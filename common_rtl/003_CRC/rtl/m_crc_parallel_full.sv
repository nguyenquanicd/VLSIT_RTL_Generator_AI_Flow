/*
 * Project      : VLSIT Common RTL library
 * Author       : Nguyen Quan and Claude Sonnet 5.5 (user)
 * AI Flow      : VLSIT RTL Generator AI Automation Flow
 * AI Flow Page : https://github.com/nguyenquanicd/VLSIT_RTL_Generator_AI_Model
 * Date         : 2026-10-25
 * Description  : Parallel CRC with initial/final XOR and configurable input/output reflection.
 */
`timescale 1ns/1ps

module m_crc_parallel_full #(
  // Parameter Description: width of the CRC state and generator polynomial.
  // Parameter values: 2 or greater; default is 16.
  // Parameter unit: bit
  parameter logic [31:0] PARA_CRC_W = 32'd16,
  // Parameter Description: width of one input data word, in whole bytes.
  // Parameter values: PARA_CRC_W or greater, divisible by 8; default is 32.
  // Parameter unit: bit
  parameter logic [31:0] PARA_DATA_W = 32'd32,
  localparam logic [31:0] LPARA_TMP_W = PARA_DATA_W * PARA_CRC_W
) (
  // Clock and reset
  input  wire                    i_clk_core,
  input  wire                    i_rst_n_core,

  // CRC request and input configuration
  input  wire                    i_ctrl_en,
  input  wire  [PARA_DATA_W-1:0] i_data,
  input  wire  [PARA_CRC_W-1:0]  i_gen_poly,
  input  wire  [PARA_CRC_W-1:0]  i_init_xor_value,
  input  wire                    i_ref_in_en,
  input  wire                    i_ref_out_en,
  input  wire  [PARA_CRC_W-1:0]  i_final_xor_value,

  // CRC result
  output logic [PARA_CRC_W-1:0]  o_crc_out,
  output logic                   o_crc_ready
);

`ifndef VLSIT_SYNTHESIS
  initial begin
    if (PARA_CRC_W < 32'd2)
      $fatal(1, "m_crc_parallel_full: PARA_CRC_W must be at least 2");
    if (PARA_DATA_W < PARA_CRC_W)
      $fatal(1, "m_crc_parallel_full: PARA_DATA_W must be at least PARA_CRC_W");
    if ((PARA_DATA_W % 32'd8) != 32'd0)
      $fatal(1, "m_crc_parallel_full: PARA_DATA_W must be divisible by 8");
  end
`endif

  // Internal signal declarations
  logic [PARA_DATA_W-1:0] w_xor_init_input;
  logic [PARA_DATA_W-1:0] w_ref_input;
  logic [PARA_DATA_W-1:0] reg_data;
  logic [PARA_CRC_W-1:0] reg_gen_poly;
  logic [LPARA_TMP_W-1:0] w_sub_crc;
  logic [PARA_DATA_W+PARA_CRC_W-1:0] w_data_cal;
  logic [PARA_CRC_W-1:0] reg_crc_seq;
  logic [PARA_CRC_W-1:0] reg_final_xor;
  logic [PARA_CRC_W-1:0] w_ref_output;
  logic reg_inv_out_en;
  logic reg_crc_ready;
  logic w_accept;

  // Expose the registered ready flag through the output port.
  assign o_crc_ready = reg_crc_ready;

  // Input reflection reverses each byte while preserving the byte order of the input word.
  for (genvar gen_idx = 0; gen_idx < (PARA_DATA_W / 32'd8); gen_idx++) begin : gen_ref_in
    // Reverse the selected bit within this input byte.
    assign w_ref_input[(gen_idx*8)+0] = i_data[(gen_idx*8)+7];
    // Reverse the selected bit within this input byte.
    assign w_ref_input[(gen_idx*8)+1] = i_data[(gen_idx*8)+6];
    // Reverse the selected bit within this input byte.
    assign w_ref_input[(gen_idx*8)+2] = i_data[(gen_idx*8)+5];
    // Reverse the selected bit within this input byte.
    assign w_ref_input[(gen_idx*8)+3] = i_data[(gen_idx*8)+4];
    // Reverse the selected bit within this input byte.
    assign w_ref_input[(gen_idx*8)+4] = i_data[(gen_idx*8)+3];
    // Reverse the selected bit within this input byte.
    assign w_ref_input[(gen_idx*8)+5] = i_data[(gen_idx*8)+2];
    // Reverse the selected bit within this input byte.
    assign w_ref_input[(gen_idx*8)+6] = i_data[(gen_idx*8)+1];
    // Reverse the selected bit within this input byte.
    assign w_ref_input[(gen_idx*8)+7] = i_data[(gen_idx*8)+0];
  end

  // The accepted input combines optional reflection with the initial CRC value.
  assign w_accept = i_ctrl_en && o_crc_ready;
  // Apply optional input reflection and the initial XOR value.
  assign w_xor_init_input =
    (i_ref_in_en ? w_ref_input : i_data) ^
    {i_init_xor_value, {(PARA_DATA_W-PARA_CRC_W){1'b0}}};
  // Append zero bits to form the CRC recurrence input.
  assign w_data_cal = {reg_data, {PARA_CRC_W{1'b0}}};

  // The data and polynomial are captured only for an accepted CRC transaction.
  always_ff @(posedge i_clk_core) begin : p_ff_input_capture
    if (w_accept) begin
      reg_gen_poly <= i_gen_poly;
      reg_data <= w_xor_init_input;
    end
  end

  // Ready marks whether the single-cycle parallel CRC transaction can accept new input.
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

  // The final recurrence stage updates the registered CRC state.
  always_ff @(posedge i_clk_core, negedge i_rst_n_core) begin : p_ff_crc_seq
    if (!i_rst_n_core)
      reg_crc_seq <= '0;
    else if (!o_crc_ready)
      reg_crc_seq <= w_sub_crc[PARA_CRC_W-1:0];
  end

  // Reflection and the captured final XOR transform the registered CRC result.
  for (genvar gen_idx = 0; gen_idx < PARA_CRC_W; gen_idx++) begin : gen_ref_out
    // Select the reflected bit for the final CRC result.
    assign w_ref_output[gen_idx] = reg_crc_seq[PARA_CRC_W-1-gen_idx];
  end

  // Output options are captured with the request so later input changes cannot alter its result.
  always_ff @(posedge i_clk_core, negedge i_rst_n_core) begin : p_ff_output_options
    if (!i_rst_n_core) begin
      reg_inv_out_en <= 1'b0;
      reg_final_xor <= '0;
    end else if (w_accept) begin
      reg_inv_out_en <= i_ref_out_en;
      reg_final_xor <= i_final_xor_value;
    end
  end

  // The output applies the captured reflection mode and final XOR value to the CRC state.
  assign o_crc_out = (reg_inv_out_en ? w_ref_output : reg_crc_seq) ^ reg_final_xor;

endmodule
