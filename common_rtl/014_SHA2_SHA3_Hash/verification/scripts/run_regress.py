"""Regression runner of the SHA2/SHA3 testbench.
Usage: python run_regress.py [suite ...]     (no argument: every default suite)
Suites are listed in SUITES. For each suite the testbench is built once for its configuration and the
vector files are run by one simulator invocation (the suite script uses the `include` command), so
the assertion table of the log is the table of the whole suite (R-025). Logs go to logs/, coverage
data to coverage/data/, a summary table to reports/regress_summary.md.
"""
import json
import os
import re
import shutil
import sys
import time

import simlib as S
import vec_lib as V

VER = S.VER
VEC = VER + '/vec'
LOGS = VER + '/logs'
COVD = VER + '/coverage/data'
REP = VER + '/reports'
ALL = V.ALL_ALGS
SHA2 = [0, 1, 2, 3, 4, 5]

CL_DEFAULT = 0x0F7          # classes 0-2, 4-7 (+3): everything except class 8 (open findings) ; DMA class 5 included only where DMA = 1
CL_NO_DMA = 0x0DF           # without class 5 (DMA)
CL_DMA = 0x0FF & ~0x100


def vf(*names):
    return [VEC + '/' + n for n in names]


def suite_cfg(dw, algs, ctxn=4, **kw):
    p = dict(DW=dw, CTXN=ctxn, ALG="12'h%03x" % V.algmask(algs))
    p.update({k: str(v) for k, v in kw.items()})
    return p


SUITES = {
    # name: (build params, files, classes, extra plusargs, synthesis branch)
    'main64': (suite_cfg(64, ALL), vf('nist_all_dw64.vec', 'edge_all_dw64.vec', 'bp_on.vec', 'rand_all_dw64.vec', 'bp_off.vec',
                                      'multi_all_dw64.vec', 'dir_apb_dw64.vec', 'dir_err_dw64.vec', 'dir_irq_dw64.vec',
                                      'dir_abort_dw64.vec', 'dir_tail_dw64.vec', 'dir_bp_dw64.vec'), CL_NO_DMA, [], False),
    'main32': (suite_cfg(32, ALL), vf('nist_all_dw32.vec', 'edge_all_dw32.vec', 'bp_on.vec', 'rand_all_dw32.vec', 'bp_off.vec',
                                      'multi_all_dw32.vec', 'dir_apb_dw32.vec', 'dir_err_dw32.vec', 'dir_irq_dw32.vec',
                                      'dir_abort_dw32.vec', 'dir_tail_dw32.vec', 'dir_bp_dw32.vec'), CL_NO_DMA, [], False),
    'main128': (suite_cfg(128, [0, 1, 2, 3, 4, 5, 8]),
                vf('nist_w128_dw128.vec', 'edge_w128_dw128.vec', 'bp_on.vec', 'rand_w128_dw128.vec', 'bp_off.vec',
                   'multi_w128_dw128.vec', 'dir_apb_dw128.vec', 'dir_err_dw128.vec', 'dir_irq_dw128.vec',
                   'dir_abort_dw128.vec', 'dir_tail_dw128.vec', 'dir_bp_dw128.vec'), CL_NO_DMA, [], False),
}


# ---- additional suites -----------------------------------------------------------------------------------------
MAIN64_FILES = vf('nist_all_dw64.vec', 'edge_all_dw64.vec', 'bp_on.vec', 'rand_all_dw64.vec', 'bp_off.vec', 'multi_all_dw64.vec',
                  'dir_apb_dw64.vec', 'dir_err_dw64.vec', 'dir_irq_dw64.vec', 'dir_abort_dw64.vec', 'dir_tail_dw64.vec', 'dir_bp_dw64.vec')
CL_ALL_NO_OPEN = 0x0FF
SUITES['dma64'] = (suite_cfg(64, ALL, DMA=1), vf('edge_all_dw64.vec', 'dir_apb_dw64.vec', 'dir_err_dw64.vec', 'dir_irq_dw64.vec',
                                                'dir_abort_dw64.vec', 'bp_on.vec', 'dir_bp_dw64.vec', 'bp_off.vec', 'dir_dma_dw64.vec'),
                   CL_ALL_NO_OPEN, [], False)
