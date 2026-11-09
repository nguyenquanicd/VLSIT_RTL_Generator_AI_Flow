/*
 * Project      : QSPI_Controller
 * Author       : Nguyen Quan (user)
 * AI Flow      : VLSIT RTL Generator AI Automation Flow
 * AI Flow Page : https://github.com/nguyenquanicd/VLSIT_RTL_Generator_AI_Model
 * Date         : 2026-11-02
 * Description  : AXI4 subordinate for read-only XIP. It validates requests, reports write errors,
 *                and exchanges one read burst at a time with the controller-side request path.
 */
`timescale 1ns/1ps

module m_qspi_axi_xip #(
  // Parameter Description: AXI4 address width.
  // Parameter values: 32 through 64; default is 32.
  // Parameter unit: bit
  parameter logic [31:0] PARA_AXI_ADDR_W = 32'd32,
  // Parameter Description: AXI4 data width.
  // Parameter values: 32, 64 or 128; default is 32.
  // Parameter unit: bit
  parameter logic [31:0] PARA_AXI_DATA_W = 32'd32,
  // Parameter Description: AXI4 transaction ID width.
  // Parameter values: 1 through 16; default is 1.
  // Parameter unit: bit
  parameter logic [31:0] PARA_AXI_ID_W = 32'd1,
  // Parameter Description: maximum accepted XIP read burst length.
  // Parameter values: 1 through 16 beats; default is 16.
  // Parameter unit: beat count
  parameter logic [31:0] PARA_AXI_MAX_BURST = 32'd16,
  // Parameter Description: base byte address of the XIP window.
  // Parameter values: 32-bit byte address; default is 0.
  // Parameter unit: byte address
  parameter logic [31:0] PARA_XIP_BASE_ADDR = 32'd0,
  // Parameter Description: size of the XIP window; zero disables XIP.
  // Parameter values: 0 through 0xFFFFFFFF bytes; default is 0.
  // Parameter unit: byte
  parameter logic [31:0] PARA_XIP_SIZE_BYTES = 32'd0,
  localparam logic [31:0] LPARA_AXI_BURST_INCR = 32'h0000_0001,
  localparam logic [31:0] LPARA_AXI_RESP_SLVERR = 32'h0000_0002,
  localparam logic [31:0] LPARA_AXI_SIZE_BYTE = 32'd0,
  localparam logic [31:0] LPARA_AXI_SIZE_HALF = 32'd1,
  localparam logic [31:0] LPARA_AXI_SIZE_WORD = 32'd2,
  localparam logic [31:0] LPARA_PAGE_LSB = 32'd12,
  localparam logic [31:0] LPARA_TRANSFER_EXT_W = 32'd16,
  localparam logic [31:0] LPARA_AXI_ADDR_W_MINUS_ONE = 32'd31
) (
  // AXI clock and reset
  input  wire                          i_clk_axi,
  input  wire                          i_rst_n_axi,

  // AXI4 write address channel
  input  wire  [PARA_AXI_ADDR_W-1:0]   i_axi_awaddr,
  input  wire  [PARA_AXI_ID_W-1:0]     i_axi_awid,
  input  wire  [7:0]                   i_axi_awlen,
  input  wire  [2:0]                   i_axi_awsize,
  input  wire  [1:0]                   i_axi_awburst,
  input  wire                          i_axi_awlock,
  input  wire  [3:0]                   i_axi_awcache,
  input  wire  [2:0]                   i_axi_awprot,
  input  wire  [3:0]                   i_axi_awqos,
  input  wire  [3:0]                   i_axi_awregion,
  input  wire                          i_axi_awvalid,
  output logic                         o_axi_awready,

  // AXI4 write data channel
  input  wire  [PARA_AXI_DATA_W-1:0]   i_axi_wdata,
  input  wire  [PARA_AXI_DATA_W/8-1:0] i_axi_wstrb,
  input  wire                          i_axi_wlast,
  input  wire                          i_axi_wvalid,
  output logic                         o_axi_wready,

  // AXI4 write response channel
  output logic [PARA_AXI_ID_W-1:0]     o_axi_bid,
  output logic [1:0]                   o_axi_bresp,
  output logic                         o_axi_bvalid,
  input  wire                          i_axi_bready,

  // AXI4 read address channel
  input  wire  [PARA_AXI_ADDR_W-1:0]   i_axi_araddr,
  input  wire  [PARA_AXI_ID_W-1:0]     i_axi_arid,
  input  wire  [7:0]                   i_axi_arlen,
  input  wire  [2:0]                   i_axi_arsize,
  input  wire  [1:0]                   i_axi_arburst,
  input  wire                          i_axi_arlock,
  input  wire  [3:0]                   i_axi_arcache,
  input  wire  [2:0]                   i_axi_arprot,
  input  wire  [3:0]                   i_axi_arqos,
  input  wire  [3:0]                   i_axi_arregion,
  input  wire                          i_axi_arvalid,
  output logic                         o_axi_arready,

  // AXI4 read response channel
  output logic [PARA_AXI_ID_W-1:0]     o_axi_rid,
  output logic [PARA_AXI_DATA_W-1:0]   o_axi_rdata,
  output logic [1:0]                   o_axi_rresp,
  output logic                         o_axi_rlast,
  output logic                         o_axi_rvalid,
  input  wire                          i_axi_rready,

  // XIP configuration and controller availability
  input  wire                          i_xip_en,
  input  wire                          i_ctrl_en,
  input  wire                          i_controller_role,
  input  wire                          i_ctrl_cpol,
  input  wire                          i_ctrl_cpha,
  input  wire                          i_ctrl_lsb_first,
  input  wire  [15:0]                  i_ctrl_divisor,
  input  wire  [7:0]                   i_cs_setup,
  input  wire  [7:0]                   i_cs_hold,
  input  wire  [7:0]                   i_cs_high,
  input  wire  [3:0]                   i_cs_sel,
  input  wire  [2:0]                   i_xip_cfg_format,
  input  wire  [1:0]                   i_xip_cfg_addr_bytes,
  input  wire  [7:0]                   i_xip_cfg_dummy_cyc,
  input  wire  [7:0]                   i_xip_cfg_opcode,
  input  wire  [4:0]                   i_xip_mode_count,
  input  wire  [7:0]                   i_xip_mode_value,

  // XIP request path to the controller-domain CDC
  output logic                         o_xip_req_valid,
  input  wire                          i_xip_req_ready,
  output logic [PARA_AXI_ADDR_W-1:0]   o_xip_req_addr,
  output logic [7:0]                   o_xip_req_len,
  output logic [2:0]                   o_xip_req_size,
  output logic [PARA_AXI_ID_W-1:0]     o_xip_req_id,
  output logic [129:0]                 o_xip_req_cmd_data,

  // Accepted burst metadata for the AXI-side response packer
  output logic [PARA_AXI_ADDR_W-1:0]   o_xip_rsp_addr,
  output logic [7:0]                   o_xip_rsp_len,
  output logic [2:0]                   o_xip_rsp_size,
  output logic                         o_xip_rsp_active,

  // XIP response path from the controller-domain CDC
  input  wire                          i_xip_rsp_valid,
  output logic                         o_xip_rsp_ready,
  input  wire  [PARA_AXI_DATA_W-1:0]   i_xip_rsp_data,
  input  wire  [1:0]                   i_xip_rsp_resp,
  input  wire                          i_xip_rsp_last
);

  // One outstanding read burst and one write-error response may be tracked here.
  logic reg_rd_active;
  logic reg_req_pending;
  logic reg_err_active;
  logic [8:0] reg_err_beats_left;
  logic [PARA_AXI_ID_W-1:0] reg_rd_id;
  logic [PARA_AXI_ADDR_W-1:0] reg_req_addr;
  logic [PARA_AXI_ADDR_W-1:0] reg_rsp_addr;
  logic [7:0] reg_req_len;
  logic [2:0] reg_req_size;
  logic [129:0] reg_req_cmd_data;
  logic reg_wr_active;
  logic [8:0] reg_wr_beats_left;
  logic [PARA_AXI_ID_W-1:0] reg_wr_id;
  logic reg_bvalid;
  logic [PARA_AXI_ADDR_W:0] w_ar_end_addr;
  logic [PARA_AXI_ADDR_W:0] w_xip_limit;
  logic [PARA_AXI_ADDR_W:0] w_ar_start_ext;
  logic [16:0] w_ar_transfer_bytes;
  logic w_ar_aligned;
  logic w_ar_page_ok;
  logic w_ar_range_ok;
  logic w_ar_profile_ok;
  logic w_ar_bad;
  logic w_r_err_handshake;
  logic w_r_data_handshake;
  logic w_w_handshake;

  // Validate full burst geometry before issuing any controller request.
  always_comb begin : p_com_axi_validate
    w_ar_start_ext = {1'b0, i_axi_araddr};
    w_ar_transfer_bytes = ({9'd0, i_axi_arlen} + 17'd1) << i_axi_arsize;
    w_ar_end_addr  = w_ar_start_ext +
                     {{(PARA_AXI_ADDR_W-LPARA_TRANSFER_EXT_W){1'b0}}, w_ar_transfer_bytes} - 1'b1;
    w_xip_limit    = {{(PARA_AXI_ADDR_W-LPARA_AXI_ADDR_W_MINUS_ONE){1'b0}}, PARA_XIP_BASE_ADDR} +
                     {{(PARA_AXI_ADDR_W-LPARA_AXI_ADDR_W_MINUS_ONE){1'b0}}, PARA_XIP_SIZE_BYTES};
    w_ar_aligned   = 1'b0;
    w_ar_page_ok   = 1'b0;
    w_ar_range_ok  = 1'b0;
    w_ar_profile_ok = 1'b0;
    w_ar_bad       = 1'b1;

    case (i_axi_arsize)
      LPARA_AXI_SIZE_BYTE[2:0]: w_ar_aligned = 1'b1;
      LPARA_AXI_SIZE_HALF[2:0]: w_ar_aligned = (i_axi_araddr[0] == 1'b0);
      LPARA_AXI_SIZE_WORD[2:0]: w_ar_aligned = (i_axi_araddr[1:0] == 2'b00);
      default:             w_ar_aligned = 1'b0;
    endcase

    w_ar_page_ok = (w_ar_start_ext[PARA_AXI_ADDR_W:LPARA_PAGE_LSB] ==
                    w_ar_end_addr[PARA_AXI_ADDR_W:LPARA_PAGE_LSB]);
    w_ar_range_ok = (PARA_XIP_SIZE_BYTES != 32'd0) &&
                    (w_ar_start_ext >= {{(PARA_AXI_ADDR_W-LPARA_AXI_ADDR_W_MINUS_ONE){1'b0}}, PARA_XIP_BASE_ADDR}) &&
                    (w_ar_end_addr < w_xip_limit);
    w_ar_profile_ok = (i_axi_arburst == LPARA_AXI_BURST_INCR[1:0]) &&
                       (({24'd0, i_axi_arlen} + 32'd1) <= PARA_AXI_MAX_BURST) &&
                       (i_axi_arsize <= LPARA_AXI_SIZE_WORD[2:0]) &&
                       !i_axi_arlock &&
                       w_ar_aligned && w_ar_page_ok && w_ar_range_ok &&
                       i_xip_en && i_ctrl_en && i_controller_role;
    w_ar_bad = !w_ar_profile_ok;
  end

  // AXI output decode is registered-state based; only CDC queue response signals pass through.
  always_comb begin : p_com_axi_out
    o_axi_awready = !reg_wr_active && !reg_bvalid;
    o_axi_wready  = reg_wr_active;
    o_axi_bid     = reg_wr_id;
    o_axi_bresp   = LPARA_AXI_RESP_SLVERR[1:0];
    o_axi_bvalid  = reg_bvalid;
    o_axi_arready = !reg_rd_active && !reg_err_active;
    o_axi_rid     = reg_rd_id;
    o_axi_rdata   = '0;
    o_axi_rresp   = LPARA_AXI_RESP_SLVERR[1:0];
    o_axi_rlast   = 1'b0;
    o_axi_rvalid  = 1'b0;
    o_xip_req_valid = reg_req_pending;
    o_xip_req_addr  = reg_req_addr;
    o_xip_req_len   = reg_req_len;
    o_xip_req_size  = reg_req_size;
    o_xip_req_id    = reg_rd_id;
    o_xip_req_cmd_data = reg_req_cmd_data;
    o_xip_rsp_addr = reg_rsp_addr;
    o_xip_rsp_len = reg_req_len;
    o_xip_rsp_size = reg_req_size;
    o_xip_rsp_active = reg_rd_active;
    o_xip_rsp_ready = 1'b0;
    w_r_err_handshake  = 1'b0;
    w_r_data_handshake = 1'b0;
    w_w_handshake      = 1'b0;

    if (reg_err_active) begin
      o_axi_rvalid = 1'b1;
      o_axi_rlast = (reg_err_beats_left == 9'd1);
      w_r_err_handshake = i_axi_rready;
    end else if (reg_rd_active && !reg_req_pending) begin
      o_axi_rdata = i_xip_rsp_data;
      o_axi_rresp = i_xip_rsp_resp;
      o_axi_rlast = i_xip_rsp_last;
      o_axi_rvalid = i_xip_rsp_valid;
      o_xip_rsp_ready = i_axi_rready;
      w_r_data_handshake = i_xip_rsp_valid && i_axi_rready;
    end

    w_w_handshake = reg_wr_active && i_axi_wvalid;
  end

  // Hold AXI channel state until handshakes complete; writes are drained then answered SLVERR.
  always_ff @(posedge i_clk_axi, negedge i_rst_n_axi) begin : p_ff_axi_xip
    if (!i_rst_n_axi) begin
      reg_rd_active      <= 1'b0;
      reg_req_pending      <= 1'b0;
      reg_err_active       <= 1'b0;
      reg_err_beats_left   <= 9'd0;
      reg_rd_id          <= '0;
      reg_req_addr         <= '0;
      reg_rsp_addr         <= '0;
      reg_req_len          <= 8'd0;
      reg_req_size         <= 3'd0;
      reg_req_cmd_data <= '0;
      reg_wr_active     <= 1'b0;
      reg_wr_beats_left <= 9'd0;
      reg_wr_id         <= '0;
      reg_bvalid           <= 1'b0;
    end else begin
      if (i_axi_arvalid && o_axi_arready) begin
        reg_rd_id <= i_axi_arid;
        if (w_ar_bad) begin
          reg_err_active <= 1'b1;
          reg_err_beats_left <= {1'b0, i_axi_arlen} + 9'd1;
        end else begin
          reg_rd_active <= 1'b1;
          reg_req_pending <= 1'b1;
          reg_req_addr <= i_axi_araddr - PARA_XIP_BASE_ADDR[PARA_AXI_ADDR_W-1:0];
          reg_req_len <= i_axi_arlen;
          reg_req_size <= i_axi_arsize;
          reg_rsp_addr <= i_axi_araddr;
          reg_req_cmd_data <= {
            i_xip_cfg_format,
            i_ctrl_cpol,
            i_ctrl_cpha,
            i_ctrl_lsb_first,
            i_ctrl_divisor,
            i_cs_setup,
            i_cs_hold,
            i_cs_high,
            i_cs_sel,
            i_xip_cfg_opcode,
            i_axi_araddr[31:0] - PARA_XIP_BASE_ADDR,
            i_xip_cfg_addr_bytes,
            i_xip_mode_value,
            i_xip_mode_count,
            i_xip_cfg_dummy_cyc,
            1'b1,
            w_ar_transfer_bytes[15:0]
          };
        end
      end

      if (reg_req_pending && i_xip_req_ready)
        reg_req_pending <= 1'b0;

      if (w_r_err_handshake) begin
        if (reg_err_beats_left == 9'd1) begin
          reg_err_active <= 1'b0;
          reg_err_beats_left <= 9'd0;
        end else begin
          reg_err_beats_left <= reg_err_beats_left - 9'd1;
        end
      end

      if (w_r_data_handshake && i_xip_rsp_last)
        reg_rd_active <= 1'b0;

      if (i_axi_awvalid && o_axi_awready) begin
        reg_wr_active <= 1'b1;
        reg_wr_id <= i_axi_awid;
        reg_wr_beats_left <= {1'b0, i_axi_awlen} + 9'd1;
      end

      if (w_w_handshake) begin
        if (i_axi_wlast || (reg_wr_beats_left == 9'd1)) begin
          reg_wr_active <= 1'b0;
          reg_wr_beats_left <= 9'd0;
          reg_bvalid <= 1'b1;
        end else begin
          reg_wr_beats_left <= reg_wr_beats_left - 9'd1;
        end
      end

      if (reg_bvalid && i_axi_bready)
        reg_bvalid <= 1'b0;
    end
  end

endmodule
