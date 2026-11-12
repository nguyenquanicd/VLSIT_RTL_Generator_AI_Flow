/*
 * Project      : VLSIT Common RTL library
 * Author       : Nguyen Quan and Claude Sonnet 5.5 (user)
 * AI Flow      : VLSIT RTL Generator AI Automation Flow
 * AI Flow Page : https://github.com/nguyenquanicd/VLSIT_RTL_Generator_AI_Model
 * Date         : 2026-11-09
 * Description  : AXI4 subordinate of the SHA2 and SHA3 hash IP (REF-006, 6.3). Each context has a
 *                message window (write, address bit 11 = 0) and a digest window (read, address bit
 *                11 = 1); address bits [15:12] select the context. The windows are FIFO ports:
 *                the offset inside a window is ignored. One write burst and one read burst are
 *                handled at a time. A burst is accepted (INCR or FIXED, full-width beats, strobes
 *                all ones); anything else is accepted and dropped with the response SLVERR and an
 *                error record (kind 1 write to a context that does not accept words, 2 read of an
 *                empty digest FIFO, 3 wrong window direction, 4 unsupported burst, size, strobe or
 *                context). A read of an empty digest FIFO returns zero with the response OKAY
 *                (DEC-022: no event while the DMA output channel pads a burst).
 *                Decisions: DEC-003, DEC-012, DEC-022, DEC-027, DEC-034.
 */
