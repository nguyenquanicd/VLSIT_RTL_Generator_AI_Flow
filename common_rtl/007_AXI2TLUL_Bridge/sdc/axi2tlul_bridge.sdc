# axi2tlul_bridge.sdc - timing constraints of m_vlsit_axi2tlul_top (specification section 17.1)
# Single clock, fully synchronous, no timing exception (EXC-001 is "none").
# TBD-001: the clock period and the I/O delay fractions are not decided yet. Set T_MAIN (ns) before use.
# The fractions below are the goals of section 17.1.2; the SoC integrator owns the real I/O delays.
#
#   set T_MAIN 2.0
#   source axi2tlul_bridge.sdc

if {![info exists T_MAIN]} {
  error "axi2tlul_bridge.sdc: set T_MAIN (clock period in ns, TBD-001) before sourcing this file"
}

# Clock (CLK-MAIN): primary clock, 50 % duty cycle.
create_clock -name CLK_MAIN -period $T_MAIN -waveform [list 0.0 [expr {$T_MAIN * 0.5}]] [get_ports i_clk_main]

# Inputs: the AXI request inputs and the TL-UL response inputs reach flip-flops through the address, mask,
# tag-decode, and arbitration logic (cut-through). The external delay leaves 55 % of the period to the IP
# (goal of section 17.1.2); the inputs that fan out to the engine states get the same value as a first
# estimate (35 % budget, to be tightened with the real netlist).
set_input_delay -clock CLK_MAIN -max [expr {$T_MAIN * 0.55}] [get_ports {i_axi_* i_tl_*}]
set_input_delay -clock CLK_MAIN -min 0.0                     [get_ports {i_axi_* i_tl_*}]

# Outputs: every output is a flip-flop output (REQ-IF-002), so the IP budget is the clock-to-output delay.
set_output_delay -clock CLK_MAIN -max [expr {$T_MAIN * 0.40}] [get_ports {o_axi_* o_tl_* o_evt_*}]
set_output_delay -clock CLK_MAIN -min 0.0                     [get_ports {o_axi_* o_tl_* o_evt_*}]

# Reset: asserted asynchronously and released synchronously by the SoC reset controller (RST-MAIN). Recovery
# and removal checks of the flip-flops are timed against CLK_MAIN; the reset input has no input delay here
# because its timing is owned by the reset controller of the SoC.
