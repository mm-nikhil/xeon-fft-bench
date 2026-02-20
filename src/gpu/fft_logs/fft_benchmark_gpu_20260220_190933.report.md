# FFT Benchmark Report (GPU, cuFFT, 1D)

- Generated at: Fri Feb 20 19:09:43 IST 2026
- Source log: ./fft_logs/fft_benchmark_gpu_20260220_190933.log

## Scenario Catalog

| Run Profile | Description | Workload | Timing Mode |
|---|---|---|---|
| cufft_gpu | cuFFT throughput sweep on RTX 3080 (1D single precision, timing=e2e) | throughput | e2e |
| cufft_gpu_batch_scaling | cuFFT batch scaling sweep on fixed length (timing=e2e) | batch_scaling | e2e |

## Consolidated Results

Metrics use explicit units: milliseconds (`ms`), single-precision gigaflops (`SP GFLOPS`), and memory (`MB`).

| Workload | Case | Length | Batch | ThreadsField | Run Profile | Fwd ms | Fwd SP GFLOPS | Bwd ms | Bwd SP GFLOPS | Mem MB | Status |
|---|---|---|---|---|---|---|---|---|---|---|---|
| throughput | n32_b1 | 32 | 1 | 1 | cufft_gpu | 0.0130 | 0.06 | 0.0120 | 0.07 | 0.00 | ok |
| throughput | n32_b4 | 32 | 4 | 1 | cufft_gpu | 0.0130 | 0.25 | 0.0129 | 0.25 | 0.00 | ok |
| throughput | n32_b16 | 32 | 16 | 1 | cufft_gpu | 0.0131 | 0.98 | 0.0138 | 0.93 | 0.02 | ok |
| throughput | n64_b1 | 64 | 1 | 1 | cufft_gpu | 0.0121 | 0.16 | 0.0124 | 0.15 | 0.00 | ok |
| throughput | n64_b4 | 64 | 4 | 1 | cufft_gpu | 0.0179 | 0.43 | 0.0129 | 0.60 | 0.01 | ok |
| throughput | n64_b16 | 64 | 16 | 1 | cufft_gpu | 0.0139 | 2.20 | 0.0136 | 2.26 | 0.03 | ok |
| throughput | n128_b1 | 128 | 1 | 1 | cufft_gpu | 0.0129 | 0.35 | 0.0121 | 0.37 | 0.00 | ok |
| throughput | n128_b4 | 128 | 4 | 1 | cufft_gpu | 0.0138 | 1.29 | 0.0136 | 1.32 | 0.02 | ok |
| throughput | n128_b16 | 128 | 16 | 1 | cufft_gpu | 0.0156 | 4.59 | 0.0217 | 3.30 | 0.06 | ok |
| throughput | n256_b1 | 256 | 1 | 1 | cufft_gpu | 0.0138 | 0.74 | 0.0137 | 0.75 | 0.01 | ok |
| throughput | n256_b4 | 256 | 4 | 1 | cufft_gpu | 0.0136 | 3.00 | 0.009792 | 4.18 | 0.03 | ok |
| throughput | n256_b16 | 256 | 16 | 1 | cufft_gpu | 0.0229 | 7.17 | 0.0174 | 9.44 | 0.12 | ok |
| throughput | n512_b1 | 512 | 1 | 1 | cufft_gpu | 0.0137 | 1.69 | 0.0137 | 1.69 | 0.02 | ok |
| throughput | n512_b4 | 512 | 4 | 1 | cufft_gpu | 0.0165 | 5.59 | 0.0156 | 5.90 | 0.06 | ok |
| throughput | n512_b16 | 512 | 16 | 1 | cufft_gpu | 0.0175 | 21.06 | 0.0174 | 21.17 | 0.25 | ok |
| throughput | n1024_b1 | 1024 | 1 | 1 | cufft_gpu | 0.0177 | 2.89 | 0.0138 | 3.70 | 0.03 | ok |
| throughput | n1024_b4 | 1024 | 4 | 1 | cufft_gpu | 0.0174 | 11.75 | 0.0172 | 11.94 | 0.12 | ok |
| throughput | n1024_b16 | 1024 | 16 | 1 | cufft_gpu | 0.0308 | 26.61 | 0.0309 | 26.51 | 0.50 | ok |
| throughput | n2048_b1 | 2048 | 1 | 1 | cufft_gpu | 0.0218 | 5.17 | 0.0162 | 6.96 | 0.06 | ok |
| throughput | n2048_b4 | 2048 | 4 | 1 | cufft_gpu | 0.0236 | 19.07 | 0.0232 | 19.42 | 0.25 | ok |
| throughput | n2048_b16 | 2048 | 16 | 1 | cufft_gpu | 0.0384 | 46.99 | 0.0400 | 45.01 | 1.00 | ok |
| throughput | n4096_b1 | 4096 | 1 | 1 | cufft_gpu | 0.0227 | 10.83 | 0.0227 | 10.83 | 0.12 | ok |
| throughput | n4096_b4 | 4096 | 4 | 1 | cufft_gpu | 0.0251 | 39.24 | 0.0246 | 39.92 | 0.50 | ok |
| throughput | n4096_b16 | 4096 | 16 | 1 | cufft_gpu | 0.0603 | 65.21 | 0.0613 | 64.12 | 2.00 | ok |
| throughput | n8192_b1 | 8192 | 1 | 1 | cufft_gpu | 0.0252 | 21.11 | 0.0249 | 21.39 | 0.25 | ok |
| throughput | n8192_b4 | 8192 | 4 | 1 | cufft_gpu | 0.0424 | 50.22 | 0.0409 | 52.13 | 1.00 | ok |
| throughput | n8192_b16 | 8192 | 16 | 1 | cufft_gpu | 0.103 | 82.75 | 0.103 | 82.75 | 4.00 | ok |
| throughput | n16384_b1 | 16384 | 1 | 1 | cufft_gpu | 0.0324 | 35.36 | 0.0324 | 35.44 | 0.50 | ok |
| throughput | n16384_b4 | 16384 | 4 | 1 | cufft_gpu | 0.0645 | 71.14 | 0.0639 | 71.81 | 2.00 | ok |
| throughput | n16384_b16 | 16384 | 16 | 1 | cufft_gpu | 0.185 | 98.93 | 0.186 | 98.56 | 8.00 | ok |
| throughput | n32768_b1 | 32768 | 1 | 1 | cufft_gpu | 0.0419 | 58.71 | 0.0412 | 59.61 | 1.00 | ok |
| throughput | n32768_b4 | 32768 | 4 | 1 | cufft_gpu | 0.104 | 94.22 | 0.102 | 96.39 | 4.00 | ok |
| throughput | n32768_b16 | 32768 | 16 | 1 | cufft_gpu | 0.354 | 111.08 | 0.354 | 110.98 | 16.00 | ok |
| throughput | n65536_b1 | 65536 | 1 | 1 | cufft_gpu | 0.0626 | 83.79 | 0.0591 | 88.73 | 2.00 | ok |
| throughput | n65536_b4 | 65536 | 4 | 1 | cufft_gpu | 0.187 | 112.35 | 0.185 | 113.31 | 8.00 | ok |
| throughput | n65536_b16 | 65536 | 16 | 1 | cufft_gpu | 0.699 | 119.94 | 0.699 | 120.03 | 32.00 | ok |
| throughput | n131072_b1 | 131072 | 1 | 1 | cufft_gpu | 0.104 | 107.19 | 0.103 | 108.20 | 4.00 | ok |
| throughput | n131072_b4 | 131072 | 4 | 1 | cufft_gpu | 0.354 | 126.02 | 0.353 | 126.42 | 16.00 | ok |
| throughput | n131072_b16 | 131072 | 16 | 1 | cufft_gpu | 1.376 | 129.53 | 1.376 | 129.53 | 64.00 | ok |
| throughput | n262144_b1 | 262144 | 1 | 1 | cufft_gpu | 0.193 | 122.38 | 0.185 | 127.42 | 8.00 | ok |
| throughput | n262144_b4 | 262144 | 4 | 1 | cufft_gpu | 0.697 | 135.48 | 0.699 | 135.03 | 32.00 | ok |
| throughput | n262144_b16 | 262144 | 16 | 1 | cufft_gpu | 2.746 | 137.45 | 2.741 | 137.73 | 128.00 | ok |
| throughput | n524288_b1 | 524288 | 1 | 1 | cufft_gpu | 0.359 | 138.86 | 0.354 | 140.57 | 16.00 | ok |
| throughput | n524288_b4 | 524288 | 4 | 1 | cufft_gpu | 1.384 | 143.99 | 1.383 | 144.08 | 64.00 | ok |
| throughput | n524288_b16 | 524288 | 16 | 1 | cufft_gpu | 5.601 | 142.28 | 5.610 | 142.05 | 256.00 | ok |
| throughput | n1048576_b1 | 1048576 | 1 | 1 | cufft_gpu | 0.704 | 148.99 | 0.703 | 149.14 | 32.00 | ok |
| throughput | n1048576_b4 | 1048576 | 4 | 1 | cufft_gpu | 2.773 | 151.26 | 2.762 | 151.87 | 128.00 | ok |
| throughput | n1048576_b16 | 1048576 | 16 | 1 | cufft_gpu | 11.151 | 150.46 | 11.194 | 149.88 | 512.00 | ok |
| throughput | n2097152_b1 | 2097152 | 1 | 1 | cufft_gpu | 1.394 | 158.01 | 1.394 | 158.01 | 64.00 | ok |
| throughput | n2097152_b4 | 2097152 | 4 | 1 | cufft_gpu | 5.527 | 159.36 | 5.568 | 158.18 | 256.00 | ok |
| throughput | n2097152_b16 | 2097152 | 16 | 1 | cufft_gpu | 22.261 | 158.27 | 22.336 | 157.74 | 1024.00 | ok |
| throughput | n4194304_b1 | 4194304 | 1 | 1 | cufft_gpu | 2.775 | 166.28 | 2.855 | 161.61 | 128.00 | ok |
| throughput | n4194304_b4 | 4194304 | 4 | 1 | cufft_gpu | 11.156 | 165.43 | 11.185 | 165.00 | 512.00 | ok |
| throughput | n4194304_b16 | 4194304 | 16 | 1 | cufft_gpu | 45.089 | 163.72 | 45.230 | 163.21 | 2048.00 | ok |
| batch_scaling | n16384_b1_t1 | 16384 | 1 | 1 | cufft_gpu_batch_scaling | 0.0324 | 35.40 | 0.0361 | 31.81 | 0.50 | ok |
| batch_scaling | n16384_b4_t1 | 16384 | 4 | 1 | cufft_gpu_batch_scaling | 0.0640 | 71.73 | 0.0636 | 72.10 | 2.00 | ok |
| batch_scaling | n16384_b16_t1 | 16384 | 16 | 1 | cufft_gpu_batch_scaling | 0.192 | 95.41 | 0.186 | 98.79 | 8.00 | ok |
| batch_scaling | n16384_b64_t1 | 16384 | 64 | 1 | cufft_gpu_batch_scaling | 0.683 | 107.44 | 0.674 | 108.89 | 32.00 | ok |
| batch_scaling | n16384_b256_t1 | 16384 | 256 | 1 | cufft_gpu_batch_scaling | 2.664 | 110.21 | 2.655 | 110.59 | 128.00 | ok |

