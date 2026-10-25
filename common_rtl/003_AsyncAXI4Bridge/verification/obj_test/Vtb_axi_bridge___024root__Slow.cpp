// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Design implementation internals
// See Vtb_axi_bridge.h for the primary calling header

#include "Vtb_axi_bridge__pch.h"

void Vtb_axi_bridge___024root___ctor_var_reset(Vtb_axi_bridge___024root* vlSelf);

Vtb_axi_bridge___024root::Vtb_axi_bridge___024root(Vtb_axi_bridge__Syms* symsp, const char* namep)
    : __VdlySched{*symsp->_vm_contextp__}
 {
    vlSymsp = symsp;
    vlNamep = strdup(namep);
    // Reset structure values
    Vtb_axi_bridge___024root___ctor_var_reset(this);
}

Vtb_axi_bridge___024root::~Vtb_axi_bridge___024root() {
    VL_DO_DANGLING(std::free(const_cast<char*>(vlNamep)), vlNamep);
}
