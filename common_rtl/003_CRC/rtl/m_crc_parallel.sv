/*
 * Project      : VLSIT Common RTL library
 * Author       : Nguyen Quan and Claude Sonnet 5.5 (user)
 * AI Flow      : VLSIT RTL Generator AI Automation Flow
 * AI Flow Page : https://github.com/nguyenquanicd/VLSIT_RTL_Generator_AI_Model
 * Date         : 2026-10-25
 * Description  : Parallel CRC calculator that processes one input word in one result cycle.
 */
`timescale 1ns/1ps

module m_crc_parallel #(
  // Parameter Description: width of the CRC state and generator polynomial.
  // Parameter values: 2 or greater; default is 8.
  // Parameter unit: bit
  parameter logic [31:0] PARA_CRC_W = 32'd8,
  // Parameter Description: width of one input data word.
  // Parameter values: 1 or greater; default is 16.
  // Parameter unit: bit
  parameter logic [31:0] PARA_DATA_W = 32'd16,
  localparam logic [31:0] LPARA_TMP_W = PARA_DATA_W * PARA_CRC_W
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
      $fatal(1, "m_crc_parallel: PARA_CRC_W must be at least 2");
    if (PARA_DATA_W < 32'd1)
      $fatal(1, "m_crc_parallel: PARA_DATA_W must be at least 1");
  end
`endif

  // Internal signal declarations
  logic [PARA_DATA_W-1:0] reg_data;
  logic [PARA_CRC_W-1:0] reg_gen_poly;
  logic [PARA_CRC_W-1:0] reg_crc_seq;
  logic reg_crc_ready;
  logic [LPARA_TMP_W-1:0] w_sub_crc;
  logic [PARA_DATA_W+PARA_CRC_W-1:0] w_data_cal;
  logic w_accept;

  // Expose the registered CRC state and ready flag through the output ports.
  assign o_crc_seq = reg_crc_seq;
  // Route the registered ready state to the module output.
  assign o_crc_ready = reg_crc_ready;

  // Request qualification selects the word and polynomial captured for this transaction.
  assign w_accept = i_ctrl_en && o_crc_ready;
  // Append zero bits to form the CRC recurrence input.
  assign w_data_cal = {reg_data, {PARA_CRC_W{1'b0}}};

  // The polynomial and data are captured together; the input word is not reset.
  always_ff @(posedge i_clk_core) begin : p_ff_input_capture
    if (w_accept) begin
      reg_gen_poly <= i_gen_poly;
      reg_data <= i_data;
    end
  end

  // Ready is low for the cycle in which the captured word's remainder is being produced.
  always_ff @(posedge i_clk_core, negedge i_rst_n_core) begin : p_ff_crc_ready
    if (!i_rst_n_core)
      reg_crc_ready <= 1'b1;
    else if (w_accept)
      reg_crc_ready <= 1'b0;
    else
      reg_crc_ready <= 1'b1;
  end

  // Each generated stage advances the MSB-first CRC recurrence by one input bit.
  for (genvar gen_idx = 0; gen_idx < PARA_DATA_W; gen_idx++) begin : gen_crc_step
    if (gen_idx == 0) begin : gen_first
      // Compute one generated stage of the CRC recurrence.
      assign w_sub_crc[LPARA_TMP_W-1 -: PARA_CRC_W] =
        w_data_cal[PARA_DATA_W+PARA_CRC_W-1] ?
        (w_data_cal[PARA_DATA_W + PARA_CRC_W - 1 - 1 -: PARA_CRC_W] ^ reg_gen_poly) :
         w_data_cal[PARA_DATA_W + PARA_CRC_W - 1 - 1 -: PARA_CRC_W];
    end else begin : gen_nxt
      // Compute one generated stage of the CRC recurrence.
      assign w_sub_crc[LPARA_TMP_W-1-(gen_idx*PARA_CRC_W) -: PARA_CRC_W] =
        w_sub_crc[LPARA_TMP_W-1-((gen_idx-1)*PARA_CRC_W)] ?
        ({w_sub_crc[LPARA_TMP_W - 1 - ((gen_idx - 1) * PARA_CRC_W) - 1 -: (PARA_CRC_W-1)],
          w_data_cal[PARA_DATA_W-1-gen_idx]} ^ reg_gen_poly) :
         {w_sub_crc[LPARA_TMP_W - 1 - ((gen_idx - 1) * PARA_CRC_W) - 1 -: (PARA_CRC_W-1)],
          w_data_cal[PARA_DATA_W-1-gen_idx]};
    end
  end

  // The final recurrence stage updates the visible CRC result.
  always_ff @(posedge i_clk_core, negedge i_rst_n_core) begin : p_ff_crc_seq
    if (!i_rst_n_core)
      reg_crc_seq <= '0;
    else if (!o_crc_ready)
      reg_crc_seq <= w_sub_crc[PARA_CRC_W-1:0];
  end

endmodule
