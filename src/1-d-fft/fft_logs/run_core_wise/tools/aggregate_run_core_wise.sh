#!/usr/bin/env bash
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
PEAK_GFLOPS="${PEAK_GFLOPS:-2112.0}"

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
TMP_STATS="$(mktemp)"
TOP_ROWS="$(mktemp)"
TMP_SORTED_TOP="$(mktemp)"
trap 'rm -f "$TMP_ROWS" "$TMP_PROFILES" "$TMP_STATS" "$TOP_ROWS" "$TMP_SORTED_TOP"' EXIT

awk -F'|' -v expected_runs="$RUN_COUNT" -v peak="$PEAK_GFLOPS" \
    -v rows_out="$TMP_ROWS" -v profiles_out="$TMP_PROFILES" -v stats_out="$TMP_STATS" '
function workload_rank(w) {
    if (w == "throughput") return 1
    if (w == "thread_scaling") return 2
    if (w == "batch_scaling") return 3
    return 9
}

function fft_flops_1d(n, b) {
    return 5.0 * n * (log(n) / log(2.0)) * b
}

function infer_profile_fields(p, default_threads,    m) {
    inferred_core = -1
    inferred_tpc = -1
    inferred_threads = default_threads

    if (match(p, /_c([0-9]+)_t([0-9]+)/, m)) {
        inferred_core = m[1] + 0
        inferred_threads = m[2] + 0
        if (inferred_core > 0 && inferred_threads > 0 && inferred_threads % inferred_core == 0) {
            inferred_tpc = inferred_threads / inferred_core
        }
    }
}

function resolve_core(p, t,    c) {
    c = p_core[p] + 0
    if (c > 0) return c
    infer_profile_fields(p, t)
    return inferred_core > 0 ? inferred_core : -1
}

function resolve_tpc(p, t, c,    tp) {
    tp = p_tpc[p] + 0
    if (tp > 0) return tp
    infer_profile_fields(p, t)
    if (inferred_tpc > 0) return inferred_tpc
    if (c > 0 && t > 0 && t % c == 0) return t / c
    return -1
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

    c = ($13 == "" ? -1 : $13 + 0)
    tp = ($14 == "" ? -1 : $14 + 0)
    cpu_set = ($15 == "" ? "-" : $15)

    if (c <= 0 || tp <= 0) {
        infer_profile_fields(p, p_threads[p])
        if (c <= 0) c = inferred_core
        if (tp <= 0) tp = inferred_tpc
    }
    if (tp <= 0 && c > 0 && p_threads[p] > 0 && p_threads[p] % c == 0) tp = p_threads[p] / c

    p_core[p] = c
    p_tpc[p] = tp
    p_cpuset[p] = cpu_set
    next
}

$1 == "RESULT" {
    p = $2
    w = $3
    c = $4
    n = $5 + 0
    b = $8 + 0
    t = $9 + 0
    core_count = resolve_core(p, t)
    tpc = resolve_tpc(p, t, core_count)
    k = p SUBSEP w SUBSEP c SUBSEP n SUBSEP b SUBSEP t SUBSEP core_count SUBSEP tpc

    seen_row[k] = 1
    count_ok[k]++
    sum_fwd_ms[k] += $10 + 0.0
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
    core_count = resolve_core(p, t)
    tpc = resolve_tpc(p, t, core_count)
    k = p SUBSEP w SUBSEP c SUBSEP n SUBSEP b SUBSEP t SUBSEP core_count SUBSEP tpc

    seen_row[k] = 1
    count_skip[k]++
    skip_reason[k] = $11
    next
}

$1 == "CHECK" {
    p = $2
    w = $3
    c = $4
    n = $5 + 0
    b = $8 + 0
    t = $9 + 0
    core_count = resolve_core(p, t)
    tpc = resolve_tpc(p, t, core_count)
    k = p SUBSEP w SUBSEP c SUBSEP n SUBSEP b SUBSEP t SUBSEP core_count SUBSEP tpc

    check_total[k]++
    if ($13 != "PASS") check_fail[k]++
    next
}

