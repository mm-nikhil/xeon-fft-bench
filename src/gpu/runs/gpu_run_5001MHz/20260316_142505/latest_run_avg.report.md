# gpu_run_5001MHz (3-run average)

- Generated at: 2026-03-16 14:25:46.424203
- Manifest: `/home/nikhil/workspace/xeon-fft-bench/src/gpu/runs/gpu_run_5001MHz/20260316_142505/manifest.tsv`
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
| run01 | `/home/nikhil/workspace/xeon-fft-bench/src/gpu/runs/gpu_run_5001MHz/20260316_142505/runs/run01/fft_benchmark_gpu_20260316_142506.log` | `/home/nikhil/workspace/xeon-fft-bench/src/gpu/runs/gpu_run_5001MHz/20260316_142505/runs/run01/fft_benchmark_gpu_20260316_142506.report.md` |
| run02 | `/home/nikhil/workspace/xeon-fft-bench/src/gpu/runs/gpu_run_5001MHz/20260316_142505/runs/run02/fft_benchmark_gpu_20260316_142519.log` | `/home/nikhil/workspace/xeon-fft-bench/src/gpu/runs/gpu_run_5001MHz/20260316_142505/runs/run02/fft_benchmark_gpu_20260316_142519.report.md` |
| run03 | `/home/nikhil/workspace/xeon-fft-bench/src/gpu/runs/gpu_run_5001MHz/20260316_142505/runs/run03/fft_benchmark_gpu_20260316_142532.log` | `/home/nikhil/workspace/xeon-fft-bench/src/gpu/runs/gpu_run_5001MHz/20260316_142505/runs/run03/fft_benchmark_gpu_20260316_142532.report.md` |

## Scenario Catalog

| Profile | Description | Workload | Library | Family |
|---|---|---|---|---|
| gpu_5001MHz | cuFFT cache-no-reuse batch=1 large-N sweep (memory clock at 5001 MHz) | throughput | CUDA_CUFFT | gpu_run_5001MHz |

## Summary Stats

- Rows aggregated: 22
- Quality counts: {'ok': 22}
- Best forward: `n524288_b1` = 1160.20 GFLOPS (3.15%)
- Best backward: `n524288_b1` = 1160.77 GFLOPS (3.15%)

## Averaged Results

