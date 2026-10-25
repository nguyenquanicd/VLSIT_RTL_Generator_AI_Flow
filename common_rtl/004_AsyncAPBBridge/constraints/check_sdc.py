"""Execute m_vlsit_apbcdc_top.sdc with stub SDC commands in a Tcl interpreter (tkinter) and print what it would apply.

This checks the Tcl syntax, the variable handling and the computed budgets. It does NOT check the SDC semantics of a
sign-off tool (set_max_delay -ignore_clock_latency, set_false_path -hold): those need Design Compiler or PrimeTime.
Usage: python check_sdc.py [T_MST T_SLV N_SYNC]    exit code 0 when the script ran and the budgets match the formulas.
"""
import os
import sys
import tkinter

here = os.path.dirname(os.path.abspath(__file__))
t_mst, t_slv, n_sync = (float(sys.argv[1]), float(sys.argv[2]), int(sys.argv[3])) if len(sys.argv) == 4 else (10.0, 20.0, 2)

tcl = tkinter.Tcl()
log = []
tcl.eval(r"""
set ::LOG {}
proc _rec {args} { lappend ::LOG [string map [list "
" " "] [join $args " "]] ; return "" }
foreach c {create_clock set_clock_uncertainty set_clock_transition set_input_delay set_output_delay set_input_transition
           set_load set_max_delay set_false_path set_dont_touch} {
  eval "proc $c {args} {_rec $c {*}\$args}"
}
proc get_ports {args} { return "ports:[lindex $args end]" }
proc get_clocks {args} { return "clocks:[lindex $args end]" }
proc get_cells {args} { return "cells:[lindex $args end]" }
proc sizeof_collection {c} { return 1 }
""")
tcl.eval("set T_MST %s; set T_SLV %s; set N_SYNC %d" % (t_mst, t_slv, n_sync))
tcl.eval("source {%s}" % os.path.join(here, "m_vlsit_apbcdc_top.sdc").replace("\\", "/"))
lines = list(tcl.splitlist(tcl.eval("set ::LOG")))
print("commands executed: %d" % len(lines))
for l in lines:
    if l.startswith(("create_clock", "set_max_delay", "set_false_path")):
        print("  " + l)
# the budgets must follow the formulas of the specification
want = {"req_pld": (n_sync - 1) * t_slv, "rsp_pld": (n_sync - 1) * t_mst, "req_ctl": t_slv, "ack_ctl": t_mst, "wk_ctl": t_slv}
got = [float(l.split()[1]) for l in lines if l.startswith("set_max_delay")]
exp = [want[k] for k in ("req_pld", "req_ctl", "ack_ctl", "rsp_pld", "wk_ctl")]
ok = got == exp
print("max-delay budgets (ns): %s, expected %s: %s" % (got, exp, "OK" if ok else "MISMATCH"))
try:
    tcl.eval("set N_SYNC 0; source {%s}" % os.path.join(here, "m_vlsit_apbcdc_top.sdc").replace("\\", "/"))
    print("N_SYNC = 0 was accepted: MISMATCH")
    ok = False
except tkinter.TclError as e:
    print("N_SYNC = 0 rejected: %s" % e)
sys.exit(0 if ok else 1)
