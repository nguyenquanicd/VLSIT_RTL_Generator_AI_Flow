`timescale 1ns/1ps
// Exhaustive truth-table test of the combinational cells VLSIT_CELL_* (expected values from the generator).
module tb_cells_comb;
  integer errors = 0;
  integer idx;
  // VLSIT_CELL_INV
  reg  [0:0] v_inv = 0;
  wire z_inv_zn;
  VLSIT_CELL_INV u_inv (.I(v_inv[0]), .ZN(z_inv_zn));
  localparam [1:0] EXP_INV_ZN = 2'b01;
  // VLSIT_CELL_BUF
  reg  [0:0] v_buf = 0;
  wire z_buf_z;
  VLSIT_CELL_BUF u_buf (.I(v_buf[0]), .Z(z_buf_z));
  localparam [1:0] EXP_BUF_Z = 2'b10;
  // VLSIT_CELL_AND2
  reg  [1:0] v_and2 = 0;
  wire z_and2_z;
  VLSIT_CELL_AND2 u_and2 (.A(v_and2[0]), .B(v_and2[1]), .Z(z_and2_z));
  localparam [3:0] EXP_AND2_Z = 4'b1000;
  // VLSIT_CELL_NAND2
  reg  [1:0] v_nand2 = 0;
  wire z_nand2_zn;
  VLSIT_CELL_NAND2 u_nand2 (.A(v_nand2[0]), .B(v_nand2[1]), .ZN(z_nand2_zn));
  localparam [3:0] EXP_NAND2_ZN = 4'b0111;
  // VLSIT_CELL_OR2
  reg  [1:0] v_or2 = 0;
  wire z_or2_z;
  VLSIT_CELL_OR2 u_or2 (.A(v_or2[0]), .B(v_or2[1]), .Z(z_or2_z));
  localparam [3:0] EXP_OR2_Z = 4'b1110;
  // VLSIT_CELL_NOR2
  reg  [1:0] v_nor2 = 0;
  wire z_nor2_zn;
  VLSIT_CELL_NOR2 u_nor2 (.A(v_nor2[0]), .B(v_nor2[1]), .ZN(z_nor2_zn));
  localparam [3:0] EXP_NOR2_ZN = 4'b0001;
  // VLSIT_CELL_AND3
  reg  [2:0] v_and3 = 0;
  wire z_and3_z;
  VLSIT_CELL_AND3 u_and3 (.A(v_and3[0]), .B(v_and3[1]), .C(v_and3[2]), .Z(z_and3_z));
  localparam [7:0] EXP_AND3_Z = 8'b10000000;
  // VLSIT_CELL_NAND3
  reg  [2:0] v_nand3 = 0;
  wire z_nand3_zn;
  VLSIT_CELL_NAND3 u_nand3 (.A(v_nand3[0]), .B(v_nand3[1]), .C(v_nand3[2]), .ZN(z_nand3_zn));
  localparam [7:0] EXP_NAND3_ZN = 8'b01111111;
  // VLSIT_CELL_OR3
  reg  [2:0] v_or3 = 0;
  wire z_or3_z;
  VLSIT_CELL_OR3 u_or3 (.A(v_or3[0]), .B(v_or3[1]), .C(v_or3[2]), .Z(z_or3_z));
  localparam [7:0] EXP_OR3_Z = 8'b11111110;
  // VLSIT_CELL_NOR3
  reg  [2:0] v_nor3 = 0;
  wire z_nor3_zn;
  VLSIT_CELL_NOR3 u_nor3 (.A(v_nor3[0]), .B(v_nor3[1]), .C(v_nor3[2]), .ZN(z_nor3_zn));
  localparam [7:0] EXP_NOR3_ZN = 8'b00000001;
  // VLSIT_CELL_AND4
  reg  [3:0] v_and4 = 0;
  wire z_and4_z;
  VLSIT_CELL_AND4 u_and4 (.A(v_and4[0]), .B(v_and4[1]), .C(v_and4[2]), .D(v_and4[3]), .Z(z_and4_z));
  localparam [15:0] EXP_AND4_Z = 16'b1000000000000000;
  // VLSIT_CELL_NAND4
  reg  [3:0] v_nand4 = 0;
  wire z_nand4_zn;
  VLSIT_CELL_NAND4 u_nand4 (.A(v_nand4[0]), .B(v_nand4[1]), .C(v_nand4[2]), .D(v_nand4[3]), .ZN(z_nand4_zn));
  localparam [15:0] EXP_NAND4_ZN = 16'b0111111111111111;
  // VLSIT_CELL_OR4
  reg  [3:0] v_or4 = 0;
  wire z_or4_z;
  VLSIT_CELL_OR4 u_or4 (.A(v_or4[0]), .B(v_or4[1]), .C(v_or4[2]), .D(v_or4[3]), .Z(z_or4_z));
  localparam [15:0] EXP_OR4_Z = 16'b1111111111111110;
  // VLSIT_CELL_NOR4
  reg  [3:0] v_nor4 = 0;
  wire z_nor4_zn;
  VLSIT_CELL_NOR4 u_nor4 (.A(v_nor4[0]), .B(v_nor4[1]), .C(v_nor4[2]), .D(v_nor4[3]), .ZN(z_nor4_zn));
  localparam [15:0] EXP_NOR4_ZN = 16'b0000000000000001;
  // VLSIT_CELL_XOR2
  reg  [1:0] v_xor2 = 0;
  wire z_xor2_z;
  VLSIT_CELL_XOR2 u_xor2 (.A(v_xor2[0]), .B(v_xor2[1]), .Z(z_xor2_z));
  localparam [3:0] EXP_XOR2_Z = 4'b0110;
  // VLSIT_CELL_XNOR2
  reg  [1:0] v_xnor2 = 0;
  wire z_xnor2_zn;
  VLSIT_CELL_XNOR2 u_xnor2 (.A(v_xnor2[0]), .B(v_xnor2[1]), .ZN(z_xnor2_zn));
  localparam [3:0] EXP_XNOR2_ZN = 4'b1001;
  // VLSIT_CELL_XOR3
  reg  [2:0] v_xor3 = 0;
  wire z_xor3_z;
  VLSIT_CELL_XOR3 u_xor3 (.A(v_xor3[0]), .B(v_xor3[1]), .C(v_xor3[2]), .Z(z_xor3_z));
  localparam [7:0] EXP_XOR3_Z = 8'b10010110;
  // VLSIT_CELL_XNOR3
  reg  [2:0] v_xnor3 = 0;
  wire z_xnor3_zn;
  VLSIT_CELL_XNOR3 u_xnor3 (.A(v_xnor3[0]), .B(v_xnor3[1]), .C(v_xnor3[2]), .ZN(z_xnor3_zn));
  localparam [7:0] EXP_XNOR3_ZN = 8'b01101001;
  // VLSIT_CELL_AOI21
  reg  [2:0] v_aoi21 = 0;
  wire z_aoi21_zn;
  VLSIT_CELL_AOI21 u_aoi21 (.A1(v_aoi21[0]), .A2(v_aoi21[1]), .B(v_aoi21[2]), .ZN(z_aoi21_zn));
  localparam [7:0] EXP_AOI21_ZN = 8'b00000111;
  // VLSIT_CELL_AOI22
  reg  [3:0] v_aoi22 = 0;
  wire z_aoi22_zn;
  VLSIT_CELL_AOI22 u_aoi22 (.A1(v_aoi22[0]), .A2(v_aoi22[1]), .B1(v_aoi22[2]), .B2(v_aoi22[3]), .ZN(z_aoi22_zn));
  localparam [15:0] EXP_AOI22_ZN = 16'b0000011101110111;
  // VLSIT_CELL_AOI211
  reg  [3:0] v_aoi211 = 0;
  wire z_aoi211_zn;
  VLSIT_CELL_AOI211 u_aoi211 (.A1(v_aoi211[0]), .A2(v_aoi211[1]), .B(v_aoi211[2]), .C(v_aoi211[3]), .ZN(z_aoi211_zn));
  localparam [15:0] EXP_AOI211_ZN = 16'b0000000000000111;
  // VLSIT_CELL_OAI21
  reg  [2:0] v_oai21 = 0;
  wire z_oai21_zn;
  VLSIT_CELL_OAI21 u_oai21 (.A1(v_oai21[0]), .A2(v_oai21[1]), .B(v_oai21[2]), .ZN(z_oai21_zn));
  localparam [7:0] EXP_OAI21_ZN = 8'b00011111;
  // VLSIT_CELL_OAI22
  reg  [3:0] v_oai22 = 0;
  wire z_oai22_zn;
  VLSIT_CELL_OAI22 u_oai22 (.A1(v_oai22[0]), .A2(v_oai22[1]), .B1(v_oai22[2]), .B2(v_oai22[3]), .ZN(z_oai22_zn));
  localparam [15:0] EXP_OAI22_ZN = 16'b0001000100011111;
  // VLSIT_CELL_OAI211
  reg  [3:0] v_oai211 = 0;
  wire z_oai211_zn;
  VLSIT_CELL_OAI211 u_oai211 (.A1(v_oai211[0]), .A2(v_oai211[1]), .B(v_oai211[2]), .C(v_oai211[3]), .ZN(z_oai211_zn));
  localparam [15:0] EXP_OAI211_ZN = 16'b0001111111111111;
  // VLSIT_CELL_AO21
  reg  [2:0] v_ao21 = 0;
  wire z_ao21_z;
  VLSIT_CELL_AO21 u_ao21 (.A1(v_ao21[0]), .A2(v_ao21[1]), .B(v_ao21[2]), .Z(z_ao21_z));
  localparam [7:0] EXP_AO21_Z = 8'b11111000;
  // VLSIT_CELL_AO22
  reg  [3:0] v_ao22 = 0;
  wire z_ao22_z;
  VLSIT_CELL_AO22 u_ao22 (.A1(v_ao22[0]), .A2(v_ao22[1]), .B1(v_ao22[2]), .B2(v_ao22[3]), .Z(z_ao22_z));
  localparam [15:0] EXP_AO22_Z = 16'b1111100010001000;
  // VLSIT_CELL_OA21
  reg  [2:0] v_oa21 = 0;
  wire z_oa21_z;
  VLSIT_CELL_OA21 u_oa21 (.A1(v_oa21[0]), .A2(v_oa21[1]), .B(v_oa21[2]), .Z(z_oa21_z));
  localparam [7:0] EXP_OA21_Z = 8'b11100000;
  // VLSIT_CELL_OA22
  reg  [3:0] v_oa22 = 0;
  wire z_oa22_z;
  VLSIT_CELL_OA22 u_oa22 (.A1(v_oa22[0]), .A2(v_oa22[1]), .B1(v_oa22[2]), .B2(v_oa22[3]), .Z(z_oa22_z));
  localparam [15:0] EXP_OA22_Z = 16'b1110111011100000;
  // VLSIT_CELL_MUX2
  reg  [2:0] v_mux2 = 0;
  wire z_mux2_z;
  VLSIT_CELL_MUX2 u_mux2 (.I0(v_mux2[0]), .I1(v_mux2[1]), .S(v_mux2[2]), .Z(z_mux2_z));
  localparam [7:0] EXP_MUX2_Z = 8'b11001010;
  // VLSIT_CELL_MUXI2
  reg  [2:0] v_muxi2 = 0;
  wire z_muxi2_zn;
  VLSIT_CELL_MUXI2 u_muxi2 (.I0(v_muxi2[0]), .I1(v_muxi2[1]), .S(v_muxi2[2]), .ZN(z_muxi2_zn));
  localparam [7:0] EXP_MUXI2_ZN = 8'b00110101;
  // VLSIT_CELL_MUX4
  reg  [5:0] v_mux4 = 0;
  wire z_mux4_z;
  VLSIT_CELL_MUX4 u_mux4 (.I0(v_mux4[0]), .I1(v_mux4[1]), .I2(v_mux4[2]), .I3(v_mux4[3]), .S0(v_mux4[4]), .S1(v_mux4[5]), .Z(z_mux4_z));
  localparam [63:0] EXP_MUX4_Z = 64'b1111111100000000111100001111000011001100110011001010101010101010;
  // VLSIT_CELL_HA
  reg  [1:0] v_ha = 0;
  wire z_ha_s;
  wire z_ha_co;
  VLSIT_CELL_HA u_ha (.A(v_ha[0]), .B(v_ha[1]), .S(z_ha_s), .CO(z_ha_co));
  localparam [3:0] EXP_HA_S = 4'b0110;
  localparam [3:0] EXP_HA_CO = 4'b1000;
  // VLSIT_CELL_FA
  reg  [2:0] v_fa = 0;
  wire z_fa_s;
  wire z_fa_co;
  VLSIT_CELL_FA u_fa (.A(v_fa[0]), .B(v_fa[1]), .CI(v_fa[2]), .S(z_fa_s), .CO(z_fa_co));
  localparam [7:0] EXP_FA_S = 8'b10010110;
  localparam [7:0] EXP_FA_CO = 8'b11101000;
  // VLSIT_CELL_TIEH
  wire z_tieh_z;
  VLSIT_CELL_TIEH u_tieh (.Z(z_tieh_z));
  localparam [0:0] EXP_TIEH_Z = 1'b1;
  // VLSIT_CELL_TIEL
  wire z_tiel_z;
  VLSIT_CELL_TIEL u_tiel (.Z(z_tiel_z));
  localparam [0:0] EXP_TIEL_Z = 1'b0;
  // VLSIT_CELL_CKBUF
  reg  [0:0] v_ckbuf = 0;
  wire z_ckbuf_z;
  VLSIT_CELL_CKBUF u_ckbuf (.I(v_ckbuf[0]), .Z(z_ckbuf_z));
  localparam [1:0] EXP_CKBUF_Z = 2'b10;
  // VLSIT_CELL_CKINV
  reg  [0:0] v_ckinv = 0;
  wire z_ckinv_zn;
  VLSIT_CELL_CKINV u_ckinv (.I(v_ckinv[0]), .ZN(z_ckinv_zn));
  localparam [1:0] EXP_CKINV_ZN = 2'b01;
  // VLSIT_CELL_CKAND2
  reg  [1:0] v_ckand2 = 0;
  wire z_ckand2_z;
  VLSIT_CELL_CKAND2 u_ckand2 (.A(v_ckand2[0]), .B(v_ckand2[1]), .Z(z_ckand2_z));
  localparam [3:0] EXP_CKAND2_Z = 4'b1000;
  // VLSIT_CELL_CKMUX2
  reg  [2:0] v_ckmux2 = 0;
  wire z_ckmux2_z;
  VLSIT_CELL_CKMUX2 u_ckmux2 (.I0(v_ckmux2[0]), .I1(v_ckmux2[1]), .S(v_ckmux2[2]), .Z(z_ckmux2_z));
  localparam [7:0] EXP_CKMUX2_Z = 8'b11001010;
  initial begin
    for (idx = 0; idx < 2; idx = idx + 1) begin
      v_inv = idx[0:0]; #1;
      if (z_inv_zn !== EXP_INV_ZN[idx]) begin errors = errors + 1; $display("FAIL VLSIT_CELL_INV idx=%0d ZN=%b", idx, z_inv_zn); end
    end
    for (idx = 0; idx < 2; idx = idx + 1) begin
      v_buf = idx[0:0]; #1;
      if (z_buf_z !== EXP_BUF_Z[idx]) begin errors = errors + 1; $display("FAIL VLSIT_CELL_BUF idx=%0d Z=%b", idx, z_buf_z); end
    end
    for (idx = 0; idx < 4; idx = idx + 1) begin
      v_and2 = idx[1:0]; #1;
      if (z_and2_z !== EXP_AND2_Z[idx]) begin errors = errors + 1; $display("FAIL VLSIT_CELL_AND2 idx=%0d Z=%b", idx, z_and2_z); end
    end
    for (idx = 0; idx < 4; idx = idx + 1) begin
      v_nand2 = idx[1:0]; #1;
      if (z_nand2_zn !== EXP_NAND2_ZN[idx]) begin errors = errors + 1; $display("FAIL VLSIT_CELL_NAND2 idx=%0d ZN=%b", idx, z_nand2_zn); end
    end
    for (idx = 0; idx < 4; idx = idx + 1) begin
      v_or2 = idx[1:0]; #1;
      if (z_or2_z !== EXP_OR2_Z[idx]) begin errors = errors + 1; $display("FAIL VLSIT_CELL_OR2 idx=%0d Z=%b", idx, z_or2_z); end
    end
    for (idx = 0; idx < 4; idx = idx + 1) begin
      v_nor2 = idx[1:0]; #1;
      if (z_nor2_zn !== EXP_NOR2_ZN[idx]) begin errors = errors + 1; $display("FAIL VLSIT_CELL_NOR2 idx=%0d ZN=%b", idx, z_nor2_zn); end
    end
    for (idx = 0; idx < 8; idx = idx + 1) begin
      v_and3 = idx[2:0]; #1;
      if (z_and3_z !== EXP_AND3_Z[idx]) begin errors = errors + 1; $display("FAIL VLSIT_CELL_AND3 idx=%0d Z=%b", idx, z_and3_z); end
    end
    for (idx = 0; idx < 8; idx = idx + 1) begin
      v_nand3 = idx[2:0]; #1;
      if (z_nand3_zn !== EXP_NAND3_ZN[idx]) begin errors = errors + 1; $display("FAIL VLSIT_CELL_NAND3 idx=%0d ZN=%b", idx, z_nand3_zn); end
    end
    for (idx = 0; idx < 8; idx = idx + 1) begin
      v_or3 = idx[2:0]; #1;
      if (z_or3_z !== EXP_OR3_Z[idx]) begin errors = errors + 1; $display("FAIL VLSIT_CELL_OR3 idx=%0d Z=%b", idx, z_or3_z); end
    end
    for (idx = 0; idx < 8; idx = idx + 1) begin
      v_nor3 = idx[2:0]; #1;
      if (z_nor3_zn !== EXP_NOR3_ZN[idx]) begin errors = errors + 1; $display("FAIL VLSIT_CELL_NOR3 idx=%0d ZN=%b", idx, z_nor3_zn); end
    end
    for (idx = 0; idx < 16; idx = idx + 1) begin
      v_and4 = idx[3:0]; #1;
      if (z_and4_z !== EXP_AND4_Z[idx]) begin errors = errors + 1; $display("FAIL VLSIT_CELL_AND4 idx=%0d Z=%b", idx, z_and4_z); end
    end
    for (idx = 0; idx < 16; idx = idx + 1) begin
      v_nand4 = idx[3:0]; #1;
      if (z_nand4_zn !== EXP_NAND4_ZN[idx]) begin errors = errors + 1; $display("FAIL VLSIT_CELL_NAND4 idx=%0d ZN=%b", idx, z_nand4_zn); end
    end
    for (idx = 0; idx < 16; idx = idx + 1) begin
      v_or4 = idx[3:0]; #1;
      if (z_or4_z !== EXP_OR4_Z[idx]) begin errors = errors + 1; $display("FAIL VLSIT_CELL_OR4 idx=%0d Z=%b", idx, z_or4_z); end
    end
    for (idx = 0; idx < 16; idx = idx + 1) begin
      v_nor4 = idx[3:0]; #1;
      if (z_nor4_zn !== EXP_NOR4_ZN[idx]) begin errors = errors + 1; $display("FAIL VLSIT_CELL_NOR4 idx=%0d ZN=%b", idx, z_nor4_zn); end
    end
    for (idx = 0; idx < 4; idx = idx + 1) begin
      v_xor2 = idx[1:0]; #1;
      if (z_xor2_z !== EXP_XOR2_Z[idx]) begin errors = errors + 1; $display("FAIL VLSIT_CELL_XOR2 idx=%0d Z=%b", idx, z_xor2_z); end
    end
    for (idx = 0; idx < 4; idx = idx + 1) begin
      v_xnor2 = idx[1:0]; #1;
      if (z_xnor2_zn !== EXP_XNOR2_ZN[idx]) begin errors = errors + 1; $display("FAIL VLSIT_CELL_XNOR2 idx=%0d ZN=%b", idx, z_xnor2_zn); end
    end
    for (idx = 0; idx < 8; idx = idx + 1) begin
      v_xor3 = idx[2:0]; #1;
      if (z_xor3_z !== EXP_XOR3_Z[idx]) begin errors = errors + 1; $display("FAIL VLSIT_CELL_XOR3 idx=%0d Z=%b", idx, z_xor3_z); end
    end
    for (idx = 0; idx < 8; idx = idx + 1) begin
      v_xnor3 = idx[2:0]; #1;
      if (z_xnor3_zn !== EXP_XNOR3_ZN[idx]) begin errors = errors + 1; $display("FAIL VLSIT_CELL_XNOR3 idx=%0d ZN=%b", idx, z_xnor3_zn); end
    end
    for (idx = 0; idx < 8; idx = idx + 1) begin
      v_aoi21 = idx[2:0]; #1;
      if (z_aoi21_zn !== EXP_AOI21_ZN[idx]) begin errors = errors + 1; $display("FAIL VLSIT_CELL_AOI21 idx=%0d ZN=%b", idx, z_aoi21_zn); end
    end
    for (idx = 0; idx < 16; idx = idx + 1) begin
      v_aoi22 = idx[3:0]; #1;
      if (z_aoi22_zn !== EXP_AOI22_ZN[idx]) begin errors = errors + 1; $display("FAIL VLSIT_CELL_AOI22 idx=%0d ZN=%b", idx, z_aoi22_zn); end
    end
    for (idx = 0; idx < 16; idx = idx + 1) begin
      v_aoi211 = idx[3:0]; #1;
      if (z_aoi211_zn !== EXP_AOI211_ZN[idx]) begin errors = errors + 1; $display("FAIL VLSIT_CELL_AOI211 idx=%0d ZN=%b", idx, z_aoi211_zn); end
    end
    for (idx = 0; idx < 8; idx = idx + 1) begin
      v_oai21 = idx[2:0]; #1;
      if (z_oai21_zn !== EXP_OAI21_ZN[idx]) begin errors = errors + 1; $display("FAIL VLSIT_CELL_OAI21 idx=%0d ZN=%b", idx, z_oai21_zn); end
    end
    for (idx = 0; idx < 16; idx = idx + 1) begin
      v_oai22 = idx[3:0]; #1;
      if (z_oai22_zn !== EXP_OAI22_ZN[idx]) begin errors = errors + 1; $display("FAIL VLSIT_CELL_OAI22 idx=%0d ZN=%b", idx, z_oai22_zn); end
    end
    for (idx = 0; idx < 16; idx = idx + 1) begin
      v_oai211 = idx[3:0]; #1;
      if (z_oai211_zn !== EXP_OAI211_ZN[idx]) begin errors = errors + 1; $display("FAIL VLSIT_CELL_OAI211 idx=%0d ZN=%b", idx, z_oai211_zn); end
    end
    for (idx = 0; idx < 8; idx = idx + 1) begin
      v_ao21 = idx[2:0]; #1;
      if (z_ao21_z !== EXP_AO21_Z[idx]) begin errors = errors + 1; $display("FAIL VLSIT_CELL_AO21 idx=%0d Z=%b", idx, z_ao21_z); end
    end
    for (idx = 0; idx < 16; idx = idx + 1) begin
      v_ao22 = idx[3:0]; #1;
      if (z_ao22_z !== EXP_AO22_Z[idx]) begin errors = errors + 1; $display("FAIL VLSIT_CELL_AO22 idx=%0d Z=%b", idx, z_ao22_z); end
    end
    for (idx = 0; idx < 8; idx = idx + 1) begin
      v_oa21 = idx[2:0]; #1;
      if (z_oa21_z !== EXP_OA21_Z[idx]) begin errors = errors + 1; $display("FAIL VLSIT_CELL_OA21 idx=%0d Z=%b", idx, z_oa21_z); end
    end
    for (idx = 0; idx < 16; idx = idx + 1) begin
      v_oa22 = idx[3:0]; #1;
      if (z_oa22_z !== EXP_OA22_Z[idx]) begin errors = errors + 1; $display("FAIL VLSIT_CELL_OA22 idx=%0d Z=%b", idx, z_oa22_z); end
    end
    for (idx = 0; idx < 8; idx = idx + 1) begin
      v_mux2 = idx[2:0]; #1;
      if (z_mux2_z !== EXP_MUX2_Z[idx]) begin errors = errors + 1; $display("FAIL VLSIT_CELL_MUX2 idx=%0d Z=%b", idx, z_mux2_z); end
    end
    for (idx = 0; idx < 8; idx = idx + 1) begin
      v_muxi2 = idx[2:0]; #1;
      if (z_muxi2_zn !== EXP_MUXI2_ZN[idx]) begin errors = errors + 1; $display("FAIL VLSIT_CELL_MUXI2 idx=%0d ZN=%b", idx, z_muxi2_zn); end
    end
    for (idx = 0; idx < 64; idx = idx + 1) begin
      v_mux4 = idx[5:0]; #1;
      if (z_mux4_z !== EXP_MUX4_Z[idx]) begin errors = errors + 1; $display("FAIL VLSIT_CELL_MUX4 idx=%0d Z=%b", idx, z_mux4_z); end
    end
    for (idx = 0; idx < 4; idx = idx + 1) begin
      v_ha = idx[1:0]; #1;
      if (z_ha_s !== EXP_HA_S[idx]) begin errors = errors + 1; $display("FAIL VLSIT_CELL_HA idx=%0d S=%b", idx, z_ha_s); end
      if (z_ha_co !== EXP_HA_CO[idx]) begin errors = errors + 1; $display("FAIL VLSIT_CELL_HA idx=%0d CO=%b", idx, z_ha_co); end
    end
    for (idx = 0; idx < 8; idx = idx + 1) begin
      v_fa = idx[2:0]; #1;
      if (z_fa_s !== EXP_FA_S[idx]) begin errors = errors + 1; $display("FAIL VLSIT_CELL_FA idx=%0d S=%b", idx, z_fa_s); end
      if (z_fa_co !== EXP_FA_CO[idx]) begin errors = errors + 1; $display("FAIL VLSIT_CELL_FA idx=%0d CO=%b", idx, z_fa_co); end
    end
    for (idx = 0; idx < 1; idx = idx + 1) begin
      #1;
      if (z_tieh_z !== EXP_TIEH_Z[idx]) begin errors = errors + 1; $display("FAIL VLSIT_CELL_TIEH idx=%0d Z=%b", idx, z_tieh_z); end
    end
    for (idx = 0; idx < 1; idx = idx + 1) begin
      #1;
      if (z_tiel_z !== EXP_TIEL_Z[idx]) begin errors = errors + 1; $display("FAIL VLSIT_CELL_TIEL idx=%0d Z=%b", idx, z_tiel_z); end
    end
    for (idx = 0; idx < 2; idx = idx + 1) begin
      v_ckbuf = idx[0:0]; #1;
      if (z_ckbuf_z !== EXP_CKBUF_Z[idx]) begin errors = errors + 1; $display("FAIL VLSIT_CELL_CKBUF idx=%0d Z=%b", idx, z_ckbuf_z); end
    end
    for (idx = 0; idx < 2; idx = idx + 1) begin
      v_ckinv = idx[0:0]; #1;
      if (z_ckinv_zn !== EXP_CKINV_ZN[idx]) begin errors = errors + 1; $display("FAIL VLSIT_CELL_CKINV idx=%0d ZN=%b", idx, z_ckinv_zn); end
    end
    for (idx = 0; idx < 4; idx = idx + 1) begin
      v_ckand2 = idx[1:0]; #1;
      if (z_ckand2_z !== EXP_CKAND2_Z[idx]) begin errors = errors + 1; $display("FAIL VLSIT_CELL_CKAND2 idx=%0d Z=%b", idx, z_ckand2_z); end
    end
    for (idx = 0; idx < 8; idx = idx + 1) begin
      v_ckmux2 = idx[2:0]; #1;
      if (z_ckmux2_z !== EXP_CKMUX2_Z[idx]) begin errors = errors + 1; $display("FAIL VLSIT_CELL_CKMUX2 idx=%0d Z=%b", idx, z_ckmux2_z); end
    end
    if (errors == 0) $display("PASS tb_cells_comb: 39 cells" );
    else $display("FAIL tb_cells_comb: %0d errors", errors);
    $finish;
  end
endmodule
