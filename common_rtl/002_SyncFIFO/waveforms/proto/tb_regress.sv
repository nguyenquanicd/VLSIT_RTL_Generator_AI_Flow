`timescale 1ns/1ps
// Self-checking regression of the prototype (scoreboard, depth limit, data order, stall counters).
// Parameters are set with iverilog -P: DEPTH, RETIME, HW and HR (half periods in ns), MODE
// (0 random traffic, 1 continuous write and continuous read), N (words), PW and PR (percent, mode 0).
module tb_regress;
  parameter integer DEPTH = 8;
  parameter integer RETIME = 0;
  parameter integer HW = 5;
  parameter integer HR = 5;
  parameter integer MODE = 1;
  parameter integer N = 400;
  parameter integer PW = 60;
  parameter integer PR = 60;
  parameter integer SEED = 1;
  parameter integer W = 16;

  localparam integer OCCW = $clog2(DEPTH + 1);

  logic clk_wr = 0, clk_rd = 0, rst_n_wr = 0, rst_n_rd = 0, rst_n_sw = 1;
  always #(HW) clk_wr = ~clk_wr;
  always #(HR) clk_rd = ~clk_rd;

  logic wr_en = 0, rd_en = 0;
  logic [W-1:0] wr_data = 0;
  logic [OCCW-1:0] full_thr = DEPTH, empty_thr = 0;
  wire full, full_thr_o, overflow, empty, empty_thr_o, underflow, busy;
  wire [W-1:0] rd_data;

  m_vlsit_sfifo_top #(.PARA_SFIFO_DEPTH(DEPTH), .PARA_SFIFO_DATA_W(W), .PARA_SFIFO_PTR_RETIME(RETIME)) dut (
    .i_clk_wr(clk_wr), .i_rst_n_wr(rst_n_wr), .i_wr_en(wr_en), .i_wr_data(wr_data), .i_full_thr(full_thr),
    .i_rst_n_sw(rst_n_sw), .o_sw_rst_busy(busy), .o_full(full), .o_full_thr(full_thr_o), .o_overflow(overflow),
    .i_clk_rd(clk_rd), .i_rst_n_rd(rst_n_rd), .i_rd_en(rd_en), .i_empty_thr(empty_thr), .o_rd_data(rd_data),
    .o_empty(empty), .o_empty_thr(empty_thr_o), .o_underflow(underflow));

  logic [W-1:0] q[$];
  integer wacc = 0, racc = 0, wstall = 0, rstall = 0, errors = 0, next_data = 0, seed_v;
  logic started = 0;

  initial begin
    seed_v = SEED;
    #(4 * HW + 3);
    rst_n_wr = 1; rst_n_rd = 1; started = 1;
  end

  // Drivers: inputs change 1 ns after the rising edge of their own clock.
  always @(posedge clk_wr) begin
    #1;
    if (started) begin
      if (MODE == 1) wr_en = (wacc < N);
      else wr_en = (($urandom(seed_v) % 100) < PW) && (wacc < N);
      wr_data = next_data[W-1:0];
    end
  end
  always @(posedge clk_rd) begin
    #1;
    if (started) begin
      if (MODE == 1) rd_en = 1'b1;
      else rd_en = (($urandom(seed_v) % 100) < PR);
    end
  end

  // Monitors: sample the values before the edge (the same values the design samples).
  always @(posedge clk_wr) begin
    if (started) begin
      if (wr_en && !full) begin
        q.push_back(wr_data); wacc = wacc + 1; next_data = next_data + 1;
        if (q.size() > DEPTH) begin errors = errors + 1; $display("ERR: more than DEPTH words stored"); end
      end
      if (wacc > 0 && wacc < N && wr_en && full) wstall = wstall + 1;
    end
  end
  always @(posedge clk_rd) begin
    if (started) begin
      if (rd_en && !empty) begin
        if (q.size() == 0) begin errors = errors + 1; $display("ERR: read of an empty scoreboard"); end
        else begin
          logic [W-1:0] exp;
          exp = q.pop_front();
          if (rd_data !== exp) begin errors = errors + 1; $display("ERR: data %h expected %h", rd_data, exp); end
        end
        racc = racc + 1;
      end
      if (racc > 0 && racc < N && rd_en && empty) rstall = rstall + 1;
      if (racc == N) begin
        $display("RESULT depth=%0d retime=%0d hw=%0d hr=%0d mode=%0d errors=%0d wacc=%0d racc=%0d wstall=%0d rstall=%0d",
                 DEPTH, RETIME, HW, HR, MODE, errors, wacc, racc, wstall, rstall);
        $finish;
      end
    end
  end

  initial begin
    #(100 * N * (HW + HR) + 100000);
    $display("RESULT depth=%0d retime=%0d hw=%0d hr=%0d mode=%0d errors=%0d TIMEOUT wacc=%0d racc=%0d", DEPTH, RETIME, HW, HR, MODE, errors + 1, wacc, racc);
    $finish;
  end
endmodule
