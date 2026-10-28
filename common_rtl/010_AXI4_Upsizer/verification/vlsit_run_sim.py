"""Run the simulation of the AXI4 / AXI3 upsizer with Verilator (Windows and Linux).

  python vlsit_run_sim.py regress [--seeds 1,2,3] [--only name,name]   configurations of section 4 of the specification
  python vlsit_run_sim.py one <config> [--seed N] [--test directed|random|all] [--vcd file]

Logs go to logs/. The exit status is non-zero when a run fails.
"""
import argparse, os, shutil, subprocess, sys

HERE = os.path.dirname(os.path.abspath(__file__))
IP = os.path.abspath(os.path.join(HERE, '..'))
LOGS = os.path.join(HERE, 'logs')
BUILD = os.path.join(HERE, 'build')
SUITE = os.environ.get('OSS_CAD_SUITE', r'C:\Tools\oss-cad-suite')
MSYS = os.environ.get('VLSIT_MSYS', os.path.join(os.path.expanduser('~'), 'Tools', 'msys64'))

# configuration name -> (profile folder, parameter overrides of the testbench)
CONFIGS = {
    'axi4_def':   ('axi4', {'PROFILE': 4}),
    'axi3_def':   ('axi3', {'PROFILE': 3, 'IL_DEPTH': 2}),
    'axi3_il4':   ('axi3', {'PROFILE': 3, 'WR_DEPTH': 8, 'IL_DEPTH': 4}),
    'min_ratio':  ('axi4', {'PROFILE': 4, 'S_W': 512, 'M_W': 1024}),
    'max_ratio':  ('axi4', {'PROFILE': 4, 'S_W': 8, 'M_W': 1024, 'NTX': 60}),
    'depth2':     ('axi4', {'PROFILE': 4, 'WR_DEPTH': 2, 'RD_DEPTH': 2}),
    'id1_a12':    ('axi4', {'PROFILE': 4, 'S_W': 64, 'M_W': 256, 'ID_W': 1, 'ADDR_W': 12}),
    'id1_a64':    ('axi4', {'PROFILE': 4, 'S_W': 64, 'M_W': 256, 'ID_W': 1, 'ADDR_W': 64}),
}


def env():
    e = dict(os.environ)
    e['VERILATOR_ROOT'] = os.path.join(SUITE, 'share', 'verilator')
    if os.name == 'nt':
        e['PATH'] = os.pathsep.join([os.path.join(MSYS, 'ucrt64', 'bin'), os.path.join(MSYS, 'usr', 'bin'), e.get('PATH', '')])
        e['TMP'] = e['TEMP'] = os.environ.get('TEMP', e.get('TMP', ''))
    return e


def verilator():
    for c in (os.path.join(SUITE, 'bin', 'verilator_bin.exe'), os.path.join(SUITE, 'bin', 'verilator_bin'), 'verilator'):
        if os.path.exists(c) or shutil.which(c):
            return c
    sys.exit('verilator not found')


def rtl_files(profile):
    fl = os.path.join(IP, 'rtl', profile, 'filelist.f')
    base = os.path.dirname(fl)
    out = []
    for l in open(fl):
        l = l.strip()
        if l and not l.startswith('//') and not l.startswith('+'):
            out.append(os.path.normpath(os.path.join(base, l)))
    return out


def build(name):
    profile, params = CONFIGS[name]
    mdir = os.path.join(BUILD, name).replace(os.sep, '/')
    os.makedirs(mdir, exist_ok=True)
    exe = os.path.join(mdir, 'Vtb_ups.exe' if os.name == 'nt' else 'Vtb_ups')
    cmd = [verilator(), '--binary', '--timing', '--trace', '--top-module', 'tb_ups', '--Mdir', mdir,
           '-Wno-fatal', '-Wno-WIDTHEXPAND', '-Wno-WIDTHTRUNC', '-Wno-WIDTHCONCAT', '-Wno-UNOPTFLAT', '-Wno-CASEINCOMPLETE',
           '-Wno-INITIALDLY', '-Wno-BLKSEQ', '-Wno-MULTIDRIVEN', '-Wno-LATCH', '-Wno-UNSIGNED', '-Wno-CMPCONST',
           '-DVLSIT_SYNTHESIS', '-O1']
    if os.name == 'nt':
        cmd += ['-CFLAGS', '-D_GLIBCXX_USE_CXX11_ABI=0']
    cmd += ['-G%s=%s' % (k, v) for k, v in params.items()]
    cmd += rtl_files(profile) + [os.path.join(HERE, 'ups_axi_chk.sv'), os.path.join(HERE, 'tb_ups.sv')]
    os.makedirs(LOGS, exist_ok=True)
    r = subprocess.run(cmd, capture_output=True, text=True, env=env(), cwd=HERE)
    open(os.path.join(LOGS, 'build_%s.log' % name), 'w').write(r.stdout + r.stderr)
    if r.returncode or not os.path.exists(exe):
        print('BUILD FAILED', name)
        print((r.stdout + r.stderr)[-4000:])
        sys.exit(2)
    return exe


def run(name, exe, seed, test='all', vcd=None):
    args = [exe, '+SEED=%d' % seed, '+TEST=%s' % test]
    if vcd:
        args.append('+VCD=%s' % vcd)
    r = subprocess.run(args, capture_output=True, text=True, env=env(), cwd=HERE, timeout=3600)
    out = r.stdout + r.stderr
    path = os.path.join(LOGS, 'regress_%s_seed%d.log' % (name, seed))
    open(path, 'w').write(out)
    ok = (r.returncode == 0 and 'PASS tb_ups' in out and 'assertion failures: 0, assertions never exercised: 0' in out)
    return ok, out


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('cmd', choices=['regress', 'one'])
    ap.add_argument('config', nargs='?')
    ap.add_argument('--seeds', default='1,2,3')
    ap.add_argument('--seed', type=int, default=1)
    ap.add_argument('--only', default='')
    ap.add_argument('--test', default='all')
    ap.add_argument('--vcd', default=None)
    a = ap.parse_args()
    if a.cmd == 'one':
        exe = build(a.config)
        ok, out = run(a.config, exe, a.seed, a.test, a.vcd)
        print(out[-3000:])
        sys.exit(0 if ok else 1)
    names = a.only.split(',') if a.only else list(CONFIGS)
    good = True
    for n in names:
        exe = build(n)
        for s in [int(x) for x in a.seeds.split(',')]:
            ok, out = run(n, exe, s, a.test)
            print('%-10s seed %-3d %s' % (n, s, 'PASS' if ok else 'FAIL (see logs/regress_%s_seed%d.log)' % (n, s)))
            good &= ok
    sys.exit(0 if good else 1)


if __name__ == '__main__':
    main()