END {
    for (i = 1; i <= n_profiles; i++) {
        p = profile_order[i]
        c = p_core[p] + 0
        tp = p_tpc[p] + 0
        thr = p_threads[p] + 0
        if (c <= 0) {
            infer_profile_fields(p, thr)
            c = inferred_core
        }
        if (tp <= 0) {
            infer_profile_fields(p, thr)
            tp = inferred_tpc
            if (tp <= 0 && c > 0 && thr > 0 && thr % c == 0) tp = thr / c
        }

        printf("%d\t%d\t%d\t%s\t%s\t%s\t%s\t%s\n",
               c, tp, thr, p, p_desc[p], p_workload[p], p_isa[p], p_cpuset[p]) >> profiles_out
    }

    for (k in seen_row) {
        split(k, a, SUBSEP)
        p = a[1]
        w = a[2]
        c_id = a[3]
        n = a[4] + 0
        b = a[5] + 0
        thr = a[6] + 0
        core_count = a[7] + 0
        tpc = a[8] + 0

        ok = count_ok[k] + 0
        if (w == "throughput" && core_count == 1 && tpc == 1 && ok > 0) {
            tk = w SUBSEP c_id SUBSEP n SUBSEP b
            avg_fwd_ms = sum_fwd_ms[k] / ok
            flops = fft_flops_1d(n, b)
            base_fwd_gf[tk] = (avg_fwd_ms > 0.0 ? flops / (avg_fwd_ms * 1.0e6) : 0.0)
        }
    }

    total_rows = 0
    bad_rows = 0
    checks_total_all = 0
    checks_failed_all = 0
    checks_missing_all = 0

    for (k in seen_row) {
        split(k, a, SUBSEP)
        p = a[1]
        w = a[2]
        c_id = a[3]
        n = a[4] + 0
        b = a[5] + 0
        thr = a[6] + 0
        core_count = a[7] + 0
        tpc = a[8] + 0

        ok = count_ok[k] + 0
        sk = count_skip[k] + 0

        avg_fwd_ms = (ok > 0 ? sum_fwd_ms[k] / ok : -1.0)
        flops = fft_flops_1d(n, b)
        avg_fwd_gf = (ok > 0 && avg_fwd_ms > 0.0 ? flops / (avg_fwd_ms * 1.0e6) : -1.0)
        avg_mem_mb = (ok > 0 ? sum_mem_mb[k] / ok : (16.0 * n * b) / (1024.0 * 1024.0))

        pct_peak_fwd = (ok > 0 && peak > 0.0 ? (100.0 * avg_fwd_gf / peak) : -1.0)

        fwd_speedup = "-"
        tk = w SUBSEP c_id SUBSEP n SUBSEP b
        if (ok > 0 && (tk in base_fwd_gf) && base_fwd_gf[tk] > 0.0) {
            fwd_speedup = sprintf("%.4f", avg_fwd_gf / base_fwd_gf[tk])
        }
        if (ok > 0 && core_count == 1 && tpc == 1) {
            fwd_speedup = "1.0000"
        }

        ctotal = check_total[k] + 0
        cfail = check_fail[k] + 0
        cok = ctotal - cfail
        if (cok < 0) cok = 0
        cmiss = (ok > ctotal ? ok - ctotal : 0)

        quality = "ok"
        if ((ok + sk) != expected_runs || cfail > 0 || cmiss > 0) quality = "incomplete"

        note = "-"
        if (ok == 0) note = "skip:" skip_reason[k]
        else if (cfail > 0) note = "validation_fail"
        else if (cmiss > 0) note = "missing_check"

        printf("%d\t%d\t%d\t%d\t%s\t%s\t%d\t%d\t%s\t%s\t%.6f\t%.6f\t%.6f\t%.4f\t%s\t%d\t%d\t%d\t%d\t%d\t%s\t%s\n",
               workload_rank(w), core_count, tpc, thr, w, c_id, n, b, p, p_isa[p],
               avg_fwd_ms, avg_fwd_gf, avg_mem_mb, pct_peak_fwd, fwd_speedup,
               ok, sk, expected_runs, cok, cfail, quality, note) >> rows_out

        total_rows++
        if (quality != "ok") bad_rows++
        checks_total_all += ctotal
        checks_failed_all += cfail
        checks_missing_all += cmiss
    }

    printf("total_rows=%d\n", total_rows) >> stats_out
    printf("bad_rows=%d\n", bad_rows) >> stats_out
    printf("checks_total=%d\n", checks_total_all) >> stats_out
    printf("checks_failed=%d\n", checks_failed_all) >> stats_out
    printf("checks_missing=%d\n", checks_missing_all) >> stats_out
}
' "${LOGS[@]}"

