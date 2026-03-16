# gpu_run_9501MHz (3-run average)

- Generated at: 2026-03-16 14:38:47.424021
- Manifest: `/home/nikhil/workspace/xeon-fft-bench/src/gpu/runs/gpu_run_9501MHz/20260316_143809/manifest.tsv`
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
- `THROUGHPUT_BATCHES` = `1`
- `THROUGHPUT_LENGTHS` = `2,4,8,16,32,64,128,256,512,1024,2048,4096,8192,16384,32768,65536,131072,262144,524288,1048576,2097152,4194304`

## Run Files

| Run | Log | Report |
|---|---|---|
| run01 | `/home/nikhil/workspace/xeon-fft-bench/src/gpu/runs/gpu_run_9501MHz/20260316_143809/runs/run01/fft_benchmark_gpu_20260316_143810.log` | `/home/nikhil/workspace/xeon-fft-bench/src/gpu/runs/gpu_run_9501MHz/20260316_143809/runs/run01/fft_benchmark_gpu_20260316_143810.report.md` |
| run02 | `/home/nikhil/workspace/xeon-fft-bench/src/gpu/runs/gpu_run_9501MHz/20260316_143809/runs/run02/fft_benchmark_gpu_20260316_143823.log` | `/home/nikhil/workspace/xeon-fft-bench/src/gpu/runs/gpu_run_9501MHz/20260316_143809/runs/run02/fft_benchmark_gpu_20260316_143823.report.md` |
| run03 | `/home/nikhil/workspace/xeon-fft-bench/src/gpu/runs/gpu_run_9501MHz/20260316_143809/runs/run03/fft_benchmark_gpu_20260316_143835.log` | `/home/nikhil/workspace/xeon-fft-bench/src/gpu/runs/gpu_run_9501MHz/20260316_143809/runs/run03/fft_benchmark_gpu_20260316_143835.report.md` |

## Scenario Catalog

| Profile | Description | Workload | Library | Family |
|---|---|---|---|---|
| gpu_9501MHz | cuFFT cache-no-reuse batch=1 large-N sweep (memory clock at 9501 MHz) | throughput | CUDA_CUFFT | gpu_run_9501MHz |

## Summary Stats

- Rows aggregated: 22
- Quality counts: {'ok': 22}
- Best forward: `n4194304_b1` = 1849.61 GFLOPS (5.02%)
- Best backward: `n524288_b1` = 1841.15 GFLOPS (5.00%)

## Averaged Results

