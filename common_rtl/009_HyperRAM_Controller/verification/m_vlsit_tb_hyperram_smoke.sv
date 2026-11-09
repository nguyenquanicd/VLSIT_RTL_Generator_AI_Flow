/*
 * Project      : HyperRAM Controller
 * Author       : Nguyen Quan (user)
 * AI Flow      : VLSIT RTL Generator AI Automation Flow
 * AI Flow Page : https://github.com/nguyenquanicd/VLSIT_RTL_Generator_AI_Model
 * Date         : 2026-11-04
 * Description  : Smoke and random-burst testbench of m_vlsit_hyperram_controller against the
 *                Infineon S27KS0641 model (verification code, not synthesizable).
 */
`timescale 1ns/1ps
`ifdef X16
`define LPARA_DQW 16
`define MEMB 16777216
`else
`define LPARA_DQW 8
`define MEMB 8388608
`endif
`ifndef INIT_LAT
`define INIT_LAT 4
`endif
// Smoke testbench: m_vlsit_hyperram_controller (x8, AXI 32, 1 CS) against the Infineon
// S27KS0641 model.
module m_vlsit_tb_hyperram_smoke ();
  localparam int LPARA_CORE_HALF = 2.5;
  logic clk_core = 0, clk_apb = 0;
  logic rst_n_core = 1, rst_n_apb = 1;
  always #(2.5) clk_core = ~clk_core;
  always #(10)  clk_apb  = ~clk_apb;

  logic        psel = 0, penable = 0, pwrite = 0;
  logic [15:0] paddr = 0;
  logic [31:0] pwdata = 0, prdata;
  logic        pready, pslverr;

  logic [3:0]  awid = 0, arid = 0;
  logic [31:0] awaddr = 0, araddr = 0;
  logic [7:0]  awlen = 0, arlen = 0;
  logic        awvalid = 0, awready, wvalid = 0, wready, wlast = 0, bready = 1, bvalid;
  logic        arvalid = 0, arready, rready = 1, rvalid, rlast;
  logic [31:0] wdata = 0, rdata;
  logic [3:0]  wstrb = 4'hF, bid, rid;
  logic [1:0]  bresp, rresp;

  wire        rst_n_mem;
  wire [0:0]  cs_n;
  wire        ck, ckn;
  localparam int LPARA_DQW = `LPARA_DQW;
  localparam int LPARA_RWW = LPARA_DQW / 8;
  wire [LPARA_DQW-1:0] dq_o, dq_oe;
  wire [LPARA_RWW-1:0] rwds_o, rwds_oe;
  wire [LPARA_DQW-1:0] w_dq;
  tri  [LPARA_RWW-1:0] w_rwds;
  wire        cap;
  wire [3:0]  dly_sel;
  wire        irq, idle;

  // read capture clock: RWDS (lane 0) delayed by a quarter of the CK period (CK = 100 MHz)
  assign #2.5 cap = w_rwds[0];

  m_vlsit_hyperram_controller #(
    .PARA_AXI_DATA_W(32'd32), .PARA_MEM_DQ_W(32'(LPARA_DQW)), .PARA_MEM_SIZE_BYTES(32'(`MEMB)),
    .PARA_AXI_CLK_ASYNC(32'd0), .PARA_NUM_CS(32'd1)
  ) u_dut (
    .i_clk_core(clk_core), .i_clk_axi(clk_core), .i_clk_apb(clk_apb),
    .i_rst_n_core(rst_n_core), .i_rst_n_axi(rst_n_core), .i_rst_n_apb(rst_n_apb),
    .i_apb_psel(psel), .i_apb_penable(penable), .i_apb_pwrite(pwrite), .i_apb_paddr(paddr),
    .i_apb_pwdata(pwdata), .i_apb_pstrb(4'hF), .i_apb_pprot(3'b0),
    .o_apb_pready(pready), .o_apb_prdata(prdata), .o_apb_pslverr(pslverr),
    .i_axi_awid(awid), .i_axi_awaddr(awaddr), .i_axi_awlen(awlen), .i_axi_awsize(3'd2),
    .i_axi_awburst(2'b01), .i_axi_awvalid(awvalid), .o_axi_awready(awready),
    .i_axi_wdata(wdata), .i_axi_wstrb(wstrb), .i_axi_wlast(wlast), .i_axi_wvalid(wvalid),
    .o_axi_wready(wready),
    .o_axi_bid(bid), .o_axi_bresp(bresp), .o_axi_bvalid(bvalid), .i_axi_bready(bready),
    .i_axi_arid(arid), .i_axi_araddr(araddr), .i_axi_arlen(arlen), .i_axi_arsize(3'd2),
    .i_axi_arburst(2'b01), .i_axi_arvalid(arvalid), .o_axi_arready(arready),
    .o_axi_rid(rid), .o_axi_rdata(rdata), .o_axi_rresp(rresp), .o_axi_rlast(rlast),
    .o_axi_rvalid(rvalid), .i_axi_rready(rready),
    .i_mem_pwr_good(1'b1), .o_rst_n_mem(rst_n_mem), .o_hb_cs_n(cs_n),
    .o_clk_hb(ck), .o_clk_hb_n(ckn),
    .i_hb_dq(w_dq), .o_hb_dq(dq_o), .o_hb_dq_oe(dq_oe),
    .i_hb_rwds(w_rwds), .o_hb_rwds(rwds_o), .o_hb_rwds_oe(rwds_oe),
    .i_clk_cap(cap), .o_hb_rwds_dly_sel(dly_sel), .o_int_hyperram(irq), .o_idle(idle)
  );

`ifdef X16
  m_vlsit_hr_x16_from_x8 u_mem (
    .i_cs_n(cs_n[0]), .i_ck(ck), .i_ck_n(ckn), .i_rst_n_mem(rst_n_mem),
    .i_dq(dq_o), .i_dq_oe(dq_oe), .o_dq(w_dq),
    .i_rwds(rwds_o), .i_rwds_oe(rwds_oe), .o_rwds(w_rwds)
  );
`else
  generate for (genvar g = 0; g < 8; g++) begin : gen_dq
    assign w_dq[g] = dq_oe[g] ? dq_o[g] : 1'bz;
  end endgenerate
  assign w_rwds = rwds_oe ? rwds_o : 1'bz;
  s27ks0641 u_dont_touch_mem (
    .DQ7(w_dq[7]), .DQ6(w_dq[6]), .DQ5(w_dq[5]), .DQ4(w_dq[4]), .DQ3(w_dq[3]), .DQ2(w_dq[2]), .DQ1(w_dq[1]),
    .DQ0(w_dq[0]), .RWDS(w_rwds), .CSNeg(cs_n[0]), .CK(ck), .CKNeg(ckn), .RESETNeg(rst_n_mem)
  );
`endif

  int errors = 0;

  task automatic apb_wr(input [15:0] a, input [31:0] d);
    @(posedge clk_apb); #1; psel = 1; pwrite = 1; paddr = a; pwdata = d; penable = 0;
    @(posedge clk_apb); #1; penable = 1;
    do @(posedge clk_apb); while (!pready);
    #1; psel = 0; penable = 0;
  endtask
  task automatic apb_rd(input [15:0] a, output [31:0] d);
    @(posedge clk_apb); #1; psel = 1; pwrite = 0; paddr = a; penable = 0;
    @(posedge clk_apb); #1; penable = 1;
    do @(posedge clk_apb); while (!pready);
    d = prdata; #1; psel = 0; penable = 0;
  endtask

  task automatic axi_wr(input [31:0] a, input int n, input [31:0] base);
    fork
      begin
        @(posedge clk_core); #1; awvalid = 1; awaddr = a; awlen = n - 1;
        do @(posedge clk_core); while (!awready);
        #1; awvalid = 0;
      end
      begin
        for (int i = 0; i < n; i++) begin
          @(posedge clk_core); #1; wvalid = 1; wdata = base + i; wlast = (i == n - 1);
          while (!wready) @(posedge clk_core);
        end
        @(posedge clk_core); #1; wvalid = 0; wlast = 0;
      end
    join
    while (!bvalid) @(posedge clk_core);
    if (bresp !== 2'b00) begin $display("ERR bresp=%0d", bresp); errors++; end
    @(posedge clk_core);
  endtask

  task automatic axi_rd(input [31:0] a, input int n, input [31:0] base);
    int cnt;
    @(posedge clk_core); #1; arvalid = 1; araddr = a; arlen = n - 1;
    do @(posedge clk_core); while (!arready);
    #1; arvalid = 0;
    cnt = 0;
    while (cnt < n) begin
      @(posedge clk_core);
      if (rvalid && rready) begin
        if (rdata !== base + cnt || rresp !== 2'b00) begin
          $display("ERR rd beat %0d: got %08h exp %08h resp %0d", cnt, rdata, base + cnt, rresp);
          errors++;
        end
        if (rlast !== (cnt == n - 1)) begin $display("ERR rlast beat %0d", cnt); errors++; end
        cnt++;
      end
    end
  endtask

  logic [31:0] wbuf [0:15];
  logic [3:0]  sbuf [0:15];
  logic [7:0]  ref_mem [0:4095];
  bit          ref_wr  [0:4095];
  int          nbursts_w = 0, nbursts_r = 0, nbytes_chk = 0;

  task automatic axi_wr_buf(input [31:0] a, input int n);
    fork
      begin
        @(posedge clk_core); #1; awvalid = 1; awaddr = a; awlen = n - 1;
        do @(posedge clk_core); while (!awready);
        #1; awvalid = 0;
      end
      begin
        for (int i = 0; i < n; i++) begin
          @(posedge clk_core); #1; wvalid = 1; wdata = wbuf[i]; wstrb = sbuf[i]; wlast = (i == n - 1);
          while (!wready) @(posedge clk_core);
        end
        @(posedge clk_core); #1; wvalid = 0; wlast = 0;
      end
    join
    while (!bvalid) @(posedge clk_core);
    if (bresp !== 2'b00) begin $display("ERR bresp=%0d", bresp); errors++; end
    @(posedge clk_core);
    nbursts_w++;
  endtask

  task automatic axi_rd_chk(input [31:0] a, input int n);
    int cnt;
    @(posedge clk_core); #1; arvalid = 1; araddr = a; arlen = n - 1;
    do @(posedge clk_core); while (!arready);
    #1; arvalid = 0;
    cnt = 0;
    while (cnt < n) begin
      @(posedge clk_core);
      if (rvalid && rready) begin
        for (int b = 0; b < 4; b++) begin
          if (ref_wr[a + cnt*4 + b]) begin
            nbytes_chk++;
            if (rdata[8*b +: 8] !== ref_mem[a + cnt*4 + b]) begin
              $display("ERR rd addr %0h byte %0d: got %02h exp %02h", a + cnt*4, b, rdata[8*b +: 8], ref_mem[a + cnt*4 + b]);
              errors++;
            end
          end
        end
        if (rresp !== 2'b00) begin $display("ERR rresp=%0d", rresp); errors++; end
        if (rlast !== (cnt == n - 1)) begin $display("ERR rlast beat %0d", cnt); errors++; end
        cnt++;
      end
    end
    nbursts_r++;
  endtask

  logic [31:0] v;
  initial begin
    if ($test$plusargs("dump")) begin $dumpfile("m_vlsit_tb_hyperram_smoke.vcd"); $dumpvars(0, m_vlsit_tb_hyperram_smoke); end
    #10; rst_n_core = 0; rst_n_apb = 0;   // real falling edge for the asynchronous resets
    #100; rst_n_core = 1; rst_n_apb = 1; #100;
    apb_rd(16'h0008, v); $display("hr_cap=%08h", v);
    apb_rd(16'h0000, v); $display("hr_ctrl=%08h", v);
    apb_wr(16'h0100, 32'h0001C4E0 & ~(32'h1F << 5) | (32'd`INIT_LAT << 5));   // init_lat = INIT_LAT
    apb_wr(16'h0010, 32'h0000_0102);                                   // ck_div = 2, ck_diff = 1
    apb_wr(16'h0000, 32'h0000_0001);                                   // en
    begin : wait_init
      for (int i = 0; i < 4000; i++) begin
        apb_rd(16'h0004, v);
        if (v[1])
          disable wait_init;
        repeat (50) @(posedge clk_apb);
      end
      $display("ERR init_done timeout hr_sts=%08h", v); errors++;
    end
    $display("%0t init: hr_sts=%08h", $time, v);
    apb_rd(16'h0124, v); $display("ID0=%04h", v[15:0]);
    apb_rd(16'h0024, v); $display("irq_raw=%08h", v);
    // Random bursts: 1 to 16 beats, word aligned, random byte strobes, region 0 to 4 KB
    for (int t = 0; t < 60; t++) begin
      int n, base;
      n    = 1 + ($urandom % 16);
      base = 4 * ($urandom % (1024 - n + 1));
      for (int k = 0; k < n; k++) begin
        wbuf[k] = $urandom;
        sbuf[k] = ($urandom % 4 == 0) ? 4'(1 + $urandom % 15) : 4'hF;
        for (int b = 0; b < 4; b++) if (sbuf[k][b]) begin
          ref_mem[base + 4*k + b] = wbuf[k][8*b +: 8];
          ref_wr [base + 4*k + b] = 1;
        end
      end
      axi_wr_buf(base, n);
    end
    $display("%0t writes done: %0d bursts", $time, nbursts_w);
    for (int t = 0; t < 60; t++) begin
      int n, base;
      n    = 1 + ($urandom % 16);
      base = 4 * ($urandom % (1024 - n + 1));
      axi_rd_chk(base, n);
    end
    for (int blk = 0; blk < 64; blk++) axi_rd_chk(blk * 64, 16);
    $display("%0t reads done: %0d bursts, %0d bytes checked", $time, nbursts_r, nbytes_chk);
    apb_rd(16'h0004, v); $display("hr_sts=%08h", v);
    if (errors == 0)
      $display("SMOKE PASS");
    else
      $display("SMOKE FAIL errors=%0d", errors);
    $finish;
  end
  initial begin #20_000_000; $display("SMOKE FAIL global timeout"); $finish; end
endmodule
