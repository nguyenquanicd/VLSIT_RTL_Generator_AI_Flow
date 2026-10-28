/*
 * Project      : VLSIT Common RTL library
 * Author       : Nguyen Quan and Claude Sonnet 5.5 (user)
 * AI Flow      : VLSIT RTL Generator AI Automation Flow
 * AI Flow Page : https://github.com/nguyenquanicd/VLSIT_RTL_Generator_AI_Model
 * Date         : 2026-10-28
 * Description  : W path of the AXI4 upsizer: packing and lane steering of the write data (OP-002,
 *                OP-003, REQ-FUNC-008, REQ-FUNC-009). It works on the head of the write transaction
 *                queue. Each accepted S beat is placed in the slot of its address of an
 *                accumulation register (data and strobes; the slots that are not written stay at
 *                zero). When the beat is the last of its M word (or of the transaction) the merged
 *                M beat goes to the W slice, otherwise it stays in the register. A burst that is
 *                not packed completes an M word at every beat, so each S beat becomes one M beat
 *                with its bytes in their byte lane. S-side WREADY is 0 while no transaction is in
 *                the queue (REQ-FUNC-010) and while a beat that completes an M word cannot be taken
 *                by the slice; it depends on registers only (REQ-IF-003). The queue entry is
 *                released with the last beat, so the next transaction follows in the next cycle
 *                (REQ-PERF-001).
 */
