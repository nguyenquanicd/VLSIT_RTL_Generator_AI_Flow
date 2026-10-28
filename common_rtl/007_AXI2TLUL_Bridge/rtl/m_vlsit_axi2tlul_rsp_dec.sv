/*
 * Project      : VLSIT Common RTL library
 * Author       : Nguyen Quan and Claude Sonnet 5.5 (user)
 * AI Flow      : VLSIT RTL Generator AI Automation Flow
 * AI Flow Page : https://github.com/nguyenquanicd/VLSIT_RTL_Generator_AI_Model
 * Date         : 2026-10-26
 * Description  : Response decoder of the AXI2TLUL bridge. It accepts every TL-UL channel D beat
 *                (d_ready is a flip-flop that is 1 from the second cycle after reset), decodes the
 *                direction and the slot index from the tag, checks the opcode against the
 *                direction, and reports the completion to the read or the write slot table. A beat
 *                whose tag is not an allocated slot is orphaned: it is dropped and reported as a
 *                condition for the orphan pulse. A beat with a wrong opcode completes its slot with
 *                an error and is reported for the bad-response pulse.
 */
`timescale 1ns/1ps

module m_vlsit_axi2tlul_rsp_dec #(
  // Parameter Description: width of the TL-UL source field (tag), direction bit above the index.
  // Parameter values: at least LPARA_SLOT_W + 1; default is 8.
  // Parameter unit: bit
  parameter logic [31:0] PARA_TL_SRC_W = 8,
  // Parameter Description: number of read slots.
  // Parameter values: power of two from 2 to 128; default is 16.
  // Parameter unit: count
  parameter logic [31:0] PARA_NUM_RD = 16,
  // Parameter Description: number of write slots.
  // Parameter values: power of two from 2 to 128; default is 16.
  // Parameter unit: count
  parameter logic [31:0] PARA_NUM_WR = 16,
  localparam logic [31:0] LPARA_RD_IDX_W = $clog2(PARA_NUM_RD),
  localparam logic [31:0] LPARA_WR_IDX_W = $clog2(PARA_NUM_WR),
  localparam logic [31:0] LPARA_SLOT_W = (PARA_NUM_RD > PARA_NUM_WR) ? $clog2(PARA_NUM_RD) : $clog2(PARA_NUM_WR),
  localparam logic [31:0] LPARA_OPC_ACK = 0,
  localparam logic [31:0] LPARA_OPC_ACK_DATA = 1
) (
  // Clock and reset
  input  wire                       i_clk_main,
  input  wire                       i_rst_n_main,

  // TL-UL channel D
  input  wire                       i_tl_d_valid,
  output logic                      o_tl_d_ready,
  input  wire  [2:0]                i_tl_d_opcode,
  input  wire  [PARA_TL_SRC_W-1:0]  i_tl_d_src,
  input  wire                       i_tl_d_err,

  // Read completion
  output logic                      o_rd_cmp_valid,
  output logic [LPARA_RD_IDX_W-1:0] o_rd_cmp_idx,
  output logic                      o_rd_cmp_err,
  input  wire                       i_rd_cmp_orphan,

  // Write completion
  output logic                      o_wr_cmp_valid,
  output logic [LPARA_WR_IDX_W-1:0] o_wr_cmp_idx,
  output logic                      o_wr_cmp_err,
  input  wire                       i_wr_cmp_orphan,

  // Conditions for the status pulses
  output logic                      o_orphan,
  output logic                      o_bad
);

  // Internal signal declarations
  logic                      reg_ready;
  logic                      w_dir_wr;
  logic [LPARA_SLOT_W-1:0]   w_idx_full;
  logic                      w_hi_bad;
  logic                      w_idx_ok_rd;
  logic                      w_idx_ok_wr;
  logic                      w_tag_bad;
  logic                      w_op_bad;
  logic                      w_slot_orphan;

  // d_ready is a flip-flop: 0 in reset and 1 from the second cycle after the release. Channel D
  // never stalls because a slot is reserved for every outstanding request.
  assign o_tl_d_ready = reg_ready;

  // Tag decode: bit LPARA_SLOT_W selects the direction (1 = write), the bits below are the slot
  // index, and any bit above must be 0. An index outside the slot table of its direction is a bad
  // tag.
  assign w_dir_wr    = i_tl_d_src[LPARA_SLOT_W];
  assign w_idx_full  = i_tl_d_src[LPARA_SLOT_W-1:0];
  assign w_hi_bad    = ((i_tl_d_src >> (LPARA_SLOT_W + 1)) != '0);
  assign w_idx_ok_rd = ({1'b0, w_idx_full} < (LPARA_SLOT_W + 1)'(PARA_NUM_RD));
  assign w_idx_ok_wr = ({1'b0, w_idx_full} < (LPARA_SLOT_W + 1)'(PARA_NUM_WR));
  assign w_tag_bad   = w_hi_bad | (w_dir_wr ? ~w_idx_ok_wr : ~w_idx_ok_rd);

  // Opcode check: a write slot expects AccessAck and a read slot expects AccessAckData.
  assign w_op_bad    = w_dir_wr ? (i_tl_d_opcode != LPARA_OPC_ACK[2:0]) : (i_tl_d_opcode != LPARA_OPC_ACK_DATA[2:0]);

  // Completion to the slot tables: a wrong opcode is reported to the table as an error completion.
  assign o_rd_cmp_valid = i_tl_d_valid & ~w_tag_bad & ~w_dir_wr;
  assign o_rd_cmp_idx   = w_idx_full[LPARA_RD_IDX_W-1:0];
  assign o_rd_cmp_err   = i_tl_d_err | w_op_bad;
  assign o_wr_cmp_valid = i_tl_d_valid & ~w_tag_bad & w_dir_wr;
  assign o_wr_cmp_idx   = w_idx_full[LPARA_WR_IDX_W-1:0];
  assign o_wr_cmp_err   = i_tl_d_err | w_op_bad;

  // Conditions for the status pulses: orphaned beat (bad tag or slot not allocated) and wrong
  // opcode on a beat of an allocated slot.
  assign w_slot_orphan = w_dir_wr ? i_wr_cmp_orphan : i_rd_cmp_orphan;
  assign o_orphan      = i_tl_d_valid & (w_tag_bad | w_slot_orphan);
  assign o_bad         = i_tl_d_valid & ~w_tag_bad & ~w_slot_orphan & w_op_bad;

  // Ready register: 0 in reset, then 1.
  always_ff @(posedge i_clk_main, negedge i_rst_n_main) begin : p_ff_ready
    if (!i_rst_n_main)
      reg_ready <= 1'b0;
    else
      reg_ready <= 1'b1;
  end

endmodule
