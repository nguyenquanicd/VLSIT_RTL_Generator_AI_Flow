"""Run the testbench tb_sfifo.sv of the synchronous-clock FIFO for a set of configurations.

Needs iverilog and vvp in PATH (on Windows the script adds C:\\Tools\\oss-cad-suite\\bin and \\lib when that
folder exists). Usage:
    python vlsit_run_sim.py [quick|full] [--rtl DIR] [--out DIR]
quick: 8 configurations; full: depth x retime x macro x clock ratio matrix. The exit code is 0 when every run
prints "RESULT PASS", else 1. Logs go to the out folder (default: sim_logs beside this script).
"""
import argparse
import os
import shutil
import subprocess
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.abspath(os.path.join(HERE, ".."))


def env_with_tools():
    env = dict(os.environ)
    cad = r"C:\Tools\oss-cad-suite"
    if os.path.isdir(cad):
        env["PATH"] = os.pathsep.join([os.path.join(cad, "bin"), os.path.join(cad, "lib"), env.get("PATH", "")])
    return env


def configs(mode):
    if mode == "quick":
        return [
            dict(DEPTH=8, RETIME=0, MACRO=0, HW=5, HR=5),
            dict(DEPTH=8, RETIME=1, MACRO=0, HW=5, HR=5),
            dict(DEPTH=5, RETIME=0, MACRO=0, HW=6, HR=4),
            dict(DEPTH=5, RETIME=1, MACRO=0, HW=4, HR=6),
            dict(DEPTH=2, RETIME=0, MACRO=0, HW=5, HR=5),
            dict(DEPTH=3, RETIME=1, MACRO=0, HW=3, HR=7),
            dict(DEPTH=12, RETIME=0, MACRO=1, HW=7, HR=3),
            dict(DEPTH=6, RETIME=1, MACRO=1, HW=5, HR=5),
        ]
    out = []
    for depth in (2, 3, 5, 8, 12, 16):
        for retime in (0, 1):
            for macro in (0, 1):
                for hw, hr in ((5, 5), (6, 4), (4, 6), (5, 10), (10, 5), (3, 7), (7, 3), (7, 5)):
                    if macro and (hw, hr) not in ((5, 5), (6, 4), (3, 7)):
                        continue
                    out.append(dict(DEPTH=depth, RETIME=retime, MACRO=macro, HW=hw, HR=hr))
    return out


def run_one(cfg, rtl, out, env, seed=1):
    tag = "d%d_r%d_m%d_w%d_r%d" % (cfg["DEPTH"], cfg["RETIME"], cfg["MACRO"], cfg["HW"], cfg["HR"])
    vvp = os.path.join(out, tag + ".vvp")
    files = [os.path.join(rtl, f) for f in ("m_vlsit_sfifo_mem.sv", "m_vlsit_sfifo_rd.sv",
                                            "m_vlsit_sfifo_wr.sv", "m_vlsit_sfifo_top.sv")]
    files += [os.path.join(ROOT, "..", "000_Common", "rtl_cells", "VLSIT_CELL_SRAM_1W1R.sv"),
              os.path.join(ROOT, "..", "000_Common", "rtl_lib", "m_vlsit_sfifo_ram_macro.sv"),
              os.path.join(HERE, "tb_sfifo.sv")]
    iverilog = shutil.which("iverilog", path=env["PATH"]) or "iverilog"
    vvp_exe = shutil.which("vvp", path=env["PATH"]) or "vvp"
    cmd = [iverilog, "-g2012", "-o", vvp, "-DVLSIT_SYNTHESIS", "-s", "tb_sfifo"]
    for k, v in cfg.items():
        cmd.append("-Ptb_sfifo.%s=%d" % (k, v))
    cmd.append("-Ptb_sfifo.SEED=%d" % seed)
    cmd += files
    comp = subprocess.run(cmd, capture_output=True, text=True, env=env)
    if comp.returncode != 0:
        return tag, False, "COMPILE ERROR\n" + comp.stderr
    res = subprocess.run([vvp_exe, vvp], capture_output=True, text=True, env=env)
    log = res.stdout + res.stderr
    with open(os.path.join(out, tag + ".log"), "w") as f:
        f.write(log)
    ok = ("RESULT PASS" in log) and ("assertion failures: 0, assertions never exercised: 0" in log) \
        and res.returncode == 0
    return tag, ok, log


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("mode", nargs="?", default="quick", choices=["quick", "full"])
    ap.add_argument("--rtl", default=os.path.join(ROOT, "rtl"))
    ap.add_argument("--out", default=os.path.join(HERE, "sim_logs"))
    ap.add_argument("--seeds", type=int, default=1)
    args = ap.parse_args()
    os.makedirs(args.out, exist_ok=True)
    env = env_with_tools()
    bad = 0
    total = 0
    for cfg in configs(args.mode):
        for seed in range(1, args.seeds + 1):
            tag, ok, log = run_one(cfg, args.rtl, args.out, env, seed)
            total += 1
            print("%-4s %s seed=%d" % ("PASS" if ok else "FAIL", tag, seed))
            if not ok:
                bad += 1
                print("\n".join(log.splitlines()[:25]))
    print("runs: %d, failed: %d" % (total, bad))
    return 1 if bad else 0


if __name__ == "__main__":
    sys.exit(main())
