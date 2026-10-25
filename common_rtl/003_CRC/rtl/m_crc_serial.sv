/*
 * Project      : VLSIT Common RTL library
 * Author       : Nguyen Quan and Claude Sonnet 5.5 (user)
 * AI Flow      : VLSIT RTL Generator AI Automation Flow
 * AI Flow Page : https://github.com/nguyenquanicd/VLSIT_RTL_Generator_AI_Model
 * Date         : 2026-10-25
 * Description  : Serial CRC calculator with configurable polynomial taps and a residue checker.
 */
`timescale 1ns/1ps

module m_crc_serial #(
  localparam logic [31:0] LPARA_CRC_W = 32'd4
) (
  // Clock and reset
  input  wire                    i_clk_core,
  input  wire                    i_rst_n_core,

  // Serial CRC input
  input  wire                    i_ctrl_en,
  input  wire                    i_data_bit,
  input  wire  [LPARA_CRC_W-1:0] i_gen_poly,

  // CRC result and residue check
  input  wire                    i_chk_en,
  output logic [LPARA_CRC_W-1:0] o_crc_seq,
  output logic                   o_crc_err
);

  // Internal signal declarations
  logic [LPARA_CRC_W-1:0] w_crc_nxt;
  logic [LPARA_CRC_W-1:0] reg_crc_seq;
  logic reg_crc_err;

  // Expose the registered CRC state and residue check through the output ports.
  assign o_crc_seq = reg_crc_seq;
  // Route the registered residue check to the module output.
  assign o_crc_err = reg_crc_err;

  // Polynomial taps select which CRC state bits feed the serial recurrence.
  assign w_crc_nxt[0] = i_gen_poly[0] ?
                         i_data_bit ^ reg_crc_seq[LPARA_CRC_W-1] : i_data_bit;

  for (genvar gen_idx = 0; gen_idx < (LPARA_CRC_W - 1); gen_idx++) begin : gen_crc_tap
    // Compute the selected serial polynomial tap for this CRC stage.
    assign w_crc_nxt[gen_idx+1] = i_gen_poly[gen_idx+1] ?
                                   reg_crc_seq[gen_idx] ^ reg_crc_seq[LPARA_CRC_W-1] :
                                   reg_crc_seq[gen_idx];
  end

  // The serial recurrence advances when enabled and clears on the first disabled edge.
  always_ff @(posedge i_clk_core) begin : p_ff_crc_seq
    if (!i_rst_n_core)
      reg_crc_seq <= '0;
    else if (i_ctrl_en)
      reg_crc_seq <= w_crc_nxt;
    else
      reg_crc_seq <= '0;
  end

  // The checker captures the old residue on an enabled idle edge before the clear takes effect.
  always_ff @(posedge i_clk_core) begin : p_ff_crc_err
    if (!i_rst_n_core)
      reg_crc_err <= 1'b0;
    else if (i_chk_en && !i_ctrl_en)
      reg_crc_err <= |o_crc_seq;
    else
      reg_crc_err <= 1'b0;
  end

endmodule
