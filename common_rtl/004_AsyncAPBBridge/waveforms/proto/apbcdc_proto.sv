`timescale 1ns/1ps
// Prototype of the asynchronous APB bridge of AsyncAPBBridge_Design_Specification.md.
// It exists only to produce the waveforms of the specification and to measure the transfer latency.
// It is not the delivered RTL (the RTL is generated later from the specification).
// mst = requester side (the bridge is the APB completer), slv = completer side (the bridge is the APB requester).

module m_vlsit_apbcdc_sync #(
  parameter integer W = 1,
  parameter integer STAGES = 2
) (
  input  wire              i_clk_dst,
  input  wire              i_rst_n_dst,
  input  wire  [W-1:0]     i_data,
  output logic [W-1:0]     o_data
);
  logic [W-1:0] reg_sh [0:3];
  always_ff @(posedge i_clk_dst, negedge i_rst_n_dst) begin : p_ff_sh
    if (!i_rst_n_dst) begin
      reg_sh[0] <= '0; reg_sh[1] <= '0; reg_sh[2] <= '0; reg_sh[3] <= '0;
    end else begin
      reg_sh[0] <= i_data; reg_sh[1] <= reg_sh[0]; reg_sh[2] <= reg_sh[1]; reg_sh[3] <= reg_sh[2];
    end
  end
  assign o_data = (STAGES == 0) ? i_data : reg_sh[STAGES-1];
endmodule

module m_vlsit_apbcdc_mst #(
  parameter integer ADDR_W = 16,
  parameter integer DATA_W = 16,
  parameter integer APB5 = 0,
  parameter integer UREQ_W = 4,
  parameter integer UDAT_W = 4,
  parameter integer URSP_W = 4,
  parameter integer HS = 0,
  parameter integer STAGES = 2,
  localparam integer STRB_W = DATA_W / 8,
  localparam integer REQ_W = ADDR_W + 3 + 1 + STRB_W + DATA_W + UREQ_W + UDAT_W,
  localparam integer RSP_W = DATA_W + 1 + UDAT_W + URSP_W
) (
  input  wire                 i_clk_mst,
  input  wire                 i_rst_n_mst,
  input  wire                 i_apb_psel,
  input  wire                 i_apb_penable,
  input  wire                 i_apb_pwrite,
  input  wire  [ADDR_W-1:0]   i_apb_paddr,
  input  wire  [2:0]          i_apb_pprot,
  input  wire  [STRB_W-1:0]   i_apb_pstrb,
  input  wire  [DATA_W-1:0]   i_apb_pwdata,
  input  wire                 i_apb_pwakeup,
  input  wire  [UREQ_W-1:0]   i_apb_pauser,
  input  wire  [UDAT_W-1:0]   i_apb_pwuser,
  output logic                o_apb_pready,
  output logic [DATA_W-1:0]   o_apb_prdata,
  output logic                o_apb_pslverr,
  output logic [UDAT_W-1:0]   o_apb_pruser,
  output logic [URSP_W-1:0]   o_apb_pbuser,
  output logic                o_req,
  output logic [REQ_W-1:0]    o_req_pld,
  output logic                o_wakeup,
  input  wire                 i_ack,
  input  wire  [RSP_W-1:0]    i_rsp_pld
);
  typedef enum logic [1:0] {ENUM_ST_IDLE = 2'd0, ENUM_ST_WAIT = 2'd1, ENUM_ST_CLOSE = 2'd2, ENUM_ST_RESP = 2'd3} st_type_def;
  st_type_def reg_fsm_hs_current_state;
  logic reg_req, reg_wakeup;
  logic [REQ_W-1:0] reg_req_pld;
  logic w_ack_s, w_setup, w_rsp_ev;

  m_vlsit_apbcdc_sync #(.W(1), .STAGES(STAGES)) u_sync_ack (
    .i_clk_dst(i_clk_mst), .i_rst_n_dst(i_rst_n_mst), .i_data(i_ack), .o_data(w_ack_s));

  assign w_setup = i_apb_psel & ~i_apb_penable;
  assign w_rsp_ev = (HS == 0) ? (w_ack_s == reg_req) : w_ack_s;

  always_ff @(posedge i_clk_mst, negedge i_rst_n_mst) begin : p_ff_mst
    if (!i_rst_n_mst) begin
      reg_fsm_hs_current_state <= ENUM_ST_IDLE;
      reg_req <= 1'b0; reg_wakeup <= 1'b0; reg_req_pld <= '0;
      o_apb_pready <= 1'b0; o_apb_prdata <= '0; o_apb_pslverr <= 1'b0; o_apb_pruser <= '0; o_apb_pbuser <= '0;
    end else begin
      reg_wakeup <= (APB5 != 0) & i_apb_pwakeup;
      case (reg_fsm_hs_current_state)
        ENUM_ST_IDLE: begin
          if (w_setup) begin
            reg_req_pld <= {(APB5 != 0) ? i_apb_pwuser : {UDAT_W{1'b0}}, (APB5 != 0) ? i_apb_pauser : {UREQ_W{1'b0}},
                            i_apb_pwdata, i_apb_pstrb, i_apb_pwrite, i_apb_pprot, i_apb_paddr};
            reg_req <= (HS == 0) ? ~reg_req : 1'b1;
            reg_fsm_hs_current_state <= ENUM_ST_WAIT;
          end
        end
        ENUM_ST_WAIT: begin
          if (w_rsp_ev) begin
            if (HS == 0) begin
              {o_apb_pbuser, o_apb_pruser, o_apb_pslverr, o_apb_prdata} <= i_rsp_pld;
              o_apb_pready <= 1'b1;
              reg_fsm_hs_current_state <= ENUM_ST_RESP;
            end else begin
              reg_req <= 1'b0;
              reg_fsm_hs_current_state <= ENUM_ST_CLOSE;
            end
          end
        end
        ENUM_ST_CLOSE: begin
          if (!w_ack_s) begin
            {o_apb_pbuser, o_apb_pruser, o_apb_pslverr, o_apb_prdata} <= i_rsp_pld;
            o_apb_pready <= 1'b1;
            reg_fsm_hs_current_state <= ENUM_ST_RESP;
          end
        end
        default: begin
          o_apb_pready <= 1'b0; o_apb_pslverr <= 1'b0;
          reg_fsm_hs_current_state <= ENUM_ST_IDLE;
        end
      endcase
    end
  end
  assign o_req = reg_req;
  assign o_req_pld = reg_req_pld;
  assign o_wakeup = reg_wakeup;
endmodule

module m_vlsit_apbcdc_slv #(
  parameter integer ADDR_W = 16,
  parameter integer DATA_W = 16,
  parameter integer APB5 = 0,
  parameter integer UREQ_W = 4,
  parameter integer UDAT_W = 4,
  parameter integer URSP_W = 4,
  parameter integer HS = 0,
  parameter integer STAGES = 2,
  localparam integer STRB_W = DATA_W / 8,
  localparam integer REQ_W = ADDR_W + 3 + 1 + STRB_W + DATA_W + UREQ_W + UDAT_W,
  localparam integer RSP_W = DATA_W + 1 + UDAT_W + URSP_W
) (
  input  wire                 i_clk_slv,
  input  wire                 i_rst_n_slv,
  output logic                o_apb_psel,
  output logic                o_apb_penable,
  output logic                o_apb_pwrite,
  output logic [ADDR_W-1:0]   o_apb_paddr,
  output logic [2:0]          o_apb_pprot,
  output logic [STRB_W-1:0]   o_apb_pstrb,
  output logic [DATA_W-1:0]   o_apb_pwdata,
  output logic                o_apb_pwakeup,
  output logic [UREQ_W-1:0]   o_apb_pauser,
  output logic [UDAT_W-1:0]   o_apb_pwuser,
  input  wire                 i_apb_pready,
  input  wire  [DATA_W-1:0]   i_apb_prdata,
  input  wire                 i_apb_pslverr,
  input  wire  [UDAT_W-1:0]   i_apb_pruser,
  input  wire  [URSP_W-1:0]   i_apb_pbuser,
  input  wire                 i_req,
  input  wire  [REQ_W-1:0]    i_req_pld,
  input  wire                 i_wakeup,
  output logic                o_ack,
  output logic [RSP_W-1:0]    o_rsp_pld
);
  typedef enum logic [1:0] {ENUM_ST_IDLE = 2'd0, ENUM_ST_SETUP = 2'd1, ENUM_ST_ACCESS = 2'd2, ENUM_ST_REQ0 = 2'd3} st_type_def;
  st_type_def reg_fsm_hs_current_state;
  logic reg_ack;
  logic [RSP_W-1:0] reg_rsp_pld;
  logic w_req_s, w_wk_s, w_ev;

  m_vlsit_apbcdc_sync #(.W(1), .STAGES(STAGES)) u_sync_req (
    .i_clk_dst(i_clk_slv), .i_rst_n_dst(i_rst_n_slv), .i_data(i_req), .o_data(w_req_s));
  m_vlsit_apbcdc_sync #(.W(1), .STAGES(STAGES)) u_sync_wk (
    .i_clk_dst(i_clk_slv), .i_rst_n_dst(i_rst_n_slv), .i_data(i_wakeup), .o_data(w_wk_s));

  assign w_ev = (HS == 0) ? (w_req_s != reg_ack) : w_req_s;

  always_ff @(posedge i_clk_slv, negedge i_rst_n_slv) begin : p_ff_slv
    if (!i_rst_n_slv) begin
      reg_fsm_hs_current_state <= ENUM_ST_IDLE;
      reg_ack <= 1'b0; reg_rsp_pld <= '0; o_apb_pwakeup <= 1'b0;
      o_apb_psel <= 1'b0; o_apb_penable <= 1'b0; o_apb_pwrite <= 1'b0; o_apb_paddr <= '0; o_apb_pprot <= '0;
      o_apb_pstrb <= '0; o_apb_pwdata <= '0; o_apb_pauser <= '0; o_apb_pwuser <= '0;
    end else begin
      o_apb_pwakeup <= (APB5 != 0) & (w_wk_s | w_ev | (reg_fsm_hs_current_state != ENUM_ST_IDLE));
      case (reg_fsm_hs_current_state)
        ENUM_ST_IDLE: begin
          if (w_ev) begin
            {o_apb_pwuser, o_apb_pauser, o_apb_pwdata, o_apb_pstrb, o_apb_pwrite, o_apb_pprot, o_apb_paddr} <= i_req_pld;
            o_apb_psel <= 1'b1; o_apb_penable <= 1'b0;
            reg_fsm_hs_current_state <= ENUM_ST_SETUP;
          end
        end
        ENUM_ST_SETUP: begin
          o_apb_penable <= 1'b1;
          reg_fsm_hs_current_state <= ENUM_ST_ACCESS;
        end
        ENUM_ST_ACCESS: begin
          if (i_apb_pready) begin
            reg_rsp_pld <= {i_apb_pbuser, i_apb_pruser, i_apb_pslverr, i_apb_prdata};
            o_apb_psel <= 1'b0; o_apb_penable <= 1'b0;
            if (HS == 0) begin
              reg_ack <= ~reg_ack;
              reg_fsm_hs_current_state <= ENUM_ST_IDLE;
            end else begin
              reg_ack <= 1'b1;
              reg_fsm_hs_current_state <= ENUM_ST_REQ0;
            end
          end
        end
        default: begin
          if (!w_req_s) begin
            reg_ack <= 1'b0;
            reg_fsm_hs_current_state <= ENUM_ST_IDLE;
          end
        end
      endcase
    end
  end
  assign o_ack = reg_ack;
  assign o_rsp_pld = reg_rsp_pld;
endmodule

module m_vlsit_apbcdc_top #(
  parameter integer ADDR_W = 16,
  parameter integer DATA_W = 16,
  parameter integer APB5 = 0,
  parameter integer UREQ_W = 4,
  parameter integer UDAT_W = 4,
  parameter integer URSP_W = 4,
  parameter integer HS = 0,
  parameter integer STAGES = 2,
  localparam integer STRB_W = DATA_W / 8
) (
  input  wire                 i_clk_mst,
  input  wire                 i_rst_n_mst,
  input  wire                 i_apb_psel,
  input  wire                 i_apb_penable,
  input  wire                 i_apb_pwrite,
  input  wire  [ADDR_W-1:0]   i_apb_paddr,
  input  wire  [2:0]          i_apb_pprot,
  input  wire  [STRB_W-1:0]   i_apb_pstrb,
  input  wire  [DATA_W-1:0]   i_apb_pwdata,
  input  wire                 i_apb_pwakeup,
  input  wire  [UREQ_W-1:0]   i_apb_pauser,
  input  wire  [UDAT_W-1:0]   i_apb_pwuser,
  output logic                o_apb_pready,
  output logic [DATA_W-1:0]   o_apb_prdata,
  output logic                o_apb_pslverr,
  output logic [UDAT_W-1:0]   o_apb_pruser,
  output logic [URSP_W-1:0]   o_apb_pbuser,
  input  wire                 i_clk_slv,
  input  wire                 i_rst_n_slv,
  output logic                o_apb_psel,
  output logic                o_apb_penable,
  output logic                o_apb_pwrite,
  output logic [ADDR_W-1:0]   o_apb_paddr,
  output logic [2:0]          o_apb_pprot,
  output logic [STRB_W-1:0]   o_apb_pstrb,
  output logic [DATA_W-1:0]   o_apb_pwdata,
  output logic                o_apb_pwakeup,
  output logic [UREQ_W-1:0]   o_apb_pauser,
  output logic [UDAT_W-1:0]   o_apb_pwuser,
  input  wire                 i_apb_pready,
  input  wire  [DATA_W-1:0]   i_apb_prdata,
  input  wire                 i_apb_pslverr,
  input  wire  [UDAT_W-1:0]   i_apb_pruser,
  input  wire  [URSP_W-1:0]   i_apb_pbuser
);
  localparam integer REQ_W = ADDR_W + 3 + 1 + STRB_W + DATA_W + UREQ_W + UDAT_W;
  localparam integer RSP_W = DATA_W + 1 + UDAT_W + URSP_W;
  logic w_req, w_ack, w_wakeup;
  logic [REQ_W-1:0] w_req_pld;
  logic [RSP_W-1:0] w_rsp_pld;

  m_vlsit_apbcdc_mst #(.ADDR_W(ADDR_W), .DATA_W(DATA_W), .APB5(APB5), .UREQ_W(UREQ_W), .UDAT_W(UDAT_W),
                       .URSP_W(URSP_W), .HS(HS), .STAGES(STAGES)) u_mst (.*,
    .o_req(w_req), .o_req_pld(w_req_pld), .o_wakeup(w_wakeup), .i_ack(w_ack), .i_rsp_pld(w_rsp_pld));
  m_vlsit_apbcdc_slv #(.ADDR_W(ADDR_W), .DATA_W(DATA_W), .APB5(APB5), .UREQ_W(UREQ_W), .UDAT_W(UDAT_W),
                       .URSP_W(URSP_W), .HS(HS), .STAGES(STAGES)) u_slv (.*,
    .i_req(w_req), .i_req_pld(w_req_pld), .i_wakeup(w_wakeup), .o_ack(w_ack), .o_rsp_pld(w_rsp_pld));
endmodule
