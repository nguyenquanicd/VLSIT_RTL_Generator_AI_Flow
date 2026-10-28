/*
 * Project      : VLSIT Common RTL library
 * Author       : Nguyen Quan and Claude Sonnet 5.5 (user)
 * AI Flow      : VLSIT RTL Generator AI Automation Flow
 * AI Flow Page : https://github.com/nguyenquanicd/VLSIT_RTL_Generator_AI_Model
 * Date         : 2026-10-27
 * Description  : Structural top for independent CRC generation and checking streams.
 */
`timescale 1ns/1ps

module m_crc_engine #(
  // Parameter Description: Selects one CRC implementation at elaboration.
  // Parameter values: 0 to 4; default is 2.
  // Parameter unit: none
  parameter logic [31:0] PARA_CRC_METHOD = 32'd2,
  // Parameter Description: Width of the CRC state and result.
  // Parameter values: Legal range is 2 to 32; default is 8.
  // Parameter unit: bit
  parameter logic [31:0] PARA_CRC_W = 32'd8,
  // Parameter Description: Input data width; method 0 requires one bit.
  // Parameter values: 1, or 8 to 256 in multiples of 8; default is 32.
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
  // Parameter Description: Chunk width used only by method 3.
  // Parameter values: 2 to 32; must equal CRC_W for method 3; default is 8.
  // Parameter unit: bit
  parameter logic [31:0] PARA_CAL_W = 32'd8,
  localparam logic [31:0] LPARA_METHOD_MIN = 32'd0,
  localparam logic [31:0] LPARA_METHOD_MAX = 32'd4,
  localparam logic [31:0] LPARA_METHOD_SERIAL_BIT = 32'd0,
  localparam logic [31:0] LPARA_METHOD_CHUNKED = 32'd3,
  localparam logic [31:0] LPARA_METHOD_REFLECTED = 32'd4,
  localparam logic [31:0] LPARA_CRC_W_MIN = 32'd2,
  localparam logic [31:0] LPARA_CRC_W_MAX = 32'd32,
  localparam logic [31:0] LPARA_CRC_W_DFLT = 32'd8,
  localparam logic [31:0] LPARA_DATA_W_MIN = 32'd8,
  localparam logic [31:0] LPARA_DATA_W_MAX = 32'd256,
  localparam logic [31:0] LPARA_CAL_W_MIN = 32'd2,
  localparam logic [31:0] LPARA_CAL_W_MAX = 32'd32,
  localparam logic [31:0] LPARA_DATA_W_DFLT = 32'd8,
  localparam logic [31:0] LPARA_CAL_W_DFLT = 32'd8,
  localparam logic [31:0] LPARA_BITS_PER_BYTE = 32'd8,
  localparam logic [31:0] LPARA_CRC_W =
    ((PARA_CRC_W >= LPARA_CRC_W_MIN) && (PARA_CRC_W <= LPARA_CRC_W_MAX)) ?
      PARA_CRC_W : LPARA_CRC_W_DFLT,
  localparam logic [31:0] LPARA_DATA_W =
    ((PARA_DATA_W >= 32'd1) && (PARA_DATA_W <= LPARA_DATA_W_MAX)) ?
      PARA_DATA_W : LPARA_DATA_W_DFLT,
  localparam logic [31:0] LPARA_KEEP_W =
    (LPARA_DATA_W + LPARA_BITS_PER_BYTE - 32'd1) / LPARA_BITS_PER_BYTE,
  localparam logic [31:0] LPARA_CAL_W =
    ((PARA_CAL_W >= LPARA_CAL_W_MIN) && (PARA_CAL_W <= LPARA_CAL_W_MAX)) ?
      PARA_CAL_W : LPARA_CAL_W_DFLT,
  localparam logic [31:0] LPARA_PARAM_VALID =
    ((PARA_CRC_METHOD >= LPARA_METHOD_MIN) &&
     (PARA_CRC_METHOD <= LPARA_METHOD_MAX) &&
     (PARA_CRC_W >= LPARA_CRC_W_MIN) && (PARA_CRC_W <= LPARA_CRC_W_MAX) &&
     ((PARA_DATA_W == 32'd1) ||
      ((PARA_DATA_W >= LPARA_DATA_W_MIN) &&
       (PARA_DATA_W <= LPARA_DATA_W_MAX) &&
       ((PARA_DATA_W % LPARA_BITS_PER_BYTE) == 32'd0))) &&
     (PARA_CRC_POLY != 32'd0) && (PARA_CRC_POLY[0] == 1'b1) &&
     ((PARA_CRC_POLY >> LPARA_CRC_W) == 32'd0) &&
     ((PARA_CRC_INIT >> LPARA_CRC_W) == 32'd0) &&
     ((PARA_CRC_XOR_OUT >> LPARA_CRC_W) == 32'd0) &&
     (PARA_CRC_REF_IN <= 32'd1) && (PARA_CRC_REF_OUT <= 32'd1) &&
     (PARA_CAL_W >= LPARA_CAL_W_MIN) && (PARA_CAL_W <= LPARA_CAL_W_MAX) &&
     (((PARA_CRC_METHOD == LPARA_METHOD_SERIAL_BIT) &&
       (PARA_DATA_W == 32'd1)) ||
      ((PARA_CRC_METHOD != LPARA_METHOD_SERIAL_BIT) &&
       (PARA_DATA_W >= LPARA_DATA_W_MIN) &&
       (PARA_DATA_W <= LPARA_DATA_W_MAX) &&
       ((PARA_DATA_W % LPARA_BITS_PER_BYTE) == 32'd0))) &&
     ((PARA_CRC_METHOD != LPARA_METHOD_CHUNKED) ||
      ((PARA_CAL_W == PARA_CRC_W) && (PARA_DATA_W >= LPARA_CAL_W) &&
       ((PARA_DATA_W % LPARA_CAL_W) == 32'd0))) &&
     ((PARA_CRC_METHOD != LPARA_METHOD_REFLECTED) ||
      (PARA_DATA_W >= PARA_CRC_W))) ? 32'd1 : 32'd0
) (
  // Clock and synchronous reset
  input  wire                     i_clk_crc,
  input  wire                     i_rst_n_crc,

  // Generator input stream
  input  wire  [LPARA_DATA_W-1:0] i_gen_data,
  input  wire  [LPARA_KEEP_W-1:0] i_gen_keep,
  input  wire                     i_gen_valid,
  input  wire                     i_gen_last,
  output logic                    o_gen_data_ready,

  // Generator CRC result
  output logic [LPARA_CRC_W-1:0]  o_gen_crc,
  output logic                    o_gen_crc_valid,
  input  wire                     i_gen_crc_ready,

  // Checker input stream and reference CRC
  input  wire  [LPARA_DATA_W-1:0] i_check_data,
  input  wire  [LPARA_KEEP_W-1:0] i_check_keep,
  input  wire                     i_check_valid,
  input  wire                     i_check_last,
  input  wire  [LPARA_CRC_W-1:0]  i_check_crc,
  output logic                    o_check_data_ready,

  // Checker pass/fail result
  output logic                    o_check_pass,
  output logic                    o_check_crc_valid,
  input  wire                     i_check_crc_ready);

  // Instantiate the generator only for a legal, elaboration-selected configuration.
  generate
    if (LPARA_PARAM_VALID == 32'd1) begin : gen_valid_config
      m_crc_gen #(
        .PARA_CRC_METHOD (PARA_CRC_METHOD),
        .PARA_CRC_W      (PARA_CRC_W),
        .PARA_DATA_W     (PARA_DATA_W),
        .PARA_CRC_POLY   (PARA_CRC_POLY),
        .PARA_CRC_INIT   (PARA_CRC_INIT),
        .PARA_CRC_XOR_OUT(PARA_CRC_XOR_OUT),
        .PARA_CRC_REF_IN (PARA_CRC_REF_IN),
        .PARA_CRC_REF_OUT(PARA_CRC_REF_OUT),
        .PARA_CAL_W      (PARA_CAL_W)
      ) u_crc_gen (
        .i_clk_crc    (i_clk_crc),
        .i_rst_n_crc  (i_rst_n_crc),
        .i_data       (i_gen_data),
        .i_keep       (i_gen_keep),
        .i_valid      (i_gen_valid),
        .i_last       (i_gen_last),
        .o_data_ready (o_gen_data_ready),
        .o_crc        (o_gen_crc),
        .o_crc_valid  (o_gen_crc_valid),
        .i_crc_ready  (i_gen_crc_ready)
      );

      // The checker owns separate frame state and method logic from the generator.
      m_crc_check #(
        .PARA_CRC_METHOD (PARA_CRC_METHOD),
        .PARA_CRC_W      (PARA_CRC_W),
        .PARA_DATA_W     (PARA_DATA_W),
        .PARA_CRC_POLY   (PARA_CRC_POLY),
        .PARA_CRC_INIT   (PARA_CRC_INIT),
        .PARA_CRC_XOR_OUT(PARA_CRC_XOR_OUT),
        .PARA_CRC_REF_IN (PARA_CRC_REF_IN),
        .PARA_CRC_REF_OUT(PARA_CRC_REF_OUT),
        .PARA_CAL_W      (PARA_CAL_W)
      ) u_crc_check (
        .i_clk_crc        (i_clk_crc),
        .i_rst_n_crc      (i_rst_n_crc),
        .i_data           (i_check_data),
        .i_keep           (i_check_keep),
        .i_valid          (i_check_valid),
        .i_last           (i_check_last),
        .i_check_crc      (i_check_crc),
        .o_data_ready     (o_check_data_ready),
        .o_check_pass     (o_check_pass),
        .o_check_crc_valid(o_check_crc_valid),
        .i_check_crc_ready(i_check_crc_ready)
      );
    end else begin : gen_invalid_config
      m_crc_invalid_config u_invalid_config ();
    end
  endgenerate

endmodule
