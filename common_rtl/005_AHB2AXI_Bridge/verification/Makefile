SHELL := /usr/bin/sh
.DEFAULT_GOAL := all

# Override these paths when the local tool installations differ.
PYTHON ?= /c/Users/PC/AppData/Local/Programs/Python/Python312/python.exe
CODEX_SKILLS ?= /c/Users/PC/.codex/skills
OSS_ROOT ?= /c/Tools/oss-cad-suite
MSYS_CXX_BIN ?= /c/Users/PC/Tools/msys64/ucrt64/bin

SKILL_SCRIPTS := $(CODEX_SKILLS)/vlsit-rtl-generator/scripts
WAVEDROM_SCRIPT := $(CODEX_SKILLS)/vlsit-wavedrom-waveform/scripts/vlsit_wavedrom_waveform.py
WAVE_SVG_SCRIPT := $(CODEX_SKILLS)/vlsit-asic-ip-microspec/scripts/vlsit_waveform_svg.py
OSS_BIN := $(OSS_ROOT)/bin
VERILATOR := $(OSS_BIN)/verilator_bin.exe
YOSYS := $(OSS_BIN)/yosys.exe
VERILATOR_ROOT := $(OSS_ROOT)/share/verilator

export VERILATOR_ROOT
export YOSYSHQ_ROOT := C:/Tools/oss-cad-suite
export PATH := $(MSYS_CXX_BIN):$(OSS_BIN):$(OSS_ROOT)/lib:$(PATH)
# The installed Verilator runtime and this MinGW compiler require a consistent ABI.
export CXXFLAGS += -std=gnu++17 -D_GLIBCXX_USE_CXX11_ABI=0

RTL_DIR := ../rtl
BUILD_DIR := build
LOG_DIR := logs
WAVE_DIR := waveforms_sim
WAVEJSON_DIR := waveforms_json
SVG_DIR := waveforms_svg
EVIDENCE_DIR := evidence
OBJ_DIR := $(BUILD_DIR)/obj_dir
SIM_EXE := $(OBJ_DIR)/tb_ahb2axi_sim.exe

RTL_SOURCES := m_ahb2axi_ahb_if.sv m_ahb2axi_axi_if.sv \
  ../../002_SyncFIFO/rtl/m_vlsit_sfifo_mem.sv \
  ../../002_SyncFIFO/rtl/m_vlsit_sfifo_rd.sv \
  ../../002_SyncFIFO/rtl/m_vlsit_sfifo_wr.sv \
  ../../002_SyncFIFO/rtl/m_vlsit_sfifo_top.sv \
  m_ahb2axi_ctrl.sv m_ahb2axi_top.sv

.PHONY: all prepare check lint compile sim waves mutation-check synth show-logs

prepare:
	mkdir -p $(BUILD_DIR) $(LOG_DIR) $(WAVE_DIR) $(WAVEJSON_DIR) $(SVG_DIR) $(EVIDENCE_DIR)

check: prepare
	$(PYTHON) $(SKILL_SCRIPTS)/vlsit_rtl_check.py check $(RTL_DIR) --report $(LOG_DIR)/rtl_rule_report.md

lint: prepare
	$(PYTHON) $(SKILL_SCRIPTS)/vlsit_lint_rtl.py lint $(RTL_DIR)/filelist.f --top m_ahb2axi_top --tool verilator --log $(LOG_DIR)/rtl_lint.log

compile: prepare
	cd $(RTL_DIR) && $(VERILATOR) --binary --timing --trace -Wno-fatal --top-module tb_ahb2axi --Mdir ../verification/$(OBJ_DIR) -o tb_ahb2axi_sim -f filelist.f ../verification/tb_ahb2axi.sv > ../verification/$(LOG_DIR)/verilator_build.log 2>&1

# CASE=0 runs the combined regression and aggregate assertion hit-count gate.
# CASE=1..6 runs
# one isolated waveform scenario after reset and writes its own waveform/log.
sim: compile
	@set +e; overall=0; \
	for case_id in 0 1 2 3 4 5 6; do \
	  case $$case_id in \
	    0) stem=full_regression ;; \
	    1) stem=wf001_shared_reset ;; \
	    2) stem=wf002_read_error ;; \
	    3) stem=wf003_bufferable_burst ;; \
	    4) stem=wf004_nonbufferable_write ;; \
	    5) stem=wf005_rejected_access ;; \
	    6) stem=wf006_4k_split ;; \
	  esac; \
	  (cd $(WAVE_DIR)/.. && ./$(SIM_EXE) +CASE=$$case_id) > $(LOG_DIR)/$$stem.log 2>&1; rc=$$?; \
	  if test $$rc -eq 0 && grep -q 'AHB-to-AXI verification PASS' $(LOG_DIR)/$$stem.log; then \
	    echo "PASS $$stem"; \
	  else \
	    echo "FAIL $$stem (see $(LOG_DIR)/$$stem.log)"; overall=1; \
	  fi; \
	done; exit $$overall

