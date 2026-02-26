# GPU FFT Latest Run (1D, wide batch sweep)

- Generated at: 2026-02-25 14:45:15.546068
- Manifest: `/home/nikhil/workspace/xeon-fft-bench/src/gpu/latest_run/64k_batch/20260225_144327/manifest.tsv`
- Runs combined: 1

## GPU Hardware

- GPU: NVIDIA GeForce RTX 3080
- Driver version: 580.126.09
- Compute capability: 8.6
- SM count: 68
- CUDA cores/SM: 128
- Total CUDA cores (SM x cores/SM): 8704
- Warp size: 32
- Max threads/SM (resident): 1536
- Max threads/block: 1024
- Max resident threads on device (SM x max threads/SM): 104448
- Reported global memory: 9872.4 MB

## Peak GFLOPS (SP)

- Formula: `peak_sp_gflops = cuda_cores * 2 FLOP/cycle * max_sm_clock_ghz`
- Max SM clock from nvidia-smi: 2115 MHz
- Estimated theoretical SP peak: 36817.92 GFLOPS
- Percent-of-peak columns in this report use this theoretical peak denominator.

## 1D FFT Benchmark Design

- cuFFT path: `cufftPlanMany` + `cufftExecC2C` forward/backward.
- Timing mode from profile metadata (`compute` or `e2e`).
- FLOP model: `5 * N * log2(N) * batch`.
- Wide sweep expected by this run: `N=32..4194304`, `batch=1..65536` (power-of-two list).

## Run Files

| Run | Log | Report |
|---|---|---|
| run01 | `/home/nikhil/workspace/xeon-fft-bench/src/gpu/latest_run/64k_batch/20260225_144327/runs/run01/fft_benchmark_gpu_20260225_144327.log` | `/home/nikhil/workspace/xeon-fft-bench/src/gpu/latest_run/64k_batch/20260225_144327/runs/run01/fft_benchmark_gpu_20260225_144327.report.md` |

## Scenario Catalog

| Profile | Description | Workload | Timing Mode |
|---|---|---|---|
| cufft_gpu | cuFFT throughput sweep on RTX 3080 (1D single precision, timing=compute) | throughput | compute |

## Summary Stats

- Rows aggregated: 306
- Quality counts: {'ok': 306}
- Best forward: `n16384_b16384` (cufft_gpu) = 2970.59 GFLOPS (8.07% peak)
- Best backward: `n16384_b16384` (cufft_gpu) = 2968.69 GFLOPS (8.06% peak)

## Averaged Results

