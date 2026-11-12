"""Context-count vectors (COV-006, TEST-005): interleaved messages with 2 to N contexts for N = 2, 8, 16 (one context runs the
edge file only). Run: python gen_ctx.py"""
import os

import gen_vectors as G

for n in (2, 8, 16):
    G.multi_file(64, G.SETS['all'], n, 'multi_c%d_dw64.vec' % n, seed=40 + n, rounds=6 if n > 2 else 4)
print('context-count vectors written')
