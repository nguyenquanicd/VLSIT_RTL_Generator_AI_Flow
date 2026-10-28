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
    // Body
    vlSelfRef.o_gen_crc_valid = vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_4__DOT__u_crc_parallel_full__DOT__reg_crc_valid;
    vlSelfRef.o_check_crc_valid = vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_4__DOT__u_crc_parallel_full__DOT__reg_crc_valid;
    vlSelfRef.o_gen_crc = vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_4__DOT__u_crc_parallel_full__DOT__reg_crc_output;
    vlSelfRef.o_gen_data_ready = ((~ ((IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_4__DOT__u_crc_parallel_full__DOT__reg_busy) 
                                      | (IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_4__DOT__u_crc_parallel_full__DOT__reg_crc_valid))) 
                                  & (IData)(vlSelfRef.i_rst_n_crc));
    vlSelfRef.o_check_data_ready = ((~ ((IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_4__DOT__u_crc_parallel_full__DOT__reg_busy) 
                                        | (IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_4__DOT__u_crc_parallel_full__DOT__reg_crc_valid))) 
                                    & (IData)(vlSelfRef.i_rst_n_crc));
    vlSelfRef.o_check_pass = ((IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_4__DOT__u_crc_parallel_full__DOT__reg_crc_valid) 
                              & (vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__reg_check_crc_ref 
                                 == vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_4__DOT__u_crc_parallel_full__DOT__reg_crc_output));
    __Vdfg_Regularize_872 = ((vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_4__DOT__u_crc_parallel_full__DOT__reg_crc_state 
                              << 1U) | (1U & (vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_4__DOT__u_crc_parallel_full__DOT__reg_data 
                                              >> 0x00000018U)));
    __Vdfg_Regularize_995 = ((vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_4__DOT__u_crc_parallel_full__DOT__reg_crc_state 
                              << 1U) | (1U & (vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_4__DOT__u_crc_parallel_full__DOT__reg_data 
                                              >> 0x00000018U)));
    __Vdfg_Regularize_873 = ((vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_4__DOT__u_crc_parallel_full__DOT__reg_crc_state 
                              >> 0x0000001fU) ? (0x04c11db7U 
                                                 ^ __Vdfg_Regularize_872)
                              : __Vdfg_Regularize_872);
    __Vdfg_Regularize_996 = ((vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_4__DOT__u_crc_parallel_full__DOT__reg_crc_state 
                              >> 0x0000001fU) ? (0x04c11db7U 
                                                 ^ __Vdfg_Regularize_995)
                              : __Vdfg_Regularize_995);
    __Vdfg_Regularize_874 = ((__Vdfg_Regularize_873 
                              << 1U) | (1U & (vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_4__DOT__u_crc_parallel_full__DOT__reg_data 
                                              >> 0x00000019U)));
    __Vdfg_Regularize_997 = ((__Vdfg_Regularize_996 
                              << 1U) | (1U & (vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_4__DOT__u_crc_parallel_full__DOT__reg_data 
                                              >> 0x00000019U)));
    __Vdfg_Regularize_875 = ((__Vdfg_Regularize_873 
                              >> 0x0000001fU) ? (0x04c11db7U 
                                                 ^ __Vdfg_Regularize_874)
                              : __Vdfg_Regularize_874);
    __Vdfg_Regularize_998 = ((__Vdfg_Regularize_996 
                              >> 0x0000001fU) ? (0x04c11db7U 
                                                 ^ __Vdfg_Regularize_997)
                              : __Vdfg_Regularize_997);
    __Vdfg_Regularize_876 = ((__Vdfg_Regularize_875 
                              << 1U) | (1U & (vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_4__DOT__u_crc_parallel_full__DOT__reg_data 
                                              >> 0x0000001aU)));
    __Vdfg_Regularize_999 = ((__Vdfg_Regularize_998 
                              << 1U) | (1U & (vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_4__DOT__u_crc_parallel_full__DOT__reg_data 
                                              >> 0x0000001aU)));
    __Vdfg_Regularize_877 = ((__Vdfg_Regularize_875 
                              >> 0x0000001fU) ? (0x04c11db7U 
                                                 ^ __Vdfg_Regularize_876)
                              : __Vdfg_Regularize_876);
    __Vdfg_Regularize_1000 = ((__Vdfg_Regularize_998 
                               >> 0x0000001fU) ? (0x04c11db7U 
                                                  ^ __Vdfg_Regularize_999)
                               : __Vdfg_Regularize_999);
    __Vdfg_Regularize_878 = ((__Vdfg_Regularize_877 
                              << 1U) | (1U & (vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_4__DOT__u_crc_parallel_full__DOT__reg_data 
                                              >> 0x0000001bU)));
    __Vdfg_Regularize_1001 = ((__Vdfg_Regularize_1000 
                               << 1U) | (1U & (vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_4__DOT__u_crc_parallel_full__DOT__reg_data 
                                               >> 0x0000001bU)));
    __Vdfg_Regularize_879 = ((__Vdfg_Regularize_877 
                              >> 0x0000001fU) ? (0x04c11db7U 
                                                 ^ __Vdfg_Regularize_878)
                              : __Vdfg_Regularize_878);
    __Vdfg_Regularize_1002 = ((__Vdfg_Regularize_1000 
                               >> 0x0000001fU) ? (0x04c11db7U 
                                                  ^ __Vdfg_Regularize_1001)
                               : __Vdfg_Regularize_1001);
    __Vdfg_Regularize_880 = ((__Vdfg_Regularize_879 
                              << 1U) | (1U & (vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_4__DOT__u_crc_parallel_full__DOT__reg_data 
                                              >> 0x0000001cU)));
    __Vdfg_Regularize_1003 = ((__Vdfg_Regularize_1002 
                               << 1U) | (1U & (vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_4__DOT__u_crc_parallel_full__DOT__reg_data 
                                               >> 0x0000001cU)));
    __Vdfg_Regularize_881 = ((__Vdfg_Regularize_879 
                              >> 0x0000001fU) ? (0x04c11db7U 
                                                 ^ __Vdfg_Regularize_880)
                              : __Vdfg_Regularize_880);
    __Vdfg_Regularize_1004 = ((__Vdfg_Regularize_1002 
                               >> 0x0000001fU) ? (0x04c11db7U 
                                                  ^ __Vdfg_Regularize_1003)
                               : __Vdfg_Regularize_1003);
    __Vdfg_Regularize_882 = ((__Vdfg_Regularize_881 
                              << 1U) | (1U & (vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_4__DOT__u_crc_parallel_full__DOT__reg_data 
                                              >> 0x0000001dU)));
    __Vdfg_Regularize_1005 = ((__Vdfg_Regularize_1004 
                               << 1U) | (1U & (vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_4__DOT__u_crc_parallel_full__DOT__reg_data 
                                               >> 0x0000001dU)));
    __Vdfg_Regularize_883 = ((__Vdfg_Regularize_881 
                              >> 0x0000001fU) ? (0x04c11db7U 
                                                 ^ __Vdfg_Regularize_882)
                              : __Vdfg_Regularize_882);
    __Vdfg_Regularize_1006 = ((__Vdfg_Regularize_1004 
                               >> 0x0000001fU) ? (0x04c11db7U 
                                                  ^ __Vdfg_Regularize_1005)
                               : __Vdfg_Regularize_1005);
    __Vdfg_Regularize_884 = ((__Vdfg_Regularize_883 
                              << 1U) | (1U & (vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_4__DOT__u_crc_parallel_full__DOT__reg_data 
                                              >> 0x0000001eU)));
    __Vdfg_Regularize_1007 = ((__Vdfg_Regularize_1006 
                               << 1U) | (1U & (vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_4__DOT__u_crc_parallel_full__DOT__reg_data 
                                               >> 0x0000001eU)));
    __Vdfg_Regularize_885 = ((__Vdfg_Regularize_883 
                              >> 0x0000001fU) ? (0x04c11db7U 
                                                 ^ __Vdfg_Regularize_884)
                              : __Vdfg_Regularize_884);
    __Vdfg_Regularize_1008 = ((__Vdfg_Regularize_1006 
                               >> 0x0000001fU) ? (0x04c11db7U 
                                                  ^ __Vdfg_Regularize_1007)
                               : __Vdfg_Regularize_1007);
    __Vdfg_Regularize_886 = ((__Vdfg_Regularize_885 
                              << 1U) | (vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_4__DOT__u_crc_parallel_full__DOT__reg_data 
                                        >> 0x0000001fU));
    __Vdfg_Regularize_1009 = ((__Vdfg_Regularize_1008 
                               << 1U) | (vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_4__DOT__u_crc_parallel_full__DOT__reg_data 
                                         >> 0x0000001fU));
    __Vdfg_Regularize_864 = ((8U & (IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_4__DOT__u_crc_parallel_full__DOT__reg_keep))
                              ? ((__Vdfg_Regularize_885 
                                  >> 0x0000001fU) ? 
                                 (0x04c11db7U ^ __Vdfg_Regularize_886)
                                  : __Vdfg_Regularize_886)
                              : vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_4__DOT__u_crc_parallel_full__DOT__reg_crc_state);
    __Vdfg_Regularize_868 = ((8U & (IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_4__DOT__u_crc_parallel_full__DOT__reg_keep))
                              ? ((__Vdfg_Regularize_1008 
                                  >> 0x0000001fU) ? 
                                 (0x04c11db7U ^ __Vdfg_Regularize_1009)
                                  : __Vdfg_Regularize_1009)
                              : vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_4__DOT__u_crc_parallel_full__DOT__reg_crc_state);
    __Vdfg_Regularize_887 = ((__Vdfg_Regularize_864 
                              << 1U) | (1U & (vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_4__DOT__u_crc_parallel_full__DOT__reg_data 
                                              >> 0x00000010U)));
    __Vdfg_Regularize_1010 = ((__Vdfg_Regularize_868 
                               << 1U) | (1U & (vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_4__DOT__u_crc_parallel_full__DOT__reg_data 
                                               >> 0x00000010U)));
    __Vdfg_Regularize_888 = ((__Vdfg_Regularize_864 
                              >> 0x0000001fU) ? (0x04c11db7U 
                                                 ^ __Vdfg_Regularize_887)
                              : __Vdfg_Regularize_887);
    __Vdfg_Regularize_1011 = ((__Vdfg_Regularize_868 
                               >> 0x0000001fU) ? (0x04c11db7U 
                                                  ^ __Vdfg_Regularize_1010)
                               : __Vdfg_Regularize_1010);
    __Vdfg_Regularize_889 = ((__Vdfg_Regularize_888 
                              << 1U) | (1U & (vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_4__DOT__u_crc_parallel_full__DOT__reg_data 
                                              >> 0x00000011U)));
    __Vdfg_Regularize_1012 = ((__Vdfg_Regularize_1011 
                               << 1U) | (1U & (vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_4__DOT__u_crc_parallel_full__DOT__reg_data 
                                               >> 0x00000011U)));
    __Vdfg_Regularize_890 = ((__Vdfg_Regularize_888 
                              >> 0x0000001fU) ? (0x04c11db7U 
                                                 ^ __Vdfg_Regularize_889)
                              : __Vdfg_Regularize_889);
    __Vdfg_Regularize_1013 = ((__Vdfg_Regularize_1011 
                               >> 0x0000001fU) ? (0x04c11db7U 
                                                  ^ __Vdfg_Regularize_1012)
                               : __Vdfg_Regularize_1012);
    __Vdfg_Regularize_891 = ((__Vdfg_Regularize_890 
                              << 1U) | (1U & (vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_4__DOT__u_crc_parallel_full__DOT__reg_data 
                                              >> 0x00000012U)));
    __Vdfg_Regularize_1014 = ((__Vdfg_Regularize_1013 
                               << 1U) | (1U & (vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_4__DOT__u_crc_parallel_full__DOT__reg_data 
                                               >> 0x00000012U)));
    __Vdfg_Regularize_892 = ((__Vdfg_Regularize_890 
                              >> 0x0000001fU) ? (0x04c11db7U 
                                                 ^ __Vdfg_Regularize_891)
                              : __Vdfg_Regularize_891);
    __Vdfg_Regularize_1015 = ((__Vdfg_Regularize_1013 
                               >> 0x0000001fU) ? (0x04c11db7U 
                                                  ^ __Vdfg_Regularize_1014)
                               : __Vdfg_Regularize_1014);
    __Vdfg_Regularize_893 = ((__Vdfg_Regularize_892 
                              << 1U) | (1U & (vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_4__DOT__u_crc_parallel_full__DOT__reg_data 
                                              >> 0x00000013U)));
    __Vdfg_Regularize_1016 = ((__Vdfg_Regularize_1015 
                               << 1U) | (1U & (vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_4__DOT__u_crc_parallel_full__DOT__reg_data 
                                               >> 0x00000013U)));
    __Vdfg_Regularize_894 = ((__Vdfg_Regularize_892 
                              >> 0x0000001fU) ? (0x04c11db7U 
                                                 ^ __Vdfg_Regularize_893)
                              : __Vdfg_Regularize_893);
    __Vdfg_Regularize_1017 = ((__Vdfg_Regularize_1015 
                               >> 0x0000001fU) ? (0x04c11db7U 
                                                  ^ __Vdfg_Regularize_1016)
                               : __Vdfg_Regularize_1016);
    __Vdfg_Regularize_895 = ((__Vdfg_Regularize_894 
                              << 1U) | (1U & (vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_4__DOT__u_crc_parallel_full__DOT__reg_data 
                                              >> 0x00000014U)));
    __Vdfg_Regularize_1018 = ((__Vdfg_Regularize_1017 
                               << 1U) | (1U & (vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_4__DOT__u_crc_parallel_full__DOT__reg_data 
                                               >> 0x00000014U)));
    __Vdfg_Regularize_896 = ((__Vdfg_Regularize_894 
                              >> 0x0000001fU) ? (0x04c11db7U 
                                                 ^ __Vdfg_Regularize_895)
                              : __Vdfg_Regularize_895);
    __Vdfg_Regularize_1019 = ((__Vdfg_Regularize_1017 
                               >> 0x0000001fU) ? (0x04c11db7U 
                                                  ^ __Vdfg_Regularize_1018)
                               : __Vdfg_Regularize_1018);
    __Vdfg_Regularize_897 = ((__Vdfg_Regularize_896 
                              << 1U) | (1U & (vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_4__DOT__u_crc_parallel_full__DOT__reg_data 
                                              >> 0x00000015U)));
    __Vdfg_Regularize_1020 = ((__Vdfg_Regularize_1019 
                               << 1U) | (1U & (vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_4__DOT__u_crc_parallel_full__DOT__reg_data 
                                               >> 0x00000015U)));
    __Vdfg_Regularize_898 = ((__Vdfg_Regularize_896 
                              >> 0x0000001fU) ? (0x04c11db7U 
                                                 ^ __Vdfg_Regularize_897)
                              : __Vdfg_Regularize_897);
    __Vdfg_Regularize_1021 = ((__Vdfg_Regularize_1019 
                               >> 0x0000001fU) ? (0x04c11db7U 
                                                  ^ __Vdfg_Regularize_1020)
                               : __Vdfg_Regularize_1020);
    __Vdfg_Regularize_899 = ((__Vdfg_Regularize_898 
                              << 1U) | (1U & (vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_4__DOT__u_crc_parallel_full__DOT__reg_data 
                                              >> 0x00000016U)));
    __Vdfg_Regularize_1022 = ((__Vdfg_Regularize_1021 
                               << 1U) | (1U & (vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_4__DOT__u_crc_parallel_full__DOT__reg_data 
                                               >> 0x00000016U)));
    __Vdfg_Regularize_900 = ((__Vdfg_Regularize_898 
                              >> 0x0000001fU) ? (0x04c11db7U 
                                                 ^ __Vdfg_Regularize_899)
                              : __Vdfg_Regularize_899);
    __Vdfg_Regularize_1023 = ((__Vdfg_Regularize_1021 
                               >> 0x0000001fU) ? (0x04c11db7U 
                                                  ^ __Vdfg_Regularize_1022)
                               : __Vdfg_Regularize_1022);
    __Vdfg_Regularize_901 = ((__Vdfg_Regularize_900 
                              << 1U) | (1U & (vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_4__DOT__u_crc_parallel_full__DOT__reg_data 
                                              >> 0x00000017U)));
    __Vdfg_Regularize_1024 = ((__Vdfg_Regularize_1023 
                               << 1U) | (1U & (vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_4__DOT__u_crc_parallel_full__DOT__reg_data 
                                               >> 0x00000017U)));
    __Vdfg_Regularize_865 = ((4U & (IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_4__DOT__u_crc_parallel_full__DOT__reg_keep))
                              ? ((__Vdfg_Regularize_900 
                                  >> 0x0000001fU) ? 
                                 (0x04c11db7U ^ __Vdfg_Regularize_901)
                                  : __Vdfg_Regularize_901)
                              : __Vdfg_Regularize_864);
    __Vdfg_Regularize_869 = ((4U & (IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_4__DOT__u_crc_parallel_full__DOT__reg_keep))
                              ? ((__Vdfg_Regularize_1023 
                                  >> 0x0000001fU) ? 
                                 (0x04c11db7U ^ __Vdfg_Regularize_1024)
                                  : __Vdfg_Regularize_1024)
                              : __Vdfg_Regularize_868);
    __Vdfg_Regularize_902 = ((__Vdfg_Regularize_865 
                              << 1U) | (1U & (vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_4__DOT__u_crc_parallel_full__DOT__reg_data 
                                              >> 8U)));
    __Vdfg_Regularize_1025 = ((__Vdfg_Regularize_869 
                               << 1U) | (1U & (vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_4__DOT__u_crc_parallel_full__DOT__reg_data 
                                               >> 8U)));
    __Vdfg_Regularize_903 = ((__Vdfg_Regularize_865 
                              >> 0x0000001fU) ? (0x04c11db7U 
                                                 ^ __Vdfg_Regularize_902)
                              : __Vdfg_Regularize_902);
    __Vdfg_Regularize_1026 = ((__Vdfg_Regularize_869 
                               >> 0x0000001fU) ? (0x04c11db7U 
                                                  ^ __Vdfg_Regularize_1025)
                               : __Vdfg_Regularize_1025);
    __Vdfg_Regularize_904 = ((__Vdfg_Regularize_903 
                              << 1U) | (1U & (vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_4__DOT__u_crc_parallel_full__DOT__reg_data 
                                              >> 9U)));
    __Vdfg_Regularize_1027 = ((__Vdfg_Regularize_1026 
                               << 1U) | (1U & (vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_4__DOT__u_crc_parallel_full__DOT__reg_data 
                                               >> 9U)));
    __Vdfg_Regularize_905 = ((__Vdfg_Regularize_903 
                              >> 0x0000001fU) ? (0x04c11db7U 
                                                 ^ __Vdfg_Regularize_904)
                              : __Vdfg_Regularize_904);
    __Vdfg_Regularize_1028 = ((__Vdfg_Regularize_1026 
                               >> 0x0000001fU) ? (0x04c11db7U 
                                                  ^ __Vdfg_Regularize_1027)
                               : __Vdfg_Regularize_1027);
    __Vdfg_Regularize_906 = ((__Vdfg_Regularize_905 
                              << 1U) | (1U & (vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_4__DOT__u_crc_parallel_full__DOT__reg_data 
                                              >> 0x0000000aU)));
    __Vdfg_Regularize_1029 = ((__Vdfg_Regularize_1028 
                               << 1U) | (1U & (vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_4__DOT__u_crc_parallel_full__DOT__reg_data 
                                               >> 0x0000000aU)));
    __Vdfg_Regularize_907 = ((__Vdfg_Regularize_905 
                              >> 0x0000001fU) ? (0x04c11db7U 
                                                 ^ __Vdfg_Regularize_906)
                              : __Vdfg_Regularize_906);
    __Vdfg_Regularize_1030 = ((__Vdfg_Regularize_1028 
                               >> 0x0000001fU) ? (0x04c11db7U 
                                                  ^ __Vdfg_Regularize_1029)
                               : __Vdfg_Regularize_1029);
    __Vdfg_Regularize_908 = ((__Vdfg_Regularize_907 
                              << 1U) | (1U & (vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_4__DOT__u_crc_parallel_full__DOT__reg_data 
                                              >> 0x0000000bU)));
    __Vdfg_Regularize_1031 = ((__Vdfg_Regularize_1030 
                               << 1U) | (1U & (vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_4__DOT__u_crc_parallel_full__DOT__reg_data 
                                               >> 0x0000000bU)));
    __Vdfg_Regularize_909 = ((__Vdfg_Regularize_907 
                              >> 0x0000001fU) ? (0x04c11db7U 
                                                 ^ __Vdfg_Regularize_908)
                              : __Vdfg_Regularize_908);
    __Vdfg_Regularize_1032 = ((__Vdfg_Regularize_1030 
                               >> 0x0000001fU) ? (0x04c11db7U 
                                                  ^ __Vdfg_Regularize_1031)
                               : __Vdfg_Regularize_1031);
    __Vdfg_Regularize_910 = ((__Vdfg_Regularize_909 
                              << 1U) | (1U & (vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_4__DOT__u_crc_parallel_full__DOT__reg_data 
                                              >> 0x0000000cU)));
    __Vdfg_Regularize_1033 = ((__Vdfg_Regularize_1032 
                               << 1U) | (1U & (vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_4__DOT__u_crc_parallel_full__DOT__reg_data 
                                               >> 0x0000000cU)));
    __Vdfg_Regularize_911 = ((__Vdfg_Regularize_909 
                              >> 0x0000001fU) ? (0x04c11db7U 
                                                 ^ __Vdfg_Regularize_910)
                              : __Vdfg_Regularize_910);
    __Vdfg_Regularize_1034 = ((__Vdfg_Regularize_1032 
                               >> 0x0000001fU) ? (0x04c11db7U 
                                                  ^ __Vdfg_Regularize_1033)
                               : __Vdfg_Regularize_1033);
    __Vdfg_Regularize_912 = ((__Vdfg_Regularize_911 
                              << 1U) | (1U & (vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_4__DOT__u_crc_parallel_full__DOT__reg_data 
                                              >> 0x0000000dU)));
    __Vdfg_Regularize_1035 = ((__Vdfg_Regularize_1034 
                               << 1U) | (1U & (vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_4__DOT__u_crc_parallel_full__DOT__reg_data 
                                               >> 0x0000000dU)));
    __Vdfg_Regularize_913 = ((__Vdfg_Regularize_911 
                              >> 0x0000001fU) ? (0x04c11db7U 
                                                 ^ __Vdfg_Regularize_912)
                              : __Vdfg_Regularize_912);
    __Vdfg_Regularize_1036 = ((__Vdfg_Regularize_1034 
                               >> 0x0000001fU) ? (0x04c11db7U 
                                                  ^ __Vdfg_Regularize_1035)
                               : __Vdfg_Regularize_1035);
    __Vdfg_Regularize_914 = ((__Vdfg_Regularize_913 
                              << 1U) | (1U & (vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_4__DOT__u_crc_parallel_full__DOT__reg_data 
                                              >> 0x0000000eU)));
    __Vdfg_Regularize_1037 = ((__Vdfg_Regularize_1036 
                               << 1U) | (1U & (vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_4__DOT__u_crc_parallel_full__DOT__reg_data 
                                               >> 0x0000000eU)));
    __Vdfg_Regularize_915 = ((__Vdfg_Regularize_913 
                              >> 0x0000001fU) ? (0x04c11db7U 
                                                 ^ __Vdfg_Regularize_914)
                              : __Vdfg_Regularize_914);
    __Vdfg_Regularize_1038 = ((__Vdfg_Regularize_1036 
                               >> 0x0000001fU) ? (0x04c11db7U 
                                                  ^ __Vdfg_Regularize_1037)
                               : __Vdfg_Regularize_1037);
    __Vdfg_Regularize_916 = ((__Vdfg_Regularize_915 
                              << 1U) | (1U & (vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_4__DOT__u_crc_parallel_full__DOT__reg_data 
                                              >> 0x0000000fU)));
    __Vdfg_Regularize_1039 = ((__Vdfg_Regularize_1038 
                               << 1U) | (1U & (vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_4__DOT__u_crc_parallel_full__DOT__reg_data 
                                               >> 0x0000000fU)));
    __Vdfg_Regularize_866 = ((2U & (IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_4__DOT__u_crc_parallel_full__DOT__reg_keep))
                              ? ((__Vdfg_Regularize_915 
                                  >> 0x0000001fU) ? 
                                 (0x04c11db7U ^ __Vdfg_Regularize_916)
                                  : __Vdfg_Regularize_916)
                              : __Vdfg_Regularize_865);
    __Vdfg_Regularize_870 = ((2U & (IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_4__DOT__u_crc_parallel_full__DOT__reg_keep))
                              ? ((__Vdfg_Regularize_1038 
                                  >> 0x0000001fU) ? 
                                 (0x04c11db7U ^ __Vdfg_Regularize_1039)
                                  : __Vdfg_Regularize_1039)
                              : __Vdfg_Regularize_869);
    __Vdfg_Regularize_917 = ((__Vdfg_Regularize_866 
                              << 1U) | (1U & vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_4__DOT__u_crc_parallel_full__DOT__reg_data));
    __Vdfg_Regularize_1040 = ((__Vdfg_Regularize_870 
                               << 1U) | (1U & vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_4__DOT__u_crc_parallel_full__DOT__reg_data));
    __Vdfg_Regularize_918 = ((__Vdfg_Regularize_866 
                              >> 0x0000001fU) ? (0x04c11db7U 
                                                 ^ __Vdfg_Regularize_917)
                              : __Vdfg_Regularize_917);
    __Vdfg_Regularize_1041 = ((__Vdfg_Regularize_870 
                               >> 0x0000001fU) ? (0x04c11db7U 
                                                  ^ __Vdfg_Regularize_1040)
                               : __Vdfg_Regularize_1040);
    __Vdfg_Regularize_919 = ((__Vdfg_Regularize_918 
                              << 1U) | (1U & (vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_4__DOT__u_crc_parallel_full__DOT__reg_data 
                                              >> 1U)));
    __Vdfg_Regularize_1042 = ((__Vdfg_Regularize_1041 
                               << 1U) | (1U & (vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_4__DOT__u_crc_parallel_full__DOT__reg_data 
                                               >> 1U)));
    __Vdfg_Regularize_920 = ((__Vdfg_Regularize_918 
                              >> 0x0000001fU) ? (0x04c11db7U 
                                                 ^ __Vdfg_Regularize_919)
                              : __Vdfg_Regularize_919);
    __Vdfg_Regularize_1043 = ((__Vdfg_Regularize_1041 
                               >> 0x0000001fU) ? (0x04c11db7U 
                                                  ^ __Vdfg_Regularize_1042)
                               : __Vdfg_Regularize_1042);
    __Vdfg_Regularize_921 = ((__Vdfg_Regularize_920 
                              << 1U) | (1U & (vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_4__DOT__u_crc_parallel_full__DOT__reg_data 
                                              >> 2U)));
    __Vdfg_Regularize_1044 = ((__Vdfg_Regularize_1043 
                               << 1U) | (1U & (vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_4__DOT__u_crc_parallel_full__DOT__reg_data 
                                               >> 2U)));
    __Vdfg_Regularize_922 = ((__Vdfg_Regularize_920 
                              >> 0x0000001fU) ? (0x04c11db7U 
                                                 ^ __Vdfg_Regularize_921)
                              : __Vdfg_Regularize_921);
    __Vdfg_Regularize_1045 = ((__Vdfg_Regularize_1043 
                               >> 0x0000001fU) ? (0x04c11db7U 
                                                  ^ __Vdfg_Regularize_1044)
                               : __Vdfg_Regularize_1044);
    __Vdfg_Regularize_923 = ((__Vdfg_Regularize_922 
                              << 1U) | (1U & (vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_4__DOT__u_crc_parallel_full__DOT__reg_data 
                                              >> 3U)));
    __Vdfg_Regularize_1046 = ((__Vdfg_Regularize_1045 
                               << 1U) | (1U & (vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_4__DOT__u_crc_parallel_full__DOT__reg_data 
                                               >> 3U)));
    __Vdfg_Regularize_924 = ((__Vdfg_Regularize_922 
                              >> 0x0000001fU) ? (0x04c11db7U 
                                                 ^ __Vdfg_Regularize_923)
                              : __Vdfg_Regularize_923);
    __Vdfg_Regularize_1047 = ((__Vdfg_Regularize_1045 
                               >> 0x0000001fU) ? (0x04c11db7U 
                                                  ^ __Vdfg_Regularize_1046)
                               : __Vdfg_Regularize_1046);
    __Vdfg_Regularize_925 = ((__Vdfg_Regularize_924 
                              << 1U) | (1U & (vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_4__DOT__u_crc_parallel_full__DOT__reg_data 
                                              >> 4U)));
    __Vdfg_Regularize_1048 = ((__Vdfg_Regularize_1047 
                               << 1U) | (1U & (vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_4__DOT__u_crc_parallel_full__DOT__reg_data 
                                               >> 4U)));
    __Vdfg_Regularize_926 = ((__Vdfg_Regularize_924 
                              >> 0x0000001fU) ? (0x04c11db7U 
                                                 ^ __Vdfg_Regularize_925)
                              : __Vdfg_Regularize_925);
    __Vdfg_Regularize_1049 = ((__Vdfg_Regularize_1047 
                               >> 0x0000001fU) ? (0x04c11db7U 
                                                  ^ __Vdfg_Regularize_1048)
                               : __Vdfg_Regularize_1048);
    __Vdfg_Regularize_927 = ((__Vdfg_Regularize_926 
                              << 1U) | (1U & (vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_4__DOT__u_crc_parallel_full__DOT__reg_data 
                                              >> 5U)));
    __Vdfg_Regularize_1050 = ((__Vdfg_Regularize_1049 
                               << 1U) | (1U & (vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_4__DOT__u_crc_parallel_full__DOT__reg_data 
                                               >> 5U)));
    __Vdfg_Regularize_928 = ((__Vdfg_Regularize_926 
                              >> 0x0000001fU) ? (0x04c11db7U 
                                                 ^ __Vdfg_Regularize_927)
                              : __Vdfg_Regularize_927);
    __Vdfg_Regularize_1051 = ((__Vdfg_Regularize_1049 
                               >> 0x0000001fU) ? (0x04c11db7U 
                                                  ^ __Vdfg_Regularize_1050)
                               : __Vdfg_Regularize_1050);
    __Vdfg_Regularize_929 = ((__Vdfg_Regularize_928 
                              << 1U) | (1U & (vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_4__DOT__u_crc_parallel_full__DOT__reg_data 
                                              >> 6U)));
    __Vdfg_Regularize_1052 = ((__Vdfg_Regularize_1051 
                               << 1U) | (1U & (vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_4__DOT__u_crc_parallel_full__DOT__reg_data 
                                               >> 6U)));
    __Vdfg_Regularize_930 = ((__Vdfg_Regularize_928 
                              >> 0x0000001fU) ? (0x04c11db7U 
                                                 ^ __Vdfg_Regularize_929)
                              : __Vdfg_Regularize_929);
    __Vdfg_Regularize_1053 = ((__Vdfg_Regularize_1051 
                               >> 0x0000001fU) ? (0x04c11db7U 
                                                  ^ __Vdfg_Regularize_1052)
                               : __Vdfg_Regularize_1052);
    __Vdfg_Regularize_931 = ((__Vdfg_Regularize_930 
                              << 1U) | (1U & (vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_4__DOT__u_crc_parallel_full__DOT__reg_data 
                                              >> 7U)));
    __Vdfg_Regularize_1054 = ((__Vdfg_Regularize_1053 
                               << 1U) | (1U & (vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_4__DOT__u_crc_parallel_full__DOT__reg_data 
                                               >> 7U)));
    __Vdfg_Regularize_867 = ((1U & (IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_4__DOT__u_crc_parallel_full__DOT__reg_keep))
                              ? ((__Vdfg_Regularize_930 
                                  >> 0x0000001fU) ? 
                                 (0x04c11db7U ^ __Vdfg_Regularize_931)
                                  : __Vdfg_Regularize_931)
                              : __Vdfg_Regularize_866);
    __Vdfg_Regularize_871 = ((1U & (IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_4__DOT__u_crc_parallel_full__DOT__reg_keep))
                              ? ((__Vdfg_Regularize_1053 
                                  >> 0x0000001fU) ? 
                                 (0x04c11db7U ^ __Vdfg_Regularize_1054)
                                  : __Vdfg_Regularize_1054)
                              : __Vdfg_Regularize_870);
    __Vdfg_Regularize_932 = ((__Vdfg_Regularize_867 
                              >> 0x0000001fU) ? (1U 
                                                 | (0xfffffffeU 
                                                    & (0x04c11db6U 
                                                       ^ 
                                                       (__Vdfg_Regularize_867 
                                                        << 1U))))
                              : (__Vdfg_Regularize_867 
                                 << 1U));
    __Vdfg_Regularize_1055 = ((__Vdfg_Regularize_871 
                               >> 0x0000001fU) ? (1U 
                                                  | (0xfffffffeU 
                                                     & (0x04c11db6U 
                                                        ^ 
                                                        (__Vdfg_Regularize_871 
                                                         << 1U))))
                               : (__Vdfg_Regularize_871 
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
    __Vdfg_Regularize_1056 = ((__Vdfg_Regularize_1055 
                               >> 0x0000001fU) ? (1U 
                                                  | (0xfffffffeU 
                                                     & (0x04c11db6U 
                                                        ^ 
                                                        (__Vdfg_Regularize_1055 
                                                         << 1U))))
                               : (__Vdfg_Regularize_1055 
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
    __Vdfg_Regularize_1057 = ((__Vdfg_Regularize_1056 
                               >> 0x0000001fU) ? (1U 
                                                  | (0xfffffffeU 
                                                     & (0x04c11db6U 
                                                        ^ 
                                                        (__Vdfg_Regularize_1056 
                                                         << 1U))))
                               : (__Vdfg_Regularize_1056 
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
    __Vdfg_Regularize_1058 = ((__Vdfg_Regularize_1057 
                               >> 0x0000001fU) ? (1U 
                                                  | (0xfffffffeU 
                                                     & (0x04c11db6U 
                                                        ^ 
                                                        (__Vdfg_Regularize_1057 
                                                         << 1U))))
                               : (__Vdfg_Regularize_1057 
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
    __Vdfg_Regularize_1059 = ((__Vdfg_Regularize_1058 
                               >> 0x0000001fU) ? (1U 
                                                  | (0xfffffffeU 
                                                     & (0x04c11db6U 
                                                        ^ 
                                                        (__Vdfg_Regularize_1058 
                                                         << 1U))))
                               : (__Vdfg_Regularize_1058 
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
    __Vdfg_Regularize_1060 = ((__Vdfg_Regularize_1059 
                               >> 0x0000001fU) ? (1U 
                                                  | (0xfffffffeU 
                                                     & (0x04c11db6U 
                                                        ^ 
                                                        (__Vdfg_Regularize_1059 
                                                         << 1U))))
                               : (__Vdfg_Regularize_1059 
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
    __Vdfg_Regularize_1061 = ((__Vdfg_Regularize_1060 
                               >> 0x0000001fU) ? (1U 
                                                  | (0xfffffffeU 
                                                     & (0x04c11db6U 
                                                        ^ 
                                                        (__Vdfg_Regularize_1060 
                                                         << 1U))))
                               : (__Vdfg_Regularize_1060 
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
    __Vdfg_Regularize_1062 = ((__Vdfg_Regularize_1061 
                               >> 0x0000001fU) ? (1U 
                                                  | (0xfffffffeU 
                                                     & (0x04c11db6U 
                                                        ^ 
                                                        (__Vdfg_Regularize_1061 
                                                         << 1U))))
                               : (__Vdfg_Regularize_1061 
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
    __Vdfg_Regularize_1063 = ((__Vdfg_Regularize_1062 
                               >> 0x0000001fU) ? (1U 
                                                  | (0xfffffffeU 
                                                     & (0x04c11db6U 
                                                        ^ 
                                                        (__Vdfg_Regularize_1062 
                                                         << 1U))))
                               : (__Vdfg_Regularize_1062 
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
    __Vdfg_Regularize_1064 = ((__Vdfg_Regularize_1063 
                               >> 0x0000001fU) ? (1U 
                                                  | (0xfffffffeU 
                                                     & (0x04c11db6U 
                                                        ^ 
                                                        (__Vdfg_Regularize_1063 
                                                         << 1U))))
                               : (__Vdfg_Regularize_1063 
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
    __Vdfg_Regularize_1065 = ((__Vdfg_Regularize_1064 
                               >> 0x0000001fU) ? (1U 
                                                  | (0xfffffffeU 
                                                     & (0x04c11db6U 
                                                        ^ 
                                                        (__Vdfg_Regularize_1064 
                                                         << 1U))))
                               : (__Vdfg_Regularize_1064 
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
    __Vdfg_Regularize_1066 = ((__Vdfg_Regularize_1065 
                               >> 0x0000001fU) ? (1U 
                                                  | (0xfffffffeU 
                                                     & (0x04c11db6U 
                                                        ^ 
                                                        (__Vdfg_Regularize_1065 
                                                         << 1U))))
                               : (__Vdfg_Regularize_1065 
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
    __Vdfg_Regularize_1067 = ((__Vdfg_Regularize_1066 
                               >> 0x0000001fU) ? (1U 
                                                  | (0xfffffffeU 
                                                     & (0x04c11db6U 
                                                        ^ 
                                                        (__Vdfg_Regularize_1066 
                                                         << 1U))))
                               : (__Vdfg_Regularize_1066 
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
    __Vdfg_Regularize_1068 = ((__Vdfg_Regularize_1067 
                               >> 0x0000001fU) ? (1U 
                                                  | (0xfffffffeU 
                                                     & (0x04c11db6U 
                                                        ^ 
                                                        (__Vdfg_Regularize_1067 
                                                         << 1U))))
                               : (__Vdfg_Regularize_1067 
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
    __Vdfg_Regularize_1069 = ((__Vdfg_Regularize_1068 
                               >> 0x0000001fU) ? (1U 
                                                  | (0xfffffffeU 
                                                     & (0x04c11db6U 
                                                        ^ 
                                                        (__Vdfg_Regularize_1068 
                                                         << 1U))))
                               : (__Vdfg_Regularize_1068 
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
    __Vdfg_Regularize_1070 = ((__Vdfg_Regularize_1069 
                               >> 0x0000001fU) ? (1U 
                                                  | (0xfffffffeU 
                                                     & (0x04c11db6U 
                                                        ^ 
                                                        (__Vdfg_Regularize_1069 
                                                         << 1U))))
                               : (__Vdfg_Regularize_1069 
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
    __Vdfg_Regularize_1071 = ((__Vdfg_Regularize_1070 
                               >> 0x0000001fU) ? (1U 
                                                  | (0xfffffffeU 
                                                     & (0x04c11db6U 
                                                        ^ 
                                                        (__Vdfg_Regularize_1070 
                                                         << 1U))))
                               : (__Vdfg_Regularize_1070 
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
    __Vdfg_Regularize_1072 = ((__Vdfg_Regularize_1071 
                               >> 0x0000001fU) ? (1U 
                                                  | (0xfffffffeU 
                                                     & (0x04c11db6U 
                                                        ^ 
                                                        (__Vdfg_Regularize_1071 
                                                         << 1U))))
                               : (__Vdfg_Regularize_1071 
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
    __Vdfg_Regularize_1073 = ((__Vdfg_Regularize_1072 
                               >> 0x0000001fU) ? (1U 
                                                  | (0xfffffffeU 
                                                     & (0x04c11db6U 
                                                        ^ 
                                                        (__Vdfg_Regularize_1072 
                                                         << 1U))))
                               : (__Vdfg_Regularize_1072 
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
    __Vdfg_Regularize_1074 = ((__Vdfg_Regularize_1073 
                               >> 0x0000001fU) ? (1U 
                                                  | (0xfffffffeU 
                                                     & (0x04c11db6U 
                                                        ^ 
                                                        (__Vdfg_Regularize_1073 
                                                         << 1U))))
                               : (__Vdfg_Regularize_1073 
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
    __Vdfg_Regularize_1075 = ((__Vdfg_Regularize_1074 
                               >> 0x0000001fU) ? (1U 
                                                  | (0xfffffffeU 
                                                     & (0x04c11db6U 
                                                        ^ 
                                                        (__Vdfg_Regularize_1074 
                                                         << 1U))))
                               : (__Vdfg_Regularize_1074 
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
    __Vdfg_Regularize_1076 = ((__Vdfg_Regularize_1075 
                               >> 0x0000001fU) ? (1U 
                                                  | (0xfffffffeU 
                                                     & (0x04c11db6U 
                                                        ^ 
                                                        (__Vdfg_Regularize_1075 
                                                         << 1U))))
                               : (__Vdfg_Regularize_1075 
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
    __Vdfg_Regularize_1077 = ((__Vdfg_Regularize_1076 
                               >> 0x0000001fU) ? (1U 
                                                  | (0xfffffffeU 
                                                     & (0x04c11db6U 
                                                        ^ 
                                                        (__Vdfg_Regularize_1076 
                                                         << 1U))))
                               : (__Vdfg_Regularize_1076 
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
    __Vdfg_Regularize_1078 = ((__Vdfg_Regularize_1077 
                               >> 0x0000001fU) ? (1U 
                                                  | (0xfffffffeU 
                                                     & (0x04c11db6U 
                                                        ^ 
                                                        (__Vdfg_Regularize_1077 
                                                         << 1U))))
                               : (__Vdfg_Regularize_1077 
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
    __Vdfg_Regularize_1079 = ((__Vdfg_Regularize_1078 
                               >> 0x0000001fU) ? (1U 
                                                  | (0xfffffffeU 
                                                     & (0x04c11db6U 
                                                        ^ 
                                                        (__Vdfg_Regularize_1078 
                                                         << 1U))))
                               : (__Vdfg_Regularize_1078 
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
    __Vdfg_Regularize_1080 = ((__Vdfg_Regularize_1079 
                               >> 0x0000001fU) ? (1U 
                                                  | (0xfffffffeU 
                                                     & (0x04c11db6U 
                                                        ^ 
                                                        (__Vdfg_Regularize_1079 
                                                         << 1U))))
                               : (__Vdfg_Regularize_1079 
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
    __Vdfg_Regularize_1081 = ((__Vdfg_Regularize_1080 
                               >> 0x0000001fU) ? (1U 
                                                  | (0xfffffffeU 
                                                     & (0x04c11db6U 
                                                        ^ 
                                                        (__Vdfg_Regularize_1080 
                                                         << 1U))))
                               : (__Vdfg_Regularize_1080 
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
    __Vdfg_Regularize_1082 = ((__Vdfg_Regularize_1081 
                               >> 0x0000001fU) ? (1U 
                                                  | (0xfffffffeU 
                                                     & (0x04c11db6U 
                                                        ^ 
                                                        (__Vdfg_Regularize_1081 
                                                         << 1U))))
                               : (__Vdfg_Regularize_1081 
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
    __Vdfg_Regularize_1083 = ((__Vdfg_Regularize_1082 
                               >> 0x0000001fU) ? (1U 
                                                  | (0xfffffffeU 
                                                     & (0x04c11db6U 
                                                        ^ 
                                                        (__Vdfg_Regularize_1082 
                                                         << 1U))))
                               : (__Vdfg_Regularize_1082 
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
    __Vdfg_Regularize_1084 = ((__Vdfg_Regularize_1083 
                               >> 0x0000001fU) ? (1U 
                                                  | (0xfffffffeU 
                                                     & (0x04c11db6U 
                                                        ^ 
                                                        (__Vdfg_Regularize_1083 
                                                         << 1U))))
                               : (__Vdfg_Regularize_1083 
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
    __Vdfg_Regularize_1085 = ((__Vdfg_Regularize_1084 
                               >> 0x0000001fU) ? (1U 
                                                  | (0xfffffffeU 
                                                     & (0x04c11db6U 
                                                        ^ 
                                                        (__Vdfg_Regularize_1084 
                                                         << 1U))))
                               : (__Vdfg_Regularize_1084 
                                  << 1U));
    vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_4__DOT__u_crc_parallel_full__DOT__w_crc_nxt 
        = ((IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_4__DOT__u_crc_parallel_full__DOT__reg_last)
            ? ((__Vdfg_Regularize_962 >> 0x0000001fU)
                ? (1U | (0xfffffffeU & (0x04c11db6U 
                                        ^ (__Vdfg_Regularize_962 
                                           << 1U))))
                : (__Vdfg_Regularize_962 << 1U)) : __Vdfg_Regularize_867);
    vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_4__DOT__u_crc_parallel_full__DOT__w_crc_nxt 
        = ((IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_4__DOT__u_crc_parallel_full__DOT__reg_last)
            ? ((__Vdfg_Regularize_1085 >> 0x0000001fU)
                ? (1U | (0xfffffffeU & (0x04c11db6U 
                                        ^ (__Vdfg_Regularize_1085 
                                           << 1U))))
                : (__Vdfg_Regularize_1085 << 1U)) : __Vdfg_Regularize_871);
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
    vlSelf->o_gen_crc = VL_SCOPED_RAND_RESET_I(32, __VscopeHash, 3043168594990581637ull);
    vlSelf->o_gen_crc_valid = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 6406002674580164605ull);
    vlSelf->i_gen_crc_ready = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 1434365149430831710ull);
    vlSelf->i_check_data = VL_SCOPED_RAND_RESET_I(32, __VscopeHash, 13571094061161519279ull);
    vlSelf->i_check_keep = VL_SCOPED_RAND_RESET_I(4, __VscopeHash, 1808124001774256246ull);
    vlSelf->i_check_valid = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 16839616335746463692ull);
    vlSelf->i_check_last = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 12123212944353719355ull);
    vlSelf->i_check_crc = VL_SCOPED_RAND_RESET_I(32, __VscopeHash, 2616207439244663111ull);
    vlSelf->o_check_data_ready = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 16371218162537437167ull);
    vlSelf->o_check_pass = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 12134859985623663099ull);
    vlSelf->o_check_crc_valid = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 2628765057176209784ull);
    vlSelf->i_check_crc_ready = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 14697704443546574182ull);
    vlSelf->m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__reg_check_crc_ref = VL_SCOPED_RAND_RESET_I(32, __VscopeHash, 5577206290272303270ull);
    vlSelf->m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_4__DOT__u_crc_parallel_full__DOT__reg_crc_state = VL_SCOPED_RAND_RESET_I(32, __VscopeHash, 13610779891690354668ull);
    vlSelf->m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_4__DOT__u_crc_parallel_full__DOT__reg_crc_output = VL_SCOPED_RAND_RESET_I(32, __VscopeHash, 11223210158918720918ull);
    vlSelf->m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_4__DOT__u_crc_parallel_full__DOT__reg_data = VL_SCOPED_RAND_RESET_I(32, __VscopeHash, 9608099358741644235ull);
    vlSelf->m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_4__DOT__u_crc_parallel_full__DOT__reg_keep = VL_SCOPED_RAND_RESET_I(4, __VscopeHash, 7090268364461047129ull);
    vlSelf->m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_4__DOT__u_crc_parallel_full__DOT__w_crc_nxt = VL_SCOPED_RAND_RESET_I(32, __VscopeHash, 5214613064981067110ull);
    vlSelf->m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_4__DOT__u_crc_parallel_full__DOT__reg_last = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 12490305210461960448ull);
    vlSelf->m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_4__DOT__u_crc_parallel_full__DOT__reg_busy = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 15032014486116969465ull);
    vlSelf->m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_4__DOT__u_crc_parallel_full__DOT__reg_crc_valid = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 3461194552164544074ull);
    vlSelf->m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_4__DOT__u_crc_parallel_full__DOT__reg_crc_state = VL_SCOPED_RAND_RESET_I(32, __VscopeHash, 14750363205640798413ull);
    vlSelf->m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_4__DOT__u_crc_parallel_full__DOT__reg_crc_output = VL_SCOPED_RAND_RESET_I(32, __VscopeHash, 15794304638862430893ull);
    vlSelf->m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_4__DOT__u_crc_parallel_full__DOT__reg_data = VL_SCOPED_RAND_RESET_I(32, __VscopeHash, 16628585295193913289ull);
    vlSelf->m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_4__DOT__u_crc_parallel_full__DOT__reg_keep = VL_SCOPED_RAND_RESET_I(4, __VscopeHash, 6601966535436248533ull);
    vlSelf->m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_4__DOT__u_crc_parallel_full__DOT__w_crc_nxt = VL_SCOPED_RAND_RESET_I(32, __VscopeHash, 1342899061654711202ull);
    vlSelf->m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_4__DOT__u_crc_parallel_full__DOT__reg_last = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 16700271703580900750ull);
    vlSelf->m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_4__DOT__u_crc_parallel_full__DOT__reg_busy = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 15419041305442938860ull);
    vlSelf->m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_4__DOT__u_crc_parallel_full__DOT__reg_crc_valid = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 16981835320424313304ull);
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
