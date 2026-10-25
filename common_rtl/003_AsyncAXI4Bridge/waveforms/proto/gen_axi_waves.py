"""Generate the waveforms of AsyncAXI4Bridge_Design_Specification.md section 10.3 from the prototype.

Needs iverilog and vvp in PATH (OSS CAD Suite bin and lib) and the skill script vlsit_waveform_svg.py.
Usage: python gen_axi_waves.py [WF-xxx ...]   (no argument: all)
Writes ../axi_wfNNN_<name>.json and .svg; "sweep" writes ../axi_perf_table.txt (latency and throughput tables of the spec).
"""
import json
import math
import os
import subprocess
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
OUT = os.path.dirname(HERE)
BUILD = os.path.join(HERE, "build")
os.makedirs(BUILD, exist_ok=True)
ROOT = os.path.abspath(os.path.join(HERE, "..", "..", ".."))
SVG = os.environ.get("VLSIT_WAVEFORM_SVG",
                     os.path.expanduser(r"~\.claude\skills\vlsit-asic-ip-microspec\scripts\vlsit_waveform_svg.py"))
PY = sys.executable

SIGS = ["clk_s", "clk_m", "rst_s", "rst_m",
        "s_awvalid", "s_awready", "s_awid", "s_awaddr", "s_awlen", "s_awuser",
        "s_wvalid", "s_wready", "s_wdata", "s_wid", "s_wlast", "s_wuser",
        "s_bvalid", "s_bready", "s_bid", "s_bresp", "s_buser",
        "s_arvalid", "s_arready", "s_arid", "s_araddr", "s_arlen", "s_aruser",
        "s_rvalid", "s_rready", "s_rdata", "s_rlast", "s_rid", "s_rresp", "s_ruser",
        "m_awvalid", "m_awready", "m_awid", "m_awaddr", "m_awlen", "m_awuser", "m_awlock", "m_awqos", "m_awregion",
        "m_wvalid", "m_wready", "m_wdata", "m_wid", "m_wlast", "m_wuser",
        "m_bvalid", "m_bready", "m_bid", "m_bresp", "m_buser",
        "m_arvalid", "m_arready", "m_arid", "m_araddr", "m_arlen", "m_aruser",
        "m_rvalid", "m_rready", "m_rdata", "m_rlast", "m_rid", "m_rresp", "m_ruser"]
EXPR = {"clk_s": "clk_s", "clk_m": "clk_m", "rst_s": "rst_n_s", "rst_m": "rst_n_m"}
SUB_IN = {"awvalid", "awid", "awaddr", "awlen", "awuser", "wvalid", "wdata", "wid", "wlast", "wuser", "bready",
          "arvalid", "arid", "araddr", "arlen", "aruser", "rready"}
MGR_OUT = {"awvalid", "awid", "awaddr", "awlen", "awuser", "awlock", "awqos", "awregion", "wvalid", "wdata", "wid",
           "wlast", "wuser", "bready", "arvalid", "arid", "araddr", "arlen", "aruser", "rready"}
TABLES = []


def label(key):
    if key in ("clk_s", "clk_m", "rst_s", "rst_m"):
        return {"clk_s": "i_clk_sub", "clk_m": "i_clk_mgr", "rst_s": "i_rst_n_sub", "rst_m": "i_rst_n_mgr"}[key]
    side, sig = key.split("_", 1)
    if side == "s":
        return ("i_axi_" if sig in SUB_IN else "o_axi_") + sig
    return ("o_axi_" if sig in MGR_OUT else "i_axi_") + sig


def write_include():
    lines = ['$write("S %0.3f", $realtime);']
    for k in SIGS:
        lines.append('$write(" %%h", %s);' % EXPR.get(k, k))
    lines.append('$write("\\n");')
    with open(os.path.join(BUILD, "sample.svh"), "w") as f:
        f.write("\n".join(lines) + "\n")


