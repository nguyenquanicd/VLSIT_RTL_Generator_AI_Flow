/*
 * Project      : Timer IP
 * Author       : Nguyen Quan and Codex
 * AI Flow      : VLSIT RTL Generator AI Automation Flow
 * AI Flow Page : https://github.com/nguyenquanicd/VLSIT_RTL_Generator_AI_Model
 * Date         : 2026-11-03
 * Description  : Shared up/down counter with PERIOD reload, a fixed 16-bit prescaler and atomic
 *                shadow updates at the terminal-count boundary. Implements REQ-CNT-001..005.
 */
`timescale 1ns/1ps

module m_vlsit_timer_counter #(
  // Parameter Description: width of counter and all counter-derived timing values.
  // Parameter values: 32 or 64; default is 32.
  // Parameter unit: bit
  parameter logic [31:0] PARA_COUNTER_WIDTH = 32
) (
  // Timer clock and reset
  input  wire                           i_clk_timer,
  input  wire                           i_rst_n_timer,

  // Counter configuration
  input  wire                           i_enable,
  input  wire                           i_dir_down,
  input  wire  [PARA_COUNTER_WIDTH-1:0] i_period_shadow,
  input  wire  [15:0]                   i_prescale_shadow,
  input  wire                           i_period_commit,
  input  wire                           i_prescale_commit,

  // Counter state and events
  output logic [PARA_COUNTER_WIDTH-1:0] o_count,
  output logic                          o_tick,
  output logic                          o_update_event
);

  // Internal signal declarations
  logic [PARA_COUNTER_WIDTH-1:0] reg_period_active;
  logic [15:0] reg_prescale_active;
  logic [15:0] reg_prescale_count;
  logic [PARA_COUNTER_WIDTH-1:0] reg_count;
  logic w_terminal;

  // The prescaler divides by PSC+1; PSC zero therefore produces one tick per timer clock.
  assign o_tick = i_enable & (reg_prescale_count >= reg_prescale_active);
  assign w_terminal = i_dir_down ? (reg_count == '0) : (reg_count >= reg_period_active);
  assign o_update_event = o_tick & w_terminal;
  assign o_count = reg_count;

  // Counter, prescaler, and active timing values.
  always_ff @(posedge i_clk_timer, negedge i_rst_n_timer) begin : p_ff_counter
    if (!i_rst_n_timer) begin
      reg_count          <= '0;
      reg_period_active  <= '0;
      reg_prescale_active <= '0;
      reg_prescale_count <= '0;
    end else begin
      if (i_enable) begin
        if (o_tick) begin
          reg_prescale_count <= '0;
          if (o_update_event) begin
            if (i_dir_down) begin
              if (i_period_commit)
                reg_count <= i_period_shadow;
              else
                reg_count <= reg_period_active;
            end else begin
              reg_count <= '0;
            end
          end else if (i_dir_down) begin
            reg_count <= reg_count - 1'b1;
          end else begin
            reg_count <= reg_count + 1'b1;
          end
        end else begin
          reg_prescale_count <= reg_prescale_count + 1'b1;
        end
        if (o_update_event) begin
          if (i_period_commit)
            reg_period_active <= i_period_shadow;
          if (i_prescale_commit)
            reg_prescale_active <= i_prescale_shadow;
        end
      end
    end
  end

endmodule
