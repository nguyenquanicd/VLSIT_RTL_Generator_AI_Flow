/*
 * Project      : VLSIT Common RTL library
 * Author       : Nguyen Quan and Claude Sonnet 5.5 (user)
 * AI Flow      : VLSIT RTL Generator AI Automation Flow
 * AI Flow Page : https://github.com/nguyenquanicd/VLSIT_RTL_Generator_AI_Model
 * Date         : 2026-10-25
 * Description  : CRC calculator that processes one configurable-width chunk per clock cycle.
 */
`timescale 1ns/1ps

module m_crc_parallel_crcw #(
  // Parameter Description: width of the CRC state and generator polynomial.
  // Parameter values: 2 or greater; default is 8.
  // Parameter unit: bit
  parameter logic [31:0] PARA_CRC_W = 32'd8,
  // Parameter Description: width of one input data word.
  // Parameter values: PARA_CAL_W or a multiple of it; default is 32.
  // Parameter unit: bit
  parameter logic [31:0] PARA_DATA_W = 32'd32,
  // Parameter Description: width of one CRC calculation chunk; must equal PARA_CRC_W.
  // Parameter values: equal to PARA_CRC_W; default is 8.
  // Parameter unit: bit
  parameter logic [31:0] PARA_CAL_W = PARA_CRC_W,
  localparam logic [31:0] LPARA_CAL_NUM = PARA_DATA_W / PARA_CAL_W,
  localparam logic [31:0] LPARA_CNT_W =
    (LPARA_CAL_NUM <= 32'd1) ? 32'd1 : $clog2(LPARA_CAL_NUM),
  localparam logic [31:0] LPARA_TMP_W = PARA_CAL_W * PARA_CRC_W
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
      $fatal(1, "m_crc_parallel_crcw: PARA_CRC_W must be at least 2");
    if (PARA_CAL_W != PARA_CRC_W)
      $fatal(1, "m_crc_parallel_crcw: PARA_CAL_W must equal PARA_CRC_W");
    if (PARA_DATA_W < PARA_CAL_W)
      $fatal(1, "m_crc_parallel_crcw: PARA_DATA_W must be at least PARA_CAL_W");
    if ((PARA_DATA_W % PARA_CAL_W) != 32'd0)
      $fatal(1, "m_crc_parallel_crcw: PARA_DATA_W must divide evenly into chunks");
  end
`endif

  // Internal signal declarations
  logic [PARA_DATA_W-1:0] reg_data;
  logic [PARA_CRC_W-1:0] reg_gen_poly;
  logic [PARA_CRC_W-1:0] reg_crc_seq;
  logic reg_crc_ready;
  logic [LPARA_TMP_W-1:0] w_sub_crc;
  logic [PARA_CAL_W+PARA_CRC_W-1:0] w_data_cal;
  logic [PARA_CAL_W-1:0] w_xor_input;
  logic [LPARA_CNT_W-1:0] reg_shift_cnt;
  logic w_set_ready;
  logic w_accept;

  // Expose the registered CRC state and ready flag through the output ports.
  assign o_crc_seq = reg_crc_seq;
  // Route the registered ready state to the module output.
  assign o_crc_ready = reg_crc_ready;

  // Request qualification and the current chunk state select one transaction's data and polynomial.
  assign w_accept = i_ctrl_en && o_crc_ready;
  // Combine the next data chunk with the current CRC state.
  assign w_xor_input = reg_data[PARA_DATA_W-1 -: PARA_CAL_W] ^ o_crc_seq;
  // Append zero bits to form the CRC recurrence input.
  assign w_data_cal = {w_xor_input, {PARA_CRC_W{1'b0}}};
  // Detect completion of the final CRC data chunk.
  assign w_set_ready =
    (reg_shift_cnt == $bits(reg_shift_cnt)'(LPARA_CAL_NUM - 32'd1));

  // The polynomial and data are captured on acceptance; data shifts one chunk while busy.
  always_ff @(posedge i_clk_core) begin : p_ff_input_capture
    if (w_accept)
      reg_gen_poly <= i_gen_poly;

    if (w_accept)
      reg_data <= i_data;
    else if (!o_crc_ready)
      reg_data <= $bits(reg_data)'(reg_data << PARA_CAL_W);
  end

  // The counter clears at acceptance and completion, then advances once per active chunk.
  always_ff @(posedge i_clk_core, negedge i_rst_n_core) begin : p_ff_shift_cnt
    if (!i_rst_n_core)
      reg_shift_cnt <= '0;
    else if (o_crc_ready || w_set_ready)
      reg_shift_cnt <= '0;
    else
      reg_shift_cnt <= $bits(reg_shift_cnt)'(reg_shift_cnt + 1'b1);
  end

  // Ready remains low until all chunks of the accepted word have been processed.
  always_ff @(posedge i_clk_core, negedge i_rst_n_core) begin : p_ff_crc_ready
    if (!i_rst_n_core)
      reg_crc_ready <= 1'b1;
    else if (w_accept)
      reg_crc_ready <= 1'b0;
    else if (w_set_ready)
      reg_crc_ready <= 1'b1;
  end

  // Each generated stage advances one bit of the current chunk through the CRC recurrence.
  for (genvar gen_idx = 0; gen_idx < PARA_CAL_W; gen_idx++) begin : gen_crc_step
    if (gen_idx == 0) begin : gen_first
      // Compute one generated stage of the CRC recurrence.
      assign w_sub_crc[LPARA_TMP_W-1 -: PARA_CRC_W] =
        w_data_cal[PARA_CAL_W+PARA_CRC_W-1] ?
        (w_data_cal[PARA_CAL_W + PARA_CRC_W - 1 - 1 -: PARA_CRC_W] ^ reg_gen_poly) :
         w_data_cal[PARA_CAL_W + PARA_CRC_W - 1 - 1 -: PARA_CRC_W];
    end else begin : gen_nxt
      // Compute one generated stage of the CRC recurrence.
      assign w_sub_crc[LPARA_TMP_W-1-(gen_idx*PARA_CRC_W) -: PARA_CRC_W] =
        w_sub_crc[LPARA_TMP_W-1-((gen_idx-1)*PARA_CRC_W)] ?
        ({w_sub_crc[LPARA_TMP_W - 1 - ((gen_idx - 1) * PARA_CRC_W) - 1 -: (PARA_CRC_W-1)],
          w_data_cal[PARA_CAL_W-1-gen_idx]} ^ reg_gen_poly) :
         {w_sub_crc[LPARA_TMP_W - 1 - ((gen_idx - 1) * PARA_CRC_W) - 1 -: (PARA_CRC_W-1)],
          w_data_cal[PARA_CAL_W-1-gen_idx]};
    end
  end

  // The CRC register clears for each accepted word and updates once per active chunk.
  always_ff @(posedge i_clk_core, negedge i_rst_n_core) begin : p_ff_crc_seq
    if (!i_rst_n_core)
      reg_crc_seq <= '0;
    else if (w_accept)
      reg_crc_seq <= '0;
    else if (!o_crc_ready)
      reg_crc_seq <= w_sub_crc[PARA_CRC_W-1:0];
  end

endmodule
