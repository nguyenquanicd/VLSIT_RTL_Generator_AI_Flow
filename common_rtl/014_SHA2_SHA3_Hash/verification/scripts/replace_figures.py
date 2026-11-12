"""Replaces the figures of the specification by the simulated waveforms of waveforms_sim/ (rows without an RTL net removed).
The sketches are kept in figures/spec_sketch/. Run after wf_tool.py. All simulated waveforms (WF-001 to WF-019) are replaced."""
import glob, json, os, shutil, subprocess, sys
IP = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
IP = os.path.dirname(IP)
SV = 'C:/Users/PC/.claude/skills/vlsit-asic-ip-microspec/scripts/vlsit_waveform_svg.py'
os.makedirs(IP + '/figures/spec_sketch', exist_ok=True)
for jp in sorted(glob.glob(IP + '/verification/waveforms_sim/wf_0*.json')):
    stem = os.path.basename(jp)[:-5]
    if stem.endswith('_diff'):
        continue
    d = json.load(open(jp))
    def clean(sig):
        out = []
        for e in sig:
            if isinstance(e, list): out.append([e[0]] + clean(e[1:]))
            elif '(no RTL net)' not in e['name']: out.append(e)
        return out
    d['signal'] = clean(d['signal'])
    d['head'] = {'text': '%s: simulation of the RTL (verification/waveforms_sim)' % stem[:6].upper().replace('_', '-')}
    for ext in ('json', 'svg'):
        src = IP + '/figures/%s.%s' % (stem, ext)
        dst = IP + '/figures/spec_sketch/%s.%s' % (stem, ext)
        if os.path.exists(src) and not os.path.exists(dst): shutil.copy(src, dst)
    json.dump(d, open(IP + '/figures/%s.json' % stem, 'w'), indent=1)
    subprocess.run([sys.executable, '-I', SV, 'render', IP + '/figures/%s.json' % stem, '--out', IP + '/figures/%s.svg' % stem, '--force'], capture_output=True)
    print('replaced', stem)
