/*
 * Project      : QSPI_Controller
 * Author       : Nguyen Quan (user)
 * AI Flow      : VLSIT RTL Generator AI Automation Flow
 * AI Flow Page : https://github.com/nguyenquanicd/VLSIT_RTL_Generator_AI_Model
 * Date         : 2026-11-02
 * Description  : Selects controller or target drive values for the shared serial IO pad group.
 *                Role changes are controlled by software and must occur while both engines idle.
 */
`timescale 1ns/1ps

module m_qspi_pin_mux (
  // Role selection
  input  wire        i_role_target,

  // Controller drive group
  input  wire  [3:0] i_ctrl_io_o,
  input  wire  [3:0] i_ctrl_io_oe,

  // Target drive group
  input  wire  [3:0] i_tgt_io_o,
  input  wire  [3:0] i_tgt_io_oe,

  // Shared pad output group
  output logic [3:0] o_spi_io_o,
  output logic [3:0] o_spi_io_oe
);

  // Select exactly one role's drive data and output-enable vector.
  always_comb begin : p_com_pin_mux
    o_spi_io_o  = 4'b0000;
    o_spi_io_oe = 4'b0000;
    if (i_role_target) begin
      o_spi_io_o  = i_tgt_io_o;
      o_spi_io_oe = i_tgt_io_oe;
    end else begin
      o_spi_io_o  = i_ctrl_io_o;
      o_spi_io_oe = i_ctrl_io_oe;
    end
  end

endmodule
