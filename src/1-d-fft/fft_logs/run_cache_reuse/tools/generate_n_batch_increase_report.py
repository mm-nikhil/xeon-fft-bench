#!/usr/bin/env python3
from __future__ import annotations

import argparse
from pathlib import Path
from typing import Dict, List

import matplotlib

matplotlib.use("Agg")
import matplotlib.pyplot as plt
import pandas as pd

PROFILE_ORDER = ["baseline_sse42_1t", "avx512_phys", "avx512_logical"]
PROFILE_LABEL = {
    "baseline_sse42_1t": "SSE4.2 baseline (1T)",
    "avx512_phys": "AVX512 (10T)",
    "avx512_logical": "AVX512 (20T)",
}
PROFILE_COLOR = {
    "baseline_sse42_1t": "#4C78A8",
    "avx512_phys": "#F58518",
    "avx512_logical": "#54A24B",
}


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="Generate per-N batch increase report/plots from averaged run_3_3 CSV")
    parser.add_argument(
        "--session-dir",
        required=True,
        help="Session directory containing latest_run_avg.csv",
    )
    parser.add_argument(
        "--csv",
        default=None,
        help="Optional explicit csv path (defaults to <session-dir>/latest_run_avg.csv)",
    )
    return parser.parse_args()


def load_data(csv_path: Path) -> pd.DataFrame:
    df = pd.read_csv(csv_path)
    df = df[df["workload"] == "throughput"].copy()

    numeric_cols = [
        "length",
        "batch",
        "threads",
        "avg_fwd_sp_gflops",
        "fwd_speedup_vs_sse42_1t",
    ]
    for col in numeric_cols:
        df[col] = pd.to_numeric(df[col], errors="coerce")

    df = df[df["profile"].isin(PROFILE_ORDER)].copy()
    df["fwd_pct_increase_vs_sse42_1t"] = (df["fwd_speedup_vs_sse42_1t"] - 1.0) * 100.0
    return df


def write_markdown(df: pd.DataFrame, out_md: Path) -> None:
    lines: List[str] = []
    lines.append("# Per-N Batch Increase Report (Averaged, Forward)")
    lines.append("")
    lines.append("- Increase is measured vs `baseline_sse42_1t` for the same `N` and `batch`.")
    lines.append("- `% Increase = (Speedup - 1) * 100`.")
    lines.append("")

    top = df[df["profile"].isin(["avx512_phys", "avx512_logical"])].copy()
    top = top.sort_values("fwd_pct_increase_vs_sse42_1t", ascending=False).head(20)
    lines.append("## Top 20 Increases")
    lines.append("")
    lines.append("| N | Batch | Profile | Fwd GFLOPS | Speedup vs SSE4.2 1T | % Increase |")
    lines.append("|---:|---:|---|---:|---:|---:|")
    for _, r in top.iterrows():
        lines.append(
            f"| {int(r['length'])} | {int(r['batch'])} | {PROFILE_LABEL.get(r['profile'], r['profile'])} "
            f"| {r['avg_fwd_sp_gflops']:.2f} | {r['fwd_speedup_vs_sse42_1t']:.4f} | {r['fwd_pct_increase_vs_sse42_1t']:.2f}% |"
        )
    lines.append("")

    for n in sorted(df["length"].dropna().unique()):
        sub = df[df["length"] == n].copy()
        batches = sorted(sub["batch"].dropna().unique())
        by_key: Dict[tuple, pd.Series] = {(int(r["batch"]), r["profile"]): r for _, r in sub.iterrows()}

        lines.append(f"## N = {int(n)}")
        lines.append("")
        lines.append("| Batch | Baseline GFLOPS | AVX512 10T GFLOPS | 10T Speedup | 10T % Increase | AVX512 20T GFLOPS | 20T Speedup | 20T % Increase | Winner |")
        lines.append("|---:|---:|---:|---:|---:|---:|---:|---:|---|")
        for b in batches:
            base = by_key.get((int(b), "baseline_sse42_1t"))
            phys = by_key.get((int(b), "avx512_phys"))
            logi = by_key.get((int(b), "avx512_logical"))

            base_g = float(base["avg_fwd_sp_gflops"]) if base is not None else float("nan")
            phys_g = float(phys["avg_fwd_sp_gflops"]) if phys is not None else float("nan")
            logi_g = float(logi["avg_fwd_sp_gflops"]) if logi is not None else float("nan")
            phys_s = float(phys["fwd_speedup_vs_sse42_1t"]) if phys is not None else float("nan")
            logi_s = float(logi["fwd_speedup_vs_sse42_1t"]) if logi is not None else float("nan")
            phys_i = float(phys["fwd_pct_increase_vs_sse42_1t"]) if phys is not None else float("nan")
            logi_i = float(logi["fwd_pct_increase_vs_sse42_1t"]) if logi is not None else float("nan")

            winner = "-"
            if pd.notna(phys_g) and pd.notna(logi_g):
                winner = "AVX512 10T" if phys_g >= logi_g else "AVX512 20T"
            elif pd.notna(phys_g):
                winner = "AVX512 10T"
            elif pd.notna(logi_g):
                winner = "AVX512 20T"

            lines.append(
                f"| {int(b)} | {base_g:.2f} | {phys_g:.2f} | {phys_s:.4f} | {phys_i:.2f}% | {logi_g:.2f} | {logi_s:.4f} | {logi_i:.2f}% | {winner} |"
            )
        lines.append("")

    out_md.write_text("\n".join(lines))


