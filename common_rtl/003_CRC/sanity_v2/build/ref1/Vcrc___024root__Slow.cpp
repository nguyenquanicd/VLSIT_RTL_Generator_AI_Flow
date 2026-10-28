// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Design implementation internals
// See Vcrc.h for the primary calling header

#include "Vcrc__pch.h"

void Vcrc___024root___ctor_var_reset(Vcrc___024root* vlSelf);

Vcrc___024root::Vcrc___024root(Vcrc__Syms* symsp, const char* namep)
 {
    vlSymsp = symsp;
    vlNamep = strdup(namep);
    // Reset structure values
    Vcrc___024root___ctor_var_reset(this);
}

Vcrc___024root::~Vcrc___024root() {
    VL_DO_DANGLING(std::free(const_cast<char*>(vlNamep)), vlNamep);
}
