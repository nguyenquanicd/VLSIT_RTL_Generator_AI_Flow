/*
 * Project      : HyperRAM Controller
 * Author       : Nguyen Quan (user)
 * AI Flow      : VLSIT RTL Generator AI Automation Flow
 * AI Flow Page : https://github.com/nguyenquanicd/VLSIT_RTL_Generator_AI_Model
 * Date         : 2026-11-04
 * Description  : Coverage testbench of m_vlsit_hyperram_controller with the behavioral device
 *                m_vlsit_hr_model (verification code, not synthesizable). The stimulus and the
 *                expected values come from the specification (AXI4 rules for beat addresses and
 *                byte lanes, response codes of Section 12, register map of Section 11); the
 *                data check compares every byte read with the byte last written to the address.
 *                Parameters select the AXI data width, the HyperBus width, the number of chip
 *                selects and the AXI clock mode, so that one build covers one configuration.
 */
`timescale 1ns/1ps

// Test code is excluded from the coverage database; only the design is measured.
// verilator coverage_off
module m_vlsit_tb_hyperram_cov #(
  parameter integer PARA_AXI_W = 32,
  parameter integer PARA_DQ    = 8,
  parameter integer PARA_NCS   = 1,
  parameter integer PARA_ASYNC = 0,
  parameter integer PARA_NTEST = 40,
  parameter integer PARA_GAPS  = 1
) ();

  localparam integer LPARA_MEM_B = 262144;
  localparam integer LPARA_BUSB  = PARA_AXI_W / 8;
  localparam integer LPARA_MAXSZ = (PARA_AXI_W == 64) ? 3 : 2;
  localparam integer LPARA_REFB  = PARA_NCS * LPARA_MEM_B;

  // Clocks and resets
  logic clk_core = 0;
  logic clk_axi = 0;
  logic clk_apb  = 0;
  logic rst_n_core = 1;
  logic rst_n_axi  = 1;
  logic rst_n_apb  = 1;
  // In the synchronous mode the AXI clock is toggled in the same process as the core clock, so that
  // the testbench and the DUT see the edge in the same time step (no delta-cycle race).
  always #1.25 begin
    clk_core = ~clk_core;
    if (PARA_ASYNC == 0)
      clk_axi = ~clk_axi;
  end
  always #1.7 begin
    if (PARA_ASYNC != 0)
      clk_axi = ~clk_axi;
  end
  always #10 clk_apb = ~clk_apb;

  // APB
  logic        psel = 0;
  logic        penable = 0;
  logic        pwrite = 0;
  logic [15:0] paddr = 0;
  logic [31:0] pwdata = 0;
  logic [3:0]  pstrb = 4'hF;
  logic [31:0] prdata;
  logic        pready;
  logic        pslverr;

  // AXI
  logic [3:0]  awid = 0;
  logic [31:0] awaddr = 0;
  logic [7:0]  awlen = 0;
  logic [2:0]  awsize = 0;
  logic [1:0]  awburst = 0;
  logic        awvalid = 0;
  logic        awready;
  logic [PARA_AXI_W-1:0]  wdata = 0;
  logic [LPARA_BUSB-1:0] wstrb = 0;
  logic        wlast = 0;
  logic        wvalid = 0;
  logic        wready;
  logic [3:0]  bid;
  logic [1:0]  bresp;
  logic        bvalid;
  logic        bready = 1;
  logic [3:0]  arid = 0;
  logic [31:0] araddr = 0;
  logic [7:0]  arlen = 0;
  logic [2:0]  arsize = 0;
  logic [1:0]  arburst = 0;
  logic        arvalid = 0;
  logic        arready;
  logic [3:0]  rid;
  logic [PARA_AXI_W-1:0]  rdata;
  logic [1:0]  rresp;
  logic        rlast;
  logic        rvalid;
  logic        rready = 1;

  // Memory side
  logic                    pwr_good = 1;
  wire                     rst_n_mem;
  wire  [PARA_NCS-1:0]        cs_n;
  wire                     ck;
  wire                     ckn;
  wire  [PARA_DQ-1:0]         dq_o;
  wire  [PARA_DQ-1:0]         dq_oe;
  wire  [PARA_DQ/8-1:0]       rwds_o;
  wire  [PARA_DQ/8-1:0]       rwds_oe;
  wire  [3:0]              dly_sel;
  wire                     irq;
  wire                     idle;
  logic                    no_data = 0;
  logic                    force_collide = 0;

  // Device outputs merged on the shared pins
  reg   [PARA_DQ-1:0]         dq_in;
  reg   [PARA_DQ/8-1:0]       rwds_in;
  wire  [PARA_NCS*PARA_DQ-1:0]   m_dq;
  wire  [PARA_NCS-1:0]        m_dq_oe;
  wire  [PARA_NCS*(PARA_DQ/8)-1:0] m_rwds;
  wire  [PARA_NCS-1:0]        m_rwds_oe;
  wire                     cap;

  always @* begin
    dq_in = '0;
    rwds_in = '0;
    for (int q = 0; q < PARA_NCS; q++) begin
      if (m_dq_oe[q])
        dq_in = dq_in | m_dq[q*PARA_DQ +: PARA_DQ];
      if (m_rwds_oe[q])
        rwds_in = rwds_in | m_rwds[q*(PARA_DQ/8) +: PARA_DQ/8];
    end
  end
  assign #1.25 cap = rwds_in[0];

  m_vlsit_hyperram_controller #(
    .PARA_AXI_DATA_W     (32'(PARA_AXI_W)),
    .PARA_MEM_DQ_W       (32'(PARA_DQ)),
    .PARA_MEM_SIZE_BYTES (32'(LPARA_MEM_B)),
    .PARA_AXI_CLK_ASYNC  (32'(PARA_ASYNC)),
    .PARA_NUM_CS         (32'(PARA_NCS))
  ) u_dut (
    .i_clk_core(clk_core), .i_clk_axi(clk_axi), .i_clk_apb(clk_apb),
    .i_rst_n_core(rst_n_core), .i_rst_n_axi(rst_n_axi), .i_rst_n_apb(rst_n_apb),
    .i_apb_psel(psel), .i_apb_penable(penable), .i_apb_pwrite(pwrite), .i_apb_paddr(paddr),
    .i_apb_pwdata(pwdata), .i_apb_pstrb(pstrb), .i_apb_pprot(3'b0),
    .o_apb_pready(pready), .o_apb_prdata(prdata), .o_apb_pslverr(pslverr),
    .i_axi_awid(awid), .i_axi_awaddr(awaddr), .i_axi_awlen(awlen), .i_axi_awsize(awsize),
    .i_axi_awburst(awburst), .i_axi_awvalid(awvalid), .o_axi_awready(awready),
    .i_axi_wdata(wdata), .i_axi_wstrb(wstrb), .i_axi_wlast(wlast), .i_axi_wvalid(wvalid),
    .o_axi_wready(wready),
    .o_axi_bid(bid), .o_axi_bresp(bresp), .o_axi_bvalid(bvalid), .i_axi_bready(bready),
    .i_axi_arid(arid), .i_axi_araddr(araddr), .i_axi_arlen(arlen), .i_axi_arsize(arsize),
    .i_axi_arburst(arburst), .i_axi_arvalid(arvalid), .o_axi_arready(arready),
    .o_axi_rid(rid), .o_axi_rdata(rdata), .o_axi_rresp(rresp), .o_axi_rlast(rlast),
    .o_axi_rvalid(rvalid), .i_axi_rready(rready),
    .i_mem_pwr_good(pwr_good), .o_rst_n_mem(rst_n_mem), .o_hb_cs_n(cs_n),
    .o_clk_hb(ck), .o_clk_hb_n(ckn),
    .i_hb_dq(dq_in), .o_hb_dq(dq_o), .o_hb_dq_oe(dq_oe),
    .i_hb_rwds(rwds_in), .o_hb_rwds(rwds_o), .o_hb_rwds_oe(rwds_oe),
    .i_clk_cap(cap), .o_hb_rwds_dly_sel(dly_sel), .o_int_hyperram(irq), .o_idle(idle)
  );

  generate for (genvar g = 0; g < PARA_NCS; g++) begin : gen_dev
    m_vlsit_hr_model #(
      .PARA_DQ_W (PARA_DQ),
      .PARA_MEM_B(LPARA_MEM_B)
    ) u_dev (
      .i_rst_n_mem(rst_n_mem), .i_cs_n(cs_n[g]), .i_ck(ck),
      .i_dq(dq_o), .i_rwds(rwds_o),
      .o_dq(m_dq[g*PARA_DQ +: PARA_DQ]), .o_dq_oe(m_dq_oe[g]),
      .o_rwds(m_rwds[g*(PARA_DQ/8) +: PARA_DQ/8]), .o_rwds_oe(m_rwds_oe[g]),
      .i_no_data(no_data), .i_force_collide(force_collide)
    );
  end endgenerate

  // ----------------------------------------------------------------------------------------
  // Bookkeeping
  // ----------------------------------------------------------------------------------------
  int errors = 0;
  int last_addr = 0;
  int last_len = 0;
  int last_size = 0;
  int last_burst = 0;
  int last_beat = 0;
  int n_checked = 0;
  int n_wr = 0;
  int n_rd = 0;
  logic [7:0] ref_mem [0:LPARA_REFB-1];
  bit         ref_wr  [0:LPARA_REFB-1];

  task automatic fail(input string msg);
    $display("ERR %s", msg);
    errors++;
  endtask

  // ----------------------------------------------------------------------------------------
  // APB tasks
  // ----------------------------------------------------------------------------------------
  logic apb_err = 0;

  task automatic apb_wr(input [15:0] a, input [31:0] d, input [3:0] st = 4'hF);
    @(posedge clk_apb);
    #1;
    psel = 1; pwrite = 1; paddr = a; pwdata = d; pstrb = st; penable = 0;
    @(posedge clk_apb);
    #1;
    penable = 1;
    do @(posedge clk_apb); while (!pready);
    apb_err = pslverr;
    #1;
    psel = 0; penable = 0; pstrb = 4'hF;
  endtask

  task automatic apb_rd(input [15:0] a, output [31:0] d);
    @(posedge clk_apb);
    #1;
    psel = 1; pwrite = 0; paddr = a; penable = 0;
    @(posedge clk_apb);
    #1;
    penable = 1;
    do @(posedge clk_apb); while (!pready);
    d = prdata;
    apb_err = pslverr;
    #1;
    psel = 0; penable = 0;
  endtask

  task automatic apb_chk(input [15:0] a, input [31:0] exp, input [31:0] mask);
    logic [31:0] v;
    apb_rd(a, v);
    if ((v & mask) !== (exp & mask))
      fail($sformatf("apb read %04h got %08h exp %08h mask %08h", a, v, exp, mask));
  endtask

  // ----------------------------------------------------------------------------------------
  // Controller start-up
  // ----------------------------------------------------------------------------------------
  // fixed: fixed latency, lat: init_lat, posted: hr_ctrl.wr_posted, merge: merge_en, arb: arb_mode
  task automatic ctrl_start(input bit fixed, input int lat, input bit posted, input bit merge,
                            input int arb, input int tmo = 512, input int idchk = 0,
                            input int tmo_act = 0);
    logic [31:0] v;
    apb_wr(16'h0000, 32'h0);
    repeat (40) @(posedge clk_apb);
    for (int d = 0; d < PARA_NCS; d++)
      apb_wr(16'h0100 + 16'(d * 16'h100), 32'h0001C000 | (32'(fixed) << 10) | (32'(lat) << 5));
    for (int d = 0; d < PARA_NCS; d++) begin
      apb_wr(16'h0120 + 16'(d * 16'h100), 32'(tmo));
      apb_wr(16'h011C + 16'(d * 16'h100),
             (idchk == 1) ? 32'h0001_0E86 : (idchk == 2) ? 32'h0001_1234 : 32'h0);
    end
    apb_wr(16'h0010, 32'h0000_0102);
    apb_wr(16'h0000, 32'h1 | (32'(posted) << 1) | (32'(arb) << 2) | (32'(merge) << 4) |
                     (32'(tmo_act) << 5));
    begin : wait_init
      for (int i = 0; i < 6000; i++) begin
        apb_rd(16'h0004, v);
        if (v[1])
          disable wait_init;
        repeat (50) @(posedge clk_apb);
      end
      fail($sformatf("init_done timeout hr_sts=%08h", v));
    end
  endtask

  // ----------------------------------------------------------------------------------------
  // AXI address and lane rules (AMBA AXI4: A3.4.1)
  // ----------------------------------------------------------------------------------------
  function automatic int f_beat_addr(input int addr, input int len, input int size, input int burst,
                                     input int i);
    int nb;
    int wb;
    int wa;
    begin
      nb = 1 << size;
      if (burst == 2'b10) begin
        wb = nb * (len + 1);
        wa = (addr / wb) * wb;
        f_beat_addr = wa + ((addr - wa + i * nb) % wb);
      end else if (burst == 2'b00 || i == 0) begin
        f_beat_addr = addr;
      end else begin
        f_beat_addr = (addr / nb) * nb + i * nb;
      end
    end
  endfunction

  // Write burst with random data. exp: expected BRESP. Updates the reference memory on OKAY.
  task automatic axi_wr(input int addr, input int len, input int size, input int burst,
                        input int id, input int exp, input bit full_strb);
    logic [PARA_AXI_W-1:0]   dat [0:255];
    logic [LPARA_BUSB-1:0] stb [0:255];
    last_addr = addr; last_len = len; last_size = size; last_burst = burst;
    $display("%0t WR addr=%0h len=%0d size=%0d burst=%0d exp=%0d", $time, addr, len, size, burst, exp);
    for (int i = 0; i <= len; i++) begin
      for (int w = 0; w < PARA_AXI_W / 32; w++)
        dat[i][32*w +: 32] = $urandom;
      stb[i] = '1;
      if (!full_strb && ($urandom % 3 == 0))
        stb[i] = LPARA_BUSB'($urandom);
    end
    fork
      begin
        @(posedge clk_axi);
        #1;
        awvalid = 1; awaddr = 32'(addr); awlen = 8'(len); awsize = 3'(size); awburst = 2'(burst);
        awid = 4'(id);
        do @(posedge clk_axi); while (!awready);
        #1;
        awvalid = 0;
      end
      begin
        @(posedge clk_axi);
        #1;
        for (int i = 0; i <= len; i++) begin
          if (PARA_GAPS != 0 && ($urandom % 8 == 0)) begin
            wvalid = 0;
            repeat (1 + $urandom % 4) @(posedge clk_axi);
            #1;
          end
          wvalid = 1; wdata = dat[i]; wstrb = stb[i]; wlast = (i == len);
          last_beat = i;
          do @(posedge clk_axi); while (!wready);
          #1;
        end
        wvalid = 0; wlast = 0;
      end
    join
    while (!bvalid) @(posedge clk_axi);
    if (bresp !== 2'(exp))
      fail($sformatf("bresp %0d exp %0d addr %0h len %0d size %0d burst %0d", bresp, exp, addr, len, size, burst));
    if (bid !== 4'(id))
      fail($sformatf("bid %0d exp %0d", bid, id));
    @(posedge clk_axi);
    n_wr++;
    if (exp == 0) begin
      for (int i = 0; i <= len; i++) begin
        int ba;
        int nb;
        int lo;
        int hi;
        ba = f_beat_addr(addr, len, size, burst, i);
        nb = 1 << size;
        lo = ba % LPARA_BUSB;
        hi = ((ba / nb) * nb) % LPARA_BUSB + nb;
        for (int l = lo; l < hi; l++) begin
          if (stb[i][l] && ((ba / LPARA_BUSB) * LPARA_BUSB + l) < LPARA_REFB) begin
            ref_mem[(ba / LPARA_BUSB) * LPARA_BUSB + l] = dat[i][8*l +: 8];
            ref_wr[(ba / LPARA_BUSB) * LPARA_BUSB + l] = 1;
          end
        end
      end
    end
  endtask

  // Read burst; checks every byte that was written, RLAST, RID and RRESP
  task automatic axi_rd(input int addr, input int len, input int size, input int burst,
                        input int id, input int exp);
    int cnt;
    $display("%0t RD addr=%0h len=%0d size=%0d burst=%0d exp=%0d", $time, addr, len, size, burst, exp);
    @(posedge clk_axi);
    #1;
    arvalid = 1; araddr = 32'(addr); arlen = 8'(len); arsize = 3'(size); arburst = 2'(burst);
    arid = 4'(id);
    do @(posedge clk_axi); while (!arready);
    #1;
    arvalid = 0;
    cnt = 0;
    while (cnt <= len) begin
      @(posedge clk_axi);
      if (rvalid && rready) begin
        int ba;
        int nb;
        int lo;
        int hi;
        ba = f_beat_addr(addr, len, size, burst, cnt);
        nb = 1 << size;
        lo = ba % LPARA_BUSB;
        hi = ((ba / nb) * nb) % LPARA_BUSB + nb;
        if (rresp !== 2'(exp))
          fail($sformatf("rresp %0d exp %0d beat %0d addr %0h", rresp, exp, cnt, addr));
        if (rid !== 4'(id))
          fail($sformatf("rid %0d exp %0d", rid, id));
        if (rlast !== (cnt == len))
          fail($sformatf("rlast beat %0d", cnt));
        if (exp == 0) begin
          for (int l = lo; l < hi; l++) begin
            int ra;
            ra = (ba / LPARA_BUSB) * LPARA_BUSB + l;
            if (ra < LPARA_REFB && ref_wr[ra]) begin
              n_checked++;
              if (rdata[8*l +: 8] !== ref_mem[ra])
                fail($sformatf("rd addr %0h got %02h exp %02h", ra, rdata[8*l +: 8], ref_mem[ra]));
            end
          end
        end
        cnt++;
      end
    end
    n_rd++;
  endtask

  // Random legal burst inside [base, base + span): size, length and burst type are random
  task automatic rand_burst(input int base, input int span, output int addr, output int len,
                            output int size, output int burst);
    int nb;
    int bytes;
    size = $urandom % (LPARA_MAXSZ + 1);
    nb = 1 << size;
    burst = ($urandom % 4 == 0) ? 2 : 1;
    if (burst == 2) begin
      len = (1 << ($urandom % 4)) - 1;
      if (len == 0)
        len = 1;
    end else begin
      len = $urandom % 16;
    end
    bytes = nb * (len + 1);
    addr = base + ($urandom % (span - bytes - 8));
    if (burst == 2)
      addr = (addr / nb) * nb;
    else if ($urandom % 2 == 0)
      addr = (addr / nb) * nb;
    // an INCR burst must not cross a 4 KB boundary
    if (burst == 1 && ((addr / 4096) != ((addr + bytes - 1) / 4096)))
      addr = (addr / 4096) * 4096;
  endtask

  // ----------------------------------------------------------------------------------------
  // Scenarios
  // ----------------------------------------------------------------------------------------
  task automatic traffic(input int n, input int base, input int span);
    int a;
    int l;
    int s;
    int b;
    for (int t = 0; t < n; t++) begin
      rand_burst(base, span, a, l, s, b);
      axi_wr(a, l, s, b, $urandom % 16, 0, 1'b0);
      rand_burst(base, span, a, l, s, b);
      axi_rd(a, l, s, b, $urandom % 16, 0);
    end
    for (int blk = 0; blk < span / 256; blk++)
      axi_rd(base + blk * 256, 63, 2, 1, blk % 16, 0);
  endtask

  // Concurrent write and read to different regions
  task automatic mixed_traffic(input int n);
    int a;
    int l;
    int s;
    int b;
    int a2;
    int l2;
    int s2;
    int b2;
    for (int t = 0; t < n; t++) begin
      rand_burst(8192, 8192, a, l, s, b);
      rand_burst(24576, 8192, a2, l2, s2, b2);
      fork
        axi_wr(a, l, s, b, 3, 0, 1'b0);
        axi_rd(a2, l2, s2, b2, 5, 0);
      join
    end
  endtask

  task automatic error_cases;
    // out of aperture: DECERR for read and write; FIXED burst: SLVERR
    axi_wr(PARA_NCS * LPARA_MEM_B, 3, 2, 1, 1, 3, 1'b1);
    axi_rd(PARA_NCS * LPARA_MEM_B + 64, 3, 2, 1, 2, 3);
    axi_wr(PARA_NCS * LPARA_MEM_B - 4, 3, 2, 1, 4, 3, 1'b1);
    axi_wr(128, 3, 2, 0, 5, 2, 1'b1);
    axi_rd(128, 3, 2, 0, 6, 2);
  endtask

  task automatic csr_access;
    logic [31:0] v;
    apb_chk(16'h0008, 32'h0, 32'h0);
    apb_rd(16'h0008, v);
    apb_rd(16'h000C, v);
    apb_rd(16'h0004, v);
    // unmapped address: PSLVERR (REQ-CSR-005)
    apb_rd(16'h0F00, v);
    if (!apb_err)
      fail("no PSLVERR on a read of an unmapped address");
    apb_wr(16'h0F00, 32'h1);
    if (!apb_err)
      fail("no PSLVERR on a write to an unmapped address");
    // address not word aligned: PSLVERR
    apb_rd(16'h0006, v);
    if (!apb_err)
      fail("no PSLVERR on an unaligned read");
    // write with PSTRB not all ones: PSLVERR and no change (Section 11.4)
    apb_wr(16'h0028, 32'h0000_01FF, 4'h1);
    if (!apb_err)
      fail("no PSLVERR on a write with partial strobes");
    apb_chk(16'h0028, 32'h0000_0000, 32'h0000_01FF);
    // read-only register write: no change
    apb_wr(16'h0004, 32'hFFFF_FFFF);
    apb_wr(16'h0028, 32'h0000_01FF);
    if (apb_err)
      fail("PSLVERR on a normal write");
    apb_chk(16'h0028, 32'h0000_01FF, 32'h0000_01FF);
    // interrupt injection, mask, clear
    apb_wr(16'h0030, 32'h0000_0020);
    apb_rd(16'h0024, v);
    apb_rd(16'h002C, v);
    apb_wr(16'h0030, 32'h0);
    apb_wr(16'h0024, 32'h0000_01FF);
    apb_wr(16'h0028, 32'h0);
    // error counters and logs
    apb_rd(16'h0034, v);
    apb_rd(16'h0038, v);
    apb_rd(16'h003C, v);
    apb_rd(16'h0040, v);
    apb_rd(16'h0044, v);
    apb_rd(16'h0048, v);
    apb_rd(16'h004C, v);
    apb_rd(16'h0124, v);
    apb_rd(16'h011C, v);
    apb_rd(16'h0120, v);
  endtask

  // Device command port: register read and write (REQ-MEM-013)
  task automatic cmd_port;
    logic [31:0] v;
    // read ID0 of device 0
    apb_wr(16'h0018, 32'h0000_0000);
    apb_wr(16'h0014, 32'h0000_0001);
    repeat (200) @(posedge clk_apb);
    apb_rd(16'h0020, v);
    apb_wr(16'h0020, 32'h0003_0000);
    // write CR1, then read it
    apb_wr(16'h0018, 32'h0000_0801);
    apb_wr(16'h001C, 32'h0000_FFF3);
    apb_wr(16'h0014, 32'h0000_0003);
    repeat (200) @(posedge clk_apb);
    apb_wr(16'h0014, 32'h0000_0001);
    repeat (200) @(posedge clk_apb);
    apb_rd(16'h0020, v);
    apb_wr(16'h0020, 32'h0003_0000);
    // command on an unused chip select (when only one exists) and before it is allowed
    apb_wr(16'h0014, 32'h0000_0005);
    repeat (200) @(posedge clk_apb);
    apb_wr(16'h0020, 32'h0003_0000);
  endtask

  // Walking patterns through every timing and configuration register while the controller is
  // disabled, then the reset values again (each field of the register map toggles both ways).
  task automatic csr_walk;
    logic [31:0] pat [0:3];
    pat[0] = 32'hFFFF_FFFF;
    pat[1] = 32'h5555_5555;
    pat[2] = 32'hAAAA_AAAA;
    pat[3] = 32'h0000_0000;
    apb_wr(16'h0000, 32'h0);
    for (int k = 0; k < 4; k++) begin
      for (int d = 0; d < 2; d++) begin
        for (int r = 0; r < 9; r++)
          apb_wr(16'h0100 + 16'(d * 16'h100) + 16'(r * 4), pat[k]);
      end
      apb_wr(16'h0010, pat[k]);
      apb_wr(16'h0014, pat[k] & 32'h6);
      apb_wr(16'h0018, pat[k]);
      apb_wr(16'h001C, pat[k]);
      apb_wr(16'h0028, pat[k]);
      apb_wr(16'h0030, pat[k]);
    end
    apb_wr(16'h0014, 32'h0);
    apb_wr(16'h0030, 32'h0);
    apb_wr(16'h0028, 32'h0);
    for (int d = 0; d < 2; d++) begin
      apb_wr(16'h0100 + 16'(d * 16'h100), 32'h0001_C4E0);
      apb_wr(16'h0104 + 16'(d * 16'h100), 32'h0050_0050);
      apb_wr(16'h0108 + 16'(d * 16'h100), 32'h0000_00A0);
      apb_wr(16'h010C + 16'(d * 16'h100), 32'h0000_9C40);
      apb_wr(16'h0110 + 16'(d * 16'h100), 32'h0001_0702);
      apb_wr(16'h0114 + 16'(d * 16'h100), 32'h0000_00A0);
      apb_wr(16'h0118 + 16'(d * 16'h100), 32'h0);
      apb_wr(16'h011C + 16'(d * 16'h100), 32'h0);
      apb_wr(16'h0120 + 16'(d * 16'h100), 32'h0000_0200);
    end
    apb_wr(16'h0010, 32'h0000_0002);
    apb_wr(16'h0018, 32'h0);
    apb_wr(16'h001C, 32'h0);
  endtask

  // Interrupt registers: injection of every cause, mask, status and clear (REQ-CSR-004)
  task automatic irq_walk;
    logic [31:0] v;
    apb_wr(16'h0028, 32'h0000_01FF);
    for (int k = 0; k < 9; k++) begin
      apb_wr(16'h0030, 32'h1 << k);
      apb_rd(16'h0024, v);
      if (v[k] !== 1'b1)
        fail($sformatf("injected cause %0d not in hr_irq_raw (%08h)", k, v));
      apb_rd(16'h002C, v);
      if (v[k] !== 1'b1)
        fail($sformatf("injected cause %0d not in hr_irq_sts (%08h)", k, v));
      if (irq !== 1'b1)
        fail($sformatf("o_int_hyperram not set for cause %0d", k));
      apb_wr(16'h0030, 32'h0);
      apb_wr(16'h0024, 32'h1 << k);
      apb_rd(16'h0024, v);
      if (v[k] !== 1'b0)
        fail($sformatf("cause %0d not cleared (%08h)", k, v));
    end
    apb_wr(16'h0030, 32'h0000_01FF);
    apb_wr(16'h0028, 32'h0000_0000);
    apb_chk(16'h002C, 32'h0, 32'h1FF);
    apb_wr(16'h0030, 32'h0);
    apb_wr(16'h0024, 32'h0000_01FF);
  endtask

  // Traffic over a wide address range so that every address bit changes
  task automatic wide_traffic(input int n);
    int bases [0:5];
    bases[0] = 32'h0001_5000;
    bases[1] = 32'h0002_A000;
    bases[2] = 32'h0003_F000 - 4096;
    bases[3] = LPARA_MEM_B - 8192;
    bases[4] = (PARA_NCS - 1) * LPARA_MEM_B + 32'h0000_2000;
    bases[5] = PARA_NCS * LPARA_MEM_B - 8192;
    for (int k = 0; k < 6; k++)
      traffic(n, bases[k], 8192);
  endtask

  // Device timeout (ERR-008): the device stops answering during a read and during a write
  task automatic timeout_test(input int act);
    logic [31:0] v;
    ctrl_start(1'b0, 4, 1'b0, 1'b1, 0, 48, 0, act);
    apb_wr(16'h0028, 32'h0000_01FF);
    no_data = 1;
    axi_rd(512, 7, 2, 1, 7, 2);
    no_data = 0;
    repeat (200) @(posedge clk_apb);
    apb_rd(16'h0048, v);
    apb_rd(16'h004C, v);
    apb_rd(16'h0004, v);
    apb_rd(16'h0024, v);
    if (!v[8])
      fail($sformatf("no timeout cause in hr_irq_raw (%08h)", v));
    if (act == 0) begin
      apb_wr(16'h0048, 32'h1);
      apb_wr(16'h0024, 32'h0000_01FF);
      apb_wr(16'h0000, 32'h0000_0051);
      repeat (400) @(posedge clk_apb);
    end else begin
      begin : wait_reinit
        for (int i = 0; i < 6000; i++) begin
          apb_rd(16'h0004, v);
          if (v[1])
            disable wait_reinit;
          repeat (50) @(posedge clk_apb);
        end
        fail($sformatf("no re-initialization after the timeout hr_sts=%08h", v));
      end
      apb_wr(16'h0024, 32'h0000_01FF);
    end
    // a write needs no device answer after the command phase, so it still completes with OKAY
    no_data = 1;
    axi_wr(1024, 3, 2, 1, 8, 0, 1'b1);
    no_data = 0;
    repeat (200) @(posedge clk_apb);
    apb_wr(16'h0048, 32'h1);
    apb_wr(16'h0024, 32'h0000_01FF);
    apb_wr(16'h0000, 32'h0000_0051);
    repeat (400) @(posedge clk_apb);
  endtask

  // Command port on every chip select, latency mismatch, ID check (REQ-MEM-013 to REQ-MEM-015)
  task automatic cmd_port_more;
    logic [31:0] v;
    for (int c = 0; c < PARA_NCS; c++) begin
      apb_wr(16'h0018, 32'h0000_0000);
      apb_wr(16'h0014, 32'h1 | (32'(c) << 2));
      repeat (300) @(posedge clk_apb);
      apb_wr(16'h0020, 32'h0003_0000);
      apb_wr(16'h0018, 32'h0000_0800);
      apb_wr(16'h0014, 32'h1 | (32'(c) << 2));
      repeat (300) @(posedge clk_apb);
      apb_rd(16'h0020, v);
      apb_wr(16'h0020, 32'h0003_0000);
      // write CR0 with a latency code that differs from init_lat: lat_mis
      apb_wr(16'h0018, 32'h0000_0800);
      apb_wr(16'h001C, 32'h0000_8F0F);
      apb_wr(16'h0014, 32'h3 | (32'(c) << 2));
      repeat (300) @(posedge clk_apb);
      apb_wr(16'h0020, 32'h0003_0000);
      // restore the old CR0
      apb_wr(16'h001C, 32'h0000_8F1F);
      apb_wr(16'h0014, 32'h3 | (32'(c) << 2));
      repeat (300) @(posedge clk_apb);
      apb_wr(16'h0020, 32'h0003_0000);
    end
    apb_rd(16'h0024, v);
    apb_wr(16'h0024, 32'h0000_01FF);
  endtask

  // Power-good loss while enabled (REQ-PWR-001), core reset and APB reset
  task automatic power_and_reset;
    logic [31:0] v;
    pwr_good = 0;
    repeat (100) @(posedge clk_apb);
    apb_rd(16'h0024, v);
    if (!v[4])
      fail($sformatf("no pwr_lost cause after the loss of power good (%08h)", v));
    apb_rd(16'h0004, v);
    pwr_good = 1;
    repeat (100) @(posedge clk_apb);
    apb_wr(16'h0024, 32'h0000_01FF);
    // core reset while idle, then the APB reset alone
    rst_n_core = 0;
    rst_n_axi = 0;
    #40;
    rst_n_core = 1;
    rst_n_axi = 1;
    repeat (20) @(posedge clk_apb);
    for (int i = 0; i < LPARA_REFB; i++)
      ref_wr[i] = 0;
    rst_n_apb = 0;
    #60;
    rst_n_apb = 1;
    repeat (20) @(posedge clk_apb);
    ctrl_start(1'b0, 6, 1'b0, 1'b1, 0);
    traffic(4, 0, 8192);
  endtask

  initial begin
    logic [31:0] v;
    int a;
    int l;
    int s;
    int b;
    $display("TB start");
    for (int i = 0; i < LPARA_REFB; i++) begin
      ref_mem[i] = 0;
      ref_wr[i] = 0;
    end
    #10;
    $display("TB reset");
    rst_n_core = 0; rst_n_axi = 0; rst_n_apb = 0;
    #100;
    rst_n_core = 1; rst_n_axi = 1; rst_n_apb = 1;
    #100;
    $display("PHASE csr_access");
    csr_access();
    // command before initialization is refused (ERR-006)
    apb_wr(16'h0014, 32'h1);
    repeat (50) @(posedge clk_apb);
    apb_chk(16'h0020, 32'h0002_0000, 32'h0002_0000);
    apb_wr(16'h0020, 32'h0003_0000);
    $display("PHASE csr_walk");
    csr_walk();
    $display("PHASE 1 fixed latency");
    // 1: fixed latency, 7 CK, default arbitration, merge on
    ctrl_start(1'b1, 7, 1'b0, 1'b1, 0);
    apb_wr(16'h0028, 32'h0000_01FF);
    traffic(PARA_NTEST, 0, 8192);
    $display("PHASE error_cases");
    error_cases();
    $display("PHASE cmd_port");
    cmd_port();
    // 2: variable latency, posted writes, read priority
    $display("PHASE 2");
    ctrl_start(1'b0, 5, 1'b1, 1'b1, 1);
    mixed_traffic(PARA_NTEST / 2);
    traffic(PARA_NTEST / 2, 0, 8192);
    // 3: variable latency with forced collisions, write priority, no merge
    $display("PHASE 3");
    force_collide = 1;
    ctrl_start(1'b0, 4, 1'b0, 1'b0, 2);
    mixed_traffic(PARA_NTEST / 2);
    traffic(PARA_NTEST / 2, 0, 8192);
    force_collide = 0;
    // 4: latency 3 and 8
    $display("PHASE 4");
    ctrl_start(1'b0, 3, 1'b0, 1'b1, 0);
    traffic(PARA_NTEST / 4, 0, 8192);
    ctrl_start(1'b1, 8, 1'b0, 1'b1, 0);
    traffic(PARA_NTEST / 4, 0, 8192);
    $display("PHASE wide addresses");
    ctrl_start(1'b0, 7, 1'b0, 1'b1, 0);
    wide_traffic(PARA_NTEST / 4);
    $display("PHASE irq");
    irq_walk();
    $display("PHASE cmd_port_more");
    cmd_port_more();
    $display("PHASE id mismatch");
    ctrl_start(1'b0, 7, 1'b0, 1'b1, 0, 512, 2);
    apb_rd(16'h0024, v);
    if (!v[5])
      fail($sformatf("no id_mis cause (%08h)", v));
    apb_wr(16'h0024, 32'h0000_01FF);
    ctrl_start(1'b0, 7, 1'b0, 1'b1, 0, 512, 1);
    apb_rd(16'h0024, v);
    if (v[5])
      fail($sformatf("id_mis with a matching ID (%08h)", v));
    apb_wr(16'h0024, 32'h0000_01FF);
    $display("PHASE timeout hold");
    timeout_test(0);
    traffic(4, 0, 8192);
    $display("PHASE timeout reinit");
    timeout_test(1);
    traffic(4, 0, 8192);
    $display("PHASE power and reset");
    power_and_reset();
    repeat (500) @(posedge clk_core);
    apb_rd(16'h0034, v);
    $display("hr_err_cnt=%08h checked_bytes=%0d writes=%0d reads=%0d", v, n_checked, n_wr, n_rd);
    if (errors == 0)
      $display("COV TB PASS");
    else
      $display("COV TB FAIL errors=%0d", errors);
    $finish;
  end

  initial begin
    #60_000_000;
    $display("stuck: awv=%b awr=%b wv=%b wr=%b bv=%b arv=%b arr=%b rv=%b idle=%b cs_n=%b rst_mem=%b irq=%b",
            awvalid, awready, wvalid, wready, bvalid, arvalid, arready, rvalid, idle, cs_n, rst_n_mem, irq);
    $display("last write addr=%0h len=%0d size=%0d burst=%0d beat=%0d", last_addr, last_len, last_size, last_burst, last_beat);
    $display("COV TB FAIL global timeout");
    $finish;
  end

// verilator coverage_on
endmodule
