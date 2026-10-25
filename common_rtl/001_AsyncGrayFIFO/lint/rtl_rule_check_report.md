# RTL rule check

Files: m_vlsit_afifo_mem.sv, m_vlsit_afifo_rd.sv, m_vlsit_afifo_sync.sv, m_vlsit_afifo_top.sv, m_vlsit_afifo_wr.sv, m_vlsit_afifo_cell_sync.sv, m_vlsit_afifo_ram_macro.sv

| Level | Rule | File:line | Finding |
|---|---|---|---|
| WARN | HIE-02 | m_vlsit_afifo_cell_sync.sv:21 | module has instances and also logic; a structural top should contain instances only (HIE-02) |
| WARN | HIE-02 | m_vlsit_afifo_mem.sv:16 | module has instances and also logic; a structural top should contain instances only (HIE-02) |
| WARN | HIE-02 | m_vlsit_afifo_rd.sv:17 | module has instances and also logic; a structural top should contain instances only (HIE-02) |
| WARN | HIE-02 | m_vlsit_afifo_wr.sv:17 | module has instances and also logic; a structural top should contain instances only (HIE-02) |
| WARN | R-027 | m_vlsit_afifo_cell_sync.sv:87 | lines 87-183: simulation-only branch of `VLSIT_SYNTHESIS` is excluded from the RTL rules (spec DEC-021 and REQ-RTL-002, rule R-027): it is never synthesized, so the design rules were NOT checked in these lines; it is covered by simulation only |

Rules failed: none
Rules warned: HIE-02, R-027
Rules clean: ARI-04, CMT-01, CMT-05, COM-02, COM-03, COM-04, COM-06, COM-07, ENM-01, ENM-03, ENM-04, ENM-05, FIL-01, FIL-02, FIL-03, FIL-04, FIL-05, FIL-06, HIE-01, HIE-03, HIE-05, NAM-07, NAM-08, NAM-09, NAM-TBL, P1, P11, P12, P13, P14, P17, P18, P19, P2, P20, P21, P22, P24, P25, P26, P27, P29, P3, P4, P6, P7, PAR-01, PAR-02, PAR-03, R-019, SCP-01, SEC-8.1, SEQ-01, TYP-02
