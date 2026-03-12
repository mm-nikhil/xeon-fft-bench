# FFT Benchmark Policy (Xeon W-2155, oneMKL, SP 1D)

This document defines the standard benchmarking policy for this repository so results are reproducible, interpretable, and decision-grade.

Scope:
- 1D complex single-precision FFT (`MKL_Complex8`)
- Intel oneMKL DFTI backend
- Forward performance is the primary business metric

Related run-local implementations:
- `src/1-d-fft/fft_logs/run_3_3` (legacy/hotter behavior)
- `src/1-d-fft/fft_logs/run_3_9` (streaming/coldness introduced)
- `src/1-d-fft/fft_logs/run_batch_1` (extra-cold, batch=1 study)
- `src/1-d-fft/fft_logs/run_batch_1/large_N` (extra-cold, extended N up to 4M)

---

## 1) Why We Need a Policy

FFT throughput can vary significantly depending on memory reuse. If the benchmark repeatedly runs on the same buffers, caches can inflate measured throughput versus realistic streaming workloads.

Without an explicit policy:
- Results across runs are not comparable.
- "Peaks" may be cache artifacts rather than sustained behavior.
- Business decisions can be made from non-representative data.

Policy goal:
- Define when to use hot-cache vs cold-streaming modes.
- Define required reporting and quality checks.
- Ensure all teams interpret numbers consistently.

---

## 2) What Changed Historically

## 2.1 Legacy Behavior (`run_3_3`)

In `run_3_3`, each case allocates one `in/out` tensor and reuses those same pointers during timing loops.

Operationally:
- One input buffer initialized once.
- Warmup and timed loops call FFT repeatedly on the same buffer pair.
- No slot rotation across a pool of buffers.

Impact:
- Greater temporal locality and cache reuse.
- Useful for "upper bound under reuse," but not sustained streaming realism.

## 2.2 Streaming/Coldness Behavior (`run_3_9` and newer)

`run_3_9` added run-local coldness controls (`BENCH_STREAM_*`):
- Build a pool of input/output slots.
- Initialize each slot with distinct randomized values.
- On each timed iteration, select slot `i % stream_slots`.

Impact:
- Reduced repeated-cache benefit.
- More realistic sustained behavior for changing data.

---

## 3) Parameter Semantics (What Each Knob Does)

All knobs below are benchmark-harness knobs implemented in our C/shell code, not native oneMKL controls.

| Parameter | Type | Purpose | Practical Effect |
|---|---|---|---|
| `BENCH_STREAM_MODE` | int (0/1) | Enable slot-rotation streaming mode | `0` = single-buffer reuse, `1` = multi-slot rotation |
| `BENCH_STREAM_TARGET_MB` | float MB | Target working-set scale used to choose slot count | Larger target -> more slots -> colder behavior |
| `BENCH_STREAM_MIN_SLOTS` | int | Lower bound on slot count | Forces minimum coldness even when tensors are large |
| `BENCH_STREAM_MAX_SLOTS` | int | Upper bound on slot count | Prevents tiny-N exploding into too many slots |
| `BENCH_MAX_MEM_MB` | float MB | Global memory safety cap per case | May reduce slots below target if memory limit reached |
| `BENCH_MIN_TOTAL_MS` | float ms | Minimum total timed duration per case | Reduces timer noise by adapting iteration count |
| `BENCH_MAX_ADAPT_ITERS` | int | Hard cap for adaptive timed iterations | Safety bound against runaway loops |
| `BENCH_NRUNS` | int | Initial timed iterations before adaptation | Seed value for adaptive loop |
| `BENCH_WARMUP` | int | Warmup iterations | Stabilizes caches and runtime state before timing |
| `BENCH_VALIDATE` | int (0/1) | Enable correctness check | Computes roundtrip check prior to timed run |
| `BENCH_VALIDATE_TOL` | float | Relative RMS / max-abs tolerance target | Numerical correctness threshold |
| `BENCH_VALIDATE_STRICT` | int (0/1) | Fail case on validation failure | Prevents invalid performance rows |

---

## 4) Memory Model and Slot Math

