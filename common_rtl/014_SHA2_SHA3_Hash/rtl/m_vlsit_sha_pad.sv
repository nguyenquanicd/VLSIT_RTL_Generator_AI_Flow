/*
 * Project      : VLSIT Common RTL library
 * Author       : Nguyen Quan and Claude Sonnet 5.5 (user)
 * AI Flow      : VLSIT RTL Generator AI Automation Flow
 * AI Flow Page : https://github.com/nguyenquanicd/VLSIT_RTL_Generator_AI_Model
 * Date         : 2026-11-09
 * Description  : Padding of the last block (REQ-FUNC-004). The input block holds i_n valid message
 *                bytes (message byte 0 in bits [7:0]); the bytes from i_n on are ignored.
 *                SHA-2 (FIPS 180-4 section 5.1): byte 0x80, zeros, then the message length in bits
 *                as a big-endian 64-bit (SHA-224, SHA-256) or 128-bit (SHA-384, SHA-512) number at
 *                the end of the block; if the length does not fit, o_two is 1 and the block holds
 *                the 0x80 byte only, and a second call with i_second = 1 returns the zero block
 *                that ends with the length. SHA-3 and SHAKE (FIPS 202 sections 5.1, 6.1, 6.2): the
 *                suffix byte 0x06 (SHA-3) or 0x1F (SHAKE) at byte i_n and the bit 0x80 in the last
 *                byte of the block; one block is always enough.
 *                Decisions: DEC-004, DEC-019.
 */
