"""Draw the waveform of the CDC seed-1 failure from a failing VCD (AXI3, AW channel FIFO) and print the facts used in the analysis.

Usage: python gen_cdc_skew_waveform.py <failing.vcd> <fifo instance path> <out.svg> [t_lo_ps t_hi_ps]
Example (from this folder):
  python gen_cdc_skew_waveform.py ../waveforms_sim/failed_meta_axi3_seed1.vcd u_vlsit_axi3_async_aw cdc_skew_waveform.svg 120000 190000
Every value in the picture is read from the VCD; nothing is typed in by hand.
"""
import sys

vcd, inst, out = sys.argv[1], sys.argv[2], sys.argv[3]
lo = int(sys.argv[4]) if len(sys.argv) > 4 else 120000
hi = int(sys.argv[5]) if len(sys.argv) > 5 else 190000

pref = "tb_axi_bridge.dut.%s.u_vlsit_afifo_top." % inst
want = {
    "clk_wr": pref + "u_vlsit_afifo_wr.i_clk_wr",
    "clk_rd": pref + "u_vlsit_afifo_rd.i_clk_rd",
    "wgray": pref + "u_vlsit_afifo_wr.reg_wgray",
    "d0": pref + "u_vlsit_afifo_rd.u_sync_wr_gray.gen_bit_cell[0].u_vlsit_afifo_cell_sync.i_d",
    "d1": pref + "u_vlsit_afifo_rd.u_sync_wr_gray.gen_bit_cell[1].u_vlsit_afifo_cell_sync.i_d",
    "d2": pref + "u_vlsit_afifo_rd.u_sync_wr_gray.gen_bit_cell[2].u_vlsit_afifo_cell_sync.i_d",
    "q0": pref + "u_vlsit_afifo_rd.u_sync_wr_gray.gen_bit_cell[0].u_vlsit_afifo_cell_sync.o_q",
    "q1": pref + "u_vlsit_afifo_rd.u_sync_wr_gray.gen_bit_cell[1].u_vlsit_afifo_cell_sync.o_q",
    "q2": pref + "u_vlsit_afifo_rd.u_sync_wr_gray.gen_bit_cell[2].u_vlsit_afifo_cell_sync.o_q",
    "wgray_s": pref + "u_vlsit_afifo_rd.w_wgray_s",
    "rgray": pref + "u_vlsit_afifo_rd.reg_rgray",
    "empty_n": pref + "u_vlsit_afifo_rd.w_empty_n",
}
tb_valid = "tb_axi_bridge.o_axi_" + inst.split("_")[-1] + "valid"
tb_ready = "tb_axi_bridge.i_axi_" + inst.split("_")[-1] + "ready"
want["dst_valid"] = tb_valid
want["dst_ready"] = tb_ready

# ---- parse the VCD (only the wanted signals) -------------------------------------------------------------
scope, ids, hdr = [], {}, True
tr = {k: [] for k in want}
cur = 0
rev = {v: k for k, v in want.items()}
with open(vcd, errors="ignore") as f:
    for line in f:
        line = line.strip()
        if hdr:
            if line.startswith("$scope"):
                scope.append(line.split()[2])
            elif line.startswith("$upscope"):
                scope.pop()
            elif line.startswith("$var"):
                p = line.split()
                name = ".".join(scope + [p[4]])
                if name in rev:
                    ids.setdefault(p[3], []).append(rev[name])
            elif line.startswith("$enddefinitions"):
                hdr = False
            continue
        if not line:
            continue
        if line[0] == "#":
            cur = int(line[1:])
            continue
        if line[0] == "b":
            v, i = line[1:].split()
        else:
            v, i = line[0], line[1:]
        for k in ids.get(i, []):
            tr[k].append((cur, v))
missing = [k for k in want if not tr[k]]
if missing:
    sys.exit("signals not found in the VCD: %s" % missing)


def at(k, t):
    v = tr[k][0][1]
    for tt, vv in tr[k]:
        if tt <= t:
            v = vv
        else:
            break
    return v


def edges(k, a, b):
    return [(t, v) for t, v in tr[k] if a <= t <= b]


# ---- facts -----------------------------------------------------------------------------------------------
print("write Gray pointer changes (reg_wgray):")
for t, v in edges("wgray", lo, hi):
    print("  %7.1f ns  %s" % (t / 1000.0, v))
for b in "012":
    print("sync input bit %s (i_d) / output bit %s (o_q) changes:" % (b, b))
    print("  in :", ["%.0f=%s" % (t / 1000.0, v) for t, v in edges("d" + b, lo, hi)])
    print("  out:", ["%.0f=%s" % (t / 1000.0, v) for t, v in edges("q" + b, lo, hi)])
print("synchronized pointer w_wgray_s:", ["%.0f=%s" % (t / 1000.0, v) for t, v in edges("wgray_s", lo, hi)])
print("read Gray pointer reg_rgray   :", ["%.0f=%s" % (t / 1000.0, v) for t, v in edges("rgray", lo, hi)])
print("w_empty_n:", ["%.0f=%s" % (t / 1000.0, v) for t, v in edges("empty_n", lo, hi)])
print("dst valid:", ["%.0f=%s" % (t / 1000.0, v) for t, v in edges("dst_valid", lo, hi)])
print("dst ready (value at start, changes):", at("dst_ready", lo), ["%.0f=%s" % (t / 1000.0, v) for t, v in edges("dst_ready", lo, hi)])
print("reg_rgray value at start:", at("rgray", lo))

