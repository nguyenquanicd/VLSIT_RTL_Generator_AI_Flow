"""Builds sha_regs.json (register description of the SHA2/SHA3 hash IP) for vlsit_csr_tool.py.

Global registers (capability, control, command, length, DMA, security, seed, status, level, counters, error record,
interrupts). The context select field of sha_ctrl selects the context that the commands, the length register and the
read-back registers refer to. Run: python gen_sha_csr_json.py  (writes sha_regs.json beside this file).
"""
import json
import os

HERE = os.path.dirname(os.path.abspath(__file__))


def desc(first, usage, values, unit, limits):
    vals = []
    for i, (k, m) in enumerate(values):
        vals.append('%s %s%s' % (k, m, '.' if i == len(values) - 1 else ';'))
    return '%s\n\nUsage: %s\n\nValues:\n%s\n\nUnit: %s\n\nLimits: %s' % (first, usage, '\n'.join(vals), unit, limits)


def F(name, bits, typ, reset, first, usage, values, unit='none', limits='none'):
    return {'name': name, 'bits': bits, 'type': typ, 'reset': reset, 'description': desc(first, usage, values, unit, limits)}


def R(name, off, text, fields, repeat=None):
    r = {'name': name, 'offset': off, 'description': text, 'fields': fields}
    if repeat:
        r['repeat'] = repeat
    return r


regs = []
ALGOS = [('0x0', 'SHA-224'), ('0x1', 'SHA-256'), ('0x2', 'SHA-384'), ('0x3', 'SHA-512'), ('0x4', 'SHA-512/224'), ('0x5', 'SHA-512/256'),
         ('0x8', 'SHA3-224'), ('0x9', 'SHA3-256'), ('0xA', 'SHA3-384'), ('0xB', 'SHA3-512'), ('0xC', 'SHAKE128'), ('0xD', 'SHAKE256')]

