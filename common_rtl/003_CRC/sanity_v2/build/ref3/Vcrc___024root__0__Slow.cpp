// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Design implementation internals
// See Vcrc.h for the primary calling header

#include "Vcrc__pch.h"

VL_ATTR_COLD void Vcrc___024root___eval_static(Vcrc___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vcrc___024root___eval_static\n"); );
    Vcrc__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Body
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
    vlSelfRef.__Vtrigprevexpr___TOP__i_clk_crc__1 = vlSelfRef.i_clk_crc;
}

VL_ATTR_COLD void Vcrc___024root___eval_initial(Vcrc___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vcrc___024root___eval_initial\n"); );
    Vcrc__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
}

#ifdef VL_DEBUG
VL_ATTR_COLD void Vcrc___024root___dump_triggers__stl(const VlUnpacked<QData/*63:0*/, 1> &triggers, const std::string &tag);
#endif  // VL_DEBUG
VL_ATTR_COLD bool Vcrc___024root___trigger_anySet__stl(const VlUnpacked<QData/*63:0*/, 1> &in);
VL_ATTR_COLD void Vcrc___024root___stl_sequent__TOP__0(Vcrc___024root* vlSelf);

VL_ATTR_COLD bool Vcrc___024root___eval_stl(Vcrc___024root* vlSelf, CData/*0:0*/ firstIteration) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vcrc___024root___eval_stl\n"); );
    Vcrc__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Locals
    CData/*0:0*/ __VstlExecute;
    // Body
    vlSelfRef.__VstlTriggered[0U] = ((0xfffffffffffffffeULL 
                                      & vlSelfRef.__VstlTriggered[0U]) 
                                     | (IData)((IData)(firstIteration)));
#ifdef VL_DEBUG
    if (VL_UNLIKELY(vlSymsp->_vm_contextp__->debug())) {
        Vcrc___024root___dump_triggers__stl(vlSelfRef.__VstlTriggered, "stl"s);
    }
#endif
    __VstlExecute = Vcrc___024root___trigger_anySet__stl(vlSelfRef.__VstlTriggered);
    if (__VstlExecute) {
        {
            // Inlined CFunc: _eval_body__stl
            if ((1ULL & vlSelfRef.__VstlTriggered[0U])) {
                Vcrc___024root___stl_sequent__TOP__0(vlSelf);
            }
        }
    }
    return (__VstlExecute);
}

VL_ATTR_COLD void Vcrc___024root___eval_dump_triggers__stl(Vcrc___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vcrc___024root___eval_dump_triggers__stl\n"); );
    Vcrc__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Body
#ifdef VL_DEBUG
    Vcrc___024root___dump_triggers__stl(vlSelfRef.__VstlTriggered, "stl"s);
#endif
}

#ifdef VL_DEBUG
VL_ATTR_COLD void Vcrc___024root___dump_triggers__ico(const VlUnpacked<QData/*63:0*/, 2> &triggers, const std::string &tag);
#endif  // VL_DEBUG

VL_ATTR_COLD void Vcrc___024root___eval_dump_triggers__ico(Vcrc___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vcrc___024root___eval_dump_triggers__ico\n"); );
    Vcrc__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Body
#ifdef VL_DEBUG
    Vcrc___024root___dump_triggers__ico(vlSelfRef.__VicoTriggered, "ico"s);
#endif
}

#ifdef VL_DEBUG
VL_ATTR_COLD void Vcrc___024root___dump_triggers__act(const VlUnpacked<QData/*63:0*/, 1> &triggers, const std::string &tag);
#endif  // VL_DEBUG

VL_ATTR_COLD void Vcrc___024root___eval_dump_triggers__act(Vcrc___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vcrc___024root___eval_dump_triggers__act\n"); );
    Vcrc__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Body
#ifdef VL_DEBUG
    Vcrc___024root___dump_triggers__act(vlSelfRef.__VactTriggered, "act"s);
#endif
}

VL_ATTR_COLD void Vcrc___024root___eval_dump_triggers__nba(Vcrc___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vcrc___024root___eval_dump_triggers__nba\n"); );
    Vcrc__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Body
#ifdef VL_DEBUG
    Vcrc___024root___dump_triggers__act(vlSelfRef.__VnbaTriggered, "nba"s);
#endif
}

VL_ATTR_COLD void Vcrc___024root___eval_dump_triggers__obs(Vcrc___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vcrc___024root___eval_dump_triggers__obs\n"); );
    Vcrc__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
}

VL_ATTR_COLD void Vcrc___024root___eval_dump_triggers__react(Vcrc___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vcrc___024root___eval_dump_triggers__react\n"); );
    Vcrc__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
}

VL_ATTR_COLD void Vcrc___024root___eval_final(Vcrc___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vcrc___024root___eval_final\n"); );
    Vcrc__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
}

#ifdef VL_DEBUG
VL_ATTR_COLD void Vcrc___024root___dump_triggers__stl(const VlUnpacked<QData/*63:0*/, 1> &triggers, const std::string &tag) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vcrc___024root___dump_triggers__stl\n"); );
    // Body
    if ((1U & (~ (IData)(Vcrc___024root___trigger_anySet__stl(triggers))))) {
        VL_DBG_MSGS("         No '" + tag + "' region triggers active\n");
    }
    if ((1U & (IData)(triggers[0U]))) {
        VL_DBG_MSGS("         '" + tag + "' region trigger index 0 is active: Internal 'stl' trigger - first iteration\n");
    }
}
#endif  // VL_DEBUG

VL_ATTR_COLD bool Vcrc___024root___trigger_anySet__stl(const VlUnpacked<QData/*63:0*/, 1> &in) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vcrc___024root___trigger_anySet__stl\n"); );
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

