/*
 * Project      : VLSIT Common RTL library
 * Author       : Nguyen Quan and Claude Sonnet 5.5 (user)
 * AI Flow      : VLSIT RTL Generator AI Automation Flow
 * AI Flow Page : https://github.com/nguyenquanicd/VLSIT_RTL_Generator_AI_Model
 * Date         : 2026-10-27
 * Description  : Serial-word CRC engine using the shared frame initialization value.
 */
`timescale 1ns/1ps

module m_crc_initial_value #(
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
  localparam logic [31:0] LPARA_CRC_W_MIN = 32'd2,
  localparam logic [31:0] LPARA_CRC_W_MAX = 32'd32,
  localparam logic [31:0] LPARA_CRC_W_DFLT = 32'd8,
  localparam logic [31:0] LPARA_WORD_MIN = 32'd8,
  localparam logic [31:0] LPARA_WORD_MAX = 32'd256,
  localparam logic [31:0] LPARA_BITS_PER_BYTE = 32'd8,
  localparam logic [31:0] LPARA_BIT_IDX_W = 32'd3,
  localparam logic [31:0] LPARA_CRC_W =
    ((PARA_CRC_W >= LPARA_CRC_W_MIN) && (PARA_CRC_W <= LPARA_CRC_W_MAX)) ?
      PARA_CRC_W : LPARA_CRC_W_DFLT,
  localparam logic [31:0] LPARA_DATA_W =
    ((PARA_DATA_W >= LPARA_WORD_MIN) && (PARA_DATA_W <= LPARA_WORD_MAX) &&
     ((PARA_DATA_W % LPARA_BITS_PER_BYTE) == 32'd0)) ? PARA_DATA_W : LPARA_WORD_MIN,
  localparam logic [31:0] LPARA_KEEP_W = LPARA_DATA_W / LPARA_BITS_PER_BYTE,
  localparam logic [31:0] LPARA_BYTE_IDX_W =
    ($clog2(LPARA_KEEP_W) > 0) ? $clog2(LPARA_KEEP_W) : 32'd1,
  localparam logic [31:0] LPARA_AUG_W = $clog2(LPARA_CRC_W + 32'd1),
  localparam logic [31:0] LPARA_DATA_IDX_W = $clog2(LPARA_DATA_W)
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
  logic [LPARA_BYTE_IDX_W-1:0] reg_byte_idx;
  logic [LPARA_BIT_IDX_W-1:0] reg_bit_idx;
  logic [LPARA_AUG_W-1:0] reg_aug_count;
  logic                   reg_last;
  logic                   reg_busy;
  logic                   reg_augment;
  logic                   reg_crc_valid;
  logic [LPARA_DATA_IDX_W-1:0] w_data_idx;
  logic [LPARA_CRC_W-1:0] w_crc_step;
  logic                   w_payload_done;

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

  // Select one payload bit per cycle using lane order and the configured reflection.
  always_comb begin : p_com_word_bit
    w_data_idx = '0;
    w_crc_step = '0;
    w_payload_done = 1'b0;
    if (PARA_CRC_REF_IN == 32'd1) begin
      w_data_idx = $bits(w_data_idx)'(
        (reg_byte_idx * LPARA_BITS_PER_BYTE) + reg_bit_idx
      );
    end else begin
      w_data_idx = $bits(w_data_idx)'(
        (reg_byte_idx * LPARA_BITS_PER_BYTE) +
        (LPARA_BITS_PER_BYTE - 32'd1 -
         $bits(LPARA_BITS_PER_BYTE)'(reg_bit_idx))
      );
    end
    if (reg_augment) begin
      w_crc_step = f_crc_step(reg_crc_state, 1'b0);
    end else begin
      w_crc_step = f_crc_step(reg_crc_state, reg_data[w_data_idx]);
    end
    if (reg_bit_idx == $bits(reg_bit_idx)'(LPARA_BITS_PER_BYTE - 32'd1)) begin
      if (reg_byte_idx == '0) begin
        w_payload_done = 1'b1;
      end else if (!reg_keep[reg_byte_idx - 1'b1]) begin
        w_payload_done = 1'b1;
      end
    end
  end

  // Process each accepted word bitwise, then append CRC_W zeros for the final beat.
  always_ff @(posedge i_clk_crc) begin : p_ff_word_crc
    if (!i_rst_n_crc) begin
      reg_crc_state <= PARA_CRC_INIT[LPARA_CRC_W-1:0];
      reg_crc_output <= '0;
      reg_data <= '0;
      reg_keep <= '0;
      reg_byte_idx <= '0;
      reg_bit_idx <= '0;
      reg_aug_count <= '0;
      reg_last <= 1'b0;
      reg_busy <= 1'b0;
      reg_augment <= 1'b0;
      reg_crc_valid <= 1'b0;
    end else begin
      if (reg_crc_valid && i_crc_ready) begin
        reg_crc_valid <= 1'b0;
      end
      if (reg_busy) begin
        reg_crc_state <= w_crc_step;
        if (reg_augment) begin
          if (reg_aug_count == $bits(reg_aug_count)'(32'd1)) begin
            reg_crc_output <= f_finalize(w_crc_step);
            reg_crc_valid <= 1'b1;
            reg_crc_state <= PARA_CRC_INIT[LPARA_CRC_W-1:0];
            reg_aug_count <= '0;
            reg_augment <= 1'b0;
            reg_busy <= 1'b0;
          end else begin
            reg_aug_count <= $bits(reg_aug_count)'(reg_aug_count - 1'b1);
          end
        end else begin
          casez ({w_payload_done, (reg_bit_idx ==
                 $bits(reg_bit_idx)'(LPARA_BITS_PER_BYTE - 32'd1))})
            2'b1?: begin
              if (reg_last) begin
                reg_augment <= 1'b1;
                reg_aug_count <= $bits(reg_aug_count)'(PARA_CRC_W);
              end else begin
                reg_busy <= 1'b0;
              end
            end
            2'b01: begin
              reg_byte_idx <= $bits(reg_byte_idx)'(reg_byte_idx - 1'b1);
              reg_bit_idx <= '0;
            end
            default: begin
              reg_bit_idx <= $bits(reg_bit_idx)'(reg_bit_idx + 1'b1);
            end
          endcase
        end
      end else if (i_valid && o_data_ready) begin
        reg_data <= i_data;
        reg_keep <= i_keep;
        reg_last <= i_last;
        reg_byte_idx <= $bits(reg_byte_idx)'(LPARA_KEEP_W - 32'd1);
        reg_bit_idx <= '0;
        reg_busy <= 1'b1;
      end
    end
  end

  // Expose readiness only when this channel can accept and retain another word.
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
