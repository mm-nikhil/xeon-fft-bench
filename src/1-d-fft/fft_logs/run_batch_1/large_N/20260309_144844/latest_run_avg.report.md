# 1D FFT run_batch_1/large_N (3-run average, forward-focused, extra-cold streaming)

- Generated at: Mon Mar  9 14:54:28 IST 2026
- Manifest: `/home/nikhil/workspace/xeon-fft-bench/src/1-d-fft/fft_logs/run_batch_1/large_N/20260309_144844/manifest.tsv`
- Runs combined: 3
- Forward-only reporting: yes
- Matrix scope: batch fixed to 1, N=2..4194304 (doubling)

## Server Hardware

- CPU: Intel(R) Xeon(R) W-2155 CPU @ 3.30GHz (family 6, model 85)
- Physical cores: 10, Logical threads: 20 (HT: 2 threads/core)
- Base clock: 3.30 GHz | Max turbo: 4.5 GHz
- NUMA nodes: 1

## Peak Model

- SP peak formula: cores x 2 FMA/core x 16 lanes x 2 FLOP/FMA x freq
- Report denominator for %peak: 2112.0 SP GFLOPS

## Correctness Summary

- CHECK lines counted: 198
- CHECK failures: 0
- Missing CHECK samples: 0
- Strict validation required at runtime: yes

## Data Quality

- Averaged rows: 66
- Rows with incomplete quality: 0
- Expected samples per row: 3

## Run Files

| Run | Log | Report |
|---|---|---|
| run01 | `/home/nikhil/workspace/xeon-fft-bench/src/1-d-fft/fft_logs/run_batch_1/large_N/20260309_144844/runs/run01/fft_benchmark_20260309_144844.log` | `/home/nikhil/workspace/xeon-fft-bench/src/1-d-fft/fft_logs/run_batch_1/large_N/20260309_144844/runs/run01/fft_benchmark_20260309_144844.report.md` |
| run02 | `/home/nikhil/workspace/xeon-fft-bench/src/1-d-fft/fft_logs/run_batch_1/large_N/20260309_144844/runs/run02/fft_benchmark_20260309_145043.log` | `/home/nikhil/workspace/xeon-fft-bench/src/1-d-fft/fft_logs/run_batch_1/large_N/20260309_144844/runs/run02/fft_benchmark_20260309_145043.report.md` |
| run03 | `/home/nikhil/workspace/xeon-fft-bench/src/1-d-fft/fft_logs/run_batch_1/large_N/20260309_144844/runs/run03/fft_benchmark_20260309_145238.log` | `/home/nikhil/workspace/xeon-fft-bench/src/1-d-fft/fft_logs/run_batch_1/large_N/20260309_144844/runs/run03/fft_benchmark_20260309_145238.report.md` |

## Scenario Catalog

| Profile | Description | Workload | ISA | Threads |
|---|---|---|---|---:|
| baseline_sse42_1t | MKL SSE4.2 baseline, single thread (CPU path, no AVX2/AVX512 kernels) | throughput | SSE4_2 | 1 |
| avx512_phys | MKL AVX-512, physical-core thread count | throughput | AVX512 | 10 |
| avx512_logical | MKL AVX-512, logical-core thread count (hyperthreading on) | throughput | AVX512 | 20 |

## Top 15 Forward Cases

