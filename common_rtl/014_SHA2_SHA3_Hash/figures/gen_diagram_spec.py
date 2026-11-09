"""Writes sha_diagram_spec.json for vlsit_spec_diagram.py (block diagram of m_vlsit_sha_top).
Usage (from this folder): python gen_diagram_spec.py"""
import json
import os

HERE = os.path.dirname(os.path.abspath(__file__))

B = [  # key, instance, module, row, col, function (no signal names)
    ('AXI', 'u_axi', 'm_vlsit_sha_axi_sub', 0, 0, 'AXI4 subordinate. It decodes the context window address, checks burst type, size and strobes, pushes message words, pops digest words and reports window errors.'),
    ('CSR', 'u_csr', 'm_vlsit_csr_sha', 2, 0, 'Generated APB register block. It holds the control, command, security, status and interrupt registers and crosses between the APB clock and the core clock.'),
    ('DMA', 'u_dma', 'm_vlsit_sha_dma', 3, 0, 'External DMA handshake. It raises the input and output requests with the four-phase protocol, counts the burst size and pads a short output burst after a timeout.'),
    ('IRQ', 'u_irq', 'm_vlsit_sha_irq', 4, 0, 'Event capture. It collects the error, done and fault events and drives the interrupt and the alarm outputs.'),
    ('INF', 'u_in_fifo', 'm_vlsit_sha_in_fifo', 0, 1, 'Input FIFOs, one per context. They hold the message words until a block is complete and give backpressure to the AXI4 write channel when full.'),
    ('SEQ', 'u_seq', 'm_vlsit_sha_seq', 1, 1, 'Context sequencer. It owns the state machine of every context, assembles blocks, adds the padding, picks the next ready context by round robin and counts blocks and bytes.'),
    ('CMEM', 'u_ctxmem', 'm_vlsit_sha_ctxmem', 2, 1, 'Context memory. It stores the hash state of every context that is not in a core, in flip-flops or in an SRAM macro.'),
    ('OUTF', 'u_out_fifo', 'm_vlsit_sha_out_fifo', 1, 0, 'Output FIFOs, one per context. They hold the digest words, or the squeezed words of SHAKE, until the AXI4 read channel or the DMA takes them.'),
    ('FLT', 'u_fault', 'm_vlsit_sha_fault', 3, 2, 'Fault detection. It compares duplicate cores, checks parity and compares recomputed blocks, then applies the selected responses.'),
    ('C256', 'u_core256', 'm_vlsit_sha_core256', 1, 2, 'SHA-224 and SHA-256 compression core with a selectable number of rounds per cycle.'),
    ('C512', 'u_core512', 'm_vlsit_sha_core512', 2, 2, 'SHA-384, SHA-512 and SHA-512/t compression core with a selectable number of rounds per cycle.'),
    ('KEC', 'u_keccak', 'm_vlsit_sha_keccak', 3, 1, 'Keccak permutation core for SHA-3 and SHAKE with a selectable number of rounds per cycle.'),
    ('DOM', 'u_keccak_dom', 'm_vlsit_sha_keccak_dom', 4, 1, 'Masked Keccak permutation core. It keeps the state as two shares and uses fresh random bits for each non-linear step.'),
    ('PRNG', 'u_prng', 'm_vlsit_sha_prng', 4, 2, 'Random generator of the masked core, seeded from the entropy input or from the seed words of the register block.'),
]
blocks = [{'key': k, 'label': [i, '(%s)' % m], 'width': max(200, ((10 * len(m) + 80) // 20) * 20), 'row': r, 'col': c, 'row_name': '%s (%s)' % (i, m), 'function': f,
           'source': 'Section 14.2'} for k, i, m, r, c, f in B]

C = [  # id, src, side, dst, side, name, category, active, signals
    ('WRD', 'AXI', 'R', 'INF', 'L', 'Message words from the AXI4 write channel', 'custom', 'u_axi -> u_in_fifo',
     'u_axi -> u_in_fifo: w_in_push, w_in_wdata; u_in_fifo -> u_axi: w_in_full'),
    ('DIG', 'OUTF', 'T', 'AXI', 'B', 'Digest words to the AXI4 read channel', 'custom', 'u_out_fifo -> u_axi',
     'u_out_fifo -> u_axi: w_out_rdata, w_out_empty; u_axi -> u_out_fifo: w_out_pop'),
    ('BLK', 'INF', 'B', 'SEQ', 'T', 'Message words to the sequencer', 'custom', 'u_in_fifo -> u_seq',
     'u_in_fifo -> u_seq: w_in_rdata, w_in_level; u_seq -> u_in_fifo: w_in_pop'),
    ('DGS', 'SEQ', 'L', 'OUTF', 'R', 'Digest words from the sequencer', 'custom', 'u_seq -> u_out_fifo',
     'u_seq -> u_out_fifo: w_out_push, w_out_wdata; u_out_fifo -> u_seq: w_out_full'),
    ('CTX', 'SEQ', 'B', 'CMEM', 'T', 'Context state read and write', 'custom', 'u_seq <-> u_ctxmem',
     'u_seq -> u_ctxmem: w_ctx_wr, w_ctx_wstate, w_ctx_rd; u_ctxmem -> u_seq: w_ctx_rstate'),
    ('S256', 'SEQ', 'R', 'C256', 'L', 'Block and state to the SHA-256 core', 'custom', 'u_seq <-> u_core256',
     'u_seq -> u_core256: w_c256_start, w_c256_block, w_c256_state; u_core256 -> u_seq: w_c256_done, w_c256_result'),
    ('SDOM', 'KEC', 'B', 'DOM', 'T', 'Select of the masked core', 'custom', 'u_keccak -> u_keccak_dom',
     'u_keccak -> u_keccak_dom: w_dom_select'),
    ('RND', 'PRNG', 'L', 'DOM', 'R', 'Random bits to the masked core', 'custom', 'u_prng -> u_keccak_dom',
     'u_prng -> u_keccak_dom: w_rnd_bits, w_rnd_valid'),
]
connectors = [{'id': i, 'src': s, 'src_side': ss, 'dst': d, 'dst_side': ds} for i, s, ss, d, ds, *_ in C]
interfaces = [{'id': i, 'name': n, 'category': cat, 'active': act, 'signals': sig} for i, s, ss, d, ds, n, cat, act, sig in C]

EXT = [  # id, block, side, dir, pos, text, name, category, active, signals
    ('AXIS', 'AXI', 'L', 'in', -10, ['AXIS', 'AXI4 sub'], 'AXI4 subordinate interface (CLK-CORE)', 'standard protocol (AXI4)', 'external manager -> IP',
     'external manager -> IP: i_axi_awvalid, i_axi_awid, i_axi_awaddr, i_axi_awlen, i_axi_awsize, i_axi_awburst, i_axi_wvalid, i_axi_wdata, i_axi_wstrb, i_axi_wlast, i_axi_bready, i_axi_arvalid, i_axi_arid, i_axi_araddr, i_axi_arlen, i_axi_arsize, i_axi_arburst, i_axi_rready; IP -> external manager: o_axi_awready, o_axi_wready, o_axi_bvalid, o_axi_bid, o_axi_bresp, o_axi_arready, o_axi_rvalid, o_axi_rid, o_axi_rdata, o_axi_rresp, o_axi_rlast'),
    ('APB', 'CSR', 'L', 'in', 0, ['APB', 'APB4 cmp'], 'APB4 completer interface (CLK-APB)', 'standard protocol (APB4)', 'external manager -> IP',
     'external manager -> IP: i_apb_psel, i_apb_penable, i_apb_pwrite, i_apb_paddr, i_apb_pwdata, i_apb_pstrb, i_apb_pprot, i_protect_en, i_slverr_en; IP -> external manager: o_apb_pready, o_apb_pslverr, o_apb_prdata'),
    ('DMAH', 'DMA', 'L', 'in', 0, ['DMAH', 'DMA handshake'], 'External DMA handshake (CLK-CORE)', 'custom handshake', 'IP <-> DMA controller',
     'IP -> DMA controller: o_dma_in_req, o_dma_out_req; DMA controller -> IP: i_dma_in_ack, i_dma_out_ack'),
    ('IRQO', 'IRQ', 'L', 'out', 0, ['IRQO', 'Interrupt, alarm'], 'Interrupt and alarm outputs (CLK-CORE)', 'level outputs', 'IP -> SoC',
     'IP -> SoC: o_irq, o_alarm'),
    ('ENT', 'PRNG', 'R', 'in', 0, ['ENT', 'Entropy'], 'Entropy input (CLK-CORE)', 'custom handshake', 'external source <-> IP',
     'external source -> IP: i_ent_valid, i_ent_data; IP -> external source: o_ent_req'),
    ('CRCLK', 'AXI', 'T', 'in', 0, ['CRCLK', 'Clock, reset'], 'Clocks and resets', 'clock and reset', 'SoC -> IP',
     'SoC -> IP: i_clk_core, i_rst_n_core, i_clk_apb, i_rst_n_apb'),
]
externals = [{'id': i, 'block': b, 'side': sd, 'dir': d, 'pos': p, 'text': t} for i, b, sd, d, p, t, *_ in EXT]
interfaces += [{'id': i, 'name': n, 'category': cat, 'active': act, 'signals': sig} for i, b, sd, d, p, t, n, cat, act, sig in EXT]
nets = [{'entry': 'CRCLK', 'sinks': [{'id': 'CK%d' % n, 'block': k, 'side': 'T', 'pos': 0} for n, k in enumerate(['INF'])]}]

spec = {
    'page_name': 'BLOCK_DIAGRAM', 'out_name': 'vlsit_sha_block_diagram.drawio', 'table_suffix': '',
    'layout': {'gap_h': 100, 'gap_v': 90, 'margin': 40, 'block_h': 60},
    'top': {'frame_label': ['TOP', '(m_vlsit_sha_top)'], 'block_label': ['TOP', '(m_vlsit_sha_top)'],
            'block_row': ['TOP (m_vlsit_sha_top)', 'Structural top of the SHA2 and SHA3 hash IP.', 'Section 14.2']},
    'frame_row': ['TOP (m_vlsit_sha_top) frame', 'Structural top of the SHA2 and SHA3 hash IP. It instantiates the blocks below and holds no logic of its own. The AXI4 and register interfaces are on the left, the entropy input on the right.', 'Section 14.2'],
    'frame_interfaces': [e[0] for e in EXT],
    'blocks': blocks, 'connectors': connectors, 'externals': externals, 'nets': nets, 'interfaces': interfaces,
    'legend_note': 'The frame is the top module; blocks are its instances. Optional blocks exist only when their parameter selects them. Clocks and resets reach every block; bus links to the SHA-512 and Keccak cores are in section 5.1.',
}
with open(os.path.join(HERE, 'sha_diagram_spec.json'), 'w', encoding='utf-8', newline='\n') as f:
    json.dump(spec, f, indent=1, ensure_ascii=False)
print('written', len(blocks), 'blocks', len(connectors), 'connectors')
