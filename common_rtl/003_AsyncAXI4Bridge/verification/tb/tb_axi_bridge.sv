`timescale 1ns/1ps

// Testbench source of truth: AsyncAXI4Bridge resolved specification and
// Arm IHI 0022H.c A3.1.2, A3.2.1, A3.2.2 and A3.3. RTL is used only for pins.
module tb_axi_bridge;

`ifdef TB_SMALL_DEPTH
  localparam [31:0] PARA_AXI_AW_DEPTH = 32'd2;
  localparam [31:0] PARA_AXI_W_DEPTH  = 32'd2;
  localparam [31:0] PARA_AXI_B_DEPTH  = 32'd2;
  localparam [31:0] PARA_AXI_AR_DEPTH = 32'd2;
  localparam [31:0] PARA_AXI_R_DEPTH  = 32'd2;
`else
  localparam [31:0] PARA_AXI_AW_DEPTH = 32'd4;
  localparam [31:0] PARA_AXI_W_DEPTH  = 32'd16;
  localparam [31:0] PARA_AXI_B_DEPTH  = 32'd4;
  localparam [31:0] PARA_AXI_AR_DEPTH = 32'd4;
  localparam [31:0] PARA_AXI_R_DEPTH  = 32'd16;
`endif
  localparam [31:0] PARA_AXI_ADDR_W = 32'd32;
  localparam [31:0] PARA_AXI_DATA_W = 32'd32;
  localparam [31:0] PARA_AXI_ID_W = 32'd4;
  localparam [31:0] PARA_AXI_CELL_TYPE = 32'd2;
  localparam [31:0] PARA_AXI_MEM_USE_MACRO = 32'd0;
  localparam [31:0] PARA_AXI_AWUSER_W = 32'd1;
  localparam [31:0] PARA_AXI_WUSER_W = 32'd1;
  localparam [31:0] PARA_AXI_BUSER_W = 32'd1;
  localparam [31:0] PARA_AXI_ARUSER_W = 32'd1;
  localparam [31:0] PARA_AXI_RUSER_W = 32'd1;
  localparam integer AW_COUNT = 6;
  localparam integer W_COUNT = 24;
  localparam integer AR_COUNT = 6;
  localparam integer B_COUNT = 6;
  localparam integer R_COUNT = 24;
  localparam integer ASSERT_COUNT = 36;

  logic i_clk_sub = 1'b0;
  logic i_clk_mgr = 1'b0;
  logic i_rst_n_sub;
  logic i_rst_n_mgr;

  // Common AXI4 pin superset. AXI3 and AXI4 base leave absent optional pins unused.
  logic i_axi_awvalid;
  logic o_axi_awready;
  logic [3:0] i_axi_awid;
  logic [31:0] i_axi_awaddr;
`ifdef TB_AXI3
  logic [3:0] i_axi_awlen;
`else
  logic [7:0] i_axi_awlen;
`endif
  logic [2:0] i_axi_awsize;
  logic [1:0] i_axi_awburst;
`ifdef TB_AXI3
  logic [1:0] i_axi_awlock;
`else
  logic i_axi_awlock;
`endif
  logic [3:0] i_axi_awcache;
  logic [2:0] i_axi_awprot;
  logic [3:0] i_axi_awqos;
  logic [3:0] i_axi_awregion;
  logic i_axi_awuser;
  logic o_axi_awvalid;
  logic i_axi_awready;
  logic [3:0] o_axi_awid;
  logic [31:0] o_axi_awaddr;
`ifdef TB_AXI3
  logic [3:0] o_axi_awlen;
`else
  logic [7:0] o_axi_awlen;
`endif
  logic [2:0] o_axi_awsize;
  logic [1:0] o_axi_awburst;
`ifdef TB_AXI3
  logic [1:0] o_axi_awlock;
