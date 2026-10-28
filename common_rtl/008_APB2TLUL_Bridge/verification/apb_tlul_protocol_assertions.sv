`timescale 1ns/1ps
// -----------------------------------------------------------------------------------------------
// Protocol assertions for the APB4 completer port and the TL-UL host port of m_apb_tlul_bridge.
//
// 36 assertions. Each one is a named check with an antecedent and a consequent; the module counts how
// often the antecedent was true (hits) and how often the consequent failed (fails), and reports an
// assertion that never fired as NOT EXERCISED, so a check that proves nothing is visible.
//
// Written as clocked procedural checks (not SVA properties) so that they run in Icarus Verilog, which
// has no concurrent-assertion support. Every check samples at the rising clock edge, before the
// flip-flops of the design update, like a concurrent assertion would.
//
// Sources (the document and clause are in the name of each assertion):
//   APB  : Arm IHI 0024 Issue D (../../../VLSIT_CODEX_CLAUDE_SKILLS/.claude/skills/vlsit-asic-ip-microspec/reference/md_doc/vlsit_apb_amba_apb_ihi0024d.md): 3.1 write
//          transfers, 3.2 write strobes, 3.3 read transfers, 3.4 error response, 4.1 operating
//          states, Appendix A signal validity.
//   TL-UL: OpenTitan TL-UL specification (vlsit_tilelink_ul_opentitan_tlul.md) and the OpenTitan
//          protocol checker tlul_assert (vlsit_tilelink_ul_protocol_checker.md); the check names
//          legalAOpcode, sizeMatchesMask, ... are the names used there.
//   BRIDGE: requirements of this design (m_apb_tlul_bridge_Design_Specification.md).
//   CROSS: the relation between an APB transfer and its TL-UL request and response.
//
// Some rules bind the requester or the device, not the bridge; they check that the testbench
// stimulus is legal. The testbench masks three of them on purpose (inputs i_tb_*):
//   i_tb_orphan   : an orphan response is injected, so respMustHaveReq is not checked in that cycle;
//   i_tb_fault    : a wrong d_opcode or d_source is injected, so respOpcode and the source match are
//                   not checked, while the bridge must still report PSLVERR (CROSS-01 stays on);
//   i_chk_pstrb_rd: 0 while a read is driven with a non-zero PSTRB to test that the bridge ignores it.
// -----------------------------------------------------------------------------------------------
module apb_tlul_protocol_assertions #(
  parameter PARA_ADDR_W = 32,
  parameter PARA_SRC_W  = 8,
  parameter PARA_SRC_ID = 0,
  parameter MAX_WAIT    = 100     // longest legal wait in the Access phase for the models of the testbench
) (
  input wire clk,
  input wire rst_n,
  // APB4
  input wire psel,
  input wire penable,
  input wire pwrite,
  input wire [PARA_ADDR_W-1:0] paddr,
  input wire [3:0] pstrb,
  input wire [31:0] pwdata,
  input wire pready,
  input wire pslverr,
  input wire [31:0] prdata,
  // TL-UL channel A
  input wire a_valid,
  input wire a_ready,
  input wire [2:0] a_opcode,
  input wire [2:0] a_param,
  input wire [1:0] a_size,
  input wire [PARA_SRC_W-1:0] a_source,
  input wire [PARA_ADDR_W-1:0] a_address,
  input wire [3:0] a_mask,
  input wire [31:0] a_data,
  input wire [0:0] a_user,
  // TL-UL channel D
  input wire d_valid,
  input wire d_ready,
  input wire [2:0] d_opcode,
  input wire [2:0] d_param,
  input wire [1:0] d_size,
  input wire [PARA_SRC_W-1:0] d_source,
  input wire [31:0] d_data,
  input wire d_error,
  // testbench masks
  input wire i_tb_orphan,
  input wire i_tb_fault,
  input wire i_chk_pstrb_rd
);

  localparam [PARA_SRC_W-1:0] SRC = PARA_SRC_ID;
  localparam NA = 36;

  integer hit [0:NA-1];
  integer bad [0:NA-1];
  reg [8*76-1:0] nm [0:NA-1];
  integer fails = 0;
  integer vacuous = 0;
  integer k;

  initial begin
    for (k = 0; k < NA; k = k + 1) begin hit[k] = 0; bad[k] = 0; end
    // APB (14)
    nm[0]  = "APB-01 PENABLE only with PSEL (IHI0024D 4.1)";
    nm[1]  = "APB-02 Setup lasts one cycle, then Access (4.1)";
    nm[2]  = "APB-03 Access holds until PREADY (3.1, 4.1)";
    nm[3]  = "APB-04 address, control, data stable during a transfer (3.1, 4.1)";
    nm[4]  = "APB-05 PSTRB all LOW on a read (3.2)";
    nm[5]  = "APB-06 request signals known when PSEL (Appendix A)";
    nm[6]  = "APB-07 PREADY known in Access, PSLVERR and PRDATA known at the end (A, 3.4)";
    nm[7]  = "APB-08 PSLVERR only together with PREADY (3.4)";
    nm[8]  = "APB-09 BRIDGE: PREADY only in the Access phase (REQ-IF-004)";
    nm[9]  = "APB-10 PENABLE LOW after a completed transfer (4.1)";
    nm[10] = "APB-11 PENABLE LOW in the first cycle of PSEL (4.1)";
    nm[11] = "APB-12 BRIDGE: an Access phase ends within MAX_WAIT cycles";
    nm[12] = "APB-13 BRIDGE: PREADY is high for one cycle only (REQ-IF-004)";
    nm[13] = "APB-14 BRIDGE: PREADY and PSLVERR are LOW in reset (REQ-RESET-001)";
    // TL-UL (19)
    nm[14] = "TL-01 legalAOpcode: Get, PutFullData or PutPartialData";
    nm[15] = "TL-02 legalAParam: a_param is 0";
    nm[16] = "TL-03 sizeMatchesMask: 2^a_size equals the number of mask bits";
    nm[17] = "TL-04 addrSizeAligned: a_address aligned to a_size";
    nm[18] = "TL-05 contigMask: a_mask contiguous for Get and PutFullData";
    nm[19] = "TL-06 aKnown: channel A fields are not X when a_valid";
    nm[20] = "TL-07 handshake signals are not X after reset (a/d valid/ready)";
    nm[21] = "TL-08 channel A stable until a_ready (valid and every field)";
    nm[22] = "TL-09 pendingReqPerSrc: one outstanding request";
    nm[23] = "TL-10 respMustHaveReq: a response needs an accepted request";
    nm[24] = "TL-11 respOpcode: AccessAckData for Get, AccessAck otherwise";
    nm[25] = "TL-12 d_source returns the source of the request";
    nm[26] = "TL-13 respSzEqReqSz and legalDParam: d_size equals a_size, d_param is 0";
    nm[27] = "TL-14 dKnown: channel D fields are not X when d_valid";
    nm[28] = "TL-15 BRIDGE: d_ready is high from the first cycle after reset";
    nm[29] = "TL-16 BRIDGE: a request starts only after an APB Setup phase";
    nm[30] = "TL-17 BRIDGE: a_source is the constant PARA_SRC_ID";
    nm[31] = "TL-18 BRIDGE: size 4 bytes, full mask, Get or PutFullData, a_user 0";
    nm[32] = "TL-19 reset: a_valid and d_ready are LOW (TileLink 3.2.2, REQ-RESET-001)";
    // CROSS (3)
    nm[33] = "CROSS-01 the APB completion reflects the TL-UL response (PSLVERR, PRDATA)";
    nm[34] = "CROSS-02 an illegal APB request: no TL-UL request, PSLVERR in the next cycle";
    nm[35] = "CROSS-03 a legal APB request becomes the matching TL-UL request";
  end

  // ---------------------------------------------------------------- one check
  task chk;
    input integer id;
    input ante;
    input cons;
    begin
      if (ante === 1'b1) begin
        hit[id] = hit[id] + 1;
        if (cons !== 1'b1) begin
          bad[id] = bad[id] + 1;
          fails   = fails + 1;
          if (bad[id] <= 3) $display("ASSERT FAIL @%0t: %0s", $time, nm[id]);
        end
      end
    end
  endtask

  function [2:0] pc4;
    input [3:0] m;
    begin pc4 = m[0] + m[1] + m[2] + m[3]; end
  endfunction

  // ---------------------------------------------------------------- state of the previous cycle
  reg rst_q = 1'b0;
  reg started = 1'b0;
  reg psel_q = 1'b0, penable_q = 1'b0, pready_q = 1'b0, pwrite_q = 1'b0;
  reg [PARA_ADDR_W-1:0] paddr_q = 0;
  reg [3:0] pstrb_q = 4'h0;
  reg [31:0] pwdata_q = 32'h0;
  reg av_q = 1'b0, ar_q = 1'b0;
  reg [2:0] aop_q = 0;
  reg [1:0] asz_q = 0;
  reg [PARA_SRC_W-1:0] asrc_q = 0;
  reg [PARA_ADDR_W-1:0] aaddr_q = 0;
  reg [3:0] amask_q = 0;
  reg [31:0] adata_q = 0;
  reg pending = 1'b0, st_rd = 1'b0;
  reg [PARA_SRC_W-1:0] st_src = 0;
  reg [1:0] st_size = 0;
  reg x_valid = 1'b0, x_err = 1'b0;
  reg [31:0] x_data = 32'h0;
  reg setup_q = 1'b0, setup_legal_q = 1'b0, setup_wr_q = 1'b0;
  reg [PARA_ADDR_W-1:0] setup_addr_q = 0;
  reg [31:0] setup_wdata_q = 32'h0;
  integer wait_cnt = 0;

  // current-cycle helpers
  wire access = psel & penable;
  wire compl  = access & pready;
  wire fire   = a_valid & a_ready;
  wire resp   = d_valid & d_ready;
  wire setup  = psel & ~penable;
  wire legal  = (paddr[1:0] == 2'b00) & (~pwrite | (pstrb == 4'hF));

  reg resp_real, exp_err, cur_rd;
  reg [PARA_SRC_W-1:0] cur_src;
  reg [1:0] cur_size;
  reg access_q, compl_q;

  always @(posedge clk) begin
    access_q = psel_q & penable_q;
    compl_q  = access_q & pready_q;

    // ---- reset behavior (checked while the reset is low, from the second clock edge: at the first
    //      edge the flip-flops have not seen the reset yet)
    chk(13, ~rst_n & started, ~pready & ~pslverr);
    chk(32, ~rst_n & started, ~a_valid & ~d_ready);

    if (rst_n && rst_q) begin
      // ============================== APB ==============================
      chk(0,  penable, psel);
      chk(1,  setup_q, psel & penable);
      chk(2,  access_q & ~pready_q, psel & penable);
      chk(3,  psel_q & ~compl_q & psel,
              (paddr === paddr_q) & (pwrite === pwrite_q) & (pstrb === pstrb_q) &
              (~pwrite | (pwdata === pwdata_q)));
      chk(4,  psel & ~pwrite & i_chk_pstrb_rd, pstrb == 4'h0);
      chk(5,  psel, (^{paddr, pwrite, pstrb, penable}) !== 1'bx && (~pwrite | (^pwdata) !== 1'bx));
      chk(6,  access, (pready !== 1'bx) && (~compl || ((pslverr !== 1'bx) && (pwrite || pslverr || (^prdata) !== 1'bx))));
      chk(7,  pslverr, pready);
      chk(8,  pready, psel & penable);
      chk(9,  compl_q, ~penable);
      chk(10, psel & ~psel_q, ~penable);
      chk(11, access & ~pready, wait_cnt < MAX_WAIT);
      chk(12, pready_q, ~pready);

      // ============================== TL-UL channel A ==============================
      chk(14, a_valid, (a_opcode === 3'b000) || (a_opcode === 3'b001) || (a_opcode === 3'b100));
      chk(15, a_valid, a_param === 3'b000);
      chk(16, a_valid, (4'd1 << a_size) == pc4(a_mask));
      chk(17, a_valid, (a_address & ((32'd1 << a_size) - 32'd1)) == 0);
      chk(18, a_valid & (a_opcode != 3'b001),
              (a_mask === 4'b0001) || (a_mask === 4'b0010) || (a_mask === 4'b0100) || (a_mask === 4'b1000) ||
              (a_mask === 4'b0011) || (a_mask === 4'b0110) || (a_mask === 4'b1100) ||
              (a_mask === 4'b0111) || (a_mask === 4'b1110) || (a_mask === 4'b1111));
      chk(19, a_valid, ((^{a_opcode, a_param, a_size, a_source, a_address, a_mask, a_user}) !== 1'bx) &&
                       ((a_opcode == 3'b100) || ((^a_data) !== 1'bx)));
      chk(20, 1'b1,    ((^{a_valid, a_ready, d_valid, d_ready}) !== 1'bx));
      chk(21, av_q & ~ar_q,
              a_valid && (a_opcode === aop_q) && (a_size === asz_q) && (a_source === asrc_q) &&
              (a_address === aaddr_q) && (a_mask === amask_q) && (a_data === adata_q));
      chk(22, fire, ~pending);

      // ============================== TL-UL channel D ==============================
      resp_real = resp & (pending | fire);
      cur_rd    = fire ? (a_opcode == 3'b100) : st_rd;
      cur_src   = fire ? a_source : st_src;
      cur_size  = fire ? a_size : st_size;
      chk(23, resp & ~i_tb_orphan, pending | fire);
      chk(24, resp_real & ~i_tb_fault, d_opcode === (cur_rd ? 3'b001 : 3'b000));
      chk(25, resp_real & ~i_tb_fault, d_source === cur_src);
      chk(26, resp_real, (d_size === cur_size) && (d_param === 3'b000));
      chk(27, d_valid, ((^{d_opcode, d_size, d_source, d_error}) !== 1'bx) &&
                       ((d_opcode != 3'b001) || d_error || ((^d_data) !== 1'bx)));

      // ============================== BRIDGE rules ==============================
      chk(28, 1'b1, d_ready);
      chk(29, a_valid & ~av_q, setup_q);
      chk(30, a_valid, a_source === SRC);
      chk(31, a_valid, (a_size === 2'b10) && (a_mask === 4'hF) &&
                       ((a_opcode === 3'b000) || (a_opcode === 3'b100)) && (a_user === 1'b0));

      // ============================== CROSS ==============================
      chk(33, x_valid, pready && (pslverr === x_err) && (prdata === x_data));
      chk(34, setup_q & ~setup_legal_q, pready & pslverr & ~a_valid & (prdata === 32'h0));
      chk(35, setup_q & setup_legal_q,
              a_valid && (a_opcode === (setup_wr_q ? 3'b000 : 3'b100)) &&
              (a_address === {setup_addr_q[PARA_ADDR_W-1:2], 2'b00}) &&
              (~setup_wr_q || (a_data === setup_wdata_q)));
    end

    // ---- update of the tracking state
    if (!rst_n) begin
      pending = 1'b0; x_valid = 1'b0; wait_cnt = 0; setup_q = 1'b0;
      psel_q = 1'b0; penable_q = 1'b0; pready_q = 1'b0; av_q = 1'b0; ar_q = 1'b0;
    end else begin
      x_valid = 1'b0;
      resp_real = resp & (pending | fire);
      if (resp_real) begin
        exp_err = d_error | (d_opcode !== ((fire ? (a_opcode == 3'b100) : st_rd) ? 3'b001 : 3'b000)) |
                  (d_source !== (fire ? a_source : st_src));
        x_valid = 1'b1;
        x_err   = exp_err;
        x_data  = ((fire ? (a_opcode == 3'b100) : st_rd) & ~exp_err) ? d_data : 32'h0;
      end
      if (fire) begin
        st_rd = (a_opcode == 3'b100); st_src = a_source; st_size = a_size;
      end
      if (resp_real) pending = 1'b0;
      else if (fire) pending = 1'b1;
      wait_cnt = (access & ~pready) ? wait_cnt + 1 : 0;
      setup_q       = setup;
      setup_legal_q = legal;
      setup_wr_q    = pwrite;
      setup_addr_q  = paddr;
      setup_wdata_q = pwdata;
      psel_q = psel; penable_q = penable; pready_q = pready; pwrite_q = pwrite;
      paddr_q = paddr; pstrb_q = pstrb; pwdata_q = pwdata;
      av_q = a_valid; ar_q = a_ready; aop_q = a_opcode; asz_q = a_size; asrc_q = a_source;
      aaddr_q = a_address; amask_q = a_mask; adata_q = a_data;
    end
    rst_q = rst_n;
    started = 1'b1;
  end

  // ---------------------------------------------------------------- report
  task report;
    integer j;
    begin
      vacuous = 0;
      $display("---- protocol assertions: %0d checks, hits = how often the antecedent was true", NA);
      for (j = 0; j < NA; j = j + 1) begin
        if (hit[j] == 0) vacuous = vacuous + 1;
        $display("  %-76s hits %7d  fails %0d%0s", nm[j], hit[j], bad[j], (hit[j] == 0) ? "  NOT EXERCISED" : "");
      end
      $display("---- assertion failures: %0d, assertions never exercised: %0d", fails, vacuous);
    end
  endtask

endmodule
