/*
 * Project      : HyperRAM Controller
 * Author       : Nguyen Quan (user)
 * AI Flow      : VLSIT RTL Generator AI Automation Flow
 * AI Flow Page : https://github.com/nguyenquanicd/VLSIT_RTL_Generator_AI_Model
 * Date         : 2026-10-31
 * Description  : HyperBus controller. It sequences the start-up (RESET# low wait, the waits after
 *                the release, CR0 and CR1 writes and the ID0 read of every chip select), the memory
 *                transactions of the segments that m_vlsit_axi4_frontend hands over, the device
 *                register commands of the CSR command port, the timeout detection with hold or
 *                re-initialization, and the loss of power good. Time is counted in CK periods: all
 *                state moves at the tick o_ck_tick of m_vlsit_hyperbus_phy (answer 1A). Every tick
 *                the controller issues one pin command for the next CK period: CS# low with CK off
 *                (t_css periods), the command and address phase (3 periods), the latency, the data
 *                units and one period with CS# high. The gap between transactions of one chip
 *                select is max(t_cshi, t_rwr - 2 - t_css); a transaction never keeps CS# low longer
 *                than t_csm periods: a longer segment continues in the next transaction (DEC-046).
 *                A following segment of the same direction and chip select at the next linear
 *                address is merged when it is at the head of the queue 2 periods before the data
 *                phase ends (answer 2A). Read data are taken from the capture FIFO of the PHY,
 *                which is emptied by reading 2 periods before the first data (DEC-040). Reads and
 *                writes are arbitrated by hr_ctrl.arb_mode with a bound of 8 segments in a row. A
 *                timeout (hr_dN_tmo.t_tmo) or the loss of power good aborts the open AXI requests.
 *                Assumptions: the data of a register write are repeated in the second beat of the
 *                unit; a register read uses the first word of the first unit; an unlisted wrapped
 *                segment is not split by t_csm.
 */