`else
  logic o_axi_awlock;
`endif
  logic [3:0] o_axi_awcache;
  logic [2:0] o_axi_awprot;
  logic [3:0] o_axi_awqos;
  logic [3:0] o_axi_awregion;
  logic o_axi_awuser;

  logic i_axi_wvalid;
  logic o_axi_wready;
  logic [3:0] i_axi_wid;
  logic [31:0] i_axi_wdata;
  logic [3:0] i_axi_wstrb;
  logic i_axi_wlast;
  logic i_axi_wuser;
  logic o_axi_wvalid;
  logic i_axi_wready;
  logic [3:0] o_axi_wid;
  logic [31:0] o_axi_wdata;
  logic [3:0] o_axi_wstrb;
  logic o_axi_wlast;
  logic o_axi_wuser;

  logic i_axi_bvalid;
  logic o_axi_bready;
  logic [3:0] i_axi_bid;
  logic [1:0] i_axi_bresp;
  logic i_axi_buser;
  logic o_axi_bvalid;
  logic i_axi_bready;
  logic [3:0] o_axi_bid;
  logic [1:0] o_axi_bresp;
  logic o_axi_buser;

  logic i_axi_arvalid;
  logic o_axi_arready;
  logic [3:0] i_axi_arid;
  logic [31:0] i_axi_araddr;
`ifdef TB_AXI3
  logic [3:0] i_axi_arlen;
`else
  logic [7:0] i_axi_arlen;
`endif
  logic [2:0] i_axi_arsize;
  logic [1:0] i_axi_arburst;
`ifdef TB_AXI3
  logic [1:0] i_axi_arlock;
`else
  logic i_axi_arlock;
`endif
  logic [3:0] i_axi_arcache;
  logic [2:0] i_axi_arprot;
  logic [3:0] i_axi_arqos;
  logic [3:0] i_axi_arregion;
  logic i_axi_aruser;
  logic o_axi_arvalid;
  logic i_axi_arready;
  logic [3:0] o_axi_arid;
  logic [31:0] o_axi_araddr;
`ifdef TB_AXI3
  logic [3:0] o_axi_arlen;
`else
  logic [7:0] o_axi_arlen;
`endif
  logic [2:0] o_axi_arsize;
  logic [1:0] o_axi_arburst;
`ifdef TB_AXI3
  logic [1:0] o_axi_arlock;
`else
  logic o_axi_arlock;
`endif
  logic [3:0] o_axi_arcache;
  logic [2:0] o_axi_arprot;
  logic [3:0] o_axi_arqos;
  logic [3:0] o_axi_arregion;
  logic o_axi_aruser;

  logic i_axi_rvalid;
  logic o_axi_rready;
  logic [3:0] i_axi_rid;
  logic [31:0] i_axi_rdata;
  logic [1:0] i_axi_rresp;
  logic i_axi_rlast;
  logic i_axi_ruser;
  logic o_axi_rvalid;
  logic i_axi_rready;
  logic [3:0] o_axi_rid;
  logic [31:0] o_axi_rdata;
  logic [1:0] o_axi_rresp;
  logic o_axi_rlast;
  logic o_axi_ruser;

