#!/usr/bin/env python3
from __future__ import annotations

import argparse
import math
import shutil
from pathlib import Path
from typing import Dict, List

import matplotlib

matplotlib.use("Agg")
import matplotlib.pyplot as plt
import numpy as np
import pandas as pd
import seaborn as sns


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="Generate compact GPU run plots from latest_run_avg.csv")
    parser.add_argument("--session-dir", required=True, help="session directory containing latest_run_avg.csv")
    parser.add_argument("--family-id", required=True, help="family label for titles")
    parser.add_argument("--expected-lengths", required=True, help="comma-separated expected lengths")
    parser.add_argument("--expected-batches", required=True, help="comma-separated expected batches")
    return parser.parse_args()


def parse_int_list(raw: str) -> List[int]:
    values: List[int] = []
    for item in raw.split(","):
        item = item.strip()
        if item:
            values.append(int(item))
    return values


def load_data(csv_path: Path) -> pd.DataFrame:
    df = pd.read_csv(csv_path)
    df = df[df["workload"] == "throughput"].copy()
    numeric_cols = [
        "length",
        "batch",
        "avg_fwd_ms",
        "avg_fwd_sp_gflops",
        "avg_mem_mb",
        "avg_stream_slots",
        "avg_workarea_mb",
    ]
    for col in numeric_cols:
        df[col] = pd.to_numeric(df[col], errors="coerce")
    return df


def validate_matrix(df: pd.DataFrame, expected_lengths: List[int], expected_batches: List[int]) -> Dict[str, int]:
    lengths = sorted(df["length"].dropna().astype(int).unique().tolist())
    batches = sorted(df["batch"].dropna().astype(int).unique().tolist())
    profiles = sorted(df["profile"].dropna().unique().tolist())
    if lengths != expected_lengths:
        raise SystemExit(f"Length set mismatch. expected={expected_lengths} found={lengths}")
    if batches != expected_batches:
        raise SystemExit(f"Batch set mismatch. expected={expected_batches} found={batches}")
    if not profiles:
        raise SystemExit("No profiles found in CSV")

    dup_count = int(df.duplicated(subset=["length", "batch", "profile"], keep=False).sum())
    if dup_count:
        raise SystemExit(f"Duplicate rows found for (length,batch,profile): {dup_count}")

    expected = pd.MultiIndex.from_product(
        [expected_lengths, expected_batches, profiles], names=["length", "batch", "profile"]
    )
    present = pd.MultiIndex.from_frame(df[["length", "batch", "profile"]].astype({"length": int, "batch": int}))
    missing = expected.difference(present)
    extra = present.difference(expected)
    if len(missing) or len(extra):
        raise SystemExit(f"Coverage mismatch. missing={len(missing)} extra={len(extra)}")

    return {
        "expected_rows": len(expected),
        "found_rows": int(len(df)),
        "num_lengths": len(lengths),
        "num_batches": len(batches),
        "num_profiles": len(profiles),
    }


def clean_plots_root(plots_root: Path) -> None:
    if plots_root.exists():
        for child in plots_root.iterdir():
            if child.is_dir():
                shutil.rmtree(child)
            else:
                child.unlink()
    plots_root.mkdir(parents=True, exist_ok=True)


