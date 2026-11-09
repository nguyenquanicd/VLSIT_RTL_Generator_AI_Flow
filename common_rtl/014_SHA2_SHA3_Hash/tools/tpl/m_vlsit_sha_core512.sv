/*
 * Project      : VLSIT Common RTL library
 * Author       : Nguyen Quan and Claude Sonnet 5.5 (user)
 * AI Flow      : VLSIT RTL Generator AI Automation Flow
 * AI Flow Page : https://github.com/nguyenquanicd/VLSIT_RTL_Generator_AI_Model
 * Date         : 2026-11-09
 * Description  : SHA-384, SHA-512, SHA-512/224 and SHA-512/256 compression core (FIPS 180-4
 *                section 6.4). One block of 128 bytes is processed in 80 / PARA_UNR clock cycles
 *                after the start pulse. The block arrives with message byte 0 in bits [7:0]; the
 *                core converts each 8-byte group to a big-endian 64-bit word. The result is the
 *                input state plus the working variables.
 *                Decisions: DEC-006, DEC-019, DEC-021 (clear input).
 */
`timescale 1ns/1ps

module m_vlsit_sha_core512 #(
  // Parameter Description: rounds computed in one clock cycle; shall divide 80.
  // Parameter values: 1, 2, 4, 5, 8, 10, 16, 20, 40 or 80; default is 1.
  // Parameter unit: count
  parameter logic [31:0] PARA_UNR = 1,
  localparam logic [31:0] LPARA_CYC_N = 80 / PARA_UNR,
  localparam logic [31:0] LPARA_CNT_W = $clog2(80 / PARA_UNR + 1),
  localparam logic [31:0] LPARA_WIN_N = 16 + PARA_UNR
) (
  // Clock and reset
  input  wire           i_clk_core,
  input  wire           i_rst_n_core,

  // Control
  input  wire           i_start,
  input  wire           i_clr,
  output logic          o_done,

  // Block and state
  input  wire  [1023:0] i_block,
  input  wire  [511:0]  i_state,
  output logic [511:0]  o_result
);

  // Internal signal declarations
  logic [511:0] reg_v;
  logic [511:0] reg_s0;
  logic [1023:0] reg_w;
  logic [LPARA_CNT_W-1:0] reg_cnt;
  logic reg_run;
  logic reg_done;

  logic [511:0] w_v_nxt;
  logic [1023:0] w_w_nxt;
  logic [511:0] w_vs [0:PARA_UNR];
  logic [LPARA_WIN_N-1:0][63:0] w_win;
  logic [63:0] w_k;
  logic [6:0] w_kidx;
  logic [LPARA_CNT_W-1:0] w_cnt_nxt;
  logic w_last;

@@FK512@@

  // Rotate right of a 64-bit word by a constant amount.
  function automatic logic [63:0] f_rotr(input logic [63:0] i_x, input logic [6:0] i_n);
    f_rotr = (i_x >> i_n) | (i_x << (7'd64 - i_n));
  endfunction

  // Byte reversal of a 64-bit word: converts the little-endian packing of the block to the
  // big-endian message word of the standard.
  function automatic logic [63:0] f_swap(input logic [63:0] i_x);
    f_swap = {i_x[7:0], i_x[15:8], i_x[23:16], i_x[31:24], i_x[39:32], i_x[47:40], i_x[55:48], i_x[63:56]};
  endfunction

  // Message schedule sigma0 of FIPS 180-4 section 4.1.3.
  function automatic logic [63:0] f_sig0(input logic [63:0] i_x);
    f_sig0 = f_rotr(i_x, 7'd1) ^ f_rotr(i_x, 7'd8) ^ (i_x >> 7);
  endfunction

  // Message schedule sigma1 of FIPS 180-4 section 4.1.3.
  function automatic logic [63:0] f_sig1(input logic [63:0] i_x);
    f_sig1 = f_rotr(i_x, 7'd19) ^ f_rotr(i_x, 7'd61) ^ (i_x >> 6);
  endfunction

  // Round function: the next working variables a..h (a in bits [63:0]) from the current ones, the
  // round constant plus message word (FIPS 180-4 section 6.4.2 step 3).
  function automatic logic [511:0] f_round(input logic [511:0] i_v, input logic [63:0] i_kw);
    logic [63:0] ra;
    logic [63:0] rb;
    logic [63:0] rc;
    logic [63:0] rd;
    logic [63:0] re;
    logic [63:0] rf;
    logic [63:0] rg;
    logic [63:0] rh;
    logic [63:0] t1;
    logic [63:0] t2;
    begin
      ra = i_v[63:0];
      rb = i_v[127:64];
      rc = i_v[191:128];
      rd = i_v[255:192];
      re = i_v[319:256];
      rf = i_v[383:320];
      rg = i_v[447:384];
      rh = i_v[511:448];
      t1 = rh + (f_rotr(re, 7'd14) ^ f_rotr(re, 7'd18) ^ f_rotr(re, 7'd41))
         + ((re & rf) ^ (~re & rg)) + i_kw;
      t2 = (f_rotr(ra, 7'd28) ^ f_rotr(ra, 7'd34) ^ f_rotr(ra, 7'd39))
         + ((ra & rb) ^ (ra & rc) ^ (rb & rc));
      f_round = {rg, rf, re, rd + t1, rc, rb, ra, t1 + t2};
    end
  endfunction

  // Message schedule window and rounds of one clock cycle. w_win[0..15] is the current window
  // W[t] .. W[t+15]; the next PARA_UNR words are derived from it. Round j of the cycle uses
  // w_win[j] and the constant K[cnt x PARA_UNR + j]. The window then moves by PARA_UNR words.
  always_comb begin : p_com_round
    w_k = '0;
    w_kidx = '0;
    w_w_nxt = '0;
    w_win = '0;
    w_vs[0] = reg_v;
    for (int idx = 0; idx < 16; idx++)
      w_win[idx] = reg_w[64*idx +: 64];
    for (int idx = 0; idx < PARA_UNR; idx++)
      w_win[16+idx] = f_sig1(w_win[14+idx]) + w_win[9+idx] + f_sig0(w_win[1+idx]) + w_win[idx];
    for (int idx = 0; idx < PARA_UNR; idx++) begin
      w_kidx = $bits(w_kidx)'(reg_cnt * PARA_UNR + idx);
      w_k = f_k(w_kidx);
      w_vs[idx+1] = f_round(w_vs[idx], w_k + w_win[idx]);
    end
    w_v_nxt = w_vs[PARA_UNR];
    for (int idx = 0; idx < 16; idx++)
      w_w_nxt[64*idx +: 64] = w_win[idx+PARA_UNR];
    w_last = (reg_cnt == LPARA_CNT_W'(LPARA_CYC_N - 1));
    w_cnt_nxt = reg_cnt + 1'b1;
  end

  // Control state: running and done flags are reset; the datapath registers below are resetless
  // because the result is only used while o_done is 1 (SEQ-04).
  always_ff @(posedge i_clk_core, negedge i_rst_n_core) begin : p_ff_ctrl
    if (!i_rst_n_core) begin
      reg_run  <= 1'b0;
      reg_done <= 1'b0;
      reg_cnt  <= '0;
    end else begin
      casez ({i_start, i_clr, reg_run})
        3'b1??: begin
          reg_run  <= 1'b1;
          reg_done <= 1'b0;
          reg_cnt  <= '0;
        end
        3'b01?: begin
          reg_run  <= 1'b0;
          reg_done <= 1'b0;
          reg_cnt  <= '0;
        end
        3'b001: begin
          reg_cnt <= w_cnt_nxt;
          if (w_last) begin
            reg_run  <= 1'b0;
            reg_done <= 1'b1;
          end
        end
        default: begin
          // Idle: the flags and the counter keep their values.
        end
      endcase
    end
  end

  // Datapath registers: loaded at start, advanced while running, zeroed by the clear input.
  always_ff @(posedge i_clk_core) begin : p_ff_data
    casez ({i_start, i_clr, reg_run})
      3'b1??: begin
        reg_v  <= i_state;
        reg_s0 <= i_state;
        for (int idx = 0; idx < 16; idx++)
          reg_w[64*idx +: 64] <= f_swap(i_block[64*idx +: 64]);
      end
      3'b01?: begin
        reg_v  <= '0;
        reg_s0 <= '0;
        reg_w  <= '0;
      end
      3'b001: begin
        reg_v <= w_v_nxt;
        reg_w <= w_w_nxt;
      end
      default: begin
        // Idle: the datapath registers keep their values.
      end
    endcase
  end

  // Result: intermediate hash value plus the working variables, word by word.
  always_comb begin : p_com_result
    o_result = '0;
    for (int idx = 0; idx < 8; idx++)
      o_result[64*idx +: 64] = reg_s0[64*idx +: 64] + reg_v[64*idx +: 64];
  end

  // The done flag is the registered end of the last round.
  assign o_done = reg_done;

endmodule
