// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Design implementation internals
// See Vtb_axi_bridge.h for the primary calling header

#include "Vtb_axi_bridge__pch.h"

void Vtb_axi_bridge___024root___timing_ready(Vtb_axi_bridge___024root* vlSelf);

VL_ATTR_COLD void Vtb_axi_bridge___024root___eval_static(Vtb_axi_bridge___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_axi_bridge___024root___eval_static\n"); );
    Vtb_axi_bridge__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Body
    {
        // Inlined CFunc: _eval_static__TOP
        vlSelfRef.tb_axi_bridge__DOT__i_clk_sub = 0U;
        vlSelfRef.tb_axi_bridge__DOT__i_clk_mgr = 0U;
    }
    vlSelfRef.__VactTriggered[0U] = (0x0000000000000080ULL 
                                     | vlSelfRef.__VactTriggered[0U]);
    vlSelfRef.__VactTriggered[0U] = (0x0000000000000100ULL 
                                     | vlSelfRef.__VactTriggered[0U]);
    vlSelfRef.__Vtrigprevexpr___TOP__tb_axi_bridge__DOT__i_clk_sub__0 = 0U;
    vlSelfRef.__Vtrigprevexpr___TOP__tb_axi_bridge__DOT__i_clk_mgr__0 = 0U;
    vlSelfRef.__Vtrigprevexpr___TOP__tb_axi_bridge__DOT__i_rst_n_sub__0 
        = vlSelfRef.tb_axi_bridge__DOT__i_rst_n_sub;
    vlSelfRef.__Vtrigprevexpr___TOP__tb_axi_bridge__DOT__i_rst_n_mgr__0 
        = vlSelfRef.tb_axi_bridge__DOT__i_rst_n_mgr;
    vlSelfRef.__Vtrigprevexpr_h325807e2__1 = (((6U 
                                                == vlSelfRef.tb_axi_bridge__DOT__out_aw) 
                                               & (0x00000012U 
                                                  == vlSelfRef.tb_axi_bridge__DOT__out_w)) 
                                              & (6U 
                                                 == vlSelfRef.tb_axi_bridge__DOT__out_ar));
    vlSelfRef.__Vtrigprevexpr_hb5e7ad64__1 = ((6U == vlSelfRef.tb_axi_bridge__DOT__out_b) 
                                              & (0x00000012U 
                                                 == vlSelfRef.tb_axi_bridge__DOT__out_r));
    Vtb_axi_bridge___024root___timing_ready(vlSelf);
    do {
        vlSelfRef.__VactTriggeredAcc[vlSelfRef.__Vi] 
            = vlSelfRef.__VactTriggered[vlSelfRef.__Vi];
        vlSelfRef.__Vi = ((IData)(1U) + vlSelfRef.__Vi);
    } while ((0U >= vlSelfRef.__Vi));
}

#ifdef VL_DEBUG
VL_ATTR_COLD void Vtb_axi_bridge___024root___dump_triggers__stl(const VlUnpacked<QData/*63:0*/, 1> &triggers, const std::string &tag);
#endif  // VL_DEBUG
VL_ATTR_COLD bool Vtb_axi_bridge___024root___trigger_anySet__stl(const VlUnpacked<QData/*63:0*/, 1> &in);
VL_ATTR_COLD void Vtb_axi_bridge___024root___stl_sequent__TOP__0(Vtb_axi_bridge___024root* vlSelf);

VL_ATTR_COLD bool Vtb_axi_bridge___024root___eval_stl(Vtb_axi_bridge___024root* vlSelf, CData/*0:0*/ firstIteration) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_axi_bridge___024root___eval_stl\n"); );
    Vtb_axi_bridge__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Locals
    CData/*0:0*/ __VstlExecute;
    // Body
    vlSelfRef.__VstlTriggered[0U] = ((0xfffffffffffffffeULL 
                                      & vlSelfRef.__VstlTriggered[0U]) 
                                     | (IData)((IData)(firstIteration)));
#ifdef VL_DEBUG
    if (VL_UNLIKELY(vlSymsp->_vm_contextp__->debug())) {
        Vtb_axi_bridge___024root___dump_triggers__stl(vlSelfRef.__VstlTriggered, "stl"s);
    }
#endif
    __VstlExecute = Vtb_axi_bridge___024root___trigger_anySet__stl(vlSelfRef.__VstlTriggered);
    if (__VstlExecute) {
        {
            // Inlined CFunc: _eval_body__stl
            if ((1ULL & vlSelfRef.__VstlTriggered[0U])) {
                Vtb_axi_bridge___024root___stl_sequent__TOP__0(vlSelf);
            }
        }
    }
    return (__VstlExecute);
}

VL_ATTR_COLD void Vtb_axi_bridge___024root___eval_dump_triggers__stl(Vtb_axi_bridge___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_axi_bridge___024root___eval_dump_triggers__stl\n"); );
    Vtb_axi_bridge__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Body
#ifdef VL_DEBUG
    Vtb_axi_bridge___024root___dump_triggers__stl(vlSelfRef.__VstlTriggered, "stl"s);
#endif
}

#ifdef VL_DEBUG
VL_ATTR_COLD void Vtb_axi_bridge___024root___dump_triggers__ico(const VlUnpacked<QData/*63:0*/, 1> &triggers, const std::string &tag);
#endif  // VL_DEBUG

VL_ATTR_COLD void Vtb_axi_bridge___024root___eval_dump_triggers__ico(Vtb_axi_bridge___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_axi_bridge___024root___eval_dump_triggers__ico\n"); );
    Vtb_axi_bridge__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Body
#ifdef VL_DEBUG
    Vtb_axi_bridge___024root___dump_triggers__ico(vlSelfRef.__VicoTriggered, "ico"s);
#endif
}

#ifdef VL_DEBUG
VL_ATTR_COLD void Vtb_axi_bridge___024root___dump_triggers__act(const VlUnpacked<QData/*63:0*/, 1> &triggers, const std::string &tag);
#endif  // VL_DEBUG

VL_ATTR_COLD void Vtb_axi_bridge___024root___eval_dump_triggers__act(Vtb_axi_bridge___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_axi_bridge___024root___eval_dump_triggers__act\n"); );
    Vtb_axi_bridge__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Body
#ifdef VL_DEBUG
    Vtb_axi_bridge___024root___dump_triggers__act(vlSelfRef.__VactTriggered, "act"s);
#endif
}

VL_ATTR_COLD void Vtb_axi_bridge___024root___eval_dump_triggers__nba(Vtb_axi_bridge___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_axi_bridge___024root___eval_dump_triggers__nba\n"); );
    Vtb_axi_bridge__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Body
#ifdef VL_DEBUG
    Vtb_axi_bridge___024root___dump_triggers__act(vlSelfRef.__VnbaTriggered, "nba"s);
#endif
}

VL_ATTR_COLD void Vtb_axi_bridge___024root___eval_dump_triggers__obs(Vtb_axi_bridge___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_axi_bridge___024root___eval_dump_triggers__obs\n"); );
    Vtb_axi_bridge__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
}

VL_ATTR_COLD void Vtb_axi_bridge___024root___eval_dump_triggers__react(Vtb_axi_bridge___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_axi_bridge___024root___eval_dump_triggers__react\n"); );
    Vtb_axi_bridge__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
}

VL_ATTR_COLD void Vtb_axi_bridge___024root___eval_final(Vtb_axi_bridge___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_axi_bridge___024root___eval_final\n"); );
    Vtb_axi_bridge__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
}

#ifdef VL_DEBUG
VL_ATTR_COLD void Vtb_axi_bridge___024root___dump_triggers__stl(const VlUnpacked<QData/*63:0*/, 1> &triggers, const std::string &tag) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_axi_bridge___024root___dump_triggers__stl\n"); );
    // Body
    if ((1U & (~ (IData)(Vtb_axi_bridge___024root___trigger_anySet__stl(triggers))))) {
        VL_DBG_MSGS("         No '" + tag + "' region triggers active\n");
    }
    if ((1U & (IData)(triggers[0U]))) {
        VL_DBG_MSGS("         '" + tag + "' region trigger index 0 is active: Internal 'stl' trigger - first iteration\n");
    }
}
#endif  // VL_DEBUG

VL_ATTR_COLD bool Vtb_axi_bridge___024root___trigger_anySet__stl(const VlUnpacked<QData/*63:0*/, 1> &in) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_axi_bridge___024root___trigger_anySet__stl\n"); );
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

