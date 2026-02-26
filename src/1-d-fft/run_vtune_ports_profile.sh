#!/usr/bin/env bash
# Collect VTune data for 1D MKL FFT with emphasis on AVX-512/core-port behavior.
#
# This script runs a fixed heavy throughput case (length x batch) to avoid
# tiny-case noise, then:
# 1) captures achieved GFLOPS and computes % of theoretical SP peak
# 2) attempts hardware-counter VTune analysis (hpc-performance by default)
# 3) falls back gracefully when this VTune build/CPU combo does not support
#    hardware event-based analyses
#
# Defaults are tuned for Xeon W-2155 in this repository.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
VTUNE_ONEAPI_ROOT="${VTUNE_ONEAPI_ROOT:-/home/nikhil/workspace/vtune/oneapi}"
RESULTS_BASE="${RESULTS_BASE:-${SCRIPT_DIR}/vtune_results_ports}"
STAMP="$(date +"%Y%m%d_%H%M%S")"
RESULTS_DIR="${RESULTS_BASE}/${STAMP}"

THREADS_LIST="${THREADS_LIST:-10 20}"
ANALYSIS_LIST="${ANALYSIS_LIST:-hpc-performance hotspots threading}"

ISA="${ISA:-AVX512}"
LENGTH="${LENGTH:-8192}"
BATCH="${BATCH:-16}"
BENCH_NRUNS="${BENCH_NRUNS:-80}"
BENCH_WARMUP="${BENCH_WARMUP:-10}"
BENCH_MAX_MEM_MB="${BENCH_MAX_MEM_MB:-3072}"

KMP_AFFINITY="${KMP_AFFINITY:-scatter,granularity=fine}"
KMP_BLOCKTIME="${KMP_BLOCKTIME:-200}"
MKL_DYNAMIC="${MKL_DYNAMIC:-FALSE}"

# Peak model knobs (single precision):
# peak_gflops = CORES * FMA_UNITS_PER_CORE * 16 * 2 * FREQ_GHZ
CORES_OVERRIDE="${CORES_OVERRIDE:-}"
FMA_UNITS_PER_CORE="${FMA_UNITS_PER_CORE:-auto}"
FREQ_GHZ="${FREQ_GHZ:-3.3}"

BIN="${SCRIPT_DIR}/fft_benchmark"
SRC="${SCRIPT_DIR}/fft_benchmark.c"

mkdir -p "${RESULTS_DIR}"

source_vtune_env() {
    if [ -f "${VTUNE_ONEAPI_ROOT}/setvars.sh" ]; then
        # shellcheck disable=SC1091
        source "${VTUNE_ONEAPI_ROOT}/setvars.sh" >/dev/null 2>&1
    elif [ -f "/opt/intel/oneapi/setvars.sh" ]; then
        # shellcheck disable=SC1091
        source /opt/intel/oneapi/setvars.sh --force >/dev/null 2>&1
    fi
}

detect_cores() {
    if [ -n "${CORES_OVERRIDE}" ]; then
        echo "${CORES_OVERRIDE}"
        return
    fi
    lscpu | awk -F: '
        /Core\(s\) per socket/ {gsub(/[ \t]/, "", $2); c=$2}
        /Socket\(s\)/ {gsub(/[ \t]/, "", $2); s=$2}
        END {
            if (c > 0 && s > 0) print c * s;
            else print 10;
        }
    '
}

detect_cpu_family_model() {
    lscpu | awk -F: '
        /CPU family/ {gsub(/[ \t]/, "", $2); fam=$2}
        /^Model:/ {gsub(/[ \t]/, "", $2); model=$2}
        END {print fam "|" model}
    '
}

