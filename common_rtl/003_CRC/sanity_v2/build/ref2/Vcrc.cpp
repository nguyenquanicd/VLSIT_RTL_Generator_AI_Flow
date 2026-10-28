// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Model implementation (design independent parts)

#include "Vcrc__pch.h"
#include "verilated_vcd_c.h"

//============================================================
// Constructors

Vcrc::Vcrc(VerilatedContext* _vcontextp__, const char* _vcname__)
    : VerilatedModel{*_vcontextp__}
    , vlSymsp{new Vcrc__Syms(contextp(), _vcname__, this)}
    , m_evalLoop{*this, /*convergeLimit:*/ 10000}
    , i_clk_crc{vlSymsp->TOP.i_clk_crc}
    , i_rst_n_crc{vlSymsp->TOP.i_rst_n_crc}
    , i_gen_data{vlSymsp->TOP.i_gen_data}
    , i_gen_keep{vlSymsp->TOP.i_gen_keep}
    , i_gen_valid{vlSymsp->TOP.i_gen_valid}
    , i_gen_last{vlSymsp->TOP.i_gen_last}
    , o_gen_data_ready{vlSymsp->TOP.o_gen_data_ready}
    , o_gen_crc{vlSymsp->TOP.o_gen_crc}
    , o_gen_crc_valid{vlSymsp->TOP.o_gen_crc_valid}
    , i_gen_crc_ready{vlSymsp->TOP.i_gen_crc_ready}
    , i_check_data{vlSymsp->TOP.i_check_data}
    , i_check_keep{vlSymsp->TOP.i_check_keep}
    , i_check_valid{vlSymsp->TOP.i_check_valid}
    , i_check_last{vlSymsp->TOP.i_check_last}
    , i_check_crc{vlSymsp->TOP.i_check_crc}
    , o_check_data_ready{vlSymsp->TOP.o_check_data_ready}
    , o_check_pass{vlSymsp->TOP.o_check_pass}
    , o_check_crc_valid{vlSymsp->TOP.o_check_crc_valid}
    , i_check_crc_ready{vlSymsp->TOP.i_check_crc_ready}
    , rootp{&(vlSymsp->TOP)}
{
    // Register model with the context
    contextp()->addModel(this);
    contextp()->traceBaseModelCbAdd(
        [this](VerilatedTraceBaseC* tfp, int levels, int options) { traceBaseModel(tfp, levels, options); });
}

Vcrc::Vcrc(const char* _vcname__)
    : Vcrc(Verilated::threadContextp(), _vcname__)
{
}

//============================================================
// Destructor

Vcrc::~Vcrc() {
    delete vlSymsp;
}

//============================================================
// Evaluation function

#ifdef VL_DEBUG
void Vcrc___024root___eval_debug_assertions(Vcrc___024root* vlSelf);
#endif  // VL_DEBUG
VL_ATTR_COLD void Vcrc___024root___eval_static(Vcrc___024root* vlSelf);
VL_ATTR_COLD void Vcrc___024root___eval_initial(Vcrc___024root* vlSelf);
VL_ATTR_COLD bool Vcrc___024root___eval_stl(Vcrc___024root* vlSelf, CData/*0:0*/ firstIteration);
void Vcrc___024root___eval_sample(Vcrc___024root* vlSelf);
bool Vcrc___024root___eval_ico(Vcrc___024root* vlSelf, CData/*0:0*/ firstIteration);
bool Vcrc___024root___eval_act(Vcrc___024root* vlSelf);
bool Vcrc___024root___eval_inact(Vcrc___024root* vlSelf);
bool Vcrc___024root___eval_nba(Vcrc___024root* vlSelf);
bool Vcrc___024root___eval_obs(Vcrc___024root* vlSelf);
bool Vcrc___024root___eval_react(Vcrc___024root* vlSelf);
void Vcrc___024root___eval_postponed(Vcrc___024root* vlSelf);
VL_ATTR_COLD void Vcrc___024root___eval_final(Vcrc___024root* vlSelf);
VL_ATTR_COLD void Vcrc___024root___eval_dump_triggers__stl(Vcrc___024root* vlSelf);
VL_ATTR_COLD void Vcrc___024root___eval_dump_triggers__ico(Vcrc___024root* vlSelf);
VL_ATTR_COLD void Vcrc___024root___eval_dump_triggers__act(Vcrc___024root* vlSelf);
VL_ATTR_COLD void Vcrc___024root___eval_dump_triggers__nba(Vcrc___024root* vlSelf);
VL_ATTR_COLD void Vcrc___024root___eval_dump_triggers__obs(Vcrc___024root* vlSelf);
VL_ATTR_COLD void Vcrc___024root___eval_dump_triggers__react(Vcrc___024root* vlSelf);

void Vcrc::eval_step() {
    VL_DEBUG_IF(VL_DBG_MSGF("+++++TOP Evaluate Vcrc::eval_step\n"); );
    m_evalLoop.eval();
}

void Vcrc::evalBegin() {
#ifdef VL_DEBUG
    // Debug assertions
    Vcrc___024root___eval_debug_assertions(&(vlSymsp->TOP));
#endif  // VL_DEBUG
    vlSymsp->__Vm_activity = true;
    vlSymsp->__Vm_deleter.deleteAll();
}

void Vcrc::evalEnd() {
    // Evaluate cleanup
    Verilated::endOfEval(vlSymsp->__Vm_evalMsgQp);
}

void Vcrc::evalStatic() {
    Vcrc___024root___eval_static(&(vlSymsp->TOP));
}

void Vcrc::evalInitial() {
    Vcrc___024root___eval_initial(&(vlSymsp->TOP));
}

