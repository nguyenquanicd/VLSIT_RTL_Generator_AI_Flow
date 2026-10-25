"""Run the testbench tb_apbcdc.sv of the asynchronous APB bridge in both simulation branches (rules R-033, R-034).

For every configuration the script generates random transfers and completer answers, then runs the testbench
- in the synthesis branch (compiled with -DVLSIT_SYNTHESIS: library cell models, deterministic latency), and
- in the simulation branch (macro undefined: metastability model with random extra latency) for the seeds 1, 2, 3.
Each log (logs/<config>__synthesis.log, logs/<config>__metastable_seed<n>.log) prints SIM-BRANCH and the assertion
line; the script fails when a run does not print "assertion failures: 0, assertions never exercised: 0".

Needs iverilog and vvp in PATH (on Windows the script adds C:\\Tools\\oss-cad-suite\\bin and \\lib when present).
Usage: python vlsit_run_sim.py [quick|full] [--out DIR]
"""
import argparse
import os
import random
import shutil
import subprocess
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.abspath(os.path.join(HERE, ".."))
COMMON = os.path.abspath(os.path.join(ROOT, "..", "000_Common"))
OK_LINE = "assertion failures: 0, assertions never exercised: 0"
RTL = [os.path.join(ROOT, "rtl", f) for f in ("m_vlsit_apbcdc_sync.sv", "m_vlsit_apbcdc_mst.sv", "m_vlsit_apbcdc_slv.sv",
                                              "m_vlsit_apbcdc_top.sv")]
CELLS = [os.path.join(COMMON, "rtl_cells", "VLSIT_CELL_SYNC_%s.sv" % n) for n in
         ("DFF_RN", "DFF_SN", "2FF_RN", "2FF_SN", "3FF_RN", "3FF_SN", "4FF_RN", "4FF_SN")]
WRAP = [os.path.join(COMMON, "rtl_lib", "m_vlsit_apbcdc_cell_sync.sv")]
TB = os.path.join(HERE, "tb_apbcdc.sv")


def env_with_tools():
    env = dict(os.environ)
    cad = r"C:\Tools\oss-cad-suite"
    if os.path.isdir(cad):
        env["PATH"] = os.pathsep.join([os.path.join(cad, "bin"), os.path.join(cad, "lib"), env.get("PATH", "")])
    return env


def configs(mode):
    quick_ratios = ((5, 5), (2, 6), (6, 2), (9, 1))
    all_ratios = ((5, 5), (2, 6), (6, 2), (3, 7), (7, 3), (5, 10), (10, 5), (1, 9), (9, 1), (4, 5))
    out = []
    for hs in (0, 1):
        for apb5 in (0, 1):
            for cell in ((2,) if mode == "quick" else (1, 2, 3, 4)):
                for hm, hs_ in (quick_ratios if mode == "quick" else all_ratios):
                    out.append(dict(HS=hs, CELL=cell, APB5=apb5, HM=hm, HS_=hs_, CORRUPT=0, NOWK=0))
    # variants: every third configuration has a requester that changes the fields in the Access phase (ERR-004: the Setup
    # values are used), and every third APB5 configuration has a requester that never drives PWAKEUP (REQ-APB5-001)
    for n, cfg in enumerate(out):
        if n % 3 == 1:
            cfg["CORRUPT"] = 1
        elif n % 3 == 2 and cfg["APB5"]:
            cfg["NOWK"] = 1
    return out


def make_stimulus(stem, nx, rnd):
    with open(stem + "_req.txt", "w") as f:
        for i in range(nx):
            wr = rnd.randint(0, 1)
            f.write("%d %d %x %x %x %x %x\n" % (rnd.choice([0, 0, 1, 2, 5]), wr, rnd.randrange(0, 1 << 16, 4),
                                               rnd.randint(1, 3) if wr else 0, rnd.randrange(1 << 16) if wr else 0,
                                               rnd.randrange(16), rnd.randrange(16) if wr else 0))
    with open(stem + "_cmp.txt", "w") as f:
        for i in range(nx):
            f.write("%d %d %x %x %x\n" % (rnd.choice([0, 0, 1, 3, 6]), rnd.randint(0, 1), rnd.randrange(1 << 16),
                                          rnd.randrange(16), rnd.randrange(16)))


def build_and_run(cfg, branch, seed, stem, out, env, nx):
    tag = "hs%d_c%d_a%d_m%d_s%d_x%d_w%d" % (cfg["HS"], cfg["CELL"], cfg["APB5"], cfg["HM"], cfg["HS_"], cfg["CORRUPT"],
                                            cfg["NOWK"])
    name = "%s__%s" % (tag, "synthesis" if branch == "synthesis" else "metastable_seed%d" % seed)
    iverilog = shutil.which("iverilog", path=env["PATH"]) or "iverilog"
    vvp_exe = shutil.which("vvp", path=env["PATH"]) or "vvp"
    vvp = os.path.join(out, "build", name + ".vvp")
    cmd = [iverilog, "-g2012", "-o", vvp, "-s", "tb_apbcdc"]
    if branch == "synthesis":
        cmd.append("-DVLSIT_SYNTHESIS")
    for k, v in cfg.items():
        cmd.append("-Ptb_apbcdc.%s=%d" % (k, v))
    cmd += ["-Ptb_apbcdc.NX=%d" % nx, "-Ptb_apbcdc.REGRESS=1"]
    cmd += CELLS + WRAP + RTL + [TB]
    comp = subprocess.run(cmd, capture_output=True, text=True, env=env)
    if comp.returncode != 0:
        return name, False, "COMPILE ERROR\n" + comp.stderr
    run = [vvp_exe, vvp, "+STIM=" + stem.replace("\\", "/")]
    if branch != "synthesis":
        run.append("+APBCDC_MSYNC_SEED=%d" % seed)
    res = subprocess.run(run, capture_output=True, text=True, env=env, timeout=600)
    log = res.stdout + res.stderr
    with open(os.path.join(out, "logs", name + ".log"), "w") as f:
        f.write(log)
    want = "SIM-BRANCH: synthesis" if branch == "synthesis" else "SIM-BRANCH: metastable seed=%d" % seed
    ok = want in log and OK_LINE in log and "RESULT PASS" in log and res.returncode == 0
    return name, ok, log


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("mode", nargs="?", default="quick", choices=["quick", "full"])
    ap.add_argument("--out", default=HERE)
    ap.add_argument("--nx", type=int, default=40)
    args = ap.parse_args()
    os.makedirs(os.path.join(args.out, "logs"), exist_ok=True)
    os.makedirs(os.path.join(args.out, "build"), exist_ok=True)
    env = env_with_tools()
    bad = total = 0
    for n, cfg in enumerate(configs(args.mode)):
        rnd = random.Random(1000 + n)
        stem = os.path.join(args.out, "build", "stim_%d" % n)
        make_stimulus(stem, args.nx, rnd)
        for branch, seed in (("synthesis", 0), ("metastable", 1), ("metastable", 2), ("metastable", 3)):
            name, ok, log = build_and_run(cfg, branch, seed, stem, args.out, env, args.nx)
            total += 1
            print("%-4s %s" % ("PASS" if ok else "FAIL", name), flush=True)
            if not ok:
                bad += 1
                print("\n".join(log.splitlines()[:12]))
    shutil.rmtree(os.path.join(args.out, "build"), ignore_errors=True)
    print("runs: %d, failed: %d" % (total, bad))
    return 1 if bad else 0


if __name__ == "__main__":
    sys.exit(main())
