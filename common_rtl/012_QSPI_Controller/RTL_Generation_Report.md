# QSPI RTL Generation Report

**Top module:** `m_qspi`  
**Specification:** `VLSIT_QSPI_CONTROLLER_HDS.md`  
**Status:** RTL is assembled and elaborated. The redundant global format field is reserved in the CSR workbook. The refreshed CSR output was generated into `rtl_v2/` with APB-CSR-Generator v3.3; the earlier `rtl/` set remains available as a baseline.

## Implemented structure

- APB4 CSR and custom TX/RX FIFO windows, including the target first-word holding register.
- AXI4 subordinate, read-only XIP path with parameterized address/data/ID widths, up to 16 INCR beats by default, and one outstanding burst.
- Standard SPI controller and target roles; Dual, Quad and QPI 4-4-4 controller formats.
- Separate target RX sample-edge and TX shift-edge clocks. Target frame configuration is captured while CS is inactive; target reset release is synchronized to APB.
- Controller/target FIFO pairs, AXI-to-serial request mailbox, serial-to-AXI response FIFO, round-robin XIP/indirect arbitration, and event CDC through shared `m_vlsit_event_sync`; `m_qspi_event_sync` is a compatibility wrapper.
- AXI XIP requests are rejected with SLVERR when XIP or controller enable is off, target role is selected, the transfer profile is unsupported, the address is misaligned/out of range, or `ARLOCK=1`. XIP writes return SLVERR and do not issue a flash command.
- Target partial-word status is synchronized into APB before setting its sticky error.

The refreshed RTL consists of 19 project modules plus generated CSR RTL. `rtl_v2/filelist.f` contains 47 source files including reused `common_rtl` dependencies. The shared event synchronizer carries request/acknowledge state; QSPI keeps only a compatibility wrapper.

## Checks run

| Check | Result |
|---|---|
| `vlsit_rtl_check.py check .` | PASS; `rtl_v2/`, 21 files, 0 errors, 19 warnings |
| `vlsit_rtl_check.py coverage` | 64 script checks, 6 lint checks, 15 manual checks listed |
| Verilator top lint | PASS; top `m_qspi`, 47 files, 0 errors, 51 warnings; log `rtl_v2/lint_verilator_event_sync_2.log` |
| CSR generator manifest verification | PASS for refreshed `rtl_v2/`; generator v3.3, workbook hash matches, 14 registers and 74 ports. Earlier v2.4 output remains under `rtl/`. |
| Simulation | Not run; no testbench was requested |

The latest refreshed Verilator output is in `rtl_v2/lint_verilator_event_sync_2.log`; the earlier `rtl_v2/lint_verilator.log` is retained as historical evidence, and the previous baseline log remains under `lint/`.

The CSR workbook SHA-256 is `7ee61d2ef046c9070e31cbf03d9ea212afb02fcde741b61bb2185a9d88684678`; it matches the refreshed v3.3 manifest under `rtl_v2/csr/`. The earlier v2.4 manifest under `rtl/csr/` is preserved. Generated files are not hand-edited.

The refreshed lint has no width warnings, missing-pin warnings, or errors. Its 51 warnings comprise 13 intentionally open AFIFO status pins, 12 blocking assignments, 5 unused parameters, 1 COMBDLY warning in a reused latch model, and 20 unused signals. The unused signals include read-only XIP payload/attributes and fields excluded by the selected profile. There are no inferred-latch, multiple-driver, or combinational-loop findings in this run.

## Rule review

- **Clean by script:** naming/port/type conventions, FSM structure, reset style, explicit named connections, combinational defaults, generated CSR integrity, and the mechanically checked RTL rules. No NAM-08 warning remains.
- **HIE-02 justified:** `m_qspi.sv` is a structural top with explicit wiring assignments. Shared `m_vlsit_event_sync.sv` combines synchronizer-cell instances with request/acknowledge state as one CDC primitive; `m_qspi_event_sync.sv` is structural, while `m_qspi_toggle_sync.sv` remains QSPI-specific.
- **CDC structure inspected:** payload crossings use the AFIFO/mailbox; event crossings use request/acknowledge synchronizers; target partial status uses two APB synchronizer stages. Multi-bit configuration synchronizers rely on their documented source-stability/program-before-use constraint.
- **Clock review:** target sample/shift selectors are latched while CS is inactive. The bundled `VLSIT_CELL_CKMUX2` model is a functional mux model, not evidence that a specific foundry clock-mux cell is glitch-free. Integration must map it to an approved clock mux or enforce stable idle SCLK during configuration, then constrain both generated clocks in STA.
- **Not established:** simulation, formal checks, CDC/RDC tool signoff, gate-level clock-mux characterization, timing closure, maximum SCLK, PPA, and flash-specific electrical timing. The SoC and target flash constraints remain inputs to those signoffs.

## CSR lane-format policy

Lane format is selected by transaction class. `qspi_cmd.format` configures each indirect flash command, and `qspi_xip_cfg.format` configures XIP reads. The unused `qspi_ctrl.format` range is reserved as read-as-zero/write-ignored, so firmware cannot accidentally program a global format that the datapath ignores. The workbook is the CSR source of truth; `m_vlsit_csr_qspi.sv` was regenerated from it.

## Reproducible commands

Run these commands from the `rtl_v2` directory:

```powershell
python C:\Users\PC\.codex\skills\vlsit-rtl-generator\scripts\vlsit_rtl_check.py check .
python C:\Users\PC\.codex\skills\vlsit-rtl-generator\scripts\vlsit_rtl_check.py coverage
python C:\Users\PC\.codex\skills\vlsit-rtl-generator\scripts\vlsit_lint_rtl.py lint filelist.f --top m_qspi --log lint_verilator_event_sync_2.log
python C:\Users\PC\.codex\skills\vlsit-rtl-generator\scripts\vlsit_csr_generate.py verify csr
```
