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

LENGTH_ORDER = [2**i for i in range(1, 23)]
BATCH_ORDER = [1]
CORE_ORDER = list(range(1, 11))
TPC_ORDER = [1, 2]
TPC_LABEL = {1: "threads=cores", 2: "threads=2xcores"}


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="Generate forward-only plots for run_core_wise (batch=1)")
    parser.add_argument(
        "--root",
        default=str(Path(__file__).resolve().parents[1]),
        help="run_core_wise root directory containing timestamped sessions",
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

    numeric_cols = [
        "length",
        "batch",
        "core_count",
        "threads_per_core",
        "threads",
        "avg_fwd_sp_gflops",
        "fwd_pct_of_peak",
    ]
    for col in numeric_cols:
        df[col] = pd.to_numeric(df[col], errors="coerce")

    df = df.dropna(
        subset=["length", "batch", "core_count", "threads_per_core", "threads", "avg_fwd_sp_gflops"]
    ).copy()
    df["length"] = df["length"].astype(int)
    df["batch"] = df["batch"].astype(int)
    df["core_count"] = df["core_count"].astype(int)
    df["threads_per_core"] = df["threads_per_core"].astype(int)
    df["threads"] = df["threads"].astype(int)
    return df


def validate_matrix(df: pd.DataFrame) -> Dict[str, int]:
    lengths = sorted(df["length"].unique().tolist())
    batches = sorted(df["batch"].unique().tolist())
    cores = sorted(df["core_count"].unique().tolist())
    tpc_set = sorted(df["threads_per_core"].unique().tolist())

    if lengths != LENGTH_ORDER:
        raise SystemExit(f"Length set mismatch. Expected {LENGTH_ORDER}, found {lengths}")
    if batches != BATCH_ORDER:
        raise SystemExit(f"Batch set mismatch. Expected {BATCH_ORDER}, found {batches}")
    if cores != CORE_ORDER:
        raise SystemExit(f"Core set mismatch. Expected {CORE_ORDER}, found {cores}")
    if tpc_set != TPC_ORDER:
        raise SystemExit(f"threads_per_core mismatch. Expected {TPC_ORDER}, found {tpc_set}")

    bad_threads = df[df["threads"] != (df["core_count"] * df["threads_per_core"])]
    if not bad_threads.empty:
        raise SystemExit(f"Found rows where threads != core_count*threads_per_core: {len(bad_threads)}")

    key_cols = ["length", "batch", "core_count", "threads_per_core"]
    dup_count = int(df.duplicated(subset=key_cols, keep=False).sum())
    if dup_count > 0:
        raise SystemExit(
            "Duplicate rows detected for (length,batch,core_count,threads_per_core). "
            f"duplicate_rows={dup_count}"
        )

    expected = pd.MultiIndex.from_product(
        [LENGTH_ORDER, BATCH_ORDER, CORE_ORDER, TPC_ORDER],
        names=["length", "batch", "core_count", "threads_per_core"],
    )
    present = pd.MultiIndex.from_frame(df[key_cols])
    missing = expected.difference(present)
    extra = present.difference(expected)

    if len(missing) or len(extra):
        raise SystemExit(
            "Matrix coverage mismatch: "
            f"missing={len(missing)} extra={len(extra)} "
            "(expected 22 lengths x 1 batch x 10 cores x 2 thread-modes = 440 rows)"
        )

    expected_rows = len(LENGTH_ORDER) * len(BATCH_ORDER) * len(CORE_ORDER) * len(TPC_ORDER)
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
        "num_cores": len(cores),
        "num_thread_modes": len(tpc_set),
    }


def clean_plots_root(plots_root: Path) -> None:
    if plots_root.exists():
        for child in plots_root.iterdir():
            if child.is_dir():
                shutil.rmtree(child)
            else:
                child.unlink()
    plots_root.mkdir(parents=True, exist_ok=True)


