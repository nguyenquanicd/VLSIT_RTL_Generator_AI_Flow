/*
 * Project      : QSPI_Controller
 * Author       : Nguyen Quan (user)
 * AI Flow      : VLSIT RTL Generator AI Automation Flow
 * AI Flow Page : https://github.com/nguyenquanicd/VLSIT_RTL_Generator_AI_Model
 * Date         : 2026-11-03
 * Description  : Transfers a source-domain event toggle to one destination pulse through a
 *                request/acknowledge handshake, retaining one pending event during CDC latency.
 */
`timescale 1ns/1ps

module m_qspi_toggle_sync (
  // Source event clock and reset
  input  wire  i_clk_src,
  input  wire  i_rst_n_src,
  input  wire  i_event_tgl_src,

  // Destination event clock and reset
  input  wire  i_clk_dst,
  input  wire  i_rst_n_dst,
  output logic o_event_pulse_dst
);

  logic reg_event_seen_src;
  logic reg_req_tgl_src;
  logic reg_src_pending;
  logic w_ack_sync_src;
  logic w_req_sync_dst;
  logic reg_req_seen_dst;
  logic reg_ack_tgl_dst;
  logic reg_event_pulse_dst;

  VLSIT_CELL_SYNC_2FF_RN u_dont_touch_ack_sync (
    .CK (i_clk_src),
    .RN (i_rst_n_src),
    .D  (reg_ack_tgl_dst),
    .Q  (w_ack_sync_src)
  );

  VLSIT_CELL_SYNC_2FF_RN u_dont_touch_req_sync (
    .CK (i_clk_dst),
    .RN (i_rst_n_dst),
    .D  (reg_req_tgl_src),
    .Q  (w_req_sync_dst)
  );

  // Capture a changed source toggle and hold the request until its destination acknowledgement.
  always_ff @(posedge i_clk_src, negedge i_rst_n_src) begin : p_ff_toggle_src
    if (!i_rst_n_src) begin
      reg_event_seen_src <= 1'b0;
      reg_req_tgl_src <= 1'b0;
      reg_src_pending <= 1'b0;
    end else if (reg_src_pending) begin
      if (w_ack_sync_src == reg_req_tgl_src)
        reg_src_pending <= 1'b0;
    end else if (i_event_tgl_src != reg_event_seen_src) begin
      reg_event_seen_src <= i_event_tgl_src;
      reg_req_tgl_src <= ~reg_req_tgl_src;
      reg_src_pending <= 1'b1;
    end
  end

  // Emit a one-cycle destination pulse and return the request toggle as its acknowledgement.
  always_ff @(posedge i_clk_dst, negedge i_rst_n_dst) begin : p_ff_toggle_dst
    if (!i_rst_n_dst) begin
      reg_req_seen_dst <= 1'b0;
      reg_ack_tgl_dst <= 1'b0;
      reg_event_pulse_dst <= 1'b0;
    end else begin
      reg_event_pulse_dst <= 1'b0;
      if (w_req_sync_dst != reg_req_seen_dst) begin
        reg_req_seen_dst <= w_req_sync_dst;
        reg_ack_tgl_dst <= w_req_sync_dst;
        reg_event_pulse_dst <= 1'b1;
      end
    end
  end

  // Drive the destination pulse from its registered event state.
  assign o_event_pulse_dst = reg_event_pulse_dst;

endmodule
