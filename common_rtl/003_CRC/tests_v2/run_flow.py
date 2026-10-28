"""Reproducible simulation and generic synthesis of the specified CRC stream IP.

The golden model uses integer polynomial long division (specification section 9),
not an RTL-derived recurrence. All tools, commands, vectors and logs are retained.
"""
from pathlib import Path
import argparse
import bisect
import concurrent.futures
import hashlib
import json
import os
import random
import re
import shutil
import subprocess
import sys

ROOT = Path(__file__).resolve().parents[1]
RTL = ROOT / "rtl_v2"
OUT = ROOT / "sanity_v2"
HERE = Path(__file__).resolve().parent
SUITE = Path(os.environ.get("OSS_CAD_SUITE", "C:/Tools/oss-cad-suite"))
SKILL = Path.home() / ".codex/skills"
SEEDS = [20261027, 19, 97]


def configs():
    items = []
    for reflected in (False, True):
        for method in range(5):
            items.append(dict(name=("ref" if reflected else "base") + str(method),
                method=method, width=8, data=1 if method == 0 else 32, poly=7,
                init=0x5A if reflected else 0, xor=0xA5 if reflected else 0,
                refin=int(reflected), refout=int(reflected), cal=8))
    items += [
        dict(name="chunk6_partial", method=3, width=6, data=24, poly=3,
             init=0x15, xor=0x2A, refin=1, refout=1, cal=6),
        dict(name="word8_crc16", method=2, width=16, data=8, poly=0x1021,
             init=0x1D0F, xor=0x55AA, refin=0, refout=0, cal=8),
        dict(name="chunk32", method=3, width=32, data=32, poly=0x04C11DB7,
             init=0xFFFFFFFF, xor=0xFFFFFFFF, refin=1, refout=1, cal=32),
        dict(name="full32", method=4, width=32, data=32, poly=0x04C11DB7,
             init=0xFFFFFFFF, xor=0xFFFFFFFF, refin=1, refout=1, cal=8),
    ]
    return items


def env():
    result = dict(os.environ)
    result["VERILATOR_ROOT"] = str(SUITE / "share/verilator")
    result["PATH"] = os.pathsep.join([str(SUITE / "bin"), str(SUITE / "lib"),
                                      result.get("PATH", "")])
    return result


def run(command, cwd, log, expected_failure=False):
    p = subprocess.run([str(x) for x in command], cwd=cwd, env=env(),
                       text=True, capture_output=True)
    text = "$ " + subprocess.list2cmdline([str(x) for x in command])
    text += "\nCWD: " + str(cwd) + "\n" + p.stdout + p.stderr
    text += "\nexit code: %d\n" % p.returncode
    log.parent.mkdir(parents=True, exist_ok=True)
    log.write_text(text, encoding="utf-8")
    if (p.returncode != 0) != expected_failure:
        raise RuntimeError("Unexpected tool result: %s\n%s" % (log, text[-6000:]))
    return p.stdout + p.stderr


def parameters(c):
    return dict(PARA_CRC_METHOD=c["method"], PARA_CRC_W=c["width"],
                PARA_DATA_W=c["data"], PARA_CRC_POLY=c["poly"],
                PARA_CRC_INIT=c["init"], PARA_CRC_XOR_OUT=c["xor"],
                PARA_CRC_REF_IN=c["refin"], PARA_CRC_REF_OUT=c["refout"],
                PARA_CAL_W=c["cal"])


def golden(payload, c):
    """Remainder of (INIT*x**N XOR payload)*x**W modulo the monic polynomial."""
    bits = "".join(format(b, "08b")[::-1] if c["refin"] else format(b, "08b")
                   for b in payload)
    dividend = ((c["init"] << len(bits)) ^ int(bits, 2)) << c["width"]
    divisor = (1 << c["width"]) | c["poly"]
    while dividend.bit_length() > c["width"]:
        dividend ^= divisor << (dividend.bit_length() - divisor.bit_length())
    if c["refout"]:
        dividend = int(format(dividend, "0%db" % c["width"])[::-1], 2)
    return dividend ^ c["xor"]


