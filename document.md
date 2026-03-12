# Xeon FFT Benchmark Dossier (Official)

## 1. Purpose and Scope
This document is the official technical and business-facing record for 1D FFT benchmarking on the Xeon server used by this repository.

It covers:
- Full hardware/software configuration used for benchmarking,
- Benchmark methodology and metric definitions,
- Active benchmark pipeline files and their responsibilities,
- Reproducible run workflow,
- Consolidated interpretation of current benchmark results.

It intentionally excludes legacy script families under `src/1-d-fft/fft_logs/latest_run/*` and VTune-focused legacy pipeline scripts from main scope.

## 2. Evidence and Confidence Policy
Each hardware claim is tagged as one of:
- `Verified (local command)`: directly measured on this machine.
- `Verified (vendor source)`: published by Intel ARK.
- `Estimated (third-party, not vendor-published)`: best available external estimate, explicitly not vendor-confirmed.

Capture date for local facts: 2026-03-10.

## 3. Hardware and System Configuration (Server Under Test)

### 3.1 CPU
| Field | Value | Confidence | Evidence |
|---|---:|---|---|
| CPU model | Intel(R) Xeon(R) W-2155 CPU @ 3.30GHz | Verified (local command) | `lscpu`, `/proc/cpuinfo` |
| CPU family / model / stepping | 6 / 85 / 4 | Verified (local command) | `lscpu`, `/proc/cpuinfo` |
| Sockets | 1 | Verified (local command) | `lscpu` |
| Physical cores | 10 | Verified (local command) | `lscpu` |
| Logical CPUs | 20 | Verified (local command) | `lscpu` |
| Threads per core | 2 (SMT enabled) | Verified (local command) | `lscpu -e` |
| Base frequency | 3.30 GHz | Verified (local command) | `lscpu` |
| Max turbo frequency | 4.50 GHz | Verified (local command) | `lscpu` |
| L1d / L1i / L2 / L3 | 32K / 32K / 1024K / 14080K | Verified (local command) | `lscpu` |
| AVX-512 flags | `avx512f avx512dq avx512cd avx512bw avx512vl` | Verified (local command) | `/proc/cpuinfo` |
| AVX-512 FMA units per core | 2 | Verified (vendor source) | Intel ARK |
| Lithography | 14 nm | Verified (vendor source) | Intel ARK |
| TDP | 140 W | Verified (vendor source) | Intel ARK |
| Die size | 484 mm^2 | Estimated (third-party, not vendor-published) | technical.city |

### 3.2 Memory
| Field | Value | Confidence | Evidence |
|---|---:|---|---|
| Installed memory | 64 GB (4 x 16 GB) | Verified (local command) | `/sys/devices/system/edac/mc/*/dimm*/size` |
| DIMM type | Unbuffered DDR4 | Verified (local command) | `/sys/devices/system/edac/mc/*/dimm*/dimm_mem_type` |
| IMC topology | 2 controllers (`Skylake Socket#0 IMC#0/1`) | Verified (local command) | `/sys/devices/system/edac/mc/*/mc_name` |
| OS-visible RAM | 62 GiB class (`MemTotal: 65351312 kB`) | Verified (local command) | `/proc/meminfo`, `free -h` |
| Memory channels supported | 4 | Verified (vendor source) | Intel ARK |
| Max memory bandwidth | 85.3 GB/s | Verified (vendor source) | Intel ARK |

Note: exact configured DIMM data rate (e.g., 2400/2666 MT/s) is not available without privileged `dmidecode` access on this host.

### 3.3 Platform and OS
| Field | Value | Confidence | Evidence |
|---|---:|---|---|
| OS | Red Hat Enterprise Linux 8.10 (Ootpa) | Verified (local command) | `/etc/os-release` |
| Kernel | `4.18.0-553.30.1.el8_10.x86_64` | Verified (local command) | `uname -a` |
| Architecture | x86_64 | Verified (local command) | `uname -a`, `lscpu` |
| NUMA nodes | 1 | Verified (local command) | `lscpu` |

### 3.4 Theoretical SP Peak Model Used in Reports
Formula used across current reports:

