"""Run the verification of the AXI2TLUL bridge (iverilog; works on Windows and Linux).

  python vlsit_run_sim.py regress   [--seeds 1,2,3]   regression of the configurations of section 4 of the specification
  python vlsit_run_sim.py scenarios                    one simulation per waveform of the plan (section 10.3), VCD, WaveJSON,
                                                       SVG and the comparison with the specification figure
  python vlsit_run_sim.py mutants                      injected bugs on a copy of the RTL: the testbench has to fail
  python vlsit_run_sim.py all

Needs iverilog and vvp on PATH (or the OSS CAD Suite folder, see SUITE below). Logs go to logs/, waveform evidence to
waveforms_sim/. The exit status is non-zero when a run fails.
"""
import argparse, bisect, concurrent.futures, glob, json, os, re, shutil, subprocess, sys, tempfile, zlib

HERE = os.path.dirname(os.path.abspath(__file__))
IP = os.path.abspath(os.path.join(HERE, '..'))
COMMON = os.path.abspath(os.path.join(IP, '..', '000_Common'))
LOGS = os.path.join(HERE, 'logs')
WSIM = os.path.join(HERE, 'waveforms_sim')
SPEC_FIG = os.path.join(IP, 'figures')
SUITE = os.environ.get('OSS_CAD_SUITE', r'C:\Tools\oss-cad-suite')
SVG_TOOL = os.path.join(os.path.expanduser('~'), '.claude', 'skills', 'vlsit-asic-ip-microspec', 'scripts', 'vlsit_waveform_svg.py')

# configurations of the specification (section 4): name, parameter overrides of the testbench
CONFIGS = [
    ('base', {}),
    ('wide', {'DW': 256, 'AW': 40, 'IDW': 4, 'NRD': 32}),
    ('macro', {'DW': 64, 'NRD': 64, 'MACRO': 1}),
    ('min', {'IDW': 1, 'SRCW': 3, 'NRD': 2, 'NWR': 2, 'NIDR': 1, 'NIDW': 1}),
    ('rdprio', {'ARB': 1}),
    ('wrprio', {'ARB': 2}),
    ('dw1024', {'DW': 1024, 'NRD': 4, 'NWR': 4, 'NTX': 60}),
    ('slots128', {'NRD': 128, 'NWR': 128, 'SRCW': 9, 'NIDR': 8, 'NIDW': 8}),
]


def env():
    e = dict(os.environ)
    if os.path.isdir(SUITE):
        e['PATH'] = os.pathsep.join([os.path.join(SUITE, 'bin'), os.path.join(SUITE, 'lib'), e.get('PATH', '')])
    return e


def exe(name):
    return shutil.which(name, path=env()['PATH']) or name


def rtl_files(rtl_dir=None):
    rtl_dir = rtl_dir or os.path.join(IP, 'rtl')
    names = [l.strip() for l in open(os.path.join(IP, 'rtl', 'filelist.f')) if l.strip() and not l.startswith('//')]
    files = [os.path.join(rtl_dir, n) for n in names]
    files += [os.path.join(COMMON, 'rtl_lib', 'm_vlsit_sfifo_ram_macro.sv'), os.path.join(COMMON, 'rtl_cells', 'VLSIT_CELL_SRAM_1W1R.sv')]
    return files


def compile_tb(out, params, rtl_dir=None):
    cmd = [exe('iverilog'), '-g2012', '-DVLSIT_SYNTHESIS', '-o', out]
    cmd += ['-Ptb_axi2tlul.%s=%s' % (k, v) for k, v in params.items()]
    cmd += [os.path.join(HERE, 'tb_axi2tlul.sv'), os.path.join(HERE, 'axi2tlul_checks.sv')] + rtl_files(rtl_dir)
    r = subprocess.run(cmd, capture_output=True, text=True, env=env())
    if r.returncode:
        sys.exit('COMPILE FAILED\n' + r.stdout + r.stderr)


