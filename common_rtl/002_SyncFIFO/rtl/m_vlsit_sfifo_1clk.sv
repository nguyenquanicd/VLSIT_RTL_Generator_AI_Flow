/*
 * Project      : VLSIT Common RTL library
 * Author       : Nguyen Quan and Claude Sonnet 5.5 (user)
 * AI Flow      : VLSIT RTL Generator AI Automation Flow
 * AI Flow Page : https://github.com/nguyenquanicd/VLSIT_RTL_Generator_AI_Model
 * Date         : 2026-10-28
 * Description  : Single-clock synchronous FIFO of registers with a show-ahead read, a variant of
 *                the synchronous-clock FIFO of this folder for designs that have one clock and need
 *                the first word at once. Function: a word written at a rising edge of i_clk_fifo
 *                (i_wr_en = 1, o_full = 0) is on o_rd_data from the next cycle and o_empty is 0
 *                from the next cycle; o_rd_data always shows the oldest word, and a read (i_rd_en =
 *                1, o_empty = 0) removes it at the rising edge. A write and a read can happen at
 *                the same edge. o_full and o_empty are registers, o_count is the number of words
 *                stored. A write while o_full = 1 and a read while o_empty = 1 are ignored without
 *                any flag. The depth is a power of 2 from 2. The word storage has no reset:
 *                o_rd_data is meaningful only while o_empty is 0 (SEQ-04). There is no software
 *                reset, no threshold and no second clock.
 */
`timescale 1ns/1ps

module m_vlsit_sfifo_1clk #(
  // Parameter Description: number of words of the FIFO. Sets the pointer width.
  // Parameter values: a power of 2 of 2 or more; default is 8.
  // Parameter unit: count
  parameter logic [31:0] PARA_SFIFO_DEPTH = 8,
  // Parameter Description: data width of one word.
  // Parameter values: 1 or more; default is 32.
  // Parameter unit: bit
  parameter logic [31:0] PARA_SFIFO_DATA_W = 32,
  localparam logic [31:0] LPARA_ADDR_W = $clog2(PARA_SFIFO_DEPTH),
  localparam logic [31:0] LPARA_CNT_W = $clog2(PARA_SFIFO_DEPTH + 1)
) (
  // Clock and reset
  input  wire                          i_clk_fifo,
  input  wire                          i_rst_n_fifo,

  // Write interface
  input  wire                          i_wr_en,
  input  wire  [PARA_SFIFO_DATA_W-1:0] i_wr_data,
  output logic                         o_full,

  // Read interface
  input  wire                          i_rd_en,
  output logic [PARA_SFIFO_DATA_W-1:0] o_rd_data,
  output logic                         o_empty,

  // Status
  output logic [LPARA_CNT_W-1:0]       o_count
);
  // Internal signal declarations
  logic [PARA_SFIFO_DATA_W-1:0] reg_mem [0:PARA_SFIFO_DEPTH-1];
  logic [LPARA_ADDR_W-1:0]      reg_wr_ptr;
  logic [LPARA_ADDR_W-1:0]      reg_rd_ptr;
  logic [LPARA_CNT_W-1:0]       reg_count;
  logic                         reg_full;
  logic                         reg_empty;
  logic                         w_wr_acc;
  logic                         w_rd_acc;
  logic [LPARA_CNT_W-1:0]       w_count_nxt;

  // Output mapping: flags and count are registers, the read data is the word at the read pointer.
  assign o_full    = reg_full;
  assign o_empty   = reg_empty;
  assign o_count   = reg_count;
  assign o_rd_data = reg_mem[reg_rd_ptr];

  // Acceptance: a write is taken when the FIFO is not full, a read when it is not empty.
  assign w_wr_acc = i_wr_en & ~reg_full;
  assign w_rd_acc = i_rd_en & ~reg_empty;

  // Next occupancy: one more for an accepted write, one less for an accepted read.
  assign w_count_nxt = reg_count + $bits(w_count_nxt)'(w_wr_acc) - $bits(w_count_nxt)'(w_rd_acc);

  // Word storage: each entry stores the write data when the write pointer selects it.
  // Resetless payload: the read side consumes a word only while the empty flag is 0.
  for (genvar gen_idx = 0; gen_idx < PARA_SFIFO_DEPTH; gen_idx++) begin : gen_mem
    // Entry register: loaded with the write data when this entry is the write target.
    always_ff @(posedge i_clk_fifo) begin : p_ff_entry
      if (w_wr_acc & (reg_wr_ptr == $bits(reg_wr_ptr)'(gen_idx)))
        reg_mem[gen_idx] <= i_wr_data;
    end
  end

  // Pointers, occupancy and flags: control state, reset asynchronously (active low). The pointers
  // wrap by themselves because the depth is a power of 2.
  always_ff @(posedge i_clk_fifo, negedge i_rst_n_fifo) begin : p_ff_ctrl
    if (!i_rst_n_fifo) begin
      reg_wr_ptr <= '0;
      reg_rd_ptr <= '0;
      reg_count  <= '0;
      reg_full   <= 1'b0;
      reg_empty  <= 1'b1;
    end else begin
      if (w_wr_acc)
        reg_wr_ptr <= $bits(reg_wr_ptr)'(reg_wr_ptr + 1'b1);
      if (w_rd_acc)
        reg_rd_ptr <= $bits(reg_rd_ptr)'(reg_rd_ptr + 1'b1);
      reg_count <= w_count_nxt;
      reg_full  <= (w_count_nxt == $bits(w_count_nxt)'(PARA_SFIFO_DEPTH));
      reg_empty <= (w_count_nxt == '0);
    end
  end

endmodule