def run_sim(name, ops, hs, hm, nslot, **kw):
    stim = os.path.join(BUILD, name)
    with open(stim + "_ops.txt", "w") as f:
        for t, ty, i, a, ln in ops:
            f.write("%d %s %d %x %d\n" % (t, ty, i, a, ln))
    dt = math.gcd(hs, hm)
    vvp = os.path.join(BUILD, name + ".vvp")
    ps = {"HS": hs, "HM": hm, "DT": dt, "NSLOT": nslot}
    ps.update(kw)
    cmd = ["iverilog", "-g2012", "-DVLSIT_SYNTHESIS", "-I", BUILD, "-s", "tb_axi_wave", "-o", vvp]
    for k, v in ps.items():
        cmd.append("-Ptb_axi_wave.%s=%s" % (k, v))
    r1 = os.path.join(ROOT, "001_AsyncGrayFIFO", "rtl")
    cm = os.path.join(ROOT, "000_Common")
    files = [os.path.join(HERE, "axi_proto.sv"), os.path.join(HERE, "tb_axi_wave.sv")]
    files += [os.path.join(r1, f) for f in ("m_vlsit_afifo_mem.sv", "m_vlsit_afifo_sync.sv", "m_vlsit_afifo_rd.sv",
                                           "m_vlsit_afifo_wr.sv", "m_vlsit_afifo_top.sv")]
    files += [os.path.join(cm, "rtl_lib", "m_vlsit_afifo_cell_sync.sv"), os.path.join(cm, "rtl_lib", "m_vlsit_afifo_ram_macro.sv"),
              os.path.join(cm, "rtl_cells", "VLSIT_CELL_SRAM_1W1R.sv")]
    for n in ("DFF", "2FF", "3FF", "4FF"):
        for s in ("RN", "SN"):
            files.append(os.path.join(cm, "rtl_cells", "VLSIT_CELL_SYNC_%s_%s.sv" % (n, s)))
    c = subprocess.run(cmd + files, capture_output=True, text=True)
    if c.returncode:
        raise SystemExit("compile error: " + c.stderr[:1500])
    out = subprocess.run(["vvp", vvp, "+STIM=" + stim.replace("\\", "/")], capture_output=True, text=True).stdout
    samples = []
    for line in out.splitlines():
        if line.startswith("S "):
            p = line.split()
            samples.append((float(p[1]), dict(zip(SIGS, p[2:]))))
    return dt, samples


def bit(v):
    return v if v in "01" else "x"


def wavejson(sel, rows, title, foot):
    sig, group = [], None
    for r in rows:
        if r[0] == "group":
            group = [r[1]]
            sig.append(group)
            continue
        lab, key, kind = r[0], r[1], r[2]
        qual = r[3] if len(r) > 3 else None
        wave, data, prev = "", [], None
        for s in sel:
            v = s[1][key]
            if kind == "bit":
                c = bit(v)
                wave += "." if c == prev else c
                prev = c
            else:
                shown = v if (qual is None or s[1][qual] == "1") else "x"
                if "x" in shown.lower() or "z" in shown.lower():
                    wave += "." if prev == "x" else "x"
                    prev = "x"
                else:
                    txt = shown.lstrip("0") or "0"
                    if txt == prev:
                        wave += "."
                    else:
                        wave += "="
                        data.append(txt)
                    prev = txt
        item = {"name": lab, "wave": wave}
        if data:
            item["data"] = data
        (group if group is not None else sig).append(item)
    return {"signal": sig, "head": {"text": title}, "foot": {"text": foot}}


def write_wave(name, wj, cell=18):
    jp = os.path.join(OUT, name + ".json")
    with open(jp, "w") as f:
        json.dump(wj, f, indent=1)
    sp = os.path.join(OUT, name + ".svg")
    subprocess.run([PY, SVG, "render", jp, "--out", sp, "--cell", str(cell), "--force"], check=True, capture_output=True)


