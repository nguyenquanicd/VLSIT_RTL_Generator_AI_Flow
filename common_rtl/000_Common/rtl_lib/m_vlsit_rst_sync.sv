/*
 * Project      : VLSIT Common RTL library
 * Author       : Nguyen Quan and Claude Sonnet 5.5 (user)
 * AI Flow      : VLSIT RTL Generator AI Automation Flow
 * AI Flow Page : https://github.com/nguyenquanicd/VLSIT_RTL_Generator_AI_Model
 * Date         : 2026-10-25
 * Description  : Reset synchronizer with asynchronous assertion and synchronous de-assertion,
 *                active-low reset. The D input of the first stage is tied to 1 by a tie-high
 *                cell. PARA_RST_SYNC_TYPE selects the depth: 1 = two D flip-flop cells in series
 *                (2 stages), 2 = one 2-FF synchronizer cell, 3 = one 3-FF synchronizer cell,
 *                4 = one 4-FF synchronizer cell. With the flow macro VLSIT_SYNTHESIS it
 *                instantiates the library cells (flops with asynchronous reset to 0 and the
 *                tie-high cell), named u_dont_touch_<function>. Without the macro it contains the
 *                simulation model of the same option with the same number of stages and a
 *                metastability model on the de-assertion: a random extra latency of 0, 1 or 2
 *                cycles, controlled by the plusargs +RSTSYNC_MSYNC_SEED=<n> (default 1) and
 *                +RSTSYNC_MSYNC_EN=<0|1> (default 1). The assertion (output to 0) is asynchronous
 *                and has no extra latency. The simulation branch is excluded from the RTL rules
 *                by rule R-027.
 */
`timescale 1ns/1ps

module m_vlsit_rst_sync #(
  // Parameter Description: depth selection. 1 = two D flip-flop cells in series, 2 = one 2-FF
  // cell, 3 = one 3-FF cell, 4 = one 4-FF cell. The number of stages is 2, 2, 3, 4.
  // Parameter values: 1, 2, 3, or 4; default is 2.
  // Parameter unit: none
  parameter logic [31:0] PARA_RST_SYNC_TYPE = 2,
  localparam logic [31:0] LPARA_TYPE_DFF2  = 32'd1,
  localparam logic [31:0] LPARA_TYPE_SYNC2 = 32'd2,
  localparam logic [31:0] LPARA_TYPE_SYNC3 = 32'd3
) (
  // Destination clock and source reset
  input  wire  i_clk_dst,
  input  wire  i_rst_n_src,

  // Synchronized reset
  output logic o_rst_n_dst
);

`ifdef VLSIT_SYNTHESIS
  // Cell selection: the option is chosen at elaboration. Only this wrapper names library cells
  // (HIE-07). Types above 4 are illegal and give the 4-FF cell.
  logic w_tie_hi;

  // Constant 1 for the D input of the first stage.
  VLSIT_CELL_TIEH u_dont_touch_tieh (.Z (w_tie_hi));

  if (PARA_RST_SYNC_TYPE == LPARA_TYPE_DFF2) begin : gen_dff2
    // Option 1: two D flip-flop cells in series.
    logic w_mid;
    VLSIT_CELL_SYNC_DFF_RN u_dont_touch_dff_0 (.CK (i_clk_dst), .RN (i_rst_n_src),  .D (w_tie_hi), .Q (w_mid));
    VLSIT_CELL_SYNC_DFF_RN u_dont_touch_dff_1 (.CK (i_clk_dst), .RN (i_rst_n_src),  .D (w_mid),    .Q (o_rst_n_dst));
  end else if (PARA_RST_SYNC_TYPE == LPARA_TYPE_SYNC2) begin : gen_sync2
    // Option 2: one 2-FF synchronizer cell.
    VLSIT_CELL_SYNC_2FF_RN u_dont_touch_sync2ff (.CK (i_clk_dst), .RN (i_rst_n_src),  .D (w_tie_hi), .Q (o_rst_n_dst));
  end else if (PARA_RST_SYNC_TYPE == LPARA_TYPE_SYNC3) begin : gen_sync3
    // Option 3: one 3-FF synchronizer cell.
    VLSIT_CELL_SYNC_3FF_RN u_dont_touch_sync3ff (.CK (i_clk_dst), .RN (i_rst_n_src),  .D (w_tie_hi), .Q (o_rst_n_dst));
  end else begin : gen_sync4
    // Option 4: one 4-FF synchronizer cell.
    VLSIT_CELL_SYNC_4FF_RN u_dont_touch_sync4ff (.CK (i_clk_dst), .RN (i_rst_n_src),  .D (w_tie_hi), .Q (o_rst_n_dst));
  end
