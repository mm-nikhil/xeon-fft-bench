# FFT Benchmark Report (GPU, cuFFT, 1D)

- Generated at: Fri Feb 20 19:51:56 IST 2026
- Source log: ./fft_logs/fft_benchmark_gpu_20260220_195154.log

## Scenario Catalog

| Run Profile | Description | Workload | Timing Mode |
|---|---|---|---|
| cufft_gpu | cuFFT throughput sweep on RTX 3080 (1D single precision, timing=compute) | throughput | compute |
| cufft_gpu_batch_scaling | cuFFT batch scaling sweep on fixed length (timing=compute) | batch_scaling | compute |

## Consolidated Results

Metrics use explicit units: milliseconds (`ms`), single-precision gigaflops (`SP GFLOPS`), and memory (`MB`).

| Workload | Case | Length | Batch | ThreadsField | Run Profile | Fwd ms | Fwd SP GFLOPS | Bwd ms | Bwd SP GFLOPS | Mem MB | Status |
|---|---|---|---|---|---|---|---|---|---|---|---|
| throughput | n32_b1 | 32 | 1 | 1 | cufft_gpu | 0.002558 | 0.31 | 0.002506 | 0.32 | 0.00 | ok |
| throughput | n32_b4 | 32 | 4 | 1 | cufft_gpu | 0.002560 | 1.25 | 0.002560 | 1.25 | 0.00 | ok |
| throughput | n32_b16 | 32 | 16 | 1 | cufft_gpu | 0.002714 | 4.72 | 0.002816 | 4.55 | 0.01 | ok |
| throughput | n64_b1 | 64 | 1 | 1 | cufft_gpu | 0.002406 | 0.80 | 0.002405 | 0.80 | 0.00 | ok |
| throughput | n64_b4 | 64 | 4 | 1 | cufft_gpu | 0.002611 | 2.94 | 0.002560 | 3.00 | 0.00 | ok |
| throughput | n64_b16 | 64 | 16 | 1 | cufft_gpu | 0.002509 | 12.24 | 0.002451 | 12.53 | 0.02 | ok |
| throughput | n128_b1 | 128 | 1 | 1 | cufft_gpu | 0.002627 | 1.71 | 0.002619 | 1.71 | 0.00 | ok |
| throughput | n128_b4 | 128 | 4 | 1 | cufft_gpu | 0.002626 | 6.83 | 0.002648 | 6.77 | 0.01 | ok |
| throughput | n128_b16 | 128 | 16 | 1 | cufft_gpu | 0.002714 | 26.42 | 0.002752 | 26.05 | 0.03 | ok |
| throughput | n256_b1 | 256 | 1 | 1 | cufft_gpu | 0.002709 | 3.78 | 0.002752 | 3.72 | 0.00 | ok |
| throughput | n256_b4 | 256 | 4 | 1 | cufft_gpu | 0.002765 | 14.81 | 0.002768 | 14.80 | 0.02 | ok |
| throughput | n256_b16 | 256 | 16 | 1 | cufft_gpu | 0.002752 | 59.53 | 0.002765 | 59.26 | 0.06 | ok |
| throughput | n512_b1 | 512 | 1 | 1 | cufft_gpu | 0.003077 | 7.49 | 0.003086 | 7.47 | 0.01 | ok |
| throughput | n512_b4 | 512 | 4 | 1 | cufft_gpu | 0.003211 | 28.70 | 0.003174 | 29.03 | 0.03 | ok |
| throughput | n512_b16 | 512 | 16 | 1 | cufft_gpu | 0.003226 | 114.29 | 0.003222 | 114.40 | 0.12 | ok |
| throughput | n1024_b1 | 1024 | 1 | 1 | cufft_gpu | 0.003379 | 15.15 | 0.003379 | 15.15 | 0.02 | ok |
| throughput | n1024_b4 | 1024 | 4 | 1 | cufft_gpu | 0.003840 | 53.33 | 0.003880 | 52.78 | 0.06 | ok |
| throughput | n1024_b16 | 1024 | 16 | 1 | cufft_gpu | 0.003891 | 210.53 | 0.003928 | 208.55 | 0.25 | ok |
| throughput | n2048_b1 | 2048 | 1 | 1 | cufft_gpu | 0.004352 | 25.88 | 0.004352 | 25.88 | 0.03 | ok |
| throughput | n2048_b4 | 2048 | 4 | 1 | cufft_gpu | 0.005478 | 82.24 | 0.005016 | 89.82 | 0.12 | ok |
| throughput | n2048_b16 | 2048 | 16 | 1 | cufft_gpu | 0.005168 | 348.73 | 0.005160 | 349.27 | 0.50 | ok |
| throughput | n4096_b1 | 4096 | 1 | 1 | cufft_gpu | 0.004813 | 51.06 | 0.004864 | 50.53 | 0.06 | ok |
| throughput | n4096_b4 | 4096 | 4 | 1 | cufft_gpu | 0.004918 | 199.87 | 0.004954 | 198.45 | 0.25 | ok |
| throughput | n4096_b16 | 4096 | 16 | 1 | cufft_gpu | 0.005018 | 783.67 | 0.005008 | 785.18 | 1.00 | ok |
| throughput | n8192_b1 | 8192 | 1 | 1 | cufft_gpu | 0.008298 | 64.17 | 0.008294 | 64.20 | 0.12 | ok |
| throughput | n8192_b4 | 8192 | 4 | 1 | cufft_gpu | 0.008397 | 253.66 | 0.008397 | 253.66 | 0.50 | ok |
| throughput | n8192_b16 | 8192 | 16 | 1 | cufft_gpu | 0.008397 | 1014.63 | 0.008397 | 1014.63 | 2.00 | ok |
| throughput | n16384_b1 | 16384 | 1 | 1 | cufft_gpu | 0.0103 | 111.53 | 0.0103 | 111.44 | 0.25 | ok |
| throughput | n16384_b4 | 16384 | 4 | 1 | cufft_gpu | 0.0103 | 443.56 | 0.0103 | 445.77 | 1.00 | ok |
| throughput | n16384_b16 | 16384 | 16 | 1 | cufft_gpu | 0.0159 | 1156.13 | 0.0159 | 1153.22 | 4.00 | ok |
| throughput | n32768_b1 | 32768 | 1 | 1 | cufft_gpu | 0.008192 | 300.00 | 0.008141 | 301.89 | 0.50 | ok |
| throughput | n32768_b4 | 32768 | 4 | 1 | cufft_gpu | 0.008698 | 1130.24 | 0.008653 | 1136.09 | 2.00 | ok |
| throughput | n32768_b16 | 32768 | 16 | 1 | cufft_gpu | 0.0245 | 1607.01 | 0.0242 | 1623.68 | 8.00 | ok |
| throughput | n65536_b1 | 65536 | 1 | 1 | cufft_gpu | 0.007578 | 691.89 | 0.007526 | 696.60 | 1.00 | ok |
| throughput | n65536_b4 | 65536 | 4 | 1 | cufft_gpu | 0.0131 | 1600.00 | 0.0131 | 1599.80 | 4.00 | ok |
| throughput | n65536_b16 | 65536 | 16 | 1 | cufft_gpu | 0.0540 | 1553.45 | 0.0541 | 1550.18 | 16.00 | ok |
| throughput | n131072_b1 | 131072 | 1 | 1 | cufft_gpu | 0.009624 | 1157.64 | 0.009472 | 1176.22 | 2.00 | ok |
| throughput | n131072_b4 | 131072 | 4 | 1 | cufft_gpu | 0.0240 | 1859.21 | 0.0239 | 1867.81 | 8.00 | ok |
| throughput | n131072_b16 | 131072 | 16 | 1 | cufft_gpu | 0.105 | 1690.10 | 0.105 | 1690.94 | 32.00 | ok |
| throughput | n262144_b1 | 262144 | 1 | 1 | cufft_gpu | 0.0157 | 1501.13 | 0.0151 | 1567.35 | 4.00 | ok |
| throughput | n262144_b4 | 262144 | 4 | 1 | cufft_gpu | 0.0549 | 1719.45 | 0.0543 | 1738.87 | 16.00 | ok |
| throughput | n262144_b16 | 262144 | 16 | 1 | cufft_gpu | 0.206 | 1836.77 | 0.205 | 1838.15 | 64.00 | ok |
| throughput | n524288_b1 | 524288 | 1 | 1 | cufft_gpu | 0.0266 | 1871.78 | 0.0266 | 1874.37 | 8.00 | ok |
| throughput | n524288_b4 | 524288 | 4 | 1 | cufft_gpu | 0.113 | 1768.73 | 0.112 | 1771.97 | 32.00 | ok |
| throughput | n524288_b16 | 524288 | 16 | 1 | cufft_gpu | 0.408 | 1950.99 | 0.409 | 1948.09 | 128.00 | ok |
| throughput | n1048576_b1 | 1048576 | 1 | 1 | cufft_gpu | 0.0616 | 1702.41 | 0.0618 | 1696.37 | 16.00 | ok |
| throughput | n1048576_b4 | 1048576 | 4 | 1 | cufft_gpu | 0.223 | 1883.65 | 0.226 | 1856.79 | 64.00 | ok |
| throughput | n1048576_b16 | 1048576 | 16 | 1 | cufft_gpu | 0.816 | 2054.81 | 0.816 | 2056.87 | 256.00 | ok |
| throughput | n2097152_b1 | 2097152 | 1 | 1 | cufft_gpu | 0.123 | 1786.05 | 0.123 | 1788.27 | 32.00 | ok |
| throughput | n2097152_b4 | 2097152 | 4 | 1 | cufft_gpu | 0.432 | 2039.26 | 0.430 | 2050.44 | 128.00 | ok |
| throughput | n2097152_b16 | 2097152 | 16 | 1 | cufft_gpu | 1.652 | 2133.33 | 1.653 | 2131.09 | 512.00 | ok |
| throughput | n4194304_b1 | 4194304 | 1 | 1 | cufft_gpu | 0.250 | 1845.80 | 0.249 | 1854.14 | 64.00 | ok |
| throughput | n4194304_b4 | 4194304 | 4 | 1 | cufft_gpu | 0.949 | 1944.58 | 0.949 | 1944.68 | 256.00 | ok |
| throughput | n4194304_b16 | 4194304 | 16 | 1 | cufft_gpu | 3.728 | 1980.02 | 3.715 | 1987.28 | 1024.00 | ok |
| batch_scaling | n16384_b1_t1 | 16384 | 1 | 1 | cufft_gpu_batch_scaling | 0.0103 | 111.44 | 0.0103 | 111.44 | 0.25 | ok |
| batch_scaling | n16384_b4_t1 | 16384 | 4 | 1 | cufft_gpu_batch_scaling | 0.0103 | 445.77 | 0.0103 | 445.77 | 1.00 | ok |
| batch_scaling | n16384_b16_t1 | 16384 | 16 | 1 | cufft_gpu_batch_scaling | 0.0162 | 1133.17 | 0.0158 | 1159.87 | 4.00 | ok |
| batch_scaling | n16384_b64_t1 | 16384 | 64 | 1 | cufft_gpu_batch_scaling | 0.0361 | 2031.13 | 0.0360 | 2036.36 | 16.00 | ok |
| batch_scaling | n16384_b256_t1 | 16384 | 256 | 1 | cufft_gpu_batch_scaling | 0.130 | 2266.56 | 0.130 | 2262.09 | 64.00 | ok |

