// Testbench of the SHA2/SHA3 hash IP m_vlsit_sha_top (verification code, not RTL).
//
// Derived from VLSIT_SHA2_SHA3_HASH_HDS.md (sections 5, 6.3, 6.4, 7.3, 11, 12, 15), FIPS 180-4, FIPS 202,
// ARM IHI0024D (APB4) and ARM IHI0022 (AXI4). The expected digests are in the vector files made by
// scripts/gen_vectors.py from the NIST CAVP vectors and Python hashlib; the RTL is read only for the
// port names, parameters and the observation points of the cross checks (R-023).
//
// The testbench runs a command script (+VEC=<file>), one command per line, see README.md.
//   apbw a d | apbr a | chka a mask val | poll a mask val tmo | waitlvl n tmo | axiw ctx n w... | axir ctx n
//   expect nbytes nwords w... | expb v | expr v | strb h | win b | rwin b | burst v | rburst v | wsize v | rsize v
//   awid v | tag s | cov alg cls | wait n | static protect slverr | pprot v | pstrbw v | pstrbr v | rstc n | rsta n | rstb n
//   axiabort ctx n k | bp 0/1 | stream ctx nwords seed | perf0 | perf1 tag blocks | chkirq v | chkalarm v
//   dmadly n | waitin | waitout | chkdma | end
// Plusargs: +VEC=<file> +CLASSES=<hex> +SEED=<n> +VCD=<file> +NAME=<run name>
`timescale 1ns/1ps

module tb_sha_top;
  parameter integer DW    = 64;
  parameter integer CTXN  = 4;
  parameter [11:0]  ALG   = 12'hFFF;
  parameter integer U256  = 1;
  parameter integer U512  = 1;
  parameter integer UKEC  = 1;
  parameter integer IND   = 64;
  parameter integer OUTD  = 32;
  parameter integer DMA   = 0;
  parameter integer ASYNC = 0;
  parameter real    APBH  = 5.0;    // half period of the APB clock in ns (core clock half period is 5 ns)
  parameter integer ZERO  = 1;
  parameter integer FDUP  = 0;
  parameter integer FPAR  = 0;
  parameter integer FREDO = 0;
  parameter integer ALARM = 0;
  parameter integer MASK  = 0;
  parameter integer SEEDSRC = 1;
  localparam integer WB   = DW / 8;
  localparam integer LWB  = $clog2(WB);
  localparam integer LPSTW = (ALG[11:6] != 0) ? ((MASK != 0) ? 3200 : 1600) : ((ALG[5:2] != 0) ? 512 : 256);

  logic clk = 0, clkapb = 0;
  logic rst_core_n = 0, rst_apb_n = 0;
  always #5 clk = ~clk;
  generate
    if (ASYNC != 0) begin : g_async_clk
      initial begin #1.7; forever #(APBH) clkapb = ~clkapb; end
    end else begin : g_sync_clk
      always #5 clkapb = ~clkapb;
    end
  endgenerate

  // APB
  logic psel = 0, penable = 0, pwrite = 0;
  logic [15:0] paddr = 0;
  logic [31:0] pwdata = 0;
  logic [3:0]  pstrb = 0;
  logic [2:0]  pprot = 0;
  logic        pready, pslverr;
  logic [31:0] prdata;
  logic        protect_en = 0, slverr_en = 1;
  logic        mask_pstrb_rd = 0;
  // AXI
  logic awvalid = 0, awready; logic [3:0] awid = 0; logic [15:0] awaddr = 0; logic [7:0] awlen = 0; logic [2:0] awsize = 0; logic [1:0] awburst = 1;
  logic wvalid = 0, wready; logic [DW-1:0] wdata = 0; logic [DW/8-1:0] wstrb = '1; logic wlast = 0;
  logic bvalid, bready = 1; logic [3:0] bid; logic [1:0] bresp;
  logic arvalid = 0, arready; logic [3:0] arid = 0; logic [15:0] araddr = 0; logic [7:0] arlen = 0; logic [2:0] arsize = 0; logic [1:0] arburst = 1;
  logic rvalid, rready = 1; logic [3:0] rid; logic [DW-1:0] rdata; logic [1:0] rresp; logic rlast;
  logic mask_axi_stim = 0;
  // DMA, entropy, events
  logic dma_in_req, dma_out_req, dma_in_ack = 0, dma_out_ack = 0, ent_req, irq, alarm;
  logic ent_valid = 0;
  logic [31:0] ent_data = 0;
  integer ent_n = 0, ent_dly = 3;
  reg [63:0] ctot_v;
  reg [CTXN*64-1:0] ctot_all;
  // Entropy source model (IF-004): answers a request after ent_dly cycles with a random word
  always @(posedge clk) begin
    ent_valid <= 1'b0;
    if (ent_req && !ent_valid) begin
      ent_n <= ent_n + 1;
      if (ent_n >= ent_dly) begin ent_valid <= 1'b1; ent_data <= $urandom; ent_n <= 0; end
    end else if (!ent_req) ent_n <= 0;
  end

  // Hash of the outputs while they are meaningful (X check by random power-up state, TEST-025): a run with random initial register
  // values shall give the same hash as a run with zero initial values, so no output depends on a register that was never written.
  logic [63:0] outhash = 64'h1234_5678_9ABC_DEF0;
  logic hs = 1'b0;                        // set once both resets have been seen low: outputs are defined from then on (7.3)
  always @(posedge clk) if (!rst_core_n && !rst_apb_n) hs <= 1'b1;
  always @(posedge clk) if (hs) begin
    outhash <= (outhash * 64'd1000003) ^ {awready, arready, wready, bvalid, rvalid & rlast, dma_in_req, dma_out_req, irq, alarm, ent_req,
                                          bvalid ? {bid, bresp} : 6'd0, 8'd0, rvalid ? {rid, rresp, rdata[31:0] ^ rdata[DW-1:DW-32]} : 38'd0};
  end
  integer dbgb = 0;
  initial if ($test$plusargs("DBGB")) dbgb = 1;
  always @(posedge clk) if (dbgb != 0) $display("DBGB %0t aw=%b ar=%b w=%b b=%b rl=%b di=%b do=%b irq=%b al=%b er=%b", $time, awready, arready, wready, bvalid, rvalid & rlast, dma_in_req, dma_out_req, irq, alarm, ent_req);
  logic [63:0] apbhash = 64'h0FED_CBA9_8765_4321;
  always @(posedge clkapb) if (hs) begin
    apbhash <= (apbhash * 64'd1000003) ^ {pready, pslverr, (psel && penable && pready) ? prdata : 32'd0};
  end

  m_vlsit_sha_top #(
    .PARA_EN_SHA224(ALG[0]), .PARA_EN_SHA256(ALG[1]), .PARA_EN_SHA384(ALG[2]), .PARA_EN_SHA512(ALG[3]),
    .PARA_EN_SHA512_224(ALG[4]), .PARA_EN_SHA512_256(ALG[5]), .PARA_EN_SHA3_224(ALG[6]), .PARA_EN_SHA3_256(ALG[7]),
    .PARA_EN_SHA3_384(ALG[8]), .PARA_EN_SHA3_512(ALG[9]), .PARA_EN_SHAKE128(ALG[10]), .PARA_EN_SHAKE256(ALG[11]),
    .PARA_S256_UNR(U256), .PARA_S512_UNR(U512), .PARA_KEC_UNR(UKEC), .PARA_CTX_N(CTXN), .PARA_AXI_DW(DW),
    .PARA_IN_DEPTH(IND), .PARA_OUT_DEPTH(OUTD), .PARA_DMA(DMA), .PARA_CSR_ASYNC(ASYNC), .PARA_ZERO(ZERO),
    .PARA_FAULT_DUP(FDUP), .PARA_FAULT_PAR(FPAR), .PARA_FAULT_REDO(FREDO), .PARA_ALARM(ALARM),
    .PARA_MASK(MASK), .PARA_SEED_SRC(MASK != 0 ? SEEDSRC : 0), .PARA_KEC_PIPE(MASK != 0 ? 2 : 1)
  ) dut (
    .i_clk_core(clk), .i_rst_n_core(rst_core_n), .i_clk_apb(clkapb), .i_rst_n_apb(rst_apb_n),
    .i_apb_psel(psel), .i_apb_penable(penable), .i_apb_pwrite(pwrite), .i_apb_paddr(paddr), .i_apb_pwdata(pwdata),
    .i_apb_pstrb(pstrb), .i_apb_pprot(pprot), .o_apb_pready(pready), .o_apb_pslverr(pslverr), .o_apb_prdata(prdata),
    .i_protect_en(protect_en), .i_slverr_en(slverr_en),
    .i_axi_awvalid(awvalid), .o_axi_awready(awready), .i_axi_awid(awid), .i_axi_awaddr(awaddr), .i_axi_awlen(awlen),
    .i_axi_awsize(awsize), .i_axi_awburst(awburst), .i_axi_wvalid(wvalid), .o_axi_wready(wready), .i_axi_wdata(wdata),
    .i_axi_wstrb(wstrb), .i_axi_wlast(wlast), .o_axi_bvalid(bvalid), .i_axi_bready(bready), .o_axi_bid(bid), .o_axi_bresp(bresp),
    .i_axi_arvalid(arvalid), .o_axi_arready(arready), .i_axi_arid(arid), .i_axi_araddr(araddr), .i_axi_arlen(arlen),
    .i_axi_arsize(arsize), .i_axi_arburst(arburst), .o_axi_rvalid(rvalid), .i_axi_rready(rready), .o_axi_rid(rid),
    .o_axi_rdata(rdata), .o_axi_rresp(rresp), .o_axi_rlast(rlast),
    .o_dma_in_req(dma_in_req), .i_dma_in_ack(dma_in_ack), .o_dma_out_req(dma_out_req), .i_dma_out_ack(dma_out_ack),
    .i_ent_valid(ent_valid), .i_ent_data(ent_data), .o_ent_req(ent_req), .o_irq(irq), .o_alarm(alarm)
  );

  // ---------------------------------------------------------------------------------------------
  // Observation points of the checkers (15.3): names only; the checks come from the specification
  logic [CTXN*4-1:0] obs_cst;
  logic [CTXN-1:0]   obs_abs, obs_memz;
  logic [2:0]        obs_starts;
  logic              obs_irq_or, obs_push, obs_core_zero, obs_core_idle, obs_inflight;
  always_comb begin
    for (int k = 0; k < CTXN; k++) begin
      obs_cst[4*k +: 4] = dut.u_seq.reg_cst[k];
      obs_memz[k]       = (dut.u_ctxmem.reg_mem[k] == '0);
    end
    obs_abs     = dut.u_seq.o_ctx_abs;
    obs_starts  = {dut.u_seq.o_kec_start, dut.u_seq.o_c512_start, dut.u_seq.o_c256_start};
    obs_push    = dut.w_in_push_en;
    obs_irq_or  = (|dut.u_irq.o_sts_one) || (|dut.u_irq.o_sts_cdone);
    obs_inflight = dut.u_seq.reg_pf_valid || (dut.u_seq.reg_fsm_be_current_state != 2'b00) || (dut.u_seq.reg_fsm_fe_current_state != 2'b00);
  end
  // core registers of the built cores
  logic z256, z512, zkec, i256, i512, ikec;
  generate
    if (ALG[1:0] != 2'b00) begin : g_z256
      always_comb begin z256 = (dut.gen_c256.u_core256.reg_v == '0) && (dut.gen_c256.u_core256.reg_w == '0); i256 = !dut.gen_c256.u_core256.reg_run; end
    end else begin : g_n256
      assign z256 = 1'b1;
      assign i256 = 1'b1;
    end
    if (ALG[5:2] != 4'b0000) begin : g_z512
      always_comb begin z512 = (dut.gen_c512.u_core512.reg_v == '0) && (dut.gen_c512.u_core512.reg_w == '0); i512 = !dut.gen_c512.u_core512.reg_run; end
    end else begin : g_n512
      assign z512 = 1'b1;
      assign i512 = 1'b1;
    end
    if (ALG[11:6] != 6'b000000) begin : g_zkec
      if (MASK == 0) begin : g_plain
        always_comb begin zkec = (dut.gen_kec.u_keccak.reg_st == '0); ikec = !dut.gen_kec.u_keccak.reg_run; end
      end else begin : g_dom
        always_comb begin zkec = (dut.gen_kec_dom.u_keccak.reg_s0 == '0) && (dut.gen_kec_dom.u_keccak.reg_s1 == '0); ikec = !dut.gen_kec_dom.u_keccak.reg_run; end
      end
    end else begin : g_nkec
      assign zkec = 1'b1;
      assign ikec = 1'b1;
    end
  endgenerate
  always_comb begin
    obs_core_zero = z256 && z512 && zkec;
    obs_core_idle = i256 && i512 && ikec;
  end


  // ---------------------------------------------------------------------------------------------
  // Fault injection by force (TEST-020): a bit flip of a core register some cycles after the core starts.
  // Targets: 0 SHA-256 core, 1 SHA-512 core, 2 Keccak core, 3 to 5 the duplicates of 0 to 2,
  // 6 SHA-256 message window register, 7 SHA-512 window, 8 context memory word of context 0.
  integer inj_tgt = 0, inj_dly = 0, inj_bit = 0, inj_req = 0;
  integer n_inj = 0, inj_snap = 0;
  reg [255:0]  inj_v256;
  reg [511:0]  inj_v512;
  reg [1599:0] inj_v1600;
  generate
    if (ALG[1:0] != 2'b00) begin : g_inj256
      always @(inj_req) begin
        if (inj_req != 0 && (inj_tgt == 0 || inj_tgt == 6)) begin
          @(posedge dut.gen_c256.u_core256.reg_run); repeat (inj_dly) @(posedge clk); #1;
          if (inj_tgt == 0) begin
            inj_v256 = dut.gen_c256.u_core256.reg_v ^ (256'd1 << inj_bit);
            force dut.gen_c256.u_core256.reg_v = inj_v256; @(posedge clk); #1; release dut.gen_c256.u_core256.reg_v;
          end else begin
            inj_v512 = dut.gen_c256.u_core256.reg_w ^ (512'd1 << inj_bit);
            force dut.gen_c256.u_core256.reg_w = inj_v512; @(posedge clk); #1; release dut.gen_c256.u_core256.reg_w;
          end
          n_inj = n_inj + 1;
        end
      end
    end
    if (ALG[5:2] != 4'b0000) begin : g_inj512
      always @(inj_req) begin
        if (inj_req != 0 && (inj_tgt == 1 || inj_tgt == 7)) begin
          @(posedge dut.gen_c512.u_core512.reg_run); repeat (inj_dly) @(posedge clk); #1;
          if (inj_tgt == 1) begin
            inj_v512 = dut.gen_c512.u_core512.reg_v ^ (512'd1 << inj_bit);
            force dut.gen_c512.u_core512.reg_v = inj_v512; @(posedge clk); #1; release dut.gen_c512.u_core512.reg_v;
          end else begin
            inj_v1600 = {576'b0, dut.gen_c512.u_core512.reg_w} ^ (1600'd1 << inj_bit);
            force dut.gen_c512.u_core512.reg_w = inj_v1600[1023:0]; @(posedge clk); #1; release dut.gen_c512.u_core512.reg_w;
          end
          n_inj = n_inj + 1;
        end
      end
    end
    if ((ALG[11:6] != 6'b000000) && (MASK == 0)) begin : g_inj_kec
      always @(inj_req) begin
        if (inj_req != 0 && inj_tgt == 2) begin
          @(posedge dut.gen_kec.u_keccak.reg_run); repeat (inj_dly) @(posedge clk); #1;
          inj_v1600 = dut.gen_kec.u_keccak.reg_st ^ (1600'd1 << inj_bit);
          force dut.gen_kec.u_keccak.reg_st = inj_v1600; @(posedge clk); #1; release dut.gen_kec.u_keccak.reg_st;
          n_inj = n_inj + 1;
        end
      end
    end
    if ((ALG[11:6] != 6'b000000) && (MASK != 0)) begin : g_inj_dom
      // masked core: a bit flip of share 0 (target 2)
      always @(inj_req) begin
        if (inj_req != 0 && inj_tgt == 2) begin
          @(posedge dut.gen_kec_dom.u_keccak.reg_run); repeat (inj_dly) @(posedge clk); #1;
          inj_v1600 = dut.gen_kec_dom.u_keccak.reg_s0 ^ (1600'd1 << inj_bit);
          force dut.gen_kec_dom.u_keccak.reg_s0 = inj_v1600; @(posedge clk); #1; release dut.gen_kec_dom.u_keccak.reg_s0;
          n_inj = n_inj + 1;
        end
      end
    end
  endgenerate

  // Memory targets: 8 context memory word of context 0, 9 all entries of the input FIFO of context 0,
  // 10 all entries of the output FIFO of context 0. The flip is applied inj_dly cycles after the request.
  reg [3359:0] inj_mem;
  generate
    if (FPAR != 0) begin : g_inj_mem
      always @(inj_req) begin
        if (inj_req != 0 && inj_tgt == 8) begin
          repeat (inj_dly) @(posedge clk); #1;
          inj_mem = {{(3360-LPSTW){1'b0}}, dut.u_ctxmem.reg_mem[0]} ^ (3360'd1 << inj_bit);
          force dut.u_ctxmem.reg_mem[0] = inj_mem[LPSTW-1:0]; @(posedge clk); #1; release dut.u_ctxmem.reg_mem[0];
          n_inj = n_inj + 1;
        end
      end
      for (genvar gi = 0; gi < IND; gi++) begin : g_in
        reg [DW+DW/32-1:0] w;
        always @(inj_req) begin
          if (inj_req != 0 && inj_tgt == 9) begin
            repeat (inj_dly) @(posedge clk); #1;
            w = dut.u_in_fifo.gen_fifo[0].u_fifo.u_vlsit_sfifo_mem.gen_array.reg_mem[gi] ^ ({{(DW+DW/32-1){1'b0}}, 1'b1} << inj_bit);
            force dut.u_in_fifo.gen_fifo[0].u_fifo.u_vlsit_sfifo_mem.gen_array.reg_mem[gi] = w; @(posedge clk); #1;
            release dut.u_in_fifo.gen_fifo[0].u_fifo.u_vlsit_sfifo_mem.gen_array.reg_mem[gi];
            if (gi == 0) n_inj = n_inj + 1;
          end
        end
      end
      for (genvar go = 0; go < OUTD; go++) begin : g_out
        reg [DW+DW/32-1:0] w;
        always @(inj_req) begin
          if (inj_req != 0 && inj_tgt == 10) begin
            repeat (inj_dly) @(posedge clk); #1;
            w = dut.u_out_fifo.gen_fifo[0].u_fifo.u_vlsit_sfifo_mem.gen_array.reg_mem[go] ^ ({{(DW+DW/32-1){1'b0}}, 1'b1} << inj_bit);
            force dut.u_out_fifo.gen_fifo[0].u_fifo.u_vlsit_sfifo_mem.gen_array.reg_mem[go] = w; @(posedge clk); #1;
            release dut.u_out_fifo.gen_fifo[0].u_fifo.u_vlsit_sfifo_mem.gen_array.reg_mem[go];
            if (go == 0) n_inj = n_inj + 1;
          end
        end
      end
    end
  endgenerate

  // Observation of the masked core (class 10 assertions and the share statistics)
  logic mk_run = 0, mk_s1nz = 0, mk_plain_run = 0, mk_s1z = 0, rnd_chg = 0, mk_start = 0;
  real hw_sum [0:1][0:47][0:1];
  real hw_sq  [0:1][0:47][0:1];
  integer hw_n [0:1][0:47];
  integer hwgrp = 2;
  generate
    if ((ALG[11:6] != 6'b000000) && (MASK != 0)) begin : g_mon
      reg [1599:0] rnd_prev;
      integer idx, g, k2;
      initial begin
        for (g = 0; g < 2; g++) for (k2 = 0; k2 < 48; k2++) begin hw_n[g][k2] = 0; hw_sum[g][k2][0] = 0; hw_sum[g][k2][1] = 0; hw_sq[g][k2][0] = 0; hw_sq[g][k2][1] = 0; end
      end
      always @(posedge clk) begin
        mk_run       <= dut.gen_kec_dom.u_keccak.reg_run && dut.w_mask_en && !dut.w_kec_start;
        mk_plain_run <= dut.gen_kec_dom.u_keccak.reg_run && !dut.w_mask_en && !dut.w_kec_start;
        mk_s1nz      <= (dut.gen_kec_dom.u_keccak.reg_s1 != '0);
        mk_s1z       <= (dut.gen_kec_dom.u_keccak.reg_s1 == '0);
        mk_start     <= dut.w_kec_start && dut.w_mask_en;
        rnd_chg      <= (dut.w_rnd != rnd_prev);
        rnd_prev     <= dut.w_rnd;
        if (dut.gen_kec_dom.u_keccak.reg_run && (hwgrp < 2)) begin
          idx = dut.gen_kec_dom.u_keccak.reg_cnt * 2 + (dut.gen_kec_dom.u_keccak.reg_ph ? 1 : 0);
          hw_n[hwgrp][idx] = hw_n[hwgrp][idx] + 1;
          hw_sum[hwgrp][idx][0] = hw_sum[hwgrp][idx][0] + $countones(dut.gen_kec_dom.u_keccak.reg_s0);
          hw_sq[hwgrp][idx][0]  = hw_sq[hwgrp][idx][0] + $countones(dut.gen_kec_dom.u_keccak.reg_s0) * $countones(dut.gen_kec_dom.u_keccak.reg_s0);
          hw_sum[hwgrp][idx][1] = hw_sum[hwgrp][idx][1] + $countones(dut.gen_kec_dom.u_keccak.reg_s1);
          hw_sq[hwgrp][idx][1]  = hw_sq[hwgrp][idx][1] + $countones(dut.gen_kec_dom.u_keccak.reg_s1) * $countones(dut.gen_kec_dom.u_keccak.reg_s1);
        end
      end
    end
  endgenerate

  sha_checkers #(.DW(DW), .CTXN(CTXN), .DMA(DMA)) u_chk (
    .i_clk(clk), .i_rst_n(rst_core_n), .i_pclk(clkapb), .i_presetn(rst_apb_n),
    .i_psel(psel), .i_penable(penable), .i_pwrite(pwrite), .i_paddr(paddr), .i_pwdata(pwdata), .i_pstrb(pstrb),
    .i_pprot(pprot), .i_pready(pready), .i_pslverr(pslverr), .i_prdata(prdata),
    .i_protect_en(protect_en), .i_slverr_en(slverr_en), .i_mask_apb_pstrb_rd(mask_pstrb_rd),
    .i_awvalid(awvalid), .i_awready(awready), .i_awid(awid), .i_awaddr(awaddr), .i_awlen(awlen), .i_awsize(awsize), .i_awburst(awburst),
    .i_wvalid(wvalid), .i_wready(wready), .i_wdata(wdata), .i_wstrb(wstrb), .i_wlast(wlast),
    .i_bvalid(bvalid), .i_bready(bready), .i_bid(bid), .i_bresp(bresp),
    .i_arvalid(arvalid), .i_arready(arready), .i_arid(arid), .i_araddr(araddr), .i_arlen(arlen), .i_arsize(arsize), .i_arburst(arburst),
    .i_rvalid(rvalid), .i_rready(rready), .i_rid(rid), .i_rdata(rdata), .i_rresp(rresp), .i_rlast(rlast),
    .i_mask_axi_stim(mask_axi_stim),
    .i_ctx_cst(obs_cst), .i_ctx_abs(obs_abs), .i_push_en(obs_push), .i_core_starts(obs_starts),
    .i_irq(irq), .i_irq_sts_or(obs_irq_or), .i_alarm(alarm),
    .i_dma_in_req(dma_in_req), .i_dma_in_ack(dma_in_ack), .i_dma_out_req(dma_out_req), .i_dma_out_ack(dma_out_ack),
    .i_zero_en(ZERO != 0), .i_ctx_mem_zero(obs_memz), .i_core_zero(obs_core_zero), .i_core_idle(obs_core_idle), .i_inflight(obs_inflight),
    .i_lock(dut.w_lock), .i_gate(dut.w_gate), .i_ev_flt(dut.w_ev_flt), .i_sec_resp(dut.w_sec_resp), .i_srst_ack(dut.w_ack_srst),
    .i_mk_run(mk_run), .i_mk_s1nz(mk_s1nz), .i_mk_plain_run(mk_plain_run), .i_mk_s1z(mk_s1z), .i_rnd_chg(rnd_chg),
    .i_mk_start(mk_start), .i_seeded(dut.w_seeded), .i_ev_ent(dut.w_ev_ent), .i_ent_req(ent_req)
  );

  // ---------------------------------------------------------------------------------------------
  // Models: DMA controller (4-phase responder), random back pressure, cycle counter
  integer dma_dly = 3;
  integer dma_man = 0;                 // 1: the DMA controller model acknowledges only when the script asks (waitin, waitout)
  reg go_in = 0, go_out = 0;
  integer n_in_req = 0, n_out_req = 0;
  integer cyc = 0;
  integer bp = 0;
  always @(posedge clk) cyc = cyc + 1;
  always begin : p_dma_in
    @(posedge clk);
    if (dma_in_req && !dma_in_ack && (dma_man == 0 || go_in)) begin repeat (dma_dly) @(posedge clk); dma_in_ack <= 1; n_in_req = n_in_req + 1; end
    if (!dma_in_req && dma_in_ack) begin repeat (2) @(posedge clk); dma_in_ack <= 0; end
  end
  always begin : p_dma_out
    @(posedge clk);
    if (dma_out_req && !dma_out_ack && (dma_man == 0 || go_out)) begin repeat (dma_dly) @(posedge clk); dma_out_ack <= 1; n_out_req = n_out_req + 1; end
    if (!dma_out_req && dma_out_ack) begin repeat (2) @(posedge clk); dma_out_ack <= 0; end
  end
  always @(posedge clk) begin
    if (bp != 0) begin bready <= ($urandom % 3) != 0; rready <= ($urandom % 3) != 0; end
    else begin bready <= 1'b1; rready <= 1'b1; end
  end

  // ---------------------------------------------------------------------------------------------
  // Scoreboard
  integer sb_pass = 0, sb_fail = 0;
  string  cur_tag = "none";
  task automatic sb(input bit ok, input string what);
    if (ok) sb_pass = sb_pass + 1;
    else begin sb_fail = sb_fail + 1; $display("SB FAIL [%0s] %0s @%0t", cur_tag, what, $time); end
  endtask

  // ---------------------------------------------------------------------------------------------
  // Bus models
  reg [DW-1:0] mem [0:255];
  reg [DW-1:0] rbuf [0:2047];
  integer rn = 0;
  reg [DW/8-1:0] strbv = '1;
  reg winbit = 0, rwinbit = 1;
  reg [1:0] burstv = 1, rburstv = 1;
  integer wsizev = -1, rsizev = -1;
  reg [3:0] awidv = 0;
  reg [1:0] last_bresp = 0;
  reg [1:0] rresp_acc = 0;
  reg [3:0] pstrbw = 4'hF, pstrbr = 4'h0;
  reg [DW/8-1:0] strbl = '1;
  reg strbl_en = 0;

  task automatic apbw(input [15:0] a, input [31:0] d);
    begin
      @(posedge clkapb); #1 psel = 1; pwrite = 1; paddr = a; pwdata = d; pstrb = pstrbw; penable = 0;
      @(posedge clkapb); #1 penable = 1;
      @(posedge clkapb); while (!pready) @(posedge clkapb);
      #1 psel = 0; penable = 0; pwrite = 0; pstrb = 0;
    end
  endtask
  reg slverr_seen = 0;
  task automatic apbr(input [15:0] a, output [31:0] d);
    begin
      @(posedge clkapb); #1 psel = 1; pwrite = 0; paddr = a; pstrb = pstrbr; mask_pstrb_rd = (pstrbr != 0); penable = 0;
      @(posedge clkapb); #1 penable = 1;
      @(posedge clkapb); while (!pready) @(posedge clkapb);
      d = prdata; slverr_seen = pslverr;
      #1 psel = 0; penable = 0; pstrb = 0; mask_pstrb_rd = 0;
    end
  endtask

  task automatic axiw(input [3:0] ctx, input integer n);
    integer i, gap;
    begin
      @(posedge clk);
      if (bp != 0) repeat ($urandom % 3) @(posedge clk);
      #1 awvalid = 1; awaddr = {ctx, winbit, 11'h000}; awid = awidv; awlen = n - 1;
      awsize = (wsizev < 0) ? LWB[2:0] : wsizev[2:0]; awburst = burstv;
      mask_axi_stim = (burstv != 2'b01 && burstv != 2'b00) || (wsizev >= 0);
      @(posedge clk); while (!awready) @(posedge clk);
      #1 awvalid = 0;
      for (i = 0; i < n; i = i + 1) begin
        if (bp != 0) begin gap = $urandom % 3; if (gap != 0) begin #1 wvalid = 0; repeat (gap) @(posedge clk); end end
        #1 wvalid = 1; wdata = mem[i]; wlast = (i == n - 1); wstrb = (strbl_en && i == n - 1) ? strbl : strbv;
        @(posedge clk); while (!wready) @(posedge clk);
      end
      #1 wvalid = 0; wlast = 0;
      while (!bvalid) @(posedge clk);
      last_bresp = bresp;
      @(posedge clk);
      mask_axi_stim = 0;
    end
  endtask

  task automatic axir(input [3:0] ctx, input integer n);
    integer i;
    begin
      @(posedge clk);
      #1 arvalid = 1; araddr = {ctx, rwinbit, 11'h000}; arid = awidv; arlen = n - 1;
      arsize = (rsizev < 0) ? LWB[2:0] : rsizev[2:0]; arburst = rburstv;
      mask_axi_stim = (rburstv != 2'b01 && rburstv != 2'b00) || (rsizev >= 0);
      @(posedge clk); while (!arready) @(posedge clk);
      #1 arvalid = 0;
      rresp_acc = 0;
      for (i = 0; i < n; i = i + 1) begin
        @(posedge clk); while (!(rvalid && rready)) @(posedge clk);
        if (rn < 2048) rbuf[rn] = rdata;
        rn = rn + 1;
        rresp_acc = rresp_acc | rresp;
      end
      @(posedge clk);
      mask_axi_stim = 0;
    end
  endtask

  // Two read bursts back to back: the second address waits while the first burst is open (AXI stall rules)
  task automatic axir2(input [3:0] ctx, input integer n1, input integer n2);
    integer i;
    begin
      @(posedge clk);
      #1 arvalid = 1; araddr = {ctx, rwinbit, 11'h000}; arid = awidv; arlen = n1 - 1; arsize = LWB[2:0]; arburst = rburstv;
      @(posedge clk); while (!arready) @(posedge clk);
      #1 araddr = {ctx, rwinbit, 11'h000}; arid = awidv + 4'd1; arlen = n2 - 1;      // second address, held until accepted
      rresp_acc = 0;
      for (i = 0; i < n1; i = i + 1) begin
        @(posedge clk); while (!(rvalid && rready)) @(posedge clk);
        if (rn < 2048) rbuf[rn] = rdata;
        rn = rn + 1; rresp_acc = rresp_acc | rresp;
      end
      while (!arready) @(posedge clk);
      #1 arvalid = 0;
      for (i = 0; i < n2; i = i + 1) begin
        @(posedge clk); while (!(rvalid && rready)) @(posedge clk);
        if (rn < 2048) rbuf[rn] = rdata;
        rn = rn + 1; rresp_acc = rresp_acc | rresp;
      end
      @(posedge clk);
    end
  endtask

  // Stream with the pattern of scripts/vec_lib.py: lane j of word i = i * 9E3779B1 + j * 85EBCA6B + seed
  function automatic [DW-1:0] f_pat(input integer idx, input integer seed);
    reg [DW-1:0] w;
    reg [31:0] ln;
    begin
      w = '0;
      for (int j = 0; j < (DW / 32); j++) begin
        ln = 32'(idx) * 32'h9E3779B1 + 32'(j) * 32'h85EBCA6B + 32'(seed);
        w[32*j +: 32] = ln;
      end
      f_pat = w;
    end
  endfunction

  task automatic stream(input [3:0] ctx, input integer nwords, input integer seed);
    integer sent, n, i;
    begin
      sent = 0;
      while (sent < nwords) begin
        n = (nwords - sent > 256) ? 256 : (nwords - sent);
        @(posedge clk);
        #1 awvalid = 1; awaddr = {ctx, 1'b0, 11'h000}; awid = 0; awlen = n - 1; awsize = LWB[2:0]; awburst = 2'b01;
        @(posedge clk); while (!awready) @(posedge clk);
        #1 awvalid = 0;
        for (i = 0; i < n; i = i + 1) begin
          #1 wvalid = 1; wdata = f_pat(sent + i, seed); wlast = (i == n - 1); wstrb = '1;
          @(posedge clk); while (!wready) @(posedge clk);
        end
        #1 wvalid = 0; wlast = 0;
        while (!bvalid) @(posedge clk);
        if (bresp != 2'b00) sb(1'b0, "stream write response not OKAY");
        @(posedge clk);
        sent = sent + n;
      end
    end
  endtask

  task automatic do_reset(input integer which, input integer ncyc);   // 1 core, 2 apb, 3 both
    begin
      #1;
      awvalid = 0; wvalid = 0; arvalid = 0; psel = 0; penable = 0;
      if (which[0]) rst_core_n = 0;
      if (which[1]) rst_apb_n = 0;
      repeat (ncyc) @(posedge clk);
      #1;
      if (which[0]) rst_core_n = 1;
      if (which[1]) rst_apb_n = 1;
      repeat (8) @(posedge clk);
    end
  endtask

  // ---------------------------------------------------------------------------------------------
  // Script interpreter
  integer fd, r, nw, i, k, cyc0, cyc1, perf_c0, ctxn, timeout, nbytes, nexp;
  reg [255:0] cmd;
  reg [1023:0] sarg;
  reg [31:0] a32, d32, v32, m32;
  reg [DW-1:0] wv, expw;
  string vecname, runname, vecdir;
  integer cov_n = 0;
  integer errs;
  string  vcdname;

  task automatic run_script(input string fn);
    integer fdl;
    begin
      fdl = $fopen(fn, "r");
      if (fdl == 0) begin $display("TB-ERROR cannot open %0s", fn); sb(1'b0, {"vector file not found: ", fn}); end
      else begin
    while (!$feof(fdl)) begin
      r = $fscanf(fdl, "%s", cmd);
      if (r == 1) begin
        case (cmd)
          "end": begin end
          "include": begin r = $fscanf(fdl, "%s", sarg); run_script({vecdir, "/", $sformatf("%0s", sarg)}); end
          "tag": begin r = $fscanf(fdl, "%s", sarg); cur_tag = $sformatf("%0s", sarg); end
          "apbw": begin r = $fscanf(fdl, "%h %h", a32, d32); apbw(a32[15:0], d32); end
          "apbr": begin r = $fscanf(fdl, "%h", a32); apbr(a32[15:0], v32); $display("APBR %h %h err=%0d", a32, v32, slverr_seen); end
          "chka": begin
            r = $fscanf(fdl, "%h %h %h", a32, m32, d32);
            apbr(a32[15:0], v32);
            sb((v32 & m32) === d32, $sformatf("APB read %h = %h, expected %h under mask %h", a32, v32, d32, m32));
          end
          "chkaif": begin   // register read whose expected value depends on PARA_CSR_ASYNC (value if async, value if tied)
            r = $fscanf(fdl, "%h %h %h %h", a32, m32, d32, v32);
            apbr(a32[15:0], cyc1);
            sb((cyc1 & m32) === (ASYNC != 0 ? d32 : v32), $sformatf("APB read %h = %h, expected %h (PARA_CSR_ASYNC=%0d)", a32, cyc1, (ASYNC != 0 ? d32 : v32), ASYNC));
          end
          "chkerr": begin   // last APB access: PSLVERR expected value
            r = $fscanf(fdl, "%d", ctxn);
            sb(slverr_seen === ctxn[0], $sformatf("PSLVERR = %0d, expected %0d", slverr_seen, ctxn[0]));
          end
          "apbwerr": begin   // write, then PSLVERR expected value
            r = $fscanf(fdl, "%h %h %d", a32, d32, ctxn);
            @(posedge clkapb); #1 psel = 1; pwrite = 1; paddr = a32[15:0]; pwdata = d32; pstrb = pstrbw; penable = 0;
            @(posedge clkapb); #1 penable = 1;
            @(posedge clkapb); while (!pready) @(posedge clkapb);
            slverr_seen = pslverr;
            #1 psel = 0; penable = 0; pwrite = 0; pstrb = 0;
            sb(slverr_seen === ctxn[0], $sformatf("write %h PSLVERR = %0d, expected %0d", a32, slverr_seen, ctxn[0]));
          end
          "poll": begin
            r = $fscanf(fdl, "%h %h %h %d", a32, m32, d32, timeout);
            cyc0 = 0; apbr(a32[15:0], v32);
            while (((v32 & m32) != d32) && cyc0 < timeout) begin apbr(a32[15:0], v32); cyc0 = cyc0 + 1; end
            sb(cyc0 < timeout, $sformatf("poll %h mask %h value %h timeout", a32, m32, d32));
          end
          "waitlvl": begin   // poll sha_lvl.outlvl >= n
            r = $fscanf(fdl, "%d %d", nw, timeout);
            cyc0 = 0; apbr(16'h0064, v32);
            while ((v32[31:16] < nw) && cyc0 < timeout) begin apbr(16'h0064, v32); cyc0 = cyc0 + 1; end
            sb(cyc0 < timeout, $sformatf("outlvl >= %0d timeout", nw));
          end
          "axiw": begin
            r = $fscanf(fdl, "%d %d", ctxn, nw);
            for (i = 0; i < nw; i = i + 1) begin r = $fscanf(fdl, "%h", wv); mem[i] = wv; end
            axiw(ctxn[3:0], nw);
          end
          "axiwx": begin   // write burst of n words of a counting pattern, no data in the script
            r = $fscanf(fdl, "%d %d", ctxn, nw);
            for (i = 0; i < nw; i = i + 1) mem[i] = f_pat(i, 7);
            axiw(ctxn[3:0], nw);
          end
          "axir": begin r = $fscanf(fdl, "%d %d", ctxn, nw); axir(ctxn[3:0], nw); end
          "rclr": begin rn = 0; end
          "expect": begin
            r = $fscanf(fdl, "%d %d", nbytes, nexp);
            errs = 0;
            for (i = 0; i < nexp; i = i + 1) begin
              r = $fscanf(fdl, "%h", expw);
              wv = (i < rn) ? rbuf[i] : {DW{1'bx}};
              if (i == nexp - 1 && (nbytes % WB) != 0) begin
                for (k = 0; k < WB; k = k + 1)
                  if (k >= (nbytes % WB)) begin wv[8*k +: 8] = 8'h00; expw[8*k +: 8] = 8'h00; end
              end
              if (wv !== expw) errs = errs + 1;
            end
            sb((errs == 0) && (rn == nexp || rn > nexp), $sformatf("digest mismatch: %0d of %0d words differ, %0d words read", errs, nexp, rn));
            rn = 0;
          end
          "expb": begin r = $fscanf(fdl, "%d", ctxn); sb(last_bresp === ctxn[1:0], $sformatf("BRESP = %0d, expected %0d", last_bresp, ctxn[1:0])); end
          "expr": begin r = $fscanf(fdl, "%d", ctxn); sb(rresp_acc === ctxn[1:0], $sformatf("RRESP = %0d, expected %0d", rresp_acc, ctxn[1:0])); end
          "expz": begin   // all words read in the last burst are zero
            r = $fscanf(fdl, "%d", nw);
            errs = 0; for (i = 0; i < rn; i = i + 1) if (rbuf[i] !== '0) errs = errs + 1;
            sb(errs == 0 && rn >= nw, $sformatf("read data not zero: %0d nonzero of %0d", errs, rn));
            rn = 0;
          end
          "strbl": begin r = $fscanf(fdl, "%h", wv); strbl = wv[DW/8-1:0]; strbl_en = 1; end
          "strblo": begin strbl_en = 0; end
          "axir2": begin r = $fscanf(fdl, "%d %d %d", ctxn, nw, k); axir2(ctxn[3:0], nw, k); end
          "strb": begin r = $fscanf(fdl, "%h", wv); strbv = wv[DW/8-1:0]; end
          "win": begin r = $fscanf(fdl, "%d", ctxn); winbit = ctxn[0]; end
          "rwin": begin r = $fscanf(fdl, "%d", ctxn); rwinbit = ctxn[0]; end
          "burst": begin r = $fscanf(fdl, "%d", ctxn); burstv = ctxn[1:0]; end
          "rburst": begin r = $fscanf(fdl, "%d", ctxn); rburstv = ctxn[1:0]; end
          "wsize": begin r = $fscanf(fdl, "%d", wsizev); end
          "rsize": begin r = $fscanf(fdl, "%d", rsizev); end
          "awid": begin r = $fscanf(fdl, "%d", ctxn); awidv = ctxn[3:0]; end
          "pprot": begin r = $fscanf(fdl, "%d", ctxn); pprot = ctxn[2:0]; end
          "pstrbw": begin r = $fscanf(fdl, "%h", a32); pstrbw = a32[3:0]; end
          "pstrbr": begin r = $fscanf(fdl, "%h", a32); pstrbr = a32[3:0]; end
          "static": begin r = $fscanf(fdl, "%d %d", ctxn, nw); protect_en = ctxn[0]; slverr_en = nw[0]; end
          "bp": begin r = $fscanf(fdl, "%d", bp); end
          "cov": begin r = $fscanf(fdl, "%d %s", ctxn, sarg); $display("COV alg=%0d cls=%0s ctxn=%0d dw=%0d", ctxn, sarg, CTXN, DW); end
          "wait": begin r = $fscanf(fdl, "%d", nw); repeat (nw) @(posedge clk); end
          "rstc": begin r = $fscanf(fdl, "%d", nw); do_reset(ASYNC != 0 ? 1 : 3, nw); end   // PARA_CSR_ASYNC=0: the two reset ports are tied (spec 7.1)
          "rsta": begin r = $fscanf(fdl, "%d", nw); do_reset(ASYNC != 0 ? 2 : 3, nw); end
          "rstov": begin   // overlapping resets of the two domains (WF-015)
            #1; awvalid = 0; wvalid = 0; arvalid = 0; psel = 0; penable = 0;
            rst_core_n = 0; repeat (2) @(posedge clk); #1 rst_apb_n = 0; repeat (2) @(posedge clk);
            #1 rst_core_n = 1; repeat (3) @(posedge clk); #1 rst_apb_n = 1; repeat (8) @(posedge clk);
          end
          "rstb": begin r = $fscanf(fdl, "%d", nw); do_reset(3, nw); end
          "axiabort": begin   // core reset in the middle of a write burst: aw and k beats, then reset
            r = $fscanf(fdl, "%d %d %d", ctxn, nw, k);
            for (i = 0; i < nw; i = i + 1) mem[i] = f_pat(i, 3);
            @(posedge clk);
            #1 awvalid = 1; awaddr = {ctxn[3:0], 1'b0, 11'h000}; awid = awidv; awlen = nw - 1; awsize = LWB[2:0]; awburst = 2'b01;
            @(posedge clk); while (!awready) @(posedge clk);
            #1 awvalid = 0;
            for (i = 0; i < k; i = i + 1) begin
              #1 wvalid = 1; wdata = mem[i]; wlast = (i == nw - 1); wstrb = '1;
              @(posedge clk); while (!wready) @(posedge clk);
            end
            do_reset(ASYNC != 0 ? 1 : 3, 4);
            #1 wvalid = 0; wlast = 0;
          end
          "stream": begin r = $fscanf(fdl, "%d %d %d", ctxn, nw, k); stream(ctxn[3:0], nw, k); end
          "perf0": begin perf_c0 = cyc; end
          "perf1": begin r = $fscanf(fdl, "%s %d", sarg, nw); $display("PERF %0s cycles=%0d blocks=%0d", sarg, cyc - perf_c0, nw); end
          "chkirq": begin r = $fscanf(fdl, "%d", ctxn); sb(irq === ctxn[0], $sformatf("o_irq = %b, expected %0d", irq, ctxn[0])); end
          "chkalarm": begin r = $fscanf(fdl, "%d", ctxn); sb(alarm === ctxn[0], $sformatf("o_alarm = %b, expected %0d", alarm, ctxn[0])); end
          "dmadly": begin r = $fscanf(fdl, "%d", dma_dly); end
          "dmaman": begin r = $fscanf(fdl, "%d", dma_man); end
          "waitin": begin
            cyc0 = 0; while (!dma_in_req && cyc0 < 20000) begin @(posedge clk); cyc0 = cyc0 + 1; end
            sb(cyc0 < 20000, "DMA input request timeout");
            go_in = 1;
            cyc0 = 0; while ((dma_in_req || !dma_in_ack) && cyc0 < 20000) begin @(posedge clk); cyc0 = cyc0 + 1; end
            go_in = 0; @(posedge clk);
          end
          "waitout": begin
            cyc0 = 0; while (!dma_out_req && cyc0 < 40000) begin @(posedge clk); cyc0 = cyc0 + 1; end
            sb(cyc0 < 40000, "DMA output request timeout");
            go_out = 1;
            cyc0 = 0; while ((dma_out_req || !dma_out_ack) && cyc0 < 20000) begin @(posedge clk); cyc0 = cyc0 + 1; end
            go_out = 0; @(posedge clk);
          end
          "inj": begin   // inj target delay bit: a bit flip of a core register, delay cycles after the core starts
            r = $fscanf(fdl, "%d %d %d", inj_tgt, inj_dly, inj_bit);
            inj_snap = n_inj;
            inj_req = inj_req + 1;
          end
          "chkinj_inc": begin sb(n_inj == inj_snap + 1, $sformatf("injection did not happen: n_inj = %0d, snapshot %0d", n_inj, inj_snap)); end
          "chkinj": begin r = $fscanf(fdl, "%d", ctxn); sb(n_inj == ctxn, $sformatf("injections done = %0d, expected %0d", n_inj, ctxn)); end
          "ctot": begin
            // TEST-008: presets the byte counter of a context near the limit 2^61 - 1 (the limit itself cannot be shortened)
            r = $fscanf(fdl, "%d %h", nw, ctot_v);
            ctot_all = dut.u_seq.reg_ctot; ctot_all[63:0] = ctot_v;                 // context 0 only
            @(negedge clk); force dut.u_seq.w_ctot_nxt = ctot_all; @(posedge clk); #1; release dut.u_seq.w_ctot_nxt;
          end
          "hwgrp": begin r = $fscanf(fdl, "%d", hwgrp); end
          "hwdump": begin
            for (int gg = 0; gg < 2; gg++)
              for (int kk = 0; kk < 48; kk++)
                $display("HW %0d %0d %0d %0f %0f %0f %0f", gg, kk, hw_n[gg][kk], hw_sum[gg][kk][0], hw_sq[gg][kk][0], hw_sum[gg][kk][1], hw_sq[gg][kk][1]);
          end
          "entdly": begin r = $fscanf(fdl, "%d", ent_dly); end
          "chkcz": begin r = $fscanf(fdl, "%d", ctxn); sb(obs_core_zero === ctxn[0], $sformatf("core registers zero = %b, expected %0d", obs_core_zero, ctxn[0])); end
          "chkreq": begin r = $fscanf(fdl, "%d %d", nw, ctxn); sb(dma_in_req === nw[0] && dma_out_req === ctxn[0], $sformatf("DMA requests in=%b out=%b, expected in=%0d out=%0d", dma_in_req, dma_out_req, nw[0], ctxn[0])); end
          "chkdmaeq": begin r = $fscanf(fdl, "%d %d", nw, ctxn); sb(n_in_req == nw && n_out_req == ctxn, $sformatf("DMA requests in=%0d out=%0d, expected in=%0d out=%0d", n_in_req, n_out_req, nw, ctxn)); end
          "chkdma": begin r = $fscanf(fdl, "%d %d", nw, ctxn); sb(n_in_req >= nw && n_out_req >= ctxn, $sformatf("DMA requests in=%0d out=%0d", n_in_req, n_out_req)); end
          default: begin $display("TB-ERROR unknown command %0s", cmd); sb(1'b0, "unknown command"); end
        endcase
      end
    end
        $fclose(fdl);
      end
    end
  endtask

  initial begin
    if (!$value$plusargs("VEC=%s", vecname)) vecname = "script.txt";
    if (!$value$plusargs("NAME=%s", runname)) runname = "run";
    if (!$value$plusargs("VECDIR=%s", vecdir)) vecdir = ".";
    if ($value$plusargs("SEED=%d", k)) k = $urandom(k);
`ifdef VLSIT_SYNTHESIS
    $display("SIM-BRANCH: synthesis");
