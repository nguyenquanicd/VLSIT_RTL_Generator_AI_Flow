/*
 * Project      : VLSIT Common RTL library
 * Author       : Nguyen Quan and Claude Sonnet 5.5 (user)
 * AI Flow      : VLSIT RTL Generator AI Automation Flow
 * AI Flow Page : https://github.com/nguyenquanicd/VLSIT_RTL_Generator_AI_Model
 * Date         : 2026-10-26
 * Description  : Structural top of the AXI2TLUL bridge: one AXI4 Subordinate port to one OpenTitan
 *                TL-UL host port on one clock. It splits AXI4 bursts (INCR, WRAP, FIXED, narrow,
 *                unaligned) into single-beat TL-UL requests with a tag in a_source, and returns the
 *                TL-UL responses as AXI read data and write responses in the order that AXI
 *                requires for each ID. It has two-entry input slices, a request engine per
 *                direction, an arbiter with the channel A register, a response decoder, a slot
 *                table with ID contexts per direction, and a read data storage. All outputs are
 *                flip-flops. Exclusive access is completed as a normal access with OKAY; AxPROT[2]
 *                becomes the TL-UL instr_type; AxCACHE, AxQOS, AxREGION, d_param, d_sink, d_user,
 *                and d_size are ignored. The integrity bits of a_user are at their default value,
 *                so the integrity generator of OpenTitan must follow the bridge when the target
 *                devices check integrity.
 */
