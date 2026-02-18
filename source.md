# Source Walkthrough: `fft_benchmark.c` and `run_fft_benchmarks.sh`

This document explains exactly what this benchmark does, what each phase means, how threads are used, what inputs mean (`64x64x64`, batch, etc.), and where the current benchmark is strong vs where it can be improved.

---

## 1. Big picture

This project measures **3D complex-to-complex FFT performance** using **Intel oneMKL DFTI** on a Xeon machine.

There are two control layers:

1. **Outer runner** (`src/run_fft_benchmarks.sh`):
- Sets environment
- Compiles binaries
- Runs the benchmark in different top-level modes (1 thread baseline, 1 thread AVX512, 10-thread AVX512, 20-thread AVX512)
- Produces log + summary

2. **Inner benchmark** (`src/fft_benchmark.c`):
- For a given process/thread setting, executes multiple workload sections (called SCENARIO 1..5 inside the C program)
- Each section runs many FFT configurations (grid sizes, batch sizes, and thread counts)

Important: there are **two different uses of “Scenario”**:
- Shell script “Scenario 1/2/3/3b” = top-level run mode
- C program “SCENARIO 1..5” = workload sections inside each run

---

## 2. Hardware/thread context (what threads mean here)

Your host (from logs and instructions):
- CPU: Intel Xeon W-2155
- **10 physical cores**
- **20 logical threads** (Hyper-Threading, 2 per core)

So in practice:
- `threads=10` means usually one software thread per physical core
- `threads=20` means physical cores + sibling hyperthreads

In this benchmark, thread control happens through:
- `MKL_NUM_THREADS`
- `OMP_NUM_THREADS`
- `mkl_set_num_threads(num_threads)` inside C

The benchmark is mostly driven by MKL threading; OpenMP vars are present but MKL is the main parallel engine for FFT calls.

---

## 3. Input concepts: grid size, batch size, transforms

### 3.1 What does `64x64x64` mean?

It is a **3D FFT grid**:
- `nx=64`, `ny=64`, `nz=64`
- Total points per transform: `N = nx * ny * nz = 262,144`

If you had `32x32x32` (not currently used), that would mean:
- `N = 32 * 32 * 32 = 32,768`
- Smaller working set, usually higher apparent GFLOPS due to cache friendliness

### 3.2 What is `batch` / `howmany`?

`batch` means **number of independent 3D FFTs executed in one DFTI call**.

Examples:
- `128^3 batch=1` = one transform
- `128^3 batch=4` = four transforms processed together
- `128^3 batch=32` = 32 transforms together

Batching can improve throughput because MKL reuses internal setup/twiddles and improves memory behavior.

### 3.3 Why memory grows so much

Code uses out-of-place transforms:
- input buffer + output buffer
- complex double = 16 bytes

Memory shown in log is total of both buffers.

Example:
- `128^3` has ~2.1M complex numbers
- With batch=4: ~8.4M complex
- Two buffers => ~16.8M complex values => ~256 MB (matches logs)

---

## 4. `run_fft_benchmarks.sh` explained phase-by-phase

### 4.1 Setup and logging

- Creates timestamped log in `src/fft_logs/`
- Redirects all stdout/stderr through `tee` so console + log both capture output

### 4.2 Environment detection

Tries to find MKL from:
- `$MKLROOT`
- `/opt/intel/oneapi/mkl/latest`
- `/opt/intel/mkl`
- `$HOME/.local` (pip-installed MKL)

Then validates:
- header: `mkl_dfti.h`
- runtime library: `libmkl_rt.so` or `libmkl_rt.so.2`

### 4.3 Compiler selection

Prefers:
- `icx` / `icc` if present
- else `gcc`

Compiles two binaries:
- `fft_cpu_only` with `-O2`
- `fft_avx512` with `-O3` + AVX-512 flags (or `-xCORE-AVX512` for Intel compilers)

### 4.4 Runtime affinity and MKL knobs

Script sets:
- `KMP_AFFINITY=scatter,granularity=fine`
- `KMP_BLOCKTIME=0`
- `MKL_DYNAMIC=FALSE`

These help deterministic core placement and avoid dynamic thread count changes.

### 4.5 Top-level run modes (outer scenarios)

