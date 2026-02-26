#!/bin/bash
# Aggregate 1D FFT runs for the latest AVX-512-focused campaign.
#
# Inputs:
#   1) manifest TSV with header: run_id <tab> log_path <tab> report_path
# Optional:
#   2) output markdown path
#   3) output csv path
set -euo pipefail

if [ $# -lt 1 ] || [ $# -gt 3 ]; then
    echo "Usage: $0 <manifest_tsv> [output_report_md] [output_csv]"
    exit 1
fi

MANIFEST="$1"
if [ ! -f "$MANIFEST" ]; then
    echo "ERROR: manifest not found: $MANIFEST"
    exit 1
fi

MANIFEST_DIR="$(cd "$(dirname "$MANIFEST")" && pwd)"
OUT_MD="${2:-${MANIFEST_DIR}/latest_run_avg.report.md}"
OUT_CSV="${3:-${MANIFEST_DIR}/latest_run_avg.csv}"

PEAK_GFLOPS="${PEAK_GFLOPS:-2112.0}"  # 10 cores * 2 FMA * 16 SP * 2 FLOP * 3.3 GHz
FMA_UNITS_PER_CORE="${FMA_UNITS_PER_CORE:-2}"

mapfile -t LOGS < <(tail -n +2 "$MANIFEST" | awk -F'\t' '{print $2}')
RUN_COUNT="${#LOGS[@]}"
if [ "$RUN_COUNT" -le 0 ]; then
    echo "ERROR: manifest has no run rows: $MANIFEST"
    exit 1
fi

for idx in "${!LOGS[@]}"; do
    if [ ! -f "${LOGS[$idx]}" ]; then
        echo "ERROR: missing log from manifest: ${LOGS[$idx]}"
        exit 1
    fi
done

TMP_ROWS="$(mktemp)"
TMP_PROFILES="$(mktemp)"
trap 'rm -f "$TMP_ROWS" "$TMP_PROFILES"' EXIT

awk -F'|' -v expected_runs="$RUN_COUNT" -v peak="$PEAK_GFLOPS" -v rows_out="$TMP_ROWS" -v profiles_out="$TMP_PROFILES" '
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
    if (p == "avx512_phys") return 2
    if (p == "avx512_logical") return 3
    return 99
}

$1 == "PROFILE" {
    p = $2
    if (!(p in seen_profile)) {
        seen_profile[p] = 1
        profile_order[++n_profiles] = p
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
    skip_reason[k] = $11
    next
}

END {
    # Profile catalog.
    for (i = 1; i <= n_profiles; i++) {
        p = profile_order[i]
        printf("%d\t%s\t%s\t%s\t%s\t%d\n",
               profile_rank(p), p, p_desc[p], p_workload[p], p_isa[p], p_threads[p]) >> profiles_out
    }

    # Baseline map first (averaged over runs).
    for (k in seen_row) {
        split(k, a, SUBSEP)
        p = a[1]; w = a[2]; c = a[3]; n = a[4] + 0; b = a[5] + 0
        ok = count_ok[k] + 0
        if (p == "baseline_sse42_1t" && ok > 0) {
            tk = w SUBSEP c SUBSEP n SUBSEP b
            avg_fwd_ms = sum_fwd_ms[k] / ok
            avg_bwd_ms = sum_bwd_ms[k] / ok
            flops = fft_flops_1d(n, b)
            base_fwd_gf[tk] = (avg_fwd_ms > 0.0 ? flops / (avg_fwd_ms * 1.0e6) : 0.0)
            base_bwd_gf[tk] = (avg_bwd_ms > 0.0 ? flops / (avg_bwd_ms * 1.0e6) : 0.0)
        }
    }

    # Emit averaged rows.
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
        avg_mem_mb = (ok > 0 ? sum_mem_mb[k] / ok : (16.0 * n * b) / (1024.0 * 1024.0))

        pct_peak_fwd = (ok > 0 && peak > 0.0 ? (100.0 * avg_fwd_gf / peak) : -1.0)
        pct_peak_bwd = (ok > 0 && peak > 0.0 ? (100.0 * avg_bwd_gf / peak) : -1.0)

        fwd_speedup = "-"
        bwd_speedup = "-"
        tk = w SUBSEP c SUBSEP n SUBSEP b
        if (ok > 0 && (tk in base_fwd_gf) && base_fwd_gf[tk] > 0.0) {
            fwd_speedup = sprintf("%.4f", avg_fwd_gf / base_fwd_gf[tk])
        }
        if (ok > 0 && (tk in base_bwd_gf) && base_bwd_gf[tk] > 0.0) {
            bwd_speedup = sprintf("%.4f", avg_bwd_gf / base_bwd_gf[tk])
        }
        if (ok > 0 && p == "baseline_sse42_1t") {
            fwd_speedup = "1.0000"
            bwd_speedup = "1.0000"
        }

        quality = ((ok + sk) == expected_runs ? "ok" : "incomplete")
        note = (ok > 0 ? "-" : ("skip:" skip_reason[k]))

        printf("%d\t%d\t%s\t%s\t%d\t%d\t%d\t%s\t%s\t%.6f\t%.6f\t%.6f\t%.6f\t%.6f\t%.4f\t%.4f\t%s\t%s\t%d\t%d\t%d\t%s\t%s\n",
               workload_rank(w), profile_rank(p), w, c, n, b, t, p, p_isa[p],
               avg_fwd_ms, avg_fwd_gf, avg_bwd_ms, avg_bwd_gf, avg_mem_mb,
               pct_peak_fwd, pct_peak_bwd, fwd_speedup, bwd_speedup,
               ok, sk, expected_runs, quality, note) >> rows_out
    }
}
' "${LOGS[@]}"

