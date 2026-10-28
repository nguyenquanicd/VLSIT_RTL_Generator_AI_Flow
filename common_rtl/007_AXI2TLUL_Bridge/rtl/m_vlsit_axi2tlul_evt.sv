/*
 * Project      : VLSIT Common RTL library
 * Author       : Nguyen Quan and Claude Sonnet 5.5 (user)
 * AI Flow      : VLSIT RTL Generator AI Automation Flow
 * AI Flow Page : https://github.com/nguyenquanicd/VLSIT_RTL_Generator_AI_Model
 * Date         : 2026-10-26
 * Description  : Status pulses of the AXI2TLUL bridge. Each output is a flip-flop that repeats, one
 *                cycle later, the one-cycle condition that a block of the bridge raises: an
 *                orphaned response, a response with a wrong opcode, and an illegal AXI burst or a
 *                WLAST mismatch of the read or the write request engine.
 */
`timescale 1ns/1ps

module m_vlsit_axi2tlul_evt (
  // Clock and reset
  input  wire  i_clk_main,
  input  wire  i_rst_n_main,

  // Conditions from the bridge blocks
  input  wire  i_orphan,
  input  wire  i_bad,
  input  wire  i_axi_err_rd,
  input  wire  i_axi_err_wr,

  // Status pulses
  output logic o_evt_orphan_resp,
  output logic o_evt_bad_resp,
  output logic o_evt_axi_err_rd,
  output logic o_evt_axi_err_wr
);

  // Internal signal declarations
  logic reg_orphan;
  logic reg_bad;
  logic reg_axi_err_rd;
  logic reg_axi_err_wr;

  // Output mapping: the pulses are flip-flop outputs.
  assign o_evt_orphan_resp = reg_orphan;
  assign o_evt_bad_resp    = reg_bad;
  assign o_evt_axi_err_rd  = reg_axi_err_rd;
  assign o_evt_axi_err_wr  = reg_axi_err_wr;

  // Pulse registers: each one follows its condition one cycle later and is cleared by reset.
  always_ff @(posedge i_clk_main, negedge i_rst_n_main) begin : p_ff_evt
    if (!i_rst_n_main) begin
      reg_orphan  <= 1'b0;
      reg_bad     <= 1'b0;
      reg_axi_err_rd <= 1'b0;
      reg_axi_err_wr <= 1'b0;
    end else begin
      reg_orphan  <= i_orphan;
      reg_bad     <= i_bad;
      reg_axi_err_rd <= i_axi_err_rd;
      reg_axi_err_wr <= i_axi_err_wr;
    end
  end

endmodule