VL_ATTR_COLD void Vtb_axi_bridge___024root___stl_sequent__TOP__0(Vtb_axi_bridge___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_axi_bridge___024root___stl_sequent__TOP__0\n"); );
    Vtb_axi_bridge__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Body
    vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_ar__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_rd__DOT__u_sync_wr_gray__DOT__o_data 
        = ((4U & ((IData)(vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_ar__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_rd__DOT__u_sync_wr_gray__DOT__gen_bit_cell__BRA__2__KET____DOT__u_vlsit_afifo_cell_sync__DOT__gen_sync2__DOT__gen_rn__DOT__u_dont_touch_sync2ff__DOT__reg_chain) 
                  << 1U)) | ((2U & (IData)(vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_ar__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_rd__DOT__u_sync_wr_gray__DOT__gen_bit_cell__BRA__1__KET____DOT__u_vlsit_afifo_cell_sync__DOT__gen_sync2__DOT__gen_rn__DOT__u_dont_touch_sync2ff__DOT__reg_chain)) 
                             | (1U & ((IData)(vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_ar__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_rd__DOT__u_sync_wr_gray__DOT__gen_bit_cell__BRA__0__KET____DOT__u_vlsit_afifo_cell_sync__DOT__gen_sync2__DOT__gen_rn__DOT__u_dont_touch_sync2ff__DOT__reg_chain) 
                                      >> 1U))));
    vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_aw__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_rd__DOT__u_sync_wr_gray__DOT__o_data 
        = ((4U & ((IData)(vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_aw__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_rd__DOT__u_sync_wr_gray__DOT__gen_bit_cell__BRA__2__KET____DOT__u_vlsit_afifo_cell_sync__DOT__gen_sync2__DOT__gen_rn__DOT__u_dont_touch_sync2ff__DOT__reg_chain) 
                  << 1U)) | ((2U & (IData)(vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_aw__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_rd__DOT__u_sync_wr_gray__DOT__gen_bit_cell__BRA__1__KET____DOT__u_vlsit_afifo_cell_sync__DOT__gen_sync2__DOT__gen_rn__DOT__u_dont_touch_sync2ff__DOT__reg_chain)) 
                             | (1U & ((IData)(vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_aw__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_rd__DOT__u_sync_wr_gray__DOT__gen_bit_cell__BRA__0__KET____DOT__u_vlsit_afifo_cell_sync__DOT__gen_sync2__DOT__gen_rn__DOT__u_dont_touch_sync2ff__DOT__reg_chain) 
                                      >> 1U))));
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
    vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_b__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__u_sync_rd_gray__DOT__o_data 
        = ((4U & ((IData)(vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_b__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__u_sync_rd_gray__DOT__gen_bit_cell__BRA__2__KET____DOT__u_vlsit_afifo_cell_sync__DOT__gen_sync2__DOT__gen_rn__DOT__u_dont_touch_sync2ff__DOT__reg_chain) 
                  << 1U)) | ((2U & (IData)(vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_b__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__u_sync_rd_gray__DOT__gen_bit_cell__BRA__1__KET____DOT__u_vlsit_afifo_cell_sync__DOT__gen_sync2__DOT__gen_rn__DOT__u_dont_touch_sync2ff__DOT__reg_chain)) 
                             | (1U & ((IData)(vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_b__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__u_sync_rd_gray__DOT__gen_bit_cell__BRA__0__KET____DOT__u_vlsit_afifo_cell_sync__DOT__gen_sync2__DOT__gen_rn__DOT__u_dont_touch_sync2ff__DOT__reg_chain) 
                                      >> 1U))));
    vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_r__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_rd__DOT__u_sync_wr_gray__DOT__o_data 
        = ((((4U & ((IData)(vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_r__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_rd__DOT__u_sync_wr_gray__DOT__gen_bit_cell__BRA__4__KET____DOT__u_vlsit_afifo_cell_sync__DOT__gen_sync2__DOT__gen_rn__DOT__u_dont_touch_sync2ff__DOT__reg_chain) 
                    << 1U)) | ((2U & (IData)(vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_r__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_rd__DOT__u_sync_wr_gray__DOT__gen_bit_cell__BRA__3__KET____DOT__u_vlsit_afifo_cell_sync__DOT__gen_sync2__DOT__gen_rn__DOT__u_dont_touch_sync2ff__DOT__reg_chain)) 
                               | (1U & ((IData)(vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_r__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_rd__DOT__u_sync_wr_gray__DOT__gen_bit_cell__BRA__2__KET____DOT__u_vlsit_afifo_cell_sync__DOT__gen_sync2__DOT__gen_rn__DOT__u_dont_touch_sync2ff__DOT__reg_chain) 
                                        >> 1U)))) << 2U) 
           | ((2U & (IData)(vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_r__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_rd__DOT__u_sync_wr_gray__DOT__gen_bit_cell__BRA__1__KET____DOT__u_vlsit_afifo_cell_sync__DOT__gen_sync2__DOT__gen_rn__DOT__u_dont_touch_sync2ff__DOT__reg_chain)) 
              | (1U & ((IData)(vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_r__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_rd__DOT__u_sync_wr_gray__DOT__gen_bit_cell__BRA__0__KET____DOT__u_vlsit_afifo_cell_sync__DOT__gen_sync2__DOT__gen_rn__DOT__u_dont_touch_sync2ff__DOT__reg_chain) 
                       >> 1U))));
    vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_w__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_rd__DOT__u_sync_wr_gray__DOT__o_data 
        = ((((4U & ((IData)(vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_w__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_rd__DOT__u_sync_wr_gray__DOT__gen_bit_cell__BRA__4__KET____DOT__u_vlsit_afifo_cell_sync__DOT__gen_sync2__DOT__gen_rn__DOT__u_dont_touch_sync2ff__DOT__reg_chain) 
                    << 1U)) | ((2U & (IData)(vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_w__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_rd__DOT__u_sync_wr_gray__DOT__gen_bit_cell__BRA__3__KET____DOT__u_vlsit_afifo_cell_sync__DOT__gen_sync2__DOT__gen_rn__DOT__u_dont_touch_sync2ff__DOT__reg_chain)) 
                               | (1U & ((IData)(vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_w__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_rd__DOT__u_sync_wr_gray__DOT__gen_bit_cell__BRA__2__KET____DOT__u_vlsit_afifo_cell_sync__DOT__gen_sync2__DOT__gen_rn__DOT__u_dont_touch_sync2ff__DOT__reg_chain) 
                                        >> 1U)))) << 2U) 
           | ((2U & (IData)(vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_w__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_rd__DOT__u_sync_wr_gray__DOT__gen_bit_cell__BRA__1__KET____DOT__u_vlsit_afifo_cell_sync__DOT__gen_sync2__DOT__gen_rn__DOT__u_dont_touch_sync2ff__DOT__reg_chain)) 
              | (1U & ((IData)(vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_w__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_rd__DOT__u_sync_wr_gray__DOT__gen_bit_cell__BRA__0__KET____DOT__u_vlsit_afifo_cell_sync__DOT__gen_sync2__DOT__gen_rn__DOT__u_dont_touch_sync2ff__DOT__reg_chain) 
                       >> 1U))));
    vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_r__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__u_sync_rd_gray__DOT__o_data 
        = ((((4U & ((IData)(vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_r__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__u_sync_rd_gray__DOT__gen_bit_cell__BRA__4__KET____DOT__u_vlsit_afifo_cell_sync__DOT__gen_sync2__DOT__gen_rn__DOT__u_dont_touch_sync2ff__DOT__reg_chain) 
                    << 1U)) | ((2U & (IData)(vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_r__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__u_sync_rd_gray__DOT__gen_bit_cell__BRA__3__KET____DOT__u_vlsit_afifo_cell_sync__DOT__gen_sync2__DOT__gen_rn__DOT__u_dont_touch_sync2ff__DOT__reg_chain)) 
                               | (1U & ((IData)(vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_r__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__u_sync_rd_gray__DOT__gen_bit_cell__BRA__2__KET____DOT__u_vlsit_afifo_cell_sync__DOT__gen_sync2__DOT__gen_rn__DOT__u_dont_touch_sync2ff__DOT__reg_chain) 
                                        >> 1U)))) << 2U) 
           | ((2U & (IData)(vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_r__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__u_sync_rd_gray__DOT__gen_bit_cell__BRA__1__KET____DOT__u_vlsit_afifo_cell_sync__DOT__gen_sync2__DOT__gen_rn__DOT__u_dont_touch_sync2ff__DOT__reg_chain)) 
              | (1U & ((IData)(vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_r__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__u_sync_rd_gray__DOT__gen_bit_cell__BRA__0__KET____DOT__u_vlsit_afifo_cell_sync__DOT__gen_sync2__DOT__gen_rn__DOT__u_dont_touch_sync2ff__DOT__reg_chain) 
                       >> 1U))));
    vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_w__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__u_sync_rd_gray__DOT__o_data 
        = ((((4U & ((IData)(vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_w__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__u_sync_rd_gray__DOT__gen_bit_cell__BRA__4__KET____DOT__u_vlsit_afifo_cell_sync__DOT__gen_sync2__DOT__gen_rn__DOT__u_dont_touch_sync2ff__DOT__reg_chain) 
                    << 1U)) | ((2U & (IData)(vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_w__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__u_sync_rd_gray__DOT__gen_bit_cell__BRA__3__KET____DOT__u_vlsit_afifo_cell_sync__DOT__gen_sync2__DOT__gen_rn__DOT__u_dont_touch_sync2ff__DOT__reg_chain)) 
                               | (1U & ((IData)(vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_w__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__u_sync_rd_gray__DOT__gen_bit_cell__BRA__2__KET____DOT__u_vlsit_afifo_cell_sync__DOT__gen_sync2__DOT__gen_rn__DOT__u_dont_touch_sync2ff__DOT__reg_chain) 
                                        >> 1U)))) << 2U) 
           | ((2U & (IData)(vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_w__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__u_sync_rd_gray__DOT__gen_bit_cell__BRA__1__KET____DOT__u_vlsit_afifo_cell_sync__DOT__gen_sync2__DOT__gen_rn__DOT__u_dont_touch_sync2ff__DOT__reg_chain)) 
              | (1U & ((IData)(vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_w__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__u_sync_rd_gray__DOT__gen_bit_cell__BRA__0__KET____DOT__u_vlsit_afifo_cell_sync__DOT__gen_sync2__DOT__gen_rn__DOT__u_dont_touch_sync2ff__DOT__reg_chain) 
                       >> 1U))));
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
    vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_b__DOT__o_axi_bvalid 
        = (1U & (~ (((IData)(vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_b__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_rd__DOT__reg_rgray) 
                     == (IData)(vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_b__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_rd__DOT__u_sync_wr_gray__DOT__o_data)) 
                    | ((0U != (IData)(vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_b__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_rd__DOT__reg_fsm_srst_current_state)) 
                       | ((IData)(vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_b__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_rd__DOT__u_sync_req__DOT__gen_bit_cell__BRA__0__KET____DOT__u_vlsit_afifo_cell_sync__DOT__gen_sync2__DOT__gen_rn__DOT__u_dont_touch_sync2ff__DOT__reg_chain) 
                          >> 1U)))));
    vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_ar__DOT__o_axi_arready 
        = (1U & (~ ((IData)(vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_ar__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__reg_sw_rst_busy) 
                    | ((IData)(vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_ar__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__reg_wgray) 
                       == (6U ^ (IData)(vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_ar__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__u_sync_rd_gray__DOT__o_data))))));
    vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_aw__DOT__o_axi_awready 
        = (1U & (~ ((IData)(vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_aw__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__reg_sw_rst_busy) 
                    | ((IData)(vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_aw__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__reg_wgray) 
                       == (6U ^ (IData)(vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_aw__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__u_sync_rd_gray__DOT__o_data))))));
    vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_b__DOT__o_axi_bready 
        = (1U & (~ ((IData)(vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_b__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__reg_sw_rst_busy) 
                    | ((IData)(vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_b__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__reg_wgray) 
                       == (6U ^ (IData)(vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_b__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__u_sync_rd_gray__DOT__o_data))))));
    vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_r__DOT__o_axi_rvalid 
        = (1U & (~ (((IData)(vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_r__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_rd__DOT__reg_rgray) 
                     == (IData)(vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_r__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_rd__DOT__u_sync_wr_gray__DOT__o_data)) 
                    | ((0U != (IData)(vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_r__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_rd__DOT__reg_fsm_srst_current_state)) 
                       | ((IData)(vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_r__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_rd__DOT__u_sync_req__DOT__gen_bit_cell__BRA__0__KET____DOT__u_vlsit_afifo_cell_sync__DOT__gen_sync2__DOT__gen_rn__DOT__u_dont_touch_sync2ff__DOT__reg_chain) 
                          >> 1U)))));
    vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_w__DOT__o_axi_wvalid 
        = (1U & (~ (((IData)(vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_w__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_rd__DOT__reg_rgray) 
                     == (IData)(vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_w__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_rd__DOT__u_sync_wr_gray__DOT__o_data)) 
                    | ((0U != (IData)(vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_w__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_rd__DOT__reg_fsm_srst_current_state)) 
                       | ((IData)(vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_w__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_rd__DOT__u_sync_req__DOT__gen_bit_cell__BRA__0__KET____DOT__u_vlsit_afifo_cell_sync__DOT__gen_sync2__DOT__gen_rn__DOT__u_dont_touch_sync2ff__DOT__reg_chain) 
                          >> 1U)))));
    vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_r__DOT__o_axi_rready 
        = (1U & (~ ((IData)(vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_r__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__reg_sw_rst_busy) 
                    | ((IData)(vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_r__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__reg_wgray) 
                       == (0x18U ^ (IData)(vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_r__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__u_sync_rd_gray__DOT__o_data))))));
    vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_w__DOT__o_axi_wready 
        = (1U & (~ ((IData)(vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_w__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__reg_sw_rst_busy) 
                    | ((IData)(vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_w__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__reg_wgray) 
                       == (0x18U ^ (IData)(vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_w__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__u_sync_rd_gray__DOT__o_data))))));
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
    vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_ar__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__o_mem_wr_en 
        = ((IData)(vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_ar__DOT__o_axi_arready) 
           & (IData)(vlSelfRef.tb_axi_bridge__DOT__i_axi_arvalid));
    vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_aw__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__o_mem_wr_en 
        = ((IData)(vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_aw__DOT__o_axi_awready) 
           & (IData)(vlSelfRef.tb_axi_bridge__DOT__i_axi_awvalid));
    vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_b__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__o_mem_wr_en 
        = ((IData)(vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_b__DOT__o_axi_bready) 
           & (IData)(vlSelfRef.tb_axi_bridge__DOT__i_axi_bvalid));
    vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_r__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_rd__DOT__w_rbin_nxt 
        = (0x0000001fU & ((- (IData)((1U != (IData)(vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_r__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_rd__DOT__reg_fsm_srst_current_state)))) 
                          & ((IData)(vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_r__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_rd__DOT__reg_rbin) 
                             + ((IData)(vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_r__DOT__o_axi_rvalid) 
                                & (IData)(vlSelfRef.tb_axi_bridge__DOT__i_axi_rready)))));
    vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_w__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_rd__DOT__w_rbin_nxt 
        = (0x0000001fU & ((- (IData)((1U != (IData)(vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_w__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_rd__DOT__reg_fsm_srst_current_state)))) 
                          & ((IData)(vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_w__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_rd__DOT__reg_rbin) 
                             + ((IData)(vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_w__DOT__o_axi_wvalid) 
                                & (IData)(vlSelfRef.tb_axi_bridge__DOT__i_axi_wready)))));
    vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_r__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__o_mem_wr_en 
        = ((IData)(vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_r__DOT__o_axi_rready) 
           & (IData)(vlSelfRef.tb_axi_bridge__DOT__i_axi_rvalid));
    vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_w__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__o_mem_wr_en 
        = ((IData)(vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_w__DOT__o_axi_wready) 
           & (IData)(vlSelfRef.tb_axi_bridge__DOT__i_axi_wvalid));
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
    vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_r__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__w_wbin_nxt 
        = (0x0000001fU & ((- (IData)((2U != (IData)(vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_r__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__reg_fsm_srst_current_state)))) 
                          & ((IData)(vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_r__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__reg_wbin) 
                             + (IData)(vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_r__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__o_mem_wr_en))));
    vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_w__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__w_wbin_nxt 
        = (0x0000001fU & ((- (IData)((2U != (IData)(vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_w__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__reg_fsm_srst_current_state)))) 
                          & ((IData)(vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_w__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__reg_wbin) 
                             + (IData)(vlSelfRef.tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_w__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__o_mem_wr_en))));
}