def hs_rows(ch, side):
    """Rows of one channel on one side. ch in aw, w, b, ar, r; side s or m."""
    p = side + "_"
    f = {
        "aw": [("valid", "awvalid", "bit"), ("ready", "awready", "bit"), ("awid", "awid", "hex", p + "awvalid"),
               ("awaddr", "awaddr", "hex", p + "awvalid"), ("awlen", "awlen", "hex", p + "awvalid")],
        "w": [("valid", "wvalid", "bit"), ("ready", "wready", "bit"), ("wdata", "wdata", "hex", p + "wvalid"),
              ("wlast", "wlast", "bit")],
        "b": [("valid", "bvalid", "bit"), ("ready", "bready", "bit"), ("bid", "bid", "hex", p + "bvalid"),
              ("bresp", "bresp", "hex", p + "bvalid")],
        "ar": [("valid", "arvalid", "bit"), ("ready", "arready", "bit"), ("arid", "arid", "hex", p + "arvalid"),
               ("araddr", "araddr", "hex", p + "arvalid"), ("arlen", "arlen", "hex", p + "arvalid")],
        "r": [("valid", "rvalid", "bit"), ("ready", "rready", "bit"), ("rdata", "rdata", "hex", p + "rvalid"),
              ("rlast", "rlast", "bit")],
    }[ch]
    rows = []
    for r in f:
        k = p + r[1]
        item = [label(k), k, r[2]]
        if len(r) > 3:
            item.append(r[3])
        rows.append(tuple(item))
    return rows


def rows_for(chs, extra_s=(), extra_m=()):
    rows = [("group", "Subordinate-side interface (CLK-SUB)"), ("i_clk_sub", "clk_s", "bit")]
    for c in chs:
        rows += hs_rows(c, "s")
    rows += list(extra_s)
    rows += [("group", "Manager-side interface (CLK-MGR)"), ("i_clk_mgr", "clk_m", "bit")]
    for c in chs:
        rows += hs_rows(c, "m")
    rows += list(extra_m)
    return rows


def idx_first(samples, key, val="1", after=0):
    for i in range(after, len(samples)):
        if samples[i][1][key] == val:
            return i
    return None


def hs_slot(samples, valid, ready, after=0):
    for i in range(after, len(samples)):
        if samples[i][1][valid] == "1" and samples[i][1][ready] == "1":
            return i
    return None


def scenario(wfid, name, ops, hs, hm, nslot, chs, title, foot, extra_s=(), extra_m=(), cell=18, trim=None, measure=None, **kw):
    write_include()
    dt, samples = run_sim(wfid.lower() + name, ops, hs, hm, nslot, **kw)
    sel = samples
    if trim:
        sel = samples[trim[0]:trim[1]]
    wj = wavejson(sel, rows_for(chs, extra_s, extra_m), title, foot)
    fname = "axi_%s_%s" % (wfid.lower().replace("-", ""), name)
    write_wave(fname, wj, cell)
    if measure:
        TABLES.append("%s %s: %s" % (wfid, name, measure(samples, dt)))
    return samples, dt


def lat(samples, dt, vkey, rkey, dkey):
    h = hs_slot(samples, vkey, rkey)
    if h is None:
        return "no handshake"
    d = idx_first(samples, dkey, "1", h)
    if d is None:
        return "no output"
    return "handshake slot %d, first output slot %d, latency %d ns" % (h, d, (d - h - 1) * dt)


SCEN = {}


def reg(wfid):
    def deco(fn):
        SCEN[wfid] = fn
        return fn
    return deco


@reg("WF-001")
def wf001():
    scenario("WF-001", "write_burst", [(0, "W", 3, 0x0100, 3)], 4, 6, 140, ["aw", "w", "b"],
             "Write burst of 4 beats (AWLEN = 3), subordinate clock 125 MHz, manager clock 83 MHz",
             "AW, W and B cross through separate FIFOs; the data of W may follow the address",
             cell=14, trim=(0, 140), measure=lambda s, d: lat(s, d, "s_awvalid", "s_awready", "m_awvalid"))


@reg("WF-002")
def wf002():
    scenario("WF-002", "read_burst", [(0, "R", 5, 0x0200, 3)], 6, 4, 140, ["ar", "r"],
             "Read burst of 4 beats (ARLEN = 3), subordinate clock 83 MHz, manager clock 125 MHz",
             "AR crosses to the manager side, the R beats cross back through the R FIFO",
             cell=14, trim=(0, 140), measure=lambda s, d: lat(s, d, "s_arvalid", "s_arready", "m_arvalid"))


