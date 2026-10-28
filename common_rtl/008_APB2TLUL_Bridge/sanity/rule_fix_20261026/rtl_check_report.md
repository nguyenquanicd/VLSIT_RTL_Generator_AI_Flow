# RTL rule check

Files: m_apb_if.sv, m_apb_tlul_bridge.sv, m_tlul_if.sv

| Level | Rule | File:line | Finding |
|---|---|---|---|
| WARN | NAM-08 | m_apb_tlul_bridge.sv:59 | port 'o_tlul_a_source' spells out 'source'; NAM-08 writes 'src' |
| WARN | NAM-08 | m_apb_tlul_bridge.sv:60 | port 'o_tlul_a_address' spells out 'address'; NAM-08 writes 'addr' |
| WARN | NAM-08 | m_apb_tlul_bridge.sv:68 | port 'i_tlul_d_error' spells out 'error'; NAM-08 writes 'err' |
| WARN | NAM-08 | m_apb_tlul_bridge.sv:72 | port 'i_tlul_d_source' spells out 'source'; NAM-08 writes 'src' |
| WARN | NAM-08 | m_tlul_if.sv:51 | port 'o_tlul_a_source' spells out 'source'; NAM-08 writes 'src' |
| WARN | NAM-08 | m_tlul_if.sv:52 | port 'o_tlul_a_address' spells out 'address'; NAM-08 writes 'addr' |
| WARN | NAM-08 | m_tlul_if.sv:60 | port 'i_tlul_d_error' spells out 'error'; NAM-08 writes 'err' |
| WARN | NAM-08 | m_tlul_if.sv:62 | port 'i_tlul_d_source' spells out 'source'; NAM-08 writes 'src' |

Rules failed: none
Rules warned: NAM-08
Rules clean: ARI-04, CMT-01, CMT-05, COM-02, COM-03, COM-04, COM-06, COM-07, ENM-01, ENM-03, ENM-04, ENM-05, ENM-06, FIL-01, FIL-02, FIL-03, FIL-04, FIL-05, FIL-06, HIE-01, HIE-02, HIE-03, HIE-05, NAM-07, NAM-09, NAM-TBL, P1, P11, P12, P13, P14, P17, P18, P19, P2, P20, P21, P22, P24, P25, P26, P27, P29, P3, P30, P4, P6, P7, PAR-01, PAR-02, PAR-03, R-019, R-027, R-032, R-035, R-036, SCP-01, SEC-8.1, SEQ-01, TYP-02, TYP-06
