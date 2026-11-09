/*
 * Project      : HyperRAM Controller
 * Author       : Nguyen Quan (user)
 * AI Flow      : VLSIT RTL Generator AI Automation Flow
 * AI Flow Page : https://github.com/nguyenquanicd/VLSIT_RTL_Generator_AI_Model
 * Date         : 2026-11-04
 * Description  : Test-bench-only x16 HyperBus device built from two x8 vendor models
 *                (verification code, not synthesizable).
 */
`timescale 1ns/1ps
// Test-bench-only x16 HyperBus device made of two Infineon S27KS0641 (x8) models.
// It is NOT a chip model.
// Model 0 holds data lane DQ[7:0] and model 1 holds DQ[15:8]; they share CS#, CK, CK# and
// RESET#, and
// each has its own RWDS. The two devices differ from a real x16 device in what the controller
// sends, so the wrapper translates (assumptions, see the controller specification, DEC-037):
//  - Memory space CA: the controller sends the x16 word address on DQ[7:0]. A model word is two
//    x16 words (one byte lane at the rising and falling edge), so the wrapper sends the word
//    address divided by 2 to both models; an odd start word is reported and not supported.
//  - Register space CA: passed unchanged to both models.
//  - Register write: the controller sends the 16-bit register on the rising beat; each model gets
//    the high byte then the low byte.
//  - Register read: the models answer in byte order; the wrapper drives the 16-bit register value
//    (read from the model of lane 0) on both beats, as an x16 device does.
module m_vlsit_hr_x16_from_x8 (
  // HyperBus control from the controller
  input  wire        i_cs_n,
  input  wire        i_ck,
  input  wire        i_ck_n,
  input  wire        i_rst_n_mem,

  // Data and RWDS lanes of the controller
  input  wire [15:0] i_dq,
  input  wire [15:0] i_dq_oe,
  output wire [15:0] o_dq,
  input  wire [1:0]  i_rwds,
  input  wire [1:0]  i_rwds_oe,
  output wire [1:0]  o_rwds
);
  wire [7:0] w_m0_dq, w_m1_dq;
  wire       w_m0_rwds, w_m1_rwds;
  integer    ecnt = 0;
  reg        is_rd = 0, is_reg = 0;
  reg  [7:0] sv [0:3];

  always @(negedge i_cs_n) ecnt = 0;
  // Edge counter of the transaction; the update is delayed so that the models sample the old
  // selection.
  always @(i_ck) if (!i_cs_n) begin
    if (ecnt == 0) begin
      is_rd  <= i_dq[7];
      is_reg <= i_dq[6];
    end
    if (ecnt < 4)
      sv[ecnt] <= i_dq[7:0];
    if (ecnt == 5 && !is_reg && i_dq[0])
      $display("%0t m_vlsit_hr_x16_from_x8: odd start word not supported", $time);
    ecnt <= #0.5 ecnt + 1;
  end

  wire       reg_now = (ecnt == 0) ? i_dq[6] : is_reg;
  reg  [7:0] ca_byte;
  always @* begin
    case (ecnt)
      0: ca_byte = reg_now ? i_dq[7:0] : {i_dq[7:5], 1'b0, i_dq[4:1]};
      1: ca_byte = reg_now ? i_dq[7:0] : {sv[0][0], i_dq[7:1]};
      2: ca_byte = reg_now ? i_dq[7:0] : {sv[1][0], i_dq[7:1]};
      3: ca_byte = reg_now ? i_dq[7:0] : {sv[2][0], i_dq[7:1]};
      5: ca_byte = reg_now ? i_dq[7:0] : {i_dq[7:3], sv[3][0], i_dq[2], i_dq[1]};
      default: ca_byte = i_dq[7:0];
    endcase
  end

  wire anyoe = |i_dq_oe;
  wire regw  = is_reg && !is_rd && (ecnt >= 6);
  wire [7:0] m0_in = (ecnt < 6) ? ca_byte : regw ? ((ecnt == 6) ? i_dq[15:8] : i_dq[7:0]) : i_dq[7:0];
  wire [7:0] m1_in = (ecnt < 6) ? ca_byte : regw ? ((ecnt == 6) ? i_dq[15:8] : i_dq[7:0]) : i_dq[15:8];
  assign w_m0_dq = anyoe ? m0_in : 8'bz;
  assign w_m1_dq = anyoe ? m1_in : 8'bz;
  assign w_m0_rwds = i_rwds_oe[0] ? i_rwds[0] : 1'bz;
  assign w_m1_rwds = i_rwds_oe[1] ? i_rwds[1] : 1'bz;
  assign o_rwds  = {w_m1_rwds, w_m0_rwds};

  reg [15:0] regval;
  always @* begin
    if (u_dont_touch_mem0.ca_in[31:24] == 8'h01)
      regval = u_dont_touch_mem0.ca_in[0] ? u_dont_touch_mem0.Config_reg_1 : u_dont_touch_mem0.Config_reg_0;
    else
      regval = u_dont_touch_mem0.ca_in[0] ? u_dont_touch_mem0.ID_Register_1 : u_dont_touch_mem0.ID_Register_0;
  end
  wire reg_rd_act = is_reg && is_rd && (ecnt >= 6) && !anyoe && (w_m0_dq !== 8'bz);
  assign o_dq = reg_rd_act ? regval : {w_m1_dq, w_m0_dq};

  s27ks0641 u_dont_touch_mem0 (.DQ0(w_m0_dq[0]), .DQ1(w_m0_dq[1]), .DQ2(w_m0_dq[2]), .DQ3(w_m0_dq[3]), .DQ4(w_m0_dq[4]), .DQ5(w_m0_dq[5]), .DQ6(w_m0_dq[6]), .DQ7(w_m0_dq[7]), .RWDS(w_m0_rwds), .CSNeg(i_cs_n), .CK(i_ck), .CKNeg(i_ck_n), .RESETNeg(i_rst_n_mem));
  s27ks0641 u_dont_touch_mem1 (.DQ0(w_m1_dq[0]), .DQ1(w_m1_dq[1]), .DQ2(w_m1_dq[2]), .DQ3(w_m1_dq[3]), .DQ4(w_m1_dq[4]), .DQ5(w_m1_dq[5]), .DQ6(w_m1_dq[6]), .DQ7(w_m1_dq[7]), .RWDS(w_m1_rwds), .CSNeg(i_cs_n), .CK(i_ck), .CKNeg(i_ck_n), .RESETNeg(i_rst_n_mem));
endmodule
