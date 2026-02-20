# GPU Plot Generation

This directory contains plotting scripts for cuFFT benchmark manifests and GPU-vs-MKL comparisons.

## Install

```bash
python3 -m pip install --user -r requirements.txt
```

## Generate plots

```bash
python3 generate_gpu_plots.py
```

Optional:

```bash
python3 generate_gpu_plots.py \
  --gpu-root ../gpu \
  --out-dir ./out \
  --mkl-report ../1-d-fft/fft_logs/fft_benchmark_1d_5run_avg_20260219_162025.report.md \
  --manifests ../gpu/fft_logs/fft_benchmark_gpu_5run_32_to_4194304.manifest.txt \
              ../gpu/fft_logs/fft_benchmark_gpu_5run_repeat2_32_to_4194304.manifest.txt \
              ../gpu/fft_logs/fft_benchmark_gpu_5run_repeat3_32_to_4194304.manifest.txt
```

## Outputs

- `out/data/gpu_results_raw.csv`
- `out/data/gpu_results_aggregated.csv`
- `out/data/mkl_best_from_report.csv`
- `out/data/gpu_vs_mkl_cases.csv`
- `out/figures/gpu_runs/individual/*.png`
- `out/figures/gpu_runs/variability/*.png`
- `out/figures/gpu_runs/set_deltas/*.png`
- `out/figures/gpu_runs/latest_case_panels/*.png`
- `out/figures/gpu_vs_mkl/*.png`
- `out/PLOTS_README.md`
