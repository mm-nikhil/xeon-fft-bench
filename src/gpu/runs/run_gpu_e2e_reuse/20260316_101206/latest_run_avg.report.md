# run_gpu_e2e_reuse (3-run average)

- Generated at: 2026-03-16 10:13:25.626425
- Manifest: `/home/nikhil/workspace/xeon-fft-bench/src/gpu/runs/run_gpu_e2e_reuse/20260316_101206/manifest.tsv`
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

- `BENCH_HOST_BUFFER_MODE` = `pinned`
- `BENCH_MAX_ADAPT_ITERS` = `100000000`
- `BENCH_MAX_MEM_MB` = `8192`
- `BENCH_MIN_TOTAL_MS` = `50`
- `BENCH_NRUNS` = `20`
- `BENCH_STREAM_MAX_SLOTS` = `1`
- `BENCH_STREAM_MIN_SLOTS` = `1`
- `BENCH_STREAM_MODE` = `0`
- `BENCH_STREAM_TARGET_MB` = `0`
- `BENCH_TIMING_SCOPE` = `e2e_pcie`
- `BENCH_VALIDATE` = `1`
- `BENCH_VALIDATE_STRICT` = `1`
- `BENCH_VALIDATE_TOL` = `1e-4`
- `BENCH_WARMUP` = `5`
- `THROUGHPUT_BATCHES` = `1,10,16,150,256,1024`
- `THROUGHPUT_LENGTHS` = `2,4,8,16,32,64,128,256,512,1024,2048,4096,8192,16384,32768,65536`

## Run Files

| Run | Log | Report |
|---|---|---|
| run01 | `/home/nikhil/workspace/xeon-fft-bench/src/gpu/runs/run_gpu_e2e_reuse/20260316_101206/runs/run01/fft_benchmark_gpu_20260316_101207.log` | `/home/nikhil/workspace/xeon-fft-bench/src/gpu/runs/run_gpu_e2e_reuse/20260316_101206/runs/run01/fft_benchmark_gpu_20260316_101207.report.md` |
| run02 | `/home/nikhil/workspace/xeon-fft-bench/src/gpu/runs/run_gpu_e2e_reuse/20260316_101206/runs/run02/fft_benchmark_gpu_20260316_101234.log` | `/home/nikhil/workspace/xeon-fft-bench/src/gpu/runs/run_gpu_e2e_reuse/20260316_101206/runs/run02/fft_benchmark_gpu_20260316_101234.report.md` |
| run03 | `/home/nikhil/workspace/xeon-fft-bench/src/gpu/runs/run_gpu_e2e_reuse/20260316_101206/runs/run03/fft_benchmark_gpu_20260316_101259.log` | `/home/nikhil/workspace/xeon-fft-bench/src/gpu/runs/run_gpu_e2e_reuse/20260316_101206/runs/run03/fft_benchmark_gpu_20260316_101259.report.md` |

## Scenario Catalog

| Profile | Description | Workload | Library | Family |
|---|---|---|---|---|
| gpu_e2e_reuse | cuFFT end-to-end cache-reuse (H2D + FFT + D2H on pinned host buffers) | throughput | CUDA_CUFFT | run_gpu_e2e_reuse |

## Summary Stats

- Rows aggregated: 96
- Quality counts: {'ok': 96}
- Best forward: `n65536_b256` = 120.37 GFLOPS (0.33%)
- Best backward: `n65536_b256` = 120.45 GFLOPS (0.33%)

## Averaged Results

