/*
 * Project      : VLSIT Common RTL library
 * Author       : Nguyen Quan and Claude Sonnet 5.5 (user)
 * AI Flow      : VLSIT RTL Generator AI Automation Flow
 * AI Flow Page : https://github.com/nguyenquanicd/VLSIT_RTL_Generator_AI_Model
 * Date         : 2026-10-25
 * Description  : AXI4 AR channel crossing with one asynchronous FIFO.
 */
`default_nettype none
`timescale 1ns/1ps

module m_vlsit_axi_async_ar #(
  // Parameter Description: address width of this channel.
  // Parameter values: 1 to 64; default is 32'd32.
  // Parameter unit: bit
  parameter logic [31:0] PARA_AXI_ADDR_W = 32'd32,
  // Parameter Description: width of transaction identifier fields.
  // Parameter values: 1 or greater; no fixed design maximum; default is 32'd4.
  // Parameter unit: bit
  parameter logic [31:0] PARA_AXI_ID_W = 32'd4,
  // Parameter Description: number of entries in the AR channel FIFO.
  // Parameter values: a power of 2; minimum 2; default is 32'd4.
  // Parameter unit: count
  parameter logic [31:0] PARA_AXI_AR_DEPTH = 32'd4,
  // Parameter Description: synchronizer selection for FIFO CDC paths.
  // Parameter values: 1, 2, 3 or 4; bypass is not supported; default is 32'd2.
  // Parameter unit: none
  parameter logic [31:0] PARA_AXI_CELL_TYPE = 32'd2,
  // Parameter Description: FIFO storage selection: RTL array or SRAM wrapper.
  // Parameter values: 0 or 1; default is 32'd0.
  // Parameter unit: none
  parameter logic [31:0] PARA_AXI_MEM_USE_MACRO = 32'd0,
  localparam logic [31:0] LPARA_LEN_W = 32'd8,
  localparam logic [31:0] LPARA_LOCK_W = 32'd1,
  localparam logic [31:0] LPARA_SIZE_W = 32'd3,
  localparam logic [31:0] LPARA_BURST_W = 32'd2,
  localparam logic [31:0] LPARA_CACHE_W = 32'd4,
  localparam logic [31:0] LPARA_PROT_W = 32'd3,
  localparam logic [31:0] LPARA_QOS_W = 32'd4,
  localparam logic [31:0] LPARA_REGION_W = 32'd4,
  localparam logic [31:0] LPARA_AR_ID_LSB = 32'd0,
  localparam logic [31:0] LPARA_AR_ADDR_LSB = LPARA_AR_ID_LSB + PARA_AXI_ID_W,
  localparam logic [31:0] LPARA_AR_LEN_LSB = LPARA_AR_ADDR_LSB + PARA_AXI_ADDR_W,
  localparam logic [31:0] LPARA_AR_SIZE_LSB = LPARA_AR_LEN_LSB + LPARA_LEN_W,
  localparam logic [31:0] LPARA_AR_BURST_LSB = LPARA_AR_SIZE_LSB + LPARA_SIZE_W,
  localparam logic [31:0] LPARA_AR_LOCK_LSB = LPARA_AR_BURST_LSB + LPARA_BURST_W,
  localparam logic [31:0] LPARA_AR_CACHE_LSB = LPARA_AR_LOCK_LSB + LPARA_LOCK_W,
  localparam logic [31:0] LPARA_AR_PROT_LSB = LPARA_AR_CACHE_LSB + LPARA_CACHE_W,
  localparam logic [31:0] LPARA_AR_QOS_LSB = LPARA_AR_PROT_LSB + LPARA_PROT_W,
  localparam logic [31:0] LPARA_AR_REGION_LSB = LPARA_AR_QOS_LSB + LPARA_QOS_W,
  localparam logic [31:0] LPARA_AR_W = LPARA_AR_REGION_LSB + LPARA_REGION_W,
  localparam logic [31:0] LPARA_PTR_W = $clog2(PARA_AXI_AR_DEPTH) + 32'd1
) (
  // Clock and reset.
  input i_clk_sub,
  input i_rst_n_sub,
  input i_clk_mgr,
  input i_rst_n_mgr,

  // Subordinate-side AR channel.
  input i_axi_arvalid,
  output logic                       o_axi_arready,
  input [PARA_AXI_ID_W-1:0]   i_axi_arid,
  input [PARA_AXI_ADDR_W-1:0] i_axi_araddr,
  input [LPARA_LEN_W-1:0]     i_axi_arlen,
  input [LPARA_SIZE_W-1:0]                 i_axi_arsize,
  input [LPARA_BURST_W-1:0]                 i_axi_arburst,
  input [LPARA_LOCK_W-1:0]    i_axi_arlock,
  input [LPARA_CACHE_W-1:0]                 i_axi_arcache,
  input [LPARA_PROT_W-1:0]                 i_axi_arprot,
  input [LPARA_QOS_W-1:0]                 i_axi_arqos,
  input [LPARA_REGION_W-1:0]                 i_axi_arregion,

  // Manager-side AR channel.
  output logic                       o_axi_arvalid,
  input i_axi_arready,
  output logic [PARA_AXI_ID_W-1:0]   o_axi_arid,
  output logic [PARA_AXI_ADDR_W-1:0] o_axi_araddr,
  output logic [LPARA_LEN_W-1:0]     o_axi_arlen,
  output logic [LPARA_SIZE_W-1:0]                 o_axi_arsize,
  output logic [LPARA_BURST_W-1:0]                 o_axi_arburst,
  output logic [LPARA_LOCK_W-1:0]    o_axi_arlock,
  output logic [LPARA_CACHE_W-1:0]                 o_axi_arcache,
  output logic [LPARA_PROT_W-1:0]                 o_axi_arprot,
  output logic [LPARA_QOS_W-1:0]                 o_axi_arqos,
  output logic [LPARA_REGION_W-1:0]                 o_axi_arregion
);

  // FIFO data and threshold interconnect.
  logic [LPARA_AR_W-1:0] w_fifo_wr_data;
  logic [LPARA_AR_W-1:0] w_fifo_rd_data;
  logic [LPARA_PTR_W-1:0] w_fifo_full_thr;
  logic w_fifo_full;
  logic w_fifo_empty;

  // Pack fields with the first Section 9 field in the least-significant bits.
  assign w_fifo_wr_data = {i_axi_arregion, i_axi_arqos, i_axi_arprot, i_axi_arcache, i_axi_arlock, i_axi_arburst, i_axi_arsize, i_axi_arlen, i_axi_araddr, i_axi_arid};
  assign w_fifo_full_thr = $bits(w_fifo_full_thr)'(PARA_AXI_AR_DEPTH);

  // Map FIFO flags to the source READY and destination VALID handshakes.
  assign o_axi_arready = ~w_fifo_full;
  assign o_axi_arvalid = ~w_fifo_empty;

  // Unpack the FIFO word into destination-side payload fields.
  assign o_axi_arid = w_fifo_rd_data[LPARA_AR_ID_LSB +: PARA_AXI_ID_W];
  assign o_axi_araddr = w_fifo_rd_data[LPARA_AR_ADDR_LSB +: PARA_AXI_ADDR_W];
  assign o_axi_arlen = w_fifo_rd_data[LPARA_AR_LEN_LSB +: LPARA_LEN_W];
  assign o_axi_arsize = w_fifo_rd_data[LPARA_AR_SIZE_LSB +: LPARA_SIZE_W];
  assign o_axi_arburst = w_fifo_rd_data[LPARA_AR_BURST_LSB +: LPARA_BURST_W];
  assign o_axi_arlock = w_fifo_rd_data[LPARA_AR_LOCK_LSB +: LPARA_LOCK_W];
  assign o_axi_arcache = w_fifo_rd_data[LPARA_AR_CACHE_LSB +: LPARA_CACHE_W];
  assign o_axi_arprot = w_fifo_rd_data[LPARA_AR_PROT_LSB +: LPARA_PROT_W];
  assign o_axi_arqos = w_fifo_rd_data[LPARA_AR_QOS_LSB +: LPARA_QOS_W];
  assign o_axi_arregion = w_fifo_rd_data[LPARA_AR_REGION_LSB +: LPARA_REGION_W];

  // Cross the AR channel between its source and destination clock domains.
  m_vlsit_afifo_top #(
    .PARA_AFIFO_DEPTH         (PARA_AXI_AR_DEPTH),
    .PARA_AFIFO_DATA_W        (LPARA_AR_W),
    .PARA_AFIFO_CELL_TYPE     (PARA_AXI_CELL_TYPE),
    .PARA_AFIFO_MEM_USE_MACRO (PARA_AXI_MEM_USE_MACRO)
  ) u_vlsit_afifo_top (
    .i_clk_wr        (i_clk_sub),
    .i_rst_n_wr      (i_rst_n_sub),
    .i_wr_en         (i_axi_arvalid),
    .i_wr_data       (w_fifo_wr_data),
    .i_full_thr      (w_fifo_full_thr),
    .o_full          (w_fifo_full),
    .o_full_thr      (),
    .o_overflow      (),
    .i_rst_n_sw      (1'b1),
    .o_sw_rst_busy   (),
    .i_clk_rd        (i_clk_mgr),
    .i_rst_n_rd      (i_rst_n_mgr),
    .i_rd_en         (i_axi_arready),
    .i_empty_thr     ('0),
    .o_rd_data       (w_fifo_rd_data),
    .o_empty         (w_fifo_empty),
    .o_empty_thr     (),
    .o_underflow     ()
  );

endmodule
`default_nettype wire
