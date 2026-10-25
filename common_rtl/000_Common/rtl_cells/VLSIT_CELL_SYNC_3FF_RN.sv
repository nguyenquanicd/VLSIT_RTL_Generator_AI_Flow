/*
 * Project      : VLSIT Common RTL library
 * Author       : Nguyen Quan and Claude Sonnet 5.5 (user)
 * AI Flow      : VLSIT RTL Generator AI Automation Flow
 * AI Flow Page : https://github.com/nguyenquanicd/VLSIT_RTL_Generator_AI_Model
 * Date         : 2026-10-25
 * Description  : VLSIT_CELL_SYNC_3FF_RN: 3 D flip-flops in series (one 3-FF synchronizer cell),
 *                with asynchronous active-low reset to 0.
 *                Synthesizable RTL model of a technology cell. In principle a real design uses
 *                the corresponding cell of the synthesis library, not this model; use this model
 *                only for simulation, for a prototype, or when no library is available. It is
 *                instantiated only by m_vlsit_afifo_cell_sync, in the instance
 *                u_dont_touch_<function>. The module and pin names keep the usual style of a
 *                library cell and are exempt from the naming rule (rule R-032); all other rules
 *                apply.
 */
`timescale 1ns/1ps

module VLSIT_CELL_SYNC_3FF_RN #(
  localparam logic [31:0] LPARA_CELL_STAGE = 3
) (
  // Clock and reset
  input  wire  CK,
  input  wire  RN,

  // Cell data
  input  wire  D,
  output logic Q
);

  logic [LPARA_CELL_STAGE-1:0] reg_chain;

  // Shift chain of 3 flip-flops: D enters stage 0 and moves one stage per rising edge of
  // CK. All stages go to 0 asynchronously when RN (active-low) is low.
  always_ff @(posedge CK, negedge RN) begin : p_ff_cell
    if (!RN)
      reg_chain <= {LPARA_CELL_STAGE{1'b0}};
    else
      reg_chain <= {reg_chain[LPARA_CELL_STAGE-2:0], D};
  end

  // Cell output is the last stage of the chain.
  assign Q = reg_chain[LPARA_CELL_STAGE-1];

endmodule