| Workload | Case | N | Batch | ThreadsField | Profile | Timing | Avg Fwd ms | Avg Fwd SP GFLOPS | Avg Bwd ms | Avg Bwd SP GFLOPS | Fwd % Peak | Bwd % Peak | Avg Mem MB | Samples | Quality | Note |
|---|---|---:|---:|---:|---|---|---:|---:|---:|---:|---:|---:|---:|---|---|---|
| throughput | n32_b1 | 32 | 1 | 1 | cufft_gpu | compute | 0.002606 | 0.31 | 0.002509 | 0.32 | 0.00% | 0.00% | 0.00 | 1/1 | ok | - |
| throughput | n32_b2 | 32 | 2 | 1 | cufft_gpu | compute | 0.002597 | 0.62 | 0.002816 | 0.57 | 0.00% | 0.00% | 0.00 | 1/1 | ok | - |
| throughput | n32_b4 | 32 | 4 | 1 | cufft_gpu | compute | 0.002560 | 1.25 | 0.002658 | 1.20 | 0.00% | 0.00% | 0.00 | 1/1 | ok | - |
| throughput | n32_b8 | 32 | 8 | 1 | cufft_gpu | compute | 0.002662 | 2.40 | 0.002560 | 2.50 | 0.01% | 0.01% | 0.00 | 1/1 | ok | - |
| throughput | n32_b16 | 32 | 16 | 1 | cufft_gpu | compute | 0.002662 | 4.81 | 0.002677 | 4.78 | 0.01% | 0.01% | 0.01 | 1/1 | ok | - |
| throughput | n32_b32 | 32 | 32 | 1 | cufft_gpu | compute | 0.002867 | 8.93 | 0.002963 | 8.64 | 0.02% | 0.02% | 0.02 | 1/1 | ok | - |
| throughput | n32_b64 | 32 | 64 | 1 | cufft_gpu | compute | 0.002907 | 17.61 | 0.002856 | 17.93 | 0.05% | 0.05% | 0.03 | 1/1 | ok | - |
| throughput | n32_b128 | 32 | 128 | 1 | cufft_gpu | compute | 0.002931 | 34.94 | 0.002918 | 35.09 | 0.09% | 0.10% | 0.06 | 1/1 | ok | - |
| throughput | n32_b256 | 32 | 256 | 1 | cufft_gpu | compute | 0.002970 | 68.96 | 0.002918 | 70.19 | 0.19% | 0.19% | 0.12 | 1/1 | ok | - |
| throughput | n32_b512 | 32 | 512 | 1 | cufft_gpu | compute | 0.002918 | 140.37 | 0.002970 | 137.91 | 0.38% | 0.37% | 0.25 | 1/1 | ok | - |
| throughput | n32_b1024 | 32 | 1024 | 1 | cufft_gpu | compute | 0.003027 | 270.63 | 0.003029 | 270.45 | 0.74% | 0.73% | 0.50 | 1/1 | ok | - |
| throughput | n32_b2048 | 32 | 2048 | 1 | cufft_gpu | compute | 0.003226 | 507.87 | 0.003226 | 507.87 | 1.38% | 1.38% | 1.00 | 1/1 | ok | - |
| throughput | n32_b4096 | 32 | 4096 | 1 | cufft_gpu | compute | 0.004184 | 783.17 | 0.004045 | 810.09 | 2.13% | 2.20% | 2.00 | 1/1 | ok | - |
| throughput | n32_b8192 | 32 | 8192 | 1 | cufft_gpu | compute | 0.005478 | 1196.35 | 0.005478 | 1196.35 | 3.25% | 3.25% | 4.00 | 1/1 | ok | - |
| throughput | n32_b16384 | 32 | 16384 | 1 | cufft_gpu | compute | 0.0126 | 1036.72 | 0.0125 | 1046.07 | 2.82% | 2.84% | 8.00 | 1/1 | ok | - |
| throughput | n32_b32768 | 32 | 32768 | 1 | cufft_gpu | compute | 0.0262 | 1000.02 | 0.0263 | 996.10 | 2.72% | 2.71% | 16.00 | 1/1 | ok | - |
| throughput | n32_b65536 | 32 | 65536 | 1 | cufft_gpu | compute | 0.0506 | 1036.43 | 0.0506 | 1036.18 | 2.82% | 2.81% | 32.00 | 1/1 | ok | - |
| throughput | n64_b1 | 64 | 1 | 1 | cufft_gpu | compute | 0.002355 | 0.82 | 0.002406 | 0.80 | 0.00% | 0.00% | 0.00 | 1/1 | ok | - |
| throughput | n64_b2 | 64 | 2 | 1 | cufft_gpu | compute | 0.002406 | 1.60 | 0.002402 | 1.60 | 0.00% | 0.00% | 0.00 | 1/1 | ok | - |
| throughput | n64_b4 | 64 | 4 | 1 | cufft_gpu | compute | 0.002355 | 3.26 | 0.002406 | 3.19 | 0.01% | 0.01% | 0.00 | 1/1 | ok | - |
| throughput | n64_b8 | 64 | 8 | 1 | cufft_gpu | compute | 0.002406 | 6.38 | 0.002406 | 6.38 | 0.02% | 0.02% | 0.01 | 1/1 | ok | - |
| throughput | n64_b16 | 64 | 16 | 1 | cufft_gpu | compute | 0.002458 | 12.50 | 0.002458 | 12.50 | 0.03% | 0.03% | 0.02 | 1/1 | ok | - |
| throughput | n64_b32 | 64 | 32 | 1 | cufft_gpu | compute | 0.002560 | 24.00 | 0.002509 | 24.49 | 0.07% | 0.07% | 0.03 | 1/1 | ok | - |
| throughput | n64_b64 | 64 | 64 | 1 | cufft_gpu | compute | 0.002549 | 48.21 | 0.002803 | 43.84 | 0.13% | 0.12% | 0.06 | 1/1 | ok | - |
| throughput | n64_b128 | 64 | 128 | 1 | cufft_gpu | compute | 0.002502 | 98.23 | 0.002509 | 97.95 | 0.27% | 0.27% | 0.12 | 1/1 | ok | - |
| throughput | n64_b256 | 64 | 256 | 1 | cufft_gpu | compute | 0.002560 | 192.00 | 0.002509 | 195.90 | 0.52% | 0.53% | 0.25 | 1/1 | ok | - |
| throughput | n64_b512 | 64 | 512 | 1 | cufft_gpu | compute | 0.002714 | 362.21 | 0.002699 | 364.22 | 0.98% | 0.99% | 0.50 | 1/1 | ok | - |
| throughput | n64_b1024 | 64 | 1024 | 1 | cufft_gpu | compute | 0.003072 | 640.00 | 0.003061 | 642.30 | 1.74% | 1.74% | 1.00 | 1/1 | ok | - |
| throughput | n64_b2048 | 64 | 2048 | 1 | cufft_gpu | compute | 0.003738 | 1051.94 | 0.003738 | 1051.94 | 2.86% | 2.86% | 2.00 | 1/1 | ok | - |
| throughput | n64_b4096 | 64 | 4096 | 1 | cufft_gpu | compute | 0.004557 | 1725.77 | 0.004506 | 1745.30 | 4.69% | 4.74% | 4.00 | 1/1 | ok | - |
| throughput | n64_b8192 | 64 | 8192 | 1 | cufft_gpu | compute | 0.0128 | 1229.57 | 0.0120 | 1307.23 | 3.34% | 3.55% | 8.00 | 1/1 | ok | - |
| throughput | n64_b16384 | 64 | 16384 | 1 | cufft_gpu | compute | 0.0264 | 1190.71 | 0.0264 | 1190.93 | 3.23% | 3.23% | 16.00 | 1/1 | ok | - |
| throughput | n64_b32768 | 64 | 32768 | 1 | cufft_gpu | compute | 0.0514 | 1224.26 | 0.0513 | 1225.47 | 3.33% | 3.33% | 32.00 | 1/1 | ok | - |
| throughput | n64_b65536 | 64 | 65536 | 1 | cufft_gpu | compute | 0.100 | 1255.98 | 0.100 | 1256.46 | 3.41% | 3.41% | 64.00 | 1/1 | ok | - |
| throughput | n128_b1 | 128 | 1 | 1 | cufft_gpu | compute | 0.002621 | 1.71 | 0.002610 | 1.72 | 0.00% | 0.00% | 0.00 | 1/1 | ok | - |
| throughput | n128_b2 | 128 | 2 | 1 | cufft_gpu | compute | 0.002654 | 3.38 | 0.002608 | 3.44 | 0.01% | 0.01% | 0.00 | 1/1 | ok | - |
| throughput | n128_b4 | 128 | 4 | 1 | cufft_gpu | compute | 0.002714 | 6.60 | 0.002613 | 6.86 | 0.02% | 0.02% | 0.01 | 1/1 | ok | - |
| throughput | n128_b8 | 128 | 8 | 1 | cufft_gpu | compute | 0.002765 | 12.96 | 0.002714 | 13.21 | 0.04% | 0.04% | 0.02 | 1/1 | ok | - |
| throughput | n128_b16 | 128 | 16 | 1 | cufft_gpu | compute | 0.002714 | 26.41 | 0.002714 | 26.41 | 0.07% | 0.07% | 0.03 | 1/1 | ok | - |
| throughput | n128_b32 | 128 | 32 | 1 | cufft_gpu | compute | 0.002714 | 52.82 | 0.002749 | 52.15 | 0.14% | 0.14% | 0.06 | 1/1 | ok | - |
| throughput | n128_b64 | 128 | 64 | 1 | cufft_gpu | compute | 0.002699 | 106.23 | 0.002704 | 106.04 | 0.29% | 0.29% | 0.12 | 1/1 | ok | - |
| throughput | n128_b128 | 128 | 128 | 1 | cufft_gpu | compute | 0.002757 | 207.99 | 0.002714 | 211.29 | 0.56% | 0.57% | 0.25 | 1/1 | ok | - |
| throughput | n128_b256 | 128 | 256 | 1 | cufft_gpu | compute | 0.002918 | 393.04 | 0.002909 | 394.25 | 1.07% | 1.07% | 0.50 | 1/1 | ok | - |
| throughput | n128_b512 | 128 | 512 | 1 | cufft_gpu | compute | 0.003226 | 711.02 | 0.003226 | 711.02 | 1.93% | 1.93% | 1.00 | 1/1 | ok | - |
| throughput | n128_b1024 | 128 | 1024 | 1 | cufft_gpu | compute | 0.003936 | 1165.53 | 0.003888 | 1179.92 | 3.17% | 3.20% | 2.00 | 1/1 | ok | - |
| throughput | n128_b2048 | 128 | 2048 | 1 | cufft_gpu | compute | 0.005016 | 1829.15 | 0.004899 | 1872.84 | 4.97% | 5.09% | 4.00 | 1/1 | ok | - |
| throughput | n128_b4096 | 128 | 4096 | 1 | cufft_gpu | compute | 0.0135 | 1356.65 | 0.0132 | 1389.11 | 3.68% | 3.77% | 8.00 | 1/1 | ok | - |
| throughput | n128_b8192 | 128 | 8192 | 1 | cufft_gpu | compute | 0.0271 | 1354.35 | 0.0271 | 1355.00 | 3.68% | 3.68% | 16.00 | 1/1 | ok | - |
| throughput | n128_b16384 | 128 | 16384 | 1 | cufft_gpu | compute | 0.0514 | 1427.88 | 0.0514 | 1426.69 | 3.88% | 3.87% | 32.00 | 1/1 | ok | - |
| throughput | n128_b32768 | 128 | 32768 | 1 | cufft_gpu | compute | 0.101 | 1459.87 | 0.101 | 1459.87 | 3.97% | 3.97% | 64.00 | 1/1 | ok | - |
| throughput | n128_b65536 | 128 | 65536 | 1 | cufft_gpu | compute | 0.198 | 1481.40 | 0.198 | 1482.55 | 4.02% | 4.03% | 128.00 | 1/1 | ok | - |
| throughput | n256_b1 | 256 | 1 | 1 | cufft_gpu | compute | 0.002762 | 3.71 | 0.002714 | 3.77 | 0.01% | 0.01% | 0.00 | 1/1 | ok | - |
| throughput | n256_b2 | 256 | 2 | 1 | cufft_gpu | compute | 0.002714 | 7.55 | 0.002714 | 7.55 | 0.02% | 0.02% | 0.01 | 1/1 | ok | - |
| throughput | n256_b4 | 256 | 4 | 1 | cufft_gpu | compute | 0.002765 | 14.81 | 0.002765 | 14.81 | 0.04% | 0.04% | 0.02 | 1/1 | ok | - |
| throughput | n256_b8 | 256 | 8 | 1 | cufft_gpu | compute | 0.002816 | 29.09 | 0.002765 | 29.63 | 0.08% | 0.08% | 0.03 | 1/1 | ok | - |
| throughput | n256_b16 | 256 | 16 | 1 | cufft_gpu | compute | 0.002765 | 59.25 | 0.002714 | 60.37 | 0.16% | 0.16% | 0.06 | 1/1 | ok | - |
| throughput | n256_b32 | 256 | 32 | 1 | cufft_gpu | compute | 0.002765 | 118.51 | 0.002765 | 118.51 | 0.32% | 0.32% | 0.12 | 1/1 | ok | - |
| throughput | n256_b64 | 256 | 64 | 1 | cufft_gpu | compute | 0.002918 | 224.59 | 0.002867 | 228.59 | 0.61% | 0.62% | 0.25 | 1/1 | ok | - |
| throughput | n256_b128 | 256 | 128 | 1 | cufft_gpu | compute | 0.003072 | 426.67 | 0.003021 | 433.87 | 1.16% | 1.18% | 0.50 | 1/1 | ok | - |
| throughput | n256_b256 | 256 | 256 | 1 | cufft_gpu | compute | 0.003277 | 799.95 | 0.003226 | 812.60 | 2.17% | 2.21% | 1.00 | 1/1 | ok | - |
| throughput | n256_b512 | 256 | 512 | 1 | cufft_gpu | compute | 0.003939 | 1331.02 | 0.003883 | 1350.21 | 3.62% | 3.67% | 2.00 | 1/1 | ok | - |
| throughput | n256_b1024 | 256 | 1024 | 1 | cufft_gpu | compute | 0.005120 | 2048.00 | 0.005184 | 2022.72 | 5.56% | 5.49% | 4.00 | 1/1 | ok | - |
| throughput | n256_b2048 | 256 | 2048 | 1 | cufft_gpu | compute | 0.0136 | 1545.66 | 0.0132 | 1587.79 | 4.20% | 4.31% | 8.00 | 1/1 | ok | - |
| throughput | n256_b4096 | 256 | 4096 | 1 | cufft_gpu | compute | 0.0270 | 1554.08 | 0.0266 | 1579.48 | 4.22% | 4.29% | 16.00 | 1/1 | ok | - |
| throughput | n256_b8192 | 256 | 8192 | 1 | cufft_gpu | compute | 0.0514 | 1633.49 | 0.0515 | 1630.00 | 4.44% | 4.43% | 32.00 | 1/1 | ok | - |
| throughput | n256_b16384 | 256 | 16384 | 1 | cufft_gpu | compute | 0.100 | 1671.97 | 0.1000 | 1677.82 | 4.54% | 4.56% | 64.00 | 1/1 | ok | - |
| throughput | n256_b32768 | 256 | 32768 | 1 | cufft_gpu | compute | 0.197 | 1699.15 | 0.198 | 1695.19 | 4.62% | 4.60% | 128.00 | 1/1 | ok | - |
| throughput | n256_b65536 | 256 | 65536 | 1 | cufft_gpu | compute | 0.393 | 1709.76 | 0.392 | 1711.35 | 4.64% | 4.65% | 256.00 | 1/1 | ok | - |
| throughput | n512_b1 | 512 | 1 | 1 | cufft_gpu | compute | 0.003123 | 7.38 | 0.003085 | 7.47 | 0.02% | 0.02% | 0.01 | 1/1 | ok | - |
| throughput | n512_b2 | 512 | 2 | 1 | cufft_gpu | compute | 0.003123 | 14.76 | 0.003123 | 14.76 | 0.04% | 0.04% | 0.02 | 1/1 | ok | - |
| throughput | n512_b4 | 512 | 4 | 1 | cufft_gpu | compute | 0.003219 | 28.63 | 0.003219 | 28.63 | 0.08% | 0.08% | 0.03 | 1/1 | ok | - |
| throughput | n512_b8 | 512 | 8 | 1 | cufft_gpu | compute | 0.003226 | 57.14 | 0.003174 | 58.07 | 0.16% | 0.16% | 0.06 | 1/1 | ok | - |
| throughput | n512_b16 | 512 | 16 | 1 | cufft_gpu | compute | 0.003226 | 114.27 | 0.003174 | 116.14 | 0.31% | 0.32% | 0.12 | 1/1 | ok | - |
| throughput | n512_b32 | 512 | 32 | 1 | cufft_gpu | compute | 0.003226 | 228.54 | 0.003226 | 228.54 | 0.62% | 0.62% | 0.25 | 1/1 | ok | - |
| throughput | n512_b64 | 512 | 64 | 1 | cufft_gpu | compute | 0.003379 | 436.39 | 0.003363 | 438.47 | 1.19% | 1.19% | 0.50 | 1/1 | ok | - |
| throughput | n512_b128 | 512 | 128 | 1 | cufft_gpu | compute | 0.003584 | 822.86 | 0.003533 | 834.74 | 2.23% | 2.27% | 1.00 | 1/1 | ok | - |
| throughput | n512_b256 | 512 | 256 | 1 | cufft_gpu | compute | 0.004355 | 1354.36 | 0.004403 | 1339.60 | 3.68% | 3.64% | 2.00 | 1/1 | ok | - |
| throughput | n512_b512 | 512 | 512 | 1 | cufft_gpu | compute | 0.005632 | 2094.55 | 0.005632 | 2094.55 | 5.69% | 5.69% | 4.00 | 1/1 | ok | - |
| throughput | n512_b1024 | 512 | 1024 | 1 | cufft_gpu | compute | 0.0145 | 1628.22 | 0.0139 | 1700.39 | 4.42% | 4.62% | 8.00 | 1/1 | ok | - |
| throughput | n512_b2048 | 512 | 2048 | 1 | cufft_gpu | compute | 0.0276 | 1709.82 | 0.0274 | 1722.62 | 4.64% | 4.68% | 16.00 | 1/1 | ok | - |
| throughput | n512_b4096 | 512 | 4096 | 1 | cufft_gpu | compute | 0.0520 | 1815.61 | 0.0520 | 1814.18 | 4.93% | 4.93% | 32.00 | 1/1 | ok | - |
| throughput | n512_b8192 | 512 | 8192 | 1 | cufft_gpu | compute | 0.101 | 1865.59 | 0.101 | 1866.53 | 5.07% | 5.07% | 64.00 | 1/1 | ok | - |
| throughput | n512_b16384 | 512 | 16384 | 1 | cufft_gpu | compute | 0.199 | 1900.53 | 0.198 | 1903.64 | 5.16% | 5.17% | 128.00 | 1/1 | ok | - |
| throughput | n512_b32768 | 512 | 32768 | 1 | cufft_gpu | compute | 0.394 | 1917.01 | 0.394 | 1915.51 | 5.21% | 5.20% | 256.00 | 1/1 | ok | - |
| throughput | n512_b65536 | 512 | 65536 | 1 | cufft_gpu | compute | 0.785 | 1924.64 | 0.784 | 1926.15 | 5.23% | 5.23% | 512.00 | 1/1 | ok | - |
| throughput | n1024_b1 | 1024 | 1 | 1 | cufft_gpu | compute | 0.003430 | 14.93 | 0.003427 | 14.94 | 0.04% | 0.04% | 0.02 | 1/1 | ok | - |
| throughput | n1024_b2 | 1024 | 2 | 1 | cufft_gpu | compute | 0.003840 | 26.67 | 0.003840 | 26.67 | 0.07% | 0.07% | 0.03 | 1/1 | ok | - |
| throughput | n1024_b4 | 1024 | 4 | 1 | cufft_gpu | compute | 0.003840 | 53.33 | 0.003840 | 53.33 | 0.14% | 0.14% | 0.06 | 1/1 | ok | - |
| throughput | n1024_b8 | 1024 | 8 | 1 | cufft_gpu | compute | 0.003888 | 105.35 | 0.003891 | 105.27 | 0.29% | 0.29% | 0.12 | 1/1 | ok | - |
| throughput | n1024_b16 | 1024 | 16 | 1 | cufft_gpu | compute | 0.003886 | 210.81 | 0.003883 | 210.97 | 0.57% | 0.57% | 0.25 | 1/1 | ok | - |
| throughput | n1024_b32 | 1024 | 32 | 1 | cufft_gpu | compute | 0.003840 | 426.67 | 0.003840 | 426.67 | 1.16% | 1.16% | 0.50 | 1/1 | ok | - |
| throughput | n1024_b64 | 1024 | 64 | 1 | cufft_gpu | compute | 0.003942 | 831.25 | 0.003893 | 841.72 | 2.26% | 2.29% | 1.00 | 1/1 | ok | - |
| throughput | n1024_b128 | 1024 | 128 | 1 | cufft_gpu | compute | 0.004451 | 1472.39 | 0.004454 | 1471.40 | 4.00% | 4.00% | 2.00 | 1/1 | ok | - |
| throughput | n1024_b256 | 1024 | 256 | 1 | cufft_gpu | compute | 0.005837 | 2245.54 | 0.005786 | 2265.33 | 6.10% | 6.15% | 4.00 | 1/1 | ok | - |
| throughput | n1024_b512 | 1024 | 512 | 1 | cufft_gpu | compute | 0.0151 | 1741.47 | 0.0149 | 1753.47 | 4.73% | 4.76% | 8.00 | 1/1 | ok | - |
| throughput | n1024_b1024 | 1024 | 1024 | 1 | cufft_gpu | compute | 0.0261 | 2007.84 | 0.0259 | 2023.73 | 5.45% | 5.50% | 16.00 | 1/1 | ok | - |
| throughput | n1024_b2048 | 1024 | 2048 | 1 | cufft_gpu | compute | 0.0507 | 2068.69 | 0.0507 | 2066.61 | 5.62% | 5.61% | 32.00 | 1/1 | ok | - |
| throughput | n1024_b4096 | 1024 | 4096 | 1 | cufft_gpu | compute | 0.0999 | 2100.24 | 0.0998 | 2101.59 | 5.70% | 5.71% | 64.00 | 1/1 | ok | - |
| throughput | n1024_b8192 | 1024 | 8192 | 1 | cufft_gpu | compute | 0.198 | 2117.34 | 0.198 | 2119.94 | 5.75% | 5.76% | 128.00 | 1/1 | ok | - |
| throughput | n1024_b16384 | 1024 | 16384 | 1 | cufft_gpu | compute | 0.394 | 2128.13 | 0.394 | 2128.90 | 5.78% | 5.78% | 256.00 | 1/1 | ok | - |
| throughput | n1024_b32768 | 1024 | 32768 | 1 | cufft_gpu | compute | 0.786 | 2134.17 | 0.786 | 2134.45 | 5.80% | 5.80% | 512.00 | 1/1 | ok | - |
| throughput | n1024_b65536 | 1024 | 65536 | 1 | cufft_gpu | compute | 1.570 | 2137.65 | 1.570 | 2137.37 | 5.81% | 5.81% | 1024.00 | 1/1 | ok | - |
| throughput | n2048_b1 | 2048 | 1 | 1 | cufft_gpu | compute | 0.004342 | 25.94 | 0.004347 | 25.91 | 0.07% | 0.07% | 0.03 | 1/1 | ok | - |
| throughput | n2048_b2 | 2048 | 2 | 1 | cufft_gpu | compute | 0.005018 | 44.89 | 0.005016 | 44.91 | 0.12% | 0.12% | 0.06 | 1/1 | ok | - |
| throughput | n2048_b4 | 2048 | 4 | 1 | cufft_gpu | compute | 0.005018 | 89.79 | 0.005018 | 89.79 | 0.24% | 0.24% | 0.12 | 1/1 | ok | - |
| throughput | n2048_b8 | 2048 | 8 | 1 | cufft_gpu | compute | 0.005120 | 176.00 | 0.005120 | 176.00 | 0.48% | 0.48% | 0.25 | 1/1 | ok | - |
| throughput | n2048_b16 | 2048 | 16 | 1 | cufft_gpu | compute | 0.005120 | 352.00 | 0.005160 | 349.27 | 0.96% | 0.95% | 0.50 | 1/1 | ok | - |
| throughput | n2048_b32 | 2048 | 32 | 1 | cufft_gpu | compute | 0.005171 | 697.06 | 0.005213 | 691.44 | 1.89% | 1.88% | 1.00 | 1/1 | ok | - |
| throughput | n2048_b64 | 2048 | 64 | 1 | cufft_gpu | compute | 0.005235 | 1377.07 | 0.005222 | 1380.50 | 3.74% | 3.75% | 2.00 | 1/1 | ok | - |
| throughput | n2048_b128 | 2048 | 128 | 1 | cufft_gpu | compute | 0.006656 | 2166.15 | 0.006656 | 2166.15 | 5.88% | 5.88% | 4.00 | 1/1 | ok | - |
| throughput | n2048_b256 | 2048 | 256 | 1 | cufft_gpu | compute | 0.0167 | 1722.37 | 0.0165 | 1743.61 | 4.68% | 4.74% | 8.00 | 1/1 | ok | - |
| throughput | n2048_b512 | 2048 | 512 | 1 | cufft_gpu | compute | 0.0262 | 2204.32 | 0.0264 | 2183.46 | 5.99% | 5.93% | 16.00 | 1/1 | ok | - |
| throughput | n2048_b1024 | 2048 | 1024 | 1 | cufft_gpu | compute | 0.0509 | 2264.70 | 0.0510 | 2259.60 | 6.15% | 6.14% | 32.00 | 1/1 | ok | - |
| throughput | n2048_b2048 | 2048 | 2048 | 1 | cufft_gpu | compute | 0.0998 | 2311.74 | 0.0998 | 2311.79 | 6.28% | 6.28% | 64.00 | 1/1 | ok | - |
| throughput | n2048_b4096 | 2048 | 4096 | 1 | cufft_gpu | compute | 0.197 | 2336.93 | 0.197 | 2338.14 | 6.35% | 6.35% | 128.00 | 1/1 | ok | - |
| throughput | n2048_b8192 | 2048 | 8192 | 1 | cufft_gpu | compute | 0.393 | 2349.73 | 0.393 | 2348.85 | 6.38% | 6.38% | 256.00 | 1/1 | ok | - |
| throughput | n2048_b16384 | 2048 | 16384 | 1 | cufft_gpu | compute | 0.784 | 2354.95 | 0.784 | 2353.56 | 6.40% | 6.39% | 512.00 | 1/1 | ok | - |
| throughput | n2048_b32768 | 2048 | 32768 | 1 | cufft_gpu | compute | 1.566 | 2357.19 | 1.566 | 2357.18 | 6.40% | 6.40% | 1024.00 | 1/1 | ok | - |
| throughput | n2048_b65536 | 2048 | 65536 | 1 | cufft_gpu | compute | 3.129 | 2358.95 | 3.130 | 2358.23 | 6.41% | 6.41% | 2048.00 | 1/1 | ok | - |
| throughput | n4096_b1 | 4096 | 1 | 1 | cufft_gpu | compute | 0.004813 | 51.06 | 0.004850 | 50.67 | 0.14% | 0.14% | 0.06 | 1/1 | ok | - |
| throughput | n4096_b2 | 4096 | 2 | 1 | cufft_gpu | compute | 0.004864 | 101.05 | 0.004813 | 102.12 | 0.27% | 0.28% | 0.12 | 1/1 | ok | - |
| throughput | n4096_b4 | 4096 | 4 | 1 | cufft_gpu | compute | 0.004966 | 197.95 | 0.004966 | 197.95 | 0.54% | 0.54% | 0.25 | 1/1 | ok | - |
| throughput | n4096_b8 | 4096 | 8 | 1 | cufft_gpu | compute | 0.005008 | 392.59 | 0.004974 | 395.27 | 1.07% | 1.07% | 0.50 | 1/1 | ok | - |
| throughput | n4096_b16 | 4096 | 16 | 1 | cufft_gpu | compute | 0.005011 | 784.71 | 0.004966 | 791.82 | 2.13% | 2.15% | 1.00 | 1/1 | ok | - |
| throughput | n4096_b32 | 4096 | 32 | 1 | cufft_gpu | compute | 0.005120 | 1536.00 | 0.005171 | 1520.85 | 4.17% | 4.13% | 2.00 | 1/1 | ok | - |
| throughput | n4096_b64 | 4096 | 64 | 1 | cufft_gpu | compute | 0.006451 | 2438.17 | 0.006502 | 2419.05 | 6.62% | 6.57% | 4.00 | 1/1 | ok | - |
| throughput | n4096_b128 | 4096 | 128 | 1 | cufft_gpu | compute | 0.0155 | 2034.49 | 0.0152 | 2067.11 | 5.53% | 5.61% | 8.00 | 1/1 | ok | - |
| throughput | n4096_b256 | 4096 | 256 | 1 | cufft_gpu | compute | 0.0270 | 2327.24 | 0.0270 | 2331.72 | 6.32% | 6.33% | 16.00 | 1/1 | ok | - |
| throughput | n4096_b512 | 4096 | 512 | 1 | cufft_gpu | compute | 0.0537 | 2341.01 | 0.0534 | 2356.84 | 6.36% | 6.40% | 32.00 | 1/1 | ok | - |
| throughput | n4096_b1024 | 4096 | 1024 | 1 | cufft_gpu | compute | 0.0993 | 2535.11 | 0.0994 | 2532.31 | 6.89% | 6.88% | 64.00 | 1/1 | ok | - |
| throughput | n4096_b2048 | 4096 | 2048 | 1 | cufft_gpu | compute | 0.197 | 2554.67 | 0.197 | 2559.35 | 6.94% | 6.95% | 128.00 | 1/1 | ok | - |
| throughput | n4096_b4096 | 4096 | 4096 | 1 | cufft_gpu | compute | 0.392 | 2566.02 | 0.392 | 2567.69 | 6.97% | 6.97% | 256.00 | 1/1 | ok | - |
| throughput | n4096_b8192 | 4096 | 8192 | 1 | cufft_gpu | compute | 0.784 | 2569.07 | 0.784 | 2569.56 | 6.98% | 6.98% | 512.00 | 1/1 | ok | - |
| throughput | n4096_b16384 | 4096 | 16384 | 1 | cufft_gpu | compute | 1.566 | 2571.74 | 1.566 | 2571.55 | 6.99% | 6.98% | 1024.00 | 1/1 | ok | - |
| throughput | n4096_b32768 | 4096 | 32768 | 1 | cufft_gpu | compute | 3.130 | 2573.02 | 3.129 | 2573.28 | 6.99% | 6.99% | 2048.00 | 1/1 | ok | - |
| throughput | n4096_b65536 | 4096 | 65536 | 1 | cufft_gpu | compute | 6.256 | 2574.41 | 6.258 | 2573.78 | 6.99% | 6.99% | 4096.00 | 1/1 | ok | - |
| throughput | n8192_b1 | 8192 | 1 | 1 | cufft_gpu | compute | 0.008304 | 64.12 | 0.008346 | 63.80 | 0.17% | 0.17% | 0.12 | 1/1 | ok | - |
| throughput | n8192_b2 | 8192 | 2 | 1 | cufft_gpu | compute | 0.008038 | 132.49 | 0.007834 | 135.94 | 0.36% | 0.37% | 0.25 | 1/1 | ok | - |
| throughput | n8192_b4 | 8192 | 4 | 1 | cufft_gpu | compute | 0.007987 | 266.67 | 0.007936 | 268.39 | 0.72% | 0.73% | 0.50 | 1/1 | ok | - |
| throughput | n8192_b8 | 8192 | 8 | 1 | cufft_gpu | compute | 0.007987 | 533.35 | 0.007936 | 536.77 | 1.45% | 1.46% | 1.00 | 1/1 | ok | - |
| throughput | n8192_b16 | 8192 | 16 | 1 | cufft_gpu | compute | 0.007936 | 1073.55 | 0.007936 | 1073.55 | 2.92% | 2.92% | 2.00 | 1/1 | ok | - |
| throughput | n8192_b32 | 8192 | 32 | 1 | cufft_gpu | compute | 0.007974 | 2136.86 | 0.007893 | 2158.79 | 5.80% | 5.86% | 4.00 | 1/1 | ok | - |
| throughput | n8192_b64 | 8192 | 64 | 1 | cufft_gpu | compute | 0.0176 | 1940.48 | 0.0175 | 1946.24 | 5.27% | 5.29% | 8.00 | 1/1 | ok | - |
| throughput | n8192_b128 | 8192 | 128 | 1 | cufft_gpu | compute | 0.0299 | 2279.97 | 0.0297 | 2295.17 | 6.19% | 6.23% | 16.00 | 1/1 | ok | - |
| throughput | n8192_b256 | 8192 | 256 | 1 | cufft_gpu | compute | 0.0556 | 2449.94 | 0.0560 | 2435.72 | 6.65% | 6.62% | 32.00 | 1/1 | ok | - |
| throughput | n8192_b512 | 8192 | 512 | 1 | cufft_gpu | compute | 0.108 | 2522.04 | 0.108 | 2516.45 | 6.85% | 6.83% | 64.00 | 1/1 | ok | - |
| throughput | n8192_b1024 | 8192 | 1024 | 1 | cufft_gpu | compute | 0.200 | 2721.59 | 0.200 | 2720.20 | 7.39% | 7.39% | 128.00 | 1/1 | ok | - |
| throughput | n8192_b2048 | 8192 | 2048 | 1 | cufft_gpu | compute | 0.396 | 2754.68 | 0.396 | 2750.88 | 7.48% | 7.47% | 256.00 | 1/1 | ok | - |
| throughput | n8192_b4096 | 8192 | 4096 | 1 | cufft_gpu | compute | 0.789 | 2763.81 | 0.788 | 2769.20 | 7.51% | 7.52% | 512.00 | 1/1 | ok | - |
| throughput | n8192_b8192 | 8192 | 8192 | 1 | cufft_gpu | compute | 1.571 | 2776.13 | 1.572 | 2775.53 | 7.54% | 7.54% | 1024.00 | 1/1 | ok | - |
| throughput | n8192_b16384 | 8192 | 16384 | 1 | cufft_gpu | compute | 3.138 | 2780.39 | 3.137 | 2780.62 | 7.55% | 7.55% | 2048.00 | 1/1 | ok | - |
| throughput | n8192_b32768 | 8192 | 32768 | 1 | cufft_gpu | compute | 6.270 | 2782.73 | 6.269 | 2783.19 | 7.56% | 7.56% | 4096.00 | 1/1 | ok | - |
| throughput | n8192_b65536 | 8192 | 65536 | 1 | cufft_gpu | compute | - | - | - | - | - | - | 8192.00 | 0/1 | ok | CUFFT_INTERNAL_ERROR |
| throughput | n16384_b1 | 16384 | 1 | 1 | cufft_gpu | compute | 0.0103 | 110.90 | 0.0103 | 111.54 | 0.30% | 0.30% | 0.25 | 1/1 | ok | - |
| throughput | n16384_b2 | 16384 | 2 | 1 | cufft_gpu | compute | 0.0103 | 221.98 | 0.0103 | 222.89 | 0.60% | 0.61% | 0.50 | 1/1 | ok | - |
| throughput | n16384_b4 | 16384 | 4 | 1 | cufft_gpu | compute | 0.0103 | 445.69 | 0.0103 | 445.78 | 1.21% | 1.21% | 1.00 | 1/1 | ok | - |
| throughput | n16384_b8 | 16384 | 8 | 1 | cufft_gpu | compute | 0.0104 | 882.72 | 0.0104 | 884.00 | 2.40% | 2.40% | 2.00 | 1/1 | ok | - |
| throughput | n16384_b16 | 16384 | 16 | 1 | cufft_gpu | compute | 0.0162 | 1135.17 | 0.0162 | 1134.19 | 3.08% | 3.08% | 4.00 | 1/1 | ok | - |
| throughput | n16384_b32 | 16384 | 32 | 1 | cufft_gpu | compute | 0.0234 | 1565.04 | 0.0236 | 1554.89 | 4.25% | 4.22% | 8.00 | 1/1 | ok | - |
| throughput | n16384_b64 | 16384 | 64 | 1 | cufft_gpu | compute | 0.0373 | 1966.52 | 0.0375 | 1958.49 | 5.34% | 5.32% | 16.00 | 1/1 | ok | - |
| throughput | n16384_b128 | 16384 | 128 | 1 | cufft_gpu | compute | 0.0718 | 2045.09 | 0.0717 | 2046.54 | 5.55% | 5.56% | 32.00 | 1/1 | ok | - |
| throughput | n16384_b256 | 16384 | 256 | 1 | cufft_gpu | compute | 0.133 | 2212.40 | 0.133 | 2199.62 | 6.01% | 5.97% | 64.00 | 1/1 | ok | - |
| throughput | n16384_b512 | 16384 | 512 | 1 | cufft_gpu | compute | 0.235 | 2500.29 | 0.234 | 2505.75 | 6.79% | 6.81% | 128.00 | 1/1 | ok | - |
| throughput | n16384_b1024 | 16384 | 1024 | 1 | cufft_gpu | compute | 0.419 | 2805.93 | 0.420 | 2796.59 | 7.62% | 7.60% | 256.00 | 1/1 | ok | - |
| throughput | n16384_b2048 | 16384 | 2048 | 1 | cufft_gpu | compute | 0.811 | 2897.80 | 0.810 | 2899.84 | 7.87% | 7.88% | 512.00 | 1/1 | ok | - |
| throughput | n16384_b4096 | 16384 | 4096 | 1 | cufft_gpu | compute | 1.598 | 2939.49 | 1.597 | 2942.32 | 7.98% | 7.99% | 1024.00 | 1/1 | ok | - |
| throughput | n16384_b8192 | 16384 | 8192 | 1 | cufft_gpu | compute | 3.173 | 2960.84 | 3.175 | 2959.27 | 8.04% | 8.04% | 2048.00 | 1/1 | ok | - |
| throughput | n16384_b16384 | 16384 | 16384 | 1 | cufft_gpu | compute | 6.326 | 2970.59 | 6.330 | 2968.69 | 8.07% | 8.06% | 4096.00 | 1/1 | ok | - |
| throughput | n16384_b32768 | 16384 | 32768 | 1 | cufft_gpu | compute | - | - | - | - | - | - | 8192.00 | 0/1 | ok | CUFFT_INTERNAL_ERROR |
| throughput | n16384_b65536 | 16384 | 65536 | 1 | cufft_gpu | compute | - | - | - | - | - | - | 16384.00 | 0/1 | ok | memory_limit |
| throughput | n32768_b1 | 32768 | 1 | 1 | cufft_gpu | compute | 0.008290 | 296.45 | 0.008192 | 300.00 | 0.81% | 0.81% | 0.50 | 1/1 | ok | - |
| throughput | n32768_b2 | 32768 | 2 | 1 | cufft_gpu | compute | 0.008243 | 596.29 | 0.008240 | 596.50 | 1.62% | 1.62% | 1.00 | 1/1 | ok | - |
| throughput | n32768_b4 | 32768 | 4 | 1 | cufft_gpu | compute | 0.008699 | 1130.06 | 0.008642 | 1137.51 | 3.07% | 3.09% | 2.00 | 1/1 | ok | - |
| throughput | n32768_b8 | 32768 | 8 | 1 | cufft_gpu | compute | 0.0141 | 1396.36 | 0.0140 | 1399.84 | 3.79% | 3.80% | 4.00 | 1/1 | ok | - |
| throughput | n32768_b16 | 32768 | 16 | 1 | cufft_gpu | compute | 0.0251 | 1564.17 | 0.0251 | 1564.17 | 4.25% | 4.25% | 8.00 | 1/1 | ok | - |
| throughput | n32768_b32 | 32768 | 32 | 1 | cufft_gpu | compute | 0.0571 | 1377.58 | 0.0568 | 1385.03 | 3.74% | 3.76% | 16.00 | 1/1 | ok | - |
| throughput | n32768_b64 | 32768 | 64 | 1 | cufft_gpu | compute | 0.110 | 1429.53 | 0.110 | 1426.84 | 3.88% | 3.88% | 32.00 | 1/1 | ok | - |
| throughput | n32768_b128 | 32768 | 128 | 1 | cufft_gpu | compute | 0.215 | 1462.86 | 0.215 | 1464.95 | 3.97% | 3.98% | 64.00 | 1/1 | ok | - |
| throughput | n32768_b256 | 32768 | 256 | 1 | cufft_gpu | compute | 0.424 | 1482.62 | 0.424 | 1482.27 | 4.03% | 4.03% | 128.00 | 1/1 | ok | - |
| throughput | n32768_b512 | 32768 | 512 | 1 | cufft_gpu | compute | 0.793 | 1585.75 | 0.794 | 1585.44 | 4.31% | 4.31% | 256.00 | 1/1 | ok | - |
| throughput | n32768_b1024 | 32768 | 1024 | 1 | cufft_gpu | compute | 1.581 | 1591.66 | 1.582 | 1591.10 | 4.32% | 4.32% | 512.00 | 1/1 | ok | - |
| throughput | n32768_b2048 | 32768 | 2048 | 1 | cufft_gpu | compute | 3.158 | 1593.70 | 3.158 | 1594.01 | 4.33% | 4.33% | 1024.00 | 1/1 | ok | - |
| throughput | n32768_b4096 | 32768 | 4096 | 1 | cufft_gpu | compute | 6.312 | 1594.72 | 6.307 | 1596.13 | 4.33% | 4.34% | 2048.00 | 1/1 | ok | - |
| throughput | n32768_b8192 | 32768 | 8192 | 1 | cufft_gpu | compute | 12.617 | 1595.63 | 12.596 | 1598.39 | 4.33% | 4.34% | 4096.00 | 1/1 | ok | - |
| throughput | n32768_b16384 | 32768 | 16384 | 1 | cufft_gpu | compute | - | - | - | - | - | - | 8192.00 | 0/1 | ok | CUFFT_INTERNAL_ERROR |
| throughput | n32768_b32768 | 32768 | 32768 | 1 | cufft_gpu | compute | - | - | - | - | - | - | 16384.00 | 0/1 | ok | memory_limit |
| throughput | n32768_b65536 | 32768 | 65536 | 1 | cufft_gpu | compute | - | - | - | - | - | - | 32768.00 | 0/1 | ok | memory_limit |
| throughput | n65536_b1 | 65536 | 1 | 1 | cufft_gpu | compute | 0.007619 | 688.13 | 0.007534 | 695.90 | 1.87% | 1.89% | 1.00 | 1/1 | ok | - |
| throughput | n65536_b2 | 65536 | 2 | 1 | cufft_gpu | compute | 0.008602 | 1218.99 | 0.008550 | 1226.40 | 3.31% | 3.33% | 2.00 | 1/1 | ok | - |
| throughput | n65536_b4 | 65536 | 4 | 1 | cufft_gpu | compute | 0.0134 | 1569.37 | 0.0134 | 1564.46 | 4.26% | 4.25% | 4.00 | 1/1 | ok | - |
| throughput | n65536_b8 | 65536 | 8 | 1 | cufft_gpu | compute | 0.0241 | 1742.98 | 0.0239 | 1754.20 | 4.73% | 4.76% | 8.00 | 1/1 | ok | - |
| throughput | n65536_b16 | 65536 | 16 | 1 | cufft_gpu | compute | 0.0574 | 1462.65 | 0.0571 | 1468.11 | 3.97% | 3.99% | 16.00 | 1/1 | ok | - |
| throughput | n65536_b32 | 65536 | 32 | 1 | cufft_gpu | compute | 0.110 | 1521.36 | 0.110 | 1526.94 | 4.13% | 4.15% | 32.00 | 1/1 | ok | - |
| throughput | n65536_b64 | 65536 | 64 | 1 | cufft_gpu | compute | 0.215 | 1562.59 | 0.215 | 1561.50 | 4.24% | 4.24% | 64.00 | 1/1 | ok | - |
| throughput | n65536_b128 | 65536 | 128 | 1 | cufft_gpu | compute | 0.426 | 1576.71 | 0.426 | 1576.93 | 4.28% | 4.28% | 128.00 | 1/1 | ok | - |
| throughput | n65536_b256 | 65536 | 256 | 1 | cufft_gpu | compute | 0.790 | 1699.92 | 0.790 | 1700.03 | 4.62% | 4.62% | 256.00 | 1/1 | ok | - |
| throughput | n65536_b512 | 65536 | 512 | 1 | cufft_gpu | compute | 1.578 | 1701.24 | 1.577 | 1702.34 | 4.62% | 4.62% | 512.00 | 1/1 | ok | - |
| throughput | n65536_b1024 | 65536 | 1024 | 1 | cufft_gpu | compute | 3.149 | 1704.93 | 3.149 | 1704.89 | 4.63% | 4.63% | 1024.00 | 1/1 | ok | - |
| throughput | n65536_b2048 | 65536 | 2048 | 1 | cufft_gpu | compute | 6.291 | 1706.71 | 6.281 | 1709.62 | 4.64% | 4.64% | 2048.00 | 1/1 | ok | - |
| throughput | n65536_b4096 | 65536 | 4096 | 1 | cufft_gpu | compute | 12.578 | 1707.34 | 12.554 | 1710.57 | 4.64% | 4.65% | 4096.00 | 1/1 | ok | - |
| throughput | n65536_b8192 | 65536 | 8192 | 1 | cufft_gpu | compute | - | - | - | - | - | - | 8192.00 | 0/1 | ok | CUFFT_INTERNAL_ERROR |
| throughput | n65536_b16384 | 65536 | 16384 | 1 | cufft_gpu | compute | - | - | - | - | - | - | 16384.00 | 0/1 | ok | memory_limit |
| throughput | n65536_b32768 | 65536 | 32768 | 1 | cufft_gpu | compute | - | - | - | - | - | - | 32768.00 | 0/1 | ok | memory_limit |
| throughput | n65536_b65536 | 65536 | 65536 | 1 | cufft_gpu | compute | - | - | - | - | - | - | 65536.00 | 0/1 | ok | memory_limit |
| throughput | n131072_b1 | 131072 | 1 | 1 | cufft_gpu | compute | 0.009626 | 1157.40 | 0.009574 | 1163.68 | 3.14% | 3.16% | 2.00 | 1/1 | ok | - |
| throughput | n131072_b2 | 131072 | 2 | 1 | cufft_gpu | compute | 0.0146 | 1527.02 | 0.0144 | 1543.31 | 4.15% | 4.19% | 4.00 | 1/1 | ok | - |
| throughput | n131072_b4 | 131072 | 4 | 1 | cufft_gpu | compute | 0.0250 | 1783.58 | 0.0250 | 1779.94 | 4.84% | 4.83% | 8.00 | 1/1 | ok | - |
| throughput | n131072_b8 | 131072 | 8 | 1 | cufft_gpu | compute | 0.0570 | 1562.65 | 0.0564 | 1579.68 | 4.24% | 4.29% | 16.00 | 1/1 | ok | - |
| throughput | n131072_b16 | 131072 | 16 | 1 | cufft_gpu | compute | 0.112 | 1595.61 | 0.111 | 1600.74 | 4.33% | 4.35% | 32.00 | 1/1 | ok | - |
| throughput | n131072_b32 | 131072 | 32 | 1 | cufft_gpu | compute | 0.215 | 1655.15 | 0.215 | 1657.90 | 4.50% | 4.50% | 64.00 | 1/1 | ok | - |
| throughput | n131072_b64 | 131072 | 64 | 1 | cufft_gpu | compute | 0.423 | 1683.81 | 0.423 | 1684.17 | 4.57% | 4.57% | 128.00 | 1/1 | ok | - |
| throughput | n131072_b128 | 131072 | 128 | 1 | cufft_gpu | compute | 0.790 | 1805.22 | 0.790 | 1805.70 | 4.90% | 4.90% | 256.00 | 1/1 | ok | - |
| throughput | n131072_b256 | 131072 | 256 | 1 | cufft_gpu | compute | 1.573 | 1813.27 | 1.573 | 1813.10 | 4.92% | 4.92% | 512.00 | 1/1 | ok | - |
| throughput | n131072_b512 | 131072 | 512 | 1 | cufft_gpu | compute | 3.137 | 1818.16 | 3.139 | 1817.50 | 4.94% | 4.94% | 1024.00 | 1/1 | ok | - |
| throughput | n131072_b1024 | 131072 | 1024 | 1 | cufft_gpu | compute | 6.288 | 1814.28 | 6.269 | 1819.79 | 4.93% | 4.94% | 2048.00 | 1/1 | ok | - |
| throughput | n131072_b2048 | 131072 | 2048 | 1 | cufft_gpu | compute | 12.556 | 1817.28 | 12.517 | 1822.95 | 4.94% | 4.95% | 4096.00 | 1/1 | ok | - |
| throughput | n131072_b4096 | 131072 | 4096 | 1 | cufft_gpu | compute | - | - | - | - | - | - | 8192.00 | 0/1 | ok | CUFFT_INTERNAL_ERROR |
| throughput | n131072_b8192 | 131072 | 8192 | 1 | cufft_gpu | compute | - | - | - | - | - | - | 16384.00 | 0/1 | ok | memory_limit |
| throughput | n131072_b16384 | 131072 | 16384 | 1 | cufft_gpu | compute | - | - | - | - | - | - | 32768.00 | 0/1 | ok | memory_limit |
| throughput | n131072_b32768 | 131072 | 32768 | 1 | cufft_gpu | compute | - | - | - | - | - | - | 65536.00 | 0/1 | ok | memory_limit |
| throughput | n131072_b65536 | 131072 | 65536 | 1 | cufft_gpu | compute | - | - | - | - | - | - | 131072.00 | 0/1 | ok | memory_limit |
| throughput | n262144_b1 | 262144 | 1 | 1 | cufft_gpu | compute | 0.0161 | 1467.50 | 0.0157 | 1501.02 | 3.99% | 4.08% | 4.00 | 1/1 | ok | - |
| throughput | n262144_b2 | 262144 | 2 | 1 | cufft_gpu | compute | 0.0256 | 1843.20 | 0.0255 | 1850.57 | 5.01% | 5.03% | 8.00 | 1/1 | ok | - |
| throughput | n262144_b4 | 262144 | 4 | 1 | cufft_gpu | compute | 0.0574 | 1644.62 | 0.0573 | 1645.71 | 4.47% | 4.47% | 16.00 | 1/1 | ok | - |
| throughput | n262144_b8 | 262144 | 8 | 1 | cufft_gpu | compute | 0.114 | 1660.54 | 0.113 | 1669.56 | 4.51% | 4.53% | 32.00 | 1/1 | ok | - |
| throughput | n262144_b16 | 262144 | 16 | 1 | cufft_gpu | compute | 0.218 | 1733.25 | 0.218 | 1733.55 | 4.71% | 4.71% | 64.00 | 1/1 | ok | - |
| throughput | n262144_b32 | 262144 | 32 | 1 | cufft_gpu | compute | 0.427 | 1766.58 | 0.427 | 1768.51 | 4.80% | 4.80% | 128.00 | 1/1 | ok | - |
| throughput | n262144_b64 | 262144 | 64 | 1 | cufft_gpu | compute | 0.796 | 1896.42 | 0.795 | 1898.49 | 5.15% | 5.16% | 256.00 | 1/1 | ok | - |
| throughput | n262144_b128 | 262144 | 128 | 1 | cufft_gpu | compute | 1.585 | 1905.49 | 1.585 | 1905.01 | 5.18% | 5.17% | 512.00 | 1/1 | ok | - |
| throughput | n262144_b256 | 262144 | 256 | 1 | cufft_gpu | compute | 3.160 | 1911.17 | 3.163 | 1909.59 | 5.19% | 5.19% | 1024.00 | 1/1 | ok | - |
| throughput | n262144_b512 | 262144 | 512 | 1 | cufft_gpu | compute | 6.317 | 1912.35 | 6.316 | 1912.42 | 5.19% | 5.19% | 2048.00 | 1/1 | ok | - |
| throughput | n262144_b1024 | 262144 | 1024 | 1 | cufft_gpu | compute | 12.622 | 1914.10 | 12.606 | 1916.46 | 5.20% | 5.21% | 4096.00 | 1/1 | ok | - |
| throughput | n262144_b2048 | 262144 | 2048 | 1 | cufft_gpu | compute | - | - | - | - | - | - | 8192.00 | 0/1 | ok | CUFFT_INTERNAL_ERROR |
| throughput | n262144_b4096 | 262144 | 4096 | 1 | cufft_gpu | compute | - | - | - | - | - | - | 16384.00 | 0/1 | ok | memory_limit |
| throughput | n262144_b8192 | 262144 | 8192 | 1 | cufft_gpu | compute | - | - | - | - | - | - | 32768.00 | 0/1 | ok | memory_limit |
| throughput | n262144_b16384 | 262144 | 16384 | 1 | cufft_gpu | compute | - | - | - | - | - | - | 65536.00 | 0/1 | ok | memory_limit |
| throughput | n262144_b32768 | 262144 | 32768 | 1 | cufft_gpu | compute | - | - | - | - | - | - | 131072.00 | 0/1 | ok | memory_limit |
| throughput | n262144_b65536 | 262144 | 65536 | 1 | cufft_gpu | compute | - | - | - | - | - | - | 262144.00 | 0/1 | ok | memory_limit |
| throughput | n524288_b1 | 524288 | 1 | 1 | cufft_gpu | compute | 0.0275 | 1808.94 | 0.0274 | 1814.94 | 4.91% | 4.93% | 8.00 | 1/1 | ok | - |
| throughput | n524288_b2 | 524288 | 2 | 1 | cufft_gpu | compute | 0.0598 | 1666.02 | 0.0603 | 1651.60 | 4.53% | 4.49% | 16.00 | 1/1 | ok | - |
| throughput | n524288_b4 | 524288 | 4 | 1 | cufft_gpu | compute | 0.119 | 1679.59 | 0.118 | 1687.43 | 4.56% | 4.58% | 32.00 | 1/1 | ok | - |
| throughput | n524288_b8 | 524288 | 8 | 1 | cufft_gpu | compute | 0.223 | 1786.68 | 0.223 | 1788.29 | 4.85% | 4.86% | 64.00 | 1/1 | ok | - |
| throughput | n524288_b16 | 524288 | 16 | 1 | cufft_gpu | compute | 0.433 | 1840.04 | 0.433 | 1839.38 | 5.00% | 5.00% | 128.00 | 1/1 | ok | - |
| throughput | n524288_b32 | 524288 | 32 | 1 | cufft_gpu | compute | 0.802 | 1988.48 | 0.802 | 1988.09 | 5.40% | 5.40% | 256.00 | 1/1 | ok | - |
| throughput | n524288_b64 | 524288 | 64 | 1 | cufft_gpu | compute | 1.590 | 2004.55 | 1.590 | 2004.74 | 5.44% | 5.45% | 512.00 | 1/1 | ok | - |
| throughput | n524288_b128 | 524288 | 128 | 1 | cufft_gpu | compute | 3.167 | 2012.84 | 3.167 | 2013.24 | 5.47% | 5.47% | 1024.00 | 1/1 | ok | - |
| throughput | n524288_b256 | 524288 | 256 | 1 | cufft_gpu | compute | 6.320 | 2017.36 | 6.320 | 2017.59 | 5.48% | 5.48% | 2048.00 | 1/1 | ok | - |
| throughput | n524288_b512 | 524288 | 512 | 1 | cufft_gpu | compute | 12.627 | 2019.66 | 12.621 | 2020.48 | 5.49% | 5.49% | 4096.00 | 1/1 | ok | - |
| throughput | n524288_b1024 | 524288 | 1024 | 1 | cufft_gpu | compute | - | - | - | - | - | - | 8192.00 | 0/1 | ok | CUFFT_INTERNAL_ERROR |
| throughput | n524288_b2048 | 524288 | 2048 | 1 | cufft_gpu | compute | - | - | - | - | - | - | 16384.00 | 0/1 | ok | memory_limit |
| throughput | n524288_b4096 | 524288 | 4096 | 1 | cufft_gpu | compute | - | - | - | - | - | - | 32768.00 | 0/1 | ok | memory_limit |
| throughput | n524288_b8192 | 524288 | 8192 | 1 | cufft_gpu | compute | - | - | - | - | - | - | 65536.00 | 0/1 | ok | memory_limit |
| throughput | n524288_b16384 | 524288 | 16384 | 1 | cufft_gpu | compute | - | - | - | - | - | - | 131072.00 | 0/1 | ok | memory_limit |
| throughput | n524288_b32768 | 524288 | 32768 | 1 | cufft_gpu | compute | - | - | - | - | - | - | 262144.00 | 0/1 | ok | memory_limit |
| throughput | n524288_b65536 | 524288 | 65536 | 1 | cufft_gpu | compute | - | - | - | - | - | - | 524288.00 | 0/1 | ok | memory_limit |
| throughput | n1048576_b1 | 1048576 | 1 | 1 | cufft_gpu | compute | 0.0640 | 1638.66 | 0.0638 | 1642.35 | 4.45% | 4.46% | 16.00 | 1/1 | ok | - |
| throughput | n1048576_b2 | 1048576 | 2 | 1 | cufft_gpu | compute | 0.125 | 1680.76 | 0.124 | 1690.46 | 4.57% | 4.59% | 32.00 | 1/1 | ok | - |
| throughput | n1048576_b4 | 1048576 | 4 | 1 | cufft_gpu | compute | 0.231 | 1812.41 | 0.234 | 1795.31 | 4.92% | 4.88% | 64.00 | 1/1 | ok | - |
| throughput | n1048576_b8 | 1048576 | 8 | 1 | cufft_gpu | compute | 0.442 | 1896.54 | 0.442 | 1897.84 | 5.15% | 5.15% | 128.00 | 1/1 | ok | - |
| throughput | n1048576_b16 | 1048576 | 16 | 1 | cufft_gpu | compute | 0.817 | 2054.42 | 0.817 | 2054.55 | 5.58% | 5.58% | 256.00 | 1/1 | ok | - |
| throughput | n1048576_b32 | 1048576 | 32 | 1 | cufft_gpu | compute | 1.611 | 2082.77 | 1.607 | 2087.60 | 5.66% | 5.67% | 512.00 | 1/1 | ok | - |
| throughput | n1048576_b64 | 1048576 | 64 | 1 | cufft_gpu | compute | 3.191 | 2103.28 | 3.191 | 2103.24 | 5.71% | 5.71% | 1024.00 | 1/1 | ok | - |
| throughput | n1048576_b128 | 1048576 | 128 | 1 | cufft_gpu | compute | 6.352 | 2112.97 | 6.352 | 2113.01 | 5.74% | 5.74% | 2048.00 | 1/1 | ok | - |
| throughput | n1048576_b256 | 1048576 | 256 | 1 | cufft_gpu | compute | 12.681 | 2116.89 | 12.628 | 2125.69 | 5.75% | 5.77% | 4096.00 | 1/1 | ok | - |
| throughput | n1048576_b512 | 1048576 | 512 | 1 | cufft_gpu | compute | - | - | - | - | - | - | 8192.00 | 0/1 | ok | CUFFT_INTERNAL_ERROR |
| throughput | n1048576_b1024 | 1048576 | 1024 | 1 | cufft_gpu | compute | - | - | - | - | - | - | 16384.00 | 0/1 | ok | memory_limit |
| throughput | n1048576_b2048 | 1048576 | 2048 | 1 | cufft_gpu | compute | - | - | - | - | - | - | 32768.00 | 0/1 | ok | memory_limit |
| throughput | n1048576_b4096 | 1048576 | 4096 | 1 | cufft_gpu | compute | - | - | - | - | - | - | 65536.00 | 0/1 | ok | memory_limit |
| throughput | n1048576_b8192 | 1048576 | 8192 | 1 | cufft_gpu | compute | - | - | - | - | - | - | 131072.00 | 0/1 | ok | memory_limit |
| throughput | n1048576_b16384 | 1048576 | 16384 | 1 | cufft_gpu | compute | - | - | - | - | - | - | 262144.00 | 0/1 | ok | memory_limit |
| throughput | n1048576_b32768 | 1048576 | 32768 | 1 | cufft_gpu | compute | - | - | - | - | - | - | 524288.00 | 0/1 | ok | memory_limit |
| throughput | n1048576_b65536 | 1048576 | 65536 | 1 | cufft_gpu | compute | - | - | - | - | - | - | 1048576.00 | 0/1 | ok | memory_limit |
| throughput | n2097152_b1 | 2097152 | 1 | 1 | cufft_gpu | compute | 0.127 | 1733.50 | 0.127 | 1728.61 | 4.71% | 4.70% | 32.00 | 1/1 | ok | - |
| throughput | n2097152_b2 | 2097152 | 2 | 1 | cufft_gpu | compute | 0.237 | 1860.21 | 0.238 | 1849.45 | 5.05% | 5.02% | 64.00 | 1/1 | ok | - |
| throughput | n2097152_b4 | 2097152 | 4 | 1 | cufft_gpu | compute | 0.454 | 1939.26 | 0.454 | 1939.26 | 5.27% | 5.27% | 128.00 | 1/1 | ok | - |
| throughput | n2097152_b8 | 2097152 | 8 | 1 | cufft_gpu | compute | 0.838 | 2101.55 | 0.840 | 2096.67 | 5.71% | 5.69% | 256.00 | 1/1 | ok | - |
| throughput | n2097152_b16 | 2097152 | 16 | 1 | cufft_gpu | compute | 1.650 | 2135.79 | 1.649 | 2136.40 | 5.80% | 5.80% | 512.00 | 1/1 | ok | - |
| throughput | n2097152_b32 | 2097152 | 32 | 1 | cufft_gpu | compute | 3.281 | 2147.72 | 3.279 | 2149.19 | 5.83% | 5.84% | 1024.00 | 1/1 | ok | - |
| throughput | n2097152_b64 | 2097152 | 64 | 1 | cufft_gpu | compute | 6.528 | 2158.99 | 6.528 | 2158.94 | 5.86% | 5.86% | 2048.00 | 1/1 | ok | - |
| throughput | n2097152_b128 | 2097152 | 128 | 1 | cufft_gpu | compute | 13.027 | 2163.59 | 13.022 | 2164.48 | 5.88% | 5.88% | 4096.00 | 1/1 | ok | - |
| throughput | n2097152_b256 | 2097152 | 256 | 1 | cufft_gpu | compute | - | - | - | - | - | - | 8192.00 | 0/1 | ok | CUFFT_INTERNAL_ERROR |
| throughput | n2097152_b512 | 2097152 | 512 | 1 | cufft_gpu | compute | - | - | - | - | - | - | 16384.00 | 0/1 | ok | memory_limit |
| throughput | n2097152_b1024 | 2097152 | 1024 | 1 | cufft_gpu | compute | - | - | - | - | - | - | 32768.00 | 0/1 | ok | memory_limit |
| throughput | n2097152_b2048 | 2097152 | 2048 | 1 | cufft_gpu | compute | - | - | - | - | - | - | 65536.00 | 0/1 | ok | memory_limit |
| throughput | n2097152_b4096 | 2097152 | 4096 | 1 | cufft_gpu | compute | - | - | - | - | - | - | 131072.00 | 0/1 | ok | memory_limit |
| throughput | n2097152_b8192 | 2097152 | 8192 | 1 | cufft_gpu | compute | - | - | - | - | - | - | 262144.00 | 0/1 | ok | memory_limit |
| throughput | n2097152_b16384 | 2097152 | 16384 | 1 | cufft_gpu | compute | - | - | - | - | - | - | 524288.00 | 0/1 | ok | memory_limit |
| throughput | n2097152_b32768 | 2097152 | 32768 | 1 | cufft_gpu | compute | - | - | - | - | - | - | 1048576.00 | 0/1 | ok | memory_limit |
| throughput | n2097152_b65536 | 2097152 | 65536 | 1 | cufft_gpu | compute | - | - | - | - | - | - | 2097152.00 | 0/1 | ok | memory_limit |
| throughput | n4194304_b1 | 4194304 | 1 | 1 | cufft_gpu | compute | 0.261 | 1769.76 | 0.260 | 1777.71 | 4.81% | 4.83% | 64.00 | 1/1 | ok | - |
| throughput | n4194304_b2 | 4194304 | 2 | 1 | cufft_gpu | compute | 0.510 | 1809.48 | 0.511 | 1806.22 | 4.91% | 4.91% | 128.00 | 1/1 | ok | - |
| throughput | n4194304_b4 | 4194304 | 4 | 1 | cufft_gpu | compute | 0.950 | 1943.43 | 0.949 | 1943.66 | 5.28% | 5.28% | 256.00 | 1/1 | ok | - |
| throughput | n4194304_b8 | 4194304 | 8 | 1 | cufft_gpu | compute | 1.879 | 1963.88 | 1.878 | 1965.42 | 5.33% | 5.34% | 512.00 | 1/1 | ok | - |
| throughput | n4194304_b16 | 4194304 | 16 | 1 | cufft_gpu | compute | 3.722 | 1983.43 | 3.727 | 1980.86 | 5.39% | 5.38% | 1024.00 | 1/1 | ok | - |
| throughput | n4194304_b32 | 4194304 | 32 | 1 | cufft_gpu | compute | 7.438 | 1984.89 | 7.379 | 2000.72 | 5.39% | 5.43% | 2048.00 | 1/1 | ok | - |
| throughput | n4194304_b64 | 4194304 | 64 | 1 | cufft_gpu | compute | 14.781 | 1997.65 | 14.564 | 2027.45 | 5.43% | 5.51% | 4096.00 | 1/1 | ok | - |
| throughput | n4194304_b128 | 4194304 | 128 | 1 | cufft_gpu | compute | - | - | - | - | - | - | 8192.00 | 0/1 | ok | CUFFT_INTERNAL_ERROR |
| throughput | n4194304_b256 | 4194304 | 256 | 1 | cufft_gpu | compute | - | - | - | - | - | - | 16384.00 | 0/1 | ok | memory_limit |
| throughput | n4194304_b512 | 4194304 | 512 | 1 | cufft_gpu | compute | - | - | - | - | - | - | 32768.00 | 0/1 | ok | memory_limit |
| throughput | n4194304_b1024 | 4194304 | 1024 | 1 | cufft_gpu | compute | - | - | - | - | - | - | 65536.00 | 0/1 | ok | memory_limit |
| throughput | n4194304_b2048 | 4194304 | 2048 | 1 | cufft_gpu | compute | - | - | - | - | - | - | 131072.00 | 0/1 | ok | memory_limit |
| throughput | n4194304_b4096 | 4194304 | 4096 | 1 | cufft_gpu | compute | - | - | - | - | - | - | 262144.00 | 0/1 | ok | memory_limit |
| throughput | n4194304_b8192 | 4194304 | 8192 | 1 | cufft_gpu | compute | - | - | - | - | - | - | 524288.00 | 0/1 | ok | memory_limit |
| throughput | n4194304_b16384 | 4194304 | 16384 | 1 | cufft_gpu | compute | - | - | - | - | - | - | 1048576.00 | 0/1 | ok | memory_limit |
| throughput | n4194304_b32768 | 4194304 | 32768 | 1 | cufft_gpu | compute | - | - | - | - | - | - | 2097152.00 | 0/1 | ok | memory_limit |
| throughput | n4194304_b65536 | 4194304 | 65536 | 1 | cufft_gpu | compute | - | - | - | - | - | - | 4194304.00 | 0/1 | ok | memory_limit |

- CSV: `/home/nikhil/workspace/xeon-fft-bench/src/gpu/latest_run/64k_batch/20260225_144327/latest_run_avg.csv`