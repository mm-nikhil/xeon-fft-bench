# run_3_3 Plot Summary

- Peak denominator used in plots: 2112.0 SP GFLOPS
- Valid data points plotted: 288
- Batches covered: 1, 10, 16, 150, 256, 1024

## Best Observed Forward Throughput by Profile

| Profile | Best Forward GFLOPS | Best Forward % Peak |
|---|---:|---:|
| SSE4.2 baseline (1 thread) | 36.10 | 1.71% |
| AVX512 (10 threads) | 745.42 | 35.29% |
| AVX512 (20 threads) | 742.17 | 35.14% |

## Top 15 Forward Cases

| Case | N | Batch | Profile | Fwd GFLOPS | Fwd % Peak | Mem MB |
|---|---:|---:|---|---:|---:|---:|
| n1024_b256 | 1024 | 256 | AVX512 (10 threads) | 745.42 | 35.29% | 4.00 |
| n512_b1024 | 512 | 1024 | AVX512 (20 threads) | 742.17 | 35.14% | 8.00 |
| n512_b1024 | 512 | 1024 | AVX512 (10 threads) | 713.96 | 33.81% | 8.00 |
| n1024_b150 | 1024 | 150 | AVX512 (10 threads) | 712.14 | 33.72% | 2.34 |
| n128_b1024 | 128 | 1024 | AVX512 (20 threads) | 703.39 | 33.30% | 2.00 |
| n2048_b150 | 2048 | 150 | AVX512 (10 threads) | 694.09 | 32.86% | 4.69 |
| n1024_b256 | 1024 | 256 | AVX512 (20 threads) | 693.56 | 32.84% | 4.00 |
| n128_b1024 | 128 | 1024 | AVX512 (10 threads) | 691.62 | 32.75% | 2.00 |
| n2048_b150 | 2048 | 150 | AVX512 (20 threads) | 684.35 | 32.40% | 4.69 |
| n512_b256 | 512 | 256 | AVX512 (20 threads) | 677.31 | 32.07% | 2.00 |
| n512_b256 | 512 | 256 | AVX512 (10 threads) | 665.59 | 31.51% | 2.00 |
| n2048_b256 | 2048 | 256 | AVX512 (20 threads) | 655.72 | 31.05% | 8.00 |
| n1024_b150 | 1024 | 150 | AVX512 (20 threads) | 649.22 | 30.74% | 2.34 |
| n256_b1024 | 256 | 1024 | AVX512 (20 threads) | 647.66 | 30.67% | 4.00 |
| n256_b1024 | 256 | 1024 | AVX512 (10 threads) | 626.09 | 29.64% | 4.00 |

## Generated Plot Files

