/*
 * Project      : QSPI_Controller
 * Author       : Nguyen Quan (user)
 * AI Flow      : VLSIT RTL Generator AI Automation Flow
 * AI Flow Page : https://github.com/nguyenquanicd/VLSIT_RTL_Generator_AI_Model
 * Date         : 2026-11-02
 * Description  : Routes APB4 accesses to generated CSRs or custom TX/RX FIFO data windows.
 *                FIFO pointers advance only after a successful APB ACCESS handshake.
 */
`timescale 1ns/1ps

module m_qspi_apb_decode #(
  localparam logic [31:0] LPARA_TX_FIFO_ADDR = 32'h0000_1000,
  localparam logic [31:0] LPARA_RX_FIFO_ADDR = 32'h0000_1004,
  localparam logic [31:0] LPARA_TGT_TX_HEAD_ADDR = 32'h0000_1008,
  localparam logic [31:0] LPARA_FULL_STROBE = 32'd15
) (
  // APB4 input interface
  input  wire         i_apb_psel,
  input  wire         i_apb_penable,
  input  wire         i_apb_pwrite,
  input  wire  [15:0] i_apb_paddr,
  input  wire  [31:0] i_apb_pwdata,
  input  wire  [3:0]  i_apb_pstrb,
  input  wire  [2:0]  i_apb_pprot,

  // Generated CSR APB interface
  output logic        o_csr_psel,
  output logic        o_csr_penable,
  output logic        o_csr_pwrite,
  output logic [15:0] o_csr_paddr,
  output logic [31:0] o_csr_pwdata,
  output logic [3:0]  o_csr_pstrb,
  output logic [2:0]  o_csr_pprot,
  input  wire         i_csr_pready,
  input  wire  [31:0] i_csr_prdata,
  input  wire         i_csr_pslverr,

  // FIFO status and data
  input  wire         i_tx_full,
  input  wire         i_rx_empty,
  input  wire  [31:0] i_rx_data,
  input  wire         i_role_target,
  input  wire         i_tgt_cs_active,
  input  wire         i_tgt_tx_head_full,

  // FIFO side effects
  output logic        o_tx_push,
  output logic [31:0] o_tx_data,
  output logic        o_rx_pop,
  output logic        o_tgt_tx_head_push,
  output logic [31:0] o_tgt_tx_head_data,

  // APB4 response interface
  output logic        o_apb_pready,
  output logic [31:0] o_apb_prdata,
  output logic        o_apb_pslverr
);

  // Decode and complete one APB transfer without changing FIFO state on error.
  always_comb begin : p_com_apb_decode
    o_csr_psel    = 1'b0;
    o_csr_penable = i_apb_penable;
    o_csr_pwrite  = i_apb_pwrite;
    o_csr_paddr   = i_apb_paddr;
    o_csr_pwdata  = i_apb_pwdata;
    o_csr_pstrb   = i_apb_pstrb;
    o_csr_pprot   = i_apb_pprot;
    o_tx_push     = 1'b0;
    o_tx_data     = i_apb_pwdata;
    o_rx_pop      = 1'b0;
    o_tgt_tx_head_push = 1'b0;
    o_tgt_tx_head_data = i_apb_pwdata;
    o_apb_pready  = 1'b0;
    o_apb_prdata  = 32'd0;
    o_apb_pslverr = 1'b0;

    if (i_apb_psel) begin
      casez (i_apb_paddr)
        16'h0???: begin
          o_csr_psel    = 1'b1;
          o_apb_pready  = i_csr_pready;
          o_apb_prdata  = i_csr_prdata;
          o_apb_pslverr = i_csr_pslverr;
        end
        LPARA_TX_FIFO_ADDR[15:0]: begin
          o_apb_pready = 1'b1;
          if (i_apb_pwrite) begin
            if ((i_apb_pstrb != LPARA_FULL_STROBE[3:0]) || i_tx_full) begin
              o_apb_pslverr = 1'b1;
            end else if (i_apb_penable) begin
              o_tx_push = 1'b1;
            end
          end else begin
            o_apb_pslverr = 1'b1;
          end
        end
        LPARA_RX_FIFO_ADDR[15:0]: begin
          o_apb_pready = 1'b1;
          if (!i_apb_pwrite) begin
            o_apb_prdata = i_rx_data;
            if (i_rx_empty) begin
              o_apb_pslverr = 1'b1;
            end else if (i_apb_penable) begin
              o_rx_pop = 1'b1;
            end
          end else begin
            o_apb_pslverr = 1'b1;
          end
        end
        LPARA_TGT_TX_HEAD_ADDR[15:0]: begin
          o_apb_pready = 1'b1;
          if (i_apb_pwrite) begin
            if ((i_apb_pstrb != LPARA_FULL_STROBE[3:0]) || i_tgt_tx_head_full ||
                i_tgt_cs_active || !i_role_target) begin
              o_apb_pslverr = 1'b1;
            end else if (i_apb_penable) begin
              o_tgt_tx_head_push = 1'b1;
            end
          end else begin
            o_apb_prdata[0] = i_tgt_tx_head_full;
          end
        end
        default: begin
          o_apb_pready  = 1'b1;
          o_apb_pslverr = 1'b1;
        end
      endcase
    end
  end

endmodule
