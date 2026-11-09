/*
 * Project      : QSPI_Controller
 * Author       : Nguyen Quan (user)
 * AI Flow      : VLSIT RTL Generator AI Automation Flow
 * AI Flow Page : https://github.com/nguyenquanicd/VLSIT_RTL_Generator_AI_Model
 * Date         : 2026-11-02
 * Description  : Serializes XIP and indirect requests onto the controller timing engine.
 *                A granted XIP request remains the owner until its full burst completes.
 */
`timescale 1ns/1ps

module m_qspi_arbiter #(
  // Parameter Description: controller command payload width.
  // Parameter values: 1 or greater; default is 130.
  // Parameter unit: bit
  parameter logic [31:0] PARA_CMD_DATA_W = 32'd130
) (
  // Controller clock and reset
  input  wire                        i_clk_serial,
  input  wire                        i_rst_n_serial,

  // Request sources
  input  wire                        i_target_active,
  input  wire                        i_xip_valid,
  output logic                       o_xip_ready,
  input  wire  [PARA_CMD_DATA_W-1:0] i_xip_data,
  input  wire                        i_indirect_valid,
  output logic                       o_indirect_ready,
  input  wire  [PARA_CMD_DATA_W-1:0] i_indirect_data,

  // Controller engine request and completion
  output logic                       o_cmd_valid,
  input  wire                        i_cmd_ready,
  input  wire                        i_cmd_done,
  input  wire                        i_cmd_err,
  output logic                       o_cmd_owner_xip,
  output logic [PARA_CMD_DATA_W-1:0] o_cmd_data,
  output logic                       o_busy,
  output logic                       o_done_xip,
  output logic                       o_done_indirect,
  output logic                       o_err_xip,
  output logic                       o_err_indirect
);

  logic [PARA_CMD_DATA_W-1:0] reg_cmd_data;
  logic reg_cmd_valid;
  logic reg_owner_xip;
  logic reg_active;
  logic reg_rr_xip_first;
  logic w_accept_xip;
  logic w_accept_indirect;

  // Grant one source according to the round-robin preference while the engine is free.
  always_comb begin : p_com_arb_gnt
    w_accept_xip = 1'b0;
    w_accept_indirect = 1'b0;
    o_xip_ready = 1'b0;
    o_indirect_ready = 1'b0;
    if (!i_target_active && !reg_cmd_valid && !reg_active) begin
      if (reg_rr_xip_first) begin
        if (i_xip_valid) begin
          w_accept_xip = 1'b1;
          o_xip_ready = 1'b1;
        end else if (i_indirect_valid) begin
          w_accept_indirect = 1'b1;
          o_indirect_ready = 1'b1;
        end
      end else begin
        if (i_indirect_valid) begin
          w_accept_indirect = 1'b1;
          o_indirect_ready = 1'b1;
        end else if (i_xip_valid) begin
          w_accept_xip = 1'b1;
          o_xip_ready = 1'b1;
        end
      end
    end
  end

  // Hold the command payload and owner until the engine accepts and completes the operation.
  always_ff @(posedge i_clk_serial, negedge i_rst_n_serial) begin : p_ff_arb
    if (!i_rst_n_serial) begin
      reg_cmd_data <= '0;
      reg_cmd_valid <= 1'b0;
      reg_owner_xip <= 1'b0;
      reg_active <= 1'b0;
      reg_rr_xip_first <= 1'b1;
    end else begin
      if (w_accept_xip) begin
        reg_cmd_data <= i_xip_data;
        reg_cmd_valid <= 1'b1;
        reg_owner_xip <= 1'b1;
      end else if (w_accept_indirect) begin
        reg_cmd_data <= i_indirect_data;
        reg_cmd_valid <= 1'b1;
        reg_owner_xip <= 1'b0;
      end
      if (reg_cmd_valid && i_cmd_ready) begin
        reg_cmd_valid <= 1'b0;
        reg_active <= 1'b1;
      end
      if (reg_active && (i_cmd_done || i_cmd_err)) begin
        reg_active <= 1'b0;
        reg_rr_xip_first <= !reg_owner_xip;
      end
    end
  end

  // Expose a stable command bundle and completion pulses for the selected owner.
  always_comb begin : p_com_arb_out
    o_cmd_valid = reg_cmd_valid;
    o_cmd_owner_xip = reg_owner_xip;
    o_cmd_data = reg_cmd_data;
    o_busy = reg_cmd_valid || reg_active;
    o_done_xip = reg_active && i_cmd_done && reg_owner_xip;
    o_done_indirect = reg_active && i_cmd_done && !reg_owner_xip;
    o_err_xip = reg_active && i_cmd_err && reg_owner_xip;
    o_err_indirect = reg_active && i_cmd_err && !reg_owner_xip;
  end

endmodule
