#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
RUN_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

SESSION_TAG="${SESSION_TAG:-$(date +"%Y%m%d_%H%M%S")}"
SESSION_DIR="${RUN_ROOT}/${SESSION_TAG}"
RUNS_DIR="${SESSION_DIR}/runs"
MANIFEST="${SESSION_DIR}/manifest.tsv"

RUN_COUNT="${RUN_COUNT:-3}"
BENCH_NRUNS="${BENCH_NRUNS:-20}"
BENCH_WARMUP="${BENCH_WARMUP:-5}"
BENCH_MAX_MEM_MB="${BENCH_MAX_MEM_MB:-3072}"
BENCH_MIN_TOTAL_MS="${BENCH_MIN_TOTAL_MS:-75}"
BENCH_MAX_ADAPT_ITERS="${BENCH_MAX_ADAPT_ITERS:-100000000}"
BENCH_VALIDATE="${BENCH_VALIDATE:-1}"
BENCH_VALIDATE_TOL="${BENCH_VALIDATE_TOL:-1e-4}"
BENCH_VALIDATE_STRICT="${BENCH_VALIDATE_STRICT:-1}"
BENCH_STREAM_MODE="${BENCH_STREAM_MODE:-1}"
BENCH_STREAM_TARGET_MB="${BENCH_STREAM_TARGET_MB:-1024}"
BENCH_STREAM_MIN_SLOTS="${BENCH_STREAM_MIN_SLOTS:-64}"
BENCH_STREAM_MAX_SLOTS="${BENCH_STREAM_MAX_SLOTS:-32768}"

THROUGHPUT_LENGTHS="${THROUGHPUT_LENGTHS:-2,4,8,16,32,64,128,256,512,1024,2048,4096,8192,16384,32768,65536,131072,262144,524288,1048576,2097152,4194304}"
THROUGHPUT_BATCHES="${THROUGHPUT_BATCHES:-1}"
THREAD_SCALING_SET="${THREAD_SCALING_SET:-1,10,20}"
SCALE_LENGTH="${SCALE_LENGTH:-4194304}"
SCALE_BATCH="${SCALE_BATCH:-1024}"
RUN_PROFILES="${RUN_PROFILES:-all}"

CORE_SWEEP_MIN="${CORE_SWEEP_MIN:-1}"
CORE_SWEEP_MAX="${CORE_SWEEP_MAX:-10}"
LOGICAL_FACTOR_SET="${LOGICAL_FACTOR_SET:-1,2}"

PEAK_GFLOPS="${PEAK_GFLOPS:-2112.0}"

SRC="${SCRIPT_DIR}/fft_benchmark_run_core_wise.c"
BIN="${SCRIPT_DIR}/fft_benchmark_run_core_wise"

export KMP_AFFINITY="${KMP_AFFINITY:-scatter,granularity=fine}"
export KMP_BLOCKTIME="${KMP_BLOCKTIME:-200}"
export MKL_DYNAMIC="${MKL_DYNAMIC:-FALSE}"
export MKL_VERBOSE="0"

mkdir -p "${RUNS_DIR}"
echo -e "run_id\tlog_path\treport_path" > "${MANIFEST}"

declare -a PHYS_CPUS=()
declare -a SMT_CPUS=()
TOPO_SOCKET=""
TOPO_AVAILABLE_CORES=0
TOPO_HAS_SMT=0

setup_intel_env() {
    if [ -f /opt/intel/oneapi/setvars.sh ]; then
        # shellcheck disable=SC1091
        source /opt/intel/oneapi/setvars.sh --force >/dev/null 2>&1 || true
    elif [ -f /opt/intel/mkl/bin/mklvars.sh ]; then
        # shellcheck disable=SC1091
        source /opt/intel/mkl/bin/mklvars.sh intel64 >/dev/null 2>&1 || true
    fi
}

detect_mklroot() {
    local candidate
    for candidate in \
        "${MKLROOT:-}" \
        "/opt/intel/oneapi/mkl/latest" \
        "/opt/intel/mkl" \
        "${HOME}/.local"
    do
        [ -n "$candidate" ] || continue
        if [ -f "${candidate}/include/mkl_dfti.h" ]; then
            echo "$candidate"
            return 0
        fi
    done
    return 1
}

