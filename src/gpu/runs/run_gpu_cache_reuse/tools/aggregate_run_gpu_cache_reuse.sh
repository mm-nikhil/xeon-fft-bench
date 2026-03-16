#!/usr/bin/env bash
set -euo pipefail

if [ $# -lt 1 ] || [ $# -gt 4 ]; then
    echo "Usage: $0 <manifest_tsv> [output_report_md] [output_csv] [gpu_query_csv]"
    exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MANIFEST="$1"
MANIFEST_DIR="$(cd "$(dirname "${MANIFEST}")" && pwd)"
OUT_MD="${2:-${MANIFEST_DIR}/latest_run_avg.report.md}"
OUT_CSV="${3:-${MANIFEST_DIR}/latest_run_avg.csv}"
GPU_QUERY="${4:-${MANIFEST_DIR}/nvidia_smi_query.csv}"

python3 "${SCRIPT_DIR}/../../common/build_gpu_run_report.py" \
    --manifest "${MANIFEST}" \
    --out-md "${OUT_MD}" \
    --out-csv "${OUT_CSV}" \
    --gpu-query "${GPU_QUERY}"