`else
  // ---------------------------------------------------------------------------------------------
  // Simulation branch. A chain of 2, 2, 3 or 4 flops with asynchronous reset to 0 and D = 1, the
  // same function as the cells of the synthesis branch, with the metastability model on the
  // output: when the input of the last stage changes (the de-assertion), a random extra delay of
  // 0, 1 or 2 cycles is applied. Latency counted after the first capturing edge: nominal N-1 for
  // N stages, so N-1, N or N+1. The assertion is asynchronous and immediate.
  // ---------------------------------------------------------------------------------------------
  if (1'b1) begin : gen_sim_msync
    localparam int SIM_STAGE = (PARA_RST_SYNC_TYPE == 32'd1) ? 2 :
                               (PARA_RST_SYNC_TYPE > 32'd4) ? 4 : int'(PARA_RST_SYNC_TYPE);

    logic [SIM_STAGE-1:0] sim_ch;
    logic        sim_last, sim_cur, sim_nxt, sim_pend, sim_din_last;
    int          sim_cnt;
    logic [31:0] sim_rs;
    logic        sim_en;
    int          sim_seed;
    int          sim_en_arg;
    int          sim_extra;

    // Xorshift step of the pseudo random generator (deterministic for a given seed).
    function automatic logic [31:0] f_sim_next(input logic [31:0] x);
      logic [31:0] y;
      begin
        y = x;
        y = y ^ (y << 13);
        y = y ^ (y >> 17);
        y = y ^ (y << 5);
        f_sim_next = y;
      end
    endfunction

    // Hash of the hierarchical instance name, so that every cell gets its own random stream.
    function automatic logic [31:0] f_sim_hash(input string s);
      logic [31:0] h;
      begin
        h = 32'h811c9dc5;
        for (int k = 0; k < s.len(); k++) h = (h ^ 32'(s[k])) * 32'h01000193;
        f_sim_hash = h;
      end
    endfunction

    // Plusargs and seed printing at the start of the simulation.
    initial begin
      sim_seed = 1;
      sim_en   = 1'b1;
      if ($value$plusargs("RSTSYNC_MSYNC_SEED=%d", sim_seed))
        ;
      if ($value$plusargs("RSTSYNC_MSYNC_EN=%d", sim_en_arg))
        sim_en = (sim_en_arg != 0);
      sim_rs = (32'(sim_seed) ^ f_sim_hash($sformatf("%m")) ^ 32'h9e3779b9) | 32'd1;
      $display("RSTSYNC_MSYNC: %m seed=%0d enable=%0d stages=%0d", sim_seed, sim_en, SIM_STAGE);
    end

    // din_last is the value that the last stage captures at this very edge.
    assign sim_din_last = sim_ch[SIM_STAGE-2];

    // Chain and delay model.
    always @(posedge i_clk_dst or negedge i_rst_n_src) begin
      if (!i_rst_n_src) begin
        sim_ch   <= {SIM_STAGE{1'b0}};
        sim_last <= 1'b0;
        sim_cur  <= 1'b0;
        sim_pend <= 1'b0;
        sim_cnt   = 0;
      end else begin
        sim_ch <= {sim_ch[SIM_STAGE-2:0], 1'b1};
        if (sim_din_last !== sim_last) begin
          sim_last <= sim_din_last;
          sim_rs    = f_sim_next(sim_rs);
          sim_extra = int'((sim_rs >> 7) % 3);
          if (sim_extra == 0) begin
            sim_cur  <= sim_din_last;
            sim_pend <= 1'b0;
          end else begin
            sim_nxt  <= sim_din_last;
            sim_cnt   = sim_extra - 1;
            sim_pend <= 1'b1;
          end
        end else if (sim_pend) begin
          if (sim_cnt == 0) begin
            sim_cur  <= sim_nxt;
            sim_pend <= 1'b0;
          end else begin
            sim_cnt = sim_cnt - 1;
          end
        end
      end
    end

    // Output: random-latency value when the model is enabled, plain chain output otherwise.
    assign o_rst_n_dst = sim_en ? sim_cur : sim_ch[SIM_STAGE-1];
  end
`endif

endmodule