def plot_master(df: pd.DataFrame, family_id: str, lengths: List[int], batches: List[int], out_path: Path) -> str:
    out_path.parent.mkdir(parents=True, exist_ok=True)

    piv_gf = df.pivot(index="length", columns="batch", values="avg_fwd_sp_gflops").reindex(index=lengths, columns=batches)
    piv_ms = df.pivot(index="length", columns="batch", values="avg_fwd_ms").reindex(index=lengths, columns=batches)
    piv_mem = df.pivot(index="length", columns="batch", values="avg_mem_mb").reindex(index=lengths, columns=batches)

    fig, axes = plt.subplots(1, 3, figsize=(21, 7.5))

    sns.heatmap(
        piv_gf,
        cmap="viridis",
        ax=axes[0],
        cbar_kws={"label": "Forward SP GFLOPS"},
        xticklabels=[str(b) for b in batches],
        yticklabels=[str(n) for n in lengths],
    )
    axes[0].set_title("A) Forward GFLOPS")
    axes[0].set_xlabel("Batch")
    axes[0].set_ylabel("Length (N)")

    sns.heatmap(
        piv_ms,
        cmap="magma_r",
        ax=axes[1],
        cbar_kws={"label": "Forward ms"},
        xticklabels=[str(b) for b in batches],
        yticklabels=[str(n) for n in lengths],
    )
    axes[1].set_title("B) Forward Latency (ms)")
    axes[1].set_xlabel("Batch")
    axes[1].set_ylabel("Length (N)")

    sns.heatmap(
        piv_mem,
        cmap="crest",
        ax=axes[2],
        cbar_kws={"label": "Working Set MB"},
        xticklabels=[str(b) for b in batches],
        yticklabels=[str(n) for n in lengths],
    )
    axes[2].set_title("C) Working Set (MB)")
    axes[2].set_xlabel("Batch")
    axes[2].set_ylabel("Length (N)")

    fig.suptitle(f"{family_id}: all N/batches", fontsize=16, y=1.02)
    fig.tight_layout()
    fig.savefig(out_path, dpi=170, bbox_inches="tight")
    plt.close(fig)
    return str(out_path)


def plot_nwise_compact(df: pd.DataFrame, family_id: str, lengths: List[int], batches: List[int], out_path: Path) -> str:
    out_path.parent.mkdir(parents=True, exist_ok=True)

    ncols = 4
    nrows = math.ceil(len(lengths) / ncols)
    fig, axes = plt.subplots(nrows, ncols, figsize=(22, max(8, nrows * 3.2)), sharex=True)
    axes_flat = np.atleast_1d(axes).ravel()
    x = np.arange(len(batches))

    for idx, length in enumerate(lengths):
        ax = axes_flat[idx]
        sub = df[df["length"] == length].set_index("batch").reindex(batches)
        ax.plot(
            x,
            sub["avg_fwd_sp_gflops"].to_numpy(),
            marker="o",
            linewidth=1.8,
            color="#0F766E",
        )
        ax.set_title(f"N={length}", fontsize=10)
        ax.grid(True, alpha=0.25)
        ax.set_ylim(bottom=0)
        ax.set_xticks(x)
        ax.set_xticklabels([str(b) for b in batches], fontsize=8)
        if idx % ncols == 0:
            ax.set_ylabel("GFLOPS", fontsize=9)
        if idx >= len(lengths) - ncols:
            ax.set_xlabel("Batch", fontsize=9)

    for idx in range(len(lengths), len(axes_flat)):
        axes_flat[idx].axis("off")

    fig.suptitle(f"{family_id}: forward GFLOPS vs batch (all N)", fontsize=16, y=1.01)
    fig.tight_layout(rect=[0, 0, 1, 0.97])
    fig.savefig(out_path, dpi=170, bbox_inches="tight")
    plt.close(fig)
    return str(out_path)


