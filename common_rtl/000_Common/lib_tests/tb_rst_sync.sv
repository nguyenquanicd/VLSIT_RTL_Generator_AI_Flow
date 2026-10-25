`timescale 1ns/1ps
//------------------------------------------------------------------------------
// Test of m_vlsit_rst_sync, depth options 1 to 4. Run twice:
//   with +define+VLSIT_SYNTHESIS : latency after the release is exactly the number of stages
//   without the macro            : latency counted from the release is N, N+1 or N+2 edges
//                                  (exactly N when +RSTSYNC_MSYNC_EN=0), N = number of stages
// The assertion must reach the output at once (asynchronous), in both flows.
// Verification code: not part of the design file set.
//------------------------------------------------------------------------------
module tb_rst_sync;
`ifdef VLSIT_SYNTHESIS
  localparam bit SYNTH = 1;
`else
  localparam bit SYNTH = 0;
`endif
  integer errors = 0;
  reg clk = 0;
  reg rst_src = 1;
  always #5 clk = ~clk;

  wire [4:1] o;
  m_vlsit_rst_sync #(.PARA_RST_SYNC_TYPE(1)) u_t1 (.i_clk_dst(clk), .i_rst_n_src(rst_src), .o_rst_n_dst(o[1]));
  m_vlsit_rst_sync #(.PARA_RST_SYNC_TYPE(2)) u_t2 (.i_clk_dst(clk), .i_rst_n_src(rst_src), .o_rst_n_dst(o[2]));
  m_vlsit_rst_sync #(.PARA_RST_SYNC_TYPE(3)) u_t3 (.i_clk_dst(clk), .i_rst_n_src(rst_src), .o_rst_n_dst(o[3]));
  m_vlsit_rst_sync #(.PARA_RST_SYNC_TYPE(4)) u_t4 (.i_clk_dst(clk), .i_rst_n_src(rst_src), .o_rst_n_dst(o[4]));

  integer stages [1:4];
  integer lat [1:4];
  integer t, k, trial, en_arg;
  reg model_on;
  integer seen_min [1:4];
  integer seen_max [1:4];

  initial begin
    stages[1] = 2; stages[2] = 2; stages[3] = 3; stages[4] = 4;
    for (k = 1; k <= 4; k = k + 1) begin seen_min[k] = 99; seen_max[k] = 0; end
    model_on = !SYNTH;
    if ($value$plusargs("RSTSYNC_MSYNC_EN=%d", en_arg)) model_on = model_on && (en_arg != 0);
    #1;
    rst_src = 0;
    #1;
    for (trial = 0; trial < 60; trial = trial + 1) begin
      // asynchronous assertion at a random time inside the cycle
      #(1 + ($urandom % 9));
      rst_src = 0;
      #0.1;
      for (k = 1; k <= 4; k = k + 1)
        if (o[k] !== 1'b0) begin errors = errors + 1; $display("FAIL t%0d assertion not immediate", k); end
      repeat (6) @(posedge clk);
      // release away from the edge, then count the edges until the output is 1
      @(negedge clk); #($urandom % 4);
      rst_src = 1;
      for (k = 1; k <= 4; k = k + 1) lat[k] = -1;
      for (t = 1; t <= 12; t = t + 1) begin
        @(posedge clk); #1;
        for (k = 1; k <= 4; k = k + 1)
          if (lat[k] < 0 && o[k] === 1'b1) lat[k] = t;
      end
      for (k = 1; k <= 4; k = k + 1) begin
        if (lat[k] < 0) begin errors = errors + 1; $display("FAIL t%0d never rose", k); end
        else begin
          if (lat[k] < seen_min[k]) seen_min[k] = lat[k];
          if (lat[k] > seen_max[k]) seen_max[k] = lat[k];
          if (!model_on && lat[k] != stages[k]) begin errors = errors + 1; $display("FAIL t%0d latency %0d expected %0d", k, lat[k], stages[k]); end
          if (model_on && (lat[k] < stages[k] || lat[k] > stages[k] + 2)) begin errors = errors + 1; $display("FAIL t%0d latency %0d out of range", k, lat[k]); end
        end
      end
    end
    for (k = 1; k <= 4; k = k + 1) $display("type %0d stages %0d: latency %0d..%0d edges", k, stages[k], seen_min[k], seen_max[k]);
    if (model_on) for (k = 1; k <= 4; k = k + 1)
      if (seen_min[k] == seen_max[k]) begin errors = errors + 1; $display("FAIL t%0d model never varied the latency", k); end
    if (errors == 0) $display("PASS tb_rst_sync (%0s)", SYNTH ? "synthesis branch" : model_on ? "simulation branch, model on" : "simulation branch, model off");
    else $display("FAIL tb_rst_sync: %0d errors", errors);
    $finish;
  end
endmodule
