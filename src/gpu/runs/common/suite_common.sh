#!/usr/bin/env bash
set -euo pipefail

COMMON_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

setup_cuda_tools() {
    if ! command -v nvidia-smi >/dev/null 2>&1; then
        echo "ERROR: nvidia-smi not found; NVIDIA driver likely unavailable."
        exit 1
    fi
    if ! command -v nvcc >/dev/null 2>&1; then
        echo "ERROR: nvcc not found; CUDA toolkit is required."
        exit 1
    fi
}

detect_ccbin() {
    local ccbin="${NVCC_CCBIN:-g++}"
    if command -v "${ccbin}" >/dev/null 2>&1; then
        printf "%s\n" "${ccbin}"
        return 0
    fi
    if command -v g++-10 >/dev/null 2>&1; then
        printf "%s\n" "g++-10"
        return 0
    fi
    echo "ERROR: no suitable host compiler found for nvcc" >&2
    exit 1
}

compile_gpu_benchmark() {
    local bin_path="$1"
    local ccbin
    ccbin="$(detect_ccbin)"
    local src="${RUN_BENCHMARK_SRC:-${COMMON_DIR}/fft_benchmark_gpu_streaming.cu}"
    echo "[COMPILE] nvcc -O3 -std=c++17 -ccbin ${ccbin} ${src}"
    nvcc -O3 -std=c++17 -ccbin "${ccbin}" "${src}" -lcufft -o "${bin_path}"
    echo "[CHECK] nvcc     : $(nvcc --version | tail -n 1)"
    echo "[CHECK] host c++ : $(${ccbin} --version | head -n 1)"
}

detect_plot_python() {
    local preferred="${GPU_PLOT_PYTHON:-${COMMON_DIR}/../../plots/.venv/bin/python}"
    if [ -x "${preferred}" ]; then
        printf "%s\n" "${preferred}"
        return 0
    fi
    printf "%s\n" "python3"
}

generate_single_run_report() {
    local run_log="$1"
    local run_report="$2"
    python3 "${COMMON_DIR}/build_gpu_single_run_report.py" \
        --log "${run_log}" \
        --out "${run_report}"
}

write_config_env() {
    local out_path="$1"
    cat > "${out_path}" <<EOF
SESSION_TAG=${SESSION_TAG}
RUN_COUNT=${RUN_COUNT}
BENCH_NRUNS=${BENCH_NRUNS}
BENCH_WARMUP=${BENCH_WARMUP}
BENCH_MAX_MEM_MB=${BENCH_MAX_MEM_MB}
BENCH_MIN_TOTAL_MS=${BENCH_MIN_TOTAL_MS}
BENCH_MAX_ADAPT_ITERS=${BENCH_MAX_ADAPT_ITERS}
BENCH_VALIDATE=${BENCH_VALIDATE}
BENCH_VALIDATE_TOL=${BENCH_VALIDATE_TOL}
BENCH_VALIDATE_STRICT=${BENCH_VALIDATE_STRICT}
BENCH_STREAM_MODE=${BENCH_STREAM_MODE}
BENCH_STREAM_TARGET_MB=${BENCH_STREAM_TARGET_MB}
BENCH_STREAM_MIN_SLOTS=${BENCH_STREAM_MIN_SLOTS}
BENCH_STREAM_MAX_SLOTS=${BENCH_STREAM_MAX_SLOTS}
THROUGHPUT_LENGTHS=${THROUGHPUT_LENGTHS}
THROUGHPUT_BATCHES=${THROUGHPUT_BATCHES}
RUN_PROFILE_ID=${RUN_PROFILE_ID}
RUN_PROFILE_DESC=${RUN_PROFILE_DESC}
RUN_FAMILY_ID=${RUN_FAMILY_ID}
BENCH_TIMING_SCOPE=${BENCH_TIMING_SCOPE:-}
BENCH_HOST_BUFFER_MODE=${BENCH_HOST_BUFFER_MODE:-}
EOF
}

capture_gpu_inventory() {
    local session_dir="$1"
    if command -v nvidia-smi >/dev/null 2>&1; then
        nvidia-smi > "${session_dir}/nvidia_smi_full.txt" || true
        nvidia-smi --query-gpu=name,driver_version,clocks.max.sm,clocks.max.graphics,memory.total \
            --format=csv,noheader,nounits > "${session_dir}/nvidia_smi_query.csv" || true
    fi
}

