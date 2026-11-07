/*
 * Project      : Timer IP
 * Author       : Nguyen Quan (user)
 * AI Flow      : VLSIT RTL Generator AI Automation Flow
 * AI Flow Page : https://github.com/nguyenquanicd/VLSIT_RTL_Generator_AI_Model
 * Date         : 2026-11-03
 * Description  : Four-record FIFO wrapper for atomic tagged DMA records. It reuses the common
 *                synchronous FIFO and exposes occupancy plus sticky overflow status.
 */
`timescale 1ns/1ps

module m_vlsit_timer_record_fifo #(
  // Parameter Description: total record width stored in one FIFO entry.
  // Parameter values: 1 or more; default is 96.
  // Parameter unit: bit
  parameter logic [31:0] PARA_DATA_WIDTH = 96,
  localparam logic [31:0] LPARA_DEPTH = 32'd4,
  localparam logic [31:0] LPARA_OCC_W = 32'd3
) (
  // Timer clock and reset
  input  wire                        i_clk_timer,
  input  wire                        i_rst_n_timer,

  // Record write and read interfaces
  input  wire                        i_push,
  input  wire  [PARA_DATA_WIDTH-1:0] i_push_data,
  input  wire                        i_pop,
  output logic [PARA_DATA_WIDTH-1:0] o_head_data,
  output logic                       o_valid,
  output logic                       o_full,
  output logic [LPARA_OCC_W-1:0]     o_level,

  // DMA flush control
  input  wire                        i_flush_clear,
  output logic                       o_flush_busy,

  // Sticky overflow clear and status
  input  wire                        i_clear_overflow,
  output logic                       o_overflow,
  output logic                       o_overflow_event
);

  // FIFO controls and occupancy state
  logic w_fifo_full;
  logic w_fifo_empty;
  logic w_push_accept;
  logic w_pop_accept;
  logic w_fifo_rst_n_sw;
  logic reg_overflow;
  logic [LPARA_OCC_W-1:0] reg_level;

  // Never overwrite an older record when the queue is full.
  assign w_push_accept = i_push & ~w_fifo_full;
  assign w_pop_accept  = i_pop & ~w_fifo_empty;
  assign o_valid       = ~w_fifo_empty;
  assign o_full        = w_fifo_full;
  assign o_level       = reg_level;
  assign o_overflow    = reg_overflow;
  assign o_overflow_event = i_push & w_fifo_full;
  assign w_fifo_rst_n_sw = i_rst_n_timer & ~i_flush_clear;

  // Common FIFO storage and pointers implement the four-entry show-ahead queue.
  m_vlsit_sfifo_top #(
    .PARA_SFIFO_DEPTH         (LPARA_DEPTH),
    .PARA_SFIFO_DATA_W        (PARA_DATA_WIDTH),
    .PARA_SFIFO_PTR_RETIME    (32'd0),
    .PARA_SFIFO_MEM_USE_MACRO (32'd0)
  ) u_record_fifo (
    .i_clk_wr       (i_clk_timer),
    .i_rst_n_wr     (i_rst_n_timer),
    .i_wr_en        (w_push_accept),
    .i_wr_data      (i_push_data),
    .i_full_thr     (LPARA_OCC_W'(LPARA_DEPTH)),
    .o_full         (w_fifo_full),
    .o_full_thr     (),
    .o_overflow     (),
    .i_rst_n_sw     (w_fifo_rst_n_sw),
    .o_sw_rst_busy  (o_flush_busy),
    .i_clk_rd       (i_clk_timer),
    .i_rst_n_rd     (i_rst_n_timer),
    .i_rd_en        (w_pop_accept),
    .i_empty_thr    (LPARA_OCC_W'(1)),
    .o_rd_data      (o_head_data),
    .o_empty        (w_fifo_empty),
    .o_empty_thr    (),
    .o_underflow    ()
  );

  // Occupancy and overflow status follow accepted operations; a new overflow wins over W1C.
  always_ff @(posedge i_clk_timer, negedge i_rst_n_timer) begin : p_ff_fifo_status
    if (!i_rst_n_timer) begin
      reg_level    <= '0;
      reg_overflow <= 1'b0;
    end else if (i_flush_clear) begin
      reg_level    <= '0;
      reg_overflow <= (reg_overflow & ~i_clear_overflow) | (i_push & w_fifo_full);
    end else begin
      case ({w_push_accept, w_pop_accept})
        2'b10: reg_level <= reg_level + 1'b1;
        2'b01: reg_level <= reg_level - 1'b1;
        default: reg_level <= reg_level;
      endcase
      reg_overflow <= (reg_overflow & ~i_clear_overflow) | (i_push & w_fifo_full);
    end
  end

endmodule
