/*
 * Project      : VLSIT Common RTL library
 * Author       : Nguyen Quan and Claude Sonnet 5.5 (user)
 * AI Flow      : VLSIT RTL Generator AI Automation Flow
 * AI Flow Page : https://github.com/nguyenquanicd/VLSIT_RTL_Generator_AI_Model
 * Date         : 2026-10-25
 * Description  : Structural top-level AXI4-to-APB4 bridge with one shared clock domain.
 */
`timescale 1ns/1ps

module m_axi2apb_bridge #(
  // Parameter Description: Shared width of AXI read and write transaction IDs.
  // Parameter values: 1 through 16 inclusive; default is 4.
  // Parameter unit: bit
  parameter logic [31:0] PARA_AXI_ID_W = 32'd4
) (
  // Shared clock and synchronous reset
  input  wire                      i_clk_axi,
  input  wire                      i_rst_n_axi,

  // AXI write address channel
  input  wire  [PARA_AXI_ID_W-1:0] i_axi_awid,
  input  wire  [31:0]              i_axi_awaddr,
  input  wire  [7:0]               i_axi_awlen,
  input  wire  [2:0]               i_axi_awsize,
  input  wire  [1:0]               i_axi_awburst,
  input  wire  [3:0]               i_axi_awcache,
  input  wire  [2:0]               i_axi_awprot,
  input  wire                      i_axi_awvalid,
  output logic                     o_axi_awready,

  // AXI write data and response channels
  input  wire  [31:0]              i_axi_wdata,
  input  wire  [3:0]               i_axi_wstrb,
  input  wire                      i_axi_wlast,
  input  wire                      i_axi_wvalid,
  output logic                     o_axi_wready,
  output logic [PARA_AXI_ID_W-1:0] o_axi_bid,
  output logic [1:0]               o_axi_bresp,
  output logic                     o_axi_bvalid,
  input  wire                      i_axi_bready,

  // AXI read address channel
  input  wire  [PARA_AXI_ID_W-1:0] i_axi_arid,
  input  wire  [31:0]              i_axi_araddr,
  input  wire  [7:0]               i_axi_arlen,
  input  wire  [2:0]               i_axi_arsize,
  input  wire  [1:0]               i_axi_arburst,
  input  wire  [3:0]               i_axi_arcache,
  input  wire  [2:0]               i_axi_arprot,
  input  wire                      i_axi_arvalid,
  output logic                     o_axi_arready,

  // AXI read response channel
  output logic [PARA_AXI_ID_W-1:0] o_axi_rid,
  output logic [31:0]              o_axi_rdata,
  output logic [1:0]               o_axi_rresp,
  output logic                     o_axi_rlast,
  output logic                     o_axi_rvalid,
  input  wire                      i_axi_rready,

  // APB4 Manager interface
  output logic [31:0]              o_apb_paddr,
  output logic                     o_apb_pwrite,
  output logic [31:0]              o_apb_pwdata,
  output logic [3:0]               o_apb_pstrb,
  output logic [2:0]               o_apb_pprot,
  output logic                     o_apb_psel,
  output logic                     o_apb_penable,
  input  wire                      i_apb_pready,
  input  wire  [31:0]              i_apb_prdata,
  input  wire                      i_apb_pslverr
);

  // Read sequencer and shared controller interface.
  logic w_gnt_rd;
  logic w_rd_ready;
  logic w_rd_done;
  logic w_rd_req_valid;
  logic [31:0] w_rd_req_addr;
  logic [2:0] w_rd_req_prot;
  logic w_rd_req_ready;
  logic w_rd_rsp_valid;
  logic [31:0] w_rd_rsp_data;
  logic w_rd_rsp_err;

  // Write sequencer and shared controller interface.
  logic w_gnt_wr;
  logic w_wr_ready;
  logic w_wr_done;
  logic w_wr_req_valid;
  logic [31:0] w_wr_req_addr;
  logic [31:0] w_wr_req_data;
  logic [3:0] w_wr_req_strb;
  logic [2:0] w_wr_req_prot;
  logic w_wr_req_ready;
  logic w_wr_rsp_valid;
  logic w_wr_rsp_err;

  // Read sequencer converts each AXI beat to one APB read.
  m_axi2apb_rd_seq #(
    .PARA_AXI_ID_W (PARA_AXI_ID_W)
  ) u_axi2apb_rd_seq (
    .i_clk_axi       (i_clk_axi),
    .i_rst_n_axi     (i_rst_n_axi),
    .i_gnt_rd        (w_gnt_rd),
    .o_rd_ready      (w_rd_ready),
    .o_rd_done       (w_rd_done),
    .i_axi_arid      (i_axi_arid),
    .i_axi_araddr    (i_axi_araddr),
    .i_axi_arlen     (i_axi_arlen),
    .i_axi_arsize    (i_axi_arsize),
    .i_axi_arburst   (i_axi_arburst),
    .i_axi_arcache   (i_axi_arcache),
    .i_axi_arprot    (i_axi_arprot),
    .i_axi_arvalid   (i_axi_arvalid),
    .o_axi_arready   (o_axi_arready),
    .i_axi_rready    (i_axi_rready),
    .o_axi_rid       (o_axi_rid),
    .o_axi_rdata     (o_axi_rdata),
    .o_axi_rresp     (o_axi_rresp),
    .o_axi_rlast     (o_axi_rlast),
    .o_axi_rvalid    (o_axi_rvalid),
    .o_req_valid     (w_rd_req_valid),
    .o_req_addr      (w_rd_req_addr),
    .o_req_prot      (w_rd_req_prot),
    .i_req_ready     (w_rd_req_ready),
    .i_rsp_valid     (w_rd_rsp_valid),
    .i_rsp_data      (w_rd_rsp_data),
    .i_rsp_err       (w_rd_rsp_err)
  );

  // Write sequencer converts each AXI beat to one APB write.
  m_axi2apb_wr_seq #(
    .PARA_AXI_ID_W (PARA_AXI_ID_W)
  ) u_axi2apb_wr_seq (
    .i_clk_axi       (i_clk_axi),
    .i_rst_n_axi     (i_rst_n_axi),
    .i_gnt_wr        (w_gnt_wr),
    .o_wr_ready      (w_wr_ready),
    .o_wr_done       (w_wr_done),
    .i_axi_awid      (i_axi_awid),
    .i_axi_awaddr    (i_axi_awaddr),
    .i_axi_awlen     (i_axi_awlen),
    .i_axi_awsize    (i_axi_awsize),
    .i_axi_awburst   (i_axi_awburst),
    .i_axi_awcache   (i_axi_awcache),
    .i_axi_awprot    (i_axi_awprot),
    .i_axi_awvalid   (i_axi_awvalid),
    .o_axi_awready   (o_axi_awready),
    .i_axi_wdata     (i_axi_wdata),
    .i_axi_wstrb     (i_axi_wstrb),
    .i_axi_wvalid    (i_axi_wvalid),
    .o_axi_wready    (o_axi_wready),
    .o_axi_bid       (o_axi_bid),
    .o_axi_bresp      (o_axi_bresp),
    .o_axi_bvalid    (o_axi_bvalid),
    .i_axi_bready    (i_axi_bready),
    .o_req_valid     (w_wr_req_valid),
    .o_req_addr      (w_wr_req_addr),
    .o_req_data      (w_wr_req_data),
    .o_req_strb      (w_wr_req_strb),
    .o_req_prot      (w_wr_req_prot),
    .i_req_ready     (w_wr_req_ready),
    .i_rsp_valid     (w_wr_rsp_valid),
    .i_rsp_err       (w_wr_rsp_err)
  );

  // Shared controller arbitrates AXI ownership and performs APB setup/access transfers.
  m_axi2apb_apb_ctrl u_axi2apb_apb_ctrl (
    .i_clk_axi       (i_clk_axi),
    .i_rst_n_axi     (i_rst_n_axi),
    .i_axi_arvalid   (i_axi_arvalid),
    .i_axi_awvalid   (i_axi_awvalid),
    .i_rd_ready      (w_rd_ready),
    .i_wr_ready      (w_wr_ready),
    .i_rd_done       (w_rd_done),
    .i_wr_done       (w_wr_done),
    .o_gnt_rd        (w_gnt_rd),
    .o_gnt_wr        (w_gnt_wr),
    .i_rd_req_valid  (w_rd_req_valid),
    .i_rd_req_addr   (w_rd_req_addr),
    .i_rd_req_prot   (w_rd_req_prot),
    .o_rd_req_ready  (w_rd_req_ready),
    .o_rd_rsp_valid  (w_rd_rsp_valid),
    .o_rd_rsp_data   (w_rd_rsp_data),
    .o_rd_rsp_err    (w_rd_rsp_err),
    .i_wr_req_valid  (w_wr_req_valid),
    .i_wr_req_addr   (w_wr_req_addr),
    .i_wr_req_data   (w_wr_req_data),
    .i_wr_req_strb   (w_wr_req_strb),
    .i_wr_req_prot   (w_wr_req_prot),
    .o_wr_req_ready  (w_wr_req_ready),
    .o_wr_rsp_valid  (w_wr_rsp_valid),
    .o_wr_rsp_err    (w_wr_rsp_err),
    .i_apb_pready    (i_apb_pready),
    .i_apb_prdata    (i_apb_prdata),
    .i_apb_pslverr   (i_apb_pslverr),
    .o_apb_paddr     (o_apb_paddr),
    .o_apb_pwrite    (o_apb_pwrite),
    .o_apb_pwdata    (o_apb_pwdata),
    .o_apb_pstrb     (o_apb_pstrb),
    .o_apb_pprot     (o_apb_pprot),
    .o_apb_psel      (o_apb_psel),
    .o_apb_penable   (o_apb_penable)
  );

endmodule
