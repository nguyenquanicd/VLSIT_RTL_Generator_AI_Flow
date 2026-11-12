# Static checks (TEST-023, TEST-024)

## TEST-023 clock structure

| Clock net in an always_ff | Files |
|---|---|
| `i_clk_apb` | m_vlsit_csr_sha.sv |
| `i_clk_core` | m_vlsit_sha_axi_sub.sv, m_vlsit_sha_core256.sv, m_vlsit_sha_core512.sv, m_vlsit_sha_ctx_fifo.sv, m_vlsit_sha_ctxmem.sv, m_vlsit_sha_dma.sv, m_vlsit_sha_fault.sv, m_vlsit_sha_irq.sv, m_vlsit_sha_keccak.sv, m_vlsit_sha_keccak_dom.sv, m_vlsit_sha_outp.sv, m_vlsit_sha_prng.sv, m_vlsit_sha_seq.sv |
| `i_clk_reg` | m_vlsit_csr_sha.sv |
| `w_clk_reg` | m_vlsit_csr_sha.sv |

Clock nets chosen between two clock ports by an elaboration parameter (generated CSR, constant after elaboration): w_clk_reg.
Clock nets that are not an input clock port and not such a selection: none.
Clock gating cell instances found: none.
Result: PASS (structure only; scan insertion not run)

## TEST-024 SDC of section 17

Ports named by the SDC: i_clk_apb, i_clk_core, i_protect_en, i_slverr_en. Clocks created: CLK_APB, CLK_CORE.

Ports of the SDC missing in the top module: none.
Clocks used but not created: none.
Clock ports of the top without create_clock: none.
Result: PASS (names only; the SDC was not loaded into an STA tool)
