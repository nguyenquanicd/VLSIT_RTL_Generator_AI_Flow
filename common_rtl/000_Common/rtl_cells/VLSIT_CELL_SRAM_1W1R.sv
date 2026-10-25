/*
 * Project      : VLSIT Common RTL library
 * Author       : Nguyen Quan and Claude Sonnet 5.5 (user)
 * AI Flow      : VLSIT RTL Generator AI Automation Flow
 * AI Flow Page : https://github.com/nguyenquanicd/VLSIT_RTL_Generator_AI_Model
 * Date         : 2026-10-22
 * Description  : VLSIT_CELL_SRAM_1W1R: generic SRAM macro with one write port and one read port.
 *                Synthesizable RTL model of a macro. In principle a real design uses the
 *                macro of the memory compiler / synthesis library, not this model; use this
 *                model only for simulation, for a prototype, or when no macro is available.
 *                It is instantiated only by the SRAM wrappers (m_vlsit_afifo_ram_macro,
 *                m_vlsit_sfifo_ram_macro), in the instance u_dont_touch_sram. The module, parameter
 *                and pin names (CLKW, WEB, AW, DW, BWEB, CLKR, REB, AR, QR) keep the style of a
 *                library macro and are exempt from the naming rule (rule R-032); all other rules
 *                apply.
 *                Write: at the rising edge of CLKW with WEB = 0, each bit of DW whose BWEB bit
 *                is 0 is written to the word at AW. Read: at the rising edge of CLKR with
 *                REB = 0, QR takes the word at AR (latency of one CLKR cycle); QR keeps its value
 *                while REB = 1. A read of the address that is written at the same edge returns
 *                the old word. The array has no reset.
 */
`timescale 1ns/1ps

module VLSIT_CELL_SRAM_1W1R #(
  // Parameter Description: address width of the macro. The number of words is 2 to the power of
  // this value.
  // Parameter values: 1 or more; default is 3.
  // Parameter unit: bit
  parameter logic [31:0] ADDR_W = 3,
  // Parameter Description: data width of the macro, also the width of the bit write mask.
  // Parameter values: 1 or more; default is 8.
  // Parameter unit: bit
  parameter logic [31:0] DATA_W = 8,
  localparam logic [31:0] LPARA_DEPTH = 32'd1 << ADDR_W
) (
  // Write port
  input  wire               CLKW,
  input  wire               WEB,
  input  wire  [ADDR_W-1:0] AW,
  input  wire  [DATA_W-1:0] DW,
  input  wire  [DATA_W-1:0] BWEB,

  // Read port
  input  wire               CLKR,
  input  wire               REB,
  input  wire  [ADDR_W-1:0] AR,
  output logic [DATA_W-1:0] QR
);

  // Storage array and read register: resetless payload state. The FIFO consumes a word only after
  // the write pointer has proved that it was written (SEQ-04).
  logic [DATA_W-1:0] reg_mem [0:LPARA_DEPTH-1];
  logic [DATA_W-1:0] reg_qr;

  // Write port: a bit of the word is written when WEB is 0 and its BWEB bit is 0 (active-low bit
  // write enable); the other bits keep their value.
  always_ff @(posedge CLKW) begin : p_ff_wr_port
    if (!WEB)
      reg_mem[AW] <= (reg_mem[AW] & BWEB) | (DW & ~BWEB);
  end

  // Read port: with REB = 0 the read register takes the word at AR at every rising edge of CLKR,
  // so the data is available one CLKR cycle after the address. With REB = 1 it keeps its value.
  always_ff @(posedge CLKR) begin : p_ff_rd_port
    if (!REB)
      reg_qr <= reg_mem[AR];
  end

  // Read data of the macro.
  assign QR = reg_qr;

endmodule
