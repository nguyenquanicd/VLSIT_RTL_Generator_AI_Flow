# CRC verification flow. From this directory run `make verify`.
PYTHON ?= python
VERILATOR ?= C:/Tools/oss-cad-suite/bin/verilator_bin.exe
CXX ?= g++
# Override for local installations, e.g. `make verify VERILATOR_ROOT=C:/oss-cad-suite/share/verilator`.
VERILATOR_ROOT ?= C:/Tools/oss-cad-suite/share/verilator
SEED ?= 20261025
N ?= 32
TEST_DIR := tests
BUILD_DIR := sanity/build

.PHONY: all verify test test-serial test-initial test-parallel test-chunked test-full mutation-test clean
all: verify
verify: test mutation-test
test: test-serial test-initial test-parallel test-chunked test-full

$(BUILD_DIR):
	mkdir -p $(BUILD_DIR)

test-serial: | $(BUILD_DIR)
	"$(PYTHON)" $(TEST_DIR)/run_verilator_sim.py tb_crc_serial m_crc_serial --seed $(SEED) --random-count $(N) --verilator "$(VERILATOR)" --cxx "$(CXX)" --verilator-root "$(VERILATOR_ROOT)"

test-initial: | $(BUILD_DIR)
	"$(PYTHON)" $(TEST_DIR)/run_verilator_sim.py tb_crc_initial_value m_crc_initial_value --seed $(SEED) --random-count $(N) --verilator "$(VERILATOR)" --cxx "$(CXX)" --verilator-root "$(VERILATOR_ROOT)"

test-parallel: | $(BUILD_DIR)
	"$(PYTHON)" $(TEST_DIR)/run_verilator_sim.py tb_crc_parallel m_crc_parallel --seed $(SEED) --random-count $(N) --verilator "$(VERILATOR)" --cxx "$(CXX)" --verilator-root "$(VERILATOR_ROOT)"

test-chunked: | $(BUILD_DIR)
	"$(PYTHON)" $(TEST_DIR)/run_verilator_sim.py tb_crc_parallel_crcw m_crc_parallel_crcw --seed $(SEED) --random-count $(N) --verilator "$(VERILATOR)" --cxx "$(CXX)" --verilator-root "$(VERILATOR_ROOT)"

test-full: | $(BUILD_DIR)
	"$(PYTHON)" $(TEST_DIR)/run_verilator_sim.py tb_crc_parallel_full m_crc_parallel_full --seed $(SEED) --random-count $(N) --verilator "$(VERILATOR)" --cxx "$(CXX)" --verilator-root "$(VERILATOR_ROOT)"

# A mutation changes only a copy and must be detected by tb_crc_parallel.
mutation-test: test-parallel
	"$(PYTHON)" $(TEST_DIR)/inject_mutation.py --verilator "$(VERILATOR)" --cxx "$(CXX)" --verilator-root "$(VERILATOR_ROOT)"

clean:
	rm -rf $(BUILD_DIR)

# Streaming CRC top in rtl_v2: independent specification-based simulation and generic synthesis.
.PHONY: v2-verify v2-sim v2-synth v2-mutation v2-waveforms v2-report v2-help
v2-verify:
	"$(PYTHON)" tests_v2/run_flow.py all

v2-sim:
	"$(PYTHON)" tests_v2/run_flow.py sim

v2-synth:
	"$(PYTHON)" tests_v2/run_flow.py synth

v2-mutation:
	"$(PYTHON)" tests_v2/run_flow.py mutation

v2-waveforms:
	"$(PYTHON)" tests_v2/run_flow.py evidence

v2-report:
	"$(PYTHON)" tests_v2/run_flow.py report

v2-help:
	@echo "v2-verify    Run simulation, synthesis, fault injection, waveforms and report"
	@echo "v2-sim       Run 14 configurations, three seeds, two independent streams"
	@echo "v2-synth     Run Yosys/slang generic synthesis and structural checks"
	@echo "v2-mutation  Detect an injected CRC bug in a copied RTL source"
	@echo "v2-waveforms Render ten measured simulation windows after v2-sim"
	@echo "v2-report    Summarize retained logs and results"
