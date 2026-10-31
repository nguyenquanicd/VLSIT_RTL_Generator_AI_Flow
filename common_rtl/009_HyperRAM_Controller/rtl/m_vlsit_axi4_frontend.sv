/*
 * Project      : HyperRAM Controller
 * Author       : Nguyen Quan (user)
 * AI Flow      : VLSIT RTL Generator AI Automation Flow
 * AI Flow Page : https://github.com/nguyenquanicd/VLSIT_RTL_Generator_AI_Model
 * Date         : 2026-10-31
 * Description  : AXI4 subordinate front end of the HyperRAM controller (REQ-IF-001 to REQ-IF-003,
 *                REQ-FUNC-002, REQ-FUNC-003). It accepts AR and AW requests into queues of four,
 *                checks the aperture (DECERR) and the burst type (SLVERR for FIXED), splits every
 *                accepted request into segments at the device page, at the chip select boundary, at
 *                the buffer size and at the wrap point, and hands one segment descriptor at a time
 *                per direction to m_vlsit_hyperbus_ctrl. The data of a segment travel as a byte
 *                stream cut into memory units of 2 x PARA_MEM_DQ_W bits (one unit per CK period).
 *                A read segment is issued only when the read buffer has room for all its units, and
 *                a write segment only after all its data are in the write buffer (DEC-044), so the
 *                controller never has to stop a HyperBus transaction in the middle. The split at
 *                the CS#-low limit t_csm is done by the controller (DEC-046).
 *                A read waits while an older accepted write overlaps its byte range (REQ-FUNC-003).
 *                i_abort (timeout) completes the requests that did not finish with SLVERR: queued
 *                reads return the beats already received and then error beats up to RLAST, queued
 *                writes consume their W beats and return B. Assumptions: PARA_MEM_SIZE_BYTES is a
 *                multiple of the AXI strobe width and of PARA_PAGE_BYTES; a segment byte is never
 *                larger than 2047; the AXI burst never crosses 4 KB.
 */
