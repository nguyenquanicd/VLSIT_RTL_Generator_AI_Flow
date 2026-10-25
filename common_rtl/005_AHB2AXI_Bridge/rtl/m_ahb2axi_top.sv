/*
 * Project      : VLSIT Common RTL library
 * Author       : Nguyen Quan and Claude Sonnet 5.5 (user)
 * AI Flow      : VLSIT RTL Generator AI Automation Flow
 * AI Flow Page : https://github.com/nguyenquanicd/VLSIT_RTL_Generator_AI_Model
 * Date         : 2026-10-25
 * Description  : Sole structural top for the synchronous Full AHB5 Subordinate to AXI4 Manager
 *                bridge. It forwards the fixed external interfaces to the central controller.
 */
`timescale 1ns/1ps

module m_ahb2axi_top #(
  // Parameter Description: number of read IDs used by the round-robin ID sequence.
  // Parameter values: legal values are 1 through 8; default is 1.
  // Parameter unit: count
  parameter logic [31:0] PARA_RD_ID_COUNT = 32'd1,
  // Parameter Description: number of write IDs used by the round-robin ID sequence.
  // Parameter values: legal values are 1 through 8; default is 1.
  // Parameter unit: count
  parameter logic [31:0] PARA_WR_ID_COUNT = 32'd1
) (
  // Shared clock and reset
  input  wire         i_clk_core,
  input  wire         i_rst_n_core,

  // AHB5 subordinate interface
  input  wire         i_ahb_hsel,
  input  wire         i_ahb_hready,
  input  wire  [31:0] i_ahb_haddr,
  input  wire  [1:0]  i_ahb_htrans,
  input  wire         i_ahb_hwrite,
  input  wire  [2:0]  i_ahb_hsize,
  input  wire  [2:0]  i_ahb_hburst,
  input  wire  [6:0]  i_ahb_hprot,
  input  wire         i_ahb_hnonsec,
  input  wire         i_ahb_hmastlock,
  input  wire  [31:0] i_ahb_hwdata,
  input  wire  [3:0]  i_ahb_hwstrb,
  output logic        o_ahb_hreadyout,
  output logic        o_ahb_hresp,
  output logic [31:0] o_ahb_hrdata,

  // AXI4 write-address channel
  output logic [2:0]  o_axi_awid,
  output logic [31:0] o_axi_awaddr,
  output logic [7:0]  o_axi_awlen,
  output logic [2:0]  o_axi_awsize,
  output logic [1:0]  o_axi_awburst,
  output logic        o_axi_awlock,
  output logic [3:0]  o_axi_awcache,
  output logic [2:0]  o_axi_awprot,
  output logic        o_axi_awvalid,
  input  wire         i_axi_awready,

  // AXI4 write-data channel
  output logic [31:0] o_axi_wdata,
  output logic [3:0]  o_axi_wstrb,
  output logic        o_axi_wlast,
  output logic        o_axi_wvalid,
  input  wire         i_axi_wready,

  // AXI4 write-response channel
  input  wire  [2:0]  i_axi_bid,
  input  wire  [1:0]  i_axi_bresp,
  input  wire         i_axi_bvalid,
  output logic        o_axi_bready,

  // AXI4 read-address channel
  output logic [2:0]  o_axi_arid,
  output logic [31:0] o_axi_araddr,
  output logic [7:0]  o_axi_arlen,
  output logic [2:0]  o_axi_arsize,
  output logic [1:0]  o_axi_arburst,
  output logic        o_axi_arlock,
  output logic [3:0]  o_axi_arcache,
  output logic [2:0]  o_axi_arprot,
  output logic        o_axi_arvalid,
  input  wire         i_axi_arready,

  // AXI4 read-data channel
  input  wire  [2:0]  i_axi_rid,
  input  wire  [31:0] i_axi_rdata,
  input  wire  [1:0]  i_axi_rresp,
  input  wire         i_axi_rlast,
  input  wire         i_axi_rvalid,
  output logic        o_axi_rready
);

  // The top remains structural and passes the two static ID-count parameters unchanged.
  m_ahb2axi_ctrl #(
    .PARA_RD_ID_COUNT (PARA_RD_ID_COUNT),
    .PARA_WR_ID_COUNT (PARA_WR_ID_COUNT)
  ) u_ahb2axi_ctrl (
    .i_clk_core       (i_clk_core),
    .i_rst_n_core     (i_rst_n_core),
    .i_ahb_hsel       (i_ahb_hsel),
    .i_ahb_hready     (i_ahb_hready),
    .i_ahb_haddr      (i_ahb_haddr),
    .i_ahb_htrans     (i_ahb_htrans),
    .i_ahb_hwrite     (i_ahb_hwrite),
    .i_ahb_hsize      (i_ahb_hsize),
    .i_ahb_hburst     (i_ahb_hburst),
    .i_ahb_hprot      (i_ahb_hprot),
    .i_ahb_hnonsec    (i_ahb_hnonsec),
    .i_ahb_hmastlock  (i_ahb_hmastlock),
    .i_ahb_hwdata     (i_ahb_hwdata),
    .i_ahb_hwstrb     (i_ahb_hwstrb),
    .o_ahb_hreadyout  (o_ahb_hreadyout),
    .o_ahb_hresp      (o_ahb_hresp),
    .o_ahb_hrdata     (o_ahb_hrdata),
    .o_axi_awid       (o_axi_awid),
    .o_axi_awaddr     (o_axi_awaddr),
    .o_axi_awlen      (o_axi_awlen),
    .o_axi_awsize     (o_axi_awsize),
    .o_axi_awburst    (o_axi_awburst),
    .o_axi_awlock     (o_axi_awlock),
    .o_axi_awcache    (o_axi_awcache),
    .o_axi_awprot     (o_axi_awprot),
    .o_axi_awvalid    (o_axi_awvalid),
    .i_axi_awready    (i_axi_awready),
    .o_axi_wdata      (o_axi_wdata),
    .o_axi_wstrb      (o_axi_wstrb),
    .o_axi_wlast      (o_axi_wlast),
    .o_axi_wvalid     (o_axi_wvalid),
    .i_axi_wready     (i_axi_wready),
    .i_axi_bid        (i_axi_bid),
    .i_axi_bresp      (i_axi_bresp),
    .i_axi_bvalid     (i_axi_bvalid),
    .o_axi_bready     (o_axi_bready),
    .o_axi_arid       (o_axi_arid),
    .o_axi_araddr     (o_axi_araddr),
    .o_axi_arlen      (o_axi_arlen),
    .o_axi_arsize     (o_axi_arsize),
    .o_axi_arburst    (o_axi_arburst),
    .o_axi_arlock     (o_axi_arlock),
    .o_axi_arcache    (o_axi_arcache),
    .o_axi_arprot     (o_axi_arprot),
    .o_axi_arvalid    (o_axi_arvalid),
    .i_axi_arready    (i_axi_arready),
    .i_axi_rid        (i_axi_rid),
    .i_axi_rdata      (i_axi_rdata),
    .i_axi_rresp      (i_axi_rresp),
    .i_axi_rlast      (i_axi_rlast),
    .i_axi_rvalid     (i_axi_rvalid),
    .o_axi_rready     (o_axi_rready)
  );

endmodule
