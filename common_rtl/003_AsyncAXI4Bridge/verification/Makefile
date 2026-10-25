# Repeatable Async AXI bridge simulation flow. Run from this directory with GNU make.
PYTHON := C:/Users/PC/AppData/Local/Programs/Python/Python312/python.exe
VERILATOR := C:/Tools/oss-cad-suite/bin/verilator_bin.exe
VERILATOR_ROOT := C:/Tools/oss-cad-suite/share/verilator
RTL_RULES := -Wno-fatal -Wno-WIDTHEXPAND -Wno-WIDTHTRUNC
BUILD := build
PROFILES := axi4_base axi4_user axi3
SEEDS := 1 2 3

export VERILATOR_ROOT

.PHONY: all prepare synth cdc waveforms evidence test
all: test

prepare:
	$(PYTHON) scripts/prepare_filelists.py

# Synthesis branch: VLSIT_SYNTHESIS is defined by each *_synth.f filelist.
build/%_synth/Vtb_axi_bridge.exe: prepare tb/tb_axi_bridge.sv filelists/%_synth.f
	@mkdir -p $(BUILD)/$*_synth
	$(VERILATOR) --binary --timing --trace --top-module tb_axi_bridge --Mdir $(BUILD)/$*_synth -MAKEFLAGS 'PYTHON3=$(PYTHON)' -CFLAGS '-D_GLIBCXX_USE_CXX11_ABI=0' $(RTL_RULES) $(if $(filter axi3,$*),-DTB_AXI3) $(if $(filter axi4_user,$*),-DTB_AXI4_USER) -f filelists/$*_synth.f tb/tb_axi_bridge.sv

# Simulation/metastability branch: the *_sim.f filelist intentionally omits VLSIT_SYNTHESIS.
build/%_sim/Vtb_axi_bridge.exe: prepare tb/tb_axi_bridge.sv filelists/%_sim.f
	@mkdir -p $(BUILD)/$*_sim
	$(VERILATOR) --binary --timing --trace --top-module tb_axi_bridge --Mdir $(BUILD)/$*_sim -MAKEFLAGS 'PYTHON3=$(PYTHON)' -CFLAGS '-D_GLIBCXX_USE_CXX11_ABI=0' $(RTL_RULES) -f filelists/$*_sim.f $(if $(filter axi3,$*),-DTB_AXI3) $(if $(filter axi4_user,$*),-DTB_AXI4_USER) tb/tb_axi_bridge.sv

build/axi4_base_small_synth/Vtb_axi_bridge.exe: prepare tb/tb_axi_bridge.sv filelists/axi4_base_synth.f
	@mkdir -p $(BUILD)/axi4_base_small_synth
	$(VERILATOR) --binary --timing --trace --top-module tb_axi_bridge --Mdir $(BUILD)/axi4_base_small_synth -MAKEFLAGS 'PYTHON3=$(PYTHON)' -CFLAGS '-D_GLIBCXX_USE_CXX11_ABI=0' $(RTL_RULES) -DTB_SMALL_DEPTH -f filelists/axi4_base_synth.f tb/tb_axi_bridge.sv

logs/synth_%.log: build/%_synth/Vtb_axi_bridge.exe scripts/normalize_sim_log.py
	-@$< +SEED=1 > $@.raw 2>&1
	$(PYTHON) scripts/normalize_sim_log.py $@.raw $@

synth: $(addprefix logs/synth_,$(addsuffix .log,$(PROFILES)))

define META_LOG_RULE
logs/meta_$(1)_seed$(2).log: build/$(1)_sim/Vtb_axi_bridge.exe scripts/normalize_sim_log.py
	-@$$< +SEED=$(2) +AFIFO_MSYNC_SEED=$(2) +AFIFO_MSYNC_EN=1 > $$@.raw 2>&1
	$$(PYTHON) scripts/normalize_sim_log.py $$@.raw $$@
endef
$(foreach profile,$(PROFILES),$(foreach seed,$(SEEDS),$(eval $(call META_LOG_RULE,$(profile),$(seed)))))

cdc: synth $(foreach profile,$(PROFILES),$(foreach seed,$(SEEDS),logs/meta_$(profile)_seed$(seed).log))
	$(PYTHON) C:/Users/PC/.codex/skills/vlsit-rtl-generator/scripts/vlsit_sim_evidence.py cdc logs --min-seeds 3

define WAVE_LOG_RULE
logs/wave_$(1).log: build/$(2)/Vtb_axi_bridge.exe scripts/normalize_sim_log.py
	-@$$< +SEED=1 +VCD=waveforms_sim/$(3).vcd > $$@.raw 2>&1
	$$(PYTHON) scripts/normalize_sim_log.py $$@.raw $$@
endef
$(eval $(call WAVE_LOG_RULE,wf001,axi4_base_synth,axi_wf001_write_burst))
$(eval $(call WAVE_LOG_RULE,wf002,axi4_base_synth,axi_wf002_read_burst))
$(eval $(call WAVE_LOG_RULE,wf003,axi4_base_synth,axi_wf003_aw_backpressure))
$(eval $(call WAVE_LOG_RULE,wf004,axi4_base_synth,axi_wf004_w_before_aw))
$(eval $(call WAVE_LOG_RULE,wf005,axi4_base_synth,axi_wf005_r_backpressure))
$(eval $(call WAVE_LOG_RULE,wf006,axi4_base_synth,axi_wf006_error_response))
$(eval $(call WAVE_LOG_RULE,wf007,axi4_user_synth,axi_wf007_user_signals))
$(eval $(call WAVE_LOG_RULE,wf008,axi3_synth,axi_wf008_axi3_mode))
$(eval $(call WAVE_LOG_RULE,wf009,axi4_base_synth,axi_wf009_reset_exit))
$(eval $(call WAVE_LOG_RULE,wf010,axi4_base_synth,axi_wf010_streaming))
$(eval $(call WAVE_LOG_RULE,wf011,axi4_base_small_synth,axi_wf011_small_depth))

waveforms: logs/wave_wf001.log logs/wave_wf002.log logs/wave_wf003.log logs/wave_wf004.log logs/wave_wf005.log logs/wave_wf006.log logs/wave_wf007.log logs/wave_wf008.log logs/wave_wf009.log logs/wave_wf010.log logs/wave_wf011.log
	$(PYTHON) scripts/build_waveform_evidence.py

evidence: cdc waveforms
	$(PYTHON) C:/Users/PC/.codex/skills/vlsit-rtl-generator/scripts/vlsit_sim_evidence.py check ../rtl/generation_notes/AsyncAXI4Bridge_Resolved_Design_Specification.md waveforms_sim --logs logs --cdc yes

test: synth
	-$(MAKE) -k cdc waveforms
	$(PYTHON) C:/Users/PC/.codex/skills/vlsit-rtl-generator/scripts/vlsit_sim_evidence.py check ../rtl/generation_notes/AsyncAXI4Bridge_Resolved_Design_Specification.md waveforms_sim --logs logs --cdc yes
