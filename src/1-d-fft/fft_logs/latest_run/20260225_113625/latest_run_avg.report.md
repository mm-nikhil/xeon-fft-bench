# 1D FFT Latest Run (5-run average)

- Generated at: Wed Feb 25 11:45:46 IST 2026
- Manifest: `/home/nikhil/workspace/xeon-fft-bench/src/1-d-fft/fft_logs/latest_run/20260225_113625/manifest.tsv`
- Runs combined: 5

## Server Hardware

- CPU: Intel(R) Xeon(R) W-2155 CPU @ 3.30GHz (family 6, model 85)
- Physical cores: 10, Logical threads: 20 (HT: 2 threads/core)
- Base clock: 3.30 GHz | Max turbo (single-core max): 4.5 GHz
- AVX512 FMA units per core: 2 (Port 0 and Port 5)
- AVX512 flags: avx512f, avx512dq, avx512cd, avx512bw, avx512vl
- NUMA nodes: 1

## Peak GFLOPS (SP, AVX512)

- Formula: cores x 2 FMA/core x 16 SP floats x 2 FLOP/FMA x freq = cores x 64 x freq
- Peak at base 3.30 GHz (10 cores): 2112 SP GFLOPS
- Peak ceiling at 4.5 GHz (not sustained all-core): 2880 SP GFLOPS
- Percent-of-peak columns in this report use 2112.0 SP GFLOPS denominator.

## 1D FFT Benchmark Design

- Intel oneMKL DFTI path: `DftiCreateDescriptor`, `DftiComputeForward`, `DftiComputeBackward`.
- Thread control via `mkl_set_num_threads()` and env `OMP_NUM_THREADS`/`MKL_NUM_THREADS`.
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
| run01 | `/home/nikhil/workspace/xeon-fft-bench/src/1-d-fft/fft_logs/latest_run/20260225_113625/runs/run01/fft_benchmark_20260225_113625.log` | `/home/nikhil/workspace/xeon-fft-bench/src/1-d-fft/fft_logs/latest_run/20260225_113625/runs/run01/fft_benchmark_20260225_113625.report.md` |
| run02 | `/home/nikhil/workspace/xeon-fft-bench/src/1-d-fft/fft_logs/latest_run/20260225_113625/runs/run02/fft_benchmark_20260225_113810.log` | `/home/nikhil/workspace/xeon-fft-bench/src/1-d-fft/fft_logs/latest_run/20260225_113625/runs/run02/fft_benchmark_20260225_113810.report.md` |
| run03 | `/home/nikhil/workspace/xeon-fft-bench/src/1-d-fft/fft_logs/latest_run/20260225_113625/runs/run03/fft_benchmark_20260225_113959.log` | `/home/nikhil/workspace/xeon-fft-bench/src/1-d-fft/fft_logs/latest_run/20260225_113625/runs/run03/fft_benchmark_20260225_113959.report.md` |
| run04 | `/home/nikhil/workspace/xeon-fft-bench/src/1-d-fft/fft_logs/latest_run/20260225_113625/runs/run04/fft_benchmark_20260225_114146.log` | `/home/nikhil/workspace/xeon-fft-bench/src/1-d-fft/fft_logs/latest_run/20260225_113625/runs/run04/fft_benchmark_20260225_114146.report.md` |
| run05 | `/home/nikhil/workspace/xeon-fft-bench/src/1-d-fft/fft_logs/latest_run/20260225_113625/runs/run05/fft_benchmark_20260225_114350.log` | `/home/nikhil/workspace/xeon-fft-bench/src/1-d-fft/fft_logs/latest_run/20260225_113625/runs/run05/fft_benchmark_20260225_114350.report.md` |

## Scenario Catalog

| Profile | Description | Workload | ISA | Threads |
|---|---|---|---|---:|
| baseline_sse42_1t | MKL SSE4.2 baseline, single thread (CPU path, no AVX2/AVX512 kernels) | throughput | SSE4_2 | 1 |
| avx512_phys | MKL AVX-512, physical-core thread count | throughput | AVX512 | 10 |
| avx512_logical | MKL AVX-512, logical-core thread count (hyperthreading on) | throughput | AVX512 | 20 |

## Averaged Results

