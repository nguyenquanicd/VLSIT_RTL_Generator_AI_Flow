"""Injected bugs on a copy of the RTL: the testbench has to fail (guide section 4 of the testbench guide).

  python vlsit_mutants.py [--only 1,2,3]

The delivered RTL is never changed: the RTL, the library files and the verification folder are copied to a temporary tree,
one bug is injected, and the simulation of the configuration is run in the copy. The result goes to logs/mutation_result.md.
"""
import argparse, os, re, shutil, subprocess, sys, tempfile

HERE = os.path.dirname(os.path.abspath(__file__))
IP = os.path.abspath(os.path.join(HERE, '..'))
ROOT = os.path.abspath(os.path.join(IP, '..'))

LIB = [os.path.join('000_Common', 'rtl_lib', 'm_vlsit_tie.sv'),
       os.path.join('000_Common', 'rtl_cells', 'VLSIT_CELL_TIEH.sv'),
       os.path.join('000_Common', 'rtl_cells', 'VLSIT_CELL_TIEL.sv'),
       os.path.join('002_SyncFIFO', 'rtl', 'm_vlsit_sfifo_1clk.sv')]

# id, config, file (relative to 010_AXI4_Upsizer/rtl), old text, new text, requirement the bug breaks
M = [
    (1, 'axi4_def', 'common/m_vlsit_ups_attribute.sv', '(w_is_incr | (w_is_wrap & (w_small | w_aligned_m)))', '(w_is_incr | w_is_wrap)',
     'REQ-FUNC-005: WRAP packed without the alignment condition'),
    (2, 'axi4_def', 'common/m_vlsit_ups_attribute.sv', 'assign w_pack = i_modifiable & ', 'assign w_pack = 1\'b1 & ',
     'REQ-FUNC-002: Non-modifiable packed'),
    (3, 'axi4_def', 'common/m_vlsit_ups_attribute.sv', '(i_lock == \'0) &', '1\'b1 &', 'REQ-FUNC-002: locked packed'),
    (4, 'axi4_def', 'common/m_vlsit_ups_attribute.sv', 'LPARA_RATIO - 1);', 'LPARA_RATIO - 2);', 'REQ-FUNC-004: wrong NM (M AxLEN)'),
    (5, 'axi4_def', 'common/m_vlsit_ups_beat_addr.sv', 'w_small_wrap ? $bits(w_wm)\'(w_bl - 1\'b1) : \'1;', '\'1;',
     'REQ-FUNC-006/007: small WRAP slot mask ignored'),
    (6, 'axi4_def', 'common/m_vlsit_ups_beat_addr.sv', 'w_last | (~w_small_wrap & (w_slot_p == \'1))', 'w_last',
     'REQ-FUNC-009: word-last flag only on the last beat (M word not issued when full)'),
    (7, 'axi4_def', 'common/m_vlsit_ups_wr_pack.sv', 'assign o_beat_last  = w_last;', 'assign o_beat_last  = 1\'b0;',
     'REQ-FUNC-009/SVA-005: M WLAST missing'),
    (8, 'axi4_def', 'common/m_vlsit_ups_rd_unpack.sv', 'assign o_beat_resp  = reg_word_resp;', 'assign o_beat_resp  = \'0;',
     'REQ-FUNC-013: RRESP not copied'),
    (9, 'axi4_def', 'common/m_vlsit_ups_rd_unpack.sv', 'assign o_beat_last  = w_last;', 'assign o_beat_last  = w_word_last;',
     'REQ-FUNC-013: RLAST on the last S beat of every M word'),
    (10, 'axi4_def', 'common/m_vlsit_ups_slice.sv', 'reg_ready      <= ~w_skid_valid_nxt;', 'reg_ready      <= 1\'b1;',
     'REQ-IF-002/003: READY of the slice never drops (data lost)'),
    (11, 'axi3_def', 'common/m_vlsit_ups_wr_interleave.sv', 'assign w_sel_idx   = w_any_match ? w_match_idx : w_free_idx;',
     'assign w_sel_idx   = w_free_idx;', 'REQ-FUNC-018: beat not given to the context of its WID'),
    (12, 'axi3_def', 'common/m_vlsit_ups_wr_interleave.sv', '(i_pend_any | w_any_ctx);', '1\'b1;',
     'REQ-FUNC-018: WREADY not held while no AW is pending'),
    (13, 'axi4_def', 'common/m_vlsit_ups_wr_path.sv', 'assign o_s_aw_ready = ~w_store_full & w_aw_slice_ready;',
     'assign o_s_aw_ready = w_aw_slice_ready;', 'REQ-PARAM-003: AW accepted while the queue is full'),
    (14, 'axi4_def', 'common/m_vlsit_ups_rd_path.sv', 'assign w_head_has_nxt = (w_queue_count > $bits(w_queue_count)\'(1));',
     'assign w_head_has_nxt = 1\'b1;', 'REQ-FUNC-014: R beat taken with no queue entry'),
    (15, 'axi4_def', 'common/m_vlsit_ups_attribute.sv', 'assign w_cmask = $bits(w_cmask)\'(w_cont - 1\'b1);',
     'assign w_cmask = $bits(w_cmask)\'(w_cont);', 'REQ-FUNC-006: wrap boundary mask of the small container'),
    (16, 'axi3_def', 'common/m_vlsit_ups_wr_path.sv', 'assign {o_s_b_id, o_s_b_resp} = w_b_slice_out;',
     'assign {o_s_b_id, o_s_b_resp} = {w_b_slice_out[LPARA_B_W-1:2], 2\'b00};', 'REQ-FUNC-011: BRESP not passed'),
    (17, 'axi3_def', 'common/m_vlsit_ups_wr_path.sv', 'assign w_store_full = (reg_out_cnt == $bits(reg_out_cnt)\'(PARA_AXI_WR_OUTSTANDING_DEPTH));',
     'assign w_store_full = 1\'b0;', 'REQ-PARAM-003: AXI3 outstanding limit missing'),
]


