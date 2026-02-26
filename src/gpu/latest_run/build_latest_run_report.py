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
    fwd_ms_sum: float = 0.0
    bwd_ms_sum: float = 0.0
    mem_sum: float = 0.0
    skip_mem_sum: float = 0.0
    skip_reason: str = ""


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="Build GPU latest_run average CSV + report")
    parser.add_argument("--manifest", required=True, help="manifest.tsv path")
    parser.add_argument("--out-csv", required=True, help="output average CSV")
    parser.add_argument("--out-md", required=True, help="output markdown report")
    parser.add_argument("--gpu-query", default=None, help="nvidia_smi_query.csv path")
    return parser.parse_args()


def read_manifest(path: Path) -> List[Tuple[str, Path, Path]]:
    if not path.is_file():
        raise FileNotFoundError(f"Manifest not found: {path}")

    text = path.read_text(errors="replace").splitlines()
    if not text:
        raise ValueError(f"Manifest is empty: {path}")
    delim = "\t" if "\t" in text[0] else "|"
    out: List[Tuple[str, Path, Path]] = []
    with path.open(newline="") as f:
        reader = csv.DictReader(f, delimiter=delim)
        for row in reader:
            run_id = (row.get("run_id") or row.get("run_index") or "").strip()
            log_path = (row.get("log_path") or row.get("log") or "").strip()
            report_path = (row.get("report_path") or row.get("report") or "").strip()
            if not run_id or not log_path:
                continue
            lp = Path(log_path)
            rp = Path(report_path) if report_path else Path("")
            out.append((run_id, lp, rp))
    if not out:
        raise ValueError(f"No run rows in manifest: {path}")
    return out


def parse_cc(s: str) -> Tuple[int, int]:
    try:
        major, minor = s.strip().split(".", 1)
        return int(major), int(minor)
    except Exception:
        return (-1, -1)


def cuda_cores_per_sm(major: int, minor: int) -> int:
    # NVIDIA architecture mapping (common generations).
    if major == 2:
        return 48 if minor == 1 else 32
    if major == 3:
        return 192
    if major == 5:
        return 128
    if major == 6:
        if minor == 0:
            return 64
        return 128
    if major == 7:
        return 64
    if major == 8:
        if minor == 0:
            return 64
        return 128
    if major == 9:
        return 128
    return 0


def parse_gpu_query(path: Path) -> Dict[str, str]:
    if not path or not path.is_file():
        return {}
    line = path.read_text(errors="replace").strip().splitlines()
    if not line:
        return {}
    parts = [p.strip() for p in line[0].split(",")]
    keys = ["name", "driver_version", "max_sm_clock_mhz", "max_graphics_clock_mhz", "memory_total_mib"]
    out: Dict[str, str] = {}
    for i, k in enumerate(keys):
        if i < len(parts):
            out[k] = parts[i]
    return out


def workload_rank(workload: str) -> int:
    if workload == "throughput":
        return 1
    if workload == "batch_scaling":
        return 2
    return 9


def fft_flops_1d(n: int, batch: int) -> float:
    return 5.0 * float(n) * math.log2(float(n)) * float(batch)


