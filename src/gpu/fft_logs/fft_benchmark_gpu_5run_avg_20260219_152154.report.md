# GPU FFT Combined Report (Averaged Across Runs)

- Generated at: Thu Feb 19 15:21:54 IST 2026
- Manifest: `fft_logs/fft_benchmark_gpu_5run_32_to_4194304.manifest.txt`
- Runs combined: 5
- Precision mode: single precision (cuFFT C2C)

## Run Files

| Run | Log | Report |
|---|---|---|
| 1 | `fft_logs/fft_benchmark_gpu_20260219_152139.log` | `fft_logs/fft_benchmark_gpu_20260219_152139.report.md` |
| 2 | `fft_logs/fft_benchmark_gpu_20260219_152141.log` | `fft_logs/fft_benchmark_gpu_20260219_152141.report.md` |
| 3 | `fft_logs/fft_benchmark_gpu_20260219_152142.log` | `fft_logs/fft_benchmark_gpu_20260219_152142.report.md` |
| 4 | `fft_logs/fft_benchmark_gpu_20260219_152144.log` | `fft_logs/fft_benchmark_gpu_20260219_152144.report.md` |
| 5 | `fft_logs/fft_benchmark_gpu_20260219_152146.log` | `fft_logs/fft_benchmark_gpu_20260219_152146.report.md` |

## Scenario Catalog

| Run Profile | Description | Workload |
|---|---|---|
| cufft_gpu | cuFFT throughput sweep on RTX 3080 (1D single precision) | throughput |
| cufft_gpu_batch_scaling | cuFFT batch scaling sweep on fixed length | batch_scaling |

## Data Quality Check

- Expected samples per row: 5
- Rows with missing samples: 0

## Averaged Results

