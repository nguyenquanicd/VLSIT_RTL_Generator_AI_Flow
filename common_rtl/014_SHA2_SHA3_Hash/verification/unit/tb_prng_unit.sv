// Unit test of the random bit source (stage 2b): seed from the seed registers and from the entropy port; the
// state is printed when o_seeded is first seen and three cycles later. Verification code, not RTL.
`timescale 1ns/1ps
module tb_prng_unit;
  logic clk = 0, rst_n = 0;
  always #5 clk = ~clk;
  logic load = 0, srst = 0, ev = 0;
  logic [255:0] seed = 256'h0123456789abcdeffedcba98765432100f1e2d3c4b5a69788796a5b4c3d2e1f0;
  logic [31:0] edata = 0;
  logic req, seeded, req2, seeded2;
  logic [1599:0] rnd, rnd2;
  m_vlsit_sha_prng #(.PARA_SEED_SRC(1)) u_a (.i_clk_core(clk), .i_rst_n_core(rst_n), .i_srst(srst), .i_seed_load(load), .i_seed_wd(seed),
    .i_ent_valid(1'b0), .i_ent_data(32'b0), .o_ent_req(req), .o_seeded(seeded), .o_rnd(rnd));
  m_vlsit_sha_prng #(.PARA_SEED_SRC(0)) u_b (.i_clk_core(clk), .i_rst_n_core(rst_n), .i_srst(srst), .i_seed_load(1'b0), .i_seed_wd(256'b0),
    .i_ent_valid(ev), .i_ent_data(edata), .o_ent_req(req2), .o_seeded(seeded2), .o_rnd(rnd2));
  integer k = 0, cnt_a = 0, cnt_b = 0, nwords = 0;
  // entropy source model: every third request is answered in the next cycle with the word 0x11110000 + request count
  always @(posedge clk) begin
    ev <= 0;
    if (req2 && !ev) begin
      k <= k + 1;
      if (k % 3 == 2) begin ev <= 1; edata <= 32'h11110000 + k; end
    end
  end
  always @(posedge clk) begin
    if (rst_n && req2 && ev) begin nwords = nwords + 1; $display("ENT %0d %08h eidx=%0d gap=%b", nwords, edata, u_b.reg_eidx, u_b.reg_gap); end
    if (seeded) begin
      cnt_a = cnt_a + 1;
      if (cnt_a == 1 || cnt_a == 4) $display("PRNG-A %0d %h", cnt_a, rnd);
    end
    if (seeded2) begin
      cnt_b = cnt_b + 1;
      if (cnt_b == 1) $display("PRNG-B %0d %h", cnt_b, rnd2);
    end
  end
  initial begin
    #43 rst_n = 1;
    repeat (4) @(posedge clk);
    #1 load = 1; @(posedge clk); #1 load = 0;
    repeat (200) @(posedge clk);
    $display("PRNG-STATUS seeded_a=%0d seeded_b=%0d words=%0d", seeded, seeded2, nwords);
    #1 srst = 1; @(posedge clk); #1 srst = 0;
    repeat (3) @(posedge clk);
    $display("PRNG-AFTER-SRST seeded_a=%0d seeded_b=%0d", seeded, seeded2);
    $finish;
  end
endmodule
