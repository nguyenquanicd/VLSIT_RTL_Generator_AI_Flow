/*
 * Project      : VLSIT Common RTL library
 * Author       : Nguyen Quan and Claude Sonnet 5.5 (user)
 * AI Flow      : VLSIT RTL Generator AI Automation Flow
 * AI Flow Page : https://github.com/nguyenquanicd/VLSIT_RTL_Generator_AI_Model
 * Date         : 2026-11-10
 * Description  : Fault detection and response of the SHA2 and SHA3 hash IP (stage 2a, REQ-SEC-002).
 *                Duplicate-core detection compares the result of each built core with the result of
 *                its duplicate when the core reports done; recompute detection compares the result
 *                of the second run of a block with the stored result of the first run; parity
 *                detection takes the parity error flags of the cores, the context memory and the
 *                FIFOs. The compare result of the done cycle (o_mismatch) is combinational so that
 *                the sequencer does not store the result of a faulty block. The mismatch is
 *                registered; the registered fault event raises the fault interrupt and, one cycle
 *                later, the responses of sha_sec.resp are active: bit 0 gate the digest words,
 *                bit 1 lock the IP, bit 2 clear all contexts, bit 3 alarm. Gate and lock stay until
 *                the soft reset command.
 *                Decisions: DEC-033, DEC-034, DEC-035.
 */
