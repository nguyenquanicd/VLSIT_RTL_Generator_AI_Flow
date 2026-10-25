# QA and decision log

- **2026-10-25 — Naming:** User selected VLSIT RTL Design Rules v2 at ../../spec_template/VLSIT_RTL_Design_Rule.md.
- **2026-10-25 — Protocols:** Full AXI4 Subordinate using IHI 0022 Issue H.c to APB4 Manager using IHI 0024 Issue D; APB4 signal profile.
- **2026-10-25 — Architecture:** One shared clock, 32-bit address/data, one APB port, external decoder, one global transaction and round-robin AR/AW selection.
- **2026-10-25 — AXI profile:** FIXED/INCR/WRAP; full legal AXI4 burst lengths; 1/2/4-byte transfers; ID width 1–16, default 4; IDs echo.
- **2026-10-25 — Mapping:** PSTRB and PPROT included; AxPROT maps directly to PPROT; AxCACHE accepts only 0000/0001; no AxLOCK/exclusive traffic or USER/QOS/REGION.
- **2026-10-25 — Errors:** APB read errors map to per-beat RRESP=SLVERR; write errors aggregate to final BRESP while remaining beats continue. Unmapped addresses require external default error Completer (PREADY=1, PSLVERR=1).
- **2026-10-25 — Reset and policy:** Shared active-low synchronous reset supplied by the SoC; no internal synchronizer; no APB timeout; no CSR. Unsupported address requests complete with SLVERR without APB access; malformed AXI writes are outside the guaranteed profile.
- **2026-10-25 — AXI exclusive clarification:** AXI4 H.c requires a subordinate without exclusive support to ignore AxLOCK and return OKAY if AxLOCK exists. The approved profile omits AxLOCK and requires the system not to issue exclusive traffic.
- **2026-10-25 — Waveforms:** User approved all 14 R-024 scenarios. SVG diagrams and paired WaveJSON source files are stored under `figures/` and linked from Sections 6.3 and 10.3.
- **2026-10-25 — RTL hierarchy and diagram:** User requested a clear diagram where every module block maps to an RTL module, then directed merging `m_axi2apb_arb` into `m_axi2apb_apb_ctrl`. The planned hierarchy is `m_axi2apb_bridge` plus `m_axi2apb_rd_seq`, `m_axi2apb_wr_seq`, and `m_axi2apb_apb_ctrl`; the latter owns round-robin arbitration and APB control.
- **2026-10-25 — Library inventory:** User requested analysis of the available `common_rtl` library. No Liberty, DB or LEF target was found. `000_Common/rtl_cells` contains stand-in RTL cell models and `000_Common/rtl_lib` contains wrappers. This bridge needs no wrapper or stand-in because its single-clock reset is synchronous and it has no memory macro; physical library/corner mapping remains with SoC PPA.
- **2026-10-25 — RTL frontend:** User selected portable synthesizable IEEE 1800-2017 RTL under VLSIT RTL Design Rules v2; exact frontend/options remain a SoC integration choice.
- **2026-10-25 — Lint:** User selected VLSIT v2 checks and available Verilator/slang lint with no project-specific waivers.
- **2026-10-25 — Reset contract:** User directed a single synchronous clock domain with no internal synchronizer. The bridge reset is active-low and synchronous to `i_clk_axi`; the SoC supplies the synchronized reset and coordinates it with both bus endpoints. User confirmed `RDATA=0` for APB read `SLVERR`.
- **2026-10-25 — RTL output path:** User selected `common_rtl/006_AXI2APB_Bridge/rtl` for the generated modules and filelist.
- **2026-10-25 — Malformed AXI writes:** User selected the legal-Manager assumption. The RTL does not define recovery for WLAST/AWLEN or WSTRB violations; AXI-compliant traffic remains required.
- **Open items:** Clock/performance targets, PPA targets, DFT contract, system threat/safety policy, address map, and exact tool versions remain documented in Section 20. Malformed WLAST/WSTRB recovery is out of profile by DEC-017.