The script runs 4 top-level passes:

1. Scenario 1: baseline ISA, 1 thread
- Binary: `fft_cpu_only`
- `MKL_ENABLE_INSTRUCTIONS=SSE4_2`
- `MKL_NUM_THREADS=1`

2. Scenario 2: AVX-512 ISA, 1 thread
- Binary: `fft_avx512`
- `MKL_ENABLE_INSTRUCTIONS=AVX512`
- `MKL_NUM_THREADS=1`

3. Scenario 3: AVX-512 + physical cores
- Binary: `fft_avx512`
- `threads=10`

4. Scenario 3b: AVX-512 + logical cores
- Binary: `fft_avx512`
- `threads=20`

### 4.6 MKL verbose check

At the end, script compiles/runs a tiny FFT and prints `MKL_VERBOSE` lines.
This confirms the actual kernel family MKL used at runtime (important for AVX-512 verification).

### 4.7 Summary extraction

Script parses the just-generated log and reports one comparable metric:
- Forward GFLOPS at `128^3 batch=4`
- for outer Scenario 1 / 2 / 3 / 3b

---

## 5. `fft_benchmark.c` explained deeply

## 5.1 Entry and configuration

Main reads:
- CLI arg: requested thread count (`cli_threads`)
- env:
  - `BENCH_NRUNS` (default 20)
  - `BENCH_WARMUP` (default 5)

Then prints machine-oriented context and starts workload sections.

## 5.2 Core kernel path (`run_benchmark`)

For each `(nx, ny, nz, batch, num_threads)` combo:

1. `mkl_set_num_threads(num_threads)`
2. Allocate 64-byte aligned input/output via `mkl_malloc`
3. Fill input with deterministic random numbers (`srand(42)` + `rand()`)
4. Build DFTI descriptor:
- precision: double
- type: complex
- dimension: 3
- number of transforms: `batch`
- input/output distances for batched layout
- placement: out-of-place
5. Warmup forward runs (`warmup_runs`, untimed)
6. Timed forward loop (`nruns`)
7. Timed backward loop (`nruns`)
8. Compute GFLOPS using `5 * N * log2(N) * batch`
9. Print one line with time/GFLOPS/memory
10. Cleanup descriptor + buffers

## 5.3 Inner workload sections (`SCENARIO 1..5` in C)

These run **inside every top-level outer run**:

1. `SCENARIO 1 — CPU ONLY (1 thread)`
- Fixed thread = 1
- Grids: 64^3, 128^3, 256^3
- Batches: mostly 1 and 4

2. `SCENARIO 2 — CPU + AVX-512 (1 thread)`
- Also fixed thread = 1
- Same grid/batch pattern

3. `SCENARIO 3 — AVX-512 + Multithreaded`
- Uses `cli_threads` from shell script (1, 10, or 20 depending on outer pass)
- More batch points (1,4,16) on 64^3 and 128^3

4. `SCENARIO 4 — Thread Scaling Sweep`
- Fixed problem: 128^3 batch=4
- Threads tested: 1,2,4,8,10,20
- Purpose: scaling curve vs threads

5. `SCENARIO 5 — Batch Scaling Sweep`
- Fixed grid: 128^3
- Batch tested: 1,2,4,8,16,32
- Uses `cli_threads` for thread count in this section

---

## 6. What “thread scaling” and “batch scaling” mean

### Thread scaling

Hold FFT problem size constant, increase threads.
Goal: see how close performance gets to ideal speedup.

Example idealized:
- 1 thread = 10 GFLOPS
- 10 threads ideal = 100 GFLOPS
- if observed 60 GFLOPS => 60% parallel efficiency vs ideal

Your logs typically show strong gain up to ~10 threads, then smaller gain at 20 threads (expected with HT and memory pressure).

### Batch scaling

Hold grid fixed, increase number of FFTs done together in one call.
Goal: measure throughput behavior and setup amortization.

Batch scaling is useful when real workloads process many independent FFT volumes/snapshots.

---

## 7. Are we using Xeon AVX-512 or not?

Yes, evidence is present:
- `MKL_ENABLE_INSTRUCTIONS=AVX512` is set for AVX runs
- `MKL_VERBOSE` prints AVX-512 enabled kernel line
- 1-thread throughput jump from baseline ISA mode to AVX mode appears in logs

