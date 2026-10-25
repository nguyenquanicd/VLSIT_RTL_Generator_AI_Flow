"""Generate the waveforms of SyncFIFO_Design_Specification.md section 10.6 from the prototype.

Needs iverilog and vvp in PATH (OSS CAD Suite bin and lib) and the skill script vlsit_waveform_svg.py.
Usage: python gen_waves.py [WF-xxx ...]   (no argument: all). Writes waveforms/<name>.json and <name>.svg and
waveforms/sfifo_wave_tables.txt (measured latencies quoted by the specification).
"""
import json
import math
import os
import re
import subprocess
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
OUT = os.path.dirname(HERE)
BUILD = os.path.join(HERE, "build")
os.makedirs(BUILD, exist_ok=True)
SVG = os.environ.get("VLSIT_WAVEFORM_SVG",
                     r"C:\HQuan\102_MyGithub\VLSIT_CODEX_CLAUDE_SKILLS\.claude\skills\vlsit-asic-ip-microspec\scripts\vlsit_waveform_svg.py")
PY = sys.executable

KEYS = ["clk_wr", "clk_rd", "rst_n_wr", "rst_n_rd", "rst_n_sw", "wr_en", "wr_data", "full", "full_thr", "overflow", "busy",
        "rd_en", "rd_data", "empty", "empty_thr", "underflow", "wptr", "rptr", "wr_state", "rd_state", "req", "ack",
        "wr_acc", "rd_acc", "wr_addr", "rd_addr"]
WSTATE = {0: "RUN", 1: "REQ", 2: "PTR", 3: "HOLD", 4: "REL"}
RSTATE = {0: "RUN", 1: "RST", 2: "ACK"}
TABLES = []


def run_sim(name, wr, rd, depth, retime, hw, hr, nslot, fullthr=4, emptythr=2, hrst_at=0, hrst_cyc=2):
    stim = os.path.join(BUILD, name)
    with open(stim + "_wr.txt", "w") as f:
        for en, data, sw in wr:
            f.write("%d %x %d\n" % (en, data, sw))
    with open(stim + "_rd.txt", "w") as f:
        for en in rd:
            f.write("%d\n" % en)
    dt = math.gcd(hw, hr)
    vvp = os.path.join(BUILD, name + ".vvp")
    cmd = ["iverilog", "-g2012", "-o", vvp, "-Ptb_wave.DEPTH=%d" % depth, "-Ptb_wave.RETIME=%d" % retime,
           "-Ptb_wave.HW=%d" % hw, "-Ptb_wave.HR=%d" % hr, "-Ptb_wave.DT=%d" % dt, "-Ptb_wave.NSLOT=%d" % nslot,
           "-Ptb_wave.FULLTHR=%d" % fullthr, "-Ptb_wave.EMPTYTHR=%d" % emptythr,
           "-Ptb_wave.HRST_AT=%d" % hrst_at, "-Ptb_wave.HRST_CYC=%d" % hrst_cyc,
           os.path.join(HERE, "sfifo_proto.sv"), os.path.join(HERE, "tb_wave.sv")]
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


def slots(samples, dt, start, off, n):
    s0 = int(round((start - dt / 2.0) / dt)) + off
    return samples[max(s0, 0):max(s0, 0) + n], s0


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
                    txt = v
                if "x" in txt and kind == "hex":
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


def first(sel, key, val, after=0):
    for i, s in enumerate(sel):
        if i >= after and s[1][key] == val:
            return i
    return None


def edge_index(sel, key, rising=True, after=0):
    for i in range(max(after, 1), len(sel)):
        a, b = sel[i - 1][1][key], sel[i][1][key]
        if (a, b) == (("0", "1") if rising else ("1", "0")):
            return i
    return None


# ---- row sets ------------------------------------------------------------------------------------------------------
def rows_main(extra=()):
    r = [("group", "Write domain"),
         ("i_clk_wr", "clk_wr", "bit"), ("i_wr_en", "wr_en", "bit"), ("i_wr_data", "wr_data", "hex"),
         ("o_full", "full", "bit"), ("o_overflow", "overflow", "bit"),
         ("group", "Read domain"),
         ("i_clk_rd", "clk_rd", "bit"), ("i_rd_en", "rd_en", "bit"), ("o_rd_data", "rd_data", "hex"),
         ("o_empty", "empty", "bit"), ("o_underflow", "underflow", "bit")]
    return r + list(extra)


