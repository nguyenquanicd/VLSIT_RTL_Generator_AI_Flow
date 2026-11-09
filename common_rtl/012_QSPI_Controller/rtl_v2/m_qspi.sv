/*
 * Project      : QSPI_Controller
 * Author       : Nguyen Quan (user)
 * AI Flow      : VLSIT RTL Generator AI Automation Flow
 * AI Flow Page : https://github.com/nguyenquanicd/VLSIT_RTL_Generator_AI_Model
 * Date         : 2026-11-03
 * Description  : Structural top for the APB-configured QSPI controller/target, AXI XIP path,
 *                CDC queues, role-specific engines, and shared serial pads (DEC-014, DEC-018).
 */
`timescale 1ns/1ps

module m_qspi #(
  // Parameter Description: AXI4 address width for the memory-mapped XIP interface.
  // Parameter values: 32 through 64; default is 32.
  // Parameter unit: bit
  parameter logic [31:0] PARA_AXI_ADDR_W = 32'd32,
  // Parameter Description: AXI4 data width for the memory-mapped XIP interface.
  // Parameter values: 32, 64, or 128; default is 32.
  // Parameter unit: bit
  parameter logic [31:0] PARA_AXI_DATA_W = 32'd32,
  // Parameter Description: AXI4 transaction ID width.
  // Parameter values: 1 through 16; default is 1.
  // Parameter unit: bit
  parameter logic [31:0] PARA_AXI_ID_W = 32'd1,
  // Parameter Description: maximum number of beats in one accepted XIP read burst.
  // Parameter values: 1 through 16; default is 16.
  // Parameter unit: beat count
  parameter logic [31:0] PARA_AXI_MAX_BURST = 32'd16,
  // Parameter Description: byte address at the base of the XIP window.
  // Parameter values: 32-bit byte address; default is 0.
  // Parameter unit: byte address
  parameter logic [31:0] PARA_XIP_BASE_ADDR = 32'd0,
  // Parameter Description: number of byte addresses exposed in the XIP window; zero disables it.
  // Parameter values: 0 through 0xFFFFFFFF; default is 0.
  // Parameter unit: byte
  parameter logic [31:0] PARA_XIP_SIZE_BYTES = 32'd0,
  // Parameter Description: number of controller chip-select outputs.
  // Parameter values: 1 through 16; default is 1.
  // Parameter unit: count
  parameter logic [31:0] PARA_NUM_CS = 32'd1,
  // Parameter Description: entries in each TX, RX, and XIP response FIFO.
  // Parameter values: power of two, minimum 2; default is 16.
  // Parameter unit: count
  parameter logic [31:0] PARA_FIFO_DEPTH = 32'd16,
  localparam logic [31:0] LPARA_XIP_LEN_W = 32'd8,
  localparam logic [31:0] LPARA_XIP_SIZE_W = 32'd3,
  localparam logic [31:0] LPARA_XIP_REQ_DATA_W = 32'd130 + PARA_AXI_ADDR_W +
                                                LPARA_XIP_LEN_W + LPARA_XIP_SIZE_W + PARA_AXI_ID_W,
  localparam logic [31:0] LPARA_CFG_AXI_W = 32'd84,
  localparam logic [31:0] LPARA_CTRL_CFG_W = 32'd2,
  localparam logic [31:0] LPARA_STS_W = 32'd3,
  localparam logic [31:0] LPARA_CTRL_EVENT_W = 32'd4,
  localparam logic [31:0] LPARA_FIFO_DATA_W = 32'd32,
  localparam logic [31:0] LPARA_ERR_CODE_CMD = 32'd1,
  localparam logic [31:0] LPARA_ERR_CODE_TX = 32'd2,
  localparam logic [31:0] LPARA_ERR_CODE_RX = 32'd3
) (
  // APB, AXI, controller, and target clocks/resets
  input  wire                          i_clk_apb,
  input  wire                          i_rst_n_apb,
  input  wire                          i_clk_axi,
  input  wire                          i_rst_n_axi,
  input  wire                          i_clk_serial,
  input  wire                          i_rst_n_serial,

  // APB4 CSR and data-window subordinate interface
  input  wire                          i_apb_psel,
  input  wire                          i_apb_penable,
  input  wire                          i_apb_pwrite,
  input  wire  [15:0]                  i_apb_paddr,
  input  wire  [31:0]                  i_apb_pwdata,
  input  wire  [3:0]                   i_apb_pstrb,
  input  wire  [2:0]                   i_apb_pprot,
  output logic                         o_apb_pready,
  output logic [31:0]                  o_apb_prdata,
  output logic                         o_apb_pslverr,

  // AXI4 XIP write-address channel
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

  // AXI4 XIP write-data and response channels
  input  wire  [PARA_AXI_DATA_W-1:0]   i_axi_wdata,
  input  wire  [PARA_AXI_DATA_W/8-1:0] i_axi_wstrb,
  input  wire                          i_axi_wlast,
  input  wire                          i_axi_wvalid,
  output logic                         o_axi_wready,
  output logic [PARA_AXI_ID_W-1:0]     o_axi_bid,
  output logic [1:0]                   o_axi_bresp,
  output logic                         o_axi_bvalid,
  input  wire                          i_axi_bready,

  // AXI4 XIP read-address channel
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

  // AXI4 XIP read-response channel
  output logic [PARA_AXI_ID_W-1:0]     o_axi_rid,
  output logic [PARA_AXI_DATA_W-1:0]   o_axi_rdata,
  output logic [1:0]                   o_axi_rresp,
  output logic                         o_axi_rlast,
  output logic                         o_axi_rvalid,
  input  wire                          i_axi_rready,

  // Controller and target SPI pins
  output logic                         o_clk_spi_ctrl,
  input  wire                          i_clk_spi_tgt,
  input  wire                          i_spi_cs_tgt_n,
  input  wire  [3:0]                   i_spi_io_i,
  output logic [3:0]                   o_spi_io_o,
  output logic [3:0]                   o_spi_io_oe,
  output logic [PARA_NUM_CS-1:0]       o_spi_cs_ctrl_n,

  // Combined enabled interrupt output
  output logic                         o_int_qspi
);

  // Interconnect declarations: synchronized local resets.
  logic w_rst_n_apb;
  logic w_rst_n_axi;
  logic w_rst_n_serial;
  logic w_rst_n_target;

  // Interconnect declarations: APB decode and generated CSR interface.
  logic w_csr_psel;
  logic w_csr_penable;
  logic w_csr_pwrite;
  logic [15:0] w_csr_paddr;
  logic [31:0] w_csr_pwdata;
  logic [3:0] w_csr_pstrb;
  logic [2:0] w_csr_pprot;
  logic w_csr_pready;
  logic [31:0] w_csr_prdata;
  logic w_csr_pslverr;
  logic w_apb_tx_push;
  logic [31:0] w_apb_tx_data;
  logic w_apb_rx_pop;
  logic w_apb_tgt_head_push;
  logic [31:0] w_apb_tgt_head_data;
  logic [31:0] w_apb_rx_data;
  logic w_apb_tx_full;
  logic w_apb_rx_empty;
  logic w_tgt_cs_active_apb;

  // Interconnect declarations: CSR configuration, command, status, and interrupts.
  logic w_qspi_ctrl_lsb_first;
  logic w_qspi_ctrl_cpha;
  logic w_qspi_ctrl_cpol;
  logic w_qspi_ctrl_role;
  logic w_qspi_ctrl_en;
  logic [15:0] w_qspi_clkdiv_divisor;
  logic [5:0] w_qspi_frame_word_len_m1;
  logic [7:0] w_qspi_xip_cfg_dummy_cyc;
  logic [2:0] w_qspi_xip_cfg_format;
  logic [1:0] w_qspi_xip_cfg_addr_bytes;
  logic [7:0] w_qspi_xip_cfg_opcode;
  logic w_qspi_xip_cfg_en;
  logic [4:0] w_qspi_xip_mode_count;
  logic [7:0] w_qspi_xip_mode_value;
  logic w_qspi_cmd_start;
  logic w_qspi_cmd_rd;
  logic [7:0] w_qspi_cmd_dummy_cyc;
  logic [1:0] w_qspi_cmd_addr_bytes;
  logic [2:0] w_qspi_cmd_format;
  logic [7:0] w_qspi_cmd_opcode;
  logic [31:0] w_qspi_addr_addr;
  logic [15:0] w_qspi_len_byte_count;
  logic [2:0] w_qspi_sts_err_code;
  logic w_qspi_sts_rx_empty;
  logic w_qspi_sts_rx_full;
  logic w_qspi_sts_tx_empty;
  logic w_qspi_sts_tx_full;
  logic w_qspi_sts_busy;
  logic w_irq_raw_fl_err;
  logic w_irq_raw_rx_err;
  logic w_irq_raw_tx_err;
  logic w_irq_raw_done;
  logic w_irq_en_fl_err;
  logic w_irq_en_rx_err;
  logic w_irq_en_tx_err;
  logic w_irq_en_done;
  logic w_irq_inj_fl_err;
  logic w_irq_inj_rx_err;
  logic w_irq_inj_tx_err;
  logic w_irq_inj_done;
  logic [7:0] w_cs_cfg_cs_high;
  logic [7:0] w_cs_cfg_cs_hold;
  logic [7:0] w_cs_cfg_cs_setup;
  logic [3:0] w_cs_cfg_cs_sel;
  logic w_irq_hw_we_fl_err;
  logic w_irq_hw_we_rx_err;
  logic w_irq_hw_we_tx_err;
  logic w_irq_hw_we_done;
  logic w_tie_protect_en;
  logic w_tie_slverr_en;

  // Interconnect declarations: role-specific TX and RX asynchronous FIFOs.
  logic w_ctrl_tx_full;
  logic w_ctrl_tx_empty;
  logic [31:0] w_ctrl_tx_data;
  logic w_ctrl_rx_full;
  logic w_ctrl_rx_empty;
  logic [31:0] w_ctrl_rx_data;
  logic w_tgt_tx_full;
  logic w_tgt_tx_empty;
  logic [31:0] w_tgt_tx_data;
  logic w_tgt_rx_full;
  logic w_tgt_rx_empty;
  logic [31:0] w_tgt_rx_data;
  logic w_tgt_head_full;
  logic [31:0] w_tgt_head_data;
  logic w_tgt_head_token;
  logic w_ctrl_tx_pop;
  logic w_ctrl_rx_push;
  logic [31:0] w_ctrl_rx_push_data;
  logic w_tgt_tx_pop;
  logic w_tgt_rx_push;
  logic [31:0] w_tgt_rx_push_data;
  logic w_tgt_head_pop;

  // Interconnect declarations: synchronized role and status configuration.
  logic [LPARA_CFG_AXI_W-1:0] w_cfg_csr_bus;
  logic [LPARA_CFG_AXI_W-1:0] w_cfg_axi_bus;
  logic [LPARA_CTRL_CFG_W-1:0] w_cfg_serial_bus;
  logic [1:0] w_cfg_serial_bus_sync;
  logic w_tgt_cs_active_bus_apb;
  logic w_xip_active_apb_bus;
  logic [LPARA_STS_W-1:0] w_ctrl_sts_src;
  logic [LPARA_STS_W-1:0] w_ctrl_sts_apb;
  logic [LPARA_STS_W-1:0] w_tgt_sts_src;
  logic [LPARA_STS_W-1:0] w_tgt_sts_apb;
  logic w_xip_active_apb;
  logic w_ctrl_en_serial;
  logic w_ctrl_role_serial;
  logic w_tgt_en_cfg;
  logic w_tgt_cpha_cfg;
  logic w_tgt_lsb_first_cfg;
  logic [5:0] w_tgt_word_bits_cfg;
  logic w_clk_tgt_sample;
  logic w_clk_tgt_shift;
  logic [5:0] w_frame_word_bits;

  // Interconnect declarations: indirect request and completion CDC.
  logic w_ind_cmd_start_hw_we;
  logic w_ind_cmd_start_hw_data;
  logic w_ind_busy_apb;
  logic w_ind_done_event_apb;
  logic w_ind_err_event_apb;
  logic w_ind_cmd_valid_apb;
  logic w_ind_cmd_ready_apb;
  logic [129:0] w_ind_cmd_data_apb;
  logic w_ind_cmd_valid_serial;
  logic w_ind_cmd_ready_serial;
  logic [129:0] w_ind_cmd_data_serial;
  logic w_ind_rsp_valid_serial;
  logic w_ind_rsp_ready_serial;
  logic [1:0] w_ind_rsp_data_serial;
  logic w_ind_rsp_valid_apb;
  logic w_ind_rsp_ready_apb;
  logic [1:0] w_ind_rsp_data_apb;

  // Interconnect declarations: AXI XIP request and response CDC.
  logic w_xip_req_valid_axi;
  logic w_xip_req_ready_axi;
  logic [PARA_AXI_ADDR_W-1:0] w_xip_req_addr_axi;
  logic [LPARA_XIP_LEN_W-1:0] w_xip_req_len_axi;
  logic [LPARA_XIP_SIZE_W-1:0] w_xip_req_size_axi;
  logic [PARA_AXI_ID_W-1:0] w_xip_req_id_axi;
  logic [129:0] w_xip_req_cmd_axi;
  logic [LPARA_XIP_REQ_DATA_W-1:0] w_xip_req_bundle_axi;
  logic [PARA_AXI_ADDR_W-1:0] w_xip_rsp_addr_axi;
  logic [LPARA_XIP_LEN_W-1:0] w_xip_rsp_len_axi;
  logic [LPARA_XIP_SIZE_W-1:0] w_xip_rsp_size_axi;
  logic w_xip_rsp_active_axi;
  logic w_xip_rsp_valid_axi;
  logic w_xip_rsp_ready_axi;
  logic [PARA_AXI_DATA_W-1:0] w_xip_rsp_data_axi;
  logic [1:0] w_xip_rsp_resp_axi;
  logic w_xip_rsp_last_axi;
  logic w_xip_req_valid_serial;
  logic w_xip_req_ready_serial;
  logic [LPARA_XIP_REQ_DATA_W-1:0] w_xip_req_bundle_serial;
  logic w_xip_rsp_push_serial;
  logic [35:0] w_xip_rsp_data_serial;
  logic w_xip_rsp_full_serial;
  logic [35:0] w_xip_rsp_fifo_data_axi;
  logic w_xip_rsp_empty_axi;
  logic w_xip_rsp_fifo_pop_axi;

  // Interconnect declarations: serial arbiter and controller engine.
  logic w_arb_xip_valid;
  logic w_arb_xip_ready;
  logic [129:0] w_arb_xip_data;
    logic w_arb_cmd_valid;
  logic w_arb_cmd_ready;
  logic w_arb_owner_xip;
  logic [129:0] w_arb_cmd_data;
  logic w_arb_busy;
  logic w_arb_done_xip;
  logic w_arb_done_ind;
  logic w_arb_err_xip;
  logic w_arb_err_ind;
  logic w_eng_busy;
  logic w_eng_done;
  logic w_eng_fl_err;
  logic w_eng_tx_err;
  logic w_eng_rx_err;
  logic w_eng_rx_push;
  logic [31:0] w_eng_rx_data;
  logic w_eng_rx_full;
  logic w_xip_engine_rx_full;
  logic [2:0] w_cmd_format;
  logic w_cmd_cpol;
  logic w_cmd_cpha;
  logic w_cmd_lsb_first;
  logic [15:0] w_cmd_divisor;
  logic [7:0] w_cmd_cs_setup;
  logic [7:0] w_cmd_cs_hold;
  logic [7:0] w_cmd_cs_high;
  logic [3:0] w_cmd_cs_sel;
  logic [7:0] w_cmd_opcode;
  logic [31:0] w_cmd_addr;
  logic [1:0] w_cmd_addr_bytes;
  logic [7:0] w_cmd_mode_value;
  logic [4:0] w_cmd_mode_count;
  logic [7:0] w_cmd_dummy_cycles;
  logic w_cmd_rd;
  logic [15:0] w_cmd_byte_count;
  logic [3:0] w_ctrl_io_o;
  logic [3:0] w_ctrl_io_oe;
  logic [3:0] w_tgt_io_o;
  logic [3:0] w_tgt_io_oe;
  logic w_tgt_busy;
  logic w_tgt_frame_done;
  logic w_tgt_tx_err_tgl;
  logic w_tgt_rx_err_tgl;
  logic w_tgt_rx_partial_err;
  logic [3:0] w_ctrl_event_src;
  logic [3:0] w_ctrl_event_apb;
  logic w_tgt_tx_err_apb;
  logic w_tgt_rx_err_apb;

  // Interconnect declarations: selected APB-domain status and interrupt events.
  logic w_selected_tx_empty;
  logic w_selected_rx_full;
  logic w_serial_busy_apb;
  logic w_target_busy_apb;
  logic w_sticky_done_event;
  logic w_sticky_tx_err_event;
  logic w_sticky_rx_err_event;
  logic w_sticky_fl_err_event;

  // Configuration buses remain stable until software enables or starts the related operation.
  assign w_cfg_csr_bus = {
    w_qspi_ctrl_en,
    w_qspi_ctrl_role,
    w_qspi_ctrl_cpol,
    w_qspi_ctrl_cpha,
    w_qspi_ctrl_lsb_first,
    w_qspi_clkdiv_divisor,
    w_cs_cfg_cs_setup,
    w_cs_cfg_cs_hold,
    w_cs_cfg_cs_high,
    w_cs_cfg_cs_sel,
    w_qspi_xip_cfg_en,
    w_qspi_xip_cfg_format,
    w_qspi_xip_cfg_addr_bytes,
    w_qspi_xip_cfg_dummy_cyc,
    w_qspi_xip_cfg_opcode,
    w_qspi_xip_mode_count,
    w_qspi_xip_mode_value
  };
  // Decode synchronized role, frame-boundary, and activity fields.
  assign w_cfg_serial_bus = {w_qspi_ctrl_en, w_qspi_ctrl_role};
  assign w_ctrl_en_serial = w_cfg_serial_bus_sync[1];
  assign w_ctrl_role_serial = w_cfg_serial_bus_sync[0];
  assign w_tgt_cs_active_apb = w_tgt_cs_active_bus_apb;
  assign w_xip_active_apb = w_xip_active_apb_bus;
  assign w_frame_word_bits = w_qspi_frame_word_len_m1 + 6'd1;
  assign w_ctrl_sts_src = {w_eng_busy || w_arb_busy, w_ctrl_rx_full, w_ctrl_tx_empty};
  assign w_tgt_sts_src = {w_tgt_busy, w_tgt_rx_full, w_tgt_tx_empty};

  // AXI-to-serial request metadata is kept with its command in one mailbox payload.
  assign w_xip_req_bundle_axi = {
    w_xip_req_id_axi,
    w_xip_req_size_axi,
    w_xip_req_len_axi,
    w_xip_req_addr_axi,
    w_xip_req_cmd_axi
  };

  // Route controller receive words to the owner-specific destination.
  assign w_eng_rx_full = w_arb_owner_xip ? w_xip_engine_rx_full : w_ctrl_rx_full;
  assign w_ctrl_rx_push = w_eng_rx_push && !w_arb_owner_xip;
  assign w_ctrl_rx_push_data = w_eng_rx_data;

  // Select the APB-visible role-specific queue status and read data.
  assign w_apb_tx_full = w_qspi_ctrl_role ? w_tgt_tx_full : w_ctrl_tx_full;
  assign w_apb_rx_empty = w_qspi_ctrl_role ? w_tgt_rx_empty : w_ctrl_rx_empty;
  assign w_apb_rx_data = w_qspi_ctrl_role ? w_tgt_rx_data : w_ctrl_rx_data;
  assign w_selected_tx_empty = w_qspi_ctrl_role ? w_tgt_sts_apb[0] : w_ctrl_sts_apb[0];
  assign w_selected_rx_full = w_qspi_ctrl_role ? w_tgt_sts_apb[1] : w_ctrl_sts_apb[1];
  assign w_serial_busy_apb = w_ctrl_sts_apb[2];
  assign w_target_busy_apb = w_tgt_sts_apb[2];

  // Present sticky event causes using the workbook's error class encodings.
  assign w_qspi_sts_err_code = w_irq_raw_fl_err ? LPARA_ERR_CODE_CMD[2:0] :
                               w_irq_raw_tx_err ? LPARA_ERR_CODE_TX[2:0] :
                               w_irq_raw_rx_err ? LPARA_ERR_CODE_RX[2:0] : 3'd0;
  // Drive CSR FIFO and busy fields from APB-local or synchronized status values.
  assign w_qspi_sts_rx_empty = w_apb_rx_empty;
  assign w_qspi_sts_rx_full = w_selected_rx_full;
  assign w_qspi_sts_tx_empty = w_selected_tx_empty;
  assign w_qspi_sts_tx_full = w_apb_tx_full;
  assign w_qspi_sts_busy = w_ind_busy_apb || w_serial_busy_apb ||
                           w_target_busy_apb || w_xip_active_apb;

  // Combine controller and target events in the APB domain before setting sticky CSR causes.
  assign w_sticky_fl_err_event = w_ctrl_event_apb[3] || w_ind_err_event_apb;
  assign w_sticky_rx_err_event = w_ctrl_event_apb[2] || w_tgt_rx_err_apb ||
                                 w_tgt_rx_partial_err;
  // Coalesce transfer-complete events and feed sticky interrupt set inputs.
  assign w_sticky_tx_err_event = w_ctrl_event_apb[1] || w_tgt_tx_err_apb;
  assign w_sticky_done_event = w_ctrl_event_apb[0] || w_tgt_frame_done ||
                               w_ind_done_event_apb;
  // Set each generated write-one-to-clear interrupt cause from its event pulse.
  assign w_irq_hw_we_fl_err = w_sticky_fl_err_event;
  assign w_irq_hw_we_rx_err = w_sticky_rx_err_event;
  assign w_irq_hw_we_tx_err = w_sticky_tx_err_event;
  assign w_irq_hw_we_done = w_sticky_done_event;
  // IRQ injection provides a software-controlled level for interrupt-path testing.
  assign o_int_qspi = ((w_irq_raw_fl_err || w_irq_inj_fl_err) && w_irq_en_fl_err) ||
                      ((w_irq_raw_rx_err || w_irq_inj_rx_err) && w_irq_en_rx_err) ||
                      ((w_irq_raw_tx_err || w_irq_inj_tx_err) && w_irq_en_tx_err) ||
                      ((w_irq_raw_done || w_irq_inj_done) && w_irq_en_done);

  // Synchronize local resets and stable control/status fields into each receiving domain.
  m_qspi_reset_sync u_rst_sync (
    .i_clk_apb      (i_clk_apb),
    .i_rst_n_apb    (i_rst_n_apb),
    .i_clk_axi      (i_clk_axi),
    .i_rst_n_axi    (i_rst_n_axi),
    .i_clk_serial   (i_clk_serial),
    .i_rst_n_serial (i_rst_n_serial),
    .o_rst_n_apb    (w_rst_n_apb),
    .o_rst_n_axi    (w_rst_n_axi),
    .o_rst_n_serial (w_rst_n_serial),
    .o_rst_n_spi_tgt(w_rst_n_target)
  );

  m_qspi_sync_bus #(
    .PARA_SYNC_W (LPARA_CFG_AXI_W)
  ) u_cfg_sync_axi (
    .i_clk_dst   (i_clk_axi),
    .i_rst_n_dst (w_rst_n_axi),
    .i_data_src  (w_cfg_csr_bus),
    .o_data_dst  (w_cfg_axi_bus)
  );

  m_qspi_sync_bus #(
    .PARA_SYNC_W (LPARA_CTRL_CFG_W)
  ) u_cfg_sync_serial (
    .i_clk_dst   (i_clk_serial),
    .i_rst_n_dst (w_rst_n_serial),
    .i_data_src  (w_cfg_serial_bus),
    .o_data_dst  (w_cfg_serial_bus_sync)
  );

  m_qspi_sync_bus #(
    .PARA_SYNC_W (32'd1)
  ) u_tgt_cs_sync_apb (
    .i_clk_dst   (i_clk_apb),
    .i_rst_n_dst (w_rst_n_apb),
    .i_data_src  (~i_spi_cs_tgt_n),
    .o_data_dst  (w_tgt_cs_active_bus_apb)
  );

  m_qspi_sync_bus #(
    .PARA_SYNC_W (LPARA_STS_W)
  ) u_ctrl_sts_sync_apb (
    .i_clk_dst   (i_clk_apb),
    .i_rst_n_dst (w_rst_n_apb),
    .i_data_src  (w_ctrl_sts_src),
    .o_data_dst  (w_ctrl_sts_apb)
  );

  m_qspi_sync_bus #(
    .PARA_SYNC_W (LPARA_STS_W)
  ) u_tgt_sts_sync_apb (
    .i_clk_dst   (i_clk_apb),
    .i_rst_n_dst (w_rst_n_apb),
    .i_data_src  (w_tgt_sts_src),
    .o_data_dst  (w_tgt_sts_apb)
  );

  m_qspi_sync_bus #(
    .PARA_SYNC_W (32'd1)
  ) u_xip_sts_sync_apb (
    .i_clk_dst   (i_clk_apb),
    .i_rst_n_dst (w_rst_n_apb),
    .i_data_src  (w_xip_rsp_active_axi),
    .o_data_dst  (w_xip_active_apb_bus)
  );

  // Synchronize controller pulses and target error toggles to APB sticky-event inputs.
  assign w_ctrl_event_src = {w_eng_fl_err, w_eng_rx_err, w_eng_tx_err, w_eng_done};
  m_qspi_event_sync #(
    .PARA_EVENT_W (LPARA_CTRL_EVENT_W)
  ) u_ctrl_event_sync (
    .i_clk_src    (i_clk_serial),
    .i_rst_n_src  (w_rst_n_serial),
    .i_clk_dst    (i_clk_apb),
    .i_rst_n_dst  (w_rst_n_apb),
    .i_event_src  (w_ctrl_event_src),
    .o_event_dst  (w_ctrl_event_apb)
  );

  m_qspi_toggle_sync u_tgt_tx_err_sync (
    .i_clk_src       (w_clk_tgt_shift),
    .i_rst_n_src     (w_rst_n_target),
    .i_event_tgl_src (w_tgt_tx_err_tgl),
    .i_clk_dst       (i_clk_apb),
    .i_rst_n_dst     (w_rst_n_apb),
    .o_event_pulse_dst(w_tgt_tx_err_apb)
  );

  m_qspi_toggle_sync u_tgt_rx_err_sync (
    .i_clk_src       (w_clk_tgt_sample),
    .i_rst_n_src     (w_rst_n_target),
    .i_event_tgl_src (w_tgt_rx_err_tgl),
    .i_clk_dst       (i_clk_apb),
    .i_rst_n_dst     (w_rst_n_apb),
    .o_event_pulse_dst(w_tgt_rx_err_apb)
  );

  // Decode CSR, FIFO-data, and target-head APB accesses into one subordinate response.
  m_qspi_apb_decode u_apb_decode (
    .i_apb_psel          (i_apb_psel),
    .i_apb_penable       (i_apb_penable),
    .i_apb_pwrite        (i_apb_pwrite),
    .i_apb_paddr         (i_apb_paddr),
    .i_apb_pwdata        (i_apb_pwdata),
    .i_apb_pstrb         (i_apb_pstrb),
    .i_apb_pprot         (i_apb_pprot),
    .o_csr_psel          (w_csr_psel),
    .o_csr_penable       (w_csr_penable),
    .o_csr_pwrite        (w_csr_pwrite),
    .o_csr_paddr         (w_csr_paddr),
    .o_csr_pwdata        (w_csr_pwdata),
    .o_csr_pstrb         (w_csr_pstrb),
    .o_csr_pprot         (w_csr_pprot),
    .i_csr_pready        (w_csr_pready),
    .i_csr_prdata        (w_csr_prdata),
    .i_csr_pslverr       (w_csr_pslverr),
    .i_tx_full           (w_apb_tx_full),
    .i_rx_empty          (w_apb_rx_empty),
    .i_rx_data           (w_apb_rx_data),
    .i_role_target       (w_qspi_ctrl_role),
    .i_tgt_cs_active     (w_tgt_cs_active_apb),
    .i_tgt_tx_head_full  (w_tgt_head_full),
    .o_tx_push           (w_apb_tx_push),
    .o_tx_data           (w_apb_tx_data),
    .o_rx_pop            (w_apb_rx_pop),
    .o_tgt_tx_head_push  (w_apb_tgt_head_push),
    .o_tgt_tx_head_data  (w_apb_tgt_head_data),
    .o_apb_pready        (o_apb_pready),
    .o_apb_prdata        (o_apb_prdata),
    .o_apb_pslverr       (o_apb_pslverr)
  );

  // Tie off the CSR access-policy controls using the shared ASIC tie wrapper.
  m_vlsit_tie #(
    .PARA_TIE_WIDTH (32'd1),
    .PARA_TIE_VALUE (32'd0)
  ) u_tie_protect_en (
    .o_tie (w_tie_protect_en)
  );

  m_vlsit_tie #(
    .PARA_TIE_WIDTH (32'd1),
    .PARA_TIE_VALUE (32'd1)
  ) u_tie_slverr_en (
    .o_tie (w_tie_slverr_en)
  );

  // The generated APB CSR is the single register implementation from the approved workbook.
  m_vlsit_csr_qspi u_csr_qspi (
    .i_clk_apb                  (i_clk_apb),
    .i_rst_n_apb                (w_rst_n_apb),
    .i_clk_reg                  (i_clk_apb),
    .i_rst_n_reg                (w_rst_n_apb),
    .i_apb_psel                 (w_csr_psel),
    .i_apb_penable              (w_csr_penable),
    .i_apb_pwrite               (w_csr_pwrite),
    .i_apb_paddr                (w_csr_paddr),
    .i_apb_pwdata               (w_csr_pwdata),
    .i_apb_pstrb                (w_csr_pstrb),
    .i_apb_pprot                (w_csr_pprot),
    .o_apb_pready               (w_csr_pready),
    .o_apb_pslverr              (w_csr_pslverr),
    .o_apb_prdata               (w_csr_prdata),
    .i_protect_en               (w_tie_protect_en),
    .i_slverr_en                (w_tie_slverr_en),
    .o_qspi_ctrl_lsb_first      (w_qspi_ctrl_lsb_first),
    .o_qspi_ctrl_cpha           (w_qspi_ctrl_cpha),
    .o_qspi_ctrl_cpol           (w_qspi_ctrl_cpol),
    .o_qspi_ctrl_role           (w_qspi_ctrl_role),
    .o_qspi_ctrl_en             (w_qspi_ctrl_en),
    .o_qspi_clkdiv_divisor      (w_qspi_clkdiv_divisor),
    .o_qspi_frame_word_len_m1   (w_qspi_frame_word_len_m1),
    .o_qspi_xip_cfg_dummy_cyc   (w_qspi_xip_cfg_dummy_cyc),
    .o_qspi_xip_cfg_format      (w_qspi_xip_cfg_format),
    .o_qspi_xip_cfg_addr_bytes  (w_qspi_xip_cfg_addr_bytes),
    .o_qspi_xip_cfg_opcode      (w_qspi_xip_cfg_opcode),
    .o_qspi_xip_cfg_en          (w_qspi_xip_cfg_en),
    .o_qspi_xip_mode_mode_count (w_qspi_xip_mode_count),
    .o_qspi_xip_mode_mode_value (w_qspi_xip_mode_value),
    .o_qspi_cmd_start           (w_qspi_cmd_start),
    .i_hw_wdata_qspi_cmd_start  (w_ind_cmd_start_hw_data),
    .i_hw_we_qspi_cmd_start     (w_ind_cmd_start_hw_we),
    .o_qspi_cmd_rd              (w_qspi_cmd_rd),
    .o_qspi_cmd_dummy_cyc       (w_qspi_cmd_dummy_cyc),
    .o_qspi_cmd_addr_bytes      (w_qspi_cmd_addr_bytes),
    .o_qspi_cmd_format          (w_qspi_cmd_format),
    .o_qspi_cmd_opcode          (w_qspi_cmd_opcode),
    .o_qspi_addr_addr           (w_qspi_addr_addr),
    .o_qspi_len_byte_count      (w_qspi_len_byte_count),
    .i_qspi_sts_err_code        (w_qspi_sts_err_code),
    .i_qspi_sts_rx_empty        (w_qspi_sts_rx_empty),
    .i_qspi_sts_rx_full         (w_qspi_sts_rx_full),
    .i_qspi_sts_tx_empty        (w_qspi_sts_tx_empty),
    .i_qspi_sts_tx_full         (w_qspi_sts_tx_full),
    .i_qspi_sts_busy            (w_qspi_sts_busy),
    .o_qspi_irq_raw_fl_err      (w_irq_raw_fl_err),
    .i_hw_wdata_qspi_irq_raw_fl_err(w_irq_hw_we_fl_err),
    .i_hw_we_qspi_irq_raw_fl_err(w_irq_hw_we_fl_err),
    .o_qspi_irq_raw_rx_err      (w_irq_raw_rx_err),
    .i_hw_wdata_qspi_irq_raw_rx_err(w_irq_hw_we_rx_err),
    .i_hw_we_qspi_irq_raw_rx_err(w_irq_hw_we_rx_err),
    .o_qspi_irq_raw_tx_err      (w_irq_raw_tx_err),
    .i_hw_wdata_qspi_irq_raw_tx_err(w_irq_hw_we_tx_err),
    .i_hw_we_qspi_irq_raw_tx_err(w_irq_hw_we_tx_err),
    .o_qspi_irq_raw_done        (w_irq_raw_done),
    .i_hw_wdata_qspi_irq_raw_done(w_irq_hw_we_done),
    .i_hw_we_qspi_irq_raw_done (w_irq_hw_we_done),
    .o_qspi_irq_en_fl_err       (w_irq_en_fl_err),
    .o_qspi_irq_en_rx_err       (w_irq_en_rx_err),
    .o_qspi_irq_en_tx_err       (w_irq_en_tx_err),
    .o_qspi_irq_en_done         (w_irq_en_done),
    .o_qspi_irq_inj_fl_err      (w_irq_inj_fl_err),
    .o_qspi_irq_inj_rx_err      (w_irq_inj_rx_err),
    .o_qspi_irq_inj_tx_err      (w_irq_inj_tx_err),
    .o_qspi_irq_inj_done        (w_irq_inj_done),
    .i_qspi_irq_sts_fl_err      ((w_irq_raw_fl_err || w_irq_inj_fl_err) && w_irq_en_fl_err),
    .i_qspi_irq_sts_rx_err      ((w_irq_raw_rx_err || w_irq_inj_rx_err) && w_irq_en_rx_err),
    .i_qspi_irq_sts_tx_err      ((w_irq_raw_tx_err || w_irq_inj_tx_err) && w_irq_en_tx_err),
    .i_qspi_irq_sts_done        ((w_irq_raw_done || w_irq_inj_done) && w_irq_en_done),
    .o_qspi_cs_cfg_cs_high      (w_cs_cfg_cs_high),
    .o_qspi_cs_cfg_cs_hold      (w_cs_cfg_cs_hold),
    .o_qspi_cs_cfg_cs_setup     (w_cs_cfg_cs_setup),
    .o_qspi_cs_cfg_cs_sel       (w_cs_cfg_cs_sel)
  );

  // Buffer controller TX/RX data between APB and the serial-engine clock.
  m_qspi_async_fifo #(
    .PARA_FIFO_DEPTH (PARA_FIFO_DEPTH),
    .PARA_FIFO_DATA_W(LPARA_FIFO_DATA_W)
  ) u_ctrl_tx_fifo (
    .i_clk_wr   (i_clk_apb),
    .i_rst_n_wr (w_rst_n_apb),
    .i_wr_en    (w_apb_tx_push && !w_qspi_ctrl_role),
    .i_wr_data  (w_apb_tx_data),
    .o_full     (w_ctrl_tx_full),
    .o_overflow (),
    .i_clk_rd   (i_clk_serial),
    .i_rst_n_rd (w_rst_n_serial),
    .i_rd_en    (w_ctrl_tx_pop),
    .o_rd_data  (w_ctrl_tx_data),
    .o_empty    (w_ctrl_tx_empty),
    .o_underflow()
  );

  m_qspi_async_fifo #(
    .PARA_FIFO_DEPTH (PARA_FIFO_DEPTH),
    .PARA_FIFO_DATA_W(LPARA_FIFO_DATA_W)
  ) u_ctrl_rx_fifo (
    .i_clk_wr   (i_clk_serial),
    .i_rst_n_wr (w_rst_n_serial),
    .i_wr_en    (w_ctrl_rx_push),
    .i_wr_data  (w_ctrl_rx_push_data),
    .o_full     (w_ctrl_rx_full),
    .o_overflow (),
    .i_clk_rd   (i_clk_apb),
    .i_rst_n_rd (w_rst_n_apb),
    .i_rd_en    (w_apb_rx_pop && !w_qspi_ctrl_role),
    .o_rd_data  (w_ctrl_rx_data),
    .o_empty    (w_ctrl_rx_empty),
    .o_underflow()
  );

  // Buffer target TX/RX words on their independently selected serial phase clocks.
  m_qspi_async_fifo #(
    .PARA_FIFO_DEPTH (PARA_FIFO_DEPTH),
    .PARA_FIFO_DATA_W(LPARA_FIFO_DATA_W)
  ) u_tgt_tx_fifo (
    .i_clk_wr   (i_clk_apb),
    .i_rst_n_wr (w_rst_n_apb),
    .i_wr_en    (w_apb_tx_push && w_qspi_ctrl_role),
    .i_wr_data  (w_apb_tx_data),
    .o_full     (w_tgt_tx_full),
    .o_overflow (),
    .i_clk_rd   (w_clk_tgt_shift),
    .i_rst_n_rd (w_rst_n_target),
    .i_rd_en    (w_tgt_tx_pop),
    .o_rd_data  (w_tgt_tx_data),
    .o_empty    (w_tgt_tx_empty),
    .o_underflow()
  );

  m_qspi_async_fifo #(
    .PARA_FIFO_DEPTH (PARA_FIFO_DEPTH),
    .PARA_FIFO_DATA_W(LPARA_FIFO_DATA_W)
  ) u_tgt_rx_fifo (
    .i_clk_wr   (w_clk_tgt_sample),
    .i_rst_n_wr (w_rst_n_target),
    .i_wr_en    (w_tgt_rx_push),
    .i_wr_data  (w_tgt_rx_push_data),
    .o_full     (w_tgt_rx_full),
    .o_overflow (),
    .i_clk_rd   (i_clk_apb),
    .i_rst_n_rd (w_rst_n_apb),
    .i_rd_en    (w_apb_rx_pop && w_qspi_ctrl_role),
    .o_rd_data  (w_tgt_rx_data),
    .o_empty    (w_tgt_rx_empty),
    .o_underflow()
  );

  // Keep the first target TX word stable until its completed RX word is acknowledged.
  m_qspi_target_tx_head u_target_tx_head (
    .i_clk_apb         (i_clk_apb),
    .i_rst_n_apb       (w_rst_n_apb),
    .i_head_push       (w_apb_tgt_head_push),
    .i_head_data       (w_apb_tgt_head_data),
    .o_head_full       (w_tgt_head_full),
    .o_head_data       (w_tgt_head_data),
    .o_head_token      (w_tgt_head_token),
    .i_clk_tgt_sample  (w_clk_tgt_sample),
    .i_rst_n_tgt_sample(w_rst_n_target),
    .i_head_pop        (w_tgt_head_pop)
  );

  // Capture frame settings while CS is inactive and derive separate positive-edge clocks.
  m_qspi_tgt_fifo_clock u_tgt_fifo_clk (
    .i_clk_spi_tgt   (i_clk_spi_tgt),
    .i_spi_cs_tgt_n  (i_spi_cs_tgt_n),
    .i_target_en     (w_qspi_ctrl_en && w_qspi_ctrl_role),
    .i_cpol          (w_qspi_ctrl_cpol),
    .i_cpha          (w_qspi_ctrl_cpha),
    .i_lsb_first     (w_qspi_ctrl_lsb_first),
    .i_word_bits     (w_frame_word_bits),
    .i_fifo_rd_en    (w_tgt_tx_pop),
    .i_fifo_wr_en    (w_tgt_rx_push),
    .o_cpha_cfg      (w_tgt_cpha_cfg),
    .o_target_en_cfg (w_tgt_en_cfg),
    .o_lsb_first_cfg (w_tgt_lsb_first_cfg),
    .o_word_bits_cfg (w_tgt_word_bits_cfg),
    .o_clk_tgt_shift (w_clk_tgt_shift),
    .o_clk_tgt_sample(w_clk_tgt_sample)
  );

  // Standard target RX samples on the sample clock and TX shifts on the opposite clock.
  m_qspi_target_engine u_target_engine (
    .i_clk_apb         (i_clk_apb),
    .i_rst_n_apb       (w_rst_n_apb),
    .i_clk_tgt_sample  (w_clk_tgt_sample),
    .i_clk_tgt_shift   (w_clk_tgt_shift),
    .i_rst_n_tgt       (w_rst_n_target),
    .i_target_en       (w_tgt_en_cfg),
    .i_spi_cs_tgt_n    (i_spi_cs_tgt_n),
    .i_cpha_cfg        (w_tgt_cpha_cfg),
    .i_lsb_first_cfg   (w_tgt_lsb_first_cfg),
    .i_word_bits_cfg   (w_tgt_word_bits_cfg),
    .i_head_valid      (w_tgt_head_full),
    .i_head_data       (w_tgt_head_data),
    .i_head_token      (w_tgt_head_token),
    .o_head_pop        (w_tgt_head_pop),
    .i_tx_data         (w_tgt_tx_data),
    .i_tx_empty        (w_tgt_tx_empty),
    .o_tx_pop          (w_tgt_tx_pop),
    .i_rx_full         (w_tgt_rx_full),
    .o_rx_data         (w_tgt_rx_push_data),
    .o_rx_push         (w_tgt_rx_push),
    .i_spi_io_i        (i_spi_io_i),
    .o_spi_io_o        (w_tgt_io_o),
    .o_spi_io_oe       (w_tgt_io_oe),
    .o_busy            (w_tgt_busy),
    .o_frame_done      (w_tgt_frame_done),
    .o_tx_err_tgl      (w_tgt_tx_err_tgl),
    .o_rx_full_err_tgl (w_tgt_rx_err_tgl),
    .o_rx_partial_err  (w_tgt_rx_partial_err)
  );

  // Select one role-specific output driver for the shared serial IO pad group.
  m_qspi_pin_mux u_pin_mux (
    .i_role_target (w_tgt_en_cfg),
    .i_ctrl_io_o   (w_ctrl_io_o),
    .i_ctrl_io_oe  (w_ctrl_io_oe),
    .i_tgt_io_o    (w_tgt_io_o),
    .i_tgt_io_oe   (w_tgt_io_oe),
    .o_spi_io_o    (o_spi_io_o),
    .o_spi_io_oe   (o_spi_io_oe)
  );

  // Capture indirect command fields in APB and exchange complete requests/responses with serial.
  m_qspi_indirect u_indirect (
    .i_clk_apb          (i_clk_apb),
    .i_rst_n_apb        (w_rst_n_apb),
    .i_cmd_start        (w_qspi_cmd_start),
    .i_ctrl_en          (w_qspi_ctrl_en),
    .i_ctrl_role        (w_qspi_ctrl_role),
    .i_tgt_cs_active    (w_tgt_cs_active_apb),
    .i_ctrl_cpol        (w_qspi_ctrl_cpol),
    .i_ctrl_cpha        (w_qspi_ctrl_cpha),
    .i_ctrl_lsb_first   (w_qspi_ctrl_lsb_first),
    .i_ctrl_divisor     (w_qspi_clkdiv_divisor),
    .i_cs_setup         (w_cs_cfg_cs_setup),
    .i_cs_hold          (w_cs_cfg_cs_hold),
    .i_cs_high          (w_cs_cfg_cs_high),
    .i_cs_sel           (w_cs_cfg_cs_sel),
    .i_cmd_format       (w_qspi_cmd_format),
    .i_cmd_opcode       (w_qspi_cmd_opcode),
    .i_cmd_addr         (w_qspi_addr_addr),
    .i_cmd_addr_bytes   (w_qspi_cmd_addr_bytes),
    .i_cmd_dummy_cycles (w_qspi_cmd_dummy_cyc),
    .i_cmd_rd           (w_qspi_cmd_rd),
    .i_cmd_byte_count   (w_qspi_len_byte_count),
    .o_cmd_start_hw_we  (w_ind_cmd_start_hw_we),
    .o_cmd_start_hw_data(w_ind_cmd_start_hw_data),
    .o_busy             (w_ind_busy_apb),
    .o_done_event       (w_ind_done_event_apb),
    .o_err_event        (w_ind_err_event_apb),
    .o_cmd_src_valid    (w_ind_cmd_valid_apb),
    .i_cmd_src_ready    (w_ind_cmd_ready_apb),
    .o_cmd_src_data     (w_ind_cmd_data_apb),
    .i_clk_serial       (i_clk_serial),
    .i_rst_n_serial     (w_rst_n_serial),
    .i_serial_cmd_done  (w_arb_done_ind),
    .i_serial_cmd_err   (w_arb_err_ind),
    .o_rsp_src_valid    (w_ind_rsp_valid_serial),
    .i_rsp_src_ready    (w_ind_rsp_ready_serial),
    .o_rsp_src_data     (w_ind_rsp_data_serial),
    .i_rsp_dst_valid    (w_ind_rsp_valid_apb),
    .i_rsp_dst_data     (w_ind_rsp_data_apb),
    .o_rsp_dst_ready    (w_ind_rsp_ready_apb)
  );

  // Translate AXI XIP traffic to one flash-read command and collect AXI response metadata.
  m_qspi_axi_xip #(
    .PARA_AXI_ADDR_W    (PARA_AXI_ADDR_W),
    .PARA_AXI_DATA_W    (PARA_AXI_DATA_W),
    .PARA_AXI_ID_W      (PARA_AXI_ID_W),
    .PARA_AXI_MAX_BURST (PARA_AXI_MAX_BURST),
    .PARA_XIP_BASE_ADDR (PARA_XIP_BASE_ADDR),
    .PARA_XIP_SIZE_BYTES(PARA_XIP_SIZE_BYTES)
  ) u_axi_xip (
    .i_clk_axi          (i_clk_axi),
    .i_rst_n_axi        (w_rst_n_axi),
    .i_axi_awaddr       (i_axi_awaddr),
    .i_axi_awid         (i_axi_awid),
    .i_axi_awlen        (i_axi_awlen),
    .i_axi_awsize       (i_axi_awsize),
    .i_axi_awburst      (i_axi_awburst),
    .i_axi_awlock       (i_axi_awlock),
    .i_axi_awcache      (i_axi_awcache),
    .i_axi_awprot       (i_axi_awprot),
    .i_axi_awqos        (i_axi_awqos),
    .i_axi_awregion     (i_axi_awregion),
    .i_axi_awvalid      (i_axi_awvalid),
    .o_axi_awready      (o_axi_awready),
    .i_axi_wdata        (i_axi_wdata),
    .i_axi_wstrb        (i_axi_wstrb),
    .i_axi_wlast        (i_axi_wlast),
    .i_axi_wvalid       (i_axi_wvalid),
    .o_axi_wready       (o_axi_wready),
    .o_axi_bid          (o_axi_bid),
    .o_axi_bresp        (o_axi_bresp),
    .o_axi_bvalid       (o_axi_bvalid),
    .i_axi_bready       (i_axi_bready),
    .i_axi_araddr       (i_axi_araddr),
    .i_axi_arid         (i_axi_arid),
    .i_axi_arlen        (i_axi_arlen),
    .i_axi_arsize       (i_axi_arsize),
    .i_axi_arburst      (i_axi_arburst),
    .i_axi_arlock       (i_axi_arlock),
    .i_axi_arcache      (i_axi_arcache),
    .i_axi_arprot       (i_axi_arprot),
    .i_axi_arqos        (i_axi_arqos),
    .i_axi_arregion     (i_axi_arregion),
    .i_axi_arvalid      (i_axi_arvalid),
    .o_axi_arready      (o_axi_arready),
    .o_axi_rid          (o_axi_rid),
    .o_axi_rdata        (o_axi_rdata),
    .o_axi_rresp        (o_axi_rresp),
    .o_axi_rlast        (o_axi_rlast),
    .o_axi_rvalid       (o_axi_rvalid),
    .i_axi_rready       (i_axi_rready),
    .i_xip_en           (w_cfg_axi_bus[34]),
    .i_ctrl_en          (w_cfg_axi_bus[83]),
    .i_controller_role  (!w_cfg_axi_bus[82]),
    .i_ctrl_cpol        (w_cfg_axi_bus[81]),
    .i_ctrl_cpha        (w_cfg_axi_bus[80]),
    .i_ctrl_lsb_first   (w_cfg_axi_bus[79]),
    .i_ctrl_divisor     (w_cfg_axi_bus[78:63]),
    .i_cs_setup         (w_cfg_axi_bus[62:55]),
    .i_cs_hold          (w_cfg_axi_bus[54:47]),
    .i_cs_high          (w_cfg_axi_bus[46:39]),
    .i_cs_sel           (w_cfg_axi_bus[38:35]),
    .i_xip_cfg_format   (w_cfg_axi_bus[33:31]),
    .i_xip_cfg_addr_bytes(w_cfg_axi_bus[30:29]),
    .i_xip_cfg_dummy_cyc(w_cfg_axi_bus[28:21]),
    .i_xip_cfg_opcode   (w_cfg_axi_bus[20:13]),
    .i_xip_mode_count   (w_cfg_axi_bus[12:8]),
    .i_xip_mode_value   (w_cfg_axi_bus[7:0]),
    .o_xip_req_valid    (w_xip_req_valid_axi),
    .i_xip_req_ready    (w_xip_req_ready_axi),
    .o_xip_req_addr     (w_xip_req_addr_axi),
    .o_xip_req_len      (w_xip_req_len_axi),
    .o_xip_req_size     (w_xip_req_size_axi),
    .o_xip_req_id       (w_xip_req_id_axi),
    .o_xip_req_cmd_data (w_xip_req_cmd_axi),
    .o_xip_rsp_addr     (w_xip_rsp_addr_axi),
    .o_xip_rsp_len      (w_xip_rsp_len_axi),
    .o_xip_rsp_size     (w_xip_rsp_size_axi),
    .o_xip_rsp_active   (w_xip_rsp_active_axi),
    .i_xip_rsp_valid    (w_xip_rsp_valid_axi),
    .o_xip_rsp_ready    (w_xip_rsp_ready_axi),
    .i_xip_rsp_data     (w_xip_rsp_data_axi),
    .i_xip_rsp_resp     (w_xip_rsp_resp_axi),
    .i_xip_rsp_last     (w_xip_rsp_last_axi)
  );

  // Pack serial bytes into AXI-sized beats, retaining response fields during R backpressure.
  m_qspi_xip_rsp_pack #(
    .PARA_AXI_DATA_W(PARA_AXI_DATA_W),
    .PARA_AXI_ADDR_W(PARA_AXI_ADDR_W)
  ) u_xip_rsp_pack (
    .i_clk_axi       (i_clk_axi),
    .i_rst_n_axi     (w_rst_n_axi),
    .i_burst_active  (w_xip_rsp_active_axi),
    .i_burst_addr    (w_xip_rsp_addr_axi),
    .i_burst_len     (w_xip_rsp_len_axi),
    .i_burst_size    (w_xip_rsp_size_axi),
    .i_fifo_data     (w_xip_rsp_fifo_data_axi),
    .i_fifo_empty    (w_xip_rsp_empty_axi),
    .o_fifo_pop      (w_xip_rsp_fifo_pop_axi),
    .o_rsp_valid     (w_xip_rsp_valid_axi),
    .i_rsp_ready     (w_xip_rsp_ready_axi),
    .o_rsp_data      (w_xip_rsp_data_axi),
    .o_rsp_resp      (w_xip_rsp_resp_axi),
    .o_rsp_last      (w_xip_rsp_last_axi)
  );

  // Cross indirect and XIP command bundles plus the XIP return stream between clock domains.
  m_qspi_cdc #(
    .PARA_AXI_ADDR_W(PARA_AXI_ADDR_W),
    .PARA_AXI_ID_W  (PARA_AXI_ID_W),
    .PARA_FIFO_DEPTH(PARA_FIFO_DEPTH)
  ) u_cdc (
    .i_clk_apb             (i_clk_apb),
    .i_rst_n_apb           (w_rst_n_apb),
    .i_clk_axi             (i_clk_axi),
    .i_rst_n_axi           (w_rst_n_axi),
    .i_clk_serial          (i_clk_serial),
    .i_rst_n_serial        (w_rst_n_serial),
    .i_ind_cmd_valid_apb   (w_ind_cmd_valid_apb),
    .o_ind_cmd_ready_apb   (w_ind_cmd_ready_apb),
    .i_ind_cmd_data_apb    (w_ind_cmd_data_apb),
    .o_ind_cmd_valid_serial(w_ind_cmd_valid_serial),
    .i_ind_cmd_ready_serial(w_ind_cmd_ready_serial),
    .o_ind_cmd_data_serial (w_ind_cmd_data_serial),
    .i_ind_rsp_valid_serial(w_ind_rsp_valid_serial),
    .o_ind_rsp_ready_serial(w_ind_rsp_ready_serial),
    .i_ind_rsp_data_serial (w_ind_rsp_data_serial),
    .o_ind_rsp_valid_apb   (w_ind_rsp_valid_apb),
    .i_ind_rsp_ready_apb   (w_ind_rsp_ready_apb),
    .o_ind_rsp_data_apb    (w_ind_rsp_data_apb),
    .i_xip_req_valid_axi   (w_xip_req_valid_axi),
    .o_xip_req_ready_axi   (w_xip_req_ready_axi),
    .i_xip_req_data_axi    (w_xip_req_bundle_axi),
    .o_xip_req_valid_serial(w_xip_req_valid_serial),
    .i_xip_req_ready_serial(w_xip_req_ready_serial),
    .o_xip_req_data_serial (w_xip_req_bundle_serial),
    .i_xip_rsp_push_serial (w_xip_rsp_push_serial),
    .i_xip_rsp_data_serial (w_xip_rsp_data_serial),
    .o_xip_rsp_full_serial (w_xip_rsp_full_serial),
    .i_xip_rsp_pop_axi     (w_xip_rsp_fifo_pop_axi),
    .o_xip_rsp_data_axi    (w_xip_rsp_fifo_data_axi),
    .o_xip_rsp_empty_axi   (w_xip_rsp_empty_axi)
  );

  // Convert accepted AXI burst metadata into one controller-domain XIP command.
  m_qspi_xip_serial #(
    .PARA_AXI_ADDR_W(PARA_AXI_ADDR_W),
    .PARA_AXI_ID_W  (PARA_AXI_ID_W)
  ) u_xip_serial (
    .i_clk_serial       (i_clk_serial),
    .i_rst_n_serial     (w_rst_n_serial),
    .i_req_valid        (w_xip_req_valid_serial),
    .o_req_ready        (w_xip_req_ready_serial),
    .i_req_data         (w_xip_req_bundle_serial),
    .o_xip_cmd_valid    (w_arb_xip_valid),
    .i_xip_cmd_ready    (w_arb_xip_ready),
    .o_xip_cmd_data     (w_arb_xip_data),
    .i_xip_cmd_done     (w_arb_done_xip),
    .i_xip_cmd_err      (w_arb_err_xip),
    .i_engine_rx_push   (w_eng_rx_push),
    .i_engine_rx_data   (w_eng_rx_data),
    .i_rsp_fifo_full    (w_xip_rsp_full_serial),
    .o_engine_rx_full   (w_xip_engine_rx_full),
    .o_rsp_fifo_push    (w_xip_rsp_push_serial),
    .o_rsp_fifo_data    (w_xip_rsp_data_serial)
  );

  // Give the controller engine exclusive ownership to XIP or indirect work, never target mode.
  m_qspi_arbiter u_arb (
    .i_clk_serial      (i_clk_serial),
    .i_rst_n_serial    (w_rst_n_serial),
    .i_target_active   (w_ctrl_en_serial && w_ctrl_role_serial),
    .i_xip_valid       (w_arb_xip_valid),
    .o_xip_ready       (w_arb_xip_ready),
    .i_xip_data        (w_arb_xip_data),
    .i_indirect_valid  (w_ind_cmd_valid_serial),
    .o_indirect_ready  (w_ind_cmd_ready_serial),
    .i_indirect_data   (w_ind_cmd_data_serial),
    .o_cmd_valid       (w_arb_cmd_valid),
    .i_cmd_ready       (w_arb_cmd_ready),
    .i_cmd_done        (w_eng_done),
    .i_cmd_err         (w_eng_fl_err || w_eng_tx_err || w_eng_rx_err),
    .o_cmd_owner_xip   (w_arb_owner_xip),
    .o_cmd_data        (w_arb_cmd_data),
    .o_busy            (w_arb_busy),
    .o_done_xip        (w_arb_done_xip),
    .o_done_indirect   (w_arb_done_ind),
    .o_err_xip         (w_arb_err_xip),
    .o_err_indirect    (w_arb_err_ind)
  );

  // Decode the selected command bundle according to the fixed 130-bit command contract.
  assign w_cmd_format       = w_arb_cmd_data[129:127];
  assign w_cmd_cpol         = w_arb_cmd_data[126];
  assign w_cmd_cpha         = w_arb_cmd_data[125];
  assign w_cmd_lsb_first    = w_arb_cmd_data[124];
  assign w_cmd_divisor      = w_arb_cmd_data[123:108];
  assign w_cmd_cs_setup     = w_arb_cmd_data[107:100];
  assign w_cmd_cs_hold      = w_arb_cmd_data[99:92];
  assign w_cmd_cs_high      = w_arb_cmd_data[91:84];
  assign w_cmd_cs_sel       = w_arb_cmd_data[83:80];
  assign w_cmd_opcode       = w_arb_cmd_data[79:72];
  assign w_cmd_addr         = w_arb_cmd_data[71:40];
  assign w_cmd_addr_bytes   = w_arb_cmd_data[39:38];
  assign w_cmd_mode_value   = w_arb_cmd_data[37:30];
  assign w_cmd_mode_count   = w_arb_cmd_data[29:25];
  assign w_cmd_dummy_cycles = w_arb_cmd_data[24:17];
  assign w_cmd_rd         = w_arb_cmd_data[16];
  assign w_cmd_byte_count   = w_arb_cmd_data[15:0];

  // Execute controller commands from the round-robin arbiter and return FIFO/error events.
  m_qspi_controller_engine #(
    .PARA_NUM_CS(PARA_NUM_CS)
  ) u_controller_engine (
    .i_clk_serial       (i_clk_serial),
    .i_rst_n_serial     (w_rst_n_serial),
    .i_en               (w_ctrl_en_serial),
    .i_target_role      (w_ctrl_role_serial),
    .i_cmd_valid        (w_arb_cmd_valid),
    .o_cmd_ready        (w_arb_cmd_ready),
    .i_cmd_format       (w_cmd_format),
    .i_cpol             (w_cmd_cpol),
    .i_cpha             (w_cmd_cpha),
    .i_lsb_first        (w_cmd_lsb_first),
    .i_clk_divisor      (w_cmd_divisor),
    .i_cs_setup         (w_cmd_cs_setup),
    .i_cs_hold          (w_cmd_cs_hold),
    .i_cs_high          (w_cmd_cs_high),
    .i_cs_sel           (w_cmd_cs_sel),
    .i_cmd_opcode       (w_cmd_opcode),
    .i_cmd_addr         (w_cmd_addr),
    .i_cmd_addr_bytes   (w_cmd_addr_bytes),
    .i_cmd_mode_value   (w_cmd_mode_value),
    .i_cmd_mode_count   (w_cmd_mode_count),
    .i_cmd_dummy_cycles (w_cmd_dummy_cycles),
    .i_cmd_rd           (w_cmd_rd),
    .i_cmd_byte_count   (w_cmd_byte_count),
    .i_tx_data          (w_ctrl_tx_data),
    .i_tx_empty         (w_ctrl_tx_empty),
    .o_tx_pop           (w_ctrl_tx_pop),
    .i_rx_full          (w_eng_rx_full),
    .o_rx_data          (w_eng_rx_data),
    .o_rx_push          (w_eng_rx_push),
    .i_spi_io_i         (i_spi_io_i),
    .o_clk_spi_ctrl     (o_clk_spi_ctrl),
    .o_spi_cs_ctrl_n    (o_spi_cs_ctrl_n),
    .o_spi_io_o         (w_ctrl_io_o),
    .o_spi_io_oe        (w_ctrl_io_oe),
    .o_busy             (w_eng_busy),
    .o_done             (w_eng_done),
    .o_fl_err           (w_eng_fl_err),
    .o_tx_err           (w_eng_tx_err),
    .o_rx_err           (w_eng_rx_err)
  );

endmodule


