"""Reproduce the FIFO and metastability waveforms of Section 10.6 of the AsyncGrayFIFO specification.

Usage:  python run_waveforms.py <output_dir>
Needs iverilog and vvp on PATH (OSS CAD Suite: both the bin and the lib directory).
Steps: simulate the real RTL with tb_fifo_wave.sv (scenario 1: overview; scenario 2: back-to-back, each
with the RTL array and with the SRAM macro model), simulate the metastability demo with seed 1, then draw the
SVG figures and the event tables with gen_all.py. The RTL files are taken from the folders of this IP and
from ../../../000_Common.
"""
import glob, os, shutil, subprocess, sys

HERE = os.path.dirname(os.path.abspath(__file__))
IP = os.path.abspath(os.path.join(HERE, '..', '..'))
COMMON = os.path.abspath(os.path.join(IP, '..', '000_Common'))
OUT = os.path.abspath(sys.argv[1] if len(sys.argv) > 1 else 'out')
WORK = os.path.join(OUT, '_work')
os.makedirs(WORK, exist_ok=True)

RTL = [os.path.join(IP, 'rtl', f) for f in ('m_vlsit_afifo_mem.sv', 'm_vlsit_afifo_sync.sv', 'm_vlsit_afifo_rd.sv',
                                              'm_vlsit_afifo_wr.sv', 'm_vlsit_afifo_top.sv')]
RTL += [os.path.join(COMMON, 'rtl_lib', f) for f in ('m_vlsit_afifo_cell_sync.sv', 'm_vlsit_afifo_ram_macro.sv')]
RTL += sorted(glob.glob(os.path.join(COMMON, 'rtl_cells', '*.sv')))

def run(cmd, cwd):
    r = subprocess.run(cmd, cwd=cwd, capture_output=True, text=True)
    if r.returncode != 0:
        sys.exit('FAILED: ' + ' '.join(cmd) + '\n' + r.stdout + r.stderr)
    return r.stdout

# scenario, macro flag, extra parameters, output VCD
runs = [(1, 0, [], 'afifo_0.vcd'), (1, 1, [], 'afifo_1.vcd'),
        (2, 0, ['DEPTH=8', 'FULL_THR=6', 'RD_FIRST=8', 'RD_HALF=5'], 'b2b_0.vcd'),
        (2, 1, ['DEPTH=8', 'FULL_THR=6', 'RD_FIRST=8', 'RD_HALF=5'], 'b2b_1.vcd')]
for scen, macro, extra, vcd in runs:
    vvp = os.path.join(WORK, vcd.replace('.vcd', '.vvp'))
    if os.path.exists(vvp):
        os.remove(vvp)
    cmd = ['iverilog', '-g2012', '-DVLSIT_SYNTHESIS', '-o', vvp, f'-Ptb_fifo_wave.SCEN={scen}', f'-Ptb_fifo_wave.USE_MACRO={macro}']
    cmd += [f'-Ptb_fifo_wave.{x}' for x in extra] + [os.path.join(HERE, 'tb_fifo_wave.sv')] + RTL
    run(cmd, WORK)
    run(['vvp', vvp, f'+VCD={vcd}'], WORK)
    print('simulated', vcd)

vvp = os.path.join(WORK, 'meta.vvp')
if os.path.exists(vvp):
    os.remove(vvp)
run(['iverilog', '-g2012', '-o', vvp, os.path.join(HERE, 'meta_demo.sv')], WORK)
log = run(['vvp', vvp, '+SEED=1'], WORK)
open(os.path.join(WORK, 'meta_log.txt'), 'w').write(log)
shutil.move(os.path.join(WORK, 'meta.vcd'), os.path.join(WORK, 'meta_seed.vcd'))

# gen_all.py reads the VCD and log files that are next to it: copy it and wavelib.py into WORK
for f in ('gen_all.py', 'wavelib.py'):
    shutil.copy(os.path.join(HERE, f), os.path.join(WORK, f))
run([sys.executable, 'gen_all.py', OUT], WORK)
print('figures and tables.txt written to', OUT)