PTRS = [("group", "Pointers"), ("write pointer (internal)", "wptr", "hex_dec"), ("read pointer (internal)", "rptr", "hex_dec")]
THR = [("group", "Thresholds"), ("o_full_thr", "full_thr", "bit"), ("o_empty_thr", "empty_thr", "bit")]
SRST = [("group", "Software reset"), ("i_rst_n_sw", "rst_n_sw", "bit"), ("o_sw_rst_busy", "busy", "bit"),
        ("write FSM (internal)", "wr_state", "state", WSTATE), ("req_wr (internal)", "req", "bit"),
        ("read FSM (internal)", "rd_state", "state", RSTATE), ("ack_rd (internal)", "ack", "bit")]


def cyc(n, v):
    return [v] * n


def wlist(*parts):
    out = []
    for p in parts:
        out += p
    return out


W0 = (0, 0, 1)


def wr_words(first_data, count, sw=1):
    return [(1, first_data + i, sw) for i in range(count)]


def build():
    wfs = {}

    # WF-001 write one word into an empty FIFO
    wfs["WF-001"] = dict(name="sfifo_wf001_write_into_empty", depth=8, retime=0, hw=5, hr=5, nslot=40, off=0,
                         wr=wlist(cyc(2, W0), [(1, 0xA1, 1)], cyc(8, W0)), rd=cyc(12, 0),
                         rows=rows_main(PTRS), title="WF-001 One write into an empty FIFO (PTR_RETIME = 0, equal clocks)",
                         foot="o_empty falls after the first read-clock edge that is later than the write edge.")
    # WF-002 read three words (show-ahead)
    wfs["WF-002"] = dict(name="sfifo_wf002_read_show_ahead", depth=8, retime=0, hw=5, hr=5, nslot=48, off=0,
                         wr=wlist(cyc(1, W0), wr_words(0xB1, 3), cyc(8, W0)),
                         rd=wlist(cyc(8, 0), cyc(3, 1), cyc(6, 0)),
                         rows=rows_main(PTRS), title="WF-002 Three reads, show-ahead data (PTR_RETIME = 0, equal clocks)",
                         foot="o_rd_data already shows the next word after each accepted read; o_empty rises with the last read.")
    # WF-003 full and overflow
    wfs["WF-003"] = dict(name="sfifo_wf003_full_overflow", depth=4, retime=0, hw=5, hr=5, nslot=70, off=0, fullthr=3,
                         wr=wlist(cyc(1, W0), wr_words(0xC1, 8), cyc(6, W0), wr_words(0xD1, 3), cyc(4, W0)),
                         rd=wlist(cyc(12, 0), cyc(1, 1), cyc(20, 0)),
                         rows=rows_main(PTRS + [("group", "Threshold"), ("o_full_thr", "full_thr", "bit")]),
                         title="WF-003 FIFO full: writes rejected and o_overflow pulses (DEPTH = 4, threshold 3)",
                         foot="Writes 5 to 8 are rejected (one o_overflow pulse each); one read frees a place and a write is accepted again.")
    # WF-004 empty and underflow
    wfs["WF-004"] = dict(name="sfifo_wf004_empty_underflow", depth=4, retime=0, hw=5, hr=5, nslot=48, off=0,
                         wr=wlist(cyc(5, W0), [(1, 0xE1, 1)], cyc(8, W0)), rd=cyc(14, 1),
                         rows=rows_main(PTRS), title="WF-004 Read of an empty FIFO: o_underflow pulses (DEPTH = 4)",
                         foot="i_rd_en is held high: every rejected read gives one o_underflow pulse in the next cycle.")
    # WF-005 thresholds
    wfs["WF-005"] = dict(name="sfifo_wf005_thresholds", depth=8, retime=0, hw=5, hr=5, nslot=72, off=0, fullthr=6, emptythr=2,
                         wr=wlist(cyc(1, W0), wr_words(0x31, 7), cyc(10, W0)),
                         rd=wlist(cyc(12, 0), cyc(8, 1), cyc(6, 0)),
                         rows=rows_main(PTRS + THR),
                         title="WF-005 Thresholds: o_full_thr at occupancy >= 6, o_empty_thr at occupancy <= 2 (DEPTH = 8)",
                         foot="o_full_thr is the write view, o_empty_thr the read view of the occupancy.")
    # WF-006 / WF-007 flag latency with clock ratio 2:3 (write period 12 ns, read period 8 ns)
    for wf, rt in (("WF-006", 0), ("WF-007", 1)):
        wfs[wf] = dict(name="sfifo_wf%s_flag_latency_retime%d" % (wf[3:], rt), depth=4, retime=rt, hw=6, hr=4, nslot=76, off=0,
                       fullthr=4,
                       wr=wlist(cyc(1, W0), [(1, 0xF1, 1)], cyc(2, W0), wr_words(0xF2, 3), cyc(4, W0)),
                       rd=wlist(cyc(12, 0), cyc(1, 1), cyc(8, 0)),
                       rows=rows_main(PTRS),
                       title="%s Flag latency with PTR_RETIME = %d (write clock 12 ns, read clock 8 ns, DEPTH = 4)" % (wf, rt),
                       foot="o_empty falls %s after the write edge; o_full falls %s after the read edge." %
                            ("after the first read edge" if rt == 0 else "after the second read edge",
                             "after the first write edge" if rt == 0 else "after the second write edge"))
    # WF-008 / WF-009 back to back, equal clocks
    for wf, rt in (("WF-008", 0), ("WF-009", 1)):
        wfs[wf] = dict(name="sfifo_wf%s_back_to_back_equal_retime%d" % (wf[3:], rt), depth=8, retime=rt, hw=5, hr=5, nslot=64,
                       off=0, wr=wlist(cyc(1, W0), wr_words(0x10, 26)), rd=cyc(30, 1),
                       rows=rows_main(PTRS),
                       title="%s Continuous write and continuous read, equal clocks, PTR_RETIME = %d (DEPTH = 8)" % (wf, rt),
                       foot="Only the initial latency: after o_empty falls a word is read in every cycle, no gap.")
    # WF-010 write clock faster
    wfs["WF-010"] = dict(name="sfifo_wf010_back_to_back_write_faster", depth=6, retime=0, hw=4, hr=6, nslot=88, off=0,
                         wr=wlist(cyc(1, W0), wr_words(0x40, 40)), rd=cyc(30, 1),
                         rows=rows_main(PTRS),
                         title="WF-010 Continuous traffic, write clock 8 ns, read clock 12 ns (DEPTH = 6, PTR_RETIME = 0)",
                         foot="The reader never stalls; the faster writer is held back by o_full only because the reader is slower.")
    # WF-011 read clock faster
    wfs["WF-011"] = dict(name="sfifo_wf011_back_to_back_read_faster", depth=6, retime=0, hw=6, hr=4, nslot=88, off=0,
                         wr=wlist(cyc(1, W0), wr_words(0x50, 30)), rd=cyc(44, 1),
                         rows=rows_main(PTRS),
                         title="WF-011 Continuous traffic, write clock 12 ns, read clock 8 ns (DEPTH = 6, PTR_RETIME = 0)",
                         foot="The writer never stalls; the faster reader waits (o_empty, o_underflow) only because the writer is slower.")
    # WF-012 pointer wrap, depth 5
    wfs["WF-012"] = dict(name="sfifo_wf012_pointer_wrap_depth5", depth=5, retime=0, hw=5, hr=5, nslot=72, off=0,
                         wr=wlist(cyc(1, W0), wr_words(0x61, 14), cyc(4, W0)), rd=cyc(22, 1),
                         rows=rows_main([("group", "Pointers (modulo 2 x DEPTH = 10)"),
                                         ("write pointer (internal)", "wptr", "hex_dec"),
                                         ("read pointer (internal)", "rptr", "hex_dec"),
                                         ("memory write address", "wr_addr", "hex_dec"),
                                         ("memory read address", "rd_addr", "hex_dec")]),
                         title="WF-012 Pointer and address wrap with DEPTH = 5 (pointer 0 to 9, address 0 to 4)",
                         foot="The pointer counts modulo 10, the address is the pointer modulo 5; no word is lost at the wrap.")
    # WF-013 software reset main sequence
    wfs["WF-013"] = dict(name="sfifo_wf013_software_reset", depth=4, retime=0, hw=5, hr=5, nslot=80, off=0,
                         wr=wlist(cyc(1, W0), wr_words(0x71, 3), cyc(3, W0), cyc(3, (0, 0, 0)), cyc(2, W0),
                                  [(1, 0x81 + i, 1) for i in range(6)], cyc(4, W0)),
                         rd=wlist(cyc(7, 0), cyc(1, 1), cyc(20, 0)),
                         rows=rows_main(SRST + PTRS),
                         title="WF-013 Software reset requested with i_rst_n_sw = 0 (DEPTH = 4, PTR_RETIME = 0)",
                         foot="The read side resets first and acknowledges, then the write side; writes are blocked until o_sw_rst_busy is 0.")
    # WF-014 one-cycle software reset pulse while full
    wfs["WF-014"] = dict(name="sfifo_wf014_software_reset_pulse_full", depth=4, retime=0, hw=5, hr=5, nslot=80, off=0,
                         wr=wlist(cyc(1, W0), wr_words(0x91, 6), cyc(1, (1, 0x97, 0)), wr_words(0xA1, 10), cyc(2, W0)),
                         rd=cyc(30, 0),
                         rows=rows_main(SRST + PTRS),
                         title="WF-014 One-cycle software reset pulse while the FIFO is full (DEPTH = 4)",
                         foot="A one-cycle low pulse starts the whole sequence; the FIFO is empty again when o_sw_rst_busy falls.")
    # WF-015 hardware reset in the middle of traffic
    wfs["WF-015"] = dict(name="sfifo_wf015_hardware_reset", depth=4, retime=0, hw=5, hr=5, nslot=72, off=0, hrst_at=0,
                         wr=wlist(cyc(1, W0), wr_words(0xB1, 24)), rd=wlist(cyc(8, 0), cyc(20, 1)),
                         rows=rows_main([("group", "Resets"), ("i_rst_n_wr", "rst_n_wr", "bit"), ("i_rst_n_rd", "rst_n_rd", "bit")] + PTRS),
                         title="WF-015 Hardware reset in the middle of traffic (asynchronous assertion, synchronous release)",
                         foot="Both resets fall at the same time, not aligned to a clock edge; all state is cleared at once and o_empty is 1.")
    return wfs


