/*
 * Project      : Timer IP
 * Author       : Nguyen Quan and Codex
 * AI Flow      : VLSIT RTL Generator AI Automation Flow
 * AI Flow Page : https://github.com/nguyenquanicd/VLSIT_RTL_Generator_AI_Model
 * Date         : 2026-11-03
 * Description  : Configurable shared-counter timer integrating APB CSR, capture, compare/PWM,
 *                PWM-input, one-pulse, timeout, interrupt, and req/ack DMA stream functions.
 */
`timescale 1ns/1ps

module m_vlsit_timer #(
  // Parameter Description: number of capture input pins and the width of i_capture_ch.
  // Parameter values: 1 through 8; default is 4.
  // Parameter unit: channel
  parameter logic [31:0] PARA_CAPTURE_COUNT = 32'd4,
  // Parameter Description: number of compare/PWM output pins and the width of o_timer_ch.
  // Parameter values: 1 through 8; default is 4.
  // Parameter unit: channel
  parameter logic [31:0] PARA_OUTPUT_COUNT = 32'd4,
  // Parameter Description: width of the shared counter and counter-derived timing values.
  // Parameter values: 32 or 64; default is 32.
  // Parameter unit: bit
  parameter logic [31:0] PARA_COUNTER_WIDTH = 32'd32,
  // Parameter Description: selects same-clock or unrelated APB and Timer clocks.
  // Parameter values: 0 (same net) or 1 (asynchronous); default is 0.
  // Parameter unit: none
  parameter logic [31:0] PARA_ASYNC = 32'd0,
  localparam logic [31:0] LPARA_ADDR_W = 32'd16,
  localparam logic [31:0] LPARA_DATA_W = 32'd32,
  localparam logic [31:0] LPARA_RECORD_W = 32'd32 + PARA_COUNTER_WIDTH,
  localparam logic [31:0] LPARA_CHANNEL_COUNT = (PARA_CAPTURE_COUNT > PARA_OUTPUT_COUNT) ?
                                                PARA_CAPTURE_COUNT : PARA_OUTPUT_COUNT
) (
  // Clock and reset
  input  wire                           i_clk_apb,
  input  wire                           i_clk_timer,
  input  wire                           i_rst_n_apb,
  input  wire                           i_rst_n_timer,

  // APB4 programming interface
  input  wire                           i_psel_apb,
  input  wire                           i_penable_apb,
  input  wire                           i_pwrite_apb,
  input  wire  [15:0]                   i_paddr_apb,
  input  wire  [31:0]                   i_pwdata_apb,
  input  wire  [3:0]                    i_pstrb_apb,
  input  wire  [2:0]                    i_pprot_apb,
  output logic                          o_pready_apb,
  output logic [31:0]                   o_prdata_apb,
  output logic                          o_pslverr_apb,

  // Capture inputs and timer channel outputs
  input  wire  [PARA_CAPTURE_COUNT-1:0] i_capture_ch,
  output logic [PARA_OUTPUT_COUNT-1:0]  o_timer_ch,

  // Capture DMA req/ack and compare/update DMA req/ack (4-phase level, synchronous to i_clk_timer)
  output logic                          o_dma_cap_req,
  input  wire                           i_dma_cap_ack,
  output logic                          o_dma_cmp_req,
  input  wire                           i_dma_cmp_ack,

  // Timer interrupt output
  output logic                          o_irq_timer
);

  // Locally synchronized reset releases for the APB and Timer clock domains.
  logic w_rst_n_apb;
  logic w_rst_n_timer;
  logic w_csr_psel;
  logic w_stream_sel;
  logic w_stream_pready;
  logic [31:0] w_stream_prdata;
  logic w_stream_pslverr;

  // Generated CSR ports are declared from the canonical workbook interface.
  logic w_csr_o_apb_pready;
  logic w_csr_o_apb_pslverr;
  logic [LPARA_DATA_W-1:0] w_csr_o_apb_prdata;
  logic w_csr_o_reg_rd_en;
  logic [LPARA_ADDR_W-1:0] w_csr_o_reg_rd_addr;
  logic w_csr_o_reg_wr_en;
  logic [LPARA_ADDR_W-1:0] w_csr_o_reg_wr_addr;
  logic w_o_ctrl_timer_en;
  logic w_o_ctrl_dir_down;
  logic [31:0] w_o_period_period;
  logic [31:0] w_o_period_hi_period_hi;
  logic [15:0] w_o_prescale_psc;
  logic [1:0] w_o_dma_cfg_cap_rec_cnt;
  logic [1:0] w_o_dma_cfg_cmp_rec_cnt;
  logic [2:0] w_o_ch0_cfg_mode;
  logic [1:0] w_o_ch0_cfg_edge_sel;
  logic [2:0] w_o_ch0_cfg_sample_div;
  logic [3:0] w_o_ch0_cfg_sample_n;
  logic [1:0] w_o_ch0_cfg_cmp_action;
  logic w_o_ch0_cfg_out_pol;
  logic w_o_ch0_cfg_idle_level;
  logic w_o_ch0_cfg_force_en;
  logic w_o_ch0_cfg_force_val;
  logic w_o_ch0_cfg_timeout_en;
  logic w_o_ch0_cfg_tout_start;
  logic [2:0] w_o_ch0_cfg_trig_sel;
  logic w_o_ch0_cfg_sw_arm_en;
  logic w_o_ch0_cfg_arm_cmd;
  logic [2:0] w_o_ch1_cfg_mode;
  logic [1:0] w_o_ch1_cfg_edge_sel;
  logic [2:0] w_o_ch1_cfg_sample_div;
  logic [3:0] w_o_ch1_cfg_sample_n;
  logic [1:0] w_o_ch1_cfg_cmp_action;
  logic w_o_ch1_cfg_out_pol;
  logic w_o_ch1_cfg_idle_level;
  logic w_o_ch1_cfg_force_en;
  logic w_o_ch1_cfg_force_val;
  logic w_o_ch1_cfg_timeout_en;
  logic w_o_ch1_cfg_tout_start;
  logic [2:0] w_o_ch1_cfg_trig_sel;
  logic w_o_ch1_cfg_sw_arm_en;
  logic w_o_ch1_cfg_arm_cmd;
  logic [2:0] w_o_ch2_cfg_mode;
  logic [1:0] w_o_ch2_cfg_edge_sel;
  logic [2:0] w_o_ch2_cfg_sample_div;
  logic [3:0] w_o_ch2_cfg_sample_n;
  logic [1:0] w_o_ch2_cfg_cmp_action;
  logic w_o_ch2_cfg_out_pol;
  logic w_o_ch2_cfg_idle_level;
  logic w_o_ch2_cfg_force_en;
  logic w_o_ch2_cfg_force_val;
  logic w_o_ch2_cfg_timeout_en;
  logic w_o_ch2_cfg_tout_start;
  logic [2:0] w_o_ch2_cfg_trig_sel;
  logic w_o_ch2_cfg_sw_arm_en;
  logic w_o_ch2_cfg_arm_cmd;
  logic [2:0] w_o_ch3_cfg_mode;
  logic [1:0] w_o_ch3_cfg_edge_sel;
  logic [2:0] w_o_ch3_cfg_sample_div;
  logic [3:0] w_o_ch3_cfg_sample_n;
  logic [1:0] w_o_ch3_cfg_cmp_action;
  logic w_o_ch3_cfg_out_pol;
  logic w_o_ch3_cfg_idle_level;
  logic w_o_ch3_cfg_force_en;
  logic w_o_ch3_cfg_force_val;
  logic w_o_ch3_cfg_timeout_en;
  logic w_o_ch3_cfg_tout_start;
  logic [2:0] w_o_ch3_cfg_trig_sel;
  logic w_o_ch3_cfg_sw_arm_en;
  logic w_o_ch3_cfg_arm_cmd;
  logic [2:0] w_o_ch4_cfg_mode;
  logic [1:0] w_o_ch4_cfg_edge_sel;
  logic [2:0] w_o_ch4_cfg_sample_div;
  logic [3:0] w_o_ch4_cfg_sample_n;
  logic [1:0] w_o_ch4_cfg_cmp_action;
  logic w_o_ch4_cfg_out_pol;
  logic w_o_ch4_cfg_idle_level;
  logic w_o_ch4_cfg_force_en;
  logic w_o_ch4_cfg_force_val;
  logic w_o_ch4_cfg_timeout_en;
  logic w_o_ch4_cfg_tout_start;
  logic [2:0] w_o_ch4_cfg_trig_sel;
  logic w_o_ch4_cfg_sw_arm_en;
  logic w_o_ch4_cfg_arm_cmd;
  logic [2:0] w_o_ch5_cfg_mode;
  logic [1:0] w_o_ch5_cfg_edge_sel;
  logic [2:0] w_o_ch5_cfg_sample_div;
  logic [3:0] w_o_ch5_cfg_sample_n;
  logic [1:0] w_o_ch5_cfg_cmp_action;
  logic w_o_ch5_cfg_out_pol;
  logic w_o_ch5_cfg_idle_level;
  logic w_o_ch5_cfg_force_en;
  logic w_o_ch5_cfg_force_val;
  logic w_o_ch5_cfg_timeout_en;
  logic w_o_ch5_cfg_tout_start;
  logic [2:0] w_o_ch5_cfg_trig_sel;
  logic w_o_ch5_cfg_sw_arm_en;
  logic w_o_ch5_cfg_arm_cmd;
  logic [2:0] w_o_ch6_cfg_mode;
  logic [1:0] w_o_ch6_cfg_edge_sel;
  logic [2:0] w_o_ch6_cfg_sample_div;
  logic [3:0] w_o_ch6_cfg_sample_n;
  logic [1:0] w_o_ch6_cfg_cmp_action;
  logic w_o_ch6_cfg_out_pol;
  logic w_o_ch6_cfg_idle_level;
  logic w_o_ch6_cfg_force_en;
  logic w_o_ch6_cfg_force_val;
  logic w_o_ch6_cfg_timeout_en;
  logic w_o_ch6_cfg_tout_start;
  logic [2:0] w_o_ch6_cfg_trig_sel;
  logic w_o_ch6_cfg_sw_arm_en;
  logic w_o_ch6_cfg_arm_cmd;
  logic [2:0] w_o_ch7_cfg_mode;
  logic [1:0] w_o_ch7_cfg_edge_sel;
  logic [2:0] w_o_ch7_cfg_sample_div;
  logic [3:0] w_o_ch7_cfg_sample_n;
  logic [1:0] w_o_ch7_cfg_cmp_action;
  logic w_o_ch7_cfg_out_pol;
  logic w_o_ch7_cfg_idle_level;
  logic w_o_ch7_cfg_force_en;
  logic w_o_ch7_cfg_force_val;
  logic w_o_ch7_cfg_timeout_en;
  logic w_o_ch7_cfg_tout_start;
  logic [2:0] w_o_ch7_cfg_trig_sel;
  logic w_o_ch7_cfg_sw_arm_en;
  logic w_o_ch7_cfg_arm_cmd;
  logic [31:0] w_o_ch0_cmp_value;
  logic [31:0] w_o_c0_cmp_h_hi;
  logic [31:0] w_o_ch1_cmp_value;
  logic [31:0] w_o_c1_cmp_h_hi;
  logic [31:0] w_o_ch2_cmp_value;
  logic [31:0] w_o_c2_cmp_h_hi;
  logic [31:0] w_o_ch3_cmp_value;
  logic [31:0] w_o_c3_cmp_h_hi;
  logic [31:0] w_o_ch4_cmp_value;
  logic [31:0] w_o_c4_cmp_h_hi;
  logic [31:0] w_o_ch5_cmp_value;
  logic [31:0] w_o_c5_cmp_h_hi;
  logic [31:0] w_o_ch6_cmp_value;
  logic [31:0] w_o_c6_cmp_h_hi;
  logic [31:0] w_o_ch7_cmp_value;
  logic [31:0] w_o_c7_cmp_h_hi;
  logic [31:0] w_i_cnt_value;
  logic [31:0] w_i_cnt_hi_hi;
  logic [3:0] w_i_cap_lvl_lvl_ch0;
  logic [3:0] w_i_cap_lvl_lvl_ch1;
  logic [3:0] w_i_cap_lvl_lvl_ch2;
  logic [3:0] w_i_cap_lvl_lvl_ch3;
  logic [3:0] w_i_cap_lvl_lvl_ch4;
  logic [3:0] w_i_cap_lvl_lvl_ch5;
  logic [3:0] w_i_cap_lvl_lvl_ch6;
  logic [3:0] w_i_cap_lvl_lvl_ch7;
  logic [2:0] w_i_dma_lvl_cap_lvl;
  logic [2:0] w_i_dma_lvl_cmp_lvl;
  logic [2:0] w_i_dma_lvl_cap_reserved;
  logic [2:0] w_i_dma_lvl_cmp_reserved;
  logic w_i_opm_sts_busy_ch0;
  logic w_i_opm_sts_busy_ch1;
  logic w_i_opm_sts_busy_ch2;
  logic w_i_opm_sts_busy_ch3;
  logic w_i_opm_sts_busy_ch4;
  logic w_i_opm_sts_busy_ch5;
  logic w_i_opm_sts_busy_ch6;
  logic w_i_opm_sts_busy_ch7;
  logic w_i_opm_sts_armed_ch0;
  logic w_i_opm_sts_armed_ch1;
  logic w_i_opm_sts_armed_ch2;
  logic w_i_opm_sts_armed_ch3;
  logic w_i_opm_sts_armed_ch4;
  logic w_i_opm_sts_armed_ch5;
  logic w_i_opm_sts_armed_ch6;
  logic w_i_opm_sts_armed_ch7;
  logic w_o_irq_raw0_cap0;
  logic w_hw_d_irq_raw0_cap0;
  logic w_hw_we_irq_raw0_cap0;
  logic w_o_irq_raw0_cap1;
  logic w_hw_d_irq_raw0_cap1;
  logic w_hw_we_irq_raw0_cap1;
  logic w_o_irq_raw0_cap2;
  logic w_hw_d_irq_raw0_cap2;
  logic w_hw_we_irq_raw0_cap2;
  logic w_o_irq_raw0_cap3;
  logic w_hw_d_irq_raw0_cap3;
  logic w_hw_we_irq_raw0_cap3;
  logic w_o_irq_raw0_cap4;
  logic w_hw_d_irq_raw0_cap4;
  logic w_hw_we_irq_raw0_cap4;
  logic w_o_irq_raw0_cap5;
  logic w_hw_d_irq_raw0_cap5;
  logic w_hw_we_irq_raw0_cap5;
  logic w_o_irq_raw0_cap6;
  logic w_hw_d_irq_raw0_cap6;
  logic w_hw_we_irq_raw0_cap6;
  logic w_o_irq_raw0_cap7;
  logic w_hw_d_irq_raw0_cap7;
  logic w_hw_we_irq_raw0_cap7;
  logic w_o_irq_raw0_ovf0;
  logic w_hw_d_irq_raw0_ovf0;
  logic w_hw_we_irq_raw0_ovf0;
  logic w_o_irq_raw0_ovf1;
  logic w_hw_d_irq_raw0_ovf1;
  logic w_hw_we_irq_raw0_ovf1;
  logic w_o_irq_raw0_ovf2;
  logic w_hw_d_irq_raw0_ovf2;
  logic w_hw_we_irq_raw0_ovf2;
  logic w_o_irq_raw0_ovf3;
  logic w_hw_d_irq_raw0_ovf3;
  logic w_hw_we_irq_raw0_ovf3;
  logic w_o_irq_raw0_ovf4;
  logic w_hw_d_irq_raw0_ovf4;
  logic w_hw_we_irq_raw0_ovf4;
  logic w_o_irq_raw0_ovf5;
  logic w_hw_d_irq_raw0_ovf5;
  logic w_hw_we_irq_raw0_ovf5;
  logic w_o_irq_raw0_ovf6;
  logic w_hw_d_irq_raw0_ovf6;
  logic w_hw_we_irq_raw0_ovf6;
  logic w_o_irq_raw0_ovf7;
  logic w_hw_d_irq_raw0_ovf7;
  logic w_hw_we_irq_raw0_ovf7;
  logic w_o_irq_raw0_cmp0;
  logic w_hw_d_irq_raw0_cmp0;
  logic w_hw_we_irq_raw0_cmp0;
  logic w_o_irq_raw0_cmp1;
  logic w_hw_d_irq_raw0_cmp1;
  logic w_hw_we_irq_raw0_cmp1;
  logic w_o_irq_raw0_cmp2;
  logic w_hw_d_irq_raw0_cmp2;
  logic w_hw_we_irq_raw0_cmp2;
  logic w_o_irq_raw0_cmp3;
  logic w_hw_d_irq_raw0_cmp3;
  logic w_hw_we_irq_raw0_cmp3;
  logic w_o_irq_raw0_cmp4;
  logic w_hw_d_irq_raw0_cmp4;
  logic w_hw_we_irq_raw0_cmp4;
  logic w_o_irq_raw0_cmp5;
  logic w_hw_d_irq_raw0_cmp5;
  logic w_hw_we_irq_raw0_cmp5;
  logic w_o_irq_raw0_cmp6;
  logic w_hw_d_irq_raw0_cmp6;
  logic w_hw_we_irq_raw0_cmp6;
  logic w_o_irq_raw0_cmp7;
  logic w_hw_d_irq_raw0_cmp7;
  logic w_hw_we_irq_raw0_cmp7;
  logic w_o_irq_raw0_tout0;
  logic w_hw_d_irq_raw0_tout0;
  logic w_hw_we_irq_raw0_tout0;
  logic w_o_irq_raw0_tout1;
  logic w_hw_d_irq_raw0_tout1;
  logic w_hw_we_irq_raw0_tout1;
  logic w_o_irq_raw0_tout2;
  logic w_hw_d_irq_raw0_tout2;
  logic w_hw_we_irq_raw0_tout2;
  logic w_o_irq_raw0_tout3;
  logic w_hw_d_irq_raw0_tout3;
  logic w_hw_we_irq_raw0_tout3;
  logic w_o_irq_raw0_tout4;
  logic w_hw_d_irq_raw0_tout4;
  logic w_hw_we_irq_raw0_tout4;
  logic w_o_irq_raw0_tout5;
  logic w_hw_d_irq_raw0_tout5;
  logic w_hw_we_irq_raw0_tout5;
  logic w_o_irq_raw0_tout6;
  logic w_hw_d_irq_raw0_tout6;
  logic w_hw_we_irq_raw0_tout6;
  logic w_o_irq_raw0_tout7;
  logic w_hw_d_irq_raw0_tout7;
  logic w_hw_we_irq_raw0_tout7;
  logic w_o_irq_en0_cap0;
  logic w_o_irq_en0_cap1;
  logic w_o_irq_en0_cap2;
  logic w_o_irq_en0_cap3;
  logic w_o_irq_en0_cap4;
  logic w_o_irq_en0_cap5;
  logic w_o_irq_en0_cap6;
  logic w_o_irq_en0_cap7;
  logic w_o_irq_en0_ovf0;
  logic w_o_irq_en0_ovf1;
  logic w_o_irq_en0_ovf2;
  logic w_o_irq_en0_ovf3;
  logic w_o_irq_en0_ovf4;
  logic w_o_irq_en0_ovf5;
  logic w_o_irq_en0_ovf6;
  logic w_o_irq_en0_ovf7;
  logic w_o_irq_en0_cmp0;
  logic w_o_irq_en0_cmp1;
  logic w_o_irq_en0_cmp2;
  logic w_o_irq_en0_cmp3;
  logic w_o_irq_en0_cmp4;
  logic w_o_irq_en0_cmp5;
  logic w_o_irq_en0_cmp6;
  logic w_o_irq_en0_cmp7;
  logic w_o_irq_en0_tout0;
  logic w_o_irq_en0_tout1;
  logic w_o_irq_en0_tout2;
  logic w_o_irq_en0_tout3;
  logic w_o_irq_en0_tout4;
  logic w_o_irq_en0_tout5;
  logic w_o_irq_en0_tout6;
  logic w_o_irq_en0_tout7;
  logic w_o_irq_inj0_cap0;
  logic w_o_irq_inj0_cap1;
  logic w_o_irq_inj0_cap2;
  logic w_o_irq_inj0_cap3;
  logic w_o_irq_inj0_cap4;
  logic w_o_irq_inj0_cap5;
  logic w_o_irq_inj0_cap6;
  logic w_o_irq_inj0_cap7;
  logic w_o_irq_inj0_ovf0;
  logic w_o_irq_inj0_ovf1;
  logic w_o_irq_inj0_ovf2;
  logic w_o_irq_inj0_ovf3;
  logic w_o_irq_inj0_ovf4;
  logic w_o_irq_inj0_ovf5;
  logic w_o_irq_inj0_ovf6;
  logic w_o_irq_inj0_ovf7;
  logic w_o_irq_inj0_cmp0;
  logic w_o_irq_inj0_cmp1;
  logic w_o_irq_inj0_cmp2;
  logic w_o_irq_inj0_cmp3;
  logic w_o_irq_inj0_cmp4;
  logic w_o_irq_inj0_cmp5;
  logic w_o_irq_inj0_cmp6;
  logic w_o_irq_inj0_cmp7;
  logic w_o_irq_inj0_tout0;
  logic w_o_irq_inj0_tout1;
  logic w_o_irq_inj0_tout2;
  logic w_o_irq_inj0_tout3;
  logic w_o_irq_inj0_tout4;
  logic w_o_irq_inj0_tout5;
  logic w_o_irq_inj0_tout6;
  logic w_o_irq_inj0_tout7;
  logic w_i_irq_sts0_cap0;
  logic w_i_irq_sts0_cap1;
  logic w_i_irq_sts0_cap2;
  logic w_i_irq_sts0_cap3;
  logic w_i_irq_sts0_cap4;
  logic w_i_irq_sts0_cap5;
  logic w_i_irq_sts0_cap6;
  logic w_i_irq_sts0_cap7;
  logic w_i_irq_sts0_ovf0;
  logic w_i_irq_sts0_ovf1;
  logic w_i_irq_sts0_ovf2;
  logic w_i_irq_sts0_ovf3;
  logic w_i_irq_sts0_ovf4;
  logic w_i_irq_sts0_ovf5;
  logic w_i_irq_sts0_ovf6;
  logic w_i_irq_sts0_ovf7;
  logic w_i_irq_sts0_cmp0;
  logic w_i_irq_sts0_cmp1;
  logic w_i_irq_sts0_cmp2;
  logic w_i_irq_sts0_cmp3;
  logic w_i_irq_sts0_cmp4;
  logic w_i_irq_sts0_cmp5;
  logic w_i_irq_sts0_cmp6;
  logic w_i_irq_sts0_cmp7;
  logic w_i_irq_sts0_tout0;
  logic w_i_irq_sts0_tout1;
  logic w_i_irq_sts0_tout2;
  logic w_i_irq_sts0_tout3;
  logic w_i_irq_sts0_tout4;
  logic w_i_irq_sts0_tout5;
  logic w_i_irq_sts0_tout6;
  logic w_i_irq_sts0_tout7;
  logic w_o_irq_raw1_upd;
  logic w_hw_d_irq_raw1_upd;
  logic w_hw_we_irq_raw1_upd;
  logic w_o_irq_raw1_cqovf;
  logic w_hw_d_irq_raw1_cqovf;
  logic w_hw_we_irq_raw1_cqovf;
  logic w_o_irq_raw1_mqovf;
  logic w_hw_d_irq_raw1_mqovf;
  logic w_hw_we_irq_raw1_mqovf;
  logic w_o_irq_raw1_dperr;
  logic w_hw_d_irq_raw1_dperr;
  logic w_hw_we_irq_raw1_dperr;
  logic w_o_irq_raw1_pwm0;
  logic w_hw_d_irq_raw1_pwm0;
  logic w_hw_we_irq_raw1_pwm0;
  logic w_o_irq_raw1_pwm1;
  logic w_hw_d_irq_raw1_pwm1;
  logic w_hw_we_irq_raw1_pwm1;
  logic w_o_irq_raw1_pwm2;
  logic w_hw_d_irq_raw1_pwm2;
  logic w_hw_we_irq_raw1_pwm2;
  logic w_o_irq_raw1_pwm3;
  logic w_hw_d_irq_raw1_pwm3;
  logic w_hw_we_irq_raw1_pwm3;
  logic w_o_irq_en1_upd;
  logic w_o_irq_en1_cqovf;
  logic w_o_irq_en1_mqovf;
  logic w_o_irq_en1_dperr;
  logic w_o_irq_en1_pwm0;
  logic w_o_irq_en1_pwm1;
  logic w_o_irq_en1_pwm2;
  logic w_o_irq_en1_pwm3;
  logic w_o_irq_inj1_upd;
  logic w_o_irq_inj1_cqovf;
  logic w_o_irq_inj1_mqovf;
  logic w_o_irq_inj1_dperr;
  logic w_o_irq_inj1_pwm0;
  logic w_o_irq_inj1_pwm1;
  logic w_o_irq_inj1_pwm2;
  logic w_o_irq_inj1_pwm3;
  logic w_i_irq_sts1_upd;
  logic w_i_irq_sts1_cqovf;
  logic w_i_irq_sts1_mqovf;
  logic w_i_irq_sts1_dperr;
  logic w_i_irq_sts1_pwm0;
  logic w_i_irq_sts1_pwm1;
  logic w_i_irq_sts1_pwm2;
  logic w_i_irq_sts1_pwm3;
  logic [31:0] w_o_c0_tout_thr;
  logic [31:0] w_o_c0_tout_h_hi;
  logic [31:0] w_o_c1_tout_thr;
  logic [31:0] w_o_c1_tout_h_hi;
  logic [31:0] w_o_c2_tout_thr;
  logic [31:0] w_o_c2_tout_h_hi;
  logic [31:0] w_o_c3_tout_thr;
  logic [31:0] w_o_c3_tout_h_hi;
  logic [31:0] w_o_c4_tout_thr;
  logic [31:0] w_o_c4_tout_h_hi;
  logic [31:0] w_o_c5_tout_thr;
  logic [31:0] w_o_c5_tout_h_hi;
  logic [31:0] w_o_c6_tout_thr;
  logic [31:0] w_o_c6_tout_h_hi;
  logic [31:0] w_o_c7_tout_thr;
  logic [31:0] w_o_c7_tout_h_hi;
  logic [2:0] w_o_pi_cfg_pair0_input;
  logic w_o_pi_cfg_low0;
  logic w_o_pi_cfg_pair0_en;
  logic [2:0] w_o_pi_cfg_pair1_input;
  logic w_o_pi_cfg_low1;
  logic w_o_pi_cfg_pair1_en;
  logic [2:0] w_o_pi_cfg_pair2_input;
  logic w_o_pi_cfg_low2;
  logic w_o_pi_cfg_pair2_en;
  logic [2:0] w_o_pi_cfg_pair3_input;
  logic w_o_pi_cfg_low3;
  logic w_o_pi_cfg_pair3_en;
  logic [31:0] w_i_p0_per_value;
  logic [31:0] w_i_p0_per_h_hi;
  logic [31:0] w_i_p0_wid_value;
  logic [31:0] w_i_p0_wid_h_hi;
  logic [31:0] w_i_p1_per_value;
  logic [31:0] w_i_p1_per_h_hi;
  logic [31:0] w_i_p1_wid_value;
  logic [31:0] w_i_p1_wid_h_hi;
  logic [31:0] w_i_p2_per_value;
  logic [31:0] w_i_p2_per_h_hi;
  logic [31:0] w_i_p2_wid_value;
  logic [31:0] w_i_p2_wid_h_hi;
  logic [31:0] w_i_p3_per_value;
  logic [31:0] w_i_p3_per_h_hi;
  logic [31:0] w_i_p3_wid_value;
  logic [31:0] w_i_p3_wid_h_hi;
  logic w_o_pi_sts_valid0;
  logic w_hw_d_pi_sts_valid0;
  logic w_hw_we_pi_sts_valid0;
  logic w_o_pi_sts_valid1;
  logic w_hw_d_pi_sts_valid1;
  logic w_hw_we_pi_sts_valid1;
  logic w_o_pi_sts_valid2;
  logic w_hw_d_pi_sts_valid2;
  logic w_hw_we_pi_sts_valid2;
  logic w_o_pi_sts_valid3;
  logic w_hw_d_pi_sts_valid3;
  logic w_hw_we_pi_sts_valid3;
  logic w_o_pi_sts_ovr0;
  logic w_hw_d_pi_sts_ovr0;
  logic w_hw_we_pi_sts_ovr0;
  logic w_o_pi_sts_ovr1;
  logic w_hw_d_pi_sts_ovr1;
  logic w_hw_we_pi_sts_ovr1;
  logic w_o_pi_sts_ovr2;
  logic w_hw_d_pi_sts_ovr2;
  logic w_hw_we_pi_sts_ovr2;
  logic w_o_pi_sts_ovr3;
  logic w_hw_d_pi_sts_ovr3;
  logic w_hw_we_pi_sts_ovr3;
  logic [31:0] w_o_c0_ow_width;
  logic [31:0] w_o_c0_ow_h_hi;
  logic [31:0] w_o_c1_ow_width;
  logic [31:0] w_o_c1_ow_h_hi;
  logic [31:0] w_o_c2_ow_width;
  logic [31:0] w_o_c2_ow_h_hi;
  logic [31:0] w_o_c3_ow_width;
  logic [31:0] w_o_c3_ow_h_hi;
  logic [31:0] w_o_c4_ow_width;
  logic [31:0] w_o_c4_ow_h_hi;
  logic [31:0] w_o_c5_ow_width;
  logic [31:0] w_o_c5_ow_h_hi;
  logic [31:0] w_o_c6_ow_width;
  logic [31:0] w_o_c6_ow_h_hi;
  logic [31:0] w_o_c7_ow_width;
  logic [31:0] w_o_c7_ow_h_hi;
  logic w_i_dma_sts_cap_req;
  logic w_i_dma_sts_cap_burst;
  logic w_i_dma_sts_cap_clr_busy;
  logic w_i_dma_sts_cmp_req;
  logic w_i_dma_sts_cmp_burst;
  logic w_i_dma_sts_cmp_clr_busy;
  logic w_o_dma_cfg_cap_clr;
  logic w_o_dma_cfg_cmp_clr;
  logic w_dma_cap_clr_done;
  logic w_dma_cmp_clr_done;

  // Reset release is synchronized locally in each destination domain.
  m_vlsit_rst_sync u_apb_rst_sync (
    .i_clk_dst   (i_clk_apb),
    .i_rst_n_src (i_rst_n_apb),
    .o_rst_n_dst (w_rst_n_apb)
  );

  m_vlsit_rst_sync u_timer_rst_sync (
    .i_clk_dst   (i_clk_timer),
    .i_rst_n_src (i_rst_n_timer),
    .o_rst_n_dst (w_rst_n_timer)
  );

  // APB address dispatch keeps the DMA-owned stream windows outside generated CSR logic.
  assign w_stream_sel = i_psel_apb & ((i_paddr_apb == 16'h0200) | (i_paddr_apb == 16'h0204));
  assign w_csr_psel = i_psel_apb & ~w_stream_sel;

  // Generated register bank; the APB side can cross independently to the Timer register clock.
  m_vlsit_csr_timer #(
    .PARA_ASYNCHRONOUS (PARA_ASYNC)
  ) u_timer_csr (
    .i_clk_apb (i_clk_apb),
    .i_rst_n_apb (w_rst_n_apb),
    .i_clk_reg (i_clk_timer),
    .i_rst_n_reg (w_rst_n_timer),
    .i_apb_psel (w_csr_psel),
    .i_apb_penable (i_penable_apb),
    .i_apb_pwrite (i_pwrite_apb),
    .i_apb_paddr (i_paddr_apb),
    .i_apb_pwdata (i_pwdata_apb),
    .i_apb_pstrb (i_pstrb_apb),
    .i_apb_pprot (i_pprot_apb),
    .o_apb_pready (w_csr_o_apb_pready),
    .o_apb_pslverr (w_csr_o_apb_pslverr),
    .o_apb_prdata (w_csr_o_apb_prdata),
    .i_protect_en (1'b0),
    .i_slverr_en (1'b1),
    .o_reg_rd_en (w_csr_o_reg_rd_en),
    .o_reg_rd_addr (w_csr_o_reg_rd_addr),
    .o_reg_wr_en (w_csr_o_reg_wr_en),
    .o_reg_wr_addr (w_csr_o_reg_wr_addr),
    .o_tmr_ctrl_timer_en (w_o_ctrl_timer_en),
    .o_tmr_ctrl_dir_down (w_o_ctrl_dir_down),
    .o_tmr_period_period (w_o_period_period),
    .o_tmr_period_hi_period_hi (w_o_period_hi_period_hi),
    .o_tmr_prescale_psc (w_o_prescale_psc),
    .o_tmr_dma_cfg_cap_rec_cnt (w_o_dma_cfg_cap_rec_cnt),
    .o_tmr_dma_cfg_cmp_rec_cnt (w_o_dma_cfg_cmp_rec_cnt),
    .o_tmr_dma_cfg_cap_clr (w_o_dma_cfg_cap_clr),
    .i_hw_wdata_tmr_dma_cfg_cap_clr (1'b0),
    .i_hw_we_tmr_dma_cfg_cap_clr (w_dma_cap_clr_done),
    .o_tmr_dma_cfg_cmp_clr (w_o_dma_cfg_cmp_clr),
    .i_hw_wdata_tmr_dma_cfg_cmp_clr (1'b0),
    .i_hw_we_tmr_dma_cfg_cmp_clr (w_dma_cmp_clr_done),
    .o_tmr_ch0_cfg_mode (w_o_ch0_cfg_mode),
    .o_tmr_ch0_cfg_edge_sel (w_o_ch0_cfg_edge_sel),
    .o_tmr_ch0_cfg_sample_div (w_o_ch0_cfg_sample_div),
    .o_tmr_ch0_cfg_sample_n (w_o_ch0_cfg_sample_n),
    .o_tmr_ch0_cfg_cmp_action (w_o_ch0_cfg_cmp_action),
    .o_tmr_ch0_cfg_out_pol (w_o_ch0_cfg_out_pol),
    .o_tmr_ch0_cfg_idle_level (w_o_ch0_cfg_idle_level),
    .o_tmr_ch0_cfg_force_en (w_o_ch0_cfg_force_en),
    .o_tmr_ch0_cfg_force_val (w_o_ch0_cfg_force_val),
    .o_tmr_ch0_cfg_timeout_en (w_o_ch0_cfg_timeout_en),
    .o_tmr_ch0_cfg_tout_start (w_o_ch0_cfg_tout_start),
    .o_tmr_ch0_cfg_trig_sel (w_o_ch0_cfg_trig_sel),
    .o_tmr_ch0_cfg_sw_arm_en (w_o_ch0_cfg_sw_arm_en),
    .o_tmr_ch0_cfg_arm_cmd (w_o_ch0_cfg_arm_cmd),
    .o_tmr_ch1_cfg_mode (w_o_ch1_cfg_mode),
    .o_tmr_ch1_cfg_edge_sel (w_o_ch1_cfg_edge_sel),
    .o_tmr_ch1_cfg_sample_div (w_o_ch1_cfg_sample_div),
    .o_tmr_ch1_cfg_sample_n (w_o_ch1_cfg_sample_n),
    .o_tmr_ch1_cfg_cmp_action (w_o_ch1_cfg_cmp_action),
    .o_tmr_ch1_cfg_out_pol (w_o_ch1_cfg_out_pol),
    .o_tmr_ch1_cfg_idle_level (w_o_ch1_cfg_idle_level),
    .o_tmr_ch1_cfg_force_en (w_o_ch1_cfg_force_en),
    .o_tmr_ch1_cfg_force_val (w_o_ch1_cfg_force_val),
    .o_tmr_ch1_cfg_timeout_en (w_o_ch1_cfg_timeout_en),
    .o_tmr_ch1_cfg_tout_start (w_o_ch1_cfg_tout_start),
    .o_tmr_ch1_cfg_trig_sel (w_o_ch1_cfg_trig_sel),
    .o_tmr_ch1_cfg_sw_arm_en (w_o_ch1_cfg_sw_arm_en),
    .o_tmr_ch1_cfg_arm_cmd (w_o_ch1_cfg_arm_cmd),
    .o_tmr_ch2_cfg_mode (w_o_ch2_cfg_mode),
    .o_tmr_ch2_cfg_edge_sel (w_o_ch2_cfg_edge_sel),
    .o_tmr_ch2_cfg_sample_div (w_o_ch2_cfg_sample_div),
    .o_tmr_ch2_cfg_sample_n (w_o_ch2_cfg_sample_n),
    .o_tmr_ch2_cfg_cmp_action (w_o_ch2_cfg_cmp_action),
    .o_tmr_ch2_cfg_out_pol (w_o_ch2_cfg_out_pol),
    .o_tmr_ch2_cfg_idle_level (w_o_ch2_cfg_idle_level),
    .o_tmr_ch2_cfg_force_en (w_o_ch2_cfg_force_en),
    .o_tmr_ch2_cfg_force_val (w_o_ch2_cfg_force_val),
    .o_tmr_ch2_cfg_timeout_en (w_o_ch2_cfg_timeout_en),
    .o_tmr_ch2_cfg_tout_start (w_o_ch2_cfg_tout_start),
    .o_tmr_ch2_cfg_trig_sel (w_o_ch2_cfg_trig_sel),
    .o_tmr_ch2_cfg_sw_arm_en (w_o_ch2_cfg_sw_arm_en),
    .o_tmr_ch2_cfg_arm_cmd (w_o_ch2_cfg_arm_cmd),
    .o_tmr_ch3_cfg_mode (w_o_ch3_cfg_mode),
    .o_tmr_ch3_cfg_edge_sel (w_o_ch3_cfg_edge_sel),
    .o_tmr_ch3_cfg_sample_div (w_o_ch3_cfg_sample_div),
    .o_tmr_ch3_cfg_sample_n (w_o_ch3_cfg_sample_n),
    .o_tmr_ch3_cfg_cmp_action (w_o_ch3_cfg_cmp_action),
    .o_tmr_ch3_cfg_out_pol (w_o_ch3_cfg_out_pol),
    .o_tmr_ch3_cfg_idle_level (w_o_ch3_cfg_idle_level),
    .o_tmr_ch3_cfg_force_en (w_o_ch3_cfg_force_en),
    .o_tmr_ch3_cfg_force_val (w_o_ch3_cfg_force_val),
    .o_tmr_ch3_cfg_timeout_en (w_o_ch3_cfg_timeout_en),
    .o_tmr_ch3_cfg_tout_start (w_o_ch3_cfg_tout_start),
    .o_tmr_ch3_cfg_trig_sel (w_o_ch3_cfg_trig_sel),
    .o_tmr_ch3_cfg_sw_arm_en (w_o_ch3_cfg_sw_arm_en),
    .o_tmr_ch3_cfg_arm_cmd (w_o_ch3_cfg_arm_cmd),
    .o_tmr_ch4_cfg_mode (w_o_ch4_cfg_mode),
    .o_tmr_ch4_cfg_edge_sel (w_o_ch4_cfg_edge_sel),
    .o_tmr_ch4_cfg_sample_div (w_o_ch4_cfg_sample_div),
    .o_tmr_ch4_cfg_sample_n (w_o_ch4_cfg_sample_n),
    .o_tmr_ch4_cfg_cmp_action (w_o_ch4_cfg_cmp_action),
    .o_tmr_ch4_cfg_out_pol (w_o_ch4_cfg_out_pol),
    .o_tmr_ch4_cfg_idle_level (w_o_ch4_cfg_idle_level),
    .o_tmr_ch4_cfg_force_en (w_o_ch4_cfg_force_en),
    .o_tmr_ch4_cfg_force_val (w_o_ch4_cfg_force_val),
    .o_tmr_ch4_cfg_timeout_en (w_o_ch4_cfg_timeout_en),
    .o_tmr_ch4_cfg_tout_start (w_o_ch4_cfg_tout_start),
    .o_tmr_ch4_cfg_trig_sel (w_o_ch4_cfg_trig_sel),
    .o_tmr_ch4_cfg_sw_arm_en (w_o_ch4_cfg_sw_arm_en),
    .o_tmr_ch4_cfg_arm_cmd (w_o_ch4_cfg_arm_cmd),
    .o_tmr_ch5_cfg_mode (w_o_ch5_cfg_mode),
    .o_tmr_ch5_cfg_edge_sel (w_o_ch5_cfg_edge_sel),
    .o_tmr_ch5_cfg_sample_div (w_o_ch5_cfg_sample_div),
    .o_tmr_ch5_cfg_sample_n (w_o_ch5_cfg_sample_n),
    .o_tmr_ch5_cfg_cmp_action (w_o_ch5_cfg_cmp_action),
    .o_tmr_ch5_cfg_out_pol (w_o_ch5_cfg_out_pol),
    .o_tmr_ch5_cfg_idle_level (w_o_ch5_cfg_idle_level),
    .o_tmr_ch5_cfg_force_en (w_o_ch5_cfg_force_en),
    .o_tmr_ch5_cfg_force_val (w_o_ch5_cfg_force_val),
    .o_tmr_ch5_cfg_timeout_en (w_o_ch5_cfg_timeout_en),
    .o_tmr_ch5_cfg_tout_start (w_o_ch5_cfg_tout_start),
    .o_tmr_ch5_cfg_trig_sel (w_o_ch5_cfg_trig_sel),
    .o_tmr_ch5_cfg_sw_arm_en (w_o_ch5_cfg_sw_arm_en),
    .o_tmr_ch5_cfg_arm_cmd (w_o_ch5_cfg_arm_cmd),
    .o_tmr_ch6_cfg_mode (w_o_ch6_cfg_mode),
    .o_tmr_ch6_cfg_edge_sel (w_o_ch6_cfg_edge_sel),
    .o_tmr_ch6_cfg_sample_div (w_o_ch6_cfg_sample_div),
    .o_tmr_ch6_cfg_sample_n (w_o_ch6_cfg_sample_n),
    .o_tmr_ch6_cfg_cmp_action (w_o_ch6_cfg_cmp_action),
    .o_tmr_ch6_cfg_out_pol (w_o_ch6_cfg_out_pol),
    .o_tmr_ch6_cfg_idle_level (w_o_ch6_cfg_idle_level),
    .o_tmr_ch6_cfg_force_en (w_o_ch6_cfg_force_en),
    .o_tmr_ch6_cfg_force_val (w_o_ch6_cfg_force_val),
    .o_tmr_ch6_cfg_timeout_en (w_o_ch6_cfg_timeout_en),
    .o_tmr_ch6_cfg_tout_start (w_o_ch6_cfg_tout_start),
    .o_tmr_ch6_cfg_trig_sel (w_o_ch6_cfg_trig_sel),
    .o_tmr_ch6_cfg_sw_arm_en (w_o_ch6_cfg_sw_arm_en),
    .o_tmr_ch6_cfg_arm_cmd (w_o_ch6_cfg_arm_cmd),
    .o_tmr_ch7_cfg_mode (w_o_ch7_cfg_mode),
    .o_tmr_ch7_cfg_edge_sel (w_o_ch7_cfg_edge_sel),
    .o_tmr_ch7_cfg_sample_div (w_o_ch7_cfg_sample_div),
    .o_tmr_ch7_cfg_sample_n (w_o_ch7_cfg_sample_n),
    .o_tmr_ch7_cfg_cmp_action (w_o_ch7_cfg_cmp_action),
    .o_tmr_ch7_cfg_out_pol (w_o_ch7_cfg_out_pol),
    .o_tmr_ch7_cfg_idle_level (w_o_ch7_cfg_idle_level),
    .o_tmr_ch7_cfg_force_en (w_o_ch7_cfg_force_en),
    .o_tmr_ch7_cfg_force_val (w_o_ch7_cfg_force_val),
    .o_tmr_ch7_cfg_timeout_en (w_o_ch7_cfg_timeout_en),
    .o_tmr_ch7_cfg_tout_start (w_o_ch7_cfg_tout_start),
    .o_tmr_ch7_cfg_trig_sel (w_o_ch7_cfg_trig_sel),
    .o_tmr_ch7_cfg_sw_arm_en (w_o_ch7_cfg_sw_arm_en),
    .o_tmr_ch7_cfg_arm_cmd (w_o_ch7_cfg_arm_cmd),
    .o_tmr_ch0_cmp_value (w_o_ch0_cmp_value),
    .o_tmr_c0_cmp_h_hi (w_o_c0_cmp_h_hi),
    .o_tmr_ch1_cmp_value (w_o_ch1_cmp_value),
    .o_tmr_c1_cmp_h_hi (w_o_c1_cmp_h_hi),
    .o_tmr_ch2_cmp_value (w_o_ch2_cmp_value),
    .o_tmr_c2_cmp_h_hi (w_o_c2_cmp_h_hi),
    .o_tmr_ch3_cmp_value (w_o_ch3_cmp_value),
    .o_tmr_c3_cmp_h_hi (w_o_c3_cmp_h_hi),
    .o_tmr_ch4_cmp_value (w_o_ch4_cmp_value),
    .o_tmr_c4_cmp_h_hi (w_o_c4_cmp_h_hi),
    .o_tmr_ch5_cmp_value (w_o_ch5_cmp_value),
    .o_tmr_c5_cmp_h_hi (w_o_c5_cmp_h_hi),
    .o_tmr_ch6_cmp_value (w_o_ch6_cmp_value),
    .o_tmr_c6_cmp_h_hi (w_o_c6_cmp_h_hi),
    .o_tmr_ch7_cmp_value (w_o_ch7_cmp_value),
    .o_tmr_c7_cmp_h_hi (w_o_c7_cmp_h_hi),
    .i_tmr_cnt_value (w_i_cnt_value),
    .i_tmr_cnt_hi_hi (w_i_cnt_hi_hi),
    .i_tmr_cap_lvl_lvl_ch0 (w_i_cap_lvl_lvl_ch0),
    .i_tmr_cap_lvl_lvl_ch1 (w_i_cap_lvl_lvl_ch1),
    .i_tmr_cap_lvl_lvl_ch2 (w_i_cap_lvl_lvl_ch2),
    .i_tmr_cap_lvl_lvl_ch3 (w_i_cap_lvl_lvl_ch3),
    .i_tmr_cap_lvl_lvl_ch4 (w_i_cap_lvl_lvl_ch4),
    .i_tmr_cap_lvl_lvl_ch5 (w_i_cap_lvl_lvl_ch5),
    .i_tmr_cap_lvl_lvl_ch6 (w_i_cap_lvl_lvl_ch6),
    .i_tmr_cap_lvl_lvl_ch7 (w_i_cap_lvl_lvl_ch7),
    .i_tmr_dma_lvl_cap_lvl (w_i_dma_lvl_cap_lvl),
    .i_tmr_dma_lvl_cmp_lvl (w_i_dma_lvl_cmp_lvl),
    .i_tmr_dma_lvl_cap_reserved (w_i_dma_lvl_cap_reserved),
    .i_tmr_dma_lvl_cmp_reserved (w_i_dma_lvl_cmp_reserved),
    .i_tmr_opm_sts_busy_ch0 (w_i_opm_sts_busy_ch0),
    .i_tmr_opm_sts_busy_ch1 (w_i_opm_sts_busy_ch1),
    .i_tmr_opm_sts_busy_ch2 (w_i_opm_sts_busy_ch2),
    .i_tmr_opm_sts_busy_ch3 (w_i_opm_sts_busy_ch3),
    .i_tmr_opm_sts_busy_ch4 (w_i_opm_sts_busy_ch4),
    .i_tmr_opm_sts_busy_ch5 (w_i_opm_sts_busy_ch5),
    .i_tmr_opm_sts_busy_ch6 (w_i_opm_sts_busy_ch6),
    .i_tmr_opm_sts_busy_ch7 (w_i_opm_sts_busy_ch7),
    .i_tmr_opm_sts_armed_ch0 (w_i_opm_sts_armed_ch0),
    .i_tmr_opm_sts_armed_ch1 (w_i_opm_sts_armed_ch1),
    .i_tmr_opm_sts_armed_ch2 (w_i_opm_sts_armed_ch2),
    .i_tmr_opm_sts_armed_ch3 (w_i_opm_sts_armed_ch3),
    .i_tmr_opm_sts_armed_ch4 (w_i_opm_sts_armed_ch4),
    .i_tmr_opm_sts_armed_ch5 (w_i_opm_sts_armed_ch5),
    .i_tmr_opm_sts_armed_ch6 (w_i_opm_sts_armed_ch6),
    .i_tmr_opm_sts_armed_ch7 (w_i_opm_sts_armed_ch7),
    .o_tmr_irq_raw0_cap0 (w_o_irq_raw0_cap0),
    .i_hw_wdata_tmr_irq_raw0_cap0 (w_hw_d_irq_raw0_cap0),
    .i_hw_we_tmr_irq_raw0_cap0 (w_hw_we_irq_raw0_cap0),
    .o_tmr_irq_raw0_cap1 (w_o_irq_raw0_cap1),
    .i_hw_wdata_tmr_irq_raw0_cap1 (w_hw_d_irq_raw0_cap1),
    .i_hw_we_tmr_irq_raw0_cap1 (w_hw_we_irq_raw0_cap1),
    .o_tmr_irq_raw0_cap2 (w_o_irq_raw0_cap2),
    .i_hw_wdata_tmr_irq_raw0_cap2 (w_hw_d_irq_raw0_cap2),
    .i_hw_we_tmr_irq_raw0_cap2 (w_hw_we_irq_raw0_cap2),
    .o_tmr_irq_raw0_cap3 (w_o_irq_raw0_cap3),
    .i_hw_wdata_tmr_irq_raw0_cap3 (w_hw_d_irq_raw0_cap3),
    .i_hw_we_tmr_irq_raw0_cap3 (w_hw_we_irq_raw0_cap3),
    .o_tmr_irq_raw0_cap4 (w_o_irq_raw0_cap4),
    .i_hw_wdata_tmr_irq_raw0_cap4 (w_hw_d_irq_raw0_cap4),
    .i_hw_we_tmr_irq_raw0_cap4 (w_hw_we_irq_raw0_cap4),
    .o_tmr_irq_raw0_cap5 (w_o_irq_raw0_cap5),
    .i_hw_wdata_tmr_irq_raw0_cap5 (w_hw_d_irq_raw0_cap5),
    .i_hw_we_tmr_irq_raw0_cap5 (w_hw_we_irq_raw0_cap5),
    .o_tmr_irq_raw0_cap6 (w_o_irq_raw0_cap6),
    .i_hw_wdata_tmr_irq_raw0_cap6 (w_hw_d_irq_raw0_cap6),
    .i_hw_we_tmr_irq_raw0_cap6 (w_hw_we_irq_raw0_cap6),
    .o_tmr_irq_raw0_cap7 (w_o_irq_raw0_cap7),
    .i_hw_wdata_tmr_irq_raw0_cap7 (w_hw_d_irq_raw0_cap7),
    .i_hw_we_tmr_irq_raw0_cap7 (w_hw_we_irq_raw0_cap7),
    .o_tmr_irq_raw0_ovf0 (w_o_irq_raw0_ovf0),
    .i_hw_wdata_tmr_irq_raw0_ovf0 (w_hw_d_irq_raw0_ovf0),
    .i_hw_we_tmr_irq_raw0_ovf0 (w_hw_we_irq_raw0_ovf0),
    .o_tmr_irq_raw0_ovf1 (w_o_irq_raw0_ovf1),
    .i_hw_wdata_tmr_irq_raw0_ovf1 (w_hw_d_irq_raw0_ovf1),
    .i_hw_we_tmr_irq_raw0_ovf1 (w_hw_we_irq_raw0_ovf1),
    .o_tmr_irq_raw0_ovf2 (w_o_irq_raw0_ovf2),
    .i_hw_wdata_tmr_irq_raw0_ovf2 (w_hw_d_irq_raw0_ovf2),
    .i_hw_we_tmr_irq_raw0_ovf2 (w_hw_we_irq_raw0_ovf2),
    .o_tmr_irq_raw0_ovf3 (w_o_irq_raw0_ovf3),
    .i_hw_wdata_tmr_irq_raw0_ovf3 (w_hw_d_irq_raw0_ovf3),
    .i_hw_we_tmr_irq_raw0_ovf3 (w_hw_we_irq_raw0_ovf3),
    .o_tmr_irq_raw0_ovf4 (w_o_irq_raw0_ovf4),
    .i_hw_wdata_tmr_irq_raw0_ovf4 (w_hw_d_irq_raw0_ovf4),
    .i_hw_we_tmr_irq_raw0_ovf4 (w_hw_we_irq_raw0_ovf4),
    .o_tmr_irq_raw0_ovf5 (w_o_irq_raw0_ovf5),
    .i_hw_wdata_tmr_irq_raw0_ovf5 (w_hw_d_irq_raw0_ovf5),
    .i_hw_we_tmr_irq_raw0_ovf5 (w_hw_we_irq_raw0_ovf5),
    .o_tmr_irq_raw0_ovf6 (w_o_irq_raw0_ovf6),
    .i_hw_wdata_tmr_irq_raw0_ovf6 (w_hw_d_irq_raw0_ovf6),
    .i_hw_we_tmr_irq_raw0_ovf6 (w_hw_we_irq_raw0_ovf6),
    .o_tmr_irq_raw0_ovf7 (w_o_irq_raw0_ovf7),
    .i_hw_wdata_tmr_irq_raw0_ovf7 (w_hw_d_irq_raw0_ovf7),
    .i_hw_we_tmr_irq_raw0_ovf7 (w_hw_we_irq_raw0_ovf7),
    .o_tmr_irq_raw0_cmp0 (w_o_irq_raw0_cmp0),
    .i_hw_wdata_tmr_irq_raw0_cmp0 (w_hw_d_irq_raw0_cmp0),
    .i_hw_we_tmr_irq_raw0_cmp0 (w_hw_we_irq_raw0_cmp0),
    .o_tmr_irq_raw0_cmp1 (w_o_irq_raw0_cmp1),
    .i_hw_wdata_tmr_irq_raw0_cmp1 (w_hw_d_irq_raw0_cmp1),
    .i_hw_we_tmr_irq_raw0_cmp1 (w_hw_we_irq_raw0_cmp1),
    .o_tmr_irq_raw0_cmp2 (w_o_irq_raw0_cmp2),
    .i_hw_wdata_tmr_irq_raw0_cmp2 (w_hw_d_irq_raw0_cmp2),
    .i_hw_we_tmr_irq_raw0_cmp2 (w_hw_we_irq_raw0_cmp2),
    .o_tmr_irq_raw0_cmp3 (w_o_irq_raw0_cmp3),
    .i_hw_wdata_tmr_irq_raw0_cmp3 (w_hw_d_irq_raw0_cmp3),
    .i_hw_we_tmr_irq_raw0_cmp3 (w_hw_we_irq_raw0_cmp3),
    .o_tmr_irq_raw0_cmp4 (w_o_irq_raw0_cmp4),
    .i_hw_wdata_tmr_irq_raw0_cmp4 (w_hw_d_irq_raw0_cmp4),
    .i_hw_we_tmr_irq_raw0_cmp4 (w_hw_we_irq_raw0_cmp4),
    .o_tmr_irq_raw0_cmp5 (w_o_irq_raw0_cmp5),
    .i_hw_wdata_tmr_irq_raw0_cmp5 (w_hw_d_irq_raw0_cmp5),
    .i_hw_we_tmr_irq_raw0_cmp5 (w_hw_we_irq_raw0_cmp5),
    .o_tmr_irq_raw0_cmp6 (w_o_irq_raw0_cmp6),
    .i_hw_wdata_tmr_irq_raw0_cmp6 (w_hw_d_irq_raw0_cmp6),
    .i_hw_we_tmr_irq_raw0_cmp6 (w_hw_we_irq_raw0_cmp6),
    .o_tmr_irq_raw0_cmp7 (w_o_irq_raw0_cmp7),
    .i_hw_wdata_tmr_irq_raw0_cmp7 (w_hw_d_irq_raw0_cmp7),
    .i_hw_we_tmr_irq_raw0_cmp7 (w_hw_we_irq_raw0_cmp7),
    .o_tmr_irq_raw0_tout0 (w_o_irq_raw0_tout0),
    .i_hw_wdata_tmr_irq_raw0_tout0 (w_hw_d_irq_raw0_tout0),
    .i_hw_we_tmr_irq_raw0_tout0 (w_hw_we_irq_raw0_tout0),
    .o_tmr_irq_raw0_tout1 (w_o_irq_raw0_tout1),
    .i_hw_wdata_tmr_irq_raw0_tout1 (w_hw_d_irq_raw0_tout1),
    .i_hw_we_tmr_irq_raw0_tout1 (w_hw_we_irq_raw0_tout1),
    .o_tmr_irq_raw0_tout2 (w_o_irq_raw0_tout2),
    .i_hw_wdata_tmr_irq_raw0_tout2 (w_hw_d_irq_raw0_tout2),
    .i_hw_we_tmr_irq_raw0_tout2 (w_hw_we_irq_raw0_tout2),
    .o_tmr_irq_raw0_tout3 (w_o_irq_raw0_tout3),
    .i_hw_wdata_tmr_irq_raw0_tout3 (w_hw_d_irq_raw0_tout3),
    .i_hw_we_tmr_irq_raw0_tout3 (w_hw_we_irq_raw0_tout3),
    .o_tmr_irq_raw0_tout4 (w_o_irq_raw0_tout4),
    .i_hw_wdata_tmr_irq_raw0_tout4 (w_hw_d_irq_raw0_tout4),
    .i_hw_we_tmr_irq_raw0_tout4 (w_hw_we_irq_raw0_tout4),
    .o_tmr_irq_raw0_tout5 (w_o_irq_raw0_tout5),
    .i_hw_wdata_tmr_irq_raw0_tout5 (w_hw_d_irq_raw0_tout5),
    .i_hw_we_tmr_irq_raw0_tout5 (w_hw_we_irq_raw0_tout5),
    .o_tmr_irq_raw0_tout6 (w_o_irq_raw0_tout6),
    .i_hw_wdata_tmr_irq_raw0_tout6 (w_hw_d_irq_raw0_tout6),
    .i_hw_we_tmr_irq_raw0_tout6 (w_hw_we_irq_raw0_tout6),
    .o_tmr_irq_raw0_tout7 (w_o_irq_raw0_tout7),
    .i_hw_wdata_tmr_irq_raw0_tout7 (w_hw_d_irq_raw0_tout7),
    .i_hw_we_tmr_irq_raw0_tout7 (w_hw_we_irq_raw0_tout7),
    .o_tmr_irq_en0_cap0 (w_o_irq_en0_cap0),
    .o_tmr_irq_en0_cap1 (w_o_irq_en0_cap1),
    .o_tmr_irq_en0_cap2 (w_o_irq_en0_cap2),
    .o_tmr_irq_en0_cap3 (w_o_irq_en0_cap3),
    .o_tmr_irq_en0_cap4 (w_o_irq_en0_cap4),
    .o_tmr_irq_en0_cap5 (w_o_irq_en0_cap5),
    .o_tmr_irq_en0_cap6 (w_o_irq_en0_cap6),
    .o_tmr_irq_en0_cap7 (w_o_irq_en0_cap7),
    .o_tmr_irq_en0_ovf0 (w_o_irq_en0_ovf0),
    .o_tmr_irq_en0_ovf1 (w_o_irq_en0_ovf1),
    .o_tmr_irq_en0_ovf2 (w_o_irq_en0_ovf2),
    .o_tmr_irq_en0_ovf3 (w_o_irq_en0_ovf3),
    .o_tmr_irq_en0_ovf4 (w_o_irq_en0_ovf4),
    .o_tmr_irq_en0_ovf5 (w_o_irq_en0_ovf5),
    .o_tmr_irq_en0_ovf6 (w_o_irq_en0_ovf6),
    .o_tmr_irq_en0_ovf7 (w_o_irq_en0_ovf7),
    .o_tmr_irq_en0_cmp0 (w_o_irq_en0_cmp0),
    .o_tmr_irq_en0_cmp1 (w_o_irq_en0_cmp1),
    .o_tmr_irq_en0_cmp2 (w_o_irq_en0_cmp2),
    .o_tmr_irq_en0_cmp3 (w_o_irq_en0_cmp3),
    .o_tmr_irq_en0_cmp4 (w_o_irq_en0_cmp4),
    .o_tmr_irq_en0_cmp5 (w_o_irq_en0_cmp5),
    .o_tmr_irq_en0_cmp6 (w_o_irq_en0_cmp6),
    .o_tmr_irq_en0_cmp7 (w_o_irq_en0_cmp7),
    .o_tmr_irq_en0_tout0 (w_o_irq_en0_tout0),
    .o_tmr_irq_en0_tout1 (w_o_irq_en0_tout1),
    .o_tmr_irq_en0_tout2 (w_o_irq_en0_tout2),
    .o_tmr_irq_en0_tout3 (w_o_irq_en0_tout3),
    .o_tmr_irq_en0_tout4 (w_o_irq_en0_tout4),
    .o_tmr_irq_en0_tout5 (w_o_irq_en0_tout5),
    .o_tmr_irq_en0_tout6 (w_o_irq_en0_tout6),
    .o_tmr_irq_en0_tout7 (w_o_irq_en0_tout7),
    .o_tmr_irq_inj0_cap0 (w_o_irq_inj0_cap0),
    .o_tmr_irq_inj0_cap1 (w_o_irq_inj0_cap1),
    .o_tmr_irq_inj0_cap2 (w_o_irq_inj0_cap2),
    .o_tmr_irq_inj0_cap3 (w_o_irq_inj0_cap3),
    .o_tmr_irq_inj0_cap4 (w_o_irq_inj0_cap4),
    .o_tmr_irq_inj0_cap5 (w_o_irq_inj0_cap5),
    .o_tmr_irq_inj0_cap6 (w_o_irq_inj0_cap6),
    .o_tmr_irq_inj0_cap7 (w_o_irq_inj0_cap7),
    .o_tmr_irq_inj0_ovf0 (w_o_irq_inj0_ovf0),
    .o_tmr_irq_inj0_ovf1 (w_o_irq_inj0_ovf1),
    .o_tmr_irq_inj0_ovf2 (w_o_irq_inj0_ovf2),
    .o_tmr_irq_inj0_ovf3 (w_o_irq_inj0_ovf3),
    .o_tmr_irq_inj0_ovf4 (w_o_irq_inj0_ovf4),
    .o_tmr_irq_inj0_ovf5 (w_o_irq_inj0_ovf5),
    .o_tmr_irq_inj0_ovf6 (w_o_irq_inj0_ovf6),
    .o_tmr_irq_inj0_ovf7 (w_o_irq_inj0_ovf7),
    .o_tmr_irq_inj0_cmp0 (w_o_irq_inj0_cmp0),
    .o_tmr_irq_inj0_cmp1 (w_o_irq_inj0_cmp1),
    .o_tmr_irq_inj0_cmp2 (w_o_irq_inj0_cmp2),
    .o_tmr_irq_inj0_cmp3 (w_o_irq_inj0_cmp3),
    .o_tmr_irq_inj0_cmp4 (w_o_irq_inj0_cmp4),
    .o_tmr_irq_inj0_cmp5 (w_o_irq_inj0_cmp5),
    .o_tmr_irq_inj0_cmp6 (w_o_irq_inj0_cmp6),
    .o_tmr_irq_inj0_cmp7 (w_o_irq_inj0_cmp7),
    .o_tmr_irq_inj0_tout0 (w_o_irq_inj0_tout0),
    .o_tmr_irq_inj0_tout1 (w_o_irq_inj0_tout1),
    .o_tmr_irq_inj0_tout2 (w_o_irq_inj0_tout2),
    .o_tmr_irq_inj0_tout3 (w_o_irq_inj0_tout3),
    .o_tmr_irq_inj0_tout4 (w_o_irq_inj0_tout4),
    .o_tmr_irq_inj0_tout5 (w_o_irq_inj0_tout5),
    .o_tmr_irq_inj0_tout6 (w_o_irq_inj0_tout6),
    .o_tmr_irq_inj0_tout7 (w_o_irq_inj0_tout7),
    .i_tmr_irq_sts0_cap0 (w_i_irq_sts0_cap0),
    .i_tmr_irq_sts0_cap1 (w_i_irq_sts0_cap1),
    .i_tmr_irq_sts0_cap2 (w_i_irq_sts0_cap2),
    .i_tmr_irq_sts0_cap3 (w_i_irq_sts0_cap3),
    .i_tmr_irq_sts0_cap4 (w_i_irq_sts0_cap4),
    .i_tmr_irq_sts0_cap5 (w_i_irq_sts0_cap5),
    .i_tmr_irq_sts0_cap6 (w_i_irq_sts0_cap6),
    .i_tmr_irq_sts0_cap7 (w_i_irq_sts0_cap7),
    .i_tmr_irq_sts0_ovf0 (w_i_irq_sts0_ovf0),
    .i_tmr_irq_sts0_ovf1 (w_i_irq_sts0_ovf1),
    .i_tmr_irq_sts0_ovf2 (w_i_irq_sts0_ovf2),
    .i_tmr_irq_sts0_ovf3 (w_i_irq_sts0_ovf3),
    .i_tmr_irq_sts0_ovf4 (w_i_irq_sts0_ovf4),
    .i_tmr_irq_sts0_ovf5 (w_i_irq_sts0_ovf5),
    .i_tmr_irq_sts0_ovf6 (w_i_irq_sts0_ovf6),
    .i_tmr_irq_sts0_ovf7 (w_i_irq_sts0_ovf7),
    .i_tmr_irq_sts0_cmp0 (w_i_irq_sts0_cmp0),
    .i_tmr_irq_sts0_cmp1 (w_i_irq_sts0_cmp1),
    .i_tmr_irq_sts0_cmp2 (w_i_irq_sts0_cmp2),
    .i_tmr_irq_sts0_cmp3 (w_i_irq_sts0_cmp3),
    .i_tmr_irq_sts0_cmp4 (w_i_irq_sts0_cmp4),
    .i_tmr_irq_sts0_cmp5 (w_i_irq_sts0_cmp5),
    .i_tmr_irq_sts0_cmp6 (w_i_irq_sts0_cmp6),
    .i_tmr_irq_sts0_cmp7 (w_i_irq_sts0_cmp7),
    .i_tmr_irq_sts0_tout0 (w_i_irq_sts0_tout0),
    .i_tmr_irq_sts0_tout1 (w_i_irq_sts0_tout1),
    .i_tmr_irq_sts0_tout2 (w_i_irq_sts0_tout2),
    .i_tmr_irq_sts0_tout3 (w_i_irq_sts0_tout3),
    .i_tmr_irq_sts0_tout4 (w_i_irq_sts0_tout4),
    .i_tmr_irq_sts0_tout5 (w_i_irq_sts0_tout5),
    .i_tmr_irq_sts0_tout6 (w_i_irq_sts0_tout6),
    .i_tmr_irq_sts0_tout7 (w_i_irq_sts0_tout7),
    .o_tmr_irq_raw1_upd (w_o_irq_raw1_upd),
    .i_hw_wdata_tmr_irq_raw1_upd (w_hw_d_irq_raw1_upd),
    .i_hw_we_tmr_irq_raw1_upd (w_hw_we_irq_raw1_upd),
    .o_tmr_irq_raw1_cqovf (w_o_irq_raw1_cqovf),
    .i_hw_wdata_tmr_irq_raw1_cqovf (w_hw_d_irq_raw1_cqovf),
    .i_hw_we_tmr_irq_raw1_cqovf (w_hw_we_irq_raw1_cqovf),
    .o_tmr_irq_raw1_mqovf (w_o_irq_raw1_mqovf),
    .i_hw_wdata_tmr_irq_raw1_mqovf (w_hw_d_irq_raw1_mqovf),
    .i_hw_we_tmr_irq_raw1_mqovf (w_hw_we_irq_raw1_mqovf),
    .o_tmr_irq_raw1_dperr (w_o_irq_raw1_dperr),
    .i_hw_wdata_tmr_irq_raw1_dperr (w_hw_d_irq_raw1_dperr),
    .i_hw_we_tmr_irq_raw1_dperr (w_hw_we_irq_raw1_dperr),
    .o_tmr_irq_raw1_pwm0 (w_o_irq_raw1_pwm0),
    .i_hw_wdata_tmr_irq_raw1_pwm0 (w_hw_d_irq_raw1_pwm0),
    .i_hw_we_tmr_irq_raw1_pwm0 (w_hw_we_irq_raw1_pwm0),
    .o_tmr_irq_raw1_pwm1 (w_o_irq_raw1_pwm1),
    .i_hw_wdata_tmr_irq_raw1_pwm1 (w_hw_d_irq_raw1_pwm1),
    .i_hw_we_tmr_irq_raw1_pwm1 (w_hw_we_irq_raw1_pwm1),
    .o_tmr_irq_raw1_pwm2 (w_o_irq_raw1_pwm2),
    .i_hw_wdata_tmr_irq_raw1_pwm2 (w_hw_d_irq_raw1_pwm2),
    .i_hw_we_tmr_irq_raw1_pwm2 (w_hw_we_irq_raw1_pwm2),
    .o_tmr_irq_raw1_pwm3 (w_o_irq_raw1_pwm3),
    .i_hw_wdata_tmr_irq_raw1_pwm3 (w_hw_d_irq_raw1_pwm3),
    .i_hw_we_tmr_irq_raw1_pwm3 (w_hw_we_irq_raw1_pwm3),
    .o_tmr_irq_en1_upd (w_o_irq_en1_upd),
    .o_tmr_irq_en1_cqovf (w_o_irq_en1_cqovf),
    .o_tmr_irq_en1_mqovf (w_o_irq_en1_mqovf),
    .o_tmr_irq_en1_dperr (w_o_irq_en1_dperr),
    .o_tmr_irq_en1_pwm0 (w_o_irq_en1_pwm0),
    .o_tmr_irq_en1_pwm1 (w_o_irq_en1_pwm1),
    .o_tmr_irq_en1_pwm2 (w_o_irq_en1_pwm2),
    .o_tmr_irq_en1_pwm3 (w_o_irq_en1_pwm3),
    .o_tmr_irq_inj1_upd (w_o_irq_inj1_upd),
    .o_tmr_irq_inj1_cqovf (w_o_irq_inj1_cqovf),
    .o_tmr_irq_inj1_mqovf (w_o_irq_inj1_mqovf),
    .o_tmr_irq_inj1_dperr (w_o_irq_inj1_dperr),
    .o_tmr_irq_inj1_pwm0 (w_o_irq_inj1_pwm0),
    .o_tmr_irq_inj1_pwm1 (w_o_irq_inj1_pwm1),
    .o_tmr_irq_inj1_pwm2 (w_o_irq_inj1_pwm2),
    .o_tmr_irq_inj1_pwm3 (w_o_irq_inj1_pwm3),
    .i_tmr_irq_sts1_upd (w_i_irq_sts1_upd),
    .i_tmr_irq_sts1_cqovf (w_i_irq_sts1_cqovf),
    .i_tmr_irq_sts1_mqovf (w_i_irq_sts1_mqovf),
    .i_tmr_irq_sts1_dperr (w_i_irq_sts1_dperr),
    .i_tmr_irq_sts1_pwm0 (w_i_irq_sts1_pwm0),
    .i_tmr_irq_sts1_pwm1 (w_i_irq_sts1_pwm1),
    .i_tmr_irq_sts1_pwm2 (w_i_irq_sts1_pwm2),
    .i_tmr_irq_sts1_pwm3 (w_i_irq_sts1_pwm3),
    .o_tmr_c0_tout_thr (w_o_c0_tout_thr),
    .o_tmr_c0_tout_h_hi (w_o_c0_tout_h_hi),
    .o_tmr_c1_tout_thr (w_o_c1_tout_thr),
    .o_tmr_c1_tout_h_hi (w_o_c1_tout_h_hi),
    .o_tmr_c2_tout_thr (w_o_c2_tout_thr),
    .o_tmr_c2_tout_h_hi (w_o_c2_tout_h_hi),
    .o_tmr_c3_tout_thr (w_o_c3_tout_thr),
    .o_tmr_c3_tout_h_hi (w_o_c3_tout_h_hi),
    .o_tmr_c4_tout_thr (w_o_c4_tout_thr),
    .o_tmr_c4_tout_h_hi (w_o_c4_tout_h_hi),
    .o_tmr_c5_tout_thr (w_o_c5_tout_thr),
    .o_tmr_c5_tout_h_hi (w_o_c5_tout_h_hi),
    .o_tmr_c6_tout_thr (w_o_c6_tout_thr),
    .o_tmr_c6_tout_h_hi (w_o_c6_tout_h_hi),
    .o_tmr_c7_tout_thr (w_o_c7_tout_thr),
    .o_tmr_c7_tout_h_hi (w_o_c7_tout_h_hi),
    .o_tmr_pi_cfg_pair0_input (w_o_pi_cfg_pair0_input),
    .o_tmr_pi_cfg_low0 (w_o_pi_cfg_low0),
    .o_tmr_pi_cfg_pair0_en (w_o_pi_cfg_pair0_en),
    .o_tmr_pi_cfg_pair1_input (w_o_pi_cfg_pair1_input),
    .o_tmr_pi_cfg_low1 (w_o_pi_cfg_low1),
    .o_tmr_pi_cfg_pair1_en (w_o_pi_cfg_pair1_en),
    .o_tmr_pi_cfg_pair2_input (w_o_pi_cfg_pair2_input),
    .o_tmr_pi_cfg_low2 (w_o_pi_cfg_low2),
    .o_tmr_pi_cfg_pair2_en (w_o_pi_cfg_pair2_en),
    .o_tmr_pi_cfg_pair3_input (w_o_pi_cfg_pair3_input),
    .o_tmr_pi_cfg_low3 (w_o_pi_cfg_low3),
    .o_tmr_pi_cfg_pair3_en (w_o_pi_cfg_pair3_en),
    .i_tmr_p0_per_value (w_i_p0_per_value),
    .i_tmr_p0_per_h_hi (w_i_p0_per_h_hi),
    .i_tmr_p0_wid_value (w_i_p0_wid_value),
    .i_tmr_p0_wid_h_hi (w_i_p0_wid_h_hi),
    .i_tmr_p1_per_value (w_i_p1_per_value),
    .i_tmr_p1_per_h_hi (w_i_p1_per_h_hi),
    .i_tmr_p1_wid_value (w_i_p1_wid_value),
    .i_tmr_p1_wid_h_hi (w_i_p1_wid_h_hi),
    .i_tmr_p2_per_value (w_i_p2_per_value),
    .i_tmr_p2_per_h_hi (w_i_p2_per_h_hi),
    .i_tmr_p2_wid_value (w_i_p2_wid_value),
    .i_tmr_p2_wid_h_hi (w_i_p2_wid_h_hi),
    .i_tmr_p3_per_value (w_i_p3_per_value),
    .i_tmr_p3_per_h_hi (w_i_p3_per_h_hi),
    .i_tmr_p3_wid_value (w_i_p3_wid_value),
    .i_tmr_p3_wid_h_hi (w_i_p3_wid_h_hi),
    .o_tmr_pi_sts_valid0 (w_o_pi_sts_valid0),
    .i_hw_wdata_tmr_pi_sts_valid0 (w_hw_d_pi_sts_valid0),
    .i_hw_we_tmr_pi_sts_valid0 (w_hw_we_pi_sts_valid0),
    .o_tmr_pi_sts_valid1 (w_o_pi_sts_valid1),
    .i_hw_wdata_tmr_pi_sts_valid1 (w_hw_d_pi_sts_valid1),
    .i_hw_we_tmr_pi_sts_valid1 (w_hw_we_pi_sts_valid1),
    .o_tmr_pi_sts_valid2 (w_o_pi_sts_valid2),
    .i_hw_wdata_tmr_pi_sts_valid2 (w_hw_d_pi_sts_valid2),
    .i_hw_we_tmr_pi_sts_valid2 (w_hw_we_pi_sts_valid2),
    .o_tmr_pi_sts_valid3 (w_o_pi_sts_valid3),
    .i_hw_wdata_tmr_pi_sts_valid3 (w_hw_d_pi_sts_valid3),
    .i_hw_we_tmr_pi_sts_valid3 (w_hw_we_pi_sts_valid3),
    .o_tmr_pi_sts_ovr0 (w_o_pi_sts_ovr0),
    .i_hw_wdata_tmr_pi_sts_ovr0 (w_hw_d_pi_sts_ovr0),
    .i_hw_we_tmr_pi_sts_ovr0 (w_hw_we_pi_sts_ovr0),
    .o_tmr_pi_sts_ovr1 (w_o_pi_sts_ovr1),
    .i_hw_wdata_tmr_pi_sts_ovr1 (w_hw_d_pi_sts_ovr1),
    .i_hw_we_tmr_pi_sts_ovr1 (w_hw_we_pi_sts_ovr1),
    .o_tmr_pi_sts_ovr2 (w_o_pi_sts_ovr2),
    .i_hw_wdata_tmr_pi_sts_ovr2 (w_hw_d_pi_sts_ovr2),
    .i_hw_we_tmr_pi_sts_ovr2 (w_hw_we_pi_sts_ovr2),
    .o_tmr_pi_sts_ovr3 (w_o_pi_sts_ovr3),
    .i_hw_wdata_tmr_pi_sts_ovr3 (w_hw_d_pi_sts_ovr3),
    .i_hw_we_tmr_pi_sts_ovr3 (w_hw_we_pi_sts_ovr3),
    .o_tmr_c0_ow_width (w_o_c0_ow_width),
    .o_tmr_c0_ow_h_hi (w_o_c0_ow_h_hi),
    .o_tmr_c1_ow_width (w_o_c1_ow_width),
    .o_tmr_c1_ow_h_hi (w_o_c1_ow_h_hi),
    .o_tmr_c2_ow_width (w_o_c2_ow_width),
    .o_tmr_c2_ow_h_hi (w_o_c2_ow_h_hi),
    .o_tmr_c3_ow_width (w_o_c3_ow_width),
    .o_tmr_c3_ow_h_hi (w_o_c3_ow_h_hi),
    .o_tmr_c4_ow_width (w_o_c4_ow_width),
    .o_tmr_c4_ow_h_hi (w_o_c4_ow_h_hi),
    .o_tmr_c5_ow_width (w_o_c5_ow_width),
    .o_tmr_c5_ow_h_hi (w_o_c5_ow_h_hi),
    .o_tmr_c6_ow_width (w_o_c6_ow_width),
    .o_tmr_c6_ow_h_hi (w_o_c6_ow_h_hi),
    .o_tmr_c7_ow_width (w_o_c7_ow_width),
    .o_tmr_c7_ow_h_hi (w_o_c7_ow_h_hi),
    .i_tmr_dma_sts_cap_req (w_i_dma_sts_cap_req),
    .i_tmr_dma_sts_cap_burst (w_i_dma_sts_cap_burst),
    .i_tmr_dma_sts_cap_clr_busy (w_i_dma_sts_cap_clr_busy),
    .i_tmr_dma_sts_cmp_req (w_i_dma_sts_cmp_req),
    .i_tmr_dma_sts_cmp_burst (w_i_dma_sts_cmp_burst),
    .i_tmr_dma_sts_cmp_clr_busy (w_i_dma_sts_cmp_clr_busy)
  );

  // Shared timebase and CSR-write tracking.
  logic [7:0] w_capture_pins;
  logic [7:0] w_filtered;
  logic [7:0] w_filter_rising;
  logic [7:0] w_filter_falling;
  logic [7:0] w_channel_available;
  logic [7:0] w_capture_event;
  logic [7:0] w_capture_rising_event;
  logic [7:0] w_compare_event;
  logic [7:0] w_timeout_event;
  logic [7:0] w_opm_busy;
  logic [7:0] w_opm_armed;
  logic [7:0] w_timer_output;
  logic [7:0] w_trigger_rising;
  logic [7:0] w_trigger_falling;
  logic [7:0] w_opm_accept;
  logic [7:0] w_timeout_start_event;
  logic [7:0] w_capture_fifo_valid;
  logic [7:0] w_capture_fifo_full;
  logic [7:0] w_capture_fifo_overrun;
  logic [7:0] w_capture_fifo_overflow_event;
  logic [7:0] w_capture_fifo_pop;
  logic [7:0] w_capture_fifo_flush_busy;
  logic [7:0] w_clear_capture_overrun;
  logic [7:0] w_ch_pair_reserved;
  logic [2:0] w_capture_level [0:7];
  logic [PARA_COUNTER_WIDTH:0] w_capture_fifo_push_data [0:7];
  logic [PARA_COUNTER_WIDTH:0] w_capture_fifo_head [0:7];
  logic [PARA_COUNTER_WIDTH-1:0] w_compare_active [0:7];
  logic [PARA_COUNTER_WIDTH-1:0] w_compare_pending [0:7];
  logic [7:0] w_compare_pending_valid;
  logic [PARA_COUNTER_WIDTH-1:0] w_timeout_active [0:7];
  logic [PARA_COUNTER_WIDTH-1:0] w_timeout_pending [0:7];
  logic [7:0] w_timeout_pending_valid;
  logic [PARA_COUNTER_WIDTH-1:0] w_opm_width_active [0:7];
  logic [PARA_COUNTER_WIDTH-1:0] w_opm_width_pending [0:7];
  logic [7:0] w_opm_width_pending_valid;
  logic [2:0] w_ch_mode [0:7];
  logic [1:0] w_ch_edge_sel [0:7];
  logic [2:0] w_ch_sample_div [0:7];
  logic [3:0] w_ch_sample_n [0:7];
  logic [1:0] w_ch_cmp_action [0:7];
  logic [7:0] w_ch_out_pol;
  logic [7:0] w_ch_idle_level;
  logic [7:0] w_ch_force_en;
  logic [7:0] w_ch_force_val;
  logic [7:0] w_ch_timeout_en;
  logic [7:0] w_ch_timeout_start;
  logic [2:0] w_ch_trigger_sel [0:7];
  logic [7:0] w_ch_sw_arm_en;
  logic [7:0] w_ch_arm_cmd;
  logic [PARA_COUNTER_WIDTH-1:0] w_counter;
  logic w_timer_tick;
  logic w_update_event;
  logic [63:0] reg_counter_snapshot;
  logic reg_counter_snapshot_valid;
  logic [31:0] w_counter_read_low;
  logic [31:0] w_counter_read_high;
  logic reg_wr_en_dly;
  logic [15:0] reg_wr_addr_dly;
  logic [15:0] reg_psc_pending_value;
  logic reg_psc_pending;
  logic [15:0] w_prescale_shadow;
  logic w_prescale_commit;
  logic [PARA_COUNTER_WIDTH-1:0] w_period_active;
  logic [PARA_COUNTER_WIDTH-1:0] w_period_pending;
  logic w_period_pending_valid;

  // Capture and DMA transaction queues.
  logic w_cap_queue_push;
  logic w_cap_queue_valid;
  logic w_cap_queue_full;
  logic w_cap_queue_overflow;
  logic w_cap_queue_overflow_event;
  logic [2:0] w_cap_queue_level;
  logic [LPARA_RECORD_W-1:0] w_cap_queue_head;
  logic [LPARA_RECORD_W-1:0] w_cap_queue_push_data;
  logic w_capture_queue_flush_busy;
  logic w_dma_cap_flush_clear;
  logic w_arb_found;
  logic [2:0] reg_arb_rr_pointer;
  logic [2:0] w_arb_sel;
  logic [7:0] w_arb_pop;
  logic w_stream_req_timer;
  logic w_stream_write_timer;
  logic [15:0] w_stream_addr_timer;
  logic [31:0] w_stream_wdata_timer;
  logic [3:0] w_stream_wstrb_timer;
  logic w_stream_ready_timer;
  logic [31:0] w_stream_rdata_timer;
  logic w_stream_error_timer;
  logic w_dma_cap_pop;
  logic [2:0] w_dma_cap_level;
  logic [2:0] w_dma_cmp_level;
  logic [2:0] w_dma_cap_reserved;
  logic [2:0] w_dma_cmp_reserved;
  logic w_dma_cap_req_status;
  logic w_dma_cap_burst_status;
  logic w_dma_cap_clr_status;
  logic w_dma_cmp_req_status;
  logic w_dma_cmp_burst_status;
  logic w_dma_cmp_clr_status;
  logic w_dma_error_event;
  logic w_dma_update_batch_valid;
  logic [2:0] w_dma_update_batch_count;
  logic [4*LPARA_RECORD_W-1:0] w_dma_update_batch_data;
  logic [7:0] w_dma_compare_update;
  logic [7:0] w_dma_width_update;
  logic [8*PARA_COUNTER_WIDTH-1:0] w_dma_compare_value_flat;
  logic [PARA_COUNTER_WIDTH-1:0] w_dma_period_value;
  logic w_dma_period_update;
  logic [15:0] w_dma_prescale_value;
  logic w_dma_prescale_update;
  logic [LPARA_RECORD_W-1:0] w_dma_record;
  logic [4:0] w_dma_tag;
  logic [PARA_COUNTER_WIDTH-1:0] w_dma_value;

  // PWM-input values and set-dominant W1C clear tracking.
  logic [3:0] w_pwm_measure_event;
  logic [3:0] w_pwm_result_commit;
  logic [3:0] w_pwm_overrun_event;
  logic [3:0] w_pwm_valid;
  logic [3:0] w_pwm_overrun;
  logic [PARA_COUNTER_WIDTH-1:0] w_pwm_period [0:3];
  logic [PARA_COUNTER_WIDTH-1:0] w_pwm_pulse_width [0:3];
  logic [63:0] w_pwm_period_ext [0:3];
  logic [63:0] w_pwm_pulse_width_ext [0:3];
  logic [7:0] w_irq_clear_ovf;
  logic [3:0] w_irq_clear_pwm_valid;
  logic [3:0] w_irq_clear_pwm_overrun;
  logic [7:0] reg_irq_ovf_prev;
  logic [3:0] reg_irq_pwm_valid_prev;
  logic [3:0] reg_irq_pwm_ovr_prev;

  // The Timer input list remains fixed while static parameters select active channels.
  assign w_capture_pins = 8'(i_capture_ch);

  // Synchronize and qualify every external pin before edge detection or timestamp capture.
  generate
    for (genvar g_filter = 0; g_filter < 8; g_filter = g_filter + 1) begin : gen_capture_filter
      m_vlsit_timer_input_filter u_input_filter (
        .i_clk_timer      (i_clk_timer),
        .i_rst_n_timer    (w_rst_n_timer),
        .i_capture_async  (w_capture_pins[g_filter]),
        .i_sample_div     (w_ch_sample_div[g_filter]),
        .i_sample_n       (w_ch_sample_n[g_filter]),
        .o_filtered       (w_filtered[g_filter]),
        .o_rising         (w_filter_rising[g_filter]),
        .o_falling        (w_filter_falling[g_filter])
      );
    end
  endgenerate

  // Delay CSR write events by one timer edge so field outputs reflect the successful write.
  always_ff @(posedge i_clk_timer, negedge w_rst_n_timer) begin : p_ff_csr_events
    if (!w_rst_n_timer) begin
      reg_wr_en_dly <= 1'b0;
      reg_wr_addr_dly <= '0;
      reg_counter_snapshot <= '0;
      reg_counter_snapshot_valid <= 1'b0;
    end else begin
      reg_wr_en_dly <= w_csr_o_reg_wr_en;
      reg_wr_addr_dly <= w_csr_o_reg_wr_addr;
      if (w_csr_o_reg_rd_en && (w_csr_o_reg_rd_addr == 16'h0078)) begin
        reg_counter_snapshot <= {{(64-PARA_COUNTER_WIDTH){1'b0}}, w_counter};
        reg_counter_snapshot_valid <= 1'b1;
      end else if (w_csr_o_reg_rd_en && (w_csr_o_reg_rd_addr == 16'h007c)) begin
        reg_counter_snapshot_valid <= 1'b0;
      end
    end
  end
  assign w_counter_read_low = ((PARA_COUNTER_WIDTH == 64) && w_csr_o_reg_rd_en &&
                               (w_csr_o_reg_rd_addr == 16'h0078)) ? w_counter[31:0] :
                              reg_counter_snapshot_valid ? reg_counter_snapshot[31:0] :
                              w_counter[31:0];
  assign w_counter_read_high = ((PARA_COUNTER_WIDTH == 64) && reg_counter_snapshot_valid) ?
                               reg_counter_snapshot[63:32] : 32'd0;

  // CSR field aliases form vectors for the channel generate loop.
  assign w_ch_mode[0] = w_o_ch0_cfg_mode;
  assign w_ch_mode[1] = w_o_ch1_cfg_mode;
  assign w_ch_mode[2] = w_o_ch2_cfg_mode;
  assign w_ch_mode[3] = w_o_ch3_cfg_mode;
  assign w_ch_mode[4] = w_o_ch4_cfg_mode;
  assign w_ch_mode[5] = w_o_ch5_cfg_mode;
  assign w_ch_mode[6] = w_o_ch6_cfg_mode;
  assign w_ch_mode[7] = w_o_ch7_cfg_mode;
  assign w_ch_edge_sel[0] = w_o_ch0_cfg_edge_sel;
  assign w_ch_edge_sel[1] = w_o_ch1_cfg_edge_sel;
  assign w_ch_edge_sel[2] = w_o_ch2_cfg_edge_sel;
  assign w_ch_edge_sel[3] = w_o_ch3_cfg_edge_sel;
  assign w_ch_edge_sel[4] = w_o_ch4_cfg_edge_sel;
  assign w_ch_edge_sel[5] = w_o_ch5_cfg_edge_sel;
  assign w_ch_edge_sel[6] = w_o_ch6_cfg_edge_sel;
  assign w_ch_edge_sel[7] = w_o_ch7_cfg_edge_sel;
  assign w_ch_sample_div[0] = w_o_ch0_cfg_sample_div;
  assign w_ch_sample_div[1] = w_o_ch1_cfg_sample_div;
  assign w_ch_sample_div[2] = w_o_ch2_cfg_sample_div;
  assign w_ch_sample_div[3] = w_o_ch3_cfg_sample_div;
  assign w_ch_sample_div[4] = w_o_ch4_cfg_sample_div;
  assign w_ch_sample_div[5] = w_o_ch5_cfg_sample_div;
  assign w_ch_sample_div[6] = w_o_ch6_cfg_sample_div;
  assign w_ch_sample_div[7] = w_o_ch7_cfg_sample_div;
  assign w_ch_sample_n[0] = w_o_ch0_cfg_sample_n;
  assign w_ch_sample_n[1] = w_o_ch1_cfg_sample_n;
  assign w_ch_sample_n[2] = w_o_ch2_cfg_sample_n;
  assign w_ch_sample_n[3] = w_o_ch3_cfg_sample_n;
  assign w_ch_sample_n[4] = w_o_ch4_cfg_sample_n;
  assign w_ch_sample_n[5] = w_o_ch5_cfg_sample_n;
  assign w_ch_sample_n[6] = w_o_ch6_cfg_sample_n;
  assign w_ch_sample_n[7] = w_o_ch7_cfg_sample_n;
  assign w_ch_cmp_action[0] = w_o_ch0_cfg_cmp_action;
  assign w_ch_cmp_action[1] = w_o_ch1_cfg_cmp_action;
  assign w_ch_cmp_action[2] = w_o_ch2_cfg_cmp_action;
  assign w_ch_cmp_action[3] = w_o_ch3_cfg_cmp_action;
  assign w_ch_cmp_action[4] = w_o_ch4_cfg_cmp_action;
  assign w_ch_cmp_action[5] = w_o_ch5_cfg_cmp_action;
  assign w_ch_cmp_action[6] = w_o_ch6_cfg_cmp_action;
  assign w_ch_cmp_action[7] = w_o_ch7_cfg_cmp_action;

  // PERIOD shadow words are staged as a pair and committed with the shared update event.
  m_vlsit_timer_timing_stage #(.PARA_VALUE_WIDTH (PARA_COUNTER_WIDTH)) u_period_stage (
    .i_clk_timer      (i_clk_timer),
    .i_rst_n_timer    (w_rst_n_timer),
    .i_write_low      (reg_wr_en_dly && (reg_wr_addr_dly == 16'h0004)),
    .i_write_high     (reg_wr_en_dly && (reg_wr_addr_dly == 16'h0008)),
    .i_value_low      (w_o_period_period),
    .i_value_high     (w_o_period_hi_period_hi),
    .i_activate       (w_update_event),
    .i_dma_update     (w_dma_period_update),
    .i_dma_value      (w_dma_period_value),
    .o_active_value   (w_period_active),
    .o_pending_value  (w_period_pending),
    .o_pending_valid  (w_period_pending_valid)
  );

  // Prescaler shadow activates on the same boundary as PERIOD and compare/PWM shadows.
  assign w_prescale_shadow = w_dma_prescale_update ? w_dma_prescale_value[15:0] :
                             reg_psc_pending_value;
  assign w_prescale_commit = w_update_event && (reg_psc_pending || w_dma_prescale_update);
  always_ff @(posedge i_clk_timer, negedge w_rst_n_timer) begin : p_ff_prescale_stage
    if (!w_rst_n_timer) begin
      reg_psc_pending_value <= '0;
      reg_psc_pending <= 1'b0;
    end else begin
      if (w_update_event && (reg_psc_pending || w_dma_prescale_update))
        reg_psc_pending <= 1'b0;
      if (reg_wr_en_dly && (reg_wr_addr_dly == 16'h000c)) begin
        reg_psc_pending_value <= w_o_prescale_psc;
        reg_psc_pending <= 1'b1;
      end
    end
  end

  // Shared counter and prescaler generate the common tick and update boundary.
  m_vlsit_timer_counter #(.PARA_COUNTER_WIDTH (PARA_COUNTER_WIDTH)) u_timer_counter (
    .i_clk_timer       (i_clk_timer),
    .i_rst_n_timer     (w_rst_n_timer),
    .i_enable          (w_o_ctrl_timer_en),
    .i_dir_down        (w_o_ctrl_dir_down),
    .i_period_shadow   (w_dma_period_update ? w_dma_period_value : w_period_pending),
    .i_prescale_shadow (w_prescale_shadow),
    .i_period_commit   (w_update_event && (w_period_pending_valid || w_dma_period_update)),
    .i_prescale_commit (w_prescale_commit),
    .o_count           (w_counter),
    .o_tick            (w_timer_tick),
    .o_update_event    (w_update_event)
  );


  // CSR aliases and complete timing-value staging instances.
  assign w_ch_out_pol[0] = w_o_ch0_cfg_out_pol;
  assign w_ch_idle_level[0] = w_o_ch0_cfg_idle_level;
  assign w_ch_force_en[0] = w_o_ch0_cfg_force_en;
  assign w_ch_force_val[0] = w_o_ch0_cfg_force_val;
  assign w_ch_timeout_en[0] = w_o_ch0_cfg_timeout_en;
  assign w_ch_timeout_start[0] = w_o_ch0_cfg_tout_start;
  assign w_ch_trigger_sel[0] = w_o_ch0_cfg_trig_sel;
  assign w_ch_sw_arm_en[0] = w_o_ch0_cfg_sw_arm_en;
  assign w_ch_arm_cmd[0] = w_o_ch0_cfg_arm_cmd;
  assign w_ch_pair_reserved[0] = w_o_pi_cfg_pair0_en;
  assign w_channel_available[0] = (LPARA_CHANNEL_COUNT > 0) && !w_ch_pair_reserved[0];
  assign w_trigger_rising[0] = ({1'b0, w_ch_trigger_sel[0]} < PARA_CAPTURE_COUNT[3:0]) ? w_filter_rising[w_ch_trigger_sel[0]] : 1'b0;
  assign w_trigger_falling[0] = ({1'b0, w_ch_trigger_sel[0]} < PARA_CAPTURE_COUNT[3:0]) ? w_filter_falling[w_ch_trigger_sel[0]] : 1'b0;
  assign w_opm_accept[0] = w_channel_available[0] && w_o_ctrl_timer_en && (w_ch_mode[0] == 3'd4) && !w_opm_busy[0] && w_opm_armed[0] && (((w_ch_edge_sel[0] == 2'd0) && w_trigger_rising[0]) || ((w_ch_edge_sel[0] == 2'd1) && w_trigger_falling[0]) || ((w_ch_edge_sel[0] == 2'd2) && (w_trigger_rising[0] || w_trigger_falling[0])));
  assign w_timeout_start_event[0] = w_capture_event[0] || (w_o_ctrl_timer_en && w_channel_available[0] && (w_ch_mode[0] == 3'd1) && !w_ch_timeout_start[0] && (w_timeout_pending_valid[0] || (w_timeout_active[0] == '0)));
  assign w_ch_out_pol[1] = w_o_ch1_cfg_out_pol;
  assign w_ch_idle_level[1] = w_o_ch1_cfg_idle_level;
  assign w_ch_force_en[1] = w_o_ch1_cfg_force_en;
  assign w_ch_force_val[1] = w_o_ch1_cfg_force_val;
  assign w_ch_timeout_en[1] = w_o_ch1_cfg_timeout_en;
  assign w_ch_timeout_start[1] = w_o_ch1_cfg_tout_start;
  assign w_ch_trigger_sel[1] = w_o_ch1_cfg_trig_sel;
  assign w_ch_sw_arm_en[1] = w_o_ch1_cfg_sw_arm_en;
  assign w_ch_arm_cmd[1] = w_o_ch1_cfg_arm_cmd;
  assign w_ch_pair_reserved[1] = w_o_pi_cfg_pair0_en;
  assign w_channel_available[1] = (LPARA_CHANNEL_COUNT > 1) && !w_ch_pair_reserved[1];
  assign w_trigger_rising[1] = ({1'b0, w_ch_trigger_sel[1]} < PARA_CAPTURE_COUNT[3:0]) ? w_filter_rising[w_ch_trigger_sel[1]] : 1'b0;
  assign w_trigger_falling[1] = ({1'b0, w_ch_trigger_sel[1]} < PARA_CAPTURE_COUNT[3:0]) ? w_filter_falling[w_ch_trigger_sel[1]] : 1'b0;
  assign w_opm_accept[1] = w_channel_available[1] && w_o_ctrl_timer_en && (w_ch_mode[1] == 3'd4) && !w_opm_busy[1] && w_opm_armed[1] && (((w_ch_edge_sel[1] == 2'd0) && w_trigger_rising[1]) || ((w_ch_edge_sel[1] == 2'd1) && w_trigger_falling[1]) || ((w_ch_edge_sel[1] == 2'd2) && (w_trigger_rising[1] || w_trigger_falling[1])));
  assign w_timeout_start_event[1] = w_capture_event[1] || (w_o_ctrl_timer_en && w_channel_available[1] && (w_ch_mode[1] == 3'd1) && !w_ch_timeout_start[1] && (w_timeout_pending_valid[1] || (w_timeout_active[1] == '0)));
  assign w_ch_out_pol[2] = w_o_ch2_cfg_out_pol;
  assign w_ch_idle_level[2] = w_o_ch2_cfg_idle_level;
  assign w_ch_force_en[2] = w_o_ch2_cfg_force_en;
  assign w_ch_force_val[2] = w_o_ch2_cfg_force_val;
  assign w_ch_timeout_en[2] = w_o_ch2_cfg_timeout_en;
  assign w_ch_timeout_start[2] = w_o_ch2_cfg_tout_start;
  assign w_ch_trigger_sel[2] = w_o_ch2_cfg_trig_sel;
  assign w_ch_sw_arm_en[2] = w_o_ch2_cfg_sw_arm_en;
  assign w_ch_arm_cmd[2] = w_o_ch2_cfg_arm_cmd;
  assign w_ch_pair_reserved[2] = w_o_pi_cfg_pair1_en;
  assign w_channel_available[2] = (LPARA_CHANNEL_COUNT > 2) && !w_ch_pair_reserved[2];
  assign w_trigger_rising[2] = ({1'b0, w_ch_trigger_sel[2]} < PARA_CAPTURE_COUNT[3:0]) ? w_filter_rising[w_ch_trigger_sel[2]] : 1'b0;
  assign w_trigger_falling[2] = ({1'b0, w_ch_trigger_sel[2]} < PARA_CAPTURE_COUNT[3:0]) ? w_filter_falling[w_ch_trigger_sel[2]] : 1'b0;
  assign w_opm_accept[2] = w_channel_available[2] && w_o_ctrl_timer_en && (w_ch_mode[2] == 3'd4) && !w_opm_busy[2] && w_opm_armed[2] && (((w_ch_edge_sel[2] == 2'd0) && w_trigger_rising[2]) || ((w_ch_edge_sel[2] == 2'd1) && w_trigger_falling[2]) || ((w_ch_edge_sel[2] == 2'd2) && (w_trigger_rising[2] || w_trigger_falling[2])));
  assign w_timeout_start_event[2] = w_capture_event[2] || (w_o_ctrl_timer_en && w_channel_available[2] && (w_ch_mode[2] == 3'd1) && !w_ch_timeout_start[2] && (w_timeout_pending_valid[2] || (w_timeout_active[2] == '0)));
  assign w_ch_out_pol[3] = w_o_ch3_cfg_out_pol;
  assign w_ch_idle_level[3] = w_o_ch3_cfg_idle_level;
  assign w_ch_force_en[3] = w_o_ch3_cfg_force_en;
  assign w_ch_force_val[3] = w_o_ch3_cfg_force_val;
  assign w_ch_timeout_en[3] = w_o_ch3_cfg_timeout_en;
  assign w_ch_timeout_start[3] = w_o_ch3_cfg_tout_start;
  assign w_ch_trigger_sel[3] = w_o_ch3_cfg_trig_sel;
  assign w_ch_sw_arm_en[3] = w_o_ch3_cfg_sw_arm_en;
  assign w_ch_arm_cmd[3] = w_o_ch3_cfg_arm_cmd;
  assign w_ch_pair_reserved[3] = w_o_pi_cfg_pair1_en;
  assign w_channel_available[3] = (LPARA_CHANNEL_COUNT > 3) && !w_ch_pair_reserved[3];
  assign w_trigger_rising[3] = ({1'b0, w_ch_trigger_sel[3]} < PARA_CAPTURE_COUNT[3:0]) ? w_filter_rising[w_ch_trigger_sel[3]] : 1'b0;
  assign w_trigger_falling[3] = ({1'b0, w_ch_trigger_sel[3]} < PARA_CAPTURE_COUNT[3:0]) ? w_filter_falling[w_ch_trigger_sel[3]] : 1'b0;
  assign w_opm_accept[3] = w_channel_available[3] && w_o_ctrl_timer_en && (w_ch_mode[3] == 3'd4) && !w_opm_busy[3] && w_opm_armed[3] && (((w_ch_edge_sel[3] == 2'd0) && w_trigger_rising[3]) || ((w_ch_edge_sel[3] == 2'd1) && w_trigger_falling[3]) || ((w_ch_edge_sel[3] == 2'd2) && (w_trigger_rising[3] || w_trigger_falling[3])));
  assign w_timeout_start_event[3] = w_capture_event[3] || (w_o_ctrl_timer_en && w_channel_available[3] && (w_ch_mode[3] == 3'd1) && !w_ch_timeout_start[3] && (w_timeout_pending_valid[3] || (w_timeout_active[3] == '0)));
  assign w_ch_out_pol[4] = w_o_ch4_cfg_out_pol;
  assign w_ch_idle_level[4] = w_o_ch4_cfg_idle_level;
  assign w_ch_force_en[4] = w_o_ch4_cfg_force_en;
  assign w_ch_force_val[4] = w_o_ch4_cfg_force_val;
  assign w_ch_timeout_en[4] = w_o_ch4_cfg_timeout_en;
  assign w_ch_timeout_start[4] = w_o_ch4_cfg_tout_start;
  assign w_ch_trigger_sel[4] = w_o_ch4_cfg_trig_sel;
  assign w_ch_sw_arm_en[4] = w_o_ch4_cfg_sw_arm_en;
  assign w_ch_arm_cmd[4] = w_o_ch4_cfg_arm_cmd;
  assign w_ch_pair_reserved[4] = w_o_pi_cfg_pair2_en;
  assign w_channel_available[4] = (LPARA_CHANNEL_COUNT > 4) && !w_ch_pair_reserved[4];
  assign w_trigger_rising[4] = ({1'b0, w_ch_trigger_sel[4]} < PARA_CAPTURE_COUNT[3:0]) ? w_filter_rising[w_ch_trigger_sel[4]] : 1'b0;
  assign w_trigger_falling[4] = ({1'b0, w_ch_trigger_sel[4]} < PARA_CAPTURE_COUNT[3:0]) ? w_filter_falling[w_ch_trigger_sel[4]] : 1'b0;
  assign w_opm_accept[4] = w_channel_available[4] && w_o_ctrl_timer_en && (w_ch_mode[4] == 3'd4) && !w_opm_busy[4] && w_opm_armed[4] && (((w_ch_edge_sel[4] == 2'd0) && w_trigger_rising[4]) || ((w_ch_edge_sel[4] == 2'd1) && w_trigger_falling[4]) || ((w_ch_edge_sel[4] == 2'd2) && (w_trigger_rising[4] || w_trigger_falling[4])));
  assign w_timeout_start_event[4] = w_capture_event[4] || (w_o_ctrl_timer_en && w_channel_available[4] && (w_ch_mode[4] == 3'd1) && !w_ch_timeout_start[4] && (w_timeout_pending_valid[4] || (w_timeout_active[4] == '0)));
  assign w_ch_out_pol[5] = w_o_ch5_cfg_out_pol;
  assign w_ch_idle_level[5] = w_o_ch5_cfg_idle_level;
  assign w_ch_force_en[5] = w_o_ch5_cfg_force_en;
  assign w_ch_force_val[5] = w_o_ch5_cfg_force_val;
  assign w_ch_timeout_en[5] = w_o_ch5_cfg_timeout_en;
  assign w_ch_timeout_start[5] = w_o_ch5_cfg_tout_start;
  assign w_ch_trigger_sel[5] = w_o_ch5_cfg_trig_sel;
  assign w_ch_sw_arm_en[5] = w_o_ch5_cfg_sw_arm_en;
  assign w_ch_arm_cmd[5] = w_o_ch5_cfg_arm_cmd;
  assign w_ch_pair_reserved[5] = w_o_pi_cfg_pair2_en;
  assign w_channel_available[5] = (LPARA_CHANNEL_COUNT > 5) && !w_ch_pair_reserved[5];
  assign w_trigger_rising[5] = ({1'b0, w_ch_trigger_sel[5]} < PARA_CAPTURE_COUNT[3:0]) ? w_filter_rising[w_ch_trigger_sel[5]] : 1'b0;
  assign w_trigger_falling[5] = ({1'b0, w_ch_trigger_sel[5]} < PARA_CAPTURE_COUNT[3:0]) ? w_filter_falling[w_ch_trigger_sel[5]] : 1'b0;
  assign w_opm_accept[5] = w_channel_available[5] && w_o_ctrl_timer_en && (w_ch_mode[5] == 3'd4) && !w_opm_busy[5] && w_opm_armed[5] && (((w_ch_edge_sel[5] == 2'd0) && w_trigger_rising[5]) || ((w_ch_edge_sel[5] == 2'd1) && w_trigger_falling[5]) || ((w_ch_edge_sel[5] == 2'd2) && (w_trigger_rising[5] || w_trigger_falling[5])));
  assign w_timeout_start_event[5] = w_capture_event[5] || (w_o_ctrl_timer_en && w_channel_available[5] && (w_ch_mode[5] == 3'd1) && !w_ch_timeout_start[5] && (w_timeout_pending_valid[5] || (w_timeout_active[5] == '0)));
  assign w_ch_out_pol[6] = w_o_ch6_cfg_out_pol;
  assign w_ch_idle_level[6] = w_o_ch6_cfg_idle_level;
  assign w_ch_force_en[6] = w_o_ch6_cfg_force_en;
  assign w_ch_force_val[6] = w_o_ch6_cfg_force_val;
  assign w_ch_timeout_en[6] = w_o_ch6_cfg_timeout_en;
  assign w_ch_timeout_start[6] = w_o_ch6_cfg_tout_start;
  assign w_ch_trigger_sel[6] = w_o_ch6_cfg_trig_sel;
  assign w_ch_sw_arm_en[6] = w_o_ch6_cfg_sw_arm_en;
  assign w_ch_arm_cmd[6] = w_o_ch6_cfg_arm_cmd;
  assign w_ch_pair_reserved[6] = w_o_pi_cfg_pair3_en;
  assign w_channel_available[6] = (LPARA_CHANNEL_COUNT > 6) && !w_ch_pair_reserved[6];
  assign w_trigger_rising[6] = ({1'b0, w_ch_trigger_sel[6]} < PARA_CAPTURE_COUNT[3:0]) ? w_filter_rising[w_ch_trigger_sel[6]] : 1'b0;
  assign w_trigger_falling[6] = ({1'b0, w_ch_trigger_sel[6]} < PARA_CAPTURE_COUNT[3:0]) ? w_filter_falling[w_ch_trigger_sel[6]] : 1'b0;
  assign w_opm_accept[6] = w_channel_available[6] && w_o_ctrl_timer_en && (w_ch_mode[6] == 3'd4) && !w_opm_busy[6] && w_opm_armed[6] && (((w_ch_edge_sel[6] == 2'd0) && w_trigger_rising[6]) || ((w_ch_edge_sel[6] == 2'd1) && w_trigger_falling[6]) || ((w_ch_edge_sel[6] == 2'd2) && (w_trigger_rising[6] || w_trigger_falling[6])));
  assign w_timeout_start_event[6] = w_capture_event[6] || (w_o_ctrl_timer_en && w_channel_available[6] && (w_ch_mode[6] == 3'd1) && !w_ch_timeout_start[6] && (w_timeout_pending_valid[6] || (w_timeout_active[6] == '0)));
  assign w_ch_out_pol[7] = w_o_ch7_cfg_out_pol;
  assign w_ch_idle_level[7] = w_o_ch7_cfg_idle_level;
  assign w_ch_force_en[7] = w_o_ch7_cfg_force_en;
  assign w_ch_force_val[7] = w_o_ch7_cfg_force_val;
  assign w_ch_timeout_en[7] = w_o_ch7_cfg_timeout_en;
  assign w_ch_timeout_start[7] = w_o_ch7_cfg_tout_start;
  assign w_ch_trigger_sel[7] = w_o_ch7_cfg_trig_sel;
  assign w_ch_sw_arm_en[7] = w_o_ch7_cfg_sw_arm_en;
  assign w_ch_arm_cmd[7] = w_o_ch7_cfg_arm_cmd;
  assign w_ch_pair_reserved[7] = w_o_pi_cfg_pair3_en;
  assign w_channel_available[7] = (LPARA_CHANNEL_COUNT > 7) && !w_ch_pair_reserved[7];
  assign w_trigger_rising[7] = ({1'b0, w_ch_trigger_sel[7]} < PARA_CAPTURE_COUNT[3:0]) ? w_filter_rising[w_ch_trigger_sel[7]] : 1'b0;
  assign w_trigger_falling[7] = ({1'b0, w_ch_trigger_sel[7]} < PARA_CAPTURE_COUNT[3:0]) ? w_filter_falling[w_ch_trigger_sel[7]] : 1'b0;
  assign w_opm_accept[7] = w_channel_available[7] && w_o_ctrl_timer_en && (w_ch_mode[7] == 3'd4) && !w_opm_busy[7] && w_opm_armed[7] && (((w_ch_edge_sel[7] == 2'd0) && w_trigger_rising[7]) || ((w_ch_edge_sel[7] == 2'd1) && w_trigger_falling[7]) || ((w_ch_edge_sel[7] == 2'd2) && (w_trigger_rising[7] || w_trigger_falling[7])));
  assign w_timeout_start_event[7] = w_capture_event[7] || (w_o_ctrl_timer_en && w_channel_available[7] && (w_ch_mode[7] == 3'd1) && !w_ch_timeout_start[7] && (w_timeout_pending_valid[7] || (w_timeout_active[7] == '0)));
  m_vlsit_timer_timing_stage #(.PARA_VALUE_WIDTH (PARA_COUNTER_WIDTH)) u_cmp_stage_0 (
    .i_clk_timer      (i_clk_timer),
    .i_rst_n_timer    (w_rst_n_timer),
    .i_write_low      (reg_wr_en_dly && (reg_wr_addr_dly == 16'h0038)),
    .i_write_high     (reg_wr_en_dly && (reg_wr_addr_dly == 16'h003c)),
    .i_value_low      (w_o_ch0_cmp_value),
    .i_value_high     (w_o_c0_cmp_h_hi),
    .i_activate       (w_update_event),
    .i_dma_update     (w_dma_compare_update[0]),
    .i_dma_value      (w_dma_compare_value_flat[0*PARA_COUNTER_WIDTH +: PARA_COUNTER_WIDTH]),
    .o_active_value   (w_compare_active[0]),
    .o_pending_value  (w_compare_pending[0]),
    .o_pending_valid  (w_compare_pending_valid[0])
  );
  m_vlsit_timer_timing_stage #(.PARA_VALUE_WIDTH (PARA_COUNTER_WIDTH)) u_timeout_stage_0 (
    .i_clk_timer      (i_clk_timer),
    .i_rst_n_timer    (w_rst_n_timer),
    .i_write_low      (reg_wr_en_dly && (reg_wr_addr_dly == 16'h00ac)),
    .i_write_high     (reg_wr_en_dly && (reg_wr_addr_dly == 16'h00b0)),
    .i_value_low      (w_o_c0_tout_thr),
    .i_value_high     (w_o_c0_tout_h_hi),
    .i_activate       (w_timeout_start_event[0]),
    .i_dma_update     (1'b0),
    .i_dma_value      ('0),
    .o_active_value   (w_timeout_active[0]),
    .o_pending_value  (w_timeout_pending[0]),
    .o_pending_valid  (w_timeout_pending_valid[0])
  );
  m_vlsit_timer_timing_stage #(.PARA_VALUE_WIDTH (PARA_COUNTER_WIDTH)) u_opm_width_stage_0 (
    .i_clk_timer      (i_clk_timer),
    .i_rst_n_timer    (w_rst_n_timer),
    .i_write_low      (reg_wr_en_dly && (reg_wr_addr_dly == 16'h0134)),
    .i_write_high     (reg_wr_en_dly && (reg_wr_addr_dly == 16'h0138)),
    .i_value_low      (w_o_c0_ow_width),
    .i_value_high     (w_o_c0_ow_h_hi),
    .i_activate       (w_opm_accept[0]),
    .i_dma_update     (w_dma_width_update[0]),
    .i_dma_value      (w_dma_compare_value_flat[0*PARA_COUNTER_WIDTH +: PARA_COUNTER_WIDTH]),
    .o_active_value   (w_opm_width_active[0]),
    .o_pending_value  (w_opm_width_pending[0]),
    .o_pending_valid  (w_opm_width_pending_valid[0])
  );
  m_vlsit_timer_timing_stage #(.PARA_VALUE_WIDTH (PARA_COUNTER_WIDTH)) u_cmp_stage_1 (
    .i_clk_timer      (i_clk_timer),
    .i_rst_n_timer    (w_rst_n_timer),
    .i_write_low      (reg_wr_en_dly && (reg_wr_addr_dly == 16'h0040)),
    .i_write_high     (reg_wr_en_dly && (reg_wr_addr_dly == 16'h0044)),
    .i_value_low      (w_o_ch1_cmp_value),
    .i_value_high     (w_o_c1_cmp_h_hi),
    .i_activate       (w_update_event),
    .i_dma_update     (w_dma_compare_update[1]),
    .i_dma_value      (w_dma_compare_value_flat[1*PARA_COUNTER_WIDTH +: PARA_COUNTER_WIDTH]),
    .o_active_value   (w_compare_active[1]),
    .o_pending_value  (w_compare_pending[1]),
    .o_pending_valid  (w_compare_pending_valid[1])
  );
  m_vlsit_timer_timing_stage #(.PARA_VALUE_WIDTH (PARA_COUNTER_WIDTH)) u_timeout_stage_1 (
    .i_clk_timer      (i_clk_timer),
    .i_rst_n_timer    (w_rst_n_timer),
    .i_write_low      (reg_wr_en_dly && (reg_wr_addr_dly == 16'h00b4)),
    .i_write_high     (reg_wr_en_dly && (reg_wr_addr_dly == 16'h00b8)),
    .i_value_low      (w_o_c1_tout_thr),
    .i_value_high     (w_o_c1_tout_h_hi),
    .i_activate       (w_timeout_start_event[1]),
    .i_dma_update     (1'b0),
    .i_dma_value      ('0),
    .o_active_value   (w_timeout_active[1]),
    .o_pending_value  (w_timeout_pending[1]),
    .o_pending_valid  (w_timeout_pending_valid[1])
  );
  m_vlsit_timer_timing_stage #(.PARA_VALUE_WIDTH (PARA_COUNTER_WIDTH)) u_opm_width_stage_1 (
    .i_clk_timer      (i_clk_timer),
    .i_rst_n_timer    (w_rst_n_timer),
    .i_write_low      (reg_wr_en_dly && (reg_wr_addr_dly == 16'h013c)),
    .i_write_high     (reg_wr_en_dly && (reg_wr_addr_dly == 16'h0140)),
    .i_value_low      (w_o_c1_ow_width),
    .i_value_high     (w_o_c1_ow_h_hi),
    .i_activate       (w_opm_accept[1]),
    .i_dma_update     (w_dma_width_update[1]),
    .i_dma_value      (w_dma_compare_value_flat[1*PARA_COUNTER_WIDTH +: PARA_COUNTER_WIDTH]),
    .o_active_value   (w_opm_width_active[1]),
    .o_pending_value  (w_opm_width_pending[1]),
    .o_pending_valid  (w_opm_width_pending_valid[1])
  );
  m_vlsit_timer_timing_stage #(.PARA_VALUE_WIDTH (PARA_COUNTER_WIDTH)) u_cmp_stage_2 (
    .i_clk_timer      (i_clk_timer),
    .i_rst_n_timer    (w_rst_n_timer),
    .i_write_low      (reg_wr_en_dly && (reg_wr_addr_dly == 16'h0048)),
    .i_write_high     (reg_wr_en_dly && (reg_wr_addr_dly == 16'h004c)),
    .i_value_low      (w_o_ch2_cmp_value),
    .i_value_high     (w_o_c2_cmp_h_hi),
    .i_activate       (w_update_event),
    .i_dma_update     (w_dma_compare_update[2]),
    .i_dma_value      (w_dma_compare_value_flat[2*PARA_COUNTER_WIDTH +: PARA_COUNTER_WIDTH]),
    .o_active_value   (w_compare_active[2]),
    .o_pending_value  (w_compare_pending[2]),
    .o_pending_valid  (w_compare_pending_valid[2])
  );
  m_vlsit_timer_timing_stage #(.PARA_VALUE_WIDTH (PARA_COUNTER_WIDTH)) u_timeout_stage_2 (
    .i_clk_timer      (i_clk_timer),
    .i_rst_n_timer    (w_rst_n_timer),
    .i_write_low      (reg_wr_en_dly && (reg_wr_addr_dly == 16'h00bc)),
    .i_write_high     (reg_wr_en_dly && (reg_wr_addr_dly == 16'h00c0)),
    .i_value_low      (w_o_c2_tout_thr),
    .i_value_high     (w_o_c2_tout_h_hi),
    .i_activate       (w_timeout_start_event[2]),
    .i_dma_update     (1'b0),
    .i_dma_value      ('0),
    .o_active_value   (w_timeout_active[2]),
    .o_pending_value  (w_timeout_pending[2]),
    .o_pending_valid  (w_timeout_pending_valid[2])
  );
  m_vlsit_timer_timing_stage #(.PARA_VALUE_WIDTH (PARA_COUNTER_WIDTH)) u_opm_width_stage_2 (
    .i_clk_timer      (i_clk_timer),
    .i_rst_n_timer    (w_rst_n_timer),
    .i_write_low      (reg_wr_en_dly && (reg_wr_addr_dly == 16'h0144)),
    .i_write_high     (reg_wr_en_dly && (reg_wr_addr_dly == 16'h0148)),
    .i_value_low      (w_o_c2_ow_width),
    .i_value_high     (w_o_c2_ow_h_hi),
    .i_activate       (w_opm_accept[2]),
    .i_dma_update     (w_dma_width_update[2]),
    .i_dma_value      (w_dma_compare_value_flat[2*PARA_COUNTER_WIDTH +: PARA_COUNTER_WIDTH]),
    .o_active_value   (w_opm_width_active[2]),
    .o_pending_value  (w_opm_width_pending[2]),
    .o_pending_valid  (w_opm_width_pending_valid[2])
  );
  m_vlsit_timer_timing_stage #(.PARA_VALUE_WIDTH (PARA_COUNTER_WIDTH)) u_cmp_stage_3 (
    .i_clk_timer      (i_clk_timer),
    .i_rst_n_timer    (w_rst_n_timer),
    .i_write_low      (reg_wr_en_dly && (reg_wr_addr_dly == 16'h0050)),
    .i_write_high     (reg_wr_en_dly && (reg_wr_addr_dly == 16'h0054)),
    .i_value_low      (w_o_ch3_cmp_value),
    .i_value_high     (w_o_c3_cmp_h_hi),
    .i_activate       (w_update_event),
    .i_dma_update     (w_dma_compare_update[3]),
    .i_dma_value      (w_dma_compare_value_flat[3*PARA_COUNTER_WIDTH +: PARA_COUNTER_WIDTH]),
    .o_active_value   (w_compare_active[3]),
    .o_pending_value  (w_compare_pending[3]),
    .o_pending_valid  (w_compare_pending_valid[3])
  );
  m_vlsit_timer_timing_stage #(.PARA_VALUE_WIDTH (PARA_COUNTER_WIDTH)) u_timeout_stage_3 (
    .i_clk_timer      (i_clk_timer),
    .i_rst_n_timer    (w_rst_n_timer),
    .i_write_low      (reg_wr_en_dly && (reg_wr_addr_dly == 16'h00c4)),
    .i_write_high     (reg_wr_en_dly && (reg_wr_addr_dly == 16'h00c8)),
    .i_value_low      (w_o_c3_tout_thr),
    .i_value_high     (w_o_c3_tout_h_hi),
    .i_activate       (w_timeout_start_event[3]),
    .i_dma_update     (1'b0),
    .i_dma_value      ('0),
    .o_active_value   (w_timeout_active[3]),
    .o_pending_value  (w_timeout_pending[3]),
    .o_pending_valid  (w_timeout_pending_valid[3])
  );
  m_vlsit_timer_timing_stage #(.PARA_VALUE_WIDTH (PARA_COUNTER_WIDTH)) u_opm_width_stage_3 (
    .i_clk_timer      (i_clk_timer),
    .i_rst_n_timer    (w_rst_n_timer),
    .i_write_low      (reg_wr_en_dly && (reg_wr_addr_dly == 16'h014c)),
    .i_write_high     (reg_wr_en_dly && (reg_wr_addr_dly == 16'h0150)),
    .i_value_low      (w_o_c3_ow_width),
    .i_value_high     (w_o_c3_ow_h_hi),
    .i_activate       (w_opm_accept[3]),
    .i_dma_update     (w_dma_width_update[3]),
    .i_dma_value      (w_dma_compare_value_flat[3*PARA_COUNTER_WIDTH +: PARA_COUNTER_WIDTH]),
    .o_active_value   (w_opm_width_active[3]),
    .o_pending_value  (w_opm_width_pending[3]),
    .o_pending_valid  (w_opm_width_pending_valid[3])
  );
  m_vlsit_timer_timing_stage #(.PARA_VALUE_WIDTH (PARA_COUNTER_WIDTH)) u_cmp_stage_4 (
    .i_clk_timer      (i_clk_timer),
    .i_rst_n_timer    (w_rst_n_timer),
    .i_write_low      (reg_wr_en_dly && (reg_wr_addr_dly == 16'h0058)),
    .i_write_high     (reg_wr_en_dly && (reg_wr_addr_dly == 16'h005c)),
    .i_value_low      (w_o_ch4_cmp_value),
    .i_value_high     (w_o_c4_cmp_h_hi),
    .i_activate       (w_update_event),
    .i_dma_update     (w_dma_compare_update[4]),
    .i_dma_value      (w_dma_compare_value_flat[4*PARA_COUNTER_WIDTH +: PARA_COUNTER_WIDTH]),
    .o_active_value   (w_compare_active[4]),
    .o_pending_value  (w_compare_pending[4]),
    .o_pending_valid  (w_compare_pending_valid[4])
  );
  m_vlsit_timer_timing_stage #(.PARA_VALUE_WIDTH (PARA_COUNTER_WIDTH)) u_timeout_stage_4 (
    .i_clk_timer      (i_clk_timer),
    .i_rst_n_timer    (w_rst_n_timer),
    .i_write_low      (reg_wr_en_dly && (reg_wr_addr_dly == 16'h00cc)),
    .i_write_high     (reg_wr_en_dly && (reg_wr_addr_dly == 16'h00d0)),
    .i_value_low      (w_o_c4_tout_thr),
    .i_value_high     (w_o_c4_tout_h_hi),
    .i_activate       (w_timeout_start_event[4]),
    .i_dma_update     (1'b0),
    .i_dma_value      ('0),
    .o_active_value   (w_timeout_active[4]),
    .o_pending_value  (w_timeout_pending[4]),
    .o_pending_valid  (w_timeout_pending_valid[4])
  );
  m_vlsit_timer_timing_stage #(.PARA_VALUE_WIDTH (PARA_COUNTER_WIDTH)) u_opm_width_stage_4 (
    .i_clk_timer      (i_clk_timer),
    .i_rst_n_timer    (w_rst_n_timer),
    .i_write_low      (reg_wr_en_dly && (reg_wr_addr_dly == 16'h0154)),
    .i_write_high     (reg_wr_en_dly && (reg_wr_addr_dly == 16'h0158)),
    .i_value_low      (w_o_c4_ow_width),
    .i_value_high     (w_o_c4_ow_h_hi),
    .i_activate       (w_opm_accept[4]),
    .i_dma_update     (w_dma_width_update[4]),
    .i_dma_value      (w_dma_compare_value_flat[4*PARA_COUNTER_WIDTH +: PARA_COUNTER_WIDTH]),
    .o_active_value   (w_opm_width_active[4]),
    .o_pending_value  (w_opm_width_pending[4]),
    .o_pending_valid  (w_opm_width_pending_valid[4])
  );
  m_vlsit_timer_timing_stage #(.PARA_VALUE_WIDTH (PARA_COUNTER_WIDTH)) u_cmp_stage_5 (
    .i_clk_timer      (i_clk_timer),
    .i_rst_n_timer    (w_rst_n_timer),
    .i_write_low      (reg_wr_en_dly && (reg_wr_addr_dly == 16'h0060)),
    .i_write_high     (reg_wr_en_dly && (reg_wr_addr_dly == 16'h0064)),
    .i_value_low      (w_o_ch5_cmp_value),
    .i_value_high     (w_o_c5_cmp_h_hi),
    .i_activate       (w_update_event),
    .i_dma_update     (w_dma_compare_update[5]),
    .i_dma_value      (w_dma_compare_value_flat[5*PARA_COUNTER_WIDTH +: PARA_COUNTER_WIDTH]),
    .o_active_value   (w_compare_active[5]),
    .o_pending_value  (w_compare_pending[5]),
    .o_pending_valid  (w_compare_pending_valid[5])
  );
  m_vlsit_timer_timing_stage #(.PARA_VALUE_WIDTH (PARA_COUNTER_WIDTH)) u_timeout_stage_5 (
    .i_clk_timer      (i_clk_timer),
    .i_rst_n_timer    (w_rst_n_timer),
    .i_write_low      (reg_wr_en_dly && (reg_wr_addr_dly == 16'h00d4)),
    .i_write_high     (reg_wr_en_dly && (reg_wr_addr_dly == 16'h00d8)),
    .i_value_low      (w_o_c5_tout_thr),
    .i_value_high     (w_o_c5_tout_h_hi),
    .i_activate       (w_timeout_start_event[5]),
    .i_dma_update     (1'b0),
    .i_dma_value      ('0),
    .o_active_value   (w_timeout_active[5]),
    .o_pending_value  (w_timeout_pending[5]),
    .o_pending_valid  (w_timeout_pending_valid[5])
  );
  m_vlsit_timer_timing_stage #(.PARA_VALUE_WIDTH (PARA_COUNTER_WIDTH)) u_opm_width_stage_5 (
    .i_clk_timer      (i_clk_timer),
    .i_rst_n_timer    (w_rst_n_timer),
    .i_write_low      (reg_wr_en_dly && (reg_wr_addr_dly == 16'h015c)),
    .i_write_high     (reg_wr_en_dly && (reg_wr_addr_dly == 16'h0160)),
    .i_value_low      (w_o_c5_ow_width),
    .i_value_high     (w_o_c5_ow_h_hi),
    .i_activate       (w_opm_accept[5]),
    .i_dma_update     (w_dma_width_update[5]),
    .i_dma_value      (w_dma_compare_value_flat[5*PARA_COUNTER_WIDTH +: PARA_COUNTER_WIDTH]),
    .o_active_value   (w_opm_width_active[5]),
    .o_pending_value  (w_opm_width_pending[5]),
    .o_pending_valid  (w_opm_width_pending_valid[5])
  );
  m_vlsit_timer_timing_stage #(.PARA_VALUE_WIDTH (PARA_COUNTER_WIDTH)) u_cmp_stage_6 (
    .i_clk_timer      (i_clk_timer),
    .i_rst_n_timer    (w_rst_n_timer),
    .i_write_low      (reg_wr_en_dly && (reg_wr_addr_dly == 16'h0068)),
    .i_write_high     (reg_wr_en_dly && (reg_wr_addr_dly == 16'h006c)),
    .i_value_low      (w_o_ch6_cmp_value),
    .i_value_high     (w_o_c6_cmp_h_hi),
    .i_activate       (w_update_event),
    .i_dma_update     (w_dma_compare_update[6]),
    .i_dma_value      (w_dma_compare_value_flat[6*PARA_COUNTER_WIDTH +: PARA_COUNTER_WIDTH]),
    .o_active_value   (w_compare_active[6]),
    .o_pending_value  (w_compare_pending[6]),
    .o_pending_valid  (w_compare_pending_valid[6])
  );
  m_vlsit_timer_timing_stage #(.PARA_VALUE_WIDTH (PARA_COUNTER_WIDTH)) u_timeout_stage_6 (
    .i_clk_timer      (i_clk_timer),
    .i_rst_n_timer    (w_rst_n_timer),
    .i_write_low      (reg_wr_en_dly && (reg_wr_addr_dly == 16'h00dc)),
    .i_write_high     (reg_wr_en_dly && (reg_wr_addr_dly == 16'h00e0)),
    .i_value_low      (w_o_c6_tout_thr),
    .i_value_high     (w_o_c6_tout_h_hi),
    .i_activate       (w_timeout_start_event[6]),
    .i_dma_update     (1'b0),
    .i_dma_value      ('0),
    .o_active_value   (w_timeout_active[6]),
    .o_pending_value  (w_timeout_pending[6]),
    .o_pending_valid  (w_timeout_pending_valid[6])
  );
  m_vlsit_timer_timing_stage #(.PARA_VALUE_WIDTH (PARA_COUNTER_WIDTH)) u_opm_width_stage_6 (
    .i_clk_timer      (i_clk_timer),
    .i_rst_n_timer    (w_rst_n_timer),
    .i_write_low      (reg_wr_en_dly && (reg_wr_addr_dly == 16'h0164)),
    .i_write_high     (reg_wr_en_dly && (reg_wr_addr_dly == 16'h0168)),
    .i_value_low      (w_o_c6_ow_width),
    .i_value_high     (w_o_c6_ow_h_hi),
    .i_activate       (w_opm_accept[6]),
    .i_dma_update     (w_dma_width_update[6]),
    .i_dma_value      (w_dma_compare_value_flat[6*PARA_COUNTER_WIDTH +: PARA_COUNTER_WIDTH]),
    .o_active_value   (w_opm_width_active[6]),
    .o_pending_value  (w_opm_width_pending[6]),
    .o_pending_valid  (w_opm_width_pending_valid[6])
  );
  m_vlsit_timer_timing_stage #(.PARA_VALUE_WIDTH (PARA_COUNTER_WIDTH)) u_cmp_stage_7 (
    .i_clk_timer      (i_clk_timer),
    .i_rst_n_timer    (w_rst_n_timer),
    .i_write_low      (reg_wr_en_dly && (reg_wr_addr_dly == 16'h0070)),
    .i_write_high     (reg_wr_en_dly && (reg_wr_addr_dly == 16'h0074)),
    .i_value_low      (w_o_ch7_cmp_value),
    .i_value_high     (w_o_c7_cmp_h_hi),
    .i_activate       (w_update_event),
    .i_dma_update     (w_dma_compare_update[7]),
    .i_dma_value      (w_dma_compare_value_flat[7*PARA_COUNTER_WIDTH +: PARA_COUNTER_WIDTH]),
    .o_active_value   (w_compare_active[7]),
    .o_pending_value  (w_compare_pending[7]),
    .o_pending_valid  (w_compare_pending_valid[7])
  );
  m_vlsit_timer_timing_stage #(.PARA_VALUE_WIDTH (PARA_COUNTER_WIDTH)) u_timeout_stage_7 (
    .i_clk_timer      (i_clk_timer),
    .i_rst_n_timer    (w_rst_n_timer),
    .i_write_low      (reg_wr_en_dly && (reg_wr_addr_dly == 16'h00e4)),
    .i_write_high     (reg_wr_en_dly && (reg_wr_addr_dly == 16'h00e8)),
    .i_value_low      (w_o_c7_tout_thr),
    .i_value_high     (w_o_c7_tout_h_hi),
    .i_activate       (w_timeout_start_event[7]),
    .i_dma_update     (1'b0),
    .i_dma_value      ('0),
    .o_active_value   (w_timeout_active[7]),
    .o_pending_value  (w_timeout_pending[7]),
    .o_pending_valid  (w_timeout_pending_valid[7])
  );
  m_vlsit_timer_timing_stage #(.PARA_VALUE_WIDTH (PARA_COUNTER_WIDTH)) u_opm_width_stage_7 (
    .i_clk_timer      (i_clk_timer),
    .i_rst_n_timer    (w_rst_n_timer),
    .i_write_low      (reg_wr_en_dly && (reg_wr_addr_dly == 16'h016c)),
    .i_write_high     (reg_wr_en_dly && (reg_wr_addr_dly == 16'h0170)),
    .i_value_low      (w_o_c7_ow_width),
    .i_value_high     (w_o_c7_ow_h_hi),
    .i_activate       (w_opm_accept[7]),
    .i_dma_update     (w_dma_width_update[7]),
    .i_dma_value      (w_dma_compare_value_flat[7*PARA_COUNTER_WIDTH +: PARA_COUNTER_WIDTH]),
    .o_active_value   (w_opm_width_active[7]),
    .o_pending_value  (w_opm_width_pending[7]),
    .o_pending_valid  (w_opm_width_pending_valid[7])
  );



  // Fixed eight-channel bank; the pin counts mask unused pins and set the bus widths.
  logic [7:0] w_timer_pin;
  assign o_timer_ch = w_timer_pin[PARA_OUTPUT_COUNT-1:0];
  generate
    for (genvar g_channel = 0; g_channel < 8; g_channel = g_channel + 1) begin : gen_timer_channel
      m_vlsit_timer_channel #(.PARA_COUNTER_WIDTH (PARA_COUNTER_WIDTH)) u_channel (
        .i_clk_timer             (i_clk_timer),
        .i_rst_n_timer           (w_rst_n_timer),
        .i_timer_enable          (w_channel_available[g_channel] && w_o_ctrl_timer_en),
        .i_timer_tick            (w_timer_tick),
        .i_dir_down              (w_o_ctrl_dir_down),
        .i_count                 (w_counter),
        .i_compare               (w_compare_active[g_channel]),
        .i_timeout_threshold     (w_timeout_pending_valid[g_channel] && w_timeout_start_event[g_channel] ? w_timeout_pending[g_channel] : w_timeout_active[g_channel]),
        .i_opm_width             (w_opm_width_pending_valid[g_channel] && w_opm_accept[g_channel] ? w_opm_width_pending[g_channel] : w_opm_width_active[g_channel]),
        .i_mode                  (w_ch_mode[g_channel]),
        .i_edge_sel              (w_ch_edge_sel[g_channel]),
        .i_cmp_action            (w_ch_cmp_action[g_channel]),
        .i_timeout_enable        (w_ch_timeout_en[g_channel]),
        .i_timeout_start_mode    (w_ch_timeout_start[g_channel]),
        .i_opm_sw_rearm_en       (w_ch_sw_arm_en[g_channel]),
        .i_opm_rearm_cmd         (w_ch_arm_cmd[g_channel]),
        .i_output_polarity       (w_ch_out_pol[g_channel]),
        .i_idle_level            (w_ch_idle_level[g_channel]),
        .i_force_enable          (w_ch_force_en[g_channel]),
        .i_force_value           (w_ch_force_val[g_channel]),
        .i_capture_rising        (w_filter_rising[g_channel]),
        .i_capture_falling       (w_filter_falling[g_channel]),
        .i_trigger_rising        (w_trigger_rising[g_channel]),
        .i_trigger_falling       (w_trigger_falling[g_channel]),
        .o_capture_event         (w_capture_event[g_channel]),
        .o_capture_rising        (w_capture_rising_event[g_channel]),
        .o_compare_event         (w_compare_event[g_channel]),
        .o_timeout_event         (w_timeout_event[g_channel]),
        .o_opm_busy              (w_opm_busy[g_channel]),
        .o_opm_armed             (w_opm_armed[g_channel]),
        .o_timer_out             (w_timer_output[g_channel])
      );
    end
  endgenerate

  assign w_capture_fifo_push_data[0] = {w_counter, w_capture_rising_event[0]};
  assign w_clear_capture_overrun[0] = reg_irq_ovf_prev[0] && !w_o_irq_raw0_ovf0;
  assign w_timer_pin[0] = w_channel_available[0] ? w_timer_output[0] : 1'b0;
  m_vlsit_timer_capture_fifo #(.PARA_DATA_W (32'd1 + PARA_COUNTER_WIDTH)) u_capture_fifo_0 (
    .i_clk_timer          (i_clk_timer),
    .i_rst_n_timer        (w_rst_n_timer),
    .i_push               (w_capture_event[0]),
    .i_data               (w_capture_fifo_push_data[0]),
    .i_pop                (w_capture_fifo_pop[0]),
    .i_flush_clear        (w_dma_cap_flush_clear),
    .o_flush_busy         (w_capture_fifo_flush_busy[0]),
    .o_data               (w_capture_fifo_head[0]),
    .o_valid              (w_capture_fifo_valid[0]),
    .o_full               (w_capture_fifo_full[0]),
    .o_level              (w_capture_level[0]),
    .i_clear_overrun      (w_clear_capture_overrun[0]),
    .o_overrun            (w_capture_fifo_overrun[0]),
    .o_overflow_event     (w_capture_fifo_overflow_event[0])
  );
  assign w_capture_fifo_push_data[1] = {w_counter, w_capture_rising_event[1]};
  assign w_clear_capture_overrun[1] = reg_irq_ovf_prev[1] && !w_o_irq_raw0_ovf1;
  assign w_timer_pin[1] = w_channel_available[1] ? w_timer_output[1] : 1'b0;
  m_vlsit_timer_capture_fifo #(.PARA_DATA_W (32'd1 + PARA_COUNTER_WIDTH)) u_capture_fifo_1 (
    .i_clk_timer          (i_clk_timer),
    .i_rst_n_timer        (w_rst_n_timer),
    .i_push               (w_capture_event[1]),
    .i_data               (w_capture_fifo_push_data[1]),
    .i_pop                (w_capture_fifo_pop[1]),
    .i_flush_clear        (w_dma_cap_flush_clear),
    .o_flush_busy         (w_capture_fifo_flush_busy[1]),
    .o_data               (w_capture_fifo_head[1]),
    .o_valid              (w_capture_fifo_valid[1]),
    .o_full               (w_capture_fifo_full[1]),
    .o_level              (w_capture_level[1]),
    .i_clear_overrun      (w_clear_capture_overrun[1]),
    .o_overrun            (w_capture_fifo_overrun[1]),
    .o_overflow_event     (w_capture_fifo_overflow_event[1])
  );
  assign w_capture_fifo_push_data[2] = {w_counter, w_capture_rising_event[2]};
  assign w_clear_capture_overrun[2] = reg_irq_ovf_prev[2] && !w_o_irq_raw0_ovf2;
  assign w_timer_pin[2] = w_channel_available[2] ? w_timer_output[2] : 1'b0;
  m_vlsit_timer_capture_fifo #(.PARA_DATA_W (32'd1 + PARA_COUNTER_WIDTH)) u_capture_fifo_2 (
    .i_clk_timer          (i_clk_timer),
    .i_rst_n_timer        (w_rst_n_timer),
    .i_push               (w_capture_event[2]),
    .i_data               (w_capture_fifo_push_data[2]),
    .i_pop                (w_capture_fifo_pop[2]),
    .i_flush_clear        (w_dma_cap_flush_clear),
    .o_flush_busy         (w_capture_fifo_flush_busy[2]),
    .o_data               (w_capture_fifo_head[2]),
    .o_valid              (w_capture_fifo_valid[2]),
    .o_full               (w_capture_fifo_full[2]),
    .o_level              (w_capture_level[2]),
    .i_clear_overrun      (w_clear_capture_overrun[2]),
    .o_overrun            (w_capture_fifo_overrun[2]),
    .o_overflow_event     (w_capture_fifo_overflow_event[2])
  );
  assign w_capture_fifo_push_data[3] = {w_counter, w_capture_rising_event[3]};
  assign w_clear_capture_overrun[3] = reg_irq_ovf_prev[3] && !w_o_irq_raw0_ovf3;
  assign w_timer_pin[3] = w_channel_available[3] ? w_timer_output[3] : 1'b0;
  m_vlsit_timer_capture_fifo #(.PARA_DATA_W (32'd1 + PARA_COUNTER_WIDTH)) u_capture_fifo_3 (
    .i_clk_timer          (i_clk_timer),
    .i_rst_n_timer        (w_rst_n_timer),
    .i_push               (w_capture_event[3]),
    .i_data               (w_capture_fifo_push_data[3]),
    .i_pop                (w_capture_fifo_pop[3]),
    .i_flush_clear        (w_dma_cap_flush_clear),
    .o_flush_busy         (w_capture_fifo_flush_busy[3]),
    .o_data               (w_capture_fifo_head[3]),
    .o_valid              (w_capture_fifo_valid[3]),
    .o_full               (w_capture_fifo_full[3]),
    .o_level              (w_capture_level[3]),
    .i_clear_overrun      (w_clear_capture_overrun[3]),
    .o_overrun            (w_capture_fifo_overrun[3]),
    .o_overflow_event     (w_capture_fifo_overflow_event[3])
  );
  assign w_capture_fifo_push_data[4] = {w_counter, w_capture_rising_event[4]};
  assign w_clear_capture_overrun[4] = reg_irq_ovf_prev[4] && !w_o_irq_raw0_ovf4;
  assign w_timer_pin[4] = w_channel_available[4] ? w_timer_output[4] : 1'b0;
  m_vlsit_timer_capture_fifo #(.PARA_DATA_W (32'd1 + PARA_COUNTER_WIDTH)) u_capture_fifo_4 (
    .i_clk_timer          (i_clk_timer),
    .i_rst_n_timer        (w_rst_n_timer),
    .i_push               (w_capture_event[4]),
    .i_data               (w_capture_fifo_push_data[4]),
    .i_pop                (w_capture_fifo_pop[4]),
    .i_flush_clear        (w_dma_cap_flush_clear),
    .o_flush_busy         (w_capture_fifo_flush_busy[4]),
    .o_data               (w_capture_fifo_head[4]),
    .o_valid              (w_capture_fifo_valid[4]),
    .o_full               (w_capture_fifo_full[4]),
    .o_level              (w_capture_level[4]),
    .i_clear_overrun      (w_clear_capture_overrun[4]),
    .o_overrun            (w_capture_fifo_overrun[4]),
    .o_overflow_event     (w_capture_fifo_overflow_event[4])
  );
  assign w_capture_fifo_push_data[5] = {w_counter, w_capture_rising_event[5]};
  assign w_clear_capture_overrun[5] = reg_irq_ovf_prev[5] && !w_o_irq_raw0_ovf5;
  assign w_timer_pin[5] = w_channel_available[5] ? w_timer_output[5] : 1'b0;
  m_vlsit_timer_capture_fifo #(.PARA_DATA_W (32'd1 + PARA_COUNTER_WIDTH)) u_capture_fifo_5 (
    .i_clk_timer          (i_clk_timer),
    .i_rst_n_timer        (w_rst_n_timer),
    .i_push               (w_capture_event[5]),
    .i_data               (w_capture_fifo_push_data[5]),
    .i_pop                (w_capture_fifo_pop[5]),
    .i_flush_clear        (w_dma_cap_flush_clear),
    .o_flush_busy         (w_capture_fifo_flush_busy[5]),
    .o_data               (w_capture_fifo_head[5]),
    .o_valid              (w_capture_fifo_valid[5]),
    .o_full               (w_capture_fifo_full[5]),
    .o_level              (w_capture_level[5]),
    .i_clear_overrun      (w_clear_capture_overrun[5]),
    .o_overrun            (w_capture_fifo_overrun[5]),
    .o_overflow_event     (w_capture_fifo_overflow_event[5])
  );
  assign w_capture_fifo_push_data[6] = {w_counter, w_capture_rising_event[6]};
  assign w_clear_capture_overrun[6] = reg_irq_ovf_prev[6] && !w_o_irq_raw0_ovf6;
  assign w_timer_pin[6] = w_channel_available[6] ? w_timer_output[6] : 1'b0;
  m_vlsit_timer_capture_fifo #(.PARA_DATA_W (32'd1 + PARA_COUNTER_WIDTH)) u_capture_fifo_6 (
    .i_clk_timer          (i_clk_timer),
    .i_rst_n_timer        (w_rst_n_timer),
    .i_push               (w_capture_event[6]),
    .i_data               (w_capture_fifo_push_data[6]),
    .i_pop                (w_capture_fifo_pop[6]),
    .i_flush_clear        (w_dma_cap_flush_clear),
    .o_flush_busy         (w_capture_fifo_flush_busy[6]),
    .o_data               (w_capture_fifo_head[6]),
    .o_valid              (w_capture_fifo_valid[6]),
    .o_full               (w_capture_fifo_full[6]),
    .o_level              (w_capture_level[6]),
    .i_clear_overrun      (w_clear_capture_overrun[6]),
    .o_overrun            (w_capture_fifo_overrun[6]),
    .o_overflow_event     (w_capture_fifo_overflow_event[6])
  );
  assign w_capture_fifo_push_data[7] = {w_counter, w_capture_rising_event[7]};
  assign w_clear_capture_overrun[7] = reg_irq_ovf_prev[7] && !w_o_irq_raw0_ovf7;
  assign w_timer_pin[7] = w_channel_available[7] ? w_timer_output[7] : 1'b0;
  m_vlsit_timer_capture_fifo #(.PARA_DATA_W (32'd1 + PARA_COUNTER_WIDTH)) u_capture_fifo_7 (
    .i_clk_timer          (i_clk_timer),
    .i_rst_n_timer        (w_rst_n_timer),
    .i_push               (w_capture_event[7]),
    .i_data               (w_capture_fifo_push_data[7]),
    .i_pop                (w_capture_fifo_pop[7]),
    .i_flush_clear        (w_dma_cap_flush_clear),
    .o_flush_busy         (w_capture_fifo_flush_busy[7]),
    .o_data               (w_capture_fifo_head[7]),
    .o_valid              (w_capture_fifo_valid[7]),
    .o_full               (w_capture_fifo_full[7]),
    .o_level              (w_capture_level[7]),
    .i_clear_overrun      (w_clear_capture_overrun[7]),
    .o_overrun            (w_capture_fifo_overrun[7]),
    .o_overflow_event     (w_capture_fifo_overflow_event[7])
  );
  // Round-robin arbitration preserves source FIFO heads while the shared capture queue is full.
  always_comb begin : p_com_capture_arbiter
    w_arb_found = 1'b0;
    w_arb_sel = reg_arb_rr_pointer;
    w_arb_pop = '0;
    for (int w_arb_loop = 0; w_arb_loop < 8; w_arb_loop = w_arb_loop + 1) begin
      if (!w_arb_found && w_capture_fifo_valid[(reg_arb_rr_pointer + w_arb_loop[2:0])]) begin
        w_arb_found = 1'b1;
        w_arb_sel = (reg_arb_rr_pointer + w_arb_loop[2:0]);
      end
    end
    if (w_arb_found && !w_cap_queue_full)
      w_arb_pop[w_arb_sel] = 1'b1;
  end
  assign w_cap_queue_push = w_arb_found && !w_cap_queue_full;
  assign w_cap_queue_push_data = {27'd0,
      (w_capture_fifo_head[w_arb_sel][0] ? 2'b00 : 2'b01), w_arb_sel,
      w_capture_fifo_head[w_arb_sel][PARA_COUNTER_WIDTH:1]};
  assign w_capture_fifo_pop = w_arb_pop;
  always_ff @(posedge i_clk_timer, negedge w_rst_n_timer) begin : p_ff_capture_rr
    if (!w_rst_n_timer)
      reg_arb_rr_pointer <= '0;
    else if (w_cap_queue_push)
      reg_arb_rr_pointer <= (w_arb_sel == 3'd7) ? 3'd0 : (w_arb_sel + 1'b1);
  end

  m_vlsit_timer_record_fifo #(.PARA_DATA_WIDTH (LPARA_RECORD_W)) u_capture_dma_queue (
    .i_clk_timer       (i_clk_timer),
    .i_rst_n_timer     (w_rst_n_timer),
    .i_push            (w_cap_queue_push),
    .i_push_data       (w_cap_queue_push_data),
    .i_pop             (w_dma_cap_pop),
    .i_flush_clear     (w_dma_cap_flush_clear),
    .o_flush_busy      (w_capture_queue_flush_busy),
    .o_head_data       (w_cap_queue_head),
    .o_valid           (w_cap_queue_valid),
    .o_full            (w_cap_queue_full),
    .o_level           (w_cap_queue_level),
    .i_clear_overflow  (1'b0),
    .o_overflow        (w_cap_queue_overflow),
    .o_overflow_event  (w_cap_queue_overflow_event)
  );



  // APB DMA stream bridge returns wait states until each timer-domain beat completes.
  m_vlsit_timer_apb_stream #(.PARA_ASYNC (PARA_ASYNC)) u_apb_stream_bridge (
    .i_clk_apb       (i_clk_apb),
    .i_rst_n_apb     (w_rst_n_apb),
    .i_psel_apb      (i_psel_apb),
    .i_penable_apb   (i_penable_apb),
    .i_pwrite_apb    (i_pwrite_apb),
    .i_paddr_apb     (i_paddr_apb),
    .i_pwdata_apb    (i_pwdata_apb),
    .i_pstrb_apb     (i_pstrb_apb),
    .i_stream_sel_apb(w_stream_sel),
    .o_pready_apb    (w_stream_pready),
    .o_prdata_apb    (w_stream_prdata),
    .o_pslverr_apb   (w_stream_pslverr),
    .i_clk_timer     (i_clk_timer),
    .i_rst_n_timer   (w_rst_n_timer),
    .o_req_timer     (w_stream_req_timer),
    .o_write_timer   (w_stream_write_timer),
    .o_addr_timer    (w_stream_addr_timer),
    .o_wdata_timer   (w_stream_wdata_timer),
    .o_wstrb_timer   (w_stream_wstrb_timer),
    .i_ready_timer   (w_stream_ready_timer),
    .i_rdata_timer   (w_stream_rdata_timer),
    .i_error_timer   (w_stream_error_timer)
  );

  // Capture and compare/update DMA: one 4-phase req/ack pair each, over shared APB record windows.
  m_vlsit_timer_dma #(
    .PARA_COUNTER_WIDTH (PARA_COUNTER_WIDTH),
    .PARA_OUTPUT_COUNT (PARA_OUTPUT_COUNT)
  ) u_timer_dma (
    .i_clk_timer          (i_clk_timer),
    .i_rst_n_timer        (w_rst_n_timer),
    .i_cap_valid          (w_cap_queue_valid),
    .i_cap_head           (w_cap_queue_head),
    .i_cap_level          (w_cap_queue_level),
    .i_cap_flush_busy     ((|w_capture_fifo_flush_busy) | w_capture_queue_flush_busy),
    .o_cap_pop            (w_dma_cap_pop),
    .o_cap_flush_clear    (w_dma_cap_flush_clear),
    .i_cap_record_cfg     (w_o_dma_cfg_cap_rec_cnt),
    .i_cmp_record_cfg     (w_o_dma_cfg_cmp_rec_cnt),
    .i_update_event       (w_update_event),
    .o_dma_cap_req        (o_dma_cap_req),
    .i_dma_cap_ack        (i_dma_cap_ack),
    .o_dma_cmp_req        (o_dma_cmp_req),
    .i_dma_cmp_ack        (i_dma_cmp_ack),
    .i_cap_clr            (w_o_dma_cfg_cap_clr),
    .i_cmp_clr            (w_o_dma_cfg_cmp_clr),
    .o_cap_clr_done       (w_dma_cap_clr_done),
    .o_cmp_clr_done       (w_dma_cmp_clr_done),
    .i_stream_req         (w_stream_req_timer),
    .i_stream_write       (w_stream_write_timer),
    .i_stream_addr        (w_stream_addr_timer),
    .i_stream_wdata       (w_stream_wdata_timer),
    .i_stream_wstrb       (w_stream_wstrb_timer),
    .o_stream_ready       (w_stream_ready_timer),
    .o_stream_rdata       (w_stream_rdata_timer),
    .o_stream_error       (w_stream_error_timer),
    .o_update_batch_valid (w_dma_update_batch_valid),
    .o_update_batch_count (w_dma_update_batch_count),
    .o_update_batch_data  (w_dma_update_batch_data),
    .o_dma_error_event    (w_dma_error_event),
    .o_cap_queue_level    (w_dma_cap_level),
    .o_cmp_queue_level    (w_dma_cmp_level),
    .o_cap_reserved_count (w_dma_cap_reserved),
    .o_cmp_reserved_count (w_dma_cmp_reserved),
    .o_cap_req_status     (w_dma_cap_req_status),
    .o_cap_burst_status   (w_dma_cap_burst_status),
    .o_cap_clr_status     (w_dma_cap_clr_status),
    .o_cmp_req_status     (w_dma_cmp_req_status),
    .o_cmp_burst_status   (w_dma_cmp_burst_status),
    .o_cmp_clr_status     (w_dma_cmp_clr_status)
  );

  // Decode the validated update batch and present values to timing shadows on the same boundary.
  always_comb begin : p_com_dma_update
    w_dma_compare_update = '0;
    w_dma_width_update = '0;
    w_dma_compare_value_flat = '0;
    w_dma_period_value = '0;
    w_dma_period_update = 1'b0;
    w_dma_prescale_value = '0;
    w_dma_prescale_update = 1'b0;
    w_dma_record = '0;
    w_dma_tag = '0;
    w_dma_value = '0;
    for (int w_dma_loop = 0; w_dma_loop < 4; w_dma_loop = w_dma_loop + 1) begin
      if (w_dma_update_batch_valid && w_update_event &&
          (w_dma_loop < w_dma_update_batch_count)) begin
        w_dma_record = w_dma_update_batch_data[w_dma_loop*LPARA_RECORD_W +: LPARA_RECORD_W];
        w_dma_tag = w_dma_record[PARA_COUNTER_WIDTH+4:PARA_COUNTER_WIDTH];
        w_dma_value = w_dma_record[PARA_COUNTER_WIDTH-1:0];
        case (w_dma_tag[4:3])
          2'b00: begin
            w_dma_compare_update[w_dma_tag[2:0]] = 1'b1;
            w_dma_compare_value_flat[w_dma_tag[2:0]*PARA_COUNTER_WIDTH +: PARA_COUNTER_WIDTH] = w_dma_value;
          end
          2'b01: begin
            w_dma_period_update = 1'b1;
            w_dma_period_value = w_dma_value;
          end
          2'b10: begin
            w_dma_prescale_update = 1'b1;
            w_dma_prescale_value = w_dma_value[15:0];
          end
          2'b11: begin
            w_dma_width_update[w_dma_tag[2:0]] = 1'b1;
            w_dma_compare_value_flat[w_dma_tag[2:0]*PARA_COUNTER_WIDTH +: PARA_COUNTER_WIDTH] = w_dma_value;
          end
          default: begin
            w_dma_compare_update = w_dma_compare_update;
          end
        endcase
      end
    end
  end
  // PWM-input pair 0: read results are retained until software clears the valid status.
  m_vlsit_timer_pwm_input #(.PARA_COUNTER_WIDTH (PARA_COUNTER_WIDTH)) u_pwm_input_0 (
    .i_clk_timer       (i_clk_timer),
    .i_rst_n_timer     (w_rst_n_timer),
    .i_enable          (w_o_pi_cfg_pair0_en && w_o_ctrl_timer_en &&
                        ({1'b0, w_o_pi_cfg_pair0_input} < PARA_CAPTURE_COUNT[3:0])),
    .i_active_low      (w_o_pi_cfg_low0),
    .i_signal          (w_filtered[w_o_pi_cfg_pair0_input]),
    .i_count           (w_counter),
    .i_clear_valid     (w_irq_clear_pwm_valid[0]),
    .i_clear_overrun   (w_irq_clear_pwm_overrun[0]),
    .o_period          (w_pwm_period[0]),
    .o_pulse_width     (w_pwm_pulse_width[0]),
    .o_valid           (w_pwm_valid[0]),
    .o_overrun         (w_pwm_overrun[0]),
    .o_measure_event   (w_pwm_measure_event[0]),
    .o_result_commit   (w_pwm_result_commit[0]),
    .o_overrun_event   (w_pwm_overrun_event[0])
  );
  // PWM-input pair 1: read results are retained until software clears the valid status.
  m_vlsit_timer_pwm_input #(.PARA_COUNTER_WIDTH (PARA_COUNTER_WIDTH)) u_pwm_input_1 (
    .i_clk_timer       (i_clk_timer),
    .i_rst_n_timer     (w_rst_n_timer),
    .i_enable          (w_o_pi_cfg_pair1_en && w_o_ctrl_timer_en &&
                        ({1'b0, w_o_pi_cfg_pair1_input} < PARA_CAPTURE_COUNT[3:0])),
    .i_active_low      (w_o_pi_cfg_low1),
    .i_signal          (w_filtered[w_o_pi_cfg_pair1_input]),
    .i_count           (w_counter),
    .i_clear_valid     (w_irq_clear_pwm_valid[1]),
    .i_clear_overrun   (w_irq_clear_pwm_overrun[1]),
    .o_period          (w_pwm_period[1]),
    .o_pulse_width     (w_pwm_pulse_width[1]),
    .o_valid           (w_pwm_valid[1]),
    .o_overrun         (w_pwm_overrun[1]),
    .o_measure_event   (w_pwm_measure_event[1]),
    .o_result_commit   (w_pwm_result_commit[1]),
    .o_overrun_event   (w_pwm_overrun_event[1])
  );
  // PWM-input pair 2: read results are retained until software clears the valid status.
  m_vlsit_timer_pwm_input #(.PARA_COUNTER_WIDTH (PARA_COUNTER_WIDTH)) u_pwm_input_2 (
    .i_clk_timer       (i_clk_timer),
    .i_rst_n_timer     (w_rst_n_timer),
    .i_enable          (w_o_pi_cfg_pair2_en && w_o_ctrl_timer_en &&
                        ({1'b0, w_o_pi_cfg_pair2_input} < PARA_CAPTURE_COUNT[3:0])),
    .i_active_low      (w_o_pi_cfg_low2),
    .i_signal          (w_filtered[w_o_pi_cfg_pair2_input]),
    .i_count           (w_counter),
    .i_clear_valid     (w_irq_clear_pwm_valid[2]),
    .i_clear_overrun   (w_irq_clear_pwm_overrun[2]),
    .o_period          (w_pwm_period[2]),
    .o_pulse_width     (w_pwm_pulse_width[2]),
    .o_valid           (w_pwm_valid[2]),
    .o_overrun         (w_pwm_overrun[2]),
    .o_measure_event   (w_pwm_measure_event[2]),
    .o_result_commit   (w_pwm_result_commit[2]),
    .o_overrun_event   (w_pwm_overrun_event[2])
  );
  // PWM-input pair 3: read results are retained until software clears the valid status.
  m_vlsit_timer_pwm_input #(.PARA_COUNTER_WIDTH (PARA_COUNTER_WIDTH)) u_pwm_input_3 (
    .i_clk_timer       (i_clk_timer),
    .i_rst_n_timer     (w_rst_n_timer),
    .i_enable          (w_o_pi_cfg_pair3_en && w_o_ctrl_timer_en &&
                        ({1'b0, w_o_pi_cfg_pair3_input} < PARA_CAPTURE_COUNT[3:0])),
    .i_active_low      (w_o_pi_cfg_low3),
    .i_signal          (w_filtered[w_o_pi_cfg_pair3_input]),
    .i_count           (w_counter),
    .i_clear_valid     (w_irq_clear_pwm_valid[3]),
    .i_clear_overrun   (w_irq_clear_pwm_overrun[3]),
    .o_period          (w_pwm_period[3]),
    .o_pulse_width     (w_pwm_pulse_width[3]),
    .o_valid           (w_pwm_valid[3]),
    .o_overrun         (w_pwm_overrun[3]),
    .o_measure_event   (w_pwm_measure_event[3]),
    .o_result_commit   (w_pwm_result_commit[3]),
    .o_overrun_event   (w_pwm_overrun_event[3])
  );
  // Detect W1C status clears to clear the matching local FIFO/measurement sticky state.
  assign w_irq_clear_ovf = reg_irq_ovf_prev & ~{
w_o_irq_raw0_ovf7, w_o_irq_raw0_ovf6, w_o_irq_raw0_ovf5, w_o_irq_raw0_ovf4, w_o_irq_raw0_ovf3, w_o_irq_raw0_ovf2, w_o_irq_raw0_ovf1, w_o_irq_raw0_ovf0};
  assign w_irq_clear_pwm_valid = reg_irq_pwm_valid_prev & ~{
w_o_pi_sts_valid3, w_o_pi_sts_valid2, w_o_pi_sts_valid1, w_o_pi_sts_valid0};
  assign w_irq_clear_pwm_overrun = reg_irq_pwm_ovr_prev & ~{
w_o_pi_sts_ovr3, w_o_pi_sts_ovr2, w_o_pi_sts_ovr1, w_o_pi_sts_ovr0};
  always_ff @(posedge i_clk_timer, negedge w_rst_n_timer) begin : p_ff_irq_clear_tracking
    if (!w_rst_n_timer) begin
      reg_irq_ovf_prev <= '0;
      reg_irq_pwm_valid_prev <= '0;
      reg_irq_pwm_ovr_prev <= '0;
    end else begin
      reg_irq_ovf_prev <= {
w_o_irq_raw0_ovf7, w_o_irq_raw0_ovf6, w_o_irq_raw0_ovf5, w_o_irq_raw0_ovf4, w_o_irq_raw0_ovf3, w_o_irq_raw0_ovf2, w_o_irq_raw0_ovf1, w_o_irq_raw0_ovf0};
      reg_irq_pwm_valid_prev <= {
w_o_pi_sts_valid3, w_o_pi_sts_valid2, w_o_pi_sts_valid1, w_o_pi_sts_valid0};
      reg_irq_pwm_ovr_prev <= {
w_o_pi_sts_ovr3, w_o_pi_sts_ovr2, w_o_pi_sts_ovr1, w_o_pi_sts_ovr0};
    end
  end

  // APB response.
  assign o_pready_apb = w_stream_sel ? w_stream_pready : w_csr_o_apb_pready;
  assign o_prdata_apb = w_stream_sel ? w_stream_prdata : w_csr_o_apb_prdata;
  assign o_pslverr_apb = w_stream_sel ? w_stream_pslverr : w_csr_o_apb_pslverr;

  // Only an enabled, pending cause reaches the single Timer IRQ output.
  assign o_irq_timer = |{
w_i_irq_sts0_cap0, w_i_irq_sts0_cap1, w_i_irq_sts0_cap2, w_i_irq_sts0_cap3, w_i_irq_sts0_cap4, w_i_irq_sts0_cap5, w_i_irq_sts0_cap6, w_i_irq_sts0_cap7, w_i_irq_sts0_ovf0, w_i_irq_sts0_ovf1, w_i_irq_sts0_ovf2, w_i_irq_sts0_ovf3, w_i_irq_sts0_ovf4, w_i_irq_sts0_ovf5, w_i_irq_sts0_ovf6, w_i_irq_sts0_ovf7, w_i_irq_sts0_cmp0, w_i_irq_sts0_cmp1, w_i_irq_sts0_cmp2, w_i_irq_sts0_cmp3, w_i_irq_sts0_cmp4, w_i_irq_sts0_cmp5, w_i_irq_sts0_cmp6, w_i_irq_sts0_cmp7, w_i_irq_sts0_tout0, w_i_irq_sts0_tout1, w_i_irq_sts0_tout2, w_i_irq_sts0_tout3, w_i_irq_sts0_tout4, w_i_irq_sts0_tout5, w_i_irq_sts0_tout6, w_i_irq_sts0_tout7, w_i_irq_sts1_upd, w_i_irq_sts1_cqovf, w_i_irq_sts1_mqovf, w_i_irq_sts1_dperr, w_i_irq_sts1_pwm0, w_i_irq_sts1_pwm1, w_i_irq_sts1_pwm2, w_i_irq_sts1_pwm3};



  // Generated CSR status, event, and data inputs.
  assign w_i_cnt_value = w_counter_read_low;
  assign w_i_cnt_hi_hi = w_counter_read_high;
  assign w_i_cap_lvl_lvl_ch0 = {1'b0, w_capture_level[0]};
  assign w_i_opm_sts_busy_ch0 = w_opm_busy[0];
  assign w_i_opm_sts_armed_ch0 = w_opm_armed[0];
  assign w_i_cap_lvl_lvl_ch1 = {1'b0, w_capture_level[1]};
  assign w_i_opm_sts_busy_ch1 = w_opm_busy[1];
  assign w_i_opm_sts_armed_ch1 = w_opm_armed[1];
  assign w_i_cap_lvl_lvl_ch2 = {1'b0, w_capture_level[2]};
  assign w_i_opm_sts_busy_ch2 = w_opm_busy[2];
  assign w_i_opm_sts_armed_ch2 = w_opm_armed[2];
  assign w_i_cap_lvl_lvl_ch3 = {1'b0, w_capture_level[3]};
  assign w_i_opm_sts_busy_ch3 = w_opm_busy[3];
  assign w_i_opm_sts_armed_ch3 = w_opm_armed[3];
  assign w_i_cap_lvl_lvl_ch4 = {1'b0, w_capture_level[4]};
  assign w_i_opm_sts_busy_ch4 = w_opm_busy[4];
  assign w_i_opm_sts_armed_ch4 = w_opm_armed[4];
  assign w_i_cap_lvl_lvl_ch5 = {1'b0, w_capture_level[5]};
  assign w_i_opm_sts_busy_ch5 = w_opm_busy[5];
  assign w_i_opm_sts_armed_ch5 = w_opm_armed[5];
  assign w_i_cap_lvl_lvl_ch6 = {1'b0, w_capture_level[6]};
  assign w_i_opm_sts_busy_ch6 = w_opm_busy[6];
  assign w_i_opm_sts_armed_ch6 = w_opm_armed[6];
  assign w_i_cap_lvl_lvl_ch7 = {1'b0, w_capture_level[7]};
  assign w_i_opm_sts_busy_ch7 = w_opm_busy[7];
  assign w_i_opm_sts_armed_ch7 = w_opm_armed[7];
  assign w_i_dma_lvl_cap_lvl = w_dma_cap_level;
  assign w_i_dma_lvl_cmp_lvl = w_dma_cmp_level;
  assign w_i_dma_lvl_cap_reserved = w_dma_cap_reserved;
  assign w_i_dma_lvl_cmp_reserved = w_dma_cmp_reserved;
  assign w_pwm_period_ext[0] = {{(64-PARA_COUNTER_WIDTH){1'b0}}, w_pwm_period[0]};
  assign w_pwm_period_ext[1] = {{(64-PARA_COUNTER_WIDTH){1'b0}}, w_pwm_period[1]};
  assign w_pwm_period_ext[2] = {{(64-PARA_COUNTER_WIDTH){1'b0}}, w_pwm_period[2]};
  assign w_pwm_period_ext[3] = {{(64-PARA_COUNTER_WIDTH){1'b0}}, w_pwm_period[3]};
  assign w_pwm_pulse_width_ext[0] = {{(64-PARA_COUNTER_WIDTH){1'b0}}, w_pwm_pulse_width[0]};
  assign w_pwm_pulse_width_ext[1] = {{(64-PARA_COUNTER_WIDTH){1'b0}}, w_pwm_pulse_width[1]};
  assign w_pwm_pulse_width_ext[2] = {{(64-PARA_COUNTER_WIDTH){1'b0}}, w_pwm_pulse_width[2]};
  assign w_pwm_pulse_width_ext[3] = {{(64-PARA_COUNTER_WIDTH){1'b0}}, w_pwm_pulse_width[3]};
  assign w_i_p0_per_value = w_pwm_period[0][31:0];
  assign w_i_p0_per_h_hi = w_pwm_period_ext[0][63:32];
  assign w_i_p0_wid_value = w_pwm_pulse_width[0][31:0];
  assign w_i_p0_wid_h_hi = w_pwm_pulse_width_ext[0][63:32];
  assign w_i_p1_per_value = w_pwm_period[1][31:0];
  assign w_i_p1_per_h_hi = w_pwm_period_ext[1][63:32];
  assign w_i_p1_wid_value = w_pwm_pulse_width[1][31:0];
  assign w_i_p1_wid_h_hi = w_pwm_pulse_width_ext[1][63:32];
  assign w_i_p2_per_value = w_pwm_period[2][31:0];
  assign w_i_p2_per_h_hi = w_pwm_period_ext[2][63:32];
  assign w_i_p2_wid_value = w_pwm_pulse_width[2][31:0];
  assign w_i_p2_wid_h_hi = w_pwm_pulse_width_ext[2][63:32];
  assign w_i_p3_per_value = w_pwm_period[3][31:0];
  assign w_i_p3_per_h_hi = w_pwm_period_ext[3][63:32];
  assign w_i_p3_wid_value = w_pwm_pulse_width[3][31:0];
  assign w_i_p3_wid_h_hi = w_pwm_pulse_width_ext[3][63:32];
  assign w_i_dma_sts_cap_req = w_dma_cap_req_status;
  assign w_i_dma_sts_cap_burst = w_dma_cap_burst_status;
  assign w_i_dma_sts_cap_clr_busy = w_dma_cap_clr_status;
  assign w_i_dma_sts_cmp_req = w_dma_cmp_req_status;
  assign w_i_dma_sts_cmp_burst = w_dma_cmp_burst_status;
  assign w_i_dma_sts_cmp_clr_busy = w_dma_cmp_clr_status;
  assign w_hw_d_irq_raw0_cap0 = (w_capture_event[0] | w_o_irq_inj0_cap0);
  assign w_hw_we_irq_raw0_cap0 = (w_capture_event[0] | w_o_irq_inj0_cap0);
  assign w_hw_d_irq_raw0_cap1 = (w_capture_event[1] | w_o_irq_inj0_cap1);
  assign w_hw_we_irq_raw0_cap1 = (w_capture_event[1] | w_o_irq_inj0_cap1);
  assign w_hw_d_irq_raw0_cap2 = (w_capture_event[2] | w_o_irq_inj0_cap2);
  assign w_hw_we_irq_raw0_cap2 = (w_capture_event[2] | w_o_irq_inj0_cap2);
  assign w_hw_d_irq_raw0_cap3 = (w_capture_event[3] | w_o_irq_inj0_cap3);
  assign w_hw_we_irq_raw0_cap3 = (w_capture_event[3] | w_o_irq_inj0_cap3);
  assign w_hw_d_irq_raw0_cap4 = (w_capture_event[4] | w_o_irq_inj0_cap4);
  assign w_hw_we_irq_raw0_cap4 = (w_capture_event[4] | w_o_irq_inj0_cap4);
  assign w_hw_d_irq_raw0_cap5 = (w_capture_event[5] | w_o_irq_inj0_cap5);
  assign w_hw_we_irq_raw0_cap5 = (w_capture_event[5] | w_o_irq_inj0_cap5);
  assign w_hw_d_irq_raw0_cap6 = (w_capture_event[6] | w_o_irq_inj0_cap6);
  assign w_hw_we_irq_raw0_cap6 = (w_capture_event[6] | w_o_irq_inj0_cap6);
  assign w_hw_d_irq_raw0_cap7 = (w_capture_event[7] | w_o_irq_inj0_cap7);
  assign w_hw_we_irq_raw0_cap7 = (w_capture_event[7] | w_o_irq_inj0_cap7);
  assign w_hw_d_irq_raw0_ovf0 = (w_capture_fifo_overflow_event[0] | w_o_irq_inj0_ovf0);
  assign w_hw_we_irq_raw0_ovf0 = (w_capture_fifo_overflow_event[0] | w_o_irq_inj0_ovf0);
  assign w_hw_d_irq_raw0_ovf1 = (w_capture_fifo_overflow_event[1] | w_o_irq_inj0_ovf1);
  assign w_hw_we_irq_raw0_ovf1 = (w_capture_fifo_overflow_event[1] | w_o_irq_inj0_ovf1);
  assign w_hw_d_irq_raw0_ovf2 = (w_capture_fifo_overflow_event[2] | w_o_irq_inj0_ovf2);
  assign w_hw_we_irq_raw0_ovf2 = (w_capture_fifo_overflow_event[2] | w_o_irq_inj0_ovf2);
  assign w_hw_d_irq_raw0_ovf3 = (w_capture_fifo_overflow_event[3] | w_o_irq_inj0_ovf3);
  assign w_hw_we_irq_raw0_ovf3 = (w_capture_fifo_overflow_event[3] | w_o_irq_inj0_ovf3);
  assign w_hw_d_irq_raw0_ovf4 = (w_capture_fifo_overflow_event[4] | w_o_irq_inj0_ovf4);
  assign w_hw_we_irq_raw0_ovf4 = (w_capture_fifo_overflow_event[4] | w_o_irq_inj0_ovf4);
  assign w_hw_d_irq_raw0_ovf5 = (w_capture_fifo_overflow_event[5] | w_o_irq_inj0_ovf5);
  assign w_hw_we_irq_raw0_ovf5 = (w_capture_fifo_overflow_event[5] | w_o_irq_inj0_ovf5);
  assign w_hw_d_irq_raw0_ovf6 = (w_capture_fifo_overflow_event[6] | w_o_irq_inj0_ovf6);
  assign w_hw_we_irq_raw0_ovf6 = (w_capture_fifo_overflow_event[6] | w_o_irq_inj0_ovf6);
  assign w_hw_d_irq_raw0_ovf7 = (w_capture_fifo_overflow_event[7] | w_o_irq_inj0_ovf7);
  assign w_hw_we_irq_raw0_ovf7 = (w_capture_fifo_overflow_event[7] | w_o_irq_inj0_ovf7);
  assign w_hw_d_irq_raw0_cmp0 = (w_compare_event[0] | w_o_irq_inj0_cmp0);
  assign w_hw_we_irq_raw0_cmp0 = (w_compare_event[0] | w_o_irq_inj0_cmp0);
  assign w_hw_d_irq_raw0_cmp1 = (w_compare_event[1] | w_o_irq_inj0_cmp1);
  assign w_hw_we_irq_raw0_cmp1 = (w_compare_event[1] | w_o_irq_inj0_cmp1);
  assign w_hw_d_irq_raw0_cmp2 = (w_compare_event[2] | w_o_irq_inj0_cmp2);
  assign w_hw_we_irq_raw0_cmp2 = (w_compare_event[2] | w_o_irq_inj0_cmp2);
  assign w_hw_d_irq_raw0_cmp3 = (w_compare_event[3] | w_o_irq_inj0_cmp3);
  assign w_hw_we_irq_raw0_cmp3 = (w_compare_event[3] | w_o_irq_inj0_cmp3);
  assign w_hw_d_irq_raw0_cmp4 = (w_compare_event[4] | w_o_irq_inj0_cmp4);
  assign w_hw_we_irq_raw0_cmp4 = (w_compare_event[4] | w_o_irq_inj0_cmp4);
  assign w_hw_d_irq_raw0_cmp5 = (w_compare_event[5] | w_o_irq_inj0_cmp5);
  assign w_hw_we_irq_raw0_cmp5 = (w_compare_event[5] | w_o_irq_inj0_cmp5);
  assign w_hw_d_irq_raw0_cmp6 = (w_compare_event[6] | w_o_irq_inj0_cmp6);
  assign w_hw_we_irq_raw0_cmp6 = (w_compare_event[6] | w_o_irq_inj0_cmp6);
  assign w_hw_d_irq_raw0_cmp7 = (w_compare_event[7] | w_o_irq_inj0_cmp7);
  assign w_hw_we_irq_raw0_cmp7 = (w_compare_event[7] | w_o_irq_inj0_cmp7);
  assign w_hw_d_irq_raw0_tout0 = (w_timeout_event[0] | w_o_irq_inj0_tout0);
  assign w_hw_we_irq_raw0_tout0 = (w_timeout_event[0] | w_o_irq_inj0_tout0);
  assign w_hw_d_irq_raw0_tout1 = (w_timeout_event[1] | w_o_irq_inj0_tout1);
  assign w_hw_we_irq_raw0_tout1 = (w_timeout_event[1] | w_o_irq_inj0_tout1);
  assign w_hw_d_irq_raw0_tout2 = (w_timeout_event[2] | w_o_irq_inj0_tout2);
  assign w_hw_we_irq_raw0_tout2 = (w_timeout_event[2] | w_o_irq_inj0_tout2);
  assign w_hw_d_irq_raw0_tout3 = (w_timeout_event[3] | w_o_irq_inj0_tout3);
  assign w_hw_we_irq_raw0_tout3 = (w_timeout_event[3] | w_o_irq_inj0_tout3);
  assign w_hw_d_irq_raw0_tout4 = (w_timeout_event[4] | w_o_irq_inj0_tout4);
  assign w_hw_we_irq_raw0_tout4 = (w_timeout_event[4] | w_o_irq_inj0_tout4);
  assign w_hw_d_irq_raw0_tout5 = (w_timeout_event[5] | w_o_irq_inj0_tout5);
  assign w_hw_we_irq_raw0_tout5 = (w_timeout_event[5] | w_o_irq_inj0_tout5);
  assign w_hw_d_irq_raw0_tout6 = (w_timeout_event[6] | w_o_irq_inj0_tout6);
  assign w_hw_we_irq_raw0_tout6 = (w_timeout_event[6] | w_o_irq_inj0_tout6);
  assign w_hw_d_irq_raw0_tout7 = (w_timeout_event[7] | w_o_irq_inj0_tout7);
  assign w_hw_we_irq_raw0_tout7 = (w_timeout_event[7] | w_o_irq_inj0_tout7);
  assign w_hw_d_irq_raw1_upd = (w_update_event | w_o_irq_inj1_upd);
  assign w_hw_we_irq_raw1_upd = (w_update_event | w_o_irq_inj1_upd);
  assign w_hw_d_irq_raw1_cqovf = (w_cap_queue_overflow_event | w_o_irq_inj1_cqovf);
  assign w_hw_we_irq_raw1_cqovf = (w_cap_queue_overflow_event | w_o_irq_inj1_cqovf);
  assign w_hw_d_irq_raw1_mqovf = (1'b0 | w_o_irq_inj1_mqovf);
  assign w_hw_we_irq_raw1_mqovf = (1'b0 | w_o_irq_inj1_mqovf);
  assign w_hw_d_irq_raw1_dperr = (w_dma_error_event | w_o_irq_inj1_dperr);
  assign w_hw_we_irq_raw1_dperr = (w_dma_error_event | w_o_irq_inj1_dperr);
  assign w_hw_d_irq_raw1_pwm0 = (w_pwm_measure_event[0] | w_o_irq_inj1_pwm0);
  assign w_hw_we_irq_raw1_pwm0 = (w_pwm_measure_event[0] | w_o_irq_inj1_pwm0);
  assign w_hw_d_irq_raw1_pwm1 = (w_pwm_measure_event[1] | w_o_irq_inj1_pwm1);
  assign w_hw_we_irq_raw1_pwm1 = (w_pwm_measure_event[1] | w_o_irq_inj1_pwm1);
  assign w_hw_d_irq_raw1_pwm2 = (w_pwm_measure_event[2] | w_o_irq_inj1_pwm2);
  assign w_hw_we_irq_raw1_pwm2 = (w_pwm_measure_event[2] | w_o_irq_inj1_pwm2);
  assign w_hw_d_irq_raw1_pwm3 = (w_pwm_measure_event[3] | w_o_irq_inj1_pwm3);
  assign w_hw_we_irq_raw1_pwm3 = (w_pwm_measure_event[3] | w_o_irq_inj1_pwm3);
  assign w_hw_d_pi_sts_valid0 = w_pwm_result_commit[0];
  assign w_hw_we_pi_sts_valid0 = w_pwm_result_commit[0];
  assign w_hw_d_pi_sts_ovr0 = w_pwm_overrun_event[0];
  assign w_hw_we_pi_sts_ovr0 = w_pwm_overrun_event[0];
  assign w_hw_d_pi_sts_valid1 = w_pwm_result_commit[1];
  assign w_hw_we_pi_sts_valid1 = w_pwm_result_commit[1];
  assign w_hw_d_pi_sts_ovr1 = w_pwm_overrun_event[1];
  assign w_hw_we_pi_sts_ovr1 = w_pwm_overrun_event[1];
  assign w_hw_d_pi_sts_valid2 = w_pwm_result_commit[2];
  assign w_hw_we_pi_sts_valid2 = w_pwm_result_commit[2];
  assign w_hw_d_pi_sts_ovr2 = w_pwm_overrun_event[2];
  assign w_hw_we_pi_sts_ovr2 = w_pwm_overrun_event[2];
  assign w_hw_d_pi_sts_valid3 = w_pwm_result_commit[3];
  assign w_hw_we_pi_sts_valid3 = w_pwm_result_commit[3];
  assign w_hw_d_pi_sts_ovr3 = w_pwm_overrun_event[3];
  assign w_hw_we_pi_sts_ovr3 = w_pwm_overrun_event[3];
  assign w_i_irq_sts0_cap0 = (w_o_irq_raw0_cap0 & w_o_irq_en0_cap0);
  assign w_i_irq_sts0_cap1 = (w_o_irq_raw0_cap1 & w_o_irq_en0_cap1);
  assign w_i_irq_sts0_cap2 = (w_o_irq_raw0_cap2 & w_o_irq_en0_cap2);
  assign w_i_irq_sts0_cap3 = (w_o_irq_raw0_cap3 & w_o_irq_en0_cap3);
  assign w_i_irq_sts0_cap4 = (w_o_irq_raw0_cap4 & w_o_irq_en0_cap4);
  assign w_i_irq_sts0_cap5 = (w_o_irq_raw0_cap5 & w_o_irq_en0_cap5);
  assign w_i_irq_sts0_cap6 = (w_o_irq_raw0_cap6 & w_o_irq_en0_cap6);
  assign w_i_irq_sts0_cap7 = (w_o_irq_raw0_cap7 & w_o_irq_en0_cap7);
  assign w_i_irq_sts0_ovf0 = (w_o_irq_raw0_ovf0 & w_o_irq_en0_ovf0);
  assign w_i_irq_sts0_ovf1 = (w_o_irq_raw0_ovf1 & w_o_irq_en0_ovf1);
  assign w_i_irq_sts0_ovf2 = (w_o_irq_raw0_ovf2 & w_o_irq_en0_ovf2);
  assign w_i_irq_sts0_ovf3 = (w_o_irq_raw0_ovf3 & w_o_irq_en0_ovf3);
  assign w_i_irq_sts0_ovf4 = (w_o_irq_raw0_ovf4 & w_o_irq_en0_ovf4);
  assign w_i_irq_sts0_ovf5 = (w_o_irq_raw0_ovf5 & w_o_irq_en0_ovf5);
  assign w_i_irq_sts0_ovf6 = (w_o_irq_raw0_ovf6 & w_o_irq_en0_ovf6);
  assign w_i_irq_sts0_ovf7 = (w_o_irq_raw0_ovf7 & w_o_irq_en0_ovf7);
  assign w_i_irq_sts0_cmp0 = (w_o_irq_raw0_cmp0 & w_o_irq_en0_cmp0);
  assign w_i_irq_sts0_cmp1 = (w_o_irq_raw0_cmp1 & w_o_irq_en0_cmp1);
  assign w_i_irq_sts0_cmp2 = (w_o_irq_raw0_cmp2 & w_o_irq_en0_cmp2);
  assign w_i_irq_sts0_cmp3 = (w_o_irq_raw0_cmp3 & w_o_irq_en0_cmp3);
  assign w_i_irq_sts0_cmp4 = (w_o_irq_raw0_cmp4 & w_o_irq_en0_cmp4);
  assign w_i_irq_sts0_cmp5 = (w_o_irq_raw0_cmp5 & w_o_irq_en0_cmp5);
  assign w_i_irq_sts0_cmp6 = (w_o_irq_raw0_cmp6 & w_o_irq_en0_cmp6);
  assign w_i_irq_sts0_cmp7 = (w_o_irq_raw0_cmp7 & w_o_irq_en0_cmp7);
  assign w_i_irq_sts0_tout0 = (w_o_irq_raw0_tout0 & w_o_irq_en0_tout0);
  assign w_i_irq_sts0_tout1 = (w_o_irq_raw0_tout1 & w_o_irq_en0_tout1);
  assign w_i_irq_sts0_tout2 = (w_o_irq_raw0_tout2 & w_o_irq_en0_tout2);
  assign w_i_irq_sts0_tout3 = (w_o_irq_raw0_tout3 & w_o_irq_en0_tout3);
  assign w_i_irq_sts0_tout4 = (w_o_irq_raw0_tout4 & w_o_irq_en0_tout4);
  assign w_i_irq_sts0_tout5 = (w_o_irq_raw0_tout5 & w_o_irq_en0_tout5);
  assign w_i_irq_sts0_tout6 = (w_o_irq_raw0_tout6 & w_o_irq_en0_tout6);
  assign w_i_irq_sts0_tout7 = (w_o_irq_raw0_tout7 & w_o_irq_en0_tout7);
  assign w_i_irq_sts1_upd = (w_o_irq_raw1_upd & w_o_irq_en1_upd);
  assign w_i_irq_sts1_cqovf = (w_o_irq_raw1_cqovf & w_o_irq_en1_cqovf);
  assign w_i_irq_sts1_mqovf = (w_o_irq_raw1_mqovf & w_o_irq_en1_mqovf);
  assign w_i_irq_sts1_dperr = (w_o_irq_raw1_dperr & w_o_irq_en1_dperr);
  assign w_i_irq_sts1_pwm0 = (w_o_irq_raw1_pwm0 & w_o_irq_en1_pwm0);
  assign w_i_irq_sts1_pwm1 = (w_o_irq_raw1_pwm1 & w_o_irq_en1_pwm1);
  assign w_i_irq_sts1_pwm2 = (w_o_irq_raw1_pwm2 & w_o_irq_en1_pwm2);
  assign w_i_irq_sts1_pwm3 = (w_o_irq_raw1_pwm3 & w_o_irq_en1_pwm3);

endmodule
