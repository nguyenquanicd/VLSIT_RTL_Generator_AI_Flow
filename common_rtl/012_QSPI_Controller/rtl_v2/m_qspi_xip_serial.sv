/*
 * Project      : QSPI_Controller
 * Author       : Nguyen Quan (user)
 * AI Flow      : VLSIT RTL Generator AI Automation Flow
 * AI Flow Page : https://github.com/nguyenquanicd/VLSIT_RTL_Generator_AI_Model
 * Date         : 2026-11-03
 * Description  : Accepts one XIP burst command, arbitrates it as a controller request, and routes
 *                returned serial words into an asynchronous AXI-response FIFO.
 */
`timescale 1ns/1ps

module m_qspi_xip_serial #(
  // Parameter Description: AXI address width used in the CDC request bundle.
  // Parameter values: 32 through 64; default is 32.
  // Parameter unit: bit
  parameter logic [31:0] PARA_AXI_ADDR_W = 32'd32,
  // Parameter Description: AXI ID width used in the CDC request bundle.
  // Parameter values: 1 through 16; default is 1.
  // Parameter unit: bit
  parameter logic [31:0] PARA_AXI_ID_W = 32'd1,
  localparam logic [31:0] LPARA_CMD_DATA_W = 32'd130,
  localparam logic [31:0] LPARA_REQ_LEN_W = 32'd8,
  localparam logic [31:0] LPARA_REQ_SIZE_W = 32'd3,
  localparam logic [31:0] LPARA_REQ_ADDR_LSB = LPARA_CMD_DATA_W,
  localparam logic [31:0] LPARA_REQ_LEN_LSB = LPARA_REQ_ADDR_LSB + PARA_AXI_ADDR_W,
  localparam logic [31:0] LPARA_REQ_SIZE_LSB = LPARA_REQ_LEN_LSB + LPARA_REQ_LEN_W,
  localparam logic [31:0] LPARA_REQ_ID_LSB = LPARA_REQ_SIZE_LSB + LPARA_REQ_SIZE_W,
  localparam logic [31:0] LPARA_REQ_DATA_W = LPARA_REQ_ID_LSB + PARA_AXI_ID_W,
  localparam logic [31:0] LPARA_BYTES_PER_WORD = 32'd4,
  localparam logic [31:0] LPARA_RSP_DATA_W = 32'd36
) (
  // Controller clock and reset
  input  wire                         i_clk_serial,
  input  wire                         i_rst_n_serial,

  // XIP request received from the AXI-domain mailbox
  input  wire                         i_req_valid,
  output logic                        o_req_ready,
  input  wire  [LPARA_REQ_DATA_W-1:0] i_req_data,

  // XIP request accepted by the serial-domain arbiter
  output logic                        o_xip_cmd_valid,
  input  wire                         i_xip_cmd_ready,
  output logic [LPARA_CMD_DATA_W-1:0] o_xip_cmd_data,
  input  wire                         i_xip_cmd_done,
  input  wire                         i_xip_cmd_err,

  // Controller RX stream and AXI-response FIFO write side
  input  wire                         i_engine_rx_push,
  input  wire  [31:0]                 i_engine_rx_data,
  input  wire                         i_rsp_fifo_full,
  output logic                        o_engine_rx_full,
  output logic                        o_rsp_fifo_push,
  output logic [LPARA_RSP_DATA_W-1:0] o_rsp_fifo_data
);

  logic reg_xip_active;
  logic [16:0] reg_bytes_left;
  logic reg_err_marker_pending;
  logic [16:0] w_req_total_bytes;
  logic [2:0] w_rsp_word_bytes;
  logic w_req_accept;
  logic w_rx_word_accept;
  logic w_err_marker_accept;

  // Decode burst metadata and calculate its serial byte count.
  always_comb begin : p_com_xip_req
    w_req_total_bytes = ({9'd0, i_req_data[LPARA_REQ_LEN_LSB +: LPARA_REQ_LEN_W]} + 17'd1) <<
                        i_req_data[LPARA_REQ_SIZE_LSB +: LPARA_REQ_SIZE_W];
    o_xip_cmd_valid = i_req_valid && !reg_xip_active;
    o_xip_cmd_data = i_req_data[LPARA_CMD_DATA_W-1:0];
    o_req_ready = !reg_xip_active && i_xip_cmd_ready;
    w_req_accept = i_req_valid && o_req_ready;
    w_rsp_word_bytes = (reg_bytes_left >= LPARA_BYTES_PER_WORD[16:0]) ?
                       LPARA_BYTES_PER_WORD[2:0] : reg_bytes_left[2:0];
    w_rx_word_accept = reg_xip_active && i_engine_rx_push && !i_rsp_fifo_full;
    w_err_marker_accept = reg_err_marker_pending && !i_rsp_fifo_full &&
                          !i_engine_rx_push;
    o_rsp_fifo_push = w_rx_word_accept || w_err_marker_accept;
    o_rsp_fifo_data = {1'b0, w_rsp_word_bytes, i_engine_rx_data};
    if (w_err_marker_accept)
      o_rsp_fifo_data = {1'b1, 3'd0, 32'd0};
    o_engine_rx_full = reg_xip_active && i_rsp_fifo_full;
  end

  // Hold burst byte count and emit one error marker if serial execution aborts early.
  always_ff @(posedge i_clk_serial, negedge i_rst_n_serial) begin : p_ff_xip_serial
    if (!i_rst_n_serial) begin
      reg_xip_active <= 1'b0;
      reg_bytes_left <= 17'd0;
      reg_err_marker_pending <= 1'b0;
    end else begin
      if (w_req_accept) begin
        reg_xip_active <= 1'b1;
        reg_bytes_left <= w_req_total_bytes;
        reg_err_marker_pending <= 1'b0;
      end
      if (w_rx_word_accept) begin
        if (reg_bytes_left > LPARA_BYTES_PER_WORD[16:0])
          reg_bytes_left <= reg_bytes_left - LPARA_BYTES_PER_WORD[16:0];
        else
          reg_bytes_left <= 17'd0;
      end
      if (w_err_marker_accept)
        reg_err_marker_pending <= 1'b0;
      if (reg_xip_active && (i_xip_cmd_err ||
          (i_xip_cmd_done && (reg_bytes_left != 17'd0)))) begin
        reg_xip_active <= 1'b0;
        reg_err_marker_pending <= 1'b1;
      end else if (reg_xip_active && i_xip_cmd_done) begin
        reg_xip_active <= 1'b0;
      end
      if (reg_xip_active && i_xip_cmd_err)
        reg_xip_active <= 1'b0;
    end
  end

endmodule
