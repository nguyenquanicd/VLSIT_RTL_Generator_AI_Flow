/*
 * Project      : VLSIT Common RTL library
 * Author       : Nguyen Quan and Claude Sonnet 5.5 (user)
 * AI Flow      : VLSIT RTL Generator AI Automation Flow
 * AI Flow Page : https://github.com/nguyenquanicd/VLSIT_RTL_Generator_AI_Model
 * Date         : 2026-10-25
 * Description  : VLSIT_CELL_FA: full adder, S = A ^ B ^ CI, CO = majority(A, B, CI).
 *                Synthesizable RTL model of a basic technology cell. In principle a real design
 *                uses the corresponding cell of the synthesis library, not this model; use this
 *                model only for simulation, for a prototype, or when no library is available.
 *                The module and pin names keep the usual style of a library cell and are exempt
 *                from the naming rule (rule R-032); all other rules apply.
 */
`timescale 1ns/1ps

module VLSIT_CELL_FA (
  // Cell data
  input  wire  A,
  input  wire  B,
  input  wire  CI,
  output logic S,
  output logic CO
);

  // Full adder: sum and carry out
  assign S = A ^ B ^ CI;
  assign CO = (A & B) | (CI & (A ^ B));

endmodule
