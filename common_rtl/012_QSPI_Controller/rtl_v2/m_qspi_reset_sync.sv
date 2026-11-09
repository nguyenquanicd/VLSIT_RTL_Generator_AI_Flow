/*
 * Project      : QSPI_Controller
 * Author       : Nguyen Quan (user)
 * AI Flow      : VLSIT RTL Generator AI Automation Flow
 * AI Flow Page : https://github.com/nguyenquanicd/VLSIT_RTL_Generator_AI_Model
 * Date         : 2026-11-02
 * Description  : Synchronizes resets into APB, AXI, controller and target domains (DEC-019).
 *                Target sample/shift clocks may stop while idle, so target release uses APB.
 */
`timescale 1ns/1ps

module m_qspi_reset_sync (
  // Clock and reset inputs
  input  wire  i_clk_apb,
  input  wire  i_rst_n_apb,
  input  wire  i_clk_axi,
  input  wire  i_rst_n_axi,
  input  wire  i_clk_serial,
  input  wire  i_rst_n_serial,

  // Domain-local reset outputs
  output logic o_rst_n_apb,
  output logic o_rst_n_axi,
  output logic o_rst_n_serial,
  output logic o_rst_n_spi_tgt
);

  // APB reset synchronizer: asynchronous assertion and APB-clocked release.
  m_vlsit_rst_sync u_rst_sync_apb (
    .i_clk_dst   (i_clk_apb),
    .i_rst_n_src (i_rst_n_apb),
    .o_rst_n_dst (o_rst_n_apb)
  );

  // AXI reset synchronizer: asynchronous assertion and AXI-clocked release.
  m_vlsit_rst_sync u_rst_sync_axi (
    .i_clk_dst   (i_clk_axi),
    .i_rst_n_src (i_rst_n_axi),
    .o_rst_n_dst (o_rst_n_axi)
  );

  // Controller reset synchronizer: asynchronous assertion and serial-clocked release.
  m_vlsit_rst_sync u_rst_sync_serial (
    .i_clk_dst   (i_clk_serial),
    .i_rst_n_src (i_rst_n_serial),
    .o_rst_n_dst (o_rst_n_serial)
  );

  // Target reset release is synchronized to APB so stopped SCLK cannot consume initial edges.
  m_vlsit_rst_sync u_rst_sync_target (
    .i_clk_dst   (i_clk_apb),
    .i_rst_n_src (i_rst_n_apb && i_rst_n_serial),
    .o_rst_n_dst (o_rst_n_spi_tgt)
  );

endmodule
