/*
 * Project      : VLSI Technology - AI RTL generator
 * Author       : Nguyen Quan and Claude (user)
 * AI Flow      : VLSIT RTL Generator AI Automation Flow
 * AI Flow Page : https://github.com/nguyenquanicd/VLSIT_RTL_Generator_AI_Model
 * Date         : 2026-10-18
 * Description  : TL-UL host side of the APB to TL-UL bridge. Loads channel A from flip-flops at the
 *                launch edge, holds it until accepted, accepts the response and checks it.
 */
`timescale 1ns/1ps

module m_tlul_if #(
  // Parameter Description: width of the channel A byte address; its two low bits are always zero.
  // Parameter values: legal range is 16 to 32; default is 32.
  // Parameter unit: bit
  parameter logic [31:0] PARA_ADDR_W = 32,
  // Parameter Description: width of the TL-UL source identifier on channels A and D.
  // Parameter values: legal range is 1 to 8; default is 8.
  // Parameter unit: bit
  parameter logic [31:0] PARA_SRC_W = 8,
  // Parameter Description: constant source identifier of every request; it fits PARA_SRC_W bits.
  // Parameter values: 0 to 2^PARA_SRC_W - 1; default is 0.
  // Parameter unit: none
  parameter logic [31:0] PARA_SRC_ID = '0,
  // Parameter Description: width of the a_user bits, which are always driven to zero.
  // Parameter values: legal range is 1 to 32; default is 1.
  // Parameter unit: bit
  parameter logic [31:0] PARA_A_USER_W = 1,
  // Request size code 2 means a 4-byte access (a_size = 2'b10).
  localparam logic [31:0] LPARA_A_SIZE = 32'd2,
  // Request mask 4'b1111: every byte lane of the 32-bit bus is active.
  localparam logic [31:0] LPARA_A_MASK = 32'd15,
  // d_opcode of AccessAckData, the expected response of a Get request.
  localparam logic [31:0] LPARA_D_ACK_DATA = 32'd1
) (
  // Clock and reset
  input  wire                      i_clk_core,
  input  wire                      i_rst_n_core,

  // Bridge request interface
  input  wire                      i_req_launch,
  input  wire                      i_req_wr,
  input  wire  [PARA_ADDR_W-3:0]   i_req_addr,
  input  wire  [31:0]              i_req_wdata,

  // TL-UL channel A
  output logic                     o_tlul_a_valid,
  output logic [2:0]               o_tlul_a_opcode,
  output logic [2:0]               o_tlul_a_param,
  output logic [1:0]               o_tlul_a_size,
  output logic [PARA_SRC_W-1:0]    o_tlul_a_source,
  output logic [PARA_ADDR_W-1:0]   o_tlul_a_address,
  output logic [3:0]               o_tlul_a_mask,
  output logic [31:0]              o_tlul_a_data,
  output logic [PARA_A_USER_W-1:0] o_tlul_a_user,
  input  wire                      i_tlul_a_ready,

  // TL-UL channel D
  input  wire                      i_tlul_d_valid,
  input  wire                      i_tlul_d_error,
  input  wire  [2:0]               i_tlul_d_opcode,
  input  wire  [PARA_SRC_W-1:0]    i_tlul_d_source,
  input  wire  [31:0]              i_tlul_d_data,
  output logic                     o_tlul_d_ready,

  // Bridge response interface
  output logic                     o_resp_valid,
  output logic                     o_resp_err,
  output logic [31:0]              o_resp_rdata
);

  // TL-UL FSM states: IDLE has no request outstanding, REQ presents channel A until it is accepted,
  // and WAIT waits for the response. Unused encoding 2'b11 recovers to ENUM_ST_IDLE.
  typedef enum logic [1:0] {
    ENUM_ST_IDLE = 2'b00,
    ENUM_ST_REQ  = 2'b01,
    ENUM_ST_WAIT = 2'b10
  } tlul_state_type_def;

  // Internal signal declarations
  tlul_state_type_def reg_fsm_tlul_current_state;
  tlul_state_type_def w_fsm_tlul_nxt_state;
  logic reg_a_valid;
  logic reg_d_ready;
  logic reg_a_rd;
  logic [PARA_ADDR_W-3:0] reg_a_addr;
  logic [31:0] reg_a_data;
  logic w_load;
  logic w_resp_hit;
  logic w_resp_err;
  logic w_a_valid_nxt;
  logic w_a_rd_nxt;
  logic [PARA_ADDR_W-3:0] w_a_addr_nxt;
  logic [31:0] w_a_data_nxt;
  logic [2:0] w_exp_opcode;

  // Launch: the APB side presents a legal request while no request is outstanding.
  assign w_load = i_req_launch & (reg_fsm_tlul_current_state == ENUM_ST_IDLE);

  // A response counts only for an accepted request: in WAIT, or in REQ in the cycle of acceptance.
  // A d_valid at any other time is an orphan response and is discarded.
  assign w_resp_hit = i_tlul_d_valid & reg_d_ready &
                      (((reg_fsm_tlul_current_state == ENUM_ST_REQ) & i_tlul_a_ready) |
                       (reg_fsm_tlul_current_state == ENUM_ST_WAIT));

  // Response check: a Get expects AccessAckData and a write expects AccessAck; d_source must echo
  // the constant source identifier; d_error is an error response. Any failure gives an error.
  assign w_exp_opcode = reg_a_rd ? LPARA_D_ACK_DATA[2:0] : '0;
  assign w_resp_err   = i_tlul_d_error | (i_tlul_d_opcode != w_exp_opcode) |
                        (i_tlul_d_source != PARA_SRC_ID[PARA_SRC_W-1:0]);

  // Response bundle for the APB side: read data only for an error-free read, zero otherwise.
  assign o_resp_valid = w_resp_hit;
  assign o_resp_err   = w_resp_err;
  assign o_resp_rdata = (reg_a_rd & ~w_resp_err) ? i_tlul_d_data : '0;

  // Channel A outputs: valid, opcode bit 2 (1 = Get), address and data come from flip-flops.
  assign o_tlul_a_valid   = reg_a_valid;
  assign o_tlul_a_opcode  = {reg_a_rd, 2'b00};
  assign o_tlul_a_address = {reg_a_addr, 2'b00};
  assign o_tlul_a_data    = reg_a_data;
  assign o_tlul_d_ready   = reg_d_ready;

  // Constant channel A fields are tie-offs: they never change, so they need no flip-flop.
  assign o_tlul_a_param  = '0;
  assign o_tlul_a_size   = LPARA_A_SIZE[1:0];
  assign o_tlul_a_mask   = LPARA_A_MASK[3:0];
  assign o_tlul_a_source = PARA_SRC_ID[PARA_SRC_W-1:0];
  assign o_tlul_a_user   = '0;

  // Next-state logic: IDLE moves to REQ on a launch; REQ leaves when channel A is accepted, going
  // to IDLE if the response arrives in the same cycle and to WAIT otherwise; WAIT leaves on the
  // response. The next state is assigned first (COM-02) and every case has a default (COM-03),
  // so no latch is inferred (COM-07).
  always_comb begin : p_com_fsm_nxt
    w_fsm_tlul_nxt_state = reg_fsm_tlul_current_state;
    case (reg_fsm_tlul_current_state)
      ENUM_ST_IDLE: begin
        if (w_load)
          w_fsm_tlul_nxt_state = ENUM_ST_REQ;
      end
      ENUM_ST_REQ: begin
        if (i_tlul_a_ready) begin
          if (w_resp_hit)
            w_fsm_tlul_nxt_state = ENUM_ST_IDLE;
          else
            w_fsm_tlul_nxt_state = ENUM_ST_WAIT;
        end
      end
      ENUM_ST_WAIT: begin
        if (w_resp_hit)
          w_fsm_tlul_nxt_state = ENUM_ST_IDLE;
      end
      default: w_fsm_tlul_nxt_state = ENUM_ST_IDLE;
    endcase
  end

  // Channel A control and payload values: the request loads at the launch edge and then holds, so
  // channel A is stable while o_tlul_a_valid is high and i_tlul_a_ready is low. Every next value
  // has its default first (COM-02), so no latch is inferred (COM-07).
  always_comb begin : p_com_chan_a
    w_a_valid_nxt   = (w_fsm_tlul_nxt_state == ENUM_ST_REQ);
    w_a_rd_nxt      = reg_a_rd;
    w_a_addr_nxt = reg_a_addr;
    w_a_data_nxt    = reg_a_data;
    if (w_load) begin
      w_a_rd_nxt      = ~i_req_wr;
      w_a_addr_nxt = i_req_addr;
      w_a_data_nxt    = i_req_wdata;
    end
  end

  // Current-state register: the control state is reset asynchronously to IDLE and otherwise takes
  // the next state every clock cycle.
  always_ff @(posedge i_clk_core, negedge i_rst_n_core) begin : p_ff_fsm_tlul
    if (!i_rst_n_core)
      reg_fsm_tlul_current_state <= ENUM_ST_IDLE;
    else
      reg_fsm_tlul_current_state <= w_fsm_tlul_nxt_state;
  end

  // Channel flip-flops: the A-channel valid and the D-channel ready. Both are reset asynchronously
  // to zero; reg_d_ready then becomes 1 at the first clock edge after reset release.
  always_ff @(posedge i_clk_core, negedge i_rst_n_core) begin : p_ff_chan_ctrl
    if (!i_rst_n_core) begin
      reg_a_valid <= 1'b0;
      reg_d_ready <= 1'b0;
    end else begin
      reg_a_valid <= w_a_valid_nxt;
      reg_d_ready <= 1'b1;
    end
  end

  // Payload flip-flops: direction, address and data of the request. They are also reset to zero so
  // the channel A outputs are defined after reset; the device ignores them while a_valid is low.
  always_ff @(posedge i_clk_core, negedge i_rst_n_core) begin : p_ff_payload
    if (!i_rst_n_core) begin
      reg_a_rd   <= 1'b0;
      reg_a_addr <= '0;
      reg_a_data <= '0;
    end else begin
      reg_a_rd   <= w_a_rd_nxt;
      reg_a_addr <= w_a_addr_nxt;
      reg_a_data <= w_a_data_nxt;
    end
  end

endmodule
