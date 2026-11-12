"""Scenario scripts of the waveform plan (WF-001 ... WF-019 of section 10.3 of the specification).
Each scenario makes the situation of its figure with the stimulus of the specification (never read from the RTL) and
is run alone so that its VCD holds only that scenario. WF-012 (fault) is simulated with stage 2a, WF-013 (masked-core
entropy port) with stage 2b.
Run: python gen_wf.py   (writes vec/wf_*.vec and wf_plan.json)
"""
import json
import os

import vec_lib as V
from gen_directed import T, CTRL, CMD, LEN, DMAC, STS, INIT, FINAL, ABORT, SRST, ctrl

OUT = os.path.join(V.VER, 'vec')

# stem of the figure -> scenario. anchor: the first event of the simulation that is slot `slot` of the figure.
PLAN = {}


def scen(wf, stem, cfg, anchor, clock='i_clk_core'):
    def deco(fn):
        PLAN[wf] = dict(stem=stem, cfg=cfg, anchor=anchor, clock=clock, fn=fn)
        return fn
    return deco


def words(v, n, base=0x1000):
    return ' '.join(v.hx(base + i) for i in range(n))


@scen('WF-001', 'wf_001_axi_write_burst', 'main', dict(sig='i_axi_awvalid', edge='rise', n=1, slot=1))
def wf001(v):
    v.sel(1, 1); v.cmd(INIT); v.add('poll 060 f00 100 2000'); v.add('wait 6')
    v.add('axiw 1 4 %s' % words(v, 4)); v.add('wait 8')


@scen('WF-002', 'wf_002_axi_write_error', 'main', dict(sig='i_axi_awvalid', edge='rise', n=1, slot=1))
def wf002(v):
    v.sel(1, 1); v.cmd(INIT); v.add('poll 060 f00 100 2000'); v.add('wait 6')
    v.add('strbl 0f'); v.add('axiw 1 2 %s' % words(v, 2)); v.add('strblo'); v.add('wait 8')
    v.add('apbw 0c4 00040000'); v.add('wait 4')


@scen('WF-003', 'wf_003_fifo_full_backpressure', 'main', dict(sig='o_axi_wready', edge='fall', n=1, slot=5))
def wf003(v):
    v.sel(1, 1); v.cmd(INIT); v.add('poll 060 f00 100 2000'); v.add('wait 6')
    v.add('axiwx 1 200'); v.add('wait 20')
    v.cmd(ABORT)


@scen('WF-004', 'wf_004_final_digest_ready', 'main', dict(sig='o_sha_cmd_final', edge='rise', n=1, slot=1))
def wf004(v):
    v.sel(1, 1); v.cmd(INIT); v.add('poll 060 f00 100 2000')
    v.add('axiw 1 1 %s' % v.hx(0x6564636261))
    v.add('apbw %03x 5' % LEN); v.add('wait 3'); v.cmd(FINAL); v.add('poll 060 4 4 20000'); v.add('wait 6')


@scen('WF-005', 'wf_005_digest_read_burst', 'main', dict(sig='i_axi_arvalid', edge='rise', n=1, slot=1))
def wf005(v):
    v.sel(1, 1); v.cmd(INIT); v.add('poll 060 f00 100 2000')
    v.add('axiw 1 1 %s' % v.hx(0x636261)); v.add('apbw %03x 3' % LEN); v.cmd(FINAL)
    v.add('poll 060 4 4 20000'); v.add('wait 6')
    v.add('rwin 1'); v.add('rclr'); v.add('axir 1 4'); v.add('wait 6')


@scen('WF-006', 'wf_006_read_empty_underflow', 'main', dict(sig='i_axi_arvalid', edge='rise', n=1, slot=1))
def wf006(v):
    v.sel(1, 2); v.add('wait 6'); v.add('rwin 1'); v.add('rclr'); v.add('axir 2 1'); v.add('wait 6')
    v.add('apbw 0c4 00020000'); v.add('wait 4')


