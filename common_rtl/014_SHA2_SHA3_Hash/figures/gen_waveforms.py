"""Writes the WaveJSON sources (WF-001..WF-019) of the SHA2/SHA3 hash IP and renders them to SVG.
Usage (from this folder): python gen_waveforms.py
The waves are design intent from sections 6.3, 10.2 and 11 of the specification, not simulation output."""
import json
import os
import subprocess
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
TOOL = r'C:\Users\PC\.claude\skills\vlsit-asic-ip-microspec\scripts\vlsit_waveform_svg.py'

CLK = ('i_clk_core', 'p')
W = {}
NOTES = {}


def wf(wid, fname, head, foot, n, groups):
    W[wid] = (fname, head, foot, n, groups)


def s(name, wave, data=None):
    return (name, wave, data)


wf('WF-001', 'wf_001_axi_write_burst', 'Write burst of 4 words to the message window of context 1 (64-bit bus)',
   'Cycle 2: AW handshake. Cycles 3 to 6: four W beats, wstrb all ones, wlast on the fourth. Level counts the words in the input FIFO of context 1.', 12, [
    ('', [s(*CLK, None) if False else s('i_clk_core', 'p')]),
    ('AXI4 write address', [s('i_axi_awvalid', '01.0'), s('o_axi_awready', '0.10'), s('i_axi_awaddr', 'x=.x', ['C1 MSG']),
                            s('i_axi_awlen', 'x=.x', ['3']), s('i_axi_awburst', 'x=.x', ['INCR'])]),
    ('AXI4 write data', [s('i_axi_wvalid', '0..1...0'), s('o_axi_wready', '0..1...0'), s('i_axi_wdata', 'x..====x', ['W0', 'W1', 'W2', 'W3']),
                         s('i_axi_wstrb', 'x..=...x', ['FF']), s('i_axi_wlast', '0..0..10')]),
    ('AXI4 write response', [s('o_axi_bvalid', '0.......10'), s('i_axi_bready', '1'), s('o_axi_bresp', 'x.......=x', ['OKAY'])]),
    ('FIFO', [s('i_sha_lvl_inlvl', '=...====', ['0', '1', '2', '3', '4'])]),
])
wf('WF-002', 'wf_002_axi_write_error', 'Write burst with a partial write strobe is rejected with SLVERR',
   'Beat 2 has wstrb 0F: both beats are accepted and dropped, bresp is SLVERR, error kind 4 is recorded and the AXI error event is raised.', 12, [
    ('', [s('i_clk_core', 'p')]),
    ('AXI4 write', [s('i_axi_awvalid', '01.0'), s('o_axi_awready', '0.10'), s('i_axi_awlen', 'x=.x', ['1']),
                    s('i_axi_wvalid', '0..110'), s('o_axi_wready', '0..110'), s('i_axi_wdata', 'x..==x', ['W0', 'W1']),
                    s('i_axi_wstrb', 'x..==x', ['FF', '0F']), s('i_axi_wlast', '0...10')]),
    ('response', [s('o_axi_bvalid', '0.....10'), s('i_axi_bready', '1'), s('o_axi_bresp', 'x.....=x', ['SLVERR'])]),
    ('error record', [s('i_hw_we_sha_irq_raw_axi', '0.....10'), s('i_sha_err_kind', '=.....=', ['0', '4']),
                      s('o_sha_irq_raw_axi', '0......1'), s('o_irq', '0.......1')]),
])
wf('WF-003', 'wf_003_fifo_full_backpressure', 'Input FIFO full: o_axi_wready low until the sequencer pops a word',
   'Example FIFO of 3 words. The FIFO is full in cycles 5 to 7 so wready is low and W3 is held; the pop in cycle 7 frees a place and W3 is accepted in cycle 8. No word is dropped.', 12, [
    ('', [s('i_clk_core', 'p')]),
    ('AXI4 write data', [s('i_axi_wvalid', '0.1.....0'), s('o_axi_wready', '1....0..10'), s('i_axi_wdata', 'x.====...x', ['W0', 'W1', 'W2', 'W3'])]),
    ('FIFO of the context', [s('w_in_full', '0....1..01'), s('r_in_pop', '0......10'), s('i_sha_lvl_inlvl', '=..===..==', ['0', '1', '2', '3', '2', '3'])]),
])
wf('WF-004', 'wf_004_final_digest_ready', 'Final command, padding and digest ready of a short SHA-256 message',
   'Cycles 4 to 8 stand for the 66 cycles of one SHA-256 block at UNR 1 (not to scale). The short message fits in one padded block.', 12, [
    ('', [s('i_clk_core', 'p')]),
    ('command', [s('o_sha_len_tail', '=', ['5']), s('o_sha_cmd_final', '01.0'), s('i_hw_we_sha_cmd_final', '0.10')]),
    ('sequencer and core', [s('r_ctx_state', '=..=.....=', ['ABSORBING', 'FINALIZING', 'DIGEST_READY']), s('w_pad_last', '0.10'),
                            s('w_core_busy', '0..1.....0')]),
    ('result', [s('i_hw_we_sha_irq_raw_cdone', '0........10'), s('o_sha_irq_raw_cdone', '0.........1'), s('i_sha_sts_ready', '0.........1'),
                s('i_sha_lvl_outlvl', '=.........=', ['0', '4']), s('o_irq', '0.........1')]),
])
wf('WF-005', 'wf_005_digest_read_burst', 'Read burst of the 4-word digest from the digest window of context 1',
   'The read data are the 4 digest words in standard byte order; the output FIFO level falls with each beat and the context becomes FREE after the last word.', 12, [
    ('', [s('i_clk_core', 'p')]),
    ('AXI4 read address', [s('i_axi_arvalid', '01.0'), s('o_axi_arready', '0.10'), s('i_axi_araddr', 'x=.x', ['C1 DIG']), s('i_axi_arlen', 'x=.x', ['3'])]),
    ('AXI4 read data', [s('o_axi_rvalid', '0...1...0'), s('i_axi_rready', '1'), s('o_axi_rdata', 'x...====x', ['D0', 'D1', 'D2', 'D3']),
                        s('o_axi_rlast', '0...0..10'), s('o_axi_rresp', 'x...=...x', ['OKAY'])]),
    ('FIFO', [s('i_sha_lvl_outlvl', '=....====', ['4', '3', '2', '1', '0'])]),
])
wf('WF-006', 'wf_006_read_empty_underflow', 'Read of an empty digest window returns zero and raises the underflow event',
   'The read completes with OKAY and data 0; error kind 2 is recorded and software learns of it from the underflow event.', 10, [
    ('', [s('i_clk_core', 'p')]),
    ('AXI4 read', [s('i_axi_arvalid', '01.0'), s('o_axi_arready', '0.10'), s('i_axi_araddr', 'x=.x', ['C2 DIG']), s('i_axi_arlen', 'x=.x', ['0']),
                   s('o_axi_rvalid', '0...10'), s('i_axi_rready', '1'), s('o_axi_rdata', 'x...=x', ['0']), s('o_axi_rlast', '0...10'),
                   s('o_axi_rresp', 'x...=x', ['OKAY'])]),
    ('error record', [s('i_sha_lvl_outlvl', '=', ['0']), s('i_hw_we_sha_irq_raw_udf', '0...10'), s('i_sha_err_kind', '=....=', ['0', '2']),
                      s('o_irq', '0....1')]),
])
wf('WF-007', 'wf_007_apb_init_and_nonsecure', 'APB write of the init command, then a non-secure write rejected with PSLVERR',
   'First write (PPROT[1] = 0): accepted, o_sha_cmd_init is raised and cleared by hardware. Second write (PPROT[1] = 1) with i_protect_en and i_slverr_en = 1: PSLVERR, no change. Delays follow the clock ratio (11.4).', 14, [
    ('', [s('i_clk_apb', 'p'), s('i_protect_en', '1'), s('i_slverr_en', '1')]),
    ('APB4 request', [s('i_apb_psel', '01..0.1..0'), s('i_apb_penable', '0.1.0..1.0'), s('i_apb_pwrite', 'x1..x.1..x'),
                      s('i_apb_pprot', 'x0..x.1..x', None), s('i_apb_paddr', 'x=..x.=..x', ['sha_cmd', 'sha_cmd']),
                      s('i_apb_pwdata', 'x=..x.=..x', ['init', 'init'])]),
    ('APB4 response', [s('o_apb_pready', '0..10...10'), s('o_apb_pslverr', '0.......10')]),
    ('register', [s('o_sha_cmd_init', '0...1..0')]),
])
wf('WF-008', 'wf_008_two_contexts_interleaved', 'Two contexts interleaved on one core: state read and written around each block',
   'The core runs a block of context 0, then of context 1, then of context 0 again. The context memory is read before and written after each block. ctxsel changes while the core is busy without disturbing it.', 14, [
    ('', [s('i_clk_core', 'p')]),
    ('core', [s('w_core_start', '01...1...1'), s('w_core_ctx', 'x=...=...=...x', ['0', '1', '0'])]),
    ('context memory', [s('w_ctxmem_rd', '10..10..10'), s('w_ctxmem_wr', '0....10..10..1')]),
    ('software', [s('o_sha_ctrl_ctxsel', '=.....=', ['0', '1'])]),
])
wf('WF-009', 'wf_009_shake_squeeze', 'SHAKE128 output of more than one block: the next block is squeezed when the FIFO has room',
   'Example numbers: FIFO of 32 words, a block of 21 words. Reads (each pulse stands for a burst of 5 words, not to scale) lower the level; at level 11 the next squeeze starts and the level returns to 32.', 14, [
    ('', [s('i_clk_core', 'p')]),
    ('context', [s('r_ctx_state', '=.=.=', ['FINALIZING', 'DIGEST_READY', 'SQUEEZING']), s('w_squeeze_start', '0......10'),
                 s('w_keccak_busy', '0......1...0..')]),
    ('output', [s('o_axi_rvalid', '0..1010'), s('i_sha_lvl_outlvl', '=.=.=.=.....=', ['0', '21', '16', '11', '32'])]),
])
wf('WF-010', 'wf_010_dma_input_handshake', 'External DMA input channel: 4-phase request and acknowledge, then the burst is written',
   'req rises, ack rises, req falls, ack falls. The DMA controller then writes the burst of sha_dmac.burst words to the message window as ordinary AXI4 writes.', 12, [
    ('', [s('i_clk_core', 'p'), s('o_sha_dmac_burst', '=', ['16'])]),
    ('handshake', [s('o_dma_in_req', '01..0'), s('i_dma_in_ack', '0..1..0')]),
    ('AXI4 write of the burst', [s('i_axi_awvalid', '0....1.0'), s('o_axi_awready', '0.....10'), s('i_axi_wvalid', '0.......1')]),
])
wf('WF-011', 'wf_011_dma_output_timeout', 'External DMA output channel: timeout pads a short digest burst with zeros',
   'The digest has 3 words, the burst is 4. The timer reaches sha_dmac.tmo = 3, the request is raised, the 4th word is zero padding and sha_dvld.words reports 3.', 14, [
    ('', [s('i_clk_core', 'p'), s('o_sha_dmac_burst', '=', ['4']), s('o_sha_dmac_tmo', '=', ['3'])]),
    ('timer and event', [s('r_tmo_cnt', '====', ['0', '1', '2', '3']), s('i_hw_we_sha_irq_raw_tmo', '0...10'), s('i_sha_dvld_words', '=....=', ['0', '3'])]),
    ('handshake', [s('o_dma_out_req', '0...1..0'), s('i_dma_out_ack', '0.....1..0')]),
    ('AXI4 read of the burst', [s('o_axi_rvalid', '0.......1...0'), s('o_axi_rdata', 'x.......====x', ['D0', 'D1', 'D2', 'PAD'])]),
])
wf('WF-012', 'wf_012_fault_response', 'Duplicate-core mismatch: gate, lock and alarm responses',
   'A fault makes core A differ from its duplicate B. The mismatch is registered in cycle 3; the responses (gate, lock, alarm) are active in cycle 4 and the lock stays until the soft reset command.', 12, [
    ('', [s('i_clk_core', 'p')]),
    ('cores', [s('w_core_a_out', '=.=', ['H', "H'"]), s('w_core_b_out', '=', ['H']), s('w_mismatch', '0.1'), s('r_mismatch', '0..1')]),
    ('responses', [s('w_digest_gate', '0...1'), s('i_sha_sts_locked', '0...1'), s('i_sha_sts_cstate', '=...=', ['1', 'F']),
                   s('o_alarm', '0...1'), s('i_hw_we_sha_irq_raw_flt', '0...10'), s('o_irq', '0....1')]),
])
wf('WF-013', 'wf_013_entropy_request', 'Masked core takes seed words from the entropy port',
   'o_ent_req is held until i_ent_valid; words 3 to 8 are not shown. After the eighth word the PRNG is seeded and the status bit is set.', 14, [
    ('', [s('i_clk_core', 'p')]),
    ('entropy port', [s('o_ent_req', '01..01...0'), s('i_ent_valid', '0..10...10'), s('i_ent_data', 'x..=x...=x', ['E0', 'E1'])]),
    ('status', [s('i_sha_sts_seeded', '0............1')]),
])
wf('WF-014', 'wf_014_abort_zero_reset', 'Abort of a context with clearing, then the soft reset command',
   'Abort: the context returns to FREE, its FIFO is emptied and, with sha_sec.zero = 1, the core registers are zeroed within 3 cycles. The soft reset command then clears all contexts.', 14, [
    ('', [s('i_clk_core', 'p')]),
    ('abort', [s('o_sha_cmd_abort', '01.0'), s('i_hw_we_sha_cmd_abort', '0.10'), s('r_ctx_state', '=..=', ['ABSORBING', 'FREE']),
               s('i_sha_lvl_inlvl', '=..=', ['8', '0'])]),
    ('clearing', [s('w_zero_active', '0..1..0'), s('r_core_reg', '=....=', ['H', '0'])]),
    ('soft reset', [s('o_sha_cmd_srst', '0......1.0'), s('i_hw_we_sha_cmd_srst', '0.......10')]),
])
wf('WF-015', 'wf_015_reset_release', 'Reset assertion and synchronized release in the core and APB domains',
   'Assertion is asynchronous and immediate; release is synchronized to the clock of the domain. During reset the outputs are 0.', 12, [
    ('', [s('i_clk_core', 'p'), s('i_clk_apb', 'p')]),
    ('core domain', [s('i_rst_n_core', '1.0...1'), s('w_rst_n_core_sync', '1.0.....1'), s('o_axi_awready', '1.0......1'), s('o_irq', '1.0')]),
    ('APB domain', [s('i_rst_n_apb', '1...0....1'), s('w_rst_n_apb_sync', '1...0......1')]),
])
wf('WF-016', 'wf_016_apb_async_write', 'APB write with asynchronous clocks (ratio 1:4): PREADY waits for the core domain',
   'i_clk_apb is drawn with a period of 4 cells and i_clk_core with 1 cell. The request crosses to the core domain, the register changes there and PREADY returns after the response crosses back; software waits for PREADY.', 16, [
    ('clocks', [s('i_clk_apb', '1.0.1.0.1.0.1.0.'), s('i_clk_core', 'p')]),
    ('APB4', [s('i_apb_psel', '0...1........0'), s('i_apb_penable', '0.......1....0'), s('i_apb_pwdata', 'x...=........x', ['W']),
              s('o_apb_pready', '0..........1.0')]),
    ('core domain', [s('w_core_req_sync', '0.......10'), s('o_sha_ctrl_en', '0........1')]),
])
wf('WF-017', 'wf_017_final_with_busy_core', 'Final command while the core is busy and the input FIFO still holds words',
   'The command is accepted in cycle 2 and the context becomes FINALIZING at once; the remaining 24 words wait until the core is free in cycle 8, then the padded block starts.', 12, [
    ('', [s('i_clk_core', 'p')]),
    ('command', [s('o_sha_cmd_final', '01.0'), s('r_ctx_state', '=..=', ['ABSORBING', 'FINALIZING'])]),
    ('core and FIFO', [s('w_core_busy', '1.......0'), s('i_sha_lvl_inlvl', '=.......=', ['24', '0']), s('w_pad_start', '0.......10')]),
    ('result', [s('i_hw_we_sha_irq_raw_cdone', '0..........1')]),
])
wf('WF-018', 'wf_018_two_block_padding', 'Message whose last block leaves no room for the length: two final blocks',
   'sha_len.tail leaves 60 bytes of 64 used. The first final block holds the data and the 0x80 byte; the second holds zeros and the 64-bit length (REQ-FUNC-004).', 14, [
    ('', [s('i_clk_core', 'p')]),
    ('input', [s('o_sha_len_tail', '=', ['60'])]),
    ('sequencer', [s('r_ctx_state', '=.=.........=.', ['ABSORBING', 'FINALIZING', 'DIGEST_READY']), s('w_blk_kind', 'x.=....=', ['LAST+80', 'LENGTH']),
                   s('w_core_start', '0.10...10'), s('w_core_busy', '0..1...01...0')]),
    ('result', [s('i_hw_we_sha_irq_raw_cdone', '0...........10'), s('o_sha_irq_raw_cdone', '0............1')]),
])
wf('WF-019', 'wf_019_ctxsel_while_busy', 'Changing the selected context while the core is busy',
   'Software selects context 1 in cycle 4; the status and level registers then show context 1 (one cycle later) while the core goes on with the block of context 0.', 12, [
    ('', [s('i_clk_core', 'p')]),
    ('core', [s('w_core_busy', '0.1.....0'), s('w_core_ctx', 'x.=.....x', ['0'])]),
    ('software', [s('o_sha_ctrl_ctxsel', '=...=', ['0', '1']), s('i_sha_lvl_inlvl', '=....=', ['12', '3']), s('i_sha_sts_cstate', '=....=', ['1', '0'])]),
])

