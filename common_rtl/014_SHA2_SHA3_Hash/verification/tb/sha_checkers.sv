// Protocol and interface checkers of the SHA2/SHA3 hash IP testbench (verification code, not RTL).
//
// Source of every check (R-023): VLSIT_SHA2_SHA3_HASH_HDS.md sections 6.3, 6.4, 7.3, 11.4, 12, 15.3,
// ARM IHI0024D (APB4) and ARM IHI0022 (AXI4); the clause is part of each assertion name.
// The assertions are clocked checks (the simulator has no concurrent assertions): the signals are
// sampled at the active edge before the flip-flops update. For each assertion the number of
// hits (antecedent true) and fails (consequent false) is counted; the run fails when a fail count is
// not 0 or when an enabled assertion has no hit (R-025).
//
// Classes (plusarg +CLASSES=<hex>, bit n enables class n): a run enables only the classes whose
// stimulus it makes; the regression runs enable every class at least once.
//   0 APB protocol   1 APB IP errors   2 AXI protocol   3 AXI IP errors   4 cross checks
//   10 masking (stage 2b)
//   5 DMA handshake  6 zeroing         7 reset   9 fault responses (stage 2a)  8 open finding (decision pending, off by default)
// Masking (stimulus that breaks a rule on purpose): input i_mask_apb_pstrb_rd masks APB-13 for the cycle
// in which the test drives a read with a non-zero strobe; i_mask_axi_stim masks the AXI stimulus-legality
// rules A33 to A36 for the cycle in which the test drives an illegal burst on purpose (error tests).
`timescale 1ns/1ps

module sha_checkers #(
  parameter integer DW   = 64,
  parameter integer CTXN = 4,
  parameter integer DMA  = 0
) (
  // Core clock domain
  input  wire                     i_clk,
  input  wire                     i_rst_n,
  // APB clock domain
  input  wire                     i_pclk,
  input  wire                     i_presetn,
  input  wire                     i_psel,
  input  wire                     i_penable,
  input  wire                     i_pwrite,
  input  wire [15:0]              i_paddr,
  input  wire [31:0]              i_pwdata,
  input  wire [3:0]               i_pstrb,
  input  wire [2:0]               i_pprot,
  input  wire                     i_pready,
  input  wire                     i_pslverr,
  input  wire [31:0]              i_prdata,
  input  wire                     i_protect_en,
  input  wire                     i_slverr_en,
  input  wire                     i_mask_apb_pstrb_rd,
  // AXI4
  input  wire                     i_awvalid,
  input  wire                     i_awready,
  input  wire [3:0]               i_awid,
  input  wire [15:0]              i_awaddr,
  input  wire [7:0]               i_awlen,
  input  wire [2:0]               i_awsize,
  input  wire [1:0]               i_awburst,
  input  wire                     i_wvalid,
  input  wire                     i_wready,
  input  wire [DW-1:0]            i_wdata,
  input  wire [DW/8-1:0]          i_wstrb,
  input  wire                     i_wlast,
  input  wire                     i_bvalid,
  input  wire                     i_bready,
  input  wire [3:0]               i_bid,
  input  wire [1:0]               i_bresp,
  input  wire                     i_arvalid,
  input  wire                     i_arready,
  input  wire [3:0]               i_arid,
  input  wire [15:0]              i_araddr,
  input  wire [7:0]               i_arlen,
  input  wire [2:0]               i_arsize,
  input  wire [1:0]               i_arburst,
  input  wire                     i_rvalid,
  input  wire                     i_rready,
  input  wire [3:0]               i_rid,
  input  wire [DW-1:0]            i_rdata,
  input  wire [1:0]               i_rresp,
  input  wire                     i_rlast,
  input  wire                     i_mask_axi_stim,
  // Internal observation points used only for the cross-interface and state checks of 15.3
  input  wire [CTXN*4-1:0]        i_ctx_cst,       // state of each context
  input  wire [CTXN-1:0]          i_ctx_abs,       // context is absorbing
  input  wire                     i_push_en,       // word pushed into the input FIFO
  input  wire [2:0]               i_core_starts,   // one bit per core start strobe
  input  wire                     i_irq,
  input  wire                     i_irq_sts_or,    // OR of the masked status register (sha_irq_sts)
  input  wire                     i_alarm,
  input  wire                     i_dma_in_req,
  input  wire                     i_dma_in_ack,
  input  wire                     i_dma_out_req,
  input  wire                     i_dma_out_ack,
  input  wire                     i_zero_en,       // PARA_ZERO and sha_sec.zero
  input  wire [CTXN-1:0]          i_ctx_mem_zero,  // context memory word of each context is zero
  input  wire                     i_core_zero,     // core registers of the built cores are zero
  input  wire                     i_core_idle,
  input  wire                     i_inflight,      // a block is queued, being assembled or being computed
  input  wire                     i_lock,
  input  wire                     i_gate,
  input  wire                     i_ev_flt,
  input  wire  [3:0]              i_sec_resp,
  input  wire                     i_srst_ack,
  // Masked core (stage 2b)
  input  wire                     i_mk_run,
  input  wire                     i_mk_s1nz,
  input  wire                     i_mk_plain_run,
  input  wire                     i_mk_s1z,
  input  wire                     i_rnd_chg,
  input  wire                     i_mk_start,
  input  wire                     i_seeded,
  input  wire                     i_ev_ent,
  input  wire                     i_ent_req
);

  localparam integer NA = 112;
  localparam integer WB = DW / 8;
  localparam integer LWB = $clog2(WB);

  integer hit [0:NA-1];
  integer bad [0:NA-1];
  bit     en  [0:NA-1];
  string  nm  [0:NA-1];
  integer cls_mask;
  integer nreg;

  function automatic void reg_a(input integer id, input integer cls, input string name);
    nm[id] = name;
    en[id] = ((cls_mask >> cls) & 1) != 0;
    if (id >= nreg) nreg = id + 1;
  endfunction

  task automatic chk(input integer id, input bit ante, input bit cons);
    if (en[id] && ante === 1'b1) begin
      hit[id] = hit[id] + 1;
      if (cons !== 1'b1) begin
        bad[id] = bad[id] + 1;
        $display("ASSERT FAIL @%0t: %0s [test %0s]", $time, nm[id], tb_sha_top.cur_tag);
      end
    end
  endtask

  initial begin
    cls_mask = 'hff;
    nreg = 0; wr_gate_l = 1'b0; rd_gate_l = 1'b0;
    if ($value$plusargs("CLASSES=%h", cls_mask)) ;
    for (int k = 0; k < NA; k++) begin hit[k] = 0; bad[k] = 0; en[k] = 0; nm[k] = ""; end
    // APB (IHI0024D)
    reg_a(0,  0, "APB-01 PENABLE only with PSEL (IHI0024D 3.1)");
    reg_a(1,  0, "APB-02 access phase follows the setup phase (3.1.1)");
    reg_a(2,  0, "APB-03 PSEL held until the access phase ends (3.1.1)");
    reg_a(3,  0, "APB-04 PADDR stable during the transfer (3.1.1)");
    reg_a(4,  0, "APB-05 PWRITE stable during the transfer (3.1.1)");
    reg_a(5,  0, "APB-06 PWDATA stable during a write transfer (3.1.1)");
    reg_a(6,  0, "APB-07 PSTRB stable during a write transfer (3.1.1)");
    reg_a(7,  0, "APB-08 PPROT stable during the transfer (3.1.1)");
    reg_a(8,  0, "APB-09 PENABLE low after the last access cycle (3.1.1)");
    reg_a(9,  0, "APB-10 PREADY known in the access phase (3.1)");
    reg_a(10, 0, "APB-11 PSLVERR and read PRDATA known at transfer end (3.1.3, 3.1.2)");
    reg_a(11, 0, "APB-12 PADDR PWRITE known while PSEL (3.1.1)");
    reg_a(12, 0, "APB-13 PSTRB low on a read transfer (3.2.3)");
    reg_a(13, 0, "APB-14 PPROT known while PSEL (3.2.2)");
    reg_a(14, 0, "APB-15 PWDATA and PSTRB known on a write (3.1.1, 3.2.3)");
    reg_a(15, 0, "APB-16 access phase ends within 400 cycles (progress, 6.3 REQ-IF-003)");
    reg_a(16, 7, "APB-17 APB outputs are 0 during reset (spec 7.3)");
    reg_a(17, 1, "IP-APB-01 partial PSTRB write gives PSLVERR with i_slverr_en (11.4)");
    reg_a(18, 1, "IP-APB-02 unaligned address gives PSLVERR with i_slverr_en (11.4)");
    reg_a(19, 1, "IP-APB-03 non-secure access gives PSLVERR with i_protect_en and i_slverr_en (11.4)");
    reg_a(20, 0, "IP-APB-04 legal aligned full-strobe secure access gives no PSLVERR (11.4)");
    reg_a(21, 1, "IP-APB-05 read of an aligned unmapped address returns 0 and OKAY (11.4)");
    reg_a(22, 1, "IP-APB-06 read of the write-only sha_seed returns 0 and OKAY (11.4)");
    reg_a(23, 0, "IP-APB-07 read of a read-only capability register returns the reset value (11.1)");
    // AXI4 (IHI0022)
    reg_a(24, 2, "AXI-01 AWVALID held until AWREADY (A3.2.1)");
    reg_a(25, 2, "AXI-02 AWADDR stable while AWVALID waits (A3.2.1)");
    reg_a(26, 2, "AXI-03 AWID stable while AWVALID waits (A3.2.1)");
    reg_a(27, 2, "AXI-04 AWLEN stable while AWVALID waits (A3.2.1)");
    reg_a(28, 2, "AXI-05 AWSIZE stable while AWVALID waits (A3.2.1)");
    reg_a(29, 2, "AXI-06 AWBURST stable while AWVALID waits (A3.2.1)");
    reg_a(30, 2, "AXI-07 WVALID held until WREADY (A3.2.1)");
    reg_a(31, 2, "AXI-08 WDATA stable while WVALID waits (A3.2.1)");
    reg_a(32, 2, "AXI-09 WSTRB stable while WVALID waits (A3.2.1)");
    reg_a(33, 2, "AXI-10 WLAST stable while WVALID waits (A3.2.1)");
    reg_a(34, 2, "AXI-11 ARVALID held until ARREADY (A3.2.1)");
    reg_a(35, 2, "AXI-12 ARADDR stable while ARVALID waits (A3.2.1)");
    reg_a(36, 2, "AXI-13 ARID stable while ARVALID waits (A3.2.1)");
    reg_a(37, 2, "AXI-14 ARLEN stable while ARVALID waits (A3.2.1)");
    reg_a(38, 2, "AXI-15 ARSIZE stable while ARVALID waits (A3.2.1)");
    reg_a(39, 2, "AXI-16 ARBURST stable while ARVALID waits (A3.2.1)");
    reg_a(40, 2, "AXI-17 BVALID held until BREADY (A3.2.1)");
    reg_a(41, 2, "AXI-18 BID stable while BVALID waits (A3.2.1)");
    reg_a(42, 2, "AXI-19 BRESP stable while BVALID waits (A3.2.1)");
    reg_a(43, 2, "AXI-20 RVALID held until RREADY (A3.2.1)");
    reg_a(44, 2, "AXI-21 RID stable while RVALID waits (A3.2.1)");
    reg_a(45, 2, "AXI-22 RDATA stable while RVALID waits (A3.2.1)");
    reg_a(46, 2, "AXI-23 RRESP stable while RVALID waits (A3.2.1)");
    reg_a(47, 2, "AXI-24 RLAST stable while RVALID waits (A3.2.1)");
    reg_a(48, 2, "AXI-25 WLAST on the last write beat only (A3.4.1)");
    reg_a(49, 2, "AXI-26 RLAST on the last read beat only (A3.4.1)");
    reg_a(50, 2, "AXI-27 BVALID only after the last write beat (A3.3.1)");
    reg_a(51, 2, "AXI-28 RVALID only after the read address (A3.3.1)");
    reg_a(52, 2, "AXI-29 BID equals the AWID of the burst (A5.3.1)");
    reg_a(53, 2, "AXI-30 RID equals the ARID of the burst (A5.3.1)");
    reg_a(54, 2, "AXI-31 no EXOKAY response, the profile has no exclusive access (6.3, A7.2)");
    reg_a(55, 2, "AXI-32 valid and ready signals known after reset (A3.1.2)");
    reg_a(56, 2, "AXI-33 AWBURST and ARBURST not reserved (A3.4.1) [stimulus rule]");
    reg_a(57, 2, "AXI-34 AWSIZE and ARSIZE not wider than the bus (A3.4.1) [stimulus rule]");
    reg_a(58, 2, "AXI-35 INCR burst does not cross a 4 KB boundary (A3.4.1) [stimulus rule]");
    reg_a(59, 7, "AXI-36 BVALID and RVALID low during reset (A3.1.2, spec 7.3)");
    reg_a(60, 2, "AXI-37 write response within 2000 cycles of WLAST (progress)");
    reg_a(61, 2, "AXI-38 read data within 3000 cycles of the first beat wait (progress)");
    reg_a(62, 3, "IP-AXI-01 one write burst at a time: AWREADY low while a burst is open (6.3)");
    reg_a(63, 3, "IP-AXI-02 one read burst at a time: ARREADY low while a burst is open (6.3)");
    reg_a(64, 3, "IP-AXI-03 write to the digest window gives SLVERR (6.3, REQ-IF-002)");
    reg_a(65, 3, "IP-AXI-04 WRAP write burst gives SLVERR (6.3, REQ-IF-002)");
    reg_a(66, 3, "IP-AXI-05 narrow write size gives SLVERR (6.3, REQ-IF-002)");
    reg_a(67, 3, "IP-AXI-06 partial WSTRB gives SLVERR (6.3, REQ-IF-002)");
    if (CTXN < 16)  // with 16 contexts every window number of the 4-bit field exists
      reg_a(68, 3, "IP-AXI-07 context number >= PARA_CTX_N gives SLVERR (6.3, REQ-IF-002)");
    reg_a(69, 3, "IP-AXI-08 legal write to an absorbing context gets OKAY (6.3, REQ-IF-001)");
    reg_a(70, 3, "IP-AXI-09 read of the message window gives SLVERR and data 0 (6.3)");
    reg_a(71, 3, "IP-AXI-10 WRAP or narrow read gives SLVERR (6.3)");
    reg_a(72, 3, "IP-AXI-11 legal digest read beat gets OKAY (6.3, REQ-IF-001)");
    reg_a(73, 3, "IP-AXI-12 write to a non-absorbing context gets SLVERR (6.3, ERR-001)");
    reg_a(74, 4, "X-AXI-APB-01 a legal write beat pushes exactly one word (6.3, REQ-IF-001)");
    reg_a(75, 4, "X-AXI-APB-02 a rejected write beat pushes no word (6.3, REQ-IF-002)");
    reg_a(76, 4, "SVA-002 every context is in a legal state (15.3)");
    reg_a(77, 4, "SVA-002b at most one core starts a block in a cycle (15.3)");
    reg_a(78, 4, "SVA-003 o_irq equals the OR of the masked events (6.4, 15.3)");
    reg_a(79, 4, "SVA-006 no X on o_irq and o_alarm after reset (15.3 X policy)");
    reg_a(80, 5, "SVA-004a DMA input request rises only while the acknowledge is low (6.3 IF-003)");
    reg_a(93, 5, "SVA-004g DMA input acknowledge answers a request: the acknowledge rises only while the request is high (6.3 IF-003)");
    reg_a(94, 5, "SVA-004h DMA output acknowledge answers a request (6.3 IF-003)");
    reg_a(81, 8, "STRICT-4PH-a DMA input request holds until the acknowledge, also against abort and final (6.3 IF-003) [strict reading, not required by DEC-031]");
    reg_a(82, 8, "STRICT-4PH-b DMA input request falls only after the acknowledge (6.3 IF-003) [strict reading, not required by DEC-031]");
    reg_a(83, 5, "SVA-004d DMA output request rises only while the acknowledge is low (6.3 IF-003)");
    reg_a(84, 8, "STRICT-4PH-c DMA output request holds until the acknowledge, also against abort and srst (6.3 IF-003) [strict reading, not required by DEC-031]");
    reg_a(85, 8, "STRICT-4PH-d DMA output request falls only after the acknowledge (6.3 IF-003) [strict reading, not required by DEC-031]");
    reg_a(86, 6, "SVA-005 state memory zero within 3 cycles after a context is freed, a block in flight or not (REQ-SEC-001, ASM-005, DEC-030)");
    reg_a(87, 6, "SVA-005b core registers zero within 3 cycles after the last context is freed with no block in flight (REQ-SEC-001)");
    reg_a(91, 6, "SVA-005c core registers zero within 3 cycles after the last context is freed, also when a block was running (REQ-SEC-001, ASM-005, DEC-030)");
    reg_a(88, 7, "RST-01 o_irq and o_alarm are 0 during reset (spec 7.3)");
    reg_a(89, 7, "RST-02 DMA requests are 0 during reset (spec 7.3)");
    reg_a(101, 10, "MASK-01 share 1 is not zero in any cycle of a masked block (REQ-SEC-003)");
    reg_a(102, 10, "MASK-02 the random bits change from cycle to cycle while a masked block runs (REQ-SEC-003, DEC-037)");
    reg_a(103, 10, "MASK-03 share 1 stays zero for a message without masking (PARA_MASK = 1 build, DEC-036)");
    reg_a(104, 10, "MASK-04 a masked block starts only when the random bit source is seeded (ERR-006)");
    reg_a(105, 10, "MASK-05 the entropy-starved event is raised only while the source is not seeded (6.4)");
    reg_a(106, 7, "RST-03 o_ent_req is 0 during reset (spec 7.3)");
    reg_a(95, 9, "FLT-01 a write burst accepted while the IP is locked gets SLVERR (DEC-034, ERR-005)");
    reg_a(96, 9, "FLT-02 a read burst accepted while locked or gated gets SLVERR and data 0 (DEC-034, REQ-SEC-002)");
    reg_a(97, 9, "FLT-03 the responses of sha_sec.resp are active one cycle after the fault event (OP-011)");
    reg_a(98, 9, "FLT-04 lock and gate stay until the soft reset command (REQ-SEC-002, 6.4)");
    reg_a(99, 9, "FLT-05 o_alarm rises only within 3 cycles after a fault event with resp bit 3 (6.4)");
  end

  // ------------------------------------------------------------------------------------------------
  // Register map of the specification (section 11.1): word addresses that exist
  function automatic bit f_mapped(input logic [15:0] a);
    case (a[15:2])
      14'h000, 14'h001, 14'h002, 14'h003, 14'h004, 14'h005, 14'h006, 14'h008,
      14'h018, 14'h019, 14'h01A, 14'h01B, 14'h01C, 14'h01D, 14'h01E,
      14'h030, 14'h031, 14'h032, 14'h033: f_mapped = 1'b1;
      default: f_mapped = 1'b0;
    endcase
  endfunction

  // ------------------------------------------------------------------------------------------------
  // APB checks, clock i_pclk
  logic        p_psel, p_pen, p_pwr, p_pready;
  logic [15:0] p_addr;
  logic [31:0] p_wdata;
  logic [3:0]  p_strb;
  logic [2:0]  p_prot;
  integer      p_wait;
  logic        p_end;

  always @(posedge i_pclk) begin
    if (i_presetn === 1'b1) begin
      p_end = i_psel && i_penable && i_pready;
      chk(0, i_penable, i_psel);
      chk(1, p_psel && !p_pen, i_psel && i_penable);
      chk(2, p_psel && p_pen && !p_pready, i_psel && i_penable);
      chk(3, i_psel && p_psel && !(p_pen && p_pready), i_paddr == p_addr);
      chk(4, i_psel && p_psel && !(p_pen && p_pready), i_pwrite == p_pwr);
      chk(5, i_psel && i_pwrite && p_psel && p_pwr && !(p_pen && p_pready), i_pwdata == p_wdata);
      chk(6, i_psel && i_pwrite && p_psel && p_pwr && !(p_pen && p_pready), i_pstrb == p_strb);
      chk(7, i_psel && p_psel && !(p_pen && p_pready), i_pprot == p_prot);
      chk(8, p_psel && p_pen && p_pready, !i_penable);
      chk(9, i_psel && i_penable, !$isunknown(i_pready));
      chk(10, p_end, !$isunknown(i_pslverr) && (i_pwrite || !$isunknown(i_prdata)));
      chk(11, i_psel, !$isunknown(i_paddr) && !$isunknown(i_pwrite));
      chk(12, i_psel && !i_pwrite && !i_mask_apb_pstrb_rd, i_pstrb == 4'h0);
      chk(13, i_psel, !$isunknown(i_pprot));
      chk(14, i_psel && i_pwrite, !$isunknown(i_pwdata) && !$isunknown(i_pstrb));
      if (i_psel && i_penable && !i_pready) p_wait = p_wait + 1; else p_wait = 0;
      chk(15, i_psel && i_penable && !i_pready, p_wait < 400);
      // IP behavior of the generated register block (11.4)
      chk(17, p_end && i_pwrite && (i_pstrb != 4'hF) && i_slverr_en && (i_paddr[1:0] == 2'b00)
              && !(i_protect_en && i_pprot[1]), i_pslverr);
      chk(18, p_end && (i_paddr[1:0] != 2'b00) && i_slverr_en, i_pslverr);
      chk(19, p_end && i_pprot[1] && i_protect_en && i_slverr_en, i_pslverr);
      chk(20, p_end && (i_paddr[1:0] == 2'b00) && (!i_pwrite || i_pstrb == 4'hF) && !(i_protect_en && i_pprot[1]),
              !i_pslverr);
      chk(21, p_end && !i_pwrite && (i_paddr[1:0] == 2'b00) && !f_mapped(i_paddr) && !(i_protect_en && i_pprot[1]),
              (i_prdata == 32'h0) && !i_pslverr);
      chk(22, p_end && !i_pwrite && (i_paddr == 16'h0020) && !(i_protect_en && i_pprot[1]),
              (i_prdata == 32'h0) && !i_pslverr);
      chk(23, p_end && !i_pwrite && (i_paddr == 16'h0000) && !(i_protect_en && i_pprot[1]),
              !$isunknown(i_prdata) && i_prdata[31:28] == 4'h1);
    end else begin
      p_wait = 0;
    end
    p_psel = i_psel; p_pen = i_penable; p_pwr = i_pwrite; p_addr = i_paddr; p_wdata = i_pwdata;
    p_strb = i_pstrb; p_prot = i_pprot; p_pready = i_pready;
  end

  // Outputs during reset (7.3): sampled while the reset is low
  always @(posedge i_pclk) begin
    if (i_presetn === 1'b0) begin
      chk(16, 1'b1, !i_pready && !i_pslverr && (i_prdata == 32'h0));
    end
  end

  // ------------------------------------------------------------------------------------------------
  // AXI4 checks, clock i_clk
  logic              a_awv, a_awr, a_wv, a_wr, a_arv, a_arr, a_bv, a_br, a_rv, a_rr;
  logic [3:0]        a_awid, a_arid, a_bid, a_rid;
  logic [15:0]       a_awaddr, a_araddr;
  logic [7:0]        a_awlen, a_arlen;
  logic [2:0]        a_awsize, a_arsize;
  logic [1:0]        a_awburst, a_arburst, a_bresp, a_rresp;
  logic [DW-1:0]     a_wdata, a_rdata;
  logic [DW/8-1:0]   a_wstrb;
  logic              a_wlast, a_rlast;
  // Burst trackers
  integer            wcnt, rcnt;          // beat counters
  logic [7:0]        awlen_l, arlen_l;    // latched lengths
  logic [3:0]        awid_l, arid_l;
  logic [15:0]       awaddr_l, araddr_l;
  logic [2:0]        awsize_l, arsize_l;
  logic [1:0]        awburst_l, arburst_l;
  logic              w_open;              // an accepted write address whose response is not done
  logic              w_data_done;         // last write beat accepted, response not yet given
  logic              r_open;
  logic              wstrb_bad;           // a beat of the open burst had a partial strobe
  logic              abs_l;               // the context of the open write burst was absorbing
  integer            w_resp_wait, r_wait;
  logic              wr_legal_hdr, rd_legal_hdr;
  logic              r_known;
  logic              wr_gate_l, rd_gate_l;   // the burst was accepted while the IP was locked or gated (stage 2a)
  logic [3:0]        ctx_w, ctx_r;
  logic              isdig_w, isdig_r;

  always @(posedge i_clk) begin
    if (i_rst_n === 1'b1) begin
      // stability: the previous cycle waited
      chk(24, a_awv && !a_awr, i_awvalid);
      chk(25, a_awv && !a_awr, i_awaddr == a_awaddr);
      chk(26, a_awv && !a_awr, i_awid == a_awid);
      chk(27, a_awv && !a_awr, i_awlen == a_awlen);
      chk(28, a_awv && !a_awr, i_awsize == a_awsize);
      chk(29, a_awv && !a_awr, i_awburst == a_awburst);
      chk(30, a_wv && !a_wr, i_wvalid);
      chk(31, a_wv && !a_wr, i_wdata == a_wdata);
      chk(32, a_wv && !a_wr, i_wstrb == a_wstrb);
      chk(33, a_wv && !a_wr, i_wlast == a_wlast);
      chk(34, a_arv && !a_arr, i_arvalid);
      chk(35, a_arv && !a_arr, i_araddr == a_araddr);
      chk(36, a_arv && !a_arr, i_arid == a_arid);
      chk(37, a_arv && !a_arr, i_arlen == a_arlen);
      chk(38, a_arv && !a_arr, i_arsize == a_arsize);
      chk(39, a_arv && !a_arr, i_arburst == a_arburst);
      chk(40, a_bv && !a_br, i_bvalid);
      chk(41, a_bv && !a_br, i_bid == a_bid);
      chk(42, a_bv && !a_br, i_bresp == a_bresp);
      chk(43, a_rv && !a_rr, i_rvalid);
      chk(44, a_rv && !a_rr, i_rid == a_rid);
      chk(45, a_rv && !a_rr, i_rdata == a_rdata);
      chk(46, a_rv && !a_rr, i_rresp == a_rresp);
      chk(47, a_rv && !a_rr, i_rlast == a_rlast);
      // address accepted: latch the burst
      if (i_awvalid && i_awready) begin
        awlen_l = i_awlen; awid_l = i_awid; awaddr_l = i_awaddr; awsize_l = i_awsize; awburst_l = i_awburst;
        w_open = 1'b1; wcnt = 0; wstrb_bad = 1'b0; w_data_done = 1'b0; wr_gate_l = i_lock;
        ctx_w = i_awaddr[15:12]; isdig_w = i_awaddr[11];
        abs_l = (ctx_w < CTXN) ? i_ctx_abs[ctx_w[3:0]] : 1'b0;
      end
      if (i_arvalid && i_arready) begin
        arlen_l = i_arlen; arid_l = i_arid; araddr_l = i_araddr; arsize_l = i_arsize; arburst_l = i_arburst;
        r_open = 1'b1; rcnt = 0; ctx_r = i_araddr[15:12]; isdig_r = i_araddr[11]; rd_gate_l = i_lock || i_gate;
      end
      wr_legal_hdr = w_open && (awburst_l != 2'b10) && (awsize_l == LWB[2:0]) && !isdig_w && (ctx_w < CTXN);
      rd_legal_hdr = r_open && (arburst_l != 2'b10) && (arsize_l == LWB[2:0]) && isdig_r && (ctx_r < CTXN);
      // write beat
      if (i_wvalid && i_wready) begin
        chk(48, w_open, i_wlast == (wcnt == awlen_l));
        chk(74, wr_legal_hdr && abs_l && (i_wstrb == {(DW/8){1'b1}}), i_push_en === 1'b1);
        chk(75, w_open && !(wr_legal_hdr && abs_l && (i_wstrb == {(DW/8){1'b1}})), i_push_en === 1'b0);
        if (i_wstrb != {(DW/8){1'b1}}) wstrb_bad = 1'b1;
        wcnt = wcnt + 1;
        if (i_wlast) w_data_done = 1'b1;
      end
      chk(50, i_bvalid, w_data_done);
      chk(51, i_rvalid, r_open);
      chk(52, i_bvalid, i_bid == awid_l);
      chk(53, i_rvalid, i_rid == arid_l);
      chk(54, i_bvalid || i_rvalid, (!i_bvalid || i_bresp != 2'b01) && (!i_rvalid || i_rresp != 2'b01));
      chk(55, 1'b1, !$isunknown({i_awvalid, i_awready, i_wvalid, i_wready, i_bvalid, i_bready,
                                 i_arvalid, i_arready, i_rvalid, i_rready}));
      chk(56, (i_awvalid || i_arvalid) && !i_mask_axi_stim,
          (!i_awvalid || i_awburst != 2'b11) && (!i_arvalid || i_arburst != 2'b11));
      chk(57, (i_awvalid || i_arvalid) && !i_mask_axi_stim,
          (!i_awvalid || i_awsize <= LWB[2:0]) && (!i_arvalid || i_arsize <= LWB[2:0]));
      chk(58, (i_awvalid && i_awburst == 2'b01) && !i_mask_axi_stim,
          ({1'b0, i_awaddr[11:0]} + ((17'(i_awlen) + 17'd1) << i_awsize)) <= 17'd4096);
      if (i_bvalid && i_bready) begin
        // response given: classify the burst (6.3)
        chk(64, isdig_w && (ctx_w < CTXN), i_bresp == 2'b10);
        chk(65, awburst_l == 2'b10 && !isdig_w && (ctx_w < CTXN), i_bresp == 2'b10);
        chk(66, awburst_l != 2'b10 && awsize_l < LWB[2:0] && !isdig_w && (ctx_w < CTXN), i_bresp == 2'b10);
        chk(67, wr_legal_hdr && wstrb_bad, i_bresp == 2'b10);
        chk(68, !(ctx_w < CTXN), i_bresp == 2'b10);
        chk(69, wr_legal_hdr && !wstrb_bad && abs_l && !wr_gate_l, i_bresp == 2'b00);
        chk(73, wr_legal_hdr && !wstrb_bad && !abs_l && !wr_gate_l, i_bresp == 2'b10);
        w_open = 1'b0; w_data_done = 1'b0;
      end
      if (i_rvalid && i_rready) begin
        chk(49, r_open, i_rlast == (rcnt == arlen_l));
        chk(70, !isdig_r && (ctx_r < CTXN), (i_rresp == 2'b10) && (i_rdata == '0));
        chk(71, isdig_r && (ctx_r < CTXN) && (arburst_l == 2'b10 || arsize_l < LWB[2:0]), i_rresp == 2'b10);
        chk(72, rd_legal_hdr && !rd_gate_l, i_rresp == 2'b00);
        rcnt = rcnt + 1;
        if (i_rlast) r_open = 1'b0;
      end
      // one outstanding burst per direction: the ready is low while a burst is open (checked the cycle
      // after the acceptance, before the response and the last read beat leave)
      chk(62, a_awv && a_awr && w_open, !i_awready);
      chk(63, a_arv && a_arr && r_open, !i_arready);
      // progress
      if (w_data_done && !i_bvalid) w_resp_wait = w_resp_wait + 1; else w_resp_wait = 0;
      chk(60, w_data_done && !i_bvalid, w_resp_wait < 2000);
      if (r_open && !i_rvalid) r_wait = r_wait + 1; else r_wait = 0;
      chk(61, r_open && !i_rvalid, r_wait < 3000);
    end else begin
      w_open = 1'b0; r_open = 1'b0; w_data_done = 1'b0; w_resp_wait = 0; r_wait = 0;
    end
    a_awv = i_awvalid; a_awr = i_awready; a_wv = i_wvalid; a_wr = i_wready; a_arv = i_arvalid; a_arr = i_arready;
    a_bv = i_bvalid; a_br = i_bready; a_rv = i_rvalid; a_rr = i_rready;
    a_awid = i_awid; a_arid = i_arid; a_bid = i_bid; a_rid = i_rid;
    a_awaddr = i_awaddr; a_araddr = i_araddr; a_awlen = i_awlen; a_arlen = i_arlen;
    a_awsize = i_awsize; a_arsize = i_arsize; a_awburst = i_awburst; a_arburst = i_arburst;
    a_bresp = i_bresp; a_rresp = i_rresp; a_wdata = i_wdata; a_rdata = i_rdata; a_wstrb = i_wstrb;
    a_wlast = i_wlast; a_rlast = i_rlast;
  end

  // Reset values of the AXI, event and DMA outputs (7.3)
  always @(posedge i_clk) begin
    if (i_rst_n === 1'b0) begin
      chk(59, 1'b1, !i_bvalid && !i_rvalid);
      chk(88, 1'b1, !i_irq && !i_alarm);
      chk(89, 1'b1, !i_dma_in_req && !i_dma_out_req);
      chk(106, 1'b1, !i_ent_req);
    end
  end

  // ------------------------------------------------------------------------------------------------
  // Cross checks, DMA handshake, zeroing (clock i_clk)
  logic          d_in_req, d_in_ack, d_out_req, d_out_ack, d_in_ack_seen, d_out_ack_seen;
  logic [CTXN-1:0] z_prev_free;
  integer        z_cnt [0:CTXN-1];
  integer        z_srst_win = 0;
  integer        zo_cnt [0:CTXN-1];
  integer        zc_cnt;
  logic          z_ctx_free;
  logic          legal_state;
  logic          z_prev_all, z_prev_cond;
  integer        zs_cnt;

  always @(posedge i_clk) begin
    if (i_rst_n === 1'b1) begin
      legal_state = 1'b1;
      for (int k = 0; k < CTXN; k++) begin
        if (i_ctx_cst[4*k +: 4] > 4'd4 && i_ctx_cst[4*k +: 4] != 4'hF) legal_state = 1'b0;
      end
      chk(76, 1'b1, legal_state);
      chk(77, 1'b1, ((i_core_starts[0] ? 1 : 0) + (i_core_starts[1] ? 1 : 0) + (i_core_starts[2] ? 1 : 0)) <= 1);
      chk(78, 1'b1, i_irq === i_irq_sts_or);
      chk(79, 1'b1, !$isunknown(i_irq) && !$isunknown(i_alarm));
      // DMA 4-phase order, input channel
      chk(80, i_dma_in_req && !d_in_req, !i_dma_in_ack);
      chk(93, i_dma_in_ack && !d_in_ack, i_dma_in_req);
      chk(94, i_dma_out_ack && !d_out_ack, i_dma_out_req);
      chk(81, d_in_req && !d_in_ack, i_dma_in_req);
      chk(82, !i_dma_in_req && d_in_req, d_in_ack);
      chk(83, i_dma_out_req && !d_out_req, !i_dma_out_ack);
      chk(84, d_out_req && !d_out_ack, i_dma_out_req);
      chk(85, !i_dma_out_req && d_out_req, d_out_ack);
      // zeroing: a context that became FREE must have a zero state memory word within 3 cycles
      if (z_srst_win > 0) z_srst_win = z_srst_win - 1;
      if (i_srst_ack) z_srst_win = CTXN + 6;
      for (int k = 0; k < CTXN; k++) begin
        if (z_cnt[k] > 0) z_cnt[k] = z_cnt[k] - 1;
        if (zo_cnt[k] > 0) zo_cnt[k] = zo_cnt[k] - 1;
        if (i_zero_en && !z_prev_free[k] && (i_ctx_cst[4*k +: 4] == 4'd0)) begin
          // the soft reset sweeps one context per cycle: context k is zero k cycles later (DEC-038)
          z_cnt[k] = 4 + ((z_srst_win > 0) ? k : 0);
        end
        if (z_cnt[k] == 1) chk(86, 1'b1, i_ctx_mem_zero[k]);
        z_prev_free[k] = (i_ctx_cst[4*k +: 4] == 4'd0);
      end
      z_ctx_free = (i_ctx_cst == '0);
      if (zc_cnt > 0) zc_cnt = zc_cnt - 1;
      if (i_zero_en && z_ctx_free && i_core_idle && !i_inflight && !z_prev_cond) zc_cnt = 4;
      if (zc_cnt == 1) chk(87, 1'b1, i_core_zero);
      if (zs_cnt > 0) zs_cnt = zs_cnt - 1;
      if (i_zero_en && z_ctx_free && !z_prev_all) zs_cnt = 4;
      if (zs_cnt == 1) chk(91, 1'b1, i_core_zero);
      z_prev_all = z_ctx_free;
      z_prev_cond = z_ctx_free && i_core_idle && !i_inflight;
    end else begin
      for (int k = 0; k < CTXN; k++) begin z_cnt[k] = 0; zo_cnt[k] = 0; z_prev_free[k] = 1'b1; end
      zc_cnt = 0; zs_cnt = 0; z_prev_all = 1'b1; z_prev_cond = 1'b1;
    end
    d_in_req = i_dma_in_req; d_in_ack = i_dma_in_ack; d_out_req = i_dma_out_req; d_out_ack = i_dma_out_ack;
  end


  // ------------------------------------------------------------------------------------------------
  // Fault responses (class 9), clock i_clk
  logic        f_awl, f_arl, f_ev_d, f_lock_d, f_gate_d, f_alarm_d, f_srst_d;
  logic [3:0]  f_resp_d;
  integer      f_alarm_win;
  always @(posedge i_clk) begin
    if (i_rst_n === 1'b1) begin
      if (i_awvalid && i_awready) f_awl = i_lock;
      if (i_arvalid && i_arready) f_arl = i_lock || i_gate;
      chk(95, i_bvalid && i_bready && f_awl, i_bresp == 2'b10);
      chk(96, i_rvalid && i_rready && f_arl, (i_rresp == 2'b10) && (i_rdata == '0));
      chk(97, f_ev_d, (!f_resp_d[1] || i_lock) && (!f_resp_d[0] || i_gate));
      chk(98, f_lock_d && !f_srst_d, i_lock);
      chk(98, f_gate_d && !f_srst_d, i_gate);
      if (i_ev_flt && f_resp_d[3]) f_alarm_win = 3; else if (f_alarm_win > 0) f_alarm_win = f_alarm_win - 1;
      chk(99, i_alarm && !f_alarm_d, f_alarm_win > 0);
    end else begin
      f_awl = 1'b0; f_arl = 1'b0; f_alarm_win = 0;
    end
    chk(101, i_mk_run, i_mk_s1nz);
    chk(102, i_mk_run, i_rnd_chg);
    chk(103, i_mk_plain_run, i_mk_s1z);
    chk(104, i_mk_start, i_seeded);
    chk(105, i_ev_ent, !i_seeded);
    f_ev_d = i_ev_flt; f_lock_d = i_lock; f_gate_d = i_gate; f_resp_d = i_sec_resp; f_alarm_d = i_alarm; f_srst_d = i_srst_ack;
  end

  // ------------------------------------------------------------------------------------------------
  // Result table. Returns 1 when every enabled assertion fired and none failed.
  function automatic integer report(input integer verbose);
    integer fails, never, tot;
    fails = 0; never = 0; tot = 0;
    for (int k = 0; k < nreg; k++) begin
      if (en[k]) begin
        tot = tot + 1;
        if (bad[k] != 0) fails = fails + 1;
        if (hit[k] == 0) never = never + 1;
        if (verbose != 0)
          $display("ASSERT %-3d hits=%-9d fails=%-4d %s%s", k, hit[k], bad[k], nm[k], (hit[k] == 0) ? "  NEVER-EXERCISED" : "");
      end
    end
    $display("ASSERT-TOTAL enabled=%0d", tot);
    $display("assertion failures: %0d, assertions never exercised: %0d", fails, never);
    report = fails + never;
  endfunction

endmodule