| Workload | Case | N | Batch | Threads | Profile | ISA | Avg Fwd ms | Avg Fwd SP GFLOPS | Avg Bwd ms | Avg Bwd SP GFLOPS | Fwd % of Peak | Bwd % of Peak | Fwd Speedup vs SSE4.2 1T | Bwd Speedup vs SSE4.2 1T | Samples |
|---|---|---:|---:|---:|---|---|---:|---:|---:|---:|---:|---:|---:|---:|---|
| throughput | n32_b1 | 32 | 1 | 1 | baseline_sse42_1t | SSE4_2 | 0.000050 | 16.06 | 0.000051 | 15.62 | 0.76% | 0.74% | 1.0000 | 1.0000 | 5/5 |
| throughput | n32_b1 | 32 | 1 | 10 | avx512_phys | AVX512 | 0.000166 | 4.81 | 0.000058 | 13.70 | 0.23% | 0.65% | 0.2996 | 0.8767 | 5/5 |
| throughput | n32_b1 | 32 | 1 | 20 | avx512_logical | AVX512 | 0.000060 | 13.29 | 0.000047 | 17.02 | 0.63% | 0.81% | 0.8272 | 1.0894 | 5/5 |
| throughput | n32_b4 | 32 | 4 | 1 | baseline_sse42_1t | SSE4_2 | 0.000127 | 25.12 | 0.000136 | 23.56 | 1.19% | 1.12% | 1.0000 | 1.0000 | 5/5 |
| throughput | n32_b4 | 32 | 4 | 10 | avx512_phys | AVX512 | 0.000243 | 13.19 | 0.000090 | 35.63 | 0.62% | 1.69% | 0.5251 | 1.5122 | 5/5 |
| throughput | n32_b4 | 32 | 4 | 20 | avx512_logical | AVX512 | 0.000084 | 38.10 | 0.000084 | 37.91 | 1.80% | 1.80% | 1.5167 | 1.6090 | 5/5 |
| throughput | n32_b16 | 32 | 16 | 1 | baseline_sse42_1t | SSE4_2 | 0.000460 | 27.85 | 0.000491 | 26.07 | 1.32% | 1.23% | 1.0000 | 1.0000 | 5/5 |
| throughput | n32_b16 | 32 | 16 | 10 | avx512_phys | AVX512 | 0.001753 | 7.30 | 0.000946 | 13.53 | 0.35% | 0.64% | 0.2621 | 0.5191 | 5/5 |
| throughput | n32_b16 | 32 | 16 | 20 | avx512_logical | AVX512 | 0.001634 | 7.84 | 0.001167 | 10.97 | 0.37% | 0.52% | 0.2813 | 0.4207 | 5/5 |
| throughput | n64_b1 | 64 | 1 | 1 | baseline_sse42_1t | SSE4_2 | 0.000103 | 18.71 | 0.000108 | 17.78 | 0.89% | 0.84% | 1.0000 | 1.0000 | 5/5 |
| throughput | n64_b1 | 64 | 1 | 10 | avx512_phys | AVX512 | 0.000044 | 43.84 | 0.000044 | 43.24 | 2.08% | 2.05% | 2.3425 | 2.4324 | 5/5 |
| throughput | n64_b1 | 64 | 1 | 20 | avx512_logical | AVX512 | 0.000044 | 43.64 | 0.000043 | 44.44 | 2.07% | 2.10% | 2.3318 | 2.5000 | 5/5 |
| throughput | n64_b4 | 64 | 4 | 1 | baseline_sse42_1t | SSE4_2 | 0.000339 | 22.63 | 0.000342 | 22.44 | 1.07% | 1.06% | 1.0000 | 1.0000 | 5/5 |
| throughput | n64_b4 | 64 | 4 | 10 | avx512_phys | AVX512 | 0.000105 | 73.28 | 0.000111 | 69.19 | 3.47% | 3.28% | 3.2385 | 3.0829 | 5/5 |
| throughput | n64_b4 | 64 | 4 | 20 | avx512_logical | AVX512 | 0.000163 | 47.00 | 0.000111 | 69.44 | 2.23% | 3.29% | 2.0771 | 3.0940 | 5/5 |
| throughput | n64_b16 | 64 | 16 | 1 | baseline_sse42_1t | SSE4_2 | 0.001363 | 22.54 | 0.001396 | 22.00 | 1.07% | 1.04% | 1.0000 | 1.0000 | 5/5 |
| throughput | n64_b16 | 64 | 16 | 10 | avx512_phys | AVX512 | 0.001538 | 19.97 | 0.001205 | 25.49 | 0.95% | 1.21% | 0.8861 | 1.1588 | 5/5 |
| throughput | n64_b16 | 64 | 16 | 20 | avx512_logical | AVX512 | 0.001929 | 15.92 | 0.001218 | 25.23 | 0.75% | 1.19% | 0.7064 | 1.1468 | 5/5 |
| throughput | n128_b1 | 128 | 1 | 1 | baseline_sse42_1t | SSE4_2 | 0.000185 | 24.16 | 0.000190 | 23.60 | 1.14% | 1.12% | 1.0000 | 1.0000 | 5/5 |
| throughput | n128_b1 | 128 | 1 | 10 | avx512_phys | AVX512 | 0.000068 | 66.27 | 0.000067 | 66.67 | 3.14% | 3.16% | 2.7426 | 2.8244 | 5/5 |
| throughput | n128_b1 | 128 | 1 | 20 | avx512_logical | AVX512 | 0.000068 | 65.88 | 0.000069 | 65.31 | 3.12% | 3.09% | 2.7265 | 2.7668 | 5/5 |
| throughput | n128_b4 | 128 | 4 | 1 | baseline_sse42_1t | SSE4_2 | 0.000704 | 25.46 | 0.000700 | 25.60 | 1.21% | 1.21% | 1.0000 | 1.0000 | 5/5 |
| throughput | n128_b4 | 128 | 4 | 10 | avx512_phys | AVX512 | 0.000738 | 24.27 | 0.000909 | 19.71 | 1.15% | 0.93% | 0.9531 | 0.7697 | 5/5 |
| throughput | n128_b4 | 128 | 4 | 20 | avx512_logical | AVX512 | 0.000781 | 22.95 | 0.000765 | 23.42 | 1.09% | 1.11% | 0.9014 | 0.9148 | 5/5 |
| throughput | n128_b16 | 128 | 16 | 1 | baseline_sse42_1t | SSE4_2 | 0.002715 | 26.40 | 0.002803 | 25.57 | 1.25% | 1.21% | 1.0000 | 1.0000 | 5/5 |
| throughput | n128_b16 | 128 | 16 | 10 | avx512_phys | AVX512 | 0.002396 | 29.91 | 0.001295 | 55.37 | 1.42% | 2.62% | 1.1330 | 2.1655 | 5/5 |
| throughput | n128_b16 | 128 | 16 | 20 | avx512_logical | AVX512 | 0.002739 | 26.17 | 0.001319 | 54.33 | 1.24% | 2.57% | 0.9911 | 2.1248 | 5/5 |
| throughput | n256_b1 | 256 | 1 | 1 | baseline_sse42_1t | SSE4_2 | 0.000382 | 26.81 | 0.000422 | 24.29 | 1.27% | 1.15% | 1.0000 | 1.0000 | 5/5 |
| throughput | n256_b1 | 256 | 1 | 10 | avx512_phys | AVX512 | 0.000162 | 63.05 | 0.000159 | 64.48 | 2.99% | 3.05% | 2.3522 | 2.6549 | 5/5 |
| throughput | n256_b1 | 256 | 1 | 20 | avx512_logical | AVX512 | 0.000163 | 62.90 | 0.000158 | 64.65 | 2.98% | 3.06% | 2.3464 | 2.6616 | 5/5 |
| throughput | n256_b4 | 256 | 4 | 1 | baseline_sse42_1t | SSE4_2 | 0.001474 | 27.78 | 0.001492 | 27.46 | 1.32% | 1.30% | 1.0000 | 1.0000 | 5/5 |
| throughput | n256_b4 | 256 | 4 | 10 | avx512_phys | AVX512 | 0.000943 | 43.44 | 0.000958 | 42.77 | 2.06% | 2.03% | 1.5635 | 1.5579 | 5/5 |
| throughput | n256_b4 | 256 | 4 | 20 | avx512_logical | AVX512 | 0.001024 | 40.01 | 0.000960 | 42.68 | 1.89% | 2.02% | 1.4401 | 1.5543 | 5/5 |
| throughput | n256_b16 | 256 | 16 | 1 | baseline_sse42_1t | SSE4_2 | 0.005867 | 27.93 | 0.005937 | 27.60 | 1.32% | 1.31% | 1.0000 | 1.0000 | 5/5 |
| throughput | n256_b16 | 256 | 16 | 10 | avx512_phys | AVX512 | 0.002978 | 55.02 | 0.001529 | 107.13 | 2.60% | 5.07% | 1.9700 | 3.8819 | 5/5 |
| throughput | n256_b16 | 256 | 16 | 20 | avx512_logical | AVX512 | 0.003517 | 46.58 | 0.001925 | 85.13 | 2.21% | 4.03% | 1.6679 | 3.0848 | 5/5 |
| throughput | n512_b1 | 512 | 1 | 1 | baseline_sse42_1t | SSE4_2 | 0.000793 | 29.07 | 0.000788 | 29.24 | 1.38% | 1.38% | 1.0000 | 1.0000 | 5/5 |
| throughput | n512_b1 | 512 | 1 | 10 | avx512_phys | AVX512 | 0.000283 | 81.53 | 0.000291 | 79.07 | 3.86% | 3.74% | 2.8047 | 2.7042 | 5/5 |
| throughput | n512_b1 | 512 | 1 | 20 | avx512_logical | AVX512 | 0.000397 | 58.09 | 0.000354 | 65.05 | 2.75% | 3.08% | 1.9985 | 2.2247 | 5/5 |
| throughput | n512_b4 | 512 | 4 | 1 | baseline_sse42_1t | SSE4_2 | 0.003143 | 29.32 | 0.003216 | 28.66 | 1.39% | 1.36% | 1.0000 | 1.0000 | 5/5 |
| throughput | n512_b4 | 512 | 4 | 10 | avx512_phys | AVX512 | 0.001465 | 62.92 | 0.001366 | 67.46 | 2.98% | 3.19% | 2.1458 | 2.3540 | 5/5 |
| throughput | n512_b4 | 512 | 4 | 20 | avx512_logical | AVX512 | 0.001760 | 52.37 | 0.001709 | 53.91 | 2.48% | 2.55% | 1.7861 | 1.8814 | 5/5 |
| throughput | n512_b16 | 512 | 16 | 1 | baseline_sse42_1t | SSE4_2 | 0.012740 | 28.94 | 0.012746 | 28.92 | 1.37% | 1.37% | 1.0000 | 1.0000 | 5/5 |
| throughput | n512_b16 | 512 | 16 | 10 | avx512_phys | AVX512 | 0.002463 | 149.66 | 0.002065 | 178.48 | 7.09% | 8.45% | 5.1722 | 6.1714 | 5/5 |
| throughput | n512_b16 | 512 | 16 | 20 | avx512_logical | AVX512 | 0.002856 | 129.08 | 0.002505 | 147.17 | 6.11% | 6.97% | 4.4609 | 5.0888 | 5/5 |
| throughput | n1024_b1 | 1024 | 1 | 1 | baseline_sse42_1t | SSE4_2 | 0.001696 | 30.19 | 0.001658 | 30.87 | 1.43% | 1.46% | 1.0000 | 1.0000 | 5/5 |
| throughput | n1024_b1 | 1024 | 1 | 10 | avx512_phys | AVX512 | 0.000690 | 74.22 | 0.000598 | 85.56 | 3.51% | 4.05% | 2.4590 | 2.7714 | 5/5 |
| throughput | n1024_b1 | 1024 | 1 | 20 | avx512_logical | AVX512 | 0.000783 | 65.41 | 0.000788 | 64.94 | 3.10% | 3.07% | 2.1668 | 2.1035 | 5/5 |
| throughput | n1024_b4 | 1024 | 4 | 1 | baseline_sse42_1t | SSE4_2 | 0.007016 | 29.19 | 0.006631 | 30.89 | 1.38% | 1.46% | 1.0000 | 1.0000 | 5/5 |
| throughput | n1024_b4 | 1024 | 4 | 10 | avx512_phys | AVX512 | 0.001866 | 109.77 | 0.001894 | 108.13 | 5.20% | 5.12% | 3.7605 | 3.5010 | 5/5 |
| throughput | n1024_b4 | 1024 | 4 | 20 | avx512_logical | AVX512 | 0.002274 | 90.05 | 0.002430 | 84.27 | 4.26% | 3.99% | 3.0849 | 2.7283 | 5/5 |
| throughput | n1024_b16 | 1024 | 16 | 1 | baseline_sse42_1t | SSE4_2 | 0.026112 | 31.37 | 0.024868 | 32.94 | 1.49% | 1.56% | 1.0000 | 1.0000 | 5/5 |
| throughput | n1024_b16 | 1024 | 16 | 10 | avx512_phys | AVX512 | 0.003967 | 206.50 | 0.002968 | 275.97 | 9.78% | 13.07% | 6.5823 | 8.3777 | 5/5 |
| throughput | n1024_b16 | 1024 | 16 | 20 | avx512_logical | AVX512 | 0.003650 | 224.41 | 0.003239 | 252.89 | 10.63% | 11.97% | 7.1531 | 7.6769 | 5/5 |
| throughput | n2048_b1 | 2048 | 1 | 1 | baseline_sse42_1t | SSE4_2 | 0.003482 | 32.35 | 0.003312 | 34.01 | 1.53% | 1.61% | 1.0000 | 1.0000 | 5/5 |
| throughput | n2048_b1 | 2048 | 1 | 10 | avx512_phys | AVX512 | 0.001588 | 70.94 | 0.001537 | 73.30 | 3.36% | 3.47% | 2.1932 | 2.1557 | 5/5 |
| throughput | n2048_b1 | 2048 | 1 | 20 | avx512_logical | AVX512 | 0.001948 | 57.84 | 0.001914 | 58.85 | 2.74% | 2.79% | 1.7880 | 1.7306 | 5/5 |
| throughput | n2048_b4 | 2048 | 4 | 1 | baseline_sse42_1t | SSE4_2 | 0.013247 | 34.01 | 0.013225 | 34.07 | 1.61% | 1.61% | 1.0000 | 1.0000 | 5/5 |
| throughput | n2048_b4 | 2048 | 4 | 10 | avx512_phys | AVX512 | 0.004141 | 108.81 | 0.002774 | 162.41 | 5.15% | 7.69% | 3.1991 | 4.7672 | 5/5 |
| throughput | n2048_b4 | 2048 | 4 | 20 | avx512_logical | AVX512 | 0.003756 | 119.94 | 0.003563 | 126.46 | 5.68% | 5.99% | 3.5265 | 3.7120 | 5/5 |
| throughput | n2048_b16 | 2048 | 16 | 1 | baseline_sse42_1t | SSE4_2 | 0.052986 | 34.01 | 0.052686 | 34.21 | 1.61% | 1.62% | 1.0000 | 1.0000 | 5/5 |
| throughput | n2048_b16 | 2048 | 16 | 10 | avx512_phys | AVX512 | 0.005370 | 335.61 | 0.005034 | 358.03 | 15.89% | 16.95% | 9.8670 | 10.4664 | 5/5 |
| throughput | n2048_b16 | 2048 | 16 | 20 | avx512_logical | AVX512 | 0.004811 | 374.59 | 0.004760 | 378.65 | 17.74% | 17.93% | 11.0130 | 11.0694 | 5/5 |
| throughput | n4096_b1 | 4096 | 1 | 1 | baseline_sse42_1t | SSE4_2 | 0.007821 | 31.42 | 0.007786 | 31.56 | 1.49% | 1.49% | 1.0000 | 1.0000 | 5/5 |
| throughput | n4096_b1 | 4096 | 1 | 10 | avx512_phys | AVX512 | 0.003692 | 66.56 | 0.003844 | 63.94 | 3.15% | 3.03% | 2.1180 | 2.0257 | 5/5 |
| throughput | n4096_b1 | 4096 | 1 | 20 | avx512_logical | AVX512 | 0.004359 | 56.37 | 0.004326 | 56.81 | 2.67% | 2.69% | 1.7940 | 1.8000 | 5/5 |
| throughput | n4096_b4 | 4096 | 4 | 1 | baseline_sse42_1t | SSE4_2 | 0.030822 | 31.89 | 0.030254 | 32.49 | 1.51% | 1.54% | 1.0000 | 1.0000 | 5/5 |
| throughput | n4096_b4 | 4096 | 4 | 10 | avx512_phys | AVX512 | 0.004714 | 208.54 | 0.004720 | 208.25 | 9.87% | 9.86% | 6.5385 | 6.4091 | 5/5 |
| throughput | n4096_b4 | 4096 | 4 | 20 | avx512_logical | AVX512 | 0.005732 | 171.51 | 0.005842 | 168.26 | 8.12% | 7.97% | 5.3776 | 5.1783 | 5/5 |
| throughput | n4096_b16 | 4096 | 16 | 1 | baseline_sse42_1t | SSE4_2 | 0.131442 | 29.92 | 0.130493 | 30.13 | 1.42% | 1.43% | 1.0000 | 1.0000 | 5/5 |
| throughput | n4096_b16 | 4096 | 16 | 10 | avx512_phys | AVX512 | 0.009465 | 415.46 | 0.009191 | 427.82 | 19.67% | 20.26% | 13.8877 | 14.1976 | 5/5 |
| throughput | n4096_b16 | 4096 | 16 | 20 | avx512_logical | AVX512 | 0.008171 | 481.21 | 0.008268 | 475.60 | 22.78% | 22.52% | 16.0856 | 15.7833 | 5/5 |
| throughput | n8192_b1 | 8192 | 1 | 1 | baseline_sse42_1t | SSE4_2 | 0.017306 | 30.77 | 0.016743 | 31.80 | 1.46% | 1.51% | 1.0000 | 1.0000 | 5/5 |
| throughput | n8192_b1 | 8192 | 1 | 10 | avx512_phys | AVX512 | 0.009355 | 56.92 | 0.009035 | 58.93 | 2.70% | 2.79% | 1.8500 | 1.8531 | 5/5 |
| throughput | n8192_b1 | 8192 | 1 | 20 | avx512_logical | AVX512 | 0.009210 | 57.82 | 0.009416 | 56.55 | 2.74% | 2.68% | 1.8791 | 1.7781 | 5/5 |
| throughput | n8192_b4 | 8192 | 4 | 1 | baseline_sse42_1t | SSE4_2 | 0.066044 | 32.25 | 0.066119 | 32.21 | 1.53% | 1.53% | 1.0000 | 1.0000 | 5/5 |
| throughput | n8192_b4 | 8192 | 4 | 10 | avx512_phys | AVX512 | 0.036398 | 58.52 | 0.034482 | 61.77 | 2.77% | 2.92% | 1.8145 | 1.9175 | 5/5 |
| throughput | n8192_b4 | 8192 | 4 | 20 | avx512_logical | AVX512 | 0.148646 | 14.33 | 1.548233 | 1.38 | 0.68% | 0.07% | 0.4443 | 0.0427 | 5/5 |
| throughput | n8192_b16 | 8192 | 16 | 1 | baseline_sse42_1t | SSE4_2 | 0.308867 | 27.58 | 0.321572 | 26.49 | 1.31% | 1.25% | 1.0000 | 1.0000 | 5/5 |
| throughput | n8192_b16 | 8192 | 16 | 10 | avx512_phys | AVX512 | 0.020513 | 415.33 | 0.020734 | 410.91 | 19.67% | 19.46% | 15.0570 | 15.5095 | 5/5 |
| throughput | n8192_b16 | 8192 | 16 | 20 | avx512_logical | AVX512 | 0.016714 | 509.73 | 0.058405 | 145.87 | 24.14% | 6.91% | 18.4795 | 5.5059 | 5/5 |
| throughput | n16384_b1 | 16384 | 1 | 1 | baseline_sse42_1t | SSE4_2 | 0.035686 | 32.14 | 0.035436 | 32.37 | 1.52% | 1.53% | 1.0000 | 1.0000 | 5/5 |
| throughput | n16384_b1 | 16384 | 1 | 10 | avx512_phys | AVX512 | 0.013300 | 86.23 | 0.013214 | 86.79 | 4.08% | 4.11% | 2.6831 | 2.6817 | 5/5 |
| throughput | n16384_b1 | 16384 | 1 | 20 | avx512_logical | AVX512 | 0.012412 | 92.40 | 0.012533 | 91.51 | 4.38% | 4.33% | 2.8752 | 2.8275 | 5/5 |
| throughput | n16384_b4 | 16384 | 4 | 1 | baseline_sse42_1t | SSE4_2 | 0.154995 | 29.60 | 0.158970 | 28.86 | 1.40% | 1.37% | 1.0000 | 1.0000 | 5/5 |
| throughput | n16384_b4 | 16384 | 4 | 10 | avx512_phys | AVX512 | 0.102324 | 44.83 | 0.102520 | 44.75 | 2.12% | 2.12% | 1.5147 | 1.5506 | 5/5 |
| throughput | n16384_b4 | 16384 | 4 | 20 | avx512_logical | AVX512 | 0.161747 | 28.36 | 0.327961 | 13.99 | 1.34% | 0.66% | 0.9583 | 0.4847 | 5/5 |
| throughput | n16384_b16 | 16384 | 16 | 1 | baseline_sse42_1t | SSE4_2 | 0.721113 | 25.45 | 0.690953 | 26.56 | 1.20% | 1.26% | 1.0000 | 1.0000 | 5/5 |
| throughput | n16384_b16 | 16384 | 16 | 10 | avx512_phys | AVX512 | 0.047954 | 382.66 | 0.049474 | 370.90 | 18.12% | 17.56% | 15.0376 | 13.9659 | 5/5 |
| throughput | n16384_b16 | 16384 | 16 | 20 | avx512_logical | AVX512 | 0.037180 | 493.55 | 0.037001 | 495.93 | 23.37% | 23.48% | 19.3953 | 18.6738 | 5/5 |
| throughput | n32768_b1 | 32768 | 1 | 1 | baseline_sse42_1t | SSE4_2 | 0.079442 | 30.94 | 0.077941 | 31.53 | 1.46% | 1.49% | 1.0000 | 1.0000 | 5/5 |
| throughput | n32768_b1 | 32768 | 1 | 10 | avx512_phys | AVX512 | 0.020698 | 118.74 | 0.020361 | 120.70 | 5.62% | 5.71% | 3.8382 | 3.8279 | 5/5 |
| throughput | n32768_b1 | 32768 | 1 | 20 | avx512_logical | AVX512 | 0.017805 | 138.03 | 0.017766 | 138.33 | 6.54% | 6.55% | 4.4617 | 4.3872 | 5/5 |
| throughput | n32768_b4 | 32768 | 4 | 1 | baseline_sse42_1t | SSE4_2 | 0.400168 | 24.57 | 0.384453 | 25.57 | 1.16% | 1.21% | 1.0000 | 1.0000 | 5/5 |
| throughput | n32768_b4 | 32768 | 4 | 10 | avx512_phys | AVX512 | 0.251218 | 39.13 | 0.247845 | 39.66 | 1.85% | 1.88% | 1.5929 | 1.5512 | 5/5 |
| throughput | n32768_b4 | 32768 | 4 | 20 | avx512_logical | AVX512 | 0.546318 | 17.99 | 0.378755 | 25.95 | 0.85% | 1.23% | 0.7325 | 1.0150 | 5/5 |
| throughput | n32768_b16 | 32768 | 16 | 1 | baseline_sse42_1t | SSE4_2 | 1.805516 | 21.78 | 1.651589 | 23.81 | 1.03% | 1.13% | 1.0000 | 1.0000 | 5/5 |
| throughput | n32768_b16 | 32768 | 16 | 10 | avx512_phys | AVX512 | 0.133409 | 294.75 | 0.138304 | 284.31 | 13.96% | 13.46% | 13.5337 | 11.9417 | 5/5 |
| throughput | n32768_b16 | 32768 | 16 | 20 | avx512_logical | AVX512 | 0.118383 | 332.16 | 0.134756 | 291.80 | 15.73% | 13.82% | 15.2515 | 12.2561 | 5/5 |
| throughput | n65536_b1 | 65536 | 1 | 1 | baseline_sse42_1t | SSE4_2 | 0.204075 | 25.69 | 0.204284 | 25.66 | 1.22% | 1.22% | 1.0000 | 1.0000 | 5/5 |
| throughput | n65536_b1 | 65536 | 1 | 10 | avx512_phys | AVX512 | 0.042419 | 123.60 | 0.043180 | 121.42 | 5.85% | 5.75% | 4.8109 | 4.7310 | 5/5 |
| throughput | n65536_b1 | 65536 | 1 | 20 | avx512_logical | AVX512 | 0.034779 | 150.75 | 0.034973 | 149.91 | 7.14% | 7.10% | 5.8677 | 5.8412 | 5/5 |
| throughput | n65536_b4 | 65536 | 4 | 1 | baseline_sse42_1t | SSE4_2 | 0.898197 | 23.35 | 0.844661 | 24.83 | 1.11% | 1.18% | 1.0000 | 1.0000 | 5/5 |
| throughput | n65536_b4 | 65536 | 4 | 10 | avx512_phys | AVX512 | 0.573544 | 36.56 | 0.568709 | 36.88 | 1.73% | 1.75% | 1.5660 | 1.4852 | 5/5 |
| throughput | n65536_b4 | 65536 | 4 | 20 | avx512_logical | AVX512 | 0.153680 | 136.46 | 0.168835 | 124.21 | 6.46% | 5.88% | 5.8446 | 5.0029 | 5/5 |
| throughput | n65536_b16 | 65536 | 16 | 1 | baseline_sse42_1t | SSE4_2 | 5.046402 | 16.62 | 5.143180 | 16.31 | 0.79% | 0.77% | 1.0000 | 1.0000 | 5/5 |
| throughput | n65536_b16 | 65536 | 16 | 10 | avx512_phys | AVX512 | 0.466160 | 179.95 | 0.461514 | 181.76 | 8.52% | 8.61% | 10.8255 | 11.1441 | 5/5 |
| throughput | n65536_b16 | 65536 | 16 | 20 | avx512_logical | AVX512 | 0.709295 | 118.27 | 0.744321 | 112.70 | 5.60% | 5.34% | 7.1147 | 6.9099 | 5/5 |
| throughput | n131072_b1 | 131072 | 1 | 1 | baseline_sse42_1t | SSE4_2 | 0.487723 | 22.84 | 0.484741 | 22.98 | 1.08% | 1.09% | 1.0000 | 1.0000 | 5/5 |
| throughput | n131072_b1 | 131072 | 1 | 10 | avx512_phys | AVX512 | 0.074691 | 149.16 | 0.073162 | 152.28 | 7.06% | 7.21% | 6.5298 | 6.6255 | 5/5 |
| throughput | n131072_b1 | 131072 | 1 | 20 | avx512_logical | AVX512 | 0.076547 | 145.55 | 0.091136 | 122.25 | 6.89% | 5.79% | 6.3716 | 5.3189 | 5/5 |
| throughput | n131072_b4 | 131072 | 4 | 1 | baseline_sse42_1t | SSE4_2 | 2.382239 | 18.71 | 2.495117 | 17.86 | 0.89% | 0.85% | 1.0000 | 1.0000 | 5/5 |
| throughput | n131072_b4 | 131072 | 4 | 10 | avx512_phys | AVX512 | 0.312927 | 142.41 | 0.314335 | 141.77 | 6.74% | 6.71% | 7.6128 | 7.9378 | 5/5 |
| throughput | n131072_b4 | 131072 | 4 | 20 | avx512_logical | AVX512 | 0.308469 | 144.47 | 0.665954 | 66.92 | 6.84% | 3.17% | 7.7228 | 3.7467 | 5/5 |
| throughput | n131072_b16 | 131072 | 16 | 1 | baseline_sse42_1t | SSE4_2 | 16.944529 | 10.52 | 17.298852 | 10.30 | 0.50% | 0.49% | 1.0000 | 1.0000 | 5/5 |
| throughput | n131072_b16 | 131072 | 16 | 10 | avx512_phys | AVX512 | 1.749523 | 101.89 | 1.800210 | 99.02 | 4.82% | 4.69% | 9.6852 | 9.6094 | 5/5 |
| throughput | n131072_b16 | 131072 | 16 | 20 | avx512_logical | AVX512 | 3.103562 | 57.44 | 2.276322 | 78.31 | 2.72% | 3.71% | 5.4597 | 7.5995 | 5/5 |
| throughput | n262144_b1 | 262144 | 1 | 1 | baseline_sse42_1t | SSE4_2 | 1.139708 | 20.70 | 1.133978 | 20.81 | 0.98% | 0.99% | 1.0000 | 1.0000 | 5/5 |
| throughput | n262144_b1 | 262144 | 1 | 10 | avx512_phys | AVX512 | 0.157664 | 149.64 | 0.155503 | 151.72 | 7.09% | 7.18% | 7.2287 | 7.2923 | 5/5 |
| throughput | n262144_b1 | 262144 | 1 | 20 | avx512_logical | AVX512 | 0.146999 | 160.50 | 0.146135 | 161.45 | 7.60% | 7.64% | 7.7532 | 7.7598 | 5/5 |
| throughput | n262144_b4 | 262144 | 4 | 1 | baseline_sse42_1t | SSE4_2 | 6.653879 | 14.18 | 6.531203 | 14.45 | 0.67% | 0.68% | 1.0000 | 1.0000 | 5/5 |
| throughput | n262144_b4 | 262144 | 4 | 10 | avx512_phys | AVX512 | 0.733817 | 128.60 | 0.744223 | 126.81 | 6.09% | 6.00% | 9.0675 | 8.7759 | 5/5 |
| throughput | n262144_b4 | 262144 | 4 | 20 | avx512_logical | AVX512 | 0.664286 | 142.06 | 0.804087 | 117.37 | 6.73% | 5.56% | 10.0166 | 8.1225 | 5/5 |
| throughput | n262144_b16 | 262144 | 16 | 1 | baseline_sse42_1t | SSE4_2 | 33.806018 | 11.17 | 33.757299 | 11.18 | 0.53% | 0.53% | 1.0000 | 1.0000 | 5/5 |
| throughput | n262144_b16 | 262144 | 16 | 10 | avx512_phys | AVX512 | 3.881864 | 97.24 | 4.007179 | 94.20 | 4.60% | 4.46% | 8.7087 | 8.4242 | 5/5 |
| throughput | n262144_b16 | 262144 | 16 | 20 | avx512_logical | AVX512 | 5.700071 | 66.23 | 6.033638 | 62.56 | 3.14% | 2.96% | 5.9308 | 5.5948 | 5/5 |
| throughput | n524288_b1 | 524288 | 1 | 1 | baseline_sse42_1t | SSE4_2 | 2.561742 | 19.44 | 2.558958 | 19.46 | 0.92% | 0.92% | 1.0000 | 1.0000 | 5/5 |
| throughput | n524288_b1 | 524288 | 1 | 10 | avx512_phys | AVX512 | 0.330718 | 150.60 | 0.324050 | 153.70 | 7.13% | 7.28% | 7.7460 | 7.8968 | 5/5 |
| throughput | n524288_b1 | 524288 | 1 | 20 | avx512_logical | AVX512 | 0.399790 | 124.58 | 0.269021 | 185.14 | 5.90% | 8.77% | 6.4077 | 9.5121 | 5/5 |
| throughput | n524288_b4 | 524288 | 4 | 1 | baseline_sse42_1t | SSE4_2 | 13.324926 | 14.95 | 13.119867 | 15.19 | 0.71% | 0.72% | 1.0000 | 1.0000 | 5/5 |
| throughput | n524288_b4 | 524288 | 4 | 10 | avx512_phys | AVX512 | 1.710000 | 116.51 | 1.710260 | 116.49 | 5.52% | 5.52% | 7.7924 | 7.6713 | 5/5 |
| throughput | n524288_b4 | 524288 | 4 | 20 | avx512_logical | AVX512 | 2.311645 | 86.19 | 2.653011 | 75.10 | 4.08% | 3.56% | 5.7643 | 4.9453 | 5/5 |
| throughput | n524288_b16 | 524288 | 16 | 1 | baseline_sse42_1t | SSE4_2 | 55.006706 | 14.49 | 55.364426 | 14.39 | 0.69% | 0.68% | 1.0000 | 1.0000 | 5/5 |
| throughput | n524288_b16 | 524288 | 16 | 10 | avx512_phys | AVX512 | 7.276320 | 109.52 | 7.308225 | 109.04 | 5.19% | 5.16% | 7.5597 | 7.5756 | 5/5 |
| throughput | n524288_b16 | 524288 | 16 | 20 | avx512_logical | AVX512 | 10.916647 | 73.00 | 10.789563 | 73.86 | 3.46% | 3.50% | 5.0388 | 5.1313 | 5/5 |
| throughput | n1048576_b1 | 1048576 | 1 | 1 | baseline_sse42_1t | SSE4_2 | 6.793659 | 15.43 | 6.798297 | 15.42 | 0.73% | 0.73% | 1.0000 | 1.0000 | 5/5 |
| throughput | n1048576_b1 | 1048576 | 1 | 10 | avx512_phys | AVX512 | 0.633764 | 165.45 | 0.629675 | 166.53 | 7.83% | 7.88% | 10.7195 | 10.7965 | 5/5 |
| throughput | n1048576_b1 | 1048576 | 1 | 20 | avx512_logical | AVX512 | 0.777221 | 134.91 | 1.227450 | 85.43 | 6.39% | 4.04% | 8.7410 | 5.5386 | 5/5 |
| throughput | n1048576_b4 | 1048576 | 4 | 1 | baseline_sse42_1t | SSE4_2 | 33.591773 | 12.49 | 33.839033 | 12.39 | 0.59% | 0.59% | 1.0000 | 1.0000 | 5/5 |
| throughput | n1048576_b4 | 1048576 | 4 | 10 | avx512_phys | AVX512 | 3.901697 | 107.50 | 3.801653 | 110.33 | 5.09% | 5.22% | 8.6095 | 8.9011 | 5/5 |
| throughput | n1048576_b4 | 1048576 | 4 | 20 | avx512_logical | AVX512 | 6.393700 | 65.60 | 5.048981 | 83.07 | 3.11% | 3.93% | 5.2539 | 6.7022 | 5/5 |
| throughput | n1048576_b16 | 1048576 | 16 | 1 | baseline_sse42_1t | SSE4_2 | 132.899409 | 12.62 | 134.520998 | 12.47 | 0.60% | 0.59% | 1.0000 | 1.0000 | 5/5 |
| throughput | n1048576_b16 | 1048576 | 16 | 10 | avx512_phys | AVX512 | 15.369534 | 109.16 | 15.289387 | 109.73 | 5.17% | 5.20% | 8.6469 | 8.7983 | 5/5 |
| throughput | n1048576_b16 | 1048576 | 16 | 20 | avx512_logical | AVX512 | 26.748043 | 62.72 | 31.316175 | 53.57 | 2.97% | 2.54% | 4.9686 | 4.2956 | 5/5 |
| throughput | n2097152_b1 | 2097152 | 1 | 1 | baseline_sse42_1t | SSE4_2 | 15.883922 | 13.86 | 15.950324 | 13.81 | 0.66% | 0.65% | 1.0000 | 1.0000 | 5/5 |
| throughput | n2097152_b1 | 2097152 | 1 | 10 | avx512_phys | AVX512 | 1.478598 | 148.93 | 1.468442 | 149.96 | 7.05% | 7.10% | 10.7426 | 10.8621 | 5/5 |
| throughput | n2097152_b1 | 2097152 | 1 | 20 | avx512_logical | AVX512 | 2.377264 | 92.63 | 2.219812 | 99.20 | 4.39% | 4.70% | 6.6816 | 7.1854 | 5/5 |
| throughput | n2097152_b4 | 2097152 | 4 | 1 | baseline_sse42_1t | SSE4_2 | 69.326650 | 12.71 | 69.892593 | 12.60 | 0.60% | 0.60% | 1.0000 | 1.0000 | 5/5 |
| throughput | n2097152_b4 | 2097152 | 4 | 10 | avx512_phys | AVX512 | 8.242591 | 106.86 | 8.270536 | 106.50 | 5.06% | 5.04% | 8.4108 | 8.4508 | 5/5 |
| throughput | n2097152_b4 | 2097152 | 4 | 20 | avx512_logical | AVX512 | 16.054426 | 54.86 | 13.085774 | 67.31 | 2.60% | 3.19% | 4.3182 | 5.3411 | 5/5 |
| throughput | n2097152_b16 | 2097152 | 16 | 1 | baseline_sse42_1t | SSE4_2 | 268.813459 | 13.11 | 292.520691 | 12.04 | 0.62% | 0.57% | 1.0000 | 1.0000 | 5/5 |
| throughput | n2097152_b16 | 2097152 | 16 | 10 | avx512_phys | AVX512 | 32.327017 | 108.99 | 41.405187 | 85.09 | 5.16% | 4.03% | 8.3154 | 7.0648 | 5/5 |
| throughput | n2097152_b16 | 2097152 | 16 | 20 | avx512_logical | AVX512 | 72.214486 | 48.79 | 50.714491 | 69.47 | 2.31% | 3.29% | 3.7224 | 5.7680 | 5/5 |
| throughput | n4194304_b1 | 4194304 | 1 | 1 | baseline_sse42_1t | SSE4_2 | 34.269549 | 13.46 | 34.730335 | 13.28 | 0.64% | 0.63% | 1.0000 | 1.0000 | 5/5 |
| throughput | n4194304_b1 | 4194304 | 1 | 10 | avx512_phys | AVX512 | 4.680561 | 98.57 | 4.703705 | 98.09 | 4.67% | 4.64% | 7.3217 | 7.3836 | 5/5 |
| throughput | n4194304_b1 | 4194304 | 1 | 20 | avx512_logical | AVX512 | 5.638793 | 81.82 | 6.561817 | 70.31 | 3.87% | 3.33% | 6.0775 | 5.2928 | 5/5 |
| throughput | n4194304_b4 | 4194304 | 4 | 1 | baseline_sse42_1t | SSE4_2 | 143.760973 | 12.84 | 144.726114 | 12.75 | 0.61% | 0.60% | 1.0000 | 1.0000 | 5/5 |
| throughput | n4194304_b4 | 4194304 | 4 | 10 | avx512_phys | AVX512 | 18.937677 | 97.45 | 18.942777 | 97.42 | 4.61% | 4.61% | 7.5913 | 7.6402 | 5/5 |
| throughput | n4194304_b4 | 4194304 | 4 | 20 | avx512_logical | AVX512 | 29.074492 | 63.47 | 29.263900 | 63.06 | 3.01% | 2.99% | 4.9446 | 4.9456 | 5/5 |
| throughput | n4194304_b16 | 4194304 | 16 | 1 | baseline_sse42_1t | SSE4_2 | 553.159195 | 13.35 | 582.345273 | 12.68 | 0.63% | 0.60% | 1.0000 | 1.0000 | 5/5 |
| throughput | n4194304_b16 | 4194304 | 16 | 10 | avx512_phys | AVX512 | 98.311784 | 75.09 | 104.365326 | 70.73 | 3.56% | 3.35% | 5.6266 | 5.5799 | 5/5 |
| throughput | n4194304_b16 | 4194304 | 16 | 20 | avx512_logical | AVX512 | 109.948581 | 67.14 | 120.847323 | 61.09 | 3.18% | 2.89% | 5.0311 | 4.8189 | 5/5 |