regs.append(R('sha_cap0', '0x000', 'Capability register 0. Reports the algorithms, contexts and bus width built into this instance.', [
    F('alg', '[11:0]', 'ro', '0x002', 'Built algorithm map. One bit for each hash algorithm; the bit is 1 when that algorithm exists in the hardware.',
      'Read by software before it writes the algorithm field of the control register; a code whose bit is 0 sets the configuration error event.',
      [('0x002', 'only SHA-256 built (reset value)'),
       ('0x001 to 0xFFF', 'bit mask: bit 0 SHA-224, 1 SHA-256, 2 SHA-384, 3 SHA-512, 4 SHA-512/224, 5 SHA-512/256, 6 SHA3-224, 7 SHA3-256, 8 SHA3-384, 9 SHA3-512, 10 SHAKE128, 11 SHAKE256')],
      'mask', 'Constant after elaboration; at least one bit is 1.'),
    F('ctxn', '[20:16]', 'ro', '0x01', 'Number of contexts. Number of independent messages that the IP keeps in progress at the same time, set by the elaboration parameter.',
      'Read by software to know how many interleaved messages it may start and the legal range of the context select field.',
      [('0x01 to 0x10', 'context count (reset value 0x01)')], 'contexts', 'Constant after elaboration; legal values 1 to 16.'),
    F('axiw', '[25:24]', 'ro', '0x1', 'AXI data width code. Width of the AXI4 data bus of the message and digest windows, set by the elaboration parameter.',
      'Read by software to find how many bytes one window beat carries.',
      [('0x0', '32 bits'), ('0x1', '64 bits (reset value)'), ('0x2', '128 bits')], 'code', 'Constant after elaboration.'),
    F('rev', '[31:28]', 'ro', '0x1', 'Register map revision. Version number of this register description.',
      'Read by software to select the driver for this register layout.', [('0x1', 'first revision (reset value)')], 'none', 'Incremented by each incompatible change of the map.'),
]))
regs.append(R('sha_cap1', '0x004', 'Capability register 1. Reports the round unrolling and the optional security and DMA features of this instance.', [
    F('s256unr', '[6:0]', 'ro', '0x01', 'SHA-256 core unrolling. Number of SHA-256 and SHA-224 rounds that the hardware computes in one clock cycle.',
      'Read by software to compute the time per block: 64 divided by this value, times the pipeline factor, plus 2 cycles.',
      [('0x01 to 0x40', 'rounds per cycle (reset value 0x01)')], 'rounds', 'A divisor of 64; zero when no SHA-224 or SHA-256 is built.'),
    F('s512unr', '[14:8]', 'ro', '0x00', 'SHA-512 core unrolling. Number of SHA-384, SHA-512 and SHA-512/t rounds that the hardware computes in one clock cycle.',
      'Read by software to compute the time per block: 80 divided by this value, times the pipeline factor, plus 2 cycles.',
      [('0x00', 'core not built (reset value)'), ('0x01 to 0x50', 'rounds per cycle')], 'rounds', 'A divisor of 80.'),
    F('kecunr', '[20:16]', 'ro', '0x00', 'Keccak core unrolling. Number of Keccak-f[1600] rounds that the hardware computes in one clock cycle.',
      'Read by software to compute the time per block: 24 divided by this value, times the pipeline factor, plus 2 cycles.',
      [('0x00', 'core not built (reset value)'), ('0x01 to 0x18', 'rounds per cycle')], 'rounds', 'A divisor of 24.'),
    F('fdup', '[24]', 'ro', '0x0', 'Duplicate-core detection built in. Indicates that a second copy of each core runs in parallel and its results are compared.',
      'Read by software before it sets the duplicate detection field of the security register.', [('0x0', 'not built (reset value)'), ('0x1', 'built')]),
    F('fpar', '[25]', 'ro', '0x0', 'Parity detection built in. Indicates that parity bits protect the state registers and the context memory.',
      'Read by software before it sets the parity detection field of the security register.', [('0x0', 'not built (reset value)'), ('0x1', 'built')]),
    F('fredo', '[26]', 'ro', '0x0', 'Recompute detection built in. Indicates that every block can be computed twice and the results compared.',
      'Read by software before it sets the recompute detection field of the security register.', [('0x0', 'not built (reset value)'), ('0x1', 'built')]),
    F('mask', '[27]', 'ro', '0x0', 'Masked Keccak built in. Indicates that the Keccak core runs on two shares with random masking of the first order.',
      'Read by software before it sets the mask enable field of the control register.', [('0x0', 'not built (reset value)'), ('0x1', 'built')]),
    F('zero', '[28]', 'ro', '0x1', 'State clearing built in. Indicates that the context memory, the FIFOs and the core registers can be cleared.',
      'Read by software before it relies on the clear command or on the automatic clearing.', [('0x0', 'not built'), ('0x1', 'built (reset value)')]),
    F('dma', '[29]', 'ro', '0x0', 'External DMA handshake built in. Indicates that the request and acknowledge ports of an external DMA controller are active.',
      'Read by software before it sets the DMA enable field of the control register.', [('0x0', 'not built (reset value)'), ('0x1', 'built')]),
    F('sdsrc', '[30]', 'ro', '0x0', 'Mask seed source. Selects where the random generator of the masked Keccak core gets its seed: the entropy input port or the seed registers.',
      'Read by software to know whether it has to write the seed registers and give the seed command.',
      [('0x0', 'entropy input port (reset value)'), ('0x1', 'seed registers written by software')], 'none', 'Meaningful only when masked Keccak is built.'),
]))

regs.append(R('sha_ctrl', '0x008', 'Control register. Enables the IP and selects the algorithm and the context for the next commands.', [
    F('en', '[0]', 'rw', '0x0', 'IP enable. Enables the datapath; when 0 the sequencer starts no new block and the windows still accept data.',
      'Program it after the algorithm is chosen; clearing it while a block runs lets that block finish and holds the next ones.',
      [('0x0', 'disabled (reset value)'), ('0x1', 'enabled')]),
    F('algo', '[11:8]', 'rw', '0x1', 'Algorithm select. Chooses the hash algorithm that the init command loads into the selected context.',
      'Program it before the init command; changing it later does not change a message in progress.',
      [(k, v + (' (reset value)' if k == '0x1' else '')) for k, v in ALGOS], 'code',
      'The other codes are reserved. A code whose bit is 0 in the capability register is rejected with the configuration error event.'),
    F('ctxsel', '[20:16]', 'rw', '0x00', 'Context select. Selects the context that the commands, the length register and the status, level and counter registers refer to.',
      'Program it before every command that concerns one context; it does not change the window address, which carries the context number.',
      [('0x00 to 0x0F', 'context number (reset value 0x00)')], 'none',
      'Must be below the context count of the capability register; a larger value sets the configuration error event.'),
    F('mask', '[24]', 'rw', '0x0', 'Mask enable. Runs the Keccak algorithms on two shares with random masking when the masked Keccak core is built.',
      'Program it while no SHA-3 or SHAKE message is in progress; it applies to the messages started afterwards.',
      [('0x0', 'unmasked Keccak (reset value)'), ('0x1', 'masked Keccak')], 'none', 'Ignored when the capability register reports no masked Keccak.'),
    F('dmaen', '[25]', 'rw', '0x0', 'External DMA enable. Lets the IP raise the request signals of the external DMA handshake for the input and output windows.',
      'Program it when a DMA controller moves the message and the digest; clear it when software writes the windows.',
      [('0x0', 'handshake off (reset value)'), ('0x1', 'handshake on')], 'none', 'Ignored when the capability register reports no DMA handshake.'),
]))

