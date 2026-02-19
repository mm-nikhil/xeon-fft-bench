#!/usr/bin/env python3
"""
Compare averaged cuFFT throughput results against CPU 1D benchmark results.

Inputs:
  - Manifest file listing GPU logs (run_index|log|report).
  - CPU aggregated CSV produced by src/plots/generate_plots.py.

Notes:
  - GFLOPS is recomputed from averaged latency to keep timing/throughput
    internally consistent.
  - Latency speedup is reported only when GPU timing mode is e2e.
"""

from __future__ import annotations

import argparse
import csv
import math
from collections import defaultdict
from datetime import datetime
from pathlib import Path
from typing import Dict, List, Tuple


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="Compare GPU cuFFT vs CPU 1D FFT results")
    parser.add_argument("--manifest", required=True, help="GPU run manifest (pipe-delimited)")
    parser.add_argument(
        "--cpu-csv",
        default=str(Path(__file__).resolve().parents[1] / "plots" / "out" / "data" / "results_aggregated.csv"),
        help="CPU aggregated CSV path",
    )
    parser.add_argument("--gpu-profile", default="cufft_gpu", help="GPU profile_id to compare")
    parser.add_argument(
        "--gpu-timing-mode",
        choices=["auto", "compute", "e2e"],
        default="auto",
        help="Timing interpretation for selected GPU profile (auto derives from PROFILE metadata).",
    )
    parser.add_argument("--out", default=None, help="Output markdown path")
    return parser.parse_args()


def geomean(vals: List[float]) -> float:
    pos = [v for v in vals if v > 0.0]
    if not pos:
        return float("nan")
    return math.exp(sum(math.log(v) for v in pos) / len(pos))


def parse_manifest(manifest: Path) -> List[Path]:
    lines = manifest.read_text().strip().splitlines()
    if len(lines) <= 1:
        raise ValueError(f"Manifest has no run rows: {manifest}")

    logs: List[Path] = []
    for line in lines[1:]:
        parts = line.split("|")
        if len(parts) < 2:
            continue
        log_rel = parts[1].strip()
        p = Path(log_rel)
        if not p.is_file():
            p = (manifest.parent / log_rel).resolve()
        if not p.is_file():
            raise FileNotFoundError(f"GPU log from manifest not found: {log_rel}")
        logs.append(p)
    if not logs:
        raise ValueError("No valid logs resolved from manifest.")
    return logs


def fft_flops_1d(n: int, batch: int) -> float:
    return 5.0 * float(n) * math.log2(float(n)) * float(batch)


def parse_gpu_averages(logs: List[Path], gpu_profile: str) -> Tuple[List[Dict], str]:
    # key: (profile, n, batch, case_id)
    sums: Dict[Tuple[str, int, int, str], Dict[str, float]] = defaultdict(
        lambda: {
            "count": 0.0,
            "fwd_ms": 0.0,
            "bwd_ms": 0.0,
            "mem_mb": 0.0,
        }
    )
    detected_timing_mode = "unknown"

    for log in logs:
        for raw in log.read_text(errors="replace").splitlines():
            if raw.startswith("PROFILE|"):
                p = raw.split("|")
                if len(p) >= 9 and p[1] == gpu_profile and p[8] in {"compute", "e2e"}:
                    detected_timing_mode = p[8]
                continue
            if not raw.startswith("RESULT|"):
                continue
            p = raw.split("|")
            if len(p) < 14:
                continue
            profile_id = p[1]
            workload = p[2]
            if profile_id != gpu_profile or workload != "throughput":
                continue
            case_id = p[3]
            n = int(p[4])
            batch = int(p[7])
            key = (profile_id, n, batch, case_id)
            sums[key]["count"] += 1.0
            sums[key]["fwd_ms"] += float(p[9])
            sums[key]["bwd_ms"] += float(p[11])
            sums[key]["mem_mb"] += float(p[13])

    out: List[Dict] = []
    for (profile_id, n, batch, case_id), acc in sums.items():
        c = acc["count"]
        if c <= 0:
            continue
        avg_fwd_ms = acc["fwd_ms"] / c
        avg_bwd_ms = acc["bwd_ms"] / c
        flops = fft_flops_1d(n, batch)
        out.append(
            {
                "profile_id": profile_id,
                "case_id": case_id,
                "n": n,
                "batch": batch,
                "run_count": int(c),
                "fwd_ms": avg_fwd_ms,
                "fwd_gflops": flops / (avg_fwd_ms * 1.0e6) if avg_fwd_ms > 0 else float("nan"),
                "bwd_ms": avg_bwd_ms,
                "bwd_gflops": flops / (avg_bwd_ms * 1.0e6) if avg_bwd_ms > 0 else float("nan"),
                "mem_mb": acc["mem_mb"] / c,
            }
        )
    return out, detected_timing_mode


