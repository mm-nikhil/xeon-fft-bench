# run_gpu_e2e_noreuse (3-run average)

- Generated at: 2026-03-16 10:15:28.076065
- Manifest: `/home/nikhil/workspace/xeon-fft-bench/src/gpu/runs/run_gpu_e2e_noreuse/20260316_101337/manifest.tsv`
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
- `BENCH_STREAM_MAX_SLOTS` = `262144`
- `BENCH_STREAM_MIN_SLOTS` = `2`
- `BENCH_STREAM_MODE` = `1`
- `BENCH_STREAM_TARGET_MB` = `128`
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
| run01 | `/home/nikhil/workspace/xeon-fft-bench/src/gpu/runs/run_gpu_e2e_noreuse/20260316_101337/runs/run01/fft_benchmark_gpu_20260316_101338.log` | `/home/nikhil/workspace/xeon-fft-bench/src/gpu/runs/run_gpu_e2e_noreuse/20260316_101337/runs/run01/fft_benchmark_gpu_20260316_101338.report.md` |
| run02 | `/home/nikhil/workspace/xeon-fft-bench/src/gpu/runs/run_gpu_e2e_noreuse/20260316_101337/runs/run02/fft_benchmark_gpu_20260316_101416.log` | `/home/nikhil/workspace/xeon-fft-bench/src/gpu/runs/run_gpu_e2e_noreuse/20260316_101337/runs/run02/fft_benchmark_gpu_20260316_101416.report.md` |
| run03 | `/home/nikhil/workspace/xeon-fft-bench/src/gpu/runs/run_gpu_e2e_noreuse/20260316_101337/runs/run03/fft_benchmark_gpu_20260316_101452.log` | `/home/nikhil/workspace/xeon-fft-bench/src/gpu/runs/run_gpu_e2e_noreuse/20260316_101337/runs/run03/fft_benchmark_gpu_20260316_101452.report.md` |

## Scenario Catalog

| Profile | Description | Workload | Library | Family |
|---|---|---|---|---|
| gpu_e2e_noreuse | cuFFT end-to-end cache-no-reuse (H2D + FFT + D2H with slot rotation) | throughput | CUDA_CUFFT | run_gpu_e2e_noreuse |

## Summary Stats

- Rows aggregated: 96
- Quality counts: {'ok': 96}
- Best forward: `n65536_b150` = 118.52 GFLOPS (0.32%)
- Best backward: `n65536_b256` = 118.73 GFLOPS (0.32%)

## Averaged Results

