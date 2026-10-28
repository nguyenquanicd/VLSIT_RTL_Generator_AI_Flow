`timescale 1ns/1ps
//------------------------------------------------------------------------------
// Protocol assertions of the AXI2TLUL bridge (verification code, not part of the design file set).
// Written from the specification AXI2TLUL_Bridge_Design_Specification.md and from the standards:
//   AXI4  : REF-001 Arm IHI 0022 H.c (A3.1 reset, A3.2 handshake, A3.3 dependencies, A3.4 burst and response,
//           A5.2 identifiers)
//   TL-UL : REF-002 OpenTitan TL-UL (signals, usage of source, user bits, opcode, size and mask, explicit
//           error cases) and REF-006 (tl_a_user_t, TL_A_USER_DEFAULT, BlankedAData)
// The simulator has no concurrent assertions, so every assertion is a clocked check that samples the ports at
// the rising edge before the flip-flops update. Each one counts its hits (antecedent true) and fails
// (consequent false); the table is printed at the end and the run fails when a check fails or never fired.
// The checks use only the ports of the bridge. Three mask inputs disable exactly the stimulus-legality checks
// that a test breaks on purpose (illegal AXI burst, WLAST mismatch, wrong or orphaned TL-UL response).
//------------------------------------------------------------------------------
module axi2tlul_checks #(
  parameter DW = 32, AW = 32, IDW = 8, SRCW = 8, NRD = 16, NWR = 16, NIDR = 4, NIDW = 4
) (
  input wire                 clk,
  input wire                 rst_n,
  // AXI4
  input wire                 arvalid, arready,
  input wire [IDW-1:0]       arid,
  input wire [AW-1:0]        araddr,
  input wire [7:0]           arlen,
  input wire [2:0]           arsize,
  input wire [1:0]           arburst,
  input wire [2:0]           arprot,
  input wire                 awvalid, awready,
  input wire [IDW-1:0]       awid,
  input wire [AW-1:0]        awaddr,
  input wire [7:0]           awlen,
  input wire [2:0]           awsize,
  input wire [1:0]           awburst,
  input wire [2:0]           awprot,
  input wire                 wvalid, wready,
  input wire [DW-1:0]        wdata,
  input wire [DW/8-1:0]      wstrb,
  input wire                 wlast,
  input wire                 bvalid, bready,
  input wire [IDW-1:0]       bid,
  input wire [1:0]           bresp,
  input wire                 rvalid, rready,
  input wire [IDW-1:0]       rid,
  input wire [DW-1:0]        rdata,
  input wire [1:0]           rresp,
  input wire                 rlast,
  // TL-UL
  input wire                 a_valid, a_ready,
  input wire [2:0]           a_opcode, a_param,
  input wire [$clog2($clog2(DW/8)+1)-1:0] a_size,
  input wire [SRCW-1:0]      a_src,
  input wire [AW-1:0]        a_addr,
  input wire [DW/8-1:0]      a_mask,
  input wire [DW-1:0]        a_data,
  input wire [17:0]          a_user,
  input wire                 d_valid, d_ready,
  input wire [2:0]           d_opcode,
  input wire [SRCW-1:0]      d_src,
  // masks of the intentional violations of a stimulus rule
  input wire                 mask_axi_illegal,
  input wire                 mask_wlast,
  input wire                 mask_tl_resp
);
  localparam SB = DW / 8;
  localparam BW = $clog2(SB);
  localparam SLOTW = (NRD > NWR) ? $clog2(NRD) : $clog2(NWR);
  localparam NA = 80;
  localparam NID = (1 << IDW) < 256 ? (1 << IDW) : 256;
  localparam NSRC = 1024;

  integer hit [0:NA-1];
  integer bad [0:NA-1];
  reg [8*72-1:0] nm [0:NA-1];
  reg used [0:NA-1];
  integer ii;
  initial for (ii = 0; ii < NA; ii = ii + 1) begin hit[ii] = 0; bad[ii] = 0; used[ii] = 0; nm[ii] = ""; end

  task defn(input integer id, input [8*72-1:0] name);
    begin nm[id] = name; used[id] = 1; end
  endtask

  task chk(input integer id, input ante, input cons);
    begin
      if (ante === 1'b1) begin
        hit[id] = hit[id] + 1;
        if (cons !== 1'b1) begin
          bad[id] = bad[id] + 1;
          if (bad[id] <= 3) $display("ASSERT FAIL @%0t: %0s", $time, nm[id]);
        end
      end
    end
  endtask

  initial begin
    defn(0,  "AXI-01 ARVALID held until ARREADY (IHI0022H A3.2)");
    defn(1,  "AXI-02 AWVALID held until AWREADY (IHI0022H A3.2)");
    defn(2,  "AXI-03 WVALID held until WREADY (IHI0022H A3.2)");
    defn(3,  "AXI-04 AR payload stable while stalled (IHI0022H A3.2)");
    defn(4,  "AXI-05 AW payload stable while stalled (IHI0022H A3.2)");
    defn(5,  "AXI-06 W payload stable while stalled (IHI0022H A3.2)");
    defn(6,  "AXI-07 RVALID held until RREADY (IHI0022H A3.2)");
    defn(7,  "AXI-08 R payload stable while stalled (IHI0022H A3.2)");
    defn(8,  "AXI-09 BVALID held until BREADY (IHI0022H A3.2)");
    defn(9,  "AXI-10 B payload stable while stalled (IHI0022H A3.2)");
    defn(10, "AXI-11 RVALID and BVALID low in reset (IHI0022H A3.1.2)");
    defn(11, "AXI-12 master VALIDs low in reset (IHI0022H A3.1.2)");
    defn(12, "AXI-13 RRESP is OKAY or SLVERR only (IHI0022H A3.4.4, REQ-FUNC-011)");
    defn(13, "AXI-14 BRESP is OKAY or SLVERR only (IHI0022H A3.4.4, REQ-FUNC-011)");
    defn(14, "AXI-15 R beat only after AR accepted (IHI0022H A3.3)");
    defn(15, "AXI-16 B only after AW and last W accepted (IHI0022H A3.3, REQ-FUNC-016)");
    defn(16, "AXI-17 RLAST on the beat ARLEN+1 only (IHI0022H A3.4.1, REQ-FUNC-001)");
    defn(17, "AXI-18 RID of a new burst has an outstanding ARID (IHI0022H A5.2.1)");
    defn(18, "AXI-19 R beats of a burst consecutive, no interleave (REQ-FUNC-019)");
    defn(19, "AXI-20 BID has an outstanding AWID (IHI0022H A5.2)");
    defn(20, "AXI-21 R payload known while RVALID (IHI0022H A3.1.2)");
    defn(21, "AXI-22 B payload known while BVALID (IHI0022H A3.1.2)");
    defn(22, "AXI-23 READY outputs known after reset (IHI0022H A3.1.2)");
    defn(23, "AXI-24 RVALID and BVALID known after reset (IHI0022H A3.1.2)");
    defn(24, "AXI-25 INCR burst stays in its 4 KB page, AR (IHI0022H A3.4.1)");
    defn(25, "AXI-26 INCR burst stays in its 4 KB page, AW (IHI0022H A3.4.1)");
    defn(26, "AXI-27 WRAP length and alignment, AR and AW (IHI0022H A3.4.1)");
    defn(27, "AXI-28 AxSIZE not above the bus width (IHI0022H A3.4.1)");
    defn(28, "AXI-29 WLAST on the last W beat of AWLEN (IHI0022H A3.2, A5.2.2)");
    defn(29, "AXI-30 FIXED burst at most 16 beats (IHI0022H A3.4.1)");
    defn(30, "AXI-31 AxBURST not reserved 2'b11 (IHI0022H A3.4.1)");
    defn(31, "AXI-32 R data of OKAY known (IHI0022H A3.4.4)");
    defn(32, "TL-01 a_valid held until a_ready (REF-002 signals)");
    defn(33, "TL-02 a_opcode stable while stalled (REF-002)");
    defn(34, "TL-03 a_size stable while stalled (REF-002)");
    defn(35, "TL-04 a_source stable while stalled (REF-002)");
    defn(36, "TL-05 a_address stable while stalled (REF-002)");
    defn(37, "TL-06 a_mask stable while stalled (REF-002)");
    defn(38, "TL-07 a_data stable while stalled (REF-002)");
    defn(39, "TL-08 a_user stable while stalled (REF-002)");
    defn(40, "TL-09 a_opcode is Get, PutFullData or PutPartialData (REF-002 opcode)");
    defn(41, "TL-10 a_param is 0 (REF-002 signals)");
    defn(42, "TL-11 a_size not above the bus width (REF-002 features)");
    defn(43, "TL-12 a_address aligned to the size (REF-002 explicit errors 2)");
    defn(44, "TL-13 a_mask only inside the transfer region (REF-002 explicit errors 2)");
    defn(45, "TL-14 PutFullData mask covers the whole region (REF-002 explicit errors 2)");
    defn(46, "TL-15 Get mask not empty and inside the region (REF-002 opcode)");
    defn(47, "TL-16 a_source is direction bit and a slot index (REQ-FUNC-007)");
    defn(48, "TL-17 a_source unique among outstanding requests (REF-002 source, REQ-FUNC-007)");
    defn(49, "TL-18 instr_type is mubi4 True or False (REF-006 tl_a_user_t)");
    defn(50, "TL-19 integrity bits at default, reserved 0 (REF-006, DEC-009)");
    defn(51, "TL-20 Get a_data all ones (REF-006 BlankedAData, REQ-FUNC-006)");
    defn(52, "TL-21 d_ready 1 from the second cycle after reset (REQ-IF-006)");
    defn(53, "TL-22 d_ready never falls after rising (REQ-IF-006)");
    defn(54, "TL-23 a_valid low in reset (REQ-RESET-001)");
    defn(55, "TL-24 a_* known while a_valid (REF-002)");
    defn(56, "TL-25 a_valid and d_ready known after reset (REQ-RESET-001)");
    defn(57, "TL-26 d_opcode fits the request, device rule (REF-002 opcode)");
    defn(58, "TL-27 d_source answers an outstanding request, device rule (REF-002 source)");
    defn(60, "REL-01 Get request equals the expected read beat (REQ-FUNC-001, 003, 004, 008)");
    defn(61, "REL-02 Put request equals the expected write beat (REQ-FUNC-002, 003, 004, 005, 006)");
    defn(62, "REL-03 illegal burst gives no TL-UL request (REQ-ERR-003)");
    defn(63, "REL-04 R beats and B responses complete every legal burst (REQ-FUNC-001, 002)");
    defn(64, "REL-05 device error gives SLVERR on the beat or burst (REQ-ERR-001, 002)");
    defn(65, "REL-06 R and B in order for equal ID, RID and BID right (REQ-FUNC-009)");
    defn(66, "REL-07 o_evt_axi_err_rd and o_evt_axi_err_wr once per illegal burst or WLAST mismatch (REQ-ERR-003, 006)");
    defn(67, "REL-08 wrong opcode gives SLVERR and one bad pulse (REQ-ERR-004)");
    defn(68, "REL-09 orphaned response gives one orphan pulse and no AXI effect (REQ-ERR-005)");
    defn(69, "REL-10 request latency 1 cycle, response latency 1 cycle (REQ-PERF-001, 002)");
    defn(70, "REL-11 outstanding beats never above the slot tables (REQ-PARAM-003, PERF-004)");
    defn(71, "REL-12 one beat per cycle without bubble in a burst (REQ-PERF-003)");
    defn(74, "REL-15 arbitration order of simultaneous read and write requests (REQ-FUNC-013, 014)");
    defn(73, "REL-14 reset clears all work, outputs idle (REQ-RESET-001, 002)");
  end

  // ---------------- helper functions
  function [SB-1:0] region(input [AW-1:0] a, input [2:0] sz);
    integer nb, off, lo, i;
    begin
      nb = 1 << sz; off = a % SB; lo = (off / nb) * nb;
      region = '0;
      for (i = 0; i < SB; i = i + 1) if (i >= lo && i < lo + nb) region[i] = 1'b1;
    end
  endfunction
  function crosses4k(input [AW-1:0] a, input [7:0] len, input [2:0] sz);
    integer nb, al;
    begin
      nb = 1 << sz; al = (a / nb) * nb;
      crosses4k = (((al % 4096) + (len + 1) * nb) > 4096);
    end
  endfunction
  function wrap_bad(input [AW-1:0] a, input [7:0] len, input [2:0] sz);
    integer nb;
    begin
      nb = 1 << sz;
      wrap_bad = !(len == 1 || len == 3 || len == 7 || len == 15) || ((a % nb) != 0);
    end
  endfunction

  // ---------------- previous-cycle samples
  reg p_rst = 0, p_rst2 = 0;
  reg p_arvalid, p_arready, p_awvalid, p_awready, p_wvalid, p_wready, p_rvalid, p_rready, p_bvalid, p_bready;
  reg [IDW-1:0] p_arid, p_awid, p_rid, p_bid;
  reg [AW-1:0] p_araddr, p_awaddr;
  reg [7:0] p_arlen, p_awlen;
  reg [2:0] p_arsize, p_awsize, p_arprot, p_awprot;
  reg [1:0] p_arburst, p_awburst, p_rresp, p_bresp;
  reg [DW-1:0] p_wdata, p_rdata;
  reg [SB-1:0] p_wstrb;
  reg p_wlast, p_rlast;
  reg p_a_valid, p_a_ready;
  reg [2:0] p_a_opcode;
  reg [$bits(a_size)-1:0] p_a_size;
  reg [SRCW-1:0] p_a_src;
  reg [AW-1:0] p_a_addr;
  reg [SB-1:0] p_a_mask;
  reg [DW-1:0] p_a_data;
  reg [17:0] p_a_user;
  reg p_d_ready;

  // ---------------- trackers
  integer rlq [0:NID*64-1];
  integer rl_w [0:NID-1];
  integer rl_r [0:NID-1];
  integer b_out [0:NID-1];
  integer awlq [0:4095];
  integer aw_cnt = 0, wl_cnt = 0, b_cnt = 0, rbeats_acc = 0, rbeats_done = 0;
  integer wb = 0, wc = 0;
  reg r_act = 0;
  integer r_cur = 0, r_len = 0, r_cnt = 0;
  reg out_src [0:NSRC-1];
  reg src_is_get [0:NSRC-1];
  integer out_rd = 0, out_wr = 0;
  integer idn;
  initial for (idn = 0; idn < NID; idn = idn + 1) begin rl_w[idn] = 0; rl_r[idn] = 0; b_out[idn] = 0; end
  initial for (idn = 0; idn < NSRC; idn = idn + 1) begin out_src[idn] = 0; src_is_get[idn] = 0; end
  reg [SRCW-1:0] srcmask;

  task clear_trackers;
    begin
      for (idn = 0; idn < NID; idn = idn + 1) begin rl_w[idn] = 0; rl_r[idn] = 0; b_out[idn] = 0; end
      for (idn = 0; idn < NSRC; idn = idn + 1) begin out_src[idn] = 0; src_is_get[idn] = 0; end
      aw_cnt = 0; wl_cnt = 0; b_cnt = 0; rbeats_acc = 0; rbeats_done = 0; wb = 0; wc = 0; r_act = 0; out_rd = 0; out_wr = 0;
    end
  endtask

  always @(posedge clk) begin : sample
    integer nb, ai, sidx;
    reg [SB-1:0] rg;
    reg known_a;
    p_rst  <= rst_n;
    p_rst2 <= p_rst;
    // ------------------------------------------------ reset checks
    if (!rst_n) begin
      chk(10, 1'b1, (rvalid === 1'b0) && (bvalid === 1'b0));
      chk(11, 1'b1, (arvalid === 1'b0) && (awvalid === 1'b0) && (wvalid === 1'b0));
      chk(54, 1'b1, a_valid === 1'b0);
      clear_trackers;
    end
    // ------------------------------------------------ checks after the release
    if (rst_n && p_rst) begin
      // stability while stalled (previous cycle: valid and not ready)
      chk(0,  p_arvalid & ~p_arready, arvalid === 1'b1);
      chk(1,  p_awvalid & ~p_awready, awvalid === 1'b1);
      chk(2,  p_wvalid & ~p_wready, wvalid === 1'b1);
      chk(3,  p_arvalid & ~p_arready, (arid === p_arid) && (araddr === p_araddr) && (arlen === p_arlen) &&
                                      (arsize === p_arsize) && (arburst === p_arburst) && (arprot === p_arprot));
      chk(4,  p_awvalid & ~p_awready, (awid === p_awid) && (awaddr === p_awaddr) && (awlen === p_awlen) &&
                                      (awsize === p_awsize) && (awburst === p_awburst) && (awprot === p_awprot));
      chk(5,  p_wvalid & ~p_wready, (wdata === p_wdata) && (wstrb === p_wstrb) && (wlast === p_wlast));
      chk(6,  p_rvalid & ~p_rready, rvalid === 1'b1);
      chk(7,  p_rvalid & ~p_rready, (rid === p_rid) && (rdata === p_rdata) && (rresp === p_rresp) && (rlast === p_rlast));
      chk(8,  p_bvalid & ~p_bready, bvalid === 1'b1);
      chk(9,  p_bvalid & ~p_bready, (bid === p_bid) && (bresp === p_bresp));
      chk(32, p_a_valid & ~p_a_ready, a_valid === 1'b1);
      chk(33, p_a_valid & ~p_a_ready, a_opcode === p_a_opcode);
      chk(34, p_a_valid & ~p_a_ready, a_size === p_a_size);
      chk(35, p_a_valid & ~p_a_ready, a_src === p_a_src);
      chk(36, p_a_valid & ~p_a_ready, a_addr === p_a_addr);
      chk(37, p_a_valid & ~p_a_ready, a_mask === p_a_mask);
      chk(38, p_a_valid & ~p_a_ready, a_data === p_a_data);
      chk(39, p_a_valid & ~p_a_ready, a_user === p_a_user);
      // validity
      chk(20, rvalid, ^{rid, rresp, rlast} !== 1'bx);
      chk(31, rvalid & (rresp === 2'b00), ^rdata !== 1'bx);
      chk(21, bvalid, ^{bid, bresp} !== 1'bx);
      chk(22, 1'b1, ^{arready, awready, wready} !== 1'bx);
      chk(23, 1'b1, ^{rvalid, bvalid} !== 1'bx);
      chk(55, a_valid, ^{a_opcode, a_param, a_size, a_src, a_addr, a_mask, a_user} !== 1'bx);
      chk(56, 1'b1, ^{a_valid, d_ready} !== 1'bx);
      // response codes
      chk(12, rvalid, (rresp === 2'b00) || (rresp === 2'b10));
      chk(13, bvalid, (bresp === 2'b00) || (bresp === 2'b10));
      // AXI stimulus legality (the master side), masked for an intentional violation
      chk(24, arvalid & arready & ~mask_axi_illegal & (arburst == 2'd1), ~crosses4k(araddr, arlen, arsize));
      chk(25, awvalid & awready & ~mask_axi_illegal & (awburst == 2'd1), ~crosses4k(awaddr, awlen, awsize));
      chk(26, ((arvalid & arready & (arburst == 2'd2)) | (awvalid & awready & (awburst == 2'd2))) & ~mask_axi_illegal,
              ~((arvalid & arready & (arburst == 2'd2) & wrap_bad(araddr, arlen, arsize)) |
                (awvalid & awready & (awburst == 2'd2) & wrap_bad(awaddr, awlen, awsize))));
      chk(27, ((arvalid & arready) | (awvalid & awready)) & ~mask_axi_illegal,
              ~((arvalid & arready & ((1 << arsize) > SB)) | (awvalid & awready & ((1 << awsize) > SB))));
      chk(29, ((arvalid & arready & (arburst == 2'd0)) | (awvalid & awready & (awburst == 2'd0))) & ~mask_axi_illegal,
              ~((arvalid & arready & (arburst == 2'd0) & (arlen > 15)) | (awvalid & awready & (awburst == 2'd0) & (awlen > 15))));
      chk(30, ((arvalid & arready) | (awvalid & awready)) & ~mask_axi_illegal,
              ~((arvalid & arready & (arburst == 2'd3)) | (awvalid & awready & (awburst == 2'd3))));
      // counters of the accepted AXI beats
      if (arvalid && arready) begin
        rbeats_acc = rbeats_acc + arlen + 1;
        rlq[(arid % NID) * 64 + (rl_w[arid % NID] % 64)] = arlen;
        rl_w[arid % NID] = rl_w[arid % NID] + 1;
      end
      if (awvalid && awready) begin
        awlq[aw_cnt % 4096] = awlen;
        aw_cnt = aw_cnt + 1;
        b_out[awid % NID] = b_out[awid % NID] + 1;
      end
      if (wvalid && wready) begin
        chk(28, (wb < aw_cnt) & ~mask_wlast & ~mask_axi_illegal, wlast === (wc == awlq[wb % 4096]));
        if (wlast) begin wl_cnt = wl_cnt + 1; wb = wb + 1; wc = 0; end
        else wc = wc + 1;
      end
      // R channel: burst tracking
      if (rvalid && rready) begin
        rbeats_done = rbeats_done + 1;
        chk(14, 1'b1, rbeats_acc >= rbeats_done);
        if (!r_act) begin
          chk(17, 1'b1, rl_w[rid % NID] > rl_r[rid % NID]);
          if (rl_w[rid % NID] > rl_r[rid % NID]) begin
            r_len = rlq[(rid % NID) * 64 + (rl_r[rid % NID] % 64)];
            rl_r[rid % NID] = rl_r[rid % NID] + 1;
          end else r_len = 0;
          r_cur = rid; r_cnt = 0; r_act = 1;
        end else begin
          chk(18, 1'b1, rid == r_cur);
        end
        chk(16, 1'b1, rlast === (r_cnt == r_len));
        if (rlast || r_cnt == r_len) r_act = 0;
        else r_cnt = r_cnt + 1;
      end
      // B channel
      if (bvalid && bready) begin
        b_cnt = b_cnt + 1;
        chk(15, ~mask_wlast, (b_cnt <= aw_cnt) && (b_cnt <= wl_cnt));
        chk(19, 1'b1, b_out[bid % NID] > 0);
        if (b_out[bid % NID] > 0) b_out[bid % NID] = b_out[bid % NID] - 1;
      end
      // ---------------- TL-UL request channel
      if (a_valid === 1'b1) begin
        nb = 1 << a_size;
        rg = region(a_addr, a_size);
        chk(40, 1'b1, (a_opcode == 3'd0) || (a_opcode == 3'd1) || (a_opcode == 3'd4));
        chk(41, 1'b1, a_param === 3'd0);
        chk(42, 1'b1, nb <= SB);
        chk(43, 1'b1, (a_addr % nb) == 0);
        chk(44, 1'b1, (a_mask & ~rg) == 0);
        chk(45, a_opcode == 3'd0, a_mask === rg);
        chk(46, a_opcode == 3'd4, (a_mask != 0) && ((a_mask & ~rg) == 0));
        srcmask = '0;
        chk(47, 1'b1, (a_src[SLOTW] ? ((a_src[SLOTW-1:0]) < NWR) : ((a_src[SLOTW-1:0]) < NRD)) && ((a_src >> (SLOTW + 1)) == 0));
        chk(49, 1'b1, (a_user[17:14] == 4'h6) || (a_user[17:14] == 4'h9));
        chk(50, 1'b1, a_user[13:0] === 14'h3FFF);
        chk(51, a_opcode == 3'd4, a_data === {DW{1'b1}});
      end
      if (a_valid && a_ready) begin
        sidx = a_src % NSRC;
        chk(48, 1'b1, out_src[sidx] == 1'b0);
        out_src[sidx] = 1'b1;
        src_is_get[sidx] = (a_opcode == 3'd4);
        if (a_opcode == 3'd4) out_rd = out_rd + 1; else out_wr = out_wr + 1;
        chk(70, 1'b1, (out_rd <= NRD) && (out_wr <= NWR));
      end
      // ---------------- TL-UL response channel (device side rules, masked for injected faults)
      chk(52, p_rst, d_ready === 1'b1);
      chk(53, p_d_ready, d_ready === 1'b1);
      if (d_valid && d_ready) begin
        sidx = d_src % NSRC;
        chk(58, ~mask_tl_resp, out_src[sidx] == 1'b1);
        chk(57, ~mask_tl_resp & out_src[sidx], d_opcode == (src_is_get[sidx] ? 3'd1 : 3'd0));
        if (out_src[sidx]) begin
          if (src_is_get[sidx]) out_rd = out_rd - 1; else out_wr = out_wr - 1;
          out_src[sidx] = 1'b0;
        end
      end
    end
    // ------------------------------------------------ keep the samples
    p_arvalid <= arvalid; p_arready <= arready; p_awvalid <= awvalid; p_awready <= awready;
    p_wvalid <= wvalid; p_wready <= wready; p_rvalid <= rvalid; p_rready <= rready; p_bvalid <= bvalid; p_bready <= bready;
    p_arid <= arid; p_awid <= awid; p_rid <= rid; p_bid <= bid;
    p_araddr <= araddr; p_awaddr <= awaddr; p_arlen <= arlen; p_awlen <= awlen;
    p_arsize <= arsize; p_awsize <= awsize; p_arprot <= arprot; p_awprot <= awprot;
    p_arburst <= arburst; p_awburst <= awburst; p_rresp <= rresp; p_bresp <= bresp;
    p_wdata <= wdata; p_rdata <= rdata; p_wstrb <= wstrb; p_wlast <= wlast; p_rlast <= rlast;
    p_a_valid <= a_valid; p_a_ready <= a_ready; p_a_opcode <= a_opcode; p_a_size <= a_size; p_a_src <= a_src;
    p_a_addr <= a_addr; p_a_mask <= a_mask; p_a_data <= a_data; p_a_user <= a_user;
    p_d_ready <= d_ready & rst_n;
  end

  // ---------------- report
  task report(input show_never, output integer nfail, output integer nnever);
    integer i;
    begin
      nfail = 0; nnever = 0;
      $display("---- assertion table: name, hits, fails");
      for (i = 0; i < NA; i = i + 1) if (used[i]) begin
        $display("  %0s : hits=%0d fails=%0d", nm[i], hit[i], bad[i]);
        nfail = nfail + bad[i];
        if (hit[i] == 0 && show_never) nnever = nnever + 1;
      end
    end
  endtask
endmodule
