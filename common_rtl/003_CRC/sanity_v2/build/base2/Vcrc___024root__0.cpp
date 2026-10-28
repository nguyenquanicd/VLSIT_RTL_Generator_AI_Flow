// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Design implementation internals
// See Vcrc.h for the primary calling header

#include "Vcrc__pch.h"

void Vcrc___024root___eval_sample(Vcrc___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vcrc___024root___eval_sample\n"); );
    Vcrc__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
}

void Vcrc___024root___eval_triggers_vec__ico(Vcrc___024root* vlSelf);
#ifdef VL_DEBUG
VL_ATTR_COLD void Vcrc___024root___dump_triggers__ico(const VlUnpacked<QData/*63:0*/, 2> &triggers, const std::string &tag);
#endif  // VL_DEBUG
bool Vcrc___024root___trigger_anySet__ico(const VlUnpacked<QData/*63:0*/, 2> &in);

bool Vcrc___024root___eval_ico(Vcrc___024root* vlSelf, CData/*0:0*/ firstIteration) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vcrc___024root___eval_ico\n"); );
    Vcrc__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Locals
    CData/*0:0*/ __VicoExecute;
    // Body
    vlSelfRef.__VicoTriggered[1U] = ((0xfffffffffffffffeULL 
                                      & vlSelfRef.__VicoTriggered[1U]) 
                                     | (IData)((IData)(firstIteration)));
    Vcrc___024root___eval_triggers_vec__ico(vlSelf);
#ifdef VL_DEBUG
    if (VL_UNLIKELY(vlSymsp->_vm_contextp__->debug())) {
        Vcrc___024root___dump_triggers__ico(vlSelfRef.__VicoTriggered, "ico"s);
    }
#endif
    __VicoExecute = Vcrc___024root___trigger_anySet__ico(vlSelfRef.__VicoTriggered);
    if (__VicoExecute) {
        {
            // Inlined CFunc: _eval_body__ico
            if ((2ULL & vlSelfRef.__VicoTriggered[0U])) {
                {
                    // Inlined CFunc: _ico_sequent__TOP__0
                    vlSelfRef.o_gen_data_ready = ((~ 
                                                   ((IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_2__DOT__u_crc_parallel__DOT__reg_busy) 
                                                    | (IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_2__DOT__u_crc_parallel__DOT__reg_crc_valid))) 
                                                  & (IData)(vlSelfRef.i_rst_n_crc));
                    vlSelfRef.o_check_data_ready = 
                        ((~ ((IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_2__DOT__u_crc_parallel__DOT__reg_busy) 
                             | (IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_2__DOT__u_crc_parallel__DOT__reg_crc_valid))) 
                         & (IData)(vlSelfRef.i_rst_n_crc));
                }
            }
        }
    }
    return (__VicoExecute);
}

#ifdef VL_DEBUG
VL_ATTR_COLD void Vcrc___024root___dump_triggers__act(const VlUnpacked<QData/*63:0*/, 1> &triggers, const std::string &tag);
#endif  // VL_DEBUG
void Vcrc___024root___trigger_orInto__act_vec_vec(VlUnpacked<QData/*63:0*/, 1> &out, const VlUnpacked<QData/*63:0*/, 1> &in);

bool Vcrc___024root___eval_act(Vcrc___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vcrc___024root___eval_act\n"); );
    Vcrc__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Body
    {
        // Inlined CFunc: _eval_triggers_vec__act
        vlSelfRef.__VactTriggered[0U] = (QData)((IData)(
                                                        ((IData)(vlSelfRef.i_clk_crc) 
                                                         & (~ (IData)(vlSelfRef.__Vtrigprevexpr___TOP__i_clk_crc__1)))));
        vlSelfRef.__Vtrigprevexpr___TOP__i_clk_crc__1 
            = vlSelfRef.i_clk_crc;
    }
#ifdef VL_DEBUG
    if (VL_UNLIKELY(vlSymsp->_vm_contextp__->debug())) {
        Vcrc___024root___dump_triggers__act(vlSelfRef.__VactTriggered, "act"s);
    }
#endif
    Vcrc___024root___trigger_orInto__act_vec_vec(vlSelfRef.__VnbaTriggered, vlSelfRef.__VactTriggered);
    return (0U);
}

bool Vcrc___024root___eval_inact(Vcrc___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vcrc___024root___eval_inact\n"); );
    Vcrc__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Body
    return (0U);
}

bool Vcrc___024root___trigger_anySet__act(const VlUnpacked<QData/*63:0*/, 1> &in);
void Vcrc___024root___nba_sequent__TOP__0(Vcrc___024root* vlSelf);
void Vcrc___024root___trigger_clear__act(VlUnpacked<QData/*63:0*/, 1> &out);

bool Vcrc___024root___eval_nba(Vcrc___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vcrc___024root___eval_nba\n"); );
    Vcrc__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Locals
    CData/*0:0*/ __VnbaExecute;
    // Body
    __VnbaExecute = Vcrc___024root___trigger_anySet__act(vlSelfRef.__VnbaTriggered);
    if (__VnbaExecute) {
        {
            // Inlined CFunc: _eval_body__nba
            if ((1ULL & vlSelfRef.__VnbaTriggered[0U])) {
                Vcrc___024root___nba_sequent__TOP__0(vlSelf);
                vlSelfRef.__VtraceActivity[1U] = 1U;
            }
        }
        Vcrc___024root___trigger_clear__act(vlSelfRef.__VnbaTriggered);
    }
    return (__VnbaExecute);
}

bool Vcrc___024root___eval_obs(Vcrc___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vcrc___024root___eval_obs\n"); );
    Vcrc__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Body
    return (0U);
}

bool Vcrc___024root___eval_react(Vcrc___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vcrc___024root___eval_react\n"); );
    Vcrc__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Body
    return (0U);
}

void Vcrc___024root___eval_postponed(Vcrc___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vcrc___024root___eval_postponed\n"); );
    Vcrc__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
}

void Vcrc___024root___eval_triggers_vec__ico(Vcrc___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vcrc___024root___eval_triggers_vec__ico\n"); );
    Vcrc__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Body
    vlSelfRef.__VicoTriggered[0U] = (QData)((IData)(
                                                    (((((IData)(vlSelfRef.i_check_crc_ready) 
                                                        != (IData)(vlSelfRef.__Vtrigprevexpr___TOP__i_check_crc_ready__0)) 
                                                       << 0x0000000cU) 
                                                      | ((((((IData)(vlSelfRef.i_check_crc) 
                                                             != (IData)(vlSelfRef.__Vtrigprevexpr___TOP__i_check_crc__0)) 
                                                            << 3U) 
                                                           | (((IData)(vlSelfRef.i_check_last) 
                                                               != (IData)(vlSelfRef.__Vtrigprevexpr___TOP__i_check_last__0)) 
                                                              << 2U)) 
                                                          | ((((IData)(vlSelfRef.i_check_valid) 
                                                               != (IData)(vlSelfRef.__Vtrigprevexpr___TOP__i_check_valid__0)) 
                                                              << 1U) 
                                                             | ((IData)(vlSelfRef.i_check_keep) 
                                                                != (IData)(vlSelfRef.__Vtrigprevexpr___TOP__i_check_keep__0)))) 
                                                         << 8U)) 
                                                     | ((((((vlSelfRef.i_check_data 
                                                             != vlSelfRef.__Vtrigprevexpr___TOP__i_check_data__0) 
                                                            << 3U) 
                                                           | (((IData)(vlSelfRef.i_gen_crc_ready) 
                                                               != (IData)(vlSelfRef.__Vtrigprevexpr___TOP__i_gen_crc_ready__0)) 
                                                              << 2U)) 
                                                          | ((((IData)(vlSelfRef.i_gen_last) 
                                                               != (IData)(vlSelfRef.__Vtrigprevexpr___TOP__i_gen_last__0)) 
                                                              << 1U) 
                                                             | ((IData)(vlSelfRef.i_gen_valid) 
                                                                != (IData)(vlSelfRef.__Vtrigprevexpr___TOP__i_gen_valid__0)))) 
                                                         << 4U) 
                                                        | (((((IData)(vlSelfRef.i_gen_keep) 
                                                              != (IData)(vlSelfRef.__Vtrigprevexpr___TOP__i_gen_keep__0)) 
                                                             << 3U) 
                                                            | ((vlSelfRef.i_gen_data 
                                                                != vlSelfRef.__Vtrigprevexpr___TOP__i_gen_data__0) 
                                                               << 2U)) 
                                                           | ((((IData)(vlSelfRef.i_rst_n_crc) 
                                                                != (IData)(vlSelfRef.__Vtrigprevexpr___TOP__i_rst_n_crc__0)) 
                                                               << 1U) 
                                                              | ((IData)(vlSelfRef.i_clk_crc) 
                                                                 != (IData)(vlSelfRef.__Vtrigprevexpr___TOP__i_clk_crc__0))))))));
    vlSelfRef.__Vtrigprevexpr___TOP__i_clk_crc__0 = vlSelfRef.i_clk_crc;
    vlSelfRef.__Vtrigprevexpr___TOP__i_rst_n_crc__0 
        = vlSelfRef.i_rst_n_crc;
    vlSelfRef.__Vtrigprevexpr___TOP__i_gen_data__0 
        = vlSelfRef.i_gen_data;
    vlSelfRef.__Vtrigprevexpr___TOP__i_gen_keep__0 
        = vlSelfRef.i_gen_keep;
    vlSelfRef.__Vtrigprevexpr___TOP__i_gen_valid__0 
        = vlSelfRef.i_gen_valid;
    vlSelfRef.__Vtrigprevexpr___TOP__i_gen_last__0 
        = vlSelfRef.i_gen_last;
    vlSelfRef.__Vtrigprevexpr___TOP__i_gen_crc_ready__0 
        = vlSelfRef.i_gen_crc_ready;
    vlSelfRef.__Vtrigprevexpr___TOP__i_check_data__0 
        = vlSelfRef.i_check_data;
    vlSelfRef.__Vtrigprevexpr___TOP__i_check_keep__0 
        = vlSelfRef.i_check_keep;
    vlSelfRef.__Vtrigprevexpr___TOP__i_check_valid__0 
        = vlSelfRef.i_check_valid;
    vlSelfRef.__Vtrigprevexpr___TOP__i_check_last__0 
        = vlSelfRef.i_check_last;
    vlSelfRef.__Vtrigprevexpr___TOP__i_check_crc__0 
        = vlSelfRef.i_check_crc;
    vlSelfRef.__Vtrigprevexpr___TOP__i_check_crc_ready__0 
        = vlSelfRef.i_check_crc_ready;
    if (VL_UNLIKELY(((1U & (~ (IData)(vlSelfRef.__VicoDidInit)))))) {
        vlSelfRef.__VicoDidInit = 1U;
        vlSelfRef.__VicoTriggered[0U] = (1ULL | vlSelfRef.__VicoTriggered[0U]);
        vlSelfRef.__VicoTriggered[0U] = (2ULL | vlSelfRef.__VicoTriggered[0U]);
        vlSelfRef.__VicoTriggered[0U] = (4ULL | vlSelfRef.__VicoTriggered[0U]);
        vlSelfRef.__VicoTriggered[0U] = (8ULL | vlSelfRef.__VicoTriggered[0U]);
        vlSelfRef.__VicoTriggered[0U] = (0x0000000000000010ULL 
                                         | vlSelfRef.__VicoTriggered[0U]);
        vlSelfRef.__VicoTriggered[0U] = (0x0000000000000020ULL 
                                         | vlSelfRef.__VicoTriggered[0U]);
        vlSelfRef.__VicoTriggered[0U] = (0x0000000000000040ULL 
                                         | vlSelfRef.__VicoTriggered[0U]);
        vlSelfRef.__VicoTriggered[0U] = (0x0000000000000080ULL 
                                         | vlSelfRef.__VicoTriggered[0U]);
        vlSelfRef.__VicoTriggered[0U] = (0x0000000000000100ULL 
                                         | vlSelfRef.__VicoTriggered[0U]);
        vlSelfRef.__VicoTriggered[0U] = (0x0000000000000200ULL 
                                         | vlSelfRef.__VicoTriggered[0U]);
        vlSelfRef.__VicoTriggered[0U] = (0x0000000000000400ULL 
                                         | vlSelfRef.__VicoTriggered[0U]);
        vlSelfRef.__VicoTriggered[0U] = (0x0000000000000800ULL 
                                         | vlSelfRef.__VicoTriggered[0U]);
        vlSelfRef.__VicoTriggered[0U] = (0x0000000000001000ULL 
                                         | vlSelfRef.__VicoTriggered[0U]);
    }
}