def plot_line_by_batch_compact(df: pd.DataFrame, family_id: str, lengths: List[int], batches: List[int], out_path: Path) -> str:
    out_path.parent.mkdir(parents=True, exist_ok=True)

    ncols = 3
    nrows = math.ceil(len(batches) / ncols)
    fig, axes = plt.subplots(nrows, ncols, figsize=(22, max(7, nrows * 4.0)), sharex=True)
    axes_flat = np.atleast_1d(axes).ravel()
    x = np.array(lengths, dtype=float)

    for idx, batch in enumerate(batches):
        ax = axes_flat[idx]
        sub = df[df["batch"] == batch].sort_values("length")
        ax.plot(
            sub["length"].to_numpy(dtype=float),
            sub["avg_fwd_sp_gflops"].to_numpy(),
            marker="o",
            linewidth=1.8,
            color="#B45309",
        )
        ax.set_title(f"Batch={batch}", fontsize=11)
        ax.grid(True, alpha=0.25)
        ax.set_ylim(bottom=0)
        ax.set_xscale("log", base=2)
        ax.set_xticks(x)
        ax.set_xticklabels([str(n) for n in lengths], rotation=45, ha="right", fontsize=7)
        if idx % ncols == 0:
            ax.set_ylabel("GFLOPS", fontsize=9)
        if idx >= len(batches) - ncols:
            ax.set_xlabel("Length (N)", fontsize=9)

    for idx in range(len(batches), len(axes_flat)):
        axes_flat[idx].axis("off")

    fig.suptitle(f"{family_id}: forward GFLOPS vs N (all batches)", fontsize=16, y=1.03)
    fig.tight_layout(rect=[0, 0, 1, 0.97])
    fig.savefig(out_path, dpi=170, bbox_inches="tight")
    plt.close(fig)
    return str(out_path)


def write_summary(
    out_path: Path,
    csv_path: Path,
    family_id: str,
    coverage: Dict[str, int],
    expected_lengths: List[int],
    expected_batches: List[int],
    generated_files: List[str],
) -> None:
    lines: List[str] = []
    lines.append(f"# {family_id} Plot Summary")
    lines.append("")
    lines.append(f"- CSV source: `{csv_path}`")
    lines.append("- Plot contract: exactly 3 PNG files")
    lines.append(f"- Expected lengths: `{','.join(str(v) for v in expected_lengths)}`")
    lines.append(f"- Expected batches: `{','.join(str(v) for v in expected_batches)}`")
    lines.append("")
    lines.append("## Coverage Checks")
    lines.append("")
    lines.append(f"- Throughput rows expected: {coverage['expected_rows']} | found: {coverage['found_rows']}")
    lines.append(
        f"- Dimensions: lengths={coverage['num_lengths']} batches={coverage['num_batches']} profiles={coverage['num_profiles']}"
    )
    lines.append("- Coverage status: PASS")
    lines.append("")
    lines.append("## Generated Files")
    lines.append("")
    for path in generated_files:
        lines.append(f"- `{path}`")
    lines.append("")
    out_path.write_text("\n".join(lines))


def main() -> None:
    args = parse_args()
    sns.set_theme(style="whitegrid", context="notebook")

    session_dir = Path(args.session_dir).resolve()
    csv_path = session_dir / "latest_run_avg.csv"
    plots_root = session_dir / "plots"

    expected_lengths = parse_int_list(args.expected_lengths)
    expected_batches = parse_int_list(args.expected_batches)
    df = load_data(csv_path)
    coverage = validate_matrix(df, expected_lengths, expected_batches)

    clean_plots_root(plots_root)

    generated: List[str] = []
    generated.append(plot_master(df, args.family_id, expected_lengths, expected_batches, plots_root / "master" / "all_cases_master.png"))
    generated.append(
        plot_nwise_compact(df, args.family_id, expected_lengths, expected_batches, plots_root / "n-wise" / "nwise_all_lengths_compact.png")
    )
    generated.append(
        plot_line_by_batch_compact(
            df,
            args.family_id,
            expected_lengths,
            expected_batches,
            plots_root / "line_by_batch" / "line_by_batch_all_batches_compact.png",
        )
    )

    summary_path = plots_root / "PLOTS_SUMMARY.md"
    write_summary(summary_path, csv_path, args.family_id, coverage, expected_lengths, expected_batches, generated)

    print(f"Session: {session_dir}")
    print(f"CSV: {csv_path}")
    print(f"Plots root: {plots_root}")
    print(f"Generated files: {len(generated)}")
    for path in generated:
        print(f" - {path}")
    print(f"Summary: {summary_path}")


if __name__ == "__main__":
    main()