def run(m, tmp):
    mid, cfg, rel, old, new, why = m
    work = tempfile.mkdtemp(dir=tmp)
    base = os.path.join(work, 'common_rtl')
    shutil.copytree(os.path.join(IP, 'rtl'), os.path.join(base, '010_AXI4_Upsizer', 'rtl'),
                    ignore=shutil.ignore_patterns('lint_*.log'))
    for f in LIB:
        os.makedirs(os.path.dirname(os.path.join(base, f)), exist_ok=True)
        shutil.copy(os.path.join(ROOT, f), os.path.join(base, f))
    shutil.copytree(HERE, os.path.join(base, '010_AXI4_Upsizer', 'verification'), ignore=shutil.ignore_patterns('build', 'logs', '__pycache__'))
    path = os.path.join(base, '010_AXI4_Upsizer', 'rtl', rel)
    text = open(path, encoding='utf-8').read()
    if text.count(old) != 1:
        return 'ERROR', 'pattern found %d times' % text.count(old)
    open(path, 'w', encoding='utf-8', newline='\n').write(text.replace(old, new))
    r = subprocess.run([sys.executable, os.path.join(base, '010_AXI4_Upsizer', 'verification', 'vlsit_run_sim.py'), 'one', cfg, '--seed', '1'],
                       capture_output=True, text=True)
    out = r.stdout + r.stderr
    logf = os.path.join(base, '010_AXI4_Upsizer', 'verification', 'logs', 'regress_%s_seed1.log' % cfg)
    if os.path.exists(logf):
        out += os.linesep + open(logf, encoding='utf-8', errors='replace').read()
    shutil.rmtree(work, ignore_errors=True)
    if 'BUILD FAILED' in out:
        return 'BUILD', out[-300:]
    seen = []
    for l in out.splitlines():
        if 'CHECK FAIL' in l or 'ASSERT FAIL' in l or 'no progress' in l or 'global timeout' in l:
            key = re.sub(r'@\d+|tx=\d+|beat=\d+|lane=\d+|[0-9a-f]{8,}', '', l.split(':', 1)[-1]).strip()[:70]
            if key not in [k for k, _ in seen]:
                seen.append((key, l.strip()))
    first = ' ## '.join(s for _, s in seen[:3])
    if r.returncode == 0 and 'PASS tb_ups' in out:
        return 'SURVIVED', ''
    return 'KILLED', first or ('exit %d' % r.returncode)


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('--only', default='')
    a = ap.parse_args()
    sel = [int(x) for x in a.only.split(',')] if a.only else [m[0] for m in M]
    tmp = tempfile.mkdtemp()
    rows = []
    for m in M:
        if m[0] not in sel:
            continue
        res, info = run(m, tmp)
        print('mutant %-3d %-9s %s | %s' % (m[0], res, m[5], info[:150]))
        rows.append((m, res, info))
    shutil.rmtree(tmp, ignore_errors=True)
    os.makedirs(os.path.join(HERE, 'logs'), exist_ok=True)
    with open(os.path.join(HERE, 'logs', 'mutation_result.md'), 'w', encoding='utf-8') as f:
        f.write('# Injected bugs\n\n| Bug | Configuration | File | Requirement broken | Result | First check that fired |\n|---|---|---|---|---|---|\n')
        for m, res, info in rows:
            f.write('| %d | %s | %s | %s | %s | %s |\n' % (m[0], m[1], m[2], m[5], res, info.replace('|', '/')))
        k = sum(1 for _, r, _ in rows if r == 'KILLED')
        f.write('\n%d of %d injected bugs were caught.\n' % (k, len(rows)))
    sys.exit(0)


if __name__ == '__main__':
    main()
