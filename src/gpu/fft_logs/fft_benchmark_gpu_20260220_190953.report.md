# FFT Benchmark Report (GPU, cuFFT, 1D)

- Generated at: Fri Feb 20 19:10:04 IST 2026
- Source log: ./fft_logs/fft_benchmark_gpu_20260220_190953.log

## Scenario Catalog

| Run Profile | Description | Workload | Timing Mode |
|---|---|---|---|
| cufft_gpu | cuFFT throughput sweep on RTX 3080 (1D single precision, timing=e2e) | throughput | e2e |
| cufft_gpu_batch_scaling | cuFFT batch scaling sweep on fixed length (timing=e2e) | batch_scaling | e2e |

## Consolidated Results

Metrics use explicit units: milliseconds (`ms`), single-precision gigaflops (`SP GFLOPS`), and memory (`MB`).

| Workload | Case | Length | Batch | ThreadsField | Run Profile | Fwd ms | Fwd SP GFLOPS | Bwd ms | Bwd SP GFLOPS | Mem MB | Status |
|---|---|---|---|---|---|---|---|---|---|---|---|
| throughput | n32_b1 | 32 | 1 | 1 | cufft_gpu | 0.0130 | 0.06 | 0.0130 | 0.06 | 0.00 | ok |
| throughput | n32_b4 | 32 | 4 | 1 | cufft_gpu | 0.0132 | 0.24 | 0.0131 | 0.25 | 0.00 | ok |
| throughput | n32_b16 | 32 | 16 | 1 | cufft_gpu | 0.0147 | 0.87 | 0.0149 | 0.86 | 0.02 | ok |
| throughput | n64_b1 | 64 | 1 | 1 | cufft_gpu | 0.0121 | 0.16 | 0.0120 | 0.16 | 0.00 | ok |
| throughput | n64_b4 | 64 | 4 | 1 | cufft_gpu | 0.009344 | 0.82 | 0.0134 | 0.57 | 0.01 | ok |
| throughput | n64_b16 | 64 | 16 | 1 | cufft_gpu | 0.0143 | 2.16 | 0.0138 | 2.23 | 0.03 | ok |
| throughput | n128_b1 | 128 | 1 | 1 | cufft_gpu | 0.0121 | 0.37 | 0.0128 | 0.35 | 0.00 | ok |
| throughput | n128_b4 | 128 | 4 | 1 | cufft_gpu | 0.0138 | 1.30 | 0.0138 | 1.30 | 0.02 | ok |
| throughput | n128_b16 | 128 | 16 | 1 | cufft_gpu | 0.0107 | 6.68 | 0.0156 | 4.59 | 0.06 | ok |
| throughput | n256_b1 | 256 | 1 | 1 | cufft_gpu | 0.0138 | 0.74 | 0.009576 | 1.07 | 0.01 | ok |
| throughput | n256_b4 | 256 | 4 | 1 | cufft_gpu | 0.009816 | 4.17 | 0.0138 | 2.97 | 0.03 | ok |
| throughput | n256_b16 | 256 | 16 | 1 | cufft_gpu | 0.0129 | 12.68 | 0.0165 | 9.94 | 0.12 | ok |
| throughput | n512_b1 | 512 | 1 | 1 | cufft_gpu | 0.0130 | 1.77 | 0.0134 | 1.72 | 0.02 | ok |
| throughput | n512_b4 | 512 | 4 | 1 | cufft_gpu | 0.0165 | 5.58 | 0.0218 | 4.23 | 0.06 | ok |
| throughput | n512_b16 | 512 | 16 | 1 | cufft_gpu | 0.0179 | 20.60 | 0.0232 | 15.91 | 0.25 | ok |
| throughput | n1024_b1 | 1024 | 1 | 1 | cufft_gpu | 0.0137 | 3.73 | 0.0140 | 3.65 | 0.03 | ok |
| throughput | n1024_b4 | 1024 | 4 | 1 | cufft_gpu | 0.0232 | 8.84 | 0.0226 | 9.05 | 0.12 | ok |
| throughput | n1024_b16 | 1024 | 16 | 1 | cufft_gpu | 0.0250 | 32.71 | 0.0303 | 27.02 | 0.50 | ok |
| throughput | n2048_b1 | 2048 | 1 | 1 | cufft_gpu | 0.0165 | 6.82 | 0.0218 | 5.16 | 0.06 | ok |
| throughput | n2048_b4 | 2048 | 4 | 1 | cufft_gpu | 0.0299 | 15.09 | 0.0239 | 18.83 | 0.25 | ok |
| throughput | n2048_b16 | 2048 | 16 | 1 | cufft_gpu | 0.0382 | 47.20 | 0.0400 | 45.04 | 1.00 | ok |
| throughput | n4096_b1 | 4096 | 1 | 1 | cufft_gpu | 0.0231 | 10.63 | 0.0177 | 13.87 | 0.12 | ok |
| throughput | n4096_b4 | 4096 | 4 | 1 | cufft_gpu | 0.0243 | 40.39 | 0.0307 | 32.00 | 0.50 | ok |
| throughput | n4096_b16 | 4096 | 16 | 1 | cufft_gpu | 0.0599 | 65.68 | 0.0614 | 64.09 | 2.00 | ok |
| throughput | n8192_b1 | 8192 | 1 | 1 | cufft_gpu | 0.0311 | 17.15 | 0.0252 | 21.12 | 0.25 | ok |
| throughput | n8192_b4 | 8192 | 4 | 1 | cufft_gpu | 0.0428 | 49.79 | 0.0412 | 51.68 | 1.00 | ok |
| throughput | n8192_b16 | 8192 | 16 | 1 | cufft_gpu | 0.104 | 82.22 | 0.102 | 83.44 | 4.00 | ok |
| throughput | n16384_b1 | 16384 | 1 | 1 | cufft_gpu | 0.0364 | 31.50 | 0.0354 | 32.42 | 0.50 | ok |
| throughput | n16384_b4 | 16384 | 4 | 1 | cufft_gpu | 0.0657 | 69.81 | 0.0634 | 72.38 | 2.00 | ok |
| throughput | n16384_b16 | 16384 | 16 | 1 | cufft_gpu | 0.191 | 96.23 | 0.187 | 98.27 | 8.00 | ok |
| throughput | n32768_b1 | 32768 | 1 | 1 | cufft_gpu | 0.0431 | 57.03 | 0.0450 | 54.61 | 1.00 | ok |
| throughput | n32768_b4 | 32768 | 4 | 1 | cufft_gpu | 0.103 | 95.29 | 0.103 | 95.53 | 4.00 | ok |
| throughput | n32768_b16 | 32768 | 16 | 1 | cufft_gpu | 0.366 | 107.31 | 0.355 | 110.74 | 16.00 | ok |
| throughput | n65536_b1 | 65536 | 1 | 1 | cufft_gpu | 0.0623 | 84.22 | 0.0606 | 86.46 | 2.00 | ok |
| throughput | n65536_b4 | 65536 | 4 | 1 | cufft_gpu | 0.189 | 110.95 | 0.184 | 114.21 | 8.00 | ok |
| throughput | n65536_b16 | 65536 | 16 | 1 | cufft_gpu | 0.710 | 118.20 | 0.699 | 119.98 | 32.00 | ok |
| throughput | n131072_b1 | 131072 | 1 | 1 | cufft_gpu | 0.110 | 101.58 | 0.104 | 107.37 | 4.00 | ok |
| throughput | n131072_b4 | 131072 | 4 | 1 | cufft_gpu | 0.361 | 123.56 | 0.353 | 126.21 | 16.00 | ok |
| throughput | n131072_b16 | 131072 | 16 | 1 | cufft_gpu | 1.388 | 128.44 | 1.379 | 129.30 | 64.00 | ok |
| throughput | n262144_b1 | 262144 | 1 | 1 | cufft_gpu | 0.191 | 123.23 | 0.184 | 128.05 | 8.00 | ok |
| throughput | n262144_b4 | 262144 | 4 | 1 | cufft_gpu | 0.711 | 132.67 | 0.699 | 135.09 | 32.00 | ok |
| throughput | n262144_b16 | 262144 | 16 | 1 | cufft_gpu | 2.851 | 132.38 | 2.817 | 134.02 | 128.00 | ok |
| throughput | n524288_b1 | 524288 | 1 | 1 | cufft_gpu | 0.360 | 138.23 | 0.355 | 140.17 | 16.00 | ok |
| throughput | n524288_b4 | 524288 | 4 | 1 | cufft_gpu | 1.384 | 143.97 | 1.386 | 143.71 | 64.00 | ok |
| throughput | n524288_b16 | 524288 | 16 | 1 | cufft_gpu | 5.617 | 141.87 | 5.600 | 142.30 | 256.00 | ok |
| throughput | n1048576_b1 | 1048576 | 1 | 1 | cufft_gpu | 0.704 | 148.90 | 0.702 | 149.30 | 32.00 | ok |
| throughput | n1048576_b4 | 1048576 | 4 | 1 | cufft_gpu | 2.794 | 150.13 | 2.792 | 150.23 | 128.00 | ok |
| throughput | n1048576_b16 | 1048576 | 16 | 1 | cufft_gpu | 11.156 | 150.39 | 11.159 | 150.35 | 512.00 | ok |
| throughput | n2097152_b1 | 2097152 | 1 | 1 | cufft_gpu | 1.392 | 158.18 | 1.393 | 158.02 | 64.00 | ok |
| throughput | n2097152_b4 | 2097152 | 4 | 1 | cufft_gpu | 5.531 | 159.25 | 5.544 | 158.88 | 256.00 | ok |
| throughput | n2097152_b16 | 2097152 | 16 | 1 | cufft_gpu | 22.277 | 158.15 | 22.362 | 157.55 | 1024.00 | ok |
| throughput | n4194304_b1 | 4194304 | 1 | 1 | cufft_gpu | 2.891 | 159.59 | 2.844 | 162.23 | 128.00 | ok |
| throughput | n4194304_b4 | 4194304 | 4 | 1 | cufft_gpu | 11.325 | 162.95 | 11.366 | 162.37 | 512.00 | ok |
| throughput | n4194304_b16 | 4194304 | 16 | 1 | cufft_gpu | 45.109 | 163.65 | 45.193 | 163.34 | 2048.00 | ok |
| batch_scaling | n16384_b1_t1 | 16384 | 1 | 1 | cufft_gpu_batch_scaling | 0.0354 | 32.39 | 0.0353 | 32.50 | 0.50 | ok |
| batch_scaling | n16384_b4_t1 | 16384 | 4 | 1 | cufft_gpu_batch_scaling | 0.0647 | 70.93 | 0.0615 | 74.60 | 2.00 | ok |
| batch_scaling | n16384_b16_t1 | 16384 | 16 | 1 | cufft_gpu_batch_scaling | 0.192 | 95.45 | 0.186 | 98.41 | 8.00 | ok |
| batch_scaling | n16384_b64_t1 | 16384 | 64 | 1 | cufft_gpu_batch_scaling | 0.684 | 107.27 | 0.673 | 109.02 | 32.00 | ok |
| batch_scaling | n16384_b256_t1 | 16384 | 256 | 1 | cufft_gpu_batch_scaling | 2.670 | 109.96 | 2.653 | 110.65 | 128.00 | ok |