compile_local_bench() {
    setup_intel_env

    local mklroot
    if ! mklroot="$(detect_mklroot)"; then
        echo "ERROR: Intel MKL not found."
        exit 1
    fi

    local include_dir="${mklroot}/include"
    local lib_dir="${mklroot}/lib/intel64"
    if [ ! -d "${lib_dir}" ]; then
        lib_dir="${mklroot}/lib"
    fi
    if [ ! -d "${lib_dir}" ]; then
        echo "ERROR: MKL lib directory not found under ${mklroot}"
        exit 1
    fi

    local rt_flag="-lmkl_rt"
    if [ ! -f "${lib_dir}/libmkl_rt.so" ] && [ -f "${lib_dir}/libmkl_rt.so.2" ]; then
        rt_flag="-l:libmkl_rt.so.2"
    fi

    local cc="gcc"
    local cflags="-O3 -march=native -std=c99"
    if command -v icx >/dev/null 2>&1; then
        cc="icx"
        cflags="-O3 -xHost -std=c99"
    elif command -v icc >/dev/null 2>&1; then
        cc="icc"
        cflags="-O3 -xHost -std=c99"
    fi

    echo "[BUILD] ${cc} ${cflags} ${SRC}"
    "${cc}" ${cflags} -I"${include_dir}" "${SRC}" \
        -Wl,-rpath,"${lib_dir}" -L"${lib_dir}" ${rt_flag} -lpthread -lm -ldl \
        -o "${BIN}"

    export LD_LIBRARY_PATH="${lib_dir}:${LD_LIBRARY_PATH:-}"
}

detect_cpu_topology() {
    if ! command -v lscpu >/dev/null 2>&1; then
        echo "ERROR: lscpu not found (required for core-wise pinning)."
        exit 1
    fi

    mapfile -t topo_rows < <(
        lscpu -p=CPU,CORE,SOCKET,ONLINE | \
            awk -F',' '
                BEGIN { first_socket = -1 }
                /^#/ { next }
                {
                    cpu = $1 + 0
                    core = $2 + 0
                    socket = $3 + 0
                    online = toupper($4)
                    if (online != "Y") next
                    if (first_socket < 0) first_socket = socket
                    if (socket != first_socket) next
                    print cpu "," core "," socket
                }
            ' | sort -t',' -k2,2n -k1,1n
    )

    if [ "${#topo_rows[@]}" -eq 0 ]; then
        echo "ERROR: Unable to parse online CPUs from lscpu -p."
        exit 1
    fi

    local row cpu core socket
    local -a core_order=()
    declare -A first_cpu=()
    declare -A sibling_cpu=()

    for row in "${topo_rows[@]}"; do
        cpu="${row%%,*}"
        row="${row#*,}"
        core="${row%%,*}"
        socket="${row#*,}"

        if [ -z "${TOPO_SOCKET}" ]; then
            TOPO_SOCKET="${socket}"
        fi

        if [ -z "${first_cpu[${core}]+x}" ]; then
            first_cpu["${core}"]="${cpu}"
            core_order+=("${core}")
        elif [ -z "${sibling_cpu[${core}]+x}" ]; then
            sibling_cpu["${core}"]="${cpu}"
        fi
    done

    PHYS_CPUS=()
    SMT_CPUS=()
    local c
    for c in "${core_order[@]}"; do
        PHYS_CPUS+=("${first_cpu[${c}]}")
        if [ -n "${sibling_cpu[${c}]+x}" ]; then
            SMT_CPUS+=("${sibling_cpu[${c}]}")
        fi
    done

    TOPO_AVAILABLE_CORES="${#PHYS_CPUS[@]}"
    if [ "${#SMT_CPUS[@]}" -eq "${TOPO_AVAILABLE_CORES}" ] && [ "${TOPO_AVAILABLE_CORES}" -gt 0 ]; then
        TOPO_HAS_SMT=1
    else
        TOPO_HAS_SMT=0
    fi

    if [ "${TOPO_AVAILABLE_CORES}" -lt 1 ]; then
        echo "ERROR: Could not detect any online physical cores."
        exit 1
    fi
}

