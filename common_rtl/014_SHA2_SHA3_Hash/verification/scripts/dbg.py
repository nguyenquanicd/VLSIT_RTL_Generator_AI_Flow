import sys, os, time
import simlib as S, vec_lib as V
name='m%dt'%int(os.environ.get('DBGDW','64')); algs=list(range(0,6))+list(range(8,14))
DW=int(os.environ.get('DBGDW','64')); p=dict(DW=DW,CTXN=4,ALG="12'h%03x"%V.algmask(algs))
p.update(dict(a.split('=') for a in os.environ.get('XP','').split() if a))
exe=os.path.join(S.WORK,name,'obj','Vsim.exe')
if not os.path.exists(exe): exe=S.build(name,p,coverage=False,trace=True)
vec=sys.argv[1]; vcd=S.WORK+'/'+name+'/dbg.vcd'
rc,out=S.run(exe,name,S.VER+'/vec/'+vec,['+CLASSES=df','+TIMEOUT_NS=1500000','+VCD='+vcd],logname=S.WORK+'/dbg.log')
print(rc, S.summarize(out)); print(os.path.getsize(vcd))