CMDS = [
    ('init', '[0]', 'Initialization command. Starts a new message in the selected context: loads the initial hash value or clears the Keccak state, and clears the length counter and the FIFOs of that context.',
     'Rejected with the configuration error event when the algorithm is not built or the context is busy.'),
    ('final', '[1]', 'Final command. Tells the IP that the last word of the message has been written; it adds the padding and finishes the message of the selected context.',
     'Write the length register first; rejected with the configuration error event when the context is not in the absorbing state.'),
    ('abort', '[2]', 'Abort command. Drops the message of the selected context, clears its FIFOs and state and returns it to the free state.', 'none'),
    ('srst', '[3]', 'Soft reset command. Clears all contexts, FIFOs, cores and the error record and keeps the control, security and DMA registers.', 'none'),
    ('clear', '[4]', 'Clear command. Writes zero into the context memory, the FIFOs and the core registers of the selected context without changing the algorithm field.',
     'Ignored when the capability register reports no state clearing.'),
    ('seed', '[5]', 'Seed command. Loads the random generator of the masked Keccak core from the seed words that software wrote.',
     'Accepted only when the seed source of the capability register is the seed registers.'),
]
regs.append(R('sha_cmd', '0x00C', 'Command register. Holds the one-shot commands of the IP.', [
    F(n, b, 'rwi', '0x0', first,
      'Software writes 1 to start the action; hardware clears the bit when the action has been accepted or completed. Do not write the register again while a bit is set.',
      [('0x0', 'no action (reset value)'), ('0x1', 'start the action')], 'none', limit) for n, b, first, limit in CMDS]))

