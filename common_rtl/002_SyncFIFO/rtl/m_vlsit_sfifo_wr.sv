/*
 * Project      : VLSIT Common RTL library
 * Author       : Nguyen Quan and Claude Sonnet 5.5 (user)
 * AI Flow      : VLSIT RTL Generator AI Automation Flow
 * AI Flow Page : https://github.com/nguyenquanicd/VLSIT_RTL_Generator_AI_Model
 * Date         : 2026-10-24
 * Description  : Write side of the synchronous-clock FIFO (write clock domain). It holds the write
 *                pointer (modulo 2 x DEPTH), the registered full and full-threshold flags computed
 *                from the next pointers, the overflow pulse, the memory write port outputs and the
 *                write software reset FSM (RUN, REQ, PTR, HOLD, REL) with its request and busy
 *                flops. The read pointer and the acknowledge of the read clock domain are timed
 *                paths of related clocks: they enter the logic directly (PARA_SFIFO_PTR_RETIME = 0)
 *                or through one retiming flop (PARA_SFIFO_PTR_RETIME = 1). There is no
 *                synchronizer.
 *                i_rst_n_sw = 0 blocks writes at once (no flop in that path).
 */
`timescale 1ns/1ps

module m_vlsit_sfifo_wr #(
  // Parameter Description: number of entries of the FIFO. Sets the address and pointer widths.
  // Parameter values: any integer of 2 or more; default is 8.
  // Parameter unit: count
  parameter logic [31:0] PARA_SFIFO_DEPTH = 8,
  // Parameter Description: data width of one entry.
  // Parameter values: 1 or more; default is 32.
  // Parameter unit: bit
  parameter logic [31:0] PARA_SFIFO_DATA_W = 32,
  // Parameter Description: pointer path from the read domain: 0 = direct, 1 = one retiming flop.
  // Parameter values: 0 or 1; default is 0.
  // Parameter unit: none
  parameter logic [31:0] PARA_SFIFO_PTR_RETIME = 0,
  localparam logic [31:0] LPARA_ADDR_W = $clog2(PARA_SFIFO_DEPTH),
  localparam logic [31:0] LPARA_PTR_W = $clog2(2 * PARA_SFIFO_DEPTH),
  localparam logic [31:0] LPARA_OCC_W = $clog2(PARA_SFIFO_DEPTH + 1),
  localparam logic [31:0] LPARA_PTR_MOD = 2 * PARA_SFIFO_DEPTH,
  localparam logic [31:0] LPARA_ARITH_W = 32
) (
  // Write clock and reset
  input  wire                          i_clk_wr,
  input  wire                          i_rst_n_wr,

  // Write interface
  input  wire                          i_wr_en,
  input  wire  [PARA_SFIFO_DATA_W-1:0] i_wr_data,
  input  wire  [LPARA_OCC_W-1:0]       i_full_thr,
  output logic                         o_full,
  output logic                         o_full_thr,
  output logic                         o_overflow,

  // Software reset and handshake with the read side
  input  wire                          i_rst_n_sw,
  output logic                         o_sw_rst_busy,
  output logic                         o_req_wr,
  input  wire                          i_ack_rd,

  // Pointer crossing
  input  wire  [LPARA_PTR_W-1:0]       i_rd_ptr,
  output logic [LPARA_PTR_W-1:0]       o_wr_ptr,

  // Memory write port
  output logic                         o_mem_wr_en,
  output logic [LPARA_ADDR_W-1:0]      o_mem_wr_addr,
  output logic [PARA_SFIFO_DATA_W-1:0] o_mem_wr_data
);

  // FSM states of the write software reset: RUN is normal operation, REQ raises the request and
  // waits for the acknowledge, PTR resets the write pointer, HOLD waits until i_rst_n_sw is 1
  // again, REL drops the request and waits for the flush check. Encodings 5 to 7 are unused and
  // recover to ENUM_ST_RUN.
  typedef enum logic [2:0] {
    ENUM_ST_RUN  = 3'b000,
    ENUM_ST_REQ  = 3'b001,
    ENUM_ST_PTR  = 3'b010,
    ENUM_ST_HOLD = 3'b011,
    ENUM_ST_REL  = 3'b100
  } srst_state_type_def;

  // Internal signal declarations
  srst_state_type_def reg_fsm_srst_current_state;
  srst_state_type_def w_fsm_srst_nxt_state;

  logic reg_sw_rst_busy;
  logic reg_req_wr;
  logic reg_overflow;
  logic reg_full;
  logic reg_full_thr;
  logic reg_ack_s;

  logic [LPARA_PTR_W-1:0] reg_wptr;
  logic [LPARA_PTR_W-1:0] w_wptr_nxt;
  logic [LPARA_PTR_W-1:0] reg_rptr_s;
  logic [LPARA_PTR_W-1:0] w_rptr_v;

  // Pointer arithmetic is done in LPARA_ARITH_W bits (zero-extended pointers):
  // any depth works.
  logic [LPARA_ARITH_W-1:0] w_wptr_ext;
  logic [LPARA_ARITH_W-1:0] w_wptr_nxt_ext;
  logic [LPARA_ARITH_W-1:0] w_rptr_ext;
  logic [LPARA_ARITH_W-1:0] w_occ_nxt;
  logic [LPARA_ARITH_W-1:0] w_full_thr_ext;
  logic [LPARA_ARITH_W-1:0] w_addr_ext;

  logic w_ack_v;
  logic w_wr_blk;
  logic w_wr_acc;

  // Pointer and acknowledge as seen by the write domain: the direct signal of the read domain
  // (timed path of related clocks) or its copy in one retiming flop.
  assign w_rptr_v = (PARA_SFIFO_PTR_RETIME != '0) ? reg_rptr_s : i_rd_ptr;
  assign w_ack_v  = (PARA_SFIFO_PTR_RETIME != '0) ? reg_ack_s : i_ack_rd;

  // Write block: writes are blocked while the write FSM is not in RUN, which is the busy flop,
  // and in every cycle in which i_rst_n_sw is 0 (zero latency, no flop on this path).
  assign w_wr_blk = reg_sw_rst_busy | ~i_rst_n_sw;

  // A write is accepted when it is requested, writes are not blocked, and the full flop is 0.
  assign w_wr_acc = i_wr_en & ~w_wr_blk & ~reg_full;

  // Zero-extended copies of the pointers and of the static threshold.
  assign w_wptr_ext     = {{(LPARA_ARITH_W - LPARA_PTR_W){1'b0}}, reg_wptr};
  assign w_wptr_nxt_ext = {{(LPARA_ARITH_W - LPARA_PTR_W){1'b0}}, w_wptr_nxt};
  assign w_rptr_ext     = {{(LPARA_ARITH_W - LPARA_PTR_W){1'b0}}, w_rptr_v};
  assign w_full_thr_ext = {{(LPARA_ARITH_W - LPARA_OCC_W){1'b0}}, i_full_thr};

  // Next write pointer: reset to 0 in state PTR, incremented modulo 2 x DEPTH by an accepted write.
  always_comb begin : p_com_wptr_nxt
    w_wptr_nxt = reg_wptr;
    casez ({(reg_fsm_srst_current_state == ENUM_ST_PTR), (w_wptr_ext == (LPARA_PTR_MOD - 1'b1)), w_wr_acc})
      3'b1??:  w_wptr_nxt = '0;
      3'b011:  w_wptr_nxt = '0;
      3'b001:  w_wptr_nxt = reg_wptr + 1'b1;
      default: w_wptr_nxt = reg_wptr;
    endcase
  end

  // Occupancy after this edge, seen from the write domain: next write pointer minus the visible
  // read pointer, modulo 2 x DEPTH. The visible read pointer may lag, so the value never
  // underestimates the real occupancy.
  always_comb begin : p_com_occ_nxt
    w_occ_nxt = w_wptr_nxt_ext - w_rptr_ext;
    if (w_wptr_nxt_ext < w_rptr_ext)
      w_occ_nxt = w_wptr_nxt_ext + LPARA_PTR_MOD - w_rptr_ext;
  end

  // Full flop, full-threshold flop, overflow pulse and retiming flops. Asynchronously reset to 0.
  // The flags are loaded from the next pointers (look-ahead), so they are exact at the own edge.
  always_ff @(posedge i_clk_wr, negedge i_rst_n_wr) begin : p_ff_flags
    if (!i_rst_n_wr) begin
      reg_full     <= 1'b0;
      reg_full_thr <= 1'b0;
      reg_overflow <= 1'b0;
      reg_rptr_s   <= '0;
      reg_ack_s    <= 1'b0;
    end else begin
      reg_full     <= (w_occ_nxt >= PARA_SFIFO_DEPTH);
      reg_full_thr <= (w_occ_nxt >= w_full_thr_ext);
      // A write that is blocked by the software reset is not an error and raises no pulse.
      reg_overflow <= i_wr_en & ~w_wr_blk & reg_full;
      reg_rptr_s   <= i_rd_ptr;
      reg_ack_s    <= i_ack_rd;
    end
  end

  // Write pointer: control state, asynchronously reset to 0.
  always_ff @(posedge i_clk_wr, negedge i_rst_n_wr) begin : p_ff_wptr
    if (!i_rst_n_wr)
      reg_wptr <= '0;
    else
      reg_wptr <= w_wptr_nxt;
  end

  // Next state of the write reset FSM. RUN takes the request when i_rst_n_sw is 0. REQ waits for
  // the acknowledge. PTR lasts one cycle. HOLD waits for i_rst_n_sw = 1. REL waits until the
  // acknowledge is 0 and the visible read pointer is 0 (flush check), then RUN.
  always_comb begin : p_com_fsm_srst_nxt
    w_fsm_srst_nxt_state = reg_fsm_srst_current_state;
    case (reg_fsm_srst_current_state)
      ENUM_ST_RUN: begin
        if (!i_rst_n_sw)
          w_fsm_srst_nxt_state = ENUM_ST_REQ;
      end
      ENUM_ST_REQ: begin
        if (w_ack_v)
          w_fsm_srst_nxt_state = ENUM_ST_PTR;
      end
      ENUM_ST_PTR: w_fsm_srst_nxt_state = ENUM_ST_HOLD;
      ENUM_ST_HOLD: begin
        if (i_rst_n_sw)
          w_fsm_srst_nxt_state = ENUM_ST_REL;
      end
      ENUM_ST_REL: begin
        if (!w_ack_v && (w_rptr_v == '0))
          w_fsm_srst_nxt_state = ENUM_ST_RUN;
      end
      default: w_fsm_srst_nxt_state = ENUM_ST_RUN;
    endcase
  end

  // Current state of the write reset FSM: control state, asynchronously reset to RUN (R-036: this
  // block holds the current state only).
  always_ff @(posedge i_clk_wr, negedge i_rst_n_wr) begin : p_ff_fsm_srst
    if (!i_rst_n_wr)
      reg_fsm_srst_current_state <= ENUM_ST_RUN;
    else
      reg_fsm_srst_current_state <= w_fsm_srst_nxt_state;
  end

  // Busy flop and request flop of the write reset handshake: control state, asynchronously reset.
  // Busy is 1 in every state except RUN. The request is 1 in REQ, PTR and HOLD. Both are decoded
  // from the next state so that they change at the same edge as the FSM.
  always_ff @(posedge i_clk_wr, negedge i_rst_n_wr) begin : p_ff_hs_ctrl
    if (!i_rst_n_wr) begin
      reg_sw_rst_busy <= 1'b0;
      reg_req_wr      <= 1'b0;
    end else begin
      reg_sw_rst_busy <= (w_fsm_srst_nxt_state != ENUM_ST_RUN);
      reg_req_wr      <= (w_fsm_srst_nxt_state == ENUM_ST_REQ) |
                         (w_fsm_srst_nxt_state == ENUM_ST_PTR) |
                         (w_fsm_srst_nxt_state == ENUM_ST_HOLD);
    end
  end

  // Memory write address: the write pointer modulo DEPTH.
  always_comb begin : p_com_wr_addr
    w_addr_ext = w_wptr_ext;
    if (w_wptr_ext >= PARA_SFIFO_DEPTH)
      w_addr_ext = w_wptr_ext - PARA_SFIFO_DEPTH;
  end

  // Output mapping. o_full and o_full_thr are a flop output combined with the block term by one
  // gate; while blocked, o_full_thr shows the value of an empty FIFO.
  assign o_full        = w_wr_blk | reg_full;
  assign o_full_thr    = w_wr_blk ? (i_full_thr == '0) : reg_full_thr;
  assign o_overflow    = reg_overflow;
  assign o_sw_rst_busy = reg_sw_rst_busy;
  assign o_req_wr      = reg_req_wr;
  assign o_wr_ptr      = reg_wptr;
  assign o_mem_wr_en   = w_wr_acc;
  assign o_mem_wr_addr = w_addr_ext[LPARA_ADDR_W-1:0];
  assign o_mem_wr_data = i_wr_data;

endmodule
