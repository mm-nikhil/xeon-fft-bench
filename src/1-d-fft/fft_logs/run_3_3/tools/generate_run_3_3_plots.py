#!/usr/bin/env python3
from __future__ import annotations

import argparse
import shutil
from pathlib import Path
from typing import Dict, List

import matplotlib

matplotlib.use("Agg")
import matplotlib.pyplot as plt
import numpy as np
import pandas as pd
import seaborn as sns

PROFILE_ORDER = ["baseline_sse42_1t", "avx512_phys", "avx512_logical"]
PROFILE_LABEL = {
    "baseline_sse42_1t": "SSE4.2 baseline (1 thread)",
    "avx512_phys": "AVX512 (10 threads)",
    "avx512_logical": "AVX512 (20 threads)",
}
PROFILE_COLOR = {
    "baseline_sse42_1t": "#4C78A8",
    "avx512_phys": "#F58518",
    "avx512_logical": "#54A24B",
}

BATCH_ORDER = [1, 10, 16, 150, 256, 1024]
LENGTH_ORDER = [2**i for i in range(1, 17)]


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="Generate simplified forward-only plots for run_3_3")
    parser.add_argument(
        "--root",
        default=str(Path(__file__).resolve().parents[1]),
        help="run_3_3 root directory containing timestamped sessions",
    )
    parser.add_argument(
        "--session-dir",
        default=None,
        help="specific session directory (default: latest with latest_run_avg.csv)",
    )
    parser.add_argument(
        "--peak-gflops",
        type=float,
        default=2112.0,
        help="SP peak denominator (reporting reference only)",
    )
    return parser.parse_args()


def pick_session(root: Path, explicit: str | None) -> Path:
    if explicit:
        session = Path(explicit).resolve()
        if not (session / "latest_run_avg.csv").is_file():
            raise SystemExit(f"CSV not found in session: {session}")
        return session

    sessions: List[Path] = []
    for p in sorted(root.iterdir()):
        if p.is_dir() and (p / "latest_run_avg.csv").is_file():
            sessions.append(p)
    if not sessions:
        raise SystemExit(f"No session with latest_run_avg.csv found under: {root}")
    return sessions[-1]


def load_data(csv_path: Path) -> pd.DataFrame:
    df = pd.read_csv(csv_path)
    df = df[df["workload"] == "throughput"].copy()

    numeric_cols = ["length", "batch", "threads", "avg_fwd_sp_gflops", "fwd_pct_of_peak"]
    for col in numeric_cols:
        df[col] = pd.to_numeric(df[col], errors="coerce")

    df = df[df["profile"].isin(PROFILE_ORDER)].copy()
    df = df.dropna(subset=["length", "batch", "avg_fwd_sp_gflops"]).copy()
    df["length"] = df["length"].astype(int)
    df["batch"] = df["batch"].astype(int)
    return df


def validate_matrix(df: pd.DataFrame) -> Dict[str, int]:
    profile_set = set(df["profile"].unique())
    missing_profiles = [p for p in PROFILE_ORDER if p not in profile_set]
    if missing_profiles:
        raise SystemExit(f"Missing required profile rows: {', '.join(missing_profiles)}")

    lengths = sorted(df["length"].unique().tolist())
    batches = sorted(df["batch"].unique().tolist())

    if lengths != LENGTH_ORDER:
        raise SystemExit(f"Length set mismatch. Expected {LENGTH_ORDER}, found {lengths}")
    if batches != BATCH_ORDER:
        raise SystemExit(f"Batch set mismatch. Expected {BATCH_ORDER}, found {batches}")

    key_cols = ["length", "batch", "profile"]
    dup_count = int(df.duplicated(subset=key_cols, keep=False).sum())
    if dup_count > 0:
        raise SystemExit(f"Duplicate rows detected for (length,batch,profile). duplicate_rows={dup_count}")

    expected = pd.MultiIndex.from_product(
        [LENGTH_ORDER, BATCH_ORDER, PROFILE_ORDER], names=["length", "batch", "profile"]
    )
    present = pd.MultiIndex.from_frame(df[key_cols])
    missing = expected.difference(present)
    extra = present.difference(expected)

    if len(missing) or len(extra):
        raise SystemExit(
            "Matrix coverage mismatch: "
            f"missing={len(missing)} extra={len(extra)} "
            "(expected 16 lengths x 6 batches x 3 profiles = 288 rows)"
        )

    expected_rows = len(LENGTH_ORDER) * len(BATCH_ORDER) * len(PROFILE_ORDER)
    if len(df) != expected_rows:
        raise SystemExit(f"Row count mismatch. expected={expected_rows} found={len(df)}")

    non_positive = int((df["avg_fwd_sp_gflops"] <= 0).sum())
    if non_positive:
        raise SystemExit(f"Found non-positive avg_fwd_sp_gflops rows: {non_positive}")

    return {
        "expected_rows": expected_rows,
        "found_rows": int(len(df)),
        "num_lengths": len(lengths),
        "num_batches": len(batches),
        "num_profiles": len(profile_set),
    }


