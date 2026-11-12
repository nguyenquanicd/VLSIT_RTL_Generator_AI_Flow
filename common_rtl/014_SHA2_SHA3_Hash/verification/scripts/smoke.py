import sys, time
import simlib as S
import vec_lib as V
name = sys.argv[1]; vecs = sys.argv[2].split(','); dw = int(sys.argv[3]); ctxn = int(sys.argv[4]); algs = [int(x) for x in sys.argv[5].split(',')]
cls = sys.argv[6] if len(sys.argv) > 6 else 'ff'
extra = dict(a.split('=') for a in sys.argv[7:])
p = dict(DW=dw, CTXN=ctxn, ALG="12'h%03x" % V.algmask(algs)); p.update(extra)
import os
exe = os.path.join(S.WORK, name, 'obj', 'Vsim.exe')
if not os.path.exists(exe) or os.environ.get('REBUILD'):
    t = time.time(); exe = S.build(name, p, coverage=False, trace=False); print('build %.0fs' % (time.time() - t))
for vec in vecs:
    t = time.time()
    rc, out = S.run(exe, name, S.VER + '/vec/' + vec, ['+CLASSES=' + cls] + os.environ.get('PLUS','').split(), logname=S.VER + '/work/%s_%s.log' % (name, vec))
    print('== %s run %.0fs rc=%d' % (vec, time.time() - t, rc), S.summarize(out))
    print('\n'.join(l for l in out.split('\n') if 'SB FAIL' in l or 'ERROR' in l or 'ASSERT FAIL' in l or 'NEVER' in l)[:3500])
