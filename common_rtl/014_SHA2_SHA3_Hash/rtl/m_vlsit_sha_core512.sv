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

  // Round constants K0 to K79 of FIPS 180-4 section 4.2.3.
  function automatic logic [63:0] f_k(input logic [6:0] i_idx);
    case (i_idx)
      7'd0: f_k = 64'h428a2f98d728ae22;
      7'd1: f_k = 64'h7137449123ef65cd;
      7'd2: f_k = 64'hb5c0fbcfec4d3b2f;
      7'd3: f_k = 64'he9b5dba58189dbbc;
      7'd4: f_k = 64'h3956c25bf348b538;
      7'd5: f_k = 64'h59f111f1b605d019;
      7'd6: f_k = 64'h923f82a4af194f9b;
      7'd7: f_k = 64'hab1c5ed5da6d8118;
      7'd8: f_k = 64'hd807aa98a3030242;
      7'd9: f_k = 64'h12835b0145706fbe;
      7'd10: f_k = 64'h243185be4ee4b28c;
      7'd11: f_k = 64'h550c7dc3d5ffb4e2;
      7'd12: f_k = 64'h72be5d74f27b896f;
      7'd13: f_k = 64'h80deb1fe3b1696b1;
      7'd14: f_k = 64'h9bdc06a725c71235;
      7'd15: f_k = 64'hc19bf174cf692694;
      7'd16: f_k = 64'he49b69c19ef14ad2;
      7'd17: f_k = 64'hefbe4786384f25e3;
      7'd18: f_k = 64'h0fc19dc68b8cd5b5;
      7'd19: f_k = 64'h240ca1cc77ac9c65;
      7'd20: f_k = 64'h2de92c6f592b0275;
      7'd21: f_k = 64'h4a7484aa6ea6e483;
      7'd22: f_k = 64'h5cb0a9dcbd41fbd4;
      7'd23: f_k = 64'h76f988da831153b5;
      7'd24: f_k = 64'h983e5152ee66dfab;
      7'd25: f_k = 64'ha831c66d2db43210;
      7'd26: f_k = 64'hb00327c898fb213f;
      7'd27: f_k = 64'hbf597fc7beef0ee4;
      7'd28: f_k = 64'hc6e00bf33da88fc2;
      7'd29: f_k = 64'hd5a79147930aa725;
      7'd30: f_k = 64'h06ca6351e003826f;
      7'd31: f_k = 64'h142929670a0e6e70;
      7'd32: f_k = 64'h27b70a8546d22ffc;
      7'd33: f_k = 64'h2e1b21385c26c926;
      7'd34: f_k = 64'h4d2c6dfc5ac42aed;
      7'd35: f_k = 64'h53380d139d95b3df;
      7'd36: f_k = 64'h650a73548baf63de;
      7'd37: f_k = 64'h766a0abb3c77b2a8;
      7'd38: f_k = 64'h81c2c92e47edaee6;
      7'd39: f_k = 64'h92722c851482353b;
      7'd40: f_k = 64'ha2bfe8a14cf10364;
      7'd41: f_k = 64'ha81a664bbc423001;
      7'd42: f_k = 64'hc24b8b70d0f89791;
      7'd43: f_k = 64'hc76c51a30654be30;
      7'd44: f_k = 64'hd192e819d6ef5218;
      7'd45: f_k = 64'hd69906245565a910;
      7'd46: f_k = 64'hf40e35855771202a;
      7'd47: f_k = 64'h106aa07032bbd1b8;
      7'd48: f_k = 64'h19a4c116b8d2d0c8;
      7'd49: f_k = 64'h1e376c085141ab53;
      7'd50: f_k = 64'h2748774cdf8eeb99;
      7'd51: f_k = 64'h34b0bcb5e19b48a8;
      7'd52: f_k = 64'h391c0cb3c5c95a63;
      7'd53: f_k = 64'h4ed8aa4ae3418acb;
      7'd54: f_k = 64'h5b9cca4f7763e373;
      7'd55: f_k = 64'h682e6ff3d6b2b8a3;
      7'd56: f_k = 64'h748f82ee5defb2fc;
      7'd57: f_k = 64'h78a5636f43172f60;
      7'd58: f_k = 64'h84c87814a1f0ab72;
      7'd59: f_k = 64'h8cc702081a6439ec;
      7'd60: f_k = 64'h90befffa23631e28;
      7'd61: f_k = 64'ha4506cebde82bde9;
      7'd62: f_k = 64'hbef9a3f7b2c67915;
      7'd63: f_k = 64'hc67178f2e372532b;
      7'd64: f_k = 64'hca273eceea26619c;
      7'd65: f_k = 64'hd186b8c721c0c207;
      7'd66: f_k = 64'heada7dd6cde0eb1e;
      7'd67: f_k = 64'hf57d4f7fee6ed178;
      7'd68: f_k = 64'h06f067aa72176fba;
      7'd69: f_k = 64'h0a637dc5a2c898a6;
      7'd70: f_k = 64'h113f9804bef90dae;
      7'd71: f_k = 64'h1b710b35131c471b;
      7'd72: f_k = 64'h28db77f523047d84;
      7'd73: f_k = 64'h32caab7b40c72493;
      7'd74: f_k = 64'h3c9ebe0a15c9bebc;
      7'd75: f_k = 64'h431d67c49c100d4c;
      7'd76: f_k = 64'h4cc5d4becb3e42b6;
      7'd77: f_k = 64'h597f299cfc657e2a;
      7'd78: f_k = 64'h5fcb6fab3ad6faec;
      7'd79: f_k = 64'h6c44198c4a475817;
      default: f_k = '0;
    endcase
  endfunction

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