waves: prepare
	@set -e; \
	for stem in wf001_shared_reset wf002_read_error wf003_bufferable_burst wf004_nonbufferable_write wf005_rejected_access wf006_4k_split; do \
	  $(PYTHON) $(WAVEDROM_SCRIPT) vcd-info $(WAVE_DIR)/$$stem.vcd > $(LOG_DIR)/$$stem.vcd-info.txt; \
	  $(PYTHON) $(WAVEDROM_SCRIPT) vcd-to-wavejson $(WAVE_DIR)/$$stem.vcd --signals 'i_clk_core,i_rst_n_core,i_ahb_hsel,i_ahb_haddr,i_ahb_htrans,i_ahb_hburst,i_ahb_hprot,i_ahb_hmastlock,i_ahb_hwdata,i_ahb_hwstrb,o_ahb_hreadyout,o_ahb_hresp,o_ahb_hrdata,o_axi_arvalid,o_axi_araddr,o_axi_arlen,o_axi_rready,i_axi_arready,i_axi_rvalid,i_axi_rresp,o_axi_awvalid,o_axi_awaddr,o_axi_awlen,i_axi_awready,o_axi_wvalid,o_axi_wdata,o_axi_wstrb,o_axi_wlast,i_axi_wready,i_axi_bvalid,i_axi_bresp,o_axi_bready' --period 10ns --out $(WAVEJSON_DIR)/$$stem.json --force; \
	  $(PYTHON) $(WAVEDROM_SCRIPT) lint $(WAVEJSON_DIR)/$$stem.json; \
	  $(PYTHON) $(WAVE_SVG_SCRIPT) render $(WAVEJSON_DIR)/$$stem.json --out $(SVG_DIR)/$$stem.svg --force; \
	  cp $(WAVE_DIR)/$$stem.vcd $(WAVEJSON_DIR)/$$stem.json $(SVG_DIR)/$$stem.svg $(EVIDENCE_DIR)/; \
	done
	$(PYTHON) $(SKILL_SCRIPTS)/vlsit_sim_evidence.py check ../AHB2AXI_Bridge_Design_Specification.md $(EVIDENCE_DIR) --logs $(LOG_DIR) --cdc no

# Mutate only the disposable copy: single-beat AXI reads must keep ARLEN=0.
mutation-check: prepare
	rm -rf $(BUILD_DIR)/mutation
	mkdir -p $(BUILD_DIR)/mutation/rtl
	cp $(RTL_DIR)/m_ahb2axi_ahb_if.sv $(RTL_DIR)/m_ahb2axi_axi_if.sv $(RTL_DIR)/m_ahb2axi_top.sv $(BUILD_DIR)/mutation/rtl/
	cp ../../002_SyncFIFO/rtl/m_vlsit_sfifo_*.sv $(BUILD_DIR)/mutation/rtl/
	sed "s/w_axi_ar_len   = 8'd0;/w_axi_ar_len   = 8'd1;/" $(RTL_DIR)/m_ahb2axi_ctrl.sv > $(BUILD_DIR)/mutation/rtl/m_ahb2axi_ctrl.sv
	cd $(BUILD_DIR)/mutation/rtl && printf '%s\n' m_ahb2axi_ahb_if.sv m_ahb2axi_axi_if.sv m_vlsit_sfifo_mem.sv m_vlsit_sfifo_rd.sv m_vlsit_sfifo_wr.sv m_vlsit_sfifo_top.sv m_ahb2axi_ctrl.sv m_ahb2axi_top.sv > filelist.f
	cd $(BUILD_DIR)/mutation/rtl && $(VERILATOR) --binary --timing --trace -Wno-fatal --top-module tb_ahb2axi --Mdir ../obj_dir -o tb_ahb2axi_mut -f filelist.f ../../../tb_ahb2axi.sv > ../../../$(LOG_DIR)/verilator_mutation_build.log 2>&1
	@set +e; (cd $(BUILD_DIR)/mutation/obj_dir && ./tb_ahb2axi_mut.exe +CASE=0) > $(LOG_DIR)/mutation_arlen.log 2>&1; rc=$$?; \
	if test $$rc -eq 0; then echo "FAIL mutation was not detected"; exit 1; fi; \
	if grep -q 'ASSERT_FAIL AXI 05 single-beat read ARLEN' $(LOG_DIR)/mutation_arlen.log; then echo "PASS mutation caught AXI ARLEN error"; else echo "FAIL expected AXI ARLEN assertion missing"; exit 1; fi

synth: export PATH := $(OSS_BIN):$(OSS_ROOT)/lib:$(MSYS_CXX_BIN):$(PATH)
synth: prepare
	cd $(RTL_DIR) && $(YOSYS) -Q -l ../verification/$(LOG_DIR)/yosys_synth.log -p "read_verilog -sv $(RTL_SOURCES); hierarchy -check -top m_ahb2axi_top; synth -top m_ahb2axi_top; check -assert; stat; write_verilog -noattr ../verification/$(BUILD_DIR)/m_ahb2axi_top_synth.v"

# Run all stages even if one fails so simulation and synthesis evidence both exist.
all: prepare
	@set +e; \
	$(MAKE) check; check_rc=$$?; \
	$(MAKE) lint; lint_rc=$$?; \
	$(MAKE) sim; sim_rc=$$?; \
	$(MAKE) waves; waves_rc=$$?; \
	$(MAKE) mutation-check; mutation_rc=$$?; \
	$(MAKE) synth; synth_rc=$$?; \
	if test $$check_rc -ne 0 || test $$lint_rc -ne 0 || test $$sim_rc -ne 0 || test $$waves_rc -ne 0 || test $$mutation_rc -ne 0 || test $$synth_rc -ne 0; then exit 1; fi

show-logs:
	@for log in $(LOG_DIR)/*.log; do echo "--- $$log"; tail -n 12 $$log; done
