# run_gpu_cache_noreuse (3-run average)

- Generated at: 2026-03-13 12:21:34.602448
- Manifest: `/home/nikhil/workspace/xeon-fft-bench/src/gpu/runs/run_gpu_cache_noreuse/20260313_121932/manifest.tsv`
- Runs combined: 3

## GPU Hardware

- GPU: NVIDIA GeForce RTX 3080
- Driver version: 580.126.09
- Compute capability: 8.6
- SM count: 68
- CUDA cores/SM: 128
- Total CUDA cores: 8704
- Warp size: 32
- Max threads/SM: 1536
- Max threads/block: 1024
- Max resident threads on device: 104448
- Global memory: 9872.4 MB

## Peak Model

- SP peak formula: `cuda_cores * 2 FLOP/cycle * max_sm_clock_ghz`
- Max SM clock from nvidia-smi: 2115 MHz
- Peak denominator for %peak: 36817.92 GFLOPS

## Run Config

- `BENCH_MAX_ADAPT_ITERS` = `100000000`
- `BENCH_MAX_MEM_MB` = `8192`
- `BENCH_MIN_TOTAL_MS` = `50`
- `BENCH_NRUNS` = `20`
- `BENCH_STREAM_MAX_SLOTS` = `262144`
- `BENCH_STREAM_MIN_SLOTS` = `2`
- `BENCH_STREAM_MODE` = `1`
- `BENCH_STREAM_TARGET_MB` = `128`
- `BENCH_VALIDATE` = `1`
- `BENCH_VALIDATE_STRICT` = `1`
- `BENCH_VALIDATE_TOL` = `1e-4`
- `BENCH_WARMUP` = `5`
- `THROUGHPUT_BATCHES` = `1,10,16,150,256,1024`
- `THROUGHPUT_LENGTHS` = `2,4,8,16,32,64,128,256,512,1024,2048,4096,8192,16384,32768,65536`

## Run Files

| Run | Log | Report |
|---|---|---|
| run01 | `/home/nikhil/workspace/xeon-fft-bench/src/gpu/runs/run_gpu_cache_noreuse/20260313_121932/runs/run01/fft_benchmark_gpu_20260313_121933.log` | `/home/nikhil/workspace/xeon-fft-bench/src/gpu/runs/run_gpu_cache_noreuse/20260313_121932/runs/run01/fft_benchmark_gpu_20260313_121933.report.md` |
| run02 | `/home/nikhil/workspace/xeon-fft-bench/src/gpu/runs/run_gpu_cache_noreuse/20260313_121932/runs/run02/fft_benchmark_gpu_20260313_122012.log` | `/home/nikhil/workspace/xeon-fft-bench/src/gpu/runs/run_gpu_cache_noreuse/20260313_121932/runs/run02/fft_benchmark_gpu_20260313_122012.report.md` |
| run03 | `/home/nikhil/workspace/xeon-fft-bench/src/gpu/runs/run_gpu_cache_noreuse/20260313_121932/runs/run03/fft_benchmark_gpu_20260313_122052.log` | `/home/nikhil/workspace/xeon-fft-bench/src/gpu/runs/run_gpu_cache_noreuse/20260313_121932/runs/run03/fft_benchmark_gpu_20260313_122052.report.md` |

## Scenario Catalog

| Profile | Description | Workload | Library | Family |
|---|---|---|---|---|
| gpu_cache_noreuse | cuFFT cache-no-reuse (streaming slot rotation on device memory) | throughput | CUDA_CUFFT | run_gpu_cache_noreuse |

## Summary Stats

- Rows aggregated: 96
- Quality counts: {'ok': 96}
- Best forward: `n16384_b1024` = 2792.43 GFLOPS (7.58%)
- Best backward: `n16384_b1024` = 2798.67 GFLOPS (7.60%)

## Averaged Results

