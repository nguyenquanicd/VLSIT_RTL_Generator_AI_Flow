"""Waveform evidence of the specification plan (R-033, R-088 to R-091).
For each WF of wf_plan.json: run the scenario alone with +VCD, cut the window of the specification figure out of the
VCD (same clock, same slot grid, anchored on the event named in the plan), write WaveJSON and SVG with the figure's
stem, compare the 1-bit rows and the value-change positions of the bus rows with the figure, and write
waveforms_sim/waveform_compare.md.
Run: python wf_tool.py [WF-001 ...]
"""
import json
import os
import re
import subprocess
import shutil
import sys

import simlib as S
import vec_lib as V

VER = S.VER
FIG = os.path.dirname(VER) + '/figures'
EVD = VER + '/waveforms_sim'
SVGTOOL = 'C:/Users/PC/.claude/skills/vlsit-asic-ip-microspec/scripts/vlsit_waveform_svg.py'

# Names used in the specification figures that are conceptual (not a net of the RTL) or are named differently.
# 'or:' = OR of the listed leaf paths (dut-relative), 'ne0:' = any bit set, 'map:' = value mapping of an encoding.
ALIAS = {
    'w_core_start': ['or:u_seq.o_c256_start', 'u_seq.o_c512_start', 'u_seq.o_kec_start'],
    'w_core_busy': ['or:gen_c256.u_core256.reg_run', 'gen_c512.u_core512.reg_run', 'gen_kec.u_keccak.reg_run'],
    'w_core_ctx': ['u_seq.reg_be_ctx'],
    'r_ctx_state': ['w_sts_cstate'],
    'r_in_pop': ['u_seq.o_in_pop_en'],
    'w_in_full': ['ne0:u_axi_sub.i_in_full'],
    'w_ctxmem_wr': ['or:u_seq.o_wra_en', 'u_seq.o_wrb_en'],
    'w_ctxmem_rd': ['u_seq.o_rd0_ctx_en'],
    'w_keccak_busy': ['gen_kec.u_keccak.reg_run'],
    'w_rst_n_core_sync': ['w_rst_n_core'],
    'w_rst_n_apb_sync': ['w_rst_n_apb'],
    'w_squeeze_start': ['u_seq.o_kec_start'],
    'r_tmo_cnt': ['u_dma.reg_tmo_cnt'],
    'w_zero_active': ['u_seq.reg_swp_act'],
    'i_sha_lvl_inlvl': ['w_in_lvl'],
    'i_sha_lvl_outlvl': ['w_out_lvl'],
    'i_sha_sts_cstate': ['w_sts_cstate'],
    'i_sha_dvld_words': ['i_sha_dvld_words'],
    'w_core_a_out': ['gen_c256.u_core256.o_result'],
    'w_core_b_out': ['gen_c256_b.u_core256_b.o_result'],
    'w_mismatch': ['w_mismatch'],
    'r_mismatch': ['u_fault.reg_flt'],
    'w_digest_gate': ['w_gate'],
}


