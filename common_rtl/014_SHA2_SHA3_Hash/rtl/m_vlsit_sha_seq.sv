/*
 * Project      : VLSIT Common RTL library
 * Author       : Nguyen Quan and Claude Sonnet 5.5 (user)
 * AI Flow      : VLSIT RTL Generator AI Automation Flow
 * AI Flow Page : https://github.com/nguyenquanicd/VLSIT_RTL_Generator_AI_Model
 * Date         : 2026-11-09
 * Description  : Context sequencer of the SHA2 and SHA3 hash IP. It owns the table of contexts
 *                (state, algorithm, word count, byte count, block count, flags), executes the
 *                commands init, final, abort, clear and soft reset (REQ-FUNC-004 to REQ-
 *                FUNC-009), and runs two engines. The front end assembles the next block of a
 *                context that has enough words (a full block, the padded last block or a SHAKE
 *                permutation) from the input FIFO into a prefetch slot while the back end runs
 *                the previous block. The back end loads the state of the slot context into the
 *                core of its algorithm, waits for the result, stores the state, and marks the
 *                context digest ready after the last block. One block is in flight at a time
 *                and the next one is prepared during it, so a block takes R / UNR + 2 cycles
 *                (13). Words are written whole; the last word of a message is held back until
 *                the final command tells its valid bytes. The digest words are pushed by
 *                m_vlsit_sha_outp. Decisions: DEC-004, DEC-005, DEC-012, DEC-013, DEC-019,
 *                DEC-021, DEC-023, DEC-024, DEC-025, DEC-026, DEC-030, DEC-033, DEC-034, DEC-035.
 */
