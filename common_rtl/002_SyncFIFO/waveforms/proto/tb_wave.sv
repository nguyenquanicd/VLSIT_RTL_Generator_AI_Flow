`timescale 1ns/1ps
// Waveform bench of the prototype. The stimulus is read from <STIM>_wr.txt (one line per write-clock cycle:
// wr_en wr_data(hex) rst_n_sw) and <STIM>_rd.txt (one line per read-clock cycle: rd_en). Every DT ns (half of
// the common divisor of the two half periods) it prints one sample line "S time signals...". Run by gen_waves.py.
module tb_wave;
  parameter integer DEPTH = 8;
  parameter integer RETIME = 0;
  parameter integer HW = 5;
  parameter integer HR = 5;
  parameter integer DT = 5;
  parameter integer NSLOT = 80;
  parameter integer FULLTHR = 4;
  parameter integer EMPTYTHR = 2;
  parameter integer HRST_AT = 0;
  parameter integer HRST_CYC = 2;
  parameter integer W = 8;
  localparam integer OCCW = $clog2(DEPTH + 1);
  localparam integer PTRW = $clog2(2 * DEPTH);

  reg [8*200-1:0] stim;
  reg [8*220-1:0] fname;
  integer fw, fr, rc, wen, wsw, ren, wd;

  logic clk_wr = 0, clk_rd = 0, rst_n_wr = 0, rst_n_rd = 0, rst_n_sw = 1;
  always #(HW) clk_wr = ~clk_wr;
  always #(HR) clk_rd = ~clk_rd;

  logic wr_en = 0, rd_en = 0;
  logic [W-1:0] wr_data = 0;
  logic [OCCW-1:0] full_thr = FULLTHR, empty_thr = EMPTYTHR;
  wire full, full_thr_o, overflow, empty, empty_thr_o, underflow, busy;
  wire [W-1:0] rd_data;

  m_vlsit_sfifo_top #(.PARA_SFIFO_DEPTH(DEPTH), .PARA_SFIFO_DATA_W(W), .PARA_SFIFO_PTR_RETIME(RETIME)) dut (
    .i_clk_wr(clk_wr), .i_rst_n_wr(rst_n_wr), .i_wr_en(wr_en), .i_wr_data(wr_data), .i_full_thr(full_thr),
    .i_rst_n_sw(rst_n_sw), .o_sw_rst_busy(busy), .o_full(full), .o_full_thr(full_thr_o), .o_overflow(overflow),
    .i_clk_rd(clk_rd), .i_rst_n_rd(rst_n_rd), .i_rd_en(rd_en), .i_empty_thr(empty_thr), .o_rd_data(rd_data),
    .o_empty(empty), .o_empty_thr(empty_thr_o), .o_underflow(underflow));

  logic started = 0;
  integer hrst_done = 0;

  initial begin
    if (!$value$plusargs("STIM=%s", stim)) stim = "none";
    $sformat(fname, "%0s_wr.txt", stim); fw = $fopen(fname, "r");
    $sformat(fname, "%0s_rd.txt", stim); fr = $fopen(fname, "r");
    // Reset is released synchronously, 1 ns after a rising edge of each clock.
    #(6 * HW + 3);
    @(posedge clk_wr); #1 rst_n_wr = 1;
    @(posedge clk_rd); #1 rst_n_rd = 1;
    @(posedge clk_wr); @(posedge clk_wr);
    started = 1;
    $display("START %0.3f", $realtime);
  end

  always @(posedge clk_wr) begin
    #1;
    if (started) begin
      if (fw != 0 && !$feof(fw)) begin
        rc = $fscanf(fw, "%d %h %d\n", wen, wd, wsw);
        wr_en = wen[0]; wr_data = wd[W-1:0]; rst_n_sw = wsw[0];
      end else begin
        wr_en = 1'b0; rst_n_sw = 1'b1;
      end
    end
  end
  always @(posedge clk_rd) begin
    #1;
    if (started) begin
      if (fr != 0 && !$feof(fr)) begin
        rc = $fscanf(fr, "%d\n", ren);
        rd_en = ren[0];
      end else rd_en = 1'b0;
    end
  end

  // Optional hardware reset in the middle of the run: both resets fall at HRST_AT ns (asynchronously, not aligned to an
  // edge) and are released synchronously after HRST_CYC cycles of their own clocks.
  initial begin
    if (HRST_AT > 0) begin
      #(HRST_AT);
      rst_n_wr = 0; rst_n_rd = 0;
      #(2 * HRST_CYC * HW);
      @(posedge clk_wr); #1 rst_n_wr = 1;
      @(posedge clk_rd); #1 rst_n_rd = 1;
    end
  end

  // Sampler: the sample time is the middle of a slot, so a value that changes at a clock edge is the new one.
  integer k = 0;
  initial begin
    #(DT / 2.0);
    forever begin
      $display("S %0.3f %b %b %b %b %b %b %h %b %b %b %b %b %h %b %b %b %0d %0d %0d %0d %b %b %b %b %0d %0d",
               $realtime, clk_wr, clk_rd, rst_n_wr, rst_n_rd, rst_n_sw, wr_en, wr_data, full, full_thr_o,
               overflow, busy, rd_en, rd_data, empty, empty_thr_o, underflow,
               dut.u_wr.reg_wptr, dut.u_rd.reg_rptr, dut.u_wr.reg_fsm_srst_current_state,
               dut.u_rd.reg_fsm_srst_current_state, dut.w_req_wr, dut.w_ack_rd, dut.w_mem_wr_en, dut.u_rd.w_rd_acc,
               dut.w_mem_wr_addr, dut.w_mem_rd_addr);
      k = k + 1;
      if (k >= NSLOT) $finish;
      #(DT);
    end
  end
endmodule
