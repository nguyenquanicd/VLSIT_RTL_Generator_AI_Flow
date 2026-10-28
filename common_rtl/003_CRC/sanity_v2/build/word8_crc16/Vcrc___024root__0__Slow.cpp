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
    // Body
    vlSelfRef.o_gen_crc_valid = vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_2__DOT__u_crc_parallel__DOT__reg_crc_valid;
    vlSelfRef.o_check_crc_valid = vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_2__DOT__u_crc_parallel__DOT__reg_crc_valid;
    vlSelfRef.o_gen_crc = vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_2__DOT__u_crc_parallel__DOT__reg_crc_output;
    vlSelfRef.o_gen_data_ready = ((~ ((IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_2__DOT__u_crc_parallel__DOT__reg_busy) 
                                      | (IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_2__DOT__u_crc_parallel__DOT__reg_crc_valid))) 
                                  & (IData)(vlSelfRef.i_rst_n_crc));
    vlSelfRef.o_check_data_ready = ((~ ((IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_2__DOT__u_crc_parallel__DOT__reg_busy) 
                                        | (IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_2__DOT__u_crc_parallel__DOT__reg_crc_valid))) 
                                    & (IData)(vlSelfRef.i_rst_n_crc));
    vlSelfRef.o_check_pass = ((IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_2__DOT__u_crc_parallel__DOT__reg_crc_valid) 
                              & ((IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__reg_check_crc_ref) 
                                 == (IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_2__DOT__u_crc_parallel__DOT__reg_crc_output)));
    __Vdfg_Regularize_344 = ((0x0000fffeU & ((IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_2__DOT__u_crc_parallel__DOT__reg_crc_state) 
                                             << 1U)) 
                             | (1U & ((IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_2__DOT__u_crc_parallel__DOT__reg_data) 
                                      >> 7U)));
    __Vdfg_Regularize_390 = ((0x0000fffeU & ((IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_2__DOT__u_crc_parallel__DOT__reg_crc_state) 
                                             << 1U)) 
                             | (1U & ((IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_2__DOT__u_crc_parallel__DOT__reg_data) 
                                      >> 7U)));
    __Vdfg_Regularize_345 = ((0x00008000U & (IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_2__DOT__u_crc_parallel__DOT__reg_crc_state))
                              ? (0x1021U ^ (IData)(__Vdfg_Regularize_344))
                              : (IData)(__Vdfg_Regularize_344));
    __Vdfg_Regularize_391 = ((0x00008000U & (IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_2__DOT__u_crc_parallel__DOT__reg_crc_state))
                              ? (0x1021U ^ (IData)(__Vdfg_Regularize_390))
                              : (IData)(__Vdfg_Regularize_390));
    __Vdfg_Regularize_346 = ((0x0000fffeU & ((IData)(__Vdfg_Regularize_345) 
                                             << 1U)) 
                             | (1U & ((IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_2__DOT__u_crc_parallel__DOT__reg_data) 
                                      >> 6U)));
    __Vdfg_Regularize_392 = ((0x0000fffeU & ((IData)(__Vdfg_Regularize_391) 
                                             << 1U)) 
                             | (1U & ((IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_2__DOT__u_crc_parallel__DOT__reg_data) 
                                      >> 6U)));
    __Vdfg_Regularize_347 = ((0x00008000U & (IData)(__Vdfg_Regularize_345))
                              ? (0x1021U ^ (IData)(__Vdfg_Regularize_346))
                              : (IData)(__Vdfg_Regularize_346));
    __Vdfg_Regularize_393 = ((0x00008000U & (IData)(__Vdfg_Regularize_391))
                              ? (0x1021U ^ (IData)(__Vdfg_Regularize_392))
                              : (IData)(__Vdfg_Regularize_392));
    __Vdfg_Regularize_348 = ((0x0000fffeU & ((IData)(__Vdfg_Regularize_347) 
                                             << 1U)) 
                             | (1U & ((IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_2__DOT__u_crc_parallel__DOT__reg_data) 
                                      >> 5U)));
    __Vdfg_Regularize_394 = ((0x0000fffeU & ((IData)(__Vdfg_Regularize_393) 
                                             << 1U)) 
                             | (1U & ((IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_2__DOT__u_crc_parallel__DOT__reg_data) 
                                      >> 5U)));
    __Vdfg_Regularize_349 = ((0x00008000U & (IData)(__Vdfg_Regularize_347))
                              ? (0x1021U ^ (IData)(__Vdfg_Regularize_348))
                              : (IData)(__Vdfg_Regularize_348));
    __Vdfg_Regularize_395 = ((0x00008000U & (IData)(__Vdfg_Regularize_393))
                              ? (0x1021U ^ (IData)(__Vdfg_Regularize_394))
                              : (IData)(__Vdfg_Regularize_394));
    __Vdfg_Regularize_350 = ((0x0000fffeU & ((IData)(__Vdfg_Regularize_349) 
                                             << 1U)) 
                             | (1U & ((IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_2__DOT__u_crc_parallel__DOT__reg_data) 
                                      >> 4U)));
    __Vdfg_Regularize_396 = ((0x0000fffeU & ((IData)(__Vdfg_Regularize_395) 
                                             << 1U)) 
                             | (1U & ((IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_2__DOT__u_crc_parallel__DOT__reg_data) 
                                      >> 4U)));
    __Vdfg_Regularize_351 = ((0x00008000U & (IData)(__Vdfg_Regularize_349))
                              ? (0x1021U ^ (IData)(__Vdfg_Regularize_350))
                              : (IData)(__Vdfg_Regularize_350));
    __Vdfg_Regularize_397 = ((0x00008000U & (IData)(__Vdfg_Regularize_395))
                              ? (0x1021U ^ (IData)(__Vdfg_Regularize_396))
                              : (IData)(__Vdfg_Regularize_396));
    __Vdfg_Regularize_352 = ((0x0000fffeU & ((IData)(__Vdfg_Regularize_351) 
                                             << 1U)) 
                             | (1U & ((IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_2__DOT__u_crc_parallel__DOT__reg_data) 
                                      >> 3U)));
    __Vdfg_Regularize_398 = ((0x0000fffeU & ((IData)(__Vdfg_Regularize_397) 
                                             << 1U)) 
                             | (1U & ((IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_2__DOT__u_crc_parallel__DOT__reg_data) 
                                      >> 3U)));
    __Vdfg_Regularize_353 = ((0x00008000U & (IData)(__Vdfg_Regularize_351))
                              ? (0x1021U ^ (IData)(__Vdfg_Regularize_352))
                              : (IData)(__Vdfg_Regularize_352));
    __Vdfg_Regularize_399 = ((0x00008000U & (IData)(__Vdfg_Regularize_397))
                              ? (0x1021U ^ (IData)(__Vdfg_Regularize_398))
                              : (IData)(__Vdfg_Regularize_398));
    __Vdfg_Regularize_354 = ((0x0000fffeU & ((IData)(__Vdfg_Regularize_353) 
                                             << 1U)) 
                             | (1U & ((IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_2__DOT__u_crc_parallel__DOT__reg_data) 
                                      >> 2U)));
    __Vdfg_Regularize_400 = ((0x0000fffeU & ((IData)(__Vdfg_Regularize_399) 
                                             << 1U)) 
                             | (1U & ((IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_2__DOT__u_crc_parallel__DOT__reg_data) 
                                      >> 2U)));
    __Vdfg_Regularize_355 = ((0x00008000U & (IData)(__Vdfg_Regularize_353))
                              ? (0x1021U ^ (IData)(__Vdfg_Regularize_354))
                              : (IData)(__Vdfg_Regularize_354));
    __Vdfg_Regularize_401 = ((0x00008000U & (IData)(__Vdfg_Regularize_399))
                              ? (0x1021U ^ (IData)(__Vdfg_Regularize_400))
                              : (IData)(__Vdfg_Regularize_400));
    __Vdfg_Regularize_356 = ((0x0000fffeU & ((IData)(__Vdfg_Regularize_355) 
                                             << 1U)) 
                             | (1U & ((IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_2__DOT__u_crc_parallel__DOT__reg_data) 
                                      >> 1U)));
    __Vdfg_Regularize_402 = ((0x0000fffeU & ((IData)(__Vdfg_Regularize_401) 
                                             << 1U)) 
                             | (1U & ((IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_2__DOT__u_crc_parallel__DOT__reg_data) 
                                      >> 1U)));
    __Vdfg_Regularize_357 = ((0x00008000U & (IData)(__Vdfg_Regularize_355))
                              ? (0x1021U ^ (IData)(__Vdfg_Regularize_356))
                              : (IData)(__Vdfg_Regularize_356));
    __Vdfg_Regularize_403 = ((0x00008000U & (IData)(__Vdfg_Regularize_401))
                              ? (0x1021U ^ (IData)(__Vdfg_Regularize_402))
                              : (IData)(__Vdfg_Regularize_402));
    __Vdfg_Regularize_358 = ((0x0000fffeU & ((IData)(__Vdfg_Regularize_357) 
                                             << 1U)) 
                             | (1U & (IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_2__DOT__u_crc_parallel__DOT__reg_data)));
    __Vdfg_Regularize_404 = ((0x0000fffeU & ((IData)(__Vdfg_Regularize_403) 
                                             << 1U)) 
                             | (1U & (IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_2__DOT__u_crc_parallel__DOT__reg_data)));
    __Vdfg_Regularize_342 = ((IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_2__DOT__u_crc_parallel__DOT__reg_keep)
                              ? ((0x00008000U & (IData)(__Vdfg_Regularize_357))
                                  ? (0x1021U ^ (IData)(__Vdfg_Regularize_358))
                                  : (IData)(__Vdfg_Regularize_358))
                              : (IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_2__DOT__u_crc_parallel__DOT__reg_crc_state));
    __Vdfg_Regularize_343 = ((IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_2__DOT__u_crc_parallel__DOT__reg_keep)
                              ? ((0x00008000U & (IData)(__Vdfg_Regularize_403))
                                  ? (0x1021U ^ (IData)(__Vdfg_Regularize_404))
                                  : (IData)(__Vdfg_Regularize_404))
                              : (IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_2__DOT__u_crc_parallel__DOT__reg_crc_state));
    __Vdfg_Regularize_359 = ((0x00008000U & (IData)(__Vdfg_Regularize_342))
                              ? (1U | (0x0000fffeU 
                                       & (0x00001020U 
                                          ^ (0x0000fffeU 
                                             & ((IData)(__Vdfg_Regularize_342) 
                                                << 1U)))))
                              : (0x0000fffeU & ((IData)(__Vdfg_Regularize_342) 
                                                << 1U)));
    __Vdfg_Regularize_405 = ((0x00008000U & (IData)(__Vdfg_Regularize_343))
                              ? (1U | (0x0000fffeU 
                                       & (0x00001020U 
                                          ^ (0x0000fffeU 
                                             & ((IData)(__Vdfg_Regularize_343) 
                                                << 1U)))))
                              : (0x0000fffeU & ((IData)(__Vdfg_Regularize_343) 
                                                << 1U)));
    __Vdfg_Regularize_360 = ((0x00008000U & (IData)(__Vdfg_Regularize_359))
                              ? (1U | (0x0000fffeU 
                                       & (0x00001020U 
                                          ^ (0x0000fffeU 
                                             & ((IData)(__Vdfg_Regularize_359) 
                                                << 1U)))))
                              : (0x0000fffeU & ((IData)(__Vdfg_Regularize_359) 
                                                << 1U)));
    __Vdfg_Regularize_406 = ((0x00008000U & (IData)(__Vdfg_Regularize_405))
                              ? (1U | (0x0000fffeU 
                                       & (0x00001020U 
                                          ^ (0x0000fffeU 
                                             & ((IData)(__Vdfg_Regularize_405) 
                                                << 1U)))))
                              : (0x0000fffeU & ((IData)(__Vdfg_Regularize_405) 
                                                << 1U)));
    __Vdfg_Regularize_361 = ((0x00008000U & (IData)(__Vdfg_Regularize_360))
                              ? (1U | (0x0000fffeU 
                                       & (0x00001020U 
                                          ^ (0x0000fffeU 
                                             & ((IData)(__Vdfg_Regularize_360) 
                                                << 1U)))))
                              : (0x0000fffeU & ((IData)(__Vdfg_Regularize_360) 
                                                << 1U)));
    __Vdfg_Regularize_407 = ((0x00008000U & (IData)(__Vdfg_Regularize_406))
                              ? (1U | (0x0000fffeU 
                                       & (0x00001020U 
                                          ^ (0x0000fffeU 
                                             & ((IData)(__Vdfg_Regularize_406) 
                                                << 1U)))))
                              : (0x0000fffeU & ((IData)(__Vdfg_Regularize_406) 
                                                << 1U)));
    __Vdfg_Regularize_362 = ((0x00008000U & (IData)(__Vdfg_Regularize_361))
                              ? (1U | (0x0000fffeU 
                                       & (0x00001020U 
                                          ^ (0x0000fffeU 
                                             & ((IData)(__Vdfg_Regularize_361) 
                                                << 1U)))))
                              : (0x0000fffeU & ((IData)(__Vdfg_Regularize_361) 
                                                << 1U)));
    __Vdfg_Regularize_408 = ((0x00008000U & (IData)(__Vdfg_Regularize_407))
                              ? (1U | (0x0000fffeU 
                                       & (0x00001020U 
                                          ^ (0x0000fffeU 
                                             & ((IData)(__Vdfg_Regularize_407) 
                                                << 1U)))))
                              : (0x0000fffeU & ((IData)(__Vdfg_Regularize_407) 
                                                << 1U)));
    __Vdfg_Regularize_363 = ((0x00008000U & (IData)(__Vdfg_Regularize_362))
                              ? (1U | (0x0000fffeU 
                                       & (0x00001020U 
                                          ^ (0x0000fffeU 
                                             & ((IData)(__Vdfg_Regularize_362) 
                                                << 1U)))))
                              : (0x0000fffeU & ((IData)(__Vdfg_Regularize_362) 
                                                << 1U)));
    __Vdfg_Regularize_409 = ((0x00008000U & (IData)(__Vdfg_Regularize_408))
                              ? (1U | (0x0000fffeU 
                                       & (0x00001020U 
                                          ^ (0x0000fffeU 
                                             & ((IData)(__Vdfg_Regularize_408) 
                                                << 1U)))))
                              : (0x0000fffeU & ((IData)(__Vdfg_Regularize_408) 
                                                << 1U)));
    __Vdfg_Regularize_364 = ((0x00008000U & (IData)(__Vdfg_Regularize_363))
                              ? (1U | (0x0000fffeU 
                                       & (0x00001020U 
                                          ^ (0x0000fffeU 
                                             & ((IData)(__Vdfg_Regularize_363) 
                                                << 1U)))))
                              : (0x0000fffeU & ((IData)(__Vdfg_Regularize_363) 
                                                << 1U)));
    __Vdfg_Regularize_410 = ((0x00008000U & (IData)(__Vdfg_Regularize_409))
                              ? (1U | (0x0000fffeU 
                                       & (0x00001020U 
                                          ^ (0x0000fffeU 
                                             & ((IData)(__Vdfg_Regularize_409) 
                                                << 1U)))))
                              : (0x0000fffeU & ((IData)(__Vdfg_Regularize_409) 
                                                << 1U)));
    __Vdfg_Regularize_365 = ((0x00008000U & (IData)(__Vdfg_Regularize_364))
                              ? (1U | (0x0000fffeU 
                                       & (0x00001020U 
                                          ^ (0x0000fffeU 
                                             & ((IData)(__Vdfg_Regularize_364) 
                                                << 1U)))))
                              : (0x0000fffeU & ((IData)(__Vdfg_Regularize_364) 
                                                << 1U)));
    __Vdfg_Regularize_411 = ((0x00008000U & (IData)(__Vdfg_Regularize_410))
                              ? (1U | (0x0000fffeU 
                                       & (0x00001020U 
                                          ^ (0x0000fffeU 
                                             & ((IData)(__Vdfg_Regularize_410) 
                                                << 1U)))))
                              : (0x0000fffeU & ((IData)(__Vdfg_Regularize_410) 
                                                << 1U)));
    __Vdfg_Regularize_366 = ((0x00008000U & (IData)(__Vdfg_Regularize_365))
                              ? (1U | (0x0000fffeU 
                                       & (0x00001020U 
                                          ^ (0x0000fffeU 
                                             & ((IData)(__Vdfg_Regularize_365) 
                                                << 1U)))))
                              : (0x0000fffeU & ((IData)(__Vdfg_Regularize_365) 
                                                << 1U)));
    __Vdfg_Regularize_412 = ((0x00008000U & (IData)(__Vdfg_Regularize_411))
                              ? (1U | (0x0000fffeU 
                                       & (0x00001020U 
                                          ^ (0x0000fffeU 
                                             & ((IData)(__Vdfg_Regularize_411) 
                                                << 1U)))))
                              : (0x0000fffeU & ((IData)(__Vdfg_Regularize_411) 
                                                << 1U)));
    __Vdfg_Regularize_367 = ((0x00008000U & (IData)(__Vdfg_Regularize_366))
                              ? (1U | (0x0000fffeU 
                                       & (0x00001020U 
                                          ^ (0x0000fffeU 
                                             & ((IData)(__Vdfg_Regularize_366) 
                                                << 1U)))))
                              : (0x0000fffeU & ((IData)(__Vdfg_Regularize_366) 
                                                << 1U)));
    __Vdfg_Regularize_413 = ((0x00008000U & (IData)(__Vdfg_Regularize_412))
                              ? (1U | (0x0000fffeU 
                                       & (0x00001020U 
                                          ^ (0x0000fffeU 
                                             & ((IData)(__Vdfg_Regularize_412) 
                                                << 1U)))))
                              : (0x0000fffeU & ((IData)(__Vdfg_Regularize_412) 
                                                << 1U)));
    __Vdfg_Regularize_368 = ((0x00008000U & (IData)(__Vdfg_Regularize_367))
                              ? (1U | (0x0000fffeU 
                                       & (0x00001020U 
                                          ^ (0x0000fffeU 
                                             & ((IData)(__Vdfg_Regularize_367) 
                                                << 1U)))))
                              : (0x0000fffeU & ((IData)(__Vdfg_Regularize_367) 
                                                << 1U)));
    __Vdfg_Regularize_414 = ((0x00008000U & (IData)(__Vdfg_Regularize_413))
                              ? (1U | (0x0000fffeU 
                                       & (0x00001020U 
                                          ^ (0x0000fffeU 
                                             & ((IData)(__Vdfg_Regularize_413) 
                                                << 1U)))))
                              : (0x0000fffeU & ((IData)(__Vdfg_Regularize_413) 
                                                << 1U)));
    __Vdfg_Regularize_369 = ((0x00008000U & (IData)(__Vdfg_Regularize_368))
                              ? (1U | (0x0000fffeU 
                                       & (0x00001020U 
                                          ^ (0x0000fffeU 
                                             & ((IData)(__Vdfg_Regularize_368) 
                                                << 1U)))))
                              : (0x0000fffeU & ((IData)(__Vdfg_Regularize_368) 
                                                << 1U)));
    __Vdfg_Regularize_415 = ((0x00008000U & (IData)(__Vdfg_Regularize_414))
                              ? (1U | (0x0000fffeU 
                                       & (0x00001020U 
                                          ^ (0x0000fffeU 
                                             & ((IData)(__Vdfg_Regularize_414) 
                                                << 1U)))))
                              : (0x0000fffeU & ((IData)(__Vdfg_Regularize_414) 
                                                << 1U)));
    __Vdfg_Regularize_370 = ((0x00008000U & (IData)(__Vdfg_Regularize_369))
                              ? (1U | (0x0000fffeU 
                                       & (0x00001020U 
                                          ^ (0x0000fffeU 
                                             & ((IData)(__Vdfg_Regularize_369) 
                                                << 1U)))))
                              : (0x0000fffeU & ((IData)(__Vdfg_Regularize_369) 
                                                << 1U)));
    __Vdfg_Regularize_416 = ((0x00008000U & (IData)(__Vdfg_Regularize_415))
                              ? (1U | (0x0000fffeU 
                                       & (0x00001020U 
                                          ^ (0x0000fffeU 
                                             & ((IData)(__Vdfg_Regularize_415) 
                                                << 1U)))))
                              : (0x0000fffeU & ((IData)(__Vdfg_Regularize_415) 
                                                << 1U)));
    __Vdfg_Regularize_371 = ((0x00008000U & (IData)(__Vdfg_Regularize_370))
                              ? (1U | (0x0000fffeU 
                                       & (0x00001020U 
                                          ^ (0x0000fffeU 
                                             & ((IData)(__Vdfg_Regularize_370) 
                                                << 1U)))))
                              : (0x0000fffeU & ((IData)(__Vdfg_Regularize_370) 
                                                << 1U)));
    __Vdfg_Regularize_417 = ((0x00008000U & (IData)(__Vdfg_Regularize_416))
                              ? (1U | (0x0000fffeU 
                                       & (0x00001020U 
                                          ^ (0x0000fffeU 
                                             & ((IData)(__Vdfg_Regularize_416) 
                                                << 1U)))))
                              : (0x0000fffeU & ((IData)(__Vdfg_Regularize_416) 
                                                << 1U)));
    __Vdfg_Regularize_372 = ((0x00008000U & (IData)(__Vdfg_Regularize_371))
                              ? (1U | (0x0000fffeU 
                                       & (0x00001020U 
                                          ^ (0x0000fffeU 
                                             & ((IData)(__Vdfg_Regularize_371) 
                                                << 1U)))))
                              : (0x0000fffeU & ((IData)(__Vdfg_Regularize_371) 
                                                << 1U)));
    __Vdfg_Regularize_418 = ((0x00008000U & (IData)(__Vdfg_Regularize_417))
                              ? (1U | (0x0000fffeU 
                                       & (0x00001020U 
                                          ^ (0x0000fffeU 
                                             & ((IData)(__Vdfg_Regularize_417) 
                                                << 1U)))))
                              : (0x0000fffeU & ((IData)(__Vdfg_Regularize_417) 
                                                << 1U)));
    __Vdfg_Regularize_373 = ((0x00008000U & (IData)(__Vdfg_Regularize_372))
                              ? (1U | (0x0000fffeU 
                                       & (0x00001020U 
                                          ^ (0x0000fffeU 
                                             & ((IData)(__Vdfg_Regularize_372) 
                                                << 1U)))))
                              : (0x0000fffeU & ((IData)(__Vdfg_Regularize_372) 
                                                << 1U)));
    __Vdfg_Regularize_419 = ((0x00008000U & (IData)(__Vdfg_Regularize_418))
                              ? (1U | (0x0000fffeU 
                                       & (0x00001020U 
                                          ^ (0x0000fffeU 
                                             & ((IData)(__Vdfg_Regularize_418) 
                                                << 1U)))))
                              : (0x0000fffeU & ((IData)(__Vdfg_Regularize_418) 
                                                << 1U)));
    vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_2__DOT__u_crc_parallel__DOT__w_crc_nxt 
        = ((IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_2__DOT__u_crc_parallel__DOT__reg_last)
            ? ((0x00008000U & (IData)(__Vdfg_Regularize_373))
                ? (1U | (0x0000fffeU & (0x00001020U 
                                        ^ (0x0000fffeU 
                                           & ((IData)(__Vdfg_Regularize_373) 
                                              << 1U)))))
                : (0x0000fffeU & ((IData)(__Vdfg_Regularize_373) 
                                  << 1U))) : (IData)(__Vdfg_Regularize_342));
    vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_2__DOT__u_crc_parallel__DOT__w_crc_nxt 
        = ((IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_2__DOT__u_crc_parallel__DOT__reg_last)
            ? ((0x00008000U & (IData)(__Vdfg_Regularize_419))
                ? (1U | (0x0000fffeU & (0x00001020U 
                                        ^ (0x0000fffeU 
                                           & ((IData)(__Vdfg_Regularize_419) 
                                              << 1U)))))
                : (0x0000fffeU & ((IData)(__Vdfg_Regularize_419) 
                                  << 1U))) : (IData)(__Vdfg_Regularize_343));
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
    vlSelf->i_gen_data = VL_SCOPED_RAND_RESET_I(8, __VscopeHash, 16272362804487448987ull);
    vlSelf->i_gen_keep = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 4003954524733374398ull);
    vlSelf->i_gen_valid = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 14976442907654210106ull);
    vlSelf->i_gen_last = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 16324074986353538365ull);
    vlSelf->o_gen_data_ready = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 5196927497760937804ull);
    vlSelf->o_gen_crc = VL_SCOPED_RAND_RESET_I(16, __VscopeHash, 3043168594990581637ull);
    vlSelf->o_gen_crc_valid = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 6406002674580164605ull);
    vlSelf->i_gen_crc_ready = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 1434365149430831710ull);
    vlSelf->i_check_data = VL_SCOPED_RAND_RESET_I(8, __VscopeHash, 13571094061161519279ull);
    vlSelf->i_check_keep = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 1808124001774256246ull);
    vlSelf->i_check_valid = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 16839616335746463692ull);
    vlSelf->i_check_last = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 12123212944353719355ull);
    vlSelf->i_check_crc = VL_SCOPED_RAND_RESET_I(16, __VscopeHash, 2616207439244663111ull);
    vlSelf->o_check_data_ready = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 16371218162537437167ull);
    vlSelf->o_check_pass = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 12134859985623663099ull);
    vlSelf->o_check_crc_valid = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 2628765057176209784ull);
    vlSelf->i_check_crc_ready = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 14697704443546574182ull);
    vlSelf->m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__reg_check_crc_ref = VL_SCOPED_RAND_RESET_I(16, __VscopeHash, 5577206290272303270ull);
    vlSelf->m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_2__DOT__u_crc_parallel__DOT__reg_crc_state = VL_SCOPED_RAND_RESET_I(16, __VscopeHash, 4040255121775303244ull);
    vlSelf->m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_2__DOT__u_crc_parallel__DOT__reg_crc_output = VL_SCOPED_RAND_RESET_I(16, __VscopeHash, 4447476525257699230ull);
    vlSelf->m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_2__DOT__u_crc_parallel__DOT__reg_data = VL_SCOPED_RAND_RESET_I(8, __VscopeHash, 17454057237108172903ull);
    vlSelf->m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_2__DOT__u_crc_parallel__DOT__reg_keep = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 14065026389270295564ull);
    vlSelf->m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_2__DOT__u_crc_parallel__DOT__w_crc_nxt = VL_SCOPED_RAND_RESET_I(16, __VscopeHash, 16037767665699483548ull);
    vlSelf->m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_2__DOT__u_crc_parallel__DOT__reg_last = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 13704706664142532284ull);
    vlSelf->m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_2__DOT__u_crc_parallel__DOT__reg_busy = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 9724353901821502908ull);
    vlSelf->m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_2__DOT__u_crc_parallel__DOT__reg_crc_valid = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 13536787382750125929ull);
    vlSelf->m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_2__DOT__u_crc_parallel__DOT__reg_crc_state = VL_SCOPED_RAND_RESET_I(16, __VscopeHash, 11638067101212833261ull);
    vlSelf->m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_2__DOT__u_crc_parallel__DOT__reg_crc_output = VL_SCOPED_RAND_RESET_I(16, __VscopeHash, 11653675597761715927ull);
    vlSelf->m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_2__DOT__u_crc_parallel__DOT__reg_data = VL_SCOPED_RAND_RESET_I(8, __VscopeHash, 9480714767398998617ull);
    vlSelf->m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_2__DOT__u_crc_parallel__DOT__reg_keep = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 2916780408696628911ull);
    vlSelf->m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_2__DOT__u_crc_parallel__DOT__w_crc_nxt = VL_SCOPED_RAND_RESET_I(16, __VscopeHash, 7647855793882640030ull);
    vlSelf->m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_2__DOT__u_crc_parallel__DOT__reg_last = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 17972067317469304373ull);
    vlSelf->m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_2__DOT__u_crc_parallel__DOT__reg_busy = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 4636294232276800602ull);
    vlSelf->m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_2__DOT__u_crc_parallel__DOT__reg_crc_valid = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 16242615416053191717ull);
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
