#!/usr/bin/env python3
from __future__ import annotations

import argparse
import subprocess
from pathlib import Path


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="Generate plots for run_gpu_cache_noreuse")
    parser.add_argument("--session-dir", required=True, help="session directory")
    return parser.parse_args()


def main() -> None:
    args = parse_args()
    script_dir = Path(__file__).resolve().parent
    common_script = script_dir.parent.parent / "common" / "generate_gpu_run_plots.py"
    plot_python = script_dir.parent.parent.parent / "plots" / ".venv" / "bin" / "python"
    if not plot_python.is_file():
        plot_python = Path("python3")
    subprocess.run(
        [
            str(plot_python),
            str(common_script),
            "--session-dir",
            str(Path(args.session_dir).resolve()),
            "--family-id",
            "run_gpu_cache_noreuse",
            "--expected-lengths",
            "2,4,8,16,32,64,128,256,512,1024,2048,4096,8192,16384,32768,65536",
            "--expected-batches",
            "1,10,16,150,256,1024",
        ],
        check=True,
    )


if __name__ == "__main__":
    main()
