/*
 * Project      : VLSIT Common RTL library
 * Author       : Nguyen Quan and Claude Sonnet 5.5 (user)
 * AI Flow      : VLSIT RTL Generator AI Automation Flow
 * AI Flow Page : https://github.com/nguyenquanicd/VLSIT_RTL_Generator_AI_Model
 * Date         : 2026-11-10
 * Description  : First-order masked Keccak-f[1600] core of the SHA2 and SHA3 hash IP (stage 2b,
 *                REQ-SEC-003). The state is held as two shares s0 and s1 (state = s0 xor s1). A
 *                round takes two cycles. Phase 0: theta, rho and pi are linear and act on each
 *                share; the cross products of the chi step u0.v1 and u1.v0 are masked with one
 *                fresh random bit per chi AND gate and registered (domain-oriented masking,
 *                DOM-indep, one register stage between the cross-domain terms and their use).
 *                Phase 1: the chi step
 *                is completed from the registered cross terms and the share-wise products u0.v0 and
 *                u1.v1, and iota is added to share 0. At the start the two shares are refreshed
 *                with
 *                the same random value R and the message block is added to share 0, so no register
 *                holds an unmasked value. With i_mask_en = 0 the random bits are 0: share 1 stays 0
 *                and the core computes the plain function (messages without masking in a build with
 *                PARA_MASK = 1). A block takes 24 x 2 + 2 cycles. The state registers are resetless
 *                (SEQ-04).
 *                Decisions: DEC-036, DEC-037.
 */
