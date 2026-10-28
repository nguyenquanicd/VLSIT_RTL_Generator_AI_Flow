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
    IData/*31:0*/ __Vdfg_Regularize_1812;
    __Vdfg_Regularize_1812 = 0;
    IData/*31:0*/ __Vdfg_Regularize_1814;
    __Vdfg_Regularize_1814 = 0;
    IData/*31:0*/ __Vdfg_Regularize_1816;
    __Vdfg_Regularize_1816 = 0;
    IData/*31:0*/ __Vdfg_Regularize_1818;
    __Vdfg_Regularize_1818 = 0;
    IData/*31:0*/ __Vdfg_Regularize_1820;
    __Vdfg_Regularize_1820 = 0;
    IData/*31:0*/ __Vdfg_Regularize_1822;
    __Vdfg_Regularize_1822 = 0;
    IData/*31:0*/ __Vdfg_Regularize_1824;
    __Vdfg_Regularize_1824 = 0;
    IData/*31:0*/ __Vdfg_Regularize_1826;
    __Vdfg_Regularize_1826 = 0;
    IData/*31:0*/ __Vdfg_Regularize_1828;
    __Vdfg_Regularize_1828 = 0;
    IData/*31:0*/ __Vdfg_Regularize_1830;
    __Vdfg_Regularize_1830 = 0;
    IData/*31:0*/ __Vdfg_Regularize_1832;
    __Vdfg_Regularize_1832 = 0;
    IData/*31:0*/ __Vdfg_Regularize_1834;
    __Vdfg_Regularize_1834 = 0;
    IData/*31:0*/ __Vdfg_Regularize_1836;
    __Vdfg_Regularize_1836 = 0;
    IData/*31:0*/ __Vdfg_Regularize_1838;
    __Vdfg_Regularize_1838 = 0;
    IData/*31:0*/ __Vdfg_Regularize_1840;
    __Vdfg_Regularize_1840 = 0;
    IData/*31:0*/ __Vdfg_Regularize_1842;
    __Vdfg_Regularize_1842 = 0;
    IData/*31:0*/ __Vdfg_Regularize_1844;
    __Vdfg_Regularize_1844 = 0;
    IData/*31:0*/ __Vdfg_Regularize_1846;
    __Vdfg_Regularize_1846 = 0;
    IData/*31:0*/ __Vdfg_Regularize_1848;
    __Vdfg_Regularize_1848 = 0;
    IData/*31:0*/ __Vdfg_Regularize_1850;
    __Vdfg_Regularize_1850 = 0;
    IData/*31:0*/ __Vdfg_Regularize_1852;
    __Vdfg_Regularize_1852 = 0;
    IData/*31:0*/ __Vdfg_Regularize_1854;
    __Vdfg_Regularize_1854 = 0;
    IData/*31:0*/ __Vdfg_Regularize_1856;
    __Vdfg_Regularize_1856 = 0;
    IData/*31:0*/ __Vdfg_Regularize_1858;
    __Vdfg_Regularize_1858 = 0;
    IData/*31:0*/ __Vdfg_Regularize_1860;
    __Vdfg_Regularize_1860 = 0;
    IData/*31:0*/ __Vdfg_Regularize_1862;
    __Vdfg_Regularize_1862 = 0;
    IData/*31:0*/ __Vdfg_Regularize_1864;
    __Vdfg_Regularize_1864 = 0;
    IData/*31:0*/ __Vdfg_Regularize_1866;
    __Vdfg_Regularize_1866 = 0;
    IData/*31:0*/ __Vdfg_Regularize_1868;
    __Vdfg_Regularize_1868 = 0;
    IData/*31:0*/ __Vdfg_Regularize_1870;
    __Vdfg_Regularize_1870 = 0;
    IData/*31:0*/ __Vdfg_Regularize_1872;
    __Vdfg_Regularize_1872 = 0;
    IData/*31:0*/ __Vdfg_Regularize_1875;
    __Vdfg_Regularize_1875 = 0;
    IData/*31:0*/ __Vdfg_Regularize_1877;
    __Vdfg_Regularize_1877 = 0;
    IData/*31:0*/ __Vdfg_Regularize_1879;
    __Vdfg_Regularize_1879 = 0;
    IData/*31:0*/ __Vdfg_Regularize_1881;
    __Vdfg_Regularize_1881 = 0;
    IData/*31:0*/ __Vdfg_Regularize_1883;
    __Vdfg_Regularize_1883 = 0;
    IData/*31:0*/ __Vdfg_Regularize_1885;
    __Vdfg_Regularize_1885 = 0;
    IData/*31:0*/ __Vdfg_Regularize_1887;
    __Vdfg_Regularize_1887 = 0;
    IData/*31:0*/ __Vdfg_Regularize_1889;
    __Vdfg_Regularize_1889 = 0;
    IData/*31:0*/ __Vdfg_Regularize_1891;
    __Vdfg_Regularize_1891 = 0;
    IData/*31:0*/ __Vdfg_Regularize_1893;
    __Vdfg_Regularize_1893 = 0;
    IData/*31:0*/ __Vdfg_Regularize_1895;
    __Vdfg_Regularize_1895 = 0;
    IData/*31:0*/ __Vdfg_Regularize_1897;
    __Vdfg_Regularize_1897 = 0;
    IData/*31:0*/ __Vdfg_Regularize_1899;
    __Vdfg_Regularize_1899 = 0;
    IData/*31:0*/ __Vdfg_Regularize_1901;
    __Vdfg_Regularize_1901 = 0;
    IData/*31:0*/ __Vdfg_Regularize_1903;
    __Vdfg_Regularize_1903 = 0;
    IData/*31:0*/ __Vdfg_Regularize_1905;
    __Vdfg_Regularize_1905 = 0;
    IData/*31:0*/ __Vdfg_Regularize_1907;
    __Vdfg_Regularize_1907 = 0;
    IData/*31:0*/ __Vdfg_Regularize_1909;
    __Vdfg_Regularize_1909 = 0;
    IData/*31:0*/ __Vdfg_Regularize_1911;
    __Vdfg_Regularize_1911 = 0;
    IData/*31:0*/ __Vdfg_Regularize_1913;
    __Vdfg_Regularize_1913 = 0;
    IData/*31:0*/ __Vdfg_Regularize_1915;
    __Vdfg_Regularize_1915 = 0;
    IData/*31:0*/ __Vdfg_Regularize_1917;
    __Vdfg_Regularize_1917 = 0;
    IData/*31:0*/ __Vdfg_Regularize_1919;
    __Vdfg_Regularize_1919 = 0;
    IData/*31:0*/ __Vdfg_Regularize_1921;
    __Vdfg_Regularize_1921 = 0;
    IData/*31:0*/ __Vdfg_Regularize_1923;
    __Vdfg_Regularize_1923 = 0;
    IData/*31:0*/ __Vdfg_Regularize_1925;
    __Vdfg_Regularize_1925 = 0;
    IData/*31:0*/ __Vdfg_Regularize_1927;
    __Vdfg_Regularize_1927 = 0;
    IData/*31:0*/ __Vdfg_Regularize_1929;
    __Vdfg_Regularize_1929 = 0;
    IData/*31:0*/ __Vdfg_Regularize_1931;
    __Vdfg_Regularize_1931 = 0;
    IData/*31:0*/ __Vdfg_Regularize_1933;
    __Vdfg_Regularize_1933 = 0;
    IData/*31:0*/ __Vdfg_Regularize_1935;
    __Vdfg_Regularize_1935 = 0;
    IData/*31:0*/ __Vdfg_Regularize_1938;
    __Vdfg_Regularize_1938 = 0;
    IData/*31:0*/ __Vdfg_Regularize_1939;
    __Vdfg_Regularize_1939 = 0;
    IData/*31:0*/ __Vdfg_Regularize_1940;
    __Vdfg_Regularize_1940 = 0;
    IData/*31:0*/ __Vdfg_Regularize_1941;
    __Vdfg_Regularize_1941 = 0;
    IData/*31:0*/ __Vdfg_Regularize_1942;
    __Vdfg_Regularize_1942 = 0;
    IData/*31:0*/ __Vdfg_Regularize_1943;
    __Vdfg_Regularize_1943 = 0;
    IData/*31:0*/ __Vdfg_Regularize_1944;
    __Vdfg_Regularize_1944 = 0;
    IData/*31:0*/ __Vdfg_Regularize_1945;
    __Vdfg_Regularize_1945 = 0;
    IData/*31:0*/ __Vdfg_Regularize_1946;
    __Vdfg_Regularize_1946 = 0;
    IData/*31:0*/ __Vdfg_Regularize_1947;
    __Vdfg_Regularize_1947 = 0;
    IData/*31:0*/ __Vdfg_Regularize_1948;
    __Vdfg_Regularize_1948 = 0;
    IData/*31:0*/ __Vdfg_Regularize_1949;
    __Vdfg_Regularize_1949 = 0;
    IData/*31:0*/ __Vdfg_Regularize_1950;
    __Vdfg_Regularize_1950 = 0;
    IData/*31:0*/ __Vdfg_Regularize_1951;
    __Vdfg_Regularize_1951 = 0;
    IData/*31:0*/ __Vdfg_Regularize_1952;
    __Vdfg_Regularize_1952 = 0;
    IData/*31:0*/ __Vdfg_Regularize_1953;
    __Vdfg_Regularize_1953 = 0;
    IData/*31:0*/ __Vdfg_Regularize_1954;
    __Vdfg_Regularize_1954 = 0;
    IData/*31:0*/ __Vdfg_Regularize_1955;
    __Vdfg_Regularize_1955 = 0;
    IData/*31:0*/ __Vdfg_Regularize_1956;
    __Vdfg_Regularize_1956 = 0;
    IData/*31:0*/ __Vdfg_Regularize_1957;
    __Vdfg_Regularize_1957 = 0;
    IData/*31:0*/ __Vdfg_Regularize_1958;
    __Vdfg_Regularize_1958 = 0;
    IData/*31:0*/ __Vdfg_Regularize_1959;
    __Vdfg_Regularize_1959 = 0;
    IData/*31:0*/ __Vdfg_Regularize_1960;
    __Vdfg_Regularize_1960 = 0;
    IData/*31:0*/ __Vdfg_Regularize_1961;
    __Vdfg_Regularize_1961 = 0;
    IData/*31:0*/ __Vdfg_Regularize_1962;
    __Vdfg_Regularize_1962 = 0;
    IData/*31:0*/ __Vdfg_Regularize_1963;
    __Vdfg_Regularize_1963 = 0;
    IData/*31:0*/ __Vdfg_Regularize_1964;
    __Vdfg_Regularize_1964 = 0;
    IData/*31:0*/ __Vdfg_Regularize_1965;
    __Vdfg_Regularize_1965 = 0;
    IData/*31:0*/ __Vdfg_Regularize_1966;
    __Vdfg_Regularize_1966 = 0;
    IData/*31:0*/ __Vdfg_Regularize_1967;
    __Vdfg_Regularize_1967 = 0;
    IData/*31:0*/ __Vdfg_Regularize_1968;
    __Vdfg_Regularize_1968 = 0;
    IData/*31:0*/ __Vdfg_Regularize_1969;
    __Vdfg_Regularize_1969 = 0;
    IData/*31:0*/ __Vdfg_Regularize_1970;
    __Vdfg_Regularize_1970 = 0;
    IData/*31:0*/ __Vdfg_Regularize_1971;
    __Vdfg_Regularize_1971 = 0;
    IData/*31:0*/ __Vdfg_Regularize_1972;
    __Vdfg_Regularize_1972 = 0;
    IData/*31:0*/ __Vdfg_Regularize_1973;
    __Vdfg_Regularize_1973 = 0;
    IData/*31:0*/ __Vdfg_Regularize_1974;
    __Vdfg_Regularize_1974 = 0;
    IData/*31:0*/ __Vdfg_Regularize_1975;
    __Vdfg_Regularize_1975 = 0;
    IData/*31:0*/ __Vdfg_Regularize_1976;
    __Vdfg_Regularize_1976 = 0;
    IData/*31:0*/ __Vdfg_Regularize_1977;
    __Vdfg_Regularize_1977 = 0;
    IData/*31:0*/ __Vdfg_Regularize_1978;
    __Vdfg_Regularize_1978 = 0;
    IData/*31:0*/ __Vdfg_Regularize_1979;
    __Vdfg_Regularize_1979 = 0;
    IData/*31:0*/ __Vdfg_Regularize_1980;
    __Vdfg_Regularize_1980 = 0;
    IData/*31:0*/ __Vdfg_Regularize_1981;
    __Vdfg_Regularize_1981 = 0;
    IData/*31:0*/ __Vdfg_Regularize_1982;
    __Vdfg_Regularize_1982 = 0;
    IData/*31:0*/ __Vdfg_Regularize_1983;
    __Vdfg_Regularize_1983 = 0;
    IData/*31:0*/ __Vdfg_Regularize_1984;
    __Vdfg_Regularize_1984 = 0;
    IData/*31:0*/ __Vdfg_Regularize_1985;
    __Vdfg_Regularize_1985 = 0;
    IData/*31:0*/ __Vdfg_Regularize_1986;
    __Vdfg_Regularize_1986 = 0;
    IData/*31:0*/ __Vdfg_Regularize_1987;
    __Vdfg_Regularize_1987 = 0;
    IData/*31:0*/ __Vdfg_Regularize_1988;
    __Vdfg_Regularize_1988 = 0;
    IData/*31:0*/ __Vdfg_Regularize_1989;
    __Vdfg_Regularize_1989 = 0;
    IData/*31:0*/ __Vdfg_Regularize_1990;
    __Vdfg_Regularize_1990 = 0;
    IData/*31:0*/ __Vdfg_Regularize_1991;
    __Vdfg_Regularize_1991 = 0;
    IData/*31:0*/ __Vdfg_Regularize_1992;
    __Vdfg_Regularize_1992 = 0;
    IData/*31:0*/ __Vdfg_Regularize_1993;
    __Vdfg_Regularize_1993 = 0;
    IData/*31:0*/ __Vdfg_Regularize_1994;
    __Vdfg_Regularize_1994 = 0;
    IData/*31:0*/ __Vdfg_Regularize_1995;
    __Vdfg_Regularize_1995 = 0;
    IData/*31:0*/ __Vdfg_Regularize_1996;
    __Vdfg_Regularize_1996 = 0;
    IData/*31:0*/ __Vdfg_Regularize_1997;
    __Vdfg_Regularize_1997 = 0;
    IData/*31:0*/ __Vdfg_Regularize_1998;
    __Vdfg_Regularize_1998 = 0;
    IData/*31:0*/ __Vdfg_Regularize_1999;
    __Vdfg_Regularize_1999 = 0;
    IData/*31:0*/ __Vdfg_Regularize_2000;
    __Vdfg_Regularize_2000 = 0;
    IData/*31:0*/ __Vdfg_Regularize_2033;
    __Vdfg_Regularize_2033 = 0;
    IData/*31:0*/ __Vdfg_Regularize_2034;
    __Vdfg_Regularize_2034 = 0;
    IData/*31:0*/ __Vdfg_Regularize_2035;
    __Vdfg_Regularize_2035 = 0;
    IData/*31:0*/ __Vdfg_Regularize_2036;
    __Vdfg_Regularize_2036 = 0;
    IData/*31:0*/ __Vdfg_Regularize_2037;
    __Vdfg_Regularize_2037 = 0;
    IData/*31:0*/ __Vdfg_Regularize_2038;
    __Vdfg_Regularize_2038 = 0;
    IData/*31:0*/ __Vdfg_Regularize_2039;
    __Vdfg_Regularize_2039 = 0;
    IData/*31:0*/ __Vdfg_Regularize_2040;
    __Vdfg_Regularize_2040 = 0;
    IData/*31:0*/ __Vdfg_Regularize_2041;
    __Vdfg_Regularize_2041 = 0;
    IData/*31:0*/ __Vdfg_Regularize_2042;
    __Vdfg_Regularize_2042 = 0;
    IData/*31:0*/ __Vdfg_Regularize_2043;
    __Vdfg_Regularize_2043 = 0;
    IData/*31:0*/ __Vdfg_Regularize_2044;
    __Vdfg_Regularize_2044 = 0;
    IData/*31:0*/ __Vdfg_Regularize_2045;
    __Vdfg_Regularize_2045 = 0;
    IData/*31:0*/ __Vdfg_Regularize_2046;
    __Vdfg_Regularize_2046 = 0;
    IData/*31:0*/ __Vdfg_Regularize_2047;
    __Vdfg_Regularize_2047 = 0;
    IData/*31:0*/ __Vdfg_Regularize_2048;
    __Vdfg_Regularize_2048 = 0;
    IData/*31:0*/ __Vdfg_Regularize_2049;
    __Vdfg_Regularize_2049 = 0;
    IData/*31:0*/ __Vdfg_Regularize_2050;
    __Vdfg_Regularize_2050 = 0;
    IData/*31:0*/ __Vdfg_Regularize_2051;
    __Vdfg_Regularize_2051 = 0;
    IData/*31:0*/ __Vdfg_Regularize_2052;
    __Vdfg_Regularize_2052 = 0;
    IData/*31:0*/ __Vdfg_Regularize_2053;
    __Vdfg_Regularize_2053 = 0;
    IData/*31:0*/ __Vdfg_Regularize_2054;
    __Vdfg_Regularize_2054 = 0;
    IData/*31:0*/ __Vdfg_Regularize_2055;
    __Vdfg_Regularize_2055 = 0;
    IData/*31:0*/ __Vdfg_Regularize_2056;
    __Vdfg_Regularize_2056 = 0;
    IData/*31:0*/ __Vdfg_Regularize_2057;
    __Vdfg_Regularize_2057 = 0;
    IData/*31:0*/ __Vdfg_Regularize_2058;
    __Vdfg_Regularize_2058 = 0;
    IData/*31:0*/ __Vdfg_Regularize_2059;
    __Vdfg_Regularize_2059 = 0;
    IData/*31:0*/ __Vdfg_Regularize_2060;
    __Vdfg_Regularize_2060 = 0;
    IData/*31:0*/ __Vdfg_Regularize_2061;
    __Vdfg_Regularize_2061 = 0;
    IData/*31:0*/ __Vdfg_Regularize_2062;
    __Vdfg_Regularize_2062 = 0;
    IData/*31:0*/ __Vdfg_Regularize_2063;
    __Vdfg_Regularize_2063 = 0;
    IData/*31:0*/ __Vdfg_Regularize_2064;
    __Vdfg_Regularize_2064 = 0;
    IData/*31:0*/ __Vdfg_Regularize_2065;
    __Vdfg_Regularize_2065 = 0;
    IData/*31:0*/ __Vdfg_Regularize_2066;
    __Vdfg_Regularize_2066 = 0;
    IData/*31:0*/ __Vdfg_Regularize_2067;
    __Vdfg_Regularize_2067 = 0;
    IData/*31:0*/ __Vdfg_Regularize_2068;
    __Vdfg_Regularize_2068 = 0;
    IData/*31:0*/ __Vdfg_Regularize_2069;
    __Vdfg_Regularize_2069 = 0;
    IData/*31:0*/ __Vdfg_Regularize_2070;
    __Vdfg_Regularize_2070 = 0;
    IData/*31:0*/ __Vdfg_Regularize_2071;
    __Vdfg_Regularize_2071 = 0;
    IData/*31:0*/ __Vdfg_Regularize_2072;
    __Vdfg_Regularize_2072 = 0;
    IData/*31:0*/ __Vdfg_Regularize_2073;
    __Vdfg_Regularize_2073 = 0;
    IData/*31:0*/ __Vdfg_Regularize_2074;
    __Vdfg_Regularize_2074 = 0;
    IData/*31:0*/ __Vdfg_Regularize_2075;
    __Vdfg_Regularize_2075 = 0;
    IData/*31:0*/ __Vdfg_Regularize_2076;
    __Vdfg_Regularize_2076 = 0;
    IData/*31:0*/ __Vdfg_Regularize_2077;
    __Vdfg_Regularize_2077 = 0;
    IData/*31:0*/ __Vdfg_Regularize_2078;
    __Vdfg_Regularize_2078 = 0;
    IData/*31:0*/ __Vdfg_Regularize_2079;
    __Vdfg_Regularize_2079 = 0;
    IData/*31:0*/ __Vdfg_Regularize_2080;
    __Vdfg_Regularize_2080 = 0;
    IData/*31:0*/ __Vdfg_Regularize_2081;
    __Vdfg_Regularize_2081 = 0;
    IData/*31:0*/ __Vdfg_Regularize_2082;
    __Vdfg_Regularize_2082 = 0;
    IData/*31:0*/ __Vdfg_Regularize_2083;
    __Vdfg_Regularize_2083 = 0;
    IData/*31:0*/ __Vdfg_Regularize_2084;
    __Vdfg_Regularize_2084 = 0;
    IData/*31:0*/ __Vdfg_Regularize_2085;
    __Vdfg_Regularize_2085 = 0;
    IData/*31:0*/ __Vdfg_Regularize_2086;
    __Vdfg_Regularize_2086 = 0;
    IData/*31:0*/ __Vdfg_Regularize_2087;
    __Vdfg_Regularize_2087 = 0;
    IData/*31:0*/ __Vdfg_Regularize_2088;
    __Vdfg_Regularize_2088 = 0;
    IData/*31:0*/ __Vdfg_Regularize_2089;
    __Vdfg_Regularize_2089 = 0;
    IData/*31:0*/ __Vdfg_Regularize_2090;
    __Vdfg_Regularize_2090 = 0;
    IData/*31:0*/ __Vdfg_Regularize_2091;
    __Vdfg_Regularize_2091 = 0;
    IData/*31:0*/ __Vdfg_Regularize_2092;
    __Vdfg_Regularize_2092 = 0;
    IData/*31:0*/ __Vdfg_Regularize_2093;
    __Vdfg_Regularize_2093 = 0;
    IData/*31:0*/ __Vdfg_Regularize_2094;
    __Vdfg_Regularize_2094 = 0;
    IData/*31:0*/ __Vdfg_Regularize_2095;
    __Vdfg_Regularize_2095 = 0;
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
                              & (vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__reg_check_crc_ref 
                                 == vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_3__DOT__u_crc_parallel_crcw__DOT__reg_crc_output));
    __Vdfg_Regularize_1970 = ((vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_3__DOT__u_crc_parallel_crcw__DOT__reg_crc_state 
                               >> 0x0000001fU) ? (1U 
                                                  | (0xfffffffeU 
                                                     & (0x04c11db6U 
                                                        ^ 
                                                        (vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_3__DOT__u_crc_parallel_crcw__DOT__reg_crc_state 
                                                         << 1U))))
                               : (vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_3__DOT__u_crc_parallel_crcw__DOT__reg_crc_state 
                                  << 1U));
    __Vdfg_Regularize_2065 = ((vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_3__DOT__u_crc_parallel_crcw__DOT__reg_crc_state 
                               >> 0x0000001fU) ? (1U 
                                                  | (0xfffffffeU 
                                                     & (0x04c11db6U 
                                                        ^ 
                                                        (vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_3__DOT__u_crc_parallel_crcw__DOT__reg_crc_state 
                                                         << 1U))))
                               : (vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_3__DOT__u_crc_parallel_crcw__DOT__reg_crc_state 
                                  << 1U));
    __Vdfg_Regularize_1938 = ((vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_3__DOT__u_crc_parallel_crcw__DOT__reg_crc_state 
                               << 1U) | (1U & (vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_3__DOT__u_crc_parallel_crcw__DOT__reg_data 
                                               >> (0x0000001fU 
                                                   & ((7U 
                                                       & (IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_3__DOT__u_crc_parallel_crcw__DOT__reg_chunk_idx)) 
                                                      + 
                                                      (0x00000018U 
                                                       & (((IData)(3U) 
                                                           - 
                                                           ((IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_3__DOT__u_crc_parallel_crcw__DOT__reg_chunk_idx) 
                                                            >> 3U)) 
                                                          << 3U)))))));
    __Vdfg_Regularize_2033 = ((vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_3__DOT__u_crc_parallel_crcw__DOT__reg_crc_state 
                               << 1U) | (1U & (vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_3__DOT__u_crc_parallel_crcw__DOT__reg_data 
                                               >> (0x0000001fU 
                                                   & ((7U 
                                                       & (IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_3__DOT__u_crc_parallel_crcw__DOT__reg_chunk_idx)) 
                                                      + 
                                                      (0x00000018U 
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
    __Vdfg_Regularize_1971 = ((__Vdfg_Regularize_1970 
                               >> 0x0000001fU) ? (1U 
                                                  | (0xfffffffeU 
                                                     & (0x04c11db6U 
                                                        ^ 
                                                        (__Vdfg_Regularize_1970 
                                                         << 1U))))
                               : (__Vdfg_Regularize_1970 
                                  << 1U));
    __Vdfg_Regularize_2066 = ((__Vdfg_Regularize_2065 
                               >> 0x0000001fU) ? (1U 
                                                  | (0xfffffffeU 
                                                     & (0x04c11db6U 
                                                        ^ 
                                                        (__Vdfg_Regularize_2065 
                                                         << 1U))))
                               : (__Vdfg_Regularize_2065 
                                  << 1U));
    __Vdfg_Regularize_1812 = (((IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_3__DOT__u_crc_parallel_crcw__DOT__reg_chunk_idx) 
                               < (IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_3__DOT__u_crc_parallel_crcw__DOT__w_valid_bit_cnt))
                               ? ((vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_3__DOT__u_crc_parallel_crcw__DOT__reg_crc_state 
                                   >> 0x0000001fU) ? 
                                  (0x04c11db7U ^ __Vdfg_Regularize_1938)
                                   : __Vdfg_Regularize_1938)
                               : vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_3__DOT__u_crc_parallel_crcw__DOT__reg_crc_state);
    __Vdfg_Regularize_1875 = (((IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_3__DOT__u_crc_parallel_crcw__DOT__reg_chunk_idx) 
                               < (IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_3__DOT__u_crc_parallel_crcw__DOT__w_valid_bit_cnt))
                               ? ((vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_3__DOT__u_crc_parallel_crcw__DOT__reg_crc_state 
                                   >> 0x0000001fU) ? 
                                  (0x04c11db7U ^ __Vdfg_Regularize_2033)
                                   : __Vdfg_Regularize_2033)
                               : vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_3__DOT__u_crc_parallel_crcw__DOT__reg_crc_state);
    __Vdfg_Regularize_1972 = ((__Vdfg_Regularize_1971 
                               >> 0x0000001fU) ? (1U 
                                                  | (0xfffffffeU 
                                                     & (0x04c11db6U 
                                                        ^ 
                                                        (__Vdfg_Regularize_1971 
                                                         << 1U))))
                               : (__Vdfg_Regularize_1971 
                                  << 1U));
    __Vdfg_Regularize_2067 = ((__Vdfg_Regularize_2066 
                               >> 0x0000001fU) ? (1U 
                                                  | (0xfffffffeU 
                                                     & (0x04c11db6U 
                                                        ^ 
                                                        (__Vdfg_Regularize_2066 
                                                         << 1U))))
                               : (__Vdfg_Regularize_2066 
                                  << 1U));
    __Vdfg_Regularize_1939 = ((__Vdfg_Regularize_1812 
                               << 1U) | (1U & (vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_3__DOT__u_crc_parallel_crcw__DOT__reg_data 
                                               >> (0x0000001fU 
                                                   & ((7U 
                                                       & ((IData)(1U) 
                                                          + (IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_3__DOT__u_crc_parallel_crcw__DOT__reg_chunk_idx))) 
                                                      + 
                                                      (0x00000018U 
                                                       & (((IData)(3U) 
                                                           - 
                                                           (3U 
                                                            & (((IData)(1U) 
                                                                + (IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_3__DOT__u_crc_parallel_crcw__DOT__reg_chunk_idx)) 
                                                               >> 3U))) 
                                                          << 3U)))))));
    __Vdfg_Regularize_2034 = ((__Vdfg_Regularize_1875 
                               << 1U) | (1U & (vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_3__DOT__u_crc_parallel_crcw__DOT__reg_data 
                                               >> (0x0000001fU 
                                                   & ((7U 
                                                       & ((IData)(1U) 
                                                          + (IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_3__DOT__u_crc_parallel_crcw__DOT__reg_chunk_idx))) 
                                                      + 
                                                      (0x00000018U 
                                                       & (((IData)(3U) 
                                                           - 
                                                           (3U 
                                                            & (((IData)(1U) 
                                                                + (IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_3__DOT__u_crc_parallel_crcw__DOT__reg_chunk_idx)) 
                                                               >> 3U))) 
                                                          << 3U)))))));
    __Vdfg_Regularize_1973 = ((__Vdfg_Regularize_1972 
                               >> 0x0000001fU) ? (1U 
                                                  | (0xfffffffeU 
                                                     & (0x04c11db6U 
                                                        ^ 
                                                        (__Vdfg_Regularize_1972 
                                                         << 1U))))
                               : (__Vdfg_Regularize_1972 
                                  << 1U));
    __Vdfg_Regularize_2068 = ((__Vdfg_Regularize_2067 
                               >> 0x0000001fU) ? (1U 
                                                  | (0xfffffffeU 
                                                     & (0x04c11db6U 
                                                        ^ 
                                                        (__Vdfg_Regularize_2067 
                                                         << 1U))))
                               : (__Vdfg_Regularize_2067 
                                  << 1U));
    __Vdfg_Regularize_1814 = (((0x0000003fU & ((IData)(1U) 
                                               + (IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_3__DOT__u_crc_parallel_crcw__DOT__reg_chunk_idx))) 
                               < (IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_3__DOT__u_crc_parallel_crcw__DOT__w_valid_bit_cnt))
                               ? ((__Vdfg_Regularize_1812 
                                   >> 0x0000001fU) ? 
                                  (0x04c11db7U ^ __Vdfg_Regularize_1939)
                                   : __Vdfg_Regularize_1939)
                               : __Vdfg_Regularize_1812);
    __Vdfg_Regularize_1877 = (((0x0000003fU & ((IData)(1U) 
                                               + (IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_3__DOT__u_crc_parallel_crcw__DOT__reg_chunk_idx))) 
                               < (IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_3__DOT__u_crc_parallel_crcw__DOT__w_valid_bit_cnt))
                               ? ((__Vdfg_Regularize_1875 
                                   >> 0x0000001fU) ? 
                                  (0x04c11db7U ^ __Vdfg_Regularize_2034)
                                   : __Vdfg_Regularize_2034)
                               : __Vdfg_Regularize_1875);
    __Vdfg_Regularize_1974 = ((__Vdfg_Regularize_1973 
                               >> 0x0000001fU) ? (1U 
                                                  | (0xfffffffeU 
                                                     & (0x04c11db6U 
                                                        ^ 
                                                        (__Vdfg_Regularize_1973 
                                                         << 1U))))
                               : (__Vdfg_Regularize_1973 
                                  << 1U));
    __Vdfg_Regularize_2069 = ((__Vdfg_Regularize_2068 
                               >> 0x0000001fU) ? (1U 
                                                  | (0xfffffffeU 
                                                     & (0x04c11db6U 
                                                        ^ 
                                                        (__Vdfg_Regularize_2068 
                                                         << 1U))))
                               : (__Vdfg_Regularize_2068 
                                  << 1U));
    __Vdfg_Regularize_1940 = ((__Vdfg_Regularize_1814 
                               << 1U) | (1U & (vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_3__DOT__u_crc_parallel_crcw__DOT__reg_data 
                                               >> (0x0000001fU 
                                                   & ((7U 
                                                       & ((IData)(2U) 
                                                          + (IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_3__DOT__u_crc_parallel_crcw__DOT__reg_chunk_idx))) 
                                                      + 
                                                      (0x00000018U 
                                                       & (((IData)(3U) 
                                                           - 
                                                           (3U 
                                                            & (((IData)(2U) 
                                                                + (IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_3__DOT__u_crc_parallel_crcw__DOT__reg_chunk_idx)) 
                                                               >> 3U))) 
                                                          << 3U)))))));
    __Vdfg_Regularize_2035 = ((__Vdfg_Regularize_1877 
                               << 1U) | (1U & (vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_3__DOT__u_crc_parallel_crcw__DOT__reg_data 
                                               >> (0x0000001fU 
                                                   & ((7U 
                                                       & ((IData)(2U) 
                                                          + (IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_3__DOT__u_crc_parallel_crcw__DOT__reg_chunk_idx))) 
                                                      + 
                                                      (0x00000018U 
                                                       & (((IData)(3U) 
                                                           - 
                                                           (3U 
                                                            & (((IData)(2U) 
                                                                + (IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_3__DOT__u_crc_parallel_crcw__DOT__reg_chunk_idx)) 
                                                               >> 3U))) 
                                                          << 3U)))))));
    __Vdfg_Regularize_1975 = ((__Vdfg_Regularize_1974 
                               >> 0x0000001fU) ? (1U 
                                                  | (0xfffffffeU 
                                                     & (0x04c11db6U 
                                                        ^ 
                                                        (__Vdfg_Regularize_1974 
                                                         << 1U))))
                               : (__Vdfg_Regularize_1974 
                                  << 1U));
    __Vdfg_Regularize_2070 = ((__Vdfg_Regularize_2069 
                               >> 0x0000001fU) ? (1U 
                                                  | (0xfffffffeU 
                                                     & (0x04c11db6U 
                                                        ^ 
                                                        (__Vdfg_Regularize_2069 
                                                         << 1U))))
                               : (__Vdfg_Regularize_2069 
                                  << 1U));
    __Vdfg_Regularize_1816 = (((0x0000003fU & ((IData)(2U) 
                                               + (IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_3__DOT__u_crc_parallel_crcw__DOT__reg_chunk_idx))) 
                               < (IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_3__DOT__u_crc_parallel_crcw__DOT__w_valid_bit_cnt))
                               ? ((__Vdfg_Regularize_1814 
                                   >> 0x0000001fU) ? 
                                  (0x04c11db7U ^ __Vdfg_Regularize_1940)
                                   : __Vdfg_Regularize_1940)
                               : __Vdfg_Regularize_1814);
    __Vdfg_Regularize_1879 = (((0x0000003fU & ((IData)(2U) 
                                               + (IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_3__DOT__u_crc_parallel_crcw__DOT__reg_chunk_idx))) 
                               < (IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_3__DOT__u_crc_parallel_crcw__DOT__w_valid_bit_cnt))
                               ? ((__Vdfg_Regularize_1877 
                                   >> 0x0000001fU) ? 
                                  (0x04c11db7U ^ __Vdfg_Regularize_2035)
                                   : __Vdfg_Regularize_2035)
                               : __Vdfg_Regularize_1877);
    __Vdfg_Regularize_1976 = ((__Vdfg_Regularize_1975 
                               >> 0x0000001fU) ? (1U 
                                                  | (0xfffffffeU 
                                                     & (0x04c11db6U 
                                                        ^ 
                                                        (__Vdfg_Regularize_1975 
                                                         << 1U))))
                               : (__Vdfg_Regularize_1975 
                                  << 1U));
    __Vdfg_Regularize_2071 = ((__Vdfg_Regularize_2070 
                               >> 0x0000001fU) ? (1U 
                                                  | (0xfffffffeU 
                                                     & (0x04c11db6U 
                                                        ^ 
                                                        (__Vdfg_Regularize_2070 
                                                         << 1U))))
                               : (__Vdfg_Regularize_2070 
                                  << 1U));
    __Vdfg_Regularize_1941 = ((__Vdfg_Regularize_1816 
                               << 1U) | (1U & (vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_3__DOT__u_crc_parallel_crcw__DOT__reg_data 
                                               >> (0x0000001fU 
                                                   & ((7U 
                                                       & ((IData)(3U) 
                                                          + (IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_3__DOT__u_crc_parallel_crcw__DOT__reg_chunk_idx))) 
                                                      + 
                                                      (0x00000018U 
                                                       & (((IData)(3U) 
                                                           - 
                                                           (3U 
                                                            & (((IData)(3U) 
                                                                + (IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_3__DOT__u_crc_parallel_crcw__DOT__reg_chunk_idx)) 
                                                               >> 3U))) 
                                                          << 3U)))))));
    __Vdfg_Regularize_2036 = ((__Vdfg_Regularize_1879 
                               << 1U) | (1U & (vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_3__DOT__u_crc_parallel_crcw__DOT__reg_data 
                                               >> (0x0000001fU 
                                                   & ((7U 
                                                       & ((IData)(3U) 
                                                          + (IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_3__DOT__u_crc_parallel_crcw__DOT__reg_chunk_idx))) 
                                                      + 
                                                      (0x00000018U 
                                                       & (((IData)(3U) 
                                                           - 
                                                           (3U 
                                                            & (((IData)(3U) 
                                                                + (IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_3__DOT__u_crc_parallel_crcw__DOT__reg_chunk_idx)) 
                                                               >> 3U))) 
                                                          << 3U)))))));
    __Vdfg_Regularize_1977 = ((__Vdfg_Regularize_1976 
                               >> 0x0000001fU) ? (1U 
                                                  | (0xfffffffeU 
                                                     & (0x04c11db6U 
                                                        ^ 
                                                        (__Vdfg_Regularize_1976 
                                                         << 1U))))
                               : (__Vdfg_Regularize_1976 
                                  << 1U));
    __Vdfg_Regularize_2072 = ((__Vdfg_Regularize_2071 
                               >> 0x0000001fU) ? (1U 
                                                  | (0xfffffffeU 
                                                     & (0x04c11db6U 
                                                        ^ 
                                                        (__Vdfg_Regularize_2071 
                                                         << 1U))))
                               : (__Vdfg_Regularize_2071 
                                  << 1U));
    __Vdfg_Regularize_1818 = (((0x0000003fU & ((IData)(3U) 
                                               + (IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_3__DOT__u_crc_parallel_crcw__DOT__reg_chunk_idx))) 
                               < (IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_3__DOT__u_crc_parallel_crcw__DOT__w_valid_bit_cnt))
                               ? ((__Vdfg_Regularize_1816 
                                   >> 0x0000001fU) ? 
                                  (0x04c11db7U ^ __Vdfg_Regularize_1941)
                                   : __Vdfg_Regularize_1941)
                               : __Vdfg_Regularize_1816);
    __Vdfg_Regularize_1881 = (((0x0000003fU & ((IData)(3U) 
                                               + (IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_3__DOT__u_crc_parallel_crcw__DOT__reg_chunk_idx))) 
                               < (IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_3__DOT__u_crc_parallel_crcw__DOT__w_valid_bit_cnt))
                               ? ((__Vdfg_Regularize_1879 
                                   >> 0x0000001fU) ? 
                                  (0x04c11db7U ^ __Vdfg_Regularize_2036)
                                   : __Vdfg_Regularize_2036)
                               : __Vdfg_Regularize_1879);
    __Vdfg_Regularize_1978 = ((__Vdfg_Regularize_1977 
                               >> 0x0000001fU) ? (1U 
                                                  | (0xfffffffeU 
                                                     & (0x04c11db6U 
                                                        ^ 
                                                        (__Vdfg_Regularize_1977 
                                                         << 1U))))
                               : (__Vdfg_Regularize_1977 
                                  << 1U));
    __Vdfg_Regularize_2073 = ((__Vdfg_Regularize_2072 
                               >> 0x0000001fU) ? (1U 
                                                  | (0xfffffffeU 
                                                     & (0x04c11db6U 
                                                        ^ 
                                                        (__Vdfg_Regularize_2072 
                                                         << 1U))))
                               : (__Vdfg_Regularize_2072 
                                  << 1U));
    __Vdfg_Regularize_1942 = ((__Vdfg_Regularize_1818 
                               << 1U) | (1U & (vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_3__DOT__u_crc_parallel_crcw__DOT__reg_data 
                                               >> (0x0000001fU 
                                                   & ((7U 
                                                       & ((IData)(4U) 
                                                          + (IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_3__DOT__u_crc_parallel_crcw__DOT__reg_chunk_idx))) 
                                                      + 
                                                      (0x00000018U 
                                                       & (((IData)(3U) 
                                                           - 
                                                           (3U 
                                                            & (((IData)(4U) 
                                                                + (IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_3__DOT__u_crc_parallel_crcw__DOT__reg_chunk_idx)) 
                                                               >> 3U))) 
                                                          << 3U)))))));
    __Vdfg_Regularize_2037 = ((__Vdfg_Regularize_1881 
                               << 1U) | (1U & (vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_3__DOT__u_crc_parallel_crcw__DOT__reg_data 
                                               >> (0x0000001fU 
                                                   & ((7U 
                                                       & ((IData)(4U) 
                                                          + (IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_3__DOT__u_crc_parallel_crcw__DOT__reg_chunk_idx))) 
                                                      + 
                                                      (0x00000018U 
                                                       & (((IData)(3U) 
                                                           - 
                                                           (3U 
                                                            & (((IData)(4U) 
                                                                + (IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_3__DOT__u_crc_parallel_crcw__DOT__reg_chunk_idx)) 
                                                               >> 3U))) 
                                                          << 3U)))))));
    __Vdfg_Regularize_1979 = ((__Vdfg_Regularize_1978 
                               >> 0x0000001fU) ? (1U 
                                                  | (0xfffffffeU 
                                                     & (0x04c11db6U 
                                                        ^ 
                                                        (__Vdfg_Regularize_1978 
                                                         << 1U))))
                               : (__Vdfg_Regularize_1978 
                                  << 1U));
    __Vdfg_Regularize_2074 = ((__Vdfg_Regularize_2073 
                               >> 0x0000001fU) ? (1U 
                                                  | (0xfffffffeU 
                                                     & (0x04c11db6U 
                                                        ^ 
                                                        (__Vdfg_Regularize_2073 
                                                         << 1U))))
                               : (__Vdfg_Regularize_2073 
                                  << 1U));
    __Vdfg_Regularize_1820 = (((0x0000003fU & ((IData)(4U) 
                                               + (IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_3__DOT__u_crc_parallel_crcw__DOT__reg_chunk_idx))) 
                               < (IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_3__DOT__u_crc_parallel_crcw__DOT__w_valid_bit_cnt))
                               ? ((__Vdfg_Regularize_1818 
                                   >> 0x0000001fU) ? 
                                  (0x04c11db7U ^ __Vdfg_Regularize_1942)
                                   : __Vdfg_Regularize_1942)
                               : __Vdfg_Regularize_1818);
    __Vdfg_Regularize_1883 = (((0x0000003fU & ((IData)(4U) 
                                               + (IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_3__DOT__u_crc_parallel_crcw__DOT__reg_chunk_idx))) 
                               < (IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_3__DOT__u_crc_parallel_crcw__DOT__w_valid_bit_cnt))
                               ? ((__Vdfg_Regularize_1881 
                                   >> 0x0000001fU) ? 
                                  (0x04c11db7U ^ __Vdfg_Regularize_2037)
                                   : __Vdfg_Regularize_2037)
                               : __Vdfg_Regularize_1881);
    __Vdfg_Regularize_1980 = ((__Vdfg_Regularize_1979 
                               >> 0x0000001fU) ? (1U 
                                                  | (0xfffffffeU 
                                                     & (0x04c11db6U 
                                                        ^ 
                                                        (__Vdfg_Regularize_1979 
                                                         << 1U))))
                               : (__Vdfg_Regularize_1979 
                                  << 1U));
    __Vdfg_Regularize_2075 = ((__Vdfg_Regularize_2074 
                               >> 0x0000001fU) ? (1U 
                                                  | (0xfffffffeU 
                                                     & (0x04c11db6U 
                                                        ^ 
                                                        (__Vdfg_Regularize_2074 
                                                         << 1U))))
                               : (__Vdfg_Regularize_2074 
                                  << 1U));
    __Vdfg_Regularize_1943 = ((__Vdfg_Regularize_1820 
                               << 1U) | (1U & (vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_3__DOT__u_crc_parallel_crcw__DOT__reg_data 
                                               >> (0x0000001fU 
                                                   & ((7U 
                                                       & ((IData)(5U) 
                                                          + (IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_3__DOT__u_crc_parallel_crcw__DOT__reg_chunk_idx))) 
                                                      + 
                                                      (0x00000018U 
                                                       & (((IData)(3U) 
                                                           - 
                                                           (3U 
                                                            & (((IData)(5U) 
                                                                + (IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_3__DOT__u_crc_parallel_crcw__DOT__reg_chunk_idx)) 
                                                               >> 3U))) 
                                                          << 3U)))))));
    __Vdfg_Regularize_2038 = ((__Vdfg_Regularize_1883 
                               << 1U) | (1U & (vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_3__DOT__u_crc_parallel_crcw__DOT__reg_data 
                                               >> (0x0000001fU 
                                                   & ((7U 
                                                       & ((IData)(5U) 
                                                          + (IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_3__DOT__u_crc_parallel_crcw__DOT__reg_chunk_idx))) 
                                                      + 
                                                      (0x00000018U 
                                                       & (((IData)(3U) 
                                                           - 
                                                           (3U 
                                                            & (((IData)(5U) 
                                                                + (IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_3__DOT__u_crc_parallel_crcw__DOT__reg_chunk_idx)) 
                                                               >> 3U))) 
                                                          << 3U)))))));
    __Vdfg_Regularize_1981 = ((__Vdfg_Regularize_1980 
                               >> 0x0000001fU) ? (1U 
                                                  | (0xfffffffeU 
                                                     & (0x04c11db6U 
                                                        ^ 
                                                        (__Vdfg_Regularize_1980 
                                                         << 1U))))
                               : (__Vdfg_Regularize_1980 
                                  << 1U));
    __Vdfg_Regularize_2076 = ((__Vdfg_Regularize_2075 
                               >> 0x0000001fU) ? (1U 
                                                  | (0xfffffffeU 
                                                     & (0x04c11db6U 
                                                        ^ 
                                                        (__Vdfg_Regularize_2075 
                                                         << 1U))))
                               : (__Vdfg_Regularize_2075 
                                  << 1U));
    __Vdfg_Regularize_1822 = (((0x0000003fU & ((IData)(5U) 
                                               + (IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_3__DOT__u_crc_parallel_crcw__DOT__reg_chunk_idx))) 
                               < (IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_3__DOT__u_crc_parallel_crcw__DOT__w_valid_bit_cnt))
                               ? ((__Vdfg_Regularize_1820 
                                   >> 0x0000001fU) ? 
                                  (0x04c11db7U ^ __Vdfg_Regularize_1943)
                                   : __Vdfg_Regularize_1943)
                               : __Vdfg_Regularize_1820);
    __Vdfg_Regularize_1885 = (((0x0000003fU & ((IData)(5U) 
                                               + (IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_3__DOT__u_crc_parallel_crcw__DOT__reg_chunk_idx))) 
                               < (IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_3__DOT__u_crc_parallel_crcw__DOT__w_valid_bit_cnt))
                               ? ((__Vdfg_Regularize_1883 
                                   >> 0x0000001fU) ? 
                                  (0x04c11db7U ^ __Vdfg_Regularize_2038)
                                   : __Vdfg_Regularize_2038)
                               : __Vdfg_Regularize_1883);
    __Vdfg_Regularize_1982 = ((__Vdfg_Regularize_1981 
                               >> 0x0000001fU) ? (1U 
                                                  | (0xfffffffeU 
                                                     & (0x04c11db6U 
                                                        ^ 
                                                        (__Vdfg_Regularize_1981 
                                                         << 1U))))
                               : (__Vdfg_Regularize_1981 
                                  << 1U));
    __Vdfg_Regularize_2077 = ((__Vdfg_Regularize_2076 
                               >> 0x0000001fU) ? (1U 
                                                  | (0xfffffffeU 
                                                     & (0x04c11db6U 
                                                        ^ 
                                                        (__Vdfg_Regularize_2076 
                                                         << 1U))))
                               : (__Vdfg_Regularize_2076 
                                  << 1U));
    __Vdfg_Regularize_1944 = ((__Vdfg_Regularize_1822 
                               << 1U) | (1U & (vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_3__DOT__u_crc_parallel_crcw__DOT__reg_data 
                                               >> (0x0000001fU 
                                                   & ((7U 
                                                       & ((IData)(6U) 
                                                          + (IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_3__DOT__u_crc_parallel_crcw__DOT__reg_chunk_idx))) 
                                                      + 
                                                      (0x00000018U 
                                                       & (((IData)(3U) 
                                                           - 
                                                           (3U 
                                                            & (((IData)(6U) 
                                                                + (IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_3__DOT__u_crc_parallel_crcw__DOT__reg_chunk_idx)) 
                                                               >> 3U))) 
                                                          << 3U)))))));
    __Vdfg_Regularize_2039 = ((__Vdfg_Regularize_1885 
                               << 1U) | (1U & (vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_3__DOT__u_crc_parallel_crcw__DOT__reg_data 
                                               >> (0x0000001fU 
                                                   & ((7U 
                                                       & ((IData)(6U) 
                                                          + (IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_3__DOT__u_crc_parallel_crcw__DOT__reg_chunk_idx))) 
                                                      + 
                                                      (0x00000018U 
                                                       & (((IData)(3U) 
                                                           - 
                                                           (3U 
                                                            & (((IData)(6U) 
                                                                + (IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_3__DOT__u_crc_parallel_crcw__DOT__reg_chunk_idx)) 
                                                               >> 3U))) 
                                                          << 3U)))))));
    __Vdfg_Regularize_1983 = ((__Vdfg_Regularize_1982 
                               >> 0x0000001fU) ? (1U 
                                                  | (0xfffffffeU 
                                                     & (0x04c11db6U 
                                                        ^ 
                                                        (__Vdfg_Regularize_1982 
                                                         << 1U))))
                               : (__Vdfg_Regularize_1982 
                                  << 1U));
    __Vdfg_Regularize_2078 = ((__Vdfg_Regularize_2077 
                               >> 0x0000001fU) ? (1U 
                                                  | (0xfffffffeU 
                                                     & (0x04c11db6U 
                                                        ^ 
                                                        (__Vdfg_Regularize_2077 
                                                         << 1U))))
                               : (__Vdfg_Regularize_2077 
                                  << 1U));
    __Vdfg_Regularize_1824 = (((0x0000003fU & ((IData)(6U) 
                                               + (IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_3__DOT__u_crc_parallel_crcw__DOT__reg_chunk_idx))) 
                               < (IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_3__DOT__u_crc_parallel_crcw__DOT__w_valid_bit_cnt))
                               ? ((__Vdfg_Regularize_1822 
                                   >> 0x0000001fU) ? 
                                  (0x04c11db7U ^ __Vdfg_Regularize_1944)
                                   : __Vdfg_Regularize_1944)
                               : __Vdfg_Regularize_1822);
    __Vdfg_Regularize_1887 = (((0x0000003fU & ((IData)(6U) 
                                               + (IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_3__DOT__u_crc_parallel_crcw__DOT__reg_chunk_idx))) 
                               < (IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_3__DOT__u_crc_parallel_crcw__DOT__w_valid_bit_cnt))
                               ? ((__Vdfg_Regularize_1885 
                                   >> 0x0000001fU) ? 
                                  (0x04c11db7U ^ __Vdfg_Regularize_2039)
                                   : __Vdfg_Regularize_2039)
                               : __Vdfg_Regularize_1885);
    __Vdfg_Regularize_1984 = ((__Vdfg_Regularize_1983 
                               >> 0x0000001fU) ? (1U 
                                                  | (0xfffffffeU 
                                                     & (0x04c11db6U 
                                                        ^ 
                                                        (__Vdfg_Regularize_1983 
                                                         << 1U))))
                               : (__Vdfg_Regularize_1983 
                                  << 1U));
    __Vdfg_Regularize_2079 = ((__Vdfg_Regularize_2078 
                               >> 0x0000001fU) ? (1U 
                                                  | (0xfffffffeU 
                                                     & (0x04c11db6U 
                                                        ^ 
                                                        (__Vdfg_Regularize_2078 
                                                         << 1U))))
                               : (__Vdfg_Regularize_2078 
                                  << 1U));
    __Vdfg_Regularize_1945 = ((__Vdfg_Regularize_1824 
                               << 1U) | (1U & (vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_3__DOT__u_crc_parallel_crcw__DOT__reg_data 
                                               >> (0x0000001fU 
                                                   & ((7U 
                                                       & ((IData)(7U) 
                                                          + (IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_3__DOT__u_crc_parallel_crcw__DOT__reg_chunk_idx))) 
                                                      + 
                                                      (0x00000018U 
                                                       & (((IData)(3U) 
                                                           - 
                                                           (3U 
                                                            & (((IData)(7U) 
                                                                + (IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_3__DOT__u_crc_parallel_crcw__DOT__reg_chunk_idx)) 
                                                               >> 3U))) 
                                                          << 3U)))))));
    __Vdfg_Regularize_2040 = ((__Vdfg_Regularize_1887 
                               << 1U) | (1U & (vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_3__DOT__u_crc_parallel_crcw__DOT__reg_data 
                                               >> (0x0000001fU 
                                                   & ((7U 
                                                       & ((IData)(7U) 
                                                          + (IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_3__DOT__u_crc_parallel_crcw__DOT__reg_chunk_idx))) 
                                                      + 
                                                      (0x00000018U 
                                                       & (((IData)(3U) 
                                                           - 
                                                           (3U 
                                                            & (((IData)(7U) 
                                                                + (IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_3__DOT__u_crc_parallel_crcw__DOT__reg_chunk_idx)) 
                                                               >> 3U))) 
                                                          << 3U)))))));
    __Vdfg_Regularize_1985 = ((__Vdfg_Regularize_1984 
                               >> 0x0000001fU) ? (1U 
                                                  | (0xfffffffeU 
                                                     & (0x04c11db6U 
                                                        ^ 
                                                        (__Vdfg_Regularize_1984 
                                                         << 1U))))
                               : (__Vdfg_Regularize_1984 
                                  << 1U));
    __Vdfg_Regularize_2080 = ((__Vdfg_Regularize_2079 
                               >> 0x0000001fU) ? (1U 
                                                  | (0xfffffffeU 
                                                     & (0x04c11db6U 
                                                        ^ 
                                                        (__Vdfg_Regularize_2079 
                                                         << 1U))))
                               : (__Vdfg_Regularize_2079 
                                  << 1U));
    __Vdfg_Regularize_1826 = (((0x0000003fU & ((IData)(7U) 
                                               + (IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_3__DOT__u_crc_parallel_crcw__DOT__reg_chunk_idx))) 
                               < (IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_3__DOT__u_crc_parallel_crcw__DOT__w_valid_bit_cnt))
                               ? ((__Vdfg_Regularize_1824 
                                   >> 0x0000001fU) ? 
                                  (0x04c11db7U ^ __Vdfg_Regularize_1945)
                                   : __Vdfg_Regularize_1945)
                               : __Vdfg_Regularize_1824);
    __Vdfg_Regularize_1889 = (((0x0000003fU & ((IData)(7U) 
                                               + (IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_3__DOT__u_crc_parallel_crcw__DOT__reg_chunk_idx))) 
                               < (IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_3__DOT__u_crc_parallel_crcw__DOT__w_valid_bit_cnt))
                               ? ((__Vdfg_Regularize_1887 
                                   >> 0x0000001fU) ? 
                                  (0x04c11db7U ^ __Vdfg_Regularize_2040)
                                   : __Vdfg_Regularize_2040)
                               : __Vdfg_Regularize_1887);
    __Vdfg_Regularize_1986 = ((__Vdfg_Regularize_1985 
                               >> 0x0000001fU) ? (1U 
                                                  | (0xfffffffeU 
                                                     & (0x04c11db6U 
                                                        ^ 
                                                        (__Vdfg_Regularize_1985 
                                                         << 1U))))
                               : (__Vdfg_Regularize_1985 
                                  << 1U));
    __Vdfg_Regularize_2081 = ((__Vdfg_Regularize_2080 
                               >> 0x0000001fU) ? (1U 
                                                  | (0xfffffffeU 
                                                     & (0x04c11db6U 
                                                        ^ 
                                                        (__Vdfg_Regularize_2080 
                                                         << 1U))))
                               : (__Vdfg_Regularize_2080 
                                  << 1U));
    __Vdfg_Regularize_1946 = ((__Vdfg_Regularize_1826 
                               << 1U) | (1U & (vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_3__DOT__u_crc_parallel_crcw__DOT__reg_data 
                                               >> (0x0000001fU 
                                                   & ((7U 
                                                       & ((IData)(8U) 
                                                          + (IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_3__DOT__u_crc_parallel_crcw__DOT__reg_chunk_idx))) 
                                                      + 
                                                      (0x00000018U 
                                                       & (((IData)(3U) 
                                                           - 
                                                           (3U 
                                                            & (((IData)(8U) 
                                                                + (IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_3__DOT__u_crc_parallel_crcw__DOT__reg_chunk_idx)) 
                                                               >> 3U))) 
                                                          << 3U)))))));
    __Vdfg_Regularize_2041 = ((__Vdfg_Regularize_1889 
                               << 1U) | (1U & (vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_3__DOT__u_crc_parallel_crcw__DOT__reg_data 
                                               >> (0x0000001fU 
                                                   & ((7U 
                                                       & ((IData)(8U) 
                                                          + (IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_3__DOT__u_crc_parallel_crcw__DOT__reg_chunk_idx))) 
                                                      + 
                                                      (0x00000018U 
                                                       & (((IData)(3U) 
                                                           - 
                                                           (3U 
                                                            & (((IData)(8U) 
                                                                + (IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_3__DOT__u_crc_parallel_crcw__DOT__reg_chunk_idx)) 
                                                               >> 3U))) 
                                                          << 3U)))))));
    __Vdfg_Regularize_1987 = ((__Vdfg_Regularize_1986 
                               >> 0x0000001fU) ? (1U 
                                                  | (0xfffffffeU 
                                                     & (0x04c11db6U 
                                                        ^ 
                                                        (__Vdfg_Regularize_1986 
                                                         << 1U))))
                               : (__Vdfg_Regularize_1986 
                                  << 1U));
    __Vdfg_Regularize_2082 = ((__Vdfg_Regularize_2081 
                               >> 0x0000001fU) ? (1U 
                                                  | (0xfffffffeU 
                                                     & (0x04c11db6U 
                                                        ^ 
                                                        (__Vdfg_Regularize_2081 
                                                         << 1U))))
                               : (__Vdfg_Regularize_2081 
                                  << 1U));
    __Vdfg_Regularize_1828 = (((0x0000003fU & ((IData)(8U) 
                                               + (IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_3__DOT__u_crc_parallel_crcw__DOT__reg_chunk_idx))) 
                               < (IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_3__DOT__u_crc_parallel_crcw__DOT__w_valid_bit_cnt))
                               ? ((__Vdfg_Regularize_1826 
                                   >> 0x0000001fU) ? 
                                  (0x04c11db7U ^ __Vdfg_Regularize_1946)
                                   : __Vdfg_Regularize_1946)
                               : __Vdfg_Regularize_1826);
    __Vdfg_Regularize_1891 = (((0x0000003fU & ((IData)(8U) 
                                               + (IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_3__DOT__u_crc_parallel_crcw__DOT__reg_chunk_idx))) 
                               < (IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_3__DOT__u_crc_parallel_crcw__DOT__w_valid_bit_cnt))
                               ? ((__Vdfg_Regularize_1889 
                                   >> 0x0000001fU) ? 
                                  (0x04c11db7U ^ __Vdfg_Regularize_2041)
                                   : __Vdfg_Regularize_2041)
                               : __Vdfg_Regularize_1889);
    __Vdfg_Regularize_1988 = ((__Vdfg_Regularize_1987 
                               >> 0x0000001fU) ? (1U 
                                                  | (0xfffffffeU 
                                                     & (0x04c11db6U 
                                                        ^ 
                                                        (__Vdfg_Regularize_1987 
                                                         << 1U))))
                               : (__Vdfg_Regularize_1987 
                                  << 1U));
    __Vdfg_Regularize_2083 = ((__Vdfg_Regularize_2082 
                               >> 0x0000001fU) ? (1U 
                                                  | (0xfffffffeU 
                                                     & (0x04c11db6U 
                                                        ^ 
                                                        (__Vdfg_Regularize_2082 
                                                         << 1U))))
                               : (__Vdfg_Regularize_2082 
                                  << 1U));
    __Vdfg_Regularize_1947 = ((__Vdfg_Regularize_1828 
                               << 1U) | (1U & (vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_3__DOT__u_crc_parallel_crcw__DOT__reg_data 
                                               >> (0x0000001fU 
                                                   & ((7U 
                                                       & ((IData)(9U) 
                                                          + (IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_3__DOT__u_crc_parallel_crcw__DOT__reg_chunk_idx))) 
                                                      + 
                                                      (0x00000018U 
                                                       & (((IData)(3U) 
                                                           - 
                                                           (3U 
                                                            & (((IData)(9U) 
                                                                + (IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_3__DOT__u_crc_parallel_crcw__DOT__reg_chunk_idx)) 
                                                               >> 3U))) 
                                                          << 3U)))))));
    __Vdfg_Regularize_2042 = ((__Vdfg_Regularize_1891 
                               << 1U) | (1U & (vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_3__DOT__u_crc_parallel_crcw__DOT__reg_data 
                                               >> (0x0000001fU 
                                                   & ((7U 
                                                       & ((IData)(9U) 
                                                          + (IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_3__DOT__u_crc_parallel_crcw__DOT__reg_chunk_idx))) 
                                                      + 
                                                      (0x00000018U 
                                                       & (((IData)(3U) 
                                                           - 
                                                           (3U 
                                                            & (((IData)(9U) 
                                                                + (IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_3__DOT__u_crc_parallel_crcw__DOT__reg_chunk_idx)) 
                                                               >> 3U))) 
                                                          << 3U)))))));
    __Vdfg_Regularize_1989 = ((__Vdfg_Regularize_1988 
                               >> 0x0000001fU) ? (1U 
                                                  | (0xfffffffeU 
                                                     & (0x04c11db6U 
                                                        ^ 
                                                        (__Vdfg_Regularize_1988 
                                                         << 1U))))
                               : (__Vdfg_Regularize_1988 
                                  << 1U));
    __Vdfg_Regularize_2084 = ((__Vdfg_Regularize_2083 
                               >> 0x0000001fU) ? (1U 
                                                  | (0xfffffffeU 
                                                     & (0x04c11db6U 
                                                        ^ 
                                                        (__Vdfg_Regularize_2083 
                                                         << 1U))))
                               : (__Vdfg_Regularize_2083 
                                  << 1U));
    __Vdfg_Regularize_1830 = (((0x0000003fU & ((IData)(9U) 
                                               + (IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_3__DOT__u_crc_parallel_crcw__DOT__reg_chunk_idx))) 
                               < (IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_3__DOT__u_crc_parallel_crcw__DOT__w_valid_bit_cnt))
                               ? ((__Vdfg_Regularize_1828 
                                   >> 0x0000001fU) ? 
                                  (0x04c11db7U ^ __Vdfg_Regularize_1947)
                                   : __Vdfg_Regularize_1947)
                               : __Vdfg_Regularize_1828);
    __Vdfg_Regularize_1893 = (((0x0000003fU & ((IData)(9U) 
                                               + (IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_3__DOT__u_crc_parallel_crcw__DOT__reg_chunk_idx))) 
                               < (IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_3__DOT__u_crc_parallel_crcw__DOT__w_valid_bit_cnt))
                               ? ((__Vdfg_Regularize_1891 
                                   >> 0x0000001fU) ? 
                                  (0x04c11db7U ^ __Vdfg_Regularize_2042)
                                   : __Vdfg_Regularize_2042)
                               : __Vdfg_Regularize_1891);
    __Vdfg_Regularize_1990 = ((__Vdfg_Regularize_1989 
                               >> 0x0000001fU) ? (1U 
                                                  | (0xfffffffeU 
                                                     & (0x04c11db6U 
                                                        ^ 
                                                        (__Vdfg_Regularize_1989 
                                                         << 1U))))
                               : (__Vdfg_Regularize_1989 
                                  << 1U));
    __Vdfg_Regularize_2085 = ((__Vdfg_Regularize_2084 
                               >> 0x0000001fU) ? (1U 
                                                  | (0xfffffffeU 
                                                     & (0x04c11db6U 
                                                        ^ 
                                                        (__Vdfg_Regularize_2084 
                                                         << 1U))))
                               : (__Vdfg_Regularize_2084 
                                  << 1U));
    __Vdfg_Regularize_1948 = ((__Vdfg_Regularize_1830 
                               << 1U) | (1U & (vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_3__DOT__u_crc_parallel_crcw__DOT__reg_data 
                                               >> (0x0000001fU 
                                                   & ((7U 
                                                       & ((IData)(0x0aU) 
                                                          + (IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_3__DOT__u_crc_parallel_crcw__DOT__reg_chunk_idx))) 
                                                      + 
                                                      (0x00000018U 
                                                       & (((IData)(3U) 
                                                           - 
                                                           (3U 
                                                            & (((IData)(0x0aU) 
                                                                + (IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_3__DOT__u_crc_parallel_crcw__DOT__reg_chunk_idx)) 
                                                               >> 3U))) 
                                                          << 3U)))))));
    __Vdfg_Regularize_2043 = ((__Vdfg_Regularize_1893 
                               << 1U) | (1U & (vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_3__DOT__u_crc_parallel_crcw__DOT__reg_data 
                                               >> (0x0000001fU 
                                                   & ((7U 
                                                       & ((IData)(0x0aU) 
                                                          + (IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_3__DOT__u_crc_parallel_crcw__DOT__reg_chunk_idx))) 
                                                      + 
                                                      (0x00000018U 
                                                       & (((IData)(3U) 
                                                           - 
                                                           (3U 
                                                            & (((IData)(0x0aU) 
                                                                + (IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_3__DOT__u_crc_parallel_crcw__DOT__reg_chunk_idx)) 
                                                               >> 3U))) 
                                                          << 3U)))))));
    __Vdfg_Regularize_1991 = ((__Vdfg_Regularize_1990 
                               >> 0x0000001fU) ? (1U 
                                                  | (0xfffffffeU 
                                                     & (0x04c11db6U 
                                                        ^ 
                                                        (__Vdfg_Regularize_1990 
                                                         << 1U))))
                               : (__Vdfg_Regularize_1990 
                                  << 1U));
    __Vdfg_Regularize_2086 = ((__Vdfg_Regularize_2085 
                               >> 0x0000001fU) ? (1U 
                                                  | (0xfffffffeU 
                                                     & (0x04c11db6U 
                                                        ^ 
                                                        (__Vdfg_Regularize_2085 
                                                         << 1U))))
                               : (__Vdfg_Regularize_2085 
                                  << 1U));
    __Vdfg_Regularize_1832 = (((0x0000003fU & ((IData)(0x0aU) 
                                               + (IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_3__DOT__u_crc_parallel_crcw__DOT__reg_chunk_idx))) 
                               < (IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_3__DOT__u_crc_parallel_crcw__DOT__w_valid_bit_cnt))
                               ? ((__Vdfg_Regularize_1830 
                                   >> 0x0000001fU) ? 
                                  (0x04c11db7U ^ __Vdfg_Regularize_1948)
                                   : __Vdfg_Regularize_1948)
                               : __Vdfg_Regularize_1830);
    __Vdfg_Regularize_1895 = (((0x0000003fU & ((IData)(0x0aU) 
                                               + (IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_3__DOT__u_crc_parallel_crcw__DOT__reg_chunk_idx))) 
                               < (IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_3__DOT__u_crc_parallel_crcw__DOT__w_valid_bit_cnt))
                               ? ((__Vdfg_Regularize_1893 
                                   >> 0x0000001fU) ? 
                                  (0x04c11db7U ^ __Vdfg_Regularize_2043)
                                   : __Vdfg_Regularize_2043)
                               : __Vdfg_Regularize_1893);
    __Vdfg_Regularize_1992 = ((__Vdfg_Regularize_1991 
                               >> 0x0000001fU) ? (1U 
                                                  | (0xfffffffeU 
                                                     & (0x04c11db6U 
                                                        ^ 
                                                        (__Vdfg_Regularize_1991 
                                                         << 1U))))
                               : (__Vdfg_Regularize_1991 
                                  << 1U));
    __Vdfg_Regularize_2087 = ((__Vdfg_Regularize_2086 
                               >> 0x0000001fU) ? (1U 
                                                  | (0xfffffffeU 
                                                     & (0x04c11db6U 
                                                        ^ 
                                                        (__Vdfg_Regularize_2086 
                                                         << 1U))))
                               : (__Vdfg_Regularize_2086 
                                  << 1U));
    __Vdfg_Regularize_1949 = ((__Vdfg_Regularize_1832 
                               << 1U) | (1U & (vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_3__DOT__u_crc_parallel_crcw__DOT__reg_data 
                                               >> (0x0000001fU 
                                                   & ((7U 
                                                       & ((IData)(0x0bU) 
                                                          + (IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_3__DOT__u_crc_parallel_crcw__DOT__reg_chunk_idx))) 
                                                      + 
                                                      (0x00000018U 
                                                       & (((IData)(3U) 
                                                           - 
                                                           (3U 
                                                            & (((IData)(0x0bU) 
                                                                + (IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_3__DOT__u_crc_parallel_crcw__DOT__reg_chunk_idx)) 
                                                               >> 3U))) 
                                                          << 3U)))))));
    __Vdfg_Regularize_2044 = ((__Vdfg_Regularize_1895 
                               << 1U) | (1U & (vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_3__DOT__u_crc_parallel_crcw__DOT__reg_data 
                                               >> (0x0000001fU 
                                                   & ((7U 
                                                       & ((IData)(0x0bU) 
                                                          + (IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_3__DOT__u_crc_parallel_crcw__DOT__reg_chunk_idx))) 
                                                      + 
                                                      (0x00000018U 
                                                       & (((IData)(3U) 
                                                           - 
                                                           (3U 
                                                            & (((IData)(0x0bU) 
                                                                + (IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_3__DOT__u_crc_parallel_crcw__DOT__reg_chunk_idx)) 
                                                               >> 3U))) 
                                                          << 3U)))))));
    __Vdfg_Regularize_1993 = ((__Vdfg_Regularize_1992 
                               >> 0x0000001fU) ? (1U 
                                                  | (0xfffffffeU 
                                                     & (0x04c11db6U 
                                                        ^ 
                                                        (__Vdfg_Regularize_1992 
                                                         << 1U))))
                               : (__Vdfg_Regularize_1992 
                                  << 1U));
    __Vdfg_Regularize_2088 = ((__Vdfg_Regularize_2087 
                               >> 0x0000001fU) ? (1U 
                                                  | (0xfffffffeU 
                                                     & (0x04c11db6U 
                                                        ^ 
                                                        (__Vdfg_Regularize_2087 
                                                         << 1U))))
                               : (__Vdfg_Regularize_2087 
                                  << 1U));
    __Vdfg_Regularize_1834 = (((0x0000003fU & ((IData)(0x0bU) 
                                               + (IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_3__DOT__u_crc_parallel_crcw__DOT__reg_chunk_idx))) 
                               < (IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_3__DOT__u_crc_parallel_crcw__DOT__w_valid_bit_cnt))
                               ? ((__Vdfg_Regularize_1832 
                                   >> 0x0000001fU) ? 
                                  (0x04c11db7U ^ __Vdfg_Regularize_1949)
                                   : __Vdfg_Regularize_1949)
                               : __Vdfg_Regularize_1832);
    __Vdfg_Regularize_1897 = (((0x0000003fU & ((IData)(0x0bU) 
                                               + (IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_3__DOT__u_crc_parallel_crcw__DOT__reg_chunk_idx))) 
                               < (IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_3__DOT__u_crc_parallel_crcw__DOT__w_valid_bit_cnt))
                               ? ((__Vdfg_Regularize_1895 
                                   >> 0x0000001fU) ? 
                                  (0x04c11db7U ^ __Vdfg_Regularize_2044)
                                   : __Vdfg_Regularize_2044)
                               : __Vdfg_Regularize_1895);
    __Vdfg_Regularize_1994 = ((__Vdfg_Regularize_1993 
                               >> 0x0000001fU) ? (1U 
                                                  | (0xfffffffeU 
                                                     & (0x04c11db6U 
                                                        ^ 
                                                        (__Vdfg_Regularize_1993 
                                                         << 1U))))
                               : (__Vdfg_Regularize_1993 
                                  << 1U));
    __Vdfg_Regularize_2089 = ((__Vdfg_Regularize_2088 
                               >> 0x0000001fU) ? (1U 
                                                  | (0xfffffffeU 
                                                     & (0x04c11db6U 
                                                        ^ 
                                                        (__Vdfg_Regularize_2088 
                                                         << 1U))))
                               : (__Vdfg_Regularize_2088 
                                  << 1U));
    __Vdfg_Regularize_1950 = ((__Vdfg_Regularize_1834 
                               << 1U) | (1U & (vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_3__DOT__u_crc_parallel_crcw__DOT__reg_data 
                                               >> (0x0000001fU 
                                                   & ((7U 
                                                       & ((IData)(0x0cU) 
                                                          + (IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_3__DOT__u_crc_parallel_crcw__DOT__reg_chunk_idx))) 
                                                      + 
                                                      (0x00000018U 
                                                       & (((IData)(3U) 
                                                           - 
                                                           (3U 
                                                            & (((IData)(0x0cU) 
                                                                + (IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_3__DOT__u_crc_parallel_crcw__DOT__reg_chunk_idx)) 
                                                               >> 3U))) 
                                                          << 3U)))))));
    __Vdfg_Regularize_2045 = ((__Vdfg_Regularize_1897 
                               << 1U) | (1U & (vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_3__DOT__u_crc_parallel_crcw__DOT__reg_data 
                                               >> (0x0000001fU 
                                                   & ((7U 
                                                       & ((IData)(0x0cU) 
                                                          + (IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_3__DOT__u_crc_parallel_crcw__DOT__reg_chunk_idx))) 
                                                      + 
                                                      (0x00000018U 
                                                       & (((IData)(3U) 
                                                           - 
                                                           (3U 
                                                            & (((IData)(0x0cU) 
                                                                + (IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_3__DOT__u_crc_parallel_crcw__DOT__reg_chunk_idx)) 
                                                               >> 3U))) 
                                                          << 3U)))))));
    __Vdfg_Regularize_1995 = ((__Vdfg_Regularize_1994 
                               >> 0x0000001fU) ? (1U 
                                                  | (0xfffffffeU 
                                                     & (0x04c11db6U 
                                                        ^ 
                                                        (__Vdfg_Regularize_1994 
                                                         << 1U))))
                               : (__Vdfg_Regularize_1994 
                                  << 1U));
    __Vdfg_Regularize_2090 = ((__Vdfg_Regularize_2089 
                               >> 0x0000001fU) ? (1U 
                                                  | (0xfffffffeU 
                                                     & (0x04c11db6U 
                                                        ^ 
                                                        (__Vdfg_Regularize_2089 
                                                         << 1U))))
                               : (__Vdfg_Regularize_2089 
                                  << 1U));
    __Vdfg_Regularize_1836 = (((0x0000003fU & ((IData)(0x0cU) 
                                               + (IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_3__DOT__u_crc_parallel_crcw__DOT__reg_chunk_idx))) 
                               < (IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_3__DOT__u_crc_parallel_crcw__DOT__w_valid_bit_cnt))
                               ? ((__Vdfg_Regularize_1834 
                                   >> 0x0000001fU) ? 
                                  (0x04c11db7U ^ __Vdfg_Regularize_1950)
                                   : __Vdfg_Regularize_1950)
                               : __Vdfg_Regularize_1834);
    __Vdfg_Regularize_1899 = (((0x0000003fU & ((IData)(0x0cU) 
                                               + (IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_3__DOT__u_crc_parallel_crcw__DOT__reg_chunk_idx))) 
                               < (IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_3__DOT__u_crc_parallel_crcw__DOT__w_valid_bit_cnt))
                               ? ((__Vdfg_Regularize_1897 
                                   >> 0x0000001fU) ? 
                                  (0x04c11db7U ^ __Vdfg_Regularize_2045)
                                   : __Vdfg_Regularize_2045)
                               : __Vdfg_Regularize_1897);
    __Vdfg_Regularize_1996 = ((__Vdfg_Regularize_1995 
                               >> 0x0000001fU) ? (1U 
                                                  | (0xfffffffeU 
                                                     & (0x04c11db6U 
                                                        ^ 
                                                        (__Vdfg_Regularize_1995 
                                                         << 1U))))
                               : (__Vdfg_Regularize_1995 
                                  << 1U));
    __Vdfg_Regularize_2091 = ((__Vdfg_Regularize_2090 
                               >> 0x0000001fU) ? (1U 
                                                  | (0xfffffffeU 
                                                     & (0x04c11db6U 
                                                        ^ 
                                                        (__Vdfg_Regularize_2090 
                                                         << 1U))))
                               : (__Vdfg_Regularize_2090 
                                  << 1U));
    __Vdfg_Regularize_1951 = ((__Vdfg_Regularize_1836 
                               << 1U) | (1U & (vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_3__DOT__u_crc_parallel_crcw__DOT__reg_data 
                                               >> (0x0000001fU 
                                                   & ((7U 
                                                       & ((IData)(0x0dU) 
                                                          + (IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_3__DOT__u_crc_parallel_crcw__DOT__reg_chunk_idx))) 
                                                      + 
                                                      (0x00000018U 
                                                       & (((IData)(3U) 
                                                           - 
                                                           (3U 
                                                            & (((IData)(0x0dU) 
                                                                + (IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_3__DOT__u_crc_parallel_crcw__DOT__reg_chunk_idx)) 
                                                               >> 3U))) 
                                                          << 3U)))))));
    __Vdfg_Regularize_2046 = ((__Vdfg_Regularize_1899 
                               << 1U) | (1U & (vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_3__DOT__u_crc_parallel_crcw__DOT__reg_data 
                                               >> (0x0000001fU 
                                                   & ((7U 
                                                       & ((IData)(0x0dU) 
                                                          + (IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_3__DOT__u_crc_parallel_crcw__DOT__reg_chunk_idx))) 
                                                      + 
                                                      (0x00000018U 
                                                       & (((IData)(3U) 
                                                           - 
                                                           (3U 
                                                            & (((IData)(0x0dU) 
                                                                + (IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_3__DOT__u_crc_parallel_crcw__DOT__reg_chunk_idx)) 
                                                               >> 3U))) 
                                                          << 3U)))))));
    __Vdfg_Regularize_1997 = ((__Vdfg_Regularize_1996 
                               >> 0x0000001fU) ? (1U 
                                                  | (0xfffffffeU 
                                                     & (0x04c11db6U 
                                                        ^ 
                                                        (__Vdfg_Regularize_1996 
                                                         << 1U))))
                               : (__Vdfg_Regularize_1996 
                                  << 1U));
    __Vdfg_Regularize_2092 = ((__Vdfg_Regularize_2091 
                               >> 0x0000001fU) ? (1U 
                                                  | (0xfffffffeU 
                                                     & (0x04c11db6U 
                                                        ^ 
                                                        (__Vdfg_Regularize_2091 
                                                         << 1U))))
                               : (__Vdfg_Regularize_2091 
                                  << 1U));
    __Vdfg_Regularize_1838 = (((0x0000003fU & ((IData)(0x0dU) 
                                               + (IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_3__DOT__u_crc_parallel_crcw__DOT__reg_chunk_idx))) 
                               < (IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_3__DOT__u_crc_parallel_crcw__DOT__w_valid_bit_cnt))
                               ? ((__Vdfg_Regularize_1836 
                                   >> 0x0000001fU) ? 
                                  (0x04c11db7U ^ __Vdfg_Regularize_1951)
                                   : __Vdfg_Regularize_1951)
                               : __Vdfg_Regularize_1836);
    __Vdfg_Regularize_1901 = (((0x0000003fU & ((IData)(0x0dU) 
                                               + (IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_3__DOT__u_crc_parallel_crcw__DOT__reg_chunk_idx))) 
                               < (IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_3__DOT__u_crc_parallel_crcw__DOT__w_valid_bit_cnt))
                               ? ((__Vdfg_Regularize_1899 
                                   >> 0x0000001fU) ? 
                                  (0x04c11db7U ^ __Vdfg_Regularize_2046)
                                   : __Vdfg_Regularize_2046)
                               : __Vdfg_Regularize_1899);
    __Vdfg_Regularize_1998 = ((__Vdfg_Regularize_1997 
                               >> 0x0000001fU) ? (1U 
                                                  | (0xfffffffeU 
                                                     & (0x04c11db6U 
                                                        ^ 
                                                        (__Vdfg_Regularize_1997 
                                                         << 1U))))
                               : (__Vdfg_Regularize_1997 
                                  << 1U));
    __Vdfg_Regularize_2093 = ((__Vdfg_Regularize_2092 
                               >> 0x0000001fU) ? (1U 
                                                  | (0xfffffffeU 
                                                     & (0x04c11db6U 
                                                        ^ 
                                                        (__Vdfg_Regularize_2092 
                                                         << 1U))))
                               : (__Vdfg_Regularize_2092 
                                  << 1U));
    __Vdfg_Regularize_1952 = ((__Vdfg_Regularize_1838 
                               << 1U) | (1U & (vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_3__DOT__u_crc_parallel_crcw__DOT__reg_data 
                                               >> (0x0000001fU 
                                                   & ((7U 
                                                       & ((IData)(0x0eU) 
                                                          + (IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_3__DOT__u_crc_parallel_crcw__DOT__reg_chunk_idx))) 
                                                      + 
                                                      (0x00000018U 
                                                       & (((IData)(3U) 
                                                           - 
                                                           (3U 
                                                            & (((IData)(0x0eU) 
                                                                + (IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_3__DOT__u_crc_parallel_crcw__DOT__reg_chunk_idx)) 
                                                               >> 3U))) 
                                                          << 3U)))))));
    __Vdfg_Regularize_2047 = ((__Vdfg_Regularize_1901 
                               << 1U) | (1U & (vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_3__DOT__u_crc_parallel_crcw__DOT__reg_data 
                                               >> (0x0000001fU 
                                                   & ((7U 
                                                       & ((IData)(0x0eU) 
                                                          + (IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_3__DOT__u_crc_parallel_crcw__DOT__reg_chunk_idx))) 
                                                      + 
                                                      (0x00000018U 
                                                       & (((IData)(3U) 
                                                           - 
                                                           (3U 
                                                            & (((IData)(0x0eU) 
                                                                + (IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_3__DOT__u_crc_parallel_crcw__DOT__reg_chunk_idx)) 
                                                               >> 3U))) 
                                                          << 3U)))))));
    __Vdfg_Regularize_1999 = ((__Vdfg_Regularize_1998 
                               >> 0x0000001fU) ? (1U 
                                                  | (0xfffffffeU 
                                                     & (0x04c11db6U 
                                                        ^ 
                                                        (__Vdfg_Regularize_1998 
                                                         << 1U))))
                               : (__Vdfg_Regularize_1998 
                                  << 1U));
    __Vdfg_Regularize_2094 = ((__Vdfg_Regularize_2093 
                               >> 0x0000001fU) ? (1U 
                                                  | (0xfffffffeU 
                                                     & (0x04c11db6U 
                                                        ^ 
                                                        (__Vdfg_Regularize_2093 
                                                         << 1U))))
                               : (__Vdfg_Regularize_2093 
                                  << 1U));
    __Vdfg_Regularize_1840 = (((0x0000003fU & ((IData)(0x0eU) 
                                               + (IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_3__DOT__u_crc_parallel_crcw__DOT__reg_chunk_idx))) 
                               < (IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_3__DOT__u_crc_parallel_crcw__DOT__w_valid_bit_cnt))
                               ? ((__Vdfg_Regularize_1838 
                                   >> 0x0000001fU) ? 
                                  (0x04c11db7U ^ __Vdfg_Regularize_1952)
                                   : __Vdfg_Regularize_1952)
                               : __Vdfg_Regularize_1838);
    __Vdfg_Regularize_1903 = (((0x0000003fU & ((IData)(0x0eU) 
                                               + (IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_3__DOT__u_crc_parallel_crcw__DOT__reg_chunk_idx))) 
                               < (IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_3__DOT__u_crc_parallel_crcw__DOT__w_valid_bit_cnt))
                               ? ((__Vdfg_Regularize_1901 
                                   >> 0x0000001fU) ? 
                                  (0x04c11db7U ^ __Vdfg_Regularize_2047)
                                   : __Vdfg_Regularize_2047)
                               : __Vdfg_Regularize_1901);
    __Vdfg_Regularize_2000 = ((__Vdfg_Regularize_1999 
                               >> 0x0000001fU) ? (1U 
                                                  | (0xfffffffeU 
                                                     & (0x04c11db6U 
                                                        ^ 
                                                        (__Vdfg_Regularize_1999 
                                                         << 1U))))
                               : (__Vdfg_Regularize_1999 
                                  << 1U));
    __Vdfg_Regularize_2095 = ((__Vdfg_Regularize_2094 
                               >> 0x0000001fU) ? (1U 
                                                  | (0xfffffffeU 
                                                     & (0x04c11db6U 
                                                        ^ 
                                                        (__Vdfg_Regularize_2094 
                                                         << 1U))))
                               : (__Vdfg_Regularize_2094 
                                  << 1U));
    __Vdfg_Regularize_1953 = ((__Vdfg_Regularize_1840 
                               << 1U) | (1U & (vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_3__DOT__u_crc_parallel_crcw__DOT__reg_data 
                                               >> (0x0000001fU 
                                                   & ((7U 
                                                       & ((IData)(0x0fU) 
                                                          + (IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_3__DOT__u_crc_parallel_crcw__DOT__reg_chunk_idx))) 
                                                      + 
                                                      (0x00000018U 
                                                       & (((IData)(3U) 
                                                           - 
                                                           (3U 
                                                            & (((IData)(0x0fU) 
                                                                + (IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_3__DOT__u_crc_parallel_crcw__DOT__reg_chunk_idx)) 
                                                               >> 3U))) 
                                                          << 3U)))))));
    __Vdfg_Regularize_2048 = ((__Vdfg_Regularize_1903 
                               << 1U) | (1U & (vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_3__DOT__u_crc_parallel_crcw__DOT__reg_data 
                                               >> (0x0000001fU 
                                                   & ((7U 
                                                       & ((IData)(0x0fU) 
                                                          + (IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_3__DOT__u_crc_parallel_crcw__DOT__reg_chunk_idx))) 
                                                      + 
                                                      (0x00000018U 
                                                       & (((IData)(3U) 
                                                           - 
                                                           (3U 
                                                            & (((IData)(0x0fU) 
                                                                + (IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_3__DOT__u_crc_parallel_crcw__DOT__reg_chunk_idx)) 
                                                               >> 3U))) 
                                                          << 3U)))))));
    __Vdfg_Regularize_1842 = (((0x0000003fU & ((IData)(0x0fU) 
                                               + (IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_3__DOT__u_crc_parallel_crcw__DOT__reg_chunk_idx))) 
                               < (IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_3__DOT__u_crc_parallel_crcw__DOT__w_valid_bit_cnt))
                               ? ((__Vdfg_Regularize_1840 
                                   >> 0x0000001fU) ? 
                                  (0x04c11db7U ^ __Vdfg_Regularize_1953)
                                   : __Vdfg_Regularize_1953)
                               : __Vdfg_Regularize_1840);
    __Vdfg_Regularize_1905 = (((0x0000003fU & ((IData)(0x0fU) 
                                               + (IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_3__DOT__u_crc_parallel_crcw__DOT__reg_chunk_idx))) 
                               < (IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_3__DOT__u_crc_parallel_crcw__DOT__w_valid_bit_cnt))
                               ? ((__Vdfg_Regularize_1903 
                                   >> 0x0000001fU) ? 
                                  (0x04c11db7U ^ __Vdfg_Regularize_2048)
                                   : __Vdfg_Regularize_2048)
                               : __Vdfg_Regularize_1903);
    __Vdfg_Regularize_1954 = ((__Vdfg_Regularize_1842 
                               << 1U) | (1U & (vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_3__DOT__u_crc_parallel_crcw__DOT__reg_data 
                                               >> (0x0000001fU 
                                                   & ((7U 
                                                       & ((IData)(0x10U) 
                                                          + (IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_3__DOT__u_crc_parallel_crcw__DOT__reg_chunk_idx))) 
                                                      + 
                                                      (0x00000018U 
                                                       & (((IData)(3U) 
                                                           - 
                                                           (3U 
                                                            & (((IData)(0x10U) 
                                                                + (IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_3__DOT__u_crc_parallel_crcw__DOT__reg_chunk_idx)) 
                                                               >> 3U))) 
                                                          << 3U)))))));
    __Vdfg_Regularize_2049 = ((__Vdfg_Regularize_1905 
                               << 1U) | (1U & (vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_3__DOT__u_crc_parallel_crcw__DOT__reg_data 
                                               >> (0x0000001fU 
                                                   & ((7U 
                                                       & ((IData)(0x10U) 
                                                          + (IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_3__DOT__u_crc_parallel_crcw__DOT__reg_chunk_idx))) 
                                                      + 
                                                      (0x00000018U 
                                                       & (((IData)(3U) 
                                                           - 
                                                           (3U 
                                                            & (((IData)(0x10U) 
                                                                + (IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_3__DOT__u_crc_parallel_crcw__DOT__reg_chunk_idx)) 
                                                               >> 3U))) 
                                                          << 3U)))))));
    __Vdfg_Regularize_1844 = (((0x0000003fU & ((IData)(0x10U) 
                                               + (IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_3__DOT__u_crc_parallel_crcw__DOT__reg_chunk_idx))) 
                               < (IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_3__DOT__u_crc_parallel_crcw__DOT__w_valid_bit_cnt))
                               ? ((__Vdfg_Regularize_1842 
                                   >> 0x0000001fU) ? 
                                  (0x04c11db7U ^ __Vdfg_Regularize_1954)
                                   : __Vdfg_Regularize_1954)
                               : __Vdfg_Regularize_1842);
    __Vdfg_Regularize_1907 = (((0x0000003fU & ((IData)(0x10U) 
                                               + (IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_3__DOT__u_crc_parallel_crcw__DOT__reg_chunk_idx))) 
                               < (IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_3__DOT__u_crc_parallel_crcw__DOT__w_valid_bit_cnt))
                               ? ((__Vdfg_Regularize_1905 
                                   >> 0x0000001fU) ? 
                                  (0x04c11db7U ^ __Vdfg_Regularize_2049)
                                   : __Vdfg_Regularize_2049)
                               : __Vdfg_Regularize_1905);
    __Vdfg_Regularize_1955 = ((__Vdfg_Regularize_1844 
                               << 1U) | (1U & (vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_3__DOT__u_crc_parallel_crcw__DOT__reg_data 
                                               >> (0x0000001fU 
                                                   & ((7U 
                                                       & ((IData)(0x11U) 
                                                          + (IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_3__DOT__u_crc_parallel_crcw__DOT__reg_chunk_idx))) 
                                                      + 
                                                      (0x00000018U 
                                                       & (((IData)(3U) 
                                                           - 
                                                           (3U 
                                                            & (((IData)(0x11U) 
                                                                + (IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_3__DOT__u_crc_parallel_crcw__DOT__reg_chunk_idx)) 
                                                               >> 3U))) 
                                                          << 3U)))))));
    __Vdfg_Regularize_2050 = ((__Vdfg_Regularize_1907 
                               << 1U) | (1U & (vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_3__DOT__u_crc_parallel_crcw__DOT__reg_data 
                                               >> (0x0000001fU 
                                                   & ((7U 
                                                       & ((IData)(0x11U) 
                                                          + (IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_3__DOT__u_crc_parallel_crcw__DOT__reg_chunk_idx))) 
                                                      + 
                                                      (0x00000018U 
                                                       & (((IData)(3U) 
                                                           - 
                                                           (3U 
                                                            & (((IData)(0x11U) 
                                                                + (IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_3__DOT__u_crc_parallel_crcw__DOT__reg_chunk_idx)) 
                                                               >> 3U))) 
                                                          << 3U)))))));
    __Vdfg_Regularize_1846 = (((0x0000003fU & ((IData)(0x11U) 
                                               + (IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_3__DOT__u_crc_parallel_crcw__DOT__reg_chunk_idx))) 
                               < (IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_3__DOT__u_crc_parallel_crcw__DOT__w_valid_bit_cnt))
                               ? ((__Vdfg_Regularize_1844 
                                   >> 0x0000001fU) ? 
                                  (0x04c11db7U ^ __Vdfg_Regularize_1955)
                                   : __Vdfg_Regularize_1955)
                               : __Vdfg_Regularize_1844);
    __Vdfg_Regularize_1909 = (((0x0000003fU & ((IData)(0x11U) 
                                               + (IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_3__DOT__u_crc_parallel_crcw__DOT__reg_chunk_idx))) 
                               < (IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_3__DOT__u_crc_parallel_crcw__DOT__w_valid_bit_cnt))
                               ? ((__Vdfg_Regularize_1907 
                                   >> 0x0000001fU) ? 
                                  (0x04c11db7U ^ __Vdfg_Regularize_2050)
                                   : __Vdfg_Regularize_2050)
                               : __Vdfg_Regularize_1907);
    __Vdfg_Regularize_1956 = ((__Vdfg_Regularize_1846 
                               << 1U) | (1U & (vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_3__DOT__u_crc_parallel_crcw__DOT__reg_data 
                                               >> (0x0000001fU 
                                                   & ((7U 
                                                       & ((IData)(0x12U) 
                                                          + (IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_3__DOT__u_crc_parallel_crcw__DOT__reg_chunk_idx))) 
                                                      + 
                                                      (0x00000018U 
                                                       & (((IData)(3U) 
                                                           - 
                                                           (3U 
                                                            & (((IData)(0x12U) 
                                                                + (IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_3__DOT__u_crc_parallel_crcw__DOT__reg_chunk_idx)) 
                                                               >> 3U))) 
                                                          << 3U)))))));
    __Vdfg_Regularize_2051 = ((__Vdfg_Regularize_1909 
                               << 1U) | (1U & (vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_3__DOT__u_crc_parallel_crcw__DOT__reg_data 
                                               >> (0x0000001fU 
                                                   & ((7U 
                                                       & ((IData)(0x12U) 
                                                          + (IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_3__DOT__u_crc_parallel_crcw__DOT__reg_chunk_idx))) 
                                                      + 
                                                      (0x00000018U 
                                                       & (((IData)(3U) 
                                                           - 
                                                           (3U 
                                                            & (((IData)(0x12U) 
                                                                + (IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_3__DOT__u_crc_parallel_crcw__DOT__reg_chunk_idx)) 
                                                               >> 3U))) 
                                                          << 3U)))))));
    __Vdfg_Regularize_1848 = (((0x0000003fU & ((IData)(0x12U) 
                                               + (IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_3__DOT__u_crc_parallel_crcw__DOT__reg_chunk_idx))) 
                               < (IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_3__DOT__u_crc_parallel_crcw__DOT__w_valid_bit_cnt))
                               ? ((__Vdfg_Regularize_1846 
                                   >> 0x0000001fU) ? 
                                  (0x04c11db7U ^ __Vdfg_Regularize_1956)
                                   : __Vdfg_Regularize_1956)
                               : __Vdfg_Regularize_1846);
    __Vdfg_Regularize_1911 = (((0x0000003fU & ((IData)(0x12U) 
                                               + (IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_3__DOT__u_crc_parallel_crcw__DOT__reg_chunk_idx))) 
                               < (IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_3__DOT__u_crc_parallel_crcw__DOT__w_valid_bit_cnt))
                               ? ((__Vdfg_Regularize_1909 
                                   >> 0x0000001fU) ? 
                                  (0x04c11db7U ^ __Vdfg_Regularize_2051)
                                   : __Vdfg_Regularize_2051)
                               : __Vdfg_Regularize_1909);
    __Vdfg_Regularize_1957 = ((__Vdfg_Regularize_1848 
                               << 1U) | (1U & (vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_3__DOT__u_crc_parallel_crcw__DOT__reg_data 
                                               >> (0x0000001fU 
                                                   & ((7U 
                                                       & ((IData)(0x13U) 
                                                          + (IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_3__DOT__u_crc_parallel_crcw__DOT__reg_chunk_idx))) 
                                                      + 
                                                      (0x00000018U 
                                                       & (((IData)(3U) 
                                                           - 
                                                           (3U 
                                                            & (((IData)(0x13U) 
                                                                + (IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_3__DOT__u_crc_parallel_crcw__DOT__reg_chunk_idx)) 
                                                               >> 3U))) 
                                                          << 3U)))))));
    __Vdfg_Regularize_2052 = ((__Vdfg_Regularize_1911 
                               << 1U) | (1U & (vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_3__DOT__u_crc_parallel_crcw__DOT__reg_data 
                                               >> (0x0000001fU 
                                                   & ((7U 
                                                       & ((IData)(0x13U) 
                                                          + (IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_3__DOT__u_crc_parallel_crcw__DOT__reg_chunk_idx))) 
                                                      + 
                                                      (0x00000018U 
                                                       & (((IData)(3U) 
                                                           - 
                                                           (3U 
                                                            & (((IData)(0x13U) 
                                                                + (IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_3__DOT__u_crc_parallel_crcw__DOT__reg_chunk_idx)) 
                                                               >> 3U))) 
                                                          << 3U)))))));
    __Vdfg_Regularize_1850 = (((0x0000003fU & ((IData)(0x13U) 
                                               + (IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_3__DOT__u_crc_parallel_crcw__DOT__reg_chunk_idx))) 
                               < (IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_3__DOT__u_crc_parallel_crcw__DOT__w_valid_bit_cnt))
                               ? ((__Vdfg_Regularize_1848 
                                   >> 0x0000001fU) ? 
                                  (0x04c11db7U ^ __Vdfg_Regularize_1957)
                                   : __Vdfg_Regularize_1957)
                               : __Vdfg_Regularize_1848);
    __Vdfg_Regularize_1913 = (((0x0000003fU & ((IData)(0x13U) 
                                               + (IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_3__DOT__u_crc_parallel_crcw__DOT__reg_chunk_idx))) 
                               < (IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_3__DOT__u_crc_parallel_crcw__DOT__w_valid_bit_cnt))
                               ? ((__Vdfg_Regularize_1911 
                                   >> 0x0000001fU) ? 
                                  (0x04c11db7U ^ __Vdfg_Regularize_2052)
                                   : __Vdfg_Regularize_2052)
                               : __Vdfg_Regularize_1911);
    __Vdfg_Regularize_1958 = ((__Vdfg_Regularize_1850 
                               << 1U) | (1U & (vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_3__DOT__u_crc_parallel_crcw__DOT__reg_data 
                                               >> (0x0000001fU 
                                                   & ((7U 
                                                       & ((IData)(0x14U) 
                                                          + (IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_3__DOT__u_crc_parallel_crcw__DOT__reg_chunk_idx))) 
                                                      + 
                                                      (0x00000018U 
                                                       & (((IData)(3U) 
                                                           - 
                                                           (3U 
                                                            & (((IData)(0x14U) 
                                                                + (IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_3__DOT__u_crc_parallel_crcw__DOT__reg_chunk_idx)) 
                                                               >> 3U))) 
                                                          << 3U)))))));
    __Vdfg_Regularize_2053 = ((__Vdfg_Regularize_1913 
                               << 1U) | (1U & (vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_3__DOT__u_crc_parallel_crcw__DOT__reg_data 
                                               >> (0x0000001fU 
                                                   & ((7U 
                                                       & ((IData)(0x14U) 
                                                          + (IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_3__DOT__u_crc_parallel_crcw__DOT__reg_chunk_idx))) 
                                                      + 
                                                      (0x00000018U 
                                                       & (((IData)(3U) 
                                                           - 
                                                           (3U 
                                                            & (((IData)(0x14U) 
                                                                + (IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_3__DOT__u_crc_parallel_crcw__DOT__reg_chunk_idx)) 
                                                               >> 3U))) 
                                                          << 3U)))))));
    __Vdfg_Regularize_1852 = (((0x0000003fU & ((IData)(0x14U) 
                                               + (IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_3__DOT__u_crc_parallel_crcw__DOT__reg_chunk_idx))) 
                               < (IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_3__DOT__u_crc_parallel_crcw__DOT__w_valid_bit_cnt))
                               ? ((__Vdfg_Regularize_1850 
                                   >> 0x0000001fU) ? 
                                  (0x04c11db7U ^ __Vdfg_Regularize_1958)
                                   : __Vdfg_Regularize_1958)
                               : __Vdfg_Regularize_1850);
    __Vdfg_Regularize_1915 = (((0x0000003fU & ((IData)(0x14U) 
                                               + (IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_3__DOT__u_crc_parallel_crcw__DOT__reg_chunk_idx))) 
                               < (IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_3__DOT__u_crc_parallel_crcw__DOT__w_valid_bit_cnt))
                               ? ((__Vdfg_Regularize_1913 
                                   >> 0x0000001fU) ? 
                                  (0x04c11db7U ^ __Vdfg_Regularize_2053)
                                   : __Vdfg_Regularize_2053)
                               : __Vdfg_Regularize_1913);
    __Vdfg_Regularize_1959 = ((__Vdfg_Regularize_1852 
                               << 1U) | (1U & (vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_3__DOT__u_crc_parallel_crcw__DOT__reg_data 
                                               >> (0x0000001fU 
                                                   & ((7U 
                                                       & ((IData)(0x15U) 
                                                          + (IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_3__DOT__u_crc_parallel_crcw__DOT__reg_chunk_idx))) 
                                                      + 
                                                      (0x00000018U 
                                                       & (((IData)(3U) 
                                                           - 
                                                           (3U 
                                                            & (((IData)(0x15U) 
                                                                + (IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_3__DOT__u_crc_parallel_crcw__DOT__reg_chunk_idx)) 
                                                               >> 3U))) 
                                                          << 3U)))))));
    __Vdfg_Regularize_2054 = ((__Vdfg_Regularize_1915 
                               << 1U) | (1U & (vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_3__DOT__u_crc_parallel_crcw__DOT__reg_data 
                                               >> (0x0000001fU 
                                                   & ((7U 
                                                       & ((IData)(0x15U) 
                                                          + (IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_3__DOT__u_crc_parallel_crcw__DOT__reg_chunk_idx))) 
                                                      + 
                                                      (0x00000018U 
                                                       & (((IData)(3U) 
                                                           - 
                                                           (3U 
                                                            & (((IData)(0x15U) 
                                                                + (IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_3__DOT__u_crc_parallel_crcw__DOT__reg_chunk_idx)) 
                                                               >> 3U))) 
                                                          << 3U)))))));
    __Vdfg_Regularize_1854 = (((0x0000003fU & ((IData)(0x15U) 
                                               + (IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_3__DOT__u_crc_parallel_crcw__DOT__reg_chunk_idx))) 
                               < (IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_3__DOT__u_crc_parallel_crcw__DOT__w_valid_bit_cnt))
                               ? ((__Vdfg_Regularize_1852 
                                   >> 0x0000001fU) ? 
                                  (0x04c11db7U ^ __Vdfg_Regularize_1959)
                                   : __Vdfg_Regularize_1959)
                               : __Vdfg_Regularize_1852);
    __Vdfg_Regularize_1917 = (((0x0000003fU & ((IData)(0x15U) 
                                               + (IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_3__DOT__u_crc_parallel_crcw__DOT__reg_chunk_idx))) 
                               < (IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_3__DOT__u_crc_parallel_crcw__DOT__w_valid_bit_cnt))
                               ? ((__Vdfg_Regularize_1915 
                                   >> 0x0000001fU) ? 
                                  (0x04c11db7U ^ __Vdfg_Regularize_2054)
                                   : __Vdfg_Regularize_2054)
                               : __Vdfg_Regularize_1915);
    __Vdfg_Regularize_1960 = ((__Vdfg_Regularize_1854 
                               << 1U) | (1U & (vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_3__DOT__u_crc_parallel_crcw__DOT__reg_data 
                                               >> (0x0000001fU 
                                                   & ((7U 
                                                       & ((IData)(0x16U) 
                                                          + (IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_3__DOT__u_crc_parallel_crcw__DOT__reg_chunk_idx))) 
                                                      + 
                                                      (0x00000018U 
                                                       & (((IData)(3U) 
                                                           - 
                                                           (3U 
                                                            & (((IData)(0x16U) 
                                                                + (IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_3__DOT__u_crc_parallel_crcw__DOT__reg_chunk_idx)) 
                                                               >> 3U))) 
                                                          << 3U)))))));
    __Vdfg_Regularize_2055 = ((__Vdfg_Regularize_1917 
                               << 1U) | (1U & (vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_3__DOT__u_crc_parallel_crcw__DOT__reg_data 
                                               >> (0x0000001fU 
                                                   & ((7U 
                                                       & ((IData)(0x16U) 
                                                          + (IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_3__DOT__u_crc_parallel_crcw__DOT__reg_chunk_idx))) 
                                                      + 
                                                      (0x00000018U 
                                                       & (((IData)(3U) 
                                                           - 
                                                           (3U 
                                                            & (((IData)(0x16U) 
                                                                + (IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_3__DOT__u_crc_parallel_crcw__DOT__reg_chunk_idx)) 
                                                               >> 3U))) 
                                                          << 3U)))))));
    __Vdfg_Regularize_1856 = (((0x0000003fU & ((IData)(0x16U) 
                                               + (IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_3__DOT__u_crc_parallel_crcw__DOT__reg_chunk_idx))) 
                               < (IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_3__DOT__u_crc_parallel_crcw__DOT__w_valid_bit_cnt))
                               ? ((__Vdfg_Regularize_1854 
                                   >> 0x0000001fU) ? 
                                  (0x04c11db7U ^ __Vdfg_Regularize_1960)
                                   : __Vdfg_Regularize_1960)
                               : __Vdfg_Regularize_1854);
    __Vdfg_Regularize_1919 = (((0x0000003fU & ((IData)(0x16U) 
                                               + (IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_3__DOT__u_crc_parallel_crcw__DOT__reg_chunk_idx))) 
                               < (IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_3__DOT__u_crc_parallel_crcw__DOT__w_valid_bit_cnt))
                               ? ((__Vdfg_Regularize_1917 
                                   >> 0x0000001fU) ? 
                                  (0x04c11db7U ^ __Vdfg_Regularize_2055)
                                   : __Vdfg_Regularize_2055)
                               : __Vdfg_Regularize_1917);
    __Vdfg_Regularize_1961 = ((__Vdfg_Regularize_1856 
                               << 1U) | (1U & (vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_3__DOT__u_crc_parallel_crcw__DOT__reg_data 
                                               >> (0x0000001fU 
                                                   & ((7U 
                                                       & ((IData)(0x17U) 
                                                          + (IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_3__DOT__u_crc_parallel_crcw__DOT__reg_chunk_idx))) 
                                                      + 
                                                      (0x00000018U 
                                                       & (((IData)(3U) 
                                                           - 
                                                           (3U 
                                                            & (((IData)(0x17U) 
                                                                + (IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_3__DOT__u_crc_parallel_crcw__DOT__reg_chunk_idx)) 
                                                               >> 3U))) 
                                                          << 3U)))))));
    __Vdfg_Regularize_2056 = ((__Vdfg_Regularize_1919 
                               << 1U) | (1U & (vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_3__DOT__u_crc_parallel_crcw__DOT__reg_data 
                                               >> (0x0000001fU 
                                                   & ((7U 
                                                       & ((IData)(0x17U) 
                                                          + (IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_3__DOT__u_crc_parallel_crcw__DOT__reg_chunk_idx))) 
                                                      + 
                                                      (0x00000018U 
                                                       & (((IData)(3U) 
                                                           - 
                                                           (3U 
                                                            & (((IData)(0x17U) 
                                                                + (IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_3__DOT__u_crc_parallel_crcw__DOT__reg_chunk_idx)) 
                                                               >> 3U))) 
                                                          << 3U)))))));
    __Vdfg_Regularize_1858 = (((0x0000003fU & ((IData)(0x17U) 
                                               + (IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_3__DOT__u_crc_parallel_crcw__DOT__reg_chunk_idx))) 
                               < (IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_3__DOT__u_crc_parallel_crcw__DOT__w_valid_bit_cnt))
                               ? ((__Vdfg_Regularize_1856 
                                   >> 0x0000001fU) ? 
                                  (0x04c11db7U ^ __Vdfg_Regularize_1961)
                                   : __Vdfg_Regularize_1961)
                               : __Vdfg_Regularize_1856);
    __Vdfg_Regularize_1921 = (((0x0000003fU & ((IData)(0x17U) 
                                               + (IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_3__DOT__u_crc_parallel_crcw__DOT__reg_chunk_idx))) 
                               < (IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_3__DOT__u_crc_parallel_crcw__DOT__w_valid_bit_cnt))
                               ? ((__Vdfg_Regularize_1919 
                                   >> 0x0000001fU) ? 
                                  (0x04c11db7U ^ __Vdfg_Regularize_2056)
                                   : __Vdfg_Regularize_2056)
                               : __Vdfg_Regularize_1919);
    __Vdfg_Regularize_1962 = ((__Vdfg_Regularize_1858 
                               << 1U) | (1U & (vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_3__DOT__u_crc_parallel_crcw__DOT__reg_data 
                                               >> (0x0000001fU 
                                                   & ((7U 
                                                       & ((IData)(0x18U) 
                                                          + (IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_3__DOT__u_crc_parallel_crcw__DOT__reg_chunk_idx))) 
                                                      + 
                                                      (0x00000018U 
                                                       & (((IData)(3U) 
                                                           - 
                                                           (3U 
                                                            & (((IData)(0x18U) 
                                                                + (IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_3__DOT__u_crc_parallel_crcw__DOT__reg_chunk_idx)) 
                                                               >> 3U))) 
                                                          << 3U)))))));
    __Vdfg_Regularize_2057 = ((__Vdfg_Regularize_1921 
                               << 1U) | (1U & (vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_3__DOT__u_crc_parallel_crcw__DOT__reg_data 
                                               >> (0x0000001fU 
                                                   & ((7U 
                                                       & ((IData)(0x18U) 
                                                          + (IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_3__DOT__u_crc_parallel_crcw__DOT__reg_chunk_idx))) 
                                                      + 
                                                      (0x00000018U 
                                                       & (((IData)(3U) 
                                                           - 
                                                           (3U 
                                                            & (((IData)(0x18U) 
                                                                + (IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_3__DOT__u_crc_parallel_crcw__DOT__reg_chunk_idx)) 
                                                               >> 3U))) 
                                                          << 3U)))))));
    __Vdfg_Regularize_1860 = (((0x0000003fU & ((IData)(0x18U) 
                                               + (IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_3__DOT__u_crc_parallel_crcw__DOT__reg_chunk_idx))) 
                               < (IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_3__DOT__u_crc_parallel_crcw__DOT__w_valid_bit_cnt))
                               ? ((__Vdfg_Regularize_1858 
                                   >> 0x0000001fU) ? 
                                  (0x04c11db7U ^ __Vdfg_Regularize_1962)
                                   : __Vdfg_Regularize_1962)
                               : __Vdfg_Regularize_1858);
    __Vdfg_Regularize_1923 = (((0x0000003fU & ((IData)(0x18U) 
                                               + (IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_3__DOT__u_crc_parallel_crcw__DOT__reg_chunk_idx))) 
                               < (IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_3__DOT__u_crc_parallel_crcw__DOT__w_valid_bit_cnt))
                               ? ((__Vdfg_Regularize_1921 
                                   >> 0x0000001fU) ? 
                                  (0x04c11db7U ^ __Vdfg_Regularize_2057)
                                   : __Vdfg_Regularize_2057)
                               : __Vdfg_Regularize_1921);
    __Vdfg_Regularize_1963 = ((__Vdfg_Regularize_1860 
                               << 1U) | (1U & (vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_3__DOT__u_crc_parallel_crcw__DOT__reg_data 
                                               >> (0x0000001fU 
                                                   & ((7U 
                                                       & ((IData)(0x19U) 
                                                          + (IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_3__DOT__u_crc_parallel_crcw__DOT__reg_chunk_idx))) 
                                                      + 
                                                      (0x00000018U 
                                                       & (((IData)(3U) 
                                                           - 
                                                           (3U 
                                                            & (((IData)(0x19U) 
                                                                + (IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_3__DOT__u_crc_parallel_crcw__DOT__reg_chunk_idx)) 
                                                               >> 3U))) 
                                                          << 3U)))))));
    __Vdfg_Regularize_2058 = ((__Vdfg_Regularize_1923 
                               << 1U) | (1U & (vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_3__DOT__u_crc_parallel_crcw__DOT__reg_data 
                                               >> (0x0000001fU 
                                                   & ((7U 
                                                       & ((IData)(0x19U) 
                                                          + (IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_3__DOT__u_crc_parallel_crcw__DOT__reg_chunk_idx))) 
                                                      + 
                                                      (0x00000018U 
                                                       & (((IData)(3U) 
                                                           - 
                                                           (3U 
                                                            & (((IData)(0x19U) 
                                                                + (IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_3__DOT__u_crc_parallel_crcw__DOT__reg_chunk_idx)) 
                                                               >> 3U))) 
                                                          << 3U)))))));
    __Vdfg_Regularize_1862 = (((0x0000003fU & ((IData)(0x19U) 
                                               + (IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_3__DOT__u_crc_parallel_crcw__DOT__reg_chunk_idx))) 
                               < (IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_3__DOT__u_crc_parallel_crcw__DOT__w_valid_bit_cnt))
                               ? ((__Vdfg_Regularize_1860 
                                   >> 0x0000001fU) ? 
                                  (0x04c11db7U ^ __Vdfg_Regularize_1963)
                                   : __Vdfg_Regularize_1963)
                               : __Vdfg_Regularize_1860);
    __Vdfg_Regularize_1925 = (((0x0000003fU & ((IData)(0x19U) 
                                               + (IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_3__DOT__u_crc_parallel_crcw__DOT__reg_chunk_idx))) 
                               < (IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_3__DOT__u_crc_parallel_crcw__DOT__w_valid_bit_cnt))
                               ? ((__Vdfg_Regularize_1923 
                                   >> 0x0000001fU) ? 
                                  (0x04c11db7U ^ __Vdfg_Regularize_2058)
                                   : __Vdfg_Regularize_2058)
                               : __Vdfg_Regularize_1923);
    __Vdfg_Regularize_1964 = ((__Vdfg_Regularize_1862 
                               << 1U) | (1U & (vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_3__DOT__u_crc_parallel_crcw__DOT__reg_data 
                                               >> (0x0000001fU 
                                                   & ((7U 
                                                       & ((IData)(0x1aU) 
                                                          + (IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_3__DOT__u_crc_parallel_crcw__DOT__reg_chunk_idx))) 
                                                      + 
                                                      (0x00000018U 
                                                       & (((IData)(3U) 
                                                           - 
                                                           (3U 
                                                            & (((IData)(0x1aU) 
                                                                + (IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_3__DOT__u_crc_parallel_crcw__DOT__reg_chunk_idx)) 
                                                               >> 3U))) 
                                                          << 3U)))))));
    __Vdfg_Regularize_2059 = ((__Vdfg_Regularize_1925 
                               << 1U) | (1U & (vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_3__DOT__u_crc_parallel_crcw__DOT__reg_data 
                                               >> (0x0000001fU 
                                                   & ((7U 
                                                       & ((IData)(0x1aU) 
                                                          + (IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_3__DOT__u_crc_parallel_crcw__DOT__reg_chunk_idx))) 
                                                      + 
                                                      (0x00000018U 
                                                       & (((IData)(3U) 
                                                           - 
                                                           (3U 
                                                            & (((IData)(0x1aU) 
                                                                + (IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_3__DOT__u_crc_parallel_crcw__DOT__reg_chunk_idx)) 
                                                               >> 3U))) 
                                                          << 3U)))))));
    __Vdfg_Regularize_1864 = (((0x0000003fU & ((IData)(0x1aU) 
                                               + (IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_3__DOT__u_crc_parallel_crcw__DOT__reg_chunk_idx))) 
                               < (IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_3__DOT__u_crc_parallel_crcw__DOT__w_valid_bit_cnt))
                               ? ((__Vdfg_Regularize_1862 
                                   >> 0x0000001fU) ? 
                                  (0x04c11db7U ^ __Vdfg_Regularize_1964)
                                   : __Vdfg_Regularize_1964)
                               : __Vdfg_Regularize_1862);
    __Vdfg_Regularize_1927 = (((0x0000003fU & ((IData)(0x1aU) 
                                               + (IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_3__DOT__u_crc_parallel_crcw__DOT__reg_chunk_idx))) 
                               < (IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_3__DOT__u_crc_parallel_crcw__DOT__w_valid_bit_cnt))
                               ? ((__Vdfg_Regularize_1925 
                                   >> 0x0000001fU) ? 
                                  (0x04c11db7U ^ __Vdfg_Regularize_2059)
                                   : __Vdfg_Regularize_2059)
                               : __Vdfg_Regularize_1925);
    __Vdfg_Regularize_1965 = ((__Vdfg_Regularize_1864 
                               << 1U) | (1U & (vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_3__DOT__u_crc_parallel_crcw__DOT__reg_data 
                                               >> (0x0000001fU 
                                                   & ((7U 
                                                       & ((IData)(0x1bU) 
                                                          + (IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_3__DOT__u_crc_parallel_crcw__DOT__reg_chunk_idx))) 
                                                      + 
                                                      (0x00000018U 
                                                       & (((IData)(3U) 
                                                           - 
                                                           (3U 
                                                            & (((IData)(0x1bU) 
                                                                + (IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_3__DOT__u_crc_parallel_crcw__DOT__reg_chunk_idx)) 
                                                               >> 3U))) 
                                                          << 3U)))))));
    __Vdfg_Regularize_2060 = ((__Vdfg_Regularize_1927 
                               << 1U) | (1U & (vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_3__DOT__u_crc_parallel_crcw__DOT__reg_data 
                                               >> (0x0000001fU 
                                                   & ((7U 
                                                       & ((IData)(0x1bU) 
                                                          + (IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_3__DOT__u_crc_parallel_crcw__DOT__reg_chunk_idx))) 
                                                      + 
                                                      (0x00000018U 
                                                       & (((IData)(3U) 
                                                           - 
                                                           (3U 
                                                            & (((IData)(0x1bU) 
                                                                + (IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_3__DOT__u_crc_parallel_crcw__DOT__reg_chunk_idx)) 
                                                               >> 3U))) 
                                                          << 3U)))))));
    __Vdfg_Regularize_1866 = (((0x0000003fU & ((IData)(0x1bU) 
                                               + (IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_3__DOT__u_crc_parallel_crcw__DOT__reg_chunk_idx))) 
                               < (IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_3__DOT__u_crc_parallel_crcw__DOT__w_valid_bit_cnt))
                               ? ((__Vdfg_Regularize_1864 
                                   >> 0x0000001fU) ? 
                                  (0x04c11db7U ^ __Vdfg_Regularize_1965)
                                   : __Vdfg_Regularize_1965)
                               : __Vdfg_Regularize_1864);
    __Vdfg_Regularize_1929 = (((0x0000003fU & ((IData)(0x1bU) 
                                               + (IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_3__DOT__u_crc_parallel_crcw__DOT__reg_chunk_idx))) 
                               < (IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_3__DOT__u_crc_parallel_crcw__DOT__w_valid_bit_cnt))
                               ? ((__Vdfg_Regularize_1927 
                                   >> 0x0000001fU) ? 
                                  (0x04c11db7U ^ __Vdfg_Regularize_2060)
                                   : __Vdfg_Regularize_2060)
                               : __Vdfg_Regularize_1927);
    __Vdfg_Regularize_1966 = ((__Vdfg_Regularize_1866 
                               << 1U) | (1U & (vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_3__DOT__u_crc_parallel_crcw__DOT__reg_data 
                                               >> (0x0000001fU 
                                                   & ((7U 
                                                       & ((IData)(0x1cU) 
                                                          + (IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_3__DOT__u_crc_parallel_crcw__DOT__reg_chunk_idx))) 
                                                      + 
                                                      (0x00000018U 
                                                       & (((IData)(3U) 
                                                           - 
                                                           (3U 
                                                            & (((IData)(0x1cU) 
                                                                + (IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_3__DOT__u_crc_parallel_crcw__DOT__reg_chunk_idx)) 
                                                               >> 3U))) 
                                                          << 3U)))))));
    __Vdfg_Regularize_2061 = ((__Vdfg_Regularize_1929 
                               << 1U) | (1U & (vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_3__DOT__u_crc_parallel_crcw__DOT__reg_data 
                                               >> (0x0000001fU 
                                                   & ((7U 
                                                       & ((IData)(0x1cU) 
                                                          + (IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_3__DOT__u_crc_parallel_crcw__DOT__reg_chunk_idx))) 
                                                      + 
                                                      (0x00000018U 
                                                       & (((IData)(3U) 
                                                           - 
                                                           (3U 
                                                            & (((IData)(0x1cU) 
                                                                + (IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_3__DOT__u_crc_parallel_crcw__DOT__reg_chunk_idx)) 
                                                               >> 3U))) 
                                                          << 3U)))))));
    __Vdfg_Regularize_1868 = (((0x0000003fU & ((IData)(0x1cU) 
                                               + (IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_3__DOT__u_crc_parallel_crcw__DOT__reg_chunk_idx))) 
                               < (IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_3__DOT__u_crc_parallel_crcw__DOT__w_valid_bit_cnt))
                               ? ((__Vdfg_Regularize_1866 
                                   >> 0x0000001fU) ? 
                                  (0x04c11db7U ^ __Vdfg_Regularize_1966)
                                   : __Vdfg_Regularize_1966)
                               : __Vdfg_Regularize_1866);
    __Vdfg_Regularize_1931 = (((0x0000003fU & ((IData)(0x1cU) 
                                               + (IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_3__DOT__u_crc_parallel_crcw__DOT__reg_chunk_idx))) 
                               < (IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_3__DOT__u_crc_parallel_crcw__DOT__w_valid_bit_cnt))
                               ? ((__Vdfg_Regularize_1929 
                                   >> 0x0000001fU) ? 
                                  (0x04c11db7U ^ __Vdfg_Regularize_2061)
                                   : __Vdfg_Regularize_2061)
                               : __Vdfg_Regularize_1929);
    __Vdfg_Regularize_1967 = ((__Vdfg_Regularize_1868 
                               << 1U) | (1U & (vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_3__DOT__u_crc_parallel_crcw__DOT__reg_data 
                                               >> (0x0000001fU 
                                                   & ((7U 
                                                       & ((IData)(0x1dU) 
                                                          + (IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_3__DOT__u_crc_parallel_crcw__DOT__reg_chunk_idx))) 
                                                      + 
                                                      (0x00000018U 
                                                       & (((IData)(3U) 
                                                           - 
                                                           (3U 
                                                            & (((IData)(0x1dU) 
                                                                + (IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_3__DOT__u_crc_parallel_crcw__DOT__reg_chunk_idx)) 
                                                               >> 3U))) 
                                                          << 3U)))))));
    __Vdfg_Regularize_2062 = ((__Vdfg_Regularize_1931 
                               << 1U) | (1U & (vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_3__DOT__u_crc_parallel_crcw__DOT__reg_data 
                                               >> (0x0000001fU 
                                                   & ((7U 
                                                       & ((IData)(0x1dU) 
                                                          + (IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_3__DOT__u_crc_parallel_crcw__DOT__reg_chunk_idx))) 
                                                      + 
                                                      (0x00000018U 
                                                       & (((IData)(3U) 
                                                           - 
                                                           (3U 
                                                            & (((IData)(0x1dU) 
                                                                + (IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_3__DOT__u_crc_parallel_crcw__DOT__reg_chunk_idx)) 
                                                               >> 3U))) 
                                                          << 3U)))))));
    __Vdfg_Regularize_1870 = (((0x0000003fU & ((IData)(0x1dU) 
                                               + (IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_3__DOT__u_crc_parallel_crcw__DOT__reg_chunk_idx))) 
                               < (IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_3__DOT__u_crc_parallel_crcw__DOT__w_valid_bit_cnt))
                               ? ((__Vdfg_Regularize_1868 
                                   >> 0x0000001fU) ? 
                                  (0x04c11db7U ^ __Vdfg_Regularize_1967)
                                   : __Vdfg_Regularize_1967)
                               : __Vdfg_Regularize_1868);
    __Vdfg_Regularize_1933 = (((0x0000003fU & ((IData)(0x1dU) 
                                               + (IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_3__DOT__u_crc_parallel_crcw__DOT__reg_chunk_idx))) 
                               < (IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_3__DOT__u_crc_parallel_crcw__DOT__w_valid_bit_cnt))
                               ? ((__Vdfg_Regularize_1931 
                                   >> 0x0000001fU) ? 
                                  (0x04c11db7U ^ __Vdfg_Regularize_2062)
                                   : __Vdfg_Regularize_2062)
                               : __Vdfg_Regularize_1931);
    __Vdfg_Regularize_1968 = ((__Vdfg_Regularize_1870 
                               << 1U) | (1U & (vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_3__DOT__u_crc_parallel_crcw__DOT__reg_data 
                                               >> (0x0000001fU 
                                                   & ((7U 
                                                       & ((IData)(0x1eU) 
                                                          + (IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_3__DOT__u_crc_parallel_crcw__DOT__reg_chunk_idx))) 
                                                      + 
                                                      (0x00000018U 
                                                       & (((IData)(3U) 
                                                           - 
                                                           (3U 
                                                            & (((IData)(0x1eU) 
                                                                + (IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_3__DOT__u_crc_parallel_crcw__DOT__reg_chunk_idx)) 
                                                               >> 3U))) 
                                                          << 3U)))))));
    __Vdfg_Regularize_2063 = ((__Vdfg_Regularize_1933 
                               << 1U) | (1U & (vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_3__DOT__u_crc_parallel_crcw__DOT__reg_data 
                                               >> (0x0000001fU 
                                                   & ((7U 
                                                       & ((IData)(0x1eU) 
                                                          + (IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_3__DOT__u_crc_parallel_crcw__DOT__reg_chunk_idx))) 
                                                      + 
                                                      (0x00000018U 
                                                       & (((IData)(3U) 
                                                           - 
                                                           (3U 
                                                            & (((IData)(0x1eU) 
                                                                + (IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_3__DOT__u_crc_parallel_crcw__DOT__reg_chunk_idx)) 
                                                               >> 3U))) 
                                                          << 3U)))))));
    __Vdfg_Regularize_1872 = (((0x0000003fU & ((IData)(0x1eU) 
                                               + (IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_3__DOT__u_crc_parallel_crcw__DOT__reg_chunk_idx))) 
                               < (IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_3__DOT__u_crc_parallel_crcw__DOT__w_valid_bit_cnt))
                               ? ((__Vdfg_Regularize_1870 
                                   >> 0x0000001fU) ? 
                                  (0x04c11db7U ^ __Vdfg_Regularize_1968)
                                   : __Vdfg_Regularize_1968)
                               : __Vdfg_Regularize_1870);
    __Vdfg_Regularize_1935 = (((0x0000003fU & ((IData)(0x1eU) 
                                               + (IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_3__DOT__u_crc_parallel_crcw__DOT__reg_chunk_idx))) 
                               < (IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_3__DOT__u_crc_parallel_crcw__DOT__w_valid_bit_cnt))
                               ? ((__Vdfg_Regularize_1933 
                                   >> 0x0000001fU) ? 
                                  (0x04c11db7U ^ __Vdfg_Regularize_2063)
                                   : __Vdfg_Regularize_2063)
                               : __Vdfg_Regularize_1933);
    __Vdfg_Regularize_1969 = ((__Vdfg_Regularize_1872 
                               << 1U) | (1U & (vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_3__DOT__u_crc_parallel_crcw__DOT__reg_data 
                                               >> (0x0000001fU 
                                                   & ((7U 
                                                       & ((IData)(0x1fU) 
                                                          + (IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_3__DOT__u_crc_parallel_crcw__DOT__reg_chunk_idx))) 
                                                      + 
                                                      (0x00000018U 
                                                       & (((IData)(3U) 
                                                           - 
                                                           (3U 
                                                            & (((IData)(0x1fU) 
                                                                + (IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_3__DOT__u_crc_parallel_crcw__DOT__reg_chunk_idx)) 
                                                               >> 3U))) 
                                                          << 3U)))))));
    __Vdfg_Regularize_2064 = ((__Vdfg_Regularize_1935 
                               << 1U) | (1U & (vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_3__DOT__u_crc_parallel_crcw__DOT__reg_data 
                                               >> (0x0000001fU 
                                                   & ((7U 
                                                       & ((IData)(0x1fU) 
                                                          + (IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_3__DOT__u_crc_parallel_crcw__DOT__reg_chunk_idx))) 
                                                      + 
                                                      (0x00000018U 
                                                       & (((IData)(3U) 
                                                           - 
                                                           (3U 
                                                            & (((IData)(0x1fU) 
                                                                + (IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_3__DOT__u_crc_parallel_crcw__DOT__reg_chunk_idx)) 
                                                               >> 3U))) 
                                                          << 3U)))))));
    vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_3__DOT__u_crc_parallel_crcw__DOT__w_chunk_crc 
        = ((IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_3__DOT__u_crc_parallel_crcw__DOT__reg_augment)
            ? ((__Vdfg_Regularize_2000 >> 0x0000001fU)
                ? (1U | (0xfffffffeU & (0x04c11db6U 
                                        ^ (__Vdfg_Regularize_2000 
                                           << 1U))))
                : (__Vdfg_Regularize_2000 << 1U)) : 
           (((0x0000003fU & ((IData)(0x1fU) + (IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_3__DOT__u_crc_parallel_crcw__DOT__reg_chunk_idx))) 
             < (IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_3__DOT__u_crc_parallel_crcw__DOT__w_valid_bit_cnt))
             ? ((__Vdfg_Regularize_1872 >> 0x0000001fU)
                 ? (0x04c11db7U ^ __Vdfg_Regularize_1969)
                 : __Vdfg_Regularize_1969) : __Vdfg_Regularize_1872));
    vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_3__DOT__u_crc_parallel_crcw__DOT__w_chunk_crc 
        = ((IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_3__DOT__u_crc_parallel_crcw__DOT__reg_augment)
            ? ((__Vdfg_Regularize_2095 >> 0x0000001fU)
                ? (1U | (0xfffffffeU & (0x04c11db6U 
                                        ^ (__Vdfg_Regularize_2095 
                                           << 1U))))
                : (__Vdfg_Regularize_2095 << 1U)) : 
           (((0x0000003fU & ((IData)(0x1fU) + (IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_3__DOT__u_crc_parallel_crcw__DOT__reg_chunk_idx))) 
             < (IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_3__DOT__u_crc_parallel_crcw__DOT__w_valid_bit_cnt))
             ? ((__Vdfg_Regularize_1935 >> 0x0000001fU)
                 ? (0x04c11db7U ^ __Vdfg_Regularize_2064)
                 : __Vdfg_Regularize_2064) : __Vdfg_Regularize_1935));
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
    vlSelf->m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_3__DOT__u_crc_parallel_crcw__DOT__reg_crc_state = VL_SCOPED_RAND_RESET_I(32, __VscopeHash, 13443014432761427644ull);
    vlSelf->m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_3__DOT__u_crc_parallel_crcw__DOT__reg_crc_output = VL_SCOPED_RAND_RESET_I(32, __VscopeHash, 13001463319406885967ull);
    vlSelf->m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_3__DOT__u_crc_parallel_crcw__DOT__reg_data = VL_SCOPED_RAND_RESET_I(32, __VscopeHash, 6671812663777553680ull);
    vlSelf->m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_3__DOT__u_crc_parallel_crcw__DOT__reg_keep = VL_SCOPED_RAND_RESET_I(4, __VscopeHash, 9762671663943597289ull);
    vlSelf->m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_3__DOT__u_crc_parallel_crcw__DOT__reg_chunk_idx = VL_SCOPED_RAND_RESET_I(6, __VscopeHash, 16723400831616142460ull);
    vlSelf->m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_3__DOT__u_crc_parallel_crcw__DOT__w_valid_bit_cnt = VL_SCOPED_RAND_RESET_I(6, __VscopeHash, 9014259169126088809ull);
    vlSelf->m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_3__DOT__u_crc_parallel_crcw__DOT__w_chunk_crc = VL_SCOPED_RAND_RESET_I(32, __VscopeHash, 2802181848208289838ull);
    vlSelf->m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_3__DOT__u_crc_parallel_crcw__DOT__reg_last = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 8720641888896107990ull);
    vlSelf->m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_3__DOT__u_crc_parallel_crcw__DOT__reg_busy = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 9651696453342168183ull);
    vlSelf->m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_3__DOT__u_crc_parallel_crcw__DOT__reg_augment = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 1151136491206911537ull);
    vlSelf->m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_3__DOT__u_crc_parallel_crcw__DOT__reg_crc_valid = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 12497723512836649804ull);
    vlSelf->m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_3__DOT__u_crc_parallel_crcw__DOT__reg_crc_state = VL_SCOPED_RAND_RESET_I(32, __VscopeHash, 6327515918761766800ull);
    vlSelf->m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_3__DOT__u_crc_parallel_crcw__DOT__reg_crc_output = VL_SCOPED_RAND_RESET_I(32, __VscopeHash, 1006719505201605607ull);
    vlSelf->m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_3__DOT__u_crc_parallel_crcw__DOT__reg_data = VL_SCOPED_RAND_RESET_I(32, __VscopeHash, 2219187603004058433ull);
    vlSelf->m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_3__DOT__u_crc_parallel_crcw__DOT__reg_keep = VL_SCOPED_RAND_RESET_I(4, __VscopeHash, 3553909975418494881ull);
    vlSelf->m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_3__DOT__u_crc_parallel_crcw__DOT__reg_chunk_idx = VL_SCOPED_RAND_RESET_I(6, __VscopeHash, 6193225356302704052ull);
    vlSelf->m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_3__DOT__u_crc_parallel_crcw__DOT__w_valid_bit_cnt = VL_SCOPED_RAND_RESET_I(6, __VscopeHash, 11234290391416748884ull);
    vlSelf->m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_3__DOT__u_crc_parallel_crcw__DOT__w_chunk_crc = VL_SCOPED_RAND_RESET_I(32, __VscopeHash, 1298101738632632859ull);
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
