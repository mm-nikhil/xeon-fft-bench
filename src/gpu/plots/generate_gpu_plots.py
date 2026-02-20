#!/usr/bin/env python3
"""
Generate GPU-centric FFT plot pack from cuFFT manifests and compare to MKL report.

Outputs:
  - normalized CSVs under out/data
  - GPU run variability and set-to-set plots
  - GPU vs MKL comparison plots
  - PLOTS_README.md with case catalog and figure inventory
"""

from __future__ import annotations

import argparse
import itertools
import math
import re
import shutil
from pathlib import Path
from typing import Dict, List, Optional, Tuple

import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt
import numpy as np
import pandas as pd
import seaborn as sns


DEFAULT_MANIFEST_BASENAMES = [
    "fft_benchmark_gpu_5run_32_to_4194304.manifest.txt",
    "fft_benchmark_gpu_5run_repeat2_32_to_4194304.manifest.txt",
    "fft_benchmark_gpu_5run_repeat3_32_to_4194304.manifest.txt",
]


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="Generate GPU FFT plots and GPU-vs-MKL comparisons")
    parser.add_argument(
        "--gpu-root",
        default=str(Path(__file__).resolve().parents[1]),
        help="GPU root (default: src/gpu)",
    )
    parser.add_argument(
        "--out-dir",
        default=str(Path(__file__).resolve().parent / "out"),
        help="Output root directory",
    )
    parser.add_argument(
        "--manifests",
        nargs="*",
        default=None,
        help="Explicit manifest paths. If omitted, uses known defaults under gpu/fft_logs.",
    )
    parser.add_argument(
        "--mkl-report",
        default=None,
        help="MKL averaged report.md path. If omitted, uses latest src/1-d-fft/fft_logs/fft_benchmark_1d_5run_avg_*.report.md",
    )
    parser.add_argument(
        "--max-case-plots",
        type=int,
        default=0,
        help="Cap per-case panel plots for latest GPU set (0 = all)",
    )
    return parser.parse_args()


def safe_name(value: str) -> str:
    return re.sub(r"[^a-zA-Z0-9._-]+", "_", value).strip("_")


def manifest_set_id(manifest: Path) -> str:
    name = manifest.name
    if name.endswith(".manifest.txt"):
        name = name[: -len(".manifest.txt")]
    elif name.endswith(".txt"):
        name = name[: -len(".txt")]
    name = name.replace("fft_benchmark_gpu_5run_", "")
    name = name.replace("fft_benchmark_gpu_", "")
    return name


def find_latest_mkl_report(repo_src: Path) -> Path:
    logs_dir = repo_src / "1-d-fft" / "fft_logs"
    cands = sorted(logs_dir.glob("fft_benchmark_1d_5run_avg_*.report.md"))
    if not cands:
        raise FileNotFoundError(f"No MKL averaged report found in {logs_dir}")
    return cands[-1]


def discover_manifests(gpu_root: Path, explicit: Optional[List[str]]) -> List[Path]:
    if explicit:
        manifests = [Path(p).resolve() for p in explicit]
    else:
        logs_dir = gpu_root / "fft_logs"
        manifests = []
        for name in DEFAULT_MANIFEST_BASENAMES:
            p = logs_dir / name
            if p.is_file():
                manifests.append(p)
        if not manifests:
            manifests = sorted(logs_dir.glob("fft_benchmark_gpu_5run*.manifest.txt"))

    manifests = [m for m in manifests if m.is_file()]
    if not manifests:
        raise FileNotFoundError("No GPU manifests found")
    return manifests


def parse_manifest(manifest: Path, gpu_root: Path) -> List[Tuple[int, Path, Optional[Path]]]:
    rows: List[Tuple[int, Path, Optional[Path]]] = []
    lines = manifest.read_text(errors="replace").strip().splitlines()
    for line in lines[1:]:
        parts = line.split("|")
        if len(parts) < 2:
            continue
        run_idx = int(parts[0])
        log_rel = parts[1].strip()
        rpt_rel = parts[2].strip() if len(parts) > 2 else ""

        log_path = (gpu_root / log_rel).resolve()
        report_path = (gpu_root / rpt_rel).resolve() if rpt_rel else None
        if not log_path.is_file():
            raise FileNotFoundError(f"Missing log from manifest {manifest}: {log_rel}")
        rows.append((run_idx, log_path, report_path if report_path and report_path.is_file() else None))

    if not rows:
        raise ValueError(f"Manifest has no run rows: {manifest}")
    return rows


