# FFT Benchmark Report (GPU, cuFFT, 1D)

- Generated at: Fri Feb 20 19:09:33 IST 2026
- Source log: ./fft_logs/fft_benchmark_gpu_20260220_190923.log

## Scenario Catalog

| Run Profile | Description | Workload | Timing Mode |
|---|---|---|---|
| cufft_gpu | cuFFT throughput sweep on RTX 3080 (1D single precision, timing=e2e) | throughput | e2e |
| cufft_gpu_batch_scaling | cuFFT batch scaling sweep on fixed length (timing=e2e) | batch_scaling | e2e |

## Consolidated Results

Metrics use explicit units: milliseconds (`ms`), single-precision gigaflops (`SP GFLOPS`), and memory (`MB`).

| Workload | Case | Length | Batch | ThreadsField | Run Profile | Fwd ms | Fwd SP GFLOPS | Bwd ms | Bwd SP GFLOPS | Mem MB | Status |
|---|---|---|---|---|---|---|---|---|---|---|---|
| throughput | n32_b1 | 32 | 1 | 1 | cufft_gpu | 0.0121 | 0.07 | 0.0121 | 0.07 | 0.00 | ok |
| throughput | n32_b4 | 32 | 4 | 1 | cufft_gpu | 0.0128 | 0.25 | 0.0129 | 0.25 | 0.00 | ok |
| throughput | n32_b16 | 32 | 16 | 1 | cufft_gpu | 0.0131 | 0.98 | 0.0139 | 0.92 | 0.02 | ok |
| throughput | n64_b1 | 64 | 1 | 1 | cufft_gpu | 0.0120 | 0.16 | 0.0137 | 0.14 | 0.00 | ok |
| throughput | n64_b4 | 64 | 4 | 1 | cufft_gpu | 0.0138 | 0.56 | 0.0134 | 0.57 | 0.01 | ok |
| throughput | n64_b16 | 64 | 16 | 1 | cufft_gpu | 0.009797 | 3.14 | 0.009776 | 3.14 | 0.03 | ok |
| throughput | n128_b1 | 128 | 1 | 1 | cufft_gpu | 0.0129 | 0.35 | 0.0126 | 0.35 | 0.00 | ok |
| throughput | n128_b4 | 128 | 4 | 1 | cufft_gpu | 0.0138 | 1.30 | 0.0131 | 1.37 | 0.02 | ok |
| throughput | n128_b16 | 128 | 16 | 1 | cufft_gpu | 0.0218 | 3.29 | 0.0164 | 4.38 | 0.06 | ok |
| throughput | n256_b1 | 256 | 1 | 1 | cufft_gpu | 0.0138 | 0.74 | 0.0137 | 0.75 | 0.01 | ok |
| throughput | n256_b4 | 256 | 4 | 1 | cufft_gpu | 0.009814 | 4.17 | 0.0148 | 2.77 | 0.03 | ok |
| throughput | n256_b16 | 256 | 16 | 1 | cufft_gpu | 0.0168 | 9.78 | 0.0170 | 9.66 | 0.12 | ok |
| throughput | n512_b1 | 512 | 1 | 1 | cufft_gpu | 0.0139 | 1.66 | 0.0137 | 1.68 | 0.02 | ok |
| throughput | n512_b4 | 512 | 4 | 1 | cufft_gpu | 0.0107 | 8.58 | 0.0217 | 4.26 | 0.06 | ok |
| throughput | n512_b16 | 512 | 16 | 1 | cufft_gpu | 0.0179 | 20.64 | 0.0231 | 15.96 | 0.25 | ok |
| throughput | n1024_b1 | 1024 | 1 | 1 | cufft_gpu | 0.0138 | 3.72 | 0.0142 | 3.60 | 0.03 | ok |
| throughput | n1024_b4 | 1024 | 4 | 1 | cufft_gpu | 0.0231 | 8.88 | 0.0230 | 8.91 | 0.12 | ok |
| throughput | n1024_b16 | 1024 | 16 | 1 | cufft_gpu | 0.0307 | 26.70 | 0.0305 | 26.89 | 0.50 | ok |
| throughput | n2048_b1 | 2048 | 1 | 1 | cufft_gpu | 0.0165 | 6.84 | 0.0216 | 5.21 | 0.06 | ok |
| throughput | n2048_b4 | 2048 | 4 | 1 | cufft_gpu | 0.0240 | 18.75 | 0.0193 | 23.34 | 0.25 | ok |
| throughput | n2048_b16 | 2048 | 16 | 1 | cufft_gpu | 0.0383 | 47.04 | 0.0368 | 49.03 | 1.00 | ok |
| throughput | n4096_b1 | 4096 | 1 | 1 | cufft_gpu | 0.0176 | 13.98 | 0.0179 | 13.71 | 0.12 | ok |
| throughput | n4096_b4 | 4096 | 4 | 1 | cufft_gpu | 0.0249 | 39.56 | 0.0308 | 31.94 | 0.50 | ok |
| throughput | n4096_b16 | 4096 | 16 | 1 | cufft_gpu | 0.0599 | 65.66 | 0.0573 | 68.59 | 2.00 | ok |
| throughput | n8192_b1 | 8192 | 1 | 1 | cufft_gpu | 0.0248 | 21.47 | 0.0257 | 20.76 | 0.25 | ok |
| throughput | n8192_b4 | 8192 | 4 | 1 | cufft_gpu | 0.0435 | 48.94 | 0.0420 | 50.66 | 1.00 | ok |
| throughput | n8192_b16 | 8192 | 16 | 1 | cufft_gpu | 0.103 | 82.61 | 0.102 | 83.89 | 4.00 | ok |
| throughput | n16384_b1 | 16384 | 1 | 1 | cufft_gpu | 0.0363 | 31.58 | 0.0333 | 34.41 | 0.50 | ok |
| throughput | n16384_b4 | 16384 | 4 | 1 | cufft_gpu | 0.0644 | 71.26 | 0.0659 | 69.63 | 2.00 | ok |
| throughput | n16384_b16 | 16384 | 16 | 1 | cufft_gpu | 0.191 | 96.13 | 0.187 | 98.31 | 8.00 | ok |
| throughput | n32768_b1 | 32768 | 1 | 1 | cufft_gpu | 0.0422 | 58.21 | 0.0450 | 54.67 | 1.00 | ok |
| throughput | n32768_b4 | 32768 | 4 | 1 | cufft_gpu | 0.103 | 95.24 | 0.102 | 96.39 | 4.00 | ok |
| throughput | n32768_b16 | 32768 | 16 | 1 | cufft_gpu | 0.365 | 107.61 | 0.356 | 110.42 | 16.00 | ok |
| throughput | n65536_b1 | 65536 | 1 | 1 | cufft_gpu | 0.0623 | 84.13 | 0.0634 | 82.69 | 2.00 | ok |
| throughput | n65536_b4 | 65536 | 4 | 1 | cufft_gpu | 0.191 | 109.64 | 0.183 | 114.65 | 8.00 | ok |
| throughput | n65536_b16 | 65536 | 16 | 1 | cufft_gpu | 0.712 | 117.85 | 0.699 | 119.99 | 32.00 | ok |
| throughput | n131072_b1 | 131072 | 1 | 1 | cufft_gpu | 0.103 | 108.02 | 0.103 | 108.28 | 4.00 | ok |
| throughput | n131072_b4 | 131072 | 4 | 1 | cufft_gpu | 0.366 | 121.69 | 0.354 | 125.95 | 16.00 | ok |
| throughput | n131072_b16 | 131072 | 16 | 1 | cufft_gpu | 1.395 | 127.82 | 1.376 | 129.54 | 64.00 | ok |
| throughput | n262144_b1 | 262144 | 1 | 1 | cufft_gpu | 0.194 | 121.70 | 0.186 | 127.11 | 8.00 | ok |
| throughput | n262144_b4 | 262144 | 4 | 1 | cufft_gpu | 0.717 | 131.64 | 0.698 | 135.18 | 32.00 | ok |
| throughput | n262144_b16 | 262144 | 16 | 1 | cufft_gpu | 2.761 | 136.74 | 2.734 | 138.05 | 128.00 | ok |
| throughput | n524288_b1 | 524288 | 1 | 1 | cufft_gpu | 0.368 | 135.22 | 0.356 | 139.84 | 16.00 | ok |
| throughput | n524288_b4 | 524288 | 4 | 1 | cufft_gpu | 1.384 | 143.95 | 1.384 | 143.95 | 64.00 | ok |
| throughput | n524288_b16 | 524288 | 16 | 1 | cufft_gpu | 5.594 | 142.45 | 5.628 | 141.59 | 256.00 | ok |
| throughput | n1048576_b1 | 1048576 | 1 | 1 | cufft_gpu | 0.704 | 149.00 | 0.703 | 149.08 | 32.00 | ok |
| throughput | n1048576_b4 | 1048576 | 4 | 1 | cufft_gpu | 2.801 | 149.72 | 2.771 | 151.35 | 128.00 | ok |
| throughput | n1048576_b16 | 1048576 | 16 | 1 | cufft_gpu | 11.151 | 150.46 | 11.207 | 149.71 | 512.00 | ok |
| throughput | n2097152_b1 | 2097152 | 1 | 1 | cufft_gpu | 1.390 | 158.40 | 1.389 | 158.50 | 64.00 | ok |
| throughput | n2097152_b4 | 2097152 | 4 | 1 | cufft_gpu | 5.549 | 158.73 | 5.570 | 158.12 | 256.00 | ok |
| throughput | n2097152_b16 | 2097152 | 16 | 1 | cufft_gpu | 22.242 | 158.41 | 22.366 | 157.53 | 1024.00 | ok |
| throughput | n4194304_b1 | 4194304 | 1 | 1 | cufft_gpu | 2.784 | 165.73 | 2.774 | 166.30 | 128.00 | ok |
| throughput | n4194304_b4 | 4194304 | 4 | 1 | cufft_gpu | 11.166 | 165.28 | 11.197 | 164.82 | 512.00 | ok |
| throughput | n4194304_b16 | 4194304 | 16 | 1 | cufft_gpu | 45.109 | 163.65 | 45.218 | 163.25 | 2048.00 | ok |
| batch_scaling | n16384_b1_t1 | 16384 | 1 | 1 | cufft_gpu_batch_scaling | 0.0363 | 31.63 | 0.0296 | 38.75 | 0.50 | ok |
| batch_scaling | n16384_b4_t1 | 16384 | 4 | 1 | cufft_gpu_batch_scaling | 0.0647 | 70.92 | 0.0655 | 70.00 | 2.00 | ok |
| batch_scaling | n16384_b16_t1 | 16384 | 16 | 1 | cufft_gpu_batch_scaling | 0.192 | 95.78 | 0.187 | 98.36 | 8.00 | ok |
| batch_scaling | n16384_b64_t1 | 16384 | 64 | 1 | cufft_gpu_batch_scaling | 0.678 | 108.29 | 0.673 | 109.04 | 32.00 | ok |
| batch_scaling | n16384_b256_t1 | 16384 | 256 | 1 | cufft_gpu_batch_scaling | 2.670 | 109.95 | 2.654 | 110.64 | 128.00 | ok |

