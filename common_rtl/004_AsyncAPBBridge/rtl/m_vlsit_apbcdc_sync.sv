/*
 * Project      : VLSIT Common RTL library
 * Author       : Nguyen Quan and Claude Sonnet 5.5 (user)
 * AI Flow      : VLSIT RTL Generator AI Automation Flow
 * AI Flow Page : https://github.com/nguyenquanicd/VLSIT_RTL_Generator_AI_Model
 * Date         : 2026-10-25
 * Description  : Synchronizer of the asynchronous APB bridge for a vector of PARA_APBCDC_SYNC_W
 *                bits. It instantiates one technology cell wrapper m_vlsit_apbcdc_cell_sync per bit
 *                and nothing else: the cell option PARA_APBCDC_CELL_TYPE (bypass, two D flip-flop
 *                cells, or a 2-FF, 3-FF or 4-FF cell) sets the number of stages, and the reset
 *                flavour of every bit follows its reset value bit. The synthesis cells and the
 *                metastability model of the simulation flow are inside m_vlsit_apbcdc_cell_sync
 *                (DEC-022, REQ-RTL-002).
 */
`timescale 1ns/1ps

module m_vlsit_apbcdc_sync #(
  // Parameter Description: number of synchronized bits.
  // Parameter values: 1 or more; no default in the parent (set to the number of control bits).
  // Parameter unit: bit
  parameter logic [31:0] PARA_APBCDC_SYNC_W = 1,
  // Parameter Description: reset value of every stage, one bit per synchronized bit (bit i is the
  // reset value of synchronized bit i). All control bits of this IP reset to 0.
  // Parameter values: any value of PARA_APBCDC_SYNC_W bits; default is 0.
  // Parameter unit: none
  parameter logic [31:0] PARA_APBCDC_SYNC_RST_VAL = 0,
  // Parameter Description: cell selection: 0 = bypass (no stage), 1 = two D flip-flop cells,
  // 2 = one 2-FF cell, 3 = one 3-FF cell, 4 = one 4-FF cell. It sets the number of stages
  // of the synchronizer (0, 2, 2, 3, 4).
  // Parameter values: 0, 1, 2, 3, or 4; default is 2.
  // Parameter unit: none
  parameter logic [31:0] PARA_APBCDC_CELL_TYPE = 2
) (
  // Destination clock and reset
  input  wire                           i_clk_dst,
  input  wire                           i_rst_n_dst,

  // Synchronized data
  input  wire  [PARA_APBCDC_SYNC_W-1:0] i_data,
  output logic [PARA_APBCDC_SYNC_W-1:0] o_data
);

  // One cell wrapper per synchronized bit. The wrapper holds the whole chain of its bit. Input bit
  // i_data[i] goes to the wrapper, and the wrapper output is o_data[i]. No logic is placed in
  // front of the first stage (CLK-01, P28).
  for (genvar gen_bit = 0; gen_bit < PARA_APBCDC_SYNC_W; gen_bit++) begin : gen_bit_cell
    m_vlsit_apbcdc_cell_sync #(
      .PARA_APBCDC_CELL_RST_VAL (32'(PARA_APBCDC_SYNC_RST_VAL[gen_bit])),
      .PARA_APBCDC_CELL_TYPE    (PARA_APBCDC_CELL_TYPE)
    ) u_vlsit_apbcdc_cell_sync (
      .i_clk_dst   (i_clk_dst),
      .i_rst_n_dst (i_rst_n_dst),
      .i_d         (i_data[gen_bit]),
      .o_q         (o_data[gen_bit])
    );
  end

endmodule
