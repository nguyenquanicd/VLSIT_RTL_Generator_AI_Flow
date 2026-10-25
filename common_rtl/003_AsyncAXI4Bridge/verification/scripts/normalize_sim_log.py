#!/usr/bin/env python3
"""Remove simulator shutdown banners so the R-025 pass line is the log's last line."""
import sys
from pathlib import Path

if len(sys.argv) != 3:
    raise SystemExit("usage: normalize_sim_log.py RAW_LOG FINAL_LOG")

raw_path, final_path = map(Path, sys.argv[1:])
lines = raw_path.read_text(encoding="utf-8", errors="replace").splitlines()
kept = [
    line for line in lines
    if "Verilog $finish" not in line
    and "Simulation Report:" not in line
    and "Verilator: $finish at" not in line
]
pass_line = "assertion failures: 0, assertions never exercised: 0"
if pass_line not in kept:
    raise SystemExit(f"ERROR: simulator log does not contain {pass_line!r}")
final_path.write_text("\n".join(kept).rstrip() + "\n", encoding="utf-8", newline="\n")
raw_path.unlink(missing_ok=True)
print(f"PASS: normalized {final_path.name}; final line is the R-025 pass line")
