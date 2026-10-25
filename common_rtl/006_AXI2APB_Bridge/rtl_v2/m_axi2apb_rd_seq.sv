/*
 * Project      : VLSIT Common RTL library
 * Author       : Nguyen Quan and Claude Sonnet 5.5 (user)
 * AI Flow      : VLSIT RTL Generator AI Automation Flow
 * AI Flow Page : https://github.com/nguyenquanicd/VLSIT_RTL_Generator_AI_Model
 * Date         : 2026-10-25
 * Description  : AXI4 read sequencer for the AXI2APB bridge. It validates each AR request,
 *                issues one APB read per beat, and returns ordered R responses under backpressure.
 */
`timescale 1ns/1ps

module m_axi2apb_rd_seq #(
  // Parameter Description: AXI read and write ID width used on the AXI R channel.
  // Parameter values: 1 through 16 inclusive; default is 4.
  // Parameter unit: bit
  parameter logic [31:0] PARA_AXI_ID_W = 32'd4,
  localparam logic [31:0] LPARA_COUNT_ONE       = 32'd1,
  localparam logic [31:0] LPARA_RESP_OKAY       = 32'd0,
  localparam logic [31:0] LPARA_RESP_SLVERR     = 32'd2,
  localparam logic [31:0] LPARA_SIZE_MAX        = 32'd2,
  localparam logic [31:0] LPARA_BURST_FIXED     = 32'd0,
  localparam logic [31:0] LPARA_BURST_INCR      = 32'd1,
  localparam logic [31:0] LPARA_BURST_WRAP      = 32'd2,
  localparam logic [31:0] LPARA_CACHE_DEV_NB    = 32'd0,
  localparam logic [31:0] LPARA_CACHE_DEV_B     = 32'd1,
  localparam logic [31:0] LPARA_FIXED_MAX_LEN   = 32'd15,
  localparam logic [31:0] LPARA_WRAP_LEN_2      = 32'd1,
  localparam logic [31:0] LPARA_WRAP_LEN_4      = 32'd3,
  localparam logic [31:0] LPARA_WRAP_LEN_8      = 32'd7,
  localparam logic [31:0] LPARA_WRAP_LEN_16     = 32'd15,
  localparam logic [31:0] LPARA_WRAP_LOG2_2     = 32'd1,
  localparam logic [31:0] LPARA_WRAP_LOG2_4     = 32'd2,
  localparam logic [31:0] LPARA_WRAP_LOG2_8     = 32'd3,
  localparam logic [31:0] LPARA_WRAP_LOG2_16    = 32'd4,
  localparam logic [31:0] LPARA_4K_PAGE_SHIFT  = 32'd12
) (
  // Clock and synchronous reset
  input  wire                      i_clk_axi,
  input  wire                      i_rst_n_axi,

  // Transaction ownership
  input  wire                      i_gnt_rd,
  output logic                     o_rd_ready,
  output logic                     o_rd_done,

  // AXI read address channel
  input  wire  [PARA_AXI_ID_W-1:0] i_axi_arid,
  input  wire  [31:0]              i_axi_araddr,
  input  wire  [7:0]               i_axi_arlen,
  input  wire  [2:0]               i_axi_arsize,
  input  wire  [1:0]               i_axi_arburst,
  input  wire  [3:0]               i_axi_arcache,
  input  wire  [2:0]               i_axi_arprot,
  input  wire                      i_axi_arvalid,
  output logic                     o_axi_arready,

  // AXI read response channel
  input  wire                      i_axi_rready,
  output logic [PARA_AXI_ID_W-1:0] o_axi_rid,
  output logic [31:0]              o_axi_rdata,
  output logic [1:0]               o_axi_rresp,
  output logic                     o_axi_rlast,
  output logic                     o_axi_rvalid,

  // APB read request channel
  output logic                     o_req_valid,
  output logic [31:0]              o_req_addr,
  output logic [2:0]               o_req_prot,
  input  wire                      i_req_ready,

  // APB read response channel
  input  wire                      i_rsp_valid,
  input  wire  [31:0]              i_rsp_data,
  input  wire                      i_rsp_err
);

  // FSM state declarations
  typedef enum logic [2:0] {
    ENUM_ST_IDLE = 3'd0,
    ENUM_ST_REQ  = 3'd1,
    ENUM_ST_WAIT = 3'd2,
    ENUM_ST_RESP = 3'd3,
    ENUM_ST_ERR  = 3'd4
  } rd_state_type_def;

  // Internal signal declarations
  rd_state_type_def reg_fsm_rd_current_state;
  rd_state_type_def w_fsm_rd_nxt_state;
  logic [PARA_AXI_ID_W-1:0] reg_rd_id;
  logic [31:0] reg_rd_addr;
  logic [7:0] reg_rd_len;
  logic [2:0] reg_rd_size;
  logic [1:0] reg_rd_burst;
  logic [2:0] reg_rd_prot;
  logic [8:0] reg_rd_beats_left;
  logic [31:0] reg_rd_data;
  logic [1:0] reg_rd_resp;
  logic w_ar_valid;
  logic w_ar_wrap_len_valid;
  logic w_ar_cross_4k;
  logic [31:0] w_ar_size_bytes;
  logic [8:0] w_ar_beats;
  logic [3:0] w_ar_wrap_log2;
  logic [3:0] w_ar_wrap_shift;
  logic [31:0] w_ar_wrap_bytes;
  logic [31:0] w_ar_wrap_mask;
  logic [31:0] w_ar_wrap_base;
  logic [31:0] w_ar_base_addr;
  logic [32:0] w_ar_total_bytes;
  logic [20:0] w_ar_end_page;
  logic [31:0] w_rd_size_bytes;
  logic [31:0] w_rd_size_mask;
  logic [3:0] w_rd_wrap_log2;
  logic [3:0] w_rd_wrap_shift;
  logic [31:0] w_rd_wrap_bytes;
  logic [31:0] w_rd_wrap_mask;
  logic [31:0] w_rd_wrap_base;
  logic [31:0] w_rd_addr_plus_size;
  logic [31:0] w_rd_nxt_addr;

  // Request validation and 4-KiB range calculation use the accepted AR payload.
  always_comb begin : p_com_ar_check
    w_ar_valid           = 1'b1;
    w_ar_wrap_len_valid  = 1'b0;
    w_ar_cross_4k        = 1'b0;
    w_ar_size_bytes      = $bits(w_ar_size_bytes)'(LPARA_COUNT_ONE << i_axi_arsize);
    w_ar_beats           = $bits(w_ar_beats)'({1'b0, i_axi_arlen} + LPARA_COUNT_ONE);
    w_ar_wrap_log2       = 4'd0;
    w_ar_wrap_shift      = 4'd0;
    w_ar_wrap_bytes      = LPARA_COUNT_ONE;
    w_ar_wrap_mask       = '0;
    w_ar_wrap_base       = i_axi_araddr & w_ar_wrap_mask;
    w_ar_base_addr       = $bits(w_ar_base_addr)'(
                             i_axi_araddr & ~(w_ar_size_bytes - LPARA_COUNT_ONE));
    w_ar_total_bytes     = {1'b0, w_ar_size_bytes};
    w_ar_end_page        = '0;

    case (i_axi_arlen)
      LPARA_WRAP_LEN_2[7:0]: begin
        w_ar_wrap_len_valid = 1'b1;
        w_ar_wrap_log2      = LPARA_WRAP_LOG2_2[3:0];
      end
      LPARA_WRAP_LEN_4[7:0]: begin
        w_ar_wrap_len_valid = 1'b1;
        w_ar_wrap_log2      = LPARA_WRAP_LOG2_4[3:0];
      end
      LPARA_WRAP_LEN_8[7:0]: begin
        w_ar_wrap_len_valid = 1'b1;
        w_ar_wrap_log2      = LPARA_WRAP_LOG2_8[3:0];
      end
      LPARA_WRAP_LEN_16[7:0]: begin
        w_ar_wrap_len_valid = 1'b1;
        w_ar_wrap_log2      = LPARA_WRAP_LOG2_16[3:0];
      end
      default: begin
        w_ar_wrap_len_valid = 1'b0;
        w_ar_wrap_log2      = 4'd0;
      end
    endcase

    w_ar_wrap_shift = $bits(w_ar_wrap_shift)'(i_axi_arsize + w_ar_wrap_log2);
    w_ar_wrap_bytes = $bits(w_ar_wrap_bytes)'(LPARA_COUNT_ONE << w_ar_wrap_shift);
    w_ar_wrap_mask  = $bits(w_ar_wrap_mask)'(~(w_ar_wrap_bytes - LPARA_COUNT_ONE));
    w_ar_wrap_base  = i_axi_araddr & w_ar_wrap_mask;

    case (i_axi_arburst)
      LPARA_BURST_FIXED[1:0]: begin
        w_ar_base_addr   = $bits(w_ar_base_addr)'(
                             i_axi_araddr & ~(w_ar_size_bytes - LPARA_COUNT_ONE));
        w_ar_total_bytes = {1'b0, w_ar_size_bytes};
        if (i_axi_arlen > LPARA_FIXED_MAX_LEN[7:0])
          w_ar_valid = 1'b0;
      end
      LPARA_BURST_INCR[1:0]: begin
        w_ar_base_addr   = $bits(w_ar_base_addr)'(
                             i_axi_araddr & ~(w_ar_size_bytes - LPARA_COUNT_ONE));
        w_ar_total_bytes = $bits(w_ar_total_bytes)'({24'd0, w_ar_beats} << i_axi_arsize);
      end
      LPARA_BURST_WRAP[1:0]: begin
        w_ar_base_addr   = w_ar_wrap_base;
        w_ar_total_bytes = {1'b0, w_ar_wrap_bytes};
        if (!w_ar_wrap_len_valid ||
            ((i_axi_araddr & (w_ar_size_bytes - LPARA_COUNT_ONE)) != 32'd0))
          w_ar_valid = 1'b0;
      end
      default: begin
        w_ar_base_addr   = i_axi_araddr & ~(w_ar_size_bytes - LPARA_COUNT_ONE);
        w_ar_total_bytes = {1'b0, w_ar_size_bytes};
        w_ar_valid       = 1'b0;
      end
    endcase

    w_ar_end_page = $bits(w_ar_end_page)'(({1'b0, w_ar_base_addr} +
                                           w_ar_total_bytes - 33'd1) >>
                                          LPARA_4K_PAGE_SHIFT);
    w_ar_cross_4k = (w_ar_end_page != {1'b0, i_axi_araddr[31:12]});

    if (i_axi_arsize > LPARA_SIZE_MAX[2:0])
      w_ar_valid = 1'b0;
    if ((i_axi_arcache != LPARA_CACHE_DEV_NB[3:0]) &&
        (i_axi_arcache != LPARA_CACHE_DEV_B[3:0]))
      w_ar_valid = 1'b0;
    if (w_ar_cross_4k)
      w_ar_valid = 1'b0;
  end

  // The next AXI beat address follows FIXED, INCR, or WRAP burst address rules.
  always_comb begin : p_com_rd_addr
    w_rd_size_bytes = $bits(w_rd_size_bytes)'(LPARA_COUNT_ONE << reg_rd_size);
    w_rd_size_mask  = $bits(w_rd_size_mask)'(w_rd_size_bytes - LPARA_COUNT_ONE);
    w_rd_wrap_log2  = 4'd0;
    w_rd_wrap_shift = 4'd0;
    w_rd_wrap_bytes = LPARA_COUNT_ONE;
    w_rd_wrap_mask  = '0;
    w_rd_wrap_base  = reg_rd_addr & w_rd_wrap_mask;
    w_rd_addr_plus_size = $bits(w_rd_addr_plus_size)'(reg_rd_addr + w_rd_size_bytes);
    w_rd_nxt_addr  = reg_rd_addr;

    case (reg_rd_len)
      LPARA_WRAP_LEN_2[7:0]: begin
        w_rd_wrap_log2 = LPARA_WRAP_LOG2_2[3:0];
      end
      LPARA_WRAP_LEN_4[7:0]: begin
        w_rd_wrap_log2 = LPARA_WRAP_LOG2_4[3:0];
      end
      LPARA_WRAP_LEN_8[7:0]: begin
        w_rd_wrap_log2 = LPARA_WRAP_LOG2_8[3:0];
      end
      LPARA_WRAP_LEN_16[7:0]: begin
        w_rd_wrap_log2 = LPARA_WRAP_LOG2_16[3:0];
      end
      default: begin
        w_rd_wrap_log2 = 4'd0;
      end
    endcase

    w_rd_wrap_shift = $bits(w_rd_wrap_shift)'(reg_rd_size + w_rd_wrap_log2);
    w_rd_wrap_bytes = $bits(w_rd_wrap_bytes)'(LPARA_COUNT_ONE << w_rd_wrap_shift);
    w_rd_wrap_mask  = $bits(w_rd_wrap_mask)'(~(w_rd_wrap_bytes - LPARA_COUNT_ONE));
    w_rd_wrap_base  = reg_rd_addr & w_rd_wrap_mask;

    case (reg_rd_burst)
      LPARA_BURST_FIXED[1:0]: begin
        w_rd_nxt_addr = reg_rd_addr;
      end
      LPARA_BURST_INCR[1:0]: begin
        w_rd_nxt_addr = $bits(w_rd_nxt_addr)'((reg_rd_addr & ~w_rd_size_mask) + w_rd_size_bytes);
      end
      LPARA_BURST_WRAP[1:0]: begin
        if ((w_rd_addr_plus_size & w_rd_wrap_mask) != w_rd_wrap_base)
          w_rd_nxt_addr = w_rd_wrap_base;
        else
          w_rd_nxt_addr = w_rd_addr_plus_size;
      end
      default: begin
        w_rd_nxt_addr = reg_rd_addr;
      end
    endcase
  end

  // Read sequencer state transitions include one APB request and one AXI response per beat.
  always_comb begin : p_com_rd_fsm
    w_fsm_rd_nxt_state = reg_fsm_rd_current_state;
    case (reg_fsm_rd_current_state)
      ENUM_ST_IDLE: begin
        if (i_gnt_rd && i_axi_arvalid) begin
          if (w_ar_valid)
            w_fsm_rd_nxt_state = ENUM_ST_REQ;
          else
            w_fsm_rd_nxt_state = ENUM_ST_ERR;
        end
      end
      ENUM_ST_REQ: begin
        if (i_req_ready)
          w_fsm_rd_nxt_state = ENUM_ST_WAIT;
      end
      ENUM_ST_WAIT: begin
        if (i_rsp_valid)
          w_fsm_rd_nxt_state = ENUM_ST_RESP;
      end
      ENUM_ST_RESP: begin
        if (i_axi_rready) begin
          if (reg_rd_beats_left == 9'd1)
            w_fsm_rd_nxt_state = ENUM_ST_IDLE;
          else
            w_fsm_rd_nxt_state = ENUM_ST_REQ;
        end
      end
      ENUM_ST_ERR: begin
        if (i_axi_rready) begin
          if (reg_rd_beats_left == 9'd1)
            w_fsm_rd_nxt_state = ENUM_ST_IDLE;
          else
            w_fsm_rd_nxt_state = ENUM_ST_ERR;
        end
      end
      default: begin
        w_fsm_rd_nxt_state = ENUM_ST_IDLE;
      end
    endcase
  end

  // AXI and APB outputs are decoded from registered state and payload only.
  always_comb begin : p_com_rd_outputs
    o_rd_ready     = 1'b0;
    o_rd_done      = 1'b0;
    o_axi_arready  = 1'b0;
    o_axi_rid      = reg_rd_id;
    o_axi_rdata    = reg_rd_data;
    o_axi_rresp    = reg_rd_resp;
    o_axi_rlast    = 1'b0;
    o_axi_rvalid   = 1'b0;
    o_req_valid    = 1'b0;
    o_req_addr     = {reg_rd_addr[31:2], 2'b00};
    o_req_prot     = reg_rd_prot;

    if (reg_fsm_rd_current_state == ENUM_ST_IDLE) begin
      o_rd_ready    = 1'b1;
      o_axi_arready = i_gnt_rd;
    end
    if (reg_fsm_rd_current_state == ENUM_ST_REQ)
      o_req_valid = 1'b1;
    if ((reg_fsm_rd_current_state == ENUM_ST_RESP) ||
        (reg_fsm_rd_current_state == ENUM_ST_ERR)) begin
      o_axi_rvalid = 1'b1;
      o_axi_rlast  = (reg_rd_beats_left == 9'd1);
    end
    if (reg_fsm_rd_current_state == ENUM_ST_ERR) begin
      o_axi_rdata = 32'd0;
      o_axi_rresp = LPARA_RESP_SLVERR[1:0];
    end
    if (o_axi_rvalid && i_axi_rready && o_axi_rlast)
      o_rd_done = 1'b1;
  end

  // Register the current state of the AXI read FSM.
  always_ff @(posedge i_clk_axi) begin : p_ff_fsm_rd
    if (!i_rst_n_axi)
      reg_fsm_rd_current_state <= ENUM_ST_IDLE;
    else
      reg_fsm_rd_current_state <= w_fsm_rd_nxt_state;
  end

  // Register the transaction context and advance only after each R handshake.
  always_ff @(posedge i_clk_axi) begin : p_ff_rd_state
    if (!i_rst_n_axi) begin
      reg_rd_id          <= '0;
      reg_rd_addr        <= '0;
      reg_rd_len         <= '0;
      reg_rd_size        <= '0;
      reg_rd_burst       <= '0;
      reg_rd_prot        <= '0;
      reg_rd_beats_left  <= '0;
      reg_rd_data        <= '0;
      reg_rd_resp        <= LPARA_RESP_OKAY[1:0];
    end else begin
      if ((reg_fsm_rd_current_state == ENUM_ST_IDLE) && i_gnt_rd && i_axi_arvalid) begin
        reg_rd_id         <= i_axi_arid;
        reg_rd_addr       <= i_axi_araddr;
        reg_rd_len        <= i_axi_arlen;
        reg_rd_size       <= i_axi_arsize;
        reg_rd_burst      <= i_axi_arburst;
        reg_rd_prot       <= i_axi_arprot;
        reg_rd_beats_left <= $bits(reg_rd_beats_left)'({1'b0, i_axi_arlen} + LPARA_COUNT_ONE);
        reg_rd_data       <= 32'd0;
        if (w_ar_valid)
          reg_rd_resp <= LPARA_RESP_OKAY[1:0];
        else
          reg_rd_resp <= LPARA_RESP_SLVERR[1:0];
      end
      if ((reg_fsm_rd_current_state == ENUM_ST_WAIT) && i_rsp_valid) begin
        if (i_rsp_err) begin
          reg_rd_data <= 32'd0;
          reg_rd_resp <= LPARA_RESP_SLVERR[1:0];
        end else begin
          reg_rd_data <= i_rsp_data;
          reg_rd_resp <= LPARA_RESP_OKAY[1:0];
        end
      end
      if (((reg_fsm_rd_current_state == ENUM_ST_RESP) ||
           (reg_fsm_rd_current_state == ENUM_ST_ERR)) && i_axi_rready &&
          (reg_rd_beats_left != 9'd1)) begin
        reg_rd_beats_left <= $bits(reg_rd_beats_left)'(reg_rd_beats_left - 9'd1);
        reg_rd_addr       <= w_rd_nxt_addr;
        if (reg_fsm_rd_current_state == ENUM_ST_ERR) begin
          reg_rd_data <= 32'd0;
          reg_rd_resp <= LPARA_RESP_SLVERR[1:0];
        end
      end
    end
  end

endmodule
