/*
 * Project      : VLSI Technology - AI RTL generator
 * Author       : Nguyen Quan and Claude (user)
 * AI Flow      : VLSIT RTL Generator AI Automation Flow
 * AI Flow Page : https://github.com/nguyenquanicd/VLSIT_RTL_Generator_AI_Model
 * Date         : 2026-10-18
 * Description  : Structural top of the APB4 to TL-UL bridge: an APB4 completer on one side and a
 *                TL-UL host on the other, in one clock domain, changing outputs come from flops.
 */
`timescale 1ns/1ps

module m_apb_tlul_bridge #(
  // Parameter Description: width of the byte address on both buses.
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
  // Parameter Description: width of the unused d_sink input; it has no effect on behavior.
  // Parameter values: legal range is 1 to 4; default is 1.
  // Parameter unit: bit
  parameter logic [31:0] PARA_D_SINK_W = 1,
  // Parameter Description: width of the unused d_user input; it has no effect on behavior.
  // Parameter values: legal range is 1 to 32; default is 1.
  // Parameter unit: bit
  parameter logic [31:0] PARA_D_USER_W = 1
) (
  // Clock and reset
  input  wire                      i_clk_core,
  input  wire                      i_rst_n_core,

  // APB4 completer interface
  input  wire                      i_apb_psel,
  input  wire                      i_apb_penable,
  input  wire                      i_apb_pwrite,
  input  wire  [PARA_ADDR_W-1:0]   i_apb_paddr,
  input  wire  [2:0]               i_apb_pprot,
  input  wire  [3:0]               i_apb_pstrb,
  input  wire  [31:0]              i_apb_pwdata,
  output logic                     o_apb_pready,
  output logic                     o_apb_pslverr,
  output logic [31:0]              o_apb_prdata,

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
  input  wire  [2:0]               i_tlul_d_param,
  input  wire  [1:0]               i_tlul_d_size,
  input  wire  [PARA_SRC_W-1:0]    i_tlul_d_source,
  input  wire  [PARA_D_SINK_W-1:0] i_tlul_d_sink,
  input  wire  [31:0]              i_tlul_d_data,
  input  wire  [PARA_D_USER_W-1:0] i_tlul_d_user,
  output logic                     o_tlul_d_ready
);

  // Interconnect between the APB side and the TL-UL side: a request bundle and a response bundle.
  // The inputs i_apb_pprot, i_tlul_d_param, i_tlul_d_size, i_tlul_d_sink and i_tlul_d_user are
  // present for integration only and are not used (PPROT is ignored; the response check does not
  // use d_size, d_param, d_sink or d_user).
  logic w_req_launch;
  logic w_req_wr;
  logic w_resp_valid;
  logic w_resp_err;
  logic [PARA_ADDR_W-3:0] w_req_addr;
  logic [31:0] w_req_wdata;
  logic [31:0] w_resp_rdata;

  // APB side: detects the Setup phase, checks and launches the request, returns the completion.
  m_apb_if #(
    .PARA_ADDR_W (PARA_ADDR_W)
  ) u_apb_if (
    .i_clk_core    (i_clk_core),
    .i_rst_n_core  (i_rst_n_core),
    .i_apb_psel    (i_apb_psel),
    .i_apb_penable (i_apb_penable),
    .i_apb_pwrite  (i_apb_pwrite),
    .i_resp_valid  (w_resp_valid),
    .i_resp_err    (w_resp_err),
    .i_apb_paddr   (i_apb_paddr),
    .i_apb_pstrb   (i_apb_pstrb),
    .i_apb_pwdata  (i_apb_pwdata),
    .i_resp_rdata  (w_resp_rdata),
    .o_req_launch  (w_req_launch),
    .o_req_wr      (w_req_wr),
    .o_apb_pready  (o_apb_pready),
    .o_apb_pslverr (o_apb_pslverr),
    .o_req_addr    (w_req_addr),
    .o_req_wdata   (w_req_wdata),
    .o_apb_prdata  (o_apb_prdata)
  );

  // TL-UL side: drives channel A from flops, accepts and checks the response, reports it upward.
  m_tlul_if #(
    .PARA_ADDR_W   (PARA_ADDR_W),
    .PARA_SRC_W    (PARA_SRC_W),
    .PARA_SRC_ID   (PARA_SRC_ID),
    .PARA_A_USER_W (PARA_A_USER_W)
  ) u_tlul_if (
    .i_clk_core       (i_clk_core),
    .i_rst_n_core     (i_rst_n_core),
    .i_req_launch     (w_req_launch),
    .i_req_wr         (w_req_wr),
    .i_tlul_a_ready   (i_tlul_a_ready),
    .i_tlul_d_valid   (i_tlul_d_valid),
    .i_tlul_d_error   (i_tlul_d_error),
    .i_req_addr       (w_req_addr),
    .i_req_wdata      (w_req_wdata),
    .i_tlul_d_opcode  (i_tlul_d_opcode),
    .i_tlul_d_source  (i_tlul_d_source),
    .i_tlul_d_data    (i_tlul_d_data),
    .o_resp_valid     (w_resp_valid),
    .o_resp_err       (w_resp_err),
    .o_tlul_a_valid   (o_tlul_a_valid),
    .o_tlul_d_ready   (o_tlul_d_ready),
    .o_resp_rdata     (w_resp_rdata),
    .o_tlul_a_opcode  (o_tlul_a_opcode),
    .o_tlul_a_param   (o_tlul_a_param),
    .o_tlul_a_size    (o_tlul_a_size),
    .o_tlul_a_source  (o_tlul_a_source),
    .o_tlul_a_address (o_tlul_a_address),
    .o_tlul_a_mask    (o_tlul_a_mask),
    .o_tlul_a_data    (o_tlul_a_data),
    .o_tlul_a_user    (o_tlul_a_user)
  );

endmodule