sort -t$'\t' -k1,1n -k5,5n -k6,6n -k7,7n -k2,2n "$TMP_ROWS" -o "$TMP_ROWS"
sort -t$'\t' -k1,1n "$TMP_PROFILES" -o "$TMP_PROFILES"

CPU_NAME="$(lscpu | awk -F: '/Model name/ {gsub(/^[ \t]+/, "", $2); print $2; exit}')"
CPU_FAMILY="$(lscpu | awk -F: '/CPU family/ {gsub(/^[ \t]+/, "", $2); print $2; exit}')"
CPU_MODEL="$(lscpu | awk -F: '/^Model:/ {gsub(/^[ \t]+/, "", $2); print $2; exit}')"
SOCKETS="$(lscpu | awk -F: '/Socket\(s\)/ {gsub(/[ \t]/, "", $2); print $2; exit}')"
CORES_PER_SOCKET="$(lscpu | awk -F: '/Core\(s\) per socket/ {gsub(/[ \t]/, "", $2); print $2; exit}')"
LOGICAL_THREADS="$(lscpu | awk -F: '/^CPU\(s\)/ {gsub(/[ \t]/, "", $2); print $2; exit}')"
THREADS_PER_CORE="$(lscpu | awk -F: '/Thread\(s\) per core/ {gsub(/[ \t]/, "", $2); print $2; exit}')"
NUMA_NODES="$(lscpu | awk -F: '/NUMA node\(s\)/ {gsub(/[ \t]/, "", $2); print $2; exit}')"
CPU_MAX_MHZ="$(lscpu | awk -F: '/CPU max MHz/ {gsub(/^[ \t]+/, "", $2); print $2; exit}')"
BASE_GHZ_FROM_NAME="$(printf "%s" "$CPU_NAME" | sed -n 's/.*@ \([0-9.]\+\)GHz.*/\1/p')"
BASE_GHZ="${BASE_GHZ:-${BASE_GHZ_FROM_NAME:-3.3}}"
MAX_TURBO_GHZ="$(awk -v mhz="${CPU_MAX_MHZ:-4500}" 'BEGIN{printf "%.1f", mhz/1000.0}')"
PHYSICAL_CORES="$(awk -v s="${SOCKETS:-1}" -v c="${CORES_PER_SOCKET:-1}" 'BEGIN{print s*c}')"
AVX_FLAGS="$(lscpu | awk -F: '/Flags/ {print $2; exit}' | tr ' ' '\n' | awk '/^avx512/ {arr[++n]=$1} END {for(i=1;i<=n;i++){printf "%s%s", arr[i], (i<n?", ":"")}}')"
if [ -z "$AVX_FLAGS" ]; then
    AVX_FLAGS="avx512 flags not detected"
fi

PEAK_BASE="$(awk -v c="$PHYSICAL_CORES" -v f="$FMA_UNITS_PER_CORE" -v hz="$BASE_GHZ" 'BEGIN{printf "%.0f", c*f*16*2*hz}')"
PEAK_TURBO_CEIL="$(awk -v c="$PHYSICAL_CORES" -v f="$FMA_UNITS_PER_CORE" -v hz="$MAX_TURBO_GHZ" 'BEGIN{printf "%.0f", c*f*16*2*hz}')"

{
    echo "workload,case,length,batch,threads,profile,isa,avg_fwd_ms,avg_fwd_sp_gflops,avg_bwd_ms,avg_bwd_sp_gflops,avg_mem_mb,fwd_pct_of_peak,bwd_pct_of_peak,fwd_speedup_vs_sse42_1t,bwd_speedup_vs_sse42_1t,samples_ok,samples_skip,samples_expected,quality,note"
    awk -F'\t' '{
        printf "%s,%s,%d,%d,%d,%s,%s,%.6f,%.6f,%.6f,%.6f,%.6f,%.4f,%.4f,%s,%s,%d,%d,%d,%s,%s\n",
               $3,$4,$5,$6,$7,$8,$9,$10,$11,$12,$13,$14,$15,$16,$17,$18,$19,$20,$21,$22,$23
    }' "$TMP_ROWS"
} > "$OUT_CSV"