regs.append(R('sha_len', '0x010', 'Length register. Gives the number of valid bytes of the last word of the message in the selected context.', [
    F('tail', '[7:0]', 'rw', '0x00', 'Valid bytes of the last word. Number of bytes of the last word written to the input window that belong to the message; the other bytes are ignored.',
      'Write it before the final command; software always writes full words, so the last word carries the message bytes in its low lanes.',
      [('0x00', 'all bytes of the last word are valid (reset value)'), ('0x01 to 0x7F', 'valid bytes, below the bytes of one word')], 'bytes',
      'Must be below the bytes of one AXI word; a larger value sets the configuration error event.'),
]))
regs.append(R('sha_dmac', '0x014', 'DMA control register. Holds the burst size and the burst timeout of the external DMA handshake.', [
    F('burst', '[8:0]', 'rw', '0x10', 'Burst size. Number of AXI words in one burst of the external DMA handshake; a request is raised when the input FIFO can take or the output FIFO can give this many words.',
      'Program it while no message runs to match the burst length configured in the DMA controller.',
      [('0x001 to 0x100', 'words per burst (reset value 0x010)')], 'AXI words',
      'Zero and values above 0x100 are illegal; the request is then not raised and the configuration error event is set.'),
    F('tmo', '[31:16]', 'rw', '0x0', 'Burst timeout. Number of clock cycles without new digest words after which a short output burst is padded with zeros and requested.',
      'Program it when the digest is shorter than one burst; the number of valid words is reported in the valid words register.',
      [('0x0000', 'timeout disabled (reset value)'), ('0x0001 to 0xFFFF', 'timeout in clock cycles')], 'clock cycles', 'none'),
]))
regs.append(R('sha_sec', '0x018', 'Security register. Enables state clearing, the fault detection mechanisms and the responses to a detected fault.', [
    F('zero', '[0]', 'rw', '0x1', 'Automatic clearing enable. Clears the state of a context after its digest has been read or the message has been aborted, and holds the core registers at zero while idle.',
      'Enable it to limit the retention of message-dependent data in idle registers. It is not a side-channel countermeasure.',
      [('0x0', 'off'), ('0x1', 'on (reset value)')], 'none', 'Ignored when state clearing is not built.'),
    F('fault', '[4]', 'rw', '0x0', 'Fault detection enable. Turns on the detection mechanisms selected by the duplicate, parity and recompute fields.',
      'Set it while no message runs, after choosing the mechanisms.', [('0x0', 'off (reset value)'), ('0x1', 'on')]),
    F('fdup', '[8]', 'rw', '0x0', 'Duplicate-core detection select. Compares the output of each core with the output of its duplicate.',
      'Set it only when the capability register reports duplicate detection as built.', [('0x0', 'not selected (reset value)'), ('0x1', 'selected')]),
    F('fpar', '[9]', 'rw', '0x0', 'Parity detection select. Checks the parity bits of the core state registers and the context memory.',
      'Set it only when the capability register reports parity detection as built.', [('0x0', 'not selected (reset value)'), ('0x1', 'selected')]),
    F('fredo', '[10]', 'rw', '0x0', 'Recompute detection select. Computes every block twice and compares the two results; the throughput halves.',
      'Set it only when the capability register reports recompute detection as built.', [('0x0', 'not selected (reset value)'), ('0x1', 'selected')]),
    F('resp', '[19:16]', 'rw', '0x3', 'Fault response select. Bit 0 gates the digest and output words until soft reset; bit 1 locks the IP until soft reset; bit 2 clears all context state; bit 3 raises the alarm output.',
      'Program it while no message runs; the fault event and interrupt are always raised.',
      [('0x0 to 0xF', 'mask of the active responses (reset value 0x3)')], 'mask', 'Bit 3 has an effect only when the alarm output is built.'),
]))
regs.append(R('sha_seed', '0x020', 'Seed register. Write-only words of the seed of the random generator of the masked Keccak core.', [
    F('wd', '[31:0]', 'wo', '0x0', 'Seed word. One 32-bit word of the seed; reads return zero and the hardware clears the word after the seed command has copied it.',
      'Write the eight words before the seed command; used only when the seed source of the capability register is the seed registers.',
      [('0x00000000 to 0xFFFFFFFF', 'seed word (reset value 0x00000000)')], 'none', 'Eight words are used.')],
    repeat={'mode': 'PARAMETERIZED', 'count': 8, 'stride': '0x4', 'max': 16}))

regs.append(R('sha_sts', '0x060', 'Status register. Reports the state of the IP and of the selected context.', [
    F('busy', '[0]', 'ro', '0x0', 'IP busy. A block is being computed or a message waits for the core.',
      'Poll it to know when the IP is idle before the soft reset command.', [('0x0', 'idle (reset value)'), ('0x1', 'busy')]),
    F('idle', '[1]', 'ro', '0x1', 'IP idle. No block is in a core and no word waits in an input FIFO.',
      'Use it as the condition for changing the security and the control registers.', [('0x0', 'not idle'), ('0x1', 'idle (reset value)')]),
    F('ready', '[2]', 'ro', '0x0', 'Digest ready. The digest of the selected context has been computed and its first words are in the output FIFO.',
      'Poll it after the final command, or use the done event.', [('0x0', 'not ready (reset value)'), ('0x1', 'ready')]),
    F('locked', '[3]', 'ro', '0x0', 'IP locked. A fault response locked the IP until the soft reset command.',
      'Give the soft reset command to clear it.', [('0x0', 'not locked (reset value)'), ('0x1', 'locked')]),
    F('dmaact', '[4]', 'ro', '0x0', 'DMA active. The external DMA handshake has a request raised or an acknowledge pending.',
      'Read for diagnosis.', [('0x0', 'no DMA activity (reset value)'), ('0x1', 'DMA activity')]),
    F('seeded', '[5]', 'ro', '0x0', 'Random generator seeded. The random generator of the masked Keccak core has a valid seed.',
      'Wait for 1 before the first masked SHA-3 or SHAKE message.', [('0x0', 'not seeded (reset value)'), ('0x1', 'seeded')], 'none',
      'Meaningful only when masked Keccak is built.'),
    F('cstate', '[11:8]', 'ro', '0x0', 'Context state. State of the selected context.', 'Read it after an error to see where the message stopped.',
      [('0x0', 'free (reset value)'), ('0x1', 'absorbing message words'), ('0x2', 'padding and last blocks'), ('0x3', 'digest ready'),
       ('0x4', 'squeezing output (SHAKE)'), ('0xF', 'locked by a fault')]),
]))
regs.append(R('sha_lvl', '0x064', 'FIFO level register. Reports the fill level of the FIFOs of the selected context.', [
    F('inlvl', '[15:0]', 'ro', '0x0000', 'Input FIFO level. Number of AXI words in the input FIFO of the selected context.',
      'Read before writing words into the window to avoid dropped words.',
      [('0x0000 to 0xFFFF', 'words in the FIFO (reset value 0x0000)')], 'AXI words', 'Bounded by the input FIFO depth parameter.'),
    F('outlvl', '[31:16]', 'ro', '0x0000', 'Output FIFO level. Number of AXI words in the output FIFO of the selected context.',
      'Read before reading the window to avoid reading zeros.',
      [('0x0000 to 0xFFFF', 'words in the FIFO (reset value 0x0000)')], 'AXI words', 'Bounded by the output FIFO depth parameter.'),
]))
regs.append(R('sha_blk', '0x068', 'Block counter register. Counts the blocks that the cores have processed for the selected context.', [
    F('cnt', '[31:0]', 'ro', '0x0', 'Processed blocks. Number of compression or permutation blocks computed for the message in the selected context since its init command.',
      'Read after an error or an abort to find where the message stopped.',
      [('0x00000000 to 0xFFFFFFFF', 'block count (reset value 0x00000000)')], 'blocks',
      'Cleared by the init, abort and soft reset commands; wraps at the maximum value.')]))