`timescale 1ns/1ps

module m_vlsit_hyperbus_ctrl #(
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
  // Parameter Description: byte capacity of one chip select, used for the byte address of the
  // timeout log.
  // Parameter values: 1024 to 33554432; default is 33554432.
  // Parameter unit: byte
  parameter logic [31:0] PARA_MEM_SIZE_BYTES = 32'd33554432,
  localparam logic [31:0] LPARA_RWDS_W     = PARA_MEM_DQ_W / 32'd8,
  localparam logic [31:0] LPARA_UNIT_W     = PARA_MEM_DQ_W * 32'd2,
  localparam logic [31:0] LPARA_UNIT_B     = PARA_MEM_DQ_W / 32'd4,
  localparam logic [31:0] LPARA_WORDS_UNIT = LPARA_UNIT_B / 32'd2,
  localparam logic [31:0] LPARA_UNITS_W    = 32'd12,
  localparam logic [31:0] LPARA_TWO_CS     = 32'd2,
  localparam logic [31:0] LPARA_ARB_RD     = 32'd1,
  localparam logic [31:0] LPARA_ARB_WR     = 32'd2,
  localparam logic [31:0] LPARA_ARB_BOUND  = 32'd8,
  localparam logic [31:0] LPARA_CSM_MAX    = 32'd800,
  localparam logic [31:0] LPARA_LAT_MIN    = 32'd3,
  localparam logic [31:0] LPARA_LAT_MAX    = 32'd8,
  localparam logic [31:0] LPARA_LAT_3      = 32'd3,
  localparam logic [31:0] LPARA_LAT_4      = 32'd4,
  localparam logic [31:0] LPARA_LAT_5      = 32'd5,
  localparam logic [31:0] LPARA_LAT_6      = 32'd6,
  localparam logic [31:0] LPARA_LAT_8      = 32'd8,
  localparam logic [31:0] LPARA_GAP_START  = 32'd2,
  localparam logic [31:0] LPARA_TMO_MIN    = 32'd16,
  localparam logic [31:0] LPARA_CR0_ADDR   = 32'h0000_0800,
  localparam logic [31:0] LPARA_CR1_ADDR   = 32'h0000_0801,
  localparam logic [31:0] LPARA_KIND_MRD   = 32'd0,
  localparam logic [31:0] LPARA_KIND_MWR   = 32'd1,
  localparam logic [31:0] LPARA_KIND_RRD   = 32'd2,
  localparam logic [31:0] LPARA_KIND_RWR   = 32'd3,
  localparam logic [31:0] LPARA_CMD_INIT_W = 32'd1,
  localparam logic [31:0] LPARA_CMD_INIT_R = 32'd2,
  localparam logic [31:0] LPARA_CMD_MEM_R  = 32'd3,
  localparam logic [31:0] LPARA_CMD_MEM_W  = 32'd4,
  localparam logic [31:0] LPARA_CMD_REG_R  = 32'd5,
  localparam logic [31:0] LPARA_CMD_REG_W  = 32'd6,
  localparam logic [31:0] LPARA_WAIT_FIRST = 32'd2,
  localparam logic [31:0] LPARA_WAIT_NXT  = 32'd3,
  localparam logic [31:0] LPARA_WAIT_FIFO  = 32'd4,
  localparam logic [31:0] LPARA_OP_CR0     = 32'd0,
  localparam logic [31:0] LPARA_OP_CR1     = 32'd1,
  localparam logic [31:0] LPARA_OP_ID0     = 32'd2,
  localparam logic [31:0] LPARA_SRC_NONE   = 32'd0,
  localparam logic [31:0] LPARA_SRC_CONT   = 32'd1,
  localparam logic [31:0] LPARA_SRC_INIT   = 32'd2,
  localparam logic [31:0] LPARA_SRC_CMD    = 32'd3,
  localparam logic [31:0] LPARA_SRC_RD     = 32'd4,
  localparam logic [31:0] LPARA_SRC_WR     = 32'd5
) (
  // Clock and reset
  input  wire                       i_clk_core,
  input  wire                       i_rst_n_core,

  // Control and status of the register file
  input  wire                       i_en,
  input  wire  [1:0]                i_arb_mode,
  input  wire                       i_merge_en,
  input  wire                       i_tmo_act,
  input  wire                       i_resume,
  input  wire  [7:0]                i_ck_div,
  input  wire                       i_ck_diff,
  input  wire                       i_cmd_go,
  input  wire                       i_cmd_wr,
  input  wire                       i_cmd_cs,
  input  wire  [31:0]               i_cmd_addr,
  input  wire  [15:0]               i_cmd_wdata,
  input  wire                       i_tmo_log_valid,
  output logic                      o_init_busy,
  output logic                      o_init_done,
  output logic                      o_idle,
  output logic                      o_cfg_valid,
  output logic                      o_memrst_n,
  output logic                      o_hold,
  output logic                      o_cmd_busy,

  // Events and hardware writes toward the register file (one-cycle pulses)
  output logic                      o_evt_init_ok,
  output logic                      o_evt_cfg_err,
  output logic                      o_evt_pwr_lost,
  output logic                      o_evt_id_mis,
  output logic                      o_evt_lat_mis,
  output logic                      o_evt_cmd_done,
  output logic                      o_evt_tmo,
  output logic                      o_cmd_go_clr,
  output logic                      o_cmd_done_set,
  output logic                      o_cmd_err_set,
  output logic                      o_resume_clr,
  output logic                      o_tmo_log_set,
  output logic [15:0]               o_cmd_rdata,
  output logic                      o_tmo_log_cs,
  output logic                      o_tmo_log_wr,
  output logic [12:0]               o_tmo_log_beats,
  output logic [3:0]                o_tmo_log_cmd,
  output logic [3:0]                o_tmo_log_wait,
  output logic [31:0]               o_tmo_addr,

  // Configuration of chip select 0
  input  wire  [4:0]                i_d0_init_lat,
  input  wire                       i_d0_fixed_lat,
  input  wire  [2:0]                i_d0_drive,
  input  wire                       i_d0_hybrid,
  input  wire  [1:0]                i_d0_blen,
  input  wire  [2:0]                i_d0_pasr,
  input  wire  [15:0]               i_d0_t_rh,
  input  wire  [15:0]               i_d0_t_rp,
  input  wire  [15:0]               i_d0_t_rph,
  input  wire  [15:0]               i_d0_t_vcs,
  input  wire  [7:0]                i_d0_t_css,
  input  wire  [7:0]                i_d0_t_rwr,
  input  wire  [7:0]                i_d0_t_cshi,
  input  wire  [15:0]               i_d0_t_csm,
  input  wire  [7:0]                i_d0_tap,
  input  wire                       i_d0_id_chk_en,
  input  wire  [15:0]               i_d0_id0_exp,
  input  wire  [15:0]               i_d0_t_tmo,
  output logic [15:0]               o_d0_id0_act,

  // Configuration of chip select 1
  input  wire  [4:0]                i_d1_init_lat,
  input  wire                       i_d1_fixed_lat,
  input  wire  [2:0]                i_d1_drive,
  input  wire                       i_d1_hybrid,
  input  wire  [1:0]                i_d1_blen,
  input  wire  [2:0]                i_d1_pasr,
  input  wire  [15:0]               i_d1_t_rh,
  input  wire  [15:0]               i_d1_t_rp,
  input  wire  [15:0]               i_d1_t_rph,
  input  wire  [15:0]               i_d1_t_vcs,
  input  wire  [7:0]                i_d1_t_css,
  input  wire  [7:0]                i_d1_t_rwr,
  input  wire  [7:0]                i_d1_t_cshi,
  input  wire  [15:0]               i_d1_t_csm,
  input  wire  [7:0]                i_d1_tap,
  input  wire                       i_d1_id_chk_en,
  input  wire  [15:0]               i_d1_id0_exp,
  input  wire  [15:0]               i_d1_t_tmo,
  output logic [15:0]               o_d1_id0_act,

  // Frontend
  output logic                      o_accept_en,
  output logic                      o_abort,
  input  wire                       i_fe_idle,
  input  wire                       i_rd_seg_valid,
  output logic                      o_rd_seg_ready,
  input  wire                       i_rd_seg_cs,
  input  wire  [31:0]               i_rd_seg_addr,
  input  wire  [LPARA_UNITS_W-1:0]  i_rd_seg_units,
  input  wire                       i_rd_seg_wrap,
  output logic                      o_rd_data_valid,
  output logic [LPARA_UNIT_W-1:0]   o_rd_data,
  input  wire                       i_wr_seg_valid,
  output logic                      o_wr_seg_ready,
  input  wire                       i_wr_seg_cs,
  input  wire  [31:0]               i_wr_seg_addr,
  input  wire  [LPARA_UNITS_W-1:0]  i_wr_seg_units,
  input  wire                       i_wr_seg_wrap,
  input  wire  [LPARA_UNIT_W-1:0]   i_wr_data,
  input  wire  [LPARA_UNIT_B-1:0]   i_wr_mask,
  output logic                      o_wr_data_pop,
  output logic                      o_wr_seg_done,

  // PHY
  input  wire                       i_ck_tick,
  output logic [PARA_NUM_CS-1:0]    o_cmd_cs_n,
  output logic                      o_cmd_ck_run,
  output logic [LPARA_UNIT_W-1:0]   o_cmd_dq,
  output logic                      o_cmd_dq_oe,
  output logic [LPARA_UNIT_B-1:0]   o_cmd_rwds,
  output logic                      o_cmd_rwds_oe,
  output logic                      o_cmd_mem_rel,
  output logic [PARA_DLY_TAP_W-1:0] o_dly_sel,
  input  wire  [LPARA_RWDS_W-1:0]   i_rwds_smp,
  input  wire                       i_pwr_good,
  output logic                      o_cap_pop,
  output logic                      o_cap_flush,
  input  wire  [LPARA_UNIT_W-1:0]   i_cap_data,
  input  wire                       i_cap_empty
);

  // ---------------------------------------------------------------------------------------------
  // Internal signal declarations
  // ---------------------------------------------------------------------------------------------

  // Mode FSM: power, enable, start-up, ready, stop, hold and blocked after a power loss.
  typedef enum logic [3:0] {
    ENUM_ST_MODE_OFF   = 4'd0,
    ENUM_ST_MODE_RST   = 4'd1,
    ENUM_ST_MODE_WRH   = 4'd2,
    ENUM_ST_MODE_WPH   = 4'd3,
    ENUM_ST_MODE_WVCS  = 4'd4,
    ENUM_ST_MODE_INIT  = 4'd5,
    ENUM_ST_MODE_READY = 4'd6,
    ENUM_ST_MODE_STOP  = 4'd7,
    ENUM_ST_MODE_HOLD  = 4'd8,
    ENUM_ST_MODE_BLOCK = 4'd9
  } mode_state_type_def;

  // Transaction FSM: one state per CK period of the pins.
  typedef enum logic [2:0] {
    ENUM_ST_TX_IDLE = 3'd0,
    ENUM_ST_TX_CSS  = 3'd1,
    ENUM_ST_TX_CA0  = 3'd2,
    ENUM_ST_TX_CA1  = 3'd3,
    ENUM_ST_TX_CA2  = 3'd4,
    ENUM_ST_TX_LAT  = 3'd5,
    ENUM_ST_TX_DATA = 3'd6,
    ENUM_ST_TX_END  = 3'd7
  } tx_state_type_def;

  mode_state_type_def         reg_fsm_mode_current_state;
  mode_state_type_def         w_fsm_mode_nxt_state;
  tx_state_type_def           reg_fsm_tx_current_state;
  tx_state_type_def           w_fsm_tx_nxt_state;

  // Selected configuration of the chip select of the current transaction.
  logic                       w_c_fixed_lat;
  logic [4:0]                 w_c_init_lat;
  logic [15:0]                w_c_t_csm;
  logic [7:0]                 w_c_t_css;
  logic [7:0]                 w_c_t_rwr;
  logic [7:0]                 w_c_t_cshi;
  logic [7:0]                 w_c_tap;
  logic                       w_c_id_chk_en;
  logic [15:0]                w_c_id0_exp;
  logic [15:0]                w_c_t_tmo;
  logic [15:0]                w_trp;
  logic [15:0]                w_trh;
  logic [15:0]                w_trph;
  logic [15:0]                w_tvcs;
  logic                       w_cs0_valid;
  logic                       w_cs1_valid;
  logic                       w_cfg_valid;
  logic [8:0]                 w_gap_load;
  logic                       w_gap_ok_cs0;
  logic                       w_gap_ok_cs1;
  logic [8:0]                 reg_gap_cnt_0;
  logic [8:0]                 reg_gap_cnt_1;

  // Mode registers.
  logic [15:0]                reg_wait_cnt;
  logic [1:0]                 reg_init_idx;
  logic [1:0]                 reg_init_op;
  logic                       reg_init_done;
  logic                       reg_reinit;
  logic                       reg_en_prev;
  logic                       w_start_up;
  logic                       w_kill;
  logic                       w_tmo_hit;
  logic                       w_pwr_loss;
  logic                       w_cmd_reject;
  logic                       w_op_done;
  logic                       w_mode_ok_seg;
  logic                       w_stop_done;
  logic                       w_cmd_ok;
  logic                       w_cmd_cs;
  logic [2:0]                 w_i_drive;
  logic                       w_i_hybrid;
  logic [1:0]                 w_i_blen;
  logic [2:0]                 w_i_pasr;
  logic                       w_i_fixed;
  logic [4:0]                 w_i_init_lat;
  logic [7:0]                 w_p_t_css;
  logic [8:0]                 w_css;

  // Transaction registers.
  logic [1:0]                 reg_kind;
  logic                       reg_cs;
  logic [31:0]                reg_waddr;
  logic [LPARA_UNITS_W-1:0]   reg_units_left;
  logic                       reg_wrap;
  logic [9:0]                 reg_cnt;
  logic [9:0]                 reg_dmax;
  logic [9:0]                 reg_dcap;
  logic [15:0]                reg_wdata;
  logic                       reg_isinit;
  logic                       reg_iscmd;
  logic                       reg_op_active;
  logic                       reg_cmd_hold;
  logic [9:0]                 reg_segs;
  logic                       reg_last_dir;
  logic [3:0]                 reg_consec;
  logic [31:0]                reg_start_waddr;

  // Pick of the next transaction.
  logic                       w_pick_valid;
  logic [31:0]                w_pick_src;
  logic [1:0]                 w_pick_kind;
  logic                       w_pick_cs;
  logic [31:0]                w_pick_waddr;
  logic [LPARA_UNITS_W-1:0]   w_pick_units;
  logic                       w_pick_wrap;
  logic [15:0]                w_pick_wdata;
  logic                       w_rd_av;
  logic                       w_wr_av;
  logic                       w_pick_rd;
  logic                       w_start;
  logic                       w_take_rd;
  logic                       w_take_wr;
  logic                       w_merge_ok;
  logic                       w_merge_rd;
  logic                       w_merge_wr;
  logic [LPARA_UNITS_W-1:0]   w_merge_units;
  logic [9:0]                 w_merge_add;
  logic [31:0]                w_nxt_baddr;

  // Command generation.
  logic [47:0]                w_ca;
  logic [7:0]                 w_ca_a;
  logic [7:0]                 w_ca_b;
  logic [LPARA_UNIT_W-1:0]    w_ca_unit;
  logic [LPARA_UNIT_W-1:0]    w_regw_unit;
  logic [5:0]                 w_lat_nxt;
  logic [16:0]                w_dmax_nxt;
  logic [9:0]                 w_d;
  logic                       w_kind_wr;
  logic                       w_kind_rd;
  logic [PARA_NUM_CS-1:0]     w_cmd_cs_n_nxt;
  logic                       w_cmd_ck_run_nxt;
  logic [LPARA_UNIT_W-1:0]    w_cmd_dq_nxt;
  logic                       w_cmd_dq_oe_nxt;
  logic [LPARA_UNIT_B-1:0]    w_cmd_rwds_nxt;
  logic                       w_cmd_rwds_oe_nxt;
  logic                       w_data_tick;
  logic                       reg_mem_rel;

  // Read capture and timeouts.
  logic                       w_drain;
  logic                       w_pop_data;
  logic [LPARA_UNITS_W-1:0]   reg_rx_left;
  logic                       reg_got;
  logic                       reg_got_any;
  logic [12:0]                reg_got_words;
  logic [15:0]                reg_tmo_cnt;
  logic                       reg_rdv;
  logic [LPARA_UNIT_W-1:0]    reg_rdd;
  logic [15:0]                w_word_in;
  logic [15:0]                reg_cmd_rdata;
  logic [15:0]                reg_id0_act_0;
  logic [15:0]                reg_id0_act_1;
  logic [9:0]                 reg_done_cnt;

  // Events, log and handshakes (registered pulses).
  logic                       reg_evt_init_ok;
  logic                       reg_evt_cfg_err;
  logic                       reg_evt_pwr_lost;
  logic                       reg_evt_id_mis;
  logic                       reg_evt_lat_mis;
  logic                       reg_evt_cmd_done;
  logic                       reg_evt_tmo;
  logic                       reg_abort;
  logic                       reg_cmd_go_clr;
  logic                       reg_cmd_done_set;
  logic                       reg_cmd_err_set;
  logic                       reg_resume_clr;
  logic                       reg_tmo_log_set;
  logic                       reg_log_cs;
  logic                       reg_log_wr;
  logic [12:0]                reg_log_beats;
  logic [3:0]                 reg_log_cmd;
  logic [3:0]                 reg_log_wait;
  logic [31:0]                reg_log_addr;
  logic [3:0]                 w_cmd_code;
  logic [3:0]                 w_wait_code;
  logic [31:0]                w_log_baddr;

  // Registered pin commands toward the PHY.
  logic [PARA_NUM_CS-1:0]     reg_cs_n;
  logic                       reg_ck_run;
  logic [LPARA_UNIT_W-1:0]    reg_dq;
  logic                       reg_dq_oe;
  logic [LPARA_UNIT_B-1:0]    reg_rwds;
  logic                       reg_rwds_oe;
  logic [PARA_DLY_TAP_W-1:0]  reg_dly_sel;

  // ---------------------------------------------------------------------------------------------
  // Functions
  // ---------------------------------------------------------------------------------------------

  // f_lat_code: CR0[7:4] code of an initial latency of 3 to 8 CK periods (REF-006 Table 9).
  function automatic logic [3:0] f_lat_code(input logic [4:0] a_lat);
    case (32'(a_lat))
      LPARA_LAT_3: begin
        f_lat_code = 4'b1110;
      end
      LPARA_LAT_4: begin
        f_lat_code = 4'b1111;
      end
      LPARA_LAT_5: begin
        f_lat_code = 4'b0000;
      end
      LPARA_LAT_6: begin
        f_lat_code = 4'b0001;
      end
      LPARA_LAT_8: begin
        f_lat_code = 4'b0011;
      end
      default: begin
        f_lat_code = 4'b0010;
      end
    endcase
  endfunction

  // f_cr0: CR0 of the device from the configuration fields (REQ-MEM-006).
  function automatic logic [15:0] f_cr0(input logic [2:0] a_drive, input logic [3:0] a_code,
                                        input logic a_fixed, input logic a_hybrid,
                                        input logic [1:0] a_blen);
    f_cr0 = {1'b1, a_drive, 4'b1111, a_code, a_fixed, a_hybrid, a_blen};
  endfunction

  // f_cr1: CR1 of the device: CK# type from the clock register and the refresh array size.
  function automatic logic [15:0] f_cr1(input logic a_diff, input logic [2:0] a_pasr);
    f_cr1 = {8'hFF, 1'b1, ~a_diff, 1'b0, a_pasr, 2'b00};
  endfunction

  // f_cs_valid: legal range of the fields of one chip select (REQ-MEM-005).
  function automatic logic f_cs_valid(input logic [4:0] a_lat, input logic [15:0] a_t_rh,
                                      input logic [15:0] a_t_rp, input logic [15:0] a_t_rph,
                                      input logic [15:0] a_t_vcs, input logic [7:0] a_t_cshi,
                                      input logic [15:0] a_t_csm, input logic [15:0] a_t_tmo);
    f_cs_valid = (32'(a_lat) >= LPARA_LAT_MIN) && (32'(a_lat) <= LPARA_LAT_MAX) &&
                 (a_t_rh != 16'd0) && (a_t_rp != 16'd0) && (a_t_rph != 16'd0) &&
                 (a_t_vcs != 16'd0) && (a_t_cshi != 8'd0) && (a_t_csm != 16'd0) &&
                 (32'(a_t_csm) <= LPARA_CSM_MAX) &&
                 !((a_t_tmo != 16'd0) && (32'(a_t_tmo) < LPARA_TMO_MIN));
  endfunction

  // f_gap: CS# high periods between two transactions of one chip select: the larger of t_cshi and
  // t_rwr minus the two periods of CA0 and CA1 and minus the t_css periods that follow
  // (REQ-MEM-004).
  function automatic logic [8:0] f_gap(input logic [7:0] a_t_cshi, input logic [7:0] a_t_rwr,
                                       input logic [7:0] a_t_css);
    logic [8:0] css;
    logic [8:0] rwr;
    css = (a_t_css == 8'd0) ? 9'd1 : {1'b0, a_t_css};
    rwr = 9'd0;
    if ({1'b0, a_t_rwr} > (css + 9'd2)) begin
      rwr = {1'b0, a_t_rwr} - css - 9'd2;
    end
    f_gap = {1'b0, a_t_cshi};
    if (rwr > f_gap)
      f_gap = rwr;
    if (f_gap == 9'd0)
      f_gap = 9'd1;
  endfunction

  // ---------------------------------------------------------------------------------------------
  // Configuration of the chip selects
  // ---------------------------------------------------------------------------------------------

  // Configuration of the chip select of the current transaction.
  always_comb begin : p_com_cfg_sel
    w_c_fixed_lat = i_d0_fixed_lat;
    w_c_init_lat  = i_d0_init_lat;
    w_c_t_csm     = i_d0_t_csm;
    w_c_t_css     = i_d0_t_css;
    w_c_t_rwr     = i_d0_t_rwr;
    w_c_t_cshi    = i_d0_t_cshi;
    w_c_tap       = i_d0_tap;
    w_c_id_chk_en = i_d0_id_chk_en;
    w_c_id0_exp   = i_d0_id0_exp;
    w_c_t_tmo     = i_d0_t_tmo;
    if (reg_cs) begin
      w_c_fixed_lat = i_d1_fixed_lat;
      w_c_init_lat  = i_d1_init_lat;
      w_c_t_csm     = i_d1_t_csm;
      w_c_t_css     = i_d1_t_css;
      w_c_t_rwr     = i_d1_t_rwr;
      w_c_t_cshi    = i_d1_t_cshi;
      w_c_tap       = i_d1_tap;
      w_c_id_chk_en = i_d1_id_chk_en;
      w_c_id0_exp   = i_d1_id0_exp;
      w_c_t_tmo     = i_d1_t_tmo;
    end
  end

  // CS#-before-CK count of the chip select that is picked for the next transaction.
  always_comb begin : p_com_cfg_pick
    w_p_t_css = i_d0_t_css;
    if (w_pick_cs) begin
      w_p_t_css = i_d1_t_css;
    end
  end

  // Configuration of the chip select of the start-up step: the fields that build CR0 and CR1.
  always_comb begin : p_com_cfg_init
    w_i_drive    = i_d0_drive;
    w_i_hybrid   = i_d0_hybrid;
    w_i_blen     = i_d0_blen;
    w_i_pasr     = i_d0_pasr;
    w_i_fixed    = i_d0_fixed_lat;
    w_i_init_lat = i_d0_init_lat;
    if (reg_init_idx[0]) begin
      w_i_drive    = i_d1_drive;
      w_i_hybrid   = i_d1_hybrid;
      w_i_blen     = i_d1_blen;
      w_i_pasr     = i_d1_pasr;
      w_i_fixed    = i_d1_fixed_lat;
      w_i_init_lat = i_d1_init_lat;
    end
  end

  // The start-up waits of the shared RESET# use the larger value of the used chip selects.
  always_comb begin : p_com_wait_max
    w_trp  = i_d0_t_rp;
    w_trh  = i_d0_t_rh;
    w_trph = i_d0_t_rph;
    w_tvcs = i_d0_t_vcs;
    if (PARA_NUM_CS == LPARA_TWO_CS) begin
      if (i_d1_t_rp > i_d0_t_rp) begin
        w_trp = i_d1_t_rp;
      end
      if (i_d1_t_rh > i_d0_t_rh) begin
        w_trh = i_d1_t_rh;
      end
      if (i_d1_t_rph > i_d0_t_rph) begin
        w_trph = i_d1_t_rph;
      end
      if (i_d1_t_vcs > i_d0_t_vcs) begin
        w_tvcs = i_d1_t_vcs;
      end
    end
  end

  // Legality of every field (REQ-MEM-005): the CK divider must be even and at least 2.
  assign w_cs0_valid = f_cs_valid(i_d0_init_lat, i_d0_t_rh, i_d0_t_rp, i_d0_t_rph, i_d0_t_vcs,
                                  i_d0_t_cshi, i_d0_t_csm, i_d0_t_tmo);
  // Legality of chip select 1.
  assign w_cs1_valid = f_cs_valid(i_d1_init_lat, i_d1_t_rh, i_d1_t_rp, i_d1_t_rph, i_d1_t_vcs,
                                  i_d1_t_cshi, i_d1_t_csm, i_d1_t_tmo);
  // Legal configuration: CK divider and every used chip select.
  assign w_cfg_valid = ~i_ck_div[0] & (i_ck_div != 8'd0) & w_cs0_valid &
                       ((PARA_NUM_CS != LPARA_TWO_CS) | w_cs1_valid);
  // Configuration status toward the register file.
  assign o_cfg_valid = w_cfg_valid;

  // ---------------------------------------------------------------------------------------------
  // Kill conditions and mode FSM
  // ---------------------------------------------------------------------------------------------

  // A device timeout: data are expected, the wait exceeds hr_dN_tmo.t_tmo and the detector is on.
  assign w_tmo_hit = i_ck_tick & (reg_rx_left != '0) & (w_c_t_tmo != 16'd0) &
                     (reg_tmo_cnt >= w_c_t_tmo);

  // The synchronized power good fell while the memory was in use.
  assign w_pwr_loss = i_ck_tick & ~i_pwr_good &
                      (reg_fsm_mode_current_state != ENUM_ST_MODE_OFF) &
                      (reg_fsm_mode_current_state != ENUM_ST_MODE_BLOCK);

  // A transaction in progress is ended at once by a timeout, a power loss or a clear enable
  // during the start-up or the hold state.
  always_comb begin : p_com_kill
    w_kill = w_tmo_hit | w_pwr_loss;
    case (reg_fsm_mode_current_state)
      ENUM_ST_MODE_RST,
      ENUM_ST_MODE_WRH,
      ENUM_ST_MODE_WPH,
      ENUM_ST_MODE_WVCS,
      ENUM_ST_MODE_INIT,
      ENUM_ST_MODE_HOLD: begin
        w_kill = w_kill | ~i_en;
      end
      default: begin
        // No other mode ends a transaction by itself.
      end
    endcase
  end

  // Part 1, sequential: the current mode, moved at the tick only.
  always_ff @(posedge i_clk_core, negedge i_rst_n_core) begin : p_ff_fsm_mode
    if (!i_rst_n_core) begin
      reg_fsm_mode_current_state <= ENUM_ST_MODE_OFF;
    end else if (i_ck_tick) begin
      reg_fsm_mode_current_state <= w_fsm_mode_nxt_state;
    end
  end

  // Part 2, combinational: next mode. The sequence is OFF, RST (RESET# low for t_rp), WRH (t_rh),
  // WPH (t_rph), WVCS (t_vcs), INIT (CR0, CR1, ID0 of every chip select), READY. A timeout goes
  // to HOLD or, with hr_ctrl.tmo_act = 1 and no re-initialization running, back to RST.
  always_comb begin : p_com_fsm_mode
    w_fsm_mode_nxt_state = reg_fsm_mode_current_state;
    case (reg_fsm_mode_current_state)
      ENUM_ST_MODE_OFF: begin
        if (w_start_up) begin
          w_fsm_mode_nxt_state = ENUM_ST_MODE_RST;
        end
      end
      ENUM_ST_MODE_RST: begin
        if (!i_en) begin
          w_fsm_mode_nxt_state = ENUM_ST_MODE_OFF;
        end else if (reg_wait_cnt == 16'd0) begin
          w_fsm_mode_nxt_state = ENUM_ST_MODE_WRH;
        end
      end
      ENUM_ST_MODE_WRH: begin
        if (!i_en) begin
          w_fsm_mode_nxt_state = ENUM_ST_MODE_OFF;
        end else if (reg_wait_cnt == 16'd0) begin
          w_fsm_mode_nxt_state = ENUM_ST_MODE_WPH;
        end
      end
      ENUM_ST_MODE_WPH: begin
        if (!i_en) begin
          w_fsm_mode_nxt_state = ENUM_ST_MODE_OFF;
        end else if (reg_wait_cnt == 16'd0) begin
          w_fsm_mode_nxt_state = ENUM_ST_MODE_WVCS;
        end
      end
      ENUM_ST_MODE_WVCS: begin
        if (!i_en) begin
          w_fsm_mode_nxt_state = ENUM_ST_MODE_OFF;
        end else if (reg_wait_cnt == 16'd0) begin
          w_fsm_mode_nxt_state = ENUM_ST_MODE_INIT;
        end
      end
      ENUM_ST_MODE_INIT: begin
        if (!i_en) begin
          w_fsm_mode_nxt_state = ENUM_ST_MODE_OFF;
        end else if ((32'(reg_init_idx) >= PARA_NUM_CS) && !reg_op_active &&
                     (reg_fsm_tx_current_state == ENUM_ST_TX_IDLE)) begin
          w_fsm_mode_nxt_state = ENUM_ST_MODE_READY;
        end
      end
      ENUM_ST_MODE_READY: begin
        if (!i_en) begin
          w_fsm_mode_nxt_state = ENUM_ST_MODE_STOP;
        end
      end
      ENUM_ST_MODE_STOP: begin
        if (w_stop_done) begin
          w_fsm_mode_nxt_state = ENUM_ST_MODE_OFF;
        end
      end
      ENUM_ST_MODE_HOLD: begin
        if (!i_en) begin
          w_fsm_mode_nxt_state = ENUM_ST_MODE_OFF;
        end else if (i_resume) begin
          w_fsm_mode_nxt_state = ENUM_ST_MODE_READY;
        end
      end
      ENUM_ST_MODE_BLOCK: begin
        if (!i_en) begin
          w_fsm_mode_nxt_state = ENUM_ST_MODE_OFF;
        end
      end
      default: begin
        w_fsm_mode_nxt_state = ENUM_ST_MODE_OFF;
      end
    endcase
    if (w_pwr_loss) begin
      w_fsm_mode_nxt_state = ENUM_ST_MODE_BLOCK;
    end else if (w_tmo_hit && ((reg_fsm_mode_current_state == ENUM_ST_MODE_INIT) ||
                               (reg_fsm_mode_current_state == ENUM_ST_MODE_READY) ||
                               (reg_fsm_mode_current_state == ENUM_ST_MODE_HOLD))) begin
      if (reg_reinit || !i_tmo_act) begin
        w_fsm_mode_nxt_state = ENUM_ST_MODE_HOLD;
      end else begin
        w_fsm_mode_nxt_state = ENUM_ST_MODE_RST;
      end
    end
  end

  // Start of the sequence: enabled, legal fields and power good.
  assign w_start_up = i_en & w_cfg_valid & i_pwr_good;

  // The STOP mode ends when all accepted work is done and the pins are idle.
  assign w_stop_done = i_fe_idle & (reg_fsm_tx_current_state == ENUM_ST_TX_IDLE) &
                       ~reg_op_active & (reg_rx_left == '0) & (reg_done_cnt == '0);

  // Mode registers: wait counter in CK periods, initialization progress and flags.
  always_ff @(posedge i_clk_core, negedge i_rst_n_core) begin : p_ff_mode_dp
    if (!i_rst_n_core) begin
      reg_wait_cnt  <= 16'd0;
      reg_init_idx  <= 2'd0;
      reg_init_op   <= 2'd0;
      reg_init_done <= 1'b0;
      reg_reinit    <= 1'b0;
      reg_en_prev   <= 1'b0;
    end else begin
      reg_en_prev <= i_en;
      // Initialization steps advance when the operation of the step is done.
      if (w_op_done && reg_isinit) begin
        if (32'(reg_init_op) == LPARA_OP_ID0) begin
          reg_init_op  <= 2'(LPARA_OP_CR0);
          reg_init_idx <= reg_init_idx + 2'd1;
        end else begin
          reg_init_op <= reg_init_op + 2'd1;
        end
      end
      if (i_ck_tick) begin
        // Wait counters: loaded with the next wait when a wait ends.
        case (reg_fsm_mode_current_state)
          ENUM_ST_MODE_RST: begin
            reg_wait_cnt <= (reg_wait_cnt == 16'd0) ? (w_trh - 16'd1) : (reg_wait_cnt - 16'd1);
          end
          ENUM_ST_MODE_WRH: begin
            reg_wait_cnt <= (reg_wait_cnt == 16'd0) ? (w_trph - 16'd1) : (reg_wait_cnt - 16'd1);
          end
          ENUM_ST_MODE_WPH: begin
            reg_wait_cnt <= (reg_wait_cnt == 16'd0) ? (w_tvcs - 16'd1) : (reg_wait_cnt - 16'd1);
          end
          ENUM_ST_MODE_WVCS: begin
            reg_wait_cnt <= (reg_wait_cnt == 16'd0) ? 16'd0 : (reg_wait_cnt - 16'd1);
            reg_init_idx <= 2'd0;
            reg_init_op  <= 2'(LPARA_OP_CR0);
          end
          default: begin
            reg_wait_cnt <= w_trp - 16'd1;
          end
        endcase
        // Flags that follow the mode change.
        case (w_fsm_mode_nxt_state)
          ENUM_ST_MODE_READY: begin
            reg_init_done <= 1'b1;
            reg_reinit    <= 1'b0;
          end
          ENUM_ST_MODE_HOLD,
          ENUM_ST_MODE_STOP: begin
            // The initialization state is kept.
          end
          ENUM_ST_MODE_INIT,
          ENUM_ST_MODE_WRH,
          ENUM_ST_MODE_WPH,
          ENUM_ST_MODE_WVCS: begin
            // Start-up under way.
          end
          ENUM_ST_MODE_RST: begin
            reg_init_done <= 1'b0;
            reg_reinit    <= (reg_fsm_mode_current_state != ENUM_ST_MODE_OFF);
          end
          default: begin
            reg_init_done <= 1'b0;
            reg_reinit    <= 1'b0;
          end
        endcase
      end
    end
  end

  // Status and control toward the register file and the frontend.
  assign o_init_busy = (reg_fsm_mode_current_state == ENUM_ST_MODE_RST) |
                       (reg_fsm_mode_current_state == ENUM_ST_MODE_WRH) |
                       (reg_fsm_mode_current_state == ENUM_ST_MODE_WPH) |
                       (reg_fsm_mode_current_state == ENUM_ST_MODE_WVCS) |
                       (reg_fsm_mode_current_state == ENUM_ST_MODE_INIT);
  // Initialization done flag.
  assign o_init_done = reg_init_done;
  assign o_hold      = (reg_fsm_mode_current_state == ENUM_ST_MODE_HOLD);
  assign o_cmd_busy  = i_cmd_go | (reg_op_active & reg_iscmd);
  assign o_idle      = reg_init_done & i_fe_idle & (reg_fsm_tx_current_state == ENUM_ST_TX_IDLE) &
                       ~reg_op_active & (reg_rx_left == '0) & (reg_done_cnt == '0);
  // Requests are accepted in READY while no device command is pending.
  assign o_accept_en = (reg_fsm_mode_current_state == ENUM_ST_MODE_READY) & ~i_cmd_go &
                       ~(reg_op_active & reg_iscmd);

  // RESET# release request toward the PHY: low in OFF, in the t_rp wait and after a power loss.
  always_ff @(posedge i_clk_core, negedge i_rst_n_core) begin : p_ff_mem_rel
    if (!i_rst_n_core) begin
      reg_mem_rel <= 1'b0;
    end else begin
      case (reg_fsm_mode_current_state)
        ENUM_ST_MODE_WRH,
        ENUM_ST_MODE_WPH,
        ENUM_ST_MODE_WVCS,
        ENUM_ST_MODE_INIT,
        ENUM_ST_MODE_READY,
        ENUM_ST_MODE_STOP,
        ENUM_ST_MODE_HOLD: begin
          reg_mem_rel <= 1'b1;
        end
        default: begin
          reg_mem_rel <= 1'b0;
        end
      endcase
    end
  end

  // RESET# request toward the PHY and its level toward the register file.
  assign o_cmd_mem_rel = reg_mem_rel;
  assign o_memrst_n    = reg_mem_rel;

  // ---------------------------------------------------------------------------------------------
  // Pick of the next transaction
  // ---------------------------------------------------------------------------------------------

  // The memory segments are served in READY and, to finish the accepted work, in STOP.
  assign w_mode_ok_seg = ((reg_fsm_mode_current_state == ENUM_ST_MODE_READY) |
                          (reg_fsm_mode_current_state == ENUM_ST_MODE_STOP)) & ~i_cmd_go &
                         ~(reg_op_active & reg_iscmd);

  // A device command is taken in READY and HOLD after the initialization, and rejected before.
  assign w_cmd_ok     = i_cmd_go & ~reg_cmd_hold & ~reg_op_active & reg_init_done &
                        ((reg_fsm_mode_current_state == ENUM_ST_MODE_READY) |
                         (reg_fsm_mode_current_state == ENUM_ST_MODE_HOLD));
  // A command before the initialization is rejected.
  assign w_cmd_reject = i_ck_tick & i_cmd_go & ~reg_cmd_hold & ~reg_op_active & ~reg_init_done &
                        (reg_fsm_tx_current_state == ENUM_ST_TX_IDLE);
  // Chip select of the command, forced to 0 with one chip select.
  assign w_cmd_cs     = i_cmd_cs & (PARA_NUM_CS == LPARA_TWO_CS);

  // Gap check of the chip select of every candidate.
  assign w_gap_ok_cs0 = (32'(reg_gap_cnt_0) <= LPARA_GAP_START);
  assign w_gap_ok_cs1 = (32'(reg_gap_cnt_1) <= LPARA_GAP_START);
  assign w_rd_av = i_rd_seg_valid & w_mode_ok_seg & (i_rd_seg_cs ? w_gap_ok_cs1 : w_gap_ok_cs0);
  assign w_wr_av = i_wr_seg_valid & w_mode_ok_seg & (i_wr_seg_cs ? w_gap_ok_cs1 : w_gap_ok_cs0);

  // Arbitration between a waiting read and a waiting write (hr_ctrl.arb_mode, ASM-003): round
  // robin alternates; a priority mode serves its direction until the bound is reached.
  always_comb begin : p_com_arb
    w_pick_rd = w_rd_av;
    if (w_rd_av && w_wr_av) begin
      case (32'(i_arb_mode))
        LPARA_ARB_RD: begin
          w_pick_rd = !((reg_last_dir == 1'b0) && (32'(reg_consec) >= LPARA_ARB_BOUND));
        end
        LPARA_ARB_WR: begin
          w_pick_rd = (reg_last_dir == 1'b1) && (32'(reg_consec) >= LPARA_ARB_BOUND);
        end
        default: begin
          w_pick_rd = (reg_last_dir == 1'b1);
        end
      endcase
    end
  end

  // Candidate selection. A continued segment first, then the start-up operations, then a device
  // command, then the memory segments.
  always_comb begin : p_com_pick
    w_pick_valid = 1'b0;
    w_pick_src   = LPARA_SRC_NONE;
    w_pick_kind  = 2'(LPARA_KIND_MRD);
    w_pick_cs    = 1'b0;
    w_pick_waddr = 32'd0;
    w_pick_units = '0;
    w_pick_wrap  = 1'b0;
    w_pick_wdata = 16'd0;
    casez ({(reg_units_left != '0),
            ((reg_fsm_mode_current_state == ENUM_ST_MODE_INIT) &&
             (32'(reg_init_idx) < PARA_NUM_CS) && !reg_op_active),
            w_cmd_ok,
            (w_rd_av && w_pick_rd),
            w_wr_av})
      5'b1????: begin
        w_pick_valid = reg_cs ? w_gap_ok_cs1 : w_gap_ok_cs0;
        w_pick_src   = LPARA_SRC_CONT;
        w_pick_kind  = reg_kind;
        w_pick_cs    = reg_cs;
        w_pick_waddr = reg_waddr;
        w_pick_units = reg_units_left;
      end
      5'b01???: begin
        w_pick_cs    = reg_init_idx[0];
        w_pick_valid = reg_init_idx[0] ? w_gap_ok_cs1 : w_gap_ok_cs0;
        w_pick_src   = LPARA_SRC_INIT;
        w_pick_units = 12'd1;
        case (32'(reg_init_op))
          LPARA_OP_CR0: begin
            w_pick_kind  = 2'(LPARA_KIND_RWR);
            w_pick_waddr = LPARA_CR0_ADDR;
            w_pick_wdata = f_cr0(w_i_drive, f_lat_code(w_i_init_lat), w_i_fixed, w_i_hybrid,
                                 w_i_blen);
          end
          LPARA_OP_CR1: begin
            w_pick_kind  = 2'(LPARA_KIND_RWR);
            w_pick_waddr = LPARA_CR1_ADDR;
            w_pick_wdata = f_cr1(i_ck_diff, w_i_pasr);
          end
          default: begin
            w_pick_kind  = 2'(LPARA_KIND_RRD);
            w_pick_waddr = 32'd0;
          end
        endcase
      end
      5'b001??: begin
        w_pick_cs    = w_cmd_cs;
        w_pick_valid = w_cmd_cs ? w_gap_ok_cs1 : w_gap_ok_cs0;
        w_pick_src   = LPARA_SRC_CMD;
        w_pick_kind  = i_cmd_wr ? 2'(LPARA_KIND_RWR) : 2'(LPARA_KIND_RRD);
        w_pick_waddr = i_cmd_addr;
        w_pick_units = 12'd1;
        w_pick_wdata = i_cmd_wdata;
      end
      5'b0001?: begin
        w_pick_valid = 1'b1;
        w_pick_src   = LPARA_SRC_RD;
        w_pick_kind  = 2'(LPARA_KIND_MRD);
        w_pick_cs    = i_rd_seg_cs;
        w_pick_waddr = {1'b0, i_rd_seg_addr[31:1]};
        w_pick_units = i_rd_seg_units;
        w_pick_wrap  = i_rd_seg_wrap;
      end
      5'b00001: begin
        w_pick_valid = 1'b1;
        w_pick_src   = LPARA_SRC_WR;
        w_pick_kind  = 2'(LPARA_KIND_MWR);
        w_pick_cs    = i_wr_seg_cs;
        w_pick_waddr = {1'b0, i_wr_seg_addr[31:1]};
        w_pick_units = i_wr_seg_units;
        w_pick_wrap  = i_wr_seg_wrap;
      end
      default: begin
        // No candidate.
      end
    endcase
  end

  // The transaction starts at a tick in IDLE when a candidate is ready and the data of an earlier
  // read have all been received (the capture FIFO is emptied by reading, DEC-040).
  assign w_start = i_ck_tick & (reg_fsm_tx_current_state == ENUM_ST_TX_IDLE) & w_pick_valid &
                   (reg_rx_left == '0) & ~w_kill;

  // Descriptors are taken when the transaction starts, and again at a merge.
  assign w_take_rd = w_start & (w_pick_src == LPARA_SRC_RD);
  assign w_take_wr = w_start & (w_pick_src == LPARA_SRC_WR);

  // ---------------------------------------------------------------------------------------------
  // Merge of a following segment (answer 2A)
  // ---------------------------------------------------------------------------------------------

  // Next linear byte address after the units that are still to be scheduled in this transaction.
  assign w_nxt_baddr = {reg_waddr[30:0], 1'b0} +
                        ((32'(reg_cnt[1:0]) + 32'd1) * LPARA_UNIT_B);

  // A merge is tried while at most 2 data periods remain: same direction, same chip select,
  // linear, next address, room under the CS#-low limit.
  always_comb begin : p_com_merge
    w_merge_rd    = 1'b0;
    w_merge_wr    = 1'b0;
    w_merge_units = '0;
    if (i_merge_en && (reg_fsm_tx_current_state == ENUM_ST_TX_DATA) && !reg_wrap &&
        (reg_cnt <= 10'd2) && (reg_dcap != 10'd0)) begin
      if ((32'(reg_kind) == LPARA_KIND_MRD) && i_rd_seg_valid && !i_rd_seg_wrap &&
          (i_rd_seg_cs == reg_cs) && (i_rd_seg_addr == w_nxt_baddr)) begin
        w_merge_rd    = 1'b1;
        w_merge_units = i_rd_seg_units;
      end
      if ((32'(reg_kind) == LPARA_KIND_MWR) && i_wr_seg_valid && !i_wr_seg_wrap &&
          (i_wr_seg_cs == reg_cs) && (i_wr_seg_addr == w_nxt_baddr)) begin
        w_merge_wr    = 1'b1;
        w_merge_units = i_wr_seg_units;
      end
    end
  end

  // Data periods added by the merge, limited by the room left under the CS#-low limit.
  assign w_merge_ok  = i_ck_tick & (w_merge_rd | w_merge_wr) & ~w_kill;
  assign w_merge_add = w_merge_ok ?
                       ((w_merge_units >= {2'b00, reg_dcap}) ? reg_dcap : w_merge_units[9:0]) :
                       10'd0;

  // Descriptor handshakes toward the frontend.
  assign o_rd_seg_ready = w_take_rd | (w_merge_ok & w_merge_rd);
  assign o_wr_seg_ready = w_take_wr | (w_merge_ok & w_merge_wr);

  // ---------------------------------------------------------------------------------------------
  // Transaction FSM
  // ---------------------------------------------------------------------------------------------

  assign w_kind_wr = (32'(reg_kind) == LPARA_KIND_MWR) | (32'(reg_kind) == LPARA_KIND_RWR);
  assign w_kind_rd  = (32'(reg_kind) == LPARA_KIND_MRD) | (32'(reg_kind) == LPARA_KIND_RRD);

  // Part 1, sequential: the current transaction state, moved at the tick only.
  always_ff @(posedge i_clk_core, negedge i_rst_n_core) begin : p_ff_fsm_tx
    if (!i_rst_n_core) begin
      reg_fsm_tx_current_state <= ENUM_ST_TX_IDLE;
    end else if (i_ck_tick) begin
      reg_fsm_tx_current_state <= w_fsm_tx_nxt_state;
    end
  end

  // Part 2, combinational: next transaction state. CSS lasts max(t_css, 1) periods, CA takes 3,
  // LAT lasts the latency (a register write has none), DATA one period per unit, END one period
  // with CS# high. A kill ends the transaction at once.
  always_comb begin : p_com_fsm_tx
    w_fsm_tx_nxt_state = reg_fsm_tx_current_state;
    case (reg_fsm_tx_current_state)
      ENUM_ST_TX_IDLE: begin
        if (w_start) begin
          w_fsm_tx_nxt_state = ENUM_ST_TX_CSS;
        end
      end
      ENUM_ST_TX_CSS: begin
        if (reg_cnt == 10'd0) begin
          w_fsm_tx_nxt_state = ENUM_ST_TX_CA0;
        end
      end
      ENUM_ST_TX_CA0: begin
        w_fsm_tx_nxt_state = ENUM_ST_TX_CA1;
      end
      ENUM_ST_TX_CA1: begin
        w_fsm_tx_nxt_state = ENUM_ST_TX_CA2;
      end
      ENUM_ST_TX_CA2: begin
        if (32'(reg_kind) == LPARA_KIND_RWR) begin
          w_fsm_tx_nxt_state = ENUM_ST_TX_DATA;
        end else begin
          w_fsm_tx_nxt_state = ENUM_ST_TX_LAT;
        end
      end
      ENUM_ST_TX_LAT: begin
        if (reg_cnt == 10'd0) begin
          w_fsm_tx_nxt_state = ENUM_ST_TX_DATA;
        end
      end
      ENUM_ST_TX_DATA: begin
        if ((reg_cnt == 10'd0) && (w_merge_add == 10'd0)) begin
          w_fsm_tx_nxt_state = ENUM_ST_TX_END;
        end
      end
      ENUM_ST_TX_END: begin
        w_fsm_tx_nxt_state = ENUM_ST_TX_IDLE;
      end
      default: begin
        w_fsm_tx_nxt_state = ENUM_ST_TX_IDLE;
      end
    endcase
    if (w_kill && (reg_fsm_tx_current_state != ENUM_ST_TX_IDLE) &&
        (reg_fsm_tx_current_state != ENUM_ST_TX_END)) begin
      w_fsm_tx_nxt_state = ENUM_ST_TX_END;
    end
  end

  // Latency of the transaction: twice the initial latency in fixed mode or when the device
  // raised RWDS in the command and address phase, otherwise the initial latency (REQ-MEM-011).
  assign w_lat_nxt = (w_c_fixed_lat | (|i_rwds_smp)) ? {w_c_init_lat, 1'b0} :
                                                       {1'b0, w_c_init_lat};

  // Data periods allowed under the CS#-low limit: t_csm minus CS#-before-CK, CA and latency.
  assign w_css      = (w_c_t_css == 8'd0) ? 9'd1 : {1'b0, w_c_t_css};
  assign w_dmax_nxt = ({1'b0, w_c_t_csm} > ({8'd0, w_css} + 17'd3 + {11'd0, w_lat_nxt})) ?
                      ({1'b0, w_c_t_csm} - ({8'd0, w_css} + 17'd3 + {11'd0, w_lat_nxt})) : 17'd1;

  // Data periods of this transaction: the units still to send, limited by the room.
  assign w_d = (reg_units_left >= {2'b00, reg_dmax}) ? reg_dmax : reg_units_left[9:0];

  // Transaction registers, moved at the tick. A kill clears the units that are still open.
  always_ff @(posedge i_clk_core, negedge i_rst_n_core) begin : p_ff_tx_dp
    if (!i_rst_n_core) begin
      reg_kind        <= 2'(LPARA_KIND_MRD);
      reg_cs          <= 1'b0;
      reg_waddr       <= 32'd0;
      reg_units_left  <= '0;
      reg_wrap        <= 1'b0;
      reg_cnt         <= 10'd0;
      reg_dmax        <= 10'd1;
      reg_dcap        <= 10'd0;
      reg_wdata       <= 16'd0;
      reg_isinit      <= 1'b0;
      reg_iscmd       <= 1'b0;
      reg_segs        <= '0;
      reg_last_dir    <= 1'b0;
      reg_consec      <= 4'd0;
      reg_start_waddr <= 32'd0;
    end else if (i_ck_tick) begin
      case (reg_fsm_tx_current_state)
        ENUM_ST_TX_IDLE: begin
          if (w_start) begin
            reg_kind       <= w_pick_kind;
            reg_cs         <= w_pick_cs;
            reg_waddr      <= w_pick_waddr;
            reg_units_left <= w_pick_units;
            reg_wrap       <= w_pick_wrap;
            reg_wdata      <= w_pick_wdata;
            reg_cnt        <= 10'({1'b0, ((w_p_t_css == 8'd0) ? 9'd1 : {1'b0, w_p_t_css})}) -
                              10'd1;
            if (w_pick_src != LPARA_SRC_CONT) begin
              reg_isinit      <= (w_pick_src == LPARA_SRC_INIT);
              reg_iscmd       <= (w_pick_src == LPARA_SRC_CMD);
              reg_start_waddr <= w_pick_waddr;
              reg_segs        <= ((w_pick_src == LPARA_SRC_RD) || (w_pick_src == LPARA_SRC_WR)) ?
                                 10'd1 : 10'd0;
            end
            if ((w_pick_src == LPARA_SRC_RD) || (w_pick_src == LPARA_SRC_WR)) begin
              reg_last_dir <= (w_pick_src == LPARA_SRC_WR);
              if (reg_last_dir == (w_pick_src == LPARA_SRC_WR)) begin
                reg_consec <= (32'(reg_consec) >= LPARA_ARB_BOUND) ? reg_consec :
                                                                      (reg_consec + 4'd1);
              end else begin
                reg_consec <= 4'd1;
              end
            end
          end
        end
        ENUM_ST_TX_CSS: begin
          reg_cnt <= (reg_cnt == 10'd0) ? 10'd0 : (reg_cnt - 10'd1);
        end
        ENUM_ST_TX_CA2: begin
          reg_dmax <= w_dmax_nxt[9:0];
          if (32'(reg_kind) == LPARA_KIND_RWR) begin
            reg_cnt  <= 10'd0;
            reg_dcap <= 10'd0;
          end else begin
            reg_cnt <= 10'(w_lat_nxt) - 10'd1;
          end
        end
        ENUM_ST_TX_LAT: begin
          if (reg_cnt == 10'd0) begin
            reg_cnt  <= w_d - 10'd1;
            reg_dcap <= reg_dmax - w_d;
          end else begin
            reg_cnt <= reg_cnt - 10'd1;
          end
        end
        ENUM_ST_TX_DATA: begin
          reg_waddr <= reg_waddr + LPARA_WORDS_UNIT;
          reg_cnt   <= (reg_cnt + w_merge_add) - 10'd1;
          if (w_merge_ok) begin
            reg_units_left <= (reg_units_left + w_merge_units) - 12'd1;
            reg_dcap       <= reg_dcap - w_merge_add;
            reg_segs       <= reg_segs + 10'd1;
          end else begin
            reg_units_left <= reg_units_left - 12'd1;
          end
        end
        ENUM_ST_TX_END: begin
          reg_segs <= 10'd0;
        end
        default: begin
          // CA0 and CA1 only move the state.
        end
      endcase
      if (w_kill) begin
        reg_units_left <= '0;
        reg_segs       <= 10'd0;
      end
    end
  end

  // ---------------------------------------------------------------------------------------------
  // Gap counters (per chip select)
  // ---------------------------------------------------------------------------------------------

  // CS# high periods required before the next transaction of the chip select (REQ-MEM-004).
  assign w_gap_load = f_gap(w_c_t_cshi, w_c_t_rwr, w_c_t_css);

  always_ff @(posedge i_clk_core, negedge i_rst_n_core) begin : p_ff_gap
    if (!i_rst_n_core) begin
      reg_gap_cnt_0 <= 9'd0;
      reg_gap_cnt_1 <= 9'd0;
    end else if (i_ck_tick) begin
      if ((reg_fsm_tx_current_state == ENUM_ST_TX_END) && !reg_cs) begin
        reg_gap_cnt_0 <= w_gap_load;
      end else if (reg_gap_cnt_0 != 9'd0) begin
        reg_gap_cnt_0 <= reg_gap_cnt_0 - 9'd1;
      end
      if ((reg_fsm_tx_current_state == ENUM_ST_TX_END) && reg_cs) begin
        reg_gap_cnt_1 <= w_gap_load;
      end else if (reg_gap_cnt_1 != 9'd0) begin
        reg_gap_cnt_1 <= reg_gap_cnt_1 - 9'd1;
      end
    end
  end

  // ---------------------------------------------------------------------------------------------
  // Pin commands (one command per CK period, issued at the tick)
  // ---------------------------------------------------------------------------------------------

  // Command and address of the transaction: read or write, memory or register space, linear or
  // wrapped, word address (REF-001). CA[15:3] are reserved and sent as 0.
  always_comb begin : p_com_ca
    w_ca         = 48'd0;
    w_ca[47]     = w_kind_rd;
    w_ca[46]     = (32'(reg_kind) == LPARA_KIND_RRD) | (32'(reg_kind) == LPARA_KIND_RWR);
    w_ca[45]     = ~reg_wrap;
    w_ca[44:16]  = reg_waddr[31:3];
    w_ca[2:0]    = reg_waddr[2:0];
    w_ca_a       = 8'd0;
    w_ca_b       = 8'd0;
    case (reg_fsm_tx_current_state)
      ENUM_ST_TX_CA0: begin
        w_ca_a = w_ca[47:40];
        w_ca_b = w_ca[39:32];
      end
      ENUM_ST_TX_CA1: begin
        w_ca_a = w_ca[31:24];
        w_ca_b = w_ca[23:16];
      end
      ENUM_ST_TX_CA2: begin
        w_ca_a = w_ca[15:8];
        w_ca_b = w_ca[7:0];
      end
      default: begin
        // No CA byte outside the CA periods.
      end
    endcase
    w_ca_unit = '0;
    w_ca_unit[7:0] = w_ca_a;
    w_ca_unit[PARA_MEM_DQ_W +: 8] = w_ca_b;
  end

  // Data of a register write: one word, big endian on x8 (byte A first), on the 16-bit beat in
  // x16, repeated in the second beat.
  if (PARA_MEM_DQ_W == 32'd8) begin : gen_regw_x8
    assign w_regw_unit = {reg_wdata[7:0], reg_wdata[15:8]};
    assign w_word_in   = {i_cap_data[7:0], i_cap_data[15:8]};
  end else begin : gen_regw_x16
    assign w_regw_unit = {reg_wdata, reg_wdata};
    assign w_word_in   = i_cap_data[15:0];
  end

  // The pin state of the next CK period from the current transaction state.
  always_comb begin : p_com_cmd
    w_cmd_cs_n_nxt    = '1;
    w_cmd_ck_run_nxt  = 1'b0;
    w_cmd_dq_nxt      = '0;
    w_cmd_dq_oe_nxt   = 1'b0;
    w_cmd_rwds_nxt    = '0;
    w_cmd_rwds_oe_nxt = 1'b0;
    case (reg_fsm_tx_current_state)
      ENUM_ST_TX_CSS: begin
        w_cmd_cs_n_nxt = ~(PARA_NUM_CS'(1) << reg_cs);
      end
      ENUM_ST_TX_CA0,
      ENUM_ST_TX_CA1,
      ENUM_ST_TX_CA2: begin
        w_cmd_cs_n_nxt         = ~(PARA_NUM_CS'(1) << reg_cs);
        w_cmd_ck_run_nxt       = 1'b1;
        w_cmd_dq_nxt           = w_ca_unit;
        w_cmd_dq_oe_nxt        = 1'b1;
      end
      ENUM_ST_TX_LAT: begin
        w_cmd_cs_n_nxt         = ~(PARA_NUM_CS'(1) << reg_cs);
        w_cmd_ck_run_nxt       = 1'b1;
        w_cmd_rwds_oe_nxt      = (32'(reg_kind) == LPARA_KIND_MWR) && (reg_cnt == 10'd0);
      end
      ENUM_ST_TX_DATA: begin
        w_cmd_cs_n_nxt         = ~(PARA_NUM_CS'(1) << reg_cs);
        w_cmd_ck_run_nxt       = 1'b1;
        case (32'(reg_kind))
          LPARA_KIND_MWR: begin
            w_cmd_dq_nxt      = i_wr_data;
            w_cmd_dq_oe_nxt   = 1'b1;
            w_cmd_rwds_nxt    = ~i_wr_mask;
            w_cmd_rwds_oe_nxt = 1'b1;
          end
          LPARA_KIND_RWR: begin
            w_cmd_dq_nxt    = w_regw_unit;
            w_cmd_dq_oe_nxt = 1'b1;
          end
          default: begin
            // A read leaves the bus to the device.
          end
        endcase
      end
      default: begin
        // IDLE and END: CS# high, CK stopped, bus released.
      end
    endcase
  end

  // Pin command registers: the PHY takes them at the next tick. The delay-line tap of the chip
  // select is set while CS# goes low, so it does not change during a read.
  always_ff @(posedge i_clk_core, negedge i_rst_n_core) begin : p_ff_cmd
    if (!i_rst_n_core) begin
      reg_cs_n    <= '1;
      reg_ck_run  <= 1'b0;
      reg_dq      <= '0;
      reg_dq_oe   <= 1'b0;
      reg_rwds    <= '0;
      reg_rwds_oe <= 1'b0;
      reg_dly_sel <= '0;
    end else if (i_ck_tick) begin
      reg_cs_n    <= w_cmd_cs_n_nxt;
      reg_ck_run  <= w_cmd_ck_run_nxt;
      reg_dq      <= w_cmd_dq_nxt;
      reg_dq_oe   <= w_cmd_dq_oe_nxt;
      reg_rwds    <= w_cmd_rwds_nxt;
      reg_rwds_oe <= w_cmd_rwds_oe_nxt;
      if (reg_fsm_tx_current_state == ENUM_ST_TX_CSS) begin
        reg_dly_sel <= w_c_tap[PARA_DLY_TAP_W-1:0];
      end
    end
  end

  // Pin command outputs and the write data pop: one unit leaves the frontend buffer in every
  // data period of a memory write.
  assign o_cmd_cs_n    = reg_cs_n;
  assign o_cmd_ck_run  = reg_ck_run;
  assign o_cmd_dq      = reg_dq;
  assign o_cmd_dq_oe   = reg_dq_oe;
  assign o_cmd_rwds    = reg_rwds;
  assign o_cmd_rwds_oe = reg_rwds_oe;
  assign o_dly_sel     = reg_dly_sel;
  assign o_wr_data_pop = i_ck_tick & (reg_fsm_tx_current_state == ENUM_ST_TX_DATA) &
                         (32'(reg_kind) == LPARA_KIND_MWR);

  // ---------------------------------------------------------------------------------------------
  // Read capture, device register reads and timeouts
  // ---------------------------------------------------------------------------------------------

  // The capture ring is flushed during the last two latency periods of a read (the pair that the
  // capture clock makes when RWDS returns LOW belongs to this and earlier reads, DEC-040) and read
  // for data once units are expected.
  assign w_data_tick = i_ck_tick & (reg_fsm_tx_current_state == ENUM_ST_TX_DATA);
  assign w_drain     = (reg_fsm_tx_current_state == ENUM_ST_TX_LAT) & w_kind_rd &
                       (reg_cnt <= 10'd1);
  // A pair is read as data when units are expected.
  assign w_pop_data  = ~i_cap_empty & (reg_rx_left != '0);
  assign o_cap_pop   = ~i_cap_empty & (reg_rx_left != '0);
  assign o_cap_flush = w_drain;

  // Receive state: units still expected, wait counter for the timeout, completed words.
  always_ff @(posedge i_clk_core, negedge i_rst_n_core) begin : p_ff_rx
    if (!i_rst_n_core) begin
      reg_rx_left    <= '0;
      reg_got        <= 1'b0;
      reg_got_any    <= 1'b0;
      reg_got_words  <= 13'd0;
      reg_tmo_cnt    <= 16'd0;
      reg_rdv        <= 1'b0;
    end else begin
      reg_rdv <= w_pop_data & (32'(reg_kind) == LPARA_KIND_MRD);
      if (w_kill) begin
        reg_rx_left <= '0;
      end else begin
        reg_rx_left <= reg_rx_left + LPARA_UNITS_W'(w_data_tick & w_kind_rd) -
                       LPARA_UNITS_W'(w_pop_data);
      end
      if (i_ck_tick) begin
        reg_got     <= 1'b0;
        reg_tmo_cnt <= (reg_got | w_pop_data | (reg_rx_left == '0)) ? 16'd0 :
                       (reg_tmo_cnt + 16'd1);
      end
      if (w_start) begin
        reg_got_any   <= 1'b0;
        reg_got_words <= 13'd0;
      end
      if (w_pop_data) begin
        reg_got     <= 1'b1;
        reg_got_any <= 1'b1;
        if (reg_got_words != 13'h1FFF) begin
          reg_got_words <= reg_got_words + 13'(LPARA_WORDS_UNIT);
        end
      end
    end
  end

  // Read data toward the frontend, one clock after the FIFO read.
  always_ff @(posedge i_clk_core) begin : p_ff_rdd
    reg_rdd <= i_cap_data;
  end

  // Read data toward the frontend.
  assign o_rd_data_valid = reg_rdv;
  assign o_rd_data       = reg_rdd;

  // An operation (start-up command or device command) is done when a register write reaches its
  // last period or when the word of a register read has arrived.
  assign w_op_done = reg_op_active &
                     ((i_ck_tick & (reg_fsm_tx_current_state == ENUM_ST_TX_END) &
                       (32'(reg_kind) == LPARA_KIND_RWR)) |
                      (w_pop_data & (32'(reg_kind) == LPARA_KIND_RRD)));

  // The operation flag is set at the start of a start-up or command operation.
  always_ff @(posedge i_clk_core, negedge i_rst_n_core) begin : p_ff_opact
    if (!i_rst_n_core) begin
      reg_op_active <= 1'b0;
    end else if (w_op_done || (w_kill && reg_op_active)) begin
      reg_op_active <= 1'b0;
    end else if (w_start && ((w_pick_src == LPARA_SRC_INIT) || (w_pick_src == LPARA_SRC_CMD))) begin
      reg_op_active <= 1'b1;
    end
  end

  // A finished or rejected command keeps go high until the register file has cleared it; the
  // controller does not start the same command again before it has seen go low.
  always_ff @(posedge i_clk_core, negedge i_rst_n_core) begin : p_ff_cmd_hold
    if (!i_rst_n_core) begin
      reg_cmd_hold <= 1'b0;
    end else if (!i_cmd_go) begin
      reg_cmd_hold <= 1'b0;
    end else if ((w_op_done & reg_iscmd) | w_cmd_reject | (w_kill & reg_op_active & reg_iscmd)) begin
      reg_cmd_hold <= 1'b1;
    end
  end

  // Words read by register reads: the device command result and the ID0 of each chip select.
  always_ff @(posedge i_clk_core, negedge i_rst_n_core) begin : p_ff_words
    if (!i_rst_n_core) begin
      reg_cmd_rdata <= 16'd0;
      reg_id0_act_0 <= 16'd0;
      reg_id0_act_1 <= 16'd0;
    end else if (w_pop_data && (32'(reg_kind) == LPARA_KIND_RRD)) begin
      if (reg_iscmd) begin
        reg_cmd_rdata <= w_word_in;
      end
      if (reg_isinit && !reg_cs) begin
        reg_id0_act_0 <= w_word_in;
      end
      if (reg_isinit && reg_cs) begin
        reg_id0_act_1 <= w_word_in;
      end
    end
  end

  // Results of the register reads.
  assign o_cmd_rdata   = reg_cmd_rdata;
  assign o_d0_id0_act  = reg_id0_act_0;
  assign o_d1_id0_act  = reg_id0_act_1;

  // Completion pulses of the write segments: all segments of a finished transaction answer at the
  // END period, one per clock.
  always_ff @(posedge i_clk_core, negedge i_rst_n_core) begin : p_ff_done
    if (!i_rst_n_core) begin
      reg_done_cnt <= '0;
    end else begin
      reg_done_cnt <= reg_done_cnt - ((reg_done_cnt != '0) ? 10'd1 : 10'd0) +
                      ((i_ck_tick && (reg_fsm_tx_current_state == ENUM_ST_TX_END) &&
                        (32'(reg_kind) == LPARA_KIND_MWR) && (reg_units_left == '0)) ?
                       reg_segs : 10'd0);
    end
  end

  // One completion pulse per finished segment.
  assign o_wr_seg_done = (reg_done_cnt != '0);

  // ---------------------------------------------------------------------------------------------
  // Events, hardware writes to the register file and the timeout log
  // ---------------------------------------------------------------------------------------------

  // Command code and awaited event of the timeout log.
  always_comb begin : p_com_log_code
    w_cmd_code  = 4'd0;
    w_wait_code = 4'd0;
    case (32'(reg_kind))
      LPARA_KIND_MRD: begin
        w_cmd_code = 4'(LPARA_CMD_MEM_R);
      end
      LPARA_KIND_MWR: begin
        w_cmd_code = 4'(LPARA_CMD_MEM_W);
      end
      LPARA_KIND_RRD: begin
        w_cmd_code = reg_isinit ? 4'(LPARA_CMD_INIT_R) : 4'(LPARA_CMD_REG_R);
      end
      default: begin
        w_cmd_code = reg_isinit ? 4'(LPARA_CMD_INIT_W) : 4'(LPARA_CMD_REG_W);
      end
    endcase
    if (reg_fsm_tx_current_state == ENUM_ST_TX_IDLE) begin
      w_wait_code = 4'(LPARA_WAIT_FIFO);
    end else if (!reg_got_any) begin
      w_wait_code = 4'(LPARA_WAIT_FIRST);
    end else begin
      w_wait_code = 4'(LPARA_WAIT_NXT);
    end
  end

  // Byte address of the first byte of the transaction (the register word address for a register
  // command), including the offset of chip select 1.
  assign w_log_baddr = ((32'(reg_kind) == LPARA_KIND_MRD) || (32'(reg_kind) == LPARA_KIND_MWR)) ?
                       ({reg_start_waddr[30:0], 1'b0} + (reg_cs ? PARA_MEM_SIZE_BYTES : 32'd0)) :
                       reg_start_waddr;

  // Event pulses (one clock), the abort of the open AXI requests and the log.
  always_ff @(posedge i_clk_core, negedge i_rst_n_core) begin : p_ff_evt
    if (!i_rst_n_core) begin
      reg_evt_init_ok  <= 1'b0;
      reg_evt_cfg_err  <= 1'b0;
      reg_evt_pwr_lost <= 1'b0;
      reg_evt_id_mis   <= 1'b0;
      reg_evt_lat_mis  <= 1'b0;
      reg_evt_cmd_done <= 1'b0;
      reg_evt_tmo      <= 1'b0;
      reg_abort        <= 1'b0;
      reg_cmd_go_clr   <= 1'b0;
      reg_cmd_done_set <= 1'b0;
      reg_cmd_err_set  <= 1'b0;
      reg_resume_clr   <= 1'b0;
      reg_tmo_log_set  <= 1'b0;
      reg_log_cs       <= 1'b0;
      reg_log_wr       <= 1'b0;
      reg_log_beats    <= 13'd0;
      reg_log_cmd      <= 4'd0;
      reg_log_wait     <= 4'd0;
      reg_log_addr     <= 32'd0;
    end else begin
      reg_evt_init_ok  <= i_ck_tick & (reg_fsm_mode_current_state == ENUM_ST_MODE_INIT) &
                          (w_fsm_mode_nxt_state == ENUM_ST_MODE_READY);
      reg_evt_cfg_err  <= i_en & ~reg_en_prev & ~w_cfg_valid &
                          (reg_fsm_mode_current_state == ENUM_ST_MODE_OFF);
      reg_evt_pwr_lost <= w_pwr_loss;
      reg_evt_tmo      <= w_tmo_hit;
      reg_abort        <= w_tmo_hit | w_pwr_loss;
      reg_resume_clr   <= i_ck_tick & i_resume;
      reg_evt_id_mis   <= w_pop_data & reg_isinit & (32'(reg_kind) == LPARA_KIND_RRD) &
                          w_c_id_chk_en & (w_word_in != w_c_id0_exp);
      reg_evt_lat_mis  <= w_op_done & reg_iscmd & (32'(reg_kind) == LPARA_KIND_RWR) &
                          (reg_start_waddr == LPARA_CR0_ADDR) &
                          (reg_wdata[7:4] != f_lat_code(w_c_init_lat));
      reg_evt_cmd_done <= w_op_done & reg_iscmd;
      reg_cmd_done_set <= w_op_done & reg_iscmd;
      reg_cmd_go_clr   <= (w_op_done & reg_iscmd) | w_cmd_reject | (w_kill & reg_op_active & reg_iscmd);
      reg_cmd_err_set  <= w_cmd_reject | (w_kill & reg_op_active & reg_iscmd);
      reg_tmo_log_set  <= w_tmo_hit & ~i_tmo_log_valid;
      if (w_tmo_hit && !i_tmo_log_valid) begin
        reg_log_cs    <= reg_cs;
        reg_log_wr    <= w_kind_wr;
        reg_log_beats <= reg_got_words;
        reg_log_cmd   <= w_cmd_code;
        reg_log_wait  <= w_wait_code;
        reg_log_addr  <= w_log_baddr;
      end
    end
  end

  // Event and handshake outputs.
  assign o_evt_init_ok  = reg_evt_init_ok;
  assign o_evt_cfg_err  = reg_evt_cfg_err;
  assign o_evt_pwr_lost = reg_evt_pwr_lost;
  assign o_evt_id_mis   = reg_evt_id_mis;
  assign o_evt_lat_mis  = reg_evt_lat_mis;
  assign o_evt_cmd_done = reg_evt_cmd_done;
  assign o_evt_tmo      = reg_evt_tmo;
  assign o_abort        = reg_abort;
  assign o_cmd_go_clr   = reg_cmd_go_clr;
  assign o_cmd_done_set = reg_cmd_done_set;
  assign o_cmd_err_set  = reg_cmd_err_set;
  assign o_resume_clr   = reg_resume_clr;
  assign o_tmo_log_set  = reg_tmo_log_set;
  assign o_tmo_log_cs    = reg_log_cs;
  assign o_tmo_log_wr    = reg_log_wr;
  assign o_tmo_log_beats = reg_log_beats;
  assign o_tmo_log_cmd   = reg_log_cmd;
  assign o_tmo_log_wait  = reg_log_wait;
  assign o_tmo_addr      = reg_log_addr;

endmodule