@reg("WF-003")
def wf003():
    scenario("WF-003", "aw_backpressure", [(0, "W", i, 0x0100 + 0x40 * i, 0) for i in range(6)], 4, 6, 150, ["aw"],
             "AW back-pressure: the manager side is not ready, the AW FIFO (depth 4) fills",
             "o_axi_awready (subordinate side) falls when the FIFO is full and rises after the manager side accepts",
             cell=14, AWR_MASK="32'hFFFF0000", AW_DEPTH=4, W_DEPTH=16)


@reg("WF-004")
def wf004():
    scenario("WF-004", "w_before_aw", [(0, "W", 7, 0x0300, 2)], 4, 6, 140, ["aw", "w"],
             "Write data before write address: AWVALID is delayed by 8 cycles",
             "The protocol allows W before AW (mechanism: separate FIFOs); the bridge keeps both channels independent",
             cell=14, AWD=8)


@reg("WF-005")
def wf005():
    scenario("WF-005", "r_backpressure", [(0, "R", 2, 0x0400, 7)], 6, 4, 150, ["ar", "r"],
             "R back-pressure: the subordinate-side master holds RREADY low, the R FIFO (depth 2) fills",
             "o_axi_rvalid is held while RREADY is low; i_axi_rready (manager side) stays low while the FIFO is full",
             cell=14, RR_MASK="32'hFFFF0000", R_DEPTH=2)


@reg("WF-006")
def wf006():
    scenario("WF-006", "error_response", [(0, "W", 4, 0x0500, 1), (4, "R", 6, 0x0600, 1)], 4, 6, 150, ["b", "r"],
             "Error responses cross unchanged: BRESP = SLVERR (2), RRESP = DECERR (3)",
             "The bridge does not interpret or modify the response codes",
             cell=14, BRESP=2, RRESP=3)


@reg("WF-007")
def wf007():
    ex_s = [("i_axi_awuser", "s_awuser", "hex", "s_awvalid"), ("i_axi_wuser", "s_wuser", "hex", "s_wvalid"),
            ("o_axi_buser", "s_buser", "hex", "s_bvalid"), ("o_axi_ruser", "s_ruser", "hex", "s_rvalid")]
    ex_m = [("o_axi_awuser", "m_awuser", "hex", "m_awvalid"), ("o_axi_wuser", "m_wuser", "hex", "m_wvalid"),
            ("i_axi_buser", "m_buser", "hex", "m_bvalid"), ("i_axi_ruser", "m_ruser", "hex", "m_rvalid")]
    scenario("WF-007", "user_signals", [(0, "W", 3, 0x0100, 1), (0, "R", 5, 0x0200, 1)], 4, 6, 150,
             ["aw", "w", "b", "ar", "r"],
             "User signals (width 4 on every channel) travel with their channel",
             "AWUSER, WUSER, BUSER, ARUSER and RUSER cross unchanged; widths are set by PARA_AXI_*USER_W",
             extra_s=ex_s, extra_m=ex_m, cell=11, USERS=1)


@reg("WF-008")
def wf008():
    ex_s = [("i_axi_wid", "s_wid", "hex", "s_wvalid")]
    ex_m = [("o_axi_wid", "m_wid", "hex", "m_wvalid"), ("o_axi_awlock", "m_awlock", "hex", "m_awvalid")]
    scenario("WF-008", "axi3_mode", [(0, "W", 9, 0x0100, 3)], 4, 6, 140, ["aw", "w"],
             "AXI3 mode (PARA_AXI_AXI3_EN = 1): write ID WID travels with the data, AWLEN has 4 bits, AWLOCK has 2 bits",
             "In AXI3 mode the user signals, QOS and REGION are not present",
             extra_s=ex_s, extra_m=ex_m, cell=14, AXI3=1)


@reg("WF-009")
def wf009():
    ex_s = [("i_rst_n_sub", "rst_s", "bit")]
    ex_m = [("i_rst_n_mgr", "rst_m", "bit")]
    scenario("WF-009", "reset_exit", [(0, "W", 3, 0x0100, 1)], 4, 6, 70, ["aw", "b"],
             "Hardware reset: VALID outputs are low during reset; the first AWVALID follows the release",
             "Both resets are asserted together and released synchronously to their clocks (outside the bridge)",
             extra_s=ex_s, extra_m=ex_m, cell=16, trim=(1, 70), PRE=1)


