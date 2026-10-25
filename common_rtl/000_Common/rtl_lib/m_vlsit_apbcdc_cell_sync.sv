/*
 * Project      : VLSIT Common RTL library
 * Author       : Nguyen Quan and Claude Sonnet 5.5 (user)
 * AI Flow      : VLSIT RTL Generator AI Automation Flow
 * AI Flow Page : https://github.com/nguyenquanicd/VLSIT_RTL_Generator_AI_Model
 * Date         : 2026-10-25
 * Description  : Wrapper of the technology synchronizer cell of the asynchronous APB bridge, one
 *                bit. PARA_APBCDC_CELL_TYPE selects the cell: 0 = bypass (o_q = i_d, no stage),
 *                1 = two D flip-flop cells in series (2 stages), 2 = one 2-FF synchronizer cell,
 *                3 = one 3-FF synchronizer cell, 4 = one 4-FF synchronizer cell. With the flow
 *                macro VLSIT_SYNTHESIS it instantiates the library cells (flops with asynchronous
 *                reset to 0, or with asynchronous set to 1, by PARA_APBCDC_CELL_RST_VAL), named
 *                u_dont_touch_<function>. Without the macro it contains the simulation model of
 *                the same option with the same number of stages and the metastability model of
 *                REQ-RTL-002: a random extra latency of 0, 1 or 2 cycles on the output, controlled
 *                by the plusargs +APBCDC_MSYNC_SEED=<n> (default 1) and +APBCDC_MSYNC_EN=<0|1>
 *                (default 1). The simulation branch is excluded from the RTL rules by rule R-027
 *                (spec DEC-022, REQ-RTL-002). This is the only module that models metastability.
 */