run_gpu_suite() {
    : "${SCRIPT_DIR:?missing SCRIPT_DIR}"
    : "${RUN_ROOT:?missing RUN_ROOT}"
    : "${RUN_FAMILY_ID:?missing RUN_FAMILY_ID}"
    : "${RUN_PROFILE_ID:?missing RUN_PROFILE_ID}"
    : "${RUN_PROFILE_DESC:?missing RUN_PROFILE_DESC}"

    setup_cuda_tools

    SESSION_TAG="${SESSION_TAG:-$(date +"%Y%m%d_%H%M%S")}"
    SESSION_DIR="${RUN_ROOT}/${SESSION_TAG}"
    RUNS_DIR="${SESSION_DIR}/runs"
    MANIFEST="${SESSION_DIR}/manifest.tsv"

    RUN_COUNT="${RUN_COUNT:-3}"
    BENCH_NRUNS="${BENCH_NRUNS:-20}"
    BENCH_WARMUP="${BENCH_WARMUP:-5}"
    BENCH_MAX_MEM_MB="${BENCH_MAX_MEM_MB:-8192}"
    BENCH_MIN_TOTAL_MS="${BENCH_MIN_TOTAL_MS:-50}"
    BENCH_MAX_ADAPT_ITERS="${BENCH_MAX_ADAPT_ITERS:-100000000}"
    BENCH_VALIDATE="${BENCH_VALIDATE:-1}"
    BENCH_VALIDATE_TOL="${BENCH_VALIDATE_TOL:-1e-4}"
    BENCH_VALIDATE_STRICT="${BENCH_VALIDATE_STRICT:-1}"
    BENCH_STREAM_MODE="${BENCH_STREAM_MODE:-0}"
    BENCH_STREAM_TARGET_MB="${BENCH_STREAM_TARGET_MB:-128}"
    BENCH_STREAM_MIN_SLOTS="${BENCH_STREAM_MIN_SLOTS:-1}"
    BENCH_STREAM_MAX_SLOTS="${BENCH_STREAM_MAX_SLOTS:-262144}"
    THROUGHPUT_LENGTHS="${THROUGHPUT_LENGTHS:-2,4,8,16,32,64,128,256,512,1024,2048,4096,8192,16384,32768,65536}"
    THROUGHPUT_BATCHES="${THROUGHPUT_BATCHES:-1,10,16,150,256,1024}"
    BENCH_THREADS_FIELD="${BENCH_THREADS_FIELD:-1}"
    BENCH_DEVICE_INDEX="${BENCH_DEVICE_INDEX:-0}"

    mkdir -p "${RUNS_DIR}"
    echo -e "run_id\tlog_path\treport_path" > "${MANIFEST}"
    write_config_env "${SESSION_DIR}/config.env"
    capture_gpu_inventory "${SESSION_DIR}"

    local bin_path="${SCRIPT_DIR}/fft_benchmark_${RUN_FAMILY_ID}"
    compile_gpu_benchmark "${bin_path}"

    echo "[INFO] Family      : ${RUN_FAMILY_ID}"
    echo "[INFO] Session dir : ${SESSION_DIR}"
    echo "[INFO] Lengths     : ${THROUGHPUT_LENGTHS}"
    echo "[INFO] Batches     : ${THROUGHPUT_BATCHES}"
    echo "[INFO] Runs        : ${RUN_COUNT}"
    echo "[INFO] Stream mode : ${BENCH_STREAM_MODE}"

    for run_idx in $(seq 1 "${RUN_COUNT}"); do
        local run_name
        run_name="$(printf "run%02d" "${run_idx}")"
        local run_dir="${RUNS_DIR}/${run_name}"
        mkdir -p "${run_dir}"

        local ts
        ts="$(date +"%Y%m%d_%H%M%S")"
        local run_log="${run_dir}/fft_benchmark_gpu_${ts}.log"
        local run_report="${run_dir}/fft_benchmark_gpu_${ts}.report.md"

        {
            echo "============================================================"
            echo "GPU FFT RUN ${run_name}"
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
            if [ -n "${BENCH_TIMING_SCOPE:-}" ]; then
                echo "CONFIG|BENCH_TIMING_SCOPE|${BENCH_TIMING_SCOPE}"
            fi
            if [ -n "${BENCH_HOST_BUFFER_MODE:-}" ]; then
                echo "CONFIG|BENCH_HOST_BUFFER_MODE|${BENCH_HOST_BUFFER_MODE}"
            fi
            echo "PROFILE|${RUN_PROFILE_ID}|${RUN_PROFILE_DESC}|CUDA_CUFFT|${BENCH_THREADS_FIELD}|throughput|${THROUGHPUT_LENGTHS}|${THROUGHPUT_BATCHES}|${RUN_FAMILY_ID}"

            BENCH_PROFILE="${RUN_PROFILE_ID}" \
            BENCH_PROFILE_DESC="${RUN_PROFILE_DESC}" \
            BENCH_WORKLOAD="throughput" \
            BENCH_LENGTHS="${THROUGHPUT_LENGTHS}" \
            BENCH_BATCHES="${THROUGHPUT_BATCHES}" \
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
            BENCH_THREADS_FIELD="${BENCH_THREADS_FIELD}" \
            BENCH_DEVICE_INDEX="${BENCH_DEVICE_INDEX}" \
            "${bin_path}"

            echo "============================================================"
            echo "RUN COMPLETE ${run_name}"
            echo "============================================================"
        } | tee "${run_log}"

        generate_single_run_report "${run_log}" "${run_report}"
        printf "%s\t%s\t%s\n" "${run_name}" "${run_log}" "${run_report}" >> "${MANIFEST}"
    done

    python3 "${COMMON_DIR}/build_gpu_run_report.py" \
        --manifest "${MANIFEST}" \
        --out-csv "${SESSION_DIR}/latest_run_avg.csv" \
        --out-md "${SESSION_DIR}/latest_run_avg.report.md" \
        --gpu-query "${SESSION_DIR}/nvidia_smi_query.csv"

    local plot_python
    plot_python="$(detect_plot_python)"
    "${plot_python}" "${COMMON_DIR}/generate_gpu_run_plots.py" \
        --session-dir "${SESSION_DIR}" \
        --family-id "${RUN_FAMILY_ID}" \
        --expected-lengths "${THROUGHPUT_LENGTHS}" \
        --expected-batches "${THROUGHPUT_BATCHES}"

    echo "${SESSION_DIR}" > "${RUN_ROOT}/LATEST_SESSION.txt"
    ln -sfn "${SESSION_TAG}" "${RUN_ROOT}/current"

    echo "[DONE] session: ${SESSION_DIR}"
    echo "[DONE] manifest: ${MANIFEST}"
    echo "[DONE] avg report: ${SESSION_DIR}/latest_run_avg.report.md"
    echo "[DONE] avg csv: ${SESSION_DIR}/latest_run_avg.csv"
}
