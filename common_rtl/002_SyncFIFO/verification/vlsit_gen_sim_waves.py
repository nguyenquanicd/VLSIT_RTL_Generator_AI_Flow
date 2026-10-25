"""Simulate the waveform plan of SyncFIFO_Design_Specification.md section 10.3 on the delivered RTL and keep the
waveforms in verification/waveforms_sim (rule R-033 of the skill vlsit-rtl-generator).

For every waveform of the plan it writes <stem>.vcd, <stem>.json and <stem>.svg (stem of the specification figure)
and the index waveform_compare.md. The result is MATCH when the WaveJSON of the simulation equals the WaveJSON of the
specification figure (same rows, same wave strings, same data labels), else DIFFERENT with the first difference.
The stimulus and the sampling are those of waveforms/proto/gen_waves.py; only the design under test differs (RTL).
Needs iverilog and vvp in PATH (OSS CAD Suite bin and lib) and the skill script vlsit_waveform_svg.py.
Usage: python vlsit_gen_sim_waves.py [WF-xxx ...]
"""
import json
import math
import os
import subprocess
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.abspath(os.path.join(HERE, ".."))
PROTO = os.path.join(ROOT, "waveforms", "proto")
sys.path.insert(0, PROTO)
import gen_waves as g  # noqa: E402

OUT = os.path.join(HERE, "waveforms_sim")
BUILD = os.path.join(HERE, "build_waves")
os.makedirs(OUT, exist_ok=True)
os.makedirs(BUILD, exist_ok=True)
RTL = [os.path.join(ROOT, "rtl", f) for f in ("m_vlsit_sfifo_mem.sv", "m_vlsit_sfifo_rd.sv", "m_vlsit_sfifo_wr.sv",
                                              "m_vlsit_sfifo_top.sv")]


def run_rtl(name, wr, rd, depth, retime, hw, hr, nslot, fullthr, emptythr, hrst_at, vcd):
    stim = os.path.join(BUILD, name)
    with open(stim + "_wr.txt", "w") as f:
        for en, data, sw in wr:
            f.write("%d %x %d\n" % (en, data, sw))
    with open(stim + "_rd.txt", "w") as f:
        for en in rd:
            f.write("%d\n" % en)
    dt = math.gcd(hw, hr)
    vvp = os.path.join(BUILD, name + ".vvp")
    cmd = ["iverilog", "-g2012", "-DVLSIT_SYNTHESIS", "-o", vvp, "-Ptb_wave.DEPTH=%d" % depth, "-Ptb_wave.RETIME=%d" % retime,
           "-Ptb_wave.HW=%d" % hw, "-Ptb_wave.HR=%d" % hr, "-Ptb_wave.DT=%d" % dt, "-Ptb_wave.NSLOT=%d" % nslot,
           "-Ptb_wave.FULLTHR=%d" % fullthr, "-Ptb_wave.EMPTYTHR=%d" % emptythr, "-Ptb_wave.HRST_AT=%d" % hrst_at,
           "-Ptb_wave.HRST_CYC=2"] + RTL + [os.path.join(HERE, "tb_wave_rtl.sv")]
    subprocess.run(cmd, check=True, capture_output=True)
    out = subprocess.run(["vvp", vvp, "+STIM=" + stim.replace("\\", "/"), "+VCD=" + vcd.replace("\\", "/")],
                         capture_output=True, text=True).stdout
    start, samples = None, []
    for line in out.splitlines():
        if line.startswith("START"):
            start = float(line.split()[1])
        elif line.startswith("S "):
            p = line.split()
            samples.append((float(p[1]), dict(zip(g.KEYS, p[2:]))))
    return dt, start, samples


def flat(wj):
    rows = []

    def walk(items, prefix=""):
        for it in items:
            if isinstance(it, list):
                walk(it[1:], it[0] + "/")
            else:
                rows.append((prefix + it["name"], it.get("wave", ""), tuple(it.get("data", []))))

    walk(wj["signal"])
    return rows


def main():
    wfs = g.build()
    want = sys.argv[1:] or sorted(wfs)
    index = ["| Waveform ID | Specification figure | Simulated waveform | Result | Note |", "|---|---|---|---|---|"]
    for wf in want:
        d = wfs[wf]
        stem = d["name"]
        vcd = os.path.join(OUT, stem + ".vcd")
        hrst = 130 if wf == "WF-015" else 0
        dt, start, samples = run_rtl(stem, d["wr"], d["rd"], d["depth"], d["retime"], d["hw"], d["hr"], d["nslot"] + 40,
                                     d.get("fullthr", 4), d.get("emptythr", 2), hrst, vcd)
        s0 = int(round((start - dt / 2.0) / dt)) + d["off"]
        sel = samples[max(s0, 0):max(s0, 0) + d["nslot"]]
        wj = g.wavejson(sel, d["rows"], d["title"], d["foot"].replace("Both resets fall", "Both resets fall"))
        jp = os.path.join(OUT, stem + ".json")
        with open(jp, "w") as f:
            json.dump(wj, f, indent=1)
        subprocess.run([g.PY, g.SVG, "render", jp, "--out", os.path.join(OUT, stem + ".svg"), "--cell",
                        str(d.get("cell", 20)), "--force"], check=True, capture_output=True)
        with open(os.path.join(ROOT, "waveforms", stem + ".json")) as f:
            spec_wj = json.load(f)
        a, b = flat(spec_wj), flat(wj)
        diff = None
        if [r[0] for r in a] != [r[0] for r in b]:
            diff = "signal rows differ"
        else:
            for ra, rb in zip(a, b):
                if ra != rb:
                    diff = "row %s differs (specification wave %s, simulated wave %s)" % (ra[0], ra[1], rb[1])
                    break
        res = "MATCH" if diff is None else "DIFFERENT"
        note = "Same rows, wave strings and data labels as the figure; RTL, synthesis branch" if diff is None else diff
        print(wf, stem, res)
        index.append("| %s | waveforms/%s.svg | waveforms_sim/%s.svg | %s | %s |" % (wf, stem, stem, res, note))
    with open(os.path.join(OUT, "waveform_compare.md"), "w") as f:
        f.write("# Simulated waveforms of the delivered RTL against the specification figures\n\n")
        f.write("Produced by `vlsit_gen_sim_waves.py`; the SyncFIFO has no clock-domain crossing, so only the synthesis flow applies.\n\n")
        f.write("\n".join(index) + "\n")


if __name__ == "__main__":
    main()
