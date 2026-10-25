// filelist_lint.f - lint set: flow macro, cell and macro models, wrappers (000_Common), design (rtl).
// The cell models VLSIT_CELL_* (rtl_cells) are synthesizable stand-ins for library cells and macros (rule R-032).
+define+VLSIT_SYNTHESIS
../../000_Common/rtl_cells/VLSIT_CELL_SYNC_DFF_RN.sv
../../000_Common/rtl_cells/VLSIT_CELL_SYNC_DFF_SN.sv
../../000_Common/rtl_cells/VLSIT_CELL_SYNC_2FF_RN.sv
../../000_Common/rtl_cells/VLSIT_CELL_SYNC_2FF_SN.sv
../../000_Common/rtl_cells/VLSIT_CELL_SYNC_3FF_RN.sv
../../000_Common/rtl_cells/VLSIT_CELL_SYNC_3FF_SN.sv
../../000_Common/rtl_cells/VLSIT_CELL_SYNC_4FF_RN.sv
../../000_Common/rtl_cells/VLSIT_CELL_SYNC_4FF_SN.sv
../../000_Common/rtl_cells/VLSIT_CELL_SRAM_1W1R.sv
../../000_Common/rtl_lib/m_vlsit_afifo_ram_macro.sv
../rtl/m_vlsit_afifo_mem.sv
../../000_Common/rtl_lib/m_vlsit_afifo_cell_sync.sv
../rtl/m_vlsit_afifo_sync.sv
../rtl/m_vlsit_afifo_rd.sv
../rtl/m_vlsit_afifo_wr.sv
../rtl/m_vlsit_afifo_top.sv
