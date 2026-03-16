# run_gpu_cache_reuse (3-run average)

- Generated at: 2026-03-13 12:38:13.451371
- Manifest: `/home/nikhil/workspace/xeon-fft-bench/src/gpu/runs/run_gpu_cache_reuse/20260313_130500/manifest.tsv`
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
- `BENCH_STREAM_MAX_SLOTS` = `1`
- `BENCH_STREAM_MIN_SLOTS` = `1`
- `BENCH_STREAM_MODE` = `0`
- `BENCH_STREAM_TARGET_MB` = `0`
- `BENCH_VALIDATE` = `1`
- `BENCH_VALIDATE_STRICT` = `1`
- `BENCH_VALIDATE_TOL` = `1e-4`
- `BENCH_WARMUP` = `5`
- `THROUGHPUT_BATCHES` = `1,10,16,150,256,1024`
- `THROUGHPUT_LENGTHS` = `2,4,8,16,32,64,128,256,512,1024,2048,4096,8192,16384,32768,65536`

## Run Files

| Run | Log | Report |
|---|---|---|
| run01 | `/home/nikhil/workspace/xeon-fft-bench/src/gpu/runs/run_gpu_cache_reuse/20260313_130500/runs/run01/fft_benchmark_gpu_20260313_123649.log` | `/home/nikhil/workspace/xeon-fft-bench/src/gpu/runs/run_gpu_cache_reuse/20260313_130500/runs/run01/fft_benchmark_gpu_20260313_123649.report.md` |
| run02 | `/home/nikhil/workspace/xeon-fft-bench/src/gpu/runs/run_gpu_cache_reuse/20260313_130500/runs/run02/fft_benchmark_gpu_20260313_123717.log` | `/home/nikhil/workspace/xeon-fft-bench/src/gpu/runs/run_gpu_cache_reuse/20260313_130500/runs/run02/fft_benchmark_gpu_20260313_123717.report.md` |
| run03 | `/home/nikhil/workspace/xeon-fft-bench/src/gpu/runs/run_gpu_cache_reuse/20260313_130500/runs/run03/fft_benchmark_gpu_20260313_123744.log` | `/home/nikhil/workspace/xeon-fft-bench/src/gpu/runs/run_gpu_cache_reuse/20260313_130500/runs/run03/fft_benchmark_gpu_20260313_123744.report.md` |

## Scenario Catalog

| Profile | Description | Workload | Library | Family |
|---|---|---|---|---|
| gpu_cache_reuse | cuFFT cache-reuse (hot device-buffer reuse) | throughput | CUDA_CUFFT | run_gpu_cache_reuse |

## Summary Stats

- Rows aggregated: 96
- Quality counts: {'ok': 96}
- Best forward: `n16384_b1024` = 2798.54 GFLOPS (7.60%)
- Best backward: `n16384_b1024` = 2798.59 GFLOPS (7.60%)

## Averaged Results