| Workload | Case | N | Batch | Threads | Profile | Avg Fwd ms | Avg Fwd SP GFLOPS | Fwd % Peak | Speedup vs SSE4.2 1T | Samples |
|---|---|---:|---:|---:|---|---:|---:|---:|---:|---|
| throughput | n1048576_b1 | 1048576 | 1 | 10 | avx512_phys | 1.075693 | 97.48 | 4.62% | 7.7280 | 3/3 |
| throughput | n524288_b1 | 524288 | 1 | 10 | avx512_phys | 0.528239 | 94.29 | 4.46% | 6.4144 | 3/3 |
| throughput | n262144_b1 | 262144 | 1 | 10 | avx512_phys | 0.257498 | 91.62 | 4.34% | 7.2835 | 3/3 |
| throughput | n131072_b1 | 131072 | 1 | 10 | avx512_phys | 0.139086 | 80.10 | 3.79% | 6.5247 | 3/3 |
| throughput | n65536_b1 | 65536 | 1 | 10 | avx512_phys | 0.066447 | 78.90 | 3.74% | 5.3939 | 3/3 |
| throughput | n2097152_b1 | 2097152 | 1 | 10 | avx512_phys | 2.800948 | 78.62 | 3.72% | 6.1121 | 3/3 |
| throughput | n32768_b1 | 32768 | 1 | 10 | avx512_phys | 0.035695 | 68.85 | 3.26% | 4.3423 | 3/3 |
| throughput | n16384_b1 | 16384 | 1 | 20 | avx512_logical | 0.017733 | 64.67 | 3.06% | 3.8678 | 3/3 |
| throughput | n4194304_b1 | 4194304 | 1 | 10 | avx512_phys | 7.182408 | 64.24 | 3.04% | 4.9558 | 3/3 |
| throughput | n16384_b1 | 16384 | 1 | 10 | avx512_phys | 0.018051 | 63.53 | 3.01% | 3.7997 | 3/3 |
| throughput | n8192_b1 | 8192 | 1 | 20 | avx512_logical | 0.011892 | 44.78 | 2.12% | 2.3297 | 3/3 |
| throughput | n8192_b1 | 8192 | 1 | 10 | avx512_phys | 0.011982 | 44.44 | 2.10% | 2.3122 | 3/3 |
| throughput | n4194304_b1 | 4194304 | 1 | 20 | avx512_logical | 12.379374 | 37.27 | 1.76% | 2.8753 | 3/3 |
| throughput | n4096_b1 | 4096 | 1 | 20 | avx512_logical | 0.007091 | 34.66 | 1.64% | 1.8694 | 3/3 |
| throughput | n2097152_b1 | 2097152 | 1 | 20 | avx512_logical | 6.507287 | 33.84 | 1.60% | 2.6308 | 3/3 |

## Averaged Results (Forward)

