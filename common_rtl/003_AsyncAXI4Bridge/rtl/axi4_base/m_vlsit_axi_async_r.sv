/*
 * Project      : VLSIT Common RTL library
 * Author       : Nguyen Quan and Claude Sonnet 5.5 (user)
 * AI Flow      : VLSIT RTL Generator AI Automation Flow
 * AI Flow Page : https://github.com/nguyenquanicd/VLSIT_RTL_Generator_AI_Model
 * Date         : 2026-10-25
 * Description  : AXI4 R channel crossing with one asynchronous FIFO.
 */
`default_nettype none
`timescale 1ns/1ps

module m_vlsit_axi_async_r #(
  // Parameter Description: data width of this channel.
  // Parameter values: 8, 16, 32, 64, 128, 256, 512 or 1024; default is 32'd32.
  // Parameter unit: bit
  parameter logic [31:0] PARA_AXI_DATA_W = 32'd32,
  // Parameter Description: width of transaction identifier fields.
  // Parameter values: 1 or greater; no fixed design maximum; default is 32'd4.
  // Parameter unit: bit
  parameter logic [31:0] PARA_AXI_ID_W = 32'd4,
  // Parameter Description: number of entries in the R channel FIFO.
  // Parameter values: a power of 2; minimum 2; default is 32'd16.
  // Parameter unit: count
  parameter logic [31:0] PARA_AXI_R_DEPTH = 32'd16,
  // Parameter Description: synchronizer selection for FIFO CDC paths.
  // Parameter values: 1, 2, 3 or 4; bypass is not supported; default is 32'd2.
  // Parameter unit: none
  parameter logic [31:0] PARA_AXI_CELL_TYPE = 32'd2,
  // Parameter Description: FIFO storage selection: RTL array or SRAM wrapper.
  // Parameter values: 0 or 1; default is 32'd0.
  // Parameter unit: none
  parameter logic [31:0] PARA_AXI_MEM_USE_MACRO = 32'd0,
  localparam logic [31:0] LPARA_RESP_W = 32'd2,
  localparam logic [31:0] LPARA_R_ID_LSB = 32'd0,
  localparam logic [31:0] LPARA_R_DATA_LSB = LPARA_R_ID_LSB + PARA_AXI_ID_W,
  localparam logic [31:0] LPARA_R_RESP_LSB = LPARA_R_DATA_LSB + PARA_AXI_DATA_W,
  localparam logic [31:0] LPARA_R_LAST_LSB = LPARA_R_RESP_LSB + LPARA_RESP_W,
  localparam logic [31:0] LPARA_R_W = LPARA_R_LAST_LSB + 32'd1,
  localparam logic [31:0] LPARA_PTR_W = $clog2(PARA_AXI_R_DEPTH) + 32'd1
) (
  // Clock and reset.
  input i_clk_sub,
  input i_rst_n_sub,
  input i_clk_mgr,
  input i_rst_n_mgr,

  // Manager-side R channel.
  input i_axi_rvalid,
  output logic                       o_axi_rready,
  input [PARA_AXI_ID_W-1:0]   i_axi_rid,
  input [PARA_AXI_DATA_W-1:0] i_axi_rdata,
  input [LPARA_RESP_W-1:0]                 i_axi_rresp,
  input i_axi_rlast,

  // Subordinate-side R channel.
  output logic                       o_axi_rvalid,
  input i_axi_rready,
  output logic [PARA_AXI_ID_W-1:0]   o_axi_rid,
  output logic [PARA_AXI_DATA_W-1:0] o_axi_rdata,
  output logic [LPARA_RESP_W-1:0]                 o_axi_rresp,
  output logic                       o_axi_rlast
);

  // FIFO data and threshold interconnect.
  logic [LPARA_R_W-1:0] w_fifo_wr_data;
  logic [LPARA_R_W-1:0] w_fifo_rd_data;
  logic [LPARA_PTR_W-1:0] w_fifo_full_thr;
  logic w_fifo_full;
  logic w_fifo_empty;

  // Pack fields with the first Section 9 field in the least-significant bits.
  assign w_fifo_wr_data = {i_axi_rlast, i_axi_rresp, i_axi_rdata, i_axi_rid};
  assign w_fifo_full_thr = $bits(w_fifo_full_thr)'(PARA_AXI_R_DEPTH);

  // Map FIFO flags to the source READY and destination VALID handshakes.
  assign o_axi_rready = ~w_fifo_full;
  assign o_axi_rvalid = ~w_fifo_empty;

  // Unpack the FIFO word into destination-side payload fields.
  assign o_axi_rid = w_fifo_rd_data[LPARA_R_ID_LSB +: PARA_AXI_ID_W];
  assign o_axi_rdata = w_fifo_rd_data[LPARA_R_DATA_LSB +: PARA_AXI_DATA_W];
  assign o_axi_rresp = w_fifo_rd_data[LPARA_R_RESP_LSB +: LPARA_RESP_W];
  assign o_axi_rlast = w_fifo_rd_data[LPARA_R_LAST_LSB];

  // Cross the R channel between its source and destination clock domains.
  m_vlsit_afifo_top #(
    .PARA_AFIFO_DEPTH         (PARA_AXI_R_DEPTH),
    .PARA_AFIFO_DATA_W        (LPARA_R_W),
    .PARA_AFIFO_CELL_TYPE     (PARA_AXI_CELL_TYPE),
    .PARA_AFIFO_MEM_USE_MACRO (PARA_AXI_MEM_USE_MACRO)
  ) u_vlsit_afifo_top (
    .i_clk_wr        (i_clk_mgr),
    .i_rst_n_wr      (i_rst_n_mgr),
    .i_wr_en         (i_axi_rvalid),
    .i_wr_data       (w_fifo_wr_data),
    .i_full_thr      (w_fifo_full_thr),
    .o_full          (w_fifo_full),
    .o_full_thr      (),
    .o_overflow      (),
    .i_rst_n_sw      (1'b1),
    .o_sw_rst_busy   (),
    .i_clk_rd        (i_clk_sub),
    .i_rst_n_rd      (i_rst_n_sub),
    .i_rd_en         (i_axi_rready),
    .i_empty_thr     ('0),
    .o_rd_data       (w_fifo_rd_data),
    .o_empty         (w_fifo_empty),
    .o_empty_thr     (),
    .o_underflow     ()
  );

endmodule
`default_nettype wire
