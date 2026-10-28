// Specification-based testbench for REQ-FUNC-001..003, REQ-IF-001..005,
// REQ-RESET-001 and specification section 10.4. Golden CRCs come from Python
// polynomial long division, independently of the RTL implementation.
#include "Vcrc.h"
#include "verilated.h"
#include "verilated_vcd_c.h"
#include "config.h"
#include <algorithm>
#include <cstdint>
#include <fstream>
#include <iostream>
#include <map>
#include <memory>
#include <random>
#include <sstream>
#include <stdexcept>
#include <string>
#include <vector>

struct Frame { std::vector<uint8_t> bytes; uint32_t crc; };
struct Check { unsigned hits=0, fails=0; };
std::map<std::string, Check> checks;
void ck(const std::string& name, bool ok) {
    auto& c=checks.at(name); ++c.hits;
    if (!ok) { ++c.fails; std::cerr<<"ASSERT FAIL "<<name<<"\n";
        throw std::runtime_error(name); }
}

struct Sim {
    VerilatedContext context;
    Vcrc dut{&context};
    std::unique_ptr<VerilatedVcdC> trace;
    unsigned cycle=0;
    explicit Sim(const char* path) {
        if (std::string(path)!="-") {
            context.traceEverOn(true); trace=std::make_unique<VerilatedVcdC>();
            dut.trace(trace.get(), 1); trace->open(path);
        }
        dut.i_rst_n_crc=0; dut.i_gen_valid=0; dut.i_check_valid=0;
        dut.i_gen_crc_ready=0; dut.i_check_crc_ready=0;
        dut.i_gen_data=0; dut.i_check_data=0; dut.i_gen_keep=1;
        dut.i_check_keep=1; dut.i_gen_last=0; dut.i_check_last=0; dut.i_check_crc=0;
    }
    void settle() { dut.i_clk_crc=0; dut.eval(); }
    void tick() {
        settle(); if(trace) trace->dump(context.time());
        context.timeInc(5000); dut.i_clk_crc=1; dut.eval();
        if(trace) trace->dump(context.time()); context.timeInc(5000); ++cycle;
    }
    ~Sim() { dut.final(); if(trace) trace->close(); }
};

void reset_checks(Sim& s) {
    ck("REQ_RESET_001_gen_valid", !s.dut.o_gen_crc_valid);
    ck("REQ_RESET_001_check_valid", !s.dut.o_check_crc_valid);
    ck("REQ_RESET_001_gen_crc", s.dut.o_gen_crc==0);
    ck("REQ_RESET_001_check_pass", !s.dut.o_check_pass);
}

void reset_scenarios(Sim& s, std::ofstream& events) {
    auto& d=s.dut; s.tick(); s.tick(); reset_checks(s);
    d.i_rst_n_crc=1; d.i_gen_valid=1; d.i_check_valid=1;
    d.i_gen_data=1; d.i_check_data=0; d.i_gen_keep=(1u<<CFG_KEEP_W)-1;
    d.i_check_keep=d.i_gen_keep;
    bool ga=false, ca=false;
    for (unsigned n=0; n<1000 && !(ga&&ca); ++n) {
        s.settle(); bool g=d.i_gen_valid&&d.o_gen_data_ready;
        bool c=d.i_check_valid&&d.o_check_data_ready; s.tick();
        if(g) {ga=true; d.i_gen_valid=0;} if(c) {ca=true; d.i_check_valid=0;}
    }
    if(!(ga&&ca)) throw std::runtime_error("reset stimulus acceptance timeout");
    s.tick(); d.i_rst_n_crc=0; s.tick(); reset_checks(s);
    unsigned abort=s.cycle; d.i_rst_n_crc=1;
    for(unsigned n=0;n<80;++n) {s.tick(); ck("REQ_RESET_001_no_stale",
        !d.o_gen_crc_valid&&!d.o_check_crc_valid);}
    events<<"reset_abort "<<abort-3<<" "<<abort+4<<"\n";
    // Also reset both channels while their results are stalled.
    d.i_gen_valid=1; d.i_check_valid=1; d.i_gen_last=1; d.i_check_last=1;
    ga=false; ca=false;
    for(unsigned n=0;n<2000;++n) {
        s.settle(); bool g=d.i_gen_valid&&d.o_gen_data_ready;
        bool c=d.i_check_valid&&d.o_check_data_ready; s.tick();
        if(g) {ga=true; d.i_gen_valid=0;} if(c) {ca=true; d.i_check_valid=0;}
        if(ga&&ca&&d.o_gen_crc_valid&&d.o_check_crc_valid) break;
        if(n==1999) throw std::runtime_error("pending-result reset timeout");
    }
    d.i_rst_n_crc=0; s.tick(); reset_checks(s); unsigned pending=s.cycle;
    d.i_rst_n_crc=1; d.i_gen_last=0; d.i_check_last=0;
    for(unsigned n=0;n<80;++n) {s.tick(); ck("REQ_RESET_001_no_stale",
        !d.o_gen_crc_valid&&!d.o_check_crc_valid);}
    events<<"reset_pending "<<pending-3<<" "<<pending+4<<"\n";
}

