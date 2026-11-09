/*
 * Project      : VLSIT Common RTL library
 * Author       : Nguyen Quan and Claude Sonnet 5.5 (user)
 * AI Flow      : VLSIT RTL Generator AI Automation Flow
 * AI Flow Page : https://github.com/nguyenquanicd/VLSIT_RTL_Generator_AI_Model
 * Date         : 2026-11-09
 * Description  : External DMA handshake (6.3, REQ-IF-004). Input channel: a request is raised when
 *                the selected context accepts message words and its input FIFO has room for one
 *                burst beyond the words already promised by earlier bursts. Output channel: a
 *                request is raised when the output FIFO of the selected context holds one burst
 *                beyond the words already promised, or when the burst timer expires with fewer
 *                words (the burst is then read with zero padding, sha_dvld.words gives the valid
 *                count, and the timeout event is raised). Each channel follows the four-phase
 *                order: request up, acknowledge up, request down, acknowledge down. The module is
 *                built only when PARA_DMA = 1.
 *                Decisions: DEC-014, DEC-022.
 */
`timescale 1ns/1ps

module m_vlsit_sha_dma #(
  // Parameter Description: depth of the input FIFO of one context.
  // Parameter values: power of 2 from 4 to 1024; default is 64.
  // Parameter unit: word
  parameter logic [31:0] PARA_IN_DEPTH = 64,
  localparam logic [31:0] LPARA_BURST_MAX = 32'd256
) (
  // Clock and reset
  input  wire         i_clk_core,
  input  wire         i_rst_n_core,

  // Configuration from the CSR block and clear
  input  wire         i_en,
  input  wire  [8:0]  i_burst,
  input  wire  [15:0] i_tmo,
  input  wire         i_clr,

  // Selected context: state of its FIFOs and word events
  input  wire         i_in_abs,
  input  wire  [15:0] i_in_lvl,
  input  wire         i_in_push_ev,
  input  wire         i_out_act,
  input  wire  [15:0] i_out_lvl,
  input  wire         i_out_pop_ev,
  input  wire         i_out_beat_ev,

  // Handshake with the DMA controller
  output logic        o_in_req,
  input  wire         i_in_ack,
  output logic        o_out_req,
  input  wire         i_out_ack,

  // Status and events
  output logic        o_act,
  output logic [8:0]  o_dvld,
  output logic        o_pad_ok,
  output logic        o_ev_tmo,
  output logic        o_ev_cfg
);

  // Channel FSM state type: an enum with the three states of the four-phase handshake. Encoding
  // 3 recovers to idle.
  typedef enum logic [1:0] {
    ENUM_ST_IDLE = 2'b00,
    ENUM_ST_REQ  = 2'b01,
    ENUM_ST_LOW  = 2'b10
  } ch_state_type_def;

  // Internal signal declarations
  ch_state_type_def reg_fsm_in_current_state;
  ch_state_type_def w_fsm_in_nxt_state;
  ch_state_type_def reg_fsm_out_current_state;
  ch_state_type_def w_fsm_out_nxt_state;

  logic [31:0] reg_pend_in;
  logic [31:0] reg_pend_out;
  logic [31:0] reg_left;
  logic [15:0] reg_tmo_cnt;
  logic [15:0] reg_lvl_prev;
  logic        reg_pad;
  logic        reg_bad_prev;
  logic [8:0]  reg_dvld;
  logic        reg_mode_tmo;

  logic        w_burst_ok;
  logic        w_bad;
  logic        w_in_cond;
  logic        w_out_cond_full;
  logic        w_out_cond_tmo;
  logic        w_out_cond;
  logic [31:0] w_burst32;
  logic [31:0] w_free;
  logic [31:0] w_avail;
  logic [31:0] w_pend_in_nxt;
  logic [31:0] w_pend_out_nxt;
  logic [31:0] w_left_nxt;
  logic [15:0] w_tmo_cnt_nxt;
  logic        w_in_ack_ev;
  logic        w_out_ack_ev;

  // Request conditions. The burst is legal when it is 1 to 256 words and fits in the input FIFO.
  // The free room and the available words are counted beyond the words promised to the DMA.
  always_comb begin : p_com_cond
    w_burst32  = {23'b0, i_burst};
    w_burst_ok = (i_burst != 9'd0) && (w_burst32 <= LPARA_BURST_MAX) && (w_burst32 <= PARA_IN_DEPTH);
    w_bad      = i_en && !w_burst_ok;
    w_free     = PARA_IN_DEPTH - {16'b0, i_in_lvl};
    w_avail    = {16'b0, i_out_lvl};
    w_in_cond  = i_en && w_burst_ok && i_in_abs && (w_free >= (reg_pend_in + w_burst32));
    w_out_cond_full = i_en && w_burst_ok && i_out_act && (w_avail >= (reg_pend_out + w_burst32));
    w_out_cond_tmo  = i_en && w_burst_ok && i_out_act && (i_tmo != 16'd0) && (reg_tmo_cnt >= i_tmo)
                      && (w_avail > reg_pend_out);
    w_out_cond = w_out_cond_full || w_out_cond_tmo;
    w_in_ack_ev  = (reg_fsm_in_current_state == ENUM_ST_REQ) && i_in_ack;
    w_out_ack_ev = (reg_fsm_out_current_state == ENUM_ST_REQ) && i_out_ack;
  end

  // Input channel FSM: IDLE to REQ when the condition holds, REQ to LOW on the acknowledge, LOW
  // to IDLE when the acknowledge falls. A cleared or disabled channel returns to IDLE.
  always_comb begin : p_com_fsm_in
    w_fsm_in_nxt_state = reg_fsm_in_current_state;
    case (reg_fsm_in_current_state)
      ENUM_ST_IDLE: begin
        if (w_in_cond)
          w_fsm_in_nxt_state = ENUM_ST_REQ;
      end
      ENUM_ST_REQ: begin
        if (i_in_ack)
          w_fsm_in_nxt_state = ENUM_ST_LOW;
      end
      ENUM_ST_LOW: begin
        if (!i_in_ack)
          w_fsm_in_nxt_state = ENUM_ST_IDLE;
      end
      default: w_fsm_in_nxt_state = ENUM_ST_IDLE;
    endcase
    if (i_clr)
      w_fsm_in_nxt_state = ENUM_ST_IDLE;
    o_in_req = (reg_fsm_in_current_state == ENUM_ST_REQ);
  end

  // Output channel FSM: same sequence with the output condition.
  always_comb begin : p_com_fsm_out
    w_fsm_out_nxt_state = reg_fsm_out_current_state;
    case (reg_fsm_out_current_state)
      ENUM_ST_IDLE: begin
        if (w_out_cond)
          w_fsm_out_nxt_state = ENUM_ST_REQ;
      end
      ENUM_ST_REQ: begin
        if (i_out_ack)
          w_fsm_out_nxt_state = ENUM_ST_LOW;
      end
      ENUM_ST_LOW: begin
        if (!i_out_ack)
          w_fsm_out_nxt_state = ENUM_ST_IDLE;
      end
      default: w_fsm_out_nxt_state = ENUM_ST_IDLE;
    endcase
    if (i_clr)
      w_fsm_out_nxt_state = ENUM_ST_IDLE;
    o_out_req = (reg_fsm_out_current_state == ENUM_ST_REQ);
  end

  // Promised words and beats. The input promise grows by a burst at the acknowledge and falls with
  // each pushed word. The output promise grows by the words that will be popped (a burst, or the
  // valid words of a timeout burst) and falls with each popped word. reg_left counts the beats
  // of the burst that the DMA has still to read, so the padding flag follows the real burst.
  always_comb begin : p_com_pend
    w_pend_in_nxt  = reg_pend_in;
    w_pend_out_nxt = reg_pend_out;
    w_left_nxt     = reg_left;
    if (w_in_ack_ev)
      w_pend_in_nxt = w_pend_in_nxt + w_burst32;
    if (i_in_push_ev && (w_pend_in_nxt != 32'd0))
      w_pend_in_nxt = w_pend_in_nxt - 32'd1;
    if (w_out_ack_ev) begin
      w_pend_out_nxt = w_pend_out_nxt + (reg_mode_tmo ? (w_avail - reg_pend_out) : w_burst32);
      w_left_nxt     = w_burst32;
    end
    if (i_out_pop_ev && (w_pend_out_nxt != 32'd0))
      w_pend_out_nxt = w_pend_out_nxt - 32'd1;
    if (i_out_beat_ev && !w_out_ack_ev && (w_left_nxt != 32'd0))
      w_left_nxt = w_left_nxt - 32'd1;
    w_tmo_cnt_nxt = reg_tmo_cnt + 16'd1;
    if ((i_out_lvl != reg_lvl_prev) || (w_avail <= reg_pend_out) || w_out_cond_full || !i_en)
      w_tmo_cnt_nxt = 16'd0;
  end

  // Input channel state register: control state, reset to idle.
  always_ff @(posedge i_clk_core, negedge i_rst_n_core) begin : p_ff_fsm_in
    if (!i_rst_n_core)
      reg_fsm_in_current_state <= ENUM_ST_IDLE;
    else
      reg_fsm_in_current_state <= w_fsm_in_nxt_state;
  end

  // Output channel state register: control state, reset to idle.
  always_ff @(posedge i_clk_core, negedge i_rst_n_core) begin : p_ff_fsm_out
    if (!i_rst_n_core)
      reg_fsm_out_current_state <= ENUM_ST_IDLE;
    else
      reg_fsm_out_current_state <= w_fsm_out_nxt_state;
  end

  // Counters, timeout bookkeeping and the valid-word register. A clear request (soft reset or
  // abort of the selected context) empties the promises and the padding state.
  always_ff @(posedge i_clk_core, negedge i_rst_n_core) begin : p_ff_cnt
    if (!i_rst_n_core) begin
      reg_pend_in  <= 32'd0;
      reg_pend_out <= 32'd0;
      reg_left     <= 32'd0;
      reg_tmo_cnt  <= 16'd0;
      reg_lvl_prev <= 16'd0;
      reg_pad      <= 1'b0;
      reg_bad_prev <= 1'b0;
      reg_dvld     <= 9'd0;
      reg_mode_tmo <= 1'b0;
    end else begin
      reg_lvl_prev <= i_out_lvl;
      reg_bad_prev <= w_bad;
      if (i_clr) begin
        reg_pend_in  <= 32'd0;
        reg_pend_out <= 32'd0;
        reg_left     <= 32'd0;
        reg_tmo_cnt  <= 16'd0;
        reg_pad      <= 1'b0;
        reg_dvld     <= 9'd0;
      end else begin
        reg_pend_in  <= w_pend_in_nxt;
        reg_pend_out <= w_pend_out_nxt;
        reg_left     <= w_left_nxt;
        reg_tmo_cnt  <= w_tmo_cnt_nxt;
        if ((reg_fsm_out_current_state == ENUM_ST_IDLE) && w_out_cond) begin
          reg_mode_tmo <= !w_out_cond_full;
          if (!w_out_cond_full) begin
            reg_pad  <= 1'b1;
            reg_dvld <= 9'(w_avail - reg_pend_out);
          end
        end
        if (reg_pad && (w_left_nxt == 32'd0) && (reg_fsm_out_current_state == ENUM_ST_IDLE))
          reg_pad <= 1'b0;
      end
    end
  end

  // Status, padding flag and events: the timeout event is one pulse when a timeout burst is
  // requested; the configuration event is one pulse when an illegal burst size becomes active.
  always_comb begin : p_com_out
    o_act    = (reg_fsm_in_current_state != ENUM_ST_IDLE) || (reg_fsm_out_current_state != ENUM_ST_IDLE);
    o_dvld   = reg_dvld;
    o_pad_ok = reg_pad && (reg_left != 32'd0);
    o_ev_tmo = (reg_fsm_out_current_state == ENUM_ST_IDLE) && w_out_cond && !w_out_cond_full;
    o_ev_cfg = w_bad && !reg_bad_prev;
  end

endmodule
