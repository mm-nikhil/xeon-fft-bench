# Xeon FFT Benchmark (Intel MKL DFTI)

This project benchmarks 3D complex-to-complex FFT on Intel Xeon using Intel MKL.

Scenarios run by `src/run_fft_benchmarks.sh`:
1. Baseline ISA, single thread (`BASELINE_ISA`, default `SSE4_2`)
2. AVX-512 ISA, single thread (`AVX_ISA`, default `AVX512`)
3. AVX-512 + physical cores (`NTHREADS_PHYSICAL`, default `10`)
4. AVX-512 + logical cores (`NTHREADS_LOGICAL`, default `20`)

Each benchmark binary internally runs:
- Grid sweep (`64^3`, `128^3`, `256^3`)
- Thread scaling sweep (`1, 2, 4, 8, 10, 20`)
- Batch scaling sweep (`1, 2, 4, 8, 16, 32`)

## Prerequisite: MKL

The script auto-detects MKL in:
- `$MKLROOT`
- `/opt/intel/oneapi/mkl/latest`
- `/opt/intel/mkl`
- `~/.local` (user-space pip install)

User-space install (no root required):

```bash
python3 -m pip install --user mkl-devel
```

## Run

```bash
cd xeon-fft-bench/src
chmod +x run_fft_benchmarks.sh
./run_fft_benchmarks.sh
```

## Useful overrides

```bash
# quick sanity run
BENCH_NRUNS=5 BENCH_WARMUP=2 ./run_fft_benchmarks.sh

# pin MKL location explicitly
MKLROOT=$HOME/.local ./run_fft_benchmarks.sh

# change ISA/thread settings
BASELINE_ISA=SSE4_2 AVX_ISA=AVX512 NTHREADS_PHYSICAL=10 NTHREADS_LOGICAL=20 ./run_fft_benchmarks.sh
```

## Output

- Full log: `src/fft_logs/fft_benchmark_<timestamp>.log`
- The script prints a summary table for `128^3 batch=4` forward GFLOPS and speedups.

## Note on ISA control

MKL chooses kernels at runtime. Compile flags alone do not force MKL ISA.  
`run_fft_benchmarks.sh` uses `MKL_ENABLE_INSTRUCTIONS` per scenario for controlled comparisons.