bool Vcrc___024root___trigger_anySet__ico(const VlUnpacked<QData/*63:0*/, 2> &in) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vcrc___024root___trigger_anySet__ico\n"); );
    // Locals
    IData/*31:0*/ n;
    // Body
    n = 0U;
    do {
        if (in[n]) {
            return (1U);
        }
        n = ((IData)(1U) + n);
    } while ((2U > n));
    return (0U);
}

bool Vcrc___024root___trigger_anySet__act(const VlUnpacked<QData/*63:0*/, 1> &in) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vcrc___024root___trigger_anySet__act\n"); );
    // Locals
    IData/*31:0*/ n;
    // Body
    n = 0U;
    do {
        if (in[n]) {
            return (1U);
        }
        n = ((IData)(1U) + n);
    } while ((1U > n));
    return (0U);
}

void Vcrc___024root___nba_sequent__TOP__0(Vcrc___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vcrc___024root___nba_sequent__TOP__0\n"); );
    Vcrc__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Locals
    CData/*7:0*/ __Vfunc_m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_2__DOT__u_crc_parallel__DOT__f_finalize__Vfuncout_17;
    __Vfunc_m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_2__DOT__u_crc_parallel__DOT__f_finalize__Vfuncout_17 = 0;
    CData/*7:0*/ __Vfunc_m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_2__DOT__u_crc_parallel__DOT__f_finalize__i_crc_18;
    __Vfunc_m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_2__DOT__u_crc_parallel__DOT__f_finalize__i_crc_18 = 0;
    CData/*7:0*/ __Vfunc_m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_2__DOT__u_crc_parallel__DOT__f_finalize__w_reflected_crc_20;
    __Vfunc_m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_2__DOT__u_crc_parallel__DOT__f_finalize__w_reflected_crc_20 = 0;
    CData/*7:0*/ __Vfunc_m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_2__DOT__u_crc_parallel__DOT__f_finalize__Vfuncout_38;
    __Vfunc_m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_2__DOT__u_crc_parallel__DOT__f_finalize__Vfuncout_38 = 0;
    CData/*7:0*/ __Vfunc_m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_2__DOT__u_crc_parallel__DOT__f_finalize__i_crc_39;
    __Vfunc_m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_2__DOT__u_crc_parallel__DOT__f_finalize__i_crc_39 = 0;
    CData/*7:0*/ __Vfunc_m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_2__DOT__u_crc_parallel__DOT__f_finalize__w_reflected_crc_41;
    __Vfunc_m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_2__DOT__u_crc_parallel__DOT__f_finalize__w_reflected_crc_41 = 0;
    CData/*7:0*/ __Vdfg_Regularize_592;
    __Vdfg_Regularize_592 = 0;
    CData/*7:0*/ __Vdfg_Regularize_593;
    __Vdfg_Regularize_593 = 0;
    CData/*7:0*/ __Vdfg_Regularize_594;
    __Vdfg_Regularize_594 = 0;
    CData/*7:0*/ __Vdfg_Regularize_595;
    __Vdfg_Regularize_595 = 0;
    CData/*7:0*/ __Vdfg_Regularize_596;
    __Vdfg_Regularize_596 = 0;
    CData/*7:0*/ __Vdfg_Regularize_597;
    __Vdfg_Regularize_597 = 0;
    CData/*7:0*/ __Vdfg_Regularize_598;
    __Vdfg_Regularize_598 = 0;
    CData/*7:0*/ __Vdfg_Regularize_599;
    __Vdfg_Regularize_599 = 0;
    CData/*7:0*/ __Vdfg_Regularize_600;
    __Vdfg_Regularize_600 = 0;
    CData/*7:0*/ __Vdfg_Regularize_601;
    __Vdfg_Regularize_601 = 0;
    CData/*7:0*/ __Vdfg_Regularize_602;
    __Vdfg_Regularize_602 = 0;
    CData/*7:0*/ __Vdfg_Regularize_603;
    __Vdfg_Regularize_603 = 0;
    CData/*7:0*/ __Vdfg_Regularize_604;
    __Vdfg_Regularize_604 = 0;
    CData/*7:0*/ __Vdfg_Regularize_605;
    __Vdfg_Regularize_605 = 0;
    CData/*7:0*/ __Vdfg_Regularize_606;
    __Vdfg_Regularize_606 = 0;
    CData/*7:0*/ __Vdfg_Regularize_607;
    __Vdfg_Regularize_607 = 0;
    CData/*7:0*/ __Vdfg_Regularize_608;
    __Vdfg_Regularize_608 = 0;
    CData/*7:0*/ __Vdfg_Regularize_609;
    __Vdfg_Regularize_609 = 0;
    CData/*7:0*/ __Vdfg_Regularize_610;
    __Vdfg_Regularize_610 = 0;
    CData/*7:0*/ __Vdfg_Regularize_611;
    __Vdfg_Regularize_611 = 0;
    CData/*7:0*/ __Vdfg_Regularize_612;
    __Vdfg_Regularize_612 = 0;
    CData/*7:0*/ __Vdfg_Regularize_613;
    __Vdfg_Regularize_613 = 0;
    CData/*7:0*/ __Vdfg_Regularize_614;
    __Vdfg_Regularize_614 = 0;
    CData/*7:0*/ __Vdfg_Regularize_615;
    __Vdfg_Regularize_615 = 0;
    CData/*7:0*/ __Vdfg_Regularize_616;
    __Vdfg_Regularize_616 = 0;
    CData/*7:0*/ __Vdfg_Regularize_617;
    __Vdfg_Regularize_617 = 0;
    CData/*7:0*/ __Vdfg_Regularize_618;
    __Vdfg_Regularize_618 = 0;
    CData/*7:0*/ __Vdfg_Regularize_619;
    __Vdfg_Regularize_619 = 0;
    CData/*7:0*/ __Vdfg_Regularize_620;
    __Vdfg_Regularize_620 = 0;
    CData/*7:0*/ __Vdfg_Regularize_621;
    __Vdfg_Regularize_621 = 0;
    CData/*7:0*/ __Vdfg_Regularize_622;
    __Vdfg_Regularize_622 = 0;
    CData/*7:0*/ __Vdfg_Regularize_623;
    __Vdfg_Regularize_623 = 0;
    CData/*7:0*/ __Vdfg_Regularize_624;
    __Vdfg_Regularize_624 = 0;
    CData/*7:0*/ __Vdfg_Regularize_625;
    __Vdfg_Regularize_625 = 0;
    CData/*7:0*/ __Vdfg_Regularize_626;
    __Vdfg_Regularize_626 = 0;
    CData/*7:0*/ __Vdfg_Regularize_627;
    __Vdfg_Regularize_627 = 0;
    CData/*7:0*/ __Vdfg_Regularize_628;
    __Vdfg_Regularize_628 = 0;
    CData/*7:0*/ __Vdfg_Regularize_629;
    __Vdfg_Regularize_629 = 0;
    CData/*7:0*/ __Vdfg_Regularize_630;
    __Vdfg_Regularize_630 = 0;
    CData/*7:0*/ __Vdfg_Regularize_631;
    __Vdfg_Regularize_631 = 0;
    CData/*7:0*/ __Vdfg_Regularize_632;
    __Vdfg_Regularize_632 = 0;
    CData/*7:0*/ __Vdfg_Regularize_633;
    __Vdfg_Regularize_633 = 0;
    CData/*7:0*/ __Vdfg_Regularize_634;
    __Vdfg_Regularize_634 = 0;
    CData/*7:0*/ __Vdfg_Regularize_635;
    __Vdfg_Regularize_635 = 0;
    CData/*7:0*/ __Vdfg_Regularize_636;
    __Vdfg_Regularize_636 = 0;
    CData/*7:0*/ __Vdfg_Regularize_637;
    __Vdfg_Regularize_637 = 0;
    CData/*7:0*/ __Vdfg_Regularize_638;
    __Vdfg_Regularize_638 = 0;
    CData/*7:0*/ __Vdfg_Regularize_639;
    __Vdfg_Regularize_639 = 0;
    CData/*7:0*/ __Vdfg_Regularize_640;
    __Vdfg_Regularize_640 = 0;
    CData/*7:0*/ __Vdfg_Regularize_641;
    __Vdfg_Regularize_641 = 0;
    CData/*7:0*/ __Vdfg_Regularize_642;
    __Vdfg_Regularize_642 = 0;
    CData/*7:0*/ __Vdfg_Regularize_643;
    __Vdfg_Regularize_643 = 0;
    CData/*7:0*/ __Vdfg_Regularize_644;
    __Vdfg_Regularize_644 = 0;
    CData/*7:0*/ __Vdfg_Regularize_645;
    __Vdfg_Regularize_645 = 0;
    CData/*7:0*/ __Vdfg_Regularize_646;
    __Vdfg_Regularize_646 = 0;
    CData/*7:0*/ __Vdfg_Regularize_647;
    __Vdfg_Regularize_647 = 0;
    CData/*7:0*/ __Vdfg_Regularize_648;
    __Vdfg_Regularize_648 = 0;
    CData/*7:0*/ __Vdfg_Regularize_649;
    __Vdfg_Regularize_649 = 0;
    CData/*7:0*/ __Vdfg_Regularize_650;
    __Vdfg_Regularize_650 = 0;
    CData/*7:0*/ __Vdfg_Regularize_651;
    __Vdfg_Regularize_651 = 0;
    CData/*7:0*/ __Vdfg_Regularize_652;
    __Vdfg_Regularize_652 = 0;
    CData/*7:0*/ __Vdfg_Regularize_653;
    __Vdfg_Regularize_653 = 0;
    CData/*7:0*/ __Vdfg_Regularize_654;
    __Vdfg_Regularize_654 = 0;
    CData/*7:0*/ __Vdfg_Regularize_655;
    __Vdfg_Regularize_655 = 0;
    CData/*7:0*/ __Vdfg_Regularize_656;
    __Vdfg_Regularize_656 = 0;
    CData/*7:0*/ __Vdfg_Regularize_657;
    __Vdfg_Regularize_657 = 0;
    CData/*7:0*/ __Vdfg_Regularize_658;
    __Vdfg_Regularize_658 = 0;
    CData/*7:0*/ __Vdfg_Regularize_659;
    __Vdfg_Regularize_659 = 0;
    CData/*7:0*/ __Vdfg_Regularize_660;
    __Vdfg_Regularize_660 = 0;
    CData/*7:0*/ __Vdfg_Regularize_661;
    __Vdfg_Regularize_661 = 0;
    CData/*7:0*/ __Vdfg_Regularize_662;
    __Vdfg_Regularize_662 = 0;
    CData/*7:0*/ __Vdfg_Regularize_663;
    __Vdfg_Regularize_663 = 0;
    CData/*7:0*/ __Vdfg_Regularize_664;
    __Vdfg_Regularize_664 = 0;
    CData/*7:0*/ __Vdfg_Regularize_665;
    __Vdfg_Regularize_665 = 0;
    CData/*7:0*/ __Vdfg_Regularize_666;
    __Vdfg_Regularize_666 = 0;
    CData/*7:0*/ __Vdfg_Regularize_675;
    __Vdfg_Regularize_675 = 0;
    CData/*7:0*/ __Vdfg_Regularize_676;
    __Vdfg_Regularize_676 = 0;
    CData/*7:0*/ __Vdfg_Regularize_677;
    __Vdfg_Regularize_677 = 0;
    CData/*7:0*/ __Vdfg_Regularize_678;
    __Vdfg_Regularize_678 = 0;
    CData/*7:0*/ __Vdfg_Regularize_679;
    __Vdfg_Regularize_679 = 0;
    CData/*7:0*/ __Vdfg_Regularize_680;
    __Vdfg_Regularize_680 = 0;
    CData/*7:0*/ __Vdfg_Regularize_681;
    __Vdfg_Regularize_681 = 0;
    CData/*7:0*/ __Vdfg_Regularize_682;
    __Vdfg_Regularize_682 = 0;
    CData/*7:0*/ __Vdfg_Regularize_683;
    __Vdfg_Regularize_683 = 0;
    CData/*7:0*/ __Vdfg_Regularize_684;
    __Vdfg_Regularize_684 = 0;
    CData/*7:0*/ __Vdfg_Regularize_685;
    __Vdfg_Regularize_685 = 0;
    CData/*7:0*/ __Vdfg_Regularize_686;
    __Vdfg_Regularize_686 = 0;
    CData/*7:0*/ __Vdfg_Regularize_687;
    __Vdfg_Regularize_687 = 0;
    CData/*7:0*/ __Vdfg_Regularize_688;
    __Vdfg_Regularize_688 = 0;
    CData/*7:0*/ __Vdfg_Regularize_689;
    __Vdfg_Regularize_689 = 0;
    CData/*7:0*/ __Vdfg_Regularize_690;
    __Vdfg_Regularize_690 = 0;
    CData/*7:0*/ __Vdfg_Regularize_691;
    __Vdfg_Regularize_691 = 0;
    CData/*7:0*/ __Vdfg_Regularize_692;
    __Vdfg_Regularize_692 = 0;
    CData/*7:0*/ __Vdfg_Regularize_693;
    __Vdfg_Regularize_693 = 0;
    CData/*7:0*/ __Vdfg_Regularize_694;
    __Vdfg_Regularize_694 = 0;
    CData/*7:0*/ __Vdfg_Regularize_695;
    __Vdfg_Regularize_695 = 0;
    CData/*7:0*/ __Vdfg_Regularize_696;
    __Vdfg_Regularize_696 = 0;
    CData/*7:0*/ __Vdfg_Regularize_697;
    __Vdfg_Regularize_697 = 0;
    CData/*7:0*/ __Vdfg_Regularize_698;
    __Vdfg_Regularize_698 = 0;
    CData/*7:0*/ __Vdfg_Regularize_699;
    __Vdfg_Regularize_699 = 0;
    CData/*7:0*/ __Vdfg_Regularize_700;
    __Vdfg_Regularize_700 = 0;
    CData/*7:0*/ __Vdfg_Regularize_701;
    __Vdfg_Regularize_701 = 0;
    CData/*7:0*/ __Vdfg_Regularize_702;
    __Vdfg_Regularize_702 = 0;
    CData/*7:0*/ __Vdfg_Regularize_703;
    __Vdfg_Regularize_703 = 0;
    CData/*7:0*/ __Vdfg_Regularize_704;
    __Vdfg_Regularize_704 = 0;
    CData/*7:0*/ __Vdfg_Regularize_705;
    __Vdfg_Regularize_705 = 0;
    CData/*7:0*/ __Vdfg_Regularize_706;
    __Vdfg_Regularize_706 = 0;
    CData/*7:0*/ __Vdfg_Regularize_707;
    __Vdfg_Regularize_707 = 0;
    CData/*7:0*/ __Vdfg_Regularize_708;
    __Vdfg_Regularize_708 = 0;
    CData/*7:0*/ __Vdfg_Regularize_709;
    __Vdfg_Regularize_709 = 0;
    CData/*7:0*/ __Vdfg_Regularize_710;
    __Vdfg_Regularize_710 = 0;
    CData/*7:0*/ __Vdfg_Regularize_711;
    __Vdfg_Regularize_711 = 0;
    CData/*7:0*/ __Vdfg_Regularize_712;
    __Vdfg_Regularize_712 = 0;
    CData/*7:0*/ __Vdfg_Regularize_713;
    __Vdfg_Regularize_713 = 0;
    CData/*7:0*/ __Vdfg_Regularize_714;
    __Vdfg_Regularize_714 = 0;
    CData/*7:0*/ __Vdfg_Regularize_715;
    __Vdfg_Regularize_715 = 0;
    CData/*7:0*/ __Vdfg_Regularize_716;
    __Vdfg_Regularize_716 = 0;
    CData/*7:0*/ __Vdfg_Regularize_717;
    __Vdfg_Regularize_717 = 0;
    CData/*7:0*/ __Vdfg_Regularize_718;
    __Vdfg_Regularize_718 = 0;
    CData/*7:0*/ __Vdfg_Regularize_719;
    __Vdfg_Regularize_719 = 0;
    CData/*7:0*/ __Vdfg_Regularize_720;
    __Vdfg_Regularize_720 = 0;
    CData/*7:0*/ __Vdfg_Regularize_721;
    __Vdfg_Regularize_721 = 0;
    CData/*7:0*/ __Vdfg_Regularize_722;
    __Vdfg_Regularize_722 = 0;
    CData/*7:0*/ __Vdfg_Regularize_723;
    __Vdfg_Regularize_723 = 0;
    CData/*7:0*/ __Vdfg_Regularize_724;
    __Vdfg_Regularize_724 = 0;
    CData/*7:0*/ __Vdfg_Regularize_725;
    __Vdfg_Regularize_725 = 0;
    CData/*7:0*/ __Vdfg_Regularize_726;
    __Vdfg_Regularize_726 = 0;
    CData/*7:0*/ __Vdfg_Regularize_727;
    __Vdfg_Regularize_727 = 0;
    CData/*7:0*/ __Vdfg_Regularize_728;
    __Vdfg_Regularize_728 = 0;
    CData/*7:0*/ __Vdfg_Regularize_729;
    __Vdfg_Regularize_729 = 0;
    CData/*7:0*/ __Vdfg_Regularize_730;
    __Vdfg_Regularize_730 = 0;
    CData/*7:0*/ __Vdfg_Regularize_731;
    __Vdfg_Regularize_731 = 0;
    CData/*7:0*/ __Vdfg_Regularize_732;
    __Vdfg_Regularize_732 = 0;
    CData/*7:0*/ __Vdfg_Regularize_733;
    __Vdfg_Regularize_733 = 0;
    CData/*7:0*/ __Vdfg_Regularize_734;
    __Vdfg_Regularize_734 = 0;
    CData/*7:0*/ __Vdfg_Regularize_735;
    __Vdfg_Regularize_735 = 0;
    CData/*7:0*/ __Vdfg_Regularize_736;
    __Vdfg_Regularize_736 = 0;
    CData/*7:0*/ __Vdfg_Regularize_737;
    __Vdfg_Regularize_737 = 0;
    CData/*7:0*/ __Vdfg_Regularize_738;
    __Vdfg_Regularize_738 = 0;
    CData/*7:0*/ __Vdfg_Regularize_739;
    __Vdfg_Regularize_739 = 0;
    CData/*7:0*/ __Vdfg_Regularize_740;
    __Vdfg_Regularize_740 = 0;
    CData/*7:0*/ __Vdfg_Regularize_741;
    __Vdfg_Regularize_741 = 0;
    CData/*0:0*/ __Vdly__m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_2__DOT__u_crc_parallel__DOT__reg_busy_4;
    __Vdly__m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_2__DOT__u_crc_parallel__DOT__reg_busy_4 = 0;
    CData/*0:0*/ __Vdly__m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_2__DOT__u_crc_parallel__DOT__reg_busy_11;
    __Vdly__m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_2__DOT__u_crc_parallel__DOT__reg_busy_11 = 0;
    // Body
    __Vdly__m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_2__DOT__u_crc_parallel__DOT__reg_busy_11 
        = vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_2__DOT__u_crc_parallel__DOT__reg_busy;
    __Vdly__m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_2__DOT__u_crc_parallel__DOT__reg_busy_4 
        = vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_2__DOT__u_crc_parallel__DOT__reg_busy;
    if (vlSelfRef.i_rst_n_crc) {
        if (((IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_2__DOT__u_crc_parallel__DOT__reg_crc_valid) 
             & (IData)(vlSelfRef.i_gen_crc_ready))) {
            vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_2__DOT__u_crc_parallel__DOT__reg_crc_valid = 0U;
        }
        if (vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_2__DOT__u_crc_parallel__DOT__reg_busy) {
            __Vdly__m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_2__DOT__u_crc_parallel__DOT__reg_busy_11 = 0U;
            if (vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_2__DOT__u_crc_parallel__DOT__reg_last) {
                vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_2__DOT__u_crc_parallel__DOT__reg_crc_valid = 1U;
                __Vfunc_m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_2__DOT__u_crc_parallel__DOT__f_finalize__i_crc_39 
                    = vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_2__DOT__u_crc_parallel__DOT__w_crc_nxt;
                __Vfunc_m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_2__DOT__u_crc_parallel__DOT__f_finalize__w_reflected_crc_41 
                    = __Vfunc_m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_2__DOT__u_crc_parallel__DOT__f_finalize__i_crc_39;
                __Vfunc_m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_2__DOT__u_crc_parallel__DOT__f_finalize__Vfuncout_38 
                    = __Vfunc_m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_2__DOT__u_crc_parallel__DOT__f_finalize__w_reflected_crc_41;
                vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_2__DOT__u_crc_parallel__DOT__reg_crc_output 
                    = __Vfunc_m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_2__DOT__u_crc_parallel__DOT__f_finalize__Vfuncout_38;
                vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_2__DOT__u_crc_parallel__DOT__reg_crc_state = 0U;
            } else {
                vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_2__DOT__u_crc_parallel__DOT__reg_crc_state 
                    = vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_2__DOT__u_crc_parallel__DOT__w_crc_nxt;
            }
        } else if (((IData)(vlSelfRef.i_gen_valid) 
                    & (IData)(vlSelfRef.o_gen_data_ready))) {
            __Vdly__m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_2__DOT__u_crc_parallel__DOT__reg_busy_11 = 1U;
        }
        if (((IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_2__DOT__u_crc_parallel__DOT__reg_crc_valid) 
             & (IData)(vlSelfRef.i_check_crc_ready))) {
            vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_2__DOT__u_crc_parallel__DOT__reg_crc_valid = 0U;
        }
        if (vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_2__DOT__u_crc_parallel__DOT__reg_busy) {
            __Vdly__m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_2__DOT__u_crc_parallel__DOT__reg_busy_4 = 0U;
            if (vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_2__DOT__u_crc_parallel__DOT__reg_last) {
                vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_2__DOT__u_crc_parallel__DOT__reg_crc_valid = 1U;
                __Vfunc_m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_2__DOT__u_crc_parallel__DOT__f_finalize__i_crc_18 
                    = vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_2__DOT__u_crc_parallel__DOT__w_crc_nxt;
                __Vfunc_m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_2__DOT__u_crc_parallel__DOT__f_finalize__w_reflected_crc_20 
                    = __Vfunc_m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_2__DOT__u_crc_parallel__DOT__f_finalize__i_crc_18;
                __Vfunc_m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_2__DOT__u_crc_parallel__DOT__f_finalize__Vfuncout_17 
                    = __Vfunc_m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_2__DOT__u_crc_parallel__DOT__f_finalize__w_reflected_crc_20;
                vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_2__DOT__u_crc_parallel__DOT__reg_crc_output 
                    = __Vfunc_m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_2__DOT__u_crc_parallel__DOT__f_finalize__Vfuncout_17;
                vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_2__DOT__u_crc_parallel__DOT__reg_crc_state = 0U;
            } else {
                vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_2__DOT__u_crc_parallel__DOT__reg_crc_state 
                    = vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_2__DOT__u_crc_parallel__DOT__w_crc_nxt;
            }
        } else if (((IData)(vlSelfRef.i_check_valid) 
                    & (IData)(vlSelfRef.o_check_data_ready))) {
            __Vdly__m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_2__DOT__u_crc_parallel__DOT__reg_busy_4 = 1U;
        }
        if ((((IData)(vlSelfRef.i_check_valid) & (IData)(vlSelfRef.o_check_data_ready)) 
             & (IData)(vlSelfRef.i_check_last))) {
            vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__reg_check_crc_ref 
                = vlSelfRef.i_check_crc;
        }
        if ((1U & (~ (IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_2__DOT__u_crc_parallel__DOT__reg_busy)))) {
            if (((IData)(vlSelfRef.i_gen_valid) & (IData)(vlSelfRef.o_gen_data_ready))) {
                vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_2__DOT__u_crc_parallel__DOT__reg_keep 
                    = vlSelfRef.i_gen_keep;
                vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_2__DOT__u_crc_parallel__DOT__reg_data 
                    = vlSelfRef.i_gen_data;
                vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_2__DOT__u_crc_parallel__DOT__reg_last 
                    = vlSelfRef.i_gen_last;
            }
        }
        if ((1U & (~ (IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_2__DOT__u_crc_parallel__DOT__reg_busy)))) {
            if (((IData)(vlSelfRef.i_check_valid) & (IData)(vlSelfRef.o_check_data_ready))) {
                vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_2__DOT__u_crc_parallel__DOT__reg_keep 
                    = vlSelfRef.i_check_keep;
                vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_2__DOT__u_crc_parallel__DOT__reg_data 
                    = vlSelfRef.i_check_data;
                vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_2__DOT__u_crc_parallel__DOT__reg_last 
                    = vlSelfRef.i_check_last;
            }
        }
    } else {
        __Vdly__m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_2__DOT__u_crc_parallel__DOT__reg_busy_11 = 0U;
        __Vdly__m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_2__DOT__u_crc_parallel__DOT__reg_busy_4 = 0U;
        vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_2__DOT__u_crc_parallel__DOT__reg_crc_valid = 0U;
        vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_2__DOT__u_crc_parallel__DOT__reg_crc_valid = 0U;
        vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__reg_check_crc_ref = 0U;
        vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_2__DOT__u_crc_parallel__DOT__reg_crc_output = 0U;
        vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_2__DOT__u_crc_parallel__DOT__reg_crc_output = 0U;
        vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_2__DOT__u_crc_parallel__DOT__reg_keep = 0U;
        vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_2__DOT__u_crc_parallel__DOT__reg_keep = 0U;
        vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_2__DOT__u_crc_parallel__DOT__reg_data = 0U;
        vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_2__DOT__u_crc_parallel__DOT__reg_data = 0U;
        vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_2__DOT__u_crc_parallel__DOT__reg_crc_state = 0U;
        vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_2__DOT__u_crc_parallel__DOT__reg_crc_state = 0U;
        vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_2__DOT__u_crc_parallel__DOT__reg_last = 0U;
        vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_2__DOT__u_crc_parallel__DOT__reg_last = 0U;
    }
    vlSelfRef.o_gen_crc_valid = vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_2__DOT__u_crc_parallel__DOT__reg_crc_valid;
    vlSelfRef.o_check_crc_valid = vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_2__DOT__u_crc_parallel__DOT__reg_crc_valid;
    vlSelfRef.o_gen_crc = vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_2__DOT__u_crc_parallel__DOT__reg_crc_output;
    vlSelfRef.o_check_pass = ((IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_2__DOT__u_crc_parallel__DOT__reg_crc_valid) 
                              & ((IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__reg_check_crc_ref) 
                                 == (IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_2__DOT__u_crc_parallel__DOT__reg_crc_output)));
    __Vdfg_Regularize_675 = ((0x000000feU & ((IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_2__DOT__u_crc_parallel__DOT__reg_crc_state) 
                                             << 1U)) 
                             | (vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_2__DOT__u_crc_parallel__DOT__reg_data 
                                >> 0x0000001fU));
    __Vdfg_Regularize_600 = ((0x000000feU & ((IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_2__DOT__u_crc_parallel__DOT__reg_crc_state) 
                                             << 1U)) 
                             | (vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_2__DOT__u_crc_parallel__DOT__reg_data 
                                >> 0x0000001fU));
    vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_2__DOT__u_crc_parallel__DOT__reg_busy 
        = __Vdly__m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_2__DOT__u_crc_parallel__DOT__reg_busy_11;
    __Vdfg_Regularize_676 = ((0x00000080U & (IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_2__DOT__u_crc_parallel__DOT__reg_crc_state))
                              ? (7U ^ (IData)(__Vdfg_Regularize_675))
                              : (IData)(__Vdfg_Regularize_675));
    vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_2__DOT__u_crc_parallel__DOT__reg_busy 
        = __Vdly__m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_2__DOT__u_crc_parallel__DOT__reg_busy_4;
    __Vdfg_Regularize_601 = ((0x00000080U & (IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_2__DOT__u_crc_parallel__DOT__reg_crc_state))
                              ? (7U ^ (IData)(__Vdfg_Regularize_600))
                              : (IData)(__Vdfg_Regularize_600));
    vlSelfRef.o_gen_data_ready = ((~ ((IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_2__DOT__u_crc_parallel__DOT__reg_busy) 
                                      | (IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_2__DOT__u_crc_parallel__DOT__reg_crc_valid))) 
                                  & (IData)(vlSelfRef.i_rst_n_crc));
    __Vdfg_Regularize_677 = ((0x000000feU & ((IData)(__Vdfg_Regularize_676) 
                                             << 1U)) 
                             | (1U & (vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_2__DOT__u_crc_parallel__DOT__reg_data 
                                      >> 0x0000001eU)));
    vlSelfRef.o_check_data_ready = ((~ ((IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_2__DOT__u_crc_parallel__DOT__reg_busy) 
                                        | (IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_2__DOT__u_crc_parallel__DOT__reg_crc_valid))) 
                                    & (IData)(vlSelfRef.i_rst_n_crc));
    __Vdfg_Regularize_602 = ((0x000000feU & ((IData)(__Vdfg_Regularize_601) 
                                             << 1U)) 
                             | (1U & (vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_2__DOT__u_crc_parallel__DOT__reg_data 
                                      >> 0x0000001eU)));
    __Vdfg_Regularize_678 = ((0x00000080U & (IData)(__Vdfg_Regularize_676))
                              ? (7U ^ (IData)(__Vdfg_Regularize_677))
                              : (IData)(__Vdfg_Regularize_677));
    __Vdfg_Regularize_603 = ((0x00000080U & (IData)(__Vdfg_Regularize_601))
                              ? (7U ^ (IData)(__Vdfg_Regularize_602))
                              : (IData)(__Vdfg_Regularize_602));
    __Vdfg_Regularize_679 = ((0x000000feU & ((IData)(__Vdfg_Regularize_678) 
                                             << 1U)) 
                             | (1U & (vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_2__DOT__u_crc_parallel__DOT__reg_data 
                                      >> 0x0000001dU)));
    __Vdfg_Regularize_604 = ((0x000000feU & ((IData)(__Vdfg_Regularize_603) 
                                             << 1U)) 
                             | (1U & (vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_2__DOT__u_crc_parallel__DOT__reg_data 
                                      >> 0x0000001dU)));
    __Vdfg_Regularize_680 = ((0x00000080U & (IData)(__Vdfg_Regularize_678))
                              ? (7U ^ (IData)(__Vdfg_Regularize_679))
                              : (IData)(__Vdfg_Regularize_679));
    __Vdfg_Regularize_605 = ((0x00000080U & (IData)(__Vdfg_Regularize_603))
                              ? (7U ^ (IData)(__Vdfg_Regularize_604))
                              : (IData)(__Vdfg_Regularize_604));
    __Vdfg_Regularize_681 = ((0x000000feU & ((IData)(__Vdfg_Regularize_680) 
                                             << 1U)) 
                             | (1U & (vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_2__DOT__u_crc_parallel__DOT__reg_data 
                                      >> 0x0000001cU)));
    __Vdfg_Regularize_606 = ((0x000000feU & ((IData)(__Vdfg_Regularize_605) 
                                             << 1U)) 
                             | (1U & (vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_2__DOT__u_crc_parallel__DOT__reg_data 
                                      >> 0x0000001cU)));
    __Vdfg_Regularize_682 = ((0x00000080U & (IData)(__Vdfg_Regularize_680))
                              ? (7U ^ (IData)(__Vdfg_Regularize_681))
                              : (IData)(__Vdfg_Regularize_681));
    __Vdfg_Regularize_607 = ((0x00000080U & (IData)(__Vdfg_Regularize_605))
                              ? (7U ^ (IData)(__Vdfg_Regularize_606))
                              : (IData)(__Vdfg_Regularize_606));
    __Vdfg_Regularize_683 = ((0x000000feU & ((IData)(__Vdfg_Regularize_682) 
                                             << 1U)) 
                             | (1U & (vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_2__DOT__u_crc_parallel__DOT__reg_data 
                                      >> 0x0000001bU)));
    __Vdfg_Regularize_608 = ((0x000000feU & ((IData)(__Vdfg_Regularize_607) 
                                             << 1U)) 
                             | (1U & (vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_2__DOT__u_crc_parallel__DOT__reg_data 
                                      >> 0x0000001bU)));
    __Vdfg_Regularize_684 = ((0x00000080U & (IData)(__Vdfg_Regularize_682))
                              ? (7U ^ (IData)(__Vdfg_Regularize_683))
                              : (IData)(__Vdfg_Regularize_683));
    __Vdfg_Regularize_609 = ((0x00000080U & (IData)(__Vdfg_Regularize_607))
                              ? (7U ^ (IData)(__Vdfg_Regularize_608))
                              : (IData)(__Vdfg_Regularize_608));
    __Vdfg_Regularize_685 = ((0x000000feU & ((IData)(__Vdfg_Regularize_684) 
                                             << 1U)) 
                             | (1U & (vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_2__DOT__u_crc_parallel__DOT__reg_data 
                                      >> 0x0000001aU)));
    __Vdfg_Regularize_610 = ((0x000000feU & ((IData)(__Vdfg_Regularize_609) 
                                             << 1U)) 
                             | (1U & (vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_2__DOT__u_crc_parallel__DOT__reg_data 
                                      >> 0x0000001aU)));
    __Vdfg_Regularize_686 = ((0x00000080U & (IData)(__Vdfg_Regularize_684))
                              ? (7U ^ (IData)(__Vdfg_Regularize_685))
                              : (IData)(__Vdfg_Regularize_685));
    __Vdfg_Regularize_611 = ((0x00000080U & (IData)(__Vdfg_Regularize_609))
                              ? (7U ^ (IData)(__Vdfg_Regularize_610))
                              : (IData)(__Vdfg_Regularize_610));
    __Vdfg_Regularize_687 = ((0x000000feU & ((IData)(__Vdfg_Regularize_686) 
                                             << 1U)) 
                             | (1U & (vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_2__DOT__u_crc_parallel__DOT__reg_data 
                                      >> 0x00000019U)));
    __Vdfg_Regularize_612 = ((0x000000feU & ((IData)(__Vdfg_Regularize_611) 
                                             << 1U)) 
                             | (1U & (vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_2__DOT__u_crc_parallel__DOT__reg_data 
                                      >> 0x00000019U)));
    __Vdfg_Regularize_688 = ((0x00000080U & (IData)(__Vdfg_Regularize_686))
                              ? (7U ^ (IData)(__Vdfg_Regularize_687))
                              : (IData)(__Vdfg_Regularize_687));
    __Vdfg_Regularize_613 = ((0x00000080U & (IData)(__Vdfg_Regularize_611))
                              ? (7U ^ (IData)(__Vdfg_Regularize_612))
                              : (IData)(__Vdfg_Regularize_612));
    __Vdfg_Regularize_689 = ((0x000000feU & ((IData)(__Vdfg_Regularize_688) 
                                             << 1U)) 
                             | (1U & (vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_2__DOT__u_crc_parallel__DOT__reg_data 
                                      >> 0x00000018U)));
    __Vdfg_Regularize_614 = ((0x000000feU & ((IData)(__Vdfg_Regularize_613) 
                                             << 1U)) 
                             | (1U & (vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_2__DOT__u_crc_parallel__DOT__reg_data 
                                      >> 0x00000018U)));
    __Vdfg_Regularize_596 = ((8U & (IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_2__DOT__u_crc_parallel__DOT__reg_keep))
                              ? ((0x00000080U & (IData)(__Vdfg_Regularize_688))
                                  ? (7U ^ (IData)(__Vdfg_Regularize_689))
                                  : (IData)(__Vdfg_Regularize_689))
                              : (IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_2__DOT__u_crc_parallel__DOT__reg_crc_state));
    __Vdfg_Regularize_592 = ((8U & (IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_2__DOT__u_crc_parallel__DOT__reg_keep))
                              ? ((0x00000080U & (IData)(__Vdfg_Regularize_613))
                                  ? (7U ^ (IData)(__Vdfg_Regularize_614))
                                  : (IData)(__Vdfg_Regularize_614))
                              : (IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_2__DOT__u_crc_parallel__DOT__reg_crc_state));
    __Vdfg_Regularize_690 = ((0x000000feU & ((IData)(__Vdfg_Regularize_596) 
                                             << 1U)) 
                             | (1U & (vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_2__DOT__u_crc_parallel__DOT__reg_data 
                                      >> 0x00000017U)));
    __Vdfg_Regularize_615 = ((0x000000feU & ((IData)(__Vdfg_Regularize_592) 
                                             << 1U)) 
                             | (1U & (vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_2__DOT__u_crc_parallel__DOT__reg_data 
                                      >> 0x00000017U)));
    __Vdfg_Regularize_691 = ((0x00000080U & (IData)(__Vdfg_Regularize_596))
                              ? (7U ^ (IData)(__Vdfg_Regularize_690))
                              : (IData)(__Vdfg_Regularize_690));
    __Vdfg_Regularize_616 = ((0x00000080U & (IData)(__Vdfg_Regularize_592))
                              ? (7U ^ (IData)(__Vdfg_Regularize_615))
                              : (IData)(__Vdfg_Regularize_615));
    __Vdfg_Regularize_692 = ((0x000000feU & ((IData)(__Vdfg_Regularize_691) 
                                             << 1U)) 
                             | (1U & (vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_2__DOT__u_crc_parallel__DOT__reg_data 
                                      >> 0x00000016U)));
    __Vdfg_Regularize_617 = ((0x000000feU & ((IData)(__Vdfg_Regularize_616) 
                                             << 1U)) 
                             | (1U & (vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_2__DOT__u_crc_parallel__DOT__reg_data 
                                      >> 0x00000016U)));
    __Vdfg_Regularize_693 = ((0x00000080U & (IData)(__Vdfg_Regularize_691))
                              ? (7U ^ (IData)(__Vdfg_Regularize_692))
                              : (IData)(__Vdfg_Regularize_692));
    __Vdfg_Regularize_618 = ((0x00000080U & (IData)(__Vdfg_Regularize_616))
                              ? (7U ^ (IData)(__Vdfg_Regularize_617))
                              : (IData)(__Vdfg_Regularize_617));
    __Vdfg_Regularize_694 = ((0x000000feU & ((IData)(__Vdfg_Regularize_693) 
                                             << 1U)) 
                             | (1U & (vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_2__DOT__u_crc_parallel__DOT__reg_data 
                                      >> 0x00000015U)));
    __Vdfg_Regularize_619 = ((0x000000feU & ((IData)(__Vdfg_Regularize_618) 
                                             << 1U)) 
                             | (1U & (vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_2__DOT__u_crc_parallel__DOT__reg_data 
                                      >> 0x00000015U)));
    __Vdfg_Regularize_695 = ((0x00000080U & (IData)(__Vdfg_Regularize_693))
                              ? (7U ^ (IData)(__Vdfg_Regularize_694))
                              : (IData)(__Vdfg_Regularize_694));
    __Vdfg_Regularize_620 = ((0x00000080U & (IData)(__Vdfg_Regularize_618))
                              ? (7U ^ (IData)(__Vdfg_Regularize_619))
                              : (IData)(__Vdfg_Regularize_619));
    __Vdfg_Regularize_696 = ((0x000000feU & ((IData)(__Vdfg_Regularize_695) 
                                             << 1U)) 
                             | (1U & (vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_2__DOT__u_crc_parallel__DOT__reg_data 
                                      >> 0x00000014U)));
    __Vdfg_Regularize_621 = ((0x000000feU & ((IData)(__Vdfg_Regularize_620) 
                                             << 1U)) 
                             | (1U & (vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_2__DOT__u_crc_parallel__DOT__reg_data 
                                      >> 0x00000014U)));
    __Vdfg_Regularize_697 = ((0x00000080U & (IData)(__Vdfg_Regularize_695))
                              ? (7U ^ (IData)(__Vdfg_Regularize_696))
                              : (IData)(__Vdfg_Regularize_696));
    __Vdfg_Regularize_622 = ((0x00000080U & (IData)(__Vdfg_Regularize_620))
                              ? (7U ^ (IData)(__Vdfg_Regularize_621))
                              : (IData)(__Vdfg_Regularize_621));
    __Vdfg_Regularize_698 = ((0x000000feU & ((IData)(__Vdfg_Regularize_697) 
                                             << 1U)) 
                             | (1U & (vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_2__DOT__u_crc_parallel__DOT__reg_data 
                                      >> 0x00000013U)));
    __Vdfg_Regularize_623 = ((0x000000feU & ((IData)(__Vdfg_Regularize_622) 
                                             << 1U)) 
                             | (1U & (vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_2__DOT__u_crc_parallel__DOT__reg_data 
                                      >> 0x00000013U)));
    __Vdfg_Regularize_699 = ((0x00000080U & (IData)(__Vdfg_Regularize_697))
                              ? (7U ^ (IData)(__Vdfg_Regularize_698))
                              : (IData)(__Vdfg_Regularize_698));
    __Vdfg_Regularize_624 = ((0x00000080U & (IData)(__Vdfg_Regularize_622))
                              ? (7U ^ (IData)(__Vdfg_Regularize_623))
                              : (IData)(__Vdfg_Regularize_623));
    __Vdfg_Regularize_700 = ((0x000000feU & ((IData)(__Vdfg_Regularize_699) 
                                             << 1U)) 
                             | (1U & (vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_2__DOT__u_crc_parallel__DOT__reg_data 
                                      >> 0x00000012U)));
    __Vdfg_Regularize_625 = ((0x000000feU & ((IData)(__Vdfg_Regularize_624) 
                                             << 1U)) 
                             | (1U & (vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_2__DOT__u_crc_parallel__DOT__reg_data 
                                      >> 0x00000012U)));
    __Vdfg_Regularize_701 = ((0x00000080U & (IData)(__Vdfg_Regularize_699))
                              ? (7U ^ (IData)(__Vdfg_Regularize_700))
                              : (IData)(__Vdfg_Regularize_700));
    __Vdfg_Regularize_626 = ((0x00000080U & (IData)(__Vdfg_Regularize_624))
                              ? (7U ^ (IData)(__Vdfg_Regularize_625))
                              : (IData)(__Vdfg_Regularize_625));
    __Vdfg_Regularize_702 = ((0x000000feU & ((IData)(__Vdfg_Regularize_701) 
                                             << 1U)) 
                             | (1U & (vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_2__DOT__u_crc_parallel__DOT__reg_data 
                                      >> 0x00000011U)));
    __Vdfg_Regularize_627 = ((0x000000feU & ((IData)(__Vdfg_Regularize_626) 
                                             << 1U)) 
                             | (1U & (vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_2__DOT__u_crc_parallel__DOT__reg_data 
                                      >> 0x00000011U)));
    __Vdfg_Regularize_703 = ((0x00000080U & (IData)(__Vdfg_Regularize_701))
                              ? (7U ^ (IData)(__Vdfg_Regularize_702))
                              : (IData)(__Vdfg_Regularize_702));
    __Vdfg_Regularize_628 = ((0x00000080U & (IData)(__Vdfg_Regularize_626))
                              ? (7U ^ (IData)(__Vdfg_Regularize_627))
                              : (IData)(__Vdfg_Regularize_627));
    __Vdfg_Regularize_704 = ((0x000000feU & ((IData)(__Vdfg_Regularize_703) 
                                             << 1U)) 
                             | (1U & (vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_2__DOT__u_crc_parallel__DOT__reg_data 
                                      >> 0x00000010U)));
    __Vdfg_Regularize_629 = ((0x000000feU & ((IData)(__Vdfg_Regularize_628) 
                                             << 1U)) 
                             | (1U & (vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_2__DOT__u_crc_parallel__DOT__reg_data 
                                      >> 0x00000010U)));
    __Vdfg_Regularize_597 = ((4U & (IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_2__DOT__u_crc_parallel__DOT__reg_keep))
                              ? ((0x00000080U & (IData)(__Vdfg_Regularize_703))
                                  ? (7U ^ (IData)(__Vdfg_Regularize_704))
                                  : (IData)(__Vdfg_Regularize_704))
                              : (IData)(__Vdfg_Regularize_596));
    __Vdfg_Regularize_593 = ((4U & (IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_2__DOT__u_crc_parallel__DOT__reg_keep))
                              ? ((0x00000080U & (IData)(__Vdfg_Regularize_628))
                                  ? (7U ^ (IData)(__Vdfg_Regularize_629))
                                  : (IData)(__Vdfg_Regularize_629))
                              : (IData)(__Vdfg_Regularize_592));
    __Vdfg_Regularize_705 = ((0x000000feU & ((IData)(__Vdfg_Regularize_597) 
                                             << 1U)) 
                             | (1U & (vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_2__DOT__u_crc_parallel__DOT__reg_data 
                                      >> 0x0000000fU)));
    __Vdfg_Regularize_630 = ((0x000000feU & ((IData)(__Vdfg_Regularize_593) 
                                             << 1U)) 
                             | (1U & (vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_2__DOT__u_crc_parallel__DOT__reg_data 
                                      >> 0x0000000fU)));
    __Vdfg_Regularize_706 = ((0x00000080U & (IData)(__Vdfg_Regularize_597))
                              ? (7U ^ (IData)(__Vdfg_Regularize_705))
                              : (IData)(__Vdfg_Regularize_705));
    __Vdfg_Regularize_631 = ((0x00000080U & (IData)(__Vdfg_Regularize_593))
                              ? (7U ^ (IData)(__Vdfg_Regularize_630))
                              : (IData)(__Vdfg_Regularize_630));
    __Vdfg_Regularize_707 = ((0x000000feU & ((IData)(__Vdfg_Regularize_706) 
                                             << 1U)) 
                             | (1U & (vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_2__DOT__u_crc_parallel__DOT__reg_data 
                                      >> 0x0000000eU)));
    __Vdfg_Regularize_632 = ((0x000000feU & ((IData)(__Vdfg_Regularize_631) 
                                             << 1U)) 
                             | (1U & (vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_2__DOT__u_crc_parallel__DOT__reg_data 
                                      >> 0x0000000eU)));
    __Vdfg_Regularize_708 = ((0x00000080U & (IData)(__Vdfg_Regularize_706))
                              ? (7U ^ (IData)(__Vdfg_Regularize_707))
                              : (IData)(__Vdfg_Regularize_707));
    __Vdfg_Regularize_633 = ((0x00000080U & (IData)(__Vdfg_Regularize_631))
                              ? (7U ^ (IData)(__Vdfg_Regularize_632))
                              : (IData)(__Vdfg_Regularize_632));
    __Vdfg_Regularize_709 = ((0x000000feU & ((IData)(__Vdfg_Regularize_708) 
                                             << 1U)) 
                             | (1U & (vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_2__DOT__u_crc_parallel__DOT__reg_data 
                                      >> 0x0000000dU)));
    __Vdfg_Regularize_634 = ((0x000000feU & ((IData)(__Vdfg_Regularize_633) 
                                             << 1U)) 
                             | (1U & (vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_2__DOT__u_crc_parallel__DOT__reg_data 
                                      >> 0x0000000dU)));
    __Vdfg_Regularize_710 = ((0x00000080U & (IData)(__Vdfg_Regularize_708))
                              ? (7U ^ (IData)(__Vdfg_Regularize_709))
                              : (IData)(__Vdfg_Regularize_709));
    __Vdfg_Regularize_635 = ((0x00000080U & (IData)(__Vdfg_Regularize_633))
                              ? (7U ^ (IData)(__Vdfg_Regularize_634))
                              : (IData)(__Vdfg_Regularize_634));
    __Vdfg_Regularize_711 = ((0x000000feU & ((IData)(__Vdfg_Regularize_710) 
                                             << 1U)) 
                             | (1U & (vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_2__DOT__u_crc_parallel__DOT__reg_data 
                                      >> 0x0000000cU)));
    __Vdfg_Regularize_636 = ((0x000000feU & ((IData)(__Vdfg_Regularize_635) 
                                             << 1U)) 
                             | (1U & (vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_2__DOT__u_crc_parallel__DOT__reg_data 
                                      >> 0x0000000cU)));
    __Vdfg_Regularize_712 = ((0x00000080U & (IData)(__Vdfg_Regularize_710))
                              ? (7U ^ (IData)(__Vdfg_Regularize_711))
                              : (IData)(__Vdfg_Regularize_711));
    __Vdfg_Regularize_637 = ((0x00000080U & (IData)(__Vdfg_Regularize_635))
                              ? (7U ^ (IData)(__Vdfg_Regularize_636))
                              : (IData)(__Vdfg_Regularize_636));
    __Vdfg_Regularize_713 = ((0x000000feU & ((IData)(__Vdfg_Regularize_712) 
                                             << 1U)) 
                             | (1U & (vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_2__DOT__u_crc_parallel__DOT__reg_data 
                                      >> 0x0000000bU)));
    __Vdfg_Regularize_638 = ((0x000000feU & ((IData)(__Vdfg_Regularize_637) 
                                             << 1U)) 
                             | (1U & (vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_2__DOT__u_crc_parallel__DOT__reg_data 
                                      >> 0x0000000bU)));
    __Vdfg_Regularize_714 = ((0x00000080U & (IData)(__Vdfg_Regularize_712))
                              ? (7U ^ (IData)(__Vdfg_Regularize_713))
                              : (IData)(__Vdfg_Regularize_713));
    __Vdfg_Regularize_639 = ((0x00000080U & (IData)(__Vdfg_Regularize_637))
                              ? (7U ^ (IData)(__Vdfg_Regularize_638))
                              : (IData)(__Vdfg_Regularize_638));
    __Vdfg_Regularize_715 = ((0x000000feU & ((IData)(__Vdfg_Regularize_714) 
                                             << 1U)) 
                             | (1U & (vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_2__DOT__u_crc_parallel__DOT__reg_data 
                                      >> 0x0000000aU)));
    __Vdfg_Regularize_640 = ((0x000000feU & ((IData)(__Vdfg_Regularize_639) 
                                             << 1U)) 
                             | (1U & (vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_2__DOT__u_crc_parallel__DOT__reg_data 
                                      >> 0x0000000aU)));
    __Vdfg_Regularize_716 = ((0x00000080U & (IData)(__Vdfg_Regularize_714))
                              ? (7U ^ (IData)(__Vdfg_Regularize_715))
                              : (IData)(__Vdfg_Regularize_715));
    __Vdfg_Regularize_641 = ((0x00000080U & (IData)(__Vdfg_Regularize_639))
                              ? (7U ^ (IData)(__Vdfg_Regularize_640))
                              : (IData)(__Vdfg_Regularize_640));
    __Vdfg_Regularize_717 = ((0x000000feU & ((IData)(__Vdfg_Regularize_716) 
                                             << 1U)) 
                             | (1U & (vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_2__DOT__u_crc_parallel__DOT__reg_data 
                                      >> 9U)));
    __Vdfg_Regularize_642 = ((0x000000feU & ((IData)(__Vdfg_Regularize_641) 
                                             << 1U)) 
                             | (1U & (vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_2__DOT__u_crc_parallel__DOT__reg_data 
                                      >> 9U)));
    __Vdfg_Regularize_718 = ((0x00000080U & (IData)(__Vdfg_Regularize_716))
                              ? (7U ^ (IData)(__Vdfg_Regularize_717))
                              : (IData)(__Vdfg_Regularize_717));
    __Vdfg_Regularize_643 = ((0x00000080U & (IData)(__Vdfg_Regularize_641))
                              ? (7U ^ (IData)(__Vdfg_Regularize_642))
                              : (IData)(__Vdfg_Regularize_642));
    __Vdfg_Regularize_719 = ((0x000000feU & ((IData)(__Vdfg_Regularize_718) 
                                             << 1U)) 
                             | (1U & (vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_2__DOT__u_crc_parallel__DOT__reg_data 
                                      >> 8U)));
    __Vdfg_Regularize_644 = ((0x000000feU & ((IData)(__Vdfg_Regularize_643) 
                                             << 1U)) 
                             | (1U & (vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_2__DOT__u_crc_parallel__DOT__reg_data 
                                      >> 8U)));
    __Vdfg_Regularize_598 = ((2U & (IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_2__DOT__u_crc_parallel__DOT__reg_keep))
                              ? ((0x00000080U & (IData)(__Vdfg_Regularize_718))
                                  ? (7U ^ (IData)(__Vdfg_Regularize_719))
                                  : (IData)(__Vdfg_Regularize_719))
                              : (IData)(__Vdfg_Regularize_597));
    __Vdfg_Regularize_594 = ((2U & (IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_2__DOT__u_crc_parallel__DOT__reg_keep))
                              ? ((0x00000080U & (IData)(__Vdfg_Regularize_643))
                                  ? (7U ^ (IData)(__Vdfg_Regularize_644))
                                  : (IData)(__Vdfg_Regularize_644))
                              : (IData)(__Vdfg_Regularize_593));
    __Vdfg_Regularize_720 = ((0x000000feU & ((IData)(__Vdfg_Regularize_598) 
                                             << 1U)) 
                             | (1U & (vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_2__DOT__u_crc_parallel__DOT__reg_data 
                                      >> 7U)));
    __Vdfg_Regularize_645 = ((0x000000feU & ((IData)(__Vdfg_Regularize_594) 
                                             << 1U)) 
                             | (1U & (vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_2__DOT__u_crc_parallel__DOT__reg_data 
                                      >> 7U)));
    __Vdfg_Regularize_721 = ((0x00000080U & (IData)(__Vdfg_Regularize_598))
                              ? (7U ^ (IData)(__Vdfg_Regularize_720))
                              : (IData)(__Vdfg_Regularize_720));
    __Vdfg_Regularize_646 = ((0x00000080U & (IData)(__Vdfg_Regularize_594))
                              ? (7U ^ (IData)(__Vdfg_Regularize_645))
                              : (IData)(__Vdfg_Regularize_645));
    __Vdfg_Regularize_722 = ((0x000000feU & ((IData)(__Vdfg_Regularize_721) 
                                             << 1U)) 
                             | (1U & (vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_2__DOT__u_crc_parallel__DOT__reg_data 
                                      >> 6U)));
    __Vdfg_Regularize_647 = ((0x000000feU & ((IData)(__Vdfg_Regularize_646) 
                                             << 1U)) 
                             | (1U & (vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_2__DOT__u_crc_parallel__DOT__reg_data 
                                      >> 6U)));
    __Vdfg_Regularize_723 = ((0x00000080U & (IData)(__Vdfg_Regularize_721))
                              ? (7U ^ (IData)(__Vdfg_Regularize_722))
                              : (IData)(__Vdfg_Regularize_722));
    __Vdfg_Regularize_648 = ((0x00000080U & (IData)(__Vdfg_Regularize_646))
                              ? (7U ^ (IData)(__Vdfg_Regularize_647))
                              : (IData)(__Vdfg_Regularize_647));
    __Vdfg_Regularize_724 = ((0x000000feU & ((IData)(__Vdfg_Regularize_723) 
                                             << 1U)) 
                             | (1U & (vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_2__DOT__u_crc_parallel__DOT__reg_data 
                                      >> 5U)));
    __Vdfg_Regularize_649 = ((0x000000feU & ((IData)(__Vdfg_Regularize_648) 
                                             << 1U)) 
                             | (1U & (vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_2__DOT__u_crc_parallel__DOT__reg_data 
                                      >> 5U)));
    __Vdfg_Regularize_725 = ((0x00000080U & (IData)(__Vdfg_Regularize_723))
                              ? (7U ^ (IData)(__Vdfg_Regularize_724))
                              : (IData)(__Vdfg_Regularize_724));
    __Vdfg_Regularize_650 = ((0x00000080U & (IData)(__Vdfg_Regularize_648))
                              ? (7U ^ (IData)(__Vdfg_Regularize_649))
                              : (IData)(__Vdfg_Regularize_649));
    __Vdfg_Regularize_726 = ((0x000000feU & ((IData)(__Vdfg_Regularize_725) 
                                             << 1U)) 
                             | (1U & (vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_2__DOT__u_crc_parallel__DOT__reg_data 
                                      >> 4U)));
    __Vdfg_Regularize_651 = ((0x000000feU & ((IData)(__Vdfg_Regularize_650) 
                                             << 1U)) 
                             | (1U & (vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_2__DOT__u_crc_parallel__DOT__reg_data 
                                      >> 4U)));
    __Vdfg_Regularize_727 = ((0x00000080U & (IData)(__Vdfg_Regularize_725))
                              ? (7U ^ (IData)(__Vdfg_Regularize_726))
                              : (IData)(__Vdfg_Regularize_726));
    __Vdfg_Regularize_652 = ((0x00000080U & (IData)(__Vdfg_Regularize_650))
                              ? (7U ^ (IData)(__Vdfg_Regularize_651))
                              : (IData)(__Vdfg_Regularize_651));
    __Vdfg_Regularize_728 = ((0x000000feU & ((IData)(__Vdfg_Regularize_727) 
                                             << 1U)) 
                             | (1U & (vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_2__DOT__u_crc_parallel__DOT__reg_data 
                                      >> 3U)));
    __Vdfg_Regularize_653 = ((0x000000feU & ((IData)(__Vdfg_Regularize_652) 
                                             << 1U)) 
                             | (1U & (vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_2__DOT__u_crc_parallel__DOT__reg_data 
                                      >> 3U)));
    __Vdfg_Regularize_729 = ((0x00000080U & (IData)(__Vdfg_Regularize_727))
                              ? (7U ^ (IData)(__Vdfg_Regularize_728))
                              : (IData)(__Vdfg_Regularize_728));
    __Vdfg_Regularize_654 = ((0x00000080U & (IData)(__Vdfg_Regularize_652))
                              ? (7U ^ (IData)(__Vdfg_Regularize_653))
                              : (IData)(__Vdfg_Regularize_653));
    __Vdfg_Regularize_730 = ((0x000000feU & ((IData)(__Vdfg_Regularize_729) 
                                             << 1U)) 
                             | (1U & (vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_2__DOT__u_crc_parallel__DOT__reg_data 
                                      >> 2U)));
    __Vdfg_Regularize_655 = ((0x000000feU & ((IData)(__Vdfg_Regularize_654) 
                                             << 1U)) 
                             | (1U & (vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_2__DOT__u_crc_parallel__DOT__reg_data 
                                      >> 2U)));
    __Vdfg_Regularize_731 = ((0x00000080U & (IData)(__Vdfg_Regularize_729))
                              ? (7U ^ (IData)(__Vdfg_Regularize_730))
                              : (IData)(__Vdfg_Regularize_730));
    __Vdfg_Regularize_656 = ((0x00000080U & (IData)(__Vdfg_Regularize_654))
                              ? (7U ^ (IData)(__Vdfg_Regularize_655))
                              : (IData)(__Vdfg_Regularize_655));
    __Vdfg_Regularize_732 = ((0x000000feU & ((IData)(__Vdfg_Regularize_731) 
                                             << 1U)) 
                             | (1U & (vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_2__DOT__u_crc_parallel__DOT__reg_data 
                                      >> 1U)));
    __Vdfg_Regularize_657 = ((0x000000feU & ((IData)(__Vdfg_Regularize_656) 
                                             << 1U)) 
                             | (1U & (vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_2__DOT__u_crc_parallel__DOT__reg_data 
                                      >> 1U)));
    __Vdfg_Regularize_733 = ((0x00000080U & (IData)(__Vdfg_Regularize_731))
                              ? (7U ^ (IData)(__Vdfg_Regularize_732))
                              : (IData)(__Vdfg_Regularize_732));
    __Vdfg_Regularize_658 = ((0x00000080U & (IData)(__Vdfg_Regularize_656))
                              ? (7U ^ (IData)(__Vdfg_Regularize_657))
                              : (IData)(__Vdfg_Regularize_657));
    __Vdfg_Regularize_734 = ((0x000000feU & ((IData)(__Vdfg_Regularize_733) 
                                             << 1U)) 
                             | (1U & vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_2__DOT__u_crc_parallel__DOT__reg_data));
    __Vdfg_Regularize_659 = ((0x000000feU & ((IData)(__Vdfg_Regularize_658) 
                                             << 1U)) 
                             | (1U & vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_2__DOT__u_crc_parallel__DOT__reg_data));
    __Vdfg_Regularize_599 = ((1U & (IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_2__DOT__u_crc_parallel__DOT__reg_keep))
                              ? ((0x00000080U & (IData)(__Vdfg_Regularize_733))
                                  ? (7U ^ (IData)(__Vdfg_Regularize_734))
                                  : (IData)(__Vdfg_Regularize_734))
                              : (IData)(__Vdfg_Regularize_598));
    __Vdfg_Regularize_595 = ((1U & (IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_2__DOT__u_crc_parallel__DOT__reg_keep))
                              ? ((0x00000080U & (IData)(__Vdfg_Regularize_658))
                                  ? (7U ^ (IData)(__Vdfg_Regularize_659))
                                  : (IData)(__Vdfg_Regularize_659))
                              : (IData)(__Vdfg_Regularize_594));
    __Vdfg_Regularize_735 = ((0x00000080U & (IData)(__Vdfg_Regularize_599))
                              ? (1U | (0x000000feU 
                                       & (6U ^ (0x000000feU 
                                                & ((IData)(__Vdfg_Regularize_599) 
                                                   << 1U)))))
                              : (0x000000feU & ((IData)(__Vdfg_Regularize_599) 
                                                << 1U)));
    __Vdfg_Regularize_660 = ((0x00000080U & (IData)(__Vdfg_Regularize_595))
                              ? (1U | (0x000000feU 
                                       & (6U ^ (0x000000feU 
                                                & ((IData)(__Vdfg_Regularize_595) 
                                                   << 1U)))))
                              : (0x000000feU & ((IData)(__Vdfg_Regularize_595) 
                                                << 1U)));
    __Vdfg_Regularize_736 = ((0x00000080U & (IData)(__Vdfg_Regularize_735))
                              ? (1U | (0x000000feU 
                                       & (6U ^ (0x000000feU 
                                                & ((IData)(__Vdfg_Regularize_735) 
                                                   << 1U)))))
                              : (0x000000feU & ((IData)(__Vdfg_Regularize_735) 
                                                << 1U)));
    __Vdfg_Regularize_661 = ((0x00000080U & (IData)(__Vdfg_Regularize_660))
                              ? (1U | (0x000000feU 
                                       & (6U ^ (0x000000feU 
                                                & ((IData)(__Vdfg_Regularize_660) 
                                                   << 1U)))))
                              : (0x000000feU & ((IData)(__Vdfg_Regularize_660) 
                                                << 1U)));
    __Vdfg_Regularize_737 = ((0x00000080U & (IData)(__Vdfg_Regularize_736))
                              ? (1U | (0x000000feU 
                                       & (6U ^ (0x000000feU 
                                                & ((IData)(__Vdfg_Regularize_736) 
                                                   << 1U)))))
                              : (0x000000feU & ((IData)(__Vdfg_Regularize_736) 
                                                << 1U)));
    __Vdfg_Regularize_662 = ((0x00000080U & (IData)(__Vdfg_Regularize_661))
                              ? (1U | (0x000000feU 
                                       & (6U ^ (0x000000feU 
                                                & ((IData)(__Vdfg_Regularize_661) 
                                                   << 1U)))))
                              : (0x000000feU & ((IData)(__Vdfg_Regularize_661) 
                                                << 1U)));
    __Vdfg_Regularize_738 = ((0x00000080U & (IData)(__Vdfg_Regularize_737))
                              ? (1U | (0x000000feU 
                                       & (6U ^ (0x000000feU 
                                                & ((IData)(__Vdfg_Regularize_737) 
                                                   << 1U)))))
                              : (0x000000feU & ((IData)(__Vdfg_Regularize_737) 
                                                << 1U)));
    __Vdfg_Regularize_663 = ((0x00000080U & (IData)(__Vdfg_Regularize_662))
                              ? (1U | (0x000000feU 
                                       & (6U ^ (0x000000feU 
                                                & ((IData)(__Vdfg_Regularize_662) 
                                                   << 1U)))))
                              : (0x000000feU & ((IData)(__Vdfg_Regularize_662) 
                                                << 1U)));
    __Vdfg_Regularize_739 = ((0x00000080U & (IData)(__Vdfg_Regularize_738))
                              ? (1U | (0x000000feU 
                                       & (6U ^ (0x000000feU 
                                                & ((IData)(__Vdfg_Regularize_738) 
                                                   << 1U)))))
                              : (0x000000feU & ((IData)(__Vdfg_Regularize_738) 
                                                << 1U)));
    __Vdfg_Regularize_664 = ((0x00000080U & (IData)(__Vdfg_Regularize_663))
                              ? (1U | (0x000000feU 
                                       & (6U ^ (0x000000feU 
                                                & ((IData)(__Vdfg_Regularize_663) 
                                                   << 1U)))))
                              : (0x000000feU & ((IData)(__Vdfg_Regularize_663) 
                                                << 1U)));
    __Vdfg_Regularize_740 = ((0x00000080U & (IData)(__Vdfg_Regularize_739))
                              ? (1U | (0x000000feU 
                                       & (6U ^ (0x000000feU 
                                                & ((IData)(__Vdfg_Regularize_739) 
                                                   << 1U)))))
                              : (0x000000feU & ((IData)(__Vdfg_Regularize_739) 
                                                << 1U)));
    __Vdfg_Regularize_665 = ((0x00000080U & (IData)(__Vdfg_Regularize_664))
                              ? (1U | (0x000000feU 
                                       & (6U ^ (0x000000feU 
                                                & ((IData)(__Vdfg_Regularize_664) 
                                                   << 1U)))))
                              : (0x000000feU & ((IData)(__Vdfg_Regularize_664) 
                                                << 1U)));
    __Vdfg_Regularize_741 = ((0x00000080U & (IData)(__Vdfg_Regularize_740))
                              ? (1U | (0x000000feU 
                                       & (6U ^ (0x000000feU 
                                                & ((IData)(__Vdfg_Regularize_740) 
                                                   << 1U)))))
                              : (0x000000feU & ((IData)(__Vdfg_Regularize_740) 
                                                << 1U)));
    __Vdfg_Regularize_666 = ((0x00000080U & (IData)(__Vdfg_Regularize_665))
                              ? (1U | (0x000000feU 
                                       & (6U ^ (0x000000feU 
                                                & ((IData)(__Vdfg_Regularize_665) 
                                                   << 1U)))))
                              : (0x000000feU & ((IData)(__Vdfg_Regularize_665) 
                                                << 1U)));
    vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_2__DOT__u_crc_parallel__DOT__w_crc_nxt 
        = ((IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_2__DOT__u_crc_parallel__DOT__reg_last)
            ? ((0x00000080U & (IData)(__Vdfg_Regularize_741))
                ? (1U | (0x000000feU & (6U ^ (0x000000feU 
                                              & ((IData)(__Vdfg_Regularize_741) 
                                                 << 1U)))))
                : (0x000000feU & ((IData)(__Vdfg_Regularize_741) 
                                  << 1U))) : (IData)(__Vdfg_Regularize_599));
    vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_2__DOT__u_crc_parallel__DOT__w_crc_nxt 
        = ((IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_2__DOT__u_crc_parallel__DOT__reg_last)
            ? ((0x00000080U & (IData)(__Vdfg_Regularize_666))
                ? (1U | (0x000000feU & (6U ^ (0x000000feU 
                                              & ((IData)(__Vdfg_Regularize_666) 
                                                 << 1U)))))
                : (0x000000feU & ((IData)(__Vdfg_Regularize_666) 
                                  << 1U))) : (IData)(__Vdfg_Regularize_595));
}