`timescale 1ns/1ps

module m_vlsit_axi2tlul_top #(
  // Parameter Description: width of the data buses of the AXI and TL-UL sides (one value for both).
  // Parameter values: 32, 64, 128, 256, 512, or 1024; default is 32.
  // Parameter unit: bit
  parameter logic [31:0] PARA_DATA_W = 32,
  // Parameter Description: width of the addresses of the AXI and TL-UL sides.
  // Parameter values: 12 to 64; default is 32.
  // Parameter unit: bit
  parameter logic [31:0] PARA_ADDR_W = 32,
  // Parameter Description: width of the AXI IDs (AWID, ARID, BID, RID).
  // Parameter values: 1 to 32; default is 8.
  // Parameter unit: bit
  parameter logic [31:0] PARA_AXI_ID_W = 8,
  // Parameter Description: width of the TL-UL source field (tag): direction bit plus slot index.
  // Parameter values: at least LPARA_SLOT_W + 1, at most 32; default is 8.
  // Parameter unit: bit
  parameter logic [31:0] PARA_TL_SRC_W = 8,
  // Parameter Description: width of the TL-UL a_user field; bits above 17 are reserved (0).
  // Parameter values: 18 to 64; default is 18.
  // Parameter unit: bit
  parameter logic [31:0] PARA_TL_AUSER_W = 18,
  // Parameter Description: width of the TL-UL d_user input, which is ignored.
  // Parameter values: 1 to 64; default is 14.
  // Parameter unit: bit
  parameter logic [31:0] PARA_TL_DUSER_W = 14,
  // Parameter Description: width of the TL-UL d_sink input, which is ignored.
  // Parameter values: 1 to 8; default is 1.
  // Parameter unit: bit
  parameter logic [31:0] PARA_TL_SINK_W = 1,
  // Parameter Description: number of read slots, the maximum number of outstanding read beats.
  // Parameter values: power of two from 2 to 128; default is 16.
  // Parameter unit: count
  parameter logic [31:0] PARA_NUM_RD = 16,
  // Parameter Description: number of write slots, the maximum number of outstanding write beats.
  // Parameter values: power of two from 2 to 128; default is 16.
  // Parameter unit: count
  parameter logic [31:0] PARA_NUM_WR = 16,
  // Parameter Description: number of read ID contexts, the AXI IDs with read beats in flight.
  // Parameter values: 1 to PARA_NUM_RD; default is 4.
  // Parameter unit: count
  parameter logic [31:0] PARA_NUM_ID_RD = 4,
  // Parameter Description: number of write ID contexts, the AXI IDs with write beats in flight.
  // Parameter values: 1 to PARA_NUM_WR; default is 4.
  // Parameter unit: count
  parameter logic [31:0] PARA_NUM_ID_WR = 4,
  // Parameter Description: arbitration of read and write requests on TL-UL channel A.
  // Parameter values: 0 = round-robin, 1 = read priority, 2 = write priority; default is 0.
  // Parameter unit: none
  parameter logic [31:0] PARA_ARB_MODE = 0,
  // Parameter Description: implementation of the read data storage, 0 = array, 1 = macro wrapper.
  // Parameter values: 0 or 1; default is 0.
  // Parameter unit: none
  parameter logic [31:0] PARA_STORE_MACRO = 0,
  localparam logic [31:0] LPARA_STRB_W = PARA_DATA_W / 8,
  localparam logic [31:0] LPARA_SIZE_W = $clog2($clog2(PARA_DATA_W / 8) + 1),
  localparam logic [31:0] LPARA_RD_IDX_W = $clog2(PARA_NUM_RD),
  localparam logic [31:0] LPARA_WR_IDX_W = $clog2(PARA_NUM_WR),
  localparam logic [31:0] LPARA_CNT_W = $clog2(PARA_NUM_RD) + 1,
  localparam logic [31:0] LPARA_AR_W = PARA_AXI_ID_W + PARA_ADDR_W + 14,
  localparam logic [31:0] LPARA_W_W = PARA_DATA_W + PARA_DATA_W / 8 + 1
) (
  // Clock and reset
  input  wire                        i_clk_main,
  input  wire                        i_rst_n_main,

  // AXI4 write address channel
  input  wire                        i_axi_awvalid,
  output logic                       o_axi_awready,
  input  wire  [PARA_AXI_ID_W-1:0]   i_axi_awid,
  input  wire  [PARA_ADDR_W-1:0]     i_axi_awaddr,
  input  wire  [7:0]                 i_axi_awlen,
  input  wire  [2:0]                 i_axi_awsize,
  input  wire  [1:0]                 i_axi_awburst,
  input  wire                        i_axi_awlock,
  input  wire  [3:0]                 i_axi_awcache,
  input  wire  [2:0]                 i_axi_awprot,
  input  wire  [3:0]                 i_axi_awqos,
  input  wire  [3:0]                 i_axi_awregion,

  // AXI4 write data channel
  input  wire                        i_axi_wvalid,
  output logic                       o_axi_wready,
  input  wire  [PARA_DATA_W-1:0]     i_axi_wdata,
  input  wire  [LPARA_STRB_W-1:0]    i_axi_wstrb,
  input  wire                        i_axi_wlast,

  // AXI4 write response channel
  output logic                       o_axi_bvalid,
  input  wire                        i_axi_bready,
  output logic [PARA_AXI_ID_W-1:0]   o_axi_bid,
  output logic [1:0]                 o_axi_bresp,

  // AXI4 read address channel
  input  wire                        i_axi_arvalid,
  output logic                       o_axi_arready,
  input  wire  [PARA_AXI_ID_W-1:0]   i_axi_arid,
  input  wire  [PARA_ADDR_W-1:0]     i_axi_araddr,
  input  wire  [7:0]                 i_axi_arlen,
  input  wire  [2:0]                 i_axi_arsize,
  input  wire  [1:0]                 i_axi_arburst,
  input  wire                        i_axi_arlock,
  input  wire  [3:0]                 i_axi_arcache,
  input  wire  [2:0]                 i_axi_arprot,
  input  wire  [3:0]                 i_axi_arqos,
  input  wire  [3:0]                 i_axi_arregion,

  // AXI4 read data channel
  output logic                       o_axi_rvalid,
  input  wire                        i_axi_rready,
  output logic [PARA_AXI_ID_W-1:0]   o_axi_rid,
  output logic [PARA_DATA_W-1:0]     o_axi_rdata,
  output logic [1:0]                 o_axi_rresp,
  output logic                       o_axi_rlast,

  // TL-UL request channel A
  output logic                       o_tl_a_valid,
  input  wire                        i_tl_a_ready,
  output logic [2:0]                 o_tl_a_opcode,
  output logic [2:0]                 o_tl_a_param,
  output logic [LPARA_SIZE_W-1:0]    o_tl_a_size,
  output logic [PARA_TL_SRC_W-1:0]   o_tl_a_src,
  output logic [PARA_ADDR_W-1:0]     o_tl_a_addr,
  output logic [LPARA_STRB_W-1:0]    o_tl_a_mask,
  output logic [PARA_DATA_W-1:0]     o_tl_a_data,
  output logic [PARA_TL_AUSER_W-1:0] o_tl_a_user,

  // TL-UL response channel D
  input  wire                        i_tl_d_valid,
  output logic                       o_tl_d_ready,
  input  wire  [2:0]                 i_tl_d_opcode,
  input  wire  [2:0]                 i_tl_d_param,
  input  wire  [LPARA_SIZE_W-1:0]    i_tl_d_size,
  input  wire  [PARA_TL_SRC_W-1:0]   i_tl_d_src,
  input  wire  [PARA_TL_SINK_W-1:0]  i_tl_d_sink,
  input  wire  [PARA_DATA_W-1:0]     i_tl_d_data,
  input  wire  [PARA_TL_DUSER_W-1:0] i_tl_d_user,
  input  wire                        i_tl_d_err,

  // Status pulses
  output logic                       o_evt_orphan_resp,
  output logic                       o_evt_bad_resp,
  output logic                       o_evt_axi_err_rd,
  output logic                       o_evt_axi_err_wr
);

  // Interconnect: input slices to the request engines.
  logic                       w_ar_sk_valid;
  logic                       w_ar_sk_ready;
  logic [LPARA_AR_W-1:0]      w_ar_sk_data;
  logic                       w_aw_sk_valid;
  logic                       w_aw_sk_ready;
  logic [LPARA_AR_W-1:0]      w_aw_sk_data;
  logic                       w_w_sk_valid;
  logic                       w_w_sk_ready;
  logic [LPARA_W_W-1:0]       w_w_sk_data;

  // Interconnect: request engines to the arbiter.
  logic                       w_rd_req_valid;
  logic                       w_rd_req_gnt;
  logic [PARA_ADDR_W-1:0]     w_rd_req_addr;
  logic [LPARA_SIZE_W-1:0]    w_rd_req_size;
  logic [LPARA_STRB_W-1:0]    w_rd_req_mask;
  logic                       w_rd_req_instr;
  logic [LPARA_RD_IDX_W-1:0]  w_rd_slot;
  logic                       w_wr_req_valid;
  logic                       w_wr_req_gnt;
  logic [2:0]                 w_wr_req_opcode;
  logic [PARA_ADDR_W-1:0]     w_wr_req_addr;
  logic [LPARA_SIZE_W-1:0]    w_wr_req_size;
  logic [LPARA_STRB_W-1:0]    w_wr_req_mask;
  logic [PARA_DATA_W-1:0]     w_wr_req_data;
  logic                       w_wr_req_instr;
  logic [LPARA_WR_IDX_W-1:0]  w_wr_slot;

  // Interconnect: request engines to the slot tables.
  logic                       w_rd_alloc_en;
  logic                       w_rd_alloc_gen;
  logic [PARA_AXI_ID_W-1:0]   w_rd_alloc_id;
  logic                       w_rd_alloc_last;
  logic [LPARA_CNT_W-1:0]     w_rd_alloc_need;
  logic                       w_rd_alloc_ok;
  logic                       w_rd_pin_valid;
  logic [PARA_AXI_ID_W-1:0]   w_rd_pin_id;
  logic                       w_wr_alloc_en;
  logic                       w_wr_alloc_gen;
  logic [PARA_AXI_ID_W-1:0]   w_wr_alloc_id;
  logic                       w_wr_alloc_last;
  logic                       w_wr_alloc_ok;
  logic                       w_wr_pin_valid;
  logic [PARA_AXI_ID_W-1:0]   w_wr_pin_id;

  // Interconnect: response decoder to the slot tables, and the read storage.
  logic                       w_rd_cmp_valid;
  logic [LPARA_RD_IDX_W-1:0]  w_rd_cmp_idx;
  logic                       w_rd_cmp_err;
  logic                       w_rd_cmp_orphan;
  logic                       w_wr_cmp_valid;
  logic [LPARA_WR_IDX_W-1:0]  w_wr_cmp_idx;
  logic                       w_wr_cmp_err;
  logic                       w_wr_cmp_orphan;
  logic                       w_store_wr_en;
  logic [LPARA_RD_IDX_W-1:0]  w_store_wr_addr;
  logic [PARA_DATA_W-1:0]     w_store_wr_data;
  logic                       w_store_rd_en;
  logic [LPARA_RD_IDX_W-1:0]  w_store_rd_addr;
  logic [PARA_DATA_W-1:0]     w_store_rd_data;

  // Interconnect: conditions of the status pulses.
  logic                       w_evt_orphan;
  logic                       w_evt_bad;
  logic                       w_evt_axi_err_rd;
  logic                       w_evt_axi_err_wr;

  // Input slice of the read address channel: all fields of AR except VALID and READY.
  m_vlsit_axi2tlul_skid #(
    .PARA_PAYLOAD_W (LPARA_AR_W)
  ) u_ar_skid (
    .i_clk_main   (i_clk_main),
    .i_rst_n_main (i_rst_n_main),
    .i_valid      (i_axi_arvalid),
    .o_ready      (o_axi_arready),
    .i_data       ({i_axi_arprot[2], i_axi_arburst, i_axi_arsize, i_axi_arlen, i_axi_araddr, i_axi_arid}),
    .o_valid      (w_ar_sk_valid),
    .i_ready      (w_ar_sk_ready),
    .o_data       (w_ar_sk_data)
  );

  // Input slice of the write address channel: all fields of AW except VALID and READY.
  m_vlsit_axi2tlul_skid #(
    .PARA_PAYLOAD_W (LPARA_AR_W)
  ) u_aw_skid (
    .i_clk_main   (i_clk_main),
    .i_rst_n_main (i_rst_n_main),
    .i_valid      (i_axi_awvalid),
    .o_ready      (o_axi_awready),
    .i_data       ({i_axi_awprot[2], i_axi_awburst, i_axi_awsize, i_axi_awlen, i_axi_awaddr, i_axi_awid}),
    .o_valid      (w_aw_sk_valid),
    .i_ready      (w_aw_sk_ready),
    .o_data       (w_aw_sk_data)
  );

  // Input slice of the write data channel: data, strobe, and last.
  m_vlsit_axi2tlul_skid #(
    .PARA_PAYLOAD_W (LPARA_W_W)
  ) u_w_skid (
    .i_clk_main   (i_clk_main),
    .i_rst_n_main (i_rst_n_main),
    .i_valid      (i_axi_wvalid),
    .o_ready      (o_axi_wready),
    .i_data       ({i_axi_wlast, i_axi_wstrb, i_axi_wdata}),
    .o_valid      (w_w_sk_valid),
    .i_ready      (w_w_sk_ready),
    .o_data       (w_w_sk_data)
  );

  // Read request engine: burst check, beat addresses, Get requests, error beats of illegal bursts.
  m_vlsit_axi2tlul_rd_req #(
    .PARA_ADDR_W   (PARA_ADDR_W),
    .PARA_AXI_ID_W (PARA_AXI_ID_W),
    .PARA_DATA_W   (PARA_DATA_W),
    .PARA_NUM_RD   (PARA_NUM_RD)
  ) u_rd_req (
    .i_clk_main     (i_clk_main),
    .i_rst_n_main   (i_rst_n_main),
    .i_ar_valid     (w_ar_sk_valid),
    .o_ar_ready     (w_ar_sk_ready),
    .i_ar_data      (w_ar_sk_data),
    .o_req_valid    (w_rd_req_valid),
    .i_req_gnt      (w_rd_req_gnt),
    .o_req_addr     (w_rd_req_addr),
    .o_req_size     (w_rd_req_size),
    .o_req_mask     (w_rd_req_mask),
    .o_req_instr    (w_rd_req_instr),
    .o_alloc_en     (w_rd_alloc_en),
    .o_alloc_gen    (w_rd_alloc_gen),
    .o_alloc_id     (w_rd_alloc_id),
    .o_alloc_last   (w_rd_alloc_last),
    .o_alloc_need   (w_rd_alloc_need),
    .i_alloc_ok     (w_rd_alloc_ok),
    .o_pin_valid    (w_rd_pin_valid),
    .o_pin_id       (w_rd_pin_id),
    .o_evt_axi_err  (w_evt_axi_err_rd)
  );

  // Write request engine: burst check, pairing with the W beats, Put requests, drop of illegal
  // bursts.
  m_vlsit_axi2tlul_wr_req #(
    .PARA_ADDR_W   (PARA_ADDR_W),
    .PARA_AXI_ID_W (PARA_AXI_ID_W),
    .PARA_DATA_W   (PARA_DATA_W)
  ) u_wr_req (
    .i_clk_main     (i_clk_main),
    .i_rst_n_main   (i_rst_n_main),
    .i_aw_valid     (w_aw_sk_valid),
    .o_aw_ready     (w_aw_sk_ready),
    .i_aw_data      (w_aw_sk_data),
    .i_w_valid      (w_w_sk_valid),
    .o_w_ready      (w_w_sk_ready),
    .i_w_data       (w_w_sk_data),
    .o_req_valid    (w_wr_req_valid),
    .i_req_gnt      (w_wr_req_gnt),
    .o_req_opcode   (w_wr_req_opcode),
    .o_req_addr     (w_wr_req_addr),
    .o_req_size     (w_wr_req_size),
    .o_req_mask     (w_wr_req_mask),
    .o_req_data     (w_wr_req_data),
    .o_req_instr    (w_wr_req_instr),
    .o_alloc_en     (w_wr_alloc_en),
    .o_alloc_gen    (w_wr_alloc_gen),
    .o_alloc_id     (w_wr_alloc_id),
    .o_alloc_last   (w_wr_alloc_last),
    .i_alloc_ok     (w_wr_alloc_ok),
    .o_pin_valid    (w_wr_pin_valid),
    .o_pin_id       (w_wr_pin_id),
    .o_evt_axi_err  (w_evt_axi_err_wr)
  );

  // Arbiter and TL-UL channel A register: grants one request and builds the tag and user bits.
  m_vlsit_axi2tlul_arb #(
    .PARA_ADDR_W     (PARA_ADDR_W),
    .PARA_DATA_W     (PARA_DATA_W),
    .PARA_TL_SRC_W   (PARA_TL_SRC_W),
    .PARA_TL_AUSER_W (PARA_TL_AUSER_W),
    .PARA_NUM_RD     (PARA_NUM_RD),
    .PARA_NUM_WR     (PARA_NUM_WR),
    .PARA_ARB_MODE   (PARA_ARB_MODE)
  ) u_arb (
    .i_clk_main    (i_clk_main),
    .i_rst_n_main  (i_rst_n_main),
    .i_rd_valid    (w_rd_req_valid),
    .o_rd_gnt      (w_rd_req_gnt),
    .i_rd_addr     (w_rd_req_addr),
    .i_rd_size     (w_rd_req_size),
    .i_rd_mask     (w_rd_req_mask),
    .i_rd_instr    (w_rd_req_instr),
    .i_rd_slot     (w_rd_slot),
    .i_wr_valid    (w_wr_req_valid),
    .o_wr_gnt      (w_wr_req_gnt),
    .i_wr_opcode   (w_wr_req_opcode),
    .i_wr_addr     (w_wr_req_addr),
    .i_wr_size     (w_wr_req_size),
    .i_wr_mask     (w_wr_req_mask),
    .i_wr_data     (w_wr_req_data),
    .i_wr_instr    (w_wr_req_instr),
    .i_wr_slot     (w_wr_slot),
    .o_tl_a_valid  (o_tl_a_valid),
    .i_tl_a_ready  (i_tl_a_ready),
    .o_tl_a_opcode (o_tl_a_opcode),
    .o_tl_a_param  (o_tl_a_param),
    .o_tl_a_size   (o_tl_a_size),
    .o_tl_a_src    (o_tl_a_src),
    .o_tl_a_addr   (o_tl_a_addr),
    .o_tl_a_mask   (o_tl_a_mask),
    .o_tl_a_data   (o_tl_a_data),
    .o_tl_a_user   (o_tl_a_user)
  );

  // Response decoder: accepts channel D, decodes the tag, and completes the slot of its direction.
  m_vlsit_axi2tlul_rsp_dec #(
    .PARA_TL_SRC_W (PARA_TL_SRC_W),
    .PARA_NUM_RD   (PARA_NUM_RD),
    .PARA_NUM_WR   (PARA_NUM_WR)
  ) u_rsp_dec (
    .i_clk_main      (i_clk_main),
    .i_rst_n_main    (i_rst_n_main),
    .i_tl_d_valid    (i_tl_d_valid),
    .o_tl_d_ready    (o_tl_d_ready),
    .i_tl_d_opcode   (i_tl_d_opcode),
    .i_tl_d_src      (i_tl_d_src),
    .i_tl_d_err      (i_tl_d_err),
    .o_rd_cmp_valid  (w_rd_cmp_valid),
    .o_rd_cmp_idx    (w_rd_cmp_idx),
    .o_rd_cmp_err    (w_rd_cmp_err),
    .i_rd_cmp_orphan (w_rd_cmp_orphan),
    .o_wr_cmp_valid  (w_wr_cmp_valid),
    .o_wr_cmp_idx    (w_wr_cmp_idx),
    .o_wr_cmp_err    (w_wr_cmp_err),
    .i_wr_cmp_orphan (w_wr_cmp_orphan),
    .o_orphan        (w_evt_orphan),
    .o_bad           (w_evt_bad)
  );

  // Read slot table: reserves slots, keeps the order per ID, and drives the AXI R channel.
  m_vlsit_axi2tlul_rd_rob #(
    .PARA_NUM_RD    (PARA_NUM_RD),
    .PARA_NUM_ID_RD (PARA_NUM_ID_RD),
    .PARA_AXI_ID_W  (PARA_AXI_ID_W),
    .PARA_DATA_W    (PARA_DATA_W)
  ) u_rd_rob (
    .i_clk_main      (i_clk_main),
    .i_rst_n_main    (i_rst_n_main),
    .i_alloc_en      (w_rd_alloc_en),
    .i_alloc_gen     (w_rd_alloc_gen),
    .i_alloc_id      (w_rd_alloc_id),
    .i_alloc_last    (w_rd_alloc_last),
    .i_alloc_need    (w_rd_alloc_need),
    .i_pin_valid     (w_rd_pin_valid),
    .i_pin_id        (w_rd_pin_id),
    .o_alloc_ok      (w_rd_alloc_ok),
    .o_alloc_slot    (w_rd_slot),
    .i_cmp_valid     (w_rd_cmp_valid),
    .i_cmp_idx       (w_rd_cmp_idx),
    .i_cmp_err       (w_rd_cmp_err),
    .i_cmp_data      (i_tl_d_data),
    .o_cmp_orphan    (w_rd_cmp_orphan),
    .o_store_wr_en   (w_store_wr_en),
    .o_store_wr_addr (w_store_wr_addr),
    .o_store_wr_data (w_store_wr_data),
    .o_store_rd_en   (w_store_rd_en),
    .o_store_rd_addr (w_store_rd_addr),
    .i_store_rd_data (w_store_rd_data),
    .o_axi_rvalid    (o_axi_rvalid),
    .i_axi_rready    (i_axi_rready),
    .o_axi_rid       (o_axi_rid),
    .o_axi_rdata     (o_axi_rdata),
    .o_axi_rresp     (o_axi_rresp),
    .o_axi_rlast     (o_axi_rlast)
  );

  // Write slot table: reserves slots, keeps the order per ID, and drives the AXI B channel.
  m_vlsit_axi2tlul_wr_rob #(
    .PARA_NUM_WR    (PARA_NUM_WR),
    .PARA_NUM_ID_WR (PARA_NUM_ID_WR),
    .PARA_AXI_ID_W  (PARA_AXI_ID_W)
  ) u_wr_rob (
    .i_clk_main    (i_clk_main),
    .i_rst_n_main  (i_rst_n_main),
    .i_alloc_en    (w_wr_alloc_en),
    .i_alloc_gen   (w_wr_alloc_gen),
    .i_alloc_id    (w_wr_alloc_id),
    .i_alloc_last  (w_wr_alloc_last),
    .i_pin_valid   (w_wr_pin_valid),
    .i_pin_id      (w_wr_pin_id),
    .o_alloc_ok    (w_wr_alloc_ok),
    .o_alloc_slot  (w_wr_slot),
    .i_cmp_valid   (w_wr_cmp_valid),
    .i_cmp_idx     (w_wr_cmp_idx),
    .i_cmp_err     (w_wr_cmp_err),
    .o_cmp_orphan  (w_wr_cmp_orphan),
    .o_axi_bvalid  (o_axi_bvalid),
    .i_axi_bready  (i_axi_bready),
    .o_axi_bid     (o_axi_bid),
    .o_axi_bresp   (o_axi_bresp)
  );

  // Read data storage: array or SRAM macro wrapper, one write port and one read port.
  m_vlsit_axi2tlul_store #(
    .PARA_DEPTH       (PARA_NUM_RD),
    .PARA_DATA_W      (PARA_DATA_W),
    .PARA_STORE_MACRO (PARA_STORE_MACRO)
  ) u_rd_store (
    .i_clk_main (i_clk_main),
    .i_wr_en    (w_store_wr_en),
    .i_wr_addr  (w_store_wr_addr),
    .i_wr_data  (w_store_wr_data),
    .i_rd_en    (w_store_rd_en),
    .i_rd_addr  (w_store_rd_addr),
    .o_rd_data  (w_store_rd_data)
  );

  // Status pulses: flip-flop outputs that repeat the one-cycle conditions of the blocks.
  m_vlsit_axi2tlul_evt u_evt (
    .i_clk_main        (i_clk_main),
    .i_rst_n_main      (i_rst_n_main),
    .i_orphan          (w_evt_orphan),
    .i_bad             (w_evt_bad),
    .i_axi_err_rd      (w_evt_axi_err_rd),
    .i_axi_err_wr      (w_evt_axi_err_wr),
    .o_evt_orphan_resp (o_evt_orphan_resp),
    .o_evt_bad_resp    (o_evt_bad_resp),
    .o_evt_axi_err_rd  (o_evt_axi_err_rd),
    .o_evt_axi_err_wr  (o_evt_axi_err_wr)
  );

endmodule