`ifdef TB_AXI3
  `define PACK_AW_SRC {i_axi_awid, i_axi_awaddr, i_axi_awlen, i_axi_awsize, i_axi_awburst, i_axi_awlock, i_axi_awcache, i_axi_awprot}
  `define PACK_AW_DST {o_axi_awid, o_axi_awaddr, o_axi_awlen, o_axi_awsize, o_axi_awburst, o_axi_awlock, o_axi_awcache, o_axi_awprot}
  `define PACK_AR_SRC {i_axi_arid, i_axi_araddr, i_axi_arlen, i_axi_arsize, i_axi_arburst, i_axi_arlock, i_axi_arcache, i_axi_arprot}
  `define PACK_AR_DST {o_axi_arid, o_axi_araddr, o_axi_arlen, o_axi_arsize, o_axi_arburst, o_axi_arlock, o_axi_arcache, o_axi_arprot}
  `define PACK_W_SRC {i_axi_wid, i_axi_wdata, i_axi_wstrb, i_axi_wlast}
  `define PACK_W_DST {o_axi_wid, o_axi_wdata, o_axi_wstrb, o_axi_wlast}
`elsif TB_AXI4_USER
  `define PACK_AW_SRC {i_axi_awid, i_axi_awaddr, i_axi_awlen, i_axi_awsize, i_axi_awburst, i_axi_awlock, i_axi_awcache, i_axi_awprot, i_axi_awqos, i_axi_awregion, i_axi_awuser}
  `define PACK_AW_DST {o_axi_awid, o_axi_awaddr, o_axi_awlen, o_axi_awsize, o_axi_awburst, o_axi_awlock, o_axi_awcache, o_axi_awprot, o_axi_awqos, o_axi_awregion, o_axi_awuser}
  `define PACK_AR_SRC {i_axi_arid, i_axi_araddr, i_axi_arlen, i_axi_arsize, i_axi_arburst, i_axi_arlock, i_axi_arcache, i_axi_arprot, i_axi_arqos, i_axi_arregion, i_axi_aruser}
  `define PACK_AR_DST {o_axi_arid, o_axi_araddr, o_axi_arlen, o_axi_arsize, o_axi_arburst, o_axi_arlock, o_axi_arcache, o_axi_arprot, o_axi_arqos, o_axi_arregion, o_axi_aruser}
  `define PACK_W_SRC {i_axi_wdata, i_axi_wstrb, i_axi_wlast, i_axi_wuser[0]}
  `define PACK_W_DST {o_axi_wdata, o_axi_wstrb, o_axi_wlast, o_axi_wuser[0]}
  `define PACK_B_SRC {i_axi_bid, i_axi_bresp, i_axi_buser[0]}
  `define PACK_B_DST {o_axi_bid, o_axi_bresp, o_axi_buser[0]}
  `define PACK_R_SRC {i_axi_rid, i_axi_rdata, i_axi_rresp, i_axi_rlast, i_axi_ruser[0]}
  `define PACK_R_DST {o_axi_rid, o_axi_rdata, o_axi_rresp, o_axi_rlast, o_axi_ruser[0]}
`else
  `define PACK_AW_SRC {i_axi_awid, i_axi_awaddr, i_axi_awlen, i_axi_awsize, i_axi_awburst, i_axi_awlock, i_axi_awcache, i_axi_awprot, i_axi_awqos, i_axi_awregion}
  `define PACK_AW_DST {o_axi_awid, o_axi_awaddr, o_axi_awlen, o_axi_awsize, o_axi_awburst, o_axi_awlock, o_axi_awcache, o_axi_awprot, o_axi_awqos, o_axi_awregion}
  `define PACK_AR_SRC {i_axi_arid, i_axi_araddr, i_axi_arlen, i_axi_arsize, i_axi_arburst, i_axi_arlock, i_axi_arcache, i_axi_arprot, i_axi_arqos, i_axi_arregion}
  `define PACK_AR_DST {o_axi_arid, o_axi_araddr, o_axi_arlen, o_axi_arsize, o_axi_arburst, o_axi_arlock, o_axi_arcache, o_axi_arprot, o_axi_arqos, o_axi_arregion}
  `define PACK_W_SRC {i_axi_wdata, i_axi_wstrb, i_axi_wlast}
  `define PACK_W_DST {o_axi_wdata, o_axi_wstrb, o_axi_wlast}
  `define PACK_B_SRC {i_axi_bid, i_axi_bresp}
  `define PACK_B_DST {o_axi_bid, o_axi_bresp}
  `define PACK_R_SRC {i_axi_rid, i_axi_rdata, i_axi_rresp, i_axi_rlast}
  `define PACK_R_DST {o_axi_rid, o_axi_rdata, o_axi_rresp, o_axi_rlast}
`endif
`ifdef TB_AXI3
  `define PACK_B_SRC {i_axi_bid, i_axi_bresp}
  `define PACK_B_DST {o_axi_bid, o_axi_bresp}
  `define PACK_R_SRC {i_axi_rid, i_axi_rdata, i_axi_rresp, i_axi_rlast}
  `define PACK_R_DST {o_axi_rid, o_axi_rdata, o_axi_rresp, o_axi_rlast}
`endif

