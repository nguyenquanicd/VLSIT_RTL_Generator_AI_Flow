/*
 * Project      : VLSIT Common RTL library
 * Author       : Nguyen Quan and Claude Sonnet 5.5 (user)
 * AI Flow      : VLSIT RTL Generator AI Automation Flow
 * AI Flow Page : https://github.com/nguyenquanicd/VLSIT_RTL_Generator_AI_Model
 * Date         : 2026-10-28
 * Description  : Register slice of one valid-ready channel of the AXI upsizer (REQ-RTL-002,
 *                DEC-012). It has an output register and a skid register, and its ready output is a
 *                register, so no output depends on an input in the same cycle (REQ-IF-003). A beat
 *                accepted at a rising edge (i_valid and o_ready) is on the output from the next
 *                cycle (one cycle of latency); when the next stage is not ready the beat goes into
 *                the skid register and o_ready falls in the next cycle, so no throughput is lost.
 *                In reset o_valid and o_ready are 0, and o_ready stays 0 in the first cycle after
 *                the release (REQ-IF-004). The payload registers have no reset and are read only
 *                while o_valid is 1 (SEQ-04).
 */
`timescale 1ns/1ps

module m_vlsit_ups_slice #(
  // Parameter Description: width of the payload that the slice carries.
  // Parameter values: 1 or more; default is 32.
  // Parameter unit: bit
  parameter logic [31:0] PARA_SLICE_W = 32
) (
  // Clock and reset
  input  wire                     i_clk_axi,
  input  wire                     i_rst_n_axi,

  // Input side
  input  wire                     i_valid,
  input  wire  [PARA_SLICE_W-1:0] i_data,
  output logic                    o_ready,

  // Output side
  output logic                    o_valid,
  output logic [PARA_SLICE_W-1:0] o_data,
  input  wire                     i_ready
);
  // Internal signal declarations
  logic                    reg_out_valid;
  logic [PARA_SLICE_W-1:0] reg_out_data;
  logic                    reg_skid_valid;
  logic [PARA_SLICE_W-1:0] reg_skid_data;
  logic                    reg_ready;
  logic                    w_consumed;
  logic                    w_accept;
  logic                    w_load_out_skid;
  logic                    w_load_out_in;
  logic                    w_load_skid;
  logic                    w_out_valid_nxt;
  logic                    w_skid_valid_nxt;
  logic [PARA_SLICE_W-1:0] w_out_data_nxt;
  logic [PARA_SLICE_W-1:0] w_skid_data_nxt;

  // Output mapping: every output is a register.
  assign o_ready = reg_ready;
  assign o_valid = reg_out_valid;
  assign o_data  = reg_out_data;

  // Handshake decode: the output beat is consumed when the next stage is ready; a beat is accepted
  // when the input is valid and the registered ready is 1.
  assign w_consumed = reg_out_valid & i_ready;
  assign w_accept   = i_valid & reg_ready;

  // Load decode: the skid beat moves to the output when the output is consumed; a new beat goes
  // to the output when the skid register is empty and the output is free or consumed; otherwise
  // it goes to the skid register.
  assign w_load_out_skid = reg_skid_valid & w_consumed;
  assign w_load_out_in   = ~reg_skid_valid & w_accept & (~reg_out_valid | w_consumed);
  assign w_load_skid     = ~reg_skid_valid & w_accept & reg_out_valid & ~w_consumed;

  // Next valid state of the output and the skid register.
  assign w_out_valid_nxt  = reg_skid_valid | w_accept | (reg_out_valid & ~w_consumed);
  assign w_skid_valid_nxt = (reg_skid_valid & ~w_consumed) | w_load_skid;

  // Next payload of the output register and of the skid register; each holds when not loaded.
  always_comb begin : p_com_out_data
    w_out_data_nxt = reg_out_data;
    case ({w_load_out_skid, w_load_out_in})
      2'b10:   w_out_data_nxt = reg_skid_data;
      2'b01:   w_out_data_nxt = i_data;
      default: w_out_data_nxt = reg_out_data;
    endcase
  end

  // Skid register payload: loaded with the input beat only when the output cannot take it.
  always_comb begin : p_com_skid_data
    w_skid_data_nxt = reg_skid_data;
    if (w_load_skid)
      w_skid_data_nxt = i_data;
  end

  // Control state: valid flags and the registered ready, reset to 0 asynchronously.
  always_ff @(posedge i_clk_axi, negedge i_rst_n_axi) begin : p_ff_ctrl
    if (!i_rst_n_axi) begin
      reg_out_valid  <= 1'b0;
      reg_skid_valid <= 1'b0;
      reg_ready      <= 1'b0;
    end else begin
      reg_out_valid  <= w_out_valid_nxt;
      reg_skid_valid <= w_skid_valid_nxt;
      reg_ready      <= ~w_skid_valid_nxt;
    end
  end

  // Payload registers, resetless: consumed only while the valid flags are 1.
  always_ff @(posedge i_clk_axi) begin : p_ff_payload
    reg_out_data  <= w_out_data_nxt;
    reg_skid_data <= w_skid_data_nxt;
  end

endmodule
