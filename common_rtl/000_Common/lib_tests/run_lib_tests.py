"""Run the tests of m_vlsit_rst_sync and m_vlsit_tie in both flows (needs iverilog and vvp on PATH).

Usage:  python run_lib_tests.py
"""
import glob, os, subprocess, sys, tempfile

HERE = os.path.dirname(os.path.abspath(__file__))
COMMON = os.path.abspath(os.path.join(HERE, '..'))
SRC = [os.path.join(COMMON, 'rtl_lib', 'm_vlsit_rst_sync.sv'), os.path.join(COMMON, 'rtl_lib', 'm_vlsit_tie.sv')]
SRC += sorted(glob.glob(os.path.join(COMMON, 'rtl_cells', 'VLSIT_CELL_*.sv')))
# (testbench, defines, plusargs)
RUNS = [('tb_rst_sync.sv', ['-DVLSIT_SYNTHESIS'], []),
        ('tb_rst_sync.sv', [], ['+RSTSYNC_MSYNC_EN=0']),
        ('tb_tie.sv', ['-DVLSIT_SYNTHESIS'], []), ('tb_tie.sv', [], [])]
RUNS += [('tb_rst_sync.sv', [], ['+RSTSYNC_MSYNC_SEED=%d' % s]) for s in (1, 2, 3, 11, 12345)]
rc = 0
with tempfile.TemporaryDirectory() as tmp:
    for tb, defs, plus in RUNS:
        vvp = os.path.join(tmp, 'a.vvp')
        r = subprocess.run(['iverilog', '-g2012', '-o', vvp] + defs + [os.path.join(HERE, tb)] + SRC, capture_output=True, text=True)
        if r.returncode:
            sys.exit('FAILED: iverilog\n' + r.stdout + r.stderr)
        r = subprocess.run(['vvp', vvp] + plus, capture_output=True, text=True)
        res = [l for l in r.stdout.splitlines() if l.startswith(('PASS', 'FAIL'))]
        print(' '.join(defs + plus) or '(simulation)', '->', res[-1] if res else 'NO RESULT')
        if not res or any(l.startswith('FAIL') for l in res):
            rc = 1
sys.exit(rc)
