// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Model implementation (design independent parts)

#include "Vtb_axi_bridge__pch.h"

//============================================================
// Constructors

Vtb_axi_bridge::Vtb_axi_bridge(VerilatedContext* _vcontextp__, const char* _vcname__)
    : VerilatedModel{*_vcontextp__}
    , vlSymsp{new Vtb_axi_bridge__Syms(contextp(), _vcname__, this)}
    , m_evalLoop{*this, /*convergeLimit:*/ 10000}
    , rootp{&(vlSymsp->TOP)}
{
    // Register model with the context
    contextp()->addModel(this);
}

Vtb_axi_bridge::Vtb_axi_bridge(const char* _vcname__)
    : Vtb_axi_bridge(Verilated::threadContextp(), _vcname__)
{
}

//============================================================
// Destructor

Vtb_axi_bridge::~Vtb_axi_bridge() {
    delete vlSymsp;
}

//============================================================
// Evaluation function

#ifdef VL_DEBUG
void Vtb_axi_bridge___024root___eval_debug_assertions(Vtb_axi_bridge___024root* vlSelf);
#endif  // VL_DEBUG
VL_ATTR_COLD void Vtb_axi_bridge___024root___eval_static(Vtb_axi_bridge___024root* vlSelf);
void Vtb_axi_bridge___024root___eval_initial(Vtb_axi_bridge___024root* vlSelf);
VL_ATTR_COLD bool Vtb_axi_bridge___024root___eval_stl(Vtb_axi_bridge___024root* vlSelf, CData/*0:0*/ firstIteration);
void Vtb_axi_bridge___024root___eval_sample(Vtb_axi_bridge___024root* vlSelf);
bool Vtb_axi_bridge___024root___eval_ico(Vtb_axi_bridge___024root* vlSelf, CData/*0:0*/ firstIteration);
bool Vtb_axi_bridge___024root___eval_act(Vtb_axi_bridge___024root* vlSelf);
bool Vtb_axi_bridge___024root___eval_inact(Vtb_axi_bridge___024root* vlSelf);
bool Vtb_axi_bridge___024root___eval_nba(Vtb_axi_bridge___024root* vlSelf);
bool Vtb_axi_bridge___024root___eval_obs(Vtb_axi_bridge___024root* vlSelf);
bool Vtb_axi_bridge___024root___eval_react(Vtb_axi_bridge___024root* vlSelf);
void Vtb_axi_bridge___024root___eval_postponed(Vtb_axi_bridge___024root* vlSelf);
VL_ATTR_COLD void Vtb_axi_bridge___024root___eval_final(Vtb_axi_bridge___024root* vlSelf);
VL_ATTR_COLD void Vtb_axi_bridge___024root___eval_dump_triggers__stl(Vtb_axi_bridge___024root* vlSelf);
VL_ATTR_COLD void Vtb_axi_bridge___024root___eval_dump_triggers__ico(Vtb_axi_bridge___024root* vlSelf);
VL_ATTR_COLD void Vtb_axi_bridge___024root___eval_dump_triggers__act(Vtb_axi_bridge___024root* vlSelf);
VL_ATTR_COLD void Vtb_axi_bridge___024root___eval_dump_triggers__nba(Vtb_axi_bridge___024root* vlSelf);
VL_ATTR_COLD void Vtb_axi_bridge___024root___eval_dump_triggers__obs(Vtb_axi_bridge___024root* vlSelf);
VL_ATTR_COLD void Vtb_axi_bridge___024root___eval_dump_triggers__react(Vtb_axi_bridge___024root* vlSelf);

void Vtb_axi_bridge::eval_step() {
    VL_DEBUG_IF(VL_DBG_MSGF("+++++TOP Evaluate Vtb_axi_bridge::eval_step\n"); );
    m_evalLoop.eval();
}

void Vtb_axi_bridge::evalBegin() {
#ifdef VL_DEBUG
    // Debug assertions
    Vtb_axi_bridge___024root___eval_debug_assertions(&(vlSymsp->TOP));
#endif  // VL_DEBUG
    vlSymsp->__Vm_deleter.deleteAll();
}

void Vtb_axi_bridge::evalEnd() {
    // Evaluate cleanup
    Verilated::endOfEval(vlSymsp->__Vm_evalMsgQp);
    vlSymsp->TOP.__VdlySched.cleanupForevered();
}

