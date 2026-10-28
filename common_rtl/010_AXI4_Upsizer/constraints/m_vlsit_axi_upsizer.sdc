# m_vlsit_axi_upsizer.sdc - constraints owned by the AXI upsizer (specification section 17.1)
# Applies to m_vlsit_axi4_upsizer and m_vlsit_axi3_upsizer (same clock port, same single clock domain).
# Usage: set T_CLK_AXI <period in ns> before sourcing this file (the period is set by the SoC, TBD-001).
# The IP owns no timing exception (EXC-000, REQ-PD-001): no false path, multicycle path, minimum or maximum
# delay, clock group, case analysis or disabled arc is allowed on a path of the IP.
# The interface delays (set_input_delay, set_output_delay), the clock uncertainty and the transitions are
# owned by the SoC (section 17.1.2).

if {![info exists T_CLK_AXI]} {
  error "set T_CLK_AXI (clock period in ns) before sourcing m_vlsit_axi_upsizer.sdc"
}
if {$T_CLK_AXI <= 0} {
  error "T_CLK_AXI must be positive"
}

create_clock -name CLK_AXI -period $T_CLK_AXI [get_ports i_clk_axi]
