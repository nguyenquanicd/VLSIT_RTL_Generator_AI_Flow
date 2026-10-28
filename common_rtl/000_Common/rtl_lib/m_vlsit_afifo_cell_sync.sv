/*
 * Project      : VLSIT Common RTL library
 * Author       : Nguyen Quan and Claude Sonnet 5.5 (user)
 * AI Flow      : VLSIT RTL Generator AI Automation Flow
 * AI Flow Page : https://github.com/nguyenquanicd/VLSIT_RTL_Generator_AI_Model
 * Date         : 2026-10-22
 * Description  : Wrapper of the technology synchronizer cell of the asynchronous Gray FIFO, one
 *                bit. PARA_AFIFO_CELL_TYPE selects the cell: 0 = bypass (o_q = i_d, no stage),
 *                1 = two D flip-flop cells in series (2 stages), 2 = one 2-FF synchronizer cell,
 *                3 = one 3-FF synchronizer cell, 4 = one 4-FF synchronizer cell. With the flow
 *                macro VLSIT_SYNTHESIS it instantiates the library cells (flops with asynchronous
 *                reset to 0, or with asynchronous set to 1, by PARA_AFIFO_CELL_RST_VAL), named
 *                u_dont_touch_<function>. Without the macro it contains the simulation model of
 *                the same option with the same number of stages and the metastability model of
 *                REQ-VER-001: the first flop resolves to the old or to the new value, 50% each,
 *                when the input changes inside an aperture window before the capturing edge, so the
 *                output is 0 or 1 cycle later than nominal. The window is a percentage of the
 *                measured period of i_clk_dst. Plusargs: +AFIFO_MSYNC_SEED=<n> (default 1),
 *                +AFIFO_MSYNC_EN=<0|1> (default 1), +AFIFO_MSYNC_WIN_PCT=<0..100> (default 10).
 *                The simulation branch is excluded from the RTL rules by rule R-027 (spec DEC-021,
 *                DEC-038, DEC-048). This is the only module that models metastability.
 */
