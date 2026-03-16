#!/usr/bin/env python3
from __future__ import annotations

import argparse
import csv
import math
from collections import Counter, defaultdict
from dataclasses import dataclass
from datetime import datetime
from pathlib import Path
from typing import Dict, Iterable, List, Tuple


@dataclass
class RowAgg:
    ok_count: int = 0
    skip_count: int = 0
    check_total: int = 0
    check_fail: int = 0
    fwd_ms_sum: float = 0.0
    bwd_ms_sum: float = 0.0
    mem_sum: float = 0.0
    slots_sum: float = 0.0
    work_sum: float = 0.0
    skip_mem_sum: float = 0.0
    skip_slots_sum: float = 0.0
    skip_work_sum: float = 0.0
    skip_reason: str = ""


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="Build averaged GPU benchmark CSV + report")
    parser.add_argument("--manifest", required=True, help="manifest.tsv path")
    parser.add_argument("--out-csv", required=True, help="output averaged CSV")
    parser.add_argument("--out-md", required=True, help="output markdown report")
    parser.add_argument("--gpu-query", default=None, help="nvidia_smi_query.csv path")
    return parser.parse_args()


def read_manifest(path: Path) -> List[Tuple[str, Path, Path]]:
    if not path.is_file():
        raise FileNotFoundError(f"manifest not found: {path}")

    text = path.read_text(errors="replace").splitlines()
    if not text:
        raise ValueError(f"manifest is empty: {path}")
    delim = "\t" if "\t" in text[0] else "|"

    rows: List[Tuple[str, Path, Path]] = []
    with path.open(newline="") as f:
        reader = csv.DictReader(f, delimiter=delim)
        for row in reader:
            run_id = (row.get("run_id") or row.get("run_index") or "").strip()
            log_path = (row.get("log_path") or row.get("log") or "").strip()
            report_path = (row.get("report_path") or row.get("report") or "").strip()
            if not run_id or not log_path:
                continue
            rows.append((run_id, Path(log_path), Path(report_path) if report_path else Path("")))

    if not rows:
        raise ValueError(f"manifest has no rows: {path}")
    return rows


def parse_cc(s: str) -> Tuple[int, int]:
    try:
        major, minor = s.strip().split(".", 1)
        return int(major), int(minor)
    except Exception:
        return (-1, -1)


def cuda_cores_per_sm(major: int, minor: int) -> int:
    if major == 2:
        return 48 if minor == 1 else 32
    if major == 3:
        return 192
    if major == 5:
        return 128
    if major == 6:
        return 64 if minor == 0 else 128
    if major == 7:
        return 64
    if major == 8:
        return 64 if minor == 0 else 128
    if major == 9:
        return 128
    return 0


def parse_gpu_query(path: Path | None) -> Dict[str, str]:
    if path is None or not path.is_file():
        return {}
    lines = path.read_text(errors="replace").strip().splitlines()
    if not lines:
        return {}
    parts = [p.strip() for p in lines[0].split(",")]
    keys = ["name", "driver_version", "max_sm_clock_mhz", "max_graphics_clock_mhz", "memory_total_mib"]
    return {k: parts[idx] for idx, k in enumerate(keys) if idx < len(parts)}


def fft_flops_1d(n: int, batch: int) -> float:
    return 5.0 * float(n) * math.log2(float(n)) * float(batch)


def workload_rank(workload: str) -> int:
    return 1 if workload == "throughput" else 9