def generate_plots(df: pd.DataFrame, out_dir: Path) -> int:
    out_dir.mkdir(parents=True, exist_ok=True)
    count = 0

    for n in sorted(df["length"].dropna().unique()):
        sub = df[df["length"] == n].copy()
        if sub.empty:
            continue

        fig, axes = plt.subplots(1, 2, figsize=(15, 5.8))

        for profile in PROFILE_ORDER:
            p = sub[sub["profile"] == profile].sort_values("batch")
            if p.empty:
                continue
            axes[0].plot(
                p["batch"],
                p["avg_fwd_sp_gflops"],
                marker="o",
                linewidth=2.0,
                label=PROFILE_LABEL.get(profile, profile),
                color=PROFILE_COLOR.get(profile),
            )

        for profile in ["avx512_phys", "avx512_logical"]:
            p = sub[sub["profile"] == profile].sort_values("batch")
            if p.empty:
                continue
            axes[1].plot(
                p["batch"],
                p["fwd_pct_increase_vs_sse42_1t"],
                marker="o",
                linewidth=2.0,
                label=PROFILE_LABEL.get(profile, profile),
                color=PROFILE_COLOR.get(profile),
            )

        for ax in axes:
            ax.set_xscale("log", base=2)
            ax.grid(True, alpha=0.25)
            ax.set_xlabel("Batch")

        axes[0].set_title(f"N={int(n)}: Forward GFLOPS vs Batch")
        axes[0].set_ylabel("Forward SP GFLOPS")
        axes[0].legend(fontsize=9)

        axes[1].axhline(0.0, color="#666666", linestyle="--", linewidth=1.0)
        axes[1].set_title(f"N={int(n)}: % Increase vs SSE4.2 1T")
        axes[1].set_ylabel("% Increase")
        axes[1].legend(fontsize=9)

        fig.tight_layout()
        out = out_dir / f"n{int(n)}_batch_forward_and_increase.png"
        fig.savefig(out, dpi=170)
        plt.close(fig)
        count += 1

    return count


def main() -> None:
    args = parse_args()
    session_dir = Path(args.session_dir).resolve()
    csv_path = Path(args.csv).resolve() if args.csv else (session_dir / "latest_run_avg.csv")
    if not csv_path.is_file():
        raise SystemExit(f"CSV not found: {csv_path}")

    df = load_data(csv_path)
    out_md = session_dir / "n_batch_increase.report.md"
    out_plot_dir = session_dir / "plots" / "n-wise-increase"

    write_markdown(df, out_md)
    nplots = generate_plots(df, out_plot_dir)

    print(f"Session: {session_dir}")
    print(f"CSV: {csv_path}")
    print(f"Markdown: {out_md}")
    print(f"Increase plot dir: {out_plot_dir}")
    print(f"Plots generated: {nplots}")


if __name__ == "__main__":
    main()