# ------------------------------------------------------------------------------------------------ VCD
class Vcd:
    def __init__(self, path):
        self.vars = {}          # full dut-relative path -> (id, width)
        self.chg = {}           # id -> [(t, value)]
        scope = []
        t = 0
        with open(path) as f:
            defs = True
            for line in f:
                line = line.strip()
                if defs:
                    if line.startswith('$scope'):
                        scope.append(line.split()[2])
                    elif line.startswith('$upscope'):
                        scope.pop()
                    elif line.startswith('$var'):
                        p = line.split()
                        i, nm, w = p[3], p[4], int(p[2])
                        full = '.'.join(scope)
                        if full == 'tb_sha_top.dut' or full.startswith('tb_sha_top.dut.'):
                            rel = (full[len('tb_sha_top.dut.'):] + '.' + nm) if len(full) > len('tb_sha_top.dut') else nm
                            self.vars.setdefault(rel, (i, w))
                            self.chg.setdefault(i, [])
                    elif line.startswith('$enddefinitions'):
                        defs = False
                    continue
                if not line:
                    continue
                if line[0] == '#':
                    t = int(line[1:])
                elif line[0] == 'b':
                    v, i = line[1:].split()
                    if i in self.chg:
                        self.chg[i].append((t, v))
                elif line[0] in '01xzXZ':
                    i = line[1:]
                    if i in self.chg:
                        self.chg[i].append((t, line[0]))

    def find(self, leaf):
        """dut-relative path of a leaf name: top level first, then the CSR block, then the shallowest."""
        if leaf in self.vars:
            return leaf
        if 'u_csr.' + leaf in self.vars:
            return 'u_csr.' + leaf
        c = sorted((p for p in self.vars if p.split('.')[-1] == leaf), key=lambda p: p.count('.'))
        return c[0] if c else None

    def series(self, path, edges):
        """Value of the signal in each cycle: the last change before the next rising edge."""
        i, w = self.vars[path]
        ch = self.chg[i]
        out = []
        k = 0
        cur = 'x'
        for n in range(len(edges) - 1):
            lim = edges[n + 1]
            while k < len(ch) and ch[k][0] < lim:
                cur = ch[k][1]
                k += 1
            out.append(cur)
        return out


def ival(v):
    if v is None or set(v) - set('01'):
        return None
    return int(v, 2)


def resolve(vcd, name, edges):
    """List of per-cycle integer values (None = unknown) for a figure row, or None when the figure signal is conceptual."""
    spec = ALIAS.get(name)
    if spec is None:
        p = vcd.find(name)
        if p is None:
            return None, None
        return [ival(x) for x in vcd.series(p, edges)], vcd.vars[p][1]
    mode = 'one'
    paths = []
    for e in spec:
        if e.startswith('or:'):
            mode = 'or'; e = e[3:]
        elif e.startswith('ne0:'):
            mode = 'ne0'; e = e[4:]
        p = e if e in vcd.vars else vcd.find(e.split('.')[-1] if '.' not in e else e)
        if p is None or p not in vcd.vars:
            return None, None
        paths.append(p)
    ser = [[ival(x) for x in vcd.series(p, edges)] for p in paths]
    n = len(ser[0])
    out = []
    for c in range(n):
        vals = [s[c] for s in ser]
        if mode == 'or':
            out.append(None if any(v is None for v in vals) else int(any(vals)))
        elif mode == 'ne0':
            out.append(None if any(v is None for v in vals) else int(any(vals)))
        else:
            out.append(vals[0])
    return out, vcd.vars[paths[0]][1]


def edges_of(vcd, clk):
    i = vcd.vars[clk][0]
    return [t for (t, v) in vcd.chg[i] if v == '1']


# ------------------------------------------------------------------------------------------------ figure
def fig_rows(d):
    rows = []
    def walk(sig, grp):
        for s in sig:
            if isinstance(s, list):
                walk(s[1:], s[0])
            elif isinstance(s, dict) and 'name' in s:
                rows.append((grp, s))
    walk(d['signal'], None)
    return rows


def expand_wave(w):
    """Per-slot state of a WaveJSON string: '0','1','x','=' (new bus value), 'k' (kept), 'z', 'p' (clock)."""
    out = []
    last = 'x'
    for ch in w:
        if ch == '.':
            out.append('k' if last in '=k' else last)
            if last == '=':
                last = 'k'
        else:
            out.append(ch)
            last = ch
    return out


def render_wave(vals, width, data_out):
    s = ''
    prev = 'unset'
    for v in vals:
        if width == 1:
            ch = 'x' if v is None else str(v)
            s += '.' if ch == prev else ch
            prev = ch
        else:
            if v is None:
                ch = 'x'
                s += '.' if prev == 'x' else 'x'
            else:
                if v == prev:
                    s += '.'
                else:
                    s += '='
                    data_out.append('%x' % v)
            prev = v if v is not None else 'x'
    return s