VL_ATTR_COLD void Vcrc___024root___stl_sequent__TOP__0(Vcrc___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vcrc___024root___stl_sequent__TOP__0\n"); );
    Vcrc__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Locals
    CData/*7:0*/ __Vdfg_Regularize_564;
    __Vdfg_Regularize_564 = 0;
    CData/*7:0*/ __Vdfg_Regularize_566;
    __Vdfg_Regularize_566 = 0;
    CData/*7:0*/ __Vdfg_Regularize_568;
    __Vdfg_Regularize_568 = 0;
    CData/*7:0*/ __Vdfg_Regularize_570;
    __Vdfg_Regularize_570 = 0;
    CData/*7:0*/ __Vdfg_Regularize_572;
    __Vdfg_Regularize_572 = 0;
    CData/*7:0*/ __Vdfg_Regularize_574;
    __Vdfg_Regularize_574 = 0;
    CData/*7:0*/ __Vdfg_Regularize_576;
    __Vdfg_Regularize_576 = 0;
    CData/*7:0*/ __Vdfg_Regularize_579;
    __Vdfg_Regularize_579 = 0;
    CData/*7:0*/ __Vdfg_Regularize_581;
    __Vdfg_Regularize_581 = 0;
    CData/*7:0*/ __Vdfg_Regularize_583;
    __Vdfg_Regularize_583 = 0;
    CData/*7:0*/ __Vdfg_Regularize_585;
    __Vdfg_Regularize_585 = 0;
    CData/*7:0*/ __Vdfg_Regularize_587;
    __Vdfg_Regularize_587 = 0;
    CData/*7:0*/ __Vdfg_Regularize_589;
    __Vdfg_Regularize_589 = 0;
    CData/*7:0*/ __Vdfg_Regularize_591;
    __Vdfg_Regularize_591 = 0;
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
    // Body
    vlSelfRef.o_gen_crc_valid = vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_3__DOT__u_crc_parallel_crcw__DOT__reg_crc_valid;
    vlSelfRef.o_check_crc_valid = vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_3__DOT__u_crc_parallel_crcw__DOT__reg_crc_valid;
    vlSelfRef.o_gen_crc = vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_3__DOT__u_crc_parallel_crcw__DOT__reg_crc_output;
    vlSelfRef.o_gen_data_ready = ((~ ((IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_3__DOT__u_crc_parallel_crcw__DOT__reg_busy) 
                                      | (IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_3__DOT__u_crc_parallel_crcw__DOT__reg_crc_valid))) 
                                  & (IData)(vlSelfRef.i_rst_n_crc));
    vlSelfRef.o_check_data_ready = ((~ ((IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_3__DOT__u_crc_parallel_crcw__DOT__reg_busy) 
                                        | (IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_3__DOT__u_crc_parallel_crcw__DOT__reg_crc_valid))) 
                                    & (IData)(vlSelfRef.i_rst_n_crc));
    vlSelfRef.o_check_pass = ((IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_3__DOT__u_crc_parallel_crcw__DOT__reg_crc_valid) 
                              & ((IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__reg_check_crc_ref) 
                                 == (IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_3__DOT__u_crc_parallel_crcw__DOT__reg_crc_output)));
    __Vdfg_Regularize_602 = ((0x00000080U & (IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_3__DOT__u_crc_parallel_crcw__DOT__reg_crc_state))
                              ? (1U | (0x000000feU 
                                       & (6U ^ (0x000000feU 
                                                & ((IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_3__DOT__u_crc_parallel_crcw__DOT__reg_crc_state) 
                                                   << 1U)))))
                              : (0x000000feU & ((IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_3__DOT__u_crc_parallel_crcw__DOT__reg_crc_state) 
                                                << 1U)));
    __Vdfg_Regularize_625 = ((0x00000080U & (IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_3__DOT__u_crc_parallel_crcw__DOT__reg_crc_state))
                              ? (1U | (0x000000feU 
                                       & (6U ^ (0x000000feU 
                                                & ((IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_3__DOT__u_crc_parallel_crcw__DOT__reg_crc_state) 
                                                   << 1U)))))
                              : (0x000000feU & ((IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_3__DOT__u_crc_parallel_crcw__DOT__reg_crc_state) 
                                                << 1U)));
    __Vdfg_Regularize_594 = ((0x000000feU & ((IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_3__DOT__u_crc_parallel_crcw__DOT__reg_crc_state) 
                                             << 1U)) 
                             | (1U & (vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_3__DOT__u_crc_parallel_crcw__DOT__reg_data 
                                      >> (0x0000001fU 
                                          & ((7U & (IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_3__DOT__u_crc_parallel_crcw__DOT__reg_chunk_idx)) 
                                             + (0x00000018U 
                                                & (((IData)(3U) 
                                                    - 
                                                    ((IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_3__DOT__u_crc_parallel_crcw__DOT__reg_chunk_idx) 
                                                     >> 3U)) 
                                                   << 3U)))))));
    __Vdfg_Regularize_617 = ((0x000000feU & ((IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_3__DOT__u_crc_parallel_crcw__DOT__reg_crc_state) 
                                             << 1U)) 
                             | (1U & (vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_3__DOT__u_crc_parallel_crcw__DOT__reg_data 
                                      >> (0x0000001fU 
                                          & ((7U & (IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_3__DOT__u_crc_parallel_crcw__DOT__reg_chunk_idx)) 
                                             + (0x00000018U 
                                                & (((IData)(3U) 
                                                    - 
                                                    ((IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_3__DOT__u_crc_parallel_crcw__DOT__reg_chunk_idx) 
                                                     >> 3U)) 
                                                   << 3U)))))));
    vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_3__DOT__u_crc_parallel_crcw__DOT__w_valid_bit_cnt 
        = (0x0000003fU & ((8U & (IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_3__DOT__u_crc_parallel_crcw__DOT__reg_keep))
                           ? (((IData)(1U) + VL_COUNTONES_I(
                                                            (7U 
                                                             & (IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_3__DOT__u_crc_parallel_crcw__DOT__reg_keep)))) 
                              << 3U) : (VL_COUNTONES_I(
                                                       (7U 
                                                        & (IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_3__DOT__u_crc_parallel_crcw__DOT__reg_keep))) 
                                        << 3U)));
    vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_3__DOT__u_crc_parallel_crcw__DOT__w_valid_bit_cnt 
        = (0x0000003fU & ((8U & (IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_3__DOT__u_crc_parallel_crcw__DOT__reg_keep))
                           ? (((IData)(1U) + VL_COUNTONES_I(
                                                            (7U 
                                                             & (IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_3__DOT__u_crc_parallel_crcw__DOT__reg_keep)))) 
                              << 3U) : (VL_COUNTONES_I(
                                                       (7U 
                                                        & (IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_3__DOT__u_crc_parallel_crcw__DOT__reg_keep))) 
                                        << 3U)));
    __Vdfg_Regularize_603 = ((0x00000080U & (IData)(__Vdfg_Regularize_602))
                              ? (1U | (0x000000feU 
                                       & (6U ^ (0x000000feU 
                                                & ((IData)(__Vdfg_Regularize_602) 
                                                   << 1U)))))
                              : (0x000000feU & ((IData)(__Vdfg_Regularize_602) 
                                                << 1U)));
    __Vdfg_Regularize_626 = ((0x00000080U & (IData)(__Vdfg_Regularize_625))
                              ? (1U | (0x000000feU 
                                       & (6U ^ (0x000000feU 
                                                & ((IData)(__Vdfg_Regularize_625) 
                                                   << 1U)))))
                              : (0x000000feU & ((IData)(__Vdfg_Regularize_625) 
                                                << 1U)));
    __Vdfg_Regularize_564 = (((IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_3__DOT__u_crc_parallel_crcw__DOT__reg_chunk_idx) 
                              < (IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_3__DOT__u_crc_parallel_crcw__DOT__w_valid_bit_cnt))
                              ? ((0x00000080U & (IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_3__DOT__u_crc_parallel_crcw__DOT__reg_crc_state))
                                  ? (7U ^ (IData)(__Vdfg_Regularize_594))
                                  : (IData)(__Vdfg_Regularize_594))
                              : (IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_3__DOT__u_crc_parallel_crcw__DOT__reg_crc_state));
    __Vdfg_Regularize_579 = (((IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_3__DOT__u_crc_parallel_crcw__DOT__reg_chunk_idx) 
                              < (IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_3__DOT__u_crc_parallel_crcw__DOT__w_valid_bit_cnt))
                              ? ((0x00000080U & (IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_3__DOT__u_crc_parallel_crcw__DOT__reg_crc_state))
                                  ? (7U ^ (IData)(__Vdfg_Regularize_617))
                                  : (IData)(__Vdfg_Regularize_617))
                              : (IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_3__DOT__u_crc_parallel_crcw__DOT__reg_crc_state));
    __Vdfg_Regularize_604 = ((0x00000080U & (IData)(__Vdfg_Regularize_603))
                              ? (1U | (0x000000feU 
                                       & (6U ^ (0x000000feU 
                                                & ((IData)(__Vdfg_Regularize_603) 
                                                   << 1U)))))
                              : (0x000000feU & ((IData)(__Vdfg_Regularize_603) 
                                                << 1U)));
    __Vdfg_Regularize_627 = ((0x00000080U & (IData)(__Vdfg_Regularize_626))
                              ? (1U | (0x000000feU 
                                       & (6U ^ (0x000000feU 
                                                & ((IData)(__Vdfg_Regularize_626) 
                                                   << 1U)))))
                              : (0x000000feU & ((IData)(__Vdfg_Regularize_626) 
                                                << 1U)));
    __Vdfg_Regularize_595 = ((0x000000feU & ((IData)(__Vdfg_Regularize_564) 
                                             << 1U)) 
                             | (1U & (vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_3__DOT__u_crc_parallel_crcw__DOT__reg_data 
                                      >> (0x0000001fU 
                                          & ((7U & 
                                              ((IData)(1U) 
                                               + (IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_3__DOT__u_crc_parallel_crcw__DOT__reg_chunk_idx))) 
                                             + (0x00000018U 
                                                & (((IData)(3U) 
                                                    - 
                                                    (3U 
                                                     & (((IData)(1U) 
                                                         + (IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_3__DOT__u_crc_parallel_crcw__DOT__reg_chunk_idx)) 
                                                        >> 3U))) 
                                                   << 3U)))))));
    __Vdfg_Regularize_618 = ((0x000000feU & ((IData)(__Vdfg_Regularize_579) 
                                             << 1U)) 
                             | (1U & (vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_3__DOT__u_crc_parallel_crcw__DOT__reg_data 
                                      >> (0x0000001fU 
                                          & ((7U & 
                                              ((IData)(1U) 
                                               + (IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_3__DOT__u_crc_parallel_crcw__DOT__reg_chunk_idx))) 
                                             + (0x00000018U 
                                                & (((IData)(3U) 
                                                    - 
                                                    (3U 
                                                     & (((IData)(1U) 
                                                         + (IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_3__DOT__u_crc_parallel_crcw__DOT__reg_chunk_idx)) 
                                                        >> 3U))) 
                                                   << 3U)))))));
    __Vdfg_Regularize_605 = ((0x00000080U & (IData)(__Vdfg_Regularize_604))
                              ? (1U | (0x000000feU 
                                       & (6U ^ (0x000000feU 
                                                & ((IData)(__Vdfg_Regularize_604) 
                                                   << 1U)))))
                              : (0x000000feU & ((IData)(__Vdfg_Regularize_604) 
                                                << 1U)));
    __Vdfg_Regularize_628 = ((0x00000080U & (IData)(__Vdfg_Regularize_627))
                              ? (1U | (0x000000feU 
                                       & (6U ^ (0x000000feU 
                                                & ((IData)(__Vdfg_Regularize_627) 
                                                   << 1U)))))
                              : (0x000000feU & ((IData)(__Vdfg_Regularize_627) 
                                                << 1U)));
    __Vdfg_Regularize_566 = (((0x0000003fU & ((IData)(1U) 
                                              + (IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_3__DOT__u_crc_parallel_crcw__DOT__reg_chunk_idx))) 
                              < (IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_3__DOT__u_crc_parallel_crcw__DOT__w_valid_bit_cnt))
                              ? ((0x00000080U & (IData)(__Vdfg_Regularize_564))
                                  ? (7U ^ (IData)(__Vdfg_Regularize_595))
                                  : (IData)(__Vdfg_Regularize_595))
                              : (IData)(__Vdfg_Regularize_564));
    __Vdfg_Regularize_581 = (((0x0000003fU & ((IData)(1U) 
                                              + (IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_3__DOT__u_crc_parallel_crcw__DOT__reg_chunk_idx))) 
                              < (IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_3__DOT__u_crc_parallel_crcw__DOT__w_valid_bit_cnt))
                              ? ((0x00000080U & (IData)(__Vdfg_Regularize_579))
                                  ? (7U ^ (IData)(__Vdfg_Regularize_618))
                                  : (IData)(__Vdfg_Regularize_618))
                              : (IData)(__Vdfg_Regularize_579));
    __Vdfg_Regularize_606 = ((0x00000080U & (IData)(__Vdfg_Regularize_605))
                              ? (1U | (0x000000feU 
                                       & (6U ^ (0x000000feU 
                                                & ((IData)(__Vdfg_Regularize_605) 
                                                   << 1U)))))
                              : (0x000000feU & ((IData)(__Vdfg_Regularize_605) 
                                                << 1U)));
    __Vdfg_Regularize_629 = ((0x00000080U & (IData)(__Vdfg_Regularize_628))
                              ? (1U | (0x000000feU 
                                       & (6U ^ (0x000000feU 
                                                & ((IData)(__Vdfg_Regularize_628) 
                                                   << 1U)))))
                              : (0x000000feU & ((IData)(__Vdfg_Regularize_628) 
                                                << 1U)));
    __Vdfg_Regularize_596 = ((0x000000feU & ((IData)(__Vdfg_Regularize_566) 
                                             << 1U)) 
                             | (1U & (vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_3__DOT__u_crc_parallel_crcw__DOT__reg_data 
                                      >> (0x0000001fU 
                                          & ((7U & 
                                              ((IData)(2U) 
                                               + (IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_3__DOT__u_crc_parallel_crcw__DOT__reg_chunk_idx))) 
                                             + (0x00000018U 
                                                & (((IData)(3U) 
                                                    - 
                                                    (3U 
                                                     & (((IData)(2U) 
                                                         + (IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_3__DOT__u_crc_parallel_crcw__DOT__reg_chunk_idx)) 
                                                        >> 3U))) 
                                                   << 3U)))))));
    __Vdfg_Regularize_619 = ((0x000000feU & ((IData)(__Vdfg_Regularize_581) 
                                             << 1U)) 
                             | (1U & (vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_3__DOT__u_crc_parallel_crcw__DOT__reg_data 
                                      >> (0x0000001fU 
                                          & ((7U & 
                                              ((IData)(2U) 
                                               + (IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_3__DOT__u_crc_parallel_crcw__DOT__reg_chunk_idx))) 
                                             + (0x00000018U 
                                                & (((IData)(3U) 
                                                    - 
                                                    (3U 
                                                     & (((IData)(2U) 
                                                         + (IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_3__DOT__u_crc_parallel_crcw__DOT__reg_chunk_idx)) 
                                                        >> 3U))) 
                                                   << 3U)))))));
    __Vdfg_Regularize_607 = ((0x00000080U & (IData)(__Vdfg_Regularize_606))
                              ? (1U | (0x000000feU 
                                       & (6U ^ (0x000000feU 
                                                & ((IData)(__Vdfg_Regularize_606) 
                                                   << 1U)))))
                              : (0x000000feU & ((IData)(__Vdfg_Regularize_606) 
                                                << 1U)));
    __Vdfg_Regularize_630 = ((0x00000080U & (IData)(__Vdfg_Regularize_629))
                              ? (1U | (0x000000feU 
                                       & (6U ^ (0x000000feU 
                                                & ((IData)(__Vdfg_Regularize_629) 
                                                   << 1U)))))
                              : (0x000000feU & ((IData)(__Vdfg_Regularize_629) 
                                                << 1U)));
    __Vdfg_Regularize_568 = (((0x0000003fU & ((IData)(2U) 
                                              + (IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_3__DOT__u_crc_parallel_crcw__DOT__reg_chunk_idx))) 
                              < (IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_3__DOT__u_crc_parallel_crcw__DOT__w_valid_bit_cnt))
                              ? ((0x00000080U & (IData)(__Vdfg_Regularize_566))
                                  ? (7U ^ (IData)(__Vdfg_Regularize_596))
                                  : (IData)(__Vdfg_Regularize_596))
                              : (IData)(__Vdfg_Regularize_566));
    __Vdfg_Regularize_583 = (((0x0000003fU & ((IData)(2U) 
                                              + (IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_3__DOT__u_crc_parallel_crcw__DOT__reg_chunk_idx))) 
                              < (IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_3__DOT__u_crc_parallel_crcw__DOT__w_valid_bit_cnt))
                              ? ((0x00000080U & (IData)(__Vdfg_Regularize_581))
                                  ? (7U ^ (IData)(__Vdfg_Regularize_619))
                                  : (IData)(__Vdfg_Regularize_619))
                              : (IData)(__Vdfg_Regularize_581));
    __Vdfg_Regularize_608 = ((0x00000080U & (IData)(__Vdfg_Regularize_607))
                              ? (1U | (0x000000feU 
                                       & (6U ^ (0x000000feU 
                                                & ((IData)(__Vdfg_Regularize_607) 
                                                   << 1U)))))
                              : (0x000000feU & ((IData)(__Vdfg_Regularize_607) 
                                                << 1U)));
    __Vdfg_Regularize_631 = ((0x00000080U & (IData)(__Vdfg_Regularize_630))
                              ? (1U | (0x000000feU 
                                       & (6U ^ (0x000000feU 
                                                & ((IData)(__Vdfg_Regularize_630) 
                                                   << 1U)))))
                              : (0x000000feU & ((IData)(__Vdfg_Regularize_630) 
                                                << 1U)));
    __Vdfg_Regularize_597 = ((0x000000feU & ((IData)(__Vdfg_Regularize_568) 
                                             << 1U)) 
                             | (1U & (vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_3__DOT__u_crc_parallel_crcw__DOT__reg_data 
                                      >> (0x0000001fU 
                                          & ((7U & 
                                              ((IData)(3U) 
                                               + (IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_3__DOT__u_crc_parallel_crcw__DOT__reg_chunk_idx))) 
                                             + (0x00000018U 
                                                & (((IData)(3U) 
                                                    - 
                                                    (3U 
                                                     & (((IData)(3U) 
                                                         + (IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_3__DOT__u_crc_parallel_crcw__DOT__reg_chunk_idx)) 
                                                        >> 3U))) 
                                                   << 3U)))))));
    __Vdfg_Regularize_620 = ((0x000000feU & ((IData)(__Vdfg_Regularize_583) 
                                             << 1U)) 
                             | (1U & (vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_3__DOT__u_crc_parallel_crcw__DOT__reg_data 
                                      >> (0x0000001fU 
                                          & ((7U & 
                                              ((IData)(3U) 
                                               + (IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_3__DOT__u_crc_parallel_crcw__DOT__reg_chunk_idx))) 
                                             + (0x00000018U 
                                                & (((IData)(3U) 
                                                    - 
                                                    (3U 
                                                     & (((IData)(3U) 
                                                         + (IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_3__DOT__u_crc_parallel_crcw__DOT__reg_chunk_idx)) 
                                                        >> 3U))) 
                                                   << 3U)))))));
    __Vdfg_Regularize_570 = (((0x0000003fU & ((IData)(3U) 
                                              + (IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_3__DOT__u_crc_parallel_crcw__DOT__reg_chunk_idx))) 
                              < (IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_3__DOT__u_crc_parallel_crcw__DOT__w_valid_bit_cnt))
                              ? ((0x00000080U & (IData)(__Vdfg_Regularize_568))
                                  ? (7U ^ (IData)(__Vdfg_Regularize_597))
                                  : (IData)(__Vdfg_Regularize_597))
                              : (IData)(__Vdfg_Regularize_568));
    __Vdfg_Regularize_585 = (((0x0000003fU & ((IData)(3U) 
                                              + (IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_3__DOT__u_crc_parallel_crcw__DOT__reg_chunk_idx))) 
                              < (IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_3__DOT__u_crc_parallel_crcw__DOT__w_valid_bit_cnt))
                              ? ((0x00000080U & (IData)(__Vdfg_Regularize_583))
                                  ? (7U ^ (IData)(__Vdfg_Regularize_620))
                                  : (IData)(__Vdfg_Regularize_620))
                              : (IData)(__Vdfg_Regularize_583));
    __Vdfg_Regularize_598 = ((0x000000feU & ((IData)(__Vdfg_Regularize_570) 
                                             << 1U)) 
                             | (1U & (vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_3__DOT__u_crc_parallel_crcw__DOT__reg_data 
                                      >> (0x0000001fU 
                                          & ((7U & 
                                              ((IData)(4U) 
                                               + (IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_3__DOT__u_crc_parallel_crcw__DOT__reg_chunk_idx))) 
                                             + (0x00000018U 
                                                & (((IData)(3U) 
                                                    - 
                                                    (3U 
                                                     & (((IData)(4U) 
                                                         + (IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_3__DOT__u_crc_parallel_crcw__DOT__reg_chunk_idx)) 
                                                        >> 3U))) 
                                                   << 3U)))))));
    __Vdfg_Regularize_621 = ((0x000000feU & ((IData)(__Vdfg_Regularize_585) 
                                             << 1U)) 
                             | (1U & (vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_3__DOT__u_crc_parallel_crcw__DOT__reg_data 
                                      >> (0x0000001fU 
                                          & ((7U & 
                                              ((IData)(4U) 
                                               + (IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_3__DOT__u_crc_parallel_crcw__DOT__reg_chunk_idx))) 
                                             + (0x00000018U 
                                                & (((IData)(3U) 
                                                    - 
                                                    (3U 
                                                     & (((IData)(4U) 
                                                         + (IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_3__DOT__u_crc_parallel_crcw__DOT__reg_chunk_idx)) 
                                                        >> 3U))) 
                                                   << 3U)))))));
    __Vdfg_Regularize_572 = (((0x0000003fU & ((IData)(4U) 
                                              + (IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_3__DOT__u_crc_parallel_crcw__DOT__reg_chunk_idx))) 
                              < (IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_3__DOT__u_crc_parallel_crcw__DOT__w_valid_bit_cnt))
                              ? ((0x00000080U & (IData)(__Vdfg_Regularize_570))
                                  ? (7U ^ (IData)(__Vdfg_Regularize_598))
                                  : (IData)(__Vdfg_Regularize_598))
                              : (IData)(__Vdfg_Regularize_570));
    __Vdfg_Regularize_587 = (((0x0000003fU & ((IData)(4U) 
                                              + (IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_3__DOT__u_crc_parallel_crcw__DOT__reg_chunk_idx))) 
                              < (IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_3__DOT__u_crc_parallel_crcw__DOT__w_valid_bit_cnt))
                              ? ((0x00000080U & (IData)(__Vdfg_Regularize_585))
                                  ? (7U ^ (IData)(__Vdfg_Regularize_621))
                                  : (IData)(__Vdfg_Regularize_621))
                              : (IData)(__Vdfg_Regularize_585));
    __Vdfg_Regularize_599 = ((0x000000feU & ((IData)(__Vdfg_Regularize_572) 
                                             << 1U)) 
                             | (1U & (vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_3__DOT__u_crc_parallel_crcw__DOT__reg_data 
                                      >> (0x0000001fU 
                                          & ((7U & 
                                              ((IData)(5U) 
                                               + (IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_3__DOT__u_crc_parallel_crcw__DOT__reg_chunk_idx))) 
                                             + (0x00000018U 
                                                & (((IData)(3U) 
                                                    - 
                                                    (3U 
                                                     & (((IData)(5U) 
                                                         + (IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_3__DOT__u_crc_parallel_crcw__DOT__reg_chunk_idx)) 
                                                        >> 3U))) 
                                                   << 3U)))))));
    __Vdfg_Regularize_622 = ((0x000000feU & ((IData)(__Vdfg_Regularize_587) 
                                             << 1U)) 
                             | (1U & (vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_3__DOT__u_crc_parallel_crcw__DOT__reg_data 
                                      >> (0x0000001fU 
                                          & ((7U & 
                                              ((IData)(5U) 
                                               + (IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_3__DOT__u_crc_parallel_crcw__DOT__reg_chunk_idx))) 
                                             + (0x00000018U 
                                                & (((IData)(3U) 
                                                    - 
                                                    (3U 
                                                     & (((IData)(5U) 
                                                         + (IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_3__DOT__u_crc_parallel_crcw__DOT__reg_chunk_idx)) 
                                                        >> 3U))) 
                                                   << 3U)))))));
    __Vdfg_Regularize_574 = (((0x0000003fU & ((IData)(5U) 
                                              + (IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_3__DOT__u_crc_parallel_crcw__DOT__reg_chunk_idx))) 
                              < (IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_3__DOT__u_crc_parallel_crcw__DOT__w_valid_bit_cnt))
                              ? ((0x00000080U & (IData)(__Vdfg_Regularize_572))
                                  ? (7U ^ (IData)(__Vdfg_Regularize_599))
                                  : (IData)(__Vdfg_Regularize_599))
                              : (IData)(__Vdfg_Regularize_572));
    __Vdfg_Regularize_589 = (((0x0000003fU & ((IData)(5U) 
                                              + (IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_3__DOT__u_crc_parallel_crcw__DOT__reg_chunk_idx))) 
                              < (IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_3__DOT__u_crc_parallel_crcw__DOT__w_valid_bit_cnt))
                              ? ((0x00000080U & (IData)(__Vdfg_Regularize_587))
                                  ? (7U ^ (IData)(__Vdfg_Regularize_622))
                                  : (IData)(__Vdfg_Regularize_622))
                              : (IData)(__Vdfg_Regularize_587));
    __Vdfg_Regularize_600 = ((0x000000feU & ((IData)(__Vdfg_Regularize_574) 
                                             << 1U)) 
                             | (1U & (vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_3__DOT__u_crc_parallel_crcw__DOT__reg_data 
                                      >> (0x0000001fU 
                                          & ((7U & 
                                              ((IData)(6U) 
                                               + (IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_3__DOT__u_crc_parallel_crcw__DOT__reg_chunk_idx))) 
                                             + (0x00000018U 
                                                & (((IData)(3U) 
                                                    - 
                                                    (3U 
                                                     & (((IData)(6U) 
                                                         + (IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_3__DOT__u_crc_parallel_crcw__DOT__reg_chunk_idx)) 
                                                        >> 3U))) 
                                                   << 3U)))))));
    __Vdfg_Regularize_623 = ((0x000000feU & ((IData)(__Vdfg_Regularize_589) 
                                             << 1U)) 
                             | (1U & (vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_3__DOT__u_crc_parallel_crcw__DOT__reg_data 
                                      >> (0x0000001fU 
                                          & ((7U & 
                                              ((IData)(6U) 
                                               + (IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_3__DOT__u_crc_parallel_crcw__DOT__reg_chunk_idx))) 
                                             + (0x00000018U 
                                                & (((IData)(3U) 
                                                    - 
                                                    (3U 
                                                     & (((IData)(6U) 
                                                         + (IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_3__DOT__u_crc_parallel_crcw__DOT__reg_chunk_idx)) 
                                                        >> 3U))) 
                                                   << 3U)))))));
    __Vdfg_Regularize_576 = (((0x0000003fU & ((IData)(6U) 
                                              + (IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_3__DOT__u_crc_parallel_crcw__DOT__reg_chunk_idx))) 
                              < (IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_3__DOT__u_crc_parallel_crcw__DOT__w_valid_bit_cnt))
                              ? ((0x00000080U & (IData)(__Vdfg_Regularize_574))
                                  ? (7U ^ (IData)(__Vdfg_Regularize_600))
                                  : (IData)(__Vdfg_Regularize_600))
                              : (IData)(__Vdfg_Regularize_574));
    __Vdfg_Regularize_591 = (((0x0000003fU & ((IData)(6U) 
                                              + (IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_3__DOT__u_crc_parallel_crcw__DOT__reg_chunk_idx))) 
                              < (IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_3__DOT__u_crc_parallel_crcw__DOT__w_valid_bit_cnt))
                              ? ((0x00000080U & (IData)(__Vdfg_Regularize_589))
                                  ? (7U ^ (IData)(__Vdfg_Regularize_623))
                                  : (IData)(__Vdfg_Regularize_623))
                              : (IData)(__Vdfg_Regularize_589));
    __Vdfg_Regularize_601 = ((0x000000feU & ((IData)(__Vdfg_Regularize_576) 
                                             << 1U)) 
                             | (1U & (vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_3__DOT__u_crc_parallel_crcw__DOT__reg_data 
                                      >> (0x0000001fU 
                                          & ((7U & 
                                              ((IData)(7U) 
                                               + (IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_3__DOT__u_crc_parallel_crcw__DOT__reg_chunk_idx))) 
                                             + (0x00000018U 
                                                & (((IData)(3U) 
                                                    - 
                                                    (3U 
                                                     & (((IData)(7U) 
                                                         + (IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_3__DOT__u_crc_parallel_crcw__DOT__reg_chunk_idx)) 
                                                        >> 3U))) 
                                                   << 3U)))))));
    __Vdfg_Regularize_624 = ((0x000000feU & ((IData)(__Vdfg_Regularize_591) 
                                             << 1U)) 
                             | (1U & (vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_3__DOT__u_crc_parallel_crcw__DOT__reg_data 
                                      >> (0x0000001fU 
                                          & ((7U & 
                                              ((IData)(7U) 
                                               + (IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_3__DOT__u_crc_parallel_crcw__DOT__reg_chunk_idx))) 
                                             + (0x00000018U 
                                                & (((IData)(3U) 
                                                    - 
                                                    (3U 
                                                     & (((IData)(7U) 
                                                         + (IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_3__DOT__u_crc_parallel_crcw__DOT__reg_chunk_idx)) 
                                                        >> 3U))) 
                                                   << 3U)))))));
    vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_3__DOT__u_crc_parallel_crcw__DOT__w_chunk_crc 
        = ((IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_3__DOT__u_crc_parallel_crcw__DOT__reg_augment)
            ? ((0x00000080U & (IData)(__Vdfg_Regularize_608))
                ? (1U | (0x000000feU & (6U ^ (0x000000feU 
                                              & ((IData)(__Vdfg_Regularize_608) 
                                                 << 1U)))))
                : (0x000000feU & ((IData)(__Vdfg_Regularize_608) 
                                  << 1U))) : (((0x0000003fU 
                                                & ((IData)(7U) 
                                                   + (IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_3__DOT__u_crc_parallel_crcw__DOT__reg_chunk_idx))) 
                                               < (IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_3__DOT__u_crc_parallel_crcw__DOT__w_valid_bit_cnt))
                                               ? ((0x00000080U 
                                                   & (IData)(__Vdfg_Regularize_576))
                                                   ? 
                                                  (7U 
                                                   ^ (IData)(__Vdfg_Regularize_601))
                                                   : (IData)(__Vdfg_Regularize_601))
                                               : (IData)(__Vdfg_Regularize_576)));
    vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_3__DOT__u_crc_parallel_crcw__DOT__w_chunk_crc 
        = ((IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_3__DOT__u_crc_parallel_crcw__DOT__reg_augment)
            ? ((0x00000080U & (IData)(__Vdfg_Regularize_631))
                ? (1U | (0x000000feU & (6U ^ (0x000000feU 
                                              & ((IData)(__Vdfg_Regularize_631) 
                                                 << 1U)))))
                : (0x000000feU & ((IData)(__Vdfg_Regularize_631) 
                                  << 1U))) : (((0x0000003fU 
                                                & ((IData)(7U) 
                                                   + (IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_3__DOT__u_crc_parallel_crcw__DOT__reg_chunk_idx))) 
                                               < (IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_3__DOT__u_crc_parallel_crcw__DOT__w_valid_bit_cnt))
                                               ? ((0x00000080U 
                                                   & (IData)(__Vdfg_Regularize_591))
                                                   ? 
                                                  (7U 
                                                   ^ (IData)(__Vdfg_Regularize_624))
                                                   : (IData)(__Vdfg_Regularize_624))
                                               : (IData)(__Vdfg_Regularize_591)));
}

