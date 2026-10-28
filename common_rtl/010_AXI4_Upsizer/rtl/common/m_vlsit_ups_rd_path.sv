/*
 * Project      : VLSIT Common RTL library
 * Author       : Nguyen Quan and Claude Sonnet 5.5 (user)
 * AI Flow      : VLSIT RTL Generator AI Automation Flow
 * AI Flow Page : https://github.com/nguyenquanicd/VLSIT_RTL_Generator_AI_Model
 * Date         : 2026-10-28
 * Description  : Read path of the AXI upsizer: AR and R channels (section 5.1 of the
 *                specification). The AR is classified and converted by m_vlsit_ups_attribute, its
 *                S-side attributes are kept in the read queue (m_vlsit_sfifo_1clk) for the R path,
 *                and the converted AR goes through the AR slice. An AR is accepted when the queue
 *                has room and the AR slice is ready (REQ-PARAM-003). The R path
 *                m_vlsit_ups_rd_unpack takes the M-side read data in the order of the queue (no
 *                interleave, ASM-002), gives the S beats to the R slice and releases the queue
 *                entry with the last S beat. Every channel is registered by a slice (REQ-RTL-002).
 */
`timescale 1ns/1ps

module m_vlsit_ups_rd_path #(
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
  // Parameter Description: number of read transactions in flight (depth of the read queue).
  // Parameter values: a power of 2 of 2 or more; default is 4.
  // Parameter unit: count
  parameter logic [31:0] PARA_AXI_RD_OUTSTANDING_DEPTH = 4,
  localparam logic [31:0] LPARA_S_BYTES_LOG2 = $clog2(PARA_AXI_S_DATA_W / 8),
  localparam logic [31:0] LPARA_M_BYTES_LOG2 = $clog2(PARA_AXI_M_DATA_W / 8),
  localparam logic [31:0] LPARA_ADDR_LOW_W = (LPARA_M_BYTES_LOG2 > (LPARA_S_BYTES_LOG2 + 4)) ? LPARA_M_BYTES_LOG2 : (LPARA_S_BYTES_LOG2 + 4),
  localparam logic [31:0] LPARA_ENTRY_W = 1 + LPARA_ADDR_LOW_W + 3 + PARA_AXI_LEN_W + 2,
  localparam logic [31:0] LPARA_AR_W = PARA_AXI_ID_W + PARA_AXI_ADDR_W + PARA_AXI_LEN_W + 3 + 2 + PARA_AXI_LOCK_W + 4 + 3 + 4 + 4,
  localparam logic [31:0] LPARA_R_W = PARA_AXI_ID_W + PARA_AXI_S_DATA_W + 2 + 1,
  localparam logic [31:0] LPARA_CNT_W = $clog2(PARA_AXI_RD_OUTSTANDING_DEPTH + 1)
) (
  // Clock and reset
  input  wire                          i_clk_axi,
  input  wire                          i_rst_n_axi,

  // Subordinate-side AR channel
  input  wire                          i_s_ar_valid,
  input  wire  [PARA_AXI_ID_W-1:0]     i_s_ar_id,
  input  wire  [PARA_AXI_ADDR_W-1:0]   i_s_ar_addr,
  input  wire  [PARA_AXI_LEN_W-1:0]    i_s_ar_len,
  input  wire  [2:0]                   i_s_ar_size,
  input  wire  [1:0]                   i_s_ar_burst,
  input  wire  [PARA_AXI_LOCK_W-1:0]   i_s_ar_lock,
  input  wire  [3:0]                   i_s_ar_cache,
  input  wire  [2:0]                   i_s_ar_prot,
  input  wire  [3:0]                   i_s_ar_qos,
  input  wire  [3:0]                   i_s_ar_region,
  output logic                         o_s_ar_ready,

  // Subordinate-side R channel
  output logic                         o_s_r_valid,
  output logic [PARA_AXI_ID_W-1:0]     o_s_r_id,
  output logic [PARA_AXI_S_DATA_W-1:0] o_s_r_data,
  output logic [1:0]                   o_s_r_resp,
  output logic                         o_s_r_last,
  input  wire                          i_s_r_ready,

  // Manager-side AR channel
  output logic                         o_m_ar_valid,
  output logic [PARA_AXI_ID_W-1:0]     o_m_ar_id,
  output logic [PARA_AXI_ADDR_W-1:0]   o_m_ar_addr,
  output logic [PARA_AXI_LEN_W-1:0]    o_m_ar_len,
  output logic [2:0]                   o_m_ar_size,
  output logic [1:0]                   o_m_ar_burst,
  output logic [PARA_AXI_LOCK_W-1:0]   o_m_ar_lock,
  output logic [3:0]                   o_m_ar_cache,
  output logic [2:0]                   o_m_ar_prot,
  output logic [3:0]                   o_m_ar_qos,
  output logic [3:0]                   o_m_ar_region,
  input  wire                          i_m_ar_ready,

  // Manager-side R channel
  input  wire                          i_m_r_valid,
  input  wire  [PARA_AXI_ID_W-1:0]     i_m_r_id,
  input  wire  [PARA_AXI_M_DATA_W-1:0] i_m_r_data,
  input  wire  [1:0]                   i_m_r_resp,
  output logic                         o_m_r_ready
);
  // Internal signal declarations
  logic                           w_ar_pack;
  logic [PARA_AXI_ADDR_W-1:0]     w_ar_addr;
  logic [PARA_AXI_LEN_W-1:0]      w_ar_len;
  logic [2:0]                     w_ar_size;
  logic [1:0]                     w_ar_burst;
  logic [LPARA_ENTRY_W-1:0]       w_entry;
  logic                           w_queue_full;
  logic                           w_queue_empty;
  logic [LPARA_CNT_W-1:0]         w_queue_count;
  logic [LPARA_ENTRY_W-1:0]       w_head_entry;
  logic                           w_head_pop;
  logic                           w_head_pack;
  logic [LPARA_ADDR_LOW_W-1:0]    w_head_addr_low;
  logic [2:0]                     w_head_size;
  logic [PARA_AXI_LEN_W-1:0]      w_head_len;
  logic [1:0]                     w_head_burst;
  logic                           w_head_has_nxt;
  logic                           w_ar_slice_ready;
  logic                           w_ar_acc;
  logic [LPARA_AR_W-1:0]          w_ar_slice_in;
  logic [LPARA_AR_W-1:0]          w_ar_slice_out;
  logic                           w_rbeat_valid;
  logic [PARA_AXI_ID_W-1:0]       w_rbeat_id;
  logic [PARA_AXI_S_DATA_W-1:0]   w_rbeat_data;
  logic [1:0]                     w_rbeat_resp;
  logic                           w_rbeat_last;
  logic                           w_r_slice_ready;
  logic [LPARA_R_W-1:0]           w_r_slice_in;
  logic [LPARA_R_W-1:0]           w_r_slice_out;

  // Queue entry: the S-side attributes that the R path needs (pack flag, low address bits, size,
  // length, burst).
  assign w_entry = {w_ar_pack, i_s_ar_addr[LPARA_ADDR_LOW_W-1:0], i_s_ar_size, i_s_ar_len, i_s_ar_burst};

  // Head entry fields, and the flag that the queue holds a second entry (used by the R path).
  assign {w_head_pack, w_head_addr_low, w_head_size, w_head_len, w_head_burst} = w_head_entry;
  assign w_head_has_nxt = (w_queue_count > $bits(w_queue_count)'(1));

  // AR slice payload: the converted attributes and the fields that pass unchanged.
  assign w_ar_slice_in = {i_s_ar_id, w_ar_addr, w_ar_len, w_ar_size, w_ar_burst, i_s_ar_lock, i_s_ar_cache, i_s_ar_prot, i_s_ar_qos, i_s_ar_region};

  // AR acceptance: the queue has room and the slice is ready. The slice takes the AR in the same
  // cycle as the queue (it is offered only when the queue has room).
  assign o_s_ar_ready = ~w_queue_full & w_ar_slice_ready;
  assign w_ar_acc     = i_s_ar_valid & o_s_ar_ready;

  // R slice payload: the S beat of the R path.
  assign w_r_slice_in = {w_rbeat_id, w_rbeat_last, w_rbeat_resp, w_rbeat_data};

  // Output mapping of the AR slice and the R slice.
  assign {o_m_ar_id, o_m_ar_addr, o_m_ar_len, o_m_ar_size, o_m_ar_burst, o_m_ar_lock, o_m_ar_cache, o_m_ar_prot, o_m_ar_qos, o_m_ar_region} = w_ar_slice_out;
  assign {o_s_r_id, o_s_r_last, o_s_r_resp, o_s_r_data} = w_r_slice_out;

  // Classification and attribute conversion of the AR.
  m_vlsit_ups_attribute #(
    .PARA_AXI_S_DATA_W (PARA_AXI_S_DATA_W),
    .PARA_AXI_M_DATA_W (PARA_AXI_M_DATA_W),
    .PARA_AXI_ADDR_W   (PARA_AXI_ADDR_W),
    .PARA_AXI_LEN_W    (PARA_AXI_LEN_W),
    .PARA_AXI_LOCK_W   (PARA_AXI_LOCK_W)
  ) u_ar_attribute (
    .i_addr       (i_s_ar_addr),
    .i_len        (i_s_ar_len),
    .i_size       (i_s_ar_size),
    .i_burst      (i_s_ar_burst),
    .i_lock       (i_s_ar_lock),
    .i_modifiable (i_s_ar_cache[1]),
    .o_pack       (w_ar_pack),
    .o_addr       (w_ar_addr),
    .o_len        (w_ar_len),
    .o_size       (w_ar_size),
    .o_burst      (w_ar_burst)
  );

  // Read queue: the entry of an accepted AR, released with the last S beat of its transaction.
  m_vlsit_sfifo_1clk #(
    .PARA_SFIFO_DEPTH  (PARA_AXI_RD_OUTSTANDING_DEPTH),
    .PARA_SFIFO_DATA_W (LPARA_ENTRY_W)
  ) u_rd_queue (
    .i_clk_fifo   (i_clk_axi),
    .i_rst_n_fifo (i_rst_n_axi),
    .i_wr_en      (w_ar_acc),
    .i_wr_data    (w_entry),
    .o_full       (w_queue_full),
    .i_rd_en      (w_head_pop),
    .o_rd_data    (w_head_entry),
    .o_empty      (w_queue_empty),
    .o_count      (w_queue_count)
  );

  // Register slice of the AR channel (manager side).
  m_vlsit_ups_slice #(
    .PARA_SLICE_W (LPARA_AR_W)
  ) u_ar_slice (
    .i_clk_axi   (i_clk_axi),
    .i_rst_n_axi (i_rst_n_axi),
    .i_valid     (i_s_ar_valid & ~w_queue_full),
    .i_data      (w_ar_slice_in),
    .o_ready     (w_ar_slice_ready),
    .o_valid     (o_m_ar_valid),
    .o_data      (w_ar_slice_out),
    .i_ready     (i_m_ar_ready)
  );

  // Unpacker: converts the M-side R beats into the S-side R beats of the head transaction.
  m_vlsit_ups_rd_unpack #(
    .PARA_AXI_S_DATA_W (PARA_AXI_S_DATA_W),
    .PARA_AXI_M_DATA_W (PARA_AXI_M_DATA_W),
    .PARA_AXI_ID_W     (PARA_AXI_ID_W),
    .PARA_AXI_LEN_W    (PARA_AXI_LEN_W)
  ) u_rd_unpack (
    .i_clk_axi       (i_clk_axi),
    .i_rst_n_axi     (i_rst_n_axi),
    .i_head_has_nxt  (w_head_has_nxt),
    .i_head_valid    (~w_queue_empty),
    .i_head_pack     (w_head_pack),
    .i_head_addr_low (w_head_addr_low),
    .i_head_size     (w_head_size),
    .i_head_len      (w_head_len),
    .i_head_burst    (w_head_burst),
    .o_head_pop      (w_head_pop),
    .i_rvalid        (i_m_r_valid),
    .i_rid           (i_m_r_id),
    .i_rdata         (i_m_r_data),
    .i_rresp         (i_m_r_resp),
    .o_rready        (o_m_r_ready),
    .o_beat_valid    (w_rbeat_valid),
    .o_beat_id       (w_rbeat_id),
    .o_beat_data     (w_rbeat_data),
    .o_beat_resp     (w_rbeat_resp),
    .o_beat_last     (w_rbeat_last),
    .i_beat_ready    (w_r_slice_ready)
  );

  // Register slice of the R channel (subordinate side).
  m_vlsit_ups_slice #(
    .PARA_SLICE_W (LPARA_R_W)
  ) u_r_slice (
    .i_clk_axi   (i_clk_axi),
    .i_rst_n_axi (i_rst_n_axi),
    .i_valid     (w_rbeat_valid),
    .i_data      (w_r_slice_in),
    .o_ready     (w_r_slice_ready),
    .o_valid     (o_s_r_valid),
    .o_data      (w_r_slice_out),
    .i_ready     (i_s_r_ready)
  );

endmodule
