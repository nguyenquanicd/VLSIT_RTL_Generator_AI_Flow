/*
 * Project      : VLSIT Common RTL library
 * Author       : Nguyen Quan and Claude Sonnet 5.5 (user)
 * AI Flow      : VLSIT RTL Generator AI Automation Flow
 * AI Flow Page : https://github.com/nguyenquanicd/VLSIT_RTL_Generator_AI_Model
 * Date         : 2026-10-22
 * Description  : Structural top of the asynchronous Gray FIFO with a software reset. It
 *                instantiates the write module, the read module and the FIFO storage and holds no
 *                logic. Write clock domain: i_clk_wr and the write interface. Read clock domain:
 *                i_clk_rd and the read interface. The two Gray pointers and the software reset
 *                request and acknowledge cross the domains inside m_vlsit_afifo_rd and
 *                m_vlsit_afifo_wr through m_vlsit_afifo_sync. i_rst_n_sw (active-low, write
 *                clock domain) starts the software reset; o_sw_rst_busy tells when the write
 *                side is released.
 */
`timescale 1ns/1ps

module m_vlsit_afifo_top #(
  // Parameter Description: number of entries of the FIFO. Sets the address and pointer widths.
  // Parameter values: power of 2, minimum 2; default is 8.
  // Parameter unit: count
  parameter logic [31:0] PARA_AFIFO_DEPTH = 8,
  // Parameter Description: data width of one entry.
  // Parameter values: 1 or more; default is 32.
  // Parameter unit: bit
  parameter logic [31:0] PARA_AFIFO_DATA_W = 32,
  // Parameter Description: synchronizer cell selection: 0 = bypass (no stage), 1 = two D flip-flop
  // cells, 2 = one 2-FF cell, 3 = one 3-FF cell, 4 = one 4-FF cell. It sets the number of stages
  // of the synchronizers of this module (0, 2, 2, 3, 4).
  // Parameter values: 0, 1, 2, 3, or 4; default is 2.
  // Parameter unit: none
  parameter logic [31:0] PARA_AFIFO_CELL_TYPE = 2,
  // Parameter Description: 0 = RTL array storage, 1 = library SRAM wrapper.
  // Parameter values: 0 or 1; default is 0.
  // Parameter unit: none
  parameter logic [31:0] PARA_AFIFO_MEM_USE_MACRO = 0,
  localparam logic [31:0] LPARA_ADDR_W = $clog2(PARA_AFIFO_DEPTH),
  localparam logic [31:0] LPARA_PTR_W = LPARA_ADDR_W + 32'd1
) (
  // Write clock and reset
  input  wire                          i_clk_wr,
  input  wire                          i_rst_n_wr,

  // Write interface
  input  wire                          i_wr_en,
  input  wire  [PARA_AFIFO_DATA_W-1:0] i_wr_data,
  input  wire  [LPARA_PTR_W-1:0]       i_full_thr,
  output logic                         o_full,
  output logic                         o_full_thr,
  output logic                         o_overflow,

  // Software reset
  input  wire                          i_rst_n_sw,
  output logic                         o_sw_rst_busy,

  // Read clock and reset
  input  wire                          i_clk_rd,
  input  wire                          i_rst_n_rd,

  // Read interface
  input  wire                          i_rd_en,
  input  wire  [LPARA_PTR_W-1:0]       i_empty_thr,
  output logic [PARA_AFIFO_DATA_W-1:0] o_rd_data,
  output logic                         o_empty,
  output logic                         o_empty_thr,
  output logic                         o_underflow
);

  // Interconnect declarations
  logic [LPARA_PTR_W-1:0] w_wr_gray;
  logic [LPARA_PTR_W-1:0] w_rd_gray;
  logic w_req_wr;
  logic w_ack_rd;
  logic w_mem_wr_en;
  logic [LPARA_ADDR_W-1:0] w_mem_wr_addr;
  logic [PARA_AFIFO_DATA_W-1:0] w_mem_wr_data;
  logic [LPARA_ADDR_W-1:0] w_mem_rd_addr;
  logic [PARA_AFIFO_DATA_W-1:0] w_mem_rd_data;

  // Write side: write pointer, full flags, overflow, software reset FSM, memory write port.
  m_vlsit_afifo_wr #(
    .PARA_AFIFO_DEPTH         (PARA_AFIFO_DEPTH),
    .PARA_AFIFO_DATA_W        (PARA_AFIFO_DATA_W),
    .PARA_AFIFO_CELL_TYPE         (PARA_AFIFO_CELL_TYPE)
  ) u_vlsit_afifo_wr (
    .i_clk_wr        (i_clk_wr),
    .i_rst_n_wr      (i_rst_n_wr),
    .i_wr_en         (i_wr_en),
    .i_wr_data       (i_wr_data),
    .i_full_thr      (i_full_thr),
    .i_rst_n_sw    (i_rst_n_sw),
    .i_rd_gray       (w_rd_gray),
    .i_ack_rd        (w_ack_rd),
    .o_full          (o_full),
    .o_full_thr      (o_full_thr),
    .o_overflow      (o_overflow),
    .o_sw_rst_busy (o_sw_rst_busy),
    .o_wr_gray       (w_wr_gray),
    .o_req_wr        (w_req_wr),
    .o_mem_wr_en     (w_mem_wr_en),
    .o_mem_wr_addr   (w_mem_wr_addr),
    .o_mem_wr_data   (w_mem_wr_data)
  );

  // Read side: read pointer, empty flags, underflow, software reset FSM, memory read port.
  m_vlsit_afifo_rd #(
    .PARA_AFIFO_DEPTH         (PARA_AFIFO_DEPTH),
    .PARA_AFIFO_DATA_W        (PARA_AFIFO_DATA_W),
    .PARA_AFIFO_CELL_TYPE         (PARA_AFIFO_CELL_TYPE)
  ) u_vlsit_afifo_rd (
    .i_clk_rd        (i_clk_rd),
    .i_rst_n_rd      (i_rst_n_rd),
    .i_rd_en         (i_rd_en),
    .i_empty_thr     (i_empty_thr),
    .i_wr_gray       (w_wr_gray),
    .i_req_wr        (w_req_wr),
    .i_mem_rd_data   (w_mem_rd_data),
    .o_rd_data       (o_rd_data),
    .o_empty         (o_empty),
    .o_empty_thr     (o_empty_thr),
    .o_underflow     (o_underflow),
    .o_rd_gray       (w_rd_gray),
    .o_ack_rd        (w_ack_rd),
    .o_mem_rd_addr   (w_mem_rd_addr)
  );

  // FIFO storage: write port in the write domain, read port in the read domain.
  m_vlsit_afifo_mem #(
    .PARA_AFIFO_DEPTH         (PARA_AFIFO_DEPTH),
    .PARA_AFIFO_DATA_W        (PARA_AFIFO_DATA_W),
    .PARA_AFIFO_MEM_USE_MACRO (PARA_AFIFO_MEM_USE_MACRO)
  ) u_vlsit_afifo_mem (
    .i_clk_wr        (i_clk_wr),
    .i_wr_en         (w_mem_wr_en),
    .i_wr_addr       (w_mem_wr_addr),
    .i_wr_data       (w_mem_wr_data),
    .i_clk_rd        (i_clk_rd),
    .i_rd_addr       (w_mem_rd_addr),
    .o_rd_data       (w_mem_rd_data)
  );

endmodule
