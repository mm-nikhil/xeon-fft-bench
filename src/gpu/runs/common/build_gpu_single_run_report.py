#!/usr/bin/env python3
from __future__ import annotations

import argparse
from collections import defaultdict
from datetime import datetime
from pathlib import Path


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="Build a markdown summary for one GPU benchmark log")
    parser.add_argument("--log", required=True, help="run log path")
    parser.add_argument("--out", required=True, help="markdown output path")
    return parser.parse_args()


def main() -> None:
    args = parse_args()
    log_path = Path(args.log).resolve()
    out_path = Path(args.out).resolve()

    if not log_path.is_file():
        raise FileNotFoundError(f"log not found: {log_path}")

    config: dict[str, str] = {}
    profile: dict[str, str] = {}
    rows: list[dict[str, str]] = []
    checks: dict[str, str] = {}

    for raw in log_path.read_text(errors="replace").splitlines():
        line = raw.strip()
        if line.startswith("CONFIG|"):
            parts = raw.split("|", 2)
            if len(parts) == 3:
                config[parts[1]] = parts[2]
            continue
        if line.startswith("PROFILE|"):
            parts = raw.split("|")
            if len(parts) >= 9:
                profile = {
                    "id": parts[1],
                    "desc": parts[2],
                    "lib": parts[3],
                    "threads_field": parts[4],
                    "workload": parts[5],
                    "lengths": parts[6],
                    "batches": parts[7],
                    "family": parts[8],
                }
            continue
        if line.startswith("CHECK|"):
            parts = raw.split("|")
            if len(parts) >= 13:
                key = f"{parts[1]}::{parts[2]}::{parts[3]}::{parts[4]}::{parts[7]}::{parts[8]}"
                checks[key] = parts[12]
            continue
        if line.startswith("RESULT|"):
            parts = raw.split("|")
            if len(parts) >= 16:
                rows.append(
                    {
                        "status": "ok",
                        "profile": parts[1],
                        "workload": parts[2],
                        "case": parts[3],
                        "n": parts[4],
                        "batch": parts[7],
                        "threads_field": parts[8],
                        "fwd_ms": parts[9],
                        "fwd_gflops": parts[10],
                        "bwd_ms": parts[11],
                        "bwd_gflops": parts[12],
                        "mem_mb": parts[13],
                        "slots": parts[14],
                        "work_mb": parts[15],
                    }
                )
            continue
        if line.startswith("SKIP|"):
            parts = raw.split("|")
            if len(parts) >= 13:
                rows.append(
                    {
                        "status": "skip",
                        "profile": parts[1],
                        "workload": parts[2],
                        "case": parts[3],
                        "n": parts[4],
                        "batch": parts[7],
                        "threads_field": parts[8],
                        "fwd_ms": "-",
                        "fwd_gflops": "-",
                        "bwd_ms": "-",
                        "bwd_gflops": "-",
                        "mem_mb": parts[9],
                        "reason": parts[10],
                        "slots": parts[11],
                        "work_mb": parts[12],
                    }
                )

    out_path.parent.mkdir(parents=True, exist_ok=True)

    lines: list[str] = []
    lines.append("# GPU FFT Run Report")
    lines.append("")
    lines.append(f"- Generated at: {datetime.now()}")
    lines.append(f"- Source log: `{log_path}`")
    if profile:
        lines.append(f"- Profile: `{profile['id']}`")
        lines.append(f"- Description: {profile['desc']}")
        lines.append(f"- Workload: `{profile['workload']}`")
        lines.append(f"- Family: `{profile['family']}`")
    lines.append("")

    if config:
        lines.append("## Config")
        lines.append("")
        for key in sorted(config):
            lines.append(f"- `{key}` = `{config[key]}`")
        lines.append("")

    lines.append("## Results")
    lines.append("")
    lines.append(
        "| Case | N | Batch | ThreadsField | Status | Fwd ms | Fwd SP GFLOPS | "
        "Bwd ms | Bwd SP GFLOPS | Mem MB | Slots | Work MB | Validation | Note |"
    )
    lines.append("|---|---:|---:|---:|---|---:|---:|---:|---:|---:|---:|---:|---|---|")

    status_counts = defaultdict(int)
    for row in rows:
        status_counts[row["status"]] += 1
        key = f"{row['profile']}::{row['workload']}::{row['case']}::{row['n']}::{row['batch']}::{row['threads_field']}"
        validation = checks.get(key, "-")
        note = row.get("reason", "-")
        lines.append(
            f"| {row['case']} | {row['n']} | {row['batch']} | {row['threads_field']} | {row['status']} | "
            f"{row['fwd_ms']} | {row['fwd_gflops']} | {row['bwd_ms']} | {row['bwd_gflops']} | "
            f"{row['mem_mb']} | {row['slots']} | {row['work_mb']} | {validation} | {note} |"
        )
    lines.append("")
    lines.append(f"- Status counts: {dict(status_counts)}")

    out_path.write_text("\n".join(lines))


if __name__ == "__main__":
    main()