`timescale 1ns/1ps

module m_vlsit_apbcdc_cell_sync #(
  // Parameter Description: reset flavour of the cells: 0 = asynchronous reset to 0 (cells with RN),
  // 1 = asynchronous set to 1 (cells with SN). One value per synchronizer bit.
  // Parameter values: 0 or 1; default is 0.
  // Parameter unit: none
  parameter logic [31:0] PARA_APBCDC_CELL_RST_VAL = 0,
  // Parameter Description: cell selection. 0 = bypass, 1 = two D flip-flop cells in series,
  // 2 = one 2-FF cell, 3 = one 3-FF cell, 4 = one 4-FF cell. The number of stages is 0, 2, 2, 3, 4.
  // Parameter values: 0, 1, 2, 3, or 4; default is 2.
  // Parameter unit: none
  parameter logic [31:0] PARA_APBCDC_CELL_TYPE = 2,
  localparam logic [31:0] LPARA_TYPE_BYPASS = 32'd0,
  localparam logic [31:0] LPARA_TYPE_DFF2   = 32'd1,
  localparam logic [31:0] LPARA_TYPE_SYNC2  = 32'd2,
  localparam logic [31:0] LPARA_TYPE_SYNC3  = 32'd3
) (
  // Destination clock and reset
  input  wire  i_clk_dst,
  input  wire  i_rst_n_dst,

  // Cell data
  input  wire  i_d,
  output logic o_q
);

`ifdef VLSIT_SYNTHESIS
  // Cell selection: the option and the reset flavour are chosen at elaboration. Only this wrapper
  // names library cells (HIE-07); the cells VLSIT_CELL_SYNC_* stand in for the real library.
  // Types above 4 are illegal and give the 4-FF cell (behavior undefined, REQ-PARAM-001).
  if (PARA_APBCDC_CELL_TYPE == LPARA_TYPE_BYPASS) begin : gen_bypass
    // Option 0: no cell and no stage, the input is the output.
    assign o_q = i_d;
  end else if (PARA_APBCDC_CELL_TYPE == LPARA_TYPE_DFF2) begin : gen_dff2
    // Option 1: two D flip-flop cells in series.
    logic w_mid;
    if (PARA_APBCDC_CELL_RST_VAL == 32'd0) begin : gen_rn
      VLSIT_CELL_SYNC_DFF_RN u_dont_touch_dff_0 (.CK (i_clk_dst), .RN (i_rst_n_dst),  .D (i_d),   .Q (w_mid));
      VLSIT_CELL_SYNC_DFF_RN u_dont_touch_dff_1 (.CK (i_clk_dst), .RN (i_rst_n_dst),  .D (w_mid), .Q (o_q));
    end else begin : gen_sn
      VLSIT_CELL_SYNC_DFF_SN u_dont_touch_dff_0 (.CK (i_clk_dst), .SN (i_rst_n_dst),  .D (i_d),   .Q (w_mid));
      VLSIT_CELL_SYNC_DFF_SN u_dont_touch_dff_1 (.CK (i_clk_dst), .SN (i_rst_n_dst),  .D (w_mid), .Q (o_q));
    end
  end else if (PARA_APBCDC_CELL_TYPE == LPARA_TYPE_SYNC2) begin : gen_sync2
    // Option 2: one 2-FF synchronizer cell.
    if (PARA_APBCDC_CELL_RST_VAL == 32'd0) begin : gen_rn
      VLSIT_CELL_SYNC_2FF_RN u_dont_touch_sync2ff (.CK (i_clk_dst), .RN (i_rst_n_dst),  .D (i_d), .Q (o_q));
    end else begin : gen_sn
      VLSIT_CELL_SYNC_2FF_SN u_dont_touch_sync2ff (.CK (i_clk_dst), .SN (i_rst_n_dst),  .D (i_d), .Q (o_q));
    end
  end else if (PARA_APBCDC_CELL_TYPE == LPARA_TYPE_SYNC3) begin : gen_sync3
    // Option 3: one 3-FF synchronizer cell.
    if (PARA_APBCDC_CELL_RST_VAL == 32'd0) begin : gen_rn
      VLSIT_CELL_SYNC_3FF_RN u_dont_touch_sync3ff (.CK (i_clk_dst), .RN (i_rst_n_dst),  .D (i_d), .Q (o_q));
    end else begin : gen_sn
      VLSIT_CELL_SYNC_3FF_SN u_dont_touch_sync3ff (.CK (i_clk_dst), .SN (i_rst_n_dst),  .D (i_d), .Q (o_q));
    end
  end else begin : gen_sync4
    // Option 4: one 4-FF synchronizer cell.
    if (PARA_APBCDC_CELL_RST_VAL == 32'd0) begin : gen_rn
      VLSIT_CELL_SYNC_4FF_RN u_dont_touch_sync4ff (.CK (i_clk_dst), .RN (i_rst_n_dst),  .D (i_d), .Q (o_q));
    end else begin : gen_sn
      VLSIT_CELL_SYNC_4FF_SN u_dont_touch_sync4ff (.CK (i_clk_dst), .SN (i_rst_n_dst),  .D (i_d), .Q (o_q));
    end
  end
`else
  // ---------------------------------------------------------------------------------------------
  // Simulation branch (REQ-RTL-002, DEC-022). Option 0 is the bypass. Options 1 to 4 are
  // a chain of 2, 2, 3 and 4 flops, the same function as the cells of the synthesis branch, with
  // the metastability model on the output: when the input of the last stage changes, a random
  // extra delay of 0, 1 or 2 cycles is applied. Latency counted after the first capturing edge:
  // nominal N-1 for N stages, so N-1, N or N+1. A new input value replaces a pending change and
  // restarts the delay. The cell is one bit, so every bit of a synchronizer is independent.
  // ---------------------------------------------------------------------------------------------
  if (PARA_APBCDC_CELL_TYPE == LPARA_TYPE_BYPASS) begin : gen_sim_bypass
    // Option 0: bypass, no stage and nothing to model.
    assign o_q = i_d;
  end else begin : gen_sim_msync
    localparam int SIM_STAGE = (PARA_APBCDC_CELL_TYPE == LPARA_TYPE_DFF2) ? 2 :
                               (PARA_APBCDC_CELL_TYPE > 32'd4) ? 4 : int'(PARA_APBCDC_CELL_TYPE);

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
      if ($value$plusargs("APBCDC_MSYNC_SEED=%d", sim_seed))
        ;
      if ($value$plusargs("APBCDC_MSYNC_EN=%d", sim_en_arg))
        sim_en = (sim_en_arg != 0);
      sim_rs = (32'(sim_seed) ^ f_sim_hash($sformatf("%m")) ^ 32'h9e3779b9) | 32'd1;
      $display("APBCDC_MSYNC: %m seed=%0d enable=%0d stages=%0d", sim_seed, sim_en, SIM_STAGE);
    end

    // din_last is the value that the last stage captures at this very edge.
    assign sim_din_last = sim_ch[SIM_STAGE-2];

    // Chain and delay model.
    always @(posedge i_clk_dst or negedge i_rst_n_dst) begin
      if (!i_rst_n_dst) begin
        sim_ch   <= {SIM_STAGE{PARA_APBCDC_CELL_RST_VAL[0]}};
        sim_last <= PARA_APBCDC_CELL_RST_VAL[0];
        sim_cur  <= PARA_APBCDC_CELL_RST_VAL[0];
        sim_pend <= 1'b0;
        sim_cnt   = 0;
      end else begin
        sim_ch <= {sim_ch[SIM_STAGE-2:0], i_d};
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
    assign o_q = sim_en ? sim_cur : sim_ch[SIM_STAGE-1];
  end
`endif

endmodule