So AVX-512 path is active.

---

## 8. Discrepancies / caveats in current benchmarking

These are the biggest points to understand before drawing conclusions:

1. "CPU-only/scalar baseline" is not truly scalar C code
- The benchmark always calls MKL.
- Baseline run limits MKL ISA to SSE4.2 and uses a different host binary.
- So this is really **"lower ISA MKL" vs "AVX512 MKL"**, not hand-written scalar FFT vs vector FFT.

2. Scenario naming is overloaded and can confuse analysis
- Outer script has Scenario 1/2/3/3b.
- C file has SCENARIO 1..5 inside each outer run.
- You will see repeated section names many times in one log.

3. Redundant repeated work
- Every outer run executes all 5 inner sections.
- This repeats many measurements and lengthens total runtime.
- It is useful for robustness, but less clean for reporting.

4. Section titles in C can be misleading in some outer passes
- C prints labels like "CPU only" and "CPU+AVX-512" regardless of outer runner mode.
- Actual ISA control is from `MKL_ENABLE_INSTRUCTIONS` set by shell script.

5. Batch scaling section says "max threads" but actually uses `cli_threads`
- In `fft_benchmark.c`, scenario 5 uses `cli_threads`.
- So in 1-thread outer runs, that section is not max threads.

6. GFLOPS formula is theoretical operation count
- Good for relative comparisons in this project.
- Not exact hardware flop-counter measurement.

7. No correctness validation step
- The benchmark measures speed only.
- It does not validate inverse(forward(x)) error norm.

8. One data point extraction for final summary
- Summary uses only `128^3 batch=4` forward GFLOPS.
- Useful, but can hide behavior differences at other sizes/batches.

---

## 9. What is useful vs less useful right now

Most useful currently:
- Outer Scenario comparison (1-thread baseline vs 1-thread AVX512 vs 10/20-thread AVX512)
- Thread scaling at `128^3 batch=4`
- Large-size behavior (`256^3`) to show memory-bound regime

Less useful / potentially misleading:
- Treating C “SCENARIO 1 CPU ONLY” as true scalar baseline
- Comparing sections across outer runs without tracking outer mode

---

## 10. How to make benchmark better (high-impact improvements)

1. Split C workload by mode flags
- Add CLI flags to run only selected inner sections.
- Example: `--section thread_scaling`.
- Reduces duplication and log complexity.

2. Make baseline definitions explicit
- Rename baseline to `MKL_SSE42_1T` and AVX run to `MKL_AVX512_1T`.
- Avoid "scalar" wording.

3. Add correctness check
- After backward FFT, compare against original input with relative L2 error.

4. Add AVX2 intermediate mode
- Compare `SSE4_2` vs `AVX2` vs `AVX512` (same thread count).

5. Add concise CSV output
- Write one row per measurement with columns:
  `outer_mode, section, nx,ny,nz,batch,threads,fwd_ms,bwd_ms,fwd_gflops,bwd_gflops`.

6. Add stability stats
- Record min/mean/stddev, not only mean.
- Especially for multithreaded runs where jitter can be nontrivial.

7. Include realistic production sizes
- If your target app uses non power-of-two or mixed dimensions, add them.

8. Consider FFTW comparison path
- Useful if you want "best available library" story, not only MKL internal tuning.

---

## 11. Quick mental model to stay confident while reading logs

When reading a log, do this in order:

1. Find outer run header (`RUNNING: Scenario ...`) to know ISA + thread target.
2. Within that block, read C section output (`SCENARIO 1..5`).
3. For apples-to-apples compare:
- same grid
- same batch
- same thread count
- different outer mode only
4. Use end summary for first-pass comparison, then drill into thread/batch scaling sections.

---

## 12. Key takeaways for this codebase

- The benchmark is real MKL DFTI performance testing, not synthetic placeholders.
- AVX-512 is being utilized.
- Threading behavior aligns with Xeon topology expectations (10 physical / 20 logical).
- Main clarity issue is naming/structure, not missing functionality.
- With a few structural changes, this can become a very solid reproducible benchmark harness.

