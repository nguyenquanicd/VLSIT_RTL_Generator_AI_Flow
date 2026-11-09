#!/bin/sh
# Smoke and random-burst simulation of m_vlsit_hyperram_controller against the Infineon S27KS0641 model.
# Usage: sh run_smoke.sh [INIT_LAT] [x16]   (run from any folder; needs iverilog in PATH, e.g. OSS CAD Suite)
HERE=$(cd "$(dirname "$0")" && pwd)
LAT=${1:-4}
MODEL="$HERE/../reference/vendor_models/infineon_s27ks0641/ks/S27ks0641/model/s27ks0641.v"
DEF=""
WRAP=""
[ "$2" = "x16" ] && { DEF="-DX16"; WRAP="$HERE/m_vlsit_hr_x16_from_x8.sv"; }
cd "$HERE/../rtl" || exit 1
iverilog -g2012 $DEF -DVLSIT_SYNTHESIS -DINIT_LAT="$LAT" -s m_vlsit_tb_hyperram_smoke -o "$HERE/smoke.vvp" \
  -c filelist.f "$HERE/m_vlsit_tb_hyperram_smoke.sv" $WRAP "$MODEL" 2>&1 | grep -v "sorry:"
cd "$HERE" && vvp smoke.vvp | tee smoke.log | grep -v "^VCD"
grep -q "SMOKE PASS" smoke.log