def _pivot(df: pd.DataFrame, tpc: int) -> pd.DataFrame:
    sub = df[(df["batch"] == 1) & (df["threads_per_core"] == tpc)].copy()
    piv = (
        sub.pivot(index="length", columns="core_count", values="avg_fwd_sp_gflops")
        .reindex(index=LENGTH_ORDER, columns=CORE_ORDER)
        .copy()
    )
    return piv


def plot_master(df: pd.DataFrame, out_path: Path) -> str:
    out_path.parent.mkdir(parents=True, exist_ok=True)

    piv_1t = _pivot(df, 1)
    piv_2t = _pivot(df, 2)
    piv_inc = 100.0 * (piv_2t - piv_1t) / piv_1t

    vmax_inc = np.nanmax(np.abs(piv_inc.to_numpy()))
    if not np.isfinite(vmax_inc) or vmax_inc == 0:
        vmax_inc = 1.0

    fig, axes = plt.subplots(1, 3, figsize=(22, 8.5))

    sns.heatmap(
        piv_1t,
        cmap="viridis",
        ax=axes[0],
        cbar_kws={"label": "Forward SP GFLOPS"},
        xticklabels=[str(c) for c in CORE_ORDER],
        yticklabels=[str(n) for n in LENGTH_ORDER],
    )
    axes[0].set_title("A) threads=cores")
    axes[0].set_xlabel("Cores")
    axes[0].set_ylabel("Length (N)")

    sns.heatmap(
        piv_2t,
        cmap="viridis",
        ax=axes[1],
        cbar_kws={"label": "Forward SP GFLOPS"},
        xticklabels=[str(c) for c in CORE_ORDER],
        yticklabels=[str(n) for n in LENGTH_ORDER],
    )
    axes[1].set_title("B) threads=2xcores")
    axes[1].set_xlabel("Cores")
    axes[1].set_ylabel("Length (N)")

    sns.heatmap(
        piv_inc,
        cmap="RdYlGn",
        center=0.0,
        vmin=-vmax_inc,
        vmax=vmax_inc,
        ax=axes[2],
        cbar_kws={"label": "% increase (2xcores vs cores)"},
        xticklabels=[str(c) for c in CORE_ORDER],
        yticklabels=[str(n) for n in LENGTH_ORDER],
    )
    axes[2].set_title("C) uplift from SMT")
    axes[2].set_xlabel("Cores")
    axes[2].set_ylabel("Length (N)")

    fig.suptitle("run_core_wise Master View (Batch=1)", fontsize=16, y=1.02)
    fig.tight_layout()
    fig.savefig(out_path, dpi=170, bbox_inches="tight")
    plt.close(fig)
    return str(out_path)


def plot_nwise_compact(df: pd.DataFrame, out_path: Path) -> str:
    out_path.parent.mkdir(parents=True, exist_ok=True)

    ncols = 4
    nrows = int(np.ceil(len(LENGTH_ORDER) / ncols))
    fig, axes = plt.subplots(nrows, ncols, figsize=(22, 3.2 * nrows), sharey=True)
    axes_flat = axes.ravel()

    for idx, length in enumerate(LENGTH_ORDER):
        ax = axes_flat[idx]
        sub = df[(df["length"] == length) & (df["batch"] == 1)]

        line_1 = (
            sub[sub["threads_per_core"] == 1]
            .set_index("core_count")
            .reindex(CORE_ORDER)["avg_fwd_sp_gflops"]
            .to_numpy()
        )
        line_2 = (
            sub[sub["threads_per_core"] == 2]
            .set_index("core_count")
            .reindex(CORE_ORDER)["avg_fwd_sp_gflops"]
            .to_numpy()
        )

        ax.plot(CORE_ORDER, line_1, marker="o", linewidth=1.8, color="#4C78A8", label=TPC_LABEL[1])
        ax.plot(CORE_ORDER, line_2, marker="o", linewidth=1.8, color="#F58518", label=TPC_LABEL[2])

        ax.set_title(f"N={length}", fontsize=10)
        ax.grid(True, alpha=0.25)
        ax.set_ylim(bottom=0)
        ax.set_xticks(CORE_ORDER)
        ax.set_xticklabels([str(c) for c in CORE_ORDER], fontsize=7)
        if idx % 4 == 0:
            ax.set_ylabel("GFLOPS", fontsize=9)
        if idx >= (nrows - 1) * ncols:
            ax.set_xlabel("Cores", fontsize=9)

    for idx in range(len(LENGTH_ORDER), len(axes_flat)):
        axes_flat[idx].axis("off")

    handles, labels = axes_flat[0].get_legend_handles_labels()
    fig.legend(handles, labels, loc="upper center", ncol=2, frameon=True, fontsize=9)
    fig.suptitle("N-wise Compact View: GFLOPS vs Cores at Batch=1", fontsize=16, y=1.01)
    fig.tight_layout(rect=[0, 0, 1, 0.97])
    fig.savefig(out_path, dpi=170, bbox_inches="tight")
    plt.close(fig)
    return str(out_path)


