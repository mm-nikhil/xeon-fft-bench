# FFT Benchmark Report

- Generated at: Wed Feb 18 11:33:04 IST 2026
- Source log: ./fft_logs/fft_benchmark_20260218_111005.log

## Scenario Catalog

| Run Profile | Description | Workload | ISA Cap | Threads | What This Run Is For |
|---|---|---|---|---|---|
| baseline_sse42_1t | MKL SSE4.2 baseline, single thread (CPU path, no AVX2/AVX512 kernels) | throughput | SSE4_2 | 1 | Single-thread ISA comparison |
| avx2_1t | MKL AVX2, single thread | throughput | AVX2 | 1 | Single-thread ISA comparison |
| avx512_1t | MKL AVX-512, single thread | throughput | AVX512 | 1 | Single-thread ISA comparison |
| avx2_phys | MKL AVX2, physical-core thread count | throughput | AVX2 | 10 | Multithread throughput at fixed thread count |
| avx512_phys | MKL AVX-512, physical-core thread count | throughput | AVX512 | 10 | Multithread throughput at fixed thread count |
| avx512_logical | MKL AVX-512, logical-core thread count (hyperthreading on) | throughput | AVX512 | 20 | Multithread throughput at fixed thread count |
| avx512_thread_scaling | MKL AVX-512 thread scaling sweep on fixed problem | thread_scaling | AVX512 | 10 | Thread sweep on fixed grid and batch |
| avx512_batch_scaling | MKL AVX-512 batch scaling sweep on fixed problem | batch_scaling | AVX512 | 10 | Batch sweep on fixed grid and threads |

## Consolidated Results

Metrics use explicit units: milliseconds (`ms`), gigaflops (`GFLOPS`), and memory (`MB`).

