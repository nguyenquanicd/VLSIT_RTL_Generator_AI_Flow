/*
 * Project      : VLSIT Common RTL library
 * Author       : Nguyen Quan and Claude Sonnet 5.5 (user)
 * AI Flow      : VLSIT RTL Generator AI Automation Flow
 * AI Flow Page : https://github.com/nguyenquanicd/VLSIT_RTL_Generator_AI_Model
 * Date         : 2026-10-25
 * Description  : AXI4 manager boundary. It maps controller request and response channels to the
 *                fixed AXI4 pins without adding buffering or READY-dependent output logic.
 */
`timescale 1ns/1ps

module m_ahb2axi_axi_if (
  // Shared reset gates AXI VALID and READY during reset.
  input  wire         i_rst_n_core,

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
  output logic        o_axi_rready,

  // Write-address request channel from the controller
  input  wire         i_req_aw_valid,
  output logic        o_req_aw_ready,
  input  wire  [2:0]  i_req_aw_id,
  input  wire  [31:0] i_req_aw_addr,
  input  wire  [7:0]  i_req_aw_len,
  input  wire  [2:0]  i_req_aw_size,
  input  wire  [1:0]  i_req_aw_burst,
  input  wire  [3:0]  i_req_aw_cache,
  input  wire  [2:0]  i_req_aw_prot,

  // Write-data request channel from the controller
  input  wire         i_req_w_valid,
  output logic        o_req_w_ready,
  input  wire  [31:0] i_req_w_data,
  input  wire  [3:0]  i_req_w_strb,
  input  wire         i_req_w_last,

  // Write-response channel to the controller
  output logic        o_resp_b_valid,
  input  wire         i_resp_b_ready,
  output logic [2:0]  o_resp_b_id,
  output logic [1:0]  o_resp_b_sts,

  // Read-address request channel from the controller
  input  wire         i_req_ar_valid,
  output logic        o_req_ar_ready,
  input  wire  [2:0]  i_req_ar_id,
  input  wire  [31:0] i_req_ar_addr,
  input  wire  [7:0]  i_req_ar_len,
  input  wire  [2:0]  i_req_ar_size,
  input  wire  [1:0]  i_req_ar_burst,
  input  wire  [3:0]  i_req_ar_cache,
  input  wire  [2:0]  i_req_ar_prot,

  // Read-response channel to the controller
  output logic        o_resp_r_valid,
  input  wire         i_resp_r_ready,
  output logic [2:0]  o_resp_r_id,
  output logic [31:0] o_resp_r_data,
  output logic [1:0]  o_resp_r_sts,
  output logic        o_resp_r_last
);

  // AXI requests map directly from the controller and remain independent of READY.
  assign o_axi_awid    = i_req_aw_id;
  assign o_axi_awaddr  = i_req_aw_addr;
  assign o_axi_awlen   = i_req_aw_len;
  assign o_axi_awsize  = i_req_aw_size;
  assign o_axi_awburst = i_req_aw_burst;
  assign o_axi_awlock  = 1'b0;
  assign o_axi_awcache = i_req_aw_cache;
  assign o_axi_awprot  = i_req_aw_prot;
  assign o_axi_awvalid = i_rst_n_core & i_req_aw_valid;

  // Write-data mapping forwards the controller payload unchanged.
  assign o_axi_wdata  = i_req_w_data;
  assign o_axi_wstrb  = i_req_w_strb;
  assign o_axi_wlast  = i_req_w_last;
  assign o_axi_wvalid = i_rst_n_core & i_req_w_valid;

  // Read-address mapping forwards the controller payload unchanged.
  assign o_axi_arid    = i_req_ar_id;
  assign o_axi_araddr  = i_req_ar_addr;
  assign o_axi_arlen   = i_req_ar_len;
  assign o_axi_arsize  = i_req_ar_size;
  assign o_axi_arburst = i_req_ar_burst;
  assign o_axi_arlock  = 1'b0;
  assign o_axi_arcache = i_req_ar_cache;
  assign o_axi_arprot  = i_req_ar_prot;
  assign o_axi_arvalid = i_rst_n_core & i_req_ar_valid;

  // READY and response signals map from AXI pins to the controller's handshake channels.
  assign o_req_aw_ready = i_axi_awready;
  assign o_req_w_ready  = i_axi_wready;
  assign o_req_ar_ready = i_axi_arready;
  assign o_axi_bready   = i_rst_n_core & i_resp_b_ready;
  assign o_resp_b_valid = i_rst_n_core & i_axi_bvalid;
  assign o_resp_b_id    = i_axi_bid;
  assign o_resp_b_sts = i_axi_bresp;
  assign o_axi_rready   = i_rst_n_core & i_resp_r_ready;
  assign o_resp_r_valid = i_rst_n_core & i_axi_rvalid;
  assign o_resp_r_id    = i_axi_rid;
  assign o_resp_r_data  = i_axi_rdata;
  assign o_resp_r_sts = i_axi_rresp;
  assign o_resp_r_last  = i_axi_rlast;

endmodule
