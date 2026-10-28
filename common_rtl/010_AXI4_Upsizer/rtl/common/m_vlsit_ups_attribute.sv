/*
 * Project      : VLSIT Common RTL library
 * Author       : Nguyen Quan and Claude Sonnet 5.5 (user)
 * AI Flow      : VLSIT RTL Generator AI Automation Flow
 * AI Flow Page : https://github.com/nguyenquanicd/VLSIT_RTL_Generator_AI_Model
 * Date         : 2026-10-28
 * Description  : Classification and attribute conversion of one AW or AR transaction of the AXI
 *                upsizer (OP-001, REQ-FUNC-002 to REQ-FUNC-006), in the implementation form of
 *                section 10.2 (REQ-RTL-004): shifts, masks, one small adder and compares, no
 *                multiplication, division or modulo. Combinational: no clock. A transaction is
 *                packable (o_pack = 1) when the Modifiable bit is 1, the lock is 0, the size is the
 *                full width of the S side, and the burst is INCR, or WRAP with a container below
 *                the width of the M side or a start address aligned to it. Packable INCR: size of
 *                the M side, length from the number of M words touched. Packable WRAP: container
 *                below M gives one M beat at the wrap boundary, otherwise a WRAP (or INCR of one
 *                beat) of container / M beats. Every other transaction keeps all attributes (lane
 *                steering). The reserved burst code passes unchanged.
 */