`timescale 1ns/1ps

module m_vlsit_sha_axi_sub #(
  // Parameter Description: AXI data width.
  // Parameter values: 32, 64 or 128; default is 64.
  // Parameter unit: bit
  parameter logic [31:0] PARA_AXI_DW = 64,
  // Parameter Description: AXI ID width.
  // Parameter values: 1 to 16; default is 4.
  // Parameter unit: bit
  parameter logic [31:0] PARA_AXI_IDW = 4,
  // Parameter Description: AXI address width; only bits [15:0] are decoded.
  // Parameter values: 16 to 32; default is 16.
  // Parameter unit: bit
  parameter logic [31:0] PARA_AXI_AW = 16,
  // Parameter Description: number of contexts.
  // Parameter values: 1 to 16; default is 1.
  // Parameter unit: count
  parameter logic [31:0] PARA_CTX_N = 1,
  localparam logic [31:0] LPARA_CTX_W = (PARA_CTX_N > 1) ? $clog2(PARA_CTX_N) : 1,
  localparam logic [31:0] LPARA_STRB_W = PARA_AXI_DW / 8,
  localparam logic [31:0] LPARA_SIZE = $clog2(PARA_AXI_DW / 8),
  // Burst types of AXI4 (REF-006): 0 FIXED and 1 INCR are accepted, 2 WRAP is not.
  localparam logic [31:0] LPARA_BURST_WRAP = 32'd2,
  localparam logic [31:0] LPARA_RESP_OKAY = 32'd0,
  localparam logic [31:0] LPARA_RESP_SLVERR = 32'd2,
  localparam logic [31:0] LPARA_KIND_OVF = 32'd1,
  localparam logic [31:0] LPARA_KIND_UDF = 32'd2,
  localparam logic [31:0] LPARA_KIND_DIR = 32'd3,
  localparam logic [31:0] LPARA_KIND_BAD = 32'd4
) (
  // Clock and reset
  input  wire                     i_clk_core,
  input  wire                     i_rst_n_core,

  // AXI4 write address channel
  input  wire                     i_axi_awvalid,
  output logic                    o_axi_awready,
  input  wire  [PARA_AXI_IDW-1:0] i_axi_awid,
  input  wire  [PARA_AXI_AW-1:0]  i_axi_awaddr,
  input  wire  [7:0]              i_axi_awlen,
  input  wire  [2:0]              i_axi_awsize,
  input  wire  [1:0]              i_axi_awburst,

  // AXI4 write data channel
  input  wire                     i_axi_wvalid,
  output logic                    o_axi_wready,
  input  wire  [PARA_AXI_DW-1:0]  i_axi_wdata,
  input  wire  [LPARA_STRB_W-1:0] i_axi_wstrb,
  input  wire                     i_axi_wlast,

  // AXI4 write response channel
  output logic                    o_axi_bvalid,
  input  wire                     i_axi_bready,
  output logic [PARA_AXI_IDW-1:0] o_axi_bid,
  output logic [1:0]              o_axi_bresp,

  // AXI4 read address channel
  input  wire                     i_axi_arvalid,
  output logic                    o_axi_arready,
  input  wire  [PARA_AXI_IDW-1:0] i_axi_arid,
  input  wire  [PARA_AXI_AW-1:0]  i_axi_araddr,
  input  wire  [7:0]              i_axi_arlen,
  input  wire  [2:0]              i_axi_arsize,
  input  wire  [1:0]              i_axi_arburst,

  // AXI4 read data channel
  output logic                    o_axi_rvalid,
  input  wire                     i_axi_rready,
  output logic [PARA_AXI_IDW-1:0] o_axi_rid,
  output logic [PARA_AXI_DW-1:0]  o_axi_rdata,
  output logic [1:0]              o_axi_rresp,
  output logic                    o_axi_rlast,

  // Input FIFO push and context state
  output logic                    o_in_push_en,
  output logic [LPARA_CTX_W-1:0]  o_in_push_ctx,
  output logic [PARA_AXI_DW-1:0]  o_in_push_data,
  input  wire  [PARA_CTX_N-1:0]   i_in_full,
  input  wire  [PARA_CTX_N-1:0]   i_ctx_abs,

  // Output FIFO pop and DMA padding
  output logic                    o_out_pop_en,
  output logic [LPARA_CTX_W-1:0]  o_out_pop_ctx,
  input  wire  [PARA_AXI_DW-1:0]  i_out_pop_data,
  input  wire  [PARA_CTX_N-1:0]   i_out_empty,
  input  wire                     i_pad_ok,
  output logic                    o_out_beat,

  // Fault responses (DEC-034): lock rejects every window access, gate rejects digest reads
  input  wire                     i_lock,
  input  wire                     i_gate,

  // Events and error record
  input  wire                     i_srst,
  output logic                    o_ev_ovf,
  output logic                    o_ev_udf,
  output logic                    o_ev_axi,
  output logic [4:0]              o_err_ctx,
  output logic [3:0]              o_err_kind,
  output logic [7:0]              o_err_ovf,
  output logic [7:0]              o_err_udf,
  output logic [31:0]             o_err_addr
);

  // FSM states of the write channel: IDLE accepts an address, DATA takes the beats up to
  // WLAST, RESP returns the response. Encoding 3 recovers to IDLE.
  typedef enum logic [1:0] {
    ENUM_ST_IDLE = 2'b00,
    ENUM_ST_DATA = 2'b01,
    ENUM_ST_RESP = 2'b10
  } wr_state_type_def;

  // FSM states of the read channel: IDLE accepts an address, DATA returns the beats.
  typedef enum logic {
    ENUM_ST_RIDLE = 1'b0,
    ENUM_ST_RDATA = 1'b1
  } rd_state_type_def;

  // Internal signal declarations
  wr_state_type_def reg_fsm_wr_current_state;
  wr_state_type_def w_fsm_wr_nxt_state;
  rd_state_type_def reg_fsm_rd_current_state;
  rd_state_type_def w_fsm_rd_nxt_state;

  logic [PARA_AXI_IDW-1:0] reg_w_id;
  logic [LPARA_CTX_W-1:0]  reg_w_ctx;
  logic [3:0]              reg_w_kind;
  logic                    reg_w_bad;
  logic [31:0]             reg_w_addr;
  logic [PARA_AXI_IDW-1:0] reg_r_id;
  logic [LPARA_CTX_W-1:0]  reg_r_ctx;
  logic [3:0]              reg_r_kind;
  logic [7:0]              reg_r_cnt;
  logic [31:0]             reg_r_addr;

  logic                    w_aw_hit;
  logic                    w_ar_hit;
  logic                    w_aw_ctx_ok;
  logic                    w_ar_ctx_ok;
  logic [3:0]              w_aw_kind;
  logic [3:0]              w_ar_kind;
  logic                    w_w_abs;
  logic                    w_w_full;
  logic                    w_w_accept;
  logic                    w_w_strb_ok;
  logic [3:0]              w_w_ev_kind;
  logic                    w_r_ok;
  logic                    w_r_empty;
  logic                    w_r_beat;
  logic [3:0]              w_r_ev_kind;
  logic [3:0]              w_ev_kind;
  logic [LPARA_CTX_W-1:0]  w_ev_ctx;
  logic [31:0]             w_ev_addr;
  logic [7:0]              w_ovf_nxt;
  logic [7:0]              w_udf_nxt;
  logic [3:0]              reg_err_kind;
  logic [4:0]              reg_err_ctx;
  logic [31:0]             reg_err_addr;
  logic [7:0]              reg_err_ovf;
  logic [7:0]              reg_err_udf;

  // Address handshakes and the decode of the two address channels: context range, burst type
  // and size, and the window direction (bit 11: 0 message window, 1 digest window).
  always_comb begin : p_com_addr
    w_aw_hit    = i_axi_awvalid && o_axi_awready;
    w_ar_hit    = i_axi_arvalid && o_axi_arready;
    w_aw_ctx_ok = ({1'b0, i_axi_awaddr[15:12]} < PARA_CTX_N[4:0]);
    w_ar_ctx_ok = ({1'b0, i_axi_araddr[15:12]} < PARA_CTX_N[4:0]);
    w_aw_kind   = 4'd0;
    w_ar_kind   = 4'd0;
    if (i_lock || !w_aw_ctx_ok || (i_axi_awburst == LPARA_BURST_WRAP[1:0]) || (i_axi_awsize != LPARA_SIZE[2:0]))
      w_aw_kind = LPARA_KIND_BAD[3:0];
    else if (i_axi_awaddr[11])
      w_aw_kind = LPARA_KIND_DIR[3:0];
    if (i_lock || i_gate || !w_ar_ctx_ok || (i_axi_arburst == LPARA_BURST_WRAP[1:0]) || (i_axi_arsize != LPARA_SIZE[2:0]))
      w_ar_kind = LPARA_KIND_BAD[3:0];
    else if (!i_axi_araddr[11])
      w_ar_kind = LPARA_KIND_DIR[3:0];
  end

  // Write beat decode: the beat is stored when the burst is legal, the context accepts words
  // and all strobes are 1; it is dropped otherwise, and the event kind says why.
  always_comb begin : p_com_wbeat
    w_w_abs     = 1'b0;
    w_w_full    = 1'b0;
    for (int idx = 0; idx < PARA_CTX_N; idx++) begin
      if (reg_w_ctx == LPARA_CTX_W'(idx)) begin
        w_w_abs  = i_ctx_abs[idx];
        w_w_full = i_in_full[idx];
      end
    end
    w_w_strb_ok = (i_axi_wstrb == {LPARA_STRB_W{1'b1}});
    w_w_ev_kind = 4'd0;
    casez ({(reg_w_kind != 4'd0), !w_w_abs, !w_w_strb_ok})
      3'b1??:  w_w_ev_kind = reg_w_kind;
      3'b01?:  w_w_ev_kind = LPARA_KIND_OVF[3:0];
      3'b001:  w_w_ev_kind = LPARA_KIND_BAD[3:0];
      default: w_w_ev_kind = 4'd0;
    endcase
    o_axi_wready   = (reg_fsm_wr_current_state == ENUM_ST_DATA) && ((w_w_ev_kind != 4'd0) || !w_w_full);
    w_w_accept     = (reg_fsm_wr_current_state == ENUM_ST_DATA) && i_axi_wvalid
                  && ((w_w_ev_kind != 4'd0) || !w_w_full);
    o_in_push_en   = w_w_accept && (w_w_ev_kind == 4'd0);
    o_in_push_ctx  = reg_w_ctx;
    o_in_push_data = i_axi_wdata;
  end

  // Read beat decode: data of the digest FIFO when the burst is legal and the FIFO has a word;
  // zero with OKAY for an empty FIFO; zero with SLVERR for an illegal burst.
  always_comb begin : p_com_rbeat
    w_r_ok    = (reg_r_kind == 4'd0);
    w_r_empty = 1'b1;
    for (int idx = 0; idx < PARA_CTX_N; idx++) begin
      if (reg_r_ctx == LPARA_CTX_W'(idx))
        w_r_empty = i_out_empty[idx];
    end
    w_r_beat      = (reg_fsm_rd_current_state == ENUM_ST_RDATA) && i_axi_rready;
    o_axi_rvalid  = (reg_fsm_rd_current_state == ENUM_ST_RDATA);
    o_axi_rid     = reg_r_id;
    o_axi_rlast   = (reg_r_cnt == 8'd0);
    o_axi_rdata   = '0;
    o_axi_rresp   = LPARA_RESP_OKAY[1:0];
    casez ({w_r_ok, w_r_empty})
      2'b10:   o_axi_rdata = i_out_pop_data;
      2'b0?:   o_axi_rresp = LPARA_RESP_SLVERR[1:0];
      default: o_axi_rdata = '0;
    endcase
    o_out_pop_en  = w_r_beat && w_r_ok && !w_r_empty;
    o_out_pop_ctx = reg_r_ctx;
    o_out_beat    = w_r_beat;
    w_r_ev_kind   = 4'd0;
    if (w_r_beat && w_r_ok && w_r_empty && !i_pad_ok)
      w_r_ev_kind = LPARA_KIND_UDF[3:0];
  end

  // Write channel FSM, next state: IDLE to DATA on an accepted address, DATA to RESP on the last
  // beat, RESP to IDLE when the response is taken.
  always_comb begin : p_com_fsm_wr
    w_fsm_wr_nxt_state = reg_fsm_wr_current_state;
    case (reg_fsm_wr_current_state)
      ENUM_ST_IDLE: begin
        if (w_aw_hit)
          w_fsm_wr_nxt_state = ENUM_ST_DATA;
      end
      ENUM_ST_DATA: begin
        if (w_w_accept && i_axi_wlast)
          w_fsm_wr_nxt_state = ENUM_ST_RESP;
      end
      ENUM_ST_RESP: begin
        if (i_axi_bready)
          w_fsm_wr_nxt_state = ENUM_ST_IDLE;
      end
      default: w_fsm_wr_nxt_state = ENUM_ST_IDLE;
    endcase
    o_axi_awready = (reg_fsm_wr_current_state == ENUM_ST_IDLE);
    o_axi_bvalid  = (reg_fsm_wr_current_state == ENUM_ST_RESP);
    o_axi_bid     = reg_w_id;
    o_axi_bresp   = reg_w_bad ? LPARA_RESP_SLVERR[1:0] : LPARA_RESP_OKAY[1:0];
  end

  // Read channel FSM, next state: IDLE to DATA on an accepted address, DATA to IDLE after the
  // last beat is taken.
  always_comb begin : p_com_fsm_rd
    w_fsm_rd_nxt_state = reg_fsm_rd_current_state;
    case (reg_fsm_rd_current_state)
      ENUM_ST_RIDLE: begin
        if (w_ar_hit)
          w_fsm_rd_nxt_state = ENUM_ST_RDATA;
      end
      ENUM_ST_RDATA: begin
        if (w_r_beat && (reg_r_cnt == 8'd0))
          w_fsm_rd_nxt_state = ENUM_ST_RIDLE;
      end
      default: w_fsm_rd_nxt_state = ENUM_ST_RIDLE;
    endcase
    o_axi_arready = (reg_fsm_rd_current_state == ENUM_ST_RIDLE);
  end

  // Event selection: the kind with the lowest number wins when two events fall in one cycle; the
  // write side wins a tie. Events: the rejected write beat, the rejected read address and the
  // read of an empty digest FIFO.
  always_comb begin : p_com_event
    w_ev_kind = 4'd0;
    w_ev_ctx  = reg_w_ctx;
    w_ev_addr = reg_w_addr;
    o_ev_ovf  = 1'b0;
    o_ev_udf  = 1'b0;
    o_ev_axi  = 1'b0;
    if (w_w_accept && (w_w_ev_kind != 4'd0)) begin
      w_ev_kind = w_w_ev_kind;
      o_ev_ovf  = (w_w_ev_kind == LPARA_KIND_OVF[3:0]);
      o_ev_axi  = (w_w_ev_kind != LPARA_KIND_OVF[3:0]);
    end
    if (w_ar_hit && (w_ar_kind != 4'd0)) begin
      o_ev_axi = 1'b1;
      if ((w_ev_kind == 4'd0) || (w_ar_kind < w_ev_kind)) begin
        w_ev_kind = w_ar_kind;
        w_ev_ctx  = i_axi_araddr[12 +: LPARA_CTX_W];
        w_ev_addr = 32'(i_axi_araddr);
      end
    end
    if (w_r_ev_kind != 4'd0) begin
      o_ev_udf = 1'b1;
      if ((w_ev_kind == 4'd0) || (w_r_ev_kind < w_ev_kind)) begin
        w_ev_kind = w_r_ev_kind;
        w_ev_ctx  = reg_r_ctx;
        w_ev_addr = reg_r_addr;
      end
    end
    w_ovf_nxt = reg_err_ovf + {7'b0, (reg_err_ovf != 8'hFF) && o_ev_ovf};
    w_udf_nxt = reg_err_udf + {7'b0, (reg_err_udf != 8'hFF) && o_ev_udf};
  end

  // FSM state registers: control state, reset to IDLE.
  always_ff @(posedge i_clk_core, negedge i_rst_n_core) begin : p_ff_fsm_wr
    if (!i_rst_n_core)
      reg_fsm_wr_current_state <= ENUM_ST_IDLE;
    else
      reg_fsm_wr_current_state <= w_fsm_wr_nxt_state;
  end

  // Read FSM state register.
  always_ff @(posedge i_clk_core, negedge i_rst_n_core) begin : p_ff_fsm_rd
    if (!i_rst_n_core)
      reg_fsm_rd_current_state <= ENUM_ST_RIDLE;
    else
      reg_fsm_rd_current_state <= w_fsm_rd_nxt_state;
  end

  // Write burst registers: captured with the address, the bad flag collects the rejected beats.
  always_ff @(posedge i_clk_core, negedge i_rst_n_core) begin : p_ff_wr
    if (!i_rst_n_core) begin
      reg_w_id   <= '0;
      reg_w_ctx  <= '0;
      reg_w_kind <= 4'd0;
      reg_w_bad  <= 1'b0;
      reg_w_addr <= 32'd0;
    end else begin
      if (w_aw_hit) begin
        reg_w_id   <= i_axi_awid;
        reg_w_ctx  <= i_axi_awaddr[12 +: LPARA_CTX_W];
        reg_w_kind <= w_aw_kind;
        reg_w_bad  <= 1'b0;
        reg_w_addr <= 32'(i_axi_awaddr);
      end else if (w_w_accept && (w_w_ev_kind != 4'd0)) begin
        reg_w_bad <= 1'b1;
      end
    end
  end

  // Read burst registers: captured with the address, the counter holds the beats left minus one.
  always_ff @(posedge i_clk_core, negedge i_rst_n_core) begin : p_ff_rd
    if (!i_rst_n_core) begin
      reg_r_id   <= '0;
      reg_r_ctx  <= '0;
      reg_r_kind <= 4'd0;
      reg_r_cnt  <= 8'd0;
      reg_r_addr <= 32'd0;
    end else begin
      if (w_ar_hit) begin
        reg_r_id   <= i_axi_arid;
        reg_r_ctx  <= i_axi_araddr[12 +: LPARA_CTX_W];
        reg_r_kind <= w_ar_kind;
        reg_r_cnt  <= i_axi_arlen;
        reg_r_addr <= 32'(i_axi_araddr);
      end else if (w_r_beat && (reg_r_cnt != 8'd0)) begin
        reg_r_cnt <= reg_r_cnt - 8'd1;
      end
    end
  end

  // Error record: the latest event kind, context and address, and the saturating counters of
  // dropped writes and empty reads. The soft reset command clears the record.
  always_ff @(posedge i_clk_core, negedge i_rst_n_core) begin : p_ff_err
    if (!i_rst_n_core) begin
      reg_err_kind <= 4'd0;
      reg_err_ctx  <= 5'd0;
      reg_err_addr <= 32'd0;
      reg_err_ovf  <= 8'd0;
      reg_err_udf  <= 8'd0;
    end else begin
      if (i_srst) begin
        reg_err_kind <= 4'd0;
        reg_err_ctx  <= 5'd0;
        reg_err_addr <= 32'd0;
        reg_err_ovf  <= 8'd0;
        reg_err_udf  <= 8'd0;
      end else begin
        reg_err_ovf <= w_ovf_nxt;
        reg_err_udf <= w_udf_nxt;
        if (w_ev_kind != 4'd0) begin
          reg_err_kind <= w_ev_kind;
          reg_err_ctx  <= 5'(w_ev_ctx);
          reg_err_addr <= w_ev_addr;
        end
      end
    end
  end

  // Error record outputs: the registers of the record.
  assign o_err_kind = reg_err_kind;
  assign o_err_ctx  = reg_err_ctx;
  assign o_err_addr = reg_err_addr;
  assign o_err_ovf  = reg_err_ovf;
  assign o_err_udf  = reg_err_udf;

endmodule
