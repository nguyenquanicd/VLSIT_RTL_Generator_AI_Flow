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
                                                   ((IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_1__DOT__u_crc_initial_value__DOT__reg_busy) 
                                                    | (IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_1__DOT__u_crc_initial_value__DOT__reg_crc_valid))) 
                                                  & (IData)(vlSelfRef.i_rst_n_crc));
                    vlSelfRef.o_check_data_ready = 
                        ((~ ((IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_1__DOT__u_crc_initial_value__DOT__reg_busy) 
                             | (IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_1__DOT__u_crc_initial_value__DOT__reg_crc_valid))) 
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
    CData/*7:0*/ __Vfunc_m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_1__DOT__u_crc_initial_value__DOT__f_finalize__Vfuncout_8;
    __Vfunc_m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_1__DOT__u_crc_initial_value__DOT__f_finalize__Vfuncout_8 = 0;
    CData/*7:0*/ __Vfunc_m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_1__DOT__u_crc_initial_value__DOT__f_finalize__i_crc_9;
    __Vfunc_m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_1__DOT__u_crc_initial_value__DOT__f_finalize__i_crc_9 = 0;
    CData/*7:0*/ __Vfunc_m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_1__DOT__u_crc_initial_value__DOT__f_finalize__w_reflected_crc_11;
    __Vfunc_m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_1__DOT__u_crc_initial_value__DOT__f_finalize__w_reflected_crc_11 = 0;
    CData/*7:0*/ __Vfunc_m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_1__DOT__u_crc_initial_value__DOT__f_finalize__Vfuncout_20;
    __Vfunc_m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_1__DOT__u_crc_initial_value__DOT__f_finalize__Vfuncout_20 = 0;
    CData/*7:0*/ __Vfunc_m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_1__DOT__u_crc_initial_value__DOT__f_finalize__i_crc_21;
    __Vfunc_m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_1__DOT__u_crc_initial_value__DOT__f_finalize__i_crc_21 = 0;
    CData/*7:0*/ __Vfunc_m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_1__DOT__u_crc_initial_value__DOT__f_finalize__w_reflected_crc_23;
    __Vfunc_m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_1__DOT__u_crc_initial_value__DOT__f_finalize__w_reflected_crc_23 = 0;
    CData/*7:0*/ __Vdfg_Regularize_140;
    __Vdfg_Regularize_140 = 0;
    CData/*7:0*/ __Vdfg_Regularize_141;
    __Vdfg_Regularize_141 = 0;
    CData/*3:0*/ __Vdly__m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_1__DOT__u_crc_initial_value__DOT__reg_aug_count_4;
    __Vdly__m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_1__DOT__u_crc_initial_value__DOT__reg_aug_count_4 = 0;
    CData/*0:0*/ __Vdly__m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_1__DOT__u_crc_initial_value__DOT__reg_augment_5;
    __Vdly__m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_1__DOT__u_crc_initial_value__DOT__reg_augment_5 = 0;
    CData/*0:0*/ __Vdly__m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_1__DOT__u_crc_initial_value__DOT__reg_busy_6;
    __Vdly__m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_1__DOT__u_crc_initial_value__DOT__reg_busy_6 = 0;
    CData/*2:0*/ __Vdly__m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_1__DOT__u_crc_initial_value__DOT__reg_bit_idx_8;
    __Vdly__m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_1__DOT__u_crc_initial_value__DOT__reg_bit_idx_8 = 0;
    CData/*3:0*/ __Vdly__m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_1__DOT__u_crc_initial_value__DOT__reg_aug_count_15;
    __Vdly__m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_1__DOT__u_crc_initial_value__DOT__reg_aug_count_15 = 0;
    CData/*0:0*/ __Vdly__m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_1__DOT__u_crc_initial_value__DOT__reg_augment_16;
    __Vdly__m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_1__DOT__u_crc_initial_value__DOT__reg_augment_16 = 0;
    CData/*0:0*/ __Vdly__m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_1__DOT__u_crc_initial_value__DOT__reg_busy_17;
    __Vdly__m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_1__DOT__u_crc_initial_value__DOT__reg_busy_17 = 0;
    CData/*2:0*/ __Vdly__m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_1__DOT__u_crc_initial_value__DOT__reg_bit_idx_19;
    __Vdly__m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_1__DOT__u_crc_initial_value__DOT__reg_bit_idx_19 = 0;
    // Body
    __Vdly__m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_1__DOT__u_crc_initial_value__DOT__reg_bit_idx_19 
        = vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_1__DOT__u_crc_initial_value__DOT__reg_bit_idx;
    __Vdly__m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_1__DOT__u_crc_initial_value__DOT__reg_bit_idx_8 
        = vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_1__DOT__u_crc_initial_value__DOT__reg_bit_idx;
    __Vdly__m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_1__DOT__u_crc_initial_value__DOT__reg_aug_count_15 
        = vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_1__DOT__u_crc_initial_value__DOT__reg_aug_count;
    __Vdly__m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_1__DOT__u_crc_initial_value__DOT__reg_aug_count_4 
        = vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_1__DOT__u_crc_initial_value__DOT__reg_aug_count;
    __Vdly__m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_1__DOT__u_crc_initial_value__DOT__reg_augment_16 
        = vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_1__DOT__u_crc_initial_value__DOT__reg_augment;
    __Vdly__m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_1__DOT__u_crc_initial_value__DOT__reg_augment_5 
        = vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_1__DOT__u_crc_initial_value__DOT__reg_augment;
    __Vdly__m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_1__DOT__u_crc_initial_value__DOT__reg_busy_17 
        = vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_1__DOT__u_crc_initial_value__DOT__reg_busy;
    __Vdly__m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_1__DOT__u_crc_initial_value__DOT__reg_busy_6 
        = vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_1__DOT__u_crc_initial_value__DOT__reg_busy;
    if (vlSelfRef.i_rst_n_crc) {
        if (((IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_1__DOT__u_crc_initial_value__DOT__reg_crc_valid) 
             & (IData)(vlSelfRef.i_gen_crc_ready))) {
            vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_1__DOT__u_crc_initial_value__DOT__reg_crc_valid = 0U;
        }
        if (vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_1__DOT__u_crc_initial_value__DOT__reg_busy) {
            if ((1U & (~ (IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_1__DOT__u_crc_initial_value__DOT__reg_augment)))) {
                if ((2U != (2U & (((IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_1__DOT__u_crc_initial_value__DOT__w_payload_done) 
                                   << 1U) | (7U == (IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_1__DOT__u_crc_initial_value__DOT__reg_bit_idx)))))) {
                    if ((1U == (((IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_1__DOT__u_crc_initial_value__DOT__w_payload_done) 
                                 << 1U) | (7U == (IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_1__DOT__u_crc_initial_value__DOT__reg_bit_idx))))) {
                        __Vdly__m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_1__DOT__u_crc_initial_value__DOT__reg_bit_idx_19 = 0U;
                        vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_1__DOT__u_crc_initial_value__DOT__reg_byte_idx 
                            = (3U & ((IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_1__DOT__u_crc_initial_value__DOT__reg_byte_idx) 
                                     - (IData)(1U)));
                    } else {
                        __Vdly__m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_1__DOT__u_crc_initial_value__DOT__reg_bit_idx_19 
                            = (7U & ((IData)(1U) + (IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_1__DOT__u_crc_initial_value__DOT__reg_bit_idx)));
                    }
                }
            }
            vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_1__DOT__u_crc_initial_value__DOT__reg_crc_state 
                = vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_1__DOT__u_crc_initial_value__DOT__w_crc_step;
            if (vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_1__DOT__u_crc_initial_value__DOT__reg_augment) {
                if ((1U == (IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_1__DOT__u_crc_initial_value__DOT__reg_aug_count))) {
                    vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_1__DOT__u_crc_initial_value__DOT__reg_crc_valid = 1U;
                    __Vdly__m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_1__DOT__u_crc_initial_value__DOT__reg_aug_count_15 = 0U;
                    __Vdly__m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_1__DOT__u_crc_initial_value__DOT__reg_augment_16 = 0U;
                    __Vdly__m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_1__DOT__u_crc_initial_value__DOT__reg_busy_17 = 0U;
                    __Vfunc_m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_1__DOT__u_crc_initial_value__DOT__f_finalize__i_crc_21 
                        = vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_1__DOT__u_crc_initial_value__DOT__w_crc_step;
                    __Vfunc_m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_1__DOT__u_crc_initial_value__DOT__f_finalize__w_reflected_crc_23 = 0U;
                    __Vfunc_m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_1__DOT__u_crc_initial_value__DOT__f_finalize__w_reflected_crc_23 
                        = ((0xf8U & (IData)(__Vfunc_m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_1__DOT__u_crc_initial_value__DOT__f_finalize__w_reflected_crc_23)) 
                           | ((4U & ((IData)(__Vfunc_m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_1__DOT__u_crc_initial_value__DOT__f_finalize__i_crc_21) 
                                     >> 3U)) | ((2U 
                                                 & ((IData)(__Vfunc_m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_1__DOT__u_crc_initial_value__DOT__f_finalize__i_crc_21) 
                                                    >> 5U)) 
                                                | (1U 
                                                   & ((IData)(__Vfunc_m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_1__DOT__u_crc_initial_value__DOT__f_finalize__i_crc_21) 
                                                      >> 7U)))));
                    __Vfunc_m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_1__DOT__u_crc_initial_value__DOT__f_finalize__w_reflected_crc_23 
                        = ((0xc7U & (IData)(__Vfunc_m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_1__DOT__u_crc_initial_value__DOT__f_finalize__w_reflected_crc_23)) 
                           | (((4U & (IData)(__Vfunc_m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_1__DOT__u_crc_initial_value__DOT__f_finalize__i_crc_21)) 
                               | ((2U & ((IData)(__Vfunc_m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_1__DOT__u_crc_initial_value__DOT__f_finalize__i_crc_21) 
                                         >> 2U)) | 
                                  (1U & ((IData)(__Vfunc_m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_1__DOT__u_crc_initial_value__DOT__f_finalize__i_crc_21) 
                                         >> 4U)))) 
                              << 3U));
                    __Vfunc_m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_1__DOT__u_crc_initial_value__DOT__f_finalize__w_reflected_crc_23 
                        = ((0x3fU & (IData)(__Vfunc_m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_1__DOT__u_crc_initial_value__DOT__f_finalize__w_reflected_crc_23)) 
                           | (((2U & ((IData)(__Vfunc_m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_1__DOT__u_crc_initial_value__DOT__f_finalize__i_crc_21) 
                                      << 1U)) | (1U 
                                                 & ((IData)(__Vfunc_m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_1__DOT__u_crc_initial_value__DOT__f_finalize__i_crc_21) 
                                                    >> 1U))) 
                              << 6U));
                    __Vfunc_m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_1__DOT__u_crc_initial_value__DOT__f_finalize__Vfuncout_20 
                        = (0xa5U ^ (IData)(__Vfunc_m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_1__DOT__u_crc_initial_value__DOT__f_finalize__w_reflected_crc_23));
                    vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_1__DOT__u_crc_initial_value__DOT__reg_crc_output 
                        = __Vfunc_m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_1__DOT__u_crc_initial_value__DOT__f_finalize__Vfuncout_20;
                    vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_1__DOT__u_crc_initial_value__DOT__reg_crc_state = 0x5aU;
                } else {
                    __Vdly__m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_1__DOT__u_crc_initial_value__DOT__reg_aug_count_15 
                        = (0x0000000fU & ((IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_1__DOT__u_crc_initial_value__DOT__reg_aug_count) 
                                          - (IData)(1U)));
                }
            } else if ((2U == (2U & (((IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_1__DOT__u_crc_initial_value__DOT__w_payload_done) 
                                      << 1U) | (7U 
                                                == (IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_1__DOT__u_crc_initial_value__DOT__reg_bit_idx)))))) {
                if (vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_1__DOT__u_crc_initial_value__DOT__reg_last) {
                    __Vdly__m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_1__DOT__u_crc_initial_value__DOT__reg_aug_count_15 = 8U;
                    __Vdly__m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_1__DOT__u_crc_initial_value__DOT__reg_augment_16 = 1U;
                }
                if ((1U & (~ (IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_1__DOT__u_crc_initial_value__DOT__reg_last)))) {
                    __Vdly__m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_1__DOT__u_crc_initial_value__DOT__reg_busy_17 = 0U;
                }
            }
        } else if (((IData)(vlSelfRef.i_gen_valid) 
                    & (IData)(vlSelfRef.o_gen_data_ready))) {
            __Vdly__m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_1__DOT__u_crc_initial_value__DOT__reg_bit_idx_19 = 0U;
            vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_1__DOT__u_crc_initial_value__DOT__reg_byte_idx = 3U;
            __Vdly__m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_1__DOT__u_crc_initial_value__DOT__reg_busy_17 = 1U;
        }
        if (((IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_1__DOT__u_crc_initial_value__DOT__reg_crc_valid) 
             & (IData)(vlSelfRef.i_check_crc_ready))) {
            vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_1__DOT__u_crc_initial_value__DOT__reg_crc_valid = 0U;
        }
        if (vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_1__DOT__u_crc_initial_value__DOT__reg_busy) {
            if ((1U & (~ (IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_1__DOT__u_crc_initial_value__DOT__reg_augment)))) {
                if ((2U != (2U & (((IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_1__DOT__u_crc_initial_value__DOT__w_payload_done) 
                                   << 1U) | (7U == (IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_1__DOT__u_crc_initial_value__DOT__reg_bit_idx)))))) {
                    if ((1U == (((IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_1__DOT__u_crc_initial_value__DOT__w_payload_done) 
                                 << 1U) | (7U == (IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_1__DOT__u_crc_initial_value__DOT__reg_bit_idx))))) {
                        __Vdly__m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_1__DOT__u_crc_initial_value__DOT__reg_bit_idx_8 = 0U;
                        vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_1__DOT__u_crc_initial_value__DOT__reg_byte_idx 
                            = (3U & ((IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_1__DOT__u_crc_initial_value__DOT__reg_byte_idx) 
                                     - (IData)(1U)));
                    } else {
                        __Vdly__m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_1__DOT__u_crc_initial_value__DOT__reg_bit_idx_8 
                            = (7U & ((IData)(1U) + (IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_1__DOT__u_crc_initial_value__DOT__reg_bit_idx)));
                    }
                }
            }
            vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_1__DOT__u_crc_initial_value__DOT__reg_crc_state 
                = vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_1__DOT__u_crc_initial_value__DOT__w_crc_step;
            if (vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_1__DOT__u_crc_initial_value__DOT__reg_augment) {
                if ((1U == (IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_1__DOT__u_crc_initial_value__DOT__reg_aug_count))) {
                    vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_1__DOT__u_crc_initial_value__DOT__reg_crc_valid = 1U;
                    __Vdly__m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_1__DOT__u_crc_initial_value__DOT__reg_aug_count_4 = 0U;
                    __Vdly__m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_1__DOT__u_crc_initial_value__DOT__reg_augment_5 = 0U;
                    __Vdly__m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_1__DOT__u_crc_initial_value__DOT__reg_busy_6 = 0U;
                    __Vfunc_m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_1__DOT__u_crc_initial_value__DOT__f_finalize__i_crc_9 
                        = vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_1__DOT__u_crc_initial_value__DOT__w_crc_step;
                    __Vfunc_m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_1__DOT__u_crc_initial_value__DOT__f_finalize__w_reflected_crc_11 = 0U;
                    __Vfunc_m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_1__DOT__u_crc_initial_value__DOT__f_finalize__w_reflected_crc_11 
                        = ((0xf8U & (IData)(__Vfunc_m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_1__DOT__u_crc_initial_value__DOT__f_finalize__w_reflected_crc_11)) 
                           | ((4U & ((IData)(__Vfunc_m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_1__DOT__u_crc_initial_value__DOT__f_finalize__i_crc_9) 
                                     >> 3U)) | ((2U 
                                                 & ((IData)(__Vfunc_m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_1__DOT__u_crc_initial_value__DOT__f_finalize__i_crc_9) 
                                                    >> 5U)) 
                                                | (1U 
                                                   & ((IData)(__Vfunc_m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_1__DOT__u_crc_initial_value__DOT__f_finalize__i_crc_9) 
                                                      >> 7U)))));
                    __Vfunc_m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_1__DOT__u_crc_initial_value__DOT__f_finalize__w_reflected_crc_11 
                        = ((0xc7U & (IData)(__Vfunc_m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_1__DOT__u_crc_initial_value__DOT__f_finalize__w_reflected_crc_11)) 
                           | (((4U & (IData)(__Vfunc_m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_1__DOT__u_crc_initial_value__DOT__f_finalize__i_crc_9)) 
                               | ((2U & ((IData)(__Vfunc_m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_1__DOT__u_crc_initial_value__DOT__f_finalize__i_crc_9) 
                                         >> 2U)) | 
                                  (1U & ((IData)(__Vfunc_m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_1__DOT__u_crc_initial_value__DOT__f_finalize__i_crc_9) 
                                         >> 4U)))) 
                              << 3U));
                    __Vfunc_m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_1__DOT__u_crc_initial_value__DOT__f_finalize__w_reflected_crc_11 
                        = ((0x3fU & (IData)(__Vfunc_m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_1__DOT__u_crc_initial_value__DOT__f_finalize__w_reflected_crc_11)) 
                           | (((2U & ((IData)(__Vfunc_m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_1__DOT__u_crc_initial_value__DOT__f_finalize__i_crc_9) 
                                      << 1U)) | (1U 
                                                 & ((IData)(__Vfunc_m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_1__DOT__u_crc_initial_value__DOT__f_finalize__i_crc_9) 
                                                    >> 1U))) 
                              << 6U));
                    __Vfunc_m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_1__DOT__u_crc_initial_value__DOT__f_finalize__Vfuncout_8 
                        = (0xa5U ^ (IData)(__Vfunc_m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_1__DOT__u_crc_initial_value__DOT__f_finalize__w_reflected_crc_11));
                    vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_1__DOT__u_crc_initial_value__DOT__reg_crc_output 
                        = __Vfunc_m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_1__DOT__u_crc_initial_value__DOT__f_finalize__Vfuncout_8;
                    vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_1__DOT__u_crc_initial_value__DOT__reg_crc_state = 0x5aU;
                } else {
                    __Vdly__m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_1__DOT__u_crc_initial_value__DOT__reg_aug_count_4 
                        = (0x0000000fU & ((IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_1__DOT__u_crc_initial_value__DOT__reg_aug_count) 
                                          - (IData)(1U)));
                }
            } else if ((2U == (2U & (((IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_1__DOT__u_crc_initial_value__DOT__w_payload_done) 
                                      << 1U) | (7U 
                                                == (IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_1__DOT__u_crc_initial_value__DOT__reg_bit_idx)))))) {
                if (vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_1__DOT__u_crc_initial_value__DOT__reg_last) {
                    __Vdly__m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_1__DOT__u_crc_initial_value__DOT__reg_aug_count_4 = 8U;
                    __Vdly__m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_1__DOT__u_crc_initial_value__DOT__reg_augment_5 = 1U;
                }
                if ((1U & (~ (IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_1__DOT__u_crc_initial_value__DOT__reg_last)))) {
                    __Vdly__m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_1__DOT__u_crc_initial_value__DOT__reg_busy_6 = 0U;
                }
            }
        } else if (((IData)(vlSelfRef.i_check_valid) 
                    & (IData)(vlSelfRef.o_check_data_ready))) {
            __Vdly__m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_1__DOT__u_crc_initial_value__DOT__reg_bit_idx_8 = 0U;
            vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_1__DOT__u_crc_initial_value__DOT__reg_byte_idx = 3U;
            __Vdly__m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_1__DOT__u_crc_initial_value__DOT__reg_busy_6 = 1U;
        }
        if ((((IData)(vlSelfRef.i_check_valid) & (IData)(vlSelfRef.o_check_data_ready)) 
             & (IData)(vlSelfRef.i_check_last))) {
            vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__reg_check_crc_ref 
                = vlSelfRef.i_check_crc;
        }
        if ((1U & (~ (IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_1__DOT__u_crc_initial_value__DOT__reg_busy)))) {
            if (((IData)(vlSelfRef.i_gen_valid) & (IData)(vlSelfRef.o_gen_data_ready))) {
                vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_1__DOT__u_crc_initial_value__DOT__reg_keep 
                    = vlSelfRef.i_gen_keep;
                vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_1__DOT__u_crc_initial_value__DOT__reg_data 
                    = vlSelfRef.i_gen_data;
                vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_1__DOT__u_crc_initial_value__DOT__reg_last 
                    = vlSelfRef.i_gen_last;
            }
        }
        if ((1U & (~ (IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_1__DOT__u_crc_initial_value__DOT__reg_busy)))) {
            if (((IData)(vlSelfRef.i_check_valid) & (IData)(vlSelfRef.o_check_data_ready))) {
                vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_1__DOT__u_crc_initial_value__DOT__reg_keep 
                    = vlSelfRef.i_check_keep;
                vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_1__DOT__u_crc_initial_value__DOT__reg_data 
                    = vlSelfRef.i_check_data;
                vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_1__DOT__u_crc_initial_value__DOT__reg_last 
                    = vlSelfRef.i_check_last;
            }
        }
    } else {
        vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_1__DOT__u_crc_initial_value__DOT__reg_crc_valid = 0U;
        vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_1__DOT__u_crc_initial_value__DOT__reg_crc_valid = 0U;
        __Vdly__m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_1__DOT__u_crc_initial_value__DOT__reg_bit_idx_19 = 0U;
        __Vdly__m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_1__DOT__u_crc_initial_value__DOT__reg_bit_idx_8 = 0U;
        vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_1__DOT__u_crc_initial_value__DOT__reg_byte_idx = 0U;
        vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_1__DOT__u_crc_initial_value__DOT__reg_byte_idx = 0U;
        __Vdly__m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_1__DOT__u_crc_initial_value__DOT__reg_aug_count_15 = 0U;
        __Vdly__m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_1__DOT__u_crc_initial_value__DOT__reg_aug_count_4 = 0U;
        __Vdly__m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_1__DOT__u_crc_initial_value__DOT__reg_augment_16 = 0U;
        __Vdly__m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_1__DOT__u_crc_initial_value__DOT__reg_augment_5 = 0U;
        __Vdly__m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_1__DOT__u_crc_initial_value__DOT__reg_busy_17 = 0U;
        __Vdly__m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_1__DOT__u_crc_initial_value__DOT__reg_busy_6 = 0U;
        vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__reg_check_crc_ref = 0U;
        vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_1__DOT__u_crc_initial_value__DOT__reg_keep = 0U;
        vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_1__DOT__u_crc_initial_value__DOT__reg_keep = 0U;
        vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_1__DOT__u_crc_initial_value__DOT__reg_data = 0U;
        vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_1__DOT__u_crc_initial_value__DOT__reg_data = 0U;
        vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_1__DOT__u_crc_initial_value__DOT__reg_crc_output = 0U;
        vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_1__DOT__u_crc_initial_value__DOT__reg_crc_output = 0U;
        vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_1__DOT__u_crc_initial_value__DOT__reg_crc_state = 0x5aU;
        vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_1__DOT__u_crc_initial_value__DOT__reg_crc_state = 0x5aU;
        vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_1__DOT__u_crc_initial_value__DOT__reg_last = 0U;
        vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_1__DOT__u_crc_initial_value__DOT__reg_last = 0U;
    }
    vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_1__DOT__u_crc_initial_value__DOT__reg_bit_idx 
        = __Vdly__m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_1__DOT__u_crc_initial_value__DOT__reg_bit_idx_19;
    vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_1__DOT__u_crc_initial_value__DOT__reg_bit_idx 
        = __Vdly__m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_1__DOT__u_crc_initial_value__DOT__reg_bit_idx_8;
    vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_1__DOT__u_crc_initial_value__DOT__reg_aug_count 
        = __Vdly__m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_1__DOT__u_crc_initial_value__DOT__reg_aug_count_4;
    vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_1__DOT__u_crc_initial_value__DOT__reg_augment 
        = __Vdly__m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_1__DOT__u_crc_initial_value__DOT__reg_augment_5;
    vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_1__DOT__u_crc_initial_value__DOT__reg_aug_count 
        = __Vdly__m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_1__DOT__u_crc_initial_value__DOT__reg_aug_count_15;
    vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_1__DOT__u_crc_initial_value__DOT__reg_augment 
        = __Vdly__m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_1__DOT__u_crc_initial_value__DOT__reg_augment_16;
    vlSelfRef.o_gen_crc_valid = vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_1__DOT__u_crc_initial_value__DOT__reg_crc_valid;
    vlSelfRef.o_check_crc_valid = vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_1__DOT__u_crc_initial_value__DOT__reg_crc_valid;
    vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_1__DOT__u_crc_initial_value__DOT__w_payload_done 
        = ((7U == (IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_1__DOT__u_crc_initial_value__DOT__reg_bit_idx)) 
           & ((~ ((IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_1__DOT__u_crc_initial_value__DOT__reg_keep) 
                  >> (3U & ((IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_1__DOT__u_crc_initial_value__DOT__reg_byte_idx) 
                            - (IData)(1U))))) | (0U 
                                                 == (IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_1__DOT__u_crc_initial_value__DOT__reg_byte_idx))));
    vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_1__DOT__u_crc_initial_value__DOT__w_payload_done 
        = ((7U == (IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_1__DOT__u_crc_initial_value__DOT__reg_bit_idx)) 
           & ((~ ((IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_1__DOT__u_crc_initial_value__DOT__reg_keep) 
                  >> (3U & ((IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_1__DOT__u_crc_initial_value__DOT__reg_byte_idx) 
                            - (IData)(1U))))) | (0U 
                                                 == (IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_1__DOT__u_crc_initial_value__DOT__reg_byte_idx))));
    vlSelfRef.o_gen_crc = vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_1__DOT__u_crc_initial_value__DOT__reg_crc_output;
    vlSelfRef.o_check_pass = ((IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_1__DOT__u_crc_initial_value__DOT__reg_crc_valid) 
                              & ((IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__reg_check_crc_ref) 
                                 == (IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_1__DOT__u_crc_initial_value__DOT__reg_crc_output)));
    __Vdfg_Regularize_140 = ((0x000000feU & ((IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_1__DOT__u_crc_initial_value__DOT__reg_crc_state) 
                                             << 1U)) 
                             | (1U & (vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_1__DOT__u_crc_initial_value__DOT__reg_data 
                                      >> (0x0000001fU 
                                          & ((IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_1__DOT__u_crc_initial_value__DOT__reg_bit_idx) 
                                             + ((IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_1__DOT__u_crc_initial_value__DOT__reg_byte_idx) 
                                                << 3U))))));
    __Vdfg_Regularize_141 = ((0x000000feU & ((IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_1__DOT__u_crc_initial_value__DOT__reg_crc_state) 
                                             << 1U)) 
                             | (1U & (vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_1__DOT__u_crc_initial_value__DOT__reg_data 
                                      >> (0x0000001fU 
                                          & ((IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_1__DOT__u_crc_initial_value__DOT__reg_bit_idx) 
                                             + ((IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_1__DOT__u_crc_initial_value__DOT__reg_byte_idx) 
                                                << 3U))))));
    vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_1__DOT__u_crc_initial_value__DOT__reg_busy 
        = __Vdly__m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_1__DOT__u_crc_initial_value__DOT__reg_busy_17;
    vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_1__DOT__u_crc_initial_value__DOT__reg_busy 
        = __Vdly__m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_1__DOT__u_crc_initial_value__DOT__reg_busy_6;
    vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_1__DOT__u_crc_initial_value__DOT__w_crc_step 
        = ((IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_1__DOT__u_crc_initial_value__DOT__reg_augment)
            ? ((0x00000080U & (IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_1__DOT__u_crc_initial_value__DOT__reg_crc_state))
                ? (1U | (0x000000feU & (6U ^ (0x000000feU 
                                              & ((IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_1__DOT__u_crc_initial_value__DOT__reg_crc_state) 
                                                 << 1U)))))
                : (0x000000feU & ((IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_1__DOT__u_crc_initial_value__DOT__reg_crc_state) 
                                  << 1U))) : ((0x00000080U 
                                               & (IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_1__DOT__u_crc_initial_value__DOT__reg_crc_state))
                                               ? (7U 
                                                  ^ (IData)(__Vdfg_Regularize_140))
                                               : (IData)(__Vdfg_Regularize_140)));
    vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_1__DOT__u_crc_initial_value__DOT__w_crc_step 
        = ((IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_1__DOT__u_crc_initial_value__DOT__reg_augment)
            ? ((0x00000080U & (IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_1__DOT__u_crc_initial_value__DOT__reg_crc_state))
                ? (1U | (0x000000feU & (6U ^ (0x000000feU 
                                              & ((IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_1__DOT__u_crc_initial_value__DOT__reg_crc_state) 
                                                 << 1U)))))
                : (0x000000feU & ((IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_1__DOT__u_crc_initial_value__DOT__reg_crc_state) 
                                  << 1U))) : ((0x00000080U 
                                               & (IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_1__DOT__u_crc_initial_value__DOT__reg_crc_state))
                                               ? (7U 
                                                  ^ (IData)(__Vdfg_Regularize_141))
                                               : (IData)(__Vdfg_Regularize_141)));
    vlSelfRef.o_gen_data_ready = ((~ ((IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_1__DOT__u_crc_initial_value__DOT__reg_busy) 
                                      | (IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_1__DOT__u_crc_initial_value__DOT__reg_crc_valid))) 
                                  & (IData)(vlSelfRef.i_rst_n_crc));
    vlSelfRef.o_check_data_ready = ((~ ((IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_1__DOT__u_crc_initial_value__DOT__reg_busy) 
                                        | (IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_1__DOT__u_crc_initial_value__DOT__reg_crc_valid))) 
                                    & (IData)(vlSelfRef.i_rst_n_crc));
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
