# FFT Benchmark Report (GPU, cuFFT, 1D)

- Generated at: Fri Feb 20 19:51:51 IST 2026
- Source log: ./fft_logs/fft_benchmark_gpu_20260220_195149.log

## Scenario Catalog

| Run Profile | Description | Workload | Timing Mode |
|---|---|---|---|
| cufft_gpu | cuFFT throughput sweep on RTX 3080 (1D single precision, timing=compute) | throughput | compute |
| cufft_gpu_batch_scaling | cuFFT batch scaling sweep on fixed length (timing=compute) | batch_scaling | compute |

## Consolidated Results

Metrics use explicit units: milliseconds (`ms`), single-precision gigaflops (`SP GFLOPS`), and memory (`MB`).

| Workload | Case | Length | Batch | ThreadsField | Run Profile | Fwd ms | Fwd SP GFLOPS | Bwd ms | Bwd SP GFLOPS | Mem MB | Status |
|---|---|---|---|---|---|---|---|---|---|---|---|
| throughput | n32_b1 | 32 | 1 | 1 | cufft_gpu | 0.002560 | 0.31 | 0.002507 | 0.32 | 0.00 | ok |
| throughput | n32_b4 | 32 | 4 | 1 | cufft_gpu | 0.002658 | 1.20 | 0.002560 | 1.25 | 0.00 | ok |
| throughput | n32_b16 | 32 | 16 | 1 | cufft_gpu | 0.002710 | 4.72 | 0.002662 | 4.81 | 0.01 | ok |
| throughput | n64_b1 | 64 | 1 | 1 | cufft_gpu | 0.002355 | 0.82 | 0.002406 | 0.80 | 0.00 | ok |
| throughput | n64_b4 | 64 | 4 | 1 | cufft_gpu | 0.002406 | 3.19 | 0.002406 | 3.19 | 0.00 | ok |
| throughput | n64_b16 | 64 | 16 | 1 | cufft_gpu | 0.002406 | 12.77 | 0.002454 | 12.52 | 0.02 | ok |
| throughput | n128_b1 | 128 | 1 | 1 | cufft_gpu | 0.002626 | 1.71 | 0.002611 | 1.72 | 0.00 | ok |
| throughput | n128_b4 | 128 | 4 | 1 | cufft_gpu | 0.002662 | 6.73 | 0.002611 | 6.86 | 0.01 | ok |
| throughput | n128_b16 | 128 | 16 | 1 | cufft_gpu | 0.002765 | 25.93 | 0.002714 | 26.42 | 0.03 | ok |
| throughput | n256_b1 | 256 | 1 | 1 | cufft_gpu | 0.002765 | 3.70 | 0.002714 | 3.77 | 0.00 | ok |
| throughput | n256_b4 | 256 | 4 | 1 | cufft_gpu | 0.002765 | 14.81 | 0.002765 | 14.81 | 0.02 | ok |
| throughput | n256_b16 | 256 | 16 | 1 | cufft_gpu | 0.002765 | 59.26 | 0.002757 | 59.43 | 0.06 | ok |
| throughput | n512_b1 | 512 | 1 | 1 | cufft_gpu | 0.003122 | 7.38 | 0.003083 | 7.47 | 0.01 | ok |
| throughput | n512_b4 | 512 | 4 | 1 | cufft_gpu | 0.003174 | 29.03 | 0.003214 | 28.67 | 0.03 | ok |
| throughput | n512_b16 | 512 | 16 | 1 | cufft_gpu | 0.003226 | 114.29 | 0.003174 | 116.13 | 0.12 | ok |
| throughput | n1024_b1 | 1024 | 1 | 1 | cufft_gpu | 0.003379 | 15.15 | 0.003379 | 15.15 | 0.02 | ok |
| throughput | n1024_b4 | 1024 | 4 | 1 | cufft_gpu | 0.003832 | 53.44 | 0.003840 | 53.33 | 0.06 | ok |
| throughput | n1024_b16 | 1024 | 16 | 1 | cufft_gpu | 0.003888 | 210.70 | 0.004085 | 200.55 | 0.25 | ok |
| throughput | n2048_b1 | 2048 | 1 | 1 | cufft_gpu | 0.004352 | 25.88 | 0.004301 | 26.19 | 0.03 | ok |
| throughput | n2048_b4 | 2048 | 4 | 1 | cufft_gpu | 0.005062 | 89.00 | 0.005053 | 89.17 | 0.12 | ok |
| throughput | n2048_b16 | 2048 | 16 | 1 | cufft_gpu | 0.005171 | 348.51 | 0.005171 | 348.51 | 0.50 | ok |
| throughput | n4096_b1 | 4096 | 1 | 1 | cufft_gpu | 0.004853 | 50.64 | 0.004864 | 50.53 | 0.06 | ok |
| throughput | n4096_b4 | 4096 | 4 | 1 | cufft_gpu | 0.005008 | 196.29 | 0.004926 | 199.55 | 0.25 | ok |
| throughput | n4096_b16 | 4096 | 16 | 1 | cufft_gpu | 0.005018 | 783.67 | 0.004966 | 791.75 | 1.00 | ok |
| throughput | n8192_b1 | 8192 | 1 | 1 | cufft_gpu | 0.008294 | 64.20 | 0.008280 | 64.31 | 0.12 | ok |
| throughput | n8192_b4 | 8192 | 4 | 1 | cufft_gpu | 0.008397 | 253.66 | 0.008387 | 253.95 | 0.50 | ok |
| throughput | n8192_b16 | 8192 | 16 | 1 | cufft_gpu | 0.008397 | 1014.63 | 0.008387 | 1015.80 | 2.00 | ok |
| throughput | n16384_b1 | 16384 | 1 | 1 | cufft_gpu | 0.0103 | 111.37 | 0.0102 | 112.00 | 0.25 | ok |
| throughput | n16384_b4 | 16384 | 4 | 1 | cufft_gpu | 0.0103 | 445.77 | 0.0103 | 445.98 | 1.00 | ok |
| throughput | n16384_b16 | 16384 | 16 | 1 | cufft_gpu | 0.0158 | 1159.87 | 0.0160 | 1148.49 | 4.00 | ok |
| throughput | n32768_b1 | 32768 | 1 | 1 | cufft_gpu | 0.008192 | 300.00 | 0.008195 | 299.88 | 0.50 | ok |
| throughput | n32768_b4 | 32768 | 4 | 1 | cufft_gpu | 0.008653 | 1136.09 | 0.008653 | 1136.09 | 2.00 | ok |
| throughput | n32768_b16 | 32768 | 16 | 1 | cufft_gpu | 0.0245 | 1606.69 | 0.0243 | 1620.25 | 8.00 | ok |
| throughput | n65536_b1 | 65536 | 1 | 1 | cufft_gpu | 0.007526 | 696.60 | 0.007621 | 687.97 | 1.00 | ok |
| throughput | n65536_b4 | 65536 | 4 | 1 | cufft_gpu | 0.0132 | 1592.03 | 0.0133 | 1581.47 | 4.00 | ok |
| throughput | n65536_b16 | 65536 | 16 | 1 | cufft_gpu | 0.0539 | 1555.94 | 0.0542 | 1548.58 | 16.00 | ok |
| throughput | n131072_b1 | 131072 | 1 | 1 | cufft_gpu | 0.009574 | 1163.64 | 0.009523 | 1169.89 | 2.00 | ok |
| throughput | n131072_b4 | 131072 | 4 | 1 | cufft_gpu | 0.0239 | 1867.81 | 0.0238 | 1871.70 | 8.00 | ok |
| throughput | n131072_b16 | 131072 | 16 | 1 | cufft_gpu | 0.105 | 1691.74 | 0.105 | 1691.15 | 32.00 | ok |
| throughput | n262144_b1 | 262144 | 1 | 1 | cufft_gpu | 0.0157 | 1505.88 | 0.0151 | 1562.36 | 4.00 | ok |
| throughput | n262144_b4 | 262144 | 4 | 1 | cufft_gpu | 0.0546 | 1729.49 | 0.0551 | 1713.01 | 16.00 | ok |
| throughput | n262144_b16 | 262144 | 16 | 1 | cufft_gpu | 0.205 | 1840.44 | 0.205 | 1840.44 | 64.00 | ok |
| throughput | n524288_b1 | 524288 | 1 | 1 | cufft_gpu | 0.0267 | 1864.61 | 0.0266 | 1873.92 | 8.00 | ok |
| throughput | n524288_b4 | 524288 | 4 | 1 | cufft_gpu | 0.112 | 1771.14 | 0.112 | 1772.76 | 32.00 | ok |
| throughput | n524288_b16 | 524288 | 16 | 1 | cufft_gpu | 0.408 | 1952.92 | 0.408 | 1954.15 | 128.00 | ok |
| throughput | n1048576_b1 | 1048576 | 1 | 1 | cufft_gpu | 0.0616 | 1701.22 | 0.0615 | 1705.25 | 16.00 | ok |
| throughput | n1048576_b4 | 1048576 | 4 | 1 | cufft_gpu | 0.223 | 1884.08 | 0.226 | 1859.35 | 64.00 | ok |
| throughput | n1048576_b16 | 1048576 | 16 | 1 | cufft_gpu | 0.817 | 2052.76 | 0.816 | 2056.00 | 256.00 | ok |
| throughput | n2097152_b1 | 2097152 | 1 | 1 | cufft_gpu | 0.123 | 1788.27 | 0.123 | 1789.20 | 32.00 | ok |
| throughput | n2097152_b4 | 2097152 | 4 | 1 | cufft_gpu | 0.432 | 2037.57 | 0.430 | 2049.95 | 128.00 | ok |
| throughput | n2097152_b16 | 2097152 | 16 | 1 | cufft_gpu | 1.652 | 2133.20 | 1.653 | 2131.42 | 512.00 | ok |
| throughput | n4194304_b1 | 4194304 | 1 | 1 | cufft_gpu | 0.249 | 1850.73 | 0.249 | 1852.63 | 64.00 | ok |
| throughput | n4194304_b4 | 4194304 | 4 | 1 | cufft_gpu | 0.949 | 1943.74 | 0.948 | 1947.10 | 256.00 | ok |
| throughput | n4194304_b16 | 4194304 | 16 | 1 | cufft_gpu | 3.727 | 1980.59 | 3.718 | 1985.43 | 1024.00 | ok |
| batch_scaling | n16384_b1_t1 | 16384 | 1 | 1 | cufft_gpu_batch_scaling | 0.0103 | 111.44 | 0.0103 | 110.99 | 0.25 | ok |
| batch_scaling | n16384_b4_t1 | 16384 | 4 | 1 | cufft_gpu_batch_scaling | 0.0103 | 443.56 | 0.0103 | 445.77 | 1.00 | ok |
| batch_scaling | n16384_b16_t1 | 16384 | 16 | 1 | cufft_gpu_batch_scaling | 0.0161 | 1141.86 | 0.0158 | 1163.64 | 4.00 | ok |
| batch_scaling | n16384_b64_t1 | 16384 | 64 | 1 | cufft_gpu_batch_scaling | 0.0361 | 2033.48 | 0.0360 | 2036.36 | 16.00 | ok |
| batch_scaling | n16384_b256_t1 | 16384 | 256 | 1 | cufft_gpu_batch_scaling | 0.129 | 2273.69 | 0.130 | 2266.87 | 64.00 | ok |

