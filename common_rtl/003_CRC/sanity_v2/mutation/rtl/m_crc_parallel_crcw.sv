/*
 * Project      : VLSIT Common RTL library
 * Author       : Nguyen Quan and Claude Sonnet 5.5 (user)
 * AI Flow      : VLSIT RTL Generator AI Automation Flow
 * AI Flow Page : https://github.com/nguyenquanicd/VLSIT_RTL_Generator_AI_Model
 * Date         : 2026-10-27
 * Description  : Chunked CRC engine with serial chunk scheduling and frame finalization.
 */
`timescale 1ns/1ps

module m_crc_parallel_crcw #(
  // Parameter Description: Width of the CRC state and result.
  // Parameter values: Legal range is 2 to 32; default is 8.
  // Parameter unit: bit
  parameter logic [31:0] PARA_CRC_W = 32'd8,
  // Parameter Description: Width of each input word; must be byte-multiple.
  // Parameter values: Legal range is 8 to 256 in multiples of 8; default is 32.
  // Parameter unit: bit
  parameter logic [31:0] PARA_DATA_W = 32'd32,
  // Parameter Description: Low-order coefficients of the CRC polynomial.
  // Parameter values: Nonzero, odd, and limited to PARA_CRC_W bits; default is 7.
  // Parameter unit: none
  parameter logic [31:0] PARA_CRC_POLY = 32'h0000_0007,
  // Parameter Description: Initial CRC state loaded at the start of each frame.
  // Parameter values: PARA_CRC_W bits; default is 0.
  // Parameter unit: none
  parameter logic [31:0] PARA_CRC_INIT = 32'h0000_0000,
  // Parameter Description: XOR mask applied after output reflection.
  // Parameter values: PARA_CRC_W bits; default is 0.
  // Parameter unit: none
  parameter logic [31:0] PARA_CRC_XOR_OUT = 32'h0000_0000,
  // Parameter Description: Reverse bit order within each valid input byte when set.
  // Parameter values: 0 or 1; default is 0.
  // Parameter unit: none
  parameter logic [31:0] PARA_CRC_REF_IN = 32'd0,
  // Parameter Description: Reverse the CRC result before applying XOR_OUT.
  // Parameter values: 0 or 1; default is 0.
  // Parameter unit: none
  parameter logic [31:0] PARA_CRC_REF_OUT = 32'd0,
  // Parameter Description: Number of payload bits processed in one chunk.
  // Parameter values: 2 to 32; method 3 requires PARA_CAL_W=PARA_CRC_W; default is 8.
  // Parameter unit: bit
  parameter logic [31:0] PARA_CAL_W = 32'd8,
  localparam logic [31:0] LPARA_CRC_W_MIN = 32'd2,
  localparam logic [31:0] LPARA_CRC_W_MAX = 32'd32,
  localparam logic [31:0] LPARA_CRC_W_DFLT = 32'd8,
  localparam logic [31:0] LPARA_WORD_MIN = 32'd8,
  localparam logic [31:0] LPARA_WORD_MAX = 32'd256,
  localparam logic [31:0] LPARA_BITS_PER_BYTE = 32'd8,
  localparam logic [31:0] LPARA_CHUNK_W_MIN = 32'd2,
  localparam logic [31:0] LPARA_CHUNK_W_MAX = 32'd32,
  localparam logic [31:0] LPARA_CHUNK_W_DFLT = 32'd8,
  localparam logic [31:0] LPARA_CRC_W =
    ((PARA_CRC_W >= LPARA_CRC_W_MIN) && (PARA_CRC_W <= LPARA_CRC_W_MAX)) ?
      PARA_CRC_W : LPARA_CRC_W_DFLT,
  localparam logic [31:0] LPARA_DATA_W =
    ((PARA_DATA_W >= LPARA_WORD_MIN) && (PARA_DATA_W <= LPARA_WORD_MAX) &&
     ((PARA_DATA_W % LPARA_BITS_PER_BYTE) == 32'd0)) ? PARA_DATA_W : LPARA_WORD_MIN,
  localparam logic [31:0] LPARA_KEEP_W = LPARA_DATA_W / LPARA_BITS_PER_BYTE,
  localparam logic [31:0] LPARA_DATA_IDX_W = $clog2(LPARA_DATA_W),
  localparam logic [31:0] LPARA_COUNT_W = $clog2(LPARA_DATA_W + 32'd1),
  localparam logic [31:0] LPARA_CHUNK_W =
    ((PARA_CAL_W >= LPARA_CHUNK_W_MIN) && (PARA_CAL_W <= LPARA_CHUNK_W_MAX)) ?
      PARA_CAL_W : LPARA_CHUNK_W_DFLT
) (
  // Clock and reset
  input  wire                     i_clk_crc,
  input  wire                     i_rst_n_crc,

  // Word payload stream
  input  wire  [LPARA_DATA_W-1:0] i_data,
  input  wire  [LPARA_KEEP_W-1:0] i_keep,
  input  wire                     i_valid,
  input  wire                     i_last,
  output logic                    o_data_ready,

  // CRC result handshake
  output logic [LPARA_CRC_W-1:0]  o_crc,
  output logic                    o_crc_valid,
  input  wire                     i_crc_ready);

  logic [LPARA_CRC_W-1:0] reg_crc_state;
  logic [LPARA_CRC_W-1:0] reg_crc_output;
  logic [LPARA_DATA_W-1:0] reg_data;
  logic [LPARA_KEEP_W-1:0] reg_keep;
  logic [LPARA_COUNT_W-1:0] reg_chunk_idx;
  logic [LPARA_COUNT_W-1:0] w_valid_byte_cnt;
  logic [LPARA_COUNT_W-1:0] w_valid_bit_cnt;
  logic [LPARA_COUNT_W-1:0] w_bit_ord;
  logic [LPARA_COUNT_W-1:0] w_byte_idx;
  logic [LPARA_COUNT_W-1:0] w_bit_in_byte;
  logic [LPARA_DATA_IDX_W-1:0] w_data_idx;
  logic [LPARA_CRC_W-1:0] w_chunk_crc;
  logic                   reg_last;
  logic                   reg_busy;
  logic                   reg_augment;
  logic                   reg_crc_valid;

  function automatic logic [LPARA_CRC_W-1:0] f_crc_step(
    input logic [LPARA_CRC_W-1:0] i_crc,
    input logic                   i_data_bit
  );
    logic [LPARA_CRC_W-1:0] w_shifted_crc;
    begin
      w_shifted_crc = $bits(w_shifted_crc)'(i_crc << 1);
      w_shifted_crc[0] = i_data_bit;
      if (i_crc[LPARA_CRC_W-1]) begin
        f_crc_step = w_shifted_crc ^ PARA_CRC_POLY[LPARA_CRC_W-1:0];
      end else begin
        f_crc_step = w_shifted_crc;
      end
    end
  endfunction

  function automatic logic [LPARA_CRC_W-1:0] f_finalize(
    input logic [LPARA_CRC_W-1:0] i_crc
  );
    logic [LPARA_CRC_W-1:0] w_reflected_crc;
    begin
      w_reflected_crc = '0;
      for (int idx = 0; idx < LPARA_CRC_W; idx++) begin
        if (PARA_CRC_REF_OUT == 32'd1) begin
          w_reflected_crc[idx] = i_crc[LPARA_CRC_W-1-idx];
        end else begin
          w_reflected_crc[idx] = i_crc[idx];
        end
      end
      f_finalize = $bits(w_reflected_crc)'(
        w_reflected_crc ^ PARA_CRC_XOR_OUT[LPARA_CRC_W-1:0]
      );
    end
  endfunction

  // Count valid lanes and update one configured-width chunk in stream order.
  always_comb begin : p_com_chunk_crc
    w_valid_byte_cnt = '0;
    w_valid_bit_cnt = '0;
    w_bit_ord = '0;
    w_byte_idx = '0;
    w_bit_in_byte = '0;
    w_data_idx = '0;
    w_chunk_crc = reg_crc_state;
    for (int keep_idx = 0; keep_idx < LPARA_KEEP_W; keep_idx++) begin
      if (reg_keep[keep_idx]) begin
        w_valid_byte_cnt = $bits(w_valid_byte_cnt)'(w_valid_byte_cnt + 1'b1);
      end
    end
    w_valid_bit_cnt = $bits(w_valid_bit_cnt)'(w_valid_byte_cnt * LPARA_BITS_PER_BYTE);
    if (reg_augment) begin
      for (int bit_idx = 0; bit_idx < LPARA_CHUNK_W; bit_idx++) begin
        w_chunk_crc = f_crc_step(w_chunk_crc, 1'b0);
      end
    end else begin
      for (int bit_idx = 0; bit_idx < LPARA_CHUNK_W; bit_idx++) begin
        w_bit_ord = $bits(w_bit_ord)'(reg_chunk_idx + bit_idx);
        if (w_bit_ord < w_valid_bit_cnt) begin
          w_byte_idx = $bits(w_byte_idx)'(
            LPARA_KEEP_W - 32'd1 -
            ($bits(LPARA_DATA_W)'(w_bit_ord) / LPARA_BITS_PER_BYTE)
          );
          w_bit_in_byte = $bits(w_bit_in_byte)'(w_bit_ord % LPARA_BITS_PER_BYTE);
          if (PARA_CRC_REF_IN == 32'd1) begin
            w_data_idx = $bits(w_data_idx)'(
              (w_byte_idx * LPARA_BITS_PER_BYTE) + w_bit_in_byte
            );
          end else begin
            w_data_idx = $bits(w_data_idx)'(
              (w_byte_idx * LPARA_BITS_PER_BYTE) +
              (LPARA_BITS_PER_BYTE - 32'd1 -
               $bits(LPARA_BITS_PER_BYTE)'(w_bit_in_byte))
            );
          end
          w_chunk_crc = f_crc_step(w_chunk_crc, reg_data[w_data_idx]);
        end
      end
    end
  end

  // Capture words, process ceil(valid_bits/CAL_W) chunks, then one CRC_W augmentation chunk.
  always_ff @(posedge i_clk_crc) begin : p_ff_chunk_crc
    if (!i_rst_n_crc) begin
      reg_crc_state <= PARA_CRC_INIT[LPARA_CRC_W-1:0];
      reg_crc_output <= '0;
      reg_data <= '0;
      reg_keep <= '0;
      reg_chunk_idx <= '0;
      reg_last <= 1'b0;
      reg_busy <= 1'b0;
      reg_augment <= 1'b0;
      reg_crc_valid <= 1'b0;
    end else begin
      if (reg_crc_valid && i_crc_ready) begin
        reg_crc_valid <= 1'b0;
      end
      if (reg_busy) begin
        reg_crc_state <= w_chunk_crc;
        if (reg_augment) begin
          reg_crc_output <= f_finalize(w_chunk_crc);
          reg_crc_valid <= 1'b1;
          reg_crc_state <= PARA_CRC_INIT[LPARA_CRC_W-1:0];
          reg_busy <= 1'b0;
          reg_augment <= 1'b0;
        end else if ($bits(reg_chunk_idx)'(reg_chunk_idx + LPARA_CHUNK_W) >=
                     $bits(reg_chunk_idx)'(w_valid_bit_cnt)) begin
          if (reg_last) begin
            reg_chunk_idx <= '0;
            reg_augment <= 1'b1;
          end else begin
            reg_chunk_idx <= '0;
            reg_busy <= 1'b0;
          end
        end else begin
          reg_chunk_idx <= $bits(reg_chunk_idx)'(reg_chunk_idx + LPARA_CHUNK_W);
        end
      end else if (i_valid && o_data_ready) begin
        reg_data <= i_data;
        reg_keep <= i_keep;
        reg_last <= i_last;
        reg_chunk_idx <= '0;
        reg_busy <= 1'b1;
      end
    end
  end

  // Stall only this channel while a word chunk or finalized result is pending.
  always_comb begin : p_com_stream_ready
    o_data_ready = 1'b0;
    if (i_rst_n_crc && !reg_busy && !reg_crc_valid) begin
      o_data_ready = 1'b1;
    end
  end

  // Expose registered CRC result state at the module boundary.
  assign o_crc = reg_crc_output;
  assign o_crc_valid = reg_crc_valid;

endmodule
