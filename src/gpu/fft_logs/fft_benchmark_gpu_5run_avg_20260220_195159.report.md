# GPU FFT Combined Report (Averaged Across Runs)

- Generated at: Fri Feb 20 19:51:59 IST 2026
- Manifest: `fft_logs/fft_benchmark_gpu_5run_32_to_4194304.manifest.txt`
- Runs combined: 5
- Precision mode: single precision (cuFFT C2C)
- Average latency (`ms`): arithmetic mean over successful samples.
- GFLOPS derivation: recomputed from averaged latency.
  `avg_sp_gflops = (5 * N * log2(N) * batch) / (avg_ms * 1e6)`

## Run Files

| Run | Log | Report |
|---|---|---|
| 1 | `fft_logs/fft_benchmark_gpu_20260220_195147.log` | `fft_logs/fft_benchmark_gpu_20260220_195147.report.md` |
| 2 | `fft_logs/fft_benchmark_gpu_20260220_195149.log` | `fft_logs/fft_benchmark_gpu_20260220_195149.report.md` |
| 3 | `fft_logs/fft_benchmark_gpu_20260220_195151.log` | `fft_logs/fft_benchmark_gpu_20260220_195151.report.md` |
| 4 | `fft_logs/fft_benchmark_gpu_20260220_195154.log` | `fft_logs/fft_benchmark_gpu_20260220_195154.report.md` |
| 5 | `fft_logs/fft_benchmark_gpu_20260220_195156.log` | `fft_logs/fft_benchmark_gpu_20260220_195156.report.md` |

## Scenario Catalog

| Run Profile | Description | Workload | Timing Mode |
|---|---|---|---|
| cufft_gpu | cuFFT throughput sweep on RTX 3080 (1D single precision, timing=compute) | throughput | compute |
| cufft_gpu_batch_scaling | cuFFT batch scaling sweep on fixed length (timing=compute) | batch_scaling | compute |

## Data Quality Check

- Expected samples per row: 5
- Rows with missing samples: 0

## Averaged Results

