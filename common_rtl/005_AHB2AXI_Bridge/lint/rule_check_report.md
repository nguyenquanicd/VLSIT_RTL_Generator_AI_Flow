# RTL rule check

Files: m_ahb2axi_ahb_if.sv, m_ahb2axi_axi_if.sv, m_ahb2axi_ctrl.sv, m_ahb2axi_top.sv

| Level | Rule | File:line | Finding |
|---|---|---|---|
| WARN | HIE-02 | m_ahb2axi_ctrl.sv:12 | module has instances and also logic; a structural top should contain instances only (HIE-02) |
| WARN | PAR-03 | m_ahb2axi_ctrl.sv:313 | literal 110 may be a magic number (P10); name it with a parameter, localparam or enum member |

Rules failed: none
Rules warned: HIE-02, PAR-03
Rules clean: ARI-04, CMT-01, CMT-05, COM-02, COM-03, COM-04, COM-06, COM-07, ENM-01, ENM-03, ENM-04, ENM-05, ENM-06, FIL-01, FIL-02, FIL-03, FIL-04, FIL-05, FIL-06, HIE-01, HIE-03, HIE-05, NAM-07, NAM-08, NAM-09, NAM-TBL, P1, P11, P12, P13, P14, P17, P18, P19, P2, P20, P21, P22, P24, P25, P26, P27, P29, P3, P30, P4, P6, P7, PAR-01, PAR-02, R-019, R-027, R-032, R-035, R-036, SCP-01, SEC-8.1, SEQ-01, TYP-02, TYP-06