void Vcrc___024root___trigger_orInto__act_vec_vec(VlUnpacked<QData/*63:0*/, 1> &out, const VlUnpacked<QData/*63:0*/, 1> &in) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vcrc___024root___trigger_orInto__act_vec_vec\n"); );
    // Locals
    IData/*31:0*/ n;
    // Body
    n = 0U;
    do {
        out[n] = (out[n] | in[n]);
        n = ((IData)(1U) + n);
    } while ((0U >= n));
}

void Vcrc___024root___trigger_clear__act(VlUnpacked<QData/*63:0*/, 1> &out) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vcrc___024root___trigger_clear__act\n"); );
    // Locals
    IData/*31:0*/ n;
    // Body
    n = 0U;
    do {
        out[n] = 0ULL;
        n = ((IData)(1U) + n);
    } while ((1U > n));
}

#ifdef VL_DEBUG
void Vcrc___024root___eval_debug_assertions(Vcrc___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vcrc___024root___eval_debug_assertions\n"); );
    Vcrc__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Body
    if (VL_UNLIKELY(((vlSelfRef.i_clk_crc & 0xfeU)))) {
        Verilated::overWidthError("i_clk_crc");
    }
    if (VL_UNLIKELY(((vlSelfRef.i_rst_n_crc & 0xfeU)))) {
        Verilated::overWidthError("i_rst_n_crc");
    }
    if (VL_UNLIKELY(((vlSelfRef.i_gen_keep & 0xf0U)))) {
        Verilated::overWidthError("i_gen_keep");
    }
    if (VL_UNLIKELY(((vlSelfRef.i_gen_valid & 0xfeU)))) {
        Verilated::overWidthError("i_gen_valid");
    }
    if (VL_UNLIKELY(((vlSelfRef.i_gen_last & 0xfeU)))) {
        Verilated::overWidthError("i_gen_last");
    }
    if (VL_UNLIKELY(((vlSelfRef.i_gen_crc_ready & 0xfeU)))) {
        Verilated::overWidthError("i_gen_crc_ready");
    }
    if (VL_UNLIKELY(((vlSelfRef.i_check_keep & 0xf0U)))) {
        Verilated::overWidthError("i_check_keep");
    }
    if (VL_UNLIKELY(((vlSelfRef.i_check_valid & 0xfeU)))) {
        Verilated::overWidthError("i_check_valid");
    }
    if (VL_UNLIKELY(((vlSelfRef.i_check_last & 0xfeU)))) {
        Verilated::overWidthError("i_check_last");
    }
    if (VL_UNLIKELY(((vlSelfRef.i_check_crc_ready & 0xfeU)))) {
        Verilated::overWidthError("i_check_crc_ready");
    }
}
#endif  // VL_DEBUG