`timescale 1ns/1ps

module m_vlsit_sha_fault #(
  // Parameter Description: SHA-224 and SHA-256 core is built.
  // Parameter values: 0 or 1; default is 1.
  // Parameter unit: flag
  parameter logic [31:0] PARA_EN_256 = 1,
  // Parameter Description: SHA-384, SHA-512 and SHA-512/t core is built.
  // Parameter values: 0 or 1; default is 0.
  // Parameter unit: flag
  parameter logic [31:0] PARA_EN_512 = 0,
  // Parameter Description: Keccak core is built.
  // Parameter values: 0 or 1; default is 0.
  // Parameter unit: flag
  parameter logic [31:0] PARA_EN_KEC = 0,
  // Parameter Description: width of the result of the sequencer (largest core state).
  // Parameter values: 256, 512 or 1600; default is 256.
  // Parameter unit: bits
  parameter logic [31:0] PARA_STW = 256,
  // Parameter Description: width of the Keccak result: 1600, or 3200 with the masked core.
  // Parameter values: 1600 or 3200; default is 1600.
  // Parameter unit: bits
  parameter logic [31:0] PARA_KECW = 1600,
  // Parameter Description: duplicate-core detection is built (the duplicates are in the top).
  // Parameter values: 0 or 1; default is 0.
  // Parameter unit: flag
  parameter logic [31:0] PARA_DUP = 0,
  // Parameter Description: parity detection is built.
  // Parameter values: 0 or 1; default is 0.
  // Parameter unit: flag
  parameter logic [31:0] PARA_PAR = 0,
  // Parameter Description: recompute detection is built.
  // Parameter values: 0 or 1; default is 0.
  // Parameter unit: flag
  parameter logic [31:0] PARA_REDO = 0,
  // Parameter Description: the alarm output is built.
  // Parameter values: 0 or 1; default is 0.
  // Parameter unit: flag
  parameter logic [31:0] PARA_ALARM = 0,
  localparam logic [31:0] LPARA_ANY = PARA_DUP | PARA_PAR | PARA_REDO
) (
  // Clock and reset
  input  wire                  i_clk_core,
  input  wire                  i_rst_n_core,
  input  wire                  i_srst,

  // Fields of the register sha_sec
  input  wire                  i_sec_fault,
  input  wire                  i_sec_fdup,
  input  wire                  i_sec_fpar,
  input  wire                  i_sec_fredo,
  input  wire  [3:0]           i_sec_resp,

  // Cores and their duplicates (the duplicate inputs are 0 when no duplicate is built)
  input  wire                  i_c256_done,
  input  wire  [255:0]         i_c256_res,
  input  wire                  i_c256_done_b,
  input  wire  [255:0]         i_c256_res_b,
  input  wire                  i_c512_done,
  input  wire  [511:0]         i_c512_res,
  input  wire                  i_c512_done_b,
  input  wire  [511:0]         i_c512_res_b,
  input  wire                  i_kec_done,
  input  wire  [PARA_KECW-1:0] i_kec_res,
  input  wire                  i_kec_done_b,
  input  wire  [PARA_KECW-1:0] i_kec_res_b,

  // Recompute: the result of the block that ends in this cycle and the pass it belongs to
  input  wire                  i_be_done,
  input  wire  [PARA_STW-1:0]  i_be_res,
  input  wire                  i_pass_first,
  input  wire                  i_pass_second,

  // Parity error flags (level or pulse) of the cores, the context memory and the FIFOs
  input  wire                  i_par_err,

  // Result of the compare in the done cycle, events and responses
  output logic                 o_mismatch,
  output logic                 o_ev_flt,
  output logic                 o_lock,
  output logic                 o_gate,
  output logic                 o_wipe,
  output logic                 o_alarm_set,
  output logic                 o_redo_en
);

  logic                 w_mm_dup;
  logic                 w_mm_redo;
  logic                 w_par_hit;
  logic                 w_fault_now;
  logic                 reg_flt;
  logic                 reg_lock;
  logic                 reg_gate;
  logic [PARA_STW-1:0]  reg_first;
  logic [3199:0]        w_be_ext;
  logic [3199:0]        w_first_ext;

  // Duplicate compare: the core and its duplicate shall report done in the same cycle with the same
  // result; a different done cycle or a different result is a mismatch.
  always_comb begin : p_com_dup
    w_mm_dup = 1'b0;
    if (PARA_DUP != 32'd0) begin
      if (PARA_EN_256 != 32'd0)
        w_mm_dup = w_mm_dup || (i_c256_done != i_c256_done_b) || (i_c256_done && (i_c256_res != i_c256_res_b));
      if (PARA_EN_512 != 32'd0)
        w_mm_dup = w_mm_dup || (i_c512_done != i_c512_done_b) || (i_c512_done && (i_c512_res != i_c512_res_b));
      if (PARA_EN_KEC != 32'd0)
        w_mm_dup = w_mm_dup || (i_kec_done != i_kec_done_b) || (i_kec_done && (i_kec_res != i_kec_res_b));
      w_mm_dup = w_mm_dup && i_sec_fault && i_sec_fdup;
    end
  end

  // Recompute compare: the second run of a block gives the same result as the first run.
  always_comb begin : p_com_redo
    w_mm_redo = 1'b0;
    w_be_ext    = '0;
    w_first_ext = '0;
    if (PARA_REDO != 32'd0) begin
      // The two runs use different random bits, so the shares of a masked result differ; the xor of
      // the two shares (the plain value; no register holds it) is compared (DEC-036).
      w_be_ext    = 3200'(i_be_res);
      w_first_ext = 3200'(reg_first);
      w_mm_redo = i_sec_fault && i_sec_fredo && i_be_done && i_pass_second
               && ((w_be_ext[1599:0] ^ w_be_ext[3199:1600]) != (w_first_ext[1599:0] ^ w_first_ext[3199:1600]));
    end
  end

  // Parity flags and the fault of this cycle.
  always_comb begin : p_com_flt
    w_par_hit   = (PARA_PAR != 32'd0) && i_sec_fault && i_sec_fpar && i_par_err;
    w_fault_now = w_mm_dup || w_mm_redo || w_par_hit;
    o_mismatch  = w_mm_dup || w_mm_redo;
  end

  // Registered fault, the lock and gate flags (they stay until the soft reset command) and the
  // stored result of the first run of a block.
  always_ff @(posedge i_clk_core, negedge i_rst_n_core) begin : p_ff_flt
    if (!i_rst_n_core) begin
      reg_flt  <= 1'b0;
      reg_lock <= 1'b0;
      reg_gate <= 1'b0;
    end else begin
      reg_flt  <= w_fault_now && !i_srst;
      if (i_srst) begin
        reg_lock <= 1'b0;
        reg_gate <= 1'b0;
      end else if (reg_flt) begin
        reg_lock <= reg_lock || i_sec_resp[1];
        reg_gate <= reg_gate || i_sec_resp[0];
      end
    end
  end

  always_ff @(posedge i_clk_core) begin : p_ff_first
    if (i_be_done && i_pass_first)
      reg_first <= i_be_res;
  end

  // Outputs: the event is the registered fault; the responses follow the register sha_sec.resp.
  always_comb begin : p_com_out
    o_ev_flt    = (LPARA_ANY != 32'd0) && reg_flt;
    o_lock      = reg_lock;
    o_gate      = reg_gate;
    o_wipe      = reg_flt && i_sec_resp[2];
    o_alarm_set = reg_flt && i_sec_resp[3] && (PARA_ALARM != 32'd0);
    o_redo_en   = (PARA_REDO != 32'd0) && i_sec_fault && i_sec_fredo;
  end

endmodule
