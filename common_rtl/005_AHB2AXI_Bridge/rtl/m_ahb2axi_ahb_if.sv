/*
 * Project      : VLSIT Common RTL library
 * Author       : Nguyen Quan and Claude Sonnet 5.5 (user)
 * AI Flow      : VLSIT RTL Generator AI Automation Flow
 * AI Flow Page : https://github.com/nguyenquanicd/VLSIT_RTL_Generator_AI_Model
 * Date         : 2026-10-25
 * Description  : AHB5 subordinate boundary. It captures address-phase requests, forwards the
 *                matching write-data phase, and presents ordered bridge responses on AHB.
 */
`timescale 1ns/1ps

module m_ahb2axi_ahb_if (
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

  // Address-phase request channel to the controller
  output logic        o_req_valid,
  input  wire         i_req_ready,
  output logic [31:0] o_req_addr,
  output logic [1:0]  o_req_trans,
  output logic        o_req_wr,
  output logic [2:0]  o_req_size,
  output logic [2:0]  o_req_burst,
  output logic [6:0]  o_req_prot,
  output logic        o_req_nonsec,
  output logic        o_req_lock,

  // Write-data phase channel to the controller
  output logic        o_data_valid,
  input  wire         i_data_ready,
  output logic [31:0] o_data,
  output logic [3:0]  o_strb,

  // Ordered completion channel from the controller
  input  wire         i_rsp_valid,
  output logic        o_rsp_ready,
  input  wire         i_rsp_err,
  input  wire  [31:0] i_rsp_data
);

  // Internal signal declarations
  logic reg_data_phase_valid;
  logic reg_data_phase_wr;
  logic reg_data_sent;
  logic reg_err_second;

  // Request and data mapping preserve the AHB address/data phase relationship.
  assign o_req_addr  = i_ahb_haddr;
  assign o_req_trans = i_ahb_htrans;
  assign o_req_wr = i_ahb_hwrite;
  assign o_req_size  = i_ahb_hsize;
  assign o_req_burst = i_ahb_hburst;
  assign o_req_prot  = i_ahb_hprot;
  assign o_req_nonsec = i_ahb_hnonsec;
  assign o_req_lock  = i_ahb_hmastlock;
  assign o_data      = i_ahb_hwdata;
  assign o_strb      = i_ahb_hwstrb;

  // AHB wait states hold an unfinished data phase and prevent the next address from being lost.
  always_comb begin : p_com_ahb_rsp
    o_req_valid       = 1'b0;
    o_data_valid      = 1'b0;
    o_rsp_ready       = 1'b0;
    o_ahb_hreadyout   = 1'b1;
    o_ahb_hresp       = 1'b0;
    o_ahb_hrdata      = '0;

    if (i_rst_n_core) begin
      o_req_valid  = i_ahb_hsel & i_ahb_hready & i_ahb_htrans[1] &
                     (~reg_data_phase_valid | o_rsp_ready);
      o_data_valid = reg_data_phase_valid & reg_data_phase_wr & ~reg_data_sent;

      if (reg_data_phase_valid) begin
        if (i_rsp_valid) begin
          o_ahb_hresp  = i_rsp_err;
          o_ahb_hrdata = i_rsp_data;
          if (i_rsp_err & ~reg_err_second)
            o_ahb_hreadyout = 1'b0;
          o_rsp_ready = i_ahb_hready & (~i_rsp_err | reg_err_second) &
                        (~i_ahb_hsel | ~i_ahb_htrans[1] | i_req_ready);
        end else begin
          o_ahb_hreadyout = 1'b0;
        end
      end

      if (i_ahb_hsel & i_ahb_htrans[1] & ~i_req_ready)
        o_ahb_hreadyout = 1'b0;
    end
  end

  // The phase register holds the accepted transfer until its AHB response completes.
  always_ff @(posedge i_clk_core, negedge i_rst_n_core) begin : p_ff_ahb_phase
    if (!i_rst_n_core) begin
      reg_data_phase_valid <= 1'b0;
      reg_data_phase_wr <= 1'b0;
      reg_data_sent        <= 1'b0;
      reg_err_second       <= 1'b0;
    end else begin
      if (o_data_valid & i_data_ready)
        reg_data_sent <= 1'b1;

      if (i_rsp_valid & i_rsp_err & reg_data_phase_valid & ~reg_err_second)
        reg_err_second <= 1'b1;

      if (o_rsp_ready) begin
        reg_data_phase_valid <= 1'b0;
        reg_data_phase_wr <= 1'b0;
        reg_data_sent        <= 1'b0;
        reg_err_second       <= 1'b0;
      end

      if (o_req_valid & i_req_ready) begin
        reg_data_phase_valid <= 1'b1;
        reg_data_phase_wr <= i_ahb_hwrite;
        reg_data_sent        <= 1'b0;
        reg_err_second       <= 1'b0;
      end
    end
  end

endmodule