For one case (`N`, `batch`) with complex SP:
- Element size = 8 bytes (`float2`)
- One tensor bytes = `tensor_bytes = N * batch * 8`
- One slot has input + output = `slot_bytes = 2 * tensor_bytes = 16 * N * batch`

When streaming mode is ON:
1. Compute candidate slots from target:
   - `stream_slots = ceil(target_bytes / slot_bytes)`
2. Clamp:
   - `stream_slots = max(stream_slots, stream_min_slots)`
   - `stream_slots = min(stream_slots, stream_max_slots)`
3. Enforce memory cap:
   - Cap may further reduce slots to fit `BENCH_MAX_MEM_MB`

Working set reported in logs is approximately:
- `orig_bytes + stream_slots * slot_bytes`

Where:
- `orig_bytes` is a copy used for correctness reference.

Interpretation:
- Small `N` and low batch: slot count is often max-clamped.
- Large `N`: memory cap dominates and slot count drops.

---

## 5) Timing Methodology (Exactly What Is Timed)

Timed section:
- Repeated calls to `DftiComputeForward(plan, in_slot, out_slot)` inside adaptive loop.
- Clock source: `clock_gettime(CLOCK_MONOTONIC)`.

Not timed:
- Buffer allocation and initialization.
- Plan creation/commit.
- Validation pass.

Warmup:
- Executes FFT calls before timed loop to reduce startup effects.

Adaptive iteration logic:
- If elapsed time < `BENCH_MIN_TOTAL_MS`, increase iteration count and rerun timing block.
- Reported per-call ms is `elapsed_ms / timed_iters`.

GFLOPS:
- `flops = 5 * N * log2(N) * batch`
- `gflops = flops / (avg_ms * 1e6)`

Note:
- This is algorithmic FLOP normalization for FFT comparisons, not direct hardware counter FLOPs.

---

## 6) Why We Chose Current Values

## 6.1 `run_3_9` defaults (moderate coldness)

Defaults:
- `STREAM_TARGET_MB=128`
- `STREAM_MIN_SLOTS=2`
- `STREAM_MAX_SLOTS=256`
- `MIN_TOTAL_MS=50`

Why:
- Introduce coldness while keeping campaign cost reasonable across full matrix.

Tradeoff:
- Better than legacy hot reuse, but still moderate for some batch=1 regions.

## 6.2 `run_batch_1` and `large_N` defaults (extra-cold)

Defaults:
- `STREAM_TARGET_MB=1024`
- `STREAM_MIN_SLOTS=64`
- `STREAM_MAX_SLOTS=32768`
- `MIN_TOTAL_MS=75`

Why:
- Force larger rotating working sets for sustained/more realistic behavior.
- Increase timing window for stability, especially at tiny N.

Observed behavior:
- Memory footprints around ~1 GB for many mid/large-N cases.
- For very large N, memory cap (`BENCH_MAX_MEM_MB=3072`) limits slots.

## 6.3 Slot parser bounds note

In older run-local code (`run_3_9`), `BENCH_STREAM_MIN_SLOTS` / `MAX_SLOTS` parser bounds were narrower.
In newer run-local code (`run_batch_1`), those parser bounds were widened so large values (for extra-cold studies) are accepted.

Policy requirement:
- Always verify effective values from run logs (`CONFIG|...` and printed runtime settings), not only from shell defaults.

---

## 7) Standard Benchmark Profiles

Use one of these profiles explicitly in reports.

| Profile | Intent | Recommended Knobs | Typical Use |
|---|---|---|---|
| `hot_reuse` | Upper bound under reuse | `STREAM_MODE=0`, `MIN_TOTAL_MS=50` | Kernel micro-optimizations, regression sanity |
| `cold_moderate` | Balanced realism/cost | `STREAM_MODE=1`, `TARGET_MB=128`, `MIN_SLOTS=2`, `MAX_SLOTS=256`, `MIN_TOTAL_MS=50` | Full-matrix routine comparisons |
| `cold_sustained` | Decision-grade sustained throughput | `STREAM_MODE=1`, `TARGET_MB=1024`, `MIN_SLOTS=64`, `MAX_SLOTS=32768`, `MIN_TOTAL_MS=75` | Business-facing performance claims |
| `cold_largeN` | Large-problem scaling | Same as `cold_sustained`, extended N up to 4M (or required bound) | Capacity and asymptotic scaling analysis |