`else
    if (!$value$plusargs("AFIFO_MSYNC_SEED=%d", k)) k = 1;
    $display("SIM-BRANCH: metastable seed=%0d", k);
`endif
    if ($value$plusargs("VCD=%s", vcdname)) begin
      $dumpfile(vcdname);
      $dumpvars(0, tb_sha_top.dut);
      $dumpvars(0, tb_sha_top.clk);
    end
    $display("TB-CONFIG name=%0s DW=%0d CTXN=%0d ALG=%03h U256=%0d U512=%0d UKEC=%0d DMA=%0d ASYNC=%0d APBH=%0f ZERO=%0d",
             runname, DW, CTXN, ALG, U256, U512, UKEC, DMA, ASYNC, APBH, ZERO);
    #50; rst_core_n = 1; rst_apb_n = 1;
    repeat (40) @(posedge clk);
    run_script(vecname);
    repeat (20) @(posedge clk);
    $display("OUTHASH core=%016x apb=%016x", outhash, apbhash);
    $display("TB-RESULT name=%0s scoreboard pass=%0d fail=%0d cycles=%0d", runname, sb_pass, sb_fail, cyc);
    r = u_chk.report(1);
    if (sb_fail != 0 || r != 0) $display("TB FAIL");
    else $display("TB PASS");
    $finish;
  end

  integer tmo_ns = 400000000;
  initial begin
    if ($value$plusargs("TIMEOUT_NS=%d", tmo_ns)) ;
    #(tmo_ns);
    $display("TB-ERROR global timeout at script tag %0s", cur_tag);
    sb(1'b0, "global timeout");
    r = u_chk.report(1);
    $display("TB FAIL");
    $finish;
  end
endmodule