`timescale 1ns/1ps

module m_vlsit_afifo_cell_sync #(
  // Parameter Description: reset flavour of the cells: 0 = asynchronous reset to 0 (cells with RN),
  // 1 = asynchronous set to 1 (cells with SN). One value per synchronizer bit.
  // Parameter values: 0 or 1; default is 0.
  // Parameter unit: none
  parameter logic [31:0] PARA_AFIFO_CELL_RST_VAL = 0,
  // Parameter Description: cell selection. 0 = bypass, 1 = two D flip-flop cells in series,
  // 2 = one 2-FF cell, 3 = one 3-FF cell, 4 = one 4-FF cell. The number of stages is 0, 2, 2, 3, 4.
  // Parameter values: 0, 1, 2, 3, or 4; default is 2.
  // Parameter unit: none
  parameter logic [31:0] PARA_AFIFO_CELL_TYPE = 2,
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
  // Types above 4 are illegal and give the 4-FF cell (behavior undefined, DEC-002).
  if (PARA_AFIFO_CELL_TYPE == LPARA_TYPE_BYPASS) begin : gen_bypass
    // Option 0: no cell and no stage, the input is the output.
    assign o_q = i_d;
  end else if (PARA_AFIFO_CELL_TYPE == LPARA_TYPE_DFF2) begin : gen_dff2
    // Option 1: two D flip-flop cells in series.
    logic w_mid;
    if (PARA_AFIFO_CELL_RST_VAL == 32'd0) begin : gen_rn
      VLSIT_CELL_SYNC_DFF_RN u_dont_touch_dff_0 (.CK (i_clk_dst), .RN (i_rst_n_dst),  .D (i_d),   .Q (w_mid));
      VLSIT_CELL_SYNC_DFF_RN u_dont_touch_dff_1 (.CK (i_clk_dst), .RN (i_rst_n_dst),  .D (w_mid), .Q (o_q));
    end else begin : gen_sn
      VLSIT_CELL_SYNC_DFF_SN u_dont_touch_dff_0 (.CK (i_clk_dst), .SN (i_rst_n_dst),  .D (i_d),   .Q (w_mid));
      VLSIT_CELL_SYNC_DFF_SN u_dont_touch_dff_1 (.CK (i_clk_dst), .SN (i_rst_n_dst),  .D (w_mid), .Q (o_q));
    end
  end else if (PARA_AFIFO_CELL_TYPE == LPARA_TYPE_SYNC2) begin : gen_sync2
    // Option 2: one 2-FF synchronizer cell.
    if (PARA_AFIFO_CELL_RST_VAL == 32'd0) begin : gen_rn
      VLSIT_CELL_SYNC_2FF_RN u_dont_touch_sync2ff (.CK (i_clk_dst), .RN (i_rst_n_dst),  .D (i_d), .Q (o_q));
    end else begin : gen_sn
      VLSIT_CELL_SYNC_2FF_SN u_dont_touch_sync2ff (.CK (i_clk_dst), .SN (i_rst_n_dst),  .D (i_d), .Q (o_q));
    end
  end else if (PARA_AFIFO_CELL_TYPE == LPARA_TYPE_SYNC3) begin : gen_sync3
    // Option 3: one 3-FF synchronizer cell.
    if (PARA_AFIFO_CELL_RST_VAL == 32'd0) begin : gen_rn
      VLSIT_CELL_SYNC_3FF_RN u_dont_touch_sync3ff (.CK (i_clk_dst), .RN (i_rst_n_dst),  .D (i_d), .Q (o_q));
    end else begin : gen_sn
      VLSIT_CELL_SYNC_3FF_SN u_dont_touch_sync3ff (.CK (i_clk_dst), .SN (i_rst_n_dst),  .D (i_d), .Q (o_q));
    end
  end else begin : gen_sync4
    // Option 4: one 4-FF synchronizer cell.
    if (PARA_AFIFO_CELL_RST_VAL == 32'd0) begin : gen_rn
      VLSIT_CELL_SYNC_4FF_RN u_dont_touch_sync4ff (.CK (i_clk_dst), .RN (i_rst_n_dst),  .D (i_d), .Q (o_q));
    end else begin : gen_sn
      VLSIT_CELL_SYNC_4FF_SN u_dont_touch_sync4ff (.CK (i_clk_dst), .SN (i_rst_n_dst),  .D (i_d), .Q (o_q));
    end
  end
`else
  // ---------------------------------------------------------------------------------------------
  // Simulation branch (REQ-VER-001, DEC-012, DEC-038, DEC-048). Option 0 is the bypass. Options 1 to 4
  // are a chain of 2, 2, 3 and 4 flops, the same function as the cells of the synthesis branch. The
  // metastability model is in the first flop: when the input changed less than the window W before
  // the capturing edge, the flop resolves to the new value or to the old value with a probability of
  // 50% each (the old value then reaches the next flop one edge later, because the input is stable at
  // the following edge). A change outside the window, or at the same time as the edge, is captured
  // as by a plain flop. W is WIN_PCT percent of the last measured period of i_clk_dst, so the
  // latency counted after the first capturing edge is N-1 or N for N stages. Only a bit that changes
  // inside the window can be late: bits that change one source period apart are not reordered when
  // W is shorter than the source period (the source clock is at most 100 / WIN_PCT times faster).
  // The cell is one bit, so every bit of a synchronizer is independent.
  // ---------------------------------------------------------------------------------------------
  if (PARA_AFIFO_CELL_TYPE == LPARA_TYPE_BYPASS) begin : gen_sim_bypass
    // Option 0: bypass, no stage and nothing to model.
    assign o_q = i_d;
  end else begin : gen_sim_msync
    localparam int SIM_STAGE = (PARA_AFIFO_CELL_TYPE == LPARA_TYPE_DFF2) ? 2 :
                               (PARA_AFIFO_CELL_TYPE > 32'd4) ? 4 : int'(PARA_AFIFO_CELL_TYPE);

    logic [SIM_STAGE-1:0] sim_ch;   // flop chain, sim_ch[0] is the first flop
    logic [31:0] sim_rs;
    logic        sim_en;
    int          sim_seed;
    int          sim_en_arg;
    int          sim_win_pct;
    real         sim_t_chg;         // time of the last change of i_d
    real         sim_t_edge;        // time of the previous capturing edge
    real         sim_t_per;         // last measured period of i_clk_dst
    real         sim_t_now;
    int          sim_n_win;         // captures with the input changed inside the window
    int          sim_n_old;         // of these, captures of the old value
    logic        sim_pick_new;

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
      sim_seed    = 1;
      sim_en      = 1'b1;
      sim_win_pct = 10;
      sim_t_chg   = -1.0;
      sim_t_edge  = -1.0;
      sim_t_per   = 0.0;
      sim_n_win   = 0;
      sim_n_old   = 0;
      if ($value$plusargs("AFIFO_MSYNC_SEED=%d", sim_seed))
        ;
      if ($value$plusargs("AFIFO_MSYNC_EN=%d", sim_en_arg))
        sim_en = (sim_en_arg != 0);
      if ($value$plusargs("AFIFO_MSYNC_WIN_PCT=%d", sim_win_pct)) begin
        if (sim_win_pct < 0)   sim_win_pct = 0;
        if (sim_win_pct > 100) sim_win_pct = 100;
      end
      sim_rs = ((32'(sim_seed) * 32'h9e3779b1) ^ f_sim_hash($sformatf("%m"))) | 32'd1;
      for (int k = 0; k < 8; k++) sim_rs = f_sim_next(sim_rs);
      $display("AFIFO_MSYNC: %m seed=%0d enable=%0d window=%0d%% stages=%0d", sim_seed, sim_en, sim_win_pct, SIM_STAGE);
    end

    // Time of the last change of the input (written as a process with an event wait: a plain
    // 'always @(i_d)' form is not evaluated with the time by the Verilator timing scheduler).
    always begin
      @(i_d);
      sim_t_chg = $realtime;
    end

    // Flop chain with the metastability model in the first flop.
    always @(posedge i_clk_dst or negedge i_rst_n_dst) begin
      if (!i_rst_n_dst) begin
        sim_ch <= {SIM_STAGE{PARA_AFIFO_CELL_RST_VAL[0]}};
      end else begin
        sim_t_now = $realtime;
        if (sim_t_edge >= 0.0) sim_t_per = sim_t_now - sim_t_edge;
        sim_t_edge = sim_t_now;
        sim_ch <= {sim_ch[SIM_STAGE-2:0], i_d};
        if (sim_en && (i_d !== sim_ch[0]) && (sim_t_chg >= 0.0) && (sim_t_chg < sim_t_now) &&
            ((sim_t_now - sim_t_chg) < (sim_t_per * sim_win_pct / 100.0))) begin
          sim_rs       = f_sim_next(sim_rs);
          sim_pick_new = sim_rs[16];
          sim_n_win    = sim_n_win + 1;
          if (!sim_pick_new) begin
            sim_ch[0] <= sim_ch[0];
            sim_n_old  = sim_n_old + 1;
          end
        end
      end
    end

    // Statistics at the end of the simulation: evidence that the window was exercised.
    final begin
      if (sim_en)
        $display("AFIFO_MSYNC_STAT: %m window_captures=%0d old_value_captures=%0d", sim_n_win, sim_n_old);
    end

    assign o_q = sim_ch[SIM_STAGE-1];
  end
`endif

endmodule