@scen('WF-007', 'wf_007_apb_init_and_nonsecure', 'main', dict(sig='i_apb_psel', edge='rise', n=1, slot=1), clock='i_clk_apb')
def wf007(v):
    v.add('static 1 1'); v.add('wait 6')
    v.add('apbw %03x 1' % CMD); v.add('wait 4')
    v.add('pprot 2'); v.add('apbwerr %03x 1 1' % CMD); v.add('pprot 0'); v.add('wait 4')
    v.add('static 0 1'); v.cmd(ABORT)


@scen('WF-008', 'wf_008_two_contexts_interleaved', 'main', dict(sig='w_core_start', edge='rise', n=1, slot=1))
def wf008(v):
    v.sel(1, 0); v.cmd(INIT); v.add('poll 060 f00 100 2000')
    v.sel(1, 1); v.cmd(INIT); v.add('poll 060 f00 100 2000'); v.add('wait 6')
    v.add('axiw 0 8 %s' % words(v, 8, 0x100)); v.add('axiw 1 8 %s' % words(v, 8, 0x200)); v.add('axiw 0 8 %s' % words(v, 8, 0x300))
    v.add('wait 200')
    v.sel(1, 0); v.cmd(ABORT); v.sel(1, 1); v.cmd(ABORT)


@scen('WF-009', 'wf_009_shake_squeeze', 'main', dict(sig='o_axi_rvalid', edge='rise', n=1, slot=3))
def wf009(v):
    v.sel(12, 0); v.cmd(INIT); v.add('poll 060 f00 100 2000')
    v.add('axiw 0 1 %s' % v.hx(0x636261)); v.add('apbw %03x 3' % LEN); v.cmd(FINAL)
    v.add('poll 060 4 4 20000'); v.add('waitlvl 21 4000'); v.add('rwin 1'); v.add('rclr')
    for _ in range(4):
        v.add('axir 0 5'); v.add('wait 3')
    v.add('wait 80'); v.cmd(ABORT)


@scen('WF-010', 'wf_010_dma_input_handshake', 'dma', dict(sig='o_dma_in_req', edge='rise', n=1, slot=1))
def wf010(v):
    v.add('apbw %03x 00000010' % DMAC)
    v.add('apbw %03x %08x' % (CTRL, ctrl(1, 0, dmaen=1)))
    v.cmd(INIT)
    v.add('waitin')
    v.add('axiw 0 16 %s' % words(v, 16)); v.add('wait 8')
    v.cmd(ABORT)


@scen('WF-011', 'wf_011_dma_output_timeout', 'dma', dict(sig='i_hw_we_sha_irq_raw_tmo', edge='rise', n=1, slot=4))
def wf011(v):
    v.add('apbw %03x %08x' % (DMAC, (3 << 16) | 8))
    v.add('apbw %03x %08x' % (CTRL, ctrl(1, 0, dmaen=1)))
    v.cmd(INIT); v.add('poll 060 f00 100 2000')
    v.add('axiw 0 1 %s' % v.hx(0x636261)); v.add('apbw %03x 3' % LEN); v.cmd(FINAL)
    v.add('poll 060 4 4 20000'); v.add('waitout'); v.add('rwin 1'); v.add('rclr'); v.add('axir 0 8'); v.add('wait 6')
    v.cmd(ABORT)


@scen('WF-012', 'wf_012_fault_response', 'fault', dict(sig='i_hw_we_sha_irq_raw_flt', edge='rise', n=1, slot=4))
def wf012(v):
    v.add('apbw 018 00038111')                # fault detection on, duplicate compare, resp = gate, lock, alarm
    v.sel(1, 0); v.cmd(INIT); v.add('poll 060 f00 100 2000')
    v.add('inj 0 10 5')
    v.add('axiw 0 16 %s' % words(v, 16, 0x900)); v.add('axiw 0 8 %s' % words(v, 8, 0xA00))
    v.add('apbw %03x 0' % LEN); v.cmd(FINAL); v.add('wait 600')


@scen('WF-013', 'wf_013_entropy_request', 'maskent', dict(sig='o_ent_req', edge='rise', n=1, slot=1))
def wf013(v):
    v.add('wait 60')                           # the eight entropy words are taken after the reset; seeded rises after the last one


