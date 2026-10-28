/*
 * Project      : VLSIT Common RTL library
 * Author       : Nguyen Quan and Claude Sonnet 5.5 (user)
 * AI Flow      : VLSIT RTL Generator AI Automation Flow
 * AI Flow Page : https://github.com/nguyenquanicd/VLSIT_RTL_Generator_AI_Model
 * Date         : 2026-10-26
 * Description  : Read slot table of the AXI2TLUL bridge. It reserves one slot per read beat (the
 *                slot index is the TL-UL tag), keeps the slots of one AXI ID in request order in an
 *                ID context, and returns the beats on the AXI R channel: the data of the oldest
 *                slot of a context goes straight to the R register when the R path can take it
 *                (bypass) and is otherwise written to the storage and read back later. The R path
 *                serves one burst at a time, so R beats of different bursts are never interleaved;
 *                an idle R path prefers a context whose data is stored, round-robin. An ID context
 *                stays allocated while the request engine issues a burst of that ID (pin), and a
 *                burst reserves its slots at its first beat, so the table cannot deadlock. All R
 *                outputs are flip-flops.
 */
`timescale 1ns/1ps

module m_vlsit_axi2tlul_rd_rob #(
  // Parameter Description: number of read slots, the maximum number of outstanding read beats.
  // Parameter values: power of two from 2 to 128; default is 16.
  // Parameter unit: count
  parameter logic [31:0] PARA_NUM_RD = 16,
  // Parameter Description: number of ID contexts, the AXI IDs that can have read beats in flight.
  // Parameter values: 1 to PARA_NUM_RD; default is 4.
  // Parameter unit: count
  parameter logic [31:0] PARA_NUM_ID_RD = 4,
  // Parameter Description: width of the AXI ID.
  // Parameter values: 1 to 32; default is 8.
  // Parameter unit: bit
  parameter logic [31:0] PARA_AXI_ID_W = 8,
  // Parameter Description: width of the read data.
  // Parameter values: 32, 64, 128, 256, 512, or 1024; default is 32.
  // Parameter unit: bit
  parameter logic [31:0] PARA_DATA_W = 32,
  localparam logic [31:0] LPARA_IDX_W = $clog2(PARA_NUM_RD),
  localparam logic [31:0] LPARA_CNT_W = $clog2(PARA_NUM_RD) + 1,
  localparam logic [31:0] LPARA_CTX_W = (PARA_NUM_ID_RD > 1) ? $clog2(PARA_NUM_ID_RD) : 1
) (
  // Clock and reset
  input  wire                      i_clk_main,
  input  wire                      i_rst_n_main,

  // Slot allocation from the read request engine
  input  wire                      i_alloc_en,
  input  wire                      i_alloc_gen,
  input  wire  [PARA_AXI_ID_W-1:0] i_alloc_id,
  input  wire                      i_alloc_last,
  input  wire  [LPARA_CNT_W-1:0]   i_alloc_need,
  input  wire                      i_pin_valid,
  input  wire  [PARA_AXI_ID_W-1:0] i_pin_id,
  output logic                     o_alloc_ok,
  output logic [LPARA_IDX_W-1:0]   o_alloc_slot,

  // Completion from the response decoder
  input  wire                      i_cmp_valid,
  input  wire  [LPARA_IDX_W-1:0]   i_cmp_idx,
  input  wire                      i_cmp_err,
  input  wire  [PARA_DATA_W-1:0]   i_cmp_data,
  output logic                     o_cmp_orphan,

  // Read data storage
  output logic                     o_store_wr_en,
  output logic [LPARA_IDX_W-1:0]   o_store_wr_addr,
  output logic [PARA_DATA_W-1:0]   o_store_wr_data,
  output logic                     o_store_rd_en,
  output logic [LPARA_IDX_W-1:0]   o_store_rd_addr,
  input  wire  [PARA_DATA_W-1:0]   i_store_rd_data,

  // AXI R channel
  output logic                     o_axi_rvalid,
  input  wire                      i_axi_rready,
  output logic [PARA_AXI_ID_W-1:0] o_axi_rid,
  output logic [PARA_DATA_W-1:0]   o_axi_rdata,
  output logic [1:0]               o_axi_rresp,
  output logic                     o_axi_rlast
);

  // Internal signal declarations: slot table (flags per slot, ID and link per slot).
  logic [PARA_NUM_RD-1:0]       reg_busy;
  logic [PARA_NUM_RD-1:0]       reg_pend;
  logic [PARA_NUM_RD-1:0]       reg_done;
  logic [PARA_NUM_RD-1:0]       reg_err;
  logic [PARA_NUM_RD-1:0]       reg_gen;
  logic [PARA_NUM_RD-1:0]       reg_last;
  logic [PARA_AXI_ID_W-1:0]     reg_slot_id [PARA_NUM_RD];
  logic [LPARA_IDX_W-1:0]       reg_nxt_slot [PARA_NUM_RD];
  logic [PARA_NUM_RD-1:0]       w_busy_nxt;
  logic [PARA_NUM_RD-1:0]       w_pend_nxt;
  logic [PARA_NUM_RD-1:0]       w_done_nxt;
  logic [PARA_NUM_RD-1:0]       w_err_nxt;
  logic [PARA_NUM_RD-1:0]       w_gen_nxt;
  logic [PARA_NUM_RD-1:0]       w_last_nxt;

  // ID contexts.
  logic [PARA_NUM_ID_RD-1:0]    reg_ctx_valid;
  logic [PARA_NUM_ID_RD-1:0]    reg_ctx_empty;
  logic [PARA_AXI_ID_W-1:0]     reg_ctx_id [PARA_NUM_ID_RD];
  logic [LPARA_IDX_W-1:0]       reg_ctx_head [PARA_NUM_ID_RD];
  logic [LPARA_IDX_W-1:0]       reg_ctx_tail [PARA_NUM_ID_RD];
  logic [PARA_NUM_ID_RD-1:0]    w_ctx_valid_nxt;
  logic [PARA_NUM_ID_RD-1:0]    w_ctx_empty_nxt;
  logic [PARA_AXI_ID_W-1:0]     w_ctx_id_nxt [PARA_NUM_ID_RD];
  logic [LPARA_IDX_W-1:0]       w_ctx_head_nxt [PARA_NUM_ID_RD];
  logic [LPARA_IDX_W-1:0]       w_ctx_tail_nxt [PARA_NUM_ID_RD];

  // Free count, R path, prefetch stage, and R register.
  logic [LPARA_CNT_W-1:0]       reg_free_cnt;
  logic [LPARA_CNT_W-1:0]       w_free_cnt_nxt;
  logic                         reg_r_active;
  logic [PARA_AXI_ID_W-1:0]     reg_r_id;
  logic [LPARA_CTX_W-1:0]       reg_rr_ptr;
  logic                         w_r_active_nxt;
  logic [PARA_AXI_ID_W-1:0]     w_r_id_nxt;
  logic [LPARA_CTX_W-1:0]       w_rr_ptr_nxt;
  logic                         reg_pf_valid;
  logic                         reg_pf_gen;
  logic                         reg_pf_err;
  logic                         reg_pf_last;
  logic [PARA_AXI_ID_W-1:0]     reg_pf_id;
  logic                         w_pf_valid_nxt;
  logic                         w_pf_gen_nxt;
  logic                         w_pf_err_nxt;
  logic                         w_pf_last_nxt;
  logic [PARA_AXI_ID_W-1:0]     w_pf_id_nxt;
  logic                         reg_rvalid;
  logic [PARA_AXI_ID_W-1:0]     reg_rid;
  logic [PARA_DATA_W-1:0]       reg_rdata;
  logic [1:0]                   reg_rresp;
  logic                         reg_rlast;
  logic                         w_rvalid_nxt;
  logic [PARA_AXI_ID_W-1:0]     w_rid_nxt;
  logic [PARA_DATA_W-1:0]       w_rdata_nxt;
  logic [1:0]                   w_rresp_nxt;
  logic                         w_rlast_nxt;

  // Allocation and lookup signals.
  logic [LPARA_IDX_W-1:0]       w_free_slot;
  logic                         w_slot_found;
  logic [PARA_NUM_ID_RD-1:0]    w_ctx_free_oh;
  logic [PARA_NUM_ID_RD-1:0]    w_ctx_hit;
  logic                         w_ctx_free_vld;
  logic                         w_alloc_ok;
  logic                         w_do_alloc;
  logic                         w_cmp_pend;
  logic [PARA_NUM_ID_RD-1:0]    w_cmp_head_ctx;
  logic [PARA_AXI_ID_W-1:0]     w_cmp_id;
  logic                         w_cmp_last;
  logic [PARA_NUM_ID_RD-1:0]    w_cand;
  logic [PARA_NUM_ID_RD-1:0]    w_idm;
  logic [PARA_NUM_ID_RD-1:0]    w_pick_src;
  logic [PARA_NUM_ID_RD-1:0]    w_fetch_sel;
  logic [LPARA_IDX_W-1:0]       w_fetch_slot;
  logic [LPARA_CTX_W-1:0]       w_fetch_idx;
  logic                         w_fetch_vld;
  logic                         w_r_free;
  logic                         w_pf_free;
  logic                         w_bypass_ok;
  logic                         w_bypass;
  logic                         w_fetch;
  logic                         w_retire;
  logic                         w_load_pf;
  logic [PARA_NUM_ID_RD-1:0]    w_ret_ctx;
  logic [LPARA_IDX_W-1:0]       w_ret_slot;
  logic                         w_link_en;
  logic [LPARA_IDX_W-1:0]       w_link_idx;

  // Slot allocation: the lowest free slot gets the next beat; the context is the one that already
  // holds the ID, or the lowest free context. The request is possible when enough slots are free
  // (the first beat of a burst reserves the whole burst) and a context exists or is free.
  always_comb begin : p_com_alloc
    w_free_slot    = '0;
    w_slot_found   = 1'b0;
    w_ctx_free_oh  = '0;
    w_ctx_free_vld = 1'b0;
    w_ctx_hit      = '0;
    for (int idx = 0; idx < PARA_NUM_RD; idx++) begin
      if (~reg_busy[idx] & ~w_slot_found) begin
        w_free_slot  = LPARA_IDX_W'(idx);
        w_slot_found = 1'b1;
      end
    end
    for (int ctx = 0; ctx < PARA_NUM_ID_RD; ctx++) begin
      w_ctx_hit[ctx] = reg_ctx_valid[ctx] & (reg_ctx_id[ctx] == i_alloc_id);
      if (~reg_ctx_valid[ctx] & ~w_ctx_free_vld) begin
        w_ctx_free_oh[ctx] = 1'b1;
        w_ctx_free_vld     = 1'b1;
      end
    end
    w_alloc_ok = (reg_free_cnt >= i_alloc_need) & ((|w_ctx_hit) | w_ctx_free_vld);
    w_do_alloc = i_alloc_en & w_alloc_ok;
  end

  // Completion lookup: the slot must be pending (else the beat is orphaned); the contexts whose
  // oldest slot is this one, and the contexts whose oldest slot has its data stored (done) or that
  // hold the ID of the burst that the R path is serving.
  always_comb begin : p_com_cmp
    w_cmp_pend     = reg_pend[i_cmp_idx];
    w_cmp_id       = reg_slot_id[i_cmp_idx];
    w_cmp_last     = reg_last[i_cmp_idx];
    w_cmp_head_ctx = '0;
    w_cand         = '0;
    w_idm          = '0;
    for (int ctx = 0; ctx < PARA_NUM_ID_RD; ctx++) begin
      w_cmp_head_ctx[ctx] = reg_ctx_valid[ctx] & ~reg_ctx_empty[ctx] & (reg_ctx_head[ctx] == i_cmp_idx);
      w_cand[ctx]         = reg_ctx_valid[ctx] & ~reg_ctx_empty[ctx] & reg_done[reg_ctx_head[ctx]];
      w_idm[ctx]          = reg_ctx_valid[ctx] & ~reg_ctx_empty[ctx] & (reg_ctx_id[ctx] == reg_r_id);
    end
  end

  // Context choice for a read of the storage: the context of the burst that the R path serves, or,
  // when the R path is idle, the next context with stored data after the last one served.
  always_comb begin : p_com_pick
    w_pick_src = w_cand & w_idm;
    if (~reg_r_active) begin
      w_pick_src = '0;
      for (int ctx = 0; ctx < PARA_NUM_ID_RD; ctx++) begin
        if (w_cand[ctx] & (LPARA_CTX_W'(ctx) > reg_rr_ptr))
          w_pick_src[ctx] = 1'b1;
      end
      if (w_pick_src == '0)
        w_pick_src = w_cand;
    end
    w_fetch_sel  = '0;
    w_fetch_slot = '0;
    w_fetch_idx  = '0;
    w_fetch_vld  = 1'b0;
    for (int ctx = 0; ctx < PARA_NUM_ID_RD; ctx++) begin
      if (w_pick_src[ctx] & ~w_fetch_vld) begin
        w_fetch_sel[ctx] = 1'b1;
        w_fetch_slot     = reg_ctx_head[ctx];
        w_fetch_idx      = LPARA_CTX_W'(ctx);
        w_fetch_vld      = 1'b1;
      end
    end
  end

  // R path decisions. A response beat is returned directly (bypass) when its slot is the oldest of
  // a context that the R path may serve (the active burst, or any context when idle and no stored
  // data is waiting), the prefetch stage is empty, and the R register can accept it. Otherwise it
  // is stored. A stored beat is fetched when the prefetch stage is free; fetch and bypass never
  // happen together.
  always_comb begin : p_com_path
    w_r_free    = ~reg_rvalid | i_axi_rready;
    w_pf_free   = ~reg_pf_valid | w_r_free;
    w_bypass_ok = reg_r_active ? (|(w_cmp_head_ctx & w_idm)) : (w_cand == '0);
    w_bypass    = i_cmp_valid & w_cmp_pend & (|w_cmp_head_ctx) & w_r_free & ~reg_pf_valid & w_bypass_ok;
    w_fetch     = w_fetch_vld & w_pf_free & ~w_bypass;
    w_retire    = w_bypass | w_fetch;
    w_load_pf   = reg_pf_valid & w_r_free;
    w_ret_ctx   = '0;
    w_ret_slot  = w_fetch_slot;
    if (w_bypass) begin
      w_ret_ctx  = w_cmp_head_ctx;
      w_ret_slot = i_cmp_idx;
    end else if (w_fetch) begin
      w_ret_ctx = w_fetch_sel;
    end
  end

  // R register and prefetch stage next state. The R register takes the bypass beat or the
  // prefetched beat (data from the storage, or 0 for an error beat of an illegal burst).
  always_comb begin : p_com_rnxt
    w_rvalid_nxt   = reg_rvalid & ~i_axi_rready;
    w_rid_nxt      = reg_rid;
    w_rdata_nxt    = reg_rdata;
    w_rresp_nxt    = reg_rresp;
    w_rlast_nxt    = reg_rlast;
    w_pf_valid_nxt = reg_pf_valid & ~w_load_pf;
    w_pf_gen_nxt   = reg_pf_gen;
    w_pf_err_nxt   = reg_pf_err;
    w_pf_last_nxt  = reg_pf_last;
    w_pf_id_nxt    = reg_pf_id;
    if (w_bypass) begin
      w_rvalid_nxt = 1'b1;
      w_rid_nxt    = w_cmp_id;
      w_rdata_nxt  = i_cmp_data;
      w_rresp_nxt  = {i_cmp_err, 1'b0};
      w_rlast_nxt  = w_cmp_last;
    end else if (w_load_pf) begin
      w_rvalid_nxt = 1'b1;
      w_rid_nxt    = reg_pf_id;
      w_rdata_nxt  = reg_pf_gen ? '0 : i_store_rd_data;
      w_rresp_nxt  = {reg_pf_err, 1'b0};
      w_rlast_nxt  = reg_pf_last;
    end
    if (w_fetch) begin
      w_pf_valid_nxt = 1'b1;
      w_pf_gen_nxt   = reg_gen[w_fetch_slot];
      w_pf_err_nxt   = reg_err[w_fetch_slot];
      w_pf_last_nxt  = reg_last[w_fetch_slot];
      w_pf_id_nxt    = reg_slot_id[w_fetch_slot];
    end
  end

  // R path burst lock: after the first beat of a burst the path serves only that ID until the beat
  // with the last flag; the round-robin pointer follows the context chosen while idle.
  always_comb begin : p_com_ract
    w_r_active_nxt = reg_r_active;
    w_r_id_nxt     = reg_r_id;
    w_rr_ptr_nxt   = reg_rr_ptr;
    if (w_retire) begin
      w_r_active_nxt = ~reg_last[w_ret_slot];
      w_r_id_nxt     = reg_slot_id[w_ret_slot];
    end
    if (w_fetch & ~reg_r_active)
      w_rr_ptr_nxt = w_fetch_idx;
  end

  // Slot flags next state: allocation sets the flags of the new slot (an error beat of an illegal
  // burst is done at once), a response clears pending and marks a stored beat done, retirement
  // frees the slot.
  always_comb begin : p_com_slots
    w_busy_nxt = reg_busy;
    w_pend_nxt = reg_pend;
    w_done_nxt = reg_done;
    w_err_nxt  = reg_err;
    w_gen_nxt  = reg_gen;
    w_last_nxt = reg_last;
    for (int idx = 0; idx < PARA_NUM_RD; idx++) begin
      if (w_do_alloc & (w_free_slot == LPARA_IDX_W'(idx))) begin
        w_busy_nxt[idx] = 1'b1;
        w_pend_nxt[idx] = ~i_alloc_gen;
        w_done_nxt[idx] = i_alloc_gen;
        w_err_nxt[idx]  = i_alloc_gen;
        w_gen_nxt[idx]  = i_alloc_gen;
        w_last_nxt[idx] = i_alloc_last;
      end
      if (i_cmp_valid & w_cmp_pend & (i_cmp_idx == LPARA_IDX_W'(idx))) begin
        w_pend_nxt[idx] = 1'b0;
        if (~w_bypass) begin
          w_done_nxt[idx] = 1'b1;
          w_err_nxt[idx]  = i_cmp_err;
        end
      end
      if (w_retire & (w_ret_slot == LPARA_IDX_W'(idx)))
        w_busy_nxt[idx] = 1'b0;
    end
    w_free_cnt_nxt = reg_free_cnt + LPARA_CNT_W'(w_retire) - LPARA_CNT_W'(w_do_alloc);
  end

  // ID context next state. A new ID takes a free context; a slot of a known ID is appended to the
  // queue of its context (the previous newest slot links to it). Retirement removes the oldest
  // slot. A context with an empty queue stays allocated while the request engine still issues a
  // burst of its ID (pin) and is freed otherwise.
  always_comb begin : p_com_ctx
    w_link_en       = 1'b0;
    w_link_idx      = '0;
    w_ctx_valid_nxt = reg_ctx_valid;
    w_ctx_empty_nxt = reg_ctx_empty;
    w_ctx_id_nxt    = reg_ctx_id;
    w_ctx_head_nxt  = reg_ctx_head;
    w_ctx_tail_nxt  = reg_ctx_tail;
    for (int ctx = 0; ctx < PARA_NUM_ID_RD; ctx++) begin
      if (w_do_alloc & ~(|w_ctx_hit) & w_ctx_free_oh[ctx]) begin
        w_ctx_valid_nxt[ctx] = 1'b1;
        w_ctx_empty_nxt[ctx] = 1'b0;
        w_ctx_id_nxt[ctx]    = i_alloc_id;
        w_ctx_head_nxt[ctx]  = w_free_slot;
        w_ctx_tail_nxt[ctx]  = w_free_slot;
      end else if (reg_ctx_valid[ctx]) begin
        if (w_do_alloc & w_ctx_hit[ctx]) begin
          if (reg_ctx_empty[ctx]) begin
            w_ctx_empty_nxt[ctx] = 1'b0;
            w_ctx_head_nxt[ctx]  = w_free_slot;
            w_ctx_tail_nxt[ctx]  = w_free_slot;
          end else if (w_retire & w_ret_ctx[ctx] & (reg_ctx_head[ctx] == reg_ctx_tail[ctx])) begin
            w_ctx_head_nxt[ctx] = w_free_slot;
            w_ctx_tail_nxt[ctx] = w_free_slot;
          end else begin
            w_ctx_tail_nxt[ctx] = w_free_slot;
            w_link_en           = 1'b1;
            w_link_idx          = reg_ctx_tail[ctx];
            if (w_retire & w_ret_ctx[ctx])
              w_ctx_head_nxt[ctx] = reg_nxt_slot[reg_ctx_head[ctx]];
          end
        end else begin
          if (w_retire & w_ret_ctx[ctx]) begin
            if (reg_ctx_head[ctx] == reg_ctx_tail[ctx]) begin
              w_ctx_empty_nxt[ctx] = 1'b1;
              if (~(i_pin_valid & (reg_ctx_id[ctx] == i_pin_id)))
                w_ctx_valid_nxt[ctx] = 1'b0;
            end else begin
              w_ctx_head_nxt[ctx] = reg_nxt_slot[reg_ctx_head[ctx]];
            end
          end else begin
            if (reg_ctx_empty[ctx] & ~(i_pin_valid & (reg_ctx_id[ctx] == i_pin_id)))
              w_ctx_valid_nxt[ctx] = 1'b0;
          end
        end
      end
    end
  end

  // Output mapping: allocation answer, orphan flag, storage ports, and the R channel register.
  assign o_alloc_ok      = w_alloc_ok;
  assign o_alloc_slot    = w_free_slot;
  assign o_cmp_orphan    = i_cmp_valid & ~w_cmp_pend;
  assign o_store_wr_en   = i_cmp_valid & w_cmp_pend & ~w_bypass;
  assign o_store_wr_addr = i_cmp_idx;
  assign o_store_wr_data = i_cmp_data;
  assign o_store_rd_en   = w_fetch & ~reg_gen[w_fetch_slot];
  assign o_store_rd_addr = w_fetch_slot;
  assign o_axi_rvalid    = reg_rvalid;
  assign o_axi_rid       = reg_rid;
  assign o_axi_rdata     = reg_rdata;
  assign o_axi_rresp     = reg_rresp;
  assign o_axi_rlast     = reg_rlast;

  // Control state of the slot table, the contexts, and the R path, reset to empty.
  always_ff @(posedge i_clk_main, negedge i_rst_n_main) begin : p_ff_ctrl
    if (!i_rst_n_main) begin
      reg_busy      <= '0;
      reg_pend      <= '0;
      reg_done      <= '0;
      reg_err       <= '0;
      reg_gen       <= '0;
      reg_last      <= '0;
      reg_ctx_valid <= '0;
      reg_ctx_empty <= '0;
      reg_free_cnt  <= LPARA_CNT_W'(PARA_NUM_RD);
      reg_r_active  <= 1'b0;
      reg_r_id      <= '0;
      reg_rr_ptr    <= '0;
      reg_pf_valid  <= 1'b0;
      reg_pf_gen    <= 1'b0;
      reg_pf_err    <= 1'b0;
      reg_pf_last   <= 1'b0;
      reg_pf_id     <= '0;
      reg_rvalid    <= 1'b0;
      reg_rid       <= '0;
      reg_rdata     <= '0;
      reg_rresp     <= '0;
      reg_rlast     <= 1'b0;
    end else begin
      reg_busy      <= w_busy_nxt;
      reg_pend      <= w_pend_nxt;
      reg_done      <= w_done_nxt;
      reg_err       <= w_err_nxt;
      reg_gen       <= w_gen_nxt;
      reg_last      <= w_last_nxt;
      reg_ctx_valid <= w_ctx_valid_nxt;
      reg_ctx_empty <= w_ctx_empty_nxt;
      reg_free_cnt  <= w_free_cnt_nxt;
      reg_r_active  <= w_r_active_nxt;
      reg_r_id      <= w_r_id_nxt;
      reg_rr_ptr    <= w_rr_ptr_nxt;
      reg_pf_valid  <= w_pf_valid_nxt;
      reg_pf_gen    <= w_pf_gen_nxt;
      reg_pf_err    <= w_pf_err_nxt;
      reg_pf_last   <= w_pf_last_nxt;
      reg_pf_id     <= w_pf_id_nxt;
      reg_rvalid    <= w_rvalid_nxt;
      reg_rid       <= w_rid_nxt;
      reg_rdata     <= w_rdata_nxt;
      reg_rresp     <= w_rresp_nxt;
      reg_rlast     <= w_rlast_nxt;
    end
  end

  // Slot ID and link per slot, without reset: an entry is read only while its slot is allocated,
  // after it was written at the allocation (ID) or at the append of the next slot (link).
  always_ff @(posedge i_clk_main) begin : p_ff_slot_arr
    if (w_do_alloc)
      reg_slot_id[w_free_slot] <= i_alloc_id;
    if (w_link_en)
      reg_nxt_slot[w_link_idx] <= w_free_slot;
  end

  // Context ID, oldest slot, and newest slot per context, without reset: they are read only while
  // the context is valid and not empty (ID: while valid), after they were written at its
  // allocation.
  for (genvar gen_idx = 0; gen_idx < PARA_NUM_ID_RD; gen_idx++) begin : gen_ctx
    // Context fields: hold their value or load the next state of the context.
    always_ff @(posedge i_clk_main) begin : p_ff_ctx_arr
      reg_ctx_id[gen_idx]   <= w_ctx_id_nxt[gen_idx];
      reg_ctx_head[gen_idx] <= w_ctx_head_nxt[gen_idx];
      reg_ctx_tail[gen_idx] <= w_ctx_tail_nxt[gen_idx];
    end
  end

endmodule
