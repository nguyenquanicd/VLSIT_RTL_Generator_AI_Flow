/*
 * Project      : VLSIT Common RTL library
 * Author       : Nguyen Quan and Claude Sonnet 5.5 (user)
 * AI Flow      : VLSIT RTL Generator AI Automation Flow
 * AI Flow Page : https://github.com/nguyenquanicd/VLSIT_RTL_Generator_AI_Model
 * Date         : 2026-10-28
 * Description  : Top module of the AXI4 upsizer: connects a narrow subordinate (S) side to a wide
 *                manager (M) side with PARA_AXI_M_DATA_W larger than PARA_AXI_S_DATA_W. It
 *                instantiates the write path m_vlsit_ups_wr_path and the read path
 *                m_vlsit_ups_rd_path of rtl/common and tie cells, nothing else. The AXI4 profile
 *                has AxQOS and AxREGION, a 1-bit AxLOCK and an 8-bit AxLEN, writes data in order
 *                and has no WID; PARA_AXI_ID_W is at most 32 because of the tie module. Every
 *                channel is registered (REQ-RTL-002). The inputs i_axi_wlast and i_axi_rlast are
 *                not used: the last beat is found from AxLEN.
 */
`timescale 1ns/1ps

module m_vlsit_axi4_upsizer #(
  // Parameter Description: data width of the subordinate side.
  // Parameter values: a power of 2 of 8 to 512; default is 32.
  // Parameter unit: bit
  parameter logic [31:0] PARA_AXI_S_DATA_W = 32,
  // Parameter Description: data width of the manager side. Larger than PARA_AXI_S_DATA_W.
  // Parameter values: a power of 2 of 16 to 1024; default is 128.
  // Parameter unit: bit
  parameter logic [31:0] PARA_AXI_M_DATA_W = 128,
  // Parameter Description: width of the AXI address fields.
  // Parameter values: 12 to 64; default is 32.
  // Parameter unit: bit
  parameter logic [31:0] PARA_AXI_ADDR_W = 32,
  // Parameter Description: width of the AXI ID fields.
  // Parameter values: 1 or more; default is 4.
  // Parameter unit: bit
  parameter logic [31:0] PARA_AXI_ID_W = 4,
  // Parameter Description: number of write transactions in flight (depth of the write queue).
  // Parameter values: a power of 2 of 2 or more; default is 4.
  // Parameter unit: count
  parameter logic [31:0] PARA_AXI_WR_OUTSTANDING_DEPTH = 4,
  // Parameter Description: number of read transactions in flight (depth of the read queue).
  // Parameter values: a power of 2 of 2 or more; default is 4.
  // Parameter unit: count
  parameter logic [31:0] PARA_AXI_RD_OUTSTANDING_DEPTH = 4,
  localparam logic [31:0] LPARA_AXI_LEN_W = 8,
  localparam logic [31:0] LPARA_AXI_LOCK_W = 1,
  localparam logic [31:0] LPARA_WR_INTERLEAVE_EN = 0
) (
  // Clock and reset
  input  wire                              i_clk_axi,
  input  wire                              i_rst_n_axi,

  // Subordinate side AW channel
  input  wire                              i_axi_awvalid,
  input  wire  [PARA_AXI_ID_W-1:0]         i_axi_awid,
  input  wire  [PARA_AXI_ADDR_W-1:0]       i_axi_awaddr,
  input  wire  [7:0]                       i_axi_awlen,
  input  wire  [2:0]                       i_axi_awsize,
  input  wire  [1:0]                       i_axi_awburst,
  input  wire                              i_axi_awlock,
  input  wire  [3:0]                       i_axi_awcache,
  input  wire  [2:0]                       i_axi_awprot,
  input  wire  [3:0]                       i_axi_awqos,
  input  wire  [3:0]                       i_axi_awregion,
  output logic                             o_axi_awready,

  // Subordinate side W channel
  input  wire                              i_axi_wvalid,
  input  wire  [PARA_AXI_S_DATA_W-1:0]     i_axi_wdata,
  input  wire  [(PARA_AXI_S_DATA_W/8)-1:0] i_axi_wstrb,
  input  wire                              i_axi_wlast,
  output logic                             o_axi_wready,

  // Subordinate side B channel
  output logic                             o_axi_bvalid,
  output logic [PARA_AXI_ID_W-1:0]         o_axi_bid,
  output logic [1:0]                       o_axi_bresp,
  input  wire                              i_axi_bready,

  // Subordinate side AR channel
  input  wire                              i_axi_arvalid,
  input  wire  [PARA_AXI_ID_W-1:0]         i_axi_arid,
  input  wire  [PARA_AXI_ADDR_W-1:0]       i_axi_araddr,
  input  wire  [7:0]                       i_axi_arlen,
  input  wire  [2:0]                       i_axi_arsize,
  input  wire  [1:0]                       i_axi_arburst,
  input  wire                              i_axi_arlock,
  input  wire  [3:0]                       i_axi_arcache,
  input  wire  [2:0]                       i_axi_arprot,
  input  wire  [3:0]                       i_axi_arqos,
  input  wire  [3:0]                       i_axi_arregion,
  output logic                             o_axi_arready,

  // Subordinate side R channel
  output logic                             o_axi_rvalid,
  output logic [PARA_AXI_ID_W-1:0]         o_axi_rid,
  output logic [PARA_AXI_S_DATA_W-1:0]     o_axi_rdata,
  output logic [1:0]                       o_axi_rresp,
  output logic                             o_axi_rlast,
  input  wire                              i_axi_rready,

  // Manager side AW channel
  output logic                             o_axi_awvalid,
  output logic [PARA_AXI_ID_W-1:0]         o_axi_awid,
  output logic [PARA_AXI_ADDR_W-1:0]       o_axi_awaddr,
  output logic [7:0]                       o_axi_awlen,
  output logic [2:0]                       o_axi_awsize,
  output logic [1:0]                       o_axi_awburst,
  output logic                             o_axi_awlock,
  output logic [3:0]                       o_axi_awcache,
  output logic [2:0]                       o_axi_awprot,
  output logic [3:0]                       o_axi_awqos,
  output logic [3:0]                       o_axi_awregion,
  input  wire                              i_axi_awready,

  // Manager side W channel
  output logic                             o_axi_wvalid,
  output logic [PARA_AXI_M_DATA_W-1:0]     o_axi_wdata,
  output logic [(PARA_AXI_M_DATA_W/8)-1:0] o_axi_wstrb,
  output logic                             o_axi_wlast,
  input  wire                              i_axi_wready,

  // Manager side B channel
  input  wire                              i_axi_bvalid,
  input  wire  [PARA_AXI_ID_W-1:0]         i_axi_bid,
  input  wire  [1:0]                       i_axi_bresp,
  output logic                             o_axi_bready,

  // Manager side AR channel
  output logic                             o_axi_arvalid,
  output logic [PARA_AXI_ID_W-1:0]         o_axi_arid,
  output logic [PARA_AXI_ADDR_W-1:0]       o_axi_araddr,
  output logic [7:0]                       o_axi_arlen,
  output logic [2:0]                       o_axi_arsize,
  output logic [1:0]                       o_axi_arburst,
  output logic                             o_axi_arlock,
  output logic [3:0]                       o_axi_arcache,
  output logic [2:0]                       o_axi_arprot,
  output logic [3:0]                       o_axi_arqos,
  output logic [3:0]                       o_axi_arregion,
  input  wire                              i_axi_arready,

  // Manager side R channel
  input  wire                              i_axi_rvalid,
  input  wire  [PARA_AXI_ID_W-1:0]         i_axi_rid,
  input  wire  [PARA_AXI_M_DATA_W-1:0]     i_axi_rdata,
  input  wire  [1:0]                       i_axi_rresp,
  input  wire                              i_axi_rlast,
  output logic                             o_axi_rready
);
  // Internal signal declarations
  logic [PARA_AXI_ID_W-1:0] w_tie_wid;

  // AXI4 has no WID: the WID input of the shared write path is tied to 0 and its output is
  // not used.
  m_vlsit_tie #(
    .PARA_TIE_WIDTH (PARA_AXI_ID_W),
    .PARA_TIE_VALUE (32'd0)
  ) u_tie_wid (
    .o_tie (w_tie_wid)
  );

  // Write path: AW, W and B channels.
  m_vlsit_ups_wr_path #(
    .PARA_AXI_S_DATA_W             (PARA_AXI_S_DATA_W),
    .PARA_AXI_M_DATA_W             (PARA_AXI_M_DATA_W),
    .PARA_AXI_ADDR_W               (PARA_AXI_ADDR_W),
    .PARA_AXI_ID_W                 (PARA_AXI_ID_W),
    .PARA_AXI_LEN_W                (LPARA_AXI_LEN_W),
    .PARA_AXI_LOCK_W               (LPARA_AXI_LOCK_W),
    .PARA_AXI_WR_OUTSTANDING_DEPTH (PARA_AXI_WR_OUTSTANDING_DEPTH),
    .PARA_AXI_WR_INTERLEAVE_EN     (LPARA_WR_INTERLEAVE_EN),
    .PARA_AXI_WR_INTERLEAVE_DEPTH  (1)
  ) u_wr_path (
    .i_clk_axi   (i_clk_axi),
    .i_rst_n_axi (i_rst_n_axi),
    .i_s_aw_valid  (i_axi_awvalid),
    .i_s_aw_id     (i_axi_awid),
    .i_s_aw_addr   (i_axi_awaddr),
    .i_s_aw_len    (i_axi_awlen),
    .i_s_aw_size   (i_axi_awsize),
    .i_s_aw_burst  (i_axi_awburst),
    .i_s_aw_lock   (i_axi_awlock),
    .i_s_aw_cache  (i_axi_awcache),
    .i_s_aw_prot   (i_axi_awprot),
    .i_s_aw_qos    (i_axi_awqos),
    .i_s_aw_region (i_axi_awregion),
    .o_s_aw_ready  (o_axi_awready),
    .o_m_aw_valid  (o_axi_awvalid),
    .o_m_aw_id     (o_axi_awid),
    .o_m_aw_addr   (o_axi_awaddr),
    .o_m_aw_len    (o_axi_awlen),
    .o_m_aw_size   (o_axi_awsize),
    .o_m_aw_burst  (o_axi_awburst),
    .o_m_aw_lock   (o_axi_awlock),
    .o_m_aw_cache  (o_axi_awcache),
    .o_m_aw_prot   (o_axi_awprot),
    .o_m_aw_qos    (o_axi_awqos),
    .o_m_aw_region (o_axi_awregion),
    .i_m_aw_ready  (i_axi_awready),
    .i_s_w_valid   (i_axi_wvalid),
    .i_s_w_id      (w_tie_wid),
    .i_s_w_data    (i_axi_wdata),
    .i_s_w_strb    (i_axi_wstrb),
    .o_s_w_ready   (o_axi_wready),
    .o_s_b_valid   (o_axi_bvalid),
    .o_s_b_id      (o_axi_bid),
    .o_s_b_resp    (o_axi_bresp),
    .i_s_b_ready   (i_axi_bready),
    .o_m_w_valid   (o_axi_wvalid),
    .o_m_w_id      (),
    .o_m_w_data    (o_axi_wdata),
    .o_m_w_strb    (o_axi_wstrb),
    .o_m_w_last    (o_axi_wlast),
    .i_m_w_ready   (i_axi_wready),
    .i_m_b_valid   (i_axi_bvalid),
    .i_m_b_id      (i_axi_bid),
    .i_m_b_resp    (i_axi_bresp),
    .o_m_b_ready   (o_axi_bready)
  );

  // Read path: AR and R channels.
  m_vlsit_ups_rd_path #(
    .PARA_AXI_S_DATA_W             (PARA_AXI_S_DATA_W),
    .PARA_AXI_M_DATA_W             (PARA_AXI_M_DATA_W),
    .PARA_AXI_ADDR_W               (PARA_AXI_ADDR_W),
    .PARA_AXI_ID_W                 (PARA_AXI_ID_W),
    .PARA_AXI_LEN_W                (LPARA_AXI_LEN_W),
    .PARA_AXI_LOCK_W               (LPARA_AXI_LOCK_W),
    .PARA_AXI_RD_OUTSTANDING_DEPTH (PARA_AXI_RD_OUTSTANDING_DEPTH)
  ) u_rd_path (
    .i_clk_axi   (i_clk_axi),
    .i_rst_n_axi (i_rst_n_axi),
    .i_s_ar_valid  (i_axi_arvalid),
    .i_s_ar_id     (i_axi_arid),
    .i_s_ar_addr   (i_axi_araddr),
    .i_s_ar_len    (i_axi_arlen),
    .i_s_ar_size   (i_axi_arsize),
    .i_s_ar_burst  (i_axi_arburst),
    .i_s_ar_lock   (i_axi_arlock),
    .i_s_ar_cache  (i_axi_arcache),
    .i_s_ar_prot   (i_axi_arprot),
    .i_s_ar_qos    (i_axi_arqos),
    .i_s_ar_region (i_axi_arregion),
    .o_s_ar_ready  (o_axi_arready),
    .o_m_ar_valid  (o_axi_arvalid),
    .o_m_ar_id     (o_axi_arid),
    .o_m_ar_addr   (o_axi_araddr),
    .o_m_ar_len    (o_axi_arlen),
    .o_m_ar_size   (o_axi_arsize),
    .o_m_ar_burst  (o_axi_arburst),
    .o_m_ar_lock   (o_axi_arlock),
    .o_m_ar_cache  (o_axi_arcache),
    .o_m_ar_prot   (o_axi_arprot),
    .o_m_ar_qos    (o_axi_arqos),
    .o_m_ar_region (o_axi_arregion),
    .i_m_ar_ready  (i_axi_arready),
    .o_s_r_valid   (o_axi_rvalid),
    .o_s_r_id      (o_axi_rid),
    .o_s_r_data    (o_axi_rdata),
    .o_s_r_resp    (o_axi_rresp),
    .o_s_r_last    (o_axi_rlast),
    .i_s_r_ready   (i_axi_rready),
    .i_m_r_valid   (i_axi_rvalid),
    .i_m_r_id      (i_axi_rid),
    .i_m_r_data    (i_axi_rdata),
    .i_m_r_resp    (i_axi_rresp),
    .o_m_r_ready   (o_axi_rready)
  );

endmodule