bool Vtb_axi_bridge___024root___trigger_anySet__ico(const VlUnpacked<QData/*63:0*/, 1> &in);

#ifdef VL_DEBUG
VL_ATTR_COLD void Vtb_axi_bridge___024root___dump_triggers__ico(const VlUnpacked<QData/*63:0*/, 1> &triggers, const std::string &tag) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_axi_bridge___024root___dump_triggers__ico\n"); );
    // Body
    if ((1U & (~ (IData)(Vtb_axi_bridge___024root___trigger_anySet__ico(triggers))))) {
        VL_DBG_MSGS("         No '" + tag + "' region triggers active\n");
    }
    if ((1U & (IData)(triggers[0U]))) {
        VL_DBG_MSGS("         '" + tag + "' region trigger index 0 is active: Internal 'ico' trigger - first iteration\n");
    }
}
#endif  // VL_DEBUG

bool Vtb_axi_bridge___024root___trigger_anySet__act(const VlUnpacked<QData/*63:0*/, 1> &in);

#ifdef VL_DEBUG
VL_ATTR_COLD void Vtb_axi_bridge___024root___dump_triggers__act(const VlUnpacked<QData/*63:0*/, 1> &triggers, const std::string &tag) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_axi_bridge___024root___dump_triggers__act\n"); );
    // Body
    if ((1U & (~ (IData)(Vtb_axi_bridge___024root___trigger_anySet__act(triggers))))) {
        VL_DBG_MSGS("         No '" + tag + "' region triggers active\n");
    }
    if ((1U & (IData)(triggers[0U]))) {
        VL_DBG_MSGS("         '" + tag + "' region trigger index 0 is active: @(posedge tb_axi_bridge.i_clk_sub)\n");
    }
    if ((1U & (IData)((triggers[0U] >> 1U)))) {
        VL_DBG_MSGS("         '" + tag + "' region trigger index 1 is active: @(posedge tb_axi_bridge.i_clk_mgr)\n");
    }
    if ((1U & (IData)((triggers[0U] >> 2U)))) {
        VL_DBG_MSGS("         '" + tag + "' region trigger index 2 is active: @(negedge tb_axi_bridge.i_rst_n_sub)\n");
    }
    if ((1U & (IData)((triggers[0U] >> 3U)))) {
        VL_DBG_MSGS("         '" + tag + "' region trigger index 3 is active: @(negedge tb_axi_bridge.i_rst_n_mgr)\n");
    }
    if ((1U & (IData)((triggers[0U] >> 4U)))) {
        VL_DBG_MSGS("         '" + tag + "' region trigger index 4 is active: @([true] __VdlySched.awaitingCurrentTime())\n");
    }
    if ((1U & (IData)((triggers[0U] >> 5U)))) {
        VL_DBG_MSGS("         '" + tag + "' region trigger index 5 is active: @(negedge tb_axi_bridge.i_clk_sub)\n");
    }
    if ((1U & (IData)((triggers[0U] >> 6U)))) {
        VL_DBG_MSGS("         '" + tag + "' region trigger index 6 is active: @(negedge tb_axi_bridge.i_clk_mgr)\n");
    }
    if ((1U & (IData)((triggers[0U] >> 7U)))) {
        VL_DBG_MSGS("         '" + tag + "' region trigger index 7 is active: @( (((32'sh6 == tb_axi_bridge.out_aw) & (32'sh12 == tb_axi_bridge.out_w)) & (32'sh6 == tb_axi_bridge.out_ar)))\n");
    }
    if ((1U & (IData)((triggers[0U] >> 8U)))) {
        VL_DBG_MSGS("         '" + tag + "' region trigger index 8 is active: @( ((32'sh6 == tb_axi_bridge.out_b) & (32'sh12 == tb_axi_bridge.out_r)))\n");
    }
}
#endif  // VL_DEBUG

