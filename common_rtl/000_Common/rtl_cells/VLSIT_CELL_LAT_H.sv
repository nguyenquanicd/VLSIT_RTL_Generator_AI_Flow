/*
 * Project      : VLSIT Common RTL library
 * Author       : Nguyen Quan and Claude Sonnet 5.5 (user)
 * AI Flow      : VLSIT RTL Generator AI Automation Flow
 * AI Flow Page : https://github.com/nguyenquanicd/VLSIT_RTL_Generator_AI_Model
 * Date         : 2026-10-25
 * Description  : VLSIT_CELL_LAT_H: D latch, transparent while G = 1.
 *                Synthesizable RTL model of a basic technology cell. In principle a real design
 *                uses the corresponding cell of the synthesis library, not this model; use this
 *                model only for simulation, for a prototype, or when no library is available.
 *                The module and pin names keep the usual style of a library cell and are exempt
 *                from the naming rule (rule R-032); all other rules apply.
 */
`timescale 1ns/1ps

module VLSIT_CELL_LAT_H (
  // Cell data
  input  wire  G,
  input  wire  D,
  output logic Q
);

  logic reg_q;

  // D latch, transparent while G = 1.
  always_latch begin : p_lat_cell
    if (G)
      reg_q <= D;
  end

  // Cell output is the latch output.
  assign Q = reg_q;

endmodule
