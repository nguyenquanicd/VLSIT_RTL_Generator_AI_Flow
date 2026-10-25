/*
 * Project      : VLSIT Common RTL library
 * Author       : Nguyen Quan and Claude Sonnet 5.5 (user)
 * AI Flow      : VLSIT RTL Generator AI Automation Flow
 * AI Flow Page : https://github.com/nguyenquanicd/VLSIT_RTL_Generator_AI_Model
 * Date         : 2026-10-22
 * Description  : Write side of the asynchronous Gray FIFO (write clock domain). It holds the binary
 *                and Gray write pointer, the full and full-threshold flags, the overflow pulse, the
 *                memory write port outputs, the synchronizer of the read Gray pointer, the write
 *                software reset FSM (RUN, REQ, PTR, HOLD, REL), its request register and the
 *                synchronizer of the acknowledge. i_rst_n_sw = 0 requests a software reset:
 *                writes are blocked at once, the read side resets its pointer first and
 *                acknowledges, then the write pointer is reset; the write side is released last.
 *                o_sw_rst_busy is a flip-flop that is 1 while the write FSM is not in RUN.
 */
`timescale 1ns/1ps

module m_vlsit_afifo_wr #(
  // Parameter Description: number of entries of the FIFO. Sets the address and pointer widths.
  // Parameter values: power of 2, minimum 2; default is 8.
  // Parameter unit: count
  parameter logic [31:0] PARA_AFIFO_DEPTH = 8,
  // Parameter Description: data width of one entry.
  // Parameter values: 1 or more; default is 32.
  // Parameter unit: bit
  parameter logic [31:0] PARA_AFIFO_DATA_W = 32,
  // Parameter Description: synchronizer cell selection: 0 = bypass (no stage), 1 = two D flip-flop
  // cells, 2 = one 2-FF cell, 3 = one 3-FF cell, 4 = one 4-FF cell. It sets the number of stages
  // of the synchronizers of this module (0, 2, 2, 3, 4).
  // Parameter values: 0, 1, 2, 3, or 4; default is 2.
  // Parameter unit: none
  parameter logic [31:0] PARA_AFIFO_CELL_TYPE = 2,
  localparam logic [31:0] LPARA_ADDR_W = $clog2(PARA_AFIFO_DEPTH),
  localparam logic [31:0] LPARA_PTR_W = LPARA_ADDR_W + 32'd1,
  localparam logic [31:0] LPARA_FULL_MSK = 32'd3 << (LPARA_PTR_W - 32'd2)
) (
  // Write clock and reset
  input  wire                          i_clk_wr,
  input  wire                          i_rst_n_wr,

  // Write interface
  input  wire                          i_wr_en,
  input  wire  [PARA_AFIFO_DATA_W-1:0] i_wr_data,
  input  wire  [LPARA_PTR_W-1:0]       i_full_thr,
  output logic                         o_full,
  output logic                         o_full_thr,
  output logic                         o_overflow,

  // Software reset and handshake with the read side
  input  wire                          i_rst_n_sw,
  output logic                         o_sw_rst_busy,
  output logic                         o_req_wr,
  input  wire                          i_ack_rd,

  // Gray pointer crossing
  input  wire  [LPARA_PTR_W-1:0]       i_rd_gray,
  output logic [LPARA_PTR_W-1:0]       o_wr_gray,

  // Memory write port
  output logic                         o_mem_wr_en,
  output logic [LPARA_ADDR_W-1:0]      o_mem_wr_addr,
  output logic [PARA_AFIFO_DATA_W-1:0] o_mem_wr_data
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
  logic w_sw_rst_busy_nxt;
  logic reg_req_wr;
  logic w_req_wr_nxt;
  logic reg_overflow;

  logic [LPARA_PTR_W-1:0] reg_wbin;
  logic [LPARA_PTR_W-1:0] w_wbin_nxt;
  logic [LPARA_PTR_W-1:0] reg_wgray;
  logic [LPARA_PTR_W-1:0] w_wgray_nxt;

  logic [LPARA_PTR_W-1:0] w_rgray_s;
  logic [LPARA_PTR_W-1:0] w_rbin_s;
  logic [LPARA_PTR_W-1:0] w_occ;
  logic w_ack_s;
  logic w_wr_blk;
  logic w_full_n;
  logic w_wr_acc;

  // Write block: writes are blocked while the write FSM is not in RUN, which is the busy flop,
  // and in every cycle in which i_rst_n_sw is 0 (zero latency, no flop on this path).
  assign w_wr_blk = reg_sw_rst_busy | ~i_rst_n_sw;

  // Normal full condition: the write Gray pointer equals the synchronized read Gray pointer with
  // its two MSBs inverted. The flag is pessimistic: it can be late to fall, never early.
  assign w_full_n = (reg_wgray == (w_rgray_s ^ LPARA_FULL_MSK[LPARA_PTR_W-1:0]));

  // A write is accepted when it is requested, writes are not blocked, and the FIFO is not full.
  assign w_wr_acc = i_wr_en & ~w_wr_blk & ~w_full_n;

  // Gray to binary conversion of the synchronized read pointer: bit i is the XOR of Gray bits i up.
  always_comb begin : p_com_rbin_s
    w_rbin_s = '0;
    for (int idx = 0; idx < LPARA_PTR_W; idx++) begin
      w_rbin_s[idx] = ^(w_rgray_s >> idx);
    end
  end

  // Occupancy estimate of the write domain: write pointer minus the synchronized read pointer.
  assign w_occ = reg_wbin - w_rbin_s;

  // Flags. o_full is 1 while the write side is blocked (software reset) and when the FIFO is full.
  // o_full_thr is 1 when the occupancy reaches the static threshold; while blocked it shows the
  // value of an empty FIFO (occupancy 0). Both are combinational.
  assign o_full     = w_wr_blk | w_full_n;
  assign o_full_thr = w_wr_blk ? (i_full_thr == '0) : (w_occ >= i_full_thr);

  // Next binary write pointer: reset to 0 in state PTR, incremented by an accepted write.
  always_comb begin : p_com_wbin_nxt
    w_wbin_nxt = reg_wbin;
    if (reg_fsm_srst_current_state == ENUM_ST_PTR)
      w_wbin_nxt = '0;
    else if (w_wr_acc)
      w_wbin_nxt = reg_wbin + 1'b1;
  end

  // Gray code of the next write pointer: the Gray register is the launch register of CDC-001.
  assign w_wgray_nxt = w_wbin_nxt ^ (w_wbin_nxt >> 1);

  // Binary write pointer: control state, asynchronously reset to 0.
  always_ff @(posedge i_clk_wr, negedge i_rst_n_wr) begin : p_ff_wbin
    if (!i_rst_n_wr)
      reg_wbin <= '0;
    else
      reg_wbin <= w_wbin_nxt;
  end

  // Gray write pointer register: changes at most one bit per cycle. Asynchronously reset to 0.
  always_ff @(posedge i_clk_wr, negedge i_rst_n_wr) begin : p_ff_wgray
    if (!i_rst_n_wr)
      reg_wgray <= '0;
    else
      reg_wgray <= w_wgray_nxt;
  end

  // Overflow pulse: registered, one cycle after a write was requested while full. A write that is
  // blocked by the software reset is not an error and raises no pulse.
  always_ff @(posedge i_clk_wr, negedge i_rst_n_wr) begin : p_ff_overflow
    if (!i_rst_n_wr)
      reg_overflow <= 1'b0;
    else
      reg_overflow <= i_wr_en & ~w_wr_blk & w_full_n;
  end

  // Next state of the write reset FSM. RUN takes the request when i_rst_n_sw is 0. REQ waits for
  // the synchronized acknowledge. PTR lasts one cycle. HOLD waits for i_rst_n_sw = 1. REL waits
  // until the acknowledge is 0 and the synchronized read pointer is 0 (flush check), then RUN.
  always_comb begin : p_com_fsm_srst_nxt
    w_fsm_srst_nxt_state = reg_fsm_srst_current_state;
    case (reg_fsm_srst_current_state)
      ENUM_ST_RUN: begin
        if (!i_rst_n_sw)
          w_fsm_srst_nxt_state = ENUM_ST_REQ;
      end
      ENUM_ST_REQ: begin
        if (w_ack_s)
          w_fsm_srst_nxt_state = ENUM_ST_PTR;
      end
      ENUM_ST_PTR: w_fsm_srst_nxt_state = ENUM_ST_HOLD;
      ENUM_ST_HOLD: begin
        if (i_rst_n_sw)
          w_fsm_srst_nxt_state = ENUM_ST_REL;
      end
      ENUM_ST_REL: begin
        if (!w_ack_s && (w_rgray_s == '0))
          w_fsm_srst_nxt_state = ENUM_ST_RUN;
      end
      default: w_fsm_srst_nxt_state = ENUM_ST_RUN;
    endcase
  end

  // Current state of the write reset FSM: control state, asynchronously reset to RUN.
  always_ff @(posedge i_clk_wr, negedge i_rst_n_wr) begin : p_ff_fsm_srst
    if (!i_rst_n_wr)
      reg_fsm_srst_current_state <= ENUM_ST_RUN;
    else
      reg_fsm_srst_current_state <= w_fsm_srst_nxt_state;
  end

  // Next values of the two handshake flops, decoded from the next state so that they change at the
  // same edge as the FSM. busy is 1 in every state except RUN. The request is 1 in REQ, PTR, HOLD.
  assign w_sw_rst_busy_nxt = (w_fsm_srst_nxt_state != ENUM_ST_RUN);
  assign w_req_wr_nxt        = (w_fsm_srst_nxt_state == ENUM_ST_REQ) |
                               (w_fsm_srst_nxt_state == ENUM_ST_PTR) |
                               (w_fsm_srst_nxt_state == ENUM_ST_HOLD);

  // Busy flop: set at the edge where the FSM leaves RUN, cleared at the edge where it returns.
  always_ff @(posedge i_clk_wr, negedge i_rst_n_wr) begin : p_ff_sw_rst_busy
    if (!i_rst_n_wr)
      reg_sw_rst_busy <= 1'b0;
    else
      reg_sw_rst_busy <= w_sw_rst_busy_nxt;
  end

  // Request flop: launch register of CDC-005, set with the busy flop and cleared when REL starts.
  always_ff @(posedge i_clk_wr, negedge i_rst_n_wr) begin : p_ff_req_wr
    if (!i_rst_n_wr)
      reg_req_wr <= 1'b0;
    else
      reg_req_wr <= w_req_wr_nxt;
  end

  // Output mapping: registered flags, pointer and memory write port to the module interface.
  assign o_overflow      = reg_overflow;
  assign o_sw_rst_busy = reg_sw_rst_busy;
  assign o_wr_gray       = reg_wgray;
  assign o_req_wr        = reg_req_wr;
  assign o_mem_wr_en     = w_wr_acc;
  assign o_mem_wr_addr   = reg_wbin[LPARA_ADDR_W-1:0];
  assign o_mem_wr_data   = i_wr_data;

  // Synchronizer of the read Gray pointer (CDC-002), reset to the Gray value 0.
  m_vlsit_afifo_sync #(
    .PARA_AFIFO_SYNC_W        (LPARA_PTR_W),
    .PARA_AFIFO_SYNC_RST_VAL  (32'd0),
    .PARA_AFIFO_CELL_TYPE         (PARA_AFIFO_CELL_TYPE)
  ) u_sync_rd_gray (
    .i_clk_dst   (i_clk_wr),
    .i_rst_n_dst (i_rst_n_wr),
    .i_data      (i_rd_gray),
    .o_data      (w_rgray_s)
  );

  // Synchronizer of the software reset acknowledge (CDC-006), one bit, reset to 0.
  m_vlsit_afifo_sync #(
    .PARA_AFIFO_SYNC_W        (32'd1),
    .PARA_AFIFO_SYNC_RST_VAL  (32'd0),
    .PARA_AFIFO_CELL_TYPE         (PARA_AFIFO_CELL_TYPE)
  ) u_sync_ack (
    .i_clk_dst   (i_clk_wr),
    .i_rst_n_dst (i_rst_n_wr),
    .i_data      (i_ack_rd),
    .o_data      (w_ack_s)
  );

endmodule
