# FFT Benchmark Report (GPU, cuFFT, 1D)

- Generated at: Thu Feb 19 15:21:20 IST 2026
- Source log: ./fft_logs/fft_benchmark_gpu_20260219_152119.log

## Scenario Catalog

| Run Profile | Description | Workload |
|---|---|---|
| cufft_gpu | cuFFT throughput sweep on RTX 3080 (1D single precision) | throughput |
| cufft_gpu_batch_scaling | cuFFT batch scaling sweep on fixed length | batch_scaling |

## Consolidated Results

Metrics use explicit units: milliseconds (`ms`), single-precision gigaflops (`SP GFLOPS`), and memory (`MB`).

| Workload | Case | Length | Batch | ThreadsField | Run Profile | Fwd ms | Fwd SP GFLOPS | Bwd ms | Bwd SP GFLOPS | Mem MB | Status |
|---|---|---|---|---|---|---|---|---|---|---|---|
| throughput | n1024_b1 | 1024 | 1 | 1 | cufft_gpu | 0.003891 | 13.16 | 0.003686 | 13.89 | 0.02 | ok |
| throughput | n1024_b4 | 1024 | 4 | 1 | cufft_gpu | 0.004506 | 45.45 | 0.004096 | 50.00 | 0.06 | ok |
| throughput | n1024_b16 | 1024 | 16 | 1 | cufft_gpu | 0.004301 | 190.48 | 0.004096 | 200.00 | 0.25 | ok |
| throughput | n16384_b1 | 16384 | 1 | 1 | cufft_gpu | 0.0106 | 107.76 | 0.0105 | 109.74 | 0.25 | ok |
| throughput | n16384_b4 | 16384 | 4 | 1 | cufft_gpu | 0.0104 | 439.22 | 0.0106 | 431.29 | 1.00 | ok |
| throughput | n16384_b16 | 16384 | 16 | 1 | cufft_gpu | 0.0160 | 1148.72 | 0.0156 | 1178.95 | 4.00 | ok |
| batch_scaling | n16384_b1_t1 | 16384 | 1 | 1 | cufft_gpu_batch_scaling | 0.0106 | 107.69 | 0.0104 | 110.34 | 0.25 | ok |
| batch_scaling | n16384_b4_t1 | 16384 | 4 | 1 | cufft_gpu_batch_scaling | 0.0104 | 439.22 | 0.0106 | 431.81 | 1.00 | ok |
| batch_scaling | n16384_b16_t1 | 16384 | 16 | 1 | cufft_gpu_batch_scaling | 0.0162 | 1134.18 | 0.0157 | 1166.95 | 4.00 | ok |
| batch_scaling | n16384_b64_t1 | 16384 | 64 | 1 | cufft_gpu_batch_scaling | 0.0363 | 2023.43 | 0.0352 | 2083.72 | 16.00 | ok |

