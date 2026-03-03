#!/usr/bin/env python3
from __future__ import annotations

import argparse
from pathlib import Path
from typing import List

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


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="Generate forward-only plots for run_3_3")
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
        help="SP peak denominator for peak overlays",
    )
    return parser.parse_args()


def pick_session(root: Path, explicit: str | None) -> Path:
    if explicit:
        session = Path(explicit).resolve()
        if not (session / "latest_run_avg.csv").is_file():
            raise SystemExit(f"CSV not found in session: {session}")
        return session

    sessions = []
    for p in sorted(root.iterdir()):
        if p.is_dir() and (p / "latest_run_avg.csv").is_file():
            sessions.append(p)
    if not sessions:
        raise SystemExit(f"No session with latest_run_avg.csv found under: {root}")
    return sessions[-1]


def style_plot(ax: plt.Axes, xlog: bool = True) -> None:
    ax.grid(True, alpha=0.25)
    if xlog:
        ax.set_xscale("log", base=2)


def load_data(csv_path: Path) -> pd.DataFrame:
    df = pd.read_csv(csv_path)
    df = df[df["workload"] == "throughput"].copy()

    numeric_cols = ["length", "batch", "threads", "avg_fwd_sp_gflops", "fwd_pct_of_peak", "avg_mem_mb"]
    for col in numeric_cols:
        df[col] = pd.to_numeric(df[col], errors="coerce")

    df["valid"] = df["avg_fwd_sp_gflops"] > 0
    df = df[df["profile"].isin(PROFILE_ORDER)].copy()
    return df


def plot_batch_panels(df: pd.DataFrame, out_dir: Path, peak_gflops: float) -> List[str]:
    out_dir.mkdir(parents=True, exist_ok=True)
    generated: List[str] = []

    for batch in sorted(df["batch"].dropna().unique()):
        sub = df[(df["batch"] == batch) & df["valid"]].copy()
        if sub.empty:
            continue

        fig, ax = plt.subplots(figsize=(12.5, 6.5))
        for profile in PROFILE_ORDER:
            p = sub[sub["profile"] == profile].sort_values("length")
            if p.empty:
                continue
            ax.plot(
                p["length"],
                p["avg_fwd_sp_gflops"],
                marker="o",
                linewidth=2.0,
                label=PROFILE_LABEL.get(profile, profile),
                color=PROFILE_COLOR.get(profile),
            )

        style_plot(ax)
        ax.axhline(peak_gflops, color="#B22222", linestyle="--", linewidth=1.2, label=f"Peak ({peak_gflops:.0f} SP GFLOPS)")
        ax.set_xlabel("Length (N)")
        ax.set_ylabel("Forward SP GFLOPS")
        ax.set_title(f"Forward throughput vs N | batch={int(batch)}")
        ax.legend(fontsize=9)
        ax.set_ylim(bottom=0)

        out = out_dir / f"batch_{int(batch):04d}_forward_panel.png"
        fig.tight_layout()
        fig.savefig(out, dpi=170)
        plt.close(fig)
        generated.append(str(out))
    return generated


def plot_nwise_cases(df: pd.DataFrame, out_dir: Path, peak_gflops: float) -> List[str]:
    out_dir.mkdir(parents=True, exist_ok=True)
    generated: List[str] = []
    valid = df[df["valid"]].copy()

    for length in sorted(valid["length"].dropna().unique()):
        sub = valid[valid["length"] == length].copy()
        if sub.empty:
            continue

        fig, ax = plt.subplots(figsize=(12.5, 6.8))
        for profile in PROFILE_ORDER:
            p = sub[sub["profile"] == profile].sort_values("batch")
            if p.empty:
                continue
            ax.plot(
                p["batch"],
                p["avg_fwd_sp_gflops"],
                marker="o",
                linewidth=2.0,
                label=PROFILE_LABEL.get(profile, profile),
                color=PROFILE_COLOR.get(profile),
            )

        style_plot(ax)
        ax.axhline(peak_gflops, color="#B22222", linestyle="--", linewidth=1.2, label=f"Peak ({peak_gflops:.0f} SP GFLOPS)")
        ax.set_xlabel("Batch size")
        ax.set_ylabel("Forward SP GFLOPS")
        ax.set_title(f"N-wise forward throughput vs batch | N={int(length)}")
        ax.legend(fontsize=9)
        ax.set_ylim(bottom=0)
        out = out_dir / f"n{int(length)}_forward_throughput_vs_batch.png"
        fig.tight_layout()
        fig.savefig(out, dpi=170)
        plt.close(fig)
        generated.append(str(out))

    return generated