`Peak_SP_GFLOPS = cores x FMA_units_per_core x 16 lanes x 2 FLOP/FMA x frequency_GHz`

For this host:
- Base-clock denominator used in reports: `10 x 2 x 16 x 2 x 3.3 = 2112 SP GFLOPS`.
- Single-core turbo ceiling reference: `10 x 2 x 16 x 2 x 4.5 = 2880 SP GFLOPS` (not sustained all-core).

Confidence:
- Core count/frequency values: Verified (local command).
- FMA units per core: Verified (vendor source).

### 3.5 oneMKL Runtime
| Field | Value | Confidence | Evidence |
|---|---:|---|---|
| oneMKL version macros | `__INTEL_MKL__=2025`, `__INTEL_MKL_MINOR__=0`, `__INTEL_MKL_UPDATE__=3` | Verified (local command) | `/home/nikhil/.local/include/mkl_version.h` |
| Runtime linkage | `libmkl_rt.so.2` | Verified (local command) | `ldd` on benchmark binaries |

## 4. Benchmark Methodology

### 4.1 Core Execution Model
All active 1D harnesses use Intel oneMKL DFTI on `MKL_Complex8` (single-precision complex):
- Descriptor setup via `DftiCreateDescriptor`, `DftiSetValue`, `DftiCommitDescriptor`.
- Forward path: `DftiComputeForward`.
- Backward path: `DftiComputeBackward`.
- Thread count controlled by `mkl_set_num_threads()` plus `OMP_NUM_THREADS` and `MKL_NUM_THREADS`.

### 4.2 Timing Model
- Wall-clock source: `clock_gettime(CLOCK_MONOTONIC)`.
- Warmup loop controlled by `BENCH_WARMUP`.
- Timed loop:
  - Base harness (`fft_benchmark.c`): fixed `BENCH_NRUNS` iteration timing.
- Current run-local harnesses (`run_cache_noreuse`/`run_3_9`, `run_batch_1`, `large_N`, `run_core_wise`): adaptive iteration timing until `BENCH_MIN_TOTAL_MS` or `BENCH_MAX_ADAPT_ITERS`.

### 4.3 FLOP Normalization and Throughput Metrics
Per-case algorithmic FLOP model used in code and aggregators:

`FLOPs = 5 x N x log2(N) x batch`

Per-direction throughput:

`SP_GFLOPS = FLOPs / (avg_ms x 1e6)`

Report families commonly expose:
- `avg_fwd_ms`, `avg_fwd_sp_gflops`,
- `avg_bwd_ms`, `avg_bwd_sp_gflops` (kept in raw/aggregate pipelines even when forward-only views are emphasized),
- `fwd_pct_of_peak` and related speedup columns.

### 4.4 Correctness Controls
Modern run-local harnesses include explicit round-trip correctness checks:
- `CHECK|...|PASS/FAIL` lines.
- Relative RMS and max-absolute error against `BENCH_VALIDATE_TOL`.
- Optional strict fail-stop with `BENCH_VALIDATE_STRICT=1`.

Aggregation scripts propagate check quality (`check_ok`, `check_fail`, `quality`).

### 4.5 Memory Behavior Controls (Streaming vs Reuse)
- `run_cache_reuse` (previously `run_3_3`) profile is legacy/hotter style (no stream-slot controls present in its suite script; source file currently missing in workspace).
- `run_cache_noreuse` (previously `run_3_9`) and newer introduce stream-slot rotation (`BENCH_STREAM_*`) to reduce repeated-cache reuse.
- `run_batch_1`, `large_N`, and `run_core_wise` increase coldness using larger target working-set knobs.

Primary controls:
- `BENCH_STREAM_MODE`,
- `BENCH_STREAM_TARGET_MB`,
- `BENCH_STREAM_MIN_SLOTS`, `BENCH_STREAM_MAX_SLOTS`,
- global cap `BENCH_MAX_MEM_MB`.

Runtime policy knobs used in drivers:
- `KMP_AFFINITY=scatter,granularity=fine`,
- `KMP_BLOCKTIME=200`,
- `MKL_DYNAMIC=FALSE`.

## 5. Active Benchmark Pipelines and File Inventory

