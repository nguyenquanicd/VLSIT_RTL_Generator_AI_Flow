/*
 * Project      : Timer IP
 * Author       : Nguyen Quan (user)
 * AI Flow      : VLSIT RTL Generator AI Automation Flow
 * AI Flow Page : https://github.com/nguyenquanicd/VLSIT_RTL_Generator_AI_Model
 * Date         : 2026-11-03
 * Description  : Four-entry capture FIFO wrapper that retains old timestamps and drops a new
 *                capture on full, while reporting a sticky overrun. Implements REQ-CAP-004/005.
 */
`timescale 1ns/1ps

module m_vlsit_timer_capture_fifo #(
  // Parameter Description: counter timestamp width plus one stored edge-polarity bit.
  // Parameter values: 33 or 65; default is 33.
  // Parameter unit: bit
  parameter logic [31:0] PARA_DATA_W = 33,
  localparam logic [31:0] LPARA_DEPTH = 32'd4,
  localparam logic [31:0] LPARA_OCC_W = 32'd3
) (
  // Timer clock and reset
  input  wire                    i_clk_timer,
  input  wire                    i_rst_n_timer,

  // Capture write and CPU/DMA drain
  input  wire                    i_push,
  input  wire  [PARA_DATA_W-1:0] i_data,
  input  wire                    i_pop,
  output logic [PARA_DATA_W-1:0] o_data,
  output logic                   o_valid,
  output logic                   o_full,
  output logic [LPARA_OCC_W-1:0] o_level,

  // DMA flush control
  input  wire                    i_flush_clear,
  output logic                   o_flush_busy,

  // Sticky overrun status
  input  wire                    i_clear_overrun,
  output logic                   o_overrun,
  output logic                   o_overflow_event
);

  // Internal signal declarations
  logic w_fifo_full;
  logic w_fifo_empty;
  logic w_fifo_wr_en;
  logic w_fifo_rd_en;
  logic w_fifo_rst_n_sw;
  logic w_push_accept;
  logic w_pop_accept;
  logic w_overflow_event;
  logic [LPARA_OCC_W-1:0] reg_level;
  logic reg_overrun;

  // FIFO acceptance is restricted so a full FIFO always keeps the four oldest timestamps.
  assign w_push_accept    = i_push & ~w_fifo_full;
  assign w_pop_accept     = i_pop & ~w_fifo_empty;
  assign w_fifo_wr_en     = w_push_accept;
  assign w_fifo_rd_en     = w_pop_accept;
  assign w_fifo_rst_n_sw  = i_rst_n_timer & ~i_flush_clear;
  assign w_overflow_event = i_push & w_fifo_full;
  assign o_valid          = ~w_fifo_empty;
  assign o_full           = w_fifo_full;
  assign o_level          = reg_level;
  assign o_overrun        = reg_overrun;
  assign o_overflow_event = w_overflow_event;

  // Reuse the approved synchronous FIFO implementation; the wrapper owns overrun policy.
  m_vlsit_sfifo_top #(
    .PARA_SFIFO_DEPTH  (LPARA_DEPTH),
    .PARA_SFIFO_DATA_W (PARA_DATA_W),
    .PARA_SFIFO_PTR_RETIME (32'd0),
    .PARA_SFIFO_MEM_USE_MACRO (32'd0)
  ) u_capture_fifo (
    .i_clk_wr       (i_clk_timer),
    .i_rst_n_wr     (i_rst_n_timer),
    .i_wr_en        (w_fifo_wr_en),
    .i_wr_data      (i_data),
    .i_full_thr     (LPARA_OCC_W'(LPARA_DEPTH)),
    .o_full         (w_fifo_full),
    .o_full_thr     (),
    .o_overflow     (),
    .i_rst_n_sw     (w_fifo_rst_n_sw),
    .o_sw_rst_busy  (o_flush_busy),
    .i_clk_rd       (i_clk_timer),
    .i_rst_n_rd     (i_rst_n_timer),
    .i_rd_en        (w_fifo_rd_en),
    .i_empty_thr    (LPARA_OCC_W'(1)),
    .o_rd_data      (o_data),
    .o_empty        (w_fifo_empty),
    .o_empty_thr    (),
    .o_underflow    ()
  );

  // Occupancy tracks accepted writes and reads; simultaneous transfer leaves the count unchanged.
  always_ff @(posedge i_clk_timer, negedge i_rst_n_timer) begin : p_ff_level
    if (!i_rst_n_timer) begin
      reg_level <= '0;
      reg_overrun <= 1'b0;
    end else if (i_flush_clear) begin
      reg_level <= '0;
      reg_overrun <= (reg_overrun & ~i_clear_overrun) | w_overflow_event;
    end else begin
      case ({w_push_accept, w_pop_accept})
        2'b10: reg_level <= reg_level + 1'b1;
        2'b01: reg_level <= reg_level - 1'b1;
        default: reg_level <= reg_level;
      endcase
      reg_overrun <= (reg_overrun & ~i_clear_overrun) | w_overflow_event;
    end
  end

endmodule
