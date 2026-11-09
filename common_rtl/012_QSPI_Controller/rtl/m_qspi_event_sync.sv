/*
 * Project      : QSPI_Controller
 * Author       : Nguyen Quan (user)
 * AI Flow      : VLSIT RTL Generator AI Automation Flow
 * AI Flow Page : https://github.com/nguyenquanicd/VLSIT_RTL_Generator_AI_Model
 * Date         : 2026-11-08
 * Description  : Compatibility wrapper around the common request/acknowledge event synchronizer.
 */
`timescale 1ns/1ps

module m_qspi_event_sync #(
  // Parameter Description: number of independent event bits.
  // Parameter values: 1 or greater; default is 1.
  // Parameter unit: bit
  parameter logic [31:0] PARA_EVENT_W = 32'd1,
  localparam logic [31:0] LPARA_EVENT_SYNC_CELL_TYPE_2 = 32'd2
) (
  // Source event clock and reset
  input  wire                     i_clk_src,
  input  wire                     i_rst_n_src,

  // Destination event clock and reset
  input  wire                     i_clk_dst,
  input  wire                     i_rst_n_dst,

  // Source pulse vector and destination pulse vector
  input  wire  [PARA_EVENT_W-1:0] i_event_src,
  output logic [PARA_EVENT_W-1:0] o_event_dst
);

  // Use the shared two-stage VLSIT synchronizer-cell configuration.
  m_vlsit_event_sync #(
    .PARA_EVENT_SYNC_W         (PARA_EVENT_W),
    .PARA_EVENT_SYNC_CELL_TYPE (LPARA_EVENT_SYNC_CELL_TYPE_2)
  ) u_vlsit_event_sync (
    .i_clk_src   (i_clk_src),
    .i_rst_n_src (i_rst_n_src),
    .i_clk_dst   (i_clk_dst),
    .i_rst_n_dst (i_rst_n_dst),
    .i_event_src (i_event_src),
    .o_event_dst (o_event_dst)
  );

endmodule

