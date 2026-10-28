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
    CData/*7:0*/ __Vdfg_Regularize_632;
    __Vdfg_Regularize_632 = 0;
    CData/*7:0*/ __Vdfg_Regularize_633;
    __Vdfg_Regularize_633 = 0;
    CData/*7:0*/ __Vdfg_Regularize_634;
    __Vdfg_Regularize_634 = 0;
    CData/*7:0*/ __Vdfg_Regularize_635;
    __Vdfg_Regularize_635 = 0;
    CData/*7:0*/ __Vdfg_Regularize_636;
    __Vdfg_Regularize_636 = 0;
    CData/*7:0*/ __Vdfg_Regularize_637;
    __Vdfg_Regularize_637 = 0;
    CData/*7:0*/ __Vdfg_Regularize_638;
    __Vdfg_Regularize_638 = 0;
    CData/*7:0*/ __Vdfg_Regularize_639;
    __Vdfg_Regularize_639 = 0;
    CData/*7:0*/ __Vdfg_Regularize_640;
    __Vdfg_Regularize_640 = 0;
    CData/*7:0*/ __Vdfg_Regularize_641;
    __Vdfg_Regularize_641 = 0;
    CData/*7:0*/ __Vdfg_Regularize_642;
    __Vdfg_Regularize_642 = 0;
    CData/*7:0*/ __Vdfg_Regularize_643;
    __Vdfg_Regularize_643 = 0;
    CData/*7:0*/ __Vdfg_Regularize_644;
    __Vdfg_Regularize_644 = 0;
    CData/*7:0*/ __Vdfg_Regularize_645;
    __Vdfg_Regularize_645 = 0;
    CData/*7:0*/ __Vdfg_Regularize_646;
    __Vdfg_Regularize_646 = 0;
    CData/*7:0*/ __Vdfg_Regularize_647;
    __Vdfg_Regularize_647 = 0;
    CData/*7:0*/ __Vdfg_Regularize_648;
    __Vdfg_Regularize_648 = 0;
    CData/*7:0*/ __Vdfg_Regularize_649;
    __Vdfg_Regularize_649 = 0;
    CData/*7:0*/ __Vdfg_Regularize_650;
    __Vdfg_Regularize_650 = 0;
    CData/*7:0*/ __Vdfg_Regularize_651;
    __Vdfg_Regularize_651 = 0;
    CData/*7:0*/ __Vdfg_Regularize_652;
    __Vdfg_Regularize_652 = 0;
    CData/*7:0*/ __Vdfg_Regularize_653;
    __Vdfg_Regularize_653 = 0;
    CData/*7:0*/ __Vdfg_Regularize_654;
    __Vdfg_Regularize_654 = 0;
    CData/*7:0*/ __Vdfg_Regularize_655;
    __Vdfg_Regularize_655 = 0;
    CData/*7:0*/ __Vdfg_Regularize_656;
    __Vdfg_Regularize_656 = 0;
    CData/*7:0*/ __Vdfg_Regularize_657;
    __Vdfg_Regularize_657 = 0;
    CData/*7:0*/ __Vdfg_Regularize_658;
    __Vdfg_Regularize_658 = 0;
    CData/*7:0*/ __Vdfg_Regularize_659;
    __Vdfg_Regularize_659 = 0;
    CData/*7:0*/ __Vdfg_Regularize_660;
    __Vdfg_Regularize_660 = 0;
    CData/*7:0*/ __Vdfg_Regularize_661;
    __Vdfg_Regularize_661 = 0;
    CData/*7:0*/ __Vdfg_Regularize_662;
    __Vdfg_Regularize_662 = 0;
    CData/*7:0*/ __Vdfg_Regularize_663;
    __Vdfg_Regularize_663 = 0;
    CData/*7:0*/ __Vdfg_Regularize_664;
    __Vdfg_Regularize_664 = 0;
    CData/*7:0*/ __Vdfg_Regularize_665;
    __Vdfg_Regularize_665 = 0;
    CData/*7:0*/ __Vdfg_Regularize_666;
    __Vdfg_Regularize_666 = 0;
    CData/*7:0*/ __Vdfg_Regularize_667;
    __Vdfg_Regularize_667 = 0;
    CData/*7:0*/ __Vdfg_Regularize_668;
    __Vdfg_Regularize_668 = 0;
    CData/*7:0*/ __Vdfg_Regularize_669;
    __Vdfg_Regularize_669 = 0;
    CData/*7:0*/ __Vdfg_Regularize_670;
    __Vdfg_Regularize_670 = 0;
    CData/*7:0*/ __Vdfg_Regularize_671;
    __Vdfg_Regularize_671 = 0;
    CData/*7:0*/ __Vdfg_Regularize_672;
    __Vdfg_Regularize_672 = 0;
    CData/*7:0*/ __Vdfg_Regularize_673;
    __Vdfg_Regularize_673 = 0;
    CData/*7:0*/ __Vdfg_Regularize_674;
    __Vdfg_Regularize_674 = 0;
    CData/*7:0*/ __Vdfg_Regularize_675;
    __Vdfg_Regularize_675 = 0;
    CData/*7:0*/ __Vdfg_Regularize_676;
    __Vdfg_Regularize_676 = 0;
    CData/*7:0*/ __Vdfg_Regularize_677;
    __Vdfg_Regularize_677 = 0;
    CData/*7:0*/ __Vdfg_Regularize_678;
    __Vdfg_Regularize_678 = 0;
    CData/*7:0*/ __Vdfg_Regularize_679;
    __Vdfg_Regularize_679 = 0;
    CData/*7:0*/ __Vdfg_Regularize_680;
    __Vdfg_Regularize_680 = 0;
    CData/*7:0*/ __Vdfg_Regularize_681;
    __Vdfg_Regularize_681 = 0;
    CData/*7:0*/ __Vdfg_Regularize_682;
    __Vdfg_Regularize_682 = 0;
    CData/*7:0*/ __Vdfg_Regularize_683;
    __Vdfg_Regularize_683 = 0;
    CData/*7:0*/ __Vdfg_Regularize_684;
    __Vdfg_Regularize_684 = 0;
    CData/*7:0*/ __Vdfg_Regularize_685;
    __Vdfg_Regularize_685 = 0;
    CData/*7:0*/ __Vdfg_Regularize_686;
    __Vdfg_Regularize_686 = 0;
    CData/*7:0*/ __Vdfg_Regularize_687;
    __Vdfg_Regularize_687 = 0;
    CData/*7:0*/ __Vdfg_Regularize_688;
    __Vdfg_Regularize_688 = 0;
    CData/*7:0*/ __Vdfg_Regularize_689;
    __Vdfg_Regularize_689 = 0;
    CData/*7:0*/ __Vdfg_Regularize_690;
    __Vdfg_Regularize_690 = 0;
    CData/*7:0*/ __Vdfg_Regularize_691;
    __Vdfg_Regularize_691 = 0;
    CData/*7:0*/ __Vdfg_Regularize_692;
    __Vdfg_Regularize_692 = 0;
    CData/*7:0*/ __Vdfg_Regularize_693;
    __Vdfg_Regularize_693 = 0;
    CData/*7:0*/ __Vdfg_Regularize_694;
    __Vdfg_Regularize_694 = 0;
    CData/*7:0*/ __Vdfg_Regularize_695;
    __Vdfg_Regularize_695 = 0;
    CData/*7:0*/ __Vdfg_Regularize_696;
    __Vdfg_Regularize_696 = 0;
    CData/*7:0*/ __Vdfg_Regularize_697;
    __Vdfg_Regularize_697 = 0;
    CData/*7:0*/ __Vdfg_Regularize_698;
    __Vdfg_Regularize_698 = 0;
    CData/*7:0*/ __Vdfg_Regularize_707;
    __Vdfg_Regularize_707 = 0;
    CData/*7:0*/ __Vdfg_Regularize_708;
    __Vdfg_Regularize_708 = 0;
    CData/*7:0*/ __Vdfg_Regularize_709;
    __Vdfg_Regularize_709 = 0;
    CData/*7:0*/ __Vdfg_Regularize_710;
    __Vdfg_Regularize_710 = 0;
    CData/*7:0*/ __Vdfg_Regularize_711;
    __Vdfg_Regularize_711 = 0;
    CData/*7:0*/ __Vdfg_Regularize_712;
    __Vdfg_Regularize_712 = 0;
    CData/*7:0*/ __Vdfg_Regularize_713;
    __Vdfg_Regularize_713 = 0;
    CData/*7:0*/ __Vdfg_Regularize_714;
    __Vdfg_Regularize_714 = 0;
    CData/*7:0*/ __Vdfg_Regularize_715;
    __Vdfg_Regularize_715 = 0;
    CData/*7:0*/ __Vdfg_Regularize_716;
    __Vdfg_Regularize_716 = 0;
    CData/*7:0*/ __Vdfg_Regularize_717;
    __Vdfg_Regularize_717 = 0;
    CData/*7:0*/ __Vdfg_Regularize_718;
    __Vdfg_Regularize_718 = 0;
    CData/*7:0*/ __Vdfg_Regularize_719;
    __Vdfg_Regularize_719 = 0;
    CData/*7:0*/ __Vdfg_Regularize_720;
    __Vdfg_Regularize_720 = 0;
    CData/*7:0*/ __Vdfg_Regularize_721;
    __Vdfg_Regularize_721 = 0;
    CData/*7:0*/ __Vdfg_Regularize_722;
    __Vdfg_Regularize_722 = 0;
    CData/*7:0*/ __Vdfg_Regularize_723;
    __Vdfg_Regularize_723 = 0;
    CData/*7:0*/ __Vdfg_Regularize_724;
    __Vdfg_Regularize_724 = 0;
    CData/*7:0*/ __Vdfg_Regularize_725;
    __Vdfg_Regularize_725 = 0;
    CData/*7:0*/ __Vdfg_Regularize_726;
    __Vdfg_Regularize_726 = 0;
    CData/*7:0*/ __Vdfg_Regularize_727;
    __Vdfg_Regularize_727 = 0;
    CData/*7:0*/ __Vdfg_Regularize_728;
    __Vdfg_Regularize_728 = 0;
    CData/*7:0*/ __Vdfg_Regularize_729;
    __Vdfg_Regularize_729 = 0;
    CData/*7:0*/ __Vdfg_Regularize_730;
    __Vdfg_Regularize_730 = 0;
    CData/*7:0*/ __Vdfg_Regularize_731;
    __Vdfg_Regularize_731 = 0;
    CData/*7:0*/ __Vdfg_Regularize_732;
    __Vdfg_Regularize_732 = 0;
    CData/*7:0*/ __Vdfg_Regularize_733;
    __Vdfg_Regularize_733 = 0;
    CData/*7:0*/ __Vdfg_Regularize_734;
    __Vdfg_Regularize_734 = 0;
    CData/*7:0*/ __Vdfg_Regularize_735;
    __Vdfg_Regularize_735 = 0;
    CData/*7:0*/ __Vdfg_Regularize_736;
    __Vdfg_Regularize_736 = 0;
    CData/*7:0*/ __Vdfg_Regularize_737;
    __Vdfg_Regularize_737 = 0;
    CData/*7:0*/ __Vdfg_Regularize_738;
    __Vdfg_Regularize_738 = 0;
    CData/*7:0*/ __Vdfg_Regularize_739;
    __Vdfg_Regularize_739 = 0;
    CData/*7:0*/ __Vdfg_Regularize_740;
    __Vdfg_Regularize_740 = 0;
    CData/*7:0*/ __Vdfg_Regularize_741;
    __Vdfg_Regularize_741 = 0;
    CData/*7:0*/ __Vdfg_Regularize_742;
    __Vdfg_Regularize_742 = 0;
    CData/*7:0*/ __Vdfg_Regularize_743;
    __Vdfg_Regularize_743 = 0;
    CData/*7:0*/ __Vdfg_Regularize_744;
    __Vdfg_Regularize_744 = 0;
    CData/*7:0*/ __Vdfg_Regularize_745;
    __Vdfg_Regularize_745 = 0;
    CData/*7:0*/ __Vdfg_Regularize_746;
    __Vdfg_Regularize_746 = 0;
    CData/*7:0*/ __Vdfg_Regularize_747;
    __Vdfg_Regularize_747 = 0;
    CData/*7:0*/ __Vdfg_Regularize_748;
    __Vdfg_Regularize_748 = 0;
    CData/*7:0*/ __Vdfg_Regularize_749;
    __Vdfg_Regularize_749 = 0;
    CData/*7:0*/ __Vdfg_Regularize_750;
    __Vdfg_Regularize_750 = 0;
    CData/*7:0*/ __Vdfg_Regularize_751;
    __Vdfg_Regularize_751 = 0;
    CData/*7:0*/ __Vdfg_Regularize_752;
    __Vdfg_Regularize_752 = 0;
    CData/*7:0*/ __Vdfg_Regularize_753;
    __Vdfg_Regularize_753 = 0;
    CData/*7:0*/ __Vdfg_Regularize_754;
    __Vdfg_Regularize_754 = 0;
    CData/*7:0*/ __Vdfg_Regularize_755;
    __Vdfg_Regularize_755 = 0;
    CData/*7:0*/ __Vdfg_Regularize_756;
    __Vdfg_Regularize_756 = 0;
    CData/*7:0*/ __Vdfg_Regularize_757;
    __Vdfg_Regularize_757 = 0;
    CData/*7:0*/ __Vdfg_Regularize_758;
    __Vdfg_Regularize_758 = 0;
    CData/*7:0*/ __Vdfg_Regularize_759;
    __Vdfg_Regularize_759 = 0;
    CData/*7:0*/ __Vdfg_Regularize_760;
    __Vdfg_Regularize_760 = 0;
    CData/*7:0*/ __Vdfg_Regularize_761;
    __Vdfg_Regularize_761 = 0;
    CData/*7:0*/ __Vdfg_Regularize_762;
    __Vdfg_Regularize_762 = 0;
    CData/*7:0*/ __Vdfg_Regularize_763;
    __Vdfg_Regularize_763 = 0;
    CData/*7:0*/ __Vdfg_Regularize_764;
    __Vdfg_Regularize_764 = 0;
    CData/*7:0*/ __Vdfg_Regularize_765;
    __Vdfg_Regularize_765 = 0;
    CData/*7:0*/ __Vdfg_Regularize_766;
    __Vdfg_Regularize_766 = 0;
    CData/*7:0*/ __Vdfg_Regularize_767;
    __Vdfg_Regularize_767 = 0;
    CData/*7:0*/ __Vdfg_Regularize_768;
    __Vdfg_Regularize_768 = 0;
    CData/*7:0*/ __Vdfg_Regularize_769;
    __Vdfg_Regularize_769 = 0;
    CData/*7:0*/ __Vdfg_Regularize_770;
    __Vdfg_Regularize_770 = 0;
    CData/*7:0*/ __Vdfg_Regularize_771;
    __Vdfg_Regularize_771 = 0;
    CData/*7:0*/ __Vdfg_Regularize_772;
    __Vdfg_Regularize_772 = 0;
    CData/*7:0*/ __Vdfg_Regularize_773;
    __Vdfg_Regularize_773 = 0;
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
                              & ((IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__reg_check_crc_ref) 
                                 == (IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_4__DOT__u_crc_parallel_full__DOT__reg_crc_output)));
    __Vdfg_Regularize_632 = ((0x000000feU & ((IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_4__DOT__u_crc_parallel_full__DOT__reg_crc_state) 
                                             << 1U)) 
                             | (1U & (vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_4__DOT__u_crc_parallel_full__DOT__reg_data 
                                      >> 0x00000018U)));
    __Vdfg_Regularize_707 = ((0x000000feU & ((IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_4__DOT__u_crc_parallel_full__DOT__reg_crc_state) 
                                             << 1U)) 
                             | (1U & (vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_4__DOT__u_crc_parallel_full__DOT__reg_data 
                                      >> 0x00000018U)));
    __Vdfg_Regularize_633 = ((0x00000080U & (IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_4__DOT__u_crc_parallel_full__DOT__reg_crc_state))
                              ? (7U ^ (IData)(__Vdfg_Regularize_632))
                              : (IData)(__Vdfg_Regularize_632));
    __Vdfg_Regularize_708 = ((0x00000080U & (IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_4__DOT__u_crc_parallel_full__DOT__reg_crc_state))
                              ? (7U ^ (IData)(__Vdfg_Regularize_707))
                              : (IData)(__Vdfg_Regularize_707));
    __Vdfg_Regularize_634 = ((0x000000feU & ((IData)(__Vdfg_Regularize_633) 
                                             << 1U)) 
                             | (1U & (vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_4__DOT__u_crc_parallel_full__DOT__reg_data 
                                      >> 0x00000019U)));
    __Vdfg_Regularize_709 = ((0x000000feU & ((IData)(__Vdfg_Regularize_708) 
                                             << 1U)) 
                             | (1U & (vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_4__DOT__u_crc_parallel_full__DOT__reg_data 
                                      >> 0x00000019U)));
    __Vdfg_Regularize_635 = ((0x00000080U & (IData)(__Vdfg_Regularize_633))
                              ? (7U ^ (IData)(__Vdfg_Regularize_634))
                              : (IData)(__Vdfg_Regularize_634));
    __Vdfg_Regularize_710 = ((0x00000080U & (IData)(__Vdfg_Regularize_708))
                              ? (7U ^ (IData)(__Vdfg_Regularize_709))
                              : (IData)(__Vdfg_Regularize_709));
    __Vdfg_Regularize_636 = ((0x000000feU & ((IData)(__Vdfg_Regularize_635) 
                                             << 1U)) 
                             | (1U & (vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_4__DOT__u_crc_parallel_full__DOT__reg_data 
                                      >> 0x0000001aU)));
    __Vdfg_Regularize_711 = ((0x000000feU & ((IData)(__Vdfg_Regularize_710) 
                                             << 1U)) 
                             | (1U & (vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_4__DOT__u_crc_parallel_full__DOT__reg_data 
                                      >> 0x0000001aU)));
    __Vdfg_Regularize_637 = ((0x00000080U & (IData)(__Vdfg_Regularize_635))
                              ? (7U ^ (IData)(__Vdfg_Regularize_636))
                              : (IData)(__Vdfg_Regularize_636));
    __Vdfg_Regularize_712 = ((0x00000080U & (IData)(__Vdfg_Regularize_710))
                              ? (7U ^ (IData)(__Vdfg_Regularize_711))
                              : (IData)(__Vdfg_Regularize_711));
    __Vdfg_Regularize_638 = ((0x000000feU & ((IData)(__Vdfg_Regularize_637) 
                                             << 1U)) 
                             | (1U & (vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_4__DOT__u_crc_parallel_full__DOT__reg_data 
                                      >> 0x0000001bU)));
    __Vdfg_Regularize_713 = ((0x000000feU & ((IData)(__Vdfg_Regularize_712) 
                                             << 1U)) 
                             | (1U & (vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_4__DOT__u_crc_parallel_full__DOT__reg_data 
                                      >> 0x0000001bU)));
    __Vdfg_Regularize_639 = ((0x00000080U & (IData)(__Vdfg_Regularize_637))
                              ? (7U ^ (IData)(__Vdfg_Regularize_638))
                              : (IData)(__Vdfg_Regularize_638));
    __Vdfg_Regularize_714 = ((0x00000080U & (IData)(__Vdfg_Regularize_712))
                              ? (7U ^ (IData)(__Vdfg_Regularize_713))
                              : (IData)(__Vdfg_Regularize_713));
    __Vdfg_Regularize_640 = ((0x000000feU & ((IData)(__Vdfg_Regularize_639) 
                                             << 1U)) 
                             | (1U & (vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_4__DOT__u_crc_parallel_full__DOT__reg_data 
                                      >> 0x0000001cU)));
    __Vdfg_Regularize_715 = ((0x000000feU & ((IData)(__Vdfg_Regularize_714) 
                                             << 1U)) 
                             | (1U & (vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_4__DOT__u_crc_parallel_full__DOT__reg_data 
                                      >> 0x0000001cU)));
    __Vdfg_Regularize_641 = ((0x00000080U & (IData)(__Vdfg_Regularize_639))
                              ? (7U ^ (IData)(__Vdfg_Regularize_640))
                              : (IData)(__Vdfg_Regularize_640));
    __Vdfg_Regularize_716 = ((0x00000080U & (IData)(__Vdfg_Regularize_714))
                              ? (7U ^ (IData)(__Vdfg_Regularize_715))
                              : (IData)(__Vdfg_Regularize_715));
    __Vdfg_Regularize_642 = ((0x000000feU & ((IData)(__Vdfg_Regularize_641) 
                                             << 1U)) 
                             | (1U & (vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_4__DOT__u_crc_parallel_full__DOT__reg_data 
                                      >> 0x0000001dU)));
    __Vdfg_Regularize_717 = ((0x000000feU & ((IData)(__Vdfg_Regularize_716) 
                                             << 1U)) 
                             | (1U & (vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_4__DOT__u_crc_parallel_full__DOT__reg_data 
                                      >> 0x0000001dU)));
    __Vdfg_Regularize_643 = ((0x00000080U & (IData)(__Vdfg_Regularize_641))
                              ? (7U ^ (IData)(__Vdfg_Regularize_642))
                              : (IData)(__Vdfg_Regularize_642));
    __Vdfg_Regularize_718 = ((0x00000080U & (IData)(__Vdfg_Regularize_716))
                              ? (7U ^ (IData)(__Vdfg_Regularize_717))
                              : (IData)(__Vdfg_Regularize_717));
    __Vdfg_Regularize_644 = ((0x000000feU & ((IData)(__Vdfg_Regularize_643) 
                                             << 1U)) 
                             | (1U & (vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_4__DOT__u_crc_parallel_full__DOT__reg_data 
                                      >> 0x0000001eU)));
    __Vdfg_Regularize_719 = ((0x000000feU & ((IData)(__Vdfg_Regularize_718) 
                                             << 1U)) 
                             | (1U & (vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_4__DOT__u_crc_parallel_full__DOT__reg_data 
                                      >> 0x0000001eU)));
    __Vdfg_Regularize_645 = ((0x00000080U & (IData)(__Vdfg_Regularize_643))
                              ? (7U ^ (IData)(__Vdfg_Regularize_644))
                              : (IData)(__Vdfg_Regularize_644));
    __Vdfg_Regularize_720 = ((0x00000080U & (IData)(__Vdfg_Regularize_718))
                              ? (7U ^ (IData)(__Vdfg_Regularize_719))
                              : (IData)(__Vdfg_Regularize_719));
    __Vdfg_Regularize_646 = ((0x000000feU & ((IData)(__Vdfg_Regularize_645) 
                                             << 1U)) 
                             | (vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_4__DOT__u_crc_parallel_full__DOT__reg_data 
                                >> 0x0000001fU));
    __Vdfg_Regularize_721 = ((0x000000feU & ((IData)(__Vdfg_Regularize_720) 
                                             << 1U)) 
                             | (vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_4__DOT__u_crc_parallel_full__DOT__reg_data 
                                >> 0x0000001fU));
    __Vdfg_Regularize_624 = ((8U & (IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_4__DOT__u_crc_parallel_full__DOT__reg_keep))
                              ? ((0x00000080U & (IData)(__Vdfg_Regularize_645))
                                  ? (7U ^ (IData)(__Vdfg_Regularize_646))
                                  : (IData)(__Vdfg_Regularize_646))
                              : (IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_4__DOT__u_crc_parallel_full__DOT__reg_crc_state));
    __Vdfg_Regularize_628 = ((8U & (IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_4__DOT__u_crc_parallel_full__DOT__reg_keep))
                              ? ((0x00000080U & (IData)(__Vdfg_Regularize_720))
                                  ? (7U ^ (IData)(__Vdfg_Regularize_721))
                                  : (IData)(__Vdfg_Regularize_721))
                              : (IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_4__DOT__u_crc_parallel_full__DOT__reg_crc_state));
    __Vdfg_Regularize_647 = ((0x000000feU & ((IData)(__Vdfg_Regularize_624) 
                                             << 1U)) 
                             | (1U & (vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_4__DOT__u_crc_parallel_full__DOT__reg_data 
                                      >> 0x00000010U)));
    __Vdfg_Regularize_722 = ((0x000000feU & ((IData)(__Vdfg_Regularize_628) 
                                             << 1U)) 
                             | (1U & (vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_4__DOT__u_crc_parallel_full__DOT__reg_data 
                                      >> 0x00000010U)));
    __Vdfg_Regularize_648 = ((0x00000080U & (IData)(__Vdfg_Regularize_624))
                              ? (7U ^ (IData)(__Vdfg_Regularize_647))
                              : (IData)(__Vdfg_Regularize_647));
    __Vdfg_Regularize_723 = ((0x00000080U & (IData)(__Vdfg_Regularize_628))
                              ? (7U ^ (IData)(__Vdfg_Regularize_722))
                              : (IData)(__Vdfg_Regularize_722));
    __Vdfg_Regularize_649 = ((0x000000feU & ((IData)(__Vdfg_Regularize_648) 
                                             << 1U)) 
                             | (1U & (vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_4__DOT__u_crc_parallel_full__DOT__reg_data 
                                      >> 0x00000011U)));
    __Vdfg_Regularize_724 = ((0x000000feU & ((IData)(__Vdfg_Regularize_723) 
                                             << 1U)) 
                             | (1U & (vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_4__DOT__u_crc_parallel_full__DOT__reg_data 
                                      >> 0x00000011U)));
    __Vdfg_Regularize_650 = ((0x00000080U & (IData)(__Vdfg_Regularize_648))
                              ? (7U ^ (IData)(__Vdfg_Regularize_649))
                              : (IData)(__Vdfg_Regularize_649));
    __Vdfg_Regularize_725 = ((0x00000080U & (IData)(__Vdfg_Regularize_723))
                              ? (7U ^ (IData)(__Vdfg_Regularize_724))
                              : (IData)(__Vdfg_Regularize_724));
    __Vdfg_Regularize_651 = ((0x000000feU & ((IData)(__Vdfg_Regularize_650) 
                                             << 1U)) 
                             | (1U & (vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_4__DOT__u_crc_parallel_full__DOT__reg_data 
                                      >> 0x00000012U)));
    __Vdfg_Regularize_726 = ((0x000000feU & ((IData)(__Vdfg_Regularize_725) 
                                             << 1U)) 
                             | (1U & (vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_4__DOT__u_crc_parallel_full__DOT__reg_data 
                                      >> 0x00000012U)));
    __Vdfg_Regularize_652 = ((0x00000080U & (IData)(__Vdfg_Regularize_650))
                              ? (7U ^ (IData)(__Vdfg_Regularize_651))
                              : (IData)(__Vdfg_Regularize_651));
    __Vdfg_Regularize_727 = ((0x00000080U & (IData)(__Vdfg_Regularize_725))
                              ? (7U ^ (IData)(__Vdfg_Regularize_726))
                              : (IData)(__Vdfg_Regularize_726));
    __Vdfg_Regularize_653 = ((0x000000feU & ((IData)(__Vdfg_Regularize_652) 
                                             << 1U)) 
                             | (1U & (vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_4__DOT__u_crc_parallel_full__DOT__reg_data 
                                      >> 0x00000013U)));
    __Vdfg_Regularize_728 = ((0x000000feU & ((IData)(__Vdfg_Regularize_727) 
                                             << 1U)) 
                             | (1U & (vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_4__DOT__u_crc_parallel_full__DOT__reg_data 
                                      >> 0x00000013U)));
    __Vdfg_Regularize_654 = ((0x00000080U & (IData)(__Vdfg_Regularize_652))
                              ? (7U ^ (IData)(__Vdfg_Regularize_653))
                              : (IData)(__Vdfg_Regularize_653));
    __Vdfg_Regularize_729 = ((0x00000080U & (IData)(__Vdfg_Regularize_727))
                              ? (7U ^ (IData)(__Vdfg_Regularize_728))
                              : (IData)(__Vdfg_Regularize_728));
    __Vdfg_Regularize_655 = ((0x000000feU & ((IData)(__Vdfg_Regularize_654) 
                                             << 1U)) 
                             | (1U & (vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_4__DOT__u_crc_parallel_full__DOT__reg_data 
                                      >> 0x00000014U)));
    __Vdfg_Regularize_730 = ((0x000000feU & ((IData)(__Vdfg_Regularize_729) 
                                             << 1U)) 
                             | (1U & (vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_4__DOT__u_crc_parallel_full__DOT__reg_data 
                                      >> 0x00000014U)));
    __Vdfg_Regularize_656 = ((0x00000080U & (IData)(__Vdfg_Regularize_654))
                              ? (7U ^ (IData)(__Vdfg_Regularize_655))
                              : (IData)(__Vdfg_Regularize_655));
    __Vdfg_Regularize_731 = ((0x00000080U & (IData)(__Vdfg_Regularize_729))
                              ? (7U ^ (IData)(__Vdfg_Regularize_730))
                              : (IData)(__Vdfg_Regularize_730));
    __Vdfg_Regularize_657 = ((0x000000feU & ((IData)(__Vdfg_Regularize_656) 
                                             << 1U)) 
                             | (1U & (vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_4__DOT__u_crc_parallel_full__DOT__reg_data 
                                      >> 0x00000015U)));
    __Vdfg_Regularize_732 = ((0x000000feU & ((IData)(__Vdfg_Regularize_731) 
                                             << 1U)) 
                             | (1U & (vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_4__DOT__u_crc_parallel_full__DOT__reg_data 
                                      >> 0x00000015U)));
    __Vdfg_Regularize_658 = ((0x00000080U & (IData)(__Vdfg_Regularize_656))
                              ? (7U ^ (IData)(__Vdfg_Regularize_657))
                              : (IData)(__Vdfg_Regularize_657));
    __Vdfg_Regularize_733 = ((0x00000080U & (IData)(__Vdfg_Regularize_731))
                              ? (7U ^ (IData)(__Vdfg_Regularize_732))
                              : (IData)(__Vdfg_Regularize_732));
    __Vdfg_Regularize_659 = ((0x000000feU & ((IData)(__Vdfg_Regularize_658) 
                                             << 1U)) 
                             | (1U & (vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_4__DOT__u_crc_parallel_full__DOT__reg_data 
                                      >> 0x00000016U)));
    __Vdfg_Regularize_734 = ((0x000000feU & ((IData)(__Vdfg_Regularize_733) 
                                             << 1U)) 
                             | (1U & (vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_4__DOT__u_crc_parallel_full__DOT__reg_data 
                                      >> 0x00000016U)));
    __Vdfg_Regularize_660 = ((0x00000080U & (IData)(__Vdfg_Regularize_658))
                              ? (7U ^ (IData)(__Vdfg_Regularize_659))
                              : (IData)(__Vdfg_Regularize_659));
    __Vdfg_Regularize_735 = ((0x00000080U & (IData)(__Vdfg_Regularize_733))
                              ? (7U ^ (IData)(__Vdfg_Regularize_734))
                              : (IData)(__Vdfg_Regularize_734));
    __Vdfg_Regularize_661 = ((0x000000feU & ((IData)(__Vdfg_Regularize_660) 
                                             << 1U)) 
                             | (1U & (vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_4__DOT__u_crc_parallel_full__DOT__reg_data 
                                      >> 0x00000017U)));
    __Vdfg_Regularize_736 = ((0x000000feU & ((IData)(__Vdfg_Regularize_735) 
                                             << 1U)) 
                             | (1U & (vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_4__DOT__u_crc_parallel_full__DOT__reg_data 
                                      >> 0x00000017U)));
    __Vdfg_Regularize_625 = ((4U & (IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_4__DOT__u_crc_parallel_full__DOT__reg_keep))
                              ? ((0x00000080U & (IData)(__Vdfg_Regularize_660))
                                  ? (7U ^ (IData)(__Vdfg_Regularize_661))
                                  : (IData)(__Vdfg_Regularize_661))
                              : (IData)(__Vdfg_Regularize_624));
    __Vdfg_Regularize_629 = ((4U & (IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_4__DOT__u_crc_parallel_full__DOT__reg_keep))
                              ? ((0x00000080U & (IData)(__Vdfg_Regularize_735))
                                  ? (7U ^ (IData)(__Vdfg_Regularize_736))
                                  : (IData)(__Vdfg_Regularize_736))
                              : (IData)(__Vdfg_Regularize_628));
    __Vdfg_Regularize_662 = ((0x000000feU & ((IData)(__Vdfg_Regularize_625) 
                                             << 1U)) 
                             | (1U & (vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_4__DOT__u_crc_parallel_full__DOT__reg_data 
                                      >> 8U)));
    __Vdfg_Regularize_737 = ((0x000000feU & ((IData)(__Vdfg_Regularize_629) 
                                             << 1U)) 
                             | (1U & (vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_4__DOT__u_crc_parallel_full__DOT__reg_data 
                                      >> 8U)));
    __Vdfg_Regularize_663 = ((0x00000080U & (IData)(__Vdfg_Regularize_625))
                              ? (7U ^ (IData)(__Vdfg_Regularize_662))
                              : (IData)(__Vdfg_Regularize_662));
    __Vdfg_Regularize_738 = ((0x00000080U & (IData)(__Vdfg_Regularize_629))
                              ? (7U ^ (IData)(__Vdfg_Regularize_737))
                              : (IData)(__Vdfg_Regularize_737));
    __Vdfg_Regularize_664 = ((0x000000feU & ((IData)(__Vdfg_Regularize_663) 
                                             << 1U)) 
                             | (1U & (vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_4__DOT__u_crc_parallel_full__DOT__reg_data 
                                      >> 9U)));
    __Vdfg_Regularize_739 = ((0x000000feU & ((IData)(__Vdfg_Regularize_738) 
                                             << 1U)) 
                             | (1U & (vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_4__DOT__u_crc_parallel_full__DOT__reg_data 
                                      >> 9U)));
    __Vdfg_Regularize_665 = ((0x00000080U & (IData)(__Vdfg_Regularize_663))
                              ? (7U ^ (IData)(__Vdfg_Regularize_664))
                              : (IData)(__Vdfg_Regularize_664));
    __Vdfg_Regularize_740 = ((0x00000080U & (IData)(__Vdfg_Regularize_738))
                              ? (7U ^ (IData)(__Vdfg_Regularize_739))
                              : (IData)(__Vdfg_Regularize_739));
    __Vdfg_Regularize_666 = ((0x000000feU & ((IData)(__Vdfg_Regularize_665) 
                                             << 1U)) 
                             | (1U & (vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_4__DOT__u_crc_parallel_full__DOT__reg_data 
                                      >> 0x0000000aU)));
    __Vdfg_Regularize_741 = ((0x000000feU & ((IData)(__Vdfg_Regularize_740) 
                                             << 1U)) 
                             | (1U & (vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_4__DOT__u_crc_parallel_full__DOT__reg_data 
                                      >> 0x0000000aU)));
    __Vdfg_Regularize_667 = ((0x00000080U & (IData)(__Vdfg_Regularize_665))
                              ? (7U ^ (IData)(__Vdfg_Regularize_666))
                              : (IData)(__Vdfg_Regularize_666));
    __Vdfg_Regularize_742 = ((0x00000080U & (IData)(__Vdfg_Regularize_740))
                              ? (7U ^ (IData)(__Vdfg_Regularize_741))
                              : (IData)(__Vdfg_Regularize_741));
    __Vdfg_Regularize_668 = ((0x000000feU & ((IData)(__Vdfg_Regularize_667) 
                                             << 1U)) 
                             | (1U & (vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_4__DOT__u_crc_parallel_full__DOT__reg_data 
                                      >> 0x0000000bU)));
    __Vdfg_Regularize_743 = ((0x000000feU & ((IData)(__Vdfg_Regularize_742) 
                                             << 1U)) 
                             | (1U & (vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_4__DOT__u_crc_parallel_full__DOT__reg_data 
                                      >> 0x0000000bU)));
    __Vdfg_Regularize_669 = ((0x00000080U & (IData)(__Vdfg_Regularize_667))
                              ? (7U ^ (IData)(__Vdfg_Regularize_668))
                              : (IData)(__Vdfg_Regularize_668));
    __Vdfg_Regularize_744 = ((0x00000080U & (IData)(__Vdfg_Regularize_742))
                              ? (7U ^ (IData)(__Vdfg_Regularize_743))
                              : (IData)(__Vdfg_Regularize_743));
    __Vdfg_Regularize_670 = ((0x000000feU & ((IData)(__Vdfg_Regularize_669) 
                                             << 1U)) 
                             | (1U & (vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_4__DOT__u_crc_parallel_full__DOT__reg_data 
                                      >> 0x0000000cU)));
    __Vdfg_Regularize_745 = ((0x000000feU & ((IData)(__Vdfg_Regularize_744) 
                                             << 1U)) 
                             | (1U & (vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_4__DOT__u_crc_parallel_full__DOT__reg_data 
                                      >> 0x0000000cU)));
    __Vdfg_Regularize_671 = ((0x00000080U & (IData)(__Vdfg_Regularize_669))
                              ? (7U ^ (IData)(__Vdfg_Regularize_670))
                              : (IData)(__Vdfg_Regularize_670));
    __Vdfg_Regularize_746 = ((0x00000080U & (IData)(__Vdfg_Regularize_744))
                              ? (7U ^ (IData)(__Vdfg_Regularize_745))
                              : (IData)(__Vdfg_Regularize_745));
    __Vdfg_Regularize_672 = ((0x000000feU & ((IData)(__Vdfg_Regularize_671) 
                                             << 1U)) 
                             | (1U & (vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_4__DOT__u_crc_parallel_full__DOT__reg_data 
                                      >> 0x0000000dU)));
    __Vdfg_Regularize_747 = ((0x000000feU & ((IData)(__Vdfg_Regularize_746) 
                                             << 1U)) 
                             | (1U & (vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_4__DOT__u_crc_parallel_full__DOT__reg_data 
                                      >> 0x0000000dU)));
    __Vdfg_Regularize_673 = ((0x00000080U & (IData)(__Vdfg_Regularize_671))
                              ? (7U ^ (IData)(__Vdfg_Regularize_672))
                              : (IData)(__Vdfg_Regularize_672));
    __Vdfg_Regularize_748 = ((0x00000080U & (IData)(__Vdfg_Regularize_746))
                              ? (7U ^ (IData)(__Vdfg_Regularize_747))
                              : (IData)(__Vdfg_Regularize_747));
    __Vdfg_Regularize_674 = ((0x000000feU & ((IData)(__Vdfg_Regularize_673) 
                                             << 1U)) 
                             | (1U & (vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_4__DOT__u_crc_parallel_full__DOT__reg_data 
                                      >> 0x0000000eU)));
    __Vdfg_Regularize_749 = ((0x000000feU & ((IData)(__Vdfg_Regularize_748) 
                                             << 1U)) 
                             | (1U & (vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_4__DOT__u_crc_parallel_full__DOT__reg_data 
                                      >> 0x0000000eU)));
    __Vdfg_Regularize_675 = ((0x00000080U & (IData)(__Vdfg_Regularize_673))
                              ? (7U ^ (IData)(__Vdfg_Regularize_674))
                              : (IData)(__Vdfg_Regularize_674));
    __Vdfg_Regularize_750 = ((0x00000080U & (IData)(__Vdfg_Regularize_748))
                              ? (7U ^ (IData)(__Vdfg_Regularize_749))
                              : (IData)(__Vdfg_Regularize_749));
    __Vdfg_Regularize_676 = ((0x000000feU & ((IData)(__Vdfg_Regularize_675) 
                                             << 1U)) 
                             | (1U & (vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_4__DOT__u_crc_parallel_full__DOT__reg_data 
                                      >> 0x0000000fU)));
    __Vdfg_Regularize_751 = ((0x000000feU & ((IData)(__Vdfg_Regularize_750) 
                                             << 1U)) 
                             | (1U & (vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_4__DOT__u_crc_parallel_full__DOT__reg_data 
                                      >> 0x0000000fU)));
    __Vdfg_Regularize_626 = ((2U & (IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_4__DOT__u_crc_parallel_full__DOT__reg_keep))
                              ? ((0x00000080U & (IData)(__Vdfg_Regularize_675))
                                  ? (7U ^ (IData)(__Vdfg_Regularize_676))
                                  : (IData)(__Vdfg_Regularize_676))
                              : (IData)(__Vdfg_Regularize_625));
    __Vdfg_Regularize_630 = ((2U & (IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_4__DOT__u_crc_parallel_full__DOT__reg_keep))
                              ? ((0x00000080U & (IData)(__Vdfg_Regularize_750))
                                  ? (7U ^ (IData)(__Vdfg_Regularize_751))
                                  : (IData)(__Vdfg_Regularize_751))
                              : (IData)(__Vdfg_Regularize_629));
    __Vdfg_Regularize_677 = ((0x000000feU & ((IData)(__Vdfg_Regularize_626) 
                                             << 1U)) 
                             | (1U & vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_4__DOT__u_crc_parallel_full__DOT__reg_data));
    __Vdfg_Regularize_752 = ((0x000000feU & ((IData)(__Vdfg_Regularize_630) 
                                             << 1U)) 
                             | (1U & vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_4__DOT__u_crc_parallel_full__DOT__reg_data));
    __Vdfg_Regularize_678 = ((0x00000080U & (IData)(__Vdfg_Regularize_626))
                              ? (7U ^ (IData)(__Vdfg_Regularize_677))
                              : (IData)(__Vdfg_Regularize_677));
    __Vdfg_Regularize_753 = ((0x00000080U & (IData)(__Vdfg_Regularize_630))
                              ? (7U ^ (IData)(__Vdfg_Regularize_752))
                              : (IData)(__Vdfg_Regularize_752));
    __Vdfg_Regularize_679 = ((0x000000feU & ((IData)(__Vdfg_Regularize_678) 
                                             << 1U)) 
                             | (1U & (vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_4__DOT__u_crc_parallel_full__DOT__reg_data 
                                      >> 1U)));
    __Vdfg_Regularize_754 = ((0x000000feU & ((IData)(__Vdfg_Regularize_753) 
                                             << 1U)) 
                             | (1U & (vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_4__DOT__u_crc_parallel_full__DOT__reg_data 
                                      >> 1U)));
    __Vdfg_Regularize_680 = ((0x00000080U & (IData)(__Vdfg_Regularize_678))
                              ? (7U ^ (IData)(__Vdfg_Regularize_679))
                              : (IData)(__Vdfg_Regularize_679));
    __Vdfg_Regularize_755 = ((0x00000080U & (IData)(__Vdfg_Regularize_753))
                              ? (7U ^ (IData)(__Vdfg_Regularize_754))
                              : (IData)(__Vdfg_Regularize_754));
    __Vdfg_Regularize_681 = ((0x000000feU & ((IData)(__Vdfg_Regularize_680) 
                                             << 1U)) 
                             | (1U & (vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_4__DOT__u_crc_parallel_full__DOT__reg_data 
                                      >> 2U)));
    __Vdfg_Regularize_756 = ((0x000000feU & ((IData)(__Vdfg_Regularize_755) 
                                             << 1U)) 
                             | (1U & (vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_4__DOT__u_crc_parallel_full__DOT__reg_data 
                                      >> 2U)));
    __Vdfg_Regularize_682 = ((0x00000080U & (IData)(__Vdfg_Regularize_680))
                              ? (7U ^ (IData)(__Vdfg_Regularize_681))
                              : (IData)(__Vdfg_Regularize_681));
    __Vdfg_Regularize_757 = ((0x00000080U & (IData)(__Vdfg_Regularize_755))
                              ? (7U ^ (IData)(__Vdfg_Regularize_756))
                              : (IData)(__Vdfg_Regularize_756));
    __Vdfg_Regularize_683 = ((0x000000feU & ((IData)(__Vdfg_Regularize_682) 
                                             << 1U)) 
                             | (1U & (vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_4__DOT__u_crc_parallel_full__DOT__reg_data 
                                      >> 3U)));
    __Vdfg_Regularize_758 = ((0x000000feU & ((IData)(__Vdfg_Regularize_757) 
                                             << 1U)) 
                             | (1U & (vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_4__DOT__u_crc_parallel_full__DOT__reg_data 
                                      >> 3U)));
    __Vdfg_Regularize_684 = ((0x00000080U & (IData)(__Vdfg_Regularize_682))
                              ? (7U ^ (IData)(__Vdfg_Regularize_683))
                              : (IData)(__Vdfg_Regularize_683));
    __Vdfg_Regularize_759 = ((0x00000080U & (IData)(__Vdfg_Regularize_757))
                              ? (7U ^ (IData)(__Vdfg_Regularize_758))
                              : (IData)(__Vdfg_Regularize_758));
    __Vdfg_Regularize_685 = ((0x000000feU & ((IData)(__Vdfg_Regularize_684) 
                                             << 1U)) 
                             | (1U & (vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_4__DOT__u_crc_parallel_full__DOT__reg_data 
                                      >> 4U)));
    __Vdfg_Regularize_760 = ((0x000000feU & ((IData)(__Vdfg_Regularize_759) 
                                             << 1U)) 
                             | (1U & (vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_4__DOT__u_crc_parallel_full__DOT__reg_data 
                                      >> 4U)));
    __Vdfg_Regularize_686 = ((0x00000080U & (IData)(__Vdfg_Regularize_684))
                              ? (7U ^ (IData)(__Vdfg_Regularize_685))
                              : (IData)(__Vdfg_Regularize_685));
    __Vdfg_Regularize_761 = ((0x00000080U & (IData)(__Vdfg_Regularize_759))
                              ? (7U ^ (IData)(__Vdfg_Regularize_760))
                              : (IData)(__Vdfg_Regularize_760));
    __Vdfg_Regularize_687 = ((0x000000feU & ((IData)(__Vdfg_Regularize_686) 
                                             << 1U)) 
                             | (1U & (vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_4__DOT__u_crc_parallel_full__DOT__reg_data 
                                      >> 5U)));
    __Vdfg_Regularize_762 = ((0x000000feU & ((IData)(__Vdfg_Regularize_761) 
                                             << 1U)) 
                             | (1U & (vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_4__DOT__u_crc_parallel_full__DOT__reg_data 
                                      >> 5U)));
    __Vdfg_Regularize_688 = ((0x00000080U & (IData)(__Vdfg_Regularize_686))
                              ? (7U ^ (IData)(__Vdfg_Regularize_687))
                              : (IData)(__Vdfg_Regularize_687));
    __Vdfg_Regularize_763 = ((0x00000080U & (IData)(__Vdfg_Regularize_761))
                              ? (7U ^ (IData)(__Vdfg_Regularize_762))
                              : (IData)(__Vdfg_Regularize_762));
    __Vdfg_Regularize_689 = ((0x000000feU & ((IData)(__Vdfg_Regularize_688) 
                                             << 1U)) 
                             | (1U & (vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_4__DOT__u_crc_parallel_full__DOT__reg_data 
                                      >> 6U)));
    __Vdfg_Regularize_764 = ((0x000000feU & ((IData)(__Vdfg_Regularize_763) 
                                             << 1U)) 
                             | (1U & (vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_4__DOT__u_crc_parallel_full__DOT__reg_data 
                                      >> 6U)));
    __Vdfg_Regularize_690 = ((0x00000080U & (IData)(__Vdfg_Regularize_688))
                              ? (7U ^ (IData)(__Vdfg_Regularize_689))
                              : (IData)(__Vdfg_Regularize_689));
    __Vdfg_Regularize_765 = ((0x00000080U & (IData)(__Vdfg_Regularize_763))
                              ? (7U ^ (IData)(__Vdfg_Regularize_764))
                              : (IData)(__Vdfg_Regularize_764));
    __Vdfg_Regularize_691 = ((0x000000feU & ((IData)(__Vdfg_Regularize_690) 
                                             << 1U)) 
                             | (1U & (vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_4__DOT__u_crc_parallel_full__DOT__reg_data 
                                      >> 7U)));
    __Vdfg_Regularize_766 = ((0x000000feU & ((IData)(__Vdfg_Regularize_765) 
                                             << 1U)) 
                             | (1U & (vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_4__DOT__u_crc_parallel_full__DOT__reg_data 
                                      >> 7U)));
    __Vdfg_Regularize_627 = ((1U & (IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_4__DOT__u_crc_parallel_full__DOT__reg_keep))
                              ? ((0x00000080U & (IData)(__Vdfg_Regularize_690))
                                  ? (7U ^ (IData)(__Vdfg_Regularize_691))
                                  : (IData)(__Vdfg_Regularize_691))
                              : (IData)(__Vdfg_Regularize_626));
    __Vdfg_Regularize_631 = ((1U & (IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_4__DOT__u_crc_parallel_full__DOT__reg_keep))
                              ? ((0x00000080U & (IData)(__Vdfg_Regularize_765))
                                  ? (7U ^ (IData)(__Vdfg_Regularize_766))
                                  : (IData)(__Vdfg_Regularize_766))
                              : (IData)(__Vdfg_Regularize_630));
    __Vdfg_Regularize_692 = ((0x00000080U & (IData)(__Vdfg_Regularize_627))
                              ? (1U | (0x000000feU 
                                       & (6U ^ (0x000000feU 
                                                & ((IData)(__Vdfg_Regularize_627) 
                                                   << 1U)))))
                              : (0x000000feU & ((IData)(__Vdfg_Regularize_627) 
                                                << 1U)));
    __Vdfg_Regularize_767 = ((0x00000080U & (IData)(__Vdfg_Regularize_631))
                              ? (1U | (0x000000feU 
                                       & (6U ^ (0x000000feU 
                                                & ((IData)(__Vdfg_Regularize_631) 
                                                   << 1U)))))
                              : (0x000000feU & ((IData)(__Vdfg_Regularize_631) 
                                                << 1U)));
    __Vdfg_Regularize_693 = ((0x00000080U & (IData)(__Vdfg_Regularize_692))
                              ? (1U | (0x000000feU 
                                       & (6U ^ (0x000000feU 
                                                & ((IData)(__Vdfg_Regularize_692) 
                                                   << 1U)))))
                              : (0x000000feU & ((IData)(__Vdfg_Regularize_692) 
                                                << 1U)));
    __Vdfg_Regularize_768 = ((0x00000080U & (IData)(__Vdfg_Regularize_767))
                              ? (1U | (0x000000feU 
                                       & (6U ^ (0x000000feU 
                                                & ((IData)(__Vdfg_Regularize_767) 
                                                   << 1U)))))
                              : (0x000000feU & ((IData)(__Vdfg_Regularize_767) 
                                                << 1U)));
    __Vdfg_Regularize_694 = ((0x00000080U & (IData)(__Vdfg_Regularize_693))
                              ? (1U | (0x000000feU 
                                       & (6U ^ (0x000000feU 
                                                & ((IData)(__Vdfg_Regularize_693) 
                                                   << 1U)))))
                              : (0x000000feU & ((IData)(__Vdfg_Regularize_693) 
                                                << 1U)));
    __Vdfg_Regularize_769 = ((0x00000080U & (IData)(__Vdfg_Regularize_768))
                              ? (1U | (0x000000feU 
                                       & (6U ^ (0x000000feU 
                                                & ((IData)(__Vdfg_Regularize_768) 
                                                   << 1U)))))
                              : (0x000000feU & ((IData)(__Vdfg_Regularize_768) 
                                                << 1U)));
    __Vdfg_Regularize_695 = ((0x00000080U & (IData)(__Vdfg_Regularize_694))
                              ? (1U | (0x000000feU 
                                       & (6U ^ (0x000000feU 
                                                & ((IData)(__Vdfg_Regularize_694) 
                                                   << 1U)))))
                              : (0x000000feU & ((IData)(__Vdfg_Regularize_694) 
                                                << 1U)));
    __Vdfg_Regularize_770 = ((0x00000080U & (IData)(__Vdfg_Regularize_769))
                              ? (1U | (0x000000feU 
                                       & (6U ^ (0x000000feU 
                                                & ((IData)(__Vdfg_Regularize_769) 
                                                   << 1U)))))
                              : (0x000000feU & ((IData)(__Vdfg_Regularize_769) 
                                                << 1U)));
    __Vdfg_Regularize_696 = ((0x00000080U & (IData)(__Vdfg_Regularize_695))
                              ? (1U | (0x000000feU 
                                       & (6U ^ (0x000000feU 
                                                & ((IData)(__Vdfg_Regularize_695) 
                                                   << 1U)))))
                              : (0x000000feU & ((IData)(__Vdfg_Regularize_695) 
                                                << 1U)));
    __Vdfg_Regularize_771 = ((0x00000080U & (IData)(__Vdfg_Regularize_770))
                              ? (1U | (0x000000feU 
                                       & (6U ^ (0x000000feU 
                                                & ((IData)(__Vdfg_Regularize_770) 
                                                   << 1U)))))
                              : (0x000000feU & ((IData)(__Vdfg_Regularize_770) 
                                                << 1U)));
    __Vdfg_Regularize_697 = ((0x00000080U & (IData)(__Vdfg_Regularize_696))
                              ? (1U | (0x000000feU 
                                       & (6U ^ (0x000000feU 
                                                & ((IData)(__Vdfg_Regularize_696) 
                                                   << 1U)))))
                              : (0x000000feU & ((IData)(__Vdfg_Regularize_696) 
                                                << 1U)));
    __Vdfg_Regularize_772 = ((0x00000080U & (IData)(__Vdfg_Regularize_771))
                              ? (1U | (0x000000feU 
                                       & (6U ^ (0x000000feU 
                                                & ((IData)(__Vdfg_Regularize_771) 
                                                   << 1U)))))
                              : (0x000000feU & ((IData)(__Vdfg_Regularize_771) 
                                                << 1U)));
    __Vdfg_Regularize_698 = ((0x00000080U & (IData)(__Vdfg_Regularize_697))
                              ? (1U | (0x000000feU 
                                       & (6U ^ (0x000000feU 
                                                & ((IData)(__Vdfg_Regularize_697) 
                                                   << 1U)))))
                              : (0x000000feU & ((IData)(__Vdfg_Regularize_697) 
                                                << 1U)));
    __Vdfg_Regularize_773 = ((0x00000080U & (IData)(__Vdfg_Regularize_772))
                              ? (1U | (0x000000feU 
                                       & (6U ^ (0x000000feU 
                                                & ((IData)(__Vdfg_Regularize_772) 
                                                   << 1U)))))
                              : (0x000000feU & ((IData)(__Vdfg_Regularize_772) 
                                                << 1U)));
    vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_4__DOT__u_crc_parallel_full__DOT__w_crc_nxt 
        = ((IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_4__DOT__u_crc_parallel_full__DOT__reg_last)
            ? ((0x00000080U & (IData)(__Vdfg_Regularize_698))
                ? (1U | (0x000000feU & (6U ^ (0x000000feU 
                                              & ((IData)(__Vdfg_Regularize_698) 
                                                 << 1U)))))
                : (0x000000feU & ((IData)(__Vdfg_Regularize_698) 
                                  << 1U))) : (IData)(__Vdfg_Regularize_627));
    vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_4__DOT__u_crc_parallel_full__DOT__w_crc_nxt 
        = ((IData)(vlSelfRef.m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_4__DOT__u_crc_parallel_full__DOT__reg_last)
            ? ((0x00000080U & (IData)(__Vdfg_Regularize_773))
                ? (1U | (0x000000feU & (6U ^ (0x000000feU 
                                              & ((IData)(__Vdfg_Regularize_773) 
                                                 << 1U)))))
                : (0x000000feU & ((IData)(__Vdfg_Regularize_773) 
                                  << 1U))) : (IData)(__Vdfg_Regularize_631));
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
    vlSelf->m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_4__DOT__u_crc_parallel_full__DOT__reg_crc_state = VL_SCOPED_RAND_RESET_I(8, __VscopeHash, 13610779891690354668ull);
    vlSelf->m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_4__DOT__u_crc_parallel_full__DOT__reg_crc_output = VL_SCOPED_RAND_RESET_I(8, __VscopeHash, 11223210158918720918ull);
    vlSelf->m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_4__DOT__u_crc_parallel_full__DOT__reg_data = VL_SCOPED_RAND_RESET_I(32, __VscopeHash, 9608099358741644235ull);
    vlSelf->m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_4__DOT__u_crc_parallel_full__DOT__reg_keep = VL_SCOPED_RAND_RESET_I(4, __VscopeHash, 7090268364461047129ull);
    vlSelf->m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_4__DOT__u_crc_parallel_full__DOT__w_crc_nxt = VL_SCOPED_RAND_RESET_I(8, __VscopeHash, 5214613064981067110ull);
    vlSelf->m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_4__DOT__u_crc_parallel_full__DOT__reg_last = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 12490305210461960448ull);
    vlSelf->m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_4__DOT__u_crc_parallel_full__DOT__reg_busy = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 15032014486116969465ull);
    vlSelf->m_crc_engine__DOT__gen_valid_config__DOT__u_crc_check__DOT__gen_method_4__DOT__u_crc_parallel_full__DOT__reg_crc_valid = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 3461194552164544074ull);
    vlSelf->m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_4__DOT__u_crc_parallel_full__DOT__reg_crc_state = VL_SCOPED_RAND_RESET_I(8, __VscopeHash, 14750363205640798413ull);
    vlSelf->m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_4__DOT__u_crc_parallel_full__DOT__reg_crc_output = VL_SCOPED_RAND_RESET_I(8, __VscopeHash, 15794304638862430893ull);
    vlSelf->m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_4__DOT__u_crc_parallel_full__DOT__reg_data = VL_SCOPED_RAND_RESET_I(32, __VscopeHash, 16628585295193913289ull);
    vlSelf->m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_4__DOT__u_crc_parallel_full__DOT__reg_keep = VL_SCOPED_RAND_RESET_I(4, __VscopeHash, 6601966535436248533ull);
    vlSelf->m_crc_engine__DOT__gen_valid_config__DOT__u_crc_gen__DOT__gen_method_4__DOT__u_crc_parallel_full__DOT__w_crc_nxt = VL_SCOPED_RAND_RESET_I(8, __VscopeHash, 1342899061654711202ull);
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
