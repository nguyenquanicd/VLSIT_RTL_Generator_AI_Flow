"""Fills the constant tables of the module templates in tpl/ and writes the modules to ../rtl.
Run: python build_rtl.py"""
import os

import sha_consts as C

HERE = os.path.dirname(os.path.abspath(__file__))
OUT = os.path.join(os.path.dirname(HERE), 'rtl')

def case_fn(name, comment, width, vals, idx_w, per_line=1):
    lines = ['  // ' + comment,
             '  function automatic logic [%d:0] %s(input logic [%d:0] i_idx);' % (width - 1, name, idx_w - 1),
             '    case (i_idx)']
    for i, v in enumerate(vals):
        lines.append("      %d'd%d: %s = %d'h%0*x;" % (idx_w, i, name, width, width // 4 if width % 4 == 0 else (width + 3) // 4, v))
    lines.append("      default: %s = '0;" % name)
    lines += ['    endcase', '  endfunction']
    return chr(10).join(lines)


rot_tab = [C.ROT[(i % 5, i // 5)] for i in range(25)]
fills = {
    '@@FK256@@': case_fn('f_k', 'Round constants K0 to K63 of FIPS 180-4 section 4.2.2.', 32, C.K256, 6),
    '@@FK512@@': case_fn('f_k', 'Round constants K0 to K79 of FIPS 180-4 section 4.2.3.', 64, C.K512, 7),
    '@@FRC@@': case_fn('f_rc', 'Round constants RC[0] to RC[23] of FIPS 202 section 3.2.5.', 64, C.RC, 5),
    '@@FROT@@': case_fn('f_rot', 'Rotation offsets of FIPS 202 section 3.2.2 for lane x + 5 y.', 6, rot_tab, 5),
    '@@IV256@@': C.table(C.H256, 32, 4),
    '@@IV224@@': C.table(C.H224, 32, 4),
    '@@IV512@@': C.table(C.H512, 64, 2),
    '@@IV384@@': C.table(C.H384, 64, 2),
    '@@IV512224@@': C.table(C.H512_224, 64, 2),
    '@@IV512256@@': C.table(C.H512_256, 64, 2),
}
tpl = os.path.join(HERE, 'tpl')
for name in sorted(os.listdir(tpl)):
    text = open(os.path.join(tpl, name), encoding='utf-8').read()
    for k, v in fills.items():
        text = text.replace(k, v)
    assert '@@' not in text, name
    with open(os.path.join(OUT, name), 'w', encoding='utf-8', newline='\n') as f:
        f.write(text)
    print('wrote', name)
