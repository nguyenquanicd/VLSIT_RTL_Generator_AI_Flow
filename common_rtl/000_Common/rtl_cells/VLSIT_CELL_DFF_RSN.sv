/*
 * Project      : VLSIT Common RTL library
 * Author       : Nguyen Quan and Claude Sonnet 5.5 (user)
 * AI Flow      : VLSIT RTL Generator AI Automation Flow
 * AI Flow Page : https://github.com/nguyenquanicd/VLSIT_RTL_Generator_AI_Model
 * Date         : 2026-10-25
 * Description  : VLSIT_CELL_DFF_RSN: D flip-flop, rising edge, asynchronous active-low reset
 *                (priority) and set.
 *                Synthesizable RTL model of a basic technology cell. In principle a real design
 *                uses the corresponding cell of the synthesis library, not this model; use this
 *                model only for simulation, for a prototype, or when no library is available.
 *                The module and pin names keep the usual style of a library cell and are exempt
 *                from the naming rule (rule R-032); all other rules apply.
 */
`timescale 1ns/1ps

module VLSIT_CELL_DFF_RSN (
  // Clock and set and reset
  input  wire  CK,
  input  wire  RN,
  input  wire  SN,

  // Cell data
  input  wire  D,
  output logic Q
);

  logic reg_q;

  // D flip-flop, rising edge, asynchronous active-low reset (priority) and set.
  always_ff @(posedge CK, negedge RN, negedge SN) begin : p_ff_cell
    if (!RN)
      reg_q <= 1'b0;
    else if (!SN)
      reg_q <= 1'b1;
    else
      reg_q <= D;
  end

  // Cell output is the flip-flop output.
  assign Q = reg_q;

endmodule
