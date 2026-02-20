# GPU FFT Combined Report (Averaged Across Runs)

- Generated at: Fri Feb 20 10:40:25 IST 2026
- Manifest: `fft_logs/fft_benchmark_gpu_5run_repeat3_32_to_4194304.manifest.txt`
- Runs combined: 5
- Precision mode: single precision (cuFFT C2C)
- Average latency (`ms`): arithmetic mean over successful samples.
- GFLOPS derivation: recomputed from averaged latency.
  `avg_sp_gflops = (5 * N * log2(N) * batch) / (avg_ms * 1e6)`

## Run Files

| Run | Log | Report |
|---|---|---|
| 1 | `fft_logs/fft_benchmark_gpu_20260220_103927.log` | `fft_logs/fft_benchmark_gpu_20260220_103927.report.md` |
| 2 | `fft_logs/fft_benchmark_gpu_20260220_103936.log` | `fft_logs/fft_benchmark_gpu_20260220_103936.report.md` |
| 3 | `fft_logs/fft_benchmark_gpu_20260220_103946.log` | `fft_logs/fft_benchmark_gpu_20260220_103946.report.md` |
| 4 | `fft_logs/fft_benchmark_gpu_20260220_103955.log` | `fft_logs/fft_benchmark_gpu_20260220_103955.report.md` |
| 5 | `fft_logs/fft_benchmark_gpu_20260220_104005.log` | `fft_logs/fft_benchmark_gpu_20260220_104005.report.md` |

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
| throughput | n32_b1 | 32 | 1 | 1 | cufft_gpu | 0.012159 | 0.07 | 0.012323 | 0.06 | 0.00 | 5 | 0 | ok |
| throughput | n32_b4 | 32 | 4 | 1 | cufft_gpu | 0.012815 | 0.25 | 0.013020 | 0.25 | 0.00 | 5 | 0 | ok |
| throughput | n32_b16 | 32 | 16 | 1 | cufft_gpu | 0.011921 | 1.07 | 0.014314 | 0.89 | 0.01 | 5 | 0 | ok |
| throughput | n64_b1 | 64 | 1 | 1 | cufft_gpu | 0.012742 | 0.15 | 0.012890 | 0.15 | 0.00 | 5 | 0 | ok |
| throughput | n64_b4 | 64 | 4 | 1 | cufft_gpu | 0.013511 | 0.57 | 0.013365 | 0.57 | 0.00 | 5 | 0 | ok |
| throughput | n64_b16 | 64 | 16 | 1 | cufft_gpu | 0.013818 | 2.22 | 0.013654 | 2.25 | 0.02 | 5 | 0 | ok |
| throughput | n128_b1 | 128 | 1 | 1 | cufft_gpu | 0.012489 | 0.36 | 0.012479 | 0.36 | 0.00 | 5 | 0 | ok |
| throughput | n128_b4 | 128 | 4 | 1 | cufft_gpu | 0.013689 | 1.31 | 0.012626 | 1.42 | 0.01 | 5 | 0 | ok |
| throughput | n128_b16 | 128 | 16 | 1 | cufft_gpu | 0.017743 | 4.04 | 0.016506 | 4.34 | 0.03 | 5 | 0 | ok |
| throughput | n256_b1 | 256 | 1 | 1 | cufft_gpu | 0.012673 | 0.81 | 0.012879 | 0.80 | 0.00 | 5 | 0 | ok |
| throughput | n256_b4 | 256 | 4 | 1 | cufft_gpu | 0.013874 | 2.95 | 0.015015 | 2.73 | 0.02 | 5 | 0 | ok |
| throughput | n256_b16 | 256 | 16 | 1 | cufft_gpu | 0.019440 | 8.43 | 0.016642 | 9.84 | 0.06 | 5 | 0 | ok |
| throughput | n512_b1 | 512 | 1 | 1 | cufft_gpu | 0.013461 | 1.71 | 0.013585 | 1.70 | 0.01 | 5 | 0 | ok |
| throughput | n512_b4 | 512 | 4 | 1 | cufft_gpu | 0.016063 | 5.74 | 0.016281 | 5.66 | 0.03 | 5 | 0 | ok |
| throughput | n512_b16 | 512 | 16 | 1 | cufft_gpu | 0.021226 | 17.37 | 0.019022 | 19.38 | 0.12 | 5 | 0 | ok |
| throughput | n1024_b1 | 1024 | 1 | 1 | cufft_gpu | 0.014246 | 3.59 | 0.012823 | 3.99 | 0.02 | 5 | 0 | ok |
| throughput | n1024_b4 | 1024 | 4 | 1 | cufft_gpu | 0.019939 | 10.27 | 0.020941 | 9.78 | 0.06 | 5 | 0 | ok |
| throughput | n1024_b16 | 1024 | 16 | 1 | cufft_gpu | 0.027153 | 30.17 | 0.025491 | 32.14 | 0.25 | 5 | 0 | ok |
| throughput | n2048_b1 | 2048 | 1 | 1 | cufft_gpu | 0.021774 | 5.17 | 0.017347 | 6.49 | 0.03 | 5 | 0 | ok |
| throughput | n2048_b4 | 2048 | 4 | 1 | cufft_gpu | 0.026385 | 17.08 | 0.024052 | 18.73 | 0.12 | 5 | 0 | ok |
| throughput | n2048_b16 | 2048 | 16 | 1 | cufft_gpu | 0.039390 | 45.75 | 0.036036 | 50.01 | 0.50 | 5 | 0 | ok |
| throughput | n4096_b1 | 4096 | 1 | 1 | cufft_gpu | 0.021024 | 11.69 | 0.020797 | 11.82 | 0.06 | 5 | 0 | ok |
| throughput | n4096_b4 | 4096 | 4 | 1 | cufft_gpu | 0.029401 | 33.44 | 0.025767 | 38.15 | 0.25 | 5 | 0 | ok |
| throughput | n4096_b16 | 4096 | 16 | 1 | cufft_gpu | 0.059875 | 65.67 | 0.058335 | 67.41 | 1.00 | 5 | 0 | ok |
| throughput | n8192_b1 | 8192 | 1 | 1 | cufft_gpu | 0.026807 | 19.86 | 0.026839 | 19.84 | 0.12 | 5 | 0 | ok |
| throughput | n8192_b4 | 8192 | 4 | 1 | cufft_gpu | 0.042802 | 49.76 | 0.041462 | 51.37 | 0.50 | 5 | 0 | ok |
| throughput | n8192_b16 | 8192 | 16 | 1 | cufft_gpu | 0.104613 | 81.44 | 0.102726 | 82.94 | 2.00 | 5 | 0 | ok |
| throughput | n16384_b1 | 16384 | 1 | 1 | cufft_gpu | 0.034851 | 32.91 | 0.034257 | 33.48 | 0.25 | 5 | 0 | ok |
| throughput | n16384_b4 | 16384 | 4 | 1 | cufft_gpu | 0.064805 | 70.79 | 0.064523 | 71.10 | 1.00 | 5 | 0 | ok |
| throughput | n16384_b16 | 16384 | 16 | 1 | cufft_gpu | 0.192281 | 95.43 | 0.186623 | 98.33 | 4.00 | 5 | 0 | ok |
| throughput | n32768_b1 | 32768 | 1 | 1 | cufft_gpu | 0.041987 | 58.53 | 0.042364 | 58.01 | 0.50 | 5 | 0 | ok |
| throughput | n32768_b4 | 32768 | 4 | 1 | cufft_gpu | 0.102828 | 95.60 | 0.102535 | 95.87 | 2.00 | 5 | 0 | ok |
| throughput | n32768_b16 | 32768 | 16 | 1 | cufft_gpu | 0.367628 | 106.96 | 0.355331 | 110.66 | 8.00 | 5 | 0 | ok |
| throughput | n65536_b1 | 65536 | 1 | 1 | cufft_gpu | 0.061930 | 84.66 | 0.060969 | 85.99 | 1.00 | 5 | 0 | ok |
| throughput | n65536_b4 | 65536 | 4 | 1 | cufft_gpu | 0.190675 | 109.99 | 0.184526 | 113.65 | 4.00 | 5 | 0 | ok |
| throughput | n65536_b16 | 65536 | 16 | 1 | cufft_gpu | 0.718398 | 116.77 | 0.697757 | 120.22 | 16.00 | 5 | 0 | ok |
| throughput | n131072_b1 | 131072 | 1 | 1 | cufft_gpu | 0.103686 | 107.45 | 0.103385 | 107.76 | 2.00 | 5 | 0 | ok |
| throughput | n131072_b4 | 131072 | 4 | 1 | cufft_gpu | 0.365767 | 121.84 | 0.353383 | 126.11 | 8.00 | 5 | 0 | ok |
| throughput | n131072_b16 | 131072 | 16 | 1 | cufft_gpu | 1.394316 | 127.85 | 1.376669 | 129.48 | 32.00 | 5 | 0 | ok |
| throughput | n262144_b1 | 262144 | 1 | 1 | cufft_gpu | 0.194536 | 121.28 | 0.186086 | 126.79 | 4.00 | 5 | 0 | ok |
| throughput | n262144_b4 | 262144 | 4 | 1 | cufft_gpu | 0.719382 | 131.18 | 0.698491 | 135.11 | 16.00 | 5 | 0 | ok |
| throughput | n262144_b16 | 262144 | 16 | 1 | cufft_gpu | 2.833841 | 133.21 | 2.757750 | 136.88 | 64.00 | 5 | 0 | ok |
| throughput | n524288_b1 | 524288 | 1 | 1 | cufft_gpu | 0.367511 | 135.53 | 0.354207 | 140.62 | 8.00 | 5 | 0 | ok |
| throughput | n524288_b4 | 524288 | 4 | 1 | cufft_gpu | 1.389225 | 143.41 | 1.383124 | 144.04 | 32.00 | 5 | 0 | ok |
| throughput | n524288_b16 | 524288 | 16 | 1 | cufft_gpu | 5.590318 | 142.55 | 5.597835 | 142.36 | 128.00 | 5 | 0 | ok |
| throughput | n1048576_b1 | 1048576 | 1 | 1 | cufft_gpu | 0.709240 | 147.85 | 0.703592 | 149.03 | 16.00 | 5 | 0 | ok |
| throughput | n1048576_b4 | 1048576 | 4 | 1 | cufft_gpu | 2.773162 | 151.25 | 2.769749 | 151.43 | 64.00 | 5 | 0 | ok |
| throughput | n1048576_b16 | 1048576 | 16 | 1 | cufft_gpu | 11.202930 | 149.76 | 11.200683 | 149.79 | 256.00 | 5 | 0 | ok |
| throughput | n2097152_b1 | 2097152 | 1 | 1 | cufft_gpu | 1.393265 | 158.05 | 1.392672 | 158.11 | 32.00 | 5 | 0 | ok |
| throughput | n2097152_b4 | 2097152 | 4 | 1 | cufft_gpu | 5.548025 | 158.76 | 5.525832 | 159.40 | 128.00 | 5 | 0 | ok |
| throughput | n2097152_b16 | 2097152 | 16 | 1 | cufft_gpu | 22.287440 | 158.08 | 22.343716 | 157.68 | 512.00 | 5 | 0 | ok |
| throughput | n4194304_b1 | 4194304 | 1 | 1 | cufft_gpu | 2.802062 | 164.65 | 2.775683 | 166.22 | 64.00 | 5 | 0 | ok |
| throughput | n4194304_b4 | 4194304 | 4 | 1 | cufft_gpu | 11.276729 | 163.66 | 11.245230 | 164.11 | 256.00 | 5 | 0 | ok |
| throughput | n4194304_b16 | 4194304 | 16 | 1 | cufft_gpu | 45.071308 | 163.78 | 45.109342 | 163.65 | 1024.00 | 5 | 0 | ok |
| batch_scaling | n16384_b1_t1 | 16384 | 1 | 1 | cufft_gpu_batch_scaling | 0.034397 | 33.34 | 0.033496 | 34.24 | 0.25 | 5 | 0 | ok |
| batch_scaling | n16384_b4_t1 | 16384 | 4 | 1 | cufft_gpu_batch_scaling | 0.064989 | 70.59 | 0.065410 | 70.13 | 1.00 | 5 | 0 | ok |
| batch_scaling | n16384_b16_t1 | 16384 | 16 | 1 | cufft_gpu_batch_scaling | 0.191900 | 95.62 | 0.186132 | 98.59 | 4.00 | 5 | 0 | ok |
| batch_scaling | n16384_b64_t1 | 16384 | 64 | 1 | cufft_gpu_batch_scaling | 0.685925 | 107.01 | 0.673519 | 108.98 | 16.00 | 5 | 0 | ok |
| batch_scaling | n16384_b256_t1 | 16384 | 256 | 1 | cufft_gpu_batch_scaling | 2.770005 | 105.99 | 2.691462 | 109.09 | 64.00 | 5 | 0 | ok |
