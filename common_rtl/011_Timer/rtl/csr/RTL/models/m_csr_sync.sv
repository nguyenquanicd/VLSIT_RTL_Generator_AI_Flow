/*
 * Project      : APB-CSR-Generator
 * Author       : Trthinh (Ethan) (user)
 * AI Flow      : VLSIT RTL Generator AI Automation Flow
 * AI Flow Page : https://github.com/nguyenquanicd/APB-CSR-Generator
 * Date         : 2026-10-28
 * Description  : Behavioral synchronizer model of the generated CSR.
 *                One bit, PARA_LEVELS flip-flops in series.
 *                Placeholder: replace this file by a wrapper of the synchronizer cell of the
 *                technology library before tape-out; keep the module name and the port names.
 *                The RTL follows the VLSIT RTL Design Rule v2.
 */
`timescale 1ns/1ps

module m_csr_sync #(
  // Parameter Description: number of flip-flop stages of the synchronizer.
  // Parameter values: 2 or more; default is 2.
  // Parameter unit: count
  parameter logic [31:0] PARA_LEVELS = 2
) (
  // Destination clock and reset
  input  wire  i_clk_dst,
  input  wire  i_rst_n_dst,

  // Synchronized bit
  input  wire  i_d,
  output logic o_q
);

  // Internal signal declarations
  logic [PARA_LEVELS-1:0] reg_sync;

  // Synchronizer chain: the input is shifted through PARA_LEVELS flip-flops, cleared by the reset.
  always_ff @(posedge i_clk_dst, negedge i_rst_n_dst) begin : p_ff_sync
    if (!i_rst_n_dst)
      reg_sync <= '0;
    else
      reg_sync <= {reg_sync[PARA_LEVELS-2:0], i_d};
  end

  // Output mapping: the last stage is the synchronized bit.
  assign o_q = reg_sync[PARA_LEVELS-1];

endmodule
