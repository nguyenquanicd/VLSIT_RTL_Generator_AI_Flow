/*
 * Project      : VLSIT Common RTL library
 * Author       : Nguyen Quan and Claude Sonnet 5.5 (user)
 * AI Flow      : VLSIT RTL Generator AI Automation Flow
 * AI Flow Page : https://github.com/nguyenquanicd/VLSIT_RTL_Generator_AI_Model
 * Date         : 2026-10-22
 * Description  : FIFO storage of the asynchronous Gray FIFO: DEPTH words of DATA_W bits with one
 *                write port (write clock) and one read port (read clock). Either an RTL array
 *                (default) or the library SRAM wrapper m_vlsit_afifo_ram_macro. The read is
 *                synchronous with a latency of one read-clock cycle: o_rd_data is a register that
 *                captures the word of i_rd_addr in every read-clock cycle (no read enable). The
 *                storage has no reset: its content is consumed only after the write pointer has
 *                proved that the entry was written (SEQ-04).
 */
`timescale 1ns/1ps

module m_vlsit_afifo_mem #(
  // Parameter Description: number of entries of the storage. Sets the address width.
  // Parameter values: power of 2, minimum 2; default is 8.
  // Parameter unit: count
  parameter logic [31:0] PARA_AFIFO_DEPTH = 8,
  // Parameter Description: data width of one entry.
  // Parameter values: 1 or more; default is 32.
  // Parameter unit: bit
  parameter logic [31:0] PARA_AFIFO_DATA_W = 32,
  // Parameter Description: 0 = RTL array, 1 = library SRAM wrapper m_vlsit_afifo_ram_macro.
  // Parameter values: 0 or 1; default is 0.
  // Parameter unit: none
  parameter logic [31:0] PARA_AFIFO_MEM_USE_MACRO = 0,
  localparam logic [31:0] LPARA_ADDR_W = $clog2(PARA_AFIFO_DEPTH)
) (
  // Write port
  input  wire                          i_clk_wr,
  input  wire                          i_wr_en,
  input  wire  [LPARA_ADDR_W-1:0]      i_wr_addr,
  input  wire  [PARA_AFIFO_DATA_W-1:0] i_wr_data,

  // Read port
  input  wire                          i_clk_rd,
  input  wire  [LPARA_ADDR_W-1:0]      i_rd_addr,
  output logic [PARA_AFIFO_DATA_W-1:0] o_rd_data
);

  if (PARA_AFIFO_MEM_USE_MACRO == 32'd0) begin : gen_array
    // Storage array and read register. Both are resetless payload state: the read side consumes
    // the word only when the empty flag is 0, which the write pointer guarantees after a write.
    logic [PARA_AFIFO_DATA_W-1:0] reg_mem [0:PARA_AFIFO_DEPTH-1];
    logic [PARA_AFIFO_DATA_W-1:0] reg_rd_data;

    // Write port: stores the word at the write edge when the write enable is 1.
    always_ff @(posedge i_clk_wr) begin : p_ff_wr_port
      if (i_wr_en)
        reg_mem[i_wr_addr] <= i_wr_data;
    end

    // Read port: captures the word of the read address in every read-clock cycle. A word that is
    // written at the same edge is not seen: the register keeps the old word, which the FIFO
    // ignores while the empty flag is 1.
    always_ff @(posedge i_clk_rd) begin : p_ff_rd_port
      reg_rd_data <= reg_mem[i_rd_addr];
    end

    // Read data of the array branch.
    assign o_rd_data = reg_rd_data;
  end else begin : gen_macro
    // The macro has active-low enables. The read is enabled in every read-clock cycle.
    logic w_wr_en_n;
    logic w_rd_en_n;

    // Enable polarity conversion for the macro pins.
    assign w_wr_en_n = ~i_wr_en;
    assign w_rd_en_n = 1'b0;

    // Library SRAM wrapper: write port in the write domain, read port in the read domain.
    m_vlsit_afifo_ram_macro #(
      .PARA_AFIFO_DEPTH  (PARA_AFIFO_DEPTH),
      .PARA_AFIFO_DATA_W (PARA_AFIFO_DATA_W)
    ) u_vlsit_afifo_ram_macro (
      .i_clk_wr  (i_clk_wr),
      .i_wr_en_n (w_wr_en_n),
      .i_wr_addr (i_wr_addr),
      .i_wr_data (i_wr_data),
      .i_clk_rd  (i_clk_rd),
      .i_rd_en_n (w_rd_en_n),
      .i_rd_addr (i_rd_addr),
      .o_rd_data (o_rd_data)
    );
  end

endmodule