def parse_logs(
    run_rows: List[Tuple[str, Path, Path]]
) -> Tuple[List[Dict], Dict[str, str], List[Dict], Dict[str, str]]:
    agg: Dict[Tuple[str, str, str, int, int, int], RowAgg] = defaultdict(RowAgg)
    profile_meta: Dict[str, Dict[str, str]] = {}
    hw: Dict[str, str] = {}
    config: Dict[str, str] = {}

    for run_index, (run_id, log_path, _) in enumerate(run_rows):
        if not log_path.is_file():
            raise FileNotFoundError(f"log not found: {log_path}")

        for raw in log_path.read_text(errors="replace").splitlines():
            line = raw.strip()
            if line.startswith("CONFIG|"):
                parts = raw.split("|", 2)
                if len(parts) == 3 and run_index == 0:
                    config[parts[1]] = parts[2]
                continue

            if line.startswith("gpu_name         :"):
                hw["gpu_name"] = line.split(":", 1)[1].strip()
                continue
            if line.startswith("compute_cap      :"):
                hw["compute_cap"] = line.split(":", 1)[1].strip()
                continue
            if line.startswith("sm_count         :"):
                hw["sm_count"] = line.split(":", 1)[1].strip()
                continue
            if line.startswith("warp_size        :"):
                hw["warp_size"] = line.split(":", 1)[1].strip()
                continue
            if line.startswith("max_threads_sm   :"):
                hw["max_threads_sm"] = line.split(":", 1)[1].strip()
                continue
            if line.startswith("max_threads_blk  :"):
                hw["max_threads_blk"] = line.split(":", 1)[1].strip()
                continue
            if line.startswith("global_mem_mb    :"):
                hw["global_mem_mb"] = line.split(":", 1)[1].strip()
                continue

            if raw.startswith("PROFILE|"):
                parts = raw.split("|")
                if len(parts) >= 9:
                    profile_meta[parts[1]] = {
                        "profile_desc": parts[2],
                        "library": parts[3],
                        "threads_field": parts[4],
                        "workload": parts[5],
                        "family": parts[8],
                    }
                continue

            if raw.startswith("RESULT|"):
                parts = raw.split("|")
                if len(parts) < 16:
                    continue
                key = (parts[1], parts[2], parts[3], int(parts[4]), int(parts[7]), int(parts[8]))
                rec = agg[key]
                rec.ok_count += 1
                rec.fwd_ms_sum += float(parts[9])
                rec.bwd_ms_sum += float(parts[11])
                rec.mem_sum += float(parts[13])
                rec.slots_sum += float(parts[14])
                rec.work_sum += float(parts[15])
                continue

            if raw.startswith("SKIP|"):
                parts = raw.split("|")
                if len(parts) < 13:
                    continue
                key = (parts[1], parts[2], parts[3], int(parts[4]), int(parts[7]), int(parts[8]))
                rec = agg[key]
                rec.skip_count += 1
                rec.skip_mem_sum += float(parts[9])
                rec.skip_reason = parts[10]
                rec.skip_slots_sum += float(parts[11])
                rec.skip_work_sum += float(parts[12])
                continue

            if raw.startswith("CHECK|"):
                parts = raw.split("|")
                if len(parts) < 13:
                    continue
                key = (parts[1], parts[2], parts[3], int(parts[4]), int(parts[7]), int(parts[8]))
                rec = agg[key]
                rec.check_total += 1
                if parts[12] != "PASS":
                    rec.check_fail += 1

    run_count_expected = len(run_rows)
    rows: List[Dict] = []
    for key, rec in agg.items():
        profile, workload, case_id, n, batch, threads_field = key
        ok = rec.ok_count
        skip = rec.skip_count

        if ok > 0:
            fwd_ms = rec.fwd_ms_sum / ok
            bwd_ms = rec.bwd_ms_sum / ok
            mem_mb = rec.mem_sum / ok
            avg_slots = rec.slots_sum / ok
            avg_work_mb = rec.work_sum / ok
            flops = fft_flops_1d(n, batch)
            fwd_gf = flops / (fwd_ms * 1.0e6) if fwd_ms > 0.0 else float("nan")
            bwd_gf = flops / (bwd_ms * 1.0e6) if bwd_ms > 0.0 else float("nan")
            note = "-"
        else:
            fwd_ms = float("nan")
            bwd_ms = float("nan")
            mem_mb = rec.skip_mem_sum / skip if skip > 0 else float("nan")
            avg_slots = rec.skip_slots_sum / skip if skip > 0 else float("nan")
            avg_work_mb = rec.skip_work_sum / skip if skip > 0 else float("nan")
            fwd_gf = float("nan")
            bwd_gf = float("nan")
            note = rec.skip_reason or "skip"

        check_ok = rec.check_total - rec.check_fail
        if check_ok < 0:
            check_ok = 0
        check_missing = ok - rec.check_total if ok > rec.check_total else 0

        quality = "ok"
        if (ok + skip) != run_count_expected or rec.check_fail > 0 or check_missing > 0:
            quality = "incomplete"

        if ok == 0:
            note = f"skip:{rec.skip_reason or 'unknown'}"
        elif rec.check_fail > 0:
            note = "validation_fail"
        elif check_missing > 0:
            note = "missing_check"

        rows.append(
            {
                "workload": workload,
                "case": case_id,
                "length": n,
                "batch": batch,
                "threads_field": threads_field,
                "profile": profile,
                "profile_desc": profile_meta.get(profile, {}).get("profile_desc", ""),
                "family": profile_meta.get(profile, {}).get("family", ""),
                "avg_fwd_ms": fwd_ms,
                "avg_fwd_sp_gflops": fwd_gf,
                "avg_bwd_ms": bwd_ms,
                "avg_bwd_sp_gflops": bwd_gf,
                "avg_mem_mb": mem_mb,
                "avg_stream_slots": avg_slots,
                "avg_workarea_mb": avg_work_mb,
                "samples_ok": ok,
                "samples_skip": skip,
                "samples_expected": run_count_expected,
                "check_ok": check_ok,
                "check_fail": rec.check_fail,
                "quality": quality,
                "note": note,
            }
        )

    rows.sort(
        key=lambda r: (
            workload_rank(r["workload"]),
            int(r["length"]),
            int(r["batch"]),
            int(r["threads_field"]),
            r["profile"],
        )
    )

    profile_rows = [
        {
            "profile": pid,
            "description": meta.get("profile_desc", ""),
            "family": meta.get("family", ""),
            "library": meta.get("library", ""),
            "workload": meta.get("workload", ""),
        }
        for pid, meta in sorted(profile_meta.items())
    ]
    return rows, hw, profile_rows, config


