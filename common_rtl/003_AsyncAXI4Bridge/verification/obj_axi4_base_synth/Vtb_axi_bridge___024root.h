// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Design internal header
// See Vtb_axi_bridge.h for the primary calling header

#ifndef VERILATED_VTB_AXI_BRIDGE___024ROOT_H_
#define VERILATED_VTB_AXI_BRIDGE___024ROOT_H_  // guard

#include "verilated.h"
#include "verilated_timing.h"


class Vtb_axi_bridge__Syms;

class alignas(VL_CACHE_LINE_BYTES) Vtb_axi_bridge___024root final {
  public:

    // DESIGN-SPECIFIC STATE
    // Anonymous structures to workaround compiler member-count bugs
    struct {
        CData/*0:0*/ tb_axi_bridge__DOT__i_clk_sub;
        CData/*0:0*/ tb_axi_bridge__DOT__i_clk_mgr;
        CData/*0:0*/ tb_axi_bridge__DOT__i_rst_n_sub;
        CData/*0:0*/ tb_axi_bridge__DOT__i_rst_n_mgr;
        CData/*0:0*/ tb_axi_bridge__DOT__i_axi_awvalid;
        CData/*3:0*/ tb_axi_bridge__DOT__i_axi_awid;
        CData/*7:0*/ tb_axi_bridge__DOT__i_axi_awlen;
        CData/*2:0*/ tb_axi_bridge__DOT__i_axi_awsize;
        CData/*1:0*/ tb_axi_bridge__DOT__i_axi_awburst;
        CData/*0:0*/ tb_axi_bridge__DOT__i_axi_awlock;
        CData/*3:0*/ tb_axi_bridge__DOT__i_axi_awcache;
        CData/*2:0*/ tb_axi_bridge__DOT__i_axi_awprot;
        CData/*3:0*/ tb_axi_bridge__DOT__i_axi_awqos;
        CData/*3:0*/ tb_axi_bridge__DOT__i_axi_awregion;
        CData/*0:0*/ tb_axi_bridge__DOT__i_axi_awready;
        CData/*0:0*/ tb_axi_bridge__DOT__i_axi_wvalid;
        CData/*3:0*/ tb_axi_bridge__DOT__i_axi_wstrb;
        CData/*0:0*/ tb_axi_bridge__DOT__i_axi_wlast;
        CData/*0:0*/ tb_axi_bridge__DOT__i_axi_wready;
        CData/*0:0*/ tb_axi_bridge__DOT__i_axi_bvalid;
        CData/*3:0*/ tb_axi_bridge__DOT__i_axi_bid;
        CData/*1:0*/ tb_axi_bridge__DOT__i_axi_bresp;
        CData/*0:0*/ tb_axi_bridge__DOT__i_axi_bready;
        CData/*0:0*/ tb_axi_bridge__DOT__i_axi_arvalid;
        CData/*3:0*/ tb_axi_bridge__DOT__i_axi_arid;
        CData/*7:0*/ tb_axi_bridge__DOT__i_axi_arlen;
        CData/*2:0*/ tb_axi_bridge__DOT__i_axi_arsize;
        CData/*1:0*/ tb_axi_bridge__DOT__i_axi_arburst;
        CData/*0:0*/ tb_axi_bridge__DOT__i_axi_arlock;
        CData/*3:0*/ tb_axi_bridge__DOT__i_axi_arcache;
        CData/*2:0*/ tb_axi_bridge__DOT__i_axi_arprot;
        CData/*3:0*/ tb_axi_bridge__DOT__i_axi_arqos;
        CData/*3:0*/ tb_axi_bridge__DOT__i_axi_arregion;
        CData/*0:0*/ tb_axi_bridge__DOT__i_axi_arready;
        CData/*0:0*/ tb_axi_bridge__DOT__i_axi_rvalid;
        CData/*3:0*/ tb_axi_bridge__DOT__i_axi_rid;
        CData/*1:0*/ tb_axi_bridge__DOT__i_axi_rresp;
        CData/*0:0*/ tb_axi_bridge__DOT__i_axi_rlast;
        CData/*0:0*/ tb_axi_bridge__DOT__i_axi_rready;
        CData/*0:0*/ tb_axi_bridge__DOT__src_aw_stall;
        CData/*0:0*/ tb_axi_bridge__DOT__dst_aw_stall;
        CData/*0:0*/ tb_axi_bridge__DOT__src_w_stall;
        CData/*0:0*/ tb_axi_bridge__DOT__dst_w_stall;
        CData/*0:0*/ tb_axi_bridge__DOT__src_b_stall;
        CData/*0:0*/ tb_axi_bridge__DOT__dst_b_stall;
        CData/*0:0*/ tb_axi_bridge__DOT__src_ar_stall;
        CData/*0:0*/ tb_axi_bridge__DOT__dst_ar_stall;
        CData/*0:0*/ tb_axi_bridge__DOT__src_r_stall;
        CData/*0:0*/ tb_axi_bridge__DOT__dst_r_stall;
        CData/*0:0*/ tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_r__DOT__o_axi_rready;
        CData/*0:0*/ tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_r__DOT__o_axi_rvalid;
        CData/*1:0*/ tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_r__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_rd__DOT__reg_fsm_srst_current_state;
        CData/*0:0*/ tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_r__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_rd__DOT__reg_ack_rd;
        CData/*4:0*/ tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_r__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_rd__DOT__reg_rbin;
        CData/*4:0*/ tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_r__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_rd__DOT__w_rbin_nxt;
        CData/*4:0*/ tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_r__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_rd__DOT__reg_rgray;
        CData/*4:0*/ tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_r__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_rd__DOT__u_sync_wr_gray__DOT__o_data;
        CData/*1:0*/ tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_r__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_rd__DOT__u_sync_wr_gray__DOT__gen_bit_cell__BRA__4__KET____DOT__u_vlsit_afifo_cell_sync__DOT__gen_sync2__DOT__gen_rn__DOT__u_dont_touch_sync2ff__DOT__reg_chain;
        CData/*1:0*/ tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_r__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_rd__DOT__u_sync_wr_gray__DOT__gen_bit_cell__BRA__3__KET____DOT__u_vlsit_afifo_cell_sync__DOT__gen_sync2__DOT__gen_rn__DOT__u_dont_touch_sync2ff__DOT__reg_chain;
        CData/*1:0*/ tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_r__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_rd__DOT__u_sync_wr_gray__DOT__gen_bit_cell__BRA__2__KET____DOT__u_vlsit_afifo_cell_sync__DOT__gen_sync2__DOT__gen_rn__DOT__u_dont_touch_sync2ff__DOT__reg_chain;
        CData/*1:0*/ tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_r__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_rd__DOT__u_sync_wr_gray__DOT__gen_bit_cell__BRA__1__KET____DOT__u_vlsit_afifo_cell_sync__DOT__gen_sync2__DOT__gen_rn__DOT__u_dont_touch_sync2ff__DOT__reg_chain;
        CData/*1:0*/ tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_r__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_rd__DOT__u_sync_wr_gray__DOT__gen_bit_cell__BRA__0__KET____DOT__u_vlsit_afifo_cell_sync__DOT__gen_sync2__DOT__gen_rn__DOT__u_dont_touch_sync2ff__DOT__reg_chain;
        CData/*1:0*/ tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_r__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_rd__DOT__u_sync_req__DOT__gen_bit_cell__BRA__0__KET____DOT__u_vlsit_afifo_cell_sync__DOT__gen_sync2__DOT__gen_rn__DOT__u_dont_touch_sync2ff__DOT__reg_chain;
        CData/*0:0*/ tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_r__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__o_mem_wr_en;
    };
    struct {
        CData/*2:0*/ tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_r__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__reg_fsm_srst_current_state;
        CData/*0:0*/ tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_r__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__reg_sw_rst_busy;
        CData/*0:0*/ tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_r__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__reg_req_wr;
        CData/*4:0*/ tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_r__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__reg_wbin;
        CData/*4:0*/ tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_r__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__w_wbin_nxt;
        CData/*4:0*/ tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_r__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__reg_wgray;
        CData/*4:0*/ tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_r__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__u_sync_rd_gray__DOT__o_data;
        CData/*1:0*/ tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_r__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__u_sync_rd_gray__DOT__gen_bit_cell__BRA__4__KET____DOT__u_vlsit_afifo_cell_sync__DOT__gen_sync2__DOT__gen_rn__DOT__u_dont_touch_sync2ff__DOT__reg_chain;
        CData/*1:0*/ tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_r__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__u_sync_rd_gray__DOT__gen_bit_cell__BRA__3__KET____DOT__u_vlsit_afifo_cell_sync__DOT__gen_sync2__DOT__gen_rn__DOT__u_dont_touch_sync2ff__DOT__reg_chain;
        CData/*1:0*/ tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_r__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__u_sync_rd_gray__DOT__gen_bit_cell__BRA__2__KET____DOT__u_vlsit_afifo_cell_sync__DOT__gen_sync2__DOT__gen_rn__DOT__u_dont_touch_sync2ff__DOT__reg_chain;
        CData/*1:0*/ tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_r__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__u_sync_rd_gray__DOT__gen_bit_cell__BRA__1__KET____DOT__u_vlsit_afifo_cell_sync__DOT__gen_sync2__DOT__gen_rn__DOT__u_dont_touch_sync2ff__DOT__reg_chain;
        CData/*1:0*/ tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_r__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__u_sync_rd_gray__DOT__gen_bit_cell__BRA__0__KET____DOT__u_vlsit_afifo_cell_sync__DOT__gen_sync2__DOT__gen_rn__DOT__u_dont_touch_sync2ff__DOT__reg_chain;
        CData/*1:0*/ tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_r__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__u_sync_ack__DOT__gen_bit_cell__BRA__0__KET____DOT__u_vlsit_afifo_cell_sync__DOT__gen_sync2__DOT__gen_rn__DOT__u_dont_touch_sync2ff__DOT__reg_chain;
        CData/*0:0*/ tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_w__DOT__o_axi_wready;
        CData/*0:0*/ tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_w__DOT__o_axi_wvalid;
        CData/*1:0*/ tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_w__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_rd__DOT__reg_fsm_srst_current_state;
        CData/*0:0*/ tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_w__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_rd__DOT__reg_ack_rd;
        CData/*4:0*/ tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_w__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_rd__DOT__reg_rbin;
        CData/*4:0*/ tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_w__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_rd__DOT__w_rbin_nxt;
        CData/*4:0*/ tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_w__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_rd__DOT__reg_rgray;
        CData/*4:0*/ tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_w__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_rd__DOT__u_sync_wr_gray__DOT__o_data;
        CData/*1:0*/ tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_w__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_rd__DOT__u_sync_wr_gray__DOT__gen_bit_cell__BRA__4__KET____DOT__u_vlsit_afifo_cell_sync__DOT__gen_sync2__DOT__gen_rn__DOT__u_dont_touch_sync2ff__DOT__reg_chain;
        CData/*1:0*/ tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_w__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_rd__DOT__u_sync_wr_gray__DOT__gen_bit_cell__BRA__3__KET____DOT__u_vlsit_afifo_cell_sync__DOT__gen_sync2__DOT__gen_rn__DOT__u_dont_touch_sync2ff__DOT__reg_chain;
        CData/*1:0*/ tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_w__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_rd__DOT__u_sync_wr_gray__DOT__gen_bit_cell__BRA__2__KET____DOT__u_vlsit_afifo_cell_sync__DOT__gen_sync2__DOT__gen_rn__DOT__u_dont_touch_sync2ff__DOT__reg_chain;
        CData/*1:0*/ tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_w__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_rd__DOT__u_sync_wr_gray__DOT__gen_bit_cell__BRA__1__KET____DOT__u_vlsit_afifo_cell_sync__DOT__gen_sync2__DOT__gen_rn__DOT__u_dont_touch_sync2ff__DOT__reg_chain;
        CData/*1:0*/ tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_w__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_rd__DOT__u_sync_wr_gray__DOT__gen_bit_cell__BRA__0__KET____DOT__u_vlsit_afifo_cell_sync__DOT__gen_sync2__DOT__gen_rn__DOT__u_dont_touch_sync2ff__DOT__reg_chain;
        CData/*1:0*/ tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_w__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_rd__DOT__u_sync_req__DOT__gen_bit_cell__BRA__0__KET____DOT__u_vlsit_afifo_cell_sync__DOT__gen_sync2__DOT__gen_rn__DOT__u_dont_touch_sync2ff__DOT__reg_chain;
        CData/*0:0*/ tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_w__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__o_mem_wr_en;
        CData/*2:0*/ tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_w__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__reg_fsm_srst_current_state;
        CData/*0:0*/ tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_w__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__reg_sw_rst_busy;
        CData/*0:0*/ tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_w__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__reg_req_wr;
        CData/*4:0*/ tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_w__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__reg_wbin;
        CData/*4:0*/ tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_w__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__w_wbin_nxt;
        CData/*4:0*/ tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_w__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__reg_wgray;
        CData/*4:0*/ tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_w__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__u_sync_rd_gray__DOT__o_data;
        CData/*1:0*/ tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_w__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__u_sync_rd_gray__DOT__gen_bit_cell__BRA__4__KET____DOT__u_vlsit_afifo_cell_sync__DOT__gen_sync2__DOT__gen_rn__DOT__u_dont_touch_sync2ff__DOT__reg_chain;
        CData/*1:0*/ tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_w__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__u_sync_rd_gray__DOT__gen_bit_cell__BRA__3__KET____DOT__u_vlsit_afifo_cell_sync__DOT__gen_sync2__DOT__gen_rn__DOT__u_dont_touch_sync2ff__DOT__reg_chain;
        CData/*1:0*/ tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_w__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__u_sync_rd_gray__DOT__gen_bit_cell__BRA__2__KET____DOT__u_vlsit_afifo_cell_sync__DOT__gen_sync2__DOT__gen_rn__DOT__u_dont_touch_sync2ff__DOT__reg_chain;
        CData/*1:0*/ tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_w__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__u_sync_rd_gray__DOT__gen_bit_cell__BRA__1__KET____DOT__u_vlsit_afifo_cell_sync__DOT__gen_sync2__DOT__gen_rn__DOT__u_dont_touch_sync2ff__DOT__reg_chain;
        CData/*1:0*/ tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_w__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__u_sync_rd_gray__DOT__gen_bit_cell__BRA__0__KET____DOT__u_vlsit_afifo_cell_sync__DOT__gen_sync2__DOT__gen_rn__DOT__u_dont_touch_sync2ff__DOT__reg_chain;
        CData/*1:0*/ tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_w__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__u_sync_ack__DOT__gen_bit_cell__BRA__0__KET____DOT__u_vlsit_afifo_cell_sync__DOT__gen_sync2__DOT__gen_rn__DOT__u_dont_touch_sync2ff__DOT__reg_chain;
        CData/*0:0*/ tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_ar__DOT__o_axi_arready;
        CData/*0:0*/ tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_ar__DOT__o_axi_arvalid;
        CData/*1:0*/ tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_ar__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_rd__DOT__reg_fsm_srst_current_state;
        CData/*0:0*/ tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_ar__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_rd__DOT__reg_ack_rd;
        CData/*2:0*/ tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_ar__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_rd__DOT__reg_rbin;
        CData/*2:0*/ tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_ar__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_rd__DOT__w_rbin_nxt;
        CData/*2:0*/ tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_ar__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_rd__DOT__reg_rgray;
        CData/*2:0*/ tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_ar__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_rd__DOT__u_sync_wr_gray__DOT__o_data;
        CData/*1:0*/ tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_ar__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_rd__DOT__u_sync_wr_gray__DOT__gen_bit_cell__BRA__2__KET____DOT__u_vlsit_afifo_cell_sync__DOT__gen_sync2__DOT__gen_rn__DOT__u_dont_touch_sync2ff__DOT__reg_chain;
        CData/*1:0*/ tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_ar__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_rd__DOT__u_sync_wr_gray__DOT__gen_bit_cell__BRA__1__KET____DOT__u_vlsit_afifo_cell_sync__DOT__gen_sync2__DOT__gen_rn__DOT__u_dont_touch_sync2ff__DOT__reg_chain;
        CData/*1:0*/ tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_ar__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_rd__DOT__u_sync_wr_gray__DOT__gen_bit_cell__BRA__0__KET____DOT__u_vlsit_afifo_cell_sync__DOT__gen_sync2__DOT__gen_rn__DOT__u_dont_touch_sync2ff__DOT__reg_chain;
        CData/*1:0*/ tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_ar__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_rd__DOT__u_sync_req__DOT__gen_bit_cell__BRA__0__KET____DOT__u_vlsit_afifo_cell_sync__DOT__gen_sync2__DOT__gen_rn__DOT__u_dont_touch_sync2ff__DOT__reg_chain;
        CData/*0:0*/ tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_ar__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__o_mem_wr_en;
        CData/*2:0*/ tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_ar__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__reg_fsm_srst_current_state;
        CData/*0:0*/ tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_ar__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__reg_sw_rst_busy;
        CData/*0:0*/ tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_ar__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__reg_req_wr;
        CData/*2:0*/ tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_ar__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__reg_wbin;
        CData/*2:0*/ tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_ar__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__w_wbin_nxt;
        CData/*2:0*/ tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_ar__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__reg_wgray;
        CData/*2:0*/ tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_ar__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__u_sync_rd_gray__DOT__o_data;
        CData/*1:0*/ tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_ar__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__u_sync_rd_gray__DOT__gen_bit_cell__BRA__2__KET____DOT__u_vlsit_afifo_cell_sync__DOT__gen_sync2__DOT__gen_rn__DOT__u_dont_touch_sync2ff__DOT__reg_chain;
        CData/*1:0*/ tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_ar__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__u_sync_rd_gray__DOT__gen_bit_cell__BRA__1__KET____DOT__u_vlsit_afifo_cell_sync__DOT__gen_sync2__DOT__gen_rn__DOT__u_dont_touch_sync2ff__DOT__reg_chain;
        CData/*1:0*/ tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_ar__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__u_sync_rd_gray__DOT__gen_bit_cell__BRA__0__KET____DOT__u_vlsit_afifo_cell_sync__DOT__gen_sync2__DOT__gen_rn__DOT__u_dont_touch_sync2ff__DOT__reg_chain;
    };
    struct {
        CData/*1:0*/ tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_ar__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__u_sync_ack__DOT__gen_bit_cell__BRA__0__KET____DOT__u_vlsit_afifo_cell_sync__DOT__gen_sync2__DOT__gen_rn__DOT__u_dont_touch_sync2ff__DOT__reg_chain;
        CData/*0:0*/ tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_aw__DOT__o_axi_awready;
        CData/*0:0*/ tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_aw__DOT__o_axi_awvalid;
        CData/*1:0*/ tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_aw__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_rd__DOT__reg_fsm_srst_current_state;
        CData/*0:0*/ tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_aw__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_rd__DOT__reg_ack_rd;
        CData/*2:0*/ tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_aw__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_rd__DOT__reg_rbin;
        CData/*2:0*/ tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_aw__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_rd__DOT__w_rbin_nxt;
        CData/*2:0*/ tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_aw__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_rd__DOT__reg_rgray;
        CData/*2:0*/ tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_aw__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_rd__DOT__u_sync_wr_gray__DOT__o_data;
        CData/*1:0*/ tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_aw__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_rd__DOT__u_sync_wr_gray__DOT__gen_bit_cell__BRA__2__KET____DOT__u_vlsit_afifo_cell_sync__DOT__gen_sync2__DOT__gen_rn__DOT__u_dont_touch_sync2ff__DOT__reg_chain;
        CData/*1:0*/ tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_aw__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_rd__DOT__u_sync_wr_gray__DOT__gen_bit_cell__BRA__1__KET____DOT__u_vlsit_afifo_cell_sync__DOT__gen_sync2__DOT__gen_rn__DOT__u_dont_touch_sync2ff__DOT__reg_chain;
        CData/*1:0*/ tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_aw__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_rd__DOT__u_sync_wr_gray__DOT__gen_bit_cell__BRA__0__KET____DOT__u_vlsit_afifo_cell_sync__DOT__gen_sync2__DOT__gen_rn__DOT__u_dont_touch_sync2ff__DOT__reg_chain;
        CData/*1:0*/ tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_aw__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_rd__DOT__u_sync_req__DOT__gen_bit_cell__BRA__0__KET____DOT__u_vlsit_afifo_cell_sync__DOT__gen_sync2__DOT__gen_rn__DOT__u_dont_touch_sync2ff__DOT__reg_chain;
        CData/*0:0*/ tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_aw__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__o_mem_wr_en;
        CData/*2:0*/ tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_aw__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__reg_fsm_srst_current_state;
        CData/*0:0*/ tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_aw__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__reg_sw_rst_busy;
        CData/*0:0*/ tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_aw__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__reg_req_wr;
        CData/*2:0*/ tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_aw__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__reg_wbin;
        CData/*2:0*/ tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_aw__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__w_wbin_nxt;
        CData/*2:0*/ tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_aw__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__reg_wgray;
        CData/*2:0*/ tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_aw__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__u_sync_rd_gray__DOT__o_data;
        CData/*1:0*/ tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_aw__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__u_sync_rd_gray__DOT__gen_bit_cell__BRA__2__KET____DOT__u_vlsit_afifo_cell_sync__DOT__gen_sync2__DOT__gen_rn__DOT__u_dont_touch_sync2ff__DOT__reg_chain;
        CData/*1:0*/ tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_aw__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__u_sync_rd_gray__DOT__gen_bit_cell__BRA__1__KET____DOT__u_vlsit_afifo_cell_sync__DOT__gen_sync2__DOT__gen_rn__DOT__u_dont_touch_sync2ff__DOT__reg_chain;
        CData/*1:0*/ tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_aw__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__u_sync_rd_gray__DOT__gen_bit_cell__BRA__0__KET____DOT__u_vlsit_afifo_cell_sync__DOT__gen_sync2__DOT__gen_rn__DOT__u_dont_touch_sync2ff__DOT__reg_chain;
        CData/*1:0*/ tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_aw__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__u_sync_ack__DOT__gen_bit_cell__BRA__0__KET____DOT__u_vlsit_afifo_cell_sync__DOT__gen_sync2__DOT__gen_rn__DOT__u_dont_touch_sync2ff__DOT__reg_chain;
        CData/*0:0*/ tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_b__DOT__o_axi_bready;
        CData/*0:0*/ tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_b__DOT__o_axi_bvalid;
        CData/*1:0*/ tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_b__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_rd__DOT__reg_fsm_srst_current_state;
        CData/*0:0*/ tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_b__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_rd__DOT__reg_ack_rd;
        CData/*2:0*/ tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_b__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_rd__DOT__reg_rbin;
        CData/*2:0*/ tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_b__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_rd__DOT__w_rbin_nxt;
        CData/*2:0*/ tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_b__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_rd__DOT__reg_rgray;
        CData/*2:0*/ tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_b__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_rd__DOT__u_sync_wr_gray__DOT__o_data;
        CData/*1:0*/ tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_b__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_rd__DOT__u_sync_wr_gray__DOT__gen_bit_cell__BRA__2__KET____DOT__u_vlsit_afifo_cell_sync__DOT__gen_sync2__DOT__gen_rn__DOT__u_dont_touch_sync2ff__DOT__reg_chain;
        CData/*1:0*/ tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_b__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_rd__DOT__u_sync_wr_gray__DOT__gen_bit_cell__BRA__1__KET____DOT__u_vlsit_afifo_cell_sync__DOT__gen_sync2__DOT__gen_rn__DOT__u_dont_touch_sync2ff__DOT__reg_chain;
        CData/*1:0*/ tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_b__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_rd__DOT__u_sync_wr_gray__DOT__gen_bit_cell__BRA__0__KET____DOT__u_vlsit_afifo_cell_sync__DOT__gen_sync2__DOT__gen_rn__DOT__u_dont_touch_sync2ff__DOT__reg_chain;
        CData/*1:0*/ tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_b__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_rd__DOT__u_sync_req__DOT__gen_bit_cell__BRA__0__KET____DOT__u_vlsit_afifo_cell_sync__DOT__gen_sync2__DOT__gen_rn__DOT__u_dont_touch_sync2ff__DOT__reg_chain;
        CData/*0:0*/ tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_b__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__o_mem_wr_en;
        CData/*2:0*/ tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_b__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__reg_fsm_srst_current_state;
        CData/*0:0*/ tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_b__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__reg_sw_rst_busy;
        CData/*0:0*/ tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_b__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__reg_req_wr;
        CData/*2:0*/ tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_b__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__reg_wbin;
        CData/*2:0*/ tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_b__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__w_wbin_nxt;
        CData/*2:0*/ tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_b__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__reg_wgray;
        CData/*2:0*/ tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_b__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__u_sync_rd_gray__DOT__o_data;
        CData/*1:0*/ tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_b__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__u_sync_rd_gray__DOT__gen_bit_cell__BRA__2__KET____DOT__u_vlsit_afifo_cell_sync__DOT__gen_sync2__DOT__gen_rn__DOT__u_dont_touch_sync2ff__DOT__reg_chain;
        CData/*1:0*/ tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_b__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__u_sync_rd_gray__DOT__gen_bit_cell__BRA__1__KET____DOT__u_vlsit_afifo_cell_sync__DOT__gen_sync2__DOT__gen_rn__DOT__u_dont_touch_sync2ff__DOT__reg_chain;
        CData/*1:0*/ tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_b__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__u_sync_rd_gray__DOT__gen_bit_cell__BRA__0__KET____DOT__u_vlsit_afifo_cell_sync__DOT__gen_sync2__DOT__gen_rn__DOT__u_dont_touch_sync2ff__DOT__reg_chain;
        CData/*1:0*/ tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_b__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__u_sync_ack__DOT__gen_bit_cell__BRA__0__KET____DOT__u_vlsit_afifo_cell_sync__DOT__gen_sync2__DOT__gen_rn__DOT__u_dont_touch_sync2ff__DOT__reg_chain;
        CData/*5:0*/ tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_b__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_mem__DOT__gen_array__DOT__reg_rd_data;
        CData/*2:0*/ __Vdly__tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_r__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__reg_fsm_srst_current_state_54;
        CData/*1:0*/ __Vdly__tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_r__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__u_sync_ack__DOT__gen_bit_cell__BRA__0__KET____DOT__u_vlsit_afifo_cell_sync__DOT__gen_sync2__DOT__gen_rn__DOT__u_dont_touch_sync2ff__DOT__reg_chain_62;
        CData/*1:0*/ __Vdly__tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_w__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_rd__DOT__reg_fsm_srst_current_state_65;
        CData/*1:0*/ __Vdly__tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_w__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_rd__DOT__u_sync_req__DOT__gen_bit_cell__BRA__0__KET____DOT__u_vlsit_afifo_cell_sync__DOT__gen_sync2__DOT__gen_rn__DOT__u_dont_touch_sync2ff__DOT__reg_chain_72;
        CData/*1:0*/ __Vdly__tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_ar__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_rd__DOT__reg_fsm_srst_current_state_75;
        CData/*1:0*/ __Vdly__tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_ar__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_rd__DOT__u_sync_req__DOT__gen_bit_cell__BRA__0__KET____DOT__u_vlsit_afifo_cell_sync__DOT__gen_sync2__DOT__gen_rn__DOT__u_dont_touch_sync2ff__DOT__reg_chain_80;
        CData/*1:0*/ __Vdly__tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_aw__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_rd__DOT__reg_fsm_srst_current_state_83;
        CData/*1:0*/ __Vdly__tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_aw__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_rd__DOT__u_sync_req__DOT__gen_bit_cell__BRA__0__KET____DOT__u_vlsit_afifo_cell_sync__DOT__gen_sync2__DOT__gen_rn__DOT__u_dont_touch_sync2ff__DOT__reg_chain_88;
        CData/*2:0*/ __Vdly__tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_b__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__reg_fsm_srst_current_state_91;
        CData/*1:0*/ __Vdly__tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_b__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_wr__DOT__u_sync_ack__DOT__gen_bit_cell__BRA__0__KET____DOT__u_vlsit_afifo_cell_sync__DOT__gen_sync2__DOT__gen_rn__DOT__u_dont_touch_sync2ff__DOT__reg_chain_97;
        CData/*3:0*/ __Vdly_Dim0__tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_r__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_mem__DOT__gen_array__DOT__reg_mem_108;
        CData/*0:0*/ __Vdly_Set__tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_r__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_mem__DOT__gen_array__DOT__reg_mem_109;
        CData/*5:0*/ __Vdly_Val__tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_b__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_mem__DOT__gen_array__DOT__reg_mem_110;
        CData/*1:0*/ __Vdly_Dim0__tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_b__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_mem__DOT__gen_array__DOT__reg_mem_111;
    };
    struct {
        CData/*0:0*/ __Vdly_Set__tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_b__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_mem__DOT__gen_array__DOT__reg_mem_112;
        CData/*0:0*/ __Vtrigprevexpr___TOP__tb_axi_bridge__DOT__i_clk_sub__0;
        CData/*0:0*/ __Vtrigprevexpr___TOP__tb_axi_bridge__DOT__i_clk_mgr__0;
        CData/*0:0*/ __Vtrigprevexpr___TOP__tb_axi_bridge__DOT__i_rst_n_sub__0;
        CData/*0:0*/ __Vtrigprevexpr___TOP__tb_axi_bridge__DOT__i_rst_n_mgr__0;
        CData/*0:0*/ __Vtrigprevexpr_h325807e2__1;
        CData/*0:0*/ __Vtrigprevexpr_hb5e7ad64__1;
        IData/*31:0*/ tb_axi_bridge__DOT__i_axi_awaddr;
        IData/*31:0*/ tb_axi_bridge__DOT__i_axi_wdata;
        IData/*31:0*/ tb_axi_bridge__DOT__i_axi_araddr;
        IData/*31:0*/ tb_axi_bridge__DOT__i_axi_rdata;
        IData/*31:0*/ tb_axi_bridge__DOT__aw_head;
        IData/*31:0*/ tb_axi_bridge__DOT__aw_tail;
        IData/*31:0*/ tb_axi_bridge__DOT__w_head;
        IData/*31:0*/ tb_axi_bridge__DOT__w_tail;
        IData/*31:0*/ tb_axi_bridge__DOT__b_head;
        IData/*31:0*/ tb_axi_bridge__DOT__b_tail;
        IData/*31:0*/ tb_axi_bridge__DOT__ar_head;
        IData/*31:0*/ tb_axi_bridge__DOT__ar_tail;
        IData/*31:0*/ tb_axi_bridge__DOT__r_head;
        IData/*31:0*/ tb_axi_bridge__DOT__r_tail;
        IData/*31:0*/ tb_axi_bridge__DOT__out_aw;
        IData/*31:0*/ tb_axi_bridge__DOT__out_w;
        IData/*31:0*/ tb_axi_bridge__DOT__out_b;
        IData/*31:0*/ tb_axi_bridge__DOT__out_ar;
        IData/*31:0*/ tb_axi_bridge__DOT__out_r;
        VlWide<16>/*511:0*/ tb_axi_bridge__DOT__prev_src_aw;
        VlWide<16>/*511:0*/ tb_axi_bridge__DOT__prev_dst_aw;
        VlWide<16>/*511:0*/ tb_axi_bridge__DOT__prev_src_w;
        VlWide<16>/*511:0*/ tb_axi_bridge__DOT__prev_dst_w;
        VlWide<16>/*511:0*/ tb_axi_bridge__DOT__prev_src_b;
        VlWide<16>/*511:0*/ tb_axi_bridge__DOT__prev_dst_b;
        VlWide<16>/*511:0*/ tb_axi_bridge__DOT__prev_src_ar;
        VlWide<16>/*511:0*/ tb_axi_bridge__DOT__prev_dst_ar;
        VlWide<16>/*511:0*/ tb_axi_bridge__DOT__prev_src_r;
        VlWide<16>/*511:0*/ tb_axi_bridge__DOT__prev_dst_r;
        IData/*31:0*/ tb_axi_bridge__DOT__seed_value;
        VlWide<128>/*4095:0*/ tb_axi_bridge__DOT__vcd_path;
        VlWide<3>/*64:0*/ tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_ar__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_mem__DOT__gen_array__DOT__reg_rd_data;
        VlWide<3>/*64:0*/ tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_aw__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_mem__DOT__gen_array__DOT__reg_rd_data;
        IData/*31:0*/ __Vi;
        QData/*38:0*/ tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_r__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_mem__DOT__gen_array__DOT__reg_rd_data;
        QData/*36:0*/ tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_w__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_mem__DOT__gen_array__DOT__reg_rd_data;
        QData/*38:0*/ __Vdly_Val__tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_r__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_mem__DOT__gen_array__DOT__reg_mem_107;
        VlUnpacked<VlWide<16>/*511:0*/, 256> tb_axi_bridge__DOT__exp_aw;
        VlUnpacked<VlWide<16>/*511:0*/, 256> tb_axi_bridge__DOT__exp_w;
        VlUnpacked<VlWide<16>/*511:0*/, 256> tb_axi_bridge__DOT__exp_b;
        VlUnpacked<VlWide<16>/*511:0*/, 256> tb_axi_bridge__DOT__exp_ar;
        VlUnpacked<VlWide<16>/*511:0*/, 256> tb_axi_bridge__DOT__exp_r;
        VlUnpacked<IData/*31:0*/, 36> tb_axi_bridge__DOT__assertion_hits;
        VlUnpacked<IData/*31:0*/, 36> tb_axi_bridge__DOT__assertion_fails;
        VlUnpacked<QData/*38:0*/, 16> tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_r__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_mem__DOT__gen_array__DOT__reg_mem;
        VlUnpacked<QData/*36:0*/, 16> tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_w__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_mem__DOT__gen_array__DOT__reg_mem;
        VlUnpacked<VlWide<3>/*64:0*/, 4> tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_ar__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_mem__DOT__gen_array__DOT__reg_mem;
        VlUnpacked<VlWide<3>/*64:0*/, 4> tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_aw__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_mem__DOT__gen_array__DOT__reg_mem;
        VlUnpacked<CData/*5:0*/, 4> tb_axi_bridge__DOT__dut__DOT__u_vlsit_axi_async_b__DOT__u_vlsit_afifo_top__DOT__u_vlsit_afifo_mem__DOT__gen_array__DOT__reg_mem;
        VlUnpacked<QData/*63:0*/, 1> __VstlTriggered;
        VlUnpacked<QData/*63:0*/, 1> __VicoTriggered;
        VlUnpacked<QData/*63:0*/, 1> __VactTriggered;
        VlUnpacked<QData/*63:0*/, 1> __VactTriggeredAcc;
        VlUnpacked<QData/*63:0*/, 1> __VnbaTriggered;
    };
    VlDelayScheduler __VdlySched;
    VlTriggerScheduler __VtrigSched_h8c92a91c__0;
    VlTriggerScheduler __VtrigSched_h046e81df__0;
    VlTriggerScheduler __VtrigSched_h8c92a665__0;
    VlTriggerScheduler __VtrigSched_h955be2db__0;
    VlTriggerScheduler __VtrigSched_h046e831a__0;
    VlTriggerScheduler __VtrigSched_h18cb2d65__0;

    // INTERNAL VARIABLES
    Vtb_axi_bridge__Syms* vlSymsp;
    const char* vlNamep;

    // CONSTRUCTORS
    Vtb_axi_bridge___024root(Vtb_axi_bridge__Syms* symsp, const char* namep);
    ~Vtb_axi_bridge___024root();
    VL_UNCOPYABLE(Vtb_axi_bridge___024root);

    // INTERNAL METHODS
};


#endif  // guard
