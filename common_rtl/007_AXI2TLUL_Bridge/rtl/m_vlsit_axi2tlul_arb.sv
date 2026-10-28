/*
 * Project      : VLSIT Common RTL library
 * Author       : Nguyen Quan and Claude Sonnet 5.5 (user)
 * AI Flow      : VLSIT RTL Generator AI Automation Flow
 * AI Flow Page : https://github.com/nguyenquanicd/VLSIT_RTL_Generator_AI_Model
 * Date         : 2026-10-26
 * Description  : Arbiter and TL-UL channel A register of the AXI2TLUL bridge. It grants the read or
 *                the write request according to PARA_ARB_MODE, builds the tag and the user bits,
 *                and loads the channel A output register, which holds the request with stable
 *                payload until the device accepts it. The register accepts a new request in the
 *                cycle in which the device takes the old one, so one request per cycle is possible.
 *                All outputs are flip-flops except the constant a_param.
 */
`timescale 1ns/1ps

module m_vlsit_axi2tlul_arb #(
  // Parameter Description: width of the request address.
  // Parameter values: 12 to 64; default is 32.
  // Parameter unit: bit
  parameter logic [31:0] PARA_ADDR_W = 32,
  // Parameter Description: width of the data bus; the mask has one bit per byte.
  // Parameter values: 32, 64, 128, 256, 512, or 1024; default is 32.
  // Parameter unit: bit
  parameter logic [31:0] PARA_DATA_W = 32,
  // Parameter Description: width of the TL-UL source field (tag).
  // Parameter values: at least LPARA_SLOT_W + 1; default is 8.
  // Parameter unit: bit
  parameter logic [31:0] PARA_TL_SRC_W = 8,
  // Parameter Description: width of the TL-UL user field; bits above 17 are reserved and driven 0.
  // Parameter values: 18 to 64; default is 18.
  // Parameter unit: bit
  parameter logic [31:0] PARA_TL_AUSER_W = 18,
  // Parameter Description: number of read slots.
  // Parameter values: power of two from 2 to 128; default is 16.
  // Parameter unit: count
  parameter logic [31:0] PARA_NUM_RD = 16,
  // Parameter Description: number of write slots.
  // Parameter values: power of two from 2 to 128; default is 16.
  // Parameter unit: count
  parameter logic [31:0] PARA_NUM_WR = 16,
  // Parameter Description: arbitration of read and write requests.
  // Parameter values: 0 = round-robin, 1 = read priority, 2 = write priority; default is 0.
  // Parameter unit: none
  parameter logic [31:0] PARA_ARB_MODE = 0,
  localparam logic [31:0] LPARA_STRB_W = PARA_DATA_W / 8,
  localparam logic [31:0] LPARA_SIZE_W = $clog2($clog2(PARA_DATA_W / 8) + 1),
  localparam logic [31:0] LPARA_RD_IDX_W = $clog2(PARA_NUM_RD),
  localparam logic [31:0] LPARA_WR_IDX_W = $clog2(PARA_NUM_WR),
  localparam logic [31:0] LPARA_SLOT_W = (PARA_NUM_RD > PARA_NUM_WR) ? $clog2(PARA_NUM_RD) : $clog2(PARA_NUM_WR),
  localparam logic [31:0] LPARA_MODE_RR = 0,
  localparam logic [31:0] LPARA_MODE_RD_PRIO = 1,
  localparam logic [31:0] LPARA_MODE_WR_PRIO = 2,
  localparam logic [31:0] LPARA_OPC_GET = 4,
  localparam logic [31:0] LPARA_MUBI_TRUE = 6,
  localparam logic [31:0] LPARA_MUBI_FALSE = 9,
  localparam logic [31:0] LPARA_INTG_DEFAULT = 127,
  localparam logic [31:0] LPARA_USER_LOW_W = 18
) (
  // Clock and reset
  input  wire                        i_clk_main,
  input  wire                        i_rst_n_main,

  // Read request
  input  wire                        i_rd_valid,
  output logic                       o_rd_gnt,
  input  wire  [PARA_ADDR_W-1:0]     i_rd_addr,
  input  wire  [LPARA_SIZE_W-1:0]    i_rd_size,
  input  wire  [LPARA_STRB_W-1:0]    i_rd_mask,
  input  wire                        i_rd_instr,
  input  wire  [LPARA_RD_IDX_W-1:0]  i_rd_slot,

  // Write request
  input  wire                        i_wr_valid,
  output logic                       o_wr_gnt,
  input  wire  [2:0]                 i_wr_opcode,
  input  wire  [PARA_ADDR_W-1:0]     i_wr_addr,
  input  wire  [LPARA_SIZE_W-1:0]    i_wr_size,
  input  wire  [LPARA_STRB_W-1:0]    i_wr_mask,
  input  wire  [PARA_DATA_W-1:0]     i_wr_data,
  input  wire                        i_wr_instr,
  input  wire  [LPARA_WR_IDX_W-1:0]  i_wr_slot,

  // TL-UL channel A
  output logic                       o_tl_a_valid,
  input  wire                        i_tl_a_ready,
  output logic [2:0]                 o_tl_a_opcode,
  output logic [2:0]                 o_tl_a_param,
  output logic [LPARA_SIZE_W-1:0]    o_tl_a_size,
  output logic [PARA_TL_SRC_W-1:0]   o_tl_a_src,
  output logic [PARA_ADDR_W-1:0]     o_tl_a_addr,
  output logic [LPARA_STRB_W-1:0]    o_tl_a_mask,
  output logic [PARA_DATA_W-1:0]     o_tl_a_data,
  output logic [PARA_TL_AUSER_W-1:0] o_tl_a_user
);

  // Internal signal declarations
  logic                       reg_a_valid;
  logic [2:0]                 reg_a_opcode;
  logic [LPARA_SIZE_W-1:0]    reg_a_size;
  logic [PARA_TL_SRC_W-1:0]   reg_a_src;
  logic [PARA_ADDR_W-1:0]     reg_a_addr;
  logic [LPARA_STRB_W-1:0]    reg_a_mask;
  logic [PARA_DATA_W-1:0]     reg_a_data;
  logic [PARA_TL_AUSER_W-1:0] reg_a_user;
  logic                       reg_prio_wr;
  logic                       w_a_free;
  logic                       w_pref_rd;
  logic                       w_gnt_rd;
  logic                       w_gnt_wr;
  logic [PARA_TL_SRC_W-1:0]   w_rd_src;
  logic [PARA_TL_SRC_W-1:0]   w_wr_src;
  logic [PARA_TL_AUSER_W-1:0] w_rd_user;
  logic [PARA_TL_AUSER_W-1:0] w_wr_user;
  logic                       w_a_valid_nxt;
  logic [2:0]                 w_a_opcode_nxt;
  logic [LPARA_SIZE_W-1:0]    w_a_size_nxt;
  logic [PARA_TL_SRC_W-1:0]   w_a_src_nxt;
  logic [PARA_ADDR_W-1:0]     w_a_addr_nxt;
  logic [LPARA_STRB_W-1:0]    w_a_mask_nxt;
  logic [PARA_DATA_W-1:0]     w_a_data_nxt;
  logic [PARA_TL_AUSER_W-1:0] w_a_user_nxt;

  // Output mapping: channel A comes from the output register; a_param is the constant 0.
  assign o_tl_a_valid  = reg_a_valid;
  assign o_tl_a_opcode = reg_a_opcode;
  assign o_tl_a_param  = 3'b000;
  assign o_tl_a_size   = reg_a_size;
  assign o_tl_a_src    = reg_a_src;
  assign o_tl_a_addr   = reg_a_addr;
  assign o_tl_a_mask   = reg_a_mask;
  assign o_tl_a_data   = reg_a_data;
  assign o_tl_a_user   = reg_a_user;
  assign o_rd_gnt      = w_gnt_rd;
  assign o_wr_gnt      = w_gnt_wr;

  // Tag and user bits. The tag has the direction bit above the slot index and zeros above it. The
  // user bits hold instr_type (mubi4 True for an instruction access, False otherwise) above the two
  // integrity fields at their default value; the bits above bit 17 are 0.
  assign w_rd_src  = $bits(w_rd_src)'(i_rd_slot);
  assign w_wr_src  = ($bits(w_wr_src)'(1) << LPARA_SLOT_W) | $bits(w_wr_src)'(i_wr_slot);

  // User bits of a read request and of a write request: the 18 low bits carry the fields, the bits
  // above bit 17 are 0.
  always_comb begin : p_com_user
    w_rd_user                   = '0;
    w_wr_user                   = '0;
    w_rd_user[LPARA_USER_LOW_W-1:0] = {(i_rd_instr ? LPARA_MUBI_TRUE[3:0] : LPARA_MUBI_FALSE[3:0]),
                                       LPARA_INTG_DEFAULT[6:0], LPARA_INTG_DEFAULT[6:0]};
    w_wr_user[LPARA_USER_LOW_W-1:0] = {(i_wr_instr ? LPARA_MUBI_TRUE[3:0] : LPARA_MUBI_FALSE[3:0]),
                                       LPARA_INTG_DEFAULT[6:0], LPARA_INTG_DEFAULT[6:0]};
  end

  // Grant: the A register can take a request when it is empty or when the device takes its request
  // in this cycle. With both requests present the mode decides; in round-robin mode the direction
  // that was not granted last wins, and the first tie after reset goes to the read request.
  always_comb begin : p_com_gnt
    w_a_free  = ~reg_a_valid | i_tl_a_ready;
    w_pref_rd = ~reg_prio_wr;
    case (PARA_ARB_MODE)
      LPARA_MODE_RR:      w_pref_rd = ~reg_prio_wr;
      LPARA_MODE_RD_PRIO: w_pref_rd = 1'b1;
      LPARA_MODE_WR_PRIO: w_pref_rd = 1'b0;
      default:            w_pref_rd = ~reg_prio_wr;
    endcase
    w_gnt_rd = w_a_free & i_rd_valid & (~i_wr_valid | w_pref_rd);
    w_gnt_wr = w_a_free & i_wr_valid & (~i_rd_valid | ~w_pref_rd);
  end

  // Channel A register next state: it keeps the request until the device accepts it and loads the
  // granted request. A read request drives a_data with all ones (BlankedAData of the TL-UL
  // package).
  always_comb begin : p_com_a_nxt
    w_a_valid_nxt  = reg_a_valid & ~i_tl_a_ready;
    w_a_opcode_nxt = reg_a_opcode;
    w_a_size_nxt   = reg_a_size;
    w_a_src_nxt    = reg_a_src;
    w_a_addr_nxt   = reg_a_addr;
    w_a_mask_nxt   = reg_a_mask;
    w_a_data_nxt   = reg_a_data;
    w_a_user_nxt   = reg_a_user;
    if (w_gnt_rd) begin
      w_a_valid_nxt  = 1'b1;
      w_a_opcode_nxt = LPARA_OPC_GET[2:0];
      w_a_size_nxt   = i_rd_size;
      w_a_src_nxt    = w_rd_src;
      w_a_addr_nxt   = i_rd_addr;
      w_a_mask_nxt   = i_rd_mask;
      w_a_data_nxt   = '1;
      w_a_user_nxt   = w_rd_user;
    end else if (w_gnt_wr) begin
      w_a_valid_nxt  = 1'b1;
      w_a_opcode_nxt = i_wr_opcode;
      w_a_size_nxt   = i_wr_size;
      w_a_src_nxt    = w_wr_src;
      w_a_addr_nxt   = i_wr_addr;
      w_a_mask_nxt   = i_wr_mask;
      w_a_data_nxt   = i_wr_data;
      w_a_user_nxt   = w_wr_user;
    end
  end

  // Channel A output register and the round-robin pointer, reset to idle.
  always_ff @(posedge i_clk_main, negedge i_rst_n_main) begin : p_ff_a
    if (!i_rst_n_main) begin
      reg_a_valid  <= 1'b0;
      reg_a_opcode <= '0;
      reg_a_size   <= '0;
      reg_a_src    <= '0;
      reg_a_addr   <= '0;
      reg_a_mask   <= '0;
      reg_a_data   <= '0;
      reg_a_user   <= '0;
      reg_prio_wr  <= 1'b0;
    end else begin
      reg_a_valid  <= w_a_valid_nxt;
      reg_a_opcode <= w_a_opcode_nxt;
      reg_a_size   <= w_a_size_nxt;
      reg_a_src    <= w_a_src_nxt;
      reg_a_addr   <= w_a_addr_nxt;
      reg_a_mask   <= w_a_mask_nxt;
      reg_a_data   <= w_a_data_nxt;
      reg_a_user   <= w_a_user_nxt;
      if (w_gnt_rd | w_gnt_wr)
        reg_prio_wr <= w_gnt_rd;
    end
  end

endmodule
