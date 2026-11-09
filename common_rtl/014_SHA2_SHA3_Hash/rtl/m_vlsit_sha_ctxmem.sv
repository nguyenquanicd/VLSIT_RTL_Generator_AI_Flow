/*
 * Project      : VLSIT Common RTL library
 * Author       : Nguyen Quan and Claude Sonnet 5.5 (user)
 * AI Flow      : VLSIT RTL Generator AI Automation Flow
 * AI Flow Page : https://github.com/nguyenquanicd/VLSIT_RTL_Generator_AI_Model
 * Date         : 2026-11-09
 * Description  : Context memory: the hash state of each context that is not inside a core, in
 *                flip-flops (DEC-016: PARA_CTX_MEM = 0 only). Two write ports and two read ports.
 *                Port A is the store of a finished block; port B is the initial value, the clear
 *                and the zeroing; if both write the same context in one cycle port A wins. The
 *                storage is resetless (SEQ-04): a state is read only for a context that is not
 *                free, and the initial value is written when the context starts, so no word is
 *                consumed before it is written (7.3, 10.5). Reads are combinational.
 *                Decisions: DEC-005, DEC-016, DEC-021.
 */
`timescale 1ns/1ps

module m_vlsit_sha_ctxmem #(
  // Parameter Description: number of contexts (words of the memory).
  // Parameter values: 1 to 16; default is 1.
  // Parameter unit: count
  parameter logic [31:0] PARA_CTX_N = 1,
  // Parameter Description: width of one state word; 256 for SHA-224 and SHA-256 only, 512 when a
  // SHA-384 or SHA-512 type is built, 1600 when a SHA-3 type is built.
  // Parameter values: 256, 512 or 1600; default is 256.
  // Parameter unit: bit
  parameter logic [31:0] PARA_STW = 256,
  localparam logic [31:0] LPARA_CTX_W = (PARA_CTX_N > 1) ? $clog2(PARA_CTX_N) : 1
) (
  // Clock
  input  wire                    i_clk_core,

  // Write port A: state store of a finished block
  input  wire                    i_wra_en,
  input  wire  [LPARA_CTX_W-1:0] i_wra_ctx,
  input  wire  [PARA_STW-1:0]    i_wra_data,

  // Write port B: initial value, clear and zeroing
  input  wire                    i_wrb_en,
  input  wire  [LPARA_CTX_W-1:0] i_wrb_ctx,
  input  wire  [PARA_STW-1:0]    i_wrb_data,

  // Read port 0: state for a block start
  input  wire  [LPARA_CTX_W-1:0] i_rd0_ctx,
  output logic [PARA_STW-1:0]    o_rd0_data,

  // Read port 1: state for the digest words
  input  wire  [LPARA_CTX_W-1:0] i_rd1_ctx,
  output logic [PARA_STW-1:0]    o_rd1_data
);

  // Internal signal declarations
  logic [PARA_STW-1:0] reg_mem [0:PARA_CTX_N-1];

  // Write of the two ports: one word per port and cycle; port A has priority for the same word.
  always_ff @(posedge i_clk_core) begin : p_ff_mem
    for (int idx = 0; idx < PARA_CTX_N; idx++) begin
      if (i_wra_en && (i_wra_ctx == LPARA_CTX_W'(idx)))
        reg_mem[idx] <= i_wra_data;
      else if (i_wrb_en && (i_wrb_ctx == LPARA_CTX_W'(idx)))
        reg_mem[idx] <= i_wrb_data;
    end
  end

  // Read ports: the state of the context addressed; an address beyond the last context reads
  // context 0 so that the output never depends on an unwritten word of another address.
  always_comb begin : p_com_rd
    o_rd0_data = reg_mem[0];
    o_rd1_data = reg_mem[0];
    for (int idx = 0; idx < PARA_CTX_N; idx++) begin
      if (i_rd0_ctx == LPARA_CTX_W'(idx))
        o_rd0_data = reg_mem[idx];
      if (i_rd1_ctx == LPARA_CTX_W'(idx))
        o_rd1_data = reg_mem[idx];
    end
  end

endmodule
