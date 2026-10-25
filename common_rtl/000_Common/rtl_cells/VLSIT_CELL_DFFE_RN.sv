/*
 * Project      : VLSIT Common RTL library
 * Author       : Nguyen Quan and Claude Sonnet 5.5 (user)
 * AI Flow      : VLSIT RTL Generator AI Automation Flow
 * AI Flow Page : https://github.com/nguyenquanicd/VLSIT_RTL_Generator_AI_Model
 * Date         : 2026-10-25
 * Description  : VLSIT_CELL_DFFE_RN: D flip-flop with synchronous enable E, rising edge,
 *                asynchronous active-low reset.
 *                Synthesizable RTL model of a basic technology cell. In principle a real design
 *                uses the corresponding cell of the synthesis library, not this model; use this
 *                model only for simulation, for a prototype, or when no library is available.
 *                The module and pin names keep the usual style of a library cell and are exempt
 *                from the naming rule (rule R-032); all other rules apply.
 */
`timescale 1ns/1ps

module VLSIT_CELL_DFFE_RN (
  // Clock and reset
  input  wire  CK,
  input  wire  RN,

  // Cell data
  input  wire  D,
  input  wire  E,
  output logic Q
);

  logic reg_q;

  // D flip-flop with synchronous enable E, rising edge, asynchronous active-low reset.
  always_ff @(posedge CK, negedge RN) begin : p_ff_cell
    if (!RN)
      reg_q <= 1'b0;
    else if (E)
      reg_q <= D;
  end

  // Cell output is the flip-flop output.
  assign Q = reg_q;

endmodule
