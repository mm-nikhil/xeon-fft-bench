#!/usr/bin/env python3
"""
Generate overview and case-level FFT benchmark plots from raw log files.

Reads RESULT|... lines (and PROFILE metadata) from fft_benchmark_*.log files
and creates:
  - normalized CSV datasets
  - aggregated metric tables
  - overview heatmaps and trend plots
  - per-case comparison plots across profiles
  - thread/batch scaling plots
"""

from __future__ import annotations

import argparse
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


PROFILE_ORDER = [
    "baseline_sse42_1t",
    "avx2_1t",
    "avx512_1t",
    "avx2_phys",
    "avx512_phys",
    "avx512_logical",
    "avx512_thread_scaling",
    "avx512_batch_scaling",
]


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="Generate FFT plots from logs")
    parser.add_argument(
        "--src-root",
        default=str(Path(__file__).resolve().parents[1]),
        help="Root directory to scan for fft_benchmark_*.log",
    )
    parser.add_argument(
        "--out-dir",
        default=str(Path(__file__).resolve().parent / "out"),
        help="Output directory for csv + figures",
    )
    parser.add_argument(
        "--pattern",
        default="fft_benchmark_*.log",
        help="Log filename pattern",
    )
    parser.add_argument(
        "--max-case-plots",
        type=int,
        default=0,
        help="Limit case-level plots per dataset (0 = all)",
    )
    return parser.parse_args()


def profile_sort_key(profile_id: str) -> Tuple[int, str]:
    try:
        return (PROFILE_ORDER.index(profile_id), profile_id)
    except ValueError:
        return (999, profile_id)


def safe_name(value: str) -> str:
    return re.sub(r"[^a-zA-Z0-9._-]+", "_", value).strip("_")


def discover_logs(src_root: Path, pattern: str) -> List[Path]:
    logs = sorted(src_root.rglob(pattern))
    return [p for p in logs if p.is_file()]


def detect_precision_from_header(lines: List[str], path: Path) -> str:
    blob = "\n".join(lines[:200]).lower()
    pstr = str(path).lower()
    if "single precision" in blob:
        return "single"
    if "double precision" in blob:
        return "double"
    if "/1-d-fft/" in pstr:
        return "single"
    return "double"


def parse_log_file(path: Path) -> List[Dict]:
    rows: List[Dict] = []
    text = path.read_text(errors="replace")
    lines = text.splitlines()
    precision_hint = detect_precision_from_header(lines, path)

    profile_meta: Dict[str, Dict] = {}

    for line in lines:
        if line.startswith("PROFILE|"):
            parts = line.split("|")
            if len(parts) < 12:
                continue
            pid = parts[1]
            profile_meta[pid] = {
                "profile_id": pid,
                "profile_desc": parts[2],
                "isa": parts[3],
                "profile_threads": int(parts[4]),
                "workload_profile": parts[5],
                "lengths_cfg": parts[6],
                "batches_cfg": parts[7],
            }
            continue

        if not line.startswith("RESULT|"):
            continue

        parts = line.split("|")
        if len(parts) < 14:
            continue

        pid = parts[1]
        workload = parts[2]
        case_id = parts[3]
        nx = int(parts[4])
        ny = int(parts[5])
        nz = int(parts[6])
        batch = int(parts[7])
        threads = int(parts[8])
        fwd_ms = float(parts[9])
        fwd_gflops = float(parts[10])
        bwd_ms = float(parts[11])
        bwd_gflops = float(parts[12])
        mem_mb = float(parts[13])

        family = "1d" if ny == 1 and nz == 1 else "3d"
        precision = "single" if family == "1d" and precision_hint == "single" else (
            "double" if family == "3d" else precision_hint
        )
        dataset_id = f"{family}_{precision}"

        meta = profile_meta.get(pid, {})
        if workload == "thread_scaling":
            scenario_id = f"n{nx}_b{batch}"
            sweep_var = "threads"
            sweep_value = threads
        elif workload == "batch_scaling":
            scenario_id = f"n{nx}_t{threads}"
            sweep_var = "batch"
            sweep_value = batch
        else:
            scenario_id = case_id
            sweep_var = "length"
            sweep_value = nx

        rows.append(
            {
                "source_log": str(path),
                "source_rel": str(path),
                "run_id": path.stem.replace("fft_benchmark_", ""),
                "dataset_id": dataset_id,
                "family": family,
                "precision": precision,
                "workload": workload,
                "scenario_id": scenario_id,
                "case_id": case_id,
                "nx": nx,
                "ny": ny,
                "nz": nz,
                "grid": f"{nx}x{ny}x{nz}",
                "batch": batch,
                "threads": threads,
                "sweep_var": sweep_var,
                "sweep_value": sweep_value,
                "profile_id": pid,
                "profile_desc": meta.get("profile_desc", ""),
                "isa": meta.get("isa", ""),
                "profile_threads": meta.get("profile_threads", threads),
                "fwd_ms": fwd_ms,
                "fwd_gflops": fwd_gflops,
                "bwd_ms": bwd_ms,
                "bwd_gflops": bwd_gflops,
                "mem_mb": mem_mb,
            }
        )

    return rows