resolve_fma_units_per_core() {
    if [ "${FMA_UNITS_PER_CORE}" != "auto" ]; then
        echo "${FMA_UNITS_PER_CORE}"
        return
    fi

    # Skylake-X / Skylake-W (family 6, model 85): two 512-bit FMA units/core.
    # Keep this override explicit so %peak uses the correct denominator.
    # Override manually via FMA_UNITS_PER_CORE if needed.
    local fam_model fam model
    fam_model="$(detect_cpu_family_model)"
    fam="${fam_model%%|*}"
    model="${fam_model##*|}"
    if [ "${fam}" = "6" ] && [ "${model}" = "85" ]; then
        echo "2"
    else
        echo "2"
    fi
}

detect_mklroot() {
    local candidate
    for candidate in \
        "${MKLROOT:-}" \
        "/opt/intel/oneapi/mkl/latest" \
        "/opt/intel/mkl" \
        "${HOME}/.local"
    do
        [ -n "${candidate}" ] || continue
        if [ -f "${candidate}/include/mkl_dfti.h" ]; then
            echo "${candidate}"
            return 0
        fi
    done
    return 1
}

compile_if_needed() {
    if [ -x "${BIN}" ]; then
        return
    fi

    local mklroot
    if ! mklroot="$(detect_mklroot)"; then
        echo "ERROR: MKL not found. Set MKLROOT or install mkl-devel."
        exit 1
    fi

    local include_dir="${mklroot}/include"
    local lib_dir="${mklroot}/lib/intel64"
    [ -d "${lib_dir}" ] || lib_dir="${mklroot}/lib"
    if [ ! -d "${lib_dir}" ]; then
        echo "ERROR: MKL lib directory not found under ${mklroot}"
        exit 1
    fi

    local rt_flag="-lmkl_rt"
    if [ ! -f "${lib_dir}/libmkl_rt.so" ] && [ -f "${lib_dir}/libmkl_rt.so.2" ]; then
        rt_flag="-l:libmkl_rt.so.2"
    fi

    local cc="gcc"
    local cflags="-O3 -march=native -std=c99"
    if command -v icx >/dev/null 2>&1; then
        cc="icx"
        cflags="-O3 -xHost -std=c99"
    fi

    echo "[BUILD] ${cc} ${cflags} ${SRC}"
    (
        cd "${SCRIPT_DIR}"
        "${cc}" ${cflags} \
            -I"${include_dir}" "${SRC}" \
            -Wl,-rpath,"${lib_dir}" -L"${lib_dir}" ${rt_flag} -lpthread -lm -ldl \
            -o "${BIN}"
    )
}

run_bench_case() {
    local threads="$1"
    local out_log="$2"

    (
        cd "${SCRIPT_DIR}"
        BENCH_WORKLOAD="throughput" \
        BENCH_PROFILE="vtune_ports_${threads}t" \
        BENCH_PROFILE_DESC="vtune ports ${threads}t" \
        BENCH_LENGTHS="${LENGTH}" \
        BENCH_BATCHES="${BATCH}" \
        BENCH_NRUNS="${BENCH_NRUNS}" \
        BENCH_WARMUP="${BENCH_WARMUP}" \
        BENCH_MAX_MEM_MB="${BENCH_MAX_MEM_MB}" \
        MKL_ENABLE_INSTRUCTIONS="${ISA}" \
        OMP_NUM_THREADS="${threads}" \
        MKL_NUM_THREADS="${threads}" \
        KMP_AFFINITY="${KMP_AFFINITY}" \
        KMP_BLOCKTIME="${KMP_BLOCKTIME}" \
        MKL_DYNAMIC="${MKL_DYNAMIC}" \
        "${BIN}" "${threads}"
    ) | tee "${out_log}"
}

