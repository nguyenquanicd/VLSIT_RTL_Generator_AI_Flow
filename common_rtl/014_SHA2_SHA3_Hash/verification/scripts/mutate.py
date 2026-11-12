"""Strength of the testbench (guide section 4): inject one bug at a time into a COPY of the RTL (work/mut/), build, run the
quick regression and record which check fired. The delivered RTL is never changed.
Run: python mutate.py       Result: reports/mutation_report.md
"""
import os
import re
import shutil
import subprocess
import sys

import simlib as S
import vec_lib as V

VER = S.VER
WORK = VER + '/work/mut'

# (name, file, old text, new text, what requirement the bug breaks)
MUTANTS = [
    ('M01 SHA-256 constant K0 bit flipped', 'm_vlsit_sha_core256.sv', "6'd0: f_k = 32'h428a2f98;", "6'd0: f_k = 32'h428a2f99;", 'REQ-FUNC-001'),
    ('M02 Keccak round constant RC[1] changed', 'm_vlsit_sha_keccak.sv', "5'd1: f_rc = 64'h0000000000008082;", "5'd1: f_rc = 64'h0000000000008083;", 'REQ-FUNC-001'),
    ('M03 partial WSTRB accepted', 'm_vlsit_sha_axi_sub.sv', "w_w_strb_ok = (i_axi_wstrb == {LPARA_STRB_W{1'b1}});", "w_w_strb_ok = 1'b1;", 'REQ-IF-002'),
    ('M04 BID not the AWID of the burst', 'm_vlsit_sha_axi_sub.sv', "o_axi_bid     = reg_w_id;", "o_axi_bid     = '0;", 'REQ-IF-001'),
    ('M05 o_irq ignores the context-done events', 'm_vlsit_sha_irq.sv', "o_irq       = (|o_sts_one) || (|o_sts_cdone);", "o_irq       = (|o_sts_one);", 'REQ-INT-001'),
    ('M06 SHA-256 core not cleared after a block (zeroing removed)', 'm_vlsit_sha_seq.sv', "o_c256_clr   = w_do_srst || w_be_abort || (w_be_done && w_cls256 && w_zero_en);", "o_c256_clr   = w_do_srst || w_be_abort;", 'REQ-SEC-001'),
    ('M07 write to a digest window accepted (direction check removed)', 'm_vlsit_sha_axi_sub.sv', "    else if (i_axi_awaddr[11])\n      w_aw_kind = LPARA_KIND_DIR[3:0];", "    else if (1'b0)\n      w_aw_kind = LPARA_KIND_DIR[3:0];", 'REQ-IF-002'),
    ('M08 DMA input request not raised (promise ignored: request when free >= burst only after 1 word)', 'm_vlsit_sha_dma.sv', "w_in_cond  = i_en && w_burst_ok && i_in_abs && (w_free >= (reg_pend_in + w_burst32));", "w_in_cond  = i_en && w_burst_ok && i_in_abs && (w_free > (reg_pend_in + w_burst32 + 32'd3));", 'REQ-IF-004'),
    ('M09 error record kind not kept (read of empty FIFO not counted)', 'm_vlsit_sha_axi_sub.sv', "if (w_r_beat && w_r_ok && w_r_empty && !i_pad_ok)\n      w_r_ev_kind = LPARA_KIND_UDF[3:0];", "if (1'b0)\n      w_r_ev_kind = LPARA_KIND_UDF[3:0];", 'REQ-ERR-001'),
    ('M10 WLAST not required: write response one beat early', 'm_vlsit_sha_axi_sub.sv', "if (w_w_accept && i_axi_wlast)", "if (w_w_accept)", 'REQ-IF-001'),
]
# stage 2a mutants: run with the fault configuration and the fault test script
FAULT_MUTANTS = [
    ('F01 duplicate compare disabled', 'm_vlsit_sha_fault.sv', "w_mm_dup = w_mm_dup && i_sec_fault && i_sec_fdup;", "w_mm_dup = 1'b0;", 'REQ-SEC-002', 'dup'),
    ('F02 lock response never set', 'm_vlsit_sha_fault.sv', "reg_lock <= reg_lock || i_sec_resp[1];", "reg_lock <= reg_lock;", 'REQ-SEC-002'),
    ('F03 gate does not reject digest reads', 'm_vlsit_sha_axi_sub.sv', "if (i_lock || i_gate || !w_ar_ctx_ok", "if (i_lock || !w_ar_ctx_ok", 'REQ-SEC-002', 'dup'),
    ('F04 parity flags ignored', 'm_vlsit_sha_fault.sv', "w_par_hit   = (PARA_PAR != 32'd0) && i_sec_fault && i_sec_fpar && i_par_err;", "w_par_hit   = 1'b0;", 'REQ-SEC-002'),
    ('F05 recompute compare disabled', 'm_vlsit_sha_fault.sv', "w_mm_redo = i_sec_fault && i_sec_fredo && i_be_done && i_pass_second", "w_mm_redo = 1'b0 && i_pass_second", 'REQ-SEC-002', 'redo'),
    ('F06 soft reset does not clear the lock', 'm_vlsit_sha_fault.sv', "        reg_lock <= 1'b0;\n        reg_gate <= 1'b0;\n      end else if (reg_flt)", "        reg_gate <= 1'b0;\n      end else if (reg_flt)", 'REQ-SEC-002'),
    ('F07 result of a faulty block still stored', 'm_vlsit_sha_seq.sv', "o_wra_en   = w_be_fin && w_be_alive && !w_be_kill && !i_mismatch;", "o_wra_en   = w_be_fin && w_be_alive && !w_be_kill;", 'REQ-SEC-002', 'dup'),
    ('F08 parity of the input FIFO not checked', 'm_vlsit_sha_ctx_fifo.sv', "        o_par_err = |w_pop_ok;", "        o_par_err = 1'b0;", 'REQ-SEC-002'),
    ('F09 alarm never raised', 'm_vlsit_sha_fault.sv', "o_alarm_set = reg_flt && i_sec_resp[3] && (PARA_ALARM != 32'd0);", "o_alarm_set = 1'b0;", 'REQ-SEC-002'),
    ('F11 parity of the context memory not checked when the output unit reads', 'm_vlsit_sha_ctxmem.sv', "|| (i_rd1_chk && (f_par(o_rd1_data) != w_par_rd1)));", "|| 1'b0);", 'REQ-SEC-002', 'par'),
    ('F10 clear response does not wipe', 'm_vlsit_sha_fault.sv', "o_wipe      = reg_flt && i_sec_resp[2];", "o_wipe      = 1'b0;", 'REQ-SEC-002'),
]
# stage 2b mutants: run with the masked configuration; kind 'mask' = regression of the masked digests, kind 'stat' = the share statistics
MASK_MUTANTS = [
    ('K01 digest not unmasked (share 1 ignored by the output unit)', 'm_vlsit_sha_outp.sv', "w_state_u = w_rd_ext[1599:0] ^ w_rd_ext[3199:1600];", "w_state_u = w_rd_ext[1599:0];", 'REQ-SEC-003', 'mask'),
    ('K02 masked block starts without a seed', 'm_vlsit_sha_seq.sv', "w_ent_stall = (reg_fsm_be_current_state == ENUM_ST_BLOAD) && reg_pf_mask && !i_seeded;", "w_ent_stall = 1'b0;", 'ERR-006', 'mask'),
    ('K03 share 1 not refreshed at the start of a block', 'm_vlsit_sha_keccak_dom.sv', "reg_s1 <= i_state[3199:1600] ^ w_r;", "reg_s1 <= i_state[3199:1600];", 'REQ-SEC-003', 'mask'),
    ('K04 round constant not added to share 0', 'm_vlsit_sha_keccak_dom.sv', "w_a0[63:0] = w_a0[63:0] ^ f_rc(reg_cnt);", "w_a0[63:0] = w_a0[63:0];", 'REQ-SEC-003', 'mask'),
    ('K05 random bits of chi at the bit position of the refresh word (first design, DEC-037)', 'm_vlsit_sha_keccak_dom.sv', "w_rc   = {w_r[1279:0], w_r[1599:1280]};", "w_rc   = w_r;", 'REQ-SEC-003', 'stat'),
    ('K06 no random bits in chi (cross terms unmasked)', 'm_vlsit_sha_keccak_dom.sv', "w_rc   = {w_r[1279:0], w_r[1599:1280]};", "w_rc   = '0;", 'REQ-SEC-003', 'stat'),
]

