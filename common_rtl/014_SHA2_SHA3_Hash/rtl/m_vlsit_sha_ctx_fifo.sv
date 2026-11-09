/*
 * Project      : VLSIT Common RTL library
 * Author       : Nguyen Quan and Claude Sonnet 5.5 (user)
 * AI Flow      : VLSIT RTL Generator AI Automation Flow
 * AI Flow Page : https://github.com/nguyenquanicd/VLSIT_RTL_Generator_AI_Model
 * Date         : 2026-11-09
 * Description  : One FIFO for each context, built from the library synchronous FIFO
 *                m_vlsit_sfifo_top with both clocks tied to i_clk_core (DEC-015). It serves as
 *                the input FIFO (message words) and as the output FIFO (digest words); the two
 *                uses are two instances of this module. One push and one pop per cycle can
 *                address different contexts. The pop data is the show-ahead word of the FIFO
 *                of the pop context. A clear request of a context is the software reset of its
 *                FIFO (pointers only, the memory is not overwritten, DEC-021). The level of the
 *                context addressed by i_lvl_ctx is counted here.
 *                Decisions: DEC-015, DEC-021.
 */
`timescale 1ns/1ps

module m_vlsit_sha_ctx_fifo #(
  // Parameter Description: number of contexts, one FIFO each.
  // Parameter values: 1 to 16; default is 1.
  // Parameter unit: count
  parameter logic [31:0] PARA_CTX_N = 1,
  // Parameter Description: depth of each FIFO.
  // Parameter values: power of 2 from 4 to 1024; default is 64.
  // Parameter unit: word
  parameter logic [31:0] PARA_FIFO_DEPTH = 64,
  // Parameter Description: width of a word.
  // Parameter values: 32, 64 or 128; default is 64.
  // Parameter unit: bit
  parameter logic [31:0] PARA_FIFO_W = 64,
  localparam logic [31:0] LPARA_CTX_W = (PARA_CTX_N > 1) ? $clog2(PARA_CTX_N) : 1,
  localparam logic [31:0] LPARA_LVL_W = $clog2(PARA_FIFO_DEPTH + 1)
) (
  // Clock and reset
  input  wire                    i_clk_core,
  input  wire                    i_rst_n_core,

  // Push port
  input  wire                    i_push_en,
  input  wire  [LPARA_CTX_W-1:0] i_push_ctx,
  input  wire  [PARA_FIFO_W-1:0] i_push_data,
  output logic [PARA_CTX_N-1:0]  o_full,

  // Pop port
  input  wire                    i_pop_en,
  input  wire  [LPARA_CTX_W-1:0] i_pop_ctx,
  output logic [PARA_FIFO_W-1:0] o_pop_data,
  output logic [PARA_CTX_N-1:0]  o_empty,

  // Clear request of each context (one cycle) and level of the selected context
  input  wire  [PARA_CTX_N-1:0]  i_clr_ctx,
  input  wire  [LPARA_CTX_W-1:0] i_lvl_ctx,
  output logic [15:0]            o_lvl
);

  // Internal signal declarations
  logic [PARA_CTX_N-1:0]  w_wr_en;
  logic [PARA_CTX_N-1:0]  w_rd_en;
  logic [PARA_CTX_N-1:0]  w_rst_n_sw;
  logic [PARA_CTX_N-1:0]  w_push_ok;
  logic [PARA_CTX_N-1:0]  w_pop_ok;
  logic [PARA_FIFO_W-1:0] w_rd_data [0:PARA_CTX_N-1];
  logic [PARA_CTX_N-1:0][LPARA_LVL_W-1:0] reg_lvl;
  logic [PARA_CTX_N-1:0][LPARA_LVL_W-1:0] w_lvl_nxt;

  // Request decode: the push and pop enables of the FIFO of the addressed context and the
  // accepted push and pop of each context (not full, not empty).
  always_comb begin : p_com_dec
    w_wr_en = '0;
    w_rd_en = '0;
    for (int idx = 0; idx < PARA_CTX_N; idx++) begin
      w_wr_en[idx] = i_push_en && (i_push_ctx == LPARA_CTX_W'(idx));
      w_rd_en[idx] = i_pop_en && (i_pop_ctx == LPARA_CTX_W'(idx));
    end
    w_push_ok = w_wr_en & ~o_full;
    w_pop_ok  = w_rd_en & ~o_empty;
    w_rst_n_sw = ~i_clr_ctx;
  end

  // Pop data: the word of the pop context; an address beyond the last context reads context 0.
  always_comb begin : p_com_pop
    o_pop_data = w_rd_data[0];
    for (int idx = 0; idx < PARA_CTX_N; idx++) begin
      if (i_pop_ctx == LPARA_CTX_W'(idx))
        o_pop_data = w_rd_data[idx];
    end
  end

  // Level counter of each context: plus one for an accepted push, minus one for an accepted pop,
  // zero after a clear request. The level of the context i_lvl_ctx is the output.
  always_comb begin : p_com_lvl
    o_lvl = 16'h0000;
    w_lvl_nxt = '0;
    for (int idx = 0; idx < PARA_CTX_N; idx++) begin
      w_lvl_nxt[idx] = reg_lvl[idx];
      casez ({i_clr_ctx[idx], w_push_ok[idx], w_pop_ok[idx]})
        3'b1??:  w_lvl_nxt[idx] = '0;
        3'b010:  w_lvl_nxt[idx] = reg_lvl[idx] + 1'b1;
        3'b001:  w_lvl_nxt[idx] = reg_lvl[idx] - 1'b1;
        default: w_lvl_nxt[idx] = reg_lvl[idx];
      endcase
      if (i_lvl_ctx == LPARA_CTX_W'(idx))
        o_lvl = 16'(reg_lvl[idx]);
    end
  end

  // Level registers: control state, reset to empty.
  always_ff @(posedge i_clk_core, negedge i_rst_n_core) begin : p_ff_lvl
    if (!i_rst_n_core)
      reg_lvl <= '0;
    else
      reg_lvl <= w_lvl_nxt;
  end

  // One library FIFO for each context. The overflow, underflow and threshold flags are not used;
  // the software reset request is the clear request of the context.
  for (genvar gen_idx = 0; gen_idx < PARA_CTX_N; gen_idx++) begin : gen_fifo
    m_vlsit_sfifo_top #(
      .PARA_SFIFO_DEPTH         (PARA_FIFO_DEPTH),
      .PARA_SFIFO_DATA_W        (PARA_FIFO_W),
      .PARA_SFIFO_PTR_RETIME    (32'd0),
      .PARA_SFIFO_MEM_USE_MACRO (32'd0)
    ) u_fifo (
      .i_clk_wr      (i_clk_core),
      .i_rst_n_wr    (i_rst_n_core),
      .i_wr_en       (w_wr_en[gen_idx]),
      .i_wr_data     (i_push_data),
      .i_full_thr    ('0),
      .o_full        (o_full[gen_idx]),
      .o_full_thr    (),
      .o_overflow    (),
      .i_rst_n_sw    (w_rst_n_sw[gen_idx]),
      .o_sw_rst_busy (),
      .i_clk_rd      (i_clk_core),
      .i_rst_n_rd    (i_rst_n_core),
      .i_rd_en       (w_rd_en[gen_idx]),
      .i_empty_thr   ('0),
      .o_rd_data     (w_rd_data[gen_idx]),
      .o_empty       (o_empty[gen_idx]),
      .o_empty_thr   (),
      .o_underflow   ()
    );
  end

endmodule
