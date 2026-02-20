# FFT Benchmark Report (GPU, cuFFT, 1D)

- Generated at: Fri Feb 20 19:09:23 IST 2026
- Source log: ./fft_logs/fft_benchmark_gpu_20260220_190913.log

## Scenario Catalog

| Run Profile | Description | Workload | Timing Mode |
|---|---|---|---|
| cufft_gpu | cuFFT throughput sweep on RTX 3080 (1D single precision, timing=e2e) | throughput | e2e |
| cufft_gpu_batch_scaling | cuFFT batch scaling sweep on fixed length (timing=e2e) | batch_scaling | e2e |

## Consolidated Results

Metrics use explicit units: milliseconds (`ms`), single-precision gigaflops (`SP GFLOPS`), and memory (`MB`).

| Workload | Case | Length | Batch | ThreadsField | Run Profile | Fwd ms | Fwd SP GFLOPS | Bwd ms | Bwd SP GFLOPS | Mem MB | Status |
|---|---|---|---|---|---|---|---|---|---|---|---|
| throughput | n32_b1 | 32 | 1 | 1 | cufft_gpu | 0.009354 | 0.09 | 0.0129 | 0.06 | 0.00 | ok |
| throughput | n32_b4 | 32 | 4 | 1 | cufft_gpu | 0.0130 | 0.25 | 0.0129 | 0.25 | 0.00 | ok |
| throughput | n32_b16 | 32 | 16 | 1 | cufft_gpu | 0.009806 | 1.31 | 0.009784 | 1.31 | 0.02 | ok |
| throughput | n64_b1 | 64 | 1 | 1 | cufft_gpu | 0.0118 | 0.16 | 0.0121 | 0.16 | 0.00 | ok |
| throughput | n64_b4 | 64 | 4 | 1 | cufft_gpu | 0.0163 | 0.47 | 0.0138 | 0.56 | 0.01 | ok |
| throughput | n64_b16 | 64 | 16 | 1 | cufft_gpu | 0.0138 | 2.22 | 0.0139 | 2.21 | 0.03 | ok |
| throughput | n128_b1 | 128 | 1 | 1 | cufft_gpu | 0.0117 | 0.38 | 0.0116 | 0.39 | 0.00 | ok |
| throughput | n128_b4 | 128 | 4 | 1 | cufft_gpu | 0.0180 | 1.00 | 0.0138 | 1.30 | 0.02 | ok |
| throughput | n128_b16 | 128 | 16 | 1 | cufft_gpu | 0.0162 | 4.44 | 0.0154 | 4.66 | 0.06 | ok |
| throughput | n256_b1 | 256 | 1 | 1 | cufft_gpu | 0.009802 | 1.04 | 0.0140 | 0.73 | 0.01 | ok |
| throughput | n256_b4 | 256 | 4 | 1 | cufft_gpu | 0.0139 | 2.94 | 0.0102 | 4.02 | 0.03 | ok |
| throughput | n256_b16 | 256 | 16 | 1 | cufft_gpu | 0.0227 | 7.22 | 0.0167 | 9.82 | 0.12 | ok |
| throughput | n512_b1 | 512 | 1 | 1 | cufft_gpu | 0.0141 | 1.64 | 0.009798 | 2.35 | 0.02 | ok |
| throughput | n512_b4 | 512 | 4 | 1 | cufft_gpu | 0.0165 | 5.58 | 0.0165 | 5.59 | 0.06 | ok |
| throughput | n512_b16 | 512 | 16 | 1 | cufft_gpu | 0.0174 | 21.15 | 0.0232 | 15.89 | 0.25 | ok |
| throughput | n1024_b1 | 1024 | 1 | 1 | cufft_gpu | 0.0144 | 3.57 | 0.0102 | 5.00 | 0.03 | ok |
| throughput | n1024_b4 | 1024 | 4 | 1 | cufft_gpu | 0.0174 | 11.78 | 0.0226 | 9.04 | 0.12 | ok |
| throughput | n1024_b16 | 1024 | 16 | 1 | cufft_gpu | 0.0253 | 32.43 | 0.0262 | 31.29 | 0.50 | ok |
| throughput | n2048_b1 | 2048 | 1 | 1 | cufft_gpu | 0.0206 | 5.48 | 0.0165 | 6.83 | 0.06 | ok |
| throughput | n2048_b4 | 2048 | 4 | 1 | cufft_gpu | 0.0175 | 25.78 | 0.0187 | 24.12 | 0.25 | ok |
| throughput | n2048_b16 | 2048 | 16 | 1 | cufft_gpu | 0.0380 | 47.37 | 0.0400 | 45.03 | 1.00 | ok |
| throughput | n4096_b1 | 4096 | 1 | 1 | cufft_gpu | 0.0174 | 14.10 | 0.0240 | 10.26 | 0.12 | ok |
| throughput | n4096_b4 | 4096 | 4 | 1 | cufft_gpu | 0.0307 | 31.97 | 0.0246 | 40.00 | 0.50 | ok |
| throughput | n4096_b16 | 4096 | 16 | 1 | cufft_gpu | 0.0604 | 65.14 | 0.0549 | 71.64 | 2.00 | ok |
| throughput | n8192_b1 | 8192 | 1 | 1 | cufft_gpu | 0.0254 | 20.99 | 0.0192 | 27.81 | 0.25 | ok |
| throughput | n8192_b4 | 8192 | 4 | 1 | cufft_gpu | 0.0440 | 48.41 | 0.0422 | 50.48 | 1.00 | ok |
| throughput | n8192_b16 | 8192 | 16 | 1 | cufft_gpu | 0.103 | 82.87 | 0.102 | 83.20 | 4.00 | ok |
| throughput | n16384_b1 | 16384 | 1 | 1 | cufft_gpu | 0.0353 | 32.46 | 0.0329 | 34.89 | 0.50 | ok |
| throughput | n16384_b4 | 16384 | 4 | 1 | cufft_gpu | 0.0644 | 71.20 | 0.0639 | 71.82 | 2.00 | ok |
| throughput | n16384_b16 | 16384 | 16 | 1 | cufft_gpu | 0.193 | 95.27 | 0.185 | 98.98 | 8.00 | ok |
| throughput | n32768_b1 | 32768 | 1 | 1 | cufft_gpu | 0.0426 | 57.66 | 0.0381 | 64.51 | 1.00 | ok |
| throughput | n32768_b4 | 32768 | 4 | 1 | cufft_gpu | 0.103 | 95.34 | 0.102 | 95.92 | 4.00 | ok |
| throughput | n32768_b16 | 32768 | 16 | 1 | cufft_gpu | 0.366 | 107.35 | 0.355 | 110.66 | 16.00 | ok |
| throughput | n65536_b1 | 65536 | 1 | 1 | cufft_gpu | 0.0610 | 85.93 | 0.0631 | 83.11 | 2.00 | ok |
| throughput | n65536_b4 | 65536 | 4 | 1 | cufft_gpu | 0.189 | 110.69 | 0.184 | 114.03 | 8.00 | ok |
| throughput | n65536_b16 | 65536 | 16 | 1 | cufft_gpu | 0.714 | 117.47 | 0.697 | 120.33 | 32.00 | ok |
| throughput | n131072_b1 | 131072 | 1 | 1 | cufft_gpu | 0.103 | 107.98 | 0.104 | 107.03 | 4.00 | ok |
| throughput | n131072_b4 | 131072 | 4 | 1 | cufft_gpu | 0.369 | 120.90 | 0.353 | 126.36 | 16.00 | ok |
| throughput | n131072_b16 | 131072 | 16 | 1 | cufft_gpu | 1.394 | 127.86 | 1.378 | 129.37 | 64.00 | ok |
| throughput | n262144_b1 | 262144 | 1 | 1 | cufft_gpu | 0.195 | 121.09 | 0.186 | 126.78 | 8.00 | ok |
| throughput | n262144_b4 | 262144 | 4 | 1 | cufft_gpu | 0.717 | 131.65 | 0.698 | 135.30 | 32.00 | ok |
| throughput | n262144_b16 | 262144 | 16 | 1 | cufft_gpu | 2.881 | 131.00 | 2.829 | 133.43 | 128.00 | ok |
| throughput | n524288_b1 | 524288 | 1 | 1 | cufft_gpu | 0.367 | 135.66 | 0.354 | 140.65 | 16.00 | ok |
| throughput | n524288_b4 | 524288 | 4 | 1 | cufft_gpu | 1.397 | 142.64 | 1.387 | 143.65 | 64.00 | ok |
| throughput | n524288_b16 | 524288 | 16 | 1 | cufft_gpu | 5.613 | 141.99 | 5.640 | 141.30 | 256.00 | ok |
| throughput | n1048576_b1 | 1048576 | 1 | 1 | cufft_gpu | 0.703 | 149.15 | 0.703 | 149.09 | 32.00 | ok |
| throughput | n1048576_b4 | 1048576 | 4 | 1 | cufft_gpu | 2.757 | 152.14 | 2.775 | 151.16 | 128.00 | ok |
| throughput | n1048576_b16 | 1048576 | 16 | 1 | cufft_gpu | 11.162 | 150.31 | 11.193 | 149.89 | 512.00 | ok |
| throughput | n2097152_b1 | 2097152 | 1 | 1 | cufft_gpu | 1.391 | 158.32 | 1.394 | 157.94 | 64.00 | ok |
| throughput | n2097152_b4 | 2097152 | 4 | 1 | cufft_gpu | 5.543 | 158.90 | 5.563 | 158.33 | 256.00 | ok |
| throughput | n2097152_b16 | 2097152 | 16 | 1 | cufft_gpu | 22.258 | 158.29 | 22.344 | 157.68 | 1024.00 | ok |
| throughput | n4194304_b1 | 4194304 | 1 | 1 | cufft_gpu | 2.811 | 164.11 | 2.774 | 166.31 | 128.00 | ok |
| throughput | n4194304_b4 | 4194304 | 4 | 1 | cufft_gpu | 11.125 | 165.88 | 11.166 | 165.27 | 512.00 | ok |
| throughput | n4194304_b16 | 4194304 | 16 | 1 | cufft_gpu | 45.087 | 163.73 | 45.184 | 163.38 | 2048.00 | ok |
| batch_scaling | n16384_b1_t1 | 16384 | 1 | 1 | cufft_gpu_batch_scaling | 0.0333 | 34.45 | 0.0296 | 38.74 | 0.50 | ok |
| batch_scaling | n16384_b4_t1 | 16384 | 4 | 1 | cufft_gpu_batch_scaling | 0.0648 | 70.81 | 0.0648 | 70.77 | 2.00 | ok |
| batch_scaling | n16384_b16_t1 | 16384 | 16 | 1 | cufft_gpu_batch_scaling | 0.193 | 95.20 | 0.188 | 97.79 | 8.00 | ok |
| batch_scaling | n16384_b64_t1 | 16384 | 64 | 1 | cufft_gpu_batch_scaling | 0.684 | 107.34 | 0.674 | 108.87 | 32.00 | ok |
| batch_scaling | n16384_b256_t1 | 16384 | 256 | 1 | cufft_gpu_batch_scaling | 2.666 | 110.12 | 2.654 | 110.63 | 128.00 | ok |

