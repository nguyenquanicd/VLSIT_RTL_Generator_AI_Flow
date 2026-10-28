/*
 * Project      : VLSIT Common RTL library
 * Author       : Nguyen Quan and Claude Sonnet 5.5 (user)
 * AI Flow      : VLSIT RTL Generator AI Automation Flow
 * AI Flow Page : https://github.com/nguyenquanicd/VLSIT_RTL_Generator_AI_Model
 * Date         : 2026-10-28
 * Description  : Slot index and end-of-word flag of one S beat of the AXI upsizer (OP-007, REQ-
 *                FUNC-007), in the implementation form of section 10.2 (REQ-RTL-004).
 *                Combinational: no clock. For a packed burst the slot is a counter and a wrap mask:
 *                (first slot and not mask) or ((first slot + beat index) and mask), and the word is
 *                complete at the last slot or at the last beat. For a burst that is not packed the
 *                slot comes from a register of the low address bits that this module advances:
 *                FIXED keeps it, INCR adds the transfer size, WRAP adds it and wraps inside the
 *                container; the word is complete at every beat. Only the low LPARA_ADDR_LOW_W
 *                address bits are used. The first beat of a burst reads the start address, the
 *                following beats read the register i_cur_low that the caller loads with o_nxt_low.
 */
`timescale 1ns/1ps

module m_vlsit_ups_beat_addr #(
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
  localparam logic [31:0] LPARA_SUM_W = 10,
  localparam logic [31:0] LPARA_BURST_FIXED = 0,
  localparam logic [31:0] LPARA_BURST_WRAP = 2
) (
  // Burst attributes (subordinate side)
  input  wire                         i_pack,
  input  wire  [LPARA_ADDR_LOW_W-1:0] i_addr_low,
  input  wire  [PARA_AXI_LEN_W-1:0]   i_len,
  input  wire  [2:0]                  i_size,
  input  wire  [1:0]                  i_burst,

  // Beat state
  input  wire  [PARA_AXI_LEN_W-1:0]   i_idx,
  input  wire  [LPARA_ADDR_LOW_W-1:0] i_cur_low,

  // Beat result
  output logic [LPARA_RATIO_LOG2-1:0] o_slot,
  output logic                        o_word_last,
  output logic                        o_last,
  output logic [LPARA_ADDR_LOW_W-1:0] o_nxt_low
);
  // LPARA_SUM_W: beat count width (at most 256 beats). LPARA_BURST_*: burst codes of AXI
  // (REF-001 A3.4.1).

  // Internal signal declarations
  logic [LPARA_SUM_W-1:0]        w_bl;
  logic                          w_first;
  logic                          w_last;
  logic [LPARA_RATIO_LOG2-1:0]   w_s0;
  logic                          w_small_wrap;
  logic [LPARA_RATIO_LOG2-1:0]   w_wm;
  logic [LPARA_RATIO_LOG2-1:0]   w_idx_lr;
  logic [LPARA_RATIO_LOG2-1:0]   w_slot_p;
  logic                          w_word_last_p;
  logic [LPARA_ADDR_LOW_W-1:0]   w_cur;
  logic [LPARA_RATIO_LOG2-1:0]   w_slot_n;
  logic [LPARA_ADDR_LOW_W-1:0]   w_nb;
  logic [LPARA_ADDR_LOW_W-1:0]   w_base;
  logic [LPARA_ADDR_LOW_W-1:0]   w_step;
  logic [LPARA_SUM_W-1:0]        w_cont;
  logic [LPARA_ADDR_LOW_W-1:0]   w_mask;

  // Beat count, first-beat and last-beat flags.
  assign w_bl    = $bits(w_bl)'(i_len) + $bits(w_bl)'(1);
  assign w_first = (i_idx == '0);
  assign w_last  = (i_idx == i_len);

  // Packed burst: first slot, wrap mask and slot of this beat. The wrap mask is the number of slots
  // of the container minus 1 for a WRAP burst with a container below M, and all ones otherwise.
  assign w_s0         = i_addr_low[LPARA_M_BYTES_LOG2-1:LPARA_S_BYTES_LOG2];
  assign w_small_wrap = (i_burst == $bits(i_burst)'(LPARA_BURST_WRAP)) & (w_bl < $bits(w_bl)'(LPARA_RATIO));
  assign w_wm         = w_small_wrap ? $bits(w_wm)'(w_bl - 1'b1) : '1;
  assign w_idx_lr     = $bits(w_idx_lr)'(i_idx);
  assign w_slot_p     = (w_s0 & ~w_wm) | ((w_s0 + w_idx_lr) & w_wm);

  // Packed burst: the word is complete at the last beat, or at the last slot of an M word. A WRAP
  // burst with a container below M stays inside one M word, so only the last beat completes it.
  assign w_word_last_p = w_last | (~w_small_wrap & (w_slot_p == '1));

  // Burst that is not packed: the current low address (the start address for the first beat) and
  // its slot.
  assign w_cur    = w_first ? i_addr_low : i_cur_low;
  assign w_slot_n = w_cur[LPARA_M_BYTES_LOG2-1:LPARA_S_BYTES_LOG2];

  // Next low address: the address aligned to the transfer size plus the transfer size; a WRAP burst
  // keeps the bits above its container (beats << size bytes) and wraps inside it.
  assign w_nb   = $bits(w_nb)'(1) << i_size;
  assign w_base = w_cur & ~(w_nb - 1'b1);
  assign w_step = w_base + w_nb;
  assign w_cont = w_bl << i_size;
  assign w_mask = $bits(w_mask)'(w_cont - 1'b1);

  // Next low address selection by burst type: FIXED keeps the address, WRAP wraps in the container,
  // every other code (INCR, reserved) takes the next transfer address.
  always_comb begin : p_com_nxt_low
    o_nxt_low = w_step;
    case (i_burst)
      $bits(i_burst)'(LPARA_BURST_FIXED): o_nxt_low = w_cur;
      $bits(i_burst)'(LPARA_BURST_WRAP):  o_nxt_low = (w_cur & ~w_mask) | (w_step & w_mask);
      default:                            o_nxt_low = w_step;
    endcase
  end

  // Result selection: a packed burst uses the counter form, any other burst the address form.
  assign o_slot      = i_pack ? w_slot_p : w_slot_n;
  assign o_word_last = i_pack ? w_word_last_p : 1'b1;
  assign o_last      = w_last;

endmodule
