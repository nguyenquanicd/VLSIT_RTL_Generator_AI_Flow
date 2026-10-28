/*
 * Project      : VLSIT Common RTL library
 * Author       : Nguyen Quan and Claude Sonnet 5.5 (user)
 * AI Flow      : VLSIT RTL Generator AI Automation Flow
 * AI Flow Page : https://github.com/nguyenquanicd/VLSIT_RTL_Generator_AI_Model
 * Date         : 2026-10-28
 * Description  : W path of the AXI3 upsizer with write data interleave (OP-009, REQ-FUNC-018). A
 *                one-beat stage takes the S-side W beat when WREADY is 1 (the stage is empty or its
 *                beat is converted in this cycle, and an AW is pending or a context is active), so
 *                WREADY depends on registers only. In the next cycle the beat is converted if it
 *                finds its context: the active context with the same ID, or, when there is none and
 *                a context is free, a new context bound to the oldest pending AW with the same AWID
 *                (found in the pending store, then taken out of it). A beat that finds no context
 *                stays in the stage. Each context holds its attributes, beat counter, low address
 *                and accumulation register, and converts its beats as m_vlsit_ups_wr_pack does
 *                (packing or lane steering). An M beat is issued when its M word is complete, with
 *                the WID of the context, so M beats of different contexts come in the order of
 *                completion. The context is released with the last beat of its transaction
 *                (o_txn_done). The context registers other than the valid flags have no reset and
 *                are read only while the flag is 1 (SEQ-04).
 */