`timescale 1ns/1ps

module m_vlsit_sha_pad #(
  // Parameter Description: size of the block buffer; the largest block of an enabled algorithm.
  // Parameter values: 64 to 168; default is 64.
  // Parameter unit: byte
  parameter logic [31:0] PARA_MAXB = 64,
  localparam logic [31:0] LPARA_BLK_W = 8 * PARA_MAXB,
  // Padding bytes: 0x80 start of SHA-2, suffix 0x06 of SHA-3 (bits 01 and the first padding
  // bit), suffix 0x1F of SHAKE (bits 1111 and the first padding bit), 0x80 final padding bit.
  localparam logic [31:0] LPARA_PAD_SHA2 = 32'h80,
  localparam logic [31:0] LPARA_PAD_SHA3 = 32'h06,
  localparam logic [31:0] LPARA_PAD_SHAKE = 32'h1F,
  localparam logic [31:0] LPARA_PAD_LAST = 32'h80,
  // Algorithm codes of the sha_ctrl.algo field: 2 to 5 SHA-384, SHA-512, SHA-512/224, SHA-512/256,
  // 8 to 11 SHA3-224, SHA3-256, SHA3-384, SHA3-512, 12 and 13 SHAKE128, SHAKE256.
  localparam logic [31:0] LPARA_ALG_SHA384 = 32'd2,
  localparam logic [31:0] LPARA_ALG_SHA512 = 32'd3,
  localparam logic [31:0] LPARA_ALG_SHA512_224 = 32'd4,
  localparam logic [31:0] LPARA_ALG_SHA512_256 = 32'd5,
  localparam logic [31:0] LPARA_ALG_SHA3_224 = 32'd8,
  localparam logic [31:0] LPARA_ALG_SHA3_256 = 32'd9,
  localparam logic [31:0] LPARA_ALG_SHA3_384 = 32'd10,
  localparam logic [31:0] LPARA_ALG_SHA3_512 = 32'd11,
  localparam logic [31:0] LPARA_ALG_SHAKE128 = 32'd12,
  localparam logic [31:0] LPARA_ALG_SHAKE256 = 32'd13
) (
  // Block in and algorithm
  input  wire  [3:0]             i_alg,
  input  wire  [LPARA_BLK_W-1:0] i_blk,
  input  wire  [7:0]             i_n,
  input  wire                    i_second,
  input  wire  [63:0]            i_tot,

  // Padded block out
  output logic [LPARA_BLK_W-1:0] o_blk,
  output logic                   o_two
);

  // Internal signal declarations
  logic [31:0]  w_alg;
  logic [7:0]   w_blk_bytes;
  logic [7:0]   w_len_bytes;
  logic         w_is_sha2;
  logic         w_is_shake;
  logic         w_fit;
  logic         w_len_here;
  logic [127:0] w_bits;
  logic [7:0]   w_byte;
  logic [7:0]   w_lenoff;
  logic [7:0]   w_jj;

  // Block size in bytes and length field size in bytes of the selected algorithm.
  always_comb begin : p_com_size
    w_alg = {28'b0, i_alg};
    w_blk_bytes = 8'd64;
    w_len_bytes = 8'd8;
    case (w_alg)
      LPARA_ALG_SHA384,
      LPARA_ALG_SHA512,
      LPARA_ALG_SHA512_224,
      LPARA_ALG_SHA512_256: begin
        w_blk_bytes = 8'd128;
        w_len_bytes = 8'd16;
      end
      LPARA_ALG_SHA3_224:   w_blk_bytes = 8'd144;
      LPARA_ALG_SHA3_256:   w_blk_bytes = 8'd136;
      LPARA_ALG_SHA3_384:   w_blk_bytes = 8'd104;
      LPARA_ALG_SHA3_512:   w_blk_bytes = 8'd72;
      LPARA_ALG_SHAKE128:   w_blk_bytes = 8'd168;
      LPARA_ALG_SHAKE256:   w_blk_bytes = 8'd136;
      default: begin
        w_blk_bytes = 8'd64;
        w_len_bytes = 8'd8;
      end
    endcase
  end

  // Family flags and the SHA-2 length rule: the length fits in this block when the data, the 0x80
  // byte and the length field need no more than the block size. The message length in bits is
  // the byte count times 8 (a 3-bit shift) in a 128-bit number.
  always_comb begin : p_com_flags
    w_is_sha2  = !i_alg[3];
    w_is_shake = (w_alg == LPARA_ALG_SHAKE128) || (w_alg == LPARA_ALG_SHAKE256);
    w_fit      = ((i_n + 8'd1 + w_len_bytes) <= w_blk_bytes);
    w_len_here = i_second || w_fit;
    w_bits     = {61'b0, i_tot, 3'b0};
    o_two      = w_is_sha2 && !i_second && !w_fit;
  end

  // Byte-by-byte construction of the padded block. A byte inside the data is copied, the byte
  // after the data gets the padding start, the length bytes get the bit length (SHA-2), and the
  // last byte of a SHA-3 block gets the final padding bit. Bytes beyond the block size are zero.
  always_comb begin : p_com_pad
    o_blk = '0;
    w_byte = 8'h00;
    w_lenoff = 8'h00;
    w_jj = 8'h00;
    for (int idx = 0; idx < PARA_MAXB; idx++) begin
      w_jj = $bits(w_jj)'(idx);
      w_byte = 8'h00;
      w_lenoff = 8'h00;
      if (w_jj < w_blk_bytes) begin
        if (w_is_sha2) begin
          w_lenoff = w_jj - (w_blk_bytes - w_len_bytes);
          // Priority: message data, then the 0x80 byte, then the length field.
          casez ({(!i_second && (w_jj < i_n)), (!i_second && (w_jj == i_n)),
                  (w_len_here && (w_jj >= (w_blk_bytes - w_len_bytes)))})
            3'b1??:  w_byte = i_blk[8*idx +: 8];
            3'b01?:  w_byte = LPARA_PAD_SHA2[7:0];
            3'b001:  w_byte = w_bits[8*(w_len_bytes - 8'd1 - w_lenoff) +: 8];
            default: w_byte = 8'h00;
          endcase
        end else begin
          if (w_jj < i_n)
            w_byte = i_blk[8*idx +: 8];
          else if (w_jj == i_n)
            w_byte = w_is_shake ? LPARA_PAD_SHAKE[7:0] : LPARA_PAD_SHA3[7:0];
          if (w_jj == (w_blk_bytes - 8'd1))
            w_byte = w_byte | LPARA_PAD_LAST[7:0];
        end
      end
      o_blk[8*idx +: 8] = w_byte;
    end
  end

endmodule
