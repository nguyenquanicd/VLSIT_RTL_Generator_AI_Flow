/*
 * Project      : QSPI_Controller
 * Author       : Nguyen Quan (user)
 * AI Flow      : VLSIT RTL Generator AI Automation Flow
 * AI Flow Page : https://github.com/nguyenquanicd/VLSIT_RTL_Generator_AI_Model
 * Date         : 2026-11-02
 * Description  : APB target TX head for first-bit setup and tokenized sample-domain acknowledgement
 *                (DEC-017, DEC-018). Payload stays stable until the full word is sampled.
 */
`timescale 1ns/1ps

module m_qspi_target_tx_head (
  // APB source clock and reset
  input  wire         i_clk_apb,
  input  wire         i_rst_n_apb,

  // APB write and status
  input  wire         i_head_push,
  input  wire  [31:0] i_head_data,
  output logic        o_head_full,
  output logic [31:0] o_head_data,
  output logic        o_head_token,

  // Target sample-edge clock and reset
  input  wire         i_clk_tgt_sample,
  input  wire         i_rst_n_tgt_sample,

  // Target consumption event
  input  wire         i_head_pop
);

  // APB-owned payload and valid state; payload remains stable during the bundled-data transfer.
  logic [31:0] reg_head_data_apb;
  logic reg_head_full_apb;
  logic reg_head_token_apb;
  logic reg_ack_tgl_tgt;
  logic reg_ack_sync_1;
  logic reg_ack_sync_2;
  logic reg_ack_seen_apb;

  // Target acknowledgement synchronization and APB head-slot update.
  always_ff @(posedge i_clk_apb, negedge i_rst_n_apb) begin : p_ff_head_apb
    if (!i_rst_n_apb) begin
      reg_head_data_apb <= 32'd0;
      reg_head_full_apb <= 1'b0;
      reg_head_token_apb <= 1'b0;
      reg_ack_sync_1 <= 1'b0;
      reg_ack_sync_2 <= 1'b0;
      reg_ack_seen_apb <= 1'b0;
    end else begin
      reg_ack_sync_1 <= reg_ack_tgl_tgt;
      reg_ack_sync_2 <= reg_ack_sync_1;
      if (reg_ack_sync_2 != reg_ack_seen_apb) begin
        reg_ack_seen_apb <= reg_ack_sync_2;
        reg_head_full_apb <= 1'b0;
      end else if (i_head_push && !reg_head_full_apb) begin
        reg_head_data_apb <= i_head_data;
        reg_head_full_apb <= 1'b1;
        reg_head_token_apb <= ~reg_head_token_apb;
      end
    end
  end

  // Target acknowledges a head token once, after its full word has been sampled.
  always_ff @(posedge i_clk_tgt_sample, negedge i_rst_n_tgt_sample) begin : p_ff_head_tgt
    if (!i_rst_n_tgt_sample)
      reg_ack_tgl_tgt <= 1'b0;
    else if (i_head_pop)
      reg_ack_tgl_tgt <= o_head_token;
  end

  // Bundled-data outputs are stable while full; the target consumes the head before the APB slot
  // is released by the synchronized acknowledgement.
  always_comb begin : p_com_head_out
    o_head_full = reg_head_full_apb;
    o_head_data = reg_head_data_apb;
    o_head_token = reg_head_token_apb;
  end

endmodule
