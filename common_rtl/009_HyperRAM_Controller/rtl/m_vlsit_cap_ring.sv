/*
 * Project      : HyperRAM Controller
 * Author       : Nguyen Quan (user)
 * AI Flow      : VLSIT RTL Generator AI Automation Flow
 * AI Flow Page : https://github.com/nguyenquanicd/VLSIT_RTL_Generator_AI_Model
 * Date         : 2026-10-31
 * Description  : Capture ring of the HyperBus read data (CDC-003, DEC-049). Four entries are
 *                written on the write clock, which only runs while the device drives RWDS, and are
 *                read on the core clock. Only the write pointer crosses to the core domain, in Gray
 *                code through the library synchronizer cell; nothing flows from the core domain
 *                back to the write domain. The write side therefore never waits for a full flag,
 *                which a quiet write clock could not update (an asynchronous FIFO with a read
 *                pointer synchronized into the write domain loses data in this case). The reader
 *                follows the synchronized write pointer: it is empty when both pointers are equal,
 *                i_rd_en takes the head entry, and i_flush moves the read pointer to the write
 *                pointer, which discards every entry written so far (the pair that RWDS makes when
 *                it returns LOW after the command and address phase, and entries left by an earlier
 *                read). A ring that is not read fast enough is overwritten and o_overrun shows it.
 *                The write side is reset only by the core reset, which is released while the write
 *                clock is quiet.
 */
`timescale 1ns/1ps

module m_vlsit_cap_ring #(
  // Parameter Description: width of one entry (one pair of DDR beats).
  // Parameter values: 16 or 32; default is 16.
  // Parameter unit: bit
  parameter logic [31:0] PARA_CAP_DATA_W = 32'd16,
  localparam logic [31:0] LPARA_PTR_W     = 32'd3,
  localparam logic [31:0] LPARA_IDX_W     = 32'd2,
  localparam logic [31:0] LPARA_DEPTH     = 32'd4,
  localparam logic [31:0] LPARA_SYNC_TYPE = 32'd2
) (
  // Write clock and reset (write clock domain)
  input  wire                        i_clk_wr,
  input  wire                        i_rst_n_wr,
  input  wire  [PARA_CAP_DATA_W-1:0] i_wr_data,

  // Read clock and reset (core clock domain)
  input  wire                        i_clk_rd,
  input  wire                        i_rst_n_rd,
  input  wire                        i_rd_en,
  input  wire                        i_flush,
  output logic [PARA_CAP_DATA_W-1:0] o_rd_data,
  output logic                       o_empty,
  output logic                       o_overrun
);

  // Internal signal declarations
  logic [PARA_CAP_DATA_W-1:0] reg_mem [0:LPARA_DEPTH-1];
  logic [LPARA_PTR_W-1:0]     reg_wbin;
  logic [LPARA_PTR_W-1:0]     reg_wgray;
  logic [LPARA_PTR_W-1:0]     w_wbin_nxt;
  logic [LPARA_PTR_W-1:0]     w_wgray_s;
  logic [LPARA_PTR_W-1:0]     w_wbin_s;
  logic [LPARA_PTR_W-1:0]     reg_rbin;
  logic [LPARA_PTR_W-1:0]     w_occ;

  // Write side: every write clock edge stores the entry and advances the write pointer. The
  // pointer moves after the entry is stored, so a reader that sees the new pointer sees the data.
  assign w_wbin_nxt = reg_wbin + 3'd1;

  always_ff @(posedge i_clk_wr, negedge i_rst_n_wr) begin : p_ff_wptr
    if (!i_rst_n_wr) begin
      reg_wbin  <= '0;
      reg_wgray <= '0;
    end else begin
      reg_wbin  <= w_wbin_nxt;
      reg_wgray <= w_wbin_nxt ^ (w_wbin_nxt >> 1);
    end
  end

  // Entry storage, resetless payload that the reader uses only below the write pointer.
  always_ff @(posedge i_clk_wr) begin : p_ff_mem
    reg_mem[reg_wbin[LPARA_IDX_W-1:0]] <= i_wr_data;
  end

  // Write pointer into the core domain: one library synchronizer cell per Gray bit.
  for (genvar gen_b = 0; gen_b < LPARA_PTR_W; gen_b++) begin : gen_sync
    m_vlsit_afifo_cell_sync #(
      .PARA_AFIFO_CELL_RST_VAL (32'd0),
      .PARA_AFIFO_CELL_TYPE    (LPARA_SYNC_TYPE)
    ) u_vlsit_afifo_cell_sync (
      .i_clk_dst   (i_clk_rd),
      .i_rst_n_dst (i_rst_n_rd),
      .i_d         (reg_wgray[gen_b]),
      .o_q         (w_wgray_s[gen_b])
    );
  end

  // Gray to binary conversion of the synchronized write pointer.
  assign w_wbin_s = {w_wgray_s[2],
                     w_wgray_s[2] ^ w_wgray_s[1],
                     w_wgray_s[2] ^ w_wgray_s[1] ^ w_wgray_s[0]};

  // Read side: the read pointer takes one entry per i_rd_en, or jumps to the write pointer with
  // i_flush.
  always_ff @(posedge i_clk_rd, negedge i_rst_n_rd) begin : p_ff_rptr
    if (!i_rst_n_rd) begin
      reg_rbin <= '0;
    end else if (i_flush) begin
      reg_rbin <= w_wbin_s;
    end else if (i_rd_en && (reg_rbin != w_wbin_s)) begin
      reg_rbin <= reg_rbin + 3'd1;
    end
  end

  // Flags and the head entry. The ring holds at most four entries; a larger distance means the
  // writer has overwritten unread entries.
  assign w_occ     = w_wbin_s - reg_rbin;
  assign o_empty   = (reg_rbin == w_wbin_s);
  assign o_overrun = (32'(w_occ) > LPARA_DEPTH);
  assign o_rd_data = reg_mem[reg_rbin[LPARA_IDX_W-1:0]];

endmodule
