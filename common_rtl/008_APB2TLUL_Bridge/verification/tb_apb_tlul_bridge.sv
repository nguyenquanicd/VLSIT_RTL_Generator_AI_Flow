`timescale 1ns/1ps
// -----------------------------------------------------------------------------------------------
// Self-checking testbench of m_apb_tlul_bridge (APB4 completer to TL-UL host).
//
// Run it with the Makefile of the folder above:  make sim  or  make sim-narrow
// It ends with $fatal (non-zero exit status) when any check fails, so it can be used in CI.
//
// What it models
//   * an APB requester: the task xfer drives one transfer and can keep PSEL high for the next one
//     (back-to-back transfers where only PENABLE changes);
//   * a TL-UL device with a 64-word memory, a programmable a_ready back pressure (a_wait),
//     a programmable response delay (resp_delay, 0 = answer in the cycle of acceptance), fault
//     injection (d_error, wrong d_opcode, wrong d_source) and orphan responses.
// What it checks
//   * every APB completion: number of Access cycles, PSLVERR, PRDATA (0 on error), read data;
//   * every TL-UL request: opcode, address and data, and that an illegal APB request issues no
//     TL-UL request at all;
//   * protocol monitors: PREADY only in the Access phase and for one cycle, PSLVERR only with PREADY,
//     channel A stable while a_valid is high and a_ready is low, constant fields (param, size, mask,
//     source, user), one outstanding request, reset values, no X after reset.
// Plusargs: +SEED=<n> (random seed, default 1), +N=<n> (random transfers, default 400).
// Parameters (override with iverilog -P): PARA_ADDR_W, PARA_SRC_W, PARA_SRC_ID.
// Expected Access cycles of a legal transfer: 2 + a_wait + resp_delay; of an illegal one: 1.
// -----------------------------------------------------------------------------------------------
module tb_apb_tlul_bridge #(
  parameter PARA_ADDR_W = 32,
  parameter PARA_SRC_W  = 8,
  parameter PARA_SRC_ID = 0
);

  localparam NWORDS = 64;
  localparam [PARA_SRC_W-1:0] SRC = PARA_SRC_ID;

  // ------------------------------------------------------------------ clock, reset, signals
  reg clk = 1'b0;
  reg rst_n = 1'b0;
  always #5 clk = ~clk;

  reg psel = 1'b0, penable = 1'b0, pwrite = 1'b0;
  reg [PARA_ADDR_W-1:0] paddr = 0;
  reg [3:0] pstrb = 4'h0;
  reg [31:0] pwdata = 32'h0;
  wire pready, pslverr;
  wire [31:0] prdata;

  wire a_valid, d_ready, a_ready, d_valid, d_error;
  wire [2:0] a_opcode, a_param, d_opcode;
  wire [1:0] a_size;
  wire [PARA_SRC_W-1:0] a_source, d_source;
  wire [PARA_ADDR_W-1:0] a_address;
  wire [3:0] a_mask;
  wire [31:0] a_data, d_data;
  wire [0:0] a_user;

  m_apb_tlul_bridge #(
    .PARA_ADDR_W (PARA_ADDR_W),
    .PARA_SRC_W  (PARA_SRC_W),
    .PARA_SRC_ID (PARA_SRC_ID)
  ) dut (
    .i_clk_core       (clk),
    .i_rst_n_core     (rst_n),
    .i_apb_psel       (psel),
    .i_apb_penable    (penable),
    .i_apb_pwrite     (pwrite),
    .i_tlul_a_ready   (a_ready),
    .i_tlul_d_valid   (d_valid),
    .i_tlul_d_error   (d_error),
    .i_apb_paddr      (paddr),
    .i_apb_pprot      (3'b000),
    .i_apb_pstrb      (pstrb),
    .i_apb_pwdata     (pwdata),
    .i_tlul_d_opcode  (d_opcode),
    .i_tlul_d_param   (3'b000),
    .i_tlul_d_size    (2'b10),
    .i_tlul_d_source  (d_source),
    .i_tlul_d_sink    (1'b0),
    .i_tlul_d_data    (d_data),
    .i_tlul_d_user    (1'b0),
    .o_apb_pready     (pready),
    .o_apb_pslverr    (pslverr),
    .o_tlul_a_valid   (a_valid),
    .o_tlul_d_ready   (d_ready),
    .o_apb_prdata     (prdata),
    .o_tlul_a_opcode  (a_opcode),
    .o_tlul_a_param   (a_param),
    .o_tlul_a_size    (a_size),
    .o_tlul_a_source  (a_source),
    .o_tlul_a_address (a_address),
    .o_tlul_a_mask    (a_mask),
    .o_tlul_a_data    (a_data),
    .o_tlul_a_user    (a_user)
  );

  // ------------------------------------------------------------------ protocol assertions
  // 36 assertions on the APB and TL-UL ports (see apb_tlul_protocol_assertions.sv). The three masks
  // switch off the checks that the test itself violates on purpose.
  reg chk_pstrb_rd = 1'b1;              // 0 while a read is driven with a non-zero PSTRB
  integer fails = 0;
  task fail;
    input [8*72-1:0] msg;
    begin
      fails = fails + 1;
      $display("FAIL @%0t: %0s", $time, msg);
    end
  endtask

  // ------------------------------------------------------------------ TL-UL device model
  integer a_wait = 0;        // cycles a_ready stays low after a_valid rises
  integer resp_delay = 1;    // cycles from acceptance to d_valid; 0 = same cycle
  reg dev_err = 1'b0;        // answer with d_error = 1
  reg dev_bad_op = 1'b0;     // answer with the wrong d_opcode
  reg dev_bad_src = 1'b0;    // answer with the wrong d_source
  reg orph = 1'b0;           // d_valid without a request (orphan response)
  integer orph_cnt = 0;

  reg [31:0] mem [0:NWORDS-1];
  reg [31:0] exp_mem [0:NWORDS-1];
  reg [7:0] rdy_cnt = 8'd0;
  reg pend = 1'b0;
  reg [7:0] pcnt = 8'd0;
  reg prd = 1'b0;
  reg [PARA_ADDR_W-1:0] paddr_q = 0;

  assign a_ready = (rdy_cnt == 8'd0);
  wire fire = a_valid & a_ready;
  wire now = fire & (resp_delay == 0);
  wire later = pend & (pcnt == 8'd0);
  wire real_resp = now | later;
  wire cur_rd = now ? (a_opcode == 3'b100) : prd;
  wire [PARA_ADDR_W-1:0] cur_addr = now ? a_address : paddr_q;
  wire fault = dev_err | dev_bad_op | dev_bad_src;

  assign d_valid  = real_resp | orph;
  assign d_opcode = real_resp ? ((cur_rd ^ dev_bad_op) ? 3'b001 : 3'b000) : 3'b001;
  assign d_source = real_resp ? (dev_bad_src ? (SRC ^ 1'b1) : SRC) : (SRC ^ 1'b1);
  assign d_error  = real_resp ? dev_err : 1'b1;
  assign d_data   = !real_resp ? 32'hBAD0BAD0 :
                    dev_err    ? 32'hDEADBEEF :
                    cur_rd     ? mem[cur_addr[7:2]] : 32'h0;

  always @(posedge clk) begin
    if (!rst_n) begin
      rdy_cnt <= 8'd0;
      pend    <= 1'b0;
      pcnt    <= 8'd0;
    end else begin
      if (!a_valid)
        rdy_cnt <= a_wait;
      else if (rdy_cnt != 8'd0)
        rdy_cnt <= rdy_cnt - 8'd1;
      if (fire) begin
        if (pend) fail("second request accepted while one is outstanding");
        if (a_opcode == 3'b000 && !fault)
          mem[a_address[7:2]] <= a_data;
        if (resp_delay != 0) begin
          pend    <= 1'b1;
          pcnt    <= resp_delay - 1;
          prd     <= (a_opcode == 3'b100);
          paddr_q <= a_address;
        end
      end else if (pend) begin
        if (pcnt == 8'd0) pend <= 1'b0;
        else              pcnt <= pcnt - 8'd1;
      end
    end
  end

  // One-cycle orphan response, started orph_cnt negedges after arm_orph.
  always @(negedge clk) begin
    orph = 1'b0;
    if (orph_cnt > 0) begin
      orph_cnt = orph_cnt - 1;
      if (orph_cnt == 0) orph = 1'b1;
    end
  end
  task arm_orph;
    input integer n;
    begin orph_cnt = n; end
  endtask

  wire tb_fault = dev_bad_op | dev_bad_src;   // wrong d_opcode or d_source injected on purpose

  apb_tlul_protocol_assertions #(
    .PARA_ADDR_W (PARA_ADDR_W),
    .PARA_SRC_W  (PARA_SRC_W),
    .PARA_SRC_ID (PARA_SRC_ID)
  ) chk (
    .clk (clk), .rst_n (rst_n),
    .psel (psel), .penable (penable), .pwrite (pwrite), .paddr (paddr), .pstrb (pstrb), .pwdata (pwdata),
    .pready (pready), .pslverr (pslverr), .prdata (prdata),
    .a_valid (a_valid), .a_ready (a_ready), .a_opcode (a_opcode), .a_param (a_param), .a_size (a_size),
    .a_source (a_source), .a_address (a_address), .a_mask (a_mask), .a_data (a_data), .a_user (a_user),
    .d_valid (d_valid), .d_ready (d_ready), .d_opcode (d_opcode), .d_param (3'b000), .d_size (2'b10),
    .d_source (d_source), .d_data (d_data), .d_error (d_error),
    .i_tb_orphan (orph), .i_tb_fault (tb_fault), .i_chk_pstrb_rd (chk_pstrb_rd)
  );

  // ------------------------------------------------------------------ monitors
  integer req_count = 0;
  reg [2:0] r_op;
  reg [PARA_ADDR_W-1:0] r_addr;
  reg [31:0] r_data;
  always @(posedge clk) begin
    if (rst_n && fire) begin
      req_count <= req_count + 1;
      r_op      <= a_opcode;
      r_addr    <= a_address;
      r_data    <= a_data;
    end
  end

  // Constant fields and the fixed shape of every request.
  always @(posedge clk) begin
    if (rst_n && a_valid) begin
      if (a_param !== 3'b000)         fail("a_param is not 0");
      if (a_size !== 2'b10)           fail("a_size is not 2");
      if (a_mask !== 4'hF)            fail("a_mask is not 4'b1111");
      if (a_source !== SRC)           fail("a_source is not PARA_SRC_ID");
      if (a_user !== 1'b0)            fail("a_user is not 0");
      if (a_opcode[1:0] !== 2'b00)    fail("a_opcode[1:0] is not 0");
      if (a_address[1:0] !== 2'b00)   fail("a_address[1:0] is not 0");
    end
  end

  // Channel A stays unchanged while a_valid is high and a_ready is low.
  reg stall_q = 1'b0;
  reg [2:0] s_op;
  reg [PARA_ADDR_W-1:0] s_addr;
  reg [31:0] s_data;
  always @(posedge clk) begin
    if (rst_n && stall_q) begin
      if (!a_valid || a_opcode !== s_op || a_address !== s_addr || a_data !== s_data)
        fail("channel A changed while stalled");
    end
    stall_q <= rst_n & a_valid & ~a_ready;
    s_op    <= a_opcode;
    s_addr  <= a_address;
    s_data  <= a_data;
  end

  // APB completion protocol.
  reg pready_q = 1'b0;
  always @(posedge clk) begin
    if (rst_n) begin
      if (pready && !(psel && penable)) fail("PREADY outside the Access phase");
      if (pslverr && !pready)           fail("PSLVERR without PREADY");
      if (pready && pready_q)           fail("PREADY high for two cycles");
      if ((^{pready, pslverr, prdata, a_valid, d_ready}) === 1'bx) fail("X on an output after reset");
    end
    pready_q <= pready;
  end

  // Reset asserted in the middle of a run: all outputs are 0 right after.
  always @(negedge rst_n) begin
    #1;
    if (pready !== 1'b0 || pslverr !== 1'b0 || prdata !== 32'h0 || a_valid !== 1'b0 || d_ready !== 1'b0 ||
        a_opcode !== 3'b000 || a_address !== 0 || a_data !== 32'h0)
      fail("outputs are not 0 in reset");
  end

  // ------------------------------------------------------------------ APB requester
  // Starts and ends at 1 ns after a rising clock edge. With hold = 1, PSEL stays high so that the
  // next call starts its Setup phase in the very next cycle; with hold = 0 one idle cycle follows.
  task xfer;
    input wr;
    input [PARA_ADDR_W-1:0] addr;
    input [3:0] strb;
    input [31:0] wdata;
    input hold;
    integer n, req0, exp_cycles, fails0;
    reg legal, exp_err, done;
    begin
      fails0 = fails;
      chk_pstrb_rd = wr || (strb == 4'h0);
      legal      = (addr[1:0] == 2'b00) && (!wr || strb == 4'hF);
      exp_err    = !legal || dev_err || dev_bad_op || dev_bad_src;
      exp_cycles = legal ? (2 + a_wait + resp_delay) : 1;
      req0 = req_count;
      psel = 1'b1; penable = 1'b0; pwrite = wr; paddr = addr; pstrb = strb; pwdata = wdata;
      @(posedge clk); #1;
      penable = 1'b1;
      n = 0;
      done = 1'b0;
      while (!done) begin
        @(negedge clk);
        n = n + 1;
        if (pready || n > 200) done = 1'b1;
        else begin @(posedge clk); #1; end
      end
      if (n != exp_cycles)                      fail("wrong number of Access cycles");
      if (pslverr !== exp_err)                  fail("wrong PSLVERR");
      if (exp_err && prdata !== 32'h0)          fail("PRDATA is not 0 on an error");
      if (!exp_err && !wr && prdata !== exp_mem[addr[7:2]]) fail("wrong read data");
      if ((req_count - req0) != (legal ? 1 : 0)) fail("wrong number of TL-UL requests");
      if (legal) begin
        if (r_op !== (wr ? 3'b000 : 3'b100))    fail("wrong a_opcode");
        if (r_addr !== {addr[PARA_ADDR_W-1:2], 2'b00}) fail("wrong a_address");
        if (wr && r_data !== wdata)             fail("wrong a_data");
      end
      if (!exp_err && wr) exp_mem[addr[7:2]] = wdata;
      if (fails != fails0)
        $display("  transfer: wr=%b addr=%h strb=%h a_wait=%0d resp_delay=%0d err=%b bad_op=%b bad_src=%b cycles=%0d pslverr=%b prdata=%h",
                 wr, addr, strb, a_wait, resp_delay, dev_err, dev_bad_op, dev_bad_src, n, pslverr, prdata);
      @(posedge clk); #1;
      penable = 1'b0;
      if (!hold) begin
        psel = 1'b0;
        @(posedge clk); #1;
      end
    end
  endtask

  task idle;
    input integer n;
    integer j;
    begin
      psel = 1'b0; penable = 1'b0;
      for (j = 0; j < n; j = j + 1) begin @(posedge clk); #1; end
    end
  endtask

  task cfg;
    input integer w;
    input integer r;
    begin
      a_wait = w; resp_delay = r;
      dev_err = 1'b0; dev_bad_op = 1'b0; dev_bad_src = 1'b0;
    end
  endtask

  // ------------------------------------------------------------------ random helpers
  integer seed, seed0;
  function integer rnd;
    input integer max;
    integer v;
    begin
      v = $random(seed);
      if (v < 0) v = -v;
      if (v < 0) v = 0;
      rnd = v % max;
    end
  endfunction

  // ------------------------------------------------------------------ tests
  reg [PARA_ADDR_W-1:0] addr_t;
  reg [31:0] data_t;
  integer i, k, w, r, nrand, kind, mode;

  task rand_addr;
    begin
      addr_t = $random(seed);
      addr_t[1:0] = 2'b00;
    end
  endtask

  initial begin
    if (!$value$plusargs("SEED=%d", seed)) seed = 1;
    seed0 = seed;
    if (!$value$plusargs("N=%d", nrand)) nrand = 400;
    for (i = 0; i < NWORDS; i = i + 1) begin
      mem[i]     = 32'hA5A50000 | i;
      exp_mem[i] = 32'hA5A50000 | i;
    end

    // ---- reset values, then release
    repeat (3) @(posedge clk);
    #1;
    if (pready !== 1'b0 || pslverr !== 1'b0 || prdata !== 32'h0 || a_valid !== 1'b0 || d_ready !== 1'b0 ||
        a_opcode !== 3'b000 || a_address !== 0 || a_data !== 32'h0)
      fail("outputs are not 0 in reset");
    rst_n = 1'b1;
    repeat (2) @(posedge clk);
    #1;
    if (d_ready !== 1'b1) fail("d_ready is not 1 after reset release");

    // ---- T1: write then read back for every back pressure and response delay
    $display("T1: latency combinations");
    for (w = 0; w < 4; w = w + 1)
      for (r = 0; r < 4; r = r + 1) begin
        cfg(w, r);
        rand_addr; data_t = $random(seed);
        xfer(1'b1, addr_t, 4'hF, data_t, 1'b0);
        xfer(1'b0, addr_t, 4'h0, 32'h0, 1'b0);
      end

    // ---- T2: read ignores PSTRB (all 16 values), illegal strobes on a write (15 values)
    $display("T2: strobes");
    cfg(0, 1);
    for (k = 0; k < 16; k = k + 1) begin
      rand_addr;
      xfer(1'b0, addr_t, k[3:0], 32'h0, 1'b0);
    end
    for (k = 0; k < 15; k = k + 1) begin
      rand_addr; data_t = $random(seed);
      xfer(1'b1, addr_t, k[3:0], data_t, 1'b0);
    end

    // ---- T3: misaligned addresses
    $display("T3: misaligned addresses");
    for (k = 1; k < 4; k = k + 1) begin
      rand_addr; addr_t[1:0] = k[1:0];
      xfer(1'b0, addr_t, 4'h0, 32'h0, 1'b0);
      xfer(1'b1, addr_t, 4'hF, 32'h12345678, 1'b0);
    end

    // ---- T4: error, wrong opcode and wrong source from the device, read and write
    $display("T4: response errors");
    for (w = 0; w < 3; w = w + 2)
      for (r = 0; r < 3; r = r + 2)
        for (mode = 0; mode < 3; mode = mode + 1) begin
          cfg(w, r);
          dev_err = (mode == 0); dev_bad_op = (mode == 1); dev_bad_src = (mode == 2);
          rand_addr; data_t = $random(seed);
          xfer(1'b1, addr_t, 4'hF, data_t, 1'b0);
          xfer(1'b0, addr_t, 4'h0, 32'h0, 1'b0);
        end
    cfg(0, 1);

    // ---- T5: orphan responses must not disturb anything
    $display("T5: orphan responses");
    cfg(0, 1);
    for (k = 1; k <= 8; k = k + 1) begin
      if (k != 2) begin                       // k = 2 is the acceptance cycle, a legal response time
        arm_orph(k);
        rand_addr;
        xfer(1'b0, addr_t, 4'h0, 32'h0, 1'b0);
        idle(2);
      end
    end
    cfg(3, 1);
    for (k = 1; k <= 4; k = k + 1) begin      // Setup, and three stalled cycles of channel A
      arm_orph(k);
      rand_addr;
      xfer(1'b0, addr_t, 4'h0, 32'h0, 1'b0);
      idle(2);
    end
    cfg(0, 1);
    for (k = 0; k < 6; k = k + 1) begin       // orphans while idle
      arm_orph(1);
      idle(2);
      if (pready !== 1'b0 || a_valid !== 1'b0) fail("an orphan response changed an output");
    end

    // ---- T6: back-to-back with PSEL held and with gaps, every ordered pair of transfer kinds
    $display("T6: back-to-back transfers");
    for (w = 0; w < 2; w = w + 1)
      for (i = 0; i < 4; i = i + 1)
        for (k = 0; k < 4; k = k + 1) begin
          cfg(w, w);
          rand_addr; data_t = $random(seed);
          case (i)
            0: xfer(1'b1, addr_t, 4'hF, data_t, 1'b1);
            1: xfer(1'b0, addr_t, 4'h0, 32'h0, 1'b1);
            2: xfer(1'b1, addr_t, 4'h5, data_t, 1'b1);
            default: begin addr_t[1:0] = 2'b10; xfer(1'b0, addr_t, 4'h0, 32'h0, 1'b1); end
          endcase
          rand_addr; data_t = $random(seed);
          case (k)
            0: xfer(1'b1, addr_t, 4'hF, data_t, 1'b0);
            1: xfer(1'b0, addr_t, 4'h0, 32'h0, 1'b0);
            2: xfer(1'b1, addr_t, 4'hA, data_t, 1'b0);
            default: begin addr_t[1:0] = 2'b01; xfer(1'b1, addr_t, 4'hF, data_t, 1'b0); end
          endcase
        end

    // ---- T7: reset in the middle of a transfer
    $display("T7: reset during a transfer");
    cfg(0, 3);
    rand_addr;
    psel = 1'b1; penable = 1'b0; pwrite = 1'b1; paddr = addr_t; pstrb = 4'hF; pwdata = 32'hCAFEF00D;
    @(posedge clk); #1;
    penable = 1'b1;
    repeat (2) begin @(posedge clk); #1; end
    rst_n = 1'b0;
    repeat (2) @(posedge clk);
    #1;
    psel = 1'b0; penable = 1'b0;
    rst_n = 1'b1;
    repeat (3) @(posedge clk);
    #1;
    if (pready !== 1'b0 || a_valid !== 1'b0) fail("outputs active after a reset during a transfer");
    if (d_ready !== 1'b1) fail("d_ready is not 1 after the second reset release");
    // The write accepted before the reset did reach the device, so the model of the memory follows it.
    exp_mem[addr_t[7:2]] = mem[addr_t[7:2]];
    cfg(0, 1);
    xfer(1'b0, addr_t, 4'h0, 32'h0, 1'b0);

    // ---- T8: constrained-random transfers, PSEL held half of the time
    $display("T8: %0d random transfers, seed %0d", nrand, seed0);
    for (i = 0; i < nrand; i = i + 1) begin
      cfg(rnd(4), rnd(4));
      rand_addr; data_t = $random(seed);
      kind = rnd(100);
      if (kind < 35) begin
        xfer(1'b1, addr_t, 4'hF, data_t, rnd(2));
      end else if (kind < 65) begin
        xfer(1'b0, addr_t, rnd(16), 32'h0, rnd(2));
      end else if (kind < 75) begin
        k = rnd(15);
        xfer(1'b1, addr_t, k[3:0], data_t, rnd(2));
      end else if (kind < 85) begin
        addr_t[1:0] = 1 + rnd(3);
        xfer(rnd(2), addr_t, 4'hF, data_t, rnd(2));
      end else begin
        mode = rnd(3);
        dev_err = (mode == 0); dev_bad_op = (mode == 1); dev_bad_src = (mode == 2);
        xfer(rnd(2), addr_t, 4'hF, data_t, rnd(2));
      end
    end
    idle(4);

    chk.report;
    if (fails == 0 && chk.fails == 0 && chk.vacuous == 0) begin
      $display("TB PASS: apb_tlul_bridge, %0d TL-UL requests, 36 protocol assertions, ADDR_W=%0d SRC_W=%0d SRC_ID=%0d",
               req_count, PARA_ADDR_W, PARA_SRC_W, PARA_SRC_ID);
      $finish;
    end else begin
      $fatal(1, "TB FAIL: %0d testbench check(s), %0d assertion failure(s), %0d assertion(s) never exercised",
             fails, chk.fails, chk.vacuous);
    end
  end

  // Safety net: a hang is a failure.
  initial begin
    #50000000;
    $fatal(1, "TB FAIL: time-out");
  end

endmodule
