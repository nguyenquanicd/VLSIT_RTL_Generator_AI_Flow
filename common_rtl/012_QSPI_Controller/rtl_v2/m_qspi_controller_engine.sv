/*
 * Project      : QSPI_Controller
 * Author       : Nguyen Quan (user)
 * AI Flow      : VLSIT RTL Generator AI Automation Flow
 * AI Flow Page : https://github.com/nguyenquanicd/VLSIT_RTL_Generator_AI_Model
 * Date         : 2026-11-02
 * Description  : Controller timing engine for Standard, Dual, Quad and QPI command phases.
 *                It serializes opcode/address/data, applies programmed SCLK and CS timing, and
 *                reports TX/RX FIFO faults without claiming flash-internal operation status.
 */
`timescale 1ns/1ps

module m_qspi_controller_engine #(
  // Parameter Description: number of active-low controller chip-select outputs.
  // Parameter values: 1 through 16; default is 1.
  // Parameter unit: count
  parameter logic [31:0] PARA_NUM_CS = 32'd1,
  localparam logic [31:0] LPARA_CS_IDX_W = (PARA_NUM_CS > 32'd1) ? $clog2(PARA_NUM_CS) : 32'd1,
  localparam logic [31:0] LPARA_FMT_STD = 32'd0,
  localparam logic [31:0] LPARA_FMT_112 = 32'd1,
  localparam logic [31:0] LPARA_FMT_122 = 32'd2,
  localparam logic [31:0] LPARA_FMT_114 = 32'd3,
  localparam logic [31:0] LPARA_FMT_144 = 32'd4,
  localparam logic [31:0] LPARA_FMT_QPI = 32'd5,
  localparam logic [31:0] LPARA_LANES_1 = 32'd1,
  localparam logic [31:0] LPARA_LANES_2 = 32'd2,
  localparam logic [31:0] LPARA_LANES_4 = 32'd4,
  localparam logic [31:0] LPARA_BITS_PER_BYTE = 32'd8,
  localparam logic [31:0] LPARA_CS_WIDTH = 32'd8,
  localparam logic [31:0] LPARA_TX_WORD_BITS = 32'd32,
  localparam logic [31:0] LPARA_BYTE_LAST_IDX = 32'd3,
  localparam logic [31:0] LPARA_ADDR_3BYTE_BITS = 32'd24,
  localparam logic [31:0] LPARA_ADDR_4BYTE_BITS = 32'd32,
  localparam logic [31:0] LPARA_MODE_BITS_MAX = 32'd8
) (
  // Controller clock and reset
  input  wire                    i_clk_serial,
  input  wire                    i_rst_n_serial,

  // Request control and phase fields
  input  wire                    i_en,
  input  wire                    i_target_role,
  input  wire                    i_cmd_valid,
  output logic                   o_cmd_ready,
  input  wire  [2:0]             i_cmd_format,
  input  wire                    i_cpol,
  input  wire                    i_cpha,
  input  wire                    i_lsb_first,
  input  wire  [15:0]            i_clk_divisor,
  input  wire  [7:0]             i_cs_setup,
  input  wire  [7:0]             i_cs_hold,
  input  wire  [7:0]             i_cs_high,
  input  wire  [3:0]             i_cs_sel,
  input  wire  [7:0]             i_cmd_opcode,
  input  wire  [31:0]            i_cmd_addr,
  input  wire  [1:0]             i_cmd_addr_bytes,
  input  wire  [7:0]             i_cmd_mode_value,
  input  wire  [4:0]             i_cmd_mode_count,
  input  wire  [7:0]             i_cmd_dummy_cycles,
  input  wire                    i_cmd_rd,
  input  wire  [15:0]            i_cmd_byte_count,

  // Controller TX/RX FIFO interfaces
  input  wire  [31:0]            i_tx_data,
  input  wire                    i_tx_empty,
  output logic                   o_tx_pop,
  input  wire                    i_rx_full,
  output logic [31:0]            o_rx_data,
  output logic                   o_rx_push,

  // Controller serial pads and status
  input  wire  [3:0]             i_spi_io_i,
  output logic                   o_clk_spi_ctrl,
  output logic [PARA_NUM_CS-1:0] o_spi_cs_ctrl_n,
  output logic [3:0]             o_spi_io_o,
  output logic [3:0]             o_spi_io_oe,
  output logic                   o_busy,
  output logic                   o_done,
  output logic                   o_fl_err,
  output logic                   o_tx_err,
  output logic                   o_rx_err
);

  // FSM states: each command phase is separated so CS remains asserted across the full request.
  typedef enum logic [3:0] {
    ENUM_ST_IDLE  = 4'b0000,
    ENUM_ST_SETUP = 4'b0001,
    ENUM_ST_OPCODE = 4'b0010,
    ENUM_ST_ADDR  = 4'b0011,
    ENUM_ST_MODE  = 4'b0100,
    ENUM_ST_DUMMY = 4'b0101,
    ENUM_ST_DATA  = 4'b0110,
    ENUM_ST_HOLD  = 4'b0111,
    ENUM_ST_DONE  = 4'b1000,
    ENUM_ST_HIGH  = 4'b1001
  } ctrl_state_type_def;

  // Internal state and transfer registers.
  ctrl_state_type_def reg_fsm_ctrl_current_state;
  ctrl_state_type_def w_fsm_ctrl_nxt_state;
  logic [15:0] reg_div_count;
  logic [15:0] reg_clk_divisor;
  logic [7:0] reg_delay_left;
  logic [7:0] reg_cs_hold;
  logic [7:0] reg_cs_high;
  logic [7:0] reg_cs_high_left;
  logic [7:0] reg_dummy_left;
  logic [2:0] reg_format;
  logic reg_cpol;
  logic reg_cpha;
  logic reg_lsb_first;
  logic reg_cmd_rd;
  logic [3:0] reg_cs_sel;
  logic [7:0] reg_opcode;
  logic [31:0] reg_addr;
  logic [1:0] reg_addr_bytes;
  logic [7:0] reg_mode_value;
  logic [4:0] reg_mode_count;
  logic [15:0] reg_bytes_left;
  logic [20:0] reg_bits_left;
  logic [31:0] reg_phase_shift;
  logic [31:0] reg_tx_shift;
  logic reg_tx_word_valid;
  logic [5:0] reg_tx_word_bits_left;
  logic [7:0] reg_rx_byte;
  logic [3:0] reg_rx_bits_in_byte;
  logic [31:0] reg_rx_word;
  logic [1:0] reg_rx_byte_idx;
  logic [31:0] reg_rx_data;
  logic [31:0] w_rx_word_nxt;
  logic reg_rx_push_pulse;
  logic reg_force_abort;
  logic reg_data_complete;
  logic w_tx_underflow_now;
  logic w_rx_overflow_now;
  logic w_any_err;
  logic reg_phase_complete;
  logic reg_first_shift;
  logic reg_success;
  logic reg_sclk;
  logic reg_done_pulse;
  logic reg_fl_err_pulse;
  logic reg_tx_err_pulse;
  logic reg_rx_err_pulse;
  logic [2:0] w_lane_count;
  logic [20:0] w_lane_count_21;
  logic [5:0] w_lane_count_6;
  logic [LPARA_CS_IDX_W-1:0] w_cs_idx;
  logic w_cs_valid;
  logic w_half_tick;
  logic w_sample_edge;
  logic w_shift_edge;
  logic w_phase_sample;
  logic w_phase_last_sample;
  logic w_phase_end;
  logic w_data_byte_done;
  logic w_data_last_byte;
  logic [7:0] w_rx_byte_nxt;
  logic [31:0] w_tx_load_data;
  logic [3:0] w_data_oe;
  logic [31:0] w_out_shift;

  // The current-state register is isolated for FSM extraction and recoding.
  always_ff @(posedge i_clk_serial, negedge i_rst_n_serial) begin : p_ff_fsm_ctrl
    if (!i_rst_n_serial)
      reg_fsm_ctrl_current_state <= ENUM_ST_IDLE;
    else
      reg_fsm_ctrl_current_state <= w_fsm_ctrl_nxt_state;
  end

  // Next-state logic advances after the final sample/shift edge of each phase.
  always_comb begin : p_com_fsm_nxt
    w_fsm_ctrl_nxt_state = reg_fsm_ctrl_current_state;
    case (reg_fsm_ctrl_current_state)
      ENUM_ST_IDLE: begin
        if (i_cmd_valid && o_cmd_ready)
          w_fsm_ctrl_nxt_state = ENUM_ST_SETUP;
      end
      ENUM_ST_SETUP: begin
        if (reg_delay_left == 8'd0)
          w_fsm_ctrl_nxt_state = ENUM_ST_OPCODE;
      end
      ENUM_ST_OPCODE: begin
        if (w_phase_end) begin
          casez ({(reg_addr_bytes != 2'd0), (reg_mode_count != 5'd0),
                  (reg_dummy_left != 8'd0), (reg_bytes_left != 16'd0)})
            4'b1???: w_fsm_ctrl_nxt_state = ENUM_ST_ADDR;
            4'b01??: w_fsm_ctrl_nxt_state = ENUM_ST_MODE;
            4'b001?: w_fsm_ctrl_nxt_state = ENUM_ST_DUMMY;
            4'b0001: w_fsm_ctrl_nxt_state = ENUM_ST_DATA;
            default: w_fsm_ctrl_nxt_state = ENUM_ST_HOLD;
          endcase
        end
      end
      ENUM_ST_ADDR: begin
        if (w_phase_end) begin
          casez ({(reg_mode_count != 5'd0), (reg_dummy_left != 8'd0),
                  (reg_bytes_left != 16'd0)})
            3'b1??: w_fsm_ctrl_nxt_state = ENUM_ST_MODE;
            3'b01?: w_fsm_ctrl_nxt_state = ENUM_ST_DUMMY;
            3'b001: w_fsm_ctrl_nxt_state = ENUM_ST_DATA;
            default: w_fsm_ctrl_nxt_state = ENUM_ST_HOLD;
          endcase
        end
      end
      ENUM_ST_MODE: begin
        if (w_phase_end) begin
          casez ({(reg_dummy_left != 8'd0), (reg_bytes_left != 16'd0)})
            2'b1?: w_fsm_ctrl_nxt_state = ENUM_ST_DUMMY;
            2'b01: w_fsm_ctrl_nxt_state = ENUM_ST_DATA;
            default: w_fsm_ctrl_nxt_state = ENUM_ST_HOLD;
          endcase
        end
      end
      ENUM_ST_DUMMY: begin
        if (w_half_tick && w_sample_edge && (reg_dummy_left == 8'd1)) begin
          if (reg_bytes_left != 16'd0)
            w_fsm_ctrl_nxt_state = ENUM_ST_DATA;
          else
            w_fsm_ctrl_nxt_state = ENUM_ST_HOLD;
        end
      end
      ENUM_ST_DATA: begin
        if ((w_any_err && (w_shift_edge || reg_cpha)) ||
            (reg_force_abort && w_phase_end) ||
            (w_phase_end && (reg_data_complete || w_data_last_byte)))
          w_fsm_ctrl_nxt_state = ENUM_ST_HOLD;
      end
      ENUM_ST_HOLD: begin
        if (reg_delay_left == 8'd0)
          w_fsm_ctrl_nxt_state = ENUM_ST_DONE;
      end
      ENUM_ST_DONE: w_fsm_ctrl_nxt_state = ENUM_ST_HIGH;
      ENUM_ST_HIGH: begin
        if (reg_cs_high_left == 8'd0)
          w_fsm_ctrl_nxt_state = ENUM_ST_IDLE;
      end
      default:      w_fsm_ctrl_nxt_state = ENUM_ST_IDLE;
    endcase
  end

  // Select lane width for the active command phase from the programmed flash format.
  always_comb begin : p_com_lane_count
    w_lane_count = LPARA_LANES_1[2:0];
    case (reg_fsm_ctrl_current_state)
      ENUM_ST_OPCODE: begin
        if (reg_format == LPARA_FMT_QPI[2:0])
          w_lane_count = LPARA_LANES_4[2:0];
      end
      ENUM_ST_ADDR: begin
        case (reg_format)
          LPARA_FMT_122[2:0]: w_lane_count = LPARA_LANES_2[2:0];
          LPARA_FMT_144[2:0], LPARA_FMT_QPI[2:0]: w_lane_count = LPARA_LANES_4[2:0];
          default: w_lane_count = LPARA_LANES_1[2:0];
        endcase
      end
      ENUM_ST_MODE: begin
        case (reg_format)
          LPARA_FMT_122[2:0]: w_lane_count = LPARA_LANES_2[2:0];
          LPARA_FMT_144[2:0], LPARA_FMT_QPI[2:0]: w_lane_count = LPARA_LANES_4[2:0];
          default: w_lane_count = LPARA_LANES_1[2:0];
        endcase
      end
      ENUM_ST_DATA: begin
        case (reg_format)
          LPARA_FMT_112[2:0], LPARA_FMT_122[2:0]: w_lane_count = LPARA_LANES_2[2:0];
          LPARA_FMT_114[2:0], LPARA_FMT_144[2:0], LPARA_FMT_QPI[2:0]: w_lane_count = LPARA_LANES_4[2:0];
          default: w_lane_count = LPARA_LANES_1[2:0];
        endcase
      end
      default: w_lane_count = LPARA_LANES_1[2:0];
    endcase
  end

  // Resize phase-lane values once so comparisons, subtractors and CS indexing stay exact.
  always_comb begin : p_com_sized_fields
    w_lane_count_21 = {18'd0, w_lane_count};
    w_lane_count_6 = {3'd0, w_lane_count};
    w_cs_idx = reg_cs_sel[LPARA_CS_IDX_W-1:0];
    w_cs_valid = ({1'b0, reg_cs_sel} < PARA_NUM_CS[4:0]);
  end

  // Edge and phase events are derived from the registered SCLK level and divider state.
  always_comb begin : p_com_serial_events
    w_half_tick = (reg_div_count == reg_clk_divisor);
    w_sample_edge = ((reg_sclk == reg_cpol) && !reg_cpha) ||
                    ((reg_sclk != reg_cpol) && reg_cpha);
    w_shift_edge = !w_sample_edge;
    w_phase_sample = w_half_tick && w_sample_edge;
    w_phase_last_sample = w_phase_sample && (reg_bits_left <= w_lane_count_21);
    w_phase_end = (w_phase_last_sample && reg_cpha) ||
                  (reg_phase_complete && w_half_tick && w_shift_edge);
    w_data_byte_done = w_phase_sample &&
                       (({1'b0, reg_rx_bits_in_byte} + {2'b00, w_lane_count}) >=
                        LPARA_CS_WIDTH[4:0]);
    w_data_last_byte = w_data_byte_done && (reg_bytes_left == 16'd1);
    w_tx_underflow_now = (reg_fsm_ctrl_current_state == ENUM_ST_DATA) &&
                         !reg_cmd_rd && !reg_tx_word_valid && i_tx_empty &&
                         (reg_bytes_left != 16'd0) && w_half_tick && w_shift_edge;
    w_rx_overflow_now = (reg_fsm_ctrl_current_state == ENUM_ST_DATA) &&
                        reg_cmd_rd && i_rx_full && w_data_byte_done;
    w_any_err = w_tx_underflow_now || w_rx_overflow_now;
  end

  // Map bytes and lane groups to the physical IO ordering selected by bit order.
  always_comb begin : p_com_data_map
    w_rx_byte_nxt = reg_rx_byte;
    w_tx_load_data = reg_lsb_first ? i_tx_data :
                     {i_tx_data[7:0], i_tx_data[15:8], i_tx_data[23:16], i_tx_data[31:24]};
    w_rx_word_nxt = reg_rx_word;
    w_out_shift = reg_phase_shift;
    if (reg_fsm_ctrl_current_state == ENUM_ST_DATA)
      w_out_shift = reg_tx_word_valid ? reg_tx_shift : w_tx_load_data;
    case (w_lane_count)
      LPARA_LANES_1[2:0]: begin
        if (reg_lsb_first)
          w_rx_byte_nxt = {i_spi_io_i[1], reg_rx_byte[7:1]};
        else
          w_rx_byte_nxt = {reg_rx_byte[6:0], i_spi_io_i[1]};
      end
      LPARA_LANES_2[2:0]: begin
        if (reg_lsb_first)
          w_rx_byte_nxt = {i_spi_io_i[1:0], reg_rx_byte[7:2]};
        else
          w_rx_byte_nxt = {reg_rx_byte[5:0], i_spi_io_i[1:0]};
      end
      LPARA_LANES_4[2:0]: begin
        if (reg_lsb_first)
          w_rx_byte_nxt = {i_spi_io_i[3:0], reg_rx_byte[7:4]};
        else
          w_rx_byte_nxt = {reg_rx_byte[3:0], i_spi_io_i[3:0]};
      end
      default: w_rx_byte_nxt = reg_rx_byte;
    endcase
    w_rx_word_nxt[(reg_rx_byte_idx * LPARA_BITS_PER_BYTE) +: LPARA_BITS_PER_BYTE] = w_rx_byte_nxt;
  end

  // Drive the current phase's active lanes. The receiver owns IO1 for standard reads.
  always_comb begin : p_com_serial_pads
    o_clk_spi_ctrl = reg_sclk;
    o_spi_cs_ctrl_n = '1;
    if ((reg_fsm_ctrl_current_state != ENUM_ST_IDLE) &&
        (reg_fsm_ctrl_current_state != ENUM_ST_DONE) &&
        (reg_fsm_ctrl_current_state != ENUM_ST_HIGH) && w_cs_valid)
      o_spi_cs_ctrl_n[w_cs_idx] = 1'b0;
    o_spi_io_o = 4'b0000;
    o_spi_io_oe = 4'b0000;
    w_data_oe = 4'b0000;
    if (reg_fsm_ctrl_current_state == ENUM_ST_DATA) begin
      if (!reg_cmd_rd) begin
        case (w_lane_count)
          LPARA_LANES_1[2:0]: w_data_oe = 4'b0001;
          LPARA_LANES_2[2:0]: w_data_oe = 4'b0011;
          LPARA_LANES_4[2:0]: w_data_oe = 4'b1111;
          default: w_data_oe = 4'b0000;
        endcase
      end
    end else if ((reg_fsm_ctrl_current_state == ENUM_ST_OPCODE) ||
                 (reg_fsm_ctrl_current_state == ENUM_ST_ADDR) ||
                 (reg_fsm_ctrl_current_state == ENUM_ST_MODE)) begin
      case (w_lane_count)
        LPARA_LANES_1[2:0]: w_data_oe = 4'b0001;
        LPARA_LANES_2[2:0]: w_data_oe = 4'b0011;
        LPARA_LANES_4[2:0]: w_data_oe = 4'b1111;
        default: w_data_oe = 4'b0000;
      endcase
    end
    o_spi_io_oe = w_data_oe;
    case (w_lane_count)
      LPARA_LANES_1[2:0]: begin
        if (reg_lsb_first)
          o_spi_io_o[0] = w_out_shift[0];
        else
          o_spi_io_o[0] = w_out_shift[31];
      end
      LPARA_LANES_2[2:0]: begin
        if (reg_lsb_first)
          o_spi_io_o[1:0] = w_out_shift[1:0];
        else
          o_spi_io_o[1:0] = w_out_shift[31:30];
      end
      LPARA_LANES_4[2:0]: begin
        if (reg_lsb_first)
          o_spi_io_o[3:0] = w_out_shift[3:0];
        else
          o_spi_io_o[3:0] = w_out_shift[31:28];
      end
      default: o_spi_io_o = 4'b0000;
    endcase
  end

  // Handshake, status and request pulses are decoded from registered state.
  always_comb begin : p_com_ctrl_out
    o_cmd_ready = i_en && !i_target_role &&
                  (reg_fsm_ctrl_current_state == ENUM_ST_IDLE);
    o_busy = (reg_fsm_ctrl_current_state != ENUM_ST_IDLE) &&
             (reg_fsm_ctrl_current_state != ENUM_ST_DONE);
    o_done = reg_done_pulse;
    o_fl_err = reg_fl_err_pulse;
    o_tx_err = reg_tx_err_pulse;
    o_rx_err = reg_rx_err_pulse;
    o_tx_pop = (reg_fsm_ctrl_current_state == ENUM_ST_DATA) && !reg_cmd_rd &&
               !reg_tx_word_valid && !i_tx_empty;
    o_rx_push = reg_rx_push_pulse;
    o_rx_data = reg_rx_data;
  end

  // Transfer and timing state is separate from the FSM state register.
  always_ff @(posedge i_clk_serial, negedge i_rst_n_serial) begin : p_ff_ctrl_data
    if (!i_rst_n_serial) begin
      reg_div_count <= 16'd0;
      reg_clk_divisor <= 16'd0;
      reg_delay_left <= 8'd0;
      reg_cs_hold <= 8'd0;
      reg_cs_high <= 8'd0;
      reg_cs_high_left <= 8'd0;
      reg_dummy_left <= 8'd0;
      reg_format <= LPARA_FMT_STD[2:0];
      reg_cpol <= 1'b0;
      reg_cpha <= 1'b0;
      reg_lsb_first <= 1'b0;
      reg_cmd_rd <= 1'b0;
      reg_cs_sel <= 4'd0;
      reg_opcode <= 8'd0;
      reg_addr <= 32'd0;
      reg_addr_bytes <= 2'd0;
      reg_mode_value <= 8'd0;
      reg_mode_count <= 5'd0;
      reg_bytes_left <= 16'd0;
      reg_bits_left <= 21'd0;
      reg_phase_shift <= 32'd0;
      reg_tx_shift <= 32'd0;
      reg_tx_word_valid <= 1'b0;
      reg_tx_word_bits_left <= 6'd0;
      reg_rx_byte <= 8'd0;
      reg_rx_bits_in_byte <= 4'd0;
      reg_rx_word <= 32'd0;
      reg_rx_byte_idx <= 2'd0;
      reg_rx_data <= 32'd0;
      reg_rx_push_pulse <= 1'b0;
      reg_force_abort <= 1'b0;
      reg_data_complete <= 1'b0;
      reg_phase_complete <= 1'b0;
      reg_first_shift <= 1'b0;
      reg_success <= 1'b0;
      reg_sclk <= 1'b0;
      reg_done_pulse <= 1'b0;
      reg_fl_err_pulse <= 1'b0;
      reg_tx_err_pulse <= 1'b0;
      reg_rx_err_pulse <= 1'b0;
    end else begin
      reg_done_pulse <= 1'b0;
      reg_fl_err_pulse <= 1'b0;
      reg_tx_err_pulse <= 1'b0;
      reg_rx_err_pulse <= 1'b0;
      reg_rx_push_pulse <= 1'b0;
      case (reg_fsm_ctrl_current_state)
      ENUM_ST_IDLE: begin
        reg_div_count <= 16'd0;
        reg_sclk <= i_cpol;
        if (i_cmd_valid && !o_cmd_ready) begin
          reg_fl_err_pulse <= 1'b1;
        end else if (i_cmd_valid && o_cmd_ready) begin
          if ((i_cmd_format > LPARA_FMT_QPI[2:0]) ||
              ((i_cmd_format != LPARA_FMT_STD[2:0]) && i_target_role) ||
              ({1'b0, i_cs_sel} >= PARA_NUM_CS[4:0]) || (i_cmd_addr_bytes == 2'b11) ||
              ({27'd0, i_cmd_mode_count} > LPARA_MODE_BITS_MAX)) begin
            reg_fl_err_pulse <= 1'b1;
          end else begin
            reg_format <= i_cmd_format;
            reg_cpol <= i_cpol;
            reg_cpha <= i_cpha;
            reg_lsb_first <= i_lsb_first;
            reg_cmd_rd <= i_cmd_rd;
            reg_cs_sel <= i_cs_sel;
            reg_clk_divisor <= i_clk_divisor;
            reg_cs_hold <= i_cs_hold;
            reg_cs_high <= i_cs_high;
            reg_opcode <= i_cmd_opcode;
            reg_addr <= i_cmd_addr;
            reg_addr_bytes <= i_cmd_addr_bytes;
            reg_mode_value <= i_cmd_mode_value;
            reg_mode_count <= i_cmd_mode_count;
            reg_dummy_left <= i_cmd_dummy_cycles;
            reg_bytes_left <= i_cmd_byte_count;
            reg_delay_left <= i_cs_setup;
            reg_phase_complete <= 1'b0;
            reg_success <= 1'b0;
            reg_force_abort <= 1'b0;
            reg_data_complete <= 1'b0;
            reg_tx_word_valid <= 1'b0;
            reg_rx_byte <= 8'd0;
            reg_rx_bits_in_byte <= 4'd0;
            reg_rx_word <= 32'd0;
            reg_rx_byte_idx <= 2'd0;
            reg_rx_push_pulse <= 1'b0;
          end
        end
      end
      ENUM_ST_SETUP, ENUM_ST_OPCODE, ENUM_ST_ADDR, ENUM_ST_MODE, ENUM_ST_DUMMY,
      ENUM_ST_DATA, ENUM_ST_HOLD: begin
        if ((reg_fsm_ctrl_current_state == ENUM_ST_SETUP) ||
            (reg_fsm_ctrl_current_state == ENUM_ST_HOLD)) begin
          reg_div_count <= 16'd0;
          if (reg_delay_left != 8'd0)
            reg_delay_left <= reg_delay_left - 8'd1;
        end else if (w_half_tick) begin
          reg_div_count <= 16'd0;
          if ((reg_fsm_ctrl_current_state == ENUM_ST_OPCODE) ||
              (reg_fsm_ctrl_current_state == ENUM_ST_ADDR) ||
              (reg_fsm_ctrl_current_state == ENUM_ST_MODE) ||
              (reg_fsm_ctrl_current_state == ENUM_ST_DUMMY) ||
              (reg_fsm_ctrl_current_state == ENUM_ST_DATA))
            reg_sclk <= ~reg_sclk;
          if (reg_fsm_ctrl_current_state == ENUM_ST_DUMMY && w_sample_edge &&
              (reg_dummy_left != 8'd0))
            reg_dummy_left <= reg_dummy_left - 8'd1;
          if ((reg_fsm_ctrl_current_state == ENUM_ST_OPCODE) ||
              (reg_fsm_ctrl_current_state == ENUM_ST_ADDR) ||
              (reg_fsm_ctrl_current_state == ENUM_ST_MODE) ||
              (reg_fsm_ctrl_current_state == ENUM_ST_DATA)) begin
            if (w_sample_edge && (reg_bits_left != 21'd0)) begin
              if (reg_bits_left <= w_lane_count_21) begin
                reg_bits_left <= 21'd0;
                reg_phase_complete <= 1'b1;
              end else begin
                reg_bits_left <= reg_bits_left - w_lane_count_21;
              end
            end
            if (w_shift_edge &&
                !((reg_fsm_ctrl_current_state == ENUM_ST_DATA) && reg_cmd_rd)) begin
              if (reg_first_shift) begin
                reg_first_shift <= 1'b0;
                if (!reg_cpha) begin
                  if (reg_lsb_first)
                    reg_phase_shift <= reg_phase_shift >> w_lane_count;
                  else
                    reg_phase_shift <= reg_phase_shift << w_lane_count;
                end
              end else begin
                if (reg_lsb_first)
                  reg_phase_shift <= reg_phase_shift >> w_lane_count;
                else
                  reg_phase_shift <= reg_phase_shift << w_lane_count;
                if (reg_fsm_ctrl_current_state == ENUM_ST_DATA) begin
                  if (reg_lsb_first)
                    reg_tx_shift <= reg_tx_shift >> w_lane_count;
                  else
                    reg_tx_shift <= reg_tx_shift << w_lane_count;
                  if (reg_tx_word_bits_left <= w_lane_count_6) begin
                    reg_tx_word_valid <= 1'b0;
                    reg_tx_word_bits_left <= 6'd0;
                  end else begin
                    reg_tx_word_bits_left <= reg_tx_word_bits_left - w_lane_count_6;
                  end
                end
              end
            end
            if (reg_fsm_ctrl_current_state == ENUM_ST_DATA && w_sample_edge && reg_cmd_rd) begin
              reg_rx_byte <= w_rx_byte_nxt;
              reg_rx_bits_in_byte <= reg_rx_bits_in_byte + w_lane_count;
              if (w_data_byte_done) begin
                reg_rx_bits_in_byte <= 4'd0;
                reg_bytes_left <= reg_bytes_left - 16'd1;
                reg_rx_byte <= 8'd0;
                if ((reg_rx_byte_idx == LPARA_BYTE_LAST_IDX[1:0]) ||
                    (reg_bytes_left == 16'd1)) begin
                  if (i_rx_full) begin
                    reg_rx_err_pulse <= 1'b1;
                    reg_force_abort <= 1'b1;
                    reg_success <= 1'b0;
                  end else begin
                    reg_rx_data <= w_rx_word_nxt;
                    reg_rx_push_pulse <= 1'b1;
                    reg_rx_word <= 32'd0;
                    reg_rx_byte_idx <= 2'd0;
                  end
                end else begin
                  reg_rx_word <= w_rx_word_nxt;
                  reg_rx_byte_idx <= reg_rx_byte_idx + 2'd1;
                end
                if (reg_bytes_left == 16'd1)
                  reg_data_complete <= 1'b1;
              end
            end else if (reg_fsm_ctrl_current_state == ENUM_ST_DATA && w_sample_edge &&
                         !reg_cmd_rd && (reg_bytes_left != 16'd0)) begin
              reg_rx_bits_in_byte <= reg_rx_bits_in_byte + w_lane_count;
              if (w_data_byte_done) begin
                reg_bytes_left <= reg_bytes_left - 16'd1;
                if (reg_bytes_left == 16'd1)
                  reg_data_complete <= 1'b1;
              end
            end
          end
        end else begin
          reg_div_count <= reg_div_count + 16'd1;
        end

        if ((reg_fsm_ctrl_current_state == ENUM_ST_DATA) && !reg_cmd_rd && o_tx_pop) begin
          if (reg_lsb_first)
            reg_tx_shift <= i_tx_data;
          else
            reg_tx_shift <= {i_tx_data[7:0], i_tx_data[15:8], i_tx_data[23:16], i_tx_data[31:24]};
          reg_tx_word_valid <= 1'b1;
          reg_tx_word_bits_left <= LPARA_TX_WORD_BITS[5:0];
        end

        if (w_fsm_ctrl_nxt_state != reg_fsm_ctrl_current_state) begin
          case (w_fsm_ctrl_nxt_state)
            ENUM_ST_OPCODE: begin
              reg_phase_shift <= reg_lsb_first ? {24'd0, reg_opcode} : {reg_opcode, 24'd0};
              reg_bits_left <= LPARA_BITS_PER_BYTE[20:0];
              reg_phase_complete <= 1'b0;
              reg_first_shift <= 1'b1;
            end
            ENUM_ST_ADDR: begin
              if (reg_addr_bytes == 2'd1) begin
                reg_phase_shift <= reg_lsb_first ? {8'd0, reg_addr[23:0]} : {reg_addr[23:0], 8'd0};
                reg_bits_left <= LPARA_ADDR_3BYTE_BITS[20:0];
              end else begin
                reg_phase_shift <= reg_addr;
                reg_bits_left <= LPARA_ADDR_4BYTE_BITS[20:0];
              end
              reg_phase_complete <= 1'b0;
              reg_first_shift <= 1'b1;
            end
            ENUM_ST_MODE: begin
              reg_phase_shift <= reg_lsb_first ? {24'd0, reg_mode_value} : {reg_mode_value, 24'd0};
              reg_bits_left <= {16'd0, reg_mode_count};
              reg_phase_complete <= 1'b0;
              reg_first_shift <= 1'b1;
            end
            ENUM_ST_DUMMY: begin
              reg_bits_left <= 21'd0;
              reg_phase_complete <= 1'b0;
              reg_first_shift <= 1'b1;
            end
            ENUM_ST_DATA: begin
              reg_bits_left <= {2'b00, reg_bytes_left, 3'b000};
              reg_phase_complete <= 1'b0;
              reg_first_shift <= 1'b1;
              reg_rx_bits_in_byte <= 4'd0;
              reg_rx_byte <= 8'd0;
              reg_rx_word <= 32'd0;
              reg_rx_byte_idx <= 2'd0;
              reg_data_complete <= 1'b0;
            end
            default: begin
              reg_phase_complete <= reg_phase_complete;
              reg_first_shift <= reg_first_shift;
            end
          endcase
        end

        if ((reg_fsm_ctrl_current_state == ENUM_ST_DATA) && w_any_err) begin
          reg_force_abort <= 1'b1;
          reg_delay_left <= reg_cs_hold;
          reg_success <= 1'b0;
          if (w_tx_underflow_now)
            reg_tx_err_pulse <= 1'b1;
          if (w_rx_overflow_now)
            reg_rx_err_pulse <= 1'b1;
        end

        if ((reg_fsm_ctrl_current_state == ENUM_ST_DATA) && w_phase_end &&
            (reg_data_complete || w_data_last_byte) && !reg_force_abort && !w_any_err) begin
          reg_delay_left <= reg_cs_hold;
          reg_success <= 1'b1;
        end
        if ((reg_fsm_ctrl_current_state == ENUM_ST_HOLD) &&
            (w_fsm_ctrl_nxt_state == ENUM_ST_DONE)) begin
          reg_sclk <= reg_cpol;
          reg_done_pulse <= reg_success && !reg_force_abort;
        end
      end
      ENUM_ST_DONE: begin
        reg_div_count <= 16'd0;
        reg_cs_high_left <= reg_cs_high;
      end
      ENUM_ST_HIGH: begin
        if (reg_cs_high_left != 8'd0)
          reg_cs_high_left <= reg_cs_high_left - 8'd1;
      end
      default: begin
        reg_div_count <= 16'd0;
      end
      endcase
    end
  end

endmodule