| Workload | Case | N | Batch | Threads | Profile | ISA | Avg Fwd ms | Avg Fwd SP GFLOPS | Avg Mem MB | Fwd % Peak | Speedup vs SSE4.2 1T | Samples | Check (ok/fail) | Quality |
|---|---|---:|---:|---:|---|---|---:|---:|---:|---:|---:|---|---|---|
| throughput | n2_b1 | 2 | 1 | 1 | baseline_sse42_1t | SSE4_2 | 0.000021 | 0.48 | 1.0000 | 0.02% | 1.0000 | 3/3 | 3/0 | ok |
| throughput | n2_b1 | 2 | 1 | 10 | avx512_phys | AVX512 | 0.000021 | 0.48 | 1.0000 | 0.02% | 1.0161 | 3/3 | 3/0 | ok |
| throughput | n2_b1 | 2 | 1 | 20 | avx512_logical | AVX512 | 0.000022 | 0.45 | 1.0000 | 0.02% | 0.9545 | 3/3 | 3/0 | ok |
| throughput | n4_b1 | 4 | 1 | 1 | baseline_sse42_1t | SSE4_2 | 0.000022 | 1.82 | 2.0000 | 0.09% | 1.0000 | 3/3 | 3/0 | ok |
| throughput | n4_b1 | 4 | 1 | 10 | avx512_phys | AVX512 | 0.000025 | 1.62 | 2.0000 | 0.08% | 0.8919 | 3/3 | 3/0 | ok |
| throughput | n4_b1 | 4 | 1 | 20 | avx512_logical | AVX512 | 0.000026 | 1.52 | 2.0000 | 0.07% | 0.8354 | 3/3 | 3/0 | ok |
| throughput | n8_b1 | 8 | 1 | 1 | baseline_sse42_1t | SSE4_2 | 0.000024 | 5.07 | 4.0000 | 0.24% | 1.0000 | 3/3 | 3/0 | ok |
| throughput | n8_b1 | 8 | 1 | 10 | avx512_phys | AVX512 | 0.000022 | 5.54 | 4.0000 | 0.26% | 1.0923 | 3/3 | 3/0 | ok |
| throughput | n8_b1 | 8 | 1 | 20 | avx512_logical | AVX512 | 0.000024 | 4.93 | 4.0000 | 0.23% | 0.9726 | 3/3 | 3/0 | ok |
| throughput | n16_b1 | 16 | 1 | 1 | baseline_sse42_1t | SSE4_2 | 0.000028 | 11.57 | 8.0000 | 0.55% | 1.0000 | 3/3 | 3/0 | ok |
| throughput | n16_b1 | 16 | 1 | 10 | avx512_phys | AVX512 | 0.000024 | 13.33 | 8.0000 | 0.63% | 1.1528 | 3/3 | 3/0 | ok |
| throughput | n16_b1 | 16 | 1 | 20 | avx512_logical | AVX512 | 0.000024 | 13.33 | 8.0000 | 0.63% | 1.1528 | 3/3 | 3/0 | ok |
| throughput | n32_b1 | 32 | 1 | 1 | baseline_sse42_1t | SSE4_2 | 0.000048 | 16.67 | 16.0000 | 0.79% | 1.0000 | 3/3 | 3/0 | ok |
| throughput | n32_b1 | 32 | 1 | 10 | avx512_phys | AVX512 | 0.000048 | 16.55 | 16.0000 | 0.78% | 0.9931 | 3/3 | 3/0 | ok |
| throughput | n32_b1 | 32 | 1 | 20 | avx512_logical | AVX512 | 0.000045 | 17.65 | 16.0000 | 0.84% | 1.0588 | 3/3 | 3/0 | ok |
| throughput | n64_b1 | 64 | 1 | 1 | baseline_sse42_1t | SSE4_2 | 0.000118 | 16.32 | 32.0000 | 0.77% | 1.0000 | 3/3 | 3/0 | ok |
| throughput | n64_b1 | 64 | 1 | 10 | avx512_phys | AVX512 | 0.000078 | 24.62 | 32.0000 | 1.17% | 1.5085 | 3/3 | 3/0 | ok |
| throughput | n64_b1 | 64 | 1 | 20 | avx512_logical | AVX512 | 0.000077 | 24.94 | 32.0000 | 1.18% | 1.5281 | 3/3 | 3/0 | ok |
| throughput | n128_b1 | 128 | 1 | 1 | baseline_sse42_1t | SSE4_2 | 0.000243 | 18.41 | 64.0000 | 0.87% | 1.0000 | 3/3 | 3/0 | ok |
| throughput | n128_b1 | 128 | 1 | 10 | avx512_phys | AVX512 | 0.000175 | 25.65 | 64.0000 | 1.21% | 1.3931 | 3/3 | 3/0 | ok |
| throughput | n128_b1 | 128 | 1 | 20 | avx512_logical | AVX512 | 0.000171 | 26.25 | 64.0000 | 1.24% | 1.4258 | 3/3 | 3/0 | ok |
| throughput | n256_b1 | 256 | 1 | 1 | baseline_sse42_1t | SSE4_2 | 0.000578 | 17.71 | 128.0000 | 0.84% | 1.0000 | 3/3 | 3/0 | ok |
| throughput | n256_b1 | 256 | 1 | 10 | avx512_phys | AVX512 | 0.000477 | 21.45 | 128.0000 | 1.02% | 1.2116 | 3/3 | 3/0 | ok |
| throughput | n256_b1 | 256 | 1 | 20 | avx512_logical | AVX512 | 0.000469 | 21.85 | 128.0000 | 1.03% | 1.2340 | 3/3 | 3/0 | ok |
| throughput | n512_b1 | 512 | 1 | 1 | baseline_sse42_1t | SSE4_2 | 0.001190 | 19.36 | 256.0000 | 0.92% | 1.0000 | 3/3 | 3/0 | ok |
| throughput | n512_b1 | 512 | 1 | 10 | avx512_phys | AVX512 | 0.001007 | 22.88 | 256.0000 | 1.08% | 1.1821 | 3/3 | 3/0 | ok |
| throughput | n512_b1 | 512 | 1 | 20 | avx512_logical | AVX512 | 0.000989 | 23.30 | 256.0000 | 1.10% | 1.2036 | 3/3 | 3/0 | ok |
| throughput | n1024_b1 | 1024 | 1 | 1 | baseline_sse42_1t | SSE4_2 | 0.002917 | 17.55 | 512.0100 | 0.83% | 1.0000 | 3/3 | 3/0 | ok |
| throughput | n1024_b1 | 1024 | 1 | 10 | avx512_phys | AVX512 | 0.001868 | 27.41 | 512.0100 | 1.30% | 1.5618 | 3/3 | 3/0 | ok |
| throughput | n1024_b1 | 1024 | 1 | 20 | avx512_logical | AVX512 | 0.001892 | 27.06 | 512.0100 | 1.28% | 1.5415 | 3/3 | 3/0 | ok |
| throughput | n2048_b1 | 2048 | 1 | 1 | baseline_sse42_1t | SSE4_2 | 0.006008 | 18.75 | 1024.0200 | 0.89% | 1.0000 | 3/3 | 3/0 | ok |
| throughput | n2048_b1 | 2048 | 1 | 10 | avx512_phys | AVX512 | 0.004004 | 28.13 | 1024.0200 | 1.33% | 1.5006 | 3/3 | 3/0 | ok |
| throughput | n2048_b1 | 2048 | 1 | 20 | avx512_logical | AVX512 | 0.003988 | 28.25 | 1024.0200 | 1.34% | 1.5067 | 3/3 | 3/0 | ok |
| throughput | n4096_b1 | 4096 | 1 | 1 | baseline_sse42_1t | SSE4_2 | 0.013256 | 18.54 | 1024.0300 | 0.88% | 1.0000 | 3/3 | 3/0 | ok |
| throughput | n4096_b1 | 4096 | 1 | 10 | avx512_phys | AVX512 | 0.007279 | 33.76 | 1024.0300 | 1.60% | 1.8211 | 3/3 | 3/0 | ok |
| throughput | n4096_b1 | 4096 | 1 | 20 | avx512_logical | AVX512 | 0.007091 | 34.66 | 1024.0300 | 1.64% | 1.8694 | 3/3 | 3/0 | ok |
| throughput | n8192_b1 | 8192 | 1 | 1 | baseline_sse42_1t | SSE4_2 | 0.027705 | 19.22 | 1024.0600 | 0.91% | 1.0000 | 3/3 | 3/0 | ok |
| throughput | n8192_b1 | 8192 | 1 | 10 | avx512_phys | AVX512 | 0.011982 | 44.44 | 1024.0600 | 2.10% | 2.3122 | 3/3 | 3/0 | ok |
| throughput | n8192_b1 | 8192 | 1 | 20 | avx512_logical | AVX512 | 0.011892 | 44.78 | 1024.0600 | 2.12% | 2.3297 | 3/3 | 3/0 | ok |
| throughput | n16384_b1 | 16384 | 1 | 1 | baseline_sse42_1t | SSE4_2 | 0.068589 | 16.72 | 1024.1200 | 0.79% | 1.0000 | 3/3 | 3/0 | ok |
| throughput | n16384_b1 | 16384 | 1 | 10 | avx512_phys | AVX512 | 0.018051 | 63.53 | 1024.1200 | 3.01% | 3.7997 | 3/3 | 3/0 | ok |
| throughput | n16384_b1 | 16384 | 1 | 20 | avx512_logical | AVX512 | 0.017733 | 64.67 | 1024.1200 | 3.06% | 3.8678 | 3/3 | 3/0 | ok |
| throughput | n32768_b1 | 32768 | 1 | 1 | baseline_sse42_1t | SSE4_2 | 0.154998 | 15.86 | 1024.2500 | 0.75% | 1.0000 | 3/3 | 3/0 | ok |
| throughput | n32768_b1 | 32768 | 1 | 10 | avx512_phys | AVX512 | 0.035695 | 68.85 | 1024.2500 | 3.26% | 4.3423 | 3/3 | 3/0 | ok |
| throughput | n32768_b1 | 32768 | 1 | 20 | avx512_logical | AVX512 | 0.132653 | 18.53 | 1024.2500 | 0.88% | 1.1684 | 3/3 | 3/0 | ok |
| throughput | n65536_b1 | 65536 | 1 | 1 | baseline_sse42_1t | SSE4_2 | 0.358407 | 14.63 | 1024.5000 | 0.69% | 1.0000 | 3/3 | 3/0 | ok |
| throughput | n65536_b1 | 65536 | 1 | 10 | avx512_phys | AVX512 | 0.066447 | 78.90 | 1024.5000 | 3.74% | 5.3939 | 3/3 | 3/0 | ok |
| throughput | n65536_b1 | 65536 | 1 | 20 | avx512_logical | AVX512 | 0.290714 | 18.03 | 1024.5000 | 0.85% | 1.2329 | 3/3 | 3/0 | ok |
| throughput | n131072_b1 | 131072 | 1 | 1 | baseline_sse42_1t | SSE4_2 | 0.907496 | 12.28 | 1025.0000 | 0.58% | 1.0000 | 3/3 | 3/0 | ok |
| throughput | n131072_b1 | 131072 | 1 | 10 | avx512_phys | AVX512 | 0.139086 | 80.10 | 1025.0000 | 3.79% | 6.5247 | 3/3 | 3/0 | ok |
| throughput | n131072_b1 | 131072 | 1 | 20 | avx512_logical | AVX512 | 0.485123 | 22.97 | 1025.0000 | 1.09% | 1.8706 | 3/3 | 3/0 | ok |
| throughput | n262144_b1 | 262144 | 1 | 1 | baseline_sse42_1t | SSE4_2 | 1.875495 | 12.58 | 1026.0000 | 0.60% | 1.0000 | 3/3 | 3/0 | ok |
| throughput | n262144_b1 | 262144 | 1 | 10 | avx512_phys | AVX512 | 0.257498 | 91.62 | 1026.0000 | 4.34% | 7.2835 | 3/3 | 3/0 | ok |
| throughput | n262144_b1 | 262144 | 1 | 20 | avx512_logical | AVX512 | 1.742796 | 13.54 | 1026.0000 | 0.64% | 1.0761 | 3/3 | 3/0 | ok |
| throughput | n524288_b1 | 524288 | 1 | 1 | baseline_sse42_1t | SSE4_2 | 3.388327 | 14.70 | 1028.0000 | 0.70% | 1.0000 | 3/3 | 3/0 | ok |
| throughput | n524288_b1 | 524288 | 1 | 10 | avx512_phys | AVX512 | 0.528239 | 94.29 | 1028.0000 | 4.46% | 6.4144 | 3/3 | 3/0 | ok |
| throughput | n524288_b1 | 524288 | 1 | 20 | avx512_logical | AVX512 | 2.269492 | 21.95 | 1028.0000 | 1.04% | 1.4930 | 3/3 | 3/0 | ok |
| throughput | n1048576_b1 | 1048576 | 1 | 1 | baseline_sse42_1t | SSE4_2 | 8.312915 | 12.61 | 1032.0000 | 0.60% | 1.0000 | 3/3 | 3/0 | ok |
| throughput | n1048576_b1 | 1048576 | 1 | 10 | avx512_phys | AVX512 | 1.075693 | 97.48 | 1032.0000 | 4.62% | 7.7280 | 3/3 | 3/0 | ok |
| throughput | n1048576_b1 | 1048576 | 1 | 20 | avx512_logical | AVX512 | 6.029966 | 17.39 | 1032.0000 | 0.82% | 1.3786 | 3/3 | 3/0 | ok |
| throughput | n2097152_b1 | 2097152 | 1 | 1 | baseline_sse42_1t | SSE4_2 | 17.119627 | 12.86 | 2064.0000 | 0.61% | 1.0000 | 3/3 | 3/0 | ok |
| throughput | n2097152_b1 | 2097152 | 1 | 10 | avx512_phys | AVX512 | 2.800948 | 78.62 | 2064.0000 | 3.72% | 6.1121 | 3/3 | 3/0 | ok |
| throughput | n2097152_b1 | 2097152 | 1 | 20 | avx512_logical | AVX512 | 6.507287 | 33.84 | 2064.0000 | 1.60% | 2.6308 | 3/3 | 3/0 | ok |
| throughput | n4194304_b1 | 4194304 | 1 | 1 | baseline_sse42_1t | SSE4_2 | 35.594679 | 12.96 | 3040.0000 | 0.61% | 1.0000 | 3/3 | 3/0 | ok |
| throughput | n4194304_b1 | 4194304 | 1 | 10 | avx512_phys | AVX512 | 7.182408 | 64.24 | 3040.0000 | 3.04% | 4.9558 | 3/3 | 3/0 | ok |
| throughput | n4194304_b1 | 4194304 | 1 | 20 | avx512_logical | AVX512 | 12.379374 | 37.27 | 3040.0000 | 1.76% | 2.8753 | 3/3 | 3/0 | ok |

## Plotting Data

- CSV: `/home/nikhil/workspace/xeon-fft-bench/src/1-d-fft/fft_logs/run_batch_1/large_N/20260309_144844/latest_run_avg.csv`