struct Channel {
    bool checker, holding=false, pending=false, seen=false;
    bool old_in_stall=false, old_out_stall=false, old_last=false;
    unsigned frame=0, beat=0, age=0, start=0, final=0, first_valid=0, latency=0;
    uint32_t data=0, keep=0, ref=0, old_data=0, old_keep=0, old_ref=0, old_result=0;
    std::vector<Frame> frames;
    std::mt19937 rng;
    Channel(bool c,unsigned seed):checker(c),rng(seed) {}
    unsigned beats() const {
        unsigned n=frames.at(frame).bytes.size();
        return CFG_METHOD==0?n*8:(n+CFG_DATA_W/8-1)/(CFG_DATA_W/8);
    }
    void prepare() {
        const auto& f=frames.at(frame); data=0; keep=0;
        if(CFG_METHOD==0) {
            unsigned b=f.bytes[beat/8], pos=CFG_REF_IN?beat%8:7-beat%8;
            data=(b>>pos)&1; keep=1;
        } else {
            unsigned lanes=CFG_DATA_W/8;
            for(unsigned j=0;j<lanes;++j) {
                unsigned p=beat*lanes+j;
                if(p<f.bytes.size()) {data|=uint32_t(f.bytes[p])<<(8*(lanes-1-j));
                    keep|=1u<<(lanes-1-j);}
            }
        }
        ref=(beat+1==beats())?(f.crc^((checker&&(frame%2))?1u:0u)):rng();
    }
    void drive(Sim& s) {
        if(!pending && frame<frames.size() && !holding && (rng()%4!=0)) {
            holding=true; prepare();
        }
        bool last=holding&&(beat+1==beats());
        unsigned delay=(!checker&&frame==0)?80:5+(frame%7);
        bool ready=pending&&seen&&age>=delay&&(rng()%4!=0);
        if(checker) {s.dut.i_check_valid=holding; s.dut.i_check_data=data;
            s.dut.i_check_keep=keep; s.dut.i_check_last=last;
            s.dut.i_check_crc=ref; s.dut.i_check_crc_ready=ready;}
        else {s.dut.i_gen_valid=holding; s.dut.i_gen_data=data;
            s.dut.i_gen_keep=keep; s.dut.i_gen_last=last; s.dut.i_gen_crc_ready=ready;}
    }
    bool inready(const Sim& s) const {return checker?s.dut.o_check_data_ready:s.dut.o_gen_data_ready;}
    bool outvalid(const Sim& s) const {return checker?s.dut.o_check_crc_valid:s.dut.o_gen_crc_valid;}
    bool outready(const Sim& s) const {return checker?s.dut.i_check_crc_ready:s.dut.i_gen_crc_ready;}
    uint32_t result(const Sim& s) const {return checker?s.dut.o_check_pass:s.dut.o_gen_crc;}
    std::string tag() const {return checker?"check":"gen";}
    void before(const Sim& s) {
        std::string t=tag(); bool valid=outvalid(s), ready=outready(s);
        if(valid) {ck("REQ_IF_001_"+t+"_no_orphan",pending);
            ck("REQ_IF_003_"+t+"_block",!inready(s));}
        if(old_out_stall) {ck("REQ_IF_003_"+t+"_hold_valid",valid);
            ck("REQ_IF_003_"+t+"_hold_result",result(s)==old_result);}
        if(old_in_stall && CFG_METHOD!=0) ck("REQ_IF_002_"+t+"_input_stable",
            holding&&data==old_data&&keep==old_keep&&ref==old_ref&&
            (beat+1==beats())==old_last);
        old_out_stall=valid&&!ready; old_result=result(s);
        old_in_stall=holding&&!inready(s); old_data=data; old_keep=keep; old_ref=ref;
        old_last=holding&&(beat+1==beats());
    }
    void after(const Sim& s,bool accept,bool consume,std::ofstream& events) {
        if(consume) {
            events<<tag()<<" "<<frame<<" "<<start<<" "<<final<<" "
                <<first_valid<<" "<<s.cycle<<"\n";
            ++frame; beat=0; pending=false; seen=false; age=0;
        }
        if(accept) {
            if(beat==0) start=s.cycle;
            bool last=beat+1==beats();
            uint32_t mask=CFG_METHOD==0?1u:(1u<<CFG_KEEP_W)-1;
            bool legal=keep!=0&&((keep|(keep-1))==mask);
            ck("REQ_IF_004_"+tag()+"_mask",legal&&(last||keep==mask));
            if(last) {
                pending=true; final=s.cycle;
                unsigned bits=CFG_METHOD==0?1:8*__builtin_popcount(keep);
                latency=CFG_METHOD==0?CFG_CRC_W:CFG_METHOD==1?bits+CFG_CRC_W:
                    CFG_METHOD==3?(bits+CFG_CAL_W-1)/CFG_CAL_W+1:1;
            }
            ++beat; holding=false;
        }
        if(outvalid(s)) {
            ck("REQ_IF_001_"+tag()+"_no_orphan",pending);
            if(!seen) {seen=true; first_valid=s.cycle;
                ck("SPEC_10_4_"+tag()+"_latency",s.cycle-final==latency);}
            if(checker) ck(frame%2?"REQ_FUNC_003_mismatch":"REQ_FUNC_003_match",
                result(s)==unsigned(frame%2==0));
            else ck("REQ_FUNC_001_gen_crc",result(s)==frames.at(frame).crc);
            ++age;
        }
    }
};