| Workload | Case | N | Batch | ThreadsField | Profile | Avg Fwd ms | Avg Fwd SP GFLOPS | Avg Bwd ms | Avg Bwd SP GFLOPS | Fwd % Peak | Bwd % Peak | Avg Mem MB | Avg Slots | Avg Work MB | Samples | Checks | Quality | Note |
|---|---|---:|---:|---:|---|---:|---:|---:|---:|---:|---:|---:|---:|---:|---|---|---|---|
| throughput | n2_b1 | 2 | 1 | 1 | gpu_cache_reuse | 0.001796 | 0.01 | 0.001788 | 0.01 | 0.00% | 0.00% | 0.00 | 1.0 | 0.00 | 3/3 (skip:0) | 3/3 | ok | - |
| throughput | n2_b10 | 2 | 10 | 1 | gpu_cache_reuse | 0.001791 | 0.06 | 0.001780 | 0.06 | 0.00% | 0.00% | 0.00 | 1.0 | 0.00 | 3/3 (skip:0) | 3/3 | ok | - |
| throughput | n2_b16 | 2 | 16 | 1 | gpu_cache_reuse | 0.001784 | 0.09 | 0.001788 | 0.09 | 0.00% | 0.00% | 0.00 | 1.0 | 0.00 | 3/3 (skip:0) | 3/3 | ok | - |
| throughput | n2_b150 | 2 | 150 | 1 | gpu_cache_reuse | 0.001791 | 0.84 | 0.001787 | 0.84 | 0.00% | 0.00% | 0.01 | 1.0 | 0.00 | 3/3 (skip:0) | 3/3 | ok | - |
| throughput | n2_b256 | 2 | 256 | 1 | gpu_cache_reuse | 0.001790 | 1.43 | 0.001784 | 1.44 | 0.00% | 0.00% | 0.02 | 1.0 | 0.00 | 3/3 (skip:0) | 3/3 | ok | - |
| throughput | n2_b1024 | 2 | 1024 | 1 | gpu_cache_reuse | 0.001788 | 5.73 | 0.001782 | 5.75 | 0.02% | 0.02% | 0.06 | 1.0 | 0.02 | 3/3 (skip:0) | 3/3 | ok | - |
| throughput | n4_b1 | 4 | 1 | 1 | gpu_cache_reuse | 0.001779 | 0.02 | 0.001779 | 0.02 | 0.00% | 0.00% | 0.00 | 1.0 | 0.00 | 3/3 (skip:0) | 3/3 | ok | - |
| throughput | n4_b10 | 4 | 10 | 1 | gpu_cache_reuse | 0.001778 | 0.22 | 0.001781 | 0.22 | 0.00% | 0.00% | 0.00 | 1.0 | 0.00 | 3/3 (skip:0) | 3/3 | ok | - |
| throughput | n4_b16 | 4 | 16 | 1 | gpu_cache_reuse | 0.001776 | 0.36 | 0.001778 | 0.36 | 0.00% | 0.00% | 0.00 | 1.0 | 0.00 | 3/3 (skip:0) | 3/3 | ok | - |
| throughput | n4_b150 | 4 | 150 | 1 | gpu_cache_reuse | 0.001839 | 3.26 | 0.001834 | 3.27 | 0.01% | 0.01% | 0.02 | 1.0 | 0.00 | 3/3 (skip:0) | 3/3 | ok | - |
| throughput | n4_b256 | 4 | 256 | 1 | gpu_cache_reuse | 0.001843 | 5.56 | 0.001846 | 5.55 | 0.02% | 0.02% | 0.03 | 1.0 | 0.01 | 3/3 (skip:0) | 3/3 | ok | - |
| throughput | n4_b1024 | 4 | 1024 | 1 | gpu_cache_reuse | 0.001835 | 22.32 | 0.001843 | 22.23 | 0.06% | 0.06% | 0.12 | 1.0 | 0.03 | 3/3 (skip:0) | 3/3 | ok | - |
| throughput | n8_b1 | 8 | 1 | 1 | gpu_cache_reuse | 0.001788 | 0.07 | 0.001786 | 0.07 | 0.00% | 0.00% | 0.00 | 1.0 | 0.00 | 3/3 (skip:0) | 3/3 | ok | - |
| throughput | n8_b10 | 8 | 10 | 1 | gpu_cache_reuse | 0.001839 | 0.65 | 0.001835 | 0.65 | 0.00% | 0.00% | 0.00 | 1.0 | 0.00 | 3/3 (skip:0) | 3/3 | ok | - |
| throughput | n8_b16 | 8 | 16 | 1 | gpu_cache_reuse | 0.001872 | 1.03 | 0.001872 | 1.03 | 0.00% | 0.00% | 0.00 | 1.0 | 0.00 | 3/3 (skip:0) | 3/3 | ok | - |
| throughput | n8_b150 | 8 | 150 | 1 | gpu_cache_reuse | 0.002007 | 8.97 | 0.002002 | 8.99 | 0.02% | 0.02% | 0.04 | 1.0 | 0.01 | 3/3 (skip:0) | 3/3 | ok | - |
| throughput | n8_b256 | 8 | 256 | 1 | gpu_cache_reuse | 0.002018 | 15.22 | 0.002009 | 15.29 | 0.04% | 0.04% | 0.06 | 1.0 | 0.02 | 3/3 (skip:0) | 3/3 | ok | - |
| throughput | n8_b1024 | 8 | 1024 | 1 | gpu_cache_reuse | 0.001968 | 62.45 | 0.001967 | 62.46 | 0.17% | 0.17% | 0.25 | 1.0 | 0.06 | 3/3 (skip:0) | 3/3 | ok | - |
| throughput | n16_b1 | 16 | 1 | 1 | gpu_cache_reuse | 0.001814 | 0.18 | 0.001810 | 0.18 | 0.00% | 0.00% | 0.00 | 1.0 | 0.00 | 3/3 (skip:0) | 3/3 | ok | - |
| throughput | n16_b10 | 16 | 10 | 1 | gpu_cache_reuse | 0.001882 | 1.70 | 0.001883 | 1.70 | 0.00% | 0.00% | 0.00 | 1.0 | 0.00 | 3/3 (skip:0) | 3/3 | ok | - |
| throughput | n16_b16 | 16 | 16 | 1 | gpu_cache_reuse | 0.001886 | 2.71 | 0.001884 | 2.72 | 0.01% | 0.01% | 0.01 | 1.0 | 0.00 | 3/3 (skip:0) | 3/3 | ok | - |
| throughput | n16_b150 | 16 | 150 | 1 | gpu_cache_reuse | 0.002025 | 23.70 | 0.002025 | 23.70 | 0.06% | 0.06% | 0.07 | 1.0 | 0.02 | 3/3 (skip:0) | 3/3 | ok | - |
| throughput | n16_b256 | 16 | 256 | 1 | gpu_cache_reuse | 0.002026 | 40.43 | 0.002026 | 40.43 | 0.11% | 0.11% | 0.12 | 1.0 | 0.03 | 3/3 (skip:0) | 3/3 | ok | - |
| throughput | n16_b1024 | 16 | 1024 | 1 | gpu_cache_reuse | 0.002169 | 151.07 | 0.002169 | 151.10 | 0.41% | 0.41% | 0.50 | 1.0 | 0.12 | 3/3 (skip:0) | 3/3 | ok | - |
| throughput | n32_b1 | 32 | 1 | 1 | gpu_cache_reuse | 0.002027 | 0.39 | 0.002027 | 0.39 | 0.00% | 0.00% | 0.00 | 1.0 | 0.00 | 3/3 (skip:0) | 3/3 | ok | - |
| throughput | n32_b10 | 32 | 10 | 1 | gpu_cache_reuse | 0.002166 | 3.69 | 0.002166 | 3.69 | 0.01% | 0.01% | 0.01 | 1.0 | 0.00 | 3/3 (skip:0) | 3/3 | ok | - |
| throughput | n32_b16 | 32 | 16 | 1 | gpu_cache_reuse | 0.002255 | 5.68 | 0.002270 | 5.64 | 0.02% | 0.02% | 0.02 | 1.0 | 0.00 | 3/3 (skip:0) | 3/3 | ok | - |
| throughput | n32_b150 | 32 | 150 | 1 | gpu_cache_reuse | 0.002451 | 48.96 | 0.002453 | 48.93 | 0.13% | 0.13% | 0.15 | 1.0 | 0.04 | 3/3 (skip:0) | 3/3 | ok | - |
| throughput | n32_b256 | 32 | 256 | 1 | gpu_cache_reuse | 0.002453 | 83.50 | 0.002452 | 83.51 | 0.23% | 0.23% | 0.25 | 1.0 | 0.06 | 3/3 (skip:0) | 3/3 | ok | - |
| throughput | n32_b1024 | 32 | 1024 | 1 | gpu_cache_reuse | 0.002576 | 318.05 | 0.002593 | 315.93 | 0.86% | 0.86% | 1.00 | 1.0 | 0.25 | 3/3 (skip:0) | 3/3 | ok | - |
| throughput | n64_b1 | 64 | 1 | 1 | gpu_cache_reuse | 0.002023 | 0.95 | 0.002023 | 0.95 | 0.00% | 0.00% | 0.00 | 1.0 | 0.00 | 3/3 (skip:0) | 3/3 | ok | - |
| throughput | n64_b10 | 64 | 10 | 1 | gpu_cache_reuse | 0.002024 | 9.48 | 0.002024 | 9.48 | 0.03% | 0.03% | 0.02 | 1.0 | 0.00 | 3/3 (skip:0) | 3/3 | ok | - |
| throughput | n64_b16 | 64 | 16 | 1 | gpu_cache_reuse | 0.002024 | 15.18 | 0.002024 | 15.18 | 0.04% | 0.04% | 0.03 | 1.0 | 0.01 | 3/3 (skip:0) | 3/3 | ok | - |
| throughput | n64_b150 | 64 | 150 | 1 | gpu_cache_reuse | 0.002168 | 132.82 | 0.002165 | 133.03 | 0.36% | 0.36% | 0.29 | 1.0 | 0.07 | 3/3 (skip:0) | 3/3 | ok | - |
| throughput | n64_b256 | 64 | 256 | 1 | gpu_cache_reuse | 0.002169 | 226.61 | 0.002168 | 226.72 | 0.62% | 0.62% | 0.50 | 1.0 | 0.12 | 3/3 (skip:0) | 3/3 | ok | - |
| throughput | n64_b1024 | 64 | 1024 | 1 | gpu_cache_reuse | 0.002611 | 753.00 | 0.002611 | 753.09 | 2.05% | 2.05% | 2.00 | 1.0 | 0.50 | 3/3 (skip:0) | 3/3 | ok | - |
| throughput | n128_b1 | 128 | 1 | 1 | gpu_cache_reuse | 0.002169 | 2.07 | 0.002166 | 2.07 | 0.01% | 0.01% | 0.00 | 1.0 | 0.00 | 3/3 (skip:0) | 3/3 | ok | - |
| throughput | n128_b10 | 128 | 10 | 1 | gpu_cache_reuse | 0.002307 | 19.42 | 0.002306 | 19.42 | 0.05% | 0.05% | 0.04 | 1.0 | 0.01 | 3/3 (skip:0) | 3/3 | ok | - |
| throughput | n128_b16 | 128 | 16 | 1 | gpu_cache_reuse | 0.002307 | 31.08 | 0.002307 | 31.08 | 0.08% | 0.08% | 0.06 | 1.0 | 0.02 | 3/3 (skip:0) | 3/3 | ok | - |
| throughput | n128_b150 | 128 | 150 | 1 | gpu_cache_reuse | 0.002317 | 290.03 | 0.002315 | 290.24 | 0.79% | 0.79% | 0.59 | 1.0 | 0.15 | 3/3 (skip:0) | 3/3 | ok | - |
| throughput | n128_b256 | 128 | 256 | 1 | gpu_cache_reuse | 0.002459 | 466.40 | 0.002459 | 466.34 | 1.27% | 1.27% | 1.00 | 1.0 | 0.25 | 3/3 (skip:0) | 3/3 | ok | - |
| throughput | n128_b1024 | 128 | 1024 | 1 | gpu_cache_reuse | 0.003334 | 1376.12 | 0.003340 | 1373.37 | 3.74% | 3.73% | 4.00 | 1.0 | 1.00 | 3/3 (skip:0) | 3/3 | ok | - |
| throughput | n256_b1 | 256 | 1 | 1 | gpu_cache_reuse | 0.002313 | 4.43 | 0.002313 | 4.43 | 0.01% | 0.01% | 0.01 | 1.0 | 0.00 | 3/3 (skip:0) | 3/3 | ok | - |
| throughput | n256_b10 | 256 | 10 | 1 | gpu_cache_reuse | 0.002315 | 44.23 | 0.002315 | 44.23 | 0.12% | 0.12% | 0.08 | 1.0 | 0.02 | 3/3 (skip:0) | 3/3 | ok | - |
| throughput | n256_b16 | 256 | 16 | 1 | gpu_cache_reuse | 0.002315 | 70.77 | 0.002315 | 70.77 | 0.19% | 0.19% | 0.12 | 1.0 | 0.03 | 3/3 (skip:0) | 3/3 | ok | - |
| throughput | n256_b150 | 256 | 150 | 1 | gpu_cache_reuse | 0.002611 | 588.28 | 0.002612 | 588.13 | 1.60% | 1.60% | 1.17 | 1.0 | 0.29 | 3/3 (skip:0) | 3/3 | ok | - |
| throughput | n256_b256 | 256 | 256 | 1 | gpu_cache_reuse | 0.002760 | 949.91 | 0.002765 | 947.97 | 2.58% | 2.57% | 2.00 | 1.0 | 0.50 | 3/3 (skip:0) | 3/3 | ok | - |
| throughput | n256_b1024 | 256 | 1024 | 1 | gpu_cache_reuse | 0.004367 | 2401.14 | 0.004434 | 2364.85 | 6.52% | 6.42% | 8.00 | 1.0 | 2.00 | 3/3 (skip:0) | 3/3 | ok | - |
| throughput | n512_b1 | 512 | 1 | 1 | gpu_cache_reuse | 0.002594 | 8.88 | 0.002594 | 8.88 | 0.02% | 0.02% | 0.02 | 1.0 | 0.00 | 3/3 (skip:0) | 3/3 | ok | - |
| throughput | n512_b10 | 512 | 10 | 1 | gpu_cache_reuse | 0.002734 | 84.28 | 0.002734 | 84.28 | 0.23% | 0.23% | 0.16 | 1.0 | 0.04 | 3/3 (skip:0) | 3/3 | ok | - |
| throughput | n512_b16 | 512 | 16 | 1 | gpu_cache_reuse | 0.002734 | 134.82 | 0.002735 | 134.80 | 0.37% | 0.37% | 0.25 | 1.0 | 0.06 | 3/3 (skip:0) | 3/3 | ok | - |
| throughput | n512_b150 | 512 | 150 | 1 | gpu_cache_reuse | 0.003185 | 1084.97 | 0.003190 | 1083.27 | 2.95% | 2.94% | 2.34 | 1.0 | 0.59 | 3/3 (skip:0) | 3/3 | ok | - |
| throughput | n512_b256 | 512 | 256 | 1 | gpu_cache_reuse | 0.003678 | 1603.80 | 0.003738 | 1578.05 | 4.36% | 4.29% | 4.00 | 1.0 | 1.00 | 3/3 (skip:0) | 3/3 | ok | - |
| throughput | n512_b1024 | 512 | 1024 | 1 | gpu_cache_reuse | 0.0129 | 1828.58 | 0.0138 | 1712.12 | 4.97% | 4.65% | 16.00 | 1.0 | 4.00 | 3/3 (skip:0) | 3/3 | ok | - |
| throughput | n1024_b1 | 1024 | 1 | 1 | gpu_cache_reuse | 0.002875 | 17.81 | 0.002876 | 17.80 | 0.05% | 0.05% | 0.03 | 1.0 | 0.01 | 3/3 (skip:0) | 3/3 | ok | - |
| throughput | n1024_b10 | 1024 | 10 | 1 | gpu_cache_reuse | 0.003303 | 155.03 | 0.003303 | 155.01 | 0.42% | 0.42% | 0.31 | 1.0 | 0.08 | 3/3 (skip:0) | 3/3 | ok | - |
| throughput | n1024_b16 | 1024 | 16 | 1 | gpu_cache_reuse | 0.003306 | 247.79 | 0.003305 | 247.89 | 0.67% | 0.67% | 0.50 | 1.0 | 0.12 | 3/3 (skip:0) | 3/3 | ok | - |
| throughput | n1024_b150 | 1024 | 150 | 1 | gpu_cache_reuse | 0.004334 | 1772.04 | 0.004352 | 1764.84 | 4.81% | 4.79% | 4.69 | 1.0 | 1.17 | 3/3 (skip:0) | 3/3 | ok | - |
| throughput | n1024_b256 | 1024 | 256 | 1 | gpu_cache_reuse | 0.005035 | 2603.39 | 0.005016 | 2613.25 | 7.07% | 7.10% | 8.00 | 1.0 | 2.00 | 3/3 (skip:0) | 3/3 | ok | - |
| throughput | n1024_b1024 | 1024 | 1024 | 1 | gpu_cache_reuse | 0.0256 | 2051.85 | 0.0255 | 2054.74 | 5.57% | 5.58% | 32.00 | 1.0 | 8.00 | 3/3 (skip:0) | 3/3 | ok | - |
| throughput | n2048_b1 | 2048 | 1 | 1 | gpu_cache_reuse | 0.003771 | 29.87 | 0.003723 | 30.25 | 0.08% | 0.08% | 0.06 | 1.0 | 0.02 | 3/3 (skip:0) | 3/3 | ok | - |
| throughput | n2048_b10 | 2048 | 10 | 1 | gpu_cache_reuse | 0.004440 | 253.71 | 0.004437 | 253.85 | 0.69% | 0.69% | 0.62 | 1.0 | 0.16 | 3/3 (skip:0) | 3/3 | ok | - |
| throughput | n2048_b16 | 2048 | 16 | 1 | gpu_cache_reuse | 0.004441 | 405.82 | 0.004443 | 405.67 | 1.10% | 1.10% | 1.00 | 1.0 | 0.25 | 3/3 (skip:0) | 3/3 | ok | - |
| throughput | n2048_b150 | 2048 | 150 | 1 | gpu_cache_reuse | 0.007456 | 2265.99 | 0.007402 | 2282.73 | 6.15% | 6.20% | 9.38 | 1.0 | 2.34 | 3/3 (skip:0) | 3/3 | ok | - |
| throughput | n2048_b256 | 2048 | 256 | 1 | gpu_cache_reuse | 0.0149 | 1937.76 | 0.0154 | 1868.29 | 5.26% | 5.07% | 16.00 | 1.0 | 4.00 | 3/3 (skip:0) | 3/3 | ok | - |
| throughput | n2048_b1024 | 2048 | 1024 | 1 | gpu_cache_reuse | 0.0507 | 2276.51 | 0.0506 | 2280.11 | 6.18% | 6.19% | 64.00 | 1.0 | 16.00 | 3/3 (skip:0) | 3/3 | ok | - |
| throughput | n4096_b1 | 4096 | 1 | 1 | gpu_cache_reuse | 0.004389 | 55.99 | 0.004390 | 55.98 | 0.15% | 0.15% | 0.12 | 1.0 | 0.03 | 3/3 (skip:0) | 3/3 | ok | - |
| throughput | n4096_b10 | 4096 | 10 | 1 | gpu_cache_reuse | 0.004377 | 561.44 | 0.004316 | 569.46 | 1.52% | 1.55% | 1.25 | 1.0 | 0.31 | 3/3 (skip:0) | 3/3 | ok | - |
| throughput | n4096_b16 | 4096 | 16 | 1 | gpu_cache_reuse | 0.004315 | 911.28 | 0.004312 | 911.98 | 2.48% | 2.48% | 2.00 | 1.0 | 0.50 | 3/3 (skip:0) | 3/3 | ok | - |
| throughput | n4096_b150 | 4096 | 150 | 1 | gpu_cache_reuse | 0.0167 | 2212.90 | 0.0164 | 2244.84 | 6.01% | 6.10% | 18.75 | 1.0 | 4.69 | 3/3 (skip:0) | 3/3 | ok | - |
| throughput | n4096_b256 | 4096 | 256 | 1 | gpu_cache_reuse | 0.0254 | 2476.43 | 0.0254 | 2473.22 | 6.73% | 6.72% | 32.00 | 1.0 | 8.00 | 3/3 (skip:0) | 3/3 | ok | - |
| throughput | n4096_b1024 | 4096 | 1024 | 1 | gpu_cache_reuse | 0.0992 | 2537.31 | 0.0994 | 2531.33 | 6.89% | 6.88% | 128.00 | 1.0 | 32.00 | 3/3 (skip:0) | 3/3 | ok | - |
| throughput | n8192_b1 | 8192 | 1 | 1 | gpu_cache_reuse | 0.008177 | 65.12 | 0.007797 | 68.30 | 0.18% | 0.19% | 0.25 | 1.0 | 0.06 | 3/3 (skip:0) | 3/3 | ok | - |
| throughput | n8192_b10 | 8192 | 10 | 1 | gpu_cache_reuse | 0.007529 | 707.27 | 0.007327 | 726.74 | 1.92% | 1.97% | 2.50 | 1.0 | 0.62 | 3/3 (skip:0) | 3/3 | ok | - |
| throughput | n8192_b16 | 8192 | 16 | 1 | gpu_cache_reuse | 0.007239 | 1176.91 | 0.007234 | 1177.67 | 3.20% | 3.20% | 4.00 | 1.0 | 1.00 | 3/3 (skip:0) | 3/3 | ok | - |
| throughput | n8192_b150 | 8192 | 150 | 1 | gpu_cache_reuse | 0.0348 | 2297.42 | 0.0347 | 2302.76 | 6.24% | 6.25% | 37.50 | 1.0 | 9.38 | 3/3 (skip:0) | 3/3 | ok | - |
| throughput | n8192_b256 | 8192 | 256 | 1 | gpu_cache_reuse | 0.0525 | 2596.64 | 0.0531 | 2568.13 | 7.05% | 6.98% | 64.00 | 1.0 | 16.00 | 3/3 (skip:0) | 3/3 | ok | - |
| throughput | n8192_b1024 | 8192 | 1024 | 1 | gpu_cache_reuse | 0.201 | 2717.80 | 0.201 | 2711.78 | 7.38% | 7.37% | 256.00 | 1.0 | 64.00 | 3/3 (skip:0) | 3/3 | ok | - |
| throughput | n16384_b1 | 16384 | 1 | 1 | gpu_cache_reuse | 0.0101 | 113.58 | 0.009813 | 116.88 | 0.31% | 0.32% | 0.50 | 1.0 | 0.12 | 3/3 (skip:0) | 3/3 | ok | - |
| throughput | n16384_b10 | 16384 | 10 | 1 | gpu_cache_reuse | 0.0106 | 1077.49 | 0.0104 | 1101.15 | 2.93% | 2.99% | 5.00 | 1.0 | 1.25 | 3/3 (skip:0) | 3/3 | ok | - |
| throughput | n16384_b16 | 16384 | 16 | 1 | gpu_cache_reuse | 0.0144 | 1273.99 | 0.0147 | 1245.48 | 3.46% | 3.38% | 8.00 | 1.0 | 2.00 | 3/3 (skip:0) | 3/3 | ok | - |
| throughput | n16384_b150 | 16384 | 150 | 1 | gpu_cache_reuse | 0.0874 | 1968.67 | 0.0863 | 1993.91 | 5.35% | 5.42% | 75.00 | 1.0 | 18.75 | 3/3 (skip:0) | 3/3 | ok | - |
| throughput | n16384_b256 | 16384 | 256 | 1 | gpu_cache_reuse | 0.129 | 2267.30 | 0.130 | 2263.68 | 6.16% | 6.15% | 128.00 | 1.0 | 32.00 | 3/3 (skip:0) | 3/3 | ok | - |
| throughput | n16384_b1024 | 16384 | 1024 | 1 | gpu_cache_reuse | 0.420 | 2798.54 | 0.420 | 2798.59 | 7.60% | 7.60% | 512.00 | 1.0 | 128.00 | 3/3 (skip:0) | 3/3 | ok | - |
| throughput | n32768_b1 | 32768 | 1 | 1 | gpu_cache_reuse | 0.007975 | 308.16 | 0.007894 | 311.34 | 0.84% | 0.85% | 1.00 | 1.0 | 0.25 | 3/3 (skip:0) | 3/3 | ok | - |
| throughput | n32768_b10 | 32768 | 10 | 1 | gpu_cache_reuse | 0.0159 | 1548.19 | 0.0158 | 1553.08 | 4.20% | 4.22% | 10.00 | 1.0 | 2.50 | 3/3 (skip:0) | 3/3 | ok | - |
| throughput | n32768_b16 | 32768 | 16 | 1 | gpu_cache_reuse | 0.0234 | 1677.57 | 0.0235 | 1673.92 | 4.56% | 4.55% | 16.00 | 1.0 | 4.00 | 3/3 (skip:0) | 3/3 | ok | - |
| throughput | n32768_b150 | 32768 | 150 | 1 | gpu_cache_reuse | 0.236 | 1561.24 | 0.236 | 1559.75 | 4.24% | 4.24% | 150.00 | 1.0 | 37.50 | 3/3 (skip:0) | 3/3 | ok | - |
| throughput | n32768_b256 | 32768 | 256 | 1 | gpu_cache_reuse | 0.399 | 1576.01 | 0.399 | 1575.97 | 4.28% | 4.28% | 256.00 | 1.0 | 64.00 | 3/3 (skip:0) | 3/3 | ok | - |
| throughput | n32768_b1024 | 32768 | 1024 | 1 | gpu_cache_reuse | 1.579 | 1593.41 | 1.579 | 1593.75 | 4.33% | 4.33% | 1024.00 | 1.0 | 256.00 | 3/3 (skip:0) | 3/3 | ok | - |
| throughput | n65536_b1 | 65536 | 1 | 1 | gpu_cache_reuse | 0.007251 | 723.06 | 0.006926 | 757.02 | 1.96% | 2.06% | 2.00 | 1.0 | 0.50 | 3/3 (skip:0) | 3/3 | ok | - |
| throughput | n65536_b10 | 65536 | 10 | 1 | gpu_cache_reuse | 0.0282 | 1860.98 | 0.0280 | 1872.35 | 5.05% | 5.09% | 20.00 | 1.0 | 5.00 | 3/3 (skip:0) | 3/3 | ok | - |
| throughput | n65536_b16 | 65536 | 16 | 1 | gpu_cache_reuse | 0.0538 | 1560.58 | 0.0537 | 1562.34 | 4.24% | 4.24% | 32.00 | 1.0 | 8.00 | 3/3 (skip:0) | 3/3 | ok | - |
| throughput | n65536_b150 | 65536 | 150 | 1 | gpu_cache_reuse | 0.465 | 1690.35 | 0.466 | 1689.33 | 4.59% | 4.59% | 300.00 | 1.0 | 75.00 | 3/3 (skip:0) | 3/3 | ok | - |
| throughput | n65536_b256 | 65536 | 256 | 1 | gpu_cache_reuse | 0.790 | 1698.01 | 0.790 | 1698.10 | 4.61% | 4.61% | 512.00 | 1.0 | 128.00 | 3/3 (skip:0) | 3/3 | ok | - |
| throughput | n65536_b1024 | 65536 | 1024 | 1 | gpu_cache_reuse | 3.144 | 1707.46 | 3.144 | 1707.81 | 4.64% | 4.64% | 2048.00 | 1.0 | 512.00 | 3/3 (skip:0) | 3/3 | ok | - |

- CSV: `/home/nikhil/workspace/xeon-fft-bench/src/gpu/runs/run_gpu_cache_reuse/20260313_130500/latest_run_avg.csv`