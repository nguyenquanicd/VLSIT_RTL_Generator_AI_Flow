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
  // Parameter Description: parity of the state registers (REQ-SEC-002, DEC-035).
  // Parameter values: 0 or 1; default is 0.
  // Parameter unit: flag
  parameter logic [31:0] PARA_PAR = 0,
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
  output logic [255:0] o_result,
  output logic         o_par_err
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

@@FK256@@

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


  // Parity of the state registers (PARA_PAR = 1): one even-parity bit per 32 bits of reg_v, reg_w,
  // generated from the next value and checked while the core runs. A flipped bit of a register
  // gives a mismatch in the cycle in which it is read (REQ-SEC-002, DEC-035). The parity bits are
  // resetless like the data registers.
  logic [7:0]  reg_pv;
  logic [15:0] reg_pw;

  function automatic logic [7:0] f_parv(input logic [255:0] i_d);
    for (int idx = 0; idx < 8; idx++)
      f_parv[idx] = ^i_d[32*idx +: 32];
  endfunction

  function automatic logic [15:0] f_parw(input logic [511:0] i_d);
    for (int idx = 0; idx < 16; idx++)
      f_parw[idx] = ^i_d[32*idx +: 32];
  endfunction

  always_ff @(posedge i_clk_core) begin : p_ff_par
    casez ({i_start, i_clr, reg_run})
      3'b1??: begin
        reg_pv <= f_parv(i_state);
        reg_pw <= f_parw(i_block);
      end
      3'b01?: begin
        reg_pv <= '0;
        reg_pw <= '0;
      end
      3'b001: begin
        reg_pv <= f_parv(w_v_nxt);
        reg_pw <= f_parw(w_w_nxt);
      end
      default: begin
        // Idle: the parity bits keep their values.
      end
    endcase
  end

  always_comb begin : p_com_par
    o_par_err = (PARA_PAR != 32'd0) && reg_run && ((f_parv(reg_v) != reg_pv) || (f_parw(reg_w) != reg_pw));
  end

endmodule