| Workload | Case | N | Batch | ThreadsField | Profile | Avg Fwd ms | Avg Fwd SP GFLOPS | Avg Bwd ms | Avg Bwd SP GFLOPS | Fwd % Peak | Bwd % Peak | Avg Mem MB | Avg Slots | Avg Work MB | Samples | Checks | Quality | Note |
|---|---|---:|---:|---:|---|---:|---:|---:|---:|---:|---:|---:|---:|---:|---|---|---|---|
| throughput | n2_b1 | 2 | 1 | 1 | gpu_5001MHz | 0.002663 | 0.00 | 0.002654 | 0.00 | 0.00% | 0.00% | 8.00 | 262144.0 | 0.00 | 3/3 (skip:0) | 3/3 | ok | - |
| throughput | n4_b1 | 4 | 1 | 1 | gpu_5001MHz | 0.003029 | 0.01 | 0.003023 | 0.01 | 0.00% | 0.00% | 16.00 | 262144.0 | 0.00 | 3/3 (skip:0) | 3/3 | ok | - |
| throughput | n8_b1 | 8 | 1 | 1 | gpu_5001MHz | 0.003180 | 0.04 | 0.002953 | 0.04 | 0.00% | 0.00% | 32.00 | 262144.0 | 0.00 | 3/3 (skip:0) | 3/3 | ok | - |
| throughput | n16_b1 | 16 | 1 | 1 | gpu_5001MHz | 0.003003 | 0.11 | 0.002982 | 0.11 | 0.00% | 0.00% | 64.00 | 262144.0 | 0.00 | 3/3 (skip:0) | 3/3 | ok | - |
| throughput | n32_b1 | 32 | 1 | 1 | gpu_5001MHz | 0.003551 | 0.23 | 0.003552 | 0.23 | 0.00% | 0.00% | 128.00 | 262144.0 | 0.00 | 3/3 (skip:0) | 3/3 | ok | - |
| throughput | n64_b1 | 64 | 1 | 1 | gpu_5001MHz | 0.003477 | 0.55 | 0.003476 | 0.55 | 0.00% | 0.00% | 128.00 | 131072.0 | 0.00 | 3/3 (skip:0) | 3/3 | ok | - |
| throughput | n128_b1 | 128 | 1 | 1 | gpu_5001MHz | 0.003825 | 1.17 | 0.003822 | 1.17 | 0.00% | 0.00% | 128.00 | 65536.0 | 0.00 | 3/3 (skip:0) | 3/3 | ok | - |
| throughput | n256_b1 | 256 | 1 | 1 | gpu_5001MHz | 0.003621 | 2.83 | 0.003603 | 2.84 | 0.01% | 0.01% | 128.00 | 32768.0 | 0.00 | 3/3 (skip:0) | 3/3 | ok | - |
| throughput | n512_b1 | 512 | 1 | 1 | gpu_5001MHz | 0.004156 | 5.54 | 0.004157 | 5.54 | 0.02% | 0.02% | 128.01 | 16384.0 | 0.00 | 3/3 (skip:0) | 3/3 | ok | - |
| throughput | n1024_b1 | 1024 | 1 | 1 | gpu_5001MHz | 0.004455 | 11.49 | 0.004455 | 11.49 | 0.03% | 0.03% | 128.02 | 8192.0 | 0.01 | 3/3 (skip:0) | 3/3 | ok | - |
| throughput | n2048_b1 | 2048 | 1 | 1 | gpu_5001MHz | 0.005358 | 21.02 | 0.005327 | 21.15 | 0.06% | 0.06% | 128.03 | 4096.0 | 0.02 | 3/3 (skip:0) | 3/3 | ok | - |
| throughput | n4096_b1 | 4096 | 1 | 1 | gpu_5001MHz | 0.005941 | 41.37 | 0.005945 | 41.34 | 0.11% | 0.11% | 128.06 | 2048.0 | 0.03 | 3/3 (skip:0) | 3/3 | ok | - |
| throughput | n8192_b1 | 8192 | 1 | 1 | gpu_5001MHz | 0.009463 | 56.27 | 0.009360 | 56.89 | 0.15% | 0.15% | 128.12 | 1024.0 | 0.06 | 3/3 (skip:0) | 3/3 | ok | - |
| throughput | n16384_b1 | 16384 | 1 | 1 | gpu_5001MHz | 0.0124 | 92.65 | 0.0124 | 92.80 | 0.25% | 0.25% | 128.25 | 512.0 | 0.12 | 3/3 (skip:0) | 3/3 | ok | - |
| throughput | n32768_b1 | 32768 | 1 | 1 | gpu_5001MHz | 0.0105 | 234.47 | 0.0106 | 232.45 | 0.64% | 0.63% | 128.50 | 256.0 | 0.25 | 3/3 (skip:0) | 3/3 | ok | - |
| throughput | n65536_b1 | 65536 | 1 | 1 | gpu_5001MHz | 0.0110 | 478.70 | 0.0109 | 483.19 | 1.30% | 1.31% | 129.00 | 128.0 | 0.50 | 3/3 (skip:0) | 3/3 | ok | - |
| throughput | n131072_b1 | 131072 | 1 | 1 | gpu_5001MHz | 0.0142 | 786.32 | 0.0142 | 786.04 | 2.14% | 2.13% | 130.00 | 64.0 | 1.00 | 3/3 (skip:0) | 3/3 | ok | - |
| throughput | n262144_b1 | 262144 | 1 | 1 | gpu_5001MHz | 0.0235 | 1005.27 | 0.0234 | 1007.00 | 2.73% | 2.74% | 132.00 | 32.0 | 2.00 | 3/3 (skip:0) | 3/3 | ok | - |
| throughput | n524288_b1 | 524288 | 1 | 1 | gpu_5001MHz | 0.0429 | 1160.20 | 0.0429 | 1160.77 | 3.15% | 3.15% | 136.00 | 16.0 | 4.00 | 3/3 (skip:0) | 3/3 | ok | - |
| throughput | n1048576_b1 | 1048576 | 1 | 1 | gpu_5001MHz | 0.0992 | 1057.33 | 0.0991 | 1057.92 | 2.87% | 2.87% | 144.00 | 8.0 | 8.00 | 3/3 (skip:0) | 3/3 | ok | - |
| throughput | n2097152_b1 | 2097152 | 1 | 1 | gpu_5001MHz | 0.199 | 1107.43 | 0.199 | 1106.29 | 3.01% | 3.00% | 160.00 | 4.0 | 16.00 | 3/3 (skip:0) | 3/3 | ok | - |
| throughput | n4194304_b1 | 4194304 | 1 | 1 | gpu_5001MHz | 0.399 | 1154.92 | 0.398 | 1159.80 | 3.14% | 3.15% | 192.00 | 2.0 | 32.00 | 3/3 (skip:0) | 3/3 | ok | - |

- CSV: `/home/nikhil/workspace/xeon-fft-bench/src/gpu/runs/gpu_run_5001MHz/20260316_142505/latest_run_avg.csv`