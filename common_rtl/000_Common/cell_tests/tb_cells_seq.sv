`timescale 1ns/1ps
//------------------------------------------------------------------------------
// Random test of the sequential cells VLSIT_CELL_* (flip-flops, latches, clock gate) against a
// reference model written in the testbench. The data inputs change 2 ns after a clock edge or
// edge-time, the asynchronous reset and set pulse at random times, and every output is compared
// at 4 ns and at 1 ns after the clock edges. Verification code: not part of the cell file set.
//------------------------------------------------------------------------------
module tb_cells_seq;
  integer errors = 0;
  integer cyc;
  integer seed = 7;

  reg CK = 0;
  reg D = 0, E = 0, SE = 0, SI = 0, G = 1, TE = 0;
  reg RN = 1, SN = 1;
  always #5 CK = ~CK;

  // ---------------- DUTs
  wire q_dff, q_dff_rn, q_dff_sn, q_dff_rsn, q_dffe, q_dffe_rn, q_sdff, q_sdff_rn, q_dffn, q_dffn_rn;
  wire q_lat_h, q_lat_l, q_icg;
  VLSIT_CELL_DFF     u_dff     (.CK(CK), .D(D), .Q(q_dff));
  VLSIT_CELL_DFF_RN  u_dff_rn  (.CK(CK), .RN(RN), .D(D), .Q(q_dff_rn));
  VLSIT_CELL_DFF_SN  u_dff_sn  (.CK(CK), .SN(SN), .D(D), .Q(q_dff_sn));
  VLSIT_CELL_DFF_RSN u_dff_rsn (.CK(CK), .RN(RN), .SN(SN), .D(D), .Q(q_dff_rsn));
  VLSIT_CELL_DFFE    u_dffe    (.CK(CK), .D(D), .E(E), .Q(q_dffe));
  VLSIT_CELL_DFFE_RN u_dffe_rn (.CK(CK), .RN(RN), .D(D), .E(E), .Q(q_dffe_rn));
  VLSIT_CELL_SDFF    u_sdff    (.CK(CK), .D(D), .SE(SE), .SI(SI), .Q(q_sdff));
  VLSIT_CELL_SDFF_RN u_sdff_rn (.CK(CK), .RN(RN), .D(D), .SE(SE), .SI(SI), .Q(q_sdff_rn));
  VLSIT_CELL_DFFN    u_dffn    (.CK(CK), .D(D), .Q(q_dffn));
  VLSIT_CELL_DFFN_RN u_dffn_rn (.CK(CK), .RN(RN), .D(D), .Q(q_dffn_rn));
  VLSIT_CELL_LAT_H   u_lat_h   (.G(G), .D(D), .Q(q_lat_h));
  VLSIT_CELL_LAT_L   u_lat_l   (.G(G), .D(D), .Q(q_lat_l));
  VLSIT_CELL_ICG     u_icg     (.CK(CK), .E(E), .TE(TE), .Q(q_icg));

  // ---------------- reference models
  reg r_dff, r_dff_rn, r_dff_sn, r_dff_rsn, r_dffe, r_dffe_rn, r_sdff, r_sdff_rn, r_dffn, r_dffn_rn;
  reg r_lat_h, r_lat_l, r_en;

  always @(posedge CK) r_dff <= D;
  always @(posedge CK or negedge RN) r_dff_rn <= (RN == 1'b0) ? 1'b0 : D;
  always @(posedge CK or negedge SN) r_dff_sn <= (SN == 1'b0) ? 1'b1 : D;
  always @(posedge CK or negedge RN or negedge SN) begin
    if (RN == 1'b0)      r_dff_rsn <= 1'b0;
    else if (SN == 1'b0) r_dff_rsn <= 1'b1;
    else                 r_dff_rsn <= D;
  end
  always @(posedge CK) if (E) r_dffe <= D;
  always @(posedge CK or negedge RN) begin
    if (RN == 1'b0) r_dffe_rn <= 1'b0;
    else if (E)     r_dffe_rn <= D;
  end
  always @(posedge CK) r_sdff <= SE ? SI : D;
  always @(posedge CK or negedge RN) r_sdff_rn <= (RN == 1'b0) ? 1'b0 : (SE ? SI : D);
  always @(negedge CK) r_dffn <= D;
  always @(negedge CK or negedge RN) r_dffn_rn <= (RN == 1'b0) ? 1'b0 : D;
  always @* if (G)  r_lat_h = D;
  always @* if (!G) r_lat_l = D;
  always @* if (!CK) r_en = E | TE;
  wire r_icg = CK & r_en;

  task cmp(input [255:0] what, input got, input exp);
    begin
      if (got !== exp) begin
        errors = errors + 1;
        if (errors < 20) $display("FAIL %0s t=%0t got=%b exp=%b", what, $time, got, exp);
      end
    end
  endtask

  task compare_all;
    begin
      cmp("DFF", q_dff, r_dff);       cmp("DFF_RN", q_dff_rn, r_dff_rn);
      cmp("DFF_SN", q_dff_sn, r_dff_sn); cmp("DFF_RSN", q_dff_rsn, r_dff_rsn);
      cmp("DFFE", q_dffe, r_dffe);    cmp("DFFE_RN", q_dffe_rn, r_dffe_rn);
      cmp("SDFF", q_sdff, r_sdff);    cmp("SDFF_RN", q_sdff_rn, r_sdff_rn);
      cmp("DFFN", q_dffn, r_dffn);    cmp("DFFN_RN", q_dffn_rn, r_dffn_rn);
      cmp("LAT_H", q_lat_h, r_lat_h); cmp("LAT_L", q_lat_l, r_lat_l);
      cmp("ICG", q_icg, r_icg);
    end
  endtask

  // data inputs change away from the clock edges (edges at 5, 10, 15 ns ...: change at x2, x7)
  initial begin
    #1;
    for (cyc = 0; cyc < 4000; cyc = cyc + 1) begin
      #1;
      if (($time % 5) == 2) begin
        D  = $random(seed);
        E  = $random(seed);
        SE = $random(seed);
        SI = $random(seed);
        TE = (($random(seed) & 7) == 0);
        G  = ($random(seed) & 3) != 0;
      end
      if (($time % 5) == 3) begin
        // asynchronous pulses of reset and set, active about one cycle in eight
        RN = (($random(seed) & 7) != 0);
        SN = (($random(seed) & 7) != 0);
      end
      if (($time % 5) == 4 || ($time % 5) == 1) begin
        if (cyc > 20) compare_all;
      end
    end
    if (errors == 0) $display("PASS tb_cells_seq: 13 cells, 4000 steps");
    else             $display("FAIL tb_cells_seq: %0d errors", errors);
    $finish;
  end
endmodule
