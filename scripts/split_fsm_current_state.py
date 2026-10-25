#!/usr/bin/env python3
"""Split AXI2APB FSM current-state updates into state-only sequential processes.

Purpose:
  Copy the approved AXI2APB RTL source set to a new output folder and move the
  current-state reset/next-state assignments into dedicated always_ff blocks.

Usage:
  python scripts/split_fsm_current_state.py <source_rtl_dir> <output_rtl_dir>

Inputs:
  source_rtl_dir  Existing RTL source folder. It is read only.
  output_rtl_dir  New or empty destination folder for the copied RTL.

Outputs:
  Four .sv files in output_rtl_dir. The filelist is generated separately by
  vlsit_lint_rtl.py after this transformation.

Exit codes:
  0  Transformation and copy completed.
  2  Invalid input, non-empty output folder, or source text did not match the
     expected FSM assignment pattern. No source RTL is modified.
"""

import argparse
import sys
from pathlib import Path


TRANSFORMS = {
    "m_axi2apb_apb_ctrl.sv": [
        {
            "comment": "  // Register arbitration ownership and the next transaction preference.",
            "state": "reg_fsm_ctrl_current_state",
            "reset": "ENUM_ST_IDLE",
            "next": "w_fsm_ctrl_nxt_state",
            "process": "p_ff_fsm_ctrl",
            "description": "Register the current state of the AXI owner FSM.",
        },
        {
            "comment": "  // Capture APB payload once, hold it through wait states, and pulse its AXI-side response.",
            "state": "reg_fsm_apb_current_state",
            "reset": "ENUM_ST_APB_IDLE",
            "next": "w_fsm_apb_nxt_state",
            "process": "p_ff_fsm_apb",
            "description": "Register the current state of the APB transfer FSM.",
        },
    ],
    "m_axi2apb_rd_seq.sv": [
        {
            "comment": "  // Register the transaction context and advance only after each R handshake.",
            "state": "reg_fsm_rd_current_state",
            "reset": "ENUM_ST_IDLE",
            "next": "w_fsm_rd_nxt_state",
            "process": "p_ff_fsm_rd",
            "description": "Register the current state of the AXI read FSM.",
        },
    ],
    "m_axi2apb_wr_seq.sv": [
        {
            "comment": "  // Register the write context and preserve aggregate error status until B is accepted.",
            "state": "reg_fsm_wr_current_state",
            "reset": "ENUM_ST_IDLE",
            "next": "w_fsm_wr_nxt_state",
            "process": "p_ff_fsm_wr",
            "description": "Register the current state of the AXI write FSM.",
        },
    ],
}


def newline_of(text):
    return "\r\n" if "\r\n" in text else "\n"


def state_block(spec, newline):
    indent = "  "
    return newline.join(
        [
            f"{indent}// {spec['description']}",
            f"{indent}always_ff @(posedge i_clk_axi) begin : {spec['process']}",
            f"{indent}  if (!i_rst_n_axi)",
            f"{indent}    {spec['state']} <= {spec['reset']};",
            f"{indent}  else",
            f"{indent}    {spec['state']} <= {spec['next']};",
            f"{indent}end",
            "",
            "",
        ]
    )


def transform_text(path, text):
    newline = newline_of(text)
    for spec in TRANSFORMS.get(path.name, []):
        reset_assignment = f"      {spec['state']} <= {spec['reset']};"
        next_assignment = f"      {spec['state']} <= {spec['next']};"
        if text.count(reset_assignment) != 1 or text.count(next_assignment) != 1:
            raise ValueError(
                f"{path.name}: expected one reset and one next-state assignment for "
                f"{spec['state']}"
            )
        if text.count(spec["comment"]) != 1:
            raise ValueError(f"{path.name}: expected one insertion marker for {spec['state']}")

        text = text.replace(reset_assignment + newline, "", 1)
        text = text.replace(next_assignment + newline, "", 1)
        text = text.replace(spec["comment"], state_block(spec, newline) + spec["comment"], 1)
    return text


def main():
    parser = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    parser.add_argument("source_rtl_dir", type=Path)
    parser.add_argument("output_rtl_dir", type=Path)
    args = parser.parse_args()

    source = args.source_rtl_dir.resolve()
    output = args.output_rtl_dir.resolve()
    if not source.is_dir():
        print(f"error: source RTL folder does not exist: {source}", file=sys.stderr)
        return 2
    if source == output or source in output.parents:
        print("error: output folder must be outside the source RTL tree", file=sys.stderr)
        return 2
    if output.exists() and (not output.is_dir() or any(output.iterdir())):
        print(f"error: output folder must be new or empty: {output}", file=sys.stderr)
        return 2

    files = sorted(source.glob("*.sv"))
    names = {path.name for path in files}
    required = set(TRANSFORMS) | {"m_axi2apb_bridge.sv"}
    if names != required:
        print(
            "error: expected exactly the four AXI2APB RTL modules; "
            f"found {', '.join(sorted(names))}",
            file=sys.stderr,
        )
        return 2

    try:
        transformed = {}
        for path in files:
            with path.open("r", encoding="utf-8", newline="") as source_file:
                original = source_file.read()
            transformed[path.name] = transform_text(path, original)
    except (OSError, UnicodeError, ValueError) as error:
        print(f"error: {error}", file=sys.stderr)
        return 2

    output.mkdir(parents=True, exist_ok=True)
    try:
        for name, content in transformed.items():
            with (output / name).open("w", encoding="utf-8", newline="") as output_file:
                output_file.write(content)
    except OSError as error:
        print(f"error: could not write output RTL: {error}", file=sys.stderr)
        return 2

    print(f"wrote {len(transformed)} RTL files to {output}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
