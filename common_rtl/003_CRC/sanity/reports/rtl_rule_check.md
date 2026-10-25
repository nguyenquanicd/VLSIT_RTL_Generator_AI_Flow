# RTL rule check

Files: m_crc_initial_value.sv, m_crc_parallel.sv, m_crc_parallel_crcw.sv, m_crc_parallel_full.sv, m_crc_serial.sv

| Level | Rule | File:line | Finding |
|---|---|---|---|
| WARN | PAR-03 | m_crc_parallel_full.sv:71 | literal 8 may be a magic number (P10); name it with a parameter, localparam or enum member |
| WARN | PAR-03 | m_crc_parallel_full.sv:73 | literal 8 may be a magic number (P10); name it with a parameter, localparam or enum member |
| WARN | PAR-03 | m_crc_parallel_full.sv:75 | literal 8 may be a magic number (P10); name it with a parameter, localparam or enum member |
| WARN | PAR-03 | m_crc_parallel_full.sv:77 | literal 8 may be a magic number (P10); name it with a parameter, localparam or enum member |
| WARN | PAR-03 | m_crc_parallel_full.sv:79 | literal 8 may be a magic number (P10); name it with a parameter, localparam or enum member |
| WARN | PAR-03 | m_crc_parallel_full.sv:81 | literal 8 may be a magic number (P10); name it with a parameter, localparam or enum member |
| WARN | PAR-03 | m_crc_parallel_full.sv:83 | literal 8 may be a magic number (P10); name it with a parameter, localparam or enum member |
| WARN | PAR-03 | m_crc_parallel_full.sv:85 | literal 8 may be a magic number (P10); name it with a parameter, localparam or enum member |
| WARN | R-027 | m_crc_initial_value.sv:36 | lines 36-41: simulation-only branch of `VLSIT_SYNTHESIS` is excluded from the RTL rules (spec DEC-021 and REQ-RTL-002, rule R-027): it is never synthesized, so the design rules were NOT checked in these lines; it is covered by simulation only |
| WARN | R-027 | m_crc_parallel.sv:35 | lines 35-40: simulation-only branch of `VLSIT_SYNTHESIS` is excluded from the RTL rules (spec DEC-021 and REQ-RTL-002, rule R-027): it is never synthesized, so the design rules were NOT checked in these lines; it is covered by simulation only |
| WARN | R-027 | m_crc_parallel_crcw.sv:42 | lines 42-51: simulation-only branch of `VLSIT_SYNTHESIS` is excluded from the RTL rules (spec DEC-021 and REQ-RTL-002, rule R-027): it is never synthesized, so the design rules were NOT checked in these lines; it is covered by simulation only |
| WARN | R-027 | m_crc_parallel_full.sv:41 | lines 41-48: simulation-only branch of `VLSIT_SYNTHESIS` is excluded from the RTL rules (spec DEC-021 and REQ-RTL-002, rule R-027): it is never synthesized, so the design rules were NOT checked in these lines; it is covered by simulation only |

Rules failed: none
Rules warned: PAR-03, R-027
Rules clean: ARI-04, CMT-01, CMT-05, COM-02, COM-03, COM-04, COM-06, COM-07, ENM-01, ENM-03, ENM-04, ENM-05, FIL-01, FIL-02, FIL-03, FIL-04, FIL-05, FIL-06, HIE-01, HIE-02, HIE-03, HIE-05, NAM-07, NAM-08, NAM-09, NAM-TBL, P1, P11, P12, P13, P14, P17, P18, P19, P2, P20, P21, P22, P24, P25, P26, P27, P29, P3, P4, P6, P7, PAR-01, PAR-02, R-019, R-032, SCP-01, SEC-8.1, SEQ-01, TYP-02
