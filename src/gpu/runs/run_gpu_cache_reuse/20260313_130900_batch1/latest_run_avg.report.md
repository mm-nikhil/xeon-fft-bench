# run_gpu_cache_reuse (3-run average)

- Generated at: 2026-03-13 12:38:49.207162
- Manifest: `/home/nikhil/workspace/xeon-fft-bench/src/gpu/runs/run_gpu_cache_reuse/20260313_130900_batch1/manifest.tsv`
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
- `THROUGHPUT_BATCHES` = `1`
- `THROUGHPUT_LENGTHS` = `2,4,8,16,32,64,128,256,512,1024,2048,4096,8192,16384,32768,65536`

## Run Files

| Run | Log | Report |
|---|---|---|
| run01 | `/home/nikhil/workspace/xeon-fft-bench/src/gpu/runs/run_gpu_cache_reuse/20260313_130900_batch1/runs/run01/fft_benchmark_gpu_20260313_123835.log` | `/home/nikhil/workspace/xeon-fft-bench/src/gpu/runs/run_gpu_cache_reuse/20260313_130900_batch1/runs/run01/fft_benchmark_gpu_20260313_123835.report.md` |
| run02 | `/home/nikhil/workspace/xeon-fft-bench/src/gpu/runs/run_gpu_cache_reuse/20260313_130900_batch1/runs/run02/fft_benchmark_gpu_20260313_123839.log` | `/home/nikhil/workspace/xeon-fft-bench/src/gpu/runs/run_gpu_cache_reuse/20260313_130900_batch1/runs/run02/fft_benchmark_gpu_20260313_123839.report.md` |
| run03 | `/home/nikhil/workspace/xeon-fft-bench/src/gpu/runs/run_gpu_cache_reuse/20260313_130900_batch1/runs/run03/fft_benchmark_gpu_20260313_123844.log` | `/home/nikhil/workspace/xeon-fft-bench/src/gpu/runs/run_gpu_cache_reuse/20260313_130900_batch1/runs/run03/fft_benchmark_gpu_20260313_123844.report.md` |

## Scenario Catalog

| Profile | Description | Workload | Library | Family |
|---|---|---|---|---|
| gpu_cache_reuse | cuFFT cache-reuse (hot device-buffer reuse) | throughput | CUDA_CUFFT | run_gpu_cache_reuse |

## Summary Stats

- Rows aggregated: 16
- Quality counts: {'ok': 16}
- Best forward: `n65536_b1` = 815.17 GFLOPS (2.21%)
- Best backward: `n65536_b1` = 813.90 GFLOPS (2.21%)

## Averaged Results