def vectors(c, seed, path):
    rng = random.Random(seed)
    # Directed lengths cover all legal final masks on 32-bit words, full words,
    # multiword frames, leading zeros, byte reflection and nonzero initialization.
    gen = [bytes.fromhex("a1b2"), b"\x00", b"\xff", bytes.fromhex("0180ff"),
           b"123456789", bytes(8), bytes([255] * 17)]
    chk = [b"\x12", bytes.fromhex("3456"), b"\x00", b"\xff", b"123456789"]
    for frames in (gen, chk):
        while len(frames) < 64:
            frames.append(bytes(rng.randrange(256) for _ in range(rng.randrange(1, 32))))
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text("".join("%s %s %08x\n" % (tag, data.hex(), golden(data, c))
                    for tag, frames in (("g", gen), ("c", chk)) for data in frames))


def build(c, rtl=RTL):
    obj = OUT / "build" / c["name"]
    obj.mkdir(parents=True, exist_ok=True)
    fingerprint = hashlib.sha256(json.dumps(c, sort_keys=True).encode() +
        (HERE / "tb_crc_engine.cpp").read_bytes() +
        b"".join(p.read_bytes() for p in sorted(rtl.glob("*.sv")))).hexdigest()
    key = obj / "build_key.txt"
    if key.exists() and key.read_text() == fingerprint and (obj / "sim.exe").exists():
        return obj / "sim.exe"
    cfg = dict(CFG_METHOD=c["method"], CFG_CRC_W=c["width"], CFG_DATA_W=c["data"],
               CFG_KEEP_W=(c["data"] + 7) // 8, CFG_REF_IN=c["refin"], CFG_CAL_W=c["cal"])
    (obj / "config.h").write_text("#pragma once\n" + "".join(
        "constexpr unsigned %s = %du;\n" % kv for kv in cfg.items()))
    cmd = [SUITE / "bin/verilator_bin.exe", "--cc", "--trace", "--trace-depth", "1",
           "--prefix", "Vcrc", "--top-module", "m_crc_engine", "--Mdir", obj]
    cmd += ["-G%s=32'h%08x" % kv for kv in parameters(c).items()]
    sources = [x.strip() for x in (RTL / "filelist.f").read_text().splitlines()
               if x.strip() and not x.startswith("//")]
    cmd += [rtl / x for x in sources]
    run(cmd, ROOT, obj / "verilate.log")
    inc = SUITE / "share/verilator/include"
    compiler = shutil.which("g++")
    if not compiler:
        raise RuntimeError("g++ not found")
    cmd = [compiler, "-std=c++17", "-O0", "-DVL_TIME_CONTEXT", "-DVM_TRACE=1",
           "-DVM_TRACE_VCD=1", "-I" + str(obj), "-I" + str(inc),
           "-I" + str(inc / "vltstd"), HERE / "tb_crc_engine.cpp"]
    cmd += sorted(obj.glob("Vcrc*.cpp"))
    cmd += [inc / "verilated.cpp", inc / "verilated_vcd_c.cpp",
            inc / "verilated_threads.cpp", "-pthread", "-o", obj / "sim.exe"]
    run(cmd, ROOT, obj / "compile.log")
    key.write_text(fingerprint)
    return obj / "sim.exe"


def simulate_one(c):
    executable = build(c)
    rows = []
    for seed in SEEDS:
        folder = OUT / "simulation" / c["name"] / str(seed)
        folder.mkdir(parents=True, exist_ok=True)
        vec = folder / "vectors.txt"
        vectors(c, seed, vec)
        trace = folder / "trace.vcd" if seed == SEEDS[0] and (
            c["name"].startswith("base") or c["name"] == "ref4") else "-"
        output = run([executable, vec, str(seed), trace, folder / "events.txt"],
                     ROOT, folder / "simulation.log")
        if "assertion failures: 0, assertions never exercised: 0" not in output:
            raise RuntimeError("Missing assertion completion: " + c["name"])
        assertions = re.findall(r"ASSERT (\S+) hits=(\d+) fails=(\d+)", output)
        rows.append(dict(config=c["name"], seed=seed, result="PASS",
                         frames=128, assertions=len(assertions),
                         assertion_hits=sum(int(a[1]) for a in assertions)))
    print("SIM PASS " + c["name"], flush=True)
    return rows


def simulate(selected):
    rows = []
    with concurrent.futures.ThreadPoolExecutor(max_workers=2) as pool:
        futures = [pool.submit(simulate_one, c) for c in selected]
        for f in concurrent.futures.as_completed(futures):
            rows.extend(f.result())
            save("simulation_results.json", rows)
    save("simulation_results.json", rows)


def synthesis(selected):
    rows = []
    for c in selected:
        folder = OUT / "synthesis" / c["name"]
        folder.mkdir(parents=True, exist_ok=True)
        opts = " ".join("-G %s=32'h%08x" % kv for kv in parameters(c).items())
        sources = " ".join(p.as_posix() for p in sorted(RTL.glob("*.sv")))
        script = "read_slang --std 1800-2017 --top m_crc_engine " + opts + " " + sources
        script += "\nhierarchy -check -top m_crc_engine\nsynth -top m_crc_engine\ncheck -assert\n"
        script += 'tee -o "%s" stat -json\n' % (folder / "stats.json").as_posix()
        script += 'write_verilog -noattr "%s"\n' % (folder / "netlist.v").as_posix()
        script += 'write_json "%s"\n' % (folder / "netlist.json").as_posix()
        ys = folder / "synth.ys"; ys.write_text(script)
        output = run([SUITE / "bin/yosys.exe", "-m", "slang", "-s", ys], ROOT, folder / "synthesis.log")
        stats = json.loads((folder / "stats.json").read_text())
        design = stats.get("design") or next(iter(stats["modules"].values()))
        cells = design["num_cells_by_type"]
        ff = sum(v for k, v in cells.items() if "DFF" in k.upper())
        latch = sum(v for k, v in cells.items() if "LATCH" in k.upper())
        if latch: raise RuntimeError("Latch found in " + c["name"])
        rows.append(dict(config=c["name"], result="PASS", cells=design["num_cells"],
                         flipflops=ff, combinational=design["num_cells"]-ff, latches=latch,
                         warnings=[line for line in output.splitlines() if "Warning:" in line]))
        save("synthesis_results.json", rows)
        print("SYNTH PASS %s cells=%d ff=%d" % (c["name"], design["num_cells"], ff), flush=True)
    save("synthesis_results.json", rows)


def mutation():
    folder = OUT / "mutation/rtl"
    folder.mkdir(parents=True, exist_ok=True)
    for p in RTL.glob("*.sv"): shutil.copy2(p, folder / p.name)
    source = folder / "m_crc_parallel.sv"
    body = source.read_text(); needle = "reg_crc_output <= f_finalize(w_crc_nxt);"
    if body.count(needle) != 1: raise RuntimeError("Mutation target is not unique")
    source.write_text(body.replace(needle,
        "reg_crc_output <= f_finalize(w_crc_nxt) ^ $bits(reg_crc_output)'(1'b1);"))
    c = dict(configs()[2]); c["name"] = "mutation_crc_bit"
    exe = build(c, folder)
    vec = OUT / "mutation/vectors.txt"; vectors(c, SEEDS[0], vec)
    output = run([exe, vec, str(SEEDS[0]), "-", OUT / "mutation/events.txt"], ROOT,
                 OUT / "mutation/simulation.log", expected_failure=True)
    if "ASSERT FAIL REQ_FUNC_" not in output: raise RuntimeError("Mutation not caught by scoreboard")
    save("mutation_results.json", dict(result="PASS", detected=True,
         fault="Invert generated CRC bit 0 on a copied method-2 module"))
    print("MUTATION PASS: CRC corruption detected", flush=True)


def save(name, obj):
    OUT.mkdir(parents=True, exist_ok=True)
    (OUT / name).write_text(json.dumps(obj, indent=2) + "\n")


def parse_vcd(path):
    text = path.read_text(); split = text.index("$enddefinitions $end") + len("$enddefinitions $end")
    header = text[:split] + "\n"
    names = {}; widths = {}; depth = 0
    for line in header.splitlines():
        fields = line.split()
        if not fields: continue
        if fields[0] == "$scope": depth += 1
        if fields[0] == "$upscope": depth -= 1
        if fields[0] == "$var":
            widths[fields[3]] = int(fields[2])
            if depth == 1: names[fields[4]] = fields[3]
    changes = {}; timestamp = 0
    for line in text[split:].splitlines():
        line = line.strip()
        if line.startswith("#"): timestamp = int(line[1:])
        elif line and line[0] in "01xzXZ":
            changes.setdefault(line[1:], []).append((timestamp, line[0].lower()))
        elif line.startswith("b"):
            value, code = line[1:].split()
            changes.setdefault(code, []).append((timestamp, value.lower()))
    return header, names, widths, changes


def evidence():
    output = HERE / "waveforms_sim"; output.mkdir(parents=True, exist_ok=True)
    cache = {}
    index = ["# Specification waveform comparison / Đối chiếu waveform đặc tả", "",
        "These are measured VCD windows from the delivered RTL. The specification figures",
        "use illustrative data and shorter stalls; literal drawings therefore differ.",
        "The scoreboard separately checks the normative CRC, latency and handshake requirements.",
        "No RTL or golden-model expectation was changed to match an illustration.", "",
        "Đây là waveform đo từ simulation. Dữ liệu và thời gian stall khác hình minh họa;",
        "scoreboard kiểm tra riêng CRC, latency và handshake theo yêu cầu đặc tả.", "",
        "| Waveform ID | Specification figure | Simulated waveform | Result | Note |",
        "|---|---|---|---|---|"]
    mapping = [(1,"base2","reset_abort"),(2,"base0","gen"),(3,"base1","gen"),
               (4,"base2","gen"),(5,"base3","gen"),(6,"ref4","gen"),
               (7,"base2","gen"),(8,"base2","check"),(9,"base2","check"),
               (10,"base2","gen")]
    for wid, config, channel in mapping:
        folder = OUT / "simulation" / config / str(SEEDS[0])
        events = [line.split() for line in (folder / "events.txt").read_text().splitlines()]
        if wid == 1:
            event = next(e for e in events if e[0] == channel)
            first, last = map(int, event[1:])
        else:
            event = next(e for e in events if e[0] == channel and e[1] == ("1" if wid == 9 else "0"))
            start, final, valid, done = map(int, event[2:])
            first, last = max(1,start-1), valid+3
            if wid == 7: first, last = valid-1, valid+12
            if wid == 10: first, last = valid+1, valid+30
            if wid in (8,9): last = done+2
        source = folder / "trace.vcd"
        if config not in cache: cache[config] = parse_vcd(source)
        header, names, widths, changes = cache[config]
        specjson = next((ROOT / "figures/waveforms").glob("WF_%03d_*.json" % wid))
        original = json.loads(specjson.read_text())
        stem = specjson.stem; begin = (first-1)*10000; end = last*10000
        def value_at(code, time):
            values = changes[code]
            position = bisect.bisect_right(values, (time, "z"))-1
            return values[max(0,position)][1]
        signals = []
        for row in original["signal"]:
            if not isinstance(row, dict) or "name" not in row: continue
            name = row["name"]; plain = re.sub(r"\[[^]]+\]$", "", name)
            if plain not in names: raise RuntimeError("Missing VCD port: " + name)
            code = names[plain]; wave = ""; data = []; previous = None
            if name != plain:
                name = plain + ("[%d:0]" % (widths[code]-1) if widths[code] > 1 else "[0]")
            for time in range(begin, end+1, 5000):
                current = value_at(code, time)
                if current == previous: wave += "."
                elif widths[code] == 1: wave += current
                elif "x" in current or "z" in current: wave += "x"
                else: wave += "="; data.append("0x%X" % int(current,2))
                previous = current
            item = dict(name=name, wave=wave)
            if data: item["data"] = data
            signals.append(item)
        wavejson = dict(signal=signals, head=dict(text="WF-%03d measured: %s" % (wid,config)),
            foot=dict(text="5 ns per slot; cycles %d to %d; seed %d" % (first,last,SEEDS[0])),
            config=dict(hscale=1))
        dest = output / (stem + ".json"); dest.write_text(json.dumps(wavejson,indent=2))
        lines = [header, "#0\n"]
        def encoded(code, value):
            return (value+code if widths.get(code)==1 else "b"+value+" "+code)+"\n"
        for code in changes: lines.append(encoded(code,value_at(code,begin)))
        selected = sorted((time,code,value) for code,values in changes.items()
                          for time,value in values if begin < time <= end)
        oldtime = None
        for time,code,value in selected:
            if time != oldtime: lines.append("#%d\n" % (time-begin)); oldtime=time
            lines.append(encoded(code,value))
        (output / (stem+".vcd")).write_text("".join(lines))
        run([sys.executable, SKILL / "vlsit-asic-ip-microspec/scripts/vlsit_waveform_svg.py",
             "render", dest, "--out", output / (stem+".svg"), "--force"], ROOT,
             output / (stem+"_render.log"))
        index.append("| WF-%03d | %s | %s.svg | DIFFERENT | Measured %s cycles %d–%d; "
                     "illustrative stimulus differs; requirement assertions pass. Retain measured evidence; "
                     "no RTL/specification change. |" %
                     (wid, specjson.with_suffix(".svg").relative_to(ROOT).as_posix(),stem,config,first,last))
    (output / "waveform_compare.md").write_text("\n".join(index)+"\n", encoding="utf-8")
    run([sys.executable, SKILL / "vlsit-rtl-generator/scripts/vlsit_sim_evidence.py", "check",
         ROOT / "CRC_Design_Specification.md", output, "--cdc", "no"], ROOT,
         output / "evidence_check.log")
    print("WAVEFORMS: 10 measured VCD/JSON/SVG windows; literal drawing differences documented",flush=True)


def report():
    def load(name, default):
        p=OUT/name
        return json.loads(p.read_text()) if p.exists() else default
    sim=load("simulation_results.json",[]); synth=load("synthesis_results.json",[])
    mut=load("mutation_results.json",{})
    lines=["# CRC simulation and synthesis / Simulation và synthesis CRC", "",
        "Source: `rtl_v2/m_crc_engine.sv`; golden contract: `CRC_Design_Specification.md`.",
        "RTL source hashes are recorded in `rtl_source_hashes.json`; this run changes no design RTL.", "",
        "## Simulation", "",
        "%d configurations, %d runs, %d completed frames (generation and checking combined)." %
        (len(set(r['config'] for r in sim)),len(sim),sum(r['frames'] for r in sim)),
        "Golden values use arbitrary-precision polynomial long division in Python. The C++",
        "testbench drives only the top ports and checks handshakes, CRCs, exact final-beat",
        "latency, matching/mismatching references, backpressure, reset aborts and independent progress.",
        "Each configuration uses seeds 20261027, 19 and 97; 64 frames per channel per seed.",
        "Verilator uses two-state simulation; X propagation, formal proof and code coverage are not claimed.", "",
        "| Configuration | Runs | Frames | Assertion checks per run | Result |",
        "|---|---:|---:|---:|---|"]
    for name in sorted(set(r['config'] for r in sim)):
        rows=[r for r in sim if r['config']==name]
        lines.append("| %s | %d | %d | %d | PASS |" %
                     (name,len(rows),sum(r['frames'] for r in rows),rows[0]['assertions']))
    lines += ["", "Mutation: **%s**. An intentionally inverted CRC bit in a copied method-2 RTL "
              "must fail the requirement scoreboard; see `mutation/simulation.log`." %
              (mut.get("result","NOT RUN")), "", "## Generic synthesis / Tổng hợp generic", "",
        "Yosys + slang elaborates each configuration, runs `synth`, ABC generic mapping,",
        "and `check -assert`, and saves the netlist, statistics, command script and full log.",
        "No standard-cell Liberty library is selected. Counts below are generic cells, not",
        "ASIC area, NAND2 equivalents, or timing signoff. Flip-flops include data/control state.", "",
        "| Configuration | Total cells | Flip-flops | Combinational cells | Latches | Result |",
        "|---|---:|---:|---:|---:|---|"]
    for row in synth:
        lines.append("| {config} | {cells} | {flipflops} | {combinational} | {latches} | {result} |".format(**row))
    warnings={w for r in synth for w in r.get("warnings",[])}
    lines += ["", "Synthesis diagnostics: CRC-width-32 configurations can report three",
        "`shift-count-overflow` warnings in the parameter high-bit legality checks. Shifting",
        "a 32-bit unsigned value right by 32 intentionally yields zero; all 32 bits are active.",
        "These are elaboration checks, not datapath shifts. No warnings are suppressed.",
        "Synthesis completed with no inferred latches or structural check failures.", "",
        "## Evidence and reproduction / Bằng chứng và chạy lại", "",
        "From the CRC directory: `make v2-verify`. Individual targets: `v2-sim`, `v2-synth`,",
        "`v2-mutation`, `v2-waveforms`, `v2-report`; `make v2-help` describes them.",
        "The single project Makefile owns all run commands. Test sources are in `tests_v2/`;",
        "vectors, assertion-hit tables, tool commands and logs are retained in `sanity_v2/`.",
        "Ten actual VCD/JSON/SVG windows are in `tests_v2/waveforms_sim/`.",
        "The comparison index labels literal differences from illustrative specification figures;",
        "functional and cycle-contract checks are reported separately by the assertions.", "",
        "Đã kiểm tra CRC bằng mô hình chia đa thức độc lập, reset, stall và hai kênh đồng thời.",
        "Synthesis dùng cell generic; số cell không phải diện tích hoặc timing của thư viện ASIC.",
        "Có thể chạy lại toàn bộ bằng `make v2-verify`; không chỉnh RTL để làm test pass.", ""]
    (OUT/"verification_report.md").write_text("\n".join(lines),encoding="utf-8")
    print("Report: " + str(OUT/"verification_report.md"),flush=True)


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("action", choices=["sim", "synth", "mutation", "all", "report", "evidence"])
    parser.add_argument("--config", help="Comma-separated configuration names")
    args = parser.parse_args()
    selected = [c for c in configs() if not args.config or c["name"] in args.config.split(",")]
    if not selected: parser.error("No matching configuration")
    before = {p.name: hashlib.sha256(p.read_bytes()).hexdigest() for p in RTL.glob("*.sv")}
    save("rtl_source_hashes.json", before)
    if args.action in ("sim", "all"): simulate(selected)
    if args.action in ("synth", "all"): synthesis(selected)
    if args.action in ("mutation", "all"): mutation()
    if args.action in ("evidence", "all"): evidence()
    if args.action in ("report", "all"): report()
    after = {p.name: hashlib.sha256(p.read_bytes()).hexdigest() for p in RTL.glob("*.sv")}
    if before != after: raise RuntimeError("RTL changed during verification")
    print("RTL source hashes unchanged", flush=True)


if __name__ == "__main__":
    try: main()
    except Exception as exc:
        print("ERROR: " + str(exc), file=sys.stderr)
        sys.exit(1)
