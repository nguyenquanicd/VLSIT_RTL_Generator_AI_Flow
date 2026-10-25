/*
 * Project      : VLSIT Common RTL library
 * Author       : Nguyen Quan and Claude Sonnet 5.5 (user)
 * AI Flow      : VLSIT RTL Generator AI Automation Flow
 * AI Flow Page : https://github.com/nguyenquanicd/VLSIT_RTL_Generator_AI_Model
 * Date         : 2026-10-24
 * Description  : Read side of the synchronous-clock FIFO (read clock domain). It holds the read
 *                pointer (modulo 2 x DEPTH), the registered empty and empty-threshold flags
 *                computed from the next pointers, the underflow pulse, the memory read address
 *                (address of the next read pointer, show-ahead) and the read software reset FSM
 *                (RUN, RST, ACK) with its acknowledge flop. The write pointer and the request of
 *                the write clock domain are timed paths of related clocks: they enter the logic
 *                directly (PARA_SFIFO_PTR_RETIME = 0) or through one retiming flop
 *                (PARA_SFIFO_PTR_RETIME = 1). There is no synchronizer. When the request is seen,
 *                reads are blocked and o_empty is 1; the FSM resets the read pointer first and then
 *                raises the acknowledge. The read side is released first, when the request is 0 and
 *                the visible write pointer is 0.
 */
