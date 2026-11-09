/*
 * Project      : QSPI_Controller
 * Author       : Nguyen Quan (user)
 * AI Flow      : VLSIT RTL Generator AI Automation Flow
 * AI Flow Page : https://github.com/nguyenquanicd/VLSIT_RTL_Generator_AI_Model
 * Date         : 2026-11-03
 * Description  : Packs serial response bytes into AXI narrow/full-width beats while preserving
 *                R-channel backpressure and converting controller aborts to SLVERR responses.
 */
`timescale 1ns/1ps

module m_qspi_xip_rsp_pack #(
  // Parameter Description: AXI XIP response data width.
  // Parameter values: 32, 64 or 128; default is 32.
  // Parameter unit: bit
  parameter logic [31:0] PARA_AXI_DATA_W = 32'd32,
  // Parameter Description: AXI XIP response address width.
  // Parameter values: 32 through 64; default is 32.
  // Parameter unit: bit
  parameter logic [31:0] PARA_AXI_ADDR_W = 32'd32,
  localparam logic [31:0] LPARA_FIFO_DATA_W = 32'd36,
  localparam logic [31:0] LPARA_BUS_BYTES = PARA_AXI_DATA_W / 32'd8,
  localparam logic [31:0] LPARA_BUS_BYTE_LSB = $clog2(LPARA_BUS_BYTES),
  localparam logic [31:0] LPARA_BYTE_W = 32'd8,
  localparam logic [31:0] LPARA_COUNT_W = 32'd3,
  localparam logic [31:0] LPARA_IDX_W = LPARA_BUS_BYTE_LSB + 32'd1,
  localparam logic [31:0] LPARA_FIFO_COUNT_LSB = 32'd32,
  localparam logic [31:0] LPARA_RESP_OKAY = 32'd0,
  localparam logic [31:0] LPARA_RESP_SLVERR = 32'd2
) (
  // AXI response clock and reset
  input  wire                          i_clk_axi,
  input  wire                          i_rst_n_axi,

  // Current accepted burst metadata from the AXI XIP subordinate
  input  wire                          i_burst_active,
  input  wire  [PARA_AXI_ADDR_W-1:0]   i_burst_addr,
  input  wire  [7:0]                   i_burst_len,
  input  wire  [2:0]                   i_burst_size,

  // Asynchronous FIFO read side
  input  wire  [LPARA_FIFO_DATA_W-1:0] i_fifo_data,
  input  wire                          i_fifo_empty,
  output logic                         o_fifo_pop,

  // AXI response stream toward the XIP subordinate
  output logic                         o_rsp_valid,
  input  wire                          i_rsp_ready,
  output logic [PARA_AXI_DATA_W-1:0]   o_rsp_data,
  output logic [1:0]                   o_rsp_resp,
  output logic                         o_rsp_last
);

  logic reg_active;
  logic reg_stream_err;
  logic reg_word_valid;
  logic [31:0] reg_word_data;
  logic [2:0] reg_word_bytes;
  logic [2:0] reg_word_byte_idx;
  logic [2:0] reg_beat_byte_count;
  logic [8:0] reg_beats_left;
  logic [2:0] reg_beat_size;
  logic [PARA_AXI_ADDR_W-1:0] reg_beat_addr;
  logic [PARA_AXI_DATA_W-1:0] reg_pack_data;
  logic [PARA_AXI_DATA_W-1:0] w_pack_data_nxt;
  logic [LPARA_BUS_BYTE_LSB:0] w_bus_lane_idx;
  logic [2:0] w_beat_bytes;
  logic w_fifo_pop;
  logic w_rsp_handshake;
  logic w_word_byte_consume;
  logic w_beat_complete;
  logic w_stream_err_rsp;
  logic reg_rsp_valid;
  logic [PARA_AXI_DATA_W-1:0] reg_rsp_data;
  logic [1:0] reg_rsp_resp;
  logic reg_rsp_last;

  // Read one FIFO word at a time and place each serial byte into its AXI lane.
  always_comb begin : p_com_xip_rsp
    w_beat_bytes = 3'd1 << reg_beat_size;
    w_bus_lane_idx = {{(LPARA_IDX_W-LPARA_COUNT_W){1'b0}},
                      reg_beat_addr[LPARA_BUS_BYTE_LSB-1:0]} +
                     {{(LPARA_IDX_W-LPARA_COUNT_W){1'b0}}, reg_beat_byte_count};
    w_pack_data_nxt = reg_pack_data;
    w_pack_data_nxt[(w_bus_lane_idx * LPARA_BYTE_W) +: LPARA_BYTE_W] =
      reg_word_data[(reg_word_byte_idx * LPARA_BYTE_W) +: LPARA_BYTE_W];
    w_fifo_pop = reg_active && !reg_stream_err && !reg_rsp_valid &&
                 !reg_word_valid && !i_fifo_empty;
    o_fifo_pop = w_fifo_pop;
    w_word_byte_consume = reg_active && !reg_stream_err && !reg_rsp_valid &&
                          reg_word_valid && (reg_word_bytes != 3'd0);
    w_beat_complete = w_word_byte_consume &&
                      ((reg_beat_byte_count + 3'd1) >= w_beat_bytes);
    w_stream_err_rsp = reg_active && reg_stream_err && !reg_rsp_valid;
    w_rsp_handshake = reg_rsp_valid && i_rsp_ready;
    o_rsp_valid = reg_rsp_valid;
    o_rsp_data = reg_rsp_data;
    o_rsp_resp = reg_rsp_resp;
    o_rsp_last = reg_rsp_last;
  end

  // Snapshot one burst, assemble each response beat, and hold it until AXI accepts it.
  always_ff @(posedge i_clk_axi, negedge i_rst_n_axi) begin : p_ff_xip_rsp
    if (!i_rst_n_axi) begin
      reg_active <= 1'b0;
      reg_stream_err <= 1'b0;
      reg_word_valid <= 1'b0;
      reg_word_data <= 32'd0;
      reg_word_bytes <= 3'd0;
      reg_word_byte_idx <= 3'd0;
      reg_beat_byte_count <= 3'd0;
      reg_beats_left <= 9'd0;
      reg_beat_size <= 3'd0;
      reg_beat_addr <= '0;
      reg_pack_data <= '0;
      reg_rsp_valid <= 1'b0;
      reg_rsp_data <= '0;
      reg_rsp_resp <= LPARA_RESP_SLVERR[1:0];
      reg_rsp_last <= 1'b0;
    end else begin
      if (i_burst_active && !reg_active) begin
        reg_active <= 1'b1;
        reg_stream_err <= 1'b0;
        reg_word_valid <= 1'b0;
        reg_word_bytes <= 3'd0;
        reg_word_byte_idx <= 3'd0;
        reg_beat_byte_count <= 3'd0;
        reg_beats_left <= {1'b0, i_burst_len} + 9'd1;
        reg_beat_size <= i_burst_size;
        reg_beat_addr <= i_burst_addr;
        reg_pack_data <= '0;
        reg_rsp_valid <= 1'b0;
      end

      if (w_fifo_pop) begin
        if (i_fifo_data[LPARA_FIFO_DATA_W-1] ||
            (i_fifo_data[LPARA_FIFO_COUNT_LSB +: LPARA_COUNT_W] == 3'd0)) begin
          reg_word_valid <= 1'b0;
          reg_word_bytes <= 3'd0;
          reg_word_byte_idx <= 3'd0;
          reg_stream_err <= 1'b1;
        end else begin
          reg_word_valid <= 1'b1;
          reg_word_data <= i_fifo_data[31:0];
          reg_word_bytes <= i_fifo_data[LPARA_FIFO_COUNT_LSB +: LPARA_COUNT_W];
          reg_word_byte_idx <= 3'd0;
        end
      end

      if (w_word_byte_consume) begin
        reg_pack_data <= w_pack_data_nxt;
        reg_beat_byte_count <= reg_beat_byte_count + 3'd1;
        if (reg_word_bytes == 3'd1) begin
          reg_word_valid <= 1'b0;
          reg_word_bytes <= 3'd0;
          reg_word_byte_idx <= 3'd0;
        end else begin
          reg_word_bytes <= reg_word_bytes - 3'd1;
          reg_word_byte_idx <= reg_word_byte_idx + 3'd1;
        end
        if (w_beat_complete) begin
          reg_rsp_valid <= 1'b1;
          reg_rsp_data <= w_pack_data_nxt;
          reg_rsp_resp <= LPARA_RESP_OKAY[1:0];
          reg_rsp_last <= (reg_beats_left == 9'd1);
        end
      end

      if (w_stream_err_rsp) begin
        reg_rsp_valid <= 1'b1;
        reg_rsp_data <= '0;
        reg_rsp_resp <= LPARA_RESP_SLVERR[1:0];
        reg_rsp_last <= (reg_beats_left == 9'd1);
      end

      if (w_rsp_handshake) begin
        reg_rsp_valid <= 1'b0;
        if (reg_beats_left == 9'd1) begin
          reg_active <= 1'b0;
          reg_beats_left <= 9'd0;
        end else begin
          reg_beats_left <= reg_beats_left - 9'd1;
          reg_beat_addr <= reg_beat_addr + (32'd1 << reg_beat_size);
        end
        reg_pack_data <= '0;
        reg_beat_byte_count <= 3'd0;
      end
    end
  end

endmodule