## Plotting Data

- CSV: `/home/nikhil/workspace/xeon-fft-bench/src/1-d-fft/fft_logs/latest_run/20260225_113625/latest_run_avg.csv`

## VTune Snapshot (Representative AVX512 Cases)

- VTune root: `/home/nikhil/workspace/xeon-fft-bench/src/1-d-fft/fft_logs/latest_run/20260225_113625/vtune/results/20260225_114546`

| Status | Analysis | Threads | Path/Log |
|---|---|---:|---|
| UNSUPPORTED | hpc-performance | 10 | `/home/nikhil/workspace/xeon-fft-bench/src/1-d-fft/fft_logs/latest_run/20260225_113625/vtune/results/20260225_114546/t10/hpc-performance_10t.collect.log` |
| OK | hotspots | 10 | `/home/nikhil/workspace/xeon-fft-bench/src/1-d-fft/fft_logs/latest_run/20260225_113625/vtune/results/20260225_114546/t10/hotspots_10t` |
| OK | threading | 10 | `/home/nikhil/workspace/xeon-fft-bench/src/1-d-fft/fft_logs/latest_run/20260225_113625/vtune/results/20260225_114546/t10/threading_10t` |
| UNSUPPORTED | hpc-performance | 20 | `/home/nikhil/workspace/xeon-fft-bench/src/1-d-fft/fft_logs/latest_run/20260225_113625/vtune/results/20260225_114546/t20/hpc-performance_20t.collect.log` |
| OK | hotspots | 20 | `/home/nikhil/workspace/xeon-fft-bench/src/1-d-fft/fft_logs/latest_run/20260225_113625/vtune/results/20260225_114546/t20/hotspots_20t` |
| OK | threading | 20 | `/home/nikhil/workspace/xeon-fft-bench/src/1-d-fft/fft_logs/latest_run/20260225_113625/vtune/results/20260225_114546/t20/threading_20t` |

| Threads | Case | Fwd GFLOPS | Bwd GFLOPS | Peak GFLOPS | Fwd % Peak | Bwd % Peak |
|---:|---|---:|---:|---:|---:|---:|
| 10 | n8192_b16 | 332.414 | 333.771 | 2112.000000 | 15.7393% | 15.8036% |
| 20 | n8192_b16 | 510.36 | 501.227 | 2112.000000 | 24.1648% | 23.7323% |