def parse_gpu_log(log_path: Path) -> List[Dict]:
    profile_timing: Dict[str, str] = {}
    rows: List[Dict] = []

    for raw in log_path.read_text(errors="replace").splitlines():
        if raw.startswith("PROFILE|"):
            p = raw.split("|")
            if len(p) >= 10:
                profile_timing[p[1]] = p[8]
            continue

        if not raw.startswith("RESULT|"):
            continue

        p = raw.split("|")
        if len(p) < 14:
            continue

        pid = p[1]
        workload = p[2]
        rows.append(
            {
                "source_log": str(log_path),
                "run_id": log_path.stem,
                "profile_id": pid,
                "workload": workload,
                "case_id": p[3],
                "n": int(p[4]),
                "batch": int(p[7]),
                "threads_field": int(p[8]),
                "fwd_ms": float(p[9]),
                "fwd_gflops": float(p[10]),
                "bwd_ms": float(p[11]),
                "bwd_gflops": float(p[12]),
                "mem_mb": float(p[13]),
                "timing_mode": profile_timing.get(pid, "unknown"),
            }
        )

    return rows


def build_gpu_data(manifests: List[Path], gpu_root: Path) -> Tuple[pd.DataFrame, pd.DataFrame]:
    all_rows: List[Dict] = []
    manifest_rows: List[Dict] = []

    for manifest in manifests:
        set_id = manifest_set_id(manifest)
        run_entries = parse_manifest(manifest, gpu_root)
        for run_idx, log_path, report_path in run_entries:
            manifest_rows.append(
                {
                    "set_id": set_id,
                    "manifest": str(manifest),
                    "run_index": run_idx,
                    "log_path": str(log_path),
                    "report_path": str(report_path) if report_path else "",
                }
            )
            run_rows = parse_gpu_log(log_path)
            for r in run_rows:
                r["set_id"] = set_id
                r["manifest"] = str(manifest)
                r["run_index"] = run_idx
            all_rows.extend(run_rows)

    if not all_rows:
        raise ValueError("No RESULT rows parsed from provided GPU manifests")

    raw = pd.DataFrame(all_rows)
    raw.sort_values(by=["set_id", "run_index", "profile_id", "workload", "n", "batch"], inplace=True)
    # Align aggregation methodology with shell aggregators:
    # average latency first, then derive GFLOPS from averaged latency.
    raw["fwd_flops"] = raw["fwd_gflops"] * raw["fwd_ms"] * 1.0e6
    raw["bwd_flops"] = raw["bwd_gflops"] * raw["bwd_ms"] * 1.0e6

    group_cols = [
        "set_id",
        "manifest",
        "profile_id",
        "workload",
        "case_id",
        "n",
        "batch",
        "threads_field",
        "timing_mode",
    ]
    agg = (
        raw.groupby(group_cols, dropna=False)
        .agg(
            run_count=("fwd_ms", "count"),
            fwd_ms_mean=("fwd_ms", "mean"),
            fwd_ms_std=("fwd_ms", "std"),
            bwd_ms_mean=("bwd_ms", "mean"),
            bwd_ms_std=("bwd_ms", "std"),
            fwd_flops_mean=("fwd_flops", "mean"),
            bwd_flops_mean=("bwd_flops", "mean"),
            fwd_gflops_mean_direct=("fwd_gflops", "mean"),
            fwd_gflops_std=("fwd_gflops", "std"),
            bwd_gflops_mean_direct=("bwd_gflops", "mean"),
            bwd_gflops_std=("bwd_gflops", "std"),
            mem_mb_mean=("mem_mb", "mean"),
        )
        .reset_index()
    )
    agg["fwd_gflops_mean"] = agg["fwd_flops_mean"] / (agg["fwd_ms_mean"] * 1.0e6)
    agg["bwd_gflops_mean"] = agg["bwd_flops_mean"] / (agg["bwd_ms_mean"] * 1.0e6)
    agg.drop(
        columns=[
            "fwd_flops_mean",
            "bwd_flops_mean",
            "fwd_gflops_mean_direct",
            "bwd_gflops_mean_direct",
        ],
        inplace=True,
    )
    for c in ["fwd_ms_std", "bwd_ms_std", "fwd_gflops_std", "bwd_gflops_std"]:
        agg[c] = agg[c].fillna(0.0)

    manifest_df = pd.DataFrame(manifest_rows)
    return raw, agg.merge(manifest_df[["set_id", "manifest"]].drop_duplicates(), on=["set_id", "manifest"], how="left")


