# 007_AXI2TLUL_Bridge

Specification of a high-performance, low-latency bridge from AMBA AXI4 (Subordinate) to OpenTitan TL-UL (host), one clock, configurable data width, all outputs from flip-flops.

| Item | File |
|---|---|
| Design specification (22 sections, REQ-xxx, 19 waveforms) | `AXI2TLUL_Bridge_Design_Specification.md` |
| Block diagram (draw.io, SVG, diagram spec) | `figures/vlsit_block_diagram.*` |
| Waveforms (WaveJSON and SVG) | `figures/wf-001` to `figures/wf-018` |
| Reference IP research log and OpenTitan source files with checksums | `research/` |

Status: draft 0.1, no RTL yet. Open points: ASM-001 to ASM-016 (author's choices to confirm) and TBD-001 (frequency and PPA targets), Section 20 of the specification.
