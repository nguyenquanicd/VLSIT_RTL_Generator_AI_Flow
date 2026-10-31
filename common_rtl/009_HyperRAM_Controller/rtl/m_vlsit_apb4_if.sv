/*
 * Project      : HyperRAM Controller
 * Author       : Nguyen Quan (user)
 * AI Flow      : VLSIT RTL Generator AI Automation Flow
 * AI Flow Page : https://github.com/nguyenquanicd/VLSIT_RTL_Generator_AI_Model
 * Date         : 2026-10-31
 * Description  : APB4 front end of the register file (REQ-CSR-005, DEC-033). It forwards every
 *                transfer to the generated CSR, except a word-aligned address that is not a
 *                register: that transfer is answered here with PREADY = 1 and PSLVERR = 1 and the
 *                CSR is not selected. A misaligned address and a partial write strobe are passed
 *                on, because the CSR answers them with PSLVERR itself. The register ranges below
 *                mirror the workbook HyperRAM_Controller_CSR_Specification.xlsx (40 registers) and
 *                have to be changed together with it.
 */
`timescale 1ns/1ps

module m_vlsit_apb4_if #(
  localparam logic [31:0] LPARA_APB_ADDR_W  = 32'd16,
  localparam logic [31:0] LPARA_APB_DATA_W  = 32'd32,
  localparam logic [31:0] LPARA_APB_STRB_W  = 32'd4,
  // Register ranges of the workbook: the 20 common registers at 0x000 to 0x04C and the 10
  // registers of each device group at 0x100 to 0x124 and at 0x200 to 0x224.
  localparam logic [31:0] LPARA_PAGE_COMMON = 32'h00,
  localparam logic [31:0] LPARA_PAGE_DEV_0  = 32'h01,
  localparam logic [31:0] LPARA_PAGE_DEV_1  = 32'h02,
  localparam logic [31:0] LPARA_LAST_COMMON = 32'd19,
  localparam logic [31:0] LPARA_LAST_DEV    = 32'd9
) (
  // APB clock and reset
  input  wire                         i_clk_apb,
  input  wire                         i_rst_n_apb,

  // APB4 completer interface (SoC side)
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

  // APB4 requester interface (register file side)
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

  // Internal signal declarations
  logic w_aligned;
  logic w_mapped;
  logic w_unmapped;
  logic w_unmap_rsp_nxt;
  logic reg_unmap_rsp;

  // Alignment check: a word register sits at an address whose two low bits are zero.
  assign w_aligned = (i_apb_paddr[1:0] == 2'b00);

  // Register decode: the address page selects the register group and the word index must not
  // exceed the last register of the group; any other page holds no register.
  always_comb begin : p_com_mapped
    w_mapped = 1'b0;
    case (32'(i_apb_paddr[LPARA_APB_ADDR_W-1:8]))
      LPARA_PAGE_COMMON: w_mapped = (32'(i_apb_paddr[7:2]) <= LPARA_LAST_COMMON);
      LPARA_PAGE_DEV_0:  w_mapped = (32'(i_apb_paddr[7:2]) <= LPARA_LAST_DEV);
      LPARA_PAGE_DEV_1:  w_mapped = (32'(i_apb_paddr[7:2]) <= LPARA_LAST_DEV);
      default:           w_mapped = 1'b0;
    endcase
  end

  // Only a word-aligned address without a register is answered here (DEC-033).
  assign w_unmapped = w_aligned & ~w_mapped;

  // Forward the request to the register file; the select is withdrawn for an unmapped address.
  assign o_apb_psel    = i_apb_psel & ~w_unmapped;
  assign o_apb_penable = i_apb_penable;
  assign o_apb_pwrite  = i_apb_pwrite;
  assign o_apb_paddr   = i_apb_paddr;
  assign o_apb_pwdata  = i_apb_pwdata;
  assign o_apb_pstrb   = i_apb_pstrb;
  assign o_apb_pprot   = i_apb_pprot;

  // Error response for an unmapped address: loaded in the setup phase, so PREADY and PSLVERR are
  // HIGH in the first access cycle (zero wait states) and LOW again afterwards.
  assign w_unmap_rsp_nxt = i_apb_psel & ~i_apb_penable & w_unmapped;

  // Response flag. Reset clears it, so no response is pending after reset.
  always_ff @(posedge i_clk_apb, negedge i_rst_n_apb) begin : p_ff_unmap_rsp
    if (!i_rst_n_apb)
      reg_unmap_rsp <= 1'b0;
    else
      reg_unmap_rsp <= w_unmap_rsp_nxt;
  end

  // Response to the SoC. The CSR keeps its last PSLVERR and PRDATA outside a transfer, so the
  // error is qualified with the CSR PREADY and the data of an unmapped read is zero.
  assign o_apb_pready  = reg_unmap_rsp | i_apb_pready;
  assign o_apb_pslverr = reg_unmap_rsp | (i_apb_pslverr & i_apb_pready);
  assign o_apb_prdata  = reg_unmap_rsp ? {LPARA_APB_DATA_W{1'b0}} : i_apb_prdata;

endmodule
