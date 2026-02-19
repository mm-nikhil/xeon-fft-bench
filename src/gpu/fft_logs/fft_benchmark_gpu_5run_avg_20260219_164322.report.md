# GPU FFT Combined Report (Averaged Across Runs)

- Generated at: Thu Feb 19 16:43:22 IST 2026
- Manifest: `fft_logs/fft_benchmark_gpu_5run_repeat2_32_to_4194304.manifest.txt`
- Runs combined: 5
- Precision mode: single precision (cuFFT C2C)
- Average latency (`ms`): arithmetic mean over successful samples.
- GFLOPS derivation: recomputed from averaged latency.
  `avg_sp_gflops = (5 * N * log2(N) * batch) / (avg_ms * 1e6)`

## Run Files

| Run | Log | Report |
|---|---|---|
| 1 | `fft_logs/fft_benchmark_gpu_20260219_164218.log` | `fft_logs/fft_benchmark_gpu_20260219_164218.report.md` |
| 2 | `fft_logs/fft_benchmark_gpu_20260219_164228.log` | `fft_logs/fft_benchmark_gpu_20260219_164228.report.md` |
| 3 | `fft_logs/fft_benchmark_gpu_20260219_164237.log` | `fft_logs/fft_benchmark_gpu_20260219_164237.report.md` |
| 4 | `fft_logs/fft_benchmark_gpu_20260219_164247.log` | `fft_logs/fft_benchmark_gpu_20260219_164247.report.md` |
| 5 | `fft_logs/fft_benchmark_gpu_20260219_164257.log` | `fft_logs/fft_benchmark_gpu_20260219_164257.report.md` |

## Scenario Catalog

| Run Profile | Description | Workload | Timing Mode |
|---|---|---|---|
| cufft_gpu | cuFFT throughput sweep on RTX 3080 (1D single precision, timing=e2e) | throughput | e2e |
| cufft_gpu_batch_scaling | cuFFT batch scaling sweep on fixed length (timing=e2e) | batch_scaling | e2e |

## Data Quality Check

- Expected samples per row: 5
- Rows with missing samples: 0

## Averaged Results

