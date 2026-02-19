# FFT Benchmark Report (GPU, cuFFT, 1D)

- Generated at: Thu Feb 19 15:21:46 IST 2026
- Source log: ./fft_logs/fft_benchmark_gpu_20260219_152144.log

## Scenario Catalog

| Run Profile | Description | Workload |
|---|---|---|
| cufft_gpu | cuFFT throughput sweep on RTX 3080 (1D single precision) | throughput |
| cufft_gpu_batch_scaling | cuFFT batch scaling sweep on fixed length | batch_scaling |

## Consolidated Results

Metrics use explicit units: milliseconds (`ms`), single-precision gigaflops (`SP GFLOPS`), and memory (`MB`).

| Workload | Case | Length | Batch | ThreadsField | Run Profile | Fwd ms | Fwd SP GFLOPS | Bwd ms | Bwd SP GFLOPS | Mem MB | Status |
|---|---|---|---|---|---|---|---|---|---|---|---|
| throughput | n32_b1 | 32 | 1 | 1 | cufft_gpu | 0.002560 | 0.31 | 0.002509 | 0.32 | 0.00 | ok |
| throughput | n32_b4 | 32 | 4 | 1 | cufft_gpu | 0.002547 | 1.26 | 0.002560 | 1.25 | 0.00 | ok |
| throughput | n32_b16 | 32 | 16 | 1 | cufft_gpu | 0.002714 | 4.72 | 0.002662 | 4.81 | 0.01 | ok |
| throughput | n64_b1 | 64 | 1 | 1 | cufft_gpu | 0.002406 | 0.80 | 0.002406 | 0.80 | 0.00 | ok |
| throughput | n64_b4 | 64 | 4 | 1 | cufft_gpu | 0.002406 | 3.19 | 0.002405 | 3.19 | 0.00 | ok |
| throughput | n64_b16 | 64 | 16 | 1 | cufft_gpu | 0.002458 | 12.50 | 0.002406 | 12.77 | 0.02 | ok |
| throughput | n128_b1 | 128 | 1 | 1 | cufft_gpu | 0.002629 | 1.70 | 0.002651 | 1.69 | 0.00 | ok |
| throughput | n128_b4 | 128 | 4 | 1 | cufft_gpu | 0.002662 | 6.73 | 0.002653 | 6.76 | 0.01 | ok |
| throughput | n128_b16 | 128 | 16 | 1 | cufft_gpu | 0.002714 | 26.42 | 0.002714 | 26.42 | 0.03 | ok |
| throughput | n256_b1 | 256 | 1 | 1 | cufft_gpu | 0.002702 | 3.79 | 0.002699 | 3.79 | 0.00 | ok |
| throughput | n256_b4 | 256 | 4 | 1 | cufft_gpu | 0.002760 | 14.84 | 0.002778 | 14.75 | 0.02 | ok |
| throughput | n256_b16 | 256 | 16 | 1 | cufft_gpu | 0.002765 | 59.26 | 0.002802 | 58.48 | 0.06 | ok |
| throughput | n512_b1 | 512 | 1 | 1 | cufft_gpu | 0.003123 | 7.38 | 0.003123 | 7.38 | 0.01 | ok |
| throughput | n512_b4 | 512 | 4 | 1 | cufft_gpu | 0.003174 | 29.03 | 0.003226 | 28.57 | 0.03 | ok |
| throughput | n512_b16 | 512 | 16 | 1 | cufft_gpu | 0.003226 | 114.29 | 0.003174 | 116.13 | 0.12 | ok |
| throughput | n1024_b1 | 1024 | 1 | 1 | cufft_gpu | 0.003379 | 15.15 | 0.003379 | 15.15 | 0.02 | ok |
| throughput | n1024_b4 | 1024 | 4 | 1 | cufft_gpu | 0.003789 | 54.05 | 0.003885 | 52.72 | 0.06 | ok |
| throughput | n1024_b16 | 1024 | 16 | 1 | cufft_gpu | 0.003891 | 210.53 | 0.003931 | 208.38 | 0.25 | ok |
| throughput | n2048_b1 | 2048 | 1 | 1 | cufft_gpu | 0.004352 | 25.88 | 0.004352 | 25.88 | 0.03 | ok |
| throughput | n2048_b4 | 2048 | 4 | 1 | cufft_gpu | 0.005018 | 89.80 | 0.005018 | 89.80 | 0.12 | ok |
| throughput | n2048_b16 | 2048 | 16 | 1 | cufft_gpu | 0.005171 | 348.51 | 0.005165 | 348.95 | 0.50 | ok |
| throughput | n4096_b1 | 4096 | 1 | 1 | cufft_gpu | 0.004848 | 50.69 | 0.004864 | 50.53 | 0.06 | ok |
| throughput | n4096_b4 | 4096 | 4 | 1 | cufft_gpu | 0.004966 | 197.94 | 0.004954 | 198.45 | 0.25 | ok |
| throughput | n4096_b16 | 4096 | 16 | 1 | cufft_gpu | 0.005018 | 783.67 | 0.005014 | 784.17 | 1.00 | ok |
| throughput | n8192_b1 | 8192 | 1 | 1 | cufft_gpu | 0.008294 | 64.20 | 0.008299 | 64.16 | 0.12 | ok |
| throughput | n8192_b4 | 8192 | 4 | 1 | cufft_gpu | 0.008397 | 253.66 | 0.008397 | 253.66 | 0.50 | ok |
| throughput | n8192_b16 | 8192 | 16 | 1 | cufft_gpu | 0.008448 | 1008.48 | 0.008346 | 1020.86 | 2.00 | ok |
| throughput | n16384_b1 | 16384 | 1 | 1 | cufft_gpu | 0.0103 | 111.48 | 0.0102 | 112.00 | 0.25 | ok |
| throughput | n16384_b4 | 16384 | 4 | 1 | cufft_gpu | 0.0103 | 444.25 | 0.0103 | 445.77 | 1.00 | ok |
| throughput | n16384_b16 | 16384 | 16 | 1 | cufft_gpu | 0.0158 | 1159.28 | 0.0158 | 1160.22 | 4.00 | ok |
| throughput | n32768_b1 | 32768 | 1 | 1 | cufft_gpu | 0.008230 | 298.60 | 0.008141 | 301.89 | 0.50 | ok |
| throughput | n32768_b4 | 32768 | 4 | 1 | cufft_gpu | 0.008653 | 1136.09 | 0.008653 | 1136.09 | 2.00 | ok |
| throughput | n32768_b16 | 32768 | 16 | 1 | cufft_gpu | 0.0245 | 1606.69 | 0.0240 | 1641.03 | 8.00 | ok |
| throughput | n65536_b1 | 65536 | 1 | 1 | cufft_gpu | 0.007490 | 700.02 | 0.007526 | 696.60 | 1.00 | ok |
| throughput | n65536_b4 | 65536 | 4 | 1 | cufft_gpu | 0.0132 | 1587.60 | 0.0130 | 1612.20 | 4.00 | ok |
| throughput | n65536_b16 | 65536 | 16 | 1 | cufft_gpu | 0.0541 | 1551.52 | 0.0541 | 1550.05 | 16.00 | ok |
| throughput | n131072_b1 | 131072 | 1 | 1 | cufft_gpu | 0.009558 | 1165.58 | 0.009523 | 1169.89 | 2.00 | ok |
| throughput | n131072_b4 | 131072 | 4 | 1 | cufft_gpu | 0.0238 | 1874.73 | 0.0237 | 1883.98 | 8.00 | ok |
| throughput | n131072_b16 | 131072 | 16 | 1 | cufft_gpu | 0.105 | 1690.99 | 0.105 | 1690.92 | 32.00 | ok |
| throughput | n262144_b1 | 262144 | 1 | 1 | cufft_gpu | 0.0157 | 1505.57 | 0.0149 | 1578.08 | 4.00 | ok |
| throughput | n262144_b4 | 262144 | 4 | 1 | cufft_gpu | 0.0550 | 1716.20 | 0.0546 | 1727.46 | 16.00 | ok |
| throughput | n262144_b16 | 262144 | 16 | 1 | cufft_gpu | 0.205 | 1837.69 | 0.206 | 1833.60 | 64.00 | ok |
| throughput | n524288_b1 | 524288 | 1 | 1 | cufft_gpu | 0.0266 | 1874.37 | 0.0264 | 1888.93 | 8.00 | ok |
| throughput | n524288_b4 | 524288 | 4 | 1 | cufft_gpu | 0.112 | 1772.76 | 0.113 | 1770.16 | 32.00 | ok |
| throughput | n524288_b16 | 524288 | 16 | 1 | cufft_gpu | 0.408 | 1951.43 | 0.410 | 1945.62 | 128.00 | ok |
| throughput | n1048576_b1 | 1048576 | 1 | 1 | cufft_gpu | 0.0614 | 1708.09 | 0.0616 | 1701.22 | 16.00 | ok |
| throughput | n1048576_b4 | 1048576 | 4 | 1 | cufft_gpu | 0.223 | 1882.91 | 0.227 | 1849.21 | 64.00 | ok |
| throughput | n1048576_b16 | 1048576 | 16 | 1 | cufft_gpu | 0.818 | 2049.79 | 0.816 | 2056.88 | 256.00 | ok |
| throughput | n2097152_b1 | 2097152 | 1 | 1 | cufft_gpu | 0.128 | 1725.32 | 0.125 | 1754.71 | 32.00 | ok |
| throughput | n2097152_b4 | 2097152 | 4 | 1 | cufft_gpu | 0.433 | 2036.33 | 0.430 | 2049.71 | 128.00 | ok |
| throughput | n2097152_b16 | 2097152 | 16 | 1 | cufft_gpu | 1.651 | 2133.40 | 1.655 | 2128.85 | 512.00 | ok |
| throughput | n4194304_b1 | 4194304 | 1 | 1 | cufft_gpu | 0.262 | 1758.63 | 0.261 | 1768.66 | 64.00 | ok |
| throughput | n4194304_b4 | 4194304 | 4 | 1 | cufft_gpu | 0.947 | 1949.30 | 0.947 | 1949.11 | 256.00 | ok |
| throughput | n4194304_b16 | 4194304 | 16 | 1 | cufft_gpu | 3.692 | 1999.41 | 3.688 | 2001.88 | 1024.00 | ok |
| batch_scaling | n16384_b1_t1 | 16384 | 1 | 1 | cufft_gpu_batch_scaling | 0.0103 | 111.44 | 0.0103 | 111.55 | 0.25 | ok |
| batch_scaling | n16384_b4_t1 | 16384 | 4 | 1 | cufft_gpu_batch_scaling | 0.0103 | 445.77 | 0.0103 | 445.77 | 1.00 | ok |
| batch_scaling | n16384_b16_t1 | 16384 | 16 | 1 | cufft_gpu_batch_scaling | 0.0160 | 1148.72 | 0.0156 | 1175.68 | 4.00 | ok |
| batch_scaling | n16384_b64_t1 | 16384 | 64 | 1 | cufft_gpu_batch_scaling | 0.0360 | 2036.36 | 0.0358 | 2050.93 | 16.00 | ok |
| batch_scaling | n16384_b256_t1 | 16384 | 256 | 1 | cufft_gpu_batch_scaling | 0.129 | 2276.46 | 0.129 | 2271.95 | 64.00 | ok |

