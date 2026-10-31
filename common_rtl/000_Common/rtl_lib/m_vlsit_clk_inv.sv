/*
 * Project      : VLSIT Common RTL library
 * Author       : Nguyen Quan (user)
 * AI Flow      : VLSIT RTL Generator AI Automation Flow
 * AI Flow Page : https://github.com/nguyenquanicd/VLSIT_RTL_Generator_AI_Model
 * Date         : 2026-10-31
 * Description  : Wrapper of the technology clock inverter cell. o_clk_n is the inverse of
 *                i_clk_in.
 *                With the flow macro VLSIT_SYNTHESIS it instantiates the library clock inverter
 *                cell, named u_dont_touch_ckinv, so that the clock tree and the dont_touch
 *                attribute apply to the inversion (HIE-07, CLK-02). Without the macro it contains
 *                the simulation model, the logical inverse. The simulation branch is excluded from
 *                the RTL rules by rule R-027. Used where a block must capture data on the falling
 *                edge of a clock that it receives from outside, for example the read capture of
 *                009_HyperRAM_Controller.
 */
`timescale 1ns/1ps

module m_vlsit_clk_inv (
  // Clock input and inverted clock output
  input  wire  i_clk_in,
  output logic o_clk_n
);

`ifdef VLSIT_SYNTHESIS
  // Library clock inverter cell.
  VLSIT_CELL_CKINV u_dont_touch_ckinv (.I (i_clk_in), .ZN (o_clk_n));
`else
  // Simulation model: the logical inverse of the clock.
  assign o_clk_n = ~i_clk_in;
`endif

endmodule
