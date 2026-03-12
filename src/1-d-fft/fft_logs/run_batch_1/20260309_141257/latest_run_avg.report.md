# 1D FFT run_batch_1 (5-run average, forward-focused, extra-cold streaming)

- Generated at: Mon Mar  9 14:17:07 IST 2026
- Manifest: `/home/nikhil/workspace/xeon-fft-bench/src/1-d-fft/fft_logs/run_batch_1/20260309_141257/manifest.tsv`
- Runs combined: 5
- Forward-only reporting: yes
- Matrix scope: batch fixed to 1

## Server Hardware

- CPU: Intel(R) Xeon(R) W-2155 CPU @ 3.30GHz (family 6, model 85)
- Physical cores: 10, Logical threads: 20 (HT: 2 threads/core)
- Base clock: 3.30 GHz | Max turbo: 4.5 GHz
- NUMA nodes: 1

## Peak Model

- SP peak formula: cores x 2 FMA/core x 16 lanes x 2 FLOP/FMA x freq
- Report denominator for %peak: 2112.0 SP GFLOPS

## Correctness Summary

- CHECK lines counted: 240
- CHECK failures: 0
- Missing CHECK samples: 0
- Strict validation required at runtime: yes

## Data Quality

- Averaged rows: 48
- Rows with incomplete quality: 0
- Expected samples per row: 5

## Run Files

| Run | Log | Report |
|---|---|---|
| run01 | `/home/nikhil/workspace/xeon-fft-bench/src/1-d-fft/fft_logs/run_batch_1/20260309_141257/runs/run01/fft_benchmark_20260309_141258.log` | `/home/nikhil/workspace/xeon-fft-bench/src/1-d-fft/fft_logs/run_batch_1/20260309_141257/runs/run01/fft_benchmark_20260309_141258.report.md` |
| run02 | `/home/nikhil/workspace/xeon-fft-bench/src/1-d-fft/fft_logs/run_batch_1/20260309_141257/runs/run02/fft_benchmark_20260309_141348.log` | `/home/nikhil/workspace/xeon-fft-bench/src/1-d-fft/fft_logs/run_batch_1/20260309_141257/runs/run02/fft_benchmark_20260309_141348.report.md` |
| run03 | `/home/nikhil/workspace/xeon-fft-bench/src/1-d-fft/fft_logs/run_batch_1/20260309_141257/runs/run03/fft_benchmark_20260309_141436.log` | `/home/nikhil/workspace/xeon-fft-bench/src/1-d-fft/fft_logs/run_batch_1/20260309_141257/runs/run03/fft_benchmark_20260309_141436.report.md` |
| run04 | `/home/nikhil/workspace/xeon-fft-bench/src/1-d-fft/fft_logs/run_batch_1/20260309_141257/runs/run04/fft_benchmark_20260309_141526.log` | `/home/nikhil/workspace/xeon-fft-bench/src/1-d-fft/fft_logs/run_batch_1/20260309_141257/runs/run04/fft_benchmark_20260309_141526.report.md` |
| run05 | `/home/nikhil/workspace/xeon-fft-bench/src/1-d-fft/fft_logs/run_batch_1/20260309_141257/runs/run05/fft_benchmark_20260309_141615.log` | `/home/nikhil/workspace/xeon-fft-bench/src/1-d-fft/fft_logs/run_batch_1/20260309_141257/runs/run05/fft_benchmark_20260309_141615.report.md` |

## Scenario Catalog

| Profile | Description | Workload | ISA | Threads |
|---|---|---|---|---:|
| baseline_sse42_1t | MKL SSE4.2 baseline, single thread (CPU path, no AVX2/AVX512 kernels) | throughput | SSE4_2 | 1 |
| avx512_phys | MKL AVX-512, physical-core thread count | throughput | AVX512 | 10 |
| avx512_logical | MKL AVX-512, logical-core thread count (hyperthreading on) | throughput | AVX512 | 20 |

## Top 15 Forward Cases

