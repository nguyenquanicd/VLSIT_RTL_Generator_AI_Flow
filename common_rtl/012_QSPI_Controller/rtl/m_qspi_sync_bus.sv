/*
 * Project      : QSPI_Controller
 * Author       : Nguyen Quan (user)
 * AI Flow      : VLSIT RTL Generator AI Automation Flow
 * AI Flow Page : https://github.com/nguyenquanicd/VLSIT_RTL_Generator_AI_Model
 * Date         : 2026-11-03
 * Description  : Two-flop synchronizer bank for stable multi-bit configuration sampled only after
 *                software has programmed and settled the source-domain fields.
 */
`timescale 1ns/1ps

module m_qspi_sync_bus #(
  // Parameter Description: number of stable configuration bits to synchronize.
  // Parameter values: 1 or greater; default is 1.
  // Parameter unit: bit
  parameter logic [31:0] PARA_SYNC_W = 32'd1
) (
  // Destination clock and reset
  input  wire                    i_clk_dst,
  input  wire                    i_rst_n_dst,

  // Stable source and synchronized destination configuration
  input  wire  [PARA_SYNC_W-1:0] i_data_src,
  output logic [PARA_SYNC_W-1:0] o_data_dst
);

  // Synchronize each stable configuration bit into the destination clock domain.
  generate
    for (genvar gen_sync_idx = 0; gen_sync_idx < PARA_SYNC_W; gen_sync_idx = gen_sync_idx + 1) begin : gen_sync_bit
      VLSIT_CELL_SYNC_2FF_RN u_dont_touch_cfg_sync (
        .CK (i_clk_dst),
        .RN (i_rst_n_dst),
        .D  (i_data_src[gen_sync_idx]),
        .Q  (o_data_dst[gen_sync_idx])
      );
    end
  endgenerate

endmodule
