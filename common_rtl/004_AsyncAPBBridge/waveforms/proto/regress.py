"""Random regression of the prototype: random transfers, wait states and errors over handshake types, synchronizer depths,
APB4 / APB5 and clock ratios. Every transfer is checked on both interfaces against the stimulus tables.
Usage: python regress.py   (needs iverilog and vvp in PATH)."""
import os
import random
import re
import subprocess
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
BUILD = os.path.join(HERE, "build")
os.makedirs(BUILD, exist_ok=True)

bad = 0
runs = 0
rnd = random.Random(7)
ratios = [(5, 5), (2, 6), (6, 2), (3, 7), (7, 3), (5, 10), (10, 5), (4, 5), (1, 9), (9, 1)]
for hs in (0, 1):
    for stages in (2, 3):
        for apb5 in (0, 1):
            for hm, hs_ in ratios:
                nx = 40
                name = "reg"
                with open(os.path.join(BUILD, name + "_req.txt"), "w") as f:
                    for i in range(nx):
                        wr = rnd.randint(0, 1)
                        f.write("%d %d %x %x %x %x %x\n" % (rnd.choice([0, 0, 1, 2, 5]), wr, rnd.randrange(0, 1 << 16, 4),
                                                           rnd.randint(1, 3) if wr else 0, rnd.randrange(1 << 16) if wr else 0,
                                                           rnd.randrange(16), rnd.randrange(16) if wr else 0))
                with open(os.path.join(BUILD, name + "_cmp.txt"), "w") as f:
                    for i in range(nx):
                        f.write("%d %d %x %x %x\n" % (rnd.choice([0, 0, 1, 3, 6]), rnd.randint(0, 1), rnd.randrange(1 << 16),
                                                      rnd.randrange(16), rnd.randrange(16)))
                vvp = os.path.join(BUILD, name + ".vvp")
                cmd = ["iverilog", "-g2012", "-o", vvp, "-Ptb_wave.HM=%d" % hm, "-Ptb_wave.HS_=%d" % hs_,
                       "-Ptb_wave.DT=1", "-Ptb_wave.NX=%d" % nx, "-Ptb_wave.HS=%d" % hs, "-Ptb_wave.STAGES=%d" % stages,
                       "-Ptb_wave.APB5=%d" % apb5, "-Ptb_wave.REGRESS=1", "-Ptb_wave.NSLOT=100",
                       os.path.join(HERE, "apbcdc_proto.sv"), os.path.join(HERE, "tb_wave.sv")]
                subprocess.run(cmd, check=True, capture_output=True)
                out = subprocess.run(["vvp", vvp, "+STIM=" + os.path.join(BUILD, name).replace("\\", "/")],
                                     capture_output=True, text=True, timeout=300).stdout
                runs += 1
                m = re.search(r"RESULT errors=(\d+) requester_done=(\d+) completer_done=(\d+) nreq=(\d+)", out)
                if not m or m.group(1) != "0" or m.group(2) != m.group(4) or m.group(3) != m.group(4):
                    bad += 1
                    print("FAIL hs=%d stages=%d apb5=%d ratio=%d:%d" % (hs, stages, apb5, hm, hs_), m.group(0) if m else "NO RESULT",
                          [l for l in out.splitlines() if l.startswith("ERR")][:3])
print("random regression done, runs: %d, failures: %d" % (runs, bad))
sys.exit(1 if bad else 0)
