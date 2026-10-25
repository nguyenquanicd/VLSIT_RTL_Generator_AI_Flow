`timescale 1ns/1ps
// Prototype of the asynchronous AXI bridge of AsyncAXI4Bridge_Design_Specification.md.
// It exists only to produce the waveforms of the specification. It is not the delivered RTL.
// Every channel is one asynchronous Gray FIFO of 001_AsyncGrayFIFO (m_vlsit_afifo_top). The payload is the
// concatenation of all fields of the channel; a field that is not enabled is forced to 0 at the input.
// The ports use the maximum widths (LEN 8 bits, LOCK 2 bits); AXI3 uses the low bits only.

module m_vlsit_axi_cdc_chan #(
  parameter logic [31:0] PARA_PLD_W = 8,
  parameter logic [31:0] PARA_DEPTH = 4,
  parameter logic [31:0] PARA_CELL_TYPE = 2,
  localparam logic [31:0] LPARA_PTR_W = $clog2(PARA_DEPTH) + 1
) (
  input  wire                   i_clk_src,
  input  wire                   i_rst_n_src,
  input  wire                   i_src_valid,
  output logic                  o_src_ready,
  input  wire  [PARA_PLD_W-1:0] i_src_pld,
  input  wire                   i_clk_dst,
  input  wire                   i_rst_n_dst,
  output logic                  o_dst_valid,
  input  wire                   i_dst_ready,
  output logic [PARA_PLD_W-1:0] o_dst_pld
);
  logic w_full, w_empty;
  logic [LPARA_PTR_W-1:0] w_full_thr, w_empty_thr;
  assign w_full_thr  = PARA_DEPTH[LPARA_PTR_W-1:0];
  assign w_empty_thr = '0;
  assign o_src_ready = ~w_full;
  assign o_dst_valid = ~w_empty;

  m_vlsit_afifo_top #(.PARA_AFIFO_DEPTH(PARA_DEPTH), .PARA_AFIFO_DATA_W(PARA_PLD_W),
                      .PARA_AFIFO_CELL_TYPE(PARA_CELL_TYPE), .PARA_AFIFO_MEM_USE_MACRO(0)) u_fifo (
    .i_clk_wr(i_clk_src), .i_rst_n_wr(i_rst_n_src), .i_wr_en(i_src_valid), .i_wr_data(i_src_pld),
    .i_full_thr(w_full_thr), .o_full(w_full), .o_full_thr(), .o_overflow(),
    .i_rst_n_sw(1'b1), .o_sw_rst_busy(),
    .i_clk_rd(i_clk_dst), .i_rst_n_rd(i_rst_n_dst), .i_rd_en(i_dst_ready), .i_empty_thr(w_empty_thr),
    .o_rd_data(o_dst_pld), .o_empty(w_empty), .o_empty_thr(), .o_underflow());
endmodule

module m_vlsit_axi_cdc_top #(
  parameter logic [31:0] PARA_AXI_ADDR_W = 16,
  parameter logic [31:0] PARA_AXI_DATA_W = 16,
  parameter logic [31:0] PARA_AXI_ID_W = 4,
  parameter logic [31:0] PARA_AXI_AXI3_EN = 0,
  parameter logic [31:0] PARA_AXI_QOS_EN = 1,
  parameter logic [31:0] PARA_AXI_REGION_EN = 1,
  parameter logic [31:0] PARA_AXI_AWUSER_W = 0,
  parameter logic [31:0] PARA_AXI_WUSER_W = 0,
  parameter logic [31:0] PARA_AXI_BUSER_W = 0,
  parameter logic [31:0] PARA_AXI_ARUSER_W = 0,
  parameter logic [31:0] PARA_AXI_RUSER_W = 0,
  parameter logic [31:0] PARA_AXI_AW_DEPTH = 4,
  parameter logic [31:0] PARA_AXI_W_DEPTH = 16,
  parameter logic [31:0] PARA_AXI_B_DEPTH = 4,
  parameter logic [31:0] PARA_AXI_AR_DEPTH = 4,
  parameter logic [31:0] PARA_AXI_R_DEPTH = 16,
  parameter logic [31:0] PARA_AXI_CELL_TYPE = 2,
  localparam logic [31:0] A = PARA_AXI_ADDR_W,
  localparam logic [31:0] D = PARA_AXI_DATA_W,
  localparam logic [31:0] I = PARA_AXI_ID_W,
  localparam logic [31:0] U1 = (PARA_AXI_AWUSER_W == 0) ? 1 : PARA_AXI_AWUSER_W,
  localparam logic [31:0] U2 = (PARA_AXI_WUSER_W == 0) ? 1 : PARA_AXI_WUSER_W,
  localparam logic [31:0] U3 = (PARA_AXI_BUSER_W == 0) ? 1 : PARA_AXI_BUSER_W,
  localparam logic [31:0] U4 = (PARA_AXI_ARUSER_W == 0) ? 1 : PARA_AXI_ARUSER_W,
  localparam logic [31:0] U5 = (PARA_AXI_RUSER_W == 0) ? 1 : PARA_AXI_RUSER_W,
  localparam logic [31:0] AW_W = I + A + 8 + 3 + 2 + 2 + 4 + 3 + 4 + 4 + U1,
  localparam logic [31:0] W_W  = I + D + D/8 + 1 + U2,
  localparam logic [31:0] B_W  = I + 2 + U3,
  localparam logic [31:0] AR_W = I + A + 8 + 3 + 2 + 2 + 4 + 3 + 4 + 4 + U4,
  localparam logic [31:0] R_W  = I + D + 2 + 1 + U5
) (
  input  wire i_clk_sub, input wire i_rst_n_sub, input wire i_clk_mgr, input wire i_rst_n_mgr,
  // subordinate-side interface
  input  wire i_axi_awvalid, output logic o_axi_awready,
  input  wire [I-1:0] i_axi_awid, input wire [A-1:0] i_axi_awaddr, input wire [7:0] i_axi_awlen,
  input  wire [2:0] i_axi_awsize, input wire [1:0] i_axi_awburst, input wire [1:0] i_axi_awlock,
  input  wire [3:0] i_axi_awcache, input wire [2:0] i_axi_awprot, input wire [3:0] i_axi_awqos,
  input  wire [3:0] i_axi_awregion, input wire [U1-1:0] i_axi_awuser,
  input  wire i_axi_wvalid, output logic o_axi_wready,
  input  wire [I-1:0] i_axi_wid, input wire [D-1:0] i_axi_wdata, input wire [D/8-1:0] i_axi_wstrb,
  input  wire i_axi_wlast, input wire [U2-1:0] i_axi_wuser,
  output logic o_axi_bvalid, input wire i_axi_bready,
  output logic [I-1:0] o_axi_bid, output logic [1:0] o_axi_bresp, output logic [U3-1:0] o_axi_buser,
  input  wire i_axi_arvalid, output logic o_axi_arready,
  input  wire [I-1:0] i_axi_arid, input wire [A-1:0] i_axi_araddr, input wire [7:0] i_axi_arlen,
  input  wire [2:0] i_axi_arsize, input wire [1:0] i_axi_arburst, input wire [1:0] i_axi_arlock,
  input  wire [3:0] i_axi_arcache, input wire [2:0] i_axi_arprot, input wire [3:0] i_axi_arqos,
  input  wire [3:0] i_axi_arregion, input wire [U4-1:0] i_axi_aruser,
  output logic o_axi_rvalid, input wire i_axi_rready,
  output logic [I-1:0] o_axi_rid, output logic [D-1:0] o_axi_rdata, output logic [1:0] o_axi_rresp,
  output logic o_axi_rlast, output logic [U5-1:0] o_axi_ruser,
  // manager-side interface (the port names differ from the subordinate side by direction)
  output logic o_axi_awvalid, input wire i_axi_awready,
  output logic [I-1:0] o_axi_awid, output logic [A-1:0] o_axi_awaddr, output logic [7:0] o_axi_awlen,
  output logic [2:0] o_axi_awsize, output logic [1:0] o_axi_awburst, output logic [1:0] o_axi_awlock,
  output logic [3:0] o_axi_awcache, output logic [2:0] o_axi_awprot, output logic [3:0] o_axi_awqos,
  output logic [3:0] o_axi_awregion, output logic [U1-1:0] o_axi_awuser,
  output logic o_axi_wvalid, input wire i_axi_wready,
  output logic [I-1:0] o_axi_wid, output logic [D-1:0] o_axi_wdata, output logic [D/8-1:0] o_axi_wstrb,
  output logic o_axi_wlast, output logic [U2-1:0] o_axi_wuser,
  input  wire i_axi_bvalid, output logic o_axi_bready,
  input  wire [I-1:0] i_axi_bid, input wire [1:0] i_axi_bresp, input wire [U3-1:0] i_axi_buser,
  output logic o_axi_arvalid, input wire i_axi_arready,
  output logic [I-1:0] o_axi_arid, output logic [A-1:0] o_axi_araddr, output logic [7:0] o_axi_arlen,
  output logic [2:0] o_axi_arsize, output logic [1:0] o_axi_arburst, output logic [1:0] o_axi_arlock,
  output logic [3:0] o_axi_arcache, output logic [2:0] o_axi_arprot, output logic [3:0] o_axi_arqos,
  output logic [3:0] o_axi_arregion, output logic [U4-1:0] o_axi_aruser,
  input  wire i_axi_rvalid, output logic o_axi_rready,
  input  wire [I-1:0] i_axi_rid, input wire [D-1:0] i_axi_rdata, input wire [1:0] i_axi_rresp,
  input  wire i_axi_rlast, input wire [U5-1:0] i_axi_ruser
);
  wire a3 = (PARA_AXI_AXI3_EN != 0);
  wire [3:0]    qos_en = (PARA_AXI_QOS_EN != 0 && !a3) ? 4'hF : 4'h0;
  wire [3:0]    reg_en = (PARA_AXI_REGION_EN != 0 && !a3) ? 4'hF : 4'h0;
  wire [U1-1:0] awu_en = (PARA_AXI_AWUSER_W != 0 && !a3) ? {U1{1'b1}} : {U1{1'b0}};
  wire [U2-1:0] wu_en  = (PARA_AXI_WUSER_W  != 0 && !a3) ? {U2{1'b1}} : {U2{1'b0}};
  wire [U3-1:0] bu_en  = (PARA_AXI_BUSER_W  != 0 && !a3) ? {U3{1'b1}} : {U3{1'b0}};
  wire [U4-1:0] aru_en = (PARA_AXI_ARUSER_W != 0 && !a3) ? {U4{1'b1}} : {U4{1'b0}};
  wire [U5-1:0] ru_en  = (PARA_AXI_RUSER_W  != 0 && !a3) ? {U5{1'b1}} : {U5{1'b0}};
  wire [I-1:0]  wid_in = a3 ? i_axi_wid : {I{1'b0}};
  wire [1:0] lock_aw = a3 ? i_axi_awlock : {1'b0, i_axi_awlock[0]};
  wire [1:0] lock_ar = a3 ? i_axi_arlock : {1'b0, i_axi_arlock[0]};
  wire [7:0] len_aw = a3 ? {4'b0, i_axi_awlen[3:0]} : i_axi_awlen;
  wire [7:0] len_ar = a3 ? {4'b0, i_axi_arlen[3:0]} : i_axi_arlen;

  m_vlsit_axi_cdc_chan #(.PARA_PLD_W(AW_W), .PARA_DEPTH(PARA_AXI_AW_DEPTH), .PARA_CELL_TYPE(PARA_AXI_CELL_TYPE)) u_aw (
    .i_clk_src(i_clk_sub), .i_rst_n_src(i_rst_n_sub), .i_src_valid(i_axi_awvalid), .o_src_ready(o_axi_awready),
    .i_src_pld({i_axi_awuser & awu_en, i_axi_awregion & reg_en, i_axi_awqos & qos_en, i_axi_awprot,
                i_axi_awcache, lock_aw, i_axi_awburst, i_axi_awsize, len_aw, i_axi_awaddr, i_axi_awid}),
    .i_clk_dst(i_clk_mgr), .i_rst_n_dst(i_rst_n_mgr), .o_dst_valid(o_axi_awvalid), .i_dst_ready(i_axi_awready),
    .o_dst_pld({o_axi_awuser, o_axi_awregion, o_axi_awqos, o_axi_awprot, o_axi_awcache, o_axi_awlock, o_axi_awburst,
                o_axi_awsize, o_axi_awlen, o_axi_awaddr, o_axi_awid}));
  m_vlsit_axi_cdc_chan #(.PARA_PLD_W(W_W), .PARA_DEPTH(PARA_AXI_W_DEPTH), .PARA_CELL_TYPE(PARA_AXI_CELL_TYPE)) u_w (
    .i_clk_src(i_clk_sub), .i_rst_n_src(i_rst_n_sub), .i_src_valid(i_axi_wvalid), .o_src_ready(o_axi_wready),
    .i_src_pld({i_axi_wuser & wu_en, i_axi_wlast, i_axi_wstrb, i_axi_wdata, wid_in}),
    .i_clk_dst(i_clk_mgr), .i_rst_n_dst(i_rst_n_mgr), .o_dst_valid(o_axi_wvalid), .i_dst_ready(i_axi_wready),
    .o_dst_pld({o_axi_wuser, o_axi_wlast, o_axi_wstrb, o_axi_wdata, o_axi_wid}));
  m_vlsit_axi_cdc_chan #(.PARA_PLD_W(B_W), .PARA_DEPTH(PARA_AXI_B_DEPTH), .PARA_CELL_TYPE(PARA_AXI_CELL_TYPE)) u_b (
    .i_clk_src(i_clk_mgr), .i_rst_n_src(i_rst_n_mgr), .i_src_valid(i_axi_bvalid), .o_src_ready(o_axi_bready),
    .i_src_pld({i_axi_buser & bu_en, i_axi_bresp, i_axi_bid}),
    .i_clk_dst(i_clk_sub), .i_rst_n_dst(i_rst_n_sub), .o_dst_valid(o_axi_bvalid), .i_dst_ready(i_axi_bready),
    .o_dst_pld({o_axi_buser, o_axi_bresp, o_axi_bid}));
  m_vlsit_axi_cdc_chan #(.PARA_PLD_W(AR_W), .PARA_DEPTH(PARA_AXI_AR_DEPTH), .PARA_CELL_TYPE(PARA_AXI_CELL_TYPE)) u_ar (
    .i_clk_src(i_clk_sub), .i_rst_n_src(i_rst_n_sub), .i_src_valid(i_axi_arvalid), .o_src_ready(o_axi_arready),
    .i_src_pld({i_axi_aruser & aru_en, i_axi_arregion & reg_en, i_axi_arqos & qos_en, i_axi_arprot,
                i_axi_arcache, lock_ar, i_axi_arburst, i_axi_arsize, len_ar, i_axi_araddr, i_axi_arid}),
    .i_clk_dst(i_clk_mgr), .i_rst_n_dst(i_rst_n_mgr), .o_dst_valid(o_axi_arvalid), .i_dst_ready(i_axi_arready),
    .o_dst_pld({o_axi_aruser, o_axi_arregion, o_axi_arqos, o_axi_arprot, o_axi_arcache, o_axi_arlock, o_axi_arburst,
                o_axi_arsize, o_axi_arlen, o_axi_araddr, o_axi_arid}));
  m_vlsit_axi_cdc_chan #(.PARA_PLD_W(R_W), .PARA_DEPTH(PARA_AXI_R_DEPTH), .PARA_CELL_TYPE(PARA_AXI_CELL_TYPE)) u_r (
    .i_clk_src(i_clk_mgr), .i_rst_n_src(i_rst_n_mgr), .i_src_valid(i_axi_rvalid), .o_src_ready(o_axi_rready),
    .i_src_pld({i_axi_ruser & ru_en, i_axi_rlast, i_axi_rresp, i_axi_rdata, i_axi_rid}),
    .i_clk_dst(i_clk_sub), .i_rst_n_dst(i_rst_n_sub), .o_dst_valid(o_axi_rvalid), .i_dst_ready(i_axi_rready),
    .o_dst_pld({o_axi_ruser, o_axi_rlast, o_axi_rresp, o_axi_rdata, o_axi_rid}));
endmodule