def run_wf(wf, d, plan, builds):
    stem = d['stem']
    cfgname = d['cfg']
    exe = builds.get(cfgname)
    if exe is None:
        params = {k: str(v) for k, v in plan['cfg'][cfgname].items()}
        exe = S.build('wf_' + cfgname, params, coverage=False, trace=True)
        builds[cfgname] = exe
    vcd = '%s/%s.vcd' % (EVD, stem)
    os.makedirs(EVD, exist_ok=True)
    rc, out = S.run(exe, wf, VER + '/vec/%s.vec' % stem, ['+CLASSES=0', '+VCD=' + vcd], logname=VER + '/logs/%s.log' % stem)
    return vcd, rc, out


def analyse(wf, d, vcdpath):
    fig = json.load(open('%s/%s.json' % (FIG, d['stem'])))
    rows = fig_rows(fig)
    vcd = Vcd(vcdpath)
    clk = d['clock']
    edges = edges_of(vcd, clk)
    nslot = max(len(s['wave']) for g, s in rows)
    # anchor
    a = d['anchor']
    ser, w = resolve(vcd, a['sig'], edges)
    if ser is None:
        return dict(result='DIFFERENT', note='anchor signal %s not found in the RTL' % a['sig'], rows=[], notes=[])
    hits = []
    for c in range(1, len(ser)):
        if ser[c] is None or ser[c - 1] is None:
            continue
        if a['edge'] == 'rise' and ser[c - 1] == 0 and ser[c] == 1:
            hits.append(c)
        if a['edge'] == 'fall' and ser[c - 1] == 1 and ser[c] == 0:
            hits.append(c)
    if len(hits) < a['n']:
        return dict(result='DIFFERENT', note='anchor event %s %s #%d does not occur' % (a['sig'], a['edge'], a['n']), rows=[], notes=[])
    c0 = hits[a['n'] - 1] - a['slot']
    ncyc = len(edges) - 1
    sim_rows = []
    mism = []
    unresolved = []
    compared = 0
    for grp, s in rows:
        name = s['name']
        wave = s['wave']
        if 'p' in wave and set(wave) <= set('p.'):
            sim_rows.append((grp, name, None, None, 'clock'))
            continue
        if name.startswith('i_clk') or wave.startswith(('1.0', '0.1')) and name.endswith('clk_apb'):
            sim_rows.append((grp, name, None, None, 'clock'))
            continue
        ser, width = resolve(vcd, name, edges)
        if ser is None:
            unresolved.append(name)
            sim_rows.append((grp, name, None, None, 'conceptual'))
            continue
        vals = [ser[c0 + k] if 0 <= c0 + k < ncyc else None for k in range(len(wave))]
        sim_rows.append((grp, name, vals, width, 'sim'))
        fx = expand_wave(wave)
        compared += 1
        for k, st in enumerate(fx):
            v = vals[k]
            if width == 1 or st in '01':
                if st in '01' and v is not None and v != int(st):
                    mism.append('%s slot %d: figure %s, simulation %s' % (name, k, st, v))
                elif st in '01' and v is None:
                    mism.append('%s slot %d: figure %s, simulation unknown' % (name, k, st))
            else:
                prev = vals[k - 1] if k > 0 else None
                if st == '=':
                    if k > 0 and v is not None and prev is not None and v == prev:
                        mism.append('%s slot %d: figure shows a new value, simulation unchanged' % (name, k))
                elif st == 'k':
                    if k > 0 and v is not None and prev is not None and v != prev:
                        mism.append('%s slot %d: figure holds the value, simulation changes' % (name, k))
    # render simulated WaveJSON with the same grouping
    out = {'signal': [], 'head': {'text': 'Simulation of %s (window of the figure, slot grid of the specification)' % wf}}
    idx = 0
    def build(sig):
        nonlocal idx
        res = []
        for s in sig:
            if isinstance(s, list):
                res.append([s[0]] + build(s[1:]))
            elif isinstance(s, dict) and 'name' in s:
                grp, name, vals, width, kind = sim_rows[idx]
                idx += 1
                if kind == 'clock':
                    res.append({'name': name, 'wave': s['wave']})
                elif kind == 'conceptual':
                    res.append({'name': name + ' (no RTL net)', 'wave': 'x' * len(s['wave'])})
                else:
                    data = []
                    res.append({'name': name, 'wave': render_wave(vals, width, data), **({'data': data} if data else {})})
        return res
    out['signal'] = build(fig['signal'])
    if 'config' in fig:
        out['config'] = fig['config']
    res = 'MATCH' if not mism else 'DIFFERENT'
    return dict(result=res, mism=mism, unresolved=unresolved, compared=compared, wavejson=out, c0=c0)