| Workload | Case | N | Batch | ThreadsField | Profile | Avg Fwd ms | Avg Fwd SP GFLOPS | Avg Bwd ms | Avg Bwd SP GFLOPS | Fwd % Peak | Bwd % Peak | Avg Mem MB | Avg Slots | Avg Work MB | Samples | Checks | Quality | Note |
|---|---|---:|---:|---:|---|---:|---:|---:|---:|---:|---:|---:|---:|---:|---|---|---|---|
| throughput | n2_b1 | 2 | 1 | 1 | gpu_9501MHz | 0.001945 | 0.01 | 0.001892 | 0.01 | 0.00% | 0.00% | 8.00 | 262144.0 | 0.00 | 3/3 (skip:0) | 3/3 | ok | - |
| throughput | n4_b1 | 4 | 1 | 1 | gpu_9501MHz | 0.002094 | 0.02 | 0.002079 | 0.02 | 0.00% | 0.00% | 16.00 | 262144.0 | 0.00 | 3/3 (skip:0) | 3/3 | ok | - |
| throughput | n8_b1 | 8 | 1 | 1 | gpu_9501MHz | 0.002245 | 0.05 | 0.002158 | 0.06 | 0.00% | 0.00% | 32.00 | 262144.0 | 0.00 | 3/3 (skip:0) | 3/3 | ok | - |
| throughput | n16_b1 | 16 | 1 | 1 | gpu_9501MHz | 0.002317 | 0.14 | 0.002325 | 0.14 | 0.00% | 0.00% | 64.00 | 262144.0 | 0.00 | 3/3 (skip:0) | 3/3 | ok | - |
| throughput | n32_b1 | 32 | 1 | 1 | gpu_9501MHz | 0.002635 | 0.30 | 0.002631 | 0.30 | 0.00% | 0.00% | 128.00 | 262144.0 | 0.00 | 3/3 (skip:0) | 3/3 | ok | - |
| throughput | n64_b1 | 64 | 1 | 1 | gpu_9501MHz | 0.002616 | 0.73 | 0.002615 | 0.73 | 0.00% | 0.00% | 128.00 | 131072.0 | 0.00 | 3/3 (skip:0) | 3/3 | ok | - |
| throughput | n128_b1 | 128 | 1 | 1 | gpu_9501MHz | 0.002826 | 1.59 | 0.002810 | 1.59 | 0.00% | 0.00% | 128.00 | 65536.0 | 0.00 | 3/3 (skip:0) | 3/3 | ok | - |
| throughput | n256_b1 | 256 | 1 | 1 | gpu_9501MHz | 0.002795 | 3.66 | 0.002808 | 3.65 | 0.01% | 0.01% | 128.00 | 32768.0 | 0.00 | 3/3 (skip:0) | 3/3 | ok | - |
| throughput | n512_b1 | 512 | 1 | 1 | gpu_9501MHz | 0.003190 | 7.22 | 0.003174 | 7.26 | 0.02% | 0.02% | 128.01 | 16384.0 | 0.00 | 3/3 (skip:0) | 3/3 | ok | - |
| throughput | n1024_b1 | 1024 | 1 | 1 | gpu_9501MHz | 0.003539 | 14.47 | 0.003570 | 14.34 | 0.04% | 0.04% | 128.02 | 8192.0 | 0.01 | 3/3 (skip:0) | 3/3 | ok | - |
| throughput | n2048_b1 | 2048 | 1 | 1 | gpu_9501MHz | 0.004415 | 25.51 | 0.004437 | 25.39 | 0.07% | 0.07% | 128.03 | 4096.0 | 0.02 | 3/3 (skip:0) | 3/3 | ok | - |
| throughput | n4096_b1 | 4096 | 1 | 1 | gpu_9501MHz | 0.005025 | 48.90 | 0.005025 | 48.91 | 0.13% | 0.13% | 128.06 | 2048.0 | 0.03 | 3/3 (skip:0) | 3/3 | ok | - |
| throughput | n8192_b1 | 8192 | 1 | 1 | gpu_9501MHz | 0.008481 | 62.79 | 0.008444 | 63.06 | 0.17% | 0.17% | 128.12 | 1024.0 | 0.06 | 3/3 (skip:0) | 3/3 | ok | - |
| throughput | n16384_b1 | 16384 | 1 | 1 | gpu_9501MHz | 0.0106 | 107.90 | 0.0107 | 107.38 | 0.29% | 0.29% | 128.25 | 512.0 | 0.12 | 3/3 (skip:0) | 3/3 | ok | - |
| throughput | n32768_b1 | 32768 | 1 | 1 | gpu_9501MHz | 0.008587 | 286.19 | 0.008589 | 286.12 | 0.78% | 0.78% | 128.50 | 256.0 | 0.25 | 3/3 (skip:0) | 3/3 | ok | - |
| throughput | n65536_b1 | 65536 | 1 | 1 | gpu_9501MHz | 0.008483 | 618.07 | 0.008489 | 617.63 | 1.68% | 1.68% | 129.00 | 128.0 | 0.50 | 3/3 (skip:0) | 3/3 | ok | - |
| throughput | n131072_b1 | 131072 | 1 | 1 | gpu_9501MHz | 0.0109 | 1017.79 | 0.0109 | 1018.01 | 2.76% | 2.76% | 130.00 | 64.0 | 1.00 | 3/3 (skip:0) | 3/3 | ok | - |
| throughput | n262144_b1 | 262144 | 1 | 1 | gpu_9501MHz | 0.0159 | 1484.64 | 0.0158 | 1492.56 | 4.03% | 4.05% | 132.00 | 32.0 | 2.00 | 3/3 (skip:0) | 3/3 | ok | - |
| throughput | n524288_b1 | 524288 | 1 | 1 | gpu_9501MHz | 0.0271 | 1836.46 | 0.0271 | 1841.15 | 4.99% | 5.00% | 136.00 | 16.0 | 4.00 | 3/3 (skip:0) | 3/3 | ok | - |
| throughput | n1048576_b1 | 1048576 | 1 | 1 | gpu_9501MHz | 0.0619 | 1694.12 | 0.0617 | 1698.22 | 4.60% | 4.61% | 144.00 | 8.0 | 8.00 | 3/3 (skip:0) | 3/3 | ok | - |
| throughput | n2097152_b1 | 2097152 | 1 | 1 | gpu_9501MHz | 0.124 | 1782.05 | 0.123 | 1784.77 | 4.84% | 4.85% | 160.00 | 4.0 | 16.00 | 3/3 (skip:0) | 3/3 | ok | - |
| throughput | n4194304_b1 | 4194304 | 1 | 1 | gpu_9501MHz | 0.249 | 1849.61 | 0.252 | 1832.83 | 5.02% | 4.98% | 192.00 | 2.0 | 32.00 | 3/3 (skip:0) | 3/3 | ok | - |

- CSV: `/home/nikhil/workspace/xeon-fft-bench/src/gpu/runs/gpu_run_9501MHz/20260316_143809/latest_run_avg.csv`