def write_csv(rows: List[Dict], out_csv: Path, peak_gflops: float) -> None:
    out_csv.parent.mkdir(parents=True, exist_ok=True)
    fields = [
        "workload",
        "case",
        "length",
        "batch",
        "threads_field",
        "profile",
        "family",
        "avg_fwd_ms",
        "avg_fwd_sp_gflops",
        "avg_bwd_ms",
        "avg_bwd_sp_gflops",
        "avg_mem_mb",
        "avg_stream_slots",
        "avg_workarea_mb",
        "fwd_pct_of_peak",
        "bwd_pct_of_peak",
        "samples_ok",
        "samples_skip",
        "samples_expected",
        "check_ok",
        "check_fail",
        "quality",
        "note",
    ]

    with out_csv.open("w", newline="") as f:
        writer = csv.DictWriter(f, fieldnames=fields)
        writer.writeheader()
        for row in rows:
            rec = {field: row.get(field, "") for field in fields}
            if math.isfinite(rec["avg_fwd_sp_gflops"]) and peak_gflops > 0:
                rec["fwd_pct_of_peak"] = 100.0 * rec["avg_fwd_sp_gflops"] / peak_gflops
            else:
                rec["fwd_pct_of_peak"] = float("nan")
            if math.isfinite(rec["avg_bwd_sp_gflops"]) and peak_gflops > 0:
                rec["bwd_pct_of_peak"] = 100.0 * rec["avg_bwd_sp_gflops"] / peak_gflops
            else:
                rec["bwd_pct_of_peak"] = float("nan")
            writer.writerow(rec)


def fmt_ms(v: float) -> str:
    if not math.isfinite(v):
        return "-"
    if v >= 0.1:
        return f"{v:.3f}"
    if v >= 0.01:
        return f"{v:.4f}"
    return f"{v:.6f}"


def fmt_float(v: float, precision: int = 2) -> str:
    if not math.isfinite(v):
        return "-"
    return f"{v:.{precision}f}"


def fmt_pct(v: float) -> str:
    if not math.isfinite(v):
        return "-"
    return f"{v:.2f}%"


