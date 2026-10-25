#!/usr/bin/env python3
"""Convert simulation VCD windows to WaveJSON/SVG and index the evidence."""
import json
import re
import subprocess
import sys
from pathlib import Path

HERE = Path(__file__).resolve().parent
VERIFICATION = HERE.parent
PROJECT = VERIFICATION.parent
SPEC = PROJECT / "rtl" / "generation_notes" / "AsyncAXI4Bridge_Resolved_Design_Specification.md"
FIGURES = PROJECT / "waveforms"
EVIDENCE = VERIFICATION / "waveforms_sim"
LOGS = VERIFICATION / "logs"
PYTHON = Path(sys.executable)
CONVERTER = Path(r"C:\Users\PC\.codex\skills\vlsit-wavedrom-waveform\scripts\vlsit_wavedrom_waveform.py")
RENDERER = Path(r"C:\Users\PC\.codex\skills\vlsit-asic-ip-microspec\scripts\vlsit_waveform_svg.py")

WAVES = {
    "WF-001": ("axi_wf001_write_burst", "axi4_base"),
    "WF-002": ("axi_wf002_read_burst", "axi4_base"),
    "WF-003": ("axi_wf003_aw_backpressure", "axi4_base"),
    "WF-004": ("axi_wf004_w_before_aw", "axi4_base"),
    "WF-005": ("axi_wf005_r_backpressure", "axi4_base"),
    "WF-006": ("axi_wf006_error_response", "axi4_base"),
    "WF-007": ("axi_wf007_user_signals", "axi4_user"),
    "WF-008": ("axi_wf008_axi3_mode", "axi3"),
    "WF-009": ("axi_wf009_reset_exit", "axi4_base"),
    "WF-010": ("axi_wf010_streaming", "axi4_base"),
    "WF-011": ("axi_wf011_small_depth", "axi4_base_small"),
}


def signal_names(value):
    names = []
    if isinstance(value, dict):
        name = value.get("name")
        if name:
            names.append(str(name))
        for child in value.values():
            names.extend(signal_names(child))
    elif isinstance(value, list):
        for child in value:
            names.extend(signal_names(child))
    return list(dict.fromkeys(names))


def marker_time(log_path: Path, waveform_id: str, edge: str) -> float:
    text = log_path.read_text(encoding="utf-8", errors="replace")
    pattern = rf"WF-MARK\s+{re.escape(waveform_id)}\s+{edge}_NS=([0-9]+(?:\.[0-9]+)?)"
    match = re.search(pattern, text)
    if not match:
        raise SystemExit(f"ERROR: {log_path.name} has no {waveform_id} {edge} time marker")
    return float(match.group(1))


def main() -> None:
    if not CONVERTER.is_file() or not RENDERER.is_file():
        raise SystemExit("ERROR: required bundled WaveDrom converter/renderer is missing")
    rows = []
    spec_text = SPEC.read_text(encoding="utf-8")
    for waveform_id, (stem, profile) in WAVES.items():
        source_json = FIGURES / f"{stem}.json"
        vcd = EVIDENCE / f"{stem}.vcd"
        log = LOGS / f"wave_{waveform_id.lower().replace('-', '')}.log"
        for path in (source_json, vcd, log):
            if not path.is_file():
                raise SystemExit(f"ERROR: missing waveform input: {path}")
        signals = signal_names(json.loads(source_json.read_text(encoding="utf-8")))
        start = marker_time(log, waveform_id, "START")
        end = marker_time(log, waveform_id, "END")
        if end <= start:
            raise SystemExit(f"ERROR: invalid simulation window for {waveform_id}: {start}..{end} ns")
        out_json = EVIDENCE / f"{stem}.json"
        out_svg = EVIDENCE / f"{stem}.svg"
        subprocess.run([
            str(PYTHON), str(CONVERTER), "vcd-to-wavejson", str(vcd),
            "--signals", ",".join(signals), "--start", f"{start}ns", "--end", f"{end}ns",
            "--out", str(out_json), "--force",
        ], check=True)
        subprocess.run([
            str(PYTHON), str(RENDERER), "render", str(out_json), "--out", str(out_svg), "--force",
        ], check=True)
        rows.append((waveform_id, stem, profile))

    index = [
        "# Simulated waveform evidence / Bằng chứng waveform mô phỏng",
        "",
        "The directed regression runs each listed behavior and records the named port window from its VCD. `NOT-SIMULATED` means no cycle-aligned comparison against the specification drawing is claimed; review the paired files before treating a figure as matched.",
        "",
        "| Waveform ID | Specification figure | Simulated waveform | Result | Note |",
        "|---|---|---|---|---|",
    ]
    for waveform_id, stem, _profile in rows:
        note = "Directed behavior is exercised in the full regression; no cycle-aligned figure comparison is claimed."
        index.append(
            f"| {waveform_id} | `waveforms/{stem}.svg` | `waveforms_sim/{stem}.svg` | NOT-SIMULATED | {note} |"
        )
    (EVIDENCE / "waveform_compare.md").write_text("\n".join(index) + "\n", encoding="utf-8", newline="\n")
    print(f"PASS: generated {len(rows)} simulation VCD, WaveJSON and SVG artifacts")


if __name__ == "__main__":
    main()