`ifdef TB_AXI3
  m_vlsit_axi3_async_top #(
    .PARA_AXI_ADDR_W(PARA_AXI_ADDR_W), .PARA_AXI_DATA_W(PARA_AXI_DATA_W),
    .PARA_AXI_ID_W(PARA_AXI_ID_W), .PARA_AXI_AW_DEPTH(PARA_AXI_AW_DEPTH),
    .PARA_AXI_W_DEPTH(PARA_AXI_W_DEPTH), .PARA_AXI_B_DEPTH(PARA_AXI_B_DEPTH),
    .PARA_AXI_AR_DEPTH(PARA_AXI_AR_DEPTH), .PARA_AXI_R_DEPTH(PARA_AXI_R_DEPTH),
    .PARA_AXI_CELL_TYPE(PARA_AXI_CELL_TYPE), .PARA_AXI_MEM_USE_MACRO(PARA_AXI_MEM_USE_MACRO)
  ) dut (.*);
`elsif TB_AXI4_USER
  m_vlsit_axi_user_async_top #(
    .PARA_AXI_ADDR_W(PARA_AXI_ADDR_W), .PARA_AXI_DATA_W(PARA_AXI_DATA_W),
    .PARA_AXI_ID_W(PARA_AXI_ID_W), .PARA_AXI_AWUSER_W(PARA_AXI_AWUSER_W),
    .PARA_AXI_WUSER_W(PARA_AXI_WUSER_W), .PARA_AXI_BUSER_W(PARA_AXI_BUSER_W),
    .PARA_AXI_ARUSER_W(PARA_AXI_ARUSER_W), .PARA_AXI_RUSER_W(PARA_AXI_RUSER_W),
    .PARA_AXI_AW_DEPTH(PARA_AXI_AW_DEPTH), .PARA_AXI_W_DEPTH(PARA_AXI_W_DEPTH),
    .PARA_AXI_B_DEPTH(PARA_AXI_B_DEPTH), .PARA_AXI_AR_DEPTH(PARA_AXI_AR_DEPTH),
    .PARA_AXI_R_DEPTH(PARA_AXI_R_DEPTH), .PARA_AXI_CELL_TYPE(PARA_AXI_CELL_TYPE),
    .PARA_AXI_MEM_USE_MACRO(PARA_AXI_MEM_USE_MACRO)
  ) dut (.*);
