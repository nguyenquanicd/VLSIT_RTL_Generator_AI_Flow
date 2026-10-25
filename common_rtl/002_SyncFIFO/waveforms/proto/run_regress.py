"""Regression and gap-free depth sweep of the prototype (needs iverilog and vvp in PATH, with the lib folder
of the OSS CAD Suite). Usage: python run_regress.py [random|sweep]"""
import os
import re
import subprocess
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
BUILD = os.path.join(HERE, "build")
os.makedirs(BUILD, exist_ok=True)


def run(depth, retime, hw, hr, mode, n=400, pw=60, pr=60, seed=1):
    out = os.path.join(BUILD, "r_%d_%d_%d_%d_%d.vvp" % (depth, retime, hw, hr, mode))
    cmd = ["iverilog", "-g2012", "-o", out,
           "-Ptb_regress.DEPTH=%d" % depth, "-Ptb_regress.RETIME=%d" % retime,
           "-Ptb_regress.HW=%d" % hw, "-Ptb_regress.HR=%d" % hr, "-Ptb_regress.MODE=%d" % mode,
           "-Ptb_regress.N=%d" % n, "-Ptb_regress.PW=%d" % pw, "-Ptb_regress.PR=%d" % pr,
           "-Ptb_regress.SEED=%d" % seed,
           os.path.join(HERE, "sfifo_proto.sv"), os.path.join(HERE, "tb_regress.sv")]
    subprocess.run(cmd, check=True, capture_output=True)
    res = subprocess.run(["vvp", out], capture_output=True, text=True).stdout
    m = re.search(r"RESULT (.*)", res)
    errs = [l for l in res.splitlines() if l.startswith("ERR")]
    return (m.group(1) if m else "NO RESULT"), errs


def kv(s):
    return dict(p.split("=") for p in s.split() if "=" in p)


if __name__ == "__main__":
    what = sys.argv[1] if len(sys.argv) > 1 else "sweep"
    ratios = [(5, 5), (6, 4), (4, 6), (5, 10), (10, 5), (3, 7)]
    if what == "random":
        bad = 0
        for depth in (2, 3, 5, 8, 12):
            for retime in (0, 1):
                for hw, hr in ratios:
                    for seed in (1, 2, 3):
                        res, errs = run(depth, retime, hw, hr, 0, n=300, pw=40 + 15 * seed, pr=70 - 15 * seed + 15, seed=seed)
                        if "errors=0" not in res or errs:
                            bad += 1
                            print("FAIL", res, errs[:2])
        print("random regression done, failures:", bad)
    else:
        print("depth retime wr/rd(half ns) wstall rstall (continuous write and read, 400 words)")
        for retime in (0, 1):
            for hw, hr in ratios:
                row = []
                for depth in (2, 3, 4, 5, 6, 8, 12):
                    res, errs = run(depth, retime, hw, hr, 1)
                    d = kv(res)
                    row.append("D%d:w%s/r%s%s" % (depth, d.get("wstall", "?"), d.get("rstall", "?"), "" if d.get("errors") == "0" else "!ERR"))
                print("retime=%d wr=%d rd=%d  " % (retime, hw, hr) + "  ".join(row))


def min_depth_table():
    """Smallest DEPTH for which the side that is not limited by the clock rates never stalls (continuous traffic)."""
    ratios = [(5, 5), (1, 1), (6, 4), (4, 6), (5, 10), (10, 5), (3, 7), (7, 3), (2, 9), (9, 2), (8, 3), (3, 8), (7, 5), (5, 7)]
    print("min depth for gap-free streaming of the rate-matched or slower side")
    for retime in (0, 1):
        worst = 0
        for hw, hr in ratios:
            found = None
            for depth in range(2, 13):
                res, errs = run(depth, retime, hw, hr, 1, n=300)
                d = kv(res)
                ok = d.get("errors") == "0" and (hw < hr or d["wstall"] == "0") and (hw > hr or d["rstall"] == "0")
                if ok:
                    found = depth
                    break
            worst = max(worst, found or 99)
            print("retime=%d wr_half=%d rd_half=%d  min depth = %s" % (retime, hw, hr, found))
        print("retime=%d worst case over these ratios: %d" % (retime, worst))
