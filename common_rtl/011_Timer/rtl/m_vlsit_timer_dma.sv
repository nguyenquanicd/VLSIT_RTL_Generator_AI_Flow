/*
 * Project      : Timer IP
 * Author       : Nguyen Quan and Codex
 * AI Flow      : VLSIT RTL Generator AI Automation Flow
 * AI Flow Page : https://github.com/nguyenquanicd/VLSIT_RTL_Generator_AI_Model
 * Date         : 2026-11-04
 * Description  : Two 4-phase level req/ack DMA handshakes (capture and compare/update), capture
 *                reservation, compare/update staging, tagged validation, transactional burst
 *                completion on ack, and CSR-controlled recovery for the Timer stream ports.
 */
`timescale 1ns/1ps

module m_vlsit_timer_dma #(
  // Parameter Description: width of the timestamp and timing-value payload.
  // Parameter values: 32 or 64; default is 32.
  // Parameter unit: bit
  parameter logic [31:0] PARA_COUNTER_WIDTH = 32,
  // Parameter Description: number of output channels addressed by compare/update tags.
  // Parameter values: 1 through 8; default is 4.
  // Parameter unit: channel
  parameter logic [31:0] PARA_OUTPUT_COUNT = 4,
  localparam logic [31:0] LPARA_RECORD_W = 32 + PARA_COUNTER_WIDTH,
  localparam logic [31:0] LPARA_ADDR_CAPTURE_STREAM = 32'h0000_0200,
  localparam logic [31:0] LPARA_ADDR_COMPARE_STREAM = 32'h0000_0204
) (
  // Timer clock and reset
  input  wire                         i_clk_timer,
  input  wire                         i_rst_n_timer,

  // Capture-record queue input and dequeue control
  input  wire                         i_cap_valid,
  input  wire  [LPARA_RECORD_W-1:0]   i_cap_head,
  input  wire  [2:0]                  i_cap_level,
  input  wire                         i_cap_flush_busy,
  output logic                        o_cap_pop,
  output logic                        o_cap_flush_clear,

  // DMA record-count configuration and timer boundary
  input  wire  [1:0]                  i_cap_record_cfg,
  input  wire  [1:0]                  i_cmp_record_cfg,
  input  wire                         i_update_event,

  // Capture and compare/update req/ack handshakes (synchronous to i_clk_timer)
  output logic                        o_dma_cap_req,
  input  wire                         i_dma_cap_ack,
  output logic                        o_dma_cmp_req,
  input  wire                         i_dma_cmp_ack,

  // CSR clear requests and completion pulses (the pulse loads 0 into the rwi clear bit)
  input  wire                         i_cap_clr,
  input  wire                         i_cmp_clr,
  output logic                        o_cap_clr_done,
  output logic                        o_cmp_clr_done,

  // APB stream beat in the timer domain
  input  wire                         i_stream_req,
  input  wire                         i_stream_write,
  input  wire  [15:0]                 i_stream_addr,
  input  wire  [31:0]                 i_stream_wdata,
  input  wire  [3:0]                  i_stream_wstrb,
  output logic                        o_stream_ready,
  output logic [31:0]                 o_stream_rdata,
  output logic                        o_stream_error,

  // Transactional compare/update batch, consumed atomically at a boundary
  output logic                        o_update_batch_valid,
  output logic [2:0]                  o_update_batch_count,
  output logic [4*LPARA_RECORD_W-1:0] o_update_batch_data,
  output logic                        o_dma_error_event,

  // DMA and reservation state for the CSR status register
  output logic [2:0]                  o_cap_queue_level,
  output logic [2:0]                  o_cmp_queue_level,
  output logic [2:0]                  o_cap_reserved_count,
  output logic [2:0]                  o_cmp_reserved_count,
  output logic                        o_cap_req_status,
  output logic                        o_cap_burst_status,
  output logic                        o_cap_clr_status,
  output logic                        o_cmp_req_status,
  output logic                        o_cmp_burst_status,
  output logic                        o_cmp_clr_status
);

  // Handshake state of each DMA group. REQ holds req until ack, WAITLOW holds the group until the
  // DMA drops ack, ERR waits for the CSR clear, and CLEAR/WAIT/DONE are the recovery sequence.
  typedef enum logic [2:0] {
    ENUM_ST_DMA_IDLE    = 3'b000,
    ENUM_ST_DMA_REQ     = 3'b001,
    ENUM_ST_DMA_WAITLOW = 3'b010,
    ENUM_ST_DMA_ERR     = 3'b011,
    ENUM_ST_DMA_CLEAR   = 3'b100,
    ENUM_ST_DMA_WAIT    = 3'b101,
    ENUM_ST_DMA_DONE    = 3'b110
  } dma_state_type_def;
  dma_state_type_def reg_fsm_cap_current_state;
  dma_state_type_def w_fsm_cap_nxt_state;
  dma_state_type_def reg_fsm_cmp_current_state;
  dma_state_type_def w_fsm_cmp_nxt_state;

  // Capture reservation and burst state
  logic [LPARA_RECORD_W-1:0] reg_cap_reserved [0:3];
  logic [2:0] reg_cap_expected;
  logic [2:0] w_cap_cfg_records;
  logic [2:0] reg_cap_fill_count;
  logic [2:0] reg_cap_record_index;
  logic [1:0] reg_cap_beat_index;
  logic [3:0] reg_cap_words_read;
  logic reg_cap_active;
  logic reg_cap_copying;
  logic reg_cap_filled;
  logic reg_cap_req;
  logic reg_cap_ack_d;
  logic w_cap_request;
  logic w_cap_start;
  logic w_cap_copy;
  logic w_cap_stream_access;
  logic w_cap_stream_handshake;
  logic w_cap_ack_spurious;
  logic w_cap_ack_good;
  logic w_cap_release;
  logic w_cap_clr_busy;
  logic reg_cap_flush_busy_seen;

  // Compare/update write parser and commit batch state
  logic [LPARA_RECORD_W-1:0] reg_cmp_stage [0:3];
  logic [LPARA_RECORD_W-1:0] reg_cmp_batch [0:3];
  logic [2:0] reg_cmp_expected;
  logic [2:0] w_cmp_cfg_records;
  logic [2:0] reg_cmp_received;
  logic [1:0] reg_cmp_beat_index;
  logic [31:0] reg_cmp_tag;
  logic [31:0] reg_cmp_value_low;
  logic reg_cmp_active;
  logic reg_cmp_invalid;
  logic reg_cmp_batch_valid;
  logic [2:0] reg_cmp_batch_count;
  logic reg_cmp_req;
  logic reg_cmp_ack_d;
  logic w_cmp_request;
  logic w_cmp_start;
  logic w_cmp_stream_access;
  logic w_cmp_stream_handshake;
  logic w_cmp_tag_valid;
  logic w_cmp_ack_spurious;
  logic w_cmp_ack_good;
  logic w_cmp_commit;
  logic w_cmp_clr_busy;
  logic [LPARA_RECORD_W-1:0] w_cmp_record_input;
  logic reg_cap_error_event;
  logic reg_cmp_error_event;
  logic [31:0] w_stream_read_data;
  logic w_stream_error;
  logic w_stream_ready;
  logic w_stream_address_valid;
  logic w_capture_stream_done;
  logic w_compare_stream_room;

  // Convert two-bit count-minus-one encodings into one through four records.
  assign w_cap_cfg_records = {1'b0, i_cap_record_cfg} + 3'd1;
  assign w_cmp_cfg_records = {1'b0, i_cmp_record_cfg} + 3'd1;

  // A new burst starts only from idle, with no clear requested, no ack still high from the DMA,
  // and (capture) enough complete records or (compare/update) an empty staging area.
  assign w_cap_request = ~reg_cap_active & ~reg_cap_copying & ~reg_cap_filled &
                         ~i_dma_cap_ack & (i_cap_level >= w_cap_cfg_records);
  assign w_cmp_request = ~reg_cmp_active & ~reg_cmp_batch_valid & ~i_dma_cmp_ack;
  assign w_cap_ack_spurious = i_dma_cap_ack & ~reg_cap_ack_d;
  assign w_cmp_ack_spurious = i_dma_cmp_ack & ~reg_cmp_ack_d;
  assign w_cap_start = (reg_fsm_cap_current_state == ENUM_ST_DMA_IDLE) & ~i_cap_clr &
                       ~w_cap_ack_spurious & w_cap_request;
  assign w_cmp_start = (reg_fsm_cmp_current_state == ENUM_ST_DMA_IDLE) & ~i_cmp_clr &
                       ~w_cmp_ack_spurious & w_cmp_request;

  // ack is a valid burst completion only when the APB stream beats of the whole burst are done.
  assign w_cap_ack_good = w_capture_stream_done;
  assign w_cmp_ack_good = reg_cmp_active & ~reg_cmp_invalid &
                          (reg_cmp_received == reg_cmp_expected) &
                          (reg_cmp_beat_index == '0);
  assign w_cap_release = (reg_fsm_cap_current_state == ENUM_ST_DMA_REQ) & i_dma_cap_ack & w_cap_ack_good;
  assign w_cmp_commit  = (reg_fsm_cmp_current_state == ENUM_ST_DMA_REQ) & i_dma_cmp_ack & w_cmp_ack_good;

  assign w_cap_copy = reg_cap_copying & i_cap_valid;
  assign o_cap_pop = w_cap_copy;
  assign o_cap_flush_clear = (reg_fsm_cap_current_state == ENUM_ST_DMA_CLEAR);
  assign o_cap_clr_done = (reg_fsm_cap_current_state == ENUM_ST_DMA_DONE);
  assign o_cmp_clr_done = (reg_fsm_cmp_current_state == ENUM_ST_DMA_DONE);
  assign w_cap_clr_busy = (reg_fsm_cap_current_state == ENUM_ST_DMA_CLEAR) |
                          (reg_fsm_cap_current_state == ENUM_ST_DMA_WAIT) |
                          (reg_fsm_cap_current_state == ENUM_ST_DMA_DONE);
  assign w_cmp_clr_busy = (reg_fsm_cmp_current_state == ENUM_ST_DMA_CLEAR) |
                          (reg_fsm_cmp_current_state == ENUM_ST_DMA_DONE);
  assign o_dma_cap_req = reg_cap_req;
  assign o_dma_cmp_req = reg_cmp_req;

  // Capture queue level/status and compare batch occupancy feed the generated CSR status inputs.
  assign o_cap_queue_level = i_cap_level;
  assign o_cmp_queue_level = reg_cmp_batch_valid ? reg_cmp_batch_count : reg_cmp_received;
  assign o_cap_reserved_count = reg_cap_active ? reg_cap_expected : 3'd0;
  assign o_cmp_reserved_count = reg_cmp_active ? (reg_cmp_expected - reg_cmp_received) :
                                reg_cmp_batch_valid ? reg_cmp_batch_count : 3'd0;
  assign o_cap_req_status = reg_cap_req;
  assign o_cap_burst_status = reg_cap_active;
  assign o_cap_clr_status = w_cap_clr_busy;
  assign o_cmp_req_status = reg_cmp_req;
  assign o_cmp_burst_status = reg_cmp_active;
  assign o_cmp_clr_status = w_cmp_clr_busy;
  assign o_update_batch_valid = reg_cmp_batch_valid;
  assign o_update_batch_count = reg_cmp_batch_count;
  assign o_update_batch_data = {reg_cmp_batch[3], reg_cmp_batch[2],
                                reg_cmp_batch[1], reg_cmp_batch[0]};

  // Determine whether a stream address and operation are valid before changing any queue state.
  assign w_stream_address_valid = (i_stream_addr == LPARA_ADDR_CAPTURE_STREAM[15:0]) |
                                  (i_stream_addr == LPARA_ADDR_COMPARE_STREAM[15:0]);
  assign w_cap_stream_access = i_stream_req &
                               (i_stream_addr == LPARA_ADDR_CAPTURE_STREAM[15:0]);
  assign w_cmp_stream_access = i_stream_req &
                               (i_stream_addr == LPARA_ADDR_COMPARE_STREAM[15:0]);
  assign w_capture_stream_done = reg_cap_filled &
                                 (reg_cap_words_read == (reg_cap_expected * (PARA_COUNTER_WIDTH == 32 ? 2 : 3)));
  assign w_compare_stream_room = (reg_cmp_received < reg_cmp_expected) &
                                 (reg_cmp_received < 3'd4);
  generate
    if (PARA_COUNTER_WIDTH == 64) begin : gen_cmp_record_64
      assign w_cmp_record_input = {reg_cmp_tag, i_stream_wdata, reg_cmp_value_low};
    end else begin : gen_cmp_record_32
      assign w_cmp_record_input = {reg_cmp_tag, i_stream_wdata};
    end
  endgenerate

  function automatic logic w_cmp_record_valid(input logic [LPARA_RECORD_W-1:0] i_record);
    logic [31:0] w_tag;
    logic [PARA_COUNTER_WIDTH-1:0] w_value;
    begin
      w_tag = i_record[PARA_COUNTER_WIDTH+31:PARA_COUNTER_WIDTH];
      w_value = i_record[PARA_COUNTER_WIDTH-1:0];
      case (w_tag[4:3])
        2'b00: w_cmp_record_valid = (w_tag[31:5] == '0) &
                                    ({1'b0, w_tag[2:0]} < PARA_OUTPUT_COUNT[3:0]);
        2'b01: w_cmp_record_valid = (w_tag[31:5] == '0) &
                                    (w_tag[2:0] == '0);
        2'b10: w_cmp_record_valid = (w_tag[31:5] == '0) &
                                    (w_tag[2:0] == '0) &
                                    (w_value[PARA_COUNTER_WIDTH-1:16] == '0);
        2'b11: w_cmp_record_valid = (w_tag[31:5] == '0) &
                                    ({1'b0, w_tag[2:0]} < PARA_OUTPUT_COUNT[3:0]);
        default: w_cmp_record_valid = 1'b0;
      endcase
    end
  endfunction

  // Validate record tags and payload constraints before accepting a staged command.
  always_comb begin : p_com_cmp_tag_valid
    w_cmp_tag_valid = w_cmp_record_valid(w_cmp_record_input);
  end

  // Stream response data: metadata, low value word, then high value word for 64-bit records.
  // Stream beats are refused while either group is clearing.
  always_comb begin : p_com_stream_read
    w_stream_read_data = '0;
    w_stream_error = 1'b0;
    w_stream_ready = 1'b0;
    case (1'b1)
      ~i_stream_req: begin
        w_stream_ready = 1'b0;
      end
      (w_cap_clr_busy | w_cmp_clr_busy): begin
        w_stream_ready = 1'b1;
        w_stream_error = 1'b1;
      end
      ~w_stream_address_valid: begin
        w_stream_ready = 1'b1;
        w_stream_error = 1'b1;
      end
      (i_stream_write & (i_stream_wstrb != 4'hf)): begin
        w_stream_ready = 1'b1;
        w_stream_error = 1'b1;
      end
      w_cap_stream_access: begin
        w_stream_ready = 1'b1;
        if (i_stream_write | ~reg_cap_filled | w_capture_stream_done |
            (reg_cap_record_index >= reg_cap_expected)) begin
          w_stream_error = 1'b1;
        end else begin
          case (reg_cap_beat_index)
            2'd0: w_stream_read_data = reg_cap_reserved[reg_cap_record_index[1:0]][PARA_COUNTER_WIDTH+31:PARA_COUNTER_WIDTH];
            2'd1: w_stream_read_data = reg_cap_reserved[reg_cap_record_index[1:0]][31:0];
            2'd2: w_stream_read_data = (PARA_COUNTER_WIDTH == 64) ?
                                         reg_cap_reserved[reg_cap_record_index[1:0]][63:32] : 32'd0;
            default: w_stream_error = 1'b1;
          endcase
          if ((PARA_COUNTER_WIDTH == 32) & (reg_cap_beat_index == 2'd2))
            w_stream_error = 1'b1;
        end
      end
      w_cmp_stream_access: begin
        w_stream_ready = 1'b1;
        if (~i_stream_write | ~reg_cmp_active | ~w_compare_stream_room)
          w_stream_error = 1'b1;
      end
      default: begin
        w_stream_ready = i_stream_req;
        w_stream_error = i_stream_req;
      end
    endcase
  end
  assign o_stream_ready = w_stream_ready;
  assign o_stream_rdata = w_stream_read_data;
  assign o_stream_error = w_stream_error;
  assign w_cap_stream_handshake = w_cap_stream_access & w_stream_ready & ~w_stream_error;
  assign w_cmp_stream_handshake = w_cmp_stream_access & w_stream_ready & ~w_stream_error;

  // Capture handshake transitions: req is held until ack; a clear request has priority.
  always_comb begin : p_com_cap_nxt
    w_fsm_cap_nxt_state = reg_fsm_cap_current_state;
    case (reg_fsm_cap_current_state)
      ENUM_ST_DMA_IDLE: begin
        casez ({i_cap_clr, w_cap_ack_spurious, w_cap_request})
          3'b1??: w_fsm_cap_nxt_state = ENUM_ST_DMA_CLEAR;
          3'b01?: w_fsm_cap_nxt_state = ENUM_ST_DMA_ERR;
          3'b001: w_fsm_cap_nxt_state = ENUM_ST_DMA_REQ;
          default: w_fsm_cap_nxt_state = ENUM_ST_DMA_IDLE;
        endcase
      end
      ENUM_ST_DMA_REQ: begin
        if (i_cap_clr)
          w_fsm_cap_nxt_state = ENUM_ST_DMA_CLEAR;
        else if (i_dma_cap_ack)
          w_fsm_cap_nxt_state = w_cap_ack_good ? ENUM_ST_DMA_WAITLOW : ENUM_ST_DMA_ERR;
      end
      ENUM_ST_DMA_WAITLOW: begin
        if (i_cap_clr)
          w_fsm_cap_nxt_state = ENUM_ST_DMA_CLEAR;
        else if (~i_dma_cap_ack)
          w_fsm_cap_nxt_state = ENUM_ST_DMA_IDLE;
      end
      ENUM_ST_DMA_ERR: begin
        if (i_cap_clr)
          w_fsm_cap_nxt_state = ENUM_ST_DMA_CLEAR;
      end
      ENUM_ST_DMA_CLEAR: w_fsm_cap_nxt_state = ENUM_ST_DMA_WAIT;
      ENUM_ST_DMA_WAIT: begin
        if (~i_cap_flush_busy & reg_cap_flush_busy_seen)
          w_fsm_cap_nxt_state = ENUM_ST_DMA_DONE;
      end
      ENUM_ST_DMA_DONE: w_fsm_cap_nxt_state = ENUM_ST_DMA_IDLE;
      default: w_fsm_cap_nxt_state = ENUM_ST_DMA_IDLE;
    endcase
  end

  // Capture handshake state register.
  always_ff @(posedge i_clk_timer, negedge i_rst_n_timer) begin : p_ff_fsm_cap
    if (!i_rst_n_timer)
      reg_fsm_cap_current_state <= ENUM_ST_DMA_IDLE;
    else
      reg_fsm_cap_current_state <= w_fsm_cap_nxt_state;
  end

  // Registered req output and sampled ack used to detect a rising ack edge.
  always_ff @(posedge i_clk_timer, negedge i_rst_n_timer) begin : p_ff_cap_req_ack
    if (!i_rst_n_timer) begin
      reg_cap_req <= 1'b0;
      reg_cap_ack_d <= 1'b0;
    end else begin
      reg_cap_req <= (w_fsm_cap_nxt_state == ENUM_ST_DMA_REQ);
      reg_cap_ack_d <= i_dma_cap_ack;
    end
  end

  // Track completion of all per-channel and shared FIFO reset handshakes.
  always_ff @(posedge i_clk_timer, negedge i_rst_n_timer) begin : p_ff_cap_flush_busy
    if (!i_rst_n_timer) begin
      reg_cap_flush_busy_seen <= 1'b0;
    end else begin
      if (reg_fsm_cap_current_state == ENUM_ST_DMA_CLEAR)
        reg_cap_flush_busy_seen <= 1'b0;
      else if ((reg_fsm_cap_current_state == ENUM_ST_DMA_WAIT) & i_cap_flush_busy)
        reg_cap_flush_busy_seen <= 1'b1;
    end
  end

  // Reserve capture records when req rises and retain them until ack completes the burst.
  always_ff @(posedge i_clk_timer, negedge i_rst_n_timer) begin : p_ff_cap_dma
    if (!i_rst_n_timer) begin
      reg_cap_expected <= 3'd1;
      reg_cap_fill_count <= '0;
      reg_cap_record_index <= '0;
      reg_cap_beat_index <= '0;
      reg_cap_words_read <= '0;
      reg_cap_active <= 1'b0;
      reg_cap_copying <= 1'b0;
      reg_cap_filled <= 1'b0;
      reg_cap_error_event <= 1'b0;
    end else begin
      reg_cap_error_event <= 1'b0;
      if (w_cap_start) begin
        reg_cap_expected <= w_cap_cfg_records;
        reg_cap_fill_count <= '0;
        reg_cap_record_index <= '0;
        reg_cap_beat_index <= '0;
        reg_cap_words_read <= '0;
        reg_cap_active <= 1'b1;
        reg_cap_copying <= 1'b1;
        reg_cap_filled <= 1'b0;
      end
      if (w_cap_copy) begin
        reg_cap_reserved[reg_cap_fill_count[1:0]] <= i_cap_head;
        if ((reg_cap_fill_count + 1'b1) >= reg_cap_expected) begin
          reg_cap_fill_count <= reg_cap_fill_count + 1'b1;
          reg_cap_copying <= 1'b0;
          reg_cap_filled <= 1'b1;
        end else begin
          reg_cap_fill_count <= reg_cap_fill_count + 1'b1;
        end
      end
      if (w_cap_stream_handshake) begin
        reg_cap_words_read <= reg_cap_words_read + 1'b1;
        if (reg_cap_beat_index == ((PARA_COUNTER_WIDTH == 32) ? 2'd1 : 2'd2)) begin
          reg_cap_beat_index <= '0;
          reg_cap_record_index <= reg_cap_record_index + 1'b1;
        end else begin
          reg_cap_beat_index <= reg_cap_beat_index + 1'b1;
        end
      end
      if (w_cap_release) begin
        reg_cap_active <= 1'b0;
        reg_cap_copying <= 1'b0;
        reg_cap_filled <= 1'b0;
        reg_cap_fill_count <= '0;
        reg_cap_record_index <= '0;
        reg_cap_beat_index <= '0;
        reg_cap_words_read <= '0;
      end
      // Protocol error: ack before the burst is complete, or ack with no request.
      if (((reg_fsm_cap_current_state == ENUM_ST_DMA_REQ) & ~i_cap_clr & i_dma_cap_ack & ~w_cap_ack_good) |
          ((reg_fsm_cap_current_state == ENUM_ST_DMA_IDLE) & ~i_cap_clr & w_cap_ack_spurious)) begin
        reg_cap_error_event <= 1'b1;
      end
      if (reg_fsm_cap_current_state == ENUM_ST_DMA_CLEAR) begin
        reg_cap_expected <= 3'd1;
        reg_cap_fill_count <= '0;
        reg_cap_record_index <= '0;
        reg_cap_beat_index <= '0;
        reg_cap_words_read <= '0;
        reg_cap_active <= 1'b0;
        reg_cap_copying <= 1'b0;
        reg_cap_filled <= 1'b0;
      end
    end
  end

  // Compare/update handshake transitions: req is held until ack; a clear request has priority.
  always_comb begin : p_com_cmp_nxt
    w_fsm_cmp_nxt_state = reg_fsm_cmp_current_state;
    case (reg_fsm_cmp_current_state)
      ENUM_ST_DMA_IDLE: begin
        casez ({i_cmp_clr, w_cmp_ack_spurious, w_cmp_request})
          3'b1??: w_fsm_cmp_nxt_state = ENUM_ST_DMA_CLEAR;
          3'b01?: w_fsm_cmp_nxt_state = ENUM_ST_DMA_ERR;
          3'b001: w_fsm_cmp_nxt_state = ENUM_ST_DMA_REQ;
          default: w_fsm_cmp_nxt_state = ENUM_ST_DMA_IDLE;
        endcase
      end
      ENUM_ST_DMA_REQ: begin
        if (i_cmp_clr)
          w_fsm_cmp_nxt_state = ENUM_ST_DMA_CLEAR;
        else if (i_dma_cmp_ack)
          w_fsm_cmp_nxt_state = w_cmp_ack_good ? ENUM_ST_DMA_WAITLOW : ENUM_ST_DMA_ERR;
      end
      ENUM_ST_DMA_WAITLOW: begin
        if (i_cmp_clr)
          w_fsm_cmp_nxt_state = ENUM_ST_DMA_CLEAR;
        else if (~i_dma_cmp_ack)
          w_fsm_cmp_nxt_state = ENUM_ST_DMA_IDLE;
      end
      ENUM_ST_DMA_ERR: begin
        if (i_cmp_clr)
          w_fsm_cmp_nxt_state = ENUM_ST_DMA_CLEAR;
      end
      ENUM_ST_DMA_CLEAR: w_fsm_cmp_nxt_state = ENUM_ST_DMA_DONE;
      ENUM_ST_DMA_DONE: w_fsm_cmp_nxt_state = ENUM_ST_DMA_IDLE;
      default: w_fsm_cmp_nxt_state = ENUM_ST_DMA_IDLE;
    endcase
  end

  // Compare/update handshake state register.
  always_ff @(posedge i_clk_timer, negedge i_rst_n_timer) begin : p_ff_fsm_cmp
    if (!i_rst_n_timer)
      reg_fsm_cmp_current_state <= ENUM_ST_DMA_IDLE;
    else
      reg_fsm_cmp_current_state <= w_fsm_cmp_nxt_state;
  end

  // Registered req output and sampled ack used to detect a rising ack edge.
  always_ff @(posedge i_clk_timer, negedge i_rst_n_timer) begin : p_ff_cmp_req_ack
    if (!i_rst_n_timer) begin
      reg_cmp_req <= 1'b0;
      reg_cmp_ack_d <= 1'b0;
    end else begin
      reg_cmp_req <= (w_fsm_cmp_nxt_state == ENUM_ST_DMA_REQ);
      reg_cmp_ack_d <= i_dma_cmp_ack;
    end
  end

  // Compare/update records remain staged until all configured records and a valid ack arrive.
  always_ff @(posedge i_clk_timer, negedge i_rst_n_timer) begin : p_ff_cmp_dma
    if (!i_rst_n_timer) begin
      reg_cmp_expected <= 3'd1;
      reg_cmp_received <= '0;
      reg_cmp_beat_index <= '0;
      reg_cmp_tag <= '0;
      reg_cmp_value_low <= '0;
      reg_cmp_active <= 1'b0;
      reg_cmp_invalid <= 1'b0;
      reg_cmp_batch_valid <= 1'b0;
      reg_cmp_batch_count <= '0;
      reg_cmp_error_event <= 1'b0;
      for (int reg_loop_index = 0; reg_loop_index < 4; reg_loop_index = reg_loop_index + 1) begin
        reg_cmp_stage[reg_loop_index[1:0]] <= '0;
        reg_cmp_batch[reg_loop_index[1:0]] <= '0;
      end
    end else begin
      reg_cmp_error_event <= 1'b0;
      if (i_update_event & reg_cmp_batch_valid) begin
        reg_cmp_batch_valid <= 1'b0;
        reg_cmp_batch_count <= '0;
      end
      if (w_cmp_start) begin
        reg_cmp_expected <= w_cmp_cfg_records;
        reg_cmp_received <= '0;
        reg_cmp_beat_index <= '0;
        reg_cmp_invalid <= 1'b0;
        reg_cmp_active <= 1'b1;
      end
      if (w_cmp_stream_handshake) begin
        case (reg_cmp_beat_index)
          2'd0: begin
            reg_cmp_tag <= i_stream_wdata;
            if (i_stream_wdata[31:5] != '0)
              reg_cmp_invalid <= 1'b1;
            reg_cmp_beat_index <= 2'd1;
          end
          2'd1: begin
            reg_cmp_value_low <= i_stream_wdata;
            if (PARA_COUNTER_WIDTH == 32) begin
              if (w_cmp_tag_valid) begin
                reg_cmp_stage[reg_cmp_received[1:0]] <= w_cmp_record_input;
              end else begin
                reg_cmp_invalid <= 1'b1;
                reg_cmp_error_event <= 1'b1;
              end
              reg_cmp_received <= reg_cmp_received + 1'b1;
              reg_cmp_beat_index <= '0;
            end else begin
              reg_cmp_beat_index <= 2'd2;
            end
          end
          2'd2: begin
            if (w_cmp_tag_valid) begin
              reg_cmp_stage[reg_cmp_received[1:0]] <= w_cmp_record_input;
            end else begin
              reg_cmp_invalid <= 1'b1;
              reg_cmp_error_event <= 1'b1;
            end
            reg_cmp_received <= reg_cmp_received + 1'b1;
            reg_cmp_beat_index <= '0;
          end
          default: begin
            reg_cmp_invalid <= 1'b1;
            reg_cmp_error_event <= 1'b1;
          end
        endcase
      end
      if (w_cmp_commit) begin
        for (int reg_loop_index = 0; reg_loop_index < 4; reg_loop_index = reg_loop_index + 1)
          if (reg_loop_index < reg_cmp_expected)
            reg_cmp_batch[reg_loop_index[1:0]] <= reg_cmp_stage[reg_loop_index[1:0]];
        reg_cmp_batch_count <= reg_cmp_expected;
        reg_cmp_batch_valid <= 1'b1;
        reg_cmp_active <= 1'b0;
      end
      // Protocol error: ack before the burst is complete, or ack with no request.
      if (((reg_fsm_cmp_current_state == ENUM_ST_DMA_REQ) & ~i_cmp_clr & i_dma_cmp_ack & ~w_cmp_ack_good) |
          ((reg_fsm_cmp_current_state == ENUM_ST_DMA_IDLE) & ~i_cmp_clr & w_cmp_ack_spurious)) begin
        reg_cmp_error_event <= 1'b1;
      end
      if (reg_fsm_cmp_current_state == ENUM_ST_DMA_CLEAR) begin
        reg_cmp_expected <= 3'd1;
        reg_cmp_received <= '0;
        reg_cmp_beat_index <= '0;
        reg_cmp_tag <= '0;
        reg_cmp_value_low <= '0;
        reg_cmp_active <= 1'b0;
        reg_cmp_invalid <= 1'b0;
        reg_cmp_batch_valid <= 1'b0;
        reg_cmp_batch_count <= '0;
        for (int reg_loop_index = 0; reg_loop_index < 4; reg_loop_index = reg_loop_index + 1) begin
          reg_cmp_stage[reg_loop_index[1:0]] <= '0;
          reg_cmp_batch[reg_loop_index[1:0]] <= '0;
        end
      end
    end
  end

  assign o_dma_error_event = reg_cap_error_event | reg_cmp_error_event;

endmodule
