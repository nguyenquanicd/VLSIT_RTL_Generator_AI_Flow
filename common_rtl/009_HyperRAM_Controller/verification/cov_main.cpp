// Verilator main of the coverage simulation: runs the timing testbench to $finish and writes the
// coverage database. Usage: Vcov_bin [+cov_out=<file>] [+cov_trace]
#include <cstdio>
#include <memory>
#include <string>
#include "verilated.h"
#include "verilated_cov.h"
#include "Vcov.h"

// Required by the generated code; the time comes from the context (calling the context here would recurse).
double sc_time_stamp() { return 0.0; }

int main(int argc, char** argv) {
  setvbuf(stdout, NULL, _IONBF, 0);
  const std::unique_ptr<VerilatedContext> contextp{new VerilatedContext};
  contextp->commandArgs(argc, argv);
  const bool trace = contextp->commandArgsPlusMatch("cov_trace")[0] != '\0';
  if (trace) std::fprintf(stderr, "main start\n");
  const std::unique_ptr<Vcov> top{new Vcov{contextp.get(), "TOP"}};
  if (trace) std::fprintf(stderr, "constructed\n");
  uint64_t next_report = 0;
  while (!contextp->gotFinish()) {
    top->eval();
    if (!top->eventsPending()) break;
    contextp->time(top->nextTimeSlot());
    if (trace && contextp->time() >= next_report) {
      std::fprintf(stderr, "t=%llu ps\n", static_cast<unsigned long long>(contextp->time()));
      next_report += 100000000ULL;
    }
  }
  top->final();
  std::string out = "coverage.dat";
  const char* arg = contextp->commandArgsPlusMatch("cov_out");
  if (arg && std::string(arg).size() > 9) out = std::string(arg).substr(9);
  contextp->coveragep()->write(out.c_str());
  return 0;
}
