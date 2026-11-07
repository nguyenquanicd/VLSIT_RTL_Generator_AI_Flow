/*
 * Project      : Timer IP
 * Author       : Nguyen Quan and Codex
 * AI Flow      : VLSIT RTL Generator AI Automation Flow
 * AI Flow Page : https://github.com/nguyenquanicd/VLSIT_RTL_Generator_AI_Model
 * Date         : 2026-11-03
 * Description  : Measures period and active width for one PWM-input pair, retaining unread results
 *                and reporting dropped measurements. Implements REQ-CAP-006..012.
 */
`timescale 1ns/1ps

module m_vlsit_timer_pwm_input #(
  // Parameter Description: width of the shared counter and measurement results.
  // Parameter values: 32 or 64; default is 32.
  // Parameter unit: bit
  parameter logic [31:0] PARA_COUNTER_WIDTH = 32
) (
  // Timer clock and reset
  input  wire                           i_clk_timer,
  input  wire                           i_rst_n_timer,

  // Input signal and shared counter
  input  wire                           i_enable,
  input  wire                           i_active_low,
  input  wire                           i_signal,
  input  wire  [PARA_COUNTER_WIDTH-1:0] i_count,

  // Software status clear
  input  wire                           i_clear_valid,
  input  wire                           i_clear_overrun,

  // Measurement result and event status
  output logic [PARA_COUNTER_WIDTH-1:0] o_period,
  output logic [PARA_COUNTER_WIDTH-1:0] o_pulse_width,
  output logic                          o_valid,
  output logic                          o_overrun,
  output logic                          o_measure_event,
  output logic                          o_result_commit,
  output logic                          o_overrun_event
);

  // Internal signal declarations
  logic w_active;
  logic reg_have_start;
  logic reg_have_width;
  logic reg_valid;
  logic reg_overrun;
  logic reg_measure_event;
  logic reg_result_commit;
  logic reg_overrun_event;
  logic reg_active_prev;
  logic [PARA_COUNTER_WIDTH-1:0] reg_start_count;
  logic [PARA_COUNTER_WIDTH-1:0] reg_last_start;
  logic [PARA_COUNTER_WIDTH-1:0] reg_last_width;
  logic [PARA_COUNTER_WIDTH-1:0] reg_period;
  logic [PARA_COUNTER_WIDTH-1:0] reg_pulse_width;
  logic w_start_event;
  logic w_end_event;

  // Active-low selection changes the physical input polarity before event detection.
  assign w_active = i_signal ^ i_active_low;
  assign w_start_event = i_enable & w_active & ~reg_active_prev;
  assign w_end_event = i_enable & ~w_active & reg_active_prev;
  assign o_valid = reg_valid;
  assign o_overrun = reg_overrun;
  assign o_period = reg_period;
  assign o_pulse_width = reg_pulse_width;
  assign o_measure_event = reg_measure_event;
  assign o_result_commit = reg_result_commit;
  assign o_overrun_event = reg_overrun_event;

  // Track the selected input transitions and preserve the most recent unread complete result.
  always_ff @(posedge i_clk_timer, negedge i_rst_n_timer) begin : p_ff_pwm_input
    if (!i_rst_n_timer) begin
      reg_active_prev  <= 1'b0;
      reg_have_start   <= 1'b0;
      reg_have_width   <= 1'b0;
      reg_valid        <= 1'b0;
      reg_overrun      <= 1'b0;
      reg_start_count  <= '0;
      reg_last_start   <= '0;
      reg_last_width   <= '0;
      reg_period        <= '0;
      reg_pulse_width   <= '0;
      reg_measure_event <= 1'b0;
      reg_result_commit <= 1'b0;
      reg_overrun_event <= 1'b0;
    end else begin
      reg_active_prev <= i_enable ? w_active : 1'b0;
      reg_measure_event <= 1'b0;
      reg_result_commit <= 1'b0;
      reg_overrun_event <= 1'b0;
      reg_overrun <= (reg_overrun & ~i_clear_overrun) |
                     (w_start_event & reg_have_start & reg_have_width &
                      reg_valid & ~i_clear_valid);

      if (i_clear_valid)
        reg_valid <= 1'b0;

      if (!i_enable) begin
        reg_have_start <= 1'b0;
        reg_have_width <= 1'b0;
      end else begin
        if (w_start_event) begin
          if (reg_have_start & reg_have_width) begin
            reg_measure_event <= 1'b1;
            if (~reg_valid | i_clear_valid) begin
              reg_period      <= i_count - reg_last_start;
              reg_pulse_width <= reg_last_width;
              reg_valid     <= 1'b1;
              reg_result_commit <= 1'b1;
            end else begin
              reg_overrun_event <= 1'b1;
            end
          end
          reg_last_start  <= i_count;
          reg_start_count <= i_count;
          reg_have_start  <= 1'b1;
          reg_have_width  <= 1'b0;
        end
        if (w_end_event & reg_have_start) begin
          reg_last_width <= i_count - reg_start_count;
          reg_have_width <= 1'b1;
        end
      end
    end
  end

endmodule
