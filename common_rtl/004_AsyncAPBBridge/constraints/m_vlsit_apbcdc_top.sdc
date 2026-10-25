##############################################################################
# m_vlsit_apbcdc_top.sdc - timing constraints of the asynchronous APB bridge
# Dialect : Synopsys SDC (Design Compiler, PrimeTime, Fusion Compiler)
# Source  : AsyncAPBBridge_Design_Specification.md, section 17 (the tables there are the contract)
# Status  : written from the specification; the constraint syntax of the sign-off tool was not run
#           (see open item OI-004). The Tcl of this file is executed with stub commands by
#           check_sdc.py, which prints the values and the exceptions.
#
# Usage: define the variables below (or leave the defaults of the specification examples), then
#   set BRIDGE "u_apbcdc/"      ;# hierarchical prefix of the instance of m_vlsit_apbcdc_top, with the "/"
#   source m_vlsit_apbcdc_top.sdc
#
# The two clocks are unrelated: there is NO set_clock_groups and NO set_false_path between them,
# because a clock group or a false path would override the set_max_delay of the crossing paths.
# Every path between the domains is one of the five crossings CDC-001 to CDC-005 below; a path
# between the clocks that is not covered by one of them is a design error and is reported by
# report_timing as an unconstrained crossing (violation against the default relation).
##############################################################################

proc _vlsit_def {name value} {
  upvar #0 $name var
  if {![info exists var]} {
    set var $value
  }
}

# ---- variables (examples of the specification: 100 MHz requester side, 50 MHz completer side) ----
_vlsit_def BRIDGE        ""      ;# hierarchical prefix of the bridge instance, empty at the top
_vlsit_def T_MST         10.0    ;# period of i_clk_mst, ns
_vlsit_def T_SLV         20.0    ;# period of i_clk_slv, ns
_vlsit_def N_SYNC        2       ;# synchronizer stages: PARA_APBCDC_CELL_TYPE 1 and 2 give 2, 3 gives 3, 4 gives 4
_vlsit_def UNCERT_SETUP  0.10    ;# clock uncertainty for setup, ns
_vlsit_def UNCERT_HOLD   0.05    ;# clock uncertainty for hold, ns
_vlsit_def CLK_TRANS     0.10    ;# clock transition, ns
_vlsit_def IO_FRAC_IN    0.40    ;# input delay as a fraction of the period of the clock of the port
_vlsit_def IO_FRAC_OUT   0.40    ;# output delay as a fraction of the period of the clock of the port
_vlsit_def IN_TRANS      0.20    ;# transition of the input ports, ns
_vlsit_def OUT_LOAD      0.05    ;# load of the output ports, pF

if {$N_SYNC < 2} {
  error "N_SYNC must be 2 or more: PARA_APBCDC_CELL_TYPE = 0 (no stage) is for simulation only"
}

# ---- derived budgets of the crossing paths (section 17.1.2) ----
# Data bundles: the bundle must arrive before the destination flop that loads it. That flop loads at
# the destination edge number N_SYNC + 1 after the launch edge, so (N_SYNC - 1) destination periods
# leave a guard of one destination period, which replaces the clock latency difference that
# -ignore_clock_latency removes from the check.
set MAXD_REQ_PLD [expr {($N_SYNC - 1) * $T_SLV}]   ;# CDC-001 request bundle, destination clock i_clk_slv
set MAXD_RSP_PLD [expr {($N_SYNC - 1) * $T_MST}]   ;# CDC-004 response bundle, destination clock i_clk_mst
# Control bits: no logic in front of the first synchronizer stage; one destination period keeps the
# launch flop and the first stage close to each other.
set MAXD_REQ_CTL $T_SLV                            ;# CDC-002 request flop to its synchronizer
set MAXD_ACK_CTL $T_MST                            ;# CDC-003 acknowledge flop to its synchronizer
set MAXD_WK_CTL  $T_SLV                            ;# CDC-005 wakeup flop to its synchronizer

# ---- clocks ----
create_clock -name clk_mst -period $T_MST [get_ports i_clk_mst]
create_clock -name clk_slv -period $T_SLV [get_ports i_clk_slv]
set_clock_uncertainty -setup $UNCERT_SETUP [get_clocks clk_mst]
set_clock_uncertainty -hold  $UNCERT_HOLD  [get_clocks clk_mst]
set_clock_uncertainty -setup $UNCERT_SETUP [get_clocks clk_slv]
set_clock_uncertainty -hold  $UNCERT_HOLD  [get_clocks clk_slv]
set_clock_transition $CLK_TRANS [get_clocks clk_mst]
set_clock_transition $CLK_TRANS [get_clocks clk_slv]

# ---- port groups (ports that do not exist in the configuration, for example PWAKEUP in APB4, are skipped by -quiet) ----
set MST_IN  [get_ports -quiet {i_apb_psel i_apb_penable i_apb_pwrite i_apb_paddr* i_apb_pprot* i_apb_pstrb* i_apb_pwdata*
                               i_apb_pwakeup i_apb_pauser* i_apb_pwuser*}]
