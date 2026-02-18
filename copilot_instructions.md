CONTEXT: FFT Benchmarking Project on Intel Xeon W-2155 Server
=============================================================

## What We Are Doing

We are building and running an FFT (Fast Fourier Transform) benchmark 
on an Intel Xeon W-2155 server to compare performance across three 
scenarios:
  1. CPU only       — scalar baseline, no explicit vectorization
  2. CPU + AVX-512  — Intel Advanced Vector Extensions 512, single thread
  3. CPU + AVX-512 + multithreading — all 10 physical cores (20 logical)

The benchmark uses randomly initialized complex double-precision data 
(no real signal needed — FFT performance depends only on problem size, 
not data values). We measure forward and inverse 3D complex-to-complex 
FFT across multiple grid sizes and batch sizes. All output is logged 
to a timestamped file.

---

## Server Specifications

  Hostname  : amdtoolsserver.morphingmachines
  User      : nikhil
  CPU       : Intel Xeon W-2155 @ 3.30GHz
              - Family 6, Model 85, Stepping 4 (Skylake-X)
              - 10 physical cores / 20 logical (hyperthreading)
              - 1 socket, 1 NUMA node (clean benchmark environment)
  AVX       : avx, avx2, avx512f, avx512dq, avx512bw, avx512cd, avx512vl
              (full Skylake-X AVX-512 suite confirmed via /proc/cpuinfo)
  Cache     : L1d 32KB | L2 1MB per core | L3 14MB shared
  Governor  : performance (already set correctly)
  Turbo     : ON (no_turbo = 0), max 4500 MHz
  OS        : Linux (exact distro TBD)
  Working   : ~/fft_test/ or current directory

  Cache working set reference for problem size selection:
    64^3  =   4MB  → fits in L3        ✓ compute bound
    128^3 =  32MB  → spills to DRAM    ← performance cliff here
    256^3 = 256MB  → fully DRAM bound

  AVX-512 frequency throttle note:
    Skylake-X drops from 3.3GHz to ~2.5GHz under sustained AVX-512.
    All benchmarks must include 5 warmup iterations (untimed) before
    the timed loop so frequency settles before measurement starts.

---


## Files Already Written

Two files exist and are ready (just blocked on missing library):

### 1. fft_benchmark.c
  - Pure C99, uses MKL DFTI API (mkl_dfti.h)
  - Random initialization via rand() seeded at 42
  - 64-byte aligned allocation via mkl_malloc() for AVX-512
  - Out-of-place FFT (DFTI_NOT_INPLACE) for better cache behavior
  - Measures both forward and backward FFT separately
  - Reports: time (ms), GFLOPS (Cooley-Tukey theoretical: 5*N*log2(N))
  - 5 warmup iterations before timed loop (critical for Skylake-X)
  - 20 timed runs averaged per configuration
  - 5 scenarios inside one binary:
      Scenario 1: CPU baseline    — grid sweep, 1 thread
      Scenario 2: AVX-512         — grid sweep, 1 thread
      Scenario 3: AVX-512 + MT   — grid sweep, N threads (CLI arg)
      Scenario 4: Thread scaling  — 128^3, threads: 1,2,4,8,10,20
      Scenario 5: Batch scaling   — 128^3, batch: 1,2,4,8,16,32

### 2. run_fft_benchmarks.sh
  - Sources Intel oneAPI automatically (checks /opt/intel/oneapi)
  - Falls back to module load
  - Compiles TWO binaries:
      fft_cpu_only  → compiled with -O2           (no AVX flags)
      fft_avx512    → compiled with -O3 -xCORE-AVX512
  - Supports both Intel compiler (icc/icx) and GCC
  - Sets KMP_AFFINITY=scatter,granularity=fine (from Intel MKL slides)
  - Runs all scenarios with correct OMP/MKL thread env vars
  - Uses MKL_VERBOSE=1 at end to confirm AVX-512 kernel selection
  - All output tee'd to ./fft_logs/fft_benchmark_TIMESTAMP.log
  - Final grep commands to extract GFLOPS comparison from log

---

## Key Technical Decisions Made (Can be changed if not optimal)

1. MKL over FFTW as primary: MKL is ~50% faster than FFTW on Intel
   hardware and is Intel's own recommendation for Xeon platforms.
   FFTW is fallback option.

2. Out-of-place FFT: separate in/out buffers avoid cache set conflict
   misses that affect in-place transforms at large N.

3. Smooth number grid sizes (powers of 2): 64, 128, 256 chosen
   because MKL uses Cooley-Tukey which requires highly composite N.
   Avoid prime or large-prime-factor sizes — they fall back to 
   Bluestein which is much slower.

4. Batch FFT via DFTI_NUMBER_OF_TRANSFORMS: never loop over single
   FFT calls. Batching lets MKL reuse twiddle factors across all
   transforms, keeping them in L2/L3 cache.

5. mkl_malloc with 64-byte alignment: AVX-512 registers are 64 bytes
   wide. Misaligned data forces split cache-line loads, doubling
   memory traffic. Regular malloc() is not sufficient.

6. GFLOPS formula: 5 * N * log2(N) * howmany
   This is the standard Cooley-Tukey theoretical FLOP count.
   Used for comparing against Intel's own benchmark slides.

7. Warmup before timing: Skylake-X throttles clock from 3.3GHz to
   ~2.5GHz when AVX-512 is active. Without warmup, first timed run
   captures transient frequency, giving misleading fast result.

8. KMP_AFFINITY=scatter: spreads OpenMP threads across physical cores
   before using hyperthreads. Recommended in Intel's own MKL FFT
   application slides (Jeongnim Kim, Intel, 2018).

---

## Background and Motivation

Reference: Intel internal slides "Leveraging Optimized FFT on Intel 
Platforms" by Jeongnim Kim, DCG/E&G/HPC Ecosystem and Applications 
Team, MKL team, May 2018. Key result from slides: composed 3D FFT 
using batched approach on Xeon Platinum 8170 (similar Skylake arch) 
achieves 80x speedup over single-thread baseline using 26 threads.

It is in workspace/ dir

---