`timescale 1ns/1ps

module m_vlsit_ups_attribute #(
  // Parameter Description: data width of the subordinate side.
  // Parameter values: a power of 2 of 8 to 512; default is 32.
  // Parameter unit: bit
  parameter logic [31:0] PARA_AXI_S_DATA_W = 32,
  // Parameter Description: data width of the manager side. Larger than PARA_AXI_S_DATA_W.
  // Parameter values: a power of 2 of 16 to 1024; default is 128.
  // Parameter unit: bit
  parameter logic [31:0] PARA_AXI_M_DATA_W = 128,
  // Parameter Description: width of the address.
  // Parameter values: 12 to 64; default is 32.
  // Parameter unit: bit
  parameter logic [31:0] PARA_AXI_ADDR_W = 32,
  // Parameter Description: width of the burst length field: 8 for AXI4, 4 for AXI3.
  // Parameter values: 4 or 8; default is 8.
  // Parameter unit: bit
  parameter logic [31:0] PARA_AXI_LEN_W = 8,
  // Parameter Description: width of the lock field: 1 for AXI4, 2 for AXI3.
  // Parameter values: 1 or 2; default is 1.
  // Parameter unit: bit
  parameter logic [31:0] PARA_AXI_LOCK_W = 1,
  localparam logic [31:0] LPARA_RATIO = PARA_AXI_M_DATA_W / PARA_AXI_S_DATA_W,
  localparam logic [31:0] LPARA_RATIO_LOG2 = $clog2(PARA_AXI_M_DATA_W / PARA_AXI_S_DATA_W),
  localparam logic [31:0] LPARA_S_BYTES_LOG2 = $clog2(PARA_AXI_S_DATA_W / 8),
  localparam logic [31:0] LPARA_M_BYTES_LOG2 = $clog2(PARA_AXI_M_DATA_W / 8),
  localparam logic [31:0] LPARA_SUM_W = 10,
  localparam logic [31:0] LPARA_BURST_INCR = 1,
  localparam logic [31:0] LPARA_BURST_WRAP = 2,
  localparam logic [31:0] LPARA_MIN_WRAP_BEATS = 2
) (
  // Subordinate-side attributes
  input  wire  [PARA_AXI_ADDR_W-1:0] i_addr,
  input  wire  [PARA_AXI_LEN_W-1:0]  i_len,
  input  wire  [2:0]                 i_size,
  input  wire  [1:0]                 i_burst,
  input  wire  [PARA_AXI_LOCK_W-1:0] i_lock,
  input  wire                        i_modifiable,

  // Manager-side attributes
  output logic                       o_pack,
  output logic [PARA_AXI_ADDR_W-1:0] o_addr,
  output logic [PARA_AXI_LEN_W-1:0]  o_len,
  output logic [2:0]                 o_size,
  output logic [1:0]                 o_burst
);
  // LPARA_SUM_W: the sum of the first slot, the beat count and the ratio is at most
  // 127 + 256 + 127 = 510, so 10 bits. LPARA_BURST_*: burst codes of AXI (REF-001 A3.4.1).
  // LPARA_MIN_WRAP_BEATS: a WRAP burst of 2 or more M beats stays WRAP, one M beat becomes INCR.

  // Internal signal declarations
  logic [LPARA_SUM_W-1:0]        w_bl;
  logic [LPARA_RATIO_LOG2-1:0]   w_s0;
  logic                          w_is_incr;
  logic                          w_is_wrap;
  logic                          w_small;
  logic                          w_aligned_m;
  logic                          w_pack;
  logic [LPARA_SUM_W-1:0]        w_sum;
  logic [LPARA_SUM_W-1:0]        w_nm;
  logic [LPARA_SUM_W-1:0]        w_cont;
  logic [LPARA_M_BYTES_LOG2-1:0] w_cmask;
  logic [LPARA_SUM_W-1:0]        w_n_big;
  logic [2:0]                    w_sel;

  // Beat count and first slot: beats = length + 1; the first slot is the slot of the start address.
  assign w_bl = $bits(w_bl)'(i_len) + $bits(w_bl)'(1);
  assign w_s0 = i_addr[LPARA_M_BYTES_LOG2-1:LPARA_S_BYTES_LOG2];

  // Burst type decode, and the two WRAP conditions: the container (beats x S bytes) is below the
  // M side width, and the start address is aligned to the M side width.
  assign w_is_incr   = (i_burst == $bits(i_burst)'(LPARA_BURST_INCR));
  assign w_is_wrap   = (i_burst == $bits(i_burst)'(LPARA_BURST_WRAP));
  assign w_small     = (w_bl < $bits(w_bl)'(LPARA_RATIO));
  assign w_aligned_m = (i_addr[LPARA_M_BYTES_LOG2-1:0] == '0);

  // Packable: Modifiable, not locked, full S width, INCR or an allowed WRAP (REQ-FUNC-002).
  assign w_pack = i_modifiable & (i_lock == '0) & (i_size == $bits(i_size)'(LPARA_S_BYTES_LOG2))
                  & (w_is_incr | (w_is_wrap & (w_small | w_aligned_m)));

  // Output mapping: the pack flag tells the caller to use the packing path.
  assign o_pack = w_pack;

  // Packable INCR: number of M beats = ceil((first slot + beats) / ratio).
  assign w_sum = $bits(w_sum)'(w_s0) + w_bl + $bits(w_sum)'(LPARA_RATIO - 1);
  assign w_nm  = w_sum >> LPARA_RATIO_LOG2;

  // Packable WRAP with a container below M: the container size in bytes minus 1 is the mask of the
  // low address bits that the wrap boundary clears. The container is beats x S bytes.
  assign w_cont  = w_bl << LPARA_S_BYTES_LOG2;
  assign w_cmask = $bits(w_cmask)'(w_cont - 1'b1);

  // Packable WRAP with a container of M or more: M beats = beats / ratio.
  assign w_n_big = w_bl >> LPARA_RATIO_LOG2;

  // Case select: INCR, WRAP with a small container, WRAP with a large container (one-hot or none).
  assign w_sel = {w_pack & w_is_incr, w_pack & w_is_wrap & w_small, w_pack & w_is_wrap & ~w_small};

  // Manager-side attributes: a packable transaction takes the converted values, every other
  // transaction passes the subordinate-side values unchanged.
  always_comb begin : p_com_convert
    o_addr  = i_addr;
    o_len   = i_len;
    o_size  = i_size;
    o_burst = i_burst;
    case (w_sel)
      3'b100: begin
        o_size  = $bits(o_size)'(LPARA_M_BYTES_LOG2);
        o_len   = $bits(o_len)'(w_nm - 1'b1);
        o_burst = $bits(o_burst)'(LPARA_BURST_INCR);
      end
      3'b010: begin
        o_addr  = {i_addr[PARA_AXI_ADDR_W-1:LPARA_M_BYTES_LOG2], i_addr[LPARA_M_BYTES_LOG2-1:0] & ~w_cmask};
        o_size  = $bits(o_size)'(LPARA_M_BYTES_LOG2);
        o_len   = '0;
        o_burst = $bits(o_burst)'(LPARA_BURST_INCR);
      end
      3'b001: begin
        o_size  = $bits(o_size)'(LPARA_M_BYTES_LOG2);
        o_len   = $bits(o_len)'(w_n_big - 1'b1);
        o_burst = (w_n_big >= $bits(w_n_big)'(LPARA_MIN_WRAP_BEATS)) ? $bits(o_burst)'(LPARA_BURST_WRAP) : $bits(o_burst)'(LPARA_BURST_INCR);
      end
      default: begin
        o_addr  = i_addr;
        o_len   = i_len;
        o_size  = i_size;
        o_burst = i_burst;
      end
    endcase
  end

endmodule
