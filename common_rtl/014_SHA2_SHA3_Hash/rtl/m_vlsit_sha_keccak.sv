/*
 * Project      : VLSIT Common RTL library
 * Author       : Nguyen Quan and Claude Sonnet 5.5 (user)
 * AI Flow      : VLSIT RTL Generator AI Automation Flow
 * AI Flow Page : https://github.com/nguyenquanicd/VLSIT_RTL_Generator_AI_Model
 * Date         : 2026-11-09
 * Description  : Keccak-f[1600] permutation core for SHA-3 and SHAKE (FIPS 202 section 3). At the
 *                start pulse the block (zero extended to 1344 bits, message byte 0 in bits [7:0])
 *                is XORed into the input state, then PARA_UNR of the 24 rounds are computed in each
 *                clock cycle. Lane (x, y) is bits [64 x (x + 5 y) +: 64] of the state, which is the
 *                bit order of FIPS 202 section 3.1.2 and appendix B.1.
 *                Decisions: DEC-006, DEC-019, DEC-021 (clear input).
 */
`timescale 1ns/1ps

module m_vlsit_sha_keccak #(
  // Parameter Description: rounds computed in one clock cycle; shall divide 24.
  // Parameter values: 1, 2, 3, 4, 6, 8, 12 or 24; default is 1.
  // Parameter unit: count
  parameter logic [31:0] PARA_UNR = 1,
  localparam logic [31:0] LPARA_CYC_N = 24 / PARA_UNR,
  localparam logic [31:0] LPARA_CNT_W = $clog2(24 / PARA_UNR + 1)
) (
  // Clock and reset
  input  wire           i_clk_core,
  input  wire           i_rst_n_core,

  // Control
  input  wire           i_start,
  input  wire           i_clr,
  output logic          o_done,

  // Block and state
  input  wire  [1343:0] i_block,
  input  wire  [1599:0] i_state,
  output logic [1599:0] o_result
);

  // Internal signal declarations
  logic [1599:0] reg_st;
  logic [LPARA_CNT_W-1:0] reg_cnt;
  logic reg_run;
  logic reg_done;

  logic [1599:0] w_st_nxt;
  logic [1599:0] w_ss [0:PARA_UNR];
  logic [4:0] w_ridx;
  logic [LPARA_CNT_W-1:0] w_cnt_nxt;
  logic w_last;

  // Round constants RC[0] to RC[23] of FIPS 202 section 3.2.5.
  function automatic logic [63:0] f_rc(input logic [4:0] i_idx);
    case (i_idx)
      5'd0: f_rc = 64'h0000000000000001;
      5'd1: f_rc = 64'h0000000000008082;
      5'd2: f_rc = 64'h800000000000808a;
      5'd3: f_rc = 64'h8000000080008000;
      5'd4: f_rc = 64'h000000000000808b;
      5'd5: f_rc = 64'h0000000080000001;
      5'd6: f_rc = 64'h8000000080008081;
      5'd7: f_rc = 64'h8000000000008009;
      5'd8: f_rc = 64'h000000000000008a;
      5'd9: f_rc = 64'h0000000000000088;
      5'd10: f_rc = 64'h0000000080008009;
      5'd11: f_rc = 64'h000000008000000a;
      5'd12: f_rc = 64'h000000008000808b;
      5'd13: f_rc = 64'h800000000000008b;
      5'd14: f_rc = 64'h8000000000008089;
      5'd15: f_rc = 64'h8000000000008003;
      5'd16: f_rc = 64'h8000000000008002;
      5'd17: f_rc = 64'h8000000000000080;
      5'd18: f_rc = 64'h000000000000800a;
      5'd19: f_rc = 64'h800000008000000a;
      5'd20: f_rc = 64'h8000000080008081;
      5'd21: f_rc = 64'h8000000000008080;
      5'd22: f_rc = 64'h0000000080000001;
      5'd23: f_rc = 64'h8000000080008008;
      default: f_rc = '0;
    endcase
  endfunction

  // Rotation offsets of FIPS 202 section 3.2.2 for lane x + 5 y.
  function automatic logic [5:0] f_rot(input logic [4:0] i_idx);
    case (i_idx)
      5'd0: f_rot = 6'h00;
      5'd1: f_rot = 6'h01;
      5'd2: f_rot = 6'h3e;
      5'd3: f_rot = 6'h1c;
      5'd4: f_rot = 6'h1b;
      5'd5: f_rot = 6'h24;
      5'd6: f_rot = 6'h2c;
      5'd7: f_rot = 6'h06;
      5'd8: f_rot = 6'h37;
      5'd9: f_rot = 6'h14;
      5'd10: f_rot = 6'h03;
      5'd11: f_rot = 6'h0a;
      5'd12: f_rot = 6'h2b;
      5'd13: f_rot = 6'h19;
      5'd14: f_rot = 6'h27;
      5'd15: f_rot = 6'h29;
      5'd16: f_rot = 6'h2d;
      5'd17: f_rot = 6'h0f;
      5'd18: f_rot = 6'h15;
      5'd19: f_rot = 6'h08;
      5'd20: f_rot = 6'h12;
      5'd21: f_rot = 6'h02;
      5'd22: f_rot = 6'h3d;
      5'd23: f_rot = 6'h38;
      5'd24: f_rot = 6'h0e;
      default: f_rot = '0;
    endcase
  endfunction

  // Rotate left of a 64-bit lane by an offset of 0 to 63.
  function automatic logic [63:0] f_rotl(input logic [63:0] i_x, input logic [6:0] i_n);
    f_rotl = (i_x << i_n) | (i_x >> (7'd64 - i_n));
  endfunction

  // One round of Keccak-f[1600]: theta, rho, pi, chi, iota in this order (FIPS 202 section 3.3).
  // Lane (x, y) is the 64 bits at index x + 5 y of the lane array.
  function automatic logic [1599:0] f_round(input logic [1599:0] i_s, input logic [63:0] i_rc);
    logic [63:0] a [0:24];
    logic [63:0] b [0:24];
    logic [63:0] c [0:4];
    logic [63:0] d [0:4];
    logic [1599:0] r;
    begin
      for (int lane = 0; lane < 25; lane++)
        a[lane] = i_s[64*lane +: 64];
      // Theta: column parities and their diffusion into every lane.
      for (int x = 0; x < 5; x++)
        c[x] = a[x] ^ a[x+5] ^ a[x+10] ^ a[x+15] ^ a[x+20];
      for (int x = 0; x < 5; x++)
        d[x] = c[(x+4)%5] ^ f_rotl(c[(x+1)%5], 7'd1);
      for (int y = 0; y < 5; y++)
        for (int x = 0; x < 5; x++)
          a[x+5*y] = a[x+5*y] ^ d[x];
      // Rho and pi: rotate each lane and move it to lane (y, 2x + 3y).
      for (int y = 0; y < 5; y++)
        for (int x = 0; x < 5; x++)
          b[y+5*((2*x+3*y)%5)] = f_rotl(a[x+5*y], {1'b0, f_rot(5'(x+5*y))});
      // Chi: the only non-linear step, row by row.
      for (int y = 0; y < 5; y++)
        for (int x = 0; x < 5; x++)
          a[x+5*y] = b[x+5*y] ^ (~b[((x+1)%5)+5*y] & b[((x+2)%5)+5*y]);
      // Iota: round constant into lane (0, 0).
      a[0] = a[0] ^ i_rc;
      for (int lane = 0; lane < 25; lane++)
        r[64*lane +: 64] = a[lane];
      f_round = r;
    end
  endfunction

  // Rounds of one clock cycle: PARA_UNR rounds in series, with round constant index
  // cnt x PARA_UNR + j for round j of the cycle.
  always_comb begin : p_com_round
    w_ridx = '0;
    w_ss[0] = reg_st;
    for (int idx = 0; idx < PARA_UNR; idx++) begin
      w_ridx = $bits(w_ridx)'(reg_cnt * PARA_UNR + idx);
      w_ss[idx+1] = f_round(w_ss[idx], f_rc(w_ridx));
    end
    w_st_nxt = w_ss[PARA_UNR];
    w_last = (reg_cnt == LPARA_CNT_W'(LPARA_CYC_N - 1));
    w_cnt_nxt = reg_cnt + 1'b1;
  end

  // Control state: running and done flags are reset; the state register is resetless because
  // the result is only used while o_done is 1 (SEQ-04).
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

  // State register: absorbs the block at start, advances while running, zeroed by the clear input.
  always_ff @(posedge i_clk_core) begin : p_ff_data
    casez ({i_start, i_clr, reg_run})
      3'b1??:  reg_st <= i_state ^ {256'b0, i_block};
      3'b01?:  reg_st <= '0;
      3'b001:  reg_st <= w_st_nxt;
      default: reg_st <= reg_st;
    endcase
  end

  // The result is the state register; the done flag is the registered end of the last round.
  assign o_result = reg_st;
  assign o_done   = reg_done;

endmodule