def parse_mkl_report_best(report: Path) -> pd.DataFrame:
    rows = []
    for line in report.read_text(errors="replace").splitlines():
        line = line.strip()
        if not line.startswith("|") or line.startswith("|---"):
            continue

        cols = [c.strip() for c in line.strip("|").split("|")]

        # Legacy format:
        # | workload | case | length | batch | threads | profile | isa | fwd_ms | fwd_gflops | bwd_ms | bwd_gflops | ... |
        if len(cols) >= 11 and cols[0] == "throughput" and re.match(r"^n\d+_b\d+$", cols[1] or ""):
            try:
                n = int(cols[2])
                batch = int(cols[3])
                threads = int(cols[4])
                fwd_ms = float(cols[7])
                fwd_gflops = float(cols[8])
                bwd_ms = float(cols[9])
                bwd_gflops = float(cols[10])
            except ValueError:
                continue
            flops = 5.0 * float(n) * math.log2(float(n)) * float(batch)
            # Some markdown reports round tiny ms values to 0.0.
            # Recover them from GFLOPS so latency overlays remain meaningful.
            if fwd_ms <= 0.0 and fwd_gflops > 0.0:
                fwd_ms = flops / (fwd_gflops * 1.0e6)
            if bwd_ms <= 0.0 and bwd_gflops > 0.0:
                bwd_ms = flops / (bwd_gflops * 1.0e6)
            rows.append(
                {
                    "case_id": cols[1],
                    "n": n,
                    "batch": batch,
                    "threads": threads,
                    "profile_id": cols[5],
                    "isa": cols[6],
                    "fwd_ms": fwd_ms,
                    "fwd_gflops": fwd_gflops,
                    "bwd_ms": bwd_ms,
                    "bwd_gflops": bwd_gflops,
                }
            )
            continue

        # Current format:
        # | case | length | batch | threads | profile | isa | fwd_ms | fwd_gflops | bwd_ms | bwd_gflops | ... |
        if len(cols) >= 10 and re.match(r"^n\d+_b\d+$", cols[0] or ""):
            try:
                n = int(cols[1])
                batch = int(cols[2])
                threads = int(cols[3])
                fwd_ms = float(cols[6])
                fwd_gflops = float(cols[7])
                bwd_ms = float(cols[8])
                bwd_gflops = float(cols[9])
            except ValueError:
                continue
            flops = 5.0 * float(n) * math.log2(float(n)) * float(batch)
            if fwd_ms <= 0.0 and fwd_gflops > 0.0:
                fwd_ms = flops / (fwd_gflops * 1.0e6)
            if bwd_ms <= 0.0 and bwd_gflops > 0.0:
                bwd_ms = flops / (bwd_gflops * 1.0e6)
            rows.append(
                {
                    "case_id": cols[0],
                    "n": n,
                    "batch": batch,
                    "threads": threads,
                    "profile_id": cols[4],
                    "isa": cols[5],
                    "fwd_ms": fwd_ms,
                    "fwd_gflops": fwd_gflops,
                    "bwd_ms": bwd_ms,
                    "bwd_gflops": bwd_gflops,
                }
            )

    if not rows:
        raise ValueError(f"No throughput rows parsed from MKL report {report}")

    df = pd.DataFrame(rows)

    best_fwd_idx = df.groupby(["n", "batch"])["fwd_gflops"].idxmax()
    best_bwd_idx = df.groupby(["n", "batch"])["bwd_gflops"].idxmax()

    fwd = df.loc[best_fwd_idx, ["n", "batch", "profile_id", "fwd_ms", "fwd_gflops"]].rename(
        columns={
            "profile_id": "mkl_fwd_profile",
            "fwd_ms": "mkl_fwd_ms",
            "fwd_gflops": "mkl_fwd_gflops",
        }
    )
    bwd = df.loc[best_bwd_idx, ["n", "batch", "profile_id", "bwd_ms", "bwd_gflops"]].rename(
        columns={
            "profile_id": "mkl_bwd_profile",
            "bwd_ms": "mkl_bwd_ms",
            "bwd_gflops": "mkl_bwd_gflops",
        }
    )
    best = fwd.merge(bwd, on=["n", "batch"], how="inner")
    best.sort_values(by=["n", "batch"], inplace=True)
    return best


def geomean(values: List[float]) -> float:
    vals = [v for v in values if v > 0.0 and math.isfinite(v)]
    if not vals:
        return float("nan")
    return math.exp(sum(math.log(v) for v in vals) / len(vals))


