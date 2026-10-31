/*
 * Project      : HyperRAM Controller
 * Author       : Nguyen Quan (user)
 * AI Flow      : VLSIT RTL Generator AI Automation Flow
 * AI Flow Page : https://github.com/nguyenquanicd/VLSIT_RTL_Generator_AI_Model
 * Date         : 2026-10-31
 * Description  : Pin engine of the HyperBus interface (REQ-MEM-007 to REQ-MEM-010, DEC-022,
 *                DEC-030). It divides i_clk_core by i_ck_div into the CK period and gives the
 *                controller the pulse o_ck_tick in the last core cycle of every CK period. At that
 *                tick it registers one command of the controller (chip select levels, CK run, one
 *                memory unit of two DDR beats with its RWDS levels and output enables) and drives
 *                it during the next CK period: beat A in the first half, beat B in the second half.
 *                DQ and RWDS change on the rising edge of i_clk_core. CK is high in the first half
 *                of a running period; with i_ck_phase = 0 it is delayed by half a core cycle
 *                (falling edge flop), which centers it in the data interval at i_ck_div = 2.
 *                A CS# or CK
 *                change takes effect at a tick, so the granularity of all waits is one CK period.
 *                Read data are captured on both edges of i_clk_cap into the capture ring
 *                m_vlsit_cap_ring (write side clocked by the inverted capture clock, so that the
 *                second beat of a pair is written at the falling edge). Only the core reset resets
 *                the ring; the controller empties it with i_cap_flush (DEC-040, DEC-049). The
 *                power-good input is
 *                synchronized with the library synchronizer and gates RESET#. Known deviation: the
 *                CK output is a mux of two flops, selected by the static i_ck_phase.
 */
