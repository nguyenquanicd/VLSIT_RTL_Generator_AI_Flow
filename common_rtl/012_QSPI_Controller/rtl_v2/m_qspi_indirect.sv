/*
 * Project      : QSPI_Controller
 * Author       : Nguyen Quan (user)
 * AI Flow      : VLSIT RTL Generator AI Automation Flow
 * AI Flow Page : https://github.com/nguyenquanicd/VLSIT_RTL_Generator_AI_Model
 * Date         : 2026-11-03
 * Description  : Captures APB indirect commands and transfers command/status bundles through
 *                request/acknowledge mailboxes between APB and controller-clock domains.
 */
`timescale 1ns/1ps

module m_qspi_indirect #(
  localparam logic [31:0] LPARA_CMD_DATA_W = 32'd130,
  localparam logic [31:0] LPARA_RSP_DATA_W = 32'd2
) (
  // APB command clock and reset
  input  wire                         i_clk_apb,
  input  wire                         i_rst_n_apb,

  // APB-visible command and configuration
  input  wire                         i_cmd_start,
  input  wire                         i_ctrl_en,
  input  wire                         i_ctrl_role,
  input  wire                         i_tgt_cs_active,
  input  wire                         i_ctrl_cpol,
  input  wire                         i_ctrl_cpha,
  input  wire                         i_ctrl_lsb_first,
  input  wire  [15:0]                 i_ctrl_divisor,
  input  wire  [7:0]                  i_cs_setup,
  input  wire  [7:0]                  i_cs_hold,
  input  wire  [7:0]                  i_cs_high,
  input  wire  [3:0]                  i_cs_sel,
  input  wire  [2:0]                  i_cmd_format,
  input  wire  [7:0]                  i_cmd_opcode,
  input  wire  [31:0]                 i_cmd_addr,
  input  wire  [1:0]                  i_cmd_addr_bytes,
  input  wire  [7:0]                  i_cmd_dummy_cycles,
  input  wire                         i_cmd_rd,
  input  wire  [15:0]                 i_cmd_byte_count,

  // Hardware clear for the APB start bit and APB status events
  output logic                        o_cmd_start_hw_we,
  output logic                        o_cmd_start_hw_data,
  output logic                        o_busy,
  output logic                        o_done_event,
  output logic                        o_err_event,

  // APB-side command mailbox interface
  output logic                        o_cmd_src_valid,
  input  wire                         i_cmd_src_ready,
  output logic [LPARA_CMD_DATA_W-1:0] o_cmd_src_data,

  // Serial-side response mailbox interface
  input  wire                         i_clk_serial,
  input  wire                         i_rst_n_serial,
  input  wire                         i_serial_cmd_done,
  input  wire                         i_serial_cmd_err,
  output logic                        o_rsp_src_valid,
  input  wire                         i_rsp_src_ready,
  output logic [LPARA_RSP_DATA_W-1:0] o_rsp_src_data,

  // APB-side response mailbox interface
  input  wire                         i_rsp_dst_valid,
  input  wire  [LPARA_RSP_DATA_W-1:0] i_rsp_dst_data,
  output logic                        o_rsp_dst_ready
);

  logic reg_start_seen;
  logic reg_cmd_pending;
  logic reg_busy_apb;
  logic reg_rsp_pending;
  logic reg_rsp_data;
  logic w_start_event;
  logic [LPARA_CMD_DATA_W-1:0] reg_cmd_data_apb;

  // Detect each software start once, even if the CSR clear returns one APB cycle later.
  always_comb begin : p_com_indirect_start
    w_start_event = i_cmd_start && !reg_start_seen;
    o_cmd_start_hw_we = i_cmd_start;
    o_cmd_start_hw_data = 1'b0;
  end

  // Snapshot one command and hold it until the serial mailbox accepts the request.
  always_ff @(posedge i_clk_apb, negedge i_rst_n_apb) begin : p_ff_indirect_apb
    if (!i_rst_n_apb) begin
      reg_start_seen <= 1'b0;
      reg_cmd_pending <= 1'b0;
      reg_busy_apb <= 1'b0;
      reg_cmd_data_apb <= '0;
    end else begin
      reg_start_seen <= i_cmd_start;
      if (!i_cmd_start)
        reg_start_seen <= 1'b0;
      if (reg_cmd_pending && i_cmd_src_ready)
        reg_cmd_pending <= 1'b0;
      if (w_start_event) begin
        if (!reg_busy_apb && !reg_cmd_pending && i_ctrl_en && !i_ctrl_role &&
            !i_tgt_cs_active) begin
          reg_cmd_data_apb <= {
            i_cmd_format,
            i_ctrl_cpol,
            i_ctrl_cpha,
            i_ctrl_lsb_first,
            i_ctrl_divisor,
            i_cs_setup,
            i_cs_hold,
            i_cs_high,
            i_cs_sel,
            i_cmd_opcode,
            i_cmd_addr,
            i_cmd_addr_bytes,
            8'd0,
            5'd0,
            i_cmd_dummy_cycles,
            i_cmd_rd,
            i_cmd_byte_count
          };
          reg_cmd_pending <= 1'b1;
          reg_busy_apb <= 1'b1;
        end
      end
      if (i_rsp_dst_valid && o_rsp_dst_ready)
        reg_busy_apb <= 1'b0;
    end
  end

  // Convert the one-bit command completion into a held cross-domain status response.
  always_ff @(posedge i_clk_serial, negedge i_rst_n_serial) begin : p_ff_indirect_rsp_src
    if (!i_rst_n_serial) begin
      reg_rsp_pending <= 1'b0;
      reg_rsp_data <= 1'b0;
    end else begin
      if (reg_rsp_pending && i_rsp_src_ready)
        reg_rsp_pending <= 1'b0;
      if (!reg_rsp_pending && (i_serial_cmd_done || i_serial_cmd_err)) begin
        reg_rsp_pending <= 1'b1;
        reg_rsp_data <= i_serial_cmd_err;
      end
    end
  end

  // APB reports completion or error only after the response mailbox crosses back.
  always_comb begin : p_com_indirect_sts
    o_busy = reg_busy_apb;
    o_done_event = i_rsp_dst_valid && !i_rsp_dst_data[1];
    o_err_event = (w_start_event && (reg_busy_apb || reg_cmd_pending || !i_ctrl_en ||
                  i_ctrl_role || i_tgt_cs_active)) ||
                  (i_rsp_dst_valid && i_rsp_dst_data[1]);
    o_cmd_src_valid = reg_cmd_pending;
    o_cmd_src_data = reg_cmd_data_apb;
    o_rsp_src_valid = reg_rsp_pending;
    o_rsp_src_data = {reg_rsp_data, 1'b0};
    o_rsp_dst_ready = 1'b1;
  end

endmodule

