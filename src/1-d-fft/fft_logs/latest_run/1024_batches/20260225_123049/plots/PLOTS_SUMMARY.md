# 1024-Batch Plot Summary

- Peak denominator used in plots: 2112.0 SP GFLOPS
- Valid data points plotted: 549
- Batches covered: 1, 2, 4, 8, 16, 32, 64, 128, 256, 512, 1024

## Best Observed Throughput by Profile

| Profile | Best Fwd GFLOPS | Best Bwd GFLOPS | Best Max(Fwd,Bwd) GFLOPS | Best % Peak |
|---|---:|---:|---:|---:|
| SSE4.2 baseline (1 thread) | 35.19 | 34.97 | 35.19 | 1.67% |
| AVX512 (10 threads) | 561.65 | 549.80 | 561.65 | 26.59% |
| AVX512 (20 threads) | 811.45 | 776.39 | 811.45 | 38.42% |

## Top 15 Cases (Max GFLOPS)

| Case | N | Batch | Profile | Fwd GFLOPS | Bwd GFLOPS | Max GFLOPS | Max % Peak | Mem MB |
|---|---:|---:|---|---:|---:|---:|---:|---:|
| n512_b1024 | 512 | 1024 | AVX512 (20 threads) | 811.45 | 773.34 | 811.45 | 38.42% | 8.00 |
| n512_b512 | 512 | 512 | AVX512 (20 threads) | 673.05 | 776.39 | 776.39 | 36.76% | 4.00 |
| n256_b1024 | 256 | 1024 | AVX512 (20 threads) | 20.25 | 726.01 | 726.01 | 34.38% | 4.00 |
| n1024_b256 | 1024 | 256 | AVX512 (20 threads) | 713.86 | 644.53 | 713.86 | 33.80% | 4.00 |
| n1024_b512 | 1024 | 512 | AVX512 (20 threads) | 708.57 | 692.77 | 708.57 | 33.55% | 8.00 |
| n2048_b256 | 2048 | 256 | AVX512 (20 threads) | 708.45 | 698.58 | 708.45 | 33.54% | 8.00 |
| n2048_b128 | 2048 | 128 | AVX512 (20 threads) | 696.48 | 684.61 | 696.48 | 32.98% | 4.00 |
| n128_b1024 | 128 | 1024 | AVX512 (20 threads) | 650.62 | 695.71 | 695.71 | 32.94% | 2.00 |
| n512_b256 | 512 | 256 | AVX512 (20 threads) | 692.61 | 681.96 | 692.61 | 32.79% | 2.00 |
| n4096_b128 | 4096 | 128 | AVX512 (20 threads) | 665.90 | 615.48 | 665.90 | 31.53% | 8.00 |
| n4096_b64 | 4096 | 64 | AVX512 (20 threads) | 639.71 | 617.32 | 639.71 | 30.29% | 4.00 |
| n256_b512 | 256 | 512 | AVX512 (20 threads) | 588.49 | 628.12 | 628.12 | 29.74% | 2.00 |
| n1024_b128 | 1024 | 128 | AVX512 (20 threads) | 597.63 | 610.89 | 610.89 | 28.92% | 2.00 |
| n2048_b64 | 2048 | 64 | AVX512 (20 threads) | 591.43 | 586.62 | 591.43 | 28.00% | 2.00 |
| n128_b1024 | 128 | 1024 | AVX512 (10 threads) | 561.65 | 549.80 | 561.65 | 26.59% | 2.00 |

## Generated Plot Files

