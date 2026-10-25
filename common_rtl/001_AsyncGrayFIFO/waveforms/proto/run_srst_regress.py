"""Regression of the software reset protocol prototype (srst_proto.sv).

Usage:  python run_srst_regress.py [work_dir]      (iverilog and vvp on PATH, lib directory too)
Matrix: seeds 1..12 x clock half-period pairs (write, read) in ns {(5,7), (3,11), (11,3)}
        x metastability model off / on, for each stimulus mode:
          mode 0: the next software reset starts after the write side is released
          mode 1: i_rst_n_sw may be asserted again at any time (also while the write FSM is in REL)
          mode 2: as mode 1, and a quarter of the resets are aborted by a hardware reset of both domains
Each run applies 20 random software resets under random traffic with a scoreboard.
Negative run: the same with the "flush check" removed (mode 1, model on).
Scripted scenarios 1 to 4 are the ones drawn in the waveforms of the specification.
"""
import os, re, subprocess, sys

HERE = os.path.dirname(os.path.abspath(__file__))
WORK = os.path.abspath(sys.argv[1] if len(sys.argv) > 1 else os.path.join(HERE, '_regress'))
os.makedirs(WORK, exist_ok=True)
vvp = os.path.join(WORK, 'srst.vvp')
if os.path.exists(vvp): os.remove(vvp)
r = subprocess.run(['iverilog', '-g2012', '-o', vvp, os.path.join(HERE, 'srst_proto.sv')], capture_output=True, text=True, cwd=WORK)
if not os.path.exists(vvp): sys.exit('compile failed\n' + r.stdout + r.stderr)

def vvp_run(*args):
    return subprocess.run(['vvp', vvp, *args], capture_output=True, text=True, cwd=WORK).stdout

def run(seed, hw, hr, rnd, mode, noflush):
    out = vvp_run(f'+SEED={seed}', f'+HW={hw}', f'+HR={hr}', f'+RAND={rnd}', f'+MODE={mode}', f'+NOFLUSH={noflush}', '+NCYC=20')
    m = re.search(r'RESULT .* (PASS|FAIL)', out)
    return m.group(1) if m else 'NO-RESULT'

ratios = [(5, 7), (3, 11), (11, 3)]
bad = 0
for n in (1, 2, 3, 4):
    line = [l for l in vvp_run(f'+SCRIPT={n}').splitlines() if l.startswith('SCRIPT=')]
    print(line[0] if line else f'SCRIPT={n} NO-RESULT')
    bad += 0 if line and line[0].endswith('PASS') else 1
for mode in (0, 1, 2):
    res = [run(s, hw, hr, rnd, mode, 0) for rnd in (0, 1) for (hw, hr) in ratios for s in range(1, 13)]
    print(f'positive mode {mode}: runs={len(res)} pass={res.count("PASS")} fail={res.count("FAIL")} other={len(res) - res.count("PASS") - res.count("FAIL")}')
    bad += len(res) - res.count('PASS')
res = [run(s, hw, hr, 1, 1, 1) for (hw, hr) in ratios for s in range(1, 13)]
print(f'negative (flush check removed, mode 1, model on): runs={len(res)} pass={res.count("PASS")} fail={res.count("FAIL")}')
print('RESULT', 'OK' if bad == 0 else 'POSITIVE RUNS FAILED')
