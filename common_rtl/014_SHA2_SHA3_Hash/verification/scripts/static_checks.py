"""Static checks of the specification that need no simulator.
TEST-023 (REQ-DFT-001), structural part: every clock of an always_ff / always @(posedge ...) process of the RTL is a clock port or
a clock signal handed in by a port, and no clock gating cell is instantiated. The scan insertion trial itself needs a DFT tool and
is NOT done here.
TEST-024 (REQ-PD-001), structural part: every port and clock name of the SDC of section 17 exists in the top module, and every
clock port of the top module has a create_clock. The load into an STA tool is NOT done here.
Run: python static_checks.py    Writes reports/static_checks.md; exit 1 on a finding.
"""
import glob
import os
import re
import sys

import vec_lib as V

IP = os.path.dirname(V.VER)
RTL = IP + '/rtl'
SPEC = IP + '/VLSIT_SHA2_SHA3_HASH_HDS.md'


def strip(t):
    t = re.sub(r'/\*.*?\*/', '', t, flags=re.S)
    return re.sub(r'//[^\n]*', '', t)


def main():
    bad = 0
    rows = ['# Static checks (TEST-023, TEST-024)', '']
    # ---- TEST-023
    files = sorted(glob.glob(RTL + '/*.sv') + glob.glob(RTL + '/csr/*.sv'))
    clocks = {}
    gate_hits = []
    for f in files:
        t = strip(open(f, encoding='utf-8').read())
        for m in re.finditer(r'always_ff\s*@\s*\(\s*(?:posedge|negedge)\s+(\w+)', t):
            clocks.setdefault(m.group(1), set()).add(os.path.basename(f))
        for m in re.finditer(r'\b(\w*(?:icg|clkgate|clk_gate|clock_gate|ckg)\w*)\s+\w+\s*\(', t, re.I):
            gate_hits.append((os.path.basename(f), m.group(1)))
    rows += ['## TEST-023 clock structure', '', '| Clock net in an always_ff | Files |', '|---|---|']
    for c, fs in sorted(clocks.items()):
        rows.append('| `%s` | %s |' % (c, ', '.join(sorted(fs))))
    ok_names = {'i_clk_core', 'i_clk_apb', 'i_clk_dst', 'i_clk_src', 'i_clk'}
    other = [c for c in clocks if c not in ok_names and not c.startswith('i_clk')]
    # a derived clock that is a selection by an elaboration parameter between two clock ports is a constant connection, not a gate
    alltext = ' '.join(strip(open(f, encoding='utf-8').read()) for f in files)
    pat = r"assign\s+%s\s*=\s*\(\s*PARA_\w+\s*==\s*32'd\d+\s*\)\s*\?\s*i_clk_\w+\s*:\s*i_clk_\w+\s*;"
    const_sel = [c for c in other if re.search(pat % c, alltext)]
    other = [c for c in other if c not in const_sel]
    rows += ['', 'Clock nets chosen between two clock ports by an elaboration parameter (generated CSR, constant after elaboration): %s.' % (', '.join(const_sel) or 'none'),
             'Clock nets that are not an input clock port and not such a selection: %s.' % (', '.join(other) if other else 'none'),
             'Clock gating cell instances found: %s.' % (', '.join('%s in %s' % (b, a) for a, b in gate_hits) if gate_hits else 'none')]
    if other or gate_hits:
        bad += 1
    rows.append('Result: %s' % ('FAIL' if (other or gate_hits) else 'PASS (structure only; scan insertion not run)'))
    # ---- TEST-024
    spec = open(SPEC, encoding='utf-8').read()
    m = re.search(r'```[a-z]*\n(create_clock.*?)```', spec, re.S)
    sdc = m.group(1) if m else ''
    top = strip(open(RTL + '/m_vlsit_sha_top.sv', encoding='utf-8').read())
    ports = set(re.findall(r'\b(?:input|output)\s+(?:wire|logic)?\s*(?:\[[^\]]*\]\s*)*(\w+)\s*,?\s*$', top, re.M))
    ports |= set(re.findall(r'\b(?:input|output)\s+(?:wire|logic)\s+(?:\[[^\]]*\]\s+)?(\w+)', top))
    used = set()
    for g in re.findall(r'get_ports\s+\{?([^\]}]*)', sdc):
        used |= set(g.split())
    clk_def = set(re.findall(r'create_clock\s+-name\s+(\w+)', sdc))
    clk_used = set(re.findall(r'get_clocks\s+(\w+)', sdc))
    rows += ['', '## TEST-024 SDC of section 17', '', 'Ports named by the SDC: %s. Clocks created: %s.' % (', '.join(sorted(used)), ', '.join(sorted(clk_def))), '']
    miss = sorted(p for p in used if p not in ports)
    undef = sorted(c for c in clk_used if c not in clk_def)
    clkports = sorted(p for p in ports if p.startswith('i_clk_'))
    nocl = sorted(p for p in clkports if p not in used)
    rows += ['Ports of the SDC missing in the top module: %s.' % (', '.join(miss) or 'none'),
             'Clocks used but not created: %s.' % (', '.join(undef) or 'none'),
             'Clock ports of the top without create_clock: %s.' % (', '.join(nocl) or 'none')]
    if not sdc or miss or undef or nocl:
        bad += 1
    rows.append('Result: %s' % ('FAIL' if (not sdc or miss or undef or nocl) else 'PASS (names only; the SDC was not loaded into an STA tool)'))
    open(V.VER + '/reports/static_checks.md', 'w').write('\n'.join(rows) + '\n')
    print('\n'.join(rows))
    return bad


if __name__ == '__main__':
    sys.exit(1 if main() else 0)
