# FFT Benchmark Report (GPU, cuFFT, 1D)

- Generated at: Thu Feb 19 16:42:28 IST 2026
- Source log: ./fft_logs/fft_benchmark_gpu_20260219_164218.log

## Scenario Catalog

| Run Profile | Description | Workload | Timing Mode |
|---|---|---|---|
| cufft_gpu | cuFFT throughput sweep on RTX 3080 (1D single precision, timing=e2e) | throughput | e2e |
| cufft_gpu_batch_scaling | cuFFT batch scaling sweep on fixed length (timing=e2e) | batch_scaling | e2e |

## Consolidated Results

Metrics use explicit units: milliseconds (`ms`), single-precision gigaflops (`SP GFLOPS`), and memory (`MB`).

| Workload | Case | Length | Batch | ThreadsField | Run Profile | Fwd ms | Fwd SP GFLOPS | Bwd ms | Bwd SP GFLOPS | Mem MB | Status |
|---|---|---|---|---|---|---|---|---|---|---|---|
| throughput | n32_b1 | 32 | 1 | 1 | cufft_gpu | 0.0113 | 0.07 | 0.0128 | 0.06 | 0.00 | ok |
| throughput | n32_b4 | 32 | 4 | 1 | cufft_gpu | 0.0128 | 0.25 | 0.0129 | 0.25 | 0.00 | ok |
| throughput | n32_b16 | 32 | 16 | 1 | cufft_gpu | 0.0134 | 0.95 | 0.0134 | 0.96 | 0.01 | ok |
| throughput | n64_b1 | 64 | 1 | 1 | cufft_gpu | 0.0121 | 0.16 | 0.0124 | 0.15 | 0.00 | ok |
| throughput | n64_b4 | 64 | 4 | 1 | cufft_gpu | 0.0134 | 0.57 | 0.0138 | 0.56 | 0.00 | ok |
| throughput | n64_b16 | 64 | 16 | 1 | cufft_gpu | 0.009546 | 3.22 | 0.0138 | 2.23 | 0.02 | ok |
| throughput | n128_b1 | 128 | 1 | 1 | cufft_gpu | 0.0129 | 0.35 | 0.0125 | 0.36 | 0.00 | ok |
| throughput | n128_b4 | 128 | 4 | 1 | cufft_gpu | 0.0139 | 1.29 | 0.0139 | 1.29 | 0.01 | ok |
| throughput | n128_b16 | 128 | 16 | 1 | cufft_gpu | 0.0205 | 3.49 | 0.0163 | 4.40 | 0.03 | ok |
| throughput | n256_b1 | 256 | 1 | 1 | cufft_gpu | 0.0177 | 0.58 | 0.009741 | 1.05 | 0.00 | ok |
| throughput | n256_b4 | 256 | 4 | 1 | cufft_gpu | 0.0138 | 2.97 | 0.0136 | 3.02 | 0.02 | ok |
| throughput | n256_b16 | 256 | 16 | 1 | cufft_gpu | 0.0173 | 9.48 | 0.0174 | 9.43 | 0.06 | ok |
| throughput | n512_b1 | 512 | 1 | 1 | cufft_gpu | 0.0137 | 1.69 | 0.0133 | 1.73 | 0.01 | ok |
| throughput | n512_b4 | 512 | 4 | 1 | cufft_gpu | 0.0144 | 6.41 | 0.0160 | 5.75 | 0.03 | ok |
| throughput | n512_b16 | 512 | 16 | 1 | cufft_gpu | 0.0233 | 15.80 | 0.0171 | 21.56 | 0.12 | ok |
| throughput | n1024_b1 | 1024 | 1 | 1 | cufft_gpu | 0.0184 | 2.79 | 0.0139 | 3.69 | 0.02 | ok |
| throughput | n1024_b4 | 1024 | 4 | 1 | cufft_gpu | 0.0227 | 9.02 | 0.0227 | 9.03 | 0.06 | ok |
| throughput | n1024_b16 | 1024 | 16 | 1 | cufft_gpu | 0.0245 | 33.44 | 0.0250 | 32.71 | 0.25 | ok |
| throughput | n2048_b1 | 2048 | 1 | 1 | cufft_gpu | 0.0217 | 5.18 | 0.0164 | 6.86 | 0.03 | ok |
| throughput | n2048_b4 | 2048 | 4 | 1 | cufft_gpu | 0.0179 | 25.19 | 0.0242 | 18.60 | 0.12 | ok |
| throughput | n2048_b16 | 2048 | 16 | 1 | cufft_gpu | 0.0397 | 45.36 | 0.0369 | 48.83 | 0.50 | ok |
| throughput | n4096_b1 | 4096 | 1 | 1 | cufft_gpu | 0.0236 | 10.42 | 0.0177 | 13.91 | 0.06 | ok |
| throughput | n4096_b4 | 4096 | 4 | 1 | cufft_gpu | 0.0307 | 32.04 | 0.0243 | 40.43 | 0.25 | ok |
| throughput | n4096_b16 | 4096 | 16 | 1 | cufft_gpu | 0.0600 | 65.49 | 0.0595 | 66.09 | 1.00 | ok |
| throughput | n8192_b1 | 8192 | 1 | 1 | cufft_gpu | 0.0249 | 21.37 | 0.0250 | 21.29 | 0.12 | ok |
| throughput | n8192_b4 | 8192 | 4 | 1 | cufft_gpu | 0.0427 | 49.90 | 0.0478 | 44.54 | 0.50 | ok |
| throughput | n8192_b16 | 8192 | 16 | 1 | cufft_gpu | 0.104 | 82.29 | 0.103 | 82.91 | 2.00 | ok |
| throughput | n16384_b1 | 16384 | 1 | 1 | cufft_gpu | 0.0296 | 38.74 | 0.0333 | 34.49 | 0.25 | ok |
| throughput | n16384_b4 | 16384 | 4 | 1 | cufft_gpu | 0.0655 | 70.03 | 0.0655 | 70.03 | 1.00 | ok |
| throughput | n16384_b16 | 16384 | 16 | 1 | cufft_gpu | 0.196 | 93.66 | 0.185 | 99.25 | 4.00 | ok |
| throughput | n32768_b1 | 32768 | 1 | 1 | cufft_gpu | 0.0435 | 56.52 | 0.0380 | 64.60 | 0.50 | ok |
| throughput | n32768_b4 | 32768 | 4 | 1 | cufft_gpu | 0.106 | 92.92 | 0.102 | 96.31 | 2.00 | ok |
| throughput | n32768_b16 | 32768 | 16 | 1 | cufft_gpu | 0.369 | 106.58 | 0.354 | 110.94 | 8.00 | ok |
| throughput | n65536_b1 | 65536 | 1 | 1 | cufft_gpu | 0.0623 | 84.19 | 0.0631 | 83.03 | 1.00 | ok |
| throughput | n65536_b4 | 65536 | 4 | 1 | cufft_gpu | 0.192 | 109.13 | 0.186 | 112.90 | 4.00 | ok |
| throughput | n65536_b16 | 65536 | 16 | 1 | cufft_gpu | 0.719 | 116.68 | 0.700 | 119.90 | 16.00 | ok |
| throughput | n131072_b1 | 131072 | 1 | 1 | cufft_gpu | 0.106 | 105.39 | 0.102 | 108.80 | 2.00 | ok |
| throughput | n131072_b4 | 131072 | 4 | 1 | cufft_gpu | 0.366 | 121.86 | 0.354 | 126.00 | 8.00 | ok |
| throughput | n131072_b16 | 131072 | 16 | 1 | cufft_gpu | 1.395 | 127.78 | 1.378 | 129.39 | 32.00 | ok |
| throughput | n262144_b1 | 262144 | 1 | 1 | cufft_gpu | 0.196 | 120.63 | 0.185 | 127.34 | 4.00 | ok |
| throughput | n262144_b4 | 262144 | 4 | 1 | cufft_gpu | 0.720 | 131.08 | 0.698 | 135.19 | 16.00 | ok |
| throughput | n262144_b16 | 262144 | 16 | 1 | cufft_gpu | 2.929 | 128.87 | 2.882 | 130.98 | 64.00 | ok |
| throughput | n524288_b1 | 524288 | 1 | 1 | cufft_gpu | 0.367 | 135.72 | 0.355 | 140.43 | 8.00 | ok |
| throughput | n524288_b4 | 524288 | 4 | 1 | cufft_gpu | 1.400 | 142.29 | 1.384 | 143.98 | 32.00 | ok |
| throughput | n524288_b16 | 524288 | 16 | 1 | cufft_gpu | 5.676 | 140.41 | 5.676 | 140.40 | 128.00 | ok |
| throughput | n1048576_b1 | 1048576 | 1 | 1 | cufft_gpu | 0.705 | 148.84 | 0.704 | 149.04 | 16.00 | ok |
| throughput | n1048576_b4 | 1048576 | 4 | 1 | cufft_gpu | 2.789 | 150.37 | 2.778 | 151.01 | 64.00 | ok |
| throughput | n1048576_b16 | 1048576 | 16 | 1 | cufft_gpu | 11.190 | 149.93 | 11.255 | 149.07 | 256.00 | ok |
| throughput | n2097152_b1 | 2097152 | 1 | 1 | cufft_gpu | 1.389 | 158.54 | 1.390 | 158.41 | 32.00 | ok |
| throughput | n2097152_b4 | 2097152 | 4 | 1 | cufft_gpu | 5.562 | 158.36 | 5.519 | 159.59 | 128.00 | ok |
| throughput | n2097152_b16 | 2097152 | 16 | 1 | cufft_gpu | 22.348 | 157.65 | 22.535 | 156.34 | 512.00 | ok |
| throughput | n4194304_b1 | 4194304 | 1 | 1 | cufft_gpu | 2.817 | 163.75 | 2.779 | 166.05 | 64.00 | ok |
| throughput | n4194304_b4 | 4194304 | 4 | 1 | cufft_gpu | 11.380 | 162.17 | 11.212 | 164.60 | 256.00 | ok |
| throughput | n4194304_b16 | 4194304 | 16 | 1 | cufft_gpu | 45.388 | 162.64 | 45.440 | 162.45 | 1024.00 | ok |
| batch_scaling | n16384_b1_t1 | 16384 | 1 | 1 | cufft_gpu_batch_scaling | 0.0351 | 32.68 | 0.0352 | 32.56 | 0.25 | ok |
| batch_scaling | n16384_b4_t1 | 16384 | 4 | 1 | cufft_gpu_batch_scaling | 0.0643 | 71.33 | 0.0668 | 68.66 | 1.00 | ok |
| batch_scaling | n16384_b16_t1 | 16384 | 16 | 1 | cufft_gpu_batch_scaling | 0.192 | 95.42 | 0.185 | 99.15 | 4.00 | ok |
| batch_scaling | n16384_b64_t1 | 16384 | 64 | 1 | cufft_gpu_batch_scaling | 0.693 | 105.87 | 0.673 | 109.11 | 16.00 | ok |
| batch_scaling | n16384_b256_t1 | 16384 | 256 | 1 | cufft_gpu_batch_scaling | 2.746 | 106.92 | 2.686 | 109.30 | 64.00 | ok |

