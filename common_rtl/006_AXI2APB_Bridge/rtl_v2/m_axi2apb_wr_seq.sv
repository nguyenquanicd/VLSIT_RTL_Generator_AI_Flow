/*
 * Project      : VLSIT Common RTL library
 * Author       : Nguyen Quan and Claude Sonnet 5.5 (user)
 * AI Flow      : VLSIT RTL Generator AI Automation Flow
 * AI Flow Page : https://github.com/nguyenquanicd/VLSIT_RTL_Generator_AI_Model
 * Date         : 2026-10-25
 * Description  : AXI4 write sequencer; validates AW and aggregates APB write errors.
 */
`timescale 1ns/1ps

module m_axi2apb_wr_seq #(
  // Parameter Description: Shared width of AXI read and write transaction IDs.
  // Parameter values: 1 through 16 inclusive; default is 4.
  // Parameter unit: bit
  parameter logic [31:0] PARA_AXI_ID_W = 32'd4,
  localparam logic [31:0] LPARA_COUNT_ONE = 32'd1,
  localparam logic [31:0] LPARA_RESP_OKAY = 32'd0,
  localparam logic [31:0] LPARA_RESP_SLVERR = 32'd2,
  localparam logic [31:0] LPARA_SIZE_MAX = 32'd2,
  localparam logic [31:0] LPARA_BURST_FIXED = 32'd0,
  localparam logic [31:0] LPARA_BURST_INCR = 32'd1,
  localparam logic [31:0] LPARA_BURST_WRAP = 32'd2,
  localparam logic [31:0] LPARA_CACHE_DEV_NB = 32'd0,
  localparam logic [31:0] LPARA_CACHE_DEV_B = 32'd1,
  localparam logic [31:0] LPARA_FIXED_MAX_LEN = 32'd15,
  localparam logic [31:0] LPARA_WRAP_LEN_2 = 32'd1,
  localparam logic [31:0] LPARA_WRAP_LEN_4 = 32'd3,
  localparam logic [31:0] LPARA_WRAP_LEN_8 = 32'd7,
  localparam logic [31:0] LPARA_WRAP_LEN_16 = 32'd15,
  localparam logic [31:0] LPARA_WRAP_LOG2_2 = 32'd1,
  localparam logic [31:0] LPARA_WRAP_LOG2_4 = 32'd2,
  localparam logic [31:0] LPARA_WRAP_LOG2_8 = 32'd3,
  localparam logic [31:0] LPARA_WRAP_LOG2_16 = 32'd4,
  localparam logic [31:0] LPARA_4K_PAGE_SHIFT = 32'd12
) (
  // Shared clock and synchronous reset
  input  wire                      i_clk_axi,
  input  wire                      i_rst_n_axi,

  // Transaction ownership
  input  wire                      i_gnt_wr,
  output logic                     o_wr_ready,
  output logic                     o_wr_done,

  // AXI write address channel
  input  wire  [PARA_AXI_ID_W-1:0] i_axi_awid,
  input  wire  [31:0]              i_axi_awaddr,
  input  wire  [7:0]               i_axi_awlen,
  input  wire  [2:0]               i_axi_awsize,
  input  wire  [1:0]               i_axi_awburst,
  input  wire  [3:0]               i_axi_awcache,
  input  wire  [2:0]               i_axi_awprot,
  input  wire                      i_axi_awvalid,
  output logic                     o_axi_awready,

  // AXI write data and response channels
  input  wire  [31:0]              i_axi_wdata,
  input  wire  [3:0]               i_axi_wstrb,
  input  wire                      i_axi_wvalid,
  output logic                     o_axi_wready,
  output logic [PARA_AXI_ID_W-1:0] o_axi_bid,
  output logic [1:0]               o_axi_bresp,
  output logic                     o_axi_bvalid,
  input  wire                      i_axi_bready,

  // APB write request
  output logic                     o_req_valid,
  output logic [31:0]              o_req_addr,
  output logic [31:0]              o_req_data,
  output logic [3:0]               o_req_strb,
  output logic [2:0]               o_req_prot,
  input  wire                      i_req_ready,

  // APB write response
  input  wire                      i_rsp_valid,
  input  wire                      i_rsp_err
);

  // FSM states: WAIT_W gathers one declared beat; REQ/WAIT serialize its APB transfer.
  typedef enum logic [2:0] {
    ENUM_ST_IDLE = 3'd0,
    ENUM_ST_WDAT = 3'd1,
    ENUM_ST_REQ  = 3'd2,
    ENUM_ST_WAIT = 3'd3,
    ENUM_ST_DRAIN = 3'd4,
    ENUM_ST_BRESP = 3'd5
  } wr_state_type_def;

  // Internal transaction context, validation results, and next address.
  wr_state_type_def reg_fsm_wr_current_state;
  wr_state_type_def w_fsm_wr_nxt_state;
  logic [PARA_AXI_ID_W-1:0] reg_wr_id;
  logic [31:0] reg_wr_addr;
  logic [7:0] reg_wr_len;
  logic [2:0] reg_wr_size;
  logic [1:0] reg_wr_burst;
  logic [2:0] reg_wr_prot;
  logic [8:0] reg_wr_beats_left;
  logic [31:0] reg_wr_data;
  logic [3:0] reg_wr_strb;
  logic reg_wr_err;
  logic w_aw_valid;
  logic w_aw_wrap_len_valid;
  logic w_aw_cross_4k;
  logic [31:0] w_aw_size_bytes;
  logic [8:0] w_aw_beats;
  logic [3:0] w_aw_wrap_log2;
  logic [3:0] w_aw_wrap_shift;
  logic [31:0] w_aw_wrap_bytes;
  logic [31:0] w_aw_wrap_mask;
  logic [31:0] w_aw_wrap_base;
  logic [31:0] w_aw_base_addr;
  logic [32:0] w_aw_total_bytes;
  logic [20:0] w_aw_end_page;
  logic [31:0] w_wr_size_bytes;
  logic [31:0] w_wr_size_mask;
  logic [3:0] w_wr_wrap_log2;
  logic [3:0] w_wr_wrap_shift;
  logic [31:0] w_wr_wrap_bytes;
  logic [31:0] w_wr_wrap_mask;
  logic [31:0] w_wr_wrap_base;
  logic [31:0] w_wr_addr_plus_size;
  logic [31:0] w_wr_nxt_addr;

  // Validate AW attributes and ensure the declared request stays within one 4-KiB region.
  always_comb begin : p_com_aw_check
    w_aw_valid = 1'b1;
    w_aw_wrap_len_valid = 1'b0;
    w_aw_cross_4k = 1'b0;
    w_aw_size_bytes = $bits(w_aw_size_bytes)'(LPARA_COUNT_ONE << i_axi_awsize);
    w_aw_beats = $bits(w_aw_beats)'({1'b0, i_axi_awlen} + LPARA_COUNT_ONE);
    w_aw_wrap_log2 = 4'd0;
    w_aw_wrap_shift = 4'd0;
    w_aw_wrap_bytes = LPARA_COUNT_ONE;
    w_aw_wrap_mask = '0;
    w_aw_wrap_base = i_axi_awaddr;
    w_aw_base_addr = $bits(w_aw_base_addr)'(
                       i_axi_awaddr & ~(w_aw_size_bytes - LPARA_COUNT_ONE));
    w_aw_total_bytes = {1'b0, w_aw_size_bytes};
    w_aw_end_page = '0;

    case (i_axi_awlen)
      LPARA_WRAP_LEN_2[7:0]: begin
        w_aw_wrap_len_valid = 1'b1;
        w_aw_wrap_log2 = LPARA_WRAP_LOG2_2[3:0];
      end
      LPARA_WRAP_LEN_4[7:0]: begin
        w_aw_wrap_len_valid = 1'b1;
        w_aw_wrap_log2 = LPARA_WRAP_LOG2_4[3:0];
      end
      LPARA_WRAP_LEN_8[7:0]: begin
        w_aw_wrap_len_valid = 1'b1;
        w_aw_wrap_log2 = LPARA_WRAP_LOG2_8[3:0];
      end
      LPARA_WRAP_LEN_16[7:0]: begin
        w_aw_wrap_len_valid = 1'b1;
        w_aw_wrap_log2 = LPARA_WRAP_LOG2_16[3:0];
      end
      default: begin
        w_aw_wrap_len_valid = 1'b0;
        w_aw_wrap_log2 = 4'd0;
      end
    endcase

    w_aw_wrap_shift = $bits(w_aw_wrap_shift)'(i_axi_awsize + w_aw_wrap_log2);
    w_aw_wrap_bytes = $bits(w_aw_wrap_bytes)'(LPARA_COUNT_ONE << w_aw_wrap_shift);
    w_aw_wrap_mask = $bits(w_aw_wrap_mask)'(~(w_aw_wrap_bytes - LPARA_COUNT_ONE));
    w_aw_wrap_base = i_axi_awaddr & w_aw_wrap_mask;

    case (i_axi_awburst)
      LPARA_BURST_FIXED[1:0]: begin
        if (i_axi_awlen > LPARA_FIXED_MAX_LEN[7:0])
          w_aw_valid = 1'b0;
      end
      LPARA_BURST_INCR[1:0]: begin
        w_aw_total_bytes = {24'd0, w_aw_beats} << i_axi_awsize;
      end
      LPARA_BURST_WRAP[1:0]: begin
        w_aw_base_addr = w_aw_wrap_base;
        w_aw_total_bytes = {1'b0, w_aw_wrap_bytes};
        if (!w_aw_wrap_len_valid ||
            ((i_axi_awaddr & (w_aw_size_bytes - LPARA_COUNT_ONE)) != 32'd0))
          w_aw_valid = 1'b0;
      end
      default: begin
        w_aw_valid = 1'b0;
      end
    endcase

    w_aw_end_page = $bits(w_aw_end_page)'(({1'b0, w_aw_base_addr} +
                                           w_aw_total_bytes - 33'd1) >>
                                          LPARA_4K_PAGE_SHIFT);
    w_aw_cross_4k = (w_aw_end_page != {1'b0, i_axi_awaddr[31:12]});
    if (i_axi_awsize > LPARA_SIZE_MAX[2:0])
      w_aw_valid = 1'b0;
    if ((i_axi_awcache != LPARA_CACHE_DEV_NB[3:0]) &&
        (i_axi_awcache != LPARA_CACHE_DEV_B[3:0]))
      w_aw_valid = 1'b0;
    if (w_aw_cross_4k)
      w_aw_valid = 1'b0;
  end

  // Advance FIXED, INCR, and WRAP addresses according to the accepted AW context.
  always_comb begin : p_com_wr_addr
    w_wr_size_bytes = $bits(w_wr_size_bytes)'(LPARA_COUNT_ONE << reg_wr_size);
    w_wr_size_mask = $bits(w_wr_size_mask)'(w_wr_size_bytes - LPARA_COUNT_ONE);
    w_wr_wrap_log2 = 4'd0;
    w_wr_wrap_shift = 4'd0;
    w_wr_wrap_bytes = LPARA_COUNT_ONE;
    w_wr_wrap_mask = '0;
    w_wr_wrap_base = reg_wr_addr;
    w_wr_addr_plus_size = $bits(w_wr_addr_plus_size)'(reg_wr_addr + w_wr_size_bytes);
    w_wr_nxt_addr = reg_wr_addr;

    case (reg_wr_len)
      LPARA_WRAP_LEN_2[7:0]: w_wr_wrap_log2 = LPARA_WRAP_LOG2_2[3:0];
      LPARA_WRAP_LEN_4[7:0]: w_wr_wrap_log2 = LPARA_WRAP_LOG2_4[3:0];
      LPARA_WRAP_LEN_8[7:0]: w_wr_wrap_log2 = LPARA_WRAP_LOG2_8[3:0];
      LPARA_WRAP_LEN_16[7:0]: w_wr_wrap_log2 = LPARA_WRAP_LOG2_16[3:0];
      default: w_wr_wrap_log2 = 4'd0;
    endcase

    w_wr_wrap_shift = $bits(w_wr_wrap_shift)'(reg_wr_size + w_wr_wrap_log2);
    w_wr_wrap_bytes = $bits(w_wr_wrap_bytes)'(LPARA_COUNT_ONE << w_wr_wrap_shift);
    w_wr_wrap_mask = $bits(w_wr_wrap_mask)'(~(w_wr_wrap_bytes - LPARA_COUNT_ONE));
    w_wr_wrap_base = reg_wr_addr & w_wr_wrap_mask;

    case (reg_wr_burst)
      LPARA_BURST_FIXED[1:0]: w_wr_nxt_addr = reg_wr_addr;
      LPARA_BURST_INCR[1:0]:
        w_wr_nxt_addr = $bits(w_wr_nxt_addr)'((reg_wr_addr & ~w_wr_size_mask) + w_wr_size_bytes);
      LPARA_BURST_WRAP[1:0]: begin
        if ((w_wr_addr_plus_size & w_wr_wrap_mask) != w_wr_wrap_base)
          w_wr_nxt_addr = w_wr_wrap_base;
        else
          w_wr_nxt_addr = w_wr_addr_plus_size;
      end
      default: w_wr_nxt_addr = reg_wr_addr;
    endcase
  end

  // Sequence AW acceptance, declared W beats, APB responses, and the final B handshake.
  always_comb begin : p_com_wr_fsm
    w_fsm_wr_nxt_state = reg_fsm_wr_current_state;
    case (reg_fsm_wr_current_state)
      ENUM_ST_IDLE: begin
        if (i_gnt_wr && i_axi_awvalid) begin
          if (w_aw_valid)
            w_fsm_wr_nxt_state = ENUM_ST_WDAT;
          else
            w_fsm_wr_nxt_state = ENUM_ST_DRAIN;
        end
      end
      ENUM_ST_WDAT: begin
        if (i_axi_wvalid)
          w_fsm_wr_nxt_state = ENUM_ST_REQ;
      end
      ENUM_ST_REQ: begin
        if (i_req_ready)
          w_fsm_wr_nxt_state = ENUM_ST_WAIT;
      end
      ENUM_ST_WAIT: begin
        if (i_rsp_valid) begin
          if (reg_wr_beats_left == 9'd0)
            w_fsm_wr_nxt_state = ENUM_ST_BRESP;
          else
            w_fsm_wr_nxt_state = ENUM_ST_WDAT;
        end
      end
      ENUM_ST_DRAIN: begin
        if (i_axi_wvalid && (reg_wr_beats_left == 9'd1))
          w_fsm_wr_nxt_state = ENUM_ST_BRESP;
      end
      ENUM_ST_BRESP: begin
        if (i_axi_bready)
          w_fsm_wr_nxt_state = ENUM_ST_IDLE;
      end
      default: begin
        w_fsm_wr_nxt_state = ENUM_ST_IDLE;
      end
    endcase
  end

  // Hold AXI response payload and APB request payload stable until their handshakes.
  always_comb begin : p_com_wr_outputs
    o_wr_ready = 1'b0;
    o_wr_done = 1'b0;
    o_axi_awready = 1'b0;
    o_axi_wready = 1'b0;
    o_axi_bid = reg_wr_id;
    o_axi_bresp = reg_wr_err ? LPARA_RESP_SLVERR[1:0] : LPARA_RESP_OKAY[1:0];
    o_axi_bvalid = 1'b0;
    o_req_valid = 1'b0;
    o_req_addr = {reg_wr_addr[31:2], 2'b00};
    o_req_data = reg_wr_data;
    o_req_strb = reg_wr_strb;
    o_req_prot = reg_wr_prot;

    if (reg_fsm_wr_current_state == ENUM_ST_IDLE) begin
      o_wr_ready = 1'b1;
      o_axi_awready = i_gnt_wr;
    end
    if ((reg_fsm_wr_current_state == ENUM_ST_WDAT) ||
        (reg_fsm_wr_current_state == ENUM_ST_DRAIN))
      o_axi_wready = 1'b1;
    if (reg_fsm_wr_current_state == ENUM_ST_REQ)
      o_req_valid = 1'b1;
    if (reg_fsm_wr_current_state == ENUM_ST_BRESP)
      o_axi_bvalid = 1'b1;
    if (o_axi_bvalid && i_axi_bready)
      o_wr_done = 1'b1;
  end

  // Register the current state of the AXI write FSM.
  always_ff @(posedge i_clk_axi) begin : p_ff_fsm_wr
    if (!i_rst_n_axi)
      reg_fsm_wr_current_state <= ENUM_ST_IDLE;
    else
      reg_fsm_wr_current_state <= w_fsm_wr_nxt_state;
  end

  // Register the write context and preserve aggregate error status until B is accepted.
  always_ff @(posedge i_clk_axi) begin : p_ff_wr_state
    if (!i_rst_n_axi) begin
      reg_wr_id <= '0;
      reg_wr_addr <= '0;
      reg_wr_len <= '0;
      reg_wr_size <= '0;
      reg_wr_burst <= '0;
      reg_wr_prot <= '0;
      reg_wr_beats_left <= '0;
      reg_wr_data <= '0;
      reg_wr_strb <= '0;
      reg_wr_err <= 1'b0;
    end else begin
      if ((reg_fsm_wr_current_state == ENUM_ST_IDLE) && i_gnt_wr && i_axi_awvalid) begin
        reg_wr_id <= i_axi_awid;
        reg_wr_addr <= i_axi_awaddr;
        reg_wr_len <= i_axi_awlen;
        reg_wr_size <= i_axi_awsize;
        reg_wr_burst <= i_axi_awburst;
        reg_wr_prot <= i_axi_awprot;
        reg_wr_beats_left <= $bits(reg_wr_beats_left)'({1'b0, i_axi_awlen} + LPARA_COUNT_ONE);
        reg_wr_err <= !w_aw_valid;
      end
      if ((reg_fsm_wr_current_state == ENUM_ST_WDAT) && i_axi_wvalid) begin
        reg_wr_data <= i_axi_wdata;
        reg_wr_strb <= i_axi_wstrb;
        reg_wr_beats_left <= $bits(reg_wr_beats_left)'(reg_wr_beats_left - 9'd1);
        reg_wr_addr <= w_wr_nxt_addr;
      end
      if ((reg_fsm_wr_current_state == ENUM_ST_DRAIN) && i_axi_wvalid)
        reg_wr_beats_left <= $bits(reg_wr_beats_left)'(reg_wr_beats_left - 9'd1);
      if ((reg_fsm_wr_current_state == ENUM_ST_WAIT) && i_rsp_valid && i_rsp_err)
        reg_wr_err <= 1'b1;
    end
  end

endmodule
