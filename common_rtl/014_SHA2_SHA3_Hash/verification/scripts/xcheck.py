"""X policy of 15.3 (TEST-025): "no X on any output after reset; resetless memories are read only after a write".
Verilator is two-state, so a four-state X is not available. Substitute: the same vectors run with all registers and memories set to
zero at power-up and with random power-up values (`--x-initial unique`, three seeds). The hash of the outputs (OUTHASH of the
testbench, outputs counted only while they are meaningful) and the scoreboard shall be identical in all four runs: no output depends on a
register or memory word that was never written or reset. This does NOT find X pessimism or optimism of a four-state simulator.
Run: python xcheck.py    Writes reports/xcheck.md; exit 1 on a difference.
"""
import os
import re
import sys

import simlib as S
import vec_lib as V

# no random back pressure (it uses $urandom, which follows the seed): the runs shall differ only in the power-up state
FILES = ['edge_all_dw64.vec', 'dir_apb_dw64.vec', 'dir_err_dw64.vec', 'dir_irq_dw64.vec', 'dir_abort_dw64.vec', 'dir_tail_dw64.vec']


def main():
    sf = V.VER + '/vec/suite_xcheck.vec'
    with open(sf, 'w', newline='\n') as f:
        f.write(''.join('include %s\n' % x for x in FILES) + 'end\n')
    params = dict(DW=64, CTXN=4, ALG="12'h%03x" % V.algmask(V.ALL_ALGS), FDUP=1, FPAR=1, FREDO=1, ALARM=1)
    rows = ['# X check by random power-up state (TEST-025, 15.3)', '', open(__file__).read().split('"""')[1].strip().replace('\n', ' '), '',
            '| Run | Power-up | Scoreboard pass/fail | Output hash core | Output hash apb |', '|---|---|---|---|---|']
    res = []
    for tag, xinit, plus in (('zero', '0', []), ('unique seed 1', 'unique', ['+verilator+rand+reset+2', '+verilator+seed+1']),
                             ('unique seed 2', 'unique', ['+verilator+rand+reset+2', '+verilator+seed+2']),
                             ('unique seed 3', 'unique', ['+verilator+rand+reset+2', '+verilator+seed+3'])):
        exe = S.build('xchk_' + xinit, params, coverage=False, trace=False, xinit=xinit) if tag in ('zero', 'unique seed 1') else exe
        rc, out = S.run(exe, 'xchk', sf, ['+CLASSES=0', '+VECDIR=' + (V.VER + '/vec').replace(chr(92), '/')] + plus, logname=V.VER + '/logs/xcheck_%s.log' % tag.replace(' ', '_'))
        s = S.summarize(out)
        m = re.search(r'OUTHASH core=(\w+) apb=(\w+)', out)
        h = (m.group(1), m.group(2)) if m else ('missing', 'missing')
        res.append((s['sbpass'], s['sbfail'], h))
        rows.append('| %s | %s | %d / %d | %s | %s |' % (tag, xinit, s['sbpass'], s['sbfail'], h[0], h[1]))
    # control: a mutant whose SLVERR read data comes from the resetless FIFO memory must make the hashes differ (the check can see it)
    import shutil
    d = V.VER + '/work/xmut'
    shutil.rmtree(d, ignore_errors=True)
    shutil.copytree(S.RTL, d + '/rtl')
    p = d + '/rtl/m_vlsit_sha_axi_sub.sv'
    t = open(p, encoding='utf-8').read()
    old = "      default: o_axi_rdata = '0;"
    assert old in t
    open(p, 'w', encoding='utf-8', newline=chr(10)).write(t.replace(old, "      default: o_axi_rdata = i_out_pop_data;", 1))
    rtlroot = S.RTL.replace(chr(92), '/')
    files = [x.replace(rtlroot, d.replace(chr(92), '/') + '/rtl') if x.startswith(rtlroot) else x for x in S.rtl_files()]
    hs = []
    rows += ['', '| Control run (mutant: error read data from the FIFO memory) | Power-up | Output hash core |', '|---|---|---|']
    for xi, plus in (('0', []), ('unique', ['+verilator+rand+reset+2', '+verilator+seed+2'])):
        e2 = S.build('xmut_' + xi, params, coverage=False, trace=False, xinit=xi, rtl_override=files)
        rc, out = S.run(e2, 'xmut', sf, ['+CLASSES=0', '+VECDIR=' + (V.VER + '/vec').replace(chr(92), '/')] + plus)
        m = re.search(r'OUTHASH core=(\w+) apb=(\w+)', out)
        hs.append(m.group(1) if m else 'missing')
        rows.append('| mutant | %s | %s |' % (xi, hs[-1]))
        shutil.rmtree(S.WORK + '/xmut_' + xi, ignore_errors=True)
    shutil.rmtree(d, ignore_errors=True)
    ctl = hs[0] != hs[1]
    rows.append('Control: %s' % ('the hashes differ, the check sees the dependence' if ctl else 'the hashes are equal: the check did NOT see the planted dependence'))
    same = ctl and all(r == res[0] for r in res) and res[0][2][0] != 'missing' and res[0][1] == 0
    rows += ['', 'Result: %s' % ('PASS: the four runs agree' if same else 'FAIL: the runs differ')]
    open(V.VER + '/reports/xcheck.md', 'w').write('\n'.join(rows) + '\n')
    print('\n'.join(rows))
    return 0 if same else 1


if __name__ == '__main__':
    sys.exit(main())
