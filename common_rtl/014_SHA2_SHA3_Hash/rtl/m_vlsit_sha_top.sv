/*
 * Project      : VLSIT Common RTL library
 * Author       : Nguyen Quan and Claude Sonnet 5.5 (user)
 * AI Flow      : VLSIT RTL Generator AI Automation Flow
 * AI Flow Page : https://github.com/nguyenquanicd/VLSIT_RTL_Generator_AI_Model
 * Date         : 2026-11-09
 * Description  : Structural top of the SHA2 and SHA3 hash IP (stage 1 of the RTL, DEC-018). It
 *                holds the reset release of both clock domains, the generated register block, the
 *                AXI4 subordinate with the message and digest windows, the per-context input and
 *                output FIFOs, the context sequencer with the padding, the SHA-256, SHA-512 and
 *                Keccak cores (each built only when one of its algorithms is enabled), the context
 *                memory, the digest pusher, the optional external DMA handshake and the interrupt
 *                logic. An illegal combination of parameters stops elaboration (DEC-017): a
 *                generate block instantiates a module named m_vlsit_sha_ERR_ and the cause, which
 *                does not exist. The fault detection (duplicate core, parity, recompute, responses,
 *                alarm) is built by its parameters (stage 2a). The masked Keccak core and the
 *                entropy input belong to stage 2b: their ports exist, their parameters must be 0.
 *                Decisions: DEC-001 to DEC-035.
 */