| Workload | Case | N | Batch | ThreadsField | Profile | Avg Fwd ms | Avg Fwd SP GFLOPS | Avg Bwd ms | Avg Bwd SP GFLOPS | Fwd % Peak | Bwd % Peak | Avg Mem MB | Avg Slots | Avg Work MB | Samples | Checks | Quality | Note |
|---|---|---:|---:|---:|---|---:|---:|---:|---:|---:|---:|---:|---:|---:|---|---|---|---|
| throughput | n2_b1 | 2 | 1 | 1 | gpu_cache_noreuse | 0.001824 | 0.01 | 0.001800 | 0.01 | 0.00% | 0.00% | 8.00 | 262144.0 | 0.00 | 3/3 (skip:0) | 3/3 | ok | - |
| throughput | n2_b10 | 2 | 10 | 1 | gpu_cache_noreuse | 0.001988 | 0.05 | 0.001919 | 0.05 | 0.00% | 0.00% | 80.00 | 262144.0 | 0.00 | 3/3 (skip:0) | 3/3 | ok | - |
| throughput | n2_b16 | 2 | 16 | 1 | gpu_cache_noreuse | 0.001989 | 0.08 | 0.001907 | 0.08 | 0.00% | 0.00% | 128.00 | 262144.0 | 0.00 | 3/3 (skip:0) | 3/3 | ok | - |
| throughput | n2_b150 | 2 | 150 | 1 | gpu_cache_noreuse | 0.002028 | 0.74 | 0.001993 | 0.75 | 0.00% | 0.00% | 128.01 | 27963.0 | 0.00 | 3/3 (skip:0) | 3/3 | ok | - |
| throughput | n2_b256 | 2 | 256 | 1 | gpu_cache_noreuse | 0.002043 | 1.25 | 0.001959 | 1.31 | 0.00% | 0.00% | 128.01 | 16384.0 | 0.00 | 3/3 (skip:0) | 3/3 | ok | - |
| throughput | n2_b1024 | 2 | 1024 | 1 | gpu_cache_noreuse | 0.001953 | 5.24 | 0.001925 | 5.32 | 0.01% | 0.01% | 128.03 | 4096.0 | 0.02 | 3/3 (skip:0) | 3/3 | ok | - |
| throughput | n4_b1 | 4 | 1 | 1 | gpu_cache_noreuse | 0.001933 | 0.02 | 0.001801 | 0.02 | 0.00% | 0.00% | 16.00 | 262144.0 | 0.00 | 3/3 (skip:0) | 3/3 | ok | - |
| throughput | n4_b10 | 4 | 10 | 1 | gpu_cache_noreuse | 0.002163 | 0.18 | 0.002163 | 0.18 | 0.00% | 0.00% | 128.00 | 209716.0 | 0.00 | 3/3 (skip:0) | 3/3 | ok | - |
| throughput | n4_b16 | 4 | 16 | 1 | gpu_cache_noreuse | 0.002163 | 0.30 | 0.002142 | 0.30 | 0.00% | 0.00% | 128.00 | 131072.0 | 0.00 | 3/3 (skip:0) | 3/3 | ok | - |
| throughput | n4_b150 | 4 | 150 | 1 | gpu_cache_noreuse | 0.002323 | 2.58 | 0.002185 | 2.75 | 0.01% | 0.01% | 128.02 | 13982.0 | 0.00 | 3/3 (skip:0) | 3/3 | ok | - |
| throughput | n4_b256 | 4 | 256 | 1 | gpu_cache_noreuse | 0.002167 | 4.73 | 0.002149 | 4.77 | 0.01% | 0.01% | 128.02 | 8192.0 | 0.01 | 3/3 (skip:0) | 3/3 | ok | - |
| throughput | n4_b1024 | 4 | 1024 | 1 | gpu_cache_noreuse | 0.002236 | 18.32 | 0.002198 | 18.64 | 0.05% | 0.05% | 128.06 | 2048.0 | 0.03 | 3/3 (skip:0) | 3/3 | ok | - |
| throughput | n8_b1 | 8 | 1 | 1 | gpu_cache_noreuse | 0.001975 | 0.06 | 0.001899 | 0.06 | 0.00% | 0.00% | 32.00 | 262144.0 | 0.00 | 3/3 (skip:0) | 3/3 | ok | - |
| throughput | n8_b10 | 8 | 10 | 1 | gpu_cache_noreuse | 0.002296 | 0.52 | 0.002217 | 0.54 | 0.00% | 0.00% | 128.00 | 104858.0 | 0.00 | 3/3 (skip:0) | 3/3 | ok | - |
| throughput | n8_b16 | 8 | 16 | 1 | gpu_cache_noreuse | 0.002327 | 0.82 | 0.002275 | 0.84 | 0.00% | 0.00% | 128.00 | 65536.0 | 0.00 | 3/3 (skip:0) | 3/3 | ok | - |
| throughput | n8_b150 | 8 | 150 | 1 | gpu_cache_noreuse | 0.002300 | 7.83 | 0.002330 | 7.73 | 0.02% | 0.02% | 128.03 | 6991.0 | 0.01 | 3/3 (skip:0) | 3/3 | ok | - |
| throughput | n8_b256 | 8 | 256 | 1 | gpu_cache_noreuse | 0.002303 | 13.34 | 0.002277 | 13.49 | 0.04% | 0.04% | 128.03 | 4096.0 | 0.02 | 3/3 (skip:0) | 3/3 | ok | - |
| throughput | n8_b1024 | 8 | 1024 | 1 | gpu_cache_noreuse | 0.002397 | 51.26 | 0.002397 | 51.26 | 0.14% | 0.14% | 128.12 | 1024.0 | 0.06 | 3/3 (skip:0) | 3/3 | ok | - |
| throughput | n16_b1 | 16 | 1 | 1 | gpu_cache_noreuse | 0.002196 | 0.15 | 0.002078 | 0.15 | 0.00% | 0.00% | 64.00 | 262144.0 | 0.00 | 3/3 (skip:0) | 3/3 | ok | - |
| throughput | n16_b10 | 16 | 10 | 1 | gpu_cache_noreuse | 0.002326 | 1.38 | 0.002331 | 1.37 | 0.00% | 0.00% | 128.00 | 52429.0 | 0.00 | 3/3 (skip:0) | 3/3 | ok | - |
| throughput | n16_b16 | 16 | 16 | 1 | gpu_cache_noreuse | 0.002324 | 2.20 | 0.002269 | 2.26 | 0.01% | 0.01% | 128.00 | 32768.0 | 0.00 | 3/3 (skip:0) | 3/3 | ok | - |
| throughput | n16_b150 | 16 | 150 | 1 | gpu_cache_noreuse | 0.002360 | 20.34 | 0.002308 | 20.80 | 0.06% | 0.06% | 128.06 | 3496.0 | 0.02 | 3/3 (skip:0) | 3/3 | ok | - |
| throughput | n16_b256 | 16 | 256 | 1 | gpu_cache_noreuse | 0.002350 | 34.86 | 0.002336 | 35.07 | 0.09% | 0.10% | 128.06 | 2048.0 | 0.03 | 3/3 (skip:0) | 3/3 | ok | - |
| throughput | n16_b1024 | 16 | 1024 | 1 | gpu_cache_noreuse | 0.002501 | 131.04 | 0.002518 | 130.14 | 0.36% | 0.35% | 128.25 | 512.0 | 0.12 | 3/3 (skip:0) | 3/3 | ok | - |
| throughput | n32_b1 | 32 | 1 | 1 | gpu_cache_noreuse | 0.002503 | 0.32 | 0.002469 | 0.32 | 0.00% | 0.00% | 128.00 | 262144.0 | 0.00 | 3/3 (skip:0) | 3/3 | ok | - |
| throughput | n32_b10 | 32 | 10 | 1 | gpu_cache_noreuse | 0.002664 | 3.00 | 0.002655 | 3.01 | 0.01% | 0.01% | 128.01 | 26215.0 | 0.00 | 3/3 (skip:0) | 3/3 | ok | - |
| throughput | n32_b16 | 32 | 16 | 1 | gpu_cache_noreuse | 0.002724 | 4.70 | 0.002570 | 4.98 | 0.01% | 0.01% | 128.01 | 16384.0 | 0.00 | 3/3 (skip:0) | 3/3 | ok | - |
| throughput | n32_b150 | 32 | 150 | 1 | gpu_cache_noreuse | 0.002902 | 41.35 | 0.002845 | 42.17 | 0.11% | 0.11% | 128.10 | 1748.0 | 0.04 | 3/3 (skip:0) | 3/3 | ok | - |
| throughput | n32_b256 | 32 | 256 | 1 | gpu_cache_noreuse | 0.002851 | 71.84 | 0.002850 | 71.85 | 0.20% | 0.20% | 128.12 | 1024.0 | 0.06 | 3/3 (skip:0) | 3/3 | ok | - |
| throughput | n32_b1024 | 32 | 1024 | 1 | gpu_cache_noreuse | 0.003154 | 259.73 | 0.003190 | 256.83 | 0.71% | 0.70% | 128.50 | 256.0 | 0.25 | 3/3 (skip:0) | 3/3 | ok | - |
| throughput | n64_b1 | 64 | 1 | 1 | gpu_cache_noreuse | 0.002480 | 0.77 | 0.002414 | 0.80 | 0.00% | 0.00% | 128.00 | 131072.0 | 0.00 | 3/3 (skip:0) | 3/3 | ok | - |
| throughput | n64_b10 | 64 | 10 | 1 | gpu_cache_noreuse | 0.002490 | 7.71 | 0.002343 | 8.19 | 0.02% | 0.02% | 128.02 | 13108.0 | 0.00 | 3/3 (skip:0) | 3/3 | ok | - |
| throughput | n64_b16 | 64 | 16 | 1 | gpu_cache_noreuse | 0.002428 | 12.65 | 0.002429 | 12.65 | 0.03% | 0.03% | 128.02 | 8192.0 | 0.01 | 3/3 (skip:0) | 3/3 | ok | - |
| throughput | n64_b150 | 64 | 150 | 1 | gpu_cache_noreuse | 0.002557 | 112.65 | 0.002527 | 113.98 | 0.31% | 0.31% | 128.17 | 874.0 | 0.07 | 3/3 (skip:0) | 3/3 | ok | - |
| throughput | n64_b256 | 64 | 256 | 1 | gpu_cache_noreuse | 0.002739 | 179.45 | 0.002761 | 178.02 | 0.49% | 0.48% | 128.25 | 512.0 | 0.12 | 3/3 (skip:0) | 3/3 | ok | - |
| throughput | n64_b1024 | 64 | 1024 | 1 | gpu_cache_noreuse | 0.003710 | 529.94 | 0.003713 | 529.56 | 1.44% | 1.44% | 129.00 | 128.0 | 0.50 | 3/3 (skip:0) | 3/3 | ok | - |
| throughput | n128_b1 | 128 | 1 | 1 | gpu_cache_noreuse | 0.002691 | 1.67 | 0.002531 | 1.77 | 0.00% | 0.00% | 128.00 | 65536.0 | 0.00 | 3/3 (skip:0) | 3/3 | ok | - |
| throughput | n128_b10 | 128 | 10 | 1 | gpu_cache_noreuse | 0.002619 | 17.11 | 0.002620 | 17.10 | 0.05% | 0.05% | 128.03 | 6554.0 | 0.01 | 3/3 (skip:0) | 3/3 | ok | - |
| throughput | n128_b16 | 128 | 16 | 1 | gpu_cache_noreuse | 0.002671 | 26.84 | 0.002642 | 27.13 | 0.07% | 0.07% | 128.03 | 4096.0 | 0.02 | 3/3 (skip:0) | 3/3 | ok | - |
| throughput | n128_b150 | 128 | 150 | 1 | gpu_cache_noreuse | 0.003008 | 223.38 | 0.003033 | 221.59 | 0.61% | 0.60% | 128.32 | 437.0 | 0.15 | 3/3 (skip:0) | 3/3 | ok | - |
| throughput | n128_b256 | 128 | 256 | 1 | gpu_cache_noreuse | 0.003321 | 345.38 | 0.003343 | 343.03 | 0.94% | 0.93% | 128.50 | 256.0 | 0.25 | 3/3 (skip:0) | 3/3 | ok | - |
| throughput | n128_b1024 | 128 | 1024 | 1 | gpu_cache_noreuse | 0.005217 | 879.28 | 0.005193 | 883.35 | 2.39% | 2.40% | 130.00 | 64.0 | 1.00 | 3/3 (skip:0) | 3/3 | ok | - |
| throughput | n256_b1 | 256 | 1 | 1 | gpu_cache_noreuse | 0.002661 | 3.85 | 0.002517 | 4.07 | 0.01% | 0.01% | 128.00 | 32768.0 | 0.00 | 3/3 (skip:0) | 3/3 | ok | - |
| throughput | n256_b10 | 256 | 10 | 1 | gpu_cache_noreuse | 0.002617 | 39.13 | 0.002599 | 39.39 | 0.11% | 0.11% | 128.05 | 3277.0 | 0.02 | 3/3 (skip:0) | 3/3 | ok | - |
| throughput | n256_b16 | 256 | 16 | 1 | gpu_cache_noreuse | 0.002647 | 61.90 | 0.002635 | 62.17 | 0.17% | 0.17% | 128.06 | 2048.0 | 0.03 | 3/3 (skip:0) | 3/3 | ok | - |
| throughput | n256_b150 | 256 | 150 | 1 | gpu_cache_noreuse | 0.003364 | 456.55 | 0.003391 | 453.01 | 1.24% | 1.23% | 128.91 | 219.0 | 0.29 | 3/3 (skip:0) | 3/3 | ok | - |
| throughput | n256_b256 | 256 | 256 | 1 | gpu_cache_noreuse | 0.003916 | 669.47 | 0.003936 | 666.02 | 1.82% | 1.81% | 129.00 | 128.0 | 0.50 | 3/3 (skip:0) | 3/3 | ok | - |
| throughput | n256_b1024 | 256 | 1024 | 1 | gpu_cache_noreuse | 0.007754 | 1352.25 | 0.007735 | 1355.57 | 3.67% | 3.68% | 132.00 | 32.0 | 2.00 | 3/3 (skip:0) | 3/3 | ok | - |
| throughput | n512_b1 | 512 | 1 | 1 | gpu_cache_noreuse | 0.003086 | 7.47 | 0.003087 | 7.46 | 0.02% | 0.02% | 128.01 | 16384.0 | 0.00 | 3/3 (skip:0) | 3/3 | ok | - |
| throughput | n512_b10 | 512 | 10 | 1 | gpu_cache_noreuse | 0.003156 | 73.01 | 0.003032 | 76.00 | 0.20% | 0.21% | 128.12 | 1639.0 | 0.04 | 3/3 (skip:0) | 3/3 | ok | - |
| throughput | n512_b16 | 512 | 16 | 1 | gpu_cache_noreuse | 0.003103 | 118.81 | 0.003077 | 119.79 | 0.32% | 0.33% | 128.12 | 1024.0 | 0.06 | 3/3 (skip:0) | 3/3 | ok | - |
| throughput | n512_b150 | 512 | 150 | 1 | gpu_cache_noreuse | 0.004393 | 786.77 | 0.004292 | 805.22 | 2.14% | 2.19% | 130.08 | 110.0 | 0.59 | 3/3 (skip:0) | 3/3 | ok | - |
| throughput | n512_b256 | 512 | 256 | 1 | gpu_cache_noreuse | 0.005003 | 1179.02 | 0.005045 | 1169.20 | 3.20% | 3.18% | 130.00 | 64.0 | 1.00 | 3/3 (skip:0) | 3/3 | ok | - |
| throughput | n512_b1024 | 512 | 1024 | 1 | gpu_cache_noreuse | 0.0145 | 1627.85 | 0.0145 | 1627.62 | 4.42% | 4.42% | 136.00 | 16.0 | 4.00 | 3/3 (skip:0) | 3/3 | ok | - |
| throughput | n1024_b1 | 1024 | 1 | 1 | gpu_cache_noreuse | 0.003330 | 15.37 | 0.003305 | 15.49 | 0.04% | 0.04% | 128.02 | 8192.0 | 0.01 | 3/3 (skip:0) | 3/3 | ok | - |
| throughput | n1024_b10 | 1024 | 10 | 1 | gpu_cache_noreuse | 0.003901 | 131.26 | 0.003916 | 130.73 | 0.36% | 0.36% | 128.28 | 820.0 | 0.08 | 3/3 (skip:0) | 3/3 | ok | - |
| throughput | n1024_b16 | 1024 | 16 | 1 | gpu_cache_noreuse | 0.004010 | 204.27 | 0.004006 | 204.48 | 0.55% | 0.56% | 128.25 | 512.0 | 0.12 | 3/3 (skip:0) | 3/3 | ok | - |
| throughput | n1024_b150 | 1024 | 150 | 1 | gpu_cache_noreuse | 0.006573 | 1168.48 | 0.006565 | 1169.84 | 3.17% | 3.18% | 131.25 | 55.0 | 1.17 | 3/3 (skip:0) | 3/3 | ok | - |
| throughput | n1024_b256 | 1024 | 256 | 1 | gpu_cache_noreuse | 0.008296 | 1579.94 | 0.008285 | 1581.98 | 4.29% | 4.30% | 132.00 | 32.0 | 2.00 | 3/3 (skip:0) | 3/3 | ok | - |
| throughput | n1024_b1024 | 1024 | 1024 | 1 | gpu_cache_noreuse | 0.0258 | 2034.49 | 0.0258 | 2032.81 | 5.53% | 5.52% | 144.00 | 8.0 | 8.00 | 3/3 (skip:0) | 3/3 | ok | - |
| throughput | n2048_b1 | 2048 | 1 | 1 | gpu_cache_noreuse | 0.004263 | 26.42 | 0.003908 | 28.82 | 0.07% | 0.08% | 128.03 | 4096.0 | 0.02 | 3/3 (skip:0) | 3/3 | ok | - |
| throughput | n2048_b10 | 2048 | 10 | 1 | gpu_cache_noreuse | 0.004839 | 232.78 | 0.004882 | 230.74 | 0.63% | 0.63% | 128.44 | 410.0 | 0.16 | 3/3 (skip:0) | 3/3 | ok | - |
| throughput | n2048_b16 | 2048 | 16 | 1 | gpu_cache_noreuse | 0.004996 | 360.74 | 0.005020 | 359.04 | 0.98% | 0.98% | 128.50 | 256.0 | 0.25 | 3/3 (skip:0) | 3/3 | ok | - |
| throughput | n2048_b150 | 2048 | 150 | 1 | gpu_cache_noreuse | 0.0117 | 1443.03 | 0.0118 | 1427.47 | 3.92% | 3.88% | 135.94 | 28.0 | 2.34 | 3/3 (skip:0) | 3/3 | ok | - |
| throughput | n2048_b256 | 2048 | 256 | 1 | gpu_cache_noreuse | 0.0162 | 1777.80 | 0.0161 | 1794.58 | 4.83% | 4.87% | 136.00 | 16.0 | 4.00 | 3/3 (skip:0) | 3/3 | ok | - |
| throughput | n2048_b1024 | 2048 | 1024 | 1 | gpu_cache_noreuse | 0.0508 | 2271.70 | 0.0508 | 2270.78 | 6.17% | 6.17% | 160.00 | 4.0 | 16.00 | 3/3 (skip:0) | 3/3 | ok | - |
| throughput | n4096_b1 | 4096 | 1 | 1 | gpu_cache_noreuse | 0.004865 | 50.52 | 0.004882 | 50.34 | 0.14% | 0.14% | 128.06 | 2048.0 | 0.03 | 3/3 (skip:0) | 3/3 | ok | - |
| throughput | n4096_b10 | 4096 | 10 | 1 | gpu_cache_noreuse | 0.005255 | 467.64 | 0.005275 | 465.90 | 1.27% | 1.27% | 128.75 | 205.0 | 0.31 | 3/3 (skip:0) | 3/3 | ok | - |
| throughput | n4096_b16 | 4096 | 16 | 1 | gpu_cache_noreuse | 0.005561 | 707.10 | 0.005612 | 700.63 | 1.92% | 1.90% | 129.00 | 128.0 | 0.50 | 3/3 (skip:0) | 3/3 | ok | - |
| throughput | n4096_b150 | 4096 | 150 | 1 | gpu_cache_noreuse | 0.0170 | 2166.64 | 0.0171 | 2158.78 | 5.88% | 5.86% | 140.62 | 14.0 | 4.69 | 3/3 (skip:0) | 3/3 | ok | - |
| throughput | n4096_b256 | 4096 | 256 | 1 | gpu_cache_noreuse | 0.0256 | 2460.19 | 0.0256 | 2461.35 | 6.68% | 6.69% | 144.00 | 8.0 | 8.00 | 3/3 (skip:0) | 3/3 | ok | - |
| throughput | n4096_b1024 | 4096 | 1024 | 1 | gpu_cache_noreuse | 0.0995 | 2530.40 | 0.0995 | 2529.05 | 6.87% | 6.87% | 192.00 | 2.0 | 32.00 | 3/3 (skip:0) | 3/3 | ok | - |
| throughput | n8192_b1 | 8192 | 1 | 1 | gpu_cache_noreuse | 0.008277 | 64.33 | 0.007857 | 67.77 | 0.17% | 0.18% | 128.12 | 1024.0 | 0.06 | 3/3 (skip:0) | 3/3 | ok | - |
| throughput | n8192_b10 | 8192 | 10 | 1 | gpu_cache_noreuse | 0.008543 | 623.29 | 0.008580 | 620.61 | 1.69% | 1.69% | 130.00 | 103.0 | 0.62 | 3/3 (skip:0) | 3/3 | ok | - |
| throughput | n8192_b16 | 8192 | 16 | 1 | gpu_cache_noreuse | 0.009023 | 944.22 | 0.009096 | 936.67 | 2.56% | 2.54% | 130.00 | 64.0 | 1.00 | 3/3 (skip:0) | 3/3 | ok | - |
| throughput | n8192_b150 | 8192 | 150 | 1 | gpu_cache_noreuse | 0.0357 | 2235.47 | 0.0359 | 2227.39 | 6.07% | 6.05% | 150.00 | 7.0 | 9.38 | 3/3 (skip:0) | 3/3 | ok | - |
| throughput | n8192_b256 | 8192 | 256 | 1 | gpu_cache_noreuse | 0.0536 | 2543.68 | 0.0540 | 2525.58 | 6.91% | 6.86% | 160.00 | 4.0 | 16.00 | 3/3 (skip:0) | 3/3 | ok | - |
| throughput | n8192_b1024 | 8192 | 1024 | 1 | gpu_cache_noreuse | 0.201 | 2711.70 | 0.201 | 2714.85 | 7.37% | 7.37% | 384.00 | 2.0 | 64.00 | 3/3 (skip:0) | 3/3 | ok | - |
| throughput | n16384_b1 | 16384 | 1 | 1 | gpu_cache_noreuse | 0.0104 | 110.17 | 0.0103 | 111.10 | 0.30% | 0.30% | 128.25 | 512.0 | 0.12 | 3/3 (skip:0) | 3/3 | ok | - |
| throughput | n16384_b10 | 16384 | 10 | 1 | gpu_cache_noreuse | 0.0131 | 877.45 | 0.0128 | 896.70 | 2.38% | 2.44% | 132.50 | 52.0 | 1.25 | 3/3 (skip:0) | 3/3 | ok | - |
| throughput | n16384_b16 | 16384 | 16 | 1 | gpu_cache_noreuse | 0.0156 | 1173.03 | 0.0156 | 1174.86 | 3.19% | 3.19% | 132.00 | 32.0 | 2.00 | 3/3 (skip:0) | 3/3 | ok | - |
| throughput | n16384_b150 | 16384 | 150 | 1 | gpu_cache_noreuse | 0.0887 | 1939.00 | 0.0886 | 1940.77 | 5.27% | 5.27% | 187.50 | 4.0 | 18.75 | 3/3 (skip:0) | 3/3 | ok | - |
| throughput | n16384_b256 | 16384 | 256 | 1 | gpu_cache_noreuse | 0.129 | 2276.80 | 0.129 | 2274.02 | 6.18% | 6.18% | 192.00 | 2.0 | 32.00 | 3/3 (skip:0) | 3/3 | ok | - |
| throughput | n16384_b1024 | 16384 | 1024 | 1 | gpu_cache_noreuse | 0.421 | 2792.43 | 0.420 | 2798.67 | 7.58% | 7.60% | 768.00 | 2.0 | 128.00 | 3/3 (skip:0) | 3/3 | ok | - |
| throughput | n32768_b1 | 32768 | 1 | 1 | gpu_cache_noreuse | 0.008371 | 293.60 | 0.008190 | 300.06 | 0.80% | 0.81% | 128.50 | 256.0 | 0.25 | 3/3 (skip:0) | 3/3 | ok | - |
| throughput | n32768_b10 | 32768 | 10 | 1 | gpu_cache_noreuse | 0.0164 | 1499.60 | 0.0164 | 1501.19 | 4.07% | 4.08% | 135.00 | 26.0 | 2.50 | 3/3 (skip:0) | 3/3 | ok | - |
| throughput | n32768_b16 | 32768 | 16 | 1 | gpu_cache_noreuse | 0.0238 | 1652.68 | 0.0237 | 1659.21 | 4.49% | 4.51% | 136.00 | 16.0 | 4.00 | 3/3 (skip:0) | 3/3 | ok | - |
| throughput | n32768_b150 | 32768 | 150 | 1 | gpu_cache_noreuse | 0.236 | 1561.29 | 0.236 | 1558.84 | 4.24% | 4.23% | 225.00 | 2.0 | 37.50 | 3/3 (skip:0) | 3/3 | ok | - |
| throughput | n32768_b256 | 32768 | 256 | 1 | gpu_cache_noreuse | 0.399 | 1575.97 | 0.399 | 1575.31 | 4.28% | 4.28% | 384.00 | 2.0 | 64.00 | 3/3 (skip:0) | 3/3 | ok | - |
| throughput | n32768_b1024 | 32768 | 1024 | 1 | gpu_cache_noreuse | 1.580 | 1593.05 | 1.579 | 1593.55 | 4.33% | 4.33% | 1536.00 | 2.0 | 256.00 | 3/3 (skip:0) | 3/3 | ok | - |
| throughput | n65536_b1 | 65536 | 1 | 1 | gpu_cache_noreuse | 0.008186 | 640.50 | 0.008023 | 653.48 | 1.74% | 1.77% | 129.00 | 128.0 | 0.50 | 3/3 (skip:0) | 3/3 | ok | - |
| throughput | n65536_b10 | 65536 | 10 | 1 | gpu_cache_noreuse | 0.0280 | 1869.14 | 0.0280 | 1871.43 | 5.08% | 5.08% | 140.00 | 13.0 | 5.00 | 3/3 (skip:0) | 3/3 | ok | - |
| throughput | n65536_b16 | 65536 | 16 | 1 | gpu_cache_noreuse | 0.0539 | 1555.55 | 0.0539 | 1556.64 | 4.22% | 4.23% | 144.00 | 8.0 | 8.00 | 3/3 (skip:0) | 3/3 | ok | - |
| throughput | n65536_b150 | 65536 | 150 | 1 | gpu_cache_noreuse | 0.466 | 1689.31 | 0.466 | 1689.17 | 4.59% | 4.59% | 450.00 | 2.0 | 75.00 | 3/3 (skip:0) | 3/3 | ok | - |
| throughput | n65536_b256 | 65536 | 256 | 1 | gpu_cache_noreuse | 0.790 | 1698.29 | 0.790 | 1698.12 | 4.61% | 4.61% | 768.00 | 2.0 | 128.00 | 3/3 (skip:0) | 3/3 | ok | - |
| throughput | n65536_b1024 | 65536 | 1024 | 1 | gpu_cache_noreuse | 3.144 | 1707.48 | 3.144 | 1707.60 | 4.64% | 4.64% | 3072.00 | 2.0 | 512.00 | 3/3 (skip:0) | 3/3 | ok | - |

- CSV: `/home/nikhil/workspace/xeon-fft-bench/src/gpu/runs/run_gpu_cache_noreuse/20260313_121932/latest_run_avg.csv`