`timescale 1ns/1ps

module m_vlsit_axi4_frontend #(
  // Parameter Description: width of the AXI data bus; the strobe width follows it.
  // Parameter values: 32 or 64; default is 32.
  // Parameter unit: bit
  parameter logic [31:0] PARA_AXI_DATA_W = 32'd32,
  // Parameter Description: width of the HyperBus data bus; one memory unit is two bus widths.
  // Parameter values: 8 or 16; default is 8.
  // Parameter unit: bit
  parameter logic [31:0] PARA_MEM_DQ_W = 32'd8,
  // Parameter Description: number of chip selects; chip select 1 starts at PARA_MEM_SIZE_BYTES.
  // Parameter values: 1 or 2; default is 1.
  // Parameter unit: count
  parameter logic [31:0] PARA_NUM_CS = 32'd1,
  // Parameter Description: byte capacity of one chip select; the window is PARA_NUM_CS times it.
  // Parameter values: multiple of PARA_PAGE_BYTES, 1024 to 33554432; default is 33554432.
  // Parameter unit: byte
  parameter logic [31:0] PARA_MEM_SIZE_BYTES = 32'd33554432,
  // Parameter Description: write buffer size; a write segment is never larger than this size.
  // Parameter values: power of two, 64 to 2048; default is 256.
  // Parameter unit: byte
  parameter logic [31:0] PARA_WR_BUF_BYTES = 32'd256,
  // Parameter Description: read buffer size; a read segment is never larger than this size.
  // Parameter values: power of two, 64 to 2048; default is 256.
  // Parameter unit: byte
  parameter logic [31:0] PARA_RD_BUF_BYTES = 32'd256,
  // Parameter Description: page size of the device where a linear burst is split (REQ-IF-003).
  // Parameter values: power of two, 128 to 4096; default is 1024.
  // Parameter unit: byte
  parameter logic [31:0] PARA_PAGE_BYTES = 32'd1024,
  localparam logic [31:0] LPARA_AXI_ADDR_W   = 32'd32,
  localparam logic [31:0] LPARA_AXI_ID_W     = 32'd4,
  localparam logic [31:0] LPARA_AXI_LEN_W    = 32'd8,
  localparam logic [31:0] LPARA_AXI_STRB_W   = PARA_AXI_DATA_W / 32'd8,
  localparam logic [31:0] LPARA_BUS_LOG2     = $clog2(LPARA_AXI_STRB_W),
  localparam logic [31:0] LPARA_UNIT_BYTES   = PARA_MEM_DQ_W / 32'd4,
  localparam logic [31:0] LPARA_UNIT_LOG2    = $clog2(LPARA_UNIT_BYTES),
  localparam logic [31:0] LPARA_UNIT_W       = PARA_MEM_DQ_W * 32'd2,
  localparam logic [31:0] LPARA_WR_UNITS     = PARA_WR_BUF_BYTES / LPARA_UNIT_BYTES,
  localparam logic [31:0] LPARA_RD_UNITS     = PARA_RD_BUF_BYTES / LPARA_UNIT_BYTES,
  localparam logic [31:0] LPARA_WR_PTR_W     = $clog2(LPARA_WR_UNITS),
  localparam logic [31:0] LPARA_RD_PTR_W     = $clog2(LPARA_RD_UNITS),
  localparam logic [31:0] LPARA_MAXSEG_WR    = PARA_WR_BUF_BYTES - LPARA_UNIT_BYTES,
  localparam logic [31:0] LPARA_MAXSEG_RD    = PARA_RD_BUF_BYTES - LPARA_UNIT_BYTES,
  localparam logic [31:0] LPARA_BYTES_W      = 32'd12,
  localparam logic [31:0] LPARA_RESP_OKAY    = 32'd0,
  localparam logic [31:0] LPARA_RESP_SLVERR  = 32'd2,
  localparam logic [31:0] LPARA_RESP_DECERR  = 32'd3,
  localparam logic [31:0] LPARA_BURST_INCR   = 32'd1,
  localparam logic [31:0] LPARA_BLEN_128     = 32'd128,
  localparam logic [31:0] LPARA_BLEN_64      = 32'd64,
  localparam logic [31:0] LPARA_BLEN_16      = 32'd16,
  localparam logic [31:0] LPARA_BLEN_32      = 32'd32,
  localparam logic [31:0] LPARA_WLEN_2       = 32'd1,
  localparam logic [31:0] LPARA_WLEN_4       = 32'd3,
  localparam logic [31:0] LPARA_WLEN_8       = 32'd7,
  localparam logic [31:0] LPARA_WLEN_16      = 32'd15,
  localparam logic [31:0] LPARA_TWO_CS       = 32'd2,
  localparam logic [31:0] LPARA_IF_DEPTH     = 32'd4,
  localparam logic [31:0] LPARA_MAX_BUS_B    = 32'd8,
  localparam logic [31:0] LPARA_MAX_UNIT_B   = 32'd4,
  localparam logic [31:0] LPARA_IDX_MASK     = 32'd7,
  localparam logic [31:0] LPARA_BYTE_W      = 32'd8,
  localparam logic [31:0] LPARA_BURST_WRAP   = 32'd2
) (
  // Clock and reset
  input  wire                         i_clk_core,
  input  wire                         i_rst_n_core,

  // Control from the controller and the register file
  input  wire                         i_accept_en,
  input  wire                         i_wr_posted,
  input  wire  [1:0]                  i_blen_cs0,
  input  wire  [1:0]                  i_blen_cs1,
  input  wire                         i_abort,

  // AXI4 AW channel
  input  wire                         i_axi_awvalid,
  output logic                        o_axi_awready,
  input  wire  [LPARA_AXI_ID_W-1:0]   i_axi_awid,
  input  wire  [LPARA_AXI_ADDR_W-1:0] i_axi_awaddr,
  input  wire  [LPARA_AXI_LEN_W-1:0]  i_axi_awlen,
  input  wire  [2:0]                  i_axi_awsize,
  input  wire  [1:0]                  i_axi_awburst,

  // AXI4 W channel
  input  wire                         i_axi_wvalid,
  output logic                        o_axi_wready,
  input  wire  [PARA_AXI_DATA_W-1:0]  i_axi_wdata,
  input  wire  [LPARA_AXI_STRB_W-1:0] i_axi_wstrb,
  input  wire                         i_axi_wlast,

  // AXI4 B channel
  output logic                        o_axi_bvalid,
  input  wire                         i_axi_bready,
  output logic [LPARA_AXI_ID_W-1:0]   o_axi_bid,
  output logic [1:0]                  o_axi_bresp,

  // AXI4 AR channel
  input  wire                         i_axi_arvalid,
  output logic                        o_axi_arready,
  input  wire  [LPARA_AXI_ID_W-1:0]   i_axi_arid,
  input  wire  [LPARA_AXI_ADDR_W-1:0] i_axi_araddr,
  input  wire  [LPARA_AXI_LEN_W-1:0]  i_axi_arlen,
  input  wire  [2:0]                  i_axi_arsize,
  input  wire  [1:0]                  i_axi_arburst,

  // AXI4 R channel
  output logic                        o_axi_rvalid,
  input  wire                         i_axi_rready,
  output logic [LPARA_AXI_ID_W-1:0]   o_axi_rid,
  output logic [PARA_AXI_DATA_W-1:0]  o_axi_rdata,
  output logic [1:0]                  o_axi_rresp,
  output logic                        o_axi_rlast,

  // Read segment descriptor to the controller
  output logic                        o_rd_seg_valid,
  input  wire                         i_rd_seg_ready,
  output logic                        o_rd_seg_cs,
  output logic [LPARA_AXI_ADDR_W-1:0] o_rd_seg_addr,
  output logic [LPARA_BYTES_W-1:0]    o_rd_seg_units,
  output logic                        o_rd_seg_wrap,

  // Read data units from the controller (no backpressure, room is reserved)
  input  wire                         i_rd_data_valid,
  input  wire  [LPARA_UNIT_W-1:0]     i_rd_data,

  // Write segment descriptor to the controller
  output logic                        o_wr_seg_valid,
  input  wire                         i_wr_seg_ready,
  output logic                        o_wr_seg_cs,
  output logic [LPARA_AXI_ADDR_W-1:0] o_wr_seg_addr,
  output logic [LPARA_BYTES_W-1:0]    o_wr_seg_units,
  output logic                        o_wr_seg_wrap,

  // Write data units to the controller: the unit at the head, popped by i_wr_data_pop
  output logic [LPARA_UNIT_W-1:0]     o_wr_data,
  output logic [LPARA_UNIT_BYTES-1:0] o_wr_mask,
  input  wire                         i_wr_data_pop,

  // Write segment completion from the controller (one pulse per finished segment)
  input  wire                         i_wr_seg_done,

  // Status, error events and error logs to the register file
  output logic [2:0]                  o_rd_out,
  output logic [2:0]                  o_wr_out,
  output logic                        o_fe_idle,
  output logic                        o_evt_decerr,
  output logic                        o_evt_slverr,
  output logic [15:0]                 o_err_cnt_decerr,
  output logic [15:0]                 o_err_cnt_slverr,
  output logic [LPARA_AXI_ADDR_W-1:0] o_err_ra_addr,
  output logic                        o_err_ri_valid,
  output logic [1:0]                  o_err_ri_resp,
  output logic [LPARA_AXI_ID_W-1:0]   o_err_ri_id,
  output logic [LPARA_AXI_ADDR_W-1:0] o_err_wa_addr,
  output logic                        o_err_wi_valid,
  output logic [1:0]                  o_err_wi_resp,
  output logic [LPARA_AXI_ID_W-1:0]   o_err_wi_id
);

  // ---------------------------------------------------------------------------------------------
  // Internal signal declarations
  // ---------------------------------------------------------------------------------------------

  // Read request queue: payload of four entries and the state bits of the entries.
  logic [LPARA_AXI_ID_W-1:0]   reg_rq_id    [0:3];
  logic [LPARA_AXI_ADDR_W-1:0] reg_rq_addr  [0:3];
  logic [LPARA_AXI_LEN_W-1:0]  reg_rq_len   [0:3];
  logic [2:0]                  reg_rq_size  [0:3];
  logic                        reg_rq_wrap  [0:3];
  logic [1:0]                  reg_rq_rej   [0:3];
  logic [LPARA_AXI_ADDR_W-1:0] reg_rq_lo    [0:3];
  logic [LPARA_AXI_ADDR_W-1:0] reg_rq_hi    [0:3];
  logic [3:0]                  reg_rq_dep   [0:3];
  logic [3:0]                  reg_rq_vld;
  logic [3:0]                  reg_rq_sdone;
  logic [3:0]                  reg_rq_gdone;
  logic [1:0]                  reg_rq_wp;
  logic [1:0]                  reg_rq_sp;
  logic [1:0]                  reg_rq_rp;
  logic [1:0]                  reg_rq_fp;

  // Write request queue: payload and state bits of the four entries.
  logic [LPARA_AXI_ID_W-1:0]   reg_wq_id    [0:3];
  logic [LPARA_AXI_ADDR_W-1:0] reg_wq_addr  [0:3];
  logic [LPARA_AXI_LEN_W-1:0]  reg_wq_len   [0:3];
  logic [2:0]                  reg_wq_size  [0:3];
  logic                        reg_wq_wrap  [0:3];
  logic [1:0]                  reg_wq_rej   [0:3];
  logic [LPARA_AXI_ADDR_W-1:0] reg_wq_lo    [0:3];
  logic [LPARA_AXI_ADDR_W-1:0] reg_wq_hi    [0:3];
  logic [4:0]                  reg_wq_niss  [0:3];
  logic [4:0]                  reg_wq_ncmp  [0:3];
  logic [3:0]                  reg_wq_vld;
  logic [3:0]                  reg_wq_ddone;
  logic [3:0]                  reg_wq_bdone;
  logic [3:0]                  reg_wq_abt;
  logic [1:0]                  reg_wq_wp;
  logic [1:0]                  reg_wq_dp;
  logic [1:0]                  reg_wq_bp;
  logic [1:0]                  reg_wq_fp;

  // Accept-time geometry of the AR and AW requests.
  logic [2:0]                  w_ar_szc;
  logic [11:0]                 w_ar_tot;
  logic                        w_ar_wrap_ok;
  logic [LPARA_AXI_ADDR_W:0]   w_ar_lo33;
  logic [LPARA_AXI_ADDR_W:0]   w_ar_hi33;
  logic [1:0]                  w_ar_rej;
  logic [2:0]                  w_aw_szc;
  logic [11:0]                 w_aw_tot;
  logic                        w_aw_wrap_ok;
  logic [LPARA_AXI_ADDR_W:0]   w_aw_lo33;
  logic [LPARA_AXI_ADDR_W:0]   w_aw_hi33;
  logic [1:0]                  w_aw_rej;
  logic                        w_ar_acc;
  logic                        w_aw_acc;
  logic                        w_rq_full;
  logic                        w_wq_full;
  logic [3:0]                  w_rq_set;
  logic [3:0]                  w_rq_clr;
  logic [3:0]                  w_wq_set;
  logic [3:0]                  w_wq_clr;
  logic                        w_rq_free;
  logic                        w_wq_free;

  // Write queue progress: entries that are complete in the RAM, and the oldest entry that waits
  // for a segment completion.
  logic [3:0]                  w_wq_ok;
  logic [3:0]                  w_wq_ramdone;
  logic [3:0]                  w_wq_abtset;
  logic                        w_cmp_hit;
  logic [1:0]                  w_cmp_idx;

  // Read splitter: state, views of the entry at the split pointer and the segment computation.
  logic                        reg_rs_ld;
  logic                        reg_rs_ph;
  logic                        reg_rs_wseg;
  logic [LPARA_AXI_ADDR_W-1:0] reg_rs_a;
  logic [LPARA_BYTES_W-1:0]    reg_rs_rem;
  logic [LPARA_AXI_ADDR_W-1:0] w_rs_addr;
  logic [LPARA_AXI_LEN_W-1:0]  w_rs_len;
  logic [2:0]                  w_rs_size;
  logic                        w_rs_wrap;
  logic [1:0]                  w_rs_rej;
  logic                        w_rs_ent_ok;
  logic                        w_rs_skip;
  logic [11:0]                 w_rs_tot;
  logic [11:0]                 w_rs_off;
  logic [11:0]                 w_rs_nbm;
  logic                        w_rs_match;
  logic                        w_rs_cs0;
  logic [LPARA_BYTES_W-1:0]    w_rs_n;
  logic                        w_rs_lead;
  logic [LPARA_BYTES_W-1:0]    w_rs_units;
  logic                        w_rs_cs;
  logic [LPARA_AXI_ADDR_W-1:0] w_rs_dev;
  logic                        w_rs_hazard;
  logic                        w_rs_room;
  logic                        w_rs_issue;
  logic                        w_rs_pend_end;
  logic                        w_rs_second;
  logic                        w_rs_sdset;
  logic [LPARA_AXI_ADDR_W-1:0] w_rs_ld_a;
  logic [LPARA_BYTES_W-1:0]    w_rs_ld_rem;

  // Read segment slot, information FIFO of the response generator and read buffer.
  logic                        reg_rd_slot_v;
  logic                        reg_rd_slot_cs;
  logic [LPARA_AXI_ADDR_W-1:0] reg_rd_slot_addr;
  logic [LPARA_BYTES_W-1:0]    reg_rd_slot_units;
  logic                        reg_rd_slot_wrap;
  logic                        reg_if_lead  [0:3];
  logic [LPARA_BYTES_W-1:0]    reg_if_bytes [0:3];
  logic [1:0]                  reg_if_wp;
  logic [1:0]                  reg_if_rp;
  logic [2:0]                  reg_if_cnt;
  logic [LPARA_UNIT_W-1:0]     reg_rd_mem   [0:LPARA_RD_UNITS-1];
  logic [LPARA_RD_PTR_W-1:0]   reg_rd_wptr;
  logic [LPARA_RD_PTR_W-1:0]   reg_rd_rptr;
  logic [LPARA_BYTES_W-1:0]    reg_rd_cnt;
  logic [LPARA_BYTES_W-1:0]    reg_rd_pend;
  logic                        reg_rd_aborted;
  logic                        w_rd_pop;
  logic                        w_rd_flush;
  logic                        w_if_pop;
  logic                        w_if_unpush;

  // Read response generator: state, views of the entry at the response pointer, beat assembly.
  logic                        reg_rg_started;
  logic                        reg_rg_errm;
  logic                        reg_rg_segld;
  logic [LPARA_BYTES_W-1:0]    reg_rg_segrem;
  logic [2:0]                  reg_rg_uoff;
  logic [6:0]                  reg_rg_a7;
  logic [LPARA_AXI_LEN_W-1:0]  reg_rg_beat;
  logic [3:0]                  reg_rg_have;
  logic [PARA_AXI_DATA_W-1:0]  reg_rg_acc;
  logic                        reg_rg_accfull;
  logic                        reg_rg_acclast;
  logic [LPARA_AXI_ID_W-1:0]   reg_rg_accid;
  logic                        reg_r_valid;
  logic [LPARA_AXI_ID_W-1:0]   reg_r_id;
  logic [PARA_AXI_DATA_W-1:0]  reg_r_data;
  logic [1:0]                  reg_r_resp;
  logic                        reg_r_last;
  logic                        w_rg_ent_v;
  logic [LPARA_AXI_ID_W-1:0]   w_rg_id;
  logic [6:0]                  w_rg_addr;
  logic [LPARA_AXI_LEN_W-1:0]  w_rg_len;
  logic [2:0]                  w_rg_size;
  logic                        w_rg_wrap;
  logic [1:0]                  w_rg_rej;
  logic [11:0]                 w_rg_tot;
  logic [3:0]                  w_rg_nb;
  logic [3:0]                  w_rg_nbeat;
  logic [3:0]                  w_rg_pos;
  logic [3:0]                  w_rg_n;
  logic [3:0]                  w_rg_have_nxt;
  logic [LPARA_UNIT_W-1:0]     w_rg_unit;
  logic [PARA_AXI_DATA_W-1:0]  w_rg_merge;
  logic [LPARA_BYTES_W-1:0]    w_rg_segrem_nxt;
  logic [2:0]                  w_rg_uoff_nxt;
  logic                        w_rg_hd_lead;
  logic [LPARA_BYTES_W-1:0]    w_rg_hd_bytes;
  logic                        w_rg_out_free;
  logic                        w_rg_errm;
  logic [1:0]                  w_rg_err_resp;
  logic                        w_rg_copy;
  logic                        w_rg_cmpl;
  logic                        w_rg_errbeat;
  logic                        w_rg_last_beat;
  logic                        w_rg_gen;
  logic                        w_rg_load_out;
  logic                        w_rg_gdset;
  logic [6:0]                  w_rg_a7_nxt;

  // Write data engine: state, views of the entry at the data pointer, segment computation.
  logic                        reg_wg_started;
  logic                        reg_wg_ld;
  logic                        reg_wg_ph;
  logic                        reg_wg_wseg;
  logic                        reg_wg_alldone;
  logic [LPARA_AXI_ADDR_W-1:0] reg_wg_a;
  logic [LPARA_BYTES_W-1:0]    reg_wg_rem;
  logic                        reg_wg_segact;
  logic                        reg_wg_segend;
  logic [LPARA_BYTES_W-1:0]    reg_wg_segrem;
  logic [LPARA_BYTES_W-1:0]    reg_wg_segunits;
  logic [LPARA_AXI_ADDR_W-1:0] reg_wg_segaddr;
  logic                        reg_wg_segcs;
  logic                        reg_wg_segwrap;
  logic [2:0]                  reg_wg_woff;
  logic                        reg_wg_first;
  logic [6:0]                  reg_wg_a7;
  logic [LPARA_AXI_LEN_W-1:0]  reg_wg_abeat;
  logic                        reg_wg_wdone;
  logic                        reg_wg_lastdone;
  logic [3:0]                  reg_wg_have;
  logic                        reg_wb_valid;
  logic                        reg_wb_last;
  logic [PARA_AXI_DATA_W-1:0]  reg_wb_data;
  logic [LPARA_AXI_STRB_W-1:0] reg_wb_strb;
  logic                        w_wd_v;
  logic                        w_wd_drain;
  logic                        w_wd_norm;
  logic [LPARA_AXI_ADDR_W-1:0] w_wd_addr;
  logic [LPARA_AXI_LEN_W-1:0]  w_wd_len;
  logic [2:0]                  w_wd_size;
  logic                        w_wd_wrap;
  logic [11:0]                 w_wd_tot;
  logic [11:0]                 w_wd_off;
  logic [11:0]                 w_wd_nbm;
  logic                        w_wd_match;
  logic [LPARA_AXI_ADDR_W-1:0] w_wd_ld_a;
  logic [LPARA_BYTES_W-1:0]    w_wd_ld_rem;
  logic                        w_wd_cs0;
  logic [LPARA_BYTES_W-1:0]    w_wd_n;
  logic                        w_wd_lead;
  logic [LPARA_BYTES_W-1:0]    w_wd_units;
  logic                        w_wd_cs;
  logic [LPARA_AXI_ADDR_W-1:0] w_wd_dev;
  logic                        w_wd_second;
  logic                        w_wd_load;
  logic                        w_wd_start;
  logic                        w_wd_wacc;
  logic                        w_wd_wlast_now;
  logic                        w_wd_copy;
  logic                        w_wd_open;
  logic                        w_wd_close;
  logic                        w_wd_cmpl;
  logic                        w_wd_push;
  logic                        w_wd_fin;
  logic [3:0]                  w_wd_nb;
  logic [3:0]                  w_wd_nbeat;
  logic [3:0]                  w_wd_pos;
  logic [3:0]                  w_wd_cn;
  logic [3:0]                  w_wd_have_nxt;
  logic [LPARA_BYTES_W-1:0]    w_wd_segrem_nxt;
  logic [2:0]                  w_wd_woff_nxt;
  logic [6:0]                  w_wd_a7_nxt;
  logic [LPARA_UNIT_BYTES-1:0] w_wc_lane_we;
  logic [LPARA_UNIT_W-1:0]     w_wc_lane_data;
  logic [LPARA_UNIT_BYTES-1:0] w_wc_lane_mask;

  // Write buffer, write segment slot and B channel register.
  logic [LPARA_WR_PTR_W-1:0]   reg_wr_wptr;
  logic [LPARA_WR_PTR_W-1:0]   reg_wr_rptr;
  logic [LPARA_BYTES_W-1:0]    reg_wr_cnt;
  logic                        reg_wr_slot_v;
  logic                        reg_wr_slot_cs;
  logic [LPARA_AXI_ADDR_W-1:0] reg_wr_slot_addr;
  logic [LPARA_BYTES_W-1:0]    reg_wr_slot_units;
  logic                        reg_wr_slot_wrap;
  logic                        reg_b_valid;
  logic [LPARA_AXI_ID_W-1:0]   reg_b_id;
  logic [1:0]                  reg_b_resp;
  logic                        w_b_load;
  logic [1:0]                  w_b_resp_nxt;

  // Error counters, logs and event pulses.
  logic [15:0]                 reg_cnt_decerr;
  logic [15:0]                 reg_cnt_slverr;
  logic [LPARA_AXI_ADDR_W-1:0] reg_ra_addr;
  logic                        reg_ri_valid;
  logic [1:0]                  reg_ri_resp;
  logic [LPARA_AXI_ID_W-1:0]   reg_ri_id;
  logic [LPARA_AXI_ADDR_W-1:0] reg_wa_addr;
  logic                        reg_wi_valid;
  logic [1:0]                  reg_wi_resp;
  logic [LPARA_AXI_ID_W-1:0]   reg_wi_id;
  logic                        reg_evt_decerr;
  logic                        reg_evt_slverr;

  // ---------------------------------------------------------------------------------------------
  // Functions (shared by the read and the write side, so that both sides split alike)
  // ---------------------------------------------------------------------------------------------

  // f_size_clip: AxSIZE limited to the width of the data bus (a larger size is not legal AXI).
  function automatic logic [2:0] f_size_clip(input logic [2:0] a_size);
    if (32'(a_size) > LPARA_BUS_LOG2)
      f_size_clip = 3'(LPARA_BUS_LOG2);
    else
      f_size_clip = a_size;
  endfunction

  // f_lo33: lowest byte of the request. A wrapped burst starts at its wrap boundary.
  function automatic logic [32:0] f_lo33(input logic [31:0] a_addr, input logic [11:0] a_tot,
                                         input logic a_wrap);
    if (a_wrap)
      f_lo33 = {1'b0, a_addr} & ~(33'(a_tot) - 33'd1);
    else
      f_lo33 = {1'b0, a_addr};
  endfunction

  // f_hi33: highest byte of the request. The first beat of an INCR burst may be unaligned, so the
  // burst ends at the aligned start plus the total size.
  function automatic logic [32:0] f_hi33(input logic [31:0] a_addr, input logic [11:0] a_tot,
                                         input logic [2:0] a_size, input logic a_wrap);
    logic [32:0] nbm;
    nbm = (33'd1 << a_size) - 33'd1;
    if (a_wrap)
      f_hi33 = ({1'b0, a_addr} & ~(33'(a_tot) - 33'd1)) + 33'(a_tot) - 33'd1;
    else
      f_hi33 = ({1'b0, a_addr} & ~nbm) + 33'(a_tot) - 33'd1;
  endfunction

  // f_seg_bytes: size of the next segment, the smallest of the bytes left in the piece, the bytes
  // left in the device page, the bytes left in the chip select and the buffer limit. A wrapped
  // segment is never cut (its size is at most 128 bytes).
  function automatic logic [11:0] f_seg_bytes(input logic [31:0] a_addr,
                                              input logic [11:0] a_rem,
                                              input logic        a_wseg,
                                              input logic [31:0] a_max);
    logic [31:0] page_rem;
    logic [31:0] cs_rem;
    logic [31:0] n_seg;
    page_rem = PARA_PAGE_BYTES - (a_addr & (PARA_PAGE_BYTES - 32'd1));
    cs_rem   = 32'hFFFF_FFFF;
    if ((PARA_NUM_CS == LPARA_TWO_CS) && (a_addr < PARA_MEM_SIZE_BYTES))
      cs_rem = PARA_MEM_SIZE_BYTES - a_addr;
    n_seg = {20'd0, a_rem};
    if (page_rem < n_seg) begin
      n_seg = page_rem;
    end
    if (cs_rem < n_seg) begin
      n_seg = cs_rem;
    end
    if (a_max < n_seg) begin
      n_seg = a_max;
    end
    if (a_wseg) begin
      n_seg = {20'd0, a_rem};
    end
    f_seg_bytes = n_seg[11:0];
  endfunction

  // f_blen_bytes: bytes of the wrap group selected by the CR0 burst length code of a device.
  function automatic logic [11:0] f_blen_bytes(input logic [1:0] a_code);
    case (a_code)
      2'b00: begin
        f_blen_bytes = 12'(LPARA_BLEN_128);
      end
      2'b01: begin
        f_blen_bytes = 12'(LPARA_BLEN_64);
      end
      2'b10: begin
        f_blen_bytes = 12'(LPARA_BLEN_16);
      end
      default: begin
        f_blen_bytes = 12'(LPARA_BLEN_32);
      end
    endcase
  endfunction

  // f_a7_nxt: low seven address bits of the next beat. The next beat starts at the next aligned
  // address; a wrapped burst keeps the bits above its wrap size.
  function automatic logic [6:0] f_a7_nxt(input logic [6:0] a_a7, input logic [2:0] a_size,
                                          input logic a_wrap, input logic [6:0] a_tot);
    logic [6:0] nb7;
    logic [6:0] base;
    logic [6:0] msk;
    nb7  = 7'd1 << a_size;
    base = (a_a7 & ~(nb7 - 7'd1)) + nb7;
    msk  = a_tot - 7'd1;
    if (a_wrap)
      f_a7_nxt = (a_a7 & ~msk) | (base & msk);
    else
      f_a7_nxt = base;
  endfunction

  // ---------------------------------------------------------------------------------------------
  // AR channel: geometry, aperture check and queue payload
  // ---------------------------------------------------------------------------------------------

  // Geometry of the AR request: clipped size, total bytes, legal wrap length, byte range and the
  // response code of a rejected request (DECERR has priority over SLVERR, REQ-IF-002).
  always_comb begin : p_com_ar_geo
    w_ar_szc     = f_size_clip(i_axi_arsize);
    w_ar_tot     = (12'(i_axi_arlen) + 12'd1) << w_ar_szc;
    w_ar_wrap_ok = (32'(i_axi_arburst) == LPARA_BURST_WRAP) &&
                   ((32'(i_axi_arlen) == LPARA_WLEN_2) || (32'(i_axi_arlen) == LPARA_WLEN_4) ||
                    (32'(i_axi_arlen) == LPARA_WLEN_8) || (32'(i_axi_arlen) == LPARA_WLEN_16));
    w_ar_lo33    = f_lo33(i_axi_araddr, w_ar_tot, w_ar_wrap_ok);
    w_ar_hi33    = f_hi33(i_axi_araddr, w_ar_tot, w_ar_szc, w_ar_wrap_ok);
    w_ar_rej     = 2'(LPARA_RESP_OKAY);
    if ((32'(i_axi_arburst) != LPARA_BURST_INCR) && (32'(i_axi_arburst) != LPARA_BURST_WRAP))
      w_ar_rej = 2'(LPARA_RESP_SLVERR);
    if (w_ar_hi33 >= 33'(PARA_NUM_CS * PARA_MEM_SIZE_BYTES))
      w_ar_rej = 2'(LPARA_RESP_DECERR);
  end

  // Handshake of the AR channel: a request is taken when the queue has a free entry, the
  // controller accepts requests and no abort is being drained.
  assign w_rq_full     = &reg_rq_vld;
  assign o_axi_arready = i_accept_en & ~reg_rd_aborted & ~w_rq_full;
  assign w_ar_acc      = i_axi_arvalid & o_axi_arready;

  // Read queue payload: written when a request is accepted. The entries are resetless payload,
  // read only while their valid bit is 1 (SEQ-04).
  always_ff @(posedge i_clk_core) begin : p_ff_rq_payload
    if (w_ar_acc) begin
      reg_rq_id[reg_rq_wp]   <= i_axi_arid;
      reg_rq_addr[reg_rq_wp] <= i_axi_araddr;
      reg_rq_len[reg_rq_wp]  <= i_axi_arlen;
      reg_rq_size[reg_rq_wp] <= w_ar_szc;
      reg_rq_wrap[reg_rq_wp] <= w_ar_wrap_ok;
      reg_rq_rej[reg_rq_wp]  <= w_ar_rej;
      reg_rq_lo[reg_rq_wp]   <= w_ar_lo33[LPARA_AXI_ADDR_W-1:0];
      reg_rq_hi[reg_rq_wp]   <= w_ar_hi33[LPARA_AXI_ADDR_W-1:0];
    end
  end

  // ---------------------------------------------------------------------------------------------
  // AW channel: geometry, aperture check and queue payload
  // ---------------------------------------------------------------------------------------------

  // Geometry of the AW request, same rules as the AR request.
  always_comb begin : p_com_aw_geo
    w_aw_szc     = f_size_clip(i_axi_awsize);
    w_aw_tot     = (12'(i_axi_awlen) + 12'd1) << w_aw_szc;
    w_aw_wrap_ok = (32'(i_axi_awburst) == LPARA_BURST_WRAP) &&
                   ((32'(i_axi_awlen) == LPARA_WLEN_2) || (32'(i_axi_awlen) == LPARA_WLEN_4) ||
                    (32'(i_axi_awlen) == LPARA_WLEN_8) || (32'(i_axi_awlen) == LPARA_WLEN_16));
    w_aw_lo33    = f_lo33(i_axi_awaddr, w_aw_tot, w_aw_wrap_ok);
    w_aw_hi33    = f_hi33(i_axi_awaddr, w_aw_tot, w_aw_szc, w_aw_wrap_ok);
    w_aw_rej     = 2'(LPARA_RESP_OKAY);
    if ((32'(i_axi_awburst) != LPARA_BURST_INCR) && (32'(i_axi_awburst) != LPARA_BURST_WRAP))
      w_aw_rej = 2'(LPARA_RESP_SLVERR);
    if (w_aw_hi33 >= 33'(PARA_NUM_CS * PARA_MEM_SIZE_BYTES))
      w_aw_rej = 2'(LPARA_RESP_DECERR);
  end

  // Handshake of the AW channel.
  assign w_wq_full     = &reg_wq_vld;
  assign o_axi_awready = i_accept_en & ~w_wq_full;
  assign w_aw_acc      = i_axi_awvalid & o_axi_awready;

  // Write queue payload.
  always_ff @(posedge i_clk_core) begin : p_ff_wq_payload
    if (w_aw_acc) begin
      reg_wq_id[reg_wq_wp]   <= i_axi_awid;
      reg_wq_addr[reg_wq_wp] <= i_axi_awaddr;
      reg_wq_len[reg_wq_wp]  <= i_axi_awlen;
      reg_wq_size[reg_wq_wp] <= w_aw_szc;
      reg_wq_wrap[reg_wq_wp] <= w_aw_wrap_ok;
      reg_wq_rej[reg_wq_wp]  <= w_aw_rej;
      reg_wq_lo[reg_wq_wp]   <= w_aw_lo33[LPARA_AXI_ADDR_W-1:0];
      reg_wq_hi[reg_wq_wp]   <= w_aw_hi33[LPARA_AXI_ADDR_W-1:0];
    end
  end

  // ---------------------------------------------------------------------------------------------
  // Read request queue control
  // ---------------------------------------------------------------------------------------------

  // One-hot masks: the entry that is allocated by an accepted AR request and the entry that is
  // freed by the last R beat that the manager accepts.
  assign w_rq_set  = w_ar_acc ? (4'b0001 << reg_rq_wp) : 4'b0000;
  assign w_rq_free = reg_r_valid & i_axi_rready & reg_r_last;
  assign w_rq_clr  = w_rq_free ? (4'b0001 << reg_rq_fp) : 4'b0000;

  // Queue state: valid bits and the progress bits of the splitter (sdone) and of the response
  // generator (gdone); a new entry starts with both progress bits clear.
  always_ff @(posedge i_clk_core, negedge i_rst_n_core) begin : p_ff_rq_ctrl
    if (!i_rst_n_core) begin
      reg_rq_vld   <= 4'b0000;
      reg_rq_sdone <= 4'b0000;
      reg_rq_gdone <= 4'b0000;
      reg_rq_wp    <= 2'd0;
      reg_rq_fp    <= 2'd0;
    end else begin
      reg_rq_vld   <= (reg_rq_vld | w_rq_set) & ~w_rq_clr;
      reg_rq_sdone <= (reg_rq_sdone | (w_rs_sdset ? (4'b0001 << reg_rq_sp) : 4'b0000)) &
                      ~w_rq_set;
      reg_rq_gdone <= (reg_rq_gdone | (w_rg_gdset ? (4'b0001 << reg_rq_rp) : 4'b0000)) &
                      ~w_rq_set;
      reg_rq_wp    <= reg_rq_wp + 2'(w_ar_acc);
      reg_rq_fp    <= reg_rq_fp + 2'(w_rq_free);
    end
  end

  // Dependency mask of each read entry: the write entries that were valid when the read was
  // accepted. A bit clears when its write entry is freed (REQ-FUNC-003).
  for (genvar gen_i = 0; gen_i < 4; gen_i++) begin : gen_rq_dep
    // Dependency mask of entry gen_i: set at the accept, cleared as write entries are freed.
    always_ff @(posedge i_clk_core, negedge i_rst_n_core) begin : p_ff_rq_dep
      if (!i_rst_n_core)
        reg_rq_dep[gen_i] <= 4'b0000;
      else if (w_ar_acc && (reg_rq_wp == 2'(gen_i)))
        reg_rq_dep[gen_i] <= reg_wq_vld & ~w_wq_clr;
      else
        reg_rq_dep[gen_i] <= reg_rq_dep[gen_i] & ~w_wq_clr;
    end
  end

  // ---------------------------------------------------------------------------------------------
  // Read splitter: cuts every accepted read into segments and issues them one at a time
  // ---------------------------------------------------------------------------------------------

  // Views of the entry at the split pointer, its geometry and the wrap match with the device.
  always_comb begin : p_com_rs_view
    w_rs_addr   = reg_rq_addr[reg_rq_sp];
    w_rs_len    = reg_rq_len[reg_rq_sp];
    w_rs_size   = reg_rq_size[reg_rq_sp];
    w_rs_wrap   = reg_rq_wrap[reg_rq_sp];
    w_rs_rej    = reg_rq_rej[reg_rq_sp];
    w_rs_ent_ok = reg_rq_vld[reg_rq_sp] & ~reg_rq_sdone[reg_rq_sp];
    w_rs_skip   = w_rs_ent_ok & ((w_rs_rej != 2'd0) | reg_rd_aborted);
    w_rs_tot    = (12'(w_rs_len) + 12'd1) << w_rs_size;
    w_rs_nbm    = (12'd1 << w_rs_size) - 12'd1;
    w_rs_off    = 12'(w_rs_addr) & (w_rs_tot - 12'd1);
    w_rs_cs0    = ~((PARA_NUM_CS == LPARA_TWO_CS) && (w_rs_addr >= PARA_MEM_SIZE_BYTES));
    w_rs_match  = w_rs_wrap && (w_rs_tot == f_blen_bytes(w_rs_cs0 ? i_blen_cs0 : i_blen_cs1));
  end

  // Piece to load: a matching wrap is one wrapped segment, a non-matching wrap is two linear
  // pieces (start to the end of the region, then the region start to the byte before the start,
  // ASM-006), and an INCR burst is one linear piece. {wrap, match, second piece} selects it.
  always_comb begin : p_com_rs_load
    w_rs_ld_a   = w_rs_addr;
    w_rs_ld_rem = w_rs_tot - (12'(w_rs_addr) & w_rs_nbm);
    casez ({w_rs_wrap, w_rs_match, reg_rs_ph})
      3'b11?: begin
        w_rs_ld_a   = w_rs_addr;
        w_rs_ld_rem = w_rs_tot;
      end
      3'b100: begin
        w_rs_ld_a   = w_rs_addr;
        w_rs_ld_rem = w_rs_tot - w_rs_off;
      end
      3'b101: begin
        w_rs_ld_a   = w_rs_addr & ~(32'(w_rs_tot) - 32'd1);
        w_rs_ld_rem = w_rs_off;
      end
      default: begin
        w_rs_ld_a   = w_rs_addr;
        w_rs_ld_rem = w_rs_tot - (12'(w_rs_addr) & w_rs_nbm);
      end
    endcase
  end

  // The segment under computation: size, the lead pad byte of an odd start, the number of memory
  // units, the chip select and the device byte address.
  always_comb begin : p_com_rs_seg
    w_rs_n     = f_seg_bytes(reg_rs_a, reg_rs_rem, reg_rs_wseg, LPARA_MAXSEG_RD);
    w_rs_lead  = reg_rs_a[0];
    w_rs_units = (12'(w_rs_lead) + w_rs_n + 12'(LPARA_UNIT_BYTES - 32'd1)) >> LPARA_UNIT_LOG2;
    w_rs_cs    = (PARA_NUM_CS == LPARA_TWO_CS) && (reg_rs_a >= PARA_MEM_SIZE_BYTES);
    w_rs_dev   = w_rs_cs ? (reg_rs_a - PARA_MEM_SIZE_BYTES) : reg_rs_a;
  end

  // Read after write hazard: an older write that is not yet in the RAM and overlaps the byte
  // range of the read blocks the issue.
  always_comb begin : p_com_rs_hazard
    w_rs_hazard = 1'b0;
    for (int idx = 0; idx < 4; idx++) begin
      if (reg_rq_dep[reg_rq_sp][idx] && reg_wq_vld[idx] && !w_wq_ramdone[idx] &&
          (reg_wq_rej[idx] == 2'd0) &&
          !(reg_rq_hi[reg_rq_sp] < reg_wq_lo[idx]) && !(reg_wq_hi[idx] < reg_rq_lo[reg_rq_sp]))
        w_rs_hazard = 1'b1;
    end
  end

  // Issue condition: a piece is loaded, the slot and the information FIFO have room, the read
  // buffer has room for every unit of the segment (reservation, DEC-044) and no hazard.
  assign w_rs_room     = ((LPARA_RD_UNITS - 32'(reg_rd_cnt) - 32'(reg_rd_pend)) >=
                          32'(w_rs_units));
  // Issue condition of the segment (all conditions of the comment above).
  assign w_rs_issue    = reg_rs_ld & w_rs_ent_ok & ~w_rs_skip & ~reg_rd_slot_v &
                         (32'(reg_if_cnt) != LPARA_IF_DEPTH) & w_rs_room & ~w_rs_hazard & ~i_abort &
                         ~reg_rd_aborted;
  // End of the piece, the second piece of a split wrap, and the end of the entry.
  assign w_rs_pend_end = (w_rs_n == reg_rs_rem);
  assign w_rs_second   = w_rs_wrap & ~reg_rs_wseg & ~reg_rs_ph & (w_rs_off != 12'd0);
  assign w_rs_sdset    = w_rs_skip | (w_rs_issue & w_rs_pend_end & ~w_rs_second);

  // Splitter state: loads the next piece, issues segments and advances to the next entry.
  always_ff @(posedge i_clk_core, negedge i_rst_n_core) begin : p_ff_rs
    if (!i_rst_n_core) begin
      reg_rs_ld   <= 1'b0;
      reg_rs_ph   <= 1'b0;
      reg_rs_wseg <= 1'b0;
      reg_rs_a    <= '0;
      reg_rs_rem  <= '0;
      reg_rq_sp   <= 2'd0;
    end else begin
      // Priority: abort, skip of an entry without segments, piece load, segment issue.
      casez ({i_abort, w_rs_skip, (w_rs_ent_ok & ~reg_rs_ld), w_rs_issue})
        4'b1???: begin
          reg_rs_ld <= 1'b0;
          reg_rs_ph <= 1'b0;
        end
        4'b01??: begin
          reg_rs_ld <= 1'b0;
          reg_rs_ph <= 1'b0;
          reg_rq_sp <= reg_rq_sp + 2'd1;
        end
        4'b001?: begin
          reg_rs_ld   <= 1'b1;
          reg_rs_wseg <= w_rs_match;
          reg_rs_a    <= w_rs_ld_a;
          reg_rs_rem  <= w_rs_ld_rem;
        end
        4'b0001: begin
          if (w_rs_pend_end) begin
            reg_rs_ld <= 1'b0;
            if (w_rs_second) begin
              reg_rs_ph <= 1'b1;
            end else begin
              reg_rs_ph <= 1'b0;
              reg_rq_sp <= reg_rq_sp + 2'd1;
            end
          end else begin
            reg_rs_a   <= reg_rs_a + 32'(w_rs_n);
            reg_rs_rem <= reg_rs_rem - w_rs_n;
          end
        end
        default: begin
          // No change.
        end
      endcase
    end
  end

  // ---------------------------------------------------------------------------------------------
  // Read segment slot, information FIFO and read buffer
  // ---------------------------------------------------------------------------------------------

  // Slot valid bit: set by an issue, cleared when the controller takes the descriptor or by an
  // abort (the descriptor is withdrawn).
  always_ff @(posedge i_clk_core, negedge i_rst_n_core) begin : p_ff_rd_slot_v
    if (!i_rst_n_core) begin
      reg_rd_slot_v <= 1'b0;
    end else begin
      casez ({i_abort, w_rs_issue, i_rd_seg_ready})
        3'b1??: begin
          reg_rd_slot_v <= 1'b0;
        end
        3'b01?: begin
          reg_rd_slot_v <= 1'b1;
        end
        3'b001: begin
          reg_rd_slot_v <= 1'b0;
        end
        default: begin
          // No change.
        end
      endcase
    end
  end

  // Slot payload, loaded at the issue; the controller reads it while the valid bit is 1.
  always_ff @(posedge i_clk_core) begin : p_ff_rd_slot_pl
    if (w_rs_issue) begin
      reg_rd_slot_cs    <= w_rs_cs;
      reg_rd_slot_addr  <= w_rs_dev & ~32'd1;
      reg_rd_slot_units <= w_rs_units;
      reg_rd_slot_wrap  <= reg_rs_wseg;
    end
  end

  // Descriptor outputs.
  assign o_rd_seg_valid = reg_rd_slot_v;
  assign o_rd_seg_cs    = reg_rd_slot_cs;
  assign o_rd_seg_addr  = reg_rd_slot_addr;
  assign o_rd_seg_units = reg_rd_slot_units;
  assign o_rd_seg_wrap  = reg_rd_slot_wrap;

  // A descriptor that the controller has not taken when the abort comes is withdrawn together
  // with its entry of the information FIFO.
  assign w_if_unpush = i_abort & reg_rd_slot_v & ~i_rd_seg_ready;

  // Information FIFO payload: lead pad flag and byte count of every issued read segment.
  always_ff @(posedge i_clk_core) begin : p_ff_if_pl
    if (w_rs_issue) begin
      reg_if_lead[reg_if_wp]  <= w_rs_lead;
      reg_if_bytes[reg_if_wp] <= w_rs_n;
    end
  end

  // Information FIFO pointers. The FIFO is emptied together with the read buffer when an abort
  // has been drained (w_rd_flush).
  always_ff @(posedge i_clk_core, negedge i_rst_n_core) begin : p_ff_if_ptr
    if (!i_rst_n_core) begin
      reg_if_wp  <= 2'd0;
      reg_if_rp  <= 2'd0;
      reg_if_cnt <= 3'd0;
    end else if (w_rd_flush) begin
      reg_if_wp  <= 2'd0;
      reg_if_rp  <= 2'd0;
      reg_if_cnt <= 3'd0;
    end else begin
      if (w_rs_issue)
        reg_if_wp <= reg_if_wp + 2'd1;
      else if (w_if_unpush)
        reg_if_wp <= reg_if_wp - 2'd1;
      if (w_if_pop)
        reg_if_rp <= reg_if_rp + 2'd1;
      reg_if_cnt <= reg_if_cnt + 3'(w_rs_issue) - 3'(w_if_pop) - 3'(w_if_unpush);
    end
  end

  // Read buffer storage: one memory unit per write; room was reserved at the issue.
  always_ff @(posedge i_clk_core) begin : p_ff_rd_mem
    if (i_rd_data_valid)
      reg_rd_mem[reg_rd_wptr] <= i_rd_data;
  end

  // An abort is drained when every queued read has been answered; then the buffer, the FIFO and
  // the response generator restart from empty.
  assign w_rd_flush = reg_rd_aborted & ~(|reg_rq_vld);

  // Read buffer pointers, fill count, reserved count and the abort flag. The reserved count
  // (pend) is the number of units of issued segments that have not arrived yet.
  always_ff @(posedge i_clk_core, negedge i_rst_n_core) begin : p_ff_rd_buf
    if (!i_rst_n_core) begin
      reg_rd_wptr    <= '0;
      reg_rd_rptr    <= '0;
      reg_rd_cnt     <= '0;
      reg_rd_pend    <= '0;
      reg_rd_aborted <= 1'b0;
    end else begin
      if (i_abort)
        reg_rd_aborted <= 1'b1;
      else if (w_rd_flush)
        reg_rd_aborted <= 1'b0;
      if (w_rd_flush) begin
        reg_rd_wptr <= '0;
        reg_rd_rptr <= '0;
        reg_rd_cnt  <= '0;
      end else begin
        if (i_rd_data_valid)
          reg_rd_wptr <= reg_rd_wptr + 1'b1;
        if (w_rd_pop)
          reg_rd_rptr <= reg_rd_rptr + 1'b1;
        reg_rd_cnt <= reg_rd_cnt + LPARA_BYTES_W'(i_rd_data_valid) - LPARA_BYTES_W'(w_rd_pop);
      end
      if (i_abort || w_rd_flush)
        reg_rd_pend <= '0;
      else
        reg_rd_pend <= reg_rd_pend + (w_rs_issue ? w_rs_units : '0) -
                       LPARA_BYTES_W'(i_rd_data_valid && (reg_rd_pend != '0));
    end
  end

  // ---------------------------------------------------------------------------------------------
  // Read response generator: turns the byte stream of the buffer into R beats in request order
  // ---------------------------------------------------------------------------------------------

  // Views of the entry at the response pointer and the geometry of the current beat.
  always_comb begin : p_com_rg_view
    w_rg_ent_v     = reg_rq_vld[reg_rq_rp] & ~reg_rq_gdone[reg_rq_rp];
    w_rg_id        = reg_rq_id[reg_rq_rp];
    w_rg_addr      = reg_rq_addr[reg_rq_rp][6:0];
    w_rg_len       = reg_rq_len[reg_rq_rp];
    w_rg_size      = reg_rq_size[reg_rq_rp];
    w_rg_wrap      = reg_rq_wrap[reg_rq_rp];
    w_rg_rej       = reg_rq_rej[reg_rq_rp];
    w_rg_tot       = (12'(w_rg_len) + 12'd1) << w_rg_size;
    w_rg_nb        = 4'd1 << w_rg_size;
    w_rg_nbeat     = w_rg_nb - (4'(reg_rg_a7) & (w_rg_nb - 4'd1));
    w_rg_pos       = 4'(reg_rg_a7 & 7'(LPARA_AXI_STRB_W - 32'd1)) + reg_rg_have;
    w_rg_unit      = reg_rd_mem[reg_rd_rptr];
    w_rg_hd_lead   = reg_if_lead[reg_if_rp];
    w_rg_hd_bytes  = reg_if_bytes[reg_if_rp];
    w_rg_out_free  = ~reg_r_valid | i_axi_rready;
    w_rg_last_beat = (reg_rg_beat == w_rg_len);
    w_rg_a7_nxt    = f_a7_nxt(reg_rg_a7, w_rg_size, w_rg_wrap, w_rg_tot[6:0]);
  end

  // Error mode of the entry: a rejected request, an entry after an abort that has no more data
  // in the buffer, or an entry that is already in error mode. The response is the rejection code
  // or SLVERR.
  assign w_rg_errm     = reg_rg_errm | (w_rg_rej != 2'd0) |
                         (reg_rd_aborted & (reg_rd_cnt == '0) &
                          (reg_rg_segld | (reg_if_cnt == 3'd0)));
  // Response of an error beat.
  assign w_rg_err_resp = (w_rg_rej != 2'd0) ? w_rg_rej : 2'(LPARA_RESP_SLVERR);

  // Copy step: bytes taken from the head unit into the beat, the smallest of the bytes the beat
  // still needs, the bytes the segment still has and the bytes the unit still has.
  always_comb begin : p_com_rg_copy
    w_rg_n = w_rg_nbeat - reg_rg_have;
    if (reg_rg_segrem < 12'(w_rg_n))
      w_rg_n = 4'(reg_rg_segrem);
    if ((4'(LPARA_UNIT_BYTES) - 4'(reg_rg_uoff)) < w_rg_n)
      w_rg_n = 4'(LPARA_UNIT_BYTES) - 4'(reg_rg_uoff);
    w_rg_copy = w_rg_ent_v & reg_rg_started & ~w_rg_errm & ~reg_rg_accfull & reg_rg_segld &
                (reg_rd_cnt != '0);
    w_rg_have_nxt   = reg_rg_have + w_rg_n;
    w_rg_segrem_nxt = reg_rg_segrem - 12'(w_rg_n);
    w_rg_uoff_nxt   = reg_rg_uoff + 3'(w_rg_n);
    w_rg_merge      = reg_rg_acc;
    for (int lane = 0; lane < LPARA_MAX_BUS_B; lane++) begin
      if (32'(lane) < LPARA_AXI_STRB_W) begin
        if ((4'(lane) >= w_rg_pos) && (4'(lane) < (w_rg_pos + w_rg_n)))
          w_rg_merge[LPARA_BYTE_W*lane +: LPARA_BYTE_W] =
            LPARA_BYTE_W'(w_rg_unit >> {(4'(reg_rg_uoff) + 4'(lane) - w_rg_pos) &
                             4'(LPARA_UNIT_BYTES - 32'd1), 3'b000});
      end
    end
  end

  // Beat completion and unit pop. The unit leaves the buffer when it is used up or when the
  // segment ends (the rest of the unit is padding); the information entry leaves with the segment.
  assign w_rg_cmpl    = w_rg_copy & (w_rg_have_nxt == w_rg_nbeat);
  assign w_rd_pop     = w_rg_copy & ((32'(w_rg_uoff_nxt) == LPARA_UNIT_BYTES) ||
                                     (w_rg_segrem_nxt == 12'd0));
  // The information entry leaves with its segment.
  assign w_if_pop     = w_rg_copy & (w_rg_segrem_nxt == 12'd0);
  // An error beat, a generated beat and the end of the entry.
  assign w_rg_errbeat = w_rg_ent_v & reg_rg_started & w_rg_errm & ~reg_rg_accfull &
                        w_rg_out_free;
  // A beat is generated by a completed copy or an error beat; the last one ends the entry.
  assign w_rg_gen     = w_rg_cmpl | w_rg_errbeat;
  assign w_rg_gdset   = w_rg_gen & w_rg_last_beat;

  // The beat register is loaded from the holding register first, otherwise from a beat that is
  // generated in this cycle.
  assign w_rg_load_out = w_rg_out_free & (reg_rg_accfull | w_rg_gen);

  // Generator state: entry start, segment load, copy, beat generation and entry end.
  always_ff @(posedge i_clk_core, negedge i_rst_n_core) begin : p_ff_rg
    if (!i_rst_n_core) begin
      reg_rg_started <= 1'b0;
      reg_rg_errm    <= 1'b0;
      reg_rg_segld   <= 1'b0;
      reg_rg_segrem  <= '0;
      reg_rg_uoff    <= 3'd0;
      reg_rg_a7      <= 7'd0;
      reg_rg_beat    <= '0;
      reg_rg_have    <= 4'd0;
      reg_rg_accfull <= 1'b0;
      reg_rg_acclast <= 1'b0;
      reg_rq_rp      <= 2'd0;
    end else if (w_rd_flush) begin
      reg_rg_started <= 1'b0;
      reg_rg_errm    <= 1'b0;
      reg_rg_segld   <= 1'b0;
      reg_rg_have    <= 4'd0;
      reg_rg_accfull <= 1'b0;
    end else begin
      // Entry start: initialise the beat state once the holding register is free.
      if (w_rg_ent_v && !reg_rg_started && !reg_rg_accfull) begin
        reg_rg_started <= 1'b1;
        reg_rg_a7      <= w_rg_addr;
        reg_rg_beat    <= '0;
        reg_rg_have    <= 4'd0;
      end
      // Error mode is sticky until the entry ends.
      if (w_rg_errm && reg_rg_started)
        reg_rg_errm <= 1'b1;
      // Segment load from the head of the information FIFO.
      if (w_rg_ent_v && reg_rg_started && !reg_rg_segld && (reg_if_cnt != 3'd0) &&
          (w_rg_rej == 2'd0) && !reg_rg_errm) begin
        reg_rg_segld  <= 1'b1;
        reg_rg_segrem <= w_rg_hd_bytes;
        reg_rg_uoff   <= 3'(w_rg_hd_lead);
      end
      // Copy of bytes into the beat.
      if (w_rg_copy) begin
        reg_rg_have   <= w_rg_have_nxt;
        reg_rg_segrem <= w_rg_segrem_nxt;
        reg_rg_uoff   <= (w_rd_pop) ? 3'd0 : w_rg_uoff_nxt;
        if (w_rg_segrem_nxt == 12'd0)
          reg_rg_segld <= 1'b0;
      end
      // Holding register: filled when a beat completes and the beat register is busy, emptied
      // when the beat register takes it.
      if (reg_rg_accfull && w_rg_out_free)
        reg_rg_accfull <= 1'b0;
      else if (w_rg_cmpl && !w_rg_out_free) begin
        reg_rg_accfull <= 1'b1;
        reg_rg_acclast <= w_rg_last_beat;
      end
      // A generated beat: next beat of the entry, or the end of the entry.
      if (w_rg_gen) begin
        reg_rg_have <= 4'd0;
        reg_rg_a7   <= w_rg_a7_nxt;
        if (w_rg_last_beat) begin
          reg_rg_beat    <= '0;
          reg_rg_started <= 1'b0;
          reg_rg_errm    <= 1'b0;
          reg_rg_segld   <= 1'b0;
          reg_rq_rp      <= reg_rq_rp + 2'd1;
        end else begin
          reg_rg_beat <= reg_rg_beat + 8'd1;
        end
      end
    end
  end

  // Beat data: the holding register and the beat register are resetless payload that is used
  // only with its valid bit.
  always_ff @(posedge i_clk_core) begin : p_ff_rg_data
    // Priority: keep the merged beat while it is still needed, clear it once it is delivered.
    casez ({(w_rg_copy & ~(w_rg_cmpl & w_rg_out_free)),
            (w_rg_gen | (reg_rg_accfull & w_rg_out_free))})
      2'b1?: begin
        reg_rg_acc <= w_rg_merge;
      end
      2'b01: begin
        reg_rg_acc <= '0;
      end
      default: begin
        // No change.
      end
    endcase
    if (w_rg_load_out) begin
      reg_r_data <= reg_rg_accfull ? reg_rg_acc : (w_rg_errbeat ? '0 : w_rg_merge);
      reg_r_last <= reg_rg_accfull ? reg_rg_acclast : w_rg_last_beat;
      reg_r_resp <= (!reg_rg_accfull && w_rg_errbeat) ? w_rg_err_resp : 2'(LPARA_RESP_OKAY);
    end
  end

  // Identifier of the held beat and of the beat register.
  always_ff @(posedge i_clk_core) begin : p_ff_rg_id
    if (w_rg_cmpl && !w_rg_out_free)
      reg_rg_accid <= w_rg_id;
    if (w_rg_load_out)
      reg_r_id <= reg_rg_accfull ? reg_rg_accid : w_rg_id;
  end

  // Beat register valid bit: set when loaded, cleared when the manager takes the beat.
  always_ff @(posedge i_clk_core, negedge i_rst_n_core) begin : p_ff_r_valid
    if (!i_rst_n_core)
      reg_r_valid <= 1'b0;
    else if (w_rg_load_out)
      reg_r_valid <= 1'b1;
    else if (i_axi_rready)
      reg_r_valid <= 1'b0;
  end

  // R channel outputs.
  assign o_axi_rvalid = reg_r_valid;
  assign o_axi_rid    = reg_r_id;
  assign o_axi_rdata  = reg_r_data;
  assign o_axi_rresp  = reg_r_resp;
  assign o_axi_rlast  = reg_r_last;

  // ---------------------------------------------------------------------------------------------
  // Write request queue control
  // ---------------------------------------------------------------------------------------------

  // A write is complete in the RAM when all its data are buffered and every issued segment is
  // done, or when it was aborted. This status releases the reads that wait for it.
  always_comb begin : p_com_wq_sts
    w_wq_ok      = 4'b0000;
    w_wq_ramdone = 4'b0000;
    w_wq_abtset  = 4'b0000;
    for (int idx = 0; idx < 4; idx++) begin
      w_wq_ok[idx]      = reg_wq_ddone[idx] && (reg_wq_niss[idx] == reg_wq_ncmp[idx]);
      w_wq_ramdone[idx] = reg_wq_abt[idx] || w_wq_ok[idx];
      w_wq_abtset[idx]  = i_abort && reg_wq_vld[idx] && !w_wq_ok[idx];
    end
  end

  // Owner of the next segment completion: the oldest valid entry that has issued segments that
  // are not done. The segments finish in the order in which they were issued.
  always_comb begin : p_com_cmp_idx
    w_cmp_hit = 1'b0;
    w_cmp_idx = 2'd0;
    for (int idx = 3; idx >= 0; idx--) begin
      if (reg_wq_vld[reg_wq_fp + 2'(idx)] && !reg_wq_abt[reg_wq_fp + 2'(idx)] &&
          (reg_wq_niss[reg_wq_fp + 2'(idx)] != reg_wq_ncmp[reg_wq_fp + 2'(idx)])) begin
        w_cmp_hit = 1'b1;
        w_cmp_idx = reg_wq_fp + 2'(idx);
      end
    end
  end

  // Segment counters of every write entry: issued and done. They clear when the entry is
  // allocated.
  for (genvar gen_i = 0; gen_i < 4; gen_i++) begin : gen_wq_cnt
    // Counters of entry gen_i.
    always_ff @(posedge i_clk_core, negedge i_rst_n_core) begin : p_ff_wq_cnt
      if (!i_rst_n_core) begin
        reg_wq_niss[gen_i] <= 5'd0;
        reg_wq_ncmp[gen_i] <= 5'd0;
      end else if (w_wq_set[gen_i]) begin
        reg_wq_niss[gen_i] <= 5'd0;
        reg_wq_ncmp[gen_i] <= 5'd0;
      end else begin
        if (w_wd_push && (reg_wq_dp == 2'(gen_i)))
          reg_wq_niss[gen_i] <= reg_wq_niss[gen_i] + 5'd1;
        if (i_wr_seg_done && w_cmp_hit && (w_cmp_idx == 2'(gen_i)))
          reg_wq_ncmp[gen_i] <= reg_wq_ncmp[gen_i] + 5'd1;
      end
    end
  end

  // One-hot masks of the entry that is allocated by an accepted AW request and of the entry that
  // is freed (response sent and RAM write complete).
  assign w_wq_set  = w_aw_acc ? (4'b0001 << reg_wq_wp) : 4'b0000;
  assign w_wq_free = reg_wq_vld[reg_wq_fp] & reg_wq_bdone[reg_wq_fp] &
                     w_wq_ramdone[reg_wq_fp];
  // Clear mask of the freed entry.
  assign w_wq_clr  = w_wq_free ? (4'b0001 << reg_wq_fp) : 4'b0000;

  // Queue state: valid, data done, response done and aborted bits and the pointers.
  always_ff @(posedge i_clk_core, negedge i_rst_n_core) begin : p_ff_wq_ctrl
    if (!i_rst_n_core) begin
      reg_wq_vld   <= 4'b0000;
      reg_wq_ddone <= 4'b0000;
      reg_wq_bdone <= 4'b0000;
      reg_wq_abt   <= 4'b0000;
      reg_wq_wp    <= 2'd0;
      reg_wq_fp    <= 2'd0;
      reg_wq_bp    <= 2'd0;
    end else begin
      reg_wq_vld   <= (reg_wq_vld | w_wq_set) & ~w_wq_clr;
      reg_wq_ddone <= (reg_wq_ddone | (w_wd_fin ? (4'b0001 << reg_wq_dp) : 4'b0000)) &
                      ~w_wq_set;
      reg_wq_bdone <= (reg_wq_bdone | (w_b_load ? (4'b0001 << reg_wq_bp) : 4'b0000)) &
                      ~w_wq_set;
      reg_wq_abt   <= (reg_wq_abt | w_wq_abtset) & ~w_wq_set;
      reg_wq_wp    <= reg_wq_wp + 2'(w_aw_acc);
      reg_wq_fp    <= reg_wq_fp + 2'(w_wq_free);
      reg_wq_bp    <= reg_wq_bp + 2'(w_b_load);
    end
  end

  // ---------------------------------------------------------------------------------------------
  // Write data engine: splits the request, takes the W beats and fills the write buffer
  // ---------------------------------------------------------------------------------------------

  // Views of the entry at the data pointer, its geometry and the wrap match with the device.
  always_comb begin : p_com_wd_view
    w_wd_addr  = reg_wq_addr[reg_wq_dp];
    w_wd_len   = reg_wq_len[reg_wq_dp];
    w_wd_size  = reg_wq_size[reg_wq_dp];
    w_wd_wrap  = reg_wq_wrap[reg_wq_dp];
    w_wd_v     = reg_wq_vld[reg_wq_dp] & ~reg_wq_ddone[reg_wq_dp];
    w_wd_drain = w_wd_v & ((reg_wq_rej[reg_wq_dp] != 2'd0) | reg_wq_abt[reg_wq_dp]);
    w_wd_norm  = w_wd_v & ~w_wd_drain;
    w_wd_tot   = (12'(w_wd_len) + 12'd1) << w_wd_size;
    w_wd_nbm   = (12'd1 << w_wd_size) - 12'd1;
    w_wd_off   = 12'(w_wd_addr) & (w_wd_tot - 12'd1);
    w_wd_cs0   = ~((PARA_NUM_CS == LPARA_TWO_CS) && (w_wd_addr >= PARA_MEM_SIZE_BYTES));
    w_wd_match = w_wd_wrap && (w_wd_tot == f_blen_bytes(w_wd_cs0 ? i_blen_cs0 : i_blen_cs1));
  end

  // Piece to load, same rules as the read splitter.
  always_comb begin : p_com_wd_load
    w_wd_ld_a   = w_wd_addr;
    w_wd_ld_rem = w_wd_tot - (12'(w_wd_addr) & w_wd_nbm);
    casez ({w_wd_wrap, w_wd_match, reg_wg_ph})
      3'b11?: begin
        w_wd_ld_a   = w_wd_addr;
        w_wd_ld_rem = w_wd_tot;
      end
      3'b100: begin
        w_wd_ld_a   = w_wd_addr;
        w_wd_ld_rem = w_wd_tot - w_wd_off;
      end
      3'b101: begin
        w_wd_ld_a   = w_wd_addr & ~(32'(w_wd_tot) - 32'd1);
        w_wd_ld_rem = w_wd_off;
      end
      default: begin
        w_wd_ld_a   = w_wd_addr;
        w_wd_ld_rem = w_wd_tot - (12'(w_wd_addr) & w_wd_nbm);
      end
    endcase
  end

  // The segment under computation: size, lead pad, memory units, chip select, device address.
  always_comb begin : p_com_wd_seg
    w_wd_n     = f_seg_bytes(reg_wg_a, reg_wg_rem, reg_wg_wseg, LPARA_MAXSEG_WR);
    w_wd_lead  = reg_wg_a[0];
    w_wd_units = (12'(w_wd_lead) + w_wd_n + 12'(LPARA_UNIT_BYTES - 32'd1)) >> LPARA_UNIT_LOG2;
    w_wd_cs    = (PARA_NUM_CS == LPARA_TWO_CS) && (reg_wg_a >= PARA_MEM_SIZE_BYTES);
    w_wd_dev   = w_wd_cs ? (reg_wg_a - PARA_MEM_SIZE_BYTES) : reg_wg_a;
  end

  // Second piece of a split wrap, piece load and segment start conditions.
  assign w_wd_second = w_wd_wrap & ~reg_wg_wseg & ~reg_wg_ph & (w_wd_off != 12'd0);
  assign w_wd_load   = w_wd_norm & reg_wg_started & ~reg_wg_ld & ~reg_wg_alldone;
  assign w_wd_start  = w_wd_norm & reg_wg_started & reg_wg_ld & ~reg_wg_segact &
                       ~reg_wg_segend & ~i_abort;

  // W channel handshake. A rejected or aborted write consumes its beats; a normal write takes a
  // beat into the beat register when it is free.
  assign o_axi_wready   = reg_wg_started & ~reg_wg_wdone &
                          (w_wd_drain | (w_wd_norm & ~reg_wb_valid));
  // Accepted W beat and the position of the last beat.
  assign w_wd_wacc      = i_axi_wvalid & o_axi_wready;
  assign w_wd_wlast_now = (reg_wg_abeat == w_wd_len);

  // Geometry of the beat in the beat register and the copy step into the write buffer: the
  // number of bytes is the smallest of the bytes the beat still has, the bytes the segment still
  // has and the bytes that fit into the current unit.
  always_comb begin : p_com_wd_copy
    w_wd_nb    = 4'd1 << w_wd_size;
    w_wd_nbeat = w_wd_nb - (4'(reg_wg_a7) & (w_wd_nb - 4'd1));
    w_wd_pos   = 4'(reg_wg_a7 & 7'(LPARA_AXI_STRB_W - 32'd1)) + reg_wg_have;
    w_wd_cn    = w_wd_nbeat - reg_wg_have;
    if (reg_wg_segrem < 12'(w_wd_cn))
      w_wd_cn = 4'(reg_wg_segrem);
    if ((4'(LPARA_UNIT_BYTES) - 4'(reg_wg_woff)) < w_wd_cn)
      w_wd_cn = 4'(LPARA_UNIT_BYTES) - 4'(reg_wg_woff);
    w_wd_open  = reg_wg_first | (reg_wg_woff == 3'd0);
    w_wd_copy  = w_wd_norm & reg_wg_started & reg_wg_segact & reg_wb_valid & ~i_abort &
                 (~w_wd_open | (32'(reg_wr_cnt) < LPARA_WR_UNITS));
    w_wd_have_nxt   = reg_wg_have + w_wd_cn;
    w_wd_segrem_nxt = reg_wg_segrem - 12'(w_wd_cn);
    w_wd_woff_nxt   = reg_wg_woff + 3'(w_wd_cn);
    w_wd_a7_nxt     = f_a7_nxt(reg_wg_a7, w_wd_size, w_wd_wrap, w_wd_tot[6:0]);
    w_wc_lane_we    = '0;
    w_wc_lane_data  = '0;
    w_wc_lane_mask  = '0;
    for (int lane = 0; lane < LPARA_MAX_UNIT_B; lane++) begin
      if (32'(lane) < LPARA_UNIT_BYTES) begin
        w_wc_lane_we[lane] = w_wd_copy & (reg_wg_first | (3'(lane) >= reg_wg_woff));
        if ((4'(lane) >= 4'(reg_wg_woff)) && (4'(lane) < (4'(reg_wg_woff) + w_wd_cn))) begin
          w_wc_lane_data[LPARA_BYTE_W*lane +: LPARA_BYTE_W] =
            LPARA_BYTE_W'(reg_wb_data >> {(w_wd_pos + 4'(lane) - 4'(reg_wg_woff)) &
                               4'(LPARA_IDX_MASK), 3'b000});
          w_wc_lane_mask[lane] =
            1'(reg_wb_strb >> ((w_wd_pos + 4'(lane) - 4'(reg_wg_woff)) & 4'(LPARA_IDX_MASK)));
        end
      end
    end
  end

  // Beat completion, unit close, segment push and entry end.
  assign w_wd_close = w_wd_copy & ((32'(w_wd_woff_nxt) == LPARA_UNIT_BYTES) ||
                                   (w_wd_segrem_nxt == 12'd0));
  // Beat completion, segment push and the end of the entry.
  assign w_wd_cmpl  = w_wd_copy & (w_wd_have_nxt == w_wd_nbeat);
  assign w_wd_push  = reg_wg_segend & ~reg_wr_slot_v & ~i_abort;
  assign w_wd_fin   = (w_wd_norm & reg_wg_started & reg_wg_lastdone & ~reg_wg_segact &
                       ~reg_wg_segend) |
                      (w_wd_drain & reg_wg_started &
                       (reg_wg_wdone | (w_wd_wacc & w_wd_wlast_now)));

  // Engine state. The abort at the end drops the work in progress; the entry then drains its W
  // beats because it is marked as aborted.
  always_ff @(posedge i_clk_core, negedge i_rst_n_core) begin : p_ff_wd
    if (!i_rst_n_core) begin
      reg_wg_started  <= 1'b0;
      reg_wg_ld       <= 1'b0;
      reg_wg_ph       <= 1'b0;
      reg_wg_wseg     <= 1'b0;
      reg_wg_alldone  <= 1'b0;
      reg_wg_a        <= '0;
      reg_wg_rem      <= '0;
      reg_wg_segact   <= 1'b0;
      reg_wg_segend   <= 1'b0;
      reg_wg_segrem   <= '0;
      reg_wg_segunits <= '0;
      reg_wg_segaddr  <= '0;
      reg_wg_segcs    <= 1'b0;
      reg_wg_segwrap  <= 1'b0;
      reg_wg_woff     <= 3'd0;
      reg_wg_first    <= 1'b0;
      reg_wg_a7       <= 7'd0;
      reg_wg_abeat    <= '0;
      reg_wg_wdone    <= 1'b0;
      reg_wg_lastdone <= 1'b0;
      reg_wg_have     <= 4'd0;
      reg_wb_valid    <= 1'b0;
      reg_wb_last     <= 1'b0;
      reg_wq_dp       <= 2'd0;
    end else begin
      if (w_wd_fin) begin
        reg_wg_started  <= 1'b0;
        reg_wg_ld       <= 1'b0;
        reg_wg_ph       <= 1'b0;
        reg_wg_alldone  <= 1'b0;
        reg_wg_segact   <= 1'b0;
        reg_wg_segend   <= 1'b0;
        reg_wg_woff     <= 3'd0;
        reg_wg_first    <= 1'b0;
        reg_wg_abeat    <= '0;
        reg_wg_wdone    <= 1'b0;
        reg_wg_lastdone <= 1'b0;
        reg_wg_have     <= 4'd0;
        reg_wb_valid    <= 1'b0;
        reg_wq_dp       <= reg_wq_dp + 2'd1;
      end else begin
        // Entry start: initialise the counters of the entry.
        if (w_wd_v && !reg_wg_started) begin
          reg_wg_started <= 1'b1;
          reg_wg_a7      <= w_wd_addr[6:0];
          reg_wg_abeat   <= '0;
          reg_wg_wdone   <= 1'b0;
          reg_wg_lastdone <= 1'b0;
          reg_wg_have    <= 4'd0;
        end
        // Piece load.
        if (w_wd_load) begin
          reg_wg_ld   <= 1'b1;
          reg_wg_wseg <= w_wd_match;
          reg_wg_a    <= w_wd_ld_a;
          reg_wg_rem  <= w_wd_ld_rem;
        end
        // Segment start: remember the descriptor and the fill state, advance the piece.
        if (w_wd_start) begin
          reg_wg_segact   <= 1'b1;
          reg_wg_segrem   <= w_wd_n;
          reg_wg_segunits <= w_wd_units;
          reg_wg_segaddr  <= w_wd_dev & ~32'd1;
          reg_wg_segcs    <= w_wd_cs;
          reg_wg_segwrap  <= reg_wg_wseg;
          reg_wg_woff     <= 3'(w_wd_lead);
          reg_wg_first    <= 1'b1;
          if (w_wd_n == reg_wg_rem) begin
            reg_wg_ld <= 1'b0;
            if (w_wd_second)
              reg_wg_ph <= 1'b1;
            else
              reg_wg_alldone <= 1'b1;
          end else begin
            reg_wg_a   <= reg_wg_a + 32'(w_wd_n);
            reg_wg_rem <= reg_wg_rem - w_wd_n;
          end
        end
        // W beat accepted.
        if (w_wd_wacc) begin
          reg_wg_abeat <= reg_wg_abeat + 8'd1;
          if (w_wd_wlast_now)
            reg_wg_wdone <= 1'b1;
          if (w_wd_norm) begin
            reg_wb_valid <= 1'b1;
            reg_wb_last  <= w_wd_wlast_now;
          end
        end
        // Copy of bytes into the write buffer.
        if (w_wd_copy) begin
          reg_wg_have   <= w_wd_have_nxt;
          reg_wg_segrem <= w_wd_segrem_nxt;
          reg_wg_woff   <= (w_wd_close) ? 3'd0 : w_wd_woff_nxt;
          reg_wg_first  <= 1'b0;
          if (w_wd_segrem_nxt == 12'd0) begin
            reg_wg_segact <= 1'b0;
            reg_wg_segend <= 1'b1;
          end
          if (w_wd_cmpl) begin
            reg_wb_valid <= 1'b0;
            reg_wg_have  <= 4'd0;
            reg_wg_a7    <= w_wd_a7_nxt;
            if (reg_wb_last)
              reg_wg_lastdone <= 1'b1;
          end
        end
        // The segment is handed to the slot.
        if (w_wd_push)
          reg_wg_segend <= 1'b0;
        // Abort: drop the work in progress; the beats that were taken stay counted.
        if (i_abort) begin
          reg_wg_ld       <= 1'b0;
          reg_wg_ph       <= 1'b0;
          reg_wg_segact   <= 1'b0;
          reg_wg_segend   <= 1'b0;
          reg_wg_lastdone <= 1'b0;
          reg_wg_woff     <= 3'd0;
          reg_wg_first    <= 1'b0;
          reg_wg_have     <= 4'd0;
          reg_wb_valid    <= 1'b0;
        end
      end
    end
  end

  // Beat register payload: loaded with the accepted W beat, used while its valid bit is 1.
  always_ff @(posedge i_clk_core) begin : p_ff_wb_pl
    if (w_wd_wacc) begin
      reg_wb_data <= i_axi_wdata;
      reg_wb_strb <= i_axi_wstrb;
    end
  end

  // Write buffer: one array of bytes and one of mask bits per lane of the memory unit. Each lane
  // is written when the copy step touches it; the controller reads the unit at the read pointer.
  for (genvar gen_l = 0; gen_l < LPARA_UNIT_BYTES; gen_l++) begin : gen_wr_lane
    logic [7:0] reg_wr_byte [0:LPARA_WR_UNITS-1];
    logic       reg_wr_msk  [0:LPARA_WR_UNITS-1];

    // Lane write port.
    always_ff @(posedge i_clk_core) begin : p_ff_wr_lane
      if (w_wc_lane_we[gen_l]) begin
        reg_wr_byte[reg_wr_wptr] <= w_wc_lane_data[LPARA_BYTE_W*gen_l +: LPARA_BYTE_W];
        reg_wr_msk[reg_wr_wptr]  <= w_wc_lane_mask[gen_l];
      end
    end

    // Lane read port: the head unit toward the controller.
    assign o_wr_data[LPARA_BYTE_W*gen_l +: LPARA_BYTE_W] = reg_wr_byte[reg_wr_rptr];
    assign o_wr_mask[gen_l]        = reg_wr_msk[reg_wr_rptr];
  end

  // Write buffer pointers and fill count. A unit counts from its first byte until the controller
  // pops it. An abort empties the buffer.
  always_ff @(posedge i_clk_core, negedge i_rst_n_core) begin : p_ff_wr_buf
    if (!i_rst_n_core) begin
      reg_wr_wptr <= '0;
      reg_wr_rptr <= '0;
      reg_wr_cnt  <= '0;
    end else if (i_abort) begin
      reg_wr_wptr <= '0;
      reg_wr_rptr <= '0;
      reg_wr_cnt  <= '0;
    end else begin
      if (w_wd_close)
        reg_wr_wptr <= reg_wr_wptr + 1'b1;
      if (i_wr_data_pop)
        reg_wr_rptr <= reg_wr_rptr + 1'b1;
      reg_wr_cnt <= reg_wr_cnt + LPARA_BYTES_W'(w_wd_copy && w_wd_open) -
                    LPARA_BYTES_W'(i_wr_data_pop);
    end
  end

  // Write segment slot valid bit: set by a push, cleared when the controller takes the
  // descriptor or by an abort.
  always_ff @(posedge i_clk_core, negedge i_rst_n_core) begin : p_ff_wr_slot_v
    if (!i_rst_n_core) begin
      reg_wr_slot_v <= 1'b0;
    end else begin
      casez ({i_abort, w_wd_push, i_wr_seg_ready})
        3'b1??: begin
          reg_wr_slot_v <= 1'b0;
        end
        3'b01?: begin
          reg_wr_slot_v <= 1'b1;
        end
        3'b001: begin
          reg_wr_slot_v <= 1'b0;
        end
        default: begin
          // No change.
        end
      endcase
    end
  end

  // Slot payload, loaded at the push.
  always_ff @(posedge i_clk_core) begin : p_ff_wr_slot_pl
    if (w_wd_push) begin
      reg_wr_slot_cs    <= reg_wg_segcs;
      reg_wr_slot_addr  <= reg_wg_segaddr;
      reg_wr_slot_units <= reg_wg_segunits;
      reg_wr_slot_wrap  <= reg_wg_segwrap;
    end
  end

  // Descriptor outputs.
  assign o_wr_seg_valid = reg_wr_slot_v;
  assign o_wr_seg_cs    = reg_wr_slot_cs;
  assign o_wr_seg_addr  = reg_wr_slot_addr;
  assign o_wr_seg_units = reg_wr_slot_units;
  assign o_wr_seg_wrap  = reg_wr_slot_wrap;

  // ---------------------------------------------------------------------------------------------
  // B channel
  // ---------------------------------------------------------------------------------------------

  // The oldest entry answers when its data are taken and, unless the write is rejected, aborted
  // or posted, when its segments are done. The response is the rejection code, SLVERR for an
  // aborted write, otherwise OKAY.
  assign w_b_load = (~reg_b_valid | i_axi_bready) & reg_wq_vld[reg_wq_bp] &
                    ~reg_wq_bdone[reg_wq_bp] & reg_wq_ddone[reg_wq_bp] &
                    ((reg_wq_rej[reg_wq_bp] != 2'd0) | reg_wq_abt[reg_wq_bp] | i_wr_posted |
                     (reg_wq_niss[reg_wq_bp] == reg_wq_ncmp[reg_wq_bp]));

  // B response code.
  always_comb begin : p_com_b_resp
    w_b_resp_nxt = 2'(LPARA_RESP_OKAY);
    if (reg_wq_rej[reg_wq_bp] != 2'd0)
      w_b_resp_nxt = reg_wq_rej[reg_wq_bp];
    else if (reg_wq_abt[reg_wq_bp])
      w_b_resp_nxt = 2'(LPARA_RESP_SLVERR);
  end

  // B register valid bit.
  always_ff @(posedge i_clk_core, negedge i_rst_n_core) begin : p_ff_b_valid
    if (!i_rst_n_core)
      reg_b_valid <= 1'b0;
    else if (w_b_load)
      reg_b_valid <= 1'b1;
    else if (i_axi_bready)
      reg_b_valid <= 1'b0;
  end

  // B register payload.
  always_ff @(posedge i_clk_core) begin : p_ff_b_pl
    if (w_b_load) begin
      reg_b_id   <= reg_wq_id[reg_wq_bp];
      reg_b_resp <= w_b_resp_nxt;
    end
  end

  // B channel outputs.
  assign o_axi_bvalid = reg_b_valid;
  assign o_axi_bid    = reg_b_id;
  assign o_axi_bresp  = reg_b_resp;

  // ---------------------------------------------------------------------------------------------
  // Error events, counters and logs (REQ-CSR registers hr_err_*)
  // ---------------------------------------------------------------------------------------------

  // Counters, last-error logs and event pulses. Only a request that is rejected at the AXI
  // interface counts (DEC-047); a device timeout is logged by the controller.
  always_ff @(posedge i_clk_core, negedge i_rst_n_core) begin : p_ff_err
    if (!i_rst_n_core) begin
      reg_cnt_decerr <= 16'd0;
      reg_cnt_slverr <= 16'd0;
      reg_ra_addr    <= '0;
      reg_ri_valid   <= 1'b0;
      reg_ri_resp    <= 2'd0;
      reg_ri_id      <= '0;
      reg_wa_addr    <= '0;
      reg_wi_valid   <= 1'b0;
      reg_wi_resp    <= 2'd0;
      reg_wi_id      <= '0;
      reg_evt_decerr <= 1'b0;
      reg_evt_slverr <= 1'b0;
    end else begin
      reg_evt_decerr <= (w_ar_acc && (w_ar_rej == 2'(LPARA_RESP_DECERR))) ||
                        (w_aw_acc && (w_aw_rej == 2'(LPARA_RESP_DECERR)));
      reg_evt_slverr <= (w_ar_acc && (w_ar_rej == 2'(LPARA_RESP_SLVERR))) ||
                        (w_aw_acc && (w_aw_rej == 2'(LPARA_RESP_SLVERR)));
      if ((w_ar_acc && (w_ar_rej == 2'(LPARA_RESP_DECERR))) ||
          (w_aw_acc && (w_aw_rej == 2'(LPARA_RESP_DECERR)))) begin
        if (reg_cnt_decerr != 16'hFFFF)
          reg_cnt_decerr <= reg_cnt_decerr + 16'd1;
      end
      if ((w_ar_acc && (w_ar_rej == 2'(LPARA_RESP_SLVERR))) ||
          (w_aw_acc && (w_aw_rej == 2'(LPARA_RESP_SLVERR)))) begin
        if (reg_cnt_slverr != 16'hFFFF)
          reg_cnt_slverr <= reg_cnt_slverr + 16'd1;
      end
      if (w_ar_acc && (w_ar_rej != 2'd0)) begin
        reg_ra_addr  <= i_axi_araddr;
        reg_ri_valid <= 1'b1;
        reg_ri_resp  <= w_ar_rej;
        reg_ri_id    <= i_axi_arid;
      end
      if (w_aw_acc && (w_aw_rej != 2'd0)) begin
        reg_wa_addr  <= i_axi_awaddr;
        reg_wi_valid <= 1'b1;
        reg_wi_resp  <= w_aw_rej;
        reg_wi_id    <= i_axi_awid;
      end
    end
  end

  // Error outputs toward the register file.
  assign o_evt_decerr     = reg_evt_decerr;
  assign o_evt_slverr     = reg_evt_slverr;
  assign o_err_cnt_decerr = reg_cnt_decerr;
  assign o_err_cnt_slverr = reg_cnt_slverr;
  assign o_err_ra_addr    = reg_ra_addr;
  assign o_err_ri_valid   = reg_ri_valid;
  assign o_err_ri_resp    = reg_ri_resp;
  assign o_err_ri_id      = reg_ri_id;
  assign o_err_wa_addr    = reg_wa_addr;
  assign o_err_wi_valid   = reg_wi_valid;
  assign o_err_wi_resp    = reg_wi_resp;
  assign o_err_wi_id      = reg_wi_id;

  // ---------------------------------------------------------------------------------------------
  // Status
  // ---------------------------------------------------------------------------------------------

  // Outstanding requests: the valid entries of the queues (hr_sts.rd_out and hr_sts.wr_out).
  assign o_rd_out = 3'(reg_rq_vld[0]) + 3'(reg_rq_vld[1]) + 3'(reg_rq_vld[2]) +
                    3'(reg_rq_vld[3]);
  // Outstanding writes.
  assign o_wr_out = 3'(reg_wq_vld[0]) + 3'(reg_wq_vld[1]) + 3'(reg_wq_vld[2]) +
                    3'(reg_wq_vld[3]);

  // Idle: no request, response, descriptor or abort drain is pending in either direction.
  assign o_fe_idle = ~(|reg_rq_vld) & ~(|reg_wq_vld) & ~reg_b_valid & ~reg_r_valid &
                     ~reg_rd_slot_v & ~reg_wr_slot_v & ~reg_rd_aborted;

endmodule