`timescale 1ns/1ps

module m_vlsit_sfifo_rd #(
  // Parameter Description: number of entries of the FIFO. Sets the address and pointer widths.
  // Parameter values: any integer of 2 or more; default is 8.
  // Parameter unit: count
  parameter logic [31:0] PARA_SFIFO_DEPTH = 8,
  // Parameter Description: data width of one entry.
  // Parameter values: 1 or more; default is 32.
  // Parameter unit: bit
  parameter logic [31:0] PARA_SFIFO_DATA_W = 32,
  // Parameter Description: pointer path from the write domain: 0 = direct, 1 = one retiming flop.
  // Parameter values: 0 or 1; default is 0.
  // Parameter unit: none
  parameter logic [31:0] PARA_SFIFO_PTR_RETIME = 0,
  localparam logic [31:0] LPARA_ADDR_W = $clog2(PARA_SFIFO_DEPTH),
  localparam logic [31:0] LPARA_PTR_W = $clog2(2 * PARA_SFIFO_DEPTH),
  localparam logic [31:0] LPARA_OCC_W = $clog2(PARA_SFIFO_DEPTH + 1),
  localparam logic [31:0] LPARA_PTR_MOD = 2 * PARA_SFIFO_DEPTH,
  localparam logic [31:0] LPARA_ARITH_W = 32
) (
  // Read clock and reset
  input  wire                          i_clk_rd,
  input  wire                          i_rst_n_rd,

  // Read interface
  input  wire                          i_rd_en,
  input  wire  [LPARA_OCC_W-1:0]       i_empty_thr,
  output logic [PARA_SFIFO_DATA_W-1:0] o_rd_data,
  output logic                         o_empty,
  output logic                         o_empty_thr,
  output logic                         o_underflow,

  // Software reset handshake with the write side
  input  wire                          i_req_wr,
  output logic                         o_ack_rd,

  // Pointer crossing
  input  wire  [LPARA_PTR_W-1:0]       i_wr_ptr,
  output logic [LPARA_PTR_W-1:0]       o_rd_ptr,

  // Memory read port
  output logic [LPARA_ADDR_W-1:0]      o_mem_rd_addr,
  input  wire  [PARA_SFIFO_DATA_W-1:0] i_mem_rd_data
);

  // FSM states of the read software reset: RUN is normal operation, RST resets the read pointer
  // (one cycle), ACK holds the acknowledge until the release condition holds. Encoding 3 is
  // unused and recovers to ENUM_ST_RUN.
  typedef enum logic [1:0] {
    ENUM_ST_RUN = 2'b00,
    ENUM_ST_RST = 2'b01,
    ENUM_ST_ACK = 2'b10
  } srst_state_type_def;

  // Internal signal declarations
  srst_state_type_def reg_fsm_srst_current_state;
  srst_state_type_def w_fsm_srst_nxt_state;

  logic reg_ack_rd;
  logic reg_underflow;
  logic reg_empty;
  logic reg_empty_thr;
  logic reg_req_s;

  logic [LPARA_PTR_W-1:0] reg_rptr;
  logic [LPARA_PTR_W-1:0] w_rptr_nxt;
  logic [LPARA_PTR_W-1:0] reg_wptr_s;
  logic [LPARA_PTR_W-1:0] w_wptr_v;

  // Pointer arithmetic is done in LPARA_ARITH_W bits (zero-extended pointers):
  // any depth works.
  logic [LPARA_ARITH_W-1:0] w_rptr_ext;
  logic [LPARA_ARITH_W-1:0] w_rptr_nxt_ext;
  logic [LPARA_ARITH_W-1:0] w_wptr_ext;
  logic [LPARA_ARITH_W-1:0] w_occ_nxt;
  logic [LPARA_ARITH_W-1:0] w_empty_thr_ext;
  logic [LPARA_ARITH_W-1:0] w_addr_ext;

  logic w_req_v;
  logic w_rd_blk;
  logic w_rd_acc;

  // Pointer and request as seen by the read domain: the direct signal of the write domain
  // (timed path of related clocks) or its copy in one retiming flop.
  assign w_wptr_v = (PARA_SFIFO_PTR_RETIME != '0) ? reg_wptr_s : i_wr_ptr;
  assign w_req_v  = (PARA_SFIFO_PTR_RETIME != '0) ? reg_req_s : i_req_wr;

  // Read block: reads are blocked while the visible request is 1 and while the read FSM is not
  // in RUN (zero latency from these two conditions).
  assign w_rd_blk = w_req_v | (reg_fsm_srst_current_state != ENUM_ST_RUN);

  // A read is accepted when it is requested, reads are not blocked, and the empty flop is 0.
  assign w_rd_acc = i_rd_en & ~w_rd_blk & ~reg_empty;

  // Zero-extended copies of the pointers and of the static threshold.
  assign w_rptr_ext      = {{(LPARA_ARITH_W - LPARA_PTR_W){1'b0}}, reg_rptr};
  assign w_rptr_nxt_ext  = {{(LPARA_ARITH_W - LPARA_PTR_W){1'b0}}, w_rptr_nxt};
  assign w_wptr_ext      = {{(LPARA_ARITH_W - LPARA_PTR_W){1'b0}}, w_wptr_v};
  assign w_empty_thr_ext = {{(LPARA_ARITH_W - LPARA_OCC_W){1'b0}}, i_empty_thr};

  // Next read pointer: reset to 0 in state RST, incremented modulo 2 x DEPTH by an accepted read.
  always_comb begin : p_com_rptr_nxt
    w_rptr_nxt = reg_rptr;
    casez ({(reg_fsm_srst_current_state == ENUM_ST_RST), (w_rptr_ext == (LPARA_PTR_MOD - 1'b1)), w_rd_acc})
      3'b1??:  w_rptr_nxt = '0;
      3'b011:  w_rptr_nxt = '0;
      3'b001:  w_rptr_nxt = reg_rptr + 1'b1;
      default: w_rptr_nxt = reg_rptr;
    endcase
  end

  // Occupancy after this edge, seen from the read domain: visible write pointer minus the next
  // read pointer, modulo 2 x DEPTH. The visible write pointer may lag, so the value never
  // overestimates the real occupancy.
  always_comb begin : p_com_occ_nxt
    w_occ_nxt = w_wptr_ext - w_rptr_nxt_ext;
    if (w_wptr_ext < w_rptr_nxt_ext)
      w_occ_nxt = w_wptr_ext + LPARA_PTR_MOD - w_rptr_nxt_ext;
  end

  // Empty flop, empty-threshold flop, underflow pulse and retiming flops. The empty flags are
  // asynchronously reset to 1, the others to 0. The flags are loaded from the next pointers
  // (look-ahead), at the same edge as the memory output register.
  always_ff @(posedge i_clk_rd, negedge i_rst_n_rd) begin : p_ff_flags
    if (!i_rst_n_rd) begin
      reg_empty     <= 1'b1;
      reg_empty_thr <= 1'b1;
      reg_underflow <= 1'b0;
      reg_wptr_s    <= '0;
      reg_req_s     <= 1'b0;
    end else begin
      reg_empty     <= (w_occ_nxt == '0);
      reg_empty_thr <= (w_empty_thr_ext >= w_occ_nxt);
      // A read that is blocked by the software reset is not an error and raises no pulse.
      reg_underflow <= i_rd_en & ~w_rd_blk & reg_empty;
      reg_wptr_s    <= i_wr_ptr;
      reg_req_s     <= i_req_wr;
    end
  end

  // Read pointer: control state, asynchronously reset to 0.
  always_ff @(posedge i_clk_rd, negedge i_rst_n_rd) begin : p_ff_rptr
    if (!i_rst_n_rd)
      reg_rptr <= '0;
    else
      reg_rptr <= w_rptr_nxt;
  end

  // Next state of the read reset FSM. RUN goes to RST when the visible request is 1. RST lasts
  // one cycle. ACK returns to RUN when the request is 0 and the visible write pointer is 0
  // (flush check): the read side is released before the write side.
  always_comb begin : p_com_fsm_srst_nxt
    w_fsm_srst_nxt_state = reg_fsm_srst_current_state;
    case (reg_fsm_srst_current_state)
      ENUM_ST_RUN: begin
        if (w_req_v)
          w_fsm_srst_nxt_state = ENUM_ST_RST;
      end
      ENUM_ST_RST: w_fsm_srst_nxt_state = ENUM_ST_ACK;
      ENUM_ST_ACK: begin
        if (!w_req_v && (w_wptr_v == '0))
          w_fsm_srst_nxt_state = ENUM_ST_RUN;
      end
      default: w_fsm_srst_nxt_state = ENUM_ST_RUN;
    endcase
  end

  // Current state of the read reset FSM: control state, asynchronously reset to RUN (R-036: this
  // block holds the current state only).
  always_ff @(posedge i_clk_rd, negedge i_rst_n_rd) begin : p_ff_fsm_srst
    if (!i_rst_n_rd)
      reg_fsm_srst_current_state <= ENUM_ST_RUN;
    else
      reg_fsm_srst_current_state <= w_fsm_srst_nxt_state;
  end

  // Acknowledge flop of the read reset handshake: control state, asynchronously reset. The
  // acknowledge is 1 from the edge that leaves RST (the read pointer is reset at that same edge)
  // until the edge that leaves ACK.
  always_ff @(posedge i_clk_rd, negedge i_rst_n_rd) begin : p_ff_ack_rd
    if (!i_rst_n_rd)
      reg_ack_rd <= 1'b0;
    else
      reg_ack_rd <= (w_fsm_srst_nxt_state == ENUM_ST_ACK);
  end

  // Memory read address: the next read pointer modulo DEPTH, so that after an accepted read the
  // storage output register already shows the next word (show-ahead). The storage is read in
  // every cycle.
  always_comb begin : p_com_rd_addr
    w_addr_ext = w_rptr_nxt_ext;
    if (w_rptr_nxt_ext >= PARA_SFIFO_DEPTH)
      w_addr_ext = w_rptr_nxt_ext - PARA_SFIFO_DEPTH;
  end

  // Output mapping. o_empty and o_empty_thr are a flop output combined with the block term by one
  // gate; while blocked both are 1 (an empty FIFO has occupancy 0).
  assign o_empty       = w_rd_blk | reg_empty;
  assign o_empty_thr   = w_rd_blk | reg_empty_thr;
  assign o_underflow   = reg_underflow;
  assign o_ack_rd      = reg_ack_rd;
  assign o_rd_ptr      = reg_rptr;
  assign o_mem_rd_addr = w_addr_ext[LPARA_ADDR_W-1:0];
  assign o_rd_data     = i_mem_rd_data;

endmodule
