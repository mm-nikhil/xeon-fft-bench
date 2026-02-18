#!/usr/bin/env bash
# Collect VTune profiles for Xeon FFT benchmark runs.
#
# Default behavior:
# - Profiles fft_avx512 with 10 and 20 threads
# - Collects hotspots + threading analyses
# - Stores reports under src/vtune_results/<timestamp>/
#
# Optional overrides:
#   VTUNE_ONEAPI_ROOT=/path/to/oneapi       (default: /home/nikhil/workspace/vtune/oneapi)
#   THREADS_LIST="10 20"                    (space-separated)
#   BENCH_NRUNS=5 BENCH_WARMUP=2
#   ISA=AVX512
#   COLLECT_LIST="hotspots threading"
#   RESULTS_BASE=./vtune_results

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
VTUNE_ONEAPI_ROOT="${VTUNE_ONEAPI_ROOT:-/home/nikhil/workspace/vtune/oneapi}"
THREADS_LIST="${THREADS_LIST:-10 20}"
BENCH_NRUNS="${BENCH_NRUNS:-5}"
BENCH_WARMUP="${BENCH_WARMUP:-2}"
ISA="${ISA:-AVX512}"
COLLECT_LIST="${COLLECT_LIST:-hotspots threading}"
RESULTS_BASE="${RESULTS_BASE:-${SCRIPT_DIR}/vtune_results}"
KMP_AFFINITY="${KMP_AFFINITY:-scatter,granularity=fine}"
MKL_DYNAMIC="${MKL_DYNAMIC:-FALSE}"
STAMP="$(date +"%Y%m%d_%H%M%S")"
RESULTS_DIR="${RESULTS_BASE}/${STAMP}"

mkdir -p "${RESULTS_DIR}"

if [ -f "${VTUNE_ONEAPI_ROOT}/setvars.sh" ]; then
    # shellcheck disable=SC1091
    source "${VTUNE_ONEAPI_ROOT}/setvars.sh" >/dev/null 2>&1
elif [ -f "/opt/intel/oneapi/setvars.sh" ]; then
    # shellcheck disable=SC1091
    source /opt/intel/oneapi/setvars.sh --force >/dev/null 2>&1
fi

if ! command -v vtune >/dev/null 2>&1; then
    echo "ERROR: vtune command not found."
    echo "Install VTune and/or set VTUNE_ONEAPI_ROOT correctly."
    exit 1
fi

compile_if_needed() {
    if [ -x "${SCRIPT_DIR}/fft_avx512" ]; then
        return
    fi

    local mklroot="${MKLROOT:-}"
    if [ -z "${mklroot}" ]; then
        for cand in "${HOME}/.local" "/opt/intel/oneapi/mkl/latest" "/opt/intel/mkl"; do
            if [ -f "${cand}/include/mkl_dfti.h" ]; then
                mklroot="${cand}"
                break
            fi
        done
    fi

    if [ -z "${mklroot}" ]; then
        echo "ERROR: MKL headers/libs not found."
        echo "Try: python3 -m pip install --user mkl-devel"
        exit 1
    fi

    local include_dir="${mklroot}/include"
    local lib_dir="${mklroot}/lib/intel64"
    if [ ! -d "${lib_dir}" ]; then
        lib_dir="${mklroot}/lib"
    fi
    if [ ! -d "${lib_dir}" ]; then
        echo "ERROR: MKL lib dir missing under ${mklroot}"
        exit 1
    fi

    local rt_flag="-lmkl_rt"
    if [ ! -f "${lib_dir}/libmkl_rt.so" ] && [ -f "${lib_dir}/libmkl_rt.so.2" ]; then
        rt_flag="-l:libmkl_rt.so.2"
    fi

    echo "[BUILD] Compiling fft_avx512 (binary missing)"
    (
        cd "${SCRIPT_DIR}"
        gcc -O3 -mavx512f -mavx512dq -mavx512bw -mavx512vl -std=c99 \
            -I"${include_dir}" fft_benchmark.c \
            -Wl,-rpath,"${lib_dir}" -L"${lib_dir}" ${rt_flag} -lpthread -lm -ldl \
            -o fft_avx512
    )
}

run_profile() {
    local collect_type="$1"
    local threads="$2"
    local result_dir="${RESULTS_DIR}/${collect_type}_${threads}t"
    local collect_knobs=()

    if [ "${collect_type}" = "hotspots" ]; then
        collect_knobs=(-knob sampling-mode=sw -knob enable-characterization-insights=false)
    elif [ "${collect_type}" = "threading" ]; then
        collect_knobs=(-knob sampling-and-waits=sw)
    fi

    echo "[VTUNE] Collect=${collect_type} Threads=${threads} -> ${result_dir}"

    (
        cd "${SCRIPT_DIR}"
        BENCH_NRUNS="${BENCH_NRUNS}" \
        BENCH_WARMUP="${BENCH_WARMUP}" \
        MKL_ENABLE_INSTRUCTIONS="${ISA}" \
        OMP_NUM_THREADS="${threads}" \
        MKL_NUM_THREADS="${threads}" \
        KMP_AFFINITY="${KMP_AFFINITY}" \
        MKL_DYNAMIC="${MKL_DYNAMIC}" \
        vtune -collect "${collect_type}" \
              "${collect_knobs[@]}" \
              -result-dir "${result_dir}" \
              -- ./fft_avx512 "${threads}"
    )

    vtune -report summary -result-dir "${result_dir}" > "${result_dir}.summary.txt"
    vtune -report hotspots -result-dir "${result_dir}" -group-by function > "${result_dir}.hotspots.txt" || true

    echo "[VTUNE] Reports:"
    echo "         ${result_dir}.summary.txt"
    echo "         ${result_dir}.hotspots.txt"
}

compile_if_needed

echo "[INFO] VTune version: $(vtune --version | head -1)"
echo "[INFO] BENCH_NRUNS=${BENCH_NRUNS} BENCH_WARMUP=${BENCH_WARMUP} ISA=${ISA}"
echo "[INFO] THREADS_LIST=${THREADS_LIST}"
echo "[INFO] COLLECT_LIST=${COLLECT_LIST}"
echo "[INFO] KMP_AFFINITY=${KMP_AFFINITY} MKL_DYNAMIC=${MKL_DYNAMIC}"
echo "[INFO] RESULTS_DIR=${RESULTS_DIR}"

for t in ${THREADS_LIST}; do
    for c in ${COLLECT_LIST}; do
        run_profile "${c}" "${t}"
    done
done

echo ""
echo "[DONE] VTune collection complete."
echo "Open GUI with:"
echo "  vtune-gui ${RESULTS_DIR}"
echo "Or inspect text reports under:"
echo "  ${RESULTS_DIR}"
