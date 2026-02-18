#!/bin/bash
# =============================================================
# run_fft_benchmarks.sh
# MKL 1D FFT benchmark driver with profile-based runs and markdown reporting.
#
# Optional overrides:
#   MKLROOT=/path/to/mkl
#   BENCH_NRUNS=20 BENCH_WARMUP=5 BENCH_MAX_MEM_MB=3072
#   NTHREADS_PHYSICAL=10 NTHREADS_LOGICAL=20
#   THROUGHPUT_LENGTHS=1024,4096,16384,65536,262144 THROUGHPUT_BATCHES=1,4,16
#   THREAD_SCALING_SET=1,2,4,8,10,20
#   BATCH_SCALING_SET=1,4,16,64,256
#   SCALE_LENGTH=16384 SCALE_BATCH=64
# =============================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

TIMESTAMP="$(date +"%Y%m%d_%H%M%S")"
LOGDIR="./fft_logs"
mkdir -p "$LOGDIR"
LOGFILE="${LOGDIR}/fft_benchmark_${TIMESTAMP}.log"
REPORT_MD="${LOGDIR}/fft_benchmark_${TIMESTAMP}.report.md"

exec > >(tee -a "$LOGFILE") 2>&1

NTHREADS_PHYSICAL="${NTHREADS_PHYSICAL:-10}"
NTHREADS_LOGICAL="${NTHREADS_LOGICAL:-20}"
BENCH_NRUNS="${BENCH_NRUNS:-20}"
BENCH_WARMUP="${BENCH_WARMUP:-5}"
BENCH_MAX_MEM_MB="${BENCH_MAX_MEM_MB:-3072}"
RUN_PROFILES="${RUN_PROFILES:-all}"

THROUGHPUT_LENGTHS="${THROUGHPUT_LENGTHS:-1024,4096,16384,65536,262144}"
THROUGHPUT_BATCHES="${THROUGHPUT_BATCHES:-1,4,16}"
THREAD_SCALING_SET="${THREAD_SCALING_SET:-1,2,4,8,10,20}"
BATCH_SCALING_SET="${BATCH_SCALING_SET:-1,4,16,64,256}"
SCALE_LENGTH="${SCALE_LENGTH:-16384}"
SCALE_BATCH="${SCALE_BATCH:-64}"

# Runtime policy for reproducibility.
export KMP_AFFINITY="scatter,granularity=fine"
export KMP_BLOCKTIME="200"
export MKL_DYNAMIC="FALSE"
export MKL_VERBOSE="0"

export BENCH_NRUNS BENCH_WARMUP BENCH_MAX_MEM_MB