@reg("WF-010")
def wf010():
    scenario("WF-010", "streaming", [(0, "W", 1, 0x0100, 15)], 4, 6, 150, ["w"],
             "Streaming: a 16-beat write burst with the subordinate clock faster than the manager clock",
             "The W FIFO (depth 16) lets the burst flow; o_axi_wready falls only when the faster side outruns the slower",
             cell=10, W_DEPTH=16)


@reg("WF-011")
def wf011():
    scenario("WF-011", "small_depth", [(0, "W", 1, 0x0100, 7)], 4, 6, 150, ["w"],
             "Small W FIFO (depth 2): the burst advances at the rate of the FIFO round trip",
             "A depth of 2 limits throughput because the full flag falls late (pessimistic flag of 001)",
             cell=12, W_DEPTH=2, WR_MASK="32'hAAAAAAAA")


def edges_after(samples, k, key="clk_s"):
    """Time of the first rising edge of key after sample k."""
    for i in range(k, len(samples) - 1):
        if samples[i][1][key] == "0" and samples[i + 1][1][key] == "1":
            return (samples[i][0] + samples[i + 1][0]) / 2.0
    return None


def sweep():
    """AW latency and W throughput for several clock ratios and FIFO depths (table for sections 10.4 and 13)."""
    write_include()
    lines = ["AW latency (subordinate-side handshake edge to the first manager-side AWVALID), CELL_TYPE = 2, AW_DEPTH = 4",
             "ratio (HS/HM half periods ns)  latency ns  latency in manager cycles"]
    for hs, hm in ((5, 5), (4, 6), (6, 4), (3, 7), (7, 3), (2, 9), (9, 2)):
        dt, smp = run_sim("sweep_aw", [(0, "W", 1, 0x100, 0)], hs, hm, 160)
        h = hs_slot(smp, "s_awvalid", "s_awready")
        e = edges_after(smp, h)
        m = idx_first(smp, "m_awvalid", "1", h)
        lat_ns = (smp[m][0] - dt / 2.0) - e
        lines.append("%d/%d  %.1f  %.2f" % (hs, hm, lat_ns, lat_ns / (2.0 * hm)))
    lines += ["", "W streaming of a 64-beat burst, manager side always ready: manager-side clock cycles of the slower clock per beat",
              "(1.00 = one beat per cycle of the slower of the two clocks, the best a single stream can do)",
              "ratio  depth: cycles per beat"]
    for hs, hm in ((5, 5), (4, 6), (6, 4), (3, 7), (7, 3)):
        row = []
        for depth in (2, 4, 8, 16, 32):
            dtt = math.gcd(hs, hm)
            nsl = int(64 * 2 * max(hs, hm) * 2.6 / dtt) + 200
            dt, smp = run_sim("sweep_w", [(0, "W", 1, 0x100, 63)], hs, hm, nsl, W_DEPTH=depth)
            hits = [i for i in range(len(smp) - 1) if smp[i][1]["m_wvalid"] == "1" and smp[i][1]["m_wready"] == "1"
                    and smp[i][1]["clk_m"] == "0" and smp[i + 1][1]["clk_m"] == "1"]
            if len(hits) < 64:
                row.append("%d:incomplete(%d)" % (depth, len(hits)))
            else:
                span = smp[hits[63]][0] - smp[hits[0]][0]
                row.append("%d:%.2f" % (depth, span / 63.0 / (2.0 * max(hs, hm))))
        lines.append("%d/%d  %s" % (hs, hm, "  ".join(row)))
    with open(os.path.join(OUT, "axi_perf_table.txt"), "w") as f:
        f.write(chr(10).join(lines) + chr(10))
    print(chr(10).join(lines))


def main():
    if sys.argv[1:] == ["sweep"]:
        sweep()
        return
    want = sys.argv[1:] or sorted(SCEN)
    for w in want:
        SCEN[w]()
        print("done", w)
    with open(os.path.join(OUT, "axi_wave_tables.txt"), "w") as f:
        f.write("\n".join(TABLES) + "\n")


if __name__ == "__main__":
    main()
