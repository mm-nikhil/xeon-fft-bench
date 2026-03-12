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
BENCH_MIN_TOTAL_MS="${BENCH_MIN_TOTAL_MS:-50}"
BENCH_MAX_ADAPT_ITERS="${BENCH_MAX_ADAPT_ITERS:-100000000}"
BENCH_VALIDATE="${BENCH_VALIDATE:-1}"
BENCH_VALIDATE_TOL="${BENCH_VALIDATE_TOL:-1e-4}"
BENCH_VALIDATE_STRICT="${BENCH_VALIDATE_STRICT:-1}"
BENCH_STREAM_MODE="${BENCH_STREAM_MODE:-1}"
BENCH_STREAM_TARGET_MB="${BENCH_STREAM_TARGET_MB:-128}"
BENCH_STREAM_MIN_SLOTS="${BENCH_STREAM_MIN_SLOTS:-2}"
BENCH_STREAM_MAX_SLOTS="${BENCH_STREAM_MAX_SLOTS:-256}"

NTHREADS_PHYSICAL="${NTHREADS_PHYSICAL:-10}"
NTHREADS_LOGICAL="${NTHREADS_LOGICAL:-20}"

THROUGHPUT_LENGTHS="${THROUGHPUT_LENGTHS:-2,4,8,16,32,64,128,256,512,1024,2048,4096,8192,16384,32768,65536}"
THROUGHPUT_BATCHES="${THROUGHPUT_BATCHES:-1,10,16,150,256,1024}"
THREAD_SCALING_SET="${THREAD_SCALING_SET:-1,10,20}"
SCALE_LENGTH="${SCALE_LENGTH:-65536}"
SCALE_BATCH="${SCALE_BATCH:-1024}"
RUN_PROFILES="${RUN_PROFILES:-baseline_sse42_1t,avx512_phys,avx512_logical}"

PEAK_GFLOPS="${PEAK_GFLOPS:-2112.0}"

SRC="${SCRIPT_DIR}/fft_benchmark_run_3_9.c"
BIN="${SCRIPT_DIR}/fft_benchmark_run_3_9"

export KMP_AFFINITY="${KMP_AFFINITY:-scatter,granularity=fine}"
export KMP_BLOCKTIME="${KMP_BLOCKTIME:-200}"
export MKL_DYNAMIC="${MKL_DYNAMIC:-FALSE}"
export MKL_VERBOSE="0"

mkdir -p "${RUNS_DIR}"
echo -e "run_id\tlog_path\treport_path" > "${MANIFEST}"

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
    local threads="$4"
    local workload="$5"
    local lengths="$6"
    local batches="$7"

    echo "============================================================"
    echo "RUN PROFILE: ${profile_id}"
    echo "Description : ${profile_desc}"
    echo "ISA         : ${isa}"
    echo "Threads     : ${threads}"
    echo "Workload    : ${workload}"
    echo "============================================================"

    echo "PROFILE|${profile_id}|${profile_desc}|${isa}|${threads}|${workload}|${lengths}|${batches}|${THREAD_SCALING_SET}|${SCALE_LENGTH}|${SCALE_BATCH}|${NTHREADS_PHYSICAL}"

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
            print "# FFT Run Report (run_3_9)"
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
            p_thr[pid] = $5
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
            print "| Profile | Description | ISA | Threads |"
            print "|---|---|---|---:|"
            for (i = 1; i <= n_profiles; i++) {
                p = profile_order[i]
                printf("| %s | %s | %s | %d |\n", p, p_desc[p], p_isa[p], p_thr[p])
            }
            print ""
            print "## Forward Results"
            print ""
            print "| Case | N | Batch | Threads | Profile | Avg Fwd ms | Avg Fwd SP GFLOPS | Mem MB |"
            print "|---|---:|---:|---:|---|---:|---:|---:|"
            for (i = 1; i <= n_rows; i++) {
                k = row_order[i]
                printf("| %s | %d | %d | %d | %s | %.6f | %.2f | %.2f |\n",
                       row_case[k], row_n[k], row_b[k], row_t[k], row_pid[k], row_ms[k], row_gf[k], row_mem[k])
            }
        }
    ' "$logfile" > "$report"
}

compile_local_bench

echo "[INFO] Session dir: ${SESSION_DIR}"
echo "[INFO] Lengths: ${THROUGHPUT_LENGTHS}"
echo "[INFO] Batches: ${THROUGHPUT_BATCHES}"
echo "[INFO] Profiles: ${RUN_PROFILES}"
echo "[INFO] Runs: ${RUN_COUNT}"

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

        should_run_profile "baseline_sse42_1t" && run_profile \
            "baseline_sse42_1t" \
            "MKL SSE4.2 baseline, single thread (CPU path, no AVX2/AVX512 kernels)" \
            "SSE4_2" \
            "1" \
            "throughput" \
            "${THROUGHPUT_LENGTHS}" \
            "${THROUGHPUT_BATCHES}"

        should_run_profile "avx512_phys" && run_profile \
            "avx512_phys" \
            "MKL AVX-512, physical-core thread count" \
            "AVX512" \
            "${NTHREADS_PHYSICAL}" \
            "throughput" \
            "${THROUGHPUT_LENGTHS}" \
            "${THROUGHPUT_BATCHES}"

        should_run_profile "avx512_logical" && run_profile \
            "avx512_logical" \
            "MKL AVX-512, logical-core thread count (hyperthreading on)" \
            "AVX512" \
            "${NTHREADS_LOGICAL}" \
            "throughput" \
            "${THROUGHPUT_LENGTHS}" \
            "${THROUGHPUT_BATCHES}"

        echo "============================================================"
        echo "RUN COMPLETE ${run_name}"
        echo "============================================================"
    } | tee "${run_log}"

    generate_run_report "${run_log}" "${run_report}"
    printf "%s\t%s\t%s\n" "${run_name}" "${run_log}" "${run_report}" >> "${MANIFEST}"

done

AVG_MD="${SESSION_DIR}/latest_run_avg.report.md"
AVG_CSV="${SESSION_DIR}/latest_run_avg.csv"
"${SCRIPT_DIR}/aggregate_run_3_9.sh" "${MANIFEST}" "${AVG_MD}" "${AVG_CSV}"

"${SCRIPT_DIR}/generate_run_3_9_plots.py" \
    --session-dir "${SESSION_DIR}" \
    --peak-gflops "${PEAK_GFLOPS}"

echo "${SESSION_DIR}" > "${RUN_ROOT}/LATEST_SESSION.txt"
ln -sfn "${SESSION_TAG}" "${RUN_ROOT}/current"

echo "[DONE] run_3_9 session: ${SESSION_DIR}"
echo "[DONE] manifest: ${MANIFEST}"
echo "[DONE] avg report: ${AVG_MD}"
echo "[DONE] avg csv: ${AVG_CSV}"
