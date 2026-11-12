"""TEST-002 (each algorithm alone builds only its core) and TEST-015 (every illegal combination of section 8 stops the
elaboration with an error that names a non-existent module m_vlsit_sha_ERR_<cause>). Uses verilator --lint-only / --xml-only.
Run: python elab_tests.py     Results: reports/elab_results.md
"""
import os
import re
import subprocess
import sys

import simlib as S
import vec_lib as V

REP = S.VER + '/reports'
BASE = dict(PARA_EN_SHA256=1)


def verilator(params, xml=None):
    bdir = S.WORK + '/elab'
    os.makedirs(bdir, exist_ok=True)
    env = S.env_for(bdir)
    cmd = [S.VBIN, '--lint-only', '-Wno-fatal', '-Wno-lint', '-Wno-style', '--top-module', 'm_vlsit_sha_top']
    cmd += ['-G%s=%s' % (k, v) for k, v in params.items()]
    if xml:
        cmd = [S.VBIN, '--json-only', '--json-only-output', xml, '-Wno-fatal', '-Wno-lint', '-Wno-style', '--top-module', 'm_vlsit_sha_top',
               '-Mdir', bdir + '/xml'] + ['-G%s=%s' % (k, v) for k, v in params.items()]
    cmd += S.rtl_files()
    r = subprocess.run(cmd, capture_output=True, text=True, env=env, cwd=S.RTL)
    return r.returncode, r.stdout + r.stderr


ALGS = ['SHA224', 'SHA256', 'SHA384', 'SHA512', 'SHA512_224', 'SHA512_256', 'SHA3_224', 'SHA3_256', 'SHA3_384', 'SHA3_512', 'SHAKE128', 'SHAKE256']

# illegal combinations of section 8 (REQ-PARAM-001): overrides and the cause named by the error module
ILLEGAL = [
    ('all PARA_EN_* = 0', dict(PARA_EN_SHA256=0), 'no_algorithm_built'),
    ('PARA_S256_UNR = 3 (not a divisor of 64)', dict(PARA_S256_UNR=3), 's256_unr_not_divisor'),
    ('PARA_S512_UNR = 3 (not a divisor of 80)', dict(PARA_EN_SHA512=1, PARA_S512_UNR=3), 's512_unr_not_divisor'),
    ('PARA_KEC_UNR = 5 (not a divisor of 24)', dict(PARA_EN_SHA3_256=1, PARA_KEC_UNR=5), 'kec_unr_not_divisor'),
    ('PARA_S256_PIPE = 2 (only 1 in this revision)', dict(PARA_S256_PIPE=2), 'pipe_stage_unsupported'),
    ('PARA_S256_PIPE = 0', dict(PARA_S256_PIPE=0), 'pipe_stage_unsupported'),
    ('PARA_CTX_N = 0', dict(PARA_CTX_N=0), 'ctx_n_out_of_range'),
    ('PARA_CTX_N = 17', dict(PARA_CTX_N=17), 'ctx_n_out_of_range'),
    ('PARA_AXI_DW = 48', dict(PARA_AXI_DW=48), 'axi_dw_value'),
    ('PARA_AXI_DW = 128 with SHA3-256 (rate 136 B)', dict(PARA_AXI_DW=128, PARA_EN_SHA3_256=1), 'axi_dw_128_block_size'),
    ('PARA_AXI_AW = 8', dict(PARA_AXI_AW=8), 'axi_aw_below_16'),
    ('PARA_IN_DEPTH = 6 (not a power of 2)', dict(PARA_IN_DEPTH=6), 'in_depth'),
    ('PARA_IN_DEPTH = 8 with 32-bit bus (32 B < 64 B + 2 words)', dict(PARA_IN_DEPTH=8, PARA_AXI_DW=32), 'in_depth'),
    ('PARA_OUT_DEPTH = 4 with 32-bit bus (16 B < 64 B)', dict(PARA_OUT_DEPTH=4, PARA_AXI_DW=32), 'out_depth'),
    ('PARA_CTX_MEM = 1 (reserved, DEC-016)', dict(PARA_CTX_MEM=1), 'ctx_mem_unsupported'),
    ('PARA_MASK = 2 (legal values 0 and 1)', dict(PARA_EN_SHA3_256=1, PARA_MASK=2, PARA_KEC_PIPE=2), 'mask_value'),
    ('PARA_SEED_SRC = 2 (legal values 0 and 1)', dict(PARA_EN_SHA3_256=1, PARA_MASK=1, PARA_KEC_PIPE=2, PARA_SEED_SRC=2), 'mask_value'),
    ('PARA_SEED_SRC = 1 without PARA_MASK', dict(PARA_EN_SHA3_256=1, PARA_SEED_SRC=1), 'mask_value'),
    ('PARA_MASK = 1 without a Keccak algorithm', dict(PARA_MASK=1, PARA_KEC_PIPE=2), 'mask_needs_keccak_unr1'),
    ('PARA_MASK = 1 with PARA_KEC_UNR = 2', dict(PARA_EN_SHA3_256=1, PARA_MASK=1, PARA_KEC_PIPE=2, PARA_KEC_UNR=2), 'mask_needs_keccak_unr1'),
    ('PARA_MASK = 1 with PARA_KEC_PIPE = 1', dict(PARA_EN_SHA3_256=1, PARA_MASK=1, PARA_KEC_PIPE=1), 'pipe_stage_unsupported'),
    ('PARA_KEC_PIPE = 2 without masking', dict(PARA_EN_SHA3_256=1, PARA_KEC_PIPE=2), 'pipe_stage_unsupported'),
    ('PARA_FAULT_DUP = 2 (legal values 0 and 1)', dict(PARA_FAULT_DUP=2), 'fault_value'),
    ('PARA_ALARM = 2 (legal values 0 and 1)', dict(PARA_ALARM=2, PARA_FAULT_PAR=1), 'fault_value'),
    ('PARA_ALARM = 1 without a fault parameter', dict(PARA_ALARM=1), 'alarm_needs_fault'),
]


