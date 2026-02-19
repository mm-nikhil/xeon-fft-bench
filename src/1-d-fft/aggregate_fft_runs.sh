#!/bin/bash
# Aggregate multiple 1D FFT benchmark logs listed in a manifest into one
# averaged markdown report with speedup/% increase comparisons.
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
OUT_MD="${2:-${MANIFEST_DIR}/fft_benchmark_1d_5run_avg_${TIMESTAMP}.report.md}"

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
    if (w == "thread_scaling") return 2
    if (w == "batch_scaling") return 3
    return 9
}

function fft_flops_1d(n, b) {
    return 5.0 * n * (log(n) / log(2.0)) * b
}

function profile_rank(p) {
    if (p == "baseline_sse42_1t") return 1
    if (p == "avx2_1t") return 2
    if (p == "avx512_1t") return 3
    if (p == "avx2_phys") return 4
    if (p == "avx512_phys") return 5
    if (p == "avx512_logical") return 6
    if (p == "avx512_thread_scaling") return 7
    if (p == "avx512_batch_scaling") return 8
    return 99
}

function profile_note(wk, t) {
    if (wk == "throughput" && t == 1) return "Single-thread ISA comparison"
    if (wk == "throughput" && t > 1) return "Multithread throughput at fixed thread count"
    if (wk == "thread_scaling") return "Thread sweep on fixed length and batch"
    if (wk == "batch_scaling") return "Batch sweep on fixed length and threads"
    return "-"
}

$1 == "PROFILE" {
    p = $2
    if (!(p in seen_profile)) {
        profile_order[++n_profiles] = p
        seen_profile[p] = 1
    }
    p_desc[p] = $3
    p_isa[p] = $4
    p_threads[p] = $5 + 0
    p_workload[p] = $6
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

    seen_row[k] = 1
    count_ok[k]++
    sum_fwd_ms[k] += $10 + 0.0
    sum_bwd_ms[k] += $12 + 0.0
    sum_mem_mb[k] += $14 + 0.0
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

    seen_row[k] = 1
    count_skip[k]++
    sum_skip_mem_mb[k] += $10 + 0.0
    skip_reason[k] = $11
    next
}

END {
    # Profile catalog output.
    for (i = 1; i <= n_profiles; i++) {
        p = profile_order[i]
        printf("%d\t%s\t%s\t%s\t%d\t%s\n",
               profile_rank(p), p, p_desc[p], p_workload[p], p_threads[p], p_isa[p]) >> profiles_out
    }

    # First pass: compute baseline averages for throughput rows.
    for (k in seen_row) {
        split(k, a, SUBSEP)
        p = a[1]; w = a[2]; c = a[3]; n = a[4] + 0; b = a[5] + 0
        ok = count_ok[k] + 0
        if (w == "throughput" && p == "baseline_sse42_1t" && ok > 0) {
            tk = w SUBSEP c SUBSEP n SUBSEP b
            avg_base_fwd_ms = sum_fwd_ms[k] / ok
            avg_base_bwd_ms = sum_bwd_ms[k] / ok
            flops = fft_flops_1d(n, b)
            base_fwd_gf[tk] = (avg_base_fwd_ms > 0.0 ? flops / (avg_base_fwd_ms * 1.0e6) : 0.0)
            base_bwd_gf[tk] = (avg_base_bwd_ms > 0.0 ? flops / (avg_base_bwd_ms * 1.0e6) : 0.0)
        }
    }

    # Second pass: emit averaged rows with comparisons.
    for (k in seen_row) {
        split(k, a, SUBSEP)
        p = a[1]; w = a[2]; c = a[3]
        n = a[4] + 0; b = a[5] + 0; t = a[6] + 0
        ok = count_ok[k] + 0
        sk = count_skip[k] + 0

        avg_fwd_ms = (ok > 0 ? sum_fwd_ms[k] / ok : -1.0)
        avg_bwd_ms = (ok > 0 ? sum_bwd_ms[k] / ok : -1.0)
        flops = fft_flops_1d(n, b)
        avg_fwd_gf = (ok > 0 && avg_fwd_ms > 0.0 ? flops / (avg_fwd_ms * 1.0e6) : -1.0)
        avg_bwd_gf = (ok > 0 && avg_bwd_ms > 0.0 ? flops / (avg_bwd_ms * 1.0e6) : -1.0)
        # Exact memory footprint for 1D single-precision complex FFT:
        # in + out buffers = 2 * (n * batch * sizeof(MKL_Complex8))
        # sizeof(MKL_Complex8)=8 bytes => total bytes = 16*n*batch.
        avg_mem_kib = (16.0 * n * b) / 1024.0

        fwd_sp = "-"
        fwd_inc = "-"
        bwd_sp = "-"
        bwd_inc = "-"
        tk = w SUBSEP c SUBSEP n SUBSEP b
        if (w == "throughput" && ok > 0 && (tk in base_fwd_gf) && base_fwd_gf[tk] > 0.0) {
            sp = avg_fwd_gf / base_fwd_gf[tk]
            fwd_sp = sprintf("%.4f", sp)
            fwd_inc = sprintf("%.2f%%", (sp - 1.0) * 100.0)
        }
        if (w == "throughput" && ok > 0 && (tk in base_bwd_gf) && base_bwd_gf[tk] > 0.0) {
            sp2 = avg_bwd_gf / base_bwd_gf[tk]
            bwd_sp = sprintf("%.4f", sp2)
            bwd_inc = sprintf("%.2f%%", (sp2 - 1.0) * 100.0)
        }
        if (w == "throughput" && p == "baseline_sse42_1t" && ok > 0) {
            fwd_sp = "1.0000"
            fwd_inc = "0.00%"
            bwd_sp = "1.0000"
            bwd_inc = "0.00%"
        }

        quality = ((ok + sk) == expected_runs ? "ok" : "incomplete")
        note = (ok > 0 ? "-" : ("skip:" skip_reason[k]))

        printf("%d\t%d\t%s\t%s\t%d\t%d\t%d\t%s\t%s\t%.6f\t%.6f\t%.6f\t%.6f\t%.6f\t%d\t%d\t%d\t%s\t%s\t%s\t%s\t%s\t%s\n",
               workload_rank(w), profile_rank(p), w, c, n, b, t, p, p_isa[p],
               avg_fwd_ms, avg_fwd_gf, avg_bwd_ms, avg_bwd_gf, avg_mem_kib,
               ok, sk, expected_runs, quality, fwd_sp, fwd_inc, bwd_sp, bwd_inc, note) >> rows_out
    }
}
' "${LOGS[@]}"

