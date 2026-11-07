/*
 * Project      : Timer IP
 * Author       : Nguyen Quan and Codex
 * AI Flow      : VLSIT RTL Generator AI Automation Flow
 * AI Flow Page : https://github.com/nguyenquanicd/VLSIT_RTL_Generator_AI_Model
 * Date         : 2026-11-04
 * Description  : Directed test of the capture and compare/update req/ack handshakes of
 *                m_vlsit_timer_dma: normal bursts, early ack, spurious ack, CSR clear recovery.
 */
`timescale 1ns/1ps

module tb_timer_dma_reqack;
  parameter int TB_WIDTH = 32;
  localparam int RW = 32 + TB_WIDTH;

  logic clk = 1'b0;
  logic rst_n = 1'b0;
  always #5 clk = ~clk;

  logic cap_valid = 1'b0;
  logic [RW-1:0] cap_head = '0;
  logic [2:0] cap_level = '0;
  logic flush_busy = 1'b0;
  logic cap_pop, flush_clear;
  logic [1:0] cap_cfg = 2'd0, cmp_cfg = 2'd0;
  logic update_event = 1'b0;
  logic cap_req, cap_ack = 1'b0, cmp_req, cmp_ack = 1'b0;
  logic cap_clr = 1'b0, cmp_clr = 1'b0, cap_clr_done, cmp_clr_done;
  logic s_req = 1'b0, s_write = 1'b0;
  logic [15:0] s_addr = '0;
  logic [31:0] s_wdata = '0;
  logic s_ready, s_error;
  logic [31:0] s_rdata;
  logic batch_valid, err_event;
  logic [2:0] batch_count;
  logic [4*RW-1:0] batch_data;
  logic [2:0] q0, q1, r0, r1;
  logic cap_req_s, cap_burst_s, cap_clr_s, cmp_req_s, cmp_burst_s, cmp_clr_s;

  m_vlsit_timer_dma #(.PARA_COUNTER_WIDTH(TB_WIDTH), .PARA_OUTPUT_COUNT(4)) dut (
    .i_clk_timer(clk), .i_rst_n_timer(rst_n),
    .i_cap_valid(cap_valid), .i_cap_head(cap_head), .i_cap_level(cap_level),
    .i_cap_flush_busy(flush_busy), .o_cap_pop(cap_pop), .o_cap_flush_clear(flush_clear),
    .i_cap_record_cfg(cap_cfg), .i_cmp_record_cfg(cmp_cfg), .i_update_event(update_event),
    .o_dma_cap_req(cap_req), .i_dma_cap_ack(cap_ack), .o_dma_cmp_req(cmp_req), .i_dma_cmp_ack(cmp_ack),
    .i_cap_clr(cap_clr), .i_cmp_clr(cmp_clr), .o_cap_clr_done(cap_clr_done), .o_cmp_clr_done(cmp_clr_done),
    .i_stream_req(s_req), .i_stream_write(s_write), .i_stream_addr(s_addr),
    .i_stream_wdata(s_wdata), .i_stream_wstrb(4'hf),
    .o_stream_ready(s_ready), .o_stream_rdata(s_rdata), .o_stream_error(s_error),
    .o_update_batch_valid(batch_valid), .o_update_batch_count(batch_count),
    .o_update_batch_data(batch_data), .o_dma_error_event(err_event),
    .o_cap_queue_level(q0), .o_cmp_queue_level(q1), .o_cap_reserved_count(r0), .o_cmp_reserved_count(r1),
    .o_cap_req_status(cap_req_s), .o_cap_burst_status(cap_burst_s), .o_cap_clr_status(cap_clr_s),
    .o_cmp_req_status(cmp_req_s), .o_cmp_burst_status(cmp_burst_s), .o_cmp_clr_status(cmp_clr_s));

  int errors = 0;
  int err_events = 0;
  always @(posedge clk) if (err_event) err_events++;

  // Flush model: busy for three cycles after the clear pulse.
  int flush_cnt = 0;
  always @(posedge clk) begin
    if (flush_clear) flush_cnt <= 3;
    else if (flush_cnt != 0) flush_cnt <= flush_cnt - 1;
    flush_busy <= (flush_cnt != 0) | flush_clear;
  end

  task automatic check(input string name, input logic ok);
    if (!ok) begin
      errors++;
      $display("FAIL %s at %0t", name, $time);
    end else begin
      $display("PASS %s", name);
    end
  endtask

  task automatic tick(input int n = 1);
    repeat (n) @(posedge clk);
    #1;
  endtask

  task automatic stream_beat(input logic write, input logic [15:0] addr, input logic [31:0] data,
                             output logic err, output logic [31:0] rdata);
    s_req = 1'b1; s_write = write; s_addr = addr; s_wdata = data;
    #1;
    err = s_error; rdata = s_rdata;
    @(posedge clk); #1;
    s_req = 1'b0; s_write = 1'b0;
  endtask

  task automatic wait_cond(input string name, input int max_cycles, ref logic sig, input logic val);
    int n = 0;
    while (sig !== val && n < max_cycles) begin tick(); n++; end
    check(name, sig === val);
  endtask

  logic e;
  logic [31:0] d;
  int ev0;

  initial begin
    tick(3);
    rst_n = 1'b1;
    tick(3);
    check("idle after reset: no capture req, no clear busy", !cap_req && !cap_clr_s && !cmp_clr_s);

    // ---- Capture burst of one record, normal completion
    cap_head = {32'h0000_0003, {(TB_WIDTH){1'b0}}} | 64'h1234;
    cap_valid = 1'b1; cap_level = 3'd1;
    wait_cond("cap: req rises when one record is available", 5, cap_req, 1'b1);
    tick(2);
    check("cap: req held while ack is low", cap_req);
    stream_beat(1'b0, 16'h0200, 32'h0, e, d);
    check("cap: beat 0 (metadata) ok", !e && d == 32'h0000_0003);
    stream_beat(1'b0, 16'h0200, 32'h0, e, d);
    check("cap: beat 1 (value) ok", !e && d == 32'h1234);
    cap_level = 3'd0; cap_valid = 1'b0;
    tick(2);
    cap_ack = 1'b1;
    tick(1);
    check("cap: req drops after ack", !cap_req);
    cap_ack = 1'b0;
    tick(3);
    check("cap: back to idle after ack low", !cap_req && !cap_burst_s);

    // ---- Early ack: nothing read yet
    ev0 = err_events;
    cap_head = 64'h1; cap_valid = 1'b1; cap_level = 3'd1;
    wait_cond("cap: req rises (early-ack case)", 5, cap_req, 1'b1);
    tick(3);
    cap_ack = 1'b1;
    tick(2);
    check("cap: early ack raises error event", err_events == ev0 + 1);
    check("cap: req dropped in ERR", !cap_req);
    cap_ack = 1'b0;
    tick(5);
    check("cap: ERR holds until clear (no new req)", !cap_req);
    cap_valid = 1'b0; cap_level = 3'd0;
    cap_clr = 1'b1;
    tick(1);
    check("cap: clear busy", cap_clr_s);
    wait_cond("cap: clear done pulse", 12, cap_clr_done, 1'b1);
    tick(1);
    cap_clr = 1'b0;
    tick(2);
    check("cap: clear finished", !cap_clr_s && !cap_burst_s && !cap_req);

    // ---- Spurious ack in idle
    ev0 = err_events;
    cap_ack = 1'b1;
    tick(2);
    check("cap: spurious ack raises error event", err_events == ev0 + 1);
    cap_ack = 1'b0;
    cap_clr = 1'b1;
    wait_cond("cap: spurious ack recovery done", 12, cap_clr_done, 1'b1);
    tick(1); cap_clr = 1'b0; tick(3);

    // ---- Compare burst of one record, normal completion
    wait_cond("cmp: req rises when staging is empty", 5, cmp_req, 1'b1);
    stream_beat(1'b1, 16'h0204, 32'h0000_0001, e, d);
    check("cmp: tag beat ok", !e);
    stream_beat(1'b1, 16'h0204, 32'h0000_0100, e, d);
    check("cmp: value beat ok", !e);
    tick(2);
    check("cmp: req held until ack", cmp_req && !batch_valid);
    cmp_ack = 1'b1;
    tick(1);
    check("cmp: batch committed on ack", batch_valid && batch_count == 3'd1 && !cmp_req);
    check("cmp: record content", batch_data[RW-1:0] == {32'h1, 32'h100});
    cmp_ack = 1'b0;
    tick(2);
    update_event = 1'b1; tick(1); update_event = 1'b0; tick(1);
    check("cmp: batch consumed at update boundary", !batch_valid);

    // ---- Compare early ack (tag written, value missing)
    ev0 = err_events;
    wait_cond("cmp: req rises (early-ack case)", 8, cmp_req, 1'b1);
    stream_beat(1'b1, 16'h0204, 32'h0000_0001, e, d);
    tick(1);
    cmp_ack = 1'b1;
    tick(2);
    check("cmp: early ack raises error event, no commit", err_events == ev0 + 1 && !batch_valid && !cmp_req);
    cmp_ack = 1'b0;
    // clear while ERR
    cmp_clr = 1'b1;
    wait_cond("cmp: clear done pulse", 8, cmp_clr_done, 1'b1);
    tick(1); cmp_clr = 1'b0; tick(2);
    check("cmp: new request after clear", cmp_req);

    // ---- Stream beats are refused while clearing
    cmp_clr = 1'b1;
    tick(1);
    stream_beat(1'b1, 16'h0204, 32'h0000_0001, e, d);
    check("cmp: stream refused while clear busy", e);
    wait_cond("cmp: clear done (second)", 8, cmp_clr_done, 1'b1);
    tick(1); cmp_clr = 1'b0; tick(2);

    $display("TB %s (%0d errors)", errors == 0 ? "PASS" : "FAIL", errors);
    $finish;
  end

  initial begin
    #200000;
    $display("TB FAIL timeout");
    $finish;
  end
endmodule