{
    echo "# 1D FFT Latest Run (5-run average)"
    echo
    echo "- Generated at: $(date)"
    echo "- Manifest: \`$MANIFEST\`"
    echo "- Runs combined: ${RUN_COUNT}"
    echo
    echo "## Server Hardware"
    echo
    echo "- CPU: ${CPU_NAME} (family ${CPU_FAMILY}, model ${CPU_MODEL})"
    echo "- Physical cores: ${PHYSICAL_CORES}, Logical threads: ${LOGICAL_THREADS} (HT: ${THREADS_PER_CORE} threads/core)"
    echo "- Base clock: ${BASE_GHZ} GHz | Max turbo (single-core max): ${MAX_TURBO_GHZ} GHz"
    echo "- AVX512 FMA units per core: ${FMA_UNITS_PER_CORE} (Port 0 and Port 5)"
    echo "- AVX512 flags: ${AVX_FLAGS}"
    echo "- NUMA nodes: ${NUMA_NODES}"
    echo
    echo "## Peak GFLOPS (SP, AVX512)"
    echo
    echo "- Formula: cores x 2 FMA/core x 16 SP floats x 2 FLOP/FMA x freq = cores x 64 x freq"
    echo "- Peak at base ${BASE_GHZ} GHz (${PHYSICAL_CORES} cores): ${PEAK_BASE} SP GFLOPS"
    echo "- Peak ceiling at ${MAX_TURBO_GHZ} GHz (not sustained all-core): ${PEAK_TURBO_CEIL} SP GFLOPS"
    echo "- Percent-of-peak columns in this report use ${PEAK_GFLOPS} SP GFLOPS denominator."
    echo
    echo "## 1D FFT Benchmark Design"
    echo
    echo "- Intel oneMKL DFTI path: \`DftiCreateDescriptor\`, \`DftiComputeForward\`, \`DftiComputeBackward\`."
    echo "- Thread control via \`mkl_set_num_threads()\` and env \`OMP_NUM_THREADS\`/\`MKL_NUM_THREADS\`."
    echo "- Runtime policy: \`KMP_AFFINITY=scatter,granularity=fine\`, \`MKL_DYNAMIC=FALSE\`."
    echo "- FLOP model: \`5 * N * log2(N) * batch\`."
    echo
    echo "## Findings So Far (Interpretation)"
    echo
    echo "- W-2155 AVX512 peak denominator for this machine is 2112 SP GFLOPS at base clock."
    echo "- Example calibration: 511.85 GFLOPS corresponds to 24.24% of 2112."
    echo "- If 1056 is used as denominator, the same point becomes 48.47%; that is a different peak model."
    echo "- Tiny-N rows can be overhead-dominated; use larger N/batch rows for business comparisons."
    echo
    echo "## Source References"
    echo
    echo "- Intel ARK W-2155 (includes AVX-512 FMA unit count): https://www.intel.com/content/www/us/en/products/sku/125042/intel-xeon-w2155-processor-13-75m-cache-3-30-ghz/specifications.html"
    echo "- uops.info SKX AVX-512 FMA behavior: https://www.uops.info/html-instr/VFMADD231PS_ZMM_ZMM_ZMM.html"
    echo
    echo "## Run Files"
    echo
    echo "| Run | Log | Report |"
    echo "|---|---|---|"
    tail -n +2 "$MANIFEST" | awk -F'\t' '{printf("| %s | `%s` | `%s` |\n", $1, $2, $3)}'
    echo
    echo "## Scenario Catalog"
    echo
    echo "| Profile | Description | Workload | ISA | Threads |"
    echo "|---|---|---|---|---:|"
    awk -F'\t' '{printf("| %s | %s | %s | %s | %d |\n", $2, $3, $4, $5, $6)}' "$TMP_PROFILES"
    echo
    echo "## Averaged Results"
    echo
    echo "| Workload | Case | N | Batch | Threads | Profile | ISA | Avg Fwd ms | Avg Fwd SP GFLOPS | Avg Bwd ms | Avg Bwd SP GFLOPS | Fwd % of Peak | Bwd % of Peak | Fwd Speedup vs SSE4.2 1T | Bwd Speedup vs SSE4.2 1T | Samples |"
    echo "|---|---|---:|---:|---:|---|---|---:|---:|---:|---:|---:|---:|---:|---:|---|"
    awk -F'\t' '
        {
            samples = sprintf("%d/%d", $19, $21)
            if ($19 > 0) {
                printf("| %s | %s | %d | %d | %d | %s | %s | %.6f | %.2f | %.6f | %.2f | %.2f%% | %.2f%% | %s | %s | %s |\n",
                       $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $15, $16, $17, $18, samples)
            } else {
                printf("| %s | %s | %d | %d | %d | %s | %s | - | - | - | - | - | - | - | - | %s |\n",
                       $3, $4, $5, $6, $7, $8, $9, samples)
            }
        }
    ' "$TMP_ROWS"
    echo
    echo "## Plotting Data"
    echo
    echo "- CSV: \`$OUT_CSV\`"
} > "$OUT_MD"

echo "Combined markdown report: $OUT_MD"
echo "Combined CSV: $OUT_CSV"
