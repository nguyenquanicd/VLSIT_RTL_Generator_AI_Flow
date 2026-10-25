"""Run the unit tests of the basic cells VLSIT_CELL_* (needs iverilog and vvp on PATH).

Usage:  python run_cell_tests.py
"""
import glob, os, subprocess, sys, tempfile

HERE = os.path.dirname(os.path.abspath(__file__))
CELLS = sorted(glob.glob(os.path.join(HERE, '..', 'rtl_cells', 'VLSIT_CELL_*.sv')))
rc = 0
with tempfile.TemporaryDirectory() as tmp:
    for tb in ('tb_cells_comb.sv', 'tb_cells_seq.sv'):
        vvp = os.path.join(tmp, tb + '.vvp')
        for cmd in (['iverilog', '-g2012', '-o', vvp, os.path.join(HERE, tb)] + CELLS, ['vvp', vvp]):
            r = subprocess.run(cmd, capture_output=True, text=True)
            if r.returncode != 0:
                sys.exit('FAILED: ' + ' '.join(cmd[:2]) + '\n' + r.stdout + r.stderr)
        line = [l for l in r.stdout.splitlines() if l.startswith(('PASS', 'FAIL'))]
        print('\n'.join(line))
        if not line or line[-1].startswith('FAIL'):
            rc = 1
sys.exit(rc)