def main():
    plan = json.load(open(VER + '/wf_plan.json'))
    names = sys.argv[1:] or sorted(plan['plan'])
    builds = {}
    index = []
    for wf in sorted(set(plan['plan']) | set(plan['not_simulated'])):
        if wf in plan['not_simulated']:
            stem, why = plan['not_simulated'][wf]
            index.append((wf, stem, 'NOT-SIMULATED', why))
            continue
        if wf not in names:
            continue
        d = plan['plan'][wf]
        vcdp, rc, out = run_wf(wf, d, plan, builds)
        if not os.path.exists(vcdp):
            index.append((wf, d['stem'], 'NOT-SIMULATED', 'run failed: ' + out[-200:].replace('\n', ' ')))
            continue
        r = analyse(wf, d, vcdp)
        if 'wavejson' in r:
            jp = '%s/%s.json' % (EVD, d['stem'])
            json.dump(r['wavejson'], open(jp, 'w'), indent=1)
            subprocess.run([sys.executable, '-I', SVGTOOL, 'render', jp, '--out', '%s/%s.svg' % (EVD, d['stem']), '--force'],
                           capture_output=True, text=True)
            note = 'compared %d rows; ' % r['compared']
            if r['mism']:
                note += '%d slot differences, first: %s; ' % (len(r['mism']), '; '.join(r['mism'][:3]))
            if r['unresolved']:
                note += 'figure signals with no RTL net: ' + ', '.join(r['unresolved'])
            index.append((wf, d['stem'], r['result'], note.strip()))
            json.dump(r['mism'], open('%s/%s_diff.json' % (EVD, d['stem']), 'w'), indent=1)
        else:
            index.append((wf, d['stem'], r['result'], r['note']))
        # keep the folder small: remove the simulator build of the last config only at the end
    lines = ['# Waveform comparison: simulation against the figures of section 10.3', '',
             'Window of each figure: same clock, same slot grid, anchored on the event named in `wf_plan.json`. '
             'A row is compared slot by slot when its signal is a net of the RTL (or the alias of `scripts/wf_tool.py`); '
             'signals the figure names that are not a net of the RTL are listed and not compared. Bus rows are compared by the slot '
             'in which the value changes, not by the value.', '',
             '| Waveform ID | Specification figure | Simulated waveform | Result | Note |', '|---|---|---|---|---|']
    for wf, stem, res, note in index:
        sim = 'waveforms_sim/%s.svg' % stem if res != 'NOT-SIMULATED' else '-'
        lines.append('| %s | waveforms/%s.svg | %s | %s | %s |' % (wf, stem, sim, res, note.replace('|', '/')))
    if names == sorted(plan['plan']) or not sys.argv[1:]:
        open(EVD + '/waveform_compare.md', 'w', encoding='utf-8').write('\n'.join(lines) + '\n')
    print('\n'.join(lines))
    for b in builds.values():
        pass
    for cfg in builds:
        shutil.rmtree(os.path.join(S.WORK, 'wf_' + cfg), ignore_errors=True)


if __name__ == '__main__':
    main()
