# FFT Benchmark Report (GPU, cuFFT, 1D)

- Generated at: Thu Feb 19 16:42:37 IST 2026
- Source log: ./fft_logs/fft_benchmark_gpu_20260219_164228.log

## Scenario Catalog

| Run Profile | Description | Workload | Timing Mode |
|---|---|---|---|
| cufft_gpu | cuFFT throughput sweep on RTX 3080 (1D single precision, timing=e2e) | throughput | e2e |
| cufft_gpu_batch_scaling | cuFFT batch scaling sweep on fixed length (timing=e2e) | batch_scaling | e2e |

## Consolidated Results

Metrics use explicit units: milliseconds (`ms`), single-precision gigaflops (`SP GFLOPS`), and memory (`MB`).

| Workload | Case | Length | Batch | ThreadsField | Run Profile | Fwd ms | Fwd SP GFLOPS | Bwd ms | Bwd SP GFLOPS | Mem MB | Status |
|---|---|---|---|---|---|---|---|---|---|---|---|
| throughput | n32_b1 | 32 | 1 | 1 | cufft_gpu | 0.0130 | 0.06 | 0.0121 | 0.07 | 0.00 | ok |
| throughput | n32_b4 | 32 | 4 | 1 | cufft_gpu | 0.0131 | 0.24 | 0.0109 | 0.29 | 0.00 | ok |
| throughput | n32_b16 | 32 | 16 | 1 | cufft_gpu | 0.009798 | 1.31 | 0.0136 | 0.94 | 0.01 | ok |
| throughput | n64_b1 | 64 | 1 | 1 | cufft_gpu | 0.0130 | 0.15 | 0.009117 | 0.21 | 0.00 | ok |
| throughput | n64_b4 | 64 | 4 | 1 | cufft_gpu | 0.0139 | 0.55 | 0.0139 | 0.55 | 0.00 | ok |
| throughput | n64_b16 | 64 | 16 | 1 | cufft_gpu | 0.0143 | 2.15 | 0.0138 | 2.23 | 0.02 | ok |
| throughput | n128_b1 | 128 | 1 | 1 | cufft_gpu | 0.009059 | 0.49 | 0.0125 | 0.36 | 0.00 | ok |
| throughput | n128_b4 | 128 | 4 | 1 | cufft_gpu | 0.0180 | 1.00 | 0.009838 | 1.82 | 0.01 | ok |
| throughput | n128_b16 | 128 | 16 | 1 | cufft_gpu | 0.0157 | 4.57 | 0.0115 | 6.25 | 0.03 | ok |
| throughput | n256_b1 | 256 | 1 | 1 | cufft_gpu | 0.0179 | 0.57 | 0.0139 | 0.74 | 0.00 | ok |
| throughput | n256_b4 | 256 | 4 | 1 | cufft_gpu | 0.0138 | 2.97 | 0.0109 | 3.75 | 0.02 | ok |
| throughput | n256_b16 | 256 | 16 | 1 | cufft_gpu | 0.0169 | 9.69 | 0.0177 | 9.28 | 0.06 | ok |
| throughput | n512_b1 | 512 | 1 | 1 | cufft_gpu | 0.0138 | 1.66 | 0.0139 | 1.66 | 0.01 | ok |
| throughput | n512_b4 | 512 | 4 | 1 | cufft_gpu | 0.0208 | 4.44 | 0.0167 | 5.50 | 0.03 | ok |
| throughput | n512_b16 | 512 | 16 | 1 | cufft_gpu | 0.0236 | 15.61 | 0.0222 | 16.58 | 0.12 | ok |
| throughput | n1024_b1 | 1024 | 1 | 1 | cufft_gpu | 0.0140 | 3.66 | 0.0139 | 3.69 | 0.02 | ok |
| throughput | n1024_b4 | 1024 | 4 | 1 | cufft_gpu | 0.0173 | 11.82 | 0.0227 | 9.01 | 0.06 | ok |
| throughput | n1024_b16 | 1024 | 16 | 1 | cufft_gpu | 0.0246 | 33.25 | 0.0307 | 26.67 | 0.25 | ok |
| throughput | n2048_b1 | 2048 | 1 | 1 | cufft_gpu | 0.0218 | 5.17 | 0.0165 | 6.84 | 0.03 | ok |
| throughput | n2048_b4 | 2048 | 4 | 1 | cufft_gpu | 0.0237 | 19.02 | 0.0258 | 17.49 | 0.12 | ok |
| throughput | n2048_b16 | 2048 | 16 | 1 | cufft_gpu | 0.0401 | 44.99 | 0.0372 | 48.50 | 0.50 | ok |
| throughput | n4096_b1 | 4096 | 1 | 1 | cufft_gpu | 0.0234 | 10.52 | 0.0223 | 11.03 | 0.06 | ok |
| throughput | n4096_b4 | 4096 | 4 | 1 | cufft_gpu | 0.0307 | 31.99 | 0.0245 | 40.16 | 0.25 | ok |
| throughput | n4096_b16 | 4096 | 16 | 1 | cufft_gpu | 0.0591 | 66.55 | 0.0598 | 65.74 | 1.00 | ok |
| throughput | n8192_b1 | 8192 | 1 | 1 | cufft_gpu | 0.0255 | 20.92 | 0.0320 | 16.63 | 0.12 | ok |
| throughput | n8192_b4 | 8192 | 4 | 1 | cufft_gpu | 0.0427 | 49.86 | 0.0417 | 51.11 | 0.50 | ok |
| throughput | n8192_b16 | 8192 | 16 | 1 | cufft_gpu | 0.104 | 81.98 | 0.103 | 82.81 | 2.00 | ok |
| throughput | n16384_b1 | 16384 | 1 | 1 | cufft_gpu | 0.0362 | 31.73 | 0.0361 | 31.75 | 0.25 | ok |
| throughput | n16384_b4 | 16384 | 4 | 1 | cufft_gpu | 0.0661 | 69.37 | 0.0650 | 70.62 | 1.00 | ok |
| throughput | n16384_b16 | 16384 | 16 | 1 | cufft_gpu | 0.194 | 94.43 | 0.186 | 98.48 | 4.00 | ok |
| throughput | n32768_b1 | 32768 | 1 | 1 | cufft_gpu | 0.0451 | 54.55 | 0.0384 | 63.92 | 0.50 | ok |
| throughput | n32768_b4 | 32768 | 4 | 1 | cufft_gpu | 0.106 | 92.64 | 0.103 | 95.69 | 2.00 | ok |
| throughput | n32768_b16 | 32768 | 16 | 1 | cufft_gpu | 0.361 | 108.89 | 0.356 | 110.58 | 8.00 | ok |
| throughput | n65536_b1 | 65536 | 1 | 1 | cufft_gpu | 0.0628 | 83.45 | 0.0621 | 84.39 | 1.00 | ok |
| throughput | n65536_b4 | 65536 | 4 | 1 | cufft_gpu | 0.193 | 108.61 | 0.184 | 114.07 | 4.00 | ok |
| throughput | n65536_b16 | 65536 | 16 | 1 | cufft_gpu | 0.699 | 119.97 | 0.699 | 119.97 | 16.00 | ok |
| throughput | n131072_b1 | 131072 | 1 | 1 | cufft_gpu | 0.106 | 104.99 | 0.103 | 108.29 | 2.00 | ok |
| throughput | n131072_b4 | 131072 | 4 | 1 | cufft_gpu | 0.361 | 123.55 | 0.353 | 126.18 | 8.00 | ok |
| throughput | n131072_b16 | 131072 | 16 | 1 | cufft_gpu | 1.377 | 129.49 | 1.379 | 129.27 | 32.00 | ok |
| throughput | n262144_b1 | 262144 | 1 | 1 | cufft_gpu | 0.194 | 121.33 | 0.186 | 126.90 | 4.00 | ok |
| throughput | n262144_b4 | 262144 | 4 | 1 | cufft_gpu | 0.720 | 131.03 | 0.698 | 135.14 | 16.00 | ok |
| throughput | n262144_b16 | 262144 | 16 | 1 | cufft_gpu | 2.880 | 131.08 | 2.835 | 133.16 | 64.00 | ok |
| throughput | n524288_b1 | 524288 | 1 | 1 | cufft_gpu | 0.361 | 137.93 | 0.354 | 140.64 | 8.00 | ok |
| throughput | n524288_b4 | 524288 | 4 | 1 | cufft_gpu | 1.382 | 144.19 | 1.385 | 143.86 | 32.00 | ok |
| throughput | n524288_b16 | 524288 | 16 | 1 | cufft_gpu | 5.667 | 140.61 | 5.630 | 141.55 | 128.00 | ok |
| throughput | n1048576_b1 | 1048576 | 1 | 1 | cufft_gpu | 0.703 | 149.05 | 0.704 | 149.04 | 16.00 | ok |
| throughput | n1048576_b4 | 1048576 | 4 | 1 | cufft_gpu | 2.803 | 149.63 | 2.770 | 151.44 | 64.00 | ok |
| throughput | n1048576_b16 | 1048576 | 16 | 1 | cufft_gpu | 11.185 | 150.00 | 11.214 | 149.61 | 256.00 | ok |
| throughput | n2097152_b1 | 2097152 | 1 | 1 | cufft_gpu | 1.391 | 158.34 | 1.390 | 158.44 | 32.00 | ok |
| throughput | n2097152_b4 | 2097152 | 4 | 1 | cufft_gpu | 5.541 | 158.97 | 5.510 | 159.85 | 128.00 | ok |
| throughput | n2097152_b16 | 2097152 | 16 | 1 | cufft_gpu | 22.315 | 157.89 | 22.437 | 157.03 | 512.00 | ok |
| throughput | n4194304_b1 | 4194304 | 1 | 1 | cufft_gpu | 2.887 | 159.80 | 2.772 | 166.45 | 64.00 | ok |
| throughput | n4194304_b4 | 4194304 | 4 | 1 | cufft_gpu | 11.178 | 165.09 | 11.174 | 165.15 | 256.00 | ok |
| throughput | n4194304_b16 | 4194304 | 16 | 1 | cufft_gpu | 45.063 | 163.81 | 45.092 | 163.71 | 1024.00 | ok |
| batch_scaling | n16384_b1_t1 | 16384 | 1 | 1 | cufft_gpu_batch_scaling | 0.0354 | 32.44 | 0.0362 | 31.71 | 0.25 | ok |
| batch_scaling | n16384_b4_t1 | 16384 | 4 | 1 | cufft_gpu_batch_scaling | 0.0647 | 70.87 | 0.0648 | 70.77 | 1.00 | ok |
| batch_scaling | n16384_b16_t1 | 16384 | 16 | 1 | cufft_gpu_batch_scaling | 0.192 | 95.74 | 0.187 | 98.13 | 4.00 | ok |
| batch_scaling | n16384_b64_t1 | 16384 | 64 | 1 | cufft_gpu_batch_scaling | 0.688 | 106.75 | 0.674 | 108.92 | 16.00 | ok |
| batch_scaling | n16384_b256_t1 | 16384 | 256 | 1 | cufft_gpu_batch_scaling | 2.903 | 101.15 | 2.664 | 110.20 | 64.00 | ok |

