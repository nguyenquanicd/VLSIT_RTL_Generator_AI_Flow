/*
 * Project      : Timer IP
 * Author       : Nguyen Quan and Codex
 * AI Flow      : VLSIT RTL Generator AI Automation Flow
 * AI Flow Page : https://github.com/nguyenquanicd/VLSIT_RTL_Generator_AI_Model
 * Date         : 2026-11-03
 * Description  : Synchronizes one asynchronous capture input and accepts a new level after the
 *                configured number of equal timer-clock samples at the selected sample interval.
 *                Implements REQ-CAP-001..003, DEC-012 and DEC-037.
 */
`timescale 1ns/1ps

module m_vlsit_timer_input_filter (
  // Timer clock and reset
  input  wire        i_clk_timer,
  input  wire        i_rst_n_timer,

  // Asynchronous pin and filter configuration
  input  wire        i_capture_async,
  input  wire  [2:0] i_sample_div,
  input  wire  [3:0] i_sample_n,

  // Qualified input and edge events
  output logic       o_filtered,
  output logic       o_rising,
  output logic       o_falling
);

  // Internal signal declarations
  logic       w_capture_sync;
  logic [5:0] reg_sample_count;
  logic [4:0] reg_equal_count;
  logic       reg_candidate;
  logic       reg_filtered;
  logic       reg_rising;
  logic       reg_falling;
  logic       w_sample_tick;
  logic [5:0] w_sample_period;

  // Synchronizer: keep the asynchronous pin outside the timer-core logic until two stages pass.
  m_vlsit_afifo_cell_sync #(
    .PARA_AFIFO_CELL_RST_VAL (32'd0),
    .PARA_AFIFO_CELL_TYPE    (32'd1)
  ) u_capture_sync (
    .i_clk_dst   (i_clk_timer),
    .i_rst_n_dst (i_rst_n_timer),
    .i_d         (i_capture_async),
    .o_q         (w_capture_sync)
  );

  // Select the programmed sample interval in timer-clock cycles.
  always_comb begin : p_com_sample_period
    w_sample_period = 6'd1;
    case (i_sample_div)
      3'd0:    w_sample_period = 6'd1;
      3'd1:    w_sample_period = 6'd2;
      3'd2:    w_sample_period = 6'd4;
      3'd3:    w_sample_period = 6'd8;
      3'd4:    w_sample_period = 6'd16;
      3'd5:    w_sample_period = 6'd32;
      default: w_sample_period = 6'd1;
    endcase
  end

  // A sample is taken once for each selected interval; the /1 mode samples every timer clock.
  assign w_sample_tick = (reg_sample_count >= (w_sample_period - 1'b1));

  // Sample divider, stable-level qualification, and one-cycle edge pulses.
  always_ff @(posedge i_clk_timer, negedge i_rst_n_timer) begin : p_ff_filter
    if (!i_rst_n_timer) begin
      reg_sample_count <= '0;
      reg_equal_count  <= '0;
      reg_candidate    <= 1'b0;
      reg_filtered     <= 1'b0;
      reg_rising       <= 1'b0;
      reg_falling      <= 1'b0;
    end else begin
      reg_rising  <= 1'b0;
      reg_falling <= 1'b0;
      if (w_sample_tick)
        reg_sample_count <= '0;
      else
        reg_sample_count <= reg_sample_count + 1'b1;

      if (w_sample_tick) begin
        casez ({(w_capture_sync == reg_filtered), (w_capture_sync != reg_candidate),
                (reg_equal_count >= {1'b0, i_sample_n})})
          3'b1??: begin
            reg_candidate   <= reg_filtered;
            reg_equal_count <= '0;
          end
          3'b01?: begin
            reg_candidate <= w_capture_sync;
            if (i_sample_n == 4'd0) begin
              reg_filtered    <= w_capture_sync;
              reg_equal_count <= '0;
              reg_rising      <= w_capture_sync;
              reg_falling     <= ~w_capture_sync;
            end else begin
              reg_equal_count <= 5'd1;
            end
          end
          3'b001: begin
            reg_filtered    <= reg_candidate;
            reg_equal_count <= '0;
            reg_rising      <= reg_candidate;
            reg_falling     <= ~reg_candidate;
          end
          3'b000: reg_equal_count <= reg_equal_count + 1'b1;
          default: begin
            reg_candidate   <= reg_candidate;
            reg_equal_count <= reg_equal_count;
          end
        endcase
      end
    end
  end

  // Filtered level output remains stable between accepted transitions.
  assign o_filtered = reg_filtered;
  assign o_rising   = reg_rising;
  assign o_falling  = reg_falling;

endmodule
