# run_gpu_810MHz (3-run average)

- Generated at: 2026-03-16 14:05:41.757007
- Manifest: `/home/nikhil/workspace/xeon-fft-bench/src/gpu/runs/run_gpu_810MHz/20260316_140459/manifest.tsv`
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
- `THROUGHPUT_LENGTHS` = `1,2,4,8,16,32,64,128,256,512,1024,2048,4096,8192,16384,32768,65536,131072,262144,524288,1048576,2097152,4194304`

## Run Files

| Run | Log | Report |
|---|---|---|
| run01 | `/home/nikhil/workspace/xeon-fft-bench/src/gpu/runs/run_gpu_810MHz/20260316_140459/runs/run01/fft_benchmark_gpu_20260316_140500.log` | `/home/nikhil/workspace/xeon-fft-bench/src/gpu/runs/run_gpu_810MHz/20260316_140459/runs/run01/fft_benchmark_gpu_20260316_140500.report.md` |
| run02 | `/home/nikhil/workspace/xeon-fft-bench/src/gpu/runs/run_gpu_810MHz/20260316_140459/runs/run02/fft_benchmark_gpu_20260316_140514.log` | `/home/nikhil/workspace/xeon-fft-bench/src/gpu/runs/run_gpu_810MHz/20260316_140459/runs/run02/fft_benchmark_gpu_20260316_140514.report.md` |
| run03 | `/home/nikhil/workspace/xeon-fft-bench/src/gpu/runs/run_gpu_810MHz/20260316_140459/runs/run03/fft_benchmark_gpu_20260316_140527.log` | `/home/nikhil/workspace/xeon-fft-bench/src/gpu/runs/run_gpu_810MHz/20260316_140459/runs/run03/fft_benchmark_gpu_20260316_140527.report.md` |

## Scenario Catalog

| Profile | Description | Workload | Library | Family |
|---|---|---|---|---|
| gpu_810MHz | cuFFT cache-no-reuse batch=1 large-N sweep (memory clock locked to 810 MHz) | throughput | CUDA_CUFFT | run_gpu_810MHz |

## Summary Stats

- Rows aggregated: 23
- Quality counts: {'ok': 23}
- Best forward: `n131072_b1` = 217.48 GFLOPS (0.59%)
- Best backward: `n131072_b1` = 217.09 GFLOPS (0.59%)

## Averaged Results

