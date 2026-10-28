/*
 * Project      : VLSI Technology - AI RTL generator
 * Author       : Nguyen Quan and Claude (user)
 * AI Flow      : VLSIT RTL Generator AI Automation Flow
 * AI Flow Page : https://github.com/nguyenquanicd/VLSIT_RTL_Generator_AI_Model
 * Date         : 2026-10-18
 * Description  : APB4 completer side of the APB to TL-UL bridge. It detects the Setup phase and
 *                checks the request, launches it to the TL-UL side and returns the completion.
 */
`timescale 1ns/1ps

module m_apb_if #(
  // Parameter Description: width of the APB byte address; bits [1:0] are checked for alignment.
  // Parameter values: legal range is 16 to 32; default is 32.
  // Parameter unit: bit
  parameter logic [31:0] PARA_ADDR_W = 32
) (
  // Clock and reset
  input  wire                    i_clk_core,
  input  wire                    i_rst_n_core,

  // APB4 completer interface
  input  wire                    i_apb_psel,
  input  wire                    i_apb_penable,
  input  wire                    i_apb_pwrite,
  input  wire  [PARA_ADDR_W-1:0] i_apb_paddr,
  input  wire  [3:0]             i_apb_pstrb,
  input  wire  [31:0]            i_apb_pwdata,
  output logic                   o_apb_pready,
  output logic                   o_apb_pslverr,
  output logic [31:0]            o_apb_prdata,

  // TL-UL request interface
  output logic                   o_req_launch,
  output logic                   o_req_wr,
  output logic [PARA_ADDR_W-3:0] o_req_addr,
  output logic [31:0]            o_req_wdata,

  // TL-UL response interface
  input  wire                    i_resp_valid,
  input  wire                    i_resp_err,
  input  wire  [31:0]            i_resp_rdata
);

  // APB FSM states: IDLE waits for a Setup phase, BUSY waits for the TL-UL response, and DONE
  // holds PREADY for one cycle. Unused encoding 2'b11 recovers to ENUM_ST_IDLE.
  typedef enum logic [1:0] {
    ENUM_ST_IDLE = 2'b00,
    ENUM_ST_BUSY = 2'b01,
    ENUM_ST_DONE = 2'b10
  } apb_state_type_def;

  // Internal signal declarations
  apb_state_type_def reg_fsm_apb_current_state;
  apb_state_type_def w_fsm_apb_nxt_state;
  logic w_setup;
  logic w_legal;
  logic w_req_launch;
  logic w_local_err;
  logic w_pready_nxt;
  logic w_pslverr_nxt;
  logic [31:0] w_prdata_nxt;
  logic reg_pready;
  logic reg_pslverr;
  logic [31:0] reg_prdata;

  // Setup phase: the level PSEL = 1 with PENABLE = 0 while the FSM is idle, not an edge of PSEL, so
  // back-to-back transfers with PSEL held high start exactly like the first transfer.
  assign w_setup = (reg_fsm_apb_current_state == ENUM_ST_IDLE) & i_apb_psel & ~i_apb_penable;

  // Legal request: word-aligned address, and a full strobe when the access is a write.
  // PSTRB is ignored on reads, where the APB requester drives it LOW.
  assign w_legal = (i_apb_paddr[1:0] == 2'b00) & (~i_apb_pwrite | (i_apb_pstrb == 4'b1111));

  // A legal Setup phase launches the TL-UL request; an illegal one gets a local error answer.
  assign w_req_launch = w_setup & w_legal;
  assign w_local_err  = w_setup & ~w_legal;

  // Request bundle for the TL-UL side: forwarded straight from the APB inputs of the Setup cycle.
  assign o_req_launch = w_req_launch;
  assign o_req_wr     = i_apb_pwrite;
  assign o_req_addr   = i_apb_paddr[PARA_ADDR_W-1:2];
  assign o_req_wdata  = i_apb_pwdata;

  // Completion outputs come straight from flip-flops.
  assign o_apb_pready  = reg_pready;
  assign o_apb_pslverr = reg_pslverr;
  assign o_apb_prdata  = reg_prdata;

  // Next-state logic: IDLE moves to BUSY on a launch or to DONE on a local error, BUSY moves to
  // DONE when the response arrives, and DONE always returns to IDLE. The next state is assigned
  // first (COM-02) and every case has a default (COM-03), so no latch is inferred (COM-07).
  always_comb begin : p_com_fsm_nxt
    w_fsm_apb_nxt_state = reg_fsm_apb_current_state;
    case (reg_fsm_apb_current_state)
      ENUM_ST_IDLE: begin
        if (w_req_launch)
          w_fsm_apb_nxt_state = ENUM_ST_BUSY;
        else if (w_local_err)
          w_fsm_apb_nxt_state = ENUM_ST_DONE;
      end
      ENUM_ST_BUSY: begin
        if (i_resp_valid)
          w_fsm_apb_nxt_state = ENUM_ST_DONE;
      end
      ENUM_ST_DONE: w_fsm_apb_nxt_state = ENUM_ST_IDLE;
      default:      w_fsm_apb_nxt_state = ENUM_ST_IDLE;
    endcase
  end

  // Completion values: PREADY and PSLVERR last one cycle. A local error clears PRDATA, a response
  // loads PRDATA (already zero for writes and errors), otherwise PRDATA holds its last value.
  // Every next value has its default first (COM-02), so no latch is inferred (COM-07).
  always_comb begin : p_com_resp
    w_pready_nxt  = 1'b0;
    w_pslverr_nxt = 1'b0;
    w_prdata_nxt  = reg_prdata;
    if (w_local_err) begin
      w_pready_nxt  = 1'b1;
      w_pslverr_nxt = 1'b1;
      w_prdata_nxt  = '0;
    end else if ((reg_fsm_apb_current_state == ENUM_ST_BUSY) & i_resp_valid) begin
      w_pready_nxt  = 1'b1;
      w_pslverr_nxt = i_resp_err;
      w_prdata_nxt  = i_resp_rdata;
    end
  end

  // Current-state register: the control state is reset asynchronously to IDLE and otherwise takes
  // the next state every clock cycle.
  always_ff @(posedge i_clk_core, negedge i_rst_n_core) begin : p_ff_fsm_apb
    if (!i_rst_n_core)
      reg_fsm_apb_current_state <= ENUM_ST_IDLE;
    else
      reg_fsm_apb_current_state <= w_fsm_apb_nxt_state;
  end

  // Completion flip-flops: all are reset asynchronously to zero, so every output is defined
  // after reset (REQ-RESET-001).
  always_ff @(posedge i_clk_core, negedge i_rst_n_core) begin : p_ff_resp
    if (!i_rst_n_core) begin
      reg_pready  <= 1'b0;
      reg_pslverr <= 1'b0;
      reg_prdata  <= '0;
    end else begin
      reg_pready  <= w_pready_nxt;
      reg_pslverr <= w_pslverr_nxt;
      reg_prdata  <= w_prdata_nxt;
    end
  end

endmodule