`timescale 1ns/1ps

module m_vlsit_ups_wr_interleave #(
  // Parameter Description: data width of the subordinate side.
  // Parameter values: a power of 2 of 8 to 512; default is 32.
  // Parameter unit: bit
  parameter logic [31:0] PARA_AXI_S_DATA_W = 32,
  // Parameter Description: data width of the manager side. Larger than PARA_AXI_S_DATA_W.
  // Parameter values: a power of 2 of 16 to 1024; default is 128.
  // Parameter unit: bit
  parameter logic [31:0] PARA_AXI_M_DATA_W = 128,
  // Parameter Description: width of the AXI ID fields.
  // Parameter values: 1 or more; default is 4.
  // Parameter unit: bit
  parameter logic [31:0] PARA_AXI_ID_W = 4,
  // Parameter Description: width of the burst length field: 8 for AXI4, 4 for AXI3.
  // Parameter values: 4 or 8; default is 8.
  // Parameter unit: bit
  parameter logic [31:0] PARA_AXI_LEN_W = 8,
  // Parameter Description: number of write contexts: the number of write transactions whose data
  // may be interleaved. At most PARA_AXI_WR_OUTSTANDING_DEPTH.
  // Parameter values: 1 or more; default is 2.
  // Parameter unit: count
  parameter logic [31:0] PARA_AXI_WR_INTERLEAVE_DEPTH = 2,
  localparam logic [31:0] LPARA_RATIO = PARA_AXI_M_DATA_W / PARA_AXI_S_DATA_W,
  localparam logic [31:0] LPARA_RATIO_LOG2 = $clog2(PARA_AXI_M_DATA_W / PARA_AXI_S_DATA_W),
  localparam logic [31:0] LPARA_S_BYTES_LOG2 = $clog2(PARA_AXI_S_DATA_W / 8),
  localparam logic [31:0] LPARA_M_BYTES_LOG2 = $clog2(PARA_AXI_M_DATA_W / 8),
  localparam logic [31:0] LPARA_ADDR_LOW_W = (LPARA_M_BYTES_LOG2 > (LPARA_S_BYTES_LOG2 + 4)) ? LPARA_M_BYTES_LOG2 : (LPARA_S_BYTES_LOG2 + 4),
  localparam logic [31:0] LPARA_S_STRB_W = PARA_AXI_S_DATA_W / 8,
  localparam logic [31:0] LPARA_M_STRB_W = PARA_AXI_M_DATA_W / 8,
  localparam logic [31:0] LPARA_CTX_IDX_W = (PARA_AXI_WR_INTERLEAVE_DEPTH > 1) ? $clog2(PARA_AXI_WR_INTERLEAVE_DEPTH) : 1
) (
  // Clock and reset
  input  wire                          i_clk_axi,
  input  wire                          i_rst_n_axi,

  // Pending store
  input  wire                          i_pend_any,
  output logic [PARA_AXI_ID_W-1:0]     o_find_id,
  input  wire                          i_find_hit,
  input  wire                          i_find_pack,
  input  wire  [LPARA_ADDR_LOW_W-1:0]  i_find_addr_low,
  input  wire  [2:0]                   i_find_size,
  input  wire  [PARA_AXI_LEN_W-1:0]    i_find_len,
  input  wire  [1:0]                   i_find_burst,
  output logic                         o_take_en,

  // Subordinate-side W beat
  input  wire                          i_wvalid,
  input  wire  [PARA_AXI_ID_W-1:0]     i_wid,
  input  wire  [PARA_AXI_S_DATA_W-1:0] i_wdata,
  input  wire  [LPARA_S_STRB_W-1:0]    i_wstrb,
  output logic                         o_wready,

  // Manager-side W beat (to the W slice)
  output logic                         o_beat_valid,
  output logic [PARA_AXI_ID_W-1:0]     o_beat_id,
  output logic [PARA_AXI_M_DATA_W-1:0] o_beat_data,
  output logic [LPARA_M_STRB_W-1:0]    o_beat_strb,
  output logic                         o_beat_last,
  input  wire                          i_beat_ready,

  // Transaction status
  output logic                         o_txn_done
);
  // Internal signal declarations: the one-beat stage
  logic                          reg_stage_valid;
  logic [PARA_AXI_ID_W-1:0]      reg_stage_id;
  logic [PARA_AXI_S_DATA_W-1:0]  reg_stage_data;
  logic [LPARA_S_STRB_W-1:0]     reg_stage_strb;
  logic                          w_stage_load;

  // Internal signal declarations: the write contexts
  logic                          reg_ctx_valid    [0:PARA_AXI_WR_INTERLEAVE_DEPTH-1];
  logic [PARA_AXI_ID_W-1:0]      reg_ctx_id       [0:PARA_AXI_WR_INTERLEAVE_DEPTH-1];
  logic                          reg_ctx_pack     [0:PARA_AXI_WR_INTERLEAVE_DEPTH-1];
  logic [LPARA_ADDR_LOW_W-1:0]   reg_ctx_addr_low [0:PARA_AXI_WR_INTERLEAVE_DEPTH-1];
  logic [2:0]                    reg_ctx_size     [0:PARA_AXI_WR_INTERLEAVE_DEPTH-1];
  logic [PARA_AXI_LEN_W-1:0]     reg_ctx_len      [0:PARA_AXI_WR_INTERLEAVE_DEPTH-1];
  logic [1:0]                    reg_ctx_burst    [0:PARA_AXI_WR_INTERLEAVE_DEPTH-1];
  logic [PARA_AXI_LEN_W-1:0]     reg_ctx_idx      [0:PARA_AXI_WR_INTERLEAVE_DEPTH-1];
  logic [LPARA_ADDR_LOW_W-1:0]   reg_ctx_cur_low  [0:PARA_AXI_WR_INTERLEAVE_DEPTH-1];
  logic [PARA_AXI_M_DATA_W-1:0]  reg_ctx_acc_data [0:PARA_AXI_WR_INTERLEAVE_DEPTH-1];
  logic [LPARA_M_STRB_W-1:0]     reg_ctx_acc_strb [0:PARA_AXI_WR_INTERLEAVE_DEPTH-1];

  // Internal signal declarations: context search and selection
  logic [PARA_AXI_WR_INTERLEAVE_DEPTH-1:0] w_ctx_match;
  logic [PARA_AXI_WR_INTERLEAVE_DEPTH-1:0] w_ctx_free;
  logic [LPARA_CTX_IDX_W-1:0]    w_match_idx;
  logic [LPARA_CTX_IDX_W-1:0]    w_free_idx;
  logic [LPARA_CTX_IDX_W-1:0]    w_sel_idx;
  logic                          w_any_match;
  logic                          w_any_free;
  logic                          w_any_ctx;
  logic                          w_bind;
  logic                          w_use;
  logic                          w_sel_pack;
  logic [LPARA_ADDR_LOW_W-1:0]   w_sel_addr_low;
  logic [2:0]                    w_sel_size;
  logic [PARA_AXI_LEN_W-1:0]     w_sel_len;
  logic [1:0]                    w_sel_burst;
  logic [PARA_AXI_LEN_W-1:0]     w_sel_beat;
  logic [LPARA_ADDR_LOW_W-1:0]   w_sel_cur_low;
  logic [PARA_AXI_M_DATA_W-1:0]  w_sel_acc_data;
  logic [LPARA_M_STRB_W-1:0]     w_sel_acc_strb;

  // Internal signal declarations: conversion of the staged beat
  logic [LPARA_RATIO_LOG2-1:0]   w_slot;
  logic                          w_word_last;
  logic                          w_last;
  logic [LPARA_ADDR_LOW_W-1:0]   w_nxt_low;
  logic [LPARA_RATIO-1:0]        w_slot_dec;
  logic                          w_proc;
  logic [PARA_AXI_M_DATA_W-1:0]  w_data_merged;
  logic [LPARA_M_STRB_W-1:0]     w_strb_merged;

  // Slot decode: one write enable per slot (one-hot).
  assign w_slot_dec = $bits(w_slot_dec)'(1) << w_slot;

  // Context availability and binding: a context exists for the staged beat when one has its ID, or
  // when a free context can bind the oldest pending AW with that ID.
  assign w_any_match = |w_ctx_match;
  assign w_any_free  = |w_ctx_free;
  assign w_any_ctx   = ~(&w_ctx_free);
  assign w_bind      = reg_stage_valid & ~w_any_match & w_any_free & i_find_hit;
  assign w_use       = reg_stage_valid & (w_any_match | w_bind);
  assign w_sel_idx   = w_any_match ? w_match_idx : w_free_idx;

  // Conversion step: the staged beat is converted when it has its context and, if it completes an
  // M word, the W slice is ready.
  assign w_proc = w_use & (~w_word_last | i_beat_ready);

  // S-side ready: the stage is empty or being emptied, and an AW is pending or a context is active.
  // Only registers drive it (no dependence on i_wvalid).
  assign o_wready     = (~reg_stage_valid | w_proc) & (i_pend_any | w_any_ctx);
  assign w_stage_load = i_wvalid & o_wready;

  // Output mapping.
  assign o_find_id    = reg_stage_id;
  assign o_take_en    = w_proc & ~w_any_match;
  assign o_txn_done   = w_proc & w_last;
  assign o_beat_valid = w_proc & w_word_last;
  assign o_beat_id    = reg_stage_id;
  assign o_beat_data  = w_data_merged;
  assign o_beat_strb  = w_strb_merged;
  assign o_beat_last  = w_last;

  // Context search: the context with the ID of the staged beat, and the first free context (the
  // lowest index wins).
  always_comb begin : p_com_search
    w_ctx_match = '0;
    w_ctx_free  = '0;
    w_match_idx = '0;
    w_free_idx  = '0;
    for (int ctx = 0; ctx < PARA_AXI_WR_INTERLEAVE_DEPTH; ctx++) begin
      w_ctx_match[ctx] = reg_ctx_valid[ctx] & (reg_ctx_id[ctx] == reg_stage_id);
      w_ctx_free[ctx]  = ~reg_ctx_valid[ctx];
    end
    for (int ctx = PARA_AXI_WR_INTERLEAVE_DEPTH - 1; ctx >= 0; ctx--) begin
      if (w_ctx_match[ctx])
        w_match_idx = $bits(w_match_idx)'(ctx);
      if (w_ctx_free[ctx])
        w_free_idx = $bits(w_free_idx)'(ctx);
    end
  end

  // Context selection: a matching context supplies its state; a new context starts from the pending
  // entry with beat 0 and an empty accumulation register.
  always_comb begin : p_com_sel
    w_sel_pack     = i_find_pack;
    w_sel_addr_low = i_find_addr_low;
    w_sel_size     = i_find_size;
    w_sel_len      = i_find_len;
    w_sel_burst    = i_find_burst;
    w_sel_beat     = '0;
    w_sel_cur_low  = '0;
    w_sel_acc_data = '0;
    w_sel_acc_strb = '0;
    if (w_any_match) begin
      w_sel_pack     = reg_ctx_pack[w_match_idx];
      w_sel_addr_low = reg_ctx_addr_low[w_match_idx];
      w_sel_size     = reg_ctx_size[w_match_idx];
      w_sel_len      = reg_ctx_len[w_match_idx];
      w_sel_burst    = reg_ctx_burst[w_match_idx];
      w_sel_beat     = reg_ctx_idx[w_match_idx];
      w_sel_cur_low  = reg_ctx_cur_low[w_match_idx];
      w_sel_acc_data = reg_ctx_acc_data[w_match_idx];
      w_sel_acc_strb = reg_ctx_acc_strb[w_match_idx];
    end
  end

  // Merge: the staged beat replaces the data and the strobes of its slot in the selected
  // accumulation register.
  always_comb begin : p_com_merge
    w_data_merged = w_sel_acc_data;
    w_strb_merged = w_sel_acc_strb;
    for (int slt = 0; slt < LPARA_RATIO; slt++) begin
      if (w_slot_dec[slt]) begin
        w_data_merged[slt*PARA_AXI_S_DATA_W +: PARA_AXI_S_DATA_W] = reg_stage_data;
        w_strb_merged[slt*LPARA_S_STRB_W +: LPARA_S_STRB_W]       = reg_stage_strb;
      end
    end
  end

  // Stage valid flag: control state, reset to 0. A new beat has priority over the release.
  always_ff @(posedge i_clk_axi, negedge i_rst_n_axi) begin : p_ff_stage_ctrl
    if (!i_rst_n_axi)
      reg_stage_valid <= 1'b0;
    else if (w_stage_load)
      reg_stage_valid <= 1'b1;
    else if (w_proc)
      reg_stage_valid <= 1'b0;
  end

  // Stage payload, resetless: used only while reg_stage_valid is 1.
  always_ff @(posedge i_clk_axi) begin : p_ff_stage_payload
    if (w_stage_load) begin
      reg_stage_id   <= i_wid;
      reg_stage_data <= i_wdata;
      reg_stage_strb <= i_wstrb;
    end
  end

  // One register set per context. The context that converts the staged beat is updated: it becomes
  // valid (or free again after the last beat of its transaction), keeps its attributes, advances
  // its beat counter and low address, and keeps the accumulation register or clears it when the
  // beat completed an M word.
  for (genvar gen_idx = 0; gen_idx < PARA_AXI_WR_INTERLEAVE_DEPTH; gen_idx++) begin : gen_ctx
    logic w_upd;

    // Update select: this context converts the staged beat in this cycle.
    assign w_upd = w_proc & (w_sel_idx == $bits(w_sel_idx)'(gen_idx));

    // Valid flag of the context: control state, reset to 0.
    always_ff @(posedge i_clk_axi, negedge i_rst_n_axi) begin : p_ff_valid
      if (!i_rst_n_axi)
        reg_ctx_valid[gen_idx] <= 1'b0;
      else if (w_upd)
        reg_ctx_valid[gen_idx] <= ~w_last;
    end

    // Context payload, resetless: read only while the valid flag of the context is 1.
    always_ff @(posedge i_clk_axi) begin : p_ff_payload
      if (w_upd) begin
        reg_ctx_id[gen_idx]       <= reg_stage_id;
        reg_ctx_pack[gen_idx]     <= w_sel_pack;
        reg_ctx_addr_low[gen_idx] <= w_sel_addr_low;
        reg_ctx_size[gen_idx]     <= w_sel_size;
        reg_ctx_len[gen_idx]      <= w_sel_len;
        reg_ctx_burst[gen_idx]    <= w_sel_burst;
        reg_ctx_idx[gen_idx]      <= w_last ? '0 : $bits(w_sel_beat)'(w_sel_beat + 1'b1);
        reg_ctx_cur_low[gen_idx]  <= w_nxt_low;
        reg_ctx_acc_data[gen_idx] <= w_word_last ? '0 : w_data_merged;
        reg_ctx_acc_strb[gen_idx] <= w_word_last ? '0 : w_strb_merged;
      end
    end
  end

  // Beat address generator: slot index, end-of-word flag and last-beat flag of the current S beat,
  // and the next low address for a burst that is not packed.
  m_vlsit_ups_beat_addr #(
    .PARA_AXI_S_DATA_W (PARA_AXI_S_DATA_W),
    .PARA_AXI_M_DATA_W (PARA_AXI_M_DATA_W),
    .PARA_AXI_LEN_W    (PARA_AXI_LEN_W)
  ) u_beat_addr (
    .i_pack      (w_sel_pack),
    .i_addr_low  (w_sel_addr_low),
    .i_len       (w_sel_len),
    .i_size      (w_sel_size),
    .i_burst     (w_sel_burst),
    .i_idx       (w_sel_beat),
    .i_cur_low   (w_sel_cur_low),
    .o_slot      (w_slot),
    .o_word_last (w_word_last),
    .o_last      (w_last),
    .o_nxt_low   (w_nxt_low)
  );

endmodule
