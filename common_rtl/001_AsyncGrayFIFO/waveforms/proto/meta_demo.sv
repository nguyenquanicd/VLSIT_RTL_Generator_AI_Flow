`timescale 1ns/10ps
//------------------------------------------------------------------------------
// Demonstration of the synchronizer metastability simulation model (branch without VLSIT_SYNTHESIS).
// Only used to draw the waveform of the specification (not the RTL / model deliverable itself).
//   S stages (+S=2|3), W bits. The metastability model is the real wrapper m_vlsit_afifo_cell_sync
//   (one instance per bit): the first flop resolves to the old or to the new value, 50% each, when the
//   input changed inside the aperture window before the capturing edge (+AFIFO_MSYNC_WIN_PCT, percent
//   of the period of the destination clock), so a change reaches the output S or S+1 edges after the
//   change; the latency counted after the first capturing edge is S-1 or S.
//   The plain chain (EN = 0) is a chain of S flops. The demo measures, for every bit, how many
//   destination periods the model output is later than the plain chain output ("extra") and prints it.
//------------------------------------------------------------------------------
module msync_model #(parameter W = 4, parameter S = 2, parameter ID = 1, parameter EN = 1) (
  input clk, input rst_n, input [31:0] seed, input [W-1:0] d, output [W-1:0] q, output reg [W*3-1:0] lat);
  reg [W-1:0] ch [0:3];
  integer i;
  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      for (i = 0; i < 4; i = i + 1) ch[i] <= 0;
    end else begin
      ch[0] <= d;
      for (i = 1; i < 4; i = i + 1) ch[i] <= ch[i-1];
    end
  end
  wire [W-1:0] chain_out = ch[S-1];
  initial lat = 0;
  generate
    if (EN == 0) begin : g_plain
      assign q = chain_out;
    end else begin : g_meta
      wire [W-1:0] qm;
      assign q = qm;
      genvar b;
      for (b = 0; b < W; b = b + 1) begin : g_b
        m_vlsit_afifo_cell_sync #(.PARA_AFIFO_CELL_TYPE(S)) u_c (.i_clk_dst(clk), .i_rst_n_dst(rst_n), .i_d(d[b]), .o_q(qm[b]));
        real tp;
        reg  pend;
        integer extra;
        initial begin tp = 0; pend = 0; end
        // time of the change of the plain chain output of this bit
        always @(chain_out[b]) begin tp = $realtime; pend = 1; end
        // the model output follows the plain chain output with 0 or 1 destination periods of extra delay
        always @(qm[b]) begin
          #0.02;
          if (pend && rst_n) begin
            extra = (($realtime - 0.02 - tp) + 1.0) / 14.0;
            $display("LAT S=%0d t=%0.1f bit=%0d new=%b extra=%0d latency=%0d", S, tp, b, qm[b], extra, (S - 1) + extra);
            lat[b*3 +: 3] <= (S - 1) + extra;
            pend = 0;
          end
        end
      end
    end
  endgenerate
endmodule

module meta_demo;
  integer seed = 7;
  reg [31:0] seed_r = 7;
  initial begin if ($value$plusargs("SEED=%d", seed)) seed_r = seed; end
  reg clk_src = 0, clk_dst = 0, rst_n = 0;
  always #5 clk_src = ~clk_src;        // source clock  (period 10 ns)
  always #7 clk_dst = ~clk_dst;        // destination clock (period 14 ns)
  initial begin repeat (3) @(posedge clk_dst); rst_n <= 1; end   // released at a destination clock edge
  // source: bits [2:0] = Gray pointer (one bit changes per step), bit [3] = a fast toggling bit
  reg [3:0] src = 0;
  wire [3:0] q_nom, q_nom3, q_s2, q_s3;
  wire [11:0] lat_s2, lat_s3;
  // stage values of the nominal chain, S = 2
  msync_model #(.W(4), .S(2), .ID(1), .EN(0)) u_nom2 (.clk(clk_dst), .rst_n(rst_n), .seed(seed_r), .d(src), .q(q_nom), .lat());
  msync_model #(.W(4), .S(3), .ID(5), .EN(0)) u_nom3 (.clk(clk_dst), .rst_n(rst_n), .seed(seed_r), .d(src), .q(q_nom3), .lat());
  msync_model #(.W(4), .S(2), .ID(1), .EN(1)) u2 (.clk(clk_dst), .rst_n(rst_n), .seed(seed_r), .d(src), .q(q_s2), .lat(lat_s2));
  msync_model #(.W(4), .S(3), .ID(2), .EN(1)) u3 (.clk(clk_dst), .rst_n(rst_n), .seed(seed_r), .d(src), .q(q_s3), .lat(lat_s3));
  wire [2:0] lat0 = lat_s2[2:0], lat1 = lat_s2[5:3], lat2 = lat_s2[8:6], lat3 = lat_s2[11:9];
  wire [2:0] l3_0 = lat_s3[2:0], l3_1 = lat_s3[5:3], l3_2 = lat_s3[8:6], l3_3 = lat_s3[11:9];
  wire [2:0] g_nom3 = q_nom3[2:0];
  wire t_nom3 = q_nom3[3];
  wire [2:0] g_nom = q_nom[2:0], g_s2 = q_s2[2:0], g_s3 = q_s3[2:0], g_src = src[2:0];
  wire t_src = src[3], t_nom = q_nom[3], t_s2 = q_s2[3], t_s3 = q_s3[3];
  initial begin
    $dumpfile("meta.vcd"); $dumpvars(0, meta_demo);
    // Every input change is launched at a rising edge of the source clock (non-blocking assignment).
    // Slow Gray pointer steps 000 -> 001 -> 011 -> 010 -> 110 -> 111, six source cycles apart.
    #95;
    @(posedge clk_src) src[2:0] <= 3'b001;
    repeat (6) @(posedge clk_src); src[2:0] <= 3'b011;
    repeat (6) @(posedge clk_src); src[2:0] <= 3'b010;
    repeat (6) @(posedge clk_src); src[2:0] <= 3'b110;
    repeat (6) @(posedge clk_src); src[2:0] <= 3'b111;
    // Fast toggling bit: one change per source cycle (10 ns, shorter than the destination period of
    // 14 ns), so a pending change is replaced by the next one.
    repeat (5) @(posedge clk_src); src[3] <= 1'b1;
    @(posedge clk_src) src[3] <= 1'b0;
    @(posedge clk_src) src[3] <= 1'b1;
    @(posedge clk_src) src[3] <= 1'b0;
    repeat (9) @(posedge clk_src); src[3] <= 1'b1;
    #120 $finish;
  end
endmodule