regs.append(R('sha_byte', '0x06C', 'Byte counter register. Counts the message bytes absorbed for the selected context.', [
    F('cnt', '[31:0]', 'ro', '0x0', 'Absorbed bytes. Low 32 bits of the number of message bytes written for the message in the selected context since its init command.',
      'Read to check the length of a stream against the expected length before the final command.',
      [('0x00000000 to 0xFFFFFFFF', 'byte count (reset value 0x00000000)')], 'bytes',
      'Cleared by the init, abort and soft reset commands; wraps at the maximum value.')]))
regs.append(R('sha_dvld', '0x070', 'Valid words register. Reports the valid words of the last padded external DMA output burst.', [
    F('words', '[8:0]', 'ro', '0x000', 'Valid words of the last burst. Number of real digest or output words in the last output burst that was padded with zeros after a timeout.',
      'Read it after the DMA timeout event to discard the padding words.',
      [('0x000 to 0x100', 'valid words (reset value 0x000)')], 'AXI words', 'Zero means that no burst was padded.')]))
regs.append(R('sha_err', '0x074', 'Error information register. Records the latest window error of the IP.', [
    F('ctx', '[4:0]', 'ro', '0x00', 'Error context. Context number of the latest window error.', 'Read after an overflow or underflow event.',
      [('0x00 to 0x0F', 'context number (reset value 0x00)')]),
    F('kind', '[11:8]', 'ro', '0x0', 'Error kind. Kind of the latest window error.', 'Read after an overflow, underflow, AXI or length event.',
      [('0x0', 'no error (reset value)'), ('0x1', 'write to a full input window dropped'), ('0x2', 'read of an empty output window returned zero'),
       ('0x3', 'access to the wrong window direction'), ('0x4', 'unsupported AXI transaction rejected with SLVERR'),
       ('0x5', 'message length limit exceeded')]),
    F('ovf', '[19:12]', 'ro', '0x00', 'Overflow count. Number of dropped writes since the last soft reset; saturates at 255.',
      'Read to judge how much data was lost.', [('0x00 to 0xFF', 'dropped writes (reset value 0x00)')], 'events', 'Saturating.'),
    F('udf', '[27:20]', 'ro', '0x00', 'Underflow count. Number of reads of an empty window since the last soft reset; saturates at 255.',
      'Read to judge how many zero words software received.', [('0x00 to 0xFF', 'empty reads (reset value 0x00)')], 'events', 'Saturating.'),
]))
regs.append(R('sha_erra', '0x078', 'Error address register. Records the low 32 bits of the AXI address of the latest window error.', [
    F('addr', '[31:0]', 'ro', '0x0', 'Error address. Low 32 bits of the AXI address that caused the latest window error.',
      'Read together with the error information register.',
      [('0x00000000 to 0xFFFFFFFF', 'AXI address (reset value 0x00000000)')], 'bytes')]))

