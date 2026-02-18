#!/bin/bash
# =============================================================
# run_fft_benchmarks.sh
# End-to-end MKL FFT benchmark driver with robust MKL discovery.
#
# Optional overrides:
#   MKLROOT=/path/to/mkl
#   NTHREADS_PHYSICAL=10 NTHREADS_LOGICAL=20
#   BASELINE_ISA=SSE4_2 AVX_ISA=AVX512
#   BENCH_NRUNS=20 BENCH_WARMUP=5
# =============================================================

set -euo pipefail

TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
LOGDIR="./fft_logs"
mkdir -p "$LOGDIR"
LOGFILE="${LOGDIR}/fft_benchmark_${TIMESTAMP}.log"
exec > >(tee -a "$LOGFILE") 2>&1

NTHREADS_PHYSICAL="${NTHREADS_PHYSICAL:-10}"
NTHREADS_LOGICAL="${NTHREADS_LOGICAL:-20}"
BASELINE_ISA="${BASELINE_ISA:-SSE4_2}"
AVX_ISA="${AVX_ISA:-AVX512}"
BENCH_NRUNS="${BENCH_NRUNS:-20}"
BENCH_WARMUP="${BENCH_WARMUP:-5}"

echo "============================================================"
echo "  FFT BENCHMARK RUN"
echo "  Date     : $(date)"
echo "  Hostname : $(hostname)"
echo "  Log file : $LOGFILE"
echo "============================================================"
echo ""

echo "[SETUP] Sourcing Intel oneAPI environment if available..."
if [ -f /opt/intel/oneapi/setvars.sh ]; then
    # shellcheck disable=SC1091
    source /opt/intel/oneapi/setvars.sh --force > /dev/null 2>&1
    echo "        Sourced: /opt/intel/oneapi/setvars.sh"
elif [ -f /opt/intel/mkl/bin/mklvars.sh ]; then
    # shellcheck disable=SC1091
    source /opt/intel/mkl/bin/mklvars.sh intel64 > /dev/null 2>&1
    echo "        Sourced: /opt/intel/mkl/bin/mklvars.sh"
elif command -v module >/dev/null 2>&1; then
    module load intel/oneapi 2>/dev/null || module load mkl 2>/dev/null || true
fi
echo ""

detect_mklroot() {
    local candidate
    for candidate in \
        "${MKLROOT:-}" \
        "/opt/intel/oneapi/mkl/latest" \
        "/opt/intel/mkl" \
        "${HOME}/.local"
    do
        [ -n "$candidate" ] || continue
        if [ -f "${candidate}/include/mkl_dfti.h" ]; then
            echo "$candidate"
            return 0
        fi
    done
    return 1
}

if ! MKLROOT="$(detect_mklroot)"; then
    echo "ERROR: Intel MKL not found."
    echo "       Tried MKLROOT, /opt/intel/oneapi/mkl/latest, /opt/intel/mkl, ~/.local."
    echo "       For user-space install on this host:"
    echo "         python3 -m pip install --user mkl-devel"
    echo ""
    exit 1
fi

MKL_INCLUDE_DIR="${MKLROOT}/include"
if [ -d "${MKLROOT}/lib/intel64" ]; then
    MKL_LIB_DIR="${MKLROOT}/lib/intel64"
elif [ -d "${MKLROOT}/lib" ]; then
    MKL_LIB_DIR="${MKLROOT}/lib"
else
    echo "ERROR: Could not find MKL library directory under ${MKLROOT}"
    exit 1
fi

if [ -f "${MKL_LIB_DIR}/libmkl_rt.so" ]; then
    MKL_RT_FLAG="-lmkl_rt"
elif [ -f "${MKL_LIB_DIR}/libmkl_rt.so.2" ]; then
    MKL_RT_FLAG="-l:libmkl_rt.so.2"
else
    echo "ERROR: libmkl_rt not found in ${MKL_LIB_DIR}"
    exit 1
fi

MKL_LIBS="-L${MKL_LIB_DIR} ${MKL_RT_FLAG} -lpthread -lm -ldl"
RPATH_FLAG="-Wl,-rpath,${MKL_LIB_DIR}"
INCLUDE="-I${MKL_INCLUDE_DIR}"
export LD_LIBRARY_PATH="${MKL_LIB_DIR}:${LD_LIBRARY_PATH:-}"