VL_ATTR_COLD void Vtb_axi_bridge___024root___ctor_var_reset(Vtb_axi_bridge___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_axi_bridge___024root___ctor_var_reset\n"); );
    Vtb_axi_bridge__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Body
    const uint64_t __VscopeHash = VL_MURMUR64_HASH(vlSelf->vlNamep);
    vlSelf->tb_axi_bridge__DOT__i_rst_n_sub = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 3162383485999730798ull);
    vlSelf->tb_axi_bridge__DOT__i_rst_n_mgr = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 9018207066493520425ull);
    vlSelf->tb_axi_bridge__DOT__i_axi_awvalid = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 2909300216594978814ull);
    vlSelf->tb_axi_bridge__DOT__i_axi_awid = VL_SCOPED_RAND_RESET_I(4, __VscopeHash, 11798170359718582023ull);
    vlSelf->tb_axi_bridge__DOT__i_axi_awaddr = VL_SCOPED_RAND_RESET_I(32, __VscopeHash, 14785642932930458638ull);
    vlSelf->tb_axi_bridge__DOT__i_axi_awlen = VL_SCOPED_RAND_RESET_I(8, __VscopeHash, 7954902985356513521ull);
    vlSelf->tb_axi_bridge__DOT__i_axi_awsize = VL_SCOPED_RAND_RESET_I(3, __VscopeHash, 15087096783296377342ull);
    vlSelf->tb_axi_bridge__DOT__i_axi_awburst = VL_SCOPED_RAND_RESET_I(2, __VscopeHash, 14044432094638169493ull);
    vlSelf->tb_axi_bridge__DOT__i_axi_awlock = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 12923600960227412299ull);
    vlSelf->tb_axi_bridge__DOT__i_axi_awcache = VL_SCOPED_RAND_RESET_I(4, __VscopeHash, 11482347789577826119ull);
    vlSelf->tb_axi_bridge__DOT__i_axi_awprot = VL_SCOPED_RAND_RESET_I(3, __VscopeHash, 1170444527578030975ull);
    vlSelf->tb_axi_bridge__DOT__i_axi_awqos = VL_SCOPED_RAND_RESET_I(4, __VscopeHash, 13920385939651815855ull);
    vlSelf->tb_axi_bridge__DOT__i_axi_awregion = VL_SCOPED_RAND_RESET_I(4, __VscopeHash, 11484471186638878271ull);
    vlSelf->tb_axi_bridge__DOT__i_axi_awready = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 2423836118679059273ull);
    vlSelf->tb_axi_bridge__DOT__i_axi_wvalid = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 4245967137757970684ull);
    vlSelf->tb_axi_bridge__DOT__i_axi_wdata = VL_SCOPED_RAND_RESET_I(32, __VscopeHash, 5007381677387837671ull);
    vlSelf->tb_axi_bridge__DOT__i_axi_wstrb = VL_SCOPED_RAND_RESET_I(4, __VscopeHash, 12898763200552891342ull);
    vlSelf->tb_axi_bridge__DOT__i_axi_wlast = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 13818212587381078705ull);
    vlSelf->tb_axi_bridge__DOT__i_axi_wready = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 4725012619452318296ull);
    vlSelf->tb_axi_bridge__DOT__i_axi_bvalid = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 9014281206921729589ull);
    vlSelf->tb_axi_bridge__DOT__i_axi_bid = VL_SCOPED_RAND_RESET_I(4, __VscopeHash, 12535063073186656335ull);
    vlSelf->tb_axi_bridge__DOT__i_axi_bresp = VL_SCOPED_RAND_RESET_I(2, __VscopeHash, 1216928769544923521ull);
    vlSelf->tb_axi_bridge__DOT__i_axi_bready = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 15478535238200642989ull);
    vlSelf->tb_axi_bridge__DOT__i_axi_arvalid = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 3484812627484697047ull);
    vlSelf->tb_axi_bridge__DOT__i_axi_arid = VL_SCOPED_RAND_RESET_I(4, __VscopeHash, 7550202395174239725ull);
    vlSelf->tb_axi_bridge__DOT__i_axi_araddr = VL_SCOPED_RAND_RESET_I(32, __VscopeHash, 3439243628092136187ull);
    vlSelf->tb_axi_bridge__DOT__i_axi_arlen = VL_SCOPED_RAND_RESET_I(8, __VscopeHash, 4579776484512526813ull);
    vlSelf->tb_axi_bridge__DOT__i_axi_arsize = VL_SCOPED_RAND_RESET_I(3, __VscopeHash, 6108811618724346513ull);
    vlSelf->tb_axi_bridge__DOT__i_axi_arburst = VL_SCOPED_RAND_RESET_I(2, __VscopeHash, 4881670736136001271ull);
    vlSelf->tb_axi_bridge__DOT__i_axi_arlock = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 12746689343087105976ull);
    vlSelf->tb_axi_bridge__DOT__i_axi_arcache = VL_SCOPED_RAND_RESET_I(4, __VscopeHash, 42934584489095599ull);
    vlSelf->tb_axi_bridge__DOT__i_axi_arprot = VL_SCOPED_RAND_RESET_I(3, __VscopeHash, 11104523423542580630ull);
    vlSelf->tb_axi_bridge__DOT__i_axi_arqos = VL_SCOPED_RAND_RESET_I(4, __VscopeHash, 4026261620655135511ull);
    vlSelf->tb_axi_bridge__DOT__i_axi_arregion = VL_SCOPED_RAND_RESET_I(4, __VscopeHash, 12634353634517020741ull);
    vlSelf->tb_axi_bridge__DOT__i_axi_arready = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 16486513726959800059ull);
    vlSelf->tb_axi_bridge__DOT__i_axi_rvalid = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 12429468143977666533ull);
    vlSelf->tb_axi_bridge__DOT__i_axi_rid = VL_SCOPED_RAND_RESET_I(4, __VscopeHash, 5720768585423049836ull);
    vlSelf->tb_axi_bridge__DOT__i_axi_rdata = VL_SCOPED_RAND_RESET_I(32, __VscopeHash, 7592040309282287910ull);
    vlSelf->tb_axi_bridge__DOT__i_axi_rresp = VL_SCOPED_RAND_RESET_I(2, __VscopeHash, 5275577505602944359ull);
    vlSelf->tb_axi_bridge__DOT__i_axi_rlast = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 16227317737396590321ull);
    vlSelf->tb_axi_bridge__DOT__i_axi_rready = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 9448190876177629315ull);
    for (int __Vi0 = 0; __Vi0 < 256; ++__Vi0) {
        VL_SCOPED_RAND_RESET_W(512, vlSelf->tb_axi_bridge__DOT__exp_aw[__Vi0], __VscopeHash, 17672768020954483908ull);
    }
    for (int __Vi0 = 0; __Vi0 < 256; ++__Vi0) {
        VL_SCOPED_RAND_RESET_W(512, vlSelf->tb_axi_bridge__DOT__exp_w[__Vi0], __VscopeHash, 16296960752354140494ull);
    }
    for (int __Vi0 = 0; __Vi0 < 256; ++__Vi0) {
        VL_SCOPED_RAND_RESET_W(512, vlSelf->tb_axi_bridge__DOT__exp_b[__Vi0], __VscopeHash, 3212012250996573041ull);
    }
    for (int __Vi0 = 0; __Vi0 < 256; ++__Vi0) {
        VL_SCOPED_RAND_RESET_W(512, vlSelf->tb_axi_bridge__DOT__exp_ar[__Vi0], __VscopeHash, 17731341117071991535ull);
    }
    for (int __Vi0 = 0; __Vi0 < 256; ++__Vi0) {
        VL_SCOPED_RAND_RESET_W(512, vlSelf->tb_axi_bridge__DOT__exp_r[__Vi0], __VscopeHash, 4868083692865027003ull);
    }
    vlSelf->tb_axi_bridge__DOT__aw_head = VL_SCOPED_RAND_RESET_I(32, __VscopeHash, 8720655540964620021ull);
    vlSelf->tb_axi_bridge__DOT__aw_tail = VL_SCOPED_RAND_RESET_I(32, __VscopeHash, 11669577853021697702ull);
    vlSelf->tb_axi_bridge__DOT__w_head = VL_SCOPED_RAND_RESET_I(32, __VscopeHash, 5463044446620683124ull);
    vlSelf->tb_axi_bridge__DOT__w_tail = VL_SCOPED_RAND_RESET_I(32, __VscopeHash, 836221125901664907ull);
    vlSelf->tb_axi_bridge__DOT__b_head = VL_SCOPED_RAND_RESET_I(32, __VscopeHash, 8268098115934561964ull);
    vlSelf->tb_axi_bridge__DOT__b_tail = VL_SCOPED_RAND_RESET_I(32, __VscopeHash, 15828496638939051983ull);
    vlSelf->tb_axi_bridge__DOT__ar_head = VL_SCOPED_RAND_RESET_I(32, __VscopeHash, 17987658294847735232ull);
    vlSelf->tb_axi_bridge__DOT__ar_tail = VL_SCOPED_RAND_RESET_I(32, __VscopeHash, 2988793587802929756ull);
    vlSelf->tb_axi_bridge__DOT__r_head = VL_SCOPED_RAND_RESET_I(32, __VscopeHash, 18426799696762372877ull);
    vlSelf->tb_axi_bridge__DOT__r_tail = VL_SCOPED_RAND_RESET_I(32, __VscopeHash, 11823825983019985905ull);
    vlSelf->tb_axi_bridge__DOT__out_aw = VL_SCOPED_RAND_RESET_I(32, __VscopeHash, 3740327106201219111ull);
    vlSelf->tb_axi_bridge__DOT__out_w = VL_SCOPED_RAND_RESET_I(32, __VscopeHash, 10646412511338981128ull);
    vlSelf->tb_axi_bridge__DOT__out_b = VL_SCOPED_RAND_RESET_I(32, __VscopeHash, 12562425759985291194ull);
    vlSelf->tb_axi_bridge__DOT__out_ar = VL_SCOPED_RAND_RESET_I(32, __VscopeHash, 11945728233227434718ull);
    vlSelf->tb_axi_bridge__DOT__out_r = VL_SCOPED_RAND_RESET_I(32, __VscopeHash, 1672926001470087669ull);
    vlSelf->tb_axi_bridge__DOT__src_aw_stall = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 2881643494316299579ull);
    vlSelf->tb_axi_bridge__DOT__dst_aw_stall = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 11168961264793474829ull);
    vlSelf->tb_axi_bridge__DOT__src_w_stall = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 2131122548374101067ull);
    vlSelf->tb_axi_bridge__DOT__dst_w_stall = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 14392071709564307212ull);
    vlSelf->tb_axi_bridge__DOT__src_b_stall = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 736078786443094818ull);
    vlSelf->tb_axi_bridge__DOT__dst_b_stall = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 8380391636586304454ull);
    vlSelf->tb_axi_bridge__DOT__src_ar_stall = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 6979058859121929587ull);
    vlSelf->tb_axi_bridge__DOT__dst_ar_stall = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 8828947294124216534ull);
    vlSelf->tb_axi_bridge__DOT__src_r_stall = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 5633585141385170696ull);
    vlSelf->tb_axi_bridge__DOT__dst_r_stall = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 2883324294767240341ull);
    VL_SCOPED_RAND_RESET_W(512, vlSelf->tb_axi_bridge__DOT__prev_src_aw, __VscopeHash, 9725307253919915442ull);
    VL_SCOPED_RAND_RESET_W(512, vlSelf->tb_axi_bridge__DOT__prev_dst_aw, __VscopeHash, 8531860717693668270ull);
    VL_SCOPED_RAND_RESET_W(512, vlSelf->tb_axi_bridge__DOT__prev_src_w, __VscopeHash, 13835507546844906395ull);
    VL_SCOPED_RAND_RESET_W(512, vlSelf->tb_axi_bridge__DOT__prev_dst_w, __VscopeHash, 4592051923497361662ull);
    VL_SCOPED_RAND_RESET_W(512, vlSelf->tb_axi_bridge__DOT__prev_src_b, __VscopeHash, 10303825302881203620ull);
    VL_SCOPED_RAND_RESET_W(512, vlSelf->tb_axi_bridge__DOT__prev_dst_b, __VscopeHash, 18284756308178449790ull);
    VL_SCOPED_RAND_RESET_W(512, vlSelf->tb_axi_bridge__DOT__prev_src_ar, __VscopeHash, 12294074291122625799ull);
    VL_SCOPED_RAND_RESET_W(512, vlSelf->tb_axi_bridge__DOT__prev_dst_ar, __VscopeHash, 4550784464127322470ull);
    VL_SCOPED_RAND_RESET_W(512, vlSelf->tb_axi_bridge__DOT__prev_src_r, __VscopeHash, 2149180894804474481ull);
    VL_SCOPED_RAND_RESET_W(512, vlSelf->tb_axi_bridge__DOT__prev_dst_r, __VscopeHash, 12172703330970956966ull);
    for (int __Vi0 = 0; __Vi0 < 36; ++__Vi0) {
        vlSelf->tb_axi_bridge__DOT__assertion_hits[__Vi0] = VL_SCOPED_RAND_RESET_I(32, __VscopeHash, 9518956583410024377ull);
    }
    for (int __Vi0 = 0; __Vi0 < 36; ++__Vi0) {
        vlSelf->tb_axi_bridge__DOT__assertion_fails[__Vi0] = VL_SCOPED_RAND_RESET_I(32, __VscopeHash, 5731057118257787501ull);
    }
    vlSelf->tb_axi_bridge__DOT__seed_value = VL_SCOPED_RAND_RESET_I(32, __VscopeHash, 2130127788256764970ull);
    VL_SCOPED_RAND_RESET_W(4096, vlSelf->tb_axi_bridge__DOT__vcd_path, __VscopeHash, 841313152235888280ull);
    vlSelf->tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_r__DOT__o_axi_rready = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 11075755822939055102ull);
    vlSelf->tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_r__DOT__o_axi_rvalid = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 8666125542704854641ull);
    vlSelf->tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_r__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_rd__DOT__reg_fsm_srst_current_state = VL_SCOPED_RAND_RESET_I(2, __VscopeHash, 14640783369572594769ull);
    vlSelf->tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_r__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_rd__DOT__reg_ack_rd = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 14149199730538947893ull);
    vlSelf->tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_r__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_rd__DOT__reg_rbin = VL_SCOPED_RAND_RESET_I(5, __VscopeHash, 18389779930672465232ull);
    vlSelf->tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_r__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_rd__DOT__w_rbin_nxt = VL_SCOPED_RAND_RESET_I(5, __VscopeHash, 843959443658530235ull);
    vlSelf->tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_r__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_rd__DOT__reg_rgray = VL_SCOPED_RAND_RESET_I(5, __VscopeHash, 12424256165633987016ull);
    vlSelf->tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_r__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_rd__DOT__u_sync_wr_gray__DOT__o_data = VL_SCOPED_RAND_RESET_I(5, __VscopeHash, 764586119424004961ull);
    vlSelf->tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_r__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_rd__DOT__u_sync_wr_gray__DOT__gen_bit_cell__BRA__4__KET____DOT__u_vlsit_afifo_cell_sync__DOT__gen_sync2__DOT__gen_rn__DOT__u_dont_touch_sync2ff__DOT__reg_chain = VL_SCOPED_RAND_RESET_I(2, __VscopeHash, 17365666374337625390ull);
    vlSelf->tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_r__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_rd__DOT__u_sync_wr_gray__DOT__gen_bit_cell__BRA__3__KET____DOT__u_vlsit_afifo_cell_sync__DOT__gen_sync2__DOT__gen_rn__DOT__u_dont_touch_sync2ff__DOT__reg_chain = VL_SCOPED_RAND_RESET_I(2, __VscopeHash, 1583770852547825818ull);
    vlSelf->tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_r__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_rd__DOT__u_sync_wr_gray__DOT__gen_bit_cell__BRA__2__KET____DOT__u_vlsit_afifo_cell_sync__DOT__gen_sync2__DOT__gen_rn__DOT__u_dont_touch_sync2ff__DOT__reg_chain = VL_SCOPED_RAND_RESET_I(2, __VscopeHash, 12098758433353401922ull);
    vlSelf->tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_r__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_rd__DOT__u_sync_wr_gray__DOT__gen_bit_cell__BRA__1__KET____DOT__u_vlsit_afifo_cell_sync__DOT__gen_sync2__DOT__gen_rn__DOT__u_dont_touch_sync2ff__DOT__reg_chain = VL_SCOPED_RAND_RESET_I(2, __VscopeHash, 1268135775690164634ull);
    vlSelf->tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_r__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_rd__DOT__u_sync_wr_gray__DOT__gen_bit_cell__BRA__0__KET____DOT__u_vlsit_afifo_cell_sync__DOT__gen_sync2__DOT__gen_rn__DOT__u_dont_touch_sync2ff__DOT__reg_chain = VL_SCOPED_RAND_RESET_I(2, __VscopeHash, 17488437777135280151ull);
    vlSelf->tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_r__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_rd__DOT__u_sync_req__DOT__gen_bit_cell__BRA__0__KET____DOT__u_vlsit_afifo_cell_sync__DOT__gen_sync2__DOT__gen_rn__DOT__u_dont_touch_sync2ff__DOT__reg_chain = VL_SCOPED_RAND_RESET_I(2, __VscopeHash, 1527405806295754642ull);
    vlSelf->tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_r__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__o_mem_wr_en = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 9608253753670170088ull);
    vlSelf->tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_r__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__reg_fsm_srst_current_state = VL_SCOPED_RAND_RESET_I(3, __VscopeHash, 7277529760924508612ull);
    vlSelf->tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_r__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__reg_sw_rst_busy = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 12565738813666072364ull);
    vlSelf->tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_r__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__reg_req_wr = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 6648335983627947702ull);
    vlSelf->tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_r__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__reg_wbin = VL_SCOPED_RAND_RESET_I(5, __VscopeHash, 10652080719967242672ull);
    vlSelf->tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_r__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__w_wbin_nxt = VL_SCOPED_RAND_RESET_I(5, __VscopeHash, 9471968814219979033ull);
    vlSelf->tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_r__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__reg_wgray = VL_SCOPED_RAND_RESET_I(5, __VscopeHash, 11070727243685362723ull);
    vlSelf->tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_r__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__u_sync_rd_gray__DOT__o_data = VL_SCOPED_RAND_RESET_I(5, __VscopeHash, 1674148258596796228ull);
    vlSelf->tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_r__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__u_sync_rd_gray__DOT__gen_bit_cell__BRA__4__KET____DOT__u_vlsit_afifo_cell_sync__DOT__gen_sync2__DOT__gen_rn__DOT__u_dont_touch_sync2ff__DOT__reg_chain = VL_SCOPED_RAND_RESET_I(2, __VscopeHash, 5371370113207643902ull);
    vlSelf->tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_r__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__u_sync_rd_gray__DOT__gen_bit_cell__BRA__3__KET____DOT__u_vlsit_afifo_cell_sync__DOT__gen_sync2__DOT__gen_rn__DOT__u_dont_touch_sync2ff__DOT__reg_chain = VL_SCOPED_RAND_RESET_I(2, __VscopeHash, 12209460369006237331ull);
    vlSelf->tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_r__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__u_sync_rd_gray__DOT__gen_bit_cell__BRA__2__KET____DOT__u_vlsit_afifo_cell_sync__DOT__gen_sync2__DOT__gen_rn__DOT__u_dont_touch_sync2ff__DOT__reg_chain = VL_SCOPED_RAND_RESET_I(2, __VscopeHash, 7458861254548731531ull);
    vlSelf->tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_r__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__u_sync_rd_gray__DOT__gen_bit_cell__BRA__1__KET____DOT__u_vlsit_afifo_cell_sync__DOT__gen_sync2__DOT__gen_rn__DOT__u_dont_touch_sync2ff__DOT__reg_chain = VL_SCOPED_RAND_RESET_I(2, __VscopeHash, 5218300903448443281ull);
    vlSelf->tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_r__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__u_sync_rd_gray__DOT__gen_bit_cell__BRA__0__KET____DOT__u_vlsit_afifo_cell_sync__DOT__gen_sync2__DOT__gen_rn__DOT__u_dont_touch_sync2ff__DOT__reg_chain = VL_SCOPED_RAND_RESET_I(2, __VscopeHash, 15018795811775047875ull);
    vlSelf->tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_r__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__u_sync_ack__DOT__gen_bit_cell__BRA__0__KET____DOT__u_vlsit_afifo_cell_sync__DOT__gen_sync2__DOT__gen_rn__DOT__u_dont_touch_sync2ff__DOT__reg_chain = VL_SCOPED_RAND_RESET_I(2, __VscopeHash, 11898872742310065451ull);
    for (int __Vi0 = 0; __Vi0 < 16; ++__Vi0) {
        vlSelf->tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_r__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_mem__DOT__gen_array__DOT__reg_mem[__Vi0] = VL_SCOPED_RAND_RESET_Q(39, __VscopeHash, 13289060035560948613ull);
    }
    vlSelf->tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_r__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_mem__DOT__gen_array__DOT__reg_rd_data = VL_SCOPED_RAND_RESET_Q(39, __VscopeHash, 5413743616224223423ull);
    vlSelf->tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_w__DOT__o_axi_wready = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 3843563618425781044ull);
    vlSelf->tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_w__DOT__o_axi_wvalid = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 16847747438894526443ull);
    vlSelf->tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_w__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_rd__DOT__reg_fsm_srst_current_state = VL_SCOPED_RAND_RESET_I(2, __VscopeHash, 10472290035354765922ull);
    vlSelf->tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_w__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_rd__DOT__reg_ack_rd = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 12688870462299409966ull);
    vlSelf->tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_w__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_rd__DOT__reg_rbin = VL_SCOPED_RAND_RESET_I(5, __VscopeHash, 1453443485931021867ull);
    vlSelf->tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_w__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_rd__DOT__w_rbin_nxt = VL_SCOPED_RAND_RESET_I(5, __VscopeHash, 5327036690590607616ull);
    vlSelf->tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_w__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_rd__DOT__reg_rgray = VL_SCOPED_RAND_RESET_I(5, __VscopeHash, 4629595194465606104ull);
    vlSelf->tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_w__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_rd__DOT__u_sync_wr_gray__DOT__o_data = VL_SCOPED_RAND_RESET_I(5, __VscopeHash, 17221768104763863648ull);
    vlSelf->tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_w__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_rd__DOT__u_sync_wr_gray__DOT__gen_bit_cell__BRA__4__KET____DOT__u_vlsit_afifo_cell_sync__DOT__gen_sync2__DOT__gen_rn__DOT__u_dont_touch_sync2ff__DOT__reg_chain = VL_SCOPED_RAND_RESET_I(2, __VscopeHash, 15332208709277432524ull);
    vlSelf->tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_w__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_rd__DOT__u_sync_wr_gray__DOT__gen_bit_cell__BRA__3__KET____DOT__u_vlsit_afifo_cell_sync__DOT__gen_sync2__DOT__gen_rn__DOT__u_dont_touch_sync2ff__DOT__reg_chain = VL_SCOPED_RAND_RESET_I(2, __VscopeHash, 3269896371015418507ull);
    vlSelf->tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_w__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_rd__DOT__u_sync_wr_gray__DOT__gen_bit_cell__BRA__2__KET____DOT__u_vlsit_afifo_cell_sync__DOT__gen_sync2__DOT__gen_rn__DOT__u_dont_touch_sync2ff__DOT__reg_chain = VL_SCOPED_RAND_RESET_I(2, __VscopeHash, 16277464599165031693ull);
    vlSelf->tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_w__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_rd__DOT__u_sync_wr_gray__DOT__gen_bit_cell__BRA__1__KET____DOT__u_vlsit_afifo_cell_sync__DOT__gen_sync2__DOT__gen_rn__DOT__u_dont_touch_sync2ff__DOT__reg_chain = VL_SCOPED_RAND_RESET_I(2, __VscopeHash, 3225094156873716077ull);
    vlSelf->tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_w__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_rd__DOT__u_sync_wr_gray__DOT__gen_bit_cell__BRA__0__KET____DOT__u_vlsit_afifo_cell_sync__DOT__gen_sync2__DOT__gen_rn__DOT__u_dont_touch_sync2ff__DOT__reg_chain = VL_SCOPED_RAND_RESET_I(2, __VscopeHash, 13294292421461005546ull);
    vlSelf->tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_w__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_rd__DOT__u_sync_req__DOT__gen_bit_cell__BRA__0__KET____DOT__u_vlsit_afifo_cell_sync__DOT__gen_sync2__DOT__gen_rn__DOT__u_dont_touch_sync2ff__DOT__reg_chain = VL_SCOPED_RAND_RESET_I(2, __VscopeHash, 2242553425217115418ull);
    vlSelf->tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_w__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__o_mem_wr_en = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 10094700360403473366ull);
    vlSelf->tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_w__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__reg_fsm_srst_current_state = VL_SCOPED_RAND_RESET_I(3, __VscopeHash, 9524332377687625199ull);
    vlSelf->tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_w__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__reg_sw_rst_busy = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 3860806879678233376ull);
    vlSelf->tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_w__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__reg_req_wr = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 15974861864012809200ull);
    vlSelf->tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_w__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__reg_wbin = VL_SCOPED_RAND_RESET_I(5, __VscopeHash, 4951605467911344378ull);
    vlSelf->tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_w__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__w_wbin_nxt = VL_SCOPED_RAND_RESET_I(5, __VscopeHash, 16789505093918104456ull);
    vlSelf->tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_w__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__reg_wgray = VL_SCOPED_RAND_RESET_I(5, __VscopeHash, 7931287495414177300ull);
    vlSelf->tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_w__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__u_sync_rd_gray__DOT__o_data = VL_SCOPED_RAND_RESET_I(5, __VscopeHash, 6962626592732234553ull);
    vlSelf->tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_w__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__u_sync_rd_gray__DOT__gen_bit_cell__BRA__4__KET____DOT__u_vlsit_afifo_cell_sync__DOT__gen_sync2__DOT__gen_rn__DOT__u_dont_touch_sync2ff__DOT__reg_chain = VL_SCOPED_RAND_RESET_I(2, __VscopeHash, 18251373037900551017ull);
    vlSelf->tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_w__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__u_sync_rd_gray__DOT__gen_bit_cell__BRA__3__KET____DOT__u_vlsit_afifo_cell_sync__DOT__gen_sync2__DOT__gen_rn__DOT__u_dont_touch_sync2ff__DOT__reg_chain = VL_SCOPED_RAND_RESET_I(2, __VscopeHash, 5433179547176825364ull);
    vlSelf->tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_w__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__u_sync_rd_gray__DOT__gen_bit_cell__BRA__2__KET____DOT__u_vlsit_afifo_cell_sync__DOT__gen_sync2__DOT__gen_rn__DOT__u_dont_touch_sync2ff__DOT__reg_chain = VL_SCOPED_RAND_RESET_I(2, __VscopeHash, 7007646308167212720ull);
    vlSelf->tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_w__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__u_sync_rd_gray__DOT__gen_bit_cell__BRA__1__KET____DOT__u_vlsit_afifo_cell_sync__DOT__gen_sync2__DOT__gen_rn__DOT__u_dont_touch_sync2ff__DOT__reg_chain = VL_SCOPED_RAND_RESET_I(2, __VscopeHash, 11297255985909204081ull);
    vlSelf->tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_w__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__u_sync_rd_gray__DOT__gen_bit_cell__BRA__0__KET____DOT__u_vlsit_afifo_cell_sync__DOT__gen_sync2__DOT__gen_rn__DOT__u_dont_touch_sync2ff__DOT__reg_chain = VL_SCOPED_RAND_RESET_I(2, __VscopeHash, 8108679730871967038ull);
    vlSelf->tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_w__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__u_sync_ack__DOT__gen_bit_cell__BRA__0__KET____DOT__u_vlsit_afifo_cell_sync__DOT__gen_sync2__DOT__gen_rn__DOT__u_dont_touch_sync2ff__DOT__reg_chain = VL_SCOPED_RAND_RESET_I(2, __VscopeHash, 13092621298055793640ull);
    for (int __Vi0 = 0; __Vi0 < 16; ++__Vi0) {
        vlSelf->tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_w__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_mem__DOT__gen_array__DOT__reg_mem[__Vi0] = VL_SCOPED_RAND_RESET_Q(37, __VscopeHash, 529721855347125806ull);
    }
    vlSelf->tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_w__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_mem__DOT__gen_array__DOT__reg_rd_data = VL_SCOPED_RAND_RESET_Q(37, __VscopeHash, 10993133275970921012ull);
    vlSelf->tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_ar__DOT__o_axi_arready = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 8511814650671382557ull);
    vlSelf->tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_ar__DOT__o_axi_arvalid = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 4722200546272149791ull);
    vlSelf->tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_ar__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_rd__DOT__reg_fsm_srst_current_state = VL_SCOPED_RAND_RESET_I(2, __VscopeHash, 12624960314204629650ull);
    vlSelf->tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_ar__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_rd__DOT__reg_ack_rd = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 12722905462364424054ull);
    vlSelf->tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_ar__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_rd__DOT__reg_rbin = VL_SCOPED_RAND_RESET_I(3, __VscopeHash, 12690390841106369165ull);
    vlSelf->tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_ar__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_rd__DOT__w_rbin_nxt = VL_SCOPED_RAND_RESET_I(3, __VscopeHash, 11531198510124746412ull);
    vlSelf->tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_ar__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_rd__DOT__reg_rgray = VL_SCOPED_RAND_RESET_I(3, __VscopeHash, 3664872176737890123ull);
    vlSelf->tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_ar__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_rd__DOT__u_sync_wr_gray__DOT__o_data = VL_SCOPED_RAND_RESET_I(3, __VscopeHash, 10480231355851683470ull);
    vlSelf->tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_ar__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_rd__DOT__u_sync_wr_gray__DOT__gen_bit_cell__BRA__2__KET____DOT__u_vlsit_afifo_cell_sync__DOT__gen_sync2__DOT__gen_rn__DOT__u_dont_touch_sync2ff__DOT__reg_chain = VL_SCOPED_RAND_RESET_I(2, __VscopeHash, 348375830935225872ull);
    vlSelf->tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_ar__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_rd__DOT__u_sync_wr_gray__DOT__gen_bit_cell__BRA__1__KET____DOT__u_vlsit_afifo_cell_sync__DOT__gen_sync2__DOT__gen_rn__DOT__u_dont_touch_sync2ff__DOT__reg_chain = VL_SCOPED_RAND_RESET_I(2, __VscopeHash, 9718217387838616706ull);
    vlSelf->tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_ar__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_rd__DOT__u_sync_wr_gray__DOT__gen_bit_cell__BRA__0__KET____DOT__u_vlsit_afifo_cell_sync__DOT__gen_sync2__DOT__gen_rn__DOT__u_dont_touch_sync2ff__DOT__reg_chain = VL_SCOPED_RAND_RESET_I(2, __VscopeHash, 4480406579724613864ull);
    vlSelf->tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_ar__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_rd__DOT__u_sync_req__DOT__gen_bit_cell__BRA__0__KET____DOT__u_vlsit_afifo_cell_sync__DOT__gen_sync2__DOT__gen_rn__DOT__u_dont_touch_sync2ff__DOT__reg_chain = VL_SCOPED_RAND_RESET_I(2, __VscopeHash, 2822860273659620907ull);
    vlSelf->tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_ar__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__o_mem_wr_en = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 14286715754316939795ull);
    vlSelf->tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_ar__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__reg_fsm_srst_current_state = VL_SCOPED_RAND_RESET_I(3, __VscopeHash, 4293520349088974038ull);
    vlSelf->tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_ar__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__reg_sw_rst_busy = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 1585151721175613444ull);
    vlSelf->tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_ar__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__reg_req_wr = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 12705375935177631123ull);
    vlSelf->tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_ar__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__reg_wbin = VL_SCOPED_RAND_RESET_I(3, __VscopeHash, 2111252437886081909ull);
    vlSelf->tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_ar__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__w_wbin_nxt = VL_SCOPED_RAND_RESET_I(3, __VscopeHash, 7496092667592700697ull);
    vlSelf->tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_ar__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__reg_wgray = VL_SCOPED_RAND_RESET_I(3, __VscopeHash, 16912434868876254887ull);
    vlSelf->tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_ar__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__u_sync_rd_gray__DOT__o_data = VL_SCOPED_RAND_RESET_I(3, __VscopeHash, 11983738135692060494ull);
    vlSelf->tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_ar__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__u_sync_rd_gray__DOT__gen_bit_cell__BRA__2__KET____DOT__u_vlsit_afifo_cell_sync__DOT__gen_sync2__DOT__gen_rn__DOT__u_dont_touch_sync2ff__DOT__reg_chain = VL_SCOPED_RAND_RESET_I(2, __VscopeHash, 12273034974362883589ull);
    vlSelf->tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_ar__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__u_sync_rd_gray__DOT__gen_bit_cell__BRA__1__KET____DOT__u_vlsit_afifo_cell_sync__DOT__gen_sync2__DOT__gen_rn__DOT__u_dont_touch_sync2ff__DOT__reg_chain = VL_SCOPED_RAND_RESET_I(2, __VscopeHash, 12514744544776351178ull);
    vlSelf->tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_ar__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__u_sync_rd_gray__DOT__gen_bit_cell__BRA__0__KET____DOT__u_vlsit_afifo_cell_sync__DOT__gen_sync2__DOT__gen_rn__DOT__u_dont_touch_sync2ff__DOT__reg_chain = VL_SCOPED_RAND_RESET_I(2, __VscopeHash, 10905058623379056760ull);
    vlSelf->tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_ar__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__u_sync_ack__DOT__gen_bit_cell__BRA__0__KET____DOT__u_vlsit_afifo_cell_sync__DOT__gen_sync2__DOT__gen_rn__DOT__u_dont_touch_sync2ff__DOT__reg_chain = VL_SCOPED_RAND_RESET_I(2, __VscopeHash, 3031932529056160424ull);
    for (int __Vi0 = 0; __Vi0 < 4; ++__Vi0) {
        VL_SCOPED_RAND_RESET_W(65, vlSelf->tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_ar__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_mem__DOT__gen_array__DOT__reg_mem[__Vi0], __VscopeHash, 8198963046917830295ull);
    }
    VL_SCOPED_RAND_RESET_W(65, vlSelf->tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_ar__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_mem__DOT__gen_array__DOT__reg_rd_data, __VscopeHash, 11329437022088893645ull);
    vlSelf->tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_aw__DOT__o_axi_awready = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 11976703837228165784ull);
    vlSelf->tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_aw__DOT__o_axi_awvalid = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 9948619219962218465ull);
    vlSelf->tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_aw__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_rd__DOT__reg_fsm_srst_current_state = VL_SCOPED_RAND_RESET_I(2, __VscopeHash, 17931783363831666076ull);
    vlSelf->tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_aw__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_rd__DOT__reg_ack_rd = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 1612388491554201850ull);
    vlSelf->tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_aw__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_rd__DOT__reg_rbin = VL_SCOPED_RAND_RESET_I(3, __VscopeHash, 14602947557972193628ull);
    vlSelf->tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_aw__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_rd__DOT__w_rbin_nxt = VL_SCOPED_RAND_RESET_I(3, __VscopeHash, 14620950148639649977ull);
    vlSelf->tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_aw__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_rd__DOT__reg_rgray = VL_SCOPED_RAND_RESET_I(3, __VscopeHash, 15783660279641795809ull);
    vlSelf->tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_aw__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_rd__DOT__u_sync_wr_gray__DOT__o_data = VL_SCOPED_RAND_RESET_I(3, __VscopeHash, 18072330833679559670ull);
    vlSelf->tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_aw__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_rd__DOT__u_sync_wr_gray__DOT__gen_bit_cell__BRA__2__KET____DOT__u_vlsit_afifo_cell_sync__DOT__gen_sync2__DOT__gen_rn__DOT__u_dont_touch_sync2ff__DOT__reg_chain = VL_SCOPED_RAND_RESET_I(2, __VscopeHash, 3806691408050439290ull);
    vlSelf->tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_aw__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_rd__DOT__u_sync_wr_gray__DOT__gen_bit_cell__BRA__1__KET____DOT__u_vlsit_afifo_cell_sync__DOT__gen_sync2__DOT__gen_rn__DOT__u_dont_touch_sync2ff__DOT__reg_chain = VL_SCOPED_RAND_RESET_I(2, __VscopeHash, 15206756635091336705ull);
    vlSelf->tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_aw__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_rd__DOT__u_sync_wr_gray__DOT__gen_bit_cell__BRA__0__KET____DOT__u_vlsit_afifo_cell_sync__DOT__gen_sync2__DOT__gen_rn__DOT__u_dont_touch_sync2ff__DOT__reg_chain = VL_SCOPED_RAND_RESET_I(2, __VscopeHash, 11978238160838249403ull);
    vlSelf->tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_aw__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_rd__DOT__u_sync_req__DOT__gen_bit_cell__BRA__0__KET____DOT__u_vlsit_afifo_cell_sync__DOT__gen_sync2__DOT__gen_rn__DOT__u_dont_touch_sync2ff__DOT__reg_chain = VL_SCOPED_RAND_RESET_I(2, __VscopeHash, 15884898828823147527ull);
    vlSelf->tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_aw__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__o_mem_wr_en = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 9714779109090434028ull);
    vlSelf->tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_aw__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__reg_fsm_srst_current_state = VL_SCOPED_RAND_RESET_I(3, __VscopeHash, 14313261920860523205ull);
    vlSelf->tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_aw__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__reg_sw_rst_busy = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 16631246557333010787ull);
    vlSelf->tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_aw__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__reg_req_wr = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 17150610590331890501ull);
    vlSelf->tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_aw__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__reg_wbin = VL_SCOPED_RAND_RESET_I(3, __VscopeHash, 5781315450392145621ull);
    vlSelf->tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_aw__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__w_wbin_nxt = VL_SCOPED_RAND_RESET_I(3, __VscopeHash, 212118907991355925ull);
    vlSelf->tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_aw__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__reg_wgray = VL_SCOPED_RAND_RESET_I(3, __VscopeHash, 7224967700458646749ull);
    vlSelf->tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_aw__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__u_sync_rd_gray__DOT__o_data = VL_SCOPED_RAND_RESET_I(3, __VscopeHash, 17515880574955066230ull);
    vlSelf->tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_aw__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__u_sync_rd_gray__DOT__gen_bit_cell__BRA__2__KET____DOT__u_vlsit_afifo_cell_sync__DOT__gen_sync2__DOT__gen_rn__DOT__u_dont_touch_sync2ff__DOT__reg_chain = VL_SCOPED_RAND_RESET_I(2, __VscopeHash, 7769897515136777422ull);
    vlSelf->tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_aw__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__u_sync_rd_gray__DOT__gen_bit_cell__BRA__1__KET____DOT__u_vlsit_afifo_cell_sync__DOT__gen_sync2__DOT__gen_rn__DOT__u_dont_touch_sync2ff__DOT__reg_chain = VL_SCOPED_RAND_RESET_I(2, __VscopeHash, 14386146752405744688ull);
    vlSelf->tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_aw__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__u_sync_rd_gray__DOT__gen_bit_cell__BRA__0__KET____DOT__u_vlsit_afifo_cell_sync__DOT__gen_sync2__DOT__gen_rn__DOT__u_dont_touch_sync2ff__DOT__reg_chain = VL_SCOPED_RAND_RESET_I(2, __VscopeHash, 4246762441371798748ull);
    vlSelf->tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_aw__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__u_sync_ack__DOT__gen_bit_cell__BRA__0__KET____DOT__u_vlsit_afifo_cell_sync__DOT__gen_sync2__DOT__gen_rn__DOT__u_dont_touch_sync2ff__DOT__reg_chain = VL_SCOPED_RAND_RESET_I(2, __VscopeHash, 5624438094789022582ull);
    for (int __Vi0 = 0; __Vi0 < 4; ++__Vi0) {
        VL_SCOPED_RAND_RESET_W(65, vlSelf->tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_aw__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_mem__DOT__gen_array__DOT__reg_mem[__Vi0], __VscopeHash, 1278706241269452513ull);
    }
    VL_SCOPED_RAND_RESET_W(65, vlSelf->tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_aw__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_mem__DOT__gen_array__DOT__reg_rd_data, __VscopeHash, 2345190255320905395ull);
    vlSelf->tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_b__DOT__o_axi_bready = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 13140558687271910992ull);
    vlSelf->tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_b__DOT__o_axi_bvalid = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 7406470403174298269ull);
    vlSelf->tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_b__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_rd__DOT__reg_fsm_srst_current_state = VL_SCOPED_RAND_RESET_I(2, __VscopeHash, 12800423496762517449ull);
    vlSelf->tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_b__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_rd__DOT__reg_ack_rd = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 12247237079256447182ull);
    vlSelf->tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_b__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_rd__DOT__reg_rbin = VL_SCOPED_RAND_RESET_I(3, __VscopeHash, 13131211244485837179ull);
    vlSelf->tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_b__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_rd__DOT__w_rbin_nxt = VL_SCOPED_RAND_RESET_I(3, __VscopeHash, 16581641914130901750ull);
    vlSelf->tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_b__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_rd__DOT__reg_rgray = VL_SCOPED_RAND_RESET_I(3, __VscopeHash, 3871556658542161416ull);
    vlSelf->tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_b__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_rd__DOT__u_sync_wr_gray__DOT__o_data = VL_SCOPED_RAND_RESET_I(3, __VscopeHash, 2605313271973247007ull);
    vlSelf->tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_b__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_rd__DOT__u_sync_wr_gray__DOT__gen_bit_cell__BRA__2__KET____DOT__u_vlsit_afifo_cell_sync__DOT__gen_sync2__DOT__gen_rn__DOT__u_dont_touch_sync2ff__DOT__reg_chain = VL_SCOPED_RAND_RESET_I(2, __VscopeHash, 2007698983367283472ull);
    vlSelf->tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_b__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_rd__DOT__u_sync_wr_gray__DOT__gen_bit_cell__BRA__1__KET____DOT__u_vlsit_afifo_cell_sync__DOT__gen_sync2__DOT__gen_rn__DOT__u_dont_touch_sync2ff__DOT__reg_chain = VL_SCOPED_RAND_RESET_I(2, __VscopeHash, 9015944014330027203ull);
    vlSelf->tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_b__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_rd__DOT__u_sync_wr_gray__DOT__gen_bit_cell__BRA__0__KET____DOT__u_vlsit_afifo_cell_sync__DOT__gen_sync2__DOT__gen_rn__DOT__u_dont_touch_sync2ff__DOT__reg_chain = VL_SCOPED_RAND_RESET_I(2, __VscopeHash, 9804560400552485139ull);
    vlSelf->tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_b__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_rd__DOT__u_sync_req__DOT__gen_bit_cell__BRA__0__KET____DOT__u_vlsit_afifo_cell_sync__DOT__gen_sync2__DOT__gen_rn__DOT__u_dont_touch_sync2ff__DOT__reg_chain = VL_SCOPED_RAND_RESET_I(2, __VscopeHash, 17677724173416907970ull);
    vlSelf->tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_b__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__o_mem_wr_en = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 10463971541447064767ull);
    vlSelf->tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_b__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__reg_fsm_srst_current_state = VL_SCOPED_RAND_RESET_I(3, __VscopeHash, 10291077141569263213ull);
    vlSelf->tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_b__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__reg_sw_rst_busy = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 11696423334653954958ull);
    vlSelf->tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_b__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__reg_req_wr = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 13903118886912581332ull);
    vlSelf->tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_b__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__reg_wbin = VL_SCOPED_RAND_RESET_I(3, __VscopeHash, 11808352722354414731ull);
    vlSelf->tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_b__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__w_wbin_nxt = VL_SCOPED_RAND_RESET_I(3, __VscopeHash, 1633498852339290653ull);
    vlSelf->tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_b__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__reg_wgray = VL_SCOPED_RAND_RESET_I(3, __VscopeHash, 3522182230817828331ull);
    vlSelf->tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_b__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__u_sync_rd_gray__DOT__o_data = VL_SCOPED_RAND_RESET_I(3, __VscopeHash, 17402367289566037831ull);
    vlSelf->tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_b__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__u_sync_rd_gray__DOT__gen_bit_cell__BRA__2__KET____DOT__u_vlsit_afifo_cell_sync__DOT__gen_sync2__DOT__gen_rn__DOT__u_dont_touch_sync2ff__DOT__reg_chain = VL_SCOPED_RAND_RESET_I(2, __VscopeHash, 14457359408100596643ull);
    vlSelf->tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_b__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__u_sync_rd_gray__DOT__gen_bit_cell__BRA__1__KET____DOT__u_vlsit_afifo_cell_sync__DOT__gen_sync2__DOT__gen_rn__DOT__u_dont_touch_sync2ff__DOT__reg_chain = VL_SCOPED_RAND_RESET_I(2, __VscopeHash, 4105799567598527763ull);
    vlSelf->tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_b__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__u_sync_rd_gray__DOT__gen_bit_cell__BRA__0__KET____DOT__u_vlsit_afifo_cell_sync__DOT__gen_sync2__DOT__gen_rn__DOT__u_dont_touch_sync2ff__DOT__reg_chain = VL_SCOPED_RAND_RESET_I(2, __VscopeHash, 7940125891042108047ull);
    vlSelf->tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_b__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__u_sync_ack__DOT__gen_bit_cell__BRA__0__KET____DOT__u_vlsit_afifo_cell_sync__DOT__gen_sync2__DOT__gen_rn__DOT__u_dont_touch_sync2ff__DOT__reg_chain = VL_SCOPED_RAND_RESET_I(2, __VscopeHash, 10730987333864212155ull);
    for (int __Vi0 = 0; __Vi0 < 4; ++__Vi0) {
        vlSelf->tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_b__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_mem__DOT__gen_array__DOT__reg_mem[__Vi0] = VL_SCOPED_RAND_RESET_I(6, __VscopeHash, 4711173933791825324ull);
    }
    vlSelf->tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_b__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_mem__DOT__gen_array__DOT__reg_rd_data = VL_SCOPED_RAND_RESET_I(6, __VscopeHash, 17905254185381721433ull);
    vlSelf->__Vdly__tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_r__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__reg_fsm_srst_current_state_54 = 0;
    vlSelf->__Vdly__tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_r__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__u_sync_ack__DOT__gen_bit_cell__BRA__0__KET____DOT__u_vlsit_afifo_cell_sync__DOT__gen_sync2__DOT__gen_rn__DOT__u_dont_touch_sync2ff__DOT__reg_chain_62 = 0;
    vlSelf->__Vdly__tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_w__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_rd__DOT__reg_fsm_srst_current_state_65 = 0;
    vlSelf->__Vdly__tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_w__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_rd__DOT__u_sync_req__DOT__gen_bit_cell__BRA__0__KET____DOT__u_vlsit_afifo_cell_sync__DOT__gen_sync2__DOT__gen_rn__DOT__u_dont_touch_sync2ff__DOT__reg_chain_72 = 0;
    vlSelf->__Vdly__tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_ar__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_rd__DOT__reg_fsm_srst_current_state_75 = 0;
    vlSelf->__Vdly__tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_ar__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_rd__DOT__u_sync_req__DOT__gen_bit_cell__BRA__0__KET____DOT__u_vlsit_afifo_cell_sync__DOT__gen_sync2__DOT__gen_rn__DOT__u_dont_touch_sync2ff__DOT__reg_chain_80 = 0;
    vlSelf->__Vdly__tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_aw__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_rd__DOT__reg_fsm_srst_current_state_83 = 0;
    vlSelf->__Vdly__tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_aw__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_rd__DOT__u_sync_req__DOT__gen_bit_cell__BRA__0__KET____DOT__u_vlsit_afifo_cell_sync__DOT__gen_sync2__DOT__gen_rn__DOT__u_dont_touch_sync2ff__DOT__reg_chain_88 = 0;
    vlSelf->__Vdly__tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_b__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__reg_fsm_srst_current_state_91 = 0;
    vlSelf->__Vdly__tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_b__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__u_sync_ack__DOT__gen_bit_cell__BRA__0__KET____DOT__u_vlsit_afifo_cell_sync__DOT__gen_sync2__DOT__gen_rn__DOT__u_dont_touch_sync2ff__DOT__reg_chain_97 = 0;
    vlSelf->__Vdly_Val__tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_r__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_mem__DOT__gen_array__DOT__reg_mem_107 = 0;
    vlSelf->__Vdly_Dim0__tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_r__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_mem__DOT__gen_array__DOT__reg_mem_108 = 0;
    vlSelf->__Vdly_Set__tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_r__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_mem__DOT__gen_array__DOT__reg_mem_109 = 0;
    vlSelf->__Vdly_Val__tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_b__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_mem__DOT__gen_array__DOT__reg_mem_110 = 0;
    vlSelf->__Vdly_Dim0__tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_b__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_mem__DOT__gen_array__DOT__reg_mem_111 = 0;
    vlSelf->__Vdly_Set__tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_b__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_mem__DOT__gen_array__DOT__reg_mem_112 = 0;
    for (int __Vi0 = 0; __Vi0 < 1; ++__Vi0) {
        vlSelf->__VstlTriggered[__Vi0] = 0;
    }
    for (int __Vi0 = 0; __Vi0 < 1; ++__Vi0) {
        vlSelf->__VicoTriggered[__Vi0] = 0;
    }
    for (int __Vi0 = 0; __Vi0 < 1; ++__Vi0) {
        vlSelf->__VactTriggered[__Vi0] = 0;
    }
    for (int __Vi0 = 0; __Vi0 < 1; ++__Vi0) {
        vlSelf->__VactTriggeredAcc[__Vi0] = 0;
    }
    vlSelf->__Vtrigprevexpr___TOP__tb_axi_bridge__DOT__i_clk_sub__0 = 0;
    vlSelf->__Vtrigprevexpr___TOP__tb_axi_bridge__DOT__i_clk_mgr__0 = 0;
    vlSelf->__Vtrigprevexpr___TOP__tb_axi_bridge__DOT__i_rst_n_sub__0 = 0;
    vlSelf->__Vtrigprevexpr___TOP__tb_axi_bridge__DOT__i_rst_n_mgr__0 = 0;
    vlSelf->__Vtrigprevexpr_h325807e2__1 = 0;
    vlSelf->__Vtrigprevexpr_hb5e7ad64__1 = 0;
    for (int __Vi0 = 0; __Vi0 < 1; ++__Vi0) {
        vlSelf->__VnbaTriggered[__Vi0] = 0;
    }
    vlSelf->__Vi = 0;
}
