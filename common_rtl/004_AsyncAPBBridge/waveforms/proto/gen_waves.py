"""Generate the waveforms of AsyncAPBBridge_Design_Specification.md section 10.3 from the prototype.

Needs iverilog and vvp in PATH (OSS CAD Suite bin and lib) and the skill script vlsit_waveform_svg.py.
Usage: python gen_waves.py [WF-xxx ...]   (no argument: all). Writes waveforms/<name>.json and <name>.svg and
waveforms/apbcdc_wave_tables.txt (measured latencies quoted by the specification).
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
SVG = os.environ.get("VLSIT_WAVEFORM_SVG",
                     r"C:\Users\PC\.claude\skills\vlsit-asic-ip-microspec\scripts\vlsit_waveform_svg.py")
PY = sys.executable

KEYS = ["clk_mst", "clk_slv", "rst_n_mst", "rst_n_slv", "m_psel", "m_penable", "m_pwrite", "m_pwakeup", "m_paddr",
        "m_pstrb", "m_pwdata", "m_pready", "m_pslverr", "m_prdata", "s_psel", "s_penable", "s_pwrite", "s_pwakeup",
        "s_pready", "s_pslverr", "s_prdata", "dummy", "s_paddr", "s_pwdata", "mst_state", "slv_state", "req", "ack",
        "ack_s", "m_pruser", "m_pbuser", "m_pauser", "m_pwuser", "s_pauser", "s_pwuser", "s_pruser", "s_pbuser"]
MST_ST = {0: "IDLE", 1: "WAIT", 2: "CLOSE", 3: "RESP"}
SLV_ST = {0: "IDLE", 1: "SETUP", 2: "ACCESS", 3: "REQ0"}
TABLES = []


def run_sim(name, reqs, cmps, hm, hs, hs_mode, stages, apb5, nslot, hrst_at=0, hrst_cyc=2):
    stim = os.path.join(BUILD, name)
    with open(stim + "_req.txt", "w") as f:
        for r in reqs:
            f.write("%d %d %x %x %x %x %x\n" % r)
    with open(stim + "_cmp.txt", "w") as f:
        for c in cmps:
            f.write("%d %d %x %x %x\n" % c)
    dt = math.gcd(hm, hs)
    vvp = os.path.join(BUILD, name + ".vvp")
    cmd = ["iverilog", "-g2012", "-o", vvp, "-Ptb_wave.HM=%d" % hm, "-Ptb_wave.HS_=%d" % hs, "-Ptb_wave.DT=%d" % dt,
           "-Ptb_wave.NSLOT=%d" % nslot, "-Ptb_wave.HS=%d" % hs_mode, "-Ptb_wave.STAGES=%d" % stages,
           "-Ptb_wave.APB5=%d" % apb5, "-Ptb_wave.HRST_AT=%d" % hrst_at, "-Ptb_wave.HRST_CYC=%d" % hrst_cyc,
           os.path.join(HERE, "apbcdc_proto.sv"), os.path.join(HERE, "tb_wave.sv")]
    subprocess.run(cmd, check=True, capture_output=True)
    out = subprocess.run(["vvp", vvp, "+STIM=" + stim.replace("\\", "/")], capture_output=True, text=True).stdout
    start = None
    samples = []
    for line in out.splitlines():
        if line.startswith("START"):
            start = float(line.split()[1])
        elif line.startswith("S "):
            p = line.split()
            samples.append((float(p[1]), dict(zip(KEYS, p[2:]))))
    return dt, start, samples


def char_bit(v):
    return v if v in "01" else "x"


def wavejson(sel, rows, title, foot):
    sig = []
    group = None
    for r in rows:
        if r[0] == "group":
            group = [r[1]]
            sig.append(group)
            continue
        label, key, kind = r[0], r[1], r[2]
        vals = [s[1][key] for s in sel]
        wave, data, prev = "", [], None
        for v in vals:
            if kind == "bit":
                c = char_bit(v)
                wave += "." if c == prev else c
                prev = c
            else:
                if kind == "state":
                    txt = (r[3] if len(r) > 3 else {}).get(int(v), v) if v.isdigit() else "x"
                else:
                    txt = v.lstrip("0") or "0" if kind == "hexs" else v
                if "x" in txt and kind in ("hex", "hexs"):
                    c, label_txt = "x", None
                else:
                    c, label_txt = "=", txt
                if txt == prev:
                    wave += "."
                else:
                    wave += c
                    if label_txt is not None:
                        data.append(label_txt)
                prev = txt
        item = {"name": label, "wave": wave}
        if data:
            item["data"] = data
        (group if group is not None else sig).append(item)
    return {"signal": sig, "head": {"text": title}, "foot": {"text": foot}}


def write_wave(name, wj, cell=22):
    jp = os.path.join(OUT, name + ".json")
    with open(jp, "w") as f:
        json.dump(wj, f, indent=1)
    sp = os.path.join(OUT, name + ".svg")
    subprocess.run([PY, SVG, "render", jp, "--out", sp, "--cell", str(cell), "--force"], check=True, capture_output=True)


def rise(sel, key, after=0):
    for i in range(max(after, 1), len(sel)):
        if sel[i - 1][1][key] == "0" and sel[i][1][key] == "1":
            return i
    return None


def rows(apb5=False, hs4=False, extra_mst=(), extra_slv=()):
    r = [("group", "Requester side (clock domain mst)"),
         ("i_clk_mst", "clk_mst", "bit"),
         ("i_apb_psel", "m_psel", "bit"), ("i_apb_penable", "m_penable", "bit"), ("i_apb_pwrite", "m_pwrite", "bit"),
         ("i_apb_paddr", "m_paddr", "hexs"), ("i_apb_pstrb", "m_pstrb", "hexs"), ("i_apb_pwdata", "m_pwdata", "hexs")]
    if apb5:
        r.append(("i_apb_pwakeup", "m_pwakeup", "bit"))
    r += [("o_apb_pready", "m_pready", "bit"), ("o_apb_prdata", "m_prdata", "hexs"), ("o_apb_pslverr", "m_pslverr", "bit")]
    r += list(extra_mst)
    r += [("group", "Crossing (internal)"), ("request (mst to slv)", "req", "bit"), ("acknowledge (slv to mst)", "ack", "bit"),
          ("mst FSM", "mst_state", "state", MST_ST), ("slv FSM", "slv_state", "state", SLV_ST)]
    r += [("group", "Completer side (clock domain slv)"),
          ("i_clk_slv", "clk_slv", "bit"),
          ("o_apb_psel", "s_psel", "bit"), ("o_apb_penable", "s_penable", "bit"), ("o_apb_pwrite", "s_pwrite", "bit"),
          ("o_apb_paddr", "s_paddr", "hexs"), ("o_apb_pwdata", "s_pwdata", "hexs")]
    if apb5:
        r.append(("o_apb_pwakeup", "s_pwakeup", "bit"))
    r += [("i_apb_pready", "s_pready", "bit"), ("i_apb_prdata", "s_prdata", "hexs"), ("i_apb_pslverr", "s_pslverr", "bit")]
    r += list(extra_slv)
    return r


def build():
    w = {}
    # tuple layout of a request: gap, write, addr, strb, wdata, auser, wuser ; of a completer answer: waits, err, rdata, ruser, buser
    w["WF-001"] = dict(name="apbcdc_wf001_write_no_wait", reqs=[(2, 1, 0x40, 3, 0xA1B2, 0, 0)], cmps=[(0, 0, 0, 0, 0)],
                       hm=5, hs=5, hs_mode=0, stages=2, apb5=0, nslot=60,
                       title="WF-001 Write transfer without wait states (equal clocks 10 ns, two-phase handshake, 2-FF synchronizers)",
                       foot="The requester sees PREADY after the whole round trip; the completer side runs one normal APB write.")
    w["WF-002"] = dict(name="apbcdc_wf002_read_no_wait", reqs=[(2, 0, 0x44, 0, 0, 0, 0)], cmps=[(0, 0, 0x5A5A, 0, 0)],
                       hm=5, hs=5, hs_mode=0, stages=2, apb5=0, nslot=60,
                       title="WF-002 Read transfer without wait states (equal clocks 10 ns, two-phase handshake)",
                       foot="PRDATA is valid in the cycle where PREADY is high; the completer-side data is held in the bridge until then.")
    w["WF-003"] = dict(name="apbcdc_wf003_write_wait_states", reqs=[(2, 1, 0x48, 3, 0x1234, 0, 0)], cmps=[(3, 0, 0, 0, 0)],
                       hm=5, hs=5, hs_mode=0, stages=2, apb5=0, nslot=64,
                       title="WF-003 Write transfer with three wait states on the completer side (equal clocks 10 ns)",
                       foot="The completer holds PREADY low for three cycles; the requester-side PREADY stays low until the response arrives.")
    w["WF-004"] = dict(name="apbcdc_wf004_read_error", reqs=[(2, 0, 0x4C, 0, 0, 0, 0)], cmps=[(1, 1, 0xDEAD, 0, 0)],
                       hm=5, hs=5, hs_mode=0, stages=2, apb5=0, nslot=60,
                       title="WF-004 Read transfer with an error response (PSLVERR, one wait state)",
                       foot="PSLVERR and PRDATA of the completer cross the domains together and appear in the PREADY cycle.")
    w["WF-005"] = dict(name="apbcdc_wf005_write_error", reqs=[(2, 1, 0x50, 3, 0xBEEF, 0, 0)], cmps=[(0, 1, 0, 0, 0)],
                       hm=5, hs=5, hs_mode=0, stages=2, apb5=0, nslot=60,
                       title="WF-005 Write transfer with an error response (PSLVERR)",
                       foot="PSLVERR is high only in the PREADY cycle of the requester side.")
    w["WF-006"] = dict(name="apbcdc_wf006_back_to_back", reqs=[(2, 1, 0x60, 3, 0x1111, 0, 0), (0, 0, 0x64, 0, 0, 0, 0),
                                                              (0, 1, 0x68, 3, 0x2222, 0, 0)],
                       cmps=[(0, 0, 0, 0, 0), (0, 0, 0x3333, 0, 0), (0, 0, 0, 0, 0)],
                       hm=5, hs=5, hs_mode=0, stages=2, apb5=0, nslot=110,
                       title="WF-006 Three transfers back to back (the next SETUP follows the PREADY cycle at once)",
                       foot="The bridge accepts the next SETUP in the cycle after PREADY; each transfer pays the full round trip.")
    w["WF-007"] = dict(name="apbcdc_wf007_four_phase_write", reqs=[(2, 1, 0x40, 3, 0xA1B2, 0, 0)], cmps=[(0, 0, 0, 0, 0)],
                       hm=5, hs=5, hs_mode=1, stages=2, apb5=0, nslot=76,
                       title="WF-007 Write transfer with the four-phase handshake (PARA_APBCDC_HS_TYPE = 1)",
                       foot="Request and acknowledge both return to 0 before PREADY is raised; the transfer is longer than with two-phase.")
    w["WF-008"] = dict(name="apbcdc_wf008_sparse_write", reqs=[(2, 1, 0x70, 1, 0xFFAA, 0, 0), (1, 1, 0x71, 2, 0x55FF, 0, 0)],
                       cmps=[(0, 0, 0, 0, 0), (0, 0, 0, 0, 0)],
                       hm=5, hs=5, hs_mode=0, stages=2, apb5=0, nslot=90,
                       title="WF-008 Sparse writes: PSTRB selects one byte lane (PSTRB = 01, then 10)",
                       foot="PSTRB crosses unchanged; the completer receives the same byte-lane mask as the requester drove.")
    w["WF-009"] = dict(name="apbcdc_wf009_apb5_wakeup_user", reqs=[(3, 1, 0x80, 3, 0xC0DE, 5, 0xA), (1, 0, 0x84, 0, 0, 6, 0)],
                       cmps=[(0, 0, 0, 0, 0xB), (0, 0, 0x7777, 0x9, 0xC)],
                       hm=5, hs=5, hs_mode=0, stages=2, apb5=1, nslot=100,
                       title="WF-009 APB5 option: PWAKEUP and user signals (PAUSER 5, PWUSER A; read with PRUSER 9, PBUSER C)",
                       foot="o_apb_pwakeup rises before the downstream PSEL and falls after the transfer. User attributes cross with the data.")
    w["WF-009"]["extra_mst"] = [("i_apb_pauser", "m_pauser", "hexs"), ("i_apb_pwuser", "m_pwuser", "hexs"),
                                ("o_apb_pruser", "m_pruser", "hexs"), ("o_apb_pbuser", "m_pbuser", "hexs")]
    w["WF-009"]["extra_slv"] = [("o_apb_pauser", "s_pauser", "hexs"), ("o_apb_pwuser", "s_pwuser", "hexs"),
                                ("i_apb_pruser", "s_pruser", "hexs"), ("i_apb_pbuser", "s_pbuser", "hexs")]
    w["WF-010"] = dict(name="apbcdc_wf010_requester_clock_fast", reqs=[(2, 1, 0x90, 3, 0xABCD, 0, 0)], cmps=[(0, 0, 0, 0, 0)],
                       hm=2, hs=6, hs_mode=0, stages=2, apb5=0, nslot=100,
                       title="WF-010 Requester clock 4 ns, completer clock 12 ns (three times slower)",
                       foot="The requester side waits several of its cycles; the completer runs one transfer at its own rate.")
    w["WF-011"] = dict(name="apbcdc_wf011_completer_clock_fast", reqs=[(2, 1, 0xA0, 3, 0xABCD, 0, 0)], cmps=[(0, 0, 0, 0, 0)],
                       hm=6, hs=2, hs_mode=0, stages=2, apb5=0, nslot=90,
                       title="WF-011 Requester clock 12 ns, completer clock 4 ns (three times faster)",
                       foot="The completer transfer finishes quickly; the response waits for the synchronizer of the slower requester clock.")
    w["WF-012"] = dict(name="apbcdc_wf012_hardware_reset", reqs=[(2, 1, 0xB0, 3, 0x7E57, 0, 0), (2, 0, 0xB4, 0, 0, 0, 0)],
                       cmps=[(4, 0, 0, 0, 0), (0, 0, 0x4242, 0, 0)],
                       hm=5, hs=5, hs_mode=0, stages=2, apb5=0, nslot=100, hrst_at=1,
                       title="WF-012 Hardware reset in the middle of a transfer (both resets together, released synchronously)",
                       foot="All bridge state is cleared at once; the transfer in flight is lost and the requester model repeats it after the reset.")
    w["WF-012"]["extra_rst"] = True
    return w


def main():
    wfs = build()
    want = sys.argv[1:] or sorted(wfs)
    for wf in want:
        d = wfs[wf]
        hrst = 0
        if wf == "WF-012":
            hrst = 140
        dt, start, samples = run_sim(d["name"], d["reqs"], d["cmps"], d["hm"], d["hs"], d["hs_mode"], d["stages"], d["apb5"],
                                     d["nslot"] + 40, hrst_at=hrst)
        s0 = int(round((start - dt / 2.0) / dt))
        sel = samples[s0:s0 + d["nslot"]]
        rws = rows(apb5=bool(d["apb5"]), hs4=d["hs_mode"] == 1, extra_mst=d.get("extra_mst", ()),
                   extra_slv=d.get("extra_slv", ()))
        if d.get("extra_rst"):
            rws = [("group", "Resets"), ("i_rst_n_mst", "rst_n_mst", "bit"), ("i_rst_n_slv", "rst_n_slv", "bit")] + rws
        wj = wavejson(sel, rws, d["title"], d["foot"])
        write_wave(d["name"], wj, cell=d.get("cell", 20))
        print(wf, d["name"], "slots", len(sel), "slot ns", dt)
        # measured latencies: first PSEL of the requester to the PREADY cycle, in cycles of the requester clock
        ps = rise(sel, "m_psel")
        pr = rise(sel, "m_pready")
        sp = rise(sel, "s_psel")
        if ps is not None and pr is not None:
            line = "%s: requester PSEL rises in the slot at %.1f ns, PREADY rises in the slot at %.1f ns" % (
                wf, sel[ps][0], sel[pr][0])
            if sp is not None:
                line += ", completer PSEL rises at %.1f ns" % sel[sp][0]
            TABLES.append(line + " (slot = %d ns, requester period %d ns, completer period %d ns)" % (
                dt, 2 * d["hm"], 2 * d["hs"]))
    with open(os.path.join(OUT, "apbcdc_wave_tables.txt"), "w") as f:
        f.write("\n".join(TABLES) + "\n")


if __name__ == "__main__":
    main()