`timescale 1ns/1ps

module m_vlsit_ups_wr_pack #(
  // Parameter Description: data width of the subordinate side.
  // Parameter values: a power of 2 of 8 to 512; default is 32.
  // Parameter unit: bit
  parameter logic [31:0] PARA_AXI_S_DATA_W = 32,
  // Parameter Description: data width of the manager side. Larger than PARA_AXI_S_DATA_W.
  // Parameter values: a power of 2 of 16 to 1024; default is 128.
  // Parameter unit: bit
  parameter logic [31:0] PARA_AXI_M_DATA_W = 128,
  // Parameter Description: width of the burst length field: 8 for AXI4, 4 for AXI3.
  // Parameter values: 4 or 8; default is 8.
  // Parameter unit: bit
  parameter logic [31:0] PARA_AXI_LEN_W = 8,
  localparam logic [31:0] LPARA_RATIO = PARA_AXI_M_DATA_W / PARA_AXI_S_DATA_W,
  localparam logic [31:0] LPARA_RATIO_LOG2 = $clog2(PARA_AXI_M_DATA_W / PARA_AXI_S_DATA_W),
  localparam logic [31:0] LPARA_S_BYTES_LOG2 = $clog2(PARA_AXI_S_DATA_W / 8),
  localparam logic [31:0] LPARA_M_BYTES_LOG2 = $clog2(PARA_AXI_M_DATA_W / 8),
  localparam logic [31:0] LPARA_ADDR_LOW_W = (LPARA_M_BYTES_LOG2 > (LPARA_S_BYTES_LOG2 + 4)) ? LPARA_M_BYTES_LOG2 : (LPARA_S_BYTES_LOG2 + 4),
  localparam logic [31:0] LPARA_S_STRB_W = PARA_AXI_S_DATA_W / 8,
  localparam logic [31:0] LPARA_M_STRB_W = PARA_AXI_M_DATA_W / 8
) (
  // Clock and reset
  input  wire                          i_clk_axi,
  input  wire                          i_rst_n_axi,

  // Transaction queue head
  input  wire                          i_head_valid,
  input  wire                          i_head_pack,
  input  wire  [LPARA_ADDR_LOW_W-1:0]  i_head_addr_low,
  input  wire  [2:0]                   i_head_size,
  input  wire  [PARA_AXI_LEN_W-1:0]    i_head_len,
  input  wire  [1:0]                   i_head_burst,
  output logic                         o_head_pop,

  // Subordinate-side W beat
  input  wire                          i_wvalid,
  input  wire  [PARA_AXI_S_DATA_W-1:0] i_wdata,
  input  wire  [LPARA_S_STRB_W-1:0]    i_wstrb,
  output logic                         o_wready,

  // Manager-side W beat (to the W slice)
  output logic                         o_beat_valid,
  output logic [PARA_AXI_M_DATA_W-1:0] o_beat_data,
  output logic [LPARA_M_STRB_W-1:0]    o_beat_strb,
  output logic                         o_beat_last,
  input  wire                          i_beat_ready
);
  // Internal signal declarations
  logic [PARA_AXI_LEN_W-1:0]     reg_idx;
  logic [LPARA_ADDR_LOW_W-1:0]   reg_cur_low;
  logic [PARA_AXI_M_DATA_W-1:0]  reg_acc_data;
  logic [LPARA_M_STRB_W-1:0]     reg_acc_strb;
  logic [LPARA_RATIO_LOG2-1:0]   w_slot;
  logic                          w_word_last;
  logic                          w_last;
  logic [LPARA_ADDR_LOW_W-1:0]   w_nxt_low;
  logic [LPARA_RATIO-1:0]        w_slot_dec;
  logic                          w_acc;
  logic [PARA_AXI_M_DATA_W-1:0]  w_data_merged;
  logic [LPARA_M_STRB_W-1:0]     w_strb_merged;

  // Slot decode: one write enable per slot (one-hot).
  assign w_slot_dec = $bits(w_slot_dec)'(1) << w_slot;

  // S-side ready: a transaction is in the queue, and a beat that completes an M word needs the
  // W slice to be ready. Only registers drive it (no dependence on i_wvalid).
  assign o_wready = i_head_valid & (~w_word_last | i_beat_ready);

  // Accepted S beat.
  assign w_acc = i_wvalid & o_wready;

  // Output mapping: the merged beat goes to the W slice when the S beat completes an M word.
  assign o_beat_valid = w_acc & w_word_last;
  assign o_beat_data  = w_data_merged;
  assign o_beat_strb  = w_strb_merged;
  assign o_beat_last  = w_last;
  assign o_head_pop   = w_acc & w_last;

  // Merge: the S beat replaces the data and the strobes of its slot in the accumulation register.
  always_comb begin : p_com_merge
    w_data_merged = reg_acc_data;
    w_strb_merged = reg_acc_strb;
    for (int slt = 0; slt < LPARA_RATIO; slt++) begin
      if (w_slot_dec[slt]) begin
        w_data_merged[slt*PARA_AXI_S_DATA_W +: PARA_AXI_S_DATA_W] = i_wdata;
        w_strb_merged[slt*LPARA_S_STRB_W +: LPARA_S_STRB_W]       = i_wstrb;
      end
    end
  end

  // Beat counter and accumulation register: control state, reset to 0. The register is cleared when
  // the beat completes an M word, so the slots that are not written stay at zero.
  always_ff @(posedge i_clk_axi, negedge i_rst_n_axi) begin : p_ff_ctrl
    if (!i_rst_n_axi) begin
      reg_idx      <= '0;
      reg_acc_data <= '0;
      reg_acc_strb <= '0;
    end else if (w_acc) begin
      reg_idx      <= w_last ? '0 : $bits(reg_idx)'(reg_idx + 1'b1);
      reg_acc_data <= w_word_last ? '0 : w_data_merged;
      reg_acc_strb <= w_word_last ? '0 : w_strb_merged;
    end
  end

  // Low address of the next beat of a burst that is not packed. Resetless: the first beat of a
  // burst reads the start address of the queue head, not this register.
  always_ff @(posedge i_clk_axi) begin : p_ff_cur
    if (w_acc)
      reg_cur_low <= w_nxt_low;
  end

  // Beat address generator: slot index, end-of-word flag and last-beat flag of the current S beat,
  // and the next low address for a burst that is not packed.
  m_vlsit_ups_beat_addr #(
    .PARA_AXI_S_DATA_W (PARA_AXI_S_DATA_W),
    .PARA_AXI_M_DATA_W (PARA_AXI_M_DATA_W),
    .PARA_AXI_LEN_W    (PARA_AXI_LEN_W)
  ) u_beat_addr (
    .i_pack      (i_head_pack),
    .i_addr_low  (i_head_addr_low),
    .i_len       (i_head_len),
    .i_size      (i_head_size),
    .i_burst     (i_head_burst),
    .i_idx       (reg_idx),
    .i_cur_low   (reg_cur_low),
    .o_slot      (w_slot),
    .o_word_last (w_word_last),
    .o_last      (w_last),
    .o_nxt_low   (w_nxt_low)
  );

endmodule
