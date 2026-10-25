"""Measure the transfer duration of the prototype for several handshake types, synchronizer depths and clock ratios and
compare it with the analytic upper bound of the specification (section 10.4). Writes waveforms/apbcdc_latency_table.txt."""
import os
import gen_waves as g

rows = ["hs stages wait Tmst Tslv measured_ns bound_ns ok"]
bad = 0
for hs in (0, 1):
    for stages in (2, 3, 4):
        for hm, hs_ in ((5, 5), (2, 6), (6, 2), (3, 7), (7, 3), (5, 10), (10, 5), (4, 5)):
            for waits in (0, 2):
                dt, start, samples = g.run_sim("lat", [(2, 1, 0x40, 3, 0xA1B2, 0, 0)], [(waits, 0, 0, 0, 0)], hm, hs_, hs, stages,
                                              0, 200)
                s0 = int(round((start - dt / 2.0) / dt))
                sel = samples[s0:]
                ps = g.rise(sel, "m_psel")
                pr = g.rise(sel, "m_pready")
                # duration from the start of the SETUP cycle to the end of the PREADY cycle (requester clock period 2*hm)
                tm, ts = 2 * hm, 2 * hs_
                meas = sel[pr][0] - sel[ps][0] + tm
                n = stages
                if hs == 0:
                    bound = (n + 3) * tm + (n + 3 + waits) * ts
                else:
                    bound = (2 * n + 4) * tm + (2 * n + 4 + waits) * ts
                ok = meas <= bound + 1e-6
                bad += 0 if ok else 1
                rows.append("%d %d %d %d %d %.1f %d %s" % (hs, stages, waits, tm, ts, meas, bound, "ok" if ok else "VIOLATION"))
rows.append("violations of the bound: %d" % bad)
open(os.path.join(g.OUT, "apbcdc_latency_table.txt"), "w").write("\n".join(rows) + "\n")
print("\n".join(rows[:12])); print(rows[-1])
