/*
 * Project      : VLSIT Common RTL library
 * Author       : Nguyen Quan and Claude Sonnet 5.5 (user)
 * AI Flow      : VLSIT RTL Generator AI Automation Flow
 * AI Flow Page : https://github.com/nguyenquanicd/VLSIT_RTL_Generator_AI_Model
 * Date         : 2026-10-25
 * Description  : Round-robin transaction owner and shared APB4 controller for the AXI2APB bridge.
 */
`timescale 1ns/1ps

module m_axi2apb_apb_ctrl (
  // Shared clock and synchronous reset
  input  wire         i_clk_axi,
  input  wire         i_rst_n_axi,

  // AXI transaction ownership
  input  wire         i_axi_arvalid,
  input  wire         i_axi_awvalid,
  input  wire         i_rd_ready,
  input  wire         i_wr_ready,
  input  wire         i_rd_done,
  input  wire         i_wr_done,
  output logic        o_gnt_rd,
  output logic        o_gnt_wr,

  // APB read request and response
  input  wire         i_rd_req_valid,
  input  wire  [31:0] i_rd_req_addr,
  input  wire  [2:0]  i_rd_req_prot,
  output logic        o_rd_req_ready,
  output logic        o_rd_rsp_valid,
  output logic [31:0] o_rd_rsp_data,
  output logic        o_rd_rsp_err,

  // APB write request and response
  input  wire         i_wr_req_valid,
  input  wire  [31:0] i_wr_req_addr,
  input  wire  [31:0] i_wr_req_data,
  input  wire  [3:0]  i_wr_req_strb,
  input  wire  [2:0]  i_wr_req_prot,
  output logic        o_wr_req_ready,
  output logic        o_wr_rsp_valid,
  output logic        o_wr_rsp_err,

  // APB4 Completer interface
  input  wire         i_apb_pready,
  input  wire  [31:0] i_apb_prdata,
  input  wire         i_apb_pslverr,
  output logic [31:0] o_apb_paddr,
  output logic        o_apb_pwrite,
  output logic [31:0] o_apb_pwdata,
  output logic [3:0]  o_apb_pstrb,
  output logic [2:0]  o_apb_pprot,
  output logic        o_apb_psel,
  output logic        o_apb_penable
);

  // Owner FSM states: IDLE selects a pending channel; grant states hold through acceptance.
  typedef enum logic [2:0] {
    ENUM_ST_IDLE  = 3'd0,
    ENUM_ST_GRD   = 3'd1,
    ENUM_ST_GRW   = 3'd2,
    ENUM_ST_ACTRD = 3'd3,
    ENUM_ST_ACTWR = 3'd4
  } ctrl_state_type_def;

  // APB FSM states: SETUP is followed by ACCESS until PREADY is sampled high.
  typedef enum logic [1:0] {
    ENUM_ST_APB_IDLE = 2'd0,
    ENUM_ST_APB_SETUP = 2'd1,
    ENUM_ST_APB_ACCESS = 2'd2
  } apb_state_type_def;

  // Registered state and APB request/response payload.
  ctrl_state_type_def reg_fsm_ctrl_current_state;
  ctrl_state_type_def w_fsm_ctrl_nxt_state;
  apb_state_type_def reg_fsm_apb_current_state;
  apb_state_type_def w_fsm_apb_nxt_state;
  logic reg_turn_rd;
  logic [31:0] reg_apb_addr;
  logic reg_apb_wr;
  logic [31:0] reg_apb_wdata;
  logic [3:0] reg_apb_strb;
  logic [2:0] reg_apb_prot;
  logic reg_rd_rsp_valid;
  logic [31:0] reg_rd_rsp_data;
  logic reg_rd_rsp_err;
  logic reg_wr_rsp_valid;
  logic reg_wr_rsp_err;

  // Select the first tie as read and alternate preference after each completed transaction.
  always_comb begin : p_com_arb_fsm
    w_fsm_ctrl_nxt_state = reg_fsm_ctrl_current_state;
    case (reg_fsm_ctrl_current_state)
      ENUM_ST_IDLE: begin
        if (reg_turn_rd) begin
          casez ({i_axi_arvalid, i_axi_awvalid})
            2'b1?: w_fsm_ctrl_nxt_state = ENUM_ST_GRD;
            2'b01: w_fsm_ctrl_nxt_state = ENUM_ST_GRW;
            default: w_fsm_ctrl_nxt_state = ENUM_ST_IDLE;
          endcase
        end else begin
          casez ({i_axi_awvalid, i_axi_arvalid})
            2'b1?: w_fsm_ctrl_nxt_state = ENUM_ST_GRW;
            2'b01: w_fsm_ctrl_nxt_state = ENUM_ST_GRD;
            default: w_fsm_ctrl_nxt_state = ENUM_ST_IDLE;
          endcase
        end
      end
      ENUM_ST_GRD: begin
        if (i_axi_arvalid && i_rd_ready)
          w_fsm_ctrl_nxt_state = ENUM_ST_ACTRD;
      end
      ENUM_ST_GRW: begin
        if (i_axi_awvalid && i_wr_ready)
          w_fsm_ctrl_nxt_state = ENUM_ST_ACTWR;
      end
      ENUM_ST_ACTRD: begin
        if (i_rd_done)
          w_fsm_ctrl_nxt_state = ENUM_ST_IDLE;
      end
      ENUM_ST_ACTWR: begin
        if (i_wr_done)
          w_fsm_ctrl_nxt_state = ENUM_ST_IDLE;
      end
      default: begin
        w_fsm_ctrl_nxt_state = ENUM_ST_IDLE;
      end
    endcase
  end

  // Convert an accepted request into a registered APB setup/access transfer.
  always_comb begin : p_com_apb_fsm
    w_fsm_apb_nxt_state = reg_fsm_apb_current_state;
    case (reg_fsm_apb_current_state)
      ENUM_ST_APB_IDLE: begin
        if ((o_gnt_rd && i_rd_req_valid) || (o_gnt_wr && i_wr_req_valid))
          w_fsm_apb_nxt_state = ENUM_ST_APB_SETUP;
      end
      ENUM_ST_APB_SETUP: begin
        w_fsm_apb_nxt_state = ENUM_ST_APB_ACCESS;
      end
      ENUM_ST_APB_ACCESS: begin
        if (i_apb_pready)
          w_fsm_apb_nxt_state = ENUM_ST_APB_IDLE;
      end
      default: begin
        w_fsm_apb_nxt_state = ENUM_ST_APB_IDLE;
      end
    endcase
  end

  // Decode grants from registered owner state and APB phases from registered payload.
  always_comb begin : p_com_outputs
    o_gnt_rd       = 1'b0;
    o_gnt_wr       = 1'b0;
    o_rd_req_ready = 1'b0;
    o_rd_rsp_valid = reg_rd_rsp_valid;
    o_rd_rsp_data  = reg_rd_rsp_data;
    o_rd_rsp_err   = reg_rd_rsp_err;
    o_wr_req_ready = 1'b0;
    o_wr_rsp_valid = reg_wr_rsp_valid;
    o_wr_rsp_err   = reg_wr_rsp_err;
    o_apb_paddr    = 32'd0;
    o_apb_pwrite   = 1'b0;
    o_apb_pwdata   = 32'd0;
    o_apb_pstrb    = 4'd0;
    o_apb_pprot    = 3'd0;
    o_apb_psel     = 1'b0;
    o_apb_penable  = 1'b0;

    case (reg_fsm_ctrl_current_state)
      ENUM_ST_GRD, ENUM_ST_ACTRD: o_gnt_rd = 1'b1;
      ENUM_ST_GRW, ENUM_ST_ACTWR: o_gnt_wr = 1'b1;
      default: begin
        o_gnt_rd = 1'b0;
        o_gnt_wr = 1'b0;
      end
    endcase

    if (reg_fsm_apb_current_state == ENUM_ST_APB_IDLE) begin
      o_rd_req_ready = o_gnt_rd;
      o_wr_req_ready = o_gnt_wr;
    end

    case (reg_fsm_apb_current_state)
      ENUM_ST_APB_SETUP: begin
        o_apb_paddr  = reg_apb_addr;
        o_apb_pwrite = reg_apb_wr;
        o_apb_pwdata = reg_apb_wdata;
        o_apb_pstrb  = reg_apb_strb;
        o_apb_pprot  = reg_apb_prot;
        o_apb_psel   = 1'b1;
      end
      ENUM_ST_APB_ACCESS: begin
        o_apb_paddr   = reg_apb_addr;
        o_apb_pwrite  = reg_apb_wr;
        o_apb_pwdata  = reg_apb_wdata;
        o_apb_pstrb   = reg_apb_strb;
        o_apb_pprot   = reg_apb_prot;
        o_apb_psel    = 1'b1;
        o_apb_penable = 1'b1;
      end
      default: begin
        o_apb_paddr   = 32'd0;
        o_apb_pwrite  = 1'b0;
        o_apb_pwdata  = 32'd0;
        o_apb_pstrb   = 4'd0;
        o_apb_pprot   = 3'd0;
        o_apb_psel    = 1'b0;
        o_apb_penable = 1'b0;
      end
    endcase
  end

  // Register arbitration ownership and the next transaction preference.
  always_ff @(posedge i_clk_axi) begin : p_ff_arb
    if (!i_rst_n_axi) begin
      reg_fsm_ctrl_current_state <= ENUM_ST_IDLE;
      reg_turn_rd                <= 1'b1;
    end else begin
      reg_fsm_ctrl_current_state <= w_fsm_ctrl_nxt_state;
      if ((reg_fsm_ctrl_current_state == ENUM_ST_ACTRD) && i_rd_done)
        reg_turn_rd <= 1'b0;
      else if ((reg_fsm_ctrl_current_state == ENUM_ST_ACTWR) && i_wr_done)
        reg_turn_rd <= 1'b1;
    end
  end

  // Capture APB payload once, hold it through wait states, and pulse its AXI-side response.
  always_ff @(posedge i_clk_axi) begin : p_ff_apb
    if (!i_rst_n_axi) begin
      reg_fsm_apb_current_state <= ENUM_ST_APB_IDLE;
      reg_apb_addr              <= '0;
      reg_apb_wr             <= 1'b0;
      reg_apb_wdata             <= '0;
      reg_apb_strb              <= '0;
      reg_apb_prot              <= '0;
      reg_rd_rsp_valid          <= 1'b0;
      reg_rd_rsp_data           <= '0;
      reg_rd_rsp_err            <= 1'b0;
      reg_wr_rsp_valid          <= 1'b0;
      reg_wr_rsp_err            <= 1'b0;
    end else begin
      reg_fsm_apb_current_state <= w_fsm_apb_nxt_state;
      reg_rd_rsp_valid          <= 1'b0;
      reg_wr_rsp_valid          <= 1'b0;

      if ((reg_fsm_apb_current_state == ENUM_ST_APB_IDLE) &&
          o_gnt_rd && i_rd_req_valid && o_rd_req_ready) begin
        reg_apb_addr  <= i_rd_req_addr;
        reg_apb_wr <= 1'b0;
        reg_apb_wdata <= 32'd0;
        reg_apb_strb  <= 4'd0;
        reg_apb_prot  <= i_rd_req_prot;
      end else if ((reg_fsm_apb_current_state == ENUM_ST_APB_IDLE) &&
                   o_gnt_wr && i_wr_req_valid && o_wr_req_ready) begin
        reg_apb_addr  <= i_wr_req_addr;
        reg_apb_wr <= 1'b1;
        reg_apb_wdata <= i_wr_req_data;
        reg_apb_strb  <= i_wr_req_strb;
        reg_apb_prot  <= i_wr_req_prot;
      end

      if ((reg_fsm_apb_current_state == ENUM_ST_APB_ACCESS) && i_apb_pready) begin
        if (reg_apb_wr) begin
          reg_wr_rsp_valid <= 1'b1;
          reg_wr_rsp_err   <= i_apb_pslverr;
        end else begin
          reg_rd_rsp_valid <= 1'b1;
          reg_rd_rsp_data  <= i_apb_prdata;
          reg_rd_rsp_err   <= i_apb_pslverr;
        end
      end
    end
  end

endmodule