def plot_individual_runs(df_raw_thr: pd.DataFrame, df_set_thr: pd.DataFrame, out_dir: Path) -> int:
    out_dir.mkdir(parents=True, exist_ok=True)
    n_plots = 0

    set_ids = sorted(df_raw_thr["set_id"].unique())
    batches = sorted(df_raw_thr["batch"].unique())
    palette = dict(zip(set_ids, sns.color_palette("tab10", n_colors=len(set_ids))))

    metrics = [
        ("fwd_gflops", "Forward SP GFLOPS", False),
        ("bwd_gflops", "Backward SP GFLOPS", False),
        ("fwd_ms", "Forward ms", True),
        ("bwd_ms", "Backward ms", True),
    ]

    for batch in batches:
        rsub = df_raw_thr[df_raw_thr["batch"] == batch].copy()
        asub = df_set_thr[df_set_thr["batch"] == batch].copy()
        if rsub.empty or asub.empty:
            continue

        for metric, y_label, y_log in metrics:
            plt.figure(figsize=(11.5, 6.2))
            for set_id in set_ids:
                sraw = rsub[rsub["set_id"] == set_id]
                sagg = asub[asub["set_id"] == set_id].sort_values("n")
                if sraw.empty or sagg.empty:
                    continue

                for run_idx in sorted(sraw["run_index"].unique()):
                    rr = sraw[sraw["run_index"] == run_idx].sort_values("n")
                    plt.plot(
                        rr["n"],
                        rr[metric],
                        color=palette[set_id],
                        alpha=0.25,
                        linewidth=1.0,
                    )

                mean_col = f"{metric}_mean"
                if mean_col in sagg.columns:
                    plt.plot(
                        sagg["n"],
                        sagg[mean_col],
                        color=palette[set_id],
                        linewidth=2.4,
                        marker="o",
                        label=f"{set_id} mean",
                    )

            plt.xscale("log", base=2)
            if y_log:
                plt.yscale("log")
            plt.grid(True, alpha=0.25)
            plt.xlabel("Length (N)")
            plt.ylabel(y_label)
            plt.title(f"GPU Individual Runs + Set Means | batch={batch} | {y_label}")
            plt.legend(fontsize=8)
            plt.tight_layout()
            out = out_dir / f"{safe_name(metric)}_batch_{batch}.png"
            plt.savefig(out, dpi=160)
            plt.close()
            n_plots += 1

    return n_plots


def plot_cv_heatmaps(df_raw_thr: pd.DataFrame, out_dir: Path) -> int:
    out_dir.mkdir(parents=True, exist_ok=True)
    n_plots = 0

    rows = []
    for (set_id, n, batch), g in df_raw_thr.groupby(["set_id", "n", "batch"], dropna=False):
        if len(g) < 2:
            continue
        fwd_mean = float(g["fwd_ms"].mean())
        bwd_mean = float(g["bwd_ms"].mean())
        fwd_std = float(g["fwd_ms"].std(ddof=1))
        bwd_std = float(g["bwd_ms"].std(ddof=1))
        rows.append(
            {
                "set_id": set_id,
                "n": int(n),
                "batch": int(batch),
                "fwd_cv_pct": 100.0 * (fwd_std / fwd_mean) if fwd_mean > 0.0 else np.nan,
                "bwd_cv_pct": 100.0 * (bwd_std / bwd_mean) if bwd_mean > 0.0 else np.nan,
            }
        )

    if not rows:
        return 0

    df_cv = pd.DataFrame(rows)
    for set_id in sorted(df_cv["set_id"].unique()):
        sub = df_cv[df_cv["set_id"] == set_id]
        for col, title in (("fwd_cv_pct", "Forward latency CV (%)"), ("bwd_cv_pct", "Backward latency CV (%)")):
            piv = sub.pivot(index="n", columns="batch", values=col).sort_index()
            plt.figure(figsize=(6.0, max(6.5, 0.30 * len(piv.index))))
            sns.heatmap(piv, cmap="magma", linewidths=0.2, linecolor="white", cbar_kws={"shrink": 0.8})
            plt.title(f"{set_id} | {title}")
            plt.xlabel("Batch")
            plt.ylabel("Length (N)")
            plt.tight_layout()
            out = out_dir / f"{safe_name(set_id)}_{safe_name(col)}.png"
            plt.savefig(out, dpi=160)
            plt.close()
            n_plots += 1

    return n_plots


def plot_set_pair_deltas(df_set_thr: pd.DataFrame, out_dir: Path) -> int:
    out_dir.mkdir(parents=True, exist_ok=True)
    n_plots = 0

    set_ids = sorted(df_set_thr["set_id"].unique())
    for a, b in itertools.combinations(set_ids, 2):
        da = df_set_thr[df_set_thr["set_id"] == a][["n", "batch", "fwd_ms_mean", "bwd_ms_mean"]]
        db = df_set_thr[df_set_thr["set_id"] == b][["n", "batch", "fwd_ms_mean", "bwd_ms_mean"]]
        m = da.merge(db, on=["n", "batch"], suffixes=("_a", "_b"))
        if m.empty:
            continue

        m["fwd_ratio_b_over_a"] = m["fwd_ms_mean_b"] / m["fwd_ms_mean_a"]
        m["bwd_ratio_b_over_a"] = m["bwd_ms_mean_b"] / m["bwd_ms_mean_a"]

        for col in ("fwd_ratio_b_over_a", "bwd_ratio_b_over_a"):
            piv = m.pivot(index="n", columns="batch", values=col).sort_index()
            plt.figure(figsize=(6.0, max(6.5, 0.30 * len(piv.index))))
            sns.heatmap(
                piv,
                cmap="RdYlGn_r",
                center=1.0,
                linewidths=0.2,
                linecolor="white",
                cbar_kws={"shrink": 0.8},
            )
            plt.title(f"{b} vs {a} | {col} (ms)")
            plt.xlabel("Batch")
            plt.ylabel("Length (N)")
            plt.tight_layout()
            out = out_dir / f"{safe_name(b)}_vs_{safe_name(a)}_{safe_name(col)}.png"
            plt.savefig(out, dpi=160)
            plt.close()
            n_plots += 1

    return n_plots


