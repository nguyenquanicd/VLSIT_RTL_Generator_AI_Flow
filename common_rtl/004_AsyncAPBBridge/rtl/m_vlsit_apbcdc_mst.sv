/*
 * Project      : VLSIT Common RTL library
 * Author       : Nguyen Quan and Claude Sonnet 5.5 (user)
 * AI Flow      : VLSIT RTL Generator AI Automation Flow
 * AI Flow Page : https://github.com/nguyenquanicd/VLSIT_RTL_Generator_AI_Model
 * Date         : 2026-10-25
 * Description  : Requester-side block of the asynchronous APB bridge (clock domain mst). It is the
 *                APB completer of the requester: in the Setup phase it loads the request hold
 *                register and launches the request bit (toggle for the two-phase handshake, level
 *                for the four-phase handshake), receives the acknowledge through the synchronizer
 *                u_sync_ack, loads the response output registers and raises PREADY for one cycle.
 *                In APB5 it registers i_apb_pwakeup for the crossing. The request bundle is held
 *                stable until the acknowledge is seen and crosses without a synchronizer; only the
 *                control bits are synchronized. DEC-016: the request bit is launched at the same
 *                edge at which the bundle is loaded. DEC-021: the APB5 ports are declared in every
 *                configuration (width 1 for an absent user signal); an unused input is ignored and
 *                an unused output is 0, which deviates from PRT-03 and is recorded here.
 */
