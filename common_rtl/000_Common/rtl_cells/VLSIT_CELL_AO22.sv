/*
 * Project      : VLSIT Common RTL library
 * Author       : Nguyen Quan and Claude Sonnet 5.5 (user)
 * AI Flow      : VLSIT RTL Generator AI Automation Flow
 * AI Flow Page : https://github.com/nguyenquanicd/VLSIT_RTL_Generator_AI_Model
 * Date         : 2026-10-25
 * Description  : VLSIT_CELL_AO22: AND-OR: Z = (A1 & A2) | (B1 & B2).
 *                Synthesizable RTL model of a basic technology cell. In principle a real design
 *                uses the corresponding cell of the synthesis library, not this model; use this
 *                model only for simulation, for a prototype, or when no library is available.
 *                The module and pin names keep the usual style of a library cell and are exempt
 *                from the naming rule (rule R-032); all other rules apply.
 */
`timescale 1ns/1ps

module VLSIT_CELL_AO22 (
  // Cell data
  input  wire  A1,
  input  wire  A2,
  input  wire  B1,
  input  wire  B2,
  output logic Z
);

  // AND-OR
  assign Z = (A1 & A2) | (B1 & B2);

endmodule