def run_vvp(vvp, args, timeout=900):
    r = subprocess.run([exe('vvp'), vvp] + args, capture_output=True, text=True, env=env(), timeout=timeout)
    return r.returncode, r.stdout + r.stderr


# ------------------------------------------------------------------ regression
def regress(seeds):
    os.makedirs(LOGS, exist_ok=True)
    tmp = tempfile.mkdtemp()
    jobs = []
    for name, params in CONFIGS:
        vvp = os.path.join(tmp, name + '.vvp')
        compile_tb(vvp, params)
        for s in seeds:
            jobs.append((name, s, vvp))
    def one(j):
        name, s, vvp = j
        rc, out = run_vvp(vvp, ['+SEED=%d' % s])
        path = os.path.join(LOGS, 'regress_%s_seed%d.log' % (name, s))
        open(path, 'w').write(out)
        ok = (rc == 0 and 'PASS tb_axi2tlul' in out and 'assertion failures: 0, assertions never exercised: 0' in out)
        return name, s, ok, rc
    results = []
    with concurrent.futures.ThreadPoolExecutor(max_workers=4) as ex:
        for r in ex.map(one, jobs):
            print('%-9s seed %-3d %s' % (r[0], r[1], 'PASS' if r[2] else 'FAIL (exit %d, log in logs/)' % r[3]))
            results.append(r)
    shutil.rmtree(tmp, ignore_errors=True)
    return all(r[2] for r in results)


# ------------------------------------------------------------------ waveform scenarios
def lab32(label):
    """32-bit value of a symbolic data label of a figure: a hex string of 8 digits is itself, else a CRC."""
    if re.fullmatch(r'[0-9A-Fa-f]{8}', label):
        return int(label, 16)
    return zlib.crc32(label.encode()) & 0xFFFFFFFF


SLOT_W = 4   # default configuration: 16 slots per direction

def dec_src(label):
    m = re.fullmatch(r'(rd|wr)(\d+)', label)
    return int(m.group(2)) + ((1 << SLOT_W) if m.group(1) == 'wr' else 0)

DECODE = {
    'awaddr': lambda l: int(l, 16), 'araddr': lambda l: int(l, 16), 'awlen': int, 'arlen': int, 'awsize': int, 'arsize': int,
    'awid': int, 'arid': int, 'awburst': lambda l: {'FIXED': 0, 'INCR': 1, 'WRAP': 2}[l], 'arburst': lambda l: {'FIXED': 0, 'INCR': 1, 'WRAP': 2}[l],
    'awprot': lambda l: int(l, 2), 'arprot': lambda l: int(l, 2), 'wdata': lab32, 'wstrb': lambda l: int(l, 2),
    'd_opcode': lambda l: {'AckData': 1, 'Ack': 0}[l], 'd_src': dec_src, 'd_data': lab32,
    'a_opcode': lambda l: {'Get': 4, 'PutFull': 0, 'PutPartial': 1}[l], 'a_src': dec_src, 'a_addr': lambda l: int(l, 16),
    'a_size': int, 'a_mask': lambda l: int(l, 2), 'a_data': lab32, 'rid': int, 'bid': int, 'rdata': lab32,
    'rresp': lambda l: {'OKAY': 0, 'SLVERR': 2}[l], 'bresp': lambda l: {'OKAY': 0, 'SLVERR': 2}[l],
}

def tbname(port):
    n = re.sub(r'^[io]_', '', port)
    if n.startswith('axi_'):
        return n[4:]
    if n.startswith('tl_a_'):
        return 'a_' + n[5:]
    if n.startswith('tl_d_'):
        return 'd_' + n[5:]
    return {'evt_axi_err_rd': 'evt_axi_err_rd', 'evt_axi_err_wr': 'evt_axi_err_wr', 'evt_bad_resp': 'evt_bad', 'evt_orphan_resp': 'evt_orphan', 'rst_n_main': 'rst_n', 'clk_main': 'clk'}.get(n, n)