def plot_batchwise_summary(df: pd.DataFrame, out_dir: Path, peak_gflops: float) -> List[str]:
    out_dir.mkdir(parents=True, exist_ok=True)
    generated: List[str] = []

    valid = df[df["valid"]].copy()
    by_batch = (
        valid.groupby(["batch", "profile"], as_index=False)[["avg_fwd_sp_gflops", "fwd_pct_of_peak"]]
        .max()
        .sort_values(["batch", "profile"])
    )

    fig, ax = plt.subplots(figsize=(12, 6))
    for profile in PROFILE_ORDER:
        p = by_batch[by_batch["profile"] == profile]
        if p.empty:
            continue
        ax.plot(
            p["batch"],
            p["avg_fwd_sp_gflops"],
            marker="o",
            linewidth=2.0,
            label=PROFILE_LABEL.get(profile, profile),
            color=PROFILE_COLOR.get(profile),
        )
    ax.axhline(peak_gflops, color="#B22222", linestyle="--", linewidth=1.2, label=f"Peak ({peak_gflops:.0f} SP GFLOPS)")
    style_plot(ax)
    ax.set_xlabel("Batch size")
    ax.set_ylabel("Best forward SP GFLOPS over N")
    ax.set_title("Batch-wise best forward throughput")
    ax.legend()
    out = out_dir / "batchwise_best_forward_gflops_line.png"
    fig.tight_layout()
    fig.savefig(out, dpi=170)
    plt.close(fig)
    generated.append(str(out))

    fig, ax = plt.subplots(figsize=(12, 6))
    for profile in PROFILE_ORDER:
        p = by_batch[by_batch["profile"] == profile]
        if p.empty:
            continue
        ax.plot(
            p["batch"],
            p["fwd_pct_of_peak"],
            marker="o",
            linewidth=2.0,
            label=PROFILE_LABEL.get(profile, profile),
            color=PROFILE_COLOR.get(profile),
        )
    ax.axhline(100.0, color="#B22222", linestyle="--", linewidth=1.2, label="100% peak")
    style_plot(ax)
    ax.set_xlabel("Batch size")
    ax.set_ylabel("Best forward % peak over N")
    ax.set_title("Batch-wise best forward %peak")
    ax.legend()
    out = out_dir / "batchwise_best_forward_pct_peak_line.png"
    fig.tight_layout()
    fig.savefig(out, dpi=170)
    plt.close(fig)
    generated.append(str(out))

    return generated


def plot_lengthwise_summary(df: pd.DataFrame, out_dir: Path, peak_gflops: float) -> List[str]:
    out_dir.mkdir(parents=True, exist_ok=True)
    generated: List[str] = []
    valid = df[df["valid"]].copy()

    by_len = (
        valid.groupby(["length", "profile"], as_index=False)[["avg_fwd_sp_gflops", "fwd_pct_of_peak"]]
        .max()
        .sort_values(["length", "profile"])
    )

    fig, ax = plt.subplots(figsize=(12, 6))
    for profile in PROFILE_ORDER:
        p = by_len[by_len["profile"] == profile]
        if p.empty:
            continue
        ax.plot(
            p["length"],
            p["avg_fwd_sp_gflops"],
            marker="o",
            linewidth=2.0,
            label=PROFILE_LABEL.get(profile, profile),
            color=PROFILE_COLOR.get(profile),
        )
    ax.axhline(peak_gflops, color="#B22222", linestyle="--", linewidth=1.2, label=f"Peak ({peak_gflops:.0f} SP GFLOPS)")
    style_plot(ax)
    ax.set_xlabel("Length (N)")
    ax.set_ylabel("Best forward SP GFLOPS over batches")
    ax.set_title("Length-wise best forward throughput")
    ax.legend()
    out = out_dir / "lengthwise_best_forward_gflops_line.png"
    fig.tight_layout()
    fig.savefig(out, dpi=170)
    plt.close(fig)
    generated.append(str(out))

    fig, ax = plt.subplots(figsize=(12, 6))
    for profile in PROFILE_ORDER:
        p = by_len[by_len["profile"] == profile]
        if p.empty:
            continue
        ax.plot(
            p["length"],
            p["fwd_pct_of_peak"],
            marker="o",
            linewidth=2.0,
            label=PROFILE_LABEL.get(profile, profile),
            color=PROFILE_COLOR.get(profile),
        )
    ax.axhline(100.0, color="#B22222", linestyle="--", linewidth=1.2, label="100% peak")
    style_plot(ax)
    ax.set_xlabel("Length (N)")
    ax.set_ylabel("Best forward % peak over batches")
    ax.set_title("Length-wise best forward %peak")
    ax.legend()
    out = out_dir / "lengthwise_best_forward_pct_peak_line.png"
    fig.tight_layout()
    fig.savefig(out, dpi=170)
    plt.close(fig)
    generated.append(str(out))

    return generated