def main():
    os.makedirs(REP, exist_ok=True)
    lines = ['# Elaboration tests', '', 'Tool: verilator --lint-only (OSS CAD Suite). TEST-002 and TEST-015 of the specification.', '',
             '## TEST-002: each algorithm alone, only its core is built', '',
             '| Algorithm | Elaborates | core256 | core512 | keccak | Result |', '|---|---|---|---|---|---|']
    bad = 0
    for a in ALGS:
        p = {('PARA_EN_' + x): (1 if x == a else 0) for x in ALGS}
        xml = S.WORK + '/elab/%s.xml' % a
        os.makedirs(S.WORK + '/elab', exist_ok=True)
        rc, out = verilator(p, xml)
        ok = (rc == 0) and os.path.exists(xml)
        txt = open(xml).read() if ok else ''
        has = {k: (k in txt) for k in ('u_core256', 'u_core512', 'u_keccak')}
        want = dict(u_core256=a in ('SHA224', 'SHA256'), u_core512=a in ('SHA384', 'SHA512', 'SHA512_224', 'SHA512_256'),
                    u_keccak=a.startswith('SHA3_') or a.startswith('SHAKE'))
        good = ok and has == want
        bad += 0 if good else 1
        lines.append('| %s | %s | %s | %s | %s | %s |' % (a, 'yes' if ok else 'NO', has['u_core256'], has['u_core512'], has['u_keccak'], 'PASS' if good else 'FAIL'))
    lines += ['', '## TEST-015: illegal combinations stop the elaboration', '',
              '| Combination | Elaboration | Error names | Result |', '|---|---|---|---|']
    for name, p, cause in ILLEGAL:
        q = dict(BASE)
        q.update(p)
        rc, out = verilator(q)
        named = 'm_vlsit_sha_ERR_%s' % cause
        stopped = rc != 0
        good = stopped and named in out
        bad += 0 if good else 1
        lines.append('| %s | %s | `%s` %s | %s |' % (name, 'stopped' if stopped else 'NOT STOPPED', named,
                                                    'found' if named in out else 'not in the message', 'PASS' if good else 'FAIL'))
    # a legal configuration must elaborate
    lines += ['', '## Legal reference configurations elaborate', '', '| Configuration | Result |', '|---|---|']
    for name, p in (('CFG-BASE (defaults)', {}),
                    ('CFG-BOOT', dict(PARA_EN_SHA224=1, PARA_EN_SHA256=1, PARA_EN_SHA384=1, PARA_EN_SHA512=1, PARA_S256_UNR=2, PARA_S512_UNR=2, PARA_DMA=1)),
                    ('64-bit, 4 contexts, all algorithms', {('PARA_EN_' + x): 1 for x in ALGS} | dict(PARA_CTX_N=4)),
                    ('128-bit, SHA-2 and SHA3-224', dict(PARA_AXI_DW=128, PARA_EN_SHA384=1, PARA_EN_SHA3_224=1)),
                    ('stage 2a: all fault detections and the alarm, one algorithm', dict(PARA_FAULT_DUP=1, PARA_FAULT_PAR=1, PARA_FAULT_REDO=1, PARA_ALARM=1)),
                    ('stage 2a: all fault detections, alarm, all algorithms, 4 contexts', {('PARA_EN_' + x): 1 for x in ALGS} | dict(PARA_CTX_N=4, PARA_FAULT_DUP=1, PARA_FAULT_PAR=1, PARA_FAULT_REDO=1, PARA_ALARM=1)),
                    ('stage 2a: parity only, 128-bit', dict(PARA_AXI_DW=128, PARA_FAULT_PAR=1)),
                    ('stage 2b: masked Keccak, seed registers', dict(PARA_EN_SHA3_256=1, PARA_MASK=1, PARA_KEC_PIPE=2, PARA_SEED_SRC=1)),
                    ('stage 2b: masked Keccak, entropy port, all faults', dict(PARA_EN_SHA3_256=1, PARA_MASK=1, PARA_KEC_PIPE=2, PARA_FAULT_DUP=1, PARA_FAULT_PAR=1, PARA_FAULT_REDO=1)),
                    ('stage 2b: all algorithms, 16 contexts, masked, seed registers', {('PARA_EN_' + x): 1 for x in ALGS} | dict(PARA_CTX_N=16, PARA_MASK=1, PARA_KEC_PIPE=2, PARA_SEED_SRC=1))):
        rc, out = verilator(p)
        good = rc == 0
        bad += 0 if good else 1
        lines.append('| %s | %s |' % (name, 'PASS' if good else 'FAIL: ' + out[-200:].replace('\n', ' ')))
    open(REP + '/elab_results.md', 'w').write('\n'.join(lines) + '\n')
    print('\n'.join(lines))
    print('ELAB RESULT:', 'PASS' if bad == 0 else 'FAIL (%d)' % bad)
    return bad


if __name__ == '__main__':
    sys.exit(1 if main() else 0)
