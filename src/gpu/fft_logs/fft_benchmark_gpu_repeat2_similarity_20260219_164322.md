# GPU Repeat-Run Similarity Summary (5-run e2e)

- New manifest: `/home/nikhil/workspace/xeon-fft-bench/src/gpu/fft_logs/fft_benchmark_gpu_5run_repeat2_32_to_4194304.manifest.txt`
- Baseline manifest: `/home/nikhil/workspace/xeon-fft-bench/src/gpu/fft_logs/fft_benchmark_gpu_5run_32_to_4194304.manifest.txt`
- Cases compared: 59

## Intra-repeat consistency (new 5 runs)

- Forward latency CV median: **1.87%**
- Forward latency CV p95: **15.35%**
- Forward latency CV max: **20.77%** at `('cufft_gpu', 'throughput', 'n64_b16', 64, 16, 1)`
- Backward latency CV median: **1.56%**
- Backward latency CV p95: **16.33%**
- Backward latency CV max: **22.96%** at `('cufft_gpu', 'throughput', 'n512_b4', 512, 4, 1)`

## New vs Previous 5-run aggregate

- Forward geomean latency ratio (new/old): **1.031x**
- Backward geomean latency ratio (new/old): **1.002x**
- Forward median absolute change: **1.17%**
- Backward median absolute change: **0.99%**
- Forward p95 absolute change: **18.06%**
- Backward p95 absolute change: **16.04%**
- Forward rows within +/-5%: **43/59**
- Backward rows within +/-5%: **46/59**