set MST_OUT [get_ports -quiet {o_apb_pready o_apb_prdata* o_apb_pslverr o_apb_pruser* o_apb_pbuser*}]
set SLV_IN  [get_ports -quiet {i_apb_pready i_apb_prdata* i_apb_pslverr i_apb_pruser* i_apb_pbuser*}]
set SLV_OUT [get_ports -quiet {o_apb_psel o_apb_penable o_apb_pwrite o_apb_paddr* o_apb_pprot* o_apb_pstrb* o_apb_pwdata*
                               o_apb_pwakeup o_apb_pauser* o_apb_pwuser*}]

# ---- interface budgets: every port is timed against the clock of its own domain ----
set_input_delay  -clock clk_mst -max [expr {$IO_FRAC_IN  * $T_MST}] $MST_IN
set_input_delay  -clock clk_mst -min 0.0                            $MST_IN
set_output_delay -clock clk_mst -max [expr {$IO_FRAC_OUT * $T_MST}] $MST_OUT
set_output_delay -clock clk_mst -min 0.0                            $MST_OUT
set_input_delay  -clock clk_slv -max [expr {$IO_FRAC_IN  * $T_SLV}] $SLV_IN
set_input_delay  -clock clk_slv -min 0.0                            $SLV_IN
set_output_delay -clock clk_slv -max [expr {$IO_FRAC_OUT * $T_SLV}] $SLV_OUT
set_output_delay -clock clk_slv -min 0.0                            $SLV_OUT
set_input_transition $IN_TRANS $MST_IN
set_input_transition $IN_TRANS $SLV_IN
set_load $OUT_LOAD $MST_OUT
set_load $OUT_LOAD $SLV_OUT

# ---- resets: asynchronous assertion, release synchronous to the clock of the domain and made outside the IP.
# The release is timed as an input (recovery and removal checks of the flops against the own clock).
set_input_delay -clock clk_mst -max [expr {$IO_FRAC_IN * $T_MST}] [get_ports i_rst_n_mst]
set_input_delay -clock clk_mst -min 0.0                           [get_ports i_rst_n_mst]
set_input_delay -clock clk_slv -max [expr {$IO_FRAC_IN * $T_SLV}] [get_ports i_rst_n_slv]
set_input_delay -clock clk_slv -min 0.0                           [get_ports i_rst_n_slv]

# ---- crossing endpoints (instance and register names are fixed by section 14 of the specification) ----
set MST ${BRIDGE}u_vlsit_apbcdc_mst
set SLV ${BRIDGE}u_vlsit_apbcdc_slv
set REQ_PLD_SRC [get_cells -hierarchical ${MST}/reg_req_payload*]
set REQ_PLD_DST [get_cells -hierarchical ${SLV}/reg_apb_payload*]
set REQ_CTL_SRC [get_cells -hierarchical ${MST}/reg_req]
set REQ_CTL_DST [get_cells -hierarchical ${SLV}/u_sync_req/*]
set ACK_CTL_SRC [get_cells -hierarchical ${SLV}/reg_ack]
set ACK_CTL_DST [get_cells -hierarchical ${MST}/u_sync_ack/*]
set RSP_PLD_SRC [get_cells -hierarchical ${SLV}/reg_resp_hold*]
set RSP_PLD_DST [get_cells -hierarchical ${MST}/reg_resp_payload*]
set WK_CTL_SRC  [get_cells -quiet -hierarchical ${MST}/reg_wakeup]
set WK_CTL_DST  [get_cells -quiet -hierarchical ${SLV}/u_sync_wk/*]

# ---- CDC-001 request bundle (mst to slv): address, protection, write, strobe, write data, user attributes ----
set_max_delay $MAXD_REQ_PLD -ignore_clock_latency -from $REQ_PLD_SRC -to $REQ_PLD_DST
set_false_path -hold -from $REQ_PLD_SRC -to $REQ_PLD_DST

# ---- CDC-002 request control (mst to slv): toggle or level of the handshake ----
set_max_delay $MAXD_REQ_CTL -ignore_clock_latency -from $REQ_CTL_SRC -to $REQ_CTL_DST
set_false_path -hold -from $REQ_CTL_SRC -to $REQ_CTL_DST

# ---- CDC-003 acknowledge control (slv to mst) ----
set_max_delay $MAXD_ACK_CTL -ignore_clock_latency -from $ACK_CTL_SRC -to $ACK_CTL_DST
set_false_path -hold -from $ACK_CTL_SRC -to $ACK_CTL_DST

# ---- CDC-004 response bundle (slv to mst): read data, error, user attributes ----
set_max_delay $MAXD_RSP_PLD -ignore_clock_latency -from $RSP_PLD_SRC -to $RSP_PLD_DST
set_false_path -hold -from $RSP_PLD_SRC -to $RSP_PLD_DST

# ---- CDC-005 wakeup (mst to slv), only in the APB5 configuration ----
if {[sizeof_collection $WK_CTL_SRC] > 0} {
  set_max_delay $MAXD_WK_CTL -ignore_clock_latency -from $WK_CTL_SRC -to $WK_CTL_DST
  set_false_path -hold -from $WK_CTL_SRC -to $WK_CTL_DST
}

# ---- the cells instantiated by the wrappers are named u_dont_touch_<function>: the implementation must not change them ----
set_dont_touch [get_cells -quiet -hierarchical *u_dont_touch_*]