def expand(row, n):
    """per-cycle (kind, value, label) of a WaveJSON row: kind 'L' level, 'D' data label, 'X' unknown"""
    wave, data = row['wave'], list(row.get('data', []))
    out, cur, di = [], ('X', None), 0
    for i in range(n):
        ch = wave[i] if i < len(wave) else '.'
        if ch in '01':
            cur = ('L', int(ch))
        elif ch == '=':
            cur = ('D', data[di]); di += 1
        elif ch in 'xX':
            cur = ('X', None)
        out.append(cur)
    return out


def figure_rows(doc):
    rows = []
    for item in doc['signal']:
        if isinstance(item, list):
            rows += [r for r in item[1:] if isinstance(r, dict)]
        elif isinstance(item, dict) and item.get('name'):
            rows.append(item)
    return rows


INPUT_FIELDS = ['rst_n', 'awvalid', 'awid', 'awaddr', 'awlen', 'awsize', 'awburst', 'awprot', 'wvalid', 'wdata', 'wstrb', 'wlast',
                'bready', 'arvalid', 'arid', 'araddr', 'arlen', 'arsize', 'arburst', 'arprot', 'rready', 'a_ready', 'd_valid',
                'd_opcode', 'd_src', 'd_data', 'd_err']
DEFAULT_IN = {f: 0 for f in INPUT_FIELDS}
DEFAULT_IN.update({'rst_n': 1, 'bready': 1, 'rready': 1, 'a_ready': 1})


# data rows of the bridge are only meaningful while their VALID is 1 (signal type "data (valid with ...)")
QUALIFIER = {'o_axi_rid': 'o_axi_rvalid', 'o_axi_rdata': 'o_axi_rvalid', 'o_axi_rresp': 'o_axi_rvalid', 'o_axi_rlast': 'o_axi_rvalid',
             'o_axi_bid': 'o_axi_bvalid', 'o_axi_bresp': 'o_axi_bvalid'}
for _n in ('opcode', 'param', 'size', 'src', 'addr', 'mask', 'data', 'user'):
    QUALIFIER['o_tl_a_' + _n] = 'o_tl_a_valid'


def stim_lines(rows, n):
    byname = {tbname(r['name']): expand(r, n) for r in rows if r['name'].startswith('i_')}
    lines = []
    for k in range(n):
        vals = []
        for f in INPUT_FIELDS:
            v = DEFAULT_IN[f]
            if f in byname:
                kind, x = byname[f][k]
                if kind == 'L':
                    v = x
                elif kind == 'D':
                    v = DECODE[f](x)
            vals.append(v)
        lines.append(' '.join('%x' % v for v in vals))
    return lines


def parse_vcd(path):
    ids, names, changes = {}, {}, {}
    t = 0
    scope = []
    with open(path) as f:
        for line in f:
            line = line.strip()
            if line.startswith('$scope'):
                scope.append(line.split()[2])
            elif line.startswith('$upscope'):
                scope.pop()
            elif line.startswith('$var'):
                p = line.split()
                if scope == ['tb_axi2tlul']:
                    ids.setdefault(p[3], []).append(p[4])
                    names[p[4]] = p[3]
                    changes.setdefault(p[3], [])
            elif line.startswith('#'):
                t = int(line[1:])
            elif line and line[0] in '01xzXZ' and not line.startswith('$'):
                if line[1:] in changes:
                    changes[line[1:]].append((t, line[0]))
            elif line.startswith('b'):
                val, ident = line[1:].split()
                if ident in changes:
                    changes[ident].append((t, val))
    return names, changes


def value_at(changes, t):
    times = [c[0] for c in changes]
    i = bisect.bisect_right(times, t) - 1
    return changes[i][1] if i >= 0 else 'x'


def to_int(v):
    return int(v, 2) if re.fullmatch(r'[01]+', v) else None


