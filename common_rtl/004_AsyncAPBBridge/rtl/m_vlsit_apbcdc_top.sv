/*
 * Project      : VLSIT Common RTL library
 * Author       : Nguyen Quan and Claude Sonnet 5.5 (user)
 * AI Flow      : VLSIT RTL Generator AI Automation Flow
 * AI Flow Page : https://github.com/nguyenquanicd/VLSIT_RTL_Generator_AI_Model
 * Date         : 2026-10-25
 * Description  : Structural top of the asynchronous APB bridge (APB4, APB5 option). It instantiates
 *                the requester-side block (clock domain mst, the bridge is the APB completer of
 *                the requester) and the completer-side block (clock domain slv, the bridge is the
 *                APB requester of the completer) and holds no logic. The two clocks are
 *                asynchronous. A handshake with bundled data crosses the domains: the request and
 *                the acknowledge bit and the wake-up pass through synchronizers inside the blocks,
 *                the request bundle and the response bundle are held stable and loaded by the
 *                destination after the control bit arrived. The two hardware resets are asserted
 *                together and released synchronously to their own clock outside the IP. DEC-021:
 *                the APB5 ports are declared in every configuration (width 1 for an absent user
 *                signal); an unused input is ignored and an unused output is 0, which deviates from
 *                PRT-03 and is recorded here.
 */
`timescale 1ns/1ps

module m_vlsit_apbcdc_top #(
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
  localparam logic [31:0] LPARA_RESP_W = PARA_APBCDC_DATA_W + 32'd1 + LPARA_UDAT_W + LPARA_URSP_W
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
  input  wire  [LPARA_PURSP_W-1:0]      i_apb_pbuser
);

  // Interconnect declarations: the five crossings between the two blocks
  logic w_req;
  logic [LPARA_REQ_W-1:0] w_req_payload;
  logic w_wakeup;
  logic w_ack;
  logic [LPARA_RESP_W-1:0] w_resp_payload;

  // Requester-side block: captures the Setup phase, launches the request, returns the response.
  m_vlsit_apbcdc_mst #(
    .PARA_APBCDC_ADDR_W      (PARA_APBCDC_ADDR_W),
    .PARA_APBCDC_DATA_W      (PARA_APBCDC_DATA_W),
    .PARA_APBCDC_APB5        (PARA_APBCDC_APB5),
    .PARA_APBCDC_USER_REQ_W  (PARA_APBCDC_USER_REQ_W),
    .PARA_APBCDC_USER_DATA_W (PARA_APBCDC_USER_DATA_W),
    .PARA_APBCDC_USER_RESP_W (PARA_APBCDC_USER_RESP_W),
    .PARA_APBCDC_HS_TYPE     (PARA_APBCDC_HS_TYPE),
    .PARA_APBCDC_CELL_TYPE   (PARA_APBCDC_CELL_TYPE)
  ) u_vlsit_apbcdc_mst (
    .i_clk_mst      (i_clk_mst),
    .i_rst_n_mst    (i_rst_n_mst),
    .i_apb_psel     (i_apb_psel),
    .i_apb_penable  (i_apb_penable),
    .i_apb_pwrite   (i_apb_pwrite),
    .i_apb_paddr    (i_apb_paddr),
    .i_apb_pprot    (i_apb_pprot),
    .i_apb_pstrb    (i_apb_pstrb),
    .i_apb_pwdata   (i_apb_pwdata),
    .i_apb_pwakeup  (i_apb_pwakeup),
    .i_apb_pauser   (i_apb_pauser),
    .i_apb_pwuser   (i_apb_pwuser),
    .o_apb_pready   (o_apb_pready),
    .o_apb_prdata   (o_apb_prdata),
    .o_apb_pslverr  (o_apb_pslverr),
    .o_apb_pruser   (o_apb_pruser),
    .o_apb_pbuser   (o_apb_pbuser),
    .o_req          (w_req),
    .o_req_payload  (w_req_payload),
    .o_wakeup       (w_wakeup),
    .i_ack          (w_ack),
    .i_resp_payload (w_resp_payload)
  );

  // Completer-side block: loads the request, runs one APB transfer, returns the acknowledge.
  m_vlsit_apbcdc_slv #(
    .PARA_APBCDC_ADDR_W      (PARA_APBCDC_ADDR_W),
    .PARA_APBCDC_DATA_W      (PARA_APBCDC_DATA_W),
    .PARA_APBCDC_APB5        (PARA_APBCDC_APB5),
    .PARA_APBCDC_USER_REQ_W  (PARA_APBCDC_USER_REQ_W),
    .PARA_APBCDC_USER_DATA_W (PARA_APBCDC_USER_DATA_W),
    .PARA_APBCDC_USER_RESP_W (PARA_APBCDC_USER_RESP_W),
    .PARA_APBCDC_HS_TYPE     (PARA_APBCDC_HS_TYPE),
    .PARA_APBCDC_CELL_TYPE   (PARA_APBCDC_CELL_TYPE)
  ) u_vlsit_apbcdc_slv (
    .i_clk_slv      (i_clk_slv),
    .i_rst_n_slv    (i_rst_n_slv),
    .o_apb_psel     (o_apb_psel),
    .o_apb_penable  (o_apb_penable),
    .o_apb_pwrite   (o_apb_pwrite),
    .o_apb_paddr    (o_apb_paddr),
    .o_apb_pprot    (o_apb_pprot),
    .o_apb_pstrb    (o_apb_pstrb),
    .o_apb_pwdata   (o_apb_pwdata),
    .o_apb_pwakeup  (o_apb_pwakeup),
    .o_apb_pauser   (o_apb_pauser),
    .o_apb_pwuser   (o_apb_pwuser),
    .i_apb_pready   (i_apb_pready),
    .i_apb_prdata   (i_apb_prdata),
    .i_apb_pslverr  (i_apb_pslverr),
    .i_apb_pruser   (i_apb_pruser),
    .i_apb_pbuser   (i_apb_pbuser),
    .i_req          (w_req),
    .i_req_payload  (w_req_payload),
    .i_wakeup       (w_wakeup),
    .o_ack          (w_ack),
    .o_resp_payload (w_resp_payload)
  );

endmodule
