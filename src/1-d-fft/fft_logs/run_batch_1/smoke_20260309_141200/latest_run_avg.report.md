# 1D FFT run_batch_1 (1-run average, forward-focused, extra-cold streaming)

- Generated at: Mon Mar  9 14:12:05 IST 2026
- Manifest: `/home/nikhil/workspace/xeon-fft-bench/src/1-d-fft/fft_logs/run_batch_1/smoke_20260309_141200/manifest.tsv`
- Runs combined: 1
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

- CHECK lines counted: 48
- CHECK failures: 0
- Missing CHECK samples: 0
- Strict validation required at runtime: yes

## Data Quality

- Averaged rows: 48
- Rows with incomplete quality: 0
- Expected samples per row: 1

## Run Files

| Run | Log | Report |
|---|---|---|
| run01 | `/home/nikhil/workspace/xeon-fft-bench/src/1-d-fft/fft_logs/run_batch_1/smoke_20260309_141200/runs/run01/fft_benchmark_20260309_141201.log` | `/home/nikhil/workspace/xeon-fft-bench/src/1-d-fft/fft_logs/run_batch_1/smoke_20260309_141200/runs/run01/fft_benchmark_20260309_141201.report.md` |

## Scenario Catalog

| Profile | Description | Workload | ISA | Threads |
|---|---|---|---|---:|
| baseline_sse42_1t | MKL SSE4.2 baseline, single thread (CPU path, no AVX2/AVX512 kernels) | throughput | SSE4_2 | 1 |
| avx512_phys | MKL AVX-512, physical-core thread count | throughput | AVX512 | 10 |
| avx512_logical | MKL AVX-512, logical-core thread count (hyperthreading on) | throughput | AVX512 | 20 |

## Top 15 Forward Cases

| Workload | Case | N | Batch | Threads | Profile | Avg Fwd ms | Avg Fwd SP GFLOPS | Fwd % Peak | Speedup vs SSE4.2 1T | Samples |
|---|---|---:|---:|---:|---|---:|---:|---:|---:|---|
| throughput | n65536_b1 | 65536 | 1 | 20 | avx512_logical | 0.057537 | 91.12 | 4.31% | 6.7530 | 1/1 |
| throughput | n65536_b1 | 65536 | 1 | 10 | avx512_phys | 0.068587 | 76.44 | 3.62% | 5.6651 | 1/1 |
| throughput | n32768_b1 | 32768 | 1 | 10 | avx512_phys | 0.034444 | 71.35 | 3.38% | 4.8642 | 1/1 |
| throughput | n128_b1 | 128 | 1 | 10 | avx512_phys | 0.000069 | 64.93 | 3.07% | 2.4493 | 1/1 |
| throughput | n128_b1 | 128 | 1 | 20 | avx512_logical | 0.000069 | 64.93 | 3.07% | 2.4493 | 1/1 |
| throughput | n16384_b1 | 16384 | 1 | 10 | avx512_phys | 0.018332 | 62.56 | 2.96% | 3.9325 | 1/1 |
| throughput | n16384_b1 | 16384 | 1 | 20 | avx512_logical | 0.020139 | 56.95 | 2.70% | 3.5796 | 1/1 |
| throughput | n256_b1 | 256 | 1 | 20 | avx512_logical | 0.000187 | 54.76 | 2.59% | 1.9358 | 1/1 |
| throughput | n256_b1 | 256 | 1 | 10 | avx512_phys | 0.000188 | 54.47 | 2.58% | 1.9255 | 1/1 |
| throughput | n8192_b1 | 8192 | 1 | 20 | avx512_logical | 0.010657 | 49.97 | 2.37% | 2.3012 | 1/1 |
| throughput | n1024_b1 | 1024 | 1 | 10 | avx512_phys | 0.001032 | 49.61 | 2.35% | 1.8343 | 1/1 |
| throughput | n8192_b1 | 8192 | 1 | 10 | avx512_phys | 0.010783 | 49.38 | 2.34% | 2.2743 | 1/1 |
| throughput | n1024_b1 | 1024 | 1 | 20 | avx512_logical | 0.001044 | 49.04 | 2.32% | 1.8132 | 1/1 |
| throughput | n2048_b1 | 2048 | 1 | 20 | avx512_logical | 0.002398 | 46.97 | 2.22% | 1.8207 | 1/1 |
| throughput | n512_b1 | 512 | 1 | 20 | avx512_logical | 0.000493 | 46.73 | 2.21% | 1.8174 | 1/1 |

