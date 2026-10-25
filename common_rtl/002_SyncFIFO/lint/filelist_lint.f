// filelist_lint.f - lint file list: the SyncFIFO RTL plus the SRAM wrapper and macro model, so that PARA_SFIFO_MEM_USE_MACRO = 1 elaborates.
// Paths are relative to the folder of this file; run tools from that folder.
+define+VLSIT_SYNTHESIS
../../000_Common/rtl_cells/VLSIT_CELL_SRAM_1W1R.sv
../../000_Common/rtl_lib/m_vlsit_sfifo_ram_macro.sv
../rtl/m_vlsit_sfifo_mem.sv
../rtl/m_vlsit_sfifo_rd.sv
../rtl/m_vlsit_sfifo_wr.sv
../rtl/m_vlsit_sfifo_top.sv
