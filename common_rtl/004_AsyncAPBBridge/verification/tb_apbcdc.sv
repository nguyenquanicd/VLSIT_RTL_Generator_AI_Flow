`timescale 1ns/1ps
// Self-checking testbench of m_vlsit_apbcdc_top (asynchronous APB bridge).
// Source of every check: AsyncAPBBridge_Design_Specification.md (requirement IDs in the assertion names) and
// AMBA APB Issue D (IHI 0024D, clause numbers in the names). The RTL was read only for port names, widths and
// parameters and for the register names that the specification fixes (Section 14.1).
//
// Transfers are read from <STIM>_req.txt (one line per transfer: gap write addr strb wdata auser wuser, hex) and the
// completer answers from <STIM>_cmp.txt (one line per transfer: waits err rdata ruser buser, hex).
// Parameters (iverilog -P tb_apbcdc.<name>=<value>): HM and HS_ half periods in ns of the mst and slv clocks,
// HS handshake type, CELL cell option (synchronizer depth), APB5, NX table size, HRST_AT hardware reset time (0 = none),
// REGRESS 1 = run all transfers and finish, 0 = waveform mode (prints one sample line every DT ns and finishes after
// NSLOT slots). Plusargs: +STIM=<stem>, +VCD=<file>, +APBCDC_MSYNC_SEED=<n> (simulation branch).
// The run prints SIM-BRANCH, the assertion table and "assertion failures: 0, assertions never exercised: 0".
module tb_apbcdc;
  parameter integer HM = 5;
  parameter integer HS_ = 5;
  parameter integer DT = 5;
  parameter integer NSLOT = 80;
  parameter integer HS = 0;
  parameter integer CELL = 2;
  parameter integer APB5 = 0;
  parameter integer HRST_AT = 0;
  parameter integer HRST_CYC = 2;
  parameter integer NX = 16;
  parameter integer REGRESS = 1;
  parameter integer AW = 16;
  parameter integer DW = 16;
  parameter integer CORRUPT = 0;   // 1: the requester changes PADDR, PWDATA, PSTRB and the user fields during the Access phase
  parameter integer NOWK = 0;      // 1: APB5 requester that never drives PWAKEUP
  localparam integer NSTAGE = (CELL == 3) ? 3 : (CELL == 4) ? 4 : 2;
  localparam integer NA = 28;

  logic clk_mst = 0, clk_slv = 0, rst_n_mst = 0, rst_n_slv = 0;
  always #(HM) clk_mst = ~clk_mst;
  always #(HS_) clk_slv = ~clk_slv;

  logic m_psel = 0, m_penable = 0, m_pwrite = 0, m_pwakeup = 0;
  logic [AW-1:0] m_paddr = 0;
  logic [2:0] m_pprot = 0;
  logic [DW/8-1:0] m_pstrb = 0;
  logic [DW-1:0] m_pwdata = 0;
  logic [3:0] m_pauser = 0, m_pwuser = 0;
  wire m_pready, m_pslverr;
  wire [DW-1:0] m_prdata;
  wire [3:0] m_pruser, m_pbuser;

  wire s_psel, s_penable, s_pwrite, s_pwakeup;
  wire [AW-1:0] s_paddr;
  wire [2:0] s_pprot;
  wire [DW/8-1:0] s_pstrb;
  wire [DW-1:0] s_pwdata;
  wire [3:0] s_pauser, s_pwuser;
  logic s_pready;
  logic s_pslverr;
  logic [DW-1:0] s_prdata;
  logic [3:0] s_pruser, s_pbuser;

  m_vlsit_apbcdc_top #(.PARA_APBCDC_ADDR_W(AW), .PARA_APBCDC_DATA_W(DW), .PARA_APBCDC_APB5(APB5),
                       .PARA_APBCDC_USER_REQ_W(4), .PARA_APBCDC_USER_DATA_W(4), .PARA_APBCDC_USER_RESP_W(4),
                       .PARA_APBCDC_HS_TYPE(HS), .PARA_APBCDC_CELL_TYPE(CELL)) dut (
    .i_clk_mst(clk_mst), .i_rst_n_mst(rst_n_mst), .i_apb_psel(m_psel), .i_apb_penable(m_penable),
    .i_apb_pwrite(m_pwrite), .i_apb_paddr(m_paddr), .i_apb_pprot(m_pprot), .i_apb_pstrb(m_pstrb),
    .i_apb_pwdata(m_pwdata), .i_apb_pwakeup(m_pwakeup), .i_apb_pauser(m_pauser), .i_apb_pwuser(m_pwuser),
    .o_apb_pready(m_pready), .o_apb_prdata(m_prdata), .o_apb_pslverr(m_pslverr), .o_apb_pruser(m_pruser),
    .o_apb_pbuser(m_pbuser),
    .i_clk_slv(clk_slv), .i_rst_n_slv(rst_n_slv), .o_apb_psel(s_psel), .o_apb_penable(s_penable),
    .o_apb_pwrite(s_pwrite), .o_apb_paddr(s_paddr), .o_apb_pprot(s_pprot), .o_apb_pstrb(s_pstrb),
    .o_apb_pwdata(s_pwdata), .o_apb_pwakeup(s_pwakeup), .o_apb_pauser(s_pauser), .o_apb_pwuser(s_pwuser),
    .i_apb_pready(s_pready), .i_apb_prdata(s_prdata), .i_apb_pslverr(s_pslverr), .i_apb_pruser(s_pruser),
    .i_apb_pbuser(s_pbuser));

  // ------------------------------------------------------------------ assertion bookkeeping
  integer hit [0:NA-1];
  integer bad [0:NA-1];
  integer errors = 0;

  function automatic string aname(input integer id);
    case (id)
      0:  aname = "UP-PREADY-ONLY-IN-ACCESS   REQ-FUNC-004 (IHI0024D 3.1, 4.1)";
      1:  aname = "UP-PREADY-ONE-CYCLE        REQ-FUNC-004";
      2:  aname = "UP-PSLVERR-WITH-PREADY     REQ-FUNC-006 (IHI0024D 3.4)";
      3:  aname = "UP-RESPONSE-EQUALS-COMP    REQ-FUNC-002 (response of the completer returned)";
      4:  aname = "DN-PENABLE-NEEDS-PSEL      REQ-FUNC-008 (IHI0024D 4.1)";
      5:  aname = "DN-PENABLE-AFTER-SETUP     REQ-FUNC-008 (Setup one cycle, then Access)";
      6:  aname = "DN-FIELDS-STABLE-IN-WAIT   REQ-FUNC-008 (IHI0024D 3.1)";
      7:  aname = "DN-IDLE-LOW-IN-RESET       REQ-FUNC-008, REQ-RESET-001";
      8:  aname = "DN-REQUEST-EQUALS-SETUP    REQ-FUNC-001 (fields of the Setup cycle)";
      9:  aname = "ONE-TO-ONE                 REQ-FUNC-003 (one completer transfer per requester transfer)";
      10: aname = "NO-SECOND-SETUP-BEFORE-RESP REQ-FUNC-003, REQ-FUNC-007";
      11: aname = "PAYLOAD-STABLE             REQ-HS-002 (hold registers stable in flight)";
      12: aname = "HS2-TOGGLE-ONCE            REQ-HS-001 (request bit changes once per transfer)";
      13: aname = "HS4-SEQUENCE               REQ-HS-001, REQ-HS-004 (handshake closed before PREADY)";
      14: aname = "WAKEUP-NOT-AFTER-PSEL      REQ-APB5-001 (IHI0024D 3.6)";
      15: aname = "WAKEUP-HELD-UNTIL-READY    REQ-APB5-001 (IHI0024D 3.6)";
      16: aname = "RESET-VALUES-MST           REQ-RESET-001";
      17: aname = "RESET-VALUES-SLV           REQ-RESET-001";
      18: aname = "NO-X-UP                    REQ-IF-003 (IHI0024D Appendix A)";
      19: aname = "NO-X-DN                    REQ-IF-003 (IHI0024D Appendix A)";
      20: aname = "LATENCY-BOUND              REQ-PERF-001, REQ-PERF-002";
      21: aname = "UP-REQUESTER-LEGAL         ASM-001 (IHI0024D 3.1: fields stable in Access)";
      22: aname = "DN-PSEL-FALLS-AFTER-PREADY REQ-FUNC-008 (IHI0024D 4.1)";
      23: aname = "APB4-NO-APB5-OUTPUTS       REQ-APB5-003";
      24: aname = "UP-PRDATA-KNOWN-WITH-READY REQ-IF-003 (IHI0024D Appendix A)";
      25: aname = "DN-PWRITE-STABLE-STRB-READ REQ-FUNC-009 (fields forwarded unchanged)";
      26: aname = "UP-PREADY-HIGH-AFTER-SETUP REQ-FUNC-004 (never in the Setup cycle)";
      27: aname = "UP-PSLVERR-CLEARED         REQ-FUNC-006 (low outside the PREADY cycle)";
      default: aname = "unused";
    endcase
  endfunction

  function automatic logic applicable(input integer id);
    begin
      applicable = 1'b1;
      if ((id == 12 && HS != 0) || (id == 13 && HS == 0)) applicable = 1'b0;
      if ((id == 14 || id == 15) && APB5 == 0) applicable = 1'b0;
      if (id == 23 && APB5 != 0) applicable = 1'b0;
      if (id == 21 && CORRUPT != 0) applicable = 1'b0;
    end
  endfunction

  task automatic chk(input integer id, input logic ante, input logic cons);
    begin
      if (ante === 1'b1) begin
        hit[id] = hit[id] + 1;
        if (cons !== 1'b1) begin
          bad[id] = bad[id] + 1;
          errors = errors + 1;
          if (bad[id] <= 5) $display("ASSERT FAIL @%0t ps: %0s", $realtime, aname(id));
        end
      end
    end
  endtask

  // ------------------------------------------------------------------ stimulus tables
  reg [8*200-1:0] stim, fname;
  integer fq, fc, rc, i;
  integer t_gap [0:NX-1];
  integer t_wr [0:NX-1];
  integer t_addr [0:NX-1];
  integer t_strb [0:NX-1];
  integer t_wdata [0:NX-1];
  integer t_au [0:NX-1];
  integer t_wu [0:NX-1];
  integer c_wait [0:NX-1];
  integer c_err [0:NX-1];
  integer c_rdata [0:NX-1];
  integer c_ru [0:NX-1];
  integer c_bu [0:NX-1];
  integer nreq = 0;
  logic started = 0;
  logic hw_seen = 0;       // a hardware reset was applied after the start: count based checks are off
  integer rq_idx = 0;
  reg [8*220-1:0] vcdname;
  integer msync_seed;

  initial begin
`ifdef VLSIT_SYNTHESIS
    $display("SIM-BRANCH: synthesis");
