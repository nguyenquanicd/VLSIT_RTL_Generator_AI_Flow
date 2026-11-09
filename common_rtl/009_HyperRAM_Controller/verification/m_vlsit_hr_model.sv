/*
 * Project      : HyperRAM Controller
 * Author       : Nguyen Quan (user)
 * AI Flow      : VLSIT RTL Generator AI Automation Flow
 * AI Flow Page : https://github.com/nguyenquanicd/VLSIT_RTL_Generator_AI_Model
 * Date         : 2026-11-04
 * Description  : Behavioral HyperRAM device for the coverage testbench (verification code, not
 *                synthesizable). Pins are split into input, output and output enable so that the
 *                model runs in simulators without tristate support. It is written from the
 *                HyperBus protocol and the device register map of the specification (DEC-037,
 *                DEC-050, DEC-051), not from the controller RTL: command and address phase of
 *                3 CK, latency from CR0 (fixed or variable), RWDS as latency indication, as read
 *                strobe and as write mask, wrapped and linear bursts, register space CR0, CR1,
 *                ID0 and ID1. It is not a vendor model; the vendor model is used by the smoke
 *                testbench.
 */
`timescale 1ns/1ps

// Test code is excluded from the coverage database; only the design is measured.
// verilator coverage_off
module m_vlsit_hr_model #(
  parameter integer PARA_DQ_W    = 8,
  parameter integer PARA_MEM_B   = 1048576,
  parameter integer PARA_TCKD_PS = 2500
) (
  // Control from the controller
  input  wire                    i_rst_n_mem,
  input  wire                    i_cs_n,
  input  wire                    i_ck,

  // Data and RWDS from the controller
  input  wire  [PARA_DQ_W-1:0]   i_dq,
  input  wire  [PARA_DQ_W/8-1:0] i_rwds,

  // Data and RWDS toward the controller
  output logic [PARA_DQ_W-1:0]   o_dq,
  output logic                   o_dq_oe,
  output logic [PARA_DQ_W/8-1:0] o_rwds,
  output logic                   o_rwds_oe,

  // Test controls
  input  wire                    i_no_data,
  input  wire                    i_force_collide
);

  localparam integer LPARA_NB = PARA_DQ_W / 8;

  reg [7:0]  mem [0:PARA_MEM_B-1];
  reg [15:0] cr0;
  reg [15:0] cr1;
  reg [47:0] ca;
  integer    ecnt;
  reg        is_rd;
  reg        is_reg;
  reg        linear;
  reg [31:0] waddr;
  integer    lat_clks;
  integer    data_e0;
  reg        collide;
  reg        rwds_ca;
  reg [15:0] regword;
  reg [PARA_DQ_W-1:0] dq_nx;
  reg [15:0] wd;
  integer    n_rd_bytes;
  integer    n_wr_bytes;
  integer    n_reg_wr;
  integer    n_reg_rd;
  integer    n_collide;

  // Byte address of byte j of the burst, wrapped inside the burst group when the burst is wrapped.
  function automatic [31:0] f_baddr(input integer j);
    integer grp;
    reg [31:0] base;
    begin
      if (!linear) begin
        case (cr0[1:0])
          2'b00:   grp = 128;
          2'b01:   grp = 64;
          2'b10:   grp = 16;
          default: grp = 32;
        endcase
        base = (waddr * 2) & ~(grp - 1);
        f_baddr = base + ((waddr * 2 - base + j) % grp);
      end else begin
        f_baddr = waddr * 2 + j;
      end
      f_baddr = f_baddr % PARA_MEM_B;
    end
  endfunction

  // Latency in CK periods from the code of CR0
  function automatic integer f_lat(input [3:0] code);
    begin
      case (code)
        4'b1110: f_lat = 3;
        4'b1111: f_lat = 4;
        4'b0000: f_lat = 5;
        4'b0001: f_lat = 6;
        4'b0010: f_lat = 7;
        default: f_lat = 8;
      endcase
    end
  endfunction

  initial begin
    cr0 = 16'h8F1F;
    cr1 = 16'hFFF3;
    o_dq = '0;
    o_dq_oe = 1'b0;
    o_rwds = '0;
    o_rwds_oe = 1'b0;
    ecnt = 0;
    n_rd_bytes = 0;
    n_wr_bytes = 0;
    n_reg_wr = 0;
    n_reg_rd = 0;
    n_collide = 0;
  end

  // CS# falling edge starts a transaction
  always @(negedge i_cs_n) begin
    ecnt = 0;
    ca = '0;
    o_dq_oe = 1'b0;
    o_rwds_oe = 1'b0;
    collide = i_force_collide || (($urandom % 4) == 0);
  end

  // CS# rising edge releases the pins after the last pending beat
  always @(posedge i_cs_n) begin
    o_dq_oe <= #(PARA_TCKD_PS / 1000.0 + 0.5) 1'b0;
    o_rwds_oe <= #(PARA_TCKD_PS / 1000.0 + 0.5) 1'b0;
  end

  // Every CK edge of a transaction
  always @(i_ck) if (!i_cs_n && i_rst_n_mem) begin : edge_blk
    integer dj;
    reg [7:0] bb;
    if (ecnt < 6) begin
      ca = {ca[39:0], i_dq[7:0]};
      if (ecnt == 5) begin
        is_rd = ca[47];
        is_reg = ca[46];
        linear = ca[45];
        waddr = {ca[44:16], ca[2:0]};
        rwds_ca = cr0[3] || (is_rd && collide);
        if (is_rd && collide && !cr0[3])
          n_collide = n_collide + 1;
        lat_clks = rwds_ca ? 2 * f_lat(cr0[7:4]) : f_lat(cr0[7:4]);
        if (is_reg && !is_rd)
          data_e0 = 6;
        else if (is_rd)
          data_e0 = 2 * (3 + lat_clks);
        else
          data_e0 = 2 * (2 + lat_clks);
      end
      if (ecnt == 0 && !i_no_data) begin
        o_rwds_oe <= #1 1'b1;
        o_rwds <= #1 (cr0[3] || (i_dq[7] && collide)) ? {LPARA_NB{1'b1}} : {LPARA_NB{1'b0}};
      end
    end else begin
      if (ecnt == 6) begin
        o_rwds <= #1 {LPARA_NB{1'b0}};
        if (!is_rd)
          o_rwds_oe <= #1 1'b0;
      end
      if (is_rd && ecnt >= data_e0 && !i_no_data) begin
        dj = ecnt - data_e0;
        dq_nx = '0;
        for (int j = 0; j < LPARA_NB; j = j + 1) begin
          if (is_reg) begin
            regword = (waddr == 32'h800) ? cr0 : (waddr == 32'h801) ? cr1 : (waddr == 0) ? 16'h0E86 : 16'h0000;
            if (PARA_DQ_W == 8)
              dq_nx[7:0] = (dj % 2 == 0) ? regword[15:8] : regword[7:0];
            else
              dq_nx = regword;
          end else begin
            bb = mem[f_baddr(dj * LPARA_NB + j)];
            dq_nx[8 * j +: 8] = bb;
          end
        end
        if (is_reg)
          n_reg_rd = n_reg_rd + 1;
        else
          n_rd_bytes = n_rd_bytes + LPARA_NB;
        o_dq <= #(PARA_TCKD_PS / 1000.0) dq_nx;
        o_dq_oe <= #(PARA_TCKD_PS / 1000.0) 1'b1;
        o_rwds_oe <= #(PARA_TCKD_PS / 1000.0) 1'b1;
        o_rwds <= #(PARA_TCKD_PS / 1000.0) {LPARA_NB{(dj % 2 == 0)}};
      end
      if (!is_rd && ecnt >= data_e0) begin
        dj = ecnt - data_e0;
        if (is_reg) begin
          if (dj == 0)
            wd = (PARA_DQ_W == 8) ? {i_dq[7:0], 8'h00} : i_dq[15:0];
          if (PARA_DQ_W == 8 && dj == 1) begin
            wd = {wd[15:8], i_dq[7:0]};
            n_reg_wr = n_reg_wr + 1;
            if (waddr == 32'h800)
              cr0 = wd;
            if (waddr == 32'h801)
              cr1 = wd;
          end else if (PARA_DQ_W == 16 && dj == 0) begin
            n_reg_wr = n_reg_wr + 1;
            if (waddr == 32'h800)
              cr0 = wd;
            if (waddr == 32'h801)
              cr1 = wd;
          end
        end else begin
          for (int j = 0; j < LPARA_NB; j = j + 1) begin
            if (!i_rwds[j]) begin
              mem[f_baddr(dj * LPARA_NB + j)] = i_dq[8 * j +: 8];
              n_wr_bytes = n_wr_bytes + 1;
            end
          end
        end
      end
    end
    ecnt = ecnt + 1;
  end

// verilator coverage_on
endmodule