collect_vtune() {
    local analysis="$1"
    local threads="$2"
    local run_root="$3"
    local vtune_dir="${run_root}/${analysis}_${threads}t"
    local vtune_log="${vtune_dir}.collect.log"
    local collect_knobs=()

    mkdir -p "${run_root}"

    if [ "${analysis}" = "hotspots" ]; then
        # Keep fallback analysis working even when PMU-based collection is unavailable.
        collect_knobs=(-knob sampling-mode=sw -knob enable-characterization-insights=false)
    elif [ "${analysis}" = "threading" ]; then
        collect_knobs=(-knob sampling-and-waits=sw)
    fi

    (
        cd "${SCRIPT_DIR}"
        BENCH_WORKLOAD="throughput" \
        BENCH_PROFILE="vtune_ports_${threads}t" \
        BENCH_PROFILE_DESC="vtune ports ${threads}t" \
        BENCH_LENGTHS="${LENGTH}" \
        BENCH_BATCHES="${BATCH}" \
        BENCH_NRUNS="${BENCH_NRUNS}" \
        BENCH_WARMUP="${BENCH_WARMUP}" \
        BENCH_MAX_MEM_MB="${BENCH_MAX_MEM_MB}" \
        MKL_ENABLE_INSTRUCTIONS="${ISA}" \
        OMP_NUM_THREADS="${threads}" \
        MKL_NUM_THREADS="${threads}" \
        KMP_AFFINITY="${KMP_AFFINITY}" \
        KMP_BLOCKTIME="${KMP_BLOCKTIME}" \
        MKL_DYNAMIC="${MKL_DYNAMIC}" \
        vtune -collect "${analysis}" \
              "${collect_knobs[@]}" \
              -result-dir "${vtune_dir}" \
              -- "${BIN}" "${threads}"
    ) >"${vtune_log}" 2>&1 || {
        if rg -qi "not applicable|cannot recognize the processor|sampling driver" "${vtune_log}"; then
            echo "UNSUPPORTED|${analysis}|${threads}|${vtune_log}"
            return 2
        fi
        echo "FAILED|${analysis}|${threads}|${vtune_log}"
        return 1
    }

    vtune -report summary -result-dir "${vtune_dir}" > "${vtune_dir}.summary.txt" || true
    vtune -report top-down -result-dir "${vtune_dir}" -group-by function -limit 60 > "${vtune_dir}.topdown.txt" || true
    vtune -report hw-events -result-dir "${vtune_dir}" -group-by function -limit 60 > "${vtune_dir}.hwevents.txt" || true
    vtune -report hotspots -result-dir "${vtune_dir}" -group-by function -limit 60 > "${vtune_dir}.hotspots.txt" || true

    {
        echo "# Port/Vector Focused Metrics (${analysis}, ${threads}t)"
        echo
        rg -ni "\\b(port|ports|fma|fp_arith|retiring|core bound|memory bound|front[- ]end bound|bad speculation|vector|uops.*port)\\b" \
            "${vtune_dir}.summary.txt" "${vtune_dir}.topdown.txt" "${vtune_dir}.hwevents.txt" 2>/dev/null || true
    } > "${vtune_dir}.port_metrics.txt"

    echo "OK|${analysis}|${threads}|${vtune_dir}"
    return 0
}

source_vtune_env
if ! command -v vtune >/dev/null 2>&1; then
    echo "ERROR: vtune not found even after sourcing oneAPI setvars."
    echo "Set VTUNE_ONEAPI_ROOT or install VTune."
    exit 1
fi

compile_if_needed

CORES="$(detect_cores)"
FMA_UNITS_EFFECTIVE="$(resolve_fma_units_per_core)"
PEAK_GFLOPS="$(awk -v c="${CORES}" -v fma="${FMA_UNITS_EFFECTIVE}" -v hz="${FREQ_GHZ}" 'BEGIN {printf "%.6f", c * fma * 16.0 * 2.0 * hz}')"

RUN_SUMMARY="${RESULTS_DIR}/run_summary.tsv"
echo -e "threads\tcase\tfwd_gflops\tbwd_gflops\tpeak_gflops\tfwd_pct_of_peak\tbwd_pct_of_peak" > "${RUN_SUMMARY}"

STATUS_FILE="${RESULTS_DIR}/vtune_collection_status.tsv"
echo -e "status\tanalysis\tthreads\tpath_or_log" > "${STATUS_FILE}"

