/*
 * Project      : VLSIT Common RTL library
 * Author       : Nguyen Quan and Claude Sonnet 5.5 (user)
 * AI Flow      : VLSIT RTL Generator AI Automation Flow
 * AI Flow Page : https://github.com/nguyenquanicd/VLSIT_RTL_Generator_AI_Model
 * Date         : 2026-10-28
 * Description  : R path of the AXI upsizer: unpacking and lane steering of the read data (OP-005,
 *                OP-006, REQ-FUNC-012, REQ-FUNC-013). It works on the head of the read transaction
 *                queue. An M-side R beat is taken into a word register; then one S beat per cycle
 *                is given to the R slice, with the data of the slot of the beat address (an AND-OR
 *                select with one enable per slot), the RRESP and the RID of the M beat copied to
 *                each S beat (REQ-ERR-001), and RLAST on the last S beat of the transaction counted
 *                from the length of the queue head. A burst that is not packed gives one S beat per
 *                M beat. The word register is reloaded in the cycle of its last S beat, so the read
 *                data flow without a bubble (REQ-PERF-001). The M side RREADY is 0 until the queue
 *                has an entry for the incoming beat. The data of the word register is not reset: it
 *                is used only while the valid flag is 1 (SEQ-04).
 */
`timescale 1ns/1ps

module m_vlsit_ups_rd_unpack #(
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
  localparam logic [31:0] LPARA_RATIO = PARA_AXI_M_DATA_W / PARA_AXI_S_DATA_W,
  localparam logic [31:0] LPARA_RATIO_LOG2 = $clog2(PARA_AXI_M_DATA_W / PARA_AXI_S_DATA_W),
  localparam logic [31:0] LPARA_S_BYTES_LOG2 = $clog2(PARA_AXI_S_DATA_W / 8),
  localparam logic [31:0] LPARA_M_BYTES_LOG2 = $clog2(PARA_AXI_M_DATA_W / 8),
  localparam logic [31:0] LPARA_ADDR_LOW_W = (LPARA_M_BYTES_LOG2 > (LPARA_S_BYTES_LOG2 + 4)) ? LPARA_M_BYTES_LOG2 : (LPARA_S_BYTES_LOG2 + 4)
) (
  // Clock and reset
  input  wire                          i_clk_axi,
  input  wire                          i_rst_n_axi,

  // Transaction queue head
  input  wire                          i_head_has_nxt,
  input  wire                          i_head_valid,
  input  wire                          i_head_pack,
  input  wire  [LPARA_ADDR_LOW_W-1:0]  i_head_addr_low,
  input  wire  [2:0]                   i_head_size,
  input  wire  [PARA_AXI_LEN_W-1:0]    i_head_len,
  input  wire  [1:0]                   i_head_burst,
  output logic                         o_head_pop,

  // Manager-side R beat
  input  wire                          i_rvalid,
  input  wire  [PARA_AXI_ID_W-1:0]     i_rid,
  input  wire  [PARA_AXI_M_DATA_W-1:0] i_rdata,
  input  wire  [1:0]                   i_rresp,
  output logic                         o_rready,

  // Subordinate-side R beat (to the R slice)
  output logic                         o_beat_valid,
  output logic [PARA_AXI_ID_W-1:0]     o_beat_id,
  output logic [PARA_AXI_S_DATA_W-1:0] o_beat_data,
  output logic [1:0]                   o_beat_resp,
  output logic                         o_beat_last,
  input  wire                          i_beat_ready
);
  // Internal signal declarations
  logic                          reg_word_valid;
  logic [PARA_AXI_ID_W-1:0]      reg_word_id;
  logic [PARA_AXI_M_DATA_W-1:0]  reg_word_data;
  logic [1:0]                    reg_word_resp;
  logic [PARA_AXI_LEN_W-1:0]     reg_idx;
  logic [LPARA_ADDR_LOW_W-1:0]   reg_cur_low;
  logic [LPARA_RATIO_LOG2-1:0]   w_slot;
  logic                          w_word_last;
  logic                          w_last;
  logic [LPARA_ADDR_LOW_W-1:0]   w_nxt_low;
  logic [LPARA_RATIO-1:0]        w_slot_dec;
  logic [PARA_AXI_S_DATA_W-1:0]  w_sel_data;
  logic                          w_xfer;
  logic                          w_word_done;
  logic                          w_load;

  // Slot decode: one select per slot (one-hot).
  assign w_slot_dec = $bits(w_slot_dec)'(1) << w_slot;

  // S beat for the R slice: valid while the word register holds a beat of the queue head.
  assign o_beat_valid = reg_word_valid & i_head_valid;
  assign o_beat_id    = reg_word_id;
  assign o_beat_data  = w_sel_data;
  assign o_beat_resp  = reg_word_resp;
  assign o_beat_last  = w_last;

  // Transfer, end of the word and release of the queue entry (last S beat of the transaction).
  assign w_xfer      = o_beat_valid & i_beat_ready;
  assign w_word_done = w_xfer & w_word_last;
  assign o_head_pop  = w_xfer & w_last;

  // M-side ready: with an empty word register it needs an entry in the queue; with a full word
  // register it is 1 only in the cycle of the last S beat of the word, and when that beat ends the
  // transaction the queue must hold a second entry for the incoming beat.
  assign o_rready = reg_word_valid ? (w_word_done & (~w_last | i_head_has_nxt)) : i_head_valid;

  // Accepted M beat.
  assign w_load = i_rvalid & o_rready;

  // Slot select: AND-OR of the S-bit fields of the word register with the one-hot slot decode.
  always_comb begin : p_com_sel
    w_sel_data = '0;
    for (int slt = 0; slt < LPARA_RATIO; slt++) begin
      w_sel_data = w_sel_data | (reg_word_data[slt*PARA_AXI_S_DATA_W +: PARA_AXI_S_DATA_W]
                                 & {PARA_AXI_S_DATA_W{w_slot_dec[slt]}});
    end
  end

  // Word valid flag and S beat counter: control state, reset to 0. A new M beat has priority over
  // the end of the word, so the register is reloaded in the same cycle.
  always_ff @(posedge i_clk_axi, negedge i_rst_n_axi) begin : p_ff_ctrl
    if (!i_rst_n_axi) begin
      reg_word_valid <= 1'b0;
      reg_idx        <= '0;
    end else begin
      if (w_load)
        reg_word_valid <= 1'b1;
      else if (w_word_done)
        reg_word_valid <= 1'b0;
      if (w_xfer)
        reg_idx <= w_last ? '0 : $bits(reg_idx)'(reg_idx + 1'b1);
    end
  end

  // Word register payload, resetless: used only while reg_word_valid is 1.
  always_ff @(posedge i_clk_axi) begin : p_ff_word
    if (w_load) begin
      reg_word_id   <= i_rid;
      reg_word_data <= i_rdata;
      reg_word_resp <= i_rresp;
    end
  end

  // Low address of the next S beat of a burst that is not packed. Resetless: the first beat of a
  // burst reads the start address of the queue head, not this register.
  always_ff @(posedge i_clk_axi) begin : p_ff_cur
    if (w_xfer)
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