def plot_heatmaps(df: pd.DataFrame, out_dir: Path) -> List[str]:
    out_dir.mkdir(parents=True, exist_ok=True)
    generated: List[str] = []
    valid = df[df["valid"]].copy()

    for profile in PROFILE_ORDER:
        p = valid[valid["profile"] == profile].copy()
        if p.empty:
            continue

        piv_g = p.pivot_table(index="length", columns="batch", values="avg_fwd_sp_gflops", aggfunc="max")
        piv_p = p.pivot_table(index="length", columns="batch", values="fwd_pct_of_peak", aggfunc="max")
        piv_g = piv_g.reindex(index=sorted(piv_g.index), columns=sorted(piv_g.columns))
        piv_p = piv_p.reindex(index=sorted(piv_p.index), columns=sorted(piv_p.columns))

        fig, ax = plt.subplots(figsize=(11, 7.5))
        sns.heatmap(piv_g, cmap="viridis", ax=ax, cbar_kws={"label": "Forward SP GFLOPS"})
        ax.set_title(f"Heatmap: forward SP GFLOPS | {PROFILE_LABEL.get(profile, profile)}")
        ax.set_xlabel("Batch")
        ax.set_ylabel("Length (N)")
        out = out_dir / f"heatmap_forward_gflops_{profile}.png"
        fig.tight_layout()
        fig.savefig(out, dpi=170)
        plt.close(fig)
        generated.append(str(out))

        fig, ax = plt.subplots(figsize=(11, 7.5))
        sns.heatmap(piv_p, cmap="YlOrRd", ax=ax, cbar_kws={"label": "Forward % of peak"})
        ax.set_title(f"Heatmap: forward %peak | {PROFILE_LABEL.get(profile, profile)}")
        ax.set_xlabel("Batch")
        ax.set_ylabel("Length (N)")
        out = out_dir / f"heatmap_forward_pct_peak_{profile}.png"
        fig.tight_layout()
        fig.savefig(out, dpi=170)
        plt.close(fig)
        generated.append(str(out))

    return generated


def plot_peak_summary(df: pd.DataFrame, out_dir: Path, peak_gflops: float) -> List[str]:
    out_dir.mkdir(parents=True, exist_ok=True)
    generated: List[str] = []
    valid = df[df["valid"]].copy()

    overall = (
        valid.groupby("profile", as_index=False)[["avg_fwd_sp_gflops", "fwd_pct_of_peak"]]
        .max()
        .set_index("profile")
        .reindex(PROFILE_ORDER)
        .reset_index()
    )
    overall["label"] = overall["profile"].map(lambda x: PROFILE_LABEL.get(x, x))

    fig, ax = plt.subplots(figsize=(10, 5.8))
    ax.bar(overall["label"], overall["avg_fwd_sp_gflops"], color="#4C78A8")
    ax.axhline(peak_gflops, color="#B22222", linestyle="--", linewidth=1.2, label=f"Peak ({peak_gflops:.0f})")
    ax.set_ylabel("Best Forward SP GFLOPS")
    ax.set_title("Overall best forward throughput by profile")
    ax.grid(True, axis="y", alpha=0.25)
    ax.legend()
    out = out_dir / "overall_best_forward_gflops_bar.png"
    fig.tight_layout()
    fig.savefig(out, dpi=170)
    plt.close(fig)
    generated.append(str(out))

    fig, ax = plt.subplots(figsize=(10, 5.8))
    ax.bar(overall["label"], overall["fwd_pct_of_peak"], color="#54A24B")
    ax.axhline(100.0, color="#B22222", linestyle="--", linewidth=1.2, label="100% peak")
    ax.set_ylabel("Best Forward % of Peak")
    ax.set_title("Overall best forward %peak by profile")
    ax.grid(True, axis="y", alpha=0.25)
    ax.legend()
    out = out_dir / "overall_best_forward_pct_peak_bar.png"
    fig.tight_layout()
    fig.savefig(out, dpi=170)
    plt.close(fig)
    generated.append(str(out))

    return generated


