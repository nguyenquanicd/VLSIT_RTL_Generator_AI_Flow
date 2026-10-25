`timescale 1ns/1ps
//------------------------------------------------------------------------------
// Waveform testbench of the Async Gray FIFO: it drives the real RTL (m_vlsit_afifo_top) and is only
// used to draw the figures of Section 10.6 of the specification (not a verification testbench).
// Every input of the write interface changes at a rising edge of i_clk_wr and every input of the
// read interface at a rising edge of i_clk_rd (non-blocking assignment at the edge), so that the
// design samples it at the next edge. The resets are released at a rising edge of their clock.
//   SCEN = 1 : write 4 words, overflow, read, underflow, write to an empty FIFO that is read every cycle
//   SCEN = 2 : back-to-back write and read, one word per clock cycle with no gap
//   USE_MACRO = 0 : RTL array, 1 : SRAM macro model
// Simulate with +define+VLSIT_SYNTHESIS (plain synchronizer cells, nominal latency S).
//------------------------------------------------------------------------------
module tb_fifo_wave;
  parameter SCEN = 1, USE_MACRO = 0, DEPTH = 4, FULL_THR = 3, EMPTY_THR = 1;
  parameter WR_FIRST = 5, WR_HALF = 5, RD_FIRST = 7, RD_HALF = 7, NWORDS = 24;
  localparam AWD = $clog2(DEPTH), PW = AWD + 1, DW = 8;

  reg clk_wr = 0, clk_rd = 0, rst_n_wr = 0, rst_n_rd = 0;
  initial begin #(WR_FIRST); forever begin clk_wr = ~clk_wr; #(WR_HALF); end end
  initial begin #(RD_FIRST); forever begin clk_rd = ~clk_rd; #(RD_HALF); end end

  // inputs of the FIFO
  reg i_wr_en = 0, i_rd_en = 0;
  reg [DW-1:0] i_wr_data = 0;
  wire [PW-1:0] i_full_thr = FULL_THR;
  wire [PW-1:0] i_empty_thr = EMPTY_THR;
  wire o_full, o_full_thr, o_overflow, o_sw_rst_busy, o_empty, o_empty_thr, o_underflow;
  wire [DW-1:0] o_rd_data;

  m_vlsit_afifo_top #(
    .PARA_AFIFO_DEPTH         (DEPTH),
    .PARA_AFIFO_DATA_W        (DW),
    .PARA_AFIFO_MEM_USE_MACRO (USE_MACRO),
    .PARA_AFIFO_CELL_TYPE     (2)
  ) dut (
    .i_clk_wr        (clk_wr),
    .i_rst_n_wr      (rst_n_wr),
    .i_wr_en         (i_wr_en),
    .i_wr_data       (i_wr_data),
    .i_full_thr      (i_full_thr),
    .o_full          (o_full),
    .o_full_thr      (o_full_thr),
    .o_overflow      (o_overflow),
    .i_rst_n_sw      (1'b1),
    .o_sw_rst_busy   (o_sw_rst_busy),
    .i_clk_rd        (clk_rd),
    .i_rst_n_rd      (rst_n_rd),
    .i_rd_en         (i_rd_en),
    .i_empty_thr     (i_empty_thr),
    .o_rd_data       (o_rd_data),
    .o_empty         (o_empty),
    .o_empty_thr     (o_empty_thr),
    .o_underflow     (o_underflow)
  );

  // internal signals shown in the figures (hierarchical references, simulation only)
  wire [PW-1:0] wbin   = dut.u_vlsit_afifo_wr.reg_wbin;
  wire [PW-1:0] wgray  = dut.u_vlsit_afifo_wr.reg_wgray;
  wire [PW-1:0] rg_s   = dut.u_vlsit_afifo_wr.w_rgray_s;
  wire [PW-1:0] rbin   = dut.u_vlsit_afifo_rd.reg_rbin;
  wire [PW-1:0] rgray  = dut.u_vlsit_afifo_rd.reg_rgray;
  wire [PW-1:0] wg_s   = dut.u_vlsit_afifo_rd.w_wgray_s;
  wire wr_accept       = dut.u_vlsit_afifo_wr.w_wr_acc;
  wire rd_accept       = dut.u_vlsit_afifo_rd.w_rd_acc;
  wire mem_wr_en       = dut.w_mem_wr_en;
  wire [AWD-1:0] mem_wr_addr = dut.w_mem_wr_addr;
  wire [DW-1:0] mem_wr_data  = dut.w_mem_wr_data;
  wire [AWD-1:0] mem_rd_addr = dut.w_mem_rd_addr;
  wire [DW-1:0] rtl_q        = dut.w_mem_rd_data;
  wire WEB = ~dut.w_mem_wr_en;
  wire REB = 1'b0;
  wire [AWD-1:0] AW = dut.w_mem_wr_addr;
  wire [DW-1:0] DWb = dut.w_mem_wr_data;
  wire [AWD-1:0] AR = dut.w_mem_rd_addr;
  wire [DW-1:0] QR  = dut.w_mem_rd_data;

  // resets released at a rising edge of their own clock
  initial begin repeat (3) @(posedge clk_wr); rst_n_wr <= 1; end
  initial begin repeat (3) @(posedge clk_rd); rst_n_rd <= 1; end

  // drive tasks: the new value appears at the next rising edge and is sampled at the one after
  task wdrive(input en, input [DW-1:0] d);
    begin @(posedge clk_wr); i_wr_en <= en; i_wr_data <= d; end
  endtask
  task rdrive(input en);
    begin @(posedge clk_rd); i_rd_en <= en; end
  endtask

  integer k, cnt;
  string vcdname;
  initial begin
    if (!$value$plusargs("VCD=%s", vcdname)) vcdname = "fifo_wave.vcd";
    $dumpfile(vcdname);
    $dumpvars(0, tb_fifo_wave);
  end

  // scenario 1: words 11 22 33 44 fill the FIFO, 55 overflows, five reads, one write while the FIFO is empty
  initial if (SCEN == 1) begin
    #90;
    wdrive(1, 8'h11); wdrive(1, 8'h22); wdrive(1, 8'h33); wdrive(1, 8'h44); wdrive(1, 8'h55); wdrive(0, 8'h55);
    #95;
    wdrive(1, 8'h66);
    wdrive(0, 8'h66);
  end
  initial if (SCEN == 1) begin
    #150;
    rdrive(1);
    repeat (4) @(posedge clk_rd);
    rdrive(0);
    repeat (3) @(posedge clk_rd);
    rdrive(1);
    rdrive(0);
  end

  // scenario 2: NWORDS words written in consecutive write cycles, the consumer sets the read request
  // when it sees o_empty = 0 and keeps it, and drops it at the edge of the last accepted read
  initial if (SCEN == 2) begin
    #40;
    for (k = 1; k <= NWORDS; k = k + 1) wdrive(1, k[DW-1:0]);
    wdrive(0, 8'h00);
  end
  initial if (SCEN == 2) begin
    wait (o_empty == 0);
    rdrive(1);
    cnt = 0;
    while (cnt < NWORDS) begin
      @(posedge clk_rd);
      if (rd_accept) begin
        cnt = cnt + 1;
        if (cnt == NWORDS) i_rd_en <= 0;
      end
    end
  end

  initial begin
    if (SCEN == 1) #340;
    else           #360;
    $finish;
  end
endmodule
