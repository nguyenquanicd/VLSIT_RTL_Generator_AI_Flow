/*
 * Project      : VLSIT Common RTL library
 * Author       : Nguyen Quan and Claude Sonnet 5.5 (user)
 * AI Flow      : VLSIT RTL Generator AI Automation Flow
 * AI Flow Page : https://github.com/nguyenquanicd/VLSIT_RTL_Generator_AI_Model
 * Date         : 2026-11-09
 * Description  : SHA-224 and SHA-256 compression core (FIPS 180-4 section 6.2). One block of 64
 *                bytes is processed in 64 / PARA_UNR clock cycles after the start pulse. The block
 *                arrives with message byte 0 in bits [7:0]; the core converts each 4-byte group to
 *                a big-endian word. The result is the input state plus the working variables.
 *                Decisions: DEC-006, DEC-019, DEC-021 (clear input).
 */
`timescale 1ns/1ps

module m_vlsit_sha_core256 #(
  // Parameter Description: rounds computed in one clock cycle; shall divide 64.
  // Parameter values: 1, 2, 4, 8, 16, 32 or 64; default is 1.
  // Parameter unit: count
  parameter logic [31:0] PARA_UNR = 1,
  localparam logic [31:0] LPARA_CYC_N = 64 / PARA_UNR,
  localparam logic [31:0] LPARA_CNT_W = $clog2(64 / PARA_UNR + 1),
  localparam logic [31:0] LPARA_WIN_N = 16 + PARA_UNR
) (
  // Clock and reset
  input  wire          i_clk_core,
  input  wire          i_rst_n_core,

  // Control
  input  wire          i_start,
  input  wire          i_clr,
  output logic         o_done,

  // Block and state
  input  wire  [511:0] i_block,
  input  wire  [255:0] i_state,
  output logic [255:0] o_result
);

  // Internal signal declarations
  logic [255:0] reg_v;
  logic [255:0] reg_s0;
  logic [511:0] reg_w;
  logic [LPARA_CNT_W-1:0] reg_cnt;
  logic reg_run;
  logic reg_done;

  logic [255:0] w_v_nxt;
  logic [511:0] w_w_nxt;
  logic [255:0] w_vs [0:PARA_UNR];
  logic [LPARA_WIN_N-1:0][31:0] w_win;
  logic [31:0] w_k;
  logic [6:0] w_kidx;
  logic [LPARA_CNT_W-1:0] w_cnt_nxt;
  logic w_last;

  // Round constants K0 to K63 of FIPS 180-4 section 4.2.2.
  function automatic logic [31:0] f_k(input logic [5:0] i_idx);
    case (i_idx)
      6'd0: f_k = 32'h428a2f98;
      6'd1: f_k = 32'h71374491;
      6'd2: f_k = 32'hb5c0fbcf;
      6'd3: f_k = 32'he9b5dba5;
      6'd4: f_k = 32'h3956c25b;
      6'd5: f_k = 32'h59f111f1;
      6'd6: f_k = 32'h923f82a4;
      6'd7: f_k = 32'hab1c5ed5;
      6'd8: f_k = 32'hd807aa98;
      6'd9: f_k = 32'h12835b01;
      6'd10: f_k = 32'h243185be;
      6'd11: f_k = 32'h550c7dc3;
      6'd12: f_k = 32'h72be5d74;
      6'd13: f_k = 32'h80deb1fe;
      6'd14: f_k = 32'h9bdc06a7;
      6'd15: f_k = 32'hc19bf174;
      6'd16: f_k = 32'he49b69c1;
      6'd17: f_k = 32'hefbe4786;
      6'd18: f_k = 32'h0fc19dc6;
      6'd19: f_k = 32'h240ca1cc;
      6'd20: f_k = 32'h2de92c6f;
      6'd21: f_k = 32'h4a7484aa;
      6'd22: f_k = 32'h5cb0a9dc;
      6'd23: f_k = 32'h76f988da;
      6'd24: f_k = 32'h983e5152;
      6'd25: f_k = 32'ha831c66d;
      6'd26: f_k = 32'hb00327c8;
      6'd27: f_k = 32'hbf597fc7;
      6'd28: f_k = 32'hc6e00bf3;
      6'd29: f_k = 32'hd5a79147;
      6'd30: f_k = 32'h06ca6351;
      6'd31: f_k = 32'h14292967;
      6'd32: f_k = 32'h27b70a85;
      6'd33: f_k = 32'h2e1b2138;
      6'd34: f_k = 32'h4d2c6dfc;
      6'd35: f_k = 32'h53380d13;
      6'd36: f_k = 32'h650a7354;
      6'd37: f_k = 32'h766a0abb;
      6'd38: f_k = 32'h81c2c92e;
      6'd39: f_k = 32'h92722c85;
      6'd40: f_k = 32'ha2bfe8a1;
      6'd41: f_k = 32'ha81a664b;
      6'd42: f_k = 32'hc24b8b70;
      6'd43: f_k = 32'hc76c51a3;
      6'd44: f_k = 32'hd192e819;
      6'd45: f_k = 32'hd6990624;
      6'd46: f_k = 32'hf40e3585;
      6'd47: f_k = 32'h106aa070;
      6'd48: f_k = 32'h19a4c116;
      6'd49: f_k = 32'h1e376c08;
      6'd50: f_k = 32'h2748774c;
      6'd51: f_k = 32'h34b0bcb5;
      6'd52: f_k = 32'h391c0cb3;
      6'd53: f_k = 32'h4ed8aa4a;
      6'd54: f_k = 32'h5b9cca4f;
      6'd55: f_k = 32'h682e6ff3;
      6'd56: f_k = 32'h748f82ee;
      6'd57: f_k = 32'h78a5636f;
      6'd58: f_k = 32'h84c87814;
      6'd59: f_k = 32'h8cc70208;
      6'd60: f_k = 32'h90befffa;
      6'd61: f_k = 32'ha4506ceb;
      6'd62: f_k = 32'hbef9a3f7;
      6'd63: f_k = 32'hc67178f2;
      default: f_k = '0;
    endcase
  endfunction

  // Rotate right of a 32-bit word by a constant amount.
  function automatic logic [31:0] f_rotr(input logic [31:0] i_x, input logic [5:0] i_n);
    f_rotr = (i_x >> i_n) | (i_x << (6'd32 - i_n));
  endfunction

  // Byte reversal of a 32-bit word: converts the little-endian packing of the block to the
  // big-endian message word of the standard.
  function automatic logic [31:0] f_swap(input logic [31:0] i_x);
    f_swap = {i_x[7:0], i_x[15:8], i_x[23:16], i_x[31:24]};
  endfunction

  // Message schedule sigma0 of FIPS 180-4 section 4.1.2.
  function automatic logic [31:0] f_sig0(input logic [31:0] i_x);
    f_sig0 = f_rotr(i_x, 6'd7) ^ f_rotr(i_x, 6'd18) ^ (i_x >> 3);
  endfunction

  // Message schedule sigma1 of FIPS 180-4 section 4.1.2.
  function automatic logic [31:0] f_sig1(input logic [31:0] i_x);
    f_sig1 = f_rotr(i_x, 6'd17) ^ f_rotr(i_x, 6'd19) ^ (i_x >> 10);
  endfunction

  // Round function: the next working variables a..h (a in bits [31:0]) from the current ones, the
  // round constant and the message word (FIPS 180-4 section 6.2.2 step 3).
  function automatic logic [255:0] f_round(input logic [255:0] i_v, input logic [31:0] i_kw);
    logic [31:0] ra;
    logic [31:0] rb;
    logic [31:0] rc;
    logic [31:0] rd;
    logic [31:0] re;
    logic [31:0] rf;
    logic [31:0] rg;
    logic [31:0] rh;
    logic [31:0] t1;
    logic [31:0] t2;
    begin
      ra = i_v[31:0];
      rb = i_v[63:32];
      rc = i_v[95:64];
      rd = i_v[127:96];
      re = i_v[159:128];
      rf = i_v[191:160];
      rg = i_v[223:192];
      rh = i_v[255:224];
      t1 = rh + (f_rotr(re, 6'd6) ^ f_rotr(re, 6'd11) ^ f_rotr(re, 6'd25))
         + ((re & rf) ^ (~re & rg)) + i_kw;
      t2 = (f_rotr(ra, 6'd2) ^ f_rotr(ra, 6'd13) ^ f_rotr(ra, 6'd22))
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
      w_win[idx] = reg_w[32*idx +: 32];
    for (int idx = 0; idx < PARA_UNR; idx++)
      w_win[16+idx] = f_sig1(w_win[14+idx]) + w_win[9+idx] + f_sig0(w_win[1+idx]) + w_win[idx];
    for (int idx = 0; idx < PARA_UNR; idx++) begin
      w_kidx = $bits(w_kidx)'(reg_cnt * PARA_UNR + idx);
      w_k = f_k(w_kidx[5:0]);
      w_vs[idx+1] = f_round(w_vs[idx], w_k + w_win[idx]);
    end
    w_v_nxt = w_vs[PARA_UNR];
    for (int idx = 0; idx < 16; idx++)
      w_w_nxt[32*idx +: 32] = w_win[idx+PARA_UNR];
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
          reg_w[32*idx +: 32] <= f_swap(i_block[32*idx +: 32]);
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
      o_result[32*idx +: 32] = reg_s0[32*idx +: 32] + reg_v[32*idx +: 32];
  end

  // The done flag is the registered end of the last round.
  assign o_done = reg_done;

endmodule
