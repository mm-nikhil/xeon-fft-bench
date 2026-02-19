# FFT Benchmark Report (GPU, cuFFT, 1D)

- Generated at: Thu Feb 19 15:21:41 IST 2026
- Source log: ./fft_logs/fft_benchmark_gpu_20260219_152139.log

## Scenario Catalog

| Run Profile | Description | Workload |
|---|---|---|
| cufft_gpu | cuFFT throughput sweep on RTX 3080 (1D single precision) | throughput |
| cufft_gpu_batch_scaling | cuFFT batch scaling sweep on fixed length | batch_scaling |

## Consolidated Results

Metrics use explicit units: milliseconds (`ms`), single-precision gigaflops (`SP GFLOPS`), and memory (`MB`).

| Workload | Case | Length | Batch | ThreadsField | Run Profile | Fwd ms | Fwd SP GFLOPS | Bwd ms | Bwd SP GFLOPS | Mem MB | Status |
|---|---|---|---|---|---|---|---|---|---|---|---|
| throughput | n32_b1 | 32 | 1 | 1 | cufft_gpu | 0.002566 | 0.31 | 0.002458 | 0.33 | 0.00 | ok |
| throughput | n32_b4 | 32 | 4 | 1 | cufft_gpu | 0.002552 | 1.25 | 0.002560 | 1.25 | 0.00 | ok |
| throughput | n32_b16 | 32 | 16 | 1 | cufft_gpu | 0.002757 | 4.64 | 0.002704 | 4.73 | 0.01 | ok |
| throughput | n64_b1 | 64 | 1 | 1 | cufft_gpu | 0.002394 | 0.80 | 0.002355 | 0.82 | 0.00 | ok |
| throughput | n64_b4 | 64 | 4 | 1 | cufft_gpu | 0.002406 | 3.19 | 0.002453 | 3.13 | 0.00 | ok |
| throughput | n64_b16 | 64 | 16 | 1 | cufft_gpu | 0.002509 | 12.24 | 0.002390 | 12.85 | 0.02 | ok |
| throughput | n128_b1 | 128 | 1 | 1 | cufft_gpu | 0.002611 | 1.72 | 0.002653 | 1.69 | 0.00 | ok |
| throughput | n128_b4 | 128 | 4 | 1 | cufft_gpu | 0.002611 | 6.86 | 0.002662 | 6.73 | 0.01 | ok |
| throughput | n128_b16 | 128 | 16 | 1 | cufft_gpu | 0.002754 | 26.03 | 0.002714 | 26.42 | 0.03 | ok |
| throughput | n256_b1 | 256 | 1 | 1 | cufft_gpu | 0.002714 | 3.77 | 0.002714 | 3.77 | 0.00 | ok |
| throughput | n256_b4 | 256 | 4 | 1 | cufft_gpu | 0.002834 | 14.46 | 0.002757 | 14.86 | 0.02 | ok |
| throughput | n256_b16 | 256 | 16 | 1 | cufft_gpu | 0.002750 | 59.57 | 0.002714 | 60.38 | 0.06 | ok |
| throughput | n512_b1 | 512 | 1 | 1 | cufft_gpu | 0.003072 | 7.50 | 0.003072 | 7.50 | 0.01 | ok |
| throughput | n512_b4 | 512 | 4 | 1 | cufft_gpu | 0.003211 | 28.70 | 0.003174 | 29.03 | 0.03 | ok |
| throughput | n512_b16 | 512 | 16 | 1 | cufft_gpu | 0.003221 | 114.46 | 0.003174 | 116.13 | 0.12 | ok |
| throughput | n1024_b1 | 1024 | 1 | 1 | cufft_gpu | 0.003424 | 14.95 | 0.003379 | 15.15 | 0.02 | ok |
| throughput | n1024_b4 | 1024 | 4 | 1 | cufft_gpu | 0.003891 | 52.63 | 0.003832 | 53.44 | 0.06 | ok |
| throughput | n1024_b16 | 1024 | 16 | 1 | cufft_gpu | 0.003931 | 208.38 | 0.003891 | 210.53 | 0.25 | ok |
| throughput | n2048_b1 | 2048 | 1 | 1 | cufft_gpu | 0.004352 | 25.88 | 0.004301 | 26.19 | 0.03 | ok |
| throughput | n2048_b4 | 2048 | 4 | 1 | cufft_gpu | 0.005018 | 89.80 | 0.005018 | 89.80 | 0.12 | ok |
| throughput | n2048_b16 | 2048 | 16 | 1 | cufft_gpu | 0.005166 | 348.84 | 0.005171 | 348.51 | 0.50 | ok |
| throughput | n4096_b1 | 4096 | 1 | 1 | cufft_gpu | 0.004864 | 50.53 | 0.004856 | 50.61 | 0.06 | ok |
| throughput | n4096_b4 | 4096 | 4 | 1 | cufft_gpu | 0.004966 | 197.94 | 0.004923 | 199.68 | 0.25 | ok |
| throughput | n4096_b16 | 4096 | 16 | 1 | cufft_gpu | 0.005061 | 776.98 | 0.004966 | 791.75 | 1.00 | ok |
| throughput | n8192_b1 | 8192 | 1 | 1 | cufft_gpu | 0.008294 | 64.20 | 0.008294 | 64.20 | 0.12 | ok |
| throughput | n8192_b4 | 8192 | 4 | 1 | cufft_gpu | 0.008440 | 252.36 | 0.008397 | 253.66 | 0.50 | ok |
| throughput | n8192_b16 | 8192 | 16 | 1 | cufft_gpu | 0.008448 | 1008.48 | 0.008346 | 1020.86 | 2.00 | ok |
| throughput | n16384_b1 | 16384 | 1 | 1 | cufft_gpu | 0.0103 | 111.44 | 0.0102 | 112.00 | 0.25 | ok |
| throughput | n16384_b4 | 16384 | 4 | 1 | cufft_gpu | 0.0103 | 445.77 | 0.0103 | 445.77 | 1.00 | ok |
| throughput | n16384_b16 | 16384 | 16 | 1 | cufft_gpu | 0.0157 | 1167.43 | 0.0158 | 1163.64 | 4.00 | ok |
| throughput | n32768_b1 | 32768 | 1 | 1 | cufft_gpu | 0.008190 | 300.06 | 0.008202 | 299.65 | 0.50 | ok |
| throughput | n32768_b4 | 32768 | 4 | 1 | cufft_gpu | 0.008618 | 1140.74 | 0.008653 | 1136.09 | 2.00 | ok |
| throughput | n32768_b16 | 32768 | 16 | 1 | cufft_gpu | 0.0245 | 1604.28 | 0.0240 | 1635.02 | 8.00 | ok |
| throughput | n65536_b1 | 65536 | 1 | 1 | cufft_gpu | 0.007526 | 696.60 | 0.007776 | 674.24 | 1.00 | ok |
| throughput | n65536_b4 | 65536 | 4 | 1 | cufft_gpu | 0.0133 | 1575.38 | 0.0131 | 1606.27 | 4.00 | ok |
| throughput | n65536_b16 | 65536 | 16 | 1 | cufft_gpu | 0.0539 | 1556.12 | 0.0538 | 1558.90 | 16.00 | ok |
| throughput | n131072_b1 | 131072 | 1 | 1 | cufft_gpu | 0.009523 | 1169.89 | 0.009514 | 1171.07 | 2.00 | ok |
| throughput | n131072_b4 | 131072 | 4 | 1 | cufft_gpu | 0.0239 | 1867.81 | 0.0236 | 1888.07 | 8.00 | ok |
| throughput | n131072_b16 | 131072 | 16 | 1 | cufft_gpu | 0.105 | 1692.56 | 0.105 | 1697.51 | 32.00 | ok |
| throughput | n262144_b1 | 262144 | 1 | 1 | cufft_gpu | 0.0157 | 1505.88 | 0.0150 | 1573.03 | 4.00 | ok |
| throughput | n262144_b4 | 262144 | 4 | 1 | cufft_gpu | 0.0545 | 1732.53 | 0.0546 | 1727.46 | 16.00 | ok |
| throughput | n262144_b16 | 262144 | 16 | 1 | cufft_gpu | 0.205 | 1839.19 | 0.206 | 1836.20 | 64.00 | ok |
| throughput | n524288_b1 | 524288 | 1 | 1 | cufft_gpu | 0.0266 | 1870.77 | 0.0265 | 1881.51 | 8.00 | ok |
| throughput | n524288_b4 | 524288 | 4 | 1 | cufft_gpu | 0.112 | 1773.56 | 0.113 | 1770.54 | 32.00 | ok |
| throughput | n524288_b16 | 524288 | 16 | 1 | cufft_gpu | 0.409 | 1948.04 | 0.408 | 1952.21 | 128.00 | ok |
| throughput | n1048576_b1 | 1048576 | 1 | 1 | cufft_gpu | 0.0615 | 1703.83 | 0.0618 | 1696.81 | 16.00 | ok |
| throughput | n1048576_b4 | 1048576 | 4 | 1 | cufft_gpu | 0.223 | 1880.31 | 0.226 | 1852.14 | 64.00 | ok |
| throughput | n1048576_b16 | 1048576 | 16 | 1 | cufft_gpu | 0.817 | 2053.28 | 0.815 | 2058.81 | 256.00 | ok |
| throughput | n2097152_b1 | 2097152 | 1 | 1 | cufft_gpu | 0.128 | 1724.46 | 0.125 | 1757.76 | 32.00 | ok |
| throughput | n2097152_b4 | 2097152 | 4 | 1 | cufft_gpu | 0.432 | 2037.33 | 0.429 | 2051.91 | 128.00 | ok |
| throughput | n2097152_b16 | 2097152 | 16 | 1 | cufft_gpu | 1.652 | 2133.14 | 1.654 | 2129.57 | 512.00 | ok |
| throughput | n4194304_b1 | 4194304 | 1 | 1 | cufft_gpu | 0.261 | 1764.85 | 0.261 | 1769.68 | 64.00 | ok |
| throughput | n4194304_b4 | 4194304 | 4 | 1 | cufft_gpu | 0.947 | 1949.63 | 0.946 | 1950.07 | 256.00 | ok |
| throughput | n4194304_b16 | 4194304 | 16 | 1 | cufft_gpu | 3.710 | 1989.81 | 3.688 | 2001.80 | 1024.00 | ok |
| batch_scaling | n16384_b1_t1 | 16384 | 1 | 1 | cufft_gpu_batch_scaling | 0.0103 | 111.44 | 0.0103 | 111.48 | 0.25 | ok |
| batch_scaling | n16384_b4_t1 | 16384 | 4 | 1 | cufft_gpu_batch_scaling | 0.0103 | 443.56 | 0.0103 | 445.77 | 1.00 | ok |
| batch_scaling | n16384_b16_t1 | 16384 | 16 | 1 | cufft_gpu_batch_scaling | 0.0160 | 1148.72 | 0.0156 | 1175.08 | 4.00 | ok |
| batch_scaling | n16384_b64_t1 | 16384 | 64 | 1 | cufft_gpu_batch_scaling | 0.0361 | 2033.57 | 0.0358 | 2048.09 | 16.00 | ok |
| batch_scaling | n16384_b256_t1 | 16384 | 256 | 1 | cufft_gpu_batch_scaling | 0.129 | 2267.46 | 0.129 | 2270.15 | 64.00 | ok |