bool Vcrc::evalStl(bool firstIteration) {
    return Vcrc___024root___eval_stl(&(vlSymsp->TOP), firstIteration);
}

void Vcrc::evalSample() {
    Vcrc___024root___eval_sample(&(vlSymsp->TOP));
}

bool Vcrc::evalIco(bool firstIteration) {
    return Vcrc___024root___eval_ico(&(vlSymsp->TOP), firstIteration);
}

bool Vcrc::evalAct() {
    return Vcrc___024root___eval_act(&(vlSymsp->TOP));
}

bool Vcrc::evalInact() {
    return Vcrc___024root___eval_inact(&(vlSymsp->TOP));
}

bool Vcrc::evalNba() {
    return Vcrc___024root___eval_nba(&(vlSymsp->TOP));
}

bool Vcrc::evalObs() {
    return Vcrc___024root___eval_obs(&(vlSymsp->TOP));
}

bool Vcrc::evalReact() {
    return Vcrc___024root___eval_react(&(vlSymsp->TOP));
}

void Vcrc::evalPostponed() {
    Vcrc___024root___eval_postponed(&(vlSymsp->TOP));
}

void Vcrc::evalFinal() {
    Vcrc___024root___eval_final(&(vlSymsp->TOP));
}

VL_ATTR_COLD void Vcrc::dumpTriggersStl() {
    Vcrc___024root___eval_dump_triggers__stl(&(vlSymsp->TOP));
}

VL_ATTR_COLD void Vcrc::dumpTriggersIco() {
    Vcrc___024root___eval_dump_triggers__ico(&(vlSymsp->TOP));
}

VL_ATTR_COLD void Vcrc::dumpTriggersAct() {
    Vcrc___024root___eval_dump_triggers__act(&(vlSymsp->TOP));
}

VL_ATTR_COLD void Vcrc::dumpTriggersNba() {
    Vcrc___024root___eval_dump_triggers__nba(&(vlSymsp->TOP));
}

VL_ATTR_COLD void Vcrc::dumpTriggersObs() {
    Vcrc___024root___eval_dump_triggers__obs(&(vlSymsp->TOP));
}

VL_ATTR_COLD void Vcrc::dumpTriggersReact() {
    Vcrc___024root___eval_dump_triggers__react(&(vlSymsp->TOP));
}

//============================================================
// Events and timing
bool Vcrc::eventsPending() { return false; }

uint64_t Vcrc::nextTimeSlot() {
    VL_FATAL_MT(__FILE__, __LINE__, "", "No delays in the design");
    return 0;
}

//============================================================
// Utilities

const char* Vcrc::name() const {
    return vlSymsp->name();
}

//============================================================
// Invoke final blocks

VL_ATTR_COLD void Vcrc::final() {
    contextp()->executingFinal(true);
    evalFinal();
    contextp()->executingFinal(false);
}

//============================================================
// Implementations of abstract methods from VerilatedModel

const char* Vcrc::hierName() const { return vlSymsp->name(); }
const char* Vcrc::modelName() const { return "Vcrc"; }
unsigned Vcrc::threads() const { return 1; }
void Vcrc::prepareClone() const { contextp()->prepareClone(); }
void Vcrc::atClone() const {
    contextp()->threadPoolpOnClone();
}
std::unique_ptr<VerilatedTraceConfig> Vcrc::traceConfig() const {
    return std::unique_ptr<VerilatedTraceConfig>{new VerilatedTraceConfig{false}};
};

//============================================================
// Trace configuration

void Vcrc___024root__trace_decl_types(VerilatedVcd* tracep);

void Vcrc___024root__trace_init_top(Vcrc___024root* vlSelf, VerilatedVcd* tracep);

VL_ATTR_COLD static void trace_init(void* voidSelf, VerilatedVcd* tracep, uint32_t code) {
    // Callback from tracep->open()
    Vcrc___024root* const __restrict vlSelf VL_ATTR_UNUSED = static_cast<Vcrc___024root*>(voidSelf);
    Vcrc__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    if (!vlSymsp->_vm_contextp__->calcUnusedSigs()) {
        VL_FATAL_MT(__FILE__, __LINE__, __FILE__,
            "Turning on wave traces requires Verilated::traceEverOn(true) call before time 0.");
    }
    vlSymsp->__Vm_baseCode = code;
    tracep->pushPrefix(vlSymsp->name(), VerilatedTracePrefixType::SCOPE_MODULE);
    Vcrc___024root__trace_decl_types(tracep);
    Vcrc___024root__trace_init_top(vlSelf, tracep);
    tracep->popPrefix();
}

VL_ATTR_COLD void Vcrc___024root__trace_register(Vcrc___024root* vlSelf, VerilatedVcd* tracep);

VL_ATTR_COLD void Vcrc::traceBaseModel(VerilatedTraceBaseC* tfp, int levels, int options) {
    (void)levels; (void)options;
    VerilatedVcdC* const stfp = dynamic_cast<VerilatedVcdC*>(tfp);
    if (VL_UNLIKELY(!stfp)) {
        vl_fatal(__FILE__, __LINE__, __FILE__,"'Vcrc::trace()' called on non-VerilatedVcdC object;"
            " use --trace-fst with VerilatedFst object, and --trace-vcd with VerilatedVcd object");
    }
    stfp->spTrace()->addModel(this);
    stfp->spTrace()->addInitCb(&trace_init, &(vlSymsp->TOP), name(), false, 30);
    Vcrc___024root__trace_register(&(vlSymsp->TOP), stfp->spTrace());
}