| Workload | Case | N | Batch | ThreadsField | Profile | Avg Fwd ms | Avg Fwd SP GFLOPS | Avg Bwd ms | Avg Bwd SP GFLOPS | Fwd % Peak | Bwd % Peak | Avg Mem MB | Avg Slots | Avg Work MB | Samples | Checks | Quality | Note |
|---|---|---:|---:|---:|---|---:|---:|---:|---:|---:|---:|---:|---:|---:|---|---|---|---|
| throughput | n2_b1 | 2 | 1 | 1 | gpu_e2e_noreuse | 0.005697 | 0.00 | 0.005687 | 0.00 | 0.00% | 0.00% | 16.00 | 262144.0 | 0.00 | 3/3 (skip:0) | 3/3 | ok | - |
| throughput | n2_b10 | 2 | 10 | 1 | gpu_e2e_noreuse | 0.005951 | 0.02 | 0.005909 | 0.02 | 0.00% | 0.00% | 160.00 | 262144.0 | 0.00 | 3/3 (skip:0) | 3/3 | ok | - |
| throughput | n2_b16 | 2 | 16 | 1 | gpu_e2e_noreuse | 0.006251 | 0.03 | 0.006060 | 0.03 | 0.00% | 0.00% | 256.00 | 262144.0 | 0.00 | 3/3 (skip:0) | 3/3 | ok | - |
| throughput | n2_b150 | 2 | 150 | 1 | gpu_e2e_noreuse | 0.0143 | 0.10 | 0.0137 | 0.11 | 0.00% | 0.00% | 256.01 | 27963.0 | 0.00 | 3/3 (skip:0) | 3/3 | ok | - |
| throughput | n2_b256 | 2 | 256 | 1 | gpu_e2e_noreuse | 0.0148 | 0.17 | 0.0145 | 0.18 | 0.00% | 0.00% | 256.00 | 16384.0 | 0.00 | 3/3 (skip:0) | 3/3 | ok | - |
| throughput | n2_b1024 | 2 | 1024 | 1 | gpu_e2e_noreuse | 0.0161 | 0.64 | 0.0160 | 0.64 | 0.00% | 0.00% | 256.02 | 4096.0 | 0.02 | 3/3 (skip:0) | 3/3 | ok | - |
| throughput | n4_b1 | 4 | 1 | 1 | gpu_e2e_noreuse | 0.006605 | 0.01 | 0.006591 | 0.01 | 0.00% | 0.00% | 32.00 | 262144.0 | 0.00 | 3/3 (skip:0) | 3/3 | ok | - |
| throughput | n4_b10 | 4 | 10 | 1 | gpu_e2e_noreuse | 0.007589 | 0.05 | 0.007614 | 0.05 | 0.00% | 0.00% | 256.00 | 209716.0 | 0.00 | 3/3 (skip:0) | 3/3 | ok | - |
| throughput | n4_b16 | 4 | 16 | 1 | gpu_e2e_noreuse | 0.007652 | 0.08 | 0.007565 | 0.08 | 0.00% | 0.00% | 256.00 | 131072.0 | 0.00 | 3/3 (skip:0) | 3/3 | ok | - |
| throughput | n4_b150 | 4 | 150 | 1 | gpu_e2e_noreuse | 0.0154 | 0.39 | 0.0153 | 0.39 | 0.00% | 0.00% | 256.02 | 13982.0 | 0.00 | 3/3 (skip:0) | 3/3 | ok | - |
| throughput | n4_b256 | 4 | 256 | 1 | gpu_e2e_noreuse | 0.0154 | 0.66 | 0.0150 | 0.68 | 0.00% | 0.00% | 256.01 | 8192.0 | 0.01 | 3/3 (skip:0) | 3/3 | ok | - |
| throughput | n4_b1024 | 4 | 1024 | 1 | gpu_e2e_noreuse | 0.0183 | 2.24 | 0.0180 | 2.28 | 0.01% | 0.01% | 256.03 | 2048.0 | 0.03 | 3/3 (skip:0) | 3/3 | ok | - |
| throughput | n8_b1 | 8 | 1 | 1 | gpu_e2e_noreuse | 0.007232 | 0.02 | 0.007231 | 0.02 | 0.00% | 0.00% | 64.00 | 262144.0 | 0.00 | 3/3 (skip:0) | 3/3 | ok | - |
| throughput | n8_b10 | 8 | 10 | 1 | gpu_e2e_noreuse | 0.008043 | 0.15 | 0.007827 | 0.15 | 0.00% | 0.00% | 256.00 | 104858.0 | 0.00 | 3/3 (skip:0) | 3/3 | ok | - |
| throughput | n8_b16 | 8 | 16 | 1 | gpu_e2e_noreuse | 0.008206 | 0.23 | 0.008122 | 0.24 | 0.00% | 0.00% | 256.00 | 65536.0 | 0.00 | 3/3 (skip:0) | 3/3 | ok | - |
| throughput | n8_b150 | 8 | 150 | 1 | gpu_e2e_noreuse | 0.0152 | 1.18 | 0.0163 | 1.10 | 0.00% | 0.00% | 256.03 | 6991.0 | 0.01 | 3/3 (skip:0) | 3/3 | ok | - |
| throughput | n8_b256 | 8 | 256 | 1 | gpu_e2e_noreuse | 0.0163 | 1.89 | 0.0159 | 1.93 | 0.01% | 0.01% | 256.02 | 4096.0 | 0.02 | 3/3 (skip:0) | 3/3 | ok | - |
| throughput | n8_b1024 | 8 | 1024 | 1 | gpu_e2e_noreuse | 0.0214 | 5.75 | 0.0218 | 5.64 | 0.02% | 0.02% | 256.06 | 1024.0 | 0.06 | 3/3 (skip:0) | 3/3 | ok | - |
| throughput | n16_b1 | 16 | 1 | 1 | gpu_e2e_noreuse | 0.007493 | 0.04 | 0.007501 | 0.04 | 0.00% | 0.00% | 128.00 | 262144.0 | 0.00 | 3/3 (skip:0) | 3/3 | ok | - |
| throughput | n16_b10 | 16 | 10 | 1 | gpu_e2e_noreuse | 0.0148 | 0.22 | 0.0151 | 0.21 | 0.00% | 0.00% | 256.00 | 52429.0 | 0.00 | 3/3 (skip:0) | 3/3 | ok | - |
| throughput | n16_b16 | 16 | 16 | 1 | gpu_e2e_noreuse | 0.0148 | 0.35 | 0.0161 | 0.32 | 0.00% | 0.00% | 256.00 | 32768.0 | 0.00 | 3/3 (skip:0) | 3/3 | ok | - |
| throughput | n16_b150 | 16 | 150 | 1 | gpu_e2e_noreuse | 0.0168 | 2.86 | 0.0168 | 2.86 | 0.01% | 0.01% | 256.07 | 3496.0 | 0.02 | 3/3 (skip:0) | 3/3 | ok | - |
| throughput | n16_b256 | 16 | 256 | 1 | gpu_e2e_noreuse | 0.0190 | 4.31 | 0.0190 | 4.31 | 0.01% | 0.01% | 256.03 | 2048.0 | 0.03 | 3/3 (skip:0) | 3/3 | ok | - |
| throughput | n16_b1024 | 16 | 1024 | 1 | gpu_e2e_noreuse | 0.0254 | 12.89 | 0.0255 | 12.85 | 0.03% | 0.03% | 256.12 | 512.0 | 0.12 | 3/3 (skip:0) | 3/3 | ok | - |
| throughput | n32_b1 | 32 | 1 | 1 | gpu_e2e_noreuse | 0.007946 | 0.10 | 0.007865 | 0.10 | 0.00% | 0.00% | 256.00 | 262144.0 | 0.00 | 3/3 (skip:0) | 3/3 | ok | - |
| throughput | n32_b10 | 32 | 10 | 1 | gpu_e2e_noreuse | 0.0153 | 0.52 | 0.0163 | 0.49 | 0.00% | 0.00% | 256.01 | 26215.0 | 0.00 | 3/3 (skip:0) | 3/3 | ok | - |
| throughput | n32_b16 | 32 | 16 | 1 | gpu_e2e_noreuse | 0.0161 | 0.80 | 0.0158 | 0.81 | 0.00% | 0.00% | 256.00 | 16384.0 | 0.00 | 3/3 (skip:0) | 3/3 | ok | - |
| throughput | n32_b150 | 32 | 150 | 1 | gpu_e2e_noreuse | 0.0195 | 6.15 | 0.0193 | 6.21 | 0.02% | 0.02% | 256.09 | 1748.0 | 0.04 | 3/3 (skip:0) | 3/3 | ok | - |
| throughput | n32_b256 | 32 | 256 | 1 | gpu_e2e_noreuse | 0.0210 | 9.73 | 0.0209 | 9.81 | 0.03% | 0.03% | 256.06 | 1024.0 | 0.06 | 3/3 (skip:0) | 3/3 | ok | - |
| throughput | n32_b1024 | 32 | 1024 | 1 | gpu_e2e_noreuse | 0.0377 | 21.73 | 0.0374 | 21.90 | 0.06% | 0.06% | 256.25 | 256.0 | 0.25 | 3/3 (skip:0) | 3/3 | ok | - |
| throughput | n64_b1 | 64 | 1 | 1 | gpu_e2e_noreuse | 0.007849 | 0.24 | 0.007739 | 0.25 | 0.00% | 0.00% | 256.00 | 131072.0 | 0.00 | 3/3 (skip:0) | 3/3 | ok | - |
| throughput | n64_b10 | 64 | 10 | 1 | gpu_e2e_noreuse | 0.0158 | 1.22 | 0.0150 | 1.28 | 0.00% | 0.00% | 256.02 | 13108.0 | 0.00 | 3/3 (skip:0) | 3/3 | ok | - |
| throughput | n64_b16 | 64 | 16 | 1 | gpu_e2e_noreuse | 0.0162 | 1.89 | 0.0167 | 1.84 | 0.01% | 0.01% | 256.01 | 8192.0 | 0.01 | 3/3 (skip:0) | 3/3 | ok | - |
| throughput | n64_b150 | 64 | 150 | 1 | gpu_e2e_noreuse | 0.0213 | 13.52 | 0.0210 | 13.69 | 0.04% | 0.04% | 256.13 | 874.0 | 0.07 | 3/3 (skip:0) | 3/3 | ok | - |
| throughput | n64_b256 | 64 | 256 | 1 | gpu_e2e_noreuse | 0.0254 | 19.37 | 0.0252 | 19.54 | 0.05% | 0.05% | 256.12 | 512.0 | 0.12 | 3/3 (skip:0) | 3/3 | ok | - |
| throughput | n64_b1024 | 64 | 1024 | 1 | gpu_e2e_noreuse | 0.0583 | 33.70 | 0.0584 | 33.69 | 0.09% | 0.09% | 256.50 | 128.0 | 0.50 | 3/3 (skip:0) | 3/3 | ok | - |
| throughput | n128_b1 | 128 | 1 | 1 | gpu_e2e_noreuse | 0.008105 | 0.55 | 0.008124 | 0.55 | 0.00% | 0.00% | 256.00 | 65536.0 | 0.00 | 3/3 (skip:0) | 3/3 | ok | - |
| throughput | n128_b10 | 128 | 10 | 1 | gpu_e2e_noreuse | 0.0154 | 2.90 | 0.0161 | 2.78 | 0.01% | 0.01% | 256.03 | 6554.0 | 0.01 | 3/3 (skip:0) | 3/3 | ok | - |
| throughput | n128_b16 | 128 | 16 | 1 | gpu_e2e_noreuse | 0.0170 | 4.21 | 0.0176 | 4.08 | 0.01% | 0.01% | 256.02 | 4096.0 | 0.02 | 3/3 (skip:0) | 3/3 | ok | - |
| throughput | n128_b150 | 128 | 150 | 1 | gpu_e2e_noreuse | 0.0284 | 23.67 | 0.0283 | 23.73 | 0.06% | 0.06% | 256.20 | 437.0 | 0.15 | 3/3 (skip:0) | 3/3 | ok | - |
| throughput | n128_b256 | 128 | 256 | 1 | gpu_e2e_noreuse | 0.0374 | 30.64 | 0.0372 | 30.86 | 0.08% | 0.08% | 256.25 | 256.0 | 0.25 | 3/3 (skip:0) | 3/3 | ok | - |
| throughput | n128_b1024 | 128 | 1024 | 1 | gpu_e2e_noreuse | 0.101 | 45.44 | 0.100 | 45.65 | 0.12% | 0.12% | 257.00 | 64.0 | 1.00 | 3/3 (skip:0) | 3/3 | ok | - |
| throughput | n256_b1 | 256 | 1 | 1 | gpu_e2e_noreuse | 0.0164 | 0.62 | 0.0162 | 0.63 | 0.00% | 0.00% | 256.00 | 32768.0 | 0.00 | 3/3 (skip:0) | 3/3 | ok | - |
| throughput | n256_b10 | 256 | 10 | 1 | gpu_e2e_noreuse | 0.0177 | 5.80 | 0.0175 | 5.85 | 0.02% | 0.02% | 256.04 | 3277.0 | 0.02 | 3/3 (skip:0) | 3/3 | ok | - |
| throughput | n256_b16 | 256 | 16 | 1 | gpu_e2e_noreuse | 0.0191 | 8.59 | 0.0189 | 8.65 | 0.02% | 0.02% | 256.03 | 2048.0 | 0.03 | 3/3 (skip:0) | 3/3 | ok | - |
| throughput | n256_b150 | 256 | 150 | 1 | gpu_e2e_noreuse | 0.0414 | 37.07 | 0.0416 | 36.96 | 0.10% | 0.10% | 256.93 | 219.0 | 0.29 | 3/3 (skip:0) | 3/3 | ok | - |
| throughput | n256_b256 | 256 | 256 | 1 | gpu_e2e_noreuse | 0.0587 | 44.64 | 0.0587 | 44.69 | 0.12% | 0.12% | 256.50 | 128.0 | 0.50 | 3/3 (skip:0) | 3/3 | ok | - |
| throughput | n256_b1024 | 256 | 1024 | 1 | gpu_e2e_noreuse | 0.184 | 57.14 | 0.184 | 56.96 | 0.16% | 0.15% | 258.00 | 32.0 | 2.00 | 3/3 (skip:0) | 3/3 | ok | - |
| throughput | n512_b1 | 512 | 1 | 1 | gpu_e2e_noreuse | 0.0156 | 1.47 | 0.0153 | 1.50 | 0.00% | 0.00% | 256.00 | 16384.0 | 0.00 | 3/3 (skip:0) | 3/3 | ok | - |
| throughput | n512_b10 | 512 | 10 | 1 | gpu_e2e_noreuse | 0.0199 | 11.55 | 0.0197 | 11.70 | 0.03% | 0.03% | 256.13 | 1639.0 | 0.04 | 3/3 (skip:0) | 3/3 | ok | - |
| throughput | n512_b16 | 512 | 16 | 1 | gpu_e2e_noreuse | 0.0208 | 17.76 | 0.0209 | 17.63 | 0.05% | 0.05% | 256.06 | 1024.0 | 0.06 | 3/3 (skip:0) | 3/3 | ok | - |
| throughput | n512_b150 | 512 | 150 | 1 | gpu_e2e_noreuse | 0.0660 | 52.34 | 0.0658 | 52.50 | 0.14% | 0.14% | 258.40 | 110.0 | 0.59 | 3/3 (skip:0) | 3/3 | ok | - |
| throughput | n512_b256 | 512 | 256 | 1 | gpu_e2e_noreuse | 0.101 | 58.54 | 0.100 | 58.88 | 0.16% | 0.16% | 257.00 | 64.0 | 1.00 | 3/3 (skip:0) | 3/3 | ok | - |
| throughput | n512_b1024 | 512 | 1024 | 1 | gpu_e2e_noreuse | 0.355 | 66.52 | 0.354 | 66.64 | 0.18% | 0.18% | 260.00 | 16.0 | 4.00 | 3/3 (skip:0) | 3/3 | ok | - |
| throughput | n1024_b1 | 1024 | 1 | 1 | gpu_e2e_noreuse | 0.0166 | 3.08 | 0.0164 | 3.13 | 0.01% | 0.01% | 256.01 | 8192.0 | 0.01 | 3/3 (skip:0) | 3/3 | ok | - |
| throughput | n1024_b10 | 1024 | 10 | 1 | gpu_e2e_noreuse | 0.0225 | 22.77 | 0.0222 | 23.07 | 0.06% | 0.06% | 256.33 | 820.0 | 0.08 | 3/3 (skip:0) | 3/3 | ok | - |
| throughput | n1024_b16 | 1024 | 16 | 1 | gpu_e2e_noreuse | 0.0267 | 30.69 | 0.0270 | 30.31 | 0.08% | 0.08% | 256.12 | 512.0 | 0.12 | 3/3 (skip:0) | 3/3 | ok | - |
| throughput | n1024_b150 | 1024 | 150 | 1 | gpu_e2e_noreuse | 0.118 | 64.99 | 0.117 | 65.46 | 0.18% | 0.18% | 258.98 | 55.0 | 1.17 | 3/3 (skip:0) | 3/3 | ok | - |
| throughput | n1024_b256 | 1024 | 256 | 1 | gpu_e2e_noreuse | 0.183 | 71.54 | 0.184 | 71.21 | 0.19% | 0.19% | 258.00 | 32.0 | 2.00 | 3/3 (skip:0) | 3/3 | ok | - |
| throughput | n1024_b1024 | 1024 | 1024 | 1 | gpu_e2e_noreuse | 0.690 | 76.01 | 0.687 | 76.29 | 0.21% | 0.21% | 264.00 | 8.0 | 8.00 | 3/3 (skip:0) | 3/3 | ok | - |
| throughput | n2048_b1 | 2048 | 1 | 1 | gpu_e2e_noreuse | 0.0187 | 6.03 | 0.0188 | 5.98 | 0.02% | 0.02% | 256.02 | 4096.0 | 0.02 | 3/3 (skip:0) | 3/3 | ok | - |
| throughput | n2048_b10 | 2048 | 10 | 1 | gpu_e2e_noreuse | 0.0309 | 36.47 | 0.0304 | 37.07 | 0.10% | 0.10% | 256.41 | 410.0 | 0.16 | 3/3 (skip:0) | 3/3 | ok | - |
| throughput | n2048_b16 | 2048 | 16 | 1 | gpu_e2e_noreuse | 0.0393 | 45.91 | 0.0389 | 46.33 | 0.12% | 0.13% | 256.25 | 256.0 | 0.25 | 3/3 (skip:0) | 3/3 | ok | - |
| throughput | n2048_b150 | 2048 | 150 | 1 | gpu_e2e_noreuse | 0.215 | 78.58 | 0.216 | 78.26 | 0.21% | 0.21% | 264.84 | 28.0 | 2.34 | 3/3 (skip:0) | 3/3 | ok | - |
| throughput | n2048_b256 | 2048 | 256 | 1 | gpu_e2e_noreuse | 0.356 | 81.00 | 0.357 | 80.69 | 0.22% | 0.22% | 260.00 | 16.0 | 4.00 | 3/3 (skip:0) | 3/3 | ok | - |
| throughput | n2048_b1024 | 2048 | 1024 | 1 | gpu_e2e_noreuse | 1.359 | 84.86 | 1.373 | 84.00 | 0.23% | 0.23% | 272.00 | 4.0 | 16.00 | 3/3 (skip:0) | 3/3 | ok | - |
| throughput | n4096_b1 | 4096 | 1 | 1 | gpu_e2e_noreuse | 0.0216 | 11.40 | 0.0214 | 11.46 | 0.03% | 0.03% | 256.03 | 2048.0 | 0.03 | 3/3 (skip:0) | 3/3 | ok | - |
| throughput | n4096_b10 | 4096 | 10 | 1 | gpu_e2e_noreuse | 0.0451 | 54.53 | 0.0451 | 54.51 | 0.15% | 0.15% | 256.56 | 205.0 | 0.31 | 3/3 (skip:0) | 3/3 | ok | - |
| throughput | n4096_b16 | 4096 | 16 | 1 | gpu_e2e_noreuse | 0.0600 | 65.51 | 0.0599 | 65.64 | 0.18% | 0.18% | 256.50 | 128.0 | 0.50 | 3/3 (skip:0) | 3/3 | ok | - |
| throughput | n4096_b150 | 4096 | 150 | 1 | gpu_e2e_noreuse | 0.416 | 88.57 | 0.412 | 89.50 | 0.24% | 0.24% | 267.19 | 14.0 | 4.69 | 3/3 (skip:0) | 3/3 | ok | - |
| throughput | n4096_b256 | 4096 | 256 | 1 | gpu_e2e_noreuse | 0.680 | 92.47 | 0.681 | 92.42 | 0.25% | 0.25% | 264.00 | 8.0 | 8.00 | 3/3 (skip:0) | 3/3 | ok | - |
| throughput | n4096_b1024 | 4096 | 1024 | 1 | gpu_e2e_noreuse | 2.724 | 92.37 | 2.720 | 92.51 | 0.25% | 0.25% | 288.00 | 2.0 | 32.00 | 3/3 (skip:0) | 3/3 | ok | - |
| throughput | n8192_b1 | 8192 | 1 | 1 | gpu_e2e_noreuse | 0.0276 | 19.29 | 0.0275 | 19.33 | 0.05% | 0.05% | 256.06 | 1024.0 | 0.06 | 3/3 (skip:0) | 3/3 | ok | - |
| throughput | n8192_b10 | 8192 | 10 | 1 | gpu_e2e_noreuse | 0.0739 | 72.08 | 0.0738 | 72.16 | 0.20% | 0.20% | 258.12 | 103.0 | 0.62 | 3/3 (skip:0) | 3/3 | ok | - |
| throughput | n8192_b16 | 8192 | 16 | 1 | gpu_e2e_noreuse | 0.105 | 80.94 | 0.105 | 80.98 | 0.22% | 0.22% | 257.00 | 64.0 | 1.00 | 3/3 (skip:0) | 3/3 | ok | - |
| throughput | n8192_b150 | 8192 | 150 | 1 | gpu_e2e_noreuse | 0.810 | 98.58 | 0.808 | 98.80 | 0.27% | 0.27% | 271.88 | 7.0 | 9.38 | 3/3 (skip:0) | 3/3 | ok | - |
| throughput | n8192_b256 | 8192 | 256 | 1 | gpu_e2e_noreuse | 1.369 | 99.58 | 1.365 | 99.87 | 0.27% | 0.27% | 272.00 | 4.0 | 16.00 | 3/3 (skip:0) | 3/3 | ok | - |
| throughput | n8192_b1024 | 8192 | 1024 | 1 | gpu_e2e_noreuse | 5.466 | 99.76 | 5.497 | 99.18 | 0.27% | 0.27% | 576.00 | 2.0 | 64.00 | 3/3 (skip:0) | 3/3 | ok | - |
| throughput | n16384_b1 | 16384 | 1 | 1 | gpu_e2e_noreuse | 0.0345 | 33.20 | 0.0343 | 33.44 | 0.09% | 0.09% | 256.12 | 512.0 | 0.12 | 3/3 (skip:0) | 3/3 | ok | - |
| throughput | n16384_b10 | 16384 | 10 | 1 | gpu_e2e_noreuse | 0.131 | 87.80 | 0.129 | 88.83 | 0.24% | 0.24% | 261.25 | 52.0 | 1.25 | 3/3 (skip:0) | 3/3 | ok | - |
| throughput | n16384_b16 | 16384 | 16 | 1 | gpu_e2e_noreuse | 0.193 | 95.00 | 0.194 | 94.52 | 0.26% | 0.26% | 258.00 | 32.0 | 2.00 | 3/3 (skip:0) | 3/3 | ok | - |
| throughput | n16384_b150 | 16384 | 150 | 1 | gpu_e2e_noreuse | 1.633 | 105.32 | 1.630 | 105.52 | 0.29% | 0.29% | 318.75 | 4.0 | 18.75 | 3/3 (skip:0) | 3/3 | ok | - |
| throughput | n16384_b256 | 16384 | 256 | 1 | gpu_e2e_noreuse | 2.750 | 106.75 | 2.737 | 107.27 | 0.29% | 0.29% | 288.00 | 2.0 | 32.00 | 3/3 (skip:0) | 3/3 | ok | - |
| throughput | n16384_b1024 | 16384 | 1024 | 1 | gpu_e2e_noreuse | 11.016 | 106.61 | 11.004 | 106.73 | 0.29% | 0.29% | 1152.00 | 2.0 | 128.00 | 3/3 (skip:0) | 3/3 | ok | - |
| throughput | n32768_b1 | 32768 | 1 | 1 | gpu_e2e_noreuse | 0.0445 | 55.23 | 0.0444 | 55.34 | 0.15% | 0.15% | 256.25 | 256.0 | 0.25 | 3/3 (skip:0) | 3/3 | ok | - |
| throughput | n32768_b10 | 32768 | 10 | 1 | gpu_e2e_noreuse | 0.236 | 104.03 | 0.236 | 104.08 | 0.28% | 0.28% | 262.50 | 26.0 | 2.50 | 3/3 (skip:0) | 3/3 | ok | - |
| throughput | n32768_b16 | 32768 | 16 | 1 | gpu_e2e_noreuse | 0.365 | 107.69 | 0.367 | 107.09 | 0.29% | 0.29% | 260.00 | 16.0 | 4.00 | 3/3 (skip:0) | 3/3 | ok | - |
| throughput | n32768_b150 | 32768 | 150 | 1 | gpu_e2e_noreuse | 3.310 | 111.36 | 3.307 | 111.46 | 0.30% | 0.30% | 337.50 | 2.0 | 37.50 | 3/3 (skip:0) | 3/3 | ok | - |
| throughput | n32768_b256 | 32768 | 256 | 1 | gpu_e2e_noreuse | 5.658 | 111.20 | 5.662 | 111.11 | 0.30% | 0.30% | 576.00 | 2.0 | 64.00 | 3/3 (skip:0) | 3/3 | ok | - |
| throughput | n32768_b1024 | 32768 | 1024 | 1 | gpu_e2e_noreuse | 22.716 | 110.78 | 22.687 | 110.93 | 0.30% | 0.30% | 2304.00 | 2.0 | 256.00 | 3/3 (skip:0) | 3/3 | ok | - |
| throughput | n65536_b1 | 65536 | 1 | 1 | gpu_e2e_noreuse | 0.0642 | 81.68 | 0.0643 | 81.55 | 0.22% | 0.22% | 256.50 | 128.0 | 0.50 | 3/3 (skip:0) | 3/3 | ok | - |
| throughput | n65536_b10 | 65536 | 10 | 1 | gpu_e2e_noreuse | 0.444 | 118.06 | 0.444 | 118.20 | 0.32% | 0.32% | 265.00 | 13.0 | 5.00 | 3/3 (skip:0) | 3/3 | ok | - |
| throughput | n65536_b16 | 65536 | 16 | 1 | gpu_e2e_noreuse | 0.726 | 115.54 | 0.729 | 115.03 | 0.31% | 0.31% | 264.00 | 8.0 | 8.00 | 3/3 (skip:0) | 3/3 | ok | - |
| throughput | n65536_b150 | 65536 | 150 | 1 | gpu_e2e_noreuse | 6.635 | 118.52 | 6.644 | 118.38 | 0.32% | 0.32% | 675.00 | 2.0 | 75.00 | 3/3 (skip:0) | 3/3 | ok | - |
| throughput | n65536_b256 | 65536 | 256 | 1 | gpu_e2e_noreuse | 11.362 | 118.13 | 11.304 | 118.73 | 0.32% | 0.32% | 1152.00 | 2.0 | 128.00 | 3/3 (skip:0) | 3/3 | ok | - |
| throughput | n65536_b1024 | 65536 | 1024 | 1 | gpu_e2e_noreuse | 45.861 | 117.07 | 45.986 | 116.75 | 0.32% | 0.32% | 4608.00 | 2.0 | 512.00 | 3/3 (skip:0) | 3/3 | ok | - |

- CSV: `/home/nikhil/workspace/xeon-fft-bench/src/gpu/runs/run_gpu_e2e_noreuse/20260316_101337/latest_run_avg.csv`