| Workload | Case | N | Batch | ThreadsField | Profile | Avg Fwd ms | Avg Fwd SP GFLOPS | Avg Bwd ms | Avg Bwd SP GFLOPS | Fwd % Peak | Bwd % Peak | Avg Mem MB | Avg Slots | Avg Work MB | Samples | Checks | Quality | Note |
|---|---|---:|---:|---:|---|---:|---:|---:|---:|---:|---:|---:|---:|---:|---|---|---|---|
| throughput | n1_b1 | 1 | 1 | 1 | gpu_810MHz | 0.002673 | 0.00 | 0.002672 | 0.00 | 0.00% | 0.00% | 4.00 | 262144.0 | 0.00 | 3/3 (skip:0) | 3/3 | ok | - |
| throughput | n2_b1 | 2 | 1 | 1 | gpu_810MHz | 0.002672 | 0.00 | 0.002678 | 0.00 | 0.00% | 0.00% | 8.00 | 262144.0 | 0.00 | 3/3 (skip:0) | 3/3 | ok | - |
| throughput | n4_b1 | 4 | 1 | 1 | gpu_810MHz | 0.003403 | 0.01 | 0.003104 | 0.01 | 0.00% | 0.00% | 16.00 | 262144.0 | 0.00 | 3/3 (skip:0) | 3/3 | ok | - |
| throughput | n8_b1 | 8 | 1 | 1 | gpu_810MHz | 0.003681 | 0.03 | 0.003112 | 0.04 | 0.00% | 0.00% | 32.00 | 262144.0 | 0.00 | 3/3 (skip:0) | 3/3 | ok | - |
| throughput | n16_b1 | 16 | 1 | 1 | gpu_810MHz | 0.003744 | 0.09 | 0.003148 | 0.10 | 0.00% | 0.00% | 64.00 | 262144.0 | 0.00 | 3/3 (skip:0) | 3/3 | ok | - |
| throughput | n32_b1 | 32 | 1 | 1 | gpu_810MHz | 0.004342 | 0.18 | 0.004342 | 0.18 | 0.00% | 0.00% | 128.00 | 262144.0 | 0.00 | 3/3 (skip:0) | 3/3 | ok | - |
| throughput | n64_b1 | 64 | 1 | 1 | gpu_810MHz | 0.004295 | 0.45 | 0.004296 | 0.45 | 0.00% | 0.00% | 128.00 | 131072.0 | 0.00 | 3/3 (skip:0) | 3/3 | ok | - |
| throughput | n128_b1 | 128 | 1 | 1 | gpu_810MHz | 0.004675 | 0.96 | 0.004675 | 0.96 | 0.00% | 0.00% | 128.00 | 65536.0 | 0.00 | 3/3 (skip:0) | 3/3 | ok | - |
| throughput | n256_b1 | 256 | 1 | 1 | gpu_810MHz | 0.004679 | 2.19 | 0.004674 | 2.19 | 0.01% | 0.01% | 128.00 | 32768.0 | 0.00 | 3/3 (skip:0) | 3/3 | ok | - |
| throughput | n512_b1 | 512 | 1 | 1 | gpu_810MHz | 0.005159 | 4.47 | 0.005154 | 4.47 | 0.01% | 0.01% | 128.01 | 16384.0 | 0.00 | 3/3 (skip:0) | 3/3 | ok | - |
| throughput | n1024_b1 | 1024 | 1 | 1 | gpu_810MHz | 0.005646 | 9.07 | 0.005646 | 9.07 | 0.02% | 0.02% | 128.02 | 8192.0 | 0.01 | 3/3 (skip:0) | 3/3 | ok | - |
| throughput | n2048_b1 | 2048 | 1 | 1 | gpu_810MHz | 0.006315 | 17.84 | 0.006314 | 17.84 | 0.05% | 0.05% | 128.03 | 4096.0 | 0.02 | 3/3 (skip:0) | 3/3 | ok | - |
| throughput | n4096_b1 | 4096 | 1 | 1 | gpu_810MHz | 0.008028 | 30.61 | 0.008021 | 30.64 | 0.08% | 0.08% | 128.06 | 2048.0 | 0.03 | 3/3 (skip:0) | 3/3 | ok | - |
| throughput | n8192_b1 | 8192 | 1 | 1 | gpu_810MHz | 0.0127 | 42.07 | 0.0126 | 42.15 | 0.11% | 0.11% | 128.12 | 1024.0 | 0.06 | 3/3 (skip:0) | 3/3 | ok | - |
| throughput | n16384_b1 | 16384 | 1 | 1 | gpu_810MHz | 0.0169 | 67.95 | 0.0168 | 68.40 | 0.18% | 0.19% | 128.25 | 512.0 | 0.12 | 3/3 (skip:0) | 3/3 | ok | - |
| throughput | n32768_b1 | 32768 | 1 | 1 | gpu_810MHz | 0.0178 | 138.35 | 0.0177 | 138.57 | 0.38% | 0.38% | 128.50 | 256.0 | 0.25 | 3/3 (skip:0) | 3/3 | ok | - |
| throughput | n65536_b1 | 65536 | 1 | 1 | gpu_810MHz | 0.0278 | 188.55 | 0.0277 | 189.28 | 0.51% | 0.51% | 129.00 | 128.0 | 0.50 | 3/3 (skip:0) | 3/3 | ok | - |
| throughput | n131072_b1 | 131072 | 1 | 1 | gpu_810MHz | 0.0512 | 217.48 | 0.0513 | 217.09 | 0.59% | 0.59% | 130.00 | 64.0 | 1.00 | 3/3 (skip:0) | 3/3 | ok | - |
| throughput | n262144_b1 | 262144 | 1 | 1 | gpu_810MHz | 0.120 | 197.35 | 0.119 | 197.73 | 0.54% | 0.54% | 132.00 | 32.0 | 2.00 | 3/3 (skip:0) | 3/3 | ok | - |
| throughput | n524288_b1 | 524288 | 1 | 1 | gpu_810MHz | 0.243 | 204.76 | 0.243 | 204.75 | 0.56% | 0.56% | 136.00 | 16.0 | 4.00 | 3/3 (skip:0) | 3/3 | ok | - |
| throughput | n1048576_b1 | 1048576 | 1 | 1 | gpu_810MHz | 0.639 | 164.02 | 0.644 | 162.92 | 0.45% | 0.44% | 144.00 | 8.0 | 8.00 | 3/3 (skip:0) | 3/3 | ok | - |
| throughput | n2097152_b1 | 2097152 | 1 | 1 | gpu_810MHz | 1.310 | 168.08 | 1.310 | 168.04 | 0.46% | 0.46% | 160.00 | 4.0 | 16.00 | 3/3 (skip:0) | 3/3 | ok | - |
| throughput | n4194304_b1 | 4194304 | 1 | 1 | gpu_810MHz | 2.638 | 174.92 | 2.624 | 175.80 | 0.48% | 0.48% | 192.00 | 2.0 | 32.00 | 3/3 (skip:0) | 3/3 | ok | - |

- CSV: `/home/nikhil/workspace/xeon-fft-bench/src/gpu/runs/run_gpu_810MHz/20260316_140459/latest_run_avg.csv`