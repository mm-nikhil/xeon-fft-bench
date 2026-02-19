# FFT Benchmark Report (GPU, cuFFT, 1D)

- Generated at: Thu Feb 19 16:31:16 IST 2026
- Source log: ./fft_logs/fft_benchmark_gpu_20260219_163106.log

## Scenario Catalog

| Run Profile | Description | Workload | Timing Mode |
|---|---|---|---|
| cufft_gpu | cuFFT throughput sweep on RTX 3080 (1D single precision, timing=e2e) | throughput | e2e |
| cufft_gpu_batch_scaling | cuFFT batch scaling sweep on fixed length (timing=e2e) | batch_scaling | e2e |

## Consolidated Results

Metrics use explicit units: milliseconds (`ms`), single-precision gigaflops (`SP GFLOPS`), and memory (`MB`).

| Workload | Case | Length | Batch | ThreadsField | Run Profile | Fwd ms | Fwd SP GFLOPS | Bwd ms | Bwd SP GFLOPS | Mem MB | Status |
|---|---|---|---|---|---|---|---|---|---|---|---|
| throughput | n32_b1 | 32 | 1 | 1 | cufft_gpu | 0.0120 | 0.07 | 0.0128 | 0.06 | 0.00 | ok |
| throughput | n32_b4 | 32 | 4 | 1 | cufft_gpu | 0.009800 | 0.33 | 0.0135 | 0.24 | 0.00 | ok |
| throughput | n32_b16 | 32 | 16 | 1 | cufft_gpu | 0.0137 | 0.93 | 0.0128 | 1.00 | 0.01 | ok |
| throughput | n64_b1 | 64 | 1 | 1 | cufft_gpu | 0.009408 | 0.20 | 0.009021 | 0.21 | 0.00 | ok |
| throughput | n64_b4 | 64 | 4 | 1 | cufft_gpu | 0.0125 | 0.61 | 0.0120 | 0.64 | 0.00 | ok |
| throughput | n64_b16 | 64 | 16 | 1 | cufft_gpu | 0.009664 | 3.18 | 0.0138 | 2.22 | 0.02 | ok |
| throughput | n128_b1 | 128 | 1 | 1 | cufft_gpu | 0.0128 | 0.35 | 0.0126 | 0.36 | 0.00 | ok |
| throughput | n128_b4 | 128 | 4 | 1 | cufft_gpu | 0.009189 | 1.95 | 0.0119 | 1.51 | 0.01 | ok |
| throughput | n128_b16 | 128 | 16 | 1 | cufft_gpu | 0.0205 | 3.50 | 0.0151 | 4.76 | 0.03 | ok |
| throughput | n256_b1 | 256 | 1 | 1 | cufft_gpu | 0.0135 | 0.76 | 0.0106 | 0.97 | 0.00 | ok |
| throughput | n256_b4 | 256 | 4 | 1 | cufft_gpu | 0.0134 | 3.05 | 0.0103 | 3.97 | 0.02 | ok |
| throughput | n256_b16 | 256 | 16 | 1 | cufft_gpu | 0.0165 | 9.92 | 0.0158 | 10.36 | 0.06 | ok |
| throughput | n512_b1 | 512 | 1 | 1 | cufft_gpu | 0.0119 | 1.93 | 0.0146 | 1.58 | 0.01 | ok |
| throughput | n512_b4 | 512 | 4 | 1 | cufft_gpu | 0.0178 | 5.18 | 0.0199 | 4.62 | 0.03 | ok |
| throughput | n512_b16 | 512 | 16 | 1 | cufft_gpu | 0.0177 | 20.87 | 0.0173 | 21.35 | 0.12 | ok |
| throughput | n1024_b1 | 1024 | 1 | 1 | cufft_gpu | 0.0139 | 3.70 | 0.0136 | 3.77 | 0.02 | ok |
| throughput | n1024_b4 | 1024 | 4 | 1 | cufft_gpu | 0.0176 | 11.61 | 0.0171 | 11.98 | 0.06 | ok |
| throughput | n1024_b16 | 1024 | 16 | 1 | cufft_gpu | 0.0262 | 31.23 | 0.0305 | 26.83 | 0.25 | ok |
| throughput | n2048_b1 | 2048 | 1 | 1 | cufft_gpu | 0.0221 | 5.10 | 0.0207 | 5.45 | 0.03 | ok |
| throughput | n2048_b4 | 2048 | 4 | 1 | cufft_gpu | 0.0240 | 18.80 | 0.0180 | 25.07 | 0.12 | ok |
| throughput | n2048_b16 | 2048 | 16 | 1 | cufft_gpu | 0.0386 | 46.66 | 0.0368 | 49.03 | 0.50 | ok |
| throughput | n4096_b1 | 4096 | 1 | 1 | cufft_gpu | 0.0225 | 10.94 | 0.0176 | 13.99 | 0.06 | ok |
| throughput | n4096_b4 | 4096 | 4 | 1 | cufft_gpu | 0.0305 | 32.19 | 0.0303 | 32.48 | 0.25 | ok |
| throughput | n4096_b16 | 4096 | 16 | 1 | cufft_gpu | 0.0601 | 65.39 | 0.0558 | 70.45 | 1.00 | ok |
| throughput | n8192_b1 | 8192 | 1 | 1 | cufft_gpu | 0.0250 | 21.28 | 0.0250 | 21.31 | 0.12 | ok |
| throughput | n8192_b4 | 8192 | 4 | 1 | cufft_gpu | 0.0412 | 51.64 | 0.0412 | 51.66 | 0.50 | ok |
| throughput | n8192_b16 | 8192 | 16 | 1 | cufft_gpu | 0.107 | 79.79 | 0.103 | 83.03 | 2.00 | ok |
| throughput | n16384_b1 | 16384 | 1 | 1 | cufft_gpu | 0.0359 | 31.97 | 0.0358 | 31.99 | 0.25 | ok |
| throughput | n16384_b4 | 16384 | 4 | 1 | cufft_gpu | 0.0654 | 70.12 | 0.0653 | 70.24 | 1.00 | ok |
| throughput | n16384_b16 | 16384 | 16 | 1 | cufft_gpu | 0.192 | 95.58 | 0.187 | 98.35 | 4.00 | ok |
| throughput | n32768_b1 | 32768 | 1 | 1 | cufft_gpu | 0.0419 | 58.59 | 0.0440 | 55.87 | 0.50 | ok |
| throughput | n32768_b4 | 32768 | 4 | 1 | cufft_gpu | 0.104 | 94.89 | 0.103 | 95.43 | 2.00 | ok |
| throughput | n32768_b16 | 32768 | 16 | 1 | cufft_gpu | 0.367 | 107.07 | 0.357 | 110.29 | 8.00 | ok |
| throughput | n65536_b1 | 65536 | 1 | 1 | cufft_gpu | 0.0617 | 84.95 | 0.0609 | 86.10 | 1.00 | ok |
| throughput | n65536_b4 | 65536 | 4 | 1 | cufft_gpu | 0.191 | 109.80 | 0.184 | 114.10 | 4.00 | ok |
| throughput | n65536_b16 | 65536 | 16 | 1 | cufft_gpu | 0.720 | 116.54 | 0.698 | 120.11 | 16.00 | ok |
| throughput | n131072_b1 | 131072 | 1 | 1 | cufft_gpu | 0.103 | 108.19 | 0.104 | 107.03 | 2.00 | ok |
| throughput | n131072_b4 | 131072 | 4 | 1 | cufft_gpu | 0.367 | 121.36 | 0.355 | 125.71 | 8.00 | ok |
| throughput | n131072_b16 | 131072 | 16 | 1 | cufft_gpu | 1.394 | 127.87 | 1.379 | 129.31 | 32.00 | ok |
| throughput | n262144_b1 | 262144 | 1 | 1 | cufft_gpu | 0.196 | 120.62 | 0.189 | 124.98 | 4.00 | ok |
| throughput | n262144_b4 | 262144 | 4 | 1 | cufft_gpu | 0.712 | 132.53 | 0.699 | 135.07 | 16.00 | ok |
| throughput | n262144_b16 | 262144 | 16 | 1 | cufft_gpu | 2.781 | 135.73 | 2.745 | 137.50 | 64.00 | ok |
| throughput | n524288_b1 | 524288 | 1 | 1 | cufft_gpu | 0.367 | 135.62 | 0.355 | 140.17 | 8.00 | ok |
| throughput | n524288_b4 | 524288 | 4 | 1 | cufft_gpu | 1.386 | 143.78 | 1.385 | 143.89 | 32.00 | ok |
| throughput | n524288_b16 | 524288 | 16 | 1 | cufft_gpu | 5.606 | 142.16 | 5.673 | 140.47 | 128.00 | ok |
| throughput | n1048576_b1 | 1048576 | 1 | 1 | cufft_gpu | 0.711 | 147.42 | 0.704 | 149.03 | 16.00 | ok |
| throughput | n1048576_b4 | 1048576 | 4 | 1 | cufft_gpu | 2.788 | 150.43 | 2.759 | 152.00 | 64.00 | ok |
| throughput | n1048576_b16 | 1048576 | 16 | 1 | cufft_gpu | 11.203 | 149.76 | 11.169 | 150.22 | 256.00 | ok |
| throughput | n2097152_b1 | 2097152 | 1 | 1 | cufft_gpu | 1.389 | 158.49 | 1.390 | 158.39 | 32.00 | ok |
| throughput | n2097152_b4 | 2097152 | 4 | 1 | cufft_gpu | 5.555 | 158.55 | 5.530 | 159.27 | 128.00 | ok |
| throughput | n2097152_b16 | 2097152 | 16 | 1 | cufft_gpu | 22.337 | 157.73 | 22.390 | 157.35 | 512.00 | ok |
| throughput | n4194304_b1 | 4194304 | 1 | 1 | cufft_gpu | 2.875 | 160.48 | 2.882 | 160.07 | 64.00 | ok |
| throughput | n4194304_b4 | 4194304 | 4 | 1 | cufft_gpu | 11.308 | 163.20 | 11.323 | 162.99 | 256.00 | ok |
| throughput | n4194304_b16 | 4194304 | 16 | 1 | cufft_gpu | 44.814 | 164.72 | 45.075 | 163.77 | 1024.00 | ok |
| batch_scaling | n16384_b1_t1 | 16384 | 1 | 1 | cufft_gpu_batch_scaling | 0.0359 | 31.95 | 0.0330 | 34.78 | 0.25 | ok |
| batch_scaling | n16384_b4_t1 | 16384 | 4 | 1 | cufft_gpu_batch_scaling | 0.0647 | 70.88 | 0.0657 | 69.88 | 1.00 | ok |
| batch_scaling | n16384_b16_t1 | 16384 | 16 | 1 | cufft_gpu_batch_scaling | 0.192 | 95.44 | 0.189 | 97.02 | 4.00 | ok |
| batch_scaling | n16384_b64_t1 | 16384 | 64 | 1 | cufft_gpu_batch_scaling | 0.686 | 107.03 | 0.673 | 109.11 | 16.00 | ok |
| batch_scaling | n16384_b256_t1 | 16384 | 256 | 1 | cufft_gpu_batch_scaling | 2.673 | 109.83 | 2.656 | 110.56 | 64.00 | ok |

