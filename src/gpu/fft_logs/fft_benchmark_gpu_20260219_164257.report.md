# FFT Benchmark Report (GPU, cuFFT, 1D)

- Generated at: Thu Feb 19 16:43:06 IST 2026
- Source log: ./fft_logs/fft_benchmark_gpu_20260219_164257.log

## Scenario Catalog

| Run Profile | Description | Workload | Timing Mode |
|---|---|---|---|
| cufft_gpu | cuFFT throughput sweep on RTX 3080 (1D single precision, timing=e2e) | throughput | e2e |
| cufft_gpu_batch_scaling | cuFFT batch scaling sweep on fixed length (timing=e2e) | batch_scaling | e2e |

## Consolidated Results

Metrics use explicit units: milliseconds (`ms`), single-precision gigaflops (`SP GFLOPS`), and memory (`MB`).

| Workload | Case | Length | Batch | ThreadsField | Run Profile | Fwd ms | Fwd SP GFLOPS | Bwd ms | Bwd SP GFLOPS | Mem MB | Status |
|---|---|---|---|---|---|---|---|---|---|---|---|
| throughput | n32_b1 | 32 | 1 | 1 | cufft_gpu | 0.0128 | 0.06 | 0.0123 | 0.07 | 0.00 | ok |
| throughput | n32_b4 | 32 | 4 | 1 | cufft_gpu | 0.008549 | 0.37 | 0.009549 | 0.34 | 0.00 | ok |
| throughput | n32_b16 | 32 | 16 | 1 | cufft_gpu | 0.0133 | 0.96 | 0.0174 | 0.74 | 0.01 | ok |
| throughput | n64_b1 | 64 | 1 | 1 | cufft_gpu | 0.008646 | 0.22 | 0.009432 | 0.20 | 0.00 | ok |
| throughput | n64_b4 | 64 | 4 | 1 | cufft_gpu | 0.0134 | 0.57 | 0.0135 | 0.57 | 0.00 | ok |
| throughput | n64_b16 | 64 | 16 | 1 | cufft_gpu | 0.0142 | 2.16 | 0.009883 | 3.11 | 0.02 | ok |
| throughput | n128_b1 | 128 | 1 | 1 | cufft_gpu | 0.0129 | 0.35 | 0.0122 | 0.37 | 0.00 | ok |
| throughput | n128_b4 | 128 | 4 | 1 | cufft_gpu | 0.0138 | 1.30 | 0.0137 | 1.31 | 0.01 | ok |
| throughput | n128_b16 | 128 | 16 | 1 | cufft_gpu | 0.0155 | 4.61 | 0.0161 | 4.44 | 0.03 | ok |
| throughput | n256_b1 | 256 | 1 | 1 | cufft_gpu | 0.0129 | 0.79 | 0.0138 | 0.74 | 0.00 | ok |
| throughput | n256_b4 | 256 | 4 | 1 | cufft_gpu | 0.009752 | 4.20 | 0.009685 | 4.23 | 0.02 | ok |
| throughput | n256_b16 | 256 | 16 | 1 | cufft_gpu | 0.0185 | 8.88 | 0.0172 | 9.53 | 0.06 | ok |
| throughput | n512_b1 | 512 | 1 | 1 | cufft_gpu | 0.0138 | 1.66 | 0.0137 | 1.68 | 0.01 | ok |
| throughput | n512_b4 | 512 | 4 | 1 | cufft_gpu | 0.0164 | 5.63 | 0.0160 | 5.75 | 0.03 | ok |
| throughput | n512_b16 | 512 | 16 | 1 | cufft_gpu | 0.0236 | 15.61 | 0.0231 | 15.94 | 0.12 | ok |
| throughput | n1024_b1 | 1024 | 1 | 1 | cufft_gpu | 0.0156 | 3.28 | 0.0137 | 3.73 | 0.02 | ok |
| throughput | n1024_b4 | 1024 | 4 | 1 | cufft_gpu | 0.0229 | 8.93 | 0.0234 | 8.76 | 0.06 | ok |
| throughput | n1024_b16 | 1024 | 16 | 1 | cufft_gpu | 0.0306 | 26.73 | 0.0265 | 30.87 | 0.25 | ok |
| throughput | n2048_b1 | 2048 | 1 | 1 | cufft_gpu | 0.0166 | 6.78 | 0.0165 | 6.83 | 0.03 | ok |
| throughput | n2048_b4 | 2048 | 4 | 1 | cufft_gpu | 0.0257 | 17.56 | 0.0195 | 23.10 | 0.12 | ok |
| throughput | n2048_b16 | 2048 | 16 | 1 | cufft_gpu | 0.0385 | 46.84 | 0.0373 | 48.32 | 0.50 | ok |
| throughput | n4096_b1 | 4096 | 1 | 1 | cufft_gpu | 0.0235 | 10.45 | 0.0230 | 10.67 | 0.06 | ok |
| throughput | n4096_b4 | 4096 | 4 | 1 | cufft_gpu | 0.0245 | 40.20 | 0.0245 | 40.07 | 0.25 | ok |
| throughput | n4096_b16 | 4096 | 16 | 1 | cufft_gpu | 0.0607 | 64.75 | 0.0560 | 70.27 | 1.00 | ok |
| throughput | n8192_b1 | 8192 | 1 | 1 | cufft_gpu | 0.0311 | 17.14 | 0.0249 | 21.36 | 0.12 | ok |
| throughput | n8192_b4 | 8192 | 4 | 1 | cufft_gpu | 0.0452 | 47.14 | 0.0452 | 47.16 | 0.50 | ok |
| throughput | n8192_b16 | 8192 | 16 | 1 | cufft_gpu | 0.105 | 80.97 | 0.103 | 82.81 | 2.00 | ok |
| throughput | n16384_b1 | 16384 | 1 | 1 | cufft_gpu | 0.0353 | 32.52 | 0.0324 | 35.41 | 0.25 | ok |
| throughput | n16384_b4 | 16384 | 4 | 1 | cufft_gpu | 0.0651 | 70.42 | 0.0607 | 75.60 | 1.00 | ok |
| throughput | n16384_b16 | 16384 | 16 | 1 | cufft_gpu | 0.193 | 95.22 | 0.186 | 98.61 | 4.00 | ok |
| throughput | n32768_b1 | 32768 | 1 | 1 | cufft_gpu | 0.0425 | 57.85 | 0.0397 | 61.93 | 0.50 | ok |
| throughput | n32768_b4 | 32768 | 4 | 1 | cufft_gpu | 0.105 | 93.46 | 0.102 | 96.23 | 2.00 | ok |
| throughput | n32768_b16 | 32768 | 16 | 1 | cufft_gpu | 0.361 | 109.03 | 0.355 | 110.91 | 8.00 | ok |
| throughput | n65536_b1 | 65536 | 1 | 1 | cufft_gpu | 0.0605 | 86.69 | 0.0627 | 83.58 | 1.00 | ok |
| throughput | n65536_b4 | 65536 | 4 | 1 | cufft_gpu | 0.191 | 109.88 | 0.183 | 114.34 | 4.00 | ok |
| throughput | n65536_b16 | 65536 | 16 | 1 | cufft_gpu | 0.699 | 120.02 | 0.698 | 120.16 | 16.00 | ok |
| throughput | n131072_b1 | 131072 | 1 | 1 | cufft_gpu | 0.106 | 105.12 | 0.103 | 108.12 | 2.00 | ok |
| throughput | n131072_b4 | 131072 | 4 | 1 | cufft_gpu | 0.367 | 121.44 | 0.353 | 126.11 | 8.00 | ok |
| throughput | n131072_b16 | 131072 | 16 | 1 | cufft_gpu | 1.379 | 129.23 | 1.377 | 129.44 | 32.00 | ok |
| throughput | n262144_b1 | 262144 | 1 | 1 | cufft_gpu | 0.195 | 120.86 | 0.187 | 125.85 | 4.00 | ok |
| throughput | n262144_b4 | 262144 | 4 | 1 | cufft_gpu | 0.712 | 132.46 | 0.698 | 135.24 | 16.00 | ok |
| throughput | n262144_b16 | 262144 | 16 | 1 | cufft_gpu | 2.754 | 137.08 | 2.733 | 138.12 | 64.00 | ok |
| throughput | n524288_b1 | 524288 | 1 | 1 | cufft_gpu | 0.368 | 135.23 | 0.356 | 139.86 | 8.00 | ok |
| throughput | n524288_b4 | 524288 | 4 | 1 | cufft_gpu | 1.386 | 143.71 | 1.385 | 143.89 | 32.00 | ok |
| throughput | n524288_b16 | 524288 | 16 | 1 | cufft_gpu | 5.607 | 142.13 | 5.598 | 142.35 | 128.00 | ok |
| throughput | n1048576_b1 | 1048576 | 1 | 1 | cufft_gpu | 0.703 | 149.25 | 0.703 | 149.14 | 16.00 | ok |
| throughput | n1048576_b4 | 1048576 | 4 | 1 | cufft_gpu | 2.761 | 151.93 | 2.798 | 149.91 | 64.00 | ok |
| throughput | n1048576_b16 | 1048576 | 16 | 1 | cufft_gpu | 11.139 | 150.62 | 11.203 | 149.75 | 256.00 | ok |
| throughput | n2097152_b1 | 2097152 | 1 | 1 | cufft_gpu | 1.397 | 157.63 | 1.394 | 157.98 | 32.00 | ok |
| throughput | n2097152_b4 | 2097152 | 4 | 1 | cufft_gpu | 5.563 | 158.33 | 5.550 | 158.70 | 128.00 | ok |
| throughput | n2097152_b16 | 2097152 | 16 | 1 | cufft_gpu | 22.286 | 158.09 | 22.378 | 157.44 | 512.00 | ok |
| throughput | n4194304_b1 | 4194304 | 1 | 1 | cufft_gpu | 2.792 | 165.26 | 2.854 | 161.64 | 64.00 | ok |
| throughput | n4194304_b4 | 4194304 | 4 | 1 | cufft_gpu | 11.399 | 161.90 | 11.389 | 162.04 | 256.00 | ok |
| throughput | n4194304_b16 | 4194304 | 16 | 1 | cufft_gpu | 45.402 | 162.59 | 45.399 | 162.60 | 1024.00 | ok |
| batch_scaling | n16384_b1_t1 | 16384 | 1 | 1 | cufft_gpu_batch_scaling | 0.0301 | 38.05 | 0.0324 | 35.39 | 0.25 | ok |
| batch_scaling | n16384_b4_t1 | 16384 | 4 | 1 | cufft_gpu_batch_scaling | 0.0653 | 70.21 | 0.0669 | 68.61 | 1.00 | ok |
| batch_scaling | n16384_b16_t1 | 16384 | 16 | 1 | cufft_gpu_batch_scaling | 0.191 | 96.01 | 0.187 | 98.26 | 4.00 | ok |
| batch_scaling | n16384_b64_t1 | 16384 | 64 | 1 | cufft_gpu_batch_scaling | 0.682 | 107.65 | 0.674 | 108.88 | 16.00 | ok |
| batch_scaling | n16384_b256_t1 | 16384 | 256 | 1 | cufft_gpu_batch_scaling | 2.744 | 107.01 | 2.682 | 109.48 | 64.00 | ok |

