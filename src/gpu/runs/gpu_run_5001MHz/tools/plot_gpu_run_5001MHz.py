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

FAMILY_ID = "gpu_run_5001MHz"
PROFILE_ID = "gpu_5001MHz"
EXPECTED_LENGTHS = [2**i for i in range(1, 23)]
EXPECTED_BATCHES = [1]


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="Generate a single GFLOPS-vs-N plot for gpu_run_5001MHz")
    parser.add_argument("--session-dir", required=True, help="session directory containing latest_run_avg.csv")
    return parser.parse_args()


def load_data(csv_path: Path) -> pd.DataFrame:
    df = pd.read_csv(csv_path)
    df = df[df["workload"] == "throughput"].copy()

    numeric_cols = ["length", "batch", "avg_fwd_sp_gflops"]
    for col in numeric_cols:
        df[col] = pd.to_numeric(df[col], errors="coerce")

    df = df[df["profile"] == PROFILE_ID].copy()
    return df.sort_values("length").reset_index(drop=True)


def validate_data(df: pd.DataFrame) -> Dict[str, int]:
    lengths = sorted(df["length"].dropna().astype(int).unique().tolist())
    batches = sorted(df["batch"].dropna().astype(int).unique().tolist())

    if lengths != EXPECTED_LENGTHS:
        raise SystemExit(f"Length set mismatch. expected={EXPECTED_LENGTHS} found={lengths}")
    if batches != EXPECTED_BATCHES:
        raise SystemExit(f"Batch set mismatch. expected={EXPECTED_BATCHES} found={batches}")

    dup_count = int(df.duplicated(subset=["length", "batch", "profile"], keep=False).sum())
    if dup_count:
        raise SystemExit(f"Duplicate rows found for (length,batch,profile): {dup_count}")

    expected = pd.MultiIndex.from_product(
        [EXPECTED_LENGTHS, EXPECTED_BATCHES, [PROFILE_ID]],
        names=["length", "batch", "profile"],
    )
    present = pd.MultiIndex.from_frame(df[["length", "batch", "profile"]].astype({"length": int, "batch": int}))
    missing = expected.difference(present)
    extra = present.difference(expected)
    if len(missing) or len(extra):
        raise SystemExit(f"Coverage mismatch. missing={len(missing)} extra={len(extra)}")

    bad = int(df["avg_fwd_sp_gflops"].isna().sum())
    if bad:
        raise SystemExit(f"Non-finite values found in avg_fwd_sp_gflops: {bad}")

    return {
        "expected_rows": len(expected),
        "found_rows": int(len(df)),
        "num_lengths": len(lengths),
        "num_batches": len(batches),
        "num_profiles": 1,
    }


def clean_plots_root(plots_root: Path) -> None:
    if plots_root.exists():
        for child in plots_root.iterdir():
            if child.is_dir():
                shutil.rmtree(child)
            else:
                child.unlink()
    plots_root.mkdir(parents=True, exist_ok=True)


def plot_overview(df: pd.DataFrame, out_path: Path) -> str:
    out_path.parent.mkdir(parents=True, exist_ok=True)

    x = df["length"].to_numpy(dtype=float)
    gflops = df["avg_fwd_sp_gflops"].to_numpy(dtype=float)

    fig, ax = plt.subplots(1, 1, figsize=(18, 7.5))

    ax.plot(
        x,
        gflops,
        marker="o",
        linewidth=2.2,
        markersize=5.5,
        color="#B45309",
    )
    ax.set_title("Batch=1: Forward GFLOPS vs N")
    ax.grid(True, alpha=0.25)
    ax.set_ylim(bottom=0)
    ax.set_xscale("log", base=2)
    ax.set_xticks(np.array(EXPECTED_LENGTHS, dtype=float))
    ax.set_xticklabels([str(v) for v in EXPECTED_LENGTHS], rotation=45, ha="right")
    ax.set_xlabel("Length (N)")
    ax.set_ylabel("GFLOPS")

    fig.tight_layout()
    fig.savefig(out_path, dpi=180, bbox_inches="tight", pad_inches=0.01)
    plt.close(fig)
    return str(out_path)


def write_summary(out_path: Path, csv_path: Path, coverage: Dict[str, int], generated_files: List[str]) -> None:
    lines: List[str] = []
    lines.append(f"# {FAMILY_ID} Plot Summary")
    lines.append("")
    lines.append(f"- CSV source: `{csv_path}`")
    lines.append("- Plot contract: exactly 1 PNG file")
    lines.append(f"- Expected lengths: `{','.join(str(v) for v in EXPECTED_LENGTHS)}`")
    lines.append("- Expected batches: `1`")
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
    sns.set_theme(style="whitegrid", context="talk")

    session_dir = Path(args.session_dir).resolve()
    csv_path = session_dir / "latest_run_avg.csv"
    plots_root = session_dir / "plots"

    df = load_data(csv_path)
    coverage = validate_data(df)
    clean_plots_root(plots_root)

    generated = [plot_overview(df, plots_root / "master" / "all_cases_master.png")]
    summary_path = plots_root / "PLOTS_SUMMARY.md"
    write_summary(summary_path, csv_path, coverage, generated)

    print(f"Session: {session_dir}")
    print(f"CSV: {csv_path}")
    print(f"Plots root: {plots_root}")
    print(f"Generated files: {len(generated)}")
    for path in generated:
        print(f" - {path}")
    print(f"Summary: {summary_path}")


if __name__ == "__main__":
    main()
