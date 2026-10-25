`timescale 1ns/1ps
// Prototype of the synchronous-clock FIFO of SyncFIFO_Design_Specification.md.
// It exists only to produce the waveforms of the specification and to measure latency and the minimum
// depth for gap-free streaming. It is not the delivered RTL (the RTL is generated later from the spec).
// Write and read clocks have different frequencies but are synchronous to each other.

module m_vlsit_sfifo_wr #(
  parameter logic [31:0] PARA_SFIFO_DEPTH = 8,
  parameter logic [31:0] PARA_SFIFO_DATA_W = 32,
  parameter logic [31:0] PARA_SFIFO_PTR_RETIME = 0,
  localparam logic [31:0] LPARA_ADDR_W = $clog2(PARA_SFIFO_DEPTH),
  localparam logic [31:0] LPARA_PTR_W = $clog2(2 * PARA_SFIFO_DEPTH),
  localparam logic [31:0] LPARA_OCC_W = $clog2(PARA_SFIFO_DEPTH + 1)
) (
  input  wire                          i_clk_wr,
  input  wire                          i_rst_n_wr,
  input  wire                          i_wr_en,
  input  wire  [PARA_SFIFO_DATA_W-1:0] i_wr_data,
  input  wire  [LPARA_OCC_W-1:0]       i_full_thr,
  output logic                         o_full,
  output logic                         o_full_thr,
  output logic                         o_overflow,
  input  wire                          i_rst_n_sw,
  output logic                         o_sw_rst_busy,
  output logic                         o_req_wr,
  input  wire                          i_ack_rd,
  input  wire  [LPARA_PTR_W-1:0]       i_rd_ptr,
  output logic [LPARA_PTR_W-1:0]       o_wr_ptr,
  output logic                         o_mem_wr_en,
  output logic [LPARA_ADDR_W-1:0]      o_mem_wr_addr,
  output logic [PARA_SFIFO_DATA_W-1:0] o_mem_wr_data
);
  typedef enum logic [2:0] {
    ENUM_ST_RUN = 3'b000, ENUM_ST_REQ = 3'b001, ENUM_ST_PTR = 3'b010,
    ENUM_ST_HOLD = 3'b011, ENUM_ST_REL = 3'b100
  } srst_state_type_def;

  srst_state_type_def reg_fsm_srst_current_state, w_fsm_srst_nxt_state;
  logic reg_sw_rst_busy, reg_req_wr, reg_overflow, reg_full, reg_full_thr;
  logic reg_ack_s;
  logic [LPARA_PTR_W-1:0] reg_wptr, w_wptr_nxt, reg_rptr_s, w_rptr_v;
  logic w_ack_v, w_wr_blk, w_wr_acc;
  logic [LPARA_PTR_W:0] w_occ_nxt;

  function automatic logic [LPARA_PTR_W:0] f_occ(input logic [LPARA_PTR_W-1:0] w, input logic [LPARA_PTR_W-1:0] r);
    logic [LPARA_PTR_W:0] ww, rr, mod;
    begin
      ww = {1'b0, w}; rr = {1'b0, r}; mod = 2 * PARA_SFIFO_DEPTH;
      f_occ = (ww >= rr) ? (ww - rr) : (ww + mod - rr);
    end
  endfunction

  function automatic logic [LPARA_PTR_W-1:0] f_inc(input logic [LPARA_PTR_W-1:0] p);
    f_inc = (p == (2 * PARA_SFIFO_DEPTH - 1)) ? '0 : p + 1'b1;
  endfunction

  function automatic logic [LPARA_ADDR_W-1:0] f_addr(input logic [LPARA_PTR_W-1:0] p);
    f_addr = (p >= PARA_SFIFO_DEPTH) ? LPARA_ADDR_W'(p - PARA_SFIFO_DEPTH) : LPARA_ADDR_W'(p);
  endfunction

  assign w_rptr_v = (PARA_SFIFO_PTR_RETIME != 0) ? reg_rptr_s : i_rd_ptr;
  assign w_ack_v  = (PARA_SFIFO_PTR_RETIME != 0) ? reg_ack_s : i_ack_rd;
  assign w_wr_blk = reg_sw_rst_busy | ~i_rst_n_sw;
  assign w_wr_acc = i_wr_en & ~w_wr_blk & ~reg_full;

  always_comb begin : p_com_wptr_nxt
    w_wptr_nxt = reg_wptr;
    if (reg_fsm_srst_current_state == ENUM_ST_PTR) w_wptr_nxt = '0;
    else if (w_wr_acc) w_wptr_nxt = f_inc(reg_wptr);
  end
  assign w_occ_nxt = f_occ(w_wptr_nxt, w_rptr_v);

  assign o_full     = w_wr_blk | reg_full;
  assign o_full_thr = w_wr_blk ? (i_full_thr == '0) : reg_full_thr;
  assign o_overflow = reg_overflow;
  assign o_sw_rst_busy = reg_sw_rst_busy;
  assign o_req_wr = reg_req_wr;
  assign o_wr_ptr = reg_wptr;
  assign o_mem_wr_en = w_wr_acc;
  assign o_mem_wr_addr = f_addr(reg_wptr);
  assign o_mem_wr_data = i_wr_data;

  always_comb begin : p_com_fsm
    w_fsm_srst_nxt_state = reg_fsm_srst_current_state;
    case (reg_fsm_srst_current_state)
      ENUM_ST_RUN:  if (!i_rst_n_sw) w_fsm_srst_nxt_state = ENUM_ST_REQ;
      ENUM_ST_REQ:  if (w_ack_v) w_fsm_srst_nxt_state = ENUM_ST_PTR;
      ENUM_ST_PTR:  w_fsm_srst_nxt_state = ENUM_ST_HOLD;
      ENUM_ST_HOLD: if (i_rst_n_sw) w_fsm_srst_nxt_state = ENUM_ST_REL;
      ENUM_ST_REL:  if (!w_ack_v && (w_rptr_v == '0)) w_fsm_srst_nxt_state = ENUM_ST_RUN;
      default:      w_fsm_srst_nxt_state = ENUM_ST_RUN;
    endcase
  end

  always_ff @(posedge i_clk_wr, negedge i_rst_n_wr) begin : p_ff_wr
    if (!i_rst_n_wr) begin
      reg_wptr <= '0; reg_full <= 1'b0; reg_full_thr <= 1'b0; reg_overflow <= 1'b0;
      reg_fsm_srst_current_state <= ENUM_ST_RUN; reg_sw_rst_busy <= 1'b0; reg_req_wr <= 1'b0;
      reg_rptr_s <= '0; reg_ack_s <= 1'b0;
    end else begin
      reg_wptr <= w_wptr_nxt;
      reg_full <= (w_occ_nxt >= PARA_SFIFO_DEPTH);
      reg_full_thr <= (w_occ_nxt >= {1'b0, i_full_thr});
      reg_overflow <= i_wr_en & ~w_wr_blk & reg_full;
      reg_fsm_srst_current_state <= w_fsm_srst_nxt_state;
      reg_sw_rst_busy <= (w_fsm_srst_nxt_state != ENUM_ST_RUN);
      reg_req_wr <= (w_fsm_srst_nxt_state == ENUM_ST_REQ) | (w_fsm_srst_nxt_state == ENUM_ST_PTR) |
                    (w_fsm_srst_nxt_state == ENUM_ST_HOLD);
      reg_rptr_s <= i_rd_ptr;
      reg_ack_s <= i_ack_rd;
    end
  end
endmodule

module m_vlsit_sfifo_rd #(
  parameter logic [31:0] PARA_SFIFO_DEPTH = 8,
  parameter logic [31:0] PARA_SFIFO_DATA_W = 32,
  parameter logic [31:0] PARA_SFIFO_PTR_RETIME = 0,
  localparam logic [31:0] LPARA_ADDR_W = $clog2(PARA_SFIFO_DEPTH),
  localparam logic [31:0] LPARA_PTR_W = $clog2(2 * PARA_SFIFO_DEPTH),
  localparam logic [31:0] LPARA_OCC_W = $clog2(PARA_SFIFO_DEPTH + 1)
) (
  input  wire                          i_clk_rd,
  input  wire                          i_rst_n_rd,
  input  wire                          i_rd_en,
  input  wire  [LPARA_OCC_W-1:0]       i_empty_thr,
  output logic [PARA_SFIFO_DATA_W-1:0] o_rd_data,
  output logic                         o_empty,
  output logic                         o_empty_thr,
  output logic                         o_underflow,
  input  wire                          i_req_wr,
  output logic                         o_ack_rd,
  input  wire  [LPARA_PTR_W-1:0]       i_wr_ptr,
  output logic [LPARA_PTR_W-1:0]       o_rd_ptr,
  output logic [LPARA_ADDR_W-1:0]      o_mem_rd_addr,
  input  wire  [PARA_SFIFO_DATA_W-1:0] i_mem_rd_data
);
  typedef enum logic [1:0] {ENUM_ST_RUN = 2'b00, ENUM_ST_RST = 2'b01, ENUM_ST_ACK = 2'b10} srst_state_type_def;

  srst_state_type_def reg_fsm_srst_current_state, w_fsm_srst_nxt_state;
  logic reg_ack_rd, reg_underflow, reg_empty, reg_empty_thr, reg_req_s;
  logic [LPARA_PTR_W-1:0] reg_rptr, w_rptr_nxt, reg_wptr_s, w_wptr_v;
  logic w_req_v, w_rd_blk, w_rd_acc;
  logic [LPARA_PTR_W:0] w_occ_nxt;

  function automatic logic [LPARA_PTR_W:0] f_occ(input logic [LPARA_PTR_W-1:0] w, input logic [LPARA_PTR_W-1:0] r);
    logic [LPARA_PTR_W:0] ww, rr, mod;
    begin
      ww = {1'b0, w}; rr = {1'b0, r}; mod = 2 * PARA_SFIFO_DEPTH;
      f_occ = (ww >= rr) ? (ww - rr) : (ww + mod - rr);
    end
  endfunction

  function automatic logic [LPARA_PTR_W-1:0] f_inc(input logic [LPARA_PTR_W-1:0] p);
    f_inc = (p == (2 * PARA_SFIFO_DEPTH - 1)) ? '0 : p + 1'b1;
  endfunction

  function automatic logic [LPARA_ADDR_W-1:0] f_addr(input logic [LPARA_PTR_W-1:0] p);
    f_addr = (p >= PARA_SFIFO_DEPTH) ? LPARA_ADDR_W'(p - PARA_SFIFO_DEPTH) : LPARA_ADDR_W'(p);
  endfunction

  assign w_wptr_v = (PARA_SFIFO_PTR_RETIME != 0) ? reg_wptr_s : i_wr_ptr;
  assign w_req_v  = (PARA_SFIFO_PTR_RETIME != 0) ? reg_req_s : i_req_wr;
  assign w_rd_blk = w_req_v | (reg_fsm_srst_current_state != ENUM_ST_RUN);
  assign w_rd_acc = i_rd_en & ~w_rd_blk & ~reg_empty;

  always_comb begin : p_com_rptr_nxt
    w_rptr_nxt = reg_rptr;
    if (reg_fsm_srst_current_state == ENUM_ST_RST) w_rptr_nxt = '0;
    else if (w_rd_acc) w_rptr_nxt = f_inc(reg_rptr);
  end
  assign w_occ_nxt = f_occ(w_wptr_v, w_rptr_nxt);

  assign o_empty     = w_rd_blk | reg_empty;
  assign o_empty_thr = w_rd_blk ? 1'b1 : reg_empty_thr;
  assign o_underflow = reg_underflow;
  assign o_ack_rd = reg_ack_rd;
  assign o_rd_ptr = reg_rptr;
  assign o_mem_rd_addr = f_addr(w_rptr_nxt);
  assign o_rd_data = i_mem_rd_data;

  always_comb begin : p_com_fsm
    w_fsm_srst_nxt_state = reg_fsm_srst_current_state;
    case (reg_fsm_srst_current_state)
      ENUM_ST_RUN: if (w_req_v) w_fsm_srst_nxt_state = ENUM_ST_RST;
      ENUM_ST_RST: w_fsm_srst_nxt_state = ENUM_ST_ACK;
      ENUM_ST_ACK: if (!w_req_v && (w_wptr_v == '0)) w_fsm_srst_nxt_state = ENUM_ST_RUN;
      default:     w_fsm_srst_nxt_state = ENUM_ST_RUN;
    endcase
  end

  always_ff @(posedge i_clk_rd, negedge i_rst_n_rd) begin : p_ff_rd
    if (!i_rst_n_rd) begin
      reg_rptr <= '0; reg_empty <= 1'b1; reg_empty_thr <= 1'b1; reg_underflow <= 1'b0;
      reg_fsm_srst_current_state <= ENUM_ST_RUN; reg_ack_rd <= 1'b0;
      reg_wptr_s <= '0; reg_req_s <= 1'b0;
    end else begin
      reg_rptr <= w_rptr_nxt;
      reg_empty <= (w_occ_nxt == '0);
      reg_empty_thr <= (w_occ_nxt <= {1'b0, i_empty_thr});
      reg_underflow <= i_rd_en & ~w_rd_blk & reg_empty;
      reg_fsm_srst_current_state <= w_fsm_srst_nxt_state;
      reg_ack_rd <= (w_fsm_srst_nxt_state == ENUM_ST_ACK);
      reg_wptr_s <= i_wr_ptr;
      reg_req_s <= i_req_wr;
    end
  end
endmodule

module m_vlsit_sfifo_mem #(
  parameter logic [31:0] PARA_SFIFO_DEPTH = 8,
  parameter logic [31:0] PARA_SFIFO_DATA_W = 32,
  localparam logic [31:0] LPARA_ADDR_W = $clog2(PARA_SFIFO_DEPTH)
) (
  input  wire                          i_clk_wr,
  input  wire                          i_wr_en,
  input  wire  [LPARA_ADDR_W-1:0]      i_wr_addr,
  input  wire  [PARA_SFIFO_DATA_W-1:0] i_wr_data,
  input  wire                          i_clk_rd,
  input  wire  [LPARA_ADDR_W-1:0]      i_rd_addr,
  output logic [PARA_SFIFO_DATA_W-1:0] o_rd_data
);
  logic [PARA_SFIFO_DATA_W-1:0] reg_mem [0:PARA_SFIFO_DEPTH-1];
  logic [PARA_SFIFO_DATA_W-1:0] reg_rd_data;
  always_ff @(posedge i_clk_wr) begin : p_ff_wr_port
    if (i_wr_en) reg_mem[i_wr_addr] <= i_wr_data;
  end
  always_ff @(posedge i_clk_rd) begin : p_ff_rd_port
    reg_rd_data <= reg_mem[i_rd_addr];
  end
  assign o_rd_data = reg_rd_data;
endmodule

module m_vlsit_sfifo_top #(
  parameter logic [31:0] PARA_SFIFO_DEPTH = 8,
  parameter logic [31:0] PARA_SFIFO_DATA_W = 32,
  parameter logic [31:0] PARA_SFIFO_PTR_RETIME = 0,
  localparam logic [31:0] LPARA_ADDR_W = $clog2(PARA_SFIFO_DEPTH),
  localparam logic [31:0] LPARA_PTR_W = $clog2(2 * PARA_SFIFO_DEPTH),
  localparam logic [31:0] LPARA_OCC_W = $clog2(PARA_SFIFO_DEPTH + 1)
) (
  input  wire                          i_clk_wr,
  input  wire                          i_rst_n_wr,
  input  wire                          i_wr_en,
  input  wire  [PARA_SFIFO_DATA_W-1:0] i_wr_data,
  input  wire  [LPARA_OCC_W-1:0]       i_full_thr,
  input  wire                          i_rst_n_sw,
  output logic                         o_sw_rst_busy,
  output logic                         o_full,
  output logic                         o_full_thr,
  output logic                         o_overflow,
  input  wire                          i_clk_rd,
  input  wire                          i_rst_n_rd,
  input  wire                          i_rd_en,
  input  wire  [LPARA_OCC_W-1:0]       i_empty_thr,
  output logic [PARA_SFIFO_DATA_W-1:0] o_rd_data,
  output logic                         o_empty,
  output logic                         o_empty_thr,
  output logic                         o_underflow
);
  logic w_req_wr, w_ack_rd, w_mem_wr_en;
  logic [LPARA_PTR_W-1:0] w_wr_ptr, w_rd_ptr;
  logic [LPARA_ADDR_W-1:0] w_mem_wr_addr, w_mem_rd_addr;
  logic [PARA_SFIFO_DATA_W-1:0] w_mem_wr_data, w_mem_rd_data;

  m_vlsit_sfifo_wr #(.PARA_SFIFO_DEPTH(PARA_SFIFO_DEPTH), .PARA_SFIFO_DATA_W(PARA_SFIFO_DATA_W),
                     .PARA_SFIFO_PTR_RETIME(PARA_SFIFO_PTR_RETIME)) u_wr (
    .i_clk_wr(i_clk_wr), .i_rst_n_wr(i_rst_n_wr), .i_wr_en(i_wr_en), .i_wr_data(i_wr_data),
    .i_full_thr(i_full_thr), .o_full(o_full), .o_full_thr(o_full_thr), .o_overflow(o_overflow),
    .i_rst_n_sw(i_rst_n_sw), .o_sw_rst_busy(o_sw_rst_busy), .o_req_wr(w_req_wr), .i_ack_rd(w_ack_rd),
    .i_rd_ptr(w_rd_ptr), .o_wr_ptr(w_wr_ptr), .o_mem_wr_en(w_mem_wr_en), .o_mem_wr_addr(w_mem_wr_addr),
    .o_mem_wr_data(w_mem_wr_data));

  m_vlsit_sfifo_rd #(.PARA_SFIFO_DEPTH(PARA_SFIFO_DEPTH), .PARA_SFIFO_DATA_W(PARA_SFIFO_DATA_W),
                     .PARA_SFIFO_PTR_RETIME(PARA_SFIFO_PTR_RETIME)) u_rd (
    .i_clk_rd(i_clk_rd), .i_rst_n_rd(i_rst_n_rd), .i_rd_en(i_rd_en), .i_empty_thr(i_empty_thr),
    .o_rd_data(o_rd_data), .o_empty(o_empty), .o_empty_thr(o_empty_thr), .o_underflow(o_underflow),
    .i_req_wr(w_req_wr), .o_ack_rd(w_ack_rd), .i_wr_ptr(w_wr_ptr), .o_rd_ptr(w_rd_ptr),
    .o_mem_rd_addr(w_mem_rd_addr), .i_mem_rd_data(w_mem_rd_data));

  m_vlsit_sfifo_mem #(.PARA_SFIFO_DEPTH(PARA_SFIFO_DEPTH), .PARA_SFIFO_DATA_W(PARA_SFIFO_DATA_W)) u_mem (
    .i_clk_wr(i_clk_wr), .i_wr_en(w_mem_wr_en), .i_wr_addr(w_mem_wr_addr), .i_wr_data(w_mem_wr_data),
    .i_clk_rd(i_clk_rd), .i_rd_addr(w_mem_rd_addr), .o_rd_data(w_mem_rd_data));
endmodule