def run_scenarios():
    os.makedirs(LOGS, exist_ok=True)
    os.makedirs(WSIM, exist_ok=True)
    tmp = tempfile.mkdtemp()
    vvp = os.path.join(tmp, 'scen.vvp')
    compile_tb(vvp, {})
    index = ['# Simulated waveforms against the figures of the specification', '',
             'Each scenario is simulated by `verification/vlsit_run_sim.py scenarios` on the delivered RTL (configuration CFG-BASE). The inputs of the bridge',
             'are driven cycle by cycle from the input rows of the specification figure; the outputs of the figure are compared with the simulated ones',
             'cycle by cycle (levels exactly, data labels decoded to values where the label has a value). Cycle 0 is the first cycle after the release of the reset.', '',
             '| Waveform ID | Specification figure | Simulated waveform | Result | Note |', '|---|---|---|---|---|']
    allok = True
    for jp in sorted(glob.glob(os.path.join(SPEC_FIG, 'wf-*.json'))):
        stem = os.path.splitext(os.path.basename(jp))[0]
        wid = stem.upper().replace('WF-', 'WF-')
        doc = json.load(open(jp))
        rows = figure_rows(doc)
        n = len(doc['signal'][0]['wave'])
        stim = os.path.join(WSIM, stem + '_stim.txt')
        open(stim, 'w').write('\n'.join(stim_lines(rows, n)) + '\n')
        vcd = os.path.join(WSIM, stem + '.vcd')
        rc, out = run_vvp(vvp, ['+STIM=' + stim, '+VCD=' + vcd])
        open(os.path.join(LOGS, 'scenario_%s.log' % stem), 'w').write(out)
        names, changes = parse_vcd(vcd)
        rel = 35000   # release edge of the scenario in ps (4 rising edges after the first one at 5 ns)
        diffs, sim_rows = [], []
        for r in rows:
            tb = tbname(r['name'])
            if tb == 'clk' or tb not in names:
                continue
            ch = changes[names[tb]]
            vals = []
            for k in range(n):
                v = value_at(ch, rel + 10000 * (k + 1) - 1)
                vals.append(v)
            fig = expand(r, n)
            qrow = next((q for q in rows if q['name'] == QUALIFIER.get(r['name'])), None)
            qual = expand(qrow, n) if qrow else None
            for k in range(n):
                kind, x = fig[k]
                iv = to_int(vals[k])
                if qual is not None and qual[k][1] == 0:
                    continue
                if r['name'].startswith('o_') or r['name'].startswith('i_'):
                    if kind == 'L' and iv != x:
                        diffs.append('%s c%d: figure %d, simulation %s' % (r['name'], k, x, vals[k]))
                    elif kind == 'D':
                        if tb == 'a_user':
                            m = re.search(r'instr (\d+)', x)
                            exp = int(m.group(1)) if m else None
                            if exp is not None and (iv is None or ((iv >> 14) & 0xF) != exp):
                                diffs.append('%s c%d: figure instr %s, simulation %s' % (r['name'], k, exp, vals[k]))
                        elif tb in DECODE:
                            exp = DECODE[tb](x) if not re.fullmatch(r'x+', x) else None
                            if exp is not None and iv != exp:
                                diffs.append('%s c%d: figure %s (%s), simulation %s' % (r['name'], k, x, hex(exp), hex(iv) if iv is not None else vals[k]))
            # simulated row in the form of the figure row
            wave, data, prev = '', [], None
            for k in range(n):
                kind, x = fig[k]
                v = vals[k]
                if len(v) == 1 and v in '01' and (kind == 'L' or tb in ('rst_n',)):
                    wave += v
                elif len(v) == 1 and v in '01' and kind != 'D':
                    wave += v
                else:
                    iv = to_int(v)
                    lab = hex(iv) if iv is not None else 'x'
                    if kind == 'X' or iv is None:
                        wave += 'x'; prev = None
                    elif lab == prev:
                        wave += '.'
                    else:
                        wave += '='; data.append(lab); prev = lab
            sim_rows.append({'name': r['name'], 'wave': wave, 'data': data})
        sim_doc = {'signal': [{'name': 'i_clk_main', 'wave': 'p' + '.' * (n - 1)}] + sim_rows, 'head': {'text': doc.get('head', {}).get('text', stem) + ' (simulated)'}}
        json.dump(sim_doc, open(os.path.join(WSIM, stem + '.json'), 'w'), indent=1)
        subprocess.run([sys.executable, SVG_TOOL, 'render', os.path.join(WSIM, stem + '.json'), '--out', os.path.join(WSIM, stem + '.svg'), '--force'],
                       capture_output=True, text=True)
        res = 'MATCH' if not diffs and rc == 0 else 'DIFFERENT'
        if diffs:
            allok = False
        note = 'Same values in all %d compared cycles' % n if not diffs else '%d difference(s), first: %s' % (len(diffs), diffs[0])
        index.append('| %s | figures/%s.svg | waveforms_sim/%s.svg | %s | %s |' % (wid, stem, stem, res, note))
        print('%s %s %s' % (wid, res, '' if not diffs else '; '.join(diffs[:3])))
        open(os.path.join(LOGS, 'scenario_%s_diff.txt' % stem), 'w').write('\n'.join(diffs) + '\n')
        os.remove(stim)
    open(os.path.join(WSIM, 'waveform_compare.md'), 'w').write('\n'.join(index) + '\n')
    shutil.rmtree(tmp, ignore_errors=True)
    return allok


