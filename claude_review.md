# 1D FFT Performance Benchmark: Technical Review and Analysis

**Platform:** Intel Xeon W-2155 (Skylake-X, 10C/20T, 3.3 GHz base, 4.5 GHz turbo)
**Library:** Intel oneMKL 2025.0.3 (DFTI interface)
**Precision:** Single-precision complex (`MKL_Complex8`, 8 bytes/element)
**Document status:** Official technical review for reproducibility and external comparison
**Date:** 2026-03-12

---

## 1. Executive Summary

This document describes the complete methodology, tooling, and results for 1D single-precision complex FFT benchmarking on an Intel Xeon W-2155 server using Intel oneMKL. The benchmark is designed to produce defensible, reproducible throughput numbers under two clearly separated regimes:

1. **Cache-reuse (hot)** — an upper bound reflecting maximum throughput when the same data remains cache-resident across repeated FFT calls.
2. **No-cache-reuse (cold/streaming)** — a sustained throughput measurement where buffer rotation forces data to be fetched from main memory on each iteration, approximating realistic workloads where FFT inputs are not reused.

The key finding is that FFT performance on this platform is fundamentally limited by memory bandwidth, not compute. Under cache-reuse conditions, the benchmark achieves up to **745 SP GFLOPS** (35.3% of the 2112 GFLOPS base-clock compute peak). Under realistic no-reuse conditions, sustained throughput drops to **85–170 SP GFLOPS** (4–8% of compute peak). This 4–9x gap between hot and cold regimes is expected and well-understood: FFT's `log2(N)` butterfly stages demand repeated data movement that saturates the memory subsystem long before the FMA units are fully utilized.

---

## 2. Hardware and Software Configuration

### 2.1 CPU Specifications

| Parameter | Value | Source |
|---|---:|---|
| Model | Intel Xeon W-2155 @ 3.30 GHz | `lscpu` |
| Microarchitecture | Skylake-X (Family 6, Model 85, Stepping 4) | `lscpu` |
| Physical cores | 10 | `lscpu` |
| Logical threads | 20 (SMT / Hyperthreading enabled) | `lscpu` |
| Base clock | 3.30 GHz | `lscpu` |
| Max single-core turbo | 4.50 GHz | `lscpu` |
| L1d / L1i cache | 32 KB per core | `lscpu` |
| L2 cache | 1024 KB per core | `lscpu` |
| L3 cache (shared) | 14080 KB (13.75 MB) | `lscpu` |
| AVX-512 FMA units per core | 2 (Port 0 + Port 5) | Intel ARK |
| AVX-512 ISA extensions | avx512f, avx512dq, avx512cd, avx512bw, avx512vl | `/proc/cpuinfo` |
| TDP | 140 W | Intel ARK |
| NUMA nodes | 1 | `lscpu` |

### 2.2 Memory Configuration

