/*
 * Project      : VLSIT Common RTL library
 * Author       : Nguyen Quan and Claude Sonnet 5.5 (user)
 * AI Flow      : VLSIT RTL Generator AI Automation Flow
 * AI Flow Page : https://github.com/nguyenquanicd/VLSIT_RTL_Generator_AI_Model
 * Date         : 2026-10-28
 * Description  : Store of the accepted write addresses that are not yet bound to a write context,
 *                for the AXI3 write data interleave of the AXI upsizer (MEM-006, REQ-FUNC-018).
 *                Entry 0 is the oldest. A push appends an entry with its AWID and its attributes.
 *                The search finds the oldest entry whose AWID equals i_find_id (o_find_hit,
 *                o_find_entry); i_take_en removes that entry and the younger entries move down by
 *                one, so the order of the other entries is kept. A push and a removal can happen in
 *                the same cycle. The caller never pushes when the store is full (the outstanding
 *                count of the write path guarantees it). The ID and attribute registers have no
 *                reset and are read only while the valid flag of the entry is 1 (SEQ-04).
 */
`timescale 1ns/1ps

module m_vlsit_ups_pending #(
  // Parameter Description: width of the AWID.
  // Parameter values: 1 or more; default is 4.
  // Parameter unit: bit
  parameter logic [31:0] PARA_AXI_ID_W = 4,
  // Parameter Description: number of entries of the store, equal to the write outstanding depth.
  // Parameter values: 2 or more; default is 4.
  // Parameter unit: count
  parameter logic [31:0] PARA_PENDING_DEPTH = 4,
  // Parameter Description: width of the attribute vector of one entry.
  // Parameter values: 1 or more; default is 16.
  // Parameter unit: bit
  parameter logic [31:0] PARA_PENDING_ENTRY_W = 16,
  localparam logic [31:0] LPARA_IDX_W = $clog2(PARA_PENDING_DEPTH),
  localparam logic [31:0] LPARA_CNT_W = $clog2(PARA_PENDING_DEPTH + 1)
) (
  // Clock and reset
  input  wire                             i_clk_axi,
  input  wire                             i_rst_n_axi,

  // Push
  input  wire                             i_push_en,
  input  wire  [PARA_AXI_ID_W-1:0]        i_push_id,
  input  wire  [PARA_PENDING_ENTRY_W-1:0] i_push_entry,

  // Search and take
  input  wire  [PARA_AXI_ID_W-1:0]        i_find_id,
  output logic                            o_find_hit,
  output logic [PARA_PENDING_ENTRY_W-1:0] o_find_entry,
  input  wire                             i_take_en,

  // Status
  output logic [LPARA_CNT_W-1:0]          o_count
);
  // Internal signal declarations
  logic                           reg_valid [0:PARA_PENDING_DEPTH-1];
  logic [PARA_AXI_ID_W-1:0]       reg_id    [0:PARA_PENDING_DEPTH-1];
  logic [PARA_PENDING_ENTRY_W-1:0] reg_entry [0:PARA_PENDING_DEPTH-1];
  logic [LPARA_CNT_W-1:0]         reg_count;
  logic [PARA_PENDING_DEPTH-1:0]  w_match;
  logic                           w_hit;
  logic [LPARA_IDX_W-1:0]         w_hit_idx;
  logic                           w_take;
  logic [LPARA_CNT_W-1:0]         w_wr_cnt;

  // Search: the oldest entry with the searched ID (the lowest index) is the hit.
  always_comb begin : p_com_find
    w_match   = '0;
    w_hit     = 1'b0;
    w_hit_idx = '0;
    for (int ent = 0; ent < PARA_PENDING_DEPTH; ent++) begin
      w_match[ent] = reg_valid[ent] & (reg_id[ent] == i_find_id);
    end
    for (int ent = PARA_PENDING_DEPTH - 1; ent >= 0; ent--) begin
      if (w_match[ent]) begin
        w_hit     = 1'b1;
        w_hit_idx = $bits(w_hit_idx)'(ent);
      end
    end
  end

  // Output mapping: the hit entry and the occupancy.
  assign o_find_hit   = w_hit;
  assign o_find_entry = reg_entry[w_hit_idx];
  assign o_count      = reg_count;

  // Removal of the hit entry, and the index where a pushed entry is written after the removal.
  assign w_take   = i_take_en & w_hit;
  assign w_wr_cnt = reg_count - $bits(w_wr_cnt)'(w_take);

  // Occupancy: one more for a push, one less for a removal. Control state, reset to 0.
  always_ff @(posedge i_clk_axi, negedge i_rst_n_axi) begin : p_ff_count
    if (!i_rst_n_axi)
      reg_count <= '0;
    else
      reg_count <= reg_count + $bits(reg_count)'(i_push_en) - $bits(reg_count)'(w_take);
  end

  // One register set per entry: after a removal the entries at or above the removed index take
  // the value of the next entry (the last one is invalidated); a push writes the entry at the
  // new count.
  for (genvar gen_idx = 0; gen_idx < PARA_PENDING_DEPTH; gen_idx++) begin : gen_entry
    logic                            w_src_valid;
    logic [PARA_AXI_ID_W-1:0]        w_src_id;
    logic [PARA_PENDING_ENTRY_W-1:0] w_src_entry;
    logic                            w_valid_nxt;
    logic [PARA_AXI_ID_W-1:0]        w_id_nxt;
    logic [PARA_PENDING_ENTRY_W-1:0] w_entry_nxt;

    // Source of a shift: the next entry, or nothing for the last entry.
    if (gen_idx < PARA_PENDING_DEPTH - 1) begin : gen_nxt
      // The next entry (index + 1) supplies the shifted value.
      assign w_src_valid = reg_valid[gen_idx + 1];
      assign w_src_id    = reg_id[gen_idx + 1];
      assign w_src_entry = reg_entry[gen_idx + 1];
    end else begin : gen_last
      // The last entry has no next entry: a shift invalidates it.
      assign w_src_valid = 1'b0;
      assign w_src_id    = '0;
      assign w_src_entry = '0;
    end

    // Next value of the entry: hold, shift after a removal, or take the pushed entry.
    always_comb begin : p_com_nxt
      w_valid_nxt = reg_valid[gen_idx];
      w_id_nxt    = reg_id[gen_idx];
      w_entry_nxt = reg_entry[gen_idx];
      if (w_take & (w_hit_idx <= $bits(w_hit_idx)'(gen_idx))) begin
        w_valid_nxt = w_src_valid;
        w_id_nxt    = w_src_id;
        w_entry_nxt = w_src_entry;
      end
      if (i_push_en & (w_wr_cnt == $bits(w_wr_cnt)'(gen_idx))) begin
        w_valid_nxt = 1'b1;
        w_id_nxt    = i_push_id;
        w_entry_nxt = i_push_entry;
      end
    end

    // Valid flag of the entry: control state, reset to 0.
    always_ff @(posedge i_clk_axi, negedge i_rst_n_axi) begin : p_ff_valid
      if (!i_rst_n_axi)
        reg_valid[gen_idx] <= 1'b0;
      else
        reg_valid[gen_idx] <= w_valid_nxt;
    end

    // ID and attributes of the entry, resetless: read only while the valid flag is 1.
    always_ff @(posedge i_clk_axi) begin : p_ff_payload
      reg_id[gen_idx]    <= w_id_nxt;
      reg_entry[gen_idx] <= w_entry_nxt;
    end
  end

endmodule
