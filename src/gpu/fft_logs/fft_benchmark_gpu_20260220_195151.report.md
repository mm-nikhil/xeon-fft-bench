# FFT Benchmark Report (GPU, cuFFT, 1D)

- Generated at: Fri Feb 20 19:51:54 IST 2026
- Source log: ./fft_logs/fft_benchmark_gpu_20260220_195151.log

## Scenario Catalog

| Run Profile | Description | Workload | Timing Mode |
|---|---|---|---|
| cufft_gpu | cuFFT throughput sweep on RTX 3080 (1D single precision, timing=compute) | throughput | compute |
| cufft_gpu_batch_scaling | cuFFT batch scaling sweep on fixed length (timing=compute) | batch_scaling | compute |

## Consolidated Results

Metrics use explicit units: milliseconds (`ms`), single-precision gigaflops (`SP GFLOPS`), and memory (`MB`).

| Workload | Case | Length | Batch | ThreadsField | Run Profile | Fwd ms | Fwd SP GFLOPS | Bwd ms | Bwd SP GFLOPS | Mem MB | Status |
|---|---|---|---|---|---|---|---|---|---|---|---|
| throughput | n32_b1 | 32 | 1 | 1 | cufft_gpu | 0.002557 | 0.31 | 0.002509 | 0.32 | 0.00 | ok |
| throughput | n32_b4 | 32 | 4 | 1 | cufft_gpu | 0.002918 | 1.10 | 0.002509 | 1.28 | 0.00 | ok |
| throughput | n32_b16 | 32 | 16 | 1 | cufft_gpu | 0.002714 | 4.72 | 0.002662 | 4.81 | 0.01 | ok |
| throughput | n64_b1 | 64 | 1 | 1 | cufft_gpu | 0.002355 | 0.82 | 0.002406 | 0.80 | 0.00 | ok |
| throughput | n64_b4 | 64 | 4 | 1 | cufft_gpu | 0.002446 | 3.14 | 0.002446 | 3.14 | 0.00 | ok |
| throughput | n64_b16 | 64 | 16 | 1 | cufft_gpu | 0.002458 | 12.50 | 0.002406 | 12.77 | 0.02 | ok |
| throughput | n128_b1 | 128 | 1 | 1 | cufft_gpu | 0.002648 | 1.69 | 0.002611 | 1.72 | 0.00 | ok |
| throughput | n128_b4 | 128 | 4 | 1 | cufft_gpu | 0.002662 | 6.73 | 0.002912 | 6.15 | 0.01 | ok |
| throughput | n128_b16 | 128 | 16 | 1 | cufft_gpu | 0.002765 | 25.93 | 0.002712 | 26.43 | 0.03 | ok |
| throughput | n256_b1 | 256 | 1 | 1 | cufft_gpu | 0.002714 | 3.77 | 0.002709 | 3.78 | 0.00 | ok |
| throughput | n256_b4 | 256 | 4 | 1 | cufft_gpu | 0.002765 | 14.81 | 0.002968 | 13.80 | 0.02 | ok |
| throughput | n256_b16 | 256 | 16 | 1 | cufft_gpu | 0.002714 | 60.38 | 0.002765 | 59.26 | 0.06 | ok |
| throughput | n512_b1 | 512 | 1 | 1 | cufft_gpu | 0.003123 | 7.38 | 0.003123 | 7.38 | 0.01 | ok |
| throughput | n512_b4 | 512 | 4 | 1 | cufft_gpu | 0.003226 | 28.57 | 0.003174 | 29.03 | 0.03 | ok |
| throughput | n512_b16 | 512 | 16 | 1 | cufft_gpu | 0.003224 | 114.34 | 0.003174 | 116.13 | 0.12 | ok |
| throughput | n1024_b1 | 1024 | 1 | 1 | cufft_gpu | 0.003379 | 15.15 | 0.003392 | 15.09 | 0.02 | ok |
| throughput | n1024_b4 | 1024 | 4 | 1 | cufft_gpu | 0.003840 | 53.33 | 0.003840 | 53.33 | 0.06 | ok |
| throughput | n1024_b16 | 1024 | 16 | 1 | cufft_gpu | 0.003891 | 210.53 | 0.003901 | 210.01 | 0.25 | ok |
| throughput | n2048_b1 | 2048 | 1 | 1 | cufft_gpu | 0.004352 | 25.88 | 0.004352 | 25.88 | 0.03 | ok |
| throughput | n2048_b4 | 2048 | 4 | 1 | cufft_gpu | 0.005018 | 89.80 | 0.005018 | 89.80 | 0.12 | ok |
| throughput | n2048_b16 | 2048 | 16 | 1 | cufft_gpu | 0.005171 | 348.51 | 0.005160 | 349.27 | 0.50 | ok |
| throughput | n4096_b1 | 4096 | 1 | 1 | cufft_gpu | 0.004851 | 50.66 | 0.004813 | 51.06 | 0.06 | ok |
| throughput | n4096_b4 | 4096 | 4 | 1 | cufft_gpu | 0.004966 | 197.94 | 0.004966 | 197.94 | 0.25 | ok |
| throughput | n4096_b16 | 4096 | 16 | 1 | cufft_gpu | 0.005018 | 783.67 | 0.004982 | 789.21 | 1.00 | ok |
| throughput | n8192_b1 | 8192 | 1 | 1 | cufft_gpu | 0.008294 | 64.20 | 0.008330 | 63.93 | 0.12 | ok |
| throughput | n8192_b4 | 8192 | 4 | 1 | cufft_gpu | 0.008443 | 252.26 | 0.008397 | 253.66 | 0.50 | ok |
| throughput | n8192_b16 | 8192 | 16 | 1 | cufft_gpu | 0.008397 | 1014.63 | 0.008384 | 1016.18 | 2.00 | ok |
| throughput | n16384_b1 | 16384 | 1 | 1 | cufft_gpu | 0.0103 | 111.58 | 0.0102 | 112.00 | 0.25 | ok |
| throughput | n16384_b4 | 16384 | 4 | 1 | cufft_gpu | 0.0103 | 443.98 | 0.0103 | 445.77 | 1.00 | ok |
| throughput | n16384_b16 | 16384 | 16 | 1 | cufft_gpu | 0.0159 | 1156.60 | 0.0160 | 1148.72 | 4.00 | ok |
| throughput | n32768_b1 | 32768 | 1 | 1 | cufft_gpu | 0.008192 | 300.00 | 0.008178 | 300.53 | 0.50 | ok |
| throughput | n32768_b4 | 32768 | 4 | 1 | cufft_gpu | 0.008658 | 1135.46 | 0.008648 | 1136.73 | 2.00 | ok |
| throughput | n32768_b16 | 32768 | 16 | 1 | cufft_gpu | 0.0246 | 1600.00 | 0.0242 | 1623.68 | 8.00 | ok |
| throughput | n65536_b1 | 65536 | 1 | 1 | cufft_gpu | 0.007578 | 691.89 | 0.007514 | 697.79 | 1.00 | ok |
| throughput | n65536_b4 | 65536 | 4 | 1 | cufft_gpu | 0.0131 | 1601.17 | 0.0133 | 1576.52 | 4.00 | ok |
| throughput | n65536_b16 | 65536 | 16 | 1 | cufft_gpu | 0.0539 | 1556.17 | 0.0541 | 1551.52 | 16.00 | ok |
| throughput | n131072_b1 | 131072 | 1 | 1 | cufft_gpu | 0.009574 | 1163.64 | 0.009523 | 1169.89 | 2.00 | ok |
| throughput | n131072_b4 | 131072 | 4 | 1 | cufft_gpu | 0.0238 | 1871.83 | 0.0237 | 1879.91 | 8.00 | ok |
| throughput | n131072_b16 | 131072 | 16 | 1 | cufft_gpu | 0.106 | 1684.45 | 0.105 | 1690.30 | 32.00 | ok |
| throughput | n262144_b1 | 262144 | 1 | 1 | cufft_gpu | 0.0156 | 1511.44 | 0.0151 | 1562.03 | 4.00 | ok |
| throughput | n262144_b4 | 262144 | 4 | 1 | cufft_gpu | 0.0549 | 1720.56 | 0.0545 | 1730.70 | 16.00 | ok |
| throughput | n262144_b16 | 262144 | 16 | 1 | cufft_gpu | 0.205 | 1838.10 | 0.205 | 1839.06 | 64.00 | ok |
| throughput | n524288_b1 | 524288 | 1 | 1 | cufft_gpu | 0.0266 | 1874.37 | 0.0265 | 1881.62 | 8.00 | ok |
| throughput | n524288_b4 | 524288 | 4 | 1 | cufft_gpu | 0.112 | 1774.37 | 0.113 | 1767.02 | 32.00 | ok |
| throughput | n524288_b16 | 524288 | 16 | 1 | cufft_gpu | 0.408 | 1952.23 | 0.408 | 1951.48 | 128.00 | ok |
| throughput | n1048576_b1 | 1048576 | 1 | 1 | cufft_gpu | 0.0617 | 1699.67 | 0.0616 | 1701.00 | 16.00 | ok |
| throughput | n1048576_b4 | 1048576 | 4 | 1 | cufft_gpu | 0.223 | 1878.04 | 0.227 | 1843.80 | 64.00 | ok |
| throughput | n1048576_b16 | 1048576 | 16 | 1 | cufft_gpu | 0.818 | 2050.82 | 0.816 | 2055.06 | 256.00 | ok |
| throughput | n2097152_b1 | 2097152 | 1 | 1 | cufft_gpu | 0.123 | 1789.79 | 0.123 | 1788.27 | 32.00 | ok |
| throughput | n2097152_b4 | 2097152 | 4 | 1 | cufft_gpu | 0.431 | 2044.39 | 0.430 | 2047.06 | 128.00 | ok |
| throughput | n2097152_b16 | 2097152 | 16 | 1 | cufft_gpu | 1.651 | 2134.33 | 1.654 | 2129.90 | 512.00 | ok |
| throughput | n4194304_b1 | 4194304 | 1 | 1 | cufft_gpu | 0.249 | 1849.21 | 0.249 | 1853.26 | 64.00 | ok |
| throughput | n4194304_b4 | 4194304 | 4 | 1 | cufft_gpu | 0.947 | 1948.37 | 0.948 | 1946.46 | 256.00 | ok |
| throughput | n4194304_b16 | 4194304 | 16 | 1 | cufft_gpu | 3.725 | 1981.57 | 3.717 | 1985.88 | 1024.00 | ok |
| batch_scaling | n16384_b1_t1 | 16384 | 1 | 1 | cufft_gpu_batch_scaling | 0.0103 | 110.91 | 0.0104 | 110.34 | 0.25 | ok |
| batch_scaling | n16384_b4_t1 | 16384 | 4 | 1 | cufft_gpu_batch_scaling | 0.0103 | 445.77 | 0.0103 | 445.77 | 1.00 | ok |
| batch_scaling | n16384_b16_t1 | 16384 | 16 | 1 | cufft_gpu_batch_scaling | 0.0160 | 1149.29 | 0.0158 | 1159.99 | 4.00 | ok |
| batch_scaling | n16384_b64_t1 | 16384 | 64 | 1 | cufft_gpu_batch_scaling | 0.0360 | 2038.63 | 0.0361 | 2032.75 | 16.00 | ok |
| batch_scaling | n16384_b256_t1 | 16384 | 256 | 1 | cufft_gpu_batch_scaling | 0.129 | 2273.75 | 0.129 | 2271.08 | 64.00 | ok |

