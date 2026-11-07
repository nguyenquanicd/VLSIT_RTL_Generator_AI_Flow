# Timer DMA req/ack simulation. Run from this directory with GNU make.
PYTHON := C:/Users/PC/AppData/Local/Programs/Python/Python312/python.exe
VERILATOR := C:/Tools/oss-cad-suite/bin/verilator_bin.exe
VERILATOR_ROOT := C:/Tools/oss-cad-suite/share/verilator
RTL_RULES := -Wno-fatal -Wno-lint -Wno-style
BUILD := build

export VERILATOR_ROOT

.PHONY: all dma clean

all: dma

# 32-bit counter record: capture and compare/update 4-phase req/ack, error and clear recovery.
dma:
	@mkdir -p $(BUILD)/dma
	$(VERILATOR) --binary --timing --top-module tb_timer_dma_reqack --Mdir $(BUILD)/dma -MAKEFLAGS 'PYTHON3=$(PYTHON)' -CFLAGS '-D_GLIBCXX_USE_CXX11_ABI=0' $(RTL_RULES) ../rtl/m_vlsit_timer_dma.sv tb_timer_dma_reqack.sv
	$(BUILD)/dma/Vtb_timer_dma_reqack

clean:
	rm -rf $(BUILD)