- `/home/nikhil/workspace/xeon-fft-bench/src/1-d-fft/fft_logs/latest_run/1024_batches/20260225_123049/plots/batchwise/batchwise_max_gflops_grouped_bar.png`
- `/home/nikhil/workspace/xeon-fft-bench/src/1-d-fft/fft_logs/latest_run/1024_batches/20260225_123049/plots/batchwise/batchwise_max_gflops_line.png`
- `/home/nikhil/workspace/xeon-fft-bench/src/1-d-fft/fft_logs/latest_run/1024_batches/20260225_123049/plots/batchwise/batchwise_max_pct_peak_line.png`
- `/home/nikhil/workspace/xeon-fft-bench/src/1-d-fft/fft_logs/latest_run/1024_batches/20260225_123049/plots/heatmaps/heatmap_max_gflops_avx512_logical.png`
- `/home/nikhil/workspace/xeon-fft-bench/src/1-d-fft/fft_logs/latest_run/1024_batches/20260225_123049/plots/heatmaps/heatmap_max_gflops_avx512_phys.png`
- `/home/nikhil/workspace/xeon-fft-bench/src/1-d-fft/fft_logs/latest_run/1024_batches/20260225_123049/plots/heatmaps/heatmap_max_gflops_baseline_sse42_1t.png`
- `/home/nikhil/workspace/xeon-fft-bench/src/1-d-fft/fft_logs/latest_run/1024_batches/20260225_123049/plots/heatmaps/heatmap_max_pct_peak_avx512_logical.png`
- `/home/nikhil/workspace/xeon-fft-bench/src/1-d-fft/fft_logs/latest_run/1024_batches/20260225_123049/plots/heatmaps/heatmap_max_pct_peak_avx512_phys.png`
- `/home/nikhil/workspace/xeon-fft-bench/src/1-d-fft/fft_logs/latest_run/1024_batches/20260225_123049/plots/heatmaps/heatmap_max_pct_peak_baseline_sse42_1t.png`
- `/home/nikhil/workspace/xeon-fft-bench/src/1-d-fft/fft_logs/latest_run/1024_batches/20260225_123049/plots/lengthwise/lengthwise_max_gflops_line.png`
- `/home/nikhil/workspace/xeon-fft-bench/src/1-d-fft/fft_logs/latest_run/1024_batches/20260225_123049/plots/lengthwise/lengthwise_max_pct_peak_line.png`
- `/home/nikhil/workspace/xeon-fft-bench/src/1-d-fft/fft_logs/latest_run/1024_batches/20260225_123049/plots/line_by_batch/batch_0001_panel.png`
- `/home/nikhil/workspace/xeon-fft-bench/src/1-d-fft/fft_logs/latest_run/1024_batches/20260225_123049/plots/line_by_batch/batch_0002_panel.png`
- `/home/nikhil/workspace/xeon-fft-bench/src/1-d-fft/fft_logs/latest_run/1024_batches/20260225_123049/plots/line_by_batch/batch_0004_panel.png`
- `/home/nikhil/workspace/xeon-fft-bench/src/1-d-fft/fft_logs/latest_run/1024_batches/20260225_123049/plots/line_by_batch/batch_0008_panel.png`
- `/home/nikhil/workspace/xeon-fft-bench/src/1-d-fft/fft_logs/latest_run/1024_batches/20260225_123049/plots/line_by_batch/batch_0016_panel.png`
- `/home/nikhil/workspace/xeon-fft-bench/src/1-d-fft/fft_logs/latest_run/1024_batches/20260225_123049/plots/line_by_batch/batch_0032_panel.png`
- `/home/nikhil/workspace/xeon-fft-bench/src/1-d-fft/fft_logs/latest_run/1024_batches/20260225_123049/plots/line_by_batch/batch_0064_panel.png`
- `/home/nikhil/workspace/xeon-fft-bench/src/1-d-fft/fft_logs/latest_run/1024_batches/20260225_123049/plots/line_by_batch/batch_0128_panel.png`
- `/home/nikhil/workspace/xeon-fft-bench/src/1-d-fft/fft_logs/latest_run/1024_batches/20260225_123049/plots/line_by_batch/batch_0256_panel.png`
- `/home/nikhil/workspace/xeon-fft-bench/src/1-d-fft/fft_logs/latest_run/1024_batches/20260225_123049/plots/line_by_batch/batch_0512_panel.png`
- `/home/nikhil/workspace/xeon-fft-bench/src/1-d-fft/fft_logs/latest_run/1024_batches/20260225_123049/plots/line_by_batch/batch_1024_panel.png`
- `/home/nikhil/workspace/xeon-fft-bench/src/1-d-fft/fft_logs/latest_run/1024_batches/20260225_123049/plots/peak_summary/overall_peak_gflops_bar.png`
- `/home/nikhil/workspace/xeon-fft-bench/src/1-d-fft/fft_logs/latest_run/1024_batches/20260225_123049/plots/peak_summary/overall_peak_pct_bar.png`