def write_summary(df: pd.DataFrame, out_path: Path, peak_gflops: float, generated_files: List[str]) -> None:
    valid = df[df["valid"]].copy()
    if valid.empty:
        out_path.write_text("No valid throughput points found.\n")
        return

    top_overall = valid.sort_values("avg_fwd_sp_gflops", ascending=False).head(15).copy()
    top_overall["profile_label"] = top_overall["profile"].map(lambda x: PROFILE_LABEL.get(x, x))

    by_profile = (
        valid.groupby("profile", as_index=False)[["avg_fwd_sp_gflops", "fwd_pct_of_peak"]]
        .max()
        .set_index("profile")
        .reindex(PROFILE_ORDER)
        .reset_index()
    )
    by_profile["profile_label"] = by_profile["profile"].map(lambda x: PROFILE_LABEL.get(x, x))

    lines: List[str] = []
    lines.append("# run_3_3 Plot Summary")
    lines.append("")
    lines.append(f"- Peak denominator used in plots: {peak_gflops:.1f} SP GFLOPS")
    lines.append(f"- Valid data points plotted: {len(valid)}")
    lines.append(f"- Batches covered: {', '.join(str(int(x)) for x in sorted(valid['batch'].unique()))}")
    lines.append("")
    lines.append("## Best Observed Forward Throughput by Profile")
    lines.append("")
    lines.append("| Profile | Best Forward GFLOPS | Best Forward % Peak |")
    lines.append("|---|---:|---:|")
    for _, row in by_profile.iterrows():
        lines.append(
            f"| {row['profile_label']} | {row['avg_fwd_sp_gflops']:.2f} | {row['fwd_pct_of_peak']:.2f}% |"
        )
    lines.append("")
    lines.append("## Top 15 Forward Cases")
    lines.append("")
    lines.append("| Case | N | Batch | Profile | Fwd GFLOPS | Fwd % Peak | Mem MB |")
    lines.append("|---|---:|---:|---|---:|---:|---:|")
    for _, row in top_overall.iterrows():
        lines.append(
            f"| {row['case']} | {int(row['length'])} | {int(row['batch'])} | {row['profile_label']} | "
            f"{row['avg_fwd_sp_gflops']:.2f} | {row['fwd_pct_of_peak']:.2f}% | {row['avg_mem_mb']:.2f} |"
        )
    lines.append("")
    lines.append("## Generated Plot Files")
    lines.append("")
    for p in sorted(generated_files):
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

    generated: List[str] = []
    generated.extend(plot_batch_panels(df, plots_root / "line_by_batch", args.peak_gflops))
    generated.extend(plot_nwise_cases(df, plots_root / "n-wise", args.peak_gflops))
    generated.extend(plot_batchwise_summary(df, plots_root / "batchwise", args.peak_gflops))
    generated.extend(plot_lengthwise_summary(df, plots_root / "lengthwise", args.peak_gflops))
    generated.extend(plot_heatmaps(df, plots_root / "heatmaps"))
    generated.extend(plot_peak_summary(df, plots_root / "peak_summary", args.peak_gflops))

    summary_path = plots_root / "PLOTS_SUMMARY.md"
    write_summary(df, summary_path, args.peak_gflops, generated)

    print(f"Session: {session}")
    print(f"CSV: {csv_path}")
    print(f"Plots root: {plots_root}")
    print(f"Generated files: {len(generated)}")
    print(f"Summary: {summary_path}")


if __name__ == "__main__":
    main()
