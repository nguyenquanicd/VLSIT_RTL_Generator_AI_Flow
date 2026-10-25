/*
 * Project      : VLSIT Common RTL library
 * Author       : Nguyen Quan and Claude Sonnet 5.5 (user)
 * AI Flow      : VLSIT RTL Generator AI Automation Flow
 * AI Flow Page : https://github.com/nguyenquanicd/VLSIT_RTL_Generator_AI_Model
 * Date         : 2026-10-25
 * Description  : AXI4 B channel crossing with one asynchronous FIFO.
 */
`default_nettype none
`timescale 1ns/1ps

module m_vlsit_axi_async_b #(
  // Parameter Description: width of transaction identifier fields.
  // Parameter values: 1 or greater; no fixed design maximum; default is 32'd4.
  // Parameter unit: bit
  parameter logic [31:0] PARA_AXI_ID_W = 32'd4,
  // Parameter Description: number of entries in the B channel FIFO.
  // Parameter values: a power of 2; minimum 2; default is 32'd4.
  // Parameter unit: count
  parameter logic [31:0] PARA_AXI_B_DEPTH = 32'd4,
  // Parameter Description: synchronizer selection for FIFO CDC paths.
  // Parameter values: 1, 2, 3 or 4; bypass is not supported; default is 32'd2.
  // Parameter unit: none
  parameter logic [31:0] PARA_AXI_CELL_TYPE = 32'd2,
  // Parameter Description: FIFO storage selection: RTL array or SRAM wrapper.
  // Parameter values: 0 or 1; default is 32'd0.
  // Parameter unit: none
  parameter logic [31:0] PARA_AXI_MEM_USE_MACRO = 32'd0,
  localparam logic [31:0] LPARA_RESP_W = 32'd2,
  localparam logic [31:0] LPARA_B_ID_LSB = 32'd0,
  localparam logic [31:0] LPARA_B_RESP_LSB = LPARA_B_ID_LSB + PARA_AXI_ID_W,
  localparam logic [31:0] LPARA_B_W = LPARA_B_RESP_LSB + LPARA_RESP_W,
  localparam logic [31:0] LPARA_PTR_W = $clog2(PARA_AXI_B_DEPTH) + 32'd1
) (
  // Clock and reset.
  input i_clk_sub,
  input i_rst_n_sub,
  input i_clk_mgr,
  input i_rst_n_mgr,

  // Manager-side B channel.
  input i_axi_bvalid,
  output logic                     o_axi_bready,
  input [PARA_AXI_ID_W-1:0] i_axi_bid,
  input [LPARA_RESP_W-1:0]               i_axi_bresp,

  // Subordinate-side B channel.
  output logic                     o_axi_bvalid,
  input i_axi_bready,
  output logic [PARA_AXI_ID_W-1:0] o_axi_bid,
  output logic [LPARA_RESP_W-1:0]               o_axi_bresp
);

  // FIFO data and threshold interconnect.
  logic [LPARA_B_W-1:0] w_fifo_wr_data;
  logic [LPARA_B_W-1:0] w_fifo_rd_data;
  logic [LPARA_PTR_W-1:0] w_fifo_full_thr;
  logic w_fifo_full;
  logic w_fifo_empty;

  // Pack fields with the first Section 9 field in the least-significant bits.
  assign w_fifo_wr_data = {i_axi_bresp, i_axi_bid};
  assign w_fifo_full_thr = $bits(w_fifo_full_thr)'(PARA_AXI_B_DEPTH);

  // Map FIFO flags to the source READY and destination VALID handshakes.
  assign o_axi_bready = ~w_fifo_full;
  assign o_axi_bvalid = ~w_fifo_empty;

  // Unpack the FIFO word into destination-side payload fields.
  assign o_axi_bid = w_fifo_rd_data[LPARA_B_ID_LSB +: PARA_AXI_ID_W];
  assign o_axi_bresp = w_fifo_rd_data[LPARA_B_RESP_LSB +: LPARA_RESP_W];

  // Cross the B channel between its source and destination clock domains.
  m_vlsit_afifo_top #(
    .PARA_AFIFO_DEPTH         (PARA_AXI_B_DEPTH),
    .PARA_AFIFO_DATA_W        (LPARA_B_W),
    .PARA_AFIFO_CELL_TYPE     (PARA_AXI_CELL_TYPE),
    .PARA_AFIFO_MEM_USE_MACRO (PARA_AXI_MEM_USE_MACRO)
  ) u_vlsit_afifo_top (
    .i_clk_wr        (i_clk_mgr),
    .i_rst_n_wr      (i_rst_n_mgr),
    .i_wr_en         (i_axi_bvalid),
    .i_wr_data       (w_fifo_wr_data),
    .i_full_thr      (w_fifo_full_thr),
    .o_full          (w_fifo_full),
    .o_full_thr      (),
    .o_overflow      (),
    .i_rst_n_sw      (1'b1),
    .o_sw_rst_busy   (),
    .i_clk_rd        (i_clk_sub),
    .i_rst_n_rd      (i_rst_n_sub),
    .i_rd_en         (i_axi_bready),
    .i_empty_thr     ('0),
    .o_rd_data       (w_fifo_rd_data),
    .o_empty         (w_fifo_empty),
    .o_empty_thr     (),
    .o_underflow     ()
  );

endmodule
`default_nettype wire
