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
                                                   ((IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_4__DOT__u_crc_parallel_full__DOT__reg_busy) 
                                                    | (IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_4__DOT__u_crc_parallel_full__DOT__reg_crc_valid))) 
                                                  & (IData)(vlSelfRef.i_rst_n_crc));
                    vlSelfRef.o_check_data_ready = 
                        ((~ ((IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_4__DOT__u_crc_parallel_full__DOT__reg_busy) 
                             | (IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_4__DOT__u_crc_parallel_full__DOT__reg_crc_valid))) 
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
                                                      | (((((vlSelfRef.i_check_crc 
                                                             != vlSelfRef.__Vtrigprevexpr___TOP__i_check_crc__0) 
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
    IData/*31:0*/ __Vfunc_m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_4__DOT__u_crc_parallel_full__DOT__f_finalize__Vfuncout_22;
    __Vfunc_m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_4__DOT__u_crc_parallel_full__DOT__f_finalize__Vfuncout_22 = 0;
    IData/*31:0*/ __Vfunc_m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_4__DOT__u_crc_parallel_full__DOT__f_finalize__i_crc_23;
    __Vfunc_m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_4__DOT__u_crc_parallel_full__DOT__f_finalize__i_crc_23 = 0;
    IData/*31:0*/ __Vfunc_m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_4__DOT__u_crc_parallel_full__DOT__f_finalize__w_reflected_crc_25;
    __Vfunc_m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_4__DOT__u_crc_parallel_full__DOT__f_finalize__w_reflected_crc_25 = 0;
    IData/*31:0*/ __Vfunc_m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_4__DOT__u_crc_parallel_full__DOT__f_finalize__Vfuncout_48;
    __Vfunc_m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_4__DOT__u_crc_parallel_full__DOT__f_finalize__Vfuncout_48 = 0;
    IData/*31:0*/ __Vfunc_m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_4__DOT__u_crc_parallel_full__DOT__f_finalize__i_crc_49;
    __Vfunc_m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_4__DOT__u_crc_parallel_full__DOT__f_finalize__i_crc_49 = 0;
    IData/*31:0*/ __Vfunc_m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_4__DOT__u_crc_parallel_full__DOT__f_finalize__w_reflected_crc_51;
    __Vfunc_m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_4__DOT__u_crc_parallel_full__DOT__f_finalize__w_reflected_crc_51 = 0;
    IData/*31:0*/ __Vdfg_Regularize_864;
    __Vdfg_Regularize_864 = 0;
    IData/*31:0*/ __Vdfg_Regularize_865;
    __Vdfg_Regularize_865 = 0;
    IData/*31:0*/ __Vdfg_Regularize_866;
    __Vdfg_Regularize_866 = 0;
    IData/*31:0*/ __Vdfg_Regularize_867;
    __Vdfg_Regularize_867 = 0;
    IData/*31:0*/ __Vdfg_Regularize_868;
    __Vdfg_Regularize_868 = 0;
    IData/*31:0*/ __Vdfg_Regularize_869;
    __Vdfg_Regularize_869 = 0;
    IData/*31:0*/ __Vdfg_Regularize_870;
    __Vdfg_Regularize_870 = 0;
    IData/*31:0*/ __Vdfg_Regularize_871;
    __Vdfg_Regularize_871 = 0;
    IData/*31:0*/ __Vdfg_Regularize_872;
    __Vdfg_Regularize_872 = 0;
    IData/*31:0*/ __Vdfg_Regularize_873;
    __Vdfg_Regularize_873 = 0;
    IData/*31:0*/ __Vdfg_Regularize_874;
    __Vdfg_Regularize_874 = 0;
    IData/*31:0*/ __Vdfg_Regularize_875;
    __Vdfg_Regularize_875 = 0;
    IData/*31:0*/ __Vdfg_Regularize_876;
    __Vdfg_Regularize_876 = 0;
    IData/*31:0*/ __Vdfg_Regularize_877;
    __Vdfg_Regularize_877 = 0;
    IData/*31:0*/ __Vdfg_Regularize_878;
    __Vdfg_Regularize_878 = 0;
    IData/*31:0*/ __Vdfg_Regularize_879;
    __Vdfg_Regularize_879 = 0;
    IData/*31:0*/ __Vdfg_Regularize_880;
    __Vdfg_Regularize_880 = 0;
    IData/*31:0*/ __Vdfg_Regularize_881;
    __Vdfg_Regularize_881 = 0;
    IData/*31:0*/ __Vdfg_Regularize_882;
    __Vdfg_Regularize_882 = 0;
    IData/*31:0*/ __Vdfg_Regularize_883;
    __Vdfg_Regularize_883 = 0;
    IData/*31:0*/ __Vdfg_Regularize_884;
    __Vdfg_Regularize_884 = 0;
    IData/*31:0*/ __Vdfg_Regularize_885;
    __Vdfg_Regularize_885 = 0;
    IData/*31:0*/ __Vdfg_Regularize_886;
    __Vdfg_Regularize_886 = 0;
    IData/*31:0*/ __Vdfg_Regularize_887;
    __Vdfg_Regularize_887 = 0;
    IData/*31:0*/ __Vdfg_Regularize_888;
    __Vdfg_Regularize_888 = 0;
    IData/*31:0*/ __Vdfg_Regularize_889;
    __Vdfg_Regularize_889 = 0;
    IData/*31:0*/ __Vdfg_Regularize_890;
    __Vdfg_Regularize_890 = 0;
    IData/*31:0*/ __Vdfg_Regularize_891;
    __Vdfg_Regularize_891 = 0;
    IData/*31:0*/ __Vdfg_Regularize_892;
    __Vdfg_Regularize_892 = 0;
    IData/*31:0*/ __Vdfg_Regularize_893;
    __Vdfg_Regularize_893 = 0;
    IData/*31:0*/ __Vdfg_Regularize_894;
    __Vdfg_Regularize_894 = 0;
    IData/*31:0*/ __Vdfg_Regularize_895;
    __Vdfg_Regularize_895 = 0;
    IData/*31:0*/ __Vdfg_Regularize_896;
    __Vdfg_Regularize_896 = 0;
    IData/*31:0*/ __Vdfg_Regularize_897;
    __Vdfg_Regularize_897 = 0;
    IData/*31:0*/ __Vdfg_Regularize_898;
    __Vdfg_Regularize_898 = 0;
    IData/*31:0*/ __Vdfg_Regularize_899;
    __Vdfg_Regularize_899 = 0;
    IData/*31:0*/ __Vdfg_Regularize_900;
    __Vdfg_Regularize_900 = 0;
    IData/*31:0*/ __Vdfg_Regularize_901;
    __Vdfg_Regularize_901 = 0;
    IData/*31:0*/ __Vdfg_Regularize_902;
    __Vdfg_Regularize_902 = 0;
    IData/*31:0*/ __Vdfg_Regularize_903;
    __Vdfg_Regularize_903 = 0;
    IData/*31:0*/ __Vdfg_Regularize_904;
    __Vdfg_Regularize_904 = 0;
    IData/*31:0*/ __Vdfg_Regularize_905;
    __Vdfg_Regularize_905 = 0;
    IData/*31:0*/ __Vdfg_Regularize_906;
    __Vdfg_Regularize_906 = 0;
    IData/*31:0*/ __Vdfg_Regularize_907;
    __Vdfg_Regularize_907 = 0;
    IData/*31:0*/ __Vdfg_Regularize_908;
    __Vdfg_Regularize_908 = 0;
    IData/*31:0*/ __Vdfg_Regularize_909;
    __Vdfg_Regularize_909 = 0;
    IData/*31:0*/ __Vdfg_Regularize_910;
    __Vdfg_Regularize_910 = 0;
    IData/*31:0*/ __Vdfg_Regularize_911;
    __Vdfg_Regularize_911 = 0;
    IData/*31:0*/ __Vdfg_Regularize_912;
    __Vdfg_Regularize_912 = 0;
    IData/*31:0*/ __Vdfg_Regularize_913;
    __Vdfg_Regularize_913 = 0;
    IData/*31:0*/ __Vdfg_Regularize_914;
    __Vdfg_Regularize_914 = 0;
    IData/*31:0*/ __Vdfg_Regularize_915;
    __Vdfg_Regularize_915 = 0;
    IData/*31:0*/ __Vdfg_Regularize_916;
    __Vdfg_Regularize_916 = 0;
    IData/*31:0*/ __Vdfg_Regularize_917;
    __Vdfg_Regularize_917 = 0;
    IData/*31:0*/ __Vdfg_Regularize_918;
    __Vdfg_Regularize_918 = 0;
    IData/*31:0*/ __Vdfg_Regularize_919;
    __Vdfg_Regularize_919 = 0;
    IData/*31:0*/ __Vdfg_Regularize_920;
    __Vdfg_Regularize_920 = 0;
    IData/*31:0*/ __Vdfg_Regularize_921;
    __Vdfg_Regularize_921 = 0;
    IData/*31:0*/ __Vdfg_Regularize_922;
    __Vdfg_Regularize_922 = 0;
    IData/*31:0*/ __Vdfg_Regularize_923;
    __Vdfg_Regularize_923 = 0;
    IData/*31:0*/ __Vdfg_Regularize_924;
    __Vdfg_Regularize_924 = 0;
    IData/*31:0*/ __Vdfg_Regularize_925;
    __Vdfg_Regularize_925 = 0;
    IData/*31:0*/ __Vdfg_Regularize_926;
    __Vdfg_Regularize_926 = 0;
    IData/*31:0*/ __Vdfg_Regularize_927;
    __Vdfg_Regularize_927 = 0;
    IData/*31:0*/ __Vdfg_Regularize_928;
    __Vdfg_Regularize_928 = 0;
    IData/*31:0*/ __Vdfg_Regularize_929;
    __Vdfg_Regularize_929 = 0;
    IData/*31:0*/ __Vdfg_Regularize_930;
    __Vdfg_Regularize_930 = 0;
    IData/*31:0*/ __Vdfg_Regularize_931;
    __Vdfg_Regularize_931 = 0;
    IData/*31:0*/ __Vdfg_Regularize_932;
    __Vdfg_Regularize_932 = 0;
    IData/*31:0*/ __Vdfg_Regularize_933;
    __Vdfg_Regularize_933 = 0;
    IData/*31:0*/ __Vdfg_Regularize_934;
    __Vdfg_Regularize_934 = 0;
    IData/*31:0*/ __Vdfg_Regularize_935;
    __Vdfg_Regularize_935 = 0;
    IData/*31:0*/ __Vdfg_Regularize_936;
    __Vdfg_Regularize_936 = 0;
    IData/*31:0*/ __Vdfg_Regularize_937;
    __Vdfg_Regularize_937 = 0;
    IData/*31:0*/ __Vdfg_Regularize_938;
    __Vdfg_Regularize_938 = 0;
    IData/*31:0*/ __Vdfg_Regularize_939;
    __Vdfg_Regularize_939 = 0;
    IData/*31:0*/ __Vdfg_Regularize_940;
    __Vdfg_Regularize_940 = 0;
    IData/*31:0*/ __Vdfg_Regularize_941;
    __Vdfg_Regularize_941 = 0;
    IData/*31:0*/ __Vdfg_Regularize_942;
    __Vdfg_Regularize_942 = 0;
    IData/*31:0*/ __Vdfg_Regularize_943;
    __Vdfg_Regularize_943 = 0;
    IData/*31:0*/ __Vdfg_Regularize_944;
    __Vdfg_Regularize_944 = 0;
    IData/*31:0*/ __Vdfg_Regularize_945;
    __Vdfg_Regularize_945 = 0;
    IData/*31:0*/ __Vdfg_Regularize_946;
    __Vdfg_Regularize_946 = 0;
    IData/*31:0*/ __Vdfg_Regularize_947;
    __Vdfg_Regularize_947 = 0;
    IData/*31:0*/ __Vdfg_Regularize_948;
    __Vdfg_Regularize_948 = 0;
    IData/*31:0*/ __Vdfg_Regularize_949;
    __Vdfg_Regularize_949 = 0;
    IData/*31:0*/ __Vdfg_Regularize_950;
    __Vdfg_Regularize_950 = 0;
    IData/*31:0*/ __Vdfg_Regularize_951;
    __Vdfg_Regularize_951 = 0;
    IData/*31:0*/ __Vdfg_Regularize_952;
    __Vdfg_Regularize_952 = 0;
    IData/*31:0*/ __Vdfg_Regularize_953;
    __Vdfg_Regularize_953 = 0;
    IData/*31:0*/ __Vdfg_Regularize_954;
    __Vdfg_Regularize_954 = 0;
    IData/*31:0*/ __Vdfg_Regularize_955;
    __Vdfg_Regularize_955 = 0;
    IData/*31:0*/ __Vdfg_Regularize_956;
    __Vdfg_Regularize_956 = 0;
    IData/*31:0*/ __Vdfg_Regularize_957;
    __Vdfg_Regularize_957 = 0;
    IData/*31:0*/ __Vdfg_Regularize_958;
    __Vdfg_Regularize_958 = 0;
    IData/*31:0*/ __Vdfg_Regularize_959;
    __Vdfg_Regularize_959 = 0;
    IData/*31:0*/ __Vdfg_Regularize_960;
    __Vdfg_Regularize_960 = 0;
    IData/*31:0*/ __Vdfg_Regularize_961;
    __Vdfg_Regularize_961 = 0;
    IData/*31:0*/ __Vdfg_Regularize_962;
    __Vdfg_Regularize_962 = 0;
    IData/*31:0*/ __Vdfg_Regularize_995;
    __Vdfg_Regularize_995 = 0;
    IData/*31:0*/ __Vdfg_Regularize_996;
    __Vdfg_Regularize_996 = 0;
    IData/*31:0*/ __Vdfg_Regularize_997;
    __Vdfg_Regularize_997 = 0;
    IData/*31:0*/ __Vdfg_Regularize_998;
    __Vdfg_Regularize_998 = 0;
    IData/*31:0*/ __Vdfg_Regularize_999;
    __Vdfg_Regularize_999 = 0;
    IData/*31:0*/ __Vdfg_Regularize_1000;
    __Vdfg_Regularize_1000 = 0;
    IData/*31:0*/ __Vdfg_Regularize_1001;
    __Vdfg_Regularize_1001 = 0;
    IData/*31:0*/ __Vdfg_Regularize_1002;
    __Vdfg_Regularize_1002 = 0;
    IData/*31:0*/ __Vdfg_Regularize_1003;
    __Vdfg_Regularize_1003 = 0;
    IData/*31:0*/ __Vdfg_Regularize_1004;
    __Vdfg_Regularize_1004 = 0;
    IData/*31:0*/ __Vdfg_Regularize_1005;
    __Vdfg_Regularize_1005 = 0;
    IData/*31:0*/ __Vdfg_Regularize_1006;
    __Vdfg_Regularize_1006 = 0;
    IData/*31:0*/ __Vdfg_Regularize_1007;
    __Vdfg_Regularize_1007 = 0;
    IData/*31:0*/ __Vdfg_Regularize_1008;
    __Vdfg_Regularize_1008 = 0;
    IData/*31:0*/ __Vdfg_Regularize_1009;
    __Vdfg_Regularize_1009 = 0;
    IData/*31:0*/ __Vdfg_Regularize_1010;
    __Vdfg_Regularize_1010 = 0;
    IData/*31:0*/ __Vdfg_Regularize_1011;
    __Vdfg_Regularize_1011 = 0;
    IData/*31:0*/ __Vdfg_Regularize_1012;
    __Vdfg_Regularize_1012 = 0;
    IData/*31:0*/ __Vdfg_Regularize_1013;
    __Vdfg_Regularize_1013 = 0;
    IData/*31:0*/ __Vdfg_Regularize_1014;
    __Vdfg_Regularize_1014 = 0;
    IData/*31:0*/ __Vdfg_Regularize_1015;
    __Vdfg_Regularize_1015 = 0;
    IData/*31:0*/ __Vdfg_Regularize_1016;
    __Vdfg_Regularize_1016 = 0;
    IData/*31:0*/ __Vdfg_Regularize_1017;
    __Vdfg_Regularize_1017 = 0;
    IData/*31:0*/ __Vdfg_Regularize_1018;
    __Vdfg_Regularize_1018 = 0;
    IData/*31:0*/ __Vdfg_Regularize_1019;
    __Vdfg_Regularize_1019 = 0;
    IData/*31:0*/ __Vdfg_Regularize_1020;
    __Vdfg_Regularize_1020 = 0;
    IData/*31:0*/ __Vdfg_Regularize_1021;
    __Vdfg_Regularize_1021 = 0;
    IData/*31:0*/ __Vdfg_Regularize_1022;
    __Vdfg_Regularize_1022 = 0;
    IData/*31:0*/ __Vdfg_Regularize_1023;
    __Vdfg_Regularize_1023 = 0;
    IData/*31:0*/ __Vdfg_Regularize_1024;
    __Vdfg_Regularize_1024 = 0;
    IData/*31:0*/ __Vdfg_Regularize_1025;
    __Vdfg_Regularize_1025 = 0;
    IData/*31:0*/ __Vdfg_Regularize_1026;
    __Vdfg_Regularize_1026 = 0;
    IData/*31:0*/ __Vdfg_Regularize_1027;
    __Vdfg_Regularize_1027 = 0;
    IData/*31:0*/ __Vdfg_Regularize_1028;
    __Vdfg_Regularize_1028 = 0;
    IData/*31:0*/ __Vdfg_Regularize_1029;
    __Vdfg_Regularize_1029 = 0;
    IData/*31:0*/ __Vdfg_Regularize_1030;
    __Vdfg_Regularize_1030 = 0;
    IData/*31:0*/ __Vdfg_Regularize_1031;
    __Vdfg_Regularize_1031 = 0;
    IData/*31:0*/ __Vdfg_Regularize_1032;
    __Vdfg_Regularize_1032 = 0;
    IData/*31:0*/ __Vdfg_Regularize_1033;
    __Vdfg_Regularize_1033 = 0;
    IData/*31:0*/ __Vdfg_Regularize_1034;
    __Vdfg_Regularize_1034 = 0;
    IData/*31:0*/ __Vdfg_Regularize_1035;
    __Vdfg_Regularize_1035 = 0;
    IData/*31:0*/ __Vdfg_Regularize_1036;
    __Vdfg_Regularize_1036 = 0;
    IData/*31:0*/ __Vdfg_Regularize_1037;
    __Vdfg_Regularize_1037 = 0;
    IData/*31:0*/ __Vdfg_Regularize_1038;
    __Vdfg_Regularize_1038 = 0;
    IData/*31:0*/ __Vdfg_Regularize_1039;
    __Vdfg_Regularize_1039 = 0;
    IData/*31:0*/ __Vdfg_Regularize_1040;
    __Vdfg_Regularize_1040 = 0;
    IData/*31:0*/ __Vdfg_Regularize_1041;
    __Vdfg_Regularize_1041 = 0;
    IData/*31:0*/ __Vdfg_Regularize_1042;
    __Vdfg_Regularize_1042 = 0;
    IData/*31:0*/ __Vdfg_Regularize_1043;
    __Vdfg_Regularize_1043 = 0;
    IData/*31:0*/ __Vdfg_Regularize_1044;
    __Vdfg_Regularize_1044 = 0;
    IData/*31:0*/ __Vdfg_Regularize_1045;
    __Vdfg_Regularize_1045 = 0;
    IData/*31:0*/ __Vdfg_Regularize_1046;
    __Vdfg_Regularize_1046 = 0;
    IData/*31:0*/ __Vdfg_Regularize_1047;
    __Vdfg_Regularize_1047 = 0;
    IData/*31:0*/ __Vdfg_Regularize_1048;
    __Vdfg_Regularize_1048 = 0;
    IData/*31:0*/ __Vdfg_Regularize_1049;
    __Vdfg_Regularize_1049 = 0;
    IData/*31:0*/ __Vdfg_Regularize_1050;
    __Vdfg_Regularize_1050 = 0;
    IData/*31:0*/ __Vdfg_Regularize_1051;
    __Vdfg_Regularize_1051 = 0;
    IData/*31:0*/ __Vdfg_Regularize_1052;
    __Vdfg_Regularize_1052 = 0;
    IData/*31:0*/ __Vdfg_Regularize_1053;
    __Vdfg_Regularize_1053 = 0;
    IData/*31:0*/ __Vdfg_Regularize_1054;
    __Vdfg_Regularize_1054 = 0;
    IData/*31:0*/ __Vdfg_Regularize_1055;
    __Vdfg_Regularize_1055 = 0;
    IData/*31:0*/ __Vdfg_Regularize_1056;
    __Vdfg_Regularize_1056 = 0;
    IData/*31:0*/ __Vdfg_Regularize_1057;
    __Vdfg_Regularize_1057 = 0;
    IData/*31:0*/ __Vdfg_Regularize_1058;
    __Vdfg_Regularize_1058 = 0;
    IData/*31:0*/ __Vdfg_Regularize_1059;
    __Vdfg_Regularize_1059 = 0;
    IData/*31:0*/ __Vdfg_Regularize_1060;
    __Vdfg_Regularize_1060 = 0;
    IData/*31:0*/ __Vdfg_Regularize_1061;
    __Vdfg_Regularize_1061 = 0;
    IData/*31:0*/ __Vdfg_Regularize_1062;
    __Vdfg_Regularize_1062 = 0;
    IData/*31:0*/ __Vdfg_Regularize_1063;
    __Vdfg_Regularize_1063 = 0;
    IData/*31:0*/ __Vdfg_Regularize_1064;
    __Vdfg_Regularize_1064 = 0;
    IData/*31:0*/ __Vdfg_Regularize_1065;
    __Vdfg_Regularize_1065 = 0;
    IData/*31:0*/ __Vdfg_Regularize_1066;
    __Vdfg_Regularize_1066 = 0;
    IData/*31:0*/ __Vdfg_Regularize_1067;
    __Vdfg_Regularize_1067 = 0;
    IData/*31:0*/ __Vdfg_Regularize_1068;
    __Vdfg_Regularize_1068 = 0;
    IData/*31:0*/ __Vdfg_Regularize_1069;
    __Vdfg_Regularize_1069 = 0;
    IData/*31:0*/ __Vdfg_Regularize_1070;
    __Vdfg_Regularize_1070 = 0;
    IData/*31:0*/ __Vdfg_Regularize_1071;
    __Vdfg_Regularize_1071 = 0;
    IData/*31:0*/ __Vdfg_Regularize_1072;
    __Vdfg_Regularize_1072 = 0;
    IData/*31:0*/ __Vdfg_Regularize_1073;
    __Vdfg_Regularize_1073 = 0;
    IData/*31:0*/ __Vdfg_Regularize_1074;
    __Vdfg_Regularize_1074 = 0;
    IData/*31:0*/ __Vdfg_Regularize_1075;
    __Vdfg_Regularize_1075 = 0;
    IData/*31:0*/ __Vdfg_Regularize_1076;
    __Vdfg_Regularize_1076 = 0;
    IData/*31:0*/ __Vdfg_Regularize_1077;
    __Vdfg_Regularize_1077 = 0;
    IData/*31:0*/ __Vdfg_Regularize_1078;
    __Vdfg_Regularize_1078 = 0;
    IData/*31:0*/ __Vdfg_Regularize_1079;
    __Vdfg_Regularize_1079 = 0;
    IData/*31:0*/ __Vdfg_Regularize_1080;
    __Vdfg_Regularize_1080 = 0;
    IData/*31:0*/ __Vdfg_Regularize_1081;
    __Vdfg_Regularize_1081 = 0;
    IData/*31:0*/ __Vdfg_Regularize_1082;
    __Vdfg_Regularize_1082 = 0;
    IData/*31:0*/ __Vdfg_Regularize_1083;
    __Vdfg_Regularize_1083 = 0;
    IData/*31:0*/ __Vdfg_Regularize_1084;
    __Vdfg_Regularize_1084 = 0;
    IData/*31:0*/ __Vdfg_Regularize_1085;
    __Vdfg_Regularize_1085 = 0;
    CData/*0:0*/ __Vdly__m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_4__DOT__u_crc_parallel_full__DOT__reg_busy_4;
    __Vdly__m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_4__DOT__u_crc_parallel_full__DOT__reg_busy_4 = 0;
    CData/*0:0*/ __Vdly__m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_4__DOT__u_crc_parallel_full__DOT__reg_busy_11;
    __Vdly__m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_4__DOT__u_crc_parallel_full__DOT__reg_busy_11 = 0;
    // Body
    __Vdly__m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_4__DOT__u_crc_parallel_full__DOT__reg_busy_11 
        = vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_4__DOT__u_crc_parallel_full__DOT__reg_busy;
    __Vdly__m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_4__DOT__u_crc_parallel_full__DOT__reg_busy_4 
        = vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_4__DOT__u_crc_parallel_full__DOT__reg_busy;
    if (vlSelfRef.i_rst_n_crc) {
        if (((IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_4__DOT__u_crc_parallel_full__DOT__reg_crc_valid) 
             & (IData)(vlSelfRef.i_gen_crc_ready))) {
            vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_4__DOT__u_crc_parallel_full__DOT__reg_crc_valid = 0U;
        }
        if (vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_4__DOT__u_crc_parallel_full__DOT__reg_busy) {
            __Vdly__m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_4__DOT__u_crc_parallel_full__DOT__reg_busy_11 = 0U;
            if (vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_4__DOT__u_crc_parallel_full__DOT__reg_last) {
                vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_4__DOT__u_crc_parallel_full__DOT__reg_crc_valid = 1U;
                __Vfunc_m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_4__DOT__u_crc_parallel_full__DOT__f_finalize__i_crc_49 
                    = vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_4__DOT__u_crc_parallel_full__DOT__w_crc_nxt;
                __Vfunc_m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_4__DOT__u_crc_parallel_full__DOT__f_finalize__w_reflected_crc_51 = 0U;
                __Vfunc_m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_4__DOT__u_crc_parallel_full__DOT__f_finalize__w_reflected_crc_51 
                    = ((0xfffffff8U & __Vfunc_m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_4__DOT__u_crc_parallel_full__DOT__f_finalize__w_reflected_crc_51) 
                       | ((4U & (__Vfunc_m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_4__DOT__u_crc_parallel_full__DOT__f_finalize__i_crc_49 
                                 >> 0x0000001bU)) | 
                          ((2U & (__Vfunc_m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_4__DOT__u_crc_parallel_full__DOT__f_finalize__i_crc_49 
                                  >> 0x0000001dU)) 
                           | (__Vfunc_m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_4__DOT__u_crc_parallel_full__DOT__f_finalize__i_crc_49 
                              >> 0x1fU))));
                __Vfunc_m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_4__DOT__u_crc_parallel_full__DOT__f_finalize__w_reflected_crc_51 
                    = ((0xffffffc7U & __Vfunc_m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_4__DOT__u_crc_parallel_full__DOT__f_finalize__w_reflected_crc_51) 
                       | (((4U & (__Vfunc_m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_4__DOT__u_crc_parallel_full__DOT__f_finalize__i_crc_49 
                                  >> 0x00000018U)) 
                           | ((2U & (__Vfunc_m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_4__DOT__u_crc_parallel_full__DOT__f_finalize__i_crc_49 
                                     >> 0x0000001aU)) 
                              | (1U & (__Vfunc_m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_4__DOT__u_crc_parallel_full__DOT__f_finalize__i_crc_49 
                                       >> 0x1cU)))) 
                          << 3U));
                __Vfunc_m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_4__DOT__u_crc_parallel_full__DOT__f_finalize__w_reflected_crc_51 
                    = ((0xfffffe3fU & __Vfunc_m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_4__DOT__u_crc_parallel_full__DOT__f_finalize__w_reflected_crc_51) 
                       | (((4U & (__Vfunc_m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_4__DOT__u_crc_parallel_full__DOT__f_finalize__i_crc_49 
                                  >> 0x00000015U)) 
                           | ((2U & (__Vfunc_m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_4__DOT__u_crc_parallel_full__DOT__f_finalize__i_crc_49 
                                     >> 0x00000017U)) 
                              | (1U & (__Vfunc_m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_4__DOT__u_crc_parallel_full__DOT__f_finalize__i_crc_49 
                                       >> 0x19U)))) 
                          << 6U));
                __Vfunc_m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_4__DOT__u_crc_parallel_full__DOT__f_finalize__w_reflected_crc_51 
                    = ((0xfffff1ffU & __Vfunc_m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_4__DOT__u_crc_parallel_full__DOT__f_finalize__w_reflected_crc_51) 
                       | (((4U & (__Vfunc_m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_4__DOT__u_crc_parallel_full__DOT__f_finalize__i_crc_49 
                                  >> 0x00000012U)) 
                           | ((2U & (__Vfunc_m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_4__DOT__u_crc_parallel_full__DOT__f_finalize__i_crc_49 
                                     >> 0x00000014U)) 
                              | (1U & (__Vfunc_m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_4__DOT__u_crc_parallel_full__DOT__f_finalize__i_crc_49 
                                       >> 0x16U)))) 
                          << 9U));
                __Vfunc_m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_4__DOT__u_crc_parallel_full__DOT__f_finalize__w_reflected_crc_51 
                    = ((0xffff8fffU & __Vfunc_m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_4__DOT__u_crc_parallel_full__DOT__f_finalize__w_reflected_crc_51) 
                       | (((4U & (__Vfunc_m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_4__DOT__u_crc_parallel_full__DOT__f_finalize__i_crc_49 
                                  >> 0x0000000fU)) 
                           | ((2U & (__Vfunc_m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_4__DOT__u_crc_parallel_full__DOT__f_finalize__i_crc_49 
                                     >> 0x00000011U)) 
                              | (1U & (__Vfunc_m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_4__DOT__u_crc_parallel_full__DOT__f_finalize__i_crc_49 
                                       >> 0x13U)))) 
                          << 0x0000000cU));
                __Vfunc_m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_4__DOT__u_crc_parallel_full__DOT__f_finalize__w_reflected_crc_51 
                    = ((0xfffc7fffU & __Vfunc_m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_4__DOT__u_crc_parallel_full__DOT__f_finalize__w_reflected_crc_51) 
                       | (((4U & (__Vfunc_m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_4__DOT__u_crc_parallel_full__DOT__f_finalize__i_crc_49 
                                  >> 0x0000000cU)) 
                           | ((2U & (__Vfunc_m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_4__DOT__u_crc_parallel_full__DOT__f_finalize__i_crc_49 
                                     >> 0x0000000eU)) 
                              | (1U & (__Vfunc_m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_4__DOT__u_crc_parallel_full__DOT__f_finalize__i_crc_49 
                                       >> 0x10U)))) 
                          << 0x0000000fU));
                __Vfunc_m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_4__DOT__u_crc_parallel_full__DOT__f_finalize__w_reflected_crc_51 
                    = ((0xffe3ffffU & __Vfunc_m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_4__DOT__u_crc_parallel_full__DOT__f_finalize__w_reflected_crc_51) 
                       | (((4U & (__Vfunc_m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_4__DOT__u_crc_parallel_full__DOT__f_finalize__i_crc_49 
                                  >> 9U)) | ((2U & 
                                              (__Vfunc_m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_4__DOT__u_crc_parallel_full__DOT__f_finalize__i_crc_49 
                                               >> 0x0000000bU)) 
                                             | (1U 
                                                & (__Vfunc_m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_4__DOT__u_crc_parallel_full__DOT__f_finalize__i_crc_49 
                                                   >> 0x0dU)))) 
                          << 0x00000012U));
                __Vfunc_m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_4__DOT__u_crc_parallel_full__DOT__f_finalize__w_reflected_crc_51 
                    = ((0xff1fffffU & __Vfunc_m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_4__DOT__u_crc_parallel_full__DOT__f_finalize__w_reflected_crc_51) 
                       | (((4U & (__Vfunc_m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_4__DOT__u_crc_parallel_full__DOT__f_finalize__i_crc_49 
                                  >> 6U)) | ((2U & 
                                              (__Vfunc_m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_4__DOT__u_crc_parallel_full__DOT__f_finalize__i_crc_49 
                                               >> 8U)) 
                                             | (1U 
                                                & (__Vfunc_m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_4__DOT__u_crc_parallel_full__DOT__f_finalize__i_crc_49 
                                                   >> 0x0aU)))) 
                          << 0x00000015U));
                __Vfunc_m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_4__DOT__u_crc_parallel_full__DOT__f_finalize__w_reflected_crc_51 
                    = ((0xf8ffffffU & __Vfunc_m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_4__DOT__u_crc_parallel_full__DOT__f_finalize__w_reflected_crc_51) 
                       | (((4U & (__Vfunc_m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_4__DOT__u_crc_parallel_full__DOT__f_finalize__i_crc_49 
                                  >> 3U)) | ((2U & 
                                              (__Vfunc_m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_4__DOT__u_crc_parallel_full__DOT__f_finalize__i_crc_49 
                                               >> 5U)) 
                                             | (1U 
                                                & (__Vfunc_m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_4__DOT__u_crc_parallel_full__DOT__f_finalize__i_crc_49 
                                                   >> 7U)))) 
                          << 0x00000018U));
                __Vfunc_m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_4__DOT__u_crc_parallel_full__DOT__f_finalize__w_reflected_crc_51 
                    = ((0xc7ffffffU & __Vfunc_m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_4__DOT__u_crc_parallel_full__DOT__f_finalize__w_reflected_crc_51) 
                       | (((4U & __Vfunc_m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_4__DOT__u_crc_parallel_full__DOT__f_finalize__i_crc_49) 
                           | ((2U & (__Vfunc_m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_4__DOT__u_crc_parallel_full__DOT__f_finalize__i_crc_49 
                                     >> 2U)) | (1U 
                                                & (__Vfunc_m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_4__DOT__u_crc_parallel_full__DOT__f_finalize__i_crc_49 
                                                   >> 4U)))) 
                          << 0x0000001bU));
                __Vfunc_m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_4__DOT__u_crc_parallel_full__DOT__f_finalize__w_reflected_crc_51 
                    = ((0x3fffffffU & __Vfunc_m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_4__DOT__u_crc_parallel_full__DOT__f_finalize__w_reflected_crc_51) 
                       | (((2U & (__Vfunc_m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_4__DOT__u_crc_parallel_full__DOT__f_finalize__i_crc_49 
                                  << 1U)) | (1U & (__Vfunc_m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_4__DOT__u_crc_parallel_full__DOT__f_finalize__i_crc_49 
                                                   >> 1U))) 
                          << 0x0000001eU));
                __Vfunc_m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_4__DOT__u_crc_parallel_full__DOT__f_finalize__Vfuncout_48 
                    = (~ __Vfunc_m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_4__DOT__u_crc_parallel_full__DOT__f_finalize__w_reflected_crc_51);
                vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_4__DOT__u_crc_parallel_full__DOT__reg_crc_output 
                    = __Vfunc_m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_4__DOT__u_crc_parallel_full__DOT__f_finalize__Vfuncout_48;
                vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_4__DOT__u_crc_parallel_full__DOT__reg_crc_state = 0xffffffffU;
            } else {
                vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_4__DOT__u_crc_parallel_full__DOT__reg_crc_state 
                    = vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_4__DOT__u_crc_parallel_full__DOT__w_crc_nxt;
            }
        } else if (((IData)(vlSelfRef.i_gen_valid) 
                    & (IData)(vlSelfRef.o_gen_data_ready))) {
            __Vdly__m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_4__DOT__u_crc_parallel_full__DOT__reg_busy_11 = 1U;
        }
        if (((IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_4__DOT__u_crc_parallel_full__DOT__reg_crc_valid) 
             & (IData)(vlSelfRef.i_check_crc_ready))) {
            vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_4__DOT__u_crc_parallel_full__DOT__reg_crc_valid = 0U;
        }
        if (vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_4__DOT__u_crc_parallel_full__DOT__reg_busy) {
            __Vdly__m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_4__DOT__u_crc_parallel_full__DOT__reg_busy_4 = 0U;
            if (vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_4__DOT__u_crc_parallel_full__DOT__reg_last) {
                vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_4__DOT__u_crc_parallel_full__DOT__reg_crc_valid = 1U;
                __Vfunc_m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_4__DOT__u_crc_parallel_full__DOT__f_finalize__i_crc_23 
                    = vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_4__DOT__u_crc_parallel_full__DOT__w_crc_nxt;
                __Vfunc_m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_4__DOT__u_crc_parallel_full__DOT__f_finalize__w_reflected_crc_25 = 0U;
                __Vfunc_m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_4__DOT__u_crc_parallel_full__DOT__f_finalize__w_reflected_crc_25 
                    = ((0xfffffff8U & __Vfunc_m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_4__DOT__u_crc_parallel_full__DOT__f_finalize__w_reflected_crc_25) 
                       | ((4U & (__Vfunc_m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_4__DOT__u_crc_parallel_full__DOT__f_finalize__i_crc_23 
                                 >> 0x0000001bU)) | 
                          ((2U & (__Vfunc_m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_4__DOT__u_crc_parallel_full__DOT__f_finalize__i_crc_23 
                                  >> 0x0000001dU)) 
                           | (__Vfunc_m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_4__DOT__u_crc_parallel_full__DOT__f_finalize__i_crc_23 
                              >> 0x1fU))));
                __Vfunc_m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_4__DOT__u_crc_parallel_full__DOT__f_finalize__w_reflected_crc_25 
                    = ((0xffffffc7U & __Vfunc_m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_4__DOT__u_crc_parallel_full__DOT__f_finalize__w_reflected_crc_25) 
                       | (((4U & (__Vfunc_m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_4__DOT__u_crc_parallel_full__DOT__f_finalize__i_crc_23 
                                  >> 0x00000018U)) 
                           | ((2U & (__Vfunc_m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_4__DOT__u_crc_parallel_full__DOT__f_finalize__i_crc_23 
                                     >> 0x0000001aU)) 
                              | (1U & (__Vfunc_m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_4__DOT__u_crc_parallel_full__DOT__f_finalize__i_crc_23 
                                       >> 0x1cU)))) 
                          << 3U));
                __Vfunc_m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_4__DOT__u_crc_parallel_full__DOT__f_finalize__w_reflected_crc_25 
                    = ((0xfffffe3fU & __Vfunc_m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_4__DOT__u_crc_parallel_full__DOT__f_finalize__w_reflected_crc_25) 
                       | (((4U & (__Vfunc_m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_4__DOT__u_crc_parallel_full__DOT__f_finalize__i_crc_23 
                                  >> 0x00000015U)) 
                           | ((2U & (__Vfunc_m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_4__DOT__u_crc_parallel_full__DOT__f_finalize__i_crc_23 
                                     >> 0x00000017U)) 
                              | (1U & (__Vfunc_m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_4__DOT__u_crc_parallel_full__DOT__f_finalize__i_crc_23 
                                       >> 0x19U)))) 
                          << 6U));
                __Vfunc_m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_4__DOT__u_crc_parallel_full__DOT__f_finalize__w_reflected_crc_25 
                    = ((0xfffff1ffU & __Vfunc_m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_4__DOT__u_crc_parallel_full__DOT__f_finalize__w_reflected_crc_25) 
                       | (((4U & (__Vfunc_m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_4__DOT__u_crc_parallel_full__DOT__f_finalize__i_crc_23 
                                  >> 0x00000012U)) 
                           | ((2U & (__Vfunc_m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_4__DOT__u_crc_parallel_full__DOT__f_finalize__i_crc_23 
                                     >> 0x00000014U)) 
                              | (1U & (__Vfunc_m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_4__DOT__u_crc_parallel_full__DOT__f_finalize__i_crc_23 
                                       >> 0x16U)))) 
                          << 9U));
                __Vfunc_m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_4__DOT__u_crc_parallel_full__DOT__f_finalize__w_reflected_crc_25 
                    = ((0xffff8fffU & __Vfunc_m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_4__DOT__u_crc_parallel_full__DOT__f_finalize__w_reflected_crc_25) 
                       | (((4U & (__Vfunc_m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_4__DOT__u_crc_parallel_full__DOT__f_finalize__i_crc_23 
                                  >> 0x0000000fU)) 
                           | ((2U & (__Vfunc_m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_4__DOT__u_crc_parallel_full__DOT__f_finalize__i_crc_23 
                                     >> 0x00000011U)) 
                              | (1U & (__Vfunc_m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_4__DOT__u_crc_parallel_full__DOT__f_finalize__i_crc_23 
                                       >> 0x13U)))) 
                          << 0x0000000cU));
                __Vfunc_m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_4__DOT__u_crc_parallel_full__DOT__f_finalize__w_reflected_crc_25 
                    = ((0xfffc7fffU & __Vfunc_m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_4__DOT__u_crc_parallel_full__DOT__f_finalize__w_reflected_crc_25) 
                       | (((4U & (__Vfunc_m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_4__DOT__u_crc_parallel_full__DOT__f_finalize__i_crc_23 
                                  >> 0x0000000cU)) 
                           | ((2U & (__Vfunc_m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_4__DOT__u_crc_parallel_full__DOT__f_finalize__i_crc_23 
                                     >> 0x0000000eU)) 
                              | (1U & (__Vfunc_m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_4__DOT__u_crc_parallel_full__DOT__f_finalize__i_crc_23 
                                       >> 0x10U)))) 
                          << 0x0000000fU));
                __Vfunc_m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_4__DOT__u_crc_parallel_full__DOT__f_finalize__w_reflected_crc_25 
                    = ((0xffe3ffffU & __Vfunc_m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_4__DOT__u_crc_parallel_full__DOT__f_finalize__w_reflected_crc_25) 
                       | (((4U & (__Vfunc_m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_4__DOT__u_crc_parallel_full__DOT__f_finalize__i_crc_23 
                                  >> 9U)) | ((2U & 
                                              (__Vfunc_m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_4__DOT__u_crc_parallel_full__DOT__f_finalize__i_crc_23 
                                               >> 0x0000000bU)) 
                                             | (1U 
                                                & (__Vfunc_m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_4__DOT__u_crc_parallel_full__DOT__f_finalize__i_crc_23 
                                                   >> 0x0dU)))) 
                          << 0x00000012U));
                __Vfunc_m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_4__DOT__u_crc_parallel_full__DOT__f_finalize__w_reflected_crc_25 
                    = ((0xff1fffffU & __Vfunc_m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_4__DOT__u_crc_parallel_full__DOT__f_finalize__w_reflected_crc_25) 
                       | (((4U & (__Vfunc_m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_4__DOT__u_crc_parallel_full__DOT__f_finalize__i_crc_23 
                                  >> 6U)) | ((2U & 
                                              (__Vfunc_m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_4__DOT__u_crc_parallel_full__DOT__f_finalize__i_crc_23 
                                               >> 8U)) 
                                             | (1U 
                                                & (__Vfunc_m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_4__DOT__u_crc_parallel_full__DOT__f_finalize__i_crc_23 
                                                   >> 0x0aU)))) 
                          << 0x00000015U));
                __Vfunc_m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_4__DOT__u_crc_parallel_full__DOT__f_finalize__w_reflected_crc_25 
                    = ((0xf8ffffffU & __Vfunc_m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_4__DOT__u_crc_parallel_full__DOT__f_finalize__w_reflected_crc_25) 
                       | (((4U & (__Vfunc_m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_4__DOT__u_crc_parallel_full__DOT__f_finalize__i_crc_23 
                                  >> 3U)) | ((2U & 
                                              (__Vfunc_m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_4__DOT__u_crc_parallel_full__DOT__f_finalize__i_crc_23 
                                               >> 5U)) 
                                             | (1U 
                                                & (__Vfunc_m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_4__DOT__u_crc_parallel_full__DOT__f_finalize__i_crc_23 
                                                   >> 7U)))) 
                          << 0x00000018U));
                __Vfunc_m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_4__DOT__u_crc_parallel_full__DOT__f_finalize__w_reflected_crc_25 
                    = ((0xc7ffffffU & __Vfunc_m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_4__DOT__u_crc_parallel_full__DOT__f_finalize__w_reflected_crc_25) 
                       | (((4U & __Vfunc_m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_4__DOT__u_crc_parallel_full__DOT__f_finalize__i_crc_23) 
                           | ((2U & (__Vfunc_m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_4__DOT__u_crc_parallel_full__DOT__f_finalize__i_crc_23 
                                     >> 2U)) | (1U 
                                                & (__Vfunc_m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_4__DOT__u_crc_parallel_full__DOT__f_finalize__i_crc_23 
                                                   >> 4U)))) 
                          << 0x0000001bU));
                __Vfunc_m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_4__DOT__u_crc_parallel_full__DOT__f_finalize__w_reflected_crc_25 
                    = ((0x3fffffffU & __Vfunc_m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_4__DOT__u_crc_parallel_full__DOT__f_finalize__w_reflected_crc_25) 
                       | (((2U & (__Vfunc_m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_4__DOT__u_crc_parallel_full__DOT__f_finalize__i_crc_23 
                                  << 1U)) | (1U & (__Vfunc_m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_4__DOT__u_crc_parallel_full__DOT__f_finalize__i_crc_23 
                                                   >> 1U))) 
                          << 0x0000001eU));
                __Vfunc_m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_4__DOT__u_crc_parallel_full__DOT__f_finalize__Vfuncout_22 
                    = (~ __Vfunc_m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_4__DOT__u_crc_parallel_full__DOT__f_finalize__w_reflected_crc_25);
                vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_4__DOT__u_crc_parallel_full__DOT__reg_crc_output 
                    = __Vfunc_m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_4__DOT__u_crc_parallel_full__DOT__f_finalize__Vfuncout_22;
                vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_4__DOT__u_crc_parallel_full__DOT__reg_crc_state = 0xffffffffU;
            } else {
                vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_4__DOT__u_crc_parallel_full__DOT__reg_crc_state 
                    = vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_4__DOT__u_crc_parallel_full__DOT__w_crc_nxt;
            }
        } else if (((IData)(vlSelfRef.i_check_valid) 
                    & (IData)(vlSelfRef.o_check_data_ready))) {
            __Vdly__m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_4__DOT__u_crc_parallel_full__DOT__reg_busy_4 = 1U;
        }
        if ((((IData)(vlSelfRef.i_check_valid) & (IData)(vlSelfRef.o_check_data_ready)) 
             & (IData)(vlSelfRef.i_check_last))) {
            vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__reg_check_crc_ref 
                = vlSelfRef.i_check_crc;
        }
        if ((1U & (~ (IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_4__DOT__u_crc_parallel_full__DOT__reg_busy)))) {
            if (((IData)(vlSelfRef.i_gen_valid) & (IData)(vlSelfRef.o_gen_data_ready))) {
                vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_4__DOT__u_crc_parallel_full__DOT__reg_keep 
                    = vlSelfRef.i_gen_keep;
                vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_4__DOT__u_crc_parallel_full__DOT__reg_data 
                    = vlSelfRef.i_gen_data;
                vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_4__DOT__u_crc_parallel_full__DOT__reg_last 
                    = vlSelfRef.i_gen_last;
            }
        }
        if ((1U & (~ (IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_4__DOT__u_crc_parallel_full__DOT__reg_busy)))) {
            if (((IData)(vlSelfRef.i_check_valid) & (IData)(vlSelfRef.o_check_data_ready))) {
                vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_4__DOT__u_crc_parallel_full__DOT__reg_keep 
                    = vlSelfRef.i_check_keep;
                vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_4__DOT__u_crc_parallel_full__DOT__reg_data 
                    = vlSelfRef.i_check_data;
                vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_4__DOT__u_crc_parallel_full__DOT__reg_last 
                    = vlSelfRef.i_check_last;
            }
        }
    } else {
        __Vdly__m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_4__DOT__u_crc_parallel_full__DOT__reg_busy_11 = 0U;
        __Vdly__m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_4__DOT__u_crc_parallel_full__DOT__reg_busy_4 = 0U;
        vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_4__DOT__u_crc_parallel_full__DOT__reg_crc_valid = 0U;
        vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_4__DOT__u_crc_parallel_full__DOT__reg_crc_valid = 0U;
        vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__reg_check_crc_ref = 0U;
        vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_4__DOT__u_crc_parallel_full__DOT__reg_crc_output = 0U;
        vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_4__DOT__u_crc_parallel_full__DOT__reg_crc_output = 0U;
        vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_4__DOT__u_crc_parallel_full__DOT__reg_keep = 0U;
        vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_4__DOT__u_crc_parallel_full__DOT__reg_keep = 0U;
        vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_4__DOT__u_crc_parallel_full__DOT__reg_data = 0U;
        vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_4__DOT__u_crc_parallel_full__DOT__reg_data = 0U;
        vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_4__DOT__u_crc_parallel_full__DOT__reg_crc_state = 0xffffffffU;
        vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_4__DOT__u_crc_parallel_full__DOT__reg_crc_state = 0xffffffffU;
        vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_4__DOT__u_crc_parallel_full__DOT__reg_last = 0U;
        vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_4__DOT__u_crc_parallel_full__DOT__reg_last = 0U;
    }
    vlSelfRef.o_gen_crc_valid = vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_4__DOT__u_crc_parallel_full__DOT__reg_crc_valid;
    vlSelfRef.o_check_crc_valid = vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_4__DOT__u_crc_parallel_full__DOT__reg_crc_valid;
    vlSelfRef.o_gen_crc = vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_4__DOT__u_crc_parallel_full__DOT__reg_crc_output;
    vlSelfRef.o_check_pass = ((IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_4__DOT__u_crc_parallel_full__DOT__reg_crc_valid) 
                              & (vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__reg_check_crc_ref 
                                 == vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_4__DOT__u_crc_parallel_full__DOT__reg_crc_output));
    __Vdfg_Regularize_995 = ((vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_4__DOT__u_crc_parallel_full__DOT__reg_crc_state 
                              << 1U) | (1U & (vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_4__DOT__u_crc_parallel_full__DOT__reg_data 
                                              >> 0x00000018U)));
    __Vdfg_Regularize_872 = ((vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_4__DOT__u_crc_parallel_full__DOT__reg_crc_state 
                              << 1U) | (1U & (vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_4__DOT__u_crc_parallel_full__DOT__reg_data 
                                              >> 0x00000018U)));
    vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_4__DOT__u_crc_parallel_full__DOT__reg_busy 
        = __Vdly__m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_4__DOT__u_crc_parallel_full__DOT__reg_busy_11;
    __Vdfg_Regularize_996 = ((vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_4__DOT__u_crc_parallel_full__DOT__reg_crc_state 
                              >> 0x0000001fU) ? (0x04c11db7U 
                                                 ^ __Vdfg_Regularize_995)
                              : __Vdfg_Regularize_995);
    vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_4__DOT__u_crc_parallel_full__DOT__reg_busy 
        = __Vdly__m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_4__DOT__u_crc_parallel_full__DOT__reg_busy_4;
    __Vdfg_Regularize_873 = ((vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_4__DOT__u_crc_parallel_full__DOT__reg_crc_state 
                              >> 0x0000001fU) ? (0x04c11db7U 
                                                 ^ __Vdfg_Regularize_872)
                              : __Vdfg_Regularize_872);
    vlSelfRef.o_gen_data_ready = ((~ ((IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_4__DOT__u_crc_parallel_full__DOT__reg_busy) 
                                      | (IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_4__DOT__u_crc_parallel_full__DOT__reg_crc_valid))) 
                                  & (IData)(vlSelfRef.i_rst_n_crc));
    __Vdfg_Regularize_997 = ((__Vdfg_Regularize_996 
                              << 1U) | (1U & (vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_4__DOT__u_crc_parallel_full__DOT__reg_data 
                                              >> 0x00000019U)));
    vlSelfRef.o_check_data_ready = ((~ ((IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_4__DOT__u_crc_parallel_full__DOT__reg_busy) 
                                        | (IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_4__DOT__u_crc_parallel_full__DOT__reg_crc_valid))) 
                                    & (IData)(vlSelfRef.i_rst_n_crc));
    __Vdfg_Regularize_874 = ((__Vdfg_Regularize_873 
                              << 1U) | (1U & (vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_4__DOT__u_crc_parallel_full__DOT__reg_data 
                                              >> 0x00000019U)));
    __Vdfg_Regularize_998 = ((__Vdfg_Regularize_996 
                              >> 0x0000001fU) ? (0x04c11db7U 
                                                 ^ __Vdfg_Regularize_997)
                              : __Vdfg_Regularize_997);
    __Vdfg_Regularize_875 = ((__Vdfg_Regularize_873 
                              >> 0x0000001fU) ? (0x04c11db7U 
                                                 ^ __Vdfg_Regularize_874)
                              : __Vdfg_Regularize_874);
    __Vdfg_Regularize_999 = ((__Vdfg_Regularize_998 
                              << 1U) | (1U & (vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_4__DOT__u_crc_parallel_full__DOT__reg_data 
                                              >> 0x0000001aU)));
    __Vdfg_Regularize_876 = ((__Vdfg_Regularize_875 
                              << 1U) | (1U & (vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_4__DOT__u_crc_parallel_full__DOT__reg_data 
                                              >> 0x0000001aU)));
    __Vdfg_Regularize_1000 = ((__Vdfg_Regularize_998 
                               >> 0x0000001fU) ? (0x04c11db7U 
                                                  ^ __Vdfg_Regularize_999)
                               : __Vdfg_Regularize_999);
    __Vdfg_Regularize_877 = ((__Vdfg_Regularize_875 
                              >> 0x0000001fU) ? (0x04c11db7U 
                                                 ^ __Vdfg_Regularize_876)
                              : __Vdfg_Regularize_876);
    __Vdfg_Regularize_1001 = ((__Vdfg_Regularize_1000 
                               << 1U) | (1U & (vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_4__DOT__u_crc_parallel_full__DOT__reg_data 
                                               >> 0x0000001bU)));
    __Vdfg_Regularize_878 = ((__Vdfg_Regularize_877 
                              << 1U) | (1U & (vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_4__DOT__u_crc_parallel_full__DOT__reg_data 
                                              >> 0x0000001bU)));
    __Vdfg_Regularize_1002 = ((__Vdfg_Regularize_1000 
                               >> 0x0000001fU) ? (0x04c11db7U 
                                                  ^ __Vdfg_Regularize_1001)
                               : __Vdfg_Regularize_1001);
    __Vdfg_Regularize_879 = ((__Vdfg_Regularize_877 
                              >> 0x0000001fU) ? (0x04c11db7U 
                                                 ^ __Vdfg_Regularize_878)
                              : __Vdfg_Regularize_878);
    __Vdfg_Regularize_1003 = ((__Vdfg_Regularize_1002 
                               << 1U) | (1U & (vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_4__DOT__u_crc_parallel_full__DOT__reg_data 
                                               >> 0x0000001cU)));
    __Vdfg_Regularize_880 = ((__Vdfg_Regularize_879 
                              << 1U) | (1U & (vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_4__DOT__u_crc_parallel_full__DOT__reg_data 
                                              >> 0x0000001cU)));
    __Vdfg_Regularize_1004 = ((__Vdfg_Regularize_1002 
                               >> 0x0000001fU) ? (0x04c11db7U 
                                                  ^ __Vdfg_Regularize_1003)
                               : __Vdfg_Regularize_1003);
    __Vdfg_Regularize_881 = ((__Vdfg_Regularize_879 
                              >> 0x0000001fU) ? (0x04c11db7U 
                                                 ^ __Vdfg_Regularize_880)
                              : __Vdfg_Regularize_880);
    __Vdfg_Regularize_1005 = ((__Vdfg_Regularize_1004 
                               << 1U) | (1U & (vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_4__DOT__u_crc_parallel_full__DOT__reg_data 
                                               >> 0x0000001dU)));
    __Vdfg_Regularize_882 = ((__Vdfg_Regularize_881 
                              << 1U) | (1U & (vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_4__DOT__u_crc_parallel_full__DOT__reg_data 
                                              >> 0x0000001dU)));
    __Vdfg_Regularize_1006 = ((__Vdfg_Regularize_1004 
                               >> 0x0000001fU) ? (0x04c11db7U 
                                                  ^ __Vdfg_Regularize_1005)
                               : __Vdfg_Regularize_1005);
    __Vdfg_Regularize_883 = ((__Vdfg_Regularize_881 
                              >> 0x0000001fU) ? (0x04c11db7U 
                                                 ^ __Vdfg_Regularize_882)
                              : __Vdfg_Regularize_882);
    __Vdfg_Regularize_1007 = ((__Vdfg_Regularize_1006 
                               << 1U) | (1U & (vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_4__DOT__u_crc_parallel_full__DOT__reg_data 
                                               >> 0x0000001eU)));
    __Vdfg_Regularize_884 = ((__Vdfg_Regularize_883 
                              << 1U) | (1U & (vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_4__DOT__u_crc_parallel_full__DOT__reg_data 
                                              >> 0x0000001eU)));
    __Vdfg_Regularize_1008 = ((__Vdfg_Regularize_1006 
                               >> 0x0000001fU) ? (0x04c11db7U 
                                                  ^ __Vdfg_Regularize_1007)
                               : __Vdfg_Regularize_1007);
    __Vdfg_Regularize_885 = ((__Vdfg_Regularize_883 
                              >> 0x0000001fU) ? (0x04c11db7U 
                                                 ^ __Vdfg_Regularize_884)
                              : __Vdfg_Regularize_884);
    __Vdfg_Regularize_1009 = ((__Vdfg_Regularize_1008 
                               << 1U) | (vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_4__DOT__u_crc_parallel_full__DOT__reg_data 
                                         >> 0x0000001fU));
    __Vdfg_Regularize_886 = ((__Vdfg_Regularize_885 
                              << 1U) | (vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_4__DOT__u_crc_parallel_full__DOT__reg_data 
                                        >> 0x0000001fU));
    __Vdfg_Regularize_868 = ((8U & (IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_4__DOT__u_crc_parallel_full__DOT__reg_keep))
                              ? ((__Vdfg_Regularize_1008 
                                  >> 0x0000001fU) ? 
                                 (0x04c11db7U ^ __Vdfg_Regularize_1009)
                                  : __Vdfg_Regularize_1009)
                              : vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_4__DOT__u_crc_parallel_full__DOT__reg_crc_state);
    __Vdfg_Regularize_864 = ((8U & (IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_4__DOT__u_crc_parallel_full__DOT__reg_keep))
                              ? ((__Vdfg_Regularize_885 
                                  >> 0x0000001fU) ? 
                                 (0x04c11db7U ^ __Vdfg_Regularize_886)
                                  : __Vdfg_Regularize_886)
                              : vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_4__DOT__u_crc_parallel_full__DOT__reg_crc_state);
    __Vdfg_Regularize_1010 = ((__Vdfg_Regularize_868 
                               << 1U) | (1U & (vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_4__DOT__u_crc_parallel_full__DOT__reg_data 
                                               >> 0x00000010U)));
    __Vdfg_Regularize_887 = ((__Vdfg_Regularize_864 
                              << 1U) | (1U & (vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_4__DOT__u_crc_parallel_full__DOT__reg_data 
                                              >> 0x00000010U)));
    __Vdfg_Regularize_1011 = ((__Vdfg_Regularize_868 
                               >> 0x0000001fU) ? (0x04c11db7U 
                                                  ^ __Vdfg_Regularize_1010)
                               : __Vdfg_Regularize_1010);
    __Vdfg_Regularize_888 = ((__Vdfg_Regularize_864 
                              >> 0x0000001fU) ? (0x04c11db7U 
                                                 ^ __Vdfg_Regularize_887)
                              : __Vdfg_Regularize_887);
    __Vdfg_Regularize_1012 = ((__Vdfg_Regularize_1011 
                               << 1U) | (1U & (vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_4__DOT__u_crc_parallel_full__DOT__reg_data 
                                               >> 0x00000011U)));
    __Vdfg_Regularize_889 = ((__Vdfg_Regularize_888 
                              << 1U) | (1U & (vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_4__DOT__u_crc_parallel_full__DOT__reg_data 
                                              >> 0x00000011U)));
    __Vdfg_Regularize_1013 = ((__Vdfg_Regularize_1011 
                               >> 0x0000001fU) ? (0x04c11db7U 
                                                  ^ __Vdfg_Regularize_1012)
                               : __Vdfg_Regularize_1012);
    __Vdfg_Regularize_890 = ((__Vdfg_Regularize_888 
                              >> 0x0000001fU) ? (0x04c11db7U 
                                                 ^ __Vdfg_Regularize_889)
                              : __Vdfg_Regularize_889);
    __Vdfg_Regularize_1014 = ((__Vdfg_Regularize_1013 
                               << 1U) | (1U & (vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_4__DOT__u_crc_parallel_full__DOT__reg_data 
                                               >> 0x00000012U)));
    __Vdfg_Regularize_891 = ((__Vdfg_Regularize_890 
                              << 1U) | (1U & (vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_4__DOT__u_crc_parallel_full__DOT__reg_data 
                                              >> 0x00000012U)));
    __Vdfg_Regularize_1015 = ((__Vdfg_Regularize_1013 
                               >> 0x0000001fU) ? (0x04c11db7U 
                                                  ^ __Vdfg_Regularize_1014)
                               : __Vdfg_Regularize_1014);
    __Vdfg_Regularize_892 = ((__Vdfg_Regularize_890 
                              >> 0x0000001fU) ? (0x04c11db7U 
                                                 ^ __Vdfg_Regularize_891)
                              : __Vdfg_Regularize_891);
    __Vdfg_Regularize_1016 = ((__Vdfg_Regularize_1015 
                               << 1U) | (1U & (vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_4__DOT__u_crc_parallel_full__DOT__reg_data 
                                               >> 0x00000013U)));
    __Vdfg_Regularize_893 = ((__Vdfg_Regularize_892 
                              << 1U) | (1U & (vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_4__DOT__u_crc_parallel_full__DOT__reg_data 
                                              >> 0x00000013U)));
    __Vdfg_Regularize_1017 = ((__Vdfg_Regularize_1015 
                               >> 0x0000001fU) ? (0x04c11db7U 
                                                  ^ __Vdfg_Regularize_1016)
                               : __Vdfg_Regularize_1016);
    __Vdfg_Regularize_894 = ((__Vdfg_Regularize_892 
                              >> 0x0000001fU) ? (0x04c11db7U 
                                                 ^ __Vdfg_Regularize_893)
                              : __Vdfg_Regularize_893);
    __Vdfg_Regularize_1018 = ((__Vdfg_Regularize_1017 
                               << 1U) | (1U & (vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_4__DOT__u_crc_parallel_full__DOT__reg_data 
                                               >> 0x00000014U)));
    __Vdfg_Regularize_895 = ((__Vdfg_Regularize_894 
                              << 1U) | (1U & (vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_4__DOT__u_crc_parallel_full__DOT__reg_data 
                                              >> 0x00000014U)));
    __Vdfg_Regularize_1019 = ((__Vdfg_Regularize_1017 
                               >> 0x0000001fU) ? (0x04c11db7U 
                                                  ^ __Vdfg_Regularize_1018)
                               : __Vdfg_Regularize_1018);
    __Vdfg_Regularize_896 = ((__Vdfg_Regularize_894 
                              >> 0x0000001fU) ? (0x04c11db7U 
                                                 ^ __Vdfg_Regularize_895)
                              : __Vdfg_Regularize_895);
    __Vdfg_Regularize_1020 = ((__Vdfg_Regularize_1019 
                               << 1U) | (1U & (vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_4__DOT__u_crc_parallel_full__DOT__reg_data 
                                               >> 0x00000015U)));
    __Vdfg_Regularize_897 = ((__Vdfg_Regularize_896 
                              << 1U) | (1U & (vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_4__DOT__u_crc_parallel_full__DOT__reg_data 
                                              >> 0x00000015U)));
    __Vdfg_Regularize_1021 = ((__Vdfg_Regularize_1019 
                               >> 0x0000001fU) ? (0x04c11db7U 
                                                  ^ __Vdfg_Regularize_1020)
                               : __Vdfg_Regularize_1020);
    __Vdfg_Regularize_898 = ((__Vdfg_Regularize_896 
                              >> 0x0000001fU) ? (0x04c11db7U 
                                                 ^ __Vdfg_Regularize_897)
                              : __Vdfg_Regularize_897);
    __Vdfg_Regularize_1022 = ((__Vdfg_Regularize_1021 
                               << 1U) | (1U & (vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_4__DOT__u_crc_parallel_full__DOT__reg_data 
                                               >> 0x00000016U)));
    __Vdfg_Regularize_899 = ((__Vdfg_Regularize_898 
                              << 1U) | (1U & (vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_4__DOT__u_crc_parallel_full__DOT__reg_data 
                                              >> 0x00000016U)));
    __Vdfg_Regularize_1023 = ((__Vdfg_Regularize_1021 
                               >> 0x0000001fU) ? (0x04c11db7U 
                                                  ^ __Vdfg_Regularize_1022)
                               : __Vdfg_Regularize_1022);
    __Vdfg_Regularize_900 = ((__Vdfg_Regularize_898 
                              >> 0x0000001fU) ? (0x04c11db7U 
                                                 ^ __Vdfg_Regularize_899)
                              : __Vdfg_Regularize_899);
    __Vdfg_Regularize_1024 = ((__Vdfg_Regularize_1023 
                               << 1U) | (1U & (vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_4__DOT__u_crc_parallel_full__DOT__reg_data 
                                               >> 0x00000017U)));
    __Vdfg_Regularize_901 = ((__Vdfg_Regularize_900 
                              << 1U) | (1U & (vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_4__DOT__u_crc_parallel_full__DOT__reg_data 
                                              >> 0x00000017U)));
    __Vdfg_Regularize_869 = ((4U & (IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_4__DOT__u_crc_parallel_full__DOT__reg_keep))
                              ? ((__Vdfg_Regularize_1023 
                                  >> 0x0000001fU) ? 
                                 (0x04c11db7U ^ __Vdfg_Regularize_1024)
                                  : __Vdfg_Regularize_1024)
                              : __Vdfg_Regularize_868);
    __Vdfg_Regularize_865 = ((4U & (IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_4__DOT__u_crc_parallel_full__DOT__reg_keep))
                              ? ((__Vdfg_Regularize_900 
                                  >> 0x0000001fU) ? 
                                 (0x04c11db7U ^ __Vdfg_Regularize_901)
                                  : __Vdfg_Regularize_901)
                              : __Vdfg_Regularize_864);
    __Vdfg_Regularize_1025 = ((__Vdfg_Regularize_869 
                               << 1U) | (1U & (vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_4__DOT__u_crc_parallel_full__DOT__reg_data 
                                               >> 8U)));
    __Vdfg_Regularize_902 = ((__Vdfg_Regularize_865 
                              << 1U) | (1U & (vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_4__DOT__u_crc_parallel_full__DOT__reg_data 
                                              >> 8U)));
    __Vdfg_Regularize_1026 = ((__Vdfg_Regularize_869 
                               >> 0x0000001fU) ? (0x04c11db7U 
                                                  ^ __Vdfg_Regularize_1025)
                               : __Vdfg_Regularize_1025);
    __Vdfg_Regularize_903 = ((__Vdfg_Regularize_865 
                              >> 0x0000001fU) ? (0x04c11db7U 
                                                 ^ __Vdfg_Regularize_902)
                              : __Vdfg_Regularize_902);
    __Vdfg_Regularize_1027 = ((__Vdfg_Regularize_1026 
                               << 1U) | (1U & (vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_4__DOT__u_crc_parallel_full__DOT__reg_data 
                                               >> 9U)));
    __Vdfg_Regularize_904 = ((__Vdfg_Regularize_903 
                              << 1U) | (1U & (vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_4__DOT__u_crc_parallel_full__DOT__reg_data 
                                              >> 9U)));
    __Vdfg_Regularize_1028 = ((__Vdfg_Regularize_1026 
                               >> 0x0000001fU) ? (0x04c11db7U 
                                                  ^ __Vdfg_Regularize_1027)
                               : __Vdfg_Regularize_1027);
    __Vdfg_Regularize_905 = ((__Vdfg_Regularize_903 
                              >> 0x0000001fU) ? (0x04c11db7U 
                                                 ^ __Vdfg_Regularize_904)
                              : __Vdfg_Regularize_904);
    __Vdfg_Regularize_1029 = ((__Vdfg_Regularize_1028 
                               << 1U) | (1U & (vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_4__DOT__u_crc_parallel_full__DOT__reg_data 
                                               >> 0x0000000aU)));
    __Vdfg_Regularize_906 = ((__Vdfg_Regularize_905 
                              << 1U) | (1U & (vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_4__DOT__u_crc_parallel_full__DOT__reg_data 
                                              >> 0x0000000aU)));
    __Vdfg_Regularize_1030 = ((__Vdfg_Regularize_1028 
                               >> 0x0000001fU) ? (0x04c11db7U 
                                                  ^ __Vdfg_Regularize_1029)
                               : __Vdfg_Regularize_1029);
    __Vdfg_Regularize_907 = ((__Vdfg_Regularize_905 
                              >> 0x0000001fU) ? (0x04c11db7U 
                                                 ^ __Vdfg_Regularize_906)
                              : __Vdfg_Regularize_906);
    __Vdfg_Regularize_1031 = ((__Vdfg_Regularize_1030 
                               << 1U) | (1U & (vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_4__DOT__u_crc_parallel_full__DOT__reg_data 
                                               >> 0x0000000bU)));
    __Vdfg_Regularize_908 = ((__Vdfg_Regularize_907 
                              << 1U) | (1U & (vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_4__DOT__u_crc_parallel_full__DOT__reg_data 
                                              >> 0x0000000bU)));
    __Vdfg_Regularize_1032 = ((__Vdfg_Regularize_1030 
                               >> 0x0000001fU) ? (0x04c11db7U 
                                                  ^ __Vdfg_Regularize_1031)
                               : __Vdfg_Regularize_1031);
    __Vdfg_Regularize_909 = ((__Vdfg_Regularize_907 
                              >> 0x0000001fU) ? (0x04c11db7U 
                                                 ^ __Vdfg_Regularize_908)
                              : __Vdfg_Regularize_908);
    __Vdfg_Regularize_1033 = ((__Vdfg_Regularize_1032 
                               << 1U) | (1U & (vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_4__DOT__u_crc_parallel_full__DOT__reg_data 
                                               >> 0x0000000cU)));
    __Vdfg_Regularize_910 = ((__Vdfg_Regularize_909 
                              << 1U) | (1U & (vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_4__DOT__u_crc_parallel_full__DOT__reg_data 
                                              >> 0x0000000cU)));
    __Vdfg_Regularize_1034 = ((__Vdfg_Regularize_1032 
                               >> 0x0000001fU) ? (0x04c11db7U 
                                                  ^ __Vdfg_Regularize_1033)
                               : __Vdfg_Regularize_1033);
    __Vdfg_Regularize_911 = ((__Vdfg_Regularize_909 
                              >> 0x0000001fU) ? (0x04c11db7U 
                                                 ^ __Vdfg_Regularize_910)
                              : __Vdfg_Regularize_910);
    __Vdfg_Regularize_1035 = ((__Vdfg_Regularize_1034 
                               << 1U) | (1U & (vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_4__DOT__u_crc_parallel_full__DOT__reg_data 
                                               >> 0x0000000dU)));
    __Vdfg_Regularize_912 = ((__Vdfg_Regularize_911 
                              << 1U) | (1U & (vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_4__DOT__u_crc_parallel_full__DOT__reg_data 
                                              >> 0x0000000dU)));
    __Vdfg_Regularize_1036 = ((__Vdfg_Regularize_1034 
                               >> 0x0000001fU) ? (0x04c11db7U 
                                                  ^ __Vdfg_Regularize_1035)
                               : __Vdfg_Regularize_1035);
    __Vdfg_Regularize_913 = ((__Vdfg_Regularize_911 
                              >> 0x0000001fU) ? (0x04c11db7U 
                                                 ^ __Vdfg_Regularize_912)
                              : __Vdfg_Regularize_912);
    __Vdfg_Regularize_1037 = ((__Vdfg_Regularize_1036 
                               << 1U) | (1U & (vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_4__DOT__u_crc_parallel_full__DOT__reg_data 
                                               >> 0x0000000eU)));
    __Vdfg_Regularize_914 = ((__Vdfg_Regularize_913 
                              << 1U) | (1U & (vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_4__DOT__u_crc_parallel_full__DOT__reg_data 
                                              >> 0x0000000eU)));
    __Vdfg_Regularize_1038 = ((__Vdfg_Regularize_1036 
                               >> 0x0000001fU) ? (0x04c11db7U 
                                                  ^ __Vdfg_Regularize_1037)
                               : __Vdfg_Regularize_1037);
    __Vdfg_Regularize_915 = ((__Vdfg_Regularize_913 
                              >> 0x0000001fU) ? (0x04c11db7U 
                                                 ^ __Vdfg_Regularize_914)
                              : __Vdfg_Regularize_914);
    __Vdfg_Regularize_1039 = ((__Vdfg_Regularize_1038 
                               << 1U) | (1U & (vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_4__DOT__u_crc_parallel_full__DOT__reg_data 
                                               >> 0x0000000fU)));
    __Vdfg_Regularize_916 = ((__Vdfg_Regularize_915 
                              << 1U) | (1U & (vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_4__DOT__u_crc_parallel_full__DOT__reg_data 
                                              >> 0x0000000fU)));
    __Vdfg_Regularize_870 = ((2U & (IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_4__DOT__u_crc_parallel_full__DOT__reg_keep))
                              ? ((__Vdfg_Regularize_1038 
                                  >> 0x0000001fU) ? 
                                 (0x04c11db7U ^ __Vdfg_Regularize_1039)
                                  : __Vdfg_Regularize_1039)
                              : __Vdfg_Regularize_869);
    __Vdfg_Regularize_866 = ((2U & (IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_4__DOT__u_crc_parallel_full__DOT__reg_keep))
                              ? ((__Vdfg_Regularize_915 
                                  >> 0x0000001fU) ? 
                                 (0x04c11db7U ^ __Vdfg_Regularize_916)
                                  : __Vdfg_Regularize_916)
                              : __Vdfg_Regularize_865);
    __Vdfg_Regularize_1040 = ((__Vdfg_Regularize_870 
                               << 1U) | (1U & vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_4__DOT__u_crc_parallel_full__DOT__reg_data));
    __Vdfg_Regularize_917 = ((__Vdfg_Regularize_866 
                              << 1U) | (1U & vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_4__DOT__u_crc_parallel_full__DOT__reg_data));
    __Vdfg_Regularize_1041 = ((__Vdfg_Regularize_870 
                               >> 0x0000001fU) ? (0x04c11db7U 
                                                  ^ __Vdfg_Regularize_1040)
                               : __Vdfg_Regularize_1040);
    __Vdfg_Regularize_918 = ((__Vdfg_Regularize_866 
                              >> 0x0000001fU) ? (0x04c11db7U 
                                                 ^ __Vdfg_Regularize_917)
                              : __Vdfg_Regularize_917);
    __Vdfg_Regularize_1042 = ((__Vdfg_Regularize_1041 
                               << 1U) | (1U & (vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_4__DOT__u_crc_parallel_full__DOT__reg_data 
                                               >> 1U)));
    __Vdfg_Regularize_919 = ((__Vdfg_Regularize_918 
                              << 1U) | (1U & (vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_4__DOT__u_crc_parallel_full__DOT__reg_data 
                                              >> 1U)));
    __Vdfg_Regularize_1043 = ((__Vdfg_Regularize_1041 
                               >> 0x0000001fU) ? (0x04c11db7U 
                                                  ^ __Vdfg_Regularize_1042)
                               : __Vdfg_Regularize_1042);
    __Vdfg_Regularize_920 = ((__Vdfg_Regularize_918 
                              >> 0x0000001fU) ? (0x04c11db7U 
                                                 ^ __Vdfg_Regularize_919)
                              : __Vdfg_Regularize_919);
    __Vdfg_Regularize_1044 = ((__Vdfg_Regularize_1043 
                               << 1U) | (1U & (vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_4__DOT__u_crc_parallel_full__DOT__reg_data 
                                               >> 2U)));
    __Vdfg_Regularize_921 = ((__Vdfg_Regularize_920 
                              << 1U) | (1U & (vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_4__DOT__u_crc_parallel_full__DOT__reg_data 
                                              >> 2U)));
    __Vdfg_Regularize_1045 = ((__Vdfg_Regularize_1043 
                               >> 0x0000001fU) ? (0x04c11db7U 
                                                  ^ __Vdfg_Regularize_1044)
                               : __Vdfg_Regularize_1044);
    __Vdfg_Regularize_922 = ((__Vdfg_Regularize_920 
                              >> 0x0000001fU) ? (0x04c11db7U 
                                                 ^ __Vdfg_Regularize_921)
                              : __Vdfg_Regularize_921);
    __Vdfg_Regularize_1046 = ((__Vdfg_Regularize_1045 
                               << 1U) | (1U & (vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_4__DOT__u_crc_parallel_full__DOT__reg_data 
                                               >> 3U)));
    __Vdfg_Regularize_923 = ((__Vdfg_Regularize_922 
                              << 1U) | (1U & (vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_4__DOT__u_crc_parallel_full__DOT__reg_data 
                                              >> 3U)));
    __Vdfg_Regularize_1047 = ((__Vdfg_Regularize_1045 
                               >> 0x0000001fU) ? (0x04c11db7U 
                                                  ^ __Vdfg_Regularize_1046)
                               : __Vdfg_Regularize_1046);
    __Vdfg_Regularize_924 = ((__Vdfg_Regularize_922 
                              >> 0x0000001fU) ? (0x04c11db7U 
                                                 ^ __Vdfg_Regularize_923)
                              : __Vdfg_Regularize_923);
    __Vdfg_Regularize_1048 = ((__Vdfg_Regularize_1047 
                               << 1U) | (1U & (vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_4__DOT__u_crc_parallel_full__DOT__reg_data 
                                               >> 4U)));
    __Vdfg_Regularize_925 = ((__Vdfg_Regularize_924 
                              << 1U) | (1U & (vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_4__DOT__u_crc_parallel_full__DOT__reg_data 
                                              >> 4U)));
    __Vdfg_Regularize_1049 = ((__Vdfg_Regularize_1047 
                               >> 0x0000001fU) ? (0x04c11db7U 
                                                  ^ __Vdfg_Regularize_1048)
                               : __Vdfg_Regularize_1048);
    __Vdfg_Regularize_926 = ((__Vdfg_Regularize_924 
                              >> 0x0000001fU) ? (0x04c11db7U 
                                                 ^ __Vdfg_Regularize_925)
                              : __Vdfg_Regularize_925);
    __Vdfg_Regularize_1050 = ((__Vdfg_Regularize_1049 
                               << 1U) | (1U & (vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_4__DOT__u_crc_parallel_full__DOT__reg_data 
                                               >> 5U)));
    __Vdfg_Regularize_927 = ((__Vdfg_Regularize_926 
                              << 1U) | (1U & (vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_4__DOT__u_crc_parallel_full__DOT__reg_data 
                                              >> 5U)));
    __Vdfg_Regularize_1051 = ((__Vdfg_Regularize_1049 
                               >> 0x0000001fU) ? (0x04c11db7U 
                                                  ^ __Vdfg_Regularize_1050)
                               : __Vdfg_Regularize_1050);
    __Vdfg_Regularize_928 = ((__Vdfg_Regularize_926 
                              >> 0x0000001fU) ? (0x04c11db7U 
                                                 ^ __Vdfg_Regularize_927)
                              : __Vdfg_Regularize_927);
    __Vdfg_Regularize_1052 = ((__Vdfg_Regularize_1051 
                               << 1U) | (1U & (vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_4__DOT__u_crc_parallel_full__DOT__reg_data 
                                               >> 6U)));
    __Vdfg_Regularize_929 = ((__Vdfg_Regularize_928 
                              << 1U) | (1U & (vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_4__DOT__u_crc_parallel_full__DOT__reg_data 
                                              >> 6U)));
    __Vdfg_Regularize_1053 = ((__Vdfg_Regularize_1051 
                               >> 0x0000001fU) ? (0x04c11db7U 
                                                  ^ __Vdfg_Regularize_1052)
                               : __Vdfg_Regularize_1052);
    __Vdfg_Regularize_930 = ((__Vdfg_Regularize_928 
                              >> 0x0000001fU) ? (0x04c11db7U 
                                                 ^ __Vdfg_Regularize_929)
                              : __Vdfg_Regularize_929);
    __Vdfg_Regularize_1054 = ((__Vdfg_Regularize_1053 
                               << 1U) | (1U & (vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_4__DOT__u_crc_parallel_full__DOT__reg_data 
                                               >> 7U)));
    __Vdfg_Regularize_931 = ((__Vdfg_Regularize_930 
                              << 1U) | (1U & (vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_4__DOT__u_crc_parallel_full__DOT__reg_data 
                                              >> 7U)));
    __Vdfg_Regularize_871 = ((1U & (IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_4__DOT__u_crc_parallel_full__DOT__reg_keep))
                              ? ((__Vdfg_Regularize_1053 
                                  >> 0x0000001fU) ? 
                                 (0x04c11db7U ^ __Vdfg_Regularize_1054)
                                  : __Vdfg_Regularize_1054)
                              : __Vdfg_Regularize_870);
    __Vdfg_Regularize_867 = ((1U & (IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_4__DOT__u_crc_parallel_full__DOT__reg_keep))
                              ? ((__Vdfg_Regularize_930 
                                  >> 0x0000001fU) ? 
                                 (0x04c11db7U ^ __Vdfg_Regularize_931)
                                  : __Vdfg_Regularize_931)
                              : __Vdfg_Regularize_866);
    __Vdfg_Regularize_1055 = ((__Vdfg_Regularize_871 
                               >> 0x0000001fU) ? (1U 
                                                  | (0xfffffffeU 
                                                     & (0x04c11db6U 
                                                        ^ 
                                                        (__Vdfg_Regularize_871 
                                                         << 1U))))
                               : (__Vdfg_Regularize_871 
                                  << 1U));
    __Vdfg_Regularize_932 = ((__Vdfg_Regularize_867 
                              >> 0x0000001fU) ? (1U 
                                                 | (0xfffffffeU 
                                                    & (0x04c11db6U 
                                                       ^ 
                                                       (__Vdfg_Regularize_867 
                                                        << 1U))))
                              : (__Vdfg_Regularize_867 
                                 << 1U));
    __Vdfg_Regularize_1056 = ((__Vdfg_Regularize_1055 
                               >> 0x0000001fU) ? (1U 
                                                  | (0xfffffffeU 
                                                     & (0x04c11db6U 
                                                        ^ 
                                                        (__Vdfg_Regularize_1055 
                                                         << 1U))))
                               : (__Vdfg_Regularize_1055 
                                  << 1U));
    __Vdfg_Regularize_933 = ((__Vdfg_Regularize_932 
                              >> 0x0000001fU) ? (1U 
                                                 | (0xfffffffeU 
                                                    & (0x04c11db6U 
                                                       ^ 
                                                       (__Vdfg_Regularize_932 
                                                        << 1U))))
                              : (__Vdfg_Regularize_932 
                                 << 1U));
    __Vdfg_Regularize_1057 = ((__Vdfg_Regularize_1056 
                               >> 0x0000001fU) ? (1U 
                                                  | (0xfffffffeU 
                                                     & (0x04c11db6U 
                                                        ^ 
                                                        (__Vdfg_Regularize_1056 
                                                         << 1U))))
                               : (__Vdfg_Regularize_1056 
                                  << 1U));
    __Vdfg_Regularize_934 = ((__Vdfg_Regularize_933 
                              >> 0x0000001fU) ? (1U 
                                                 | (0xfffffffeU 
                                                    & (0x04c11db6U 
                                                       ^ 
                                                       (__Vdfg_Regularize_933 
                                                        << 1U))))
                              : (__Vdfg_Regularize_933 
                                 << 1U));
    __Vdfg_Regularize_1058 = ((__Vdfg_Regularize_1057 
                               >> 0x0000001fU) ? (1U 
                                                  | (0xfffffffeU 
                                                     & (0x04c11db6U 
                                                        ^ 
                                                        (__Vdfg_Regularize_1057 
                                                         << 1U))))
                               : (__Vdfg_Regularize_1057 
                                  << 1U));
    __Vdfg_Regularize_935 = ((__Vdfg_Regularize_934 
                              >> 0x0000001fU) ? (1U 
                                                 | (0xfffffffeU 
                                                    & (0x04c11db6U 
                                                       ^ 
                                                       (__Vdfg_Regularize_934 
                                                        << 1U))))
                              : (__Vdfg_Regularize_934 
                                 << 1U));
    __Vdfg_Regularize_1059 = ((__Vdfg_Regularize_1058 
                               >> 0x0000001fU) ? (1U 
                                                  | (0xfffffffeU 
                                                     & (0x04c11db6U 
                                                        ^ 
                                                        (__Vdfg_Regularize_1058 
                                                         << 1U))))
                               : (__Vdfg_Regularize_1058 
                                  << 1U));
    __Vdfg_Regularize_936 = ((__Vdfg_Regularize_935 
                              >> 0x0000001fU) ? (1U 
                                                 | (0xfffffffeU 
                                                    & (0x04c11db6U 
                                                       ^ 
                                                       (__Vdfg_Regularize_935 
                                                        << 1U))))
                              : (__Vdfg_Regularize_935 
                                 << 1U));
    __Vdfg_Regularize_1060 = ((__Vdfg_Regularize_1059 
                               >> 0x0000001fU) ? (1U 
                                                  | (0xfffffffeU 
                                                     & (0x04c11db6U 
                                                        ^ 
                                                        (__Vdfg_Regularize_1059 
                                                         << 1U))))
                               : (__Vdfg_Regularize_1059 
                                  << 1U));
    __Vdfg_Regularize_937 = ((__Vdfg_Regularize_936 
                              >> 0x0000001fU) ? (1U 
                                                 | (0xfffffffeU 
                                                    & (0x04c11db6U 
                                                       ^ 
                                                       (__Vdfg_Regularize_936 
                                                        << 1U))))
                              : (__Vdfg_Regularize_936 
                                 << 1U));
    __Vdfg_Regularize_1061 = ((__Vdfg_Regularize_1060 
                               >> 0x0000001fU) ? (1U 
                                                  | (0xfffffffeU 
                                                     & (0x04c11db6U 
                                                        ^ 
                                                        (__Vdfg_Regularize_1060 
                                                         << 1U))))
                               : (__Vdfg_Regularize_1060 
                                  << 1U));
    __Vdfg_Regularize_938 = ((__Vdfg_Regularize_937 
                              >> 0x0000001fU) ? (1U 
                                                 | (0xfffffffeU 
                                                    & (0x04c11db6U 
                                                       ^ 
                                                       (__Vdfg_Regularize_937 
                                                        << 1U))))
                              : (__Vdfg_Regularize_937 
                                 << 1U));
    __Vdfg_Regularize_1062 = ((__Vdfg_Regularize_1061 
                               >> 0x0000001fU) ? (1U 
                                                  | (0xfffffffeU 
                                                     & (0x04c11db6U 
                                                        ^ 
                                                        (__Vdfg_Regularize_1061 
                                                         << 1U))))
                               : (__Vdfg_Regularize_1061 
                                  << 1U));
    __Vdfg_Regularize_939 = ((__Vdfg_Regularize_938 
                              >> 0x0000001fU) ? (1U 
                                                 | (0xfffffffeU 
                                                    & (0x04c11db6U 
                                                       ^ 
                                                       (__Vdfg_Regularize_938 
                                                        << 1U))))
                              : (__Vdfg_Regularize_938 
                                 << 1U));
    __Vdfg_Regularize_1063 = ((__Vdfg_Regularize_1062 
                               >> 0x0000001fU) ? (1U 
                                                  | (0xfffffffeU 
                                                     & (0x04c11db6U 
                                                        ^ 
                                                        (__Vdfg_Regularize_1062 
                                                         << 1U))))
                               : (__Vdfg_Regularize_1062 
                                  << 1U));
    __Vdfg_Regularize_940 = ((__Vdfg_Regularize_939 
                              >> 0x0000001fU) ? (1U 
                                                 | (0xfffffffeU 
                                                    & (0x04c11db6U 
                                                       ^ 
                                                       (__Vdfg_Regularize_939 
                                                        << 1U))))
                              : (__Vdfg_Regularize_939 
                                 << 1U));
    __Vdfg_Regularize_1064 = ((__Vdfg_Regularize_1063 
                               >> 0x0000001fU) ? (1U 
                                                  | (0xfffffffeU 
                                                     & (0x04c11db6U 
                                                        ^ 
                                                        (__Vdfg_Regularize_1063 
                                                         << 1U))))
                               : (__Vdfg_Regularize_1063 
                                  << 1U));
    __Vdfg_Regularize_941 = ((__Vdfg_Regularize_940 
                              >> 0x0000001fU) ? (1U 
                                                 | (0xfffffffeU 
                                                    & (0x04c11db6U 
                                                       ^ 
                                                       (__Vdfg_Regularize_940 
                                                        << 1U))))
                              : (__Vdfg_Regularize_940 
                                 << 1U));
    __Vdfg_Regularize_1065 = ((__Vdfg_Regularize_1064 
                               >> 0x0000001fU) ? (1U 
                                                  | (0xfffffffeU 
                                                     & (0x04c11db6U 
                                                        ^ 
                                                        (__Vdfg_Regularize_1064 
                                                         << 1U))))
                               : (__Vdfg_Regularize_1064 
                                  << 1U));
    __Vdfg_Regularize_942 = ((__Vdfg_Regularize_941 
                              >> 0x0000001fU) ? (1U 
                                                 | (0xfffffffeU 
                                                    & (0x04c11db6U 
                                                       ^ 
                                                       (__Vdfg_Regularize_941 
                                                        << 1U))))
                              : (__Vdfg_Regularize_941 
                                 << 1U));
    __Vdfg_Regularize_1066 = ((__Vdfg_Regularize_1065 
                               >> 0x0000001fU) ? (1U 
                                                  | (0xfffffffeU 
                                                     & (0x04c11db6U 
                                                        ^ 
                                                        (__Vdfg_Regularize_1065 
                                                         << 1U))))
                               : (__Vdfg_Regularize_1065 
                                  << 1U));
    __Vdfg_Regularize_943 = ((__Vdfg_Regularize_942 
                              >> 0x0000001fU) ? (1U 
                                                 | (0xfffffffeU 
                                                    & (0x04c11db6U 
                                                       ^ 
                                                       (__Vdfg_Regularize_942 
                                                        << 1U))))
                              : (__Vdfg_Regularize_942 
                                 << 1U));
    __Vdfg_Regularize_1067 = ((__Vdfg_Regularize_1066 
                               >> 0x0000001fU) ? (1U 
                                                  | (0xfffffffeU 
                                                     & (0x04c11db6U 
                                                        ^ 
                                                        (__Vdfg_Regularize_1066 
                                                         << 1U))))
                               : (__Vdfg_Regularize_1066 
                                  << 1U));
    __Vdfg_Regularize_944 = ((__Vdfg_Regularize_943 
                              >> 0x0000001fU) ? (1U 
                                                 | (0xfffffffeU 
                                                    & (0x04c11db6U 
                                                       ^ 
                                                       (__Vdfg_Regularize_943 
                                                        << 1U))))
                              : (__Vdfg_Regularize_943 
                                 << 1U));
    __Vdfg_Regularize_1068 = ((__Vdfg_Regularize_1067 
                               >> 0x0000001fU) ? (1U 
                                                  | (0xfffffffeU 
                                                     & (0x04c11db6U 
                                                        ^ 
                                                        (__Vdfg_Regularize_1067 
                                                         << 1U))))
                               : (__Vdfg_Regularize_1067 
                                  << 1U));
    __Vdfg_Regularize_945 = ((__Vdfg_Regularize_944 
                              >> 0x0000001fU) ? (1U 
                                                 | (0xfffffffeU 
                                                    & (0x04c11db6U 
                                                       ^ 
                                                       (__Vdfg_Regularize_944 
                                                        << 1U))))
                              : (__Vdfg_Regularize_944 
                                 << 1U));
    __Vdfg_Regularize_1069 = ((__Vdfg_Regularize_1068 
                               >> 0x0000001fU) ? (1U 
                                                  | (0xfffffffeU 
                                                     & (0x04c11db6U 
                                                        ^ 
                                                        (__Vdfg_Regularize_1068 
                                                         << 1U))))
                               : (__Vdfg_Regularize_1068 
                                  << 1U));
    __Vdfg_Regularize_946 = ((__Vdfg_Regularize_945 
                              >> 0x0000001fU) ? (1U 
                                                 | (0xfffffffeU 
                                                    & (0x04c11db6U 
                                                       ^ 
                                                       (__Vdfg_Regularize_945 
                                                        << 1U))))
                              : (__Vdfg_Regularize_945 
                                 << 1U));
    __Vdfg_Regularize_1070 = ((__Vdfg_Regularize_1069 
                               >> 0x0000001fU) ? (1U 
                                                  | (0xfffffffeU 
                                                     & (0x04c11db6U 
                                                        ^ 
                                                        (__Vdfg_Regularize_1069 
                                                         << 1U))))
                               : (__Vdfg_Regularize_1069 
                                  << 1U));
    __Vdfg_Regularize_947 = ((__Vdfg_Regularize_946 
                              >> 0x0000001fU) ? (1U 
                                                 | (0xfffffffeU 
                                                    & (0x04c11db6U 
                                                       ^ 
                                                       (__Vdfg_Regularize_946 
                                                        << 1U))))
                              : (__Vdfg_Regularize_946 
                                 << 1U));
    __Vdfg_Regularize_1071 = ((__Vdfg_Regularize_1070 
                               >> 0x0000001fU) ? (1U 
                                                  | (0xfffffffeU 
                                                     & (0x04c11db6U 
                                                        ^ 
                                                        (__Vdfg_Regularize_1070 
                                                         << 1U))))
                               : (__Vdfg_Regularize_1070 
                                  << 1U));
    __Vdfg_Regularize_948 = ((__Vdfg_Regularize_947 
                              >> 0x0000001fU) ? (1U 
                                                 | (0xfffffffeU 
                                                    & (0x04c11db6U 
                                                       ^ 
                                                       (__Vdfg_Regularize_947 
                                                        << 1U))))
                              : (__Vdfg_Regularize_947 
                                 << 1U));
    __Vdfg_Regularize_1072 = ((__Vdfg_Regularize_1071 
                               >> 0x0000001fU) ? (1U 
                                                  | (0xfffffffeU 
                                                     & (0x04c11db6U 
                                                        ^ 
                                                        (__Vdfg_Regularize_1071 
                                                         << 1U))))
                               : (__Vdfg_Regularize_1071 
                                  << 1U));
    __Vdfg_Regularize_949 = ((__Vdfg_Regularize_948 
                              >> 0x0000001fU) ? (1U 
                                                 | (0xfffffffeU 
                                                    & (0x04c11db6U 
                                                       ^ 
                                                       (__Vdfg_Regularize_948 
                                                        << 1U))))
                              : (__Vdfg_Regularize_948 
                                 << 1U));
    __Vdfg_Regularize_1073 = ((__Vdfg_Regularize_1072 
                               >> 0x0000001fU) ? (1U 
                                                  | (0xfffffffeU 
                                                     & (0x04c11db6U 
                                                        ^ 
                                                        (__Vdfg_Regularize_1072 
                                                         << 1U))))
                               : (__Vdfg_Regularize_1072 
                                  << 1U));
    __Vdfg_Regularize_950 = ((__Vdfg_Regularize_949 
                              >> 0x0000001fU) ? (1U 
                                                 | (0xfffffffeU 
                                                    & (0x04c11db6U 
                                                       ^ 
                                                       (__Vdfg_Regularize_949 
                                                        << 1U))))
                              : (__Vdfg_Regularize_949 
                                 << 1U));
    __Vdfg_Regularize_1074 = ((__Vdfg_Regularize_1073 
                               >> 0x0000001fU) ? (1U 
                                                  | (0xfffffffeU 
                                                     & (0x04c11db6U 
                                                        ^ 
                                                        (__Vdfg_Regularize_1073 
                                                         << 1U))))
                               : (__Vdfg_Regularize_1073 
                                  << 1U));
    __Vdfg_Regularize_951 = ((__Vdfg_Regularize_950 
                              >> 0x0000001fU) ? (1U 
                                                 | (0xfffffffeU 
                                                    & (0x04c11db6U 
                                                       ^ 
                                                       (__Vdfg_Regularize_950 
                                                        << 1U))))
                              : (__Vdfg_Regularize_950 
                                 << 1U));
    __Vdfg_Regularize_1075 = ((__Vdfg_Regularize_1074 
                               >> 0x0000001fU) ? (1U 
                                                  | (0xfffffffeU 
                                                     & (0x04c11db6U 
                                                        ^ 
                                                        (__Vdfg_Regularize_1074 
                                                         << 1U))))
                               : (__Vdfg_Regularize_1074 
                                  << 1U));
    __Vdfg_Regularize_952 = ((__Vdfg_Regularize_951 
                              >> 0x0000001fU) ? (1U 
                                                 | (0xfffffffeU 
                                                    & (0x04c11db6U 
                                                       ^ 
                                                       (__Vdfg_Regularize_951 
                                                        << 1U))))
                              : (__Vdfg_Regularize_951 
                                 << 1U));
    __Vdfg_Regularize_1076 = ((__Vdfg_Regularize_1075 
                               >> 0x0000001fU) ? (1U 
                                                  | (0xfffffffeU 
                                                     & (0x04c11db6U 
                                                        ^ 
                                                        (__Vdfg_Regularize_1075 
                                                         << 1U))))
                               : (__Vdfg_Regularize_1075 
                                  << 1U));
    __Vdfg_Regularize_953 = ((__Vdfg_Regularize_952 
                              >> 0x0000001fU) ? (1U 
                                                 | (0xfffffffeU 
                                                    & (0x04c11db6U 
                                                       ^ 
                                                       (__Vdfg_Regularize_952 
                                                        << 1U))))
                              : (__Vdfg_Regularize_952 
                                 << 1U));
    __Vdfg_Regularize_1077 = ((__Vdfg_Regularize_1076 
                               >> 0x0000001fU) ? (1U 
                                                  | (0xfffffffeU 
                                                     & (0x04c11db6U 
                                                        ^ 
                                                        (__Vdfg_Regularize_1076 
                                                         << 1U))))
                               : (__Vdfg_Regularize_1076 
                                  << 1U));
    __Vdfg_Regularize_954 = ((__Vdfg_Regularize_953 
                              >> 0x0000001fU) ? (1U 
                                                 | (0xfffffffeU 
                                                    & (0x04c11db6U 
                                                       ^ 
                                                       (__Vdfg_Regularize_953 
                                                        << 1U))))
                              : (__Vdfg_Regularize_953 
                                 << 1U));
    __Vdfg_Regularize_1078 = ((__Vdfg_Regularize_1077 
                               >> 0x0000001fU) ? (1U 
                                                  | (0xfffffffeU 
                                                     & (0x04c11db6U 
                                                        ^ 
                                                        (__Vdfg_Regularize_1077 
                                                         << 1U))))
                               : (__Vdfg_Regularize_1077 
                                  << 1U));
    __Vdfg_Regularize_955 = ((__Vdfg_Regularize_954 
                              >> 0x0000001fU) ? (1U 
                                                 | (0xfffffffeU 
                                                    & (0x04c11db6U 
                                                       ^ 
                                                       (__Vdfg_Regularize_954 
                                                        << 1U))))
                              : (__Vdfg_Regularize_954 
                                 << 1U));
    __Vdfg_Regularize_1079 = ((__Vdfg_Regularize_1078 
                               >> 0x0000001fU) ? (1U 
                                                  | (0xfffffffeU 
                                                     & (0x04c11db6U 
                                                        ^ 
                                                        (__Vdfg_Regularize_1078 
                                                         << 1U))))
                               : (__Vdfg_Regularize_1078 
                                  << 1U));
    __Vdfg_Regularize_956 = ((__Vdfg_Regularize_955 
                              >> 0x0000001fU) ? (1U 
                                                 | (0xfffffffeU 
                                                    & (0x04c11db6U 
                                                       ^ 
                                                       (__Vdfg_Regularize_955 
                                                        << 1U))))
                              : (__Vdfg_Regularize_955 
                                 << 1U));
    __Vdfg_Regularize_1080 = ((__Vdfg_Regularize_1079 
                               >> 0x0000001fU) ? (1U 
                                                  | (0xfffffffeU 
                                                     & (0x04c11db6U 
                                                        ^ 
                                                        (__Vdfg_Regularize_1079 
                                                         << 1U))))
                               : (__Vdfg_Regularize_1079 
                                  << 1U));
    __Vdfg_Regularize_957 = ((__Vdfg_Regularize_956 
                              >> 0x0000001fU) ? (1U 
                                                 | (0xfffffffeU 
                                                    & (0x04c11db6U 
                                                       ^ 
                                                       (__Vdfg_Regularize_956 
                                                        << 1U))))
                              : (__Vdfg_Regularize_956 
                                 << 1U));
    __Vdfg_Regularize_1081 = ((__Vdfg_Regularize_1080 
                               >> 0x0000001fU) ? (1U 
                                                  | (0xfffffffeU 
                                                     & (0x04c11db6U 
                                                        ^ 
                                                        (__Vdfg_Regularize_1080 
                                                         << 1U))))
                               : (__Vdfg_Regularize_1080 
                                  << 1U));
    __Vdfg_Regularize_958 = ((__Vdfg_Regularize_957 
                              >> 0x0000001fU) ? (1U 
                                                 | (0xfffffffeU 
                                                    & (0x04c11db6U 
                                                       ^ 
                                                       (__Vdfg_Regularize_957 
                                                        << 1U))))
                              : (__Vdfg_Regularize_957 
                                 << 1U));
    __Vdfg_Regularize_1082 = ((__Vdfg_Regularize_1081 
                               >> 0x0000001fU) ? (1U 
                                                  | (0xfffffffeU 
                                                     & (0x04c11db6U 
                                                        ^ 
                                                        (__Vdfg_Regularize_1081 
                                                         << 1U))))
                               : (__Vdfg_Regularize_1081 
                                  << 1U));
    __Vdfg_Regularize_959 = ((__Vdfg_Regularize_958 
                              >> 0x0000001fU) ? (1U 
                                                 | (0xfffffffeU 
                                                    & (0x04c11db6U 
                                                       ^ 
                                                       (__Vdfg_Regularize_958 
                                                        << 1U))))
                              : (__Vdfg_Regularize_958 
                                 << 1U));
    __Vdfg_Regularize_1083 = ((__Vdfg_Regularize_1082 
                               >> 0x0000001fU) ? (1U 
                                                  | (0xfffffffeU 
                                                     & (0x04c11db6U 
                                                        ^ 
                                                        (__Vdfg_Regularize_1082 
                                                         << 1U))))
                               : (__Vdfg_Regularize_1082 
                                  << 1U));
    __Vdfg_Regularize_960 = ((__Vdfg_Regularize_959 
                              >> 0x0000001fU) ? (1U 
                                                 | (0xfffffffeU 
                                                    & (0x04c11db6U 
                                                       ^ 
                                                       (__Vdfg_Regularize_959 
                                                        << 1U))))
                              : (__Vdfg_Regularize_959 
                                 << 1U));
    __Vdfg_Regularize_1084 = ((__Vdfg_Regularize_1083 
                               >> 0x0000001fU) ? (1U 
                                                  | (0xfffffffeU 
                                                     & (0x04c11db6U 
                                                        ^ 
                                                        (__Vdfg_Regularize_1083 
                                                         << 1U))))
                               : (__Vdfg_Regularize_1083 
                                  << 1U));
    __Vdfg_Regularize_961 = ((__Vdfg_Regularize_960 
                              >> 0x0000001fU) ? (1U 
                                                 | (0xfffffffeU 
                                                    & (0x04c11db6U 
                                                       ^ 
                                                       (__Vdfg_Regularize_960 
                                                        << 1U))))
                              : (__Vdfg_Regularize_960 
                                 << 1U));
    __Vdfg_Regularize_1085 = ((__Vdfg_Regularize_1084 
                               >> 0x0000001fU) ? (1U 
                                                  | (0xfffffffeU 
                                                     & (0x04c11db6U 
                                                        ^ 
                                                        (__Vdfg_Regularize_1084 
                                                         << 1U))))
                               : (__Vdfg_Regularize_1084 
                                  << 1U));
    __Vdfg_Regularize_962 = ((__Vdfg_Regularize_961 
                              >> 0x0000001fU) ? (1U 
                                                 | (0xfffffffeU 
                                                    & (0x04c11db6U 
                                                       ^ 
                                                       (__Vdfg_Regularize_961 
                                                        << 1U))))
                              : (__Vdfg_Regularize_961 
                                 << 1U));
    vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_4__DOT__u_crc_parallel_full__DOT__w_crc_nxt 
        = ((IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_4__DOT__u_crc_parallel_full__DOT__reg_last)
            ? ((__Vdfg_Regularize_1085 >> 0x0000001fU)
                ? (1U | (0xfffffffeU & (0x04c11db6U 
                                        ^ (__Vdfg_Regularize_1085 
                                           << 1U))))
                : (__Vdfg_Regularize_1085 << 1U)) : __Vdfg_Regularize_871);
    vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_4__DOT__u_crc_parallel_full__DOT__w_crc_nxt 
        = ((IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_4__DOT__u_crc_parallel_full__DOT__reg_last)
            ? ((__Vdfg_Regularize_962 >> 0x0000001fU)
                ? (1U | (0xfffffffeU & (0x04c11db6U 
                                        ^ (__Vdfg_Regularize_962 
                                           << 1U))))
                : (__Vdfg_Regularize_962 << 1U)) : __Vdfg_Regularize_867);
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
