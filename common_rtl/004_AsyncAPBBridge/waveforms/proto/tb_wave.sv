`timescale 1ns/1ps
// Waveform and regression bench of the prototype bridge.
// Transfers are read from <STIM>_req.txt (one line per transfer: gap write addr strb wdata auser wuser, hex) and the
// completer answers from <STIM>_cmp.txt (one line per transfer: waits err rdata ruser buser, hex).
// The requester model obeys the APB state machine (IHI 0024D, Figure 4-1). Every DT ns it prints a sample line.
module tb_wave;
  parameter integer HM = 5;      // half period of the requester-side clock, ns
  parameter integer HS_ = 5;     // half period of the completer-side clock, ns
  parameter integer DT = 5;
  parameter integer NSLOT = 80;
  parameter integer HS = 0;
  parameter integer STAGES = 2;
  parameter integer APB5 = 0;
  parameter integer HRST_AT = 0;
  parameter integer HRST_CYC = 2;
  parameter integer NX = 16;
  parameter integer REGRESS = 0;   // 1: check every transfer against the tables and finish when all are done
  parameter integer SKIP = 0;    // print no sample before this slot offset from START
  parameter integer AW = 16;
  parameter integer DW = 16;

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

  m_vlsit_apbcdc_top #(.ADDR_W(AW), .DATA_W(DW), .APB5(APB5), .HS(HS), .STAGES(STAGES)) dut (
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

  // ---- stimulus tables
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
  integer rq_idx = 0;       // transfer in flight or next transfer of the requester model

  initial begin
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
    // resets are released synchronously, 1 ns after a rising edge of their own clock
    #(8 * HM + 3);
    @(posedge clk_mst); #0.2 rst_n_mst = 1;
    @(posedge clk_slv); #0.2 rst_n_slv = 1;
    @(posedge clk_mst); @(posedge clk_mst);
    started = 1;
    $display("START %0.3f", $realtime);
  end

  // ---- requester model (mst clock): idle gap, SETUP, ACCESS until PREADY, optional back-to-back
  integer rq_state = 0;     // 0 idle, 1 setup done (drive access), 2 access
  integer gap_cnt = 0;
  logic pr_s, pe_s;
  logic [DW-1:0] pd_s;
  logic [3:0] pu_s, pb_s;
  integer m_cnt = 0, s_cnt = 0, errs = 0;
  always @(posedge clk_mst) begin
    pr_s = m_pready; pe_s = m_pslverr; pd_s = m_prdata; pu_s = m_pruser; pb_s = m_pbuser;
    if (REGRESS != 0 && started && rst_n_mst && m_psel && m_penable && pr_s) begin
      // response check against the completer table (REQ-FUNC-001)
      if (pe_s !== c_err[m_cnt][0]) begin errs = errs + 1; $display("ERR resp pslverr %0d", m_cnt); end
      if (!t_wr[m_cnt] && pd_s !== c_rdata[m_cnt][DW-1:0]) begin errs = errs + 1; $display("ERR resp prdata %0d", m_cnt); end
      if (APB5 != 0 && !t_wr[m_cnt] && pu_s !== c_ru[m_cnt][3:0]) begin errs = errs + 1; $display("ERR resp pruser %0d", m_cnt); end
      if (APB5 != 0 && pb_s !== c_bu[m_cnt][3:0]) begin errs = errs + 1; $display("ERR resp pbuser %0d", m_cnt); end
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
              // SETUP phase
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
        1: begin m_penable = 1; rq_state = 2; end
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
    end
  end

  // ---- completer-side request check (REQ-FUNC-001, REQ-FUNC-006)
  always @(posedge clk_slv) begin
    if (REGRESS != 0 && rst_n_slv && s_psel && s_penable && s_pready) begin
      if (s_cnt >= nreq) begin errs = errs + 1; $display("ERR extra transfer"); end
      else begin
        if (s_paddr !== t_addr[s_cnt][AW-1:0] || s_pwrite !== t_wr[s_cnt][0] || s_pprot !== 3'b010) begin errs = errs + 1; $display("ERR req addr/write/prot %0d", s_cnt); end
        if (t_wr[s_cnt] && (s_pwdata !== t_wdata[s_cnt][DW-1:0] || s_pstrb !== t_strb[s_cnt][DW/8-1:0])) begin errs = errs + 1; $display("ERR req wdata/strb %0d", s_cnt); end
        if (APB5 != 0 && (s_pauser !== t_au[s_cnt][3:0] || (t_wr[s_cnt] && s_pwuser !== t_wu[s_cnt][3:0]))) begin errs = errs + 1; $display("ERR req user %0d", s_cnt); end
      end
      s_cnt = s_cnt + 1;
    end
    if (REGRESS != 0 && started && m_cnt == nreq && nreq > 0) begin
      #200;
      $display("RESULT errors=%0d requester_done=%0d completer_done=%0d nreq=%0d", errs + ((s_cnt != nreq) ? 1 : 0), m_cnt, s_cnt, nreq);
      $finish;
    end
  end

  // ---- completer model (slv clock): PREADY after the given number of wait states
  integer cwait = 0;
  always @(posedge clk_slv) begin
    if (!rst_n_slv) cwait = 0;
    else if (s_psel && s_penable) begin
      if (s_pready) cwait = 0;
      else cwait = cwait + 1;
    end
  end
  always_comb begin
    s_pready = 1'b0; s_pslverr = 1'b0; s_prdata = '0; s_pruser = '0; s_pbuser = '0;
    if (s_psel && s_penable && (cwait >= c_wait[rq_idx < NX ? rq_idx : 0])) begin
      s_pready = 1'b1;
      s_pslverr = c_err[rq_idx < NX ? rq_idx : 0];
      if (!s_pwrite) begin
        s_prdata = c_rdata[rq_idx < NX ? rq_idx : 0];
        s_pruser = (APB5 != 0) ? c_ru[rq_idx < NX ? rq_idx : 0] : 0;
      end
      s_pbuser = (APB5 != 0) ? c_bu[rq_idx < NX ? rq_idx : 0] : 0;
    end
  end

  // ---- optional hardware reset in the middle of the run: both resets fall at HRST_AT ns (asynchronously)
  // and are released synchronously after HRST_CYC cycles of their own clocks
  initial begin
    if (HRST_AT > 0) begin
      #(HRST_AT);
      rst_n_mst = 0; rst_n_slv = 0;
      #(2 * HRST_CYC * HM);
      @(posedge clk_mst); #0.2 rst_n_mst = 1;
      @(posedge clk_slv); #0.2 rst_n_slv = 1;
    end
  end

  // ---- sampler: the sample time is the middle of a slot, so a value that changes at a clock edge is the new one
  integer k = 0;
  initial begin
    #(DT / 2.0);
    forever if (REGRESS != 0) #(1000000); else begin
      $display("S %0.3f %b %b %b %b %b %b %b %b %h %h %h %b %b %h %b %b %b %b %b %b %h %b %h %h %0d %0d %b %b %b %h %h %h %h %h %h %h %h",
               $realtime, clk_mst, clk_slv, rst_n_mst, rst_n_slv,
               m_psel, m_penable, m_pwrite, m_pwakeup, m_paddr, m_pstrb, m_pwdata, m_pready, m_pslverr, m_prdata,
               s_psel, s_penable, s_pwrite, s_pwakeup, s_pready, s_pslverr, s_prdata, 1'b0, s_paddr, s_pwdata,
               dut.u_mst.reg_fsm_hs_current_state, dut.u_slv.reg_fsm_hs_current_state, dut.u_mst.reg_req,
               dut.u_slv.reg_ack, dut.u_mst.w_ack_s, m_pruser, m_pbuser, m_pauser, m_pwuser, s_pauser, s_pwuser,
               s_pruser, s_pbuser);
      k = k + 1;
      if (k >= NSLOT + 200) $finish;
      #(DT);
    end
  end
  initial if (REGRESS != 0) begin
    #20000000;
    $display("RESULT errors=999 requester_done=%0d completer_done=%0d nreq=%0d TIMEOUT", m_cnt, s_cnt, nreq);
    $finish;
  end
endmodule