| Workload | Case | N | Batch | ThreadsField | Profile | Avg Fwd ms | Avg Fwd SP GFLOPS | Avg Bwd ms | Avg Bwd SP GFLOPS | Fwd % Peak | Bwd % Peak | Avg Mem MB | Avg Slots | Avg Work MB | Samples | Checks | Quality | Note |
|---|---|---:|---:|---:|---|---:|---:|---:|---:|---:|---:|---:|---:|---:|---|---|---|---|
| throughput | n2_b1 | 2 | 1 | 1 | gpu_cache_reuse | 0.001802 | 0.01 | 0.001786 | 0.01 | 0.00% | 0.00% | 0.00 | 1.0 | 0.00 | 3/3 (skip:0) | 3/3 | ok | - |
| throughput | n4_b1 | 4 | 1 | 1 | gpu_cache_reuse | 0.001783 | 0.02 | 0.001769 | 0.02 | 0.00% | 0.00% | 0.00 | 1.0 | 0.00 | 3/3 (skip:0) | 3/3 | ok | - |
| throughput | n8_b1 | 8 | 1 | 1 | gpu_cache_reuse | 0.001791 | 0.07 | 0.001790 | 0.07 | 0.00% | 0.00% | 0.00 | 1.0 | 0.00 | 3/3 (skip:0) | 3/3 | ok | - |
| throughput | n16_b1 | 16 | 1 | 1 | gpu_cache_reuse | 0.001809 | 0.18 | 0.001809 | 0.18 | 0.00% | 0.00% | 0.00 | 1.0 | 0.00 | 3/3 (skip:0) | 3/3 | ok | - |
| throughput | n32_b1 | 32 | 1 | 1 | gpu_cache_reuse | 0.002028 | 0.39 | 0.002027 | 0.39 | 0.00% | 0.00% | 0.00 | 1.0 | 0.00 | 3/3 (skip:0) | 3/3 | ok | - |
| throughput | n64_b1 | 64 | 1 | 1 | gpu_cache_reuse | 0.002023 | 0.95 | 0.002023 | 0.95 | 0.00% | 0.00% | 0.00 | 1.0 | 0.00 | 3/3 (skip:0) | 3/3 | ok | - |
| throughput | n128_b1 | 128 | 1 | 1 | gpu_cache_reuse | 0.002166 | 2.07 | 0.002166 | 2.07 | 0.01% | 0.01% | 0.00 | 1.0 | 0.00 | 3/3 (skip:0) | 3/3 | ok | - |
| throughput | n256_b1 | 256 | 1 | 1 | gpu_cache_reuse | 0.002306 | 4.44 | 0.002306 | 4.44 | 0.01% | 0.01% | 0.01 | 1.0 | 0.00 | 3/3 (skip:0) | 3/3 | ok | - |
| throughput | n512_b1 | 512 | 1 | 1 | gpu_cache_reuse | 0.002591 | 8.89 | 0.002591 | 8.89 | 0.02% | 0.02% | 0.02 | 1.0 | 0.00 | 3/3 (skip:0) | 3/3 | ok | - |
| throughput | n1024_b1 | 1024 | 1 | 1 | gpu_cache_reuse | 0.002873 | 17.82 | 0.002874 | 17.82 | 0.05% | 0.05% | 0.03 | 1.0 | 0.01 | 3/3 (skip:0) | 3/3 | ok | - |
| throughput | n2048_b1 | 2048 | 1 | 1 | gpu_cache_reuse | 0.003715 | 30.32 | 0.003722 | 30.26 | 0.08% | 0.08% | 0.06 | 1.0 | 0.02 | 3/3 (skip:0) | 3/3 | ok | - |
| throughput | n4096_b1 | 4096 | 1 | 1 | gpu_cache_reuse | 0.004147 | 59.26 | 0.004147 | 59.26 | 0.16% | 0.16% | 0.12 | 1.0 | 0.03 | 3/3 (skip:0) | 3/3 | ok | - |
| throughput | n8192_b1 | 8192 | 1 | 1 | gpu_cache_reuse | 0.007128 | 74.70 | 0.007122 | 74.77 | 0.20% | 0.20% | 0.25 | 1.0 | 0.06 | 3/3 (skip:0) | 3/3 | ok | - |
| throughput | n16384_b1 | 16384 | 1 | 1 | gpu_cache_reuse | 0.008872 | 129.27 | 0.008874 | 129.25 | 0.35% | 0.35% | 0.50 | 1.0 | 0.12 | 3/3 (skip:0) | 3/3 | ok | - |
| throughput | n32768_b1 | 32768 | 1 | 1 | gpu_cache_reuse | 0.007059 | 348.17 | 0.007058 | 348.20 | 0.95% | 0.95% | 1.00 | 1.0 | 0.25 | 3/3 (skip:0) | 3/3 | ok | - |
| throughput | n65536_b1 | 65536 | 1 | 1 | gpu_cache_reuse | 0.006432 | 815.17 | 0.006442 | 813.90 | 2.21% | 2.21% | 2.00 | 1.0 | 0.50 | 3/3 (skip:0) | 3/3 | ok | - |

- CSV: `/home/nikhil/workspace/xeon-fft-bench/src/gpu/runs/run_gpu_cache_reuse/20260313_130900_batch1/latest_run_avg.csv`