def plot_line_batch1(df: pd.DataFrame, out_path: Path) -> str:
    out_path.parent.mkdir(parents=True, exist_ok=True)

    x = np.array(LENGTH_ORDER, dtype=float)
    colors = sns.color_palette("tab10", len(CORE_ORDER))

    fig, axes = plt.subplots(1, 2, figsize=(19, 7), sharey=True)

    for ax, tpc in zip(axes, TPC_ORDER):
        sub = df[(df["batch"] == 1) & (df["threads_per_core"] == tpc)]
        for idx, core in enumerate(CORE_ORDER):
            line = sub[sub["core_count"] == core].sort_values("length")
            ax.plot(
                line["length"].to_numpy(dtype=float),
                line["avg_fwd_sp_gflops"].to_numpy(),
                marker="o",
                linewidth=1.5,
                color=colors[idx],
                label=f"{core} core(s)",
            )

        ax.set_title(f"{TPC_LABEL[tpc]}")
        ax.grid(True, alpha=0.25)
        ax.set_ylim(bottom=0)
        ax.set_xscale("log", base=2)
        ax.set_xticks(x)
        ax.set_xticklabels([str(n) for n in LENGTH_ORDER], rotation=45, ha="right", fontsize=8)
        ax.set_xlabel("Length (N)")

    axes[0].set_ylabel("GFLOPS")
    handles, labels = axes[1].get_legend_handles_labels()
    fig.legend(handles, labels, loc="upper center", ncol=5, frameon=True, fontsize=9)
    fig.suptitle("Batch=1: Forward GFLOPS vs N (Core-wise)", fontsize=16, y=1.02)
    fig.tight_layout(rect=[0, 0, 1, 0.96])
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
    lines.append("# run_core_wise Plot Summary")
    lines.append("")
    lines.append(f"- CSV source: `{csv_path}`")
    lines.append(f"- Peak denominator reference: {peak_gflops:.1f} SP GFLOPS")
    lines.append("- Plot contract: exactly 3 PNG files")
    lines.append("- Batch coverage fixed to: `1`")
    lines.append("")
    lines.append("## Coverage Checks")
    lines.append("")
    lines.append(f"- Throughput rows expected: {coverage['expected_rows']} | found: {coverage['found_rows']}")
    lines.append(
        "- Dimensions: "
        f"lengths={coverage['num_lengths']} batches={coverage['num_batches']} "
        f"cores={coverage['num_cores']} thread_modes={coverage['num_thread_modes']}"
    )
    lines.append("- Coverage status: PASS (complete 22 x 1 x 10 x 2 matrix)")
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
    generated.append(plot_nwise_compact(df, plots_root / "n-wise" / "nwise_batch1_corewise_all_lengths_compact.png"))
    generated.append(plot_line_batch1(df, plots_root / "line_by_batch" / "line_by_batch_batch1.png"))

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
