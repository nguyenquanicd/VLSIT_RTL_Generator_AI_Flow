/*
 * Project      : QSPI_Controller
 * Author       : Nguyen Quan (user)
 * AI Flow      : VLSIT RTL Generator AI Automation Flow
 * AI Flow Page : https://github.com/nguyenquanicd/VLSIT_RTL_Generator_AI_Model
 * Date         : 2026-11-02
 * Description  : One-entry bundled-data request/acknowledge mailbox between unrelated clocks.
 *                The source holds the payload until the destination accepts it.
 */
`timescale 1ns/1ps

module m_qspi_mailbox #(
  // Parameter Description: number of payload bits carried by one mailbox transfer.
  // Parameter values: 1 or greater; default is 64.
  // Parameter unit: bit
  parameter logic [31:0] PARA_DATA_W = 32'd64
) (
  // Source clock and reset
  input  wire                    i_clk_src,
  input  wire                    i_rst_n_src,

  // Source request interface
  input  wire                    i_src_valid,
  output logic                   o_src_ready,
  input  wire  [PARA_DATA_W-1:0] i_src_data,

  // Destination clock and reset
  input  wire                    i_clk_dst,
  input  wire                    i_rst_n_dst,

  // Destination request interface
  output logic                   o_dst_valid,
  input  wire                    i_dst_ready,
  output logic [PARA_DATA_W-1:0] o_dst_data
);

  // Toggle synchronizers and bundled-data holding registers.
  logic reg_req_tgl_src;
  logic reg_ack_tgl_dst;
  logic reg_ack_sync_1;
  logic reg_ack_sync_2;
  logic reg_req_sync_1;
  logic reg_req_sync_2;
  logic [PARA_DATA_W-1:0] reg_src_data;
  logic [PARA_DATA_W-1:0] reg_dst_data;
  logic reg_dst_valid;

  // Source holds data stable until the synchronized acknowledgement returns.
  always_ff @(posedge i_clk_src, negedge i_rst_n_src) begin : p_ff_src_mailbox
    if (!i_rst_n_src) begin
      reg_req_tgl_src <= 1'b0;
      reg_ack_sync_1  <= 1'b0;
      reg_ack_sync_2  <= 1'b0;
      reg_src_data    <= '0;
    end else begin
      reg_ack_sync_1 <= reg_ack_tgl_dst;
      reg_ack_sync_2 <= reg_ack_sync_1;
      if (i_src_valid && o_src_ready) begin
        reg_src_data    <= i_src_data;
        reg_req_tgl_src <= ~reg_req_tgl_src;
      end
    end
  end

  // Destination captures the stable payload and acknowledges after acceptance.
  always_ff @(posedge i_clk_dst, negedge i_rst_n_dst) begin : p_ff_dst_mailbox
    if (!i_rst_n_dst) begin
      reg_req_sync_1 <= 1'b0;
      reg_req_sync_2 <= 1'b0;
      reg_ack_tgl_dst <= 1'b0;
      reg_dst_data <= '0;
      reg_dst_valid <= 1'b0;
    end else begin
      reg_req_sync_1 <= reg_req_tgl_src;
      reg_req_sync_2 <= reg_req_sync_1;
      if (!reg_dst_valid && (reg_req_sync_2 != reg_ack_tgl_dst)) begin
        reg_dst_data  <= reg_src_data;
        reg_dst_valid <= 1'b1;
      end else if (reg_dst_valid && i_dst_ready) begin
        reg_dst_valid <= 1'b0;
        reg_ack_tgl_dst <= reg_req_sync_2;
      end
    end
  end

  // Handshake outputs expose the held source and destination state.
  always_comb begin : p_com_mailbox_out
    o_src_ready = (reg_req_tgl_src == reg_ack_sync_2);
    o_dst_valid = reg_dst_valid;
    o_dst_data  = reg_dst_data;
  end

endmodule