`else
  m_vlsit_axi_async_top #(
    .PARA_AXI_ADDR_W(PARA_AXI_ADDR_W), .PARA_AXI_DATA_W(PARA_AXI_DATA_W),
    .PARA_AXI_ID_W(PARA_AXI_ID_W), .PARA_AXI_AW_DEPTH(PARA_AXI_AW_DEPTH),
    .PARA_AXI_W_DEPTH(PARA_AXI_W_DEPTH), .PARA_AXI_B_DEPTH(PARA_AXI_B_DEPTH),
    .PARA_AXI_AR_DEPTH(PARA_AXI_AR_DEPTH), .PARA_AXI_R_DEPTH(PARA_AXI_R_DEPTH),
    .PARA_AXI_CELL_TYPE(PARA_AXI_CELL_TYPE), .PARA_AXI_MEM_USE_MACRO(PARA_AXI_MEM_USE_MACRO)
  ) dut (.*);
`endif

  // Each channel has an independent reference queue. The destination must return
  // the oldest accepted payload unchanged (REQ-FUNC-001/003; IHI 0022H.c A3.2.1).
  logic [511:0] exp_aw [0:255];
  logic [511:0] exp_w  [0:255];
  logic [511:0] exp_b  [0:255];
  logic [511:0] exp_ar [0:255];
  logic [511:0] exp_r  [0:255];
  integer aw_head, aw_tail, w_head, w_tail, b_head, b_tail, ar_head, ar_tail, r_head, r_tail;
  integer out_aw, out_w, out_b, out_ar, out_r;
  logic src_aw_stall, dst_aw_stall, src_w_stall, dst_w_stall;
  logic src_b_stall, dst_b_stall, src_ar_stall, dst_ar_stall, src_r_stall, dst_r_stall;
  logic [511:0] prev_src_aw, prev_dst_aw, prev_src_w, prev_dst_w;
  logic [511:0] prev_src_b, prev_dst_b, prev_src_ar, prev_dst_ar, prev_src_r, prev_dst_r;
  integer assertion_hits [0:ASSERT_COUNT-1];
  integer assertion_fails [0:ASSERT_COUNT-1];
  integer assertion_fail_total;
  integer assertion_never_total;
  integer idx;
  integer seed_value;
  integer init_seed;
  reg [8*512-1:0] vcd_path;

  task automatic chk;
    input integer check_id;
    input antecedent;
    input consequent;
    begin
      if (antecedent === 1'b1) begin
        assertion_hits[check_id] = assertion_hits[check_id] + 1;
        if (consequent !== 1'b1) begin
          assertion_fails[check_id] = assertion_fails[check_id] + 1;
          $display("ASSERT FAIL AXI-SVA-%02d time=%0t", check_id, $time);
        end
      end
    end
  endtask

  // Source-side AXI VALID/payload hold checks (IHI 0022H.c A3.2.1).
  `define MON_SRC(BASE, CLK, RST, VALID, READY, PACK, TAIL, EXPECT, STALL, PREV) \
  always @(posedge CLK) begin \
    if (RST !== 1'b1) begin STALL = 1'b0; TAIL = 0; end \
    else begin \
      chk(BASE, STALL, VALID); \
      chk(BASE+1, STALL, ((PACK) === PREV)); \
      chk(BASE+5, VALID, ((^(PACK)) !== 1'bx)); \
      if ((VALID === 1'b1) && (READY === 1'b1)) begin EXPECT[TAIL] = (PACK); TAIL = TAIL + 1; end \
      STALL = (VALID === 1'b1) && (READY !== 1'b1); PREV = (PACK); \
    end \
  end

  // Destination-side hold and oldest-word checks (REQ-FUNC-001/004; A3.2.1/A3.2.2).
  `define MON_DST(BASE, CLK, RST, VALID, READY, PACK, HEAD, TAIL, EXPECT, STALL, PREV, OUT_COUNT) \
  always @(posedge CLK) begin \
    if (RST !== 1'b1) begin STALL = 1'b0; HEAD = 0; OUT_COUNT = 0; \
      chk(35, 1'b1, !(o_axi_awvalid || o_axi_wvalid || o_axi_arvalid || o_axi_bvalid || o_axi_rvalid)); end \
    else begin \
      chk(BASE+2, STALL, VALID); \
      chk(BASE+3, STALL, ((PACK) === PREV)); \
      chk(BASE+6, VALID, ((^(PACK)) !== 1'bx)); \
      if ((VALID === 1'b1) && (READY === 1'b1)) begin \
        chk(BASE+4, 1'b1, (HEAD < TAIL) && ((PACK) === EXPECT[HEAD])); \
        HEAD = HEAD + 1; OUT_COUNT = OUT_COUNT + 1; \
      end \
      STALL = (VALID === 1'b1) && (READY !== 1'b1); PREV = (PACK); \
    end \
  end

  `MON_SRC(0,  i_clk_sub, i_rst_n_sub, i_axi_awvalid, o_axi_awready, `PACK_AW_SRC, aw_tail, exp_aw, src_aw_stall, prev_src_aw)
  `MON_DST(0,  i_clk_mgr, i_rst_n_mgr, o_axi_awvalid, i_axi_awready, `PACK_AW_DST, aw_head, aw_tail, exp_aw, dst_aw_stall, prev_dst_aw, out_aw)
  `MON_SRC(7,  i_clk_sub, i_rst_n_sub, i_axi_wvalid, o_axi_wready, `PACK_W_SRC, w_tail, exp_w, src_w_stall, prev_src_w)
  `MON_DST(7,  i_clk_mgr, i_rst_n_mgr, o_axi_wvalid, i_axi_wready, `PACK_W_DST, w_head, w_tail, exp_w, dst_w_stall, prev_dst_w, out_w)
  `MON_SRC(14, i_clk_mgr, i_rst_n_mgr, i_axi_bvalid, o_axi_bready, `PACK_B_SRC, b_tail, exp_b, src_b_stall, prev_src_b)
  `MON_DST(14, i_clk_sub, i_rst_n_sub, o_axi_bvalid, i_axi_bready, `PACK_B_DST, b_head, b_tail, exp_b, dst_b_stall, prev_dst_b, out_b)
  `MON_SRC(21, i_clk_sub, i_rst_n_sub, i_axi_arvalid, o_axi_arready, `PACK_AR_SRC, ar_tail, exp_ar, src_ar_stall, prev_src_ar)
  `MON_DST(21, i_clk_mgr, i_rst_n_mgr, o_axi_arvalid, i_axi_arready, `PACK_AR_DST, ar_head, ar_tail, exp_ar, dst_ar_stall, prev_dst_ar, out_ar)
  `MON_SRC(28, i_clk_mgr, i_rst_n_mgr, i_axi_rvalid, o_axi_rready, `PACK_R_SRC, r_tail, exp_r, src_r_stall, prev_src_r)
  `MON_DST(28, i_clk_sub, i_rst_n_sub, o_axi_rvalid, i_axi_rready, `PACK_R_DST, r_head, r_tail, exp_r, dst_r_stall, prev_dst_r, out_r)

  // Driver tasks hold VALID and every payload bit until the source handshake.
  task automatic send_aw(input integer first, input integer count);
    integer k;
    begin
      for (k = first; k < first + count; k = k + 1) begin
        @(negedge i_clk_sub);
        i_axi_awvalid = 1'b1;
        if (k == 0) $display("WF-MARK WF-004 END_NS=%0.3f", $realtime);
        i_axi_awid = (k + seed_value) & 15;
        i_axi_awaddr = 32'h00001000 + (k * 16) + (seed_value & 32'hf0);
        i_axi_awlen = (k == 0) ? 8'd3 : ((k == 1) ? 8'd15 : 8'd0);
        i_axi_awsize = 3'd2;
        i_axi_awburst = 2'b01;
