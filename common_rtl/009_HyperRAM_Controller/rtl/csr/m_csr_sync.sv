/*
 * Project      : HyperRAM Controller
 * Author       : Nguyen Quan (user)
 * AI Flow      : VLSIT RTL Generator AI Automation Flow
 * AI Flow Page : https://github.com/nguyenquanicd/VLSIT_RTL_Generator_AI_Model
 * Date         : 2026-10-31
 * Description  : Adapter of APB-CSR-Generator to the library. It keeps the module name, the
 *                parameter and the port names that the generated CSR module instantiates
 *                (m_csr_sync with PARA_LEVELS, i_clk_dst, i_rst_n_dst, i_d, o_q) and forwards
 *                them to the library wrapper m_vlsit_afifo_cell_sync (one synchronizer cell,
 *                2 to 4 stages). It replaces the placeholder model of the generator.
 *                Written by vlsit_csr_generate.py; do not edit by hand.
 *                The RTL follows the VLSIT RTL Design Rule v2.
 */
`timescale 1ns/1ps

module m_csr_sync #(
  // Parameter Description: number of synchronizer stages that the generated CSR module asks for.
  // Parameter values: 2, 3 or 4; default is 2.
  // Parameter unit: stage
  parameter logic [31:0] PARA_LEVELS = 2
) (
  // Destination clock and reset
  input  wire  i_clk_dst,
  input  wire  i_rst_n_dst,

  // Synchronized bit
  input  wire  i_d,
  output logic o_q
);

  // Synchronizer cell: the library wrapper selects the 2-FF, 3-FF or 4-FF cell by the stage count.
  m_vlsit_afifo_cell_sync #(
    .PARA_AFIFO_CELL_RST_VAL (32'd0),
    .PARA_AFIFO_CELL_TYPE    (PARA_LEVELS)
  ) u_sync (
    .i_clk_dst   (i_clk_dst),
    .i_rst_n_dst (i_rst_n_dst),
    .i_d         (i_d),
    .o_q         (o_q)
  );

endmodule
