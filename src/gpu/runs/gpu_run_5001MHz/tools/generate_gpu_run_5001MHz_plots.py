#!/usr/bin/env python3
from __future__ import annotations

import argparse
import subprocess
from pathlib import Path


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="Generate plots for gpu_run_5001MHz")
    parser.add_argument("--session-dir", required=True, help="session directory")
    return parser.parse_args()


def main() -> None:
    args = parse_args()
    script_dir = Path(__file__).resolve().parent
    plot_script = script_dir / "plot_gpu_run_5001MHz.py"
    plot_python = script_dir.parent.parent.parent / "plots" / ".venv" / "bin" / "python"
    if not plot_python.is_file():
        plot_python = Path("python3")

    subprocess.run(
        [
            str(plot_python),
            str(plot_script),
            "--session-dir",
            str(Path(args.session_dir).resolve()),
        ],
        check=True,
    )


if __name__ == "__main__":
    main()