cpu_list_for_profile() {
    local core_count="$1"
    local threads_per_core="$2"

    local -a cpus=()
    local i
    for ((i = 0; i < core_count; i++)); do
        cpus+=("${PHYS_CPUS[$i]}")
    done

    if [ "${threads_per_core}" -eq 2 ]; then
        for ((i = 0; i < core_count; i++)); do
            cpus+=("${SMT_CPUS[$i]}")
        done
    fi

    local IFS=,
    printf "%s" "${cpus[*]}"
}

should_run_profile() {
    local profile_id="$1"
    if [ "${RUN_PROFILES}" = "all" ]; then
        return 0
    fi
    case ",${RUN_PROFILES}," in
        *,"${profile_id}",*) return 0 ;;
        *) return 1 ;;
    esac
}

run_profile() {
    local profile_id="$1"
    local profile_desc="$2"
    local isa="$3"
    local core_count="$4"
    local threads_per_core="$5"
    local threads="$6"
    local workload="$7"
    local lengths="$8"
    local batches="$9"
    local cpu_list="${10}"

    echo "============================================================"
    echo "RUN PROFILE: ${profile_id}"
    echo "Description : ${profile_desc}"
    echo "ISA         : ${isa}"
    echo "Cores       : ${core_count}"
    echo "Threads/core: ${threads_per_core}"
    echo "Threads     : ${threads}"
    echo "CPU set     : ${cpu_list}"
    echo "Workload    : ${workload}"
    echo "============================================================"

    echo "PROFILE|${profile_id}|${profile_desc}|${isa}|${threads}|${workload}|${lengths}|${batches}|${THREAD_SCALING_SET}|${SCALE_LENGTH}|${SCALE_BATCH}|${TOPO_AVAILABLE_CORES}|${core_count}|${threads_per_core}|${cpu_list}"

    taskset -c "${cpu_list}" env \
        OMP_NUM_THREADS="${threads}" \
        MKL_NUM_THREADS="${threads}" \
        MKL_ENABLE_INSTRUCTIONS="${isa}" \
        BENCH_PROFILE="${profile_id}" \
        BENCH_PROFILE_DESC="${profile_desc}" \
        BENCH_WORKLOAD="${workload}" \
        BENCH_LENGTHS="${lengths}" \
        BENCH_BATCHES="${batches}" \
        BENCH_NRUNS="${BENCH_NRUNS}" \
        BENCH_WARMUP="${BENCH_WARMUP}" \
        BENCH_MAX_MEM_MB="${BENCH_MAX_MEM_MB}" \
        BENCH_MIN_TOTAL_MS="${BENCH_MIN_TOTAL_MS}" \
        BENCH_MAX_ADAPT_ITERS="${BENCH_MAX_ADAPT_ITERS}" \
        BENCH_VALIDATE="${BENCH_VALIDATE}" \
        BENCH_VALIDATE_TOL="${BENCH_VALIDATE_TOL}" \
        BENCH_VALIDATE_STRICT="${BENCH_VALIDATE_STRICT}" \
        BENCH_STREAM_MODE="${BENCH_STREAM_MODE}" \
        BENCH_STREAM_TARGET_MB="${BENCH_STREAM_TARGET_MB}" \
        BENCH_STREAM_MIN_SLOTS="${BENCH_STREAM_MIN_SLOTS}" \
        BENCH_STREAM_MAX_SLOTS="${BENCH_STREAM_MAX_SLOTS}" \
        "${BIN}" "${threads}"

    echo "[DONE] ${profile_id}"
    echo
}

