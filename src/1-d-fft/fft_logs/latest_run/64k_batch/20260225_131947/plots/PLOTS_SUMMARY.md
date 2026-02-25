# 64k-Batch Plot Summary

- Peak denominator used in plots: 2112.0 SP GFLOPS
- Valid data points plotted: 720
- Batches covered: 1, 2, 4, 8, 16, 32, 64, 128, 256, 512, 1024, 2048, 4096, 8192, 16384, 32768, 65536

## Best Observed Throughput by Profile

| Profile | Best Fwd GFLOPS | Best Bwd GFLOPS | Best Max(Fwd,Bwd) GFLOPS | Best % Peak |
|---|---:|---:|---:|---:|
| SSE4.2 baseline (1 thread) | 37.45 | 37.43 | 37.45 | 1.77% |
| AVX512 (10 threads) | 749.84 | 795.51 | 795.51 | 37.67% |
| AVX512 (20 threads) | 843.29 | 857.20 | 857.20 | 40.59% |

## Top 15 Cases (Max GFLOPS)

| Case | N | Batch | Profile | Fwd GFLOPS | Bwd GFLOPS | Max GFLOPS | Max % Peak | Mem MB |
|---|---:|---:|---|---:|---:|---:|---:|---:|
| n128_b4096 | 128 | 4096 | AVX512 (20 threads) | 843.29 | 857.20 | 857.20 | 40.59% | 8.00 |
| n128_b2048 | 128 | 2048 | AVX512 (20 threads) | 818.25 | 830.77 | 830.77 | 39.34% | 4.00 |
| n64_b8192 | 64 | 8192 | AVX512 (20 threads) | 820.87 | 828.83 | 828.83 | 39.24% | 8.00 |
| n64_b4096 | 64 | 4096 | AVX512 (20 threads) | 793.73 | 798.49 | 798.49 | 37.81% | 4.00 |
| n128_b4096 | 128 | 4096 | AVX512 (10 threads) | 683.61 | 795.51 | 795.51 | 37.67% | 8.00 |
| n512_b512 | 512 | 512 | AVX512 (20 threads) | 788.27 | 573.62 | 788.27 | 37.32% | 4.00 |
| n512_b1024 | 512 | 1024 | AVX512 (20 threads) | 781.95 | 767.58 | 781.95 | 37.02% | 8.00 |
| n128_b2048 | 128 | 2048 | AVX512 (10 threads) | 749.84 | 778.47 | 778.47 | 36.86% | 4.00 |
| n1024_b512 | 1024 | 512 | AVX512 (10 threads) | 734.54 | 741.38 | 741.38 | 35.10% | 8.00 |
| n512_b512 | 512 | 512 | AVX512 (10 threads) | 739.22 | 722.78 | 739.22 | 35.00% | 4.00 |
| n512_b1024 | 512 | 1024 | AVX512 (10 threads) | 546.16 | 730.55 | 730.55 | 34.59% | 8.00 |
| n1024_b256 | 1024 | 256 | AVX512 (10 threads) | 725.36 | 728.83 | 728.83 | 34.51% | 4.00 |
| n256_b2048 | 256 | 2048 | AVX512 (20 threads) | 713.83 | 726.59 | 726.59 | 34.40% | 8.00 |
| n1024_b512 | 1024 | 512 | AVX512 (20 threads) | 717.02 | 682.22 | 717.02 | 33.95% | 8.00 |
| n64_b8192 | 64 | 8192 | AVX512 (10 threads) | 518.11 | 715.49 | 715.49 | 33.88% | 8.00 |

## Generated Plot Files

