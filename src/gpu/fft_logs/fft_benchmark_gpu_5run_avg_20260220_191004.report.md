# GPU FFT Combined Report (Averaged Across Runs)

- Generated at: Fri Feb 20 19:10:04 IST 2026
- Manifest: `fft_logs/fft_benchmark_gpu_5run_32_to_4194304.manifest.txt`
- Runs combined: 5
- Precision mode: single precision (cuFFT C2C)
- Average latency (`ms`): arithmetic mean over successful samples.
- GFLOPS derivation: recomputed from averaged latency.
  `avg_sp_gflops = (5 * N * log2(N) * batch) / (avg_ms * 1e6)`

## Run Files

| Run | Log | Report |
|---|---|---|
| 1 | `fft_logs/fft_benchmark_gpu_20260220_190913.log` | `fft_logs/fft_benchmark_gpu_20260220_190913.report.md` |
| 2 | `fft_logs/fft_benchmark_gpu_20260220_190923.log` | `fft_logs/fft_benchmark_gpu_20260220_190923.report.md` |
| 3 | `fft_logs/fft_benchmark_gpu_20260220_190933.log` | `fft_logs/fft_benchmark_gpu_20260220_190933.report.md` |
| 4 | `fft_logs/fft_benchmark_gpu_20260220_190943.log` | `fft_logs/fft_benchmark_gpu_20260220_190943.report.md` |
| 5 | `fft_logs/fft_benchmark_gpu_20260220_190953.log` | `fft_logs/fft_benchmark_gpu_20260220_190953.report.md` |

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
| throughput | n32_b1 | 32 | 1 | 1 | cufft_gpu | 0.011907 | 0.07 | 0.012600 | 0.06 | 0.00 | 5 | 0 | ok |
| throughput | n32_b4 | 32 | 4 | 1 | cufft_gpu | 0.013051 | 0.25 | 0.012893 | 0.25 | 0.00 | 5 | 0 | ok |
| throughput | n32_b16 | 32 | 16 | 1 | cufft_gpu | 0.012917 | 0.99 | 0.013134 | 0.97 | 0.02 | 5 | 0 | ok |
| throughput | n64_b1 | 64 | 1 | 1 | cufft_gpu | 0.012055 | 0.16 | 0.012627 | 0.15 | 0.00 | 5 | 0 | ok |
| throughput | n64_b4 | 64 | 4 | 1 | cufft_gpu | 0.014340 | 0.54 | 0.013303 | 0.58 | 0.01 | 5 | 0 | ok |
| throughput | n64_b16 | 64 | 16 | 1 | cufft_gpu | 0.012317 | 2.49 | 0.012967 | 2.37 | 0.03 | 5 | 0 | ok |
| throughput | n128_b1 | 128 | 1 | 1 | cufft_gpu | 0.012518 | 0.36 | 0.012272 | 0.37 | 0.00 | 5 | 0 | ok |
| throughput | n128_b4 | 128 | 4 | 1 | cufft_gpu | 0.013831 | 1.30 | 0.013660 | 1.31 | 0.02 | 5 | 0 | ok |
| throughput | n128_b16 | 128 | 16 | 1 | cufft_gpu | 0.016126 | 4.45 | 0.016918 | 4.24 | 0.06 | 5 | 0 | ok |
| throughput | n256_b1 | 256 | 1 | 1 | cufft_gpu | 0.013020 | 0.79 | 0.012963 | 0.79 | 0.01 | 5 | 0 | ok |
| throughput | n256_b4 | 256 | 4 | 1 | cufft_gpu | 0.012141 | 3.37 | 0.012474 | 3.28 | 0.03 | 5 | 0 | ok |
| throughput | n256_b16 | 256 | 16 | 1 | cufft_gpu | 0.018532 | 8.84 | 0.016908 | 9.69 | 0.12 | 5 | 0 | ok |
| throughput | n512_b1 | 512 | 1 | 1 | cufft_gpu | 0.013624 | 1.69 | 0.012082 | 1.91 | 0.02 | 5 | 0 | ok |
| throughput | n512_b4 | 512 | 4 | 1 | cufft_gpu | 0.015030 | 6.13 | 0.018361 | 5.02 | 0.06 | 5 | 0 | ok |
| throughput | n512_b16 | 512 | 16 | 1 | cufft_gpu | 0.018658 | 19.76 | 0.021933 | 16.81 | 0.25 | 5 | 0 | ok |
| throughput | n1024_b1 | 1024 | 1 | 1 | cufft_gpu | 0.015442 | 3.32 | 0.013261 | 3.86 | 0.03 | 5 | 0 | ok |
| throughput | n1024_b4 | 1024 | 4 | 1 | cufft_gpu | 0.019685 | 10.40 | 0.020536 | 9.97 | 0.12 | 5 | 0 | ok |
| throughput | n1024_b16 | 1024 | 16 | 1 | cufft_gpu | 0.028491 | 28.75 | 0.029653 | 27.63 | 0.50 | 5 | 0 | ok |
| throughput | n2048_b1 | 2048 | 1 | 1 | cufft_gpu | 0.018344 | 6.14 | 0.018507 | 6.09 | 0.06 | 5 | 0 | ok |
| throughput | n2048_b4 | 2048 | 4 | 1 | cufft_gpu | 0.023782 | 18.95 | 0.022153 | 20.34 | 0.25 | 5 | 0 | ok |
| throughput | n2048_b16 | 2048 | 16 | 1 | cufft_gpu | 0.038445 | 46.88 | 0.038725 | 46.54 | 1.00 | 5 | 0 | ok |
| throughput | n4096_b1 | 4096 | 1 | 1 | cufft_gpu | 0.020797 | 11.82 | 0.019998 | 12.29 | 0.12 | 5 | 0 | ok |
| throughput | n4096_b4 | 4096 | 4 | 1 | cufft_gpu | 0.025916 | 37.93 | 0.028285 | 34.76 | 0.50 | 5 | 0 | ok |
| throughput | n4096_b16 | 4096 | 16 | 1 | cufft_gpu | 0.060061 | 65.47 | 0.058894 | 66.77 | 2.00 | 5 | 0 | ok |
| throughput | n8192_b1 | 8192 | 1 | 1 | cufft_gpu | 0.026333 | 20.22 | 0.024028 | 22.16 | 0.25 | 5 | 0 | ok |
| throughput | n8192_b4 | 8192 | 4 | 1 | cufft_gpu | 0.043170 | 49.34 | 0.042160 | 50.52 | 1.00 | 5 | 0 | ok |
| throughput | n8192_b16 | 8192 | 16 | 1 | cufft_gpu | 0.102809 | 82.87 | 0.102271 | 83.31 | 4.00 | 5 | 0 | ok |
| throughput | n16384_b1 | 16384 | 1 | 1 | cufft_gpu | 0.035159 | 32.62 | 0.033838 | 33.89 | 0.50 | 5 | 0 | ok |
| throughput | n16384_b4 | 16384 | 4 | 1 | cufft_gpu | 0.064728 | 70.87 | 0.064574 | 71.04 | 2.00 | 5 | 0 | ok |
| throughput | n16384_b16 | 16384 | 16 | 1 | cufft_gpu | 0.190151 | 96.50 | 0.186314 | 98.49 | 8.00 | 5 | 0 | ok |
| throughput | n32768_b1 | 32768 | 1 | 1 | cufft_gpu | 0.042623 | 57.66 | 0.042857 | 57.34 | 1.00 | 5 | 0 | ok |
| throughput | n32768_b4 | 32768 | 4 | 1 | cufft_gpu | 0.103387 | 95.08 | 0.102259 | 96.13 | 4.00 | 5 | 0 | ok |
| throughput | n32768_b16 | 32768 | 16 | 1 | cufft_gpu | 0.362601 | 108.44 | 0.355087 | 110.74 | 16.00 | 5 | 0 | ok |
| throughput | n65536_b1 | 65536 | 1 | 1 | cufft_gpu | 0.062420 | 83.99 | 0.061365 | 85.44 | 2.00 | 5 | 0 | ok |
| throughput | n65536_b4 | 65536 | 4 | 1 | cufft_gpu | 0.189140 | 110.88 | 0.183835 | 114.08 | 8.00 | 5 | 0 | ok |
| throughput | n65536_b16 | 65536 | 16 | 1 | cufft_gpu | 0.709083 | 118.30 | 0.698354 | 120.12 | 32.00 | 5 | 0 | ok |
| throughput | n131072_b1 | 131072 | 1 | 1 | cufft_gpu | 0.105386 | 105.72 | 0.103334 | 107.82 | 4.00 | 5 | 0 | ok |
| throughput | n131072_b4 | 131072 | 4 | 1 | cufft_gpu | 0.361954 | 123.12 | 0.353085 | 126.21 | 16.00 | 5 | 0 | ok |
| throughput | n131072_b16 | 131072 | 16 | 1 | cufft_gpu | 1.388441 | 128.39 | 1.376940 | 129.46 | 64.00 | 5 | 0 | ok |
| throughput | n262144_b1 | 262144 | 1 | 1 | cufft_gpu | 0.193738 | 121.78 | 0.185353 | 127.29 | 8.00 | 5 | 0 | ok |
| throughput | n262144_b4 | 262144 | 4 | 1 | cufft_gpu | 0.710445 | 132.83 | 0.698028 | 135.20 | 32.00 | 5 | 0 | ok |
| throughput | n262144_b16 | 262144 | 16 | 1 | cufft_gpu | 2.820006 | 133.86 | 2.788303 | 135.38 | 128.00 | 5 | 0 | ok |
| throughput | n524288_b1 | 524288 | 1 | 1 | cufft_gpu | 0.363622 | 136.98 | 0.355221 | 140.22 | 16.00 | 5 | 0 | ok |
| throughput | n524288_b4 | 524288 | 4 | 1 | cufft_gpu | 1.386178 | 143.73 | 1.385016 | 143.85 | 64.00 | 5 | 0 | ok |
| throughput | n524288_b16 | 524288 | 16 | 1 | cufft_gpu | 5.606096 | 142.15 | 5.620163 | 141.80 | 256.00 | 5 | 0 | ok |
| throughput | n1048576_b1 | 1048576 | 1 | 1 | cufft_gpu | 0.703480 | 149.06 | 0.703191 | 149.12 | 32.00 | 5 | 0 | ok |
| throughput | n1048576_b4 | 1048576 | 4 | 1 | cufft_gpu | 2.776443 | 151.07 | 2.775293 | 151.13 | 128.00 | 5 | 0 | ok |
| throughput | n1048576_b16 | 1048576 | 16 | 1 | cufft_gpu | 11.154550 | 150.41 | 11.197318 | 149.83 | 512.00 | 5 | 0 | ok |
| throughput | n2097152_b1 | 2097152 | 1 | 1 | cufft_gpu | 1.391461 | 158.25 | 1.392095 | 158.18 | 64.00 | 5 | 0 | ok |
| throughput | n2097152_b4 | 2097152 | 4 | 1 | cufft_gpu | 5.536447 | 159.09 | 5.566585 | 158.23 | 256.00 | 5 | 0 | ok |
| throughput | n2097152_b16 | 2097152 | 16 | 1 | cufft_gpu | 22.265980 | 158.23 | 22.352053 | 157.62 | 1024.00 | 5 | 0 | ok |
| throughput | n4194304_b1 | 4194304 | 1 | 1 | cufft_gpu | 2.813431 | 163.99 | 2.805461 | 164.46 | 128.00 | 5 | 0 | ok |
| throughput | n4194304_b4 | 4194304 | 4 | 1 | cufft_gpu | 11.204174 | 164.71 | 11.227242 | 164.38 | 512.00 | 5 | 0 | ok |
| throughput | n4194304_b16 | 4194304 | 16 | 1 | cufft_gpu | 45.103596 | 163.67 | 45.206364 | 163.30 | 2048.00 | 5 | 0 | ok |
| batch_scaling | n16384_b1_t1 | 16384 | 1 | 1 | cufft_gpu_batch_scaling | 0.033884 | 33.85 | 0.033246 | 34.50 | 0.50 | 5 | 0 | ok |
| batch_scaling | n16384_b4_t1 | 16384 | 4 | 1 | cufft_gpu_batch_scaling | 0.064597 | 71.02 | 0.064447 | 71.18 | 2.00 | 5 | 0 | ok |
| batch_scaling | n16384_b16_t1 | 16384 | 16 | 1 | cufft_gpu_batch_scaling | 0.192116 | 95.52 | 0.186556 | 98.36 | 8.00 | 5 | 0 | ok |
| batch_scaling | n16384_b64_t1 | 16384 | 64 | 1 | cufft_gpu_batch_scaling | 0.681210 | 107.75 | 0.673597 | 108.97 | 32.00 | 5 | 0 | ok |
| batch_scaling | n16384_b256_t1 | 16384 | 256 | 1 | cufft_gpu_batch_scaling | 2.667854 | 110.05 | 2.653872 | 110.63 | 128.00 | 5 | 0 | ok |