def clean_plots_root(plots_root: Path) -> None:
    if plots_root.exists():
        for child in plots_root.iterdir():
            if child.is_dir():
                shutil.rmtree(child)
            else:
                child.unlink()
    plots_root.mkdir(parents=True, exist_ok=True)


def plot_master(df: pd.DataFrame, out_path: Path) -> str:
    out_path.parent.mkdir(parents=True, exist_ok=True)

    base = (
        df[df["profile"] == "baseline_sse42_1t"][["length", "batch", "avg_fwd_sp_gflops"]]
        .rename(columns={"avg_fwd_sp_gflops": "baseline_gflops"})
        .copy()
    )
    phys = (
        df[df["profile"] == "avx512_phys"][["length", "batch", "avg_fwd_sp_gflops"]]
        .rename(columns={"avg_fwd_sp_gflops": "phys_gflops"})
        .copy()
    )
    logical = (
        df[df["profile"] == "avx512_logical"][["length", "batch", "avg_fwd_sp_gflops"]]
        .rename(columns={"avg_fwd_sp_gflops": "logical_gflops"})
        .copy()
    )

    phys_inc = phys.merge(base, on=["length", "batch"], how="inner")
    logical_inc = logical.merge(base, on=["length", "batch"], how="inner")
    phys_inc["pct_inc"] = 100.0 * (phys_inc["phys_gflops"] - phys_inc["baseline_gflops"]) / phys_inc["baseline_gflops"]
    logical_inc["pct_inc"] = (
        100.0 * (logical_inc["logical_gflops"] - logical_inc["baseline_gflops"]) / logical_inc["baseline_gflops"]
    )

    piv_base = (
        base.pivot(index="length", columns="batch", values="baseline_gflops")
        .reindex(index=LENGTH_ORDER, columns=BATCH_ORDER)
        .copy()
    )
    piv_phys_inc = (
        phys_inc.pivot(index="length", columns="batch", values="pct_inc")
        .reindex(index=LENGTH_ORDER, columns=BATCH_ORDER)
        .copy()
    )
    piv_logical_inc = (
        logical_inc.pivot(index="length", columns="batch", values="pct_inc")
        .reindex(index=LENGTH_ORDER, columns=BATCH_ORDER)
        .copy()
    )

    vmax_inc = np.nanmax(
        np.abs(np.concatenate([piv_phys_inc.to_numpy().ravel(), piv_logical_inc.to_numpy().ravel()]))
    )
    if not np.isfinite(vmax_inc) or vmax_inc == 0:
        vmax_inc = 1.0

    fig, axes = plt.subplots(1, 3, figsize=(21, 7.5))

    sns.heatmap(
        piv_base,
        cmap="viridis",
        ax=axes[0],
        cbar_kws={"label": "Forward SP GFLOPS"},
        xticklabels=[str(b) for b in BATCH_ORDER],
        yticklabels=[str(n) for n in LENGTH_ORDER],
    )
    axes[0].set_title("A) Baseline SSE4.2 1T (GFLOPS)")
    axes[0].set_xlabel("Batch")
    axes[0].set_ylabel("Length (N)")

    sns.heatmap(
        piv_phys_inc,
        cmap="RdYlGn",
        center=0.0,
        vmin=-vmax_inc,
        vmax=vmax_inc,
        ax=axes[1],
        cbar_kws={"label": "% increase vs baseline"},
        xticklabels=[str(b) for b in BATCH_ORDER],
        yticklabels=[str(n) for n in LENGTH_ORDER],
    )
    axes[1].set_title("B) AVX512 10T (% increase vs baseline)")
    axes[1].set_xlabel("Batch")
    axes[1].set_ylabel("Length (N)")

    sns.heatmap(
        piv_logical_inc,
        cmap="RdYlGn",
        center=0.0,
        vmin=-vmax_inc,
        vmax=vmax_inc,
        ax=axes[2],
        cbar_kws={"label": "% increase vs baseline"},
        xticklabels=[str(b) for b in BATCH_ORDER],
        yticklabels=[str(n) for n in LENGTH_ORDER],
    )
    axes[2].set_title("C) AVX512 20T (% increase vs baseline)")
    axes[2].set_xlabel("Batch")
    axes[2].set_ylabel("Length (N)")

    fig.suptitle("run_3_3 Master View: All N/Batches/Profiles", fontsize=16, y=1.02)
    fig.tight_layout()
    fig.savefig(out_path, dpi=170, bbox_inches="tight")
    plt.close(fig)
    return str(out_path)