echo "[INFO] VTune: $(vtune --version | head -1)"
echo "[INFO] Results dir: ${RESULTS_DIR}"
echo "[INFO] Case: N=${LENGTH}, batch=${BATCH}, ISA=${ISA}, runs=${BENCH_NRUNS}, warmup=${BENCH_WARMUP}"
echo "[INFO] Peak model: cores=${CORES}, fma_units/core=${FMA_UNITS_EFFECTIVE}, freq=${FREQ_GHZ} GHz => ${PEAK_GFLOPS} SP GFLOPS"
if [ "${FMA_UNITS_PER_CORE}" = "auto" ]; then
    echo "[INFO] FMA units/core selection: auto (override with FMA_UNITS_PER_CORE=1 or 2)"
fi

for threads in ${THREADS_LIST}; do
    run_root="${RESULTS_DIR}/t${threads}"
    mkdir -p "${run_root}"

    app_log="${run_root}/benchmark_${threads}t.log"
    run_bench_case "${threads}" "${app_log}"

    # Throughput row should be unique for fixed length+batch throughput run.
    line="$(awk -F'|' '$1=="RESULT" && $3=="throughput" {print $0}' "${app_log}" | tail -n 1)"
    if [ -z "${line}" ]; then
        echo "WARN: could not find RESULT line in ${app_log}"
        continue
    fi

    case_id="$(printf "%s" "${line}" | awk -F'|' '{print $4}')"
    fwd="$(printf "%s" "${line}" | awk -F'|' '{print $11+0}')"
    bwd="$(printf "%s" "${line}" | awk -F'|' '{print $13+0}')"
    fwd_pct="$(awk -v g="${fwd}" -v p="${PEAK_GFLOPS}" 'BEGIN {if (p>0) printf "%.4f", 100.0*g/p; else print "0.0"}')"
    bwd_pct="$(awk -v g="${bwd}" -v p="${PEAK_GFLOPS}" 'BEGIN {if (p>0) printf "%.4f", 100.0*g/p; else print "0.0"}')"

    echo -e "${threads}\t${case_id}\t${fwd}\t${bwd}\t${PEAK_GFLOPS}\t${fwd_pct}\t${bwd_pct}" >> "${RUN_SUMMARY}"

    for analysis in ${ANALYSIS_LIST}; do
        if collect_line="$(collect_vtune "${analysis}" "${threads}" "${run_root}")"; then
            echo -e "$(printf "%s" "${collect_line}" | tr '|' '\t')" >> "${STATUS_FILE}"
        else
            rc=$?
            echo -e "$(printf "%s" "${collect_line}" | tr '|' '\t')" >> "${STATUS_FILE}"
            if [ "${rc}" -eq 1 ]; then
                echo "ERROR: VTune collection failed for analysis=${analysis}, threads=${threads}"
                exit 1
            fi
        fi
    done
done

cat > "${RESULTS_DIR}/README.txt" <<EOF
VTune Port Profiling Run
========================
Timestamp: ${STAMP}
Case: length=${LENGTH}, batch=${BATCH}, ISA=${ISA}
Threads tested: ${THREADS_LIST}
Analyses requested: ${ANALYSIS_LIST}

Files:
- run_summary.tsv                : achieved GFLOPS and % of peak model
- vtune_collection_status.tsv    : per-analysis success/unsupported/failure
- t*/benchmark_*t.log            : raw benchmark output
- t*/<analysis>_*t.summary.txt   : VTune summary report
- t*/<analysis>_*t.topdown.txt   : VTune top-down report
- t*/<analysis>_*t.hwevents.txt  : VTune hardware events report
- t*/<analysis>_*t.port_metrics.txt: grep-filtered port/vector-related lines

Notes:
- If status is UNSUPPORTED for hardware-counter analyses, this VTune build
  cannot provide port-level PMU metrics on this CPU. In that case, use an
  older VTune release that supports Skylake-X PMU event mapping, or collect
  equivalent counters with a supported PMU toolchain.
EOF

echo "[DONE] Results written to ${RESULTS_DIR}"
echo "[DONE] See:"
echo "       ${RUN_SUMMARY}"
echo "       ${STATUS_FILE}"