IRQ = [('cdone', '[15:0]', 'context done', 'The message of the context whose bit number is set has finished: its digest is ready, or for a SHAKE message its first output block is ready.'),
       ('ovf', '[16]', 'FIFO overflow', 'A write to a full input FIFO window was dropped.'),
       ('udf', '[17]', 'FIFO underflow', 'A read of an empty output FIFO window returned zero.'),
       ('axi', '[18]', 'AXI error', 'The AXI4 subordinate rejected an unsupported transaction with SLVERR.'),
       ('cfg', '[19]', 'configuration error', 'A command or a register value was rejected: algorithm not built, context busy or out of range, or an illegal length or burst.'),
       ('flt', '[20]', 'fault detected', 'A fault detection mechanism found a mismatch and the responses of the security register were applied.'),
       ('ent', '[21]', 'entropy starved', 'The masked Keccak core needed random bits and the random generator had no valid seed or entropy.'),
       ('tmo', '[22]', 'DMA timeout', 'The burst timer expired and a short output burst was padded with zeros.'),
       ('len', '[23]', 'length limit', 'A message exceeded the maximum length of 2 to the power 61 minus 1 bytes.')]
for suffix, typ, text in [('irq_raw', 'w1c', 'Raw interrupt register. Holds the sticky events of the IP.'),
                          ('irq_en', 'rw', 'Interrupt enable register. Enables each event to raise the interrupt outputs.'),
                          ('irq_inj', 'rw', 'Interrupt injection register. Injects events for software tests.'),
                          ('irq_sts', 'ro', 'Masked interrupt status register. Shows the enabled events that are pending.')]:
    o = {'irq_raw': 0xC0, 'irq_en': 0xC4, 'irq_inj': 0xC8, 'irq_sts': 0xCC}[suffix]
    flds = []
    for n, bits, lname, meaning in IRQ:
        multi = n == 'cdone'
        cap = lname[0].upper() + lname[1:]
        if suffix == 'irq_raw':
            first = '%s event. %s' % (cap, meaning)
            use = 'Hardware sets the bit when the event happens; software writes 1 to clear it. A hardware set in the same cycle as a clear wins.'
            vals = [('0x0', 'no event (reset value)'), ('0x1', 'event pending')] if not multi else [('0x0000', 'no event (reset value)'), ('0x0001 to 0xFFFF', 'bit mask of the contexts that finished')]
        elif suffix == 'irq_en':
            first = '%s enable. Lets the %s event raise the interrupt output.' % (cap, lname)
            use = 'Set it after the event handler is ready; the raw event is recorded whatever its value.'
            vals = [('0x0', 'event masked (reset value)'), ('0x1', 'event enabled')] if not multi else [('0x0000', 'all masked (reset value)'), ('0x0001 to 0xFFFF', 'bit mask of the contexts whose done event is enabled')]
        elif suffix == 'irq_inj':
            first = '%s injection. A rising edge of this bit sets the raw %s event once.' % (cap, lname)
            use = 'Write 1 then write 0 before the next injection; used to test the handler.'
            vals = [('0x0', 'no injection (reset value)'), ('0x1', 'inject the event')] if not multi else [('0x0000', 'no injection (reset value)'), ('0x0001 to 0xFFFF', 'bit mask of the contexts to inject')]
        else:
            first = '%s status. The %s event is pending and enabled.' % (cap, lname)
            use = 'Read it in the interrupt handler to find the cause; it is the raw event AND the enable.'
            vals = [('0x0', 'not pending (reset value)'), ('0x1', 'pending')] if not multi else [('0x0000', 'none pending (reset value)'), ('0x0001 to 0xFFFF', 'bit mask of the contexts pending')]
        flds.append(F(n, bits, typ, '0x0', first, use, vals, 'none', 'Bits above the context count are always 0.' if multi else 'none'))
    regs.append(R('sha_' + suffix, '0x%03X' % o, text, flds))

doc = {'module': 'm_vlsit_csr_sha', 'prefix': 'sha', 'async': 1, 'registers': regs}
path = os.path.join(HERE, 'sha_regs.json')
with open(path, 'w', encoding='utf-8', newline='\n') as f:
    json.dump(doc, f, indent=1, ensure_ascii=False)
print(len(regs), 'registers written to', path)