int main(int argc,char** argv) {
    const std::vector<std::string> names={"REQ_RESET_001_gen_valid","REQ_RESET_001_check_valid",
        "REQ_RESET_001_gen_crc","REQ_RESET_001_check_pass","REQ_RESET_001_no_stale",
        "REQ_IF_001_gen_no_orphan","REQ_IF_001_check_no_orphan","REQ_FUNC_001_gen_crc",
        "REQ_FUNC_003_match","REQ_FUNC_003_mismatch","REQ_IF_003_gen_hold_valid",
        "REQ_IF_003_gen_hold_result","REQ_IF_003_check_hold_valid","REQ_IF_003_check_hold_result",
        "REQ_IF_003_gen_block","REQ_IF_003_check_block","SPEC_10_4_gen_latency",
        "SPEC_10_4_check_latency","REQ_IF_004_gen_mask","REQ_IF_004_check_mask",
        "REQ_IF_005_independent_progress","REQ_IF_001_completion_count","bounded_watchdog"};
    for(auto& n:names) checks[n]={};
    if(CFG_METHOD!=0) {checks["REQ_IF_002_gen_input_stable"]={};
        checks["REQ_IF_002_check_input_stable"]={};}
    try {
        if(argc!=5) throw std::runtime_error("usage: simulator vectors seed VCD events");
        unsigned seed=std::stoul(argv[2]); Channel gen(false,seed), chk(true,seed^0x54321u);
        std::ifstream input(argv[1]); std::string line;
        while(std::getline(input,line)) {
            std::istringstream row(line); char channel; std::string bytes; uint32_t crc;
            if(!(row>>channel>>bytes>>std::hex>>crc)) continue;
            Frame f; f.crc=crc;
            for(size_t i=0;i<bytes.size();i+=2) f.bytes.push_back(std::stoul(bytes.substr(i,2),nullptr,16));
            (channel=='g'?gen.frames:chk.frames).push_back(f);
        }
        if(gen.frames.empty()||chk.frames.empty()) throw std::runtime_error("empty vectors");
        std::ofstream events(argv[4]); Sim s(argv[3]); reset_scenarios(s,events);
        unsigned independent=0;
        while(gen.frame<gen.frames.size()||chk.frame<chk.frames.size()) {
            ck("bounded_watchdog",s.cycle<300000);
            gen.drive(s); chk.drive(s); s.settle(); gen.before(s); chk.before(s);
            bool ga=gen.holding&&gen.inready(s), ca=chk.holding&&chk.inready(s);
            bool gc=gen.outvalid(s)&&gen.outready(s), cc=chk.outvalid(s)&&chk.outready(s);
            if(gen.outvalid(s)&&!gen.outready(s)&&(ca||cc)) ++independent;
            s.tick(); gen.after(s,ga,gc,events); chk.after(s,ca,cc,events);
        }
        ck("REQ_IF_005_independent_progress",independent>0);
        ck("REQ_IF_001_completion_count",gen.frame==gen.frames.size()&&chk.frame==chk.frames.size());
        unsigned never=0;
        for(auto& [name,c]:checks) {std::cout<<"ASSERT "<<name<<" hits="<<c.hits<<" fails="<<c.fails<<"\n";
            if(!c.hits) ++never;}
        if(never) throw std::runtime_error("assertions never exercised: "+std::to_string(never));
        std::cout<<"assertion failures: 0, assertions never exercised: 0\n";
        std::cout<<"PASS method="<<CFG_METHOD<<" seed="<<seed<<" gen_frames="<<gen.frame
            <<" check_frames="<<chk.frame<<" independent_events="<<independent<<"\n";
        return 0;
    } catch(const std::exception& e) {std::cerr<<"FAIL "<<e.what()<<"\n"; return 1;}
}
