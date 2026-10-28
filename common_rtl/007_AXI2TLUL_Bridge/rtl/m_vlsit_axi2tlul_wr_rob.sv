/*
 * Project      : VLSIT Common RTL library
 * Author       : Nguyen Quan and Claude Sonnet 5.5 (user)
 * AI Flow      : VLSIT RTL Generator AI Automation Flow
 * AI Flow Page : https://github.com/nguyenquanicd/VLSIT_RTL_Generator_AI_Model
 * Date         : 2026-10-26
 * Description  : Write slot table of the AXI2TLUL bridge. It reserves one slot per write beat (the
 *                slot index is the TL-UL tag), keeps the slots of one AXI ID in request order in an
 *                ID context, and returns one B response per burst: a slot retires when it is the
 *                oldest of its context and its TL-UL response has arrived (directly in the cycle of
 *                the response when possible, otherwise later from the table); the slot with the
 *                last flag loads the B register with the ID and the sticky burst error, SLVERR if
 *                any beat of the burst failed. B responses of different IDs may leave in any order.
 *                An ID context stays allocated while the request engine issues a burst of that ID
 *                (pin), which keeps the sticky error of the burst. All B outputs are flip-flops.
 */
`timescale 1ns/1ps

module m_vlsit_axi2tlul_wr_rob #(
  // Parameter Description: number of write slots, the maximum number of outstanding write beats.
  // Parameter values: power of two from 2 to 128; default is 16.
  // Parameter unit: count
  parameter logic [31:0] PARA_NUM_WR = 16,
  // Parameter Description: number of ID contexts, the AXI IDs that can have write beats in flight.
  // Parameter values: 1 to PARA_NUM_WR; default is 4.
  // Parameter unit: count
  parameter logic [31:0] PARA_NUM_ID_WR = 4,
  // Parameter Description: width of the AXI ID.
  // Parameter values: 1 to 32; default is 8.
  // Parameter unit: bit
  parameter logic [31:0] PARA_AXI_ID_W = 8,
  localparam logic [31:0] LPARA_IDX_W = $clog2(PARA_NUM_WR),
  localparam logic [31:0] LPARA_CNT_W = $clog2(PARA_NUM_WR) + 1,
  localparam logic [31:0] LPARA_CTX_W = (PARA_NUM_ID_WR > 1) ? $clog2(PARA_NUM_ID_WR) : 1
) (
  // Clock and reset
  input  wire                      i_clk_main,
  input  wire                      i_rst_n_main,

  // Slot allocation from the write request engine
  input  wire                      i_alloc_en,
  input  wire                      i_alloc_gen,
  input  wire  [PARA_AXI_ID_W-1:0] i_alloc_id,
  input  wire                      i_alloc_last,
  input  wire                      i_pin_valid,
  input  wire  [PARA_AXI_ID_W-1:0] i_pin_id,
  output logic                     o_alloc_ok,
  output logic [LPARA_IDX_W-1:0]   o_alloc_slot,

  // Completion from the response decoder
  input  wire                      i_cmp_valid,
  input  wire  [LPARA_IDX_W-1:0]   i_cmp_idx,
  input  wire                      i_cmp_err,
  output logic                     o_cmp_orphan,

  // AXI B channel
  output logic                     o_axi_bvalid,
  input  wire                      i_axi_bready,
  output logic [PARA_AXI_ID_W-1:0] o_axi_bid,
  output logic [1:0]               o_axi_bresp
);

  // Internal signal declarations: slot table (flags per slot, ID and link per slot).
  logic [PARA_NUM_WR-1:0]       reg_busy;
  logic [PARA_NUM_WR-1:0]       reg_pend;
  logic [PARA_NUM_WR-1:0]       reg_done;
  logic [PARA_NUM_WR-1:0]       reg_err;
  logic [PARA_NUM_WR-1:0]       reg_last;
  logic [PARA_AXI_ID_W-1:0]     reg_slot_id [PARA_NUM_WR];
  logic [LPARA_IDX_W-1:0]       reg_nxt_slot [PARA_NUM_WR];
  logic [PARA_NUM_WR-1:0]       w_busy_nxt;
  logic [PARA_NUM_WR-1:0]       w_pend_nxt;
  logic [PARA_NUM_WR-1:0]       w_done_nxt;
  logic [PARA_NUM_WR-1:0]       w_err_nxt;
  logic [PARA_NUM_WR-1:0]       w_last_nxt;

  // ID contexts, with the sticky error of the burst in progress.
  logic [PARA_NUM_ID_WR-1:0]    reg_ctx_valid;
  logic [PARA_NUM_ID_WR-1:0]    reg_ctx_empty;
  logic [PARA_NUM_ID_WR-1:0]    reg_ctx_err;
  logic [PARA_AXI_ID_W-1:0]     reg_ctx_id [PARA_NUM_ID_WR];
  logic [LPARA_IDX_W-1:0]       reg_ctx_head [PARA_NUM_ID_WR];
  logic [LPARA_IDX_W-1:0]       reg_ctx_tail [PARA_NUM_ID_WR];
  logic [PARA_NUM_ID_WR-1:0]    w_ctx_valid_nxt;
  logic [PARA_NUM_ID_WR-1:0]    w_ctx_empty_nxt;
  logic [PARA_NUM_ID_WR-1:0]    w_ctx_err_nxt;
  logic [PARA_AXI_ID_W-1:0]     w_ctx_id_nxt [PARA_NUM_ID_WR];
  logic [LPARA_IDX_W-1:0]       w_ctx_head_nxt [PARA_NUM_ID_WR];
  logic [LPARA_IDX_W-1:0]       w_ctx_tail_nxt [PARA_NUM_ID_WR];

  // Free count, retirement pointer, and B register.
  logic [LPARA_CNT_W-1:0]       reg_free_cnt;
  logic [LPARA_CNT_W-1:0]       w_free_cnt_nxt;
  logic [LPARA_CTX_W-1:0]       reg_rr_ptr;
  logic [LPARA_CTX_W-1:0]       w_rr_ptr_nxt;
  logic                         reg_bvalid;
  logic [PARA_AXI_ID_W-1:0]     reg_bid;
  logic [1:0]                   reg_bresp;
  logic                         w_bvalid_nxt;
  logic [PARA_AXI_ID_W-1:0]     w_bid_nxt;
  logic [1:0]                   w_bresp_nxt;

  // Allocation and lookup signals.
  logic [LPARA_IDX_W-1:0]       w_free_slot;
  logic                         w_slot_found;
  logic [PARA_NUM_ID_WR-1:0]    w_ctx_free_oh;
  logic [PARA_NUM_ID_WR-1:0]    w_ctx_hit;
  logic                         w_ctx_free_vld;
  logic                         w_alloc_ok;
  logic                         w_do_alloc;
  logic                         w_cmp_pend;
  logic [PARA_NUM_ID_WR-1:0]    w_cmp_head_ctx;
  logic                         w_cmp_last;
  logic                         w_b_free;
  logic [PARA_NUM_ID_WR-1:0]    w_cand;
  logic [PARA_NUM_ID_WR-1:0]    w_pick_src;
  logic [PARA_NUM_ID_WR-1:0]    w_q_sel;
  logic [LPARA_IDX_W-1:0]       w_q_slot;
  logic [LPARA_CTX_W-1:0]       w_q_idx;
  logic                         w_q_vld;
  logic                         w_bypass;
  logic                         w_retire;
  logic [PARA_NUM_ID_WR-1:0]    w_ret_ctx;
  logic [LPARA_IDX_W-1:0]       w_ret_slot;
  logic                         w_ret_last;
  logic                         w_ret_err;
  logic                         w_link_en;
  logic [LPARA_IDX_W-1:0]       w_link_idx;

  // Slot allocation: the lowest free slot gets the next beat; the context is the one that already
  // holds the ID, or the lowest free context. The request is possible when a slot is free and a
  // context exists or is free.
  always_comb begin : p_com_alloc
    w_free_slot    = '0;
    w_slot_found   = 1'b0;
    w_ctx_free_oh  = '0;
    w_ctx_free_vld = 1'b0;
    w_ctx_hit      = '0;
    for (int idx = 0; idx < PARA_NUM_WR; idx++) begin
      if (~reg_busy[idx] & ~w_slot_found) begin
        w_free_slot  = LPARA_IDX_W'(idx);
        w_slot_found = 1'b1;
      end
    end
    for (int ctx = 0; ctx < PARA_NUM_ID_WR; ctx++) begin
      w_ctx_hit[ctx] = reg_ctx_valid[ctx] & (reg_ctx_id[ctx] == i_alloc_id);
      if (~reg_ctx_valid[ctx] & ~w_ctx_free_vld) begin
        w_ctx_free_oh[ctx] = 1'b1;
        w_ctx_free_vld     = 1'b1;
      end
    end
    w_alloc_ok = (reg_free_cnt != '0) & ((|w_ctx_hit) | w_ctx_free_vld);
    w_do_alloc = i_alloc_en & w_alloc_ok;
  end

  // Completion lookup: the slot must be pending (else the beat is orphaned) and the contexts whose
  // oldest slot is this one. A context can retire its oldest slot from the table when that slot is
  // done and, if it carries the last flag, the B register can take the response.
  always_comb begin : p_com_cmp
    w_cmp_pend     = reg_pend[i_cmp_idx];
    w_cmp_last     = reg_last[i_cmp_idx];
    w_b_free       = ~reg_bvalid | i_axi_bready;
    w_cmp_head_ctx = '0;
    w_cand         = '0;
    for (int ctx = 0; ctx < PARA_NUM_ID_WR; ctx++) begin
      w_cmp_head_ctx[ctx] = reg_ctx_valid[ctx] & ~reg_ctx_empty[ctx] & (reg_ctx_head[ctx] == i_cmp_idx);
      w_cand[ctx]         = reg_ctx_valid[ctx] & ~reg_ctx_empty[ctx] & reg_done[reg_ctx_head[ctx]] &
                            (~reg_last[reg_ctx_head[ctx]] | w_b_free);
    end
  end

  // Context choice for a retirement from the table: the next candidate after the last one served.
  always_comb begin : p_com_pick
    w_pick_src = '0;
    for (int ctx = 0; ctx < PARA_NUM_ID_WR; ctx++) begin
      if (w_cand[ctx] & (LPARA_CTX_W'(ctx) > reg_rr_ptr))
        w_pick_src[ctx] = 1'b1;
    end
    if (w_pick_src == '0)
      w_pick_src = w_cand;
    w_q_sel  = '0;
    w_q_slot = '0;
    w_q_idx  = '0;
    w_q_vld  = 1'b0;
    for (int ctx = 0; ctx < PARA_NUM_ID_WR; ctx++) begin
      if (w_pick_src[ctx] & ~w_q_vld) begin
        w_q_sel[ctx] = 1'b1;
        w_q_slot     = reg_ctx_head[ctx];
        w_q_idx      = LPARA_CTX_W'(ctx);
        w_q_vld      = 1'b1;
      end
    end
  end

  // Retirement: one slot per cycle. A done slot of the table has priority; a response beat retires
  // at once when its slot is the oldest of a context, no table slot retires in this cycle, and the
  // B register can take the response when the slot is the last of its burst. The error of the
  // burst is the sticky error of the context plus the error of this beat.
  always_comb begin : p_com_ret
    w_bypass   = i_cmp_valid & w_cmp_pend & (|w_cmp_head_ctx) & ~w_q_vld & (~w_cmp_last | w_b_free);
    w_retire   = w_q_vld | w_bypass;
    w_ret_ctx  = '0;
    w_ret_slot = w_q_slot;
    if (w_q_vld) begin
      w_ret_ctx = w_q_sel;
    end else if (w_bypass) begin
      w_ret_ctx  = w_cmp_head_ctx;
      w_ret_slot = i_cmp_idx;
    end
    w_ret_last = reg_last[w_ret_slot];
    w_ret_err  = (|(w_ret_ctx & reg_ctx_err)) | (w_bypass ? i_cmp_err : reg_err[w_ret_slot]);
  end

  // B register next state: the slot with the last flag loads the response of its burst.
  always_comb begin : p_com_b
    w_bvalid_nxt = reg_bvalid & ~i_axi_bready;
    w_bid_nxt    = reg_bid;
    w_bresp_nxt  = reg_bresp;
    if (w_retire & w_ret_last) begin
      w_bvalid_nxt = 1'b1;
      w_bid_nxt    = reg_slot_id[w_ret_slot];
      w_bresp_nxt  = {w_ret_err, 1'b0};
    end
  end

  // Slot flags next state: allocation sets the flags of the new slot (the error slot of an illegal
  // burst is done at once), a response clears pending and marks a waiting slot done, retirement
  // frees the slot.
  always_comb begin : p_com_slots
    w_busy_nxt = reg_busy;
    w_pend_nxt = reg_pend;
    w_done_nxt = reg_done;
    w_err_nxt  = reg_err;
    w_last_nxt = reg_last;
    for (int idx = 0; idx < PARA_NUM_WR; idx++) begin
      if (w_do_alloc & (w_free_slot == LPARA_IDX_W'(idx))) begin
        w_busy_nxt[idx] = 1'b1;
        w_pend_nxt[idx] = ~i_alloc_gen;
        w_done_nxt[idx] = i_alloc_gen;
        w_err_nxt[idx]  = i_alloc_gen;
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
    w_rr_ptr_nxt   = reg_rr_ptr;
    if (w_q_vld)
      w_rr_ptr_nxt = w_q_idx;
  end

  // ID context next state, as in the read slot table, plus the sticky error: it takes the error of
  // each retired beat and is cleared with the last beat of a burst.
  always_comb begin : p_com_ctx
    w_link_en       = 1'b0;
    w_link_idx      = '0;
    w_ctx_valid_nxt = reg_ctx_valid;
    w_ctx_empty_nxt = reg_ctx_empty;
    w_ctx_err_nxt   = reg_ctx_err;
    w_ctx_id_nxt    = reg_ctx_id;
    w_ctx_head_nxt  = reg_ctx_head;
    w_ctx_tail_nxt  = reg_ctx_tail;
    for (int ctx = 0; ctx < PARA_NUM_ID_WR; ctx++) begin
      if (w_retire & w_ret_ctx[ctx])
        w_ctx_err_nxt[ctx] = ~w_ret_last & w_ret_err;
      if (w_do_alloc & ~(|w_ctx_hit) & w_ctx_free_oh[ctx]) begin
        w_ctx_valid_nxt[ctx] = 1'b1;
        w_ctx_empty_nxt[ctx] = 1'b0;
        w_ctx_err_nxt[ctx]   = 1'b0;
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

  // Output mapping: allocation answer, orphan flag, and the B channel register.
  assign o_alloc_ok   = w_alloc_ok;
  assign o_alloc_slot = w_free_slot;
  assign o_cmp_orphan = i_cmp_valid & ~w_cmp_pend;
  assign o_axi_bvalid = reg_bvalid;
  assign o_axi_bid    = reg_bid;
  assign o_axi_bresp  = reg_bresp;

  // Control state of the slot table, the contexts, and the B register, reset to empty.
  always_ff @(posedge i_clk_main, negedge i_rst_n_main) begin : p_ff_ctrl
    if (!i_rst_n_main) begin
      reg_busy      <= '0;
      reg_pend      <= '0;
      reg_done      <= '0;
      reg_err       <= '0;
      reg_last      <= '0;
      reg_ctx_valid <= '0;
      reg_ctx_empty <= '0;
      reg_ctx_err   <= '0;
      reg_free_cnt  <= LPARA_CNT_W'(PARA_NUM_WR);
      reg_rr_ptr    <= '0;
      reg_bvalid    <= 1'b0;
      reg_bid       <= '0;
      reg_bresp     <= '0;
    end else begin
      reg_busy      <= w_busy_nxt;
      reg_pend      <= w_pend_nxt;
      reg_done      <= w_done_nxt;
      reg_err       <= w_err_nxt;
      reg_last      <= w_last_nxt;
      reg_ctx_valid <= w_ctx_valid_nxt;
      reg_ctx_empty <= w_ctx_empty_nxt;
      reg_ctx_err   <= w_ctx_err_nxt;
      reg_free_cnt  <= w_free_cnt_nxt;
      reg_rr_ptr    <= w_rr_ptr_nxt;
      reg_bvalid    <= w_bvalid_nxt;
      reg_bid       <= w_bid_nxt;
      reg_bresp     <= w_bresp_nxt;
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
  for (genvar gen_idx = 0; gen_idx < PARA_NUM_ID_WR; gen_idx++) begin : gen_ctx
    // Context fields: hold their value or load the next state of the context.
    always_ff @(posedge i_clk_main) begin : p_ff_ctx_arr
      reg_ctx_id[gen_idx]   <= w_ctx_id_nxt[gen_idx];
      reg_ctx_head[gen_idx] <= w_ctx_head_nxt[gen_idx];
      reg_ctx_tail[gen_idx] <= w_ctx_tail_nxt[gen_idx];
    end
  end

endmodule