`timescale 1ns/1ps

module m_vlsit_apbcdc_mst #(
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
  // Clock and reset of the mst domain
  input  wire                           i_clk_mst,
  input  wire                           i_rst_n_mst,

  // Requester-side APB interface, request
  input  wire                           i_apb_psel,
  input  wire                           i_apb_penable,
  input  wire                           i_apb_pwrite,
  input  wire  [PARA_APBCDC_ADDR_W-1:0] i_apb_paddr,
  input  wire  [2:0]                    i_apb_pprot,
  input  wire  [LPARA_STRB_W-1:0]       i_apb_pstrb,
  input  wire  [PARA_APBCDC_DATA_W-1:0] i_apb_pwdata,
  input  wire                           i_apb_pwakeup,
  input  wire  [LPARA_PUREQ_W-1:0]      i_apb_pauser,
  input  wire  [LPARA_PUDAT_W-1:0]      i_apb_pwuser,

  // Requester-side APB interface, response
  output logic                          o_apb_pready,
  output logic [PARA_APBCDC_DATA_W-1:0] o_apb_prdata,
  output logic                          o_apb_pslverr,
  output logic [LPARA_PUDAT_W-1:0]      o_apb_pruser,
  output logic [LPARA_PURSP_W-1:0]      o_apb_pbuser,

  // Crossing signals with the slv block
  output logic                          o_req,
  output logic [LPARA_REQ_W-1:0]        o_req_payload,
  output logic                          o_wakeup,
  input  wire                           i_ack,
  input  wire  [LPARA_RESP_W-1:0]       i_resp_payload
);

  // FSM states of the requester side: IDLE waits for the Setup phase, WAIT waits for the
  // acknowledge event, CLOSE (four-phase only) waits for the acknowledge to fall, RESP holds PREADY
  // for one cycle. All four encodings are used, so there is no unused encoding.
  typedef enum logic [1:0] {
    ENUM_ST_IDLE  = 2'b00,
    ENUM_ST_WAIT  = 2'b01,
    ENUM_ST_CLOSE = 2'b10,
    ENUM_ST_RESP  = 2'b11
  } hs_state_type_def;

  // Internal signal declarations
  hs_state_type_def reg_fsm_hs_current_state;
  hs_state_type_def w_fsm_hs_nxt_state;

  logic reg_req;
  logic w_req_nxt;
  logic reg_wakeup;
  logic reg_pready;
  logic [LPARA_REQ_W-1:0] reg_req_payload;
  logic [LPARA_REQ_W-1:0] w_req_payload;
  logic [LPARA_RESP_W-1:0] reg_resp_payload;

  logic w_ack_s;
  logic w_setup;
  logic w_ack_event;
  logic w_launch;
  logic w_clr_req;
  logic w_load_resp;

  // Setup phase of the requester: PSEL high and PENABLE low (IHI 0024D 4.1).
  assign w_setup = i_apb_psel & ~i_apb_penable;

  // Acknowledge event. Two-phase: the synchronized acknowledge equals the request bit again.
  // Four-phase: the synchronized acknowledge is high.
  assign w_ack_event = (PARA_APBCDC_HS_TYPE == 32'd0) ? (w_ack_s == reg_req) : w_ack_s;

  // Request bundle packed from the Setup cycle. Field order from bit 0: PADDR, PPROT, PWRITE,
  // PSTRB, PWDATA, PAUSER, PWUSER; a field of width 0 has no bit.
  assign w_req_payload[PARA_APBCDC_ADDR_W-1:0] = i_apb_paddr;
  assign w_req_payload[PARA_APBCDC_ADDR_W +: LPARA_PROT_W] = i_apb_pprot;
  assign w_req_payload[LPARA_OFF_WR] = i_apb_pwrite;
  assign w_req_payload[LPARA_OFF_STRB +: LPARA_STRB_W] = i_apb_pstrb;
  assign w_req_payload[LPARA_OFF_WDATA +: PARA_APBCDC_DATA_W] = i_apb_pwdata;
  if (LPARA_UREQ_W != 32'd0) begin : gen_pack_auser
    // Bundle field of the packed vector (field order of Section 9).
    assign w_req_payload[LPARA_OFF_AUSER +: LPARA_UREQ_W] =
      i_apb_pauser[LPARA_UREQ_W-1:0];
  end
  if (LPARA_UDAT_W != 32'd0) begin : gen_pack_wuser
    // Bundle field of the packed vector (field order of Section 9).
    assign w_req_payload[LPARA_OFF_WUSER +: LPARA_UDAT_W] =
      i_apb_pwuser[LPARA_UDAT_W-1:0];
  end

  // Next state of the requester-side FSM.
  always_comb begin : p_com_fsm_hs_nxt
    w_fsm_hs_nxt_state = reg_fsm_hs_current_state;
    case (reg_fsm_hs_current_state)
      ENUM_ST_IDLE: begin
        if (w_setup)
          w_fsm_hs_nxt_state = ENUM_ST_WAIT;
      end
      ENUM_ST_WAIT: begin
        if (w_ack_event)
          w_fsm_hs_nxt_state = (PARA_APBCDC_HS_TYPE == 32'd0) ? ENUM_ST_RESP : ENUM_ST_CLOSE;
      end
      ENUM_ST_CLOSE: begin
        if (!w_ack_s)
          w_fsm_hs_nxt_state = ENUM_ST_RESP;
      end
      default: w_fsm_hs_nxt_state = ENUM_ST_IDLE;
    endcase
  end

  // Datapath controls decoded from the state. The launch loads the bundle and starts the request at
  // the same edge. The response is loaded at the edge that leaves WAIT (two-phase) or CLOSE
  // (four-phase); the four-phase request is cleared at the edge that leaves WAIT.
  assign w_launch    = (reg_fsm_hs_current_state == ENUM_ST_IDLE) & w_setup;
  assign w_clr_req   = (reg_fsm_hs_current_state == ENUM_ST_WAIT) & w_ack_event &
                       (PARA_APBCDC_HS_TYPE != 32'd0);
  // Combinational decode of the control signals.
  assign w_load_resp = ((reg_fsm_hs_current_state == ENUM_ST_WAIT) & w_ack_event &
                        (PARA_APBCDC_HS_TYPE == 32'd0)) |
                       ((reg_fsm_hs_current_state == ENUM_ST_CLOSE) & ~w_ack_s);

  // Next request bit: toggled (two-phase) or set (four-phase) at the launch, cleared in four-phase.
  always_comb begin : p_com_req_nxt
    w_req_nxt = reg_req;
    if (w_launch)
      w_req_nxt = (PARA_APBCDC_HS_TYPE == 32'd0) ? ~reg_req : 1'b1;
    else if (w_clr_req)
      w_req_nxt = 1'b0;
  end

  // Current state of the requester-side FSM: control state, asynchronously reset to IDLE (R-036:
  // this block holds the current state only).
  always_ff @(posedge i_clk_mst, negedge i_rst_n_mst) begin : p_ff_fsm_hs
    if (!i_rst_n_mst)
      reg_fsm_hs_current_state <= ENUM_ST_IDLE;
    else
      reg_fsm_hs_current_state <= w_fsm_hs_nxt_state;
  end

  // Request bit, wake-up register and PREADY: control state, asynchronously reset to 0.
  always_ff @(posedge i_clk_mst, negedge i_rst_n_mst) begin : p_ff_ctrl
    if (!i_rst_n_mst) begin
      reg_req    <= 1'b0;
      reg_wakeup <= 1'b0;
      reg_pready <= 1'b0;
    end else begin
      reg_req    <= w_req_nxt;
      reg_wakeup <= (PARA_APBCDC_APB5 != 32'd0) & i_apb_pwakeup;
      reg_pready <= w_load_resp;
    end
  end

  // Request hold register: loaded at the launch edge and stable until the acknowledge is seen
  // (REQ-HS-002). It is the source of the crossing CDC-001.
  always_ff @(posedge i_clk_mst, negedge i_rst_n_mst) begin : p_ff_req_payload
    if (!i_rst_n_mst)
      reg_req_payload <= '0;
    else if (w_launch)
      reg_req_payload <= w_req_payload;
  end

  // Response output registers: loaded from the response bundle of the slv block at the PREADY
  // edge (crossing CDC-004). PSLVERR is cleared after the PREADY cycle.
  always_ff @(posedge i_clk_mst, negedge i_rst_n_mst) begin : p_ff_resp_payload
    if (!i_rst_n_mst) begin
      reg_resp_payload <= '0;
    end else if (w_load_resp) begin
      reg_resp_payload <= i_resp_payload;
    end else if (reg_fsm_hs_current_state == ENUM_ST_RESP) begin
      reg_resp_payload[PARA_APBCDC_DATA_W] <= 1'b0;
    end
  end

  // Response outputs sliced from the response output registers. Field order from bit 0: PRDATA,
  // PSLVERR, PRUSER, PBUSER; an absent user field is 0.
  assign o_apb_pready  = reg_pready;
  assign o_apb_prdata  = reg_resp_payload[PARA_APBCDC_DATA_W-1:0];
  assign o_apb_pslverr = reg_resp_payload[PARA_APBCDC_DATA_W];
  if (LPARA_UDAT_W != 32'd0) begin : gen_pruser
    // Response output sliced from the response output registers.
    assign o_apb_pruser = {{(LPARA_PUDAT_W - LPARA_UDAT_W){1'b0}},
                           reg_resp_payload[PARA_APBCDC_DATA_W + 1 +: LPARA_UDAT_W]};
  end else begin : gen_no_pruser
    // Response output sliced from the response output registers.
    assign o_apb_pruser = '0;
  end
  if (LPARA_URSP_W != 32'd0) begin : gen_pbuser
    // Response output sliced from the response output registers.
    assign o_apb_pbuser = {{(LPARA_PURSP_W - LPARA_URSP_W){1'b0}},
                           reg_resp_payload[PARA_APBCDC_DATA_W + 1 + LPARA_UDAT_W +: LPARA_URSP_W]};
  end else begin : gen_no_pbuser
    // Response output sliced from the response output registers.
    assign o_apb_pbuser = '0;
  end

  // Crossing outputs.
  assign o_req         = reg_req;
  assign o_req_payload = reg_req_payload;
  assign o_wakeup      = reg_wakeup;

  // Synchronizer of the acknowledge (crossing CDC-003), one bit, reset to 0.
  m_vlsit_apbcdc_sync #(
    .PARA_APBCDC_SYNC_W       (32'd1),
    .PARA_APBCDC_SYNC_RST_VAL (32'd0),
    .PARA_APBCDC_CELL_TYPE    (PARA_APBCDC_CELL_TYPE)
  ) u_sync_ack (
    .i_clk_dst   (i_clk_mst),
    .i_rst_n_dst (i_rst_n_mst),
    .i_data      (i_ack),
    .o_data      (w_ack_s)
  );

endmodule
