Running ncverilog ..........
    irun15 +access+rwc +sv   +define+T133  W958D6NBKX.nc.vp  W958D6NBKX_sim.v (your test pattern)

Running VCS ................
    vcs -V -notice -full64 -debug_access+all -sverilog -R +define+T133  W958D6NBKX.vcs.vp W958D6NBKX_sim.v (your test pattern)

Running Intel Modelsim FPGA (free ver)...........
    rm -fr work
    vlib work
    vmap work work
    vlog -sv -sv09compat +define+T133 W958D6NBKX.modelsim.vp  W958D6NBKX_sim.v (your test pattern)
    vsim tb -batch -do "run -all" -logfile modelsim.log 

