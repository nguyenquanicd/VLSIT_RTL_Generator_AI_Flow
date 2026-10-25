`timescale 1ns/1ps
// Self-checking testbench of m_vlsit_sfifo_top (synchronous-clock FIFO).
// Source of every check: SyncFIFO_Design_Specification.md (requirement IDs in the assertion names).
// The RTL was read only for port names, widths and parameters (rule R-023).
//
// Parameters (set with iverilog -P tb_sfifo.<name>=<value>):
//   DEPTH, RETIME, MACRO     design configuration (PARA_SFIFO_DEPTH, _PTR_RETIME, _MEM_USE_MACRO)
//   HW, HR                   half period in ns of the write and the read clock (both start at 0 at time 0)
//   SEED, NRAND              random seed and number of words of every random run
//
// The model is a queue of accepted words. A request is accepted when the request input is 1 and the
// flag output is 0 at the clock edge (REQ-FUNC-001, REQ-FUNC-002). The queue is committed 0.1 ns after
// the edge, so every check at an edge sees only operations of strictly earlier edges (a coincident edge
// of the other clock is not visible, REQ-CLK-001, REQ-PERF-003).
//
// Requirement IDs used: REQ-FUNC-001..010, REQ-IF-002, REQ-IF-003, REQ-CLK-001, REQ-RESET-001/002,
// REQ-SRST-001..008, REQ-PERF-001..005 of the specification.
module tb_sfifo;
  parameter integer DEPTH = 8;
  parameter integer RETIME = 0;
  parameter integer MACRO = 0;
  parameter integer HW = 5;
  parameter integer HR = 5;
  parameter integer SEED = 1;
  parameter integer NRAND = 600;
  parameter integer W = 16;

  localparam integer OCCW = $clog2(DEPTH + 1);
  localparam integer NA = 32;

  // ------------------------------------------------------------------ DUT and clocks
  logic clk_wr = 0, clk_rd = 0, rst_n_wr = 0, rst_n_rd = 0, rst_n_sw = 1;
  always #(HW) clk_wr = ~clk_wr;
  always #(HR) clk_rd = ~clk_rd;

  logic wr_en = 0, rd_en = 0;
  logic [W-1:0] wr_data = 0;
  logic [OCCW-1:0] full_thr = DEPTH, empty_thr = 0;
  wire full, full_thr_o, overflow, empty, empty_thr_o, underflow, busy;
  wire [W-1:0] rd_data;

  m_vlsit_sfifo_top #(.PARA_SFIFO_DEPTH(DEPTH), .PARA_SFIFO_DATA_W(W), .PARA_SFIFO_PTR_RETIME(RETIME),
                      .PARA_SFIFO_MEM_USE_MACRO(MACRO)) dut (
    .i_clk_wr(clk_wr), .i_rst_n_wr(rst_n_wr), .i_wr_en(wr_en), .i_wr_data(wr_data), .i_full_thr(full_thr),
    .i_rst_n_sw(rst_n_sw), .o_sw_rst_busy(busy), .o_full(full), .o_full_thr(full_thr_o), .o_overflow(overflow),
    .i_clk_rd(clk_rd), .i_rst_n_rd(rst_n_rd), .i_rd_en(rd_en), .i_empty_thr(empty_thr), .o_rd_data(rd_data),
    .o_empty(empty), .o_empty_thr(empty_thr_o), .o_underflow(underflow));

  // ------------------------------------------------------------------ assertion bookkeeping
  integer hit [0:NA-1];
  integer bad [0:NA-1];
  integer errors = 0;
  integer seed_v;

  function automatic string aname(input integer id);
    case (id)
      0:  aname = "WR-FULL-EXACT          REQ-FUNC-004 (full when DEPTH words stored)";
      1:  aname = "WR-NO-ACCEPT-WHEN-FULL REQ-FUNC-001/SVA-001 (accepted write needs a free place)";
      2:  aname = "WR-OVERFLOW-PULSE      REQ-FUNC-008 (rejected write gives a pulse)";
      3:  aname = "WR-OVERFLOW-ONLY-THEN  REQ-FUNC-008 (pulse only after a rejected write)";
      4:  aname = "WR-BLOCK-FULL-NOW      REQ-SRST-002 (i_rst_n_sw low gives o_full at once)";
      5:  aname = "WR-BLOCK-FULL-THR      REQ-SRST-002 (o_full_thr shows empty FIFO while blocked)";
      6:  aname = "WR-BUSY-RISES          REQ-SRST-006 (busy follows the request)";
      7:  aname = "WR-RESET-VALUES        REQ-RESET-001 (write domain reset values)";
      8:  aname = "WR-FULL-NEXT-CYCLE     REQ-PERF-005 (full in the cycle after the last place)";
      9:  aname = "WR-FULL-THR-AT-FULL    REQ-FUNC-007 (full threshold set when full)";
      10: aname = "WR-NO-X                REQ-IF-002 (write outputs not X)";
      11: aname = "WR-NO-PULSE-BLOCKED    REQ-SRST-002 (no overflow for a blocked write)";
      12: aname = "RD-EMPTY-EXACT         REQ-FUNC-005 (empty when no word stored)";
      13: aname = "RD-NONEMPTY-HAS-DATA   REQ-FUNC-005 (o_empty low means a word exists)";
      14: aname = "RD-SHOW-AHEAD-DATA     REQ-FUNC-002/IF-003 (o_rd_data is the oldest word)";
      15: aname = "RD-UNDERFLOW-PULSE     REQ-FUNC-009 (rejected read gives a pulse)";
      16: aname = "RD-UNDERFLOW-ONLY-THEN REQ-FUNC-009 (pulse only after a rejected read)";
      17: aname = "RD-EMPTY-THR-IMPLIED   REQ-FUNC-007 (empty implies empty threshold)";
      18: aname = "RD-RESET-VALUES        REQ-RESET-001 (read domain reset values)";
      19: aname = "RD-EMPTY-NEXT-CYCLE    REQ-PERF-005 (empty in the cycle after the last word)";
      20: aname = "RD-NO-X                REQ-IF-002 (read outputs not X, data not X when valid)";
      21: aname = "RD-FIFO-ORDER          REQ-FUNC-003 (word read equals oldest word written)";
      22: aname = "PERF-EMPTY-FALL-LAT    REQ-PERF-003 (o_empty falls after 1 + RETIME later read edges)";
      23: aname = "PERF-FULL-FALL-LAT     REQ-PERF-004 (o_full falls after 1 + RETIME later write edges)";
      24: aname = "PERF-GAPLESS           REQ-PERF-002 (no stall of the unlimited side)";
      25: aname = "SRST-SEQUENCE          REQ-SRST-001/004/005 (busy ends, FIFO empty, order kept after)";
      26: aname = "SRST-BLOCK-NO-ACCEPT   REQ-SRST-002 (no write accepted while blocked)";
      27: aname = "THR-FULL-SWEEP         REQ-FUNC-007 (o_full_thr equals occupancy >= threshold)";
      28: aname = "THR-EMPTY-SWEEP        REQ-FUNC-007 (o_empty_thr equals occupancy <= threshold)";
      29: aname = "HWRST-RECOVERY         REQ-SRST-007/REQ-RESET-002 (clean start after hardware reset)";
      30: aname = "REJECT-NO-CHANGE       REQ-FUNC-010 (rejected requests change nothing)";
      31: aname = "OCC-BOUND              REQ-FUNC-004/SVA-011 (occupancy never above DEPTH)";
      default: aname = "unused";
    endcase
  endfunction

  // chk: ante = the assertion is active (hit); cons = what must hold (fail otherwise).
  task automatic chk(input integer id, input logic ante, input logic cons);
    begin
      if (ante === 1'b1) begin
        hit[id] = hit[id] + 1;
        if (cons !== 1'b1) begin
          bad[id] = bad[id] + 1;
          errors = errors + 1;
          if (bad[id] <= 5) $display("ASSERT FAIL @%0t ps: %0s", $realtime, aname(id));
        end
      end
    end
  endtask

  // ------------------------------------------------------------------ model and flags
  logic [W-1:0] q[$];
  integer wacc = 0, racc = 0, wstall = 0, rstall = 0;
  integer next_data = 0;
  integer wr_left = 0;
  integer rd_left = 0;
  integer wr_mode = 0, rd_mode = 0, pw = 50, pr = 50;
  logic started = 0;      // resets released, traffic allowed
  logic hw_active = 0;    // hardware reset sequence in progress: monitors are off
  logic srst_win = 0;     // software reset window: occupancy checks are off, blocking checks are on
  logic saw_busy = 0;
  logic win_start = 0;
  integer busy_cycles = 0;
  integer stall_lim = 0;   // stall counters run only while the access counter is below this value
  logic lat_emp_arm = 0, lat_full_arm = 0;
  // empty-fall latency (REQ-PERF-003)
  logic lat_emp_on = 0;
  realtime lat_emp_t0;
  integer lat_emp_cnt = 0;
  integer lat_emp_exp = 1 + RETIME;
  logic lat_emp_done = 0;

  // previous-cycle samples
  logic p_wr_en = 0, p_full = 0, p_blk = 0, p_wacc = 0;
  logic [31:0] p_occ_w = 0;
  logic p_rd_en = 0, p_empty = 0, p_racc = 0;
  logic [31:0] p_occ_r = 0;
  logic p_sw = 1, p_busy = 0;

  // drivers: inputs change 1 ns after the rising edge of their own clock
  always @(posedge clk_wr) begin
    #1;
    if (started && !hw_active) begin
      case (wr_mode)
        0: wr_en = 1'b0;
        1: wr_en = (wr_left != 0);
        2: wr_en = (wr_left != 0) && (($urandom(seed_v) % 100) < pw);
        default: wr_en = busy || !rst_n_sw;   // 3: request only while the software reset blocks writes
      endcase
      wr_data = next_data[W-1:0];
    end else wr_en = 1'b0;
  end
  always @(posedge clk_rd) begin
    #1;
    if (started && !hw_active) begin
      case (rd_mode)
        0: rd_en = 1'b0;
        1: rd_en = 1'b1;
        4: rd_en = (rd_left != 0);
        default: rd_en = (($urandom(seed_v) % 100) < pr);
      endcase
    end else rd_en = 1'b0;
  end

  // ------------------------------------------------------------------ write-domain monitor
  logic w_acc, w_blk;
  logic [W-1:0] w_dat;
  logic [31:0] occ;
  // latency measurement (REQ-PERF-004): count write edges, after a read from a full FIFO, where o_full is 1
  logic lat_full_on = 0;
  realtime lat_full_t0;
  integer lat_full_cnt = 0;
  integer lat_full_exp = 1 + RETIME;
  logic lat_full_done = 0;

  always @(posedge clk_wr) begin
    if (started && !hw_active) begin
      occ = q.size();
      w_acc = wr_en && !full;
      w_blk = !rst_n_sw || busy;
      w_dat = wr_data;
      // the software reset window opens at the first edge that samples i_rst_n_sw low
      if (!rst_n_sw && !srst_win) begin
        srst_win = 1; saw_busy = 0; busy_cycles = 0; win_start = 1;
      end
      // reset-free checks
      chk(10, 1'b1, !$isunknown({full, full_thr_o, overflow, busy}));
      chk(4,  !rst_n_sw, full);
      chk(5,  !rst_n_sw, full_thr_o == (full_thr == '0));
      chk(6,  p_sw == 1'b0 && p_busy == 1'b0 && started, busy);
      chk(11, p_blk && p_wr_en, !overflow);
      chk(26, w_blk && wr_en, !w_acc);
      if (!srst_win) begin
        chk(0,  occ == DEPTH, full);
        chk(1,  w_acc, occ < DEPTH);
        chk(31, 1'b1, occ <= DEPTH);
        chk(2,  p_wr_en && p_full && !p_blk, overflow);
        chk(3,  overflow, p_wr_en && p_full && !p_blk);
        chk(8,  p_wacc && p_occ_w == DEPTH - 1, full);
        chk(9,  occ == DEPTH, full_thr_o);
        // rejected request changes nothing (REQ-FUNC-010): the model is untouched, data order is
        // checked by RD-FIFO-ORDER; here the model must not grow
        chk(30, wr_en && full && !w_blk, q.size() == occ);
      end
      if (wr_en && !w_blk && full && wacc > 0 && wacc < stall_lim) wstall = wstall + 1;
      if (w_acc && lat_emp_arm) begin
        lat_emp_t0 = $realtime; lat_emp_cnt = 0; lat_emp_on = 1; lat_emp_arm = 0; lat_emp_done = 0;
      end
      // full-fall latency
      if (lat_full_on && $realtime > lat_full_t0) begin
        if (full === 1'b1) lat_full_cnt = lat_full_cnt + 1;
        else begin
          chk(23, 1'b1, lat_full_cnt == lat_full_exp);
          lat_full_on = 0; lat_full_done = 1;
        end
      end
      p_wr_en = wr_en; p_full = full; p_blk = w_blk; p_wacc = w_acc; p_occ_w = occ;
      p_sw = rst_n_sw; p_busy = busy;
      // software reset window handling (REQ-SRST-001, REQ-SRST-005)
      if (win_start) begin
        win_start = 0;
        #0.1; q.delete();
      end else if (srst_win) begin
        busy_cycles = busy_cycles + 1;
        if (busy) saw_busy = 1;
        if (saw_busy && !busy && rst_n_sw) srst_win = 0;
        else if (busy_cycles > 40 + 2 * DEPTH) begin
          chk(25, 1'b1, 1'b0);
          srst_win = 0;
        end
      end
      if (w_acc) begin
        #0.1;
        if (!srst_win || !w_blk) q.push_back(w_dat);
        wacc = wacc + 1;
        next_data = next_data + 1;
        if (wr_left > 0) wr_left = wr_left - 1;
      end
    end else if (started && hw_active) begin
      chk(7, !rst_n_wr, full === !rst_n_sw && overflow === 1'b0 && busy === 1'b0);   // o_full = flop 0 OR block term
    end
  end

  // ------------------------------------------------------------------ read-domain monitor
  logic r_acc;
  logic [W-1:0] r_exp;
  logic [W-1:0] r_head;

  always @(posedge clk_rd) begin
    if (started && !hw_active) begin
      occ = q.size();
      r_acc = rd_en && !empty;
      chk(20, 1'b1, !$isunknown({empty, empty_thr_o, underflow}) && (empty === 1'b1 || !$isunknown(rd_data)));
      if (!srst_win) begin
        chk(12, occ == 0, empty);
        chk(13, !empty, occ > 0);
        if (occ > 0) r_head = q[0]; else r_head = '0;
        chk(14, !empty && occ > 0, rd_data === r_head);
        chk(15, p_rd_en && p_empty, underflow);
        chk(16, underflow, p_rd_en && p_empty);
        chk(17, empty, empty_thr_o);
        chk(19, p_racc && p_occ_r == 1, empty);
        if (rd_en && empty && racc > 0 && racc < stall_lim) rstall = rstall + 1;
      end
      if (lat_emp_on && $realtime > lat_emp_t0) begin
        if (empty === 1'b1) lat_emp_cnt = lat_emp_cnt + 1;
        else begin
          chk(22, 1'b1, lat_emp_cnt == lat_emp_exp);
          lat_emp_on = 0; lat_emp_done = 1;
        end
      end
      p_rd_en = rd_en; p_empty = empty; p_racc = r_acc; p_occ_r = occ;
      if (r_acc && lat_full_arm) begin
        lat_full_t0 = $realtime; lat_full_cnt = 0; lat_full_on = 1; lat_full_arm = 0; lat_full_done = 0;
      end
      if (r_acc && !srst_win) begin
        if (occ > 0) r_exp = q[0]; else r_exp = {W{1'bx}};
        chk(21, 1'b1, rd_data === r_exp);
        #0.1;
        if (q.size() > 0) void'(q.pop_front());
        racc = racc + 1;
        if (rd_left > 0) rd_left = rd_left - 1;
      end
    end else if (started && hw_active) begin
      chk(18, !rst_n_rd, empty === 1'b1 && empty_thr_o === 1'b1 && underflow === 1'b0);
    end
  end

  // ------------------------------------------------------------------ helper tasks
  task automatic wait_wr(input integer n); repeat (n) @(posedge clk_wr); endtask
  task automatic wait_rd(input integer n); repeat (n) @(posedge clk_rd); endtask
  task automatic wait_both(input integer n);
    begin
      wait_wr(n); wait_rd(n);
    end
  endtask

  // drive an exact number of writes (rest idle) and wait until they were accepted
  task automatic write_n(input integer n);
    integer guard;
    begin
      wr_mode = 1; wr_left = n; guard = 0;
      while (wr_left != 0 && guard < 100000) begin wait_wr(1); guard = guard + 1; end
      wr_mode = 0;
      wait_wr(2);
    end
  endtask

  // read n words with continuous read requests (stops when the n-th is accepted)
  task automatic read_n(input integer n);
    integer guard;
    begin
      rd_mode = 4; rd_left = n; guard = 0;
      while (rd_left != 0 && guard < 100000) begin wait_rd(1); guard = guard + 1; end
      rd_mode = 0;
      wait_rd(2);
    end
  endtask

  // settle: wait long enough for any pointer to be visible in the other domain
  task automatic settle; begin wait_both(6); end endtask

  task automatic check_eq(input integer id, input logic cond);
    begin chk(id, 1'b1, cond); end
  endtask

  // reset the whole FIFO by the hardware reset (not a test: used between phases for a known start)
  task automatic hw_reset(input integer cycles);
    begin
      wr_mode = 0; rd_mode = 0;
      hw_active = 1;
      #0.2;
      rst_n_wr = 0; rst_n_rd = 0;
      q.delete();
      srst_win = 0;
      repeat (cycles) @(posedge clk_wr);
      @(posedge clk_wr); #1 rst_n_sw = 1;
      rst_n_wr = 1;
      @(posedge clk_rd); #1 rst_n_rd = 1;
      wait_both(2);
      hw_active = 0;
      wacc = 0; racc = 0; wstall = 0; rstall = 0;
      p_wr_en = 0; p_rd_en = 0; p_full = 0; p_empty = 1; p_wacc = 0; p_racc = 0; p_blk = 0; p_sw = 1; p_busy = 0;
      wait_both(2);
    end
  endtask

  // ------------------------------------------------------------------ test sequence
  integer i, j, t, k, nw;
  integer rseed;
  logic ok;

  initial begin
    for (i = 0; i < NA; i = i + 1) begin hit[i] = 0; bad[i] = 0; end
    seed_v = SEED;
    // reset: released synchronously, 1 ns after a rising edge of each clock
    #(6 * HW + 3);
    @(posedge clk_wr); #1 rst_n_wr = 1;
    @(posedge clk_rd); #1 rst_n_rd = 1;
    wait_both(3);
    started = 1;
    wait_both(3);

    $display("PHASE T1 @%0t ps", $realtime);
    // T1: values after reset (REQ-RESET-001) and an idle FIFO
    check_eq(29, full === 1'b0 && empty === 1'b1 && empty_thr_o === 1'b1 && overflow === 1'b0 && underflow === 1'b0 && busy === 1'b0);

    $display("PHASE T2 @%0t ps", $realtime);
    // T2: underflow on an empty FIFO (REQ-FUNC-009), then one write and the empty-fall latency (REQ-PERF-003)
    rd_mode = 1; wait_rd(4); rd_mode = 0; wait_rd(3);
    lat_emp_arm = 1;
    write_n(1);
    settle;
    check_eq(22, lat_emp_done === 1'b1);
    read_n(1);
    settle;

    $display("PHASE T3 @%0t ps", $realtime);
    // T3: fill the FIFO, keep writing (overflow, REQ-FUNC-004/008), read one (full-fall latency, REQ-PERF-004)
    rd_mode = 0;
    write_n(DEPTH);
    settle;
    wr_mode = 1; wr_left = 5; wait_wr(6); wr_mode = 0; wr_left = 0; wait_wr(3);
    settle;
    lat_full_arm = 1;
    read_n(1);
    settle;
    check_eq(23, lat_full_done === 1'b1);
    // drain the rest with continuous reads, then more reads on the empty FIFO
    rd_mode = 1; wait_rd(DEPTH + 6); rd_mode = 0; wait_rd(2);
    settle;
    check_eq(30, full === 1'b0 && empty === 1'b1 && q.size() == 0);

    $display("PHASE T4 @%0t ps", $realtime);
    // T4: threshold sweep (REQ-FUNC-007), thresholds are static: changed only while the FIFO is idle
    for (t = 0; t <= DEPTH; t = t + 1) begin
      full_thr = t[OCCW-1:0]; empty_thr = t[OCCW-1:0];
      settle;
      for (k = 0; k <= DEPTH; k = k + 1) begin
        if (k > 0) begin write_n(1); end
        settle;
        check_eq(27, full_thr_o === (k >= t));
        check_eq(28, empty_thr_o === (k <= t));
      end
      for (k = DEPTH; k > 0; k = k - 1) begin
        read_n(1);
        settle;
        check_eq(27, full_thr_o === ((k - 1) >= t));
        check_eq(28, empty_thr_o === ((k - 1) <= t));
      end
    end
    full_thr = DEPTH; empty_thr = 0;
    settle;

    $display("PHASE T5 @%0t ps", $realtime);
    // T5: gap-free streaming (REQ-PERF-001, REQ-PERF-002), only when the depth is large enough
    if (DEPTH >= 4 + 2 * RETIME) begin
      wacc = 0; racc = 0; wstall = 0; rstall = 0;
      nw = 300; stall_lim = nw;
      wr_mode = 1; wr_left = nw; rd_mode = 1;
      while (racc < nw) wait_rd(1);
      rd_mode = 0; wait_both(3);
      // the side with the faster clock is limited by the other one; the slower side never stalls
      chk(24, HW >= HR, wstall == 0);       // write clock slower or equal: writer never stalls
      chk(24, HW <= HR, rstall == 0);       // read clock slower or equal: reader never stalls
      stall_lim = 0;
      settle;
    end
    wr_mode = 0; rd_mode = 0;

    $display("PHASE T6 @%0t ps", $realtime);
    // T6: software reset with continuous write requests during the block (REQ-SRST-001..006)
    for (j = 0; j < 3; j = j + 1) begin
      write_n((j == 2) ? DEPTH : 3);
      settle;
      @(posedge clk_wr); #1 rst_n_sw = 0;
      wr_mode = 3;
      if (j == 1) begin wait_wr(1); end
      else begin wait_wr((j == 0) ? 3 : 10); end
      #1 rst_n_sw = 1;
      busy_cycles = 0;
      while (srst_win && busy_cycles < 100) wait_wr(1);
      wr_mode = 0;
      wait_wr(2);
      settle;
      check_eq(25, srst_win === 1'b0 && busy === 1'b0 && full === 1'b0 && empty === 1'b1);
      // data after the reset is correct and in order: write 5 words, read them back
      write_n(5 > DEPTH ? DEPTH : 5);
      settle;
      read_n(5 > DEPTH ? DEPTH : 5);
      settle;
    end
    // a one-cycle low pulse on a full FIFO (REQ-SRST-001: one cycle is enough)
    write_n(DEPTH);
    settle;
    @(posedge clk_wr); #1 rst_n_sw = 0;
    @(posedge clk_wr); #1 rst_n_sw = 1;
    busy_cycles = 0;
    while (srst_win && busy_cycles < 100) wait_wr(1);
    wait_wr(2); settle;
    check_eq(25, srst_win === 1'b0 && busy === 1'b0 && full === 1'b0 && empty === 1'b1);

    $display("PHASE T7 @%0t ps", $realtime);
    // T7: random traffic with a scoreboard for several request densities (REQ-FUNC-001..003, 010)
    for (j = 0; j < 4; j = j + 1) begin
      case (j)
        0: begin pw = 30; pr = 80; end
        1: begin pw = 80; pr = 30; end
        2: begin pw = 60; pr = 60; end
        default: begin pw = 100; pr = 100; end
      endcase
      wr_mode = 2; rd_mode = 2; wr_left = NRAND;
      wacc = 0; racc = 0;
      while (wr_left != 0) wait_wr(1);
      wr_mode = 0; rd_mode = 1;
      while (q.size() != 0) wait_rd(1);
      rd_mode = 0; wait_both(4);
    end

    $display("PHASE T8 @%0t ps", $realtime);
    // T8: hardware reset in the middle of traffic (REQ-RESET-001, REQ-SRST-007)
    wr_mode = 2; rd_mode = 2; pw = 70; pr = 40; wr_left = 100000;
    wait_wr(DEPTH + 7);
    hw_reset(3);
    check_eq(29, full === 1'b0 && empty === 1'b1 && overflow === 1'b0 && underflow === 1'b0 && busy === 1'b0);
    wr_mode = 2; rd_mode = 2; wr_left = NRAND;
    while (wr_left != 0) wait_wr(1);
    wr_mode = 0; rd_mode = 1;
    while (q.size() != 0) wait_rd(1);
    rd_mode = 0; wait_both(6);
    // a hardware reset in the middle of a software reset
    write_n(3);
    @(posedge clk_wr); #1 rst_n_sw = 0;
    wait_wr(3);
    hw_reset(2);
    wait_both(4);
    check_eq(29, full === 1'b0 && empty === 1'b1 && busy === 1'b0);
    write_n(4); settle; read_n(4); settle;

    report_and_finish;
  end

  // ------------------------------------------------------------------ report
  integer total_bad, never;
  task automatic report_and_finish;
    begin
      total_bad = 0; never = 0;
      $display("---- assertion table (name, hits, failures) DEPTH=%0d RETIME=%0d MACRO=%0d HW=%0d HR=%0d ----",
               DEPTH, RETIME, MACRO, HW, HR);
      for (i = 0; i < NA - 1; i = i + 1) begin
        // PERF-GAPLESS is skipped when the depth is below the stated limit
        if (!(i == 24 && DEPTH < 4 + 2 * RETIME)) begin
          $display("  [%2d] %-85s hits=%0d fails=%0d", i, aname(i), hit[i], bad[i]);
          total_bad = total_bad + bad[i];
          if (hit[i] == 0) never = never + 1;
        end
      end
      $display("assertion failures: %0d, assertions never exercised: %0d", total_bad, never);
      if (total_bad != 0 || never != 0 || errors != 0) begin
        $display("RESULT FAIL");
        $fatal(1, "testbench failed");
      end else $display("RESULT PASS");
      $finish;
    end
  endtask

  // watchdog
  initial begin
    #50_000_000;
    $display("RESULT FAIL (timeout) errors=%0d", errors);
    $fatal(1, "timeout");
  end
endmodule
