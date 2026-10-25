/*
 * Project      : VLSIT Common RTL library
 * Author       : Nguyen Quan and Claude Sonnet 5.5 (user)
 * AI Flow      : VLSIT RTL Generator AI Automation Flow
 * AI Flow Page : https://github.com/nguyenquanicd/VLSIT_RTL_Generator_AI_Model
 * Date         : 2026-10-25
 * Description  : Validates and schedules AHB transfers, buffers write bursts, maps attributes,
 *                controls AXI handshakes and returns ordered AHB responses. Reset release at the
 *                IP input is synchronous to i_clk_core, as required by the system contract.
 */
`timescale 1ns/1ps

module m_ahb2axi_ctrl #(
  // Parameter Description: number of read IDs used by the round-robin ID sequence.
  // Parameter values: legal values are 1 through 8; default is 1.
  // Parameter unit: count
  parameter logic [31:0] PARA_RD_ID_COUNT = 32'd1,
  // Parameter Description: number of write IDs used by the round-robin ID sequence.
  // Parameter values: legal values are 1 through 8; default is 1.
  // Parameter unit: count
  parameter logic [31:0] PARA_WR_ID_COUNT = 32'd1,
  localparam logic [31:0] LPARA_CMD_DEPTH = 32'd2,
  localparam logic [31:0] LPARA_DATA_DEPTH = 32'd16,
  localparam logic [31:0] LPARA_RSP_DEPTH = 32'd2,
  localparam logic [31:0] LPARA_CMD_W = 32'd50,
  localparam logic [31:0] LPARA_DATA_W = 32'd36,
  localparam logic [31:0] LPARA_RD_RSP_W = 32'd34,
  localparam logic [31:0] LPARA_WR_RSP_W = 32'd2,
  localparam logic [31:0] LPARA_BURST_4 = 32'd4,
  localparam logic [31:0] LPARA_BURST_8 = 32'd8,
  localparam logic [31:0] LPARA_BURST_16 = 32'd16
) (
  // Shared clock and reset
  input  wire         i_clk_core,
  input  wire         i_rst_n_core,

  // AHB5 subordinate interface
  input  wire         i_ahb_hsel,
  input  wire         i_ahb_hready,
  input  wire  [31:0] i_ahb_haddr,
  input  wire  [1:0]  i_ahb_htrans,
  input  wire         i_ahb_hwrite,
  input  wire  [2:0]  i_ahb_hsize,
  input  wire  [2:0]  i_ahb_hburst,
  input  wire  [6:0]  i_ahb_hprot,
  input  wire         i_ahb_hnonsec,
  input  wire         i_ahb_hmastlock,
  input  wire  [31:0] i_ahb_hwdata,
  input  wire  [3:0]  i_ahb_hwstrb,
  output logic        o_ahb_hreadyout,
  output logic        o_ahb_hresp,
  output logic [31:0] o_ahb_hrdata,

  // AXI4 write-address channel
  output logic [2:0]  o_axi_awid,
  output logic [31:0] o_axi_awaddr,
  output logic [7:0]  o_axi_awlen,
  output logic [2:0]  o_axi_awsize,
  output logic [1:0]  o_axi_awburst,
  output logic        o_axi_awlock,
  output logic [3:0]  o_axi_awcache,
  output logic [2:0]  o_axi_awprot,
  output logic        o_axi_awvalid,
  input  wire         i_axi_awready,

  // AXI4 write-data channel
  output logic [31:0] o_axi_wdata,
  output logic [3:0]  o_axi_wstrb,
  output logic        o_axi_wlast,
  output logic        o_axi_wvalid,
  input  wire         i_axi_wready,

  // AXI4 write-response channel
  input  wire  [2:0]  i_axi_bid,
  input  wire  [1:0]  i_axi_bresp,
  input  wire         i_axi_bvalid,
  output logic        o_axi_bready,

  // AXI4 read-address channel
  output logic [2:0]  o_axi_arid,
  output logic [31:0] o_axi_araddr,
  output logic [7:0]  o_axi_arlen,
  output logic [2:0]  o_axi_arsize,
  output logic [1:0]  o_axi_arburst,
  output logic        o_axi_arlock,
  output logic [3:0]  o_axi_arcache,
  output logic [2:0]  o_axi_arprot,
  output logic        o_axi_arvalid,
  input  wire         i_axi_arready,

  // AXI4 read-data channel
  input  wire  [2:0]  i_axi_rid,
  input  wire  [31:0] i_axi_rdata,
  input  wire  [1:0]  i_axi_rresp,
  input  wire         i_axi_rlast,
  input  wire         i_axi_rvalid,
  output logic        o_axi_rready
);

  // Local state encoding follows the FSM example and recovers unused states to IDLE.
  typedef enum logic [3:0] {
    ENUM_ST_IDLE       = 4'b0000,
    ENUM_ST_RD_AR      = 4'b0001,
    ENUM_ST_RD_RSP     = 4'b0010,
    ENUM_ST_WR_SINGLE  = 4'b0011,
    ENUM_ST_WR_B       = 4'b0100,
    ENUM_ST_WR_CAPTURE = 4'b0101,
    ENUM_ST_WR_BURST   = 4'b0110,
    ENUM_ST_WR_BBURST  = 4'b0111,
    ENUM_ST_LOCAL      = 4'b1000,
    ENUM_ST_AHB_RSP    = 4'b1001
  } ctrl_state_type_def;

  // Internal signal declarations
  ctrl_state_type_def reg_fsm_ctrl_current_state;
  ctrl_state_type_def w_fsm_ctrl_nxt_state;

  logic [31:0] reg_cmd_addr;
  logic [2:0]  reg_cmd_size;
  logic [5:0]  reg_cmd_prot;
  logic        reg_cmd_nonsec;

  logic [31:0] reg_burst_addr [0:15];
  logic [2:0]  reg_burst_size [0:15];
  logic [2:0]  reg_burst_type [0:15];
  logic [6:0]  reg_burst_prot [0:15];
  logic        reg_burst_nonsec [0:15];
  logic [4:0]  reg_burst_count;
  logic [4:0]  reg_burst_expected;
  logic [4:0]  reg_burst_start;
  logic [4:0]  reg_burst_widx;
  logic        reg_burst_fallback;
  logic        reg_burst_term_seen;
  logic        reg_burst_err;

  logic        reg_in_burst_active;
  logic [4:0]  reg_in_burst_count;
  logic [4:0]  reg_in_burst_expected;
  logic        reg_data_store;
  logic        reg_data_early_ack;

  logic [4:0]  reg_data_count;
  logic        reg_aw_done;
  logic        reg_w_done;
  logic [2:0]  reg_rd_id;
  logic [2:0]  reg_wr_id;
  logic        reg_rsp_valid;
  logic        reg_rsp_err;
  logic [31:0] reg_rsp_data;
  logic        reg_early_rsp_valid;

  logic        w_req_valid;
  logic        w_req_ready;
  logic [31:0] w_req_addr;
  logic [1:0]  w_req_trans;
  logic        w_req_wr;
  logic [2:0]  w_req_size;
  logic [2:0]  w_req_burst;
  logic [6:0]  w_req_prot;
  logic        w_req_nonsec;
  logic        w_req_lock;
  logic        w_data_valid;
  logic        w_data_ready;
  logic [31:0] w_data;
  logic [3:0]  w_strb;
  logic        w_ahb_rsp_valid;
  logic        w_ahb_rsp_ready;
  logic        w_ahb_rsp_err;
  logic [31:0] w_ahb_rsp_data;
  logic        w_early_ack_now;
  logic        w_early_ack_pending;
  logic        w_reg_rsp_ready;
  logic        w_req_hs;
  logic        w_data_hs;
  logic        w_burst_term;
  logic        w_input_err;
  logic        w_input_eligible;
  logic [4:0]  w_input_burst_len;
  logic        w_input_early_ack;

  logic [49:0] w_cmd_wr_data;
  logic [49:0] w_wr_cmd_rd_data;
  logic [49:0] w_rd_cmd_rd_data;
  logic        w_wr_cmd_wr_en;
  logic        w_wr_cmd_rd_en;
  logic        w_wr_cmd_full;
  logic        w_wr_cmd_empty;
  logic        w_rd_cmd_wr_en;
  logic        w_rd_cmd_rd_en;
  logic        w_rd_cmd_full;
  logic        w_rd_cmd_empty;

  logic [35:0] w_wr_data_wr_data;
  logic [35:0] w_wr_data_rd_data;
  logic        w_wr_data_wr_en;
  logic        w_wr_data_rd_en;
  logic        w_wr_data_full;
  logic        w_wr_data_empty;

  logic [33:0] w_rd_rsp_wr_data;
  logic [33:0] w_rd_rsp_rd_data;
  logic        w_rd_rsp_wr_en;
  logic        w_rd_rsp_rd_en;
  logic        w_rd_rsp_full;
  logic        w_rd_rsp_empty;

  logic [1:0]  w_wr_rsp_wr_data;
  logic [1:0]  w_wr_rsp_rd_data;
  logic        w_wr_rsp_wr_en;
  logic        w_wr_rsp_rd_en;
  logic        w_wr_rsp_full;
  logic        w_wr_rsp_empty;

  logic        w_axi_aw_valid;
  logic        w_axi_aw_ready;
  logic [2:0]  w_axi_aw_id;
  logic [31:0] w_axi_aw_addr;
  logic [7:0]  w_axi_aw_len;
  logic [2:0]  w_axi_aw_size;
  logic [1:0]  w_axi_aw_burst;
  logic [3:0]  w_axi_aw_cache;
  logic [2:0]  w_axi_aw_prot;
  logic        w_axi_w_valid;
  logic        w_axi_w_ready;
  logic [31:0] w_axi_w_data;
  logic [3:0]  w_axi_w_strb;
  logic        w_axi_w_last;
  logic        w_axi_b_valid;
  logic        w_axi_b_ready;
  logic [2:0]  w_axi_b_id;
  logic [1:0]  w_axi_b_sts;
  logic        w_axi_ar_valid;
  logic        w_axi_ar_ready;
  logic [2:0]  w_axi_ar_id;
  logic [31:0] w_axi_ar_addr;
  logic [7:0]  w_axi_ar_len;
  logic [2:0]  w_axi_ar_size;
  logic [1:0]  w_axi_ar_burst;
  logic [3:0]  w_axi_ar_cache;
  logic [2:0]  w_axi_ar_prot;
  logic        w_axi_r_valid;
  logic        w_axi_r_ready;
  logic [2:0]  w_axi_r_id;
  logic [31:0] w_axi_r_data;
  logic [1:0]  w_axi_r_sts;
  logic        w_axi_r_last;

  logic        w_aw_hs;
  logic        w_w_hs;
  logic        w_ar_hs;
  logic        w_wr_b_hs;
  logic        w_rd_r_hs;
  logic [4:0]  w_burst_sub_len;
  logic [31:0] w_idle_cmd_addr;
  logic [1:0]  w_idle_cmd_htrans;
  logic        w_idle_cmd_wr;
  logic [2:0]  w_idle_cmd_size;
  logic [2:0]  w_idle_cmd_burst;
  logic [6:0]  w_idle_cmd_prot;
  logic        w_idle_cmd_nonsec;
  logic        w_idle_cmd_lock;
  logic        w_idle_cmd_err;
  logic        w_idle_cmd_eligible;
  logic [1:0]  w_cap_cmd_htrans;
  logic [31:0] w_cap_cmd_addr;
  logic        w_cap_cmd_wr;
  logic [2:0]  w_cap_cmd_size;
  logic [2:0]  w_cap_cmd_burst;
  logic [6:0]  w_cap_cmd_prot;
  logic        w_cap_cmd_nonsec;
  logic        w_cap_cmd_lock;
  logic        w_cap_cmd_err;
  logic        w_cap_stop;
  logic        w_cap_pop;
  logic        w_rd_cmd_start;
  logic        w_wr_cmd_start;
  logic        w_idle_cmd_start;
  logic        w_more_burst_segments;
  logic        w_more_fallback_beats;
  logic        w_axi_aw_hs;
  logic        w_axi_w_hs;
  logic        w_axi_ar_hs;
  logic        w_rsp_err_now;
  logic [1:0]  w_burst_axi_burst;

  // Protocol decode functions keep validation and HPROT mapping consistent for every transfer.
  function automatic logic f_hsize_valid(input logic [2:0] hsize);
    begin
      case (hsize)
        3'b000, 3'b001, 3'b010: f_hsize_valid = 1'b1;
        default:                f_hsize_valid = 1'b0;
      endcase
    end
  endfunction

  function automatic logic f_addr_aligned(
    input logic [1:0] addr_low,
    input logic [2:0] size
  );
    begin
      case (size)
        3'b000:  f_addr_aligned = 1'b1;
        3'b001:  f_addr_aligned = ~addr_low[0];
        3'b010:  f_addr_aligned = ~(|addr_low[1:0]);
        default: f_addr_aligned = 1'b0;
      endcase
    end
  endfunction

  function automatic logic f_hprot_valid(input logic [4:0] hprot_attr);
    begin
      casez (hprot_attr)
        5'b0_0000, 5'b0_0001, 5'b0_0010, 5'b0_?110, 5'b0_?111:
          f_hprot_valid = 1'b1;
        default: f_hprot_valid = 1'b0;
      endcase
    end
  endfunction

  function automatic logic f_hburst_valid(input logic [2:0] hburst);
    begin
      case (hburst)
        3'b000, 3'b001, 3'b010, 3'b011, 3'b100, 3'b101, 3'b110, 3'b111:
          f_hburst_valid = 1'b1;
        default: f_hburst_valid = 1'b0;
      endcase
    end
  endfunction

  function automatic logic [4:0] f_hburst_len(input logic [2:0] hburst);
    begin
      case (hburst)
        3'b010, 3'b011: f_hburst_len = $bits(f_hburst_len)'(LPARA_BURST_4);
        3'b100, 3'b101: f_hburst_len = $bits(f_hburst_len)'(LPARA_BURST_8);
        3'b110, 3'b111: f_hburst_len = $bits(f_hburst_len)'(LPARA_BURST_16);
        default:        f_hburst_len = 5'd1;
      endcase
    end
  endfunction

  function automatic logic f_local_error(
    input logic [1:0] addr_low,
    input logic [2:0] size,
    input logic [2:0] burst,
    input logic [4:0] hprot_attr,
    input logic lock
  );
    begin
      f_local_error = ~f_hsize_valid(size) | ~f_addr_aligned(addr_low, size) |
                      ~f_hprot_valid(hprot_attr) | ~f_hburst_valid(burst) | lock;
    end
  endfunction

  function automatic logic f_burst_eligible(
    input logic [1:0] trans,
    input logic wr,
    input logic [2:0] burst,
    input logic shareable,
    input logic lookup,
    input logic modifiable,
    input logic bufferable,
    input logic lock
  );
    logic [4:0] burst_len;
    begin
      burst_len = f_hburst_len(burst);
      f_burst_eligible = (trans == 2'b10) & wr &
                         (burst_len >= $bits(burst_len)'(LPARA_BURST_4)) &
                         ~shareable & lookup & modifiable & bufferable & ~lock;
    end
  endfunction

  function automatic logic [2:0] f_axi_prot(
    input logic [1:0] hprot_low,
    input logic hnonsec
  );
    begin
      f_axi_prot = {~hprot_low[0], hnonsec, hprot_low[1]};
    end
  endfunction

  function automatic logic [3:0] f_axi_cache(
    input logic [3:0] hprot_attr,
    input logic wr
  );
    logic [3:0] cache_value;
    begin
      cache_value = '0;
      cache_value[1] = hprot_attr[1];
      cache_value[0] = hprot_attr[0];
      if (hprot_attr[2]) begin
        if (wr) begin
          if (hprot_attr[3])
            cache_value[3] = 1'b1;
          else
            cache_value[2] = 1'b1;
        end else begin
          if (hprot_attr[3])
            cache_value[2] = 1'b1;
          else
            cache_value[3] = 1'b1;
        end
      end
      f_axi_cache = cache_value;
    end
  endfunction

  // Input qualification creates a single request queue entry and preserves AHB beat ordering.
  assign w_req_hs = w_req_valid & w_req_ready;
  assign w_data_hs = w_data_valid & w_data_ready;
  assign w_input_err = f_local_error(w_req_addr[1:0], w_req_size, w_req_burst,
                                     w_req_prot[6:2], w_req_lock);
  // Burst length selects fixed-burst capture depth or single-transfer handling.
  assign w_input_burst_len = f_hburst_len(w_req_burst);
  assign w_input_eligible = ~w_input_err &
                            f_burst_eligible(w_req_trans, w_req_wr, w_req_burst,
                                             w_req_prot[6], w_req_prot[4],
                                             w_req_prot[3], w_req_prot[2],
                                             w_req_lock);
  // Eligible buffered writes may acknowledge each stored nonterminal beat early.
  assign w_input_early_ack = w_input_eligible ? (w_input_burst_len > 5'd1) :
                             (reg_in_burst_active & (w_req_trans == 2'b11) &
                              ~w_input_err &
                              ((reg_in_burst_count + 5'd1) < reg_in_burst_expected));
  // Detect an incomplete fixed burst so captured beats can drain as AXI singles.
  assign w_burst_term = (((reg_fsm_ctrl_current_state == ENUM_ST_WR_CAPTURE) &
                          reg_in_burst_active) |
                         ((reg_fsm_ctrl_current_state == ENUM_ST_IDLE) &
                          w_wr_cmd_start & w_idle_cmd_eligible)) &
                         (~i_ahb_hsel |
                          ((i_ahb_htrans != 2'b11) & (i_ahb_htrans != 2'b01)) |
                          (i_ahb_hready & i_ahb_htrans[1] & w_input_err));
  // Backpressure write data only when the pending beat cannot enter the FIFO.
  assign w_data_ready = i_rst_n_core & (~reg_data_store | ~w_wr_data_full);
  // An early AHB OKAY is valid only after the corresponding data enters the FIFO.
  assign w_early_ack_now = w_data_hs & reg_data_store & reg_data_early_ack &
                           ~w_burst_term;
  // Hold an early response if the AHB response phase is not ready this cycle.
  assign w_early_ack_pending = w_early_ack_now & ~w_ahb_rsp_ready;
  assign w_ahb_rsp_valid = reg_rsp_valid |
                           (reg_early_rsp_valid & ~w_burst_term) |
                           w_early_ack_now;
  // Early buffer acknowledgements are OKAY; terminal errors come from AXI status.
  assign w_ahb_rsp_err = reg_early_rsp_valid | w_early_ack_now ?
                            1'b0 : reg_rsp_err;
  // Read data remains associated with the controller's final response record.
  assign w_ahb_rsp_data = reg_rsp_data;
  // Only consume a final controller response when no early response owns the phase.
  assign w_reg_rsp_ready = w_ahb_rsp_ready & ~reg_early_rsp_valid &
                           ~w_early_ack_now;

  // The five synchronous FIFOs separate accepted commands, payload and AXI responses.
  assign w_cmd_wr_data = {w_req_addr, w_req_trans, w_req_wr, w_req_size,
                          w_req_burst, w_req_prot, w_req_nonsec, w_req_lock};
  // Route each accepted address descriptor to its read or write command queue.
  assign w_wr_cmd_wr_en = w_req_hs & w_req_wr;
  assign w_rd_cmd_wr_en = w_req_hs & ~w_req_wr;
  assign w_wr_data_wr_data = {w_data, w_strb};
  assign w_wr_data_wr_en = w_data_hs & reg_data_store;
  assign w_rd_rsp_wr_data = {w_axi_r_data, w_axi_r_sts};
  assign w_rd_rsp_wr_en = w_rd_r_hs;
  assign w_wr_rsp_wr_data = w_axi_b_sts;
  assign w_wr_rsp_wr_en = w_wr_b_hs;

  // Address metadata is read from the selected command queue without changing its encoding.
  assign w_idle_cmd_start  = w_rd_cmd_start | w_wr_cmd_start;
  assign w_idle_cmd_addr   = w_rd_cmd_start ? w_rd_cmd_rd_data[49:18] :
                             w_wr_cmd_rd_data[49:18];
  // Decode the remaining fields from the selected show-ahead command descriptor.
  assign w_idle_cmd_htrans = w_rd_cmd_start ? w_rd_cmd_rd_data[17:16] :
                             w_wr_cmd_rd_data[17:16];
  // Preserve the operation direction with the selected command descriptor.
  assign w_idle_cmd_wr  = w_rd_cmd_start ? w_rd_cmd_rd_data[15] :
                             w_wr_cmd_rd_data[15];
  // Preserve the transfer size for AXI request generation.
  assign w_idle_cmd_size   = w_rd_cmd_start ? w_rd_cmd_rd_data[14:12] :
                             w_wr_cmd_rd_data[14:12];
  // Preserve the AHB burst code for aggregation eligibility checks.
  assign w_idle_cmd_burst  = w_rd_cmd_start ? w_rd_cmd_rd_data[11:9] :
                             w_wr_cmd_rd_data[11:9];
  // Preserve protection attributes for validation and AXI mapping.
  assign w_idle_cmd_prot   = w_rd_cmd_start ? w_rd_cmd_rd_data[8:2] :
                             w_wr_cmd_rd_data[8:2];
  // Preserve security state for AXI protection mapping.
  assign w_idle_cmd_nonsec = w_rd_cmd_start ? w_rd_cmd_rd_data[1] :
                             w_wr_cmd_rd_data[1];
  // Preserve the lock bit so unsupported locked transfers are rejected.
  assign w_idle_cmd_lock   = w_rd_cmd_start ? w_rd_cmd_rd_data[0] :
                             w_wr_cmd_rd_data[0];
  // Validate the selected descriptor before it enters the transaction FSM.
  assign w_idle_cmd_err = f_local_error(w_idle_cmd_addr[1:0], w_idle_cmd_size,
                                        w_idle_cmd_burst, w_idle_cmd_prot[6:2],
                                        w_idle_cmd_lock);
  // Select fixed Normal Write-back write bursts for complete capture.
  assign w_idle_cmd_eligible = f_burst_eligible(
    w_idle_cmd_htrans, w_idle_cmd_wr, w_idle_cmd_burst, w_idle_cmd_prot[6],
    w_idle_cmd_prot[4], w_idle_cmd_prot[3], w_idle_cmd_prot[2], w_idle_cmd_lock);

  // Decode the write descriptor at the head of the burst-capture queue.
  assign w_cap_cmd_addr   = w_wr_cmd_rd_data[49:18];
  assign w_cap_cmd_htrans = w_wr_cmd_rd_data[17:16];
  assign w_cap_cmd_wr  = w_wr_cmd_rd_data[15];
  assign w_cap_cmd_size   = w_wr_cmd_rd_data[14:12];
  assign w_cap_cmd_burst  = w_wr_cmd_rd_data[11:9];
  assign w_cap_cmd_prot   = w_wr_cmd_rd_data[8:2];
  assign w_cap_cmd_nonsec = w_wr_cmd_rd_data[1];
  assign w_cap_cmd_lock   = w_wr_cmd_rd_data[0];
  // Validate each queued beat before adding it to the captured burst prefix.
  assign w_cap_cmd_err = f_local_error(w_cap_cmd_addr[1:0], w_cap_cmd_size,
                                       w_cap_cmd_burst, w_cap_cmd_prot[6:2],
                                       w_cap_cmd_lock);
  // Stop capture when AHB ends the burst or a queued descriptor is not a valid SEQ beat.
  assign w_cap_stop = w_burst_term |
                      (~w_wr_cmd_empty &
                       ((w_cap_cmd_htrans != 2'b11) | ~w_cap_cmd_wr |
                        w_cap_cmd_err));
  // Pop only valid sequential write beats while the expected burst has room.
  assign w_cap_pop = (reg_fsm_ctrl_current_state == ENUM_ST_WR_CAPTURE) &
                     ~w_wr_cmd_empty & (reg_burst_count < reg_burst_expected) &
                     (w_cap_cmd_htrans == 2'b11) & w_cap_cmd_wr &
                     ~w_cap_cmd_err;

  // Static selection checks keep the aggregated AXI burst inside one 4 KiB page.
  always_comb begin : p_com_burst_sub_len
    w_burst_sub_len = 5'd1;
    if (reg_burst_start < reg_burst_count) begin
      for (int idx = 0; idx < 16; idx++) begin
        if ((idx > reg_burst_start) & (idx < reg_burst_count) &
            (idx == $bits(idx)'(reg_burst_start + w_burst_sub_len)) &
            (reg_burst_addr[idx][31:12] ==
             reg_burst_addr[reg_burst_start[3:0]][31:12]))
          w_burst_sub_len = $bits(w_burst_sub_len)'(
                              $bits(w_burst_sub_len)'(idx) - reg_burst_start + 5'd1);
      end
    end
  end

  // Track 4 KiB split segments and the remaining captured single-beat writes.
  assign w_more_burst_segments =
    (reg_burst_start + w_burst_sub_len) < reg_burst_count;
  // Advance fallback writes until every captured beat has received a B response.
  assign w_more_fallback_beats = (reg_burst_widx + 5'd1) < reg_burst_count;
  assign w_burst_axi_burst = ((reg_burst_type[0] == 3'b010) |
                              (reg_burst_type[0] == 3'b100) |
                              (reg_burst_type[0] == 3'b110)) ? 2'b10 : 2'b01;

  // FIFO reads are show-ahead. A command is captured on the same edge that advances its pointer.
  always_comb begin : p_com_fifo_ctrl
    w_rd_cmd_start      = (reg_fsm_ctrl_current_state == ENUM_ST_IDLE) &
                          ~w_rd_cmd_empty;
    w_wr_cmd_start      = (reg_fsm_ctrl_current_state == ENUM_ST_IDLE) &
                          w_rd_cmd_empty & ~w_wr_cmd_empty;
    w_rd_cmd_rd_en      = w_rd_cmd_start;
    w_wr_cmd_rd_en      = w_wr_cmd_start | w_cap_pop;
    w_wr_data_rd_en     = w_axi_w_valid & w_axi_w_ready;
    w_rd_rsp_rd_en      = (reg_fsm_ctrl_current_state == ENUM_ST_RD_RSP) &
                          ~w_rd_rsp_empty & ~reg_rsp_valid;
    w_wr_rsp_rd_en      = ((reg_fsm_ctrl_current_state == ENUM_ST_WR_B) |
                           (reg_fsm_ctrl_current_state == ENUM_ST_WR_BBURST)) &
                          ~w_wr_rsp_empty;
  end

  // Request admission leaves queue space for the current AHB data phase and burst drain.
  always_comb begin : p_com_req_ready
    w_req_ready = 1'b0;
    if (i_rst_n_core) begin
      case (reg_fsm_ctrl_current_state)
        ENUM_ST_IDLE, ENUM_ST_AHB_RSP: begin
          case (w_req_wr)
            1'b1:    w_req_ready = ~w_wr_cmd_full;
            default: w_req_ready = ~w_rd_cmd_full;
          endcase
        end
        ENUM_ST_WR_CAPTURE:
          w_req_ready = ~w_wr_cmd_full & reg_in_burst_active &
                        (w_req_trans == 2'b11) & w_req_wr & ~w_input_err &
                        (reg_in_burst_count < reg_in_burst_expected) &
                        ~w_burst_term;
        default: w_req_ready = 1'b0;
      endcase
    end
  end

  // The main FSM selects the next transaction phase and recovers unused encodings to IDLE.
  always_comb begin : p_com_fsm_nxt
    w_fsm_ctrl_nxt_state = reg_fsm_ctrl_current_state;
    case (reg_fsm_ctrl_current_state)
      ENUM_ST_IDLE: begin
        if (w_rd_cmd_start) begin
          if (w_idle_cmd_err)
            w_fsm_ctrl_nxt_state = ENUM_ST_LOCAL;
          else
            w_fsm_ctrl_nxt_state = ENUM_ST_RD_AR;
        end else if (w_wr_cmd_start) begin
          if (w_idle_cmd_err)
            w_fsm_ctrl_nxt_state = ENUM_ST_LOCAL;
          else if (w_idle_cmd_eligible)
            w_fsm_ctrl_nxt_state = ENUM_ST_WR_CAPTURE;
          else
            w_fsm_ctrl_nxt_state = ENUM_ST_WR_SINGLE;
        end
      end
      ENUM_ST_RD_AR: begin
        if (w_axi_ar_hs)
          w_fsm_ctrl_nxt_state = ENUM_ST_RD_RSP;
      end
      ENUM_ST_RD_RSP: begin
        if (w_rd_rsp_rd_en)
          w_fsm_ctrl_nxt_state = ENUM_ST_AHB_RSP;
      end
      ENUM_ST_WR_SINGLE: begin
        if ((reg_aw_done | w_axi_aw_hs) & (reg_w_done | w_axi_w_hs))
          w_fsm_ctrl_nxt_state = ENUM_ST_WR_B;
      end
      ENUM_ST_WR_B: begin
        if (w_wr_rsp_rd_en) begin
          if (reg_burst_fallback & w_more_fallback_beats)
            w_fsm_ctrl_nxt_state = ENUM_ST_WR_SINGLE;
          else
            w_fsm_ctrl_nxt_state = ENUM_ST_AHB_RSP;
        end
      end
      ENUM_ST_WR_CAPTURE: begin
        if ((reg_burst_count >= reg_burst_expected) &
            (reg_data_count >= reg_burst_expected)) begin
          if (reg_burst_fallback)
            w_fsm_ctrl_nxt_state = ENUM_ST_WR_SINGLE;
          else
            w_fsm_ctrl_nxt_state = ENUM_ST_WR_BURST;
        end else if ((reg_burst_term_seen | w_cap_stop) & ~w_cap_pop &
                     (reg_data_count >= reg_burst_count)) begin
          w_fsm_ctrl_nxt_state = ENUM_ST_WR_SINGLE;
        end
      end
      ENUM_ST_WR_BURST: begin
        if ((reg_aw_done | w_axi_aw_hs) & (reg_w_done | w_axi_w_hs))
          w_fsm_ctrl_nxt_state = ENUM_ST_WR_BBURST;
      end
      ENUM_ST_WR_BBURST: begin
        if (w_wr_rsp_rd_en) begin
          if (w_more_burst_segments)
            w_fsm_ctrl_nxt_state = ENUM_ST_WR_BURST;
          else
            w_fsm_ctrl_nxt_state = ENUM_ST_AHB_RSP;
        end
      end
      ENUM_ST_LOCAL: w_fsm_ctrl_nxt_state = ENUM_ST_AHB_RSP;
      ENUM_ST_AHB_RSP: begin
        if (reg_rsp_valid & w_reg_rsp_ready)
          w_fsm_ctrl_nxt_state = ENUM_ST_IDLE;
      end
      default: w_fsm_ctrl_nxt_state = ENUM_ST_IDLE;
    endcase
  end

  // AXI request payload stays fixed until its VALID/READY handshake completes.
  always_comb begin : p_com_axi_req
    w_axi_aw_valid = 1'b0;
    w_axi_aw_id    = reg_wr_id;
    w_axi_aw_addr  = '0;
    w_axi_aw_len   = '0;
    w_axi_aw_size  = '0;
    w_axi_aw_burst = 2'b01;
    w_axi_aw_cache = '0;
    w_axi_aw_prot  = '0;
    w_axi_w_valid  = 1'b0;
    w_axi_w_data   = w_wr_data_rd_data[35:4];
    w_axi_w_strb   = w_wr_data_rd_data[3:0];
    w_axi_w_last   = 1'b0;
    w_axi_ar_valid = 1'b0;
    w_axi_ar_id    = reg_rd_id;
    w_axi_ar_addr  = reg_cmd_addr;
    w_axi_ar_len   = 8'd0;
    w_axi_ar_size  = reg_cmd_size;
    w_axi_ar_burst = 2'b01;
    w_axi_ar_cache = f_axi_cache(reg_cmd_prot[5:2], 1'b0);
    w_axi_ar_prot  = f_axi_prot(reg_cmd_prot[1:0], reg_cmd_nonsec);

    if (reg_fsm_ctrl_current_state == ENUM_ST_RD_AR)
      w_axi_ar_valid = 1'b1;

    if ((reg_fsm_ctrl_current_state == ENUM_ST_WR_SINGLE) & ~w_wr_data_empty) begin
      w_axi_aw_valid = ~reg_aw_done;
      w_axi_w_valid  = reg_aw_done & ~reg_w_done;
      w_axi_w_last   = 1'b1;
      w_axi_aw_len   = 8'd0;
      w_axi_aw_burst = 2'b01;
      if (reg_burst_fallback) begin
        w_axi_aw_addr  = reg_burst_addr[reg_burst_widx[3:0]];
        w_axi_aw_size  = reg_burst_size[reg_burst_widx[3:0]];
        w_axi_aw_cache = f_axi_cache(reg_burst_prot[reg_burst_widx[3:0]][5:2], 1'b1);
        w_axi_aw_prot  = f_axi_prot(reg_burst_prot[reg_burst_widx[3:0]][1:0],
                                    reg_burst_nonsec[reg_burst_widx[3:0]]);
      end else begin
        w_axi_aw_addr  = reg_cmd_addr;
        w_axi_aw_size  = reg_cmd_size;
        w_axi_aw_cache = f_axi_cache(reg_cmd_prot[5:2], 1'b1);
        w_axi_aw_prot  = f_axi_prot(reg_cmd_prot[1:0], reg_cmd_nonsec);
      end
    end

    if ((reg_fsm_ctrl_current_state == ENUM_ST_WR_BURST) & ~w_wr_data_empty) begin
      w_axi_aw_valid = ~reg_aw_done;
      w_axi_w_valid  = reg_aw_done & ~reg_w_done;
      w_axi_aw_addr  = reg_burst_addr[reg_burst_start[3:0]];
      w_axi_aw_len   = $bits(w_axi_aw_len)'(w_burst_sub_len - 5'd1);
      w_axi_aw_size  = reg_burst_size[reg_burst_start[3:0]];
      w_axi_aw_burst = w_burst_axi_burst;
      w_axi_aw_cache = f_axi_cache(reg_burst_prot[reg_burst_start[3:0]][5:2], 1'b1);
      w_axi_aw_prot  = f_axi_prot(reg_burst_prot[reg_burst_start[3:0]][1:0],
                                  reg_burst_nonsec[reg_burst_start[3:0]]);
      w_axi_w_last   = (reg_burst_widx + 5'd1) ==
                       (reg_burst_start + w_burst_sub_len);
    end
  end

  // AXI response capture uses the selected response FIFOs and accepts only matching IDs.
  always_comb begin : p_com_axi_rsp
    w_axi_b_ready = 1'b0;
    w_axi_r_ready = 1'b0;
    if (((reg_fsm_ctrl_current_state == ENUM_ST_WR_SINGLE) |
         (reg_fsm_ctrl_current_state == ENUM_ST_WR_B) |
         (reg_fsm_ctrl_current_state == ENUM_ST_WR_BURST) |
         (reg_fsm_ctrl_current_state == ENUM_ST_WR_BBURST)) &
        ~w_wr_rsp_full & (w_axi_b_id == reg_wr_id))
      w_axi_b_ready = 1'b1;
    if (((reg_fsm_ctrl_current_state == ENUM_ST_RD_AR) |
         (reg_fsm_ctrl_current_state == ENUM_ST_RD_RSP)) &
        ~w_rd_rsp_full & (w_axi_r_id == reg_rd_id) & w_axi_r_last)
      w_axi_r_ready = 1'b1;
  end

  // Derive handshakes only from VALID and READY of their matching AXI channels.
  assign w_aw_hs = w_axi_aw_valid & w_axi_aw_ready;
  assign w_w_hs = w_axi_w_valid & w_axi_w_ready;
  assign w_ar_hs = w_axi_ar_valid & w_axi_ar_ready;
  assign w_wr_b_hs = w_axi_b_valid & w_axi_b_ready;
  assign w_rd_r_hs = w_axi_r_valid & w_axi_r_ready;
  assign w_axi_aw_hs = w_aw_hs;
  assign w_axi_w_hs = w_w_hs;
  assign w_axi_ar_hs = w_ar_hs;
  assign w_rsp_err_now = (w_wr_rsp_rd_data[1:0] != 2'b00);

  // The FSM state register is separate from datapath state for independent synthesis handling.
  always_ff @(posedge i_clk_core, negedge i_rst_n_core) begin : p_ff_ctrl_state
    if (!i_rst_n_core)
      reg_fsm_ctrl_current_state <= ENUM_ST_IDLE;
    else
      reg_fsm_ctrl_current_state <= w_fsm_ctrl_nxt_state;
  end

  // Payload and handshake state use asynchronous assertion and externally synchronized release.
  always_ff @(posedge i_clk_core, negedge i_rst_n_core) begin : p_ff_ctrl
    if (!i_rst_n_core) begin
      reg_cmd_addr               <= '0;
      reg_cmd_size               <= '0;
      reg_cmd_prot               <= '0;
      reg_cmd_nonsec             <= 1'b0;
      reg_burst_count            <= '0;
      reg_burst_expected         <= '0;
      reg_burst_start            <= '0;
      reg_burst_widx             <= '0;
      reg_burst_fallback         <= 1'b0;
      reg_burst_term_seen        <= 1'b0;
      reg_burst_err            <= 1'b0;
      reg_in_burst_active        <= 1'b0;
      reg_in_burst_count         <= '0;
      reg_in_burst_expected      <= '0;
      reg_data_store             <= 1'b0;
      reg_data_early_ack         <= 1'b0;
      reg_data_count             <= '0;
      reg_aw_done                <= 1'b0;
      reg_w_done                 <= 1'b0;
      reg_rd_id                  <= '0;
      reg_wr_id                  <= '0;
      reg_rsp_valid              <= 1'b0;
      reg_rsp_err              <= 1'b0;
      reg_rsp_data               <= '0;
      reg_early_rsp_valid        <= 1'b0;
    end else begin
      if (w_req_hs) begin
        reg_data_store     <= w_req_wr & ~w_input_err;
        reg_data_early_ack <= w_input_early_ack;
        if (w_input_eligible) begin
          reg_in_burst_active   <= 1'b1;
          reg_in_burst_count    <= 5'd1;
          reg_in_burst_expected <= w_input_burst_len;
        end else if (reg_in_burst_active & (w_req_trans == 2'b11) &
                     ~w_input_err) begin
          reg_in_burst_count <= reg_in_burst_count + 5'd1;
          if ((reg_in_burst_count + 5'd1) >= reg_in_burst_expected)
            reg_in_burst_active <= 1'b0;
        end else begin
          reg_in_burst_active   <= 1'b0;
          reg_in_burst_count    <= '0;
          reg_in_burst_expected <= '0;
        end
      end else if (w_burst_term) begin
        reg_in_burst_active <= 1'b0;
        reg_data_early_ack  <= 1'b0;
      end

      if (w_data_hs & reg_data_store) begin
        if (w_early_ack_pending)
          reg_early_rsp_valid <= 1'b1;
      end
      if (w_ahb_rsp_ready & reg_early_rsp_valid)
        reg_early_rsp_valid <= 1'b0;
      if (w_burst_term)
        reg_early_rsp_valid <= 1'b0;

      case ({w_wr_data_wr_en, w_wr_data_rd_en})
        2'b10: reg_data_count <= reg_data_count + 5'd1;
        2'b01: reg_data_count <= reg_data_count - 5'd1;
        default: reg_data_count <= reg_data_count;
      endcase

      if (w_idle_cmd_start) begin
        reg_cmd_addr   <= w_idle_cmd_addr;
        reg_cmd_size   <= w_idle_cmd_size;
        reg_cmd_prot   <= w_idle_cmd_prot[5:0];
        reg_cmd_nonsec <= w_idle_cmd_nonsec;
        reg_aw_done    <= 1'b0;
        reg_w_done     <= 1'b0;
        reg_burst_fallback <= 1'b0;
        reg_burst_widx     <= '0;
        if (w_idle_cmd_eligible & ~w_idle_cmd_err) begin
          reg_burst_addr[0]    <= w_idle_cmd_addr;
          reg_burst_size[0]    <= w_idle_cmd_size;
          reg_burst_type[0]    <= w_idle_cmd_burst;
          reg_burst_prot[0]    <= w_idle_cmd_prot;
          reg_burst_nonsec[0]  <= w_idle_cmd_nonsec;
          reg_burst_count      <= 5'd1;
          reg_burst_expected   <= f_hburst_len(w_idle_cmd_burst);
          reg_burst_start      <= '0;
          reg_burst_widx       <= '0;
          reg_burst_fallback   <= 1'b0;
          reg_burst_term_seen  <= 1'b0;
          reg_burst_err      <= 1'b0;
        end
      end

      if (w_cap_pop) begin
        reg_burst_addr[reg_burst_count[3:0]]   <= w_cap_cmd_addr;
        reg_burst_size[reg_burst_count[3:0]]   <= w_cap_cmd_size;
        reg_burst_type[reg_burst_count[3:0]]   <= w_cap_cmd_burst;
        reg_burst_prot[reg_burst_count[3:0]]   <= w_cap_cmd_prot;
        reg_burst_nonsec[reg_burst_count[3:0]] <= w_cap_cmd_nonsec;
        reg_burst_count <= reg_burst_count + 5'd1;
        if ((w_cap_cmd_size != reg_burst_size[0]) |
            (w_cap_cmd_burst != reg_burst_type[0]) |
            (f_axi_prot(w_cap_cmd_prot[1:0], w_cap_cmd_nonsec) !=
             f_axi_prot(reg_burst_prot[0][1:0], reg_burst_nonsec[0])) |
            (f_axi_cache(w_cap_cmd_prot[5:2], 1'b1) !=
             f_axi_cache(reg_burst_prot[0][5:2], 1'b1)))
          reg_burst_fallback <= 1'b1;
      end

      if (w_cap_stop) begin
        reg_burst_term_seen <= 1'b1;
        reg_burst_fallback  <= 1'b1;
      end

      if ((reg_fsm_ctrl_current_state == ENUM_ST_WR_CAPTURE) &
          (w_fsm_ctrl_nxt_state == ENUM_ST_WR_BURST)) begin
        reg_burst_start <= '0;
        reg_burst_widx  <= '0;
        reg_aw_done     <= 1'b0;
        reg_w_done      <= 1'b0;
      end
      if ((reg_fsm_ctrl_current_state == ENUM_ST_WR_CAPTURE) &
          (w_fsm_ctrl_nxt_state == ENUM_ST_WR_SINGLE)) begin
        reg_burst_widx <= '0;
        reg_aw_done    <= 1'b0;
        reg_w_done     <= 1'b0;
        reg_burst_fallback <= 1'b1;
      end

      if (reg_fsm_ctrl_current_state == ENUM_ST_WR_SINGLE) begin
        if (w_axi_aw_hs)
          reg_aw_done <= 1'b1;
        if (w_axi_w_hs)
          reg_w_done <= 1'b1;
      end
      if (reg_fsm_ctrl_current_state == ENUM_ST_WR_BURST) begin
        if (w_axi_aw_hs)
          reg_aw_done <= 1'b1;
        if (w_axi_w_hs) begin
          reg_burst_widx <= reg_burst_widx + 5'd1;
          if (w_axi_w_last)
            reg_w_done <= 1'b1;
        end
      end

      if (w_wr_rsp_rd_en) begin
        if (reg_wr_id == $bits(reg_wr_id)'(PARA_WR_ID_COUNT - 32'd1))
          reg_wr_id <= '0;
        else
          reg_wr_id <= $bits(reg_wr_id)'(reg_wr_id + 3'd1);
        reg_aw_done <= 1'b0;
        reg_w_done  <= 1'b0;
        if (reg_fsm_ctrl_current_state == ENUM_ST_WR_B) begin
          if (reg_burst_fallback) begin
            reg_burst_err <= reg_burst_err | w_rsp_err_now;
            if (w_more_fallback_beats)
              reg_burst_widx <= reg_burst_widx + 5'd1;
            else begin
              reg_rsp_valid <= 1'b1;
              reg_rsp_err <= reg_burst_err | w_rsp_err_now;
              reg_rsp_data  <= '0;
            end
          end else begin
            reg_rsp_valid <= 1'b1;
            reg_rsp_err <= w_rsp_err_now;
            reg_rsp_data  <= '0;
          end
        end else begin
          reg_burst_err <= reg_burst_err | w_rsp_err_now;
          if (w_more_burst_segments) begin
            reg_burst_start <= reg_burst_start + w_burst_sub_len;
            reg_burst_widx  <= reg_burst_start + w_burst_sub_len;
          end else begin
            reg_rsp_valid <= 1'b1;
            reg_rsp_err <= reg_burst_err | w_rsp_err_now;
            reg_rsp_data  <= '0;
          end
        end
      end

      if (w_rd_rsp_rd_en) begin
        if (reg_rd_id == $bits(reg_rd_id)'(PARA_RD_ID_COUNT - 32'd1))
          reg_rd_id <= '0;
        else
          reg_rd_id <= $bits(reg_rd_id)'(reg_rd_id + 3'd1);
        reg_rsp_valid <= 1'b1;
        reg_rsp_err <= (w_rd_rsp_rd_data[1:0] != 2'b00);
        reg_rsp_data  <= w_rd_rsp_rd_data[33:2];
      end

      if (reg_fsm_ctrl_current_state == ENUM_ST_LOCAL) begin
        reg_rsp_valid <= 1'b1;
        reg_rsp_err <= 1'b1;
        reg_rsp_data  <= '0;
      end

      if (reg_rsp_valid & w_reg_rsp_ready)
        reg_rsp_valid <= 1'b0;
    end
  end

  // The central controller owns the AHB and AXI protocol boundary instances.
  m_ahb2axi_ahb_if u_ahb2axi_ahb_if (
    .i_clk_core       (i_clk_core),
    .i_rst_n_core     (i_rst_n_core),
    .i_ahb_hsel       (i_ahb_hsel),
    .i_ahb_hready     (i_ahb_hready),
    .i_ahb_haddr      (i_ahb_haddr),
    .i_ahb_htrans     (i_ahb_htrans),
    .i_ahb_hwrite     (i_ahb_hwrite),
    .i_ahb_hsize      (i_ahb_hsize),
    .i_ahb_hburst     (i_ahb_hburst),
    .i_ahb_hprot      (i_ahb_hprot),
    .i_ahb_hnonsec    (i_ahb_hnonsec),
    .i_ahb_hmastlock  (i_ahb_hmastlock),
    .i_ahb_hwdata     (i_ahb_hwdata),
    .i_ahb_hwstrb     (i_ahb_hwstrb),
    .o_ahb_hreadyout  (o_ahb_hreadyout),
    .o_ahb_hresp      (o_ahb_hresp),
    .o_ahb_hrdata     (o_ahb_hrdata),
    .o_req_valid      (w_req_valid),
    .i_req_ready      (w_req_ready),
    .o_req_addr       (w_req_addr),
    .o_req_trans      (w_req_trans),
    .o_req_wr      (w_req_wr),
    .o_req_size       (w_req_size),
    .o_req_burst      (w_req_burst),
    .o_req_prot       (w_req_prot),
    .o_req_nonsec     (w_req_nonsec),
    .o_req_lock       (w_req_lock),
    .o_data_valid     (w_data_valid),
    .i_data_ready     (w_data_ready),
    .o_data           (w_data),
    .o_strb           (w_strb),
    .i_rsp_valid      (w_ahb_rsp_valid),
    .o_rsp_ready      (w_ahb_rsp_ready),
    .i_rsp_err      (w_ahb_rsp_err),
    .i_rsp_data       (w_ahb_rsp_data)
  );

  m_ahb2axi_axi_if u_ahb2axi_axi_if (
    .i_rst_n_core     (i_rst_n_core),
    .o_axi_awid       (o_axi_awid),
    .o_axi_awaddr     (o_axi_awaddr),
    .o_axi_awlen      (o_axi_awlen),
    .o_axi_awsize     (o_axi_awsize),
    .o_axi_awburst    (o_axi_awburst),
    .o_axi_awlock     (o_axi_awlock),
    .o_axi_awcache    (o_axi_awcache),
    .o_axi_awprot     (o_axi_awprot),
    .o_axi_awvalid    (o_axi_awvalid),
    .i_axi_awready    (i_axi_awready),
    .o_axi_wdata      (o_axi_wdata),
    .o_axi_wstrb      (o_axi_wstrb),
    .o_axi_wlast      (o_axi_wlast),
    .o_axi_wvalid     (o_axi_wvalid),
    .i_axi_wready     (i_axi_wready),
    .i_axi_bid        (i_axi_bid),
    .i_axi_bresp      (i_axi_bresp),
    .i_axi_bvalid     (i_axi_bvalid),
    .o_axi_bready     (o_axi_bready),
    .o_axi_arid       (o_axi_arid),
    .o_axi_araddr     (o_axi_araddr),
    .o_axi_arlen      (o_axi_arlen),
    .o_axi_arsize     (o_axi_arsize),
    .o_axi_arburst    (o_axi_arburst),
    .o_axi_arlock     (o_axi_arlock),
    .o_axi_arcache    (o_axi_arcache),
    .o_axi_arprot     (o_axi_arprot),
    .o_axi_arvalid    (o_axi_arvalid),
    .i_axi_arready    (i_axi_arready),
    .i_axi_rid        (i_axi_rid),
    .i_axi_rdata      (i_axi_rdata),
    .i_axi_rresp      (i_axi_rresp),
    .i_axi_rlast      (i_axi_rlast),
    .i_axi_rvalid     (i_axi_rvalid),
    .o_axi_rready     (o_axi_rready),
    .i_req_aw_valid   (w_axi_aw_valid),
    .o_req_aw_ready   (w_axi_aw_ready),
    .i_req_aw_id      (w_axi_aw_id),
    .i_req_aw_addr    (w_axi_aw_addr),
    .i_req_aw_len     (w_axi_aw_len),
    .i_req_aw_size    (w_axi_aw_size),
    .i_req_aw_burst   (w_axi_aw_burst),
    .i_req_aw_cache   (w_axi_aw_cache),
    .i_req_aw_prot    (w_axi_aw_prot),
    .i_req_w_valid    (w_axi_w_valid),
    .o_req_w_ready    (w_axi_w_ready),
    .i_req_w_data     (w_axi_w_data),
    .i_req_w_strb     (w_axi_w_strb),
    .i_req_w_last     (w_axi_w_last),
    .o_resp_b_valid   (w_axi_b_valid),
    .i_resp_b_ready   (w_axi_b_ready),
    .o_resp_b_id      (w_axi_b_id),
    .o_resp_b_sts  (w_axi_b_sts),
    .i_req_ar_valid   (w_axi_ar_valid),
    .o_req_ar_ready   (w_axi_ar_ready),
    .i_req_ar_id      (w_axi_ar_id),
    .i_req_ar_addr    (w_axi_ar_addr),
    .i_req_ar_len     (w_axi_ar_len),
    .i_req_ar_size    (w_axi_ar_size),
    .i_req_ar_burst   (w_axi_ar_burst),
    .i_req_ar_cache   (w_axi_ar_cache),
    .i_req_ar_prot    (w_axi_ar_prot),
    .o_resp_r_valid   (w_axi_r_valid),
    .i_resp_r_ready   (w_axi_r_ready),
    .o_resp_r_id      (w_axi_r_id),
    .o_resp_r_data    (w_axi_r_data),
    .o_resp_r_sts  (w_axi_r_sts),
    .o_resp_r_last    (w_axi_r_last)
  );

  // Command and payload queues are the only storage for accepted requests and write data.
  m_vlsit_sfifo_top #(
    .PARA_SFIFO_DEPTH  (LPARA_CMD_DEPTH),
    .PARA_SFIFO_DATA_W (LPARA_CMD_W)
  ) u_vlsit_sfifo_top_0 (
    .i_clk_wr       (i_clk_core),
    .i_rst_n_wr     (i_rst_n_core),
    .i_wr_en        (w_wr_cmd_wr_en),
    .i_wr_data      (w_cmd_wr_data),
    .i_full_thr     ('0),
    .o_full         (w_wr_cmd_full),
    .o_full_thr     (),
    .o_overflow     (),
    .i_rst_n_sw     (1'b1),
    .o_sw_rst_busy  (),
    .i_clk_rd       (i_clk_core),
    .i_rst_n_rd     (i_rst_n_core),
    .i_rd_en        (w_wr_cmd_rd_en),
    .i_empty_thr    ('0),
    .o_rd_data      (w_wr_cmd_rd_data),
    .o_empty        (w_wr_cmd_empty),
    .o_empty_thr    (),
    .o_underflow    ()
  );

  m_vlsit_sfifo_top #(
    .PARA_SFIFO_DEPTH  (LPARA_DATA_DEPTH),
    .PARA_SFIFO_DATA_W (LPARA_DATA_W)
  ) u_vlsit_sfifo_top_1 (
    .i_clk_wr       (i_clk_core),
    .i_rst_n_wr     (i_rst_n_core),
    .i_wr_en        (w_wr_data_wr_en),
    .i_wr_data      (w_wr_data_wr_data),
    .i_full_thr     ('0),
    .o_full         (w_wr_data_full),
    .o_full_thr     (),
    .o_overflow     (),
    .i_rst_n_sw     (1'b1),
    .o_sw_rst_busy  (),
    .i_clk_rd       (i_clk_core),
    .i_rst_n_rd     (i_rst_n_core),
    .i_rd_en        (w_wr_data_rd_en),
    .i_empty_thr    ('0),
    .o_rd_data      (w_wr_data_rd_data),
    .o_empty        (w_wr_data_empty),
    .o_empty_thr    (),
    .o_underflow    ()
  );

  m_vlsit_sfifo_top #(
    .PARA_SFIFO_DEPTH  (LPARA_CMD_DEPTH),
    .PARA_SFIFO_DATA_W (LPARA_CMD_W)
  ) u_vlsit_sfifo_top_2 (
    .i_clk_wr       (i_clk_core),
    .i_rst_n_wr     (i_rst_n_core),
    .i_wr_en        (w_rd_cmd_wr_en),
    .i_wr_data      (w_cmd_wr_data),
    .i_full_thr     ('0),
    .o_full         (w_rd_cmd_full),
    .o_full_thr     (),
    .o_overflow     (),
    .i_rst_n_sw     (1'b1),
    .o_sw_rst_busy  (),
    .i_clk_rd       (i_clk_core),
    .i_rst_n_rd     (i_rst_n_core),
    .i_rd_en        (w_rd_cmd_rd_en),
    .i_empty_thr    ('0),
    .o_rd_data      (w_rd_cmd_rd_data),
    .o_empty        (w_rd_cmd_empty),
    .o_empty_thr    (),
    .o_underflow    ()
  );

  m_vlsit_sfifo_top #(
    .PARA_SFIFO_DEPTH  (LPARA_RSP_DEPTH),
    .PARA_SFIFO_DATA_W (LPARA_RD_RSP_W)
  ) u_vlsit_sfifo_top_3 (
    .i_clk_wr       (i_clk_core),
    .i_rst_n_wr     (i_rst_n_core),
    .i_wr_en        (w_rd_rsp_wr_en),
    .i_wr_data      (w_rd_rsp_wr_data),
    .i_full_thr     ('0),
    .o_full         (w_rd_rsp_full),
    .o_full_thr     (),
    .o_overflow     (),
    .i_rst_n_sw     (1'b1),
    .o_sw_rst_busy  (),
    .i_clk_rd       (i_clk_core),
    .i_rst_n_rd     (i_rst_n_core),
    .i_rd_en        (w_rd_rsp_rd_en),
    .i_empty_thr    ('0),
    .o_rd_data      (w_rd_rsp_rd_data),
    .o_empty        (w_rd_rsp_empty),
    .o_empty_thr    (),
    .o_underflow    ()
  );

  m_vlsit_sfifo_top #(
    .PARA_SFIFO_DEPTH  (LPARA_RSP_DEPTH),
    .PARA_SFIFO_DATA_W (LPARA_WR_RSP_W)
  ) u_vlsit_sfifo_top_4 (
    .i_clk_wr       (i_clk_core),
    .i_rst_n_wr     (i_rst_n_core),
    .i_wr_en        (w_wr_rsp_wr_en),
    .i_wr_data      (w_wr_rsp_wr_data),
    .i_full_thr     ('0),
    .o_full         (w_wr_rsp_full),
    .o_full_thr     (),
    .o_overflow     (),
    .i_rst_n_sw     (1'b1),
    .o_sw_rst_busy  (),
    .i_clk_rd       (i_clk_core),
    .i_rst_n_rd     (i_rst_n_core),
    .i_rd_en        (w_wr_rsp_rd_en),
    .i_empty_thr    ('0),
    .o_rd_data      (w_wr_rsp_rd_data),
    .o_empty        (w_wr_rsp_empty),
    .o_empty_thr    (),
    .o_underflow    ()
  );

endmodule
