# 1D FFT Latest Run (5-run average)

- Generated at: Wed Feb 25 11:35:09 IST 2026
- Manifest: `/home/nikhil/workspace/xeon-fft-bench/src/1-d-fft/fft_logs/latest_run/smoke_113508/manifest.tsv`
- Runs combined: 1

## Server Hardware

- CPU: Intel(R) Xeon(R) W-2155 CPU @ 3.30GHz (family 6, model 85)
- Physical cores: 10, Logical threads: 20 (HT: 2 threads/core)
- Base clock: 3.30 GHz | Max turbo (single-core max): 4.5 GHz
- AVX512 FMA units per core: 2 (Port 0 and Port 5)
- AVX512 flags: avx512f,avx512dq avx512cd,avx512bw avx512vl
- NUMA nodes: 1

## Peak GFLOPS (SP, AVX512)

- Formula: cores x 2 FMA/core x 16 SP floats x 2 FLOP/FMA x freq = cores x 64 x freq
- Peak at base 3.30 GHz (10 cores): 2112 SP GFLOPS
- Peak ceiling at 4.5 GHz (not sustained all-core): 2880 SP GFLOPS
- Percent-of-peak columns in this report use 2112.0 SP GFLOPS denominator.

## 1D FFT Benchmark Design

- Intel oneMKL DFTI path: `DftiCreateDescriptor`, `DftiComputeForward`, `DftiComputeBackward`.
- Thread control via `mkl_set_num_threads()` and env `OMP_NUM_THREADS`/\`MKL_NUM_THREADS\`.
- Runtime policy: `KMP_AFFINITY=scatter,granularity=fine`, `MKL_DYNAMIC=FALSE`.
- FLOP model: `5 * N * log2(N) * batch`.

## Findings So Far (Interpretation)

- W-2155 AVX512 peak denominator for this machine is 2112 SP GFLOPS at base clock.
- Example calibration: 511.85 GFLOPS corresponds to 24.24% of 2112.
- If 1056 is used as denominator, the same point becomes 48.47%; that is a different peak model.
- Tiny-N rows can be overhead-dominated; use larger N/batch rows for business comparisons.

## Source References

- Intel ARK W-2155 (includes AVX-512 FMA unit count): https://www.intel.com/content/www/us/en/products/sku/125042/intel-xeon-w2155-processor-13-75m-cache-3-30-ghz/specifications.html
- uops.info SKX AVX-512 FMA behavior: https://www.uops.info/html-instr/VFMADD231PS_ZMM_ZMM_ZMM.html

## Run Files

| Run | Log | Report |
|---|---|---|
| run01 | `/home/nikhil/workspace/xeon-fft-bench/src/1-d-fft/fft_logs/latest_run/smoke_113508/runs/run01/fft_benchmark_20260225_113509.log` | `/home/nikhil/workspace/xeon-fft-bench/src/1-d-fft/fft_logs/latest_run/smoke_113508/runs/run01/fft_benchmark_20260225_113509.report.md` |

## Scenario Catalog

| Profile | Description | Workload | ISA | Threads |
|---|---|---|---|---:|
| baseline_sse42_1t | MKL SSE4.2 baseline, single thread (CPU path, no AVX2/AVX512 kernels) | throughput | SSE4_2 | 1 |
| avx512_phys | MKL AVX-512, physical-core thread count | throughput | AVX512 | 10 |
| avx512_logical | MKL AVX-512, logical-core thread count (hyperthreading on) | throughput | AVX512 | 20 |

## Averaged Results

| Workload | Case | N | Batch | Threads | Profile | ISA | Avg Fwd ms | Avg Fwd SP GFLOPS | Avg Bwd ms | Avg Bwd SP GFLOPS | Fwd % of Peak | Bwd % of Peak | Fwd Speedup vs SSE4.2 1T | Bwd Speedup vs SSE4.2 1T | Samples |
|---|---|---:|---:|---:|---|---|---:|---:|---:|---:|---:|---:|---:|---:|---|
| throughput | n32_b1 | 32 | 1 | 1 | baseline_sse42_1t | SSE4_2 | 0.009361 | 0.09 | 0.004784 | 0.17 | 0.00% | 0.01% | 1.0000 | 1.0000 | 1/1 |
| throughput | n32_b1 | 32 | 1 | 10 | avx512_phys | AVX512 | 0.009925 | 0.08 | 0.001670 | 0.48 | 0.00% | 0.02% | 0.9432 | 2.8647 | 1/1 |
| throughput | n32_b1 | 32 | 1 | 20 | avx512_logical | AVX512 | 0.006858 | 0.12 | 0.001305 | 0.61 | 0.01% | 0.03% | 1.3650 | 3.6659 | 1/1 |
| throughput | n64_b1 | 64 | 1 | 1 | baseline_sse42_1t | SSE4_2 | 0.007432 | 0.26 | 0.001678 | 1.14 | 0.01% | 0.05% | 1.0000 | 1.0000 | 1/1 |
| throughput | n64_b1 | 64 | 1 | 10 | avx512_phys | AVX512 | 0.005115 | 0.38 | 0.000381 | 5.04 | 0.02% | 0.24% | 1.4530 | 4.4042 | 1/1 |
| throughput | n64_b1 | 64 | 1 | 20 | avx512_logical | AVX512 | 0.003442 | 0.56 | 0.000375 | 5.12 | 0.03% | 0.24% | 2.1592 | 4.4747 | 1/1 |

## Plotting Data

- CSV: `/home/nikhil/workspace/xeon-fft-bench/src/1-d-fft/fft_logs/latest_run/smoke_113508/latest_run_avg.csv`

## VTune Snapshot (Representative AVX512 Cases)

- VTune root: `/home/nikhil/workspace/xeon-fft-bench/src/1-d-fft/fft_logs/latest_run/smoke_113508/vtune/results/20260225_113509`

| Status | Analysis | Threads | Path/Log |
|---|---|---:|---|
| OK | hotspots | 10 | `/home/nikhil/workspace/xeon-fft-bench/src/1-d-fft/fft_logs/latest_run/smoke_113508/vtune/results/20260225_113509/t10/hotspots_10t` |
| OK | hotspots | 20 | `/home/nikhil/workspace/xeon-fft-bench/src/1-d-fft/fft_logs/latest_run/smoke_113508/vtune/results/20260225_113509/t20/hotspots_20t` |

| Threads | Case | Fwd GFLOPS | Bwd GFLOPS | Peak GFLOPS | Fwd % Peak | Bwd % Peak |
|---:|---|---:|---:|---:|---:|---:|
| 10 | n8192_b16 | 17.3316 | 234.003 | 2112.000000 | 0.8206% | 11.0797% |
| 20 | n8192_b16 | 13.0843 | 312.285 | 2112.000000 | 0.6195% | 14.7862% |
