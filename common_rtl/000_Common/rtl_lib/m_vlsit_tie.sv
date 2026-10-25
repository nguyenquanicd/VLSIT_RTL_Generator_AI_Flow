/*
 * Project      : VLSIT Common RTL library
 * Author       : Nguyen Quan and Claude Sonnet 5.5 (user)
 * AI Flow      : VLSIT RTL Generator AI Automation Flow
 * AI Flow Page : https://github.com/nguyenquanicd/VLSIT_RTL_Generator_AI_Model
 * Date         : 2026-10-25
 * Description  : Tie-off module with a selectable width and value. Bit n of o_tie is tied to bit n
 *                of PARA_TIE_VALUE; the width is PARA_TIE_WIDTH, from 1 to 32. With the flow macro
 *                VLSIT_SYNTHESIS it instantiates one tie cell per bit, a tie-high cell for a bit
 *                value of 1 and a tie-low cell for 0, named u_dont_touch_<function>. Without the
 *                macro it contains the simulation model, the constant value (a tie cell has no
 *                other behavior). The simulation branch is excluded from the RTL rules by rule
 *                R-027.
 */
`timescale 1ns/1ps

module m_vlsit_tie #(
  // Parameter Description: width of the tied output.
  // Parameter values: 1 to 32; default is 1.
  // Parameter unit: bit
  parameter logic [31:0] PARA_TIE_WIDTH = 1,
  // Parameter Description: tie value. Bit n of the value is the tie value of o_tie[n]; the bits at
  // or above PARA_TIE_WIDTH are ignored.
  // Parameter values: any 32-bit value; default is 0.
  // Parameter unit: none
  parameter logic [31:0] PARA_TIE_VALUE = 0
) (
  // Tied output
  output logic [PARA_TIE_WIDTH-1:0] o_tie
);

`ifdef VLSIT_SYNTHESIS
  // One tie cell per bit, chosen at elaboration by the value of the bit.
  for (genvar gv_bit = 0; gv_bit < PARA_TIE_WIDTH; gv_bit++) begin : gen_bit
    if (PARA_TIE_VALUE[gv_bit]) begin : gen_hi
      VLSIT_CELL_TIEH u_dont_touch_tieh (.Z (o_tie[gv_bit]));
    end else begin : gen_lo
      VLSIT_CELL_TIEL u_dont_touch_tiel (.Z (o_tie[gv_bit]));
    end
  end
`else
  // Simulation model: the constant value.
  assign o_tie = PARA_TIE_VALUE[PARA_TIE_WIDTH-1:0];
`endif

endmodule