### 5.1 C Harnesses
| File | Role |
|---|---|
| `src/1-d-fft/fft_benchmark.c` | Root generic 1D FFT harness (fixed-run timing, throughput/thread/batch workloads). |
| `src/1-d-fft/fft_logs/run_cache_noreuse/tools/fft_benchmark_run_3_9.c` | Run-local harness with adaptive timing, validation, and streaming controls. |
| `src/1-d-fft/fft_logs/run_batch_1/tools/fft_benchmark_run_batch_1.c` | Extra-cold batch=1 study harness (same feature set as newer family). |
| `src/1-d-fft/fft_logs/run_batch_1/large_N/tools/fft_benchmark_large_N.c` | Extended-length (up to 4,194,304) harness variant. |
| `src/1-d-fft/fft_logs/run_core_wise/tools/fft_benchmark_run_core_wise.c` | Core-wise sweep harness used with pinned CPU sets. |
| `src/1-d-fft/fft_logs/run_cache_reuse/tools/fft_benchmark_run_3_3.c` | Referenced by `run_cache_reuse` suite script but currently missing in this workspace (repository gap). |

### 5.2 Shell Orchestration and Aggregation (Non-Legacy)
| File | Role |
|---|---|
| `src/1-d-fft/run_fft_benchmarks.sh` | Root benchmark campaign driver (profile execution + per-run markdown). |
| `src/1-d-fft/aggregate_fft_runs.sh` | Root multi-run aggregator for generic manifest/log format. |
| `src/1-d-fft/fft_logs/run_cache_reuse/tools/run_run_3_3_suite.sh` | `run_cache_reuse` campaign runner. |
| `src/1-d-fft/fft_logs/run_cache_reuse/tools/aggregate_run_3_3.sh` | `run_cache_reuse` campaign aggregator (forward-focused quality fields). |
| `src/1-d-fft/fft_logs/run_cache_noreuse/tools/run_run_3_9_suite.sh` | `run_cache_noreuse` campaign runner. |
| `src/1-d-fft/fft_logs/run_cache_noreuse/tools/aggregate_run_3_9.sh` | `run_cache_noreuse` campaign aggregator. |
| `src/1-d-fft/fft_logs/run_batch_1/tools/run_run_batch_1_suite.sh` | Batch=1 extra-cold campaign runner. |
| `src/1-d-fft/fft_logs/run_batch_1/tools/aggregate_run_batch_1.sh` | Batch=1 extra-cold aggregator. |
| `src/1-d-fft/fft_logs/run_batch_1/large_N/tools/run_run_large_N_suite.sh` | Large-N extra-cold campaign runner. |
| `src/1-d-fft/fft_logs/run_batch_1/large_N/tools/aggregate_large_N.sh` | Large-N extra-cold aggregator. |
| `src/1-d-fft/fft_logs/run_core_wise/tools/run_run_core_wise_suite.sh` | Core/thread-mode sweep runner with `taskset` CPU pinning and topology parsing. |
| `src/1-d-fft/fft_logs/run_core_wise/tools/aggregate_run_core_wise.sh` | Core-wise aggregator with baseline `c01/t01` speedup model. |

### 5.3 Plot/Report Python (Non-Legacy)
| File | Role |
|---|---|
| `src/1-d-fft/fft_logs/run_cache_reuse/tools/generate_run_3_3_plots.py` | Standardized `run_cache_reuse` plot generation + coverage summary. |
| `src/1-d-fft/fft_logs/run_cache_reuse/tools/generate_n_batch_increase_report.py` | Per-`N` batch increase markdown and companion plots. |
| `src/1-d-fft/fft_logs/run_cache_noreuse/tools/generate_run_3_9_plots.py` | `run_cache_noreuse` master/n-wise/line-by-batch plots with strict matrix checks. |
| `src/1-d-fft/fft_logs/run_batch_1/tools/generate_run_batch_1_plots.py` | Batch=1 master/n-wise/line plot pipeline. |
| `src/1-d-fft/fft_logs/run_batch_1/large_N/tools/generate_large_N_plots.py` | Large-N batch=1 plotting pipeline. |
| `src/1-d-fft/fft_logs/run_core_wise/tools/generate_run_core_wise_plots.py` | Core-wise plotting pipeline across cores and thread modes. |

