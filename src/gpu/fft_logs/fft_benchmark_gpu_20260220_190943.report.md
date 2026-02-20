# FFT Benchmark Report (GPU, cuFFT, 1D)

- Generated at: Fri Feb 20 19:09:53 IST 2026
- Source log: ./fft_logs/fft_benchmark_gpu_20260220_190943.log

## Scenario Catalog

| Run Profile | Description | Workload | Timing Mode |
|---|---|---|---|
| cufft_gpu | cuFFT throughput sweep on RTX 3080 (1D single precision, timing=e2e) | throughput | e2e |
| cufft_gpu_batch_scaling | cuFFT batch scaling sweep on fixed length (timing=e2e) | batch_scaling | e2e |

## Consolidated Results

Metrics use explicit units: milliseconds (`ms`), single-precision gigaflops (`SP GFLOPS`), and memory (`MB`).

| Workload | Case | Length | Batch | ThreadsField | Run Profile | Fwd ms | Fwd SP GFLOPS | Bwd ms | Bwd SP GFLOPS | Mem MB | Status |
|---|---|---|---|---|---|---|---|---|---|---|---|
| throughput | n32_b1 | 32 | 1 | 1 | cufft_gpu | 0.0121 | 0.07 | 0.0129 | 0.06 | 0.00 | ok |
| throughput | n32_b4 | 32 | 4 | 1 | cufft_gpu | 0.0133 | 0.24 | 0.0129 | 0.25 | 0.00 | ok |
| throughput | n32_b16 | 32 | 16 | 1 | cufft_gpu | 0.0138 | 0.92 | 0.0133 | 0.96 | 0.02 | ok |
| throughput | n64_b1 | 64 | 1 | 1 | cufft_gpu | 0.0122 | 0.16 | 0.0130 | 0.15 | 0.00 | ok |
| throughput | n64_b4 | 64 | 4 | 1 | cufft_gpu | 0.0143 | 0.54 | 0.0130 | 0.59 | 0.01 | ok |
| throughput | n64_b16 | 64 | 16 | 1 | cufft_gpu | 0.009746 | 3.15 | 0.0138 | 2.22 | 0.03 | ok |
| throughput | n128_b1 | 128 | 1 | 1 | cufft_gpu | 0.0130 | 0.35 | 0.0121 | 0.37 | 0.00 | ok |
| throughput | n128_b4 | 128 | 4 | 1 | cufft_gpu | 0.009742 | 1.84 | 0.0139 | 1.29 | 0.02 | ok |
| throughput | n128_b16 | 128 | 16 | 1 | cufft_gpu | 0.0163 | 4.38 | 0.0155 | 4.62 | 0.06 | ok |
| throughput | n256_b1 | 256 | 1 | 1 | cufft_gpu | 0.0139 | 0.74 | 0.0139 | 0.74 | 0.01 | ok |
| throughput | n256_b4 | 256 | 4 | 1 | cufft_gpu | 0.0135 | 3.03 | 0.0138 | 2.97 | 0.03 | ok |
| throughput | n256_b16 | 256 | 16 | 1 | cufft_gpu | 0.0174 | 9.40 | 0.0171 | 9.61 | 0.12 | ok |
| throughput | n512_b1 | 512 | 1 | 1 | cufft_gpu | 0.0135 | 1.71 | 0.009782 | 2.36 | 0.02 | ok |
| throughput | n512_b4 | 512 | 4 | 1 | cufft_gpu | 0.0149 | 6.18 | 0.0163 | 5.66 | 0.06 | ok |
| throughput | n512_b16 | 512 | 16 | 1 | cufft_gpu | 0.0226 | 16.31 | 0.0228 | 16.18 | 0.25 | ok |
| throughput | n1024_b1 | 1024 | 1 | 1 | cufft_gpu | 0.0176 | 2.91 | 0.0140 | 3.66 | 0.03 | ok |
| throughput | n1024_b4 | 1024 | 4 | 1 | cufft_gpu | 0.0174 | 11.79 | 0.0173 | 11.86 | 0.12 | ok |
| throughput | n1024_b16 | 1024 | 16 | 1 | cufft_gpu | 0.0307 | 26.70 | 0.0304 | 26.94 | 0.50 | ok |
| throughput | n2048_b1 | 2048 | 1 | 1 | cufft_gpu | 0.0164 | 6.87 | 0.0164 | 6.85 | 0.06 | ok |
| throughput | n2048_b4 | 2048 | 4 | 1 | cufft_gpu | 0.0239 | 18.83 | 0.0257 | 17.56 | 0.25 | ok |
| throughput | n2048_b16 | 2048 | 16 | 1 | cufft_gpu | 0.0393 | 45.81 | 0.0368 | 48.99 | 1.00 | ok |
| throughput | n4096_b1 | 4096 | 1 | 1 | cufft_gpu | 0.0232 | 10.61 | 0.0177 | 13.88 | 0.12 | ok |
| throughput | n4096_b4 | 4096 | 4 | 1 | cufft_gpu | 0.0246 | 39.97 | 0.0307 | 32.00 | 0.50 | ok |
| throughput | n4096_b16 | 4096 | 16 | 1 | cufft_gpu | 0.0599 | 65.66 | 0.0596 | 66.00 | 2.00 | ok |
| throughput | n8192_b1 | 8192 | 1 | 1 | cufft_gpu | 0.0252 | 21.12 | 0.0252 | 21.10 | 0.25 | ok |
| throughput | n8192_b4 | 8192 | 4 | 1 | cufft_gpu | 0.0431 | 49.38 | 0.0445 | 47.87 | 1.00 | ok |
| throughput | n8192_b16 | 8192 | 16 | 1 | cufft_gpu | 0.102 | 83.92 | 0.102 | 83.26 | 4.00 | ok |
| throughput | n16384_b1 | 16384 | 1 | 1 | cufft_gpu | 0.0353 | 32.48 | 0.0353 | 32.53 | 0.50 | ok |
| throughput | n16384_b4 | 16384 | 4 | 1 | cufft_gpu | 0.0646 | 70.97 | 0.0658 | 69.68 | 2.00 | ok |
| throughput | n16384_b16 | 16384 | 16 | 1 | cufft_gpu | 0.191 | 96.03 | 0.187 | 98.33 | 8.00 | ok |
| throughput | n32768_b1 | 32768 | 1 | 1 | cufft_gpu | 0.0433 | 56.73 | 0.0450 | 54.61 | 1.00 | ok |
| throughput | n32768_b4 | 32768 | 4 | 1 | cufft_gpu | 0.103 | 95.34 | 0.102 | 96.43 | 4.00 | ok |
| throughput | n32768_b16 | 32768 | 16 | 1 | cufft_gpu | 0.361 | 108.95 | 0.355 | 110.89 | 16.00 | ok |
| throughput | n65536_b1 | 65536 | 1 | 1 | cufft_gpu | 0.0639 | 81.99 | 0.0606 | 86.50 | 2.00 | ok |
| throughput | n65536_b4 | 65536 | 4 | 1 | cufft_gpu | 0.189 | 110.79 | 0.184 | 114.20 | 8.00 | ok |
| throughput | n65536_b16 | 65536 | 16 | 1 | cufft_gpu | 0.710 | 118.09 | 0.697 | 120.27 | 32.00 | ok |
| throughput | n131072_b1 | 131072 | 1 | 1 | cufft_gpu | 0.107 | 104.14 | 0.103 | 108.21 | 4.00 | ok |
| throughput | n131072_b4 | 131072 | 4 | 1 | cufft_gpu | 0.361 | 123.56 | 0.353 | 126.13 | 16.00 | ok |
| throughput | n131072_b16 | 131072 | 16 | 1 | cufft_gpu | 1.389 | 128.30 | 1.376 | 129.56 | 64.00 | ok |
| throughput | n262144_b1 | 262144 | 1 | 1 | cufft_gpu | 0.196 | 120.53 | 0.186 | 127.08 | 8.00 | ok |
| throughput | n262144_b4 | 262144 | 4 | 1 | cufft_gpu | 0.711 | 132.81 | 0.697 | 135.39 | 32.00 | ok |
| throughput | n262144_b16 | 262144 | 16 | 1 | cufft_gpu | 2.860 | 131.98 | 2.820 | 133.84 | 128.00 | ok |
| throughput | n524288_b1 | 524288 | 1 | 1 | cufft_gpu | 0.364 | 136.99 | 0.356 | 139.85 | 16.00 | ok |
| throughput | n524288_b4 | 524288 | 4 | 1 | cufft_gpu | 1.383 | 144.09 | 1.385 | 143.83 | 64.00 | ok |
| throughput | n524288_b16 | 524288 | 16 | 1 | cufft_gpu | 5.606 | 142.16 | 5.622 | 141.75 | 256.00 | ok |
| throughput | n1048576_b1 | 1048576 | 1 | 1 | cufft_gpu | 0.703 | 149.24 | 0.704 | 148.98 | 32.00 | ok |
| throughput | n1048576_b4 | 1048576 | 4 | 1 | cufft_gpu | 2.757 | 152.12 | 2.777 | 151.04 | 128.00 | ok |
| throughput | n1048576_b16 | 1048576 | 16 | 1 | cufft_gpu | 11.153 | 150.43 | 11.235 | 149.34 | 512.00 | ok |
| throughput | n2097152_b1 | 2097152 | 1 | 1 | cufft_gpu | 1.391 | 158.35 | 1.390 | 158.43 | 64.00 | ok |
| throughput | n2097152_b4 | 2097152 | 4 | 1 | cufft_gpu | 5.532 | 159.23 | 5.587 | 157.64 | 256.00 | ok |
| throughput | n2097152_b16 | 2097152 | 16 | 1 | cufft_gpu | 22.292 | 158.05 | 22.353 | 157.62 | 1024.00 | ok |
| throughput | n4194304_b1 | 4194304 | 1 | 1 | cufft_gpu | 2.806 | 164.42 | 2.780 | 165.96 | 128.00 | ok |
| throughput | n4194304_b4 | 4194304 | 4 | 1 | cufft_gpu | 11.248 | 164.07 | 11.222 | 164.46 | 512.00 | ok |
| throughput | n4194304_b16 | 4194304 | 16 | 1 | cufft_gpu | 45.125 | 163.59 | 45.208 | 163.29 | 2048.00 | ok |
| batch_scaling | n16384_b1_t1 | 16384 | 1 | 1 | cufft_gpu_batch_scaling | 0.0321 | 35.76 | 0.0357 | 32.14 | 0.50 | ok |
| batch_scaling | n16384_b4_t1 | 16384 | 4 | 1 | cufft_gpu_batch_scaling | 0.0649 | 70.70 | 0.0668 | 68.72 | 2.00 | ok |
| batch_scaling | n16384_b16_t1 | 16384 | 16 | 1 | cufft_gpu_batch_scaling | 0.192 | 95.74 | 0.186 | 98.47 | 8.00 | ok |
| batch_scaling | n16384_b64_t1 | 16384 | 64 | 1 | cufft_gpu_batch_scaling | 0.677 | 108.42 | 0.673 | 109.02 | 32.00 | ok |
| batch_scaling | n16384_b256_t1 | 16384 | 256 | 1 | cufft_gpu_batch_scaling | 2.669 | 110.02 | 2.654 | 110.64 | 128.00 | ok |

