// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Symbol table internal header
//
// Internal details; most calling programs do not need this header,
// unless using verilator public meta comments.

#ifndef VERILATED_VTB_AXI_BRIDGE__SYMS_H_
#define VERILATED_VTB_AXI_BRIDGE__SYMS_H_  // guard

#include "verilated.h"

// INCLUDE MODEL CLASS

#include "Vtb_axi_bridge.h"

// INCLUDE MODULE CLASSES
#include "Vtb_axi_bridge___024root.h"

// SYMS CLASS (contains all model state)
class alignas(VL_CACHE_LINE_BYTES) Vtb_axi_bridge__Syms final : public VerilatedSyms {
  public:
    // INTERNAL STATE
    Vtb_axi_bridge* const __Vm_modelp;
    VlDeleter __Vm_deleter;
    bool& __Vm_didInit;

    // MODULE INSTANCE STATE
    Vtb_axi_bridge___024root       TOP;

    // CONSTRUCTORS
    Vtb_axi_bridge__Syms(VerilatedContext* contextp, const char* namep, Vtb_axi_bridge* modelp);
    ~Vtb_axi_bridge__Syms();

    // METHODS
    const char* name() const { return TOP.vlNamep; }
};

#endif  // guard
