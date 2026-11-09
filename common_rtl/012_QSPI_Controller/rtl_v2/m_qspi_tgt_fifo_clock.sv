/*
 * Project      : QSPI_Controller
 * Author       : Nguyen Quan (user)
 * AI Flow      : VLSIT RTL Generator AI Automation Flow
 * AI Flow Page : https://github.com/nguyenquanicd/VLSIT_RTL_Generator_AI_Model
 * Date         : 2026-11-02
 * Description  : Captures frame config and selects sample/shift SCLK phases (DEC-016, DEC-018).
 *                Config and edge selectors update only while target CS is inactive.
 */
`timescale 1ns/1ps

module m_qspi_tgt_fifo_clock (
  // External target SCLK and frame control
  input  wire        i_clk_spi_tgt,
  input  wire        i_spi_cs_tgt_n,
  input  wire        i_target_en,
  input  wire        i_cpol,
  input  wire        i_cpha,
  input  wire        i_lsb_first,
  input  wire  [5:0] i_word_bits,
  input  wire        i_fifo_rd_en,
  input  wire        i_fifo_wr_en,

  // Target configuration held for one CS-active frame
  output logic       o_cpha_cfg,
  output logic       o_target_en_cfg,
  output logic       o_lsb_first_cfg,
  output logic [5:0] o_word_bits_cfg,

  // Selected positive-edge target clocks
  output logic       o_clk_tgt_shift,
  output logic       o_clk_tgt_sample
);

  logic w_clk_spi_tgt_n;
  logic w_sel_latch_gate_n;
  logic w_fifo_rd_en_n;
  logic w_fifo_wr_en_n;
  logic w_tx_sel_latch_en;
  logic w_rx_sel_latch_en;
  logic w_rx_sel_latch_gate_n;
  logic w_shift_edge_rise_latched;
  logic w_sample_edge_rise_latched;
  logic w_cs_active;

  // Open the selector latch only between frames and with read side effects disabled.
  VLSIT_CELL_INV u_dont_touch_fifo_rd_en_inv (
    .I  (i_fifo_rd_en),
    .ZN (w_fifo_rd_en_n)
  );

  VLSIT_CELL_INV u_dont_touch_fifo_wr_en_inv (
    .I  (i_fifo_wr_en),
    .ZN (w_fifo_wr_en_n)
  );

  VLSIT_CELL_AND2 u_dont_touch_tx_sel_latch_en (
    .A (i_spi_cs_tgt_n),
    .B (w_fifo_rd_en_n),
    .Z (w_tx_sel_latch_en)
  );

  VLSIT_CELL_AND2 u_dont_touch_rx_sel_latch_en (
    .A (i_spi_cs_tgt_n),
    .B (w_fifo_wr_en_n),
    .Z (w_rx_sel_latch_en)
  );

  VLSIT_CELL_INV u_dont_touch_tx_sel_gate_inv (
    .I  (w_tx_sel_latch_en),
    .ZN (w_sel_latch_gate_n)
  );

  VLSIT_CELL_INV u_dont_touch_rx_sel_gate_inv (
    .I  (w_rx_sel_latch_en),
    .ZN (w_rx_sel_latch_gate_n)
  );

  VLSIT_CELL_INV u_dont_touch_cs_active_inv (
    .I  (i_spi_cs_tgt_n),
    .ZN (w_cs_active)
  );

  VLSIT_CELL_LAT_L u_dont_touch_clk_sel_latch (
    .G (w_sel_latch_gate_n),
    .D (i_cpol ^ i_cpha),
    .Q (w_shift_edge_rise_latched)
  );

  VLSIT_CELL_LAT_L u_dont_touch_sam_sel_latch (
    .G (w_rx_sel_latch_gate_n),
    .D (~(i_cpol ^ i_cpha)),
    .Q (w_sample_edge_rise_latched)
  );

  // Hold target framing settings stable throughout the CS-active interval.
  VLSIT_CELL_LAT_L u_dont_touch_tgt_cpha_latch (
    .G (w_cs_active),
    .D (i_cpha),
    .Q (o_cpha_cfg)
  );

  // Hold target enable stable for the active external frame.
  VLSIT_CELL_LAT_L u_dont_touch_tgt_en_latch (
    .G (w_cs_active),
    .D (i_target_en),
    .Q (o_target_en_cfg)
  );

  VLSIT_CELL_LAT_L u_dont_touch_tgt_lsb_latch (
    .G (w_cs_active),
    .D (i_lsb_first),
    .Q (o_lsb_first_cfg)
  );

  // The latch cell is one bit wide; replicate it for the six-bit word-length field.
  generate
    for (genvar gen_word_idx = 0; gen_word_idx < 6; gen_word_idx = gen_word_idx + 1) begin : gen_word_cfg_latch
      VLSIT_CELL_LAT_L u_dont_touch_tgt_word_latch (
        .G (w_cs_active),
        .D (i_word_bits[gen_word_idx]),
        .Q (o_word_bits_cfg[gen_word_idx])
      );
    end
  endgenerate

  // The local library provides the inverter and clock-mux technology-cell models.
  VLSIT_CELL_CKINV u_dont_touch_sclk_inverter (
    .I  (i_clk_spi_tgt),
    .ZN (w_clk_spi_tgt_n)
  );

  VLSIT_CELL_CKMUX2 u_dont_touch_tgt_clk_mux (
    .I0 (w_clk_spi_tgt_n),
    .I1 (i_clk_spi_tgt),
    .S  (w_shift_edge_rise_latched),
    .Z  (o_clk_tgt_shift)
  );

  VLSIT_CELL_CKMUX2 u_dont_touch_sam_clk_mux (
    .I0 (w_clk_spi_tgt_n),
    .I1 (i_clk_spi_tgt),
    .S  (w_sample_edge_rise_latched),
    .Z  (o_clk_tgt_sample)
  );

endmodule