bool Vcrc___024root___trigger_anySet__ico(const VlUnpacked<QData/*63:0*/, 2> &in);

#ifdef VL_DEBUG
VL_ATTR_COLD void Vcrc___024root___dump_triggers__ico(const VlUnpacked<QData/*63:0*/, 2> &triggers, const std::string &tag) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vcrc___024root___dump_triggers__ico\n"); );
    // Body
    if ((1U & (~ (IData)(Vcrc___024root___trigger_anySet__ico(triggers))))) {
        VL_DBG_MSGS("         No '" + tag + "' region triggers active\n");
    }
    if ((1U & (IData)(triggers[0U]))) {
        VL_DBG_MSGS("         '" + tag + "' region trigger index 0 is active: @( i_clk_crc)\n");
    }
    if ((1U & (IData)((triggers[0U] >> 1U)))) {
        VL_DBG_MSGS("         '" + tag + "' region trigger index 1 is active: @( i_rst_n_crc)\n");
    }
    if ((1U & (IData)((triggers[0U] >> 2U)))) {
        VL_DBG_MSGS("         '" + tag + "' region trigger index 2 is active: @( i_gen_data)\n");
    }
    if ((1U & (IData)((triggers[0U] >> 3U)))) {
        VL_DBG_MSGS("         '" + tag + "' region trigger index 3 is active: @( i_gen_keep)\n");
    }
    if ((1U & (IData)((triggers[0U] >> 4U)))) {
        VL_DBG_MSGS("         '" + tag + "' region trigger index 4 is active: @( i_gen_valid)\n");
    }
    if ((1U & (IData)((triggers[0U] >> 5U)))) {
        VL_DBG_MSGS("         '" + tag + "' region trigger index 5 is active: @( i_gen_last)\n");
    }
    if ((1U & (IData)((triggers[0U] >> 6U)))) {
        VL_DBG_MSGS("         '" + tag + "' region trigger index 6 is active: @( i_gen_crc_ready)\n");
    }
    if ((1U & (IData)((triggers[0U] >> 7U)))) {
        VL_DBG_MSGS("         '" + tag + "' region trigger index 7 is active: @( i_check_data)\n");
    }
    if ((1U & (IData)((triggers[0U] >> 8U)))) {
        VL_DBG_MSGS("         '" + tag + "' region trigger index 8 is active: @( i_check_keep)\n");
    }
    if ((1U & (IData)((triggers[0U] >> 9U)))) {
        VL_DBG_MSGS("         '" + tag + "' region trigger index 9 is active: @( i_check_valid)\n");
    }
    if ((1U & (IData)((triggers[0U] >> 0x0000000aU)))) {
        VL_DBG_MSGS("         '" + tag + "' region trigger index 10 is active: @( i_check_last)\n");
    }
    if ((1U & (IData)((triggers[0U] >> 0x0000000bU)))) {
        VL_DBG_MSGS("         '" + tag + "' region trigger index 11 is active: @( i_check_crc)\n");
    }
    if ((1U & (IData)((triggers[0U] >> 0x0000000cU)))) {
        VL_DBG_MSGS("         '" + tag + "' region trigger index 12 is active: @( i_check_crc_ready)\n");
    }
    if ((1U & (IData)(triggers[1U]))) {
        VL_DBG_MSGS("         '" + tag + "' region trigger index 64 is active: Internal 'ico' trigger - first iteration\n");
    }
}
#endif  // VL_DEBUG