`else
    msync_seed = 1;
    if ($value$plusargs("APBCDC_MSYNC_SEED=%d", msync_seed)) ;
    $display("SIM-BRANCH: metastable seed=%0d", msync_seed);
`endif
    if ($value$plusargs("VCD=%s", vcdname)) begin
      $dumpfile(vcdname);
      $dumpvars(0, tb_apbcdc);
    end
    for (i = 0; i < NA; i = i + 1) begin hit[i] = 0; bad[i] = 0; end
    for (i = 0; i < NX; i = i + 1) begin
      t_gap[i] = 0; t_wr[i] = 0; t_addr[i] = 0; t_strb[i] = 0; t_wdata[i] = 0; t_au[i] = 0; t_wu[i] = 0;
      c_wait[i] = 0; c_err[i] = 0; c_rdata[i] = 0; c_ru[i] = 0; c_bu[i] = 0;
    end
    if (!$value$plusargs("STIM=%s", stim)) stim = "none";
    $sformat(fname, "%0s_req.txt", stim); fq = $fopen(fname, "r");
    $sformat(fname, "%0s_cmp.txt", stim); fc = $fopen(fname, "r");
    while (fq != 0 && !$feof(fq) && nreq < NX) begin
      rc = $fscanf(fq, "%d %d %h %h %h %h %h\n", t_gap[nreq], t_wr[nreq], t_addr[nreq], t_strb[nreq], t_wdata[nreq],
                   t_au[nreq], t_wu[nreq]);
      if (rc == 7) nreq = nreq + 1;
    end
    i = 0;
    while (fc != 0 && !$feof(fc) && i < NX) begin
      rc = $fscanf(fc, "%d %d %h %h %h\n", c_wait[i], c_err[i], c_rdata[i], c_ru[i], c_bu[i]);
      if (rc == 5) i = i + 1;
    end
    // resets are released synchronously, 0.2 ns after a rising edge of their own clock
    #((REGRESS != 0) ? (20 * (HM + HS_) + 3) : (8 * HM + 3));
    @(posedge clk_mst); #0.2 rst_n_mst = 1;
    @(posedge clk_slv); #0.2 rst_n_slv = 1;
    @(posedge clk_mst); @(posedge clk_mst);
    started = 1;
    $display("START %0.3f", $realtime);
  end

  // ------------------------------------------------------------------ requester model (mst clock)
  integer rq_state = 0;
  integer gap_cnt = 0;
  logic pr_s, pe_s;
  logic [DW-1:0] pd_s;
  logic [3:0] pu_s, pb_s;
  integer m_cnt = 0, s_cnt = 0;
  always @(posedge clk_mst) begin
    pr_s = m_pready; pe_s = m_pslverr; pd_s = m_prdata; pu_s = m_pruser; pb_s = m_pbuser;
    if (started && rst_n_mst && m_psel && m_penable && pr_s && !hw_seen && m_cnt < nreq) begin
      // response of the requester side equals the answer of the completer table (REQ-FUNC-002)
      chk(3, 1'b1, pe_s === c_err[m_cnt][0] && (t_wr[m_cnt] != 0 || pd_s === c_rdata[m_cnt][DW-1:0]) &&
                   (APB5 == 0 || ((t_wr[m_cnt] != 0 || pu_s === c_ru[m_cnt][3:0]) && pb_s === c_bu[m_cnt][3:0])));
      m_cnt = m_cnt + 1;
    end
    #0.2;
    if (!rst_n_mst || !started) begin
      rq_state = 0; m_psel = 0; m_penable = 0; m_pwakeup = 0;
      gap_cnt = (rq_idx < nreq) ? t_gap[rq_idx] : 0;
      if (!rst_n_mst && started) gap_cnt = 3;
    end else begin
      case (rq_state)
        0: begin
          if (rq_idx < nreq) begin
            if (gap_cnt == 0) begin
              m_pwakeup = 1;
              m_psel = 1; m_penable = 0; m_pwrite = t_wr[rq_idx][0]; m_paddr = t_addr[rq_idx];
              m_pprot = 3'b010; m_pstrb = t_wr[rq_idx] ? t_strb[rq_idx] : 0;
              m_pwdata = t_wr[rq_idx] ? t_wdata[rq_idx] : 0;
              m_pauser = t_au[rq_idx]; m_pwuser = t_wr[rq_idx] ? t_wu[rq_idx] : 0;
              rq_state = 1;
            end else begin
              gap_cnt = gap_cnt - 1;
              m_pwakeup = (gap_cnt == 0);
            end
          end else m_pwakeup = 0;
        end
        1: begin
          m_penable = 1; rq_state = 2;
          // illegal on purpose (IHI0024D 3.1): the bridge shall still use the values of the Setup cycle (ERR-004)
          if (CORRUPT != 0) begin
            m_paddr = ~m_paddr; m_pwdata = ~m_pwdata; m_pstrb = ~m_pstrb; m_pauser = ~m_pauser; m_pwuser = ~m_pwuser;
          end
        end
        default: begin
          if (pr_s) begin
            rq_idx = rq_idx + 1;
            if (rq_idx < nreq && t_gap[rq_idx] == 0) begin
              m_penable = 0; m_pwrite = t_wr[rq_idx][0]; m_paddr = t_addr[rq_idx];
              m_pstrb = t_wr[rq_idx] ? t_strb[rq_idx] : 0; m_pwdata = t_wr[rq_idx] ? t_wdata[rq_idx] : 0;
              m_pauser = t_au[rq_idx]; m_pwuser = t_wr[rq_idx] ? t_wu[rq_idx] : 0;
              rq_state = 1;
            end else begin
              m_psel = 0; m_penable = 0; rq_state = 0;
              gap_cnt = (rq_idx < nreq) ? t_gap[rq_idx] : 0;
              m_pwakeup = 0;
            end
          end
        end
      endcase
      if (NOWK != 0) m_pwakeup = 0;
    end
  end

  // ------------------------------------------------------------------ completer model (slv clock)
  integer cwait = 0;
  integer ci;
  always @(posedge clk_slv) begin
    if (!rst_n_slv) cwait = 0;
    else if (s_psel && s_penable) begin
      if (s_pready) cwait = 0;
      else cwait = cwait + 1;
    end
  end
  always_comb begin
    ci = (rq_idx < NX) ? rq_idx : 0;
    s_pready = 1'b0; s_pslverr = 1'b0; s_prdata = '0; s_pruser = '0; s_pbuser = '0;
    if (s_psel && s_penable && (cwait >= c_wait[ci])) begin
      s_pready = 1'b1;
      s_pslverr = c_err[ci][0];
      if (!s_pwrite) begin
        s_prdata = c_rdata[ci];
        s_pruser = (APB5 != 0) ? c_ru[ci] : 0;
      end
      s_pbuser = (APB5 != 0) ? c_bu[ci] : 0;
    end
  end

  // ------------------------------------------------------------------ optional hardware reset at HRST_AT ns
  initial begin
    if (HRST_AT > 0) begin
      #(HRST_AT);
      hw_seen = 1;
      rst_n_mst = 0; rst_n_slv = 0;
      #(2 * HRST_CYC * HM);
      @(posedge clk_mst); #0.2 rst_n_mst = 1;
      @(posedge clk_slv); #0.2 rst_n_slv = 1;
    end
  end

  // ------------------------------------------------------------------ assertions, requester-side clock
  localparam realtime TM = 2.0 * HM;
  localparam realtime TS = 2.0 * HS_;
  logic p_psel = 0, p_penable = 0, p_pready = 0, p_pslverr = 0, p_wk = 0;
  logic [AW-1:0] p_paddr = 0;
  logic [DW-1:0] p_pwdata = 0;
  logic [DW/8-1:0] p_pstrb = 0;
  logic p_pwrite = 0;
  logic [2:0] p_pprot = 0;
  logic [3:0] p_pauser = 0, p_pwuser = 0;
  logic [1:0] p_mst_state = 0;
  logic p_req = 0, p_ack_s = 0;
  logic [63:0] p_payload = 0;
  logic [63:0] w_payload = 0;
  realtime t_setup_end = 0;
  integer cur_wait = 0;
  logic in_xfer = 0;
  integer up_done = 0;
  integer dn_setups = 0;
  logic p_up_ready_seen = 0;
  real bound, extra;

  always @(posedge clk_mst) begin
    // reset values while the mst reset is asserted (asynchronous, sampled at the edge, after two clock periods)
    if ($realtime > 3 * (TM + TS))
      chk(16, !rst_n_mst, m_pready === 1'b0 && m_pslverr === 1'b0 && dut.u_vlsit_apbcdc_mst.reg_req === 1'b0 &&
                          dut.u_vlsit_apbcdc_mst.reg_fsm_hs_current_state === 2'b00);
    if (started) begin
      if (rst_n_mst) begin
        chk(0, m_pready, m_psel && m_penable);
        chk(1, p_pready, !m_pready);
        chk(2, m_pslverr, m_pready);
        chk(27, !m_pready, !m_pslverr);
        chk(26, m_psel && !m_penable, !m_pready);
        chk(18, 1'b1, !$isunknown({m_pready, m_pslverr}));
        chk(24, m_pready && !m_pwrite && m_psel, !$isunknown(m_prdata));
        // legality of the requester model (REF-001 3.1): fields stable from Setup through Access
        chk(21, CORRUPT == 0 && p_psel && m_psel && !p_pready, m_paddr === p_paddr && m_pwrite === p_pwrite && m_pprot === p_pprot &&
                                              m_pstrb === p_pstrb && (!m_pwrite || m_pwdata === p_pwdata));
        // payload hold register stable while the handshake is in flight (REQ-HS-002)
        w_payload = dut.u_vlsit_apbcdc_mst.reg_req_payload;
        chk(11, dut.u_vlsit_apbcdc_mst.reg_fsm_hs_current_state !== 2'b00 && p_mst_state !== 2'b00, w_payload === p_payload);
        // two-phase: the request bit changes only at the launch edge, once per transfer (REQ-HS-001)
        chk(12, HS == 0 && p_mst_state !== 2'b00, dut.u_vlsit_apbcdc_mst.reg_req === p_req);
        // four-phase: when PREADY rises the request and the acknowledge are both 0 (REQ-HS-004)
        chk(13, HS != 0 && m_pready && !p_pready, dut.u_vlsit_apbcdc_mst.reg_req === 1'b0 && dut.u_vlsit_apbcdc_slv.reg_ack === 1'b0);
        // latency of the transfer (REQ-PERF-001, REQ-PERF-002)
        if (m_psel && !m_penable && dut.u_vlsit_apbcdc_mst.reg_fsm_hs_current_state === 2'b00 && !in_xfer) begin
          t_setup_end = $realtime; in_xfer = 1;
          cur_wait = (rq_idx < NX) ? c_wait[rq_idx] : 0;
        end
        if (in_xfer && m_pready && m_psel && m_penable && !hw_seen) begin
          if (HS == 0) bound = (NSTAGE + 3) * TM + (NSTAGE + 3 + cur_wait) * TS;
          else bound = (2 * NSTAGE + 4) * TM + (2 * NSTAGE + 4 + cur_wait) * TS;
`ifndef VLSIT_SYNTHESIS
          // metastability model: up to two extra destination cycles per control-bit change
          extra = (HS == 0) ? (2 * TM + 2 * TS) : (4 * TM + 4 * TS);
          bound = bound + extra;
`endif
          chk(20, 1'b1, ($realtime - t_setup_end + TM) <= bound + 0.001);
          in_xfer = 0; up_done = up_done + 1;
        end
        if (hw_seen) in_xfer = 0;
      end
      p_psel = m_psel; p_penable = m_penable; p_pready = m_pready; p_pslverr = m_pslverr;
      p_paddr = m_paddr; p_pwdata = m_pwdata; p_pstrb = m_pstrb; p_pwrite = m_pwrite; p_pprot = m_pprot;
      p_mst_state = dut.u_vlsit_apbcdc_mst.reg_fsm_hs_current_state; p_req = dut.u_vlsit_apbcdc_mst.reg_req;
      p_payload = dut.u_vlsit_apbcdc_mst.reg_req_payload;
    end
  end

  // ------------------------------------------------------------------ assertions, completer-side clock
  logic q_psel = 0, q_penable = 0, q_pready = 0, q_wk = 0;
  logic [AW-1:0] q_paddr = 0;
  logic [DW-1:0] q_pwdata = 0;
  logic [DW/8-1:0] q_pstrb = 0;
  logic q_pwrite = 0;
  logic [2:0] q_pprot = 0;
  logic [3:0] q_pauser = 0, q_pwuser = 0;
  logic [AW-1:0] su_paddr;

  always @(posedge clk_slv) begin
    if ($realtime > 3 * (TM + TS)) begin
      chk(17, !rst_n_slv, s_psel === 1'b0 && s_penable === 1'b0 && s_pwakeup === 1'b0 &&
                          dut.u_vlsit_apbcdc_slv.reg_ack === 1'b0 && dut.u_vlsit_apbcdc_slv.reg_fsm_hs_current_state === 2'b00);
      chk(7, !rst_n_slv, s_psel === 1'b0 && s_penable === 1'b0);
    end
    if (started) begin
      if (rst_n_slv) begin
        chk(4, s_penable, s_psel);
        chk(5, s_psel && !q_psel, !s_penable);
        chk(5, q_psel && !q_penable && s_psel, s_penable);
        chk(6, q_psel && s_psel && !(q_penable && q_pready),
            s_paddr === q_paddr && s_pwrite === q_pwrite && s_pprot === q_pprot && s_pstrb === q_pstrb &&
            (!s_pwrite || s_pwdata === q_pwdata) && (APB5 == 0 || s_pauser === q_pauser));
        chk(22, q_psel && q_penable && q_pready, !s_psel && !s_penable);
        chk(19, 1'b1, !$isunknown({s_psel, s_penable, s_pwakeup}));
        chk(23, 1'b1, (APB5 != 0) || (s_pwakeup === 1'b0 && s_pauser === 4'b0 && s_pwuser === 4'b0));
        // wake-up no later than PSEL and held until PREADY (REF-001 3.6)
        chk(14, APB5 != 0 && s_psel && !q_psel, s_pwakeup);
        chk(15, APB5 != 0 && q_wk && q_psel && !q_pready, s_pwakeup);
        // downstream Setup phase against the requester side (REQ-FUNC-001, REQ-FUNC-003)
        if (s_psel && !s_penable && !q_psel && !hw_seen && s_cnt < nreq) begin
          dn_setups = dn_setups + 1;
          chk(10, 1'b1, dn_setups == up_done + 1);
        end
        if (s_psel && s_penable && s_pready && !hw_seen) begin
          if (s_cnt >= nreq) begin
            chk(9, 1'b1, 1'b0);
          end else begin
            chk(8, 1'b1, s_paddr === t_addr[s_cnt][AW-1:0] && s_pwrite === t_wr[s_cnt][0] && s_pprot === 3'b010 &&
                         (t_wr[s_cnt] == 0 || (s_pwdata === t_wdata[s_cnt][DW-1:0] && s_pstrb === t_strb[s_cnt][DW/8-1:0])) &&
                         (APB5 == 0 || (s_pauser === t_au[s_cnt][3:0] && (t_wr[s_cnt] == 0 || s_pwuser === t_wu[s_cnt][3:0]))));
            chk(25, t_wr[s_cnt] == 0, s_pstrb === t_strb[s_cnt][DW/8-1:0]);
            s_cnt = s_cnt + 1;
          end
        end
      end
      q_psel = s_psel; q_penable = s_penable; q_pready = s_pready; q_wk = s_pwakeup;
      q_paddr = s_paddr; q_pwdata = s_pwdata; q_pstrb = s_pstrb; q_pwrite = s_pwrite; q_pprot = s_pprot;
      q_pauser = s_pauser; q_pwuser = s_pwuser;
    end
  end

  // ------------------------------------------------------------------ end of the run
  integer total_bad, never, k = 0;
  task automatic report_and_finish;
    begin
      // one completer transfer per requester transfer (REQ-FUNC-003)
      if (!hw_seen) chk(9, 1'b1, s_cnt == m_cnt && m_cnt == nreq);
      total_bad = 0; never = 0;
      $display("---- assertion table (name, hits, failures) HS=%0d CELL=%0d APB5=%0d HM=%0d HS_=%0d ----", HS, CELL, APB5, HM, HS_);
      for (i = 0; i < NA; i = i + 1) begin
        if (aname(i) != "unused" && applicable(i)) begin
          // the reset assertions and the counted checks of a run with a hardware reset are exercised by the reset itself
          $display("  [%2d] %-90s hits=%0d fails=%0d", i, aname(i), hit[i], bad[i]);
          total_bad = total_bad + bad[i];
          if (hit[i] == 0) never = never + 1;
        end
      end
      if (REGRESS == 0) never = 0;   // a waveform scenario shows one function; coverage is judged on the regression runs
      $display("assertion failures: %0d, assertions never exercised: %0d", total_bad, never);
      if (total_bad != 0 || never != 0 || errors != 0) begin
        $display("RESULT FAIL");
        $fatal(1, "testbench failed");
      end else $display("RESULT PASS");
      $finish;
    end
  endtask

  // regression mode: finish when every transfer was answered and the completer side is quiet
  always @(posedge clk_slv) begin
    if (REGRESS != 0 && started && m_cnt == nreq && nreq > 0 && !hw_seen) begin
      #(40 * HS_ + 40 * HM);
      report_and_finish;
    end
  end

  // waveform mode: a sample line every DT ns, finish after NSLOT slots
  initial begin
    #(DT / 2.0);
    forever if (REGRESS != 0) #(1000000); else begin
      $display("S %0.3f %b %b %b %b %b %b %b %b %h %h %h %b %b %h %b %b %b %b %b %b %h %b %h %h %0d %0d %b %b %b %h %h %h %h %h %h %h %h",
               $realtime, clk_mst, clk_slv, rst_n_mst, rst_n_slv,
               m_psel, m_penable, m_pwrite, m_pwakeup, m_paddr, m_pstrb, m_pwdata, m_pready, m_pslverr, m_prdata,
               s_psel, s_penable, s_pwrite, s_pwakeup, s_pready, s_pslverr, s_prdata, 1'b0, s_paddr, s_pwdata,
               dut.u_vlsit_apbcdc_mst.reg_fsm_hs_current_state, dut.u_vlsit_apbcdc_slv.reg_fsm_hs_current_state,
               dut.u_vlsit_apbcdc_mst.reg_req, dut.u_vlsit_apbcdc_slv.reg_ack, dut.u_vlsit_apbcdc_mst.w_ack_s,
               m_pruser, m_pbuser, m_pauser, m_pwuser, s_pauser, s_pwuser, s_pruser, s_pbuser);
      k = k + 1;
      if (k >= NSLOT + 40) report_and_finish;
      #(DT);
    end
  end

  // watchdog
  initial begin
    #50_000_000;
    $display("RESULT FAIL (timeout) m_cnt=%0d s_cnt=%0d nreq=%0d", m_cnt, s_cnt, nreq);
    $fatal(1, "timeout");
  end
endmodule
