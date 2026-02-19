# GPU FFT Combined Report (Averaged Across Runs)

- Generated at: Thu Feb 19 16:32:35 IST 2026
- Manifest: `fft_logs/fft_benchmark_gpu_5run_32_to_4194304.manifest.txt`
- Runs combined: 5
- Precision mode: single precision (cuFFT C2C)
- Average latency (`ms`): arithmetic mean over successful samples.
- GFLOPS derivation: recomputed from averaged latency.
  `avg_sp_gflops = (5 * N * log2(N) * batch) / (avg_ms * 1e6)`

## Run Files

| Run | Log | Report |
|---|---|---|
| 1 | `fft_logs/fft_benchmark_gpu_20260219_163106.log` | `fft_logs/fft_benchmark_gpu_20260219_163106.report.md` |
| 2 | `fft_logs/fft_benchmark_gpu_20260219_163137.log` | `fft_logs/fft_benchmark_gpu_20260219_163137.report.md` |
| 3 | `fft_logs/fft_benchmark_gpu_20260219_163147.log` | `fft_logs/fft_benchmark_gpu_20260219_163147.report.md` |
| 4 | `fft_logs/fft_benchmark_gpu_20260219_163156.log` | `fft_logs/fft_benchmark_gpu_20260219_163156.report.md` |
| 5 | `fft_logs/fft_benchmark_gpu_20260219_163206.log` | `fft_logs/fft_benchmark_gpu_20260219_163206.report.md` |

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
| throughput | n32_b1 | 32 | 1 | 1 | cufft_gpu | 0.010798 | 0.07 | 0.010289 | 0.08 | 0.00 | 5 | 0 | ok |
| throughput | n32_b4 | 32 | 4 | 1 | cufft_gpu | 0.010668 | 0.30 | 0.012059 | 0.27 | 0.00 | 5 | 0 | ok |
| throughput | n32_b16 | 32 | 16 | 1 | cufft_gpu | 0.011998 | 1.07 | 0.012103 | 1.06 | 0.01 | 5 | 0 | ok |
| throughput | n64_b1 | 64 | 1 | 1 | cufft_gpu | 0.010426 | 0.18 | 0.009921 | 0.19 | 0.00 | 5 | 0 | ok |
| throughput | n64_b4 | 64 | 4 | 1 | cufft_gpu | 0.010596 | 0.72 | 0.010726 | 0.72 | 0.00 | 5 | 0 | ok |
| throughput | n64_b16 | 64 | 16 | 1 | cufft_gpu | 0.012096 | 2.54 | 0.012604 | 2.44 | 0.02 | 5 | 0 | ok |
| throughput | n128_b1 | 128 | 1 | 1 | cufft_gpu | 0.012085 | 0.37 | 0.012821 | 0.35 | 0.00 | 5 | 0 | ok |
| throughput | n128_b4 | 128 | 4 | 1 | cufft_gpu | 0.013036 | 1.37 | 0.012559 | 1.43 | 0.01 | 5 | 0 | ok |
| throughput | n128_b16 | 128 | 16 | 1 | cufft_gpu | 0.014881 | 4.82 | 0.017853 | 4.02 | 0.03 | 5 | 0 | ok |
| throughput | n256_b1 | 256 | 1 | 1 | cufft_gpu | 0.013650 | 0.75 | 0.012917 | 0.79 | 0.00 | 5 | 0 | ok |
| throughput | n256_b4 | 256 | 4 | 1 | cufft_gpu | 0.012759 | 3.21 | 0.013206 | 3.10 | 0.02 | 5 | 0 | ok |
| throughput | n256_b16 | 256 | 16 | 1 | cufft_gpu | 0.017100 | 9.58 | 0.018034 | 9.09 | 0.06 | 5 | 0 | ok |
| throughput | n512_b1 | 512 | 1 | 1 | cufft_gpu | 0.012370 | 1.86 | 0.013864 | 1.66 | 0.01 | 5 | 0 | ok |
| throughput | n512_b4 | 512 | 4 | 1 | cufft_gpu | 0.017716 | 5.20 | 0.017019 | 5.42 | 0.03 | 5 | 0 | ok |
| throughput | n512_b16 | 512 | 16 | 1 | cufft_gpu | 0.019089 | 19.31 | 0.019832 | 18.59 | 0.12 | 5 | 0 | ok |
| throughput | n1024_b1 | 1024 | 1 | 1 | cufft_gpu | 0.013283 | 3.85 | 0.014783 | 3.46 | 0.02 | 5 | 0 | ok |
| throughput | n1024_b4 | 1024 | 4 | 1 | cufft_gpu | 0.020649 | 9.92 | 0.020775 | 9.86 | 0.06 | 5 | 0 | ok |
| throughput | n1024_b16 | 1024 | 16 | 1 | cufft_gpu | 0.028573 | 28.67 | 0.026834 | 30.53 | 0.25 | 5 | 0 | ok |
| throughput | n2048_b1 | 2048 | 1 | 1 | cufft_gpu | 0.018585 | 6.06 | 0.018951 | 5.94 | 0.03 | 5 | 0 | ok |
| throughput | n2048_b4 | 2048 | 4 | 1 | cufft_gpu | 0.024891 | 18.10 | 0.020099 | 22.42 | 0.12 | 5 | 0 | ok |
| throughput | n2048_b16 | 2048 | 16 | 1 | cufft_gpu | 0.039593 | 45.52 | 0.037070 | 48.62 | 0.50 | 5 | 0 | ok |
| throughput | n4096_b1 | 4096 | 1 | 1 | cufft_gpu | 0.018689 | 13.15 | 0.020963 | 11.72 | 0.06 | 5 | 0 | ok |
| throughput | n4096_b4 | 4096 | 4 | 1 | cufft_gpu | 0.029412 | 33.42 | 0.028127 | 34.95 | 0.25 | 5 | 0 | ok |
| throughput | n4096_b16 | 4096 | 16 | 1 | cufft_gpu | 0.059982 | 65.56 | 0.058421 | 67.31 | 1.00 | 5 | 0 | ok |
| throughput | n8192_b1 | 8192 | 1 | 1 | cufft_gpu | 0.026447 | 20.13 | 0.026335 | 20.22 | 0.12 | 5 | 0 | ok |
| throughput | n8192_b4 | 8192 | 4 | 1 | cufft_gpu | 0.043155 | 49.36 | 0.042454 | 50.17 | 0.50 | 5 | 0 | ok |
| throughput | n8192_b16 | 8192 | 16 | 1 | cufft_gpu | 0.104178 | 81.78 | 0.102045 | 83.49 | 2.00 | 5 | 0 | ok |
| throughput | n16384_b1 | 16384 | 1 | 1 | cufft_gpu | 0.034535 | 33.21 | 0.034837 | 32.92 | 0.25 | 5 | 0 | ok |
| throughput | n16384_b4 | 16384 | 4 | 1 | cufft_gpu | 0.065111 | 70.46 | 0.064466 | 71.16 | 1.00 | 5 | 0 | ok |
| throughput | n16384_b16 | 16384 | 16 | 1 | cufft_gpu | 0.191319 | 95.91 | 0.186117 | 98.59 | 4.00 | 5 | 0 | ok |
| throughput | n32768_b1 | 32768 | 1 | 1 | cufft_gpu | 0.042278 | 58.13 | 0.043795 | 56.12 | 0.50 | 5 | 0 | ok |
| throughput | n32768_b4 | 32768 | 4 | 1 | cufft_gpu | 0.104208 | 94.33 | 0.102277 | 96.12 | 2.00 | 5 | 0 | ok |
| throughput | n32768_b16 | 32768 | 16 | 1 | cufft_gpu | 0.365147 | 107.69 | 0.355929 | 110.48 | 8.00 | 5 | 0 | ok |
| throughput | n65536_b1 | 65536 | 1 | 1 | cufft_gpu | 0.061398 | 85.39 | 0.060749 | 86.30 | 1.00 | 5 | 0 | ok |
| throughput | n65536_b4 | 65536 | 4 | 1 | cufft_gpu | 0.191172 | 109.70 | 0.184183 | 113.86 | 4.00 | 5 | 0 | ok |
| throughput | n65536_b16 | 65536 | 16 | 1 | cufft_gpu | 0.716559 | 117.07 | 0.698596 | 120.08 | 16.00 | 5 | 0 | ok |
| throughput | n131072_b1 | 131072 | 1 | 1 | cufft_gpu | 0.103901 | 107.23 | 0.103338 | 107.81 | 2.00 | 5 | 0 | ok |
| throughput | n131072_b4 | 131072 | 4 | 1 | cufft_gpu | 0.365801 | 121.83 | 0.353212 | 126.17 | 8.00 | 5 | 0 | ok |
| throughput | n131072_b16 | 131072 | 16 | 1 | cufft_gpu | 1.393913 | 127.88 | 1.377537 | 129.40 | 32.00 | 5 | 0 | ok |
| throughput | n262144_b1 | 262144 | 1 | 1 | cufft_gpu | 0.193801 | 121.74 | 0.187449 | 125.86 | 4.00 | 5 | 0 | ok |
| throughput | n262144_b4 | 262144 | 4 | 1 | cufft_gpu | 0.712891 | 132.38 | 0.698426 | 135.12 | 16.00 | 5 | 0 | ok |
| throughput | n262144_b16 | 262144 | 16 | 1 | cufft_gpu | 2.786869 | 135.45 | 2.770012 | 136.28 | 64.00 | 5 | 0 | ok |
| throughput | n524288_b1 | 524288 | 1 | 1 | cufft_gpu | 0.361053 | 137.95 | 0.354619 | 140.45 | 8.00 | 5 | 0 | ok |
| throughput | n524288_b4 | 524288 | 4 | 1 | cufft_gpu | 1.384876 | 143.86 | 1.385418 | 143.80 | 32.00 | 5 | 0 | ok |
| throughput | n524288_b16 | 524288 | 16 | 1 | cufft_gpu | 5.615893 | 141.90 | 5.625481 | 141.66 | 128.00 | 5 | 0 | ok |
| throughput | n1048576_b1 | 1048576 | 1 | 1 | cufft_gpu | 0.708034 | 148.10 | 0.703577 | 149.03 | 16.00 | 5 | 0 | ok |
| throughput | n1048576_b4 | 1048576 | 4 | 1 | cufft_gpu | 2.773619 | 151.22 | 2.777221 | 151.03 | 64.00 | 5 | 0 | ok |
| throughput | n1048576_b16 | 1048576 | 16 | 1 | cufft_gpu | 11.198487 | 149.82 | 11.210939 | 149.65 | 256.00 | 5 | 0 | ok |
| throughput | n2097152_b1 | 2097152 | 1 | 1 | cufft_gpu | 1.391222 | 158.28 | 1.392567 | 158.13 | 32.00 | 5 | 0 | ok |
| throughput | n2097152_b4 | 2097152 | 4 | 1 | cufft_gpu | 5.559247 | 158.44 | 5.541399 | 158.95 | 128.00 | 5 | 0 | ok |
| throughput | n2097152_b16 | 2097152 | 16 | 1 | cufft_gpu | 22.307298 | 157.94 | 22.362997 | 157.55 | 512.00 | 5 | 0 | ok |
| throughput | n4194304_b1 | 4194304 | 1 | 1 | cufft_gpu | 2.826408 | 163.24 | 2.824513 | 163.35 | 64.00 | 5 | 0 | ok |
| throughput | n4194304_b4 | 4194304 | 4 | 1 | cufft_gpu | 11.261227 | 163.88 | 11.264792 | 163.83 | 256.00 | 5 | 0 | ok |
| throughput | n4194304_b16 | 4194304 | 16 | 1 | cufft_gpu | 45.112729 | 163.63 | 45.329183 | 162.85 | 1024.00 | 5 | 0 | ok |
| batch_scaling | n16384_b1_t1 | 16384 | 1 | 1 | cufft_gpu_batch_scaling | 0.034860 | 32.90 | 0.033374 | 34.36 | 0.25 | 5 | 0 | ok |
| batch_scaling | n16384_b4_t1 | 16384 | 4 | 1 | cufft_gpu_batch_scaling | 0.064516 | 71.11 | 0.064086 | 71.58 | 1.00 | 5 | 0 | ok |
| batch_scaling | n16384_b16_t1 | 16384 | 16 | 1 | cufft_gpu_batch_scaling | 0.191535 | 95.81 | 0.187130 | 98.06 | 4.00 | 5 | 0 | ok |
| batch_scaling | n16384_b64_t1 | 16384 | 64 | 1 | cufft_gpu_batch_scaling | 0.683343 | 107.41 | 0.673298 | 109.02 | 16.00 | 5 | 0 | ok |
| batch_scaling | n16384_b256_t1 | 16384 | 256 | 1 | cufft_gpu_batch_scaling | 2.688592 | 109.20 | 2.664237 | 110.20 | 64.00 | 5 | 0 | ok |