## Averaged Results (Forward)

| Workload | Case | N | Batch | Threads | Profile | ISA | Avg Fwd ms | Avg Fwd SP GFLOPS | Avg Mem MB | Fwd % Peak | Speedup vs SSE4.2 1T | Samples | Check (ok/fail) | Quality |
|---|---|---:|---:|---:|---|---|---:|---:|---:|---:|---:|---|---|---|
| throughput | n2_b1 | 2 | 1 | 1 | baseline_sse42_1t | SSE4_2 | 0.000020 | 0.50 | 0.0100 | 0.02% | 1.0000 | 1/1 | 1/0 | ok |
| throughput | n2_b1 | 2 | 1 | 10 | avx512_phys | AVX512 | 0.000020 | 0.50 | 0.0100 | 0.02% | 1.0000 | 1/1 | 1/0 | ok |
| throughput | n2_b1 | 2 | 1 | 20 | avx512_logical | AVX512 | 0.000020 | 0.50 | 0.0100 | 0.02% | 1.0000 | 1/1 | 1/0 | ok |
| throughput | n4_b1 | 4 | 1 | 1 | baseline_sse42_1t | SSE4_2 | 0.000022 | 1.82 | 0.0200 | 0.09% | 1.0000 | 1/1 | 1/0 | ok |
| throughput | n4_b1 | 4 | 1 | 10 | avx512_phys | AVX512 | 0.000024 | 1.67 | 0.0200 | 0.08% | 0.9167 | 1/1 | 1/0 | ok |
| throughput | n4_b1 | 4 | 1 | 20 | avx512_logical | AVX512 | 0.000024 | 1.67 | 0.0200 | 0.08% | 0.9167 | 1/1 | 1/0 | ok |
| throughput | n8_b1 | 8 | 1 | 1 | baseline_sse42_1t | SSE4_2 | 0.000022 | 5.45 | 0.0300 | 0.26% | 1.0000 | 1/1 | 1/0 | ok |
| throughput | n8_b1 | 8 | 1 | 10 | avx512_phys | AVX512 | 0.000021 | 5.71 | 0.0300 | 0.27% | 1.0476 | 1/1 | 1/0 | ok |
| throughput | n8_b1 | 8 | 1 | 20 | avx512_logical | AVX512 | 0.000021 | 5.71 | 0.0300 | 0.27% | 1.0476 | 1/1 | 1/0 | ok |
| throughput | n16_b1 | 16 | 1 | 1 | baseline_sse42_1t | SSE4_2 | 0.000026 | 12.31 | 0.0600 | 0.58% | 1.0000 | 1/1 | 1/0 | ok |
| throughput | n16_b1 | 16 | 1 | 10 | avx512_phys | AVX512 | 0.000022 | 14.55 | 0.0600 | 0.69% | 1.1818 | 1/1 | 1/0 | ok |
| throughput | n16_b1 | 16 | 1 | 20 | avx512_logical | AVX512 | 0.000022 | 14.55 | 0.0600 | 0.69% | 1.1818 | 1/1 | 1/0 | ok |
| throughput | n32_b1 | 32 | 1 | 1 | baseline_sse42_1t | SSE4_2 | 0.000039 | 20.51 | 0.1300 | 0.97% | 1.0000 | 1/1 | 1/0 | ok |
| throughput | n32_b1 | 32 | 1 | 10 | avx512_phys | AVX512 | 0.000035 | 22.86 | 0.1300 | 1.08% | 1.1143 | 1/1 | 1/0 | ok |
| throughput | n32_b1 | 32 | 1 | 20 | avx512_logical | AVX512 | 0.000033 | 24.24 | 0.1300 | 1.15% | 1.1818 | 1/1 | 1/0 | ok |
| throughput | n64_b1 | 64 | 1 | 1 | baseline_sse42_1t | SSE4_2 | 0.000091 | 21.10 | 0.2500 | 1.00% | 1.0000 | 1/1 | 1/0 | ok |
| throughput | n64_b1 | 64 | 1 | 10 | avx512_phys | AVX512 | 0.000045 | 42.67 | 0.2500 | 2.02% | 2.0222 | 1/1 | 1/0 | ok |
| throughput | n64_b1 | 64 | 1 | 20 | avx512_logical | AVX512 | 0.000047 | 40.85 | 0.2500 | 1.93% | 1.9362 | 1/1 | 1/0 | ok |
| throughput | n128_b1 | 128 | 1 | 1 | baseline_sse42_1t | SSE4_2 | 0.000169 | 26.51 | 0.5000 | 1.26% | 1.0000 | 1/1 | 1/0 | ok |
| throughput | n128_b1 | 128 | 1 | 10 | avx512_phys | AVX512 | 0.000069 | 64.93 | 0.5000 | 3.07% | 2.4493 | 1/1 | 1/0 | ok |
| throughput | n128_b1 | 128 | 1 | 20 | avx512_logical | AVX512 | 0.000069 | 64.93 | 0.5000 | 3.07% | 2.4493 | 1/1 | 1/0 | ok |
| throughput | n256_b1 | 256 | 1 | 1 | baseline_sse42_1t | SSE4_2 | 0.000362 | 28.29 | 1.0000 | 1.34% | 1.0000 | 1/1 | 1/0 | ok |
| throughput | n256_b1 | 256 | 1 | 10 | avx512_phys | AVX512 | 0.000188 | 54.47 | 1.0000 | 2.58% | 1.9255 | 1/1 | 1/0 | ok |
| throughput | n256_b1 | 256 | 1 | 20 | avx512_logical | AVX512 | 0.000187 | 54.76 | 1.0000 | 2.59% | 1.9358 | 1/1 | 1/0 | ok |
| throughput | n512_b1 | 512 | 1 | 1 | baseline_sse42_1t | SSE4_2 | 0.000896 | 25.71 | 2.0000 | 1.22% | 1.0000 | 1/1 | 1/0 | ok |
| throughput | n512_b1 | 512 | 1 | 10 | avx512_phys | AVX512 | 0.000497 | 46.36 | 2.0000 | 2.19% | 1.8028 | 1/1 | 1/0 | ok |
| throughput | n512_b1 | 512 | 1 | 20 | avx512_logical | AVX512 | 0.000493 | 46.73 | 2.0000 | 2.21% | 1.8174 | 1/1 | 1/0 | ok |
| throughput | n1024_b1 | 1024 | 1 | 1 | baseline_sse42_1t | SSE4_2 | 0.001893 | 27.05 | 4.0100 | 1.28% | 1.0000 | 1/1 | 1/0 | ok |
| throughput | n1024_b1 | 1024 | 1 | 10 | avx512_phys | AVX512 | 0.001032 | 49.61 | 4.0100 | 2.35% | 1.8343 | 1/1 | 1/0 | ok |
| throughput | n1024_b1 | 1024 | 1 | 20 | avx512_logical | AVX512 | 0.001044 | 49.04 | 4.0100 | 2.32% | 1.8132 | 1/1 | 1/0 | ok |
| throughput | n2048_b1 | 2048 | 1 | 1 | baseline_sse42_1t | SSE4_2 | 0.004366 | 25.80 | 8.0200 | 1.22% | 1.0000 | 1/1 | 1/0 | ok |
| throughput | n2048_b1 | 2048 | 1 | 10 | avx512_phys | AVX512 | 0.002583 | 43.61 | 8.0200 | 2.06% | 1.6903 | 1/1 | 1/0 | ok |
| throughput | n2048_b1 | 2048 | 1 | 20 | avx512_logical | AVX512 | 0.002398 | 46.97 | 8.0200 | 2.22% | 1.8207 | 1/1 | 1/0 | ok |
| throughput | n4096_b1 | 4096 | 1 | 1 | baseline_sse42_1t | SSE4_2 | 0.010792 | 22.77 | 16.0300 | 1.08% | 1.0000 | 1/1 | 1/0 | ok |
| throughput | n4096_b1 | 4096 | 1 | 10 | avx512_phys | AVX512 | 0.005415 | 45.39 | 16.0300 | 2.15% | 1.9930 | 1/1 | 1/0 | ok |
| throughput | n4096_b1 | 4096 | 1 | 20 | avx512_logical | AVX512 | 0.005898 | 41.67 | 16.0300 | 1.97% | 1.8298 | 1/1 | 1/0 | ok |
| throughput | n8192_b1 | 8192 | 1 | 1 | baseline_sse42_1t | SSE4_2 | 0.024524 | 21.71 | 32.0600 | 1.03% | 1.0000 | 1/1 | 1/0 | ok |
| throughput | n8192_b1 | 8192 | 1 | 10 | avx512_phys | AVX512 | 0.010783 | 49.38 | 32.0600 | 2.34% | 2.2743 | 1/1 | 1/0 | ok |
| throughput | n8192_b1 | 8192 | 1 | 20 | avx512_logical | AVX512 | 0.010657 | 49.97 | 32.0600 | 2.37% | 2.3012 | 1/1 | 1/0 | ok |
| throughput | n16384_b1 | 16384 | 1 | 1 | baseline_sse42_1t | SSE4_2 | 0.072090 | 15.91 | 64.1200 | 0.75% | 1.0000 | 1/1 | 1/0 | ok |
| throughput | n16384_b1 | 16384 | 1 | 10 | avx512_phys | AVX512 | 0.018332 | 62.56 | 64.1200 | 2.96% | 3.9325 | 1/1 | 1/0 | ok |
| throughput | n16384_b1 | 16384 | 1 | 20 | avx512_logical | AVX512 | 0.020139 | 56.95 | 64.1200 | 2.70% | 3.5796 | 1/1 | 1/0 | ok |
| throughput | n32768_b1 | 32768 | 1 | 1 | baseline_sse42_1t | SSE4_2 | 0.167544 | 14.67 | 128.2500 | 0.69% | 1.0000 | 1/1 | 1/0 | ok |
| throughput | n32768_b1 | 32768 | 1 | 10 | avx512_phys | AVX512 | 0.034444 | 71.35 | 128.2500 | 3.38% | 4.8642 | 1/1 | 1/0 | ok |
| throughput | n32768_b1 | 32768 | 1 | 20 | avx512_logical | AVX512 | 0.176564 | 13.92 | 128.2500 | 0.66% | 0.9489 | 1/1 | 1/0 | ok |
| throughput | n65536_b1 | 65536 | 1 | 1 | baseline_sse42_1t | SSE4_2 | 0.388550 | 13.49 | 256.5000 | 0.64% | 1.0000 | 1/1 | 1/0 | ok |
| throughput | n65536_b1 | 65536 | 1 | 10 | avx512_phys | AVX512 | 0.068587 | 76.44 | 256.5000 | 3.62% | 5.6651 | 1/1 | 1/0 | ok |
| throughput | n65536_b1 | 65536 | 1 | 20 | avx512_logical | AVX512 | 0.057537 | 91.12 | 256.5000 | 4.31% | 6.7530 | 1/1 | 1/0 | ok |

## Plotting Data

- CSV: `/home/nikhil/workspace/xeon-fft-bench/src/1-d-fft/fft_logs/run_batch_1/smoke_20260309_141200/latest_run_avg.csv`