def plot_gpu_vs_mkl(df_cmp: pd.DataFrame, out_dir: Path) -> int:
    out_dir.mkdir(parents=True, exist_ok=True)
    n_plots = 0

    set_ids = sorted(df_cmp["set_id"].unique())
    batches = sorted(df_cmp["batch"].unique())
    timing_modes = sorted(df_cmp["timing_mode"].dropna().unique().tolist())
    timing_mode_str = ",".join(timing_modes) if timing_modes else "unknown"
    timing_note = f"GPU timing={timing_mode_str}; MKL timing=compute-only"
    latest_set = set_ids[-1]
    latest = df_cmp[df_cmp["set_id"] == latest_set].copy()
    latest.sort_values(by=["n", "batch"], inplace=True)

    def _two_line_overlay(
        batch_df: pd.DataFrame,
        gpu_col: str,
        mkl_col: str,
        title: str,
        ylabel: str,
        better_when: str,
        out_name: str,
    ) -> None:
        n_vals = batch_df["n"].to_numpy()
        gpu = batch_df[gpu_col].to_numpy(dtype=float)
        mkl = batch_df[mkl_col].to_numpy(dtype=float)

        if better_when == "higher":
            gpu_better = gpu > mkl
            gpu_worse = gpu < mkl
        else:
            gpu_better = gpu < mkl
            gpu_worse = gpu > mkl
        tied = ~(gpu_better | gpu_worse)

        plt.figure(figsize=(11.6, 6.2))
        plt.plot(n_vals, mkl, marker="o", linewidth=2.2, color="#1f77b4", label="MKL best (latest CPU run)")
        plt.plot(n_vals, gpu, marker="o", linewidth=2.2, color="#ff7f0e", label=f"GPU latest ({latest_set})")

        if np.any(gpu_better):
            plt.scatter(
                n_vals[gpu_better],
                gpu[gpu_better],
                s=45,
                color="#2ca02c",
                edgecolors="black",
                linewidths=0.4,
                label="GPU better",
                zorder=5,
            )
        if np.any(gpu_worse):
            plt.scatter(
                n_vals[gpu_worse],
                gpu[gpu_worse],
                s=45,
                color="#d62728",
                edgecolors="black",
                linewidths=0.4,
                label="GPU worse",
                zorder=5,
            )
        if np.any(tied):
            plt.scatter(
                n_vals[tied],
                gpu[tied],
                s=45,
                color="#7f7f7f",
                edgecolors="black",
                linewidths=0.4,
                label="Tie",
                zorder=5,
            )

        plt.xscale("log", base=2)
        plt.grid(True, alpha=0.25)
        plt.xlabel("Length (N)")
        plt.ylabel(ylabel)
        plt.title(
            f"{title} | batch={int(batch_df['batch'].iloc[0])}\n"
            f"{timing_note} | GPU better={int(gpu_better.sum())}/{len(batch_df)}"
        )
        plt.legend(fontsize=8, ncol=2)
        plt.tight_layout()
        out = out_dir / out_name
        plt.savefig(out, dpi=160)
        plt.close()

    # Absolute overlays (two lines per chart): MKL vs latest GPU.
    for batch in batches:
        sub = latest[latest["batch"] == batch].sort_values("n")
        if sub.empty:
            continue
        _two_line_overlay(
            sub,
            "fwd_gflops_mean",
            "mkl_fwd_gflops",
            "Forward SP GFLOPS: GPU vs MKL",
            "SP GFLOPS",
            "higher",
            f"fwd_gflops_gpu_vs_mkl_batch_{batch}.png",
        )
        n_plots += 1
        _two_line_overlay(
            sub,
            "bwd_gflops_mean",
            "mkl_bwd_gflops",
            "Backward SP GFLOPS: GPU vs MKL",
            "SP GFLOPS",
            "higher",
            f"bwd_gflops_gpu_vs_mkl_batch_{batch}.png",
        )
        n_plots += 1
        _two_line_overlay(
            sub,
            "fwd_ms_mean",
            "mkl_fwd_ms",
            "Forward latency: GPU vs MKL",
            "ms",
            "lower",
            f"fwd_ms_gpu_vs_mkl_batch_{batch}.png",
        )
        n_plots += 1
        _two_line_overlay(
            sub,
            "bwd_ms_mean",
            "mkl_bwd_ms",
            "Backward latency: GPU vs MKL",
            "ms",
            "lower",
            f"bwd_ms_gpu_vs_mkl_batch_{batch}.png",
        )
        n_plots += 1

    # Heatmaps make better/worse cases explicit at a glance.
    for col, title, out_name in (
        ("fwd_gflops_speedup_vs_mkl", "Forward GFLOPS speedup (GPU / MKL)", "heatmap_fwd_gflops_speedup.png"),
        ("bwd_gflops_speedup_vs_mkl", "Backward GFLOPS speedup (GPU / MKL)", "heatmap_bwd_gflops_speedup.png"),
        ("fwd_latency_speedup_vs_mkl", "Forward latency speedup (MKL / GPU)", "heatmap_fwd_latency_speedup.png"),
        ("bwd_latency_speedup_vs_mkl", "Backward latency speedup (MKL / GPU)", "heatmap_bwd_latency_speedup.png"),
    ):
        piv = latest.pivot(index="n", columns="batch", values=col).sort_index()
        plt.figure(figsize=(6.6, max(6.5, 0.32 * len(piv.index))))
        sns.heatmap(
            piv,
            cmap="RdYlGn",
            center=1.0,
            linewidths=0.2,
            linecolor="white",
            cbar_kws={"shrink": 0.85},
        )
        plt.title(f"{title}\nlatest GPU set={latest_set}")
        plt.xlabel("Batch")
        plt.ylabel("Length (N)")
        plt.tight_layout()
        out = out_dir / out_name
        plt.savefig(out, dpi=160)
        plt.close()
        n_plots += 1

    # Win counts by batch for quick reading.
    win_rows = []
    for batch, g in latest.groupby("batch", dropna=False):
        win_rows.append(
            {
                "batch": int(batch),
                "fwd_win": int((g["fwd_gflops_speedup_vs_mkl"] > 1.0).sum()),
                "fwd_loss": int((g["fwd_gflops_speedup_vs_mkl"] < 1.0).sum()),
                "bwd_win": int((g["bwd_gflops_speedup_vs_mkl"] > 1.0).sum()),
                "bwd_loss": int((g["bwd_gflops_speedup_vs_mkl"] < 1.0).sum()),
            }
        )
    wdf = pd.DataFrame(win_rows).sort_values("batch")
    x = np.arange(len(wdf))
    width = 0.36
    for win_col, loss_col, title, out_name in (
        ("fwd_win", "fwd_loss", "Forward win/loss count by batch", "wins_fwd_gflops_speedup.png"),
        ("bwd_win", "bwd_loss", "Backward win/loss count by batch", "wins_bwd_gflops_speedup.png"),
    ):
        plt.figure(figsize=(8.5, 5.0))
        plt.bar(x - width / 2, wdf[win_col], width=width, label="GPU better", color="#2ca02c")
        plt.bar(x + width / 2, wdf[loss_col], width=width, label="GPU worse", color="#d62728")
        plt.xticks(x, [str(v) for v in wdf["batch"]])
        plt.xlabel("Batch")
        plt.ylabel("Case count")
        plt.title(f"{title}\nlatest GPU set={latest_set}")
        plt.grid(True, axis="y", alpha=0.25)
        plt.legend()
        plt.tight_layout()
        out = out_dir / out_name
        plt.savefig(out, dpi=160)
        plt.close()
        n_plots += 1

    return n_plots


