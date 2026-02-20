# GPU 3-Set Comparison and MKL Contrast

- Generated at: 2026-02-20 10:41:39.394093
- CPU reference report used: `/home/nikhil/workspace/xeon-fft-bench/src/1-d-fft/fft_logs/fft_benchmark_1d_5run_avg_20260219_162025.report.md`

## Latest Aggregate (Requested)

- Latest GPU averaged report: `/home/nikhil/workspace/xeon-fft-bench/src/gpu/fft_logs/fft_benchmark_gpu_5run_avg_20260220_104025.report.md`
- Latest GPU manifest: `/home/nikhil/workspace/xeon-fft-bench/src/gpu/fft_logs/fft_benchmark_gpu_5run_repeat3_32_to_4194304.manifest.txt`

## GPU Stability Per 5-Run Set

| GPU Set | Fwd CV Median | Fwd CV p95 | Bwd CV Median | Bwd CV p95 | Run-to-run Fwd Geomean Span | Run-to-run Bwd Geomean Span |
|---|---:|---:|---:|---:|---:|---:|
| gpu_set1_20260219_163235 | 2.02% | 20.73% | 1.93% | 17.82% | 3.45% | 6.48% |
| gpu_set2_20260219_164322 | 1.99% | 15.35% | 1.60% | 16.33% | 2.43% | 1.16% |
| gpu_set3_20260220_104025 | 1.47% | 15.79% | 1.71% | 15.21% | 4.28% | 3.14% |

## GPU Set-to-Set Similarity

| A -> B | Rows | Fwd Geomean ms Ratio (B/A) | Bwd Geomean ms Ratio (B/A) | Fwd Median Abs Change | Bwd Median Abs Change | Fwd p95 Abs Change | Bwd p95 Abs Change | Fwd rows within +/-5% | Bwd rows within +/-5% |
|---|---:|---:|---:|---:|---:|---:|---:|---:|---:|
| gpu_set1_20260219_163235 -> gpu_set2_20260219_164322 | 54 | 1.034x | 1.001x | 1.28% | 1.36% | 18.05% | 16.04% | 38/54 | 41/54 |
| gpu_set1_20260219_163235 -> gpu_set3_20260220_104025 | 54 | 1.032x | 1.010x | 0.86% | 0.70% | 19.23% | 19.67% | 37/54 | 40/54 |
| gpu_set2_20260219_164322 -> gpu_set3_20260220_104025 | 54 | 0.999x | 1.009x | 1.61% | 0.75% | 11.81% | 12.06% | 40/54 | 43/54 |

## GPU vs Intel Xeon MKL (from 1D FFT averaged report)

| GPU Set | Overlap Cases | Fwd GFLOPS Geomean Speedup | Bwd GFLOPS Geomean Speedup | Fwd Latency Geomean Speedup | Bwd Latency Geomean Speedup | Fwd Cases GPU>MKL | Bwd Cases GPU>MKL |
|---|---:|---:|---:|---:|---:|---:|---:|
| gpu_set1_20260219_163235 | 54 | 0.21x | 0.23x | 0.21x | 0.23x | 14/54 | 14/54 |
| gpu_set2_20260219_164322 | 54 | 0.20x | 0.23x | 0.20x | 0.23x | 14/54 | 14/54 |
| gpu_set3_20260220_104025 | 54 | 0.21x | 0.22x | 0.20x | 0.22x | 14/54 | 14/54 |