| Workload | Case | Length | Batch | ThreadsField | Profile | Avg Fwd ms | Avg Fwd SP GFLOPS | Avg Bwd ms | Avg Bwd SP GFLOPS | Avg Mem MB | Successful Samples | Skipped Samples | Status |
|---|---|---:|---:|---:|---|---:|---:|---:|---:|---:|---:|---:|---|
| throughput | n32_b1 | 32 | 1 | 1 | cufft_gpu | 0.002549 | 0.31 | 0.002515 | 0.32 | 0.00 | 5 | 0 | ok |
| throughput | n32_b4 | 32 | 4 | 1 | cufft_gpu | 0.002651 | 1.21 | 0.002550 | 1.25 | 0.00 | 5 | 0 | ok |
| throughput | n32_b16 | 32 | 16 | 1 | cufft_gpu | 0.002718 | 4.71 | 0.002702 | 4.74 | 0.01 | 5 | 0 | ok |
| throughput | n64_b1 | 64 | 1 | 1 | cufft_gpu | 0.002386 | 0.80 | 0.002385 | 0.80 | 0.00 | 5 | 0 | ok |
| throughput | n64_b4 | 64 | 4 | 1 | cufft_gpu | 0.002463 | 3.12 | 0.002453 | 3.13 | 0.00 | 5 | 0 | ok |
| throughput | n64_b16 | 64 | 16 | 1 | cufft_gpu | 0.002445 | 12.56 | 0.002445 | 12.56 | 0.02 | 5 | 0 | ok |
| throughput | n128_b1 | 128 | 1 | 1 | cufft_gpu | 0.002630 | 1.70 | 0.002616 | 1.71 | 0.00 | 5 | 0 | ok |
| throughput | n128_b4 | 128 | 4 | 1 | cufft_gpu | 0.002655 | 6.75 | 0.002689 | 6.66 | 0.01 | 5 | 0 | ok |
| throughput | n128_b16 | 128 | 16 | 1 | cufft_gpu | 0.002755 | 26.02 | 0.002730 | 26.25 | 0.03 | 5 | 0 | ok |
| throughput | n256_b1 | 256 | 1 | 1 | cufft_gpu | 0.002730 | 3.75 | 0.002728 | 3.75 | 0.00 | 5 | 0 | ok |
| throughput | n256_b4 | 256 | 4 | 1 | cufft_gpu | 0.002783 | 14.72 | 0.002807 | 14.59 | 0.02 | 5 | 0 | ok |
| throughput | n256_b16 | 256 | 16 | 1 | cufft_gpu | 0.002752 | 59.53 | 0.002763 | 59.29 | 0.06 | 5 | 0 | ok |
| throughput | n512_b1 | 512 | 1 | 1 | cufft_gpu | 0.003112 | 7.40 | 0.003101 | 7.43 | 0.01 | 5 | 0 | ok |
| throughput | n512_b4 | 512 | 4 | 1 | cufft_gpu | 0.003202 | 28.78 | 0.003182 | 28.96 | 0.03 | 5 | 0 | ok |
| throughput | n512_b16 | 512 | 16 | 1 | cufft_gpu | 0.003205 | 115.03 | 0.003190 | 115.55 | 0.12 | 5 | 0 | ok |
| throughput | n1024_b1 | 1024 | 1 | 1 | cufft_gpu | 0.003389 | 15.11 | 0.003390 | 15.10 | 0.02 | 5 | 0 | ok |
| throughput | n1024_b4 | 1024 | 4 | 1 | cufft_gpu | 0.003846 | 53.25 | 0.003857 | 53.10 | 0.06 | 5 | 0 | ok |
| throughput | n1024_b16 | 1024 | 16 | 1 | cufft_gpu | 0.003890 | 210.57 | 0.003939 | 207.96 | 0.25 | 5 | 0 | ok |
| throughput | n2048_b1 | 2048 | 1 | 1 | cufft_gpu | 0.004371 | 25.77 | 0.004321 | 26.07 | 0.03 | 5 | 0 | ok |
| throughput | n2048_b4 | 2048 | 4 | 1 | cufft_gpu | 0.005128 | 87.86 | 0.005025 | 89.67 | 0.12 | 5 | 0 | ok |
| throughput | n2048_b16 | 2048 | 16 | 1 | cufft_gpu | 0.005168 | 348.76 | 0.005156 | 349.52 | 0.50 | 5 | 0 | ok |
| throughput | n4096_b1 | 4096 | 1 | 1 | cufft_gpu | 0.004849 | 50.68 | 0.004844 | 50.74 | 0.06 | 5 | 0 | ok |
| throughput | n4096_b4 | 4096 | 4 | 1 | cufft_gpu | 0.004963 | 198.07 | 0.004937 | 199.13 | 0.25 | 5 | 0 | ok |
| throughput | n4096_b16 | 4096 | 16 | 1 | cufft_gpu | 0.005026 | 782.43 | 0.004976 | 790.23 | 1.00 | 5 | 0 | ok |
| throughput | n8192_b1 | 8192 | 1 | 1 | cufft_gpu | 0.008302 | 64.14 | 0.008288 | 64.25 | 0.12 | 5 | 0 | ok |
| throughput | n8192_b4 | 8192 | 4 | 1 | cufft_gpu | 0.008413 | 253.18 | 0.008403 | 253.48 | 0.50 | 5 | 0 | ok |
| throughput | n8192_b16 | 8192 | 16 | 1 | cufft_gpu | 0.008409 | 1013.19 | 0.008382 | 1016.40 | 2.00 | 5 | 0 | ok |
| throughput | n16384_b1 | 16384 | 1 | 1 | cufft_gpu | 0.010296 | 111.40 | 0.010260 | 111.78 | 0.25 | 5 | 0 | ok |
| throughput | n16384_b4 | 16384 | 4 | 1 | cufft_gpu | 0.010325 | 444.30 | 0.010290 | 445.82 | 1.00 | 5 | 0 | ok |
| throughput | n16384_b16 | 16384 | 16 | 1 | cufft_gpu | 0.015833 | 1158.96 | 0.015973 | 1148.83 | 4.00 | 5 | 0 | ok |
| throughput | n32768_b1 | 32768 | 1 | 1 | cufft_gpu | 0.008191 | 300.04 | 0.008178 | 300.53 | 0.50 | 5 | 0 | ok |
| throughput | n32768_b4 | 32768 | 4 | 1 | cufft_gpu | 0.008691 | 1131.13 | 0.008652 | 1136.20 | 2.00 | 5 | 0 | ok |
| throughput | n32768_b16 | 32768 | 16 | 1 | cufft_gpu | 0.024544 | 1602.10 | 0.024251 | 1621.44 | 8.00 | 5 | 0 | ok |
| throughput | n65536_b1 | 65536 | 1 | 1 | cufft_gpu | 0.007556 | 693.85 | 0.007550 | 694.44 | 1.00 | 5 | 0 | ok |
| throughput | n65536_b4 | 65536 | 4 | 1 | cufft_gpu | 0.013142 | 1595.79 | 0.013220 | 1586.35 | 4.00 | 5 | 0 | ok |
| throughput | n65536_b16 | 65536 | 16 | 1 | cufft_gpu | 0.053960 | 1554.59 | 0.054125 | 1549.86 | 16.00 | 5 | 0 | ok |
| throughput | n131072_b1 | 131072 | 1 | 1 | cufft_gpu | 0.009612 | 1159.08 | 0.009518 | 1170.48 | 2.00 | 5 | 0 | ok |
| throughput | n131072_b4 | 131072 | 4 | 1 | cufft_gpu | 0.023859 | 1867.83 | 0.023757 | 1875.88 | 8.00 | 5 | 0 | ok |
| throughput | n131072_b16 | 131072 | 16 | 1 | cufft_gpu | 0.105523 | 1689.29 | 0.105423 | 1690.88 | 32.00 | 5 | 0 | ok |
| throughput | n262144_b1 | 262144 | 1 | 1 | cufft_gpu | 0.015684 | 1504.25 | 0.015131 | 1559.25 | 4.00 | 5 | 0 | ok |
| throughput | n262144_b4 | 262144 | 4 | 1 | cufft_gpu | 0.054764 | 1723.26 | 0.054591 | 1728.71 | 16.00 | 5 | 0 | ok |
| throughput | n262144_b16 | 262144 | 16 | 1 | cufft_gpu | 0.205341 | 1838.35 | 0.205293 | 1838.78 | 64.00 | 5 | 0 | ok |
| throughput | n524288_b1 | 524288 | 1 | 1 | cufft_gpu | 0.026633 | 1870.15 | 0.026543 | 1876.49 | 8.00 | 5 | 0 | ok |
| throughput | n524288_b4 | 524288 | 4 | 1 | cufft_gpu | 0.112445 | 1771.80 | 0.112549 | 1770.16 | 32.00 | 5 | 0 | ok |
| throughput | n524288_b16 | 524288 | 16 | 1 | cufft_gpu | 0.408236 | 1952.10 | 0.408552 | 1950.59 | 128.00 | 5 | 0 | ok |
| throughput | n1048576_b1 | 1048576 | 1 | 1 | cufft_gpu | 0.061631 | 1701.38 | 0.061627 | 1701.50 | 16.00 | 5 | 0 | ok |
| throughput | n1048576_b4 | 1048576 | 4 | 1 | cufft_gpu | 0.222995 | 1880.89 | 0.226588 | 1851.07 | 64.00 | 5 | 0 | ok |
| throughput | n1048576_b16 | 1048576 | 16 | 1 | cufft_gpu | 0.817796 | 2051.52 | 0.815981 | 2056.08 | 256.00 | 5 | 0 | ok |
| throughput | n2097152_b1 | 2097152 | 1 | 1 | cufft_gpu | 0.123167 | 1787.83 | 0.123092 | 1788.91 | 32.00 | 5 | 0 | ok |
| throughput | n2097152_b4 | 2097152 | 4 | 1 | cufft_gpu | 0.431971 | 2039.03 | 0.429905 | 2048.84 | 128.00 | 5 | 0 | ok |
| throughput | n2097152_b16 | 2097152 | 16 | 1 | cufft_gpu | 1.651325 | 2133.57 | 1.652961 | 2131.46 | 512.00 | 5 | 0 | ok |
| throughput | n4194304_b1 | 4194304 | 1 | 1 | cufft_gpu | 0.249692 | 1847.77 | 0.249030 | 1852.69 | 64.00 | 5 | 0 | ok |
| throughput | n4194304_b4 | 4194304 | 4 | 1 | cufft_gpu | 0.947999 | 1946.73 | 0.948053 | 1946.61 | 256.00 | 5 | 0 | ok |
| throughput | n4194304_b16 | 4194304 | 16 | 1 | cufft_gpu | 3.727440 | 1980.44 | 3.717093 | 1985.95 | 1024.00 | 5 | 0 | ok |
| batch_scaling | n16384_b1_t1 | 16384 | 1 | 1 | cufft_gpu_batch_scaling | 0.010310 | 111.24 | 0.010318 | 111.15 | 0.25 | 5 | 0 | ok |
| batch_scaling | n16384_b4_t1 | 16384 | 4 | 1 | cufft_gpu_batch_scaling | 0.010321 | 444.48 | 0.010291 | 445.78 | 1.00 | 5 | 0 | ok |
| batch_scaling | n16384_b16_t1 | 16384 | 16 | 1 | cufft_gpu_batch_scaling | 0.016025 | 1145.06 | 0.015800 | 1161.38 | 4.00 | 5 | 0 | ok |
| batch_scaling | n16384_b64_t1 | 16384 | 64 | 1 | cufft_gpu_batch_scaling | 0.036107 | 2032.88 | 0.036087 | 2033.99 | 16.00 | 5 | 0 | ok |
| batch_scaling | n16384_b256_t1 | 16384 | 256 | 1 | cufft_gpu_batch_scaling | 0.129240 | 2271.76 | 0.129460 | 2267.90 | 64.00 | 5 | 0 | ok |