setup_intel_env() {
    echo "[SETUP] Sourcing Intel oneAPI environment if available..."
    if [ -f /opt/intel/oneapi/setvars.sh ]; then
        # shellcheck disable=SC1091
        source /opt/intel/oneapi/setvars.sh --force >/dev/null 2>&1 || true
        echo "        Sourced: /opt/intel/oneapi/setvars.sh"
    elif [ -f /opt/intel/mkl/bin/mklvars.sh ]; then
        # shellcheck disable=SC1091
        source /opt/intel/mkl/bin/mklvars.sh intel64 >/dev/null 2>&1 || true
        echo "        Sourced: /opt/intel/mkl/bin/mklvars.sh"
    elif command -v module >/dev/null 2>&1; then
        module load intel/oneapi 2>/dev/null || module load mkl 2>/dev/null || true
    fi
    echo ""
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

setup_intel_env

if ! MKLROOT="$(detect_mklroot)"; then
    echo "ERROR: Intel MKL not found."
    echo "Tried MKLROOT, /opt/intel/oneapi/mkl/latest, /opt/intel/mkl, ~/.local"
    echo "For user-space install: python3 -m pip install --user mkl-devel"
    exit 1
fi

MKL_INCLUDE_DIR="${MKLROOT}/include"
if [ -d "${MKLROOT}/lib/intel64" ]; then
    MKL_LIB_DIR="${MKLROOT}/lib/intel64"
elif [ -d "${MKLROOT}/lib" ]; then
    MKL_LIB_DIR="${MKLROOT}/lib"
else
    echo "ERROR: Could not find MKL library directory under ${MKLROOT}"
    exit 1
fi

if [ -f "${MKL_LIB_DIR}/libmkl_rt.so" ]; then
    MKL_RT_FLAG="-lmkl_rt"
elif [ -f "${MKL_LIB_DIR}/libmkl_rt.so.2" ]; then
    MKL_RT_FLAG="-l:libmkl_rt.so.2"
else
    echo "ERROR: libmkl_rt not found in ${MKL_LIB_DIR}"
    exit 1
fi

MKL_LIBS="-L${MKL_LIB_DIR} ${MKL_RT_FLAG} -lpthread -lm -ldl"
RPATH_FLAG="-Wl,-rpath,${MKL_LIB_DIR}"
INCLUDE_FLAG="-I${MKL_INCLUDE_DIR}"
export LD_LIBRARY_PATH="${MKL_LIB_DIR}:${LD_LIBRARY_PATH:-}"

echo "============================================================"
echo "  FFT BENCHMARK RUN (1D)"
echo "  Date       : $(date)"
echo "  Hostname   : $(hostname)"
echo "  Log file   : ${LOGFILE}"
echo "  Report file: ${REPORT_MD}"
echo "============================================================"
echo ""

echo "[CHECK] MKL environment"
echo "        MKLROOT     = ${MKLROOT}"
echo "        Include dir = ${MKL_INCLUDE_DIR}"
echo "        Lib dir     = ${MKL_LIB_DIR}"
echo "        Runtime lib = ${MKL_RT_FLAG}"
echo ""

USE_ICX=0
if command -v icx >/dev/null 2>&1; then
    CC="icx"
    USE_ICX=1
    echo "[CHECK] Compiler: $(icx --version 2>&1 | head -1)"
elif command -v icc >/dev/null 2>&1; then
    CC="icc"
    USE_ICX=1
    echo "[CHECK] Compiler: $(icc --version 2>&1 | head -1)"
elif command -v gcc >/dev/null 2>&1; then
    CC="gcc"
    echo "[CHECK] Compiler: $(gcc --version | head -1)"
else
    echo "ERROR: no supported compiler found (icx, icc, gcc)"
    exit 1
fi

echo ""
if [ "${USE_ICX}" -eq 1 ]; then
    CFLAGS="-O3 -xHost -std=c99"
else
    CFLAGS="-O3 -march=native -std=c99"
fi

SRC="fft_benchmark.c"
BIN="fft_benchmark"

echo "[COMPILE] ${CC} ${CFLAGS} ${SRC}"
${CC} ${CFLAGS} ${INCLUDE_FLAG} "${SRC}" ${RPATH_FLAG} ${MKL_LIBS} -o "${BIN}"
echo "          Binary: ${BIN}"
echo ""

echo "[CONFIG] timed runs=${BENCH_NRUNS}, warmup=${BENCH_WARMUP}, mem_cap_mb=${BENCH_MAX_MEM_MB}"
echo "[CONFIG] run profiles=${RUN_PROFILES}"
echo "[CONFIG] throughput lengths=${THROUGHPUT_LENGTHS}, batches=${THROUGHPUT_BATCHES}"
echo "[CONFIG] thread scaling set=${THREAD_SCALING_SET}, scale length=${SCALE_LENGTH}, scale batch=${SCALE_BATCH}"
echo "[CONFIG] batch scaling set=${BATCH_SCALING_SET}, scale length=${SCALE_LENGTH}"
if awk -F',' '
    BEGIN { bad=0 }
    {
        for (i = 1; i <= NF; i++) {
            gsub(/^[ \t]+|[ \t]+$/, "", $i);
            if (($i + 0) < 1024) { bad=1; break; }
        }
    }
    END { exit bad ? 0 : 1 }
' <<< "${THROUGHPUT_LENGTHS}"; then
    echo "[WARN] throughput lengths include values < 1024."
    echo "       For 1D multithread runs, tiny lengths are overhead-dominated and can look falsely slow."
fi
echo ""

run_profile() {
    local profile_id="$1"
    local profile_desc="$2"
    local isa="$3"
    local threads="$4"
    local workload="$5"
    local lengths="$6"
    local batches="$7"
    local thread_set="$8"
    local scale_length="$9"
    local scale_batch="${10}"
    local scale_threads="${11}"

    echo "============================================================"
    echo "RUN PROFILE: ${profile_id}"
    echo "Description : ${profile_desc}"
    echo "ISA         : ${isa}"
    echo "Threads     : ${threads}"
    echo "Workload    : ${workload}"
    echo "============================================================"

    echo "PROFILE|${profile_id}|${profile_desc}|${isa}|${threads}|${workload}|${lengths}|${batches}|${thread_set}|${scale_length}|${scale_batch}|${scale_threads}"

    export OMP_NUM_THREADS="${threads}"
    export MKL_NUM_THREADS="${threads}"
    export MKL_ENABLE_INSTRUCTIONS="${isa}"
    export BENCH_PROFILE="${profile_id}"
    export BENCH_PROFILE_DESC="${profile_desc}"
    export BENCH_WORKLOAD="${workload}"
    export BENCH_LENGTHS="${lengths}"
    export BENCH_BATCHES="${batches}"
    export BENCH_THREAD_SET="${thread_set}"
    export BENCH_SCALE_LENGTH="${scale_length}"
    export BENCH_SCALE_BATCH="${scale_batch}"
    export BENCH_SCALE_THREADS="${scale_threads}"

    time "./${BIN}" "${threads}"

    echo "[DONE] ${profile_id}"
    echo ""
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

# Throughput profiles (same workload, different ISA/thread profile).
should_run_profile "baseline_sse42_1t" && run_profile \
    "baseline_sse42_1t" \
    "MKL SSE4.2 baseline, single thread (CPU path, no AVX2/AVX512 kernels)" \
    "SSE4_2" \
    "1" \
    "throughput" \
    "${THROUGHPUT_LENGTHS}" \
    "${THROUGHPUT_BATCHES}" \
    "${THREAD_SCALING_SET}" \
    "${SCALE_LENGTH}" \
    "${SCALE_BATCH}" \
    "${NTHREADS_PHYSICAL}"

should_run_profile "avx2_1t" && run_profile \
    "avx2_1t" \
    "MKL AVX2, single thread" \
    "AVX2" \
    "1" \
    "throughput" \
    "${THROUGHPUT_LENGTHS}" \
    "${THROUGHPUT_BATCHES}" \
    "${THREAD_SCALING_SET}" \
    "${SCALE_LENGTH}" \
    "${SCALE_BATCH}" \
    "${NTHREADS_PHYSICAL}"

should_run_profile "avx512_1t" && run_profile \
    "avx512_1t" \
    "MKL AVX-512, single thread" \
    "AVX512" \
    "1" \
    "throughput" \
    "${THROUGHPUT_LENGTHS}" \
    "${THROUGHPUT_BATCHES}" \
    "${THREAD_SCALING_SET}" \
    "${SCALE_LENGTH}" \
    "${SCALE_BATCH}" \
    "${NTHREADS_PHYSICAL}"

should_run_profile "avx2_phys" && run_profile \
    "avx2_phys" \
    "MKL AVX2, physical-core thread count" \
    "AVX2" \
    "${NTHREADS_PHYSICAL}" \
    "throughput" \
    "${THROUGHPUT_LENGTHS}" \
    "${THROUGHPUT_BATCHES}" \
    "${THREAD_SCALING_SET}" \
    "${SCALE_LENGTH}" \
    "${SCALE_BATCH}" \
    "${NTHREADS_PHYSICAL}"

should_run_profile "avx512_phys" && run_profile \
    "avx512_phys" \
    "MKL AVX-512, physical-core thread count" \
    "AVX512" \
    "${NTHREADS_PHYSICAL}" \
    "throughput" \
    "${THROUGHPUT_LENGTHS}" \
    "${THROUGHPUT_BATCHES}" \
    "${THREAD_SCALING_SET}" \
    "${SCALE_LENGTH}" \
    "${SCALE_BATCH}" \
    "${NTHREADS_PHYSICAL}"

should_run_profile "avx512_logical" && run_profile \
    "avx512_logical" \
    "MKL AVX-512, logical-core thread count (hyperthreading on)" \
    "AVX512" \
    "${NTHREADS_LOGICAL}" \
    "throughput" \
    "${THROUGHPUT_LENGTHS}" \
    "${THROUGHPUT_BATCHES}" \
    "${THREAD_SCALING_SET}" \
    "${SCALE_LENGTH}" \
    "${SCALE_BATCH}" \
    "${NTHREADS_PHYSICAL}"

# Dedicated scaling workloads.
should_run_profile "avx512_thread_scaling" && run_profile \
    "avx512_thread_scaling" \
    "MKL AVX-512 thread scaling sweep on fixed problem" \
    "AVX512" \
    "${NTHREADS_PHYSICAL}" \
    "thread_scaling" \
    "${THROUGHPUT_LENGTHS}" \
    "${THROUGHPUT_BATCHES}" \
    "${THREAD_SCALING_SET}" \
    "${SCALE_LENGTH}" \
    "${SCALE_BATCH}" \
    "${NTHREADS_PHYSICAL}"

should_run_profile "avx512_batch_scaling" && run_profile \
    "avx512_batch_scaling" \
    "MKL AVX-512 batch scaling sweep on fixed problem" \
    "AVX512" \
    "${NTHREADS_PHYSICAL}" \
    "batch_scaling" \
    "${THROUGHPUT_LENGTHS}" \
    "${BATCH_SCALING_SET}" \
    "${THREAD_SCALING_SET}" \
    "${SCALE_LENGTH}" \
    "${SCALE_BATCH}" \
    "${NTHREADS_PHYSICAL}"

generate_markdown_report() {
    local logfile="$1"
    local report="$2"
    local generated_at="$3"

    awk -F'|' -v generated_at="$generated_at" -v source_log="$logfile" '
        function profile_note(pid, t) {
            t = threads[pid] + 0
            if (workload[pid] == "throughput" && t == 1) return "Single-thread ISA comparison"
            if (workload[pid] == "throughput" && t > 1) return "Multithread throughput at fixed thread count"
            if (workload[pid] == "thread_scaling") return "Thread sweep on fixed length and batch"
            if (workload[pid] == "batch_scaling") return "Batch sweep on fixed length and threads"
            return "-"
        }

        function throughput_key(cid, n, b) {
            return "throughput|" cid "|" n "|" b
        }

        function other_key(wk, cid, n, b, t) {
            return wk "|" cid "|" n "|" b "|" t
        }

        function fmt_ms(v) {
            if (v >= 0.1) return sprintf("%.1f", v)
            if (v >= 0.01) return sprintf("%.3f", v)
            return sprintf("%.4f", v)
        }

        BEGIN {
            print "# FFT Benchmark Report (1D)"
            print ""
            print "- Generated at: " generated_at
            print "- Source log: " source_log
            print ""
        }

        $1 == "PROFILE" {
            pid = $2
            if (!(pid in seen_profile)) {
                profile_order[++n_profiles] = pid
                seen_profile[pid] = 1
            }
            desc[pid] = $3
            isa[pid] = $4
            threads[pid] = $5
            workload[pid] = $6
            lengths[pid] = $7
            batches[pid] = $8
            thread_set[pid] = $9
            scale_length[pid] = $10
            scale_batch[pid] = $11
            scale_threads[pid] = $12
            next
        }

        $1 == "RESULT" || $1 == "SKIP" {
            is_ok = ($1 == "RESULT")
            pid = $2
            wk = $3
            cid = $4
            n = $5
            b = $8
            t = $9
            m = (is_ok ? $14 : $10)

            if (wk == "throughput") ck = throughput_key(cid, n, b)
            else ck = other_key(wk, cid, n, b, t)

            if (!(seen_case[wk, ck])) {
                seen_case[wk, ck] = 1
                case_order[wk, ++n_cases[wk]] = ck
            }

            case_id[ck] = cid
            case_n[ck] = n
            case_batch[ck] = b
            case_threads[ck] = t

            have[ck, pid] = 1
            status[ck, pid] = (is_ok ? "ok" : "skip")
            mem_mb[ck, pid] = m + 0.0
            if (is_ok) {
                fwd_ms[ck, pid] = $10 + 0.0
                fwd_gf[ck, pid] = $11 + 0.0
                bwd_ms[ck, pid] = $12 + 0.0
                bwd_gf[ck, pid] = $13 + 0.0
                reason[ck, pid] = ""
            } else {
                fwd_ms[ck, pid] = 0.0
                fwd_gf[ck, pid] = 0.0
                bwd_ms[ck, pid] = 0.0
                bwd_gf[ck, pid] = 0.0
                reason[ck, pid] = $11
            }
            next
        }

        END {
            print "## Scenario Catalog"
            print ""
            print "| Run Profile | Description | Workload | ISA Cap | Threads | What This Run Is For |"
            print "|---|---|---|---|---|---|"
            for (i = 1; i <= n_profiles; i++) {
                pid = profile_order[i]
                printf("| %s | %s | %s | %s | %s | %s |\n",
                       pid, desc[pid], workload[pid], isa[pid], threads[pid], profile_note(pid))
            }
            print ""

            print "## Consolidated Results"
            print ""
            print "Metrics use explicit units: milliseconds (`ms`), gigaflops (`GFLOPS`), and memory (`MB`)."
            print ""
            print "| Case | Length | Batch | Threads | Run Profile | ISA Cap | Fwd ms | Fwd GFLOPS | Bwd ms | Bwd GFLOPS | Mem MB | Fwd Speedup vs baseline_sse42_1t |"
            print "|---|---|---|---|---|---|---|---|---|---|---|---|"

            wk_name[1] = "throughput"
            wk_name[2] = "thread_scaling"
            wk_name[3] = "batch_scaling"

            for (w = 1; w <= 3; w++) {
                wk = wk_name[w]
                for (c = 1; c <= n_cases[wk]; c++) {
                    ck = case_order[wk, c]

                    base_ok = 0
                    base_gf = 0.0
                    if (wk == "throughput" &&
                        have[ck, "baseline_sse42_1t"] &&
                        status[ck, "baseline_sse42_1t"] == "ok") {
                        base_ok = 1
                        base_gf = fwd_gf[ck, "baseline_sse42_1t"]
                    }

                    for (i = 1; i <= n_profiles; i++) {
                        pid = profile_order[i]
                        if (workload[pid] != wk) continue
                        if (!have[ck, pid]) continue

                        row_threads = case_threads[ck]
                        if (wk == "throughput") row_threads = threads[pid]

                        spd = "-"
                        if (wk == "throughput" && status[ck, pid] == "ok") {
                            if (pid == "baseline_sse42_1t") spd = "1.00x"
                            else if (base_ok && base_gf > 0.0) spd = sprintf("%.2fx", fwd_gf[ck, pid] / base_gf)
                        }

                        if (status[ck, pid] == "ok") {
                            printf("| %s | %s | %s | %s | %s | %s | %s | %.2f | %s | %.2f | %.2f | %s |\n",
                                   case_id[ck],
                                   case_n[ck],
                                   case_batch[ck],
                                   row_threads,
                                   pid,
                                   isa[pid],
                                   fmt_ms(fwd_ms[ck, pid]),
                                   fwd_gf[ck, pid],
                                   fmt_ms(bwd_ms[ck, pid]),
                                   bwd_gf[ck, pid],
                                   mem_mb[ck, pid],
                                   spd)
                        } else {
                            rs = reason[ck, pid]
                            if (rs == "") rs = "skip"
                            printf("| %s | %s | %s | %s | %s | %s | - | - | - | - | %.2f | - |\n",
                                   case_id[ck],
                                   case_n[ck],
                                   case_batch[ck],
                                   row_threads,
                                   pid " (" rs ")",
                                   isa[pid],
                                   mem_mb[ck, pid])
                        }
                    }
                }
            }
            print ""
        }
    ' "$logfile" > "$report"
}

generate_markdown_report "$LOGFILE" "$REPORT_MD" "$(date)"

echo "============================================================"
echo "ALL RUNS COMPLETE"
echo "Log    : ${LOGFILE}"
echo "Report : ${REPORT_MD}"
echo "Lines  : $(wc -l < "${LOGFILE}")"
echo "Done at: $(date)"
echo "============================================================"
echo ""
echo "Quick inspect:"
echo "  grep '^PROFILE|' ${LOGFILE}"
echo "  grep '^RESULT|' ${LOGFILE} | head"
echo "  cat ${REPORT_MD}"
