/*
 * Project      : VLSIT Common RTL library
 * Author       : Nguyen Quan and Claude Sonnet 5.5 (user)
 * AI Flow      : VLSIT RTL Generator AI Automation Flow
 * AI Flow Page : https://github.com/nguyenquanicd/VLSIT_RTL_Generator_AI_Model
 * Date         : 2026-11-09
 * Description  : Digest word pusher. For each context that the sequencer marks as pushable it
 *                reads the stored hash state and writes one digest word per cycle into the output
 *                FIFO of that context when the FIFO has room. The word is built from the state in
 *                the byte order of the standard (SHA-2: big-endian words, SHA-3 and SHAKE: state
 *                byte i is output byte i); bytes beyond the digest length of the algorithm are
 *                zero (DEC-020). A fixed digest ends after its last word (the done event). A SHAKE
 *                context ends a block after rate / word bytes and asks the sequencer for the
 *                next permutation (the permutation event); the output stream stays continuous
 *                because every rate is a whole number of words (DEC-019).
 *                Decisions: DEC-019, DEC-020, DEC-036.
 */
`timescale 1ns/1ps

module m_vlsit_sha_outp #(
  // Parameter Description: number of contexts.
  // Parameter values: 1 to 16; default is 1.
  // Parameter unit: count
  parameter logic [31:0] PARA_CTX_N = 1,
  // Parameter Description: AXI data width, the width of one output word.
  // Parameter values: 32, 64 or 128; default is 64.
  // Parameter unit: bit
  parameter logic [31:0] PARA_AXI_DW = 64,
  // Parameter Description: width of one state word of the context memory.
  // Parameter values: 256, 512 or 1600; default is 256.
  // Parameter unit: bit
  parameter logic [31:0] PARA_STW = 256,
  localparam logic [31:0] LPARA_CTX_W = (PARA_CTX_N > 1) ? $clog2(PARA_CTX_N) : 1,
  localparam logic [31:0] LPARA_WB = PARA_AXI_DW / 8
) (
  // Clock and reset
  input  wire                        i_clk_core,
  input  wire                        i_rst_n_core,

  // Context flags and clear request from the sequencer
  input  wire  [PARA_CTX_N-1:0]      i_push_flag,
  input  wire  [PARA_CTX_N-1:0][3:0] i_ctx_alg,
  input  wire  [PARA_CTX_N-1:0]      i_clr_ctx,

  // Context memory read port 1
  output logic [LPARA_CTX_W-1:0]     o_rd_ctx,
  input  wire  [PARA_STW-1:0]        i_rd_data,

  // Output FIFO push
  input  wire  [PARA_CTX_N-1:0]      i_out_full,
  output logic                       o_push_en,
  output logic [LPARA_CTX_W-1:0]     o_push_ctx,
  output logic [PARA_AXI_DW-1:0]     o_push_data,

  // End of block events
  output logic                       o_done_ev,
  output logic [LPARA_CTX_W-1:0]     o_done_ctx,
  output logic                       o_perm_ev,
  output logic [LPARA_CTX_W-1:0]     o_perm_ctx
);

  // Internal signal declarations
  logic [PARA_CTX_N-1:0][7:0] reg_off;
  logic [PARA_CTX_N-1:0]      reg_fin;
  logic [LPARA_CTX_W-1:0]     reg_ptr;
  logic [PARA_CTX_N-1:0]      w_el;
  logic                       w_hit;
  logic [LPARA_CTX_W-1:0]     w_sel;
  logic [31:0]                w_cand;
  logic [3:0]                 w_alg;
  logic [31:0]                w_dig_bytes;
  logic [31:0]                w_nwords;
  logic [7:0]                 w_off;
  logic                       w_is_shake;
  logic                       w_last_word;
  logic [PARA_CTX_N-1:0][7:0] w_off_nxt;
  logic [PARA_CTX_N-1:0]      w_fin_nxt;
  logic [3199:0]              w_rd_ext;
  logic [1599:0]              w_state_u;

  // Digest length of an algorithm in bytes; 0 means an open output (SHAKE).
  function automatic logic [31:0] f_dlen(input logic [3:0] i_alg);
    case (i_alg)
      4'd0:    f_dlen = 32'd28;
      4'd1:    f_dlen = 32'd32;
      4'd2:    f_dlen = 32'd48;
      4'd3:    f_dlen = 32'd64;
      4'd4:    f_dlen = 32'd28;
      4'd5:    f_dlen = 32'd32;
      4'd8:    f_dlen = 32'd28;
      4'd9:    f_dlen = 32'd32;
      4'd10:   f_dlen = 32'd48;
      4'd11:   f_dlen = 32'd64;
      default: f_dlen = 32'd0;
    endcase
  endfunction

  // Block of a SHAKE function in bytes (the rate); 0 for the fixed digest functions.
  function automatic logic [31:0] f_rate(input logic [3:0] i_alg);
    case (i_alg)
      4'd12:   f_rate = 32'd168;
      4'd13:   f_rate = 32'd136;
      default: f_rate = 32'd0;
    endcase
  endfunction

  // Byte k of the digest stream of the state. SHA-224 and SHA-256 keep eight 32-bit words and
  // SHA-384 to SHA-512/256 eight 64-bit words, each word output most significant byte first; the
  // Keccak state is output byte by byte from bit 0 (FIPS 180-4 section 6, FIPS 202 section 3.1).
  function automatic logic [7:0] f_dbyte(input logic [3:0] i_alg, input logic [1599:0] i_s,
                                         input logic [7:0] i_k);
    logic [10:0] pos;
    begin
      f_dbyte = 8'h00;
      case (i_alg)
        4'd0,
        4'd1: begin
          pos = {i_k[7:2], 5'b0} + {6'b0, 3'd3 - {1'b0, i_k[1:0]}, 3'b0};
          f_dbyte = i_s[pos +: 8];
        end
        4'd2,
        4'd3,
        4'd4,
        4'd5: begin
          pos = {i_k[7:3], 6'b0} + {5'b0, 3'd7 - i_k[2:0], 3'b0};
          f_dbyte = i_s[pos +: 8];
        end
        default: begin
          pos = {i_k, 3'b0};
          f_dbyte = i_s[pos +: 8];
        end
      endcase
    end
  endfunction

  // Candidate selection: the first context from reg_ptr + 1 (round robin) that is pushable, has
  // not just finished a block and has room in its output FIFO.
  // The state read from the context memory: with the masked core (width 3200) it holds two
  // shares and the digest is their xor; a narrower state has no second share (zero extended).
  always_comb begin : p_com_unmask
    w_rd_ext  = 3200'(i_rd_data);
    w_state_u = w_rd_ext[1599:0] ^ w_rd_ext[3199:1600];
  end

  always_comb begin : p_com_sel
    w_el  = '0;
    w_hit = 1'b0;
    w_sel = '0;
    w_cand = 32'd0;
    for (int idx = 0; idx < PARA_CTX_N; idx++)
      w_el[idx] = i_push_flag[idx] && !reg_fin[idx] && !i_out_full[idx];
    for (int k = PARA_CTX_N - 1; k >= 0; k--) begin
      w_cand = (32'(reg_ptr) + 32'd1 + 32'(k)) % PARA_CTX_N;
      if (w_el[w_cand[LPARA_CTX_W-1:0]]) begin
        w_hit = 1'b1;
        w_sel = w_cand[LPARA_CTX_W-1:0];
      end
    end
  end

  // Word construction for the selected context: the bytes of the word at word offset w_off.
  always_comb begin : p_com_word
    w_alg       = i_ctx_alg[w_sel];
    w_off       = reg_off[w_sel];
    w_dig_bytes = f_dlen(w_alg);
    w_is_shake  = (f_rate(w_alg) != 32'd0);
    w_nwords    = w_is_shake ? (f_rate(w_alg) / LPARA_WB) : ((w_dig_bytes + LPARA_WB - 32'd1) / LPARA_WB);
    w_last_word = ((32'(w_off) + 32'd1) == w_nwords);
    o_rd_ctx    = w_sel;
    o_push_data = '0;
    for (int idx = 0; idx < LPARA_WB; idx++) begin
      if (w_is_shake || ((32'(w_off) * LPARA_WB + 32'(idx)) < w_dig_bytes))
        o_push_data[8*idx +: 8] = f_dbyte(w_alg, w_state_u, 8'(32'(w_off) * LPARA_WB + 32'(idx)));
    end
    o_push_en  = w_hit;
    o_push_ctx = w_sel;
    o_done_ev  = w_hit && w_last_word && !w_is_shake;
    o_done_ctx = w_sel;
    o_perm_ev  = w_hit && w_last_word && w_is_shake;
    o_perm_ctx = w_sel;
  end

  // Offset and finish flag of each context. A push advances the offset; the last word of a block
  // resets it and sets the finish flag, which holds until the sequencer drops the push flag
  // (the sequencer needs one cycle to react). A clear request resets both.
  always_comb begin : p_com_off
    w_off_nxt = reg_off;
    w_fin_nxt = reg_fin;
    for (int idx = 0; idx < PARA_CTX_N; idx++) begin
      if (!i_push_flag[idx])
        w_fin_nxt[idx] = 1'b0;
      if (w_hit && (w_sel == LPARA_CTX_W'(idx))) begin
        if (w_last_word) begin
          w_off_nxt[idx] = 8'd0;
          w_fin_nxt[idx] = 1'b1;
        end else begin
          w_off_nxt[idx] = reg_off[idx] + 8'd1;
        end
      end
      if (i_clr_ctx[idx]) begin
        w_off_nxt[idx] = 8'd0;
        w_fin_nxt[idx] = 1'b0;
      end
    end
  end

  // Registers: control state, reset to zero.
  always_ff @(posedge i_clk_core, negedge i_rst_n_core) begin : p_ff_off
    if (!i_rst_n_core) begin
      reg_off <= '0;
      reg_fin <= '0;
      reg_ptr <= '0;
    end else begin
      reg_off <= w_off_nxt;
      reg_fin <= w_fin_nxt;
      if (w_hit)
        reg_ptr <= w_sel;
    end
  end

endmodule