generate_run_report() {
    local logfile="$1"
    local report="$2"

    awk -F'|' -v source_log="$logfile" -v generated_at="$(date)" '
        BEGIN {
            print "# FFT Run Report (run_core_wise)"
            print ""
            print "- Generated at: " generated_at
            print "- Source log: `" source_log "`"
            print ""
        }

        $1 == "PROFILE" {
            pid = $2
            if (!(pid in seen_profile)) {
                seen_profile[pid] = 1
                profile_order[++n_profiles] = pid
            }
            p_desc[pid] = $3
            p_isa[pid] = $4
            p_thr[pid] = $5 + 0
            p_cores[pid] = ($13 == "" ? -1 : $13 + 0)
            p_tpc[pid] = ($14 == "" ? -1 : $14 + 0)
            next
        }

        $1 == "RESULT" {
            pid = $2
            case_id = $4
            n = $5 + 0
            b = $8 + 0
            t = $9 + 0
            fwd_ms = $10 + 0.0
            fwd_gf = $11 + 0.0
            mem = $14 + 0.0
            key = pid SUBSEP case_id
            row_pid[key] = pid
            row_case[key] = case_id
            row_n[key] = n
            row_b[key] = b
            row_t[key] = t
            row_ms[key] = fwd_ms
            row_gf[key] = fwd_gf
            row_mem[key] = mem
            if (!(key in seen_row)) {
                seen_row[key] = 1
                row_order[++n_rows] = key
            }
            next
        }

        END {
            print "## Scenario Catalog"
            print ""
            print "| Profile | Description | ISA | Cores | Threads/Core | Threads |"
            print "|---|---|---|---:|---:|---:|"
            for (i = 1; i <= n_profiles; i++) {
                p = profile_order[i]
                printf("| %s | %s | %s | %d | %d | %d |\n", p, p_desc[p], p_isa[p], p_cores[p], p_tpc[p], p_thr[p])
            }
            print ""
            print "## Forward Results"
            print ""
            print "| Case | N | Batch | Cores | Threads/Core | Threads | Profile | Avg Fwd ms | Avg Fwd SP GFLOPS | Mem MB |"
            print "|---|---:|---:|---:|---:|---:|---|---:|---:|---:|"
            for (i = 1; i <= n_rows; i++) {
                k = row_order[i]
                p = row_pid[k]
                printf("| %s | %d | %d | %d | %d | %d | %s | %.6f | %.2f | %.2f |\n",
                       row_case[k], row_n[k], row_b[k], p_cores[p], p_tpc[p], row_t[k], p, row_ms[k], row_gf[k], row_mem[k])
            }
        }
    ' "$logfile" > "$report"
}

compile_local_bench
detect_cpu_topology

if [ "${CORE_SWEEP_MIN}" -lt 1 ]; then
    CORE_SWEEP_MIN=1
fi
if [ "${CORE_SWEEP_MAX}" -gt "${TOPO_AVAILABLE_CORES}" ]; then
    CORE_SWEEP_MAX="${TOPO_AVAILABLE_CORES}"
fi
if [ "${CORE_SWEEP_MIN}" -gt "${CORE_SWEEP_MAX}" ]; then
    echo "ERROR: Invalid core sweep range CORE_SWEEP_MIN=${CORE_SWEEP_MIN}, CORE_SWEEP_MAX=${CORE_SWEEP_MAX}"
    exit 1
fi

if [ "${TOPO_HAS_SMT}" -ne 1 ]; then
    case ",${LOGICAL_FACTOR_SET}," in
        *,2,*)
            echo "ERROR: LOGICAL_FACTOR_SET includes 2 but SMT siblings are unavailable in detected topology."
            exit 1
            ;;
    esac
fi

echo "[INFO] Session dir: ${SESSION_DIR}"
echo "[INFO] Lengths: ${THROUGHPUT_LENGTHS}"
echo "[INFO] Batches: ${THROUGHPUT_BATCHES}"
echo "[INFO] Profiles filter: ${RUN_PROFILES}"
echo "[INFO] Runs: ${RUN_COUNT}"
echo "[INFO] Socket used: ${TOPO_SOCKET}"
echo "[INFO] Detected physical cores: ${TOPO_AVAILABLE_CORES}"
echo "[INFO] SMT available: ${TOPO_HAS_SMT}"
echo "[INFO] Core sweep: ${CORE_SWEEP_MIN}..${CORE_SWEEP_MAX}"
echo "[INFO] Logical factor set: ${LOGICAL_FACTOR_SET}"

