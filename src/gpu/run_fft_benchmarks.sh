#!/bin/bash
# =============================================================
# run_fft_benchmarks.sh
# cuFFT 1D FFT benchmark driver with profile-based runs and markdown reporting.
#
# Optional overrides:
#   BENCH_NRUNS=20 BENCH_WARMUP=5 BENCH_MAX_MEM_MB=8192
#   BENCH_TIMING_MODE=compute   # compute or e2e (H2D+FFT+D2H)
#   THROUGHPUT_LENGTHS=32,64,...,4194304 THROUGHPUT_BATCHES=1,4,16
#   BATCH_SCALING_SET=1,4,16,64,256 SCALE_LENGTH=16384
#   RUN_PROFILES=all
# =============================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

TIMESTAMP="$(date +"%Y%m%d_%H%M%S")"
LOGDIR="./fft_logs"
mkdir -p "$LOGDIR"
LOGFILE="${LOGDIR}/fft_benchmark_gpu_${TIMESTAMP}.log"
REPORT_MD="${LOGDIR}/fft_benchmark_gpu_${TIMESTAMP}.report.md"

exec > >(tee -a "$LOGFILE") 2>&1

BENCH_NRUNS="${BENCH_NRUNS:-20}"
BENCH_WARMUP="${BENCH_WARMUP:-5}"
BENCH_MAX_MEM_MB="${BENCH_MAX_MEM_MB:-8192}"
RUN_PROFILES="${RUN_PROFILES:-all}"
# Default to compute-only timing for apples-to-apples comparison with MKL.
BENCH_TIMING_MODE="${BENCH_TIMING_MODE:-compute}"

THROUGHPUT_LENGTHS="${THROUGHPUT_LENGTHS:-32,64,128,256,512,1024,2048,4096,8192,16384,32768,65536,131072,262144,524288,1048576,2097152,4194304}"
THROUGHPUT_BATCHES="${THROUGHPUT_BATCHES:-1,4,16}"
BATCH_SCALING_SET="${BATCH_SCALING_SET:-1,4,16,64,256}"
SCALE_LENGTH="${SCALE_LENGTH:-16384}"

case "${BENCH_TIMING_MODE}" in
    compute|e2e) ;;
    *)
        echo "ERROR: BENCH_TIMING_MODE must be compute or e2e (got: ${BENCH_TIMING_MODE})"
        exit 1
        ;;
esac

export BENCH_NRUNS BENCH_WARMUP BENCH_MAX_MEM_MB BENCH_TIMING_MODE

echo "============================================================"
echo "  FFT BENCHMARK RUN (GPU, cuFFT, 1D)"
echo "  Date       : $(date)"
echo "  Hostname   : $(hostname)"
echo "  Log file   : ${LOGFILE}"
echo "  Report file: ${REPORT_MD}"
echo "============================================================"
echo ""

if ! command -v nvidia-smi >/dev/null 2>&1; then
    echo "ERROR: nvidia-smi not found; NVIDIA driver likely unavailable."
    exit 1
fi
if ! command -v nvcc >/dev/null 2>&1; then
    echo "ERROR: nvcc not found; CUDA toolkit is required."
    exit 1
fi

echo "[CHECK] GPU context"
nvidia-smi
echo ""

CCBIN="${NVCC_CCBIN:-g++}"
if ! command -v "${CCBIN}" >/dev/null 2>&1; then
    if command -v g++-10 >/dev/null 2>&1; then
        CCBIN="g++-10"
    else
        echo "ERROR: requested host compiler '${CCBIN}' not found and g++-10 fallback missing."
        exit 1
    fi
fi

echo "[CHECK] nvcc      : $(nvcc --version | tail -n 1)"
echo "[CHECK] host c++  : $(${CCBIN} --version | head -n 1)"
echo ""

SRC="fft_benchmark.cu"
BIN="fft_benchmark"
CFLAGS="-O3 -std=c++14"

