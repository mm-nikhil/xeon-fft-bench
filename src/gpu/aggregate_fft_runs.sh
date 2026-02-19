#!/bin/bash
# Aggregate multiple cuFFT benchmark logs listed in a manifest.
# Manifest format:
#   run_index|log|report
set -euo pipefail

if [ $# -lt 1 ] || [ $# -gt 2 ]; then
    echo "Usage: $0 <manifest_file> [output_report_md]"
    exit 1
fi

MANIFEST="$1"
if [ ! -f "$MANIFEST" ]; then
    echo "ERROR: manifest file not found: $MANIFEST"
    exit 1
fi

MANIFEST_DIR="$(cd "$(dirname "$MANIFEST")" && pwd)"
TIMESTAMP="$(date +"%Y%m%d_%H%M%S")"
OUT_MD="${2:-${MANIFEST_DIR}/fft_benchmark_gpu_5run_avg_${TIMESTAMP}.report.md}"

mapfile -t MANIFEST_ROWS < <(tail -n +2 "$MANIFEST")
RUN_COUNT="${#MANIFEST_ROWS[@]}"
if [ "$RUN_COUNT" -le 0 ]; then
    echo "ERROR: manifest has no run rows: $MANIFEST"
    exit 1
fi

declare -a LOGS=()
for row in "${MANIFEST_ROWS[@]}"; do
    log_rel="$(printf "%s" "$row" | awk -F'|' '{print $2}')"
    if [ -z "$log_rel" ]; then
        echo "ERROR: malformed manifest row (missing log path): $row"
        exit 1
    fi
    if [ -f "$log_rel" ]; then
        LOGS+=("$log_rel")
    elif [ -f "${MANIFEST_DIR}/${log_rel}" ]; then
        LOGS+=("${MANIFEST_DIR}/${log_rel}")
    else
        echo "ERROR: log file from manifest not found: $log_rel"
        exit 1
    fi
done

TMP_ROWS="$(mktemp)"
TMP_PROFILES="$(mktemp)"
trap 'rm -f "$TMP_ROWS" "$TMP_PROFILES"' EXIT

awk -F'|' -v expected_runs="$RUN_COUNT" -v rows_out="$TMP_ROWS" -v profiles_out="$TMP_PROFILES" '
function workload_rank(w) {
    if (w == "throughput") return 1
    if (w == "batch_scaling") return 2
    return 9
}
function fft_flops_1d(n, b) {
    return 5.0 * n * (log(n) / log(2.0)) * b
}
$1 == "PROFILE" {
    p = $2
    if (!(p in seen_profile)) {
        seen_profile[p] = 1
        profile_order[++n_profiles] = p
    }
    p_desc[p] = $3
    p_workload[p] = $6
    p_timing[p] = $9
    next
}
$1 == "RESULT" {
    p = $2
    w = $3
    c = $4
    n = $5 + 0
    b = $8 + 0
    t = $9 + 0
    k = p SUBSEP w SUBSEP c SUBSEP n SUBSEP b SUBSEP t
    seen[k] = 1
    ok[k]++
    sum_fwd_ms[k] += $10 + 0.0
    sum_bwd_ms[k] += $12 + 0.0
    sum_mem[k] += $14 + 0.0
    next
}
$1 == "SKIP" {
    p = $2
    w = $3
    c = $4
    n = $5 + 0
    b = $8 + 0
    t = $9 + 0
    k = p SUBSEP w SUBSEP c SUBSEP n SUBSEP b SUBSEP t
    seen[k] = 1
    skip[k]++
    sum_skip_mem[k] += $10 + 0.0
    reason[k] = $11
    next
}
END {
    for (i = 1; i <= n_profiles; i++) {
        p = profile_order[i]
        printf("%s\t%s\t%s\t%s\n", p, p_desc[p], p_workload[p], p_timing[p]) >> profiles_out
    }

    for (k in seen) {
        split(k, a, SUBSEP)
        p = a[1]; w = a[2]; c = a[3]; n = a[4] + 0; b = a[5] + 0; t = a[6] + 0
        n_ok = ok[k] + 0
        n_sk = skip[k] + 0
        if (n_ok > 0) {
            avg_fwd_ms = sum_fwd_ms[k] / n_ok
            avg_bwd_ms = sum_bwd_ms[k] / n_ok
            flops = fft_flops_1d(n, b)
            avg_fwd_gf = (avg_fwd_ms > 0.0 ? flops / (avg_fwd_ms * 1.0e6) : -1.0)
            avg_bwd_gf = (avg_bwd_ms > 0.0 ? flops / (avg_bwd_ms * 1.0e6) : -1.0)
            avg_mem = sum_mem[k] / n_ok
            st = ((n_ok + n_sk) == expected_runs ? "ok" : "incomplete")
            note = "-"
        } else {
            avg_fwd_ms = -1.0
            avg_fwd_gf = -1.0
            avg_bwd_ms = -1.0
            avg_bwd_gf = -1.0
            avg_mem = (n_sk > 0 ? sum_skip_mem[k] / n_sk : 0.0)
            st = ((n_ok + n_sk) == expected_runs ? "skip" : "incomplete")
            note = reason[k]
        }
        printf("%d\t%s\t%s\t%d\t%d\t%d\t%s\t%.6f\t%.6f\t%.6f\t%.6f\t%.2f\t%d\t%d\t%d\t%s\t%s\n",
               workload_rank(w), w, c, n, b, t, p,
               avg_fwd_ms, avg_fwd_gf, avg_bwd_ms, avg_bwd_gf, avg_mem,
               n_ok, n_sk, expected_runs, st, note) >> rows_out
    }
}
' "${LOGS[@]}"

sort -t$'\t' -k1,1n -k4,4n -k5,5n -k6,6n -k7,7 "$TMP_ROWS" -o "$TMP_ROWS"
sort -t$'\t' -k1,1 "$TMP_PROFILES" -o "$TMP_PROFILES"

{
    echo "# GPU FFT Combined Report (Averaged Across Runs)"
    echo
    echo "- Generated at: $(date)"
    echo "- Manifest: \`$MANIFEST\`"
    echo "- Runs combined: ${RUN_COUNT}"
    echo "- Precision mode: single precision (cuFFT C2C)"
    echo "- Average latency (\`ms\`): arithmetic mean over successful samples."
    echo "- GFLOPS derivation: recomputed from averaged latency."
    echo "  \`avg_sp_gflops = (5 * N * log2(N) * batch) / (avg_ms * 1e6)\`"
    echo
    echo "## Run Files"
    echo
    echo "| Run | Log | Report |"
    echo "|---|---|---|"
    tail -n +2 "$MANIFEST" | awk -F'|' '{printf("| %s | `%s` | `%s` |\n", $1, $2, $3)}'
    echo
    echo "## Scenario Catalog"
    echo
    echo "| Run Profile | Description | Workload | Timing Mode |"
    echo "|---|---|---|---|"
    awk -F'\t' '{printf("| %s | %s | %s | %s |\n", $1, $2, $3, $4)}' "$TMP_PROFILES"
    echo
    echo "## Data Quality Check"
    echo
    echo "- Expected samples per row: ${RUN_COUNT}"
    BAD_ROWS="$(awk -F'\t' '$16 != "ok" && $16 != "skip" {c++} END{print c+0}' "$TMP_ROWS")"
    echo "- Rows with missing samples: ${BAD_ROWS}"
    echo
    echo "## Averaged Results"
    echo
    echo "| Workload | Case | Length | Batch | ThreadsField | Profile | Avg Fwd ms | Avg Fwd SP GFLOPS | Avg Bwd ms | Avg Bwd SP GFLOPS | Avg Mem MB | Successful Samples | Skipped Samples | Status |"
    echo "|---|---|---:|---:|---:|---|---:|---:|---:|---:|---:|---:|---:|---|"
    awk -F'\t' '
        function fmt(v, n) { return sprintf("%." n "f", v) }
        {
            if ($8 >= 0) {
                fwd_ms = fmt($8, 6)
                fwd_gf = fmt($9, 2)
                bwd_ms = fmt($10, 6)
                bwd_gf = fmt($11, 2)
            } else {
                fwd_ms = "-"
                fwd_gf = "-"
                bwd_ms = "-"
                bwd_gf = "-"
            }
            printf("| %s | %s | %d | %d | %d | %s | %s | %s | %s | %s | %.2f | %d | %d | %s |\n",
                   $2, $3, $4, $5, $6, $7,
                   fwd_ms, fwd_gf, bwd_ms, bwd_gf, $12, $13, $14, $16)
        }
    ' "$TMP_ROWS"
} > "$OUT_MD"

echo "Combined report written: $OUT_MD"