for wid, (fname, head, foot, n, groups) in W.items():
    signal = []
    for gname, sigs in groups:
        items = []
        for name, wave, data in sigs:
            if len(wave) > n:
                sys.exit('%s: wave of %s longer than %d' % (wid, name, n))
            if wave not in ('p', '1', '=') or len(wave) > 1 or name.startswith('i_clk') is False:
                pass
            w = wave if name.startswith('i_clk') else wave + '.' * (n - len(wave))
            if name.startswith('i_clk') and wave == 'p':
                w = 'p' + '.' * (n - 1)
            if name.startswith('i_clk') and len(wave) > 1:
                w = wave[:n]
            d = data or []
            if w.count('=') != len(d):
                sys.exit('%s: %s has %d "=" but %d data' % (wid, name, w.count('='), len(d)))
            e = {'name': name, 'wave': w}
            if d:
                e['data'] = d
            items.append(e)
        signal.append(items if not gname else [gname] + items)
    flat = []
    for g in signal:
        if g and isinstance(g[0], str):
            flat.append(g)
        else:
            flat.extend(g)
    short = foot.split('. ')[0].rstrip('.')
    if len(short) > 105:
        short = short[:102].rsplit(' ', 1)[0] + ' ...'
    NOTES[wid] = {'file': fname, 'head': head, 'note': foot}
    doc = {'signal': flat, 'head': {'text': '%s: %s' % (wid, head)}, 'foot': {'text': short}}
    jp = os.path.join(HERE, fname + '.json')
    json.dump(doc, open(jp, 'w', encoding='utf-8', newline='\n'), indent=1, ensure_ascii=False)
    r = subprocess.run([sys.executable, TOOL, 'render', jp, '--out', os.path.join(HERE, fname + '.svg'), '--cell', '48', '--force'],
                       capture_output=True, text=True)
    print(wid, 'OK' if r.returncode == 0 else 'FAIL', (r.stdout + r.stderr).strip()[:200])
with open(os.path.join(HERE, 'wf_notes.json'), 'w', encoding='utf-8') as fh:
    json.dump(NOTES, fh, indent=1, ensure_ascii=False)
