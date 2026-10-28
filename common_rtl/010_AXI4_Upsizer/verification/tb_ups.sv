// Testbench of the AXI4 / AXI3 upsizer (verification code, not part of the design file set).
//
// Derived from the specification AXI4_Upsizer_Design_Specification.md (REQ-FUNC-001..018, REQ-IF-*, REQ-PARAM-*,
// REQ-ERR-*, test plan TEST-001..021, assertions SVA-001..009, coverage COV-001..006) and from the AMBA AXI
// protocol IHI 0022 (A3.4.1 burst address, A3.4.4 data bus, A3.3 channel order). The RTL is read only for the port
// names, widths and parameters. Every expected value below comes from the specification.
//
//   S side : AXI manager model (TB drives), golden memory = "direct S-side access" (REQ-FUNC-001)
//   M side : AXI subordinate model with a byte memory (the IP drives); the final memory must equal the golden one
//   Checks : attribute conversion (REQ-FUNC-002..006,015,017), write data (byte memory), read data and RESP
//            (REQ-FUNC-012,013), B pass (REQ-FUNC-011), order (REQ-FUNC-014), W after AW (REQ-FUNC-010),
//            outstanding limit (REQ-PARAM-003), reset (REQ-IF-004), protocol assertions (ups_axi_chk).
//
// Plusargs: +SEED=<n> +TEST=<name or all> +VCD=<file> +NBATCH=<n> +NTX=<n>
`timescale 1ns/1ps

module tb_ups #(
  parameter int PROFILE  = 4,     // 4 = AXI4 top, 3 = AXI3 top
  parameter int S_W      = 32,
  parameter int M_W      = 128,
  parameter int ADDR_W   = 32,
  parameter int ID_W     = 4,
  parameter int WR_DEPTH = 4,
  parameter int RD_DEPTH = 4,
  parameter int IL_DEPTH = 2,
  parameter int NTX      = 120,   // transactions of one random batch (write and read each)
  parameter int NBATCH   = 4      // random batches with different delay settings
) ();

  localparam int SB   = S_W / 8;
  localparam int MB   = M_W / 8;
  localparam int LSB  = $clog2(SB);
  localparam int LMB  = $clog2(MB);
  localparam int RATIO = M_W / S_W;
  localparam int IDN  = 1 << ID_W;
  localparam int NT   = 4096;      // transactions per test
  localparam bit AXI3 = (PROFILE == 3);

  // ---------------------------------------------------------------------------------------------------
  // clock, reset, random numbers
  // ---------------------------------------------------------------------------------------------------
  logic clk = 1'b0;
  logic rst_n = 1'b0;
  always #5 clk = ~clk;

  int unsigned rng;
  function automatic int unsigned rnd();
    rng = rng ^ (rng << 13);
    rng = rng ^ (rng >> 17);
    rng = rng ^ (rng << 5);
    return rng;
  endfunction
  function automatic bit pct(input int p);
    return (int'(rnd() % 100) < p);
  endfunction
  function automatic int rr(input int n);   // 0 .. n-1
    return int'(rnd() % n);
  endfunction

  // ---------------------------------------------------------------------------------------------------
  // signals
  // ---------------------------------------------------------------------------------------------------
  // S side (the testbench drives)
  logic                 s_awvalid;  logic [ID_W-1:0] s_awid;  logic [ADDR_W-1:0] s_awaddr;  logic [7:0] s_awlen;
  logic [2:0] s_awsize;  logic [1:0] s_awburst;  logic [1:0] s_awlock;  logic [3:0] s_awcache;  logic [2:0] s_awprot;
  logic [3:0] s_awqos;   logic [3:0] s_awregion;  wire s_awready;
  logic                 s_wvalid;   logic [ID_W-1:0] s_wid;   logic [S_W-1:0] s_wdata;  logic [SB-1:0] s_wstrb;  logic s_wlast;
  wire                  s_wready;
  wire                  s_bvalid;   wire [ID_W-1:0] s_bid;    wire [1:0] s_bresp;      logic s_bready;
  logic                 s_arvalid;  logic [ID_W-1:0] s_arid;  logic [ADDR_W-1:0] s_araddr;  logic [7:0] s_arlen;
  logic [2:0] s_arsize;  logic [1:0] s_arburst;  logic [1:0] s_arlock;  logic [3:0] s_arcache;  logic [2:0] s_arprot;
  logic [3:0] s_arqos;   logic [3:0] s_arregion;  wire s_arready;
  wire                  s_rvalid;   wire [ID_W-1:0] s_rid;    wire [S_W-1:0] s_rdata;  wire [1:0] s_rresp;  wire s_rlast;
  logic                 s_rready;
  // M side (the IP drives the requests, the testbench answers)
  wire                  m_awvalid;  wire [ID_W-1:0] m_awid;   wire [ADDR_W-1:0] m_awaddr;  wire [7:0] m_awlen;
  wire [2:0] m_awsize;   wire [1:0] m_awburst;  wire [1:0] m_awlock;  wire [3:0] m_awcache;  wire [2:0] m_awprot;
  wire [3:0] m_awqos;    wire [3:0] m_awregion;  logic m_awready;
  wire                  m_wvalid;   wire [ID_W-1:0] m_wid;    wire [M_W-1:0] m_wdata;  wire [MB-1:0] m_wstrb;  wire m_wlast;
  logic                 m_wready;
  logic                 m_bvalid;   logic [ID_W-1:0] m_bid;   logic [1:0] m_bresp;      wire m_bready;
  wire                  m_arvalid;  wire [ID_W-1:0] m_arid;   wire [ADDR_W-1:0] m_araddr;  wire [7:0] m_arlen;
  wire [2:0] m_arsize;   wire [1:0] m_arburst;  wire [1:0] m_arlock;  wire [3:0] m_arcache;  wire [2:0] m_arprot;
  wire [3:0] m_arqos;    wire [3:0] m_arregion;  logic m_arready;
  logic                 m_rvalid;   logic [ID_W-1:0] m_rid;    logic [M_W-1:0] m_rdata;  logic [1:0] m_rresp;  logic m_rlast;
  wire                  m_rready;

  logic tb_clr;          // 1 = every model of the testbench is held in its initial state

  // ---------------------------------------------------------------------------------------------------
  // device under test
  // ---------------------------------------------------------------------------------------------------
  generate
    if (PROFILE == 4) begin : g_dut
      wire [7:0] w_m_awlen, w_m_arlen;
      m_vlsit_axi4_upsizer #(
        .PARA_AXI_S_DATA_W (S_W), .PARA_AXI_M_DATA_W (M_W), .PARA_AXI_ADDR_W (ADDR_W), .PARA_AXI_ID_W (ID_W),
        .PARA_AXI_WR_OUTSTANDING_DEPTH (WR_DEPTH), .PARA_AXI_RD_OUTSTANDING_DEPTH (RD_DEPTH)
      ) u_dut (
        .i_clk_axi (clk), .i_rst_n_axi (rst_n),
        .i_axi_awvalid (s_awvalid), .i_axi_awid (s_awid), .i_axi_awaddr (s_awaddr), .i_axi_awlen (s_awlen),
        .i_axi_awsize (s_awsize), .i_axi_awburst (s_awburst), .i_axi_awlock (s_awlock[0]), .i_axi_awcache (s_awcache),
        .i_axi_awprot (s_awprot), .i_axi_awqos (s_awqos), .i_axi_awregion (s_awregion), .o_axi_awready (s_awready),
        .i_axi_wvalid (s_wvalid), .i_axi_wdata (s_wdata), .i_axi_wstrb (s_wstrb), .i_axi_wlast (s_wlast),
        .o_axi_wready (s_wready),
        .o_axi_bvalid (s_bvalid), .o_axi_bid (s_bid), .o_axi_bresp (s_bresp), .i_axi_bready (s_bready),
        .i_axi_arvalid (s_arvalid), .i_axi_arid (s_arid), .i_axi_araddr (s_araddr), .i_axi_arlen (s_arlen),
        .i_axi_arsize (s_arsize), .i_axi_arburst (s_arburst), .i_axi_arlock (s_arlock[0]), .i_axi_arcache (s_arcache),
        .i_axi_arprot (s_arprot), .i_axi_arqos (s_arqos), .i_axi_arregion (s_arregion), .o_axi_arready (s_arready),
        .o_axi_rvalid (s_rvalid), .o_axi_rid (s_rid), .o_axi_rdata (s_rdata), .o_axi_rresp (s_rresp),
        .o_axi_rlast (s_rlast), .i_axi_rready (s_rready),
        .o_axi_awvalid (m_awvalid), .o_axi_awid (m_awid), .o_axi_awaddr (m_awaddr), .o_axi_awlen (m_awlen),
        .o_axi_awsize (m_awsize), .o_axi_awburst (m_awburst), .o_axi_awlock (m_awlock[0]), .o_axi_awcache (m_awcache),
        .o_axi_awprot (m_awprot), .o_axi_awqos (m_awqos), .o_axi_awregion (m_awregion), .i_axi_awready (m_awready),
        .o_axi_wvalid (m_wvalid), .o_axi_wdata (m_wdata), .o_axi_wstrb (m_wstrb), .o_axi_wlast (m_wlast),
        .i_axi_wready (m_wready),
        .i_axi_bvalid (m_bvalid), .i_axi_bid (m_bid), .i_axi_bresp (m_bresp), .o_axi_bready (m_bready),
        .o_axi_arvalid (m_arvalid), .o_axi_arid (m_arid), .o_axi_araddr (m_araddr), .o_axi_arlen (m_arlen),
        .o_axi_arsize (m_arsize), .o_axi_arburst (m_arburst), .o_axi_arlock (m_arlock[0]), .o_axi_arcache (m_arcache),
        .o_axi_arprot (m_arprot), .o_axi_arqos (m_arqos), .o_axi_arregion (m_arregion), .i_axi_arready (m_arready),
        .i_axi_rvalid (m_rvalid), .i_axi_rid (m_rid), .i_axi_rdata (m_rdata), .i_axi_rresp (m_rresp),
        .i_axi_rlast (m_rlast), .o_axi_rready (m_rready)
      );
      assign m_awlock[1] = 1'b0;
      assign m_arlock[1] = 1'b0;
      assign m_wid = '0;
    end else begin : g_dut
      wire [3:0] w_m_awlen, w_m_arlen;
      m_vlsit_axi3_upsizer #(
        .PARA_AXI_S_DATA_W (S_W), .PARA_AXI_M_DATA_W (M_W), .PARA_AXI_ADDR_W (ADDR_W), .PARA_AXI_ID_W (ID_W),
        .PARA_AXI_WR_OUTSTANDING_DEPTH (WR_DEPTH), .PARA_AXI_RD_OUTSTANDING_DEPTH (RD_DEPTH),
        .PARA_AXI_WR_INTERLEAVE_DEPTH (IL_DEPTH)
      ) u_dut (
        .i_clk_axi (clk), .i_rst_n_axi (rst_n),
        .i_axi_awvalid (s_awvalid), .i_axi_awid (s_awid), .i_axi_awaddr (s_awaddr), .i_axi_awlen (s_awlen[3:0]),
        .i_axi_awsize (s_awsize), .i_axi_awburst (s_awburst), .i_axi_awlock (s_awlock), .i_axi_awcache (s_awcache),
        .i_axi_awprot (s_awprot), .o_axi_awready (s_awready),
        .i_axi_wvalid (s_wvalid), .i_axi_wid (s_wid), .i_axi_wdata (s_wdata), .i_axi_wstrb (s_wstrb), .i_axi_wlast (s_wlast),
        .o_axi_wready (s_wready),
        .o_axi_bvalid (s_bvalid), .o_axi_bid (s_bid), .o_axi_bresp (s_bresp), .i_axi_bready (s_bready),
        .i_axi_arvalid (s_arvalid), .i_axi_arid (s_arid), .i_axi_araddr (s_araddr), .i_axi_arlen (s_arlen[3:0]),
        .i_axi_arsize (s_arsize), .i_axi_arburst (s_arburst), .i_axi_arlock (s_arlock), .i_axi_arcache (s_arcache),
        .i_axi_arprot (s_arprot), .o_axi_arready (s_arready),
        .o_axi_rvalid (s_rvalid), .o_axi_rid (s_rid), .o_axi_rdata (s_rdata), .o_axi_rresp (s_rresp),
        .o_axi_rlast (s_rlast), .i_axi_rready (s_rready),
        .o_axi_awvalid (m_awvalid), .o_axi_awid (m_awid), .o_axi_awaddr (m_awaddr), .o_axi_awlen (w_m_awlen),
        .o_axi_awsize (m_awsize), .o_axi_awburst (m_awburst), .o_axi_awlock (m_awlock), .o_axi_awcache (m_awcache),
        .o_axi_awprot (m_awprot), .i_axi_awready (m_awready),
        .o_axi_wvalid (m_wvalid), .o_axi_wid (m_wid), .o_axi_wdata (m_wdata), .o_axi_wstrb (m_wstrb), .o_axi_wlast (m_wlast),
        .i_axi_wready (m_wready),
        .i_axi_bvalid (m_bvalid), .i_axi_bid (m_bid), .i_axi_bresp (m_bresp), .o_axi_bready (m_bready),
        .o_axi_arvalid (m_arvalid), .o_axi_arid (m_arid), .o_axi_araddr (m_araddr), .o_axi_arlen (w_m_arlen),
        .o_axi_arsize (m_arsize), .o_axi_arburst (m_arburst), .o_axi_arlock (m_arlock), .o_axi_arcache (m_arcache),
        .o_axi_arprot (m_arprot), .i_axi_arready (m_arready),
        .i_axi_rvalid (m_rvalid), .i_axi_rid (m_rid), .i_axi_rdata (m_rdata), .i_axi_rresp (m_rresp),
        .i_axi_rlast (m_rlast), .o_axi_rready (m_rready)
      );
      assign m_awlen = {4'b0, w_m_awlen};
      assign m_arlen = {4'b0, w_m_arlen};
      assign m_awqos = 4'b0;
      assign m_awregion = 4'b0;
      assign m_arqos = 4'b0;
      assign m_arregion = 4'b0;
    end
  endgenerate

  // ---------------------------------------------------------------------------------------------------
  // protocol assertions on both interfaces
  // ---------------------------------------------------------------------------------------------------
  wire [63:0] s_awaddr64 = 64'(s_awaddr);
  wire [63:0] s_araddr64 = 64'(s_araddr);
  wire [63:0] m_awaddr64 = 64'(m_awaddr);
  wire [63:0] m_araddr64 = 64'(m_araddr);

  ups_axi_chk #(.DW (S_W), .IDW (ID_W), .AXI3 (AXI3), .NAME (0)) u_chk_s (
    .clk (clk), .rst_n (rst_n),
    .awvalid (s_awvalid), .awready (s_awready), .awid (s_awid), .awaddr (s_awaddr64), .awlen (s_awlen), .awsize (s_awsize),
    .awburst (s_awburst), .awlock (s_awlock), .awcache (s_awcache), .awprot (s_awprot), .awqr ({s_awqos, s_awregion}),
    .wvalid (s_wvalid), .wready (s_wready), .wid (AXI3 ? s_wid : '0), .wstrb (s_wstrb), .wlast (s_wlast), .wdata (s_wdata),
    .bvalid (s_bvalid), .bready (s_bready), .bid (s_bid), .bresp (s_bresp),
    .arvalid (s_arvalid), .arready (s_arready), .arid (s_arid), .araddr (s_araddr64), .arlen (s_arlen), .arsize (s_arsize),
    .arburst (s_arburst), .arlock (s_arlock), .arcache (s_arcache), .arprot (s_arprot), .arqr ({s_arqos, s_arregion}),
    .rvalid (s_rvalid), .rready (s_rready), .rid (s_rid), .rresp (s_rresp), .rlast (s_rlast), .rdata (s_rdata)
  );

  ups_axi_chk #(.DW (M_W), .IDW (ID_W), .AXI3 (AXI3), .NAME (1)) u_chk_m (
    .clk (clk), .rst_n (rst_n),
    .awvalid (m_awvalid), .awready (m_awready), .awid (m_awid), .awaddr (m_awaddr64), .awlen (m_awlen), .awsize (m_awsize),
    .awburst (m_awburst), .awlock (m_awlock), .awcache (m_awcache), .awprot (m_awprot), .awqr ({m_awqos, m_awregion}),
    .wvalid (m_wvalid), .wready (m_wready), .wid (m_wid), .wstrb (m_wstrb), .wlast (m_wlast), .wdata (m_wdata),
    .bvalid (m_bvalid), .bready (m_bready), .bid (m_bid), .bresp (m_bresp),
    .arvalid (m_arvalid), .arready (m_arready), .arid (m_arid), .araddr (m_araddr64), .arlen (m_arlen), .arsize (m_arsize),
    .arburst (m_arburst), .arlock (m_arlock), .arcache (m_arcache), .arprot (m_arprot), .arqr ({m_arqos, m_arregion}),
    .rvalid (m_rvalid), .rready (m_rready), .rid (m_rid), .rresp (m_rresp), .rlast (m_rlast), .rdata (m_rdata)
  );

  // ---------------------------------------------------------------------------------------------------
  // reference functions (from the specification and IHI 0022 A3.4.1)
  // ---------------------------------------------------------------------------------------------------
  // address of beat n (REQ-FUNC-007, A3.4.1)
  function automatic bit [63:0] baddr(input bit [63:0] a, input int size, input int burst, input int len, input int n);
    bit [63:0] nb, c, wb, al;
    nb = 64'd1 << size;
    c  = nb * 64'(len + 1);
    al = (a / nb) * nb;
    wb = (a / c) * c;
    if (burst == 0) return a;
    if (burst == 1) return (n == 0) ? a : al + 64'(n) * nb;
    return wb + ((a - wb) + 64'(n) * nb) % c;
  endfunction

  // byte lanes lo..hi of the beat at address b inside a bus of bus_bytes
  function automatic void lanes(input bit [63:0] b, input int size, input int bus_bytes, output int lo, output int hi);
    bit [63:0] nb, base, top;
    nb   = 64'd1 << size;
    base = (b / 64'(bus_bytes)) * 64'(bus_bytes);
    top  = (b / nb) * nb + nb - 1;
    lo   = int'(b - base);
    hi   = int'(top - base);
  endfunction

  // classification and manager-side attributes of a transaction (REQ-FUNC-002..006)
  function automatic void calc_m(input bit [63:0] a, input int size, input int burst, input int len, input bit cache1,
                                 input int lock, output bit pk, output bit [63:0] ma, output int ml, output int ms,
                                 output int mb);
    bit [63:0] bl, c, e, nm, n;
    bl = 64'(len + 1);
    c  = bl * 64'(SB);
    pk = cache1 && (lock == 0) && (size == LSB) && (burst == 1 || (burst == 2 && (c < 64'(MB) || (a % 64'(MB)) == 0)));
    ma = a; ml = len; ms = size; mb = burst;
    if (pk) begin
      ms = LMB;
      if (burst == 1) begin
        e  = (a / 64'(SB)) * 64'(SB) + bl * 64'(SB);
        nm = (e + 64'(MB) - 1) / 64'(MB) - a / 64'(MB);
        ml = int'(nm) - 1;
        mb = 1;
      end else begin
        if (c >= 64'(MB)) begin
          n = c / 64'(MB);
          ma = a;
          if (n >= 2) begin mb = 2; ml = int'(n) - 1; end
          else begin mb = 1; ml = 0; end
        end else begin
          ma = (a / c) * c;
          mb = 1; ml = 0;
        end
      end
    end
  endfunction

  // data pattern of the read memory (the same function is used by the subordinate model and by the checker)
  int unsigned rdseed;
  function automatic byte unsigned fpat(input bit [63:0] a);
    bit [63:0] x;
    x = (a ^ 64'(rdseed)) * 64'h9E3779B97F4A7C15;
    x = x ^ (x >> 29);
    x = x * 64'hBF58476D1CE4E5B9;
    x = x ^ (x >> 32);
    return x[15:8];
  endfunction

  // ---------------------------------------------------------------------------------------------------
  // address space: a write region and a read region, a random base for the bits above bit 15
  // ---------------------------------------------------------------------------------------------------
  localparam int WINB  = (ADDR_W >= 16) ? 16 : ADDR_W;          // window of 2**WINB bytes
  localparam bit [63:0] WIN = 64'd1 << WINB;
  bit [63:0] abase;                                            // bits above the window
  bit [63:0] wr_lo, wr_hi, rd_lo, rd_hi;
  bit [63:0] wcur;                                             // allocation cursor of the write region

  function automatic bit [63:0] amask(input bit [63:0] a);
    return (ADDR_W >= 64) ? a : (a & ((64'd1 << ADDR_W) - 1));
  endfunction

  // ---------------------------------------------------------------------------------------------------
  // transaction tables
  // ---------------------------------------------------------------------------------------------------
  // writes
  bit [63:0] w_addr [NT];  int w_len [NT];  int w_size [NT];  int w_burst [NT];  int w_lock [NT];  bit [3:0] w_cache [NT];
  bit [2:0]  w_prot [NT];  bit [3:0] w_qos [NT];  bit [3:0] w_region [NT];  int w_id [NT];
  bit        w_pk [NT];    bit [63:0] wm_addr [NT];  int wm_len [NT];  int wm_size [NT];  int wm_burst [NT];
  bit        w_awdone [NT];  bit w_wdone [NT];  int w_nbeat [NT];
  int wgen, awk, wlo;
  // reads
  bit [63:0] r_addr [NT];  int r_len [NT];  int r_size [NT];  int r_burst [NT];  int r_lock [NT];  bit [3:0] r_cache [NT];
  bit [2:0]  r_prot [NT];  bit [3:0] r_qos [NT];  bit [3:0] r_region [NT];  int r_id [NT];
  bit        r_pk [NT];    bit [63:0] rm_addr [NT];  int rm_len [NT];  int rm_size [NT];  int rm_burst [NT];
  int        r_mbase [NT]; int r_mtot;
  int rgen, ark, rk;

  // memories
  byte unsigned gmem [bit [63:0]];     // golden (direct S-side access)
  byte unsigned mmem [bit [63:0]];     // memory of the M-side subordinate model

  // knobs (percent / cycles), changed by the tests
  int aw_gap_pct, aw_gap_max, w_gap_pct, w_gap_max, ar_gap_pct, ar_gap_max;
  int s_rready_pct, s_bready_pct;
  int m_awrdy_pct, m_wrdy_pct, m_arrdy_pct, m_bvalid_pct, m_rvalid_pct;
  int w_early_pct, w_ilk;
  int aw_first_delay;      // idle cycles before the first AW of a test
  int err_pct;
  bit aw_en, ar_en, w_en, m_hold;      // m_hold = 1 stalls the W, B and R channels of the subordinate (queue full test)

  // statistics
  int err_cnt, tests_run, tests_fail;
  int cov_class [8];       // 0 packed INCR, 1 packed WRAP >= M, 2 packed WRAP < M, 3 NM-modifiable, 4 narrow, 5 FIXED, 6 locked, 7 WRAP unaligned
  int cov_rerr, cov_berr, cov_pk_rerr;
  int cov_ctx_max;
  int cov_skid;

  task automatic fail(input string msg);
    err_cnt = err_cnt + 1;
    if (err_cnt <= 20) $display("CHECK FAIL @%0t: %0s", $time, msg);
  endtask

  // ---------------------------------------------------------------------------------------------------
  // transaction generation
  // ---------------------------------------------------------------------------------------------------
  function automatic void add_w(input int id, input bit [63:0] a, input int len, input int size, input int burst,
                       input bit [3:0] cache, input int lock);
    int k;
    bit pk; bit [63:0] ma; int ml, ms, mb;
    k = wgen;
    w_addr[k] = a; w_len[k] = len; w_size[k] = size; w_burst[k] = burst; w_lock[k] = lock; w_cache[k] = cache;
    w_prot[k] = 3'(rnd()); w_qos[k] = 4'(rnd()); w_region[k] = 4'(rnd()); w_id[k] = id % IDN;
    calc_m(a, size, burst, len, cache[1], lock, pk, ma, ml, ms, mb);
    w_pk[k] = pk; wm_addr[k] = ma; wm_len[k] = ml; wm_size[k] = ms; wm_burst[k] = mb;
    w_awdone[k] = 0; w_wdone[k] = 0; w_nbeat[k] = 0;
    wgen = wgen + 1;
    cov_note(pk, a, size, burst, len, cache[1], lock);
  endfunction

  function automatic void add_r(input int id, input bit [63:0] a, input int len, input int size, input int burst,
                       input bit [3:0] cache, input int lock);
    int k;
    bit pk; bit [63:0] ma; int ml, ms, mb;
    k = rgen;
    r_addr[k] = a; r_len[k] = len; r_size[k] = size; r_burst[k] = burst; r_lock[k] = lock; r_cache[k] = cache;
    r_prot[k] = 3'(rnd()); r_qos[k] = 4'(rnd()); r_region[k] = 4'(rnd()); r_id[k] = id % IDN;
    calc_m(a, size, burst, len, cache[1], lock, pk, ma, ml, ms, mb);
    r_pk[k] = pk; rm_addr[k] = ma; rm_len[k] = ml; rm_size[k] = ms; rm_burst[k] = mb;
    r_mbase[k] = r_mtot; r_mtot = r_mtot + ml + 1;
    rgen = rgen + 1;
    cov_note(pk, a, size, burst, len, cache[1], lock);
  endfunction

  // coverage COV-001: class of the transaction
  function automatic void cov_note(input bit pk, input bit [63:0] a, input int size, input int burst, input int len,
                          input bit cache1, input int lock);
    bit [63:0] c;
    c = 64'(len + 1) * 64'(SB);
    if (pk && burst == 1) cov_class[0]++;
    else if (pk && burst == 2 && c >= 64'(MB)) cov_class[1]++;
    else if (pk && burst == 2) cov_class[2]++;
    else begin
      if (!cache1) cov_class[3]++;
      if (size < LSB) cov_class[4]++;
      if (burst == 0) cov_class[5]++;
      if (lock != 0) cov_class[6]++;
      if (burst == 2 && size == LSB && cache1 && lock == 0 && c >= 64'(MB) && (a % 64'(MB)) != 0) cov_class[7]++;
    end
  endfunction

  // random write: allocates a window of the write region that no other write uses. returns 0 when the region is full.
  function automatic bit gen_w(input int id);
    int size, burst, len, k, mx;
    bit [63:0] a, nb, c, base, lo, hi, e;
    bit [3:0] cache; int lock;
    size = pct(55) ? LSB : rr(LSB + 1);
    burst = rr(100) < 60 ? 1 : (rr(100) < 62 ? 2 : 0);
    nb = 64'd1 << size;
    mx = AXI3 ? 15 : 63;
    if (burst == 1) len = pct(70) ? rr(16) : rr(mx + 1);
    else if (burst == 0) len = rr(16);
    else begin k = rr(4); len = (k == 0) ? 1 : (k == 1) ? 3 : (k == 2) ? 7 : 15; end
    cache = 4'(rnd());
    cache[1] = pct(75);
    lock = pct(10) ? (AXI3 ? 1 + rr(2) : 1) : 0;
    if (burst == 2) begin
      c = nb * 64'(len + 1);
      base = ((wcur + c - 1) / c) * c;
      a = base + 64'(rr(len + 1)) * nb;
      lo = base; hi = base + c;
    end else begin
      a = wcur + 64'(rr(SB * 2));
      if (burst == 1) begin
        e = (a / nb) * nb + 64'(len + 1) * nb;
        while (((a >> 12) != ((e - 1) >> 12)) && len > 0) begin
          len = len - 1;
          e = (a / nb) * nb + 64'(len + 1) * nb;
        end
        if ((a >> 12) != ((e - 1) >> 12)) begin a = ((a >> 12) + 1) << 12; e = (a / nb) * nb + 64'(len + 1) * nb; end
        lo = a; hi = e;
      end else begin
        lo = (a / 64'(SB)) * 64'(SB); hi = lo + 64'(SB);
      end
    end
    if (hi > wr_hi - wr_lo) return 1'b0;
    wcur = hi;
    add_w(id, amask(abase + wr_lo + a), len, size, burst, cache, lock);
    return 1'b1;
  endfunction

  task automatic gen_r(input int id);
    int size, burst, len, k, mx;
    bit [63:0] a, nb, c, base, e, span, rngsz;
    bit [3:0] cache; int lock;
    size = pct(55) ? LSB : rr(LSB + 1);
    burst = rr(100) < 60 ? 1 : (rr(100) < 62 ? 2 : 0);
    nb = 64'd1 << size;
    mx = AXI3 ? 15 : 63;
    if (burst == 1) len = pct(70) ? rr(16) : rr(mx + 1);
    else if (burst == 0) len = rr(16);
    else begin k = rr(4); len = (k == 0) ? 1 : (k == 1) ? 3 : (k == 2) ? 7 : 15; end
    cache = 4'(rnd());
    cache[1] = pct(75);
    lock = pct(10) ? (AXI3 ? 1 + rr(2) : 1) : 0;
    rngsz = rd_hi - rd_lo;
    if (burst == 2) begin
      c = nb * 64'(len + 1);
      base = rd_lo + (64'(rnd()) % (rngsz / c)) * c;
      a = base + 64'(rr(len + 1)) * nb;
    end else begin
      a = rd_lo + (64'(rnd()) % (rngsz - 64'(SB) * 2));
      if (burst == 1) begin
        e = (a / nb) * nb + 64'(len + 1) * nb;
        while (((a >> 12) != ((e - 1) >> 12)) && len > 0) begin
          len = len - 1;
          e = (a / nb) * nb + 64'(len + 1) * nb;
        end
        if ((a >> 12) != ((e - 1) >> 12)) begin a = ((a >> 12) << 12) ; end
        e = (a / nb) * nb + 64'(len + 1) * nb;
        if (e > rd_hi) begin a = rd_lo; len = 0; end
      end
    end
    add_r(id, amask(abase + a), len, size, burst, cache, lock);
  endtask

  // ---------------------------------------------------------------------------------------------------
  // S side: AW driver
  // ---------------------------------------------------------------------------------------------------
  bit aw_busy;  int aw_gapc;
  int sacc_aw, sdone_w, sacc_ar, sdone_r;          // outstanding counters (REQ-PARAM-003)

  always @(posedge clk) begin : p_aw_drv
    if (tb_clr) begin
      s_awvalid <= 1'b0; aw_busy = 1'b0; aw_gapc = aw_first_delay; awk = 0; sacc_aw = 0;
    end else begin
      if (aw_busy && s_awready) begin
        w_awdone[awk] = 1'b1;
        awk = awk + 1;
        sacc_aw = sacc_aw + 1;
        aw_busy = 1'b0;
        s_awvalid <= 1'b0;
        aw_gapc = pct(aw_gap_pct) ? 1 + rr(aw_gap_max) : 0;
      end
      if (!aw_busy) begin
        if (aw_gapc > 0) aw_gapc = aw_gapc - 1;
        else if (awk < wgen && aw_en) begin
          s_awvalid <= 1'b1; s_awid <= ID_W'(w_id[awk]); s_awaddr <= ADDR_W'(w_addr[awk]); s_awlen <= 8'(w_len[awk]);
          s_awsize <= 3'(w_size[awk]); s_awburst <= 2'(w_burst[awk]); s_awlock <= 2'(w_lock[awk]);
          s_awcache <= w_cache[awk]; s_awprot <= w_prot[awk]; s_awqos <= w_qos[awk]; s_awregion <= w_region[awk];
          aw_busy = 1'b1;
        end
      end
    end
  end

  // ---------------------------------------------------------------------------------------------------
  // S side: W driver (in order for AXI4; WID interleave for AXI3)
  // ---------------------------------------------------------------------------------------------------
  bit w_busy;  int w_gapc;  int w_cur, w_curn;
  logic [S_W-1:0] w_pdata;  logic [SB-1:0] w_pstrb;
  int ctx_now, w_last_tx;
  int cov_switch;
  int cov_ctx_hist [5];

  function automatic int pick_w();
    int cand [24];
    int nc, ns, i, hi, started_cnt, firstnew;
    nc = 0; ns = 0; firstnew = -1;
    if (!AXI3) begin
      if (wlo < wgen && (w_awdone[wlo] || pct(w_early_pct))) return wlo;
      return -1;
    end
    hi = wlo + ((IDN < 8) ? IDN - 1 : 8);
    if (hi > wgen) hi = wgen;
    for (i = wlo; i < hi; i++) begin
      if (!w_wdone[i]) begin
        if (w_nbeat[i] > 0) begin cand[nc] = i; nc = nc + 1; ns = ns + 1; end
        else if (firstnew < 0 && (w_awdone[i] || (i == wlo && pct(w_early_pct)))) firstnew = i;
      end
    end
    if (ns < w_ilk && firstnew >= 0) begin cand[nc] = firstnew; nc = nc + 1; end
    if (nc == 0) return -1;
    return cand[rr(nc)];
  endfunction

  always @(posedge clk) begin : p_w_drv
    int c, lo, hi, l, s0, n;
    bit [63:0] b;
    if (tb_clr) begin
      s_wvalid <= 1'b0; w_busy = 1'b0; w_gapc = 0; wlo = 0; sdone_w = 0; ctx_now = 0; w_last_tx = -1;
    end else begin
      if (w_busy && s_wready) begin
        // handshake: the beat goes to the golden memory (direct S-side access)
        c = w_cur; n = w_curn;
        b = baddr(w_addr[c], w_size[c], w_burst[c], w_len[c], n);
        lanes(b, w_size[c], SB, lo, hi);
        for (l = lo; l <= hi; l++)
          if (w_pstrb[l]) gmem[(b / 64'(SB)) * 64'(SB) + 64'(l)] = w_pdata[l*8 +: 8];
        w_nbeat[c] = w_nbeat[c] + 1;
        if (n == w_len[c]) begin
          w_wdone[c] = 1'b1;
          sdone_w = sdone_w + 1;
          while (wlo < wgen && w_wdone[wlo]) wlo = wlo + 1;
        end
        w_busy = 1'b0;
        s_wvalid <= 1'b0;
        w_gapc = pct(w_gap_pct) ? 1 + rr(w_gap_max) : 0;
      end
      if (!w_busy) begin
        if (w_gapc > 0) w_gapc = w_gapc - 1;
        else if (w_en) begin
          c = pick_w();
          if (c >= 0) begin
            n = w_nbeat[c];
            b = baddr(w_addr[c], w_size[c], w_burst[c], w_len[c], n);
            lanes(b, w_size[c], SB, lo, hi);
            for (l = 0; l < SB; l++) begin
              w_pdata[l*8 +: 8] = 8'(rnd());
              w_pstrb[l] = (l >= lo && l <= hi) ? pct(75) : 1'b0;
            end
            s_wvalid <= 1'b1; s_wdata <= w_pdata; s_wstrb <= w_pstrb; s_wlast <= (n == w_len[c]);
            s_wid <= ID_W'(w_id[c]);
            // COV-006: contexts active at the same time and beats that switch to another transaction
            ctx_now = 0;
            for (l = wlo; l < wgen && l < wlo + 8; l++) if (!w_wdone[l] && (w_nbeat[l] > 0 || l == c)) ctx_now = ctx_now + 1;
            if (ctx_now > cov_ctx_max) cov_ctx_max = ctx_now;
            if (ctx_now >= 2) cov_ctx_hist[(ctx_now > 4) ? 4 : ctx_now]++;
            if (w_last_tx >= 0 && w_last_tx != c && !w_wdone[w_last_tx]) cov_switch = cov_switch + 1;
            w_last_tx = c;
            w_cur = c; w_curn = n; w_busy = 1'b1;
          end
        end
      end
    end
  end

  // ---------------------------------------------------------------------------------------------------
  // S side: AR driver, R checker, B checker
  // ---------------------------------------------------------------------------------------------------
  bit ar_busy;  int ar_gapc;
  always @(posedge clk) begin : p_ar_drv
    if (tb_clr) begin
      s_arvalid <= 1'b0; ar_busy = 1'b0; ar_gapc = 0; ark = 0; sacc_ar = 0;
    end else begin
      if (ar_busy && s_arready) begin
        ark = ark + 1; sacc_ar = sacc_ar + 1;
        ar_busy = 1'b0; s_arvalid <= 1'b0;
        ar_gapc = pct(ar_gap_pct) ? 1 + rr(ar_gap_max) : 0;
      end
      if (!ar_busy) begin
        if (ar_gapc > 0) ar_gapc = ar_gapc - 1;
        else if (ark < rgen && ar_en) begin
          s_arvalid <= 1'b1; s_arid <= ID_W'(r_id[ark]); s_araddr <= ADDR_W'(r_addr[ark]); s_arlen <= 8'(r_len[ark]);
          s_arsize <= 3'(r_size[ark]); s_arburst <= 2'(r_burst[ark]); s_arlock <= 2'(r_lock[ark]);
          s_arcache <= r_cache[ark]; s_arprot <= r_prot[ark]; s_arqos <= r_qos[ark]; s_arregion <= r_region[ark];
          ar_busy = 1'b1;
        end
      end
    end
  end

  // random READY of the S-side R and B channels
  always @(posedge clk) begin
    if (tb_clr) begin s_rready <= 1'b0; s_bready <= 1'b0; end
    else begin s_rready <= pct(s_rready_pct); s_bready <= pct(s_bready_pct); end
  end

  // M-side response logs (the S side must show the same responses, REQ-FUNC-011, REQ-FUNC-012, REQ-FUNC-013)
  int mresp [NT * 8];            // RRESP of the global M read beat
  int mR_cnt;                    // number of M R beats generated
  int mB_id [NT];  int mB_resp [NT];  int mB_cnt;       // M-side B handshakes
  int sB_cnt;                    // S-side B handshakes

  // S-side R checker: data, id, last, resp of every S beat (REQ-FUNC-012, REQ-FUNC-013)
  int rn, rkm;  bit [63:0] r_prevword;
  always @(posedge clk) begin : p_r_chk
    int lo, hi, l, mi, exp_resp;
    bit [63:0] b, wd;
    if (tb_clr) begin
      rk = 0; rn = 0; rkm = 0; r_prevword = 0; sdone_r = 0;
    end else if (s_rvalid && s_rready) begin
      if (rk >= ark) fail("S-side R beat while no AR was accepted (IHI0022 A3.3.1)");
      else begin
        b = baddr(r_addr[rk], r_size[rk], r_burst[rk], r_len[rk], rn);
        wd = b / 64'(MB);
        if (rn == 0) rkm = 0;
        else if (r_pk[rk]) begin if (wd != r_prevword) rkm = rkm + 1; end
        else rkm = rn;
        r_prevword = wd;
        lanes(b, r_size[rk], SB, lo, hi);
        for (l = lo; l <= hi; l++)
          if (s_rdata[l*8 +: 8] !== fpat((b / 64'(SB)) * 64'(SB) + 64'(l)))
            fail($sformatf("S R data tx=%0d beat=%0d lane=%0d (REQ-FUNC-012/013)", rk, rn, l));
        if (int'(s_rid) != r_id[rk]) fail($sformatf("S RID tx=%0d (REQ-FUNC-012)", rk));
        if (s_rlast !== (rn == r_len[rk])) fail($sformatf("S RLAST tx=%0d beat=%0d (REQ-FUNC-013)", rk, rn));
        mi = r_mbase[rk] + rkm;
        exp_resp = (mi < mR_cnt) ? mresp[mi] : -1;
        if (exp_resp < 0 || int'(s_rresp) != exp_resp) fail($sformatf("S RRESP tx=%0d beat=%0d got %0d expected %0d (REQ-FUNC-013)", rk, rn, s_rresp, exp_resp));
        if (rn == r_len[rk]) begin
          if (rkm != rm_len[rk]) fail($sformatf("number of M R beats of tx=%0d is %0d, M ARLEN+1 is %0d (REQ-FUNC-004)", rk, rkm + 1, rm_len[rk] + 1));
          rk = rk + 1; rn = 0; sdone_r = sdone_r + 1;
        end else rn = rn + 1;
      end
    end
  end

  // S-side B checker: the response is the one of the M side, in the order received (REQ-FUNC-011)
  always @(posedge clk) begin : p_b_chk
    if (tb_clr) sB_cnt = 0;
    else if (s_bvalid && s_bready) begin
      if (sB_cnt >= mB_cnt) fail("S-side B before the M-side B (REQ-FUNC-011)");
      else begin
        if (int'(s_bid) != mB_id[sB_cnt] || int'(s_bresp) != mB_resp[sB_cnt])
          fail($sformatf("S B (id %0d resp %0d) differs from M B (id %0d resp %0d) (REQ-FUNC-011)", s_bid, s_bresp, mB_id[sB_cnt], mB_resp[sB_cnt]));
      end
      sB_cnt = sB_cnt + 1;
    end
  end

  // ---------------------------------------------------------------------------------------------------
  // outstanding limit (REQ-PARAM-003, SVA-003) and write-after-AW (REQ-FUNC-010)
  // ---------------------------------------------------------------------------------------------------
  int sw_aw_acc [IDN];     // AW accepted per ID (AXI3) / total (AXI4: index 0)
  int sw_w_started;        // W transactions started
  always @(posedge clk) begin : p_outst
    if (tb_clr) begin
    end else begin
      if (sacc_aw - sdone_w > WR_DEPTH) fail($sformatf("write outstanding %0d above PARA_AXI_WR_OUTSTANDING_DEPTH=%0d (REQ-PARAM-003)", sacc_aw - sdone_w, WR_DEPTH));
      // the queue entry of a read leaves with the last S beat given to the R slice, so up to the two beats held by the R slice
      // (two single-beat transactions) are still outstanding on the S side
      if (sacc_ar - sdone_r > RD_DEPTH + 2) fail($sformatf("read outstanding %0d above PARA_AXI_RD_OUTSTANDING_DEPTH=%0d + R slice (REQ-PARAM-003)", sacc_ar - sdone_r, RD_DEPTH));
    end
  end
  // REQ-FUNC-010 (AXI4 top): no W beat is accepted before the AW of its transaction was accepted in an earlier cycle.
  // REQ-FUNC-018 (AXI3 top): WREADY is 0 while no accepted AW is pending and no context is active. A context stays active
  // until its last beat is converted, so one beat of the next transaction may enter the one-beat stage before its AW; a
  // second such beat before the next AW is accepted is a violation (the stage holds one beat).
  int aw_seen, wd_seen, orphan;
  always @(posedge clk) begin : p_wfirst
    if (tb_clr) begin aw_seen = 0; wd_seen = 0; orphan = 0; end
    else begin
      if (s_wvalid && s_wready) begin
        if (!(aw_seen > wd_seen)) begin
          orphan = orphan + 1;
          // idle IP (no AW accepted yet and no transaction completed since the reset): no context can be active
          if (AXI3 && aw_seen == 0 && wd_seen == 0) fail("AXI3: W beat accepted while no AW is pending and no context is active (REQ-FUNC-018)");
          if (!AXI3) fail("W beat accepted before its AW (REQ-FUNC-010)");
          else if (orphan > 1) fail("AXI3: second W beat accepted while no accepted AW waits for data (REQ-FUNC-018)");
        end
        if (s_wlast) wd_seen = wd_seen + 1;
      end
      if (s_awvalid && s_awready) begin aw_seen = aw_seen + 1; orphan = 0; end
    end
  end

  // ---------------------------------------------------------------------------------------------------
  // M side: subordinate model
  // ---------------------------------------------------------------------------------------------------
  // AW queue of the subordinate
  bit [63:0] maw_addr [NT]; int maw_len [NT]; int maw_size [NT]; int maw_burst [NT]; int maw_id [NT];
  bit maw_bound [NT]; bit maw_done [NT]; int maw_beat [NT];
  int maw_cnt, mlo;                     // received AW, oldest incomplete AW
  int mcur [IDN];                       // AXI3: AW index of the context of each WID, -1 = none
  int mar_cnt, mrk, mrn;                // received AR, current AR, beat
  int mawchk, marchk;                   // index of the next AW / AR to compare with the expected attributes

  // M AW / AR attribute checker (REQ-FUNC-002..006, 015, 017; SVA-004)
  always @(posedge clk) begin : p_mattr
    if (tb_clr) begin mawchk = 0; marchk = 0; end
    else begin
      if (m_awvalid && m_awready) begin
        if (mawchk >= awk && !(s_awvalid && s_awready && mawchk == awk)) fail("M AW before the S AW was accepted (REQ-FUNC-014)");
        else if (mawchk < wgen) begin
          if (m_awaddr64[63:0] !== amask(wm_addr[mawchk])) fail($sformatf("M AWADDR tx=%0d got %h expected %h (REQ-FUNC-004/005/006)", mawchk, m_awaddr64, wm_addr[mawchk]));
          if (int'(m_awlen) != wm_len[mawchk]) fail($sformatf("M AWLEN tx=%0d got %0d expected %0d (REQ-FUNC-004/005/006)", mawchk, m_awlen, wm_len[mawchk]));
          if (int'(m_awsize) != wm_size[mawchk]) fail($sformatf("M AWSIZE tx=%0d got %0d expected %0d (REQ-FUNC-004)", mawchk, m_awsize, wm_size[mawchk]));
          if (int'(m_awburst) != wm_burst[mawchk]) fail($sformatf("M AWBURST tx=%0d got %0d expected %0d (REQ-FUNC-004/005/006)", mawchk, m_awburst, wm_burst[mawchk]));
          if (int'(m_awid) != w_id[mawchk] || m_awlock[0] !== w_lock[mawchk][0] || m_awcache !== w_cache[mawchk] || m_awprot !== w_prot[mawchk])
            fail($sformatf("M AW pass-through fields tx=%0d (REQ-FUNC-015)", mawchk));
          if (!AXI3 && (m_awqos !== w_qos[mawchk] || m_awregion !== w_region[mawchk])) fail($sformatf("M AWQOS/AWREGION tx=%0d (REQ-FUNC-015)", mawchk));
          if (AXI3 && m_awlock !== 2'(w_lock[mawchk])) fail($sformatf("M AWLOCK tx=%0d (REQ-FUNC-015)", mawchk));
        end
        mawchk = mawchk + 1;
      end
      if (m_arvalid && m_arready) begin
        if (marchk >= ark && !(s_arvalid && s_arready && marchk == ark)) fail("M AR before the S AR was accepted (REQ-FUNC-014)");
        else if (marchk < rgen) begin
          if (m_araddr64[63:0] !== amask(rm_addr[marchk])) fail($sformatf("M ARADDR tx=%0d got %h expected %h (REQ-FUNC-004/005/006)", marchk, m_araddr64, rm_addr[marchk]));
          if (int'(m_arlen) != rm_len[marchk]) fail($sformatf("M ARLEN tx=%0d got %0d expected %0d (REQ-FUNC-004/005/006)", marchk, m_arlen, rm_len[marchk]));
          if (int'(m_arsize) != rm_size[marchk]) fail($sformatf("M ARSIZE tx=%0d got %0d expected %0d (REQ-FUNC-004)", marchk, m_arsize, rm_size[marchk]));
          if (int'(m_arburst) != rm_burst[marchk]) fail($sformatf("M ARBURST tx=%0d got %0d expected %0d (REQ-FUNC-004/005/006)", marchk, m_arburst, rm_burst[marchk]));
          if (int'(m_arid) != r_id[marchk] || m_arlock[0] !== r_lock[marchk][0] || m_arcache !== r_cache[marchk] || m_arprot !== r_prot[marchk])
            fail($sformatf("M AR pass-through fields tx=%0d (REQ-FUNC-015)", marchk));
          if (!AXI3 && (m_arqos !== r_qos[marchk] || m_arregion !== r_region[marchk])) fail($sformatf("M ARQOS/ARREGION tx=%0d (REQ-FUNC-015)", marchk));
          if (AXI3 && m_arlock !== 2'(r_lock[marchk])) fail($sformatf("M ARLOCK tx=%0d (REQ-FUNC-015)", marchk));
        end
        marchk = marchk + 1;
      end
    end
  end

  // random READY of the M-side request channels
  logic m_awready_r, m_arready_r, m_wready_r;
  always @(posedge clk) begin
    if (tb_clr) begin m_awready <= 1'b0; m_arready <= 1'b0; m_wready_r <= 1'b0; end
    else begin
      m_awready <= pct(m_awrdy_pct);
      m_arready <= pct(m_arrdy_pct);
      m_wready_r <= !m_hold && pct(m_wrdy_pct);
    end
  end

  // M AW queue and the context lookup of the W channel
  always @(posedge clk) begin : p_maw
    if (tb_clr) begin
      maw_cnt = 0;
    end else if (m_awvalid && m_awready) begin
      maw_addr[maw_cnt] = m_awaddr64; maw_len[maw_cnt] = int'(m_awlen); maw_size[maw_cnt] = int'(m_awsize);
      maw_burst[maw_cnt] = int'(m_awburst); maw_id[maw_cnt] = int'(m_awid);
      maw_bound[maw_cnt] = 1'b0; maw_done[maw_cnt] = 1'b0; maw_beat[maw_cnt] = 0;
      maw_cnt = maw_cnt + 1;
    end
  end

  function automatic int find_unbound(input int id);
    int i;
    for (i = mlo; i < maw_cnt; i++)
      if (!maw_bound[i] && !maw_done[i] && maw_id[i] == id) return i;
    return -1;
  endfunction

  // WREADY: a W beat is accepted when its AW is known (REQ-FUNC-010 is the behavior of the IP, this is the model)
  logic m_can_take;
  always_comb begin
    m_can_take = 1'b0;
    if (!AXI3) m_can_take = (mlo < maw_cnt);
    else m_can_take = (mcur[int'(m_wid)] >= 0) || (find_unbound(int'(m_wid)) >= 0);
  end
  assign m_wready = m_wready_r & m_can_take;

  // B queue
  int bq_id [NT*2];  int bq_resp [NT*2];  int bq_head, bq_tail;

  always @(posedge clk) begin : p_mw
    int ctx, n, l, wi;
    bit [63:0] b, basew;
    if (tb_clr) begin
      mlo = 0;
      for (wi = 0; wi < IDN; wi++) mcur[wi] = -1;
      bq_head = 0; bq_tail = 0;
    end else if (m_wvalid && m_wready) begin
      wi = int'(m_wid);
      if (!AXI3) ctx = mlo;
      else begin
        ctx = mcur[wi];
        if (ctx < 0) begin
          ctx = find_unbound(wi);
          maw_bound[ctx] = 1'b1;
          mcur[wi] = ctx;
        end
      end
      if (ctx < 0 || ctx >= maw_cnt) fail("M W beat without AW");
      else begin
        n = maw_beat[ctx];
        b = baddr(maw_addr[ctx], maw_size[ctx], maw_burst[ctx], maw_len[ctx], n);
        basew = (b / 64'(MB)) * 64'(MB);
        for (l = 0; l < MB; l++)
          if (m_wstrb[l]) mmem[basew + 64'(l)] = m_wdata[l*8 +: 8];
        if (m_wlast !== (n == maw_len[ctx])) fail($sformatf("M WLAST tx=%0d beat=%0d (REQ-FUNC-009, SVA-005)", ctx, n));
        maw_beat[ctx] = n + 1;
        if (n == maw_len[ctx]) begin
          maw_done[ctx] = 1'b1;
          if (AXI3) mcur[wi] = -1;
          bq_id[bq_tail] = maw_id[ctx];
          bq_resp[bq_tail] = pct(err_pct) ? (pct(50) ? 2 : 3) : 0;
          bq_tail = bq_tail + 1;
          if (!AXI3) mlo = mlo + 1;
          else while (mlo < maw_cnt && maw_done[mlo]) mlo = mlo + 1;
        end
      end
    end
  end

  // B driver
  bit b_busy;
  always @(posedge clk) begin : p_bdrv
    if (tb_clr) begin
      m_bvalid <= 1'b0; b_busy = 1'b0; mB_cnt = 0;
    end else begin
      if (b_busy && m_bready) begin
        mB_id[mB_cnt] = int'(m_bid); mB_resp[mB_cnt] = int'(m_bresp);
        if (m_bresp != 2'b00) cov_berr = cov_berr + 1;
        mB_cnt = mB_cnt + 1;
        b_busy = 1'b0;
        m_bvalid <= 1'b0;
      end
      if (!b_busy && !m_hold && bq_head < bq_tail && pct(m_bvalid_pct)) begin
        m_bvalid <= 1'b1; m_bid <= ID_W'(bq_id[bq_head]); m_bresp <= 2'(bq_resp[bq_head]);
        bq_head = bq_head + 1;
        b_busy = 1'b1;
      end
    end
  end

  // M AR queue and R driver (in order, no interleave, ASM-002)
  bit [63:0] mar_addr [NT]; int mar_len [NT]; int mar_size [NT]; int mar_burst [NT]; int mar_id [NT];
  always @(posedge clk) begin : p_mar
    if (tb_clr) mar_cnt = 0;
    else if (m_arvalid && m_arready) begin
      mar_addr[mar_cnt] = m_araddr64; mar_len[mar_cnt] = int'(m_arlen); mar_size[mar_cnt] = int'(m_arsize);
      mar_burst[mar_cnt] = int'(m_arburst); mar_id[mar_cnt] = int'(m_arid);
      mar_cnt = mar_cnt + 1;
    end
  end

  bit r_busy;
  always @(posedge clk) begin : p_rdrv
    int l, rs;
    bit [63:0] b, basew;
    if (tb_clr) begin
      m_rvalid <= 1'b0; r_busy = 1'b0; mrk = 0; mrn = 0; mR_cnt = 0;
    end else begin
      if (r_busy && m_rready) begin
        r_busy = 1'b0;
        m_rvalid <= 1'b0;
        if (mrn == mar_len[mrk]) begin mrk = mrk + 1; mrn = 0; end else mrn = mrn + 1;
      end
      if (!r_busy && !m_hold && mrk < mar_cnt && pct(m_rvalid_pct)) begin
        b = baddr(mar_addr[mrk], mar_size[mrk], mar_burst[mrk], mar_len[mrk], mrn);
        basew = (b / 64'(MB)) * 64'(MB);
        for (l = 0; l < MB; l++) m_rdata[l*8 +: 8] <= fpat(basew + 64'(l));
        rs = pct(err_pct) ? (pct(50) ? 2 : 3) : 0;
        mresp[mR_cnt] = rs;
        mR_cnt = mR_cnt + 1;
        if (rs != 0) cov_rerr = cov_rerr + 1;
        m_rvalid <= 1'b1; m_rid <= ID_W'(mar_id[mrk]); m_rresp <= 2'(rs); m_rlast <= (mrn == mar_len[mrk]);
        r_busy = 1'b1;
      end
    end
  end

  // ---------------------------------------------------------------------------------------------------
  // reset checks (REQ-IF-004, SVA-002): VALID and READY outputs of the IP are low in reset and READY is low in the
  // first cycle after the release
  // ---------------------------------------------------------------------------------------------------
  bit rst_prev;  int rst_rel_cnt;
  always @(posedge clk) begin : p_rstchk
    if (!rst_n) begin
      rst_rel_cnt = 0;
    end else begin
      if (rst_rel_cnt == 0) begin
        if (s_awready || s_wready || s_arready || m_bready || m_rready || s_bvalid || s_rvalid || m_awvalid || m_wvalid || m_arvalid)
          fail($sformatf("READY or VALID output high in the first cycle after the reset release (REQ-IF-004): s_awready=%b s_wready=%b s_arready=%b m_bready=%b m_rready=%b s_bvalid=%b s_rvalid=%b m_awvalid=%b m_wvalid=%b m_arvalid=%b", s_awready, s_wready, s_arready, m_bready, m_rready, s_bvalid, s_rvalid, m_awvalid, m_wvalid, m_arvalid));
        rst_rel_cnt = 1;
      end
    end
    rst_prev = rst_n;
  end

  // ---------------------------------------------------------------------------------------------------
  // test control
  // ---------------------------------------------------------------------------------------------------
  task automatic set_defaults();
    aw_gap_pct = 0; aw_gap_max = 1; w_gap_pct = 0; w_gap_max = 1; ar_gap_pct = 0; ar_gap_max = 1;
    s_rready_pct = 100; s_bready_pct = 100;
    m_awrdy_pct = 100; m_wrdy_pct = 100; m_arrdy_pct = 100; m_bvalid_pct = 100; m_rvalid_pct = 100;
    w_early_pct = 0; w_ilk = 1; err_pct = 0; aw_first_delay = 0;
    aw_en = 1; ar_en = 1; w_en = 1; m_hold = 0;
  endtask

  task automatic clear_state();
    int i;
    wgen = 0; rgen = 0; r_mtot = 0; wcur = 0; mR_cnt = 0;
    gmem.delete(); mmem.delete();
    for (i = 0; i < NT; i++) begin
      w_awdone[i] = 0; w_wdone[i] = 0; w_nbeat[i] = 0;
    end
  endtask

  task automatic do_reset();
    tb_clr = 1'b1;
    rst_n = 1'b0;
    repeat (4) @(posedge clk);
    clear_state();
    set_defaults();
    abase = (ADDR_W > 16) ? amask(64'(rnd()) << 16 | (64'(rnd()) << 32)) & ~((64'd1 << 16) - 1) : 64'd0;
    wr_lo = 0; wr_hi = WIN / 2; rd_lo = WIN / 2; rd_hi = WIN;
    rdseed = rnd();
    @(negedge clk);
    rst_n = 1'b1;
    repeat (2) @(posedge clk);
    @(negedge clk);
    tb_clr = 1'b0;
  endtask

  // run until every transaction is complete or the watchdog expires, then compare the memories
  task automatic finish_test(input string name);
    int cyc, lastp, prog;
    bit [63:0] k;
    int nmiss;
    cyc = 0; lastp = 0;
    prog = 0;
    forever begin
      @(posedge clk);
      cyc = cyc + 1;
      if (awk + sB_cnt + rk + ark + mB_cnt != prog) begin prog = awk + sB_cnt + rk + ark + mB_cnt; lastp = cyc; end
      if (awk == wgen && sB_cnt == wgen && ark == rgen && rk == rgen) break;
      if (cyc - lastp > 4000) begin
        fail($sformatf("%0s: no progress for 4000 cycles (AW %0d/%0d B %0d/%0d AR %0d/%0d R %0d/%0d)", name, awk, wgen, sB_cnt, wgen, ark, rgen, rk, rgen));
        break;
      end
    end
    repeat (30) @(posedge clk);
    // memories (REQ-FUNC-001): every byte written on the S side is in the M-side memory and nothing else
    nmiss = 0;
    foreach (gmem[k]) begin
      if (!mmem.exists(k) || mmem[k] !== gmem[k]) begin
        nmiss = nmiss + 1;
        if (nmiss <= 5) fail($sformatf("%0s: byte %h golden %h M-side %s (REQ-FUNC-001)", name, k, gmem[k], mmem.exists(k) ? $sformatf("%h", mmem[k]) : "missing"));
      end
    end
    foreach (mmem[k])
      if (!gmem.exists(k)) begin
        nmiss = nmiss + 1;
        if (nmiss <= 5) fail($sformatf("%0s: M-side byte %h written without S-side data (REQ-FUNC-009, SVA-007)", name, k));
      end
    if (mawchk != wgen || marchk != rgen || mB_cnt != wgen || mR_cnt != r_mtot)
      fail($sformatf("%0s: counts M AW %0d/%0d M AR %0d/%0d M B %0d/%0d M R %0d/%0d (REQ-FUNC-014)", name, mawchk, wgen, marchk, rgen, mB_cnt, wgen, mR_cnt, r_mtot));
  endtask

  int fails_before;
  task automatic begin_test(input string name);
    fails_before = err_cnt;
    do_reset();
    $display("TEST %0s start", name);
  endtask
  task automatic end_test(input string name);
    finish_test(name);
    tests_run = tests_run + 1;
    if (err_cnt != fails_before) begin tests_fail = tests_fail + 1; $display("TEST %0s FAIL", name); end
    else $display("TEST %0s PASS  (write %0d read %0d)", name, wgen, rgen);
  endtask

  // directed helpers: addresses are inside the write region (offset from wr_lo) and the read region
  function automatic bit [63:0] wa(input int off); return amask(abase + wr_lo + 64'(off)); endfunction
  function automatic bit [63:0] ra(input int off); return amask(abase + rd_lo + 64'(off)); endfunction
  localparam bit [3:0] CMOD = 4'b0011;      // Modifiable
  localparam bit [3:0] CNOM = 4'b0001;      // Non-modifiable

  // ---- tests ----
  task automatic t_pack_aligned();                 // TEST-002, WF-001
    begin_test("TEST-002 packed INCR aligned");
    add_w(1, wa(MB * 4), 7, LSB, 1, CMOD, 0);
    add_r(2, ra(MB * 4), 7, LSB, 1, CMOD, 0);
    end_test("TEST-002");
  endtask

  task automatic t_pack_unaligned();               // TEST-003, WF-002
    begin_test("TEST-003 packed INCR unaligned");
    add_w(1, wa(MB * 4 + SB * 2), 6, LSB, 1, CMOD, 0);
    add_w(3, wa(MB * 12 + SB), 4, LSB, 1, CMOD, 0);
    add_r(2, ra(MB * 4 + SB * 2), 6, LSB, 1, CMOD, 0);
    add_r(4, ra(MB * 12 + SB), 4, LSB, 1, CMOD, 0);
    end_test("TEST-003");
  endtask

  task automatic t_lane_steering();                // TEST-004, TEST-018, WF-003, WF-008
    begin_test("TEST-004 not packable");
    add_w(1, wa(MB * 4), 3, LSB, 1, CNOM, 0);                              // Non-modifiable
    add_w(2, wa(MB * 8 + 1), 4, (LSB > 0) ? LSB - 1 : 0, 1, CMOD, 0);      // narrow
    add_w(3, wa(MB * 12), 3, LSB, 0, CMOD, 0);                             // FIXED
    add_w(4, wa(MB * 16), 3, LSB, 1, CMOD, 1);                             // exclusive / locked
    add_w(5, wa(MB * 20), 2, LSB, 1, CMOD, AXI3 ? 2 : 1);
    add_r(1, ra(MB * 4), 3, LSB, 1, CNOM, 0);
    add_r(2, ra(MB * 8 + 1), 4, (LSB > 0) ? LSB - 1 : 0, 1, CMOD, 0);
    add_r(3, ra(MB * 12), 3, LSB, 0, CMOD, 0);
    add_r(4, ra(MB * 16), 3, LSB, 1, CMOD, 1);
    end_test("TEST-004");
  endtask

  task automatic t_wrap();                         // TEST-007, WF-006, WF-009
    int cbig, csmall;
    begin_test("TEST-007 WRAP");
    // container 4 beats at least M bytes when RATIO >= 4: use 16 beats (container 16 * SB bytes)
    add_w(1, wa(MB * 16), 15, LSB, 2, CMOD, 0);                             // container 16*SB, aligned to M: packed if >= M
    add_w(2, wa(MB * 64 + SB * 4), 15, LSB, 2, CMOD, 0);                    // container >= M, start not aligned to M (not packed)
    add_w(3, wa(MB * 100 + SB), 1, LSB, 2, CMOD, 0);                        // container 2*SB
    add_w(4, wa(MB * 120 + SB), 3, LSB, 2, CMOD, 0);                        // container 4*SB
    add_r(1, ra(MB * 16), 15, LSB, 2, CMOD, 0);
    add_r(2, ra(MB * 64 + SB * 4), 15, LSB, 2, CMOD, 0);
    add_r(3, ra(MB * 100 + SB), 1, LSB, 2, CMOD, 0);
    add_r(4, ra(MB * 120 + SB), 3, LSB, 2, CMOD, 0);
    end_test("TEST-007");
  endtask

  task automatic t_backpressure();                 // TEST-005, WF-004
    int i;
    begin_test("TEST-005 backpressure");
    m_awrdy_pct = 30; m_wrdy_pct = 30; m_arrdy_pct = 30; m_rvalid_pct = 40; m_bvalid_pct = 40;
    w_gap_pct = 50; w_gap_max = 3; s_rready_pct = 50; s_bready_pct = 50;
    for (i = 0; i < 6; i++) begin
      add_w(i, wa(MB * 8 * i), 7, LSB, 1, CMOD, 0);
      add_r(i, ra(MB * 8 * i), 7, LSB, 1, CMOD, 0);
    end
    end_test("TEST-005");
    // responses not accepted for a long time: the B and R slices fill up and READY of the M side drops
    begin_test("TEST-005b response backpressure");
    s_bready_pct = 8; s_rready_pct = 8; m_bvalid_pct = 100; m_rvalid_pct = 100;
    for (i = 0; i < 12; i++) begin
      add_w(i, wa(MB * 4 * i), 0, LSB, 1, CMOD, 0);
      add_r(i, ra(MB * 4 * i), 0, LSB, 1, CMOD, 0);
    end
    end_test("TEST-005b");
  endtask

  task automatic t_w_before_aw();                  // TEST-006, WF-005
    int i;
    begin_test("TEST-006 W before AW");
    aw_gap_pct = 100; aw_gap_max = 12; w_early_pct = 100; w_ilk = 1; aw_first_delay = 12;
    for (i = 0; i < 4; i++) add_w(i, wa(MB * 8 * i), 3, LSB, 1, CMOD, 0);
    end_test("TEST-006");
  endtask

  task automatic t_errors();                       // TEST-009, WF-010
    int i;
    begin_test("TEST-009 error responses");
    err_pct = 50;
    for (i = 0; i < 8; i++) begin
      add_w(i, wa(MB * 8 * i), 7, LSB, 1, CMOD, 0);
      add_r(i, ra(MB * 8 * i), 7, (i % 2) ? LSB : 0, 1, (i % 2) ? CMOD : CNOM, 0);
    end
    end_test("TEST-009");
  endtask

  task automatic t_queue_full();                   // TEST-010, WF-011
    int i, wmax, rmax, cyc;
    begin_test("TEST-010 queue full");
    for (i = 0; i < WR_DEPTH + 3; i++) add_w(i, wa(MB * 4 * i), 1, LSB, 1, CMOD, 0);
    for (i = 0; i < RD_DEPTH + 3; i++) add_r(i, ra(MB * 4 * i), 1, LSB, 1, CMOD, 0);
    m_hold = 1;
    wmax = 0; rmax = 0;
    for (cyc = 0; cyc < 400; cyc++) begin
      @(posedge clk);
      if (awk > wmax) wmax = awk;
      if (ark > rmax) rmax = ark;
    end
    // the downstream is stalled: AW/AR acceptance is limited by the queue (REQ-PARAM-003)
    if (awk < WR_DEPTH) fail($sformatf("queue full: only %0d AW accepted, depth %0d (REQ-PARAM-003)", awk, WR_DEPTH));
    if (ark < RD_DEPTH) fail($sformatf("queue full: only %0d AR accepted, depth %0d (REQ-PARAM-003)", ark, RD_DEPTH));
    if (awk >= wgen) fail($sformatf("queue full: all %0d AW accepted while the downstream is stalled, depth %0d (REQ-PARAM-003)", awk, WR_DEPTH));
    if (ark >= rgen) fail($sformatf("queue full: all %0d AR accepted while the downstream is stalled, depth %0d (REQ-PARAM-003)", ark, RD_DEPTH));
    m_hold = 0;
    end_test("TEST-010");
  endtask

  task automatic t_reset_mid();                    // TEST-011, WF-012
    int i;
    begin_test("TEST-011 reset during bursts");
    m_wrdy_pct = 50; m_rvalid_pct = 50;
    for (i = 0; i < 4; i++) begin
      add_w(i, wa(MB * 16 * i), 15, LSB, 1, CMOD, 0);
      add_r(i, ra(MB * 16 * i), 15, LSB, 1, CMOD, 0);
    end
    repeat (40) @(posedge clk);
    // reset in the middle of the bursts, then new traffic
    do_reset();
    add_w(1, wa(MB * 4), 5, LSB, 1, CMOD, 0);
    add_r(2, ra(MB * 4), 5, LSB, 1, CMOD, 0);
    add_w(3, wa(MB * 40 + 1), 2, 0, 1, CMOD, 0);
    end_test("TEST-011");
  endtask

  task automatic t_interleave();                   // TEST-021, WF-013 (AXI3)
    begin_test("TEST-021 AXI3 write interleave");
    w_ilk = (IL_DEPTH > 1) ? 2 : 1;
    aw_gap_pct = 0;
    add_w(1, wa(MB * 4), 7, LSB, 1, CMOD, 0);
    add_w(2, wa(MB * 12), 7, LSB, 1, CMOD, 0);
    add_w(3, wa(MB * 20), 7, LSB, 1, CMOD, 0);
    end_test("TEST-021");
  endtask

  task automatic t_random(input int nb);           // TEST-001, TEST-012, TEST-013, TEST-019, TEST-020
    int b, i, tw, tr;
    string nm;
    for (b = 0; b < nb; b++) begin
      nm = $sformatf("TEST-001 random batch %0d", b);
      begin_test(nm);
      case (b % 4)
        0: begin end
        1: begin m_awrdy_pct = 60; m_wrdy_pct = 60; m_arrdy_pct = 60; m_rvalid_pct = 60; m_bvalid_pct = 60;
                 aw_gap_pct = 30; aw_gap_max = 4; w_gap_pct = 30; w_gap_max = 3; ar_gap_pct = 30; ar_gap_max = 4;
                 s_rready_pct = 70; s_bready_pct = 70; err_pct = 5; end
        2: begin m_awrdy_pct = 20; m_wrdy_pct = 25; m_arrdy_pct = 20; m_rvalid_pct = 30; m_bvalid_pct = 30;
                 w_gap_pct = 60; w_gap_max = 5; s_rready_pct = 40; s_bready_pct = 30; w_early_pct = 30; err_pct = 10; end
        3: begin err_pct = 3; w_early_pct = 50; s_rready_pct = 85; m_wrdy_pct = 80; end
      endcase
      if (AXI3) w_ilk = 1 + rr(IL_DEPTH);
      if (AXI3 && b % 2 == 1) w_ilk = IL_DEPTH;
      tw = 0; tr = 0;
      for (i = 0; i < NTX; i++) begin
        if (gen_w((AXI3 ? wgen : rr(IDN)) % IDN)) tw = tw + 1;
        gen_r(rr(IDN));
        tr = tr + 1;
      end
      end_test(nm);
    end
  endtask

  // ---------------------------------------------------------------------------------------------------
  // main sequence and report
  // ---------------------------------------------------------------------------------------------------
  string tsel;
  int seed, nbatch_run, ntx_run;
  int i_rep;

  task automatic report();
    int i, tot_bad, never;
    tot_bad = 0; never = 0;
    $display("---------------- assertion table (hits / failures) ----------------");
    for (i = 0; i < 33; i++) begin
      if (u_chk_s.en[i] != 0 || u_chk_m.en[i] != 0) begin
        $display("S side %-3d hits %-8d bad %-4d  %0s", i + 1, u_chk_s.hit[i], u_chk_s.bad[i], u_chk_s.nm[i]);
        $display("M side %-3d hits %-8d bad %-4d", i + 1, u_chk_m.hit[i], u_chk_m.bad[i]);
        tot_bad = tot_bad + u_chk_s.bad[i] + u_chk_m.bad[i];
        if (u_chk_s.en[i] != 0 && u_chk_s.hit[i] == 0) never = never + 1;
        if (u_chk_m.en[i] != 0 && u_chk_m.hit[i] == 0) never = never + 1;
      end
    end
    $display("coverage COV-001 classes: packed INCR %0d, packed WRAP>=M %0d, packed WRAP<M %0d, non-modifiable %0d, narrow %0d, FIXED %0d, locked %0d, WRAP not aligned %0d",
             cov_class[0], cov_class[1], cov_class[2], cov_class[3], cov_class[4], cov_class[5], cov_class[6], cov_class[7]);
    $display("coverage COV-005 error responses: R beats %0d, B %0d", cov_rerr, cov_berr);
    if (AXI3) $display("coverage COV-006 AXI3 contexts: max active %0d, beats that switch transaction %0d, 2 contexts %0d, 3 contexts %0d, 4 or more %0d",
                       cov_ctx_max, cov_switch, cov_ctx_hist[2], cov_ctx_hist[3], cov_ctx_hist[4]);
    $display("tests run %0d, failed %0d, check failures %0d", tests_run, tests_fail, err_cnt);
    $display("assertion failures: %0d, assertions never exercised: %0d", tot_bad, never);
    if (err_cnt == 0 && tot_bad == 0 && never == 0 && tests_fail == 0) $display("PASS tb_ups");
    else $display("FAIL tb_ups");
    if (err_cnt != 0 || tot_bad != 0 || never != 0 || tests_fail != 0) $fatal(1, "tb_ups failed");
    $finish;
  endtask

  initial begin
    string vcd;
    if (!$value$plusargs("SEED=%d", seed)) seed = 1;
    if (!$value$plusargs("TEST=%s", tsel)) tsel = "all";
    if (!$value$plusargs("NBATCH=%d", nbatch_run)) nbatch_run = NBATCH;
    rng = 32'h1234567 ^ (32'(seed) * 32'h9E3779B1);
    if (rng == 0) rng = 1;
    if ($value$plusargs("VCD=%s", vcd)) begin
      $dumpfile(vcd);
      $dumpvars(0, tb_ups);
    end
    $display("CONFIG PROFILE=%0d S=%0d M=%0d ADDR=%0d ID=%0d WR_DEPTH=%0d RD_DEPTH=%0d IL_DEPTH=%0d seed=%0d test=%0s",
             PROFILE, S_W, M_W, ADDR_W, ID_W, WR_DEPTH, RD_DEPTH, IL_DEPTH, seed, tsel);
    err_cnt = 0; tests_run = 0; tests_fail = 0;
    for (i_rep = 0; i_rep < 8; i_rep++) cov_class[i_rep] = 0;
    cov_rerr = 0; cov_berr = 0; cov_ctx_max = 0; cov_switch = 0;
    for (i_rep = 0; i_rep < 5; i_rep++) cov_ctx_hist[i_rep] = 0;
    tb_clr = 1'b1;
    set_defaults();
    s_awvalid = 0; s_wvalid = 0; s_arvalid = 0;
    repeat (3) @(posedge clk);
    if (tsel == "all" || tsel == "directed") begin
      t_pack_aligned();
      t_pack_unaligned();
      t_lane_steering();
      t_wrap();
      t_backpressure();
      t_w_before_aw();
      t_errors();
      t_queue_full();
      t_reset_mid();
      if (AXI3) t_interleave();
    end
    if (tsel == "all" || tsel == "random") t_random(nbatch_run);
    report();
  end

  // global watchdog
  initial begin
    #(64'd400_000_000);
    $display("FAIL tb_ups: global timeout");
    $fatal(1, "timeout");
  end

endmodule