@scen('WF-014', 'wf_014_abort_zero_reset', 'main', dict(sig='o_sha_cmd_abort', edge='rise', n=1, slot=1))
def wf014(v):
    v.sel(1, 0); v.cmd(INIT); v.add('poll 060 f00 100 2000')
    v.add('axiw 0 8 %s' % words(v, 8)); v.add('wait 4')
    v.cmd(ABORT); v.add('poll 060 3 2 20000'); v.add('wait 4'); v.cmd(SRST); v.add('wait 10')


@scen('WF-015', 'wf_015_reset_release', 'async', dict(sig='i_rst_n_core', edge='fall', n=1, slot=2))
def wf015(v):
    v.add('wait 10'); v.add('rstov'); v.add('wait 12')


@scen('WF-016', 'wf_016_apb_async_write', 'async', dict(sig='i_apb_psel', edge='rise', n=1, slot=4))
def wf016(v):
    v.add('wait 10'); v.add('apbw %03x 00000101' % CTRL); v.add('wait 12')


@scen('WF-017', 'wf_017_final_with_busy_core', 'main', dict(sig='o_sha_cmd_final', edge='rise', n=1, slot=1))
def wf017(v):
    v.sel(1, 0); v.cmd(INIT); v.add('poll 060 f00 100 2000')
    v.add('axiw 0 16 %s' % words(v, 16, 0x500)); v.add('axiw 0 8 %s' % words(v, 8, 0x600))
    v.add('apbw %03x 0' % LEN); v.add('wait 3'); v.cmd(FINAL); v.add('poll 060 4 4 20000'); v.add('wait 6')


@scen('WF-018', 'wf_018_two_block_padding', 'main', dict(sig='w_core_start', edge='rise', n=1, slot=2))
def wf018(v):
    v.sel(1, 0); v.cmd(INIT); v.add('poll 060 f00 100 2000')
    v.add('axiw 0 8 %s' % words(v, 8, 0x700)); v.add('apbw %03x 4' % LEN); v.add('wait 3'); v.cmd(FINAL)
    v.add('poll 060 4 4 20000'); v.add('wait 6')


@scen('WF-019', 'wf_019_ctxsel_while_busy', 'main', dict(sig='w_core_busy', edge='rise', n=1, slot=2))
def wf019(v):
    v.sel(1, 0); v.cmd(INIT); v.add('poll 060 f00 100 2000')
    v.sel(1, 1); v.cmd(INIT); v.add('poll 060 f00 100 2000'); v.sel(1, 0)
    v.add('axiw 0 12 %s' % words(v, 12, 0x800)); v.add('wait 2')
    v.add('apbw %03x %08x' % (CTRL, ctrl(1, 1))); v.add('wait 4')
    v.add('chka %03x f00 000' % STS); v.add('wait 4')


NOT_SIMULATED = {}

CFG = {
    'main': dict(DW=64, CTXN=4, ALG="12'h%03x" % V.algmask(V.ALL_ALGS)),
    'dma': dict(DW=64, CTXN=4, ALG="12'h%03x" % V.algmask(V.ALL_ALGS), DMA=1),
    'fault': dict(DW=64, CTXN=4, ALG="12'h%03x" % V.algmask(V.ALL_ALGS), FDUP=1, ALARM=1),
    'maskent': dict(DW=64, CTXN=2, ALG="12'h%03x" % V.algmask(V.ALL_ALGS), MASK=1, SEEDSRC=0),
    'async': dict(DW=64, CTXN=4, ALG="12'h%03x" % V.algmask(V.ALL_ALGS), ASYNC=1, APBH='20.0'),
}

if __name__ == '__main__':
    os.makedirs(OUT, exist_ok=True)
    plan = {}
    for wf, d in PLAN.items():
        v = T(64)
        d['fn'](v)
        v.add('wait 10')
        v.add('end')
        v.save(os.path.join(OUT, '%s.vec' % d['stem']))
        plan[wf] = {k: d[k] for k in ('stem', 'cfg', 'anchor', 'clock')}
    json.dump(dict(plan=plan, not_simulated=NOT_SIMULATED, cfg=CFG), open(os.path.join(V.VER, 'wf_plan.json'), 'w'), indent=1)
    print('wrote %d scenarios' % len(plan))
