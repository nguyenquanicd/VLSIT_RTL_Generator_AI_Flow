/*
 * Project      : VLSIT Common RTL library
 * Author       : Nguyen Quan and Claude Sonnet 5.5 (user)
 * AI Flow      : VLSIT RTL Generator AI Automation Flow
 * AI Flow Page : https://github.com/nguyenquanicd/VLSIT_RTL_Generator_AI_Model
 * Date         : 2026-10-22
 * Description  : Wrapper of the library SRAM (one write port, one read port) of the asynchronous
 *                Gray FIFO. It instantiates the macro VLSIT_CELL_SRAM_1W1R (pins CLKW, WEB, AW, DW,
 *                BWEB, CLKR, REB, AR, QR) and nothing else, in every flow and for simulation as
 *                well as synthesis (DEC-043). The real macro is mapped in the body of this wrapper.
 *                Read latency is one read-clock cycle. The write enable and the read enable of the
 *                macro are active-low, and the whole word is written (BWEB tied to 0).
 */
`timescale 1ns/1ps

module m_vlsit_afifo_ram_macro #(
  // Parameter Description: number of entries of the macro. Sets the address width.
  // Parameter values: power of 2, minimum 2; default is 8.
  // Parameter unit: count
  parameter logic [31:0] PARA_AFIFO_DEPTH = 8,
  // Parameter Description: data width of the macro.
  // Parameter values: 1 or more; default is 32.
  // Parameter unit: bit
  parameter logic [31:0] PARA_AFIFO_DATA_W = 32,
  localparam logic [31:0] LPARA_ADDR_W = $clog2(PARA_AFIFO_DEPTH)
) (
  // Write port
  input  wire                          i_clk_wr,
  input  wire                          i_wr_en_n,
  input  wire  [LPARA_ADDR_W-1:0]      i_wr_addr,
  input  wire  [PARA_AFIFO_DATA_W-1:0] i_wr_data,

  // Read port
  input  wire                          i_clk_rd,
  input  wire                          i_rd_en_n,
  input  wire  [LPARA_ADDR_W-1:0]      i_rd_addr,
  output logic [PARA_AFIFO_DATA_W-1:0] o_rd_data
);

  // Macro instance: the whole word is written (BWEB tied to 0, active-low bit write enable).
  VLSIT_CELL_SRAM_1W1R #(
    .ADDR_W (LPARA_ADDR_W),
    .DATA_W (PARA_AFIFO_DATA_W)
  ) u_dont_touch_sram (
    .CLKW (i_clk_wr),
    .WEB  (i_wr_en_n),
    .AW   (i_wr_addr),
    .DW   (i_wr_data),
    .BWEB ({PARA_AFIFO_DATA_W{1'b0}}),
    .CLKR (i_clk_rd),
    .REB  (i_rd_en_n),
    .AR   (i_rd_addr),
    .QR   (o_rd_data)
  );

endmodule
