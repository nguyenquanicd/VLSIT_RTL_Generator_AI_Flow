// Protocol assertions of one AXI interface (verification code, not part of the design file set).
//
// Source: AMBA AXI and ACE Protocol Specification, IHI 0022 (A3.2.1 handshake, A3.3 write and read
// structure, A3.4.1 burst, A3.1.2 reset) and the specification of the upsizer (REQ-IF-002, REQ-IF-004,
// REQ-FUNC-017, SVA-001, SVA-002). One instance checks the S side (the stimulus of the testbench) and one
// instance checks the M side (the outputs of the IP). The stimulus is legal, so no assertion is masked.
//
// The simulator has no concurrent assertions, so every assertion is a clocked check: it samples at the
// rising edge before the flip-flops update, counts how many times the antecedent was true (hit) and how
// many times the consequent failed (bad).
`timescale 1ns/1ps

module ups_axi_chk #(
  parameter int DW    = 32,     // data width of the interface
  parameter int IDW   = 4,      // ID width
  parameter int AXI3  = 0,      // 1 = AXI3 profile (WID, 4-bit length, 2-bit lock), 0 = AXI4 profile
  parameter int NAME  = 0       // 0 = S side, 1 = M side (label of the report)
) (
  input  wire              clk,
  input  wire              rst_n,
  input  wire              awvalid, input wire awready,
  input  wire [IDW-1:0]    awid,
  input  wire [63:0]       awaddr,
  input  wire [7:0]        awlen,
  input  wire [2:0]        awsize,
  input  wire [1:0]        awburst,
  input  wire [1:0]        awlock,
  input  wire [3:0]        awcache,
  input  wire [2:0]        awprot,
  input  wire [7:0]        awqr,
  input  wire              wvalid, input wire wready,
  input  wire [IDW-1:0]    wid,
  input  wire [DW/8-1:0]   wstrb,
  input  wire              wlast,
  input  wire [DW-1:0]     wdata,
  input  wire              bvalid, input wire bready,
  input  wire [IDW-1:0]    bid,
  input  wire [1:0]        bresp,
  input  wire              arvalid, input wire arready,
  input  wire [IDW-1:0]    arid,
  input  wire [63:0]       araddr,
  input  wire [7:0]        arlen,
  input  wire [2:0]        arsize,
  input  wire [1:0]        arburst,
  input  wire [1:0]        arlock,
  input  wire [3:0]        arcache,
  input  wire [2:0]        arprot,
  input  wire [7:0]        arqr,
  input  wire              rvalid, input wire rready,
  input  wire [IDW-1:0]    rid,
  input  wire [1:0]        rresp,
  input  wire              rlast,
  input  wire [DW-1:0]     rdata
);
  localparam int NA = 33;
  localparam int IDN = 1 << IDW;
  localparam int BUSB = DW / 8;

  int hit [NA];
  int bad [NA];
  int en  [NA];
  string nm [NA];

  initial begin
    for (int i = 0; i < NA; i++) begin hit[i] = 0; bad[i] = 0; en[i] = 1; nm[i] = ""; end
    nm[0]  = "AXI-01 AW payload stable while AWVALID and not AWREADY (IHI0022 A3.2.1, REQ-IF-002)";
    nm[1]  = "AXI-02 AWVALID held until AWREADY (IHI0022 A3.2.1)";
    nm[2]  = "AXI-03 W payload stable while WVALID and not WREADY (IHI0022 A3.2.1, REQ-IF-002)";
    nm[3]  = "AXI-04 WVALID held until WREADY (IHI0022 A3.2.1)";
    nm[4]  = "AXI-05 B payload stable while BVALID and not BREADY (IHI0022 A3.2.1)";
    nm[5]  = "AXI-06 BVALID held until BREADY (IHI0022 A3.2.1)";
    nm[6]  = "AXI-07 AR payload stable while ARVALID and not ARREADY (IHI0022 A3.2.1, REQ-IF-002)";
    nm[7]  = "AXI-08 ARVALID held until ARREADY (IHI0022 A3.2.1)";
    nm[8]  = "AXI-09 R payload stable while RVALID and not RREADY (IHI0022 A3.2.1)";
    nm[9]  = "AXI-10 RVALID held until RREADY (IHI0022 A3.2.1)";
    nm[10] = "AXI-11 no X on the AW payload while AWVALID (SVA-002)";
    nm[11] = "AXI-12 no X on WSTRB, WLAST, WID while WVALID (SVA-002)";
    nm[12] = "AXI-13 no X on the B payload while BVALID (SVA-002)";
    nm[13] = "AXI-14 no X on the AR payload while ARVALID (SVA-002)";
    nm[14] = "AXI-15 no X on RID, RRESP, RLAST while RVALID (SVA-002)";
    nm[15] = "AXI-16 AWSIZE not larger than the data bus (IHI0022 A3.4.1)";
    nm[16] = "AXI-17 ARSIZE not larger than the data bus (IHI0022 A3.4.1)";
    nm[17] = "AXI-18 AWBURST not reserved 3 (IHI0022 A3.4.1)";
    nm[18] = "AXI-19 ARBURST not reserved 3 (IHI0022 A3.4.1)";
    nm[19] = "AXI-20 AW INCR burst does not cross a 4KB boundary (IHI0022 A3.4.1, REQ-FUNC-017)";
    nm[20] = "AXI-21 AR INCR burst does not cross a 4KB boundary (IHI0022 A3.4.1, REQ-FUNC-017)";
    nm[21] = "AXI-22 AW WRAP length 2, 4, 8 or 16 and start aligned to the size (IHI0022 A3.4.1)";
    nm[22] = "AXI-23 AR WRAP length 2, 4, 8 or 16 and start aligned to the size (IHI0022 A3.4.1)";
    nm[23] = "AXI-24 AW FIXED and WRAP burst of at most 16 beats (IHI0022 A3.4.1, REQ-FUNC-017)";
    nm[24] = "AXI-25 AR FIXED and WRAP burst of at most 16 beats (IHI0022 A3.4.1, REQ-FUNC-017)";
    nm[25] = "AXI-26 WLAST on the beat AWLEN + 1 of the transaction (IHI0022 A3.4.1, SVA-005)";
    nm[26] = "AXI-27 RLAST on the beat ARLEN + 1 and RID equal to the oldest AR (IHI0022 A3.4.1, SVA-006, SVA-008)";
    nm[27] = "AXI-28 R beat only while an AR is outstanding (IHI0022 A3.3.1)";
    nm[28] = "AXI-29 B only after the AW and the last W beat of its transaction (IHI0022 A3.3.1)";
    nm[29] = "AXI-30 VALID outputs low in reset (IHI0022 A3.1.2, SVA-002)";
    nm[30] = "AXI-31 AXI3: AWLOCK not reserved 3 (IHI0022 AXI3 A7.2.4)";
    nm[31] = "AXI-32 AXI3: ARLOCK not reserved 3 (IHI0022 AXI3 A7.2.4)";
    nm[32] = "AXI-33 no X on AWCACHE and AWPROT while AWVALID (SVA-002)";
    if (!AXI3) begin en[30] = 0; en[31] = 0; end
  end

  task automatic chk(input int id, input bit ante, input bit cons);
    if (en[id] && ante) begin
      hit[id] = hit[id] + 1;
      if (!cons) begin
        bad[id] = bad[id] + 1;
        if (bad[id] <= 5) $display("ASSERT FAIL @%0t [%0s]: %0s", $time, NAME == 0 ? "S side" : "M side", nm[id]);
      end
    end
  endtask

  // state of the previous cycle
  bit              p_rst_n;
  bit              p_awv, p_awr, p_wv, p_wr, p_bv, p_br, p_arv, p_arr, p_rv, p_rr;
  logic [IDW+64+8+3+2+2+4+3+8-1:0]  p_aw, p_ar;
  logic [IDW+DW/8+1+DW-1:0]         p_w;
  logic [IDW+2-1:0]                 p_b;
  logic [IDW+DW+2+1-1:0]            p_r;
  bit              pp_rst_n;
  logic [IDW+64+8+3+2+2+4+3+8-1:0]  c_aw, c_ar;
  logic [IDW+DW/8+1+DW-1:0]         c_w;
  logic [IDW+2-1:0]                 c_b;
  logic [IDW+DW+2+1-1:0]            c_r;

  // pairing state: lengths of the AW and AR, beat counters, completed W counts, B credit
  int awq   [IDN][$];     // AXI3: per ID; AXI4: only index 0
  int awq_g [$];          // AXI4: global order
  int awid_g[$];
  int wdq   [IDN][$];     // completed W beat counts (per WID in AXI3, index 0 in AXI4)
  int wcnt  [IDN];
  int bcr   [IDN];        // B credit per ID
  int arq_len [$];
  int arq_id  [$];
  int rcnt;
  int i;
  int wi_idx;
  int sh;
  bit [63:0] a64, nb64, end64;
  int bl;
  int wl, al_;
  int wid_k;

  function automatic int idx_of(input bit [IDW-1:0] x);
    return int'(x);
  endfunction

  task automatic pair_w(input int idk);
    int lenx, cntx, aid;
    // AW and completed W data of the same stream are paired in order
    while (((AXI3 != 0) ? (awq[idk].size() > 0) : (awq_g.size() > 0)) && wdq[(AXI3 != 0) ? idk : 0].size() > 0) begin
      if (AXI3 != 0) begin lenx = awq[idk].pop_front(); aid = idk; end
      else begin lenx = awq_g.pop_front(); aid = awid_g.pop_front(); end
      cntx = wdq[(AXI3 != 0) ? idk : 0].pop_front();
      chk(25, 1'b1, cntx == lenx + 1);
      bcr[aid] = bcr[aid] + 1;
    end
  endtask

  always @(posedge clk) begin
    c_aw = {awid, awaddr, awlen, awsize, awburst, awlock, awcache, awprot, awqr};
    c_ar = {arid, araddr, arlen, arsize, arburst, arlock, arcache, arprot, arqr};
    c_w  = {wid, wstrb, wlast, wdata};
    c_b  = {bid, bresp};
    c_r  = {rid, rdata, rresp, rlast};

    if (!rst_n) begin
      p_awv = 0; p_wv = 0; p_bv = 0; p_arv = 0; p_rv = 0;
      p_awr = 0; p_wr = 0; p_br = 0; p_arr = 0; p_rr = 0;
      for (i = 0; i < IDN; i++) begin awq[i].delete(); wdq[i].delete(); wcnt[i] = 0; bcr[i] = 0; end
      awq_g.delete(); awid_g.delete(); arq_len.delete(); arq_id.delete(); rcnt = 0;
      // AXI-30: the VALID outputs are low from the second cycle of the reset
      chk(29, !p_rst_n && !pp_rst_n, !awvalid && !wvalid && !arvalid && !bvalid && !rvalid);
    end else begin
      // AXI-01..AXI-10: stability and VALID hold (A3.2.1)
      chk(0, p_awv && !p_awr, awvalid && c_aw === p_aw);
      chk(1, p_awv && !p_awr, awvalid);
      chk(2, p_wv && !p_wr, wvalid && c_w === p_w);
      chk(3, p_wv && !p_wr, wvalid);
      chk(4, p_bv && !p_br, bvalid && c_b === p_b);
      chk(5, p_bv && !p_br, bvalid);
      chk(6, p_arv && !p_arr, arvalid && c_ar === p_ar);
      chk(7, p_arv && !p_arr, arvalid);
      chk(8, p_rv && !p_rr, rvalid && c_r === p_r);
      chk(9, p_rv && !p_rr, rvalid);
      // AXI-11..AXI-15, AXI-33: validity
      chk(10, awvalid, !$isunknown({awid, awaddr, awlen, awsize, awburst, awlock}));
      chk(32, awvalid, !$isunknown({awcache, awprot}));
      chk(11, wvalid, !$isunknown({wstrb, wlast, wid}));
      chk(12, bvalid, !$isunknown({bid, bresp}));
      chk(13, arvalid, !$isunknown({arid, araddr, arlen, arsize, arburst, arlock}));
      chk(14, rvalid, !$isunknown({rid, rresp, rlast}));
      // AXI-16..AXI-25: encoding of the address channels (A3.4.1) at the handshake
      nb64 = 64'd1 << awsize;
      bl   = awlen + 1;
      chk(15, awvalid, (1 << awsize) <= BUSB);
      chk(17, awvalid, awburst != 2'b11);
      end64 = (awaddr / nb64) * nb64 + bl * nb64 - 1;
      chk(19, awvalid && awburst == 2'b01, (awaddr >> 12) == (end64 >> 12));
      chk(21, awvalid && awburst == 2'b10,
          (bl == 2 || bl == 4 || bl == 8 || bl == 16) && (awaddr % nb64) == 0);
      chk(23, awvalid && awburst != 2'b01, bl <= 16);
      nb64 = 64'd1 << arsize;
      bl   = arlen + 1;
      chk(16, arvalid, (1 << arsize) <= BUSB);
      chk(18, arvalid, arburst != 2'b11);
      end64 = (araddr / nb64) * nb64 + bl * nb64 - 1;
      chk(20, arvalid && arburst == 2'b01, (araddr >> 12) == (end64 >> 12));
      chk(22, arvalid && arburst == 2'b10,
          (bl == 2 || bl == 4 || bl == 8 || bl == 16) && (araddr % nb64) == 0);
      chk(24, arvalid && arburst != 2'b01, bl <= 16);
      chk(30, awvalid, awlock != 2'b11);
      chk(31, arvalid, arlock != 2'b11);

      // handshakes: pairing of AW and W, AR and R, B credit
      if (awvalid && awready) begin
        if (AXI3 != 0) awq[idx_of(awid)].push_back(int'(awlen));
        else begin awq_g.push_back(int'(awlen)); awid_g.push_back(idx_of(awid)); end
        pair_w((AXI3 != 0) ? idx_of(awid) : 0);
      end
      if (wvalid && wready) begin
        wid_k = (AXI3 != 0) ? idx_of(wid) : 0;
        wcnt[wid_k] = wcnt[wid_k] + 1;
        if (wlast) begin
          wdq[wid_k].push_back(wcnt[wid_k]);
          wcnt[wid_k] = 0;
          if (AXI3 != 0) pair_w(wid_k);
          else pair_w(0);
        end
      end
      if (bvalid && bready) begin
        chk(28, 1'b1, bcr[idx_of(bid)] > 0);
        if (bcr[idx_of(bid)] > 0) bcr[idx_of(bid)] = bcr[idx_of(bid)] - 1;
      end
      if (arvalid && arready) begin
        arq_len.push_back(int'(arlen));
        arq_id.push_back(idx_of(arid));
      end
      if (rvalid && rready) begin
        chk(27, 1'b1, arq_len.size() > 0);
        if (arq_len.size() > 0) begin
          rcnt = rcnt + 1;
          chk(26, 1'b1, (rlast == (rcnt == arq_len[0] + 1)) && (idx_of(rid) == arq_id[0]));
          if (rlast || rcnt == arq_len[0] + 1) begin
            void'(arq_len.pop_front());
            void'(arq_id.pop_front());
            rcnt = 0;
          end
        end
      end
    end
    pp_rst_n = p_rst_n;
    p_rst_n = rst_n;
    p_awv = awvalid; p_awr = awready; p_wv = wvalid; p_wr = wready; p_bv = bvalid; p_br = bready;
    p_arv = arvalid; p_arr = arready; p_rv = rvalid; p_rr = rready;
    p_aw = c_aw; p_ar = c_ar; p_w = c_w; p_b = c_b; p_r = c_r;
  end
endmodule
