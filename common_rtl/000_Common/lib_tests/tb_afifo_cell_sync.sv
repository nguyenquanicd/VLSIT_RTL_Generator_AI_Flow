`timescale 1ns/1ps
//------------------------------------------------------------------------------
// Test of the metastability model of m_vlsit_afifo_cell_sync (simulation branch, cell option 2, S = 2
// stages). Plusargs: +AFIFO_MSYNC_SEED=<n>, +AFIFO_MSYNC_EN=<0|1>, +AFIFO_MSYNC_WIN_PCT=<0..100>.
//   T1 input changes far from the capturing edge: the latency is exactly S edges.
//   T2 input changes inside the window: the latency is S or S+1 edges, both occur, about 50% each.
//   T3 a 3-bit Gray counter written every 10.26 ns and read at 14 ns: the code seen by the read side
//      never goes back in the sequence (no reordering of the bits).
// Verification code: not part of the design file set.
//------------------------------------------------------------------------------
module tb_afifo_cell_sync;
  integer errors = 0;
  localparam real TD = 14.0;
  localparam int  S  = 2;

  reg clk = 0;
  reg rst_n = 0;
  always #(TD/2.0) clk = ~clk;

  // ---- single bit for T1 and T2 ----
  reg  d1 = 0;
  wire q1;
  m_vlsit_afifo_cell_sync #(.PARA_AFIFO_CELL_TYPE(2)) u_bit (.i_clk_dst(clk), .i_rst_n_dst(rst_n), .i_d(d1), .o_q(q1));

  // ---- Gray counter bus for T3 ----
  reg        clk_s = 0;
  always #5.13 clk_s = ~clk_s;   // 10.26 ns: not a multiple of the 14 ns read period, so the phase sweeps
  reg  [2:0] cnt = 0;
  reg  [2:0] gray = 0;
  always @(posedge clk_s) begin
    cnt  <= cnt + 3'd1;
    gray <= (cnt + 3'd1) ^ ((cnt + 3'd1) >> 1);
  end
  wire [2:0] gq;
  genvar g;
  generate
    for (g = 0; g < 3; g = g + 1) begin : gen_b
      m_vlsit_afifo_cell_sync #(.PARA_AFIFO_CELL_TYPE(2)) u_b (.i_clk_dst(clk), .i_rst_n_dst(rst_n), .i_d(gray[g]), .o_q(gq[g]));
    end
  endgenerate

  function automatic [2:0] f_idx(input [2:0] c);
    integer k;
    begin
      f_idx = 3'd0;
      for (k = 0; k < 8; k = k + 1)
        if (c == (k[2:0] ^ (k[2:0] >> 1))) f_idx = k[2:0];
    end
  endfunction

  integer lat, t, trial, n_s, n_s1, en_arg, win_arg;
  bit     model_on;
  integer win_pct;
  reg [2:0] prev_idx, idx;
  integer back_steps, samples;

  task automatic run_latency(input real before_edge, output integer latency);
    begin
      // change d1 at 'before_edge' ns before the next rising edge, then count the edges until q1 follows
      @(posedge clk);
      #(TD - before_edge);
      d1 = ~d1;
      latency = -1;
      for (t = 1; t <= 8; t = t + 1) begin
        @(posedge clk); #0.01;
        if (latency < 0 && q1 === d1) latency = t;
      end
    end
  endtask

  initial begin
    model_on = 1;
    win_pct  = 10;
    if ($value$plusargs("AFIFO_MSYNC_EN=%d", en_arg)) model_on = (en_arg != 0);
    if ($value$plusargs("AFIFO_MSYNC_WIN_PCT=%d", win_arg)) win_pct = win_arg;
    #20 rst_n = 1;
    repeat (4) @(posedge clk);

    // T1: change 13 ns before the edge, outside every window up to 90%: latency must be exactly S
    for (trial = 0; trial < 100 && win_pct < 90; trial = trial + 1) begin
      run_latency(13.0, lat);
      if (lat != S) begin errors = errors + 1; $display("FAIL T1 trial %0d latency %0d expected %0d", trial, lat, S); end
    end

    // T2: change 0.3 ns before the edge: inside the window when the window is >= 3% of the period
    n_s = 0; n_s1 = 0;
    for (trial = 0; trial < 400; trial = trial + 1) begin
      run_latency(0.3, lat);
      if (lat == S) n_s = n_s + 1;
      else if (lat == S + 1) n_s1 = n_s1 + 1;
      else begin errors = errors + 1; $display("FAIL T2 trial %0d latency %0d is neither S nor S+1", trial, lat); end
    end
    $display("T2 latency S: %0d, S+1: %0d (model %0s, window %0d%%)", n_s, n_s1, model_on ? "on" : "off", win_pct);
    if (!model_on || win_pct == 0) begin
      if (n_s1 != 0) begin errors = errors + 1; $display("FAIL T2 model off or window 0 but S+1 seen"); end
    end else begin
      if (n_s < 120 || n_s1 < 120) begin errors = errors + 1; $display("FAIL T2 split is not about 50%% each"); end
    end

    // T3: Gray bus, count the backward steps of the code seen by the read side
    back_steps = 0; samples = 0; prev_idx = 0;
    repeat (4000) begin
      @(posedge clk); #0.01;
      idx = f_idx(gq);
      if (samples > 8 && (3'(idx - prev_idx) >= 3'd5)) begin
        back_steps = back_steps + 1;
      end
      prev_idx = idx;
      samples = samples + 1;
    end
    $display("T3 samples %0d, backward steps of the sampled Gray code: %0d", samples, back_steps);
    if (back_steps != 0) begin errors = errors + 1; $display("FAIL T3 the bits of the bus were reordered"); end

    if (errors == 0) $display("PASS tb_afifo_cell_sync");
    else $display("FAIL tb_afifo_cell_sync errors=%0d", errors);
    $finish;
  end
endmodule
