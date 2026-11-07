/*
 * Project      : Timer IP
 * Author       : Nguyen Quan (user)
 * AI Flow      : VLSIT RTL Generator AI Automation Flow
 * AI Flow Page : https://github.com/nguyenquanicd/VLSIT_RTL_Generator_AI_Model
 * Date         : 2026-11-03
 * Description  : One timer channel's capture qualification, compare/PWM output, timeout monitor,
 *                and non-retriggerable one-pulse engine. Implements DEC-020 and DEC-037.
 */
`timescale 1ns/1ps

module m_vlsit_timer_channel #(
  // Parameter Description: width of the shared counter and channel timing values.
  // Parameter values: 32 or 64; default is 32.
  // Parameter unit: bit
  parameter logic [31:0] PARA_COUNTER_WIDTH = 32,
  localparam logic [31:0] LPARA_MODE_CAP = 32'd1,
  localparam logic [31:0] LPARA_MODE_CMP = 32'd2,
  localparam logic [31:0] LPARA_MODE_PWM = 32'd3,
  localparam logic [31:0] LPARA_MODE_OPM = 32'd4,
  localparam logic [31:0] LPARA_ACT_SET = 32'd0,
  localparam logic [31:0] LPARA_ACT_CLR = 32'd1,
  localparam logic [31:0] LPARA_ACT_TGL = 32'd2,
  localparam logic [31:0] LPARA_EDGE_RISE = 32'd0,
  localparam logic [31:0] LPARA_EDGE_FALL = 32'd1,
  localparam logic [31:0] LPARA_EDGE_BOTH = 32'd2
) (
  // Timer clock and reset
  input  wire                           i_clk_timer,
  input  wire                           i_rst_n_timer,

  // Shared counter and channel configuration
  input  wire                           i_timer_enable,
  input  wire                           i_timer_tick,
  input  wire                           i_dir_down,
  input  wire  [PARA_COUNTER_WIDTH-1:0] i_count,
  input  wire  [PARA_COUNTER_WIDTH-1:0] i_compare,
  input  wire  [PARA_COUNTER_WIDTH-1:0] i_timeout_threshold,
  input  wire  [PARA_COUNTER_WIDTH-1:0] i_opm_width,
  input  wire  [2:0]                    i_mode,
  input  wire  [1:0]                    i_edge_sel,
  input  wire  [1:0]                    i_cmp_action,
  input  wire                           i_timeout_enable,
  input  wire                           i_timeout_start_mode,
  input  wire                           i_opm_sw_rearm_en,
  input  wire                           i_opm_rearm_cmd,
  input  wire                           i_output_polarity,
  input  wire                           i_idle_level,
  input  wire                           i_force_enable,
  input  wire                           i_force_value,

  // Filtered capture and selected one-pulse trigger edges
  input  wire                           i_capture_rising,
  input  wire                           i_capture_falling,
  input  wire                           i_trigger_rising,
  input  wire                           i_trigger_falling,

  // Channel events and status
  output logic                          o_capture_event,
  output logic                          o_capture_rising,
  output logic                          o_compare_event,
  output logic                          o_timeout_event,
  output logic                          o_opm_busy,
  output logic                          o_opm_armed,
  output logic                          o_timer_out
);

  // One-pulse state encoding: idle, trigger-to-output delay, and active output pulse.
  typedef enum logic [1:0] {
    ENUM_ST_IDLE  = 2'b00,
    ENUM_ST_DELAY = 2'b01,
    ENUM_ST_PULSE = 2'b10
  } opm_state_type_def;

  // Internal signal declarations
  opm_state_type_def reg_fsm_opm_current_state;
  opm_state_type_def w_fsm_opm_nxt_state;
  logic [PARA_COUNTER_WIDTH-1:0] reg_opm_elapsed;
  logic [PARA_COUNTER_WIDTH-1:0] reg_opm_active_delay;
  logic [PARA_COUNTER_WIDTH-1:0] reg_opm_active_width;
  logic [PARA_COUNTER_WIDTH-1:0] reg_timeout_elapsed;
  logic [PARA_COUNTER_WIDTH-1:0] reg_timeout_active_value;
  logic reg_timeout_active;
  logic reg_timeout_expired;
  logic reg_timeout_event;
  logic reg_compare_state;
  logic reg_opm_armed;
  logic reg_opm_active_mode;
  logic reg_rearm_cmd_prev;
  logic w_capture_edge;
  logic w_trigger_edge;
  logic w_opm_accept;
  logic w_delay_done;
  logic w_width_done;
  logic w_pwm_active;
  logic w_wave_output;

  // Select configured capture and trigger edges.
  always_comb begin : p_com_edges
    w_capture_edge = 1'b0;
    w_trigger_edge = 1'b0;
    case (i_edge_sel)
      LPARA_EDGE_RISE[1:0]: begin
        w_capture_edge = i_capture_rising;
        w_trigger_edge = i_trigger_rising;
      end
      LPARA_EDGE_FALL[1:0]: begin
        w_capture_edge = i_capture_falling;
        w_trigger_edge = i_trigger_falling;
      end
      LPARA_EDGE_BOTH[1:0]: begin
        w_capture_edge = i_capture_rising | i_capture_falling;
        w_trigger_edge = i_trigger_rising | i_trigger_falling;
      end
      default: begin
        w_capture_edge = 1'b0;
        w_trigger_edge = 1'b0;
      end
    endcase
  end

  // Capture, compare, and one-pulse trigger events are qualified by their selected channel mode.
  assign o_capture_event  = i_timer_enable & (i_mode == LPARA_MODE_CAP[2:0]) & w_capture_edge;
  assign o_capture_rising = o_capture_event & i_capture_rising;
  assign o_compare_event  = i_timer_enable & i_timer_tick &
                            ((i_mode == LPARA_MODE_CMP[2:0]) | (i_mode == LPARA_MODE_PWM[2:0])) &
                            (i_count == i_compare);
  assign w_opm_accept = i_timer_enable & (i_mode == LPARA_MODE_OPM[2:0]) &
                        reg_opm_active_mode & (reg_fsm_opm_current_state == ENUM_ST_IDLE) &
                        reg_opm_armed & w_trigger_edge;
  assign w_delay_done = (reg_opm_active_delay == '0) |
                        ((reg_opm_elapsed + 1'b1) >= reg_opm_active_delay);
  assign w_width_done = (reg_opm_active_width == '0) |
                        ((reg_opm_elapsed + 1'b1) >= reg_opm_active_width);
  assign o_opm_busy   = (reg_fsm_opm_current_state != ENUM_ST_IDLE);
  assign o_opm_armed  = reg_opm_armed;
  assign o_timeout_event = reg_timeout_event;

  // One-pulse next-state logic: a busy trigger is ignored and only an idle channel can accept one.
  always_comb begin : p_com_opm_nxt
    w_fsm_opm_nxt_state = reg_fsm_opm_current_state;
    case (reg_fsm_opm_current_state)
      ENUM_ST_IDLE: begin
        if (w_opm_accept) begin
          if (i_compare == '0)
            w_fsm_opm_nxt_state = ENUM_ST_PULSE;
          else
            w_fsm_opm_nxt_state = ENUM_ST_DELAY;
        end
      end
      ENUM_ST_DELAY: begin
        if (i_timer_tick & w_delay_done)
          w_fsm_opm_nxt_state = ENUM_ST_PULSE;
      end
      ENUM_ST_PULSE: begin
        if (i_timer_tick & w_width_done)
          w_fsm_opm_nxt_state = ENUM_ST_IDLE;
      end
      default: w_fsm_opm_nxt_state = ENUM_ST_IDLE;
    endcase
    if (!i_timer_enable | (i_mode != LPARA_MODE_OPM[2:0]))
      w_fsm_opm_nxt_state = ENUM_ST_IDLE;
  end

  // The one-pulse current state is held in its own sequential process for FSM extraction.
  always_ff @(posedge i_clk_timer, negedge i_rst_n_timer) begin : p_ff_fsm_opm
    if (!i_rst_n_timer)
      reg_fsm_opm_current_state <= ENUM_ST_IDLE;
    else
      reg_fsm_opm_current_state <= w_fsm_opm_nxt_state;
  end

  // Compare output action, timeout interval, and one-pulse timing state.
  always_ff @(posedge i_clk_timer, negedge i_rst_n_timer) begin : p_ff_channel
    if (!i_rst_n_timer) begin
      reg_compare_state       <= 1'b0;
      reg_opm_elapsed         <= '0;
      reg_opm_active_delay    <= '0;
      reg_opm_active_width    <= '0;
      reg_timeout_elapsed     <= '0;
      reg_timeout_active_value <= '0;
      reg_timeout_active      <= 1'b0;
      reg_timeout_expired     <= 1'b0;
      reg_opm_armed           <= 1'b1;
      reg_opm_active_mode     <= 1'b0;
      reg_rearm_cmd_prev      <= 1'b0;
      reg_timeout_event       <= 1'b0;
    end else begin
      reg_timeout_event <= 1'b0;
      reg_rearm_cmd_prev <= i_opm_rearm_cmd;
      reg_opm_active_mode <= i_timer_enable & (i_mode == LPARA_MODE_OPM[2:0]);

      if (i_timer_enable & (i_mode == LPARA_MODE_CMP[2:0]) & o_compare_event) begin
        case (i_cmp_action)
          LPARA_ACT_SET[1:0]: reg_compare_state <= 1'b1;
          LPARA_ACT_CLR[1:0]: reg_compare_state <= 1'b0;
          LPARA_ACT_TGL[1:0]: reg_compare_state <= ~reg_compare_state;
          default: reg_compare_state <= reg_compare_state;
        endcase
      end

      casez ({~i_timer_enable | (i_mode != LPARA_MODE_CAP[2:0]) | ~i_timeout_enable |
              (i_timeout_threshold == '0), o_capture_event,
              ~reg_timeout_active & ~i_timeout_start_mode,
              reg_timeout_active & ~reg_timeout_expired & i_timer_tick})
        4'b1???: begin
          reg_timeout_elapsed      <= '0;
          reg_timeout_active_value <= '0;
          reg_timeout_active       <= 1'b0;
          reg_timeout_expired      <= 1'b0;
        end
        4'b01??: begin
          reg_timeout_elapsed      <= '0;
          reg_timeout_active_value <= i_timeout_threshold;
          reg_timeout_active       <= 1'b1;
          reg_timeout_expired      <= 1'b0;
        end
        4'b001?: begin
          reg_timeout_elapsed      <= '0;
          reg_timeout_active_value <= i_timeout_threshold;
          reg_timeout_active       <= 1'b1;
          reg_timeout_expired      <= 1'b0;
        end
        4'b0001: begin
          if ((reg_timeout_elapsed + 1'b1) >= reg_timeout_active_value) begin
            reg_timeout_elapsed <= '0;
            reg_timeout_expired <= 1'b1;
            reg_timeout_event   <= 1'b1;
          end else begin
            reg_timeout_elapsed <= reg_timeout_elapsed + 1'b1;
          end
        end
        default: begin
          reg_timeout_elapsed      <= reg_timeout_elapsed;
          reg_timeout_active_value <= reg_timeout_active_value;
          reg_timeout_active       <= reg_timeout_active;
          reg_timeout_expired      <= reg_timeout_expired;
        end
      endcase

      casez ({~i_timer_enable | (i_mode != LPARA_MODE_OPM[2:0]), w_opm_accept,
              i_timer_tick & (reg_fsm_opm_current_state == ENUM_ST_DELAY) & w_delay_done,
              i_timer_tick & ((reg_fsm_opm_current_state == ENUM_ST_DELAY) |
                              (reg_fsm_opm_current_state == ENUM_ST_PULSE)),
              reg_fsm_opm_current_state == ENUM_ST_IDLE})
        5'b1????: begin
        reg_opm_elapsed <= '0;
        reg_opm_armed   <= 1'b1;
        end
        5'b01???: begin
          reg_opm_elapsed      <= '0;
          reg_opm_active_delay <= i_compare;
          reg_opm_active_width <= i_opm_width;
          reg_opm_armed        <= ~i_opm_sw_rearm_en;
        end
        5'b001??: begin
          reg_opm_elapsed <= '0;
        end
        5'b0001?: begin
          reg_opm_elapsed <= reg_opm_elapsed + 1'b1;
        end
        5'b00001: begin
          reg_opm_elapsed <= '0;
        end
        default: reg_opm_elapsed <= reg_opm_elapsed;
      endcase

      if (i_timer_enable & (i_mode == LPARA_MODE_OPM[2:0]) &
          (reg_fsm_opm_current_state == ENUM_ST_PULSE) & i_timer_tick & w_width_done &
          ~i_opm_sw_rearm_en)
        reg_opm_armed <= 1'b1;
      if (i_timer_enable & (i_mode == LPARA_MODE_OPM[2:0]) & i_opm_sw_rearm_en &
          i_opm_rearm_cmd & ~reg_rearm_cmd_prev &
          (reg_fsm_opm_current_state == ENUM_ST_IDLE))
        reg_opm_armed <= 1'b1;
      if (i_timer_enable & (i_mode == LPARA_MODE_OPM[2:0]) & w_opm_accept)
        reg_opm_armed <= 1'b0;
      if (i_timer_enable & (i_mode == LPARA_MODE_OPM[2:0]) & ~reg_opm_active_mode)
        reg_opm_armed <= ~i_opm_sw_rearm_en;
    end
  end

  // PWM threshold semantics are deterministic in both count directions, including endpoints.
  always_comb begin : p_com_pwm
    w_pwm_active = 1'b0;
    if (i_dir_down)
      w_pwm_active = (i_count <= i_compare);
    else
      w_pwm_active = (i_count < i_compare);
  end

  // Apply mode waveform, polarity, idle level, and the physical output override in priority order.
  always_comb begin : p_com_output
    o_timer_out = 1'b0;
    w_wave_output = i_idle_level;
    if (i_timer_enable) begin
      case (i_mode)
        LPARA_MODE_CMP[2:0]: w_wave_output = reg_compare_state ^ i_output_polarity;
        LPARA_MODE_PWM[2:0]: w_wave_output = w_pwm_active ^ i_output_polarity;
        LPARA_MODE_OPM[2:0]: w_wave_output =
                          (reg_fsm_opm_current_state == ENUM_ST_PULSE) ^ i_output_polarity;
        default:        w_wave_output = i_idle_level;
      endcase
    end
    if (i_force_enable)
      o_timer_out = i_force_value;
    else
      o_timer_out = w_wave_output;
  end

endmodule