LIMIT_MUTANTS = [
    ('L01 length limit never raised', 'm_vlsit_sha_seq.sv', "w_len_kill[idx] = (reg_ctot[idx][63:61] != 3'b000) && (reg_cst[idx] != LPARA_ST_FREE[3:0]);", "w_len_kill[idx] = 1'b0;", 'REQ-FUNC-009', 'limit'),
]


def rtl_copy(dst):
    if os.path.exists(dst):
        shutil.rmtree(dst, ignore_errors=True)
    shutil.copytree(S.RTL, dst)


def main():
    os.makedirs(WORK, exist_ok=True)
    algs = V.ALL_ALGS
    params = dict(DW=64, CTXN=4, ALG="12'h%03x" % V.algmask(algs))
    suite = ['edge_all_dw64.vec', 'dir_apb_dw64.vec', 'dir_err_dw64.vec', 'dir_irq_dw64.vec', 'dir_abort_dw64.vec', 'bp_on.vec', 'dir_bp_dw64.vec']
    sf = VER + '/vec/suite_mut.vec'
    with open(sf, 'w', newline='\n') as f:
        for x in suite:
            f.write('include %s\n' % x)
        f.write('end\n')
    for kk, vv in (('all', 'fault_all_dw64.vec'), ('dup', 'fault_dup_dw64.vec'), ('redo', 'fault_redo_dw64.vec'), ('par', 'fault_par_dw64.vec')):
        with open(VER + '/vec/suite_mut_%s.vec' % kk, 'w', newline=chr(10)) as ff:
            ff.write('include %s' % vv + chr(10) + 'end' + chr(10))
    sf_f = VER + '/vec/suite_mut_all.vec'
    with open(sf_f, 'w', newline='\n') as f:
        f.write('include fault_all_dw64.vec\nend\n')
    rows = []
    caught = 0
    allm = [(m, 'base') for m in MUTANTS] + [(m[:5], m[5] if len(m) > 5 else 'all') for m in FAULT_MUTANTS] + [(m[:5], m[5]) for m in MASK_MUTANTS] + [(m[:5], m[5]) for m in LIMIT_MUTANTS]
    for kk, vv in (('mask', ['mask_reg_dw64.vec', 'mask_err_dw64.vec']), ('stat', ['mask_stat_dw64.vec']), ('limit', ['dir_limit_dw64.vec'])):
        with open(VER + '/vec/suite_mut_%s.vec' % kk, 'w', newline=chr(10)) as ff:
            ff.write(''.join('include %s' % x + chr(10) for x in vv) + 'end' + chr(10))
    for i, ((name, fn, old, new, req), kind) in enumerate(allm):
        d = WORK + '/m%02d' % (i + 1)
        rtl_copy(d + '/rtl')
        p = d + '/rtl/' + fn
        txt = open(p, encoding='utf-8').read()
        if old not in txt:
            rows.append((name, req, 'NOT APPLIED', 'pattern not found in ' + fn))
            continue
        open(p, 'w', encoding='utf-8', newline='\n').write(txt.replace(old, new, 1))
        # build with the mutated copy (same relative layout: ../../000_Common is two levels up from rtl, so keep absolute paths for the others)
        files = [x if not x.startswith(S.RTL.replace(chr(92), '/')) else x.replace(S.RTL.replace(chr(92), '/'), d.replace(chr(92), '/') + '/rtl') for x in S.rtl_files()]
        pr = dict(params) if kind == 'base' else dict(params, **{'dup': dict(FDUP=1, ALARM=1), 'redo': dict(FREDO=1, ALARM=1), 'par': dict(FPAR=1, ALARM=1), 'all': dict(FDUP=1, FPAR=1, FREDO=1, ALARM=1), 'mask': dict(MASK=1, CTXN=2), 'stat': dict(MASK=1, CTXN=2), 'limit': dict(CTXN=2)}[kind])
        exe = S.build('mut%02d' % (i + 1), pr, coverage=False, trace=False, rtl_override=files)
        if not exe:
            rows.append((name, req, 'BUILD FAIL', ''))
            continue
        sfile = sf if kind == 'base' else (VER + '/vec/suite_mut_%s.vec' % kind)
        rc, out = S.run(exe, 'mut%02d' % (i + 1), sfile, ['+CLASSES=%s' % ('df' if kind == 'base' else ('480' if kind == 'mask' else ('80' if kind == 'stat' else ('00' if kind == 'limit' else '280')))), '+VECDIR=' + (VER + '/vec').replace(chr(92), '/'), '+TIMEOUT_NS=60000000'],
                        logname=VER + '/logs/mutation/mut%02d.log' % (i + 1))
        s = S.summarize(out)
        fired = []
        if s['sbfail'] > 0:
            tags = sorted(set(re.findall(r'SB FAIL \[([^\]]+)\]', out)))
            fired.append('scoreboard (%d fails, first in %s)' % (s['sbfail'], tags[0] if tags else '?'))
        for m in re.finditer(r'ASSERT (\d+)\s+hits=\d+\s+fails=([1-9]\d*)\s+(.*)', out):
            fired.append('assertion %s: %s' % (m.group(1), m.group(3).strip()[:80]))
        if 'global timeout' in out:
            fired.append('global timeout')
        if kind == 'stat':
            import mask_stat
            res = mask_stat.analyse(VER + '/logs/mutation/mut%02d.log' % (i + 1))
            if res:
                mx = max(max(abs(x[1]), abs(x[2])) for x in res)
                if mx >= 4.5:
                    fired.append('Welch t-test: max |t| = %.1f (limit 4.5)' % mx)
        ok = bool(fired)
        caught += 1 if ok else 0
        rows.append((name, req, 'CAUGHT' if ok else 'NOT CAUGHT', '; '.join(fired[:3]) if fired else 'no check fired'))
        shutil.rmtree(S.WORK + '/mut%02d' % (i + 1), ignore_errors=True)
        shutil.rmtree(d, ignore_errors=True)
    lines = ['# Mutation check of the testbench', '',
             'Each bug was injected alone into a copy of the RTL (`work/mut/`, deleted afterwards); the delivered RTL was not changed. '
             'Quick regression used: edge, APB, error, interrupt, abort, back pressure vectors of the 64-bit configuration (`scripts/mutate.py`).', '',
             '| Bug | Requirement | Result | What fired |', '|---|---|---|---|']
    for r in rows:
        lines.append('| %s | %s | %s | %s |' % r)
    lines += ['', 'Caught: %d of %d.' % (caught, len(allm)), '']
    open(VER + '/reports/mutation_report.md', 'w', encoding='utf-8').write('\n'.join(lines))
    print('\n'.join(lines))


if __name__ == '__main__':
    main()