def write_report(
    out_md: Path,
    manifest: Path,
    run_rows: List[Tuple[str, Path, Path]],
    rows: List[Dict],
    profile_rows: List[Dict],
    hw_log: Dict[str, str],
    gpu_query: Dict[str, str],
    config: Dict[str, str],
) -> None:
    out_md.parent.mkdir(parents=True, exist_ok=True)

    cc_major, cc_minor = parse_cc(hw_log.get("compute_cap", ""))
    cores_per_sm = cuda_cores_per_sm(cc_major, cc_minor) if cc_major >= 0 else 0
    sm_count = int(hw_log.get("sm_count", "0") or 0)
    warp_size = int(hw_log.get("warp_size", "0") or 0)
    max_threads_sm = int(hw_log.get("max_threads_sm", "0") or 0)
    max_threads_blk = int(hw_log.get("max_threads_blk", "0") or 0)
    cuda_cores = sm_count * cores_per_sm if sm_count > 0 and cores_per_sm > 0 else 0
    resident_threads = sm_count * max_threads_sm if sm_count > 0 and max_threads_sm > 0 else 0
    max_sm_clock_mhz = float(gpu_query.get("max_sm_clock_mhz", "0") or 0.0)
    peak_sp_gflops = cuda_cores * 2.0 * (max_sm_clock_mhz / 1000.0) if cuda_cores > 0 and max_sm_clock_mhz > 0 else 0.0

    valid_rows = [r for r in rows if math.isfinite(r["avg_fwd_sp_gflops"])]
    best_fwd = max(valid_rows, key=lambda r: r["avg_fwd_sp_gflops"]) if valid_rows else None
    best_bwd_rows = [r for r in rows if math.isfinite(r["avg_bwd_sp_gflops"])]
    best_bwd = max(best_bwd_rows, key=lambda r: r["avg_bwd_sp_gflops"]) if best_bwd_rows else None

    lines: List[str] = []
    family = profile_rows[0]["family"] if profile_rows else "gpu_fft_run"
    lines.append(f"# {family} ({len(run_rows)}-run average)")
    lines.append("")
    lines.append(f"- Generated at: {datetime.now()}")
    lines.append(f"- Manifest: `{manifest.resolve()}`")
    lines.append(f"- Runs combined: {len(run_rows)}")
    lines.append("")

    lines.append("## GPU Hardware")
    lines.append("")
    lines.append(f"- GPU: {hw_log.get('gpu_name', gpu_query.get('name', 'unknown'))}")
    lines.append(f"- Driver version: {gpu_query.get('driver_version', 'unknown')}")
    lines.append(f"- Compute capability: {hw_log.get('compute_cap', 'unknown')}")
    lines.append(f"- SM count: {sm_count}")
    lines.append(f"- CUDA cores/SM: {cores_per_sm if cores_per_sm else 'unknown'}")
    lines.append(f"- Total CUDA cores: {cuda_cores if cuda_cores else 'unknown'}")
    lines.append(f"- Warp size: {warp_size if warp_size else 'unknown'}")
    lines.append(f"- Max threads/SM: {max_threads_sm if max_threads_sm else 'unknown'}")
    lines.append(f"- Max threads/block: {max_threads_blk if max_threads_blk else 'unknown'}")
    lines.append(f"- Max resident threads on device: {resident_threads if resident_threads else 'unknown'}")
    lines.append(f"- Global memory: {hw_log.get('global_mem_mb', gpu_query.get('memory_total_mib', 'unknown'))} MB")
    lines.append("")

    lines.append("## Peak Model")
    lines.append("")
    lines.append("- SP peak formula: `cuda_cores * 2 FLOP/cycle * max_sm_clock_ghz`")
    lines.append(f"- Max SM clock from nvidia-smi: {max_sm_clock_mhz:.0f} MHz")
    lines.append(f"- Peak denominator for %peak: {peak_sp_gflops:.2f} GFLOPS")
    lines.append("")

    if config:
        lines.append("## Run Config")
        lines.append("")
        for key in sorted(config):
            lines.append(f"- `{key}` = `{config[key]}`")
        lines.append("")

    lines.append("## Run Files")
    lines.append("")
    lines.append("| Run | Log | Report |")
    lines.append("|---|---|---|")
    for run_id, log_path, report_path in run_rows:
        lines.append(f"| {run_id} | `{log_path}` | `{report_path}` |")
    lines.append("")

    lines.append("## Scenario Catalog")
    lines.append("")
    lines.append("| Profile | Description | Workload | Library | Family |")
    lines.append("|---|---|---|---|---|")
    for row in profile_rows:
        lines.append(
            f"| {row['profile']} | {row['description']} | {row['workload']} | {row['library']} | {row['family']} |"
        )
    lines.append("")

    lines.append("## Summary Stats")
    lines.append("")
    lines.append(f"- Rows aggregated: {len(rows)}")
    lines.append(f"- Quality counts: {dict(Counter(r['quality'] for r in rows))}")
    if best_fwd:
        fwd_pct = 100.0 * best_fwd["avg_fwd_sp_gflops"] / peak_sp_gflops if peak_sp_gflops > 0 else float("nan")
        lines.append(
            f"- Best forward: `{best_fwd['case']}` = {best_fwd['avg_fwd_sp_gflops']:.2f} GFLOPS "
            f"({fmt_pct(fwd_pct)})"
        )
    if best_bwd:
        bwd_pct = 100.0 * best_bwd["avg_bwd_sp_gflops"] / peak_sp_gflops if peak_sp_gflops > 0 else float("nan")
        lines.append(
            f"- Best backward: `{best_bwd['case']}` = {best_bwd['avg_bwd_sp_gflops']:.2f} GFLOPS "
            f"({fmt_pct(bwd_pct)})"
        )
    lines.append("")

    lines.append("## Averaged Results")
    lines.append("")
    lines.append(
        "| Workload | Case | N | Batch | ThreadsField | Profile | Avg Fwd ms | Avg Fwd SP GFLOPS | "
        "Avg Bwd ms | Avg Bwd SP GFLOPS | Fwd % Peak | Bwd % Peak | Avg Mem MB | Avg Slots | "
        "Avg Work MB | Samples | Checks | Quality | Note |"
    )
    lines.append("|---|---|---:|---:|---:|---|---:|---:|---:|---:|---:|---:|---:|---:|---:|---|---|---|---|")
    for row in rows:
        fwd_pct = 100.0 * row["avg_fwd_sp_gflops"] / peak_sp_gflops if peak_sp_gflops > 0 else float("nan")
        bwd_pct = 100.0 * row["avg_bwd_sp_gflops"] / peak_sp_gflops if peak_sp_gflops > 0 else float("nan")
        lines.append(
            f"| {row['workload']} | {row['case']} | {row['length']} | {row['batch']} | {row['threads_field']} | "
            f"{row['profile']} | {fmt_ms(row['avg_fwd_ms'])} | {fmt_float(row['avg_fwd_sp_gflops'])} | "
            f"{fmt_ms(row['avg_bwd_ms'])} | {fmt_float(row['avg_bwd_sp_gflops'])} | {fmt_pct(fwd_pct)} | "
            f"{fmt_pct(bwd_pct)} | {fmt_float(row['avg_mem_mb'])} | {fmt_float(row['avg_stream_slots'], 1)} | "
            f"{fmt_float(row['avg_workarea_mb'])} | {row['samples_ok']}/{row['samples_expected']} "
            f"(skip:{row['samples_skip']}) | {row['check_ok']}/{row['samples_ok']} | {row['quality']} | {row['note']} |"
        )
    lines.append("")
    lines.append(f"- CSV: `{out_md.parent / 'latest_run_avg.csv'}`")

    out_md.write_text("\n".join(lines))