Thread profiles (fixed mapping):
- `baseline_sse42_1t`: ISA `SSE4_2`, 1 thread
- `avx512_phys`: ISA `AVX512`, 10 threads
- `avx512_logical`: ISA `AVX512`, 20 threads

---

## 8) Required Reporting Contract

Every decision-grade run must include:
- Averaged CSV and markdown report
- Plot summary with coverage checks
- Run manifest with exact run logs

Required metrics:
- `avg_fwd_ms`
- `avg_fwd_sp_gflops`
- `fwd_pct_of_peak` (denominator currently 2112 SP GFLOPS base-clock model)
- `fwd_speedup_vs_sse42_1t`
- sample quality fields (`samples_ok`, `samples_expected`, `check_fail`)

Forward-only business view:
- Forward metrics are primary.
- Backward can be computed internally but excluded from final decision tables unless explicitly requested.

---

## 9) Quality Gates (Must Pass)

1. Matrix completeness:
   - Expected row count exactly matches `(num_lengths * num_batches * num_profiles)`.
2. Sample completeness:
   - `samples_ok == run_count` for every averaged row.
3. Correctness:
   - `check_fail == 0`.
4. Configuration traceability:
   - `CONFIG|...` lines present in each run log.
5. No silent memory clipping surprises:
   - Review `Slots:` and `Mem:` lines at key N points.
6. Plot contract:
   - expected plot files generated and coverage statement says PASS.

If any gate fails, the run is not decision-grade.

---

## 10) How to Choose Knobs for a New Campaign

Use this decision sequence:

1. Decide claim type:
   - "Best possible under reuse" -> `hot_reuse`
   - "Realistic sustained" -> `cold_sustained`

2. Set memory behavior first:
   - Choose `STREAM_TARGET_MB` so working set clearly exceeds cache regime for target N/batch.
   - Keep `BENCH_MAX_MEM_MB` high enough to avoid unwanted slot clipping, but safe for machine memory.

3. Stabilize timing:
   - Use `MIN_TOTAL_MS >= 75` for business-facing studies.
   - Keep `BENCH_MAX_ADAPT_ITERS` high enough not to cap small-N adaptation.

4. Fix statistical confidence:
   - Use at least 3 runs; prefer 5 for key business slides.

5. Validate numerics strictly:
   - Keep strict validation ON unless explicitly conducting a non-correctness stress test.

---

## 11) Interpretation Guidance (Avoid Common Misreads)

1. "Higher batch should equal same throughput as batch=1":
   - Not universally true.
   - Batch changes locality, plan behavior, and parallel scheduling efficiency.

2. Local peaks/dips in FFT curves:
   - Can be real due to algorithmic stage structure + cache/TLB + threading interactions.
   - Compare against memory-only baseline runs before labeling as anomaly.

3. 20-thread (HT) behavior:
   - May underperform 10-thread at some sizes under memory pressure.
   - This does not imply benchmark bug by itself.

4. Peak denominator:
   - `%peak` uses a compute-peak model (2112 SP GFLOPS base clock), not memory roofline.
   - Low `%peak` can still be expected for memory-sensitive FFT.

---

## 12) Reproducibility Checklist (Per Session)

- Record script path and git state.
- Archive manifest + all raw run logs.
- Confirm run log header prints the intended config values.
- Confirm row and check counts.
- Keep session pointer (`LATEST_SESSION.txt`, `current` symlink) updated.
- Store averaged CSV/report/plots in the run-local folder only.

---

## 13) Recommended Default for Business Decisions

For this Xeon W-2155 server and this project, policy default is:
- `cold_sustained` profile
- 3 runs minimum, 5 runs preferred for primary charts
- forward-focused reporting
- baseline + 10T + 20T comparison
- explicit quality gate pass in report

This gives a conservative, defensible estimate of sustained FFT throughput while preserving comparability across campaigns.