def plot_nwise_compact(df: pd.DataFrame, out_path: Path) -> str:
    out_path.parent.mkdir(parents=True, exist_ok=True)

    x = np.arange(len(BATCH_ORDER))
    fig, axes = plt.subplots(4, 4, figsize=(22, 14), sharex=True)
    axes_flat = axes.ravel()

    legend_handles = []
    legend_labels = []
    for idx, length in enumerate(LENGTH_ORDER):
        ax = axes_flat[idx]
        sub = df[df["length"] == length]
        for profile in PROFILE_ORDER:
            p = sub[sub["profile"] == profile].set_index("batch").reindex(BATCH_ORDER)
            line = ax.plot(
                x,
                p["avg_fwd_sp_gflops"].to_numpy(),
                marker="o",
                linewidth=1.8,
                color=PROFILE_COLOR[profile],
                label=PROFILE_LABEL[profile],
            )[0]
            if idx == 0:
                legend_handles.append(line)
                legend_labels.append(PROFILE_LABEL[profile])

        ax.set_title(f"N={length}", fontsize=10)
        ax.grid(True, alpha=0.25)
        ax.set_ylim(bottom=0)
        ax.set_xticks(x)
        ax.set_xticklabels([str(b) for b in BATCH_ORDER], fontsize=8)
        if idx % 4 == 0:
            ax.set_ylabel("GFLOPS", fontsize=9)
        if idx >= 12:
            ax.set_xlabel("Batch", fontsize=9)

    fig.legend(legend_handles, legend_labels, loc="upper center", ncol=3, frameon=True, fontsize=9)
    fig.suptitle("N-wise Compact View: Forward GFLOPS vs Batch (All N)", fontsize=16, y=1.01)
    fig.tight_layout(rect=[0, 0, 1, 0.97])
    fig.savefig(out_path, dpi=170, bbox_inches="tight")
    plt.close(fig)
    return str(out_path)


