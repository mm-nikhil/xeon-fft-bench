#!/bin/bash
# Run an archived GPU latest_run session with broad batch sweep (up to 65536)
# and generate aggregated artifacts under src/gpu/runs/older_run/64k_batch.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
GPU_DIR="$(cd "${SCRIPT_DIR}/../.." && pwd)"
LATEST_ROOT="${SCRIPT_DIR}/64k_batch"
TIMESTAMP="$(date +"%Y%m%d_%H%M%S")"
SESSION_DIR="${LATEST_ROOT}/${TIMESTAMP}"
RUN_DIR="${SESSION_DIR}/runs/run01"

mkdir -p "${RUN_DIR}"

THROUGHPUT_LENGTHS_DEFAULT="32,64,128,256,512,1024,2048,4096,8192,16384,32768,65536,131072,262144,524288,1048576,2097152,4194304"
THROUGHPUT_BATCHES_DEFAULT="1,2,4,8,16,32,64,128,256,512,1024,2048,4096,8192,16384,32768,65536"

THROUGHPUT_LENGTHS="${THROUGHPUT_LENGTHS:-${THROUGHPUT_LENGTHS_DEFAULT}}"
THROUGHPUT_BATCHES="${THROUGHPUT_BATCHES:-${THROUGHPUT_BATCHES_DEFAULT}}"
RUN_PROFILES="${RUN_PROFILES:-cufft_gpu}"
BENCH_TIMING_MODE="${BENCH_TIMING_MODE:-compute}"
BENCH_NRUNS="${BENCH_NRUNS:-20}"
BENCH_WARMUP="${BENCH_WARMUP:-5}"
BENCH_MAX_MEM_MB="${BENCH_MAX_MEM_MB:-8192}"

cat > "${SESSION_DIR}/config.env" <<EOF
TIMESTAMP=${TIMESTAMP}
RUN_PROFILES=${RUN_PROFILES}
BENCH_TIMING_MODE=${BENCH_TIMING_MODE}
BENCH_NRUNS=${BENCH_NRUNS}
BENCH_WARMUP=${BENCH_WARMUP}
BENCH_MAX_MEM_MB=${BENCH_MAX_MEM_MB}
THROUGHPUT_LENGTHS=${THROUGHPUT_LENGTHS}
THROUGHPUT_BATCHES=${THROUGHPUT_BATCHES}
EOF

if command -v nvidia-smi >/dev/null 2>&1; then
    nvidia-smi > "${SESSION_DIR}/nvidia_smi_full.txt" || true
    nvidia-smi --query-gpu=name,driver_version,clocks.max.sm,clocks.max.graphics,memory.total \
        --format=csv,noheader,nounits > "${SESSION_DIR}/nvidia_smi_query.csv" || true
fi

echo "[GPU latest_run] session_dir=${SESSION_DIR}"
echo "[GPU latest_run] starting benchmark run..."

(
    cd "${GPU_DIR}"
    RUN_PROFILES="${RUN_PROFILES}" \
    BENCH_TIMING_MODE="${BENCH_TIMING_MODE}" \
    BENCH_NRUNS="${BENCH_NRUNS}" \
    BENCH_WARMUP="${BENCH_WARMUP}" \
    BENCH_MAX_MEM_MB="${BENCH_MAX_MEM_MB}" \
    THROUGHPUT_LENGTHS="${THROUGHPUT_LENGTHS}" \
    THROUGHPUT_BATCHES="${THROUGHPUT_BATCHES}" \
    BATCH_SCALING_SET="${THROUGHPUT_BATCHES}" \
    ./run_fft_benchmarks.sh
) | tee "${RUN_DIR}/driver_stdout.log"

LOG_REL="$(awk -F': ' '/^Log    : /{v=$2} END{print v}' "${RUN_DIR}/driver_stdout.log")"
REPORT_REL="$(awk -F': ' '/^Report : /{v=$2} END{print v}' "${RUN_DIR}/driver_stdout.log")"

if [ -z "${LOG_REL}" ] || [ -z "${REPORT_REL}" ]; then
    echo "ERROR: failed to parse generated log/report paths from driver output"
    exit 1
fi

if [[ "${LOG_REL}" = /* ]]; then
    SRC_LOG="${LOG_REL}"
else
    SRC_LOG="${GPU_DIR}/${LOG_REL#./}"
fi
if [[ "${REPORT_REL}" = /* ]]; then
    SRC_REPORT="${REPORT_REL}"
else
    SRC_REPORT="${GPU_DIR}/${REPORT_REL#./}"
fi

if [ ! -f "${SRC_LOG}" ]; then
    echo "ERROR: expected log not found: ${SRC_LOG}"
    exit 1
fi
if [ ! -f "${SRC_REPORT}" ]; then
    echo "ERROR: expected report not found: ${SRC_REPORT}"
    exit 1
fi

cp "${SRC_LOG}" "${RUN_DIR}/"
cp "${SRC_REPORT}" "${RUN_DIR}/"

RUN_LOG="${RUN_DIR}/$(basename "${SRC_LOG}")"
RUN_REPORT="${RUN_DIR}/$(basename "${SRC_REPORT}")"

cat > "${SESSION_DIR}/manifest.tsv" <<EOF
run_id	log_path	report_path
run01	${RUN_LOG}	${RUN_REPORT}
EOF

python3 "${SCRIPT_DIR}/build_latest_run_report.py" \
    --manifest "${SESSION_DIR}/manifest.tsv" \
    --out-csv "${SESSION_DIR}/latest_run_avg.csv" \
    --out-md "${SESSION_DIR}/latest_run_avg.report.md" \
    --gpu-query "${SESSION_DIR}/nvidia_smi_query.csv"

mkdir -p "${LATEST_ROOT}"
ln -sfn "${SESSION_DIR}" "${LATEST_ROOT}/current"
printf "%s\n" "${SESSION_DIR}" > "${LATEST_ROOT}/LATEST_SESSION.txt"
printf "%s\n" "${SESSION_DIR}" > "${SCRIPT_DIR}/LATEST_SESSION.txt"

echo "[GPU latest_run] complete"
echo "[GPU latest_run] manifest: ${SESSION_DIR}/manifest.tsv"
echo "[GPU latest_run] csv     : ${SESSION_DIR}/latest_run_avg.csv"
echo "[GPU latest_run] report  : ${SESSION_DIR}/latest_run_avg.report.md"
