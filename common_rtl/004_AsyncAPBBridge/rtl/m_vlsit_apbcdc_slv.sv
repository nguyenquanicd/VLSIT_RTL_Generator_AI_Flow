/*
 * Project      : VLSIT Common RTL library
 * Author       : Nguyen Quan and Claude Sonnet 5.5 (user)
 * AI Flow      : VLSIT RTL Generator AI Automation Flow
 * AI Flow Page : https://github.com/nguyenquanicd/VLSIT_RTL_Generator_AI_Model
 * Date         : 2026-10-25
 * Description  : Completer-side block of the asynchronous APB bridge (clock domain slv). It is the
 *                APB requester toward the completer: it receives the request bit through the
 *                synchronizer u_sync_req, loads the request bundle of the mst block into
 *                reg_apb_payload, drives one APB transfer (Setup, Access until PREADY), holds the
 *                response in reg_resp_hold and launches the acknowledge bit (toggle for the
 *                two-phase handshake, level for the four-phase handshake). In APB5 it drives
 *                o_apb_pwakeup from a flip-flop: the synchronized wake-up of the mst block OR a
 *                transfer in progress. All APB outputs are flip-flop outputs (REQ-IF-002).
 *                DEC-021: the APB5 ports are declared in every configuration (width 1 for an
 *                absent user signal); an unused input is ignored and an unused output is 0, which
 *                deviates from PRT-03 and is recorded here.
 */