echo "[CHECK] MKL environment:"
echo "        MKLROOT     = ${MKLROOT}"
echo "        Include dir = ${MKL_INCLUDE_DIR}"
echo "        Lib dir     = ${MKL_LIB_DIR}"
echo "        Runtime lib = ${MKL_RT_FLAG}"
echo ""

echo "[CHECK] Compiler availability:"
USE_ICX=0
if command -v icx >/dev/null 2>&1; then
    CC_BASE="icx"
    CC_AVX="icx"
    USE_ICX=1
    echo "        icx found: $(icx --version 2>&1 | head -1)"
elif command -v icc >/dev/null 2>&1; then
    CC_BASE="icc"
    CC_AVX="icc"
    USE_ICX=1
    echo "        icc found: $(icc --version 2>&1 | head -1)"
elif command -v gcc >/dev/null 2>&1; then
    CC_BASE="gcc"
    CC_AVX="gcc"
    echo "        gcc found: $(gcc --version | head -1)"
else
    echo "ERROR: No supported C compiler found (icx, icc, gcc)."
    exit 1
fi
echo ""

if [ "${USE_ICX}" -eq 1 ]; then
    FLAGS_BASE="-O2 -std=c99"
    FLAGS_AVX="-O3 -xCORE-AVX512 -std=c99"
else
    FLAGS_BASE="-O2 -std=c99"
    FLAGS_AVX="-O3 -mavx512f -mavx512dq -mavx512bw -mavx512vl -std=c99"
fi

SRC="fft_benchmark.c"
COMMON_ENVS=(
    "KMP_AFFINITY=scatter,granularity=fine"
    "KMP_BLOCKTIME=0"
    "MKL_DYNAMIC=FALSE"
)

for env_kv in "${COMMON_ENVS[@]}"; do
    export "${env_kv}"
done
export BENCH_NRUNS BENCH_WARMUP
export MKL_VERBOSE=0

echo "[INFO] BENCH_NRUNS=${BENCH_NRUNS}, BENCH_WARMUP=${BENCH_WARMUP}"
echo "[INFO] KMP_AFFINITY=${KMP_AFFINITY}"
echo "[INFO] NOTE: MKL chooses kernels at runtime; ISA is controlled with MKL_ENABLE_INSTRUCTIONS."
echo ""

echo "------------------------------------------------------------"
echo "[COMPILE] Scenario 1 binary: ${CC_BASE} ${FLAGS_BASE}"
echo "------------------------------------------------------------"
${CC_BASE} ${FLAGS_BASE} ${INCLUDE} "${SRC}" ${RPATH_FLAG} ${MKL_LIBS} -o fft_cpu_only
echo "          Binary: fft_cpu_only"
echo ""

echo "------------------------------------------------------------"
echo "[COMPILE] Scenario 2/3 binary: ${CC_AVX} ${FLAGS_AVX}"
echo "------------------------------------------------------------"
${CC_AVX} ${FLAGS_AVX} ${INCLUDE} "${SRC}" ${RPATH_FLAG} ${MKL_LIBS} -o fft_avx512
echo "          Binary: fft_avx512"
echo ""

run_case() {
    local tag="$1"
    local desc="$2"
    local bin="$3"
    local threads="$4"
    local isa="$5"

    echo "============================================================"
    echo " RUNNING: ${tag} — ${desc}"
    echo " Binary : ${bin}"
    echo " Threads: ${threads}"
    echo " ISA    : ${isa}"
    echo "============================================================"
    echo ""

    export OMP_NUM_THREADS="${threads}"
    export MKL_NUM_THREADS="${threads}"
    export MKL_ENABLE_INSTRUCTIONS="${isa}"
    time "./${bin}" "${threads}"

    echo ""
    echo "[DONE] ${tag} complete"
    echo ""
}

run_case "Scenario 1" "CPU baseline (single thread)" "fft_cpu_only" "1" "${BASELINE_ISA}"
run_case "Scenario 2" "AVX-512 (single thread)" "fft_avx512" "1" "${AVX_ISA}"
run_case "Scenario 3" "AVX-512 + physical cores" "fft_avx512" "${NTHREADS_PHYSICAL}" "${AVX_ISA}"
run_case "Scenario 3b" "AVX-512 + logical cores (hyperthreading)" "fft_avx512" "${NTHREADS_LOGICAL}" "${AVX_ISA}"

