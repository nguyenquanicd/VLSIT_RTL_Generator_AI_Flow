`timescale 1ns/1ps
// Test-bench-only x16 HyperBus device made of two Infineon S27KS0641 (x8) models. It is NOT a chip model.
// Model 0 holds data lane DQ[7:0] and model 1 holds DQ[15:8]; they share CS#, CK, CK# and RESET#, and
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
module hr_x16_from_x8 (
  input  wire        CSNeg,
  input  wire        CK,
  input  wire        CKNeg,
  input  wire        RESETNeg,
  input  wire [15:0] i_dq,
  input  wire [15:0] i_dq_oe,
  output wire [15:0] o_dq,
  input  wire [1:0]  i_rwds,
  input  wire [1:0]  i_rwds_oe,
  output wire [1:0]  o_rwds
);
  wire [7:0] m0_dq, m1_dq;
  wire       m0_rwds, m1_rwds;
  integer    ecnt = 0;
  reg        is_rd = 0, is_reg = 0;
  reg  [7:0] sv [0:3];

  always @(negedge CSNeg) ecnt = 0;
  // Edge counter of the transaction; the update is delayed so that the models sample the old selection.
  always @(CK) if (!CSNeg) begin
    if (ecnt == 0) begin is_rd <= i_dq[7]; is_reg <= i_dq[6]; end
    if (ecnt < 4) sv[ecnt] <= i_dq[7:0];
    if (ecnt == 5 && !is_reg && i_dq[0]) $display("%0t hr_x16_from_x8: odd start word not supported", $time);
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
  assign m0_dq = anyoe ? m0_in : 8'bz;
  assign m1_dq = anyoe ? m1_in : 8'bz;
  assign m0_rwds = i_rwds_oe[0] ? i_rwds[0] : 1'bz;
  assign m1_rwds = i_rwds_oe[1] ? i_rwds[1] : 1'bz;
  assign o_rwds  = {m1_rwds, m0_rwds};

  reg [15:0] regval;
  always @* begin
    if (u_m0.ca_in[31:24] == 8'h01) regval = u_m0.ca_in[0] ? u_m0.Config_reg_1 : u_m0.Config_reg_0;
    else                           regval = u_m0.ca_in[0] ? u_m0.ID_Register_1 : u_m0.ID_Register_0;
  end
  wire reg_rd_act = is_reg && is_rd && (ecnt >= 6) && !anyoe && (m0_dq !== 8'bz);
  assign o_dq = reg_rd_act ? regval : {m1_dq, m0_dq};

  s27ks0641 u_m0 (.DQ0(m0_dq[0]), .DQ1(m0_dq[1]), .DQ2(m0_dq[2]), .DQ3(m0_dq[3]), .DQ4(m0_dq[4]), .DQ5(m0_dq[5]), .DQ6(m0_dq[6]), .DQ7(m0_dq[7]), .RWDS(m0_rwds), .CSNeg(CSNeg), .CK(CK), .CKNeg(CKNeg), .RESETNeg(RESETNeg));
  s27ks0641 u_m1 (.DQ0(m1_dq[0]), .DQ1(m1_dq[1]), .DQ2(m1_dq[2]), .DQ3(m1_dq[3]), .DQ4(m1_dq[4]), .DQ5(m1_dq[5]), .DQ6(m1_dq[6]), .DQ7(m1_dq[7]), .RWDS(m1_rwds), .CSNeg(CSNeg), .CK(CK), .CKNeg(CKNeg), .RESETNeg(RESETNeg));
endmodule