| Workload | Case | N | Batch | ThreadsField | Profile | Avg Fwd ms | Avg Fwd SP GFLOPS | Avg Bwd ms | Avg Bwd SP GFLOPS | Fwd % Peak | Bwd % Peak | Avg Mem MB | Avg Slots | Avg Work MB | Samples | Checks | Quality | Note |
|---|---|---:|---:|---:|---|---:|---:|---:|---:|---:|---:|---:|---:|---:|---|---|---|---|
| throughput | n2_b1 | 2 | 1 | 1 | gpu_e2e_reuse | 0.005384 | 0.00 | 0.005515 | 0.00 | 0.00% | 0.00% | 0.00 | 1.0 | 0.00 | 3/3 (skip:0) | 3/3 | ok | - |
| throughput | n2_b10 | 2 | 10 | 1 | gpu_e2e_reuse | 0.005470 | 0.02 | 0.005573 | 0.02 | 0.00% | 0.00% | 0.00 | 1.0 | 0.00 | 3/3 (skip:0) | 3/3 | ok | - |
| throughput | n2_b16 | 2 | 16 | 1 | gpu_e2e_reuse | 0.005941 | 0.03 | 0.005893 | 0.03 | 0.00% | 0.00% | 0.00 | 1.0 | 0.00 | 3/3 (skip:0) | 3/3 | ok | - |
| throughput | n2_b150 | 2 | 150 | 1 | gpu_e2e_reuse | 0.0150 | 0.10 | 0.0149 | 0.10 | 0.00% | 0.00% | 0.01 | 1.0 | 0.00 | 3/3 (skip:0) | 3/3 | ok | - |
| throughput | n2_b256 | 2 | 256 | 1 | gpu_e2e_reuse | 0.0148 | 0.17 | 0.0151 | 0.17 | 0.00% | 0.00% | 0.02 | 1.0 | 0.00 | 3/3 (skip:0) | 3/3 | ok | - |
| throughput | n2_b1024 | 2 | 1024 | 1 | gpu_e2e_reuse | 0.0174 | 0.59 | 0.0170 | 0.60 | 0.00% | 0.00% | 0.08 | 1.0 | 0.02 | 3/3 (skip:0) | 3/3 | ok | - |
| throughput | n4_b1 | 4 | 1 | 1 | gpu_e2e_reuse | 0.006604 | 0.01 | 0.006580 | 0.01 | 0.00% | 0.00% | 0.00 | 1.0 | 0.00 | 3/3 (skip:0) | 3/3 | ok | - |
| throughput | n4_b10 | 4 | 10 | 1 | gpu_e2e_reuse | 0.007505 | 0.05 | 0.007307 | 0.05 | 0.00% | 0.00% | 0.00 | 1.0 | 0.00 | 3/3 (skip:0) | 3/3 | ok | - |
| throughput | n4_b16 | 4 | 16 | 1 | gpu_e2e_reuse | 0.007864 | 0.08 | 0.007710 | 0.08 | 0.00% | 0.00% | 0.00 | 1.0 | 0.00 | 3/3 (skip:0) | 3/3 | ok | - |
| throughput | n4_b150 | 4 | 150 | 1 | gpu_e2e_reuse | 0.0157 | 0.38 | 0.0152 | 0.39 | 0.00% | 0.00% | 0.02 | 1.0 | 0.00 | 3/3 (skip:0) | 3/3 | ok | - |
| throughput | n4_b256 | 4 | 256 | 1 | gpu_e2e_reuse | 0.0138 | 0.74 | 0.0147 | 0.70 | 0.00% | 0.00% | 0.04 | 1.0 | 0.01 | 3/3 (skip:0) | 3/3 | ok | - |
| throughput | n4_b1024 | 4 | 1024 | 1 | gpu_e2e_reuse | 0.0181 | 2.27 | 0.0180 | 2.28 | 0.01% | 0.01% | 0.16 | 1.0 | 0.03 | 3/3 (skip:0) | 3/3 | ok | - |
| throughput | n8_b1 | 8 | 1 | 1 | gpu_e2e_reuse | 0.006919 | 0.02 | 0.006870 | 0.02 | 0.00% | 0.00% | 0.00 | 1.0 | 0.00 | 3/3 (skip:0) | 3/3 | ok | - |
| throughput | n8_b10 | 8 | 10 | 1 | gpu_e2e_reuse | 0.007793 | 0.15 | 0.007945 | 0.15 | 0.00% | 0.00% | 0.00 | 1.0 | 0.00 | 3/3 (skip:0) | 3/3 | ok | - |
| throughput | n8_b16 | 8 | 16 | 1 | gpu_e2e_reuse | 0.007834 | 0.25 | 0.007886 | 0.24 | 0.00% | 0.00% | 0.00 | 1.0 | 0.00 | 3/3 (skip:0) | 3/3 | ok | - |
| throughput | n8_b150 | 8 | 150 | 1 | gpu_e2e_reuse | 0.0155 | 1.16 | 0.0155 | 1.16 | 0.00% | 0.00% | 0.05 | 1.0 | 0.01 | 3/3 (skip:0) | 3/3 | ok | - |
| throughput | n8_b256 | 8 | 256 | 1 | gpu_e2e_reuse | 0.0177 | 1.73 | 0.0173 | 1.77 | 0.00% | 0.00% | 0.08 | 1.0 | 0.02 | 3/3 (skip:0) | 3/3 | ok | - |
| throughput | n8_b1024 | 8 | 1024 | 1 | gpu_e2e_reuse | 0.0214 | 5.74 | 0.0201 | 6.12 | 0.02% | 0.02% | 0.31 | 1.0 | 0.06 | 3/3 (skip:0) | 3/3 | ok | - |
| throughput | n16_b1 | 16 | 1 | 1 | gpu_e2e_reuse | 0.007588 | 0.04 | 0.007459 | 0.04 | 0.00% | 0.00% | 0.00 | 1.0 | 0.00 | 3/3 (skip:0) | 3/3 | ok | - |
| throughput | n16_b10 | 16 | 10 | 1 | gpu_e2e_reuse | 0.0154 | 0.21 | 0.0159 | 0.20 | 0.00% | 0.00% | 0.01 | 1.0 | 0.00 | 3/3 (skip:0) | 3/3 | ok | - |
| throughput | n16_b16 | 16 | 16 | 1 | gpu_e2e_reuse | 0.0158 | 0.33 | 0.0157 | 0.33 | 0.00% | 0.00% | 0.01 | 1.0 | 0.00 | 3/3 (skip:0) | 3/3 | ok | - |
| throughput | n16_b150 | 16 | 150 | 1 | gpu_e2e_reuse | 0.0175 | 2.74 | 0.0172 | 2.79 | 0.01% | 0.01% | 0.09 | 1.0 | 0.02 | 3/3 (skip:0) | 3/3 | ok | - |
| throughput | n16_b256 | 16 | 256 | 1 | gpu_e2e_reuse | 0.0189 | 4.35 | 0.0191 | 4.29 | 0.01% | 0.01% | 0.16 | 1.0 | 0.03 | 3/3 (skip:0) | 3/3 | ok | - |
| throughput | n16_b1024 | 16 | 1024 | 1 | gpu_e2e_reuse | 0.0254 | 12.90 | 0.0266 | 12.33 | 0.04% | 0.03% | 0.62 | 1.0 | 0.12 | 3/3 (skip:0) | 3/3 | ok | - |
| throughput | n32_b1 | 32 | 1 | 1 | gpu_e2e_reuse | 0.007728 | 0.10 | 0.007868 | 0.10 | 0.00% | 0.00% | 0.00 | 1.0 | 0.00 | 3/3 (skip:0) | 3/3 | ok | - |
| throughput | n32_b10 | 32 | 10 | 1 | gpu_e2e_reuse | 0.0158 | 0.51 | 0.0156 | 0.51 | 0.00% | 0.00% | 0.01 | 1.0 | 0.00 | 3/3 (skip:0) | 3/3 | ok | - |
| throughput | n32_b16 | 32 | 16 | 1 | gpu_e2e_reuse | 0.0157 | 0.82 | 0.0158 | 0.81 | 0.00% | 0.00% | 0.02 | 1.0 | 0.00 | 3/3 (skip:0) | 3/3 | ok | - |
| throughput | n32_b150 | 32 | 150 | 1 | gpu_e2e_reuse | 0.0193 | 6.23 | 0.0191 | 6.28 | 0.02% | 0.02% | 0.18 | 1.0 | 0.04 | 3/3 (skip:0) | 3/3 | ok | - |
| throughput | n32_b256 | 32 | 256 | 1 | gpu_e2e_reuse | 0.0227 | 9.02 | 0.0217 | 9.43 | 0.02% | 0.03% | 0.31 | 1.0 | 0.06 | 3/3 (skip:0) | 3/3 | ok | - |
| throughput | n32_b1024 | 32 | 1024 | 1 | gpu_e2e_reuse | 0.0368 | 22.29 | 0.0364 | 22.49 | 0.06% | 0.06% | 1.25 | 1.0 | 0.25 | 3/3 (skip:0) | 3/3 | ok | - |
| throughput | n64_b1 | 64 | 1 | 1 | gpu_e2e_reuse | 0.007748 | 0.25 | 0.007802 | 0.25 | 0.00% | 0.00% | 0.00 | 1.0 | 0.00 | 3/3 (skip:0) | 3/3 | ok | - |
| throughput | n64_b10 | 64 | 10 | 1 | gpu_e2e_reuse | 0.0159 | 1.21 | 0.0156 | 1.23 | 0.00% | 0.00% | 0.02 | 1.0 | 0.00 | 3/3 (skip:0) | 3/3 | ok | - |
| throughput | n64_b16 | 64 | 16 | 1 | gpu_e2e_reuse | 0.0162 | 1.90 | 0.0162 | 1.90 | 0.01% | 0.01% | 0.04 | 1.0 | 0.01 | 3/3 (skip:0) | 3/3 | ok | - |
| throughput | n64_b150 | 64 | 150 | 1 | gpu_e2e_reuse | 0.0214 | 13.46 | 0.0223 | 12.92 | 0.04% | 0.04% | 0.37 | 1.0 | 0.07 | 3/3 (skip:0) | 3/3 | ok | - |
| throughput | n64_b256 | 64 | 256 | 1 | gpu_e2e_reuse | 0.0255 | 19.31 | 0.0259 | 18.94 | 0.05% | 0.05% | 0.62 | 1.0 | 0.12 | 3/3 (skip:0) | 3/3 | ok | - |
| throughput | n64_b1024 | 64 | 1024 | 1 | gpu_e2e_reuse | 0.0570 | 34.50 | 0.0569 | 34.54 | 0.09% | 0.09% | 2.50 | 1.0 | 0.50 | 3/3 (skip:0) | 3/3 | ok | - |
| throughput | n128_b1 | 128 | 1 | 1 | gpu_e2e_reuse | 0.007835 | 0.57 | 0.007844 | 0.57 | 0.00% | 0.00% | 0.00 | 1.0 | 0.00 | 3/3 (skip:0) | 3/3 | ok | - |
| throughput | n128_b10 | 128 | 10 | 1 | gpu_e2e_reuse | 0.0159 | 2.82 | 0.0159 | 2.81 | 0.01% | 0.01% | 0.05 | 1.0 | 0.01 | 3/3 (skip:0) | 3/3 | ok | - |
| throughput | n128_b16 | 128 | 16 | 1 | gpu_e2e_reuse | 0.0176 | 4.07 | 0.0175 | 4.08 | 0.01% | 0.01% | 0.08 | 1.0 | 0.02 | 3/3 (skip:0) | 3/3 | ok | - |
| throughput | n128_b150 | 128 | 150 | 1 | gpu_e2e_reuse | 0.0281 | 23.91 | 0.0291 | 23.10 | 0.06% | 0.06% | 0.73 | 1.0 | 0.15 | 3/3 (skip:0) | 3/3 | ok | - |
| throughput | n128_b256 | 128 | 256 | 1 | gpu_e2e_reuse | 0.0368 | 31.17 | 0.0366 | 31.33 | 0.08% | 0.09% | 1.25 | 1.0 | 0.25 | 3/3 (skip:0) | 3/3 | ok | - |
| throughput | n128_b1024 | 128 | 1024 | 1 | gpu_e2e_reuse | 0.0986 | 46.51 | 0.0972 | 47.17 | 0.13% | 0.13% | 5.00 | 1.0 | 1.00 | 3/3 (skip:0) | 3/3 | ok | - |
| throughput | n256_b1 | 256 | 1 | 1 | gpu_e2e_reuse | 0.0155 | 0.66 | 0.0161 | 0.63 | 0.00% | 0.00% | 0.01 | 1.0 | 0.00 | 3/3 (skip:0) | 3/3 | ok | - |
| throughput | n256_b10 | 256 | 10 | 1 | gpu_e2e_reuse | 0.0173 | 5.93 | 0.0179 | 5.72 | 0.02% | 0.02% | 0.10 | 1.0 | 0.02 | 3/3 (skip:0) | 3/3 | ok | - |
| throughput | n256_b16 | 256 | 16 | 1 | gpu_e2e_reuse | 0.0198 | 8.28 | 0.0199 | 8.23 | 0.02% | 0.02% | 0.16 | 1.0 | 0.03 | 3/3 (skip:0) | 3/3 | ok | - |
| throughput | n256_b150 | 256 | 150 | 1 | gpu_e2e_reuse | 0.0405 | 37.95 | 0.0406 | 37.86 | 0.10% | 0.10% | 1.46 | 1.0 | 0.29 | 3/3 (skip:0) | 3/3 | ok | - |
| throughput | n256_b256 | 256 | 256 | 1 | gpu_e2e_reuse | 0.0576 | 45.51 | 0.0573 | 45.74 | 0.12% | 0.12% | 2.50 | 1.0 | 0.50 | 3/3 (skip:0) | 3/3 | ok | - |
| throughput | n256_b1024 | 256 | 1024 | 1 | gpu_e2e_reuse | 0.177 | 59.35 | 0.177 | 59.30 | 0.16% | 0.16% | 10.00 | 1.0 | 2.00 | 3/3 (skip:0) | 3/3 | ok | - |
| throughput | n512_b1 | 512 | 1 | 1 | gpu_e2e_reuse | 0.0154 | 1.49 | 0.0154 | 1.50 | 0.00% | 0.00% | 0.02 | 1.0 | 0.00 | 3/3 (skip:0) | 3/3 | ok | - |
| throughput | n512_b10 | 512 | 10 | 1 | gpu_e2e_reuse | 0.0195 | 11.83 | 0.0197 | 11.70 | 0.03% | 0.03% | 0.20 | 1.0 | 0.04 | 3/3 (skip:0) | 3/3 | ok | - |
| throughput | n512_b16 | 512 | 16 | 1 | gpu_e2e_reuse | 0.0225 | 16.38 | 0.0208 | 17.70 | 0.04% | 0.05% | 0.31 | 1.0 | 0.06 | 3/3 (skip:0) | 3/3 | ok | - |
| throughput | n512_b150 | 512 | 150 | 1 | gpu_e2e_reuse | 0.0653 | 52.90 | 0.0648 | 53.35 | 0.14% | 0.14% | 2.93 | 1.0 | 0.59 | 3/3 (skip:0) | 3/3 | ok | - |
| throughput | n512_b256 | 512 | 256 | 1 | gpu_e2e_reuse | 0.0995 | 59.31 | 0.0997 | 59.16 | 0.16% | 0.16% | 5.00 | 1.0 | 1.00 | 3/3 (skip:0) | 3/3 | ok | - |
| throughput | n512_b1024 | 512 | 1024 | 1 | gpu_e2e_reuse | 0.347 | 68.09 | 0.347 | 68.05 | 0.18% | 0.18% | 20.00 | 1.0 | 4.00 | 3/3 (skip:0) | 3/3 | ok | - |
| throughput | n1024_b1 | 1024 | 1 | 1 | gpu_e2e_reuse | 0.0160 | 3.19 | 0.0153 | 3.35 | 0.01% | 0.01% | 0.04 | 1.0 | 0.01 | 3/3 (skip:0) | 3/3 | ok | - |
| throughput | n1024_b10 | 1024 | 10 | 1 | gpu_e2e_reuse | 0.0236 | 21.66 | 0.0236 | 21.67 | 0.06% | 0.06% | 0.39 | 1.0 | 0.08 | 3/3 (skip:0) | 3/3 | ok | - |
| throughput | n1024_b16 | 1024 | 16 | 1 | gpu_e2e_reuse | 0.0269 | 30.46 | 0.0276 | 29.74 | 0.08% | 0.08% | 0.62 | 1.0 | 0.12 | 3/3 (skip:0) | 3/3 | ok | - |
| throughput | n1024_b150 | 1024 | 150 | 1 | gpu_e2e_reuse | 0.114 | 67.48 | 0.113 | 68.02 | 0.18% | 0.18% | 5.86 | 1.0 | 1.17 | 3/3 (skip:0) | 3/3 | ok | - |
| throughput | n1024_b256 | 1024 | 256 | 1 | gpu_e2e_reuse | 0.181 | 72.48 | 0.178 | 73.50 | 0.20% | 0.20% | 10.00 | 1.0 | 2.00 | 3/3 (skip:0) | 3/3 | ok | - |
| throughput | n1024_b1024 | 1024 | 1024 | 1 | gpu_e2e_reuse | 0.668 | 78.51 | 0.668 | 78.46 | 0.21% | 0.21% | 40.00 | 1.0 | 8.00 | 3/3 (skip:0) | 3/3 | ok | - |
| throughput | n2048_b1 | 2048 | 1 | 1 | gpu_e2e_reuse | 0.0181 | 6.22 | 0.0187 | 6.03 | 0.02% | 0.02% | 0.08 | 1.0 | 0.02 | 3/3 (skip:0) | 3/3 | ok | - |
| throughput | n2048_b10 | 2048 | 10 | 1 | gpu_e2e_reuse | 0.0312 | 36.06 | 0.0315 | 35.78 | 0.10% | 0.10% | 0.78 | 1.0 | 0.16 | 3/3 (skip:0) | 3/3 | ok | - |
| throughput | n2048_b16 | 2048 | 16 | 1 | gpu_e2e_reuse | 0.0384 | 46.88 | 0.0384 | 46.89 | 0.13% | 0.13% | 1.25 | 1.0 | 0.25 | 3/3 (skip:0) | 3/3 | ok | - |
| throughput | n2048_b150 | 2048 | 150 | 1 | gpu_e2e_reuse | 0.210 | 80.36 | 0.210 | 80.53 | 0.22% | 0.22% | 11.72 | 1.0 | 2.34 | 3/3 (skip:0) | 3/3 | ok | - |
| throughput | n2048_b256 | 2048 | 256 | 1 | gpu_e2e_reuse | 0.347 | 83.10 | 0.346 | 83.30 | 0.23% | 0.23% | 20.00 | 1.0 | 4.00 | 3/3 (skip:0) | 3/3 | ok | - |
| throughput | n2048_b1024 | 2048 | 1024 | 1 | gpu_e2e_reuse | 1.324 | 87.14 | 1.326 | 86.99 | 0.24% | 0.24% | 80.00 | 1.0 | 16.00 | 3/3 (skip:0) | 3/3 | ok | - |
| throughput | n4096_b1 | 4096 | 1 | 1 | gpu_e2e_reuse | 0.0213 | 11.56 | 0.0222 | 11.06 | 0.03% | 0.03% | 0.16 | 1.0 | 0.03 | 3/3 (skip:0) | 3/3 | ok | - |
| throughput | n4096_b10 | 4096 | 10 | 1 | gpu_e2e_reuse | 0.0441 | 55.79 | 0.0435 | 56.48 | 0.15% | 0.15% | 1.56 | 1.0 | 0.31 | 3/3 (skip:0) | 3/3 | ok | - |
| throughput | n4096_b16 | 4096 | 16 | 1 | gpu_e2e_reuse | 0.0589 | 66.78 | 0.0589 | 66.74 | 0.18% | 0.18% | 2.50 | 1.0 | 0.50 | 3/3 (skip:0) | 3/3 | ok | - |
| throughput | n4096_b150 | 4096 | 150 | 1 | gpu_e2e_reuse | 0.400 | 92.13 | 0.399 | 92.28 | 0.25% | 0.25% | 23.44 | 1.0 | 4.69 | 3/3 (skip:0) | 3/3 | ok | - |
| throughput | n4096_b256 | 4096 | 256 | 1 | gpu_e2e_reuse | 0.667 | 94.31 | 0.667 | 94.31 | 0.26% | 0.26% | 40.00 | 1.0 | 8.00 | 3/3 (skip:0) | 3/3 | ok | - |
| throughput | n4096_b1024 | 4096 | 1024 | 1 | gpu_e2e_reuse | 2.700 | 93.19 | 2.696 | 93.34 | 0.25% | 0.25% | 160.00 | 1.0 | 32.00 | 3/3 (skip:0) | 3/3 | ok | - |
| throughput | n8192_b1 | 8192 | 1 | 1 | gpu_e2e_reuse | 0.0262 | 20.33 | 0.0273 | 19.48 | 0.06% | 0.05% | 0.31 | 1.0 | 0.06 | 3/3 (skip:0) | 3/3 | ok | - |
| throughput | n8192_b10 | 8192 | 10 | 1 | gpu_e2e_reuse | 0.0733 | 72.66 | 0.0724 | 73.60 | 0.20% | 0.20% | 3.12 | 1.0 | 0.62 | 3/3 (skip:0) | 3/3 | ok | - |
| throughput | n8192_b16 | 8192 | 16 | 1 | gpu_e2e_reuse | 0.103 | 82.38 | 0.104 | 82.10 | 0.22% | 0.22% | 5.00 | 1.0 | 1.00 | 3/3 (skip:0) | 3/3 | ok | - |
| throughput | n8192_b150 | 8192 | 150 | 1 | gpu_e2e_reuse | 0.790 | 101.06 | 0.789 | 101.28 | 0.27% | 0.28% | 46.88 | 1.0 | 9.38 | 3/3 (skip:0) | 3/3 | ok | - |
| throughput | n8192_b256 | 8192 | 256 | 1 | gpu_e2e_reuse | 1.326 | 102.79 | 1.323 | 103.07 | 0.28% | 0.28% | 80.00 | 1.0 | 16.00 | 3/3 (skip:0) | 3/3 | ok | - |
| throughput | n8192_b1024 | 8192 | 1024 | 1 | gpu_e2e_reuse | 5.438 | 100.27 | 5.432 | 100.38 | 0.27% | 0.27% | 320.00 | 1.0 | 64.00 | 3/3 (skip:0) | 3/3 | ok | - |
| throughput | n16384_b1 | 16384 | 1 | 1 | gpu_e2e_reuse | 0.0334 | 34.37 | 0.0341 | 33.62 | 0.09% | 0.09% | 0.62 | 1.0 | 0.12 | 3/3 (skip:0) | 3/3 | ok | - |
| throughput | n16384_b10 | 16384 | 10 | 1 | gpu_e2e_reuse | 0.127 | 90.57 | 0.126 | 90.95 | 0.25% | 0.25% | 6.25 | 1.0 | 1.25 | 3/3 (skip:0) | 3/3 | ok | - |
| throughput | n16384_b16 | 16384 | 16 | 1 | gpu_e2e_reuse | 0.186 | 98.53 | 0.186 | 98.43 | 0.27% | 0.27% | 10.00 | 1.0 | 2.00 | 3/3 (skip:0) | 3/3 | ok | - |
| throughput | n16384_b150 | 16384 | 150 | 1 | gpu_e2e_reuse | 1.579 | 108.95 | 1.584 | 108.63 | 0.30% | 0.30% | 93.75 | 1.0 | 18.75 | 3/3 (skip:0) | 3/3 | ok | - |
| throughput | n16384_b256 | 16384 | 256 | 1 | gpu_e2e_reuse | 2.708 | 108.42 | 2.705 | 108.55 | 0.29% | 0.29% | 160.00 | 1.0 | 32.00 | 3/3 (skip:0) | 3/3 | ok | - |
| throughput | n16384_b1024 | 16384 | 1024 | 1 | gpu_e2e_reuse | 10.876 | 107.99 | 10.858 | 108.16 | 0.29% | 0.29% | 640.00 | 1.0 | 128.00 | 3/3 (skip:0) | 3/3 | ok | - |
| throughput | n32768_b1 | 32768 | 1 | 1 | gpu_e2e_reuse | 0.0430 | 57.11 | 0.0431 | 57.08 | 0.16% | 0.16% | 1.25 | 1.0 | 0.25 | 3/3 (skip:0) | 3/3 | ok | - |
| throughput | n32768_b10 | 32768 | 10 | 1 | gpu_e2e_reuse | 0.231 | 106.35 | 0.231 | 106.61 | 0.29% | 0.29% | 12.50 | 1.0 | 2.50 | 3/3 (skip:0) | 3/3 | ok | - |
| throughput | n32768_b16 | 32768 | 16 | 1 | gpu_e2e_reuse | 0.364 | 108.01 | 0.359 | 109.62 | 0.29% | 0.30% | 20.00 | 1.0 | 4.00 | 3/3 (skip:0) | 3/3 | ok | - |
| throughput | n32768_b150 | 32768 | 150 | 1 | gpu_e2e_reuse | 3.280 | 112.37 | 3.274 | 112.58 | 0.31% | 0.31% | 187.50 | 1.0 | 37.50 | 3/3 (skip:0) | 3/3 | ok | - |
| throughput | n32768_b256 | 32768 | 256 | 1 | gpu_e2e_reuse | 5.601 | 112.34 | 5.599 | 112.37 | 0.31% | 0.31% | 320.00 | 1.0 | 64.00 | 3/3 (skip:0) | 3/3 | ok | - |
| throughput | n32768_b1024 | 32768 | 1024 | 1 | gpu_e2e_reuse | 22.453 | 112.08 | 22.429 | 112.20 | 0.30% | 0.30% | 1280.00 | 1.0 | 256.00 | 3/3 (skip:0) | 3/3 | ok | - |
| throughput | n65536_b1 | 65536 | 1 | 1 | gpu_e2e_reuse | 0.0624 | 83.97 | 0.0625 | 83.86 | 0.23% | 0.23% | 2.50 | 1.0 | 0.50 | 3/3 (skip:0) | 3/3 | ok | - |
| throughput | n65536_b10 | 65536 | 10 | 1 | gpu_e2e_reuse | 0.442 | 118.53 | 0.443 | 118.43 | 0.32% | 0.32% | 25.00 | 1.0 | 5.00 | 3/3 (skip:0) | 3/3 | ok | - |
| throughput | n65536_b16 | 65536 | 16 | 1 | gpu_e2e_reuse | 0.707 | 118.60 | 0.709 | 118.36 | 0.32% | 0.32% | 40.00 | 1.0 | 8.00 | 3/3 (skip:0) | 3/3 | ok | - |
| throughput | n65536_b150 | 65536 | 150 | 1 | gpu_e2e_reuse | 6.646 | 118.32 | 6.637 | 118.50 | 0.32% | 0.32% | 375.00 | 1.0 | 75.00 | 3/3 (skip:0) | 3/3 | ok | - |
| throughput | n65536_b256 | 65536 | 256 | 1 | gpu_e2e_reuse | 11.150 | 120.37 | 11.143 | 120.45 | 0.33% | 0.33% | 640.00 | 1.0 | 128.00 | 3/3 (skip:0) | 3/3 | ok | - |
| throughput | n65536_b1024 | 65536 | 1024 | 1 | gpu_e2e_reuse | 45.501 | 117.99 | 45.248 | 118.65 | 0.32% | 0.32% | 2560.00 | 1.0 | 512.00 | 3/3 (skip:0) | 3/3 | ok | - |

- CSV: `/home/nikhil/workspace/xeon-fft-bench/src/gpu/runs/run_gpu_e2e_reuse/20260316_101206/latest_run_avg.csv`