def parse_cpu_best(cpu_csv: Path) -> Dict[Tuple[int, int], Dict]:
    # best profile per (n,batch) by forward GFLOPS.
    best: Dict[Tuple[int, int], Dict] = {}
    with cpu_csv.open(newline="") as f:
        reader = csv.DictReader(f)
        for row in reader:
            if row.get("dataset_id") != "1d_single":
                continue
            if row.get("workload") != "throughput":
                continue
            n = int(float(row["nx"]))
            batch = int(float(row["batch"]))
            key = (n, batch)

            fwd_ms = float(row["fwd_ms_mean"])
            bwd_ms = float(row["bwd_ms_mean"])
            flops = fft_flops_1d(n, batch)
            cand = {
                "cpu_best_profile": row["profile_id"],
                "cpu_fwd_ms": fwd_ms,
                "cpu_fwd_gflops": flops / (fwd_ms * 1.0e6) if fwd_ms > 0 else float("nan"),
                "cpu_bwd_ms": bwd_ms,
                "cpu_bwd_gflops": flops / (bwd_ms * 1.0e6) if bwd_ms > 0 else float("nan"),
            }
            prev = best.get(key)
            if prev is None or cand["cpu_fwd_gflops"] > prev["cpu_fwd_gflops"]:
                best[key] = cand
    return best