bool Vcrc___024root___trigger_anySet__act(const VlUnpacked<QData/*63:0*/, 1> &in);

#ifdef VL_DEBUG
VL_ATTR_COLD void Vcrc___024root___dump_triggers__act(const VlUnpacked<QData/*63:0*/, 1> &triggers, const std::string &tag) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vcrc___024root___dump_triggers__act\n"); );
    // Body
    if ((1U & (~ (IData)(Vcrc___024root___trigger_anySet__act(triggers))))) {
        VL_DBG_MSGS("         No '" + tag + "' region triggers active\n");
    }
    if ((1U & (IData)(triggers[0U]))) {
        VL_DBG_MSGS("         '" + tag + "' region trigger index 0 is active: @(posedge i_clk_crc)\n");
    }
}
#endif  // VL_DEBUG

VL_ATTR_COLD void Vcrc___024root___ctor_var_reset(Vcrc___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vcrc___024root___ctor_var_reset\n"); );
    Vcrc__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Body
    const uint64_t __VscopeHash = VL_MURMUR64_HASH(vlSelf->vlNamep);
    vlSelf->i_clk_crc = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 7833043531627825060ull);
    vlSelf->i_rst_n_crc = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 16368492165118379620ull);
    vlSelf->i_gen_data = VL_SCOPED_RAND_RESET_I(32, __VscopeHash, 16272362804487448987ull);
    vlSelf->i_gen_keep = VL_SCOPED_RAND_RESET_I(4, __VscopeHash, 4003954524733374398ull);
    vlSelf->i_gen_valid = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 14976442907654210106ull);
    vlSelf->i_gen_last = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 16324074986353538365ull);
    vlSelf->o_gen_data_ready = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 5196927497760937804ull);
    vlSelf->o_gen_crc = VL_SCOPED_RAND_RESET_I(8, __VscopeHash, 3043168594990581637ull);
    vlSelf->o_gen_crc_valid = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 6406002674580164605ull);
    vlSelf->i_gen_crc_ready = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 1434365149430831710ull);
    vlSelf->i_check_data = VL_SCOPED_RAND_RESET_I(32, __VscopeHash, 13571094061161519279ull);
    vlSelf->i_check_keep = VL_SCOPED_RAND_RESET_I(4, __VscopeHash, 1808124001774256246ull);
    vlSelf->i_check_valid = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 16839616335746463692ull);
    vlSelf->i_check_last = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 12123212944353719355ull);
    vlSelf->i_check_crc = VL_SCOPED_RAND_RESET_I(8, __VscopeHash, 2616207439244663111ull);
    vlSelf->o_check_data_ready = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 16371218162537437167ull);
    vlSelf->o_check_pass = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 12134859985623663099ull);
    vlSelf->o_check_crc_valid = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 2628765057176209784ull);
    vlSelf->i_check_crc_ready = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 14697704443546574182ull);
    vlSelf->m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__reg_check_crc_ref = VL_SCOPED_RAND_RESET_I(8, __VscopeHash, 5577206290272303270ull);
    vlSelf->m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_3__DOT__u_crc_parallel_crcw__DOT__reg_crc_state = VL_SCOPED_RAND_RESET_I(8, __VscopeHash, 13443014432761427644ull);
    vlSelf->m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_3__DOT__u_crc_parallel_crcw__DOT__reg_crc_output = VL_SCOPED_RAND_RESET_I(8, __VscopeHash, 13001463319406885967ull);
    vlSelf->m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_3__DOT__u_crc_parallel_crcw__DOT__reg_data = VL_SCOPED_RAND_RESET_I(32, __VscopeHash, 6671812663777553680ull);
    vlSelf->m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_3__DOT__u_crc_parallel_crcw__DOT__reg_keep = VL_SCOPED_RAND_RESET_I(4, __VscopeHash, 9762671663943597289ull);
    vlSelf->m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_3__DOT__u_crc_parallel_crcw__DOT__reg_chunk_idx = VL_SCOPED_RAND_RESET_I(6, __VscopeHash, 16723400831616142460ull);
    vlSelf->m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_3__DOT__u_crc_parallel_crcw__DOT__w_valid_bit_cnt = VL_SCOPED_RAND_RESET_I(6, __VscopeHash, 9014259169126088809ull);
    vlSelf->m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_3__DOT__u_crc_parallel_crcw__DOT__w_chunk_crc = VL_SCOPED_RAND_RESET_I(8, __VscopeHash, 2802181848208289838ull);
    vlSelf->m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_3__DOT__u_crc_parallel_crcw__DOT__reg_last = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 8720641888896107990ull);
    vlSelf->m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_3__DOT__u_crc_parallel_crcw__DOT__reg_busy = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 9651696453342168183ull);
    vlSelf->m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_3__DOT__u_crc_parallel_crcw__DOT__reg_augment = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 1151136491206911537ull);
    vlSelf->m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_3__DOT__u_crc_parallel_crcw__DOT__reg_crc_valid = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 12497723512836649804ull);
    vlSelf->m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_3__DOT__u_crc_parallel_crcw__DOT__reg_crc_state = VL_SCOPED_RAND_RESET_I(8, __VscopeHash, 6327515918761766800ull);
    vlSelf->m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_3__DOT__u_crc_parallel_crcw__DOT__reg_crc_output = VL_SCOPED_RAND_RESET_I(8, __VscopeHash, 1006719505201605607ull);
    vlSelf->m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_3__DOT__u_crc_parallel_crcw__DOT__reg_data = VL_SCOPED_RAND_RESET_I(32, __VscopeHash, 2219187603004058433ull);
    vlSelf->m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_3__DOT__u_crc_parallel_crcw__DOT__reg_keep = VL_SCOPED_RAND_RESET_I(4, __VscopeHash, 3553909975418494881ull);
    vlSelf->m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_3__DOT__u_crc_parallel_crcw__DOT__reg_chunk_idx = VL_SCOPED_RAND_RESET_I(6, __VscopeHash, 6193225356302704052ull);
    vlSelf->m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_3__DOT__u_crc_parallel_crcw__DOT__w_valid_bit_cnt = VL_SCOPED_RAND_RESET_I(6, __VscopeHash, 11234290391416748884ull);
    vlSelf->m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_3__DOT__u_crc_parallel_crcw__DOT__w_chunk_crc = VL_SCOPED_RAND_RESET_I(8, __VscopeHash, 1298101738632632859ull);
    vlSelf->m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_3__DOT__u_crc_parallel_crcw__DOT__reg_last = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 9372979359670151926ull);
    vlSelf->m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_3__DOT__u_crc_parallel_crcw__DOT__reg_busy = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 16179699655576898079ull);
    vlSelf->m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_3__DOT__u_crc_parallel_crcw__DOT__reg_augment = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 11544048237484024497ull);
    vlSelf->m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_3__DOT__u_crc_parallel_crcw__DOT__reg_crc_valid = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 7938195777084560975ull);
    for (int __Vi0 = 0; __Vi0 < 1; ++__Vi0) {
        vlSelf->__VstlTriggered[__Vi0] = 0;
    }
    for (int __Vi0 = 0; __Vi0 < 2; ++__Vi0) {
        vlSelf->__VicoTriggered[__Vi0] = 0;
    }
    vlSelf->__Vtrigprevexpr___TOP__i_clk_crc__0 = 0;
    vlSelf->__Vtrigprevexpr___TOP__i_rst_n_crc__0 = 0;
    vlSelf->__Vtrigprevexpr___TOP__i_gen_data__0 = 0;
    vlSelf->__Vtrigprevexpr___TOP__i_gen_keep__0 = 0;
    vlSelf->__Vtrigprevexpr___TOP__i_gen_valid__0 = 0;
    vlSelf->__Vtrigprevexpr___TOP__i_gen_last__0 = 0;
    vlSelf->__Vtrigprevexpr___TOP__i_gen_crc_ready__0 = 0;
    vlSelf->__Vtrigprevexpr___TOP__i_check_data__0 = 0;
    vlSelf->__Vtrigprevexpr___TOP__i_check_keep__0 = 0;
    vlSelf->__Vtrigprevexpr___TOP__i_check_valid__0 = 0;
    vlSelf->__Vtrigprevexpr___TOP__i_check_last__0 = 0;
    vlSelf->__Vtrigprevexpr___TOP__i_check_crc__0 = 0;
    vlSelf->__Vtrigprevexpr___TOP__i_check_crc_ready__0 = 0;
    vlSelf->__VicoDidInit = 0;
    for (int __Vi0 = 0; __Vi0 < 1; ++__Vi0) {
        vlSelf->__VactTriggered[__Vi0] = 0;
    }
    vlSelf->__Vtrigprevexpr___TOP__i_clk_crc__1 = 0;
    for (int __Vi0 = 0; __Vi0 < 1; ++__Vi0) {
        vlSelf->__VnbaTriggered[__Vi0] = 0;
    }
    for (int __Vi0 = 0; __Vi0 < 2; ++__Vi0) {
        vlSelf->__VtraceActivity[__Vi0] = 0;
    }
}
