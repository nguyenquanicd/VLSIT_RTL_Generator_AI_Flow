/*
 * Project      : HyperRAM Controller
 * Author       : Nguyen Quan (user)
 * AI Flow      : VLSIT RTL Generator AI Automation Flow
 * AI Flow Page : https://github.com/nguyenquanicd/VLSIT_RTL_Generator_AI_Model
 * Date         : 2026-10-31
 * Description  : APB-to-core crossing point (CDC-001). The request and response of the register
 *                transfer pass through unchanged, because the clock crossing itself is inside the
 *                generated CSR module (sheet ASYNC_CSR with the library synchronizer, DEC-039).
 *                The block holds no state and no clock; it marks the crossing in the hierarchy
 *                and keeps the APB-side reset independent of the core, which is done by the
 *                separate resets i_rst_n_apb and i_rst_n_core of the CSR module.
 */
`timescale 1ns/1ps

module m_vlsit_apb4_cdc #(
  localparam logic [31:0] LPARA_APB_ADDR_W = 32'd16,
  localparam logic [31:0] LPARA_APB_DATA_W = 32'd32,
  localparam logic [31:0] LPARA_APB_STRB_W = 32'd4
) (
  // APB4 requester side (from m_vlsit_apb4_if)
  input  wire                         i_apb_psel,
  input  wire                         i_apb_penable,
  input  wire                         i_apb_pwrite,
  input  wire  [LPARA_APB_ADDR_W-1:0] i_apb_paddr,
  input  wire  [LPARA_APB_DATA_W-1:0] i_apb_pwdata,
  input  wire  [LPARA_APB_STRB_W-1:0] i_apb_pstrb,
  input  wire  [2:0]                  i_apb_pprot,
  output logic                        o_apb_pready,
  output logic                        o_apb_pslverr,
  output logic [LPARA_APB_DATA_W-1:0] o_apb_prdata,

  // APB4 completer side (to the register file)
  output logic                        o_apb_psel,
  output logic                        o_apb_penable,
  output logic                        o_apb_pwrite,
  output logic [LPARA_APB_ADDR_W-1:0] o_apb_paddr,
  output logic [LPARA_APB_DATA_W-1:0] o_apb_pwdata,
  output logic [LPARA_APB_STRB_W-1:0] o_apb_pstrb,
  output logic [2:0]                  o_apb_pprot,
  input  wire                         i_apb_pready,
  input  wire                         i_apb_pslverr,
  input  wire  [LPARA_APB_DATA_W-1:0] i_apb_prdata
);

  // Request path: forwarded unchanged to the register file.
  assign o_apb_psel    = i_apb_psel;
  assign o_apb_penable = i_apb_penable;
  assign o_apb_pwrite  = i_apb_pwrite;
  assign o_apb_paddr   = i_apb_paddr;
  assign o_apb_pwdata  = i_apb_pwdata;
  assign o_apb_pstrb   = i_apb_pstrb;
  assign o_apb_pprot   = i_apb_pprot;

  // Response path: forwarded unchanged to the APB front end.
  assign o_apb_pready  = i_apb_pready;
  assign o_apb_pslverr = i_apb_pslverr;
  assign o_apb_prdata  = i_apb_prdata;

endmodule
