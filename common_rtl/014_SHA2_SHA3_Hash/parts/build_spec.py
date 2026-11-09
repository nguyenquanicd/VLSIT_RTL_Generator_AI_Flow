"""Assembles VLSIT_SHA2_SHA3_HASH_HDS.md from parts p1..p3 and the 11.3 table built from csr/sha_regs.json."""
import json
import os

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.dirname(HERE)
regs = json.load(open(os.path.join(ROOT, 'csr', 'sha_regs.json'), encoding='utf-8'))['registers']

DIR = {'ro': 'status in', 'rw': 'control out', 'wo': 'control out (write-only, hardware clear)',
       'rwi': 'hardware load (command)', 'w1c': 'hardware set (event)'}
SIG = {
    'sha_cap0.alg': 'LPARA_ALG_MAP derived from the `PARA_EN_*` parameters',
    'sha_cap0.ctxn': '`PARA_CTX_N`', 'sha_cap0.axiw': 'code of `PARA_AXI_DW`', 'sha_cap0.rev': 'constant 1',
    'sha_cap1.s256unr': '`PARA_S256_UNR` (0 when no SHA-224 or SHA-256)', 'sha_cap1.s512unr': '`PARA_S512_UNR` (0 when no SHA-512 type)',
    'sha_cap1.kecunr': '`PARA_KEC_UNR` (0 when no SHA-3 type)', 'sha_cap1.fdup': '`PARA_FAULT_DUP`', 'sha_cap1.fpar': '`PARA_FAULT_PAR`',
    'sha_cap1.fredo': '`PARA_FAULT_REDO`', 'sha_cap1.mask': '`PARA_MASK`', 'sha_cap1.zero': '`PARA_ZERO`', 'sha_cap1.dma': '`PARA_DMA`',
    'sha_cap1.sdsrc': '`PARA_SEED_SRC`',
    'sha_ctrl.en': 'Enable of `m_vlsit_sha_seq`', 'sha_ctrl.algo': 'Algorithm code to `m_vlsit_sha_seq`',
    'sha_ctrl.ctxsel': 'Selected context of `m_vlsit_sha_seq`', 'sha_ctrl.mask': 'Mask enable to `m_vlsit_sha_keccak_dom` select',
    'sha_ctrl.dmaen': 'Enable of `m_vlsit_sha_dma`',
    'sha_len.tail': 'Valid bytes of the last word to `m_vlsit_sha_pad`',
    'sha_dmac.burst': 'Burst size of `m_vlsit_sha_dma`', 'sha_dmac.tmo': 'Burst timer limit of `m_vlsit_sha_dma`',
    'sha_sec.zero': 'Automatic clearing enable of `m_vlsit_sha_seq`', 'sha_sec.fault': 'Enable of `m_vlsit_sha_fault`',
    'sha_sec.fdup': 'Select of the duplicate compare', 'sha_sec.fpar': 'Select of the parity check',
    'sha_sec.fredo': 'Select of the recompute compare', 'sha_sec.resp': 'Response mask of `m_vlsit_sha_fault`',
    'sha_seed.wd': 'Seed word n to `m_vlsit_sha_prng`',
    'sha_sts.busy': 'Busy flag of `m_vlsit_sha_seq`', 'sha_sts.idle': 'Idle flag of `m_vlsit_sha_seq`',
    'sha_sts.ready': 'Digest-ready flag of the selected context', 'sha_sts.locked': 'Lock flag of `m_vlsit_sha_fault`',
    'sha_sts.dmaact': 'Activity flag of `m_vlsit_sha_dma`', 'sha_sts.seeded': 'Seeded flag of `m_vlsit_sha_prng`',
    'sha_sts.cstate': 'State of the selected context',
    'sha_lvl.inlvl': 'Level of the input FIFO of the selected context', 'sha_lvl.outlvl': 'Level of the output FIFO of the selected context',
    'sha_blk.cnt': 'Block counter of the selected context', 'sha_byte.cnt': 'Byte counter (low 32 bits) of the selected context',
    'sha_dvld.words': 'Valid-word count of `m_vlsit_sha_dma`',
    'sha_err.ctx': 'Context of the latest window error', 'sha_err.kind': 'Kind of the latest window error',
    'sha_err.ovf': 'Overflow count', 'sha_err.udf': 'Underflow count', 'sha_erra.addr': 'AXI address of the latest window error',
}
CMD_NOTE = 'one command; hardware loads 0 when the action is accepted or done'
EV = {'cdone': 'context done (one bit per context)', 'ovf': 'window overflow', 'udf': 'window underflow', 'axi': 'AXI error',
      'cfg': 'configuration error', 'flt': 'fault detected', 'ent': 'entropy starved', 'tmo': 'DMA timeout', 'len': 'length limit'}

