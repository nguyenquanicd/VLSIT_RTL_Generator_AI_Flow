`timescale 1ns/1ps
// Test of m_vlsit_tie in both flows (with and without +define+VLSIT_SYNTHESIS). Verification code.
module tb_tie;
  integer errors = 0;
  wire [0:0]  o_w1_v1;
  wire [0:0]  o_w1_v0;
  wire [4:0]  o_w5_v0;
  wire [7:0]  o_w8_va5;
  wire [11:0] o_w12_vfff;
  wire [31:0] o_w32_vdead;
  wire [2:0]  o_w3_vhigh;
  m_vlsit_tie #(.PARA_TIE_WIDTH(1),  .PARA_TIE_VALUE(1))             u_a (.o_tie(o_w1_v1));
  m_vlsit_tie #(.PARA_TIE_WIDTH(1),  .PARA_TIE_VALUE(0))             u_b (.o_tie(o_w1_v0));
  m_vlsit_tie #(.PARA_TIE_WIDTH(5))                                  u_c (.o_tie(o_w5_v0));
  m_vlsit_tie #(.PARA_TIE_WIDTH(8),  .PARA_TIE_VALUE(32'hA5))        u_d (.o_tie(o_w8_va5));
  m_vlsit_tie #(.PARA_TIE_WIDTH(12), .PARA_TIE_VALUE(32'hFFFF_FFFF)) u_e (.o_tie(o_w12_vfff));
  m_vlsit_tie #(.PARA_TIE_WIDTH(32), .PARA_TIE_VALUE(32'hDEADBEEF))  u_f (.o_tie(o_w32_vdead));
  m_vlsit_tie #(.PARA_TIE_WIDTH(3),  .PARA_TIE_VALUE(32'hFFFF_FFFD)) u_g (.o_tie(o_w3_vhigh));
  initial begin
    #1;
    if (o_w1_v1 !== 1'b1) errors++;
    if (o_w1_v0 !== 1'b0) errors++;
    if (o_w5_v0 !== 5'h00) errors++;
    if (o_w8_va5 !== 8'hA5) errors++;
    if (o_w12_vfff !== 12'hFFF) errors++;
    if (o_w32_vdead !== 32'hDEADBEEF) errors++;
    if (o_w3_vhigh !== 3'b101) errors++;
    if (errors == 0) $display("PASS tb_tie");
    else $display("FAIL tb_tie: %0d errors", errors);
    $finish;
  end
endmodule
