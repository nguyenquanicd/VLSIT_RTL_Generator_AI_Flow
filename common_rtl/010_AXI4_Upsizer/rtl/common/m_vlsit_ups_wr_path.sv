/*
 * Project      : VLSIT Common RTL library
 * Author       : Nguyen Quan and Claude Sonnet 5.5 (user)
 * AI Flow      : VLSIT RTL Generator AI Automation Flow
 * AI Flow Page : https://github.com/nguyenquanicd/VLSIT_RTL_Generator_AI_Model
 * Date         : 2026-10-28
 * Description  : Write path of the AXI upsizer: AW, W and B channels (section 5.1 of the
 *                specification). The AW is classified and converted by m_vlsit_ups_attribute, its
 *                S-side attributes are kept for the W path, and the converted AW goes through the
 *                AW slice. The W path is chosen by PARA_AXI_WR_INTERLEAVE_EN: 0 = in-order queue
 *                (m_vlsit_sfifo_1clk) and the packer m_vlsit_ups_wr_pack (AXI4); 1 = pending store
 *                and the write contexts of m_vlsit_ups_wr_interleave with WID interleave (AXI3),
 *                where the outstanding count of the write path counts an AW from its acceptance to
 *                the last conversion of its data. An AW is accepted when the store has room and the
 *                AW slice is ready (REQ-PARAM-003). The write data go through the W slice and the
 *                write response through the B slice. Every channel is registered by a slice (REQ-
 *                RTL-002). The IDs of the AXI4 profile have no WID: the W ID input is not used when
 *                PARA_AXI_WR_INTERLEAVE_EN is 0 and the W ID output is 0.
 */
