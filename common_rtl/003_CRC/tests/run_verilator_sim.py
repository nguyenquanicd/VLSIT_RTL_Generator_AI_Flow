"""Build and run one timed SystemVerilog testbench with Verilator and g++."""
from pathlib import Path
import argparse
import os
import shutil
import subprocess
import sys


def run(cmd, cwd, env):
    return subprocess.run(cmd, cwd=cwd, env=env, capture_output=True, text=True)


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("testbench")
    parser.add_argument("top_module")
    parser.add_argument("--seed", type=int, default=20261025)
    parser.add_argument("--random-count", type=int, default=32)
    parser.add_argument("--verilator", default="verilator")
    parser.add_argument("--cxx", default="g++")
    parser.add_argument("--verilator-root", required=True)
    parser.add_argument("--rtl-file", help="alternate RTL source, used for mutation testing")
    parser.add_argument("--expect-fail", action="store_true")
    parser.add_argument("--log-name", default=None)
    args = parser.parse_args()

    root = Path(__file__).resolve().parents[1]
    build = root / "sanity" / "build"
    build.mkdir(parents=True, exist_ok=True)
    logs = root / "sanity" / "logs"
    logs.mkdir(parents=True, exist_ok=True)
    tag = args.log_name or args.testbench
    obj = build / ("obj_" + tag)
    if obj.exists():
        shutil.rmtree(obj)
    obj.mkdir(parents=True)
    rtl_file = args.rtl_file or ("rtl/" + args.top_module + ".sv")
    executable = obj / (tag + ".exe")
    log_path = logs / (tag + ".log")
    env = os.environ.copy()
    env["VERILATOR_ROOT"] = args.verilator_root

    verilator_cmd = [
        args.verilator, "--cc", "--timing", "--main", "-Wno-fatal", "-Itests",
        "--top-module", args.testbench, "--Mdir", str(obj),
        "tests/" + args.testbench + ".sv", rtl_file,
    ]
    ver_run = run(verilator_cmd, root, env)
    report = ["Timed simulation: Verilator + g++", "$ " + " ".join(verilator_cmd),
              ver_run.stdout, ver_run.stderr]
    if ver_run.returncode != 0:
        log_path.write_text("\n".join(report), encoding="utf-8", newline="\n")
        print(ver_run.stdout, end="")
        print(ver_run.stderr, end="", file=sys.stderr)
        print("compile/elaboration failed; log: %s" % log_path)
        return 2

    include = Path(args.verilator_root) / "include"
    cpp_files = sorted(obj.glob("V" + args.testbench + "*.cpp"))
    if not cpp_files:
        print("ERROR: Verilator generated no C++ source files")
        return 2
    compile_cmd = [
        args.cxx, "-std=gnu++17", "-fcoroutines", "-O0", "-DVL_TIME_CONTEXT", "-DVM_TIMING=1",
        "-I" + str(obj), "-I" + str(include), "-I" + str(include / "vltstd"),
    ] + [str(path) for path in cpp_files] + [
        str(include / "verilated.cpp"), str(include / "verilated_timing.cpp"),
        str(include / "verilated_threads.cpp"), "-pthread", "-o", str(executable),
    ]
    cxx_run = run(compile_cmd, root, env)
    report += ["$ " + " ".join(compile_cmd), cxx_run.stdout, cxx_run.stderr]
    if cxx_run.returncode != 0:
        log_path.write_text("\n".join(report), encoding="utf-8", newline="\n")
        print(cxx_run.stdout, end="")
        print(cxx_run.stderr, end="", file=sys.stderr)
        print("C++ build failed; log: %s" % log_path)
        return 2

    sim_cmd = [str(executable), "+SEED=%d" % args.seed,
               "+N=%d" % args.random_count]
    sim_run = run(sim_cmd, root, env)
    report += ["$ " + " ".join(sim_cmd), sim_run.stdout, sim_run.stderr,
               "simulation exit code: %d" % sim_run.returncode]
    log_path.write_text("\n".join(report), encoding="utf-8", newline="\n")
    print(sim_run.stdout, end="")
    if sim_run.stderr:
        print(sim_run.stderr, end="", file=sys.stderr)

    if args.expect_fail:
        if sim_run.returncode != 0 and "ASSERT FAIL" in (sim_run.stdout + sim_run.stderr):
            print("PASS: injected fault was detected; log: %s" % log_path)
            return 0
        print("FAIL: injected fault was not detected; log: %s" % log_path)
        return 1
    if sim_run.returncode != 0:
        print("simulation failed; log: %s" % log_path)
        return 1
    print("PASS: %s; log: %s" % (args.testbench, log_path))
    return 0


if __name__ == "__main__":
    sys.exit(main())
