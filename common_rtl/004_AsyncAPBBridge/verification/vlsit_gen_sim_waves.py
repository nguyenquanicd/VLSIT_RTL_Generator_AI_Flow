"""Simulate the waveform plan of AsyncAPBBridge_Design_Specification.md section 10.3 on the delivered RTL and keep the
waveforms in verification/waveforms_sim (rule R-033 of the skill vlsit-rtl-generator).

For every waveform of the plan it writes <stem>.vcd, <stem>.json and <stem>.svg (stem of the specification figure) from the
synthesis branch, and the index waveform_compare.md. The result is MATCH when the WaveJSON of the simulation equals the
WaveJSON of the specification figure (same rows, wave strings and data labels), else DIFFERENT with the first difference.
The scenario is also run in the simulation branch (metastability model) with the seeds 1 to 3: the assertions must not fail
(the latency differs by design, so these waveforms are not compared with the figures).
The stimulus and the sampling are those of waveforms/proto/gen_waves.py; only the design under test differs (RTL).
Needs iverilog and vvp in PATH (OSS CAD Suite bin and lib) and the skill script vlsit_waveform_svg.py.
Usage: python vlsit_gen_sim_waves.py [WF-xxx ...]
"""
import json
import math
import os
import shutil
import subprocess
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.abspath(os.path.join(HERE, ".."))
sys.path.insert(0, os.path.join(ROOT, "waveforms", "proto"))
import gen_waves as g  # noqa: E402
import vlsit_run_sim as rs  # noqa: E402

OUT = os.path.join(HERE, "waveforms_sim")
BUILD = os.path.join(HERE, "build_waves")
os.makedirs(OUT, exist_ok=True)
os.makedirs(BUILD, exist_ok=True)
os.makedirs(os.path.join(HERE, "logs"), exist_ok=True)
ENV = rs.env_with_tools()
IVERILOG = shutil.which("iverilog", path=ENV["PATH"]) or "iverilog"
VVP = shutil.which("vvp", path=ENV["PATH"]) or "vvp"


def run_rtl(name, d, branch, seed, vcd):
    stim = os.path.join(BUILD, name)
    with open(stim + "_req.txt", "w") as f:
        for r in d["reqs"]:
            f.write("%d %d %x %x %x %x %x\n" % r)
    with open(stim + "_cmp.txt", "w") as f:
        for c in d["cmps"]:
            f.write("%d %d %x %x %x\n" % c)
    dt = math.gcd(d["hm"], d["hs"])
    vvp = os.path.join(BUILD, "%s_%s_%d.vvp" % (name, branch, seed))
    hrst = 140 if d.get("extra_rst") else 0
    cmd = [IVERILOG, "-g2012", "-o", vvp, "-s", "tb_apbcdc"]
    if branch == "synthesis":
        cmd.append("-DVLSIT_SYNTHESIS")
    cmd += ["-Ptb_apbcdc.HM=%d" % d["hm"], "-Ptb_apbcdc.HS_=%d" % d["hs"], "-Ptb_apbcdc.DT=%d" % dt,
            "-Ptb_apbcdc.NSLOT=%d" % (d["nslot"] + 40), "-Ptb_apbcdc.HS=%d" % d["hs_mode"],
            "-Ptb_apbcdc.CELL=%d" % d["stages"], "-Ptb_apbcdc.APB5=%d" % d["apb5"], "-Ptb_apbcdc.HRST_AT=%d" % hrst,
            "-Ptb_apbcdc.REGRESS=0"] + rs.CELLS + rs.WRAP + rs.RTL + [rs.TB]
    subprocess.run(cmd, check=True, capture_output=True, env=ENV)
    run = [VVP, vvp, "+STIM=" + stim.replace("\\", "/")]
    if vcd:
        run.append("+VCD=" + vcd.replace("\\", "/"))
    if branch != "synthesis":
        run.append("+APBCDC_MSYNC_SEED=%d" % seed)
    out = subprocess.run(run, capture_output=True, text=True, env=ENV).stdout
    start, samples = None, []
    for line in out.splitlines():
        if line.startswith("START"):
            start = float(line.split()[1])
        elif line.startswith("S "):
            p = line.split()
            samples.append((float(p[1]), dict(zip(g.KEYS, p[2:]))))
    return dt, start, samples, out


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
    bad = 0
    for wf in want:
        d = wfs[wf]
        stem = d["name"]
        vcd = os.path.join(OUT, stem + ".vcd")
        dt, start, samples, out = run_rtl(stem, d, "synthesis", 0, vcd)
        s0 = int(round((start - dt / 2.0) / dt))
        sel = samples[max(s0, 0):max(s0, 0) + d["nslot"]]
        rws = g.rows(apb5=bool(d["apb5"]), hs4=d["hs_mode"] == 1, extra_mst=d.get("extra_mst", ()),
                     extra_slv=d.get("extra_slv", ()))
        if d.get("extra_rst"):
            rws = [("group", "Resets"), ("i_rst_n_mst", "rst_n_mst", "bit"), ("i_rst_n_slv", "rst_n_slv", "bit")] + rws
        wj = g.wavejson(sel, rws, d["title"], d["foot"])
        jp = os.path.join(OUT, stem + ".json")
        with open(jp, "w") as f:
            json.dump(wj, f, indent=1)
        subprocess.run([g.PY, g.SVG, "render", jp, "--out", os.path.join(OUT, stem + ".svg"), "--cell", str(d.get("cell", 20)),
                        "--force"], check=True, capture_output=True)
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
        # the assertions of the synthesis run and of three metastability runs must not fail
        fails = []
        for br, sd in (("synthesis", 0), ("metastable", 1), ("metastable", 2), ("metastable", 3)):
            o = out if br == "synthesis" else run_rtl(stem, d, br, sd, None)[3]
            line = [l for l in o.splitlines() if l.startswith("assertion failures:")]
            if not line or not line[0].startswith("assertion failures: 0,"):
                fails.append("%s seed %d: %s" % (br, sd, line[0] if line else "no assertion line"))
        res = "MATCH" if diff is None and not fails else "DIFFERENT"
        note = ("Same rows, wave strings and data labels as the figure (RTL, synthesis branch); assertions pass in the "
                "synthesis branch and with metastability seeds 1 to 3") if res == "MATCH" else "; ".join(
                    ([diff] if diff else []) + fails)
        bad += res != "MATCH"
        print(wf, stem, res)
        index.append("| %s | waveforms/%s.svg | waveforms_sim/%s.svg | %s | %s |" % (wf, stem, stem, res, note))
    with open(os.path.join(OUT, "waveform_compare.md"), "w") as f:
        f.write("# Simulated waveforms of the delivered RTL against the specification figures\n\n")
        f.write("Produced by `vlsit_gen_sim_waves.py` (synthesis branch, `-DVLSIT_SYNTHESIS`). The metastability branch is run "
                "for the assertions only, because its latency differs from the figure by design (R-034).\n\n")
        f.write("\n".join(index) + "\n")
    shutil.rmtree(BUILD, ignore_errors=True)
    return 1 if bad else 0


if __name__ == "__main__":
    sys.exit(main())