echo "[COMPILE] nvcc ${CFLAGS} -ccbin ${CCBIN} ${SRC}"
nvcc ${CFLAGS} -ccbin "${CCBIN}" "${SRC}" -lcufft -o "${BIN}"
echo "          Binary: ${BIN}"
echo ""

echo "[CONFIG] timed runs=${BENCH_NRUNS}, warmup=${BENCH_WARMUP}, mem_cap_mb=${BENCH_MAX_MEM_MB}"
echo "[CONFIG] run profiles=${RUN_PROFILES}"
echo "[CONFIG] timing mode=${BENCH_TIMING_MODE} (compute = kernel-only, e2e = H2D+FFT+D2H)"
echo "[CONFIG] throughput lengths=${THROUGHPUT_LENGTHS}, batches=${THROUGHPUT_BATCHES}"
echo "[CONFIG] batch scaling set=${BATCH_SCALING_SET}, scale length=${SCALE_LENGTH}"
echo ""

run_profile() {
    local profile_id="$1"
    local profile_desc="$2"
    local workload="$3"
    local timing_mode="$4"
    local lengths="$5"
    local batches="$6"
    local batch_scale_set="$7"
    local scale_length="$8"

    echo "============================================================"
    echo "RUN PROFILE: ${profile_id}"
    echo "Description : ${profile_desc}"
    echo "Workload    : ${workload}"
    echo "============================================================"

    echo "PROFILE|${profile_id}|${profile_desc}|CUDA_CUFFT|1|${workload}|${lengths}|${batches}|${timing_mode}|${scale_length}|-|1"

    export BENCH_PROFILE="${profile_id}"
    export BENCH_PROFILE_DESC="${profile_desc}"
    export BENCH_WORKLOAD="${workload}"
    export BENCH_TIMING_MODE="${timing_mode}"
    export BENCH_LENGTHS="${lengths}"
    export BENCH_BATCHES="${batches}"
    export BENCH_BATCH_SCALE_SET="${batch_scale_set}"
    export BENCH_SCALE_LENGTH="${scale_length}"
    export BENCH_THREADS_FIELD="1"

    time "./${BIN}"

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

should_run_profile "cufft_gpu" && run_profile \
    "cufft_gpu" \
    "cuFFT throughput sweep on RTX 3080 (1D single precision, timing=${BENCH_TIMING_MODE})" \
    "throughput" \
    "${BENCH_TIMING_MODE}" \
    "${THROUGHPUT_LENGTHS}" \
    "${THROUGHPUT_BATCHES}" \
    "${BATCH_SCALING_SET}" \
    "${SCALE_LENGTH}"

should_run_profile "cufft_gpu_batch_scaling" && run_profile \
    "cufft_gpu_batch_scaling" \
    "cuFFT batch scaling sweep on fixed length (timing=${BENCH_TIMING_MODE})" \
    "batch_scaling" \
    "${BENCH_TIMING_MODE}" \
    "${THROUGHPUT_LENGTHS}" \
    "${THROUGHPUT_BATCHES}" \
    "${BATCH_SCALING_SET}" \
    "${SCALE_LENGTH}"

generate_markdown_report() {
    local logfile="$1"
    local report="$2"
    local generated_at="$3"

    awk -F'|' -v generated_at="$generated_at" -v source_log="$logfile" '
        function workload_rank(w) {
            if (w == "throughput") return 1
            if (w == "batch_scaling") return 2
            return 9
        }
        function fmt_ms(v) {
            if (v >= 0.1) return sprintf("%.3f", v)
            if (v >= 0.01) return sprintf("%.4f", v)
            return sprintf("%.6f", v)
        }
        BEGIN {
            print "# FFT Benchmark Report (GPU, cuFFT, 1D)"
            print ""
            print "- Generated at: " generated_at
            print "- Source log: " source_log
            print ""
        }
        $1 == "PROFILE" {
            p = $2
            if (!(p in seen_profile)) {
                profile_order[++n_profiles] = p
                seen_profile[p] = 1
            }
            p_desc[p] = $3
            p_workload[p] = $6
            p_timing[p] = $9
            next
        }
        $1 == "RESULT" || $1 == "SKIP" {
            ok = ($1 == "RESULT")
            p = $2
            w = $3
            c = $4
            n = $5 + 0
            b = $8 + 0
            t = $9 + 0
            k = w SUBSEP c SUBSEP n SUBSEP b SUBSEP t SUBSEP p

            rows[k] = 1
            w_case = w SUBSEP c SUBSEP n SUBSEP b SUBSEP t
            cases[w_case] = 1
            workload[w_case] = w
            case_id[w_case] = c
            case_n[w_case] = n
            case_b[w_case] = b
            case_t[w_case] = t

            if (ok) {
                fwd_ms[k] = $10 + 0.0
                fwd_gf[k] = $11 + 0.0
                bwd_ms[k] = $12 + 0.0
                bwd_gf[k] = $13 + 0.0
                mem_mb[k] = $14 + 0.0
                status[k] = "ok"
            } else {
                mem_mb[k] = $10 + 0.0
                status[k] = "skip"
                reason[k] = $11
            }
            next
        }
        END {
            print "## Scenario Catalog"
            print ""
            print "| Run Profile | Description | Workload | Timing Mode |"
            print "|---|---|---|---|"
            for (i = 1; i <= n_profiles; i++) {
                p = profile_order[i]
                printf("| %s | %s | %s | %s |\n", p, p_desc[p], p_workload[p], p_timing[p])
            }
            print ""

            print "## Consolidated Results"
            print ""
            print "Metrics use explicit units: milliseconds (`ms`), single-precision gigaflops (`SP GFLOPS`), and memory (`MB`)."
            print ""
            print "| Workload | Case | Length | Batch | ThreadsField | Run Profile | Fwd ms | Fwd SP GFLOPS | Bwd ms | Bwd SP GFLOPS | Mem MB | Status |"
            print "|---|---|---|---|---|---|---|---|---|---|---|---|"

            n_case = 0
            for (ck in cases) {
                case_order[++n_case] = ck
            }
            for (i = 1; i <= n_case; i++) {
                for (j = i + 1; j <= n_case; j++) {
                    a = case_order[i]
                    b = case_order[j]
                    split(a, aa, SUBSEP); split(b, bb, SUBSEP)
                    ra = workload_rank(aa[1]); rb = workload_rank(bb[1])
                    if (ra > rb || (ra == rb && (aa[3] > bb[3] || (aa[3] == bb[3] && aa[4] > bb[4])))) {
                        case_order[i] = b
                        case_order[j] = a
                    }
                }
            }

            for (ci = 1; ci <= n_case; ci++) {
                ck = case_order[ci]
                for (i = 1; i <= n_profiles; i++) {
                    p = profile_order[i]
                    k = workload[ck] SUBSEP case_id[ck] SUBSEP case_n[ck] SUBSEP case_b[ck] SUBSEP case_t[ck] SUBSEP p
                    if (!(k in rows)) continue
                    if (status[k] == "ok") {
                        printf("| %s | %s | %d | %d | %d | %s | %s | %.2f | %s | %.2f | %.2f | ok |\n",
                               workload[ck], case_id[ck], case_n[ck], case_b[ck], case_t[ck], p,
                               fmt_ms(fwd_ms[k]), fwd_gf[k], fmt_ms(bwd_ms[k]), bwd_gf[k], mem_mb[k])
                    } else {
                        printf("| %s | %s | %d | %d | %d | %s | - | - | - | - | %.2f | skip (%s) |\n",
                               workload[ck], case_id[ck], case_n[ck], case_b[ck], case_t[ck], p, mem_mb[k], reason[k])
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
