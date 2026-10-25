// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Symbol table implementation internals

#include "Vtb_axi_bridge__pch.h"

Vtb_axi_bridge__Syms::Vtb_axi_bridge__Syms(VerilatedContext* contextp, const char* namep, Vtb_axi_bridge* modelp)
    : VerilatedSyms{contextp}
    // Setup internal state of the Syms class
    , __Vm_modelp{modelp}
    , __Vm_didInit{modelp->m_didInit}
    // Setup top module instance
    , TOP{this, namep}
{
    // Check resources
    Verilated::stackCheck(169);
    // Setup sub module instances
    // Configure time unit / time precision
    _vm_contextp__->timeunit(-9);
    _vm_contextp__->timeprecision(-12);
    // Setup each module's pointers to their submodules
}

Vtb_axi_bridge__Syms::~Vtb_axi_bridge__Syms() {
    // Tear down scopes
    // Tear down sub module instances
}
