# =============================================================================
# APB4 to TL-UL bridge (m_apb_tlul_bridge) - the ONE Makefile for the sanity checks:
# rule check, lint and self-checking simulation. Works on Windows and Linux.
# =============================================================================
#
# QUICK START (run from this folder, the folder of this file)
#
#   make help          list every target
#   make info          show the detected OS, tools and versions
#   make all           check + lint + sim + sim-narrow
#   make check         VLSIT RTL rule check of rtl/           -> sanity/rtl_check_report.md
#   make lint          Verilator and slang lint of rtl/       -> sanity/lint_verilator.log, lint_slang.log
#   make sim           testbench, default parameters          -> sanity/sim_default.log
#   make sim-narrow    testbench, PARA_ADDR_W=16, PARA_SRC_W=1, PARA_SRC_ID=1 -> sanity/sim_narrow.log
#   make sim SEED=7 N=2000     another random seed and more random transfers
#   make clean         remove build/ (the sanity/ results are kept for the repository)
#
# FOLDERS
#   rtl/            the design RTL and filelist.f (design files only)
#   verification/   the self-checking testbench
#   sanity/         the logs and the report of the last run, released together with the RTL
#   build/          compiled simulation (not released)
#
# REQUIREMENTS
#   * GNU make and a POSIX shell with mkdir/rm/cat
#       Linux  : the normal "make" of the distribution
#       Windows: make from MSYS2 or Git Bash (cmd.exe-only make programs are NOT supported)
#   * Icarus Verilog 12+ (iverilog, vvp) for the simulation; Verilator and/or slang for the lint.
#     The OSS CAD Suite (https://github.com/YosysHQ/oss-cad-suite-build) contains all of them.
#   * Python 3 (standard library only) for the check and lint scripts of the skill
#     vlsit-rtl-generator, found by the relative path SKILL below (this folder is common_rtl/008_APB2TLUL_Bridge
#     of the repository VLSIT_RTL_Generator_AI_Model).
#
# WINDOWS EXAMPLE
#   make all                                   (OSS CAD Suite expected in C:/Tools/oss-cad-suite)
#   make all OSSCAD=D:/tools/oss-cad-suite     (another location)
#   make all PYTHON=C:/Python312/python.exe    (a Python that is not on PATH)
# LINUX EXAMPLE
#   make all                                   (tools already in PATH)
#   make all OSSCAD=$HOME/oss-cad-suite
#
# EXIT STATUS: every target returns non-zero when it fails (rule error, lint error, failed check of
# the testbench, which ends with $fatal), so the Makefile can be used in CI.
# =============================================================================

.DEFAULT_GOAL := help

# -----------------------------------------------------------------------------
# 1. Host detection and tool locations
# -----------------------------------------------------------------------------
# Windows is detected by the OS variable (set by Windows) or, in MSYS2/Git Bash where it can be missing,
# by the name reported by uname.
UNAME_S := $(shell uname -s 2>/dev/null)
ifneq ($(findstring Windows_NT,$(OS))$(findstring MINGW,$(UNAME_S))$(findstring MSYS,$(UNAME_S))$(findstring CYGWIN,$(UNAME_S)),)
  HOST := windows
  OSSCAD ?= C:/Tools/oss-cad-suite
else
  HOST := linux
  OSSCAD ?=
endif

# Put bin/ and lib/ of an OSS CAD Suite in PATH when the folder exists. Under MSYS2/Git Bash the PATH
# is a POSIX list, so the Windows folder is first converted with cygpath; on Linux it is used as is.
ifneq ($(strip $(OSSCAD)),)
  ifneq ($(wildcard $(OSSCAD)/bin),)
    OSSCAD_P := $(or $(shell cygpath -u "$(OSSCAD)" 2>/dev/null),$(OSSCAD))
    PATHSEP  := $(if $(findstring ;,$(PATH)),;,:)
    export PATH := $(OSSCAD_P)/bin$(PATHSEP)$(OSSCAD_P)/lib$(PATHSEP)$(PATH)
  endif
endif

IVERILOG ?= iverilog
VVP      ?= vvp
# On Windows the command "python" is often only a Microsoft Store stub: the OSS CAD Suite brings
# python3.exe; on Linux use python3.
ifeq ($(HOST),windows)
  PYTHON ?= $(if $(wildcard $(OSSCAD)/lib/python3.exe),$(OSSCAD)/lib/python3.exe,python)
