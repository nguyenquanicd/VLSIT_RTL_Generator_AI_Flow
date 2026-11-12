/*
 * Project      : VLSIT Common RTL library
 * Author       : Nguyen Quan and Claude Sonnet 5.5 (user)
 * AI Flow      : VLSIT RTL Generator AI Automation Flow
 * AI Flow Page : https://github.com/nguyenquanicd/VLSIT_RTL_Generator_AI_Model
 * Date         : 2026-11-09
 * Description  : Selected-context glue of the SHA2 and SHA3 hash IP. It reduces the per-context
 *                signals to those of the context chosen by sha_ctrl.ctxsel (level select, push,
 *                pop and beat events and the acceptance flag for the DMA handshake), ORs the two
 *                configuration events, and drives the entropy request low in this revision
 *                (the masked core is stage 2, DEC-018). It keeps the structural top free of logic
 *                (HIE-02).
 *                Decisions: DEC-012, DEC-014, DEC-018.
 */
`timescale 1ns/1ps

module m_vlsit_sha_sel #(
  // Parameter Description: number of contexts.
  // Parameter values: 1 to 16; default is 1.
  // Parameter unit: count
  parameter logic [31:0] PARA_CTX_N = 1,
  localparam logic [31:0] LPARA_CTX_W = (PARA_CTX_N > 1) ? $clog2(PARA_CTX_N) : 1
) (
  // Selected context of the register block
  input  wire  [4:0]             i_ctxsel,
  output logic [LPARA_CTX_W-1:0] o_lvl_ctx,

  // Word events and context acceptance
  input  wire                    i_in_push_en,
  input  wire  [LPARA_CTX_W-1:0] i_in_push_ctx,
  input  wire                    i_out_pop_en,
  input  wire  [LPARA_CTX_W-1:0] i_out_pop_ctx,
  input  wire                    i_out_beat,
  input  wire  [PARA_CTX_N-1:0]  i_ctx_abs,
  output logic                   o_in_push_sel,
  output logic                   o_out_pop_sel,
  output logic                   o_out_beat_sel,
  output logic                   o_in_abs_sel,

  // Configuration events and entropy request
  input  wire                    i_ev_cfg,
  input  wire                    i_ev_cfg_dma,
  output logic                   o_ev_cfg_all,
  output logic                   o_ent_req
);

  // Select decode: a context number above the last context selects nothing.
  always_comb begin : p_com_sel
    o_lvl_ctx      = i_ctxsel[LPARA_CTX_W-1:0];
    o_in_push_sel  = i_in_push_en && (i_in_push_ctx == i_ctxsel[LPARA_CTX_W-1:0]);
    o_out_pop_sel  = i_out_pop_en && (i_out_pop_ctx == i_ctxsel[LPARA_CTX_W-1:0]);
    o_out_beat_sel = i_out_beat && (i_out_pop_ctx == i_ctxsel[LPARA_CTX_W-1:0]);
    o_in_abs_sel   = 1'b0;
    for (int idx = 0; idx < PARA_CTX_N; idx++) begin
      if (i_ctxsel == 5'(idx))
        o_in_abs_sel = i_ctx_abs[idx];
    end
    o_ev_cfg_all   = i_ev_cfg || i_ev_cfg_dma;
    o_ent_req      = 1'b0;
  end

endmodule
