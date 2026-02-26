#!/bin/bash
# Run 5x 1D FFT benchmark campaign focused on:
# - baseline_sse42_1t
# - avx512_phys (10 threads)
# - avx512_logical (20 threads)
#
# Produces:
# - per-run logs/reports
# - manifest
# - averaged markdown + csv
# - representative VTune run summary/status
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

LATEST_ROOT="${LATEST_ROOT:-${SCRIPT_DIR}/fft_logs/latest_run}"
SESSION_TAG="${SESSION_TAG:-$(date +"%Y%m%d_%H%M%S")}"
SESSION_DIR="${LATEST_ROOT}/${SESSION_TAG}"
RUNS_DIR="${SESSION_DIR}/runs"
VTUNE_DIR="${SESSION_DIR}/vtune"

RUN_COUNT="${RUN_COUNT:-5}"
BENCH_NRUNS="${BENCH_NRUNS:-20}"
BENCH_WARMUP="${BENCH_WARMUP:-5}"
BENCH_MAX_MEM_MB="${BENCH_MAX_MEM_MB:-3072}"
THROUGHPUT_BATCHES="${THROUGHPUT_BATCHES:-1,4,16}"
RUN_PROFILES="baseline_sse42_1t,avx512_phys,avx512_logical"

VTUNE_THREADS_LIST="${VTUNE_THREADS_LIST:-10 20}"
VTUNE_ANALYSIS_LIST="${VTUNE_ANALYSIS_LIST:-hpc-performance hotspots threading}"
VTUNE_LENGTH="${VTUNE_LENGTH:-8192}"
VTUNE_BATCH="${VTUNE_BATCH:-16}"
VTUNE_BENCH_NRUNS="${VTUNE_BENCH_NRUNS:-80}"
VTUNE_BENCH_WARMUP="${VTUNE_BENCH_WARMUP:-10}"

mkdir -p "$RUNS_DIR" "$VTUNE_DIR"

build_lengths_pow2_32_to_2p22() {
    local n=32
    local out=""
    while [ "$n" -le 4194304 ]; do
        if [ -z "$out" ]; then
            out="$n"
        else
            out="${out},${n}"
        fi
        n=$((n * 2))
    done
    printf "%s" "$out"
}

THROUGHPUT_LENGTHS="${THROUGHPUT_LENGTHS:-$(build_lengths_pow2_32_to_2p22)}"
MANIFEST="${SESSION_DIR}/manifest.tsv"
echo -e "run_id\tlog_path\treport_path" > "$MANIFEST"

echo "[INFO] Session dir: $SESSION_DIR"
echo "[INFO] Profiles: $RUN_PROFILES"
echo "[INFO] Lengths: $THROUGHPUT_LENGTHS"
echo "[INFO] Batches: $THROUGHPUT_BATCHES"
echo "[INFO] Repeats: $RUN_COUNT"

for run_idx in $(seq 1 "$RUN_COUNT"); do
    run_name="$(printf "run%02d" "$run_idx")"
    run_dir="${RUNS_DIR}/${run_name}"
    driver_log="${run_dir}/driver_stdout.log"
    mkdir -p "$run_dir"

    echo "[RUN] ${run_name} ..."
    (
        cd "$SCRIPT_DIR"
        BENCH_LOGDIR="$run_dir" \
        RUN_PROFILES="$RUN_PROFILES" \
        THROUGHPUT_LENGTHS="$THROUGHPUT_LENGTHS" \
        THROUGHPUT_BATCHES="$THROUGHPUT_BATCHES" \
        BENCH_NRUNS="$BENCH_NRUNS" \
        BENCH_WARMUP="$BENCH_WARMUP" \
        BENCH_MAX_MEM_MB="$BENCH_MAX_MEM_MB" \
        ./run_fft_benchmarks.sh
    ) > "$driver_log" 2>&1

    run_log="$(ls -1t "${run_dir}"/fft_benchmark_*.log | head -n1)"
    run_report="$(ls -1t "${run_dir}"/fft_benchmark_*.report.md | head -n1)"
    printf "%s\t%s\t%s\n" "$run_name" "$run_log" "$run_report" >> "$MANIFEST"
    echo "[RUN] ${run_name} complete: ${run_log}"
done

AVG_MD="${SESSION_DIR}/latest_run_avg.report.md"
AVG_CSV="${SESSION_DIR}/latest_run_avg.csv"
"${SCRIPT_DIR}/aggregate_fft_latest_run.sh" "$MANIFEST" "$AVG_MD" "$AVG_CSV"

echo "[VTUNE] Running representative AVX512 profiling ..."
VTUNE_DRIVER_LOG="${VTUNE_DIR}/driver_stdout.log"
(
    cd "$SCRIPT_DIR"
    RESULTS_BASE="${VTUNE_DIR}/results" \
    THREADS_LIST="${VTUNE_THREADS_LIST}" \
    ANALYSIS_LIST="${VTUNE_ANALYSIS_LIST}" \
    LENGTH="${VTUNE_LENGTH}" \
    BATCH="${VTUNE_BATCH}" \
    BENCH_NRUNS="${VTUNE_BENCH_NRUNS}" \
    BENCH_WARMUP="${VTUNE_BENCH_WARMUP}" \
    ./run_vtune_ports_profile.sh
) > "$VTUNE_DRIVER_LOG" 2>&1 || true

VTUNE_LATEST="$(ls -1dt "${VTUNE_DIR}"/results/* 2>/dev/null | head -n1 || true)"
if [ -n "$VTUNE_LATEST" ]; then
    if [ -f "${VTUNE_LATEST}/run_summary.tsv" ]; then
        cp "${VTUNE_LATEST}/run_summary.tsv" "${VTUNE_DIR}/run_summary.tsv"
    fi
    if [ -f "${VTUNE_LATEST}/vtune_collection_status.tsv" ]; then
        cp "${VTUNE_LATEST}/vtune_collection_status.tsv" "${VTUNE_DIR}/vtune_collection_status.tsv"
    fi

    {
        echo
        echo "## VTune Snapshot (Representative AVX512 Cases)"
        echo
        echo "- VTune root: \`${VTUNE_LATEST}\`"
        if [ -f "${VTUNE_DIR}/vtune_collection_status.tsv" ]; then
            echo
            echo "| Status | Analysis | Threads | Path/Log |"
            echo "|---|---|---:|---|"
            tail -n +2 "${VTUNE_DIR}/vtune_collection_status.tsv" | awk -F'\t' '{printf("| %s | %s | %s | `%s` |\n", $1, $2, $3, $4)}'
        fi
        if [ -f "${VTUNE_DIR}/run_summary.tsv" ]; then
            echo
            echo "| Threads | Case | Fwd GFLOPS | Bwd GFLOPS | Peak GFLOPS | Fwd % Peak | Bwd % Peak |"
            echo "|---:|---|---:|---:|---:|---:|---:|"
            tail -n +2 "${VTUNE_DIR}/run_summary.tsv" | awk -F'\t' '{printf("| %s | %s | %s | %s | %s | %s%% | %s%% |\n", $1, $2, $3, $4, $5, $6, $7)}'
        fi
    } >> "$AVG_MD"
fi

echo "$SESSION_DIR" > "${LATEST_ROOT}/LATEST_SESSION.txt"
ln -sfn "$SESSION_TAG" "${LATEST_ROOT}/current"

echo "[DONE] latest_run session: $SESSION_DIR"
echo "[DONE] manifest: $MANIFEST"
echo "[DONE] avg report: $AVG_MD"
echo "[DONE] avg csv: $AVG_CSV"