`timescale 1ns/1ps

module m_vlsit_sha_seq #(
  // Parameter Description: number of contexts.
  // Parameter values: 1 to 16; default is 1.
  // Parameter unit: count
  parameter logic [31:0] PARA_CTX_N = 1,
  // Parameter Description: AXI data width, the width of one message word.
  // Parameter values: 32, 64 or 128; default is 64.
  // Parameter unit: bit
  parameter logic [31:0] PARA_AXI_DW = 64,
  // Parameter Description: mask of the built algorithms; bit n is the algorithm of bit n of the
  // capability field (0 SHA-224, 1 SHA-256, 2 SHA-384, 3 SHA-512, 4 SHA-512/224, 5 SHA-512/256,
  // 6 SHA3-224, 7 SHA3-256, 8 SHA3-384, 9 SHA3-512, 10 SHAKE128, 11 SHAKE256).
  // Parameter values: 12-bit mask, not zero; default is 32'h2 (SHA-256).
  // Parameter unit: none
  parameter logic [31:0] PARA_ALG_EN = 32'h2,
  // Parameter Description: build the clearing of the context state and of the core registers.
  // Parameter values: 0 or 1; default is 1.
  // Parameter unit: none
  parameter logic [31:0] PARA_ZERO = 1,
  // Parameter Description: width of the state word of the context memory.
  // Parameter values: 256, 512 or 1600; default is 256.
  // Parameter unit: bit
  parameter logic [31:0] PARA_STW = 256,
  // Parameter Description: width of the Keccak result: 1600, or 3200 with the masked core.
  // Parameter values: 1600 or 3200; default is 1600.
  // Parameter unit: bit
  parameter logic [31:0] PARA_KECW = 1600,
  // Parameter Description: the masked Keccak core and the seed command are built (stage 2b).
  // Parameter values: 0 or 1; default is 0.
  // Parameter unit: flag
  parameter logic [31:0] PARA_MASK = 0,
  // Parameter Description: seed source of the random bit source: 0 entropy port, 1 seed registers.
  // Parameter values: 0 or 1; default is 1.
  // Parameter unit: flag
  parameter logic [31:0] PARA_SEED_SRC = 1,
  // Parameter Description: size of the largest block of a built algorithm.
  // Parameter values: 64 to 168; default is 64.
  // Parameter unit: byte
  parameter logic [31:0] PARA_MAXB = 64,
  localparam logic [31:0] LPARA_CTX_W = (PARA_CTX_N > 1) ? $clog2(PARA_CTX_N) : 1,
  localparam logic [31:0] LPARA_WB = PARA_AXI_DW / 8,
  localparam logic [31:0] LPARA_BLK_W = 8 * PARA_MAXB,
  localparam logic [31:0] LPARA_CNT_W = $clog2(PARA_MAXB / (PARA_AXI_DW / 8) + 1),
  // Context states, the encoding of the status field cstate of the register block.
  localparam logic [31:0] LPARA_ST_FREE = 32'd0,
  localparam logic [31:0] LPARA_ST_ABS = 32'd1,
  localparam logic [31:0] LPARA_ST_FIN = 32'd2,
  localparam logic [31:0] LPARA_ST_RDY = 32'd3,
  localparam logic [31:0] LPARA_ST_SQZ = 32'd4,
  // Kind of a prefetched item: a full data block, the last block, the second padding block or
  // a SHAKE permutation without data.
  localparam logic [31:0] LPARA_KIND_DATA = 32'd0,
  localparam logic [31:0] LPARA_KIND_FINAL = 32'd1,
  localparam logic [31:0] LPARA_KIND_FIN2 = 32'd2,
  localparam logic [31:0] LPARA_KIND_PERM = 32'd3
) (
  // Clock and reset
  input  wire                        i_clk_core,
  input  wire                        i_rst_n_core,

  // Control fields and commands of the register block
  input  wire                        i_ctrl_en,
  input  wire  [3:0]                 i_ctrl_algo,
  input  wire  [4:0]                 i_ctrl_ctxsel,
  input  wire  [7:0]                 i_len_tail,
  input  wire                        i_sec_zero,
  input  wire                        i_ctrl_mask,
  input  wire                        i_seeded,
  input  wire                        i_sec_redo,
  input  wire                        i_mismatch,
  input  wire                        i_lock,
  input  wire                        i_wipe,
  input  wire                        i_cmd_init,
  input  wire                        i_cmd_final,
  input  wire                        i_cmd_abort,
  input  wire                        i_cmd_srst,
  input  wire                        i_cmd_clear,
  input  wire                        i_cmd_seed,
  output logic                       o_ack_init,
  output logic                       o_ack_final,
  output logic                       o_ack_abort,
  output logic                       o_ack_srst,
  output logic                       o_ack_clear,
  output logic                       o_ack_seed,

  // Status of the selected context for the register block
  output logic                       o_sts_busy,
  output logic                       o_sts_idle,
  output logic                       o_sts_ready,
  output logic [3:0]                 o_sts_cstate,
  output logic [31:0]                o_blk_cnt,
  output logic [31:0]                o_byte_cnt,

  // Events
  output logic [PARA_CTX_N-1:0]      o_ev_cdone,
  output logic                       o_ev_cfg,
  output logic                       o_ev_len,

  // Message words from the AXI4 window and the context acceptance
  input  wire                        i_push_ev,
  input  wire  [LPARA_CTX_W-1:0]     i_push_ctx,
  output logic [PARA_CTX_N-1:0]      o_ctx_abs,

  // Input FIFO pop, output FIFO state and clear requests
  output logic                       o_in_pop_en,
  output logic [LPARA_CTX_W-1:0]     o_in_pop_ctx,
  input  wire  [PARA_AXI_DW-1:0]     i_in_pop_data,
  input  wire  [PARA_CTX_N-1:0]      i_in_empty,
  input  wire  [PARA_CTX_N-1:0]      i_out_empty,
  output logic [PARA_CTX_N-1:0]      o_clr_ctx,
  output logic                       o_dma_clr,

  // Digest pusher
  output logic [PARA_CTX_N-1:0]      o_push_flag,
  output logic [PARA_CTX_N-1:0][3:0] o_ctx_alg,
  input  wire                        i_done_ev,
  input  wire  [LPARA_CTX_W-1:0]     i_done_ctx,
  input  wire                        i_perm_ev,
  input  wire  [LPARA_CTX_W-1:0]     i_perm_ctx,

  // Context memory
  output logic                       o_wra_en,
  output logic [LPARA_CTX_W-1:0]     o_wra_ctx,
  output logic [PARA_STW-1:0]        o_wra_data,
  output logic                       o_wrb_en,
  output logic [LPARA_CTX_W-1:0]     o_wrb_ctx,
  output logic [PARA_STW-1:0]        o_wrb_data,
  output logic [LPARA_CTX_W-1:0]     o_rd0_ctx,
  input  wire  [PARA_STW-1:0]        i_rd0_data,

  // SHA-224 and SHA-256 core
  output logic                       o_c256_start,
  output logic                       o_c256_clr,
  input  wire                        i_c256_done,
  input  wire  [255:0]               i_c256_result,

  // SHA-384, SHA-512 and SHA-512/t core
  output logic                       o_c512_start,
  output logic                       o_c512_clr,
  input  wire                        i_c512_done,
  input  wire  [511:0]               i_c512_result,

  // Keccak core
  output logic                       o_kec_start,
  output logic                       o_kec_clr,
  input  wire                        i_kec_done,
  input  wire  [PARA_KECW-1:0]       i_kec_result,

  // Block and state to the cores
  output logic [1343:0]              o_core_blk,
  output logic [PARA_STW-1:0]        o_core_state,

  // Result of the block that ends and the recompute pass for the fault logic
  output logic                       o_be_done,
  output logic [PARA_STW-1:0]        o_be_res,
  output logic                       o_pass_first,
  output logic                       o_pass_second,
  output logic                       o_par_chk,

  // Masking (stage 2b): seed command strobe, entropy-starved event and mask flag of the item in
  // the core
  output logic                       o_seed_load,
  output logic                       o_ev_ent,
  output logic                       o_mask_en
);

  // FSM states of the front end: IDLE selects a context, POP reads the words of the block from
  // the input FIFO, PUT pads the block and writes it to the prefetch slot. Encoding 3 recovers
  // to IDLE.
  typedef enum logic [1:0] {
    ENUM_ST_IDLE = 2'b00,
    ENUM_ST_POP  = 2'b01,
    ENUM_ST_PUT  = 2'b10
  } fe_state_type_def;

  // FSM states of the back end: IDLE waits for the slot, LOAD starts the core with the state and
  // the block, RUN waits for the result and stores it. Encoding 3 recovers to IDLE.
  typedef enum logic [1:0] {
    ENUM_ST_BIDLE = 2'b00,
    ENUM_ST_BLOAD = 2'b01,
    ENUM_ST_BRUN  = 2'b10
  } be_state_type_def;

  // Internal signal declarations: context table
  logic [PARA_CTX_N-1:0][3:0]  reg_cst;
  logic [PARA_CTX_N-1:0][3:0]  reg_calg;
  logic [PARA_CTX_N-1:0][15:0] reg_ccw;
  logic [PARA_CTX_N-1:0][63:0] reg_ctot;
  logic [PARA_CTX_N-1:0][7:0]  reg_ctail;
  logic [PARA_CTX_N-1:0][31:0] reg_cblk;
  logic [PARA_CTX_N-1:0]       reg_cflast;
  logic [PARA_CTX_N-1:0]       reg_c2nd;
  logic [PARA_CTX_N-1:0]       reg_cperm;
  logic [PARA_CTX_N-1:0]       reg_cpush;
  logic [PARA_CTX_N-1:0]       reg_cpdone;

  logic [PARA_CTX_N-1:0][3:0]  w_cst_nxt;
  logic [PARA_CTX_N-1:0][3:0]  w_calg_nxt;
  logic [PARA_CTX_N-1:0][15:0] w_ccw_nxt;
  logic [PARA_CTX_N-1:0][63:0] w_ctot_nxt;
  logic [PARA_CTX_N-1:0][7:0]  w_ctail_nxt;
  logic [PARA_CTX_N-1:0][31:0] w_cblk_nxt;
  logic [PARA_CTX_N-1:0]       w_cflast_nxt;
  logic [PARA_CTX_N-1:0]       w_c2nd_nxt;
  logic [PARA_CTX_N-1:0]       w_cperm_nxt;
  logic [PARA_CTX_N-1:0]       w_cpush_nxt;
  logic [PARA_CTX_N-1:0]       w_cpdone_nxt;

  // Internal signal declarations: command decode and per-context events
  logic [LPARA_CTX_W-1:0]      w_cx;
  logic                        w_cx_ok;
  logic [3:0]                  w_cx_cst;
  logic                        w_cx_busy;
  logic                        w_alg_ok;
  logic [4:0]                  w_alg_bit;
  logic                        w_zero_en;
  logic                        w_sel_srst;
  logic                        w_sel_abort;
  logic                        w_sel_clear;
  logic                        w_sel_init;
  logic                        w_sel_final;
  logic                        w_sel_seed;
  logic                        w_do_srst;
  logic                        w_do_abort;
  logic                        w_do_clear;
  logic                        w_do_init;
  logic                        w_do_final;
  logic                        w_cfg;
  logic [7:0]                  w_tail_eff;
  logic [PARA_CTX_N-1:0]       w_clr_v;
  logic [PARA_CTX_N-1:0]       w_len_kill;
  logic [PARA_CTX_N-1:0]       w_free_req;
  logic [PARA_CTX_N-1:0]       w_free_v;
  logic [PARA_CTX_N-1:0]       w_init_v;
  logic [PARA_CTX_N-1:0]       w_final_v;
  logic [PARA_CTX_N-1:0]       w_push_v;
  logic [PARA_CTX_N-1:0]       w_done_v;
  logic [PARA_CTX_N-1:0]       w_permev_v;
  logic [PARA_CTX_N-1:0]       w_fe_dec_v;
  logic [PARA_CTX_N-1:0]       w_fe_last_v;
  logic [PARA_CTX_N-1:0]       w_fe_two_v;
  logic [PARA_CTX_N-1:0]       w_fe_fin2_v;
  logic [PARA_CTX_N-1:0]       w_fe_perm_v;
  logic [PARA_CTX_N-1:0]       w_be_cnt_v;
  logic [PARA_CTX_N-1:0]       w_be_fin_v;
  logic [PARA_CTX_N-1:0]       w_be_perm_v;
  logic [LPARA_CTX_W-1:0]      w_free_ctx;
  logic                        w_free_hit;
  logic                        w_swp_wr;
  logic [31:0]                 w_cand;
  logic [LPARA_CTX_W-1:0]      w_swp_ctx_nxt;
  logic [3199:0]               w_iv_full;

  // Internal signal declarations: front end
  fe_state_type_def            reg_fsm_fe_current_state;
  fe_state_type_def            w_fsm_fe_nxt_state;
  logic [LPARA_CTX_W-1:0]      reg_fe_ptr;
  logic [LPARA_CTX_W-1:0]      reg_fe_ctx;
  logic [1:0]                  reg_fe_kind;
  logic [LPARA_CNT_W-1:0]      reg_fe_nw;
  logic [7:0]                  reg_fe_n;
  logic [LPARA_CNT_W-1:0]      reg_fe_cnt;
  logic [LPARA_BLK_W-1:0]      reg_fe_blk;
  logic [PARA_CTX_N-1:0]       w_fe_el;
  logic                        w_fe_hit;
  logic [LPARA_CTX_W-1:0]      w_fe_sel;
  logic [3:0]                  w_k_alg;
  logic [7:0]                  w_k_blkb;
  logic [31:0]                 w_k_bw;
  logic [31:0]                 w_k_rem;
  logic [1:0]                  w_k_kind;
  logic [LPARA_CNT_W-1:0]      w_k_nw;
  logic [7:0]                  w_k_n;
  logic                        w_fe_pop;
  logic                        w_fe_put;
  logic [LPARA_BLK_W-1:0]      w_pad_blk;
  logic                        w_pad_two;
  logic [LPARA_BLK_W-1:0]      w_put_blk;
  logic [LPARA_BLK_W-1:0]      w_mask_blk;
  logic                        w_put_last;

  // Internal signal declarations: prefetch slot and back end
  logic [LPARA_BLK_W-1:0]      reg_pf_blk;
  logic                        reg_pf_valid;
  logic                        w_pf_valid_nxt;
  logic [LPARA_CTX_W-1:0]      reg_pf_ctx;
  logic [3:0]                  reg_pf_alg;
  logic                        reg_pf_last;
  logic                        reg_pf_perm;
  be_state_type_def            reg_fsm_be_current_state;
  be_state_type_def            w_fsm_be_nxt_state;
  logic [LPARA_CTX_W-1:0]      reg_be_ctx;
  logic [3:0]                  reg_be_alg;
  logic                        reg_be_last;
  logic                        reg_be_perm;
  logic                        w_be_done;
  logic                        w_cls256;
  logic                        w_cls512;
  logic                        w_clskec;
  logic                        w_cls256_pf;
  logic                        w_cls512_pf;
  logic                        w_clskec_pf;
  logic                        w_be_alive;
  logic                        w_be_kill;
  logic [PARA_CTX_N-1:0]       w_flt_v;
  logic                        w_be_abort;
  logic                        w_do_seed;
  logic                        w_ent_stall;
  logic                        w_bld;
  logic [PARA_CTX_N-1:0]       w_cmask_nxt;
  logic [PARA_CTX_N-1:0]       reg_cmask;
  logic                        reg_pf_mask;
  logic                        reg_be_mask;
  logic                        reg_ent_rep;
  logic                        w_be_first;
  logic                        w_be_fin;
  logic                        w_bload_keep;
  logic                        reg_redo_wait;
  logic                        reg_be_pass;
  logic [LPARA_CTX_W-1:0]      w_be_cx;
  logic [3199:0]               w_result;
  logic                        w_busy;
  logic                        reg_swp_act;
  logic [LPARA_CTX_W-1:0]      reg_swp_ctx;

  // Block size in bytes of an algorithm: 64 for SHA-224 and SHA-256, 128 for the SHA-512 family,
  // and the rate of the SHA-3 functions (FIPS 180-4 section 1, FIPS 202 table 3).
  function automatic logic [7:0] f_blkb(input logic [3:0] i_alg);
    case (i_alg)
      4'd2,
      4'd3,
      4'd4,
      4'd5:    f_blkb = 8'd128;
      4'd8:    f_blkb = 8'd144;
      4'd9:    f_blkb = 8'd136;
      4'd10:   f_blkb = 8'd104;
      4'd11:   f_blkb = 8'd72;
      4'd12:   f_blkb = 8'd168;
      4'd13:   f_blkb = 8'd136;
      default: f_blkb = 8'd64;
    endcase
  endfunction

  // Initial hash value of each algorithm (FIPS 180-4 section 5.3). State word i is in bits
  // [32 i +: 32] for SHA-224 and SHA-256 and [64 i +: 64] for the others; SHA-3 starts at zero.
  function automatic logic [1599:0] f_iv(input logic [3:0] i_alg);
    case (i_alg)
      4'd0: f_iv = 1600'hbefa4fa464f98fa768581511ffc00b31f70e59393070dd17367cd507c1059ed8;
      4'd1: f_iv = 1600'h5be0cd191f83d9ab9b05688c510e527fa54ff53a3c6ef372bb67ae856a09e667;
      4'd2: f_iv = 1600'h47b5481dbefa4fa4db0c2e0d64f98fa78eb44a876858151167332667ffc00b31152fecd8f70e59399159015a3070dd17629a292a367cd507cbbb9d5dc1059ed8;
      4'd3: f_iv = 1600'h5be0cd19137e21791f83d9abfb41bd6b9b05688c2b3e6c1f510e527fade682d1a54ff53a5f1d36f13c6ef372fe94f82bbb67ae8584caa73b6a09e667f3bcc908;
      4'd4: f_iv = 1600'h1112e6ad91d692a13f9d85a86a1d36c877e36f7304c489420f6d2b697bd44da8679dd514582f9fcf1dfab7ae32ff9c8273e1996689dcd4d68c3d37c819544da2;
      4'd5: f_iv = 1600'heb72ddc81c52ca22b0199fc2c85b8aabe5e1e255386399296283ee2a88effe3963877195940eabd2393b86b6f53b1519f555fa3c84c64c222312194fc2bf72c;
      default: f_iv = '0;
    endcase
  endfunction

  // Command selection: one command per cycle, in the order soft reset, abort, clear, init, final,
  // seed. The others stay pending in the register block until their turn. The decode also checks
  // the selected context and algorithm. A command that cannot be done sets the configuration event.
  always_comb begin : p_com_cmd
    w_cx      = i_ctrl_ctxsel[LPARA_CTX_W-1:0];
    w_cx_ok   = (i_ctrl_ctxsel < 5'(PARA_CTX_N));
    w_cx_cst  = reg_cst[w_cx];
    w_cx_busy = (reg_pf_valid && (reg_pf_ctx == w_cx))
             || ((reg_fsm_be_current_state != ENUM_ST_BIDLE) && (reg_be_ctx == w_cx))
             || ((reg_fsm_fe_current_state != ENUM_ST_IDLE) && (reg_fe_ctx == w_cx));
    w_alg_bit = 5'd31;
    case (i_ctrl_algo)
      4'd0,
      4'd1,
      4'd2,
      4'd3,
      4'd4,
      4'd5:    w_alg_bit = {1'b0, i_ctrl_algo};
      4'd8,
      4'd9,
      4'd10,
      4'd11,
      4'd12,
      4'd13:   w_alg_bit = {1'b0, i_ctrl_algo} - 5'd2;
      default: w_alg_bit = 5'd31;
    endcase
    w_alg_ok   = (w_alg_bit < 5'd12) && PARA_ALG_EN[w_alg_bit];
    w_zero_en  = (PARA_ZERO != 32'd0) && i_sec_zero;
    w_sel_srst  = i_cmd_srst;
    w_sel_abort = !i_cmd_srst && i_cmd_abort;
    w_sel_clear = !i_cmd_srst && !i_cmd_abort && i_cmd_clear;
    w_sel_init  = !i_cmd_srst && !i_cmd_abort && !i_cmd_clear && i_cmd_init;
    w_sel_final = !i_cmd_srst && !i_cmd_abort && !i_cmd_clear && !i_cmd_init && i_cmd_final;
    w_sel_seed  = !i_cmd_srst && !i_cmd_abort && !i_cmd_clear && !i_cmd_init && !i_cmd_final
               && i_cmd_seed;
    w_tail_eff  = (i_len_tail == 8'd0) ? 8'(LPARA_WB) : i_len_tail;
    w_do_srst   = w_sel_srst || i_wipe;
    w_do_seed   = w_sel_seed && (PARA_MASK != 32'd0) && (PARA_SEED_SRC != 32'd0) && !i_lock;
    o_seed_load = w_do_seed;
    w_do_abort  = w_sel_abort && w_cx_ok && !i_lock;
    w_do_clear  = w_sel_clear && w_cx_ok && (PARA_ZERO != 32'd0) && !i_lock;
    w_do_init   = w_sel_init && w_cx_ok && w_alg_ok && (w_cx_cst == LPARA_ST_FREE[3:0]) && !w_cx_busy
               && !i_lock;
    w_do_final  = w_sel_final && w_cx_ok && (w_cx_cst == LPARA_ST_ABS[3:0])
               && (32'(i_len_tail) < LPARA_WB) && !i_lock;
    w_cfg       = (w_sel_abort && !w_cx_ok) || (w_sel_clear && !w_cx_ok) || (w_sel_init && !w_do_init)
               || (w_sel_final && !w_do_final) || (w_sel_seed && !w_do_seed)
               || (i_lock && (w_sel_abort || w_sel_clear));
    o_ack_srst  = w_sel_srst;
    o_ack_abort = w_sel_abort;
    o_ack_clear = w_sel_clear;
    o_ack_init  = w_sel_init;
    o_ack_final = w_sel_final;
    o_ack_seed  = w_sel_seed;
    o_ev_cfg    = w_cfg;
    o_dma_clr   = w_do_srst || w_do_abort;
  end

  // Per-context event vectors: the command target, the pushed word, the digest events and the
  // length limit (a message above 2^61 - 1 bytes is dropped, REQ-FUNC-009).
  always_comb begin : p_com_vec
    w_init_v   = '0;
    w_final_v  = '0;
    w_push_v   = '0;
    w_done_v   = '0;
    w_permev_v = '0;
    w_len_kill = '0;
    w_free_req = '0;
    for (int idx = 0; idx < PARA_CTX_N; idx++) begin
      w_init_v[idx]   = w_do_init && (w_cx == LPARA_CTX_W'(idx));
      w_final_v[idx]  = w_do_final && (w_cx == LPARA_CTX_W'(idx));
      w_push_v[idx]   = i_push_ev && (i_push_ctx == LPARA_CTX_W'(idx));
      w_done_v[idx]   = i_done_ev && (i_done_ctx == LPARA_CTX_W'(idx));
      w_permev_v[idx] = i_perm_ev && (i_perm_ctx == LPARA_CTX_W'(idx));
      w_len_kill[idx] = (reg_ctot[idx][63:61] != 3'b000) && (reg_cst[idx] != LPARA_ST_FREE[3:0]);
      w_free_req[idx] = (reg_cpdone[idx] && i_out_empty[idx] && (reg_cst[idx] == LPARA_ST_RDY[3:0]))
                     || w_len_kill[idx];
    end
  end

  // Arbitration of context memory write port B: the initial value of init, then the zeroing of
  // an aborted or cleared context, then the zeroing of a context that frees itself (the lowest
  // index first), then the zeroing sweep after a soft reset. Without zeroing a free request is
  // granted at once for all contexts.
  always_comb begin : p_com_wrb
    o_wrb_en  = 1'b0;
    o_wrb_ctx = w_cx;
    o_wrb_data = '0;
    w_free_v  = '0;
    w_free_hit = 1'b0;
    w_free_ctx = '0;
    w_swp_wr  = 1'b0;
    w_iv_full = 3200'(f_iv(i_ctrl_algo));
    for (int k = PARA_CTX_N - 1; k >= 0; k--) begin
      if (w_free_req[k]) begin
        w_free_hit = 1'b1;
        w_free_ctx = LPARA_CTX_W'(k);
      end
    end
    if (PARA_ZERO == 32'd0)
      w_free_v = w_free_req;
    casez ({w_do_init, (w_do_abort && w_zero_en) || w_do_clear, w_free_hit && (PARA_ZERO != 32'd0),
            reg_swp_act})
      4'b1???: begin
        o_wrb_en   = 1'b1;
        o_wrb_ctx  = w_cx;
        o_wrb_data = w_iv_full[PARA_STW-1:0];
      end
      4'b01??: begin
        o_wrb_en   = 1'b1;
        o_wrb_ctx  = w_cx;
        o_wrb_data = '0;
      end
      4'b001?: begin
        o_wrb_en   = 1'b1;
        o_wrb_ctx  = w_free_ctx;
        o_wrb_data = '0;
        w_free_v[w_free_ctx] = 1'b1;
      end
      4'b0001: begin
        o_wrb_en   = 1'b1;
        o_wrb_ctx  = reg_swp_ctx;
        o_wrb_data = '0;
        w_swp_wr   = 1'b1;
      end
      default: begin
        o_wrb_en = 1'b0;
      end
    endcase
    w_swp_ctx_nxt = reg_swp_ctx + 1'b1;
  end

  // Context clear vector: a soft reset clears every context; abort and clear command clear the
  // selected one; a freed context and a dropped long message are cleared as well.
  always_comb begin : p_com_clr
    w_clr_v = '0;
    for (int idx = 0; idx < PARA_CTX_N; idx++)
      w_clr_v[idx] = w_do_srst || (w_do_abort && (w_cx == LPARA_CTX_W'(idx)))
                  || (w_do_clear && (w_cx == LPARA_CTX_W'(idx))) || w_free_v[idx];
    o_clr_ctx = w_clr_v;
    o_ev_len  = |w_len_kill;
  end

  // Front end selection: a context has work when it holds more than a block of words (the last
  // word is held back until final), when it is finalizing and has not queued its last block, or
  // when it asks for a SHAKE permutation. The first context after reg_fe_ptr wins (round robin).
  always_comb begin : p_com_fe_sel
    w_fe_el  = '0;
    w_fe_hit = 1'b0;
    w_fe_sel = '0;
    w_cand   = 32'd0;
    for (int idx = 0; idx < PARA_CTX_N; idx++) begin
      w_fe_el[idx] = (reg_cperm[idx])
                  || ((reg_cst[idx] == LPARA_ST_FIN[3:0]) && !reg_cflast[idx])
                  || ((reg_cst[idx] == LPARA_ST_ABS[3:0])
                      && (32'(reg_ccw[idx]) > (32'(f_blkb(reg_calg[idx])) / LPARA_WB)));
    end
    for (int k = PARA_CTX_N - 1; k >= 0; k--) begin
      w_cand = (32'(reg_fe_ptr) + 32'd1 + 32'(k)) % PARA_CTX_N;
      if (w_fe_el[w_cand[LPARA_CTX_W-1:0]]) begin
        w_fe_hit = 1'b1;
        w_fe_sel = w_cand[LPARA_CTX_W-1:0];
      end
    end
  end

  // Item of the selected context: kind, number of words to read and valid bytes of the last
  // block. Bytes left in the context: the words times the word size less the unused bytes of the
  // last word (the tail given by final).
  always_comb begin : p_com_fe_kind
    w_k_alg  = reg_calg[w_fe_sel];
    w_k_blkb = f_blkb(w_k_alg);
    w_k_bw   = 32'(w_k_blkb) / LPARA_WB;
    w_k_rem  = (reg_ccw[w_fe_sel] == 16'd0) ? 32'd0
             : ((32'(reg_ccw[w_fe_sel]) - 32'd1) * LPARA_WB + 32'(reg_ctail[w_fe_sel]));
    w_k_kind = LPARA_KIND_DATA[1:0];
    w_k_nw   = LPARA_CNT_W'(w_k_bw);
    w_k_n    = 8'd0;
    casez ({reg_cperm[w_fe_sel], reg_c2nd[w_fe_sel], (reg_cst[w_fe_sel] == LPARA_ST_ABS[3:0]),
            (w_k_rem >= 32'(w_k_blkb))})
      4'b1???: begin
        w_k_kind = LPARA_KIND_PERM[1:0];
        w_k_nw   = '0;
      end
      4'b01??: begin
        w_k_kind = LPARA_KIND_FIN2[1:0];
        w_k_nw   = '0;
      end
      4'b001?: begin
        w_k_kind = LPARA_KIND_DATA[1:0];
      end
      4'b0001: begin
        w_k_kind = LPARA_KIND_DATA[1:0];
      end
      default: begin
        w_k_kind = LPARA_KIND_FINAL[1:0];
        w_k_nw   = LPARA_CNT_W'(reg_ccw[w_fe_sel]);
        w_k_n    = 8'(w_k_rem);
      end
    endcase
  end

  // Front end FSM: IDLE takes an item when the slot is free and the IP is enabled, POP reads the
  // words, PUT writes the slot. A clear of the item context drops the item.
  always_comb begin : p_com_fe_fsm
    w_fsm_fe_nxt_state = reg_fsm_fe_current_state;
    w_fe_pop = (reg_fsm_fe_current_state == ENUM_ST_POP) && (reg_fe_cnt != reg_fe_nw)
            && !i_in_empty[reg_fe_ctx];
    w_fe_put = (reg_fsm_fe_current_state == ENUM_ST_PUT);
    case (reg_fsm_fe_current_state)
      ENUM_ST_IDLE: begin
        if (w_fe_hit && !reg_pf_valid && i_ctrl_en && !i_lock && !w_clr_v[w_fe_sel])
          w_fsm_fe_nxt_state = ENUM_ST_POP;
      end
      ENUM_ST_POP: begin
        if ((reg_fe_cnt == reg_fe_nw) || (w_fe_pop && ((reg_fe_cnt + 1'b1) == reg_fe_nw)))
          w_fsm_fe_nxt_state = ENUM_ST_PUT;
      end
      ENUM_ST_PUT: w_fsm_fe_nxt_state = ENUM_ST_IDLE;
      default:     w_fsm_fe_nxt_state = ENUM_ST_IDLE;
    endcase
    if (w_clr_v[reg_fe_ctx] && (reg_fsm_fe_current_state != ENUM_ST_IDLE))
      w_fsm_fe_nxt_state = ENUM_ST_IDLE;
    o_in_pop_en  = w_fe_pop;
    o_in_pop_ctx = reg_fe_ctx;
  end

  // Data block mask: the bytes of the assembly buffer beyond the block size of the algorithm are
  // stale words of an earlier item; they are zeroed so that a Keccak block XORed into the state
  // carries no extra bytes (the buffer is as wide as the largest block).
  always_comb begin : p_com_mask
    w_mask_blk = '0;
    for (int idx = 0; idx < PARA_MAXB; idx++) begin
      if (8'(idx) < f_blkb(reg_calg[reg_fe_ctx]))
        w_mask_blk[8*idx +: 8] = reg_fe_blk[8*idx +: 8];
    end
  end

  // Padding of the last block and the slot block: a data block is the masked buffer, a permutation
  // block is zero, the other kinds take the padded block.
  always_comb begin : p_com_put
    w_put_last = 1'b0;
    w_put_blk  = reg_fe_blk;
    case (reg_fe_kind)
      LPARA_KIND_PERM[1:0]: w_put_blk = '0;
      LPARA_KIND_DATA[1:0]: w_put_blk = w_mask_blk;
      default:              w_put_blk = w_pad_blk;
    endcase
    case (reg_fe_kind)
      LPARA_KIND_FIN2[1:0]:  w_put_last = 1'b1;
      LPARA_KIND_FINAL[1:0]: w_put_last = !w_pad_two;
      default:               w_put_last = 1'b0;
    endcase
    w_fe_dec_v   = '0;
    w_fe_last_v  = '0;
    w_fe_two_v   = '0;
    w_fe_fin2_v  = '0;
    w_fe_perm_v  = '0;
    for (int idx = 0; idx < PARA_CTX_N; idx++) begin
      if (w_fe_put && (reg_fe_ctx == LPARA_CTX_W'(idx))) begin
        w_fe_dec_v[idx]  = (reg_fe_kind != LPARA_KIND_PERM[1:0]) && (reg_fe_kind != LPARA_KIND_FIN2[1:0]);
        w_fe_last_v[idx] = w_put_last;
        w_fe_two_v[idx]  = (reg_fe_kind == LPARA_KIND_FINAL[1:0]) && w_pad_two;
        w_fe_fin2_v[idx] = (reg_fe_kind == LPARA_KIND_FIN2[1:0]);
        w_fe_perm_v[idx] = (reg_fe_kind == LPARA_KIND_PERM[1:0]);
      end
    end
  end

  // Back end: class of the core of the slot item and of the item in the core.
  always_comb begin : p_com_cls
    w_cls256_pf = (reg_pf_alg <= 4'd1);
    w_cls512_pf = (reg_pf_alg >= 4'd2) && (reg_pf_alg <= 4'd5);
    w_clskec_pf = (reg_pf_alg >= 4'd8);
    w_cls256    = (reg_be_alg <= 4'd1);
    w_cls512    = (reg_be_alg >= 4'd2) && (reg_be_alg <= 4'd5);
    w_clskec    = (reg_be_alg >= 4'd8);
  end

  // Back end FSM: IDLE to LOAD when the slot holds an item; LOAD to RUN after the start; RUN ends
  // when the core of the item reports done (the state is stored in that cycle), then LOAD again
  // at once if the slot holds the next item, otherwise IDLE. A soft reset returns to IDLE.
  always_comb begin : p_com_be_fsm
    w_be_done = (reg_fsm_be_current_state == ENUM_ST_BRUN)
             && ((w_cls256 && i_c256_done) || (w_cls512 && i_c512_done) || (w_clskec && i_kec_done));
    w_ent_stall = (reg_fsm_be_current_state == ENUM_ST_BLOAD) && reg_pf_mask && !i_seeded;
    w_bld       = (reg_fsm_be_current_state == ENUM_ST_BLOAD) && !w_ent_stall;
    w_fsm_be_nxt_state = reg_fsm_be_current_state;
    case (reg_fsm_be_current_state)
      ENUM_ST_BIDLE: begin
        if (reg_pf_valid && !w_clr_v[reg_pf_ctx])
          w_fsm_be_nxt_state = ENUM_ST_BLOAD;
      end
      ENUM_ST_BLOAD: w_fsm_be_nxt_state = w_ent_stall ? ENUM_ST_BLOAD : ENUM_ST_BRUN;
      ENUM_ST_BRUN: begin
        if (w_be_done)
          w_fsm_be_nxt_state = (reg_pf_valid && !w_clr_v[reg_pf_ctx]) ? ENUM_ST_BLOAD : ENUM_ST_BIDLE;
      end
      default: w_fsm_be_nxt_state = ENUM_ST_BIDLE;
    endcase
    // Abort, clear or free of the context that the back end loads or runs (DEC-030): the core
    // is cleared and stops at once, the back end returns to IDLE, init is possible next cycle.
    w_be_cx    = (reg_fsm_be_current_state == ENUM_ST_BLOAD) ? reg_pf_ctx : reg_be_ctx;
    w_be_abort = (reg_fsm_be_current_state != ENUM_ST_BIDLE) && w_clr_v[w_be_cx];
    if (w_do_srst || w_be_abort)
      w_fsm_be_nxt_state = ENUM_ST_BIDLE;
    w_be_alive = (reg_cst[reg_be_ctx] != LPARA_ST_FREE[3:0]);
    o_c256_start = w_bld && w_cls256_pf && !w_be_abort;
    o_c512_start = w_bld && w_cls512_pf && !w_be_abort;
    o_kec_start  = w_bld && w_clskec_pf && !w_be_abort;
    o_mask_en    = (reg_fsm_be_current_state == ENUM_ST_BLOAD) ? reg_pf_mask : reg_be_mask;
    o_ev_ent     = w_ent_stall && !reg_ent_rep;
    o_c256_clr   = w_do_srst || w_be_abort || (w_be_done && w_cls256 && w_zero_en);
    o_c512_clr   = w_do_srst || w_be_abort || (w_be_done && w_cls512 && w_zero_en);
    o_kec_clr    = w_do_srst || w_be_abort || (w_be_done && w_clskec && w_zero_en);
    o_core_blk   = 1344'(reg_pf_blk);
    o_core_state = i_rd0_data;
    o_rd0_ctx    = reg_pf_ctx;
    w_result     = '0;
    case ({w_cls256, w_cls512, w_clskec})
      3'b100:  w_result = 3200'(i_c256_result);
      3'b010:  w_result = 3200'(i_c512_result);
      3'b001:  w_result = 3200'(i_kec_result);
      default: w_result = '0;
    endcase
    // A zero write of port B to the same context in the same cycle (abort, clear, self-free) wins:
    // the result of the block that ends now is not written, so no message data is left in memory.
    w_be_kill  = o_wrb_en && (o_wrb_ctx == reg_be_ctx);
    // Recompute (DEC-035): with i_sec_redo a block runs twice. The first pass only stores its
    // result in the fault logic; the second pass is compared with it and completes the block.
    w_be_first = w_be_done && reg_redo_wait && !reg_be_pass;
    w_be_fin   = w_be_done && !w_be_first;
    o_wra_en   = w_be_fin && w_be_alive && !w_be_kill && !i_mismatch;
    o_be_done  = w_be_done;
    o_be_res   = w_result[PARA_STW-1:0];
    o_pass_first  = reg_redo_wait && !reg_be_pass;
    o_pass_second = reg_be_pass;
    o_par_chk  = (reg_fsm_be_current_state == ENUM_ST_BLOAD);
    o_wra_ctx  = reg_be_ctx;
    o_wra_data = w_result[PARA_STW-1:0];
    w_be_cnt_v  = '0;
    w_be_fin_v  = '0;
    w_be_perm_v = '0;
    w_flt_v     = '0;
    for (int idx = 0; idx < PARA_CTX_N; idx++) begin
      if (w_be_fin && w_be_alive && !i_mismatch && (reg_be_ctx == LPARA_CTX_W'(idx))) begin
        w_be_cnt_v[idx]  = !reg_be_perm;
        w_be_fin_v[idx]  = reg_be_last;
        w_be_perm_v[idx] = reg_be_perm;
      end
      // A block with a compare mismatch is dropped, its context goes to the fault state (DEC-033).
      w_flt_v[idx] = w_be_done && w_be_alive && i_mismatch && (reg_be_ctx == LPARA_CTX_W'(idx));
    end
  end

  // Next values of the context table. Priority for the state: clear, init, final, last block
  // done, permutation requested. The word count follows the pushed words and the words read for
  // an item; the byte count follows the pushed words and is corrected by final for the unused
  // bytes of the last word.
  always_comb begin : p_com_ctx
    w_cst_nxt    = reg_cst;
    w_calg_nxt   = reg_calg;
    w_ccw_nxt    = reg_ccw;
    w_ctot_nxt   = reg_ctot;
    w_ctail_nxt  = reg_ctail;
    w_cblk_nxt   = reg_cblk;
    w_cflast_nxt = reg_cflast;
    w_c2nd_nxt   = reg_c2nd;
    w_cperm_nxt  = reg_cperm;
    w_cpush_nxt  = reg_cpush;
    w_cpdone_nxt = reg_cpdone;
    w_cmask_nxt  = reg_cmask;
    for (int idx = 0; idx < PARA_CTX_N; idx++) begin
      if (w_push_v[idx]) begin
        w_ccw_nxt[idx]  = w_ccw_nxt[idx] + 16'd1;
        w_ctot_nxt[idx] = w_ctot_nxt[idx] + 64'(LPARA_WB);
      end
      if (w_fe_dec_v[idx])
        w_ccw_nxt[idx] = w_ccw_nxt[idx] - 16'(reg_fe_nw);
      if (w_final_v[idx]) begin
        w_cst_nxt[idx]   = LPARA_ST_FIN[3:0];
        w_ctail_nxt[idx] = w_tail_eff;
        if (w_ctot_nxt[idx] != 64'd0)
          w_ctot_nxt[idx] = w_ctot_nxt[idx] - 64'(LPARA_WB) + 64'(w_tail_eff);
      end
      if (w_be_cnt_v[idx])
        w_cblk_nxt[idx] = reg_cblk[idx] + 32'd1;
      if (w_fe_last_v[idx])
        w_cflast_nxt[idx] = 1'b1;
      if (w_fe_two_v[idx])
        w_c2nd_nxt[idx] = 1'b1;
      if (w_fe_fin2_v[idx])
        w_c2nd_nxt[idx] = 1'b0;
      if (w_fe_perm_v[idx])
        w_cperm_nxt[idx] = 1'b0;
      if (w_be_fin_v[idx]) begin
        w_cst_nxt[idx]  = LPARA_ST_RDY[3:0];
        w_cpush_nxt[idx] = 1'b1;
      end
      if (w_be_perm_v[idx])
        w_cpush_nxt[idx] = 1'b1;
      if (w_done_v[idx]) begin
        w_cpush_nxt[idx] = 1'b0;
        w_cpdone_nxt[idx] = 1'b1;
      end
      if (w_permev_v[idx]) begin
        w_cpush_nxt[idx] = 1'b0;
        w_cperm_nxt[idx] = 1'b1;
        w_cst_nxt[idx]   = LPARA_ST_SQZ[3:0];
      end
      if (w_init_v[idx]) begin
        w_cst_nxt[idx]    = LPARA_ST_ABS[3:0];
        w_calg_nxt[idx]   = i_ctrl_algo;
        w_ccw_nxt[idx]    = 16'd0;
        w_ctot_nxt[idx]   = 64'd0;
        w_ctail_nxt[idx]  = 8'd0;
        w_cblk_nxt[idx]   = 32'd0;
        w_cflast_nxt[idx] = 1'b0;
        w_c2nd_nxt[idx]   = 1'b0;
        w_cperm_nxt[idx]  = 1'b0;
        w_cpush_nxt[idx]  = 1'b0;
        w_cpdone_nxt[idx] = 1'b0;
        w_cmask_nxt[idx]  = (PARA_MASK != 32'd0) && i_ctrl_mask && (i_ctrl_algo >= 4'd8);
      end
      if (w_flt_v[idx])
        w_cst_nxt[idx]    = 4'hF;
      if (w_clr_v[idx]) begin
        w_cst_nxt[idx]    = LPARA_ST_FREE[3:0];
        w_ccw_nxt[idx]    = 16'd0;
        w_ctot_nxt[idx]   = 64'd0;
        w_cflast_nxt[idx] = 1'b0;
        w_c2nd_nxt[idx]   = 1'b0;
        w_cperm_nxt[idx]  = 1'b0;
        w_cpush_nxt[idx]  = 1'b0;
        w_cpdone_nxt[idx] = 1'b0;
      end
    end
  end

  // Outputs of the context table: the acceptance of message words, the algorithm and the
  // push flag for the digest pusher, and the events of finished messages.
  always_comb begin : p_com_out
    o_ctx_abs   = '0;
    for (int idx = 0; idx < PARA_CTX_N; idx++)
      o_ctx_abs[idx] = (reg_cst[idx] == LPARA_ST_ABS[3:0]) && !w_len_kill[idx];
    o_push_flag = reg_cpush;
    o_ctx_alg   = reg_calg;
    o_ev_cdone  = w_be_fin_v;
  end

  // Status of the selected context and of the IP. busy: an item is in the front end, in the slot
  // or in a core. idle: not busy and no context holds words. An invalid selection reads as free.
  always_comb begin : p_com_sts
    w_busy       = (reg_fsm_fe_current_state != ENUM_ST_IDLE) || reg_pf_valid
                || (reg_fsm_be_current_state != ENUM_ST_BIDLE);
    o_sts_busy   = w_busy;
    o_sts_idle   = !w_busy;
    o_sts_cstate = w_cx_ok ? reg_cst[w_cx] : LPARA_ST_FREE[3:0];
    o_sts_ready  = w_cx_ok && ((reg_cst[w_cx] == LPARA_ST_RDY[3:0]) || (reg_cst[w_cx] == LPARA_ST_SQZ[3:0]));
    o_blk_cnt    = w_cx_ok ? reg_cblk[w_cx] : 32'd0;
    o_byte_cnt   = w_cx_ok ? reg_ctot[w_cx][31:0] : 32'd0;
    for (int idx = 0; idx < PARA_CTX_N; idx++) begin
      if (reg_ccw[idx] != 16'd0)
        o_sts_idle = 1'b0;
    end
  end

  // Context table registers: control state, reset to free.
  always_ff @(posedge i_clk_core, negedge i_rst_n_core) begin : p_ff_ctx
    if (!i_rst_n_core) begin
      reg_cst    <= '0;
      reg_calg   <= '0;
      reg_ccw    <= '0;
      reg_ctot   <= '0;
      reg_ctail  <= '0;
      reg_cblk   <= '0;
      reg_cflast <= '0;
      reg_c2nd   <= '0;
      reg_cperm  <= '0;
      reg_cpush  <= '0;
      reg_cpdone <= '0;
      reg_cmask  <= '0;
    end else begin
      reg_cst    <= w_cst_nxt;
      reg_calg   <= w_calg_nxt;
      reg_ccw    <= w_ccw_nxt;
      reg_ctot   <= w_ctot_nxt;
      reg_ctail  <= w_ctail_nxt;
      reg_cblk   <= w_cblk_nxt;
      reg_cflast <= w_cflast_nxt;
      reg_c2nd   <= w_c2nd_nxt;
      reg_cperm  <= w_cperm_nxt;
      reg_cpush  <= w_cpush_nxt;
      reg_cpdone <= w_cpdone_nxt;
      reg_cmask  <= w_cmask_nxt;
    end
  end

  // Front end state register.
  always_ff @(posedge i_clk_core, negedge i_rst_n_core) begin : p_ff_fsm_fe
    if (!i_rst_n_core)
      reg_fsm_fe_current_state <= ENUM_ST_IDLE;
    else
      reg_fsm_fe_current_state <= w_fsm_fe_nxt_state;
  end

  // Back end state register.
  always_ff @(posedge i_clk_core, negedge i_rst_n_core) begin : p_ff_fsm_be
    if (!i_rst_n_core)
      reg_fsm_be_current_state <= ENUM_ST_BIDLE;
    else
      reg_fsm_be_current_state <= w_fsm_be_nxt_state;
  end

  // Front end registers: the item taken in IDLE, the word counter, the sweep of the zeroing and
  // the round-robin pointer. They are control state and reset.
  always_ff @(posedge i_clk_core, negedge i_rst_n_core) begin : p_ff_fe
    if (!i_rst_n_core) begin
      reg_fe_ptr  <= '0;
      reg_fe_ctx  <= '0;
      reg_fe_kind <= '0;
      reg_fe_nw   <= '0;
      reg_fe_n    <= '0;
      reg_fe_cnt  <= '0;
      reg_swp_act <= 1'b0;
      reg_swp_ctx <= '0;
    end else begin
      if ((reg_fsm_fe_current_state == ENUM_ST_IDLE) && w_fe_hit && !reg_pf_valid && i_ctrl_en) begin
        reg_fe_ptr  <= w_fe_sel;
        reg_fe_ctx  <= w_fe_sel;
        reg_fe_kind <= w_k_kind;
        reg_fe_nw   <= w_k_nw;
        reg_fe_n    <= w_k_n;
        reg_fe_cnt  <= '0;
      end
      if (w_fe_pop)
        reg_fe_cnt <= reg_fe_cnt + 1'b1;
      if ((w_sel_srst && w_zero_en) || (i_wipe && (PARA_ZERO != 32'd0))) begin
        reg_swp_act <= 1'b1;
        reg_swp_ctx <= '0;
      end else if (w_swp_wr) begin
        reg_swp_ctx <= w_swp_ctx_nxt;
        if (32'(reg_swp_ctx) == (PARA_CTX_N - 32'd1))
          reg_swp_act <= 1'b0;
      end
    end
  end

  // Block assembly buffer: the words popped from the input FIFO, resetless because it is read
  // only after the front end has loaded every word of the item (SEQ-04).
  always_ff @(posedge i_clk_core) begin : p_ff_fe_blk
    if (w_fe_pop)
      reg_fe_blk[PARA_AXI_DW*reg_fe_cnt +: PARA_AXI_DW] <= i_in_pop_data;
  end

  // Prefetch slot: written by the PUT state, emptied when the back end loads the core. The
  // block is resetless; the valid flag and the item context are control state.
  always_ff @(posedge i_clk_core) begin : p_ff_pf_blk
    if (w_fe_put)
      reg_pf_blk <= w_put_blk;
  end

  // Slot valid flag, next value: cleared by a soft reset, by the clear of the item context and
  // when the back end loads the core; set when the front end writes the slot.
  always_comb begin : p_com_pf_nxt
    w_pf_valid_nxt = reg_pf_valid;
    w_bload_keep = w_bld && i_sec_redo && !reg_redo_wait;
    casez ({(w_do_srst || (w_fe_put && w_clr_v[reg_fe_ctx])
             || (reg_pf_valid && w_clr_v[reg_pf_ctx])),
            w_fe_put, (w_bld && !w_bload_keep)})
      3'b1??:  w_pf_valid_nxt = 1'b0;
      3'b01?:  w_pf_valid_nxt = 1'b1;
      3'b001:  w_pf_valid_nxt = 1'b0;
      default: w_pf_valid_nxt = reg_pf_valid;
    endcase
  end

  // Slot control: the valid flag and the context of the item in the slot, and the context of the
  // item in the core (control state, reset).
  always_ff @(posedge i_clk_core, negedge i_rst_n_core) begin : p_ff_pf
    if (!i_rst_n_core) begin
      reg_pf_valid <= 1'b0;
      reg_pf_ctx   <= '0;
      reg_pf_alg   <= '0;
      reg_pf_last  <= 1'b0;
      reg_pf_perm  <= 1'b0;
      reg_be_ctx   <= '0;
      reg_be_alg   <= '0;
      reg_be_last  <= 1'b0;
      reg_be_perm  <= 1'b0;
      reg_redo_wait <= 1'b0;
      reg_be_pass  <= 1'b0;
      reg_pf_mask  <= 1'b0;
      reg_be_mask  <= 1'b0;
      reg_ent_rep  <= 1'b0;
    end else begin
      reg_ent_rep <= w_ent_stall;
      reg_pf_valid <= w_pf_valid_nxt;
      if (w_fe_put) begin
        reg_pf_ctx  <= reg_fe_ctx;
        reg_pf_alg  <= reg_calg[reg_fe_ctx];
        reg_pf_last <= w_put_last;
        reg_pf_perm <= (reg_fe_kind == LPARA_KIND_PERM[1:0]);
        reg_pf_mask <= reg_cmask[reg_fe_ctx];
      end
      casez ({(w_do_srst || w_be_abort), w_bld, (w_be_done && reg_be_pass)})
        3'b1??: begin
          reg_redo_wait <= 1'b0;
          reg_be_pass   <= 1'b0;
        end
        3'b01?: begin
          reg_redo_wait <= i_sec_redo && !reg_redo_wait;
          reg_be_pass   <= reg_redo_wait;
        end
        3'b001:  reg_be_pass <= 1'b0;
        default: begin
          // Control state of the recompute pass keeps its value.
        end
      endcase
      if (reg_fsm_be_current_state == ENUM_ST_BLOAD) begin
        reg_be_ctx  <= reg_pf_ctx;
        reg_be_alg  <= reg_pf_alg;
        reg_be_last <= reg_pf_last;
        reg_be_perm <= reg_pf_perm;
        reg_be_mask <= reg_pf_mask;
      end
    end
  end

  // Padding of the last block of the context being read: the valid bytes are those counted when
  // the item was taken, the second pass is the second padding block of SHA-2.
  m_vlsit_sha_pad #(
    .PARA_MAXB (PARA_MAXB)
  ) u_pad (
    .i_alg    (reg_calg[reg_fe_ctx]),
    .i_blk    (reg_fe_blk),
    .i_n      (reg_fe_n),
    .i_second (reg_fe_kind == LPARA_KIND_FIN2[1:0]),
    .i_tot    (reg_ctot[reg_fe_ctx]),
    .o_blk    (w_pad_blk),
    .o_two    (w_pad_two)
  );

endmodule