# ------------------------------------------------------------------ injected bugs
MUTANTS = [
    ('wr_opcode_always_partial', 'm_vlsit_axi2tlul_wr_req.sv', "(w_mask == w_region) ?", "(w_mask != w_mask) ?"),
    ('wr_mask_or', 'm_vlsit_axi2tlul_wr_req.sv', "assign w_mask   = w_w_strb & f_mask", "assign w_mask   = w_w_strb | f_mask"),
    ('wrap_as_incr', 'm_vlsit_axi2tlul_rd_req.sv', "LPARA_BURST_WRAP[1:0]:  f_next = (aligned & ~wrap_mask) | (inc & wrap_mask);", "LPARA_BURST_WRAP[1:0]:  f_next = inc;"),
    ('fixed_as_incr', 'm_vlsit_axi2tlul_rd_req.sv', "LPARA_BURST_FIXED[1:0]: f_next = addr;", "LPARA_BURST_FIXED[1:0]: f_next = inc;"),
    ('no_4k_check', 'm_vlsit_axi2tlul_rd_req.sv', "(w_ar_page_end > 17'(LPARA_PAGE_BYTES))", "1'b0"),
    ('rlast_zero_bypass', 'm_vlsit_axi2tlul_rd_rob.sv', "w_rlast_nxt  = w_cmp_last;", "w_rlast_nxt  = 1'b0;"),
    ('interleave_allowed', 'm_vlsit_axi2tlul_rd_rob.sv', "w_bypass_ok = reg_r_active ? (|(w_cmp_head_ctx & w_idm)) : (w_cand == '0);", "w_bypass_ok = 1'b1;"),
    ('error_ignored_read', 'm_vlsit_axi2tlul_rsp_dec.sv', "assign o_rd_cmp_err   = i_tl_d_err | w_op_bad;", "assign o_rd_cmp_err   = w_op_bad;"),
    ('error_ignored_write', 'm_vlsit_axi2tlul_rsp_dec.sv', "assign o_wr_cmp_err   = i_tl_d_err | w_op_bad;", "assign o_wr_cmp_err   = w_op_bad;"),
    ('sticky_error_lost', 'm_vlsit_axi2tlul_wr_rob.sv', "w_ctx_err_nxt[ctx] = ~w_ret_last & w_ret_err;", "w_ctx_err_nxt[ctx] = 1'b0;"),
    ('d_ready_late', 'm_vlsit_axi2tlul_rsp_dec.sv', "      reg_ready <= 1'b1;", "      reg_ready <= i_tl_d_valid;"),
    ('src_direction_lost', 'm_vlsit_axi2tlul_arb.sv', "assign w_wr_src  = ($bits(w_wr_src)'(1) << LPARA_SLOT_W) | $bits(w_wr_src)'(i_wr_slot);", "assign w_wr_src  = $bits(w_wr_src)'(i_wr_slot);"),
    ('instr_type_inverted', 'm_vlsit_axi2tlul_arb.sv', "w_rd_user[LPARA_USER_LOW_W-1:0] = {(i_rd_instr ? LPARA_MUBI_TRUE[3:0] : LPARA_MUBI_FALSE[3:0]),", "w_rd_user[LPARA_USER_LOW_W-1:0] = {(i_rd_instr ? LPARA_MUBI_FALSE[3:0] : LPARA_MUBI_TRUE[3:0]),"),
    ('read_priority_ignored', 'm_vlsit_axi2tlul_arb.sv', "LPARA_MODE_RD_PRIO: w_pref_rd = 1'b1;", "LPARA_MODE_RD_PRIO: w_pref_rd = ~reg_prio_wr;"),
    ('orphan_not_reported', 'm_vlsit_axi2tlul_rsp_dec.sv', "assign o_orphan      = i_tl_d_valid & (w_tag_bad | w_slot_orphan);", "assign o_orphan      = 1'b0;"),
    ('evt_rd_wr_merged', 'm_vlsit_axi2tlul_evt.sv', "reg_axi_err_wr <= i_axi_err_wr;", "reg_axi_err_wr <= i_axi_err_wr | i_axi_err_rd;"),
    ('illegal_event_lost', 'm_vlsit_axi2tlul_wr_req.sv', "            w_aw_pop = 1'b1;\n            w_evt    = 1'b1;", "            w_aw_pop = 1'b1;"),
]