def plot_case_panels_latest_set(df_latest_thr: pd.DataFrame, out_dir: Path, max_case_plots: int) -> int:
    out_dir.mkdir(parents=True, exist_ok=True)
    n_plots = 0

    cases = (
        df_latest_thr[["case_id", "n", "batch"]]
        .drop_duplicates()
        .sort_values(by=["n", "batch"])
    )
    case_ids = cases["case_id"].tolist()
    if max_case_plots > 0:
        case_ids = case_ids[:max_case_plots]

    runs = sorted(df_latest_thr["run_index"].unique())
    for case_id in case_ids:
        sub = df_latest_thr[df_latest_thr["case_id"] == case_id].copy()
        if sub.empty:
            continue

        fig, axes = plt.subplots(2, 2, figsize=(12.5, 8.5))
        n_val = int(sub["n"].iloc[0])
        b_val = int(sub["batch"].iloc[0])
        fig.suptitle(f"GPU latest set | {case_id} | n={n_val}, batch={b_val}")

        metrics = [
            ("fwd_gflops", "Forward SP GFLOPS"),
            ("bwd_gflops", "Backward SP GFLOPS"),
            ("fwd_ms", "Forward ms"),
            ("bwd_ms", "Backward ms"),
        ]

        for ax, (metric, title) in zip(axes.flatten(), metrics):
            vals = []
            for r in runs:
                rv = sub[sub["run_index"] == r][metric]
                if not rv.empty:
                    vals.append(float(rv.iloc[0]))
            x = np.arange(len(vals))
            ax.plot(x, vals, marker="o")
            ax.set_xticks(x)
            ax.set_xticklabels([str(r) for r in runs[: len(vals)]])
            ax.set_title(title)
            ax.grid(True, alpha=0.25)
            if metric.endswith("ms"):
                pos = [v for v in vals if v > 0]
                if len(pos) >= 2 and max(pos) / min(pos) > 20:
                    ax.set_yscale("log")

        plt.tight_layout(rect=[0, 0.02, 1, 0.95])
        out = out_dir / f"{safe_name(case_id)}.png"
        plt.savefig(out, dpi=160)
        plt.close()
        n_plots += 1

    return n_plots


