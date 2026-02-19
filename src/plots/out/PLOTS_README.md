# FFT Plot Pack

This folder contains plots generated from raw `RESULT|...` benchmark logs.

## Included Inputs

- Logs parsed: 9
- `/home/nikhil/workspace/xeon-fft-bench/src/1-d-fft/fft_logs/fft_benchmark_20260218_160053.log`
- `/home/nikhil/workspace/xeon-fft-bench/src/1-d-fft/fft_logs/fft_benchmark_20260218_160442.log`
- `/home/nikhil/workspace/xeon-fft-bench/src/1-d-fft/fft_logs/fft_benchmark_20260218_160832.log`
- `/home/nikhil/workspace/xeon-fft-bench/src/1-d-fft/fft_logs/fft_benchmark_20260218_161226.log`
- `/home/nikhil/workspace/xeon-fft-bench/src/1-d-fft/fft_logs/fft_benchmark_20260218_161625.log`
- `/home/nikhil/workspace/xeon-fft-bench/src/1-d-fft/fft_logs/fft_benchmark_20260219_102202.log`
- `/home/nikhil/workspace/xeon-fft-bench/src/fft_logs/backup/fft_benchmark_20260218_133417.log`
- `/home/nikhil/workspace/xeon-fft-bench/src/fft_logs/backup/fft_benchmark_20260218_134111.log`
- `/home/nikhil/workspace/xeon-fft-bench/src/fft_logs/fft_benchmark_20260218_135211.log`

## Datasets

- `1d_single`: workloads=['batch_scaling', 'thread_scaling', 'throughput'], cases=64, profiles=8
- `3d_double`: workloads=['batch_scaling', 'thread_scaling', 'throughput'], cases=19, profiles=8

## Plot Types

- Overview heatmaps: forward/backward throughput, speedup, latency
- Trend plots by batch: length vs throughput, length vs latency
- Case drilldowns: 2x2 panels per case (fwd/bwd throughput + latency)
- Scaling plots: thread scaling and batch scaling scenarios

## Generated Counts

- `1d_single`: overview=4, trend=6, case=54, scaling=2
- `3d_double`: overview=4, trend=4, case=8, scaling=2

## How To Read

- Use `figures/<dataset>/overview/` for quick ranking and bottleneck detection.
- Use `figures/<dataset>/cases/` for direct profile-by-profile case comparisons.
- Use `figures/<dataset>/scaling/` to inspect thread or batch efficiency.