echo "============================================================"
echo " EXTRA: MKL_VERBOSE=1 quick check"
echo "============================================================"
echo ""

export MKL_VERBOSE=1
export OMP_NUM_THREADS=1
export MKL_NUM_THREADS=1
export MKL_ENABLE_INSTRUCTIONS="${AVX_ISA}"

cat > /tmp/fft_quick.c << 'EOF'
#include <mkl_dfti.h>
#include <mkl.h>
int main(void) {
    MKL_LONG n[3] = {64, 64, 64};
    DFTI_DESCRIPTOR_HANDLE h;
    MKL_Complex16 *buf = mkl_malloc(64 * 64 * 64 * sizeof(MKL_Complex16), 64);
    if (!buf) return 2;
    DftiCreateDescriptor(&h, DFTI_DOUBLE, DFTI_COMPLEX, 3, n);
    DftiSetValue(h, DFTI_PLACEMENT, DFTI_INPLACE);
    DftiCommitDescriptor(h);
    DftiComputeForward(h, buf);
    DftiFreeDescriptor(&h);
    mkl_free(buf);
    return 0;
}
EOF

${CC_AVX} ${FLAGS_AVX} ${INCLUDE} /tmp/fft_quick.c ${RPATH_FLAG} ${MKL_LIBS} -o /tmp/fft_quick
/tmp/fft_quick 2>&1 | grep -m 5 "MKL_VERBOSE" || true
rm -f /tmp/fft_quick /tmp/fft_quick.c
export MKL_VERBOSE=0
echo ""

extract_fwd_gflops() {
    local block="$1"
    local thr="$2"
    awk -v block="$block" -v thr="$thr" '
        $0 ~ ("RUNNING: " block) {inside=1; next}
        inside && $0 ~ ("\\[DONE\\] " block) {inside=0}
        inside && /128\^3 batch=4/ && $0 ~ ("Thr:[[:space:]]*" thr "[[:space:]]*\\|") {
            if (match($0, /Fwd:[[:space:]]*[0-9.]+ ms[[:space:]]*([0-9.]+) GFLOPS/, m)) {
                print m[1];
                exit;
            }
        }
    ' "$LOGFILE"
}

CPU_GF=$(extract_fwd_gflops "Scenario 1" "1")
AVX1_GF=$(extract_fwd_gflops "Scenario 2" "1")
AVX_PHYS_GF=$(extract_fwd_gflops "Scenario 3" "${NTHREADS_PHYSICAL}")
AVX_LOGICAL_GF=$(extract_fwd_gflops "Scenario 3b" "${NTHREADS_LOGICAL}")

speedup() {
    local base="$1"
    local now="$2"
    awk -v b="$base" -v n="$now" 'BEGIN { if (b + 0 > 0 && n + 0 > 0) printf "%.2fx", n / b; else printf "n/a"; }'
}

echo "============================================================"
echo "  SUMMARY (128^3 batch=4, Forward GFLOPS)"
echo "============================================================"
echo "  Scenario 1   : ${CPU_GF:-n/a} GFLOPS"
echo "  Scenario 2   : ${AVX1_GF:-n/a} GFLOPS  (speedup vs S1: $(speedup "${CPU_GF:-0}" "${AVX1_GF:-0}"))"
echo "  Scenario 3   : ${AVX_PHYS_GF:-n/a} GFLOPS (speedup vs S1: $(speedup "${CPU_GF:-0}" "${AVX_PHYS_GF:-0}"))"
echo "  Scenario 3b  : ${AVX_LOGICAL_GF:-n/a} GFLOPS (speedup vs S1: $(speedup "${CPU_GF:-0}" "${AVX_LOGICAL_GF:-0}"))"
echo "============================================================"
echo ""

echo "============================================================"
echo "  ALL RUNS COMPLETE"
echo "  Log saved to: ${LOGFILE}"
echo "  $(wc -l < "${LOGFILE}") lines logged"
echo "  Run completed at: $(date)"
echo "============================================================"
echo ""
echo "To inspect full output:"
echo "  cat ${LOGFILE}"
echo ""
echo "To extract scenario markers + GFLOPS:"
echo "  grep -E 'RUNNING:|SCENARIO|GFLOPS|SUMMARY' ${LOGFILE}"