sort -t$'\t' -k1,1n -k5,5n -k6,6n -k7,7n -k2,2n "$TMP_ROWS" -o "$TMP_ROWS"
sort -t$'\t' -k1,1n "$TMP_PROFILES" -o "$TMP_PROFILES"

{
    echo "# 1D FFT Combined Report (Averaged Across Runs)"
    echo
    echo "- Generated at: $(date)"
    echo "- Manifest: \`$MANIFEST\`"
    echo "- Runs combined: ${RUN_COUNT}"
    echo "- Precision mode: single precision (MKL \`DFTI_SINGLE\`, \`MKL_Complex8\`)"
    echo
    echo "## Aggregation Method"
    echo
    echo "- Input source: raw \`RESULT|\` and \`SKIP|\` lines from each log."
    echo "- Average latency (\`ms\`): arithmetic mean over successful samples."
    echo "- GFLOPS derivation: recomputed from averaged latency for each row."
    echo "  \`avg_sp_gflops = (5 * N * log2(N) * batch) / (avg_ms * 1e6)\`"
    echo "- For each row key: \`profile + workload + case + length + batch + threads\`."
    echo "- Throughput comparison:"
    echo "  \`Fwd Speedup = avg_fwd_sp_gflops(profile) / avg_fwd_sp_gflops(baseline_sse42_1t)\`"
    echo "  \`Fwd % Increase = (Fwd Speedup - 1) * 100\`"
    echo "  \`Bwd Speedup = avg_bwd_sp_gflops(profile) / avg_bwd_sp_gflops(baseline_sse42_1t)\`"
    echo "  \`Bwd % Increase = (Bwd Speedup - 1) * 100\`"
    echo "- GFLOPS columns are single-precision throughput (\`SP GFLOPS\`)."
    echo "- Small-size multithread caveat: rows with very small work items (for example, low \`N\` and low batch) are overhead-dominated and should not be used for thread-scaling conclusions."
    echo
    echo "## Run Files"
    echo
    echo "| Run | Log | Report |"
    echo "|---|---|---|"
    tail -n +2 "$MANIFEST" | awk -F'|' '{printf("| %s | `%s` | `%s` |\n", $1, $2, $3)}'
    echo
    echo "## Scenario Catalog"
    echo
    echo "| Run Profile | Description | Workload | ISA Cap | Threads |"
    echo "|---|---|---|---|---|"
    awk -F'\t' '{printf("| %s | %s | %s | %s | %d |\n", $2, $3, $4, $6, $5)}' "$TMP_PROFILES"
    echo
    echo "## Data Quality Check"
    echo
    echo "- Expected samples per row: ${RUN_COUNT}"
    BAD_ROWS="$(awk -F'\t' '$18 != "ok" {c++} END{print c+0}' "$TMP_ROWS")"
    echo "- Rows with missing samples: ${BAD_ROWS}"
    echo
    echo "## Averaged Results"
    echo
    echo "| Workload | Case | Length | Batch | Threads | Profile | ISA | Avg Fwd ms | Avg Fwd SP GFLOPS | Avg Bwd ms | Avg Bwd SP GFLOPS | Avg Mem KiB | Fwd Speedup vs baseline | Fwd % Increase | Bwd Speedup vs baseline | Bwd % Increase |"
    echo "|---|---|---:|---:|---:|---|---|---:|---:|---:|---:|---:|---:|---:|---:|---:|"
    awk -F'\t' '
        function fmt(v, n) { return sprintf("%." n "f", v) }
        {
            if ($15 > 0) {
                fwd_ms = fmt($10, 6)
                fwd_gf = fmt($11, 2)
                bwd_ms = fmt($12, 6)
                bwd_gf = fmt($13, 2)
                memkib = fmt($14, 4)
            } else {
                fwd_ms = "-"
                fwd_gf = "-"
                bwd_ms = "-"
                bwd_gf = "-"
                memkib = fmt($14, 4)
            }
            printf("| %s | %s | %d | %d | %d | %s | %s | %s | %s | %s | %s | %s | %s | %s | %s | %s |\n",
                   $3, $4, $5, $6, $7, $8, $9,
                   fwd_ms, fwd_gf, bwd_ms, bwd_gf, memkib,
                   $19, $20, $21, $22)
        }
    ' "$TMP_ROWS"
} > "$OUT_MD"

echo "Combined report written: $OUT_MD"
