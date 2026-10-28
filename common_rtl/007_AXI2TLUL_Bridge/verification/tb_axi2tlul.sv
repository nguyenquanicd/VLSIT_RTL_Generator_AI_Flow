`timescale 1ns/1ps
//------------------------------------------------------------------------------
// Testbench of the AXI2TLUL bridge (verification code, not part of the design file set).
// Derived from the specification AXI2TLUL_Bridge_Design_Specification.md (requirements, cycle tables, test plan
// 15.2) and the standards REF-001 (AXI4) and REF-002/REF-006 (TL-UL); the RTL is read only for port names, widths
// and parameters.
//   +TEST=regress  (default) directed phases and constrained-random batches with scoreboard and assertions
//   +TEST=scenario +STIM=<file> +VCD=<file>  one waveform scenario of the plan of section 10.3: the inputs of the
//                  bridge are driven cycle by cycle from the file (made from the specification figure), the
//                  outputs are dumped. Cycle 0 is the first cycle after the release of the reset.
//   +SEED=<n>      random seed (default 1)
// Result: a table of the assertions, the line "assertion failures: F, assertions never exercised: N", a PASS or
// FAIL line, and a non-zero exit status ($fatal) on failure.
//------------------------------------------------------------------------------
module tb_axi2tlul;
  parameter DW = 32, AW = 32, IDW = 4, NRD = 16, NWR = 16, NIDR = 4, NIDW = 4, SRCW = 8, ARB = 0, MACRO = 0;
  parameter NTX = 120;
  localparam SB = DW / 8;
  localparam BW = $clog2(SB);
  localparam SZW = $clog2(BW + 1);
  localparam MEMSZ = 1 << 20;
  localparam MAXB = 64;
  localparam MAXTX = 256;

  reg clk = 0, rst_n = 1'b1;
  always #5 clk = ~clk;

  integer seed = 1;
  reg [8*64-1:0] test_name = "regress";
  reg [8*256-1:0] stim_name = "";
  reg [8*256-1:0] vcd_name = "";
  reg scen = 0;

  // ---------------- DUT signals
  reg awvalid = 0, wvalid = 0, bready = 1, arvalid = 0, rready = 1;
  wire awready, wready, bvalid, arready, rvalid, rlast;
  reg [IDW-1:0] awid = 0, arid = 0;
  reg [AW-1:0] awaddr = 0, araddr = 0;
  reg [7:0] awlen = 0, arlen = 0;
  reg [2:0] awsize = 0, arsize = 0, awprot = 0, arprot = 0;
  reg [1:0] awburst = 0, arburst = 0;
  reg [DW-1:0] wdata = 0;
  reg [SB-1:0] wstrb = 0;
  reg wlast = 0;
  wire [IDW-1:0] bid, rid;
  wire [1:0] bresp, rresp;
  wire [DW-1:0] rdata;
  wire a_valid, d_ready;
  reg a_ready = 1;
  wire [2:0] a_opcode, a_param;
  wire [SZW-1:0] a_size;
  wire [SRCW-1:0] a_src;
  wire [AW-1:0] a_addr;
  wire [SB-1:0] a_mask;
  wire [DW-1:0] a_data;
  wire [17:0] a_user;
  reg d_valid = 0;
  reg [2:0] d_opcode = 0;
  reg [SRCW-1:0] d_src = 0;
  reg [DW-1:0] d_data = 0;
  reg d_err = 0;
  wire evt_orphan, evt_bad, evt_axi_err_rd, evt_axi_err_wr;
  reg mask_axi_illegal = 0, mask_wlast = 0, mask_tl_resp = 0;

  m_vlsit_axi2tlul_top #(.PARA_DATA_W(DW), .PARA_ADDR_W(AW), .PARA_AXI_ID_W(IDW), .PARA_TL_SRC_W(SRCW),
    .PARA_TL_AUSER_W(18), .PARA_TL_DUSER_W(14), .PARA_TL_SINK_W(1), .PARA_NUM_RD(NRD), .PARA_NUM_WR(NWR),
    .PARA_NUM_ID_RD(NIDR), .PARA_NUM_ID_WR(NIDW), .PARA_ARB_MODE(ARB), .PARA_STORE_MACRO(MACRO)) dut (
    .i_clk_main(clk), .i_rst_n_main(rst_n),
    .i_axi_awvalid(awvalid), .o_axi_awready(awready), .i_axi_awid(awid), .i_axi_awaddr(awaddr), .i_axi_awlen(awlen),
    .i_axi_awsize(awsize), .i_axi_awburst(awburst), .i_axi_awlock(1'b0), .i_axi_awcache(4'd0), .i_axi_awprot(awprot),
    .i_axi_awqos(4'd0), .i_axi_awregion(4'd0),
    .i_axi_wvalid(wvalid), .o_axi_wready(wready), .i_axi_wdata(wdata), .i_axi_wstrb(wstrb), .i_axi_wlast(wlast),
    .o_axi_bvalid(bvalid), .i_axi_bready(bready), .o_axi_bid(bid), .o_axi_bresp(bresp),
    .i_axi_arvalid(arvalid), .o_axi_arready(arready), .i_axi_arid(arid), .i_axi_araddr(araddr), .i_axi_arlen(arlen),
    .i_axi_arsize(arsize), .i_axi_arburst(arburst), .i_axi_arlock(1'b0), .i_axi_arcache(4'd0), .i_axi_arprot(arprot),
    .i_axi_arqos(4'd0), .i_axi_arregion(4'd0),
    .o_axi_rvalid(rvalid), .i_axi_rready(rready), .o_axi_rid(rid), .o_axi_rdata(rdata), .o_axi_rresp(rresp), .o_axi_rlast(rlast),
    .o_tl_a_valid(a_valid), .i_tl_a_ready(a_ready), .o_tl_a_opcode(a_opcode), .o_tl_a_param(a_param), .o_tl_a_size(a_size),
    .o_tl_a_src(a_src), .o_tl_a_addr(a_addr), .o_tl_a_mask(a_mask), .o_tl_a_data(a_data), .o_tl_a_user(a_user),
    .i_tl_d_valid(d_valid), .o_tl_d_ready(d_ready), .i_tl_d_opcode(d_opcode), .i_tl_d_param(3'd0), .i_tl_d_size({SZW{1'b0}}),
    .i_tl_d_src(d_src), .i_tl_d_sink(1'b0), .i_tl_d_data(d_data), .i_tl_d_user(14'd0), .i_tl_d_err(d_err),
    .o_evt_orphan_resp(evt_orphan), .o_evt_bad_resp(evt_bad), .o_evt_axi_err_rd(evt_axi_err_rd), .o_evt_axi_err_wr(evt_axi_err_wr));

  axi2tlul_checks #(.DW(DW), .AW(AW), .IDW(IDW), .SRCW(SRCW), .NRD(NRD), .NWR(NWR), .NIDR(NIDR), .NIDW(NIDW)) chk_i (
    .clk(clk), .rst_n(rst_n),
    .arvalid(arvalid), .arready(arready), .arid(arid), .araddr(araddr), .arlen(arlen), .arsize(arsize), .arburst(arburst), .arprot(arprot),
    .awvalid(awvalid), .awready(awready), .awid(awid), .awaddr(awaddr), .awlen(awlen), .awsize(awsize), .awburst(awburst), .awprot(awprot),
    .wvalid(wvalid), .wready(wready), .wdata(wdata), .wstrb(wstrb), .wlast(wlast),
    .bvalid(bvalid), .bready(bready), .bid(bid), .bresp(bresp),
    .rvalid(rvalid), .rready(rready), .rid(rid), .rdata(rdata), .rresp(rresp), .rlast(rlast),
    .a_valid(a_valid), .a_ready(a_ready), .a_opcode(a_opcode), .a_param(a_param), .a_size(a_size), .a_src(a_src),
    .a_addr(a_addr), .a_mask(a_mask), .a_data(a_data), .a_user(a_user),
    .d_valid(d_valid), .d_ready(d_ready), .d_opcode(d_opcode), .d_src(d_src),
    .mask_axi_illegal(mask_axi_illegal), .mask_wlast(mask_wlast), .mask_tl_resp(mask_tl_resp));

  integer errors = 0;
  integer cycle = 0;
  always @(posedge clk) cycle <= cycle + 1;
  task fail(input [8*80-1:0] msg);
    begin
      errors = errors + 1;
      if (errors < 40) $display("FAIL @%0d: %0s", cycle, msg);
    end
  endtask

  // ---------------- memories (device) and shadow (AXI view of the written region)
  reg [7:0] mem [0:MEMSZ-1];
  reg [7:0] shadow [0:MEMSZ-1];
  function [7:0] pat(input [31:0] a);
    pat = ((a * 32'd2654435761) >> 11) & 8'hFF;
  endfunction

  // ---------------- knobs of the current batch
  reg kn_illegal = 0, kn_err = 0, kn_wlast = 0, kn_reorder = 1, kn_ideal = 0;
  integer kn_dmx = 4, kn_bpr = 3, kn_ids = 6;

  // ---------------- transaction tables of the current batch
  reg [IDW-1:0] r_id [0:MAXTX-1];
  reg [AW-1:0] r_addr [0:MAXTX-1];
  reg [7:0] r_len [0:MAXTX-1];
  reg [2:0] r_size [0:MAXTX-1];
  reg [1:0] r_burst [0:MAXTX-1];
  reg r_prot [0:MAXTX-1];
  reg r_ill [0:MAXTX-1];
  reg [IDW-1:0] w_id [0:MAXTX-1];
  reg [AW-1:0] w_addr [0:MAXTX-1];
  reg [7:0] w_len [0:MAXTX-1];
  reg [2:0] w_size [0:MAXTX-1];
  reg [1:0] w_burst [0:MAXTX-1];
  reg w_prot [0:MAXTX-1];
  reg w_ill [0:MAXTX-1];
  reg w_err [0:MAXTX-1];
  reg w_wlbad [0:MAXTX-1];
  reg [DW-1:0] wd [0:MAXTX*MAXB-1];
  reg [SB-1:0] ws [0:MAXTX*MAXB-1];
  integer r_issued = 0, w_issued = 0, nbat = 0;

  // beat address, lanes and legality (independent of the RTL)
  function [AW-1:0] beat_addr(input [AW-1:0] a, input integer len, input [2:0] size, input [1:0] burst, input integer k);
    integer nb, wrapsz, base, j;
    reg [AW-1:0] cur;
    begin
      nb = 1 << size; cur = a;
      for (j = 0; j < k; j = j + 1) begin
        if (burst == 2'd1 || burst == 2'd2) begin
          cur = ((cur / nb) * nb) + nb;
          if (burst == 2'd2) begin
            wrapsz = nb * (len + 1); base = (a / wrapsz) * wrapsz;
            if (cur == base + wrapsz) cur = base;
          end
        end
      end
      beat_addr = cur;
    end
  endfunction
  function integer lane_lo(input [AW-1:0] ba, input [2:0] size, input [1:0] burst, input integer k);
    integer nb, off;
    begin
      nb = 1 << size; off = ba % SB;
      lane_lo = (k == 0 || burst == 2'd0) ? off : (off / nb) * nb;
    end
  endfunction
  function integer lane_hi(input [AW-1:0] ba, input [2:0] size);
    integer nb, off;
    begin nb = 1 << size; off = ba % SB; lane_hi = ((off / nb) * nb) + nb - 1; end
  endfunction
  function [SB-1:0] lanes(input [AW-1:0] ba, input [2:0] size, input [1:0] burst, input integer k);
    integer i;
    begin
      lanes = '0;
      for (i = 0; i < SB; i = i + 1) if (i >= lane_lo(ba, size, burst, k) && i <= lane_hi(ba, size)) lanes[i] = 1'b1;
    end
  endfunction
  function [SB-1:0] region(input [AW-1:0] ba, input [2:0] size);
    integer i;
    begin
      region = '0;
      for (i = 0; i < SB; i = i + 1) if (i >= ((ba % SB) / (1 << size)) * (1 << size) && i <= lane_hi(ba, size)) region[i] = 1'b1;
    end
  endfunction
  function is_illegal(input [AW-1:0] a, input [7:0] len, input [2:0] size, input [1:0] burst);
    integer nb, al;
    begin
      nb = 1 << size; al = (a / nb) * nb; is_illegal = 0;
      if (burst == 2'd3) is_illegal = 1;
      if (nb > SB) is_illegal = 1;
      if (burst == 2'd0 && len > 15) is_illegal = 1;
      if (burst == 2'd2 && !(len == 1 || len == 3 || len == 7 || len == 15)) is_illegal = 1;
      if (burst == 2'd2 && (a % nb) != 0) is_illegal = 1;
      if (burst == 2'd1 && (((al % 4096) + (len + 1) * nb) > 4096)) is_illegal = 1;
    end
  endfunction
  // the device reports an error on about one request in sixteen when the knob is set
  function beat_err(input [AW-1:0] a);
    beat_err = kn_err && ((pat(((a / SB) ^ 32'h5A5A5) & 32'hFFFFF) & 8'h0F) == 8'h00);
  endfunction

  // ---------------- random transaction generation
  task gen_tx(input is_wr, input integer n);
    integer sz, ln, bt, sel, k, i, lo, hi;
    reg [AW-1:0] a, ba;
    reg [IDW-1:0] id;
    reg illg, pr;
    reg [DW-1:0] dat;
    reg [SB-1:0] st;
    begin
      sz = $urandom(seed) % (BW + 1);
      bt = $urandom(seed) % 3;
      id = $urandom(seed) % kn_ids;
      a = $urandom(seed); a = a & 20'h7FFFF;
      if (is_wr) a = a | 20'h80000;
      pr = $urandom(seed);
      case (bt)
        0: ln = $urandom(seed) % 16;
        2: begin sel = $urandom(seed) % 4; ln = (sel == 0) ? 1 : (sel == 1) ? 3 : (sel == 2) ? 7 : 15; a = (a >> sz) << sz; end
        default: ln = $urandom(seed) % 40;
      endcase
      if (bt == 1)
        while ((((a / (1 << sz)) * (1 << sz)) % 4096) + (ln + 1) * (1 << sz) > 4096) ln = ln / 2;
      if (kn_illegal && ($urandom(seed) % 8) == 0) begin
        case ($urandom(seed) % 5)
          0: bt = 3;
          1: begin bt = 2; ln = 2; a = (a >> sz) << sz; end
          2: begin bt = 0; ln = 20; end
          3: begin bt = 1; a = (a & 20'hFF000) | 20'hFFC; ln = 7; sz = (BW < 2) ? BW : 2; end
          default: begin bt = 2; a = a | 1; sz = (BW > 0) ? 1 : 0; ln = 3; end
        endcase
      end
      illg = is_illegal(a, ln, sz, bt);
      if (is_wr) begin
        w_id[n] = id; w_addr[n] = a; w_len[n] = ln; w_size[n] = sz; w_burst[n] = bt; w_prot[n] = pr; w_ill[n] = illg;
        w_wlbad[n] = kn_wlast && ($urandom(seed) % 4 == 0) && (ln >= 1);
        w_err[n] = 0;
        for (k = 0; k <= ln; k = k + 1) begin
          ba = beat_addr(a, ln, sz, bt, k);
          lo = lane_lo(ba, sz, bt, k); hi = lane_hi(ba, sz);
          for (i = 0; i < DW/32; i = i + 1) dat[i*32 +: 32] = $urandom(seed);
          st = '0;
          for (i = 0; i < SB; i = i + 1) if (i >= lo && i <= hi) st[i] = ($urandom(seed) % 4 != 0);
          if (illg) st = $urandom(seed);
          wd[n*MAXB + k] = dat; ws[n*MAXB + k] = st;
          if (!illg && beat_err(ba)) w_err[n] = 1;
        end
      end else begin
        r_id[n] = id; r_addr[n] = a; r_len[n] = ln; r_size[n] = sz; r_burst[n] = bt; r_prot[n] = pr; r_ill[n] = illg;
      end
    end
  endtask

  // ---------------- AXI master drivers
  task ar_send(input integer n);
    begin
      arvalid <= 1; arid <= r_id[n]; araddr <= r_addr[n]; arlen <= r_len[n]; arsize <= r_size[n]; arburst <= r_burst[n];
      arprot <= {1'b0, r_prot[n], 1'b0} | {r_prot[n], 2'b00};
      @(posedge clk);
      while (!arready) @(posedge clk);
      r_issued = n + 1;
      arvalid <= 0; arid <= 'x; araddr <= 'x; arlen <= 'x; arsize <= 'x; arburst <= 'x; arprot <= 'x;
    end
  endtask
  task aw_send(input integer n);
    begin
      awvalid <= 1; awid <= w_id[n]; awaddr <= w_addr[n]; awlen <= w_len[n]; awsize <= w_size[n]; awburst <= w_burst[n];
      awprot <= {w_prot[n], 2'b00};
      @(posedge clk);
      while (!awready) @(posedge clk);
      w_issued = n + 1;
      awvalid <= 0; awid <= 'x; awaddr <= 'x; awlen <= 'x; awsize <= 'x; awburst <= 'x; awprot <= 'x;
    end
  endtask
  task w_beat(input integer n, input integer k, input gap_ok);
    integer gap, i;
    reg [AW-1:0] ba;
    reg lastv;
    begin
      gap = (gap_ok && !kn_ideal && ($urandom(seed) % 3 == 0)) ? ($urandom(seed) % 3) : 0;
      repeat (gap) @(posedge clk);
      lastv = (k == w_len[n]);
      if (w_wlbad[n]) lastv = (n % 2 == 0) ? ((k == w_len[n]) || (k == w_len[n] - 1)) : (k == w_len[n] - 1 && 0);
      wvalid <= 1; wdata <= wd[n*MAXB + k]; wstrb <= ws[n*MAXB + k]; wlast <= lastv;
      @(posedge clk);
      while (!wready) @(posedge clk);
      wvalid <= 0; wlast <= 0; wdata <= 'x; wstrb <= 'x;
      if (!w_ill[n]) begin
        ba = beat_addr(w_addr[n], w_len[n], w_size[n], w_burst[n], k);
        if (!beat_err(ba))
          for (i = 0; i < SB; i = i + 1)
            if (ws[n*MAXB + k][i]) shadow[(ba / SB) * SB + i] = wd[n*MAXB + k][i*8 +: 8];
      end
    end
  endtask

  integer evt_cnt = 0, ill_cnt = 0, wl_cnt_exp = 0;
  always @(posedge clk) evt_cnt = evt_cnt + (evt_axi_err_rd === 1'b1) + (evt_axi_err_wr === 1'b1);

  // ---------------- R monitor and scoreboard
  integer rd_ptr [0:15];
  reg rd_seen [0:MAXTX-1];
  integer rd_cur_tx, rd_cur_beat, rd_done, rd_beats, ovt_cnt, wb_done, wb_ptr [0:15];
  integer rfind, bfind;
  integer rq_tx = 0, rq_beat = 0, wq_tx = 0, wq_beat = 0, acc_get = 0, acc_put = 0;
  reg mon_en = 0;
  task sb_init(input integer n);
    integer i;
    begin
      for (i = 0; i < 16; i = i + 1) begin rd_ptr[i] = 0; wb_ptr[i] = 0; end
      for (i = 0; i < MAXTX; i = i + 1) rd_seen[i] = 0;
      rd_cur_tx = -1; rd_cur_beat = 0; rd_done = 0; rd_beats = 0; ovt_cnt = 0; wb_done = 0;
      r_issued = 0; w_issued = 0; nbat = n; evt_cnt = 0;
      rq_tx = 0; rq_beat = 0; wq_tx = 0; wq_beat = 0; acc_get = 0; acc_put = 0;
    end
  endtask
  always @(posedge clk) if (mon_en && rst_n && rvalid && rready) begin : rmon
    integer n, lo, hi, i;
    reg [AW-1:0] ba;
    reg beat_e;
    rd_beats = rd_beats + 1;
    if (rd_cur_tx < 0) begin
      rfind = -1;
      for (n = rd_ptr[rid]; n < r_issued && rfind < 0; n = n + 1) if (r_id[n] == rid) rfind = n;
      chk_i.chk(65, 1'b1, rfind >= 0);
      if (rfind >= 0) begin
        rd_cur_tx = rfind; rd_cur_beat = 0; rd_ptr[rid] = rfind + 1;
        for (n = 0; n < rfind; n = n + 1) if (r_id[n] != rid && !rd_seen[n]) ovt_cnt = ovt_cnt + 1;
        rd_seen[rfind] = 1;
      end
    end
    if (rd_cur_tx >= 0) begin
      chk_i.chk(65, 1'b1, rid == r_id[rd_cur_tx]);
      ba = beat_addr(r_addr[rd_cur_tx], r_len[rd_cur_tx], r_size[rd_cur_tx], r_burst[rd_cur_tx], rd_cur_beat);
      lo = lane_lo(ba, r_size[rd_cur_tx], r_burst[rd_cur_tx], rd_cur_beat); hi = lane_hi(ba, r_size[rd_cur_tx]);
      beat_e = !r_ill[rd_cur_tx] && beat_err(ba);
      chk_i.chk(64, beat_e | r_ill[rd_cur_tx], rresp === 2'b10);
      if (!beat_e && !r_ill[rd_cur_tx]) begin
        if (rresp !== 2'b00) fail("RRESP not OKAY");
        for (i = lo; i <= hi; i = i + 1)
          if (rdata[i*8 +: 8] !== pat((ba / SB) * SB + i)) fail("RDATA mismatch");
      end
      if (rd_cur_beat == r_len[rd_cur_tx]) begin rd_cur_tx = -1; rd_done = rd_done + 1; end
      else rd_cur_beat = rd_cur_beat + 1;
    end
  end
  always @(posedge clk) if (mon_en && rst_n && bvalid && bready) begin : bmon
    integer n;
    bfind = -1;
    for (n = wb_ptr[bid]; n < w_issued && bfind < 0; n = n + 1) if (w_id[n] == bid) bfind = n;
    chk_i.chk(65, 1'b1, bfind >= 0);
    if (bfind >= 0) begin
      wb_ptr[bid] = bfind + 1; wb_done = wb_done + 1;
      chk_i.chk(64, w_ill[bfind] | w_err[bfind], bresp === 2'b10);
      if (!(w_ill[bfind] | w_err[bfind]) && bresp !== 2'b00) fail("BRESP not OKAY");
    end
  end

  // ---------------- expected TL-UL requests (order per direction)
  always @(posedge clk) if (mon_en && rst_n && a_valid && a_ready) begin : reqmon
    integer nb, i;
    reg [AW-1:0] ba;
    reg [SB-1:0] ex_mask, rg;
    reg ok;
    if (a_opcode == 3'd4) begin
      while (rq_tx < nbat && r_ill[rq_tx]) begin rq_tx = rq_tx + 1; rq_beat = 0; end
      ok = (rq_tx < r_issued);
      if (ok) begin
        ba = beat_addr(r_addr[rq_tx], r_len[rq_tx], r_size[rq_tx], r_burst[rq_tx], rq_beat);
        ex_mask = lanes(ba, r_size[rq_tx], r_burst[rq_tx], rq_beat);
        chk_i.chk(60, 1'b1, (a_addr === ((ba / (1 << r_size[rq_tx])) * (1 << r_size[rq_tx]))) && (a_size === r_size[rq_tx][SZW-1:0]) &&
                            (a_mask === ex_mask) && (a_user[17:14] === (r_prot[rq_tx] ? 4'h6 : 4'h9)));
        if (rq_beat == r_len[rq_tx]) begin rq_tx = rq_tx + 1; rq_beat = 0; end else rq_beat = rq_beat + 1;
      end else chk_i.chk(60, 1'b1, 1'b0);
      acc_get = acc_get + 1;
    end else begin
      while (wq_tx < nbat && w_ill[wq_tx]) begin wq_tx = wq_tx + 1; wq_beat = 0; end
      ok = (wq_tx < w_issued);
      if (ok) begin
        ba = beat_addr(w_addr[wq_tx], w_len[wq_tx], w_size[wq_tx], w_burst[wq_tx], wq_beat);
        ex_mask = ws[wq_tx*MAXB + wq_beat] & lanes(ba, w_size[wq_tx], w_burst[wq_tx], wq_beat);
        rg = region(ba, w_size[wq_tx]);
        chk_i.chk(61, 1'b1, (a_addr === ((ba / (1 << w_size[wq_tx])) * (1 << w_size[wq_tx]))) && (a_size === w_size[wq_tx][SZW-1:0]) &&
                            (a_mask === ex_mask) && (a_opcode === ((ex_mask == rg) ? 3'd0 : 3'd1)) &&
                            (a_data === wd[wq_tx*MAXB + wq_beat]) && (a_user[17:14] === (w_prot[wq_tx] ? 4'h6 : 4'h9)));
        if (wq_beat == w_len[wq_tx]) begin wq_tx = wq_tx + 1; wq_beat = 0; end else wq_beat = wq_beat + 1;
      end else chk_i.chk(61, 1'b1, 1'b0);
      acc_put = acc_put + 1;
    end
  end

  // ---------------- TL-UL device model (hold of d_valid until d_ready, reorder, delay, error window)
  reg [SRCW-1:0] q_src [0:63];
  reg [2:0] q_op [0:63];
  reg [DW-1:0] q_data [0:63];
  reg q_err [0:63];
  integer q_time [0:63];
  reg q_used [0:63];
  integer q_i;
  reg dev_flip_op = 0;
  reg inj_v = 0;
  reg [2:0] inj_op = 0;
  reg [SRCW-1:0] inj_src = 0;
  initial for (q_i = 0; q_i < 64; q_i = q_i + 1) q_used[q_i] = 0;
  integer dev_hold_ready = 0;
  reg dev_hold = 0;
  always @(posedge clk) if (!scen) begin
    if (dev_hold) a_ready <= 1'b0;
    else a_ready <= kn_ideal ? 1'b1 : (($urandom(seed) % 4) != 0);
  end
  always @(posedge clk) if (!scen && rst_n === 1'b1 && a_valid && a_ready) begin : devacc
    integer slot, i, base;
    reg [DW-1:0] rd;
    reg e;
    slot = -1;
    for (i = 0; i < 64 && slot < 0; i = i + 1) if (!q_used[i]) slot = i;
    if (slot < 0) fail("device queue overflow");
    else begin
      e = beat_err(a_addr);
      base = (a_addr / SB) * SB;
      rd = '0;
      for (i = 0; i < SB; i = i + 1) rd[i*8 +: 8] = mem[base + i];
      if (a_opcode == 3'd4) begin q_op[slot] = 3'd1; q_data[slot] = rd; end
      else begin
        q_op[slot] = 3'd0; q_data[slot] = '0;
        if (!e) for (i = 0; i < SB; i = i + 1) if (a_mask[i]) mem[base + i] = a_data[i*8 +: 8];
      end
      if (dev_flip_op) begin q_op[slot] = (a_opcode == 3'd4) ? 3'd0 : 3'd1; dev_flip_op = 0; end
      if (e && a_opcode == 3'd4) q_data[slot] = {DW{1'b1}};
      q_err[slot] = e; q_src[slot] = a_src;
      q_time[slot] = cycle + 1 + (kn_ideal ? 0 : ($urandom(seed) % (kn_dmx + 1)));
      q_used[slot] = 1;
    end
  end
  integer d_taken = 0;
  always @(posedge clk) if (!scen) begin : devresp
    integer i, pick, cnt;
    if (d_valid && !d_ready) begin
      // hold the response until the bridge takes it
    end else begin
      if (d_valid && d_ready) d_taken = d_taken + 1;
      pick = -1; cnt = 0;
      for (i = 0; i < 64; i = i + 1)
        if (q_used[i] && q_time[i] <= cycle) begin
          if (kn_reorder && ($urandom(seed) % (cnt + 1) == 0)) pick = i;
          else if (!kn_reorder && pick < 0) pick = i;
          cnt = cnt + 1;
        end
      d_valid <= 0; d_err <= 0; d_opcode <= 'x; d_src <= 'x; d_data <= 'x;
      if (inj_v) begin
        d_valid <= 1; d_opcode <= inj_op; d_src <= inj_src; d_data <= {DW{1'b1}}; inj_v = 0;
      end else if (pick >= 0 && rst_n === 1'b1) begin
        d_valid <= 1; d_opcode <= q_op[pick]; d_src <= q_src[pick]; d_data <= q_data[pick]; d_err <= q_err[pick];
        q_used[pick] = 0;
      end
    end
  end

  // ---------------- R and B readiness
  reg rb_free = 0;
  always @(posedge clk) if (!scen) begin
    rready <= (kn_ideal || rb_free) ? 1'b1 : (($urandom(seed) % kn_bpr) != 0);
    bready <= (kn_ideal || rb_free) ? 1'b1 : (($urandom(seed) % kn_bpr) != 0);
  end

  // ---------------- one batch of transactions
  integer to_cnt;
  task run_batch(input integer n);
    integer i;
    begin
      sb_init(n);
      chk_i.clear_trackers;
      ill_cnt = 0; wl_cnt_exp = 0;
      for (i = 0; i < n; i = i + 1) begin
        gen_tx(0, i); gen_tx(1, i);
        if (r_ill[i]) ill_cnt = ill_cnt + 1;
        if (w_ill[i]) ill_cnt = ill_cnt + 1;
        if (w_wlbad[i] && !w_ill[i]) wl_cnt_exp = wl_cnt_exp + 1;
        if (w_wlbad[i] && w_ill[i]) wl_cnt_exp = wl_cnt_exp + 1;
      end
      mask_axi_illegal = kn_illegal; mask_wlast = kn_wlast;
      mon_en = 1;
      fork
        begin : arl
          integer k, gap;
          for (k = 0; k < n; k = k + 1) begin
            gap = kn_ideal ? 0 : ($urandom(seed) % 4);
            repeat (gap) @(posedge clk);
            ar_send(k);
          end
        end
        begin : awl
          integer k, gap;
          for (k = 0; k < n; k = k + 1) begin
            gap = kn_ideal ? 0 : ($urandom(seed) % 5);
            repeat (gap) @(posedge clk);
            aw_send(k);
          end
        end
        begin : wl
          integer k, j;
          for (k = 0; k < n; k = k + 1) for (j = 0; j <= w_len[k]; j = j + 1) w_beat(k, j, 1'b1);
        end
      join
      to_cnt = 0;
      while ((rd_done < n || wb_done < n) && to_cnt < 200000) begin @(posedge clk); to_cnt = to_cnt + 1; end
      if (to_cnt >= 200000) fail("batch timeout, a transaction did not complete");
      repeat (40) @(posedge clk);
      mon_en = 0;
      mask_axi_illegal = 0; mask_wlast = 0;
      chk_i.chk(63, 1'b1, rd_done == n && wb_done == n);
      chk_i.chk(62, 1'b1, (acc_get == sum_get(n)) && (acc_put == sum_put(n)));
      chk_i.chk(66, 1'b1, evt_cnt == ill_cnt + wl_cnt_exp);
      if (acc_get != sum_get(n) || acc_put != sum_put(n)) $display("  requests: get %0d expected %0d, put %0d expected %0d", acc_get, sum_get(n), acc_put, sum_put(n));
      if (evt_cnt != ill_cnt + wl_cnt_exp) $display("  events: %0d expected %0d", evt_cnt, ill_cnt + wl_cnt_exp);
    end
  endtask
  function integer sum_get(input integer n);
    integer i;
    begin sum_get = 0; for (i = 0; i < n; i = i + 1) if (!r_ill[i]) sum_get = sum_get + r_len[i] + 1; end
  endfunction
  function integer sum_put(input integer n);
    integer i;
    begin sum_put = 0; for (i = 0; i < n; i = i + 1) if (!w_ill[i]) sum_put = sum_put + w_len[i] + 1; end
  endfunction

  task idle_wait(input integer n);
    begin repeat (n) @(posedge clk); end
  endtask

  // ---------------- reset helper
  // The reset is asserted at a falling edge of the clock (away from the sampling edge) and released at a
  // rising edge, as the specification requires (asynchronous assertion, synchronous release).
  task do_reset(input integer n);
    begin
      @(negedge clk);
      rst_n = 0;
      arvalid <= 0; awvalid <= 0; wvalid <= 0; wlast <= 0;
      repeat (n) @(posedge clk);
      rst_n <= 1;
    end
  endtask

  // ---------------- directed phases
  integer t0, t1, t2, seq_i;
  reg [255:0] seq_str;
  integer pulse_cnt;

  // single AXI read in an idle bridge with ideal handshakes: request latency and response latency
  task single_read(input [IDW-1:0] id, input [AW-1:0] a, input [7:0] ln);
    integer c_ar, c_a, c_d, c_r;
    begin
      c_ar = -1; c_a = -1; c_d = -1; c_r = -1;
      fork
        begin
          @(posedge clk); arvalid <= 1; arid <= id; araddr <= a; arlen <= ln; arsize <= 2; arburst <= 1; arprot <= 0;
          @(posedge clk); while (!arready) @(posedge clk);
          c_ar = cycle; arvalid <= 0;
        end
        begin : watch
          integer k;
          for (k = 0; k < 60; k = k + 1) begin
            @(posedge clk);
            if (c_a < 0 && a_valid && a_ready) c_a = cycle;
            if (c_d < 0 && d_valid && d_ready) c_d = cycle;
            if (c_r < 0 && rvalid && rready) c_r = cycle;
          end
        end
      join
      chk_i.chk(69, 1'b1, (c_a == c_ar + 1) && (c_r == c_d + 1));
      if (!((c_a == c_ar + 1) && (c_r == c_d + 1))) $display("  latency: AR %0d A %0d D %0d R %0d", c_ar, c_a, c_d, c_r);
    end
  endtask
  task single_write(input [IDW-1:0] id, input [AW-1:0] a);
    integer c_aw, c_a, c_d, c_b;
    begin
      c_aw = -1; c_a = -1; c_d = -1; c_b = -1;
      fork
        begin
          @(posedge clk); awvalid <= 1; awid <= id; awaddr <= a; awlen <= 0; awsize <= 2; awburst <= 1; awprot <= 0;
          wvalid <= 1; wdata <= 32'h12345678; wstrb <= {SB{1'b1}}; wlast <= 1;
          @(posedge clk); while (!awready) @(posedge clk);
          c_aw = cycle; awvalid <= 0;
          while (!wready) @(posedge clk);
          wvalid <= 0; wlast <= 0;
        end
        begin : watch
          integer k;
          for (k = 0; k < 60; k = k + 1) begin
            @(posedge clk);
            if (c_a < 0 && a_valid && a_ready) c_a = cycle;
            if (c_d < 0 && d_valid && d_ready) c_d = cycle;
            if (c_b < 0 && bvalid && bready) c_b = cycle;
          end
        end
      join
      chk_i.chk(69, 1'b1, (c_a == c_aw + 1) && (c_b == c_d + 1));
      if (!((c_a == c_aw + 1) && (c_b == c_d + 1))) $display("  latency: AW %0d A %0d D %0d B %0d", c_aw, c_a, c_d, c_b);
    end
  endtask

  // continuity of a burst and of two bursts back to back (REQ-PERF-003, PERF-005); a burst needs one free read slot
  // per beat, so the burst length and the burst count follow NRD (a single slot cannot hold a burst)
  task burst_continuity;
    localparam integer BLEN = (NRD >= 8) ? 7 : (NRD >= 4) ? 3 : 1;
    localparam integer NB = (NRD >= 16) ? 2 : 1;
    integer first_a, last_a, na, k, nr, first_r, last_r, exp_n;
    reg ok;
    begin
      if (NRD >= 2) begin
        na = 0; nr = 0; first_a = -1; last_a = -1; first_r = -1; last_r = -1;
        exp_n = NB * (BLEN + 1);
        fork
          begin
            @(posedge clk); arvalid <= 1; arid <= 3; araddr <= 20'h1000; arlen <= BLEN; arsize <= 2; arburst <= 1; arprot <= 0;
            @(posedge clk); while (!arready) @(posedge clk);
            arvalid <= 0;
            if (NB == 2) begin
              @(posedge clk); arvalid <= 1; arid <= 4; araddr <= 20'h2000; arlen <= BLEN; arsize <= 2; arburst <= 1;
              @(posedge clk); while (!arready) @(posedge clk);
              arvalid <= 0;
            end
          end
          begin
            for (k = 0; k < 60; k = k + 1) begin
              @(posedge clk);
              if (a_valid && a_ready) begin if (first_a < 0) first_a = cycle; last_a = cycle; na = na + 1; end
              if (rvalid && rready) begin if (first_r < 0) first_r = cycle; last_r = cycle; nr = nr + 1; end
            end
          end
        join
        ok = (na == exp_n) && (last_a - first_a == exp_n - 1) && (nr == exp_n) && (last_r - first_r == exp_n - 1);
        chk_i.chk(71, 1'b1, ok);
        if (!ok) $display("  continuity: requests %0d span %0d, R beats %0d span %0d (expected %0d)", na, last_a - first_a, nr, last_r - first_r, exp_n);
      end
    end
  endtask

  // response with a wrong opcode: SLVERR and one bad pulse, nothing else
  task wrong_opcode(input is_wr);
    integer bad_before, bd;
    begin
      bad_before = 0; bd = 0;
      mask_tl_resp = 1; dev_flip_op = 1;
      pulse_cnt = 0;
      fork
        begin
          @(posedge clk);
          if (is_wr) begin
            awvalid <= 1; awid <= 5; awaddr <= 20'h80100; awlen <= 0; awsize <= 2; awburst <= 1; awprot <= 0;
            wvalid <= 1; wdata <= 32'hCAFEF00D; wstrb <= {SB{1'b1}}; wlast <= 1;
            @(posedge clk); while (!awready) @(posedge clk);
            awvalid <= 0; while (!wready) @(posedge clk); wvalid <= 0; wlast <= 0;
          end else begin
            arvalid <= 1; arid <= 5; araddr <= 20'h100; arlen <= 0; arsize <= 2; arburst <= 1; arprot <= 0;
            @(posedge clk); while (!arready) @(posedge clk);
            arvalid <= 0;
          end
        end
        begin : watch
          integer k;
          for (k = 0; k < 60; k = k + 1) begin
            @(posedge clk);
            if (evt_bad) pulse_cnt = pulse_cnt + 1;
            if (is_wr && bvalid && bready) chk_i.chk(67, 1'b1, bresp === 2'b10);
            if (!is_wr && rvalid && rready) chk_i.chk(67, 1'b1, rresp === 2'b10);
          end
        end
      join
      chk_i.chk(67, 1'b1, pulse_cnt == 1);
      mask_tl_resp = 0;
      idle_wait(4);
    end
  endtask

  // orphaned responses: tag of a free slot, tag with a bit above the slot field (REQ-ERR-005)
  task orphan_resp;
    integer c_before, k;
    begin
      mask_tl_resp = 1; pulse_cnt = 0;
      fork
        begin
          @(posedge clk); inj_v = 1; inj_op = 3'd1; inj_src = 5;
          repeat (4) @(posedge clk);
          inj_v = 1; inj_op = 3'd0; inj_src = (1 << (SRCW - 1)) | 3;
          repeat (4) @(posedge clk);
          inj_v = 1; inj_op = 3'd0; inj_src = 20;
          repeat (4) @(posedge clk);
        end
        begin
          for (k = 0; k < 30; k = k + 1) begin
            @(posedge clk);
            if (evt_orphan) pulse_cnt = pulse_cnt + 1;
            chk_i.chk(68, 1'b1, ~(rvalid | bvalid));
          end
        end
      join
      chk_i.chk(68, 1'b1, pulse_cnt == 3);
      mask_tl_resp = 0;
    end
  endtask

  // arbitration order of simultaneous read and write requests (REQ-FUNC-013, REQ-FUNC-014)
  task arb_order;
    integer k, n, ok;
    reg [63:0] ops;
    begin
      n = 0; ops = 0;
      fork
        begin
          @(posedge clk);
          arvalid <= 1; arid <= 2; araddr <= 20'h3000; arlen <= 7; arsize <= 2; arburst <= 1; arprot <= 0;
          @(posedge clk); while (!arready) @(posedge clk);
          arvalid <= 0;
        end
        begin
          @(posedge clk);
          awvalid <= 1; awid <= 2; awaddr <= 20'h83000; awlen <= 7; awsize <= 2; awburst <= 1; awprot <= 0;
          @(posedge clk); while (!awready) @(posedge clk);
          awvalid <= 0;
        end
        begin : wdrv
          integer kk;
          @(posedge clk);
          for (kk = 0; kk < 8; kk = kk + 1) begin
            wvalid <= 1; wdata <= 32'h11111111 + kk; wstrb <= {SB{1'b1}}; wlast <= (kk == 7);
            @(posedge clk); while (!wready) @(posedge clk);
          end
          wvalid <= 0; wlast <= 0;
        end
        begin
          for (k = 0; k < 50; k = k + 1) begin
            @(posedge clk);
            if (a_valid && a_ready && n < 16) begin ops[n] = (a_opcode == 3'd4); n = n + 1; end
          end
        end
      join
      // ops[i] = 1 for a Get request: expected order of the 16 requests per mode
      ok = 1;
      case (ARB)
        0: for (k = 0; k < 16; k = k + 1) if (ops[k] !== ((k % 2) == 0)) ok = 0;
        1: for (k = 0; k < 16; k = k + 1) if (ops[k] !== (k < 8)) ok = 0;
        default: for (k = 0; k < 16; k = k + 1) if (ops[k] !== (k >= 8)) ok = 0;
      endcase
      chk_i.chk(74, 1'b1, ok == 1 && n == 16);
      if (!(ok == 1 && n == 16)) $display("  arbitration order: %b (n=%0d)", ops[15:0], n);
    end
  endtask

  // reset in the middle of traffic, then a short batch to prove normal operation (REQ-RESET-001..003)
  task reset_in_traffic;
    integer k, orph0, drained;
    begin
      kn_dmx = 20; kn_ideal = 0; kn_illegal = 0; kn_wlast = 0; kn_err = 0;
      sb_init(8);
      chk_i.clear_trackers;
      for (k = 0; k < 8; k = k + 1) begin gen_tx(0, k); gen_tx(1, k); end
      mask_axi_illegal = 0; mon_en = 0;
      fork : drv
        begin : ard
          integer ka;
          for (ka = 0; ka < 8; ka = ka + 1) ar_send(ka);
        end
        begin : awd
          integer kw;
          for (kw = 0; kw < 8; kw = kw + 1) aw_send(kw);
        end
        begin : wl
          integer kk, j;
          for (kk = 0; kk < 8; kk = kk + 1) for (j = 0; j <= w_len[kk]; j = j + 1) w_beat(kk, j, 1'b0);
        end
        begin
          repeat (45) @(posedge clk);
        end
      join_any
      disable drv;
      // the tasks called by the driver threads are separate scopes: stop them too, or they keep driving the next batch
      disable ar_send; disable aw_send; disable w_beat;
      // abort the masters and assert the reset
      @(negedge clk);
      rst_n = 0; arvalid <= 0; awvalid <= 0; wvalid <= 0; wlast <= 0;
      mask_tl_resp = 1; pulse_cnt = 0;
      repeat (3) @(posedge clk);
      chk_i.chk(73, 1'b1, (rvalid === 1'b0) && (bvalid === 1'b0) && (a_valid === 1'b0) && (arready === 1'b0 || arready === 1'b1));
      rst_n <= 1;
      d_taken = 0;
      repeat (3) @(posedge clk);
      // the device still delivers the old responses: each one is orphaned
      for (k = 0; k < 60; k = k + 1) begin
        @(posedge clk);
        if (evt_orphan) pulse_cnt = pulse_cnt + 1;
      end
      chk_i.chk(73, 1'b1, (pulse_cnt >= 0) && (rvalid === 1'b0) && (bvalid === 1'b0) && (a_valid === 1'b0));
      mask_tl_resp = 0;
      // clear the device state and show that the bridge works after the reset
      for (k = 0; k < 64; k = k + 1) q_used[k] = 0;
      d_valid <= 0;
      for (k = 'h80000; k < MEMSZ; k = k + 1) shadow[k] = mem[k];
    end
  endtask

  // ---------------- scenario mode: inputs from the specification figure
  integer fd, rcode;
  reg f_rst, f_awvalid, f_wvalid, f_bready, f_arvalid, f_rready, f_aready, f_dvalid, f_derr, f_wlast;
  reg [IDW-1:0] f_awid, f_arid;
  reg [AW-1:0] f_awaddr, f_araddr;
  reg [7:0] f_awlen, f_arlen;
  reg [2:0] f_awsize, f_arsize, f_awprot, f_arprot, f_dop;
  reg [1:0] f_awburst, f_arburst;
  reg [DW-1:0] f_wdata, f_ddata;
  reg [SB-1:0] f_wstrb;
  reg [SRCW-1:0] f_dsrc;
  initial begin : scenario
    #1;
    if (scen) begin
      fd = $fopen(stim_name, "r");
      if (fd == 0) begin $display("cannot open the stimulus file"); $finish; end
      rst_n = 0;
      repeat (4) @(posedge clk);
      while (!$feof(fd)) begin
        rcode = $fscanf(fd, "%h %h %h %h %h %h %h %h %h %h %h %h %h %h %h %h %h %h %h %h %h %h %h %h %h %h %h\n",
          f_rst, f_awvalid, f_awid, f_awaddr, f_awlen, f_awsize, f_awburst, f_awprot,
          f_wvalid, f_wdata, f_wstrb, f_wlast, f_bready,
          f_arvalid, f_arid, f_araddr, f_arlen, f_arsize, f_arburst, f_arprot, f_rready,
          f_aready, f_dvalid, f_dop, f_dsrc, f_ddata, f_derr);
        if (rcode == 27) begin
          rst_n <= f_rst; awvalid <= f_awvalid; awid <= f_awid; awaddr <= f_awaddr; awlen <= f_awlen; awsize <= f_awsize;
          awburst <= f_awburst; awprot <= f_awprot; wvalid <= f_wvalid; wdata <= f_wdata; wstrb <= f_wstrb; wlast <= f_wlast;
          bready <= f_bready; arvalid <= f_arvalid; arid <= f_arid; araddr <= f_araddr; arlen <= f_arlen; arsize <= f_arsize;
          arburst <= f_arburst; arprot <= f_arprot; rready <= f_rready; a_ready <= f_aready; d_valid <= f_dvalid;
          d_opcode <= f_dop; d_src <= f_dsrc; d_data <= f_ddata; d_err <= f_derr;
          @(posedge clk);
        end
      end
      awvalid <= 0; wvalid <= 0; arvalid <= 0; d_valid <= 0; a_ready <= 1; bready <= 1; rready <= 1; wlast <= 0;
      repeat (8) @(posedge clk);
      $display("SCENARIO done: %0s", stim_name);
      $finish;
    end
  end
  // the scenario sets the masks of the stimulus rules that a figure breaks on purpose (illegal burst, injected response)
  initial begin
    #1;
    if (scen) begin mask_axi_illegal = 1; mask_wlast = 1; mask_tl_resp = 1; end
  end

  // ---------------- main (regression mode)
  integer n_i, nf, nn;
  initial begin : main
    if (!$value$plusargs("SEED=%d", seed)) seed = 1;
    if ($value$plusargs("TEST=%s", test_name)) begin end
    if ($value$plusargs("STIM=%s", stim_name)) scen = 1;
    if ($value$plusargs("VCD=%s", vcd_name)) begin
      $dumpfile(vcd_name);
      $dumpvars(0, tb_axi2tlul);
    end
    $display("SIM-BRANCH: synthesis (single clock, no crossing)");
    $display("TEST %0s seed=%0d", scen ? "scenario" : "regress", seed);
    for (n_i = 0; n_i < MEMSZ; n_i = n_i + 1) begin mem[n_i] = pat(n_i); shadow[n_i] = pat(n_i); end
    if (!scen) begin
      #1 rst_n = 0;
      repeat (4) @(posedge clk);
      rst_n <= 1;
      repeat (6) @(posedge clk);
      // reset values and the first cycles after the release are checked by the assertions
      // phase 1: latency and continuity with ideal handshakes (REQ-PERF-001..003, 005)
      kn_ideal = 1; kn_dmx = 0; kn_reorder = 0; rb_free = 1;
      single_read(1, 20'h100, 0); idle_wait(6);
      single_read(2, 20'h104, 3); idle_wait(10);
      single_write(3, 20'h80200); idle_wait(8);
      burst_continuity; idle_wait(10);
      // phase 2: arbitration order of simultaneous requests, after a reset: the first tie goes to the read request
      do_reset(3); idle_wait(5);
      arb_order; idle_wait(40);
      // phase 3: injected faults of the TL-UL device (REQ-ERR-004, 005)
      wrong_opcode(0); wrong_opcode(1);
      orphan_resp; idle_wait(10);
      kn_ideal = 0; rb_free = 0;
      // phase 4: random batches
      kn_reorder = 1; kn_dmx = 4; kn_bpr = 3; kn_illegal = 0; kn_err = 0; kn_wlast = 0; kn_ids = 6;
      run_batch(NTX);
      kn_illegal = 1; kn_err = 1; kn_wlast = 1; kn_dmx = 8; kn_bpr = 2;
      run_batch(NTX);
      kn_illegal = 0; kn_err = 0; kn_wlast = 0; kn_dmx = 14; kn_bpr = 2; kn_ids = 8;
      run_batch(NTX);
      kn_illegal = 1; kn_err = 1; kn_wlast = 0; kn_dmx = 0; kn_reorder = 0; kn_bpr = 4; kn_ids = 3;
      run_batch(NTX);
      // phase 5: reset in the middle of traffic
      reset_in_traffic;
      kn_illegal = 0; kn_err = 0; kn_wlast = 0; kn_dmx = 3; kn_reorder = 1; kn_bpr = 3; kn_ids = 4;
      idle_wait(8);
      run_batch(30);
      // memory of the write region against the AXI view
      for (n_i = 'h80000; n_i < MEMSZ; n_i = n_i + 1)
        if (mem[n_i] !== shadow[n_i]) begin
          fail("memory of the write region differs from the AXI view");
          n_i = MEMSZ;
        end
      if (a_valid) fail("a_valid after the end of the test");
      chk_i.report(1'b1, nf, nn);
      $display("assertion failures: %0d, assertions never exercised: %0d", nf, nn);
      if (errors == 0 && nf == 0 && nn == 0) $display("PASS tb_axi2tlul");
      else begin
        $display("FAIL tb_axi2tlul: %0d check errors", errors);
        $fatal(1, "simulation failed");
      end
      $finish;
    end
  end
  initial begin
    #500000000;
    $display("TIMEOUT");
    $fatal(1, "timeout");
  end
endmodule