`timescale 1ns/1ps

module m_vlsit_sha_top #(
  // Parameter Description: build SHA-224 (needs the SHA-256 core).
  // Parameter values: 0 or 1; default is 0.
  // Parameter unit: none
  parameter logic [31:0] PARA_EN_SHA224 = 0,
  // Parameter Description: build SHA-256 (needs the SHA-256 core).
  // Parameter values: 0 or 1; default is 1. At least one algorithm shall be built.
  // Parameter unit: none
  parameter logic [31:0] PARA_EN_SHA256 = 1,
  // Parameter Description: build SHA-384 (needs the SHA-512 core).
  // Parameter values: 0 or 1; default is 0.
  // Parameter unit: none
  parameter logic [31:0] PARA_EN_SHA384 = 0,
  // Parameter Description: build SHA-512 (needs the SHA-512 core).
  // Parameter values: 0 or 1; default is 0.
  // Parameter unit: none
  parameter logic [31:0] PARA_EN_SHA512 = 0,
  // Parameter Description: build SHA-512/224 (needs the SHA-512 core).
  // Parameter values: 0 or 1; default is 0.
  // Parameter unit: none
  parameter logic [31:0] PARA_EN_SHA512_224 = 0,
  // Parameter Description: build SHA-512/256 (needs the SHA-512 core).
  // Parameter values: 0 or 1; default is 0.
  // Parameter unit: none
  parameter logic [31:0] PARA_EN_SHA512_256 = 0,
  // Parameter Description: build SHA3-224 (needs the Keccak core).
  // Parameter values: 0 or 1; default is 0.
  // Parameter unit: none
  parameter logic [31:0] PARA_EN_SHA3_224 = 0,
  // Parameter Description: build SHA3-256 (needs the Keccak core).
  // Parameter values: 0 or 1; default is 0.
  // Parameter unit: none
  parameter logic [31:0] PARA_EN_SHA3_256 = 0,
  // Parameter Description: build SHA3-384 (needs the Keccak core).
  // Parameter values: 0 or 1; default is 0.
  // Parameter unit: none
  parameter logic [31:0] PARA_EN_SHA3_384 = 0,
  // Parameter Description: build SHA3-512 (needs the Keccak core).
  // Parameter values: 0 or 1; default is 0.
  // Parameter unit: none
  parameter logic [31:0] PARA_EN_SHA3_512 = 0,
  // Parameter Description: build SHAKE128 (needs the Keccak core).
  // Parameter values: 0 or 1; default is 0.
  // Parameter unit: none
  parameter logic [31:0] PARA_EN_SHAKE128 = 0,
  // Parameter Description: build SHAKE256 (needs the Keccak core).
  // Parameter values: 0 or 1; default is 0.
  // Parameter unit: none
  parameter logic [31:0] PARA_EN_SHAKE256 = 0,
  // Parameter Description: SHA-224 and SHA-256 rounds computed in one cycle; shall divide 64.
  // Parameter values: 1, 2, 4, 8, 16, 32 or 64; default is 1.
  // Parameter unit: count
  parameter logic [31:0] PARA_S256_UNR = 1,
  // Parameter Description: SHA-384 and SHA-512 family rounds per cycle; shall divide 80.
  // Parameter values: 1, 2, 4, 5, 8, 10, 16, 20, 40 or 80; default is 1.
  // Parameter unit: count
  parameter logic [31:0] PARA_S512_UNR = 1,
  // Parameter Description: Keccak rounds computed in one cycle; shall divide 24.
  // Parameter values: 1, 2, 3, 4, 6, 8, 12 or 24; default is 1.
  // Parameter unit: count
  parameter logic [31:0] PARA_KEC_UNR = 1,
  // Parameter Description: register stages in the SHA-256 round loop (DEC-019).
  // Parameter values: 1 only; default is 1.
  // Parameter unit: count
  parameter logic [31:0] PARA_S256_PIPE = 1,
  // Parameter Description: register stages in the SHA-512 round loop (DEC-019).
  // Parameter values: 1 only; default is 1.
  // Parameter unit: count
  parameter logic [31:0] PARA_S512_PIPE = 1,
  // Parameter Description: register stages in the Keccak round loop (DEC-019, DEC-036).
  // Parameter values: 1, or 2 with PARA_MASK = 1 (and only then); default is 1.
  // Parameter unit: count
  parameter logic [31:0] PARA_KEC_PIPE = 1,
  // Parameter Description: messages in progress at the same time.
  // Parameter values: 1 to 16; default is 1.
  // Parameter unit: count
  parameter logic [31:0] PARA_CTX_N = 1,
  // Parameter Description: context memory kind (DEC-016).
  // Parameter values: 0 only (flip-flops); default is 0.
  // Parameter unit: none
  parameter logic [31:0] PARA_CTX_MEM = 0,
  // Parameter Description: AXI data width. 128 needs every enabled block to be a multiple of 16
  // bytes, which excludes SHA3-256, SHA3-384, SHA3-512, SHAKE128 and SHAKE256 (DEC-019).
  // Parameter values: 32, 64 or 128; default is 64.
  // Parameter unit: bit
  parameter logic [31:0] PARA_AXI_DW = 64,
  // Parameter Description: AXI ID width.
  // Parameter values: 1 to 16; default is 4.
  // Parameter unit: bit
  parameter logic [31:0] PARA_AXI_IDW = 4,
  // Parameter Description: AXI address width; only bits [15:0] are decoded.
  // Parameter values: 16 to 32; default is 16.
  // Parameter unit: bit
  parameter logic [31:0] PARA_AXI_AW = 16,
  // Parameter Description: depth of the input FIFO of each context; at least a block and two words.
  // Parameter values: power of 2 from 4 to 1024; default is 64.
  // Parameter unit: word
  parameter logic [31:0] PARA_IN_DEPTH = 64,
  // Parameter Description: depth of the output FIFO of each context; at least 64 bytes.
  // Parameter values: power of 2 from 4 to 1024; default is 32.
  // Parameter unit: word
  parameter logic [31:0] PARA_OUT_DEPTH = 32,
  // Parameter Description: build the external DMA handshake.
  // Parameter values: 0 or 1; default is 0.
  // Parameter unit: none
  parameter logic [31:0] PARA_DMA = 0,
  // Parameter Description: the APB clock differs from the core clock (asynchronous register block).
  // Parameter values: 0 or 1; default is 0.
  // Parameter unit: none
  parameter logic [31:0] PARA_CSR_ASYNC = 0,
  // Parameter Description: build the clearing of the state and the core registers.
  // Parameter values: 0 or 1; default is 1.
  // Parameter unit: none
  parameter logic [31:0] PARA_ZERO = 1,
  // Parameter Description: duplicate-core fault detection (stage 2a).
  // Parameter values: 0 or 1; default is 0.
  // Parameter unit: none
  parameter logic [31:0] PARA_FAULT_DUP = 0,
  // Parameter Description: parity fault detection (stage 2a).
  // Parameter values: 0 or 1; default is 0.
  // Parameter unit: none
  parameter logic [31:0] PARA_FAULT_PAR = 0,
  // Parameter Description: recompute fault detection (stage 2a).
  // Parameter values: 0 or 1; default is 0.
  // Parameter unit: none
  parameter logic [31:0] PARA_FAULT_REDO = 0,
  // Parameter Description: first-order masked Keccak core and random bit source (stage 2b).
  // Parameter values: 0 or 1; 1 needs a Keccak algorithm, KEC_UNR 1 and KEC_PIPE 2; default is 0.
  // Parameter unit: none
  parameter logic [31:0] PARA_MASK = 0,
  // Parameter Description: seed source of the random bit source (stage 2b).
  // Parameter values: 0 entropy port, 1 seed registers (1 needs PARA_MASK = 1); default is 0.
  // Parameter unit: none
  parameter logic [31:0] PARA_SEED_SRC = 0,
  // Parameter Description: drive the alarm output; needs a fault detection (stage 2a).
  // Parameter values: 0 or 1; default is 0.
  // Parameter unit: none
  parameter logic [31:0] PARA_ALARM = 0,
  localparam logic [31:0] LPARA_CTX_W = (PARA_CTX_N > 1) ? $clog2(PARA_CTX_N) : 1,
  localparam logic [31:0] LPARA_WB = PARA_AXI_DW / 8,
  localparam logic [31:0] LPARA_STRB_W = PARA_AXI_DW / 8,
  localparam logic [31:0] LPARA_EN_256 = PARA_EN_SHA224 | PARA_EN_SHA256,
  localparam logic [31:0] LPARA_EN_512 = PARA_EN_SHA384 | PARA_EN_SHA512 | PARA_EN_SHA512_224
                                       | PARA_EN_SHA512_256,
  localparam logic [31:0] LPARA_EN_KEC = PARA_EN_SHA3_224 | PARA_EN_SHA3_256 | PARA_EN_SHA3_384
                                       | PARA_EN_SHA3_512 | PARA_EN_SHAKE128 | PARA_EN_SHAKE256,
  localparam logic [31:0] LPARA_ALG_MAP = {20'b0, PARA_EN_SHAKE256[0], PARA_EN_SHAKE128[0],
                                           PARA_EN_SHA3_512[0], PARA_EN_SHA3_384[0],
                                           PARA_EN_SHA3_256[0], PARA_EN_SHA3_224[0],
                                           PARA_EN_SHA512_256[0], PARA_EN_SHA512_224[0],
                                           PARA_EN_SHA512[0], PARA_EN_SHA384[0],
                                           PARA_EN_SHA256[0], PARA_EN_SHA224[0]},
  localparam logic [31:0] LPARA_KECW = (PARA_MASK != 32'd0) ? 32'd3200 : 32'd1600,
  localparam logic [31:0] LPARA_STW = LPARA_EN_KEC ? LPARA_KECW : (LPARA_EN_512 ? 32'd512 : 32'd256),
  localparam logic [31:0] LPARA_MB_0 = LPARA_EN_256 ? 32'd64 : 32'd0,
  localparam logic [31:0] LPARA_MB_1 = LPARA_EN_512 ? 32'd128 : LPARA_MB_0,
  localparam logic [31:0] LPARA_MB_2 = PARA_EN_SHA3_224 ? 32'd144 : LPARA_MB_1,
  localparam logic [31:0] LPARA_MB_3 = (PARA_EN_SHA3_256 | PARA_EN_SHAKE256) ? ((LPARA_MB_2 > 32'd136) ? LPARA_MB_2 : 32'd136)
                                       : LPARA_MB_2,
  localparam logic [31:0] LPARA_MB_4 = PARA_EN_SHA3_384 ? ((LPARA_MB_3 > 32'd104) ? LPARA_MB_3 : 32'd104) : LPARA_MB_3,
  localparam logic [31:0] LPARA_MB_5 = PARA_EN_SHA3_512 ? ((LPARA_MB_4 > 32'd72) ? LPARA_MB_4 : 32'd72) : LPARA_MB_4,
  localparam logic [31:0] LPARA_MAXB = PARA_EN_SHAKE128 ? 32'd168 : LPARA_MB_5,
  localparam logic [31:0] LPARA_AXI_CODE = (PARA_AXI_DW == 32'd32) ? 32'd0 : ((PARA_AXI_DW == 32'd64) ? 32'd1 : 32'd2),
  localparam logic [31:0] LPARA_CAP_S256 = LPARA_EN_256 ? PARA_S256_UNR : 32'd0,
  localparam logic [31:0] LPARA_CAP_S512 = LPARA_EN_512 ? PARA_S512_UNR : 32'd0,
  localparam logic [31:0] LPARA_CAP_KEC = LPARA_EN_KEC ? PARA_KEC_UNR : 32'd0
) (
  // Clocks and resets
  input  wire                     i_clk_core,
  input  wire                     i_rst_n_core,
  input  wire                     i_clk_apb,
  input  wire                     i_rst_n_apb,

  // APB4 register interface
  input  wire                     i_apb_psel,
  input  wire                     i_apb_penable,
  input  wire                     i_apb_pwrite,
  input  wire  [15:0]             i_apb_paddr,
  input  wire  [31:0]             i_apb_pwdata,
  input  wire  [3:0]              i_apb_pstrb,
  input  wire  [2:0]              i_apb_pprot,
  output logic                    o_apb_pready,
  output logic                    o_apb_pslverr,
  output logic [31:0]             o_apb_prdata,
  input  wire                     i_protect_en,
  input  wire                     i_slverr_en,

  // AXI4 write address channel
  input  wire                     i_axi_awvalid,
  output logic                    o_axi_awready,
  input  wire  [PARA_AXI_IDW-1:0] i_axi_awid,
  input  wire  [PARA_AXI_AW-1:0]  i_axi_awaddr,
  input  wire  [7:0]              i_axi_awlen,
  input  wire  [2:0]              i_axi_awsize,
  input  wire  [1:0]              i_axi_awburst,

  // AXI4 write data channel
  input  wire                     i_axi_wvalid,
  output logic                    o_axi_wready,
  input  wire  [PARA_AXI_DW-1:0]  i_axi_wdata,
  input  wire  [LPARA_STRB_W-1:0] i_axi_wstrb,
  input  wire                     i_axi_wlast,

  // AXI4 write response channel
  output logic                    o_axi_bvalid,
  input  wire                     i_axi_bready,
  output logic [PARA_AXI_IDW-1:0] o_axi_bid,
  output logic [1:0]              o_axi_bresp,

  // AXI4 read address channel
  input  wire                     i_axi_arvalid,
  output logic                    o_axi_arready,
  input  wire  [PARA_AXI_IDW-1:0] i_axi_arid,
  input  wire  [PARA_AXI_AW-1:0]  i_axi_araddr,
  input  wire  [7:0]              i_axi_arlen,
  input  wire  [2:0]              i_axi_arsize,
  input  wire  [1:0]              i_axi_arburst,

  // AXI4 read data channel
  output logic                    o_axi_rvalid,
  input  wire                     i_axi_rready,
  output logic [PARA_AXI_IDW-1:0] o_axi_rid,
  output logic [PARA_AXI_DW-1:0]  o_axi_rdata,
  output logic [1:0]              o_axi_rresp,
  output logic                    o_axi_rlast,

  // External DMA handshake
  output logic                    o_dma_in_req,
  input  wire                     i_dma_in_ack,
  output logic                    o_dma_out_req,
  input  wire                     i_dma_out_ack,

  // Entropy input (stage 2, not used in this revision)
  input  wire                     i_ent_valid,
  input  wire  [31:0]             i_ent_data,
  output logic                    o_ent_req,

  // Interrupt and alarm
  output logic                    o_irq,
  output logic                    o_alarm
);

  // Interconnect declarations: resets
  logic w_rst_n_core;
  logic w_rst_n_apb;

  // Interconnect declarations: register block fields
  logic        w_ctrl_en;
  logic [3:0]  w_ctrl_algo;
  logic [4:0]  w_ctrl_ctxsel;
  logic        w_ctrl_dmaen;
  logic [7:0]  w_len_tail;
  logic [8:0]  w_dmac_burst;
  logic [15:0] w_dmac_tmo;
  logic        w_sec_zero;
  logic        w_sec_fault;
  logic        w_sec_fdup;
  logic        w_sec_fpar;
  logic        w_sec_fredo;
  logic [3:0]  w_sec_resp;
  logic        w_cmd_init;
  logic        w_cmd_final;
  logic        w_cmd_abort;
  logic        w_cmd_srst;
  logic        w_cmd_clear;
  logic        w_cmd_seed;
  logic        w_ack_init;
  logic        w_ack_final;
  logic        w_ack_abort;
  logic        w_ack_srst;
  logic        w_ack_clear;
  logic        w_ack_seed;
  logic        w_sts_busy;
  logic        w_sts_idle;
  logic        w_sts_ready;
  logic [3:0]  w_sts_cstate;
  logic [31:0] w_blk_cnt;
  logic [31:0] w_byte_cnt;
  logic [15:0] w_in_lvl;
  logic [15:0] w_out_lvl;
  logic        w_dma_act;
  logic [8:0]  w_dma_dvld;
  logic        w_dma_pad_ok;
  logic [4:0]  w_err_ctx;
  logic [3:0]  w_err_kind;
  logic [7:0]  w_err_ovf;
  logic [7:0]  w_err_udf;
  logic [31:0] w_err_addr;

  // Interconnect declarations: interrupts
  logic [PARA_CTX_N-1:0] w_ev_cdone;
  logic        w_ev_cfg;
  logic        w_ev_cfg_dma;
  logic        w_ev_cfg_all;
  logic        w_ev_len;
  logic        w_ev_ovf;
  logic        w_ev_udf;
  logic        w_ev_axi;
  logic        w_ev_tmo;
  logic [7:0]  w_raw_one;
  logic [15:0] w_raw_cdone;
  logic [7:0]  w_en_one;
  logic [15:0] w_en_cdone;
  logic [7:0]  w_inj_one;
  logic [15:0] w_inj_cdone;
  logic [7:0]  w_hw_we_one;
  logic [7:0]  w_hw_wd_one;
  logic        w_hw_we_cdone;
  logic [15:0] w_hw_wd_cdone;
  logic [7:0]  w_sts_one;
  logic [15:0] w_sts_cdone;

  // Interconnect declarations: windows, FIFOs and sequencer
  logic                    w_in_push_en;
  logic [LPARA_CTX_W-1:0]  w_in_push_ctx;
  logic [PARA_AXI_DW-1:0]  w_in_push_data;
  logic [PARA_CTX_N-1:0]   w_in_full;
  logic [PARA_CTX_N-1:0]   w_in_empty;
  logic                    w_in_pop_en;
  logic [LPARA_CTX_W-1:0]  w_in_pop_ctx;
  logic [PARA_AXI_DW-1:0]  w_in_pop_data;
  logic                    w_out_push_en;
  logic [LPARA_CTX_W-1:0]  w_out_push_ctx;
  logic [PARA_AXI_DW-1:0]  w_out_push_data;
  logic [PARA_CTX_N-1:0]   w_out_full;
  logic [PARA_CTX_N-1:0]   w_out_empty;
  logic                    w_out_pop_en;
  logic [LPARA_CTX_W-1:0]  w_out_pop_ctx;
  logic [PARA_AXI_DW-1:0]  w_out_pop_data;
  logic                    w_out_beat;
  logic [PARA_CTX_N-1:0]   w_ctx_abs;
  logic [PARA_CTX_N-1:0]   w_clr_ctx;
  logic                    w_dma_clr;
  logic [PARA_CTX_N-1:0]   w_push_flag;
  logic [PARA_CTX_N-1:0][3:0] w_ctx_alg;
  logic                    w_done_ev;
  logic [LPARA_CTX_W-1:0]  w_done_ctx;
  logic                    w_perm_ev;
  logic [LPARA_CTX_W-1:0]  w_perm_ctx;
  logic [LPARA_CTX_W-1:0]  w_lvl_ctx;
  logic                    w_in_push_sel;
  logic                    w_out_pop_sel;
  logic                    w_out_beat_sel;
  logic                    w_in_abs_sel;

  // Interconnect declarations: context memory and cores
  logic                    w_wra_en;
  logic [LPARA_CTX_W-1:0]  w_wra_ctx;
  logic [LPARA_STW-1:0]    w_wra_data;
  logic                    w_wrb_en;
  logic [LPARA_CTX_W-1:0]  w_wrb_ctx;
  logic [LPARA_STW-1:0]    w_wrb_data;
  logic [LPARA_CTX_W-1:0]  w_rd0_ctx;
  logic [LPARA_STW-1:0]    w_rd0_data;
  logic [LPARA_CTX_W-1:0]  w_rd1_ctx;
  logic [LPARA_STW-1:0]    w_rd1_data;
  logic                    w_c256_start;
  logic                    w_c256_clr;
  logic                    w_c256_done;
  logic [255:0]            w_c256_result;
  logic                    w_c512_start;
  logic                    w_c512_clr;
  logic                    w_c512_done;
  logic [511:0]            w_c512_result;
  logic                    w_kec_start;
  logic                    w_kec_clr;
  logic                    w_kec_done;
  logic [LPARA_KECW-1:0]   w_kec_result;
  logic                    w_c256_done_b;
  logic [255:0]            w_c256_result_b;
  logic                    w_c512_done_b;
  logic [511:0]            w_c512_result_b;
  logic                    w_kec_done_b;
  logic [LPARA_KECW-1:0]   w_kec_result_b;
  logic                    w_seeded;
  logic [1599:0]           w_rnd;
  logic                    w_ctrl_mask;
  logic                    w_seed_load;
  logic                    w_ev_ent;
  logic                    w_mask_en;
  logic [255:0]            w_seed_wd;
  logic                    w_mismatch;
  logic                    w_ev_flt;
  logic                    w_lock;
  logic                    w_gate;
  logic                    w_wipe;
  logic                    w_alarm_set;
  logic                    w_par_err;
  logic                    w_redo_en;
  logic                    w_par_chk;
  logic                    w_perr_c256;
  logic                    w_perr_c512;
  logic                    w_perr_kec;
  logic                    w_perr_mem;
  logic                    w_perr_in;
  logic                    w_perr_out;
  logic                    w_be_done;
  logic [LPARA_STW-1:0]    w_be_res;
  logic                    w_pass_first;
  logic                    w_pass_second;
  logic [1343:0]           w_core_blk;
  logic [LPARA_STW-1:0]    w_core_state;

  // Illegal combinations of parameters (REQ-PARAM-001, DEC-016, DEC-017, DEC-018, DEC-019). Each
  // generate block instantiates a module that does not exist, so elaboration stops with its name.
  if ((PARA_CTX_N < 32'd1) || (PARA_CTX_N > 32'd16)) begin : gen_err_ctx_n
    m_vlsit_sha_ERR_ctx_n_out_of_range u_err ();
  end
  if (LPARA_ALG_MAP == 32'd0) begin : gen_err_alg
    m_vlsit_sha_ERR_no_algorithm_built u_err ();
  end
  if (LPARA_EN_256 && ((PARA_S256_UNR == 32'd0) || (PARA_S256_UNR > 32'd64) || ((32'd64 % PARA_S256_UNR) != 32'd0))) begin : gen_err_u256
    m_vlsit_sha_ERR_s256_unr_not_divisor u_err ();
  end
  if (LPARA_EN_512 && ((PARA_S512_UNR == 32'd0) || (PARA_S512_UNR > 32'd80) || ((32'd80 % PARA_S512_UNR) != 32'd0))) begin : gen_err_u512
    m_vlsit_sha_ERR_s512_unr_not_divisor u_err ();
  end
  if (LPARA_EN_KEC && ((PARA_KEC_UNR == 32'd0) || (PARA_KEC_UNR > 32'd24) || ((32'd24 % PARA_KEC_UNR) != 32'd0))) begin : gen_err_ukec
    m_vlsit_sha_ERR_kec_unr_not_divisor u_err ();
  end
  if ((PARA_S256_PIPE != 32'd1) || (PARA_S512_PIPE != 32'd1) || (PARA_KEC_PIPE != ((PARA_MASK != 32'd0) ? 32'd2 : 32'd1))) begin : gen_err_pipe
    m_vlsit_sha_ERR_pipe_stage_unsupported u_err ();
  end
  if ((PARA_AXI_DW != 32'd32) && (PARA_AXI_DW != 32'd64) && (PARA_AXI_DW != 32'd128)) begin : gen_err_dw
    m_vlsit_sha_ERR_axi_dw_value u_err ();
  end
  if ((PARA_AXI_DW == 32'd128) && (LPARA_MAXB != 32'd0)
      && (PARA_EN_SHA3_256 | PARA_EN_SHA3_384 | PARA_EN_SHA3_512 | PARA_EN_SHAKE128 | PARA_EN_SHAKE256)) begin : gen_err_dw128
    m_vlsit_sha_ERR_axi_dw_128_block_size u_err ();
  end
  if (PARA_AXI_AW < 32'd16) begin : gen_err_aw
    m_vlsit_sha_ERR_axi_aw_below_16 u_err ();
  end
  if ((PARA_IN_DEPTH < 32'd4) || (PARA_IN_DEPTH > 32'd1024) || ((PARA_IN_DEPTH & (PARA_IN_DEPTH - 32'd1)) != 32'd0)
      || ((PARA_IN_DEPTH * LPARA_WB) < (LPARA_MAXB + 32'd2 * LPARA_WB))) begin : gen_err_indepth
    m_vlsit_sha_ERR_in_depth u_err ();
  end
  if ((PARA_OUT_DEPTH < 32'd4) || (PARA_OUT_DEPTH > 32'd1024) || ((PARA_OUT_DEPTH & (PARA_OUT_DEPTH - 32'd1)) != 32'd0)
      || ((PARA_OUT_DEPTH * LPARA_WB) < 32'd64)) begin : gen_err_outdepth
    m_vlsit_sha_ERR_out_depth u_err ();
  end
  if (PARA_CTX_MEM != 32'd0) begin : gen_err_ctx_mem
    m_vlsit_sha_ERR_ctx_mem_unsupported u_err ();
  end
  if ((PARA_MASK > 32'd1) || (PARA_SEED_SRC > 32'd1) || ((PARA_SEED_SRC != 32'd0) && (PARA_MASK == 32'd0))) begin : gen_err_mask
    m_vlsit_sha_ERR_mask_value u_err ();
  end
  if ((PARA_MASK != 32'd0) && ((LPARA_EN_KEC == 32'd0) || (PARA_KEC_UNR != 32'd1))) begin : gen_err_mask_kec
    m_vlsit_sha_ERR_mask_needs_keccak_unr1 u_err ();
  end
  if ((PARA_FAULT_DUP > 32'd1) || (PARA_FAULT_PAR > 32'd1) || (PARA_FAULT_REDO > 32'd1) || (PARA_ALARM > 32'd1)) begin : gen_err_fault
    m_vlsit_sha_ERR_fault_value u_err ();
  end
  if ((PARA_ALARM != 32'd0) && (PARA_FAULT_DUP == 32'd0) && (PARA_FAULT_PAR == 32'd0) && (PARA_FAULT_REDO == 32'd0)) begin : gen_err_alarm
    m_vlsit_sha_ERR_alarm_needs_fault u_err ();
  end

  // Reset release of the core domain and of the APB domain: asynchronous assertion, release
  // synchronous to the clock of the domain (CDC-003).
  m_vlsit_rst_sync #(
    .PARA_RST_SYNC_TYPE (32'd2)
  ) u_rst_core (
    .i_clk_dst   (i_clk_core),
    .i_rst_n_src (i_rst_n_core),
    .o_rst_n_dst (w_rst_n_core)
  );

  // Reset release of the APB domain.
  m_vlsit_rst_sync #(
    .PARA_RST_SYNC_TYPE (32'd2)
  ) u_rst_apb (
    .i_clk_dst   (i_clk_apb),
    .i_rst_n_src (i_rst_n_apb),
    .o_rst_n_dst (w_rst_n_apb)
  );

  // Generated APB register block (REF-005, REF-008). The register clock is the core clock; the
  // hardware load ports of the command bits clear the bit when the sequencer has taken it, and
  // the raw interrupt bits are loaded by the interrupt logic. Unused outputs are left open.
  m_vlsit_csr_sha #(
    .PARA_ASYNCHRONOUS   (PARA_CSR_ASYNC),
    .PARA_SHA_SEED_COUNT (32'd8)
  ) u_csr (
    .i_clk_apb                    (i_clk_apb),
    .i_rst_n_apb                  (w_rst_n_apb),
    .i_clk_reg                    (i_clk_core),
    .i_rst_n_reg                  (w_rst_n_core),
    .i_apb_psel                   (i_apb_psel),
    .i_apb_penable                (i_apb_penable),
    .i_apb_pwrite                 (i_apb_pwrite),
    .i_apb_paddr                  (i_apb_paddr),
    .i_apb_pwdata                 (i_apb_pwdata),
    .i_apb_pstrb                  (i_apb_pstrb),
    .i_apb_pprot                  (i_apb_pprot),
    .o_apb_pready                 (o_apb_pready),
    .o_apb_pslverr                (o_apb_pslverr),
    .o_apb_prdata                 (o_apb_prdata),
    .i_protect_en                 (i_protect_en),
    .i_slverr_en                  (i_slverr_en),
    .i_sha_cap0_rev               (4'd1),
    .i_sha_cap0_axiw              (LPARA_AXI_CODE[1:0]),
    .i_sha_cap0_ctxn              (PARA_CTX_N[4:0]),
    .i_sha_cap0_alg               (LPARA_ALG_MAP[11:0]),
    .i_sha_cap1_sdsrc             (PARA_SEED_SRC[0]),
    .i_sha_cap1_dma               (PARA_DMA[0]),
    .i_sha_cap1_zero              (PARA_ZERO[0]),
    .i_sha_cap1_mask              (PARA_MASK[0]),
    .i_sha_cap1_fredo             (PARA_FAULT_REDO[0]),
    .i_sha_cap1_fpar              (PARA_FAULT_PAR[0]),
    .i_sha_cap1_fdup              (PARA_FAULT_DUP[0]),
    .i_sha_cap1_kecunr            (LPARA_CAP_KEC[4:0]),
    .i_sha_cap1_s512unr           (LPARA_CAP_S512[6:0]),
    .i_sha_cap1_s256unr           (LPARA_CAP_S256[6:0]),
    .o_sha_ctrl_dmaen             (w_ctrl_dmaen),
    .o_sha_ctrl_mask              (w_ctrl_mask),
    .o_sha_ctrl_ctxsel            (w_ctrl_ctxsel),
    .o_sha_ctrl_algo              (w_ctrl_algo),
    .o_sha_ctrl_en                (w_ctrl_en),
    .o_sha_cmd_seed               (w_cmd_seed),
    .i_hw_wdata_sha_cmd_seed      (1'b0),
    .i_hw_we_sha_cmd_seed         (w_ack_seed),
    .o_sha_cmd_clear              (w_cmd_clear),
    .i_hw_wdata_sha_cmd_clear     (1'b0),
    .i_hw_we_sha_cmd_clear        (w_ack_clear),
    .o_sha_cmd_srst               (w_cmd_srst),
    .i_hw_wdata_sha_cmd_srst      (1'b0),
    .i_hw_we_sha_cmd_srst         (w_ack_srst),
    .o_sha_cmd_abort              (w_cmd_abort),
    .i_hw_wdata_sha_cmd_abort     (1'b0),
    .i_hw_we_sha_cmd_abort        (w_ack_abort),
    .o_sha_cmd_final              (w_cmd_final),
    .i_hw_wdata_sha_cmd_final     (1'b0),
    .i_hw_we_sha_cmd_final        (w_ack_final),
    .o_sha_cmd_init               (w_cmd_init),
    .i_hw_wdata_sha_cmd_init      (1'b0),
    .i_hw_we_sha_cmd_init         (w_ack_init),
    .o_sha_len_tail               (w_len_tail),
    .o_sha_dmac_tmo               (w_dmac_tmo),
    .o_sha_dmac_burst             (w_dmac_burst),
    .o_sha_sec_resp               (w_sec_resp),
    .o_sha_sec_fredo              (w_sec_fredo),
    .o_sha_sec_fpar               (w_sec_fpar),
    .o_sha_sec_fdup               (w_sec_fdup),
    .o_sha_sec_fault              (w_sec_fault),
    .o_sha_sec_zero               (w_sec_zero),
    .o_sha_seed_wd                (w_seed_wd),
    .i_hw_clr_sha_seed_wd         ({8{w_seed_load}}),
    .i_sha_sts_cstate             (w_sts_cstate),
    .i_sha_sts_seeded             (w_seeded),
    .i_sha_sts_dmaact             (w_dma_act),
    .i_sha_sts_locked             (w_lock),
    .i_sha_sts_ready              (w_sts_ready),
    .i_sha_sts_idle               (w_sts_idle),
    .i_sha_sts_busy               (w_sts_busy),
    .i_sha_lvl_outlvl             (w_out_lvl),
    .i_sha_lvl_inlvl              (w_in_lvl),
    .i_sha_blk_cnt                (w_blk_cnt),
    .i_sha_byte_cnt               (w_byte_cnt),
    .i_sha_dvld_words             (w_dma_dvld),
    .i_sha_err_udf                (w_err_udf),
    .i_sha_err_ovf                (w_err_ovf),
    .i_sha_err_kind               (w_err_kind),
    .i_sha_err_ctx                (w_err_ctx),
    .i_sha_erra_addr              (w_err_addr),
    .o_sha_irq_raw_len            (w_raw_one[7]),
    .i_hw_wdata_sha_irq_raw_len   (w_hw_wd_one[7]),
    .i_hw_we_sha_irq_raw_len      (w_hw_we_one[7]),
    .o_sha_irq_raw_tmo            (w_raw_one[6]),
    .i_hw_wdata_sha_irq_raw_tmo   (w_hw_wd_one[6]),
    .i_hw_we_sha_irq_raw_tmo      (w_hw_we_one[6]),
    .o_sha_irq_raw_ent            (w_raw_one[5]),
    .i_hw_wdata_sha_irq_raw_ent   (w_hw_wd_one[5]),
    .i_hw_we_sha_irq_raw_ent      (w_hw_we_one[5]),
    .o_sha_irq_raw_flt            (w_raw_one[4]),
    .i_hw_wdata_sha_irq_raw_flt   (w_hw_wd_one[4]),
    .i_hw_we_sha_irq_raw_flt      (w_hw_we_one[4]),
    .o_sha_irq_raw_cfg            (w_raw_one[3]),
    .i_hw_wdata_sha_irq_raw_cfg   (w_hw_wd_one[3]),
    .i_hw_we_sha_irq_raw_cfg      (w_hw_we_one[3]),
    .o_sha_irq_raw_axi            (w_raw_one[2]),
    .i_hw_wdata_sha_irq_raw_axi   (w_hw_wd_one[2]),
    .i_hw_we_sha_irq_raw_axi      (w_hw_we_one[2]),
    .o_sha_irq_raw_udf            (w_raw_one[1]),
    .i_hw_wdata_sha_irq_raw_udf   (w_hw_wd_one[1]),
    .i_hw_we_sha_irq_raw_udf      (w_hw_we_one[1]),
    .o_sha_irq_raw_ovf            (w_raw_one[0]),
    .i_hw_wdata_sha_irq_raw_ovf   (w_hw_wd_one[0]),
    .i_hw_we_sha_irq_raw_ovf      (w_hw_we_one[0]),
    .o_sha_irq_raw_cdone          (w_raw_cdone),
    .i_hw_wdata_sha_irq_raw_cdone (w_hw_wd_cdone),
    .i_hw_we_sha_irq_raw_cdone    (w_hw_we_cdone),
    .o_sha_irq_en_len             (w_en_one[7]),
    .o_sha_irq_en_tmo             (w_en_one[6]),
    .o_sha_irq_en_ent             (w_en_one[5]),
    .o_sha_irq_en_flt             (w_en_one[4]),
    .o_sha_irq_en_cfg             (w_en_one[3]),
    .o_sha_irq_en_axi             (w_en_one[2]),
    .o_sha_irq_en_udf             (w_en_one[1]),
    .o_sha_irq_en_ovf             (w_en_one[0]),
    .o_sha_irq_en_cdone           (w_en_cdone),
    .o_sha_irq_inj_len            (w_inj_one[7]),
    .o_sha_irq_inj_tmo            (w_inj_one[6]),
    .o_sha_irq_inj_ent            (w_inj_one[5]),
    .o_sha_irq_inj_flt            (w_inj_one[4]),
    .o_sha_irq_inj_cfg            (w_inj_one[3]),
    .o_sha_irq_inj_axi            (w_inj_one[2]),
    .o_sha_irq_inj_udf            (w_inj_one[1]),
    .o_sha_irq_inj_ovf            (w_inj_one[0]),
    .o_sha_irq_inj_cdone          (w_inj_cdone),
    .i_sha_irq_sts_len            (w_sts_one[7]),
    .i_sha_irq_sts_tmo            (w_sts_one[6]),
    .i_sha_irq_sts_ent            (w_sts_one[5]),
    .i_sha_irq_sts_flt            (w_sts_one[4]),
    .i_sha_irq_sts_cfg            (w_sts_one[3]),
    .i_sha_irq_sts_axi            (w_sts_one[2]),
    .i_sha_irq_sts_udf            (w_sts_one[1]),
    .i_sha_irq_sts_ovf            (w_sts_one[0]),
    .i_sha_irq_sts_cdone          (w_sts_cdone)
  );

  // AXI4 subordinate with the message and digest windows of each context (DEC-003, DEC-012).
  m_vlsit_sha_axi_sub #(
    .PARA_AXI_DW  (PARA_AXI_DW),
    .PARA_AXI_IDW (PARA_AXI_IDW),
    .PARA_AXI_AW  (PARA_AXI_AW),
    .PARA_CTX_N   (PARA_CTX_N)
  ) u_axi_sub (
    .i_clk_core     (i_clk_core),
    .i_rst_n_core   (w_rst_n_core),
    .i_axi_awvalid  (i_axi_awvalid),
    .o_axi_awready  (o_axi_awready),
    .i_axi_awid     (i_axi_awid),
    .i_axi_awaddr   (i_axi_awaddr),
    .i_axi_awlen    (i_axi_awlen),
    .i_axi_awsize   (i_axi_awsize),
    .i_axi_awburst  (i_axi_awburst),
    .i_axi_wvalid   (i_axi_wvalid),
    .o_axi_wready   (o_axi_wready),
    .i_axi_wdata    (i_axi_wdata),
    .i_axi_wstrb    (i_axi_wstrb),
    .i_axi_wlast    (i_axi_wlast),
    .o_axi_bvalid   (o_axi_bvalid),
    .i_axi_bready   (i_axi_bready),
    .o_axi_bid      (o_axi_bid),
    .o_axi_bresp    (o_axi_bresp),
    .i_axi_arvalid  (i_axi_arvalid),
    .o_axi_arready  (o_axi_arready),
    .i_axi_arid     (i_axi_arid),
    .i_axi_araddr   (i_axi_araddr),
    .i_axi_arlen    (i_axi_arlen),
    .i_axi_arsize   (i_axi_arsize),
    .i_axi_arburst  (i_axi_arburst),
    .o_axi_rvalid   (o_axi_rvalid),
    .i_axi_rready   (i_axi_rready),
    .o_axi_rid      (o_axi_rid),
    .o_axi_rdata    (o_axi_rdata),
    .o_axi_rresp    (o_axi_rresp),
    .o_axi_rlast    (o_axi_rlast),
    .o_in_push_en   (w_in_push_en),
    .o_in_push_ctx  (w_in_push_ctx),
    .o_in_push_data (w_in_push_data),
    .i_in_full      (w_in_full),
    .i_ctx_abs      (w_ctx_abs),
    .o_out_pop_en   (w_out_pop_en),
    .o_out_pop_ctx  (w_out_pop_ctx),
    .i_out_pop_data (w_out_pop_data),
    .i_out_empty    (w_out_empty),
    .i_pad_ok       (w_dma_pad_ok),
    .i_lock         (w_lock),
    .i_gate         (w_gate),
    .o_out_beat     (w_out_beat),
    .i_srst         (w_ack_srst),
    .o_ev_ovf       (w_ev_ovf),
    .o_ev_udf       (w_ev_udf),
    .o_ev_axi       (w_ev_axi),
    .o_err_ctx      (w_err_ctx),
    .o_err_kind     (w_err_kind),
    .o_err_ovf      (w_err_ovf),
    .o_err_udf      (w_err_udf),
    .o_err_addr     (w_err_addr)
  );

  // Input FIFOs, one per context (DEC-015); the level of the selected context goes to sha_lvl.
  m_vlsit_sha_ctx_fifo #(
    .PARA_CTX_N      (PARA_CTX_N),
    .PARA_FIFO_DEPTH (PARA_IN_DEPTH),
    .PARA_FIFO_W     (PARA_AXI_DW),
    .PARA_PAR        (PARA_FAULT_PAR)
  ) u_in_fifo (
    .i_clk_core   (i_clk_core),
    .i_rst_n_core (w_rst_n_core),
    .i_push_en    (w_in_push_en),
    .i_push_ctx   (w_in_push_ctx),
    .i_push_data  (w_in_push_data),
    .o_full       (w_in_full),
    .i_pop_en     (w_in_pop_en),
    .i_pop_ctx    (w_in_pop_ctx),
    .o_pop_data   (w_in_pop_data),
    .o_empty      (w_in_empty),
    .i_clr_ctx    (w_clr_ctx),
    .i_lvl_ctx    (w_lvl_ctx),
    .o_lvl        (w_in_lvl),
    .o_par_err    (w_perr_in)
  );

  // Output FIFOs, one per context.
  m_vlsit_sha_ctx_fifo #(
    .PARA_CTX_N      (PARA_CTX_N),
    .PARA_FIFO_DEPTH (PARA_OUT_DEPTH),
    .PARA_FIFO_W     (PARA_AXI_DW),
    .PARA_PAR        (PARA_FAULT_PAR)
  ) u_out_fifo (
    .i_clk_core   (i_clk_core),
    .i_rst_n_core (w_rst_n_core),
    .i_push_en    (w_out_push_en),
    .i_push_ctx   (w_out_push_ctx),
    .i_push_data  (w_out_push_data),
    .o_full       (w_out_full),
    .i_pop_en     (w_out_pop_en),
    .i_pop_ctx    (w_out_pop_ctx),
    .o_pop_data   (w_out_pop_data),
    .o_empty      (w_out_empty),
    .i_clr_ctx    (w_clr_ctx),
    .i_lvl_ctx    (w_lvl_ctx),
    .o_lvl        (w_out_lvl),
    .o_par_err    (w_perr_out)
  );

  // Context sequencer: commands, context table, block assembly, padding and core control.
  m_vlsit_sha_seq #(
    .PARA_CTX_N  (PARA_CTX_N),
    .PARA_AXI_DW (PARA_AXI_DW),
    .PARA_ALG_EN (LPARA_ALG_MAP),
    .PARA_ZERO   (PARA_ZERO),
    .PARA_STW    (LPARA_STW),
    .PARA_KECW   (LPARA_KECW),
    .PARA_MASK   (PARA_MASK),
    .PARA_SEED_SRC (PARA_SEED_SRC),
    .PARA_MAXB   (LPARA_MAXB)
  ) u_seq (
    .i_clk_core    (i_clk_core),
    .i_rst_n_core  (w_rst_n_core),
    .i_ctrl_en     (w_ctrl_en),
    .i_ctrl_algo   (w_ctrl_algo),
    .i_ctrl_ctxsel (w_ctrl_ctxsel),
    .i_len_tail    (w_len_tail),
    .i_sec_zero    (w_sec_zero),
    .i_ctrl_mask   (w_ctrl_mask),
    .i_seeded      (w_seeded),
    .i_sec_redo    (w_redo_en),
    .i_mismatch    (w_mismatch),
    .i_lock        (w_lock),
    .i_wipe        (w_wipe),
    .i_cmd_init    (w_cmd_init),
    .i_cmd_final   (w_cmd_final),
    .i_cmd_abort   (w_cmd_abort),
    .i_cmd_srst    (w_cmd_srst),
    .i_cmd_clear   (w_cmd_clear),
    .i_cmd_seed    (w_cmd_seed),
    .o_ack_init    (w_ack_init),
    .o_ack_final   (w_ack_final),
    .o_ack_abort   (w_ack_abort),
    .o_ack_srst    (w_ack_srst),
    .o_ack_clear   (w_ack_clear),
    .o_ack_seed    (w_ack_seed),
    .o_sts_busy    (w_sts_busy),
    .o_sts_idle    (w_sts_idle),
    .o_sts_ready   (w_sts_ready),
    .o_sts_cstate  (w_sts_cstate),
    .o_blk_cnt     (w_blk_cnt),
    .o_byte_cnt    (w_byte_cnt),
    .o_ev_cdone    (w_ev_cdone),
    .o_ev_cfg      (w_ev_cfg),
    .o_ev_len      (w_ev_len),
    .i_push_ev     (w_in_push_en),
    .i_push_ctx    (w_in_push_ctx),
    .o_ctx_abs     (w_ctx_abs),
    .o_in_pop_en   (w_in_pop_en),
    .o_in_pop_ctx  (w_in_pop_ctx),
    .i_in_pop_data (w_in_pop_data),
    .i_in_empty    (w_in_empty),
    .i_out_empty   (w_out_empty),
    .o_clr_ctx     (w_clr_ctx),
    .o_dma_clr     (w_dma_clr),
    .o_push_flag   (w_push_flag),
    .o_ctx_alg     (w_ctx_alg),
    .i_done_ev     (w_done_ev),
    .i_done_ctx    (w_done_ctx),
    .i_perm_ev     (w_perm_ev),
    .i_perm_ctx    (w_perm_ctx),
    .o_wra_en      (w_wra_en),
    .o_wra_ctx     (w_wra_ctx),
    .o_wra_data    (w_wra_data),
    .o_wrb_en      (w_wrb_en),
    .o_wrb_ctx     (w_wrb_ctx),
    .o_wrb_data    (w_wrb_data),
    .o_rd0_ctx     (w_rd0_ctx),
    .i_rd0_data    (w_rd0_data),
    .o_c256_start  (w_c256_start),
    .o_c256_clr    (w_c256_clr),
    .i_c256_done   (w_c256_done),
    .i_c256_result (w_c256_result),
    .o_c512_start  (w_c512_start),
    .o_c512_clr    (w_c512_clr),
    .i_c512_done   (w_c512_done),
    .i_c512_result (w_c512_result),
    .o_kec_start   (w_kec_start),
    .o_kec_clr     (w_kec_clr),
    .i_kec_done    (w_kec_done),
    .i_kec_result  (w_kec_result),
    .o_core_blk    (w_core_blk),
    .o_core_state  (w_core_state),
    .o_be_done     (w_be_done),
    .o_be_res      (w_be_res),
    .o_pass_first  (w_pass_first),
    .o_pass_second (w_pass_second),
    .o_par_chk     (w_par_chk),
    .o_seed_load   (w_seed_load),
    .o_ev_ent      (w_ev_ent),
    .o_mask_en     (w_mask_en)
  );

  // Context memory: hash state of the contexts that are not in a core.
  m_vlsit_sha_ctxmem #(
    .PARA_CTX_N (PARA_CTX_N),
    .PARA_STW   (LPARA_STW),
    .PARA_PAR   (PARA_FAULT_PAR)
  ) u_ctxmem (
    .i_clk_core (i_clk_core),
    .i_wra_en   (w_wra_en),
    .i_wra_ctx  (w_wra_ctx),
    .i_wra_data (w_wra_data),
    .i_wrb_en   (w_wrb_en),
    .i_wrb_ctx  (w_wrb_ctx),
    .i_wrb_data (w_wrb_data),
    .i_rd0_ctx  (w_rd0_ctx),
    .o_rd0_data (w_rd0_data),
    .i_rd0_chk  (w_par_chk),
    .i_rd1_chk  (w_out_push_en),
    .o_par_err  (w_perr_mem),
    .i_rd1_ctx  (w_rd1_ctx),
    .o_rd1_data (w_rd1_data)
  );

  // Digest pusher: reads the state of a ready context and writes the digest words to its FIFO.
  m_vlsit_sha_outp #(
    .PARA_CTX_N  (PARA_CTX_N),
    .PARA_AXI_DW (PARA_AXI_DW),
    .PARA_STW    (LPARA_STW)
  ) u_outp (
    .i_clk_core   (i_clk_core),
    .i_rst_n_core (w_rst_n_core),
    .i_push_flag  (w_push_flag),
    .i_ctx_alg    (w_ctx_alg),
    .i_clr_ctx    (w_clr_ctx),
    .o_rd_ctx     (w_rd1_ctx),
    .i_rd_data    (w_rd1_data),
    .i_out_full   (w_out_full),
    .o_push_en    (w_out_push_en),
    .o_push_ctx   (w_out_push_ctx),
    .o_push_data  (w_out_push_data),
    .o_done_ev    (w_done_ev),
    .o_done_ctx   (w_done_ctx),
    .o_perm_ev    (w_perm_ev),
    .o_perm_ctx   (w_perm_ctx)
  );

  // SHA-224 and SHA-256 core, built when one of them is enabled; otherwise its signals are tied.
  if (LPARA_EN_256 != 32'd0) begin : gen_c256
    m_vlsit_sha_core256 #(
      .PARA_UNR (PARA_S256_UNR),
      .PARA_PAR (PARA_FAULT_PAR)
    ) u_core256 (
      .i_clk_core   (i_clk_core),
      .i_rst_n_core (w_rst_n_core),
      .i_start      (w_c256_start),
      .i_clr        (w_c256_clr),
      .o_done       (w_c256_done),
      .i_block      (w_core_blk[511:0]),
      .i_state      (w_core_state[255:0]),
      .o_result     (w_c256_result),
      .o_par_err    (w_perr_c256)
    );
  end else begin : gen_no_c256
    // Absent option: tied when the SHA-256 core is not built.
    assign w_c256_done   = 1'b0;
    assign w_c256_result = '0;
    assign w_perr_c256   = 1'b0;
  end

  // SHA-384, SHA-512 and SHA-512/t core, built when one of them is enabled.
  if (LPARA_EN_512 != 32'd0) begin : gen_c512
    m_vlsit_sha_core512 #(
      .PARA_UNR (PARA_S512_UNR),
      .PARA_PAR (PARA_FAULT_PAR)
    ) u_core512 (
      .i_clk_core   (i_clk_core),
      .i_rst_n_core (w_rst_n_core),
      .i_start      (w_c512_start),
      .i_clr        (w_c512_clr),
      .o_done       (w_c512_done),
      .i_block      (w_core_blk[1023:0]),
      .i_state      (w_core_state[511:0]),
      .o_result     (w_c512_result),
      .o_par_err    (w_perr_c512)
    );
  end else begin : gen_no_c512
    // Absent option: tied when the SHA-512 core is not built.
    assign w_c512_done   = 1'b0;
    assign w_c512_result = '0;
    assign w_perr_c512   = 1'b0;
  end

  // Keccak core for SHA-3 and SHAKE, built when one of them is enabled: the plain core, or the
  // masked core with two shares when PARA_MASK = 1 (stage 2b).
  if ((LPARA_EN_KEC != 32'd0) && (PARA_MASK == 32'd0)) begin : gen_kec
    m_vlsit_sha_keccak #(
      .PARA_UNR (PARA_KEC_UNR),
      .PARA_PAR (PARA_FAULT_PAR)
    ) u_keccak (
      .i_clk_core   (i_clk_core),
      .i_rst_n_core (w_rst_n_core),
      .i_start      (w_kec_start),
      .i_clr        (w_kec_clr),
      .o_done       (w_kec_done),
      .i_block      (w_core_blk),
      .i_state      (w_core_state[1599:0]),
      .o_result     (w_kec_result),
      .o_par_err    (w_perr_kec)
    );
  end else if (LPARA_EN_KEC != 32'd0) begin : gen_kec_dom
    m_vlsit_sha_keccak_dom #(
      .PARA_PAR (PARA_FAULT_PAR)
    ) u_keccak (
      .i_clk_core   (i_clk_core),
      .i_rst_n_core (w_rst_n_core),
      .i_start      (w_kec_start),
      .i_clr        (w_kec_clr),
      .o_done       (w_kec_done),
      .i_block      (w_core_blk),
      .i_state      (w_core_state[3199:0]),
      .i_rnd        (w_rnd),
      .i_mask_en    (w_mask_en),
      .o_result     (w_kec_result),
      .o_par_err    (w_perr_kec)
    );
  end else begin : gen_no_kec
    // Absent option: tied when the Keccak core is not built.
    assign w_kec_done   = 1'b0;
    assign w_kec_result = '0;
    assign w_perr_kec   = 1'b0;
  end

  // Random bit source of the masked core: seeded by the seed registers or the entropy port.
  if (PARA_MASK != 32'd0) begin : gen_prng
    m_vlsit_sha_prng #(
      .PARA_SEED_SRC (PARA_SEED_SRC)
    ) u_prng (
      .i_clk_core   (i_clk_core),
      .i_rst_n_core (w_rst_n_core),
      .i_srst       (w_ack_srst),
      .i_seed_load  (w_seed_load),
      .i_seed_wd    (w_seed_wd),
      .i_ent_valid  (i_ent_valid),
      .i_ent_data   (i_ent_data),
      .o_ent_req    (o_ent_req),
      .o_seeded     (w_seeded),
      .o_rnd        (w_rnd)
    );
  end else begin : gen_no_prng
    // Absent option: no random bit source without masking.
    assign o_ent_req = 1'b0;
    assign w_seeded  = 1'b0;
    assign w_rnd     = '0;
  end

  // Duplicate cores for the duplicate-core detection (PARA_FAULT_DUP = 1): the same inputs as the
  // core, compared by the fault logic when the core reports done.
  if ((LPARA_EN_256 != 32'd0) && (PARA_FAULT_DUP != 32'd0)) begin : gen_c256_b
    m_vlsit_sha_core256 #(
      .PARA_UNR (PARA_S256_UNR)
    ) u_core256_b (
      .i_clk_core   (i_clk_core),
      .i_rst_n_core (w_rst_n_core),
      .i_start      (w_c256_start),
      .i_clr        (w_c256_clr),
      .o_done       (w_c256_done_b),
      .i_block      (w_core_blk[511:0]),
      .i_state      (w_core_state[255:0]),
      .o_result     (w_c256_result_b),
      .o_par_err    ()
    );
  end else begin : gen_no_c256_b
    // Absent option: no duplicate of the SHA-256 core.
    assign w_c256_done_b   = 1'b0;
    assign w_c256_result_b = '0;
  end
  if ((LPARA_EN_512 != 32'd0) && (PARA_FAULT_DUP != 32'd0)) begin : gen_c512_b
    m_vlsit_sha_core512 #(
      .PARA_UNR (PARA_S512_UNR)
    ) u_core512_b (
      .i_clk_core   (i_clk_core),
      .i_rst_n_core (w_rst_n_core),
      .i_start      (w_c512_start),
      .i_clr        (w_c512_clr),
      .o_done       (w_c512_done_b),
      .i_block      (w_core_blk[1023:0]),
      .i_state      (w_core_state[511:0]),
      .o_result     (w_c512_result_b),
      .o_par_err    ()
    );
  end else begin : gen_no_c512_b
    // Absent option: no duplicate of the SHA-512 core.
    assign w_c512_done_b   = 1'b0;
    assign w_c512_result_b = '0;
  end
  if ((LPARA_EN_KEC != 32'd0) && (PARA_FAULT_DUP != 32'd0) && (PARA_MASK == 32'd0)) begin : gen_kec_b
    m_vlsit_sha_keccak #(
      .PARA_UNR (PARA_KEC_UNR)
    ) u_keccak_b (
      .i_clk_core   (i_clk_core),
      .i_rst_n_core (w_rst_n_core),
      .i_start      (w_kec_start),
      .i_clr        (w_kec_clr),
      .o_done       (w_kec_done_b),
      .i_block      (w_core_blk),
      .i_state      (w_core_state[1599:0]),
      .o_result     (w_kec_result_b),
      .o_par_err    ()
    );
  end else if ((LPARA_EN_KEC != 32'd0) && (PARA_FAULT_DUP != 32'd0)) begin : gen_kec_dom_b
    // The duplicate of the masked core gets the same random bits, so its shares equal those of the
    // core.
    m_vlsit_sha_keccak_dom #(
      .PARA_PAR (32'd0)
    ) u_keccak_b (
      .i_clk_core   (i_clk_core),
      .i_rst_n_core (w_rst_n_core),
      .i_start      (w_kec_start),
      .i_clr        (w_kec_clr),
      .o_done       (w_kec_done_b),
      .i_block      (w_core_blk),
      .i_state      (w_core_state[3199:0]),
      .i_rnd        (w_rnd),
      .i_mask_en    (w_mask_en),
      .o_result     (w_kec_result_b),
      .o_par_err    ()
    );
  end else begin : gen_no_kec_b
    // Absent option: no duplicate of the Keccak core.
    assign w_kec_done_b   = 1'b0;
    assign w_kec_result_b = '0;
  end

  // Fault detection and responses (stage 2a): compare of the duplicates and of the recompute,
  // parity flags, the fault event, lock, gate, clear and alarm.
  m_vlsit_sha_fault #(
    .PARA_EN_256 (LPARA_EN_256),
    .PARA_EN_512 (LPARA_EN_512),
    .PARA_EN_KEC (LPARA_EN_KEC),
    .PARA_STW    (LPARA_STW),
    .PARA_KECW   (LPARA_KECW),
    .PARA_DUP    (PARA_FAULT_DUP),
    .PARA_PAR    (PARA_FAULT_PAR),
    .PARA_REDO   (PARA_FAULT_REDO),
    .PARA_ALARM  (PARA_ALARM)
  ) u_fault (
    .i_clk_core    (i_clk_core),
    .i_rst_n_core  (w_rst_n_core),
    .i_srst        (w_ack_srst),
    .i_sec_fault   (w_sec_fault),
    .i_sec_fdup    (w_sec_fdup),
    .i_sec_fpar    (w_sec_fpar),
    .i_sec_fredo   (w_sec_fredo),
    .i_sec_resp    (w_sec_resp),
    .i_c256_done   (w_c256_done),
    .i_c256_res    (w_c256_result),
    .i_c256_done_b (w_c256_done_b),
    .i_c256_res_b  (w_c256_result_b),
    .i_c512_done   (w_c512_done),
    .i_c512_res    (w_c512_result),
    .i_c512_done_b (w_c512_done_b),
    .i_c512_res_b  (w_c512_result_b),
    .i_kec_done    (w_kec_done),
    .i_kec_res     (w_kec_result),
    .i_kec_done_b  (w_kec_done_b),
    .i_kec_res_b   (w_kec_result_b),
    .i_be_done     (w_be_done),
    .i_be_res      (w_be_res),
    .i_pass_first  (w_pass_first),
    .i_pass_second (w_pass_second),
    .i_par_err     (w_par_err),
    .o_mismatch    (w_mismatch),
    .o_ev_flt      (w_ev_flt),
    .o_lock        (w_lock),
    .o_gate        (w_gate),
    .o_wipe        (w_wipe),
    .o_alarm_set   (w_alarm_set),
    .o_redo_en     (w_redo_en)
  );
  // Parity error flags of the cores, context memory and FIFOs (zero when PARA_FAULT_PAR = 0).
  assign w_par_err = w_perr_c256 || w_perr_c512 || w_perr_kec || w_perr_mem || w_perr_in || w_perr_out;

  // External DMA handshake, built when PARA_DMA = 1; otherwise the requests are 0.
  if (PARA_DMA != 32'd0) begin : gen_dma
    m_vlsit_sha_dma #(
      .PARA_IN_DEPTH (PARA_IN_DEPTH)
    ) u_dma (
      .i_clk_core    (i_clk_core),
      .i_rst_n_core  (w_rst_n_core),
      .i_en          (w_ctrl_dmaen),
      .i_burst       (w_dmac_burst),
      .i_tmo         (w_dmac_tmo),
      .i_clr         (w_dma_clr),
      .i_in_abs      (w_in_abs_sel),
      .i_in_lvl      (w_in_lvl),
      .i_in_push_ev  (w_in_push_sel),
      .i_out_act     (w_sts_ready),
      .i_out_lvl     (w_out_lvl),
      .i_out_pop_ev  (w_out_pop_sel),
      .i_out_beat_ev (w_out_beat_sel),
      .o_in_req      (o_dma_in_req),
      .i_in_ack      (i_dma_in_ack),
      .o_out_req     (o_dma_out_req),
      .i_out_ack     (i_dma_out_ack),
      .o_act         (w_dma_act),
      .o_dvld        (w_dma_dvld),
      .o_pad_ok      (w_dma_pad_ok),
      .o_ev_tmo      (w_ev_tmo),
      .o_ev_cfg      (w_ev_cfg_dma)
    );
  end else begin : gen_no_dma
    // Absent option: DMA requests and status tied low without DMA.
    assign o_dma_in_req  = 1'b0;
    assign o_dma_out_req = 1'b0;
    assign w_dma_act     = 1'b0;
    assign w_dma_dvld    = 9'd0;
    assign w_dma_pad_ok  = 1'b0;
    assign w_ev_tmo      = 1'b0;
    assign w_ev_cfg_dma  = 1'b0;
  end

  // Selected-context glue: level select, word events of the selected context, the configuration
  // event OR and the entropy request (low in this revision).
  m_vlsit_sha_sel #(
    .PARA_CTX_N (PARA_CTX_N)
  ) u_sel (
    .i_ctxsel       (w_ctrl_ctxsel),
    .o_lvl_ctx      (w_lvl_ctx),
    .i_in_push_en   (w_in_push_en),
    .i_in_push_ctx  (w_in_push_ctx),
    .i_out_pop_en   (w_out_pop_en),
    .i_out_pop_ctx  (w_out_pop_ctx),
    .i_out_beat     (w_out_beat),
    .i_ctx_abs      (w_ctx_abs),
    .o_in_push_sel  (w_in_push_sel),
    .o_out_pop_sel  (w_out_pop_sel),
    .o_out_beat_sel (w_out_beat_sel),
    .o_in_abs_sel   (w_in_abs_sel),
    .i_ev_cfg       (w_ev_cfg),
    .i_ev_cfg_dma   (w_ev_cfg_dma),
    .o_ev_cfg_all   (w_ev_cfg_all),
    .o_ent_req      ()
  );

  // Interrupt logic: events to the raw bits, status and the interrupt and alarm outputs.
  m_vlsit_sha_irq u_irq (
    .i_clk_core    (i_clk_core),
    .i_rst_n_core  (w_rst_n_core),
    .i_ev_one      ({w_ev_len, w_ev_tmo, w_ev_ent, w_ev_flt, w_ev_cfg_all, w_ev_axi, w_ev_udf, w_ev_ovf}),
    .i_ev_cdone    (16'(w_ev_cdone)),
    .i_alarm_set   (w_alarm_set),
    .i_srst        (w_ack_srst),
    .i_raw_one     (w_raw_one),
    .i_raw_cdone   (w_raw_cdone),
    .i_en_one      (w_en_one),
    .i_en_cdone    (w_en_cdone),
    .i_inj_one     (w_inj_one),
    .i_inj_cdone   (w_inj_cdone),
    .o_hw_we_one   (w_hw_we_one),
    .o_hw_wd_one   (w_hw_wd_one),
    .o_hw_we_cdone (w_hw_we_cdone),
    .o_hw_wd_cdone (w_hw_wd_cdone),
    .o_sts_one     (w_sts_one),
    .o_sts_cdone   (w_sts_cdone),
    .o_irq         (o_irq),
    .o_alarm       (o_alarm)
  );

endmodule