def parse_logs(run_rows: List[Tuple[str, Path, Path]]) -> Tuple[List[Dict], Dict[str, str], List[Dict]]:
    # key=(profile, workload, case, n, batch, threads)
    agg: Dict[Tuple[str, str, str, int, int, int], RowAgg] = defaultdict(RowAgg)
    profile_meta: Dict[str, Dict[str, str]] = {}
    hw: Dict[str, str] = {}

    for run_id, log_path, _ in run_rows:
        if not log_path.is_file():
            raise FileNotFoundError(f"Log not found: {log_path}")
        for raw in log_path.read_text(errors="replace").splitlines():
            line = raw.strip()
            if line.startswith("gpu_name         :"):
                hw["gpu_name"] = line.split(":", 1)[1].strip()
            elif line.startswith("compute_cap      :"):
                hw["compute_cap"] = line.split(":", 1)[1].strip()
            elif line.startswith("sm_count         :"):
                hw["sm_count"] = line.split(":", 1)[1].strip()
            elif line.startswith("warp_size        :"):
                hw["warp_size"] = line.split(":", 1)[1].strip()
            elif line.startswith("max_threads_sm   :"):
                hw["max_threads_sm"] = line.split(":", 1)[1].strip()
            elif line.startswith("max_threads_blk  :"):
                hw["max_threads_blk"] = line.split(":", 1)[1].strip()
            elif line.startswith("global_mem_mb    :"):
                hw["global_mem_mb"] = line.split(":", 1)[1].strip()

            if raw.startswith("PROFILE|"):
                p = raw.split("|")
                if len(p) >= 10:
                    profile_meta[p[1]] = {
                        "profile_desc": p[2],
                        "workload": p[5],
                        "timing_mode": p[8],
                    }
                continue

            if raw.startswith("RESULT|"):
                p = raw.split("|")
                if len(p) < 14:
                    continue
                key = (p[1], p[2], p[3], int(p[4]), int(p[7]), int(p[8]))
                rec = agg[key]
                rec.ok_count += 1
                rec.fwd_ms_sum += float(p[9])
                rec.bwd_ms_sum += float(p[11])
                rec.mem_sum += float(p[13])
                continue

            if raw.startswith("SKIP|"):
                p = raw.split("|")
                if len(p) < 11:
                    continue
                key = (p[1], p[2], p[3], int(p[4]), int(p[7]), int(p[8]))
                rec = agg[key]
                rec.skip_count += 1
                rec.skip_mem_sum += float(p[9])
                rec.skip_reason = p[10]
                continue

    run_count_expected = len(run_rows)
    rows: List[Dict] = []
    for key, rec in agg.items():
        profile, workload, case_id, n, batch, threads = key
        ok = rec.ok_count
        skip = rec.skip_count
        if ok > 0:
            fwd_ms = rec.fwd_ms_sum / ok
            bwd_ms = rec.bwd_ms_sum / ok
            mem_mb = rec.mem_sum / ok
            flops = fft_flops_1d(n, batch)
            fwd_gf = flops / (fwd_ms * 1.0e6) if fwd_ms > 0.0 else float("nan")
            bwd_gf = flops / (bwd_ms * 1.0e6) if bwd_ms > 0.0 else float("nan")
            note = "-"
        else:
            fwd_ms = float("nan")
            bwd_ms = float("nan")
            mem_mb = rec.skip_mem_sum / skip if skip > 0 else float("nan")
            fwd_gf = float("nan")
            bwd_gf = float("nan")
            note = rec.skip_reason or "skip"
        quality = "ok" if (ok + skip) == run_count_expected else "incomplete"

        rows.append(
            {
                "workload": workload,
                "case": case_id,
                "length": n,
                "batch": batch,
                "threads_field": threads,
                "profile": profile,
                "timing_mode": profile_meta.get(profile, {}).get("timing_mode", "unknown"),
                "avg_fwd_ms": fwd_ms,
                "avg_fwd_sp_gflops": fwd_gf,
                "avg_bwd_ms": bwd_ms,
                "avg_bwd_sp_gflops": bwd_gf,
                "avg_mem_mb": mem_mb,
                "samples_ok": ok,
                "samples_skip": skip,
                "samples_expected": run_count_expected,
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

    profile_rows: List[Dict] = []
    for pid in sorted(profile_meta):
        m = profile_meta[pid]
        profile_rows.append(
            {
                "profile": pid,
                "description": m.get("profile_desc", ""),
                "workload": m.get("workload", ""),
                "timing_mode": m.get("timing_mode", ""),
            }
        )
    return rows, hw, profile_rows


def write_csv(rows: List[Dict], out_csv: Path, peak_gflops: float) -> None:
    out_csv.parent.mkdir(parents=True, exist_ok=True)
    fields = [
        "workload",
        "case",
        "length",
        "batch",
        "threads_field",
        "profile",
        "timing_mode",
        "avg_fwd_ms",
        "avg_fwd_sp_gflops",
        "avg_bwd_ms",
        "avg_bwd_sp_gflops",
        "avg_mem_mb",
        "fwd_pct_of_peak",
        "bwd_pct_of_peak",
        "samples_ok",
        "samples_skip",
        "samples_expected",
        "quality",
        "note",
    ]

    with out_csv.open("w", newline="") as f:
        w = csv.DictWriter(f, fieldnames=fields)
        w.writeheader()
        for r in rows:
            rr = dict(r)
            if math.isfinite(rr["avg_fwd_sp_gflops"]) and peak_gflops > 0:
                rr["fwd_pct_of_peak"] = 100.0 * rr["avg_fwd_sp_gflops"] / peak_gflops
            else:
                rr["fwd_pct_of_peak"] = float("nan")
            if math.isfinite(rr["avg_bwd_sp_gflops"]) and peak_gflops > 0:
                rr["bwd_pct_of_peak"] = 100.0 * rr["avg_bwd_sp_gflops"] / peak_gflops
            else:
                rr["bwd_pct_of_peak"] = float("nan")
            w.writerow(rr)


def _fmt_ms(v: float) -> str:
    if not math.isfinite(v):
        return "-"
    if v >= 0.1:
        return f"{v:.3f}"
    if v >= 0.01:
        return f"{v:.4f}"
    return f"{v:.6f}"


def _fmt_gf(v: float) -> str:
    if not math.isfinite(v):
        return "-"
    return f"{v:.2f}"


def _fmt_pct(v: float) -> str:
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
) -> None:
    out_md.parent.mkdir(parents=True, exist_ok=True)

    cc_major, cc_minor = parse_cc(hw_log.get("compute_cap", ""))
    cores_per_sm = cuda_cores_per_sm(cc_major, cc_minor) if cc_major >= 0 else 0
    sm_count = int(hw_log.get("sm_count", "0") or 0)
    max_threads_sm = int(hw_log.get("max_threads_sm", "0") or 0)
    max_threads_blk = int(hw_log.get("max_threads_blk", "0") or 0)
    warp_size = int(hw_log.get("warp_size", "0") or 0)
    cuda_cores = sm_count * cores_per_sm if sm_count > 0 and cores_per_sm > 0 else 0
    resident_threads = sm_count * max_threads_sm if sm_count > 0 and max_threads_sm > 0 else 0

    max_sm_clock_mhz = float(gpu_query.get("max_sm_clock_mhz", "0") or 0.0)
    peak_sp_gflops = cuda_cores * 2.0 * (max_sm_clock_mhz / 1000.0) if cuda_cores > 0 and max_sm_clock_mhz > 0 else 0.0

    valid_rows = [r for r in rows if math.isfinite(r["avg_fwd_sp_gflops"]) and math.isfinite(r["avg_bwd_sp_gflops"])]
    if valid_rows and peak_sp_gflops > 0:
        best_fwd = max(valid_rows, key=lambda r: r["avg_fwd_sp_gflops"])
        best_bwd = max(valid_rows, key=lambda r: r["avg_bwd_sp_gflops"])
        best_fwd_pct = 100.0 * best_fwd["avg_fwd_sp_gflops"] / peak_sp_gflops
        best_bwd_pct = 100.0 * best_bwd["avg_bwd_sp_gflops"] / peak_sp_gflops
    else:
        best_fwd = None
        best_bwd = None
        best_fwd_pct = float("nan")
        best_bwd_pct = float("nan")

    lines: List[str] = []
    lines.append("# GPU FFT Latest Run (1D, wide batch sweep)")
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
    lines.append(f"- Total CUDA cores (SM x cores/SM): {cuda_cores if cuda_cores else 'unknown'}")
    lines.append(f"- Warp size: {warp_size if warp_size else 'unknown'}")
    lines.append(f"- Max threads/SM (resident): {max_threads_sm if max_threads_sm else 'unknown'}")
    lines.append(f"- Max threads/block: {max_threads_blk if max_threads_blk else 'unknown'}")
    lines.append(f"- Max resident threads on device (SM x max threads/SM): {resident_threads if resident_threads else 'unknown'}")
    lines.append(f"- Reported global memory: {hw_log.get('global_mem_mb', gpu_query.get('memory_total_mib', 'unknown'))} MB")
    lines.append("")

    lines.append("## Peak GFLOPS (SP)")
    lines.append("")
    lines.append("- Formula: `peak_sp_gflops = cuda_cores * 2 FLOP/cycle * max_sm_clock_ghz`")
    lines.append(f"- Max SM clock from nvidia-smi: {max_sm_clock_mhz:.0f} MHz")
    lines.append(f"- Estimated theoretical SP peak: {peak_sp_gflops:.2f} GFLOPS")
    lines.append("- Percent-of-peak columns in this report use this theoretical peak denominator.")
    lines.append("")

    lines.append("## 1D FFT Benchmark Design")
    lines.append("")
    lines.append("- cuFFT path: `cufftPlanMany` + `cufftExecC2C` forward/backward.")
    lines.append("- Timing mode from profile metadata (`compute` or `e2e`).")
    lines.append("- FLOP model: `5 * N * log2(N) * batch`.")
    lines.append("- Wide sweep expected by this run: `N=32..4194304`, `batch=1..65536` (power-of-two list).")
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
    lines.append("| Profile | Description | Workload | Timing Mode |")
    lines.append("|---|---|---|---|")
    for r in profile_rows:
        lines.append(f"| {r['profile']} | {r['description']} | {r['workload']} | {r['timing_mode']} |")
    lines.append("")

    lines.append("## Summary Stats")
    lines.append("")
    status_counts = Counter(r["quality"] for r in rows)
    lines.append(f"- Rows aggregated: {len(rows)}")
    lines.append(f"- Quality counts: {dict(status_counts)}")
    if best_fwd:
        lines.append(
            f"- Best forward: `{best_fwd['case']}` ({best_fwd['profile']}) = "
            f"{best_fwd['avg_fwd_sp_gflops']:.2f} GFLOPS ({best_fwd_pct:.2f}% peak)"
        )
    if best_bwd:
        lines.append(
            f"- Best backward: `{best_bwd['case']}` ({best_bwd['profile']}) = "
            f"{best_bwd['avg_bwd_sp_gflops']:.2f} GFLOPS ({best_bwd_pct:.2f}% peak)"
        )
    lines.append("")

    lines.append("## Averaged Results")
    lines.append("")
    lines.append(
        "| Workload | Case | N | Batch | ThreadsField | Profile | Timing | "
        "Avg Fwd ms | Avg Fwd SP GFLOPS | Avg Bwd ms | Avg Bwd SP GFLOPS | "
        "Fwd % Peak | Bwd % Peak | Avg Mem MB | Samples | Quality | Note |"
    )
    lines.append("|---|---|---:|---:|---:|---|---|---:|---:|---:|---:|---:|---:|---:|---|---|---|")
    for r in rows:
        if peak_sp_gflops > 0 and math.isfinite(r["avg_fwd_sp_gflops"]):
            fwd_pct = 100.0 * r["avg_fwd_sp_gflops"] / peak_sp_gflops
        else:
            fwd_pct = float("nan")
        if peak_sp_gflops > 0 and math.isfinite(r["avg_bwd_sp_gflops"]):
            bwd_pct = 100.0 * r["avg_bwd_sp_gflops"] / peak_sp_gflops
        else:
            bwd_pct = float("nan")
        lines.append(
            f"| {r['workload']} | {r['case']} | {r['length']} | {r['batch']} | {r['threads_field']} | "
            f"{r['profile']} | {r['timing_mode']} | {_fmt_ms(r['avg_fwd_ms'])} | {_fmt_gf(r['avg_fwd_sp_gflops'])} | "
            f"{_fmt_ms(r['avg_bwd_ms'])} | {_fmt_gf(r['avg_bwd_sp_gflops'])} | {_fmt_pct(fwd_pct)} | {_fmt_pct(bwd_pct)} | "
            f"{r['avg_mem_mb']:.2f} | {r['samples_ok']}/{r['samples_expected']} | {r['quality']} | {r['note']} |"
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
    rows, hw_log, profile_rows = parse_logs(run_rows)

    cc_major, cc_minor = parse_cc(hw_log.get("compute_cap", ""))
    sm_count = int(hw_log.get("sm_count", "0") or 0)
    cores_per_sm = cuda_cores_per_sm(cc_major, cc_minor) if cc_major >= 0 else 0
    cuda_cores = sm_count * cores_per_sm if sm_count > 0 and cores_per_sm > 0 else 0
    max_sm_clock_mhz = float(gpu_query.get("max_sm_clock_mhz", "0") or 0.0)
    peak_sp_gflops = cuda_cores * 2.0 * (max_sm_clock_mhz / 1000.0) if cuda_cores > 0 and max_sm_clock_mhz > 0 else 0.0

    write_csv(rows, out_csv, peak_sp_gflops)
    write_report(out_md, manifest, run_rows, rows, profile_rows, hw_log, gpu_query)
    print(f"Wrote CSV: {out_csv}")
    print(f"Wrote MD : {out_md}")


if __name__ == "__main__":
    main()