`ifdef TB_AXI3
        i_axi_awlock = k % 3;
`else
        i_axi_awlock = k % 2;
`endif
        i_axi_awcache = 4'h3;
        i_axi_awprot = 3'h1;
        i_axi_awqos = k & 15;
        i_axi_awregion = (k + 2) & 15;
        i_axi_awuser = k & 1;
        do @(posedge i_clk_sub); while (o_axi_awready !== 1'b1);
      end
      @(negedge i_clk_sub); i_axi_awvalid = 1'b0;
    end
  endtask

  task automatic send_w(input integer first, input integer count);
    integer k;
    begin
      for (k = first; k < first + count; k = k + 1) begin
        @(negedge i_clk_sub);
        if (k == 4) $display("WF-MARK WF-010 START_NS=%0.3f", $realtime);
        i_axi_wvalid = 1'b1;
        if (k < 4) i_axi_wid = (seed_value & 15);
        else if (k < 20) i_axi_wid = ((seed_value + 1) & 15);
        else i_axi_wid = ((seed_value + k - 18) & 15);
        i_axi_wdata = 32'h01000000 + k + seed_value;
        i_axi_wstrb = 4'hf;
        i_axi_wlast = ((k == 3) || (k == 19) || (k >= 20));
        i_axi_wuser = k & 1;
        do @(posedge i_clk_sub); while (o_axi_wready !== 1'b1);
      end
      @(negedge i_clk_sub); i_axi_wvalid = 1'b0;
    end
  endtask

  task automatic send_b(input integer first, input integer count);
    integer k;
    begin
      for (k = first; k < first + count; k = k + 1) begin
        @(negedge i_clk_mgr);
        i_axi_bvalid = 1'b1;
        i_axi_bid = (k + seed_value) & 15;
        i_axi_bresp = k % 4;
        i_axi_buser = k & 1;
        do @(posedge i_clk_mgr); while (o_axi_bready !== 1'b1);
      end
      @(negedge i_clk_mgr); i_axi_bvalid = 1'b0;
    end
  endtask

  task automatic send_ar(input integer first, input integer count);
    integer k;
    begin
      for (k = first; k < first + count; k = k + 1) begin
        @(negedge i_clk_sub);
        i_axi_arvalid = 1'b1;
        i_axi_arid = (k + seed_value) & 15;
        i_axi_araddr = 32'h00002000 + (k * 16) + (seed_value & 32'hf0);
        i_axi_arlen = 8'd3;
        i_axi_arsize = 3'd2;
        i_axi_arburst = 2'b01;
`ifdef TB_AXI3
        i_axi_arlock = k % 3;