def aggregate_metrics(df: pd.DataFrame) -> pd.DataFrame:
    # Keep aggregation methodology aligned with shell aggregators:
    # average latency first, then derive GFLOPS from averaged latency.
    df = df.copy()
    df["fwd_flops"] = df["fwd_gflops"] * df["fwd_ms"] * 1.0e6
    df["bwd_flops"] = df["bwd_gflops"] * df["bwd_ms"] * 1.0e6

    group_cols = [
        "dataset_id",
        "family",
        "precision",
        "workload",
        "scenario_id",
        "case_id",
        "nx",
        "ny",
        "nz",
        "grid",
        "batch",
        "threads",
        "sweep_var",
        "sweep_value",
        "profile_id",
        "profile_desc",
        "isa",
    ]
    agg = (
        df.groupby(group_cols, dropna=False)
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

    for c in [
        "fwd_ms_std",
        "bwd_ms_std",
        "fwd_gflops_std",
        "bwd_gflops_std",
    ]:
        agg[c] = agg[c].fillna(0.0)

    # Exact memory for out-of-place complex FFT: in + out.
    # single (complex8): 8 bytes/element, double (complex16): 16 bytes/element
    bytes_per_complex = np.where(agg["precision"] == "single", 8.0, 16.0)
    agg["mem_kib_exact"] = (
        2.0 * agg["nx"].astype(float) * agg["ny"].astype(float) * agg["nz"].astype(float)
        * agg["batch"].astype(float) * bytes_per_complex / 1024.0
    )

    # Throughput-only speedups vs SSE4.2 baseline.
    throughput = agg[agg["workload"] == "throughput"].copy()
    baseline = throughput[throughput["profile_id"] == "baseline_sse42_1t"][
        [
            "dataset_id",
            "case_id",
            "nx",
            "ny",
            "nz",
            "batch",
            "fwd_gflops_mean",
            "bwd_gflops_mean",
        ]
    ].rename(
        columns={
            "fwd_gflops_mean": "base_fwd_gflops",
            "bwd_gflops_mean": "base_bwd_gflops",
        }
    )
    agg = agg.merge(
        baseline,
        how="left",
        on=["dataset_id", "case_id", "nx", "ny", "nz", "batch"],
    )
    agg["fwd_speedup_vs_baseline"] = agg["fwd_gflops_mean"] / agg["base_fwd_gflops"]
    agg["bwd_speedup_vs_baseline"] = agg["bwd_gflops_mean"] / agg["base_bwd_gflops"]
    agg["fwd_increase_pct"] = (agg["fwd_speedup_vs_baseline"] - 1.0) * 100.0
    agg["bwd_increase_pct"] = (agg["bwd_speedup_vs_baseline"] - 1.0) * 100.0

    return agg


def _case_sort(df_case: pd.DataFrame) -> pd.DataFrame:
    sort_cols = [c for c in ["nx", "ny", "nz", "batch", "threads"] if c in df_case.columns]
    return df_case.sort_values(by=sort_cols)


def _metric_label(precision: str) -> str:
    return "SP GFLOPS" if precision == "single" else "DP GFLOPS"


def plot_heatmap(
    df_t: pd.DataFrame,
    metric_col: str,
    title: str,
    out_path: Path,
    center: Optional[float] = None,
    cmap: str = "viridis",
) -> None:
    ordered = _case_sort(df_t[["case_id", "nx", "ny", "nz", "batch"]].drop_duplicates())
    case_order = ordered["case_id"].tolist()
    piv = df_t.pivot_table(index="case_id", columns="profile_id", values=metric_col, aggfunc="mean")
    piv = piv.reindex(index=case_order)
    cols = sorted(piv.columns.tolist(), key=profile_sort_key)
    piv = piv.reindex(columns=cols)

    h = max(6, 0.28 * max(1, len(piv.index)))
    w = max(10, 1.2 * max(1, len(piv.columns)) + 4)
    plt.figure(figsize=(w, h))
    annotate = len(piv.index) <= 28
    sns.heatmap(
        piv,
        cmap=cmap,
        center=center,
        linewidths=0.2,
        linecolor="white",
        annot=annotate,
        fmt=".2f",
        cbar_kws={"shrink": 0.7},
    )
    plt.title(title)
    plt.xlabel("Profile")
    plt.ylabel("Case")
    plt.tight_layout()
    out_path.parent.mkdir(parents=True, exist_ok=True)
    plt.savefig(out_path, dpi=160)
    plt.close()


def plot_trend_by_batch(
    df_t: pd.DataFrame,
    metric_col: str,
    y_label: str,
    title_prefix: str,
    out_dir: Path,
    y_log: bool = False,
) -> None:
    for batch in sorted(df_t["batch"].dropna().unique()):
        sub = df_t[df_t["batch"] == batch].copy()
        if sub.empty:
            continue

        plt.figure(figsize=(11, 6))
        for pid in sorted(sub["profile_id"].unique(), key=profile_sort_key):
            s = sub[sub["profile_id"] == pid].sort_values("nx")
            plt.plot(s["nx"], s[metric_col], marker="o", linewidth=1.8, label=pid)
        plt.xscale("log", base=2)
        if y_log:
            plt.yscale("log")
        plt.grid(True, alpha=0.25)
        plt.xlabel("Length (N)")
        plt.ylabel(y_label)
        plt.title(f"{title_prefix} | batch={batch}")
        plt.legend(fontsize=8, ncol=2)
        plt.tight_layout()
        out = out_dir / f"{safe_name(metric_col)}_batch_{batch}.png"
        out.parent.mkdir(parents=True, exist_ok=True)
        plt.savefig(out, dpi=160)
        plt.close()


def plot_case_panels(df_case: pd.DataFrame, out_path: Path, precision: str) -> None:
    order = sorted(df_case["profile_id"].unique(), key=profile_sort_key)
    d = df_case.set_index("profile_id").reindex(order).reset_index()

    fig, axes = plt.subplots(2, 2, figsize=(14, 9))
    fig.suptitle(
        f"Case {d['case_id'].iloc[0]} | n={int(d['nx'].iloc[0])}, batch={int(d['batch'].iloc[0])}"
    )
    metrics = [
        ("fwd_gflops_mean", "fwd_gflops_std", f"Forward {_metric_label(precision)}"),
        ("bwd_gflops_mean", "bwd_gflops_std", f"Backward {_metric_label(precision)}"),
        ("fwd_ms_mean", "fwd_ms_std", "Forward ms"),
        ("bwd_ms_mean", "bwd_ms_std", "Backward ms"),
    ]
    for ax, (m, s, title) in zip(axes.flatten(), metrics):
        x = np.arange(len(d))
        vals = d[m].to_numpy()
        errs = d[s].to_numpy()
        ax.bar(x, vals, yerr=errs, capsize=3)
        ax.set_xticks(x)
        ax.set_xticklabels(d["profile_id"], rotation=30, ha="right", fontsize=8)
        ax.set_title(title)
        ax.grid(True, axis="y", alpha=0.25)
        if m.endswith("_ms_mean"):
            vmin = np.nanmin(vals[vals > 0]) if np.any(vals > 0) else 0.0
            vmax = np.nanmax(vals)
            if vmin > 0 and vmax / vmin > 20:
                ax.set_yscale("log")
    plt.tight_layout(rect=[0, 0.02, 1, 0.96])
    out_path.parent.mkdir(parents=True, exist_ok=True)
    plt.savefig(out_path, dpi=160)
    plt.close()


def plot_scaling(df: pd.DataFrame, workload: str, out_dir: Path, precision: str) -> None:
    sub = df[df["workload"] == workload].copy()
    if sub.empty:
        return

    if workload == "thread_scaling":
        xcol = "threads"
        xlabel = "Threads"
    else:
        xcol = "batch"
        xlabel = "Batch"

    for scen in sorted(sub["scenario_id"].dropna().unique()):
        s = sub[sub["scenario_id"] == scen].sort_values(xcol)
        if s.empty:
            continue
        fig, axes = plt.subplots(2, 2, figsize=(12.8, 8.8))
        for pid in sorted(s["profile_id"].unique(), key=profile_sort_key):
            p = s[s["profile_id"] == pid].sort_values(xcol)
            axes[0, 0].plot(p[xcol], p["fwd_gflops_mean"], marker="o", label=pid)
            axes[0, 1].plot(p[xcol], p["bwd_gflops_mean"], marker="o", label=pid)
            axes[1, 0].plot(p[xcol], p["fwd_ms_mean"], marker="o", label=pid)
            axes[1, 1].plot(p[xcol], p["bwd_ms_mean"], marker="o", label=pid)

        axes[0, 0].set_title(f"{workload} {scen} | Forward {_metric_label(precision)}")
        axes[0, 1].set_title(f"{workload} {scen} | Backward {_metric_label(precision)}")
        axes[1, 0].set_title(f"{workload} {scen} | Forward ms")
        axes[1, 1].set_title(f"{workload} {scen} | Backward ms")

        for ax in axes.flatten():
            ax.set_xlabel(xlabel)
            ax.set_xscale("log", base=2)
            ax.grid(True, alpha=0.25)

        axes[1, 0].set_yscale("log")
        axes[1, 1].set_yscale("log")
        axes[0, 0].legend(fontsize=8)
        plt.tight_layout()
        out = out_dir / f"{safe_name(workload)}_{safe_name(scen)}.png"
        out.parent.mkdir(parents=True, exist_ok=True)
        plt.savefig(out, dpi=160)
        plt.close()


def generate_for_dataset(df_agg: pd.DataFrame, dataset_id: str, out_root: Path, max_case_plots: int) -> Dict[str, int]:
    d = df_agg[df_agg["dataset_id"] == dataset_id].copy()
    if d.empty:
        return {}

    precision = d["precision"].iloc[0]
    throughput = d[d["workload"] == "throughput"].copy()
    ds_dir = out_root / "figures" / safe_name(dataset_id)
    # Keep reruns deterministic and avoid stale plots from prior runs.
    shutil.rmtree(ds_dir, ignore_errors=True)
    overview_dir = ds_dir / "overview"
    trends_dir = ds_dir / "trends"
    cases_dir = ds_dir / "cases"
    scaling_dir = ds_dir / "scaling"
    counts = {"overview": 0, "trend": 0, "case": 0, "scaling": 0}

    if not throughput.empty:
        plot_heatmap(
            throughput,
            "fwd_gflops_mean",
            f"{dataset_id}: Forward {_metric_label(precision)} heatmap",
            overview_dir / "heatmap_fwd_gflops.png",
            cmap="viridis",
        )
        counts["overview"] += 1
        plot_heatmap(
            throughput,
            "bwd_gflops_mean",
            f"{dataset_id}: Backward {_metric_label(precision)} heatmap",
            overview_dir / "heatmap_bwd_gflops.png",
            cmap="viridis",
        )
        counts["overview"] += 1
        plot_heatmap(
            throughput,
            "fwd_speedup_vs_baseline",
            f"{dataset_id}: Forward speedup vs baseline",
            overview_dir / "heatmap_fwd_speedup.png",
            center=1.0,
            cmap="RdYlGn",
        )
        counts["overview"] += 1
        plot_heatmap(
            throughput,
            "fwd_ms_mean",
            f"{dataset_id}: Forward latency (ms)",
            overview_dir / "heatmap_fwd_ms.png",
            cmap="magma_r",
        )
        counts["overview"] += 1

        plot_trend_by_batch(
            throughput,
            "fwd_gflops_mean",
            f"Forward {_metric_label(precision)}",
            f"{dataset_id} Forward throughput",
            trends_dir,
        )
        counts["trend"] += len(throughput["batch"].dropna().unique())

        plot_trend_by_batch(
            throughput,
            "fwd_ms_mean",
            "Forward ms",
            f"{dataset_id} Forward latency",
            trends_dir,
            y_log=True,
        )
        counts["trend"] += len(throughput["batch"].dropna().unique())

        case_rows = _case_sort(throughput[["case_id", "nx", "batch"]].drop_duplicates())
        case_ids = case_rows["case_id"].tolist()
        if max_case_plots > 0:
            case_ids = case_ids[:max_case_plots]
        for case_id in case_ids:
            c = throughput[throughput["case_id"] == case_id].copy()
            if c.empty:
                continue
            out = cases_dir / f"{safe_name(case_id)}.png"
            plot_case_panels(c, out, precision)
            counts["case"] += 1

    for workload in ("thread_scaling", "batch_scaling"):
        n_scenarios = d[d["workload"] == workload]["scenario_id"].nunique()
        plot_scaling(d, workload, scaling_dir, precision)
        counts["scaling"] += int(n_scenarios)

    return counts


def write_readme(out_root: Path, logs: List[Path], agg: pd.DataFrame, counts: Dict[str, Dict[str, int]]) -> None:
    path = out_root / "PLOTS_README.md"
    lines = []
    lines.append("# FFT Plot Pack")
    lines.append("")
    lines.append("This folder contains plots generated from raw `RESULT|...` benchmark logs.")
    lines.append("")
    lines.append("## Included Inputs")
    lines.append("")
    lines.append(f"- Logs parsed: {len(logs)}")
    for log in logs:
        lines.append(f"- `{log}`")
    lines.append("")
    lines.append("## Datasets")
    lines.append("")
    for ds in sorted(agg["dataset_id"].unique()):
        sub = agg[agg["dataset_id"] == ds]
        lines.append(
            f"- `{ds}`: workloads={sorted(sub['workload'].unique())}, cases={sub['case_id'].nunique()}, profiles={sub['profile_id'].nunique()}"
        )
    lines.append("")
    lines.append("## Plot Types")
    lines.append("")
    lines.append("- Overview heatmaps: forward/backward throughput, speedup, latency")
    lines.append("- Trend plots by batch: length vs throughput, length vs latency")
    lines.append("- Case drilldowns: 2x2 panels per case (fwd/bwd throughput + latency)")
    lines.append("- Scaling plots: thread scaling and batch scaling scenarios")
    lines.append("")
    lines.append("## Generated Counts")
    lines.append("")
    for ds, c in sorted(counts.items()):
        lines.append(
            f"- `{ds}`: overview={c.get('overview', 0)}, trend={c.get('trend', 0)}, case={c.get('case', 0)}, scaling={c.get('scaling', 0)}"
        )
    lines.append("")
    lines.append("## How To Read")
    lines.append("")
    lines.append("- Use `figures/<dataset>/overview/` for quick ranking and bottleneck detection.")
    lines.append("- Use `figures/<dataset>/cases/` for direct profile-by-profile case comparisons.")
    lines.append("- Use `figures/<dataset>/scaling/` to inspect thread or batch efficiency.")
    lines.append("")
    path.write_text("\n".join(lines))


def main() -> None:
    args = parse_args()
    src_root = Path(args.src_root).resolve()
    out_root = Path(args.out_dir).resolve()
    data_dir = out_root / "data"
    data_dir.mkdir(parents=True, exist_ok=True)
    sns.set_theme(style="whitegrid", context="notebook")

    logs = discover_logs(src_root, args.pattern)
    if not logs:
        raise SystemExit(f"No logs found under {src_root} with pattern {args.pattern}")

    rows: List[Dict] = []
    for log in logs:
        rows.extend(parse_log_file(log))
    if not rows:
        raise SystemExit("No RESULT rows parsed from logs.")

    raw = pd.DataFrame(rows)
    raw.sort_values(
        by=["dataset_id", "workload", "nx", "ny", "nz", "batch", "threads", "profile_id", "run_id"],
        inplace=True,
    )
    agg = aggregate_metrics(raw)
    agg.sort_values(
        by=["dataset_id", "workload", "nx", "ny", "nz", "batch", "threads", "profile_id"],
        inplace=True,
    )

    raw_csv = data_dir / "results_raw.csv"
    agg_csv = data_dir / "results_aggregated.csv"
    raw.to_csv(raw_csv, index=False)
    agg.to_csv(agg_csv, index=False)

    counts: Dict[str, Dict[str, int]] = {}
    for ds in sorted(agg["dataset_id"].unique()):
        counts[ds] = generate_for_dataset(agg, ds, out_root, args.max_case_plots)

    write_readme(out_root, logs, agg, counts)

    print(f"Parsed logs: {len(logs)}")
    print(f"Raw rows: {len(raw)}")
    print(f"Aggregated rows: {len(agg)}")
    print(f"Raw CSV: {raw_csv}")
    print(f"Aggregated CSV: {agg_csv}")
    print(f"Plots root: {out_root / 'figures'}")
    for ds, c in sorted(counts.items()):
        print(
            f"{ds}: overview={c.get('overview', 0)}, trend={c.get('trend', 0)}, "
            f"case={c.get('case', 0)}, scaling={c.get('scaling', 0)}"
        )


if __name__ == "__main__":
    main()
