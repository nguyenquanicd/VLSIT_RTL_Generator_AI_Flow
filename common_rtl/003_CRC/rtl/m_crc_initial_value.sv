/*
 * Project      : VLSIT Common RTL library
 * Author       : Nguyen Quan and Claude Sonnet 5.5 (user)
 * AI Flow      : VLSIT RTL Generator AI Automation Flow
 * AI Flow Page : https://github.com/nguyenquanicd/VLSIT_RTL_Generator_AI_Model
 * Date         : 2026-10-25
 * Description  : Serially processes payload bits after loading the CRC initial state from a word.
 */
`timescale 1ns/1ps

module m_crc_initial_value #(
  // Parameter Description: width of the CRC state and generator polynomial.
  // Parameter values: 2 or greater; default is 8.
  // Parameter unit: bit
  parameter logic [31:0] PARA_CRC_W = 32'd8,
  // Parameter Description: width of the input word containing the initial state and payload.
  // Parameter values: greater than PARA_CRC_W; default is 16.
  // Parameter unit: bit
  parameter logic [31:0] PARA_DATA_W = 32'd16,
  localparam logic [31:0] LPARA_DATA_LSB_W = PARA_DATA_W - PARA_CRC_W,
  localparam logic [31:0] LPARA_CNT_W = $clog2(PARA_DATA_W)
) (
  // Clock and reset
  input  wire                    i_clk_core,
  input  wire                    i_rst_n_core,

  // CRC request and result
  input  wire                    i_ctrl_en,
  input  wire  [PARA_DATA_W-1:0] i_data,
  input  wire  [PARA_CRC_W-1:0]  i_gen_poly,
  output logic [PARA_CRC_W-1:0]  o_crc_seq,
  output logic                   o_crc_ready
);

`ifndef VLSIT_SYNTHESIS
  initial begin
    if (PARA_CRC_W < 32'd2)
      $fatal(1, "m_crc_initial_value: PARA_CRC_W must be at least 2");
    if (PARA_DATA_W <= PARA_CRC_W)
      $fatal(1, "m_crc_initial_value: PARA_DATA_W must exceed PARA_CRC_W");
  end
`endif

  // Internal signal declarations
  logic [LPARA_DATA_LSB_W-1:0] reg_data;
  logic [PARA_CRC_W-1:0] reg_gen_poly;
  logic [PARA_CRC_W-1:0] reg_crc_seq;
  logic reg_cal_sts;
  logic [LPARA_CNT_W-1:0] reg_cnt;
  logic w_clear_cnt;
  logic w_accept;

  // Expose the registered CRC state through the result port.
  assign o_crc_seq = reg_crc_seq;

  // Request qualification and counter completion determine when a word is accepted.
  assign w_accept = i_ctrl_en && o_crc_ready;
  // Detect the final processing count for the current input word.
  assign w_clear_cnt =
    (reg_cnt == $bits(reg_cnt)'(PARA_DATA_W - 32'd1));
  // Route the registered ready state to the module output.
  assign o_crc_ready = !reg_cal_sts;

  // Calculation status stays active until the final payload and appended zero bits are consumed.
  always_ff @(posedge i_clk_core, negedge i_rst_n_core) begin : p_ff_cal_sts
    if (!i_rst_n_core)
      reg_cal_sts <= 1'b0;
    else if (reg_cal_sts && w_clear_cnt)
      reg_cal_sts <= 1'b0;
    else if (w_accept)
      reg_cal_sts <= 1'b1;
  end

  // The polynomial is captured with each accepted word and remains fixed during its calculation.
  always_ff @(posedge i_clk_core) begin : p_ff_gen_poly
    if (w_accept)
      reg_gen_poly <= i_gen_poly;
  end

  // The payload register shifts toward its most-significant bit as each serial step completes.
  always_ff @(posedge i_clk_core) begin : p_ff_data
    if (w_accept)
      reg_data <= i_data[LPARA_DATA_LSB_W-1:0];
    else if (reg_cal_sts)
      reg_data <= $bits(reg_data)'(reg_data << 1'b1);
  end

  // The counter tracks the fixed number of processing clocks for one accepted word.
  always_ff @(posedge i_clk_core, negedge i_rst_n_core) begin : p_ff_cnt
    if (!i_rst_n_core)
      reg_cnt <= '0;
    else if (o_crc_ready || w_clear_cnt)
      reg_cnt <= '0;
    else if (reg_cal_sts)
      reg_cnt <= $bits(reg_cnt)'(reg_cnt + 1'b1);
  end

  // The CRC state loads the input word's upper bits, then consumes payload and appended zeros.
  always_ff @(posedge i_clk_core, negedge i_rst_n_core) begin : p_ff_crc_seq
    if (!i_rst_n_core)
      reg_crc_seq <= '0;
    else if (w_accept)
      reg_crc_seq <= i_data[PARA_DATA_W-1 -: PARA_CRC_W];
    else if (reg_cal_sts) begin
      if (reg_crc_seq[PARA_CRC_W-1])
        reg_crc_seq <= {reg_crc_seq[PARA_CRC_W-2:0], reg_data[LPARA_DATA_LSB_W-1]} ^
                     reg_gen_poly;
      else
        reg_crc_seq <= {reg_crc_seq[PARA_CRC_W-2:0], reg_data[LPARA_DATA_LSB_W-1]};
    end
  end

endmodule
