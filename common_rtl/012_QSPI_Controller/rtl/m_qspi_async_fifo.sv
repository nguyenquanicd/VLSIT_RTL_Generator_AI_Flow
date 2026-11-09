/*
 * Project      : QSPI_Controller
 * Author       : Nguyen Quan (user)
 * AI Flow      : VLSIT RTL Generator AI Automation Flow
 * AI Flow Page : https://github.com/nguyenquanicd/VLSIT_RTL_Generator_AI_Model
 * Date         : 2026-11-02
 * Description  : Parameterized dual-clock FIFO wrapper reused for TX, RX and CDC payload queues.
 *                The underlying Gray FIFO is supplied by common_rtl.
 */
`timescale 1ns/1ps

module m_qspi_async_fifo #(
  // Parameter Description: queue depth; must be a power of two and at least 2.
  // Parameter values: power of two, 2 or greater; default is 16.
  // Parameter unit: count
  parameter logic [31:0] PARA_FIFO_DEPTH = 32'd16,
  // Parameter Description: width of one FIFO entry.
  // Parameter values: 1 or greater; default is 32.
  // Parameter unit: bit
  parameter logic [31:0] PARA_FIFO_DATA_W = 32'd32,
  localparam logic [31:0] LPARA_AFIFO_SYNC_CELL = 32'd2,
  localparam logic [31:0] LPARA_AFIFO_MEM_ARRAY = 32'd0
) (
  // Write clock and reset
  input  wire                         i_clk_wr,
  input  wire                         i_rst_n_wr,

  // FIFO write interface
  input  wire                         i_wr_en,
  input  wire  [PARA_FIFO_DATA_W-1:0] i_wr_data,
  output logic                        o_full,
  output logic                        o_overflow,

  // Read clock and reset
  input  wire                         i_clk_rd,
  input  wire                         i_rst_n_rd,

  // FIFO read interface
  input  wire                         i_rd_en,
  output logic [PARA_FIFO_DATA_W-1:0] o_rd_data,
  output logic                        o_empty,
  output logic                        o_underflow
);

  // The FIFO reset is tied inactive because top-level reset clears both pointer domains.
  m_vlsit_afifo_top #(
    .PARA_AFIFO_DEPTH        (PARA_FIFO_DEPTH),
    .PARA_AFIFO_DATA_W       (PARA_FIFO_DATA_W),
    .PARA_AFIFO_CELL_TYPE    (LPARA_AFIFO_SYNC_CELL),
    .PARA_AFIFO_MEM_USE_MACRO(LPARA_AFIFO_MEM_ARRAY)
  ) u_afifo (
    .i_clk_wr       (i_clk_wr),
    .i_rst_n_wr     (i_rst_n_wr),
    .i_wr_en        (i_wr_en),
    .i_wr_data      (i_wr_data),
    .i_full_thr     ('0),
    .o_full         (o_full),
    .o_full_thr     (),
    .o_overflow     (o_overflow),
    .i_rst_n_sw     (1'b1),
    .o_sw_rst_busy  (),
    .i_clk_rd       (i_clk_rd),
    .i_rst_n_rd     (i_rst_n_rd),
    .i_rd_en        (i_rd_en),
    .i_empty_thr    ('0),
    .o_rd_data      (o_rd_data),
    .o_empty        (o_empty),
    .o_empty_thr    (),
    .o_underflow    (o_underflow)
  );

endmodule
