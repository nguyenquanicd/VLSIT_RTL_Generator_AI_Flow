/*
 * Project      : VLSIT Common RTL library
 * Author       : Nguyen Hung Quan (user)
 * AI Flow      : VLSIT RTL Generator AI Automation Flow
 * AI Flow Page : https://github.com/nguyenquanicd/VLSIT_RTL_Generator_AI_Model
 * Date         : 2026-11-08
 * Description  : Transfers source-domain event pulses to destination-domain pulses with a
 *                per-event request/acknowledge toggle handshake. One pending notification is
 *                retained per bit; additional pulses while pending coalesce. A pulse coincident
 *                with acknowledgement is captured as the next notification.
 */
`timescale 1ns/1ps

module m_vlsit_event_sync #(
  // Parameter Description: number of independent event bits.
  // Parameter values: 1 or greater; default is 1.
  // Parameter unit: bit
  parameter logic [31:0] PARA_EVENT_SYNC_W = 32'd1,
  // Parameter Description: two-stage synchronizer implementation. 1 = two discrete DFF cells,
  // 2 = one VLSIT 2-FF synchronizer cell. Bypass is not supported for this CDC primitive.
  // Parameter values: 1 or 2; default is 2.
  // Parameter unit: none
  parameter logic [31:0] PARA_EVENT_SYNC_CELL_TYPE = 32'd2
) (
  // Source event clock and reset
  input  wire                          i_clk_src,
  input  wire                          i_rst_n_src,

  // Destination event clock and reset
  input  wire                          i_clk_dst,
  input  wire                          i_rst_n_dst,

  // Source pulse vector and destination pulse vector
  input  wire  [PARA_EVENT_SYNC_W-1:0] i_event_src,
  output logic [PARA_EVENT_SYNC_W-1:0] o_event_dst
);

  // Independent request/acknowledge state and synchronizers for every event bit.
  for (genvar gen_event_idx = 0; gen_event_idx < PARA_EVENT_SYNC_W; gen_event_idx++) begin : gen_event
    logic reg_req_tgl;
    logic reg_src_pending;
    logic w_ack_sync;
    logic w_req_sync;
    logic reg_req_seen;
    logic reg_ack_tgl;
    logic reg_event_pulse;

    m_vlsit_afifo_cell_sync #(
      .PARA_AFIFO_CELL_RST_VAL (32'd0),
      .PARA_AFIFO_CELL_TYPE    (PARA_EVENT_SYNC_CELL_TYPE)
    ) u_vlsit_afifo_cell_sync_0 (
      .i_clk_dst   (i_clk_src),
      .i_rst_n_dst (i_rst_n_src),
      .i_d         (reg_ack_tgl),
      .o_q         (w_ack_sync)
    );

    m_vlsit_afifo_cell_sync #(
      .PARA_AFIFO_CELL_RST_VAL (32'd0),
      .PARA_AFIFO_CELL_TYPE    (PARA_EVENT_SYNC_CELL_TYPE)
    ) u_vlsit_afifo_cell_sync_1 (
      .i_clk_dst   (i_clk_dst),
      .i_rst_n_dst (i_rst_n_dst),
      .i_d         (reg_req_tgl),
      .o_q         (w_req_sync)
    );

    // Hold a request until its acknowledgement returns; coalesce pulses while one is pending.
    always_ff @(posedge i_clk_src, negedge i_rst_n_src) begin : p_ff_event_src
      if (!i_rst_n_src) begin
        reg_req_tgl     <= 1'b0;
        reg_src_pending <= 1'b0;
      end else if (reg_src_pending) begin
        if (w_ack_sync == reg_req_tgl) begin
          reg_src_pending <= i_event_src[gen_event_idx];
          if (i_event_src[gen_event_idx])
            reg_req_tgl <= ~reg_req_tgl;
        end
      end else if (i_event_src[gen_event_idx]) begin
        reg_req_tgl     <= ~reg_req_tgl;
        reg_src_pending <= 1'b1;
      end
    end

    // Convert each observed request toggle to one destination pulse and return its acknowledgement.
    always_ff @(posedge i_clk_dst, negedge i_rst_n_dst) begin : p_ff_event_dst
      if (!i_rst_n_dst) begin
        reg_req_seen   <= 1'b0;
        reg_ack_tgl    <= 1'b0;
        reg_event_pulse <= 1'b0;
      end else begin
        reg_event_pulse <= 1'b0;
        if (w_req_sync != reg_req_seen) begin
          reg_req_seen    <= w_req_sync;
          reg_ack_tgl     <= w_req_sync;
          reg_event_pulse <= 1'b1;
        end
      end
    end

    // Drive the destination event from its registered one-cycle pulse.
    assign o_event_dst[gen_event_idx] = reg_event_pulse;
  end

endmodule