rows = []
for r in regs:
    for f in r['fields']:
        if f['name'] == 'reserved':
            continue
        key = '%s.%s' % (r['name'], f['name'])
        t = f['type']
        reg = r['name']
        if reg == 'sha_cmd':
            sig = 'Command `%s` to `m_vlsit_sha_seq`' % f['name']
            note = CMD_NOTE
        elif reg.startswith('sha_irq_'):
            what = EV[f['name']]
            if reg == 'sha_irq_raw':
                sig, note = 'Event set: %s, from `m_vlsit_sha_irq`' % what, 'Set by hardware, cleared by software write 1; a new event wins over a clear'
            elif reg == 'sha_irq_en':
                sig, note = 'Enable of %s' % what, 'Software level'
            elif reg == 'sha_irq_inj':
                sig, note = 'Injection of %s into the raw register' % what, 'A rising edge sets the raw bit once'
            else:
                sig, note = 'Pending and enabled %s to `o_irq`' % what, 'raw AND enable'
        else:
            sig = SIG.get(key, key)
            note = {'ro': 'Constant or level of the core domain', 'rw': 'Static while software does not write it',
                    'wo': 'Held one clock; the IP clears it after use'}.get(t, '')
            if reg in ('sha_sts', 'sha_lvl', 'sha_blk', 'sha_byte', 'sha_dvld', 'sha_err', 'sha_erra'):
                note = 'Level of the core domain; value of the context chosen by `sha_ctrl.ctxsel` where it is per context'
            if reg.startswith('sha_cap'):
                note = 'Constant after elaboration'
        rows.append('| `%s` | %s | %s | CLK-CORE (register clock) | %s |' % (key, DIR[t], sig, note))

table = '| Workbook register.field | Direction at the CSR | Design signal | Clock domain of the signal | Behavior notes |\n|---|---|---|---|---|\n' + '\n'.join(rows) + '\n'

parts = [open(os.path.join(HERE, p), encoding='utf-8').read() for p in ('p1.md', 'p2.md', 'p3.md')]
import re
notes = json.load(open(os.path.join(ROOT, 'figures', 'wf_notes.json'), encoding='utf-8'))
text = '\n'.join(parts).replace('@@CSR_TABLE@@', table)
for wid, n in notes.items():
    pat = re.compile(r'(\| %s \|[^\n]*?)\| Not drawn \| Pending \|' % re.escape(wid))
    link = '| ![%s](figures/%s.svg) (source `figures/%s.json`) | 2026-11-09 |' % (wid, n['file'], n['file'])
    text = pat.sub(lambda m: m.group(1) + link, text, count=1)
lines = ['**Waveform notes.**', '']
for wid, n in notes.items():
    lines.append('- **%s** (%s): %s' % (wid, n['head'], n['note']))
text = text.replace('@@WF_NOTES@@', '\n'.join(lines))
out = os.path.join(ROOT, 'VLSIT_SHA2_SHA3_HASH_HDS.md')
open(out, 'w', encoding='utf-8', newline='\n').write(text)
print('wrote', out, len(text.splitlines()), 'lines,', len(rows), 'CSR rows')