`timescale 1ns/1ps

module m_vlsit_hyperbus_phy #(
  // Parameter Description: width of the HyperBus data bus; one memory unit is two bus widths.
  // Parameter values: 8 or 16; default is 8.
  // Parameter unit: bit
  parameter logic [31:0] PARA_MEM_DQ_W = 32'd8,
  // Parameter Description: number of chip selects.
  // Parameter values: 1 or 2; default is 1.
  // Parameter unit: count
  parameter logic [31:0] PARA_NUM_CS = 32'd1,
  // Parameter Description: width of the delay-line tap select.
  // Parameter values: 1 to 8; default is 4.
  // Parameter unit: bit
  parameter logic [31:0] PARA_DLY_TAP_W = 32'd4,
  localparam logic [31:0] LPARA_RWDS_W    = PARA_MEM_DQ_W / 32'd8,
  localparam logic [31:0] LPARA_UNIT_W    = PARA_MEM_DQ_W * 32'd2,
  localparam logic [31:0] LPARA_UNIT_B    = PARA_MEM_DQ_W / 32'd4,
  localparam logic [31:0] LPARA_CAP_SYNC  = 32'd2
) (
  // Clock and reset
  input  wire                       i_clk_core,
  input  wire                       i_rst_n_core,

  // Static configuration
  input  wire  [7:0]                i_ck_div,
  input  wire                       i_ck_diff,
  input  wire                       i_ck_phase,
  input  wire  [PARA_DLY_TAP_W-1:0] i_dly_sel,

  // Tick and command from the controller
  output logic                      o_ck_tick,
  input  wire  [PARA_NUM_CS-1:0]    i_cmd_cs_n,
  input  wire                       i_cmd_ck_run,
  input  wire  [LPARA_UNIT_W-1:0]   i_cmd_dq,
  input  wire                       i_cmd_dq_oe,
  input  wire  [LPARA_UNIT_B-1:0]   i_cmd_rwds,
  input  wire                       i_cmd_rwds_oe,
  input  wire                       i_cmd_mem_rel,

  // Observation toward the controller
  output logic [LPARA_RWDS_W-1:0]   o_rwds_smp,
  output logic                      o_pwr_good,

  // Read capture toward the controller
  input  wire                       i_cap_pop,
  input  wire                       i_cap_flush,
  output logic [LPARA_UNIT_W-1:0]   o_cap_data,
  output logic                      o_cap_empty,

  // Memory power good (asynchronous)
  input  wire                       i_mem_pwr_good,

  // HyperBus pins toward the pad wrapper
  output logic                      o_rst_n_mem,
  output logic [PARA_NUM_CS-1:0]    o_hb_cs_n,
  output logic                      o_clk_hb,
  output logic                      o_clk_hb_n,
  input  wire  [PARA_MEM_DQ_W-1:0]  i_hb_dq,
  output logic [PARA_MEM_DQ_W-1:0]  o_hb_dq,
  output logic [PARA_MEM_DQ_W-1:0]  o_hb_dq_oe,
  input  wire  [LPARA_RWDS_W-1:0]   i_hb_rwds,
  output logic [LPARA_RWDS_W-1:0]   o_hb_rwds,
  output logic [LPARA_RWDS_W-1:0]   o_hb_rwds_oe,
  input  wire                       i_clk_cap,
  output logic [PARA_DLY_TAP_W-1:0] o_hb_rwds_dly_sel
);

  // Internal signal declarations
  logic [7:0]                 reg_cnt;
  logic [PARA_NUM_CS-1:0]     reg_cs_n;
  logic [PARA_DLY_TAP_W-1:0]  reg_dly_sel;
  logic                       reg_rst_mem_n;
  logic [PARA_MEM_DQ_W-1:0]   reg_dq;
  logic [LPARA_RWDS_W-1:0]    reg_rwds;
  logic [LPARA_RWDS_W-1:0]    reg_rwds_smp;
  logic                       reg_half;
  logic                       reg_last;
  logic [7:0]                 w_half_m1;
  logic [7:0]                 w_cnt_nxt;
  logic                       w_edge_e;
  logic                       w_edge_m;
  logic [LPARA_UNIT_W-1:0]    reg_unit;
  logic [LPARA_UNIT_B-1:0]    reg_rwds_unit;
  logic                       reg_ck_r;
  logic                       reg_ck_f;
  logic                       w_ck_o;
  logic                       reg_dq_oe;
  logic                       reg_rwds_oe;
  logic                       w_pwr_good_s;
  logic                       w_clk_cap_n;
  logic [PARA_MEM_DQ_W-1:0]   reg_cap_a;
  logic [LPARA_UNIT_W-1:0]    w_cap_wr_data;

  // ---------------------------------------------------------------------------------------------
  // CK period timebase
  // ---------------------------------------------------------------------------------------------

  // The CK period has two halves of i_ck_div / 2 core cycles. reg_last marks the last cycle of a
  // half; the tick is the last cycle of the second half. The comparison uses >= so that a change
  // of i_ck_div while the controller is disabled cannot leave the counter above its limit.
  assign w_half_m1 = {1'b0, i_ck_div[7:1]} - 8'd1;
  assign w_cnt_nxt = reg_last ? 8'd0 : (reg_cnt + 8'd1);

  // Timebase registers: counter, half flag and the last-cycle flag.
  always_ff @(posedge i_clk_core, negedge i_rst_n_core) begin : p_ff_timebase
    if (!i_rst_n_core) begin
      reg_cnt  <= 8'd0;
      reg_half <= 1'b0;
      reg_last <= 1'b0;
    end else begin
      reg_cnt  <= w_cnt_nxt;
      reg_half <= reg_last ? ~reg_half : reg_half;
      reg_last <= (w_cnt_nxt >= w_half_m1);
    end
  end

  // Tick (end of a CK period, start of the next) and the middle of a period.
  assign w_edge_e  = reg_last & reg_half;
  assign w_edge_m  = reg_last & ~reg_half;
  assign o_ck_tick = w_edge_e;

  // ---------------------------------------------------------------------------------------------
  // Command registers and pin drivers
  // ---------------------------------------------------------------------------------------------

  // Chip selects, output enables, RESET# and the delay-line select change at the tick only; a
  // reset puts every pin in its idle state (CS# high, no drive, RESET# low).
  always_ff @(posedge i_clk_core, negedge i_rst_n_core) begin : p_ff_pins
    if (!i_rst_n_core) begin
      reg_cs_n          <= '1;
      reg_dq_oe         <= 1'b0;
      reg_rwds_oe       <= 1'b0;
      reg_dly_sel       <= '0;
    end else if (w_edge_e) begin
      reg_cs_n          <= i_cmd_cs_n;
      reg_dq_oe         <= i_cmd_dq_oe;
      reg_rwds_oe       <= i_cmd_rwds_oe;
      reg_dly_sel       <= i_dly_sel;
    end
  end

  // RESET# to the memory: low in core reset, while the controller requests it and while the
  // synchronized power good is low (REQ-RST-004).
  always_ff @(posedge i_clk_core, negedge i_rst_n_core) begin : p_ff_rst_mem
    if (!i_rst_n_core)
      reg_rst_mem_n <= 1'b0;
    else
      reg_rst_mem_n <= i_cmd_mem_rel & w_pwr_good_s;
  end

  // Unit registers: the command unit is kept for the second beat.
  always_ff @(posedge i_clk_core) begin : p_ff_unit
    if (w_edge_e) begin
      reg_unit      <= i_cmd_dq;
      reg_rwds_unit <= i_cmd_rwds;
    end
  end

  // DQ and RWDS data: beat A is launched at the tick, beat B in the middle of the period.
  always_ff @(posedge i_clk_core, negedge i_rst_n_core) begin : p_ff_data
    if (!i_rst_n_core) begin
      reg_dq   <= '0;
      reg_rwds <= '0;
    end else if (w_edge_e) begin
      reg_dq   <= i_cmd_dq[PARA_MEM_DQ_W-1:0];
      reg_rwds <= i_cmd_rwds[LPARA_RWDS_W-1:0];
    end else if (w_edge_m) begin
      reg_dq   <= reg_unit[LPARA_UNIT_W-1:PARA_MEM_DQ_W];
      reg_rwds <= reg_rwds_unit[LPARA_UNIT_B-1:LPARA_RWDS_W];
    end
  end

  // Pin outputs: data and masks from their registers, output enables one bit per pin.
  assign o_hb_dq           = reg_dq;
  assign o_hb_rwds         = reg_rwds;
  assign o_hb_dq_oe        = {PARA_MEM_DQ_W{reg_dq_oe}};
  assign o_hb_rwds_oe      = {LPARA_RWDS_W{reg_rwds_oe}};
  assign o_hb_cs_n         = reg_cs_n;
  assign o_hb_rwds_dly_sel = reg_dly_sel;
  assign o_rst_n_mem       = reg_rst_mem_n;

  // CK level: high in the first half of a running period, low otherwise. The rising-edge flop is
  // used for i_ck_phase = 1; the falling-edge flop copies it half a core cycle later.
  always_ff @(posedge i_clk_core, negedge i_rst_n_core) begin : p_ff_ck_r
    if (!i_rst_n_core)
      reg_ck_r <= 1'b0;
    else if (w_edge_e)
      reg_ck_r <= i_cmd_ck_run;
    else if (w_edge_m)
      reg_ck_r <= 1'b0;
  end

  // Falling-edge copy of the CK level: CK delayed by half a core cycle.
  always_ff @(negedge i_clk_core, negedge i_rst_n_core) begin : p_ff_ck_f
    if (!i_rst_n_core)
      reg_ck_f <= 1'b0;
    else
      reg_ck_f <= reg_ck_r;
  end

  // CK and CK# outputs. CK# is the complement of CK when differential, otherwise held high.
  assign w_ck_o     = i_ck_phase ? reg_ck_r : reg_ck_f;
  assign o_clk_hb   = w_ck_o;
  assign o_clk_hb_n = ~w_ck_o | ~i_ck_diff;

  // RWDS samples for the controller (latency indication in the CA phase).
  always_ff @(posedge i_clk_core, negedge i_rst_n_core) begin : p_ff_rwds_smp
    if (!i_rst_n_core)
      reg_rwds_smp <= '0;
    else
      reg_rwds_smp <= i_hb_rwds;
  end

  // Sampled RWDS toward the controller.
  assign o_rwds_smp = reg_rwds_smp;

  // ---------------------------------------------------------------------------------------------
  // Power good synchronizer
  // ---------------------------------------------------------------------------------------------

  // Library synchronizer cell wrapper (CDC-002): the output is low during reset.
  m_vlsit_afifo_cell_sync #(
    .PARA_AFIFO_CELL_RST_VAL (32'd0),
    .PARA_AFIFO_CELL_TYPE    (LPARA_CAP_SYNC)
  ) u_vlsit_afifo_cell_sync (
    .i_clk_dst   (i_clk_core),
    .i_rst_n_dst (i_rst_n_core),
    .i_d         (i_mem_pwr_good),
    .o_q         (w_pwr_good_s)
  );

  // Synchronized power good toward the controller.
  assign o_pwr_good = w_pwr_good_s;

  // ---------------------------------------------------------------------------------------------
  // Read capture (CDC-003)
  // ---------------------------------------------------------------------------------------------

  // First beat of a pair: captured at the rising edge of the capture clock.
  always_ff @(posedge i_clk_cap) begin : p_ff_cap_a
    reg_cap_a <= i_hb_dq;
  end

  // Inverted capture clock for the write side of the FIFO: the pair is complete at the falling
  // edge of the capture clock, where the second beat is on the pins.
  m_vlsit_clk_inv u_vlsit_clk_inv (
    .i_clk_in (i_clk_cap),
    .o_clk_n  (w_clk_cap_n)
  );

  // Ring write data: second beat on the pins, first beat from its register.
  assign w_cap_wr_data   = {i_hb_dq, reg_cap_a};

  // Capture ring: four pairs, write side on the capture clock, read side on the core clock. Both
  // sides are reset by the core reset only, which is released while the capture clock is quiet.
  // The overrun flag is not used here (the controller reads faster than the device writes).
  m_vlsit_cap_ring #(
    .PARA_CAP_DATA_W (LPARA_UNIT_W)
  ) u_vlsit_cap_ring (
    .i_clk_wr   (w_clk_cap_n),
    .i_rst_n_wr (i_rst_n_core),
    .i_wr_data  (w_cap_wr_data),
    .i_clk_rd   (i_clk_core),
    .i_rst_n_rd (i_rst_n_core),
    .i_rd_en    (i_cap_pop),
    .i_flush    (i_cap_flush),
    .o_rd_data  (o_cap_data),
    .o_empty    (o_cap_empty),
    .o_overrun  ()
  );

endmodule