| Workload | Case | N | Batch | Threads | Profile | Avg Fwd ms | Avg Fwd SP GFLOPS | Fwd % Peak | Speedup vs SSE4.2 1T | Samples |
|---|---|---:|---:|---:|---|---:|---:|---:|---:|---|
| throughput | n65536_b1 | 65536 | 1 | 10 | avx512_phys | 0.061064 | 85.86 | 4.07% | 6.0291 | 5/5 |
| throughput | n32768_b1 | 32768 | 1 | 10 | avx512_phys | 0.031168 | 78.85 | 3.73% | 5.1920 | 5/5 |
| throughput | n16384_b1 | 16384 | 1 | 10 | avx512_phys | 0.018465 | 62.11 | 2.94% | 3.7856 | 5/5 |
| throughput | n16384_b1 | 16384 | 1 | 20 | avx512_logical | 0.018817 | 60.95 | 2.89% | 3.7149 | 5/5 |
| throughput | n8192_b1 | 8192 | 1 | 10 | avx512_phys | 0.011952 | 44.55 | 2.11% | 2.2947 | 5/5 |
| throughput | n4096_b1 | 4096 | 1 | 20 | avx512_logical | 0.007114 | 34.55 | 1.64% | 1.8165 | 5/5 |
| throughput | n4096_b1 | 4096 | 1 | 10 | avx512_phys | 0.007153 | 34.36 | 1.63% | 1.8064 | 5/5 |
| throughput | n8192_b1 | 8192 | 1 | 20 | avx512_logical | 0.017936 | 29.69 | 1.41% | 1.5291 | 5/5 |
| throughput | n2048_b1 | 2048 | 1 | 10 | avx512_phys | 0.003905 | 28.85 | 1.37% | 1.5397 | 5/5 |
| throughput | n2048_b1 | 2048 | 1 | 20 | avx512_logical | 0.003945 | 28.55 | 1.35% | 1.5239 | 5/5 |
| throughput | n1024_b1 | 1024 | 1 | 10 | avx512_phys | 0.001832 | 27.95 | 1.32% | 1.5925 | 5/5 |
| throughput | n1024_b1 | 1024 | 1 | 20 | avx512_logical | 0.001846 | 27.73 | 1.31% | 1.5797 | 5/5 |
| throughput | n128_b1 | 128 | 1 | 20 | avx512_logical | 0.000166 | 27.05 | 1.28% | 1.3913 | 5/5 |
| throughput | n128_b1 | 128 | 1 | 10 | avx512_phys | 0.000166 | 27.02 | 1.28% | 1.3896 | 5/5 |
| throughput | n64_b1 | 64 | 1 | 10 | avx512_phys | 0.000071 | 26.89 | 1.27% | 1.5714 | 5/5 |

## Averaged Results (Forward)