def plot_line_by_batch_compact(df: pd.DataFrame, out_path: Path) -> str:
    out_path.parent.mkdir(parents=True, exist_ok=True)

    x = np.array(LENGTH_ORDER, dtype=float)
    fig, axes = plt.subplots(2, 3, figsize=(22, 10.5), sharex=True)
    axes_flat = axes.ravel()

    legend_handles = []
    legend_labels = []
    for idx, batch in enumerate(BATCH_ORDER):
        ax = axes_flat[idx]
        sub = df[df["batch"] == batch]
        for profile in PROFILE_ORDER:
            p = sub[sub["profile"] == profile].sort_values("length")
            line = ax.plot(
                p["length"].to_numpy(dtype=float),
                p["avg_fwd_sp_gflops"].to_numpy(),
                marker="o",
                linewidth=1.8,
                color=PROFILE_COLOR[profile],
                label=PROFILE_LABEL[profile],
            )[0]
            if idx == 0:
                legend_handles.append(line)
                legend_labels.append(PROFILE_LABEL[profile])

        ax.set_title(f"Batch={batch}", fontsize=11)
        ax.grid(True, alpha=0.25)
        ax.set_ylim(bottom=0)
        ax.set_xscale("log", base=2)
        ax.set_xticks(x)
        ax.set_xticklabels([str(n) for n in LENGTH_ORDER], rotation=45, ha="right", fontsize=7)
        if idx % 3 == 0:
            ax.set_ylabel("GFLOPS", fontsize=9)
        if idx >= 3:
            ax.set_xlabel("Length (N)", fontsize=9)

    fig.legend(legend_handles, legend_labels, loc="upper center", ncol=3, frameon=True, fontsize=9)
    fig.suptitle("Line-by-Batch Compact View: Forward GFLOPS vs N (All Batches)", fontsize=16, y=1.03)
    fig.tight_layout(rect=[0, 0, 1, 0.97])
    fig.savefig(out_path, dpi=170, bbox_inches="tight")
    plt.close(fig)
    return str(out_path)


def write_summary(
    out_path: Path,
    csv_path: Path,
    peak_gflops: float,
    coverage: Dict[str, int],
    generated_files: List[str],
) -> None:
    lines: List[str] = []
    lines.append("# run_3_3 Plot Summary (Simplified)")
    lines.append("")
    lines.append(f"- CSV source: `{csv_path}`")
    lines.append(f"- Peak denominator reference: {peak_gflops:.1f} SP GFLOPS")
    lines.append("- Plot contract: exactly 3 PNG files")
    lines.append("- Batch labels forced explicitly on batch axes: `1, 10, 16, 150, 256, 1024`")
    lines.append("")
    lines.append("## Coverage Checks")
    lines.append("")
    lines.append(
        f"- Throughput rows expected: {coverage['expected_rows']} | found: {coverage['found_rows']}"
    )
    lines.append(
        f"- Dimensions: lengths={coverage['num_lengths']} batches={coverage['num_batches']} profiles={coverage['num_profiles']}"
    )
    lines.append("- Coverage status: PASS (complete 16 x 6 x 3 matrix)")
    lines.append("")
    lines.append("## Generated Files")
    lines.append("")
    for p in generated_files:
        lines.append(f"- `{p}`")
    lines.append("")

    out_path.write_text("\n".join(lines))


def main() -> None:
    args = parse_args()
    sns.set_theme(style="whitegrid", context="notebook")

    root = Path(args.root).resolve()
    session = pick_session(root, args.session_dir)
    csv_path = session / "latest_run_avg.csv"
    plots_root = session / "plots"

    df = load_data(csv_path)
    coverage = validate_matrix(df)

    clean_plots_root(plots_root)

    generated: List[str] = []
    generated.append(plot_master(df, plots_root / "master" / "all_cases_master.png"))
    generated.append(plot_nwise_compact(df, plots_root / "n-wise" / "nwise_all_lengths_compact.png"))
    generated.append(
        plot_line_by_batch_compact(df, plots_root / "line_by_batch" / "line_by_batch_all_batches_compact.png")
    )

    summary_path = plots_root / "PLOTS_SUMMARY.md"
    write_summary(summary_path, csv_path, args.peak_gflops, coverage, generated)

    print(f"Session: {session}")
    print(f"CSV: {csv_path}")
    print(f"Plots root: {plots_root}")
    print(f"Generated files: {len(generated)}")
    for p in generated:
        print(f" - {p}")
    print(f"Summary: {summary_path}")


if __name__ == "__main__":
    main()
