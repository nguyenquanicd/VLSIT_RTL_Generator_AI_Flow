/*
 * Project      : Timer IP
 * Author       : Nguyen Quan (user)
 * AI Flow      : VLSIT RTL Generator AI Automation Flow
 * AI Flow Page : https://github.com/nguyenquanicd/VLSIT_RTL_Generator_AI_Model
 * Date         : 2026-11-03
 * Description  : Tracks successful low/high CSR writes and activates complete timing values only
 *                at the selected shared-update, timeout-interval, or one-pulse-trigger boundary.
 */
`timescale 1ns/1ps

module m_vlsit_timer_timing_stage #(
  // Parameter Description: width of the timing value assembled from APB words.
  // Parameter values: 32 or 64; default is 32.
  // Parameter unit: bit
  parameter logic [31:0] PARA_VALUE_WIDTH = 32
) (
  // Timer clock and reset
  input  wire                         i_clk_timer,
  input  wire                         i_rst_n_timer,

  // CSR word-write events and the resulting stored value
  input  wire                         i_write_low,
  input  wire                         i_write_high,
  input  wire  [31:0]                 i_value_low,
  input  wire  [31:0]                 i_value_high,

  // Value-activation event and value state
  input  wire                         i_activate,
  input  wire                         i_dma_update,
  input  wire  [PARA_VALUE_WIDTH-1:0] i_dma_value,
  output logic [PARA_VALUE_WIDTH-1:0] o_active_value,
  output logic [PARA_VALUE_WIDTH-1:0] o_pending_value,
  output logic                        o_pending_valid
);

  // Word-pair bookkeeping and active/pending values
  logic reg_low_seen;
  logic reg_high_seen;
  logic reg_pending_valid;
  logic [PARA_VALUE_WIDTH-1:0] reg_active_value;
  logic [PARA_VALUE_WIDTH-1:0] reg_pending_value;
  logic w_pair_complete;
  logic [PARA_VALUE_WIDTH-1:0] w_new_value;

  // A 32-bit profile completes on its low word; a 64-bit profile requires both write events.
  assign w_pair_complete = (PARA_VALUE_WIDTH == 32) ? i_write_low :
                           ((reg_low_seen | i_write_low) & (reg_high_seen | i_write_high));
  generate
    if (PARA_VALUE_WIDTH == 32) begin : gen_value_32
      assign w_new_value = i_value_low;
    end else begin : gen_value_64
      assign w_new_value = {i_value_high, i_value_low};
    end
  endgenerate
  assign o_active_value = reg_active_value;
  assign o_pending_value = reg_pending_value;
  assign o_pending_valid = reg_pending_valid;

  // Hold each half until both successful writes are observed, then activate the whole value only
  // at the configured boundary. A new complete value arriving on an activation edge stays pending.
  always_ff @(posedge i_clk_timer, negedge i_rst_n_timer) begin : p_ff_timing_stage
    if (!i_rst_n_timer) begin
      reg_low_seen <= 1'b0;
      reg_high_seen <= 1'b0;
      reg_pending_valid <= 1'b0;
      reg_active_value <= '0;
      reg_pending_value <= '0;
    end else begin
      if (i_write_low)
        reg_low_seen <= 1'b1;
      if (i_write_high)
        reg_high_seen <= 1'b1;
      if (w_pair_complete) begin
        reg_pending_value <= w_new_value;
        reg_pending_valid <= 1'b1;
        reg_low_seen <= 1'b0;
        reg_high_seen <= 1'b0;
      end
      if (i_activate & reg_pending_valid) begin
        reg_active_value <= reg_pending_value;
        reg_pending_valid <= 1'b0;
      end
      if (i_dma_update)
        reg_active_value <= i_dma_value;
    end
  end

endmodule