SUITES['strict4ph_dma64'] = (suite_cfg(64, ALL, DMA=1), vf('open_dma_dw64.vec'), 0x1FF, [], False)
SUITES['fault_dup64'] = (suite_cfg(64, ALL, FDUP=1, ALARM=1), vf('fault_dup_dw64.vec'), 0x280, [], False)
SUITES['fault_par64'] = (suite_cfg(64, ALL, FPAR=1, ALARM=1), vf('fault_par_dw64.vec'), 0x280, [], False)
SUITES['fault_redo64'] = (suite_cfg(64, ALL, FREDO=1, ALARM=1), vf('fault_redo_dw64.vec'), 0x280, [], False)
SUITES['fault_all64'] = (suite_cfg(64, ALL, FDUP=1, FPAR=1, FREDO=1, ALARM=1), vf('fault_all_dw64.vec'), 0x280, [], False)
SUITES['dma32'] = (suite_cfg(32, ALL, DMA=1), vf('dir_dma_dw32.vec'), 0x20, [], False)
SUITES['dma128'] = (suite_cfg(128, [0, 1, 2, 3, 4, 5, 8], DMA=1), vf('dir_dma_dw128.vec'), 0x20, [], False)
# CDC / clock ratios (TEST-013): APB half period in ns, core half period 5 ns
ASYNC_RATIOS = {'r1_1': '5.0', 'r1_3': '15.0', 'r7_2': '17.5', 'r2_7': '1.43'}
ASYNC_FILES = vf('edge_all_dw64.vec', 'bp_on.vec', 'rand_all_dw64.vec', 'bp_off.vec', 'multi_all_dw64.vec', 'dir_apb_dw64.vec',
                 'dir_err_dw64.vec', 'dir_irq_dw64.vec', 'dir_abort_dw64.vec', 'dir_bp_dw64.vec')
for _r, _h in ASYNC_RATIOS.items():
    SUITES['async_%s_synth' % _r] = (suite_cfg(64, ALL, ASYNC=1, APBH=_h), ASYNC_FILES, CL_NO_DMA, [], True)
    for _s in (1, 2, 3):
        SUITES['async_%s_seed%d' % (_r, _s)] = (suite_cfg(64, ALL, ASYNC=1, APBH=_h), ASYNC_FILES, CL_NO_DMA, ['+AFIFO_MSYNC_SEED=%d' % _s], False)
# performance (TEST-018)
for _u in (1, 2, 4):
    SUITES['perf_u%d' % _u] = (suite_cfg(64, [1, 3, 9, 11], 1, U256=_u, U512=_u, UKEC=_u), vf('perf_dw64.vec'), 0x00, [], False)
for _n in (1, 2, 16):
    SUITES['dirctx%d' % _n] = (suite_cfg(64, ALL, _n), vf('edge_all_dw64.vec', 'bp_on.vec', 'rand_all_dw64.vec', 'bp_off.vec', *(['dir_%s_c%d_dw64.vec' % (k, _n) for k in ('apb', 'err', 'irq', 'abort')] + ['dir_tail_dw64.vec', 'dir_bp_c%d_dw64.vec' % _n])), CL_NO_DMA, [], False)
for _n in (1, 2, 8, 16):
    SUITES['ctx%d' % _n] = (suite_cfg(64, ALL, _n), vf('edge_all_dw64.vec', 'bp_on.vec') + (vf('multi_c%d_dw64.vec' % _n) if _n > 1 else []), 0x00, [], False)
