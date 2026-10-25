"""Small VCD -> annotated SVG waveform renderer (top-module signals only)."""
import os, json

class Vcd:
    def __init__(self, path):
        self.ids, scope, self.vals, t = {}, [], {}, 0
        scale = 0.1
        for line in open(path):
            s = line.strip()
            if s.startswith('$timescale'):
                pass
            if s.startswith('$scope'): scope.append(s.split()[2])
            elif s.startswith('$upscope'): scope.pop()
            elif s.startswith('$var') and len(scope) == 1:
                p = s.split(); self.ids.setdefault(p[4], (p[3], int(p[2])))
            elif s.startswith('#'): t = int(s[1:])
            elif s and s[0] in '01xz' and not s.startswith('$'): self.vals.setdefault(s[1:], []).append((t, s[0]))
            elif s.startswith('b'):
                v, i = s[1:].split(); self.vals.setdefault(i, []).append((t, v))
        self.tick_ns = None
    def set_tick(self, ns): self.tick_ns = ns
    def width(self, n): return self.ids[n][1]
    def series(self, n):
        return [(a * self.tick_ns, v) for a, v in self.vals.get(self.ids[n][0], [])]
    def at(self, n, tt):
        cur = 'x'
        for a, v in self.series(n):
            if a <= tt + 1e-9: cur = v
            else: break
        return cur
    def tmax(self): return max(a for v in self.vals.values() for a, _ in v) * self.tick_ns
    def change(self, n, to=None, after=-1.0, cond=None):
        """first time (> after) the signal takes value 'to' (int, or 'x' for any unknown); cond(prev_value_int)"""
        prev = None
        for a, v in self.series(n):
            if a > after + 1e-9:
                ok = False
                if to == 'x': ok = 'x' in v
                else: ok = num(v) == to
                if ok and (cond is None or cond(num(prev) if prev is not None else None)): return a
            prev = v
        return None

def num(v):
    try: return int(v, 2)
    except Exception: return None

COL = {'w': ('#1f5fbf', '#dbe8ff'), 'r': ('#c25a00', '#ffe6cc'), 'm': ('#2b8a3e', '#d3f9d8'), 's': ('#7048e8', '#e5dbff')}

def render(vcd, rows, t0, t1, scale, out, title, events, markers, note=''):
    LW, RH, TOP = 168, 22, 54
    W = LW + int((t1 - t0) * scale) + 20
    H = TOP + len(rows) * RH + 34
    X = lambda tt: LW + (tt - t0) * scale
    o = [f'<svg xmlns="http://www.w3.org/2000/svg" width="{W}" height="{H}" font-family="Segoe UI, Arial, sans-serif" font-size="11">',
         f'<rect width="{W}" height="{H}" fill="#ffffff"/>',
         f'<text x="8" y="16" font-size="14" font-weight="bold" fill="#222">{title}</text>']
    step = 50 if (t1 - t0) > 250 else (20 if (t1 - t0) > 100 else 10)
    tick = int(t0 // step * step)
    while tick <= t1:
        if tick >= t0:
            o.append(f'<line x1="{X(tick):.1f}" y1="{TOP-6}" x2="{X(tick):.1f}" y2="{H-30}" stroke="#ececec"/>')
            o.append(f'<text x="{X(tick):.1f}" y="{TOP-10}" text-anchor="middle" fill="#888">{tick}</text>')
        tick += step
    o.append(f'<text x="{W-6}" y="16" text-anchor="end" fill="#888">time in ns</text>')
    y = TOP
    for r in rows:
        label, sig, kind, dom = r[0], r[1], r[2], r[3]
        if sig is None:
            o.append(f'<rect x="0" y="{y}" width="{W}" height="{RH}" fill="#f1f1f1"/><text x="8" y="{y+15}" font-weight="bold" fill="#444">{label}</text>')
            y += RH; continue
        stroke, fill = COL[dom]
        o.append(f'<text x="8" y="{y+15}" fill="#222">{label}</text>')
        hi, lo = y + 4, y + RH - 4
        ser = vcd.series(sig)
        pts = [(t0, vcd.at(sig, t0))] + [(a, v) for a, v in ser if t0 < a <= t1] + [(t1, None)]
        if kind in ('bit', 'clk'):
            d, prev = [], None
            for (a, v), (b, _) in zip(pts[:-1], pts[1:]):
                yy = hi if v == '1' else lo
                d.append(f'M{X(a):.1f},{yy}' if prev is None else f'L{X(a):.1f},{prev} L{X(a):.1f},{yy}')
                prev = yy; d.append(f'L{X(b):.1f},{yy}')
            o.append(f'<path d="{" ".join(d)}" fill="none" stroke="{stroke}" stroke-width="1.5"/>')
        else:
            for (a, v), (b, _) in zip(pts[:-1], pts[1:]):
                n = num(v); wd = vcd.width(sig)
                if kind == 'enum': txt = r[4].get(n, '?') if n is not None else 'x'
                elif kind == 'dec': txt = str(n) if n is not None else 'x'
                elif kind == 'hex': txt = format(n, '0%dx' % max(1, (wd + 3) // 4)) if n is not None else 'x'
                else: txt = format(n, '0%db' % wd) if n is not None else 'x'
                x1, x2 = X(a), X(b)
                if x2 - x1 < 1: continue
                bad = n is None
                f = '#ffc9c9' if bad else fill; st = '#e03131' if bad else stroke
                o.append(f'<path d="M{x1+3:.1f},{hi} L{x2-3:.1f},{hi} L{x2:.1f},{(hi+lo)/2} L{x2-3:.1f},{lo} L{x1+3:.1f},{lo} L{x1:.1f},{(hi+lo)/2} Z" fill="{f}" stroke="{st}"/>')
                if x2 - x1 > 7 * len(txt) + 6:
                    o.append(f'<text x="{(x1+x2)/2:.1f}" y="{y+15}" text-anchor="middle" fill="#111">{txt}</text>')
        y += RH
    for k in markers:
        tt = events.get(k)
        if tt is None or tt < t0 or tt > t1: continue
        o.append(f'<line x1="{X(tt):.1f}" y1="{TOP-4}" x2="{X(tt):.1f}" y2="{H-30}" stroke="#d6336c" stroke-dasharray="4,3"/>')
        o.append(f'<circle cx="{X(tt):.1f}" cy="{TOP-24}" r="9" fill="#d6336c"/><text x="{X(tt):.1f}" y="{TOP-20}" text-anchor="middle" fill="#fff" font-weight="bold">{k}</text>')
    o.append(f'<text x="{LW}" y="{H-10}" fill="#555">{note or "numbers = events of the table next to the figure; red bus = unknown (X)"}</text>')
    o.append('</svg>')
    os.makedirs(os.path.dirname(out), exist_ok=True)
    open(out, 'w', encoding='utf-8').write('\n'.join(o))
    return W, H