def main() -> None:
    args = parse_args()
    manifest = Path(args.manifest).resolve()
    cpu_csv = Path(args.cpu_csv).resolve()
    if not manifest.is_file():
        raise FileNotFoundError(f"Manifest not found: {manifest}")
    if not cpu_csv.is_file():
        raise FileNotFoundError(f"CPU CSV not found: {cpu_csv}")

    logs = parse_manifest(manifest)
    gpu_rows, detected_timing_mode = parse_gpu_averages(logs, args.gpu_profile)
    if not gpu_rows:
        raise ValueError(f"No GPU throughput rows found for profile {args.gpu_profile}")
    timing_mode = detected_timing_mode if args.gpu_timing_mode == "auto" else args.gpu_timing_mode

    cpu_best = parse_cpu_best(cpu_csv)
    merged: List[Dict] = []
    for g in gpu_rows:
        key = (g["n"], g["batch"])
        c = cpu_best.get(key)
        if not c:
            continue
        r = dict(g)
        r.update(c)
        r["fwd_gflops_speedup_vs_cpu_best"] = r["fwd_gflops"] / r["cpu_fwd_gflops"]
        r["bwd_gflops_speedup_vs_cpu_best"] = r["bwd_gflops"] / r["cpu_bwd_gflops"]
        if timing_mode == "e2e":
            r["fwd_latency_speedup_vs_cpu_best"] = r["cpu_fwd_ms"] / r["fwd_ms"]
            r["bwd_latency_speedup_vs_cpu_best"] = r["cpu_bwd_ms"] / r["bwd_ms"]
        else:
            r["fwd_latency_speedup_vs_cpu_best"] = float("nan")
            r["bwd_latency_speedup_vs_cpu_best"] = float("nan")
        merged.append(r)

    if not merged:
        raise ValueError("No overlapping (N,batch) rows between GPU profile and CPU dataset")

    merged.sort(key=lambda x: (x["n"], x["batch"]))

    summary = {
        "rows": len(merged),
        "fwd_gflops_speedup_geomean": geomean([r["fwd_gflops_speedup_vs_cpu_best"] for r in merged]),
        "bwd_gflops_speedup_geomean": geomean([r["bwd_gflops_speedup_vs_cpu_best"] for r in merged]),
        "fwd_latency_speedup_geomean": geomean(
            [r["fwd_latency_speedup_vs_cpu_best"] for r in merged if not math.isnan(r["fwd_latency_speedup_vs_cpu_best"])]
        ),
        "bwd_latency_speedup_geomean": geomean(
            [r["bwd_latency_speedup_vs_cpu_best"] for r in merged if not math.isnan(r["bwd_latency_speedup_vs_cpu_best"])]
        ),
    }

    ts = datetime.now().strftime("%Y%m%d_%H%M%S")
    out_path = Path(args.out).resolve() if args.out else manifest.parent / f"gpu_vs_cpu_1d_comparison_{ts}.md"

    lines: List[str] = []
    lines.append("# GPU vs CPU 1D FFT Comparison")
    lines.append("")
    lines.append(f"- Generated at: {datetime.now()}")
    lines.append(f"- GPU manifest: `{manifest}`")
    lines.append(f"- CPU source CSV: `{cpu_csv}`")
    lines.append(f"- GPU profile compared: `{args.gpu_profile}`")
    lines.append(f"- GPU timing mode interpreted as: `{timing_mode}`")
    lines.append(f"- Overlapping throughput cases: {summary['rows']}")
    lines.append("")
    lines.append("## Summary")
    lines.append("")
    lines.append(f"- Geomean forward GFLOPS speedup vs CPU best-profile-per-case: **{summary['fwd_gflops_speedup_geomean']:.2f}x**")
    lines.append(f"- Geomean backward GFLOPS speedup vs CPU best-profile-per-case: **{summary['bwd_gflops_speedup_geomean']:.2f}x**")
    if timing_mode == "e2e":
        lines.append(f"- Geomean forward latency speedup vs CPU best-profile-per-case: **{summary['fwd_latency_speedup_geomean']:.2f}x**")
        lines.append(f"- Geomean backward latency speedup vs CPU best-profile-per-case: **{summary['bwd_latency_speedup_geomean']:.2f}x**")
    elif timing_mode == "compute":
        lines.append("- Latency speedup is **not reported** because GPU timing mode is compute-only (no H2D/D2H).")
    else:
        lines.append("- Latency speedup is **not reported** because GPU timing mode could not be verified as e2e from log metadata.")
    lines.append("")
    lines.append("## Per-Case Results")
    lines.append("")
    lines.append("| Case | N | Batch | GPU Fwd ms | GPU Fwd GFLOPS | CPU Best Profile | CPU Fwd ms | CPU Fwd GFLOPS | Fwd GFLOPS Speedup | GPU Bwd ms | GPU Bwd GFLOPS | CPU Bwd ms | CPU Bwd GFLOPS | Bwd GFLOPS Speedup |")
    lines.append("|---|---:|---:|---:|---:|---|---:|---:|---:|---:|---:|---:|---:|---:|")
    for r in merged:
        lines.append(
            f"| {r['case_id']} | {r['n']} | {r['batch']} | "
            f"{r['fwd_ms']:.6f} | {r['fwd_gflops']:.2f} | {r['cpu_best_profile']} | "
            f"{r['cpu_fwd_ms']:.6f} | {r['cpu_fwd_gflops']:.2f} | {r['fwd_gflops_speedup_vs_cpu_best']:.2f}x | "
            f"{r['bwd_ms']:.6f} | {r['bwd_gflops']:.2f} | {r['cpu_bwd_ms']:.6f} | "
            f"{r['cpu_bwd_gflops']:.2f} | {r['bwd_gflops_speedup_vs_cpu_best']:.2f}x |"
        )

    out_path.write_text("\n".join(lines))
    print(f"Comparison report written: {out_path}")


if __name__ == "__main__":
    main()