`timescale 1ns/1ps

module m_vlsit_sha_keccak_dom #(
  // Parameter Description: parity of the share and cross-term registers (REQ-SEC-002, DEC-035).
  // Parameter values: 0 or 1; default is 0.
  // Parameter unit: flag
  parameter logic [31:0] PARA_PAR = 0
) (
  // Clock and reset
  input  wire           i_clk_core,
  input  wire           i_rst_n_core,

  // Control
  input  wire           i_start,
  input  wire           i_clr,
  output logic          o_done,

  // Block, shared state and fresh random bits (new bits in every cycle)
  input  wire  [1343:0] i_block,
  input  wire  [3199:0] i_state,
  input  wire  [1599:0] i_rnd,
  input  wire           i_mask_en,
  output logic [3199:0] o_result,
  output logic          o_par_err
);

  // Internal signal declarations
  logic [1599:0] reg_s0;
  logic [1599:0] reg_s1;
  logic [1599:0] reg_x0;
  logic [1599:0] reg_x1;
  logic [4:0]    reg_cnt;
  logic          reg_ph;
  logic          reg_run;
  logic          reg_done;

  logic [1599:0] w_b0;
  logic [1599:0] w_b1;
  logic [1599:0] w_t0;
  logic [1599:0] w_t1;
  logic [1599:0] w_a0;
  logic [1599:0] w_a1;
  logic [1599:0] w_r;
  logic [1599:0] w_rc;
  logic          w_last;

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


  // Linear layer of a round (theta, rho, pi) of one share, the same lane moves as f_round before
  // chi.
  function automatic logic [1599:0] f_lin(input logic [1599:0] i_s);
    logic [63:0] a [0:24];
    logic [63:0] b [0:24];
    logic [63:0] c [0:4];
    logic [63:0] d [0:4];
    logic [1599:0] r;
    begin
      for (int lane = 0; lane < 25; lane++)
        a[lane] = i_s[64*lane +: 64];
      for (int x = 0; x < 5; x++)
        c[x] = a[x] ^ a[x+5] ^ a[x+10] ^ a[x+15] ^ a[x+20];
      for (int x = 0; x < 5; x++)
        d[x] = c[(x+4)%5] ^ f_rotl(c[(x+1)%5], 7'd1);
      for (int y = 0; y < 5; y++)
        for (int x = 0; x < 5; x++)
          a[x+5*y] = a[x+5*y] ^ d[x];
      for (int y = 0; y < 5; y++)
        for (int x = 0; x < 5; x++)
          b[y+5*((2*x+3*y)%5)] = f_rotl(a[x+5*y], {1'b0, f_rot(5'(x+5*y))});
      for (int lane = 0; lane < 25; lane++)
        r[64*lane +: 64] = b[lane];
      f_lin = r;
    end
  endfunction

  // Row neighbour of the chi step: lane (x, y) of the result is lane (x + k, y) of the input.
  function automatic logic [1599:0] f_nb(input logic [1599:0] i_b, input logic [2:0] i_k);
    logic [1599:0] r;
    begin
      for (int y = 0; y < 5; y++)
        for (int x = 0; x < 5; x++)
          r[64*(x+5*y) +: 64] = i_b[64*(((x+i_k)%5)+5*y) +: 64];
      f_nb = r;
    end
  endfunction

  // Even parity of each 32-bit lane of a state share.
  function automatic logic [49:0] f_pars(input logic [1599:0] i_d);
    for (int idx = 0; idx < 50; idx++)
      f_pars[idx] = ^i_d[32*idx +: 32];
  endfunction

  // Linear layer of both shares and the random bits of the cycle (0 without masking).
  always_comb begin : p_com_lin
    w_b0   = f_lin(reg_s0);
    w_b1   = f_lin(reg_s1);
    w_r    = i_mask_en ? i_rnd : '0;
    // Random bits of the chi step: the bits of the refresh word moved by five lanes. The random
    // bits of
    // the first round are a public function of the refresh word (next state of the random source);
    // at
    // the same bit position its linear part would cancel the mask and expose the message.
    w_rc   = {w_r[1279:0], w_r[1599:1280]};
    w_last = (reg_cnt == 5'd23);
  end

  // Chi of the two phases. Phase 0 forms the masked cross terms u0.v1 xor r and u1.v0 xor r with
  // u0 = not b0 (neighbour 1), u1 = b1 (neighbour 1) and v = b (neighbour 2). Phase 1 completes the
  // output shares: a0 = b0 xor u0.v0 xor x0 and a1 = b1 xor u1.v1 xor x1; iota goes to share 0.
  always_comb begin : p_com_chi
    w_t0 = ((~f_nb(w_b0, 1)) & f_nb(w_b1, 2)) ^ w_rc;
    w_t1 = (f_nb(w_b1, 1) & f_nb(w_b0, 2)) ^ w_rc;
    w_a0 = w_b0 ^ ((~f_nb(w_b0, 1)) & f_nb(w_b0, 2)) ^ reg_x0;
    w_a1 = w_b1 ^ (f_nb(w_b1, 1) & f_nb(w_b1, 2)) ^ reg_x1;
    w_a0[63:0] = w_a0[63:0] ^ f_rc(reg_cnt);
  end

  // Control state: running, phase, round counter and done flag (reset).
  always_ff @(posedge i_clk_core, negedge i_rst_n_core) begin : p_ff_ctrl
    if (!i_rst_n_core) begin
      reg_run  <= 1'b0;
      reg_done <= 1'b0;
      reg_cnt  <= '0;
      reg_ph   <= 1'b0;
    end else begin
      casez ({i_start, i_clr, reg_run})
        3'b1??: begin
          reg_run  <= 1'b1;
          reg_done <= 1'b0;
          reg_cnt  <= '0;
          reg_ph   <= 1'b0;
        end
        3'b01?: begin
          reg_run  <= 1'b0;
          reg_done <= 1'b0;
          reg_cnt  <= '0;
          reg_ph   <= 1'b0;
        end
        3'b001: begin
          reg_ph <= !reg_ph;
          if (reg_ph) begin
            reg_cnt <= reg_cnt + 5'd1;
            if (w_last) begin
              reg_run  <= 1'b0;
              reg_done <= 1'b1;
            end
          end
        end
        default: begin
          // Idle: the flags and the counter keep their values.
        end
      endcase
    end
  end

  // Share and cross-term registers. Start: both shares are refreshed with R and the block is added
  // to share 0. Phase 0 stores the cross terms, phase 1 the new shares. Cleared by the clear input.
  always_ff @(posedge i_clk_core) begin : p_ff_data
    casez ({i_start, i_clr, reg_run, reg_ph})
      4'b1???: begin
        reg_s0 <= i_state[1599:0] ^ w_r ^ {256'b0, i_block};
        reg_s1 <= i_state[3199:1600] ^ w_r;
      end
      4'b01??: begin
        reg_s0 <= '0;
        reg_s1 <= '0;
        reg_x0 <= '0;
        reg_x1 <= '0;
      end
      4'b0010: begin
        reg_x0 <= w_t0;
        reg_x1 <= w_t1;
      end
      4'b0011: begin
        reg_s0 <= w_a0;
        reg_s1 <= w_a1;
      end
      default: begin
        // Idle: the registers keep their values.
      end
    endcase
  end

  // The result of the block: the two shares; the done flag is the registered end of the last round.
  assign o_result = {reg_s1, reg_s0};
  assign o_done   = reg_done;

  // Parity of the share and cross-term registers (PARA_PAR = 1): one even-parity bit per 32 bits,
  // generated from the next value and checked while the core runs (DEC-035).
  logic [49:0] reg_p0;
  logic [49:0] reg_p1;
  logic [49:0] reg_px0;
  logic [49:0] reg_px1;

  always_ff @(posedge i_clk_core) begin : p_ff_par
    casez ({i_start, i_clr, reg_run, reg_ph})
      4'b1???: begin
        reg_p0 <= f_pars(i_state[1599:0] ^ w_r ^ {256'b0, i_block});
        reg_p1 <= f_pars(i_state[3199:1600] ^ w_r);
      end
      4'b01??: begin
        reg_p0  <= '0;
        reg_p1  <= '0;
        reg_px0 <= '0;
        reg_px1 <= '0;
      end
      4'b0010: begin
        reg_px0 <= f_pars(w_t0);
        reg_px1 <= f_pars(w_t1);
      end
      4'b0011: begin
        reg_p0 <= f_pars(w_a0);
        reg_p1 <= f_pars(w_a1);
      end
      default: begin
        // Idle: the parity bits keep their values.
      end
    endcase
  end

  always_comb begin : p_com_par
    o_par_err = (PARA_PAR != 32'd0) && reg_run
             && ((f_pars(reg_s0) != reg_p0) || (f_pars(reg_s1) != reg_p1)
              || (reg_ph && ((f_pars(reg_x0) != reg_px0) || (f_pars(reg_x1) != reg_px1))));
  end

endmodule