| Workload | Case | Length | Batch | ThreadsField | Profile | Avg Fwd ms | Avg Fwd SP GFLOPS | Avg Bwd ms | Avg Bwd SP GFLOPS | Avg Mem MB | Successful Samples | Skipped Samples | Status |
|---|---|---:|---:|---:|---|---:|---:|---:|---:|---:|---:|---:|---|
| throughput | n32_b1 | 32 | 1 | 1 | cufft_gpu | 0.012635 | 0.06 | 0.012523 | 0.06 | 0.00 | 5 | 0 | ok |
| throughput | n32_b4 | 32 | 4 | 1 | cufft_gpu | 0.011912 | 0.27 | 0.011381 | 0.28 | 0.00 | 5 | 0 | ok |
| throughput | n32_b16 | 32 | 16 | 1 | cufft_gpu | 0.012825 | 1.00 | 0.014406 | 0.89 | 0.01 | 5 | 0 | ok |
| throughput | n64_b1 | 64 | 1 | 1 | cufft_gpu | 0.011449 | 0.17 | 0.011047 | 0.17 | 0.00 | 5 | 0 | ok |
| throughput | n64_b4 | 64 | 4 | 1 | cufft_gpu | 0.012835 | 0.60 | 0.012801 | 0.60 | 0.00 | 5 | 0 | ok |
| throughput | n64_b16 | 64 | 16 | 1 | cufft_gpu | 0.012279 | 2.50 | 0.012185 | 2.52 | 0.02 | 5 | 0 | ok |
| throughput | n128_b1 | 128 | 1 | 1 | cufft_gpu | 0.012167 | 0.37 | 0.012552 | 0.36 | 0.00 | 5 | 0 | ok |
| throughput | n128_b4 | 128 | 4 | 1 | cufft_gpu | 0.014550 | 1.23 | 0.012975 | 1.38 | 0.01 | 5 | 0 | ok |
| throughput | n128_b16 | 128 | 16 | 1 | cufft_gpu | 0.018008 | 3.98 | 0.015184 | 4.72 | 0.03 | 5 | 0 | ok |
| throughput | n256_b1 | 256 | 1 | 1 | cufft_gpu | 0.015275 | 0.67 | 0.012140 | 0.84 | 0.00 | 5 | 0 | ok |
| throughput | n256_b4 | 256 | 4 | 1 | cufft_gpu | 0.013049 | 3.14 | 0.012466 | 3.29 | 0.02 | 5 | 0 | ok |
| throughput | n256_b16 | 256 | 16 | 1 | cufft_gpu | 0.017387 | 9.42 | 0.017421 | 9.40 | 0.06 | 5 | 0 | ok |
| throughput | n512_b1 | 512 | 1 | 1 | cufft_gpu | 0.013157 | 1.75 | 0.013599 | 1.69 | 0.01 | 5 | 0 | ok |
| throughput | n512_b4 | 512 | 4 | 1 | cufft_gpu | 0.016750 | 5.50 | 0.016347 | 5.64 | 0.03 | 5 | 0 | ok |
| throughput | n512_b16 | 512 | 16 | 1 | cufft_gpu | 0.023306 | 15.82 | 0.020625 | 17.87 | 0.12 | 5 | 0 | ok |
| throughput | n1024_b1 | 1024 | 1 | 1 | cufft_gpu | 0.015235 | 3.36 | 0.013375 | 3.83 | 0.02 | 5 | 0 | ok |
| throughput | n1024_b4 | 1024 | 4 | 1 | cufft_gpu | 0.021550 | 9.50 | 0.021758 | 9.41 | 0.06 | 5 | 0 | ok |
| throughput | n1024_b16 | 1024 | 16 | 1 | cufft_gpu | 0.028264 | 28.98 | 0.026310 | 31.14 | 0.25 | 5 | 0 | ok |
| throughput | n2048_b1 | 2048 | 1 | 1 | cufft_gpu | 0.020832 | 5.41 | 0.016367 | 6.88 | 0.03 | 5 | 0 | ok |
| throughput | n2048_b4 | 2048 | 4 | 1 | cufft_gpu | 0.023105 | 19.50 | 0.023322 | 19.32 | 0.12 | 5 | 0 | ok |
| throughput | n2048_b16 | 2048 | 16 | 1 | cufft_gpu | 0.039395 | 45.75 | 0.037709 | 47.79 | 0.50 | 5 | 0 | ok |
| throughput | n4096_b1 | 4096 | 1 | 1 | cufft_gpu | 0.022063 | 11.14 | 0.021826 | 11.26 | 0.06 | 5 | 0 | ok |
| throughput | n4096_b4 | 4096 | 4 | 1 | cufft_gpu | 0.027050 | 36.34 | 0.024422 | 40.25 | 0.25 | 5 | 0 | ok |
| throughput | n4096_b16 | 4096 | 16 | 1 | cufft_gpu | 0.060175 | 65.35 | 0.058380 | 67.35 | 1.00 | 5 | 0 | ok |
| throughput | n8192_b1 | 8192 | 1 | 1 | cufft_gpu | 0.027437 | 19.41 | 0.026388 | 20.18 | 0.12 | 5 | 0 | ok |
| throughput | n8192_b4 | 8192 | 4 | 1 | cufft_gpu | 0.043562 | 48.89 | 0.043856 | 48.57 | 0.50 | 5 | 0 | ok |
| throughput | n8192_b16 | 8192 | 16 | 1 | cufft_gpu | 0.105241 | 80.95 | 0.102728 | 82.93 | 2.00 | 5 | 0 | ok |
| throughput | n16384_b1 | 16384 | 1 | 1 | cufft_gpu | 0.033758 | 33.97 | 0.034492 | 33.25 | 0.25 | 5 | 0 | ok |
| throughput | n16384_b4 | 16384 | 4 | 1 | cufft_gpu | 0.065486 | 70.05 | 0.063904 | 71.79 | 1.00 | 5 | 0 | ok |
| throughput | n16384_b16 | 16384 | 16 | 1 | cufft_gpu | 0.193992 | 94.59 | 0.186003 | 98.65 | 4.00 | 5 | 0 | ok |
| throughput | n32768_b1 | 32768 | 1 | 1 | cufft_gpu | 0.043746 | 56.18 | 0.039745 | 61.83 | 0.50 | 5 | 0 | ok |
| throughput | n32768_b4 | 32768 | 4 | 1 | cufft_gpu | 0.105394 | 93.27 | 0.102656 | 95.76 | 2.00 | 5 | 0 | ok |
| throughput | n32768_b16 | 32768 | 16 | 1 | cufft_gpu | 0.366970 | 107.15 | 0.355111 | 110.73 | 8.00 | 5 | 0 | ok |
| throughput | n65536_b1 | 65536 | 1 | 1 | cufft_gpu | 0.062115 | 84.41 | 0.062054 | 84.49 | 1.00 | 5 | 0 | ok |
| throughput | n65536_b4 | 65536 | 4 | 1 | cufft_gpu | 0.192046 | 109.20 | 0.184086 | 113.92 | 4.00 | 5 | 0 | ok |
| throughput | n65536_b16 | 65536 | 16 | 1 | cufft_gpu | 0.711784 | 117.85 | 0.698564 | 120.08 | 16.00 | 5 | 0 | ok |
| throughput | n131072_b1 | 131072 | 1 | 1 | cufft_gpu | 0.105959 | 105.15 | 0.102971 | 108.20 | 2.00 | 5 | 0 | ok |
| throughput | n131072_b4 | 131072 | 4 | 1 | cufft_gpu | 0.366324 | 121.65 | 0.353313 | 126.13 | 8.00 | 5 | 0 | ok |
| throughput | n131072_b16 | 131072 | 16 | 1 | cufft_gpu | 1.388565 | 128.38 | 1.377570 | 129.40 | 32.00 | 5 | 0 | ok |
| throughput | n262144_b1 | 262144 | 1 | 1 | cufft_gpu | 0.194792 | 121.12 | 0.186210 | 126.70 | 4.00 | 5 | 0 | ok |
| throughput | n262144_b4 | 262144 | 4 | 1 | cufft_gpu | 0.719550 | 131.15 | 0.698333 | 135.14 | 16.00 | 5 | 0 | ok |
| throughput | n262144_b16 | 262144 | 16 | 1 | cufft_gpu | 2.874475 | 131.32 | 2.829820 | 133.40 | 64.00 | 5 | 0 | ok |
| throughput | n524288_b1 | 524288 | 1 | 1 | cufft_gpu | 0.366076 | 136.06 | 0.354445 | 140.52 | 8.00 | 5 | 0 | ok |
| throughput | n524288_b4 | 524288 | 4 | 1 | cufft_gpu | 1.387989 | 143.54 | 1.384082 | 143.94 | 32.00 | 5 | 0 | ok |
| throughput | n524288_b16 | 524288 | 16 | 1 | cufft_gpu | 5.645052 | 141.17 | 5.643559 | 141.21 | 128.00 | 5 | 0 | ok |
| throughput | n1048576_b1 | 1048576 | 1 | 1 | cufft_gpu | 0.703689 | 149.01 | 0.703747 | 149.00 | 16.00 | 5 | 0 | ok |
| throughput | n1048576_b4 | 1048576 | 4 | 1 | cufft_gpu | 2.799670 | 149.81 | 2.779971 | 150.88 | 64.00 | 5 | 0 | ok |
| throughput | n1048576_b16 | 1048576 | 16 | 1 | cufft_gpu | 11.176840 | 150.11 | 11.230347 | 149.39 | 256.00 | 5 | 0 | ok |
| throughput | n2097152_b1 | 2097152 | 1 | 1 | cufft_gpu | 1.393254 | 158.05 | 1.391538 | 158.24 | 32.00 | 5 | 0 | ok |
| throughput | n2097152_b4 | 2097152 | 4 | 1 | cufft_gpu | 5.552446 | 158.63 | 5.523448 | 159.47 | 128.00 | 5 | 0 | ok |
| throughput | n2097152_b16 | 2097152 | 16 | 1 | cufft_gpu | 22.321652 | 157.84 | 22.440564 | 157.00 | 512.00 | 5 | 0 | ok |
| throughput | n4194304_b1 | 4194304 | 1 | 1 | cufft_gpu | 2.836825 | 162.64 | 2.802053 | 164.66 | 64.00 | 5 | 0 | ok |
| throughput | n4194304_b4 | 4194304 | 4 | 1 | cufft_gpu | 11.288243 | 163.49 | 11.288024 | 163.49 | 256.00 | 5 | 0 | ok |
| throughput | n4194304_b16 | 4194304 | 16 | 1 | cufft_gpu | 45.187251 | 163.36 | 45.202932 | 163.31 | 1024.00 | 5 | 0 | ok |
| batch_scaling | n16384_b1_t1 | 16384 | 1 | 1 | cufft_gpu_batch_scaling | 0.033975 | 33.76 | 0.034789 | 32.97 | 0.25 | 5 | 0 | ok |
| batch_scaling | n16384_b4_t1 | 16384 | 4 | 1 | cufft_gpu_batch_scaling | 0.064853 | 70.74 | 0.065406 | 70.14 | 1.00 | 5 | 0 | ok |
| batch_scaling | n16384_b16_t1 | 16384 | 16 | 1 | cufft_gpu_batch_scaling | 0.191976 | 95.59 | 0.185798 | 98.76 | 4.00 | 5 | 0 | ok |
| batch_scaling | n16384_b64_t1 | 16384 | 64 | 1 | cufft_gpu_batch_scaling | 0.687272 | 106.80 | 0.673797 | 108.94 | 16.00 | 5 | 0 | ok |
| batch_scaling | n16384_b256_t1 | 16384 | 256 | 1 | cufft_gpu_batch_scaling | 2.797230 | 104.96 | 2.670336 | 109.95 | 64.00 | 5 | 0 | ok |
