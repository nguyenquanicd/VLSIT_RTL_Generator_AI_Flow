/*
 * Project      : QSPI_Controller
 * Author       : Nguyen Quan (user)
 * AI Flow      : VLSIT RTL Generator AI Automation Flow
 * AI Flow Page : https://github.com/nguyenquanicd/VLSIT_RTL_Generator_AI_Model
 * Date         : 2026-11-03
 * Description  : Standard SPI target engine with independent sample-edge RX and shift-edge TX
 *                state (DEC-018). The final CPHA=1 sample needs no later SCLK edge.
 */
`timescale 1ns/1ps

module m_qspi_target_engine #(
  localparam logic [31:0] LPARA_TX_ONES = 32'hFFFF_FFFF,
  localparam logic [31:0] LPARA_MIN_WORD_BITS = 32'd4,
  localparam logic [31:0] LPARA_MAX_WORD_BITS = 32'd32
) (
  // APB status clock and reset
  input  wire         i_clk_apb,
  input  wire         i_rst_n_apb,

  // Selected target sample and shift clocks
  input  wire         i_clk_tgt_sample,
  input  wire         i_clk_tgt_shift,
  input  wire         i_rst_n_tgt,

  // Target enable, frame and word configuration
  input  wire         i_target_en,
  input  wire         i_spi_cs_tgt_n,
  input  wire         i_cpha_cfg,
  input  wire         i_lsb_first_cfg,
  input  wire  [5:0]  i_word_bits_cfg,

  // First-word APB holding slot
  input  wire         i_head_valid,
  input  wire  [31:0] i_head_data,
  input  wire         i_head_token,
  output logic        o_head_pop,

  // Tail TX FIFO
  input  wire  [31:0] i_tx_data,
  input  wire         i_tx_empty,
  output logic        o_tx_pop,

  // RX FIFO
  input  wire         i_rx_full,
  output logic [31:0] o_rx_data,
  output logic        o_rx_push,

  // Shared target pads and status events
  input  wire  [3:0]  i_spi_io_i,
  output logic [3:0]  o_spi_io_o,
  output logic [3:0]  o_spi_io_oe,
  output logic        o_busy,
  output logic        o_frame_done,
  output logic        o_tx_err_tgl,
  output logic        o_rx_full_err_tgl,
  output logic        o_rx_partial_err
);

  logic [31:0] reg_tx_word;
  logic [31:0] reg_tx_prefetch_data;
  logic [5:0] reg_tx_word_bits;
  logic [5:0] reg_tx_bit_idx;
  logic reg_tx_frame_active;
  logic reg_tx_word_valid;
  logic reg_tx_lsb_first;
  logic reg_tx_prefetch_valid;
  logic reg_tx_prefetch_pending;
  logic reg_tx_underflow_seen;
  logic reg_tx_err_tgl;
  logic [31:0] reg_rx_word;
  logic [5:0] reg_rx_word_bits;
  logic [5:0] reg_rx_bit_count;
  logic reg_rx_frame_active;
  logic reg_rx_lsb_first;
  logic reg_rx_full_seen;
  logic reg_rx_full_err_tgl;
  logic reg_head_token_seen;
  logic reg_partial_frame;
  logic reg_cs_sync_1;
  logic reg_cs_sync_2;
  logic reg_cs_sync_prev;
  logic reg_partial_sync_1_apb;
  logic reg_partial_sync_2_apb;
  logic reg_frame_done_pulse;
  logic reg_rx_partial_pulse;
  logic [31:0] w_rx_word_nxt;
  logic [5:0] w_rx_word_bits;
  logic [5:0] w_rx_frame_bits_cfg;
  logic [5:0] w_rx_bit_count;
  logic [5:0] w_tx_word_bits;
  logic w_tx_config_valid;
  logic w_rx_config_valid;
  logic w_rx_lsb_first;
  logic w_rx_word_complete;
  logic w_tx_word_wrap;
  logic w_tx_underflow_event;
  logic w_rx_full_event;
  logic w_tx_prefetch_consume;
  logic w_rst_n_rx_frame;
  logic w_rst_n_tx_frame;
  logic w_tx_first_bit;
  logic [4:0] w_tx_first_bit_idx;
  logic [4:0] w_tx_word_bit_idx;
  logic w_head_available;

  // Word-length validation is shared by the independent RX and TX timing domains.
  always_comb begin : p_com_tgt_cfg
    w_tx_word_bits = reg_tx_frame_active ? reg_tx_word_bits : i_word_bits_cfg;
    w_tx_config_valid = (w_tx_word_bits >= LPARA_MIN_WORD_BITS[5:0]) &&
                        (w_tx_word_bits <= LPARA_MAX_WORD_BITS[5:0]);
    w_rx_config_valid = (w_rx_frame_bits_cfg >= LPARA_MIN_WORD_BITS[5:0]) &&
                        (w_rx_frame_bits_cfg <= LPARA_MAX_WORD_BITS[5:0]);
    w_rx_lsb_first = reg_rx_frame_active ? reg_rx_lsb_first : i_lsb_first_cfg;
    w_head_available = i_head_valid && (i_head_token != reg_head_token_seen);
  end

  // Remember each accepted APB head token so a fast second word cannot acknowledge it twice.
  always_ff @(posedge i_clk_tgt_sample, negedge i_rst_n_tgt) begin : p_ff_tgt_head_token
    if (!i_rst_n_tgt)
      reg_head_token_seen <= 1'b0;
    else if (o_head_pop)
      reg_head_token_seen <= i_head_token;
  end

  // CS deassertion resets per-frame state even if the external SCLK has stopped.
  assign w_rst_n_rx_frame = i_rst_n_tgt && !i_spi_cs_tgt_n;
  assign w_rst_n_tx_frame = i_rst_n_tgt && !i_spi_cs_tgt_n;

  // Build the receive word including the bit sampled at the current sample-clock edge.
  always_comb begin : p_com_tgt_rx_word
    w_rx_word_bits = reg_rx_frame_active ? reg_rx_word_bits : i_word_bits_cfg;
    w_rx_frame_bits_cfg = reg_rx_frame_active ? reg_rx_word_bits : i_word_bits_cfg;
    w_rx_bit_count = reg_rx_frame_active ? reg_rx_bit_count : 6'd0;
    w_rx_word_nxt = reg_rx_frame_active ? reg_rx_word : 32'd0;
    if (w_rx_lsb_first)
      w_rx_word_nxt[w_rx_bit_count[4:0]] = i_spi_io_i[0];
    else
      w_rx_word_nxt = {w_rx_word_nxt[30:0], i_spi_io_i[0]};
    w_rx_word_complete = !i_spi_cs_tgt_n && i_target_en && w_rx_config_valid &&
                         ((w_rx_bit_count + 6'd1) >= w_rx_word_bits);
    o_rx_push = w_rx_word_complete && !i_rx_full;
    o_rx_data = w_rx_word_nxt;
    w_rx_full_event = w_rx_word_complete && i_rx_full;
  end

  // RX samples on the configured sample edge; FIFO writes occur on this same selected edge.
  always_ff @(posedge i_clk_tgt_sample, negedge w_rst_n_rx_frame) begin : p_ff_tgt_rx
    if (!w_rst_n_rx_frame) begin
      reg_rx_word <= 32'd0;
      reg_rx_word_bits <= LPARA_MIN_WORD_BITS[5:0];
      reg_rx_bit_count <= 6'd0;
      reg_rx_frame_active <= 1'b0;
      reg_rx_lsb_first <= 1'b0;
    end else if (i_target_en && w_rx_config_valid) begin
      if (!reg_rx_frame_active) begin
        reg_rx_frame_active <= 1'b1;
        reg_rx_word_bits <= i_word_bits_cfg;
        reg_rx_lsb_first <= i_lsb_first_cfg;
      end
      if (w_rx_word_complete) begin
        reg_rx_word <= 32'd0;
        reg_rx_bit_count <= 6'd0;
      end else begin
        reg_rx_word <= w_rx_word_nxt;
        reg_rx_bit_count <= w_rx_bit_count + 6'd1;
      end
    end
  end

  // Keep the current partial-word condition stable across CS deassertion for APB event capture.
  always_ff @(posedge i_clk_tgt_sample, negedge i_rst_n_tgt) begin : p_ff_tgt_partial
    if (!i_rst_n_tgt) begin
      reg_partial_frame <= 1'b0;
    end else if (i_target_en && w_rx_config_valid) begin
      if (w_rx_word_complete)
        reg_partial_frame <= 1'b0;
      else
        reg_partial_frame <= 1'b1;
    end
  end

  // Latch FIFO-full once per frame; the RX stream continues and drops newest complete words.
  // A CS-derived asynchronous reset is only used to re-arm the per-frame seen flag.
  always_ff @(posedge i_clk_tgt_sample, negedge w_rst_n_rx_frame) begin : p_ff_tgt_rx_err_seen
    if (!w_rst_n_rx_frame)
      reg_rx_full_seen <= 1'b0;
    else if (w_rx_full_event && !reg_rx_full_seen)
      reg_rx_full_seen <= 1'b1;
  end

  // Convert each frame's first RX-full event to a toggle for the APB-side synchronizer.
  always_ff @(posedge i_clk_tgt_sample, negedge i_rst_n_tgt) begin : p_ff_tgt_rx_err_tgl
    if (!i_rst_n_tgt)
      reg_rx_full_err_tgl <= 1'b0;
    else if (w_rx_full_event && !reg_rx_full_seen)
      reg_rx_full_err_tgl <= ~reg_rx_full_err_tgl;
  end

  // Prefetch the next TX word one selected shift edge before it is needed.
  always_ff @(posedge i_clk_tgt_shift, negedge i_rst_n_tgt) begin : p_ff_tgt_tx_prefetch
    if (!i_rst_n_tgt) begin
      reg_tx_prefetch_data <= 32'd0;
      reg_tx_prefetch_valid <= 1'b0;
      reg_tx_prefetch_pending <= 1'b0;
    end else begin
      if (o_tx_pop)
        reg_tx_prefetch_pending <= 1'b1;
      if (reg_tx_prefetch_pending) begin
        reg_tx_prefetch_data <= i_tx_data;
        reg_tx_prefetch_valid <= 1'b1;
        reg_tx_prefetch_pending <= 1'b0;
      end
      if ((w_tx_word_wrap || w_tx_prefetch_consume) && reg_tx_prefetch_valid)
        reg_tx_prefetch_valid <= 1'b0;
    end
  end

  // TX changes on the configured shift edge and retains a prefetched tail word between frames.
  always_ff @(posedge i_clk_tgt_shift, negedge w_rst_n_tx_frame) begin : p_ff_tgt_tx
    if (!w_rst_n_tx_frame) begin
      reg_tx_word <= LPARA_TX_ONES;
      reg_tx_word_bits <= LPARA_MIN_WORD_BITS[5:0];
      reg_tx_bit_idx <= 6'd0;
      reg_tx_frame_active <= 1'b0;
      reg_tx_word_valid <= 1'b0;
      reg_tx_lsb_first <= 1'b0;
    end else if (i_target_en && w_tx_config_valid) begin
      casez ({reg_tx_frame_active, w_tx_word_wrap})
        2'b0?: begin
        reg_tx_frame_active <= 1'b1;
        reg_tx_word_bits <= w_tx_word_bits;
        reg_tx_lsb_first <= i_lsb_first_cfg;
        reg_tx_bit_idx <= i_cpha_cfg ? 6'd0 : 6'd1;
        if (w_head_available) begin
          reg_tx_word <= i_head_data;
          reg_tx_word_valid <= 1'b1;
        end else if (reg_tx_prefetch_valid) begin
          reg_tx_word <= reg_tx_prefetch_data;
          reg_tx_word_valid <= 1'b1;
        end else begin
          reg_tx_word <= LPARA_TX_ONES;
          reg_tx_word_valid <= 1'b0;
        end
        end
        2'b11: begin
        reg_tx_bit_idx <= 6'd0;
        if (reg_tx_prefetch_valid) begin
          reg_tx_word <= reg_tx_prefetch_data;
          reg_tx_word_valid <= 1'b1;
        end else begin
          reg_tx_word <= LPARA_TX_ONES;
          reg_tx_word_valid <= 1'b0;
        end
        end
        2'b10: begin
          if (reg_tx_bit_idx < (reg_tx_word_bits - 6'd1))
            reg_tx_bit_idx <= reg_tx_bit_idx + 6'd1;
        end
        default: begin
          reg_tx_bit_idx <= reg_tx_bit_idx;
        end
      endcase
    end
  end

  // Report target TX starvation once per frame; missing bits are driven HIGH.
  always_ff @(posedge i_clk_tgt_shift, negedge w_rst_n_tx_frame) begin : p_ff_tgt_tx_err_seen
    if (!w_rst_n_tx_frame)
      reg_tx_underflow_seen <= 1'b0;
    else if (w_tx_underflow_event && !reg_tx_underflow_seen)
      reg_tx_underflow_seen <= 1'b1;
  end

  // Convert each frame's first TX-underflow event to a toggle for the APB-side synchronizer.
  always_ff @(posedge i_clk_tgt_shift, negedge i_rst_n_tgt) begin : p_ff_tgt_tx_err_tgl
    if (!i_rst_n_tgt)
      reg_tx_err_tgl <= 1'b0;
    else if (w_tx_underflow_event && !reg_tx_underflow_seen)
      reg_tx_err_tgl <= ~reg_tx_err_tgl;
  end

  // Synchronize CS and the held partial-word indication into APB for software status.
  always_ff @(posedge i_clk_apb, negedge i_rst_n_apb) begin : p_ff_apb_frame_events
    if (!i_rst_n_apb) begin
      reg_cs_sync_1 <= 1'b1;
      reg_cs_sync_2 <= 1'b1;
      reg_cs_sync_prev <= 1'b1;
      reg_partial_sync_1_apb <= 1'b0;
      reg_partial_sync_2_apb <= 1'b0;
      reg_frame_done_pulse <= 1'b0;
      reg_rx_partial_pulse <= 1'b0;
    end else begin
      reg_cs_sync_1 <= i_spi_cs_tgt_n;
      reg_cs_sync_2 <= reg_cs_sync_1;
      reg_cs_sync_prev <= reg_cs_sync_2;
      reg_partial_sync_1_apb <= reg_partial_frame;
      reg_partial_sync_2_apb <= reg_partial_sync_1_apb;
      reg_frame_done_pulse <= 1'b0;
      reg_rx_partial_pulse <= 1'b0;
      if (reg_cs_sync_2 && !reg_cs_sync_prev) begin
        reg_frame_done_pulse <= 1'b1;
        if (reg_partial_sync_2_apb)
          reg_rx_partial_pulse <= 1'b1;
      end
    end
  end

  // Output the first target word from the APB head before the first SCLK edge.
  always_comb begin : p_com_tgt_pads
    w_tx_first_bit = 1'b1;
    w_tx_first_bit_idx = i_word_bits_cfg[4:0] - 5'd1;
    w_tx_word_bit_idx = reg_tx_word_bits[4:0] - 5'd1 - reg_tx_bit_idx[4:0];
    if (i_lsb_first_cfg && w_tx_config_valid)
      w_tx_first_bit = w_head_available ? i_head_data[0] :
                       (reg_tx_prefetch_valid ? reg_tx_prefetch_data[0] : 1'b1);
    else if (w_tx_config_valid)
      w_tx_first_bit = w_head_available ? i_head_data[w_tx_first_bit_idx] :
                       (reg_tx_prefetch_valid ? reg_tx_prefetch_data[w_tx_first_bit_idx] : 1'b1);

    w_tx_word_wrap = reg_tx_frame_active &&
                     (reg_tx_bit_idx == (reg_tx_word_bits - 6'd1));
    w_tx_prefetch_consume = !reg_tx_frame_active && !w_head_available &&
                            reg_tx_prefetch_valid && !i_spi_cs_tgt_n && i_target_en;
    w_tx_underflow_event = !i_spi_cs_tgt_n && i_target_en &&
                           ((!reg_tx_frame_active && !w_head_available && !reg_tx_prefetch_valid) ||
                            (w_tx_word_wrap && !reg_tx_prefetch_valid));
    o_head_pop = w_rx_word_complete && w_head_available;
    o_tx_pop = !i_spi_cs_tgt_n && i_target_en && reg_tx_frame_active &&
               !reg_tx_prefetch_valid && !reg_tx_prefetch_pending && !i_tx_empty;
    o_spi_io_o = 4'b0000;
    o_spi_io_oe = 4'b0000;
    if (i_rst_n_tgt && !i_spi_cs_tgt_n && i_target_en) begin
      casez ({reg_tx_frame_active, reg_tx_word_valid, reg_tx_lsb_first})
        3'b0??: o_spi_io_o[1] = w_tx_first_bit;
        3'b11? : o_spi_io_o[1] = reg_tx_word[reg_tx_lsb_first ? reg_tx_bit_idx[4:0] :
                                               w_tx_word_bit_idx];
        default: o_spi_io_o[1] = 1'b1;
      endcase
      o_spi_io_oe[1] = 1'b1;
    end
    o_busy = i_rst_n_tgt && i_target_en && !i_spi_cs_tgt_n;
    o_frame_done = reg_frame_done_pulse;
    o_tx_err_tgl = reg_tx_err_tgl;
    o_rx_full_err_tgl = reg_rx_full_err_tgl;
    o_rx_partial_err = reg_rx_partial_pulse;
  end

endmodule
