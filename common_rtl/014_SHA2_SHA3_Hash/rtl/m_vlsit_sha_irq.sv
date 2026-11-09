/*
 * Project      : VLSIT Common RTL library
 * Author       : Nguyen Quan and Claude Sonnet 5.5 (user)
 * AI Flow      : VLSIT RTL Generator AI Automation Flow
 * AI Flow Page : https://github.com/nguyenquanicd/VLSIT_RTL_Generator_AI_Model
 * Date         : 2026-11-09
 * Description  : Event capture of the SHA2 and SHA3 hash IP (6.4). It turns the event pulses of
 *                the IP and the injection bits of sha_irq_inj (rising edge) into hardware loads of
 *                the sticky raw bits of sha_irq_raw, computes the masked status (raw and enable)
 *                and drives o_irq (OR of the masked status) and o_alarm. The raw bits live in the
 *                CSR block: a hardware load replaces the whole field, so the load value is the
 *                raw value ORed with the new events (hardware set wins over a software clear).
 *                One-bit events are the vector bits 0 ovf, 1 udf, 2 axi, 3 cfg, 4 flt, 5 ent,
 *                6 tmo and 7 len; the context-done event has one bit per context.
 *                Decisions: DEC-014.
 */
`timescale 1ns/1ps

module m_vlsit_sha_irq (
  // Clock and reset
  input  wire         i_clk_core,
  input  wire         i_rst_n_core,

  // Events of the IP (one-cycle pulses) and the alarm request of the fault logic
  input  wire  [7:0]  i_ev_one,
  input  wire  [15:0] i_ev_cdone,
  input  wire         i_alarm_set,
  input  wire         i_srst,

  // Raw, enable and injection fields of the CSR block
  input  wire  [7:0]  i_raw_one,
  input  wire  [15:0] i_raw_cdone,
  input  wire  [7:0]  i_en_one,
  input  wire  [15:0] i_en_cdone,
  input  wire  [7:0]  i_inj_one,
  input  wire  [15:0] i_inj_cdone,

  // Hardware loads of the raw fields
  output logic [7:0]  o_hw_we_one,
  output logic [7:0]  o_hw_wd_one,
  output logic        o_hw_we_cdone,
  output logic [15:0] o_hw_wd_cdone,

  // Masked status, interrupt and alarm outputs
  output logic [7:0]  o_sts_one,
  output logic [15:0] o_sts_cdone,
  output logic        o_irq,
  output logic        o_alarm
);

  // Internal signal declarations
  logic [7:0]  reg_inj_one;
  logic [15:0] reg_inj_cdone;
  logic        reg_alarm;
  logic [7:0]  w_set_one;
  logic [15:0] w_set_cdone;
  logic        w_alarm_nxt;

  // Event set: an event pulse, or a rising edge of the injection bit, sets the raw bit. The load
  // value of a field is the raw value with the set bits ORed in; the write enable is the set.
  always_comb begin : p_com_set
    w_set_one     = i_ev_one | (i_inj_one & ~reg_inj_one);
    w_set_cdone   = i_ev_cdone | (i_inj_cdone & ~reg_inj_cdone);
    o_hw_we_one   = w_set_one;
    o_hw_wd_one   = i_raw_one | w_set_one;
    o_hw_we_cdone = |w_set_cdone;
    o_hw_wd_cdone = i_raw_cdone | w_set_cdone;
  end

  // Masked status and outputs: status is raw and enable; o_irq is the OR of all status bits.
  always_comb begin : p_com_sts
    o_sts_one   = i_raw_one & i_en_one;
    o_sts_cdone = i_raw_cdone & i_en_cdone;
    o_irq       = (|o_sts_one) || (|o_sts_cdone);
    w_alarm_nxt = i_srst ? 1'b0 : (reg_alarm || i_alarm_set);
  end

  // Injection edge detector and alarm flag: control state, reset to 0. The alarm stays on
  // until the soft reset command (6.4).
  always_ff @(posedge i_clk_core, negedge i_rst_n_core) begin : p_ff_irq
    if (!i_rst_n_core) begin
      reg_inj_one   <= '0;
      reg_inj_cdone <= '0;
      reg_alarm     <= 1'b0;
    end else begin
      reg_inj_one   <= i_inj_one;
      reg_inj_cdone <= i_inj_cdone;
      reg_alarm     <= w_alarm_nxt;
    end
  end

  // The alarm output is the alarm flag.
  assign o_alarm = reg_alarm;

endmodule