def build_compare_table(df_agg: pd.DataFrame, mkl_best: pd.DataFrame) -> pd.DataFrame:
    gpu_thr = df_agg[(df_agg["profile_id"] == "cufft_gpu") & (df_agg["workload"] == "throughput")].copy()
    cmp = gpu_thr.merge(mkl_best, on=["n", "batch"], how="inner")
    cmp["fwd_gflops_speedup_vs_mkl"] = cmp["fwd_gflops_mean"] / cmp["mkl_fwd_gflops"]
    cmp["bwd_gflops_speedup_vs_mkl"] = cmp["bwd_gflops_mean"] / cmp["mkl_bwd_gflops"]
    cmp["fwd_latency_speedup_vs_mkl"] = cmp["mkl_fwd_ms"] / cmp["fwd_ms_mean"]
    cmp["bwd_latency_speedup_vs_mkl"] = cmp["mkl_bwd_ms"] / cmp["bwd_ms_mean"]
    cmp["gpu_beats_mkl_fwd"] = cmp["fwd_gflops_speedup_vs_mkl"] > 1.0
    cmp["gpu_beats_mkl_bwd"] = cmp["bwd_gflops_speedup_vs_mkl"] > 1.0
    cmp.sort_values(by=["set_id", "n", "batch"], inplace=True)
    return cmp


def format_pct(v: float) -> str:
    if not math.isfinite(v):
        return "nan"
    return f"{v * 100.0:.2f}%"


def write_readme(
    out_root: Path,
    manifests: List[Path],
    mkl_report: Path,
    df_raw: pd.DataFrame,
    df_agg: pd.DataFrame,
    df_cmp: pd.DataFrame,
    figure_counts: Dict[str, int],
) -> None:
    path = out_root / "PLOTS_README.md"
    lines: List[str] = []

    lines.append("# GPU FFT Plot Pack")
    lines.append("")
    lines.append("This folder contains plots generated from GPU manifest runs and MKL averaged report data.")
    lines.append("")
    lines.append("## Inputs")
    lines.append("")
    lines.append(f"- GPU manifests: {len(manifests)}")
    for m in manifests:
        lines.append(f"- `{m}`")
    lines.append(f"- MKL reference report: `{mkl_report}`")
    lines.append("")

    lines.append("## Data Summary")
    lines.append("")
    lines.append(f"- Parsed GPU RESULT rows: {len(df_raw)}")
    lines.append(f"- Aggregated GPU rows: {len(df_agg)}")
    lines.append(f"- GPU-vs-MKL overlap rows: {len(df_cmp)}")
    lines.append(f"- GPU sets: {sorted(df_raw['set_id'].unique().tolist())}")
    lines.append(f"- Timing modes seen: {sorted(df_raw['timing_mode'].dropna().unique().tolist())}")
    lines.append("")

    # Case catalog.
    thr = df_raw[(df_raw["profile_id"] == "cufft_gpu") & (df_raw["workload"] == "throughput")]
    lengths = sorted(thr["n"].unique().tolist())
    batches = sorted(thr["batch"].unique().tolist())
    case_ids = (
        thr[["case_id", "n", "batch"]]
        .drop_duplicates()
        .sort_values(by=["n", "batch"])["case_id"]
        .tolist()
    )

    bs = df_raw[(df_raw["profile_id"] == "cufft_gpu_batch_scaling") & (df_raw["workload"] == "batch_scaling")]
    bs_cases = (
        bs[["case_id", "n", "batch"]]
        .drop_duplicates()
        .sort_values(by=["n", "batch"])["case_id"]
        .tolist()
    )

    latest_set = sorted(df_cmp["set_id"].unique().tolist())[-1] if not df_cmp.empty else None
    if latest_set is not None:
        latest_cmp = df_cmp[df_cmp["set_id"] == latest_set]
        fwd_wins = latest_cmp[latest_cmp["gpu_beats_mkl_fwd"]].sort_values(by=["n", "batch"])
        bwd_wins = latest_cmp[latest_cmp["gpu_beats_mkl_bwd"]].sort_values(by=["n", "batch"])
        fwd_win_ids = fwd_wins["case_id"].tolist()
        bwd_win_ids = bwd_wins["case_id"].tolist()
    else:
        fwd_win_ids = []
        bwd_win_ids = []

    lines.append("## Plot Case Catalog")
    lines.append("")
    lines.append(f"- Throughput grid: {len(lengths)} lengths x {len(batches)} batches = {len(case_ids)} cases")
    lines.append(f"  lengths: {lengths}")
    lines.append(f"  batches: {batches}")
    lines.append("- Throughput case IDs:")
    lines.append(f"  {', '.join(case_ids)}")
    lines.append(f"- Batch-scaling case IDs ({len(bs_cases)}):")
    lines.append(f"  {', '.join(bs_cases)}")
    lines.append(f"- Latest set GPU>MKL forward win cases ({len(fwd_win_ids)}):")
    lines.append(f"  {', '.join(fwd_win_ids) if fwd_win_ids else '-'}")
    lines.append(f"- Latest set GPU>MKL backward win cases ({len(bwd_win_ids)}):")
    lines.append(f"  {', '.join(bwd_win_ids) if bwd_win_ids else '-'}")
    lines.append("")

    lines.append("## Figure Inventory")
    lines.append("")
    for k, v in sorted(figure_counts.items()):
        lines.append(f"- {k}: {v}")
    lines.append("")
    lines.append("## Key Interpretation")
    lines.append("")
    lines.append("- `individual_runs`: each raw run line + per-set mean overlay, to inspect run drift.")
    lines.append("- `cv_heatmaps`: per-case run-to-run variability (coefficient of variation).")
    lines.append("- `set_pair_deltas`: pairwise latency ratio heatmaps across GPU sets.")
    lines.append("- `gpu_vs_mkl`: explicit MKL-vs-GPU two-line overlays, speedup heatmaps, and win/loss counts.")

    path.write_text("\n".join(lines))


