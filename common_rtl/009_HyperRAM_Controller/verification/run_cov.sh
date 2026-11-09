#!/bin/sh
# Line, branch and toggle coverage simulation of m_vlsit_hyperram_controller with Verilator.
# Usage: sh run_cov.sh <tag> [PARA_AXI_W=32|64] [PARA_DQ=8|16] [PARA_NCS=1|2] [PARA_ASYNC=0|1] [PARA_NTEST=n]
# Output: $COV_WORK/<tag>/coverage.dat (merge with: verilator_coverage --write merged.dat a.dat b.dat)
# Needs (Windows): OSS CAD Suite (verilator_bin.exe), MinGW g++ (MSYS2 ucrt64) and, because the
# verilator_bin.exe of the suite looks for its library folder at /yosyshq/share/verilator, a junction
# C:\yosyshq\share\verilator -> <OSS CAD>\share\verilator. make is not used: its temporary file
# handling fails in this environment, so the objects are compiled by g++ directly.
# Paths can be set with OSS_CAD_POSIX, MSYS_UCRT_POSIX and VERILATOR_ROOT_WIN.
TAG=${1:?tag}
shift
OSS_P=${OSS_CAD_POSIX:-/c/Tools/oss-cad-suite}
GCC_P=${MSYS_UCRT_POSIX:-/c/Users/PC/Tools/msys64/ucrt64}
HERE=$(cd "$(dirname "$0")" && pwd)
WORK=${COV_WORK:-$HERE/cov_work}/$TAG
PATH="$GCC_P/bin:$OSS_P/bin:$PATH"
export PATH
VERILATOR_ROOT=${VERILATOR_ROOT_WIN:-'C:\Tools\oss-cad-suite\share\verilator'}
export VERILATOR_ROOT
INC=$OSS_P/share/verilator/include
GEN=""
for a in "$@"; do GEN="$GEN -G$a"; done
mkdir -p "$WORK" || exit 1
rm -rf "$WORK/obj"
cd "$HERE/../rtl" || exit 1
verilator_bin.exe --cc --exe --timing --coverage-line --coverage-toggle --Mdir "$WORK/obj" \
  -Wno-fatal -Wno-lint -Wno-style --top-module m_vlsit_tb_hyperram_cov -DVLSIT_SYNTHESIS $GEN \
  -f filelist.f ../verification/m_vlsit_hr_model.sv ../verification/m_vlsit_tb_hyperram_cov.sv \
  --prefix Vcov > "$WORK/verilator.log" 2>&1 || { tail -20 "$WORK/verilator.log"; exit 1; }
cd "$WORK/obj" || exit 1
CXXFLAGS="-O1 -w -I. -I$INC -I$INC/vltstd -DVERILATOR=1 -DVM_COVERAGE=1 -DVM_SC=0 -DVM_TIMING=1 \
 -DVM_TRACE=0 -DVM_TRACE_FST=0 -DVM_TRACE_VCD=0 -DVM_TRACE_SAIF=0 -DVM_VPI=0 -faligned-new \
 -fcf-protection=none -std=gnu++20"
for f in Vcov*.cpp "$HERE/cov_main.cpp" "$INC/verilated.cpp" "$INC/verilated_cov.cpp" \
         "$INC/verilated_covergroup.cpp" "$INC/verilated_threads.cpp" "$INC/verilated_timing.cpp"; do
  echo "$f"
done > srcs.txt
xargs -P 6 -I SRC sh -c "g++ $CXXFLAGS -c SRC -o \$(basename SRC .cpp).o" < srcs.txt || exit 1
g++ -Wl,--stack,536870912 -o Vcov_bin.exe ./*.o || exit 1
cd "$WORK" || exit 1
./obj/Vcov_bin.exe +cov_out="$WORK/coverage.dat" | tee sim.log
grep -q "COV TB PASS" sim.log
