// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Design internal header
// See Vcrc.h for the primary calling header

#ifndef VERILATED_VCRC___024ROOT_H_
#define VERILATED_VCRC___024ROOT_H_  // guard

#include "verilated.h"


class Vcrc__Syms;

class alignas(VL_CACHE_LINE_BYTES) Vcrc___024root final {
  public:

    // DESIGN-SPECIFIC STATE
    VL_IN8(i_clk_crc,0,0);
    VL_IN8(i_rst_n_crc,0,0);
    VL_IN(i_gen_data,31,0);
    VL_IN8(i_gen_keep,3,0);
    VL_IN8(i_gen_valid,0,0);
    VL_IN8(i_gen_last,0,0);
    VL_OUT8(o_gen_data_ready,0,0);
    VL_OUT8(o_gen_crc,7,0);
    VL_OUT8(o_gen_crc_valid,0,0);
    VL_IN8(i_gen_crc_ready,0,0);
    VL_IN(i_check_data,31,0);
    VL_IN8(i_check_keep,3,0);
    VL_IN8(i_check_valid,0,0);
    VL_IN8(i_check_last,0,0);
    VL_IN8(i_check_crc,7,0);
    VL_OUT8(o_check_data_ready,0,0);
    VL_OUT8(o_check_pass,0,0);
    VL_OUT8(o_check_crc_valid,0,0);
    VL_IN8(i_check_crc_ready,0,0);
    CData/*7:0*/ m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__reg_check_crc_ref;
    CData/*7:0*/ m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_4__DOT__u_crc_parallel_full__DOT__reg_crc_state;
    CData/*7:0*/ m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_4__DOT__u_crc_parallel_full__DOT__reg_crc_output;
    CData/*3:0*/ m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_4__DOT__u_crc_parallel_full__DOT__reg_keep;
    CData/*7:0*/ m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_4__DOT__u_crc_parallel_full__DOT__w_crc_nxt;
    CData/*0:0*/ m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_4__DOT__u_crc_parallel_full__DOT__reg_last;
    CData/*0:0*/ m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_4__DOT__u_crc_parallel_full__DOT__reg_busy;
    CData/*0:0*/ m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_4__DOT__u_crc_parallel_full__DOT__reg_crc_valid;
    CData/*7:0*/ m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_4__DOT__u_crc_parallel_full__DOT__reg_crc_state;
    CData/*7:0*/ m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_4__DOT__u_crc_parallel_full__DOT__reg_crc_output;
    CData/*3:0*/ m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_4__DOT__u_crc_parallel_full__DOT__reg_keep;
    CData/*7:0*/ m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_4__DOT__u_crc_parallel_full__DOT__w_crc_nxt;
    CData/*0:0*/ m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_4__DOT__u_crc_parallel_full__DOT__reg_last;
    CData/*0:0*/ m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_4__DOT__u_crc_parallel_full__DOT__reg_busy;
    CData/*0:0*/ m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_4__DOT__u_crc_parallel_full__DOT__reg_crc_valid;
    CData/*0:0*/ __Vtrigprevexpr___TOP__i_clk_crc__0;
    CData/*0:0*/ __Vtrigprevexpr___TOP__i_rst_n_crc__0;
    CData/*3:0*/ __Vtrigprevexpr___TOP__i_gen_keep__0;
    CData/*0:0*/ __Vtrigprevexpr___TOP__i_gen_valid__0;
    CData/*0:0*/ __Vtrigprevexpr___TOP__i_gen_last__0;
    CData/*0:0*/ __Vtrigprevexpr___TOP__i_gen_crc_ready__0;
    CData/*3:0*/ __Vtrigprevexpr___TOP__i_check_keep__0;
    CData/*0:0*/ __Vtrigprevexpr___TOP__i_check_valid__0;
    CData/*0:0*/ __Vtrigprevexpr___TOP__i_check_last__0;
    CData/*7:0*/ __Vtrigprevexpr___TOP__i_check_crc__0;
    CData/*0:0*/ __Vtrigprevexpr___TOP__i_check_crc_ready__0;
    CData/*0:0*/ __VicoDidInit;
    CData/*0:0*/ __Vtrigprevexpr___TOP__i_clk_crc__1;
    IData/*31:0*/ m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_4__DOT__u_crc_parallel_full__DOT__reg_data;
    IData/*31:0*/ m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_4__DOT__u_crc_parallel_full__DOT__reg_data;
    IData/*31:0*/ __Vtrigprevexpr___TOP__i_gen_data__0;
    IData/*31:0*/ __Vtrigprevexpr___TOP__i_check_data__0;
    VlUnpacked<QData/*63:0*/, 1> __VstlTriggered;
    VlUnpacked<QData/*63:0*/, 2> __VicoTriggered;
    VlUnpacked<QData/*63:0*/, 1> __VactTriggered;
    VlUnpacked<QData/*63:0*/, 1> __VnbaTriggered;
    VlUnpacked<CData/*0:0*/, 2> __VtraceActivity;

    // INTERNAL VARIABLES
    Vcrc__Syms* vlSymsp;
    const char* vlNamep;

    // CONSTRUCTORS
    Vcrc___024root(Vcrc__Syms* symsp, const char* namep);
    ~Vcrc___024root();
    VL_UNCOPYABLE(Vcrc___024root);

    // INTERNAL METHODS
};


#endif  // guard
