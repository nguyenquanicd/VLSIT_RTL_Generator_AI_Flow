/*
 * Project      : QSPI_Controller
 * Author       : Nguyen Quan (user)
 * AI Flow      : VLSIT RTL Generator AI Automation Flow
 * AI Flow Page : https://github.com/nguyenquanicd/VLSIT_RTL_Generator_AI_Model
 * Date         : 2026-11-03
 * Description  : Structural CDC wrapper for APB indirect commands, AXI XIP requests/responses,
 *                and their bundled status/data paths.
 */
`timescale 1ns/1ps

module m_qspi_cdc #(
  // Parameter Description: AXI address width for the XIP request bundle.
  // Parameter values: 32 through 64; default is 32.
  // Parameter unit: bit
  parameter logic [31:0] PARA_AXI_ADDR_W = 32'd32,
  // Parameter Description: AXI ID width for the XIP request bundle.
  // Parameter values: 1 through 16; default is 1.
  // Parameter unit: bit
  parameter logic [31:0] PARA_AXI_ID_W = 32'd1,
  // Parameter Description: asynchronous FIFO depth for XIP response words.
  // Parameter values: power of two, 2 or greater; default is 16.
  // Parameter unit: count
  parameter logic [31:0] PARA_FIFO_DEPTH = 32'd16,
  localparam logic [31:0] LPARA_CMD_DATA_W = 32'd130,
  localparam logic [31:0] LPARA_RSP_DATA_W = 32'd2,
  localparam logic [31:0] LPARA_XIP_CMD_W = 32'd130,
  localparam logic [31:0] LPARA_XIP_META_W = PARA_AXI_ADDR_W + 32'd8 + 32'd3 + PARA_AXI_ID_W,
  localparam logic [31:0] LPARA_XIP_REQ_DATA_W = LPARA_XIP_CMD_W + LPARA_XIP_META_W,
  localparam logic [31:0] LPARA_XIP_RSP_DATA_W = 32'd36
) (
  // Domain clocks and synchronized resets
  input  wire                             i_clk_apb,
  input  wire                             i_rst_n_apb,
  input  wire                             i_clk_axi,
  input  wire                             i_rst_n_axi,
  input  wire                             i_clk_serial,
  input  wire                             i_rst_n_serial,

  // Indirect command APB-to-serial request mailbox
  input  wire                             i_ind_cmd_valid_apb,
  output logic                            o_ind_cmd_ready_apb,
  input  wire  [LPARA_CMD_DATA_W-1:0]     i_ind_cmd_data_apb,
  output logic                            o_ind_cmd_valid_serial,
  input  wire                             i_ind_cmd_ready_serial,
  output logic [LPARA_CMD_DATA_W-1:0]     o_ind_cmd_data_serial,

  // Indirect completion serial-to-APB response mailbox
  input  wire                             i_ind_rsp_valid_serial,
  output logic                            o_ind_rsp_ready_serial,
  input  wire  [LPARA_RSP_DATA_W-1:0]     i_ind_rsp_data_serial,
  output logic                            o_ind_rsp_valid_apb,
  input  wire                             i_ind_rsp_ready_apb,
  output logic [LPARA_RSP_DATA_W-1:0]     o_ind_rsp_data_apb,

  // XIP request AXI-to-serial mailbox
  input  wire                             i_xip_req_valid_axi,
  output logic                            o_xip_req_ready_axi,
  input  wire  [LPARA_XIP_REQ_DATA_W-1:0] i_xip_req_data_axi,
  output logic                            o_xip_req_valid_serial,
  input  wire                             i_xip_req_ready_serial,
  output logic [LPARA_XIP_REQ_DATA_W-1:0] o_xip_req_data_serial,

  // XIP response serial-to-AXI asynchronous FIFO
  input  wire                             i_xip_rsp_push_serial,
  input  wire  [LPARA_XIP_RSP_DATA_W-1:0] i_xip_rsp_data_serial,
  output logic                            o_xip_rsp_full_serial,
  input  wire                             i_xip_rsp_pop_axi,
  output logic [LPARA_XIP_RSP_DATA_W-1:0] o_xip_rsp_data_axi,
  output logic                            o_xip_rsp_empty_axi
);

  // APB indirect-command request bundle crosses into the serial domain atomically.
  m_qspi_mailbox #(
    .PARA_DATA_W (LPARA_CMD_DATA_W)
  ) u_indirect_cmd_mailbox (
    .i_clk_src   (i_clk_apb),
    .i_rst_n_src (i_rst_n_apb),
    .i_src_valid (i_ind_cmd_valid_apb),
    .o_src_ready (o_ind_cmd_ready_apb),
    .i_src_data  (i_ind_cmd_data_apb),
    .i_clk_dst   (i_clk_serial),
    .i_rst_n_dst (i_rst_n_serial),
    .o_dst_valid (o_ind_cmd_valid_serial),
    .i_dst_ready (i_ind_cmd_ready_serial),
    .o_dst_data  (o_ind_cmd_data_serial)
  );

  // Completion and error status cross back to the APB clock domain atomically.
  m_qspi_mailbox #(
    .PARA_DATA_W (LPARA_RSP_DATA_W)
  ) u_indirect_rsp_mailbox (
    .i_clk_src   (i_clk_serial),
    .i_rst_n_src (i_rst_n_serial),
    .i_src_valid (i_ind_rsp_valid_serial),
    .o_src_ready (o_ind_rsp_ready_serial),
    .i_src_data  (i_ind_rsp_data_serial),
    .i_clk_dst   (i_clk_apb),
    .i_rst_n_dst (i_rst_n_apb),
    .o_dst_valid (o_ind_rsp_valid_apb),
    .i_dst_ready (i_ind_rsp_ready_apb),
    .o_dst_data  (o_ind_rsp_data_apb)
  );

  // XIP request metadata and command snapshot cross from AXI to serial together.
  m_qspi_mailbox #(
    .PARA_DATA_W (LPARA_XIP_REQ_DATA_W)
  ) u_xip_req_mailbox (
    .i_clk_src   (i_clk_axi),
    .i_rst_n_src (i_rst_n_axi),
    .i_src_valid (i_xip_req_valid_axi),
    .o_src_ready (o_xip_req_ready_axi),
    .i_src_data  (i_xip_req_data_axi),
    .i_clk_dst   (i_clk_serial),
    .i_rst_n_dst (i_rst_n_serial),
    .o_dst_valid (o_xip_req_valid_serial),
    .i_dst_ready (i_xip_req_ready_serial),
    .o_dst_data  (o_xip_req_data_serial)
  );

  // XIP response words cross from serial RX into the AXI response packer.
  m_qspi_async_fifo #(
    .PARA_FIFO_DEPTH (PARA_FIFO_DEPTH),
    .PARA_FIFO_DATA_W(LPARA_XIP_RSP_DATA_W)
  ) u_xip_rsp_fifo (
    .i_clk_wr   (i_clk_serial),
    .i_rst_n_wr (i_rst_n_serial),
    .i_wr_en    (i_xip_rsp_push_serial),
    .i_wr_data  (i_xip_rsp_data_serial),
    .o_full     (o_xip_rsp_full_serial),
    .o_overflow (),
    .i_clk_rd   (i_clk_axi),
    .i_rst_n_rd (i_rst_n_axi),
    .i_rd_en    (i_xip_rsp_pop_axi),
    .o_rd_data  (o_xip_rsp_data_axi),
    .o_empty    (o_xip_rsp_empty_axi),
    .o_underflow()
  );

endmodule