def run_mutants():
    os.makedirs(LOGS, exist_ok=True)
    tmp = tempfile.mkdtemp()
    lines = ['# Injected bugs (a copy of the RTL, the delivered RTL is untouched)', '', '| Bug | Result |', '|---|---|']
    caught = 0
    cfg_for = {'read_priority_ignored': {'ARB': 1}}
    for name, fname, a, b in MUTANTS:
        d = os.path.join(tmp, name)
        shutil.copytree(os.path.join(IP, 'rtl'), d)
        p = os.path.join(d, fname)
        s = open(p).read()
        if a not in s:
            print('mutant %s: pattern not found' % name)
            lines.append('| %s | not applied: pattern not found |' % name)
            continue
        open(p, 'w').write(s.replace(a, b, 1))
        vvp = os.path.join(d, 'm.vvp')
        compile_tb(vvp, cfg_for.get(name, {}), rtl_dir=d)
        try:
            rc, out = run_vvp(vvp, ['+SEED=5'], timeout=600)
        except subprocess.TimeoutExpired:
            rc, out = 1, 'timeout'
        failed = rc != 0 or 'PASS tb_axi2tlul' not in out
        caught += failed
        first = next((l for l in out.splitlines() if 'FAIL' in l or 'TIMEOUT' in l), '') or ('simulation timeout' if out == 'timeout' else 'exit code %d, no assertion line' % rc)
        print('%-26s %s' % (name, 'CAUGHT' if failed else 'NOT CAUGHT'))
        lines.append('| %s | %s |' % (name, ('caught: ' + first[:110].replace('|', '/')) if failed else 'NOT CAUGHT'))
    lines += ['', 'Caught: %d of %d.' % (caught, len(MUTANTS))]
    open(os.path.join(LOGS, 'mutation_result.md'), 'w').write('\n'.join(lines) + '\n')
    shutil.rmtree(tmp, ignore_errors=True)
    return caught == len(MUTANTS)


if __name__ == '__main__':
    ap = argparse.ArgumentParser()
    ap.add_argument('action', choices=['regress', 'scenarios', 'mutants', 'all'])
    ap.add_argument('--seeds', default='1,2,3')
    a = ap.parse_args()
    ok = True
    if a.action in ('regress', 'all'):
        ok = regress([int(x) for x in a.seeds.split(',')]) and ok
    if a.action in ('scenarios', 'all'):
        ok = run_scenarios() and ok
    if a.action in ('mutants', 'all'):
        ok = run_mutants() and ok
    print('RESULT: %s' % ('PASS' if ok else 'FAIL'))
    sys.exit(0 if ok else 1)
