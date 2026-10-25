/*
 * Project      : VLSIT Common RTL library
 * Author       : Nguyen Quan and Claude Sonnet 5.5 (user)
 * AI Flow      : VLSIT RTL Generator AI Automation Flow
 * AI Flow Page : https://github.com/nguyenquanicd/VLSIT_RTL_Generator_AI_Model
 * Date         : 2026-10-22
 * Description  : Read side of the asynchronous Gray FIFO (read clock domain). It holds the binary
 *                and Gray read pointer, the empty and empty-threshold flags, the underflow pulse,
 *                the memory read address output (address of the next read pointer, show-ahead),
 *                the synchronizer of the write Gray pointer, the read software reset FSM (RUN, RST,
 *                ACK), its acknowledge register and the synchronizer of the request. When the
 *                synchronized request is 1 reads are blocked and o_empty is 1; the FSM resets the
 *                read pointer first and then raises the acknowledge. The read side is released
 *                first, when the request is 0 and the synchronized write pointer is 0.
 */
`timescale 1ns/1ps

module m_vlsit_afifo_rd #(
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
  localparam logic [31:0] LPARA_PTR_W = LPARA_ADDR_W + 32'd1
) (
  // Read clock and reset
  input  wire                          i_clk_rd,
  input  wire                          i_rst_n_rd,

  // Read interface
  input  wire                          i_rd_en,
  input  wire  [LPARA_PTR_W-1:0]       i_empty_thr,
  output logic [PARA_AFIFO_DATA_W-1:0] o_rd_data,
  output logic                         o_empty,
  output logic                         o_empty_thr,
  output logic                         o_underflow,

  // Software reset handshake with the write side
  input  wire                          i_req_wr,
  output logic                         o_ack_rd,

  // Gray pointer crossing
  input  wire  [LPARA_PTR_W-1:0]       i_wr_gray,
  output logic [LPARA_PTR_W-1:0]       o_rd_gray,

  // Memory read port
  output logic [LPARA_ADDR_W-1:0]      o_mem_rd_addr,
  input  wire  [PARA_AFIFO_DATA_W-1:0] i_mem_rd_data
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
  logic w_ack_rd_nxt;
  logic reg_underflow;

  logic [LPARA_PTR_W-1:0] reg_rbin;
  logic [LPARA_PTR_W-1:0] w_rbin_nxt;
  logic [LPARA_PTR_W-1:0] reg_rgray;
  logic [LPARA_PTR_W-1:0] w_rgray_nxt;

  logic [LPARA_PTR_W-1:0] w_wgray_s;
  logic [LPARA_PTR_W-1:0] w_wbin_s;
  logic [LPARA_PTR_W-1:0] w_occ;
  logic w_req_s;
  logic w_rd_blk;
  logic w_empty_n;
  logic w_rd_acc;

  // Read block: reads are blocked while the synchronized request is 1 and while the read FSM is
  // not in RUN (zero latency from these two conditions).
  assign w_rd_blk = w_req_s | (reg_fsm_srst_current_state != ENUM_ST_RUN);

  // Normal empty condition: the read Gray pointer equals the synchronized write Gray pointer.
  // The flag is pessimistic: it can be late to fall, never early.
  assign w_empty_n = (reg_rgray == w_wgray_s);

  // A read is accepted when it is requested, reads are not blocked, and the FIFO is not empty.
  assign w_rd_acc = i_rd_en & ~w_rd_blk & ~w_empty_n;

  // Gray to binary conversion of the synchronized write pointer: bit i is the XOR of Gray bits
  // i and above.
  always_comb begin : p_com_wbin_s
    w_wbin_s = '0;
    for (int idx = 0; idx < LPARA_PTR_W; idx++) begin
      w_wbin_s[idx] = ^(w_wgray_s >> idx);
    end
  end

  // Occupancy estimate of the read domain: synchronized write pointer minus the read pointer.
  assign w_occ = w_wbin_s - reg_rbin;

  // Flags. o_empty is 1 while the read side is blocked (software reset) and when the FIFO is empty.
  // o_empty_thr is 1 when the occupancy is at or below the static threshold; while blocked it is
  // 1 (an empty FIFO has occupancy 0). Both are combinational.
  assign o_empty     = w_rd_blk | w_empty_n;
  assign o_empty_thr = w_rd_blk ? 1'b1 : (w_occ <= i_empty_thr);

  // Next binary read pointer: reset to 0 in state RST, incremented by an accepted read.
  always_comb begin : p_com_rbin_nxt
    w_rbin_nxt = reg_rbin;
    if (reg_fsm_srst_current_state == ENUM_ST_RST)
      w_rbin_nxt = '0;
    else if (w_rd_acc)
      w_rbin_nxt = reg_rbin + 1'b1;
  end

  // Gray code of the next read pointer: the Gray register is the launch register of CDC-002.
  assign w_rgray_nxt = w_rbin_nxt ^ (w_rbin_nxt >> 1);

  // Binary read pointer: control state, asynchronously reset to 0.
  always_ff @(posedge i_clk_rd, negedge i_rst_n_rd) begin : p_ff_rbin
    if (!i_rst_n_rd)
      reg_rbin <= '0;
    else
      reg_rbin <= w_rbin_nxt;
  end

  // Gray read pointer register: changes at most one bit per cycle. Asynchronously reset to 0.
  always_ff @(posedge i_clk_rd, negedge i_rst_n_rd) begin : p_ff_rgray
    if (!i_rst_n_rd)
      reg_rgray <= '0;
    else
      reg_rgray <= w_rgray_nxt;
  end

  // Underflow pulse: registered, one cycle after a read was requested while empty. A read that is
  // blocked by the software reset is not an error and raises no pulse.
  always_ff @(posedge i_clk_rd, negedge i_rst_n_rd) begin : p_ff_underflow
    if (!i_rst_n_rd)
      reg_underflow <= 1'b0;
    else
      reg_underflow <= i_rd_en & ~w_rd_blk & w_empty_n;
  end

  // Next state of the read reset FSM. RUN goes to RST when the synchronized request is 1. RST lasts
  // one cycle. ACK returns to RUN when the request is 0 and the synchronized write pointer is 0
  // (flush check): the read side is released before the write side.
  always_comb begin : p_com_fsm_srst_nxt
    w_fsm_srst_nxt_state = reg_fsm_srst_current_state;
    case (reg_fsm_srst_current_state)
      ENUM_ST_RUN: begin
        if (w_req_s)
          w_fsm_srst_nxt_state = ENUM_ST_RST;
      end
      ENUM_ST_RST: w_fsm_srst_nxt_state = ENUM_ST_ACK;
      ENUM_ST_ACK: begin
        if (!w_req_s && (w_wgray_s == '0))
          w_fsm_srst_nxt_state = ENUM_ST_RUN;
      end
      default: w_fsm_srst_nxt_state = ENUM_ST_RUN;
    endcase
  end

  // Current state of the read reset FSM: control state, asynchronously reset to RUN.
  always_ff @(posedge i_clk_rd, negedge i_rst_n_rd) begin : p_ff_fsm_srst
    if (!i_rst_n_rd)
      reg_fsm_srst_current_state <= ENUM_ST_RUN;
    else
      reg_fsm_srst_current_state <= w_fsm_srst_nxt_state;
  end

  // Next acknowledge: 1 from the edge that leaves RST (the read pointer is reset at that same
  // edge) until the edge that leaves ACK.
  assign w_ack_rd_nxt = (w_fsm_srst_nxt_state == ENUM_ST_ACK);

  // Acknowledge flop: launch register of CDC-006, asynchronously reset to 0.
  always_ff @(posedge i_clk_rd, negedge i_rst_n_rd) begin : p_ff_ack_rd
    if (!i_rst_n_rd)
      reg_ack_rd <= 1'b0;
    else
      reg_ack_rd <= w_ack_rd_nxt;
  end

  // Output mapping: registered flags and pointer, the memory read address and the read data.
  // The address is the low bits of the next read pointer, so after an accepted read the storage
  // output already shows the next word (show-ahead, DEC-022). The storage is read every cycle.
  assign o_underflow   = reg_underflow;
  assign o_rd_gray     = reg_rgray;
  assign o_ack_rd      = reg_ack_rd;
  assign o_mem_rd_addr = w_rbin_nxt[LPARA_ADDR_W-1:0];
  assign o_rd_data     = i_mem_rd_data;

  // Synchronizer of the write Gray pointer (CDC-001), reset to the Gray value 0.
  m_vlsit_afifo_sync #(
    .PARA_AFIFO_SYNC_W        (LPARA_PTR_W),
    .PARA_AFIFO_SYNC_RST_VAL  (32'd0),
    .PARA_AFIFO_CELL_TYPE         (PARA_AFIFO_CELL_TYPE)
  ) u_sync_wr_gray (
    .i_clk_dst   (i_clk_rd),
    .i_rst_n_dst (i_rst_n_rd),
    .i_data      (i_wr_gray),
    .o_data      (w_wgray_s)
  );

  // Synchronizer of the software reset request (CDC-005), one bit, reset to 0.
  m_vlsit_afifo_sync #(
    .PARA_AFIFO_SYNC_W        (32'd1),
    .PARA_AFIFO_SYNC_RST_VAL  (32'd0),
    .PARA_AFIFO_CELL_TYPE         (PARA_AFIFO_CELL_TYPE)
  ) u_sync_req (
    .i_clk_dst   (i_clk_rd),
    .i_rst_n_dst (i_rst_n_rd),
    .i_data      (i_req_wr),
    .o_data      (w_req_s)
  );

endmodule