def main():
    wfs = build()
    want = sys.argv[1:] or sorted(wfs)
    for wf in want:
        d = wfs[wf]
        hr_at = 0
        if wf == "WF-015":
            hr_at = 130
        dt, start, samples = run_sim(d["name"], d["wr"], d["rd"], d["depth"], d["retime"], d["hw"], d["hr"], d["nslot"] + 40,
                                     d.get("fullthr", 4), d.get("emptythr", 2), hrst_at=hr_at, hrst_cyc=2)
        sel, s0 = slots(samples, dt, start, d["off"], d["nslot"])
        wj = wavejson(sel, d["rows"], d["title"], d["foot"])
        write_wave(d["name"], wj, cell=d.get("cell", 20))
        print(wf, d["name"], "slots", len(sel), "slot ns", dt)
        # measured latencies for the tables
        if wf in ("WF-001", "WF-006", "WF-007"):
            wacc = first(sel, "wr_acc", "1")
            ef = edge_index(sel, "empty", rising=False)
            if wacc is not None and ef is not None:
                # wr_acc is combinational and 1 in the cycle of the accepted write; the write edge is the end of that cycle
                tw = sel[wacc][0]
                te = sel[ef][0]
                TABLES.append("%s: write accepted in the slot at %.1f ns, o_empty falls in the slot at %.1f ns (slot = %d ns)" %
                              (wf, tw, te, dt))
    with open(os.path.join(OUT, "sfifo_wave_tables.txt"), "w") as f:
        f.write("\n".join(TABLES) + "\n")


if __name__ == "__main__":
    main()
