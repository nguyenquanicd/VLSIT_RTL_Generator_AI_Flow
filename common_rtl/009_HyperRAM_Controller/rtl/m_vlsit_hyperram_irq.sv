/*
 * Project      : HyperRAM Controller
 * Author       : Nguyen Quan (user)
 * AI Flow      : VLSIT RTL Generator AI Automation Flow
 * AI Flow Page : https://github.com/nguyenquanicd/VLSIT_RTL_Generator_AI_Model
 * Date         : 2026-10-31
 * Description  : Interrupt glue of the HyperRAM controller (section 11.3 of the specification,
 *                rule R-040 of the register conventions). It keeps the structural top free of
 *                logic. For the nine interrupt causes it gives the hardware set of the raw
 *                register (a cause pulse of the controller or the frontend, or the rising edge
 *                of the software injection bit), the masked status (raw AND enable), and the
 *                interrupt output (OR of the masked status). The cause order of every vector
 *                is bit 0 init_ok, 1 cfg_err, 2 decerr, 3 slverr, 4 pwr_lost, 5 id_mis,
 *                6 lat_mis, 7 cmd_done, 8 tmo.
 */
`timescale 1ns/1ps

module m_vlsit_hyperram_irq #(
  localparam logic [31:0] LPARA_IRQ_W = 32'd9
) (
  // Clock and reset
  input  wire                    i_clk_core,
  input  wire                    i_rst_n_core,

  // Cause pulses from the controller and the frontend (one core cycle each)
  input  wire  [LPARA_IRQ_W-1:0] i_evt,

  // Interrupt registers of the register file (raw status, enable mask, injection)
  input  wire  [LPARA_IRQ_W-1:0] i_irq_raw,
  input  wire  [LPARA_IRQ_W-1:0] i_irq_en,
  input  wire  [LPARA_IRQ_W-1:0] i_irq_inj,

  // Results toward the register file and the interrupt pin
  output logic [LPARA_IRQ_W-1:0] o_raw_set,
  output logic [LPARA_IRQ_W-1:0] o_irq_sts,
  output logic                   o_int
);

  // Internal signal declarations
  logic [LPARA_IRQ_W-1:0] reg_inj_prev;
  logic [LPARA_IRQ_W-1:0] w_inj_rise;

  // Injection edge: a bit of the injection register sets its raw bit once, in the cycle in which
  // it rises, and software writes 0 before the next injection. The previous value is reset to 0.
  assign w_inj_rise = i_irq_inj & ~reg_inj_prev;

  // Hardware set of the raw register: a cause pulse or an injection edge sets the raw bit.
  assign o_raw_set = i_evt | w_inj_rise;

  // Masked status: a raw bit shows in the status only while its enable bit is 1.
  assign o_irq_sts = i_irq_raw & i_irq_en;

  // Interrupt output: high while any masked status bit is 1.
  assign o_int = |o_irq_sts;

  // Previous value of the injection register for the edge detection; cleared by the core reset.
  always_ff @(posedge i_clk_core, negedge i_rst_n_core) begin : p_ff_inj_prev
    if (!i_rst_n_core)
      reg_inj_prev <= '0;
    else
      reg_inj_prev <= i_irq_inj;
  end

endmodule