# ---- SVG -------------------------------------------------------------------------------------------------
W, LBL, RIGHT = 1180, 230, 20
RH, TOP = 34, 70
x0, x1 = LBL, W - RIGHT
rows = [
    ("clk_wr", "i_clk_wr (10 ns)", "clk"),
    ("wgray", "reg_wgray [2:0] (write)", "bus"),
    ("d0", "sync bit0 input", "bit"),
    ("q0", "sync bit0 output", "bit"),
    ("d1", "sync bit1 input", "bit"),
    ("q1", "sync bit1 output", "bit"),
    ("d2", "sync bit2 input", "bit"),
    ("q2", "sync bit2 output", "bit"),
    ("clk_rd", "i_clk_rd (14 ns)", "clk"),
    ("wgray_s", "w_wgray_s [2:0] (read side)", "bus"),
    ("rgray", "reg_rgray [2:0] (read)", "bus"),
    ("empty_n", "w_empty_n  (= wgray_s == rgray)", "bit"),
    ("dst_valid", "o_axi_awvalid (destination)", "bit"),
    ("dst_ready", "i_axi_awready (destination)", "bit"),
]
H = TOP + RH * len(rows) + 120


def X(t):
    return x0 + (min(max(t, lo), hi) - lo) * (x1 - x0) / float(hi - lo)


s = []
s.append('<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 %d %d" width="%d" font-family="Consolas, Menlo, monospace" font-size="12">' % (W, H, W))
s.append('<rect width="100%" height="100%" fill="#ffffff"/>')
s.append('<text x="10" y="22" font-size="15" font-weight="bold">AXI3 AW channel FIFO, metastability seed 1: a Gray pointer code that never existed</text>')
s.append('<text x="10" y="42" fill="#444">Read from %s, instance %s. Time axis in ns.</text>' % (vcd.replace("\\", "/").split("/")[-1], inst))

# time grid
t = (lo // 10000) * 10000
while t <= hi:
    if t >= lo:
        s.append('<line x1="%.1f" y1="%d" x2="%.1f" y2="%d" stroke="#e3e3e3"/>' % (X(t), TOP - 8, X(t), TOP + RH * len(rows)))
        s.append('<text x="%.1f" y="%d" text-anchor="middle" fill="#666">%d</text>' % (X(t), TOP - 14, t // 1000))
    t += 10000

HI, LOW = 6, RH - 8
for r, (k, label, kind) in enumerate(rows):
    y = TOP + r * RH
    s.append('<text x="%d" y="%.1f" text-anchor="end" fill="#111">%s</text>' % (x0 - 8, y + RH / 2 + 4, label))
    pts = [(lo, at(k, lo))] + [(tt, vv) for tt, vv in tr[k] if lo < tt <= hi]
    if kind in ("clk", "bit"):
        path = []
        prev = None
        for tt, vv in pts:
            yy = y + (HI if vv == "1" else LOW)
            if prev is None:
                path.append("M%.1f,%.1f" % (X(tt), yy))
            else:
                path.append("L%.1f,%.1f L%.1f,%.1f" % (X(tt), prev, X(tt), yy))
            prev = yy
        path.append("L%.1f,%.1f" % (x1, prev))
        col = "#888" if kind == "clk" else "#1f5fbf"
        if k.startswith("q"):
            col = "#c0392b"
        if k == "empty_n":
            col = "#c0392b"
        s.append('<path d="%s" fill="none" stroke="%s" stroke-width="1.6"/>' % (" ".join(path), col))
    else:
        for i, (tt, vv) in enumerate(pts):
            ta = tt
            tb = pts[i + 1][0] if i + 1 < len(pts) else hi
            xa, xb = X(ta), X(tb)
            s.append('<polygon points="%.1f,%d %.1f,%d %.1f,%d %.1f,%d %.1f,%d %.1f,%d" fill="#f4f6fa" stroke="#555"/>' % (
                xa + 3, y + RH / 2, xa + 7, y + HI, xb - 7, y + HI, xb - 3, y + RH / 2, xb - 7, y + LOW + 2, xa + 7, y + LOW + 2))
            if xb - xa > 34:
                s.append('<text x="%.1f" y="%.1f" text-anchor="middle">%s</text>' % ((xa + xb) / 2, y + RH / 2 + 4, vv.zfill(3)))

# marker lines come from the data: write changes of bit1 and bit0, the moment w_wgray_s equals reg_rgray
marks = []
wg = edges("wgray", lo, hi)
bits = {b: edges("d" + b, lo, hi) for b in "012"}
out_bits = {b: edges("q" + b, lo, hi) for b in "012"}
fake = [t for t, v in edges("empty_n", lo, hi) if v == "1" and t > lo]
for t in fake:
    marks.append((t, "w_empty_n = 1", "#c0392b"))
for t, v in edges("dst_valid", lo, hi):
    if v == "0" and fake and t >= fake[0]:
        marks.append((t, "VALID drops", "#c0392b"))
        break
ym = TOP + RH * len(rows)
for i, (t, txt, col) in enumerate(marks):
    s.append('<line x1="%.1f" y1="%d" x2="%.1f" y2="%d" stroke="%s" stroke-dasharray="5,4" stroke-width="1.4"/>' % (X(t), TOP - 8, X(t), ym, col))
    s.append('<text x="%.1f" y="%d" fill="%s" font-weight="bold">%s @ %.0f ns</text>' % (X(t) + 4, ym + 18 + 16 * i, col, txt, t / 1000.0))

# legend
yy = ym + 18 + 16 * len(marks) + 10
s.append('<text x="10" y="%d" fill="#333">Blue = bit entering the synchronizer (write domain). Red bit rows = bit leaving the synchronizer (read domain, with the metastability delay).</text>' % yy)
s.append('<text x="10" y="%d" fill="#333">The read-side pointer w_wgray_s is built from the three red output bits, each delayed independently.</text>' % (yy + 16))
s.append("</svg>")
open(out, "w", encoding="utf-8").write("\n".join(s))
print("wrote", out)