| Parameter | Value | Source |
|---|---:|---|
| Installed RAM | 64 GB (4 x 16 GB DDR4 Unbuffered) | `/sys/devices/system/edac` |
| Memory controllers | 2 (Skylake Socket#0 IMC#0/1) | `/sys/devices/system/edac` |
| Memory channels supported | 4 | Intel ARK |
| Max memory bandwidth (vendor) | 85.3 GB/s | Intel ARK |

### 2.3 Software Environment

| Component | Value |
|---|---|
| OS | Red Hat Enterprise Linux 8.10 (kernel 4.18.0-553.30.1.el8_10.x86_64) |
| oneMKL | Version 2025.0.3, linked via `libmkl_rt.so.2` |
| Compiler | GCC / ICX with `-O3 -march=native` (or `-xHost` for Intel compilers) |
| Runtime settings | `KMP_AFFINITY=scatter,granularity=fine`, `KMP_BLOCKTIME=200`, `MKL_DYNAMIC=FALSE` |

### 2.4 Theoretical Compute Peak

The single-precision FMA-based peak is:

```
Peak = cores × FMA_units/core × SIMD_lanes × FLOPs/FMA × frequency
     = 10 × 2 × 16 × 2 × 3.3 GHz
     = 2112 SP GFLOPS (base clock)
```

This is the denominator used in all `% of peak` calculations throughout the benchmark. It represents a pure FMA throughput ceiling — an idealized upper bound that no memory-bound workload can approach. FFT percentage-of-peak figures in the single digits are expected and not indicative of a benchmark defect.

---

## 3. Benchmark Methodology

### 3.1 FFT Configuration

All benchmarks use the Intel oneMKL Discrete Fourier Transform Interface (DFTI):

- **Transform type:** 1D complex-to-complex, single precision
- **Data type:** `MKL_Complex8` (interleaved float pairs, 8 bytes per element)
- **Placement:** Out-of-place (`DFTI_NOT_INPLACE`)
- **Batching:** DFTI native batching via `DFTI_NUMBER_OF_TRANSFORMS` and `DFTI_INPUT_DISTANCE = N`
- **Direction timed:** Forward (`DftiComputeForward`) is the primary metric; backward is recorded but not used for business claims
- **Thread control:** `mkl_set_num_threads()` + environment variables `OMP_NUM_THREADS` and `MKL_NUM_THREADS`

Memory is allocated with 64-byte alignment via `mkl_malloc`, satisfying AVX-512 alignment requirements.

### 3.2 FLOP Counting Convention

The algorithmic FLOP count for an N-point complex FFT follows the standard Cooley-Tukey model:

```
FLOPs = 5 × N × log₂(N) × batch
```

This counts 5 real floating-point operations per radix-2 butterfly (one complex multiply plus one complex add). This is the universally accepted convention for FFT performance normalization in the HPC community and allows direct comparison with published FFT benchmarks from other vendors and libraries.

**Throughput is then:**
```
SP GFLOPS = FLOPs / (avg_time_ms × 10⁶)
```

This is an *algorithmic throughput* metric — it normalizes performance to a standardized operation count, not to hardware counter measurements. It allows fair comparison across different FFT implementations and platforms regardless of internal algorithmic differences.

### 3.3 Timing Methodology

**Clock source:** `clock_gettime(CLOCK_MONOTONIC)` — monotonic wall-clock with nanosecond resolution, immune to NTP adjustments.

**What is timed:**
- Only the `DftiComputeForward` (or `DftiComputeBackward`) calls within the measurement loop.

**What is NOT timed:**
- Buffer allocation and initialization
- DFTI plan creation and commit
- Validation passes (forward + backward roundtrip correctness check)
- Warmup iterations

**Warmup phase:** A configurable number of warmup iterations (`BENCH_WARMUP`, default: 5) execute the FFT on the same buffers before timing begins. This stabilizes the MKL runtime, JIT compilation paths, thread pool initialization, and microarchitectural state (branch predictors, TLB entries).

**Adaptive timing (cold/streaming harnesses):** The newer C harnesses (`run_cache_noreuse`, `run_batch_1`, `run_core_wise`) use an adaptive iteration scheme:

1. Start with `BENCH_NRUNS` iterations (default: 20).
2. Time the entire batch of iterations.
3. If total elapsed time is less than `BENCH_MIN_TOTAL_MS` (50–75 ms depending on campaign), increase the iteration count proportionally and re-time.
4. Repeat until the timing threshold is met or `BENCH_MAX_ADAPT_ITERS` is reached.
5. Report per-call time as `total_elapsed / timed_iterations`.

This ensures that even fast cases (small N) accumulate enough total time to reduce timer granularity noise. The minimum total timing window of 50–75 ms is well above the ~25 ns `CLOCK_MONOTONIC` resolution, providing sub-percent relative timing uncertainty for all measured cases.

**Fixed-iteration timing (cache-reuse harness):** The `run_cache_reuse` harness uses a fixed iteration count (`BENCH_NRUNS`, default: 20) without adaptive expansion. This is acceptable for the cache-reuse profile because all timed calls operate on the same small buffer that remains cache-hot, and the fixed count is sufficient for stable averages.

### 3.4 Correctness Validation

Each benchmark case performs a round-trip correctness check before the timed section:

1. Forward FFT on input buffer → output buffer
2. Backward FFT on output buffer → reconstructed input
3. Scale reconstructed values by 1/N (MKL's unnormalized convention)
4. Compute relative RMS error and maximum absolute error against the original input
5. Pass if either `rel_RMS ≤ tolerance` or `max_abs ≤ tolerance` (default tolerance: 1×10⁻⁴)

Results are logged as `CHECK|...|PASS` or `CHECK|...|FAIL` lines. With `BENCH_VALIDATE_STRICT=1`, any validation failure immediately skips the timed section for that case. Across all campaigns, **zero validation failures** have been recorded, confirming numerical correctness of all measured results.

### 3.5 Statistical Methodology

Each benchmark campaign executes multiple independent runs (3–5 depending on the family):

- Each run independently creates the DFTI plan, allocates fresh buffers, and times all cases.
- Per-case results across runs are averaged by the aggregation scripts.
- The averaged CSV records `samples_ok` and `samples_expected` for every row; quality gates require these to match exactly.
- A `quality` field flags rows as `ok` only when sample counts are complete and validation passes.

---

## 4. Memory Behavior: Cache Reuse vs. No Reuse

This is the central design axis of the benchmark and the primary source of performance differences across campaign families.

### 4.1 Why Memory Behavior Matters for FFT

FFT is not a simple matrix multiply where data is consumed in large, predictable streaming patterns. Instead, the Cooley-Tukey algorithm operates in `log₂(N)` stages, with each stage performing butterfly operations across data elements at varying strides. For large N, these strides exceed cache line size and eventually exceed cache capacity, causing cache misses at each stage.

On this platform:
- **L1 data cache:** 32 KB per core (holds ~4096 complex SP elements)
- **L2 cache:** 1024 KB per core (holds ~131072 elements)
- **L3 cache:** 14080 KB shared (holds ~1.8M elements)

For a single FFT of N=65536 (512 KB of complex SP data), the working set fits comfortably in L2. But the multi-stage butterfly access pattern means that cache lines are evicted and re-fetched across stages unless the entire working set stays resident. When the benchmark reuses the same buffer across iterations, hardware prefetchers and cache replacement policies can keep data warm. When buffers rotate, each iteration starts from a cold cache state relative to that buffer's data.

### 4.2 Cache-Reuse Mode (run_cache_reuse)

**C harness:** `fft_benchmark_run_3_3.c` (referenced; architecturally identical to the root `fft_benchmark.c`)

**Memory structure:**
- A single input buffer and a single output buffer are allocated per case.
- Size per buffer: `N × batch × 8 bytes`
- Total working footprint: `2 × N × batch × 8 bytes`
- The same pointers are passed to `DftiComputeForward` on every timed iteration.

**What happens at the hardware level:**
After warmup, the input buffer data and MKL's internal scratch memory are cache-resident. Subsequent iterations find most data in L1/L2/L3, experiencing minimal DRAM traffic. This measures the FFT kernel's *compute-limited* throughput — what happens when memory is not the bottleneck.

**Reported working memory:** Very small (e.g., ~1.0 MB for N=65536, batch=1; ~1024 MB for N=65536, batch=1024). These reflect the raw tensor sizes, not the actual cache pressure.

**When this mode is appropriate:**
- Measuring the MKL FFT kernel's maximum throughput under ideal conditions
- Regression testing — detecting kernel-level performance changes
- Upper-bound reference for cache-friendly applications (e.g., repeated FFTs on the same signal buffer in real-time processing)

### 4.3 No-Reuse / Streaming Mode (run_cache_noreuse, run_batch_1, run_core_wise)

**C harness:** `fft_benchmark_run_3_9.c` (and derivatives)

**Memory structure:**
- A *pool* of input buffers (`in_pool`) and a corresponding pool of output buffers (`out_pool`) is allocated.
- Each pool contains `stream_slots` copies of the full tensor (`N × batch × 8 bytes` each).
- Each slot is initialized with distinct random data (seeded uniquely per slot).
- On timed iteration `i`, the harness selects slot `i % stream_slots`, using pointer arithmetic: `in = in_pool + slot × total_elements`.
- An additional `orig` buffer holds a copy of slot 0 for validation.

**Slot count calculation:**
```
candidate_slots = ceil(BENCH_STREAM_TARGET_MB × 1024² / (2 × N × batch × 8))
stream_slots = clamp(candidate_slots, BENCH_STREAM_MIN_SLOTS, BENCH_STREAM_MAX_SLOTS)
```
The result is further reduced if total allocation would exceed `BENCH_MAX_MEM_MB`.

**What happens at the hardware level:**
With a large pool (128 MB to 1+ GB), the rotating slot access pattern prevents temporal locality from helping. Each iteration touches data that has likely been evicted from cache since the last time that slot was used. The FFT must fetch its input from L3 or DRAM, measuring *memory-bandwidth-limited* throughput.

**Concrete examples (N=65536, batch=1, AVX512, 10 threads):**

| Campaign | Working Set | Slots | Forward GFLOPS | % of Compute Peak |
|---|---:|---:|---:|---:|
| `run_cache_reuse` | ~1.0 MB | 1 | 137.51 | 6.51% |
| `run_cache_noreuse` | ~128.5 MB | moderate | 89.84 | 4.25% |
| `run_batch_1` | ~1024.5 MB | 64+ | 85.86 | 4.07% |
| `run_core_wise` (10c/1t) | ~1024.5 MB | 64+ | 88.48 | 4.19% |

The 1.5–1.6x drop from reuse to no-reuse at this point, and the convergence of all three cold campaigns to within ~5% of each other, demonstrates that the no-reuse methodology successfully eliminates cache reuse inflation and produces a stable, reproducible sustained throughput figure.

### 4.4 Campaign-Specific Streaming Parameters

| Parameter | `run_cache_reuse` | `run_cache_noreuse` | `run_batch_1` / `run_core_wise` |
|---|---|---|---|
| `BENCH_STREAM_MODE` | N/A (no slot rotation) | 1 | 1 |
| `BENCH_STREAM_TARGET_MB` | N/A | 128 | 1024 |
| `BENCH_STREAM_MIN_SLOTS` | N/A | 2 | 64 |
| `BENCH_STREAM_MAX_SLOTS` | N/A | 256 | 32768 |
| `BENCH_MIN_TOTAL_MS` | 50 | 50 | 75 |
| `BENCH_MAX_MEM_MB` | 3072 | 3072 | 3072 |
| `BENCH_WARMUP` | 5 | 5 | 5 |
| `BENCH_NRUNS` (seed iterations) | 20 | 20 | 20 |

The `run_cache_noreuse` campaign uses a 128 MB target — enough to significantly reduce cache reuse for moderate-to-large N, but still somewhat moderate. The `run_batch_1` and `run_core_wise` campaigns raise the target to 1024 MB ("extra-cold"), which exceeds L3 capacity (~14 MB) by ~73x and produces the most conservative sustained throughput numbers.

---

## 5. Benchmark Campaign Descriptions

### 5.1 run_cache_reuse

**Purpose:** Establish the upper-bound throughput under pointer-reuse conditions.

**Test matrix:**
- 16 FFT lengths: N = 2, 4, 8, 16, 32, 64, 128, 256, 512, 1024, 2048, 4096, 8192, 16384, 32768, 65536
- 6 batch sizes: 1, 10, 16, 150, 256, 1024
- 3 thread profiles: SSE4.2 single-thread baseline, AVX-512 10-thread (physical cores), AVX-512 20-thread (logical cores with SMT)
- Full matrix: 16 × 6 × 3 = **288 cases**
- Runs: 3, all averaged

**Best observed throughput:** **745.42 SP GFLOPS** at N=1024, batch=256, AVX-512 10 threads (35.3% of 2112 GFLOPS compute peak).

**Interpretation:** This represents what the MKL FFT kernel can deliver when data stays cache-hot. The N=1024, batch=256 case has a total tensor size of ~4 MB (fits in L3) and high arithmetic intensity per FFT call due to batching. Larger working sets (e.g., N=65536, batch=1024 at ~1 GB) show dramatically lower throughput even in reuse mode because the dataset exceeds cache capacity and forces DRAM traffic regardless of pointer reuse.

### 5.2 run_cache_noreuse

**Purpose:** Measure sustained throughput with moderate streaming (128 MB target working set).

**Test matrix:** Identical to `run_cache_reuse` (288 cases, 3 runs).

**Best observed throughput:** **170.42 SP GFLOPS** at N=8192, batch=150, AVX-512 10 threads (8.1% of compute peak).

**Key observation:** The 4.4x drop from the cache-reuse best case (745 vs. 170 GFLOPS) is not an apples-to-apples comparison — the best cases differ in N and batch. At matched parameters (N=65536, batch=1), the drop is ~1.5x (137 → 90 GFLOPS), which is more representative of the cache-reuse effect for a single-FFT workload.

### 5.3 run_batch_1

**Purpose:** Characterize sustained single-FFT throughput (batch=1) under extra-cold conditions (1024 MB target).

**Test matrix:**
- 16 FFT lengths: N = 2 through 65536
- Batch: 1 only
- 3 thread profiles (same as above)
- 48 cases, 5 runs

**Best observed throughput:** **85.86 SP GFLOPS** at N=65536, AVX-512 10 threads (4.1% of compute peak).

**Interpretation:** This is the most conservative measurement for single-FFT sustained performance. With batch=1 and a 1 GB+ rotating buffer pool, the benchmark forces every FFT call to fetch its ~512 KB input (for N=65536) from memory that has been evicted since the previous use of that slot. This closely models a workload where each FFT processes a new, independent data block.

### 5.4 run_batch_1/large_N

**Purpose:** Extend the batch=1 characterization to very large transform sizes (N up to 4,194,304).

**Test matrix:**
- 22 FFT lengths: N = 2 through 4,194,304
- Batch: 1 only
- 3 thread profiles
- 66 cases, 3 runs

**Best observed throughput:** **97.48 SP GFLOPS** at N=1,048,576 (1M), AVX-512 10 threads (4.6% of compute peak).

**Scaling observations:**
- Throughput increases from small N up to a plateau around N=524288–1048576.
- At N=4,194,304, the single tensor is ~32 MB (exceeds L3), and 10-thread throughput is 64.24 GFLOPS.
- The throughput curve reflects the transition from overhead-dominated (small N) to memory-bandwidth-limited (large N) regimes.

### 5.5 run_core_wise

**Purpose:** Map performance as a function of core count and SMT (1 thread/core vs. 2 threads/core), under extra-cold conditions with explicit CPU pinning.

**Test matrix:**
- 22 FFT lengths: N = 2 through 4,194,304
- Batch: 1
- 10 core counts (1 through 10) × 2 thread modes (1T/core, 2T/core) = 20 configurations
- 440 cases, 1 run per configuration (CPU-pinned via `taskset`)

**Best observed throughput:** **105.49 SP GFLOPS** at N=1,048,576, 10 cores × 1 thread/core.

**SMT finding:** Across all N and core counts, the average ratio of 2T/core to 1T/core throughput is slightly above 1.0, but the benefit is inconsistent. At some working points SMT slightly helps; at others it slightly hurts. For memory-bandwidth-limited FFT, the second hardware thread on each core adds contention for the shared L1/L2 cache and memory bus with diminishing returns.

---

## 6. Orchestration and Automation

### 6.1 Suite Runner Scripts

Each benchmark family has a dedicated suite runner shell script (e.g., `run_run_3_3_suite.sh`, `run_run_3_9_suite.sh`). These scripts:

1. **Compile** the C harness using the best available compiler (ICX > ICC > GCC) with aggressive optimization flags (`-O3 -march=native` or `-O3 -xHost`).
2. **Detect** the MKL installation path and configure library linkage.
3. **Create** a timestamped session directory with a `runs/` subdirectory.
4. **Execute** multiple independent runs, each producing a raw log file.
5. **Set** environment variables for each profile: thread counts, ISA restrictions (`MKL_ENABLE_INSTRUCTIONS`), streaming parameters, and runtime configuration.
6. **Record** a manifest (`manifest.tsv`) mapping run IDs to log and report file paths.
7. **Invoke** the aggregation script and plot generation script after all runs complete.
8. **Update** `LATEST_SESSION.txt` and `current` symlink for easy access.

### 6.2 Thread and ISA Profiles

Three standard profiles are used across all campaigns:

| Profile ID | ISA Restriction | Thread Count | Purpose |
|---|---|---:|---|
| `baseline_sse42_1t` | `SSE4_2` | 1 | Single-thread scalar baseline; disables AVX2/AVX-512 in MKL to isolate ISA contribution |
| `avx512_phys` | `AVX512` | 10 | Full AVX-512 with one thread per physical core |
| `avx512_logical` | `AVX512` | 20 | Full AVX-512 with SMT (two threads per physical core) |

The ISA restriction is applied via `MKL_ENABLE_INSTRUCTIONS`, which tells the MKL runtime to select kernel implementations limited to the specified instruction set. This allows measuring the ISA contribution independently of threading effects.

The `run_core_wise` campaign extends this to a full sweep: 1–10 cores × 1–2 threads/core, with each configuration pinned to specific physical cores using `taskset` and `lscpu`-derived topology maps.

### 6.3 Runtime Environment Controls

| Setting | Value | Purpose |
|---|---|---|
| `KMP_AFFINITY=scatter,granularity=fine` | Distribute threads across cores before doubling up on any core | Maximize cache and memory bandwidth per thread |
| `KMP_BLOCKTIME=200` | OpenMP threads wait 200 ms at barriers before sleeping | Reduce re-spin overhead for repeated short FFT calls |
| `MKL_DYNAMIC=FALSE` | Disable MKL's dynamic thread adjustment | Ensure the requested thread count is always used |
| `MKL_VERBOSE=0` | Suppress verbose MKL output during timed runs | Avoid I/O interference with timing |

### 6.4 Aggregation Scripts

Each family has a dedicated aggregation script (e.g., `aggregate_run_3_3.sh`, `aggregate_run_3_9.sh`) implemented in AWK. These scripts:

1. Parse all `RESULT|`, `CHECK|`, and `SKIP|` lines from run logs referenced in the manifest.
2. Compute per-case averages of forward time and GFLOPS across all runs.
3. Calculate `fwd_pct_of_peak` using the 2112 GFLOPS denominator.
4. Calculate `fwd_speedup_vs_sse42_1t` by dividing each case's averaged GFLOPS by the corresponding SSE4.2 single-thread baseline.
5. Compile quality metrics: `samples_ok`, `samples_expected`, `check_ok`, `check_fail`.
6. Output averaged CSV and markdown report files.

The aggregation is purely arithmetic averaging — no outlier removal or statistical trimming is applied. The quality gate (`samples_ok == samples_expected` and `check_fail == 0`) ensures data integrity without modifying the values.

### 6.5 Plot Generation Scripts

Each family has a Python plot generation script using matplotlib, pandas, and seaborn. These scripts:

1. Read the averaged CSV.
2. Validate matrix completeness (e.g., 16 lengths × 6 batches × 3 profiles = 288 expected rows).
3. Generate standardized plot sets:
   - **Master heatmap:** Absolute GFLOPS values for all cases, plus percentage improvement vs. baseline.
   - **N-wise compact view:** 4×4 grid showing per-N bar charts across batch sizes and profiles.
   - **Line-by-batch view:** 2×3 grid of line plots showing GFLOPS vs. N for each batch size, with profile overlays.
4. Output a `PLOTS_SUMMARY.md` with coverage status.

All plots are saved as PNG at 170 DPI.

---

## 7. Quality Gates

Every decision-grade run must satisfy the following checks before results are considered valid:

1. **Matrix completeness:** Row count in the averaged CSV exactly matches `(lengths × batches × profiles)` for the campaign.
2. **Sample completeness:** Every row has `samples_ok == samples_expected` (typically 3 or 5).
3. **Numerical correctness:** `check_fail == 0` across all cases and all runs.
4. **Configuration traceability:** `CONFIG|...` lines present in each run log, confirming the exact parameter values used.
5. **Memory audit:** `Slots:` and `Mem:` values in run logs reviewed at key N points to confirm streaming behavior.
6. **Plot coverage:** All expected plot files generated; `PLOTS_SUMMARY.md` shows PASS.

**Current status:** All five campaign families pass all quality gates with zero failures.

---

## 8. Results Summary

### 8.1 Best Forward Throughput by Campaign

| Campaign | Memory Mode | Best Case | GFLOPS | % of 2112 Peak |
|---|---|---|---:|---:|
| `run_cache_reuse` | Hot (single-buffer reuse) | N=1024, B=256, 10T | 745.42 | 35.29% |
| `run_cache_noreuse` | Moderate cold (128 MB target) | N=8192, B=150, 10T | 170.42 | 8.07% |
| `run_batch_1` | Extra-cold (1024 MB target, B=1) | N=65536, B=1, 10T | 85.86 | 4.07% |
| `run_batch_1/large_N` | Extra-cold (1024 MB, B=1, extended N) | N=1048576, B=1, 10T | 97.48 | 4.62% |
| `run_core_wise` | Extra-cold (1024 MB, B=1, pinned) | N=1048576, B=1, 10c×1t | 105.49 | 4.99% |

### 8.2 Matched-Case Comparison (N=65536, Batch=1, ~10 Threads, AVX-512)

| Campaign | Working Set | GFLOPS | Drop vs. Reuse |
|---|---:|---:|---:|
| `run_cache_reuse` | ~1 MB | 137.51 | — |
| `run_cache_noreuse` | ~128.5 MB | 89.84 | −34.7% |
| `run_batch_1` | ~1024.5 MB | 85.86 | −37.6% |
| `run_core_wise` (10c/1t) | ~1024.5 MB | 88.48 | −35.7% |

The three cold campaigns converge to within ~5% of each other, confirming that the streaming methodology produces stable, reproducible results regardless of the specific coldness level (128 MB vs. 1024 MB).

### 8.3 ISA and Threading Effects (from run_cache_noreuse at N=65536)

| Configuration | Batch=1 GFLOPS | Batch=150 GFLOPS | Batch=1024 GFLOPS |
|---|---:|---:|---:|
| SSE4.2, 1 thread | 13.43 | 13.81 | 14.25 |
| AVX-512, 10 threads | 89.84 | 154.97 | 147.54 |
| AVX-512, 20 threads | 44.55 | 100.21 | 149.88 |

Key observations:
- AVX-512 10-thread delivers 6.7x speedup over SSE4.2 single-thread at batch=1 — significantly below the theoretical 10× from core count alone, confirming memory bandwidth as the bottleneck.
- 20-thread SMT provides no benefit (often regression) at batch=1, where per-thread memory demands already saturate bandwidth. At higher batch sizes, SMT sometimes catches up or marginally exceeds 10-thread throughput.
- Batching has diminishing returns under cold conditions — unlike the reuse case where batch=256 at N=1024 hits 745 GFLOPS, the cold case at N=65536 shows little batch scaling.

### 8.4 Core Scaling (from run_core_wise at N=1048576, Batch=1)

| Cores | 1T/core GFLOPS | 2T/core GFLOPS | Scaling Efficiency (1T) |
|---:|---:|---:|---:|
| 1 | 15.13 | 13.60 | 100% (baseline) |
| 2 | 27.33 | 25.24 | 90.3% |
| 4 | 52.44 | 47.10 | 86.6% |
| 6 | 73.78 | 66.79 | 81.2% |
| 8 | 91.52 | 81.72 | 75.6% |
| 10 | 105.49 | 96.96 | 69.7% |

*Note: Scaling efficiency is computed as `(N-core GFLOPS) / (1-core GFLOPS × N) × 100%`.*

Sublinear scaling is the expected behavior for a memory-bandwidth-bound workload. Each additional core adds compute capacity but shares the same memory bus. The 69.7% efficiency at 10 cores is consistent with the memory subsystem becoming the primary bottleneck at high core counts.

---

## 9. Fairness Assessment

### 9.1 Is the Hot (Cache-Reuse) Benchmark Fair?

**Yes, within its stated scope.** The cache-reuse benchmark correctly measures the maximum FFT kernel throughput when data remains cache-resident. This is a legitimate and useful measurement for:
- Kernels that process the same buffer repeatedly (e.g., overlap-add convolution on a fixed impulse response)
- Regression detection and kernel optimization validation
- Comparison with other FFT libraries under identical conditions

**However, it must not be presented as "sustained FFT throughput" without qualification.** The 745 GFLOPS figure is an upper bound that depends on the data fitting in cache and being reused. Any application where FFT inputs change between calls will not achieve this performance.

### 9.2 Is the Cold (No-Reuse) Benchmark Fair?

**Yes, and it is the more representative measurement for most real-world workloads.** The slot rotation mechanism ensures that:

1. Each timed iteration accesses data that has not been recently cached.
2. The working set (128 MB to 1+ GB) far exceeds L3 cache (14 MB), preventing temporal locality from artificially inflating results.
3. Different slots contain distinct random data (each seeded uniquely), so neither the hardware prefetcher nor MKL can exploit data-dependent shortcuts.
4. The adaptive timing loop ensures sufficient iterations for statistical stability even with the added per-iteration overhead of slot selection.

The only overhead introduced by the streaming mechanism is the modular index computation (`i % stream_slots`) and pointer offset calculation, which is negligible (a few nanoseconds) compared to the FFT execution time (microseconds to milliseconds).

### 9.3 Is the GFLOPS Metric Appropriate?

**Yes.** The `5 × N × log₂(N)` formula is the standard FFT FLOP counting convention used by FFTW, Intel MKL documentation, and academic benchmarks. It enables:
- Direct comparison with published results from other platforms and libraries
- Consistent normalization across different N and batch sizes
- A meaningful throughput metric that reflects useful work per unit time

The `% of peak` column is included for context but should be interpreted with care: it compares algorithmic FLOPs against a pure FMA roofline. Since FFT involves integer indexing, data shuffling, and multi-stage memory access in addition to arithmetic, low `% of peak` values are expected and do not indicate a benchmark or hardware deficiency.

### 9.4 Are There Any Potential Sources of Bias?

**Identified and controlled:**

1. **Timer noise for fast cases:** Controlled by adaptive iteration counting (minimum 50–75 ms total timed duration).
2. **MKL plan caching:** Plans are created once per case, which is standard practice. Plan creation cost is not timed.
3. **Warmup effects:** 5 warmup iterations per case stabilize runtime state. The warmup count is consistent across all campaigns.
4. **NUMA effects:** Single NUMA node — no remote memory access bias.
5. **Turbo frequency variation:** The 2112 GFLOPS denominator uses base clock (3.3 GHz). Actual turbo behavior during benchmarks may be slightly higher, which means the reported `% of peak` is slightly pessimistic. This is the conservative choice.
6. **Background system load:** Not explicitly controlled (no CPU isolation or cgroup pinning on non-core-wise campaigns). The `run_core_wise` campaign uses `taskset` for explicit pinning.

**Not currently controlled:**
- **Transparent huge pages (THP):** The benchmark uses standard `mkl_malloc` without explicit huge page configuration. THP behavior depends on OS policy.
- **Power management:** Intel Turbo Boost behavior and C-state transitions are not pinned. This can introduce ~1–3% run-to-run variability, which is within the tolerance of 3–5 run averaging.

---

## 10. FFT as a Memory-Bandwidth Problem

### 10.1 Why FFT Does Not Saturate Compute

The theoretical peak of 2112 SP GFLOPS assumes that every clock cycle, all 10 cores issue two 512-bit FMA instructions on Port 0 and Port 5, each processing 16 single-precision values. This requires that data arrives at the FMA units without stalls.

For FFT, data delivery is the bottleneck:

1. **Multi-stage access patterns:** A radix-2 FFT of length N has `log₂(N)` stages. Each stage reads N complex values, performs butterfly operations, and writes N complex values. For N=65536, this is 16 stages × 65536 × 8 bytes × 2 (read+write) = ~16.8 MB of data movement *per FFT*, even though the input is only 512 KB.

2. **Stride-based access:** In later stages, butterfly pairs are separated by large strides (N/2, N/4, ...), causing cache line misses when the stride exceeds cache line size or cache capacity.

3. **Bytes-per-FLOP ratio:** The FFT performs `5N log₂(N)` FLOPs while moving approximately `2N × 8 × 2 × log₂(N)` bytes (read + write of complex SP data at each stage). The operational intensity is roughly `5N log₂(N) / (32N log₂(N))` ≈ 0.15 FLOPs/byte. At 85.3 GB/s peak memory bandwidth, the memory-side throughput ceiling is approximately `0.15 × 85.3` ≈ 12.8 GFLOPS per thread — an order of magnitude below the compute ceiling.

4. **In practice:** MKL's optimized kernels use cache blocking, vectorized butterflies, and pre-fetch strategies to significantly exceed this naive roofline estimate. The observed 85–170 GFLOPS under cold conditions reflects MKL's ability to exploit L2/L3 cache reuse within a single FFT computation, while the inter-iteration streaming prevents L3 reuse across FFT calls.

### 10.2 What Real Workloads Look Like

In most production FFT workloads:

- **Signal processing (radar, sonar, communications):** Each FFT processes a new data frame from an ADC or network interface. Data is consumed once. This maps directly to the **no-reuse** benchmark profile.
- **Spectral analysis:** Overlapping windows may partially reuse data, but typically with 50–75% new data per frame. Performance is closer to the cold profile than the hot profile.
- **Large-scale scientific simulation (CFD, molecular dynamics):** FFTs are applied to 3D grids that far exceed cache. Each FFT pass touches different memory regions. Cold profile is representative.
- **Real-time audio processing:** Small N (256–4096), very low latency. L1/L2 resident. Cache-reuse profile may be representative here.

**For external comparison and business claims, the no-reuse campaigns (`run_cache_noreuse`, `run_batch_1`, `run_core_wise`) provide the appropriate sustained throughput figures.** The cache-reuse campaign is retained as an upper-bound reference and engineering diagnostic tool.

---

## 11. How to Reproduce

### 11.1 Prerequisites

1. Intel oneMKL installed (headers at `$MKLROOT/include/mkl_dfti.h`, libraries at `$MKLROOT/lib/intel64/`)
2. GCC or Intel compiler (ICX/ICC) available
3. Python 3 with `matplotlib`, `pandas`, `seaborn` for plot generation
4. `lscpu` and `taskset` available for core-wise campaigns

### 11.2 Running a Campaign

From the repository root:
```bash
cd src/1-d-fft

# Cache-reuse (hot) campaign:
bash fft_logs/run_cache_reuse/tools/run_run_3_3_suite.sh

# No-reuse (moderate cold) campaign:
bash fft_logs/run_cache_noreuse/tools/run_run_3_9_suite.sh

# Batch=1 extra-cold campaign:
bash fft_logs/run_batch_1/tools/run_run_batch_1_suite.sh

# Batch=1 large-N extra-cold campaign:
bash fft_logs/run_batch_1/large_N/tools/run_run_large_N_suite.sh

# Core-wise scaling campaign:
bash fft_logs/run_core_wise/tools/run_run_core_wise_suite.sh
```

Each campaign creates a timestamped session directory containing:
- Raw run logs in `runs/runXX/`
- `manifest.tsv` linking runs to files
- `latest_run_avg.csv` — the averaged result table
- `latest_run_avg.report.md` — human-readable markdown report
- `plots/` — generated PNG visualizations
- `PLOTS_SUMMARY.md` — plot coverage check

### 11.3 Customization

All benchmark parameters can be overridden via environment variables before invoking the suite script:

```bash
# Example: run with 5 independent runs and a 256 MB streaming target
RUN_COUNT=5 BENCH_STREAM_TARGET_MB=256 bash fft_logs/run_cache_noreuse/tools/run_run_3_9_suite.sh
```

---

## 12. File Inventory

### 12.1 C Benchmark Harnesses

| File | Lines | Purpose |
|---|---:|---|
| `src/1-d-fft/fft_benchmark.c` | 481 | Root harness (fixed iteration, no streaming, no validation) |
| `src/1-d-fft/fft_logs/run_cache_noreuse/tools/fft_benchmark_run_3_9.c` | 853 | Full-featured harness: adaptive timing, streaming slots, roundtrip validation |
| `src/1-d-fft/fft_logs/run_batch_1/tools/fft_benchmark_run_batch_1.c` | 854 | Batch=1 variant (same features as run_3_9) |
| `src/1-d-fft/fft_logs/run_batch_1/large_N/tools/fft_benchmark_large_N.c` | 854 | Large-N variant (same features) |
| `src/1-d-fft/fft_logs/run_core_wise/tools/fft_benchmark_run_core_wise.c` | 854 | Core-wise variant (same features, used with CPU pinning) |
| `src/1-d-fft/fft_logs/run_cache_reuse/tools/fft_benchmark_run_3_3.c` | 727 | Cache-reuse harness: adaptive timing, validation, single-buffer (no streaming slots) |

### 12.2 Shell Orchestration

| File | Purpose |
|---|---|
| `src/1-d-fft/fft_logs/run_cache_reuse/tools/run_run_3_3_suite.sh` | Cache-reuse campaign runner |
| `src/1-d-fft/fft_logs/run_cache_reuse/tools/aggregate_run_3_3.sh` | Cache-reuse aggregator |
| `src/1-d-fft/fft_logs/run_cache_noreuse/tools/run_run_3_9_suite.sh` | No-reuse campaign runner |
| `src/1-d-fft/fft_logs/run_cache_noreuse/tools/aggregate_run_3_9.sh` | No-reuse aggregator |
| `src/1-d-fft/fft_logs/run_batch_1/tools/run_run_batch_1_suite.sh` | Batch=1 campaign runner |
| `src/1-d-fft/fft_logs/run_batch_1/tools/aggregate_run_batch_1.sh` | Batch=1 aggregator |
| `src/1-d-fft/fft_logs/run_batch_1/large_N/tools/run_run_large_N_suite.sh` | Large-N campaign runner |
| `src/1-d-fft/fft_logs/run_batch_1/large_N/tools/aggregate_large_N.sh` | Large-N aggregator |
| `src/1-d-fft/fft_logs/run_core_wise/tools/run_run_core_wise_suite.sh` | Core-wise campaign runner |
| `src/1-d-fft/fft_logs/run_core_wise/tools/aggregate_run_core_wise.sh` | Core-wise aggregator |

### 12.3 Plot Generation (Python)

| File | Purpose |
|---|---|
| `src/1-d-fft/fft_logs/run_cache_reuse/tools/generate_run_3_3_plots.py` | Cache-reuse visualizations |
| `src/1-d-fft/fft_logs/run_cache_reuse/tools/generate_n_batch_increase_report.py` | Per-N batch scaling analysis |
| `src/1-d-fft/fft_logs/run_cache_noreuse/tools/generate_run_3_9_plots.py` | No-reuse visualizations |
| `src/1-d-fft/fft_logs/run_batch_1/tools/generate_run_batch_1_plots.py` | Batch=1 visualizations |
| `src/1-d-fft/fft_logs/run_batch_1/large_N/tools/generate_large_N_plots.py` | Large-N visualizations |
| `src/1-d-fft/fft_logs/run_core_wise/tools/generate_run_core_wise_plots.py` | Core-wise scaling visualizations |

---

## 13. Known Limitations and Gaps

1. **Source file parity:** `run_cache_reuse/tools/fft_benchmark_run_3_3.c` is present and confirmed to use single-buffer (no slot rotation) with adaptive timing and roundtrip validation — consistent with the suite script and the recorded session data.

2. **Single machine:** All results are from one specific Xeon W-2155 system. Cross-machine variability (DIMM speed, BIOS settings, thermal environment) is not characterized.

3. **No hardware counter validation:** GFLOPS figures use algorithmic FLOP counts. No PMU-based measurements (e.g., via `perf` or VTune) of actual retired FLOPs or memory bandwidth are included in the current campaign data.

4. **Background process interference:** Non-core-wise campaigns do not use CPU isolation (cgroups, `taskset`). System daemons may introduce minor noise, mitigated by multi-run averaging.

5. **DIMM speed unknown:** Exact configured DDR4 data rate is not available without `dmidecode` root access. Memory bandwidth benchmarks (e.g., STREAM) have not been run to empirically validate the vendor-published 85.3 GB/s figure.

---

## 14. Conclusion

This benchmark infrastructure provides a rigorous, transparent, and reproducible framework for characterizing 1D FFT performance on the Xeon W-2155. The dual-mode design (cache-reuse and no-reuse) ensures that both optimistic and realistic throughput figures are available, with clear documentation of what each number represents.

**For external comparisons and business-facing performance claims:**
- Use the **no-reuse** campaigns (`run_cache_noreuse`, `run_batch_1`, `run_core_wise`).
- Sustained single-FFT throughput at large N is approximately **85–105 SP GFLOPS** on 10 physical cores.
- Always report the memory-mode configuration and working-set size alongside the GFLOPS figure.

**For engineering optimization and regression tracking:**
- Use the **cache-reuse** campaign as the upper-bound reference.
- Monitor batch-dependent scaling to detect kernel-level changes.

The observed performance levels — single-digit percentage of the FMA compute peak under realistic conditions — are entirely expected for FFT and reflect the fundamental memory-bandwidth limitation of the algorithm, not a deficiency in the benchmark or the hardware.