def main() -> None:
    args = parse_args()
    gpu_root = Path(args.gpu_root).resolve()
    out_root = Path(args.out_dir).resolve()
    repo_src = gpu_root.parent

    manifests = discover_manifests(gpu_root, args.manifests)
    mkl_report = Path(args.mkl_report).resolve() if args.mkl_report else find_latest_mkl_report(repo_src)

    sns.set_theme(style="whitegrid", context="notebook")

    # Deterministic reruns: wipe stale output subtree.
    shutil.rmtree(out_root, ignore_errors=True)
    (out_root / "data").mkdir(parents=True, exist_ok=True)

    df_raw, df_agg = build_gpu_data(manifests, gpu_root)
    mkl_best = parse_mkl_report_best(mkl_report)
    df_cmp = build_compare_table(df_agg, mkl_best)

    # Persist data tables.
    raw_csv = out_root / "data" / "gpu_results_raw.csv"
    agg_csv = out_root / "data" / "gpu_results_aggregated.csv"
    mkl_csv = out_root / "data" / "mkl_best_from_report.csv"
    cmp_csv = out_root / "data" / "gpu_vs_mkl_cases.csv"

    df_raw.to_csv(raw_csv, index=False)
    df_agg.to_csv(agg_csv, index=False)
    mkl_best.to_csv(mkl_csv, index=False)
    df_cmp.to_csv(cmp_csv, index=False)

    # Plot groups.
    fig_root = out_root / "figures"
    gpu_thr_raw = df_raw[(df_raw["profile_id"] == "cufft_gpu") & (df_raw["workload"] == "throughput")].copy()
    gpu_thr_set = df_agg[(df_agg["profile_id"] == "cufft_gpu") & (df_agg["workload"] == "throughput")].copy()

    counts: Dict[str, int] = {}
    counts["individual_runs"] = plot_individual_runs(gpu_thr_raw, gpu_thr_set, fig_root / "gpu_runs" / "individual")
    counts["cv_heatmaps"] = plot_cv_heatmaps(gpu_thr_raw, fig_root / "gpu_runs" / "variability")
    counts["set_pair_deltas"] = plot_set_pair_deltas(gpu_thr_set, fig_root / "gpu_runs" / "set_deltas")
    counts["gpu_vs_mkl"] = plot_gpu_vs_mkl(df_cmp, fig_root / "gpu_vs_mkl")

    latest_set = sorted(gpu_thr_raw["set_id"].unique())[-1]
    latest_raw = gpu_thr_raw[gpu_thr_raw["set_id"] == latest_set].copy()
    counts["latest_case_panels"] = plot_case_panels_latest_set(
        latest_raw,
        fig_root / "gpu_runs" / "latest_case_panels",
        args.max_case_plots,
    )

    write_readme(out_root, manifests, mkl_report, df_raw, df_agg, df_cmp, counts)

    print(f"GPU manifests: {len(manifests)}")
    for m in manifests:
        print(f"  - {m}")
    print(f"MKL report: {mkl_report}")
    print(f"Raw CSV: {raw_csv}")
    print(f"Agg CSV: {agg_csv}")
    print(f"Compare CSV: {cmp_csv}")
    print(f"Figures root: {fig_root}")
    for k in sorted(counts):
        print(f"{k}: {counts[k]}")


if __name__ == "__main__":
    main()