- `/home/nikhil/workspace/xeon-fft-bench/src/1-d-fft/fft_logs/latest_run/64k_batch/20260225_131947/plots/batchwise/batchwise_max_gflops_grouped_bar.png`
- `/home/nikhil/workspace/xeon-fft-bench/src/1-d-fft/fft_logs/latest_run/64k_batch/20260225_131947/plots/batchwise/batchwise_max_gflops_line.png`
- `/home/nikhil/workspace/xeon-fft-bench/src/1-d-fft/fft_logs/latest_run/64k_batch/20260225_131947/plots/batchwise/batchwise_max_pct_peak_line.png`
- `/home/nikhil/workspace/xeon-fft-bench/src/1-d-fft/fft_logs/latest_run/64k_batch/20260225_131947/plots/heatmaps/heatmap_max_gflops_avx512_logical.png`
- `/home/nikhil/workspace/xeon-fft-bench/src/1-d-fft/fft_logs/latest_run/64k_batch/20260225_131947/plots/heatmaps/heatmap_max_gflops_avx512_phys.png`
- `/home/nikhil/workspace/xeon-fft-bench/src/1-d-fft/fft_logs/latest_run/64k_batch/20260225_131947/plots/heatmaps/heatmap_max_gflops_baseline_sse42_1t.png`
- `/home/nikhil/workspace/xeon-fft-bench/src/1-d-fft/fft_logs/latest_run/64k_batch/20260225_131947/plots/heatmaps/heatmap_max_pct_peak_avx512_logical.png`
- `/home/nikhil/workspace/xeon-fft-bench/src/1-d-fft/fft_logs/latest_run/64k_batch/20260225_131947/plots/heatmaps/heatmap_max_pct_peak_avx512_phys.png`
- `/home/nikhil/workspace/xeon-fft-bench/src/1-d-fft/fft_logs/latest_run/64k_batch/20260225_131947/plots/heatmaps/heatmap_max_pct_peak_baseline_sse42_1t.png`
- `/home/nikhil/workspace/xeon-fft-bench/src/1-d-fft/fft_logs/latest_run/64k_batch/20260225_131947/plots/lengthwise/lengthwise_max_gflops_line.png`
- `/home/nikhil/workspace/xeon-fft-bench/src/1-d-fft/fft_logs/latest_run/64k_batch/20260225_131947/plots/lengthwise/lengthwise_max_pct_peak_line.png`
- `/home/nikhil/workspace/xeon-fft-bench/src/1-d-fft/fft_logs/latest_run/64k_batch/20260225_131947/plots/line_by_batch/batch_0001_panel.png`
- `/home/nikhil/workspace/xeon-fft-bench/src/1-d-fft/fft_logs/latest_run/64k_batch/20260225_131947/plots/line_by_batch/batch_0002_panel.png`
- `/home/nikhil/workspace/xeon-fft-bench/src/1-d-fft/fft_logs/latest_run/64k_batch/20260225_131947/plots/line_by_batch/batch_0004_panel.png`
- `/home/nikhil/workspace/xeon-fft-bench/src/1-d-fft/fft_logs/latest_run/64k_batch/20260225_131947/plots/line_by_batch/batch_0008_panel.png`
- `/home/nikhil/workspace/xeon-fft-bench/src/1-d-fft/fft_logs/latest_run/64k_batch/20260225_131947/plots/line_by_batch/batch_0016_panel.png`
- `/home/nikhil/workspace/xeon-fft-bench/src/1-d-fft/fft_logs/latest_run/64k_batch/20260225_131947/plots/line_by_batch/batch_0032_panel.png`
- `/home/nikhil/workspace/xeon-fft-bench/src/1-d-fft/fft_logs/latest_run/64k_batch/20260225_131947/plots/line_by_batch/batch_0064_panel.png`
- `/home/nikhil/workspace/xeon-fft-bench/src/1-d-fft/fft_logs/latest_run/64k_batch/20260225_131947/plots/line_by_batch/batch_0128_panel.png`
- `/home/nikhil/workspace/xeon-fft-bench/src/1-d-fft/fft_logs/latest_run/64k_batch/20260225_131947/plots/line_by_batch/batch_0256_panel.png`
- `/home/nikhil/workspace/xeon-fft-bench/src/1-d-fft/fft_logs/latest_run/64k_batch/20260225_131947/plots/line_by_batch/batch_0512_panel.png`
- `/home/nikhil/workspace/xeon-fft-bench/src/1-d-fft/fft_logs/latest_run/64k_batch/20260225_131947/plots/line_by_batch/batch_1024_panel.png`
- `/home/nikhil/workspace/xeon-fft-bench/src/1-d-fft/fft_logs/latest_run/64k_batch/20260225_131947/plots/line_by_batch/batch_16384_panel.png`
- `/home/nikhil/workspace/xeon-fft-bench/src/1-d-fft/fft_logs/latest_run/64k_batch/20260225_131947/plots/line_by_batch/batch_2048_panel.png`
- `/home/nikhil/workspace/xeon-fft-bench/src/1-d-fft/fft_logs/latest_run/64k_batch/20260225_131947/plots/line_by_batch/batch_32768_panel.png`
- `/home/nikhil/workspace/xeon-fft-bench/src/1-d-fft/fft_logs/latest_run/64k_batch/20260225_131947/plots/line_by_batch/batch_4096_panel.png`
- `/home/nikhil/workspace/xeon-fft-bench/src/1-d-fft/fft_logs/latest_run/64k_batch/20260225_131947/plots/line_by_batch/batch_65536_panel.png`
- `/home/nikhil/workspace/xeon-fft-bench/src/1-d-fft/fft_logs/latest_run/64k_batch/20260225_131947/plots/line_by_batch/batch_8192_panel.png`
- `/home/nikhil/workspace/xeon-fft-bench/src/1-d-fft/fft_logs/latest_run/64k_batch/20260225_131947/plots/peak_summary/overall_peak_gflops_bar.png`
- `/home/nikhil/workspace/xeon-fft-bench/src/1-d-fft/fft_logs/latest_run/64k_batch/20260225_131947/plots/peak_summary/overall_peak_pct_bar.png`