## 6. Reproducibility Workflow (Current Pipelines)

### 6.1 Common Preconditions
1. oneMKL headers and runtime available (`mkl_dfti.h`, `libmkl_rt`).
2. CPU topology tools available (`lscpu`, `taskset` for core-wise campaign).
3. Run from repo root: `/home/nikhil/workspace/xeon-fft-bench`.

### 6.2 Campaign Commands
From repository root:
1. `cd src/1-d-fft`
2. Run one family suite:
   - `run_cache_reuse` (previously `run_3_3`): `bash fft_logs/run_cache_reuse/tools/run_run_3_3_suite.sh`
   - `run_cache_noreuse` (previously `run_3_9`): `bash fft_logs/run_cache_noreuse/tools/run_run_3_9_suite.sh`
   - `run_batch_1`: `bash fft_logs/run_batch_1/tools/run_run_batch_1_suite.sh`
   - `run_batch_1/large_N`: `bash fft_logs/run_batch_1/large_N/tools/run_run_large_N_suite.sh`
   - `run_core_wise`: `bash fft_logs/run_core_wise/tools/run_run_core_wise_suite.sh`

Each suite generates:
- Session directory (`timestamp`),
- `runs/runXX` logs/reports,
- `manifest.tsv`,
- `latest_run_avg.csv`, `latest_run_avg.report.md`,
- `plots/` and `PLOTS_SUMMARY.md`.

### 6.3 Data Quality Checks to Enforce
For decision-grade interpretation:
- `quality=ok` rows only,
- `check_fail=0`,
- no missing samples (`samples_ok == samples_expected`),
- matrix coverage must match each plotting script's expected dimensions.

## 7. Consolidated Results (Latest Sessions)

### 7.1 Sessions Used
| Family | Session |
|---|---|
| `run_cache_reuse` | `src/1-d-fft/fft_logs/run_cache_reuse/20260303_132905` |
| `run_cache_noreuse` | `src/1-d-fft/fft_logs/run_cache_noreuse/20260309_110958` |
| `run_batch_1` | `src/1-d-fft/fft_logs/run_batch_1/20260309_141257` |
| `run_batch_1/large_N` | `src/1-d-fft/fft_logs/run_batch_1/large_N/20260309_144844` |
| `run_core_wise` | `src/1-d-fft/fft_logs/run_core_wise/20260310_113330` |

### 7.2 Matrix Sizes and Quality
| Family | Rows in `latest_run_avg.csv` | Incomplete rows |
|---|---:|---:|
| `run_cache_reuse` | 288 | 0 |
| `run_cache_noreuse` | 288 | 0 |
| `run_batch_1` | 48 | 0 |
| `run_batch_1/large_N` | 66 | 0 |
| `run_core_wise` | 440 | 0 |

### 7.3 Best Forward Throughput by Family (from averaged CSV)
| Family | Best case | Best Fwd GFLOPS | % of 2112 peak |
|---|---|---:|---:|
| `run_cache_reuse` | `n1024_b256`, AVX512 10T | 745.42 | 35.29% |
| `run_cache_noreuse` | `n8192_b150`, AVX512 10T | 170.42 | 8.07% |
| `run_batch_1` | `n65536_b1`, AVX512 10T | 85.86 | 4.07% |
| `run_batch_1/large_N` | `n1048576_b1`, AVX512 10T | 97.48 | 4.62% |
| `run_core_wise` | `n1048576_b1`, 10 cores x 1 thread/core | 105.49 | 4.99% |

### 7.4 Interpretation for Business and Audit Context
1. Cross-family comparability must be contextualized.
   - `run_cache_reuse` reflects hotter reuse behavior (legacy profile) and should be treated as a best-case cache-friendly upper bound.
   - `run_cache_noreuse` introduces moderate streaming/coldness and yields lower but more sustained values.
   - `run_batch_1` and `run_batch_1/large_N` are extra-cold, batch=1 studies intended for conservative sustained characterization.
   - `run_core_wise` maps scaling behavior under explicit CPU affinity and thread-mode permutations.