| Workload | Case | Length | Batch | ThreadsField | Profile | Avg Fwd ms | Avg Fwd SP GFLOPS | Avg Bwd ms | Avg Bwd SP GFLOPS | Avg Mem MB | Successful Samples | Skipped Samples | Status |
|---|---|---:|---:|---:|---|---:|---:|---:|---:|---:|---:|---:|---|
| throughput | n32_b1 | 32 | 1 | 1 | cufft_gpu | 0.002563 | 0.31 | 0.002485 | 0.32 | 0.00 | 5 | 0 | ok |
| throughput | n32_b4 | 32 | 4 | 1 | cufft_gpu | 0.002553 | 1.25 | 0.002558 | 1.25 | 0.00 | 5 | 0 | ok |
| throughput | n32_b16 | 32 | 16 | 1 | cufft_gpu | 0.002728 | 4.69 | 0.002689 | 4.76 | 0.01 | 5 | 0 | ok |
| throughput | n64_b1 | 64 | 1 | 1 | cufft_gpu | 0.002404 | 0.80 | 0.002406 | 0.80 | 0.00 | 5 | 0 | ok |
| throughput | n64_b4 | 64 | 4 | 1 | cufft_gpu | 0.002432 | 3.16 | 0.002426 | 3.17 | 0.00 | 5 | 0 | ok |
| throughput | n64_b16 | 64 | 16 | 1 | cufft_gpu | 0.002476 | 12.41 | 0.002403 | 12.78 | 0.02 | 5 | 0 | ok |
| throughput | n128_b1 | 128 | 1 | 1 | cufft_gpu | 0.002633 | 1.70 | 0.002627 | 1.71 | 0.00 | 5 | 0 | ok |
| throughput | n128_b4 | 128 | 4 | 1 | cufft_gpu | 0.002642 | 6.78 | 0.002657 | 6.75 | 0.01 | 5 | 0 | ok |
| throughput | n128_b16 | 128 | 16 | 1 | cufft_gpu | 0.002747 | 26.10 | 0.002713 | 26.43 | 0.03 | 5 | 0 | ok |
| throughput | n256_b1 | 256 | 1 | 1 | cufft_gpu | 0.002722 | 3.76 | 0.002708 | 3.78 | 0.00 | 5 | 0 | ok |
| throughput | n256_b4 | 256 | 4 | 1 | cufft_gpu | 0.002778 | 14.75 | 0.002767 | 14.80 | 0.02 | 5 | 0 | ok |
| throughput | n256_b16 | 256 | 16 | 1 | cufft_gpu | 0.002766 | 59.23 | 0.002760 | 59.37 | 0.06 | 5 | 0 | ok |
| throughput | n512_b1 | 512 | 1 | 1 | cufft_gpu | 0.003109 | 7.41 | 0.003104 | 7.42 | 0.01 | 5 | 0 | ok |
| throughput | n512_b4 | 512 | 4 | 1 | cufft_gpu | 0.003202 | 28.78 | 0.003184 | 28.94 | 0.03 | 5 | 0 | ok |
| throughput | n512_b16 | 512 | 16 | 1 | cufft_gpu | 0.003213 | 114.73 | 0.003184 | 115.78 | 0.12 | 5 | 0 | ok |
| throughput | n1024_b1 | 1024 | 1 | 1 | cufft_gpu | 0.003395 | 15.08 | 0.003379 | 15.15 | 0.02 | 5 | 0 | ok |
| throughput | n1024_b4 | 1024 | 4 | 1 | cufft_gpu | 0.003837 | 53.38 | 0.003837 | 53.38 | 0.06 | 5 | 0 | ok |
| throughput | n1024_b16 | 1024 | 16 | 1 | cufft_gpu | 0.003899 | 210.10 | 0.003899 | 210.10 | 0.25 | 5 | 0 | ok |
| throughput | n2048_b1 | 2048 | 1 | 1 | cufft_gpu | 0.004352 | 25.88 | 0.004326 | 26.04 | 0.03 | 5 | 0 | ok |
| throughput | n2048_b4 | 2048 | 4 | 1 | cufft_gpu | 0.005025 | 89.67 | 0.005004 | 90.04 | 0.12 | 5 | 0 | ok |
| throughput | n2048_b16 | 2048 | 16 | 1 | cufft_gpu | 0.005169 | 348.67 | 0.005158 | 349.41 | 0.50 | 5 | 0 | ok |
| throughput | n4096_b1 | 4096 | 1 | 1 | cufft_gpu | 0.004847 | 50.70 | 0.004850 | 50.68 | 0.06 | 5 | 0 | ok |
| throughput | n4096_b4 | 4096 | 4 | 1 | cufft_gpu | 0.004965 | 197.99 | 0.004955 | 198.39 | 0.25 | 5 | 0 | ok |
| throughput | n4096_b16 | 4096 | 16 | 1 | cufft_gpu | 0.005037 | 780.75 | 0.004998 | 786.75 | 1.00 | 5 | 0 | ok |
| throughput | n8192_b1 | 8192 | 1 | 1 | cufft_gpu | 0.008309 | 64.08 | 0.008311 | 64.07 | 0.12 | 5 | 0 | ok |
| throughput | n8192_b4 | 8192 | 4 | 1 | cufft_gpu | 0.008416 | 253.09 | 0.008397 | 253.67 | 0.50 | 5 | 0 | ok |
| throughput | n8192_b16 | 8192 | 16 | 1 | cufft_gpu | 0.008427 | 1011.06 | 0.008355 | 1019.81 | 2.00 | 5 | 0 | ok |
| throughput | n16384_b1 | 16384 | 1 | 1 | cufft_gpu | 0.010293 | 111.42 | 0.010249 | 111.90 | 0.25 | 5 | 0 | ok |
| throughput | n16384_b4 | 16384 | 4 | 1 | cufft_gpu | 0.010308 | 445.03 | 0.010299 | 445.44 | 1.00 | 5 | 0 | ok |
| throughput | n16384_b16 | 16384 | 16 | 1 | cufft_gpu | 0.015788 | 1162.31 | 0.015807 | 1160.86 | 4.00 | 5 | 0 | ok |
| throughput | n32768_b1 | 32768 | 1 | 1 | cufft_gpu | 0.008197 | 299.80 | 0.008172 | 300.73 | 0.50 | 5 | 0 | ok |
| throughput | n32768_b4 | 32768 | 4 | 1 | cufft_gpu | 0.008637 | 1138.25 | 0.008653 | 1136.09 | 2.00 | 5 | 0 | ok |
| throughput | n32768_b16 | 32768 | 16 | 1 | cufft_gpu | 0.024512 | 1604.20 | 0.024021 | 1636.96 | 8.00 | 5 | 0 | ok |
| throughput | n65536_b1 | 65536 | 1 | 1 | cufft_gpu | 0.007525 | 696.70 | 0.007567 | 692.96 | 1.00 | 5 | 0 | ok |
| throughput | n65536_b4 | 65536 | 4 | 1 | cufft_gpu | 0.013263 | 1581.22 | 0.013052 | 1606.81 | 4.00 | 5 | 0 | ok |
| throughput | n65536_b16 | 65536 | 16 | 1 | cufft_gpu | 0.054004 | 1553.34 | 0.053922 | 1555.69 | 16.00 | 5 | 0 | ok |
| throughput | n131072_b1 | 131072 | 1 | 1 | cufft_gpu | 0.009560 | 1165.37 | 0.009518 | 1170.48 | 2.00 | 5 | 0 | ok |
| throughput | n131072_b4 | 131072 | 4 | 1 | cufft_gpu | 0.023819 | 1870.99 | 0.023613 | 1887.31 | 8.00 | 5 | 0 | ok |
| throughput | n131072_b16 | 131072 | 16 | 1 | cufft_gpu | 0.105440 | 1690.61 | 0.105237 | 1693.88 | 32.00 | 5 | 0 | ok |
| throughput | n262144_b1 | 262144 | 1 | 1 | cufft_gpu | 0.015644 | 1508.07 | 0.014980 | 1574.92 | 4.00 | 5 | 0 | ok |
| throughput | n262144_b4 | 262144 | 4 | 1 | cufft_gpu | 0.054801 | 1722.12 | 0.054752 | 1723.63 | 16.00 | 5 | 0 | ok |
| throughput | n262144_b16 | 262144 | 16 | 1 | cufft_gpu | 0.205449 | 1837.38 | 0.205491 | 1837.01 | 64.00 | 5 | 0 | ok |
| throughput | n524288_b1 | 524288 | 1 | 1 | cufft_gpu | 0.026647 | 1869.14 | 0.026368 | 1888.92 | 8.00 | 5 | 0 | ok |
| throughput | n524288_b4 | 524288 | 4 | 1 | cufft_gpu | 0.112462 | 1771.53 | 0.112445 | 1771.79 | 32.00 | 5 | 0 | ok |
| throughput | n524288_b16 | 524288 | 16 | 1 | cufft_gpu | 0.408413 | 1951.26 | 0.408982 | 1948.54 | 128.00 | 5 | 0 | ok |
| throughput | n1048576_b1 | 1048576 | 1 | 1 | cufft_gpu | 0.061446 | 1706.49 | 0.061645 | 1700.99 | 16.00 | 5 | 0 | ok |
| throughput | n1048576_b4 | 1048576 | 4 | 1 | cufft_gpu | 0.222540 | 1884.75 | 0.226156 | 1854.63 | 64.00 | 5 | 0 | ok |
| throughput | n1048576_b16 | 1048576 | 16 | 1 | cufft_gpu | 0.817770 | 2051.58 | 0.815267 | 2057.88 | 256.00 | 5 | 0 | ok |
| throughput | n2097152_b1 | 2097152 | 1 | 1 | cufft_gpu | 0.127771 | 1723.41 | 0.124412 | 1770.01 | 32.00 | 5 | 0 | ok |
| throughput | n2097152_b4 | 2097152 | 4 | 1 | cufft_gpu | 0.432251 | 2037.71 | 0.429639 | 2050.11 | 128.00 | 5 | 0 | ok |
| throughput | n2097152_b16 | 2097152 | 16 | 1 | cufft_gpu | 1.651178 | 2133.76 | 1.653573 | 2130.67 | 512.00 | 5 | 0 | ok |
| throughput | n4194304_b1 | 4194304 | 1 | 1 | cufft_gpu | 0.261743 | 1762.70 | 0.260155 | 1773.47 | 64.00 | 5 | 0 | ok |
| throughput | n4194304_b4 | 4194304 | 4 | 1 | cufft_gpu | 0.944698 | 1953.55 | 0.945597 | 1951.68 | 256.00 | 5 | 0 | ok |
| throughput | n4194304_b16 | 4194304 | 16 | 1 | cufft_gpu | 3.703702 | 1993.14 | 3.686928 | 2002.20 | 1024.00 | 5 | 0 | ok |
| batch_scaling | n16384_b1_t1 | 16384 | 1 | 1 | cufft_gpu_batch_scaling | 0.010188 | 112.63 | 0.010156 | 113.00 | 0.25 | 5 | 0 | ok |
| batch_scaling | n16384_b4_t1 | 16384 | 4 | 1 | cufft_gpu_batch_scaling | 0.010218 | 449.17 | 0.010168 | 451.43 | 1.00 | 5 | 0 | ok |
| batch_scaling | n16384_b16_t1 | 16384 | 16 | 1 | cufft_gpu_batch_scaling | 0.015944 | 1150.97 | 0.015643 | 1173.02 | 4.00 | 5 | 0 | ok |
| batch_scaling | n16384_b64_t1 | 16384 | 64 | 1 | cufft_gpu_batch_scaling | 0.036085 | 2034.07 | 0.035796 | 2050.51 | 16.00 | 5 | 0 | ok |
| batch_scaling | n16384_b256_t1 | 16384 | 256 | 1 | cufft_gpu_batch_scaling | 0.129271 | 2271.22 | 0.129223 | 2272.05 | 64.00 | 5 | 0 | ok |
