"""Inject one fault into a copy and require the self-checking test to detect it."""
from pathlib import Path
import argparse
import subprocess
import sys


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--verilator", default="verilator")
    parser.add_argument("--cxx", default="g++")
    parser.add_argument("--verilator-root", required=True)
    args = parser.parse_args()
    root = Path(__file__).resolve().parents[1]
    build = root / "sanity" / "build" / "mutation"
    build.mkdir(parents=True, exist_ok=True)
    original = root / "rtl" / "m_crc_parallel.sv"
    mutant = build / "m_crc_parallel_mutant.sv"
    src = original.read_text(encoding="utf-8")
    correct = "assign o_crc_seq = reg_crc_seq;"
    if src.count(correct) != 1:
        print("ERROR: expected output assignment was not found exactly once")
        return 2
    mutant.write_text(src.replace(correct, "assign o_crc_seq = '0;", 1),
                      encoding="utf-8", newline="\n")
    cmd = [sys.executable, "tests/run_verilator_sim.py", "tb_crc_parallel",
           "m_crc_parallel", "--seed", "20261025", "--random-count", "0",
           "--verilator", args.verilator, "--cxx", args.cxx,
           "--verilator-root", args.verilator_root,
           "--rtl-file", str(mutant.relative_to(root)),
           "--expect-fail", "--log-name", "mutation_check"]
    run = subprocess.run(cmd, cwd=root, capture_output=True, text=True)
    print(run.stdout, end="")
    if run.stderr:
        print(run.stderr, end="", file=sys.stderr)
    return run.returncode


if __name__ == "__main__":
    sys.exit(main())