SUITES['limit64'] = (suite_cfg(64, ALL, 2), vf('dir_limit_dw64.vec'), 0x00, [], False)
SUITES['perf_mask'] = (suite_cfg(64, [9, 11], 1, MASK=1), vf('perf_mask_dw64.vec'), 0x00, [], False)
SUITES['perf_redo'] = (suite_cfg(64, [1, 3, 9, 11], 1, FREDO=1), vf('perf_redo_dw64.vec'), 0x00, [], False)
SUITES['boot'] = (suite_cfg(64, [0, 1, 2, 3], 1, U256=2, U512=2, DMA=1), vf('boot_sha256_dw64.vec', 'boot_sha384_dw64.vec'), 0x00, [], False)
# masked Keccak core (TEST-021, stage 2b): class 10 = masking assertions, class 7 = reset
CL_MASK = 0x480
SUITES['mask_reg64'] = (suite_cfg(64, ALL, 2, MASK=1), vf('mask_reg_dw64.vec', 'mask_err_dw64.vec'), CL_MASK, [], False)
SUITES['mask_reg32'] = (suite_cfg(32, ALL, 2, MASK=1), vf('mask_reg_dw32.vec', 'mask_err_dw32.vec'), CL_MASK, [], False)
SUITES['mask_ent64'] = (suite_cfg(64, ALL, 2, MASK=1, SEEDSRC=0), vf('mask_ent_dw64.vec'), 0x080, [], False)
SUITES['mask_stat64'] = (suite_cfg(64, ALL, 2, MASK=1), vf('mask_stat_dw64.vec'), 0x080, [], False)
SUITES['mask_statctl64'] = (suite_cfg(64, ALL, 2, MASK=1), vf('mask_statctl_dw64.vec'), 0x080, [], False)
SUITES['mask_fault64'] = (suite_cfg(64, ALL, 2, MASK=1, FDUP=1, FPAR=1, FREDO=1, ALARM=1), vf('mask_fault_dw64.vec'), 0x280, [], False)
# the whole functional set on a PARA_MASK = 1 build (messages without masking use the same core with zero random bits)
SUITES['main64_mask'] = (suite_cfg(64, ALL, MASK=1), MAIN64_FILES, CL_NO_DMA & ~0x0, [], False)


def write_suite(name, files):
    path = VEC + '/suite_%s.vec' % name
    with open(path, 'w', newline='\n') as f:
        for x in files:
            f.write('include %s\n' % os.path.basename(x))
        f.write('end\n')
    return path


def parse_asserts(out):
    res = {}
    for m in re.finditer(r'ASSERT (\d+)\s+hits=(\d+)\s+fails=(\d+)\s+(.*?)(?:\s+NEVER-EXERCISED)?$', out, re.M):
        res[int(m.group(1))] = (int(m.group(2)), int(m.group(3)), m.group(4).strip())
    return res


def run_suite(name, keep=False):
    params, files, cls, plus, synth = SUITES[name]
    os.makedirs(LOGS, exist_ok=True)
    os.makedirs(COVD, exist_ok=True)
    sfile = write_suite(name, files)
    t = time.time()
    exe = S.build('s_' + name, params, synth=synth, coverage=True, trace=False)
    if not exe:
        return dict(name=name, ok=False, note='compile failed')
    tb = time.time() - t
    t = time.time()
    rc, out = S.run(exe, name, sfile, ['+CLASSES=%x' % cls, '+VECDIR=' + VEC.replace(chr(92), '/')] + plus, logname=LOGS + '/%s.log' % name,
                    cov_out=COVD + '/%s.dat' % name, timeout=3000)
    r = S.summarize(out)
    if name.startswith('async_'):
        os.makedirs(LOGS + '/cdc', exist_ok=True)
        shutil.copy(LOGS + '/%s.log' % name, LOGS + '/cdc/%s.log' % name)
    r.update(name=name, rc=rc, build_s=round(tb), run_s=round(time.time() - t))
    if not keep:
        shutil.rmtree(os.path.join(S.WORK, 's_' + name), ignore_errors=True)
    return r


if __name__ == '__main__':
    os.makedirs(VEC, exist_ok=True)
    open(VEC + '/bp_on.vec', 'w').write('bp 1\n')
    open(VEC + '/bp_off.vec', 'w').write('bp 0\n')
    names = sys.argv[1:] or [n for n in SUITES if n != 'strict4ph_dma64']
    if names == ['all_async']:
        names = [n for n in SUITES if n.startswith('async_')]
    rows = []
    for n in names:
        r = run_suite(n, keep=bool(os.environ.get('KEEP')))
        print(n, r)
        rows.append(r)