for run_idx in $(seq 1 "${RUN_COUNT}"); do
    run_name="$(printf "run%02d" "${run_idx}")"
    run_dir="${RUNS_DIR}/${run_name}"
    mkdir -p "${run_dir}"

    ts="$(date +"%Y%m%d_%H%M%S")"
    run_log="${run_dir}/fft_benchmark_${ts}.log"
    run_report="${run_dir}/fft_benchmark_${ts}.report.md"

    {
        echo "============================================================"
        echo "FFT RUN ${run_name}"
        echo "Date: $(date)"
        echo "Host: $(hostname)"
        echo "============================================================"
        echo "CONFIG|BENCH_NRUNS|${BENCH_NRUNS}"
        echo "CONFIG|BENCH_WARMUP|${BENCH_WARMUP}"
        echo "CONFIG|BENCH_MAX_MEM_MB|${BENCH_MAX_MEM_MB}"
        echo "CONFIG|BENCH_MIN_TOTAL_MS|${BENCH_MIN_TOTAL_MS}"
        echo "CONFIG|BENCH_MAX_ADAPT_ITERS|${BENCH_MAX_ADAPT_ITERS}"
        echo "CONFIG|BENCH_VALIDATE|${BENCH_VALIDATE}"
        echo "CONFIG|BENCH_VALIDATE_TOL|${BENCH_VALIDATE_TOL}"
        echo "CONFIG|BENCH_VALIDATE_STRICT|${BENCH_VALIDATE_STRICT}"
        echo "CONFIG|BENCH_STREAM_MODE|${BENCH_STREAM_MODE}"
        echo "CONFIG|BENCH_STREAM_TARGET_MB|${BENCH_STREAM_TARGET_MB}"
        echo "CONFIG|BENCH_STREAM_MIN_SLOTS|${BENCH_STREAM_MIN_SLOTS}"
        echo "CONFIG|BENCH_STREAM_MAX_SLOTS|${BENCH_STREAM_MAX_SLOTS}"
        echo "CONFIG|THROUGHPUT_LENGTHS|${THROUGHPUT_LENGTHS}"
        echo "CONFIG|THROUGHPUT_BATCHES|${THROUGHPUT_BATCHES}"
        echo "CONFIG|CORE_SWEEP_MIN|${CORE_SWEEP_MIN}"
        echo "CONFIG|CORE_SWEEP_MAX|${CORE_SWEEP_MAX}"
        echo "CONFIG|LOGICAL_FACTOR_SET|${LOGICAL_FACTOR_SET}"

        for core_count in $(seq "${CORE_SWEEP_MIN}" "${CORE_SWEEP_MAX}"); do
            for factor in $(echo "${LOGICAL_FACTOR_SET}" | tr ',' ' '); do
                if [ "${factor}" != "1" ] && [ "${factor}" != "2" ]; then
                    continue
                fi
                if [ "${factor}" = "2" ] && [ "${TOPO_HAS_SMT}" -ne 1 ]; then
                    continue
                fi

                threads=$((core_count * factor))
                threads_per_core="${factor}"
                cpu_list="$(cpu_list_for_profile "${core_count}" "${threads_per_core}")"
                profile_id="$(printf "avx512_c%02d_t%02d" "${core_count}" "${threads}")"
                profile_desc="MKL AVX-512 pinned to ${core_count} core(s), ${threads} thread(s)"

                should_run_profile "${profile_id}" && run_profile \
                    "${profile_id}" \
                    "${profile_desc}" \
                    "AVX512" \
                    "${core_count}" \
                    "${threads_per_core}" \
                    "${threads}" \
                    "throughput" \
                    "${THROUGHPUT_LENGTHS}" \
                    "${THROUGHPUT_BATCHES}" \
                    "${cpu_list}"
            done
        done

        echo "============================================================"
        echo "RUN COMPLETE ${run_name}"
        echo "============================================================"
    } | tee "${run_log}"

    generate_run_report "${run_log}" "${run_report}"
    printf "%s\t%s\t%s\n" "${run_name}" "${run_log}" "${run_report}" >> "${MANIFEST}"
done

AVG_MD="${SESSION_DIR}/latest_run_avg.report.md"
AVG_CSV="${SESSION_DIR}/latest_run_avg.csv"
"${SCRIPT_DIR}/aggregate_run_core_wise.sh" "${MANIFEST}" "${AVG_MD}" "${AVG_CSV}"

"${SCRIPT_DIR}/generate_run_core_wise_plots.py" \
    --session-dir "${SESSION_DIR}" \
    --peak-gflops "${PEAK_GFLOPS}"

echo "${SESSION_DIR}" > "${RUN_ROOT}/LATEST_SESSION.txt"
ln -sfn "${SESSION_TAG}" "${RUN_ROOT}/current"

echo "[DONE] run_core_wise session: ${SESSION_DIR}"
echo "[DONE] manifest: ${MANIFEST}"
echo "[DONE] avg report: ${AVG_MD}"
echo "[DONE] avg csv: ${AVG_CSV}"
