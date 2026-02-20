# GPU FFT Plot Pack

This folder contains plots generated from GPU manifest runs and MKL averaged report data.

## Inputs

- GPU manifests: 1
- `/home/nikhil/workspace/xeon-fft-bench/src/gpu/fft_logs/fft_benchmark_gpu_5run_32_to_4194304.manifest.txt`
- MKL reference report: `/home/nikhil/workspace/xeon-fft-bench/src/1-d-fft/fft_logs/fft_benchmark_20260220_184713.report.md`

## Data Summary

- Parsed GPU RESULT rows: 295
- Aggregated GPU rows: 59
- GPU-vs-MKL overlap rows: 54
- GPU sets: ['32_to_4194304']
- Timing modes seen: ['e2e']

## Plot Case Catalog

- Throughput grid: 18 lengths x 3 batches = 54 cases
  lengths: [32, 64, 128, 256, 512, 1024, 2048, 4096, 8192, 16384, 32768, 65536, 131072, 262144, 524288, 1048576, 2097152, 4194304]
  batches: [1, 4, 16]
- Throughput case IDs:
  n32_b1, n32_b4, n32_b16, n64_b1, n64_b4, n64_b16, n128_b1, n128_b4, n128_b16, n256_b1, n256_b4, n256_b16, n512_b1, n512_b4, n512_b16, n1024_b1, n1024_b4, n1024_b16, n2048_b1, n2048_b4, n2048_b16, n4096_b1, n4096_b4, n4096_b16, n8192_b1, n8192_b4, n8192_b16, n16384_b1, n16384_b4, n16384_b16, n32768_b1, n32768_b4, n32768_b16, n65536_b1, n65536_b4, n65536_b16, n131072_b1, n131072_b4, n131072_b16, n262144_b1, n262144_b4, n262144_b16, n524288_b1, n524288_b4, n524288_b16, n1048576_b1, n1048576_b4, n1048576_b16, n2097152_b1, n2097152_b4, n2097152_b16, n4194304_b1, n4194304_b4, n4194304_b16
- Batch-scaling case IDs (5):
  n16384_b1_t1, n16384_b4_t1, n16384_b16_t1, n16384_b64_t1, n16384_b256_t1
- Latest set GPU>MKL forward win cases (13):
  n16384_b4, n32768_b4, n131072_b16, n262144_b16, n524288_b4, n524288_b16, n1048576_b4, n1048576_b16, n2097152_b4, n2097152_b16, n4194304_b1, n4194304_b4, n4194304_b16
- Latest set GPU>MKL backward win cases (13):
  n16384_b4, n32768_b4, n131072_b16, n262144_b16, n524288_b4, n524288_b16, n1048576_b4, n1048576_b16, n2097152_b4, n2097152_b16, n4194304_b1, n4194304_b4, n4194304_b16

## Figure Inventory

- cv_heatmaps: 2
- gpu_vs_mkl: 18
- individual_runs: 12
- latest_case_panels: 54
- set_pair_deltas: 0

## Key Interpretation

- `individual_runs`: each raw run line + per-set mean overlay, to inspect run drift.
- `cv_heatmaps`: per-case run-to-run variability (coefficient of variation).
- `set_pair_deltas`: pairwise latency ratio heatmaps across GPU sets.
- `gpu_vs_mkl`: explicit MKL-vs-GPU two-line overlays, speedup heatmaps, and win/loss counts.