- `/home/nikhil/workspace/xeon-fft-bench/src/1-d-fft/fft_logs/run_3_3/20260303_132905/plots/batchwise/batchwise_best_forward_gflops_line.png`
- `/home/nikhil/workspace/xeon-fft-bench/src/1-d-fft/fft_logs/run_3_3/20260303_132905/plots/batchwise/batchwise_best_forward_pct_peak_line.png`
- `/home/nikhil/workspace/xeon-fft-bench/src/1-d-fft/fft_logs/run_3_3/20260303_132905/plots/heatmaps/heatmap_forward_gflops_avx512_logical.png`
- `/home/nikhil/workspace/xeon-fft-bench/src/1-d-fft/fft_logs/run_3_3/20260303_132905/plots/heatmaps/heatmap_forward_gflops_avx512_phys.png`
- `/home/nikhil/workspace/xeon-fft-bench/src/1-d-fft/fft_logs/run_3_3/20260303_132905/plots/heatmaps/heatmap_forward_gflops_baseline_sse42_1t.png`
- `/home/nikhil/workspace/xeon-fft-bench/src/1-d-fft/fft_logs/run_3_3/20260303_132905/plots/heatmaps/heatmap_forward_pct_peak_avx512_logical.png`
- `/home/nikhil/workspace/xeon-fft-bench/src/1-d-fft/fft_logs/run_3_3/20260303_132905/plots/heatmaps/heatmap_forward_pct_peak_avx512_phys.png`
- `/home/nikhil/workspace/xeon-fft-bench/src/1-d-fft/fft_logs/run_3_3/20260303_132905/plots/heatmaps/heatmap_forward_pct_peak_baseline_sse42_1t.png`
- `/home/nikhil/workspace/xeon-fft-bench/src/1-d-fft/fft_logs/run_3_3/20260303_132905/plots/lengthwise/lengthwise_best_forward_gflops_line.png`
- `/home/nikhil/workspace/xeon-fft-bench/src/1-d-fft/fft_logs/run_3_3/20260303_132905/plots/lengthwise/lengthwise_best_forward_pct_peak_line.png`
- `/home/nikhil/workspace/xeon-fft-bench/src/1-d-fft/fft_logs/run_3_3/20260303_132905/plots/line_by_batch/batch_0001_forward_panel.png`
- `/home/nikhil/workspace/xeon-fft-bench/src/1-d-fft/fft_logs/run_3_3/20260303_132905/plots/line_by_batch/batch_0010_forward_panel.png`
- `/home/nikhil/workspace/xeon-fft-bench/src/1-d-fft/fft_logs/run_3_3/20260303_132905/plots/line_by_batch/batch_0016_forward_panel.png`
- `/home/nikhil/workspace/xeon-fft-bench/src/1-d-fft/fft_logs/run_3_3/20260303_132905/plots/line_by_batch/batch_0150_forward_panel.png`
- `/home/nikhil/workspace/xeon-fft-bench/src/1-d-fft/fft_logs/run_3_3/20260303_132905/plots/line_by_batch/batch_0256_forward_panel.png`
- `/home/nikhil/workspace/xeon-fft-bench/src/1-d-fft/fft_logs/run_3_3/20260303_132905/plots/line_by_batch/batch_1024_forward_panel.png`
- `/home/nikhil/workspace/xeon-fft-bench/src/1-d-fft/fft_logs/run_3_3/20260303_132905/plots/n-wise/n1024_forward_throughput_vs_batch.png`
- `/home/nikhil/workspace/xeon-fft-bench/src/1-d-fft/fft_logs/run_3_3/20260303_132905/plots/n-wise/n128_forward_throughput_vs_batch.png`
- `/home/nikhil/workspace/xeon-fft-bench/src/1-d-fft/fft_logs/run_3_3/20260303_132905/plots/n-wise/n16384_forward_throughput_vs_batch.png`
- `/home/nikhil/workspace/xeon-fft-bench/src/1-d-fft/fft_logs/run_3_3/20260303_132905/plots/n-wise/n16_forward_throughput_vs_batch.png`
- `/home/nikhil/workspace/xeon-fft-bench/src/1-d-fft/fft_logs/run_3_3/20260303_132905/plots/n-wise/n2048_forward_throughput_vs_batch.png`
- `/home/nikhil/workspace/xeon-fft-bench/src/1-d-fft/fft_logs/run_3_3/20260303_132905/plots/n-wise/n256_forward_throughput_vs_batch.png`
- `/home/nikhil/workspace/xeon-fft-bench/src/1-d-fft/fft_logs/run_3_3/20260303_132905/plots/n-wise/n2_forward_throughput_vs_batch.png`
- `/home/nikhil/workspace/xeon-fft-bench/src/1-d-fft/fft_logs/run_3_3/20260303_132905/plots/n-wise/n32768_forward_throughput_vs_batch.png`
- `/home/nikhil/workspace/xeon-fft-bench/src/1-d-fft/fft_logs/run_3_3/20260303_132905/plots/n-wise/n32_forward_throughput_vs_batch.png`
- `/home/nikhil/workspace/xeon-fft-bench/src/1-d-fft/fft_logs/run_3_3/20260303_132905/plots/n-wise/n4096_forward_throughput_vs_batch.png`
- `/home/nikhil/workspace/xeon-fft-bench/src/1-d-fft/fft_logs/run_3_3/20260303_132905/plots/n-wise/n4_forward_throughput_vs_batch.png`
- `/home/nikhil/workspace/xeon-fft-bench/src/1-d-fft/fft_logs/run_3_3/20260303_132905/plots/n-wise/n512_forward_throughput_vs_batch.png`
- `/home/nikhil/workspace/xeon-fft-bench/src/1-d-fft/fft_logs/run_3_3/20260303_132905/plots/n-wise/n64_forward_throughput_vs_batch.png`
- `/home/nikhil/workspace/xeon-fft-bench/src/1-d-fft/fft_logs/run_3_3/20260303_132905/plots/n-wise/n65536_forward_throughput_vs_batch.png`
- `/home/nikhil/workspace/xeon-fft-bench/src/1-d-fft/fft_logs/run_3_3/20260303_132905/plots/n-wise/n8192_forward_throughput_vs_batch.png`
- `/home/nikhil/workspace/xeon-fft-bench/src/1-d-fft/fft_logs/run_3_3/20260303_132905/plots/n-wise/n8_forward_throughput_vs_batch.png`
- `/home/nikhil/workspace/xeon-fft-bench/src/1-d-fft/fft_logs/run_3_3/20260303_132905/plots/peak_summary/overall_best_forward_gflops_bar.png`
- `/home/nikhil/workspace/xeon-fft-bench/src/1-d-fft/fft_logs/run_3_3/20260303_132905/plots/peak_summary/overall_best_forward_pct_peak_bar.png`
