// Unit test of the masked Keccak core (stage 2b). Verification code, not RTL.
// The masked core is compared with the unmasked core m_vlsit_sha_keccak (checked against hashlib by the system
// tests): same block and state, the xor of the two output shares shall equal the plain result (REQ-SEC-003).
`timescale 1ns/1ps
module tb_mask_unit;
  logic clk = 0, rst_n = 0;
  always #5 clk = ~clk;
  logic start = 0, clr = 0, mask = 0;
  logic [1343:0] blk;
  logic [3199:0] st;
  logic [1599:0] rnd;
  logic done_d, done_r, perr;
  logic [3199:0] res_d;
  logic [1599:0] res_r;
  m_vlsit_sha_keccak_dom #(.PARA_PAR(1)) u_dom (.i_clk_core(clk), .i_rst_n_core(rst_n), .i_start(start), .i_clr(clr), .o_done(done_d),
    .i_block(blk), .i_state(st), .i_rnd(rnd), .i_mask_en(mask), .o_result(res_d), .o_par_err(perr));
  m_vlsit_sha_keccak #(.PARA_UNR(1), .PARA_PAR(0)) u_ref (.i_clk_core(clk), .i_rst_n_core(rst_n), .i_start(start), .i_clr(clr), .o_done(done_r),
    .i_block(blk), .i_state(st[1599:0] ^ st[3199:1600]), .o_result(res_r), .o_par_err());
  // fresh random bits in every cycle
  always @(posedge clk) begin
    for (int i = 0; i < 50; i++) rnd[32*i +: 32] <= $urandom;
  end
  integer n, bad = 0, ok = 0, shares_differ = 0, masked_runs = 0, perr_cnt = 0, tout;
  reg [1599:0] plain, sh0, sh1;
  initial begin
    for (int i = 0; i < 50; i++) rnd[32*i +: 32] = $urandom;
    #43 rst_n = 1;
    repeat (3) @(posedge clk);
    for (n = 0; n < 60; n++) begin
      mask = (n % 3) != 0;                       // two thirds masked, one third plain (random bits 0)
      for (int i = 0; i < 42; i++) blk[32*i +: 32] = $urandom;
      for (int i = 0; i < 100; i++) st[32*i +: 32] = $urandom;
      if (n % 5 == 0) st[3199:1600] = '0;        // an unshared state
      @(posedge clk); #1 start = 1;
      @(posedge clk); #1 start = 0;
      tout = 0;
      while (!done_d && tout < 200) begin
        @(posedge clk); tout = tout + 1;
        if (perr) perr_cnt = perr_cnt + 1;
      end
      @(posedge clk);
      sh0 = res_d[1599:0]; sh1 = res_d[3199:1600]; plain = res_r;
      if (((sh0 ^ sh1) === plain) && (tout < 200)) ok = ok + 1;
      else begin bad = bad + 1; $display("DOM MISMATCH n=%0d tout=%0d", n, tout); end
      if (mask) begin
        masked_runs = masked_runs + 1;
        if ((sh0 != plain) && (sh1 != '0)) shares_differ = shares_differ + 1;
      end else begin
        if (!((sh0 == plain) && (sh1 == '0)) && (st[3199:1600] == '0)) bad = bad + 1;
      end
    end
    $display("DOM-RESULT ok=%0d bad=%0d masked_runs=%0d random_shares=%0d parity_false_alarms=%0d", ok, bad, masked_runs, shares_differ, perr_cnt);
    $finish;
  end
endmodule
