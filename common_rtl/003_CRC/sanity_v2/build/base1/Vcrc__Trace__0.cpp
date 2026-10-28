// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Tracing implementation internals

#include "verilated_vcd_c.h"
#include "Vcrc__Syms.h"


void Vcrc___024root__trace_chg_0_sub_0(Vcrc___024root* vlSelf, VerilatedVcd::Buffer* bufp);

void Vcrc___024root__trace_chg_0(void* voidSelf, VerilatedVcd::Buffer* bufp) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vcrc___024root__trace_chg_0\n"); );
    // Body
    Vcrc___024root* const __restrict vlSelf VL_ATTR_UNUSED = static_cast<Vcrc___024root*>(voidSelf);
    Vcrc__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    if (VL_UNLIKELY(!vlSymsp->__Vm_activity)) return;
    Vcrc___024root__trace_chg_0_sub_0((&vlSymsp->TOP), bufp);
}

void Vcrc___024root__trace_chg_0_sub_0(Vcrc___024root* vlSelf, VerilatedVcd::Buffer* bufp) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vcrc___024root__trace_chg_0_sub_0\n"); );
    Vcrc__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Body
    uint32_t* const oldp VL_ATTR_UNUSED = bufp->oldp(vlSymsp->__Vm_baseCode + 0);
    if (VL_UNLIKELY((vlSelfRef.__VtraceActivity[1U]))) {
        bufp->chgCData(oldp+0,(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_1__DOT__u_crc_initial_value__DOT__reg_crc_output),8);
        bufp->chgBit(oldp+1,(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_1__DOT__u_crc_initial_value__DOT__reg_crc_valid));
        bufp->chgBit(oldp+2,(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_1__DOT__u_crc_initial_value__DOT__reg_crc_valid));
    }
    bufp->chgBit(oldp+3,(vlSelfRef.i_clk_crc));
    bufp->chgBit(oldp+4,(vlSelfRef.i_rst_n_crc));
    bufp->chgIData(oldp+5,(vlSelfRef.i_gen_data),32);
    bufp->chgCData(oldp+6,(vlSelfRef.i_gen_keep),4);
    bufp->chgBit(oldp+7,(vlSelfRef.i_gen_valid));
    bufp->chgBit(oldp+8,(vlSelfRef.i_gen_last));
    bufp->chgBit(oldp+9,(vlSelfRef.o_gen_data_ready));
    bufp->chgBit(oldp+10,(vlSelfRef.i_gen_crc_ready));
    bufp->chgIData(oldp+11,(vlSelfRef.i_check_data),32);
    bufp->chgCData(oldp+12,(vlSelfRef.i_check_keep),4);
    bufp->chgBit(oldp+13,(vlSelfRef.i_check_valid));
    bufp->chgBit(oldp+14,(vlSelfRef.i_check_last));
    bufp->chgCData(oldp+15,(vlSelfRef.i_check_crc),8);
    bufp->chgBit(oldp+16,(vlSelfRef.o_check_data_ready));
    bufp->chgBit(oldp+17,(vlSelfRef.o_check_pass));
    bufp->chgBit(oldp+18,(vlSelfRef.i_check_crc_ready));
}

void Vcrc___024root__trace_cleanup(void* voidSelf, VerilatedVcd* /*unused*/) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vcrc___024root__trace_cleanup\n"); );
    // Body
    Vcrc___024root* const __restrict vlSelf VL_ATTR_UNUSED = static_cast<Vcrc___024root*>(voidSelf);
    Vcrc__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    vlSymsp->__Vm_activity = false;
    vlSymsp->TOP.__VtraceActivity[0U] = 0U;
    vlSymsp->TOP.__VtraceActivity[1U] = 0U;
}