2. Sustained forward throughput under cold, batch=1 conditions on this host is generally in the ~65-105 GFLOPS band for larger N ranges represented in current sessions.

3. Efficiency versus base-clock compute peak (`2112 SP GFLOPS`) is single-digit percent in sustained/cold regimes, consistent with memory-traffic and FFT overhead effects relative to pure FMA roofline models.

4. Small-N caveat:
   - Low transform sizes are overhead-dominated; many configurations can appear similar because launch/synchronization/control overheads dominate arithmetic.
   - Core-wise data confirms this effect at low-to-mid N, while larger N shows clearer differences and more informative scaling behavior.

5. SMT effect in core-wise study:
   - Across all length/core pairs in the current `run_core_wise` dataset, average `tpc=2 / tpc=1` forward ratio is slightly above 1.0, but behavior is case-dependent; SMT is not uniformly beneficial and can regress some points.

## 8. Explicit Exclusions
The following are intentionally excluded from this official mainline dossier scope:
- `src/1-d-fft/fft_logs/latest_run/*` plotting script families,
- VTune-focused legacy pipeline scripts and reports,
- GPU comparison artifacts.

## 9. Risks, Gaps, and Controls
1. Repository gap: `run_cache_reuse/tools/fft_benchmark_run_3_3.c` is referenced by suite scripts but currently absent in this workspace.
   - Control: preserve this fact in audit documentation and avoid claiming source-level parity checks for that file until restored.

2. Die size uncertainty:
   - Intel does not publish W-2155 die size on ARK.
   - The 484 mm^2 value is retained only as `Estimated (third-party, not vendor-published)`.

3. Peak denominator assumptions:
   - `% peak` metrics are denominator-sensitive.
   - This dossier standardizes on 2112 SP GFLOPS base-clock denominator for consistency with current scripts.

## 10. References

### 10.1 Vendor / External
- Intel ARK, Xeon W-2155 specifications:
  - https://www.intel.com/content/www/us/en/products/sku/125042/intel-xeon-w2155-processor-13-75m-cache-3-30-ghz/specifications.html
- Technical City, Xeon W-2155 (die-size estimate source):
  - https://technical.city/en/cpu/Xeon-W-2155

### 10.2 Local Evidence Sources
- CPU/OS topology: `lscpu`, `lscpu -e=CPU,CORE,SOCKET,NODE,ONLINE`, `/proc/cpuinfo`, `/etc/os-release`, `uname -a`.
- Memory topology: `/sys/devices/system/edac/mc/*`, `/proc/meminfo`, `free -h`.
- oneMKL version: `/home/nikhil/.local/include/mkl_version.h`.
- Runtime linkage: `ldd` on run-local benchmark binaries.
- Benchmark datasets: `latest_run_avg.csv` files under current run-family session directories listed in Section 7.1.

## 11. Cache Reuse vs No-Reuse Analysis (End-of-Document Summary)

This section formalizes the practical observation across:
- `run_cache_reuse` (previously `run_3_3`),
- `run_cache_noreuse` (previously `run_3_9`),
- `run_batch_1`,
- `run_core_wise`.

### 11.1 How Memory Is Passed and Structured in Each Mode
Common data model in all harnesses:
- Type: `MKL_Complex8` (8 bytes per complex sample).
- Logical shape per case: `N x batch`.
- DFTI batching model: `DFTI_NUMBER_OF_TRANSFORMS=batch`, `DFTI_INPUT_DISTANCE=N`, `DFTI_OUTPUT_DISTANCE=N`.

Derived sizes:
- `tensor_bytes = N x batch x 8`.
- `slot_bytes = in + out = 2 x tensor_bytes = 16 x N x batch`.

Cache-reuse mode (`run_cache_reuse`):
- Uses a single input tensor and single output tensor for timed loops.
- The same input/output pointers are reused on every FFT call.
- Effective benchmark memory footprint is small (for `N=65536, batch=1`, reported ~1.0 MB).