| Workload | Case | N | Batch | Threads | Profile | ISA | Avg Fwd ms | Avg Fwd SP GFLOPS | Avg Mem MB | Fwd % Peak | Speedup vs SSE4.2 1T | Samples | Check (ok/fail) | Quality |
|---|---|---:|---:|---:|---|---|---:|---:|---:|---:|---:|---|---|---|
| throughput | n2_b1 | 2 | 1 | 1 | baseline_sse42_1t | SSE4_2 | 0.000021 | 0.47 | 1.0000 | 0.02% | 1.0000 | 5/5 | 5/0 | ok |
| throughput | n2_b1 | 2 | 1 | 10 | avx512_phys | AVX512 | 0.000020 | 0.49 | 1.0000 | 0.02% | 1.0392 | 5/5 | 5/0 | ok |
| throughput | n2_b1 | 2 | 1 | 20 | avx512_logical | AVX512 | 0.000022 | 0.46 | 1.0000 | 0.02% | 0.9815 | 5/5 | 5/0 | ok |
| throughput | n4_b1 | 4 | 1 | 1 | baseline_sse42_1t | SSE4_2 | 0.000022 | 1.82 | 2.0000 | 0.09% | 1.0000 | 5/5 | 5/0 | ok |
| throughput | n4_b1 | 4 | 1 | 10 | avx512_phys | AVX512 | 0.000024 | 1.68 | 2.0000 | 0.08% | 0.9244 | 5/5 | 5/0 | ok |
| throughput | n4_b1 | 4 | 1 | 20 | avx512_logical | AVX512 | 0.000025 | 1.59 | 2.0000 | 0.08% | 0.8730 | 5/5 | 5/0 | ok |
| throughput | n8_b1 | 8 | 1 | 1 | baseline_sse42_1t | SSE4_2 | 0.000026 | 4.69 | 4.0000 | 0.22% | 1.0000 | 5/5 | 5/0 | ok |
| throughput | n8_b1 | 8 | 1 | 10 | avx512_phys | AVX512 | 0.000023 | 5.26 | 4.0000 | 0.25% | 1.1228 | 5/5 | 5/0 | ok |
| throughput | n8_b1 | 8 | 1 | 20 | avx512_logical | AVX512 | 0.000022 | 5.50 | 4.0000 | 0.26% | 1.1743 | 5/5 | 5/0 | ok |
| throughput | n16_b1 | 16 | 1 | 1 | baseline_sse42_1t | SSE4_2 | 0.000027 | 11.76 | 8.0000 | 0.56% | 1.0000 | 5/5 | 5/0 | ok |
| throughput | n16_b1 | 16 | 1 | 10 | avx512_phys | AVX512 | 0.000023 | 14.16 | 8.0000 | 0.67% | 1.2035 | 5/5 | 5/0 | ok |
| throughput | n16_b1 | 16 | 1 | 20 | avx512_logical | AVX512 | 0.000023 | 13.79 | 8.0000 | 0.65% | 1.1724 | 5/5 | 5/0 | ok |
| throughput | n32_b1 | 32 | 1 | 1 | baseline_sse42_1t | SSE4_2 | 0.000045 | 17.62 | 16.0000 | 0.83% | 1.0000 | 5/5 | 5/0 | ok |
| throughput | n32_b1 | 32 | 1 | 10 | avx512_phys | AVX512 | 0.000043 | 18.60 | 16.0000 | 0.88% | 1.0558 | 5/5 | 5/0 | ok |
| throughput | n32_b1 | 32 | 1 | 20 | avx512_logical | AVX512 | 0.000041 | 19.42 | 16.0000 | 0.92% | 1.1019 | 5/5 | 5/0 | ok |
| throughput | n64_b1 | 64 | 1 | 1 | baseline_sse42_1t | SSE4_2 | 0.000112 | 17.11 | 32.0000 | 0.81% | 1.0000 | 5/5 | 5/0 | ok |
| throughput | n64_b1 | 64 | 1 | 10 | avx512_phys | AVX512 | 0.000071 | 26.89 | 32.0000 | 1.27% | 1.5714 | 5/5 | 5/0 | ok |
| throughput | n64_b1 | 64 | 1 | 20 | avx512_logical | AVX512 | 0.000076 | 25.40 | 32.0000 | 1.20% | 1.4841 | 5/5 | 5/0 | ok |
| throughput | n128_b1 | 128 | 1 | 1 | baseline_sse42_1t | SSE4_2 | 0.000230 | 19.44 | 64.0000 | 0.92% | 1.0000 | 5/5 | 5/0 | ok |
| throughput | n128_b1 | 128 | 1 | 10 | avx512_phys | AVX512 | 0.000166 | 27.02 | 64.0000 | 1.28% | 1.3896 | 5/5 | 5/0 | ok |
| throughput | n128_b1 | 128 | 1 | 20 | avx512_logical | AVX512 | 0.000166 | 27.05 | 64.0000 | 1.28% | 1.3913 | 5/5 | 5/0 | ok |
| throughput | n256_b1 | 256 | 1 | 1 | baseline_sse42_1t | SSE4_2 | 0.000572 | 17.90 | 128.0000 | 0.85% | 1.0000 | 5/5 | 5/0 | ok |
| throughput | n256_b1 | 256 | 1 | 10 | avx512_phys | AVX512 | 0.000449 | 22.81 | 128.0000 | 1.08% | 1.2744 | 5/5 | 5/0 | ok |
| throughput | n256_b1 | 256 | 1 | 20 | avx512_logical | AVX512 | 0.000456 | 22.46 | 128.0000 | 1.06% | 1.2548 | 5/5 | 5/0 | ok |
| throughput | n512_b1 | 512 | 1 | 1 | baseline_sse42_1t | SSE4_2 | 0.001199 | 19.21 | 256.0000 | 0.91% | 1.0000 | 5/5 | 5/0 | ok |
| throughput | n512_b1 | 512 | 1 | 10 | avx512_phys | AVX512 | 0.000988 | 23.32 | 256.0000 | 1.10% | 1.2140 | 5/5 | 5/0 | ok |
| throughput | n512_b1 | 512 | 1 | 20 | avx512_logical | AVX512 | 0.000988 | 23.32 | 256.0000 | 1.10% | 1.2135 | 5/5 | 5/0 | ok |
| throughput | n1024_b1 | 1024 | 1 | 1 | baseline_sse42_1t | SSE4_2 | 0.002917 | 17.55 | 512.0100 | 0.83% | 1.0000 | 5/5 | 5/0 | ok |
| throughput | n1024_b1 | 1024 | 1 | 10 | avx512_phys | AVX512 | 0.001832 | 27.95 | 512.0100 | 1.32% | 1.5925 | 5/5 | 5/0 | ok |
| throughput | n1024_b1 | 1024 | 1 | 20 | avx512_logical | AVX512 | 0.001846 | 27.73 | 512.0100 | 1.31% | 1.5797 | 5/5 | 5/0 | ok |
| throughput | n2048_b1 | 2048 | 1 | 1 | baseline_sse42_1t | SSE4_2 | 0.006012 | 18.74 | 1024.0200 | 0.89% | 1.0000 | 5/5 | 5/0 | ok |
| throughput | n2048_b1 | 2048 | 1 | 10 | avx512_phys | AVX512 | 0.003905 | 28.85 | 1024.0200 | 1.37% | 1.5397 | 5/5 | 5/0 | ok |
| throughput | n2048_b1 | 2048 | 1 | 20 | avx512_logical | AVX512 | 0.003945 | 28.55 | 1024.0200 | 1.35% | 1.5239 | 5/5 | 5/0 | ok |
| throughput | n4096_b1 | 4096 | 1 | 1 | baseline_sse42_1t | SSE4_2 | 0.012922 | 19.02 | 1024.0300 | 0.90% | 1.0000 | 5/5 | 5/0 | ok |
| throughput | n4096_b1 | 4096 | 1 | 10 | avx512_phys | AVX512 | 0.007153 | 34.36 | 1024.0300 | 1.63% | 1.8064 | 5/5 | 5/0 | ok |
| throughput | n4096_b1 | 4096 | 1 | 20 | avx512_logical | AVX512 | 0.007114 | 34.55 | 1024.0300 | 1.64% | 1.8165 | 5/5 | 5/0 | ok |
| throughput | n8192_b1 | 8192 | 1 | 1 | baseline_sse42_1t | SSE4_2 | 0.027426 | 19.42 | 1024.0600 | 0.92% | 1.0000 | 5/5 | 5/0 | ok |
| throughput | n8192_b1 | 8192 | 1 | 10 | avx512_phys | AVX512 | 0.011952 | 44.55 | 1024.0600 | 2.11% | 2.2947 | 5/5 | 5/0 | ok |
| throughput | n8192_b1 | 8192 | 1 | 20 | avx512_logical | AVX512 | 0.017936 | 29.69 | 1024.0600 | 1.41% | 1.5291 | 5/5 | 5/0 | ok |
| throughput | n16384_b1 | 16384 | 1 | 1 | baseline_sse42_1t | SSE4_2 | 0.069903 | 16.41 | 1024.1200 | 0.78% | 1.0000 | 5/5 | 5/0 | ok |
| throughput | n16384_b1 | 16384 | 1 | 10 | avx512_phys | AVX512 | 0.018465 | 62.11 | 1024.1200 | 2.94% | 3.7856 | 5/5 | 5/0 | ok |
| throughput | n16384_b1 | 16384 | 1 | 20 | avx512_logical | AVX512 | 0.018817 | 60.95 | 1024.1200 | 2.89% | 3.7149 | 5/5 | 5/0 | ok |
| throughput | n32768_b1 | 32768 | 1 | 1 | baseline_sse42_1t | SSE4_2 | 0.161822 | 15.19 | 1024.2500 | 0.72% | 1.0000 | 5/5 | 5/0 | ok |
| throughput | n32768_b1 | 32768 | 1 | 10 | avx512_phys | AVX512 | 0.031168 | 78.85 | 1024.2500 | 3.73% | 5.1920 | 5/5 | 5/0 | ok |
| throughput | n32768_b1 | 32768 | 1 | 20 | avx512_logical | AVX512 | 0.105500 | 23.29 | 1024.2500 | 1.10% | 1.5339 | 5/5 | 5/0 | ok |
| throughput | n65536_b1 | 65536 | 1 | 1 | baseline_sse42_1t | SSE4_2 | 0.368163 | 14.24 | 1024.5000 | 0.67% | 1.0000 | 5/5 | 5/0 | ok |
| throughput | n65536_b1 | 65536 | 1 | 10 | avx512_phys | AVX512 | 0.061064 | 85.86 | 1024.5000 | 4.07% | 6.0291 | 5/5 | 5/0 | ok |
| throughput | n65536_b1 | 65536 | 1 | 20 | avx512_logical | AVX512 | 0.254026 | 20.64 | 1024.5000 | 0.98% | 1.4493 | 5/5 | 5/0 | ok |

## Plotting Data

- CSV: `/home/nikhil/workspace/xeon-fft-bench/src/1-d-fft/fft_logs/run_batch_1/20260309_141257/latest_run_avg.csv`
