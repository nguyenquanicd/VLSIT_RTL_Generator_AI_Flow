// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Design implementation internals
// See Vtb_axi_bridge.h for the primary calling header

#include "Vtb_axi_bridge__pch.h"

VlCoroutine Vtb_axi_bridge___024root___eval_initial__TOP__Vtiming__0(Vtb_axi_bridge___024root* vlSelf);
VlCoroutine Vtb_axi_bridge___024root___eval_initial__TOP__Vtiming__1(Vtb_axi_bridge___024root* vlSelf);
VlCoroutine Vtb_axi_bridge___024root___eval_initial__TOP__Vtiming__2(Vtb_axi_bridge___024root* vlSelf);
VlCoroutine Vtb_axi_bridge___024root___eval_initial__TOP__Vtiming__3(Vtb_axi_bridge___024root* vlSelf);

void Vtb_axi_bridge___024root___eval_initial(Vtb_axi_bridge___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_axi_bridge___024root___eval_initial\n"); );
    Vtb_axi_bridge__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Body
    Vtb_axi_bridge___024root___eval_initial__TOP__Vtiming__0(vlSelf);
    Vtb_axi_bridge___024root___eval_initial__TOP__Vtiming__1(vlSelf);
    Vtb_axi_bridge___024root___eval_initial__TOP__Vtiming__2(vlSelf);
    Vtb_axi_bridge___024root___eval_initial__TOP__Vtiming__3(vlSelf);
}

void Vtb_axi_bridge___024root___eval_sample(Vtb_axi_bridge___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_axi_bridge___024root___eval_sample\n"); );
    Vtb_axi_bridge__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
}

#ifdef VL_DEBUG
VL_ATTR_COLD void Vtb_axi_bridge___024root___dump_triggers__ico(const VlUnpacked<QData/*63:0*/, 1> &triggers, const std::string &tag);
#endif  // VL_DEBUG

bool Vtb_axi_bridge___024root___eval_ico(Vtb_axi_bridge___024root* vlSelf, CData/*0:0*/ firstIteration) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_axi_bridge___024root___eval_ico\n"); );
    Vtb_axi_bridge__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Body
    vlSelfRef.__VicoTriggered[0U] = ((0xfffffffffffffffeULL 
                                      & vlSelfRef.__VicoTriggered[0U]) 
                                     | (IData)((IData)(firstIteration)));
#ifdef VL_DEBUG
    if (VL_UNLIKELY(vlSymsp->_vm_contextp__->debug())) {
        Vtb_axi_bridge___024root___dump_triggers__ico(vlSelfRef.__VicoTriggered, "ico"s);
    }
#endif
    return (0U);
}

void Vtb_axi_bridge___024root___timing_ready(Vtb_axi_bridge___024root* vlSelf);
void Vtb_axi_bridge___024root___trigger_orInto__act_vec_vec(VlUnpacked<QData/*63:0*/, 1> &out, const VlUnpacked<QData/*63:0*/, 1> &in);
#ifdef VL_DEBUG
VL_ATTR_COLD void Vtb_axi_bridge___024root___dump_triggers__act(const VlUnpacked<QData/*63:0*/, 1> &triggers, const std::string &tag);
#endif  // VL_DEBUG
bool Vtb_axi_bridge___024root___trigger_anySet__act(const VlUnpacked<QData/*63:0*/, 1> &in);
void Vtb_axi_bridge___024root___timing_resume(Vtb_axi_bridge___024root* vlSelf);

bool Vtb_axi_bridge___024root___eval_act(Vtb_axi_bridge___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_axi_bridge___024root___eval_act\n"); );
    Vtb_axi_bridge__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Locals
    CData/*0:0*/ __VactExecute;
    // Body
    {
        // Inlined CFunc: _eval_triggers_vec__act
        CData/*0:0*/ __Vinline_0__eval_triggers_vec__act___Vtrigprevexpr_h325807e2__0;
        __Vinline_0__eval_triggers_vec__act___Vtrigprevexpr_h325807e2__0 = 0;
        CData/*0:0*/ __Vinline_0__eval_triggers_vec__act___Vtrigprevexpr_hb5e7ad64__0;
        __Vinline_0__eval_triggers_vec__act___Vtrigprevexpr_hb5e7ad64__0 = 0;
        __Vinline_0__eval_triggers_vec__act___Vtrigprevexpr_h325807e2__0 
            = (((6U == vlSelfRef.tb_axi_bridge__DOT__out_aw) 
                & (0x00000012U == vlSelfRef.tb_axi_bridge__DOT__out_w)) 
               & (6U == vlSelfRef.tb_axi_bridge__DOT__out_ar));
        __Vinline_0__eval_triggers_vec__act___Vtrigprevexpr_hb5e7ad64__0 
            = ((6U == vlSelfRef.tb_axi_bridge__DOT__out_b) 
               & (0x00000012U == vlSelfRef.tb_axi_bridge__DOT__out_r));
        vlSelfRef.__VactTriggered[0U] = (QData)((IData)(
                                                        (((__Vinline_0__eval_triggers_vec__act___Vtrigprevexpr_hb5e7ad64__0 
                                                           != (IData)(vlSelfRef.__Vtrigprevexpr_hb5e7ad64__1)) 
                                                          << 8U) 
                                                         | ((((((__Vinline_0__eval_triggers_vec__act___Vtrigprevexpr_h325807e2__0 
                                                                 != (IData)(vlSelfRef.__Vtrigprevexpr_h325807e2__1)) 
                                                                << 3U) 
                                                               | (((~ (IData)(vlSelfRef.tb_axi_bridge__DOT__i_clk_mgr)) 
                                                                   & (IData)(vlSelfRef.__Vtrigprevexpr___TOP__tb_axi_bridge__DOT__i_clk_mgr__0)) 
                                                                  << 2U)) 
                                                              | ((((~ (IData)(vlSelfRef.tb_axi_bridge__DOT__i_clk_sub)) 
                                                                   & (IData)(vlSelfRef.__Vtrigprevexpr___TOP__tb_axi_bridge__DOT__i_clk_sub__0)) 
                                                                  << 1U) 
                                                                 | vlSelfRef.__VdlySched.awaitingCurrentTime())) 
                                                             << 4U) 
                                                            | (((((~ (IData)(vlSelfRef.tb_axi_bridge__DOT__i_rst_n_mgr)) 
                                                                  & (IData)(vlSelfRef.__Vtrigprevexpr___TOP__tb_axi_bridge__DOT__i_rst_n_mgr__0)) 
                                                                 << 3U) 
                                                                | (((~ (IData)(vlSelfRef.tb_axi_bridge__DOT__i_rst_n_sub)) 
                                                                    & (IData)(vlSelfRef.__Vtrigprevexpr___TOP__tb_axi_bridge__DOT__i_rst_n_sub__0)) 
                                                                   << 2U)) 
                                                               | ((((IData)(vlSelfRef.tb_axi_bridge__DOT__i_clk_mgr) 
                                                                    & (~ (IData)(vlSelfRef.__Vtrigprevexpr___TOP__tb_axi_bridge__DOT__i_clk_mgr__0))) 
                                                                   << 1U) 
                                                                  | ((IData)(vlSelfRef.tb_axi_bridge__DOT__i_clk_sub) 
                                                                     & (~ (IData)(vlSelfRef.__Vtrigprevexpr___TOP__tb_axi_bridge__DOT__i_clk_sub__0)))))))));
        vlSelfRef.__Vtrigprevexpr___TOP__tb_axi_bridge__DOT__i_clk_sub__0 
            = vlSelfRef.tb_axi_bridge__DOT__i_clk_sub;
        vlSelfRef.__Vtrigprevexpr___TOP__tb_axi_bridge__DOT__i_clk_mgr__0 
            = vlSelfRef.tb_axi_bridge__DOT__i_clk_mgr;
        vlSelfRef.__Vtrigprevexpr___TOP__tb_axi_bridge__DOT__i_rst_n_sub__0 
            = vlSelfRef.tb_axi_bridge__DOT__i_rst_n_sub;
        vlSelfRef.__Vtrigprevexpr___TOP__tb_axi_bridge__DOT__i_rst_n_mgr__0 
            = vlSelfRef.tb_axi_bridge__DOT__i_rst_n_mgr;
        vlSelfRef.__Vtrigprevexpr_h325807e2__1 = __Vinline_0__eval_triggers_vec__act___Vtrigprevexpr_h325807e2__0;
        vlSelfRef.__Vtrigprevexpr_hb5e7ad64__1 = __Vinline_0__eval_triggers_vec__act___Vtrigprevexpr_hb5e7ad64__0;
    }
    Vtb_axi_bridge___024root___timing_ready(vlSelf);
    Vtb_axi_bridge___024root___trigger_orInto__act_vec_vec(vlSelfRef.__VactTriggered, vlSelfRef.__VactTriggeredAcc);
#ifdef VL_DEBUG
    if (VL_UNLIKELY(vlSymsp->_vm_contextp__->debug())) {
        Vtb_axi_bridge___024root___dump_triggers__act(vlSelfRef.__VactTriggered, "act"s);
    }
#endif
    Vtb_axi_bridge___024root___trigger_orInto__act_vec_vec(vlSelfRef.__VnbaTriggered, vlSelfRef.__VactTriggered);
    __VactExecute = Vtb_axi_bridge___024root___trigger_anySet__act(vlSelfRef.__VactTriggered);
    if (__VactExecute) {
        vlSelfRef.__VactTriggeredAcc.fill(0ULL);
        Vtb_axi_bridge___024root___timing_resume(vlSelf);
        {
            // Inlined CFunc: _eval_body__act
            if ((0x00000000000001f3ULL & vlSelfRef.__VactTriggered[0U])) {
                {
                    // Inlined CFunc: _act_comb__TOP__0
                    vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_ar__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_rd__DOT__w_rbin_nxt 
                        = (7U & ((- (IData)((1U != (IData)(vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_ar__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_rd__DOT__reg_fsm_srst_current_state)))) 
                                 & ((IData)(vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_ar__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_rd__DOT__reg_rbin) 
                                    + ((IData)(vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_ar__DOT__o_axi_arvalid) 
                                       & (IData)(vlSelfRef.tb_axi_bridge__DOT__i_axi_arready)))));
                    vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_aw__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_rd__DOT__w_rbin_nxt 
                        = (7U & ((- (IData)((1U != (IData)(vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_aw__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_rd__DOT__reg_fsm_srst_current_state)))) 
                                 & ((IData)(vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_aw__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_rd__DOT__reg_rbin) 
                                    + ((IData)(vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_aw__DOT__o_axi_awvalid) 
                                       & (IData)(vlSelfRef.tb_axi_bridge__DOT__i_axi_awready)))));
                    vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_b__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_rd__DOT__w_rbin_nxt 
                        = (7U & ((- (IData)((1U != (IData)(vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_b__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_rd__DOT__reg_fsm_srst_current_state)))) 
                                 & ((IData)(vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_b__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_rd__DOT__reg_rbin) 
                                    + ((IData)(vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_b__DOT__o_axi_bvalid) 
                                       & (IData)(vlSelfRef.tb_axi_bridge__DOT__i_axi_bready)))));
                    vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_r__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_rd__DOT__w_rbin_nxt 
                        = (0x0000001fU & ((- (IData)(
                                                     (1U 
                                                      != (IData)(vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_r__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_rd__DOT__reg_fsm_srst_current_state)))) 
                                          & ((IData)(vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_r__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_rd__DOT__reg_rbin) 
                                             + ((IData)(vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_r__DOT__o_axi_rvalid) 
                                                & (IData)(vlSelfRef.tb_axi_bridge__DOT__i_axi_rready)))));
                    vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_w__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_rd__DOT__w_rbin_nxt 
                        = (0x0000001fU & ((- (IData)(
                                                     (1U 
                                                      != (IData)(vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_w__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_rd__DOT__reg_fsm_srst_current_state)))) 
                                          & ((IData)(vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_w__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_rd__DOT__reg_rbin) 
                                             + ((IData)(vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_w__DOT__o_axi_wvalid) 
                                                & (IData)(vlSelfRef.tb_axi_bridge__DOT__i_axi_wready)))));
                    vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_ar__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__o_mem_wr_en 
                        = ((IData)(vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_ar__DOT__o_axi_arready) 
                           & (IData)(vlSelfRef.tb_axi_bridge__DOT__i_axi_arvalid));
                    vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_aw__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__o_mem_wr_en 
                        = ((IData)(vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_aw__DOT__o_axi_awready) 
                           & (IData)(vlSelfRef.tb_axi_bridge__DOT__i_axi_awvalid));
                    vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_b__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__o_mem_wr_en 
                        = ((IData)(vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_b__DOT__o_axi_bready) 
                           & (IData)(vlSelfRef.tb_axi_bridge__DOT__i_axi_bvalid));
                    vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_w__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__o_mem_wr_en 
                        = ((IData)(vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_w__DOT__o_axi_wready) 
                           & (IData)(vlSelfRef.tb_axi_bridge__DOT__i_axi_wvalid));
                    vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_r__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__o_mem_wr_en 
                        = ((IData)(vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_r__DOT__o_axi_rready) 
                           & (IData)(vlSelfRef.tb_axi_bridge__DOT__i_axi_rvalid));
                    vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_ar__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__w_wbin_nxt 
                        = (7U & ((- (IData)((2U != (IData)(vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_ar__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__reg_fsm_srst_current_state)))) 
                                 & ((IData)(vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_ar__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__reg_wbin) 
                                    + (IData)(vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_ar__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__o_mem_wr_en))));
                    vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_aw__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__w_wbin_nxt 
                        = (7U & ((- (IData)((2U != (IData)(vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_aw__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__reg_fsm_srst_current_state)))) 
                                 & ((IData)(vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_aw__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__reg_wbin) 
                                    + (IData)(vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_aw__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__o_mem_wr_en))));
                    vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_b__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__w_wbin_nxt 
                        = (7U & ((- (IData)((2U != (IData)(vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_b__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__reg_fsm_srst_current_state)))) 
                                 & ((IData)(vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_b__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__reg_wbin) 
                                    + (IData)(vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_b__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__o_mem_wr_en))));
                    vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_w__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__w_wbin_nxt 
                        = (0x0000001fU & ((- (IData)(
                                                     (2U 
                                                      != (IData)(vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_w__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__reg_fsm_srst_current_state)))) 
                                          & ((IData)(vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_w__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__reg_wbin) 
                                             + (IData)(vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_w__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__o_mem_wr_en))));
                    vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_r__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__w_wbin_nxt 
                        = (0x0000001fU & ((- (IData)(
                                                     (2U 
                                                      != (IData)(vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_r__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__reg_fsm_srst_current_state)))) 
                                          & ((IData)(vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_r__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__reg_wbin) 
                                             + (IData)(vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_r__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__o_mem_wr_en))));
                }
            }
        }
    }
    return (__VactExecute);
}

bool Vtb_axi_bridge___024root___eval_inact(Vtb_axi_bridge___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_axi_bridge___024root___eval_inact\n"); );
    Vtb_axi_bridge__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Locals
    CData/*0:0*/ __VinactExecute;
    // Body
    __VinactExecute = vlSelfRef.__VdlySched.awaitingZeroDelay();
    if (__VinactExecute) {
        VL_FATAL_MT("..\\..\\verification\\tb\\tb_axi_bridge.sv", 5, "", "ZERODLY: Design Verilated with '--no-sched-zero-delay', but #0 delay executed at runtime");
    }
    return (__VinactExecute);
}

void Vtb_axi_bridge___024root___eval_body__nba(Vtb_axi_bridge___024root* vlSelf);
void Vtb_axi_bridge___024root___trigger_clear__act(VlUnpacked<QData/*63:0*/, 1> &out);

bool Vtb_axi_bridge___024root___eval_nba(Vtb_axi_bridge___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_axi_bridge___024root___eval_nba\n"); );
    Vtb_axi_bridge__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Locals
    CData/*0:0*/ __VnbaExecute;
    // Body
    __VnbaExecute = Vtb_axi_bridge___024root___trigger_anySet__act(vlSelfRef.__VnbaTriggered);
    if (__VnbaExecute) {
        Vtb_axi_bridge___024root___eval_body__nba(vlSelf);
        Vtb_axi_bridge___024root___trigger_clear__act(vlSelfRef.__VnbaTriggered);
    }
    return (__VnbaExecute);
}

bool Vtb_axi_bridge___024root___eval_obs(Vtb_axi_bridge___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_axi_bridge___024root___eval_obs\n"); );
    Vtb_axi_bridge__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Body
    return (0U);
}

bool Vtb_axi_bridge___024root___eval_react(Vtb_axi_bridge___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_axi_bridge___024root___eval_react\n"); );
    Vtb_axi_bridge__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Body
    return (0U);
}

void Vtb_axi_bridge___024root___eval_postponed(Vtb_axi_bridge___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_axi_bridge___024root___eval_postponed\n"); );
    Vtb_axi_bridge__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
}

VlCoroutine Vtb_axi_bridge___024root___eval_initial__TOP__Vtiming__0(Vtb_axi_bridge___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_axi_bridge___024root___eval_initial__TOP__Vtiming__0\n"); );
    Vtb_axi_bridge__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Body
    co_await vlSelfRef.__VdlySched.delay(0x00000000000003e8ULL, 
                                         nullptr, "..\\..\\verification\\tb\\tb_axi_bridge.sv", 
                                         419);
    while (true) {
        co_await vlSelfRef.__VdlySched.delay(0x0000000000001b58ULL, 
                                             nullptr, 
                                             "..\\..\\verification\\tb\\tb_axi_bridge.sv", 
                                             419);
        vlSelfRef.tb_axi_bridge__DOT__i_clk_mgr = (1U 
                                                   & (~ (IData)(vlSelfRef.tb_axi_bridge__DOT__i_clk_mgr)));
    }
    co_return;
}

void Vtb_axi_bridge___024root____VbeforeTrig_h8c92a91c__0(Vtb_axi_bridge___024root* vlSelf, const char* __VeventDescription);
void Vtb_axi_bridge___024root____VbeforeTrig_h046e81df__0(Vtb_axi_bridge___024root* vlSelf, const char* __VeventDescription);
void Vtb_axi_bridge___024root____VbeforeTrig_h8c92a665__0(Vtb_axi_bridge___024root* vlSelf, const char* __VeventDescription);
VlCoroutine Vtb_axi_bridge___024root___eval_initial__TOP__Vtiming__1____Vfork_1__0(Vtb_axi_bridge___024root* vlSelf, VlForkSync __Vfork_1__sync);
VlCoroutine Vtb_axi_bridge___024root___eval_initial__TOP__Vtiming__1____Vfork_2__0(Vtb_axi_bridge___024root* vlSelf, VlForkSync __Vfork_2__sync);
VlCoroutine Vtb_axi_bridge___024root___eval_initial__TOP__Vtiming__1____Vfork_2__1(Vtb_axi_bridge___024root* vlSelf, VlForkSync __Vfork_2__sync);
VlCoroutine Vtb_axi_bridge___024root___eval_initial__TOP__Vtiming__1____Vfork_2__2(Vtb_axi_bridge___024root* vlSelf, VlForkSync __Vfork_2__sync);
VlCoroutine Vtb_axi_bridge___024root___eval_initial__TOP__Vtiming__1____Vfork_2__3(Vtb_axi_bridge___024root* vlSelf, VlForkSync __Vfork_2__sync);
void Vtb_axi_bridge___024root____VbeforeTrig_h955be2db__0(Vtb_axi_bridge___024root* vlSelf, const char* __VeventDescription);
void Vtb_axi_bridge___024root____VbeforeTrig_h046e831a__0(Vtb_axi_bridge___024root* vlSelf, const char* __VeventDescription);
VlCoroutine Vtb_axi_bridge___024root___eval_initial__TOP__Vtiming__1____Vfork_3__0(Vtb_axi_bridge___024root* vlSelf, VlForkSync __Vfork_3__sync);
VlCoroutine Vtb_axi_bridge___024root___eval_initial__TOP__Vtiming__1____Vfork_3__1(Vtb_axi_bridge___024root* vlSelf, VlForkSync __Vfork_3__sync);
VlCoroutine Vtb_axi_bridge___024root___eval_initial__TOP__Vtiming__1____Vfork_3__2(Vtb_axi_bridge___024root* vlSelf, VlForkSync __Vfork_3__sync);
void Vtb_axi_bridge___024root____VbeforeTrig_h18cb2d65__0(Vtb_axi_bridge___024root* vlSelf, const char* __VeventDescription);

VlCoroutine Vtb_axi_bridge___024root___eval_initial__TOP__Vtiming__1(Vtb_axi_bridge___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_axi_bridge___024root___eval_initial__TOP__Vtiming__1\n"); );
    Vtb_axi_bridge__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Locals
    IData/*31:0*/ tb_axi_bridge__DOT____VlemExpr_1;
    IData/*31:0*/ tb_axi_bridge__DOT____VlemExpr_0;
    IData/*31:0*/ tb_axi_bridge__DOT__assertion_fail_total;
    tb_axi_bridge__DOT__assertion_fail_total = 0;
    IData/*31:0*/ tb_axi_bridge__DOT__assertion_never_total;
    tb_axi_bridge__DOT__assertion_never_total = 0;
    IData/*31:0*/ tb_axi_bridge__DOT__unnamedblk1_1__DOT____Vrepeat0;
    tb_axi_bridge__DOT__unnamedblk1_1__DOT____Vrepeat0 = 0;
    IData/*31:0*/ tb_axi_bridge__DOT__unnamedblk1_2__DOT____Vrepeat1;
    tb_axi_bridge__DOT__unnamedblk1_2__DOT____Vrepeat1 = 0;
    IData/*31:0*/ tb_axi_bridge__DOT__unnamedblk1_3__DOT____Vrepeat2;
    tb_axi_bridge__DOT__unnamedblk1_3__DOT____Vrepeat2 = 0;
    IData/*31:0*/ tb_axi_bridge__DOT__unnamedblk1_4__DOT____Vrepeat3;
    tb_axi_bridge__DOT__unnamedblk1_4__DOT____Vrepeat3 = 0;
    IData/*31:0*/ tb_axi_bridge__DOT__unnamedblk1_5__DOT____Vrepeat4;
    tb_axi_bridge__DOT__unnamedblk1_5__DOT____Vrepeat4 = 0;
    // Body
    vlSelfRef.tb_axi_bridge__DOT__i_rst_n_sub = 0U;
    vlSelfRef.tb_axi_bridge__DOT__i_rst_n_mgr = 0U;
    vlSelfRef.tb_axi_bridge__DOT__i_axi_awvalid = 0U;
    vlSelfRef.tb_axi_bridge__DOT__i_axi_awid = 0U;
    vlSelfRef.tb_axi_bridge__DOT__i_axi_awaddr = 0U;
    vlSelfRef.tb_axi_bridge__DOT__i_axi_awlen = 0U;
    vlSelfRef.tb_axi_bridge__DOT__i_axi_awsize = 0U;
    vlSelfRef.tb_axi_bridge__DOT__i_axi_awburst = 0U;
    vlSelfRef.tb_axi_bridge__DOT__i_axi_awlock = 0U;
    vlSelfRef.tb_axi_bridge__DOT__i_axi_awcache = 0U;
    vlSelfRef.tb_axi_bridge__DOT__i_axi_awprot = 0U;
    vlSelfRef.tb_axi_bridge__DOT__i_axi_awqos = 0U;
    vlSelfRef.tb_axi_bridge__DOT__i_axi_awregion = 0U;
    vlSelfRef.tb_axi_bridge__DOT__i_axi_awready = 0U;
    vlSelfRef.tb_axi_bridge__DOT__i_axi_wvalid = 0U;
    vlSelfRef.tb_axi_bridge__DOT__i_axi_wdata = 0U;
    vlSelfRef.tb_axi_bridge__DOT__i_axi_wstrb = 0U;
    vlSelfRef.tb_axi_bridge__DOT__i_axi_wlast = 0U;
    vlSelfRef.tb_axi_bridge__DOT__i_axi_wready = 0U;
    vlSelfRef.tb_axi_bridge__DOT__i_axi_bvalid = 0U;
    vlSelfRef.tb_axi_bridge__DOT__i_axi_bid = 0U;
    vlSelfRef.tb_axi_bridge__DOT__i_axi_bresp = 0U;
    vlSelfRef.tb_axi_bridge__DOT__i_axi_bready = 0U;
    vlSelfRef.tb_axi_bridge__DOT__i_axi_arvalid = 0U;
    vlSelfRef.tb_axi_bridge__DOT__i_axi_arid = 0U;
    vlSelfRef.tb_axi_bridge__DOT__i_axi_araddr = 0U;
    vlSelfRef.tb_axi_bridge__DOT__i_axi_arlen = 0U;
    vlSelfRef.tb_axi_bridge__DOT__i_axi_arsize = 0U;
    vlSelfRef.tb_axi_bridge__DOT__i_axi_arburst = 0U;
    vlSelfRef.tb_axi_bridge__DOT__i_axi_arlock = 0U;
    vlSelfRef.tb_axi_bridge__DOT__i_axi_arcache = 0U;
    vlSelfRef.tb_axi_bridge__DOT__i_axi_arprot = 0U;
    vlSelfRef.tb_axi_bridge__DOT__i_axi_arqos = 0U;
    vlSelfRef.tb_axi_bridge__DOT__i_axi_arregion = 0U;
    vlSelfRef.tb_axi_bridge__DOT__i_axi_arready = 0U;
    vlSelfRef.tb_axi_bridge__DOT__i_axi_rvalid = 0U;
    vlSelfRef.tb_axi_bridge__DOT__i_axi_rid = 0U;
    vlSelfRef.tb_axi_bridge__DOT__i_axi_rdata = 0U;
    vlSelfRef.tb_axi_bridge__DOT__i_axi_rresp = 0U;
    vlSelfRef.tb_axi_bridge__DOT__i_axi_rlast = 0U;
    vlSelfRef.tb_axi_bridge__DOT__i_axi_rready = 0U;
    vlSelfRef.tb_axi_bridge__DOT__assertion_hits[0U] = 0U;
    vlSelfRef.tb_axi_bridge__DOT__assertion_fails[0U] = 0U;
    vlSelfRef.tb_axi_bridge__DOT__assertion_hits[1U] = 0U;
    vlSelfRef.tb_axi_bridge__DOT__assertion_fails[1U] = 0U;
    vlSelfRef.tb_axi_bridge__DOT__assertion_hits[2U] = 0U;
    vlSelfRef.tb_axi_bridge__DOT__assertion_fails[2U] = 0U;
    vlSelfRef.tb_axi_bridge__DOT__assertion_hits[3U] = 0U;
    vlSelfRef.tb_axi_bridge__DOT__assertion_fails[3U] = 0U;
    vlSelfRef.tb_axi_bridge__DOT__assertion_hits[4U] = 0U;
    vlSelfRef.tb_axi_bridge__DOT__assertion_fails[4U] = 0U;
    vlSelfRef.tb_axi_bridge__DOT__assertion_hits[5U] = 0U;
    vlSelfRef.tb_axi_bridge__DOT__assertion_fails[5U] = 0U;
    vlSelfRef.tb_axi_bridge__DOT__assertion_hits[6U] = 0U;
    vlSelfRef.tb_axi_bridge__DOT__assertion_fails[6U] = 0U;
    vlSelfRef.tb_axi_bridge__DOT__assertion_hits[7U] = 0U;
    vlSelfRef.tb_axi_bridge__DOT__assertion_fails[7U] = 0U;
    vlSelfRef.tb_axi_bridge__DOT__assertion_hits[8U] = 0U;
    vlSelfRef.tb_axi_bridge__DOT__assertion_fails[8U] = 0U;
    vlSelfRef.tb_axi_bridge__DOT__assertion_hits[9U] = 0U;
    vlSelfRef.tb_axi_bridge__DOT__assertion_fails[9U] = 0U;
    vlSelfRef.tb_axi_bridge__DOT__assertion_hits[10U] = 0U;
    vlSelfRef.tb_axi_bridge__DOT__assertion_fails[10U] = 0U;
    vlSelfRef.tb_axi_bridge__DOT__assertion_hits[11U] = 0U;
    vlSelfRef.tb_axi_bridge__DOT__assertion_fails[11U] = 0U;
    vlSelfRef.tb_axi_bridge__DOT__assertion_hits[12U] = 0U;
    vlSelfRef.tb_axi_bridge__DOT__assertion_fails[12U] = 0U;
    vlSelfRef.tb_axi_bridge__DOT__assertion_hits[13U] = 0U;
    vlSelfRef.tb_axi_bridge__DOT__assertion_fails[13U] = 0U;
    vlSelfRef.tb_axi_bridge__DOT__assertion_hits[14U] = 0U;
    vlSelfRef.tb_axi_bridge__DOT__assertion_fails[14U] = 0U;
    vlSelfRef.tb_axi_bridge__DOT__assertion_hits[15U] = 0U;
    vlSelfRef.tb_axi_bridge__DOT__assertion_fails[15U] = 0U;
    vlSelfRef.tb_axi_bridge__DOT__assertion_hits[16U] = 0U;
    vlSelfRef.tb_axi_bridge__DOT__assertion_fails[16U] = 0U;
    vlSelfRef.tb_axi_bridge__DOT__assertion_hits[17U] = 0U;
    vlSelfRef.tb_axi_bridge__DOT__assertion_fails[17U] = 0U;
    vlSelfRef.tb_axi_bridge__DOT__assertion_hits[18U] = 0U;
    vlSelfRef.tb_axi_bridge__DOT__assertion_fails[18U] = 0U;
    vlSelfRef.tb_axi_bridge__DOT__assertion_hits[19U] = 0U;
    vlSelfRef.tb_axi_bridge__DOT__assertion_fails[19U] = 0U;
    vlSelfRef.tb_axi_bridge__DOT__assertion_hits[20U] = 0U;
    vlSelfRef.tb_axi_bridge__DOT__assertion_fails[20U] = 0U;
    vlSelfRef.tb_axi_bridge__DOT__assertion_hits[21U] = 0U;
    vlSelfRef.tb_axi_bridge__DOT__assertion_fails[21U] = 0U;
    vlSelfRef.tb_axi_bridge__DOT__assertion_hits[22U] = 0U;
    vlSelfRef.tb_axi_bridge__DOT__assertion_fails[22U] = 0U;
    vlSelfRef.tb_axi_bridge__DOT__assertion_hits[23U] = 0U;
    vlSelfRef.tb_axi_bridge__DOT__assertion_fails[23U] = 0U;
    vlSelfRef.tb_axi_bridge__DOT__assertion_hits[24U] = 0U;
    vlSelfRef.tb_axi_bridge__DOT__assertion_fails[24U] = 0U;
    vlSelfRef.tb_axi_bridge__DOT__assertion_hits[25U] = 0U;
    vlSelfRef.tb_axi_bridge__DOT__assertion_fails[25U] = 0U;
    vlSelfRef.tb_axi_bridge__DOT__assertion_hits[26U] = 0U;
    vlSelfRef.tb_axi_bridge__DOT__assertion_fails[26U] = 0U;
    vlSelfRef.tb_axi_bridge__DOT__assertion_hits[27U] = 0U;
    vlSelfRef.tb_axi_bridge__DOT__assertion_fails[27U] = 0U;
    vlSelfRef.tb_axi_bridge__DOT__assertion_hits[28U] = 0U;
    vlSelfRef.tb_axi_bridge__DOT__assertion_fails[28U] = 0U;
    vlSelfRef.tb_axi_bridge__DOT__assertion_hits[29U] = 0U;
    vlSelfRef.tb_axi_bridge__DOT__assertion_fails[29U] = 0U;
    vlSelfRef.tb_axi_bridge__DOT__assertion_hits[30U] = 0U;
    vlSelfRef.tb_axi_bridge__DOT__assertion_fails[30U] = 0U;
    vlSelfRef.tb_axi_bridge__DOT__assertion_hits[31U] = 0U;
    vlSelfRef.tb_axi_bridge__DOT__assertion_fails[31U] = 0U;
    vlSelfRef.tb_axi_bridge__DOT__assertion_hits[32U] = 0U;
    vlSelfRef.tb_axi_bridge__DOT__assertion_fails[32U] = 0U;
    vlSelfRef.tb_axi_bridge__DOT__assertion_hits[33U] = 0U;
    vlSelfRef.tb_axi_bridge__DOT__assertion_fails[33U] = 0U;
    vlSelfRef.tb_axi_bridge__DOT__assertion_hits[34U] = 0U;
    vlSelfRef.tb_axi_bridge__DOT__assertion_fails[34U] = 0U;
    vlSelfRef.tb_axi_bridge__DOT__assertion_hits[35U] = 0U;
    vlSelfRef.tb_axi_bridge__DOT__assertion_fails[35U] = 0U;
    vlSelfRef.tb_axi_bridge__DOT__aw_head = 0U;
    vlSelfRef.tb_axi_bridge__DOT__aw_tail = 0U;
    vlSelfRef.tb_axi_bridge__DOT__w_head = 0U;
    vlSelfRef.tb_axi_bridge__DOT__w_tail = 0U;
    vlSelfRef.tb_axi_bridge__DOT__b_head = 0U;
    vlSelfRef.tb_axi_bridge__DOT__b_tail = 0U;
    vlSelfRef.tb_axi_bridge__DOT__ar_head = 0U;
    vlSelfRef.tb_axi_bridge__DOT__ar_tail = 0U;
    vlSelfRef.tb_axi_bridge__DOT__r_head = 0U;
    vlSelfRef.tb_axi_bridge__DOT__r_tail = 0U;
    vlSelfRef.tb_axi_bridge__DOT__out_aw = 0U;
    vlSelfRef.tb_axi_bridge__DOT__out_w = 0U;
    vlSelfRef.tb_axi_bridge__DOT__out_b = 0U;
    vlSelfRef.tb_axi_bridge__DOT__out_ar = 0U;
    vlSelfRef.tb_axi_bridge__DOT__out_r = 0U;
    vlSelfRef.tb_axi_bridge__DOT__src_aw_stall = 0U;
    vlSelfRef.tb_axi_bridge__DOT__dst_aw_stall = 0U;
    vlSelfRef.tb_axi_bridge__DOT__src_w_stall = 0U;
    vlSelfRef.tb_axi_bridge__DOT__dst_w_stall = 0U;
    vlSelfRef.tb_axi_bridge__DOT__src_b_stall = 0U;
    vlSelfRef.tb_axi_bridge__DOT__dst_b_stall = 0U;
    vlSelfRef.tb_axi_bridge__DOT__src_ar_stall = 0U;
    vlSelfRef.tb_axi_bridge__DOT__dst_ar_stall = 0U;
    vlSelfRef.tb_axi_bridge__DOT__src_r_stall = 0U;
    vlSelfRef.tb_axi_bridge__DOT__dst_r_stall = 0U;
    vlSelfRef.tb_axi_bridge__DOT__seed_value = 1U;
    tb_axi_bridge__DOT____VlemExpr_0 = VL_VALUEPLUSARGS_INI(32, "SEED=%d"s, 
                                                            vlSelfRef.tb_axi_bridge__DOT__seed_value);
    VL_WRITEF_NX("SIM-BRANCH: synthesis\nPROFILE: AXI4_BASE\nFIFO_DEPTH_PROFILE: AW/B/AR=4, W/R=16\n",0);
    tb_axi_bridge__DOT____VlemExpr_1 = VL_VALUEPLUSARGS_INW(4096, "VCD=%s"s, 
                                                            vlSelfRef.tb_axi_bridge__DOT__vcd_path);
    if ((0U != tb_axi_bridge__DOT____VlemExpr_1)) {
        vlSymsp->_vm_contextp__->dumpfile(VL_CVT_PACK_STR_NW(128, vlSelfRef.tb_axi_bridge__DOT__vcd_path));
        VL_PRINTF_MT("-Info: ..\\..\\verification\\tb\\tb_axi_bridge.sv:460: $dumpvar ignored, as Verilated without --trace\n");
    }
    tb_axi_bridge__DOT__unnamedblk1_1__DOT____Vrepeat0 = 3U;
    while (VL_LTS_III(32, 0U, tb_axi_bridge__DOT__unnamedblk1_1__DOT____Vrepeat0)) {
        Vtb_axi_bridge___024root____VbeforeTrig_h8c92a91c__0(vlSelf, 
                                                             "@(negedge tb_axi_bridge.i_clk_sub)");
        co_await vlSelfRef.__VtrigSched_h8c92a91c__0.trigger(0U, 
                                                             nullptr, 
                                                             "@(negedge tb_axi_bridge.i_clk_sub)", 
                                                             "..\\..\\verification\\tb\\tb_axi_bridge.sv", 
                                                             463);
        tb_axi_bridge__DOT__unnamedblk1_1__DOT____Vrepeat0 
            = (tb_axi_bridge__DOT__unnamedblk1_1__DOT____Vrepeat0 
               - (IData)(1U));
    }
    vlSelfRef.tb_axi_bridge__DOT__i_rst_n_sub = 1U;
    tb_axi_bridge__DOT__unnamedblk1_2__DOT____Vrepeat1 = 2U;
    while (VL_LTS_III(32, 0U, tb_axi_bridge__DOT__unnamedblk1_2__DOT____Vrepeat1)) {
        Vtb_axi_bridge___024root____VbeforeTrig_h046e81df__0(vlSelf, 
                                                             "@(negedge tb_axi_bridge.i_clk_mgr)");
        co_await vlSelfRef.__VtrigSched_h046e81df__0.trigger(0U, 
                                                             nullptr, 
                                                             "@(negedge tb_axi_bridge.i_clk_mgr)", 
                                                             "..\\..\\verification\\tb\\tb_axi_bridge.sv", 
                                                             465);
        tb_axi_bridge__DOT__unnamedblk1_2__DOT____Vrepeat1 
            = (tb_axi_bridge__DOT__unnamedblk1_2__DOT____Vrepeat1 
               - (IData)(1U));
    }
    vlSelfRef.tb_axi_bridge__DOT__i_rst_n_mgr = 1U;
    tb_axi_bridge__DOT__unnamedblk1_3__DOT____Vrepeat2 = 4U;
    while (VL_LTS_III(32, 0U, tb_axi_bridge__DOT__unnamedblk1_3__DOT____Vrepeat2)) {
        Vtb_axi_bridge___024root____VbeforeTrig_h8c92a665__0(vlSelf, 
                                                             "@(posedge tb_axi_bridge.i_clk_sub)");
        co_await vlSelfRef.__VtrigSched_h8c92a665__0.trigger(0U, 
                                                             nullptr, 
                                                             "@(posedge tb_axi_bridge.i_clk_sub)", 
                                                             "..\\..\\verification\\tb\\tb_axi_bridge.sv", 
                                                             467);
        tb_axi_bridge__DOT__unnamedblk1_3__DOT____Vrepeat2 
            = (tb_axi_bridge__DOT__unnamedblk1_3__DOT____Vrepeat2 
               - (IData)(1U));
    }
    vlSelfRef.tb_axi_bridge__DOT__i_axi_awready = 0U;
    vlSelfRef.tb_axi_bridge__DOT__i_axi_wready = 0U;
    vlSelfRef.tb_axi_bridge__DOT__i_axi_arready = 0U;
    vlSelfRef.tb_axi_bridge__DOT__i_axi_bready = 0U;
    vlSelfRef.tb_axi_bridge__DOT__i_axi_rready = 0U;
    {
        VlForkSync __Vfork_1__sync;
        __Vfork_1__sync.init(1U, nullptr);
        Vtb_axi_bridge___024root___eval_initial__TOP__Vtiming__1____Vfork_1__0(vlSelf, __Vfork_1__sync);
        co_await __Vfork_1__sync.join(nullptr, "..\\..\\verification\\tb\\tb_axi_bridge.sv", 
                                      472);
    }
    {
        VlForkSync __Vfork_2__sync;
        __Vfork_2__sync.init(4U, nullptr);
        Vtb_axi_bridge___024root___eval_initial__TOP__Vtiming__1____Vfork_2__0(vlSelf, __Vfork_2__sync);
        Vtb_axi_bridge___024root___eval_initial__TOP__Vtiming__1____Vfork_2__1(vlSelf, __Vfork_2__sync);
        Vtb_axi_bridge___024root___eval_initial__TOP__Vtiming__1____Vfork_2__2(vlSelf, __Vfork_2__sync);
        Vtb_axi_bridge___024root___eval_initial__TOP__Vtiming__1____Vfork_2__3(vlSelf, __Vfork_2__sync);
        co_await __Vfork_2__sync.join(nullptr, "..\\..\\verification\\tb\\tb_axi_bridge.sv", 
                                      475);
    }
    while ((1U & (~ (((6U == vlSelfRef.tb_axi_bridge__DOT__out_aw) 
                      & (0x00000012U == vlSelfRef.tb_axi_bridge__DOT__out_w)) 
                     & (6U == vlSelfRef.tb_axi_bridge__DOT__out_ar))))) {
        Vtb_axi_bridge___024root____VbeforeTrig_h955be2db__0(vlSelf, 
                                                             "@( (((32'sh6 == tb_axi_bridge.out_aw) & (32'sh12 == tb_axi_bridge.out_w)) & (32'sh6 == tb_axi_bridge.out_ar)))");
        co_await vlSelfRef.__VtrigSched_h955be2db__0.trigger(1U, 
                                                             nullptr, 
                                                             "@( (((32'sh6 == tb_axi_bridge.out_aw) & (32'sh12 == tb_axi_bridge.out_w)) & (32'sh6 == tb_axi_bridge.out_ar)))", 
                                                             "..\\..\\verification\\tb\\tb_axi_bridge.sv", 
                                                             484);
    }
    tb_axi_bridge__DOT__unnamedblk1_4__DOT____Vrepeat3 = 8U;
    while (VL_LTS_III(32, 0U, tb_axi_bridge__DOT__unnamedblk1_4__DOT____Vrepeat3)) {
        Vtb_axi_bridge___024root____VbeforeTrig_h046e831a__0(vlSelf, 
                                                             "@(posedge tb_axi_bridge.i_clk_mgr)");
        co_await vlSelfRef.__VtrigSched_h046e831a__0.trigger(0U, 
                                                             nullptr, 
                                                             "@(posedge tb_axi_bridge.i_clk_mgr)", 
                                                             "..\\..\\verification\\tb\\tb_axi_bridge.sv", 
                                                             485);
        tb_axi_bridge__DOT__unnamedblk1_4__DOT____Vrepeat3 
            = (tb_axi_bridge__DOT__unnamedblk1_4__DOT____Vrepeat3 
               - (IData)(1U));
    }
    {
        VlForkSync __Vfork_3__sync;
        __Vfork_3__sync.init(3U, nullptr);
        Vtb_axi_bridge___024root___eval_initial__TOP__Vtiming__1____Vfork_3__0(vlSelf, __Vfork_3__sync);
        Vtb_axi_bridge___024root___eval_initial__TOP__Vtiming__1____Vfork_3__1(vlSelf, __Vfork_3__sync);
        Vtb_axi_bridge___024root___eval_initial__TOP__Vtiming__1____Vfork_3__2(vlSelf, __Vfork_3__sync);
        co_await __Vfork_3__sync.join(nullptr, "..\\..\\verification\\tb\\tb_axi_bridge.sv", 
                                      489);
    }
    while ((1U & (~ ((6U == vlSelfRef.tb_axi_bridge__DOT__out_b) 
                     & (0x00000012U == vlSelfRef.tb_axi_bridge__DOT__out_r))))) {
        Vtb_axi_bridge___024root____VbeforeTrig_h18cb2d65__0(vlSelf, 
                                                             "@( ((32'sh6 == tb_axi_bridge.out_b) & (32'sh12 == tb_axi_bridge.out_r)))");
        co_await vlSelfRef.__VtrigSched_h18cb2d65__0.trigger(1U, 
                                                             nullptr, 
                                                             "@( ((32'sh6 == tb_axi_bridge.out_b) & (32'sh12 == tb_axi_bridge.out_r)))", 
                                                             "..\\..\\verification\\tb\\tb_axi_bridge.sv", 
                                                             497);
    }
    tb_axi_bridge__DOT__unnamedblk1_5__DOT____Vrepeat4 = 0x0000000aU;
    while (VL_LTS_III(32, 0U, tb_axi_bridge__DOT__unnamedblk1_5__DOT____Vrepeat4)) {
        Vtb_axi_bridge___024root____VbeforeTrig_h8c92a665__0(vlSelf, 
                                                             "@(posedge tb_axi_bridge.i_clk_sub)");
        co_await vlSelfRef.__VtrigSched_h8c92a665__0.trigger(0U, 
                                                             nullptr, 
                                                             "@(posedge tb_axi_bridge.i_clk_sub)", 
                                                             "..\\..\\verification\\tb\\tb_axi_bridge.sv", 
                                                             498);
        tb_axi_bridge__DOT__unnamedblk1_5__DOT____Vrepeat4 
            = (tb_axi_bridge__DOT__unnamedblk1_5__DOT____Vrepeat4 
               - (IData)(1U));
    }
    tb_axi_bridge__DOT__assertion_fail_total = 0U;
    tb_axi_bridge__DOT__assertion_never_total = 0U;
    if ((0U == vlSelfRef.tb_axi_bridge__DOT__assertion_hits[0U])) {
        tb_axi_bridge__DOT__assertion_never_total = 
            ((IData)(1U) + tb_axi_bridge__DOT__assertion_never_total);
    }
    tb_axi_bridge__DOT__assertion_fail_total = vlSelfRef.tb_axi_bridge__DOT__assertion_fails[0U];
    VL_WRITEF_NX("AXI-SVA-00 hits=%0d fails=%0d\n",2
                 , '~',32,vlSelfRef.tb_axi_bridge__DOT__assertion_hits[0U]
                 , '~',32,vlSelfRef.tb_axi_bridge__DOT__assertion_fails[0U]);
    if ((0U == vlSelfRef.tb_axi_bridge__DOT__assertion_hits[1U])) {
        tb_axi_bridge__DOT__assertion_never_total = 
            ((IData)(1U) + tb_axi_bridge__DOT__assertion_never_total);
    }
    tb_axi_bridge__DOT__assertion_fail_total = (tb_axi_bridge__DOT__assertion_fail_total 
                                                + vlSelfRef.tb_axi_bridge__DOT__assertion_fails[1U]);
    VL_WRITEF_NX("AXI-SVA-01 hits=%0d fails=%0d\n",2
                 , '~',32,vlSelfRef.tb_axi_bridge__DOT__assertion_hits[1U]
                 , '~',32,vlSelfRef.tb_axi_bridge__DOT__assertion_fails[1U]);
    if ((0U == vlSelfRef.tb_axi_bridge__DOT__assertion_hits[2U])) {
        tb_axi_bridge__DOT__assertion_never_total = 
            ((IData)(1U) + tb_axi_bridge__DOT__assertion_never_total);
    }
    tb_axi_bridge__DOT__assertion_fail_total = (tb_axi_bridge__DOT__assertion_fail_total 
                                                + vlSelfRef.tb_axi_bridge__DOT__assertion_fails[2U]);
    VL_WRITEF_NX("AXI-SVA-02 hits=%0d fails=%0d\n",2
                 , '~',32,vlSelfRef.tb_axi_bridge__DOT__assertion_hits[2U]
                 , '~',32,vlSelfRef.tb_axi_bridge__DOT__assertion_fails[2U]);
    if ((0U == vlSelfRef.tb_axi_bridge__DOT__assertion_hits[3U])) {
        tb_axi_bridge__DOT__assertion_never_total = 
            ((IData)(1U) + tb_axi_bridge__DOT__assertion_never_total);
    }
    tb_axi_bridge__DOT__assertion_fail_total = (tb_axi_bridge__DOT__assertion_fail_total 
                                                + vlSelfRef.tb_axi_bridge__DOT__assertion_fails[3U]);
    VL_WRITEF_NX("AXI-SVA-03 hits=%0d fails=%0d\n",2
                 , '~',32,vlSelfRef.tb_axi_bridge__DOT__assertion_hits[3U]
                 , '~',32,vlSelfRef.tb_axi_bridge__DOT__assertion_fails[3U]);
    if ((0U == vlSelfRef.tb_axi_bridge__DOT__assertion_hits[4U])) {
        tb_axi_bridge__DOT__assertion_never_total = 
            ((IData)(1U) + tb_axi_bridge__DOT__assertion_never_total);
    }
    tb_axi_bridge__DOT__assertion_fail_total = (tb_axi_bridge__DOT__assertion_fail_total 
                                                + vlSelfRef.tb_axi_bridge__DOT__assertion_fails[4U]);
    VL_WRITEF_NX("AXI-SVA-04 hits=%0d fails=%0d\n",2
                 , '~',32,vlSelfRef.tb_axi_bridge__DOT__assertion_hits[4U]
                 , '~',32,vlSelfRef.tb_axi_bridge__DOT__assertion_fails[4U]);
    if ((0U == vlSelfRef.tb_axi_bridge__DOT__assertion_hits[5U])) {
        tb_axi_bridge__DOT__assertion_never_total = 
            ((IData)(1U) + tb_axi_bridge__DOT__assertion_never_total);
    }
    tb_axi_bridge__DOT__assertion_fail_total = (tb_axi_bridge__DOT__assertion_fail_total 
                                                + vlSelfRef.tb_axi_bridge__DOT__assertion_fails[5U]);
    VL_WRITEF_NX("AXI-SVA-05 hits=%0d fails=%0d\n",2
                 , '~',32,vlSelfRef.tb_axi_bridge__DOT__assertion_hits[5U]
                 , '~',32,vlSelfRef.tb_axi_bridge__DOT__assertion_fails[5U]);
    if ((0U == vlSelfRef.tb_axi_bridge__DOT__assertion_hits[6U])) {
        tb_axi_bridge__DOT__assertion_never_total = 
            ((IData)(1U) + tb_axi_bridge__DOT__assertion_never_total);
    }
    tb_axi_bridge__DOT__assertion_fail_total = (tb_axi_bridge__DOT__assertion_fail_total 
                                                + vlSelfRef.tb_axi_bridge__DOT__assertion_fails[6U]);
    VL_WRITEF_NX("AXI-SVA-06 hits=%0d fails=%0d\n",2
                 , '~',32,vlSelfRef.tb_axi_bridge__DOT__assertion_hits[6U]
                 , '~',32,vlSelfRef.tb_axi_bridge__DOT__assertion_fails[6U]);
    if ((0U == vlSelfRef.tb_axi_bridge__DOT__assertion_hits[7U])) {
        tb_axi_bridge__DOT__assertion_never_total = 
            ((IData)(1U) + tb_axi_bridge__DOT__assertion_never_total);
    }
    tb_axi_bridge__DOT__assertion_fail_total = (tb_axi_bridge__DOT__assertion_fail_total 
                                                + vlSelfRef.tb_axi_bridge__DOT__assertion_fails[7U]);
    VL_WRITEF_NX("AXI-SVA-07 hits=%0d fails=%0d\n",2
                 , '~',32,vlSelfRef.tb_axi_bridge__DOT__assertion_hits[7U]
                 , '~',32,vlSelfRef.tb_axi_bridge__DOT__assertion_fails[7U]);
    if ((0U == vlSelfRef.tb_axi_bridge__DOT__assertion_hits[8U])) {
        tb_axi_bridge__DOT__assertion_never_total = 
            ((IData)(1U) + tb_axi_bridge__DOT__assertion_never_total);
    }
    tb_axi_bridge__DOT__assertion_fail_total = (tb_axi_bridge__DOT__assertion_fail_total 
                                                + vlSelfRef.tb_axi_bridge__DOT__assertion_fails[8U]);
    VL_WRITEF_NX("AXI-SVA-08 hits=%0d fails=%0d\n",2
                 , '~',32,vlSelfRef.tb_axi_bridge__DOT__assertion_hits[8U]
                 , '~',32,vlSelfRef.tb_axi_bridge__DOT__assertion_fails[8U]);
    if ((0U == vlSelfRef.tb_axi_bridge__DOT__assertion_hits[9U])) {
        tb_axi_bridge__DOT__assertion_never_total = 
            ((IData)(1U) + tb_axi_bridge__DOT__assertion_never_total);
    }
    tb_axi_bridge__DOT__assertion_fail_total = (tb_axi_bridge__DOT__assertion_fail_total 
                                                + vlSelfRef.tb_axi_bridge__DOT__assertion_fails[9U]);
    VL_WRITEF_NX("AXI-SVA-09 hits=%0d fails=%0d\n",2
                 , '~',32,vlSelfRef.tb_axi_bridge__DOT__assertion_hits[9U]
                 , '~',32,vlSelfRef.tb_axi_bridge__DOT__assertion_fails[9U]);
    if ((0U == vlSelfRef.tb_axi_bridge__DOT__assertion_hits[10U])) {
        tb_axi_bridge__DOT__assertion_never_total = 
            ((IData)(1U) + tb_axi_bridge__DOT__assertion_never_total);
    }
    tb_axi_bridge__DOT__assertion_fail_total = (tb_axi_bridge__DOT__assertion_fail_total 
                                                + vlSelfRef.tb_axi_bridge__DOT__assertion_fails[10U]);
    VL_WRITEF_NX("AXI-SVA-10 hits=%0d fails=%0d\n",2
                 , '~',32,vlSelfRef.tb_axi_bridge__DOT__assertion_hits[10U]
                 , '~',32,vlSelfRef.tb_axi_bridge__DOT__assertion_fails[10U]);
    if ((0U == vlSelfRef.tb_axi_bridge__DOT__assertion_hits[11U])) {
        tb_axi_bridge__DOT__assertion_never_total = 
            ((IData)(1U) + tb_axi_bridge__DOT__assertion_never_total);
    }
    tb_axi_bridge__DOT__assertion_fail_total = (tb_axi_bridge__DOT__assertion_fail_total 
                                                + vlSelfRef.tb_axi_bridge__DOT__assertion_fails[11U]);
    VL_WRITEF_NX("AXI-SVA-11 hits=%0d fails=%0d\n",2
                 , '~',32,vlSelfRef.tb_axi_bridge__DOT__assertion_hits[11U]
                 , '~',32,vlSelfRef.tb_axi_bridge__DOT__assertion_fails[11U]);
    if ((0U == vlSelfRef.tb_axi_bridge__DOT__assertion_hits[12U])) {
        tb_axi_bridge__DOT__assertion_never_total = 
            ((IData)(1U) + tb_axi_bridge__DOT__assertion_never_total);
    }
    tb_axi_bridge__DOT__assertion_fail_total = (tb_axi_bridge__DOT__assertion_fail_total 
                                                + vlSelfRef.tb_axi_bridge__DOT__assertion_fails[12U]);
    VL_WRITEF_NX("AXI-SVA-12 hits=%0d fails=%0d\n",2
                 , '~',32,vlSelfRef.tb_axi_bridge__DOT__assertion_hits[12U]
                 , '~',32,vlSelfRef.tb_axi_bridge__DOT__assertion_fails[12U]);
    if ((0U == vlSelfRef.tb_axi_bridge__DOT__assertion_hits[13U])) {
        tb_axi_bridge__DOT__assertion_never_total = 
            ((IData)(1U) + tb_axi_bridge__DOT__assertion_never_total);
    }
    tb_axi_bridge__DOT__assertion_fail_total = (tb_axi_bridge__DOT__assertion_fail_total 
                                                + vlSelfRef.tb_axi_bridge__DOT__assertion_fails[13U]);
    VL_WRITEF_NX("AXI-SVA-13 hits=%0d fails=%0d\n",2
                 , '~',32,vlSelfRef.tb_axi_bridge__DOT__assertion_hits[13U]
                 , '~',32,vlSelfRef.tb_axi_bridge__DOT__assertion_fails[13U]);
    if ((0U == vlSelfRef.tb_axi_bridge__DOT__assertion_hits[14U])) {
        tb_axi_bridge__DOT__assertion_never_total = 
            ((IData)(1U) + tb_axi_bridge__DOT__assertion_never_total);
    }
    tb_axi_bridge__DOT__assertion_fail_total = (tb_axi_bridge__DOT__assertion_fail_total 
                                                + vlSelfRef.tb_axi_bridge__DOT__assertion_fails[14U]);
    VL_WRITEF_NX("AXI-SVA-14 hits=%0d fails=%0d\n",2
                 , '~',32,vlSelfRef.tb_axi_bridge__DOT__assertion_hits[14U]
                 , '~',32,vlSelfRef.tb_axi_bridge__DOT__assertion_fails[14U]);
    if ((0U == vlSelfRef.tb_axi_bridge__DOT__assertion_hits[15U])) {
        tb_axi_bridge__DOT__assertion_never_total = 
            ((IData)(1U) + tb_axi_bridge__DOT__assertion_never_total);
    }
    tb_axi_bridge__DOT__assertion_fail_total = (tb_axi_bridge__DOT__assertion_fail_total 
                                                + vlSelfRef.tb_axi_bridge__DOT__assertion_fails[15U]);
    VL_WRITEF_NX("AXI-SVA-15 hits=%0d fails=%0d\n",2
                 , '~',32,vlSelfRef.tb_axi_bridge__DOT__assertion_hits[15U]
                 , '~',32,vlSelfRef.tb_axi_bridge__DOT__assertion_fails[15U]);
    if ((0U == vlSelfRef.tb_axi_bridge__DOT__assertion_hits[16U])) {
        tb_axi_bridge__DOT__assertion_never_total = 
            ((IData)(1U) + tb_axi_bridge__DOT__assertion_never_total);
    }
    tb_axi_bridge__DOT__assertion_fail_total = (tb_axi_bridge__DOT__assertion_fail_total 
                                                + vlSelfRef.tb_axi_bridge__DOT__assertion_fails[16U]);
    VL_WRITEF_NX("AXI-SVA-16 hits=%0d fails=%0d\n",2
                 , '~',32,vlSelfRef.tb_axi_bridge__DOT__assertion_hits[16U]
                 , '~',32,vlSelfRef.tb_axi_bridge__DOT__assertion_fails[16U]);
    if ((0U == vlSelfRef.tb_axi_bridge__DOT__assertion_hits[17U])) {
        tb_axi_bridge__DOT__assertion_never_total = 
            ((IData)(1U) + tb_axi_bridge__DOT__assertion_never_total);
    }
    tb_axi_bridge__DOT__assertion_fail_total = (tb_axi_bridge__DOT__assertion_fail_total 
                                                + vlSelfRef.tb_axi_bridge__DOT__assertion_fails[17U]);
    VL_WRITEF_NX("AXI-SVA-17 hits=%0d fails=%0d\n",2
                 , '~',32,vlSelfRef.tb_axi_bridge__DOT__assertion_hits[17U]
                 , '~',32,vlSelfRef.tb_axi_bridge__DOT__assertion_fails[17U]);
    if ((0U == vlSelfRef.tb_axi_bridge__DOT__assertion_hits[18U])) {
        tb_axi_bridge__DOT__assertion_never_total = 
            ((IData)(1U) + tb_axi_bridge__DOT__assertion_never_total);
    }
    tb_axi_bridge__DOT__assertion_fail_total = (tb_axi_bridge__DOT__assertion_fail_total 
                                                + vlSelfRef.tb_axi_bridge__DOT__assertion_fails[18U]);
    VL_WRITEF_NX("AXI-SVA-18 hits=%0d fails=%0d\n",2
                 , '~',32,vlSelfRef.tb_axi_bridge__DOT__assertion_hits[18U]
                 , '~',32,vlSelfRef.tb_axi_bridge__DOT__assertion_fails[18U]);
    if ((0U == vlSelfRef.tb_axi_bridge__DOT__assertion_hits[19U])) {
        tb_axi_bridge__DOT__assertion_never_total = 
            ((IData)(1U) + tb_axi_bridge__DOT__assertion_never_total);
    }
    tb_axi_bridge__DOT__assertion_fail_total = (tb_axi_bridge__DOT__assertion_fail_total 
                                                + vlSelfRef.tb_axi_bridge__DOT__assertion_fails[19U]);
    VL_WRITEF_NX("AXI-SVA-19 hits=%0d fails=%0d\n",2
                 , '~',32,vlSelfRef.tb_axi_bridge__DOT__assertion_hits[19U]
                 , '~',32,vlSelfRef.tb_axi_bridge__DOT__assertion_fails[19U]);
    if ((0U == vlSelfRef.tb_axi_bridge__DOT__assertion_hits[20U])) {
        tb_axi_bridge__DOT__assertion_never_total = 
            ((IData)(1U) + tb_axi_bridge__DOT__assertion_never_total);
    }
    tb_axi_bridge__DOT__assertion_fail_total = (tb_axi_bridge__DOT__assertion_fail_total 
                                                + vlSelfRef.tb_axi_bridge__DOT__assertion_fails[20U]);
    VL_WRITEF_NX("AXI-SVA-20 hits=%0d fails=%0d\n",2
                 , '~',32,vlSelfRef.tb_axi_bridge__DOT__assertion_hits[20U]
                 , '~',32,vlSelfRef.tb_axi_bridge__DOT__assertion_fails[20U]);
    if ((0U == vlSelfRef.tb_axi_bridge__DOT__assertion_hits[21U])) {
        tb_axi_bridge__DOT__assertion_never_total = 
            ((IData)(1U) + tb_axi_bridge__DOT__assertion_never_total);
    }
    tb_axi_bridge__DOT__assertion_fail_total = (tb_axi_bridge__DOT__assertion_fail_total 
                                                + vlSelfRef.tb_axi_bridge__DOT__assertion_fails[21U]);
    VL_WRITEF_NX("AXI-SVA-21 hits=%0d fails=%0d\n",2
                 , '~',32,vlSelfRef.tb_axi_bridge__DOT__assertion_hits[21U]
                 , '~',32,vlSelfRef.tb_axi_bridge__DOT__assertion_fails[21U]);
    if ((0U == vlSelfRef.tb_axi_bridge__DOT__assertion_hits[22U])) {
        tb_axi_bridge__DOT__assertion_never_total = 
            ((IData)(1U) + tb_axi_bridge__DOT__assertion_never_total);
    }
    tb_axi_bridge__DOT__assertion_fail_total = (tb_axi_bridge__DOT__assertion_fail_total 
                                                + vlSelfRef.tb_axi_bridge__DOT__assertion_fails[22U]);
    VL_WRITEF_NX("AXI-SVA-22 hits=%0d fails=%0d\n",2
                 , '~',32,vlSelfRef.tb_axi_bridge__DOT__assertion_hits[22U]
                 , '~',32,vlSelfRef.tb_axi_bridge__DOT__assertion_fails[22U]);
    if ((0U == vlSelfRef.tb_axi_bridge__DOT__assertion_hits[23U])) {
        tb_axi_bridge__DOT__assertion_never_total = 
            ((IData)(1U) + tb_axi_bridge__DOT__assertion_never_total);
    }
    tb_axi_bridge__DOT__assertion_fail_total = (tb_axi_bridge__DOT__assertion_fail_total 
                                                + vlSelfRef.tb_axi_bridge__DOT__assertion_fails[23U]);
    VL_WRITEF_NX("AXI-SVA-23 hits=%0d fails=%0d\n",2
                 , '~',32,vlSelfRef.tb_axi_bridge__DOT__assertion_hits[23U]
                 , '~',32,vlSelfRef.tb_axi_bridge__DOT__assertion_fails[23U]);
    if ((0U == vlSelfRef.tb_axi_bridge__DOT__assertion_hits[24U])) {
        tb_axi_bridge__DOT__assertion_never_total = 
            ((IData)(1U) + tb_axi_bridge__DOT__assertion_never_total);
    }
    tb_axi_bridge__DOT__assertion_fail_total = (tb_axi_bridge__DOT__assertion_fail_total 
                                                + vlSelfRef.tb_axi_bridge__DOT__assertion_fails[24U]);
    VL_WRITEF_NX("AXI-SVA-24 hits=%0d fails=%0d\n",2
                 , '~',32,vlSelfRef.tb_axi_bridge__DOT__assertion_hits[24U]
                 , '~',32,vlSelfRef.tb_axi_bridge__DOT__assertion_fails[24U]);
    if ((0U == vlSelfRef.tb_axi_bridge__DOT__assertion_hits[25U])) {
        tb_axi_bridge__DOT__assertion_never_total = 
            ((IData)(1U) + tb_axi_bridge__DOT__assertion_never_total);
    }
    tb_axi_bridge__DOT__assertion_fail_total = (tb_axi_bridge__DOT__assertion_fail_total 
                                                + vlSelfRef.tb_axi_bridge__DOT__assertion_fails[25U]);
    VL_WRITEF_NX("AXI-SVA-25 hits=%0d fails=%0d\n",2
                 , '~',32,vlSelfRef.tb_axi_bridge__DOT__assertion_hits[25U]
                 , '~',32,vlSelfRef.tb_axi_bridge__DOT__assertion_fails[25U]);
    if ((0U == vlSelfRef.tb_axi_bridge__DOT__assertion_hits[26U])) {
        tb_axi_bridge__DOT__assertion_never_total = 
            ((IData)(1U) + tb_axi_bridge__DOT__assertion_never_total);
    }
    tb_axi_bridge__DOT__assertion_fail_total = (tb_axi_bridge__DOT__assertion_fail_total 
                                                + vlSelfRef.tb_axi_bridge__DOT__assertion_fails[26U]);
    VL_WRITEF_NX("AXI-SVA-26 hits=%0d fails=%0d\n",2
                 , '~',32,vlSelfRef.tb_axi_bridge__DOT__assertion_hits[26U]
                 , '~',32,vlSelfRef.tb_axi_bridge__DOT__assertion_fails[26U]);
    if ((0U == vlSelfRef.tb_axi_bridge__DOT__assertion_hits[27U])) {
        tb_axi_bridge__DOT__assertion_never_total = 
            ((IData)(1U) + tb_axi_bridge__DOT__assertion_never_total);
    }
    tb_axi_bridge__DOT__assertion_fail_total = (tb_axi_bridge__DOT__assertion_fail_total 
                                                + vlSelfRef.tb_axi_bridge__DOT__assertion_fails[27U]);
    VL_WRITEF_NX("AXI-SVA-27 hits=%0d fails=%0d\n",2
                 , '~',32,vlSelfRef.tb_axi_bridge__DOT__assertion_hits[27U]
                 , '~',32,vlSelfRef.tb_axi_bridge__DOT__assertion_fails[27U]);
    if ((0U == vlSelfRef.tb_axi_bridge__DOT__assertion_hits[28U])) {
        tb_axi_bridge__DOT__assertion_never_total = 
            ((IData)(1U) + tb_axi_bridge__DOT__assertion_never_total);
    }
    tb_axi_bridge__DOT__assertion_fail_total = (tb_axi_bridge__DOT__assertion_fail_total 
                                                + vlSelfRef.tb_axi_bridge__DOT__assertion_fails[28U]);
    VL_WRITEF_NX("AXI-SVA-28 hits=%0d fails=%0d\n",2
                 , '~',32,vlSelfRef.tb_axi_bridge__DOT__assertion_hits[28U]
                 , '~',32,vlSelfRef.tb_axi_bridge__DOT__assertion_fails[28U]);
    if ((0U == vlSelfRef.tb_axi_bridge__DOT__assertion_hits[29U])) {
        tb_axi_bridge__DOT__assertion_never_total = 
            ((IData)(1U) + tb_axi_bridge__DOT__assertion_never_total);
    }
    tb_axi_bridge__DOT__assertion_fail_total = (tb_axi_bridge__DOT__assertion_fail_total 
                                                + vlSelfRef.tb_axi_bridge__DOT__assertion_fails[29U]);
    VL_WRITEF_NX("AXI-SVA-29 hits=%0d fails=%0d\n",2
                 , '~',32,vlSelfRef.tb_axi_bridge__DOT__assertion_hits[29U]
                 , '~',32,vlSelfRef.tb_axi_bridge__DOT__assertion_fails[29U]);
    if ((0U == vlSelfRef.tb_axi_bridge__DOT__assertion_hits[30U])) {
        tb_axi_bridge__DOT__assertion_never_total = 
            ((IData)(1U) + tb_axi_bridge__DOT__assertion_never_total);
    }
    tb_axi_bridge__DOT__assertion_fail_total = (tb_axi_bridge__DOT__assertion_fail_total 
                                                + vlSelfRef.tb_axi_bridge__DOT__assertion_fails[30U]);
    VL_WRITEF_NX("AXI-SVA-30 hits=%0d fails=%0d\n",2
                 , '~',32,vlSelfRef.tb_axi_bridge__DOT__assertion_hits[30U]
                 , '~',32,vlSelfRef.tb_axi_bridge__DOT__assertion_fails[30U]);
    if ((0U == vlSelfRef.tb_axi_bridge__DOT__assertion_hits[31U])) {
        tb_axi_bridge__DOT__assertion_never_total = 
            ((IData)(1U) + tb_axi_bridge__DOT__assertion_never_total);
    }
    tb_axi_bridge__DOT__assertion_fail_total = (tb_axi_bridge__DOT__assertion_fail_total 
                                                + vlSelfRef.tb_axi_bridge__DOT__assertion_fails[31U]);
    VL_WRITEF_NX("AXI-SVA-31 hits=%0d fails=%0d\n",2
                 , '~',32,vlSelfRef.tb_axi_bridge__DOT__assertion_hits[31U]
                 , '~',32,vlSelfRef.tb_axi_bridge__DOT__assertion_fails[31U]);
    if ((0U == vlSelfRef.tb_axi_bridge__DOT__assertion_hits[32U])) {
        tb_axi_bridge__DOT__assertion_never_total = 
            ((IData)(1U) + tb_axi_bridge__DOT__assertion_never_total);
    }
    tb_axi_bridge__DOT__assertion_fail_total = (tb_axi_bridge__DOT__assertion_fail_total 
                                                + vlSelfRef.tb_axi_bridge__DOT__assertion_fails[32U]);
    VL_WRITEF_NX("AXI-SVA-32 hits=%0d fails=%0d\n",2
                 , '~',32,vlSelfRef.tb_axi_bridge__DOT__assertion_hits[32U]
                 , '~',32,vlSelfRef.tb_axi_bridge__DOT__assertion_fails[32U]);
    if ((0U == vlSelfRef.tb_axi_bridge__DOT__assertion_hits[33U])) {
        tb_axi_bridge__DOT__assertion_never_total = 
            ((IData)(1U) + tb_axi_bridge__DOT__assertion_never_total);
    }
    tb_axi_bridge__DOT__assertion_fail_total = (tb_axi_bridge__DOT__assertion_fail_total 
                                                + vlSelfRef.tb_axi_bridge__DOT__assertion_fails[33U]);
    VL_WRITEF_NX("AXI-SVA-33 hits=%0d fails=%0d\n",2
                 , '~',32,vlSelfRef.tb_axi_bridge__DOT__assertion_hits[33U]
                 , '~',32,vlSelfRef.tb_axi_bridge__DOT__assertion_fails[33U]);
    if ((0U == vlSelfRef.tb_axi_bridge__DOT__assertion_hits[34U])) {
        tb_axi_bridge__DOT__assertion_never_total = 
            ((IData)(1U) + tb_axi_bridge__DOT__assertion_never_total);
    }
    tb_axi_bridge__DOT__assertion_fail_total = (tb_axi_bridge__DOT__assertion_fail_total 
                                                + vlSelfRef.tb_axi_bridge__DOT__assertion_fails[34U]);
    VL_WRITEF_NX("AXI-SVA-34 hits=%0d fails=%0d\n",2
                 , '~',32,vlSelfRef.tb_axi_bridge__DOT__assertion_hits[34U]
                 , '~',32,vlSelfRef.tb_axi_bridge__DOT__assertion_fails[34U]);
    if ((0U == vlSelfRef.tb_axi_bridge__DOT__assertion_hits[35U])) {
        tb_axi_bridge__DOT__assertion_never_total = 
            ((IData)(1U) + tb_axi_bridge__DOT__assertion_never_total);
    }
    tb_axi_bridge__DOT__assertion_fail_total = (tb_axi_bridge__DOT__assertion_fail_total 
                                                + vlSelfRef.tb_axi_bridge__DOT__assertion_fails[35U]);
    VL_WRITEF_NX("AXI-SVA-35 hits=%0d fails=%0d\nTRANSFER COUNTS: AW=%0d W=%0d B=%0d AR=%0d R=%0d\n",7
                 , '~',32,vlSelfRef.tb_axi_bridge__DOT__assertion_hits[35U]
                 , '~',32,vlSelfRef.tb_axi_bridge__DOT__assertion_fails[35U]
                 , '~',32,vlSelfRef.tb_axi_bridge__DOT__out_aw
                 , '~',32,vlSelfRef.tb_axi_bridge__DOT__out_w
                 , '~',32,vlSelfRef.tb_axi_bridge__DOT__out_b
                 , '~',32,vlSelfRef.tb_axi_bridge__DOT__out_ar
                 , '~',32,vlSelfRef.tb_axi_bridge__DOT__out_r);
    if (VL_UNLIKELY((((0U != tb_axi_bridge__DOT__assertion_fail_total) 
                      | (0U != tb_axi_bridge__DOT__assertion_never_total))))) {
        VL_WRITEF_NX("[%0t] %%Fatal: tb_axi_bridge.sv:509: Assertion failed in %m: verification failed: failures=%0d never=%0d\n",5, 'M',vlSymsp->name(),"tb_axi_bridge", 'T',-9
                     , '#',64,VL_TIME_UNITED_Q(1000)
                     , '~',32,tb_axi_bridge__DOT__assertion_fail_total
                     , '~',32,tb_axi_bridge__DOT__assertion_never_total);
        VL_STOP_MT("..\\..\\verification\\tb\\tb_axi_bridge.sv", 509, "", false);
    }
    VL_WRITEF_NX("assertion failures: 0, assertions never exercised: 0\n",0);
    VL_FINISH_MT("..\\..\\verification\\tb\\tb_axi_bridge.sv", 511, "");
    co_return;
}

VlCoroutine Vtb_axi_bridge___024root___eval_initial__TOP__Vtiming__1____Vfork_3__2(Vtb_axi_bridge___024root* vlSelf, VlForkSync __Vfork_3__sync) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_axi_bridge___024root___eval_initial__TOP__Vtiming__1____Vfork_3__2\n"); );
    Vtb_axi_bridge__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Body
    co_await vlSelfRef.__VdlySched.delay(0x000000000007a120ULL, 
                                         nullptr, "..\\..\\verification\\tb\\tb_axi_bridge.sv", 
                                         493);
    vlSelfRef.tb_axi_bridge__DOT__i_axi_bready = 1U;
    vlSelfRef.tb_axi_bridge__DOT__i_axi_rready = 1U;
    __Vfork_3__sync.done("..\\..\\verification\\tb\\tb_axi_bridge.sv", 
                         492);
    co_return;
}

VlCoroutine Vtb_axi_bridge___024root___eval_initial__TOP__Vtiming__1____Vfork_3__1(Vtb_axi_bridge___024root* vlSelf, VlForkSync __Vfork_3__sync) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_axi_bridge___024root___eval_initial__TOP__Vtiming__1____Vfork_3__1\n"); );
    Vtb_axi_bridge__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Locals
    IData/*31:0*/ __Vtask_tb_axi_bridge__DOT__send_r__first_135;
    __Vtask_tb_axi_bridge__DOT__send_r__first_135 = 0;
    IData/*31:0*/ __Vtask_tb_axi_bridge__DOT__send_r__count_136;
    __Vtask_tb_axi_bridge__DOT__send_r__count_136 = 0;
    IData/*31:0*/ __Vtask_tb_axi_bridge__DOT__send_r__k_137;
    __Vtask_tb_axi_bridge__DOT__send_r__k_137 = 0;
    // Body
    __Vtask_tb_axi_bridge__DOT__send_r__count_136 = 0x00000012U;
    __Vtask_tb_axi_bridge__DOT__send_r__first_135 = 0U;
    __Vtask_tb_axi_bridge__DOT__send_r__k_137 = 0;
    __Vtask_tb_axi_bridge__DOT__send_r__k_137 = __Vtask_tb_axi_bridge__DOT__send_r__first_135;
    while (VL_LTS_III(32, __Vtask_tb_axi_bridge__DOT__send_r__k_137, 
                      (__Vtask_tb_axi_bridge__DOT__send_r__first_135 
                       + __Vtask_tb_axi_bridge__DOT__send_r__count_136))) {
        Vtb_axi_bridge___024root____VbeforeTrig_h046e81df__0(vlSelf, 
                                                             "@(negedge tb_axi_bridge.i_clk_mgr)");
        co_await vlSelfRef.__VtrigSched_h046e81df__0.trigger(0U, 
                                                             nullptr, 
                                                             "@(negedge tb_axi_bridge.i_clk_mgr)", 
                                                             "..\\..\\verification\\tb\\tb_axi_bridge.sv", 
                                                             405);
        vlSelfRef.tb_axi_bridge__DOT__i_axi_rvalid = 1U;
        vlSelfRef.tb_axi_bridge__DOT__i_axi_rid = (0x0000000fU 
                                                   & (VL_DIVS_III(32, __Vtask_tb_axi_bridge__DOT__send_r__k_137, (IData)(3U)) 
                                                      + vlSelfRef.tb_axi_bridge__DOT__seed_value));
        vlSelfRef.tb_axi_bridge__DOT__i_axi_rdata = 
            ((IData)(0x80000000U) + (__Vtask_tb_axi_bridge__DOT__send_r__k_137 
                                     + vlSelfRef.tb_axi_bridge__DOT__seed_value));
        vlSelfRef.tb_axi_bridge__DOT__i_axi_rresp = 
            (3U & VL_MODDIVS_III(32, __Vtask_tb_axi_bridge__DOT__send_r__k_137, (IData)(4U)));
        vlSelfRef.tb_axi_bridge__DOT__i_axi_rlast = 
            (2U == VL_MODDIVS_III(32, __Vtask_tb_axi_bridge__DOT__send_r__k_137, (IData)(3U)));
        do {
            Vtb_axi_bridge___024root____VbeforeTrig_h046e831a__0(vlSelf, 
                                                                 "@(posedge tb_axi_bridge.i_clk_mgr)");
            co_await vlSelfRef.__VtrigSched_h046e831a__0.trigger(0U, 
                                                                 nullptr, 
                                                                 "@(posedge tb_axi_bridge.i_clk_mgr)", 
                                                                 "..\\..\\verification\\tb\\tb_axi_bridge.sv", 
                                                                 412);
        } while ((1U & (~ (IData)(vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_r__DOT__o_axi_rready))));
        __Vtask_tb_axi_bridge__DOT__send_r__k_137 = 
            ((IData)(1U) + __Vtask_tb_axi_bridge__DOT__send_r__k_137);
    }
    Vtb_axi_bridge___024root____VbeforeTrig_h046e81df__0(vlSelf, 
                                                         "@(negedge tb_axi_bridge.i_clk_mgr)");
    co_await vlSelfRef.__VtrigSched_h046e81df__0.trigger(0U, 
                                                         nullptr, 
                                                         "@(negedge tb_axi_bridge.i_clk_mgr)", 
                                                         "..\\..\\verification\\tb\\tb_axi_bridge.sv", 
                                                         414);
    vlSelfRef.tb_axi_bridge__DOT__i_axi_rvalid = 0U;
    __Vfork_3__sync.done("..\\..\\verification\\tb\\tb_axi_bridge.sv", 
                         491);
    co_return;
}

VlCoroutine Vtb_axi_bridge___024root___eval_initial__TOP__Vtiming__1____Vfork_3__0(Vtb_axi_bridge___024root* vlSelf, VlForkSync __Vfork_3__sync) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_axi_bridge___024root___eval_initial__TOP__Vtiming__1____Vfork_3__0\n"); );
    Vtb_axi_bridge__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Locals
    IData/*31:0*/ __Vtask_tb_axi_bridge__DOT__send_b__first_132;
    __Vtask_tb_axi_bridge__DOT__send_b__first_132 = 0;
    IData/*31:0*/ __Vtask_tb_axi_bridge__DOT__send_b__count_133;
    __Vtask_tb_axi_bridge__DOT__send_b__count_133 = 0;
    IData/*31:0*/ __Vtask_tb_axi_bridge__DOT__send_b__k_134;
    __Vtask_tb_axi_bridge__DOT__send_b__k_134 = 0;
    // Body
    __Vtask_tb_axi_bridge__DOT__send_b__count_133 = 6U;
    __Vtask_tb_axi_bridge__DOT__send_b__first_132 = 0U;
    __Vtask_tb_axi_bridge__DOT__send_b__k_134 = 0;
    __Vtask_tb_axi_bridge__DOT__send_b__k_134 = __Vtask_tb_axi_bridge__DOT__send_b__first_132;
    while (VL_LTS_III(32, __Vtask_tb_axi_bridge__DOT__send_b__k_134, 
                      (__Vtask_tb_axi_bridge__DOT__send_b__first_132 
                       + __Vtask_tb_axi_bridge__DOT__send_b__count_133))) {
        Vtb_axi_bridge___024root____VbeforeTrig_h046e81df__0(vlSelf, 
                                                             "@(negedge tb_axi_bridge.i_clk_mgr)");
        co_await vlSelfRef.__VtrigSched_h046e81df__0.trigger(0U, 
                                                             nullptr, 
                                                             "@(negedge tb_axi_bridge.i_clk_mgr)", 
                                                             "..\\..\\verification\\tb\\tb_axi_bridge.sv", 
                                                             363);
        vlSelfRef.tb_axi_bridge__DOT__i_axi_bvalid = 1U;
        vlSelfRef.tb_axi_bridge__DOT__i_axi_bid = (0x0000000fU 
                                                   & (__Vtask_tb_axi_bridge__DOT__send_b__k_134 
                                                      + vlSelfRef.tb_axi_bridge__DOT__seed_value));
        vlSelfRef.tb_axi_bridge__DOT__i_axi_bresp = 
            (3U & VL_MODDIVS_III(32, __Vtask_tb_axi_bridge__DOT__send_b__k_134, (IData)(4U)));
        do {
            Vtb_axi_bridge___024root____VbeforeTrig_h046e831a__0(vlSelf, 
                                                                 "@(posedge tb_axi_bridge.i_clk_mgr)");
            co_await vlSelfRef.__VtrigSched_h046e831a__0.trigger(0U, 
                                                                 nullptr, 
                                                                 "@(posedge tb_axi_bridge.i_clk_mgr)", 
                                                                 "..\\..\\verification\\tb\\tb_axi_bridge.sv", 
                                                                 368);
        } while ((1U & (~ (IData)(vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_b__DOT__o_axi_bready))));
        __Vtask_tb_axi_bridge__DOT__send_b__k_134 = 
            ((IData)(1U) + __Vtask_tb_axi_bridge__DOT__send_b__k_134);
    }
    Vtb_axi_bridge___024root____VbeforeTrig_h046e81df__0(vlSelf, 
                                                         "@(negedge tb_axi_bridge.i_clk_mgr)");
    co_await vlSelfRef.__VtrigSched_h046e81df__0.trigger(0U, 
                                                         nullptr, 
                                                         "@(negedge tb_axi_bridge.i_clk_mgr)", 
                                                         "..\\..\\verification\\tb\\tb_axi_bridge.sv", 
                                                         370);
    vlSelfRef.tb_axi_bridge__DOT__i_axi_bvalid = 0U;
    __Vfork_3__sync.done("..\\..\\verification\\tb\\tb_axi_bridge.sv", 
                         490);
    co_return;
}

VlCoroutine Vtb_axi_bridge___024root___eval_initial__TOP__Vtiming__1____Vfork_2__3(Vtb_axi_bridge___024root* vlSelf, VlForkSync __Vfork_2__sync) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_axi_bridge___024root___eval_initial__TOP__Vtiming__1____Vfork_2__3\n"); );
    Vtb_axi_bridge__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Body
    co_await vlSelfRef.__VdlySched.delay(0x000000000007a120ULL, 
                                         nullptr, "..\\..\\verification\\tb\\tb_axi_bridge.sv", 
                                         480);
    vlSelfRef.tb_axi_bridge__DOT__i_axi_awready = 1U;
    vlSelfRef.tb_axi_bridge__DOT__i_axi_wready = 1U;
    vlSelfRef.tb_axi_bridge__DOT__i_axi_arready = 1U;
    __Vfork_2__sync.done("..\\..\\verification\\tb\\tb_axi_bridge.sv", 
                         479);
    co_return;
}

VlCoroutine Vtb_axi_bridge___024root___eval_initial__TOP__Vtiming__1____Vfork_2__2(Vtb_axi_bridge___024root* vlSelf, VlForkSync __Vfork_2__sync) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_axi_bridge___024root___eval_initial__TOP__Vtiming__1____Vfork_2__2\n"); );
    Vtb_axi_bridge__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Locals
    IData/*31:0*/ __Vtask_tb_axi_bridge__DOT__send_ar__first_129;
    __Vtask_tb_axi_bridge__DOT__send_ar__first_129 = 0;
    IData/*31:0*/ __Vtask_tb_axi_bridge__DOT__send_ar__count_130;
    __Vtask_tb_axi_bridge__DOT__send_ar__count_130 = 0;
    IData/*31:0*/ __Vtask_tb_axi_bridge__DOT__send_ar__k_131;
    __Vtask_tb_axi_bridge__DOT__send_ar__k_131 = 0;
    // Body
    __Vtask_tb_axi_bridge__DOT__send_ar__count_130 = 6U;
    __Vtask_tb_axi_bridge__DOT__send_ar__first_129 = 0U;
    __Vtask_tb_axi_bridge__DOT__send_ar__k_131 = 0;
    __Vtask_tb_axi_bridge__DOT__send_ar__k_131 = __Vtask_tb_axi_bridge__DOT__send_ar__first_129;
    while (VL_LTS_III(32, __Vtask_tb_axi_bridge__DOT__send_ar__k_131, 
                      (__Vtask_tb_axi_bridge__DOT__send_ar__first_129 
                       + __Vtask_tb_axi_bridge__DOT__send_ar__count_130))) {
        Vtb_axi_bridge___024root____VbeforeTrig_h8c92a91c__0(vlSelf, 
                                                             "@(negedge tb_axi_bridge.i_clk_sub)");
        co_await vlSelfRef.__VtrigSched_h8c92a91c__0.trigger(0U, 
                                                             nullptr, 
                                                             "@(negedge tb_axi_bridge.i_clk_sub)", 
                                                             "..\\..\\verification\\tb\\tb_axi_bridge.sv", 
                                                             378);
        vlSelfRef.tb_axi_bridge__DOT__i_axi_arvalid = 1U;
        vlSelfRef.tb_axi_bridge__DOT__i_axi_arid = 
            (0x0000000fU & (__Vtask_tb_axi_bridge__DOT__send_ar__k_131 
                            + vlSelfRef.tb_axi_bridge__DOT__seed_value));
        vlSelfRef.tb_axi_bridge__DOT__i_axi_araddr 
            = ((IData)(0x00002000U) + ((__Vtask_tb_axi_bridge__DOT__send_ar__k_131 
                                        << 4U) + (0x000000f0U 
                                                  & vlSelfRef.tb_axi_bridge__DOT__seed_value)));
        vlSelfRef.tb_axi_bridge__DOT__i_axi_arlen = 2U;
        vlSelfRef.tb_axi_bridge__DOT__i_axi_arsize = 2U;
        vlSelfRef.tb_axi_bridge__DOT__i_axi_arburst = 1U;
        vlSelfRef.tb_axi_bridge__DOT__i_axi_arlock 
            = (1U & VL_MODDIVS_III(32, __Vtask_tb_axi_bridge__DOT__send_ar__k_131, (IData)(2U)));
        vlSelfRef.tb_axi_bridge__DOT__i_axi_arcache = 3U;
        vlSelfRef.tb_axi_bridge__DOT__i_axi_arprot = 1U;
        vlSelfRef.tb_axi_bridge__DOT__i_axi_arqos = 
            (0x0000000fU & __Vtask_tb_axi_bridge__DOT__send_ar__k_131);
        vlSelfRef.tb_axi_bridge__DOT__i_axi_arregion 
            = (0x0000000fU & ((IData)(3U) + __Vtask_tb_axi_bridge__DOT__send_ar__k_131));
        do {
            Vtb_axi_bridge___024root____VbeforeTrig_h8c92a665__0(vlSelf, 
                                                                 "@(posedge tb_axi_bridge.i_clk_sub)");
            co_await vlSelfRef.__VtrigSched_h8c92a665__0.trigger(0U, 
                                                                 nullptr, 
                                                                 "@(posedge tb_axi_bridge.i_clk_sub)", 
                                                                 "..\\..\\verification\\tb\\tb_axi_bridge.sv", 
                                                                 395);
        } while ((1U & (~ (IData)(vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_ar__DOT__o_axi_arready))));
        __Vtask_tb_axi_bridge__DOT__send_ar__k_131 
            = ((IData)(1U) + __Vtask_tb_axi_bridge__DOT__send_ar__k_131);
    }
    Vtb_axi_bridge___024root____VbeforeTrig_h8c92a91c__0(vlSelf, 
                                                         "@(negedge tb_axi_bridge.i_clk_sub)");
    co_await vlSelfRef.__VtrigSched_h8c92a91c__0.trigger(0U, 
                                                         nullptr, 
                                                         "@(negedge tb_axi_bridge.i_clk_sub)", 
                                                         "..\\..\\verification\\tb\\tb_axi_bridge.sv", 
                                                         397);
    vlSelfRef.tb_axi_bridge__DOT__i_axi_arvalid = 0U;
    __Vfork_2__sync.done("..\\..\\verification\\tb\\tb_axi_bridge.sv", 
                         478);
    co_return;
}

VlCoroutine Vtb_axi_bridge___024root___eval_initial__TOP__Vtiming__1____Vfork_2__1(Vtb_axi_bridge___024root* vlSelf, VlForkSync __Vfork_2__sync) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_axi_bridge___024root___eval_initial__TOP__Vtiming__1____Vfork_2__1\n"); );
    Vtb_axi_bridge__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Locals
    IData/*31:0*/ __Vtask_tb_axi_bridge__DOT__send_w__first_126;
    __Vtask_tb_axi_bridge__DOT__send_w__first_126 = 0;
    IData/*31:0*/ __Vtask_tb_axi_bridge__DOT__send_w__count_127;
    __Vtask_tb_axi_bridge__DOT__send_w__count_127 = 0;
    IData/*31:0*/ __Vtask_tb_axi_bridge__DOT__send_w__k_128;
    __Vtask_tb_axi_bridge__DOT__send_w__k_128 = 0;
    // Body
    __Vtask_tb_axi_bridge__DOT__send_w__count_127 = 0x00000011U;
    __Vtask_tb_axi_bridge__DOT__send_w__first_126 = 1U;
    __Vtask_tb_axi_bridge__DOT__send_w__k_128 = 0;
    __Vtask_tb_axi_bridge__DOT__send_w__k_128 = __Vtask_tb_axi_bridge__DOT__send_w__first_126;
    while (VL_LTS_III(32, __Vtask_tb_axi_bridge__DOT__send_w__k_128, 
                      (__Vtask_tb_axi_bridge__DOT__send_w__first_126 
                       + __Vtask_tb_axi_bridge__DOT__send_w__count_127))) {
        Vtb_axi_bridge___024root____VbeforeTrig_h8c92a91c__0(vlSelf, 
                                                             "@(negedge tb_axi_bridge.i_clk_sub)");
        co_await vlSelfRef.__VtrigSched_h8c92a91c__0.trigger(0U, 
                                                             nullptr, 
                                                             "@(negedge tb_axi_bridge.i_clk_sub)", 
                                                             "..\\..\\verification\\tb\\tb_axi_bridge.sv", 
                                                             346);
        vlSelfRef.tb_axi_bridge__DOT__i_axi_wvalid = 1U;
        vlSelfRef.tb_axi_bridge__DOT__i_axi_wdata = 
            ((IData)(0x01000000U) + (__Vtask_tb_axi_bridge__DOT__send_w__k_128 
                                     + vlSelfRef.tb_axi_bridge__DOT__seed_value));
        vlSelfRef.tb_axi_bridge__DOT__i_axi_wstrb = 0x0fU;
        vlSelfRef.tb_axi_bridge__DOT__i_axi_wlast = 
            (2U == VL_MODDIVS_III(32, __Vtask_tb_axi_bridge__DOT__send_w__k_128, (IData)(3U)));
        do {
            Vtb_axi_bridge___024root____VbeforeTrig_h8c92a665__0(vlSelf, 
                                                                 "@(posedge tb_axi_bridge.i_clk_sub)");
            co_await vlSelfRef.__VtrigSched_h8c92a665__0.trigger(0U, 
                                                                 nullptr, 
                                                                 "@(posedge tb_axi_bridge.i_clk_sub)", 
                                                                 "..\\..\\verification\\tb\\tb_axi_bridge.sv", 
                                                                 353);
        } while ((1U & (~ (IData)(vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_w__DOT__o_axi_wready))));
        __Vtask_tb_axi_bridge__DOT__send_w__k_128 = 
            ((IData)(1U) + __Vtask_tb_axi_bridge__DOT__send_w__k_128);
    }
    Vtb_axi_bridge___024root____VbeforeTrig_h8c92a91c__0(vlSelf, 
                                                         "@(negedge tb_axi_bridge.i_clk_sub)");
    co_await vlSelfRef.__VtrigSched_h8c92a91c__0.trigger(0U, 
                                                         nullptr, 
                                                         "@(negedge tb_axi_bridge.i_clk_sub)", 
                                                         "..\\..\\verification\\tb\\tb_axi_bridge.sv", 
                                                         355);
    vlSelfRef.tb_axi_bridge__DOT__i_axi_wvalid = 0U;
    __Vfork_2__sync.done("..\\..\\verification\\tb\\tb_axi_bridge.sv", 
                         477);
    co_return;
}

VlCoroutine Vtb_axi_bridge___024root___eval_initial__TOP__Vtiming__1____Vfork_2__0(Vtb_axi_bridge___024root* vlSelf, VlForkSync __Vfork_2__sync) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_axi_bridge___024root___eval_initial__TOP__Vtiming__1____Vfork_2__0\n"); );
    Vtb_axi_bridge__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Locals
    IData/*31:0*/ __Vtask_tb_axi_bridge__DOT__send_aw__first_123;
    __Vtask_tb_axi_bridge__DOT__send_aw__first_123 = 0;
    IData/*31:0*/ __Vtask_tb_axi_bridge__DOT__send_aw__count_124;
    __Vtask_tb_axi_bridge__DOT__send_aw__count_124 = 0;
    IData/*31:0*/ __Vtask_tb_axi_bridge__DOT__send_aw__k_125;
    __Vtask_tb_axi_bridge__DOT__send_aw__k_125 = 0;
    // Body
    __Vtask_tb_axi_bridge__DOT__send_aw__count_124 = 6U;
    __Vtask_tb_axi_bridge__DOT__send_aw__first_123 = 0U;
    __Vtask_tb_axi_bridge__DOT__send_aw__k_125 = 0;
    __Vtask_tb_axi_bridge__DOT__send_aw__k_125 = __Vtask_tb_axi_bridge__DOT__send_aw__first_123;
    while (VL_LTS_III(32, __Vtask_tb_axi_bridge__DOT__send_aw__k_125, 
                      (__Vtask_tb_axi_bridge__DOT__send_aw__first_123 
                       + __Vtask_tb_axi_bridge__DOT__send_aw__count_124))) {
        Vtb_axi_bridge___024root____VbeforeTrig_h8c92a91c__0(vlSelf, 
                                                             "@(negedge tb_axi_bridge.i_clk_sub)");
        co_await vlSelfRef.__VtrigSched_h8c92a91c__0.trigger(0U, 
                                                             nullptr, 
                                                             "@(negedge tb_axi_bridge.i_clk_sub)", 
                                                             "..\\..\\verification\\tb\\tb_axi_bridge.sv", 
                                                             319);
        vlSelfRef.tb_axi_bridge__DOT__i_axi_awvalid = 1U;
        vlSelfRef.tb_axi_bridge__DOT__i_axi_awid = 
            (0x0000000fU & (__Vtask_tb_axi_bridge__DOT__send_aw__k_125 
                            + vlSelfRef.tb_axi_bridge__DOT__seed_value));
        vlSelfRef.tb_axi_bridge__DOT__i_axi_awaddr 
            = ((IData)(0x00001000U) + ((__Vtask_tb_axi_bridge__DOT__send_aw__k_125 
                                        << 4U) + (0x000000f0U 
                                                  & vlSelfRef.tb_axi_bridge__DOT__seed_value)));
        vlSelfRef.tb_axi_bridge__DOT__i_axi_awlen = 2U;
        vlSelfRef.tb_axi_bridge__DOT__i_axi_awsize = 2U;
        vlSelfRef.tb_axi_bridge__DOT__i_axi_awburst = 1U;
        vlSelfRef.tb_axi_bridge__DOT__i_axi_awlock 
            = (1U & VL_MODDIVS_III(32, __Vtask_tb_axi_bridge__DOT__send_aw__k_125, (IData)(2U)));
        vlSelfRef.tb_axi_bridge__DOT__i_axi_awcache = 3U;
        vlSelfRef.tb_axi_bridge__DOT__i_axi_awprot = 1U;
        vlSelfRef.tb_axi_bridge__DOT__i_axi_awqos = 
            (0x0000000fU & __Vtask_tb_axi_bridge__DOT__send_aw__k_125);
        vlSelfRef.tb_axi_bridge__DOT__i_axi_awregion 
            = (0x0000000fU & ((IData)(2U) + __Vtask_tb_axi_bridge__DOT__send_aw__k_125));
        do {
            Vtb_axi_bridge___024root____VbeforeTrig_h8c92a665__0(vlSelf, 
                                                                 "@(posedge tb_axi_bridge.i_clk_sub)");
            co_await vlSelfRef.__VtrigSched_h8c92a665__0.trigger(0U, 
                                                                 nullptr, 
                                                                 "@(posedge tb_axi_bridge.i_clk_sub)", 
                                                                 "..\\..\\verification\\tb\\tb_axi_bridge.sv", 
                                                                 336);
        } while ((1U & (~ (IData)(vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_aw__DOT__o_axi_awready))));
        __Vtask_tb_axi_bridge__DOT__send_aw__k_125 
            = ((IData)(1U) + __Vtask_tb_axi_bridge__DOT__send_aw__k_125);
    }
    Vtb_axi_bridge___024root____VbeforeTrig_h8c92a91c__0(vlSelf, 
                                                         "@(negedge tb_axi_bridge.i_clk_sub)");
    co_await vlSelfRef.__VtrigSched_h8c92a91c__0.trigger(0U, 
                                                         nullptr, 
                                                         "@(negedge tb_axi_bridge.i_clk_sub)", 
                                                         "..\\..\\verification\\tb\\tb_axi_bridge.sv", 
                                                         338);
    vlSelfRef.tb_axi_bridge__DOT__i_axi_awvalid = 0U;
    __Vfork_2__sync.done("..\\..\\verification\\tb\\tb_axi_bridge.sv", 
                         476);
    co_return;
}

VlCoroutine Vtb_axi_bridge___024root___eval_initial__TOP__Vtiming__1____Vfork_1__0(Vtb_axi_bridge___024root* vlSelf, VlForkSync __Vfork_1__sync) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_axi_bridge___024root___eval_initial__TOP__Vtiming__1____Vfork_1__0\n"); );
    Vtb_axi_bridge__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Locals
    IData/*31:0*/ __Vtask_tb_axi_bridge__DOT__send_w__first_120;
    __Vtask_tb_axi_bridge__DOT__send_w__first_120 = 0;
    IData/*31:0*/ __Vtask_tb_axi_bridge__DOT__send_w__count_121;
    __Vtask_tb_axi_bridge__DOT__send_w__count_121 = 0;
    IData/*31:0*/ __Vtask_tb_axi_bridge__DOT__send_w__k_122;
    __Vtask_tb_axi_bridge__DOT__send_w__k_122 = 0;
    // Body
    __Vtask_tb_axi_bridge__DOT__send_w__count_121 = 1U;
    __Vtask_tb_axi_bridge__DOT__send_w__first_120 = 0U;
    __Vtask_tb_axi_bridge__DOT__send_w__k_122 = 0;
    __Vtask_tb_axi_bridge__DOT__send_w__k_122 = __Vtask_tb_axi_bridge__DOT__send_w__first_120;
    while (VL_LTS_III(32, __Vtask_tb_axi_bridge__DOT__send_w__k_122, 
                      (__Vtask_tb_axi_bridge__DOT__send_w__first_120 
                       + __Vtask_tb_axi_bridge__DOT__send_w__count_121))) {
        Vtb_axi_bridge___024root____VbeforeTrig_h8c92a91c__0(vlSelf, 
                                                             "@(negedge tb_axi_bridge.i_clk_sub)");
        co_await vlSelfRef.__VtrigSched_h8c92a91c__0.trigger(0U, 
                                                             nullptr, 
                                                             "@(negedge tb_axi_bridge.i_clk_sub)", 
                                                             "..\\..\\verification\\tb\\tb_axi_bridge.sv", 
                                                             346);
        vlSelfRef.tb_axi_bridge__DOT__i_axi_wvalid = 1U;
        vlSelfRef.tb_axi_bridge__DOT__i_axi_wdata = 
            ((IData)(0x01000000U) + (__Vtask_tb_axi_bridge__DOT__send_w__k_122 
                                     + vlSelfRef.tb_axi_bridge__DOT__seed_value));
        vlSelfRef.tb_axi_bridge__DOT__i_axi_wstrb = 0x0fU;
        vlSelfRef.tb_axi_bridge__DOT__i_axi_wlast = 
            (2U == VL_MODDIVS_III(32, __Vtask_tb_axi_bridge__DOT__send_w__k_122, (IData)(3U)));
        do {
            Vtb_axi_bridge___024root____VbeforeTrig_h8c92a665__0(vlSelf, 
                                                                 "@(posedge tb_axi_bridge.i_clk_sub)");
            co_await vlSelfRef.__VtrigSched_h8c92a665__0.trigger(0U, 
                                                                 nullptr, 
                                                                 "@(posedge tb_axi_bridge.i_clk_sub)", 
                                                                 "..\\..\\verification\\tb\\tb_axi_bridge.sv", 
                                                                 353);
        } while ((1U & (~ (IData)(vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_w__DOT__o_axi_wready))));
        __Vtask_tb_axi_bridge__DOT__send_w__k_122 = 
            ((IData)(1U) + __Vtask_tb_axi_bridge__DOT__send_w__k_122);
    }
    Vtb_axi_bridge___024root____VbeforeTrig_h8c92a91c__0(vlSelf, 
                                                         "@(negedge tb_axi_bridge.i_clk_sub)");
    co_await vlSelfRef.__VtrigSched_h8c92a91c__0.trigger(0U, 
                                                         nullptr, 
                                                         "@(negedge tb_axi_bridge.i_clk_sub)", 
                                                         "..\\..\\verification\\tb\\tb_axi_bridge.sv", 
                                                         355);
    vlSelfRef.tb_axi_bridge__DOT__i_axi_wvalid = 0U;
    __Vfork_1__sync.done("..\\..\\verification\\tb\\tb_axi_bridge.sv", 
                         473);
    co_return;
}

VlCoroutine Vtb_axi_bridge___024root___eval_initial__TOP__Vtiming__2(Vtb_axi_bridge___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_axi_bridge___024root___eval_initial__TOP__Vtiming__2\n"); );
    Vtb_axi_bridge__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Body
    co_await vlSelfRef.__VdlySched.delay(0x000000000bebc200ULL, 
                                         nullptr, "..\\..\\verification\\tb\\tb_axi_bridge.sv", 
                                         515);
    VL_WRITEF_NX("[%0t] %%Fatal: tb_axi_bridge.sv:516: Assertion failed in %m: simulation timeout\n",3, 'M',vlSymsp->name(),"tb_axi_bridge", 'T',-9
                 , '#',64,VL_TIME_UNITED_Q(1000));
    VL_STOP_MT("..\\..\\verification\\tb\\tb_axi_bridge.sv", 516, "", false);
    co_return;
}

VlCoroutine Vtb_axi_bridge___024root___eval_initial__TOP__Vtiming__3(Vtb_axi_bridge___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_axi_bridge___024root___eval_initial__TOP__Vtiming__3\n"); );
    Vtb_axi_bridge__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Body
    while (VL_LIKELY(!vlSymsp->_vm_contextp__->gotFinish())) {
        co_await vlSelfRef.__VdlySched.delay(0x0000000000001388ULL, 
                                             nullptr, 
                                             "..\\..\\verification\\tb\\tb_axi_bridge.sv", 
                                             418);
        vlSelfRef.tb_axi_bridge__DOT__i_clk_sub = (1U 
                                                   & (~ (IData)(vlSelfRef.tb_axi_bridge__DOT__i_clk_sub)));
    }
    co_return;
}

bool Vtb_axi_bridge___024root___trigger_anySet__ico(const VlUnpacked<QData/*63:0*/, 1> &in) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_axi_bridge___024root___trigger_anySet__ico\n"); );
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

bool Vtb_axi_bridge___024root___trigger_anySet__act(const VlUnpacked<QData/*63:0*/, 1> &in) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_axi_bridge___024root___trigger_anySet__act\n"); );
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

extern const VlUnpacked<CData/*2:0*/, 1024> Vtb_axi_bridge__ConstPool__TABLE_3;
extern const VlUnpacked<CData/*2:0*/, 256> Vtb_axi_bridge__ConstPool__TABLE_6;
extern const VlUnpacked<CData/*1:0*/, 256> Vtb_axi_bridge__ConstPool__TABLE_1;
extern const VlUnpacked<CData/*1:0*/, 64> Vtb_axi_bridge__ConstPool__TABLE_5;

void Vtb_axi_bridge___024root___nba_sequent__TOP__0(Vtb_axi_bridge___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_axi_bridge___024root___nba_sequent__TOP__0\n"); );
    Vtb_axi_bridge__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Body
    vlSelfRef.__Vdly__tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_r__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__reg_fsm_srst_current_state_54 
        = vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_r__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__reg_fsm_srst_current_state;
    vlSelfRef.__Vdly__tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_b__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__reg_fsm_srst_current_state_91 
        = vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_b__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__reg_fsm_srst_current_state;
    vlSelfRef.__Vdly__tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_w__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_rd__DOT__reg_fsm_srst_current_state_65 
        = vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_w__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_rd__DOT__reg_fsm_srst_current_state;
    vlSelfRef.__Vdly__tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_ar__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_rd__DOT__reg_fsm_srst_current_state_75 
        = vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_ar__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_rd__DOT__reg_fsm_srst_current_state;
    vlSelfRef.__Vdly__tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_aw__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_rd__DOT__reg_fsm_srst_current_state_83 
        = vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_aw__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_rd__DOT__reg_fsm_srst_current_state;
    vlSelfRef.__Vdly__tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_r__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__u_sync_ack__DOT__gen_bit_cell__BRA__0__KET____DOT__u_vlsit_afifo_cell_sync__DOT__gen_sync2__DOT__gen_rn__DOT__u_dont_touch_sync2ff__DOT__reg_chain_62 
        = vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_r__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__u_sync_ack__DOT__gen_bit_cell__BRA__0__KET____DOT__u_vlsit_afifo_cell_sync__DOT__gen_sync2__DOT__gen_rn__DOT__u_dont_touch_sync2ff__DOT__reg_chain;
    vlSelfRef.__Vdly__tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_b__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__u_sync_ack__DOT__gen_bit_cell__BRA__0__KET____DOT__u_vlsit_afifo_cell_sync__DOT__gen_sync2__DOT__gen_rn__DOT__u_dont_touch_sync2ff__DOT__reg_chain_97 
        = vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_b__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__u_sync_ack__DOT__gen_bit_cell__BRA__0__KET____DOT__u_vlsit_afifo_cell_sync__DOT__gen_sync2__DOT__gen_rn__DOT__u_dont_touch_sync2ff__DOT__reg_chain;
    vlSelfRef.__Vdly__tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_w__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_rd__DOT__u_sync_req__DOT__gen_bit_cell__BRA__0__KET____DOT__u_vlsit_afifo_cell_sync__DOT__gen_sync2__DOT__gen_rn__DOT__u_dont_touch_sync2ff__DOT__reg_chain_72 
        = vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_w__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_rd__DOT__u_sync_req__DOT__gen_bit_cell__BRA__0__KET____DOT__u_vlsit_afifo_cell_sync__DOT__gen_sync2__DOT__gen_rn__DOT__u_dont_touch_sync2ff__DOT__reg_chain;
    vlSelfRef.__Vdly__tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_ar__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_rd__DOT__u_sync_req__DOT__gen_bit_cell__BRA__0__KET____DOT__u_vlsit_afifo_cell_sync__DOT__gen_sync2__DOT__gen_rn__DOT__u_dont_touch_sync2ff__DOT__reg_chain_80 
        = vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_ar__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_rd__DOT__u_sync_req__DOT__gen_bit_cell__BRA__0__KET____DOT__u_vlsit_afifo_cell_sync__DOT__gen_sync2__DOT__gen_rn__DOT__u_dont_touch_sync2ff__DOT__reg_chain;
    vlSelfRef.__Vdly__tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_aw__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_rd__DOT__u_sync_req__DOT__gen_bit_cell__BRA__0__KET____DOT__u_vlsit_afifo_cell_sync__DOT__gen_sync2__DOT__gen_rn__DOT__u_dont_touch_sync2ff__DOT__reg_chain_88 
        = vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_aw__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_rd__DOT__u_sync_req__DOT__gen_bit_cell__BRA__0__KET____DOT__u_vlsit_afifo_cell_sync__DOT__gen_sync2__DOT__gen_rn__DOT__u_dont_touch_sync2ff__DOT__reg_chain;
    if (vlSelfRef.tb_axi_bridge__DOT__i_rst_n_mgr) {
        vlSelfRef.__Vdly__tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_r__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__reg_fsm_srst_current_state_54 
            = Vtb_axi_bridge__ConstPool__TABLE_3[(0x00000200U 
                                                  | (((IData)(vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_r__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__u_sync_rd_gray__DOT__o_data) 
                                                      << 4U) 
                                                     | ((8U 
                                                         & ((IData)(vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_r__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__u_sync_ack__DOT__gen_bit_cell__BRA__0__KET____DOT__u_vlsit_afifo_cell_sync__DOT__gen_sync2__DOT__gen_rn__DOT__u_dont_touch_sync2ff__DOT__reg_chain) 
                                                            << 2U)) 
                                                        | (IData)(vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_r__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__reg_fsm_srst_current_state))))];
        vlSelfRef.__Vdly__tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_b__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__reg_fsm_srst_current_state_91 
            = Vtb_axi_bridge__ConstPool__TABLE_6[(0x00000080U 
                                                  | (((IData)(vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_b__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__u_sync_rd_gray__DOT__o_data) 
                                                      << 4U) 
                                                     | ((8U 
                                                         & ((IData)(vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_b__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__u_sync_ack__DOT__gen_bit_cell__BRA__0__KET____DOT__u_vlsit_afifo_cell_sync__DOT__gen_sync2__DOT__gen_rn__DOT__u_dont_touch_sync2ff__DOT__reg_chain) 
                                                            << 2U)) 
                                                        | (IData)(vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_b__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__reg_fsm_srst_current_state))))];
        vlSelfRef.__Vdly__tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_w__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_rd__DOT__reg_fsm_srst_current_state_65 
            = Vtb_axi_bridge__ConstPool__TABLE_1[(((IData)(vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_w__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_rd__DOT__u_sync_wr_gray__DOT__o_data) 
                                                   << 3U) 
                                                  | ((4U 
                                                      & ((IData)(vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_w__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_rd__DOT__u_sync_req__DOT__gen_bit_cell__BRA__0__KET____DOT__u_vlsit_afifo_cell_sync__DOT__gen_sync2__DOT__gen_rn__DOT__u_dont_touch_sync2ff__DOT__reg_chain) 
                                                         << 1U)) 
                                                     | (IData)(vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_w__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_rd__DOT__reg_fsm_srst_current_state)))];
        vlSelfRef.__Vdly__tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_ar__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_rd__DOT__reg_fsm_srst_current_state_75 
            = Vtb_axi_bridge__ConstPool__TABLE_5[(((IData)(vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_ar__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_rd__DOT__u_sync_wr_gray__DOT__o_data) 
                                                   << 3U) 
                                                  | ((4U 
                                                      & ((IData)(vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_ar__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_rd__DOT__u_sync_req__DOT__gen_bit_cell__BRA__0__KET____DOT__u_vlsit_afifo_cell_sync__DOT__gen_sync2__DOT__gen_rn__DOT__u_dont_touch_sync2ff__DOT__reg_chain) 
                                                         << 1U)) 
                                                     | (IData)(vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_ar__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_rd__DOT__reg_fsm_srst_current_state)))];
        vlSelfRef.__Vdly__tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_aw__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_rd__DOT__reg_fsm_srst_current_state_83 
            = Vtb_axi_bridge__ConstPool__TABLE_5[(((IData)(vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_aw__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_rd__DOT__u_sync_wr_gray__DOT__o_data) 
                                                   << 3U) 
                                                  | ((4U 
                                                      & ((IData)(vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_aw__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_rd__DOT__u_sync_req__DOT__gen_bit_cell__BRA__0__KET____DOT__u_vlsit_afifo_cell_sync__DOT__gen_sync2__DOT__gen_rn__DOT__u_dont_touch_sync2ff__DOT__reg_chain) 
                                                         << 1U)) 
                                                     | (IData)(vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_aw__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_rd__DOT__reg_fsm_srst_current_state)))];
        vlSelfRef.__Vdly__tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_r__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__u_sync_ack__DOT__gen_bit_cell__BRA__0__KET____DOT__u_vlsit_afifo_cell_sync__DOT__gen_sync2__DOT__gen_rn__DOT__u_dont_touch_sync2ff__DOT__reg_chain_62 
            = ((2U & ((IData)(vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_r__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__u_sync_ack__DOT__gen_bit_cell__BRA__0__KET____DOT__u_vlsit_afifo_cell_sync__DOT__gen_sync2__DOT__gen_rn__DOT__u_dont_touch_sync2ff__DOT__reg_chain) 
                      << 1U)) | (IData)(vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_r__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_rd__DOT__reg_ack_rd));
        vlSelfRef.__Vdly__tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_b__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__u_sync_ack__DOT__gen_bit_cell__BRA__0__KET____DOT__u_vlsit_afifo_cell_sync__DOT__gen_sync2__DOT__gen_rn__DOT__u_dont_touch_sync2ff__DOT__reg_chain_97 
            = ((2U & ((IData)(vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_b__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__u_sync_ack__DOT__gen_bit_cell__BRA__0__KET____DOT__u_vlsit_afifo_cell_sync__DOT__gen_sync2__DOT__gen_rn__DOT__u_dont_touch_sync2ff__DOT__reg_chain) 
                      << 1U)) | (IData)(vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_b__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_rd__DOT__reg_ack_rd));
        vlSelfRef.__Vdly__tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_w__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_rd__DOT__u_sync_req__DOT__gen_bit_cell__BRA__0__KET____DOT__u_vlsit_afifo_cell_sync__DOT__gen_sync2__DOT__gen_rn__DOT__u_dont_touch_sync2ff__DOT__reg_chain_72 
            = ((2U & ((IData)(vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_w__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_rd__DOT__u_sync_req__DOT__gen_bit_cell__BRA__0__KET____DOT__u_vlsit_afifo_cell_sync__DOT__gen_sync2__DOT__gen_rn__DOT__u_dont_touch_sync2ff__DOT__reg_chain) 
                      << 1U)) | (IData)(vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_w__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__reg_req_wr));
        vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_ar__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_rd__DOT__u_sync_wr_gray__DOT__gen_bit_cell__BRA__2__KET____DOT__u_vlsit_afifo_cell_sync__DOT__gen_sync2__DOT__gen_rn__DOT__u_dont_touch_sync2ff__DOT__reg_chain 
            = ((2U & ((IData)(vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_ar__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_rd__DOT__u_sync_wr_gray__DOT__gen_bit_cell__BRA__2__KET____DOT__u_vlsit_afifo_cell_sync__DOT__gen_sync2__DOT__gen_rn__DOT__u_dont_touch_sync2ff__DOT__reg_chain) 
                      << 1U)) | (1U & ((IData)(vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_ar__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__reg_wgray) 
                                       >> 2U)));
        vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_ar__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_rd__DOT__u_sync_wr_gray__DOT__gen_bit_cell__BRA__1__KET____DOT__u_vlsit_afifo_cell_sync__DOT__gen_sync2__DOT__gen_rn__DOT__u_dont_touch_sync2ff__DOT__reg_chain 
            = ((2U & ((IData)(vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_ar__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_rd__DOT__u_sync_wr_gray__DOT__gen_bit_cell__BRA__1__KET____DOT__u_vlsit_afifo_cell_sync__DOT__gen_sync2__DOT__gen_rn__DOT__u_dont_touch_sync2ff__DOT__reg_chain) 
                      << 1U)) | (1U & ((IData)(vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_ar__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__reg_wgray) 
                                       >> 1U)));
        vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_ar__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_rd__DOT__u_sync_wr_gray__DOT__gen_bit_cell__BRA__0__KET____DOT__u_vlsit_afifo_cell_sync__DOT__gen_sync2__DOT__gen_rn__DOT__u_dont_touch_sync2ff__DOT__reg_chain 
            = ((2U & ((IData)(vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_ar__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_rd__DOT__u_sync_wr_gray__DOT__gen_bit_cell__BRA__0__KET____DOT__u_vlsit_afifo_cell_sync__DOT__gen_sync2__DOT__gen_rn__DOT__u_dont_touch_sync2ff__DOT__reg_chain) 
                      << 1U)) | (1U & (IData)(vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_ar__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__reg_wgray)));
        vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_aw__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_rd__DOT__u_sync_wr_gray__DOT__gen_bit_cell__BRA__2__KET____DOT__u_vlsit_afifo_cell_sync__DOT__gen_sync2__DOT__gen_rn__DOT__u_dont_touch_sync2ff__DOT__reg_chain 
            = ((2U & ((IData)(vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_aw__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_rd__DOT__u_sync_wr_gray__DOT__gen_bit_cell__BRA__2__KET____DOT__u_vlsit_afifo_cell_sync__DOT__gen_sync2__DOT__gen_rn__DOT__u_dont_touch_sync2ff__DOT__reg_chain) 
                      << 1U)) | (1U & ((IData)(vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_aw__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__reg_wgray) 
                                       >> 2U)));
        vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_aw__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_rd__DOT__u_sync_wr_gray__DOT__gen_bit_cell__BRA__1__KET____DOT__u_vlsit_afifo_cell_sync__DOT__gen_sync2__DOT__gen_rn__DOT__u_dont_touch_sync2ff__DOT__reg_chain 
            = ((2U & ((IData)(vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_aw__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_rd__DOT__u_sync_wr_gray__DOT__gen_bit_cell__BRA__1__KET____DOT__u_vlsit_afifo_cell_sync__DOT__gen_sync2__DOT__gen_rn__DOT__u_dont_touch_sync2ff__DOT__reg_chain) 
                      << 1U)) | (1U & ((IData)(vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_aw__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__reg_wgray) 
                                       >> 1U)));
        vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_aw__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_rd__DOT__u_sync_wr_gray__DOT__gen_bit_cell__BRA__0__KET____DOT__u_vlsit_afifo_cell_sync__DOT__gen_sync2__DOT__gen_rn__DOT__u_dont_touch_sync2ff__DOT__reg_chain 
            = ((2U & ((IData)(vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_aw__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_rd__DOT__u_sync_wr_gray__DOT__gen_bit_cell__BRA__0__KET____DOT__u_vlsit_afifo_cell_sync__DOT__gen_sync2__DOT__gen_rn__DOT__u_dont_touch_sync2ff__DOT__reg_chain) 
                      << 1U)) | (1U & (IData)(vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_aw__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__reg_wgray)));
        vlSelfRef.__Vdly__tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_ar__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_rd__DOT__u_sync_req__DOT__gen_bit_cell__BRA__0__KET____DOT__u_vlsit_afifo_cell_sync__DOT__gen_sync2__DOT__gen_rn__DOT__u_dont_touch_sync2ff__DOT__reg_chain_80 
            = ((2U & ((IData)(vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_ar__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_rd__DOT__u_sync_req__DOT__gen_bit_cell__BRA__0__KET____DOT__u_vlsit_afifo_cell_sync__DOT__gen_sync2__DOT__gen_rn__DOT__u_dont_touch_sync2ff__DOT__reg_chain) 
                      << 1U)) | (IData)(vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_ar__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__reg_req_wr));
        vlSelfRef.__Vdly__tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_aw__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_rd__DOT__u_sync_req__DOT__gen_bit_cell__BRA__0__KET____DOT__u_vlsit_afifo_cell_sync__DOT__gen_sync2__DOT__gen_rn__DOT__u_dont_touch_sync2ff__DOT__reg_chain_88 
            = ((2U & ((IData)(vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_aw__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_rd__DOT__u_sync_req__DOT__gen_bit_cell__BRA__0__KET____DOT__u_vlsit_afifo_cell_sync__DOT__gen_sync2__DOT__gen_rn__DOT__u_dont_touch_sync2ff__DOT__reg_chain) 
                      << 1U)) | (IData)(vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_aw__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__reg_req_wr));
        vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_b__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__u_sync_rd_gray__DOT__gen_bit_cell__BRA__2__KET____DOT__u_vlsit_afifo_cell_sync__DOT__gen_sync2__DOT__gen_rn__DOT__u_dont_touch_sync2ff__DOT__reg_chain 
            = ((2U & ((IData)(vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_b__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__u_sync_rd_gray__DOT__gen_bit_cell__BRA__2__KET____DOT__u_vlsit_afifo_cell_sync__DOT__gen_sync2__DOT__gen_rn__DOT__u_dont_touch_sync2ff__DOT__reg_chain) 
                      << 1U)) | (1U & ((IData)(vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_b__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_rd__DOT__reg_rgray) 
                                       >> 2U)));
        vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_b__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__u_sync_rd_gray__DOT__gen_bit_cell__BRA__1__KET____DOT__u_vlsit_afifo_cell_sync__DOT__gen_sync2__DOT__gen_rn__DOT__u_dont_touch_sync2ff__DOT__reg_chain 
            = ((2U & ((IData)(vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_b__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__u_sync_rd_gray__DOT__gen_bit_cell__BRA__1__KET____DOT__u_vlsit_afifo_cell_sync__DOT__gen_sync2__DOT__gen_rn__DOT__u_dont_touch_sync2ff__DOT__reg_chain) 
                      << 1U)) | (1U & ((IData)(vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_b__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_rd__DOT__reg_rgray) 
                                       >> 1U)));
        vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_b__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__u_sync_rd_gray__DOT__gen_bit_cell__BRA__0__KET____DOT__u_vlsit_afifo_cell_sync__DOT__gen_sync2__DOT__gen_rn__DOT__u_dont_touch_sync2ff__DOT__reg_chain 
            = ((2U & ((IData)(vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_b__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__u_sync_rd_gray__DOT__gen_bit_cell__BRA__0__KET____DOT__u_vlsit_afifo_cell_sync__DOT__gen_sync2__DOT__gen_rn__DOT__u_dont_touch_sync2ff__DOT__reg_chain) 
                      << 1U)) | (1U & (IData)(vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_b__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_rd__DOT__reg_rgray)));
        vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_w__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_rd__DOT__u_sync_wr_gray__DOT__gen_bit_cell__BRA__4__KET____DOT__u_vlsit_afifo_cell_sync__DOT__gen_sync2__DOT__gen_rn__DOT__u_dont_touch_sync2ff__DOT__reg_chain 
            = ((2U & ((IData)(vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_w__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_rd__DOT__u_sync_wr_gray__DOT__gen_bit_cell__BRA__4__KET____DOT__u_vlsit_afifo_cell_sync__DOT__gen_sync2__DOT__gen_rn__DOT__u_dont_touch_sync2ff__DOT__reg_chain) 
                      << 1U)) | (1U & ((IData)(vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_w__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__reg_wgray) 
                                       >> 4U)));
        vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_w__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_rd__DOT__u_sync_wr_gray__DOT__gen_bit_cell__BRA__3__KET____DOT__u_vlsit_afifo_cell_sync__DOT__gen_sync2__DOT__gen_rn__DOT__u_dont_touch_sync2ff__DOT__reg_chain 
            = ((2U & ((IData)(vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_w__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_rd__DOT__u_sync_wr_gray__DOT__gen_bit_cell__BRA__3__KET____DOT__u_vlsit_afifo_cell_sync__DOT__gen_sync2__DOT__gen_rn__DOT__u_dont_touch_sync2ff__DOT__reg_chain) 
                      << 1U)) | (1U & ((IData)(vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_w__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__reg_wgray) 
                                       >> 3U)));
        vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_w__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_rd__DOT__u_sync_wr_gray__DOT__gen_bit_cell__BRA__2__KET____DOT__u_vlsit_afifo_cell_sync__DOT__gen_sync2__DOT__gen_rn__DOT__u_dont_touch_sync2ff__DOT__reg_chain 
            = ((2U & ((IData)(vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_w__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_rd__DOT__u_sync_wr_gray__DOT__gen_bit_cell__BRA__2__KET____DOT__u_vlsit_afifo_cell_sync__DOT__gen_sync2__DOT__gen_rn__DOT__u_dont_touch_sync2ff__DOT__reg_chain) 
                      << 1U)) | (1U & ((IData)(vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_w__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__reg_wgray) 
                                       >> 2U)));
        vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_w__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_rd__DOT__u_sync_wr_gray__DOT__gen_bit_cell__BRA__1__KET____DOT__u_vlsit_afifo_cell_sync__DOT__gen_sync2__DOT__gen_rn__DOT__u_dont_touch_sync2ff__DOT__reg_chain 
            = ((2U & ((IData)(vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_w__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_rd__DOT__u_sync_wr_gray__DOT__gen_bit_cell__BRA__1__KET____DOT__u_vlsit_afifo_cell_sync__DOT__gen_sync2__DOT__gen_rn__DOT__u_dont_touch_sync2ff__DOT__reg_chain) 
                      << 1U)) | (1U & ((IData)(vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_w__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__reg_wgray) 
                                       >> 1U)));
        vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_w__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_rd__DOT__u_sync_wr_gray__DOT__gen_bit_cell__BRA__0__KET____DOT__u_vlsit_afifo_cell_sync__DOT__gen_sync2__DOT__gen_rn__DOT__u_dont_touch_sync2ff__DOT__reg_chain 
            = ((2U & ((IData)(vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_w__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_rd__DOT__u_sync_wr_gray__DOT__gen_bit_cell__BRA__0__KET____DOT__u_vlsit_afifo_cell_sync__DOT__gen_sync2__DOT__gen_rn__DOT__u_dont_touch_sync2ff__DOT__reg_chain) 
                      << 1U)) | (1U & (IData)(vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_w__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__reg_wgray)));
        vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_r__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__u_sync_rd_gray__DOT__gen_bit_cell__BRA__4__KET____DOT__u_vlsit_afifo_cell_sync__DOT__gen_sync2__DOT__gen_rn__DOT__u_dont_touch_sync2ff__DOT__reg_chain 
            = ((2U & ((IData)(vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_r__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__u_sync_rd_gray__DOT__gen_bit_cell__BRA__4__KET____DOT__u_vlsit_afifo_cell_sync__DOT__gen_sync2__DOT__gen_rn__DOT__u_dont_touch_sync2ff__DOT__reg_chain) 
                      << 1U)) | (1U & ((IData)(vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_r__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_rd__DOT__reg_rgray) 
                                       >> 4U)));
        vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_r__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__u_sync_rd_gray__DOT__gen_bit_cell__BRA__3__KET____DOT__u_vlsit_afifo_cell_sync__DOT__gen_sync2__DOT__gen_rn__DOT__u_dont_touch_sync2ff__DOT__reg_chain 
            = ((2U & ((IData)(vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_r__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__u_sync_rd_gray__DOT__gen_bit_cell__BRA__3__KET____DOT__u_vlsit_afifo_cell_sync__DOT__gen_sync2__DOT__gen_rn__DOT__u_dont_touch_sync2ff__DOT__reg_chain) 
                      << 1U)) | (1U & ((IData)(vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_r__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_rd__DOT__reg_rgray) 
                                       >> 3U)));
        vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_r__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__u_sync_rd_gray__DOT__gen_bit_cell__BRA__2__KET____DOT__u_vlsit_afifo_cell_sync__DOT__gen_sync2__DOT__gen_rn__DOT__u_dont_touch_sync2ff__DOT__reg_chain 
            = ((2U & ((IData)(vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_r__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__u_sync_rd_gray__DOT__gen_bit_cell__BRA__2__KET____DOT__u_vlsit_afifo_cell_sync__DOT__gen_sync2__DOT__gen_rn__DOT__u_dont_touch_sync2ff__DOT__reg_chain) 
                      << 1U)) | (1U & ((IData)(vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_r__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_rd__DOT__reg_rgray) 
                                       >> 2U)));
        vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_r__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__u_sync_rd_gray__DOT__gen_bit_cell__BRA__1__KET____DOT__u_vlsit_afifo_cell_sync__DOT__gen_sync2__DOT__gen_rn__DOT__u_dont_touch_sync2ff__DOT__reg_chain 
            = ((2U & ((IData)(vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_r__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__u_sync_rd_gray__DOT__gen_bit_cell__BRA__1__KET____DOT__u_vlsit_afifo_cell_sync__DOT__gen_sync2__DOT__gen_rn__DOT__u_dont_touch_sync2ff__DOT__reg_chain) 
                      << 1U)) | (1U & ((IData)(vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_r__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_rd__DOT__reg_rgray) 
                                       >> 1U)));
        vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_r__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__u_sync_rd_gray__DOT__gen_bit_cell__BRA__0__KET____DOT__u_vlsit_afifo_cell_sync__DOT__gen_sync2__DOT__gen_rn__DOT__u_dont_touch_sync2ff__DOT__reg_chain 
            = ((2U & ((IData)(vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_r__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__u_sync_rd_gray__DOT__gen_bit_cell__BRA__0__KET____DOT__u_vlsit_afifo_cell_sync__DOT__gen_sync2__DOT__gen_rn__DOT__u_dont_touch_sync2ff__DOT__reg_chain) 
                      << 1U)) | (1U & (IData)(vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_r__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_rd__DOT__reg_rgray)));
        vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_w__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_rd__DOT__reg_rbin 
            = vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_w__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_rd__DOT__w_rbin_nxt;
        vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_ar__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_rd__DOT__reg_rbin 
            = vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_ar__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_rd__DOT__w_rbin_nxt;
        vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_aw__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_rd__DOT__reg_rbin 
            = vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_aw__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_rd__DOT__w_rbin_nxt;
        vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_r__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__reg_sw_rst_busy 
            = (0U != Vtb_axi_bridge__ConstPool__TABLE_3
               [(0x00000200U | (((IData)(vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_r__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__u_sync_rd_gray__DOT__o_data) 
                                 << 4U) | ((8U & ((IData)(vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_r__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__u_sync_ack__DOT__gen_bit_cell__BRA__0__KET____DOT__u_vlsit_afifo_cell_sync__DOT__gen_sync2__DOT__gen_rn__DOT__u_dont_touch_sync2ff__DOT__reg_chain) 
                                                  << 2U)) 
                                           | (IData)(vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_r__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__reg_fsm_srst_current_state))))]);
        vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_b__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__reg_sw_rst_busy 
            = (0U != Vtb_axi_bridge__ConstPool__TABLE_6
               [(0x00000080U | (((IData)(vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_b__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__u_sync_rd_gray__DOT__o_data) 
                                 << 4U) | ((8U & ((IData)(vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_b__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__u_sync_ack__DOT__gen_bit_cell__BRA__0__KET____DOT__u_vlsit_afifo_cell_sync__DOT__gen_sync2__DOT__gen_rn__DOT__u_dont_touch_sync2ff__DOT__reg_chain) 
                                                  << 2U)) 
                                           | (IData)(vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_b__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__reg_fsm_srst_current_state))))]);
    } else {
        vlSelfRef.__Vdly__tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_r__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__reg_fsm_srst_current_state_54 = 0U;
        vlSelfRef.__Vdly__tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_b__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__reg_fsm_srst_current_state_91 = 0U;
        vlSelfRef.__Vdly__tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_w__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_rd__DOT__reg_fsm_srst_current_state_65 = 0U;
        vlSelfRef.__Vdly__tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_ar__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_rd__DOT__reg_fsm_srst_current_state_75 = 0U;
        vlSelfRef.__Vdly__tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_aw__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_rd__DOT__reg_fsm_srst_current_state_83 = 0U;
        vlSelfRef.__Vdly__tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_r__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__u_sync_ack__DOT__gen_bit_cell__BRA__0__KET____DOT__u_vlsit_afifo_cell_sync__DOT__gen_sync2__DOT__gen_rn__DOT__u_dont_touch_sync2ff__DOT__reg_chain_62 = 0U;
        vlSelfRef.__Vdly__tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_b__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__u_sync_ack__DOT__gen_bit_cell__BRA__0__KET____DOT__u_vlsit_afifo_cell_sync__DOT__gen_sync2__DOT__gen_rn__DOT__u_dont_touch_sync2ff__DOT__reg_chain_97 = 0U;
        vlSelfRef.__Vdly__tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_w__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_rd__DOT__u_sync_req__DOT__gen_bit_cell__BRA__0__KET____DOT__u_vlsit_afifo_cell_sync__DOT__gen_sync2__DOT__gen_rn__DOT__u_dont_touch_sync2ff__DOT__reg_chain_72 = 0U;
        vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_ar__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_rd__DOT__u_sync_wr_gray__DOT__gen_bit_cell__BRA__2__KET____DOT__u_vlsit_afifo_cell_sync__DOT__gen_sync2__DOT__gen_rn__DOT__u_dont_touch_sync2ff__DOT__reg_chain = 0U;
        vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_ar__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_rd__DOT__u_sync_wr_gray__DOT__gen_bit_cell__BRA__1__KET____DOT__u_vlsit_afifo_cell_sync__DOT__gen_sync2__DOT__gen_rn__DOT__u_dont_touch_sync2ff__DOT__reg_chain = 0U;
        vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_ar__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_rd__DOT__u_sync_wr_gray__DOT__gen_bit_cell__BRA__0__KET____DOT__u_vlsit_afifo_cell_sync__DOT__gen_sync2__DOT__gen_rn__DOT__u_dont_touch_sync2ff__DOT__reg_chain = 0U;
        vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_aw__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_rd__DOT__u_sync_wr_gray__DOT__gen_bit_cell__BRA__2__KET____DOT__u_vlsit_afifo_cell_sync__DOT__gen_sync2__DOT__gen_rn__DOT__u_dont_touch_sync2ff__DOT__reg_chain = 0U;
        vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_aw__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_rd__DOT__u_sync_wr_gray__DOT__gen_bit_cell__BRA__1__KET____DOT__u_vlsit_afifo_cell_sync__DOT__gen_sync2__DOT__gen_rn__DOT__u_dont_touch_sync2ff__DOT__reg_chain = 0U;
        vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_aw__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_rd__DOT__u_sync_wr_gray__DOT__gen_bit_cell__BRA__0__KET____DOT__u_vlsit_afifo_cell_sync__DOT__gen_sync2__DOT__gen_rn__DOT__u_dont_touch_sync2ff__DOT__reg_chain = 0U;
        vlSelfRef.__Vdly__tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_ar__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_rd__DOT__u_sync_req__DOT__gen_bit_cell__BRA__0__KET____DOT__u_vlsit_afifo_cell_sync__DOT__gen_sync2__DOT__gen_rn__DOT__u_dont_touch_sync2ff__DOT__reg_chain_80 = 0U;
        vlSelfRef.__Vdly__tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_aw__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_rd__DOT__u_sync_req__DOT__gen_bit_cell__BRA__0__KET____DOT__u_vlsit_afifo_cell_sync__DOT__gen_sync2__DOT__gen_rn__DOT__u_dont_touch_sync2ff__DOT__reg_chain_88 = 0U;
        vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_b__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__u_sync_rd_gray__DOT__gen_bit_cell__BRA__2__KET____DOT__u_vlsit_afifo_cell_sync__DOT__gen_sync2__DOT__gen_rn__DOT__u_dont_touch_sync2ff__DOT__reg_chain = 0U;
        vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_b__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__u_sync_rd_gray__DOT__gen_bit_cell__BRA__1__KET____DOT__u_vlsit_afifo_cell_sync__DOT__gen_sync2__DOT__gen_rn__DOT__u_dont_touch_sync2ff__DOT__reg_chain = 0U;
        vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_b__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__u_sync_rd_gray__DOT__gen_bit_cell__BRA__0__KET____DOT__u_vlsit_afifo_cell_sync__DOT__gen_sync2__DOT__gen_rn__DOT__u_dont_touch_sync2ff__DOT__reg_chain = 0U;
        vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_w__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_rd__DOT__u_sync_wr_gray__DOT__gen_bit_cell__BRA__4__KET____DOT__u_vlsit_afifo_cell_sync__DOT__gen_sync2__DOT__gen_rn__DOT__u_dont_touch_sync2ff__DOT__reg_chain = 0U;
        vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_w__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_rd__DOT__u_sync_wr_gray__DOT__gen_bit_cell__BRA__3__KET____DOT__u_vlsit_afifo_cell_sync__DOT__gen_sync2__DOT__gen_rn__DOT__u_dont_touch_sync2ff__DOT__reg_chain = 0U;
        vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_w__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_rd__DOT__u_sync_wr_gray__DOT__gen_bit_cell__BRA__2__KET____DOT__u_vlsit_afifo_cell_sync__DOT__gen_sync2__DOT__gen_rn__DOT__u_dont_touch_sync2ff__DOT__reg_chain = 0U;
        vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_w__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_rd__DOT__u_sync_wr_gray__DOT__gen_bit_cell__BRA__1__KET____DOT__u_vlsit_afifo_cell_sync__DOT__gen_sync2__DOT__gen_rn__DOT__u_dont_touch_sync2ff__DOT__reg_chain = 0U;
        vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_w__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_rd__DOT__u_sync_wr_gray__DOT__gen_bit_cell__BRA__0__KET____DOT__u_vlsit_afifo_cell_sync__DOT__gen_sync2__DOT__gen_rn__DOT__u_dont_touch_sync2ff__DOT__reg_chain = 0U;
        vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_r__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__u_sync_rd_gray__DOT__gen_bit_cell__BRA__4__KET____DOT__u_vlsit_afifo_cell_sync__DOT__gen_sync2__DOT__gen_rn__DOT__u_dont_touch_sync2ff__DOT__reg_chain = 0U;
        vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_r__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__u_sync_rd_gray__DOT__gen_bit_cell__BRA__3__KET____DOT__u_vlsit_afifo_cell_sync__DOT__gen_sync2__DOT__gen_rn__DOT__u_dont_touch_sync2ff__DOT__reg_chain = 0U;
        vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_r__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__u_sync_rd_gray__DOT__gen_bit_cell__BRA__2__KET____DOT__u_vlsit_afifo_cell_sync__DOT__gen_sync2__DOT__gen_rn__DOT__u_dont_touch_sync2ff__DOT__reg_chain = 0U;
        vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_r__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__u_sync_rd_gray__DOT__gen_bit_cell__BRA__1__KET____DOT__u_vlsit_afifo_cell_sync__DOT__gen_sync2__DOT__gen_rn__DOT__u_dont_touch_sync2ff__DOT__reg_chain = 0U;
        vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_r__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__u_sync_rd_gray__DOT__gen_bit_cell__BRA__0__KET____DOT__u_vlsit_afifo_cell_sync__DOT__gen_sync2__DOT__gen_rn__DOT__u_dont_touch_sync2ff__DOT__reg_chain = 0U;
        vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_w__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_rd__DOT__reg_rbin = 0U;
        vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_ar__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_rd__DOT__reg_rbin = 0U;
        vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_aw__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_rd__DOT__reg_rbin = 0U;
        vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_r__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__reg_sw_rst_busy = 0U;
        vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_b__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__reg_sw_rst_busy = 0U;
    }
}

void Vtb_axi_bridge___024root___nba_sequent__TOP__1(Vtb_axi_bridge___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_axi_bridge___024root___nba_sequent__TOP__1\n"); );
    Vtb_axi_bridge__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Locals
    CData/*1:0*/ __Vdly__tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_r__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_rd__DOT__reg_fsm_srst_current_state_7;
    __Vdly__tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_r__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_rd__DOT__reg_fsm_srst_current_state_7 = 0;
    CData/*1:0*/ __Vdly__tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_r__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_rd__DOT__u_sync_req__DOT__gen_bit_cell__BRA__0__KET____DOT__u_vlsit_afifo_cell_sync__DOT__gen_sync2__DOT__gen_rn__DOT__u_dont_touch_sync2ff__DOT__reg_chain_14;
    __Vdly__tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_r__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_rd__DOT__u_sync_req__DOT__gen_bit_cell__BRA__0__KET____DOT__u_vlsit_afifo_cell_sync__DOT__gen_sync2__DOT__gen_rn__DOT__u_dont_touch_sync2ff__DOT__reg_chain_14 = 0;
    CData/*2:0*/ __Vdly__tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_w__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__reg_fsm_srst_current_state_17;
    __Vdly__tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_w__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__reg_fsm_srst_current_state_17 = 0;
    CData/*1:0*/ __Vdly__tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_w__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__u_sync_ack__DOT__gen_bit_cell__BRA__0__KET____DOT__u_vlsit_afifo_cell_sync__DOT__gen_sync2__DOT__gen_rn__DOT__u_dont_touch_sync2ff__DOT__reg_chain_25;
    __Vdly__tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_w__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__u_sync_ack__DOT__gen_bit_cell__BRA__0__KET____DOT__u_vlsit_afifo_cell_sync__DOT__gen_sync2__DOT__gen_rn__DOT__u_dont_touch_sync2ff__DOT__reg_chain_25 = 0;
    CData/*2:0*/ __Vdly__tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_ar__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__reg_fsm_srst_current_state_28;
    __Vdly__tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_ar__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__reg_fsm_srst_current_state_28 = 0;
    CData/*1:0*/ __Vdly__tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_ar__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__u_sync_ack__DOT__gen_bit_cell__BRA__0__KET____DOT__u_vlsit_afifo_cell_sync__DOT__gen_sync2__DOT__gen_rn__DOT__u_dont_touch_sync2ff__DOT__reg_chain_34;
    __Vdly__tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_ar__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__u_sync_ack__DOT__gen_bit_cell__BRA__0__KET____DOT__u_vlsit_afifo_cell_sync__DOT__gen_sync2__DOT__gen_rn__DOT__u_dont_touch_sync2ff__DOT__reg_chain_34 = 0;
    CData/*2:0*/ __Vdly__tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_aw__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__reg_fsm_srst_current_state_37;
    __Vdly__tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_aw__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__reg_fsm_srst_current_state_37 = 0;
    CData/*1:0*/ __Vdly__tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_aw__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__u_sync_ack__DOT__gen_bit_cell__BRA__0__KET____DOT__u_vlsit_afifo_cell_sync__DOT__gen_sync2__DOT__gen_rn__DOT__u_dont_touch_sync2ff__DOT__reg_chain_43;
    __Vdly__tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_aw__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__u_sync_ack__DOT__gen_bit_cell__BRA__0__KET____DOT__u_vlsit_afifo_cell_sync__DOT__gen_sync2__DOT__gen_rn__DOT__u_dont_touch_sync2ff__DOT__reg_chain_43 = 0;
    CData/*1:0*/ __Vdly__tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_b__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_rd__DOT__reg_fsm_srst_current_state_46;
    __Vdly__tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_b__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_rd__DOT__reg_fsm_srst_current_state_46 = 0;
    CData/*1:0*/ __Vdly__tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_b__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_rd__DOT__u_sync_req__DOT__gen_bit_cell__BRA__0__KET____DOT__u_vlsit_afifo_cell_sync__DOT__gen_sync2__DOT__gen_rn__DOT__u_dont_touch_sync2ff__DOT__reg_chain_51;
    __Vdly__tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_b__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_rd__DOT__u_sync_req__DOT__gen_bit_cell__BRA__0__KET____DOT__u_vlsit_afifo_cell_sync__DOT__gen_sync2__DOT__gen_rn__DOT__u_dont_touch_sync2ff__DOT__reg_chain_51 = 0;
    // Body
    __Vdly__tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_w__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__reg_fsm_srst_current_state_17 
        = vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_w__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__reg_fsm_srst_current_state;
    __Vdly__tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_ar__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__reg_fsm_srst_current_state_28 
        = vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_ar__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__reg_fsm_srst_current_state;
    __Vdly__tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_aw__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__reg_fsm_srst_current_state_37 
        = vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_aw__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__reg_fsm_srst_current_state;
    __Vdly__tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_r__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_rd__DOT__reg_fsm_srst_current_state_7 
        = vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_r__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_rd__DOT__reg_fsm_srst_current_state;
    __Vdly__tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_b__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_rd__DOT__reg_fsm_srst_current_state_46 
        = vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_b__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_rd__DOT__reg_fsm_srst_current_state;
    __Vdly__tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_w__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__u_sync_ack__DOT__gen_bit_cell__BRA__0__KET____DOT__u_vlsit_afifo_cell_sync__DOT__gen_sync2__DOT__gen_rn__DOT__u_dont_touch_sync2ff__DOT__reg_chain_25 
        = vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_w__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__u_sync_ack__DOT__gen_bit_cell__BRA__0__KET____DOT__u_vlsit_afifo_cell_sync__DOT__gen_sync2__DOT__gen_rn__DOT__u_dont_touch_sync2ff__DOT__reg_chain;
    __Vdly__tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_ar__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__u_sync_ack__DOT__gen_bit_cell__BRA__0__KET____DOT__u_vlsit_afifo_cell_sync__DOT__gen_sync2__DOT__gen_rn__DOT__u_dont_touch_sync2ff__DOT__reg_chain_34 
        = vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_ar__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__u_sync_ack__DOT__gen_bit_cell__BRA__0__KET____DOT__u_vlsit_afifo_cell_sync__DOT__gen_sync2__DOT__gen_rn__DOT__u_dont_touch_sync2ff__DOT__reg_chain;
    __Vdly__tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_aw__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__u_sync_ack__DOT__gen_bit_cell__BRA__0__KET____DOT__u_vlsit_afifo_cell_sync__DOT__gen_sync2__DOT__gen_rn__DOT__u_dont_touch_sync2ff__DOT__reg_chain_43 
        = vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_aw__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__u_sync_ack__DOT__gen_bit_cell__BRA__0__KET____DOT__u_vlsit_afifo_cell_sync__DOT__gen_sync2__DOT__gen_rn__DOT__u_dont_touch_sync2ff__DOT__reg_chain;
    __Vdly__tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_r__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_rd__DOT__u_sync_req__DOT__gen_bit_cell__BRA__0__KET____DOT__u_vlsit_afifo_cell_sync__DOT__gen_sync2__DOT__gen_rn__DOT__u_dont_touch_sync2ff__DOT__reg_chain_14 
        = vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_r__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_rd__DOT__u_sync_req__DOT__gen_bit_cell__BRA__0__KET____DOT__u_vlsit_afifo_cell_sync__DOT__gen_sync2__DOT__gen_rn__DOT__u_dont_touch_sync2ff__DOT__reg_chain;
    __Vdly__tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_b__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_rd__DOT__u_sync_req__DOT__gen_bit_cell__BRA__0__KET____DOT__u_vlsit_afifo_cell_sync__DOT__gen_sync2__DOT__gen_rn__DOT__u_dont_touch_sync2ff__DOT__reg_chain_51 
        = vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_b__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_rd__DOT__u_sync_req__DOT__gen_bit_cell__BRA__0__KET____DOT__u_vlsit_afifo_cell_sync__DOT__gen_sync2__DOT__gen_rn__DOT__u_dont_touch_sync2ff__DOT__reg_chain;
    if (vlSelfRef.tb_axi_bridge__DOT__i_rst_n_sub) {
        __Vdly__tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_w__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__reg_fsm_srst_current_state_17 
            = Vtb_axi_bridge__ConstPool__TABLE_3[(0x00000200U 
                                                  | (((IData)(vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_w__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__u_sync_rd_gray__DOT__o_data) 
                                                      << 4U) 
                                                     | ((8U 
                                                         & ((IData)(vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_w__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__u_sync_ack__DOT__gen_bit_cell__BRA__0__KET____DOT__u_vlsit_afifo_cell_sync__DOT__gen_sync2__DOT__gen_rn__DOT__u_dont_touch_sync2ff__DOT__reg_chain) 
                                                            << 2U)) 
                                                        | (IData)(vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_w__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__reg_fsm_srst_current_state))))];
        __Vdly__tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_ar__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__reg_fsm_srst_current_state_28 
            = Vtb_axi_bridge__ConstPool__TABLE_6[(0x00000080U 
                                                  | (((IData)(vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_ar__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__u_sync_rd_gray__DOT__o_data) 
                                                      << 4U) 
                                                     | ((8U 
                                                         & ((IData)(vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_ar__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__u_sync_ack__DOT__gen_bit_cell__BRA__0__KET____DOT__u_vlsit_afifo_cell_sync__DOT__gen_sync2__DOT__gen_rn__DOT__u_dont_touch_sync2ff__DOT__reg_chain) 
                                                            << 2U)) 
                                                        | (IData)(vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_ar__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__reg_fsm_srst_current_state))))];
        __Vdly__tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_aw__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__reg_fsm_srst_current_state_37 
            = Vtb_axi_bridge__ConstPool__TABLE_6[(0x00000080U 
                                                  | (((IData)(vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_aw__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__u_sync_rd_gray__DOT__o_data) 
                                                      << 4U) 
                                                     | ((8U 
                                                         & ((IData)(vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_aw__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__u_sync_ack__DOT__gen_bit_cell__BRA__0__KET____DOT__u_vlsit_afifo_cell_sync__DOT__gen_sync2__DOT__gen_rn__DOT__u_dont_touch_sync2ff__DOT__reg_chain) 
                                                            << 2U)) 
                                                        | (IData)(vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_aw__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__reg_fsm_srst_current_state))))];
        __Vdly__tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_r__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_rd__DOT__reg_fsm_srst_current_state_7 
            = Vtb_axi_bridge__ConstPool__TABLE_1[(((IData)(vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_r__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_rd__DOT__u_sync_wr_gray__DOT__o_data) 
                                                   << 3U) 
                                                  | ((4U 
                                                      & ((IData)(vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_r__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_rd__DOT__u_sync_req__DOT__gen_bit_cell__BRA__0__KET____DOT__u_vlsit_afifo_cell_sync__DOT__gen_sync2__DOT__gen_rn__DOT__u_dont_touch_sync2ff__DOT__reg_chain) 
                                                         << 1U)) 
                                                     | (IData)(vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_r__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_rd__DOT__reg_fsm_srst_current_state)))];
        __Vdly__tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_b__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_rd__DOT__reg_fsm_srst_current_state_46 
            = Vtb_axi_bridge__ConstPool__TABLE_5[(((IData)(vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_b__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_rd__DOT__u_sync_wr_gray__DOT__o_data) 
                                                   << 3U) 
                                                  | ((4U 
                                                      & ((IData)(vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_b__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_rd__DOT__u_sync_req__DOT__gen_bit_cell__BRA__0__KET____DOT__u_vlsit_afifo_cell_sync__DOT__gen_sync2__DOT__gen_rn__DOT__u_dont_touch_sync2ff__DOT__reg_chain) 
                                                         << 1U)) 
                                                     | (IData)(vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_b__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_rd__DOT__reg_fsm_srst_current_state)))];
        __Vdly__tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_w__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__u_sync_ack__DOT__gen_bit_cell__BRA__0__KET____DOT__u_vlsit_afifo_cell_sync__DOT__gen_sync2__DOT__gen_rn__DOT__u_dont_touch_sync2ff__DOT__reg_chain_25 
            = ((2U & ((IData)(vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_w__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__u_sync_ack__DOT__gen_bit_cell__BRA__0__KET____DOT__u_vlsit_afifo_cell_sync__DOT__gen_sync2__DOT__gen_rn__DOT__u_dont_touch_sync2ff__DOT__reg_chain) 
                      << 1U)) | (IData)(vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_w__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_rd__DOT__reg_ack_rd));
        __Vdly__tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_ar__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__u_sync_ack__DOT__gen_bit_cell__BRA__0__KET____DOT__u_vlsit_afifo_cell_sync__DOT__gen_sync2__DOT__gen_rn__DOT__u_dont_touch_sync2ff__DOT__reg_chain_34 
            = ((2U & ((IData)(vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_ar__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__u_sync_ack__DOT__gen_bit_cell__BRA__0__KET____DOT__u_vlsit_afifo_cell_sync__DOT__gen_sync2__DOT__gen_rn__DOT__u_dont_touch_sync2ff__DOT__reg_chain) 
                      << 1U)) | (IData)(vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_ar__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_rd__DOT__reg_ack_rd));
        __Vdly__tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_aw__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__u_sync_ack__DOT__gen_bit_cell__BRA__0__KET____DOT__u_vlsit_afifo_cell_sync__DOT__gen_sync2__DOT__gen_rn__DOT__u_dont_touch_sync2ff__DOT__reg_chain_43 
            = ((2U & ((IData)(vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_aw__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__u_sync_ack__DOT__gen_bit_cell__BRA__0__KET____DOT__u_vlsit_afifo_cell_sync__DOT__gen_sync2__DOT__gen_rn__DOT__u_dont_touch_sync2ff__DOT__reg_chain) 
                      << 1U)) | (IData)(vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_aw__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_rd__DOT__reg_ack_rd));
        __Vdly__tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_r__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_rd__DOT__u_sync_req__DOT__gen_bit_cell__BRA__0__KET____DOT__u_vlsit_afifo_cell_sync__DOT__gen_sync2__DOT__gen_rn__DOT__u_dont_touch_sync2ff__DOT__reg_chain_14 
            = ((2U & ((IData)(vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_r__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_rd__DOT__u_sync_req__DOT__gen_bit_cell__BRA__0__KET____DOT__u_vlsit_afifo_cell_sync__DOT__gen_sync2__DOT__gen_rn__DOT__u_dont_touch_sync2ff__DOT__reg_chain) 
                      << 1U)) | (IData)(vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_r__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__reg_req_wr));
        vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_b__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_rd__DOT__u_sync_wr_gray__DOT__gen_bit_cell__BRA__2__KET____DOT__u_vlsit_afifo_cell_sync__DOT__gen_sync2__DOT__gen_rn__DOT__u_dont_touch_sync2ff__DOT__reg_chain 
            = ((2U & ((IData)(vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_b__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_rd__DOT__u_sync_wr_gray__DOT__gen_bit_cell__BRA__2__KET____DOT__u_vlsit_afifo_cell_sync__DOT__gen_sync2__DOT__gen_rn__DOT__u_dont_touch_sync2ff__DOT__reg_chain) 
                      << 1U)) | (1U & ((IData)(vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_b__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__reg_wgray) 
                                       >> 2U)));
        vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_b__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_rd__DOT__u_sync_wr_gray__DOT__gen_bit_cell__BRA__1__KET____DOT__u_vlsit_afifo_cell_sync__DOT__gen_sync2__DOT__gen_rn__DOT__u_dont_touch_sync2ff__DOT__reg_chain 
            = ((2U & ((IData)(vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_b__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_rd__DOT__u_sync_wr_gray__DOT__gen_bit_cell__BRA__1__KET____DOT__u_vlsit_afifo_cell_sync__DOT__gen_sync2__DOT__gen_rn__DOT__u_dont_touch_sync2ff__DOT__reg_chain) 
                      << 1U)) | (1U & ((IData)(vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_b__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__reg_wgray) 
                                       >> 1U)));
        vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_b__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_rd__DOT__u_sync_wr_gray__DOT__gen_bit_cell__BRA__0__KET____DOT__u_vlsit_afifo_cell_sync__DOT__gen_sync2__DOT__gen_rn__DOT__u_dont_touch_sync2ff__DOT__reg_chain 
            = ((2U & ((IData)(vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_b__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_rd__DOT__u_sync_wr_gray__DOT__gen_bit_cell__BRA__0__KET____DOT__u_vlsit_afifo_cell_sync__DOT__gen_sync2__DOT__gen_rn__DOT__u_dont_touch_sync2ff__DOT__reg_chain) 
                      << 1U)) | (1U & (IData)(vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_b__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__reg_wgray)));
        __Vdly__tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_b__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_rd__DOT__u_sync_req__DOT__gen_bit_cell__BRA__0__KET____DOT__u_vlsit_afifo_cell_sync__DOT__gen_sync2__DOT__gen_rn__DOT__u_dont_touch_sync2ff__DOT__reg_chain_51 
            = ((2U & ((IData)(vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_b__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_rd__DOT__u_sync_req__DOT__gen_bit_cell__BRA__0__KET____DOT__u_vlsit_afifo_cell_sync__DOT__gen_sync2__DOT__gen_rn__DOT__u_dont_touch_sync2ff__DOT__reg_chain) 
                      << 1U)) | (IData)(vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_b__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__reg_req_wr));
        vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_ar__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__u_sync_rd_gray__DOT__gen_bit_cell__BRA__2__KET____DOT__u_vlsit_afifo_cell_sync__DOT__gen_sync2__DOT__gen_rn__DOT__u_dont_touch_sync2ff__DOT__reg_chain 
            = ((2U & ((IData)(vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_ar__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__u_sync_rd_gray__DOT__gen_bit_cell__BRA__2__KET____DOT__u_vlsit_afifo_cell_sync__DOT__gen_sync2__DOT__gen_rn__DOT__u_dont_touch_sync2ff__DOT__reg_chain) 
                      << 1U)) | (1U & ((IData)(vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_ar__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_rd__DOT__reg_rgray) 
                                       >> 2U)));
        vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_ar__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__u_sync_rd_gray__DOT__gen_bit_cell__BRA__1__KET____DOT__u_vlsit_afifo_cell_sync__DOT__gen_sync2__DOT__gen_rn__DOT__u_dont_touch_sync2ff__DOT__reg_chain 
            = ((2U & ((IData)(vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_ar__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__u_sync_rd_gray__DOT__gen_bit_cell__BRA__1__KET____DOT__u_vlsit_afifo_cell_sync__DOT__gen_sync2__DOT__gen_rn__DOT__u_dont_touch_sync2ff__DOT__reg_chain) 
                      << 1U)) | (1U & ((IData)(vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_ar__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_rd__DOT__reg_rgray) 
                                       >> 1U)));
        vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_ar__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__u_sync_rd_gray__DOT__gen_bit_cell__BRA__0__KET____DOT__u_vlsit_afifo_cell_sync__DOT__gen_sync2__DOT__gen_rn__DOT__u_dont_touch_sync2ff__DOT__reg_chain 
            = ((2U & ((IData)(vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_ar__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__u_sync_rd_gray__DOT__gen_bit_cell__BRA__0__KET____DOT__u_vlsit_afifo_cell_sync__DOT__gen_sync2__DOT__gen_rn__DOT__u_dont_touch_sync2ff__DOT__reg_chain) 
                      << 1U)) | (1U & (IData)(vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_ar__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_rd__DOT__reg_rgray)));
        vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_aw__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__u_sync_rd_gray__DOT__gen_bit_cell__BRA__2__KET____DOT__u_vlsit_afifo_cell_sync__DOT__gen_sync2__DOT__gen_rn__DOT__u_dont_touch_sync2ff__DOT__reg_chain 
            = ((2U & ((IData)(vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_aw__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__u_sync_rd_gray__DOT__gen_bit_cell__BRA__2__KET____DOT__u_vlsit_afifo_cell_sync__DOT__gen_sync2__DOT__gen_rn__DOT__u_dont_touch_sync2ff__DOT__reg_chain) 
                      << 1U)) | (1U & ((IData)(vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_aw__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_rd__DOT__reg_rgray) 
                                       >> 2U)));
        vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_aw__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__u_sync_rd_gray__DOT__gen_bit_cell__BRA__1__KET____DOT__u_vlsit_afifo_cell_sync__DOT__gen_sync2__DOT__gen_rn__DOT__u_dont_touch_sync2ff__DOT__reg_chain 
            = ((2U & ((IData)(vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_aw__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__u_sync_rd_gray__DOT__gen_bit_cell__BRA__1__KET____DOT__u_vlsit_afifo_cell_sync__DOT__gen_sync2__DOT__gen_rn__DOT__u_dont_touch_sync2ff__DOT__reg_chain) 
                      << 1U)) | (1U & ((IData)(vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_aw__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_rd__DOT__reg_rgray) 
                                       >> 1U)));
        vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_aw__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__u_sync_rd_gray__DOT__gen_bit_cell__BRA__0__KET____DOT__u_vlsit_afifo_cell_sync__DOT__gen_sync2__DOT__gen_rn__DOT__u_dont_touch_sync2ff__DOT__reg_chain 
            = ((2U & ((IData)(vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_aw__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__u_sync_rd_gray__DOT__gen_bit_cell__BRA__0__KET____DOT__u_vlsit_afifo_cell_sync__DOT__gen_sync2__DOT__gen_rn__DOT__u_dont_touch_sync2ff__DOT__reg_chain) 
                      << 1U)) | (1U & (IData)(vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_aw__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_rd__DOT__reg_rgray)));
        vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_r__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_rd__DOT__u_sync_wr_gray__DOT__gen_bit_cell__BRA__4__KET____DOT__u_vlsit_afifo_cell_sync__DOT__gen_sync2__DOT__gen_rn__DOT__u_dont_touch_sync2ff__DOT__reg_chain 
            = ((2U & ((IData)(vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_r__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_rd__DOT__u_sync_wr_gray__DOT__gen_bit_cell__BRA__4__KET____DOT__u_vlsit_afifo_cell_sync__DOT__gen_sync2__DOT__gen_rn__DOT__u_dont_touch_sync2ff__DOT__reg_chain) 
                      << 1U)) | (1U & ((IData)(vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_r__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__reg_wgray) 
                                       >> 4U)));
        vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_r__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_rd__DOT__u_sync_wr_gray__DOT__gen_bit_cell__BRA__3__KET____DOT__u_vlsit_afifo_cell_sync__DOT__gen_sync2__DOT__gen_rn__DOT__u_dont_touch_sync2ff__DOT__reg_chain 
            = ((2U & ((IData)(vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_r__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_rd__DOT__u_sync_wr_gray__DOT__gen_bit_cell__BRA__3__KET____DOT__u_vlsit_afifo_cell_sync__DOT__gen_sync2__DOT__gen_rn__DOT__u_dont_touch_sync2ff__DOT__reg_chain) 
                      << 1U)) | (1U & ((IData)(vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_r__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__reg_wgray) 
                                       >> 3U)));
        vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_r__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_rd__DOT__u_sync_wr_gray__DOT__gen_bit_cell__BRA__2__KET____DOT__u_vlsit_afifo_cell_sync__DOT__gen_sync2__DOT__gen_rn__DOT__u_dont_touch_sync2ff__DOT__reg_chain 
            = ((2U & ((IData)(vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_r__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_rd__DOT__u_sync_wr_gray__DOT__gen_bit_cell__BRA__2__KET____DOT__u_vlsit_afifo_cell_sync__DOT__gen_sync2__DOT__gen_rn__DOT__u_dont_touch_sync2ff__DOT__reg_chain) 
                      << 1U)) | (1U & ((IData)(vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_r__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__reg_wgray) 
                                       >> 2U)));
        vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_r__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_rd__DOT__u_sync_wr_gray__DOT__gen_bit_cell__BRA__1__KET____DOT__u_vlsit_afifo_cell_sync__DOT__gen_sync2__DOT__gen_rn__DOT__u_dont_touch_sync2ff__DOT__reg_chain 
            = ((2U & ((IData)(vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_r__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_rd__DOT__u_sync_wr_gray__DOT__gen_bit_cell__BRA__1__KET____DOT__u_vlsit_afifo_cell_sync__DOT__gen_sync2__DOT__gen_rn__DOT__u_dont_touch_sync2ff__DOT__reg_chain) 
                      << 1U)) | (1U & ((IData)(vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_r__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__reg_wgray) 
                                       >> 1U)));
        vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_r__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_rd__DOT__u_sync_wr_gray__DOT__gen_bit_cell__BRA__0__KET____DOT__u_vlsit_afifo_cell_sync__DOT__gen_sync2__DOT__gen_rn__DOT__u_dont_touch_sync2ff__DOT__reg_chain 
            = ((2U & ((IData)(vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_r__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_rd__DOT__u_sync_wr_gray__DOT__gen_bit_cell__BRA__0__KET____DOT__u_vlsit_afifo_cell_sync__DOT__gen_sync2__DOT__gen_rn__DOT__u_dont_touch_sync2ff__DOT__reg_chain) 
                      << 1U)) | (1U & (IData)(vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_r__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__reg_wgray)));
        vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_w__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__u_sync_rd_gray__DOT__gen_bit_cell__BRA__4__KET____DOT__u_vlsit_afifo_cell_sync__DOT__gen_sync2__DOT__gen_rn__DOT__u_dont_touch_sync2ff__DOT__reg_chain 
            = ((2U & ((IData)(vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_w__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__u_sync_rd_gray__DOT__gen_bit_cell__BRA__4__KET____DOT__u_vlsit_afifo_cell_sync__DOT__gen_sync2__DOT__gen_rn__DOT__u_dont_touch_sync2ff__DOT__reg_chain) 
                      << 1U)) | (1U & ((IData)(vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_w__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_rd__DOT__reg_rgray) 
                                       >> 4U)));
        vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_w__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__u_sync_rd_gray__DOT__gen_bit_cell__BRA__3__KET____DOT__u_vlsit_afifo_cell_sync__DOT__gen_sync2__DOT__gen_rn__DOT__u_dont_touch_sync2ff__DOT__reg_chain 
            = ((2U & ((IData)(vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_w__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__u_sync_rd_gray__DOT__gen_bit_cell__BRA__3__KET____DOT__u_vlsit_afifo_cell_sync__DOT__gen_sync2__DOT__gen_rn__DOT__u_dont_touch_sync2ff__DOT__reg_chain) 
                      << 1U)) | (1U & ((IData)(vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_w__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_rd__DOT__reg_rgray) 
                                       >> 3U)));
        vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_w__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__u_sync_rd_gray__DOT__gen_bit_cell__BRA__2__KET____DOT__u_vlsit_afifo_cell_sync__DOT__gen_sync2__DOT__gen_rn__DOT__u_dont_touch_sync2ff__DOT__reg_chain 
            = ((2U & ((IData)(vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_w__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__u_sync_rd_gray__DOT__gen_bit_cell__BRA__2__KET____DOT__u_vlsit_afifo_cell_sync__DOT__gen_sync2__DOT__gen_rn__DOT__u_dont_touch_sync2ff__DOT__reg_chain) 
                      << 1U)) | (1U & ((IData)(vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_w__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_rd__DOT__reg_rgray) 
                                       >> 2U)));
        vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_w__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__u_sync_rd_gray__DOT__gen_bit_cell__BRA__1__KET____DOT__u_vlsit_afifo_cell_sync__DOT__gen_sync2__DOT__gen_rn__DOT__u_dont_touch_sync2ff__DOT__reg_chain 
            = ((2U & ((IData)(vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_w__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__u_sync_rd_gray__DOT__gen_bit_cell__BRA__1__KET____DOT__u_vlsit_afifo_cell_sync__DOT__gen_sync2__DOT__gen_rn__DOT__u_dont_touch_sync2ff__DOT__reg_chain) 
                      << 1U)) | (1U & ((IData)(vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_w__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_rd__DOT__reg_rgray) 
                                       >> 1U)));
        vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_w__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__u_sync_rd_gray__DOT__gen_bit_cell__BRA__0__KET____DOT__u_vlsit_afifo_cell_sync__DOT__gen_sync2__DOT__gen_rn__DOT__u_dont_touch_sync2ff__DOT__reg_chain 
            = ((2U & ((IData)(vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_w__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__u_sync_rd_gray__DOT__gen_bit_cell__BRA__0__KET____DOT__u_vlsit_afifo_cell_sync__DOT__gen_sync2__DOT__gen_rn__DOT__u_dont_touch_sync2ff__DOT__reg_chain) 
                      << 1U)) | (1U & (IData)(vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_w__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_rd__DOT__reg_rgray)));
        vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_r__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_rd__DOT__reg_rbin 
            = vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_r__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_rd__DOT__w_rbin_nxt;
        vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_b__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_rd__DOT__reg_rbin 
            = vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_b__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_rd__DOT__w_rbin_nxt;
        vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_ar__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__reg_wgray 
            = (((IData)(vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_ar__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__w_wbin_nxt) 
                >> 1U) ^ (IData)(vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_ar__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__w_wbin_nxt));
        vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_aw__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__reg_wgray 
            = (((IData)(vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_aw__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__w_wbin_nxt) 
                >> 1U) ^ (IData)(vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_aw__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__w_wbin_nxt));
        vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_b__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_rd__DOT__reg_rgray 
            = (((IData)(vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_b__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_rd__DOT__w_rbin_nxt) 
                >> 1U) ^ (IData)(vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_b__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_rd__DOT__w_rbin_nxt));
        vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_w__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__reg_wgray 
            = (((IData)(vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_w__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__w_wbin_nxt) 
                >> 1U) ^ (IData)(vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_w__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__w_wbin_nxt));
        vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_r__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_rd__DOT__reg_rgray 
            = (((IData)(vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_r__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_rd__DOT__w_rbin_nxt) 
                >> 1U) ^ (IData)(vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_r__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_rd__DOT__w_rbin_nxt));
        vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_w__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__reg_sw_rst_busy 
            = (0U != Vtb_axi_bridge__ConstPool__TABLE_3
               [(0x00000200U | (((IData)(vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_w__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__u_sync_rd_gray__DOT__o_data) 
                                 << 4U) | ((8U & ((IData)(vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_w__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__u_sync_ack__DOT__gen_bit_cell__BRA__0__KET____DOT__u_vlsit_afifo_cell_sync__DOT__gen_sync2__DOT__gen_rn__DOT__u_dont_touch_sync2ff__DOT__reg_chain) 
                                                  << 2U)) 
                                           | (IData)(vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_w__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__reg_fsm_srst_current_state))))]);
        vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_ar__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__reg_sw_rst_busy 
            = (0U != Vtb_axi_bridge__ConstPool__TABLE_6
               [(0x00000080U | (((IData)(vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_ar__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__u_sync_rd_gray__DOT__o_data) 
                                 << 4U) | ((8U & ((IData)(vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_ar__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__u_sync_ack__DOT__gen_bit_cell__BRA__0__KET____DOT__u_vlsit_afifo_cell_sync__DOT__gen_sync2__DOT__gen_rn__DOT__u_dont_touch_sync2ff__DOT__reg_chain) 
                                                  << 2U)) 
                                           | (IData)(vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_ar__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__reg_fsm_srst_current_state))))]);
        vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_aw__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__reg_sw_rst_busy 
            = (0U != Vtb_axi_bridge__ConstPool__TABLE_6
               [(0x00000080U | (((IData)(vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_aw__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__u_sync_rd_gray__DOT__o_data) 
                                 << 4U) | ((8U & ((IData)(vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_aw__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__u_sync_ack__DOT__gen_bit_cell__BRA__0__KET____DOT__u_vlsit_afifo_cell_sync__DOT__gen_sync2__DOT__gen_rn__DOT__u_dont_touch_sync2ff__DOT__reg_chain) 
                                                  << 2U)) 
                                           | (IData)(vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_aw__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__reg_fsm_srst_current_state))))]);
        vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_r__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_rd__DOT__reg_ack_rd 
            = (2U == Vtb_axi_bridge__ConstPool__TABLE_1
               [(((IData)(vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_r__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_rd__DOT__u_sync_wr_gray__DOT__o_data) 
                  << 3U) | ((4U & ((IData)(vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_r__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_rd__DOT__u_sync_req__DOT__gen_bit_cell__BRA__0__KET____DOT__u_vlsit_afifo_cell_sync__DOT__gen_sync2__DOT__gen_rn__DOT__u_dont_touch_sync2ff__DOT__reg_chain) 
                                   << 1U)) | (IData)(vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_r__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_rd__DOT__reg_fsm_srst_current_state)))]);
        vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_b__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_rd__DOT__reg_ack_rd 
            = (2U == Vtb_axi_bridge__ConstPool__TABLE_5
               [(((IData)(vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_b__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_rd__DOT__u_sync_wr_gray__DOT__o_data) 
                  << 3U) | ((4U & ((IData)(vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_b__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_rd__DOT__u_sync_req__DOT__gen_bit_cell__BRA__0__KET____DOT__u_vlsit_afifo_cell_sync__DOT__gen_sync2__DOT__gen_rn__DOT__u_dont_touch_sync2ff__DOT__reg_chain) 
                                   << 1U)) | (IData)(vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_b__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_rd__DOT__reg_fsm_srst_current_state)))]);
        vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_w__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__reg_req_wr 
            = ((1U == Vtb_axi_bridge__ConstPool__TABLE_3
                [(0x00000200U | (((IData)(vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_w__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__u_sync_rd_gray__DOT__o_data) 
                                  << 4U) | ((8U & ((IData)(vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_w__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__u_sync_ack__DOT__gen_bit_cell__BRA__0__KET____DOT__u_vlsit_afifo_cell_sync__DOT__gen_sync2__DOT__gen_rn__DOT__u_dont_touch_sync2ff__DOT__reg_chain) 
                                                   << 2U)) 
                                            | (IData)(vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_w__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__reg_fsm_srst_current_state))))]) 
               | ((2U == Vtb_axi_bridge__ConstPool__TABLE_3
                   [(0x00000200U | (((IData)(vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_w__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__u_sync_rd_gray__DOT__o_data) 
                                     << 4U) | ((8U 
                                                & ((IData)(vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_w__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__u_sync_ack__DOT__gen_bit_cell__BRA__0__KET____DOT__u_vlsit_afifo_cell_sync__DOT__gen_sync2__DOT__gen_rn__DOT__u_dont_touch_sync2ff__DOT__reg_chain) 
                                                   << 2U)) 
                                               | (IData)(vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_w__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__reg_fsm_srst_current_state))))]) 
                  | (3U == Vtb_axi_bridge__ConstPool__TABLE_3
                     [(0x00000200U | (((IData)(vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_w__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__u_sync_rd_gray__DOT__o_data) 
                                       << 4U) | ((8U 
                                                  & ((IData)(vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_w__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__u_sync_ack__DOT__gen_bit_cell__BRA__0__KET____DOT__u_vlsit_afifo_cell_sync__DOT__gen_sync2__DOT__gen_rn__DOT__u_dont_touch_sync2ff__DOT__reg_chain) 
                                                     << 2U)) 
                                                 | (IData)(vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_w__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__reg_fsm_srst_current_state))))])));
        vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_ar__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__reg_req_wr 
            = ((1U == Vtb_axi_bridge__ConstPool__TABLE_6
                [(0x00000080U | (((IData)(vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_ar__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__u_sync_rd_gray__DOT__o_data) 
                                  << 4U) | ((8U & ((IData)(vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_ar__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__u_sync_ack__DOT__gen_bit_cell__BRA__0__KET____DOT__u_vlsit_afifo_cell_sync__DOT__gen_sync2__DOT__gen_rn__DOT__u_dont_touch_sync2ff__DOT__reg_chain) 
                                                   << 2U)) 
                                            | (IData)(vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_ar__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__reg_fsm_srst_current_state))))]) 
               | ((2U == Vtb_axi_bridge__ConstPool__TABLE_6
                   [(0x00000080U | (((IData)(vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_ar__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__u_sync_rd_gray__DOT__o_data) 
                                     << 4U) | ((8U 
                                                & ((IData)(vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_ar__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__u_sync_ack__DOT__gen_bit_cell__BRA__0__KET____DOT__u_vlsit_afifo_cell_sync__DOT__gen_sync2__DOT__gen_rn__DOT__u_dont_touch_sync2ff__DOT__reg_chain) 
                                                   << 2U)) 
                                               | (IData)(vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_ar__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__reg_fsm_srst_current_state))))]) 
                  | (3U == Vtb_axi_bridge__ConstPool__TABLE_6
                     [(0x00000080U | (((IData)(vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_ar__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__u_sync_rd_gray__DOT__o_data) 
                                       << 4U) | ((8U 
                                                  & ((IData)(vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_ar__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__u_sync_ack__DOT__gen_bit_cell__BRA__0__KET____DOT__u_vlsit_afifo_cell_sync__DOT__gen_sync2__DOT__gen_rn__DOT__u_dont_touch_sync2ff__DOT__reg_chain) 
                                                     << 2U)) 
                                                 | (IData)(vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_ar__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__reg_fsm_srst_current_state))))])));
        vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_aw__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__reg_req_wr 
            = ((1U == Vtb_axi_bridge__ConstPool__TABLE_6
                [(0x00000080U | (((IData)(vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_aw__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__u_sync_rd_gray__DOT__o_data) 
                                  << 4U) | ((8U & ((IData)(vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_aw__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__u_sync_ack__DOT__gen_bit_cell__BRA__0__KET____DOT__u_vlsit_afifo_cell_sync__DOT__gen_sync2__DOT__gen_rn__DOT__u_dont_touch_sync2ff__DOT__reg_chain) 
                                                   << 2U)) 
                                            | (IData)(vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_aw__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__reg_fsm_srst_current_state))))]) 
               | ((2U == Vtb_axi_bridge__ConstPool__TABLE_6
                   [(0x00000080U | (((IData)(vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_aw__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__u_sync_rd_gray__DOT__o_data) 
                                     << 4U) | ((8U 
                                                & ((IData)(vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_aw__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__u_sync_ack__DOT__gen_bit_cell__BRA__0__KET____DOT__u_vlsit_afifo_cell_sync__DOT__gen_sync2__DOT__gen_rn__DOT__u_dont_touch_sync2ff__DOT__reg_chain) 
                                                   << 2U)) 
                                               | (IData)(vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_aw__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__reg_fsm_srst_current_state))))]) 
                  | (3U == Vtb_axi_bridge__ConstPool__TABLE_6
                     [(0x00000080U | (((IData)(vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_aw__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__u_sync_rd_gray__DOT__o_data) 
                                       << 4U) | ((8U 
                                                  & ((IData)(vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_aw__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__u_sync_ack__DOT__gen_bit_cell__BRA__0__KET____DOT__u_vlsit_afifo_cell_sync__DOT__gen_sync2__DOT__gen_rn__DOT__u_dont_touch_sync2ff__DOT__reg_chain) 
                                                     << 2U)) 
                                                 | (IData)(vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_aw__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__reg_fsm_srst_current_state))))])));
    } else {
        __Vdly__tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_w__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__reg_fsm_srst_current_state_17 = 0U;
        __Vdly__tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_ar__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__reg_fsm_srst_current_state_28 = 0U;
        __Vdly__tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_aw__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__reg_fsm_srst_current_state_37 = 0U;
        __Vdly__tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_r__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_rd__DOT__reg_fsm_srst_current_state_7 = 0U;
        __Vdly__tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_b__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_rd__DOT__reg_fsm_srst_current_state_46 = 0U;
        __Vdly__tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_w__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__u_sync_ack__DOT__gen_bit_cell__BRA__0__KET____DOT__u_vlsit_afifo_cell_sync__DOT__gen_sync2__DOT__gen_rn__DOT__u_dont_touch_sync2ff__DOT__reg_chain_25 = 0U;
        __Vdly__tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_ar__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__u_sync_ack__DOT__gen_bit_cell__BRA__0__KET____DOT__u_vlsit_afifo_cell_sync__DOT__gen_sync2__DOT__gen_rn__DOT__u_dont_touch_sync2ff__DOT__reg_chain_34 = 0U;
        __Vdly__tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_aw__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__u_sync_ack__DOT__gen_bit_cell__BRA__0__KET____DOT__u_vlsit_afifo_cell_sync__DOT__gen_sync2__DOT__gen_rn__DOT__u_dont_touch_sync2ff__DOT__reg_chain_43 = 0U;
        __Vdly__tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_r__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_rd__DOT__u_sync_req__DOT__gen_bit_cell__BRA__0__KET____DOT__u_vlsit_afifo_cell_sync__DOT__gen_sync2__DOT__gen_rn__DOT__u_dont_touch_sync2ff__DOT__reg_chain_14 = 0U;
        vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_b__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_rd__DOT__u_sync_wr_gray__DOT__gen_bit_cell__BRA__2__KET____DOT__u_vlsit_afifo_cell_sync__DOT__gen_sync2__DOT__gen_rn__DOT__u_dont_touch_sync2ff__DOT__reg_chain = 0U;
        vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_b__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_rd__DOT__u_sync_wr_gray__DOT__gen_bit_cell__BRA__1__KET____DOT__u_vlsit_afifo_cell_sync__DOT__gen_sync2__DOT__gen_rn__DOT__u_dont_touch_sync2ff__DOT__reg_chain = 0U;
        vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_b__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_rd__DOT__u_sync_wr_gray__DOT__gen_bit_cell__BRA__0__KET____DOT__u_vlsit_afifo_cell_sync__DOT__gen_sync2__DOT__gen_rn__DOT__u_dont_touch_sync2ff__DOT__reg_chain = 0U;
        __Vdly__tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_b__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_rd__DOT__u_sync_req__DOT__gen_bit_cell__BRA__0__KET____DOT__u_vlsit_afifo_cell_sync__DOT__gen_sync2__DOT__gen_rn__DOT__u_dont_touch_sync2ff__DOT__reg_chain_51 = 0U;
        vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_ar__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__u_sync_rd_gray__DOT__gen_bit_cell__BRA__2__KET____DOT__u_vlsit_afifo_cell_sync__DOT__gen_sync2__DOT__gen_rn__DOT__u_dont_touch_sync2ff__DOT__reg_chain = 0U;
        vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_ar__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__u_sync_rd_gray__DOT__gen_bit_cell__BRA__1__KET____DOT__u_vlsit_afifo_cell_sync__DOT__gen_sync2__DOT__gen_rn__DOT__u_dont_touch_sync2ff__DOT__reg_chain = 0U;
        vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_ar__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__u_sync_rd_gray__DOT__gen_bit_cell__BRA__0__KET____DOT__u_vlsit_afifo_cell_sync__DOT__gen_sync2__DOT__gen_rn__DOT__u_dont_touch_sync2ff__DOT__reg_chain = 0U;
        vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_aw__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__u_sync_rd_gray__DOT__gen_bit_cell__BRA__2__KET____DOT__u_vlsit_afifo_cell_sync__DOT__gen_sync2__DOT__gen_rn__DOT__u_dont_touch_sync2ff__DOT__reg_chain = 0U;
        vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_aw__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__u_sync_rd_gray__DOT__gen_bit_cell__BRA__1__KET____DOT__u_vlsit_afifo_cell_sync__DOT__gen_sync2__DOT__gen_rn__DOT__u_dont_touch_sync2ff__DOT__reg_chain = 0U;
        vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_aw__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__u_sync_rd_gray__DOT__gen_bit_cell__BRA__0__KET____DOT__u_vlsit_afifo_cell_sync__DOT__gen_sync2__DOT__gen_rn__DOT__u_dont_touch_sync2ff__DOT__reg_chain = 0U;
        vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_r__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_rd__DOT__u_sync_wr_gray__DOT__gen_bit_cell__BRA__4__KET____DOT__u_vlsit_afifo_cell_sync__DOT__gen_sync2__DOT__gen_rn__DOT__u_dont_touch_sync2ff__DOT__reg_chain = 0U;
        vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_r__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_rd__DOT__u_sync_wr_gray__DOT__gen_bit_cell__BRA__3__KET____DOT__u_vlsit_afifo_cell_sync__DOT__gen_sync2__DOT__gen_rn__DOT__u_dont_touch_sync2ff__DOT__reg_chain = 0U;
        vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_r__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_rd__DOT__u_sync_wr_gray__DOT__gen_bit_cell__BRA__2__KET____DOT__u_vlsit_afifo_cell_sync__DOT__gen_sync2__DOT__gen_rn__DOT__u_dont_touch_sync2ff__DOT__reg_chain = 0U;
        vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_r__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_rd__DOT__u_sync_wr_gray__DOT__gen_bit_cell__BRA__1__KET____DOT__u_vlsit_afifo_cell_sync__DOT__gen_sync2__DOT__gen_rn__DOT__u_dont_touch_sync2ff__DOT__reg_chain = 0U;
        vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_r__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_rd__DOT__u_sync_wr_gray__DOT__gen_bit_cell__BRA__0__KET____DOT__u_vlsit_afifo_cell_sync__DOT__gen_sync2__DOT__gen_rn__DOT__u_dont_touch_sync2ff__DOT__reg_chain = 0U;
        vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_w__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__u_sync_rd_gray__DOT__gen_bit_cell__BRA__4__KET____DOT__u_vlsit_afifo_cell_sync__DOT__gen_sync2__DOT__gen_rn__DOT__u_dont_touch_sync2ff__DOT__reg_chain = 0U;
        vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_w__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__u_sync_rd_gray__DOT__gen_bit_cell__BRA__3__KET____DOT__u_vlsit_afifo_cell_sync__DOT__gen_sync2__DOT__gen_rn__DOT__u_dont_touch_sync2ff__DOT__reg_chain = 0U;
        vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_w__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__u_sync_rd_gray__DOT__gen_bit_cell__BRA__2__KET____DOT__u_vlsit_afifo_cell_sync__DOT__gen_sync2__DOT__gen_rn__DOT__u_dont_touch_sync2ff__DOT__reg_chain = 0U;
        vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_w__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__u_sync_rd_gray__DOT__gen_bit_cell__BRA__1__KET____DOT__u_vlsit_afifo_cell_sync__DOT__gen_sync2__DOT__gen_rn__DOT__u_dont_touch_sync2ff__DOT__reg_chain = 0U;
        vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_w__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__u_sync_rd_gray__DOT__gen_bit_cell__BRA__0__KET____DOT__u_vlsit_afifo_cell_sync__DOT__gen_sync2__DOT__gen_rn__DOT__u_dont_touch_sync2ff__DOT__reg_chain = 0U;
        vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_r__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_rd__DOT__reg_rbin = 0U;
        vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_b__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_rd__DOT__reg_rbin = 0U;
        vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_ar__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__reg_wgray = 0U;
        vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_aw__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__reg_wgray = 0U;
        vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_b__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_rd__DOT__reg_rgray = 0U;
        vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_w__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__reg_wgray = 0U;
        vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_r__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_rd__DOT__reg_rgray = 0U;
        vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_w__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__reg_sw_rst_busy = 0U;
        vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_ar__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__reg_sw_rst_busy = 0U;
        vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_aw__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__reg_sw_rst_busy = 0U;
        vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_r__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_rd__DOT__reg_ack_rd = 0U;
        vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_b__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_rd__DOT__reg_ack_rd = 0U;
        vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_w__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__reg_req_wr = 0U;
        vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_ar__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__reg_req_wr = 0U;
        vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_aw__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__reg_req_wr = 0U;
    }
    vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_r__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_rd__DOT__u_sync_req__DOT__gen_bit_cell__BRA__0__KET____DOT__u_vlsit_afifo_cell_sync__DOT__gen_sync2__DOT__gen_rn__DOT__u_dont_touch_sync2ff__DOT__reg_chain 
        = __Vdly__tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_r__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_rd__DOT__u_sync_req__DOT__gen_bit_cell__BRA__0__KET____DOT__u_vlsit_afifo_cell_sync__DOT__gen_sync2__DOT__gen_rn__DOT__u_dont_touch_sync2ff__DOT__reg_chain_14;
    vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_r__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_rd__DOT__reg_fsm_srst_current_state 
        = __Vdly__tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_r__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_rd__DOT__reg_fsm_srst_current_state_7;
    vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_b__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_rd__DOT__u_sync_req__DOT__gen_bit_cell__BRA__0__KET____DOT__u_vlsit_afifo_cell_sync__DOT__gen_sync2__DOT__gen_rn__DOT__u_dont_touch_sync2ff__DOT__reg_chain 
        = __Vdly__tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_b__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_rd__DOT__u_sync_req__DOT__gen_bit_cell__BRA__0__KET____DOT__u_vlsit_afifo_cell_sync__DOT__gen_sync2__DOT__gen_rn__DOT__u_dont_touch_sync2ff__DOT__reg_chain_51;
    vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_b__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_rd__DOT__reg_fsm_srst_current_state 
        = __Vdly__tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_b__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_rd__DOT__reg_fsm_srst_current_state_46;
    vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_w__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__u_sync_ack__DOT__gen_bit_cell__BRA__0__KET____DOT__u_vlsit_afifo_cell_sync__DOT__gen_sync2__DOT__gen_rn__DOT__u_dont_touch_sync2ff__DOT__reg_chain 
        = __Vdly__tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_w__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__u_sync_ack__DOT__gen_bit_cell__BRA__0__KET____DOT__u_vlsit_afifo_cell_sync__DOT__gen_sync2__DOT__gen_rn__DOT__u_dont_touch_sync2ff__DOT__reg_chain_25;
    vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_w__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__reg_fsm_srst_current_state 
        = __Vdly__tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_w__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__reg_fsm_srst_current_state_17;
    vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_ar__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__u_sync_ack__DOT__gen_bit_cell__BRA__0__KET____DOT__u_vlsit_afifo_cell_sync__DOT__gen_sync2__DOT__gen_rn__DOT__u_dont_touch_sync2ff__DOT__reg_chain 
        = __Vdly__tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_ar__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__u_sync_ack__DOT__gen_bit_cell__BRA__0__KET____DOT__u_vlsit_afifo_cell_sync__DOT__gen_sync2__DOT__gen_rn__DOT__u_dont_touch_sync2ff__DOT__reg_chain_34;
    vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_ar__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__reg_fsm_srst_current_state 
        = __Vdly__tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_ar__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__reg_fsm_srst_current_state_28;
    vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_aw__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__u_sync_ack__DOT__gen_bit_cell__BRA__0__KET____DOT__u_vlsit_afifo_cell_sync__DOT__gen_sync2__DOT__gen_rn__DOT__u_dont_touch_sync2ff__DOT__reg_chain 
        = __Vdly__tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_aw__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__u_sync_ack__DOT__gen_bit_cell__BRA__0__KET____DOT__u_vlsit_afifo_cell_sync__DOT__gen_sync2__DOT__gen_rn__DOT__u_dont_touch_sync2ff__DOT__reg_chain_43;
    vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_aw__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__reg_fsm_srst_current_state 
        = __Vdly__tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_aw__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__reg_fsm_srst_current_state_37;
    vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_b__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_rd__DOT__u_sync_wr_gray__DOT__o_data 
        = ((4U & ((IData)(vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_b__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_rd__DOT__u_sync_wr_gray__DOT__gen_bit_cell__BRA__2__KET____DOT__u_vlsit_afifo_cell_sync__DOT__gen_sync2__DOT__gen_rn__DOT__u_dont_touch_sync2ff__DOT__reg_chain) 
                  << 1U)) | ((2U & (IData)(vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_b__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_rd__DOT__u_sync_wr_gray__DOT__gen_bit_cell__BRA__1__KET____DOT__u_vlsit_afifo_cell_sync__DOT__gen_sync2__DOT__gen_rn__DOT__u_dont_touch_sync2ff__DOT__reg_chain)) 
                             | (1U & ((IData)(vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_b__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_rd__DOT__u_sync_wr_gray__DOT__gen_bit_cell__BRA__0__KET____DOT__u_vlsit_afifo_cell_sync__DOT__gen_sync2__DOT__gen_rn__DOT__u_dont_touch_sync2ff__DOT__reg_chain) 
                                      >> 1U))));
    vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_ar__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__u_sync_rd_gray__DOT__o_data 
        = ((4U & ((IData)(vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_ar__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__u_sync_rd_gray__DOT__gen_bit_cell__BRA__2__KET____DOT__u_vlsit_afifo_cell_sync__DOT__gen_sync2__DOT__gen_rn__DOT__u_dont_touch_sync2ff__DOT__reg_chain) 
                  << 1U)) | ((2U & (IData)(vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_ar__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__u_sync_rd_gray__DOT__gen_bit_cell__BRA__1__KET____DOT__u_vlsit_afifo_cell_sync__DOT__gen_sync2__DOT__gen_rn__DOT__u_dont_touch_sync2ff__DOT__reg_chain)) 
                             | (1U & ((IData)(vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_ar__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__u_sync_rd_gray__DOT__gen_bit_cell__BRA__0__KET____DOT__u_vlsit_afifo_cell_sync__DOT__gen_sync2__DOT__gen_rn__DOT__u_dont_touch_sync2ff__DOT__reg_chain) 
                                      >> 1U))));
    vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_aw__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__u_sync_rd_gray__DOT__o_data 
        = ((4U & ((IData)(vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_aw__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__u_sync_rd_gray__DOT__gen_bit_cell__BRA__2__KET____DOT__u_vlsit_afifo_cell_sync__DOT__gen_sync2__DOT__gen_rn__DOT__u_dont_touch_sync2ff__DOT__reg_chain) 
                  << 1U)) | ((2U & (IData)(vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_aw__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__u_sync_rd_gray__DOT__gen_bit_cell__BRA__1__KET____DOT__u_vlsit_afifo_cell_sync__DOT__gen_sync2__DOT__gen_rn__DOT__u_dont_touch_sync2ff__DOT__reg_chain)) 
                             | (1U & ((IData)(vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_aw__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__u_sync_rd_gray__DOT__gen_bit_cell__BRA__0__KET____DOT__u_vlsit_afifo_cell_sync__DOT__gen_sync2__DOT__gen_rn__DOT__u_dont_touch_sync2ff__DOT__reg_chain) 
                                      >> 1U))));
    vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_r__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_rd__DOT__u_sync_wr_gray__DOT__o_data 
        = ((((4U & ((IData)(vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_r__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_rd__DOT__u_sync_wr_gray__DOT__gen_bit_cell__BRA__4__KET____DOT__u_vlsit_afifo_cell_sync__DOT__gen_sync2__DOT__gen_rn__DOT__u_dont_touch_sync2ff__DOT__reg_chain) 
                    << 1U)) | ((2U & (IData)(vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_r__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_rd__DOT__u_sync_wr_gray__DOT__gen_bit_cell__BRA__3__KET____DOT__u_vlsit_afifo_cell_sync__DOT__gen_sync2__DOT__gen_rn__DOT__u_dont_touch_sync2ff__DOT__reg_chain)) 
                               | (1U & ((IData)(vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_r__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_rd__DOT__u_sync_wr_gray__DOT__gen_bit_cell__BRA__2__KET____DOT__u_vlsit_afifo_cell_sync__DOT__gen_sync2__DOT__gen_rn__DOT__u_dont_touch_sync2ff__DOT__reg_chain) 
                                        >> 1U)))) << 2U) 
           | ((2U & (IData)(vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_r__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_rd__DOT__u_sync_wr_gray__DOT__gen_bit_cell__BRA__1__KET____DOT__u_vlsit_afifo_cell_sync__DOT__gen_sync2__DOT__gen_rn__DOT__u_dont_touch_sync2ff__DOT__reg_chain)) 
              | (1U & ((IData)(vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_r__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_rd__DOT__u_sync_wr_gray__DOT__gen_bit_cell__BRA__0__KET____DOT__u_vlsit_afifo_cell_sync__DOT__gen_sync2__DOT__gen_rn__DOT__u_dont_touch_sync2ff__DOT__reg_chain) 
                       >> 1U))));
    vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_w__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__u_sync_rd_gray__DOT__o_data 
        = ((((4U & ((IData)(vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_w__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__u_sync_rd_gray__DOT__gen_bit_cell__BRA__4__KET____DOT__u_vlsit_afifo_cell_sync__DOT__gen_sync2__DOT__gen_rn__DOT__u_dont_touch_sync2ff__DOT__reg_chain) 
                    << 1U)) | ((2U & (IData)(vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_w__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__u_sync_rd_gray__DOT__gen_bit_cell__BRA__3__KET____DOT__u_vlsit_afifo_cell_sync__DOT__gen_sync2__DOT__gen_rn__DOT__u_dont_touch_sync2ff__DOT__reg_chain)) 
                               | (1U & ((IData)(vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_w__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__u_sync_rd_gray__DOT__gen_bit_cell__BRA__2__KET____DOT__u_vlsit_afifo_cell_sync__DOT__gen_sync2__DOT__gen_rn__DOT__u_dont_touch_sync2ff__DOT__reg_chain) 
                                        >> 1U)))) << 2U) 
           | ((2U & (IData)(vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_w__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__u_sync_rd_gray__DOT__gen_bit_cell__BRA__1__KET____DOT__u_vlsit_afifo_cell_sync__DOT__gen_sync2__DOT__gen_rn__DOT__u_dont_touch_sync2ff__DOT__reg_chain)) 
              | (1U & ((IData)(vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_w__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__u_sync_rd_gray__DOT__gen_bit_cell__BRA__0__KET____DOT__u_vlsit_afifo_cell_sync__DOT__gen_sync2__DOT__gen_rn__DOT__u_dont_touch_sync2ff__DOT__reg_chain) 
                       >> 1U))));
}

void Vtb_axi_bridge___024root___nba_sequent__TOP__2(Vtb_axi_bridge___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_axi_bridge___024root___nba_sequent__TOP__2\n"); );
    Vtb_axi_bridge__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Locals
    IData/*31:0*/ __Vtask_tb_axi_bridge__DOT__chk__check_id_9;
    __Vtask_tb_axi_bridge__DOT__chk__check_id_9 = 0;
    CData/*0:0*/ __Vtask_tb_axi_bridge__DOT__chk__antecedent_10;
    __Vtask_tb_axi_bridge__DOT__chk__antecedent_10 = 0;
    CData/*0:0*/ __Vtask_tb_axi_bridge__DOT__chk__consequent_11;
    __Vtask_tb_axi_bridge__DOT__chk__consequent_11 = 0;
    IData/*31:0*/ __Vtask_tb_axi_bridge__DOT__chk__check_id_12;
    __Vtask_tb_axi_bridge__DOT__chk__check_id_12 = 0;
    CData/*0:0*/ __Vtask_tb_axi_bridge__DOT__chk__antecedent_13;
    __Vtask_tb_axi_bridge__DOT__chk__antecedent_13 = 0;
    CData/*0:0*/ __Vtask_tb_axi_bridge__DOT__chk__consequent_14;
    __Vtask_tb_axi_bridge__DOT__chk__consequent_14 = 0;
    IData/*31:0*/ __Vtask_tb_axi_bridge__DOT__chk__check_id_15;
    __Vtask_tb_axi_bridge__DOT__chk__check_id_15 = 0;
    CData/*0:0*/ __Vtask_tb_axi_bridge__DOT__chk__antecedent_16;
    __Vtask_tb_axi_bridge__DOT__chk__antecedent_16 = 0;
    CData/*0:0*/ __Vtask_tb_axi_bridge__DOT__chk__consequent_17;
    __Vtask_tb_axi_bridge__DOT__chk__consequent_17 = 0;
    IData/*31:0*/ __Vtask_tb_axi_bridge__DOT__chk__check_id_18;
    __Vtask_tb_axi_bridge__DOT__chk__check_id_18 = 0;
    CData/*0:0*/ __Vtask_tb_axi_bridge__DOT__chk__consequent_20;
    __Vtask_tb_axi_bridge__DOT__chk__consequent_20 = 0;
    IData/*31:0*/ __Vtask_tb_axi_bridge__DOT__chk__check_id_21;
    __Vtask_tb_axi_bridge__DOT__chk__check_id_21 = 0;
    CData/*0:0*/ __Vtask_tb_axi_bridge__DOT__chk__consequent_23;
    __Vtask_tb_axi_bridge__DOT__chk__consequent_23 = 0;
    IData/*31:0*/ __Vtask_tb_axi_bridge__DOT__chk__check_id_33;
    __Vtask_tb_axi_bridge__DOT__chk__check_id_33 = 0;
    CData/*0:0*/ __Vtask_tb_axi_bridge__DOT__chk__antecedent_34;
    __Vtask_tb_axi_bridge__DOT__chk__antecedent_34 = 0;
    CData/*0:0*/ __Vtask_tb_axi_bridge__DOT__chk__consequent_35;
    __Vtask_tb_axi_bridge__DOT__chk__consequent_35 = 0;
    IData/*31:0*/ __Vtask_tb_axi_bridge__DOT__chk__check_id_36;
    __Vtask_tb_axi_bridge__DOT__chk__check_id_36 = 0;
    CData/*0:0*/ __Vtask_tb_axi_bridge__DOT__chk__antecedent_37;
    __Vtask_tb_axi_bridge__DOT__chk__antecedent_37 = 0;
    CData/*0:0*/ __Vtask_tb_axi_bridge__DOT__chk__consequent_38;
    __Vtask_tb_axi_bridge__DOT__chk__consequent_38 = 0;
    IData/*31:0*/ __Vtask_tb_axi_bridge__DOT__chk__check_id_39;
    __Vtask_tb_axi_bridge__DOT__chk__check_id_39 = 0;
    CData/*0:0*/ __Vtask_tb_axi_bridge__DOT__chk__antecedent_40;
    __Vtask_tb_axi_bridge__DOT__chk__antecedent_40 = 0;
    CData/*0:0*/ __Vtask_tb_axi_bridge__DOT__chk__consequent_41;
    __Vtask_tb_axi_bridge__DOT__chk__consequent_41 = 0;
    IData/*31:0*/ __Vtask_tb_axi_bridge__DOT__chk__check_id_42;
    __Vtask_tb_axi_bridge__DOT__chk__check_id_42 = 0;
    CData/*0:0*/ __Vtask_tb_axi_bridge__DOT__chk__consequent_44;
    __Vtask_tb_axi_bridge__DOT__chk__consequent_44 = 0;
    IData/*31:0*/ __Vtask_tb_axi_bridge__DOT__chk__check_id_45;
    __Vtask_tb_axi_bridge__DOT__chk__check_id_45 = 0;
    CData/*0:0*/ __Vtask_tb_axi_bridge__DOT__chk__consequent_47;
    __Vtask_tb_axi_bridge__DOT__chk__consequent_47 = 0;
    IData/*31:0*/ __Vtask_tb_axi_bridge__DOT__chk__check_id_48;
    __Vtask_tb_axi_bridge__DOT__chk__check_id_48 = 0;
    CData/*0:0*/ __Vtask_tb_axi_bridge__DOT__chk__antecedent_49;
    __Vtask_tb_axi_bridge__DOT__chk__antecedent_49 = 0;
    CData/*0:0*/ __Vtask_tb_axi_bridge__DOT__chk__consequent_50;
    __Vtask_tb_axi_bridge__DOT__chk__consequent_50 = 0;
    IData/*31:0*/ __Vtask_tb_axi_bridge__DOT__chk__check_id_51;
    __Vtask_tb_axi_bridge__DOT__chk__check_id_51 = 0;
    CData/*0:0*/ __Vtask_tb_axi_bridge__DOT__chk__antecedent_52;
    __Vtask_tb_axi_bridge__DOT__chk__antecedent_52 = 0;
    CData/*0:0*/ __Vtask_tb_axi_bridge__DOT__chk__consequent_53;
    __Vtask_tb_axi_bridge__DOT__chk__consequent_53 = 0;
    IData/*31:0*/ __Vtask_tb_axi_bridge__DOT__chk__check_id_54;
    __Vtask_tb_axi_bridge__DOT__chk__check_id_54 = 0;
    CData/*0:0*/ __Vtask_tb_axi_bridge__DOT__chk__antecedent_55;
    __Vtask_tb_axi_bridge__DOT__chk__antecedent_55 = 0;
    CData/*0:0*/ __Vtask_tb_axi_bridge__DOT__chk__consequent_56;
    __Vtask_tb_axi_bridge__DOT__chk__consequent_56 = 0;
    IData/*31:0*/ __Vtask_tb_axi_bridge__DOT__chk__check_id_81;
    __Vtask_tb_axi_bridge__DOT__chk__check_id_81 = 0;
    CData/*0:0*/ __Vtask_tb_axi_bridge__DOT__chk__antecedent_82;
    __Vtask_tb_axi_bridge__DOT__chk__antecedent_82 = 0;
    CData/*0:0*/ __Vtask_tb_axi_bridge__DOT__chk__consequent_83;
    __Vtask_tb_axi_bridge__DOT__chk__consequent_83 = 0;
    IData/*31:0*/ __Vtask_tb_axi_bridge__DOT__chk__check_id_84;
    __Vtask_tb_axi_bridge__DOT__chk__check_id_84 = 0;
    CData/*0:0*/ __Vtask_tb_axi_bridge__DOT__chk__antecedent_85;
    __Vtask_tb_axi_bridge__DOT__chk__antecedent_85 = 0;
    CData/*0:0*/ __Vtask_tb_axi_bridge__DOT__chk__consequent_86;
    __Vtask_tb_axi_bridge__DOT__chk__consequent_86 = 0;
    IData/*31:0*/ __Vtask_tb_axi_bridge__DOT__chk__check_id_87;
    __Vtask_tb_axi_bridge__DOT__chk__check_id_87 = 0;
    CData/*0:0*/ __Vtask_tb_axi_bridge__DOT__chk__antecedent_88;
    __Vtask_tb_axi_bridge__DOT__chk__antecedent_88 = 0;
    CData/*0:0*/ __Vtask_tb_axi_bridge__DOT__chk__consequent_89;
    __Vtask_tb_axi_bridge__DOT__chk__consequent_89 = 0;
    IData/*31:0*/ __Vtask_tb_axi_bridge__DOT__chk__check_id_90;
    __Vtask_tb_axi_bridge__DOT__chk__check_id_90 = 0;
    CData/*0:0*/ __Vtask_tb_axi_bridge__DOT__chk__consequent_92;
    __Vtask_tb_axi_bridge__DOT__chk__consequent_92 = 0;
    IData/*31:0*/ __Vtask_tb_axi_bridge__DOT__chk__check_id_93;
    __Vtask_tb_axi_bridge__DOT__chk__check_id_93 = 0;
    CData/*0:0*/ __Vtask_tb_axi_bridge__DOT__chk__consequent_95;
    __Vtask_tb_axi_bridge__DOT__chk__consequent_95 = 0;
    IData/*31:0*/ __Vtask_tb_axi_bridge__DOT__chk__check_id_96;
    __Vtask_tb_axi_bridge__DOT__chk__check_id_96 = 0;
    CData/*0:0*/ __Vtask_tb_axi_bridge__DOT__chk__antecedent_97;
    __Vtask_tb_axi_bridge__DOT__chk__antecedent_97 = 0;
    CData/*0:0*/ __Vtask_tb_axi_bridge__DOT__chk__consequent_98;
    __Vtask_tb_axi_bridge__DOT__chk__consequent_98 = 0;
    IData/*31:0*/ __Vtask_tb_axi_bridge__DOT__chk__check_id_99;
    __Vtask_tb_axi_bridge__DOT__chk__check_id_99 = 0;
    CData/*0:0*/ __Vtask_tb_axi_bridge__DOT__chk__antecedent_100;
    __Vtask_tb_axi_bridge__DOT__chk__antecedent_100 = 0;
    CData/*0:0*/ __Vtask_tb_axi_bridge__DOT__chk__consequent_101;
    __Vtask_tb_axi_bridge__DOT__chk__consequent_101 = 0;
    IData/*31:0*/ __Vtask_tb_axi_bridge__DOT__chk__check_id_102;
    __Vtask_tb_axi_bridge__DOT__chk__check_id_102 = 0;
    CData/*0:0*/ __Vtask_tb_axi_bridge__DOT__chk__antecedent_103;
    __Vtask_tb_axi_bridge__DOT__chk__antecedent_103 = 0;
    CData/*0:0*/ __Vtask_tb_axi_bridge__DOT__chk__consequent_104;
    __Vtask_tb_axi_bridge__DOT__chk__consequent_104 = 0;
    VlWide<3>/*95:0*/ __Vtemp_17;
    VlWide<3>/*95:0*/ __Vtemp_23;
    VlWide<3>/*95:0*/ __Vtemp_44;
    VlWide<3>/*95:0*/ __Vtemp_50;
    // Body
    vlSelfRef.__Vdly_Set__tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_b__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_mem__DOT__gen_array__DOT__reg_mem_112 = 0U;
    vlSelfRef.__Vdly_Set__tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_r__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_mem__DOT__gen_array__DOT__reg_mem_109 = 0U;
    if (vlSelfRef.tb_axi_bridge__DOT__i_rst_n_mgr) {
        __Vtask_tb_axi_bridge__DOT__chk__consequent_50 
            = vlSelfRef.tb_axi_bridge__DOT__i_axi_bvalid;
        __Vtask_tb_axi_bridge__DOT__chk__antecedent_49 
            = vlSelfRef.tb_axi_bridge__DOT__src_b_stall;
        if (((IData)(vlSelfRef.tb_axi_bridge__DOT__i_axi_bvalid) 
             & (IData)(vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_b__DOT__o_axi_bready))) {
            vlSelfRef.tb_axi_bridge__DOT__exp_b[(0x000000ffU 
                                                 & vlSelfRef.tb_axi_bridge__DOT__b_tail)][0U] 
                = ((0xffffffc0U & vlSelfRef.tb_axi_bridge__DOT__exp_b
                    [(0x000000ffU & vlSelfRef.tb_axi_bridge__DOT__b_tail)][0U]) 
                   | (((IData)(vlSelfRef.tb_axi_bridge__DOT__i_axi_bid) 
                       << 2U) | (IData)(vlSelfRef.tb_axi_bridge__DOT__i_axi_bresp)));
            vlSelfRef.tb_axi_bridge__DOT__exp_b[(0x000000ffU 
                                                 & vlSelfRef.tb_axi_bridge__DOT__b_tail)][0U] 
                = (0x0000003fU & vlSelfRef.tb_axi_bridge__DOT__exp_b
                   [(0x000000ffU & vlSelfRef.tb_axi_bridge__DOT__b_tail)][0U]);
            vlSelfRef.tb_axi_bridge__DOT__exp_b[(0x000000ffU 
                                                 & vlSelfRef.tb_axi_bridge__DOT__b_tail)][1U] = 0U;
            vlSelfRef.tb_axi_bridge__DOT__exp_b[(0x000000ffU 
                                                 & vlSelfRef.tb_axi_bridge__DOT__b_tail)][2U] = 0U;
            vlSelfRef.tb_axi_bridge__DOT__exp_b[(0x000000ffU 
                                                 & vlSelfRef.tb_axi_bridge__DOT__b_tail)][3U] = 0U;
            vlSelfRef.tb_axi_bridge__DOT__exp_b[(0x000000ffU 
                                                 & vlSelfRef.tb_axi_bridge__DOT__b_tail)][4U] = 0U;
            vlSelfRef.tb_axi_bridge__DOT__exp_b[(0x000000ffU 
                                                 & vlSelfRef.tb_axi_bridge__DOT__b_tail)][5U] = 0U;
            vlSelfRef.tb_axi_bridge__DOT__exp_b[(0x000000ffU 
                                                 & vlSelfRef.tb_axi_bridge__DOT__b_tail)][6U] = 0U;
            vlSelfRef.tb_axi_bridge__DOT__exp_b[(0x000000ffU 
                                                 & vlSelfRef.tb_axi_bridge__DOT__b_tail)][7U] = 0U;
            vlSelfRef.tb_axi_bridge__DOT__exp_b[(0x000000ffU 
                                                 & vlSelfRef.tb_axi_bridge__DOT__b_tail)][8U] = 0U;
            vlSelfRef.tb_axi_bridge__DOT__exp_b[(0x000000ffU 
                                                 & vlSelfRef.tb_axi_bridge__DOT__b_tail)][9U] = 0U;
            vlSelfRef.tb_axi_bridge__DOT__exp_b[(0x000000ffU 
                                                 & vlSelfRef.tb_axi_bridge__DOT__b_tail)][10U] = 0U;
            vlSelfRef.tb_axi_bridge__DOT__exp_b[(0x000000ffU 
                                                 & vlSelfRef.tb_axi_bridge__DOT__b_tail)][11U] = 0U;
            vlSelfRef.tb_axi_bridge__DOT__exp_b[(0x000000ffU 
                                                 & vlSelfRef.tb_axi_bridge__DOT__b_tail)][12U] = 0U;
            vlSelfRef.tb_axi_bridge__DOT__exp_b[(0x000000ffU 
                                                 & vlSelfRef.tb_axi_bridge__DOT__b_tail)][13U] = 0U;
            vlSelfRef.tb_axi_bridge__DOT__exp_b[(0x000000ffU 
                                                 & vlSelfRef.tb_axi_bridge__DOT__b_tail)][14U] = 0U;
            vlSelfRef.tb_axi_bridge__DOT__exp_b[(0x000000ffU 
                                                 & vlSelfRef.tb_axi_bridge__DOT__b_tail)][15U] = 0U;
            vlSelfRef.tb_axi_bridge__DOT__b_tail = 
                ((IData)(1U) + vlSelfRef.tb_axi_bridge__DOT__b_tail);
        }
        __Vtask_tb_axi_bridge__DOT__chk__check_id_48 = 0x0000000eU;
        if (__Vtask_tb_axi_bridge__DOT__chk__antecedent_49) {
            if (VL_LIKELY(((0x23U >= (0x0000003fU & __Vtask_tb_axi_bridge__DOT__chk__check_id_48))))) {
                vlSelfRef.tb_axi_bridge__DOT__assertion_hits[(0x0000003fU 
                                                              & __Vtask_tb_axi_bridge__DOT__chk__check_id_48)] 
                    = ((IData)(1U) + ((0x23U >= (0x0000003fU 
                                                 & __Vtask_tb_axi_bridge__DOT__chk__check_id_48))
                                       ? vlSelfRef.tb_axi_bridge__DOT__assertion_hits
                                      [(0x0000003fU 
                                        & __Vtask_tb_axi_bridge__DOT__chk__check_id_48)]
                                       : 0U));
            }
            if (VL_UNLIKELY(((1U & (~ (IData)(__Vtask_tb_axi_bridge__DOT__chk__consequent_50)))))) {
                if (VL_LIKELY(((0x23U >= (0x0000003fU 
                                          & __Vtask_tb_axi_bridge__DOT__chk__check_id_48))))) {
                    vlSelfRef.tb_axi_bridge__DOT__assertion_fails[(0x0000003fU 
                                                                   & __Vtask_tb_axi_bridge__DOT__chk__check_id_48)] 
                        = ((IData)(1U) + ((0x23U >= 
                                           (0x0000003fU 
                                            & __Vtask_tb_axi_bridge__DOT__chk__check_id_48))
                                           ? vlSelfRef.tb_axi_bridge__DOT__assertion_fails
                                          [(0x0000003fU 
                                            & __Vtask_tb_axi_bridge__DOT__chk__check_id_48)]
                                           : 0U));
                }
                VL_WRITEF_NX("ASSERT FAIL AXI-SVA-%02d time=%0t\n",3, 'T',-9
                             , '~',32,__Vtask_tb_axi_bridge__DOT__chk__check_id_48
                             , '#',64,VL_TIME_UNITED_Q(1000));
            }
        }
        __Vtask_tb_axi_bridge__DOT__chk__consequent_53 
            = (0U == (((((((((((((((((((IData)(vlSelfRef.tb_axi_bridge__DOT__i_axi_bid) 
                                       << 2U) | (IData)(vlSelfRef.tb_axi_bridge__DOT__i_axi_bresp)) 
                                     ^ vlSelfRef.tb_axi_bridge__DOT__prev_src_b[0U]) 
                                    | vlSelfRef.tb_axi_bridge__DOT__prev_src_b[1U]) 
                                   | vlSelfRef.tb_axi_bridge__DOT__prev_src_b[2U]) 
                                  | vlSelfRef.tb_axi_bridge__DOT__prev_src_b[3U]) 
                                 | vlSelfRef.tb_axi_bridge__DOT__prev_src_b[4U]) 
                                | vlSelfRef.tb_axi_bridge__DOT__prev_src_b[5U]) 
                               | vlSelfRef.tb_axi_bridge__DOT__prev_src_b[6U]) 
                              | vlSelfRef.tb_axi_bridge__DOT__prev_src_b[7U]) 
                             | vlSelfRef.tb_axi_bridge__DOT__prev_src_b[8U]) 
                            | vlSelfRef.tb_axi_bridge__DOT__prev_src_b[9U]) 
                           | vlSelfRef.tb_axi_bridge__DOT__prev_src_b[10U]) 
                          | vlSelfRef.tb_axi_bridge__DOT__prev_src_b[11U]) 
                         | vlSelfRef.tb_axi_bridge__DOT__prev_src_b[12U]) 
                        | vlSelfRef.tb_axi_bridge__DOT__prev_src_b[13U]) 
                       | vlSelfRef.tb_axi_bridge__DOT__prev_src_b[14U]) 
                      | vlSelfRef.tb_axi_bridge__DOT__prev_src_b[15U]));
        __Vtask_tb_axi_bridge__DOT__chk__antecedent_52 
            = vlSelfRef.tb_axi_bridge__DOT__src_b_stall;
        __Vtask_tb_axi_bridge__DOT__chk__check_id_51 = 0x0000000fU;
        if (__Vtask_tb_axi_bridge__DOT__chk__antecedent_52) {
            if (VL_LIKELY(((0x23U >= (0x0000003fU & __Vtask_tb_axi_bridge__DOT__chk__check_id_51))))) {
                vlSelfRef.tb_axi_bridge__DOT__assertion_hits[(0x0000003fU 
                                                              & __Vtask_tb_axi_bridge__DOT__chk__check_id_51)] 
                    = ((IData)(1U) + ((0x23U >= (0x0000003fU 
                                                 & __Vtask_tb_axi_bridge__DOT__chk__check_id_51))
                                       ? vlSelfRef.tb_axi_bridge__DOT__assertion_hits
                                      [(0x0000003fU 
                                        & __Vtask_tb_axi_bridge__DOT__chk__check_id_51)]
                                       : 0U));
            }
            if (VL_UNLIKELY(((1U & (~ (IData)(__Vtask_tb_axi_bridge__DOT__chk__consequent_53)))))) {
                if (VL_LIKELY(((0x23U >= (0x0000003fU 
                                          & __Vtask_tb_axi_bridge__DOT__chk__check_id_51))))) {
                    vlSelfRef.tb_axi_bridge__DOT__assertion_fails[(0x0000003fU 
                                                                   & __Vtask_tb_axi_bridge__DOT__chk__check_id_51)] 
                        = ((IData)(1U) + ((0x23U >= 
                                           (0x0000003fU 
                                            & __Vtask_tb_axi_bridge__DOT__chk__check_id_51))
                                           ? vlSelfRef.tb_axi_bridge__DOT__assertion_fails
                                          [(0x0000003fU 
                                            & __Vtask_tb_axi_bridge__DOT__chk__check_id_51)]
                                           : 0U));
                }
                VL_WRITEF_NX("ASSERT FAIL AXI-SVA-%02d time=%0t\n",3, 'T',-9
                             , '~',32,__Vtask_tb_axi_bridge__DOT__chk__check_id_51
                             , '#',64,VL_TIME_UNITED_Q(1000));
            }
        }
        __Vtask_tb_axi_bridge__DOT__chk__consequent_56 = 1U;
        __Vtask_tb_axi_bridge__DOT__chk__antecedent_55 
            = vlSelfRef.tb_axi_bridge__DOT__i_axi_bvalid;
        __Vtask_tb_axi_bridge__DOT__chk__check_id_54 = 0x00000013U;
        if (__Vtask_tb_axi_bridge__DOT__chk__antecedent_55) {
            if (VL_LIKELY(((0x23U >= (0x0000003fU & __Vtask_tb_axi_bridge__DOT__chk__check_id_54))))) {
                vlSelfRef.tb_axi_bridge__DOT__assertion_hits[(0x0000003fU 
                                                              & __Vtask_tb_axi_bridge__DOT__chk__check_id_54)] 
                    = ((IData)(1U) + ((0x23U >= (0x0000003fU 
                                                 & __Vtask_tb_axi_bridge__DOT__chk__check_id_54))
                                       ? vlSelfRef.tb_axi_bridge__DOT__assertion_hits
                                      [(0x0000003fU 
                                        & __Vtask_tb_axi_bridge__DOT__chk__check_id_54)]
                                       : 0U));
            }
            if (VL_UNLIKELY(((1U & (~ (IData)(__Vtask_tb_axi_bridge__DOT__chk__consequent_56)))))) {
                if (VL_LIKELY(((0x23U >= (0x0000003fU 
                                          & __Vtask_tb_axi_bridge__DOT__chk__check_id_54))))) {
                    vlSelfRef.tb_axi_bridge__DOT__assertion_fails[(0x0000003fU 
                                                                   & __Vtask_tb_axi_bridge__DOT__chk__check_id_54)] 
                        = ((IData)(1U) + ((0x23U >= 
                                           (0x0000003fU 
                                            & __Vtask_tb_axi_bridge__DOT__chk__check_id_54))
                                           ? vlSelfRef.tb_axi_bridge__DOT__assertion_fails
                                          [(0x0000003fU 
                                            & __Vtask_tb_axi_bridge__DOT__chk__check_id_54)]
                                           : 0U));
                }
                VL_WRITEF_NX("ASSERT FAIL AXI-SVA-%02d time=%0t\n",3, 'T',-9
                             , '~',32,__Vtask_tb_axi_bridge__DOT__chk__check_id_54
                             , '#',64,VL_TIME_UNITED_Q(1000));
            }
        }
        vlSelfRef.tb_axi_bridge__DOT__src_b_stall = 
            ((IData)(vlSelfRef.tb_axi_bridge__DOT__i_axi_bvalid) 
             & (~ (IData)(vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_b__DOT__o_axi_bready)));
        vlSelfRef.tb_axi_bridge__DOT__prev_src_b[0U] 
            = (((IData)(vlSelfRef.tb_axi_bridge__DOT__i_axi_bid) 
                << 2U) | (IData)(vlSelfRef.tb_axi_bridge__DOT__i_axi_bresp));
        vlSelfRef.tb_axi_bridge__DOT__prev_src_b[1U] = 0U;
        vlSelfRef.tb_axi_bridge__DOT__prev_src_b[2U] = 0U;
        vlSelfRef.tb_axi_bridge__DOT__prev_src_b[3U] = 0U;
        vlSelfRef.tb_axi_bridge__DOT__prev_src_b[4U] = 0U;
        vlSelfRef.tb_axi_bridge__DOT__prev_src_b[5U] = 0U;
        vlSelfRef.tb_axi_bridge__DOT__prev_src_b[6U] = 0U;
        vlSelfRef.tb_axi_bridge__DOT__prev_src_b[7U] = 0U;
        vlSelfRef.tb_axi_bridge__DOT__prev_src_b[8U] = 0U;
        vlSelfRef.tb_axi_bridge__DOT__prev_src_b[9U] = 0U;
        vlSelfRef.tb_axi_bridge__DOT__prev_src_b[10U] = 0U;
        vlSelfRef.tb_axi_bridge__DOT__prev_src_b[11U] = 0U;
        vlSelfRef.tb_axi_bridge__DOT__prev_src_b[12U] = 0U;
        vlSelfRef.tb_axi_bridge__DOT__prev_src_b[13U] = 0U;
        vlSelfRef.tb_axi_bridge__DOT__prev_src_b[14U] = 0U;
        vlSelfRef.tb_axi_bridge__DOT__prev_src_b[15U] = 0U;
        __Vtask_tb_axi_bridge__DOT__chk__consequent_98 
            = vlSelfRef.tb_axi_bridge__DOT__i_axi_rvalid;
        __Vtask_tb_axi_bridge__DOT__chk__antecedent_97 
            = vlSelfRef.tb_axi_bridge__DOT__src_r_stall;
        if (((IData)(vlSelfRef.tb_axi_bridge__DOT__i_axi_rvalid) 
             & (IData)(vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_r__DOT__o_axi_rready))) {
            vlSelfRef.tb_axi_bridge__DOT__exp_r[(0x000000ffU 
                                                 & vlSelfRef.tb_axi_bridge__DOT__r_tail)][0U] 
                = ((0xfffffff8U & vlSelfRef.tb_axi_bridge__DOT__exp_r
                    [(0x000000ffU & vlSelfRef.tb_axi_bridge__DOT__r_tail)][0U]) 
                   | (((IData)(vlSelfRef.tb_axi_bridge__DOT__i_axi_rresp) 
                       << 1U) | (IData)(vlSelfRef.tb_axi_bridge__DOT__i_axi_rlast)));
            vlSelfRef.tb_axi_bridge__DOT__exp_r[(0x000000ffU 
                                                 & vlSelfRef.tb_axi_bridge__DOT__r_tail)][0U] 
                = ((7U & vlSelfRef.tb_axi_bridge__DOT__exp_r
                    [(0x000000ffU & vlSelfRef.tb_axi_bridge__DOT__r_tail)][0U]) 
                   | (vlSelfRef.tb_axi_bridge__DOT__i_axi_rdata 
                      << 3U));
            vlSelfRef.tb_axi_bridge__DOT__exp_r[(0x000000ffU 
                                                 & vlSelfRef.tb_axi_bridge__DOT__r_tail)][1U] 
                = ((0xfffffff8U & vlSelfRef.tb_axi_bridge__DOT__exp_r
                    [(0x000000ffU & vlSelfRef.tb_axi_bridge__DOT__r_tail)][1U]) 
                   | (vlSelfRef.tb_axi_bridge__DOT__i_axi_rdata 
                      >> 0x0000001dU));
            vlSelfRef.tb_axi_bridge__DOT__exp_r[(0x000000ffU 
                                                 & vlSelfRef.tb_axi_bridge__DOT__r_tail)][1U] 
                = ((0xffffff87U & vlSelfRef.tb_axi_bridge__DOT__exp_r
                    [(0x000000ffU & vlSelfRef.tb_axi_bridge__DOT__r_tail)][1U]) 
                   | ((IData)(vlSelfRef.tb_axi_bridge__DOT__i_axi_rid) 
                      << 3U));
            vlSelfRef.tb_axi_bridge__DOT__exp_r[(0x000000ffU 
                                                 & vlSelfRef.tb_axi_bridge__DOT__r_tail)][1U] 
                = (0x0000007fU & vlSelfRef.tb_axi_bridge__DOT__exp_r
                   [(0x000000ffU & vlSelfRef.tb_axi_bridge__DOT__r_tail)][1U]);
            vlSelfRef.tb_axi_bridge__DOT__exp_r[(0x000000ffU 
                                                 & vlSelfRef.tb_axi_bridge__DOT__r_tail)][2U] = 0U;
            vlSelfRef.tb_axi_bridge__DOT__exp_r[(0x000000ffU 
                                                 & vlSelfRef.tb_axi_bridge__DOT__r_tail)][3U] = 0U;
            vlSelfRef.tb_axi_bridge__DOT__exp_r[(0x000000ffU 
                                                 & vlSelfRef.tb_axi_bridge__DOT__r_tail)][4U] = 0U;
            vlSelfRef.tb_axi_bridge__DOT__exp_r[(0x000000ffU 
                                                 & vlSelfRef.tb_axi_bridge__DOT__r_tail)][5U] = 0U;
            vlSelfRef.tb_axi_bridge__DOT__exp_r[(0x000000ffU 
                                                 & vlSelfRef.tb_axi_bridge__DOT__r_tail)][6U] = 0U;
            vlSelfRef.tb_axi_bridge__DOT__exp_r[(0x000000ffU 
                                                 & vlSelfRef.tb_axi_bridge__DOT__r_tail)][7U] = 0U;
            vlSelfRef.tb_axi_bridge__DOT__exp_r[(0x000000ffU 
                                                 & vlSelfRef.tb_axi_bridge__DOT__r_tail)][8U] = 0U;
            vlSelfRef.tb_axi_bridge__DOT__exp_r[(0x000000ffU 
                                                 & vlSelfRef.tb_axi_bridge__DOT__r_tail)][9U] = 0U;
            vlSelfRef.tb_axi_bridge__DOT__exp_r[(0x000000ffU 
                                                 & vlSelfRef.tb_axi_bridge__DOT__r_tail)][10U] = 0U;
            vlSelfRef.tb_axi_bridge__DOT__exp_r[(0x000000ffU 
                                                 & vlSelfRef.tb_axi_bridge__DOT__r_tail)][11U] = 0U;
            vlSelfRef.tb_axi_bridge__DOT__exp_r[(0x000000ffU 
                                                 & vlSelfRef.tb_axi_bridge__DOT__r_tail)][12U] = 0U;
            vlSelfRef.tb_axi_bridge__DOT__exp_r[(0x000000ffU 
                                                 & vlSelfRef.tb_axi_bridge__DOT__r_tail)][13U] = 0U;
            vlSelfRef.tb_axi_bridge__DOT__exp_r[(0x000000ffU 
                                                 & vlSelfRef.tb_axi_bridge__DOT__r_tail)][14U] = 0U;
            vlSelfRef.tb_axi_bridge__DOT__exp_r[(0x000000ffU 
                                                 & vlSelfRef.tb_axi_bridge__DOT__r_tail)][15U] = 0U;
            vlSelfRef.tb_axi_bridge__DOT__r_tail = 
                ((IData)(1U) + vlSelfRef.tb_axi_bridge__DOT__r_tail);
        }
        __Vtask_tb_axi_bridge__DOT__chk__check_id_96 = 0x0000001cU;
        if (__Vtask_tb_axi_bridge__DOT__chk__antecedent_97) {
            if (VL_LIKELY(((0x23U >= (0x0000003fU & __Vtask_tb_axi_bridge__DOT__chk__check_id_96))))) {
                vlSelfRef.tb_axi_bridge__DOT__assertion_hits[(0x0000003fU 
                                                              & __Vtask_tb_axi_bridge__DOT__chk__check_id_96)] 
                    = ((IData)(1U) + ((0x23U >= (0x0000003fU 
                                                 & __Vtask_tb_axi_bridge__DOT__chk__check_id_96))
                                       ? vlSelfRef.tb_axi_bridge__DOT__assertion_hits
                                      [(0x0000003fU 
                                        & __Vtask_tb_axi_bridge__DOT__chk__check_id_96)]
                                       : 0U));
            }
            if (VL_UNLIKELY(((1U & (~ (IData)(__Vtask_tb_axi_bridge__DOT__chk__consequent_98)))))) {
                if (VL_LIKELY(((0x23U >= (0x0000003fU 
                                          & __Vtask_tb_axi_bridge__DOT__chk__check_id_96))))) {
                    vlSelfRef.tb_axi_bridge__DOT__assertion_fails[(0x0000003fU 
                                                                   & __Vtask_tb_axi_bridge__DOT__chk__check_id_96)] 
                        = ((IData)(1U) + ((0x23U >= 
                                           (0x0000003fU 
                                            & __Vtask_tb_axi_bridge__DOT__chk__check_id_96))
                                           ? vlSelfRef.tb_axi_bridge__DOT__assertion_fails
                                          [(0x0000003fU 
                                            & __Vtask_tb_axi_bridge__DOT__chk__check_id_96)]
                                           : 0U));
                }
                VL_WRITEF_NX("ASSERT FAIL AXI-SVA-%02d time=%0t\n",3, 'T',-9
                             , '~',32,__Vtask_tb_axi_bridge__DOT__chk__check_id_96
                             , '#',64,VL_TIME_UNITED_Q(1000));
            }
        }
        __Vtask_tb_axi_bridge__DOT__chk__consequent_101 
            = (0U == (((((((((((((((((IData)((((QData)((IData)(vlSelfRef.tb_axi_bridge__DOT__i_axi_rid)) 
                                               << 0x00000023U) 
                                              | (((QData)((IData)(vlSelfRef.tb_axi_bridge__DOT__i_axi_rdata)) 
                                                  << 3U) 
                                                 | (QData)((IData)(
                                                                   (((IData)(vlSelfRef.tb_axi_bridge__DOT__i_axi_rresp) 
                                                                     << 1U) 
                                                                    | (IData)(vlSelfRef.tb_axi_bridge__DOT__i_axi_rlast))))))) 
                                     ^ vlSelfRef.tb_axi_bridge__DOT__prev_src_r[0U]) 
                                    | ((IData)(((((QData)((IData)(vlSelfRef.tb_axi_bridge__DOT__i_axi_rid)) 
                                                  << 0x00000023U) 
                                                 | (((QData)((IData)(vlSelfRef.tb_axi_bridge__DOT__i_axi_rdata)) 
                                                     << 3U) 
                                                    | (QData)((IData)(
                                                                      (((IData)(vlSelfRef.tb_axi_bridge__DOT__i_axi_rresp) 
                                                                        << 1U) 
                                                                       | (IData)(vlSelfRef.tb_axi_bridge__DOT__i_axi_rlast)))))) 
                                                >> 0x00000020U)) 
                                       ^ vlSelfRef.tb_axi_bridge__DOT__prev_src_r[1U])) 
                                   | vlSelfRef.tb_axi_bridge__DOT__prev_src_r[2U]) 
                                  | vlSelfRef.tb_axi_bridge__DOT__prev_src_r[3U]) 
                                 | vlSelfRef.tb_axi_bridge__DOT__prev_src_r[4U]) 
                                | vlSelfRef.tb_axi_bridge__DOT__prev_src_r[5U]) 
                               | vlSelfRef.tb_axi_bridge__DOT__prev_src_r[6U]) 
                              | vlSelfRef.tb_axi_bridge__DOT__prev_src_r[7U]) 
                             | vlSelfRef.tb_axi_bridge__DOT__prev_src_r[8U]) 
                            | vlSelfRef.tb_axi_bridge__DOT__prev_src_r[9U]) 
                           | vlSelfRef.tb_axi_bridge__DOT__prev_src_r[10U]) 
                          | vlSelfRef.tb_axi_bridge__DOT__prev_src_r[11U]) 
                         | vlSelfRef.tb_axi_bridge__DOT__prev_src_r[12U]) 
                        | vlSelfRef.tb_axi_bridge__DOT__prev_src_r[13U]) 
                       | vlSelfRef.tb_axi_bridge__DOT__prev_src_r[14U]) 
                      | vlSelfRef.tb_axi_bridge__DOT__prev_src_r[15U]));
        __Vtask_tb_axi_bridge__DOT__chk__antecedent_100 
            = vlSelfRef.tb_axi_bridge__DOT__src_r_stall;
        __Vtask_tb_axi_bridge__DOT__chk__check_id_99 = 0x0000001dU;
        if (__Vtask_tb_axi_bridge__DOT__chk__antecedent_100) {
            if (VL_LIKELY(((0x23U >= (0x0000003fU & __Vtask_tb_axi_bridge__DOT__chk__check_id_99))))) {
                vlSelfRef.tb_axi_bridge__DOT__assertion_hits[(0x0000003fU 
                                                              & __Vtask_tb_axi_bridge__DOT__chk__check_id_99)] 
                    = ((IData)(1U) + ((0x23U >= (0x0000003fU 
                                                 & __Vtask_tb_axi_bridge__DOT__chk__check_id_99))
                                       ? vlSelfRef.tb_axi_bridge__DOT__assertion_hits
                                      [(0x0000003fU 
                                        & __Vtask_tb_axi_bridge__DOT__chk__check_id_99)]
                                       : 0U));
            }
            if (VL_UNLIKELY(((1U & (~ (IData)(__Vtask_tb_axi_bridge__DOT__chk__consequent_101)))))) {
                if (VL_LIKELY(((0x23U >= (0x0000003fU 
                                          & __Vtask_tb_axi_bridge__DOT__chk__check_id_99))))) {
                    vlSelfRef.tb_axi_bridge__DOT__assertion_fails[(0x0000003fU 
                                                                   & __Vtask_tb_axi_bridge__DOT__chk__check_id_99)] 
                        = ((IData)(1U) + ((0x23U >= 
                                           (0x0000003fU 
                                            & __Vtask_tb_axi_bridge__DOT__chk__check_id_99))
                                           ? vlSelfRef.tb_axi_bridge__DOT__assertion_fails
                                          [(0x0000003fU 
                                            & __Vtask_tb_axi_bridge__DOT__chk__check_id_99)]
                                           : 0U));
                }
                VL_WRITEF_NX("ASSERT FAIL AXI-SVA-%02d time=%0t\n",3, 'T',-9
                             , '~',32,__Vtask_tb_axi_bridge__DOT__chk__check_id_99
                             , '#',64,VL_TIME_UNITED_Q(1000));
            }
        }
        __Vtask_tb_axi_bridge__DOT__chk__consequent_104 = 1U;
        __Vtask_tb_axi_bridge__DOT__chk__antecedent_103 
            = vlSelfRef.tb_axi_bridge__DOT__i_axi_rvalid;
        __Vtask_tb_axi_bridge__DOT__chk__check_id_102 = 0x00000021U;
        if (__Vtask_tb_axi_bridge__DOT__chk__antecedent_103) {
            if (VL_LIKELY(((0x23U >= (0x0000003fU & __Vtask_tb_axi_bridge__DOT__chk__check_id_102))))) {
                vlSelfRef.tb_axi_bridge__DOT__assertion_hits[(0x0000003fU 
                                                              & __Vtask_tb_axi_bridge__DOT__chk__check_id_102)] 
                    = ((IData)(1U) + ((0x23U >= (0x0000003fU 
                                                 & __Vtask_tb_axi_bridge__DOT__chk__check_id_102))
                                       ? vlSelfRef.tb_axi_bridge__DOT__assertion_hits
                                      [(0x0000003fU 
                                        & __Vtask_tb_axi_bridge__DOT__chk__check_id_102)]
                                       : 0U));
            }
            if (VL_UNLIKELY(((1U & (~ (IData)(__Vtask_tb_axi_bridge__DOT__chk__consequent_104)))))) {
                if (VL_LIKELY(((0x23U >= (0x0000003fU 
                                          & __Vtask_tb_axi_bridge__DOT__chk__check_id_102))))) {
                    vlSelfRef.tb_axi_bridge__DOT__assertion_fails[(0x0000003fU 
                                                                   & __Vtask_tb_axi_bridge__DOT__chk__check_id_102)] 
                        = ((IData)(1U) + ((0x23U >= 
                                           (0x0000003fU 
                                            & __Vtask_tb_axi_bridge__DOT__chk__check_id_102))
                                           ? vlSelfRef.tb_axi_bridge__DOT__assertion_fails
                                          [(0x0000003fU 
                                            & __Vtask_tb_axi_bridge__DOT__chk__check_id_102)]
                                           : 0U));
                }
                VL_WRITEF_NX("ASSERT FAIL AXI-SVA-%02d time=%0t\n",3, 'T',-9
                             , '~',32,__Vtask_tb_axi_bridge__DOT__chk__check_id_102
                             , '#',64,VL_TIME_UNITED_Q(1000));
            }
        }
        vlSelfRef.tb_axi_bridge__DOT__src_r_stall = 
            ((IData)(vlSelfRef.tb_axi_bridge__DOT__i_axi_rvalid) 
             & (~ (IData)(vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_r__DOT__o_axi_rready)));
        vlSelfRef.tb_axi_bridge__DOT__prev_src_r[0U] 
            = (IData)((((QData)((IData)(vlSelfRef.tb_axi_bridge__DOT__i_axi_rid)) 
                        << 0x00000023U) | (((QData)((IData)(vlSelfRef.tb_axi_bridge__DOT__i_axi_rdata)) 
                                            << 3U) 
                                           | (QData)((IData)(
                                                             (((IData)(vlSelfRef.tb_axi_bridge__DOT__i_axi_rresp) 
                                                               << 1U) 
                                                              | (IData)(vlSelfRef.tb_axi_bridge__DOT__i_axi_rlast)))))));
        vlSelfRef.tb_axi_bridge__DOT__prev_src_r[1U] 
            = ((0xffffff80U & vlSelfRef.tb_axi_bridge__DOT__prev_src_r[1U]) 
               | (IData)(((((QData)((IData)(vlSelfRef.tb_axi_bridge__DOT__i_axi_rid)) 
                            << 0x00000023U) | (((QData)((IData)(vlSelfRef.tb_axi_bridge__DOT__i_axi_rdata)) 
                                                << 3U) 
                                               | (QData)((IData)(
                                                                 (((IData)(vlSelfRef.tb_axi_bridge__DOT__i_axi_rresp) 
                                                                   << 1U) 
                                                                  | (IData)(vlSelfRef.tb_axi_bridge__DOT__i_axi_rlast)))))) 
                          >> 0x00000020U)));
        vlSelfRef.tb_axi_bridge__DOT__prev_src_r[1U] 
            = (0x0000007fU & vlSelfRef.tb_axi_bridge__DOT__prev_src_r[1U]);
        vlSelfRef.tb_axi_bridge__DOT__prev_src_r[2U] = 0U;
        vlSelfRef.tb_axi_bridge__DOT__prev_src_r[3U] = 0U;
        vlSelfRef.tb_axi_bridge__DOT__prev_src_r[4U] = 0U;
        vlSelfRef.tb_axi_bridge__DOT__prev_src_r[5U] = 0U;
        vlSelfRef.tb_axi_bridge__DOT__prev_src_r[6U] = 0U;
        vlSelfRef.tb_axi_bridge__DOT__prev_src_r[7U] = 0U;
        vlSelfRef.tb_axi_bridge__DOT__prev_src_r[8U] = 0U;
        vlSelfRef.tb_axi_bridge__DOT__prev_src_r[9U] = 0U;
        vlSelfRef.tb_axi_bridge__DOT__prev_src_r[10U] = 0U;
        vlSelfRef.tb_axi_bridge__DOT__prev_src_r[11U] = 0U;
        vlSelfRef.tb_axi_bridge__DOT__prev_src_r[12U] = 0U;
        vlSelfRef.tb_axi_bridge__DOT__prev_src_r[13U] = 0U;
        vlSelfRef.tb_axi_bridge__DOT__prev_src_r[14U] = 0U;
        vlSelfRef.tb_axi_bridge__DOT__prev_src_r[15U] = 0U;
        __Vtask_tb_axi_bridge__DOT__chk__consequent_11 
            = vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_aw__DOT__o_axi_awvalid;
        __Vtask_tb_axi_bridge__DOT__chk__antecedent_10 
            = vlSelfRef.tb_axi_bridge__DOT__dst_aw_stall;
        __Vtask_tb_axi_bridge__DOT__chk__check_id_9 = 2U;
        if (__Vtask_tb_axi_bridge__DOT__chk__antecedent_10) {
            if (VL_LIKELY(((0x23U >= (0x0000003fU & __Vtask_tb_axi_bridge__DOT__chk__check_id_9))))) {
                vlSelfRef.tb_axi_bridge__DOT__assertion_hits[(0x0000003fU 
                                                              & __Vtask_tb_axi_bridge__DOT__chk__check_id_9)] 
                    = ((IData)(1U) + ((0x23U >= (0x0000003fU 
                                                 & __Vtask_tb_axi_bridge__DOT__chk__check_id_9))
                                       ? vlSelfRef.tb_axi_bridge__DOT__assertion_hits
                                      [(0x0000003fU 
                                        & __Vtask_tb_axi_bridge__DOT__chk__check_id_9)]
                                       : 0U));
            }
            if (VL_UNLIKELY(((1U & (~ (IData)(__Vtask_tb_axi_bridge__DOT__chk__consequent_11)))))) {
                if (VL_LIKELY(((0x23U >= (0x0000003fU 
                                          & __Vtask_tb_axi_bridge__DOT__chk__check_id_9))))) {
                    vlSelfRef.tb_axi_bridge__DOT__assertion_fails[(0x0000003fU 
                                                                   & __Vtask_tb_axi_bridge__DOT__chk__check_id_9)] 
                        = ((IData)(1U) + ((0x23U >= 
                                           (0x0000003fU 
                                            & __Vtask_tb_axi_bridge__DOT__chk__check_id_9))
                                           ? vlSelfRef.tb_axi_bridge__DOT__assertion_fails
                                          [(0x0000003fU 
                                            & __Vtask_tb_axi_bridge__DOT__chk__check_id_9)]
                                           : 0U));
                }
                VL_WRITEF_NX("ASSERT FAIL AXI-SVA-%02d time=%0t\n",3, 'T',-9
                             , '~',32,__Vtask_tb_axi_bridge__DOT__chk__check_id_9
                             , '#',64,VL_TIME_UNITED_Q(1000));
            }
        }
        __Vtemp_17[0U] = (IData)((((QData)((IData)(
                                                   ((vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_aw__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_mem__DOT__gen_array__DOT__reg_rd_data[1U] 
                                                     << 0x0000001cU) 
                                                    | (vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_aw__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_mem__DOT__gen_array__DOT__reg_rd_data[0U] 
                                                       >> 4U)))) 
                                   << 0x0000001dU) 
                                  | (QData)((IData)(
                                                    ((((0x00003fc0U 
                                                        & (vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_aw__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_mem__DOT__gen_array__DOT__reg_rd_data[1U] 
                                                           << 2U)) 
                                                       | ((0x00000038U 
                                                           & (vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_aw__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_mem__DOT__gen_array__DOT__reg_rd_data[1U] 
                                                              >> 9U)) 
                                                          | ((6U 
                                                              & (vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_aw__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_mem__DOT__gen_array__DOT__reg_rd_data[1U] 
                                                                 >> 0x0000000eU)) 
                                                             | (1U 
                                                                & (vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_aw__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_mem__DOT__gen_array__DOT__reg_rd_data[1U] 
                                                                   >> 0x00000011U))))) 
                                                      << 0x0000000fU) 
                                                     | ((((0x00000078U 
                                                           & (vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_aw__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_mem__DOT__gen_array__DOT__reg_rd_data[1U] 
                                                              >> 0x0000000fU)) 
                                                          | (7U 
                                                             & (vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_aw__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_mem__DOT__gen_array__DOT__reg_rd_data[1U] 
                                                                >> 0x00000016U))) 
                                                         << 8U) 
                                                        | ((0x000000f0U 
                                                            & (vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_aw__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_mem__DOT__gen_array__DOT__reg_rd_data[1U] 
                                                               >> 0x00000015U)) 
                                                           | (0x0000000fU 
                                                              & ((vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_aw__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_mem__DOT__gen_array__DOT__reg_rd_data[2U] 
                                                                  << 3U) 
                                                                 | (vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_aw__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_mem__DOT__gen_array__DOT__reg_rd_data[1U] 
                                                                    >> 0x0000001dU))))))))));
        __Vtemp_17[1U] = ((vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_aw__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_mem__DOT__gen_array__DOT__reg_rd_data[0U] 
                           << 0x0000001dU) | (IData)(
                                                     ((((QData)((IData)(
                                                                        ((vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_aw__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_mem__DOT__gen_array__DOT__reg_rd_data[1U] 
                                                                          << 0x0000001cU) 
                                                                         | (vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_aw__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_mem__DOT__gen_array__DOT__reg_rd_data[0U] 
                                                                            >> 4U)))) 
                                                        << 0x0000001dU) 
                                                       | (QData)((IData)(
                                                                         ((((0x00003fc0U 
                                                                             & (vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_aw__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_mem__DOT__gen_array__DOT__reg_rd_data[1U] 
                                                                                << 2U)) 
                                                                            | ((0x00000038U 
                                                                                & (vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_aw__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_mem__DOT__gen_array__DOT__reg_rd_data[1U] 
                                                                                >> 9U)) 
                                                                               | ((6U 
                                                                                & (vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_aw__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_mem__DOT__gen_array__DOT__reg_rd_data[1U] 
                                                                                >> 0x0000000eU)) 
                                                                                | (1U 
                                                                                & (vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_aw__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_mem__DOT__gen_array__DOT__reg_rd_data[1U] 
                                                                                >> 0x00000011U))))) 
                                                                           << 0x0000000fU) 
                                                                          | ((((0x00000078U 
                                                                                & (vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_aw__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_mem__DOT__gen_array__DOT__reg_rd_data[1U] 
                                                                                >> 0x0000000fU)) 
                                                                               | (7U 
                                                                                & (vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_aw__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_mem__DOT__gen_array__DOT__reg_rd_data[1U] 
                                                                                >> 0x00000016U))) 
                                                                              << 8U) 
                                                                             | ((0x000000f0U 
                                                                                & (vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_aw__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_mem__DOT__gen_array__DOT__reg_rd_data[1U] 
                                                                                >> 0x00000015U)) 
                                                                                | (0x0000000fU 
                                                                                & ((vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_aw__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_mem__DOT__gen_array__DOT__reg_rd_data[2U] 
                                                                                << 3U) 
                                                                                | (vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_aw__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_mem__DOT__gen_array__DOT__reg_rd_data[1U] 
                                                                                >> 0x0000001dU))))))))) 
                                                      >> 0x00000020U)));
        __Vtask_tb_axi_bridge__DOT__chk__consequent_14 
            = (0U == ((((((((((((((((__Vtemp_17[0U] 
                                     ^ vlSelfRef.tb_axi_bridge__DOT__prev_dst_aw[0U]) 
                                    | (__Vtemp_17[1U] 
                                       ^ vlSelfRef.tb_axi_bridge__DOT__prev_dst_aw[1U])) 
                                   | ((1U & (vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_aw__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_mem__DOT__gen_array__DOT__reg_rd_data[0U] 
                                             >> 3U)) 
                                      ^ vlSelfRef.tb_axi_bridge__DOT__prev_dst_aw[2U])) 
                                  | vlSelfRef.tb_axi_bridge__DOT__prev_dst_aw[3U]) 
                                 | vlSelfRef.tb_axi_bridge__DOT__prev_dst_aw[4U]) 
                                | vlSelfRef.tb_axi_bridge__DOT__prev_dst_aw[5U]) 
                               | vlSelfRef.tb_axi_bridge__DOT__prev_dst_aw[6U]) 
                              | vlSelfRef.tb_axi_bridge__DOT__prev_dst_aw[7U]) 
                             | vlSelfRef.tb_axi_bridge__DOT__prev_dst_aw[8U]) 
                            | vlSelfRef.tb_axi_bridge__DOT__prev_dst_aw[9U]) 
                           | vlSelfRef.tb_axi_bridge__DOT__prev_dst_aw[10U]) 
                          | vlSelfRef.tb_axi_bridge__DOT__prev_dst_aw[11U]) 
                         | vlSelfRef.tb_axi_bridge__DOT__prev_dst_aw[12U]) 
                        | vlSelfRef.tb_axi_bridge__DOT__prev_dst_aw[13U]) 
                       | vlSelfRef.tb_axi_bridge__DOT__prev_dst_aw[14U]) 
                      | vlSelfRef.tb_axi_bridge__DOT__prev_dst_aw[15U]));
        __Vtask_tb_axi_bridge__DOT__chk__antecedent_13 
            = vlSelfRef.tb_axi_bridge__DOT__dst_aw_stall;
        __Vtask_tb_axi_bridge__DOT__chk__check_id_12 = 3U;
        if (__Vtask_tb_axi_bridge__DOT__chk__antecedent_13) {
            if (VL_LIKELY(((0x23U >= (0x0000003fU & __Vtask_tb_axi_bridge__DOT__chk__check_id_12))))) {
                vlSelfRef.tb_axi_bridge__DOT__assertion_hits[(0x0000003fU 
                                                              & __Vtask_tb_axi_bridge__DOT__chk__check_id_12)] 
                    = ((IData)(1U) + ((0x23U >= (0x0000003fU 
                                                 & __Vtask_tb_axi_bridge__DOT__chk__check_id_12))
                                       ? vlSelfRef.tb_axi_bridge__DOT__assertion_hits
                                      [(0x0000003fU 
                                        & __Vtask_tb_axi_bridge__DOT__chk__check_id_12)]
                                       : 0U));
            }
            if (VL_UNLIKELY(((1U & (~ (IData)(__Vtask_tb_axi_bridge__DOT__chk__consequent_14)))))) {
                if (VL_LIKELY(((0x23U >= (0x0000003fU 
                                          & __Vtask_tb_axi_bridge__DOT__chk__check_id_12))))) {
                    vlSelfRef.tb_axi_bridge__DOT__assertion_fails[(0x0000003fU 
                                                                   & __Vtask_tb_axi_bridge__DOT__chk__check_id_12)] 
                        = ((IData)(1U) + ((0x23U >= 
                                           (0x0000003fU 
                                            & __Vtask_tb_axi_bridge__DOT__chk__check_id_12))
                                           ? vlSelfRef.tb_axi_bridge__DOT__assertion_fails
                                          [(0x0000003fU 
                                            & __Vtask_tb_axi_bridge__DOT__chk__check_id_12)]
                                           : 0U));
                }
                VL_WRITEF_NX("ASSERT FAIL AXI-SVA-%02d time=%0t\n",3, 'T',-9
                             , '~',32,__Vtask_tb_axi_bridge__DOT__chk__check_id_12
                             , '#',64,VL_TIME_UNITED_Q(1000));
            }
        }
        __Vtask_tb_axi_bridge__DOT__chk__consequent_17 = 1U;
        __Vtask_tb_axi_bridge__DOT__chk__antecedent_16 
            = vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_aw__DOT__o_axi_awvalid;
        __Vtask_tb_axi_bridge__DOT__chk__check_id_15 = 6U;
        if (__Vtask_tb_axi_bridge__DOT__chk__antecedent_16) {
            if (VL_LIKELY(((0x23U >= (0x0000003fU & __Vtask_tb_axi_bridge__DOT__chk__check_id_15))))) {
                vlSelfRef.tb_axi_bridge__DOT__assertion_hits[(0x0000003fU 
                                                              & __Vtask_tb_axi_bridge__DOT__chk__check_id_15)] 
                    = ((IData)(1U) + ((0x23U >= (0x0000003fU 
                                                 & __Vtask_tb_axi_bridge__DOT__chk__check_id_15))
                                       ? vlSelfRef.tb_axi_bridge__DOT__assertion_hits
                                      [(0x0000003fU 
                                        & __Vtask_tb_axi_bridge__DOT__chk__check_id_15)]
                                       : 0U));
            }
            if (VL_UNLIKELY(((1U & (~ (IData)(__Vtask_tb_axi_bridge__DOT__chk__consequent_17)))))) {
                if (VL_LIKELY(((0x23U >= (0x0000003fU 
                                          & __Vtask_tb_axi_bridge__DOT__chk__check_id_15))))) {
                    vlSelfRef.tb_axi_bridge__DOT__assertion_fails[(0x0000003fU 
                                                                   & __Vtask_tb_axi_bridge__DOT__chk__check_id_15)] 
                        = ((IData)(1U) + ((0x23U >= 
                                           (0x0000003fU 
                                            & __Vtask_tb_axi_bridge__DOT__chk__check_id_15))
                                           ? vlSelfRef.tb_axi_bridge__DOT__assertion_fails
                                          [(0x0000003fU 
                                            & __Vtask_tb_axi_bridge__DOT__chk__check_id_15)]
                                           : 0U));
                }
                VL_WRITEF_NX("ASSERT FAIL AXI-SVA-%02d time=%0t\n",3, 'T',-9
                             , '~',32,__Vtask_tb_axi_bridge__DOT__chk__check_id_15
                             , '#',64,VL_TIME_UNITED_Q(1000));
            }
        }
        if (((IData)(vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_aw__DOT__o_axi_awvalid) 
             & (IData)(vlSelfRef.tb_axi_bridge__DOT__i_axi_awready))) {
            __Vtemp_23[0U] = (IData)((((QData)((IData)(
                                                       ((vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_aw__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_mem__DOT__gen_array__DOT__reg_rd_data[1U] 
                                                         << 0x0000001cU) 
                                                        | (vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_aw__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_mem__DOT__gen_array__DOT__reg_rd_data[0U] 
                                                           >> 4U)))) 
                                       << 0x0000001dU) 
                                      | (QData)((IData)(
                                                        ((((0x00003fc0U 
                                                            & (vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_aw__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_mem__DOT__gen_array__DOT__reg_rd_data[1U] 
                                                               << 2U)) 
                                                           | ((0x00000038U 
                                                               & (vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_aw__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_mem__DOT__gen_array__DOT__reg_rd_data[1U] 
                                                                  >> 9U)) 
                                                              | ((6U 
                                                                  & (vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_aw__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_mem__DOT__gen_array__DOT__reg_rd_data[1U] 
                                                                     >> 0x0000000eU)) 
                                                                 | (1U 
                                                                    & (vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_aw__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_mem__DOT__gen_array__DOT__reg_rd_data[1U] 
                                                                       >> 0x00000011U))))) 
                                                          << 0x0000000fU) 
                                                         | ((((0x00000078U 
                                                               & (vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_aw__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_mem__DOT__gen_array__DOT__reg_rd_data[1U] 
                                                                  >> 0x0000000fU)) 
                                                              | (7U 
                                                                 & (vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_aw__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_mem__DOT__gen_array__DOT__reg_rd_data[1U] 
                                                                    >> 0x00000016U))) 
                                                             << 8U) 
                                                            | ((0x000000f0U 
                                                                & (vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_aw__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_mem__DOT__gen_array__DOT__reg_rd_data[1U] 
                                                                   >> 0x00000015U)) 
                                                               | (0x0000000fU 
                                                                  & ((vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_aw__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_mem__DOT__gen_array__DOT__reg_rd_data[2U] 
                                                                      << 3U) 
                                                                     | (vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_aw__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_mem__DOT__gen_array__DOT__reg_rd_data[1U] 
                                                                        >> 0x0000001dU))))))))));
            __Vtemp_23[1U] = ((vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_aw__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_mem__DOT__gen_array__DOT__reg_rd_data[0U] 
                               << 0x0000001dU) | (IData)(
                                                         ((((QData)((IData)(
                                                                            ((vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_aw__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_mem__DOT__gen_array__DOT__reg_rd_data[1U] 
                                                                              << 0x0000001cU) 
                                                                             | (vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_aw__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_mem__DOT__gen_array__DOT__reg_rd_data[0U] 
                                                                                >> 4U)))) 
                                                            << 0x0000001dU) 
                                                           | (QData)((IData)(
                                                                             ((((0x00003fc0U 
                                                                                & (vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_aw__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_mem__DOT__gen_array__DOT__reg_rd_data[1U] 
                                                                                << 2U)) 
                                                                                | ((0x00000038U 
                                                                                & (vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_aw__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_mem__DOT__gen_array__DOT__reg_rd_data[1U] 
                                                                                >> 9U)) 
                                                                                | ((6U 
                                                                                & (vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_aw__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_mem__DOT__gen_array__DOT__reg_rd_data[1U] 
                                                                                >> 0x0000000eU)) 
                                                                                | (1U 
                                                                                & (vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_aw__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_mem__DOT__gen_array__DOT__reg_rd_data[1U] 
                                                                                >> 0x00000011U))))) 
                                                                               << 0x0000000fU) 
                                                                              | ((((0x00000078U 
                                                                                & (vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_aw__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_mem__DOT__gen_array__DOT__reg_rd_data[1U] 
                                                                                >> 0x0000000fU)) 
                                                                                | (7U 
                                                                                & (vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_aw__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_mem__DOT__gen_array__DOT__reg_rd_data[1U] 
                                                                                >> 0x00000016U))) 
                                                                                << 8U) 
                                                                                | ((0x000000f0U 
                                                                                & (vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_aw__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_mem__DOT__gen_array__DOT__reg_rd_data[1U] 
                                                                                >> 0x00000015U)) 
                                                                                | (0x0000000fU 
                                                                                & ((vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_aw__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_mem__DOT__gen_array__DOT__reg_rd_data[2U] 
                                                                                << 3U) 
                                                                                | (vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_aw__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_mem__DOT__gen_array__DOT__reg_rd_data[1U] 
                                                                                >> 0x0000001dU))))))))) 
                                                          >> 0x00000020U)));
            __Vtask_tb_axi_bridge__DOT__chk__consequent_20 
                = (VL_LTS_III(32, vlSelfRef.tb_axi_bridge__DOT__aw_head, vlSelfRef.tb_axi_bridge__DOT__aw_tail) 
                   & (0U == ((((((((((((((((__Vtemp_23[0U] 
                                            ^ vlSelfRef.tb_axi_bridge__DOT__exp_aw
                                            [(0x000000ffU 
                                              & vlSelfRef.tb_axi_bridge__DOT__aw_head)][0U]) 
                                           | (__Vtemp_23[1U] 
                                              ^ vlSelfRef.tb_axi_bridge__DOT__exp_aw
                                              [(0x000000ffU 
                                                & vlSelfRef.tb_axi_bridge__DOT__aw_head)][1U])) 
                                          | ((1U & 
                                              (vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_aw__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_mem__DOT__gen_array__DOT__reg_rd_data[0U] 
                                               >> 3U)) 
                                             ^ vlSelfRef.tb_axi_bridge__DOT__exp_aw
                                             [(0x000000ffU 
                                               & vlSelfRef.tb_axi_bridge__DOT__aw_head)][2U])) 
                                         | vlSelfRef.tb_axi_bridge__DOT__exp_aw
                                         [(0x000000ffU 
                                           & vlSelfRef.tb_axi_bridge__DOT__aw_head)][3U]) 
                                        | vlSelfRef.tb_axi_bridge__DOT__exp_aw
                                        [(0x000000ffU 
                                          & vlSelfRef.tb_axi_bridge__DOT__aw_head)][4U]) 
                                       | vlSelfRef.tb_axi_bridge__DOT__exp_aw
                                       [(0x000000ffU 
                                         & vlSelfRef.tb_axi_bridge__DOT__aw_head)][5U]) 
                                      | vlSelfRef.tb_axi_bridge__DOT__exp_aw
                                      [(0x000000ffU 
                                        & vlSelfRef.tb_axi_bridge__DOT__aw_head)][6U]) 
                                     | vlSelfRef.tb_axi_bridge__DOT__exp_aw
                                     [(0x000000ffU 
                                       & vlSelfRef.tb_axi_bridge__DOT__aw_head)][7U]) 
                                    | vlSelfRef.tb_axi_bridge__DOT__exp_aw
                                    [(0x000000ffU & vlSelfRef.tb_axi_bridge__DOT__aw_head)][8U]) 
                                   | vlSelfRef.tb_axi_bridge__DOT__exp_aw
                                   [(0x000000ffU & vlSelfRef.tb_axi_bridge__DOT__aw_head)][9U]) 
                                  | vlSelfRef.tb_axi_bridge__DOT__exp_aw
                                  [(0x000000ffU & vlSelfRef.tb_axi_bridge__DOT__aw_head)][10U]) 
                                 | vlSelfRef.tb_axi_bridge__DOT__exp_aw
                                 [(0x000000ffU & vlSelfRef.tb_axi_bridge__DOT__aw_head)][11U]) 
                                | vlSelfRef.tb_axi_bridge__DOT__exp_aw
                                [(0x000000ffU & vlSelfRef.tb_axi_bridge__DOT__aw_head)][12U]) 
                               | vlSelfRef.tb_axi_bridge__DOT__exp_aw
                               [(0x000000ffU & vlSelfRef.tb_axi_bridge__DOT__aw_head)][13U]) 
                              | vlSelfRef.tb_axi_bridge__DOT__exp_aw
                              [(0x000000ffU & vlSelfRef.tb_axi_bridge__DOT__aw_head)][14U]) 
                             | vlSelfRef.tb_axi_bridge__DOT__exp_aw
                             [(0x000000ffU & vlSelfRef.tb_axi_bridge__DOT__aw_head)][15U])));
            __Vtask_tb_axi_bridge__DOT__chk__check_id_18 = 4U;
            vlSelfRef.tb_axi_bridge__DOT__out_aw = 
                ((IData)(1U) + vlSelfRef.tb_axi_bridge__DOT__out_aw);
            vlSelfRef.tb_axi_bridge__DOT__assertion_hits[(0x0000003fU 
                                                          & __Vtask_tb_axi_bridge__DOT__chk__check_id_18)] 
                = ((IData)(1U) + ((0x23U >= (0x0000003fU 
                                             & __Vtask_tb_axi_bridge__DOT__chk__check_id_18))
                                   ? vlSelfRef.tb_axi_bridge__DOT__assertion_hits
                                  [(0x0000003fU & __Vtask_tb_axi_bridge__DOT__chk__check_id_18)]
                                   : 0U));
            if (VL_UNLIKELY(((1U & (~ (IData)(__Vtask_tb_axi_bridge__DOT__chk__consequent_20)))))) {
                if (VL_LIKELY(((0x23U >= (0x0000003fU 
                                          & __Vtask_tb_axi_bridge__DOT__chk__check_id_18))))) {
                    vlSelfRef.tb_axi_bridge__DOT__assertion_fails[(0x0000003fU 
                                                                   & __Vtask_tb_axi_bridge__DOT__chk__check_id_18)] 
                        = ((IData)(1U) + ((0x23U >= 
                                           (0x0000003fU 
                                            & __Vtask_tb_axi_bridge__DOT__chk__check_id_18))
                                           ? vlSelfRef.tb_axi_bridge__DOT__assertion_fails
                                          [(0x0000003fU 
                                            & __Vtask_tb_axi_bridge__DOT__chk__check_id_18)]
                                           : 0U));
                }
                VL_WRITEF_NX("ASSERT FAIL AXI-SVA-%02d time=%0t\n",3, 'T',-9
                             , '~',32,__Vtask_tb_axi_bridge__DOT__chk__check_id_18
                             , '#',64,VL_TIME_UNITED_Q(1000));
            }
            vlSelfRef.tb_axi_bridge__DOT__aw_head = 
                ((IData)(1U) + vlSelfRef.tb_axi_bridge__DOT__aw_head);
        }
        vlSelfRef.tb_axi_bridge__DOT__dst_aw_stall 
            = ((IData)(vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_aw__DOT__o_axi_awvalid) 
               & (~ (IData)(vlSelfRef.tb_axi_bridge__DOT__i_axi_awready)));
        vlSelfRef.tb_axi_bridge__DOT__prev_dst_aw[0U] 
            = ((0xe0000000U & vlSelfRef.tb_axi_bridge__DOT__prev_dst_aw[0U]) 
               | ((((0x00003fc0U & (vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_aw__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_mem__DOT__gen_array__DOT__reg_rd_data[1U] 
                                    << 2U)) | ((0x00000038U 
                                                & (vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_aw__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_mem__DOT__gen_array__DOT__reg_rd_data[1U] 
                                                   >> 9U)) 
                                               | ((6U 
                                                   & (vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_aw__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_mem__DOT__gen_array__DOT__reg_rd_data[1U] 
                                                      >> 0x0000000eU)) 
                                                  | (1U 
                                                     & (vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_aw__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_mem__DOT__gen_array__DOT__reg_rd_data[1U] 
                                                        >> 0x00000011U))))) 
                   << 0x0000000fU) | ((((0x00000078U 
                                         & (vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_aw__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_mem__DOT__gen_array__DOT__reg_rd_data[1U] 
                                            >> 0x0000000fU)) 
                                        | (7U & (vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_aw__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_mem__DOT__gen_array__DOT__reg_rd_data[1U] 
                                                 >> 0x00000016U))) 
                                       << 8U) | ((0x000000f0U 
                                                  & (vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_aw__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_mem__DOT__gen_array__DOT__reg_rd_data[1U] 
                                                     >> 0x00000015U)) 
                                                 | (0x0000000fU 
                                                    & ((vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_aw__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_mem__DOT__gen_array__DOT__reg_rd_data[2U] 
                                                        << 3U) 
                                                       | (vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_aw__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_mem__DOT__gen_array__DOT__reg_rd_data[1U] 
                                                          >> 0x0000001dU)))))));
        vlSelfRef.tb_axi_bridge__DOT__prev_dst_aw[0U] 
            = ((0x1fffffffU & vlSelfRef.tb_axi_bridge__DOT__prev_dst_aw[0U]) 
               | ((IData)((((QData)((IData)((0x0000000fU 
                                             & vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_aw__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_mem__DOT__gen_array__DOT__reg_rd_data[0U]))) 
                            << 0x00000020U) | (QData)((IData)(
                                                              ((vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_aw__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_mem__DOT__gen_array__DOT__reg_rd_data[1U] 
                                                                << 0x0000001cU) 
                                                               | (vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_aw__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_mem__DOT__gen_array__DOT__reg_rd_data[0U] 
                                                                  >> 4U)))))) 
                  << 0x0000001dU));
        vlSelfRef.tb_axi_bridge__DOT__prev_dst_aw[1U] 
            = (((IData)((((QData)((IData)((0x0000000fU 
                                           & vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_aw__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_mem__DOT__gen_array__DOT__reg_rd_data[0U]))) 
                          << 0x00000020U) | (QData)((IData)(
                                                            ((vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_aw__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_mem__DOT__gen_array__DOT__reg_rd_data[1U] 
                                                              << 0x0000001cU) 
                                                             | (vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_aw__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_mem__DOT__gen_array__DOT__reg_rd_data[0U] 
                                                                >> 4U)))))) 
                >> 3U) | ((IData)(((((QData)((IData)(
                                                     (0x0000000fU 
                                                      & vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_aw__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_mem__DOT__gen_array__DOT__reg_rd_data[0U]))) 
                                     << 0x00000020U) 
                                    | (QData)((IData)(
                                                      ((vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_aw__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_mem__DOT__gen_array__DOT__reg_rd_data[1U] 
                                                        << 0x0000001cU) 
                                                       | (vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_aw__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_mem__DOT__gen_array__DOT__reg_rd_data[0U] 
                                                          >> 4U))))) 
                                   >> 0x00000020U)) 
                          << 0x0000001dU));
        vlSelfRef.tb_axi_bridge__DOT__prev_dst_aw[2U] 
            = ((IData)(((((QData)((IData)((0x0000000fU 
                                           & vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_aw__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_mem__DOT__gen_array__DOT__reg_rd_data[0U]))) 
                          << 0x00000020U) | (QData)((IData)(
                                                            ((vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_aw__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_mem__DOT__gen_array__DOT__reg_rd_data[1U] 
                                                              << 0x0000001cU) 
                                                             | (vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_aw__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_mem__DOT__gen_array__DOT__reg_rd_data[0U] 
                                                                >> 4U))))) 
                        >> 0x00000020U)) >> 3U);
        vlSelfRef.tb_axi_bridge__DOT__prev_dst_aw[3U] = 0U;
        vlSelfRef.tb_axi_bridge__DOT__prev_dst_aw[4U] = 0U;
        vlSelfRef.tb_axi_bridge__DOT__prev_dst_aw[5U] = 0U;
        vlSelfRef.tb_axi_bridge__DOT__prev_dst_aw[6U] = 0U;
        vlSelfRef.tb_axi_bridge__DOT__prev_dst_aw[7U] = 0U;
        vlSelfRef.tb_axi_bridge__DOT__prev_dst_aw[8U] = 0U;
        vlSelfRef.tb_axi_bridge__DOT__prev_dst_aw[9U] = 0U;
        vlSelfRef.tb_axi_bridge__DOT__prev_dst_aw[10U] = 0U;
        vlSelfRef.tb_axi_bridge__DOT__prev_dst_aw[11U] = 0U;
        vlSelfRef.tb_axi_bridge__DOT__prev_dst_aw[12U] = 0U;
        vlSelfRef.tb_axi_bridge__DOT__prev_dst_aw[13U] = 0U;
        vlSelfRef.tb_axi_bridge__DOT__prev_dst_aw[14U] = 0U;
        vlSelfRef.tb_axi_bridge__DOT__prev_dst_aw[15U] = 0U;
        __Vtask_tb_axi_bridge__DOT__chk__consequent_35 
            = vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_w__DOT__o_axi_wvalid;
        __Vtask_tb_axi_bridge__DOT__chk__antecedent_34 
            = vlSelfRef.tb_axi_bridge__DOT__dst_w_stall;
        __Vtask_tb_axi_bridge__DOT__chk__check_id_33 = 9U;
        if (__Vtask_tb_axi_bridge__DOT__chk__antecedent_34) {
            if (VL_LIKELY(((0x23U >= (0x0000003fU & __Vtask_tb_axi_bridge__DOT__chk__check_id_33))))) {
                vlSelfRef.tb_axi_bridge__DOT__assertion_hits[(0x0000003fU 
                                                              & __Vtask_tb_axi_bridge__DOT__chk__check_id_33)] 
                    = ((IData)(1U) + ((0x23U >= (0x0000003fU 
                                                 & __Vtask_tb_axi_bridge__DOT__chk__check_id_33))
                                       ? vlSelfRef.tb_axi_bridge__DOT__assertion_hits
                                      [(0x0000003fU 
                                        & __Vtask_tb_axi_bridge__DOT__chk__check_id_33)]
                                       : 0U));
            }
            if (VL_UNLIKELY(((1U & (~ (IData)(__Vtask_tb_axi_bridge__DOT__chk__consequent_35)))))) {
                if (VL_LIKELY(((0x23U >= (0x0000003fU 
                                          & __Vtask_tb_axi_bridge__DOT__chk__check_id_33))))) {
                    vlSelfRef.tb_axi_bridge__DOT__assertion_fails[(0x0000003fU 
                                                                   & __Vtask_tb_axi_bridge__DOT__chk__check_id_33)] 
                        = ((IData)(1U) + ((0x23U >= 
                                           (0x0000003fU 
                                            & __Vtask_tb_axi_bridge__DOT__chk__check_id_33))
                                           ? vlSelfRef.tb_axi_bridge__DOT__assertion_fails
                                          [(0x0000003fU 
                                            & __Vtask_tb_axi_bridge__DOT__chk__check_id_33)]
                                           : 0U));
                }
                VL_WRITEF_NX("ASSERT FAIL AXI-SVA-%02d time=%0t\n",3, 'T',-9
                             , '~',32,__Vtask_tb_axi_bridge__DOT__chk__check_id_33
                             , '#',64,VL_TIME_UNITED_Q(1000));
            }
        }
        __Vtask_tb_axi_bridge__DOT__chk__consequent_38 
            = (0U == (((((((((((((((((IData)((((QData)((IData)(vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_w__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_mem__DOT__gen_array__DOT__reg_rd_data)) 
                                               << 5U) 
                                              | (QData)((IData)(
                                                                ((0x0000001eU 
                                                                  & ((IData)(
                                                                             (vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_w__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_mem__DOT__gen_array__DOT__reg_rd_data 
                                                                              >> 0x00000020U)) 
                                                                     << 1U)) 
                                                                 | (1U 
                                                                    & (IData)(
                                                                              (vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_w__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_mem__DOT__gen_array__DOT__reg_rd_data 
                                                                               >> 0x00000024U)))))))) 
                                     ^ vlSelfRef.tb_axi_bridge__DOT__prev_dst_w[0U]) 
                                    | ((IData)(((((QData)((IData)(vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_w__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_mem__DOT__gen_array__DOT__reg_rd_data)) 
                                                  << 5U) 
                                                 | (QData)((IData)(
                                                                   ((0x0000001eU 
                                                                     & ((IData)(
                                                                                (vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_w__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_mem__DOT__gen_array__DOT__reg_rd_data 
                                                                                >> 0x00000020U)) 
                                                                        << 1U)) 
                                                                    | (1U 
                                                                       & (IData)(
                                                                                (vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_w__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_mem__DOT__gen_array__DOT__reg_rd_data 
                                                                                >> 0x00000024U))))))) 
                                                >> 0x00000020U)) 
                                       ^ vlSelfRef.tb_axi_bridge__DOT__prev_dst_w[1U])) 
                                   | vlSelfRef.tb_axi_bridge__DOT__prev_dst_w[2U]) 
                                  | vlSelfRef.tb_axi_bridge__DOT__prev_dst_w[3U]) 
                                 | vlSelfRef.tb_axi_bridge__DOT__prev_dst_w[4U]) 
                                | vlSelfRef.tb_axi_bridge__DOT__prev_dst_w[5U]) 
                               | vlSelfRef.tb_axi_bridge__DOT__prev_dst_w[6U]) 
                              | vlSelfRef.tb_axi_bridge__DOT__prev_dst_w[7U]) 
                             | vlSelfRef.tb_axi_bridge__DOT__prev_dst_w[8U]) 
                            | vlSelfRef.tb_axi_bridge__DOT__prev_dst_w[9U]) 
                           | vlSelfRef.tb_axi_bridge__DOT__prev_dst_w[10U]) 
                          | vlSelfRef.tb_axi_bridge__DOT__prev_dst_w[11U]) 
                         | vlSelfRef.tb_axi_bridge__DOT__prev_dst_w[12U]) 
                        | vlSelfRef.tb_axi_bridge__DOT__prev_dst_w[13U]) 
                       | vlSelfRef.tb_axi_bridge__DOT__prev_dst_w[14U]) 
                      | vlSelfRef.tb_axi_bridge__DOT__prev_dst_w[15U]));
        __Vtask_tb_axi_bridge__DOT__chk__antecedent_37 
            = vlSelfRef.tb_axi_bridge__DOT__dst_w_stall;
        __Vtask_tb_axi_bridge__DOT__chk__check_id_36 = 0x0000000aU;
        if (__Vtask_tb_axi_bridge__DOT__chk__antecedent_37) {
            if (VL_LIKELY(((0x23U >= (0x0000003fU & __Vtask_tb_axi_bridge__DOT__chk__check_id_36))))) {
                vlSelfRef.tb_axi_bridge__DOT__assertion_hits[(0x0000003fU 
                                                              & __Vtask_tb_axi_bridge__DOT__chk__check_id_36)] 
                    = ((IData)(1U) + ((0x23U >= (0x0000003fU 
                                                 & __Vtask_tb_axi_bridge__DOT__chk__check_id_36))
                                       ? vlSelfRef.tb_axi_bridge__DOT__assertion_hits
                                      [(0x0000003fU 
                                        & __Vtask_tb_axi_bridge__DOT__chk__check_id_36)]
                                       : 0U));
            }
            if (VL_UNLIKELY(((1U & (~ (IData)(__Vtask_tb_axi_bridge__DOT__chk__consequent_38)))))) {
                if (VL_LIKELY(((0x23U >= (0x0000003fU 
                                          & __Vtask_tb_axi_bridge__DOT__chk__check_id_36))))) {
                    vlSelfRef.tb_axi_bridge__DOT__assertion_fails[(0x0000003fU 
                                                                   & __Vtask_tb_axi_bridge__DOT__chk__check_id_36)] 
                        = ((IData)(1U) + ((0x23U >= 
                                           (0x0000003fU 
                                            & __Vtask_tb_axi_bridge__DOT__chk__check_id_36))
                                           ? vlSelfRef.tb_axi_bridge__DOT__assertion_fails
                                          [(0x0000003fU 
                                            & __Vtask_tb_axi_bridge__DOT__chk__check_id_36)]
                                           : 0U));
                }
                VL_WRITEF_NX("ASSERT FAIL AXI-SVA-%02d time=%0t\n",3, 'T',-9
                             , '~',32,__Vtask_tb_axi_bridge__DOT__chk__check_id_36
                             , '#',64,VL_TIME_UNITED_Q(1000));
            }
        }
        __Vtask_tb_axi_bridge__DOT__chk__consequent_41 = 1U;
        __Vtask_tb_axi_bridge__DOT__chk__antecedent_40 
            = vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_w__DOT__o_axi_wvalid;
        __Vtask_tb_axi_bridge__DOT__chk__check_id_39 = 0x0000000dU;
        if (__Vtask_tb_axi_bridge__DOT__chk__antecedent_40) {
            if (VL_LIKELY(((0x23U >= (0x0000003fU & __Vtask_tb_axi_bridge__DOT__chk__check_id_39))))) {
                vlSelfRef.tb_axi_bridge__DOT__assertion_hits[(0x0000003fU 
                                                              & __Vtask_tb_axi_bridge__DOT__chk__check_id_39)] 
                    = ((IData)(1U) + ((0x23U >= (0x0000003fU 
                                                 & __Vtask_tb_axi_bridge__DOT__chk__check_id_39))
                                       ? vlSelfRef.tb_axi_bridge__DOT__assertion_hits
                                      [(0x0000003fU 
                                        & __Vtask_tb_axi_bridge__DOT__chk__check_id_39)]
                                       : 0U));
            }
            if (VL_UNLIKELY(((1U & (~ (IData)(__Vtask_tb_axi_bridge__DOT__chk__consequent_41)))))) {
                if (VL_LIKELY(((0x23U >= (0x0000003fU 
                                          & __Vtask_tb_axi_bridge__DOT__chk__check_id_39))))) {
                    vlSelfRef.tb_axi_bridge__DOT__assertion_fails[(0x0000003fU 
                                                                   & __Vtask_tb_axi_bridge__DOT__chk__check_id_39)] 
                        = ((IData)(1U) + ((0x23U >= 
                                           (0x0000003fU 
                                            & __Vtask_tb_axi_bridge__DOT__chk__check_id_39))
                                           ? vlSelfRef.tb_axi_bridge__DOT__assertion_fails
                                          [(0x0000003fU 
                                            & __Vtask_tb_axi_bridge__DOT__chk__check_id_39)]
                                           : 0U));
                }
                VL_WRITEF_NX("ASSERT FAIL AXI-SVA-%02d time=%0t\n",3, 'T',-9
                             , '~',32,__Vtask_tb_axi_bridge__DOT__chk__check_id_39
                             , '#',64,VL_TIME_UNITED_Q(1000));
            }
        }
        if (((IData)(vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_w__DOT__o_axi_wvalid) 
             & (IData)(vlSelfRef.tb_axi_bridge__DOT__i_axi_wready))) {
            __Vtask_tb_axi_bridge__DOT__chk__consequent_44 
                = (VL_LTS_III(32, vlSelfRef.tb_axi_bridge__DOT__w_head, vlSelfRef.tb_axi_bridge__DOT__w_tail) 
                   & (0U == (((((((((((((((((IData)(
                                                    (((QData)((IData)(vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_w__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_mem__DOT__gen_array__DOT__reg_rd_data)) 
                                                      << 5U) 
                                                     | (QData)((IData)(
                                                                       ((0x0000001eU 
                                                                         & ((IData)(
                                                                                (vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_w__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_mem__DOT__gen_array__DOT__reg_rd_data 
                                                                                >> 0x00000020U)) 
                                                                            << 1U)) 
                                                                        | (1U 
                                                                           & (IData)(
                                                                                (vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_w__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_mem__DOT__gen_array__DOT__reg_rd_data 
                                                                                >> 0x00000024U)))))))) 
                                            ^ vlSelfRef.tb_axi_bridge__DOT__exp_w
                                            [(0x000000ffU 
                                              & vlSelfRef.tb_axi_bridge__DOT__w_head)][0U]) 
                                           | ((IData)(
                                                      ((((QData)((IData)(vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_w__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_mem__DOT__gen_array__DOT__reg_rd_data)) 
                                                         << 5U) 
                                                        | (QData)((IData)(
                                                                          ((0x0000001eU 
                                                                            & ((IData)(
                                                                                (vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_w__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_mem__DOT__gen_array__DOT__reg_rd_data 
                                                                                >> 0x00000020U)) 
                                                                               << 1U)) 
                                                                           | (1U 
                                                                              & (IData)(
                                                                                (vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_w__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_mem__DOT__gen_array__DOT__reg_rd_data 
                                                                                >> 0x00000024U))))))) 
                                                       >> 0x00000020U)) 
                                              ^ vlSelfRef.tb_axi_bridge__DOT__exp_w
                                              [(0x000000ffU 
                                                & vlSelfRef.tb_axi_bridge__DOT__w_head)][1U])) 
                                          | vlSelfRef.tb_axi_bridge__DOT__exp_w
                                          [(0x000000ffU 
                                            & vlSelfRef.tb_axi_bridge__DOT__w_head)][2U]) 
                                         | vlSelfRef.tb_axi_bridge__DOT__exp_w
                                         [(0x000000ffU 
                                           & vlSelfRef.tb_axi_bridge__DOT__w_head)][3U]) 
                                        | vlSelfRef.tb_axi_bridge__DOT__exp_w
                                        [(0x000000ffU 
                                          & vlSelfRef.tb_axi_bridge__DOT__w_head)][4U]) 
                                       | vlSelfRef.tb_axi_bridge__DOT__exp_w
                                       [(0x000000ffU 
                                         & vlSelfRef.tb_axi_bridge__DOT__w_head)][5U]) 
                                      | vlSelfRef.tb_axi_bridge__DOT__exp_w
                                      [(0x000000ffU 
                                        & vlSelfRef.tb_axi_bridge__DOT__w_head)][6U]) 
                                     | vlSelfRef.tb_axi_bridge__DOT__exp_w
                                     [(0x000000ffU 
                                       & vlSelfRef.tb_axi_bridge__DOT__w_head)][7U]) 
                                    | vlSelfRef.tb_axi_bridge__DOT__exp_w
                                    [(0x000000ffU & vlSelfRef.tb_axi_bridge__DOT__w_head)][8U]) 
                                   | vlSelfRef.tb_axi_bridge__DOT__exp_w
                                   [(0x000000ffU & vlSelfRef.tb_axi_bridge__DOT__w_head)][9U]) 
                                  | vlSelfRef.tb_axi_bridge__DOT__exp_w
                                  [(0x000000ffU & vlSelfRef.tb_axi_bridge__DOT__w_head)][10U]) 
                                 | vlSelfRef.tb_axi_bridge__DOT__exp_w
                                 [(0x000000ffU & vlSelfRef.tb_axi_bridge__DOT__w_head)][11U]) 
                                | vlSelfRef.tb_axi_bridge__DOT__exp_w
                                [(0x000000ffU & vlSelfRef.tb_axi_bridge__DOT__w_head)][12U]) 
                               | vlSelfRef.tb_axi_bridge__DOT__exp_w
                               [(0x000000ffU & vlSelfRef.tb_axi_bridge__DOT__w_head)][13U]) 
                              | vlSelfRef.tb_axi_bridge__DOT__exp_w
                              [(0x000000ffU & vlSelfRef.tb_axi_bridge__DOT__w_head)][14U]) 
                             | vlSelfRef.tb_axi_bridge__DOT__exp_w
                             [(0x000000ffU & vlSelfRef.tb_axi_bridge__DOT__w_head)][15U])));
            __Vtask_tb_axi_bridge__DOT__chk__check_id_42 = 0x0000000bU;
            vlSelfRef.tb_axi_bridge__DOT__out_w = ((IData)(1U) 
                                                   + vlSelfRef.tb_axi_bridge__DOT__out_w);
            vlSelfRef.tb_axi_bridge__DOT__assertion_hits[(0x0000003fU 
                                                          & __Vtask_tb_axi_bridge__DOT__chk__check_id_42)] 
                = ((IData)(1U) + ((0x23U >= (0x0000003fU 
                                             & __Vtask_tb_axi_bridge__DOT__chk__check_id_42))
                                   ? vlSelfRef.tb_axi_bridge__DOT__assertion_hits
                                  [(0x0000003fU & __Vtask_tb_axi_bridge__DOT__chk__check_id_42)]
                                   : 0U));
            if (VL_UNLIKELY(((1U & (~ (IData)(__Vtask_tb_axi_bridge__DOT__chk__consequent_44)))))) {
                if (VL_LIKELY(((0x23U >= (0x0000003fU 
                                          & __Vtask_tb_axi_bridge__DOT__chk__check_id_42))))) {
                    vlSelfRef.tb_axi_bridge__DOT__assertion_fails[(0x0000003fU 
                                                                   & __Vtask_tb_axi_bridge__DOT__chk__check_id_42)] 
                        = ((IData)(1U) + ((0x23U >= 
                                           (0x0000003fU 
                                            & __Vtask_tb_axi_bridge__DOT__chk__check_id_42))
                                           ? vlSelfRef.tb_axi_bridge__DOT__assertion_fails
                                          [(0x0000003fU 
                                            & __Vtask_tb_axi_bridge__DOT__chk__check_id_42)]
                                           : 0U));
                }
                VL_WRITEF_NX("ASSERT FAIL AXI-SVA-%02d time=%0t\n",3, 'T',-9
                             , '~',32,__Vtask_tb_axi_bridge__DOT__chk__check_id_42
                             , '#',64,VL_TIME_UNITED_Q(1000));
            }
            vlSelfRef.tb_axi_bridge__DOT__w_head = 
                ((IData)(1U) + vlSelfRef.tb_axi_bridge__DOT__w_head);
        }
        vlSelfRef.tb_axi_bridge__DOT__dst_w_stall = 
            ((IData)(vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_w__DOT__o_axi_wvalid) 
             & (~ (IData)(vlSelfRef.tb_axi_bridge__DOT__i_axi_wready)));
        vlSelfRef.tb_axi_bridge__DOT__prev_dst_w[0U] 
            = (IData)((((QData)((IData)(vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_w__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_mem__DOT__gen_array__DOT__reg_rd_data)) 
                        << 5U) | (QData)((IData)(((0x0000001eU 
                                                   & ((IData)(
                                                              (vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_w__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_mem__DOT__gen_array__DOT__reg_rd_data 
                                                               >> 0x00000020U)) 
                                                      << 1U)) 
                                                  | (1U 
                                                     & (IData)(
                                                               (vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_w__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_mem__DOT__gen_array__DOT__reg_rd_data 
                                                                >> 0x00000024U))))))));
        vlSelfRef.tb_axi_bridge__DOT__prev_dst_w[1U] 
            = ((0xffffffe0U & vlSelfRef.tb_axi_bridge__DOT__prev_dst_w[1U]) 
               | (IData)(((((QData)((IData)(vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_w__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_mem__DOT__gen_array__DOT__reg_rd_data)) 
                            << 5U) | (QData)((IData)(
                                                     ((0x0000001eU 
                                                       & ((IData)(
                                                                  (vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_w__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_mem__DOT__gen_array__DOT__reg_rd_data 
                                                                   >> 0x00000020U)) 
                                                          << 1U)) 
                                                      | (1U 
                                                         & (IData)(
                                                                   (vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_w__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_mem__DOT__gen_array__DOT__reg_rd_data 
                                                                    >> 0x00000024U))))))) 
                          >> 0x00000020U)));
        vlSelfRef.tb_axi_bridge__DOT__prev_dst_w[1U] 
            = (0x0000001fU & vlSelfRef.tb_axi_bridge__DOT__prev_dst_w[1U]);
        vlSelfRef.tb_axi_bridge__DOT__prev_dst_w[2U] = 0U;
        vlSelfRef.tb_axi_bridge__DOT__prev_dst_w[3U] = 0U;
        vlSelfRef.tb_axi_bridge__DOT__prev_dst_w[4U] = 0U;
        vlSelfRef.tb_axi_bridge__DOT__prev_dst_w[5U] = 0U;
        vlSelfRef.tb_axi_bridge__DOT__prev_dst_w[6U] = 0U;
        vlSelfRef.tb_axi_bridge__DOT__prev_dst_w[7U] = 0U;
        vlSelfRef.tb_axi_bridge__DOT__prev_dst_w[8U] = 0U;
        vlSelfRef.tb_axi_bridge__DOT__prev_dst_w[9U] = 0U;
        vlSelfRef.tb_axi_bridge__DOT__prev_dst_w[10U] = 0U;
        vlSelfRef.tb_axi_bridge__DOT__prev_dst_w[11U] = 0U;
        vlSelfRef.tb_axi_bridge__DOT__prev_dst_w[12U] = 0U;
        vlSelfRef.tb_axi_bridge__DOT__prev_dst_w[13U] = 0U;
        vlSelfRef.tb_axi_bridge__DOT__prev_dst_w[14U] = 0U;
        vlSelfRef.tb_axi_bridge__DOT__prev_dst_w[15U] = 0U;
        __Vtask_tb_axi_bridge__DOT__chk__consequent_83 
            = vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_ar__DOT__o_axi_arvalid;
        __Vtask_tb_axi_bridge__DOT__chk__antecedent_82 
            = vlSelfRef.tb_axi_bridge__DOT__dst_ar_stall;
        __Vtask_tb_axi_bridge__DOT__chk__check_id_81 = 0x00000017U;
        if (__Vtask_tb_axi_bridge__DOT__chk__antecedent_82) {
            if (VL_LIKELY(((0x23U >= (0x0000003fU & __Vtask_tb_axi_bridge__DOT__chk__check_id_81))))) {
                vlSelfRef.tb_axi_bridge__DOT__assertion_hits[(0x0000003fU 
                                                              & __Vtask_tb_axi_bridge__DOT__chk__check_id_81)] 
                    = ((IData)(1U) + ((0x23U >= (0x0000003fU 
                                                 & __Vtask_tb_axi_bridge__DOT__chk__check_id_81))
                                       ? vlSelfRef.tb_axi_bridge__DOT__assertion_hits
                                      [(0x0000003fU 
                                        & __Vtask_tb_axi_bridge__DOT__chk__check_id_81)]
                                       : 0U));
            }
            if (VL_UNLIKELY(((1U & (~ (IData)(__Vtask_tb_axi_bridge__DOT__chk__consequent_83)))))) {
                if (VL_LIKELY(((0x23U >= (0x0000003fU 
                                          & __Vtask_tb_axi_bridge__DOT__chk__check_id_81))))) {
                    vlSelfRef.tb_axi_bridge__DOT__assertion_fails[(0x0000003fU 
                                                                   & __Vtask_tb_axi_bridge__DOT__chk__check_id_81)] 
                        = ((IData)(1U) + ((0x23U >= 
                                           (0x0000003fU 
                                            & __Vtask_tb_axi_bridge__DOT__chk__check_id_81))
                                           ? vlSelfRef.tb_axi_bridge__DOT__assertion_fails
                                          [(0x0000003fU 
                                            & __Vtask_tb_axi_bridge__DOT__chk__check_id_81)]
                                           : 0U));
                }
                VL_WRITEF_NX("ASSERT FAIL AXI-SVA-%02d time=%0t\n",3, 'T',-9
                             , '~',32,__Vtask_tb_axi_bridge__DOT__chk__check_id_81
                             , '#',64,VL_TIME_UNITED_Q(1000));
            }
        }
        __Vtemp_44[0U] = (IData)((((QData)((IData)(
                                                   ((vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_ar__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_mem__DOT__gen_array__DOT__reg_rd_data[1U] 
                                                     << 0x0000001cU) 
                                                    | (vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_ar__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_mem__DOT__gen_array__DOT__reg_rd_data[0U] 
                                                       >> 4U)))) 
                                   << 0x0000001dU) 
                                  | (QData)((IData)(
                                                    ((((0x00003fc0U 
                                                        & (vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_ar__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_mem__DOT__gen_array__DOT__reg_rd_data[1U] 
                                                           << 2U)) 
                                                       | ((0x00000038U 
                                                           & (vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_ar__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_mem__DOT__gen_array__DOT__reg_rd_data[1U] 
                                                              >> 9U)) 
                                                          | ((6U 
                                                              & (vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_ar__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_mem__DOT__gen_array__DOT__reg_rd_data[1U] 
                                                                 >> 0x0000000eU)) 
                                                             | (1U 
                                                                & (vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_ar__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_mem__DOT__gen_array__DOT__reg_rd_data[1U] 
                                                                   >> 0x00000011U))))) 
                                                      << 0x0000000fU) 
                                                     | ((((0x00000078U 
                                                           & (vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_ar__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_mem__DOT__gen_array__DOT__reg_rd_data[1U] 
                                                              >> 0x0000000fU)) 
                                                          | (7U 
                                                             & (vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_ar__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_mem__DOT__gen_array__DOT__reg_rd_data[1U] 
                                                                >> 0x00000016U))) 
                                                         << 8U) 
                                                        | ((0x000000f0U 
                                                            & (vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_ar__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_mem__DOT__gen_array__DOT__reg_rd_data[1U] 
                                                               >> 0x00000015U)) 
                                                           | (0x0000000fU 
                                                              & ((vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_ar__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_mem__DOT__gen_array__DOT__reg_rd_data[2U] 
                                                                  << 3U) 
                                                                 | (vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_ar__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_mem__DOT__gen_array__DOT__reg_rd_data[1U] 
                                                                    >> 0x0000001dU))))))))));
        __Vtemp_44[1U] = ((vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_ar__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_mem__DOT__gen_array__DOT__reg_rd_data[0U] 
                           << 0x0000001dU) | (IData)(
                                                     ((((QData)((IData)(
                                                                        ((vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_ar__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_mem__DOT__gen_array__DOT__reg_rd_data[1U] 
                                                                          << 0x0000001cU) 
                                                                         | (vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_ar__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_mem__DOT__gen_array__DOT__reg_rd_data[0U] 
                                                                            >> 4U)))) 
                                                        << 0x0000001dU) 
                                                       | (QData)((IData)(
                                                                         ((((0x00003fc0U 
                                                                             & (vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_ar__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_mem__DOT__gen_array__DOT__reg_rd_data[1U] 
                                                                                << 2U)) 
                                                                            | ((0x00000038U 
                                                                                & (vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_ar__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_mem__DOT__gen_array__DOT__reg_rd_data[1U] 
                                                                                >> 9U)) 
                                                                               | ((6U 
                                                                                & (vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_ar__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_mem__DOT__gen_array__DOT__reg_rd_data[1U] 
                                                                                >> 0x0000000eU)) 
                                                                                | (1U 
                                                                                & (vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_ar__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_mem__DOT__gen_array__DOT__reg_rd_data[1U] 
                                                                                >> 0x00000011U))))) 
                                                                           << 0x0000000fU) 
                                                                          | ((((0x00000078U 
                                                                                & (vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_ar__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_mem__DOT__gen_array__DOT__reg_rd_data[1U] 
                                                                                >> 0x0000000fU)) 
                                                                               | (7U 
                                                                                & (vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_ar__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_mem__DOT__gen_array__DOT__reg_rd_data[1U] 
                                                                                >> 0x00000016U))) 
                                                                              << 8U) 
                                                                             | ((0x000000f0U 
                                                                                & (vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_ar__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_mem__DOT__gen_array__DOT__reg_rd_data[1U] 
                                                                                >> 0x00000015U)) 
                                                                                | (0x0000000fU 
                                                                                & ((vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_ar__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_mem__DOT__gen_array__DOT__reg_rd_data[2U] 
                                                                                << 3U) 
                                                                                | (vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_ar__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_mem__DOT__gen_array__DOT__reg_rd_data[1U] 
                                                                                >> 0x0000001dU))))))))) 
                                                      >> 0x00000020U)));
        __Vtask_tb_axi_bridge__DOT__chk__consequent_86 
            = (0U == ((((((((((((((((__Vtemp_44[0U] 
                                     ^ vlSelfRef.tb_axi_bridge__DOT__prev_dst_ar[0U]) 
                                    | (__Vtemp_44[1U] 
                                       ^ vlSelfRef.tb_axi_bridge__DOT__prev_dst_ar[1U])) 
                                   | ((1U & (vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_ar__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_mem__DOT__gen_array__DOT__reg_rd_data[0U] 
                                             >> 3U)) 
                                      ^ vlSelfRef.tb_axi_bridge__DOT__prev_dst_ar[2U])) 
                                  | vlSelfRef.tb_axi_bridge__DOT__prev_dst_ar[3U]) 
                                 | vlSelfRef.tb_axi_bridge__DOT__prev_dst_ar[4U]) 
                                | vlSelfRef.tb_axi_bridge__DOT__prev_dst_ar[5U]) 
                               | vlSelfRef.tb_axi_bridge__DOT__prev_dst_ar[6U]) 
                              | vlSelfRef.tb_axi_bridge__DOT__prev_dst_ar[7U]) 
                             | vlSelfRef.tb_axi_bridge__DOT__prev_dst_ar[8U]) 
                            | vlSelfRef.tb_axi_bridge__DOT__prev_dst_ar[9U]) 
                           | vlSelfRef.tb_axi_bridge__DOT__prev_dst_ar[10U]) 
                          | vlSelfRef.tb_axi_bridge__DOT__prev_dst_ar[11U]) 
                         | vlSelfRef.tb_axi_bridge__DOT__prev_dst_ar[12U]) 
                        | vlSelfRef.tb_axi_bridge__DOT__prev_dst_ar[13U]) 
                       | vlSelfRef.tb_axi_bridge__DOT__prev_dst_ar[14U]) 
                      | vlSelfRef.tb_axi_bridge__DOT__prev_dst_ar[15U]));
        __Vtask_tb_axi_bridge__DOT__chk__antecedent_85 
            = vlSelfRef.tb_axi_bridge__DOT__dst_ar_stall;
        __Vtask_tb_axi_bridge__DOT__chk__check_id_84 = 0x00000018U;
        if (__Vtask_tb_axi_bridge__DOT__chk__antecedent_85) {
            if (VL_LIKELY(((0x23U >= (0x0000003fU & __Vtask_tb_axi_bridge__DOT__chk__check_id_84))))) {
                vlSelfRef.tb_axi_bridge__DOT__assertion_hits[(0x0000003fU 
                                                              & __Vtask_tb_axi_bridge__DOT__chk__check_id_84)] 
                    = ((IData)(1U) + ((0x23U >= (0x0000003fU 
                                                 & __Vtask_tb_axi_bridge__DOT__chk__check_id_84))
                                       ? vlSelfRef.tb_axi_bridge__DOT__assertion_hits
                                      [(0x0000003fU 
                                        & __Vtask_tb_axi_bridge__DOT__chk__check_id_84)]
                                       : 0U));
            }
            if (VL_UNLIKELY(((1U & (~ (IData)(__Vtask_tb_axi_bridge__DOT__chk__consequent_86)))))) {
                if (VL_LIKELY(((0x23U >= (0x0000003fU 
                                          & __Vtask_tb_axi_bridge__DOT__chk__check_id_84))))) {
                    vlSelfRef.tb_axi_bridge__DOT__assertion_fails[(0x0000003fU 
                                                                   & __Vtask_tb_axi_bridge__DOT__chk__check_id_84)] 
                        = ((IData)(1U) + ((0x23U >= 
                                           (0x0000003fU 
                                            & __Vtask_tb_axi_bridge__DOT__chk__check_id_84))
                                           ? vlSelfRef.tb_axi_bridge__DOT__assertion_fails
                                          [(0x0000003fU 
                                            & __Vtask_tb_axi_bridge__DOT__chk__check_id_84)]
                                           : 0U));
                }
                VL_WRITEF_NX("ASSERT FAIL AXI-SVA-%02d time=%0t\n",3, 'T',-9
                             , '~',32,__Vtask_tb_axi_bridge__DOT__chk__check_id_84
                             , '#',64,VL_TIME_UNITED_Q(1000));
            }
        }
        __Vtask_tb_axi_bridge__DOT__chk__consequent_89 = 1U;
        __Vtask_tb_axi_bridge__DOT__chk__antecedent_88 
            = vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_ar__DOT__o_axi_arvalid;
        __Vtask_tb_axi_bridge__DOT__chk__check_id_87 = 0x0000001bU;
        if (__Vtask_tb_axi_bridge__DOT__chk__antecedent_88) {
            if (VL_LIKELY(((0x23U >= (0x0000003fU & __Vtask_tb_axi_bridge__DOT__chk__check_id_87))))) {
                vlSelfRef.tb_axi_bridge__DOT__assertion_hits[(0x0000003fU 
                                                              & __Vtask_tb_axi_bridge__DOT__chk__check_id_87)] 
                    = ((IData)(1U) + ((0x23U >= (0x0000003fU 
                                                 & __Vtask_tb_axi_bridge__DOT__chk__check_id_87))
                                       ? vlSelfRef.tb_axi_bridge__DOT__assertion_hits
                                      [(0x0000003fU 
                                        & __Vtask_tb_axi_bridge__DOT__chk__check_id_87)]
                                       : 0U));
            }
            if (VL_UNLIKELY(((1U & (~ (IData)(__Vtask_tb_axi_bridge__DOT__chk__consequent_89)))))) {
                if (VL_LIKELY(((0x23U >= (0x0000003fU 
                                          & __Vtask_tb_axi_bridge__DOT__chk__check_id_87))))) {
                    vlSelfRef.tb_axi_bridge__DOT__assertion_fails[(0x0000003fU 
                                                                   & __Vtask_tb_axi_bridge__DOT__chk__check_id_87)] 
                        = ((IData)(1U) + ((0x23U >= 
                                           (0x0000003fU 
                                            & __Vtask_tb_axi_bridge__DOT__chk__check_id_87))
                                           ? vlSelfRef.tb_axi_bridge__DOT__assertion_fails
                                          [(0x0000003fU 
                                            & __Vtask_tb_axi_bridge__DOT__chk__check_id_87)]
                                           : 0U));
                }
                VL_WRITEF_NX("ASSERT FAIL AXI-SVA-%02d time=%0t\n",3, 'T',-9
                             , '~',32,__Vtask_tb_axi_bridge__DOT__chk__check_id_87
                             , '#',64,VL_TIME_UNITED_Q(1000));
            }
        }
        if (((IData)(vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_ar__DOT__o_axi_arvalid) 
             & (IData)(vlSelfRef.tb_axi_bridge__DOT__i_axi_arready))) {
            __Vtemp_50[0U] = (IData)((((QData)((IData)(
                                                       ((vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_ar__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_mem__DOT__gen_array__DOT__reg_rd_data[1U] 
                                                         << 0x0000001cU) 
                                                        | (vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_ar__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_mem__DOT__gen_array__DOT__reg_rd_data[0U] 
                                                           >> 4U)))) 
                                       << 0x0000001dU) 
                                      | (QData)((IData)(
                                                        ((((0x00003fc0U 
                                                            & (vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_ar__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_mem__DOT__gen_array__DOT__reg_rd_data[1U] 
                                                               << 2U)) 
                                                           | ((0x00000038U 
                                                               & (vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_ar__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_mem__DOT__gen_array__DOT__reg_rd_data[1U] 
                                                                  >> 9U)) 
                                                              | ((6U 
                                                                  & (vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_ar__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_mem__DOT__gen_array__DOT__reg_rd_data[1U] 
                                                                     >> 0x0000000eU)) 
                                                                 | (1U 
                                                                    & (vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_ar__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_mem__DOT__gen_array__DOT__reg_rd_data[1U] 
                                                                       >> 0x00000011U))))) 
                                                          << 0x0000000fU) 
                                                         | ((((0x00000078U 
                                                               & (vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_ar__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_mem__DOT__gen_array__DOT__reg_rd_data[1U] 
                                                                  >> 0x0000000fU)) 
                                                              | (7U 
                                                                 & (vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_ar__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_mem__DOT__gen_array__DOT__reg_rd_data[1U] 
                                                                    >> 0x00000016U))) 
                                                             << 8U) 
                                                            | ((0x000000f0U 
                                                                & (vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_ar__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_mem__DOT__gen_array__DOT__reg_rd_data[1U] 
                                                                   >> 0x00000015U)) 
                                                               | (0x0000000fU 
                                                                  & ((vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_ar__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_mem__DOT__gen_array__DOT__reg_rd_data[2U] 
                                                                      << 3U) 
                                                                     | (vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_ar__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_mem__DOT__gen_array__DOT__reg_rd_data[1U] 
                                                                        >> 0x0000001dU))))))))));
            __Vtemp_50[1U] = ((vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_ar__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_mem__DOT__gen_array__DOT__reg_rd_data[0U] 
                               << 0x0000001dU) | (IData)(
                                                         ((((QData)((IData)(
                                                                            ((vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_ar__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_mem__DOT__gen_array__DOT__reg_rd_data[1U] 
                                                                              << 0x0000001cU) 
                                                                             | (vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_ar__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_mem__DOT__gen_array__DOT__reg_rd_data[0U] 
                                                                                >> 4U)))) 
                                                            << 0x0000001dU) 
                                                           | (QData)((IData)(
                                                                             ((((0x00003fc0U 
                                                                                & (vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_ar__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_mem__DOT__gen_array__DOT__reg_rd_data[1U] 
                                                                                << 2U)) 
                                                                                | ((0x00000038U 
                                                                                & (vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_ar__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_mem__DOT__gen_array__DOT__reg_rd_data[1U] 
                                                                                >> 9U)) 
                                                                                | ((6U 
                                                                                & (vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_ar__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_mem__DOT__gen_array__DOT__reg_rd_data[1U] 
                                                                                >> 0x0000000eU)) 
                                                                                | (1U 
                                                                                & (vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_ar__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_mem__DOT__gen_array__DOT__reg_rd_data[1U] 
                                                                                >> 0x00000011U))))) 
                                                                               << 0x0000000fU) 
                                                                              | ((((0x00000078U 
                                                                                & (vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_ar__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_mem__DOT__gen_array__DOT__reg_rd_data[1U] 
                                                                                >> 0x0000000fU)) 
                                                                                | (7U 
                                                                                & (vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_ar__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_mem__DOT__gen_array__DOT__reg_rd_data[1U] 
                                                                                >> 0x00000016U))) 
                                                                                << 8U) 
                                                                                | ((0x000000f0U 
                                                                                & (vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_ar__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_mem__DOT__gen_array__DOT__reg_rd_data[1U] 
                                                                                >> 0x00000015U)) 
                                                                                | (0x0000000fU 
                                                                                & ((vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_ar__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_mem__DOT__gen_array__DOT__reg_rd_data[2U] 
                                                                                << 3U) 
                                                                                | (vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_ar__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_mem__DOT__gen_array__DOT__reg_rd_data[1U] 
                                                                                >> 0x0000001dU))))))))) 
                                                          >> 0x00000020U)));
            __Vtask_tb_axi_bridge__DOT__chk__consequent_92 
                = (VL_LTS_III(32, vlSelfRef.tb_axi_bridge__DOT__ar_head, vlSelfRef.tb_axi_bridge__DOT__ar_tail) 
                   & (0U == ((((((((((((((((__Vtemp_50[0U] 
                                            ^ vlSelfRef.tb_axi_bridge__DOT__exp_ar
                                            [(0x000000ffU 
                                              & vlSelfRef.tb_axi_bridge__DOT__ar_head)][0U]) 
                                           | (__Vtemp_50[1U] 
                                              ^ vlSelfRef.tb_axi_bridge__DOT__exp_ar
                                              [(0x000000ffU 
                                                & vlSelfRef.tb_axi_bridge__DOT__ar_head)][1U])) 
                                          | ((1U & 
                                              (vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_ar__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_mem__DOT__gen_array__DOT__reg_rd_data[0U] 
                                               >> 3U)) 
                                             ^ vlSelfRef.tb_axi_bridge__DOT__exp_ar
                                             [(0x000000ffU 
                                               & vlSelfRef.tb_axi_bridge__DOT__ar_head)][2U])) 
                                         | vlSelfRef.tb_axi_bridge__DOT__exp_ar
                                         [(0x000000ffU 
                                           & vlSelfRef.tb_axi_bridge__DOT__ar_head)][3U]) 
                                        | vlSelfRef.tb_axi_bridge__DOT__exp_ar
                                        [(0x000000ffU 
                                          & vlSelfRef.tb_axi_bridge__DOT__ar_head)][4U]) 
                                       | vlSelfRef.tb_axi_bridge__DOT__exp_ar
                                       [(0x000000ffU 
                                         & vlSelfRef.tb_axi_bridge__DOT__ar_head)][5U]) 
                                      | vlSelfRef.tb_axi_bridge__DOT__exp_ar
                                      [(0x000000ffU 
                                        & vlSelfRef.tb_axi_bridge__DOT__ar_head)][6U]) 
                                     | vlSelfRef.tb_axi_bridge__DOT__exp_ar
                                     [(0x000000ffU 
                                       & vlSelfRef.tb_axi_bridge__DOT__ar_head)][7U]) 
                                    | vlSelfRef.tb_axi_bridge__DOT__exp_ar
                                    [(0x000000ffU & vlSelfRef.tb_axi_bridge__DOT__ar_head)][8U]) 
                                   | vlSelfRef.tb_axi_bridge__DOT__exp_ar
                                   [(0x000000ffU & vlSelfRef.tb_axi_bridge__DOT__ar_head)][9U]) 
                                  | vlSelfRef.tb_axi_bridge__DOT__exp_ar
                                  [(0x000000ffU & vlSelfRef.tb_axi_bridge__DOT__ar_head)][10U]) 
                                 | vlSelfRef.tb_axi_bridge__DOT__exp_ar
                                 [(0x000000ffU & vlSelfRef.tb_axi_bridge__DOT__ar_head)][11U]) 
                                | vlSelfRef.tb_axi_bridge__DOT__exp_ar
                                [(0x000000ffU & vlSelfRef.tb_axi_bridge__DOT__ar_head)][12U]) 
                               | vlSelfRef.tb_axi_bridge__DOT__exp_ar
                               [(0x000000ffU & vlSelfRef.tb_axi_bridge__DOT__ar_head)][13U]) 
                              | vlSelfRef.tb_axi_bridge__DOT__exp_ar
                              [(0x000000ffU & vlSelfRef.tb_axi_bridge__DOT__ar_head)][14U]) 
                             | vlSelfRef.tb_axi_bridge__DOT__exp_ar
                             [(0x000000ffU & vlSelfRef.tb_axi_bridge__DOT__ar_head)][15U])));
            __Vtask_tb_axi_bridge__DOT__chk__check_id_90 = 0x00000019U;
            vlSelfRef.tb_axi_bridge__DOT__out_ar = 
                ((IData)(1U) + vlSelfRef.tb_axi_bridge__DOT__out_ar);
            vlSelfRef.tb_axi_bridge__DOT__assertion_hits[(0x0000003fU 
                                                          & __Vtask_tb_axi_bridge__DOT__chk__check_id_90)] 
                = ((IData)(1U) + ((0x23U >= (0x0000003fU 
                                             & __Vtask_tb_axi_bridge__DOT__chk__check_id_90))
                                   ? vlSelfRef.tb_axi_bridge__DOT__assertion_hits
                                  [(0x0000003fU & __Vtask_tb_axi_bridge__DOT__chk__check_id_90)]
                                   : 0U));
            if (VL_UNLIKELY(((1U & (~ (IData)(__Vtask_tb_axi_bridge__DOT__chk__consequent_92)))))) {
                if (VL_LIKELY(((0x23U >= (0x0000003fU 
                                          & __Vtask_tb_axi_bridge__DOT__chk__check_id_90))))) {
                    vlSelfRef.tb_axi_bridge__DOT__assertion_fails[(0x0000003fU 
                                                                   & __Vtask_tb_axi_bridge__DOT__chk__check_id_90)] 
                        = ((IData)(1U) + ((0x23U >= 
                                           (0x0000003fU 
                                            & __Vtask_tb_axi_bridge__DOT__chk__check_id_90))
                                           ? vlSelfRef.tb_axi_bridge__DOT__assertion_fails
                                          [(0x0000003fU 
                                            & __Vtask_tb_axi_bridge__DOT__chk__check_id_90)]
                                           : 0U));
                }
                VL_WRITEF_NX("ASSERT FAIL AXI-SVA-%02d time=%0t\n",3, 'T',-9
                             , '~',32,__Vtask_tb_axi_bridge__DOT__chk__check_id_90
                             , '#',64,VL_TIME_UNITED_Q(1000));
            }
            vlSelfRef.tb_axi_bridge__DOT__ar_head = 
                ((IData)(1U) + vlSelfRef.tb_axi_bridge__DOT__ar_head);
        }
        vlSelfRef.tb_axi_bridge__DOT__dst_ar_stall 
            = ((IData)(vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_ar__DOT__o_axi_arvalid) 
               & (~ (IData)(vlSelfRef.tb_axi_bridge__DOT__i_axi_arready)));
        vlSelfRef.tb_axi_bridge__DOT__prev_dst_ar[0U] 
            = ((0xe0000000U & vlSelfRef.tb_axi_bridge__DOT__prev_dst_ar[0U]) 
               | ((((0x00003fc0U & (vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_ar__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_mem__DOT__gen_array__DOT__reg_rd_data[1U] 
                                    << 2U)) | ((0x00000038U 
                                                & (vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_ar__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_mem__DOT__gen_array__DOT__reg_rd_data[1U] 
                                                   >> 9U)) 
                                               | ((6U 
                                                   & (vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_ar__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_mem__DOT__gen_array__DOT__reg_rd_data[1U] 
                                                      >> 0x0000000eU)) 
                                                  | (1U 
                                                     & (vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_ar__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_mem__DOT__gen_array__DOT__reg_rd_data[1U] 
                                                        >> 0x00000011U))))) 
                   << 0x0000000fU) | ((((0x00000078U 
                                         & (vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_ar__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_mem__DOT__gen_array__DOT__reg_rd_data[1U] 
                                            >> 0x0000000fU)) 
                                        | (7U & (vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_ar__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_mem__DOT__gen_array__DOT__reg_rd_data[1U] 
                                                 >> 0x00000016U))) 
                                       << 8U) | ((0x000000f0U 
                                                  & (vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_ar__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_mem__DOT__gen_array__DOT__reg_rd_data[1U] 
                                                     >> 0x00000015U)) 
                                                 | (0x0000000fU 
                                                    & ((vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_ar__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_mem__DOT__gen_array__DOT__reg_rd_data[2U] 
                                                        << 3U) 
                                                       | (vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_ar__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_mem__DOT__gen_array__DOT__reg_rd_data[1U] 
                                                          >> 0x0000001dU)))))));
        vlSelfRef.tb_axi_bridge__DOT__prev_dst_ar[0U] 
            = ((0x1fffffffU & vlSelfRef.tb_axi_bridge__DOT__prev_dst_ar[0U]) 
               | ((IData)((((QData)((IData)((0x0000000fU 
                                             & vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_ar__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_mem__DOT__gen_array__DOT__reg_rd_data[0U]))) 
                            << 0x00000020U) | (QData)((IData)(
                                                              ((vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_ar__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_mem__DOT__gen_array__DOT__reg_rd_data[1U] 
                                                                << 0x0000001cU) 
                                                               | (vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_ar__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_mem__DOT__gen_array__DOT__reg_rd_data[0U] 
                                                                  >> 4U)))))) 
                  << 0x0000001dU));
        vlSelfRef.tb_axi_bridge__DOT__prev_dst_ar[1U] 
            = (((IData)((((QData)((IData)((0x0000000fU 
                                           & vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_ar__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_mem__DOT__gen_array__DOT__reg_rd_data[0U]))) 
                          << 0x00000020U) | (QData)((IData)(
                                                            ((vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_ar__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_mem__DOT__gen_array__DOT__reg_rd_data[1U] 
                                                              << 0x0000001cU) 
                                                             | (vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_ar__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_mem__DOT__gen_array__DOT__reg_rd_data[0U] 
                                                                >> 4U)))))) 
                >> 3U) | ((IData)(((((QData)((IData)(
                                                     (0x0000000fU 
                                                      & vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_ar__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_mem__DOT__gen_array__DOT__reg_rd_data[0U]))) 
                                     << 0x00000020U) 
                                    | (QData)((IData)(
                                                      ((vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_ar__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_mem__DOT__gen_array__DOT__reg_rd_data[1U] 
                                                        << 0x0000001cU) 
                                                       | (vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_ar__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_mem__DOT__gen_array__DOT__reg_rd_data[0U] 
                                                          >> 4U))))) 
                                   >> 0x00000020U)) 
                          << 0x0000001dU));
        vlSelfRef.tb_axi_bridge__DOT__prev_dst_ar[2U] 
            = ((IData)(((((QData)((IData)((0x0000000fU 
                                           & vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_ar__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_mem__DOT__gen_array__DOT__reg_rd_data[0U]))) 
                          << 0x00000020U) | (QData)((IData)(
                                                            ((vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_ar__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_mem__DOT__gen_array__DOT__reg_rd_data[1U] 
                                                              << 0x0000001cU) 
                                                             | (vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_ar__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_mem__DOT__gen_array__DOT__reg_rd_data[0U] 
                                                                >> 4U))))) 
                        >> 0x00000020U)) >> 3U);
        vlSelfRef.tb_axi_bridge__DOT__prev_dst_ar[3U] = 0U;
        vlSelfRef.tb_axi_bridge__DOT__prev_dst_ar[4U] = 0U;
        vlSelfRef.tb_axi_bridge__DOT__prev_dst_ar[5U] = 0U;
        vlSelfRef.tb_axi_bridge__DOT__prev_dst_ar[6U] = 0U;
        vlSelfRef.tb_axi_bridge__DOT__prev_dst_ar[7U] = 0U;
        vlSelfRef.tb_axi_bridge__DOT__prev_dst_ar[8U] = 0U;
        vlSelfRef.tb_axi_bridge__DOT__prev_dst_ar[9U] = 0U;
        vlSelfRef.tb_axi_bridge__DOT__prev_dst_ar[10U] = 0U;
        vlSelfRef.tb_axi_bridge__DOT__prev_dst_ar[11U] = 0U;
        vlSelfRef.tb_axi_bridge__DOT__prev_dst_ar[12U] = 0U;
        vlSelfRef.tb_axi_bridge__DOT__prev_dst_ar[13U] = 0U;
        vlSelfRef.tb_axi_bridge__DOT__prev_dst_ar[14U] = 0U;
        vlSelfRef.tb_axi_bridge__DOT__prev_dst_ar[15U] = 0U;
    } else {
        vlSelfRef.tb_axi_bridge__DOT__src_b_stall = 0U;
        vlSelfRef.tb_axi_bridge__DOT__b_tail = 0U;
        vlSelfRef.tb_axi_bridge__DOT__src_r_stall = 0U;
        vlSelfRef.tb_axi_bridge__DOT__r_tail = 0U;
        __Vtask_tb_axi_bridge__DOT__chk__consequent_23 
            = (1U & (~ (((((IData)(vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_aw__DOT__o_axi_awvalid) 
                           | (IData)(vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_w__DOT__o_axi_wvalid)) 
                          | (IData)(vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_ar__DOT__o_axi_arvalid)) 
                         | (IData)(vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_b__DOT__o_axi_bvalid)) 
                        | (IData)(vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_r__DOT__o_axi_rvalid))));
        vlSelfRef.tb_axi_bridge__DOT__dst_aw_stall = 0U;
        vlSelfRef.tb_axi_bridge__DOT__aw_head = 0U;
        vlSelfRef.tb_axi_bridge__DOT__out_aw = 0U;
        __Vtask_tb_axi_bridge__DOT__chk__check_id_21 = 0x00000023U;
        vlSelfRef.tb_axi_bridge__DOT__assertion_hits[(0x0000003fU 
                                                      & __Vtask_tb_axi_bridge__DOT__chk__check_id_21)] 
            = ((IData)(1U) + ((0x23U >= (0x0000003fU 
                                         & __Vtask_tb_axi_bridge__DOT__chk__check_id_21))
                               ? vlSelfRef.tb_axi_bridge__DOT__assertion_hits
                              [(0x0000003fU & __Vtask_tb_axi_bridge__DOT__chk__check_id_21)]
                               : 0U));
        if (VL_UNLIKELY(((1U & (~ (IData)(__Vtask_tb_axi_bridge__DOT__chk__consequent_23)))))) {
            if (VL_LIKELY(((0x23U >= (0x0000003fU & __Vtask_tb_axi_bridge__DOT__chk__check_id_21))))) {
                vlSelfRef.tb_axi_bridge__DOT__assertion_fails[(0x0000003fU 
                                                               & __Vtask_tb_axi_bridge__DOT__chk__check_id_21)] 
                    = ((IData)(1U) + ((0x23U >= (0x0000003fU 
                                                 & __Vtask_tb_axi_bridge__DOT__chk__check_id_21))
                                       ? vlSelfRef.tb_axi_bridge__DOT__assertion_fails
                                      [(0x0000003fU 
                                        & __Vtask_tb_axi_bridge__DOT__chk__check_id_21)]
                                       : 0U));
            }
            VL_WRITEF_NX("ASSERT FAIL AXI-SVA-%02d time=%0t\n",3, 'T',-9
                         , '~',32,__Vtask_tb_axi_bridge__DOT__chk__check_id_21
                         , '#',64,VL_TIME_UNITED_Q(1000));
        }
        __Vtask_tb_axi_bridge__DOT__chk__consequent_47 
            = (1U & (~ (((((IData)(vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_aw__DOT__o_axi_awvalid) 
                           | (IData)(vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_w__DOT__o_axi_wvalid)) 
                          | (IData)(vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_ar__DOT__o_axi_arvalid)) 
                         | (IData)(vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_b__DOT__o_axi_bvalid)) 
                        | (IData)(vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_r__DOT__o_axi_rvalid))));
        vlSelfRef.tb_axi_bridge__DOT__dst_w_stall = 0U;
        vlSelfRef.tb_axi_bridge__DOT__w_head = 0U;
        vlSelfRef.tb_axi_bridge__DOT__out_w = 0U;
        __Vtask_tb_axi_bridge__DOT__chk__check_id_45 = 0x00000023U;
        vlSelfRef.tb_axi_bridge__DOT__assertion_hits[(0x0000003fU 
                                                      & __Vtask_tb_axi_bridge__DOT__chk__check_id_45)] 
            = ((IData)(1U) + ((0x23U >= (0x0000003fU 
                                         & __Vtask_tb_axi_bridge__DOT__chk__check_id_45))
                               ? vlSelfRef.tb_axi_bridge__DOT__assertion_hits
                              [(0x0000003fU & __Vtask_tb_axi_bridge__DOT__chk__check_id_45)]
                               : 0U));
        if (VL_UNLIKELY(((1U & (~ (IData)(__Vtask_tb_axi_bridge__DOT__chk__consequent_47)))))) {
            if (VL_LIKELY(((0x23U >= (0x0000003fU & __Vtask_tb_axi_bridge__DOT__chk__check_id_45))))) {
                vlSelfRef.tb_axi_bridge__DOT__assertion_fails[(0x0000003fU 
                                                               & __Vtask_tb_axi_bridge__DOT__chk__check_id_45)] 
                    = ((IData)(1U) + ((0x23U >= (0x0000003fU 
                                                 & __Vtask_tb_axi_bridge__DOT__chk__check_id_45))
                                       ? vlSelfRef.tb_axi_bridge__DOT__assertion_fails
                                      [(0x0000003fU 
                                        & __Vtask_tb_axi_bridge__DOT__chk__check_id_45)]
                                       : 0U));
            }
            VL_WRITEF_NX("ASSERT FAIL AXI-SVA-%02d time=%0t\n",3, 'T',-9
                         , '~',32,__Vtask_tb_axi_bridge__DOT__chk__check_id_45
                         , '#',64,VL_TIME_UNITED_Q(1000));
        }
        __Vtask_tb_axi_bridge__DOT__chk__consequent_95 
            = (1U & (~ (((((IData)(vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_aw__DOT__o_axi_awvalid) 
                           | (IData)(vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_w__DOT__o_axi_wvalid)) 
                          | (IData)(vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_ar__DOT__o_axi_arvalid)) 
                         | (IData)(vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_b__DOT__o_axi_bvalid)) 
                        | (IData)(vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_r__DOT__o_axi_rvalid))));
        vlSelfRef.tb_axi_bridge__DOT__dst_ar_stall = 0U;
        vlSelfRef.tb_axi_bridge__DOT__ar_head = 0U;
        vlSelfRef.tb_axi_bridge__DOT__out_ar = 0U;
        __Vtask_tb_axi_bridge__DOT__chk__check_id_93 = 0x00000023U;
        vlSelfRef.tb_axi_bridge__DOT__assertion_hits[(0x0000003fU 
                                                      & __Vtask_tb_axi_bridge__DOT__chk__check_id_93)] 
            = ((IData)(1U) + ((0x23U >= (0x0000003fU 
                                         & __Vtask_tb_axi_bridge__DOT__chk__check_id_93))
                               ? vlSelfRef.tb_axi_bridge__DOT__assertion_hits
                              [(0x0000003fU & __Vtask_tb_axi_bridge__DOT__chk__check_id_93)]
                               : 0U));
        if (VL_UNLIKELY(((1U & (~ (IData)(__Vtask_tb_axi_bridge__DOT__chk__consequent_95)))))) {
            if (VL_LIKELY(((0x23U >= (0x0000003fU & __Vtask_tb_axi_bridge__DOT__chk__check_id_93))))) {
                vlSelfRef.tb_axi_bridge__DOT__assertion_fails[(0x0000003fU 
                                                               & __Vtask_tb_axi_bridge__DOT__chk__check_id_93)] 
                    = ((IData)(1U) + ((0x23U >= (0x0000003fU 
                                                 & __Vtask_tb_axi_bridge__DOT__chk__check_id_93))
                                       ? vlSelfRef.tb_axi_bridge__DOT__assertion_fails
                                      [(0x0000003fU 
                                        & __Vtask_tb_axi_bridge__DOT__chk__check_id_93)]
                                       : 0U));
            }
            VL_WRITEF_NX("ASSERT FAIL AXI-SVA-%02d time=%0t\n",3, 'T',-9
                         , '~',32,__Vtask_tb_axi_bridge__DOT__chk__check_id_93
                         , '#',64,VL_TIME_UNITED_Q(1000));
        }
    }
    if (vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_b__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__o_mem_wr_en) {
        vlSelfRef.__Vdly_Val__tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_b__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_mem__DOT__gen_array__DOT__reg_mem_110 
            = (((IData)(vlSelfRef.tb_axi_bridge__DOT__i_axi_bresp) 
                << 4U) | (IData)(vlSelfRef.tb_axi_bridge__DOT__i_axi_bid));
        vlSelfRef.__Vdly_Dim0__tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_b__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_mem__DOT__gen_array__DOT__reg_mem_111 
            = (3U & (IData)(vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_b__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__reg_wbin));
        vlSelfRef.__Vdly_Set__tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_b__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_mem__DOT__gen_array__DOT__reg_mem_112 = 1U;
    }
    if (vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_r__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__o_mem_wr_en) {
        vlSelfRef.__Vdly_Val__tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_r__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_mem__DOT__gen_array__DOT__reg_mem_107 
            = (((QData)((IData)((((IData)(vlSelfRef.tb_axi_bridge__DOT__i_axi_rlast) 
                                  << 2U) | (IData)(vlSelfRef.tb_axi_bridge__DOT__i_axi_rresp)))) 
                << 0x00000024U) | (((QData)((IData)(vlSelfRef.tb_axi_bridge__DOT__i_axi_rdata)) 
                                    << 4U) | (QData)((IData)(vlSelfRef.tb_axi_bridge__DOT__i_axi_rid))));
        vlSelfRef.__Vdly_Dim0__tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_r__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_mem__DOT__gen_array__DOT__reg_mem_108 
            = (0x0000000fU & (IData)(vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_r__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__reg_wbin));
        vlSelfRef.__Vdly_Set__tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_r__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_mem__DOT__gen_array__DOT__reg_mem_109 = 1U;
    }
    vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_aw__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_mem__DOT__gen_array__DOT__reg_rd_data[0U] 
        = vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_aw__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_mem__DOT__gen_array__DOT__reg_mem
        [(3U & (IData)(vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_aw__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_rd__DOT__w_rbin_nxt))][0U];
    vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_aw__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_mem__DOT__gen_array__DOT__reg_rd_data[1U] 
        = vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_aw__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_mem__DOT__gen_array__DOT__reg_mem
        [(3U & (IData)(vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_aw__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_rd__DOT__w_rbin_nxt))][1U];
    vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_aw__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_mem__DOT__gen_array__DOT__reg_rd_data[2U] 
        = vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_aw__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_mem__DOT__gen_array__DOT__reg_mem
        [(3U & (IData)(vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_aw__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_rd__DOT__w_rbin_nxt))][2U];
    vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_w__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_mem__DOT__gen_array__DOT__reg_rd_data 
        = vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_w__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_mem__DOT__gen_array__DOT__reg_mem
        [(0x0000000fU & (IData)(vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_w__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_rd__DOT__w_rbin_nxt))];
    vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_ar__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_mem__DOT__gen_array__DOT__reg_rd_data[0U] 
        = vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_ar__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_mem__DOT__gen_array__DOT__reg_mem
        [(3U & (IData)(vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_ar__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_rd__DOT__w_rbin_nxt))][0U];
    vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_ar__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_mem__DOT__gen_array__DOT__reg_rd_data[1U] 
        = vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_ar__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_mem__DOT__gen_array__DOT__reg_mem
        [(3U & (IData)(vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_ar__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_rd__DOT__w_rbin_nxt))][1U];
    vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_ar__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_mem__DOT__gen_array__DOT__reg_rd_data[2U] 
        = vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_ar__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_mem__DOT__gen_array__DOT__reg_mem
        [(3U & (IData)(vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_ar__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_rd__DOT__w_rbin_nxt))][2U];
}

void Vtb_axi_bridge___024root___nba_sequent__TOP__3(Vtb_axi_bridge___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_axi_bridge___024root___nba_sequent__TOP__3\n"); );
    Vtb_axi_bridge__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Locals
    IData/*31:0*/ __Vtask_tb_axi_bridge__DOT__chk__check_id_0;
    __Vtask_tb_axi_bridge__DOT__chk__check_id_0 = 0;
    CData/*0:0*/ __Vtask_tb_axi_bridge__DOT__chk__antecedent_1;
    __Vtask_tb_axi_bridge__DOT__chk__antecedent_1 = 0;
    CData/*0:0*/ __Vtask_tb_axi_bridge__DOT__chk__consequent_2;
    __Vtask_tb_axi_bridge__DOT__chk__consequent_2 = 0;
    IData/*31:0*/ __Vtask_tb_axi_bridge__DOT__chk__check_id_3;
    __Vtask_tb_axi_bridge__DOT__chk__check_id_3 = 0;
    CData/*0:0*/ __Vtask_tb_axi_bridge__DOT__chk__antecedent_4;
    __Vtask_tb_axi_bridge__DOT__chk__antecedent_4 = 0;
    CData/*0:0*/ __Vtask_tb_axi_bridge__DOT__chk__consequent_5;
    __Vtask_tb_axi_bridge__DOT__chk__consequent_5 = 0;
    IData/*31:0*/ __Vtask_tb_axi_bridge__DOT__chk__check_id_6;
    __Vtask_tb_axi_bridge__DOT__chk__check_id_6 = 0;
    CData/*0:0*/ __Vtask_tb_axi_bridge__DOT__chk__antecedent_7;
    __Vtask_tb_axi_bridge__DOT__chk__antecedent_7 = 0;
    CData/*0:0*/ __Vtask_tb_axi_bridge__DOT__chk__consequent_8;
    __Vtask_tb_axi_bridge__DOT__chk__consequent_8 = 0;
    IData/*31:0*/ __Vtask_tb_axi_bridge__DOT__chk__check_id_24;
    __Vtask_tb_axi_bridge__DOT__chk__check_id_24 = 0;
    CData/*0:0*/ __Vtask_tb_axi_bridge__DOT__chk__antecedent_25;
    __Vtask_tb_axi_bridge__DOT__chk__antecedent_25 = 0;
    CData/*0:0*/ __Vtask_tb_axi_bridge__DOT__chk__consequent_26;
    __Vtask_tb_axi_bridge__DOT__chk__consequent_26 = 0;
    IData/*31:0*/ __Vtask_tb_axi_bridge__DOT__chk__check_id_27;
    __Vtask_tb_axi_bridge__DOT__chk__check_id_27 = 0;
    CData/*0:0*/ __Vtask_tb_axi_bridge__DOT__chk__antecedent_28;
    __Vtask_tb_axi_bridge__DOT__chk__antecedent_28 = 0;
    CData/*0:0*/ __Vtask_tb_axi_bridge__DOT__chk__consequent_29;
    __Vtask_tb_axi_bridge__DOT__chk__consequent_29 = 0;
    IData/*31:0*/ __Vtask_tb_axi_bridge__DOT__chk__check_id_30;
    __Vtask_tb_axi_bridge__DOT__chk__check_id_30 = 0;
    CData/*0:0*/ __Vtask_tb_axi_bridge__DOT__chk__antecedent_31;
    __Vtask_tb_axi_bridge__DOT__chk__antecedent_31 = 0;
    CData/*0:0*/ __Vtask_tb_axi_bridge__DOT__chk__consequent_32;
    __Vtask_tb_axi_bridge__DOT__chk__consequent_32 = 0;
    IData/*31:0*/ __Vtask_tb_axi_bridge__DOT__chk__check_id_57;
    __Vtask_tb_axi_bridge__DOT__chk__check_id_57 = 0;
    CData/*0:0*/ __Vtask_tb_axi_bridge__DOT__chk__antecedent_58;
    __Vtask_tb_axi_bridge__DOT__chk__antecedent_58 = 0;
    CData/*0:0*/ __Vtask_tb_axi_bridge__DOT__chk__consequent_59;
    __Vtask_tb_axi_bridge__DOT__chk__consequent_59 = 0;
    IData/*31:0*/ __Vtask_tb_axi_bridge__DOT__chk__check_id_60;
    __Vtask_tb_axi_bridge__DOT__chk__check_id_60 = 0;
    CData/*0:0*/ __Vtask_tb_axi_bridge__DOT__chk__antecedent_61;
    __Vtask_tb_axi_bridge__DOT__chk__antecedent_61 = 0;
    CData/*0:0*/ __Vtask_tb_axi_bridge__DOT__chk__consequent_62;
    __Vtask_tb_axi_bridge__DOT__chk__consequent_62 = 0;
    IData/*31:0*/ __Vtask_tb_axi_bridge__DOT__chk__check_id_63;
    __Vtask_tb_axi_bridge__DOT__chk__check_id_63 = 0;
    CData/*0:0*/ __Vtask_tb_axi_bridge__DOT__chk__antecedent_64;
    __Vtask_tb_axi_bridge__DOT__chk__antecedent_64 = 0;
    CData/*0:0*/ __Vtask_tb_axi_bridge__DOT__chk__consequent_65;
    __Vtask_tb_axi_bridge__DOT__chk__consequent_65 = 0;
    IData/*31:0*/ __Vtask_tb_axi_bridge__DOT__chk__check_id_66;
    __Vtask_tb_axi_bridge__DOT__chk__check_id_66 = 0;
    CData/*0:0*/ __Vtask_tb_axi_bridge__DOT__chk__consequent_68;
    __Vtask_tb_axi_bridge__DOT__chk__consequent_68 = 0;
    IData/*31:0*/ __Vtask_tb_axi_bridge__DOT__chk__check_id_69;
    __Vtask_tb_axi_bridge__DOT__chk__check_id_69 = 0;
    CData/*0:0*/ __Vtask_tb_axi_bridge__DOT__chk__consequent_71;
    __Vtask_tb_axi_bridge__DOT__chk__consequent_71 = 0;
    IData/*31:0*/ __Vtask_tb_axi_bridge__DOT__chk__check_id_72;
    __Vtask_tb_axi_bridge__DOT__chk__check_id_72 = 0;
    CData/*0:0*/ __Vtask_tb_axi_bridge__DOT__chk__antecedent_73;
    __Vtask_tb_axi_bridge__DOT__chk__antecedent_73 = 0;
    CData/*0:0*/ __Vtask_tb_axi_bridge__DOT__chk__consequent_74;
    __Vtask_tb_axi_bridge__DOT__chk__consequent_74 = 0;
    IData/*31:0*/ __Vtask_tb_axi_bridge__DOT__chk__check_id_75;
    __Vtask_tb_axi_bridge__DOT__chk__check_id_75 = 0;
    CData/*0:0*/ __Vtask_tb_axi_bridge__DOT__chk__antecedent_76;
    __Vtask_tb_axi_bridge__DOT__chk__antecedent_76 = 0;
    CData/*0:0*/ __Vtask_tb_axi_bridge__DOT__chk__consequent_77;
    __Vtask_tb_axi_bridge__DOT__chk__consequent_77 = 0;
    IData/*31:0*/ __Vtask_tb_axi_bridge__DOT__chk__check_id_78;
    __Vtask_tb_axi_bridge__DOT__chk__check_id_78 = 0;
    CData/*0:0*/ __Vtask_tb_axi_bridge__DOT__chk__antecedent_79;
    __Vtask_tb_axi_bridge__DOT__chk__antecedent_79 = 0;
    CData/*0:0*/ __Vtask_tb_axi_bridge__DOT__chk__consequent_80;
    __Vtask_tb_axi_bridge__DOT__chk__consequent_80 = 0;
    IData/*31:0*/ __Vtask_tb_axi_bridge__DOT__chk__check_id_105;
    __Vtask_tb_axi_bridge__DOT__chk__check_id_105 = 0;
    CData/*0:0*/ __Vtask_tb_axi_bridge__DOT__chk__antecedent_106;
    __Vtask_tb_axi_bridge__DOT__chk__antecedent_106 = 0;
    CData/*0:0*/ __Vtask_tb_axi_bridge__DOT__chk__consequent_107;
    __Vtask_tb_axi_bridge__DOT__chk__consequent_107 = 0;
    IData/*31:0*/ __Vtask_tb_axi_bridge__DOT__chk__check_id_108;
    __Vtask_tb_axi_bridge__DOT__chk__check_id_108 = 0;
    CData/*0:0*/ __Vtask_tb_axi_bridge__DOT__chk__antecedent_109;
    __Vtask_tb_axi_bridge__DOT__chk__antecedent_109 = 0;
    CData/*0:0*/ __Vtask_tb_axi_bridge__DOT__chk__consequent_110;
    __Vtask_tb_axi_bridge__DOT__chk__consequent_110 = 0;
    IData/*31:0*/ __Vtask_tb_axi_bridge__DOT__chk__check_id_111;
    __Vtask_tb_axi_bridge__DOT__chk__check_id_111 = 0;
    CData/*0:0*/ __Vtask_tb_axi_bridge__DOT__chk__antecedent_112;
    __Vtask_tb_axi_bridge__DOT__chk__antecedent_112 = 0;
    CData/*0:0*/ __Vtask_tb_axi_bridge__DOT__chk__consequent_113;
    __Vtask_tb_axi_bridge__DOT__chk__consequent_113 = 0;
    IData/*31:0*/ __Vtask_tb_axi_bridge__DOT__chk__check_id_114;
    __Vtask_tb_axi_bridge__DOT__chk__check_id_114 = 0;
    CData/*0:0*/ __Vtask_tb_axi_bridge__DOT__chk__consequent_116;
    __Vtask_tb_axi_bridge__DOT__chk__consequent_116 = 0;
    IData/*31:0*/ __Vtask_tb_axi_bridge__DOT__chk__check_id_117;
    __Vtask_tb_axi_bridge__DOT__chk__check_id_117 = 0;
    CData/*0:0*/ __Vtask_tb_axi_bridge__DOT__chk__consequent_119;
    __Vtask_tb_axi_bridge__DOT__chk__consequent_119 = 0;
    QData/*36:0*/ __Vdly_Val__tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_w__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_mem__DOT__gen_array__DOT__reg_mem_98;
    __Vdly_Val__tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_w__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_mem__DOT__gen_array__DOT__reg_mem_98 = 0;
    CData/*3:0*/ __Vdly_Dim0__tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_w__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_mem__DOT__gen_array__DOT__reg_mem_99;
    __Vdly_Dim0__tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_w__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_mem__DOT__gen_array__DOT__reg_mem_99 = 0;
    CData/*0:0*/ __Vdly_Set__tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_w__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_mem__DOT__gen_array__DOT__reg_mem_100;
    __Vdly_Set__tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_w__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_mem__DOT__gen_array__DOT__reg_mem_100 = 0;
    VlWide<3>/*64:0*/ __Vdly_Val__tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_ar__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_mem__DOT__gen_array__DOT__reg_mem_101;
    VL_ZERO_W(65, __Vdly_Val__tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_ar__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_mem__DOT__gen_array__DOT__reg_mem_101);
    CData/*1:0*/ __Vdly_Dim0__tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_ar__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_mem__DOT__gen_array__DOT__reg_mem_102;
    __Vdly_Dim0__tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_ar__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_mem__DOT__gen_array__DOT__reg_mem_102 = 0;
    CData/*0:0*/ __Vdly_Set__tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_ar__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_mem__DOT__gen_array__DOT__reg_mem_103;
    __Vdly_Set__tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_ar__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_mem__DOT__gen_array__DOT__reg_mem_103 = 0;
    VlWide<3>/*64:0*/ __Vdly_Val__tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_aw__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_mem__DOT__gen_array__DOT__reg_mem_104;
    VL_ZERO_W(65, __Vdly_Val__tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_aw__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_mem__DOT__gen_array__DOT__reg_mem_104);
    CData/*1:0*/ __Vdly_Dim0__tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_aw__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_mem__DOT__gen_array__DOT__reg_mem_105;
    __Vdly_Dim0__tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_aw__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_mem__DOT__gen_array__DOT__reg_mem_105 = 0;
    CData/*0:0*/ __Vdly_Set__tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_aw__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_mem__DOT__gen_array__DOT__reg_mem_106;
    __Vdly_Set__tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_aw__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_mem__DOT__gen_array__DOT__reg_mem_106 = 0;
    // Body
    __Vdly_Set__tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_w__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_mem__DOT__gen_array__DOT__reg_mem_100 = 0U;
    __Vdly_Set__tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_ar__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_mem__DOT__gen_array__DOT__reg_mem_103 = 0U;
    __Vdly_Set__tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_aw__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_mem__DOT__gen_array__DOT__reg_mem_106 = 0U;
    if (vlSelfRef.tb_axi_bridge__DOT__i_rst_n_sub) {
        __Vtask_tb_axi_bridge__DOT__chk__consequent_26 
            = vlSelfRef.tb_axi_bridge__DOT__i_axi_wvalid;
        __Vtask_tb_axi_bridge__DOT__chk__antecedent_25 
            = vlSelfRef.tb_axi_bridge__DOT__src_w_stall;
        if (((IData)(vlSelfRef.tb_axi_bridge__DOT__i_axi_wvalid) 
             & (IData)(vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_w__DOT__o_axi_wready))) {
            vlSelfRef.tb_axi_bridge__DOT__exp_w[(0x000000ffU 
                                                 & vlSelfRef.tb_axi_bridge__DOT__w_tail)][0U] 
                = ((0xffffffe0U & vlSelfRef.tb_axi_bridge__DOT__exp_w
                    [(0x000000ffU & vlSelfRef.tb_axi_bridge__DOT__w_tail)][0U]) 
                   | (((IData)(vlSelfRef.tb_axi_bridge__DOT__i_axi_wstrb) 
                       << 1U) | (IData)(vlSelfRef.tb_axi_bridge__DOT__i_axi_wlast)));
            vlSelfRef.tb_axi_bridge__DOT__exp_w[(0x000000ffU 
                                                 & vlSelfRef.tb_axi_bridge__DOT__w_tail)][0U] 
                = ((0x0000001fU & vlSelfRef.tb_axi_bridge__DOT__exp_w
                    [(0x000000ffU & vlSelfRef.tb_axi_bridge__DOT__w_tail)][0U]) 
                   | (vlSelfRef.tb_axi_bridge__DOT__i_axi_wdata 
                      << 5U));
            vlSelfRef.tb_axi_bridge__DOT__exp_w[(0x000000ffU 
                                                 & vlSelfRef.tb_axi_bridge__DOT__w_tail)][1U] 
                = ((0xffffffe0U & vlSelfRef.tb_axi_bridge__DOT__exp_w
                    [(0x000000ffU & vlSelfRef.tb_axi_bridge__DOT__w_tail)][1U]) 
                   | (vlSelfRef.tb_axi_bridge__DOT__i_axi_wdata 
                      >> 0x0000001bU));
            vlSelfRef.tb_axi_bridge__DOT__exp_w[(0x000000ffU 
                                                 & vlSelfRef.tb_axi_bridge__DOT__w_tail)][1U] 
                = (0x0000001fU & vlSelfRef.tb_axi_bridge__DOT__exp_w
                   [(0x000000ffU & vlSelfRef.tb_axi_bridge__DOT__w_tail)][1U]);
            vlSelfRef.tb_axi_bridge__DOT__exp_w[(0x000000ffU 
                                                 & vlSelfRef.tb_axi_bridge__DOT__w_tail)][2U] = 0U;
            vlSelfRef.tb_axi_bridge__DOT__exp_w[(0x000000ffU 
                                                 & vlSelfRef.tb_axi_bridge__DOT__w_tail)][3U] = 0U;
            vlSelfRef.tb_axi_bridge__DOT__exp_w[(0x000000ffU 
                                                 & vlSelfRef.tb_axi_bridge__DOT__w_tail)][4U] = 0U;
            vlSelfRef.tb_axi_bridge__DOT__exp_w[(0x000000ffU 
                                                 & vlSelfRef.tb_axi_bridge__DOT__w_tail)][5U] = 0U;
            vlSelfRef.tb_axi_bridge__DOT__exp_w[(0x000000ffU 
                                                 & vlSelfRef.tb_axi_bridge__DOT__w_tail)][6U] = 0U;
            vlSelfRef.tb_axi_bridge__DOT__exp_w[(0x000000ffU 
                                                 & vlSelfRef.tb_axi_bridge__DOT__w_tail)][7U] = 0U;
            vlSelfRef.tb_axi_bridge__DOT__exp_w[(0x000000ffU 
                                                 & vlSelfRef.tb_axi_bridge__DOT__w_tail)][8U] = 0U;
            vlSelfRef.tb_axi_bridge__DOT__exp_w[(0x000000ffU 
                                                 & vlSelfRef.tb_axi_bridge__DOT__w_tail)][9U] = 0U;
            vlSelfRef.tb_axi_bridge__DOT__exp_w[(0x000000ffU 
                                                 & vlSelfRef.tb_axi_bridge__DOT__w_tail)][10U] = 0U;
            vlSelfRef.tb_axi_bridge__DOT__exp_w[(0x000000ffU 
                                                 & vlSelfRef.tb_axi_bridge__DOT__w_tail)][11U] = 0U;
            vlSelfRef.tb_axi_bridge__DOT__exp_w[(0x000000ffU 
                                                 & vlSelfRef.tb_axi_bridge__DOT__w_tail)][12U] = 0U;
            vlSelfRef.tb_axi_bridge__DOT__exp_w[(0x000000ffU 
                                                 & vlSelfRef.tb_axi_bridge__DOT__w_tail)][13U] = 0U;
            vlSelfRef.tb_axi_bridge__DOT__exp_w[(0x000000ffU 
                                                 & vlSelfRef.tb_axi_bridge__DOT__w_tail)][14U] = 0U;
            vlSelfRef.tb_axi_bridge__DOT__exp_w[(0x000000ffU 
                                                 & vlSelfRef.tb_axi_bridge__DOT__w_tail)][15U] = 0U;
            vlSelfRef.tb_axi_bridge__DOT__w_tail = 
                ((IData)(1U) + vlSelfRef.tb_axi_bridge__DOT__w_tail);
        }
        __Vtask_tb_axi_bridge__DOT__chk__check_id_24 = 7U;
        if (__Vtask_tb_axi_bridge__DOT__chk__antecedent_25) {
            if (VL_LIKELY(((0x23U >= (0x0000003fU & __Vtask_tb_axi_bridge__DOT__chk__check_id_24))))) {
                vlSelfRef.tb_axi_bridge__DOT__assertion_hits[(0x0000003fU 
                                                              & __Vtask_tb_axi_bridge__DOT__chk__check_id_24)] 
                    = ((IData)(1U) + ((0x23U >= (0x0000003fU 
                                                 & __Vtask_tb_axi_bridge__DOT__chk__check_id_24))
                                       ? vlSelfRef.tb_axi_bridge__DOT__assertion_hits
                                      [(0x0000003fU 
                                        & __Vtask_tb_axi_bridge__DOT__chk__check_id_24)]
                                       : 0U));
            }
            if (VL_UNLIKELY(((1U & (~ (IData)(__Vtask_tb_axi_bridge__DOT__chk__consequent_26)))))) {
                if (VL_LIKELY(((0x23U >= (0x0000003fU 
                                          & __Vtask_tb_axi_bridge__DOT__chk__check_id_24))))) {
                    vlSelfRef.tb_axi_bridge__DOT__assertion_fails[(0x0000003fU 
                                                                   & __Vtask_tb_axi_bridge__DOT__chk__check_id_24)] 
                        = ((IData)(1U) + ((0x23U >= 
                                           (0x0000003fU 
                                            & __Vtask_tb_axi_bridge__DOT__chk__check_id_24))
                                           ? vlSelfRef.tb_axi_bridge__DOT__assertion_fails
                                          [(0x0000003fU 
                                            & __Vtask_tb_axi_bridge__DOT__chk__check_id_24)]
                                           : 0U));
                }
                VL_WRITEF_NX("ASSERT FAIL AXI-SVA-%02d time=%0t\n",3, 'T',-9
                             , '~',32,__Vtask_tb_axi_bridge__DOT__chk__check_id_24
                             , '#',64,VL_TIME_UNITED_Q(1000));
            }
        }
        __Vtask_tb_axi_bridge__DOT__chk__consequent_29 
            = (0U == (((((((((((((((((IData)((((QData)((IData)(vlSelfRef.tb_axi_bridge__DOT__i_axi_wdata)) 
                                               << 5U) 
                                              | (QData)((IData)(
                                                                (((IData)(vlSelfRef.tb_axi_bridge__DOT__i_axi_wstrb) 
                                                                  << 1U) 
                                                                 | (IData)(vlSelfRef.tb_axi_bridge__DOT__i_axi_wlast)))))) 
                                     ^ vlSelfRef.tb_axi_bridge__DOT__prev_src_w[0U]) 
                                    | ((IData)(((((QData)((IData)(vlSelfRef.tb_axi_bridge__DOT__i_axi_wdata)) 
                                                  << 5U) 
                                                 | (QData)((IData)(
                                                                   (((IData)(vlSelfRef.tb_axi_bridge__DOT__i_axi_wstrb) 
                                                                     << 1U) 
                                                                    | (IData)(vlSelfRef.tb_axi_bridge__DOT__i_axi_wlast))))) 
                                                >> 0x00000020U)) 
                                       ^ vlSelfRef.tb_axi_bridge__DOT__prev_src_w[1U])) 
                                   | vlSelfRef.tb_axi_bridge__DOT__prev_src_w[2U]) 
                                  | vlSelfRef.tb_axi_bridge__DOT__prev_src_w[3U]) 
                                 | vlSelfRef.tb_axi_bridge__DOT__prev_src_w[4U]) 
                                | vlSelfRef.tb_axi_bridge__DOT__prev_src_w[5U]) 
                               | vlSelfRef.tb_axi_bridge__DOT__prev_src_w[6U]) 
                              | vlSelfRef.tb_axi_bridge__DOT__prev_src_w[7U]) 
                             | vlSelfRef.tb_axi_bridge__DOT__prev_src_w[8U]) 
                            | vlSelfRef.tb_axi_bridge__DOT__prev_src_w[9U]) 
                           | vlSelfRef.tb_axi_bridge__DOT__prev_src_w[10U]) 
                          | vlSelfRef.tb_axi_bridge__DOT__prev_src_w[11U]) 
                         | vlSelfRef.tb_axi_bridge__DOT__prev_src_w[12U]) 
                        | vlSelfRef.tb_axi_bridge__DOT__prev_src_w[13U]) 
                       | vlSelfRef.tb_axi_bridge__DOT__prev_src_w[14U]) 
                      | vlSelfRef.tb_axi_bridge__DOT__prev_src_w[15U]));
        __Vtask_tb_axi_bridge__DOT__chk__antecedent_28 
            = vlSelfRef.tb_axi_bridge__DOT__src_w_stall;
        __Vtask_tb_axi_bridge__DOT__chk__check_id_27 = 8U;
        if (__Vtask_tb_axi_bridge__DOT__chk__antecedent_28) {
            if (VL_LIKELY(((0x23U >= (0x0000003fU & __Vtask_tb_axi_bridge__DOT__chk__check_id_27))))) {
                vlSelfRef.tb_axi_bridge__DOT__assertion_hits[(0x0000003fU 
                                                              & __Vtask_tb_axi_bridge__DOT__chk__check_id_27)] 
                    = ((IData)(1U) + ((0x23U >= (0x0000003fU 
                                                 & __Vtask_tb_axi_bridge__DOT__chk__check_id_27))
                                       ? vlSelfRef.tb_axi_bridge__DOT__assertion_hits
                                      [(0x0000003fU 
                                        & __Vtask_tb_axi_bridge__DOT__chk__check_id_27)]
                                       : 0U));
            }
            if (VL_UNLIKELY(((1U & (~ (IData)(__Vtask_tb_axi_bridge__DOT__chk__consequent_29)))))) {
                if (VL_LIKELY(((0x23U >= (0x0000003fU 
                                          & __Vtask_tb_axi_bridge__DOT__chk__check_id_27))))) {
                    vlSelfRef.tb_axi_bridge__DOT__assertion_fails[(0x0000003fU 
                                                                   & __Vtask_tb_axi_bridge__DOT__chk__check_id_27)] 
                        = ((IData)(1U) + ((0x23U >= 
                                           (0x0000003fU 
                                            & __Vtask_tb_axi_bridge__DOT__chk__check_id_27))
                                           ? vlSelfRef.tb_axi_bridge__DOT__assertion_fails
                                          [(0x0000003fU 
                                            & __Vtask_tb_axi_bridge__DOT__chk__check_id_27)]
                                           : 0U));
                }
                VL_WRITEF_NX("ASSERT FAIL AXI-SVA-%02d time=%0t\n",3, 'T',-9
                             , '~',32,__Vtask_tb_axi_bridge__DOT__chk__check_id_27
                             , '#',64,VL_TIME_UNITED_Q(1000));
            }
        }
        __Vtask_tb_axi_bridge__DOT__chk__consequent_32 = 1U;
        __Vtask_tb_axi_bridge__DOT__chk__antecedent_31 
            = vlSelfRef.tb_axi_bridge__DOT__i_axi_wvalid;
        __Vtask_tb_axi_bridge__DOT__chk__check_id_30 = 0x0000000cU;
        if (__Vtask_tb_axi_bridge__DOT__chk__antecedent_31) {
            if (VL_LIKELY(((0x23U >= (0x0000003fU & __Vtask_tb_axi_bridge__DOT__chk__check_id_30))))) {
                vlSelfRef.tb_axi_bridge__DOT__assertion_hits[(0x0000003fU 
                                                              & __Vtask_tb_axi_bridge__DOT__chk__check_id_30)] 
                    = ((IData)(1U) + ((0x23U >= (0x0000003fU 
                                                 & __Vtask_tb_axi_bridge__DOT__chk__check_id_30))
                                       ? vlSelfRef.tb_axi_bridge__DOT__assertion_hits
                                      [(0x0000003fU 
                                        & __Vtask_tb_axi_bridge__DOT__chk__check_id_30)]
                                       : 0U));
            }
            if (VL_UNLIKELY(((1U & (~ (IData)(__Vtask_tb_axi_bridge__DOT__chk__consequent_32)))))) {
                if (VL_LIKELY(((0x23U >= (0x0000003fU 
                                          & __Vtask_tb_axi_bridge__DOT__chk__check_id_30))))) {
                    vlSelfRef.tb_axi_bridge__DOT__assertion_fails[(0x0000003fU 
                                                                   & __Vtask_tb_axi_bridge__DOT__chk__check_id_30)] 
                        = ((IData)(1U) + ((0x23U >= 
                                           (0x0000003fU 
                                            & __Vtask_tb_axi_bridge__DOT__chk__check_id_30))
                                           ? vlSelfRef.tb_axi_bridge__DOT__assertion_fails
                                          [(0x0000003fU 
                                            & __Vtask_tb_axi_bridge__DOT__chk__check_id_30)]
                                           : 0U));
                }
                VL_WRITEF_NX("ASSERT FAIL AXI-SVA-%02d time=%0t\n",3, 'T',-9
                             , '~',32,__Vtask_tb_axi_bridge__DOT__chk__check_id_30
                             , '#',64,VL_TIME_UNITED_Q(1000));
            }
        }
        vlSelfRef.tb_axi_bridge__DOT__src_w_stall = 
            ((IData)(vlSelfRef.tb_axi_bridge__DOT__i_axi_wvalid) 
             & (~ (IData)(vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_w__DOT__o_axi_wready)));
        vlSelfRef.tb_axi_bridge__DOT__prev_src_w[0U] 
            = (IData)((((QData)((IData)(vlSelfRef.tb_axi_bridge__DOT__i_axi_wdata)) 
                        << 5U) | (QData)((IData)((((IData)(vlSelfRef.tb_axi_bridge__DOT__i_axi_wstrb) 
                                                   << 1U) 
                                                  | (IData)(vlSelfRef.tb_axi_bridge__DOT__i_axi_wlast))))));
        vlSelfRef.tb_axi_bridge__DOT__prev_src_w[1U] 
            = (IData)(((((QData)((IData)(vlSelfRef.tb_axi_bridge__DOT__i_axi_wdata)) 
                         << 5U) | (QData)((IData)((
                                                   ((IData)(vlSelfRef.tb_axi_bridge__DOT__i_axi_wstrb) 
                                                    << 1U) 
                                                   | (IData)(vlSelfRef.tb_axi_bridge__DOT__i_axi_wlast))))) 
                       >> 0x00000020U));
        vlSelfRef.tb_axi_bridge__DOT__prev_src_w[2U] = 0U;
        vlSelfRef.tb_axi_bridge__DOT__prev_src_w[3U] = 0U;
        vlSelfRef.tb_axi_bridge__DOT__prev_src_w[4U] = 0U;
        vlSelfRef.tb_axi_bridge__DOT__prev_src_w[5U] = 0U;
        vlSelfRef.tb_axi_bridge__DOT__prev_src_w[6U] = 0U;
        vlSelfRef.tb_axi_bridge__DOT__prev_src_w[7U] = 0U;
        vlSelfRef.tb_axi_bridge__DOT__prev_src_w[8U] = 0U;
        vlSelfRef.tb_axi_bridge__DOT__prev_src_w[9U] = 0U;
        vlSelfRef.tb_axi_bridge__DOT__prev_src_w[10U] = 0U;
        vlSelfRef.tb_axi_bridge__DOT__prev_src_w[11U] = 0U;
        vlSelfRef.tb_axi_bridge__DOT__prev_src_w[12U] = 0U;
        vlSelfRef.tb_axi_bridge__DOT__prev_src_w[13U] = 0U;
        vlSelfRef.tb_axi_bridge__DOT__prev_src_w[14U] = 0U;
        vlSelfRef.tb_axi_bridge__DOT__prev_src_w[15U] = 0U;
        __Vtask_tb_axi_bridge__DOT__chk__consequent_2 
            = vlSelfRef.tb_axi_bridge__DOT__i_axi_awvalid;
        __Vtask_tb_axi_bridge__DOT__chk__antecedent_1 
            = vlSelfRef.tb_axi_bridge__DOT__src_aw_stall;
        if (((IData)(vlSelfRef.tb_axi_bridge__DOT__i_axi_awvalid) 
             & (IData)(vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_aw__DOT__o_axi_awready))) {
            vlSelfRef.tb_axi_bridge__DOT__exp_aw[(0x000000ffU 
                                                  & vlSelfRef.tb_axi_bridge__DOT__aw_tail)][0U] 
                = ((0xe0000000U & vlSelfRef.tb_axi_bridge__DOT__exp_aw
                    [(0x000000ffU & vlSelfRef.tb_axi_bridge__DOT__aw_tail)][0U]) 
                   | ((((IData)(vlSelfRef.tb_axi_bridge__DOT__i_axi_awlen) 
                        << 0x00000015U) | (((IData)(vlSelfRef.tb_axi_bridge__DOT__i_axi_awsize) 
                                            << 0x00000012U) 
                                           | (((IData)(vlSelfRef.tb_axi_bridge__DOT__i_axi_awburst) 
                                               << 0x00000010U) 
                                              | ((IData)(vlSelfRef.tb_axi_bridge__DOT__i_axi_awlock) 
                                                 << 0x0000000fU)))) 
                      | ((((IData)(vlSelfRef.tb_axi_bridge__DOT__i_axi_awcache) 
                           << 0x0000000bU) | ((IData)(vlSelfRef.tb_axi_bridge__DOT__i_axi_awprot) 
                                              << 8U)) 
                         | (((IData)(vlSelfRef.tb_axi_bridge__DOT__i_axi_awqos) 
                             << 4U) | (IData)(vlSelfRef.tb_axi_bridge__DOT__i_axi_awregion)))));
            vlSelfRef.tb_axi_bridge__DOT__exp_aw[(0x000000ffU 
                                                  & vlSelfRef.tb_axi_bridge__DOT__aw_tail)][0U] 
                = ((0x1fffffffU & vlSelfRef.tb_axi_bridge__DOT__exp_aw
                    [(0x000000ffU & vlSelfRef.tb_axi_bridge__DOT__aw_tail)][0U]) 
                   | (vlSelfRef.tb_axi_bridge__DOT__i_axi_awaddr 
                      << 0x0000001dU));
            vlSelfRef.tb_axi_bridge__DOT__exp_aw[(0x000000ffU 
                                                  & vlSelfRef.tb_axi_bridge__DOT__aw_tail)][1U] 
                = ((0xe0000000U & vlSelfRef.tb_axi_bridge__DOT__exp_aw
                    [(0x000000ffU & vlSelfRef.tb_axi_bridge__DOT__aw_tail)][1U]) 
                   | (vlSelfRef.tb_axi_bridge__DOT__i_axi_awaddr 
                      >> 3U));
            vlSelfRef.tb_axi_bridge__DOT__exp_aw[(0x000000ffU 
                                                  & vlSelfRef.tb_axi_bridge__DOT__aw_tail)][1U] 
                = ((0x1fffffffU & vlSelfRef.tb_axi_bridge__DOT__exp_aw
                    [(0x000000ffU & vlSelfRef.tb_axi_bridge__DOT__aw_tail)][1U]) 
                   | ((IData)(vlSelfRef.tb_axi_bridge__DOT__i_axi_awid) 
                      << 0x0000001dU));
            vlSelfRef.tb_axi_bridge__DOT__exp_aw[(0x000000ffU 
                                                  & vlSelfRef.tb_axi_bridge__DOT__aw_tail)][2U] 
                = ((0xfffffffeU & vlSelfRef.tb_axi_bridge__DOT__exp_aw
                    [(0x000000ffU & vlSelfRef.tb_axi_bridge__DOT__aw_tail)][2U]) 
                   | ((IData)(vlSelfRef.tb_axi_bridge__DOT__i_axi_awid) 
                      >> 3U));
            vlSelfRef.tb_axi_bridge__DOT__exp_aw[(0x000000ffU 
                                                  & vlSelfRef.tb_axi_bridge__DOT__aw_tail)][2U] 
                = (1U & vlSelfRef.tb_axi_bridge__DOT__exp_aw
                   [(0x000000ffU & vlSelfRef.tb_axi_bridge__DOT__aw_tail)][2U]);
            vlSelfRef.tb_axi_bridge__DOT__exp_aw[(0x000000ffU 
                                                  & vlSelfRef.tb_axi_bridge__DOT__aw_tail)][3U] = 0U;
            vlSelfRef.tb_axi_bridge__DOT__exp_aw[(0x000000ffU 
                                                  & vlSelfRef.tb_axi_bridge__DOT__aw_tail)][4U] = 0U;
            vlSelfRef.tb_axi_bridge__DOT__exp_aw[(0x000000ffU 
                                                  & vlSelfRef.tb_axi_bridge__DOT__aw_tail)][5U] = 0U;
            vlSelfRef.tb_axi_bridge__DOT__exp_aw[(0x000000ffU 
                                                  & vlSelfRef.tb_axi_bridge__DOT__aw_tail)][6U] = 0U;
            vlSelfRef.tb_axi_bridge__DOT__exp_aw[(0x000000ffU 
                                                  & vlSelfRef.tb_axi_bridge__DOT__aw_tail)][7U] = 0U;
            vlSelfRef.tb_axi_bridge__DOT__exp_aw[(0x000000ffU 
                                                  & vlSelfRef.tb_axi_bridge__DOT__aw_tail)][8U] = 0U;
            vlSelfRef.tb_axi_bridge__DOT__exp_aw[(0x000000ffU 
                                                  & vlSelfRef.tb_axi_bridge__DOT__aw_tail)][9U] = 0U;
            vlSelfRef.tb_axi_bridge__DOT__exp_aw[(0x000000ffU 
                                                  & vlSelfRef.tb_axi_bridge__DOT__aw_tail)][10U] = 0U;
            vlSelfRef.tb_axi_bridge__DOT__exp_aw[(0x000000ffU 
                                                  & vlSelfRef.tb_axi_bridge__DOT__aw_tail)][11U] = 0U;
            vlSelfRef.tb_axi_bridge__DOT__exp_aw[(0x000000ffU 
                                                  & vlSelfRef.tb_axi_bridge__DOT__aw_tail)][12U] = 0U;
            vlSelfRef.tb_axi_bridge__DOT__exp_aw[(0x000000ffU 
                                                  & vlSelfRef.tb_axi_bridge__DOT__aw_tail)][13U] = 0U;
            vlSelfRef.tb_axi_bridge__DOT__exp_aw[(0x000000ffU 
                                                  & vlSelfRef.tb_axi_bridge__DOT__aw_tail)][14U] = 0U;
            vlSelfRef.tb_axi_bridge__DOT__exp_aw[(0x000000ffU 
                                                  & vlSelfRef.tb_axi_bridge__DOT__aw_tail)][15U] = 0U;
            vlSelfRef.tb_axi_bridge__DOT__aw_tail = 
                ((IData)(1U) + vlSelfRef.tb_axi_bridge__DOT__aw_tail);
        }
        __Vtask_tb_axi_bridge__DOT__chk__check_id_0 = 0U;
        if (__Vtask_tb_axi_bridge__DOT__chk__antecedent_1) {
            if (VL_LIKELY(((0x23U >= (0x0000003fU & __Vtask_tb_axi_bridge__DOT__chk__check_id_0))))) {
                vlSelfRef.tb_axi_bridge__DOT__assertion_hits[(0x0000003fU 
                                                              & __Vtask_tb_axi_bridge__DOT__chk__check_id_0)] 
                    = ((IData)(1U) + ((0x23U >= (0x0000003fU 
                                                 & __Vtask_tb_axi_bridge__DOT__chk__check_id_0))
                                       ? vlSelfRef.tb_axi_bridge__DOT__assertion_hits
                                      [(0x0000003fU 
                                        & __Vtask_tb_axi_bridge__DOT__chk__check_id_0)]
                                       : 0U));
            }
            if (VL_UNLIKELY(((1U & (~ (IData)(__Vtask_tb_axi_bridge__DOT__chk__consequent_2)))))) {
                if (VL_LIKELY(((0x23U >= (0x0000003fU 
                                          & __Vtask_tb_axi_bridge__DOT__chk__check_id_0))))) {
                    vlSelfRef.tb_axi_bridge__DOT__assertion_fails[(0x0000003fU 
                                                                   & __Vtask_tb_axi_bridge__DOT__chk__check_id_0)] 
                        = ((IData)(1U) + ((0x23U >= 
                                           (0x0000003fU 
                                            & __Vtask_tb_axi_bridge__DOT__chk__check_id_0))
                                           ? vlSelfRef.tb_axi_bridge__DOT__assertion_fails
                                          [(0x0000003fU 
                                            & __Vtask_tb_axi_bridge__DOT__chk__check_id_0)]
                                           : 0U));
                }
                VL_WRITEF_NX("ASSERT FAIL AXI-SVA-%02d time=%0t\n",3, 'T',-9
                             , '~',32,__Vtask_tb_axi_bridge__DOT__chk__check_id_0
                             , '#',64,VL_TIME_UNITED_Q(1000));
            }
        }
        __Vtask_tb_axi_bridge__DOT__chk__consequent_5 
            = (0U == (((((((((((((((((IData)((((QData)((IData)(vlSelfRef.tb_axi_bridge__DOT__i_axi_awaddr)) 
                                               << 0x0000001dU) 
                                              | (QData)((IData)(
                                                                ((((IData)(vlSelfRef.tb_axi_bridge__DOT__i_axi_awlen) 
                                                                   << 0x00000015U) 
                                                                  | (((IData)(vlSelfRef.tb_axi_bridge__DOT__i_axi_awsize) 
                                                                      << 0x00000012U) 
                                                                     | (((IData)(vlSelfRef.tb_axi_bridge__DOT__i_axi_awburst) 
                                                                         << 0x00000010U) 
                                                                        | ((IData)(vlSelfRef.tb_axi_bridge__DOT__i_axi_awlock) 
                                                                           << 0x0000000fU)))) 
                                                                 | ((((IData)(vlSelfRef.tb_axi_bridge__DOT__i_axi_awcache) 
                                                                      << 0x0000000bU) 
                                                                     | ((IData)(vlSelfRef.tb_axi_bridge__DOT__i_axi_awprot) 
                                                                        << 8U)) 
                                                                    | (((IData)(vlSelfRef.tb_axi_bridge__DOT__i_axi_awqos) 
                                                                        << 4U) 
                                                                       | (IData)(vlSelfRef.tb_axi_bridge__DOT__i_axi_awregion)))))))) 
                                     ^ vlSelfRef.tb_axi_bridge__DOT__prev_src_aw[0U]) 
                                    | ((((IData)(vlSelfRef.tb_axi_bridge__DOT__i_axi_awid) 
                                         << 0x0000001dU) 
                                        | (IData)((
                                                   (((QData)((IData)(vlSelfRef.tb_axi_bridge__DOT__i_axi_awaddr)) 
                                                     << 0x0000001dU) 
                                                    | (QData)((IData)(
                                                                      ((((IData)(vlSelfRef.tb_axi_bridge__DOT__i_axi_awlen) 
                                                                         << 0x00000015U) 
                                                                        | (((IData)(vlSelfRef.tb_axi_bridge__DOT__i_axi_awsize) 
                                                                            << 0x00000012U) 
                                                                           | (((IData)(vlSelfRef.tb_axi_bridge__DOT__i_axi_awburst) 
                                                                               << 0x00000010U) 
                                                                              | ((IData)(vlSelfRef.tb_axi_bridge__DOT__i_axi_awlock) 
                                                                                << 0x0000000fU)))) 
                                                                       | ((((IData)(vlSelfRef.tb_axi_bridge__DOT__i_axi_awcache) 
                                                                            << 0x0000000bU) 
                                                                           | ((IData)(vlSelfRef.tb_axi_bridge__DOT__i_axi_awprot) 
                                                                              << 8U)) 
                                                                          | (((IData)(vlSelfRef.tb_axi_bridge__DOT__i_axi_awqos) 
                                                                              << 4U) 
                                                                             | (IData)(vlSelfRef.tb_axi_bridge__DOT__i_axi_awregion))))))) 
                                                   >> 0x00000020U))) 
                                       ^ vlSelfRef.tb_axi_bridge__DOT__prev_src_aw[1U])) 
                                   | (((IData)(vlSelfRef.tb_axi_bridge__DOT__i_axi_awid) 
                                       >> 3U) ^ vlSelfRef.tb_axi_bridge__DOT__prev_src_aw[2U])) 
                                  | vlSelfRef.tb_axi_bridge__DOT__prev_src_aw[3U]) 
                                 | vlSelfRef.tb_axi_bridge__DOT__prev_src_aw[4U]) 
                                | vlSelfRef.tb_axi_bridge__DOT__prev_src_aw[5U]) 
                               | vlSelfRef.tb_axi_bridge__DOT__prev_src_aw[6U]) 
                              | vlSelfRef.tb_axi_bridge__DOT__prev_src_aw[7U]) 
                             | vlSelfRef.tb_axi_bridge__DOT__prev_src_aw[8U]) 
                            | vlSelfRef.tb_axi_bridge__DOT__prev_src_aw[9U]) 
                           | vlSelfRef.tb_axi_bridge__DOT__prev_src_aw[10U]) 
                          | vlSelfRef.tb_axi_bridge__DOT__prev_src_aw[11U]) 
                         | vlSelfRef.tb_axi_bridge__DOT__prev_src_aw[12U]) 
                        | vlSelfRef.tb_axi_bridge__DOT__prev_src_aw[13U]) 
                       | vlSelfRef.tb_axi_bridge__DOT__prev_src_aw[14U]) 
                      | vlSelfRef.tb_axi_bridge__DOT__prev_src_aw[15U]));
        __Vtask_tb_axi_bridge__DOT__chk__antecedent_4 
            = vlSelfRef.tb_axi_bridge__DOT__src_aw_stall;
        __Vtask_tb_axi_bridge__DOT__chk__check_id_3 = 1U;
        if (__Vtask_tb_axi_bridge__DOT__chk__antecedent_4) {
            if (VL_LIKELY(((0x23U >= (0x0000003fU & __Vtask_tb_axi_bridge__DOT__chk__check_id_3))))) {
                vlSelfRef.tb_axi_bridge__DOT__assertion_hits[(0x0000003fU 
                                                              & __Vtask_tb_axi_bridge__DOT__chk__check_id_3)] 
                    = ((IData)(1U) + ((0x23U >= (0x0000003fU 
                                                 & __Vtask_tb_axi_bridge__DOT__chk__check_id_3))
                                       ? vlSelfRef.tb_axi_bridge__DOT__assertion_hits
                                      [(0x0000003fU 
                                        & __Vtask_tb_axi_bridge__DOT__chk__check_id_3)]
                                       : 0U));
            }
            if (VL_UNLIKELY(((1U & (~ (IData)(__Vtask_tb_axi_bridge__DOT__chk__consequent_5)))))) {
                if (VL_LIKELY(((0x23U >= (0x0000003fU 
                                          & __Vtask_tb_axi_bridge__DOT__chk__check_id_3))))) {
                    vlSelfRef.tb_axi_bridge__DOT__assertion_fails[(0x0000003fU 
                                                                   & __Vtask_tb_axi_bridge__DOT__chk__check_id_3)] 
                        = ((IData)(1U) + ((0x23U >= 
                                           (0x0000003fU 
                                            & __Vtask_tb_axi_bridge__DOT__chk__check_id_3))
                                           ? vlSelfRef.tb_axi_bridge__DOT__assertion_fails
                                          [(0x0000003fU 
                                            & __Vtask_tb_axi_bridge__DOT__chk__check_id_3)]
                                           : 0U));
                }
                VL_WRITEF_NX("ASSERT FAIL AXI-SVA-%02d time=%0t\n",3, 'T',-9
                             , '~',32,__Vtask_tb_axi_bridge__DOT__chk__check_id_3
                             , '#',64,VL_TIME_UNITED_Q(1000));
            }
        }
        __Vtask_tb_axi_bridge__DOT__chk__consequent_8 = 1U;
        __Vtask_tb_axi_bridge__DOT__chk__antecedent_7 
            = vlSelfRef.tb_axi_bridge__DOT__i_axi_awvalid;
        __Vtask_tb_axi_bridge__DOT__chk__check_id_6 = 5U;
        if (__Vtask_tb_axi_bridge__DOT__chk__antecedent_7) {
            if (VL_LIKELY(((0x23U >= (0x0000003fU & __Vtask_tb_axi_bridge__DOT__chk__check_id_6))))) {
                vlSelfRef.tb_axi_bridge__DOT__assertion_hits[(0x0000003fU 
                                                              & __Vtask_tb_axi_bridge__DOT__chk__check_id_6)] 
                    = ((IData)(1U) + ((0x23U >= (0x0000003fU 
                                                 & __Vtask_tb_axi_bridge__DOT__chk__check_id_6))
                                       ? vlSelfRef.tb_axi_bridge__DOT__assertion_hits
                                      [(0x0000003fU 
                                        & __Vtask_tb_axi_bridge__DOT__chk__check_id_6)]
                                       : 0U));
            }
            if (VL_UNLIKELY(((1U & (~ (IData)(__Vtask_tb_axi_bridge__DOT__chk__consequent_8)))))) {
                if (VL_LIKELY(((0x23U >= (0x0000003fU 
                                          & __Vtask_tb_axi_bridge__DOT__chk__check_id_6))))) {
                    vlSelfRef.tb_axi_bridge__DOT__assertion_fails[(0x0000003fU 
                                                                   & __Vtask_tb_axi_bridge__DOT__chk__check_id_6)] 
                        = ((IData)(1U) + ((0x23U >= 
                                           (0x0000003fU 
                                            & __Vtask_tb_axi_bridge__DOT__chk__check_id_6))
                                           ? vlSelfRef.tb_axi_bridge__DOT__assertion_fails
                                          [(0x0000003fU 
                                            & __Vtask_tb_axi_bridge__DOT__chk__check_id_6)]
                                           : 0U));
                }
                VL_WRITEF_NX("ASSERT FAIL AXI-SVA-%02d time=%0t\n",3, 'T',-9
                             , '~',32,__Vtask_tb_axi_bridge__DOT__chk__check_id_6
                             , '#',64,VL_TIME_UNITED_Q(1000));
            }
        }
        vlSelfRef.tb_axi_bridge__DOT__src_aw_stall 
            = ((IData)(vlSelfRef.tb_axi_bridge__DOT__i_axi_awvalid) 
               & (~ (IData)(vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_aw__DOT__o_axi_awready)));
        vlSelfRef.tb_axi_bridge__DOT__prev_src_aw[0U] 
            = ((0xe0000000U & vlSelfRef.tb_axi_bridge__DOT__prev_src_aw[0U]) 
               | ((((IData)(vlSelfRef.tb_axi_bridge__DOT__i_axi_awlen) 
                    << 0x00000015U) | (((IData)(vlSelfRef.tb_axi_bridge__DOT__i_axi_awsize) 
                                        << 0x00000012U) 
                                       | (((IData)(vlSelfRef.tb_axi_bridge__DOT__i_axi_awburst) 
                                           << 0x00000010U) 
                                          | ((IData)(vlSelfRef.tb_axi_bridge__DOT__i_axi_awlock) 
                                             << 0x0000000fU)))) 
                  | ((((IData)(vlSelfRef.tb_axi_bridge__DOT__i_axi_awcache) 
                       << 0x0000000bU) | ((IData)(vlSelfRef.tb_axi_bridge__DOT__i_axi_awprot) 
                                          << 8U)) | 
                     (((IData)(vlSelfRef.tb_axi_bridge__DOT__i_axi_awqos) 
                       << 4U) | (IData)(vlSelfRef.tb_axi_bridge__DOT__i_axi_awregion)))));
        vlSelfRef.tb_axi_bridge__DOT__prev_src_aw[0U] 
            = ((0x1fffffffU & vlSelfRef.tb_axi_bridge__DOT__prev_src_aw[0U]) 
               | ((IData)((((QData)((IData)(vlSelfRef.tb_axi_bridge__DOT__i_axi_awid)) 
                            << 0x00000020U) | (QData)((IData)(vlSelfRef.tb_axi_bridge__DOT__i_axi_awaddr)))) 
                  << 0x0000001dU));
        vlSelfRef.tb_axi_bridge__DOT__prev_src_aw[1U] 
            = (((IData)((((QData)((IData)(vlSelfRef.tb_axi_bridge__DOT__i_axi_awid)) 
                          << 0x00000020U) | (QData)((IData)(vlSelfRef.tb_axi_bridge__DOT__i_axi_awaddr)))) 
                >> 3U) | ((IData)(((((QData)((IData)(vlSelfRef.tb_axi_bridge__DOT__i_axi_awid)) 
                                     << 0x00000020U) 
                                    | (QData)((IData)(vlSelfRef.tb_axi_bridge__DOT__i_axi_awaddr))) 
                                   >> 0x00000020U)) 
                          << 0x0000001dU));
        vlSelfRef.tb_axi_bridge__DOT__prev_src_aw[2U] 
            = ((IData)(((((QData)((IData)(vlSelfRef.tb_axi_bridge__DOT__i_axi_awid)) 
                          << 0x00000020U) | (QData)((IData)(vlSelfRef.tb_axi_bridge__DOT__i_axi_awaddr))) 
                        >> 0x00000020U)) >> 3U);
        vlSelfRef.tb_axi_bridge__DOT__prev_src_aw[3U] = 0U;
        vlSelfRef.tb_axi_bridge__DOT__prev_src_aw[4U] = 0U;
        vlSelfRef.tb_axi_bridge__DOT__prev_src_aw[5U] = 0U;
        vlSelfRef.tb_axi_bridge__DOT__prev_src_aw[6U] = 0U;
        vlSelfRef.tb_axi_bridge__DOT__prev_src_aw[7U] = 0U;
        vlSelfRef.tb_axi_bridge__DOT__prev_src_aw[8U] = 0U;
        vlSelfRef.tb_axi_bridge__DOT__prev_src_aw[9U] = 0U;
        vlSelfRef.tb_axi_bridge__DOT__prev_src_aw[10U] = 0U;
        vlSelfRef.tb_axi_bridge__DOT__prev_src_aw[11U] = 0U;
        vlSelfRef.tb_axi_bridge__DOT__prev_src_aw[12U] = 0U;
        vlSelfRef.tb_axi_bridge__DOT__prev_src_aw[13U] = 0U;
        vlSelfRef.tb_axi_bridge__DOT__prev_src_aw[14U] = 0U;
        vlSelfRef.tb_axi_bridge__DOT__prev_src_aw[15U] = 0U;
        __Vtask_tb_axi_bridge__DOT__chk__consequent_74 
            = vlSelfRef.tb_axi_bridge__DOT__i_axi_arvalid;
        __Vtask_tb_axi_bridge__DOT__chk__antecedent_73 
            = vlSelfRef.tb_axi_bridge__DOT__src_ar_stall;
        if (((IData)(vlSelfRef.tb_axi_bridge__DOT__i_axi_arvalid) 
             & (IData)(vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_ar__DOT__o_axi_arready))) {
            vlSelfRef.tb_axi_bridge__DOT__exp_ar[(0x000000ffU 
                                                  & vlSelfRef.tb_axi_bridge__DOT__ar_tail)][0U] 
                = ((0xe0000000U & vlSelfRef.tb_axi_bridge__DOT__exp_ar
                    [(0x000000ffU & vlSelfRef.tb_axi_bridge__DOT__ar_tail)][0U]) 
                   | ((((IData)(vlSelfRef.tb_axi_bridge__DOT__i_axi_arlen) 
                        << 0x00000015U) | (((IData)(vlSelfRef.tb_axi_bridge__DOT__i_axi_arsize) 
                                            << 0x00000012U) 
                                           | (((IData)(vlSelfRef.tb_axi_bridge__DOT__i_axi_arburst) 
                                               << 0x00000010U) 
                                              | ((IData)(vlSelfRef.tb_axi_bridge__DOT__i_axi_arlock) 
                                                 << 0x0000000fU)))) 
                      | ((((IData)(vlSelfRef.tb_axi_bridge__DOT__i_axi_arcache) 
                           << 0x0000000bU) | ((IData)(vlSelfRef.tb_axi_bridge__DOT__i_axi_arprot) 
                                              << 8U)) 
                         | (((IData)(vlSelfRef.tb_axi_bridge__DOT__i_axi_arqos) 
                             << 4U) | (IData)(vlSelfRef.tb_axi_bridge__DOT__i_axi_arregion)))));
            vlSelfRef.tb_axi_bridge__DOT__exp_ar[(0x000000ffU 
                                                  & vlSelfRef.tb_axi_bridge__DOT__ar_tail)][0U] 
                = ((0x1fffffffU & vlSelfRef.tb_axi_bridge__DOT__exp_ar
                    [(0x000000ffU & vlSelfRef.tb_axi_bridge__DOT__ar_tail)][0U]) 
                   | (vlSelfRef.tb_axi_bridge__DOT__i_axi_araddr 
                      << 0x0000001dU));
            vlSelfRef.tb_axi_bridge__DOT__exp_ar[(0x000000ffU 
                                                  & vlSelfRef.tb_axi_bridge__DOT__ar_tail)][1U] 
                = ((0xe0000000U & vlSelfRef.tb_axi_bridge__DOT__exp_ar
                    [(0x000000ffU & vlSelfRef.tb_axi_bridge__DOT__ar_tail)][1U]) 
                   | (vlSelfRef.tb_axi_bridge__DOT__i_axi_araddr 
                      >> 3U));
            vlSelfRef.tb_axi_bridge__DOT__exp_ar[(0x000000ffU 
                                                  & vlSelfRef.tb_axi_bridge__DOT__ar_tail)][1U] 
                = ((0x1fffffffU & vlSelfRef.tb_axi_bridge__DOT__exp_ar
                    [(0x000000ffU & vlSelfRef.tb_axi_bridge__DOT__ar_tail)][1U]) 
                   | ((IData)(vlSelfRef.tb_axi_bridge__DOT__i_axi_arid) 
                      << 0x0000001dU));
            vlSelfRef.tb_axi_bridge__DOT__exp_ar[(0x000000ffU 
                                                  & vlSelfRef.tb_axi_bridge__DOT__ar_tail)][2U] 
                = ((0xfffffffeU & vlSelfRef.tb_axi_bridge__DOT__exp_ar
                    [(0x000000ffU & vlSelfRef.tb_axi_bridge__DOT__ar_tail)][2U]) 
                   | ((IData)(vlSelfRef.tb_axi_bridge__DOT__i_axi_arid) 
                      >> 3U));
            vlSelfRef.tb_axi_bridge__DOT__exp_ar[(0x000000ffU 
                                                  & vlSelfRef.tb_axi_bridge__DOT__ar_tail)][2U] 
                = (1U & vlSelfRef.tb_axi_bridge__DOT__exp_ar
                   [(0x000000ffU & vlSelfRef.tb_axi_bridge__DOT__ar_tail)][2U]);
            vlSelfRef.tb_axi_bridge__DOT__exp_ar[(0x000000ffU 
                                                  & vlSelfRef.tb_axi_bridge__DOT__ar_tail)][3U] = 0U;
            vlSelfRef.tb_axi_bridge__DOT__exp_ar[(0x000000ffU 
                                                  & vlSelfRef.tb_axi_bridge__DOT__ar_tail)][4U] = 0U;
            vlSelfRef.tb_axi_bridge__DOT__exp_ar[(0x000000ffU 
                                                  & vlSelfRef.tb_axi_bridge__DOT__ar_tail)][5U] = 0U;
            vlSelfRef.tb_axi_bridge__DOT__exp_ar[(0x000000ffU 
                                                  & vlSelfRef.tb_axi_bridge__DOT__ar_tail)][6U] = 0U;
            vlSelfRef.tb_axi_bridge__DOT__exp_ar[(0x000000ffU 
                                                  & vlSelfRef.tb_axi_bridge__DOT__ar_tail)][7U] = 0U;
            vlSelfRef.tb_axi_bridge__DOT__exp_ar[(0x000000ffU 
                                                  & vlSelfRef.tb_axi_bridge__DOT__ar_tail)][8U] = 0U;
            vlSelfRef.tb_axi_bridge__DOT__exp_ar[(0x000000ffU 
                                                  & vlSelfRef.tb_axi_bridge__DOT__ar_tail)][9U] = 0U;
            vlSelfRef.tb_axi_bridge__DOT__exp_ar[(0x000000ffU 
                                                  & vlSelfRef.tb_axi_bridge__DOT__ar_tail)][10U] = 0U;
            vlSelfRef.tb_axi_bridge__DOT__exp_ar[(0x000000ffU 
                                                  & vlSelfRef.tb_axi_bridge__DOT__ar_tail)][11U] = 0U;
            vlSelfRef.tb_axi_bridge__DOT__exp_ar[(0x000000ffU 
                                                  & vlSelfRef.tb_axi_bridge__DOT__ar_tail)][12U] = 0U;
            vlSelfRef.tb_axi_bridge__DOT__exp_ar[(0x000000ffU 
                                                  & vlSelfRef.tb_axi_bridge__DOT__ar_tail)][13U] = 0U;
            vlSelfRef.tb_axi_bridge__DOT__exp_ar[(0x000000ffU 
                                                  & vlSelfRef.tb_axi_bridge__DOT__ar_tail)][14U] = 0U;
            vlSelfRef.tb_axi_bridge__DOT__exp_ar[(0x000000ffU 
                                                  & vlSelfRef.tb_axi_bridge__DOT__ar_tail)][15U] = 0U;
            vlSelfRef.tb_axi_bridge__DOT__ar_tail = 
                ((IData)(1U) + vlSelfRef.tb_axi_bridge__DOT__ar_tail);
        }
        __Vtask_tb_axi_bridge__DOT__chk__check_id_72 = 0x00000015U;
        if (__Vtask_tb_axi_bridge__DOT__chk__antecedent_73) {
            if (VL_LIKELY(((0x23U >= (0x0000003fU & __Vtask_tb_axi_bridge__DOT__chk__check_id_72))))) {
                vlSelfRef.tb_axi_bridge__DOT__assertion_hits[(0x0000003fU 
                                                              & __Vtask_tb_axi_bridge__DOT__chk__check_id_72)] 
                    = ((IData)(1U) + ((0x23U >= (0x0000003fU 
                                                 & __Vtask_tb_axi_bridge__DOT__chk__check_id_72))
                                       ? vlSelfRef.tb_axi_bridge__DOT__assertion_hits
                                      [(0x0000003fU 
                                        & __Vtask_tb_axi_bridge__DOT__chk__check_id_72)]
                                       : 0U));
            }
            if (VL_UNLIKELY(((1U & (~ (IData)(__Vtask_tb_axi_bridge__DOT__chk__consequent_74)))))) {
                if (VL_LIKELY(((0x23U >= (0x0000003fU 
                                          & __Vtask_tb_axi_bridge__DOT__chk__check_id_72))))) {
                    vlSelfRef.tb_axi_bridge__DOT__assertion_fails[(0x0000003fU 
                                                                   & __Vtask_tb_axi_bridge__DOT__chk__check_id_72)] 
                        = ((IData)(1U) + ((0x23U >= 
                                           (0x0000003fU 
                                            & __Vtask_tb_axi_bridge__DOT__chk__check_id_72))
                                           ? vlSelfRef.tb_axi_bridge__DOT__assertion_fails
                                          [(0x0000003fU 
                                            & __Vtask_tb_axi_bridge__DOT__chk__check_id_72)]
                                           : 0U));
                }
                VL_WRITEF_NX("ASSERT FAIL AXI-SVA-%02d time=%0t\n",3, 'T',-9
                             , '~',32,__Vtask_tb_axi_bridge__DOT__chk__check_id_72
                             , '#',64,VL_TIME_UNITED_Q(1000));
            }
        }
        __Vtask_tb_axi_bridge__DOT__chk__consequent_77 
            = (0U == (((((((((((((((((IData)((((QData)((IData)(vlSelfRef.tb_axi_bridge__DOT__i_axi_araddr)) 
                                               << 0x0000001dU) 
                                              | (QData)((IData)(
                                                                ((((IData)(vlSelfRef.tb_axi_bridge__DOT__i_axi_arlen) 
                                                                   << 0x00000015U) 
                                                                  | (((IData)(vlSelfRef.tb_axi_bridge__DOT__i_axi_arsize) 
                                                                      << 0x00000012U) 
                                                                     | (((IData)(vlSelfRef.tb_axi_bridge__DOT__i_axi_arburst) 
                                                                         << 0x00000010U) 
                                                                        | ((IData)(vlSelfRef.tb_axi_bridge__DOT__i_axi_arlock) 
                                                                           << 0x0000000fU)))) 
                                                                 | ((((IData)(vlSelfRef.tb_axi_bridge__DOT__i_axi_arcache) 
                                                                      << 0x0000000bU) 
                                                                     | ((IData)(vlSelfRef.tb_axi_bridge__DOT__i_axi_arprot) 
                                                                        << 8U)) 
                                                                    | (((IData)(vlSelfRef.tb_axi_bridge__DOT__i_axi_arqos) 
                                                                        << 4U) 
                                                                       | (IData)(vlSelfRef.tb_axi_bridge__DOT__i_axi_arregion)))))))) 
                                     ^ vlSelfRef.tb_axi_bridge__DOT__prev_src_ar[0U]) 
                                    | ((((IData)(vlSelfRef.tb_axi_bridge__DOT__i_axi_arid) 
                                         << 0x0000001dU) 
                                        | (IData)((
                                                   (((QData)((IData)(vlSelfRef.tb_axi_bridge__DOT__i_axi_araddr)) 
                                                     << 0x0000001dU) 
                                                    | (QData)((IData)(
                                                                      ((((IData)(vlSelfRef.tb_axi_bridge__DOT__i_axi_arlen) 
                                                                         << 0x00000015U) 
                                                                        | (((IData)(vlSelfRef.tb_axi_bridge__DOT__i_axi_arsize) 
                                                                            << 0x00000012U) 
                                                                           | (((IData)(vlSelfRef.tb_axi_bridge__DOT__i_axi_arburst) 
                                                                               << 0x00000010U) 
                                                                              | ((IData)(vlSelfRef.tb_axi_bridge__DOT__i_axi_arlock) 
                                                                                << 0x0000000fU)))) 
                                                                       | ((((IData)(vlSelfRef.tb_axi_bridge__DOT__i_axi_arcache) 
                                                                            << 0x0000000bU) 
                                                                           | ((IData)(vlSelfRef.tb_axi_bridge__DOT__i_axi_arprot) 
                                                                              << 8U)) 
                                                                          | (((IData)(vlSelfRef.tb_axi_bridge__DOT__i_axi_arqos) 
                                                                              << 4U) 
                                                                             | (IData)(vlSelfRef.tb_axi_bridge__DOT__i_axi_arregion))))))) 
                                                   >> 0x00000020U))) 
                                       ^ vlSelfRef.tb_axi_bridge__DOT__prev_src_ar[1U])) 
                                   | (((IData)(vlSelfRef.tb_axi_bridge__DOT__i_axi_arid) 
                                       >> 3U) ^ vlSelfRef.tb_axi_bridge__DOT__prev_src_ar[2U])) 
                                  | vlSelfRef.tb_axi_bridge__DOT__prev_src_ar[3U]) 
                                 | vlSelfRef.tb_axi_bridge__DOT__prev_src_ar[4U]) 
                                | vlSelfRef.tb_axi_bridge__DOT__prev_src_ar[5U]) 
                               | vlSelfRef.tb_axi_bridge__DOT__prev_src_ar[6U]) 
                              | vlSelfRef.tb_axi_bridge__DOT__prev_src_ar[7U]) 
                             | vlSelfRef.tb_axi_bridge__DOT__prev_src_ar[8U]) 
                            | vlSelfRef.tb_axi_bridge__DOT__prev_src_ar[9U]) 
                           | vlSelfRef.tb_axi_bridge__DOT__prev_src_ar[10U]) 
                          | vlSelfRef.tb_axi_bridge__DOT__prev_src_ar[11U]) 
                         | vlSelfRef.tb_axi_bridge__DOT__prev_src_ar[12U]) 
                        | vlSelfRef.tb_axi_bridge__DOT__prev_src_ar[13U]) 
                       | vlSelfRef.tb_axi_bridge__DOT__prev_src_ar[14U]) 
                      | vlSelfRef.tb_axi_bridge__DOT__prev_src_ar[15U]));
        __Vtask_tb_axi_bridge__DOT__chk__antecedent_76 
            = vlSelfRef.tb_axi_bridge__DOT__src_ar_stall;
        __Vtask_tb_axi_bridge__DOT__chk__check_id_75 = 0x00000016U;
        if (__Vtask_tb_axi_bridge__DOT__chk__antecedent_76) {
            if (VL_LIKELY(((0x23U >= (0x0000003fU & __Vtask_tb_axi_bridge__DOT__chk__check_id_75))))) {
                vlSelfRef.tb_axi_bridge__DOT__assertion_hits[(0x0000003fU 
                                                              & __Vtask_tb_axi_bridge__DOT__chk__check_id_75)] 
                    = ((IData)(1U) + ((0x23U >= (0x0000003fU 
                                                 & __Vtask_tb_axi_bridge__DOT__chk__check_id_75))
                                       ? vlSelfRef.tb_axi_bridge__DOT__assertion_hits
                                      [(0x0000003fU 
                                        & __Vtask_tb_axi_bridge__DOT__chk__check_id_75)]
                                       : 0U));
            }
            if (VL_UNLIKELY(((1U & (~ (IData)(__Vtask_tb_axi_bridge__DOT__chk__consequent_77)))))) {
                if (VL_LIKELY(((0x23U >= (0x0000003fU 
                                          & __Vtask_tb_axi_bridge__DOT__chk__check_id_75))))) {
                    vlSelfRef.tb_axi_bridge__DOT__assertion_fails[(0x0000003fU 
                                                                   & __Vtask_tb_axi_bridge__DOT__chk__check_id_75)] 
                        = ((IData)(1U) + ((0x23U >= 
                                           (0x0000003fU 
                                            & __Vtask_tb_axi_bridge__DOT__chk__check_id_75))
                                           ? vlSelfRef.tb_axi_bridge__DOT__assertion_fails
                                          [(0x0000003fU 
                                            & __Vtask_tb_axi_bridge__DOT__chk__check_id_75)]
                                           : 0U));
                }
                VL_WRITEF_NX("ASSERT FAIL AXI-SVA-%02d time=%0t\n",3, 'T',-9
                             , '~',32,__Vtask_tb_axi_bridge__DOT__chk__check_id_75
                             , '#',64,VL_TIME_UNITED_Q(1000));
            }
        }
        __Vtask_tb_axi_bridge__DOT__chk__consequent_80 = 1U;
        __Vtask_tb_axi_bridge__DOT__chk__antecedent_79 
            = vlSelfRef.tb_axi_bridge__DOT__i_axi_arvalid;
        __Vtask_tb_axi_bridge__DOT__chk__check_id_78 = 0x0000001aU;
        if (__Vtask_tb_axi_bridge__DOT__chk__antecedent_79) {
            if (VL_LIKELY(((0x23U >= (0x0000003fU & __Vtask_tb_axi_bridge__DOT__chk__check_id_78))))) {
                vlSelfRef.tb_axi_bridge__DOT__assertion_hits[(0x0000003fU 
                                                              & __Vtask_tb_axi_bridge__DOT__chk__check_id_78)] 
                    = ((IData)(1U) + ((0x23U >= (0x0000003fU 
                                                 & __Vtask_tb_axi_bridge__DOT__chk__check_id_78))
                                       ? vlSelfRef.tb_axi_bridge__DOT__assertion_hits
                                      [(0x0000003fU 
                                        & __Vtask_tb_axi_bridge__DOT__chk__check_id_78)]
                                       : 0U));
            }
            if (VL_UNLIKELY(((1U & (~ (IData)(__Vtask_tb_axi_bridge__DOT__chk__consequent_80)))))) {
                if (VL_LIKELY(((0x23U >= (0x0000003fU 
                                          & __Vtask_tb_axi_bridge__DOT__chk__check_id_78))))) {
                    vlSelfRef.tb_axi_bridge__DOT__assertion_fails[(0x0000003fU 
                                                                   & __Vtask_tb_axi_bridge__DOT__chk__check_id_78)] 
                        = ((IData)(1U) + ((0x23U >= 
                                           (0x0000003fU 
                                            & __Vtask_tb_axi_bridge__DOT__chk__check_id_78))
                                           ? vlSelfRef.tb_axi_bridge__DOT__assertion_fails
                                          [(0x0000003fU 
                                            & __Vtask_tb_axi_bridge__DOT__chk__check_id_78)]
                                           : 0U));
                }
                VL_WRITEF_NX("ASSERT FAIL AXI-SVA-%02d time=%0t\n",3, 'T',-9
                             , '~',32,__Vtask_tb_axi_bridge__DOT__chk__check_id_78
                             , '#',64,VL_TIME_UNITED_Q(1000));
            }
        }
        vlSelfRef.tb_axi_bridge__DOT__src_ar_stall 
            = ((IData)(vlSelfRef.tb_axi_bridge__DOT__i_axi_arvalid) 
               & (~ (IData)(vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_ar__DOT__o_axi_arready)));
        vlSelfRef.tb_axi_bridge__DOT__prev_src_ar[0U] 
            = ((0xe0000000U & vlSelfRef.tb_axi_bridge__DOT__prev_src_ar[0U]) 
               | ((((IData)(vlSelfRef.tb_axi_bridge__DOT__i_axi_arlen) 
                    << 0x00000015U) | (((IData)(vlSelfRef.tb_axi_bridge__DOT__i_axi_arsize) 
                                        << 0x00000012U) 
                                       | (((IData)(vlSelfRef.tb_axi_bridge__DOT__i_axi_arburst) 
                                           << 0x00000010U) 
                                          | ((IData)(vlSelfRef.tb_axi_bridge__DOT__i_axi_arlock) 
                                             << 0x0000000fU)))) 
                  | ((((IData)(vlSelfRef.tb_axi_bridge__DOT__i_axi_arcache) 
                       << 0x0000000bU) | ((IData)(vlSelfRef.tb_axi_bridge__DOT__i_axi_arprot) 
                                          << 8U)) | 
                     (((IData)(vlSelfRef.tb_axi_bridge__DOT__i_axi_arqos) 
                       << 4U) | (IData)(vlSelfRef.tb_axi_bridge__DOT__i_axi_arregion)))));
        vlSelfRef.tb_axi_bridge__DOT__prev_src_ar[0U] 
            = ((0x1fffffffU & vlSelfRef.tb_axi_bridge__DOT__prev_src_ar[0U]) 
               | ((IData)((((QData)((IData)(vlSelfRef.tb_axi_bridge__DOT__i_axi_arid)) 
                            << 0x00000020U) | (QData)((IData)(vlSelfRef.tb_axi_bridge__DOT__i_axi_araddr)))) 
                  << 0x0000001dU));
        vlSelfRef.tb_axi_bridge__DOT__prev_src_ar[1U] 
            = (((IData)((((QData)((IData)(vlSelfRef.tb_axi_bridge__DOT__i_axi_arid)) 
                          << 0x00000020U) | (QData)((IData)(vlSelfRef.tb_axi_bridge__DOT__i_axi_araddr)))) 
                >> 3U) | ((IData)(((((QData)((IData)(vlSelfRef.tb_axi_bridge__DOT__i_axi_arid)) 
                                     << 0x00000020U) 
                                    | (QData)((IData)(vlSelfRef.tb_axi_bridge__DOT__i_axi_araddr))) 
                                   >> 0x00000020U)) 
                          << 0x0000001dU));
        vlSelfRef.tb_axi_bridge__DOT__prev_src_ar[2U] 
            = ((IData)(((((QData)((IData)(vlSelfRef.tb_axi_bridge__DOT__i_axi_arid)) 
                          << 0x00000020U) | (QData)((IData)(vlSelfRef.tb_axi_bridge__DOT__i_axi_araddr))) 
                        >> 0x00000020U)) >> 3U);
        vlSelfRef.tb_axi_bridge__DOT__prev_src_ar[3U] = 0U;
        vlSelfRef.tb_axi_bridge__DOT__prev_src_ar[4U] = 0U;
        vlSelfRef.tb_axi_bridge__DOT__prev_src_ar[5U] = 0U;
        vlSelfRef.tb_axi_bridge__DOT__prev_src_ar[6U] = 0U;
        vlSelfRef.tb_axi_bridge__DOT__prev_src_ar[7U] = 0U;
        vlSelfRef.tb_axi_bridge__DOT__prev_src_ar[8U] = 0U;
        vlSelfRef.tb_axi_bridge__DOT__prev_src_ar[9U] = 0U;
        vlSelfRef.tb_axi_bridge__DOT__prev_src_ar[10U] = 0U;
        vlSelfRef.tb_axi_bridge__DOT__prev_src_ar[11U] = 0U;
        vlSelfRef.tb_axi_bridge__DOT__prev_src_ar[12U] = 0U;
        vlSelfRef.tb_axi_bridge__DOT__prev_src_ar[13U] = 0U;
        vlSelfRef.tb_axi_bridge__DOT__prev_src_ar[14U] = 0U;
        vlSelfRef.tb_axi_bridge__DOT__prev_src_ar[15U] = 0U;
        __Vtask_tb_axi_bridge__DOT__chk__consequent_59 
            = vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_b__DOT__o_axi_bvalid;
        __Vtask_tb_axi_bridge__DOT__chk__antecedent_58 
            = vlSelfRef.tb_axi_bridge__DOT__dst_b_stall;
        __Vtask_tb_axi_bridge__DOT__chk__check_id_57 = 0x00000010U;
        if (__Vtask_tb_axi_bridge__DOT__chk__antecedent_58) {
            if (VL_LIKELY(((0x23U >= (0x0000003fU & __Vtask_tb_axi_bridge__DOT__chk__check_id_57))))) {
                vlSelfRef.tb_axi_bridge__DOT__assertion_hits[(0x0000003fU 
                                                              & __Vtask_tb_axi_bridge__DOT__chk__check_id_57)] 
                    = ((IData)(1U) + ((0x23U >= (0x0000003fU 
                                                 & __Vtask_tb_axi_bridge__DOT__chk__check_id_57))
                                       ? vlSelfRef.tb_axi_bridge__DOT__assertion_hits
                                      [(0x0000003fU 
                                        & __Vtask_tb_axi_bridge__DOT__chk__check_id_57)]
                                       : 0U));
            }
            if (VL_UNLIKELY(((1U & (~ (IData)(__Vtask_tb_axi_bridge__DOT__chk__consequent_59)))))) {
                if (VL_LIKELY(((0x23U >= (0x0000003fU 
                                          & __Vtask_tb_axi_bridge__DOT__chk__check_id_57))))) {
                    vlSelfRef.tb_axi_bridge__DOT__assertion_fails[(0x0000003fU 
                                                                   & __Vtask_tb_axi_bridge__DOT__chk__check_id_57)] 
                        = ((IData)(1U) + ((0x23U >= 
                                           (0x0000003fU 
                                            & __Vtask_tb_axi_bridge__DOT__chk__check_id_57))
                                           ? vlSelfRef.tb_axi_bridge__DOT__assertion_fails
                                          [(0x0000003fU 
                                            & __Vtask_tb_axi_bridge__DOT__chk__check_id_57)]
                                           : 0U));
                }
                VL_WRITEF_NX("ASSERT FAIL AXI-SVA-%02d time=%0t\n",3, 'T',-9
                             , '~',32,__Vtask_tb_axi_bridge__DOT__chk__check_id_57
                             , '#',64,VL_TIME_UNITED_Q(1000));
            }
        }
        __Vtask_tb_axi_bridge__DOT__chk__consequent_62 
            = (0U == ((((((((((((((((((0x0000003cU 
                                       & ((IData)(vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_b__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_mem__DOT__gen_array__DOT__reg_rd_data) 
                                          << 2U)) | 
                                      (3U & ((IData)(vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_b__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_mem__DOT__gen_array__DOT__reg_rd_data) 
                                             >> 4U))) 
                                     ^ vlSelfRef.tb_axi_bridge__DOT__prev_dst_b[0U]) 
                                    | vlSelfRef.tb_axi_bridge__DOT__prev_dst_b[1U]) 
                                   | vlSelfRef.tb_axi_bridge__DOT__prev_dst_b[2U]) 
                                  | vlSelfRef.tb_axi_bridge__DOT__prev_dst_b[3U]) 
                                 | vlSelfRef.tb_axi_bridge__DOT__prev_dst_b[4U]) 
                                | vlSelfRef.tb_axi_bridge__DOT__prev_dst_b[5U]) 
                               | vlSelfRef.tb_axi_bridge__DOT__prev_dst_b[6U]) 
                              | vlSelfRef.tb_axi_bridge__DOT__prev_dst_b[7U]) 
                             | vlSelfRef.tb_axi_bridge__DOT__prev_dst_b[8U]) 
                            | vlSelfRef.tb_axi_bridge__DOT__prev_dst_b[9U]) 
                           | vlSelfRef.tb_axi_bridge__DOT__prev_dst_b[10U]) 
                          | vlSelfRef.tb_axi_bridge__DOT__prev_dst_b[11U]) 
                         | vlSelfRef.tb_axi_bridge__DOT__prev_dst_b[12U]) 
                        | vlSelfRef.tb_axi_bridge__DOT__prev_dst_b[13U]) 
                       | vlSelfRef.tb_axi_bridge__DOT__prev_dst_b[14U]) 
                      | vlSelfRef.tb_axi_bridge__DOT__prev_dst_b[15U]));
        __Vtask_tb_axi_bridge__DOT__chk__antecedent_61 
            = vlSelfRef.tb_axi_bridge__DOT__dst_b_stall;
        __Vtask_tb_axi_bridge__DOT__chk__check_id_60 = 0x00000011U;
        if (__Vtask_tb_axi_bridge__DOT__chk__antecedent_61) {
            if (VL_LIKELY(((0x23U >= (0x0000003fU & __Vtask_tb_axi_bridge__DOT__chk__check_id_60))))) {
                vlSelfRef.tb_axi_bridge__DOT__assertion_hits[(0x0000003fU 
                                                              & __Vtask_tb_axi_bridge__DOT__chk__check_id_60)] 
                    = ((IData)(1U) + ((0x23U >= (0x0000003fU 
                                                 & __Vtask_tb_axi_bridge__DOT__chk__check_id_60))
                                       ? vlSelfRef.tb_axi_bridge__DOT__assertion_hits
                                      [(0x0000003fU 
                                        & __Vtask_tb_axi_bridge__DOT__chk__check_id_60)]
                                       : 0U));
            }
            if (VL_UNLIKELY(((1U & (~ (IData)(__Vtask_tb_axi_bridge__DOT__chk__consequent_62)))))) {
                if (VL_LIKELY(((0x23U >= (0x0000003fU 
                                          & __Vtask_tb_axi_bridge__DOT__chk__check_id_60))))) {
                    vlSelfRef.tb_axi_bridge__DOT__assertion_fails[(0x0000003fU 
                                                                   & __Vtask_tb_axi_bridge__DOT__chk__check_id_60)] 
                        = ((IData)(1U) + ((0x23U >= 
                                           (0x0000003fU 
                                            & __Vtask_tb_axi_bridge__DOT__chk__check_id_60))
                                           ? vlSelfRef.tb_axi_bridge__DOT__assertion_fails
                                          [(0x0000003fU 
                                            & __Vtask_tb_axi_bridge__DOT__chk__check_id_60)]
                                           : 0U));
                }
                VL_WRITEF_NX("ASSERT FAIL AXI-SVA-%02d time=%0t\n",3, 'T',-9
                             , '~',32,__Vtask_tb_axi_bridge__DOT__chk__check_id_60
                             , '#',64,VL_TIME_UNITED_Q(1000));
            }
        }
        __Vtask_tb_axi_bridge__DOT__chk__consequent_65 = 1U;
        __Vtask_tb_axi_bridge__DOT__chk__antecedent_64 
            = vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_b__DOT__o_axi_bvalid;
        __Vtask_tb_axi_bridge__DOT__chk__check_id_63 = 0x00000014U;
        if (__Vtask_tb_axi_bridge__DOT__chk__antecedent_64) {
            if (VL_LIKELY(((0x23U >= (0x0000003fU & __Vtask_tb_axi_bridge__DOT__chk__check_id_63))))) {
                vlSelfRef.tb_axi_bridge__DOT__assertion_hits[(0x0000003fU 
                                                              & __Vtask_tb_axi_bridge__DOT__chk__check_id_63)] 
                    = ((IData)(1U) + ((0x23U >= (0x0000003fU 
                                                 & __Vtask_tb_axi_bridge__DOT__chk__check_id_63))
                                       ? vlSelfRef.tb_axi_bridge__DOT__assertion_hits
                                      [(0x0000003fU 
                                        & __Vtask_tb_axi_bridge__DOT__chk__check_id_63)]
                                       : 0U));
            }
            if (VL_UNLIKELY(((1U & (~ (IData)(__Vtask_tb_axi_bridge__DOT__chk__consequent_65)))))) {
                if (VL_LIKELY(((0x23U >= (0x0000003fU 
                                          & __Vtask_tb_axi_bridge__DOT__chk__check_id_63))))) {
                    vlSelfRef.tb_axi_bridge__DOT__assertion_fails[(0x0000003fU 
                                                                   & __Vtask_tb_axi_bridge__DOT__chk__check_id_63)] 
                        = ((IData)(1U) + ((0x23U >= 
                                           (0x0000003fU 
                                            & __Vtask_tb_axi_bridge__DOT__chk__check_id_63))
                                           ? vlSelfRef.tb_axi_bridge__DOT__assertion_fails
                                          [(0x0000003fU 
                                            & __Vtask_tb_axi_bridge__DOT__chk__check_id_63)]
                                           : 0U));
                }
                VL_WRITEF_NX("ASSERT FAIL AXI-SVA-%02d time=%0t\n",3, 'T',-9
                             , '~',32,__Vtask_tb_axi_bridge__DOT__chk__check_id_63
                             , '#',64,VL_TIME_UNITED_Q(1000));
            }
        }
        if (((IData)(vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_b__DOT__o_axi_bvalid) 
             & (IData)(vlSelfRef.tb_axi_bridge__DOT__i_axi_bready))) {
            __Vtask_tb_axi_bridge__DOT__chk__consequent_68 
                = (VL_LTS_III(32, vlSelfRef.tb_axi_bridge__DOT__b_head, vlSelfRef.tb_axi_bridge__DOT__b_tail) 
                   & (0U == ((((((((((((((((((0x0000003cU 
                                              & ((IData)(vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_b__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_mem__DOT__gen_array__DOT__reg_rd_data) 
                                                 << 2U)) 
                                             | (3U 
                                                & ((IData)(vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_b__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_mem__DOT__gen_array__DOT__reg_rd_data) 
                                                   >> 4U))) 
                                            ^ vlSelfRef.tb_axi_bridge__DOT__exp_b
                                            [(0x000000ffU 
                                              & vlSelfRef.tb_axi_bridge__DOT__b_head)][0U]) 
                                           | vlSelfRef.tb_axi_bridge__DOT__exp_b
                                           [(0x000000ffU 
                                             & vlSelfRef.tb_axi_bridge__DOT__b_head)][1U]) 
                                          | vlSelfRef.tb_axi_bridge__DOT__exp_b
                                          [(0x000000ffU 
                                            & vlSelfRef.tb_axi_bridge__DOT__b_head)][2U]) 
                                         | vlSelfRef.tb_axi_bridge__DOT__exp_b
                                         [(0x000000ffU 
                                           & vlSelfRef.tb_axi_bridge__DOT__b_head)][3U]) 
                                        | vlSelfRef.tb_axi_bridge__DOT__exp_b
                                        [(0x000000ffU 
                                          & vlSelfRef.tb_axi_bridge__DOT__b_head)][4U]) 
                                       | vlSelfRef.tb_axi_bridge__DOT__exp_b
                                       [(0x000000ffU 
                                         & vlSelfRef.tb_axi_bridge__DOT__b_head)][5U]) 
                                      | vlSelfRef.tb_axi_bridge__DOT__exp_b
                                      [(0x000000ffU 
                                        & vlSelfRef.tb_axi_bridge__DOT__b_head)][6U]) 
                                     | vlSelfRef.tb_axi_bridge__DOT__exp_b
                                     [(0x000000ffU 
                                       & vlSelfRef.tb_axi_bridge__DOT__b_head)][7U]) 
                                    | vlSelfRef.tb_axi_bridge__DOT__exp_b
                                    [(0x000000ffU & vlSelfRef.tb_axi_bridge__DOT__b_head)][8U]) 
                                   | vlSelfRef.tb_axi_bridge__DOT__exp_b
                                   [(0x000000ffU & vlSelfRef.tb_axi_bridge__DOT__b_head)][9U]) 
                                  | vlSelfRef.tb_axi_bridge__DOT__exp_b
                                  [(0x000000ffU & vlSelfRef.tb_axi_bridge__DOT__b_head)][10U]) 
                                 | vlSelfRef.tb_axi_bridge__DOT__exp_b
                                 [(0x000000ffU & vlSelfRef.tb_axi_bridge__DOT__b_head)][11U]) 
                                | vlSelfRef.tb_axi_bridge__DOT__exp_b
                                [(0x000000ffU & vlSelfRef.tb_axi_bridge__DOT__b_head)][12U]) 
                               | vlSelfRef.tb_axi_bridge__DOT__exp_b
                               [(0x000000ffU & vlSelfRef.tb_axi_bridge__DOT__b_head)][13U]) 
                              | vlSelfRef.tb_axi_bridge__DOT__exp_b
                              [(0x000000ffU & vlSelfRef.tb_axi_bridge__DOT__b_head)][14U]) 
                             | vlSelfRef.tb_axi_bridge__DOT__exp_b
                             [(0x000000ffU & vlSelfRef.tb_axi_bridge__DOT__b_head)][15U])));
            __Vtask_tb_axi_bridge__DOT__chk__check_id_66 = 0x00000012U;
            vlSelfRef.tb_axi_bridge__DOT__out_b = ((IData)(1U) 
                                                   + vlSelfRef.tb_axi_bridge__DOT__out_b);
            vlSelfRef.tb_axi_bridge__DOT__assertion_hits[(0x0000003fU 
                                                          & __Vtask_tb_axi_bridge__DOT__chk__check_id_66)] 
                = ((IData)(1U) + ((0x23U >= (0x0000003fU 
                                             & __Vtask_tb_axi_bridge__DOT__chk__check_id_66))
                                   ? vlSelfRef.tb_axi_bridge__DOT__assertion_hits
                                  [(0x0000003fU & __Vtask_tb_axi_bridge__DOT__chk__check_id_66)]
                                   : 0U));
            if (VL_UNLIKELY(((1U & (~ (IData)(__Vtask_tb_axi_bridge__DOT__chk__consequent_68)))))) {
                if (VL_LIKELY(((0x23U >= (0x0000003fU 
                                          & __Vtask_tb_axi_bridge__DOT__chk__check_id_66))))) {
                    vlSelfRef.tb_axi_bridge__DOT__assertion_fails[(0x0000003fU 
                                                                   & __Vtask_tb_axi_bridge__DOT__chk__check_id_66)] 
                        = ((IData)(1U) + ((0x23U >= 
                                           (0x0000003fU 
                                            & __Vtask_tb_axi_bridge__DOT__chk__check_id_66))
                                           ? vlSelfRef.tb_axi_bridge__DOT__assertion_fails
                                          [(0x0000003fU 
                                            & __Vtask_tb_axi_bridge__DOT__chk__check_id_66)]
                                           : 0U));
                }
                VL_WRITEF_NX("ASSERT FAIL AXI-SVA-%02d time=%0t\n",3, 'T',-9
                             , '~',32,__Vtask_tb_axi_bridge__DOT__chk__check_id_66
                             , '#',64,VL_TIME_UNITED_Q(1000));
            }
            vlSelfRef.tb_axi_bridge__DOT__b_head = 
                ((IData)(1U) + vlSelfRef.tb_axi_bridge__DOT__b_head);
        }
        vlSelfRef.tb_axi_bridge__DOT__dst_b_stall = 
            ((IData)(vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_b__DOT__o_axi_bvalid) 
             & (~ (IData)(vlSelfRef.tb_axi_bridge__DOT__i_axi_bready)));
        vlSelfRef.tb_axi_bridge__DOT__prev_dst_b[0U] 
            = ((0x0000003cU & ((IData)(vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_b__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_mem__DOT__gen_array__DOT__reg_rd_data) 
                               << 2U)) | (3U & ((IData)(vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_b__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_mem__DOT__gen_array__DOT__reg_rd_data) 
                                                >> 4U)));
        vlSelfRef.tb_axi_bridge__DOT__prev_dst_b[1U] = 0U;
        vlSelfRef.tb_axi_bridge__DOT__prev_dst_b[2U] = 0U;
        vlSelfRef.tb_axi_bridge__DOT__prev_dst_b[3U] = 0U;
        vlSelfRef.tb_axi_bridge__DOT__prev_dst_b[4U] = 0U;
        vlSelfRef.tb_axi_bridge__DOT__prev_dst_b[5U] = 0U;
        vlSelfRef.tb_axi_bridge__DOT__prev_dst_b[6U] = 0U;
        vlSelfRef.tb_axi_bridge__DOT__prev_dst_b[7U] = 0U;
        vlSelfRef.tb_axi_bridge__DOT__prev_dst_b[8U] = 0U;
        vlSelfRef.tb_axi_bridge__DOT__prev_dst_b[9U] = 0U;
        vlSelfRef.tb_axi_bridge__DOT__prev_dst_b[10U] = 0U;
        vlSelfRef.tb_axi_bridge__DOT__prev_dst_b[11U] = 0U;
        vlSelfRef.tb_axi_bridge__DOT__prev_dst_b[12U] = 0U;
        vlSelfRef.tb_axi_bridge__DOT__prev_dst_b[13U] = 0U;
        vlSelfRef.tb_axi_bridge__DOT__prev_dst_b[14U] = 0U;
        vlSelfRef.tb_axi_bridge__DOT__prev_dst_b[15U] = 0U;
        __Vtask_tb_axi_bridge__DOT__chk__consequent_107 
            = vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_r__DOT__o_axi_rvalid;
        __Vtask_tb_axi_bridge__DOT__chk__antecedent_106 
            = vlSelfRef.tb_axi_bridge__DOT__dst_r_stall;
        __Vtask_tb_axi_bridge__DOT__chk__check_id_105 = 0x0000001eU;
        if (__Vtask_tb_axi_bridge__DOT__chk__antecedent_106) {
            if (VL_LIKELY(((0x23U >= (0x0000003fU & __Vtask_tb_axi_bridge__DOT__chk__check_id_105))))) {
                vlSelfRef.tb_axi_bridge__DOT__assertion_hits[(0x0000003fU 
                                                              & __Vtask_tb_axi_bridge__DOT__chk__check_id_105)] 
                    = ((IData)(1U) + ((0x23U >= (0x0000003fU 
                                                 & __Vtask_tb_axi_bridge__DOT__chk__check_id_105))
                                       ? vlSelfRef.tb_axi_bridge__DOT__assertion_hits
                                      [(0x0000003fU 
                                        & __Vtask_tb_axi_bridge__DOT__chk__check_id_105)]
                                       : 0U));
            }
            if (VL_UNLIKELY(((1U & (~ (IData)(__Vtask_tb_axi_bridge__DOT__chk__consequent_107)))))) {
                if (VL_LIKELY(((0x23U >= (0x0000003fU 
                                          & __Vtask_tb_axi_bridge__DOT__chk__check_id_105))))) {
                    vlSelfRef.tb_axi_bridge__DOT__assertion_fails[(0x0000003fU 
                                                                   & __Vtask_tb_axi_bridge__DOT__chk__check_id_105)] 
                        = ((IData)(1U) + ((0x23U >= 
                                           (0x0000003fU 
                                            & __Vtask_tb_axi_bridge__DOT__chk__check_id_105))
                                           ? vlSelfRef.tb_axi_bridge__DOT__assertion_fails
                                          [(0x0000003fU 
                                            & __Vtask_tb_axi_bridge__DOT__chk__check_id_105)]
                                           : 0U));
                }
                VL_WRITEF_NX("ASSERT FAIL AXI-SVA-%02d time=%0t\n",3, 'T',-9
                             , '~',32,__Vtask_tb_axi_bridge__DOT__chk__check_id_105
                             , '#',64,VL_TIME_UNITED_Q(1000));
            }
        }
        __Vtask_tb_axi_bridge__DOT__chk__consequent_110 
            = (0U == (((((((((((((((((IData)((((QData)((IData)(
                                                               (0x0000000fU 
                                                                & (IData)(vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_r__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_mem__DOT__gen_array__DOT__reg_rd_data)))) 
                                               << 0x00000023U) 
                                              | (((QData)((IData)(
                                                                  (vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_r__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_mem__DOT__gen_array__DOT__reg_rd_data 
                                                                   >> 4U))) 
                                                  << 3U) 
                                                 | (QData)((IData)(
                                                                   ((6U 
                                                                     & ((IData)(
                                                                                (vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_r__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_mem__DOT__gen_array__DOT__reg_rd_data 
                                                                                >> 0x00000024U)) 
                                                                        << 1U)) 
                                                                    | (1U 
                                                                       & (IData)(
                                                                                (vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_r__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_mem__DOT__gen_array__DOT__reg_rd_data 
                                                                                >> 0x00000026U))))))))) 
                                     ^ vlSelfRef.tb_axi_bridge__DOT__prev_dst_r[0U]) 
                                    | ((IData)(((((QData)((IData)(
                                                                  (0x0000000fU 
                                                                   & (IData)(vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_r__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_mem__DOT__gen_array__DOT__reg_rd_data)))) 
                                                  << 0x00000023U) 
                                                 | (((QData)((IData)(
                                                                     (vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_r__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_mem__DOT__gen_array__DOT__reg_rd_data 
                                                                      >> 4U))) 
                                                     << 3U) 
                                                    | (QData)((IData)(
                                                                      ((6U 
                                                                        & ((IData)(
                                                                                (vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_r__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_mem__DOT__gen_array__DOT__reg_rd_data 
                                                                                >> 0x00000024U)) 
                                                                           << 1U)) 
                                                                       | (1U 
                                                                          & (IData)(
                                                                                (vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_r__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_mem__DOT__gen_array__DOT__reg_rd_data 
                                                                                >> 0x00000026U)))))))) 
                                                >> 0x00000020U)) 
                                       ^ vlSelfRef.tb_axi_bridge__DOT__prev_dst_r[1U])) 
                                   | vlSelfRef.tb_axi_bridge__DOT__prev_dst_r[2U]) 
                                  | vlSelfRef.tb_axi_bridge__DOT__prev_dst_r[3U]) 
                                 | vlSelfRef.tb_axi_bridge__DOT__prev_dst_r[4U]) 
                                | vlSelfRef.tb_axi_bridge__DOT__prev_dst_r[5U]) 
                               | vlSelfRef.tb_axi_bridge__DOT__prev_dst_r[6U]) 
                              | vlSelfRef.tb_axi_bridge__DOT__prev_dst_r[7U]) 
                             | vlSelfRef.tb_axi_bridge__DOT__prev_dst_r[8U]) 
                            | vlSelfRef.tb_axi_bridge__DOT__prev_dst_r[9U]) 
                           | vlSelfRef.tb_axi_bridge__DOT__prev_dst_r[10U]) 
                          | vlSelfRef.tb_axi_bridge__DOT__prev_dst_r[11U]) 
                         | vlSelfRef.tb_axi_bridge__DOT__prev_dst_r[12U]) 
                        | vlSelfRef.tb_axi_bridge__DOT__prev_dst_r[13U]) 
                       | vlSelfRef.tb_axi_bridge__DOT__prev_dst_r[14U]) 
                      | vlSelfRef.tb_axi_bridge__DOT__prev_dst_r[15U]));
        __Vtask_tb_axi_bridge__DOT__chk__antecedent_109 
            = vlSelfRef.tb_axi_bridge__DOT__dst_r_stall;
        __Vtask_tb_axi_bridge__DOT__chk__check_id_108 = 0x0000001fU;
        if (__Vtask_tb_axi_bridge__DOT__chk__antecedent_109) {
            if (VL_LIKELY(((0x23U >= (0x0000003fU & __Vtask_tb_axi_bridge__DOT__chk__check_id_108))))) {
                vlSelfRef.tb_axi_bridge__DOT__assertion_hits[(0x0000003fU 
                                                              & __Vtask_tb_axi_bridge__DOT__chk__check_id_108)] 
                    = ((IData)(1U) + ((0x23U >= (0x0000003fU 
                                                 & __Vtask_tb_axi_bridge__DOT__chk__check_id_108))
                                       ? vlSelfRef.tb_axi_bridge__DOT__assertion_hits
                                      [(0x0000003fU 
                                        & __Vtask_tb_axi_bridge__DOT__chk__check_id_108)]
                                       : 0U));
            }
            if (VL_UNLIKELY(((1U & (~ (IData)(__Vtask_tb_axi_bridge__DOT__chk__consequent_110)))))) {
                if (VL_LIKELY(((0x23U >= (0x0000003fU 
                                          & __Vtask_tb_axi_bridge__DOT__chk__check_id_108))))) {
                    vlSelfRef.tb_axi_bridge__DOT__assertion_fails[(0x0000003fU 
                                                                   & __Vtask_tb_axi_bridge__DOT__chk__check_id_108)] 
                        = ((IData)(1U) + ((0x23U >= 
                                           (0x0000003fU 
                                            & __Vtask_tb_axi_bridge__DOT__chk__check_id_108))
                                           ? vlSelfRef.tb_axi_bridge__DOT__assertion_fails
                                          [(0x0000003fU 
                                            & __Vtask_tb_axi_bridge__DOT__chk__check_id_108)]
                                           : 0U));
                }
                VL_WRITEF_NX("ASSERT FAIL AXI-SVA-%02d time=%0t\n",3, 'T',-9
                             , '~',32,__Vtask_tb_axi_bridge__DOT__chk__check_id_108
                             , '#',64,VL_TIME_UNITED_Q(1000));
            }
        }
        __Vtask_tb_axi_bridge__DOT__chk__consequent_113 = 1U;
        __Vtask_tb_axi_bridge__DOT__chk__antecedent_112 
            = vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_r__DOT__o_axi_rvalid;
        __Vtask_tb_axi_bridge__DOT__chk__check_id_111 = 0x00000022U;
        if (__Vtask_tb_axi_bridge__DOT__chk__antecedent_112) {
            if (VL_LIKELY(((0x23U >= (0x0000003fU & __Vtask_tb_axi_bridge__DOT__chk__check_id_111))))) {
                vlSelfRef.tb_axi_bridge__DOT__assertion_hits[(0x0000003fU 
                                                              & __Vtask_tb_axi_bridge__DOT__chk__check_id_111)] 
                    = ((IData)(1U) + ((0x23U >= (0x0000003fU 
                                                 & __Vtask_tb_axi_bridge__DOT__chk__check_id_111))
                                       ? vlSelfRef.tb_axi_bridge__DOT__assertion_hits
                                      [(0x0000003fU 
                                        & __Vtask_tb_axi_bridge__DOT__chk__check_id_111)]
                                       : 0U));
            }
            if (VL_UNLIKELY(((1U & (~ (IData)(__Vtask_tb_axi_bridge__DOT__chk__consequent_113)))))) {
                if (VL_LIKELY(((0x23U >= (0x0000003fU 
                                          & __Vtask_tb_axi_bridge__DOT__chk__check_id_111))))) {
                    vlSelfRef.tb_axi_bridge__DOT__assertion_fails[(0x0000003fU 
                                                                   & __Vtask_tb_axi_bridge__DOT__chk__check_id_111)] 
                        = ((IData)(1U) + ((0x23U >= 
                                           (0x0000003fU 
                                            & __Vtask_tb_axi_bridge__DOT__chk__check_id_111))
                                           ? vlSelfRef.tb_axi_bridge__DOT__assertion_fails
                                          [(0x0000003fU 
                                            & __Vtask_tb_axi_bridge__DOT__chk__check_id_111)]
                                           : 0U));
                }
                VL_WRITEF_NX("ASSERT FAIL AXI-SVA-%02d time=%0t\n",3, 'T',-9
                             , '~',32,__Vtask_tb_axi_bridge__DOT__chk__check_id_111
                             , '#',64,VL_TIME_UNITED_Q(1000));
            }
        }
        if (((IData)(vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_r__DOT__o_axi_rvalid) 
             & (IData)(vlSelfRef.tb_axi_bridge__DOT__i_axi_rready))) {
            __Vtask_tb_axi_bridge__DOT__chk__consequent_116 
                = (VL_LTS_III(32, vlSelfRef.tb_axi_bridge__DOT__r_head, vlSelfRef.tb_axi_bridge__DOT__r_tail) 
                   & (0U == (((((((((((((((((IData)(
                                                    (((QData)((IData)(
                                                                      (0x0000000fU 
                                                                       & (IData)(vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_r__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_mem__DOT__gen_array__DOT__reg_rd_data)))) 
                                                      << 0x00000023U) 
                                                     | (((QData)((IData)(
                                                                         (vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_r__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_mem__DOT__gen_array__DOT__reg_rd_data 
                                                                          >> 4U))) 
                                                         << 3U) 
                                                        | (QData)((IData)(
                                                                          ((6U 
                                                                            & ((IData)(
                                                                                (vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_r__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_mem__DOT__gen_array__DOT__reg_rd_data 
                                                                                >> 0x00000024U)) 
                                                                               << 1U)) 
                                                                           | (1U 
                                                                              & (IData)(
                                                                                (vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_r__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_mem__DOT__gen_array__DOT__reg_rd_data 
                                                                                >> 0x00000026U))))))))) 
                                            ^ vlSelfRef.tb_axi_bridge__DOT__exp_r
                                            [(0x000000ffU 
                                              & vlSelfRef.tb_axi_bridge__DOT__r_head)][0U]) 
                                           | ((IData)(
                                                      ((((QData)((IData)(
                                                                         (0x0000000fU 
                                                                          & (IData)(vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_r__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_mem__DOT__gen_array__DOT__reg_rd_data)))) 
                                                         << 0x00000023U) 
                                                        | (((QData)((IData)(
                                                                            (vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_r__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_mem__DOT__gen_array__DOT__reg_rd_data 
                                                                             >> 4U))) 
                                                            << 3U) 
                                                           | (QData)((IData)(
                                                                             ((6U 
                                                                               & ((IData)(
                                                                                (vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_r__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_mem__DOT__gen_array__DOT__reg_rd_data 
                                                                                >> 0x00000024U)) 
                                                                                << 1U)) 
                                                                              | (1U 
                                                                                & (IData)(
                                                                                (vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_r__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_mem__DOT__gen_array__DOT__reg_rd_data 
                                                                                >> 0x00000026U)))))))) 
                                                       >> 0x00000020U)) 
                                              ^ vlSelfRef.tb_axi_bridge__DOT__exp_r
                                              [(0x000000ffU 
                                                & vlSelfRef.tb_axi_bridge__DOT__r_head)][1U])) 
                                          | vlSelfRef.tb_axi_bridge__DOT__exp_r
                                          [(0x000000ffU 
                                            & vlSelfRef.tb_axi_bridge__DOT__r_head)][2U]) 
                                         | vlSelfRef.tb_axi_bridge__DOT__exp_r
                                         [(0x000000ffU 
                                           & vlSelfRef.tb_axi_bridge__DOT__r_head)][3U]) 
                                        | vlSelfRef.tb_axi_bridge__DOT__exp_r
                                        [(0x000000ffU 
                                          & vlSelfRef.tb_axi_bridge__DOT__r_head)][4U]) 
                                       | vlSelfRef.tb_axi_bridge__DOT__exp_r
                                       [(0x000000ffU 
                                         & vlSelfRef.tb_axi_bridge__DOT__r_head)][5U]) 
                                      | vlSelfRef.tb_axi_bridge__DOT__exp_r
                                      [(0x000000ffU 
                                        & vlSelfRef.tb_axi_bridge__DOT__r_head)][6U]) 
                                     | vlSelfRef.tb_axi_bridge__DOT__exp_r
                                     [(0x000000ffU 
                                       & vlSelfRef.tb_axi_bridge__DOT__r_head)][7U]) 
                                    | vlSelfRef.tb_axi_bridge__DOT__exp_r
                                    [(0x000000ffU & vlSelfRef.tb_axi_bridge__DOT__r_head)][8U]) 
                                   | vlSelfRef.tb_axi_bridge__DOT__exp_r
                                   [(0x000000ffU & vlSelfRef.tb_axi_bridge__DOT__r_head)][9U]) 
                                  | vlSelfRef.tb_axi_bridge__DOT__exp_r
                                  [(0x000000ffU & vlSelfRef.tb_axi_bridge__DOT__r_head)][10U]) 
                                 | vlSelfRef.tb_axi_bridge__DOT__exp_r
                                 [(0x000000ffU & vlSelfRef.tb_axi_bridge__DOT__r_head)][11U]) 
                                | vlSelfRef.tb_axi_bridge__DOT__exp_r
                                [(0x000000ffU & vlSelfRef.tb_axi_bridge__DOT__r_head)][12U]) 
                               | vlSelfRef.tb_axi_bridge__DOT__exp_r
                               [(0x000000ffU & vlSelfRef.tb_axi_bridge__DOT__r_head)][13U]) 
                              | vlSelfRef.tb_axi_bridge__DOT__exp_r
                              [(0x000000ffU & vlSelfRef.tb_axi_bridge__DOT__r_head)][14U]) 
                             | vlSelfRef.tb_axi_bridge__DOT__exp_r
                             [(0x000000ffU & vlSelfRef.tb_axi_bridge__DOT__r_head)][15U])));
            __Vtask_tb_axi_bridge__DOT__chk__check_id_114 = 0x00000020U;
            vlSelfRef.tb_axi_bridge__DOT__out_r = ((IData)(1U) 
                                                   + vlSelfRef.tb_axi_bridge__DOT__out_r);
            vlSelfRef.tb_axi_bridge__DOT__assertion_hits[(0x0000003fU 
                                                          & __Vtask_tb_axi_bridge__DOT__chk__check_id_114)] 
                = ((IData)(1U) + ((0x23U >= (0x0000003fU 
                                             & __Vtask_tb_axi_bridge__DOT__chk__check_id_114))
                                   ? vlSelfRef.tb_axi_bridge__DOT__assertion_hits
                                  [(0x0000003fU & __Vtask_tb_axi_bridge__DOT__chk__check_id_114)]
                                   : 0U));
            if (VL_UNLIKELY(((1U & (~ (IData)(__Vtask_tb_axi_bridge__DOT__chk__consequent_116)))))) {
                if (VL_LIKELY(((0x23U >= (0x0000003fU 
                                          & __Vtask_tb_axi_bridge__DOT__chk__check_id_114))))) {
                    vlSelfRef.tb_axi_bridge__DOT__assertion_fails[(0x0000003fU 
                                                                   & __Vtask_tb_axi_bridge__DOT__chk__check_id_114)] 
                        = ((IData)(1U) + ((0x23U >= 
                                           (0x0000003fU 
                                            & __Vtask_tb_axi_bridge__DOT__chk__check_id_114))
                                           ? vlSelfRef.tb_axi_bridge__DOT__assertion_fails
                                          [(0x0000003fU 
                                            & __Vtask_tb_axi_bridge__DOT__chk__check_id_114)]
                                           : 0U));
                }
                VL_WRITEF_NX("ASSERT FAIL AXI-SVA-%02d time=%0t\n",3, 'T',-9
                             , '~',32,__Vtask_tb_axi_bridge__DOT__chk__check_id_114
                             , '#',64,VL_TIME_UNITED_Q(1000));
            }
            vlSelfRef.tb_axi_bridge__DOT__r_head = 
                ((IData)(1U) + vlSelfRef.tb_axi_bridge__DOT__r_head);
        }
        vlSelfRef.tb_axi_bridge__DOT__dst_r_stall = 
            ((IData)(vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_r__DOT__o_axi_rvalid) 
             & (~ (IData)(vlSelfRef.tb_axi_bridge__DOT__i_axi_rready)));
        vlSelfRef.tb_axi_bridge__DOT__prev_dst_r[0U] 
            = (IData)((((QData)((IData)((vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_r__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_mem__DOT__gen_array__DOT__reg_rd_data 
                                         >> 4U))) << 3U) 
                       | (QData)((IData)(((6U & ((IData)(
                                                         (vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_r__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_mem__DOT__gen_array__DOT__reg_rd_data 
                                                          >> 0x00000024U)) 
                                                 << 1U)) 
                                          | (1U & (IData)(
                                                          (vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_r__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_mem__DOT__gen_array__DOT__reg_rd_data 
                                                           >> 0x00000026U))))))));
        vlSelfRef.tb_axi_bridge__DOT__prev_dst_r[1U] 
            = ((0xfffffff8U & vlSelfRef.tb_axi_bridge__DOT__prev_dst_r[1U]) 
               | (IData)(((((QData)((IData)((vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_r__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_mem__DOT__gen_array__DOT__reg_rd_data 
                                             >> 4U))) 
                            << 3U) | (QData)((IData)(
                                                     ((6U 
                                                       & ((IData)(
                                                                  (vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_r__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_mem__DOT__gen_array__DOT__reg_rd_data 
                                                                   >> 0x00000024U)) 
                                                          << 1U)) 
                                                      | (1U 
                                                         & (IData)(
                                                                   (vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_r__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_mem__DOT__gen_array__DOT__reg_rd_data 
                                                                    >> 0x00000026U))))))) 
                          >> 0x00000020U)));
        vlSelfRef.tb_axi_bridge__DOT__prev_dst_r[1U] 
            = ((7U & vlSelfRef.tb_axi_bridge__DOT__prev_dst_r[1U]) 
               | (0x00000078U & ((IData)(vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_r__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_mem__DOT__gen_array__DOT__reg_rd_data) 
                                 << 3U)));
        vlSelfRef.tb_axi_bridge__DOT__prev_dst_r[2U] = 0U;
        vlSelfRef.tb_axi_bridge__DOT__prev_dst_r[3U] = 0U;
        vlSelfRef.tb_axi_bridge__DOT__prev_dst_r[4U] = 0U;
        vlSelfRef.tb_axi_bridge__DOT__prev_dst_r[5U] = 0U;
        vlSelfRef.tb_axi_bridge__DOT__prev_dst_r[6U] = 0U;
        vlSelfRef.tb_axi_bridge__DOT__prev_dst_r[7U] = 0U;
        vlSelfRef.tb_axi_bridge__DOT__prev_dst_r[8U] = 0U;
        vlSelfRef.tb_axi_bridge__DOT__prev_dst_r[9U] = 0U;
        vlSelfRef.tb_axi_bridge__DOT__prev_dst_r[10U] = 0U;
        vlSelfRef.tb_axi_bridge__DOT__prev_dst_r[11U] = 0U;
        vlSelfRef.tb_axi_bridge__DOT__prev_dst_r[12U] = 0U;
        vlSelfRef.tb_axi_bridge__DOT__prev_dst_r[13U] = 0U;
        vlSelfRef.tb_axi_bridge__DOT__prev_dst_r[14U] = 0U;
        vlSelfRef.tb_axi_bridge__DOT__prev_dst_r[15U] = 0U;
    } else {
        vlSelfRef.tb_axi_bridge__DOT__src_w_stall = 0U;
        vlSelfRef.tb_axi_bridge__DOT__w_tail = 0U;
        vlSelfRef.tb_axi_bridge__DOT__src_aw_stall = 0U;
        vlSelfRef.tb_axi_bridge__DOT__aw_tail = 0U;
        vlSelfRef.tb_axi_bridge__DOT__src_ar_stall = 0U;
        vlSelfRef.tb_axi_bridge__DOT__ar_tail = 0U;
        __Vtask_tb_axi_bridge__DOT__chk__consequent_71 
            = (1U & (~ (((((IData)(vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_aw__DOT__o_axi_awvalid) 
                           | (IData)(vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_w__DOT__o_axi_wvalid)) 
                          | (IData)(vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_ar__DOT__o_axi_arvalid)) 
                         | (IData)(vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_b__DOT__o_axi_bvalid)) 
                        | (IData)(vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_r__DOT__o_axi_rvalid))));
        vlSelfRef.tb_axi_bridge__DOT__dst_b_stall = 0U;
        vlSelfRef.tb_axi_bridge__DOT__b_head = 0U;
        vlSelfRef.tb_axi_bridge__DOT__out_b = 0U;
        __Vtask_tb_axi_bridge__DOT__chk__check_id_69 = 0x00000023U;
        vlSelfRef.tb_axi_bridge__DOT__assertion_hits[(0x0000003fU 
                                                      & __Vtask_tb_axi_bridge__DOT__chk__check_id_69)] 
            = ((IData)(1U) + ((0x23U >= (0x0000003fU 
                                         & __Vtask_tb_axi_bridge__DOT__chk__check_id_69))
                               ? vlSelfRef.tb_axi_bridge__DOT__assertion_hits
                              [(0x0000003fU & __Vtask_tb_axi_bridge__DOT__chk__check_id_69)]
                               : 0U));
        if (VL_UNLIKELY(((1U & (~ (IData)(__Vtask_tb_axi_bridge__DOT__chk__consequent_71)))))) {
            if (VL_LIKELY(((0x23U >= (0x0000003fU & __Vtask_tb_axi_bridge__DOT__chk__check_id_69))))) {
                vlSelfRef.tb_axi_bridge__DOT__assertion_fails[(0x0000003fU 
                                                               & __Vtask_tb_axi_bridge__DOT__chk__check_id_69)] 
                    = ((IData)(1U) + ((0x23U >= (0x0000003fU 
                                                 & __Vtask_tb_axi_bridge__DOT__chk__check_id_69))
                                       ? vlSelfRef.tb_axi_bridge__DOT__assertion_fails
                                      [(0x0000003fU 
                                        & __Vtask_tb_axi_bridge__DOT__chk__check_id_69)]
                                       : 0U));
            }
            VL_WRITEF_NX("ASSERT FAIL AXI-SVA-%02d time=%0t\n",3, 'T',-9
                         , '~',32,__Vtask_tb_axi_bridge__DOT__chk__check_id_69
                         , '#',64,VL_TIME_UNITED_Q(1000));
        }
        __Vtask_tb_axi_bridge__DOT__chk__consequent_119 
            = (1U & (~ (((((IData)(vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_aw__DOT__o_axi_awvalid) 
                           | (IData)(vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_w__DOT__o_axi_wvalid)) 
                          | (IData)(vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_ar__DOT__o_axi_arvalid)) 
                         | (IData)(vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_b__DOT__o_axi_bvalid)) 
                        | (IData)(vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_r__DOT__o_axi_rvalid))));
        vlSelfRef.tb_axi_bridge__DOT__dst_r_stall = 0U;
        vlSelfRef.tb_axi_bridge__DOT__r_head = 0U;
        vlSelfRef.tb_axi_bridge__DOT__out_r = 0U;
        __Vtask_tb_axi_bridge__DOT__chk__check_id_117 = 0x00000023U;
        vlSelfRef.tb_axi_bridge__DOT__assertion_hits[(0x0000003fU 
                                                      & __Vtask_tb_axi_bridge__DOT__chk__check_id_117)] 
            = ((IData)(1U) + ((0x23U >= (0x0000003fU 
                                         & __Vtask_tb_axi_bridge__DOT__chk__check_id_117))
                               ? vlSelfRef.tb_axi_bridge__DOT__assertion_hits
                              [(0x0000003fU & __Vtask_tb_axi_bridge__DOT__chk__check_id_117)]
                               : 0U));
        if (VL_UNLIKELY(((1U & (~ (IData)(__Vtask_tb_axi_bridge__DOT__chk__consequent_119)))))) {
            if (VL_LIKELY(((0x23U >= (0x0000003fU & __Vtask_tb_axi_bridge__DOT__chk__check_id_117))))) {
                vlSelfRef.tb_axi_bridge__DOT__assertion_fails[(0x0000003fU 
                                                               & __Vtask_tb_axi_bridge__DOT__chk__check_id_117)] 
                    = ((IData)(1U) + ((0x23U >= (0x0000003fU 
                                                 & __Vtask_tb_axi_bridge__DOT__chk__check_id_117))
                                       ? vlSelfRef.tb_axi_bridge__DOT__assertion_fails
                                      [(0x0000003fU 
                                        & __Vtask_tb_axi_bridge__DOT__chk__check_id_117)]
                                       : 0U));
            }
            VL_WRITEF_NX("ASSERT FAIL AXI-SVA-%02d time=%0t\n",3, 'T',-9
                         , '~',32,__Vtask_tb_axi_bridge__DOT__chk__check_id_117
                         , '#',64,VL_TIME_UNITED_Q(1000));
        }
    }
    if (vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_w__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__o_mem_wr_en) {
        __Vdly_Val__tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_w__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_mem__DOT__gen_array__DOT__reg_mem_98 
            = (((QData)((IData)(vlSelfRef.tb_axi_bridge__DOT__i_axi_wlast)) 
                << 0x00000024U) | (((QData)((IData)(vlSelfRef.tb_axi_bridge__DOT__i_axi_wstrb)) 
                                    << 0x00000020U) 
                                   | (QData)((IData)(vlSelfRef.tb_axi_bridge__DOT__i_axi_wdata))));
        __Vdly_Dim0__tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_w__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_mem__DOT__gen_array__DOT__reg_mem_99 
            = (0x0000000fU & (IData)(vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_w__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__reg_wbin));
        __Vdly_Set__tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_w__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_mem__DOT__gen_array__DOT__reg_mem_100 = 1U;
    }
    if (vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_ar__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__o_mem_wr_en) {
        __Vdly_Val__tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_ar__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_mem__DOT__gen_array__DOT__reg_mem_101[0U] 
            = (IData)((((QData)((IData)(vlSelfRef.tb_axi_bridge__DOT__i_axi_araddr)) 
                        << 4U) | (QData)((IData)(vlSelfRef.tb_axi_bridge__DOT__i_axi_arid))));
        __Vdly_Val__tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_ar__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_mem__DOT__gen_array__DOT__reg_mem_101[1U] 
            = ((0xfffffff0U & __Vdly_Val__tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_ar__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_mem__DOT__gen_array__DOT__reg_mem_101[1U]) 
               | (IData)(((((QData)((IData)(vlSelfRef.tb_axi_bridge__DOT__i_axi_araddr)) 
                            << 4U) | (QData)((IData)(vlSelfRef.tb_axi_bridge__DOT__i_axi_arid))) 
                          >> 0x00000020U)));
        __Vdly_Val__tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_ar__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_mem__DOT__gen_array__DOT__reg_mem_101[1U] 
            = ((0xfffc000fU & __Vdly_Val__tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_ar__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_mem__DOT__gen_array__DOT__reg_mem_101[1U]) 
               | (((IData)(vlSelfRef.tb_axi_bridge__DOT__i_axi_arlock) 
                   << 0x00000011U) | (((IData)(vlSelfRef.tb_axi_bridge__DOT__i_axi_arburst) 
                                       << 0x0000000fU) 
                                      | (((IData)(vlSelfRef.tb_axi_bridge__DOT__i_axi_arsize) 
                                          << 0x0000000cU) 
                                         | ((IData)(vlSelfRef.tb_axi_bridge__DOT__i_axi_arlen) 
                                            << 4U)))));
        __Vdly_Val__tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_ar__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_mem__DOT__gen_array__DOT__reg_mem_101[1U] 
            = ((0x0003ffffU & __Vdly_Val__tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_ar__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_mem__DOT__gen_array__DOT__reg_mem_101[1U]) 
               | (((IData)(vlSelfRef.tb_axi_bridge__DOT__i_axi_arregion) 
                   << 0x0000001dU) | (((IData)(vlSelfRef.tb_axi_bridge__DOT__i_axi_arqos) 
                                       << 0x00000019U) 
                                      | (((IData)(vlSelfRef.tb_axi_bridge__DOT__i_axi_arprot) 
                                          << 0x00000016U) 
                                         | ((IData)(vlSelfRef.tb_axi_bridge__DOT__i_axi_arcache) 
                                            << 0x00000012U)))));
        __Vdly_Val__tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_ar__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_mem__DOT__gen_array__DOT__reg_mem_101[2U] 
            = (1U & ((0x0003ffffU & ((IData)(vlSelfRef.tb_axi_bridge__DOT__i_axi_arregion) 
                                     >> 3U)) | ((0x0003ffffU 
                                                 & ((IData)(vlSelfRef.tb_axi_bridge__DOT__i_axi_arqos) 
                                                    >> 7U)) 
                                                | ((0x0003ffffU 
                                                    & ((IData)(vlSelfRef.tb_axi_bridge__DOT__i_axi_arprot) 
                                                       >> 0x0000000aU)) 
                                                   | ((IData)(vlSelfRef.tb_axi_bridge__DOT__i_axi_arcache) 
                                                      >> 0x0000000eU)))));
        __Vdly_Dim0__tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_ar__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_mem__DOT__gen_array__DOT__reg_mem_102 
            = (3U & (IData)(vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_ar__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__reg_wbin));
        __Vdly_Set__tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_ar__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_mem__DOT__gen_array__DOT__reg_mem_103 = 1U;
    }
    if (vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_aw__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__o_mem_wr_en) {
        __Vdly_Val__tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_aw__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_mem__DOT__gen_array__DOT__reg_mem_104[0U] 
            = (IData)((((QData)((IData)(vlSelfRef.tb_axi_bridge__DOT__i_axi_awaddr)) 
                        << 4U) | (QData)((IData)(vlSelfRef.tb_axi_bridge__DOT__i_axi_awid))));
        __Vdly_Val__tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_aw__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_mem__DOT__gen_array__DOT__reg_mem_104[1U] 
            = ((0xfffffff0U & __Vdly_Val__tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_aw__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_mem__DOT__gen_array__DOT__reg_mem_104[1U]) 
               | (IData)(((((QData)((IData)(vlSelfRef.tb_axi_bridge__DOT__i_axi_awaddr)) 
                            << 4U) | (QData)((IData)(vlSelfRef.tb_axi_bridge__DOT__i_axi_awid))) 
                          >> 0x00000020U)));
        __Vdly_Val__tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_aw__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_mem__DOT__gen_array__DOT__reg_mem_104[1U] 
            = ((0xfffc000fU & __Vdly_Val__tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_aw__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_mem__DOT__gen_array__DOT__reg_mem_104[1U]) 
               | (((IData)(vlSelfRef.tb_axi_bridge__DOT__i_axi_awlock) 
                   << 0x00000011U) | (((IData)(vlSelfRef.tb_axi_bridge__DOT__i_axi_awburst) 
                                       << 0x0000000fU) 
                                      | (((IData)(vlSelfRef.tb_axi_bridge__DOT__i_axi_awsize) 
                                          << 0x0000000cU) 
                                         | ((IData)(vlSelfRef.tb_axi_bridge__DOT__i_axi_awlen) 
                                            << 4U)))));
        __Vdly_Val__tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_aw__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_mem__DOT__gen_array__DOT__reg_mem_104[1U] 
            = ((0x0003ffffU & __Vdly_Val__tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_aw__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_mem__DOT__gen_array__DOT__reg_mem_104[1U]) 
               | (((IData)(vlSelfRef.tb_axi_bridge__DOT__i_axi_awregion) 
                   << 0x0000001dU) | (((IData)(vlSelfRef.tb_axi_bridge__DOT__i_axi_awqos) 
                                       << 0x00000019U) 
                                      | (((IData)(vlSelfRef.tb_axi_bridge__DOT__i_axi_awprot) 
                                          << 0x00000016U) 
                                         | ((IData)(vlSelfRef.tb_axi_bridge__DOT__i_axi_awcache) 
                                            << 0x00000012U)))));
        __Vdly_Val__tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_aw__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_mem__DOT__gen_array__DOT__reg_mem_104[2U] 
            = (1U & ((0x0003ffffU & ((IData)(vlSelfRef.tb_axi_bridge__DOT__i_axi_awregion) 
                                     >> 3U)) | ((0x0003ffffU 
                                                 & ((IData)(vlSelfRef.tb_axi_bridge__DOT__i_axi_awqos) 
                                                    >> 7U)) 
                                                | ((0x0003ffffU 
                                                    & ((IData)(vlSelfRef.tb_axi_bridge__DOT__i_axi_awprot) 
                                                       >> 0x0000000aU)) 
                                                   | ((IData)(vlSelfRef.tb_axi_bridge__DOT__i_axi_awcache) 
                                                      >> 0x0000000eU)))));
        __Vdly_Dim0__tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_aw__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_mem__DOT__gen_array__DOT__reg_mem_105 
            = (3U & (IData)(vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_aw__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__reg_wbin));
        __Vdly_Set__tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_aw__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_mem__DOT__gen_array__DOT__reg_mem_106 = 1U;
    }
    if (__Vdly_Set__tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_w__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_mem__DOT__gen_array__DOT__reg_mem_100) {
        vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_w__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_mem__DOT__gen_array__DOT__reg_mem[__Vdly_Dim0__tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_w__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_mem__DOT__gen_array__DOT__reg_mem_99] 
            = __Vdly_Val__tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_w__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_mem__DOT__gen_array__DOT__reg_mem_98;
    }
    if (__Vdly_Set__tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_ar__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_mem__DOT__gen_array__DOT__reg_mem_103) {
        vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_ar__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_mem__DOT__gen_array__DOT__reg_mem[__Vdly_Dim0__tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_ar__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_mem__DOT__gen_array__DOT__reg_mem_102][0U] 
            = __Vdly_Val__tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_ar__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_mem__DOT__gen_array__DOT__reg_mem_101[0U];
        vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_ar__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_mem__DOT__gen_array__DOT__reg_mem[__Vdly_Dim0__tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_ar__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_mem__DOT__gen_array__DOT__reg_mem_102][1U] 
            = __Vdly_Val__tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_ar__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_mem__DOT__gen_array__DOT__reg_mem_101[1U];
        vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_ar__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_mem__DOT__gen_array__DOT__reg_mem[__Vdly_Dim0__tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_ar__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_mem__DOT__gen_array__DOT__reg_mem_102][2U] 
            = __Vdly_Val__tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_ar__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_mem__DOT__gen_array__DOT__reg_mem_101[2U];
    }
    if (__Vdly_Set__tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_aw__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_mem__DOT__gen_array__DOT__reg_mem_106) {
        vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_aw__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_mem__DOT__gen_array__DOT__reg_mem[__Vdly_Dim0__tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_aw__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_mem__DOT__gen_array__DOT__reg_mem_105][0U] 
            = __Vdly_Val__tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_aw__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_mem__DOT__gen_array__DOT__reg_mem_104[0U];
        vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_aw__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_mem__DOT__gen_array__DOT__reg_mem[__Vdly_Dim0__tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_aw__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_mem__DOT__gen_array__DOT__reg_mem_105][1U] 
            = __Vdly_Val__tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_aw__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_mem__DOT__gen_array__DOT__reg_mem_104[1U];
        vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_aw__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_mem__DOT__gen_array__DOT__reg_mem[__Vdly_Dim0__tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_aw__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_mem__DOT__gen_array__DOT__reg_mem_105][2U] 
            = __Vdly_Val__tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_aw__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_mem__DOT__gen_array__DOT__reg_mem_104[2U];
    }
    vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_b__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_mem__DOT__gen_array__DOT__reg_rd_data 
        = vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_b__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_mem__DOT__gen_array__DOT__reg_mem
        [(3U & (IData)(vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_b__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_rd__DOT__w_rbin_nxt))];
    vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_r__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_mem__DOT__gen_array__DOT__reg_rd_data 
        = vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_r__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_mem__DOT__gen_array__DOT__reg_mem
        [(0x0000000fU & (IData)(vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_r__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_rd__DOT__w_rbin_nxt))];
}

void Vtb_axi_bridge___024root___nba_sequent__TOP__4(Vtb_axi_bridge___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_axi_bridge___024root___nba_sequent__TOP__4\n"); );
    Vtb_axi_bridge__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Body
    if (vlSelfRef.tb_axi_bridge__DOT__i_rst_n_mgr) {
        vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_w__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_rd__DOT__reg_ack_rd 
            = (2U == Vtb_axi_bridge__ConstPool__TABLE_1
               [(((IData)(vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_w__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_rd__DOT__u_sync_wr_gray__DOT__o_data) 
                  << 3U) | ((4U & ((IData)(vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_w__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_rd__DOT__u_sync_req__DOT__gen_bit_cell__BRA__0__KET____DOT__u_vlsit_afifo_cell_sync__DOT__gen_sync2__DOT__gen_rn__DOT__u_dont_touch_sync2ff__DOT__reg_chain) 
                                   << 1U)) | (IData)(vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_w__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_rd__DOT__reg_fsm_srst_current_state)))]);
        vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_ar__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_rd__DOT__reg_ack_rd 
            = (2U == Vtb_axi_bridge__ConstPool__TABLE_5
               [(((IData)(vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_ar__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_rd__DOT__u_sync_wr_gray__DOT__o_data) 
                  << 3U) | ((4U & ((IData)(vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_ar__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_rd__DOT__u_sync_req__DOT__gen_bit_cell__BRA__0__KET____DOT__u_vlsit_afifo_cell_sync__DOT__gen_sync2__DOT__gen_rn__DOT__u_dont_touch_sync2ff__DOT__reg_chain) 
                                   << 1U)) | (IData)(vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_ar__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_rd__DOT__reg_fsm_srst_current_state)))]);
        vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_aw__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_rd__DOT__reg_ack_rd 
            = (2U == Vtb_axi_bridge__ConstPool__TABLE_5
               [(((IData)(vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_aw__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_rd__DOT__u_sync_wr_gray__DOT__o_data) 
                  << 3U) | ((4U & ((IData)(vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_aw__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_rd__DOT__u_sync_req__DOT__gen_bit_cell__BRA__0__KET____DOT__u_vlsit_afifo_cell_sync__DOT__gen_sync2__DOT__gen_rn__DOT__u_dont_touch_sync2ff__DOT__reg_chain) 
                                   << 1U)) | (IData)(vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_aw__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_rd__DOT__reg_fsm_srst_current_state)))]);
        vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_r__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__reg_req_wr 
            = ((1U == Vtb_axi_bridge__ConstPool__TABLE_3
                [(0x00000200U | (((IData)(vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_r__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__u_sync_rd_gray__DOT__o_data) 
                                  << 4U) | ((8U & ((IData)(vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_r__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__u_sync_ack__DOT__gen_bit_cell__BRA__0__KET____DOT__u_vlsit_afifo_cell_sync__DOT__gen_sync2__DOT__gen_rn__DOT__u_dont_touch_sync2ff__DOT__reg_chain) 
                                                   << 2U)) 
                                            | (IData)(vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_r__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__reg_fsm_srst_current_state))))]) 
               | ((2U == Vtb_axi_bridge__ConstPool__TABLE_3
                   [(0x00000200U | (((IData)(vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_r__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__u_sync_rd_gray__DOT__o_data) 
                                     << 4U) | ((8U 
                                                & ((IData)(vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_r__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__u_sync_ack__DOT__gen_bit_cell__BRA__0__KET____DOT__u_vlsit_afifo_cell_sync__DOT__gen_sync2__DOT__gen_rn__DOT__u_dont_touch_sync2ff__DOT__reg_chain) 
                                                   << 2U)) 
                                               | (IData)(vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_r__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__reg_fsm_srst_current_state))))]) 
                  | (3U == Vtb_axi_bridge__ConstPool__TABLE_3
                     [(0x00000200U | (((IData)(vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_r__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__u_sync_rd_gray__DOT__o_data) 
                                       << 4U) | ((8U 
                                                  & ((IData)(vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_r__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__u_sync_ack__DOT__gen_bit_cell__BRA__0__KET____DOT__u_vlsit_afifo_cell_sync__DOT__gen_sync2__DOT__gen_rn__DOT__u_dont_touch_sync2ff__DOT__reg_chain) 
                                                     << 2U)) 
                                                 | (IData)(vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_r__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__reg_fsm_srst_current_state))))])));
        vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_b__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__reg_wgray 
            = (((IData)(vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_b__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__w_wbin_nxt) 
                >> 1U) ^ (IData)(vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_b__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__w_wbin_nxt));
        vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_ar__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_rd__DOT__reg_rgray 
            = (((IData)(vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_ar__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_rd__DOT__w_rbin_nxt) 
                >> 1U) ^ (IData)(vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_ar__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_rd__DOT__w_rbin_nxt));
        vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_aw__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_rd__DOT__reg_rgray 
            = (((IData)(vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_aw__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_rd__DOT__w_rbin_nxt) 
                >> 1U) ^ (IData)(vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_aw__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_rd__DOT__w_rbin_nxt));
        vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_r__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__reg_wgray 
            = (((IData)(vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_r__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__w_wbin_nxt) 
                >> 1U) ^ (IData)(vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_r__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__w_wbin_nxt));
        vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_w__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_rd__DOT__reg_rgray 
            = (((IData)(vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_w__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_rd__DOT__w_rbin_nxt) 
                >> 1U) ^ (IData)(vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_w__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_rd__DOT__w_rbin_nxt));
        vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_b__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__reg_wbin 
            = vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_b__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__w_wbin_nxt;
        vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_r__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__reg_wbin 
            = vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_r__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__w_wbin_nxt;
        vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_b__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__reg_req_wr 
            = ((1U == Vtb_axi_bridge__ConstPool__TABLE_6
                [(0x00000080U | (((IData)(vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_b__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__u_sync_rd_gray__DOT__o_data) 
                                  << 4U) | ((8U & ((IData)(vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_b__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__u_sync_ack__DOT__gen_bit_cell__BRA__0__KET____DOT__u_vlsit_afifo_cell_sync__DOT__gen_sync2__DOT__gen_rn__DOT__u_dont_touch_sync2ff__DOT__reg_chain) 
                                                   << 2U)) 
                                            | (IData)(vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_b__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__reg_fsm_srst_current_state))))]) 
               | ((2U == Vtb_axi_bridge__ConstPool__TABLE_6
                   [(0x00000080U | (((IData)(vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_b__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__u_sync_rd_gray__DOT__o_data) 
                                     << 4U) | ((8U 
                                                & ((IData)(vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_b__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__u_sync_ack__DOT__gen_bit_cell__BRA__0__KET____DOT__u_vlsit_afifo_cell_sync__DOT__gen_sync2__DOT__gen_rn__DOT__u_dont_touch_sync2ff__DOT__reg_chain) 
                                                   << 2U)) 
                                               | (IData)(vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_b__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__reg_fsm_srst_current_state))))]) 
                  | (3U == Vtb_axi_bridge__ConstPool__TABLE_6
                     [(0x00000080U | (((IData)(vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_b__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__u_sync_rd_gray__DOT__o_data) 
                                       << 4U) | ((8U 
                                                  & ((IData)(vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_b__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__u_sync_ack__DOT__gen_bit_cell__BRA__0__KET____DOT__u_vlsit_afifo_cell_sync__DOT__gen_sync2__DOT__gen_rn__DOT__u_dont_touch_sync2ff__DOT__reg_chain) 
                                                     << 2U)) 
                                                 | (IData)(vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_b__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__reg_fsm_srst_current_state))))])));
    } else {
        vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_w__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_rd__DOT__reg_ack_rd = 0U;
        vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_ar__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_rd__DOT__reg_ack_rd = 0U;
        vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_aw__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_rd__DOT__reg_ack_rd = 0U;
        vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_r__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__reg_req_wr = 0U;
        vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_b__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__reg_wgray = 0U;
        vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_ar__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_rd__DOT__reg_rgray = 0U;
        vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_aw__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_rd__DOT__reg_rgray = 0U;
        vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_r__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__reg_wgray = 0U;
        vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_w__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_rd__DOT__reg_rgray = 0U;
        vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_b__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__reg_wbin = 0U;
        vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_r__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__reg_wbin = 0U;
        vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_b__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__reg_req_wr = 0U;
    }
    vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_w__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_rd__DOT__u_sync_req__DOT__gen_bit_cell__BRA__0__KET____DOT__u_vlsit_afifo_cell_sync__DOT__gen_sync2__DOT__gen_rn__DOT__u_dont_touch_sync2ff__DOT__reg_chain 
        = vlSelfRef.__Vdly__tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_w__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_rd__DOT__u_sync_req__DOT__gen_bit_cell__BRA__0__KET____DOT__u_vlsit_afifo_cell_sync__DOT__gen_sync2__DOT__gen_rn__DOT__u_dont_touch_sync2ff__DOT__reg_chain_72;
    vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_w__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_rd__DOT__u_sync_wr_gray__DOT__o_data 
        = ((((4U & ((IData)(vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_w__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_rd__DOT__u_sync_wr_gray__DOT__gen_bit_cell__BRA__4__KET____DOT__u_vlsit_afifo_cell_sync__DOT__gen_sync2__DOT__gen_rn__DOT__u_dont_touch_sync2ff__DOT__reg_chain) 
                    << 1U)) | ((2U & (IData)(vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_w__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_rd__DOT__u_sync_wr_gray__DOT__gen_bit_cell__BRA__3__KET____DOT__u_vlsit_afifo_cell_sync__DOT__gen_sync2__DOT__gen_rn__DOT__u_dont_touch_sync2ff__DOT__reg_chain)) 
                               | (1U & ((IData)(vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_w__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_rd__DOT__u_sync_wr_gray__DOT__gen_bit_cell__BRA__2__KET____DOT__u_vlsit_afifo_cell_sync__DOT__gen_sync2__DOT__gen_rn__DOT__u_dont_touch_sync2ff__DOT__reg_chain) 
                                        >> 1U)))) << 2U) 
           | ((2U & (IData)(vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_w__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_rd__DOT__u_sync_wr_gray__DOT__gen_bit_cell__BRA__1__KET____DOT__u_vlsit_afifo_cell_sync__DOT__gen_sync2__DOT__gen_rn__DOT__u_dont_touch_sync2ff__DOT__reg_chain)) 
              | (1U & ((IData)(vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_w__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_rd__DOT__u_sync_wr_gray__DOT__gen_bit_cell__BRA__0__KET____DOT__u_vlsit_afifo_cell_sync__DOT__gen_sync2__DOT__gen_rn__DOT__u_dont_touch_sync2ff__DOT__reg_chain) 
                       >> 1U))));
    vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_w__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_rd__DOT__reg_fsm_srst_current_state 
        = vlSelfRef.__Vdly__tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_w__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_rd__DOT__reg_fsm_srst_current_state_65;
    vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_ar__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_rd__DOT__u_sync_req__DOT__gen_bit_cell__BRA__0__KET____DOT__u_vlsit_afifo_cell_sync__DOT__gen_sync2__DOT__gen_rn__DOT__u_dont_touch_sync2ff__DOT__reg_chain 
        = vlSelfRef.__Vdly__tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_ar__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_rd__DOT__u_sync_req__DOT__gen_bit_cell__BRA__0__KET____DOT__u_vlsit_afifo_cell_sync__DOT__gen_sync2__DOT__gen_rn__DOT__u_dont_touch_sync2ff__DOT__reg_chain_80;
    vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_ar__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_rd__DOT__u_sync_wr_gray__DOT__o_data 
        = ((4U & ((IData)(vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_ar__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_rd__DOT__u_sync_wr_gray__DOT__gen_bit_cell__BRA__2__KET____DOT__u_vlsit_afifo_cell_sync__DOT__gen_sync2__DOT__gen_rn__DOT__u_dont_touch_sync2ff__DOT__reg_chain) 
                  << 1U)) | ((2U & (IData)(vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_ar__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_rd__DOT__u_sync_wr_gray__DOT__gen_bit_cell__BRA__1__KET____DOT__u_vlsit_afifo_cell_sync__DOT__gen_sync2__DOT__gen_rn__DOT__u_dont_touch_sync2ff__DOT__reg_chain)) 
                             | (1U & ((IData)(vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_ar__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_rd__DOT__u_sync_wr_gray__DOT__gen_bit_cell__BRA__0__KET____DOT__u_vlsit_afifo_cell_sync__DOT__gen_sync2__DOT__gen_rn__DOT__u_dont_touch_sync2ff__DOT__reg_chain) 
                                      >> 1U))));
    vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_ar__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_rd__DOT__reg_fsm_srst_current_state 
        = vlSelfRef.__Vdly__tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_ar__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_rd__DOT__reg_fsm_srst_current_state_75;
    vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_aw__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_rd__DOT__u_sync_req__DOT__gen_bit_cell__BRA__0__KET____DOT__u_vlsit_afifo_cell_sync__DOT__gen_sync2__DOT__gen_rn__DOT__u_dont_touch_sync2ff__DOT__reg_chain 
        = vlSelfRef.__Vdly__tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_aw__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_rd__DOT__u_sync_req__DOT__gen_bit_cell__BRA__0__KET____DOT__u_vlsit_afifo_cell_sync__DOT__gen_sync2__DOT__gen_rn__DOT__u_dont_touch_sync2ff__DOT__reg_chain_88;
    vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_aw__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_rd__DOT__u_sync_wr_gray__DOT__o_data 
        = ((4U & ((IData)(vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_aw__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_rd__DOT__u_sync_wr_gray__DOT__gen_bit_cell__BRA__2__KET____DOT__u_vlsit_afifo_cell_sync__DOT__gen_sync2__DOT__gen_rn__DOT__u_dont_touch_sync2ff__DOT__reg_chain) 
                  << 1U)) | ((2U & (IData)(vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_aw__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_rd__DOT__u_sync_wr_gray__DOT__gen_bit_cell__BRA__1__KET____DOT__u_vlsit_afifo_cell_sync__DOT__gen_sync2__DOT__gen_rn__DOT__u_dont_touch_sync2ff__DOT__reg_chain)) 
                             | (1U & ((IData)(vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_aw__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_rd__DOT__u_sync_wr_gray__DOT__gen_bit_cell__BRA__0__KET____DOT__u_vlsit_afifo_cell_sync__DOT__gen_sync2__DOT__gen_rn__DOT__u_dont_touch_sync2ff__DOT__reg_chain) 
                                      >> 1U))));
    vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_aw__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_rd__DOT__reg_fsm_srst_current_state 
        = vlSelfRef.__Vdly__tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_aw__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_rd__DOT__reg_fsm_srst_current_state_83;
    vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_r__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__u_sync_ack__DOT__gen_bit_cell__BRA__0__KET____DOT__u_vlsit_afifo_cell_sync__DOT__gen_sync2__DOT__gen_rn__DOT__u_dont_touch_sync2ff__DOT__reg_chain 
        = vlSelfRef.__Vdly__tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_r__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__u_sync_ack__DOT__gen_bit_cell__BRA__0__KET____DOT__u_vlsit_afifo_cell_sync__DOT__gen_sync2__DOT__gen_rn__DOT__u_dont_touch_sync2ff__DOT__reg_chain_62;
    vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_r__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__reg_fsm_srst_current_state 
        = vlSelfRef.__Vdly__tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_r__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__reg_fsm_srst_current_state_54;
    vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_r__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__u_sync_rd_gray__DOT__o_data 
        = ((((4U & ((IData)(vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_r__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__u_sync_rd_gray__DOT__gen_bit_cell__BRA__4__KET____DOT__u_vlsit_afifo_cell_sync__DOT__gen_sync2__DOT__gen_rn__DOT__u_dont_touch_sync2ff__DOT__reg_chain) 
                    << 1U)) | ((2U & (IData)(vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_r__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__u_sync_rd_gray__DOT__gen_bit_cell__BRA__3__KET____DOT__u_vlsit_afifo_cell_sync__DOT__gen_sync2__DOT__gen_rn__DOT__u_dont_touch_sync2ff__DOT__reg_chain)) 
                               | (1U & ((IData)(vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_r__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__u_sync_rd_gray__DOT__gen_bit_cell__BRA__2__KET____DOT__u_vlsit_afifo_cell_sync__DOT__gen_sync2__DOT__gen_rn__DOT__u_dont_touch_sync2ff__DOT__reg_chain) 
                                        >> 1U)))) << 2U) 
           | ((2U & (IData)(vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_r__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__u_sync_rd_gray__DOT__gen_bit_cell__BRA__1__KET____DOT__u_vlsit_afifo_cell_sync__DOT__gen_sync2__DOT__gen_rn__DOT__u_dont_touch_sync2ff__DOT__reg_chain)) 
              | (1U & ((IData)(vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_r__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__u_sync_rd_gray__DOT__gen_bit_cell__BRA__0__KET____DOT__u_vlsit_afifo_cell_sync__DOT__gen_sync2__DOT__gen_rn__DOT__u_dont_touch_sync2ff__DOT__reg_chain) 
                       >> 1U))));
    vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_b__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__u_sync_ack__DOT__gen_bit_cell__BRA__0__KET____DOT__u_vlsit_afifo_cell_sync__DOT__gen_sync2__DOT__gen_rn__DOT__u_dont_touch_sync2ff__DOT__reg_chain 
        = vlSelfRef.__Vdly__tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_b__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__u_sync_ack__DOT__gen_bit_cell__BRA__0__KET____DOT__u_vlsit_afifo_cell_sync__DOT__gen_sync2__DOT__gen_rn__DOT__u_dont_touch_sync2ff__DOT__reg_chain_97;
    vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_b__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__reg_fsm_srst_current_state 
        = vlSelfRef.__Vdly__tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_b__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__reg_fsm_srst_current_state_91;
    vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_b__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__u_sync_rd_gray__DOT__o_data 
        = ((4U & ((IData)(vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_b__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__u_sync_rd_gray__DOT__gen_bit_cell__BRA__2__KET____DOT__u_vlsit_afifo_cell_sync__DOT__gen_sync2__DOT__gen_rn__DOT__u_dont_touch_sync2ff__DOT__reg_chain) 
                  << 1U)) | ((2U & (IData)(vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_b__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__u_sync_rd_gray__DOT__gen_bit_cell__BRA__1__KET____DOT__u_vlsit_afifo_cell_sync__DOT__gen_sync2__DOT__gen_rn__DOT__u_dont_touch_sync2ff__DOT__reg_chain)) 
                             | (1U & ((IData)(vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_b__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__u_sync_rd_gray__DOT__gen_bit_cell__BRA__0__KET____DOT__u_vlsit_afifo_cell_sync__DOT__gen_sync2__DOT__gen_rn__DOT__u_dont_touch_sync2ff__DOT__reg_chain) 
                                      >> 1U))));
    vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_b__DOT__o_axi_bready 
        = (1U & (~ ((IData)(vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_b__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__reg_sw_rst_busy) 
                    | ((IData)(vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_b__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__reg_wgray) 
                       == (6U ^ (IData)(vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_b__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__u_sync_rd_gray__DOT__o_data))))));
    vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_ar__DOT__o_axi_arvalid 
        = (1U & (~ (((IData)(vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_ar__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_rd__DOT__reg_rgray) 
                     == (IData)(vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_ar__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_rd__DOT__u_sync_wr_gray__DOT__o_data)) 
                    | ((0U != (IData)(vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_ar__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_rd__DOT__reg_fsm_srst_current_state)) 
                       | ((IData)(vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_ar__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_rd__DOT__u_sync_req__DOT__gen_bit_cell__BRA__0__KET____DOT__u_vlsit_afifo_cell_sync__DOT__gen_sync2__DOT__gen_rn__DOT__u_dont_touch_sync2ff__DOT__reg_chain) 
                          >> 1U)))));
    vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_aw__DOT__o_axi_awvalid 
        = (1U & (~ (((IData)(vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_aw__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_rd__DOT__reg_rgray) 
                     == (IData)(vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_aw__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_rd__DOT__u_sync_wr_gray__DOT__o_data)) 
                    | ((0U != (IData)(vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_aw__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_rd__DOT__reg_fsm_srst_current_state)) 
                       | ((IData)(vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_aw__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_rd__DOT__u_sync_req__DOT__gen_bit_cell__BRA__0__KET____DOT__u_vlsit_afifo_cell_sync__DOT__gen_sync2__DOT__gen_rn__DOT__u_dont_touch_sync2ff__DOT__reg_chain) 
                          >> 1U)))));
    vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_r__DOT__o_axi_rready 
        = (1U & (~ ((IData)(vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_r__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__reg_sw_rst_busy) 
                    | ((IData)(vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_r__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__reg_wgray) 
                       == (0x18U ^ (IData)(vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_r__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__u_sync_rd_gray__DOT__o_data))))));
    vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_w__DOT__o_axi_wvalid 
        = (1U & (~ (((IData)(vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_w__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_rd__DOT__reg_rgray) 
                     == (IData)(vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_w__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_rd__DOT__u_sync_wr_gray__DOT__o_data)) 
                    | ((0U != (IData)(vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_w__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_rd__DOT__reg_fsm_srst_current_state)) 
                       | ((IData)(vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_w__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_rd__DOT__u_sync_req__DOT__gen_bit_cell__BRA__0__KET____DOT__u_vlsit_afifo_cell_sync__DOT__gen_sync2__DOT__gen_rn__DOT__u_dont_touch_sync2ff__DOT__reg_chain) 
                          >> 1U)))));
}

void Vtb_axi_bridge___024root___eval_body__nba(Vtb_axi_bridge___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_axi_bridge___024root___eval_body__nba\n"); );
    Vtb_axi_bridge__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Body
    if ((0x000000000000000aULL & vlSelfRef.__VnbaTriggered[0U])) {
        Vtb_axi_bridge___024root___nba_sequent__TOP__0(vlSelf);
    }
    if ((5ULL & vlSelfRef.__VnbaTriggered[0U])) {
        Vtb_axi_bridge___024root___nba_sequent__TOP__1(vlSelf);
    }
    if ((2ULL & vlSelfRef.__VnbaTriggered[0U])) {
        Vtb_axi_bridge___024root___nba_sequent__TOP__2(vlSelf);
    }
    if ((1ULL & vlSelfRef.__VnbaTriggered[0U])) {
        Vtb_axi_bridge___024root___nba_sequent__TOP__3(vlSelf);
    }
    if ((0x000000000000000aULL & vlSelfRef.__VnbaTriggered[0U])) {
        Vtb_axi_bridge___024root___nba_sequent__TOP__4(vlSelf);
    }
    if ((5ULL & vlSelfRef.__VnbaTriggered[0U])) {
        {
            // Inlined CFunc: _nba_sequent__TOP__5
            vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_w__DOT__o_axi_wready 
                = (1U & (~ ((IData)(vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_w__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__reg_sw_rst_busy) 
                            | ((IData)(vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_w__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__reg_wgray) 
                               == (0x18U ^ (IData)(vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_w__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__u_sync_rd_gray__DOT__o_data))))));
            vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_aw__DOT__o_axi_awready 
                = (1U & (~ ((IData)(vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_aw__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__reg_sw_rst_busy) 
                            | ((IData)(vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_aw__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__reg_wgray) 
                               == (6U ^ (IData)(vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_aw__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__u_sync_rd_gray__DOT__o_data))))));
            vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_ar__DOT__o_axi_arready 
                = (1U & (~ ((IData)(vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_ar__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__reg_sw_rst_busy) 
                            | ((IData)(vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_ar__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__reg_wgray) 
                               == (6U ^ (IData)(vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_ar__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__u_sync_rd_gray__DOT__o_data))))));
            vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_r__DOT__o_axi_rvalid 
                = (1U & (~ (((IData)(vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_r__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_rd__DOT__reg_rgray) 
                             == (IData)(vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_r__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_rd__DOT__u_sync_wr_gray__DOT__o_data)) 
                            | ((0U != (IData)(vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_r__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_rd__DOT__reg_fsm_srst_current_state)) 
                               | ((IData)(vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_r__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_rd__DOT__u_sync_req__DOT__gen_bit_cell__BRA__0__KET____DOT__u_vlsit_afifo_cell_sync__DOT__gen_sync2__DOT__gen_rn__DOT__u_dont_touch_sync2ff__DOT__reg_chain) 
                                  >> 1U)))));
            vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_b__DOT__o_axi_bvalid 
                = (1U & (~ (((IData)(vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_b__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_rd__DOT__reg_rgray) 
                             == (IData)(vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_b__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_rd__DOT__u_sync_wr_gray__DOT__o_data)) 
                            | ((0U != (IData)(vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_b__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_rd__DOT__reg_fsm_srst_current_state)) 
                               | ((IData)(vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_b__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_rd__DOT__u_sync_req__DOT__gen_bit_cell__BRA__0__KET____DOT__u_vlsit_afifo_cell_sync__DOT__gen_sync2__DOT__gen_rn__DOT__u_dont_touch_sync2ff__DOT__reg_chain) 
                                  >> 1U)))));
            if (vlSelfRef.tb_axi_bridge__DOT__i_rst_n_sub) {
                vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_w__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__reg_wbin 
                    = vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_w__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__w_wbin_nxt;
                vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_ar__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__reg_wbin 
                    = vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_ar__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__w_wbin_nxt;
                vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_aw__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__reg_wbin 
                    = vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_aw__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__w_wbin_nxt;
            } else {
                vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_w__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__reg_wbin = 0U;
                vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_ar__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__reg_wbin = 0U;
                vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_aw__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__reg_wbin = 0U;
            }
        }
    }
    if ((2ULL & vlSelfRef.__VnbaTriggered[0U])) {
        {
            // Inlined CFunc: _nba_sequent__TOP__6
            if (vlSelfRef.__Vdly_Set__tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_b__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_mem__DOT__gen_array__DOT__reg_mem_112) {
                vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_b__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_mem__DOT__gen_array__DOT__reg_mem[vlSelfRef.__Vdly_Dim0__tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_b__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_mem__DOT__gen_array__DOT__reg_mem_111] 
                    = vlSelfRef.__Vdly_Val__tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_b__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_mem__DOT__gen_array__DOT__reg_mem_110;
            }
            if (vlSelfRef.__Vdly_Set__tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_r__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_mem__DOT__gen_array__DOT__reg_mem_109) {
                vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_r__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_mem__DOT__gen_array__DOT__reg_mem[vlSelfRef.__Vdly_Dim0__tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_r__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_mem__DOT__gen_array__DOT__reg_mem_108] 
                    = vlSelfRef.__Vdly_Val__tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_r__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_mem__DOT__gen_array__DOT__reg_mem_107;
            }
        }
    }
    if ((0x00000000000001fbULL & vlSelfRef.__VnbaTriggered[0U])) {
        {
            // Inlined CFunc: _nba_comb__TOP__0
            vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_b__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__o_mem_wr_en 
                = ((IData)(vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_b__DOT__o_axi_bready) 
                   & (IData)(vlSelfRef.tb_axi_bridge__DOT__i_axi_bvalid));
            vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_ar__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_rd__DOT__w_rbin_nxt 
                = (7U & ((- (IData)((1U != (IData)(vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_ar__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_rd__DOT__reg_fsm_srst_current_state)))) 
                         & ((IData)(vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_ar__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_rd__DOT__reg_rbin) 
                            + ((IData)(vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_ar__DOT__o_axi_arvalid) 
                               & (IData)(vlSelfRef.tb_axi_bridge__DOT__i_axi_arready)))));
            vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_aw__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_rd__DOT__w_rbin_nxt 
                = (7U & ((- (IData)((1U != (IData)(vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_aw__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_rd__DOT__reg_fsm_srst_current_state)))) 
                         & ((IData)(vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_aw__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_rd__DOT__reg_rbin) 
                            + ((IData)(vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_aw__DOT__o_axi_awvalid) 
                               & (IData)(vlSelfRef.tb_axi_bridge__DOT__i_axi_awready)))));
            vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_r__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__o_mem_wr_en 
                = ((IData)(vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_r__DOT__o_axi_rready) 
                   & (IData)(vlSelfRef.tb_axi_bridge__DOT__i_axi_rvalid));
            vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_w__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_rd__DOT__w_rbin_nxt 
                = (0x0000001fU & ((- (IData)((1U != (IData)(vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_w__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_rd__DOT__reg_fsm_srst_current_state)))) 
                                  & ((IData)(vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_w__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_rd__DOT__reg_rbin) 
                                     + ((IData)(vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_w__DOT__o_axi_wvalid) 
                                        & (IData)(vlSelfRef.tb_axi_bridge__DOT__i_axi_wready)))));
            vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_b__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__w_wbin_nxt 
                = (7U & ((- (IData)((2U != (IData)(vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_b__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__reg_fsm_srst_current_state)))) 
                         & ((IData)(vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_b__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__reg_wbin) 
                            + (IData)(vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_b__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__o_mem_wr_en))));
            vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_r__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__w_wbin_nxt 
                = (0x0000001fU & ((- (IData)((2U != (IData)(vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_r__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__reg_fsm_srst_current_state)))) 
                                  & ((IData)(vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_r__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__reg_wbin) 
                                     + (IData)(vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_r__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__o_mem_wr_en))));
        }
    }
    if ((0x00000000000001f7ULL & vlSelfRef.__VnbaTriggered[0U])) {
        {
            // Inlined CFunc: _nba_comb__TOP__1
            vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_w__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__o_mem_wr_en 
                = ((IData)(vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_w__DOT__o_axi_wready) 
                   & (IData)(vlSelfRef.tb_axi_bridge__DOT__i_axi_wvalid));
            vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_aw__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__o_mem_wr_en 
                = ((IData)(vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_aw__DOT__o_axi_awready) 
                   & (IData)(vlSelfRef.tb_axi_bridge__DOT__i_axi_awvalid));
            vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_ar__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__o_mem_wr_en 
                = ((IData)(vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_ar__DOT__o_axi_arready) 
                   & (IData)(vlSelfRef.tb_axi_bridge__DOT__i_axi_arvalid));
            vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_r__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_rd__DOT__w_rbin_nxt 
                = (0x0000001fU & ((- (IData)((1U != (IData)(vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_r__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_rd__DOT__reg_fsm_srst_current_state)))) 
                                  & ((IData)(vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_r__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_rd__DOT__reg_rbin) 
                                     + ((IData)(vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_r__DOT__o_axi_rvalid) 
                                        & (IData)(vlSelfRef.tb_axi_bridge__DOT__i_axi_rready)))));
            vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_b__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_rd__DOT__w_rbin_nxt 
                = (7U & ((- (IData)((1U != (IData)(vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_b__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_rd__DOT__reg_fsm_srst_current_state)))) 
                         & ((IData)(vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_b__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_rd__DOT__reg_rbin) 
                            + ((IData)(vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_b__DOT__o_axi_bvalid) 
                               & (IData)(vlSelfRef.tb_axi_bridge__DOT__i_axi_bready)))));
            vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_w__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__w_wbin_nxt 
                = (0x0000001fU & ((- (IData)((2U != (IData)(vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_w__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__reg_fsm_srst_current_state)))) 
                                  & ((IData)(vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_w__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__reg_wbin) 
                                     + (IData)(vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_w__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__o_mem_wr_en))));
            vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_aw__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__w_wbin_nxt 
                = (7U & ((- (IData)((2U != (IData)(vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_aw__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__reg_fsm_srst_current_state)))) 
                         & ((IData)(vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_aw__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__reg_wbin) 
                            + (IData)(vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_aw__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__o_mem_wr_en))));
            vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_ar__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__w_wbin_nxt 
                = (7U & ((- (IData)((2U != (IData)(vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_ar__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__reg_fsm_srst_current_state)))) 
                         & ((IData)(vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_ar__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__reg_wbin) 
                            + (IData)(vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_ar__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__o_mem_wr_en))));
        }
    }
}

void Vtb_axi_bridge___024root___timing_ready(Vtb_axi_bridge___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_axi_bridge___024root___timing_ready\n"); );
    Vtb_axi_bridge__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Body
    if ((0x0000000000000020ULL & vlSelfRef.__VactTriggered[0U])) {
        vlSelfRef.__VtrigSched_h8c92a91c__0.ready("@(negedge tb_axi_bridge.i_clk_sub)");
    }
    if ((0x0000000000000040ULL & vlSelfRef.__VactTriggered[0U])) {
        vlSelfRef.__VtrigSched_h046e81df__0.ready("@(negedge tb_axi_bridge.i_clk_mgr)");
    }
    if ((1ULL & vlSelfRef.__VactTriggered[0U])) {
        vlSelfRef.__VtrigSched_h8c92a665__0.ready("@(posedge tb_axi_bridge.i_clk_sub)");
    }
    if ((0x0000000000000080ULL & vlSelfRef.__VactTriggered[0U])) {
        vlSelfRef.__VtrigSched_h955be2db__0.ready("@( (((32'sh6 == tb_axi_bridge.out_aw) & (32'sh12 == tb_axi_bridge.out_w)) & (32'sh6 == tb_axi_bridge.out_ar)))");
    }
    if ((2ULL & vlSelfRef.__VactTriggered[0U])) {
        vlSelfRef.__VtrigSched_h046e831a__0.ready("@(posedge tb_axi_bridge.i_clk_mgr)");
    }
    if ((0x0000000000000100ULL & vlSelfRef.__VactTriggered[0U])) {
        vlSelfRef.__VtrigSched_h18cb2d65__0.ready("@( ((32'sh6 == tb_axi_bridge.out_b) & (32'sh12 == tb_axi_bridge.out_r)))");
    }
}

void Vtb_axi_bridge___024root___timing_resume(Vtb_axi_bridge___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_axi_bridge___024root___timing_resume\n"); );
    Vtb_axi_bridge__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Body
    vlSelfRef.__VtrigSched_h8c92a91c__0.moveToResumeQueue(
                                                          "@(negedge tb_axi_bridge.i_clk_sub)");
    vlSelfRef.__VtrigSched_h046e81df__0.moveToResumeQueue(
                                                          "@(negedge tb_axi_bridge.i_clk_mgr)");
    vlSelfRef.__VtrigSched_h8c92a665__0.moveToResumeQueue(
                                                          "@(posedge tb_axi_bridge.i_clk_sub)");
    vlSelfRef.__VtrigSched_h955be2db__0.moveToResumeQueue(
                                                          "@( (((32'sh6 == tb_axi_bridge.out_aw) & (32'sh12 == tb_axi_bridge.out_w)) & (32'sh6 == tb_axi_bridge.out_ar)))");
    vlSelfRef.__VtrigSched_h046e831a__0.moveToResumeQueue(
                                                          "@(posedge tb_axi_bridge.i_clk_mgr)");
    vlSelfRef.__VtrigSched_h18cb2d65__0.moveToResumeQueue(
                                                          "@( ((32'sh6 == tb_axi_bridge.out_b) & (32'sh12 == tb_axi_bridge.out_r)))");
    vlSelfRef.__VtrigSched_h8c92a91c__0.resume("@(negedge tb_axi_bridge.i_clk_sub)");
    vlSelfRef.__VtrigSched_h046e81df__0.resume("@(negedge tb_axi_bridge.i_clk_mgr)");
    vlSelfRef.__VtrigSched_h8c92a665__0.resume("@(posedge tb_axi_bridge.i_clk_sub)");
    vlSelfRef.__VtrigSched_h955be2db__0.resume("@( (((32'sh6 == tb_axi_bridge.out_aw) & (32'sh12 == tb_axi_bridge.out_w)) & (32'sh6 == tb_axi_bridge.out_ar)))");
    vlSelfRef.__VtrigSched_h046e831a__0.resume("@(posedge tb_axi_bridge.i_clk_mgr)");
    vlSelfRef.__VtrigSched_h18cb2d65__0.resume("@( ((32'sh6 == tb_axi_bridge.out_b) & (32'sh12 == tb_axi_bridge.out_r)))");
    if ((0x0000000000000010ULL & vlSelfRef.__VactTriggered[0U])) {
        vlSelfRef.__VdlySched.resume();
    }
}

void Vtb_axi_bridge___024root___trigger_orInto__act_vec_vec(VlUnpacked<QData/*63:0*/, 1> &out, const VlUnpacked<QData/*63:0*/, 1> &in) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_axi_bridge___024root___trigger_orInto__act_vec_vec\n"); );
    // Locals
    IData/*31:0*/ n;
    // Body
    n = 0U;
    do {
        out[n] = (out[n] | in[n]);
        n = ((IData)(1U) + n);
    } while ((0U >= n));
}

void Vtb_axi_bridge___024root___trigger_clear__act(VlUnpacked<QData/*63:0*/, 1> &out) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_axi_bridge___024root___trigger_clear__act\n"); );
    // Locals
    IData/*31:0*/ n;
    // Body
    n = 0U;
    do {
        out[n] = 0ULL;
        n = ((IData)(1U) + n);
    } while ((1U > n));
}

void Vtb_axi_bridge___024root____VbeforeTrig_h8c92a91c__0(Vtb_axi_bridge___024root* vlSelf, const char* __VeventDescription) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_axi_bridge___024root____VbeforeTrig_h8c92a91c__0\n"); );
    Vtb_axi_bridge__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Locals
    VlUnpacked<QData/*63:0*/, 1> __VTmp;
    // Body
    __VTmp[0U] = (QData)((IData)(((((~ (IData)(vlSelfRef.tb_axi_bridge__DOT__i_clk_sub)) 
                                    & (IData)(vlSelfRef.__Vtrigprevexpr___TOP__tb_axi_bridge__DOT__i_clk_sub__0)) 
                                   << 5U) | ((IData)(vlSelfRef.tb_axi_bridge__DOT__i_clk_sub) 
                                             & (~ (IData)(vlSelfRef.__Vtrigprevexpr___TOP__tb_axi_bridge__DOT__i_clk_sub__0))))));
    vlSelfRef.__Vtrigprevexpr___TOP__tb_axi_bridge__DOT__i_clk_sub__0 
        = vlSelfRef.tb_axi_bridge__DOT__i_clk_sub;
    if ((1ULL & __VTmp[0U])) {
        vlSelfRef.__VtrigSched_h8c92a665__0.ready(__VeventDescription);
        vlSelfRef.__VtrigSched_h8c92a665__0.ready(__VeventDescription);
        vlSelfRef.__VtrigSched_h8c92a665__0.ready(__VeventDescription);
        vlSelfRef.__VtrigSched_h8c92a665__0.ready(__VeventDescription);
        vlSelfRef.__VtrigSched_h8c92a665__0.ready(__VeventDescription);
        vlSelfRef.__VtrigSched_h8c92a665__0.ready(__VeventDescription);
    }
    if ((0x0000000000000020ULL & __VTmp[0U])) {
        vlSelfRef.__VtrigSched_h8c92a91c__0.ready(__VeventDescription);
        vlSelfRef.__VtrigSched_h8c92a91c__0.ready(__VeventDescription);
        vlSelfRef.__VtrigSched_h8c92a91c__0.ready(__VeventDescription);
        vlSelfRef.__VtrigSched_h8c92a91c__0.ready(__VeventDescription);
        vlSelfRef.__VtrigSched_h8c92a91c__0.ready(__VeventDescription);
        vlSelfRef.__VtrigSched_h8c92a91c__0.ready(__VeventDescription);
        vlSelfRef.__VtrigSched_h8c92a91c__0.ready(__VeventDescription);
        vlSelfRef.__VtrigSched_h8c92a91c__0.ready(__VeventDescription);
        vlSelfRef.__VtrigSched_h8c92a91c__0.ready(__VeventDescription);
    }
    vlSelfRef.__VactTriggeredAcc[0U] = (vlSelfRef.__VactTriggeredAcc[0U] 
                                        | __VTmp[0U]);
}

void Vtb_axi_bridge___024root____VbeforeTrig_h046e81df__0(Vtb_axi_bridge___024root* vlSelf, const char* __VeventDescription) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_axi_bridge___024root____VbeforeTrig_h046e81df__0\n"); );
    Vtb_axi_bridge__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Locals
    VlUnpacked<QData/*63:0*/, 1> __VTmp;
    // Body
    __VTmp[0U] = (QData)((IData)(((((~ (IData)(vlSelfRef.tb_axi_bridge__DOT__i_clk_mgr)) 
                                    & (IData)(vlSelfRef.__Vtrigprevexpr___TOP__tb_axi_bridge__DOT__i_clk_mgr__0)) 
                                   << 6U) | (((IData)(vlSelfRef.tb_axi_bridge__DOT__i_clk_mgr) 
                                              & (~ (IData)(vlSelfRef.__Vtrigprevexpr___TOP__tb_axi_bridge__DOT__i_clk_mgr__0))) 
                                             << 1U))));
    vlSelfRef.__Vtrigprevexpr___TOP__tb_axi_bridge__DOT__i_clk_mgr__0 
        = vlSelfRef.tb_axi_bridge__DOT__i_clk_mgr;
    if ((2ULL & __VTmp[0U])) {
        vlSelfRef.__VtrigSched_h046e831a__0.ready(__VeventDescription);
        vlSelfRef.__VtrigSched_h046e831a__0.ready(__VeventDescription);
        vlSelfRef.__VtrigSched_h046e831a__0.ready(__VeventDescription);
    }
    if ((0x0000000000000040ULL & __VTmp[0U])) {
        vlSelfRef.__VtrigSched_h046e81df__0.ready(__VeventDescription);
        vlSelfRef.__VtrigSched_h046e81df__0.ready(__VeventDescription);
        vlSelfRef.__VtrigSched_h046e81df__0.ready(__VeventDescription);
        vlSelfRef.__VtrigSched_h046e81df__0.ready(__VeventDescription);
        vlSelfRef.__VtrigSched_h046e81df__0.ready(__VeventDescription);
    }
    vlSelfRef.__VactTriggeredAcc[0U] = (vlSelfRef.__VactTriggeredAcc[0U] 
                                        | __VTmp[0U]);
}

void Vtb_axi_bridge___024root____VbeforeTrig_h8c92a665__0(Vtb_axi_bridge___024root* vlSelf, const char* __VeventDescription) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_axi_bridge___024root____VbeforeTrig_h8c92a665__0\n"); );
    Vtb_axi_bridge__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Locals
    VlUnpacked<QData/*63:0*/, 1> __VTmp;
    // Body
    __VTmp[0U] = (QData)((IData)(((((~ (IData)(vlSelfRef.tb_axi_bridge__DOT__i_clk_sub)) 
                                    & (IData)(vlSelfRef.__Vtrigprevexpr___TOP__tb_axi_bridge__DOT__i_clk_sub__0)) 
                                   << 5U) | ((IData)(vlSelfRef.tb_axi_bridge__DOT__i_clk_sub) 
                                             & (~ (IData)(vlSelfRef.__Vtrigprevexpr___TOP__tb_axi_bridge__DOT__i_clk_sub__0))))));
    vlSelfRef.__Vtrigprevexpr___TOP__tb_axi_bridge__DOT__i_clk_sub__0 
        = vlSelfRef.tb_axi_bridge__DOT__i_clk_sub;
    if ((1ULL & __VTmp[0U])) {
        vlSelfRef.__VtrigSched_h8c92a665__0.ready(__VeventDescription);
        vlSelfRef.__VtrigSched_h8c92a665__0.ready(__VeventDescription);
        vlSelfRef.__VtrigSched_h8c92a665__0.ready(__VeventDescription);
        vlSelfRef.__VtrigSched_h8c92a665__0.ready(__VeventDescription);
        vlSelfRef.__VtrigSched_h8c92a665__0.ready(__VeventDescription);
        vlSelfRef.__VtrigSched_h8c92a665__0.ready(__VeventDescription);
    }
    if ((0x0000000000000020ULL & __VTmp[0U])) {
        vlSelfRef.__VtrigSched_h8c92a91c__0.ready(__VeventDescription);
        vlSelfRef.__VtrigSched_h8c92a91c__0.ready(__VeventDescription);
        vlSelfRef.__VtrigSched_h8c92a91c__0.ready(__VeventDescription);
        vlSelfRef.__VtrigSched_h8c92a91c__0.ready(__VeventDescription);
        vlSelfRef.__VtrigSched_h8c92a91c__0.ready(__VeventDescription);
        vlSelfRef.__VtrigSched_h8c92a91c__0.ready(__VeventDescription);
        vlSelfRef.__VtrigSched_h8c92a91c__0.ready(__VeventDescription);
        vlSelfRef.__VtrigSched_h8c92a91c__0.ready(__VeventDescription);
        vlSelfRef.__VtrigSched_h8c92a91c__0.ready(__VeventDescription);
    }
    vlSelfRef.__VactTriggeredAcc[0U] = (vlSelfRef.__VactTriggeredAcc[0U] 
                                        | __VTmp[0U]);
}

void Vtb_axi_bridge___024root____VbeforeTrig_h955be2db__0(Vtb_axi_bridge___024root* vlSelf, const char* __VeventDescription) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_axi_bridge___024root____VbeforeTrig_h955be2db__0\n"); );
    Vtb_axi_bridge__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Locals
    VlUnpacked<QData/*63:0*/, 1> __VTmp;
    CData/*0:0*/ __Vtrigprevexpr_h325807e2__0;
    __Vtrigprevexpr_h325807e2__0 = 0;
    // Body
    __Vtrigprevexpr_h325807e2__0 = (((6U == vlSelfRef.tb_axi_bridge__DOT__out_aw) 
                                     & (0x00000012U 
                                        == vlSelfRef.tb_axi_bridge__DOT__out_w)) 
                                    & (6U == vlSelfRef.tb_axi_bridge__DOT__out_ar));
    __VTmp[0U] = (QData)((IData)((((IData)(__Vtrigprevexpr_h325807e2__0) 
                                   != (IData)(vlSelfRef.__Vtrigprevexpr_h325807e2__1)) 
                                  << 7U)));
    vlSelfRef.__Vtrigprevexpr_h325807e2__1 = __Vtrigprevexpr_h325807e2__0;
    if ((0x0000000000000080ULL & __VTmp[0U])) {
        vlSelfRef.__VtrigSched_h955be2db__0.ready(__VeventDescription);
    }
    vlSelfRef.__VactTriggeredAcc[0U] = (vlSelfRef.__VactTriggeredAcc[0U] 
                                        | __VTmp[0U]);
}

void Vtb_axi_bridge___024root____VbeforeTrig_h046e831a__0(Vtb_axi_bridge___024root* vlSelf, const char* __VeventDescription) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_axi_bridge___024root____VbeforeTrig_h046e831a__0\n"); );
    Vtb_axi_bridge__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Locals
    VlUnpacked<QData/*63:0*/, 1> __VTmp;
    // Body
    __VTmp[0U] = (QData)((IData)(((((~ (IData)(vlSelfRef.tb_axi_bridge__DOT__i_clk_mgr)) 
                                    & (IData)(vlSelfRef.__Vtrigprevexpr___TOP__tb_axi_bridge__DOT__i_clk_mgr__0)) 
                                   << 6U) | (((IData)(vlSelfRef.tb_axi_bridge__DOT__i_clk_mgr) 
                                              & (~ (IData)(vlSelfRef.__Vtrigprevexpr___TOP__tb_axi_bridge__DOT__i_clk_mgr__0))) 
                                             << 1U))));
    vlSelfRef.__Vtrigprevexpr___TOP__tb_axi_bridge__DOT__i_clk_mgr__0 
        = vlSelfRef.tb_axi_bridge__DOT__i_clk_mgr;
    if ((2ULL & __VTmp[0U])) {
        vlSelfRef.__VtrigSched_h046e831a__0.ready(__VeventDescription);
        vlSelfRef.__VtrigSched_h046e831a__0.ready(__VeventDescription);
        vlSelfRef.__VtrigSched_h046e831a__0.ready(__VeventDescription);
    }
    if ((0x0000000000000040ULL & __VTmp[0U])) {
        vlSelfRef.__VtrigSched_h046e81df__0.ready(__VeventDescription);
        vlSelfRef.__VtrigSched_h046e81df__0.ready(__VeventDescription);
        vlSelfRef.__VtrigSched_h046e81df__0.ready(__VeventDescription);
        vlSelfRef.__VtrigSched_h046e81df__0.ready(__VeventDescription);
        vlSelfRef.__VtrigSched_h046e81df__0.ready(__VeventDescription);
    }
    vlSelfRef.__VactTriggeredAcc[0U] = (vlSelfRef.__VactTriggeredAcc[0U] 
                                        | __VTmp[0U]);
}

void Vtb_axi_bridge___024root____VbeforeTrig_h18cb2d65__0(Vtb_axi_bridge___024root* vlSelf, const char* __VeventDescription) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_axi_bridge___024root____VbeforeTrig_h18cb2d65__0\n"); );
    Vtb_axi_bridge__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Locals
    VlUnpacked<QData/*63:0*/, 1> __VTmp;
    CData/*0:0*/ __Vtrigprevexpr_hb5e7ad64__0;
    __Vtrigprevexpr_hb5e7ad64__0 = 0;
    // Body
    __Vtrigprevexpr_hb5e7ad64__0 = ((6U == vlSelfRef.tb_axi_bridge__DOT__out_b) 
                                    & (0x00000012U 
                                       == vlSelfRef.tb_axi_bridge__DOT__out_r));
    __VTmp[0U] = (QData)((IData)((((IData)(__Vtrigprevexpr_hb5e7ad64__0) 
                                   != (IData)(vlSelfRef.__Vtrigprevexpr_hb5e7ad64__1)) 
                                  << 8U)));
    vlSelfRef.__Vtrigprevexpr_hb5e7ad64__1 = __Vtrigprevexpr_hb5e7ad64__0;
    if ((0x0000000000000100ULL & __VTmp[0U])) {
        vlSelfRef.__VtrigSched_h18cb2d65__0.ready(__VeventDescription);
    }
    vlSelfRef.__VactTriggeredAcc[0U] = (vlSelfRef.__VactTriggeredAcc[0U] 
                                        | __VTmp[0U]);
}

#ifdef VL_DEBUG
void Vtb_axi_bridge___024root___eval_debug_assertions(Vtb_axi_bridge___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_axi_bridge___024root___eval_debug_assertions\n"); );
    Vtb_axi_bridge__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
}
#endif  // VL_DEBUG
