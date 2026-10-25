/*
 * Project      : VLSIT Common RTL library
 * Author       : Nguyen Quan and Claude Sonnet 5.5 (user)
 * AI Flow      : VLSIT RTL Generator AI Automation Flow
 * AI Flow Page : https://github.com/nguyenquanicd/VLSIT_RTL_Generator_AI_Model
 * Date         : 2026-10-25
 * Description  : Structural AXI4 bridge top with all five USER sidebands.
 */
`default_nettype none
`timescale 1ns/1ps

module m_vlsit_axi_user_async_top #(
  // Parameter Description: address width for AWADDR and ARADDR.
  // Parameter values: 1 to 64; default is 32'd32.
  // Parameter unit: bit
  parameter logic [31:0] PARA_AXI_ADDR_W = 32'd32,
  // Parameter Description: data width for WDATA and RDATA.
  // Parameter values: 8, 16, 32, 64, 128, 256, 512 or 1024; default is 32'd32.
  // Parameter unit: bit
  parameter logic [31:0] PARA_AXI_DATA_W = 32'd32,
  // Parameter Description: width of transaction identifier fields.
  // Parameter values: 1 or greater; no fixed design maximum; default is 32'd4.
  // Parameter unit: bit
  parameter logic [31:0] PARA_AXI_ID_W = 32'd4,
  // Parameter Description: width of AWUSER in the AXI4 USER profile.
  // Parameter values: 1 to 128; default is 32'd1.
  // Parameter unit: bit
  parameter logic [31:0] PARA_AXI_AWUSER_W = 32'd1,
  // Parameter Description: width of WUSER in the AXI4 USER profile.
  // Parameter values: 1 to PARA_AXI_DATA_W / 2; default is 32'd1.
  // Parameter unit: bit
  parameter logic [31:0] PARA_AXI_WUSER_W = 32'd1,
  // Parameter Description: width of BUSER in the AXI4 USER profile.
  // Parameter values: 1 to 16; default is 32'd1.
  // Parameter unit: bit
  parameter logic [31:0] PARA_AXI_BUSER_W = 32'd1,
  // Parameter Description: width of ARUSER in the AXI4 USER profile.
  // Parameter values: 1 to 128; default is 32'd1.
  // Parameter unit: bit
  parameter logic [31:0] PARA_AXI_ARUSER_W = 32'd1,
  // Parameter Description: width of RUSER in the AXI4 USER profile.
  // Parameter values: 1 to PARA_AXI_DATA_W / 2 + 16; default is 32'd1.
  // Parameter unit: bit
  parameter logic [31:0] PARA_AXI_RUSER_W = 32'd1,
  // Parameter Description: number of entries in the AW channel FIFO.
  // Parameter values: a power of 2; minimum 2; default is 32'd4.
  // Parameter unit: count
  parameter logic [31:0] PARA_AXI_AW_DEPTH = 32'd4,
  // Parameter Description: number of entries in the W channel FIFO.
  // Parameter values: a power of 2; minimum 2; default is 32'd16.
  // Parameter unit: count
  parameter logic [31:0] PARA_AXI_W_DEPTH = 32'd16,
  // Parameter Description: number of entries in the B channel FIFO.
  // Parameter values: a power of 2; minimum 2; default is 32'd4.
  // Parameter unit: count
  parameter logic [31:0] PARA_AXI_B_DEPTH = 32'd4,
  // Parameter Description: number of entries in the AR channel FIFO.
  // Parameter values: a power of 2; minimum 2; default is 32'd4.
  // Parameter unit: count
  parameter logic [31:0] PARA_AXI_AR_DEPTH = 32'd4,
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
  localparam logic [31:0] LPARA_LEN_W = 32'd8,
  localparam logic [31:0] LPARA_LOCK_W = 32'd1,
  localparam logic [31:0] LPARA_STRB_W = PARA_AXI_DATA_W / 32'd8,
  localparam logic [31:0] LPARA_AWUSER_W = PARA_AXI_AWUSER_W,
  localparam logic [31:0] LPARA_WUSER_W = PARA_AXI_WUSER_W,
  localparam logic [31:0] LPARA_BUSER_W = PARA_AXI_BUSER_W,
  localparam logic [31:0] LPARA_ARUSER_W = PARA_AXI_ARUSER_W,
  localparam logic [31:0] LPARA_RUSER_W = PARA_AXI_RUSER_W
) (
  // Clock and reset.
  input i_clk_sub,
  input i_rst_n_sub,
  input i_clk_mgr,
  input i_rst_n_mgr,

  // Subordinate-side AW channel.
  input i_axi_awvalid,
  output logic                       o_axi_awready,
  input [PARA_AXI_ID_W-1:0]   i_axi_awid,
  input [PARA_AXI_ADDR_W-1:0] i_axi_awaddr,
  input [LPARA_LEN_W-1:0]     i_axi_awlen,
  input [2:0]                 i_axi_awsize,
  input [1:0]                 i_axi_awburst,
  input [LPARA_LOCK_W-1:0]    i_axi_awlock,
  input [3:0]                 i_axi_awcache,
  input [2:0]                 i_axi_awprot,
  input [3:0]                 i_axi_awqos,
  input [3:0]                 i_axi_awregion,
  input [LPARA_AWUSER_W-1:0]  i_axi_awuser,

  // Manager-side AW channel.
  output logic                       o_axi_awvalid,
  input i_axi_awready,
  output logic [PARA_AXI_ID_W-1:0]   o_axi_awid,
  output logic [PARA_AXI_ADDR_W-1:0] o_axi_awaddr,
  output logic [LPARA_LEN_W-1:0]     o_axi_awlen,
  output logic [2:0]                 o_axi_awsize,
  output logic [1:0]                 o_axi_awburst,
  output logic [LPARA_LOCK_W-1:0]    o_axi_awlock,
  output logic [3:0]                 o_axi_awcache,
  output logic [2:0]                 o_axi_awprot,
  output logic [3:0]                 o_axi_awqos,
  output logic [3:0]                 o_axi_awregion,
  output logic [LPARA_AWUSER_W-1:0]  o_axi_awuser,

  // Subordinate-side W channel.
  input i_axi_wvalid,
  output logic                       o_axi_wready,
  input [PARA_AXI_DATA_W-1:0] i_axi_wdata,
  input [LPARA_STRB_W-1:0]    i_axi_wstrb,
  input i_axi_wlast,
  input [LPARA_WUSER_W-1:0]   i_axi_wuser,

  // Manager-side W channel.
  output logic                       o_axi_wvalid,
  input i_axi_wready,
  output logic [PARA_AXI_DATA_W-1:0] o_axi_wdata,
  output logic [LPARA_STRB_W-1:0]    o_axi_wstrb,
  output logic                       o_axi_wlast,
  output logic [LPARA_WUSER_W-1:0]   o_axi_wuser,

  // Manager-side B channel.
  input i_axi_bvalid,
  output logic                       o_axi_bready,
  input [PARA_AXI_ID_W-1:0]   i_axi_bid,
  input [1:0]                 i_axi_bresp,
  input [LPARA_BUSER_W-1:0]   i_axi_buser,

  // Subordinate-side B channel.
  output logic                       o_axi_bvalid,
  input i_axi_bready,
  output logic [PARA_AXI_ID_W-1:0]   o_axi_bid,
  output logic [1:0]                 o_axi_bresp,
  output logic [LPARA_BUSER_W-1:0]   o_axi_buser,

  // Subordinate-side AR channel.
  input i_axi_arvalid,
  output logic                       o_axi_arready,
  input [PARA_AXI_ID_W-1:0]   i_axi_arid,
  input [PARA_AXI_ADDR_W-1:0] i_axi_araddr,
  input [LPARA_LEN_W-1:0]     i_axi_arlen,
  input [2:0]                 i_axi_arsize,
  input [1:0]                 i_axi_arburst,
  input [LPARA_LOCK_W-1:0]    i_axi_arlock,
  input [3:0]                 i_axi_arcache,
  input [2:0]                 i_axi_arprot,
  input [3:0]                 i_axi_arqos,
  input [3:0]                 i_axi_arregion,
  input [LPARA_ARUSER_W-1:0]  i_axi_aruser,

  // Manager-side AR channel.
  output logic                       o_axi_arvalid,
  input i_axi_arready,
  output logic [PARA_AXI_ID_W-1:0]   o_axi_arid,
  output logic [PARA_AXI_ADDR_W-1:0] o_axi_araddr,
  output logic [LPARA_LEN_W-1:0]     o_axi_arlen,
  output logic [2:0]                 o_axi_arsize,
  output logic [1:0]                 o_axi_arburst,
  output logic [LPARA_LOCK_W-1:0]    o_axi_arlock,
  output logic [3:0]                 o_axi_arcache,
  output logic [2:0]                 o_axi_arprot,
  output logic [3:0]                 o_axi_arqos,
  output logic [3:0]                 o_axi_arregion,
  output logic [LPARA_ARUSER_W-1:0]  o_axi_aruser,

  // Manager-side R channel.
  input i_axi_rvalid,
  output logic                       o_axi_rready,
  input [PARA_AXI_ID_W-1:0]   i_axi_rid,
  input [PARA_AXI_DATA_W-1:0] i_axi_rdata,
  input [1:0]                 i_axi_rresp,
  input i_axi_rlast,
  input [LPARA_RUSER_W-1:0]   i_axi_ruser,

  // Subordinate-side R channel.
  output logic                       o_axi_rvalid,
  input i_axi_rready,
  output logic [PARA_AXI_ID_W-1:0]   o_axi_rid,
  output logic [PARA_AXI_DATA_W-1:0] o_axi_rdata,
  output logic [1:0]                 o_axi_rresp,
  output logic                       o_axi_rlast,
  output logic [LPARA_RUSER_W-1:0]   o_axi_ruser
);

  // Connect the AW FIFO channel from Subordinate to manager.
  m_vlsit_axi_user_async_aw #(
    .PARA_AXI_ADDR_W        (PARA_AXI_ADDR_W),
    .PARA_AXI_ID_W          (PARA_AXI_ID_W),
    .PARA_AXI_AWUSER_W      (PARA_AXI_AWUSER_W),
    .PARA_AXI_AW_DEPTH      (PARA_AXI_AW_DEPTH),
    .PARA_AXI_CELL_TYPE     (PARA_AXI_CELL_TYPE),
    .PARA_AXI_MEM_USE_MACRO (PARA_AXI_MEM_USE_MACRO)
  ) u_vlsit_axi_user_async_aw (
    .i_clk_sub      (i_clk_sub),
    .i_rst_n_sub    (i_rst_n_sub),
    .i_clk_mgr      (i_clk_mgr),
    .i_rst_n_mgr    (i_rst_n_mgr),
    .i_axi_awvalid  (i_axi_awvalid),
    .o_axi_awready  (o_axi_awready),
    .i_axi_awid     (i_axi_awid),
    .i_axi_awaddr   (i_axi_awaddr),
    .i_axi_awlen    (i_axi_awlen),
    .i_axi_awsize   (i_axi_awsize),
    .i_axi_awburst  (i_axi_awburst),
    .i_axi_awlock   (i_axi_awlock),
    .i_axi_awcache  (i_axi_awcache),
    .i_axi_awprot   (i_axi_awprot),
    .i_axi_awqos    (i_axi_awqos),
    .i_axi_awregion (i_axi_awregion),
    .i_axi_awuser   (i_axi_awuser),
    .o_axi_awvalid  (o_axi_awvalid),
    .i_axi_awready  (i_axi_awready),
    .o_axi_awid     (o_axi_awid),
    .o_axi_awaddr   (o_axi_awaddr),
    .o_axi_awlen    (o_axi_awlen),
    .o_axi_awsize   (o_axi_awsize),
    .o_axi_awburst  (o_axi_awburst),
    .o_axi_awlock   (o_axi_awlock),
    .o_axi_awcache  (o_axi_awcache),
    .o_axi_awprot   (o_axi_awprot),
    .o_axi_awqos    (o_axi_awqos),
    .o_axi_awregion (o_axi_awregion),
    .o_axi_awuser   (o_axi_awuser)
  );

  // Connect the W FIFO channel from Subordinate to manager.
  m_vlsit_axi_user_async_w #(
    .PARA_AXI_DATA_W        (PARA_AXI_DATA_W),
    .PARA_AXI_WUSER_W       (PARA_AXI_WUSER_W),
    .PARA_AXI_W_DEPTH       (PARA_AXI_W_DEPTH),
    .PARA_AXI_CELL_TYPE     (PARA_AXI_CELL_TYPE),
    .PARA_AXI_MEM_USE_MACRO (PARA_AXI_MEM_USE_MACRO)
  ) u_vlsit_axi_user_async_w (
    .i_clk_sub    (i_clk_sub),
    .i_rst_n_sub  (i_rst_n_sub),
    .i_clk_mgr    (i_clk_mgr),
    .i_rst_n_mgr  (i_rst_n_mgr),
    .i_axi_wvalid (i_axi_wvalid),
    .o_axi_wready (o_axi_wready),
    .i_axi_wdata  (i_axi_wdata),
    .i_axi_wstrb  (i_axi_wstrb),
    .i_axi_wlast  (i_axi_wlast),
    .i_axi_wuser  (i_axi_wuser),
    .o_axi_wvalid (o_axi_wvalid),
    .i_axi_wready (i_axi_wready),
    .o_axi_wdata  (o_axi_wdata),
    .o_axi_wstrb  (o_axi_wstrb),
    .o_axi_wlast  (o_axi_wlast),
    .o_axi_wuser  (o_axi_wuser)
  );

  // Connect the B FIFO channel from Manager to subordinate.
  m_vlsit_axi_user_async_b #(
    .PARA_AXI_ID_W          (PARA_AXI_ID_W),
    .PARA_AXI_BUSER_W       (PARA_AXI_BUSER_W),
    .PARA_AXI_B_DEPTH       (PARA_AXI_B_DEPTH),
    .PARA_AXI_CELL_TYPE     (PARA_AXI_CELL_TYPE),
    .PARA_AXI_MEM_USE_MACRO (PARA_AXI_MEM_USE_MACRO)
  ) u_vlsit_axi_user_async_b (
    .i_clk_sub    (i_clk_sub),
    .i_rst_n_sub  (i_rst_n_sub),
    .i_clk_mgr    (i_clk_mgr),
    .i_rst_n_mgr  (i_rst_n_mgr),
    .i_axi_bvalid (i_axi_bvalid),
    .o_axi_bready (o_axi_bready),
    .i_axi_bid    (i_axi_bid),
    .i_axi_bresp  (i_axi_bresp),
    .i_axi_buser  (i_axi_buser),
    .o_axi_bvalid (o_axi_bvalid),
    .i_axi_bready (i_axi_bready),
    .o_axi_bid    (o_axi_bid),
    .o_axi_bresp  (o_axi_bresp),
    .o_axi_buser  (o_axi_buser)
  );

  // Connect the AR FIFO channel from Subordinate to manager.
  m_vlsit_axi_user_async_ar #(
    .PARA_AXI_ADDR_W        (PARA_AXI_ADDR_W),
    .PARA_AXI_ID_W          (PARA_AXI_ID_W),
    .PARA_AXI_ARUSER_W      (PARA_AXI_ARUSER_W),
    .PARA_AXI_AR_DEPTH      (PARA_AXI_AR_DEPTH),
    .PARA_AXI_CELL_TYPE     (PARA_AXI_CELL_TYPE),
    .PARA_AXI_MEM_USE_MACRO (PARA_AXI_MEM_USE_MACRO)
  ) u_vlsit_axi_user_async_ar (
    .i_clk_sub      (i_clk_sub),
    .i_rst_n_sub    (i_rst_n_sub),
    .i_clk_mgr      (i_clk_mgr),
    .i_rst_n_mgr    (i_rst_n_mgr),
    .i_axi_arvalid  (i_axi_arvalid),
    .o_axi_arready  (o_axi_arready),
    .i_axi_arid     (i_axi_arid),
    .i_axi_araddr   (i_axi_araddr),
    .i_axi_arlen    (i_axi_arlen),
    .i_axi_arsize   (i_axi_arsize),
    .i_axi_arburst  (i_axi_arburst),
    .i_axi_arlock   (i_axi_arlock),
    .i_axi_arcache  (i_axi_arcache),
    .i_axi_arprot   (i_axi_arprot),
    .i_axi_arqos    (i_axi_arqos),
    .i_axi_arregion (i_axi_arregion),
    .i_axi_aruser   (i_axi_aruser),
    .o_axi_arvalid  (o_axi_arvalid),
    .i_axi_arready  (i_axi_arready),
    .o_axi_arid     (o_axi_arid),
    .o_axi_araddr   (o_axi_araddr),
    .o_axi_arlen    (o_axi_arlen),
    .o_axi_arsize   (o_axi_arsize),
    .o_axi_arburst  (o_axi_arburst),
    .o_axi_arlock   (o_axi_arlock),
    .o_axi_arcache  (o_axi_arcache),
    .o_axi_arprot   (o_axi_arprot),
    .o_axi_arqos    (o_axi_arqos),
    .o_axi_arregion (o_axi_arregion),
    .o_axi_aruser   (o_axi_aruser)
  );

  // Connect the R FIFO channel from Manager to subordinate.
  m_vlsit_axi_user_async_r #(
    .PARA_AXI_DATA_W        (PARA_AXI_DATA_W),
    .PARA_AXI_ID_W          (PARA_AXI_ID_W),
    .PARA_AXI_RUSER_W       (PARA_AXI_RUSER_W),
    .PARA_AXI_R_DEPTH       (PARA_AXI_R_DEPTH),
    .PARA_AXI_CELL_TYPE     (PARA_AXI_CELL_TYPE),
    .PARA_AXI_MEM_USE_MACRO (PARA_AXI_MEM_USE_MACRO)
  ) u_vlsit_axi_user_async_r (
    .i_clk_sub    (i_clk_sub),
    .i_rst_n_sub  (i_rst_n_sub),
    .i_clk_mgr    (i_clk_mgr),
    .i_rst_n_mgr  (i_rst_n_mgr),
    .i_axi_rvalid (i_axi_rvalid),
    .o_axi_rready (o_axi_rready),
    .i_axi_rid    (i_axi_rid),
    .i_axi_rdata  (i_axi_rdata),
    .i_axi_rresp  (i_axi_rresp),
    .i_axi_rlast  (i_axi_rlast),
    .i_axi_ruser  (i_axi_ruser),
    .o_axi_rvalid (o_axi_rvalid),
    .i_axi_rready (i_axi_rready),
    .o_axi_rid    (o_axi_rid),
    .o_axi_rdata  (o_axi_rdata),
    .o_axi_rresp  (o_axi_rresp),
    .o_axi_rlast  (o_axi_rlast),
    .o_axi_ruser  (o_axi_ruser)
  );

endmodule
`default_nettype wire
