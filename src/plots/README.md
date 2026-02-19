# Plot Generation

This directory contains scripts to generate visualization packs from raw FFT benchmark logs.

## Install

```bash
python3 -m pip install --user -r requirements.txt
```

## Generate plots

```bash
python3 generate_plots.py
```

Optional:

```bash
python3 generate_plots.py --src-root ../ --out-dir ./out --max-case-plots 0
```

- `--src-root`: root to scan for `fft_benchmark_*.log` (default `src/`)
- `--out-dir`: output root (default `src/plots/out`)
- `--max-case-plots`: cap per-case chart count per dataset (`0` means all)

## Outputs

- `out/data/results_raw.csv`
- `out/data/results_aggregated.csv`
- `out/figures/<dataset>/overview/*.png`
- `out/figures/<dataset>/trends/*.png`
- `out/figures/<dataset>/cases/*.png`
- `out/figures/<dataset>/scaling/*.png`
- `out/PLOTS_README.md`