| Case | Grid | Batch | Threads | Run Profile | ISA Cap | Fwd ms | Fwd GFLOPS | Bwd ms | Bwd GFLOPS | Mem MB | Fwd Speedup vs baseline_sse42_1t |
|---|---|---|---|---|---|---|---|---|---|---|---|
| n32_b1 | 32x32x32 | 1 | 1 | baseline_sse42_1t | SSE4_2 | 0.186 | 13.23 | 0.183 | 13.42 | 1.0 | 1.00x |
| n32_b1 | 32x32x32 | 1 | 1 | avx2_1t | AVX2 | 0.108 | 22.79 | 0.104 | 23.70 | 1.0 | 1.72x |
| n32_b1 | 32x32x32 | 1 | 1 | avx512_1t | AVX512 | 0.068 | 36.37 | 0.067 | 36.52 | 1.0 | 2.75x |
| n32_b1 | 32x32x32 | 1 | 10 | avx2_phys | AVX2 | 0.040 | 61.79 | 0.042 | 59.12 | 1.0 | 4.67x |
| n32_b1 | 32x32x32 | 1 | 10 | avx512_phys | AVX512 | 0.037 | 65.68 | 0.038 | 65.11 | 1.0 | 4.97x |
| n32_b1 | 32x32x32 | 1 | 20 | avx512_logical | AVX512 | 0.039 | 62.31 | 0.038 | 64.04 | 1.0 | 4.71x |
| n32_b4 | 32x32x32 | 4 | 1 | baseline_sse42_1t | SSE4_2 | 0.701 | 14.02 | 0.725 | 13.57 | 4.0 | 1.00x |
| n32_b4 | 32x32x32 | 4 | 1 | avx2_1t | AVX2 | 0.483 | 20.37 | 0.490 | 20.04 | 4.0 | 1.45x |
| n32_b4 | 32x32x32 | 4 | 1 | avx512_1t | AVX512 | 0.341 | 28.80 | 0.350 | 28.07 | 4.0 | 2.05x |
| n32_b4 | 32x32x32 | 4 | 10 | avx2_phys | AVX2 | 0.127 | 77.33 | 0.126 | 77.71 | 4.0 | 5.52x |
| n32_b4 | 32x32x32 | 4 | 10 | avx512_phys | AVX512 | 0.092 | 107.40 | 0.090 | 109.14 | 4.0 | 7.66x |
| n32_b4 | 32x32x32 | 4 | 20 | avx512_logical | AVX512 | 0.096 | 102.00 | 0.098 | 99.96 | 4.0 | 7.28x |
| n64_b1 | 64x64x64 | 1 | 1 | baseline_sse42_1t | SSE4_2 | 2.039 | 11.57 | 2.043 | 11.55 | 8.0 | 1.00x |
| n64_b1 | 64x64x64 | 1 | 1 | avx2_1t | AVX2 | 1.514 | 15.59 | 1.476 | 15.99 | 8.0 | 1.35x |
| n64_b1 | 64x64x64 | 1 | 1 | avx512_1t | AVX512 | 1.125 | 20.97 | 1.132 | 20.85 | 8.0 | 1.81x |
| n64_b1 | 64x64x64 | 1 | 10 | avx2_phys | AVX2 | 0.242 | 97.56 | 0.227 | 103.77 | 8.0 | 8.43x |
| n64_b1 | 64x64x64 | 1 | 10 | avx512_phys | AVX512 | 0.196 | 120.18 | 0.192 | 122.90 | 8.0 | 10.39x |
| n64_b1 | 64x64x64 | 1 | 20 | avx512_logical | AVX512 | 0.215 | 109.75 | 0.236 | 99.93 | 8.0 | 9.49x |
| n64_b4 | 64x64x64 | 4 | 1 | baseline_sse42_1t | SSE4_2 | 10.964 | 8.61 | 11.161 | 8.46 | 32.0 | 1.00x |
| n64_b4 | 64x64x64 | 4 | 1 | avx2_1t | AVX2 | 8.608 | 10.96 | 9.182 | 10.28 | 32.0 | 1.27x |
| n64_b4 | 64x64x64 | 4 | 1 | avx512_1t | AVX512 | 7.427 | 12.71 | 7.517 | 12.55 | 32.0 | 1.48x |
| n64_b4 | 64x64x64 | 4 | 10 | avx2_phys | AVX2 | 0.935 | 100.88 | 1.036 | 91.11 | 32.0 | 11.72x |
| n64_b4 | 64x64x64 | 4 | 10 | avx512_phys | AVX512 | 0.858 | 109.98 | 0.914 | 103.20 | 32.0 | 12.78x |
| n64_b4 | 64x64x64 | 4 | 20 | avx512_logical | AVX512 | 0.929 | 101.63 | 0.865 | 109.08 | 32.0 | 11.81x |
| n128_b1 | 128x128x128 | 1 | 1 | baseline_sse42_1t | SSE4_2 | 29.009 | 7.59 | 28.806 | 7.64 | 64.0 | 1.00x |
| n128_b1 | 128x128x128 | 1 | 1 | avx2_1t | AVX2 | 23.805 | 9.25 | 24.067 | 9.15 | 64.0 | 1.22x |
| n128_b1 | 128x128x128 | 1 | 1 | avx512_1t | AVX512 | 20.094 | 10.96 | 20.347 | 10.82 | 64.0 | 1.44x |
| n128_b1 | 128x128x128 | 1 | 10 | avx2_phys | AVX2 | 3.496 | 62.98 | 3.470 | 63.45 | 64.0 | 8.30x |
| n128_b1 | 128x128x128 | 1 | 10 | avx512_phys | AVX512 | 3.371 | 65.33 | 3.207 | 68.66 | 64.0 | 8.61x |
| n128_b1 | 128x128x128 | 1 | 20 | avx512_logical | AVX512 | 3.354 | 65.65 | 3.249 | 67.77 | 64.0 | 8.65x |
| n128_b4 | 128x128x128 | 4 | 1 | baseline_sse42_1t | SSE4_2 | 117.886 | 7.47 | 117.329 | 7.51 | 256.0 | 1.00x |
| n128_b4 | 128x128x128 | 4 | 1 | avx2_1t | AVX2 | 98.778 | 8.92 | 99.588 | 8.84 | 256.0 | 1.19x |
| n128_b4 | 128x128x128 | 4 | 1 | avx512_1t | AVX512 | 83.872 | 10.50 | 84.877 | 10.38 | 256.0 | 1.41x |
| n128_b4 | 128x128x128 | 4 | 10 | avx2_phys | AVX2 | 15.224 | 57.86 | 15.079 | 58.41 | 256.0 | 7.74x |
| n128_b4 | 128x128x128 | 4 | 10 | avx512_phys | AVX512 | 14.384 | 61.24 | 14.705 | 59.90 | 256.0 | 8.20x |
| n128_b4 | 128x128x128 | 4 | 20 | avx512_logical | AVX512 | 14.242 | 61.84 | 14.435 | 61.02 | 256.0 | 8.28x |
| n256_b1 | 256x256x256 | 1 | 1 | baseline_sse42_1t | SSE4_2 | 280.266 | 7.18 | 280.709 | 7.17 | 512.0 | 1.00x |
| n256_b1 | 256x256x256 | 1 | 1 | avx2_1t | AVX2 | 260.537 | 7.73 | 261.757 | 7.69 | 512.0 | 1.08x |
| n256_b1 | 256x256x256 | 1 | 1 | avx512_1t | AVX512 | 235.279 | 8.56 | 239.469 | 8.41 | 512.0 | 1.19x |
| n256_b1 | 256x256x256 | 1 | 10 | avx2_phys | AVX2 | 37.724 | 53.37 | 38.284 | 52.59 | 512.0 | 7.43x |
| n256_b1 | 256x256x256 | 1 | 10 | avx512_phys | AVX512 | 35.371 | 56.92 | 35.360 | 56.94 | 512.0 | 7.92x |
| n256_b1 | 256x256x256 | 1 | 20 | avx512_logical | AVX512 | 37.854 | 53.19 | 37.908 | 53.11 | 512.0 | 7.40x |
| n256_b4 | 256x256x256 | 4 | 1 | baseline_sse42_1t | SSE4_2 | 1069.418 | 7.53 | 1120.696 | 7.19 | 2048.0 | 1.00x |
| n256_b4 | 256x256x256 | 4 | 1 | avx2_1t | AVX2 | 963.987 | 8.35 | 1050.423 | 7.67 | 2048.0 | 1.11x |
| n256_b4 | 256x256x256 | 4 | 1 | avx512_1t | AVX512 | 862.519 | 9.34 | 948.117 | 8.49 | 2048.0 | 1.24x |
| n256_b4 | 256x256x256 | 4 | 10 | avx2_phys | AVX2 | 139.596 | 57.69 | 148.034 | 54.40 | 2048.0 | 7.66x |
| n256_b4 | 256x256x256 | 4 | 10 | avx512_phys | AVX512 | 132.523 | 60.77 | 138.094 | 58.32 | 2048.0 | 8.07x |
| n256_b4 | 256x256x256 | 4 | 20 | avx512_logical | AVX512 | 129.940 | 61.98 | 147.798 | 54.49 | 2048.0 | 8.23x |
| n128_b4_t1 | 128x128x128 | 4 | 1 | avx512_thread_scaling | AVX512 | 85.074 | 10.35 | 85.596 | 10.29 | 256.0 | - |
| n128_b4_t2 | 128x128x128 | 4 | 2 | avx512_thread_scaling | AVX512 | 45.564 | 19.33 | 44.555 | 19.77 | 256.0 | - |
| n128_b4_t4 | 128x128x128 | 4 | 4 | avx512_thread_scaling | AVX512 | 25.168 | 35.00 | 24.934 | 35.33 | 256.0 | - |
| n128_b4_t8 | 128x128x128 | 4 | 8 | avx512_thread_scaling | AVX512 | 18.140 | 48.56 | 18.303 | 48.12 | 256.0 | - |
| n128_b4_t10 | 128x128x128 | 4 | 10 | avx512_thread_scaling | AVX512 | 14.238 | 61.86 | 14.824 | 59.42 | 256.0 | - |
| n128_b4_t20 | 128x128x128 | 4 | 20 | avx512_thread_scaling | AVX512 | 15.222 | 57.86 | 15.780 | 55.82 | 256.0 | - |
| n128_b1_t10 | 128x128x128 | 1 | 10 | avx512_batch_scaling | AVX512 | 3.210 | 68.60 | 3.272 | 67.30 | 64.0 | - |
| n128_b2_t10 | 128x128x128 | 2 | 10 | avx512_batch_scaling | AVX512 | 7.189 | 61.26 | 7.094 | 62.08 | 128.0 | - |
| n128_b4_t10 | 128x128x128 | 4 | 10 | avx512_batch_scaling | AVX512 | 14.421 | 61.08 | 14.449 | 60.96 | 256.0 | - |
| n128_b8_t10 | 128x128x128 | 8 | 10 | avx512_batch_scaling | AVX512 | 28.223 | 62.42 | 31.416 | 56.07 | 512.0 | - |
| n128_b16_t10 | 128x128x128 | 16 | 10 | avx512_batch_scaling | AVX512 | 58.852 | 59.87 | 57.199 | 61.60 | 1024.0 | - |
| n128_b32_t10 | 128x128x128 | 32 | 10 | avx512_batch_scaling | AVX512 | 110.118 | 63.99 | 113.060 | 62.32 | 2048.0 | - |

