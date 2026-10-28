/*
 * Project      : VLSIT Common RTL library
 * Author       : Nguyen Quan and Claude Sonnet 5.5 (user)
 * AI Flow      : VLSIT RTL Generator AI Automation Flow
 * AI Flow Page : https://github.com/nguyenquanicd/VLSIT_RTL_Generator_AI_Model
 * Date         : 2026-10-26
 * Description  : Read data storage of the AXI2TLUL bridge: PARA_DEPTH words of PARA_DATA_W bits
 *                with one write port and one read port on one clock and a read latency of one
 *                cycle. PARA_STORE_MACRO selects an inferred array (0) or the library SRAM wrapper
 *                m_vlsit_sfifo_ram_macro (1); both give the same behavior. The read data stays
 *                unchanged until the next read. A word is read only after it was written, so the
 *                array has no reset.
 */
`timescale 1ns/1ps

module m_vlsit_axi2tlul_store #(
  // Parameter Description: number of words of the storage (one word per read slot of the bridge).
  // Parameter values: any integer from 2 to 128; default is 16.
  // Parameter unit: count
  parameter logic [31:0] PARA_DEPTH = 16,
  // Parameter Description: width of one word of the storage.
  // Parameter values: 32, 64, 128, 256, 512, or 1024; default is 32.
  // Parameter unit: bit
  parameter logic [31:0] PARA_DATA_W = 32,
  // Parameter Description: implementation of the storage, 0 = inferred array, 1 = macro wrapper.
  // Parameter values: 0 or 1; default is 0.
  // Parameter unit: none
  parameter logic [31:0] PARA_STORE_MACRO = 0,
  localparam logic [31:0] LPARA_ADDR_W = $clog2(PARA_DEPTH)
) (
  // Clock
  input  wire                     i_clk_main,

  // Write port
  input  wire                     i_wr_en,
  input  wire  [LPARA_ADDR_W-1:0] i_wr_addr,
  input  wire  [PARA_DATA_W-1:0]  i_wr_data,

  // Read port
  input  wire                     i_rd_en,
  input  wire  [LPARA_ADDR_W-1:0] i_rd_addr,
  output logic [PARA_DATA_W-1:0]  o_rd_data
);

  // Storage implementation selected at elaboration.
  if (PARA_STORE_MACRO == 32'd0) begin : gen_array
    logic [PARA_DATA_W-1:0] reg_mem [PARA_DEPTH];
    logic [PARA_DATA_W-1:0] reg_rd_data;

    // Write port: the word is written at the rising edge when the write enable is high.
    always_ff @(posedge i_clk_main) begin : p_ff_wr
      if (i_wr_en)
        reg_mem[i_wr_addr] <= i_wr_data;
    end

    // Read port: the registered read data takes the addressed word and holds it until the next
    // read.
    always_ff @(posedge i_clk_main) begin : p_ff_rd
      if (i_rd_en)
        reg_rd_data <= reg_mem[i_rd_addr];
    end

    // The read data output is the registered read data.
    assign o_rd_data = reg_rd_data;
  end else begin : gen_macro
    logic w_wr_en_n;
    logic w_rd_en_n;

    // The macro wrapper has active-low enables.
    assign w_wr_en_n = ~i_wr_en;
    assign w_rd_en_n = ~i_rd_en;

    // Library SRAM wrapper: the only place that names the macro (rule HIE-07).
    m_vlsit_sfifo_ram_macro #(
      .PARA_SFIFO_DEPTH  (PARA_DEPTH),
      .PARA_SFIFO_DATA_W (PARA_DATA_W)
    ) u_vlsit_sfifo_ram_macro (
      .i_clk_wr  (i_clk_main),
      .i_wr_en_n (w_wr_en_n),
      .i_wr_addr (i_wr_addr),
      .i_wr_data (i_wr_data),
      .i_clk_rd  (i_clk_main),
      .i_rd_en_n (w_rd_en_n),
      .i_rd_addr (i_rd_addr),
      .o_rd_data (o_rd_data)
    );
  end

endmodule