else
  PYTHON ?= python3
endif

# -----------------------------------------------------------------------------
# 2. Files and options
# -----------------------------------------------------------------------------
SKILL     := ../../../VLSIT_RTL_Generator_AI_Model/.claude/skills/vlsit-rtl-generator/scripts
CHECK_PY  := $(SKILL)/vlsit_rtl_check.py
LINT_PY   := $(SKILL)/vlsit_lint_rtl.py

TOP       := m_apb_tlul_bridge
TB_TOP    := tb_apb_tlul_bridge
RTL_FILES := rtl/m_apb_if.sv rtl/m_tlul_if.sv rtl/m_apb_tlul_bridge.sv
TB_FILE   := verification/apb_tlul_protocol_assertions.sv verification/tb_apb_tlul_bridge.sv
FILELIST  := rtl/filelist.f

BUILD     := build
SANITY    := sanity
# The Windows build of iverilog needs a temporary folder that exists; TMP/TEMP can be unset or point to a
# missing folder (error "Error opening temporary file"), so the build/ folder is used for it.
ifeq ($(HOST),windows)
  TMPW := $(or $(shell cygpath -m "$(CURDIR)/$(BUILD)" 2>/dev/null),$(CURDIR)/$(BUILD))
  export TMP := $(TMPW)
  export TEMP := $(TMPW)
  export TMPDIR := $(TMPW)
endif

SEED      ?= 1
N         ?= 400

# iverilog -P overrides of the testbench parameters for the narrow configuration (CFG-NARROW)
NARROW    := -P$(TB_TOP).PARA_ADDR_W=16 -P$(TB_TOP).PARA_SRC_W=1 -P$(TB_TOP).PARA_SRC_ID=1

# -----------------------------------------------------------------------------
# 3. Targets
# -----------------------------------------------------------------------------
.PHONY: help info all check lint sim sim-narrow clean

help:
	@echo "Targets: all check lint sim sim-narrow clean info help"
	@echo "Options: SEED=<n> N=<random transfers> OSSCAD=<oss-cad-suite folder> PYTHON=<python>"
	@echo "See the header of this Makefile."

info:
	@echo "host   : $(HOST)"
	@echo "OSSCAD : $(OSSCAD)"
	@echo "python : $(PYTHON)"
	@$(PYTHON) --version
	@echo "iverilog: $$(command -v $(IVERILOG) || echo NOT FOUND)"
	@echo "skill  : $(SKILL)"

all: check lint sim sim-narrow
	@echo "ALL CHECKS PASSED (results in $(SANITY)/)"

$(BUILD) $(SANITY):
	@mkdir -p $@

check: | $(SANITY)
	$(PYTHON) $(CHECK_PY) check rtl --report $(SANITY)/rtl_check_report.md

lint: | $(SANITY)
	@rm -f $(SANITY)/lint_verilator.log $(SANITY)/lint_slang.log
	$(PYTHON) $(LINT_PY) lint $(FILELIST) --top $(TOP) --tool verilator --log $(SANITY)/lint_verilator.log
	$(PYTHON) $(LINT_PY) lint $(FILELIST) --top $(TOP) --tool slang --log $(SANITY)/lint_slang.log

sim: | $(BUILD) $(SANITY)
	$(IVERILOG) -g2012 -s $(TB_TOP) -o $(BUILD)/sim_default.vvp $(RTL_FILES) $(TB_FILE)
	@$(VVP) $(BUILD)/sim_default.vvp +SEED=$(SEED) +N=$(N) > $(SANITY)/sim_default.log 2>&1; rc=$$?; cat $(SANITY)/sim_default.log; exit $$rc

sim-narrow: | $(BUILD) $(SANITY)
	$(IVERILOG) -g2012 -s $(TB_TOP) $(NARROW) -o $(BUILD)/sim_narrow.vvp $(RTL_FILES) $(TB_FILE)
	@$(VVP) $(BUILD)/sim_narrow.vvp +SEED=$(SEED) +N=$(N) > $(SANITY)/sim_narrow.log 2>&1; rc=$$?; cat $(SANITY)/sim_narrow.log; exit $$rc

clean:
	@rm -rf $(BUILD)