`timescale 1ns/1ps

module m_vlsit_apbcdc_slv #(
  // Parameter Description: width of the byte address.
  // Parameter values: 1 to 32; default is 32.
  // Parameter unit: bit
  parameter logic [31:0] PARA_APBCDC_ADDR_W = 32,
  // Parameter Description: width of the data buses PWDATA and PRDATA.
  // Parameter values: 8, 16 or 32; default is 32.
  // Parameter unit: bit
  parameter logic [31:0] PARA_APBCDC_DATA_W = 32,
  // Parameter Description: interface revision, 0 = APB4, 1 = APB5 (adds PWAKEUP and user signals).
  // Parameter values: 0 or 1; default is 0.
  // Parameter unit: none
  parameter logic [31:0] PARA_APBCDC_APB5 = 0,
  // Parameter Description: width of PAUSER, used only when PARA_APBCDC_APB5 is 1.
  // Parameter values: 0 to 128; default is 0 (signal absent, port of width 1 ignored).
  // Parameter unit: bit
  parameter logic [31:0] PARA_APBCDC_USER_REQ_W = 0,
  // Parameter Description: width of PWUSER and PRUSER, used only when PARA_APBCDC_APB5 is 1.
  // Parameter values: 0 to PARA_APBCDC_DATA_W; default is 0 (signals absent).
  // Parameter unit: bit
  parameter logic [31:0] PARA_APBCDC_USER_DATA_W = 0,
  // Parameter Description: width of PBUSER, used only when PARA_APBCDC_APB5 is 1.
  // Parameter values: 0 to 16; default is 0 (signal absent).
  // Parameter unit: bit
  parameter logic [31:0] PARA_APBCDC_USER_RESP_W = 0,
  // Parameter Description: handshake type, 0 = two-phase (toggle), 1 = four-phase (level).
  // Parameter values: 0 or 1; default is 0.
  // Parameter unit: none
  parameter logic [31:0] PARA_APBCDC_HS_TYPE = 0,
  // Parameter Description: synchronizer cell option, 0 = bypass (simulation only), 1 = two D
  // flip-flop cells, 2 = one 2-FF cell, 3 = one 3-FF cell, 4 = one 4-FF cell.
  // Parameter values: 0 to 4; default is 2.
  // Parameter unit: none
  parameter logic [31:0] PARA_APBCDC_CELL_TYPE = 2,
  localparam logic [31:0] LPARA_STRB_W = PARA_APBCDC_DATA_W / 8,
  localparam logic [31:0] LPARA_PROT_W = 3,
  localparam logic [31:0] LPARA_PUREQ_W = (PARA_APBCDC_USER_REQ_W == 0) ? 1 : PARA_APBCDC_USER_REQ_W,
  localparam logic [31:0] LPARA_PUDAT_W = (PARA_APBCDC_USER_DATA_W == 0) ? 1 : PARA_APBCDC_USER_DATA_W,
  localparam logic [31:0] LPARA_PURSP_W = (PARA_APBCDC_USER_RESP_W == 0) ? 1 : PARA_APBCDC_USER_RESP_W,
  localparam logic [31:0] LPARA_UREQ_W = (PARA_APBCDC_APB5 == 0) ? 0 : PARA_APBCDC_USER_REQ_W,
  localparam logic [31:0] LPARA_UDAT_W = (PARA_APBCDC_APB5 == 0) ? 0 : PARA_APBCDC_USER_DATA_W,
  localparam logic [31:0] LPARA_URSP_W = (PARA_APBCDC_APB5 == 0) ? 0 : PARA_APBCDC_USER_RESP_W,
  localparam logic [31:0] LPARA_REQ_W = PARA_APBCDC_ADDR_W + LPARA_PROT_W + 32'd1 + LPARA_STRB_W + PARA_APBCDC_DATA_W +
                                        LPARA_UREQ_W + LPARA_UDAT_W,
  localparam logic [31:0] LPARA_RESP_W = PARA_APBCDC_DATA_W + 32'd1 + LPARA_UDAT_W + LPARA_URSP_W,
  localparam logic [31:0] LPARA_OFF_WR = PARA_APBCDC_ADDR_W + LPARA_PROT_W,
  localparam logic [31:0] LPARA_OFF_STRB = LPARA_OFF_WR + 32'd1,
  localparam logic [31:0] LPARA_OFF_WDATA = LPARA_OFF_STRB + LPARA_STRB_W,
  localparam logic [31:0] LPARA_OFF_AUSER = LPARA_OFF_WDATA + PARA_APBCDC_DATA_W,
  localparam logic [31:0] LPARA_OFF_WUSER = LPARA_OFF_AUSER + LPARA_UREQ_W
) (
  // Clock and reset of the slv domain
  input  wire                           i_clk_slv,
  input  wire                           i_rst_n_slv,

  // Completer-side APB interface, request
  output logic                          o_apb_psel,
  output logic                          o_apb_penable,
  output logic                          o_apb_pwrite,
  output logic [PARA_APBCDC_ADDR_W-1:0] o_apb_paddr,
  output logic [2:0]                    o_apb_pprot,
  output logic [LPARA_STRB_W-1:0]       o_apb_pstrb,
  output logic [PARA_APBCDC_DATA_W-1:0] o_apb_pwdata,
  output logic                          o_apb_pwakeup,
  output logic [LPARA_PUREQ_W-1:0]      o_apb_pauser,
  output logic [LPARA_PUDAT_W-1:0]      o_apb_pwuser,

  // Completer-side APB interface, response
  input  wire                           i_apb_pready,
  input  wire  [PARA_APBCDC_DATA_W-1:0] i_apb_prdata,
  input  wire                           i_apb_pslverr,
  input  wire  [LPARA_PUDAT_W-1:0]      i_apb_pruser,
  input  wire  [LPARA_PURSP_W-1:0]      i_apb_pbuser,

  // Crossing signals with the mst block
  input  wire                           i_req,
  input  wire  [LPARA_REQ_W-1:0]        i_req_payload,
  input  wire                           i_wakeup,
  output logic                          o_ack,
  output logic [LPARA_RESP_W-1:0]       o_resp_payload
);

  // FSM states of the completer side: IDLE waits for the request event, SETUP is the Setup phase,
  // ACCESS is the Access phase until PREADY, REQ0 (four-phase only) waits for the request to fall.
  // All four encodings are used, so there is no unused encoding.
  typedef enum logic [1:0] {
    ENUM_ST_IDLE   = 2'b00,
    ENUM_ST_SETUP  = 2'b01,
    ENUM_ST_ACCESS = 2'b10,
    ENUM_ST_REQ0   = 2'b11
  } hs_state_type_def;

  // Internal signal declarations
  hs_state_type_def reg_fsm_hs_current_state;
  hs_state_type_def w_fsm_hs_nxt_state;

  logic reg_ack;
  logic w_ack_nxt;
  logic reg_apb_psel;
  logic reg_apb_penable;
  logic reg_pwakeup;
  logic [LPARA_REQ_W-1:0] reg_apb_payload;
  logic [LPARA_RESP_W-1:0] reg_resp_hold;
  logic [LPARA_RESP_W-1:0] w_resp_payload;

  logic w_req_s;
  logic w_wk_s;
  logic w_req_event;
  logic w_load_req;
  logic w_done;

  // Request event. Two-phase: the synchronized request differs from the acknowledge bit.
  // Four-phase: the synchronized request is high.
  assign w_req_event = (PARA_APBCDC_HS_TYPE == 32'd0) ? (w_req_s != reg_ack) : w_req_s;

  // The request is loaded in IDLE at the request event; the transfer ends when the completer
  // drives PREADY in the Access phase.
  assign w_load_req = (reg_fsm_hs_current_state == ENUM_ST_IDLE) & w_req_event;
  assign w_done     = (reg_fsm_hs_current_state == ENUM_ST_ACCESS) & i_apb_pready;

  // Response bundle packed from the completer. Field order from bit 0: PRDATA, PSLVERR, PRUSER,
  // PBUSER; a field of width 0 has no bit.
  assign w_resp_payload[PARA_APBCDC_DATA_W-1:0] = i_apb_prdata;
  assign w_resp_payload[PARA_APBCDC_DATA_W] = i_apb_pslverr;
  if (LPARA_UDAT_W != 32'd0) begin : gen_pack_pruser
    // Bundle field of the packed vector (field order of Section 9).
    assign w_resp_payload[PARA_APBCDC_DATA_W + 1 +: LPARA_UDAT_W] = i_apb_pruser[LPARA_UDAT_W-1:0];
  end
  if (LPARA_URSP_W != 32'd0) begin : gen_pack_pbuser
    // Bundle field of the packed vector (field order of Section 9).
    assign w_resp_payload[PARA_APBCDC_DATA_W + 1 + LPARA_UDAT_W +: LPARA_URSP_W] = i_apb_pbuser[LPARA_URSP_W-1:0];
  end

  // Next state of the completer-side FSM.
  always_comb begin : p_com_fsm_hs_nxt
    w_fsm_hs_nxt_state = reg_fsm_hs_current_state;
    case (reg_fsm_hs_current_state)
      ENUM_ST_IDLE: begin
        if (w_req_event)
          w_fsm_hs_nxt_state = ENUM_ST_SETUP;
      end
      ENUM_ST_SETUP: w_fsm_hs_nxt_state = ENUM_ST_ACCESS;
      ENUM_ST_ACCESS: begin
        if (i_apb_pready)
          w_fsm_hs_nxt_state = (PARA_APBCDC_HS_TYPE == 32'd0) ? ENUM_ST_IDLE : ENUM_ST_REQ0;
      end
      default: begin
        if (!w_req_s)
          w_fsm_hs_nxt_state = ENUM_ST_IDLE;
      end
    endcase
  end

  // Next acknowledge bit: toggled (two-phase) or set (four-phase) when the transfer ends, and
  // cleared (four-phase) when the request has fallen.
  always_comb begin : p_com_ack_nxt
    w_ack_nxt = reg_ack;
    if (w_done)
      w_ack_nxt = (PARA_APBCDC_HS_TYPE == 32'd0) ? ~reg_ack : 1'b1;
    else if ((reg_fsm_hs_current_state == ENUM_ST_REQ0) & ~w_req_s)
      w_ack_nxt = 1'b0;
  end

  // Current state of the completer-side FSM: control state, asynchronously reset to IDLE (R-036:
  // this block holds the current state only).
  always_ff @(posedge i_clk_slv, negedge i_rst_n_slv) begin : p_ff_fsm_hs
    if (!i_rst_n_slv)
      reg_fsm_hs_current_state <= ENUM_ST_IDLE;
    else
      reg_fsm_hs_current_state <= w_fsm_hs_nxt_state;
  end

  // Acknowledge bit, PSEL, PENABLE and the wake-up flop: control state, asynchronously reset to 0.
  // PSEL and PENABLE are decoded from the next state, so PSEL is high in SETUP and ACCESS and
  // PENABLE is high in ACCESS. The wake-up covers the synchronized wake-up of the requester, the
  // load of a request and every state but IDLE; it is 0 in APB4.
  always_ff @(posedge i_clk_slv, negedge i_rst_n_slv) begin : p_ff_ctrl
    if (!i_rst_n_slv) begin
      reg_ack         <= 1'b0;
      reg_apb_psel    <= 1'b0;
      reg_apb_penable <= 1'b0;
      reg_pwakeup     <= 1'b0;
    end else begin
      reg_ack         <= w_ack_nxt;
      reg_apb_psel    <= (w_fsm_hs_nxt_state == ENUM_ST_SETUP) | (w_fsm_hs_nxt_state == ENUM_ST_ACCESS);
      reg_apb_penable <= (w_fsm_hs_nxt_state == ENUM_ST_ACCESS);
      reg_pwakeup     <= (PARA_APBCDC_APB5 != 32'd0) &
                         (w_wk_s | w_load_req | (reg_fsm_hs_current_state != ENUM_ST_IDLE));
    end
  end

  // Request register of the completer side: loaded from the request bundle of the mst block at the
  // request event (crossing CDC-001, the bundle has been stable for the synchronizer latency) and
  // stable until the next request. It drives the APB request fields.
  always_ff @(posedge i_clk_slv, negedge i_rst_n_slv) begin : p_ff_apb_payload
    if (!i_rst_n_slv)
      reg_apb_payload <= '0;
    else if (w_load_req)
      reg_apb_payload <= i_req_payload;
  end

  // Response hold register: loaded at the edge where the completer drives PREADY and stable until
  // the next request (source of the crossing CDC-004).
  always_ff @(posedge i_clk_slv, negedge i_rst_n_slv) begin : p_ff_resp_hold
    if (!i_rst_n_slv)
      reg_resp_hold <= '0;
    else if (w_done)
      reg_resp_hold <= w_resp_payload;
  end

  // APB request outputs sliced from the request register. Field order from bit 0: PADDR, PPROT,
  // PWRITE, PSTRB, PWDATA, PAUSER, PWUSER; an absent user field is 0.
  assign o_apb_psel    = reg_apb_psel;
  assign o_apb_penable = reg_apb_penable;
  assign o_apb_pwakeup = reg_pwakeup;
  assign o_apb_paddr   = reg_apb_payload[PARA_APBCDC_ADDR_W-1:0];
  assign o_apb_pprot   = reg_apb_payload[PARA_APBCDC_ADDR_W +: LPARA_PROT_W];
  assign o_apb_pwrite  = reg_apb_payload[LPARA_OFF_WR];
  assign o_apb_pstrb   = reg_apb_payload[LPARA_OFF_STRB +: LPARA_STRB_W];
  assign o_apb_pwdata  = reg_apb_payload[LPARA_OFF_WDATA +: PARA_APBCDC_DATA_W];
  if (LPARA_UREQ_W != 32'd0) begin : gen_pauser
    // APB request output sliced from the request register.
    assign o_apb_pauser = {{(LPARA_PUREQ_W - LPARA_UREQ_W){1'b0}},
                           reg_apb_payload[LPARA_OFF_AUSER +: LPARA_UREQ_W]};
  end else begin : gen_no_pauser
    // APB request output sliced from the request register.
    assign o_apb_pauser = '0;
  end
  if (LPARA_UDAT_W != 32'd0) begin : gen_pwuser
    // APB request output sliced from the request register.
    assign o_apb_pwuser = {{(LPARA_PUDAT_W - LPARA_UDAT_W){1'b0}},
                           reg_apb_payload[LPARA_OFF_WUSER +: LPARA_UDAT_W]};
  end else begin : gen_no_pwuser
    // APB request output sliced from the request register.
    assign o_apb_pwuser = '0;
  end

  // Crossing outputs.
  assign o_ack          = reg_ack;
  assign o_resp_payload = reg_resp_hold;

  // Synchronizer of the request (crossing CDC-002), one bit, reset to 0.
  m_vlsit_apbcdc_sync #(
    .PARA_APBCDC_SYNC_W       (32'd1),
    .PARA_APBCDC_SYNC_RST_VAL (32'd0),
    .PARA_APBCDC_CELL_TYPE    (PARA_APBCDC_CELL_TYPE)
  ) u_sync_req (
    .i_clk_dst   (i_clk_slv),
    .i_rst_n_dst (i_rst_n_slv),
    .i_data      (i_req),
    .o_data      (w_req_s)
  );

  // Synchronizer of the wake-up (crossing CDC-005), one bit, reset to 0.
  m_vlsit_apbcdc_sync #(
    .PARA_APBCDC_SYNC_W       (32'd1),
    .PARA_APBCDC_SYNC_RST_VAL (32'd0),
    .PARA_APBCDC_CELL_TYPE    (PARA_APBCDC_CELL_TYPE)
  ) u_sync_wk (
    .i_clk_dst   (i_clk_slv),
    .i_rst_n_dst (i_rst_n_slv),
    .i_data      (i_wakeup),
    .o_data      (w_wk_s)
  );

endmodule
