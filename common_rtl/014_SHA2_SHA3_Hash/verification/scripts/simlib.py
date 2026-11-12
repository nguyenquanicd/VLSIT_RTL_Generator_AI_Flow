"""Build and run helpers: Verilator (OSS CAD Suite) on Windows. Not part of the RTL."""
import os
import re
import subprocess
import sys

import vec_lib as V

VER = V.VER
IP = os.path.dirname(VER)
RTL = IP + '/rtl'
TB = VER + '/tb'
WORK = VER + '/work'
VBIN = 'C:/Tools/oss-cad-suite/bin/verilator_bin.exe'
GXX = 'C:/Users/PC/Tools/msys64/ucrt64/bin'


def rtl_files():
    files = [l.strip() for l in open(RTL + '/filelist.f') if l.strip() and not l.startswith('//')]
    return [os.path.normpath(os.path.join(RTL, f)).replace(chr(92), '/') for f in files]


def env_for(bdir):
    os.makedirs(bdir + '/tmp', exist_ok=True)
    os.makedirs(bdir + '/shim', exist_ok=True)
    shim = bdir + '/shim/python3'
    with open(shim, 'w', newline=chr(10)) as fh:
        fh.write('#!/bin/bash' + chr(10) + 'exec "%s" "$@"' % sys.executable.replace(chr(92), '/') + chr(10))
    env = dict(os.environ)
    env.update(TMP=bdir + '/tmp', TEMP=bdir + '/tmp', TMPDIR=bdir + '/tmp', VERILATOR_ROOT='C:/Tools/oss-cad-suite/share/verilator')
    env['PATH'] = os.pathsep.join([bdir + '/shim', GXX, 'C:/Tools/oss-cad-suite/bin', 'C:/Users/PC/Tools/msys64/usr/bin', env['PATH']])
    return env


def build(name, params, synth=False, coverage=True, trace=True, extra_files=(), rtl_override=None, xinit='0'):
    """Compile tb_sha_top with parameters (dict name -> value). Returns the executable path or None."""
    bdir = '%s/%s' % (WORK, name)
    os.makedirs(bdir, exist_ok=True)
    exe = bdir + '/obj/Vsim.exe'
    env = env_for(bdir)
    cmd = [VBIN, '--binary', '--timing', '-O1', '-Wno-fatal', '-Wno-lint', '-Wno-style', '--top-module', 'tb_sha_top',
           '--x-assign', '0', '--x-initial', xinit]
    cmd += ['-G%s=%s' % (k, v) for k, v in params.items()]
    if synth:
        cmd += ['+define+VLSIT_SYNTHESIS']
    if coverage:
        cmd += ['--coverage-line', '--coverage-toggle']
    if trace:
        cmd += ['--trace']
    cmd += ['-Mdir', bdir + '/obj', '-j', '4', '-CFLAGS', '-std=gnu++17', '-LDFLAGS', '-static-libstdc++ -static-libgcc',
            '-o', 'Vsim', TB + '/tb_sha_top.sv', TB + '/sha_checkers.sv'] + list(extra_files) + (rtl_override or rtl_files())
    r = subprocess.run(cmd, capture_output=True, text=True, env=env)
    open(bdir + '/build.log', 'w').write(r.stdout + r.stderr)
    if not os.path.exists(exe):
        print('COMPILE FAIL', name)
        print((r.stdout + r.stderr)[-3000:])
        return None
    return exe


def run(exe, name, vec, plus=(), logname=None, timeout=3000, cov_out=None):
    """Run one simulation. Returns (returncode, stdout)."""
    bdir = os.path.dirname(os.path.dirname(exe))
    env = env_for(bdir)
    args = [exe, '+VEC=' + vec.replace(chr(92), '/'), '+NAME=' + name] + list(plus)
    cwd = bdir
    r = subprocess.run(args, capture_output=True, text=True, env=env, cwd=cwd, timeout=timeout)
    out = r.stdout + r.stderr
    if logname:
        os.makedirs(os.path.dirname(logname), exist_ok=True)
        open(logname, 'w').write(out)
    if cov_out and os.path.exists(cwd + '/coverage.dat'):
        os.makedirs(os.path.dirname(cov_out), exist_ok=True)
        os.replace(cwd + '/coverage.dat', cov_out)
    return r.returncode, out


def summarize(out):
    m = re.search(r'TB-RESULT name=(\S+) scoreboard pass=(\d+) fail=(\d+) cycles=(\d+)', out)
    ok = 'TB PASS' in out
    a = re.search(r'assertion failures: (\d+), assertions never exercised: (\d+)', out)
    return dict(ok=ok, sbpass=int(m.group(2)) if m else -1, sbfail=int(m.group(3)) if m else -1,
                cycles=int(m.group(4)) if m else -1, afail=int(a.group(1)) if a else -1, anever=int(a.group(2)) if a else -1)