sort -t$'\t' -k1,1n -k7,7n -k8,8n -k2,2n -k3,3n -k4,4n "$TMP_ROWS" -o "$TMP_ROWS"
sort -t$'\t' -k1,1n -k2,2n -k3,3n "$TMP_PROFILES" -o "$TMP_PROFILES"
sort -t$'\t' -k12,12gr "$TMP_ROWS" > "$TMP_SORTED_TOP"
head -n 15 "$TMP_SORTED_TOP" > "$TOP_ROWS"

TOTAL_ROWS=0
BAD_ROWS=0
CHECKS_TOTAL=0
CHECKS_FAILED=0
CHECKS_MISSING=0
while IFS='=' read -r k v; do
    case "$k" in
        total_rows) TOTAL_ROWS="$v" ;;
        bad_rows) BAD_ROWS="$v" ;;
        checks_total) CHECKS_TOTAL="$v" ;;
        checks_failed) CHECKS_FAILED="$v" ;;
        checks_missing) CHECKS_MISSING="$v" ;;
    esac
done < "$TMP_STATS"

CPU_NAME="$(lscpu | awk -F: '/Model name/ {gsub(/^[ \t]+/, "", $2); print $2; exit}')"
CPU_FAMILY="$(lscpu | awk -F: '/CPU family/ {gsub(/^[ \t]+/, "", $2); print $2; exit}')"
CPU_MODEL="$(lscpu | awk -F: '/^Model:/ {gsub(/^[ \t]+/, "", $2); print $2; exit}')"
SOCKETS="$(lscpu | awk -F: '/Socket\(s\)/ {gsub(/[ \t]/, "", $2); print $2; exit}')"
CORES_PER_SOCKET="$(lscpu | awk -F: '/Core\(s\) per socket/ {gsub(/[ \t]/, "", $2); print $2; exit}')"
LOGICAL_THREADS="$(lscpu | awk -F: '/^CPU\(s\)/ {gsub(/[ \t]/, "", $2); print $2; exit}')"
THREADS_PER_CORE="$(lscpu | awk -F: '/Thread\(s\) per core/ {gsub(/[ \t]/, "", $2); print $2; exit}')"
NUMA_NODES="$(lscpu | awk -F: '/NUMA node\(s\)/ {gsub(/[ \t]/, "", $2); print $2; exit}')"
BASE_GHZ_FROM_NAME="$(printf "%s" "$CPU_NAME" | sed -n 's/.*@ \([0-9.]\+\)GHz.*/\1/p')"
BASE_GHZ="${BASE_GHZ:-${BASE_GHZ_FROM_NAME:-3.3}}"
CPU_MAX_MHZ="$(lscpu | awk -F: '/CPU max MHz/ {gsub(/^[ \t]+/, "", $2); print $2; exit}')"
MAX_TURBO_GHZ="$(awk -v mhz="${CPU_MAX_MHZ:-4500}" 'BEGIN{printf "%.1f", mhz/1000.0}')"
PHYSICAL_CORES="$(awk -v s="${SOCKETS:-1}" -v c="${CORES_PER_SOCKET:-1}" 'BEGIN{print s*c}')"

{
    echo "workload,case,length,batch,core_count,threads_per_core,threads,profile,isa,avg_fwd_ms,avg_fwd_sp_gflops,avg_mem_mb,fwd_pct_of_peak,fwd_speedup_vs_c01_t01,samples_ok,samples_skip,samples_expected,check_ok,check_fail,quality,note"
    awk -F'\t' '{
        printf "%s,%s,%d,%d,%d,%d,%d,%s,%s,%.6f,%.6f,%.6f,%.4f,%s,%d,%d,%d,%d,%d,%s,%s\n",
               $5,$6,$7,$8,$2,$3,$4,$9,$10,$11,$12,$13,$14,$15,$16,$17,$18,$19,$20,$21,$22
    }' "$TMP_ROWS"
} > "$OUT_CSV"

