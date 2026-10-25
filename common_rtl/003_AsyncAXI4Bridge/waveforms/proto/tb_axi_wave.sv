`timescale 1ns/1ps
// Waveform bench of the AXI bridge prototype. A behavioural AXI manager drives the subordinate-side port of the
// bridge and a behavioural AXI subordinate answers on the manager-side port. The traffic is read from the file
// <STIM>_ops.txt: one line per transaction "<cycle> <W|R> <id> <addr hex> <len>" (len = AxLEN, beats = len + 1;
// cycle counts subordinate-side clock cycles after the start). Every DT ns the bench prints one sample line "S ...".
// Parameters: see the list below. Ready patterns are 32-bit masks cycled every clock of the owning side.
module tb_axi_wave;
  parameter integer HS = 5;          // half period of the subordinate-side clock (ns)
  parameter integer HM = 5;          // half period of the manager-side clock (ns)
  parameter integer DT = 5;          // sampling slot (ns)
  parameter integer NSLOT = 120;
  parameter integer SKIP = 0;        // number of slots skipped before the first printed sample (after START)
  parameter integer PRE = 0;         // 1: print from time 0 (reset shown)
  parameter integer AXI3 = 0;
  parameter integer USERS = 0;       // 1: user signals of width 4 on all channels
  parameter integer AWD = 0;         // cycles after the operation time before AWVALID rises
  parameter integer WD = 0;          // cycles after the operation time before the first WVALID
  parameter integer WGAP = 0;        // idle cycles between W beats
  parameter integer RGAP = 0;        // idle cycles between R beats (manager side)
  parameter integer BDELAY = 2;      // manager-side cycles from the last W beat to BVALID
  parameter integer RDELAY = 2;      // manager-side cycles from the AR handshake to the first R beat
  parameter [31:0] AWR_MASK = 32'hFFFFFFFF;
  parameter [31:0] WR_MASK  = 32'hFFFFFFFF;
  parameter [31:0] ARR_MASK = 32'hFFFFFFFF;
  parameter [31:0] BR_MASK  = 32'hFFFFFFFF;
  parameter [31:0] RR_MASK  = 32'hFFFFFFFF;
  parameter integer BRESP = 0;
  parameter integer RRESP = 0;
  parameter integer AW_DEPTH = 4;
  parameter integer W_DEPTH = 16;
  parameter integer B_DEPTH = 4;
  parameter integer AR_DEPTH = 4;
  parameter integer R_DEPTH = 16;
  parameter integer RST_AT = 0;      // >0: hardware reset of both domains at this time (ns), 2 cycles long
  localparam integer UW = (USERS != 0 && AXI3 == 0) ? 4 : 0;
  localparam integer AW_ = 16;
  localparam integer DW_ = 16;
  localparam integer IW_ = 4;

  logic clk_s = 0, clk_m = 0, rst_n_s = 0, rst_n_m = 0;
  always #(HS) clk_s = ~clk_s;
  always #(HM) clk_m = ~clk_m;

  // subordinate-side bus (driven by the manager model)
  logic s_awvalid = 0; wire s_awready; logic [IW_-1:0] s_awid = 0; logic [AW_-1:0] s_awaddr = 0; logic [7:0] s_awlen = 0;
  logic [3:0] s_awuser = 0;
  logic s_wvalid = 0; wire s_wready; logic [IW_-1:0] s_wid = 0; logic [DW_-1:0] s_wdata = 0; logic s_wlast = 0; logic [3:0] s_wuser = 0;
  wire s_bvalid; logic s_bready = 0; wire [IW_-1:0] s_bid; wire [1:0] s_bresp; wire [3:0] s_buser;
  logic s_arvalid = 0; wire s_arready; logic [IW_-1:0] s_arid = 0; logic [AW_-1:0] s_araddr = 0; logic [7:0] s_arlen = 0;
  logic [3:0] s_aruser = 0;
  wire s_rvalid; logic s_rready = 0; wire [IW_-1:0] s_rid; wire [DW_-1:0] s_rdata; wire [1:0] s_rresp; wire s_rlast; wire [3:0] s_ruser;
  // manager-side bus (driven by the subordinate model)
  wire m_awvalid; logic m_awready = 0; wire [IW_-1:0] m_awid; wire [AW_-1:0] m_awaddr; wire [7:0] m_awlen; wire [3:0] m_awuser;
  wire [1:0] m_awlock; wire [3:0] m_awqos, m_awregion;
  wire m_wvalid; logic m_wready = 0; wire [IW_-1:0] m_wid; wire [DW_-1:0] m_wdata; wire m_wlast; wire [3:0] m_wuser;
  logic m_bvalid = 0; wire m_bready; logic [IW_-1:0] m_bid = 0; logic [1:0] m_bresp = 0; logic [3:0] m_buser = 0;
  wire m_arvalid; logic m_arready = 0; wire [IW_-1:0] m_arid; wire [AW_-1:0] m_araddr; wire [7:0] m_arlen; wire [3:0] m_aruser;
  logic m_rvalid = 0; wire m_rready; logic [IW_-1:0] m_rid = 0; logic [DW_-1:0] m_rdata = 0; logic [1:0] m_rresp = 0;
  logic m_rlast = 0; logic [3:0] m_ruser = 0;

  m_vlsit_axi_cdc_top #(.PARA_AXI_ADDR_W(AW_), .PARA_AXI_DATA_W(DW_), .PARA_AXI_ID_W(IW_), .PARA_AXI_AXI3_EN(AXI3),
    .PARA_AXI_QOS_EN(1), .PARA_AXI_REGION_EN(1), .PARA_AXI_AWUSER_W(UW), .PARA_AXI_WUSER_W(UW), .PARA_AXI_BUSER_W(UW),
    .PARA_AXI_ARUSER_W(UW), .PARA_AXI_RUSER_W(UW), .PARA_AXI_AW_DEPTH(AW_DEPTH), .PARA_AXI_W_DEPTH(W_DEPTH),
    .PARA_AXI_B_DEPTH(B_DEPTH), .PARA_AXI_AR_DEPTH(AR_DEPTH), .PARA_AXI_R_DEPTH(R_DEPTH), .PARA_AXI_CELL_TYPE(2)) dut (
    .i_clk_sub(clk_s), .i_rst_n_sub(rst_n_s), .i_clk_mgr(clk_m), .i_rst_n_mgr(rst_n_m),
    .i_axi_awvalid(s_awvalid), .o_axi_awready(s_awready), .i_axi_awid(s_awid), .i_axi_awaddr(s_awaddr),
    .i_axi_awlen(s_awlen), .i_axi_awsize(3'd1), .i_axi_awburst(2'b01), .i_axi_awlock(2'b01), .i_axi_awcache(4'h0),
    .i_axi_awprot(3'h0), .i_axi_awqos(4'h3), .i_axi_awregion(4'h1), .i_axi_awuser(s_awuser),
    .i_axi_wvalid(s_wvalid), .o_axi_wready(s_wready), .i_axi_wid(s_wid), .i_axi_wdata(s_wdata), .i_axi_wstrb(2'b11),
    .i_axi_wlast(s_wlast), .i_axi_wuser(s_wuser),
    .o_axi_bvalid(s_bvalid), .i_axi_bready(s_bready), .o_axi_bid(s_bid), .o_axi_bresp(s_bresp), .o_axi_buser(s_buser),
    .i_axi_arvalid(s_arvalid), .o_axi_arready(s_arready), .i_axi_arid(s_arid), .i_axi_araddr(s_araddr),
    .i_axi_arlen(s_arlen), .i_axi_arsize(3'd1), .i_axi_arburst(2'b01), .i_axi_arlock(2'b00), .i_axi_arcache(4'h0),
    .i_axi_arprot(3'h0), .i_axi_arqos(4'h0), .i_axi_arregion(4'h0), .i_axi_aruser(s_aruser),
    .o_axi_rvalid(s_rvalid), .i_axi_rready(s_rready), .o_axi_rid(s_rid), .o_axi_rdata(s_rdata), .o_axi_rresp(s_rresp),
    .o_axi_rlast(s_rlast), .o_axi_ruser(s_ruser),
    .o_axi_awvalid(m_awvalid), .i_axi_awready(m_awready), .o_axi_awid(m_awid), .o_axi_awaddr(m_awaddr),
    .o_axi_awlen(m_awlen), .o_axi_awsize(), .o_axi_awburst(), .o_axi_awlock(m_awlock), .o_axi_awcache(), .o_axi_awprot(),
    .o_axi_awqos(m_awqos), .o_axi_awregion(m_awregion), .o_axi_awuser(m_awuser),
    .o_axi_wvalid(m_wvalid), .i_axi_wready(m_wready), .o_axi_wid(m_wid), .o_axi_wdata(m_wdata), .o_axi_wstrb(),
    .o_axi_wlast(m_wlast), .o_axi_wuser(m_wuser),
    .i_axi_bvalid(m_bvalid), .o_axi_bready(m_bready), .i_axi_bid(m_bid), .i_axi_bresp(m_bresp), .i_axi_buser(m_buser),
    .o_axi_arvalid(m_arvalid), .i_axi_arready(m_arready), .o_axi_arid(m_arid), .o_axi_araddr(m_araddr),
    .o_axi_arlen(m_arlen), .o_axi_arsize(), .o_axi_arburst(), .o_axi_arlock(), .o_axi_arcache(), .o_axi_arprot(),
    .o_axi_arqos(), .o_axi_arregion(), .o_axi_aruser(m_aruser),
    .i_axi_rvalid(m_rvalid), .o_axi_rready(m_rready), .i_axi_rid(m_rid), .i_axi_rdata(m_rdata), .i_axi_rresp(m_rresp),
    .i_axi_rlast(m_rlast), .i_axi_ruser(m_ruser));

  // ---------------------------------------------------------------- operations
  reg [8*200-1:0] stim, fname;
  integer fo, rc, nops;
  integer op_t [0:15];
  integer op_w [0:15];
  integer op_id [0:15];
  integer op_addr [0:15];
  integer op_len [0:15];
  reg [8*4-1:0] op_s;
  integer nw, nr;
  integer wl [0:15];   // operation index of write number i
  integer rl [0:15];
  logic started = 0;
  integer cs = 0, cm = 0;
  integer aw_i = 0, w_i = 0, w_beat = 0, w_gap = 0, ar_i = 0;
  integer rr_hold = 0;

  initial begin
    if (!$value$plusargs("STIM=%s", stim)) stim = "none";
    $sformat(fname, "%0s_ops.txt", stim);
    fo = $fopen(fname, "r");
    nops = 0; nw = 0; nr = 0;
    while (fo != 0 && !$feof(fo) && nops < 16) begin
      rc = $fscanf(fo, "%d %s %d %h %d\n", op_t[nops], op_s, op_id[nops], op_addr[nops], op_len[nops]);
      if (rc == 5) begin
        if (op_s[7:0] == "W") begin op_w[nops] = 1; wl[nw] = nops; nw = nw + 1; end
        else begin op_w[nops] = 0; rl[nr] = nops; nr = nr + 1; end
        nops = nops + 1;
      end
    end
    #(6 * HS + 3);
    @(posedge clk_s); #1 rst_n_s = 1;
    @(posedge clk_m); #1 rst_n_m = 1;
    @(posedge clk_s); @(posedge clk_s);
    started = 1;
    $display("START %0.3f", $realtime);
  end

  // optional hardware reset in the middle of the run
  initial begin
    if (RST_AT > 0) begin
      #(RST_AT);
      rst_n_s = 0; rst_n_m = 0;
      #(4 * HS + 1);
      @(posedge clk_s); #1 rst_n_s = 1;
      @(posedge clk_m); #1 rst_n_m = 1;
    end
  end

  // ---------------------------------------------------------------- subordinate-side manager model
  integer k_op;
  always @(posedge clk_s) begin
    if (started && rst_n_s) cs = cs + 1;
    // handshakes sampled before the edge
    if (rst_n_s) begin
      if (s_awvalid && s_awready) aw_i = aw_i + 1;
      if (s_wvalid && s_wready) begin
        if (w_beat == op_len[wl[w_i]]) begin w_i = w_i + 1; w_beat = 0; end
        else w_beat = w_beat + 1;
        w_gap = WGAP;
      end else if (w_gap > 0 && !s_wvalid) w_gap = w_gap - 1;
      if (s_arvalid && s_arready) ar_i = ar_i + 1;
    end
    #1;
    if (!rst_n_s || !started) begin
      s_awvalid = 0; s_wvalid = 0; s_arvalid = 0; s_wlast = 0;
    end else begin
      // AW
      s_awvalid = 0;
      if (aw_i < nw) begin
        k_op = wl[aw_i];
        if (cs >= op_t[k_op] + AWD) begin
          s_awvalid = 1; s_awid = op_id[k_op]; s_awaddr = op_addr[k_op]; s_awlen = op_len[k_op];
          s_awuser = 4'(k_op + 1);
        end
      end
      // W
      s_wvalid = 0; s_wlast = 0;
      if (w_i < nw) begin
        k_op = wl[w_i];
        if (cs >= op_t[k_op] + WD && w_gap == 0) begin
          s_wvalid = 1; s_wid = op_id[k_op]; s_wdata = 16'hA000 | (k_op << 8) | (w_beat << 4) | w_beat;
          s_wlast = (w_beat == op_len[k_op]); s_wuser = 4'(w_beat);
        end
      end
      // AR
      s_arvalid = 0;
      if (ar_i < nr) begin
        k_op = rl[ar_i];
        if (cs >= op_t[k_op]) begin
          s_arvalid = 1; s_arid = op_id[k_op]; s_araddr = op_addr[k_op]; s_arlen = op_len[k_op];
          s_aruser = 4'(k_op + 1);
        end
      end
    end
    s_bready = BR_MASK[cs % 32];
    s_rready = RR_MASK[cs % 32];
  end

  // ---------------------------------------------------------------- manager-side subordinate model
  integer aw_cnt = 0, wl_cnt = 0, b_sent = 0, b_wait = 0;
  integer aw_idq [0:15];
  integer rq_id [0:15];
  integer rq_addr [0:15];
  integer rq_len [0:15];
  integer rq_n = 0, rq_done = 0, r_beat = 0, r_wait = 0, r_busy = 0, r_gap = 0;
  always @(posedge clk_m) begin
    if (started && rst_n_m) cm = cm + 1;
    if (rst_n_m) begin
      if (m_awvalid && m_awready) begin aw_idq[aw_cnt] = m_awid; aw_cnt = aw_cnt + 1; end
      if (m_wvalid && m_wready && m_wlast) wl_cnt = wl_cnt + 1;
      if (m_bvalid && m_bready) begin b_sent = b_sent + 1; b_wait = 0; end
      if (m_arvalid && m_arready) begin
        rq_id[rq_n] = m_arid; rq_addr[rq_n] = m_araddr; rq_len[rq_n] = m_arlen; rq_n = rq_n + 1;
        if (!r_busy) begin r_wait = RDELAY; end
      end
      if (m_rvalid && m_rready) begin
        if (r_beat == rq_len[rq_done]) begin rq_done = rq_done + 1; r_beat = 0; r_busy = 0; r_wait = RDELAY; end
        else begin r_beat = r_beat + 1; r_gap = RGAP; end
      end else if (r_gap > 0 && !m_rvalid) r_gap = r_gap - 1;
      if (!m_rvalid && rq_done < rq_n && r_wait > 0) r_wait = r_wait - 1;
      if (!m_bvalid && b_sent < wl_cnt && b_sent < aw_cnt) b_wait = b_wait + 1;
    end
    #1;
    m_awready = AWR_MASK[cm % 32];
    m_wready  = WR_MASK[cm % 32];
    m_arready = ARR_MASK[cm % 32];
    if (!rst_n_m || !started) begin
      m_bvalid = 0; m_rvalid = 0; m_rlast = 0;
    end else begin
      if (!m_bvalid || (m_bvalid && m_bready)) begin
        m_bvalid = 0;
        if (b_sent < wl_cnt && b_sent < aw_cnt && b_wait >= BDELAY) begin
          m_bvalid = 1; m_bid = aw_idq[b_sent]; m_bresp = BRESP; m_buser = 4'hB;
        end
      end
      if (rq_done < rq_n && r_wait == 0 && r_gap == 0) begin
        m_rvalid = 1; r_busy = 1; m_rid = rq_id[rq_done];
        m_rdata = 16'hC000 | (rq_done << 8) | (r_beat << 4) | r_beat; m_rresp = RRESP;
        m_rlast = (r_beat == rq_len[rq_done]); m_ruser = 4'(r_beat + 8);
      end else begin
        m_rvalid = 0; m_rlast = 0;
      end
    end
  end

  // ---------------------------------------------------------------- sampler
  integer k = 0, skipped = 0;
  initial begin
    #(DT / 2.0);
    forever begin
      if (PRE != 0 || started) begin
        if (PRE != 0 || skipped >= SKIP) begin
          `include "sample.svh"
          k = k + 1;
          if (k >= NSLOT) $finish;
        end else skipped = skipped + 1;
      end
      #(DT);
    end
  end
endmodule
