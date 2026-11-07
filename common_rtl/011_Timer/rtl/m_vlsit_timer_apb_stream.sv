/*
 * Project      : Timer IP
 * Author       : Nguyen Quan and Codex
 * AI Flow      : VLSIT RTL Generator AI Automation Flow
 * AI Flow Page : https://github.com/nguyenquanicd/VLSIT_RTL_Generator_AI_Model
 * Date         : 2026-11-03
 * Description  : APB stream-beat bridge. PARA_ASYNC selects either a direct same-clock operation
 *                or a bundled-data request/acknowledge toggle crossing to the timer domain.
 */
`timescale 1ns/1ps

module m_vlsit_timer_apb_stream #(
  // Parameter Description: selects whether APB and Timer clocks are unrelated.
  // Parameter values: 0 (same clock net) or 1 (asynchronous clocks); default is 0.
  // Parameter unit: none
  parameter logic [31:0] PARA_ASYNC = 32'd0,
  localparam logic [31:0] LPARA_ADDR_W = 32'd16,
  localparam logic [31:0] LPARA_DATA_W = 32'd32
) (
  // APB-side request and response
  input  wire                     i_clk_apb,
  input  wire                     i_rst_n_apb,
  input  wire                     i_psel_apb,
  input  wire                     i_penable_apb,
  input  wire                     i_pwrite_apb,
  input  wire  [LPARA_ADDR_W-1:0] i_paddr_apb,
  input  wire  [LPARA_DATA_W-1:0] i_pwdata_apb,
  input  wire  [3:0]              i_pstrb_apb,
  input  wire                     i_stream_sel_apb,
  output logic                    o_pready_apb,
  output logic [LPARA_DATA_W-1:0] o_prdata_apb,
  output logic                    o_pslverr_apb,

  // Timer-domain operation and response
  input  wire                     i_clk_timer,
  input  wire                     i_rst_n_timer,
  output logic                    o_req_timer,
  output logic                    o_write_timer,
  output logic [LPARA_ADDR_W-1:0] o_addr_timer,
  output logic [LPARA_DATA_W-1:0] o_wdata_timer,
  output logic [3:0]              o_wstrb_timer,
  input  wire                     i_ready_timer,
  input  wire  [LPARA_DATA_W-1:0] i_rdata_timer,
  input  wire                     i_error_timer
);

  // Timer-side synchronizer and handshake state
  logic w_req_toggle_timer_sync;
  logic w_ack_toggle_apb_sync;
  logic reg_ack_toggle_timer;
  logic reg_timer_req_seen;
  logic [LPARA_DATA_W:0] reg_response_timer;
  logic w_timer_req_pending;

  // APB-side payload and response state
  logic [LPARA_ADDR_W+LPARA_DATA_W+4:0] reg_payload_apb;
  logic reg_req_toggle_apb;
  logic reg_apb_pending;
  logic [LPARA_DATA_W:0] reg_response_apb;
  logic w_apb_access;
  logic w_async_apb_done;
  logic w_stream_ready_timer;

  // The payload is frozen from request launch until the matching response toggle returns.
  assign w_apb_access = i_stream_sel_apb & i_psel_apb & i_penable_apb;
  assign w_async_apb_done = reg_apb_pending & (w_ack_toggle_apb_sync == reg_req_toggle_apb);
  assign w_timer_req_pending = (w_req_toggle_timer_sync != reg_timer_req_seen);
  assign w_stream_ready_timer = i_ready_timer;

  // Select stable APB payload during the asynchronous transfer and direct pins in same-clock mode.
  assign o_write_timer = (PARA_ASYNC == 32'd1) ? reg_payload_apb[LPARA_DATA_W+LPARA_ADDR_W+4] : i_pwrite_apb;
  assign o_addr_timer  = (PARA_ASYNC == 32'd1) ?
                         reg_payload_apb[LPARA_DATA_W+LPARA_ADDR_W+3:LPARA_DATA_W+4] : i_paddr_apb;
  assign o_wdata_timer = (PARA_ASYNC == 32'd1) ?
                         reg_payload_apb[LPARA_DATA_W+3:4] : i_pwdata_apb;
  assign o_wstrb_timer = (PARA_ASYNC == 32'd1) ? reg_payload_apb[3:0] : i_pstrb_apb;

  // In same-clock mode a stream request is the active APB ACCESS phase. In asynchronous mode the
  // request remains asserted until the timer side accepts and acknowledges the bundled payload.
  assign o_req_timer = (PARA_ASYNC == 32'd1) ? w_timer_req_pending : w_apb_access;
  assign o_pready_apb = (PARA_ASYNC == 32'd1) ? w_async_apb_done :
                        (i_stream_sel_apb ? w_stream_ready_timer : 1'b0);
  assign o_prdata_apb = (PARA_ASYNC == 32'd1) ? reg_response_apb[LPARA_DATA_W:1] : i_rdata_timer;
  assign o_pslverr_apb = (PARA_ASYNC == 32'd1) ? reg_response_apb[0] : i_error_timer;

  // Synchronize only the handshake toggles; bundled data remains stable until acknowledgement.
  m_vlsit_afifo_cell_sync #(
    .PARA_AFIFO_CELL_RST_VAL (32'd0),
    .PARA_AFIFO_CELL_TYPE    (32'd1)
  ) u_req_toggle_sync (
    .i_clk_dst   (i_clk_timer),
    .i_rst_n_dst (i_rst_n_timer),
    .i_d         (reg_req_toggle_apb),
    .o_q         (w_req_toggle_timer_sync)
  );

  m_vlsit_afifo_cell_sync #(
    .PARA_AFIFO_CELL_RST_VAL (32'd0),
    .PARA_AFIFO_CELL_TYPE    (32'd1)
  ) u_ack_toggle_sync (
    .i_clk_dst   (i_clk_apb),
    .i_rst_n_dst (i_rst_n_apb),
    .i_d         (reg_ack_toggle_timer),
    .o_q         (w_ack_toggle_apb_sync)
  );

  // APB launches exactly one stable payload for each stream ACCESS phase.
  always_ff @(posedge i_clk_apb, negedge i_rst_n_apb) begin : p_ff_apb_stream
    if (!i_rst_n_apb) begin
      reg_payload_apb <= '0;
      reg_req_toggle_apb <= 1'b0;
      reg_apb_pending <= 1'b0;
      reg_response_apb <= '0;
    end else begin
      if (!w_apb_access)
        reg_apb_pending <= 1'b0;
      if (w_apb_access & (PARA_ASYNC == 32'd1) & ~reg_apb_pending) begin
        reg_payload_apb <= {i_pwrite_apb, i_paddr_apb, i_pwdata_apb, i_pstrb_apb};
        reg_req_toggle_apb <= ~reg_req_toggle_apb;
        reg_apb_pending <= 1'b1;
      end
      if (w_async_apb_done) begin
        reg_response_apb <= reg_response_timer;
        if (i_psel_apb & ~i_penable_apb)
          reg_apb_pending <= 1'b0;
      end
    end
  end

  // The Timer core performs the stream operation once and returns its response with the ack toggle.
  always_ff @(posedge i_clk_timer, negedge i_rst_n_timer) begin : p_ff_timer_stream
    if (!i_rst_n_timer) begin
      reg_timer_req_seen <= 1'b0;
      reg_ack_toggle_timer <= 1'b0;
      reg_response_timer <= '0;
    end else if (PARA_ASYNC == 32'd1) begin
      if (w_timer_req_pending & w_stream_ready_timer) begin
        reg_timer_req_seen <= w_req_toggle_timer_sync;
        reg_response_timer <= {i_error_timer, i_rdata_timer};
        reg_ack_toggle_timer <= w_req_toggle_timer_sync;
      end
    end
  end

endmodule
