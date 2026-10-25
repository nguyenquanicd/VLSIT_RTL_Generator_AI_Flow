# 000_Common: shared library RTL

Library and cell RTL shared by the IPs of `common_rtl`. Any library wrapper, technology cell, or macro model that an IP needs is written in this folder, not in the folder of the IP.

| Folder | Content |
|---|---|
| `rtl_lib` | Wrapper modules that are the only place naming library cells or macros (for example `m_vlsit_afifo_cell_sync`, `m_vlsit_afifo_ram_macro`, `m_vlsit_rst_sync`, `m_vlsit_tie`). Their instances of cells are named `u_dont_touch_<function>`. Each wrapper has a branch with `VLSIT_SYNTHESIS` (instances of cells) and a simulation-only branch (model of the cell behavior) |
| `lib_tests` | Verification of `m_vlsit_rst_sync` and `m_vlsit_tie` in both flows (`tb_rst_sync.sv`, `tb_tie.sv`, `run_lib_tests.py`); not part of the design file set |
| `rtl_cells` | Technology cell models, stand-ins of the real library views: the basic cells `VLSIT_CELL_<FUNCTION>` (rule R-032) and the example cells and macro model `VLSIT_CELL_SYNC_*`, `VLSIT_CELL_SRAM_1W1R`. Module and pin names keep the library style and are exempt from the naming rule |
| `cell_tests` | Verification of the basic cells (not part of the design file set): `tb_cells_comb.sv` (exhaustive truth tables), `tb_cells_seq.sv` (random test of flip-flops, latches and clock gate against a reference model), `run_cell_tests.py` |

Each folder has a `filelist.f` (paths relative to the folder). The IP folders refer to these folders, for example `../../000_Common/rtl_lib` from the `lint` folder of an IP. One module per file, file name equal to the module name.

## Basic cells `VLSIT_CELL_<FUNCTION>` (52 cells)

Synthesizable RTL models, one module per file. A real design uses the cell of the synthesis library, not these models (stated in every header). Pins use the usual library names; an output of an inverting cell is `ZN`, otherwise `Z`.

| Group | Cells |
|---|---|
| Buffer, inverter | `INV` (I, ZN), `BUF` (I, Z) |
| Gates of 2, 3, 4 inputs (A, B, C, D) | `AND2/3/4`, `NAND2/3/4`, `OR2/3/4`, `NOR2/3/4` |
| XOR, XNOR of 2, 3 inputs | `XOR2/3`, `XNOR2/3` |
| Complex gates (A1, A2, B1, B2, B, C) | `AOI21`, `AOI22`, `AOI211`, `OAI21`, `OAI22`, `OAI211`, `AO21`, `AO22`, `OA21`, `OA22` |
| Multiplexers | `MUX2`, `MUXI2` (I0, I1, S), `MUX4` (I0..I3, S0, S1) |
| Adders | `HA` (A, B; S, CO), `FA` (A, B, CI; S, CO) |
| Tie | `TIEH` (Z = 1), `TIEL` (Z = 0) |
| Flip-flops (CK, D, Q) | `DFF`, `DFF_RN` (async reset), `DFF_SN` (async set), `DFF_RSN` (reset has priority), `DFFE` (enable E), `DFFE_RN`, `SDFF` (scan SE, SI), `SDFF_RN`, `DFFN`, `DFFN_RN` (falling edge) |
| Latches | `LAT_H` (transparent at G = 1), `LAT_L` (transparent at G = 0) |
| Clock cells | `CKBUF`, `CKINV`, `CKAND2`, `CKMUX2`, `ICG` (CK, E, TE; Q, latch-based clock gate with test enable) |

Run the tests with `python cell_tests/run_cell_tests.py` (needs `iverilog`/`vvp` on PATH).

## Functional modules of `rtl_lib`

| Module | Function | Parameters |
|---|---|---|
| `m_vlsit_rst_sync` | Reset synchronizer, active-low, asynchronous assertion and synchronous de-assertion, D of the first stage tied to 1 by `VLSIT_CELL_TIEH`. Simulation branch: chain of the same number of stages with the metastability model on the de-assertion (random extra latency of 0, 1 or 2 cycles; plusargs `+RSTSYNC_MSYNC_SEED=<n>`, `+RSTSYNC_MSYNC_EN=<0\|1>`) | `PARA_RST_SYNC_TYPE`: 1 = two `VLSIT_CELL_SYNC_DFF_RN`, 2/3/4 = one `VLSIT_CELL_SYNC_2FF/3FF/4FF_RN` |
| `m_vlsit_tie` | Tie-off of a selectable width and value, one `VLSIT_CELL_TIEH` or `VLSIT_CELL_TIEL` per bit. Simulation branch: constant | `PARA_TIE_WIDTH` (1 to 32), `PARA_TIE_VALUE` |

Run `python lib_tests/run_lib_tests.py` (needs `iverilog`/`vvp` on PATH).
