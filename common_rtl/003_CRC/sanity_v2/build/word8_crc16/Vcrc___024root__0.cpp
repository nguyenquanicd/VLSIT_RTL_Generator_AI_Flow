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
                                                     | (((((((IData)(vlSelfRef.i_check_data) 
                                                             != (IData)(vlSelfRef.__Vtrigprevexpr___TOP__i_check_data__0)) 
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
                                                            | (((IData)(vlSelfRef.i_gen_data) 
                                                                != (IData)(vlSelfRef.__Vtrigprevexpr___TOP__i_gen_data__0)) 
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
    SData/*15:0*/ __Vfunc_m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_2__DOT__u_crc_parallel__DOT__f_finalize__Vfuncout_17;
    __Vfunc_m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_2__DOT__u_crc_parallel__DOT__f_finalize__Vfuncout_17 = 0;
    SData/*15:0*/ __Vfunc_m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_2__DOT__u_crc_parallel__DOT__f_finalize__i_crc_18;
    __Vfunc_m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_2__DOT__u_crc_parallel__DOT__f_finalize__i_crc_18 = 0;
    SData/*15:0*/ __Vfunc_m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_2__DOT__u_crc_parallel__DOT__f_finalize__w_reflected_crc_20;
    __Vfunc_m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_2__DOT__u_crc_parallel__DOT__f_finalize__w_reflected_crc_20 = 0;
    SData/*15:0*/ __Vfunc_m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_2__DOT__u_crc_parallel__DOT__f_finalize__Vfuncout_38;
    __Vfunc_m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_2__DOT__u_crc_parallel__DOT__f_finalize__Vfuncout_38 = 0;
    SData/*15:0*/ __Vfunc_m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_2__DOT__u_crc_parallel__DOT__f_finalize__i_crc_39;
    __Vfunc_m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_2__DOT__u_crc_parallel__DOT__f_finalize__i_crc_39 = 0;
    SData/*15:0*/ __Vfunc_m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_2__DOT__u_crc_parallel__DOT__f_finalize__w_reflected_crc_41;
    __Vfunc_m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_2__DOT__u_crc_parallel__DOT__f_finalize__w_reflected_crc_41 = 0;
    SData/*15:0*/ __Vdfg_Regularize_342;
    __Vdfg_Regularize_342 = 0;
    SData/*15:0*/ __Vdfg_Regularize_343;
    __Vdfg_Regularize_343 = 0;
    SData/*15:0*/ __Vdfg_Regularize_344;
    __Vdfg_Regularize_344 = 0;
    SData/*15:0*/ __Vdfg_Regularize_345;
    __Vdfg_Regularize_345 = 0;
    SData/*15:0*/ __Vdfg_Regularize_346;
    __Vdfg_Regularize_346 = 0;
    SData/*15:0*/ __Vdfg_Regularize_347;
    __Vdfg_Regularize_347 = 0;
    SData/*15:0*/ __Vdfg_Regularize_348;
    __Vdfg_Regularize_348 = 0;
    SData/*15:0*/ __Vdfg_Regularize_349;
    __Vdfg_Regularize_349 = 0;
    SData/*15:0*/ __Vdfg_Regularize_350;
    __Vdfg_Regularize_350 = 0;
    SData/*15:0*/ __Vdfg_Regularize_351;
    __Vdfg_Regularize_351 = 0;
    SData/*15:0*/ __Vdfg_Regularize_352;
    __Vdfg_Regularize_352 = 0;
    SData/*15:0*/ __Vdfg_Regularize_353;
    __Vdfg_Regularize_353 = 0;
    SData/*15:0*/ __Vdfg_Regularize_354;
    __Vdfg_Regularize_354 = 0;
    SData/*15:0*/ __Vdfg_Regularize_355;
    __Vdfg_Regularize_355 = 0;
    SData/*15:0*/ __Vdfg_Regularize_356;
    __Vdfg_Regularize_356 = 0;
    SData/*15:0*/ __Vdfg_Regularize_357;
    __Vdfg_Regularize_357 = 0;
    SData/*15:0*/ __Vdfg_Regularize_358;
    __Vdfg_Regularize_358 = 0;
    SData/*15:0*/ __Vdfg_Regularize_359;
    __Vdfg_Regularize_359 = 0;
    SData/*15:0*/ __Vdfg_Regularize_360;
    __Vdfg_Regularize_360 = 0;
    SData/*15:0*/ __Vdfg_Regularize_361;
    __Vdfg_Regularize_361 = 0;
    SData/*15:0*/ __Vdfg_Regularize_362;
    __Vdfg_Regularize_362 = 0;
    SData/*15:0*/ __Vdfg_Regularize_363;
    __Vdfg_Regularize_363 = 0;
    SData/*15:0*/ __Vdfg_Regularize_364;
    __Vdfg_Regularize_364 = 0;
    SData/*15:0*/ __Vdfg_Regularize_365;
    __Vdfg_Regularize_365 = 0;
    SData/*15:0*/ __Vdfg_Regularize_366;
    __Vdfg_Regularize_366 = 0;
    SData/*15:0*/ __Vdfg_Regularize_367;
    __Vdfg_Regularize_367 = 0;
    SData/*15:0*/ __Vdfg_Regularize_368;
    __Vdfg_Regularize_368 = 0;
    SData/*15:0*/ __Vdfg_Regularize_369;
    __Vdfg_Regularize_369 = 0;
    SData/*15:0*/ __Vdfg_Regularize_370;
    __Vdfg_Regularize_370 = 0;
    SData/*15:0*/ __Vdfg_Regularize_371;
    __Vdfg_Regularize_371 = 0;
    SData/*15:0*/ __Vdfg_Regularize_372;
    __Vdfg_Regularize_372 = 0;
    SData/*15:0*/ __Vdfg_Regularize_373;
    __Vdfg_Regularize_373 = 0;
    SData/*15:0*/ __Vdfg_Regularize_390;
    __Vdfg_Regularize_390 = 0;
    SData/*15:0*/ __Vdfg_Regularize_391;
    __Vdfg_Regularize_391 = 0;
    SData/*15:0*/ __Vdfg_Regularize_392;
    __Vdfg_Regularize_392 = 0;
    SData/*15:0*/ __Vdfg_Regularize_393;
    __Vdfg_Regularize_393 = 0;
    SData/*15:0*/ __Vdfg_Regularize_394;
    __Vdfg_Regularize_394 = 0;
    SData/*15:0*/ __Vdfg_Regularize_395;
    __Vdfg_Regularize_395 = 0;
    SData/*15:0*/ __Vdfg_Regularize_396;
    __Vdfg_Regularize_396 = 0;
    SData/*15:0*/ __Vdfg_Regularize_397;
    __Vdfg_Regularize_397 = 0;
    SData/*15:0*/ __Vdfg_Regularize_398;
    __Vdfg_Regularize_398 = 0;
    SData/*15:0*/ __Vdfg_Regularize_399;
    __Vdfg_Regularize_399 = 0;
    SData/*15:0*/ __Vdfg_Regularize_400;
    __Vdfg_Regularize_400 = 0;
    SData/*15:0*/ __Vdfg_Regularize_401;
    __Vdfg_Regularize_401 = 0;
    SData/*15:0*/ __Vdfg_Regularize_402;
    __Vdfg_Regularize_402 = 0;
    SData/*15:0*/ __Vdfg_Regularize_403;
    __Vdfg_Regularize_403 = 0;
    SData/*15:0*/ __Vdfg_Regularize_404;
    __Vdfg_Regularize_404 = 0;
    SData/*15:0*/ __Vdfg_Regularize_405;
    __Vdfg_Regularize_405 = 0;
    SData/*15:0*/ __Vdfg_Regularize_406;
    __Vdfg_Regularize_406 = 0;
    SData/*15:0*/ __Vdfg_Regularize_407;
    __Vdfg_Regularize_407 = 0;
    SData/*15:0*/ __Vdfg_Regularize_408;
    __Vdfg_Regularize_408 = 0;
    SData/*15:0*/ __Vdfg_Regularize_409;
    __Vdfg_Regularize_409 = 0;
    SData/*15:0*/ __Vdfg_Regularize_410;
    __Vdfg_Regularize_410 = 0;
    SData/*15:0*/ __Vdfg_Regularize_411;
    __Vdfg_Regularize_411 = 0;
    SData/*15:0*/ __Vdfg_Regularize_412;
    __Vdfg_Regularize_412 = 0;
    SData/*15:0*/ __Vdfg_Regularize_413;
    __Vdfg_Regularize_413 = 0;
    SData/*15:0*/ __Vdfg_Regularize_414;
    __Vdfg_Regularize_414 = 0;
    SData/*15:0*/ __Vdfg_Regularize_415;
    __Vdfg_Regularize_415 = 0;
    SData/*15:0*/ __Vdfg_Regularize_416;
    __Vdfg_Regularize_416 = 0;
    SData/*15:0*/ __Vdfg_Regularize_417;
    __Vdfg_Regularize_417 = 0;
    SData/*15:0*/ __Vdfg_Regularize_418;
    __Vdfg_Regularize_418 = 0;
    SData/*15:0*/ __Vdfg_Regularize_419;
    __Vdfg_Regularize_419 = 0;
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
                    = (0x55aaU ^ (IData)(__Vfunc_m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_2__DOT__u_crc_parallel__DOT__f_finalize__w_reflected_crc_41));
                vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_2__DOT__u_crc_parallel__DOT__reg_crc_output 
                    = __Vfunc_m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_2__DOT__u_crc_parallel__DOT__f_finalize__Vfuncout_38;
                vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_2__DOT__u_crc_parallel__DOT__reg_crc_state = 0x1d0fU;
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
                    = (0x55aaU ^ (IData)(__Vfunc_m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_2__DOT__u_crc_parallel__DOT__f_finalize__w_reflected_crc_20));
                vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_2__DOT__u_crc_parallel__DOT__reg_crc_output 
                    = __Vfunc_m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_2__DOT__u_crc_parallel__DOT__f_finalize__Vfuncout_17;
                vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_2__DOT__u_crc_parallel__DOT__reg_crc_state = 0x1d0fU;
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
        vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_2__DOT__u_crc_parallel__DOT__reg_keep = 0U;
        vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_2__DOT__u_crc_parallel__DOT__reg_crc_output = 0U;
        vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_2__DOT__u_crc_parallel__DOT__reg_keep = 0U;
        vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_2__DOT__u_crc_parallel__DOT__reg_data = 0U;
        vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_2__DOT__u_crc_parallel__DOT__reg_data = 0U;
        vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_2__DOT__u_crc_parallel__DOT__reg_crc_state = 0x1d0fU;
        vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_2__DOT__u_crc_parallel__DOT__reg_crc_state = 0x1d0fU;
        vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_2__DOT__u_crc_parallel__DOT__reg_last = 0U;
        vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_2__DOT__u_crc_parallel__DOT__reg_last = 0U;
    }
    vlSelfRef.o_gen_crc_valid = vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_2__DOT__u_crc_parallel__DOT__reg_crc_valid;
    vlSelfRef.o_check_crc_valid = vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_2__DOT__u_crc_parallel__DOT__reg_crc_valid;
    vlSelfRef.o_gen_crc = vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_2__DOT__u_crc_parallel__DOT__reg_crc_output;
    vlSelfRef.o_check_pass = ((IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_2__DOT__u_crc_parallel__DOT__reg_crc_valid) 
                              & ((IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__reg_check_crc_ref) 
                                 == (IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_2__DOT__u_crc_parallel__DOT__reg_crc_output)));
    __Vdfg_Regularize_390 = ((0x0000fffeU & ((IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_2__DOT__u_crc_parallel__DOT__reg_crc_state) 
                                             << 1U)) 
                             | (1U & ((IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_2__DOT__u_crc_parallel__DOT__reg_data) 
                                      >> 7U)));
    __Vdfg_Regularize_344 = ((0x0000fffeU & ((IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_2__DOT__u_crc_parallel__DOT__reg_crc_state) 
                                             << 1U)) 
                             | (1U & ((IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_2__DOT__u_crc_parallel__DOT__reg_data) 
                                      >> 7U)));
    vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_2__DOT__u_crc_parallel__DOT__reg_busy 
        = __Vdly__m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_2__DOT__u_crc_parallel__DOT__reg_busy_11;
    __Vdfg_Regularize_391 = ((0x00008000U & (IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_2__DOT__u_crc_parallel__DOT__reg_crc_state))
                              ? (0x1021U ^ (IData)(__Vdfg_Regularize_390))
                              : (IData)(__Vdfg_Regularize_390));
    vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_2__DOT__u_crc_parallel__DOT__reg_busy 
        = __Vdly__m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_2__DOT__u_crc_parallel__DOT__reg_busy_4;
    __Vdfg_Regularize_345 = ((0x00008000U & (IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_2__DOT__u_crc_parallel__DOT__reg_crc_state))
                              ? (0x1021U ^ (IData)(__Vdfg_Regularize_344))
                              : (IData)(__Vdfg_Regularize_344));
    vlSelfRef.o_gen_data_ready = ((~ ((IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_2__DOT__u_crc_parallel__DOT__reg_busy) 
                                      | (IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_2__DOT__u_crc_parallel__DOT__reg_crc_valid))) 
                                  & (IData)(vlSelfRef.i_rst_n_crc));
    __Vdfg_Regularize_392 = ((0x0000fffeU & ((IData)(__Vdfg_Regularize_391) 
                                             << 1U)) 
                             | (1U & ((IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_2__DOT__u_crc_parallel__DOT__reg_data) 
                                      >> 6U)));
    vlSelfRef.o_check_data_ready = ((~ ((IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_2__DOT__u_crc_parallel__DOT__reg_busy) 
                                        | (IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_2__DOT__u_crc_parallel__DOT__reg_crc_valid))) 
                                    & (IData)(vlSelfRef.i_rst_n_crc));
    __Vdfg_Regularize_346 = ((0x0000fffeU & ((IData)(__Vdfg_Regularize_345) 
                                             << 1U)) 
                             | (1U & ((IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_2__DOT__u_crc_parallel__DOT__reg_data) 
                                      >> 6U)));
    __Vdfg_Regularize_393 = ((0x00008000U & (IData)(__Vdfg_Regularize_391))
                              ? (0x1021U ^ (IData)(__Vdfg_Regularize_392))
                              : (IData)(__Vdfg_Regularize_392));
    __Vdfg_Regularize_347 = ((0x00008000U & (IData)(__Vdfg_Regularize_345))
                              ? (0x1021U ^ (IData)(__Vdfg_Regularize_346))
                              : (IData)(__Vdfg_Regularize_346));
    __Vdfg_Regularize_394 = ((0x0000fffeU & ((IData)(__Vdfg_Regularize_393) 
                                             << 1U)) 
                             | (1U & ((IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_2__DOT__u_crc_parallel__DOT__reg_data) 
                                      >> 5U)));
    __Vdfg_Regularize_348 = ((0x0000fffeU & ((IData)(__Vdfg_Regularize_347) 
                                             << 1U)) 
                             | (1U & ((IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_2__DOT__u_crc_parallel__DOT__reg_data) 
                                      >> 5U)));
    __Vdfg_Regularize_395 = ((0x00008000U & (IData)(__Vdfg_Regularize_393))
                              ? (0x1021U ^ (IData)(__Vdfg_Regularize_394))
                              : (IData)(__Vdfg_Regularize_394));
    __Vdfg_Regularize_349 = ((0x00008000U & (IData)(__Vdfg_Regularize_347))
                              ? (0x1021U ^ (IData)(__Vdfg_Regularize_348))
                              : (IData)(__Vdfg_Regularize_348));
    __Vdfg_Regularize_396 = ((0x0000fffeU & ((IData)(__Vdfg_Regularize_395) 
                                             << 1U)) 
                             | (1U & ((IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_2__DOT__u_crc_parallel__DOT__reg_data) 
                                      >> 4U)));
    __Vdfg_Regularize_350 = ((0x0000fffeU & ((IData)(__Vdfg_Regularize_349) 
                                             << 1U)) 
                             | (1U & ((IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_2__DOT__u_crc_parallel__DOT__reg_data) 
                                      >> 4U)));
    __Vdfg_Regularize_397 = ((0x00008000U & (IData)(__Vdfg_Regularize_395))
                              ? (0x1021U ^ (IData)(__Vdfg_Regularize_396))
                              : (IData)(__Vdfg_Regularize_396));
    __Vdfg_Regularize_351 = ((0x00008000U & (IData)(__Vdfg_Regularize_349))
                              ? (0x1021U ^ (IData)(__Vdfg_Regularize_350))
                              : (IData)(__Vdfg_Regularize_350));
    __Vdfg_Regularize_398 = ((0x0000fffeU & ((IData)(__Vdfg_Regularize_397) 
                                             << 1U)) 
                             | (1U & ((IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_2__DOT__u_crc_parallel__DOT__reg_data) 
                                      >> 3U)));
    __Vdfg_Regularize_352 = ((0x0000fffeU & ((IData)(__Vdfg_Regularize_351) 
                                             << 1U)) 
                             | (1U & ((IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_2__DOT__u_crc_parallel__DOT__reg_data) 
                                      >> 3U)));
    __Vdfg_Regularize_399 = ((0x00008000U & (IData)(__Vdfg_Regularize_397))
                              ? (0x1021U ^ (IData)(__Vdfg_Regularize_398))
                              : (IData)(__Vdfg_Regularize_398));
    __Vdfg_Regularize_353 = ((0x00008000U & (IData)(__Vdfg_Regularize_351))
                              ? (0x1021U ^ (IData)(__Vdfg_Regularize_352))
                              : (IData)(__Vdfg_Regularize_352));
    __Vdfg_Regularize_400 = ((0x0000fffeU & ((IData)(__Vdfg_Regularize_399) 
                                             << 1U)) 
                             | (1U & ((IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_2__DOT__u_crc_parallel__DOT__reg_data) 
                                      >> 2U)));
    __Vdfg_Regularize_354 = ((0x0000fffeU & ((IData)(__Vdfg_Regularize_353) 
                                             << 1U)) 
                             | (1U & ((IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_2__DOT__u_crc_parallel__DOT__reg_data) 
                                      >> 2U)));
    __Vdfg_Regularize_401 = ((0x00008000U & (IData)(__Vdfg_Regularize_399))
                              ? (0x1021U ^ (IData)(__Vdfg_Regularize_400))
                              : (IData)(__Vdfg_Regularize_400));
    __Vdfg_Regularize_355 = ((0x00008000U & (IData)(__Vdfg_Regularize_353))
                              ? (0x1021U ^ (IData)(__Vdfg_Regularize_354))
                              : (IData)(__Vdfg_Regularize_354));
    __Vdfg_Regularize_402 = ((0x0000fffeU & ((IData)(__Vdfg_Regularize_401) 
                                             << 1U)) 
                             | (1U & ((IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_2__DOT__u_crc_parallel__DOT__reg_data) 
                                      >> 1U)));
    __Vdfg_Regularize_356 = ((0x0000fffeU & ((IData)(__Vdfg_Regularize_355) 
                                             << 1U)) 
                             | (1U & ((IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_2__DOT__u_crc_parallel__DOT__reg_data) 
                                      >> 1U)));
    __Vdfg_Regularize_403 = ((0x00008000U & (IData)(__Vdfg_Regularize_401))
                              ? (0x1021U ^ (IData)(__Vdfg_Regularize_402))
                              : (IData)(__Vdfg_Regularize_402));
    __Vdfg_Regularize_357 = ((0x00008000U & (IData)(__Vdfg_Regularize_355))
                              ? (0x1021U ^ (IData)(__Vdfg_Regularize_356))
                              : (IData)(__Vdfg_Regularize_356));
    __Vdfg_Regularize_404 = ((0x0000fffeU & ((IData)(__Vdfg_Regularize_403) 
                                             << 1U)) 
                             | (1U & (IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_2__DOT__u_crc_parallel__DOT__reg_data)));
    __Vdfg_Regularize_358 = ((0x0000fffeU & ((IData)(__Vdfg_Regularize_357) 
                                             << 1U)) 
                             | (1U & (IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_2__DOT__u_crc_parallel__DOT__reg_data)));
    __Vdfg_Regularize_343 = ((IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_2__DOT__u_crc_parallel__DOT__reg_keep)
                              ? ((0x00008000U & (IData)(__Vdfg_Regularize_403))
                                  ? (0x1021U ^ (IData)(__Vdfg_Regularize_404))
                                  : (IData)(__Vdfg_Regularize_404))
                              : (IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_2__DOT__u_crc_parallel__DOT__reg_crc_state));
    __Vdfg_Regularize_342 = ((IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_2__DOT__u_crc_parallel__DOT__reg_keep)
                              ? ((0x00008000U & (IData)(__Vdfg_Regularize_357))
                                  ? (0x1021U ^ (IData)(__Vdfg_Regularize_358))
                                  : (IData)(__Vdfg_Regularize_358))
                              : (IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_2__DOT__u_crc_parallel__DOT__reg_crc_state));
    __Vdfg_Regularize_405 = ((0x00008000U & (IData)(__Vdfg_Regularize_343))
                              ? (1U | (0x0000fffeU 
                                       & (0x00001020U 
                                          ^ (0x0000fffeU 
                                             & ((IData)(__Vdfg_Regularize_343) 
                                                << 1U)))))
                              : (0x0000fffeU & ((IData)(__Vdfg_Regularize_343) 
                                                << 1U)));
    __Vdfg_Regularize_359 = ((0x00008000U & (IData)(__Vdfg_Regularize_342))
                              ? (1U | (0x0000fffeU 
                                       & (0x00001020U 
                                          ^ (0x0000fffeU 
                                             & ((IData)(__Vdfg_Regularize_342) 
                                                << 1U)))))
                              : (0x0000fffeU & ((IData)(__Vdfg_Regularize_342) 
                                                << 1U)));
    __Vdfg_Regularize_406 = ((0x00008000U & (IData)(__Vdfg_Regularize_405))
                              ? (1U | (0x0000fffeU 
                                       & (0x00001020U 
                                          ^ (0x0000fffeU 
                                             & ((IData)(__Vdfg_Regularize_405) 
                                                << 1U)))))
                              : (0x0000fffeU & ((IData)(__Vdfg_Regularize_405) 
                                                << 1U)));
    __Vdfg_Regularize_360 = ((0x00008000U & (IData)(__Vdfg_Regularize_359))
                              ? (1U | (0x0000fffeU 
                                       & (0x00001020U 
                                          ^ (0x0000fffeU 
                                             & ((IData)(__Vdfg_Regularize_359) 
                                                << 1U)))))
                              : (0x0000fffeU & ((IData)(__Vdfg_Regularize_359) 
                                                << 1U)));
    __Vdfg_Regularize_407 = ((0x00008000U & (IData)(__Vdfg_Regularize_406))
                              ? (1U | (0x0000fffeU 
                                       & (0x00001020U 
                                          ^ (0x0000fffeU 
                                             & ((IData)(__Vdfg_Regularize_406) 
                                                << 1U)))))
                              : (0x0000fffeU & ((IData)(__Vdfg_Regularize_406) 
                                                << 1U)));
    __Vdfg_Regularize_361 = ((0x00008000U & (IData)(__Vdfg_Regularize_360))
                              ? (1U | (0x0000fffeU 
                                       & (0x00001020U 
                                          ^ (0x0000fffeU 
                                             & ((IData)(__Vdfg_Regularize_360) 
                                                << 1U)))))
                              : (0x0000fffeU & ((IData)(__Vdfg_Regularize_360) 
                                                << 1U)));
    __Vdfg_Regularize_408 = ((0x00008000U & (IData)(__Vdfg_Regularize_407))
                              ? (1U | (0x0000fffeU 
                                       & (0x00001020U 
                                          ^ (0x0000fffeU 
                                             & ((IData)(__Vdfg_Regularize_407) 
                                                << 1U)))))
                              : (0x0000fffeU & ((IData)(__Vdfg_Regularize_407) 
                                                << 1U)));
    __Vdfg_Regularize_362 = ((0x00008000U & (IData)(__Vdfg_Regularize_361))
                              ? (1U | (0x0000fffeU 
                                       & (0x00001020U 
                                          ^ (0x0000fffeU 
                                             & ((IData)(__Vdfg_Regularize_361) 
                                                << 1U)))))
                              : (0x0000fffeU & ((IData)(__Vdfg_Regularize_361) 
                                                << 1U)));
    __Vdfg_Regularize_409 = ((0x00008000U & (IData)(__Vdfg_Regularize_408))
                              ? (1U | (0x0000fffeU 
                                       & (0x00001020U 
                                          ^ (0x0000fffeU 
                                             & ((IData)(__Vdfg_Regularize_408) 
                                                << 1U)))))
                              : (0x0000fffeU & ((IData)(__Vdfg_Regularize_408) 
                                                << 1U)));
    __Vdfg_Regularize_363 = ((0x00008000U & (IData)(__Vdfg_Regularize_362))
                              ? (1U | (0x0000fffeU 
                                       & (0x00001020U 
                                          ^ (0x0000fffeU 
                                             & ((IData)(__Vdfg_Regularize_362) 
                                                << 1U)))))
                              : (0x0000fffeU & ((IData)(__Vdfg_Regularize_362) 
                                                << 1U)));
    __Vdfg_Regularize_410 = ((0x00008000U & (IData)(__Vdfg_Regularize_409))
                              ? (1U | (0x0000fffeU 
                                       & (0x00001020U 
                                          ^ (0x0000fffeU 
                                             & ((IData)(__Vdfg_Regularize_409) 
                                                << 1U)))))
                              : (0x0000fffeU & ((IData)(__Vdfg_Regularize_409) 
                                                << 1U)));
    __Vdfg_Regularize_364 = ((0x00008000U & (IData)(__Vdfg_Regularize_363))
                              ? (1U | (0x0000fffeU 
                                       & (0x00001020U 
                                          ^ (0x0000fffeU 
                                             & ((IData)(__Vdfg_Regularize_363) 
                                                << 1U)))))
                              : (0x0000fffeU & ((IData)(__Vdfg_Regularize_363) 
                                                << 1U)));
    __Vdfg_Regularize_411 = ((0x00008000U & (IData)(__Vdfg_Regularize_410))
                              ? (1U | (0x0000fffeU 
                                       & (0x00001020U 
                                          ^ (0x0000fffeU 
                                             & ((IData)(__Vdfg_Regularize_410) 
                                                << 1U)))))
                              : (0x0000fffeU & ((IData)(__Vdfg_Regularize_410) 
                                                << 1U)));
    __Vdfg_Regularize_365 = ((0x00008000U & (IData)(__Vdfg_Regularize_364))
                              ? (1U | (0x0000fffeU 
                                       & (0x00001020U 
                                          ^ (0x0000fffeU 
                                             & ((IData)(__Vdfg_Regularize_364) 
                                                << 1U)))))
                              : (0x0000fffeU & ((IData)(__Vdfg_Regularize_364) 
                                                << 1U)));
    __Vdfg_Regularize_412 = ((0x00008000U & (IData)(__Vdfg_Regularize_411))
                              ? (1U | (0x0000fffeU 
                                       & (0x00001020U 
                                          ^ (0x0000fffeU 
                                             & ((IData)(__Vdfg_Regularize_411) 
                                                << 1U)))))
                              : (0x0000fffeU & ((IData)(__Vdfg_Regularize_411) 
                                                << 1U)));
    __Vdfg_Regularize_366 = ((0x00008000U & (IData)(__Vdfg_Regularize_365))
                              ? (1U | (0x0000fffeU 
                                       & (0x00001020U 
                                          ^ (0x0000fffeU 
                                             & ((IData)(__Vdfg_Regularize_365) 
                                                << 1U)))))
                              : (0x0000fffeU & ((IData)(__Vdfg_Regularize_365) 
                                                << 1U)));
    __Vdfg_Regularize_413 = ((0x00008000U & (IData)(__Vdfg_Regularize_412))
                              ? (1U | (0x0000fffeU 
                                       & (0x00001020U 
                                          ^ (0x0000fffeU 
                                             & ((IData)(__Vdfg_Regularize_412) 
                                                << 1U)))))
                              : (0x0000fffeU & ((IData)(__Vdfg_Regularize_412) 
                                                << 1U)));
    __Vdfg_Regularize_367 = ((0x00008000U & (IData)(__Vdfg_Regularize_366))
                              ? (1U | (0x0000fffeU 
                                       & (0x00001020U 
                                          ^ (0x0000fffeU 
                                             & ((IData)(__Vdfg_Regularize_366) 
                                                << 1U)))))
                              : (0x0000fffeU & ((IData)(__Vdfg_Regularize_366) 
                                                << 1U)));
    __Vdfg_Regularize_414 = ((0x00008000U & (IData)(__Vdfg_Regularize_413))
                              ? (1U | (0x0000fffeU 
                                       & (0x00001020U 
                                          ^ (0x0000fffeU 
                                             & ((IData)(__Vdfg_Regularize_413) 
                                                << 1U)))))
                              : (0x0000fffeU & ((IData)(__Vdfg_Regularize_413) 
                                                << 1U)));
    __Vdfg_Regularize_368 = ((0x00008000U & (IData)(__Vdfg_Regularize_367))
                              ? (1U | (0x0000fffeU 
                                       & (0x00001020U 
                                          ^ (0x0000fffeU 
                                             & ((IData)(__Vdfg_Regularize_367) 
                                                << 1U)))))
                              : (0x0000fffeU & ((IData)(__Vdfg_Regularize_367) 
                                                << 1U)));
    __Vdfg_Regularize_415 = ((0x00008000U & (IData)(__Vdfg_Regularize_414))
                              ? (1U | (0x0000fffeU 
                                       & (0x00001020U 
                                          ^ (0x0000fffeU 
                                             & ((IData)(__Vdfg_Regularize_414) 
                                                << 1U)))))
                              : (0x0000fffeU & ((IData)(__Vdfg_Regularize_414) 
                                                << 1U)));
    __Vdfg_Regularize_369 = ((0x00008000U & (IData)(__Vdfg_Regularize_368))
                              ? (1U | (0x0000fffeU 
                                       & (0x00001020U 
                                          ^ (0x0000fffeU 
                                             & ((IData)(__Vdfg_Regularize_368) 
                                                << 1U)))))
                              : (0x0000fffeU & ((IData)(__Vdfg_Regularize_368) 
                                                << 1U)));
    __Vdfg_Regularize_416 = ((0x00008000U & (IData)(__Vdfg_Regularize_415))
                              ? (1U | (0x0000fffeU 
                                       & (0x00001020U 
                                          ^ (0x0000fffeU 
                                             & ((IData)(__Vdfg_Regularize_415) 
                                                << 1U)))))
                              : (0x0000fffeU & ((IData)(__Vdfg_Regularize_415) 
                                                << 1U)));
    __Vdfg_Regularize_370 = ((0x00008000U & (IData)(__Vdfg_Regularize_369))
                              ? (1U | (0x0000fffeU 
                                       & (0x00001020U 
                                          ^ (0x0000fffeU 
                                             & ((IData)(__Vdfg_Regularize_369) 
                                                << 1U)))))
                              : (0x0000fffeU & ((IData)(__Vdfg_Regularize_369) 
                                                << 1U)));
    __Vdfg_Regularize_417 = ((0x00008000U & (IData)(__Vdfg_Regularize_416))
                              ? (1U | (0x0000fffeU 
                                       & (0x00001020U 
                                          ^ (0x0000fffeU 
                                             & ((IData)(__Vdfg_Regularize_416) 
                                                << 1U)))))
                              : (0x0000fffeU & ((IData)(__Vdfg_Regularize_416) 
                                                << 1U)));
    __Vdfg_Regularize_371 = ((0x00008000U & (IData)(__Vdfg_Regularize_370))
                              ? (1U | (0x0000fffeU 
                                       & (0x00001020U 
                                          ^ (0x0000fffeU 
                                             & ((IData)(__Vdfg_Regularize_370) 
                                                << 1U)))))
                              : (0x0000fffeU & ((IData)(__Vdfg_Regularize_370) 
                                                << 1U)));
    __Vdfg_Regularize_418 = ((0x00008000U & (IData)(__Vdfg_Regularize_417))
                              ? (1U | (0x0000fffeU 
                                       & (0x00001020U 
                                          ^ (0x0000fffeU 
                                             & ((IData)(__Vdfg_Regularize_417) 
                                                << 1U)))))
                              : (0x0000fffeU & ((IData)(__Vdfg_Regularize_417) 
                                                << 1U)));
    __Vdfg_Regularize_372 = ((0x00008000U & (IData)(__Vdfg_Regularize_371))
                              ? (1U | (0x0000fffeU 
                                       & (0x00001020U 
                                          ^ (0x0000fffeU 
                                             & ((IData)(__Vdfg_Regularize_371) 
                                                << 1U)))))
                              : (0x0000fffeU & ((IData)(__Vdfg_Regularize_371) 
                                                << 1U)));
    __Vdfg_Regularize_419 = ((0x00008000U & (IData)(__Vdfg_Regularize_418))
                              ? (1U | (0x0000fffeU 
                                       & (0x00001020U 
                                          ^ (0x0000fffeU 
                                             & ((IData)(__Vdfg_Regularize_418) 
                                                << 1U)))))
                              : (0x0000fffeU & ((IData)(__Vdfg_Regularize_418) 
                                                << 1U)));
    __Vdfg_Regularize_373 = ((0x00008000U & (IData)(__Vdfg_Regularize_372))
                              ? (1U | (0x0000fffeU 
                                       & (0x00001020U 
                                          ^ (0x0000fffeU 
                                             & ((IData)(__Vdfg_Regularize_372) 
                                                << 1U)))))
                              : (0x0000fffeU & ((IData)(__Vdfg_Regularize_372) 
                                                << 1U)));
    vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_2__DOT__u_crc_parallel__DOT__w_crc_nxt 
        = ((IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_2__DOT__u_crc_parallel__DOT__reg_last)
            ? ((0x00008000U & (IData)(__Vdfg_Regularize_419))
                ? (1U | (0x0000fffeU & (0x00001020U 
                                        ^ (0x0000fffeU 
                                           & ((IData)(__Vdfg_Regularize_419) 
                                              << 1U)))))
                : (0x0000fffeU & ((IData)(__Vdfg_Regularize_419) 
                                  << 1U))) : (IData)(__Vdfg_Regularize_343));
    vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_2__DOT__u_crc_parallel__DOT__w_crc_nxt 
        = ((IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_2__DOT__u_crc_parallel__DOT__reg_last)
            ? ((0x00008000U & (IData)(__Vdfg_Regularize_373))
                ? (1U | (0x0000fffeU & (0x00001020U 
                                        ^ (0x0000fffeU 
                                           & ((IData)(__Vdfg_Regularize_373) 
                                              << 1U)))))
                : (0x0000fffeU & ((IData)(__Vdfg_Regularize_373) 
                                  << 1U))) : (IData)(__Vdfg_Regularize_342));
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
    if (VL_UNLIKELY(((vlSelfRef.i_gen_keep & 0xfeU)))) {
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
    if (VL_UNLIKELY(((vlSelfRef.i_check_keep & 0xfeU)))) {
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