void Vtb_axi_bridge::evalStatic() {
    Vtb_axi_bridge___024root___eval_static(&(vlSymsp->TOP));
}

void Vtb_axi_bridge::evalInitial() {
    Vtb_axi_bridge___024root___eval_initial(&(vlSymsp->TOP));
}

bool Vtb_axi_bridge::evalStl(bool firstIteration) {
    return Vtb_axi_bridge___024root___eval_stl(&(vlSymsp->TOP), firstIteration);
}

void Vtb_axi_bridge::evalSample() {
    Vtb_axi_bridge___024root___eval_sample(&(vlSymsp->TOP));
}

bool Vtb_axi_bridge::evalIco(bool firstIteration) {
    return Vtb_axi_bridge___024root___eval_ico(&(vlSymsp->TOP), firstIteration);
}

bool Vtb_axi_bridge::evalAct() {
    return Vtb_axi_bridge___024root___eval_act(&(vlSymsp->TOP));
}

bool Vtb_axi_bridge::evalInact() {
    return Vtb_axi_bridge___024root___eval_inact(&(vlSymsp->TOP));
}

bool Vtb_axi_bridge::evalNba() {
    return Vtb_axi_bridge___024root___eval_nba(&(vlSymsp->TOP));
}

bool Vtb_axi_bridge::evalObs() {
    return Vtb_axi_bridge___024root___eval_obs(&(vlSymsp->TOP));
}

bool Vtb_axi_bridge::evalReact() {
    return Vtb_axi_bridge___024root___eval_react(&(vlSymsp->TOP));
}

void Vtb_axi_bridge::evalPostponed() {
    Vtb_axi_bridge___024root___eval_postponed(&(vlSymsp->TOP));
}

void Vtb_axi_bridge::evalFinal() {
    Vtb_axi_bridge___024root___eval_final(&(vlSymsp->TOP));
}

VL_ATTR_COLD void Vtb_axi_bridge::dumpTriggersStl() {
    Vtb_axi_bridge___024root___eval_dump_triggers__stl(&(vlSymsp->TOP));
}

VL_ATTR_COLD void Vtb_axi_bridge::dumpTriggersIco() {
    Vtb_axi_bridge___024root___eval_dump_triggers__ico(&(vlSymsp->TOP));
}

VL_ATTR_COLD void Vtb_axi_bridge::dumpTriggersAct() {
    Vtb_axi_bridge___024root___eval_dump_triggers__act(&(vlSymsp->TOP));
}

VL_ATTR_COLD void Vtb_axi_bridge::dumpTriggersNba() {
    Vtb_axi_bridge___024root___eval_dump_triggers__nba(&(vlSymsp->TOP));
}

VL_ATTR_COLD void Vtb_axi_bridge::dumpTriggersObs() {
    Vtb_axi_bridge___024root___eval_dump_triggers__obs(&(vlSymsp->TOP));
}

VL_ATTR_COLD void Vtb_axi_bridge::dumpTriggersReact() {
    Vtb_axi_bridge___024root___eval_dump_triggers__react(&(vlSymsp->TOP));
}

//============================================================
// Events and timing
bool Vtb_axi_bridge::eventsPending() { return !vlSymsp->TOP.__VdlySched.empty() && !contextp()->gotFinish(); }

uint64_t Vtb_axi_bridge::nextTimeSlot() { return vlSymsp->TOP.__VdlySched.nextTimeSlot(); }

//============================================================
// Utilities

const char* Vtb_axi_bridge::name() const {
    return vlSymsp->name();
}

//============================================================
// Invoke final blocks

VL_ATTR_COLD void Vtb_axi_bridge::final() {
    contextp()->executingFinal(true);
    evalFinal();
    contextp()->executingFinal(false);
}

//============================================================
// Implementations of abstract methods from VerilatedModel

const char* Vtb_axi_bridge::hierName() const { return vlSymsp->name(); }
const char* Vtb_axi_bridge::modelName() const { return "Vtb_axi_bridge"; }
unsigned Vtb_axi_bridge::threads() const { return 1; }
void Vtb_axi_bridge::prepareClone() const { contextp()->prepareClone(); }
void Vtb_axi_bridge::atClone() const {
    contextp()->threadPoolpOnClone();
}