No-reuse / streaming modes (`run_cache_noreuse`, `run_batch_1`, `run_core_wise`):
- Allocate pools (`in_pool`, `out_pool`) with multiple slots.
- Timed iteration `i` uses slot `i % stream_slots` (pointer rotation across slots).
- This prevents immediate cache reuse of the exact same data region.
- Working-set size is controlled by:
  - `BENCH_STREAM_MODE`,
  - `BENCH_STREAM_TARGET_MB`,
  - `BENCH_STREAM_MIN_SLOTS`,
  - `BENCH_STREAM_MAX_SLOTS`,
  - `BENCH_MAX_MEM_MB`.

Concrete example (`N=65536, batch=1`, 10-thread AVX512 profile):
- `run_cache_reuse`: ~1.0 MB reported `avg_mem_mb` working footprint.
- `run_cache_noreuse`: ~128.5 MB reported `avg_mem_mb` working footprint (moderate streaming).
- `run_batch_1`: ~1024.5 MB reported `avg_mem_mb` working footprint (extra-cold).
- `run_core_wise` (10c/10t): ~1024.5 MB reported `avg_mem_mb` working footprint (extra-cold, pinned).

Important clarification: these MB values are benchmark working-memory footprint indicators, not DRAM bandwidth (GB/s) measurements.

### 11.2 Quantitative Effect of Reuse vs No-Reuse
Best-case family peaks (Section 7.3) show large differences:
- `run_cache_reuse`: 745.42 GFLOPS.
- `run_cache_noreuse`: 170.42 GFLOPS.
- `run_batch_1`: 85.86 GFLOPS.
- `run_core_wise`: 105.49 GFLOPS.

Peak ratio observations:
- `run_cache_reuse` vs `run_cache_noreuse`: ~4.37x.
- `run_cache_reuse` vs `run_batch_1`: ~8.68x.
- `run_cache_reuse` vs `run_core_wise`: ~7.07x.

More apples-to-apples comparison at the same case (`N=65536, batch=1, ~10 threads`):
- `run_cache_reuse`: 137.51 GFLOPS.
- `run_cache_noreuse`: 89.84 GFLOPS.
- `run_batch_1`: 85.86 GFLOPS.
- `run_core_wise` (10c/10t): 88.48 GFLOPS.

Drop versus reuse baseline for this same case:
- `run_cache_noreuse`: ~34.7% lower.
- `run_batch_1`: ~37.6% lower.
- `run_core_wise` (10c/10t): ~35.7% lower.

### 11.3 Why FFT Appears Memory-Bandwidth Sensitive in Practice
1. FFT has multi-stage data movement (`log2(N)` stages), not a single-pass compute kernel.
2. Even with AVX512, realized throughput depends heavily on movement locality and cache residency.
3. When working sets exceed cache-friendly regimes (128 MB to 1 GB+ in no-reuse modes), data is forced to DRAM more consistently and throughput drops.
4. Therefore, high reuse measurements are useful as an engineering upper bound, but no-reuse measurements are better for realistic sustained behavior claims.

### 11.4 How No-Reuse Is Controlled by Knobs in This Repo
Current no-reuse control strategy:
- Enable streaming mode (`BENCH_STREAM_MODE=1`).
- Set target working set (`BENCH_STREAM_TARGET_MB`).
- Enforce slot bounds (`BENCH_STREAM_MIN_SLOTS`, `BENCH_STREAM_MAX_SLOTS`).
- Respect memory safety (`BENCH_MAX_MEM_MB`).
- Stabilize timing with adaptive loops (`BENCH_MIN_TOTAL_MS`, `BENCH_MAX_ADAPT_ITERS`).

Family defaults used in current campaigns:
- `run_cache_noreuse`: `TARGET_MB=128`, `MIN_SLOTS=2`, `MAX_SLOTS=256` (moderate coldness).
- `run_batch_1` and `run_core_wise`: `TARGET_MB=1024`, `MIN_SLOTS=64`, `MAX_SLOTS=32768` (extra-cold sustained profile).

### 11.5 Practical Benchmarking Guidance
- Use `run_cache_reuse` to understand idealized upper-bound behavior under pointer reuse.
- Use `run_cache_noreuse`, `run_batch_1`, and `run_core_wise` for realistic sustained/business-facing claims.
- For external comparisons, prefer no-reuse families and always report the memory-mode configuration alongside GFLOPS.

---
Document status: `Official Draft for Repository Use`.
