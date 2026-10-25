"""Reproduce the software reset waveforms of Section 10.7 of the AsyncGrayFIFO specification.

Usage:  python run_srst_waveforms.py <output_dir>
Needs iverilog and vvp on PATH (OSS CAD Suite: both the bin and the lib directory).
"""
import os, subprocess, sys

HERE = os.path.dirname(os.path.abspath(__file__))
OUT = os.path.abspath(sys.argv[1] if len(sys.argv) > 1 else 'out_srst')
WORK = os.path.join(OUT, '_work')
os.makedirs(WORK, exist_ok=True)
vvp = os.path.join(WORK, 'srst.vvp')
if os.path.exists(vvp): os.remove(vvp)
r = subprocess.run(['iverilog', '-g2012', '-o', vvp, os.path.join(HERE, 'srst_proto.sv')], capture_output=True, text=True, cwd=WORK)
if not os.path.exists(vvp): sys.exit('compile failed\n' + r.stdout + r.stderr)
for n in (1, 2, 3, 4):
    out = subprocess.run(['vvp', vvp, f'+SCRIPT={n}'], capture_output=True, text=True, cwd=WORK).stdout
    print([l for l in out.splitlines() if l.startswith('SCRIPT=')][0])
r = subprocess.run([sys.executable, os.path.join(HERE, 'gen_srst.py'), WORK, OUT], capture_output=True, text=True)
print(r.stdout.strip() or r.stderr.strip())
