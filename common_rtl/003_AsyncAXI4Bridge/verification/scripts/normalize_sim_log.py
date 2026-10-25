#!/usr/bin/env python3
"""Normalize successful logs and retain complete failing logs for evidence checks."""
import sys
from pathlib import Path

if len(sys.argv) != 3:
    raise SystemExit("usage: normalize_sim_log.py RAW_LOG FINAL_LOG")

raw_path, final_path = map(Path, sys.argv[1:])
lines = raw_path.read_text(encoding="utf-8", errors="replace").splitlines()
pass_line = "assertion failures: 0, assertions never exercised: 0"
pass_index = next((i for i in range(len(lines) - 1, -1, -1) if lines[i].strip() == pass_line), None)
if pass_index is None:
    final_path.write_text("\n".join(lines).rstrip() + "\n", encoding="utf-8", newline="\n")
    print(f"FAIL: retained complete failing log in {final_path.name}; raw log preserved")
    raise SystemExit(0)
kept = lines[:pass_index + 1]
final_path.write_text("\n".join(kept).rstrip() + "\n", encoding="utf-8", newline="\n")
raw_path.unlink(missing_ok=True)
print(f"PASS: normalized {final_path.name}; final line is the R-025 pass line")
