/*
 * Project      : HyperRAM Controller
 * Author       : Nguyen Quan (user)
 * AI Flow      : VLSIT RTL Generator AI Automation Flow
 * AI Flow Page : https://github.com/nguyenquanicd/VLSIT_RTL_Generator_AI_Model
 * Date         : 2026-10-31
 * Description  : AXI4 clock-domain crossing point (CDC-004, DEC-035). With PARA_AXI_CLK_ASYNC = 0
 *                the AXI pins and the frontend share the core clock and the five channels are
 *                wired through. With 1 the library bridge m_vlsit_async_axi4_bridge of
 *                003_AsyncAXI4Bridge crosses all five channels between i_clk_axi (pin side,
 *                subordinate) and i_clk_core (frontend side, manager). The signals that this IP
 *                does not use (LOCK, CACHE, PROT, QOS, REGION) are tied to zero at the bridge.
 *                The ports i_clk_axi and i_rst_n_axi are not used when PARA_AXI_CLK_ASYNC = 0.
 */
`timescale 1ns/1ps

module m_vlsit_axi4_cdc #(
  // Parameter Description: selects the AXI clock relation. 0 = the AXI clock is the core clock and
  // the channels are wired through; 1 = the AXI clock is asynchronous and the channels cross
  // through the asynchronous AXI4 bridge.
  // Parameter values: 0 or 1; default is 0.
  // Parameter unit: none
  parameter logic [31:0] PARA_AXI_CLK_ASYNC = 32'd0,
  // Parameter Description: width of the AXI data bus; the strobe width follows it.
  // Parameter values: 32 or 64; default is 32.
  // Parameter unit: bit
  parameter logic [31:0] PARA_AXI_DATA_W = 32'd32,
  localparam logic [31:0] LPARA_AXI_ADDR_W = 32'd32,
  localparam logic [31:0] LPARA_AXI_ID_W   = 32'd4,
  localparam logic [31:0] LPARA_AXI_LEN_W  = 32'd8,
  localparam logic [31:0] LPARA_AXI_STRB_W = PARA_AXI_DATA_W / 32'd8
) (
  // AXI clock and reset (pin side)
  input  wire                         i_clk_axi,
  input  wire                         i_rst_n_axi,

  // Core clock and reset (frontend side)
  input  wire                         i_clk_core,
  input  wire                         i_rst_n_core,

  // Pin side AW channel
  input  wire                         i_axi_awvalid,
  output logic                        o_axi_awready,
  input  wire  [LPARA_AXI_ID_W-1:0]   i_axi_awid,
  input  wire  [LPARA_AXI_ADDR_W-1:0] i_axi_awaddr,
  input  wire  [LPARA_AXI_LEN_W-1:0]  i_axi_awlen,
  input  wire  [2:0]                  i_axi_awsize,
  input  wire  [1:0]                  i_axi_awburst,

  // Frontend side AW channel
  output logic                        o_axi_awvalid,
  input  wire                         i_axi_awready,
  output logic [LPARA_AXI_ID_W-1:0]   o_axi_awid,
  output logic [LPARA_AXI_ADDR_W-1:0] o_axi_awaddr,
  output logic [LPARA_AXI_LEN_W-1:0]  o_axi_awlen,
  output logic [2:0]                  o_axi_awsize,
  output logic [1:0]                  o_axi_awburst,

  // Pin side W channel
  input  wire                         i_axi_wvalid,
  output logic                        o_axi_wready,
  input  wire  [PARA_AXI_DATA_W-1:0]  i_axi_wdata,
  input  wire  [LPARA_AXI_STRB_W-1:0] i_axi_wstrb,
  input  wire                         i_axi_wlast,

  // Frontend side W channel
  output logic                        o_axi_wvalid,
  input  wire                         i_axi_wready,
  output logic [PARA_AXI_DATA_W-1:0]  o_axi_wdata,
  output logic [LPARA_AXI_STRB_W-1:0] o_axi_wstrb,
  output logic                        o_axi_wlast,

  // Frontend side B channel
  input  wire                         i_axi_bvalid,
  output logic                        o_axi_bready,
  input  wire  [LPARA_AXI_ID_W-1:0]   i_axi_bid,
  input  wire  [1:0]                  i_axi_bresp,

  // Pin side B channel
  output logic                        o_axi_bvalid,
  input  wire                         i_axi_bready,
  output logic [LPARA_AXI_ID_W-1:0]   o_axi_bid,
  output logic [1:0]                  o_axi_bresp,

  // Pin side AR channel
  input  wire                         i_axi_arvalid,
  output logic                        o_axi_arready,
  input  wire  [LPARA_AXI_ID_W-1:0]   i_axi_arid,
  input  wire  [LPARA_AXI_ADDR_W-1:0] i_axi_araddr,
  input  wire  [LPARA_AXI_LEN_W-1:0]  i_axi_arlen,
  input  wire  [2:0]                  i_axi_arsize,
  input  wire  [1:0]                  i_axi_arburst,

  // Frontend side AR channel
  output logic                        o_axi_arvalid,
  input  wire                         i_axi_arready,
  output logic [LPARA_AXI_ID_W-1:0]   o_axi_arid,
  output logic [LPARA_AXI_ADDR_W-1:0] o_axi_araddr,
  output logic [LPARA_AXI_LEN_W-1:0]  o_axi_arlen,
  output logic [2:0]                  o_axi_arsize,
  output logic [1:0]                  o_axi_arburst,

  // Frontend side R channel
  input  wire                         i_axi_rvalid,
  output logic                        o_axi_rready,
  input  wire  [LPARA_AXI_ID_W-1:0]   i_axi_rid,
  input  wire  [PARA_AXI_DATA_W-1:0]  i_axi_rdata,
  input  wire  [1:0]                  i_axi_rresp,
  input  wire                         i_axi_rlast,

  // Pin side R channel
  output logic                        o_axi_rvalid,
  input  wire                         i_axi_rready,
  output logic [LPARA_AXI_ID_W-1:0]   o_axi_rid,
  output logic [PARA_AXI_DATA_W-1:0]  o_axi_rdata,
  output logic [1:0]                  o_axi_rresp,
  output logic                        o_axi_rlast
);

  // Crossing selection: the bridge when the AXI clock is asynchronous, plain wires otherwise.
  if (PARA_AXI_CLK_ASYNC == 32'd1) begin : gen_async
    // Asynchronous AXI clock: one FIFO per channel inside the library bridge. The pin side is
    // its subordinate side, the frontend side is its manager side; the unused sideband signals
    // are tied to zero and their outputs are left open.
    m_vlsit_async_axi4_bridge #(
      .PARA_AXI_ADDR_W (LPARA_AXI_ADDR_W),
      .PARA_AXI_DATA_W (PARA_AXI_DATA_W),
      .PARA_AXI_ID_W   (LPARA_AXI_ID_W)
    ) u_vlsit_async_axi4_bridge (
      .i_clk_sub      (i_clk_axi),
      .i_rst_n_sub    (i_rst_n_axi),
      .i_clk_mgr      (i_clk_core),
      .i_rst_n_mgr    (i_rst_n_core),

      .i_axi_awvalid  (i_axi_awvalid),
      .o_axi_awready  (o_axi_awready),
      .i_axi_awid     (i_axi_awid),
      .i_axi_awaddr   (i_axi_awaddr),
      .i_axi_awlen    (i_axi_awlen),
      .i_axi_awsize   (i_axi_awsize),
      .i_axi_awburst  (i_axi_awburst),
      .i_axi_awlock   (1'b0),
      .i_axi_awcache  (4'd0),
      .i_axi_awprot   (3'd0),
      .i_axi_awqos    (4'd0),
      .i_axi_awregion (4'd0),

      .o_axi_awvalid  (o_axi_awvalid),
      .i_axi_awready  (i_axi_awready),
      .o_axi_awid     (o_axi_awid),
      .o_axi_awaddr   (o_axi_awaddr),
      .o_axi_awlen    (o_axi_awlen),
      .o_axi_awsize   (o_axi_awsize),
      .o_axi_awburst  (o_axi_awburst),
      .o_axi_awlock   (),
      .o_axi_awcache  (),
      .o_axi_awprot   (),
      .o_axi_awqos    (),
      .o_axi_awregion (),

      .i_axi_wvalid   (i_axi_wvalid),
      .o_axi_wready   (o_axi_wready),
      .i_axi_wdata    (i_axi_wdata),
      .i_axi_wstrb    (i_axi_wstrb),
      .i_axi_wlast    (i_axi_wlast),

      .o_axi_wvalid   (o_axi_wvalid),
      .i_axi_wready   (i_axi_wready),
      .o_axi_wdata    (o_axi_wdata),
      .o_axi_wstrb    (o_axi_wstrb),
      .o_axi_wlast    (o_axi_wlast),

      .i_axi_bvalid   (i_axi_bvalid),
      .o_axi_bready   (o_axi_bready),
      .i_axi_bid      (i_axi_bid),
      .i_axi_bresp    (i_axi_bresp),

      .o_axi_bvalid   (o_axi_bvalid),
      .i_axi_bready   (i_axi_bready),
      .o_axi_bid      (o_axi_bid),
      .o_axi_bresp    (o_axi_bresp),

      .i_axi_arvalid  (i_axi_arvalid),
      .o_axi_arready  (o_axi_arready),
      .i_axi_arid     (i_axi_arid),
      .i_axi_araddr   (i_axi_araddr),
      .i_axi_arlen    (i_axi_arlen),
      .i_axi_arsize   (i_axi_arsize),
      .i_axi_arburst  (i_axi_arburst),
      .i_axi_arlock   (1'b0),
      .i_axi_arcache  (4'd0),
      .i_axi_arprot   (3'd0),
      .i_axi_arqos    (4'd0),
      .i_axi_arregion (4'd0),

      .o_axi_arvalid  (o_axi_arvalid),
      .i_axi_arready  (i_axi_arready),
      .o_axi_arid     (o_axi_arid),
      .o_axi_araddr   (o_axi_araddr),
      .o_axi_arlen    (o_axi_arlen),
      .o_axi_arsize   (o_axi_arsize),
      .o_axi_arburst  (o_axi_arburst),
      .o_axi_arlock   (),
      .o_axi_arcache  (),
      .o_axi_arprot   (),
      .o_axi_arqos    (),
      .o_axi_arregion (),

      .i_axi_rvalid   (i_axi_rvalid),
      .o_axi_rready   (o_axi_rready),
      .i_axi_rid      (i_axi_rid),
      .i_axi_rdata    (i_axi_rdata),
      .i_axi_rresp    (i_axi_rresp),
      .i_axi_rlast    (i_axi_rlast),

      .o_axi_rvalid   (o_axi_rvalid),
      .i_axi_rready   (i_axi_rready),
      .o_axi_rid      (o_axi_rid),
      .o_axi_rdata    (o_axi_rdata),
      .o_axi_rresp    (o_axi_rresp),
      .o_axi_rlast    (o_axi_rlast)
    );
  end else begin : gen_sync
    // Same clock: the request channels AW, W and AR go to the frontend, the response channels B
    // and R come back, each with its ready or valid handshake line, without any logic.
    // Write address channel AW, wired through.
    assign o_axi_awvalid = i_axi_awvalid;
    assign o_axi_awready = i_axi_awready;
    assign o_axi_awid    = i_axi_awid;
    assign o_axi_awaddr  = i_axi_awaddr;
    assign o_axi_awlen   = i_axi_awlen;
    assign o_axi_awsize  = i_axi_awsize;
    assign o_axi_awburst = i_axi_awburst;

    // Write data channel W, wired through.
    assign o_axi_wvalid  = i_axi_wvalid;
    assign o_axi_wready  = i_axi_wready;
    assign o_axi_wdata   = i_axi_wdata;
    assign o_axi_wstrb   = i_axi_wstrb;
    assign o_axi_wlast   = i_axi_wlast;

    // Write response channel B, wired back to the pins.
    assign o_axi_bvalid  = i_axi_bvalid;
    assign o_axi_bready  = i_axi_bready;
    assign o_axi_bid     = i_axi_bid;
    assign o_axi_bresp   = i_axi_bresp;

    // Read address channel AR, wired through.
    assign o_axi_arvalid = i_axi_arvalid;
    assign o_axi_arready = i_axi_arready;
    assign o_axi_arid    = i_axi_arid;
    assign o_axi_araddr  = i_axi_araddr;
    assign o_axi_arlen   = i_axi_arlen;
    assign o_axi_arsize  = i_axi_arsize;
    assign o_axi_arburst = i_axi_arburst;

    // Read data channel R, wired back to the pins.
    assign o_axi_rvalid  = i_axi_rvalid;
    assign o_axi_rready  = i_axi_rready;
    assign o_axi_rid     = i_axi_rid;
    assign o_axi_rdata   = i_axi_rdata;
    assign o_axi_rresp   = i_axi_rresp;
    assign o_axi_rlast   = i_axi_rlast;
  end

endmodule