def main() -> None:
    args = parse_args()
    manifest = Path(args.manifest).resolve()
    out_csv = Path(args.out_csv).resolve()
    out_md = Path(args.out_md).resolve()
    gpu_query = parse_gpu_query(Path(args.gpu_query).resolve()) if args.gpu_query else {}

    run_rows = read_manifest(manifest)
    rows, hw_log, profile_rows, config = parse_logs(run_rows)

    cc_major, cc_minor = parse_cc(hw_log.get("compute_cap", ""))
    sm_count = int(hw_log.get("sm_count", "0") or 0)
    cores_per_sm = cuda_cores_per_sm(cc_major, cc_minor) if cc_major >= 0 else 0
    cuda_cores = sm_count * cores_per_sm if sm_count > 0 and cores_per_sm > 0 else 0
    max_sm_clock_mhz = float(gpu_query.get("max_sm_clock_mhz", "0") or 0.0)
    peak_sp_gflops = cuda_cores * 2.0 * (max_sm_clock_mhz / 1000.0) if cuda_cores > 0 and max_sm_clock_mhz > 0 else 0.0

    write_csv(rows, out_csv, peak_sp_gflops)
    write_report(out_md, manifest, run_rows, rows, profile_rows, hw_log, gpu_query, config)
    print(f"Wrote CSV: {out_csv}")
    print(f"Wrote MD : {out_md}")


if __name__ == "__main__":
    main()