`timescale 1ns/1ps

module m_vlsit_ups_wr_path #(
  // Parameter Description: data width of the subordinate side.
  // Parameter values: a power of 2 of 8 to 512; default is 32.
  // Parameter unit: bit
  parameter logic [31:0] PARA_AXI_S_DATA_W = 32,
  // Parameter Description: data width of the manager side. Larger than PARA_AXI_S_DATA_W.
  // Parameter values: a power of 2 of 16 to 1024; default is 128.
  // Parameter unit: bit
  parameter logic [31:0] PARA_AXI_M_DATA_W = 128,
  // Parameter Description: width of the AXI address fields.
  // Parameter values: 12 to 64; default is 32.
  // Parameter unit: bit
  parameter logic [31:0] PARA_AXI_ADDR_W = 32,
  // Parameter Description: width of the AXI ID fields.
  // Parameter values: 1 or more; default is 4.
  // Parameter unit: bit
  parameter logic [31:0] PARA_AXI_ID_W = 4,
  // Parameter Description: width of the burst length field: 8 for AXI4, 4 for AXI3.
  // Parameter values: 4 or 8; default is 8.
  // Parameter unit: bit
  parameter logic [31:0] PARA_AXI_LEN_W = 8,
  // Parameter Description: width of the lock field: 1 for AXI4, 2 for AXI3.
  // Parameter values: 1 or 2; default is 1.
  // Parameter unit: bit
  parameter logic [31:0] PARA_AXI_LOCK_W = 1,
  // Parameter Description: number of write transactions in flight (depth of the write queue).
  // Parameter values: a power of 2 of 2 or more; default is 4.
  // Parameter unit: count
  parameter logic [31:0] PARA_AXI_WR_OUTSTANDING_DEPTH = 4,
  // Parameter Description: selects the write data path: 0 = in-order queue and packer (AXI4),
  // 1 = pending store and write contexts with WID interleave (AXI3).
  // Parameter values: 0 or 1; default is 0.
  // Parameter unit: none
  parameter logic [31:0] PARA_AXI_WR_INTERLEAVE_EN = 0,
  // Parameter Description: number of write contexts when PARA_AXI_WR_INTERLEAVE_EN is 1.
  // At most PARA_AXI_WR_OUTSTANDING_DEPTH.
  // Parameter values: 1 or more; default is 2.
  // Parameter unit: count
  parameter logic [31:0] PARA_AXI_WR_INTERLEAVE_DEPTH = 2,
  localparam logic [31:0] LPARA_S_BYTES_LOG2 = $clog2(PARA_AXI_S_DATA_W / 8),
  localparam logic [31:0] LPARA_M_BYTES_LOG2 = $clog2(PARA_AXI_M_DATA_W / 8),
  localparam logic [31:0] LPARA_ADDR_LOW_W = (LPARA_M_BYTES_LOG2 > (LPARA_S_BYTES_LOG2 + 4)) ? LPARA_M_BYTES_LOG2 : (LPARA_S_BYTES_LOG2 + 4),
  localparam logic [31:0] LPARA_S_STRB_W = PARA_AXI_S_DATA_W / 8,
  localparam logic [31:0] LPARA_M_STRB_W = PARA_AXI_M_DATA_W / 8,
  localparam logic [31:0] LPARA_ENTRY_W = 1 + LPARA_ADDR_LOW_W + 3 + PARA_AXI_LEN_W + 2,
  localparam logic [31:0] LPARA_AW_W = PARA_AXI_ID_W + PARA_AXI_ADDR_W + PARA_AXI_LEN_W + 3 + 2 + PARA_AXI_LOCK_W + 4 + 3 + 4 + 4,
  localparam logic [31:0] LPARA_W_W = PARA_AXI_ID_W + PARA_AXI_M_DATA_W + LPARA_M_STRB_W + 1,
  localparam logic [31:0] LPARA_B_W = PARA_AXI_ID_W + 2,
  localparam logic [31:0] LPARA_CNT_W = $clog2(PARA_AXI_WR_OUTSTANDING_DEPTH + 1)
) (
  // Clock and reset
  input  wire                          i_clk_axi,
  input  wire                          i_rst_n_axi,

  // Subordinate-side AW channel
  input  wire                          i_s_aw_valid,
  input  wire  [PARA_AXI_ID_W-1:0]     i_s_aw_id,
  input  wire  [PARA_AXI_ADDR_W-1:0]   i_s_aw_addr,
  input  wire  [PARA_AXI_LEN_W-1:0]    i_s_aw_len,
  input  wire  [2:0]                   i_s_aw_size,
  input  wire  [1:0]                   i_s_aw_burst,
  input  wire  [PARA_AXI_LOCK_W-1:0]   i_s_aw_lock,
  input  wire  [3:0]                   i_s_aw_cache,
  input  wire  [2:0]                   i_s_aw_prot,
  input  wire  [3:0]                   i_s_aw_qos,
  input  wire  [3:0]                   i_s_aw_region,
  output logic                         o_s_aw_ready,

  // Subordinate-side W channel
  input  wire                          i_s_w_valid,
  input  wire  [PARA_AXI_ID_W-1:0]     i_s_w_id,
  input  wire  [PARA_AXI_S_DATA_W-1:0] i_s_w_data,
  input  wire  [LPARA_S_STRB_W-1:0]    i_s_w_strb,
  output logic                         o_s_w_ready,

  // Subordinate-side B channel
  output logic                         o_s_b_valid,
  output logic [PARA_AXI_ID_W-1:0]     o_s_b_id,
  output logic [1:0]                   o_s_b_resp,
  input  wire                          i_s_b_ready,

  // Manager-side AW channel
  output logic                         o_m_aw_valid,
  output logic [PARA_AXI_ID_W-1:0]     o_m_aw_id,
  output logic [PARA_AXI_ADDR_W-1:0]   o_m_aw_addr,
  output logic [PARA_AXI_LEN_W-1:0]    o_m_aw_len,
  output logic [2:0]                   o_m_aw_size,
  output logic [1:0]                   o_m_aw_burst,
  output logic [PARA_AXI_LOCK_W-1:0]   o_m_aw_lock,
  output logic [3:0]                   o_m_aw_cache,
  output logic [2:0]                   o_m_aw_prot,
  output logic [3:0]                   o_m_aw_qos,
  output logic [3:0]                   o_m_aw_region,
  input  wire                          i_m_aw_ready,

  // Manager-side W channel
  output logic                         o_m_w_valid,
  output logic [PARA_AXI_ID_W-1:0]     o_m_w_id,
  output logic [PARA_AXI_M_DATA_W-1:0] o_m_w_data,
  output logic [LPARA_M_STRB_W-1:0]    o_m_w_strb,
  output logic                         o_m_w_last,
  input  wire                          i_m_w_ready,

  // Manager-side B channel
  input  wire                          i_m_b_valid,
  input  wire  [PARA_AXI_ID_W-1:0]     i_m_b_id,
  input  wire  [1:0]                   i_m_b_resp,
  output logic                         o_m_b_ready
);
  // Internal signal declarations
  logic                           w_aw_pack;
  logic [PARA_AXI_ADDR_W-1:0]     w_aw_addr;
  logic [PARA_AXI_LEN_W-1:0]      w_aw_len;
  logic [2:0]                     w_aw_size;
  logic [1:0]                     w_aw_burst;
  logic [LPARA_ENTRY_W-1:0]       w_entry;
  logic                           w_store_full;
  logic                           w_aw_slice_ready;
  logic                           w_aw_acc;
  logic [LPARA_AW_W-1:0]          w_aw_slice_in;
  logic [LPARA_AW_W-1:0]          w_aw_slice_out;
  logic                           w_wbeat_valid;
  logic [PARA_AXI_ID_W-1:0]       w_wbeat_id;
  logic [PARA_AXI_M_DATA_W-1:0]   w_wbeat_data;
  logic [LPARA_M_STRB_W-1:0]      w_wbeat_strb;
  logic                           w_wbeat_last;
  logic                           w_w_slice_ready;
  logic [LPARA_W_W-1:0]           w_w_slice_in;
  logic [LPARA_W_W-1:0]           w_w_slice_out;
  logic [LPARA_B_W-1:0]           w_b_slice_out;

  // Queue entry: the S-side attributes that the W path needs (pack flag, low address bits, size,
  // length, burst). The M-side address bits above the low bits are not stored.
  assign w_entry = {w_aw_pack, i_s_aw_addr[LPARA_ADDR_LOW_W-1:0], i_s_aw_size, i_s_aw_len, i_s_aw_burst};

  // AW slice payload: the converted attributes and the fields that pass unchanged.
  assign w_aw_slice_in = {i_s_aw_id, w_aw_addr, w_aw_len, w_aw_size, w_aw_burst, i_s_aw_lock, i_s_aw_cache, i_s_aw_prot, i_s_aw_qos, i_s_aw_region};

  // AW acceptance: the store has room and the slice is ready. The slice takes the AW in the same
  // cycle as the store (it is offered only when the store has room).
  assign o_s_aw_ready = ~w_store_full & w_aw_slice_ready;
  assign w_aw_acc     = i_s_aw_valid & o_s_aw_ready;

  // Output mapping of the AW slice, the W slice and the B slice.
  assign {o_m_aw_id, o_m_aw_addr, o_m_aw_len, o_m_aw_size, o_m_aw_burst, o_m_aw_lock, o_m_aw_cache, o_m_aw_prot, o_m_aw_qos, o_m_aw_region} = w_aw_slice_out;
  assign {o_m_w_id, o_m_w_last, o_m_w_strb, o_m_w_data} = w_w_slice_out;
  assign {o_s_b_id, o_s_b_resp} = w_b_slice_out;

  // W slice payload: the converted W beat.
  assign w_w_slice_in = {w_wbeat_id, w_wbeat_last, w_wbeat_strb, w_wbeat_data};

  // Classification and attribute conversion of the AW.
  m_vlsit_ups_attribute #(
    .PARA_AXI_S_DATA_W (PARA_AXI_S_DATA_W),
    .PARA_AXI_M_DATA_W (PARA_AXI_M_DATA_W),
    .PARA_AXI_ADDR_W   (PARA_AXI_ADDR_W),
    .PARA_AXI_LEN_W    (PARA_AXI_LEN_W),
    .PARA_AXI_LOCK_W   (PARA_AXI_LOCK_W)
  ) u_aw_attribute (
    .i_addr       (i_s_aw_addr),
    .i_len        (i_s_aw_len),
    .i_size       (i_s_aw_size),
    .i_burst      (i_s_aw_burst),
    .i_lock       (i_s_aw_lock),
    .i_modifiable (i_s_aw_cache[1]),
    .o_pack       (w_aw_pack),
    .o_addr       (w_aw_addr),
    .o_len        (w_aw_len),
    .o_size       (w_aw_size),
    .o_burst      (w_aw_burst)
  );

  // Register slice of the AW channel (manager side).
  m_vlsit_ups_slice #(
    .PARA_SLICE_W (LPARA_AW_W)
  ) u_aw_slice (
    .i_clk_axi   (i_clk_axi),
    .i_rst_n_axi (i_rst_n_axi),
    .i_valid     (i_s_aw_valid & ~w_store_full),
    .i_data      (w_aw_slice_in),
    .o_ready     (w_aw_slice_ready),
    .o_valid     (o_m_aw_valid),
    .o_data      (w_aw_slice_out),
    .i_ready     (i_m_aw_ready)
  );

  // Register slice of the W channel (manager side).
  m_vlsit_ups_slice #(
    .PARA_SLICE_W (LPARA_W_W)
  ) u_w_slice (
    .i_clk_axi   (i_clk_axi),
    .i_rst_n_axi (i_rst_n_axi),
    .i_valid     (w_wbeat_valid),
    .i_data      (w_w_slice_in),
    .o_ready     (w_w_slice_ready),
    .o_valid     (o_m_w_valid),
    .o_data      (w_w_slice_out),
    .i_ready     (i_m_w_ready)
  );

  // Register slice of the B channel (subordinate side): the response passes unchanged.
  m_vlsit_ups_slice #(
    .PARA_SLICE_W (LPARA_B_W)
  ) u_b_slice (
    .i_clk_axi   (i_clk_axi),
    .i_rst_n_axi (i_rst_n_axi),
    .i_valid     (i_m_b_valid),
    .i_data      ({i_m_b_id, i_m_b_resp}),
    .o_ready     (o_m_b_ready),
    .o_valid     (o_s_b_valid),
    .o_data      (w_b_slice_out),
    .i_ready     (i_s_b_ready)
  );

  if (PARA_AXI_WR_INTERLEAVE_EN == 32'd0) begin : gen_inorder
    // In-order write data path: queue of the S-side attributes and the packer.
    logic [LPARA_ENTRY_W-1:0]     w_head_entry;
    logic                         w_head_empty;
    logic                         w_head_pop;
    logic                         w_head_pack;
    logic [LPARA_ADDR_LOW_W-1:0]  w_head_addr_low;
    logic [2:0]                   w_head_size;
    logic [PARA_AXI_LEN_W-1:0]    w_head_len;
    logic [1:0]                   w_head_burst;

    // Head entry fields.
    assign {w_head_pack, w_head_addr_low, w_head_size, w_head_len, w_head_burst} = w_head_entry;

    // The AXI4 profile has no WID: the M-side W ID is 0.
    assign w_wbeat_id = '0;

    // Write queue: the entry of an accepted AW, released with the last W beat of its transaction.
    m_vlsit_sfifo_1clk #(
      .PARA_SFIFO_DEPTH  (PARA_AXI_WR_OUTSTANDING_DEPTH),
      .PARA_SFIFO_DATA_W (LPARA_ENTRY_W)
    ) u_wr_queue (
      .i_clk_fifo   (i_clk_axi),
      .i_rst_n_fifo (i_rst_n_axi),
      .i_wr_en      (w_aw_acc),
      .i_wr_data    (w_entry),
      .o_full       (w_store_full),
      .i_rd_en      (w_head_pop),
      .o_rd_data    (w_head_entry),
      .o_empty      (w_head_empty),
      .o_count      ()
    );

    // Packer: converts the S-side W beats of the head transaction into M-side W beats.
    m_vlsit_ups_wr_pack #(
      .PARA_AXI_S_DATA_W (PARA_AXI_S_DATA_W),
      .PARA_AXI_M_DATA_W (PARA_AXI_M_DATA_W),
      .PARA_AXI_LEN_W    (PARA_AXI_LEN_W)
    ) u_wr_pack (
      .i_clk_axi       (i_clk_axi),
      .i_rst_n_axi     (i_rst_n_axi),
      .i_head_valid    (~w_head_empty),
      .i_head_pack     (w_head_pack),
      .i_head_addr_low (w_head_addr_low),
      .i_head_size     (w_head_size),
      .i_head_len      (w_head_len),
      .i_head_burst    (w_head_burst),
      .o_head_pop      (w_head_pop),
      .i_wvalid        (i_s_w_valid),
      .i_wdata         (i_s_w_data),
      .i_wstrb         (i_s_w_strb),
      .o_wready        (o_s_w_ready),
      .o_beat_valid    (w_wbeat_valid),
      .o_beat_data     (w_wbeat_data),
      .o_beat_strb     (w_wbeat_strb),
      .o_beat_last     (w_wbeat_last),
      .i_beat_ready    (w_w_slice_ready)
    );
  end else begin : gen_interleave
    // AXI3 write data path: pending store of the AW not yet bound, write contexts, and the count of
    // the AW in flight (accepted and not fully converted).
    logic [LPARA_CNT_W-1:0]       reg_out_cnt;
    logic [LPARA_CNT_W-1:0]       w_pend_count;
    logic                         w_pend_any;
    logic [PARA_AXI_ID_W-1:0]     w_find_id;
    logic                         w_find_hit;
    logic [LPARA_ENTRY_W-1:0]     w_find_entry;
    logic                         w_take_en;
    logic                         w_txn_done;
    logic                         w_find_pack;
    logic [LPARA_ADDR_LOW_W-1:0]  w_find_addr_low;
    logic [2:0]                   w_find_size;
    logic [PARA_AXI_LEN_W-1:0]    w_find_len;
    logic [1:0]                   w_find_burst;

    // Found entry fields, and the pending flag.
    assign {w_find_pack, w_find_addr_low, w_find_size, w_find_len, w_find_burst} = w_find_entry;
    assign w_pend_any = |w_pend_count;

    // The store is full when the AW in flight reach the outstanding depth.
    assign w_store_full = (reg_out_cnt == $bits(reg_out_cnt)'(PARA_AXI_WR_OUTSTANDING_DEPTH));

    // Outstanding count: one more for an accepted AW, one less when the data of a transaction is
    // fully converted. Control state, reset to 0.
    always_ff @(posedge i_clk_axi, negedge i_rst_n_axi) begin : p_ff_out_cnt
      if (!i_rst_n_axi)
        reg_out_cnt <= '0;
      else
        reg_out_cnt <= reg_out_cnt + $bits(reg_out_cnt)'(w_aw_acc) - $bits(reg_out_cnt)'(w_txn_done);
    end

    // Pending store: the AW that no write context has taken yet, searched by ID, oldest first.
    m_vlsit_ups_pending #(
      .PARA_AXI_ID_W        (PARA_AXI_ID_W),
      .PARA_PENDING_DEPTH   (PARA_AXI_WR_OUTSTANDING_DEPTH),
      .PARA_PENDING_ENTRY_W (LPARA_ENTRY_W)
    ) u_wr_pending (
      .i_clk_axi    (i_clk_axi),
      .i_rst_n_axi  (i_rst_n_axi),
      .i_push_en    (w_aw_acc),
      .i_push_id    (i_s_aw_id),
      .i_push_entry (w_entry),
      .i_find_id    (w_find_id),
      .o_find_hit   (w_find_hit),
      .o_find_entry (w_find_entry),
      .i_take_en    (w_take_en),
      .o_count      (w_pend_count)
    );

    // Write contexts: stage, binding by WID and conversion of the interleaved W beats.
    m_vlsit_ups_wr_interleave #(
      .PARA_AXI_S_DATA_W           (PARA_AXI_S_DATA_W),
      .PARA_AXI_M_DATA_W           (PARA_AXI_M_DATA_W),
      .PARA_AXI_ID_W               (PARA_AXI_ID_W),
      .PARA_AXI_LEN_W              (PARA_AXI_LEN_W),
      .PARA_AXI_WR_INTERLEAVE_DEPTH (PARA_AXI_WR_INTERLEAVE_DEPTH)
    ) u_wr_interleave (
      .i_clk_axi       (i_clk_axi),
      .i_rst_n_axi     (i_rst_n_axi),
      .i_pend_any      (w_pend_any),
      .o_find_id       (w_find_id),
      .i_find_hit      (w_find_hit),
      .i_find_pack     (w_find_pack),
      .i_find_addr_low (w_find_addr_low),
      .i_find_size     (w_find_size),
      .i_find_len      (w_find_len),
      .i_find_burst    (w_find_burst),
      .o_take_en       (w_take_en),
      .i_wvalid        (i_s_w_valid),
      .i_wid           (i_s_w_id),
      .i_wdata         (i_s_w_data),
      .i_wstrb         (i_s_w_strb),
      .o_wready        (o_s_w_ready),
      .o_beat_valid    (w_wbeat_valid),
      .o_beat_id       (w_wbeat_id),
      .o_beat_data     (w_wbeat_data),
      .o_beat_strb     (w_wbeat_strb),
      .o_beat_last     (w_wbeat_last),
      .i_beat_ready    (w_w_slice_ready),
      .o_txn_done      (w_txn_done)
    );
  end

endmodule