`else
        i_axi_arlock = k % 2;
`endif
        i_axi_arcache = 4'h3;
        i_axi_arprot = 3'h1;
        i_axi_arqos = k & 15;
        i_axi_arregion = (k + 3) & 15;
        i_axi_aruser = k & 1;
        do @(posedge i_clk_sub); while (o_axi_arready !== 1'b1);
      end
      @(negedge i_clk_sub); i_axi_arvalid = 1'b0;
    end
  endtask

  task automatic send_r(input integer first, input integer count);
    integer k;
    begin
      for (k = first; k < first + count; k = k + 1) begin
        @(negedge i_clk_mgr);
        i_axi_rvalid = 1'b1;
        i_axi_rid = ((k / 4) + seed_value) & 15;
        i_axi_rdata = 32'h80000000 + k + seed_value;
        i_axi_rresp = k % 4;
        i_axi_rlast = ((k % 4) == 3);
        i_axi_ruser = k & 1;
        do @(posedge i_clk_mgr); while (o_axi_rready !== 1'b1);
      end
      @(negedge i_clk_mgr); i_axi_rvalid = 1'b0;
    end
  endtask

  always #5 i_clk_sub = ~i_clk_sub;
  initial begin #1; forever #7 i_clk_mgr = ~i_clk_mgr; end

  initial begin
    i_rst_n_sub = 1'b0; i_rst_n_mgr = 1'b0;
    i_axi_awvalid = 0; i_axi_awid = 0; i_axi_awaddr = 0; i_axi_awlen = 0; i_axi_awsize = 0;
    i_axi_awburst = 0; i_axi_awlock = 0; i_axi_awcache = 0; i_axi_awprot = 0; i_axi_awqos = 0;
    i_axi_awregion = 0; i_axi_awuser = 0; i_axi_awready = 0;
    i_axi_wvalid = 0; i_axi_wid = 0; i_axi_wdata = 0; i_axi_wstrb = 0; i_axi_wlast = 0;
    i_axi_wuser = 0; i_axi_wready = 0;
    i_axi_bvalid = 0; i_axi_bid = 0; i_axi_bresp = 0; i_axi_buser = 0; i_axi_bready = 0;
    i_axi_arvalid = 0; i_axi_arid = 0; i_axi_araddr = 0; i_axi_arlen = 0; i_axi_arsize = 0;
    i_axi_arburst = 0; i_axi_arlock = 0; i_axi_arcache = 0; i_axi_arprot = 0; i_axi_arqos = 0;
    i_axi_arregion = 0; i_axi_aruser = 0; i_axi_arready = 0;
    i_axi_rvalid = 0; i_axi_rid = 0; i_axi_rdata = 0; i_axi_rresp = 0; i_axi_rlast = 0;
    i_axi_ruser = 0; i_axi_rready = 0;
    for (idx = 0; idx < ASSERT_COUNT; idx = idx + 1) begin assertion_hits[idx] = 0; assertion_fails[idx] = 0; end
    aw_head=0; aw_tail=0; w_head=0; w_tail=0; b_head=0; b_tail=0; ar_head=0; ar_tail=0; r_head=0; r_tail=0;
    out_aw=0; out_w=0; out_b=0; out_ar=0; out_r=0;
    src_aw_stall=0; dst_aw_stall=0; src_w_stall=0; dst_w_stall=0; src_b_stall=0; dst_b_stall=0;
    src_ar_stall=0; dst_ar_stall=0; src_r_stall=0; dst_r_stall=0;
    seed_value = 1;
    if ($value$plusargs("SEED=%d", seed_value)) begin end
`ifdef VLSIT_SYNTHESIS
    $display("SIM-BRANCH: synthesis");
`else
    init_seed = 1;
    if ($value$plusargs("AFIFO_MSYNC_SEED=%d", init_seed)) begin end
    $display("SIM-BRANCH: metastable seed=%0d", init_seed);
`endif
`ifdef TB_AXI3
    $display("PROFILE: AXI3");
`elsif TB_AXI4_USER
    $display("PROFILE: AXI4_USER");
`else
    $display("PROFILE: AXI4_BASE");
`endif
`ifdef TB_SMALL_DEPTH
    $display("FIFO_DEPTH_PROFILE: all depth=2");
`else
    $display("FIFO_DEPTH_PROFILE: AW/B/AR=4, W/R=16");
`endif
    if ($value$plusargs("VCD=%s", vcd_path)) begin $dumpfile(vcd_path); $dumpvars(0, tb_axi_bridge); end

    // Reset release is synchronized externally to each clock domain (REQ-RESET-001).
    $display("WF-MARK WF-009 START_NS=%0.3f", $realtime);
    repeat (3) @(negedge i_clk_sub);
    i_rst_n_sub = 1'b1;
    repeat (2) @(negedge i_clk_mgr);
    i_rst_n_mgr = 1'b1;
    repeat (4) @(posedge i_clk_sub);

    // Hold all destinations to force FIFO-full back-pressure in every channel.
    // Send one W beat before AW to exercise independent channel timing (WF-004).
    $display("WF-MARK WF-001 START_NS=%0.3f", $realtime);
    $display("WF-MARK WF-002 START_NS=%0.3f", $realtime);
    $display("WF-MARK WF-003 START_NS=%0.3f", $realtime);
    $display("WF-MARK WF-004 START_NS=%0.3f", $realtime);
    $display("WF-MARK WF-007 START_NS=%0.3f", $realtime);
    $display("WF-MARK WF-008 START_NS=%0.3f", $realtime);
    $display("WF-MARK WF-011 START_NS=%0.3f", $realtime);
    i_axi_awready = 0; i_axi_wready = 0; i_axi_arready = 0; i_axi_bready = 0; i_axi_rready = 0;
    fork
      send_w(0, 1);
    join
    fork
      send_aw(0, AW_COUNT);
      send_w(1, W_COUNT-1);
      send_ar(0, AR_COUNT);
      begin
        #500;
        i_axi_awready = 1; i_axi_wready = 1; i_axi_arready = 1;
      end
    join
    wait ((out_aw == AW_COUNT) && (out_w == W_COUNT) && (out_ar == AR_COUNT));
    $display("WF-MARK WF-001 END_NS=%0.3f", $realtime);
    $display("WF-MARK WF-002 END_NS=%0.3f", $realtime);
    $display("WF-MARK WF-003 END_NS=%0.3f", $realtime);
    $display("WF-MARK WF-010 END_NS=%0.3f", $realtime);
    $display("WF-MARK WF-011 END_NS=%0.3f", $realtime);
    repeat (8) @(posedge i_clk_mgr);

    // Return responses only after their associated address/data requests reached
    // the manager model. Back-pressure the subordinate-side response channels.
    $display("WF-MARK WF-005 START_NS=%0.3f", $realtime);
    $display("WF-MARK WF-006 START_NS=%0.3f", $realtime);
    fork
      send_b(0, B_COUNT);
      send_r(0, R_COUNT);
      begin
        #500;
        i_axi_bready = 1; i_axi_rready = 1;
      end
    join
    wait ((out_b == B_COUNT) && (out_r == R_COUNT));
    $display("WF-MARK WF-005 END_NS=%0.3f", $realtime);
    $display("WF-MARK WF-006 END_NS=%0.3f", $realtime);
    $display("WF-MARK WF-007 END_NS=%0.3f", $realtime);
    $display("WF-MARK WF-008 END_NS=%0.3f", $realtime);
    $display("WF-MARK WF-009 END_NS=%0.3f", $realtime);
    repeat (10) @(posedge i_clk_sub);

    assertion_fail_total = 0;
    assertion_never_total = 0;
    for (idx = 0; idx < ASSERT_COUNT; idx = idx + 1) begin
      if (assertion_hits[idx] == 0) assertion_never_total = assertion_never_total + 1;
      assertion_fail_total = assertion_fail_total + assertion_fails[idx];
      $display("AXI-SVA-%02d hits=%0d fails=%0d", idx, assertion_hits[idx], assertion_fails[idx]);
    end
    $display("TRANSFER COUNTS: AW=%0d W=%0d B=%0d AR=%0d R=%0d", out_aw, out_w, out_b, out_ar, out_r);
    if ((assertion_fail_total != 0) || (assertion_never_total != 0))
      $fatal(1, "verification failed: failures=%0d never=%0d", assertion_fail_total, assertion_never_total);
    $display("assertion failures: 0, assertions never exercised: 0");
    $finish;
  end

  initial begin
    #200000;
    $fatal(1, "simulation timeout");
  end
endmodule
