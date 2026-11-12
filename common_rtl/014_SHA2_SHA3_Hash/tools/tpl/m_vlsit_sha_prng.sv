/*
 * Project      : VLSIT Common RTL library
 * Author       : Nguyen Quan and Claude Sonnet 5.5 (user)
 * AI Flow      : VLSIT RTL Generator AI Automation Flow
 * AI Flow Page : https://github.com/nguyenquanicd/VLSIT_RTL_Generator_AI_Model
 * Date         : 2026-11-10
 * Description  : Random bit source of the masked Keccak core (stage 2b, IF-004, OP-009). A
 *                free-running Keccak-f[1600] round (one round per clock cycle, the round constants
 *                run through the 24 values again and again) delivers 1600 fresh bits per cycle:
 *                the state register. It is seeded with 256 bits. The seed comes from the seed
 *                registers of the
 *                CSR block (PARA_SEED_SRC = 1, loaded by the seed command) or from the entropy port
 *                (PARA_SEED_SRC = 0: eight 32-bit words requested with o_ent_req after reset and
 *                after the soft reset, o_ent_req stays high until i_ent_valid is seen). The state
 *                becomes the seed in the lanes 0 to 3 plus a padding bit, then 24 warm-up rounds
 *                run before o_seeded goes to 1. There is no automatic reseed (DEC-037). The soft
 *                reset clears the seeded flag.
 *                Decisions: DEC-036, DEC-037.
 */
`timescale 1ns/1ps

module m_vlsit_sha_prng #(
  // Parameter Description: source of the seed: 0 entropy port, 1 seed registers of the CSR block.
  // Parameter values: 0 or 1; default is 1.
  // Parameter unit: flag
  parameter logic [31:0] PARA_SEED_SRC = 1
) (
  // Clock and reset
  input  wire           i_clk_core,
  input  wire           i_rst_n_core,
  input  wire           i_srst,

  // Seed from the seed registers (one-cycle load strobe with the eight words)
  input  wire           i_seed_load,
  input  wire  [255:0]  i_seed_wd,

  // Seed from the entropy port
  input  wire           i_ent_valid,
  input  wire  [31:0]   i_ent_data,
  output logic          o_ent_req,

  // Status and random bits
  output logic          o_seeded,
  output logic [1599:0] o_rnd
);

  // Internal signal declarations
  logic [1599:0] reg_st;
  logic [4:0]    reg_cnt;
  logic [4:0]    reg_warm;
  logic          reg_run;
  logic          reg_seeded;
  logic [3:0]    reg_eidx;
  logic          reg_gap;
  logic          reg_en;
  logic [255:0]  reg_eseed;
  logic          w_load;
  logic [255:0]  w_seed;
  logic [4:0]    w_ridx;
  logic [1599:0] w_st_nxt;
  logic          w_ent_want;
  logic          w_ent_take;
  logic          w_ent_done;

@@KFUNCS@@
  // Seed load: from the seed registers on the seed command, from the collected entropy words when
  // the eighth word is in. Entropy words are requested while fewer than eight are collected.
  always_comb begin : p_com_seed
    w_ent_want = (PARA_SEED_SRC == 32'd0) && reg_en && (reg_eidx < 4'd8) && !reg_gap;
    w_ent_take = w_ent_want && i_ent_valid;
    w_ent_done = (PARA_SEED_SRC == 32'd0) && (reg_eidx == 4'd8);
    w_load     = ((PARA_SEED_SRC != 32'd0) && i_seed_load) || w_ent_done;
    w_seed     = (PARA_SEED_SRC != 32'd0) ? i_seed_wd : reg_eseed;
    o_ent_req  = w_ent_want;
  end

  // Entropy words: the request is enabled one cycle after the reset release (no request in reset,
  // 7.3),
  // the word counter, the pause of one cycle after each word and the collected seed.
  // The counter stays at 8 for one cycle (the load) and then returns to 0 only by the soft reset,
  // so
  // the entropy path seeds once after a reset (DEC-037).
  always_ff @(posedge i_clk_core, negedge i_rst_n_core) begin : p_ff_ent
    if (!i_rst_n_core) begin
      reg_eidx <= 4'd0;
      reg_gap  <= 1'b0;
      reg_en   <= 1'b0;
    end else begin
      reg_en  <= 1'b1;
      reg_gap <= w_ent_take;
      casez ({i_srst, w_ent_take, (reg_eidx == 4'd8)})
        3'b1??:  reg_eidx <= 4'd0;
        3'b01?:  reg_eidx <= reg_eidx + 4'd1;
        3'b001:  reg_eidx <= 4'd9;
        default: reg_eidx <= reg_eidx;
      endcase
    end
  end

  always_ff @(posedge i_clk_core) begin : p_ff_eseed
    if (w_ent_take)
      reg_eseed[32*reg_eidx[2:0] +: 32] <= i_ent_data;
  end

  // Round counter, warm-up counter and seeded flag. The state advances in every cycle from the
  // load.
  always_ff @(posedge i_clk_core, negedge i_rst_n_core) begin : p_ff_ctrl
    if (!i_rst_n_core) begin
      reg_run    <= 1'b0;
      reg_seeded <= 1'b0;
      reg_cnt    <= '0;
      reg_warm   <= '0;
    end else begin
      casez ({i_srst, w_load, reg_run})
        3'b1??: begin
          reg_run    <= 1'b0;
          reg_seeded <= 1'b0;
          reg_cnt    <= '0;
          reg_warm   <= '0;
        end
        3'b01?: begin
          reg_run    <= 1'b1;
          reg_seeded <= 1'b0;
          reg_cnt    <= '0;
          reg_warm   <= '0;
        end
        3'b001: begin
          reg_cnt <= (reg_cnt == 5'd23) ? 5'd0 : (reg_cnt + 5'd1);
          if (!reg_seeded) begin
            reg_warm <= reg_warm + 5'd1;
            if (reg_warm == 5'd23)
              reg_seeded <= 1'b1;
          end
        end
        default: begin
          // Not seeded: nothing runs.
        end
      endcase
    end
  end

  // State register: the seed with a padding bit at load, one round per cycle afterwards. Resetless:
  // the bits are used only while o_seeded is 1 (SEQ-04).
  always_comb begin : p_com_round
    w_ridx   = reg_cnt;
    w_st_nxt = f_round(reg_st, f_rc(w_ridx));
  end

  always_ff @(posedge i_clk_core) begin : p_ff_st
    casez ({w_load, reg_run})
      2'b1?:   reg_st <= {1'b1, 1342'b0, 1'b1, w_seed};
      2'b01:   reg_st <= w_st_nxt;
      default: reg_st <= reg_st;
    endcase
  end

  assign o_seeded = reg_seeded;
  assign o_rnd    = reg_st;

endmodule