{
    echo "# 1D FFT run_core_wise (${RUN_COUNT}-run average, forward-focused, extra-cold streaming)"
    echo
    echo "- Generated at: $(date)"
    echo "- Manifest: \`$MANIFEST\`"
    echo "- Runs combined: ${RUN_COUNT}"
    echo "- Forward-only reporting: yes"
    echo "- Matrix scope: batch fixed to 1, N=2..4194304 (doubling), cores=1..10, threads={cores, 2xcores}"
    echo
    echo "## Server Hardware"
    echo
    echo "- CPU: ${CPU_NAME} (family ${CPU_FAMILY}, model ${CPU_MODEL})"
    echo "- Physical cores: ${PHYSICAL_CORES}, Logical threads: ${LOGICAL_THREADS} (HT: ${THREADS_PER_CORE} threads/core)"
    echo "- Base clock: ${BASE_GHZ} GHz | Max turbo: ${MAX_TURBO_GHZ} GHz"
    echo "- NUMA nodes: ${NUMA_NODES}"
    echo
    echo "## Peak Model"
    echo
    echo "- SP peak formula: cores x 2 FMA/core x 16 lanes x 2 FLOP/FMA x freq"
    echo "- Report denominator for %peak: ${PEAK_GFLOPS} SP GFLOPS"
    echo
    echo "## Correctness Summary"
    echo
    echo "- CHECK lines counted: ${CHECKS_TOTAL}"
    echo "- CHECK failures: ${CHECKS_FAILED}"
    echo "- Missing CHECK samples: ${CHECKS_MISSING}"
    echo "- Strict validation required at runtime: yes"
    echo
    echo "## Data Quality"
    echo
    echo "- Averaged rows: ${TOTAL_ROWS}"
    echo "- Rows with incomplete quality: ${BAD_ROWS}"
    echo "- Expected samples per row: ${RUN_COUNT}"
    echo
    echo "## Run Files"
    echo
    echo "| Run | Log | Report |"
    echo "|---|---|---|"
    tail -n +2 "$MANIFEST" | awk -F'\t' '{printf("| %s | `%s` | `%s` |\n", $1, $2, $3)}'
    echo
    echo "## Scenario Catalog"
    echo
    echo "| Profile | Description | Workload | ISA | Cores | Threads/Core | Threads | CPU Set |"
    echo "|---|---|---|---|---:|---:|---:|---|"
    awk -F'\t' '{printf("| %s | %s | %s | %s | %d | %d | %d | `%s` |\n", $4, $5, $6, $7, $1, $2, $3, $8)}' "$TMP_PROFILES"
    echo
    echo "## Top 15 Forward Cases"
    echo
    echo "| Workload | Case | N | Batch | Cores | Threads/Core | Threads | Profile | Avg Fwd ms | Avg Fwd SP GFLOPS | Fwd % Peak | Speedup vs c01/t01 | Samples |"
    echo "|---|---|---:|---:|---:|---:|---:|---|---:|---:|---:|---:|---|"
    awk -F'\t' '{
        samples = sprintf("%d/%d", $16, $18)
        printf("| %s | %s | %d | %d | %d | %d | %d | %s | %.6f | %.2f | %.2f%% | %s | %s |\n",
               $5,$6,$7,$8,$2,$3,$4,$9,$11,$12,$14,$15,samples)
    }' "$TOP_ROWS"
    echo
    echo "## Averaged Results (Forward)"
    echo
    echo "| Workload | Case | N | Batch | Cores | Threads/Core | Threads | Profile | ISA | Avg Fwd ms | Avg Fwd SP GFLOPS | Avg Mem MB | Fwd % Peak | Speedup vs c01/t01 | Samples | Check (ok/fail) | Quality |"
    echo "|---|---|---:|---:|---:|---:|---:|---|---|---:|---:|---:|---:|---:|---|---|---|"
    awk -F'\t' '{
        samples = sprintf("%d/%d", $16, $18)
        ck = sprintf("%d/%d", $19, $20)
        if ($16 > 0) {
            printf("| %s | %s | %d | %d | %d | %d | %d | %s | %s | %.6f | %.2f | %.4f | %.2f%% | %s | %s | %s | %s |\n",
                   $5,$6,$7,$8,$2,$3,$4,$9,$10,$11,$12,$13,$14,$15,samples,ck,$21)
        } else {
            printf("| %s | %s | %d | %d | %d | %d | %d | %s | %s | - | - | %.4f | - | - | %s | %s | %s |\n",
                   $5,$6,$7,$8,$2,$3,$4,$9,$10,$13,samples,ck,$21)
        }
    }' "$TMP_ROWS"
    echo
    echo "## Plotting Data"
    echo
    echo "- CSV: \`$OUT_CSV\`"
} > "$OUT_MD"

echo "Combined markdown report: $OUT_MD"
echo "Combined CSV: $OUT_CSV"
