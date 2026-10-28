/*
 * Project      : VLSIT Common RTL library
 * Author       : Nguyen Quan and Claude Sonnet 5.5 (user)
 * AI Flow      : VLSIT RTL Generator AI Automation Flow
 * AI Flow Page : https://github.com/nguyenquanicd/VLSIT_RTL_Generator_AI_Model
 * Date         : 2026-10-26
 * Description  : Read request engine of the AXI2TLUL bridge. It takes one AR beat from the input
 *                slice, checks the burst (reserved burst type, size above the bus, WRAP length and
 *                alignment, FIXED length, INCR across 4 KB), and splits a legal burst into one Get
 *                request per beat with the beat address aligned to the size, the size, and the
 *                byte-lane mask. The first request of a burst is presented in the same cycle as the
 *                AR beat (cut-through). A request needs a read slot and an ID context from the read
 *                slot table; the first beat of a burst needs enough free slots for the whole burst
 *                (at most the table size), which keeps the table free of deadlock. An illegal burst
 *                is not sent: the engine allocates one error beat per beat of the burst and raises
 *                a one-cycle event.
 */
`timescale 1ns/1ps

module m_vlsit_axi2tlul_rd_req #(
  // Parameter Description: width of the address.
  // Parameter values: 12 to 64; default is 32.
  // Parameter unit: bit
  parameter logic [31:0] PARA_ADDR_W = 32,
  // Parameter Description: width of the AXI ID.
  // Parameter values: 1 to 32; default is 8.
  // Parameter unit: bit
  parameter logic [31:0] PARA_AXI_ID_W = 8,
  // Parameter Description: width of the data bus; the mask has one bit per byte.
  // Parameter values: 32, 64, 128, 256, 512, or 1024; default is 32.
  // Parameter unit: bit
  parameter logic [31:0] PARA_DATA_W = 32,
  // Parameter Description: number of read slots; a burst reserves at most this many slots.
  // Parameter values: power of two from 2 to 128; default is 16.
  // Parameter unit: count
  parameter logic [31:0] PARA_NUM_RD = 16,
  localparam logic [31:0] LPARA_STRB_W = PARA_DATA_W / 8,
  localparam logic [31:0] LPARA_BYTE_W = $clog2(PARA_DATA_W / 8),
  localparam logic [31:0] LPARA_SIZE_W = $clog2($clog2(PARA_DATA_W / 8) + 1),
  localparam logic [31:0] LPARA_CNT_W = $clog2(PARA_NUM_RD) + 1,
  localparam logic [31:0] LPARA_LEN_W = 8,
  localparam logic [31:0] LPARA_SIZE_FLD_W = 3,
  localparam logic [31:0] LPARA_BURST_FLD_W = 2,
  localparam logic [31:0] LPARA_LSB_LEN = PARA_AXI_ID_W + PARA_ADDR_W,
  localparam logic [31:0] LPARA_LSB_SIZE = PARA_AXI_ID_W + PARA_ADDR_W + 8,
  localparam logic [31:0] LPARA_LSB_BURST = PARA_AXI_ID_W + PARA_ADDR_W + 11,
  localparam logic [31:0] LPARA_LSB_PROT2 = PARA_AXI_ID_W + PARA_ADDR_W + 13,
  localparam logic [31:0] LPARA_AR_W = PARA_AXI_ID_W + PARA_ADDR_W + 14,
  localparam logic [31:0] LPARA_BURST_FIXED = 0,
  localparam logic [31:0] LPARA_BURST_INCR = 1,
  localparam logic [31:0] LPARA_BURST_WRAP = 2,
  localparam logic [31:0] LPARA_PAGE_BYTES = 4096,
  localparam logic [31:0] LPARA_ONE = 1
) (
  // Clock and reset
  input  wire                      i_clk_main,
  input  wire                      i_rst_n_main,

  // AR input slice
  input  wire                      i_ar_valid,
  output logic                     o_ar_ready,
  input  wire  [LPARA_AR_W-1:0]    i_ar_data,

  // Read request to the arbiter
  output logic                     o_req_valid,
  input  wire                      i_req_gnt,
  output logic [PARA_ADDR_W-1:0]   o_req_addr,
  output logic [LPARA_SIZE_W-1:0]  o_req_size,
  output logic [LPARA_STRB_W-1:0]  o_req_mask,
  output logic                     o_req_instr,

  // Slot allocation to the read slot table
  output logic                     o_alloc_en,
  output logic                     o_alloc_gen,
  output logic [PARA_AXI_ID_W-1:0] o_alloc_id,
  output logic                     o_alloc_last,
  output logic [LPARA_CNT_W-1:0]   o_alloc_need,
  input  wire                      i_alloc_ok,
  output logic                     o_pin_valid,
  output logic [PARA_AXI_ID_W-1:0] o_pin_id,

  // Status
  output logic                     o_evt_axi_err
);

  // FSM states: IDLE waits for an AR beat, BURST issues the remaining beats of a legal burst, and
  // ERR allocates the error beats of an illegal burst. Encoding 2'b11 is unused and recovers to
  // IDLE.
  typedef enum logic [1:0] {
    ENUM_ST_IDLE  = 2'b00,
    ENUM_ST_BURST = 2'b01,
    ENUM_ST_ERR   = 2'b10
  } rd_state_type_def;

  // Internal signal declarations
  rd_state_type_def         reg_fsm_rd_current_state;
  rd_state_type_def         w_fsm_rd_nxt_state;
  logic [PARA_ADDR_W-1:0]   reg_addr;
  logic [7:0]               reg_left;
  logic [PARA_AXI_ID_W-1:0] reg_id;
  logic [2:0]               reg_size;
  logic [1:0]               reg_burst;
  logic [7:0]               reg_len;
  logic                     reg_instr;
  logic                     reg_first_err;
  logic [PARA_ADDR_W-1:0]   w_addr_nxt;
  logic [7:0]               w_left_nxt;
  logic [PARA_AXI_ID_W-1:0] w_id_nxt;
  logic [2:0]               w_size_nxt;
  logic [1:0]               w_burst_nxt;
  logic [7:0]               w_len_nxt;
  logic                     w_instr_nxt;
  logic                     w_first_err_nxt;
  logic [PARA_AXI_ID_W-1:0] w_ar_id;
  logic [PARA_ADDR_W-1:0]   w_ar_addr;
  logic [7:0]               w_ar_len;
  logic [2:0]               w_ar_size;
  logic [1:0]               w_ar_burst;
  logic                     w_ar_prot2;
  logic [PARA_ADDR_W-1:0]   w_ar_aligned;
  logic [16:0]              w_ar_total;
  logic [16:0]              w_ar_page_end;
  logic                     w_illegal;
  logic [PARA_ADDR_W-1:0]   w_cur_addr;
  logic [2:0]               w_cur_size;
  logic [7:0]               w_cur_left;
  logic [PARA_AXI_ID_W-1:0] w_cur_id;
  logic                     w_cur_instr;
  logic                     w_cur_first;
  logic                     w_cur_last;
  logic                     w_req_valid;
  logic                     w_alloc_en;
  logic                     w_alloc_gen;
  logic [LPARA_CNT_W-1:0]   w_alloc_need;
  logic                     w_ar_pop;
  logic                     w_evt;

  // Address of a beat aligned down to the transfer size (the low size bits are cleared).
  function automatic logic [PARA_ADDR_W-1:0] f_align(input logic [PARA_ADDR_W-1:0] addr,
                                                     input logic [2:0] size);
    logic [PARA_ADDR_W-1:0] one;
    begin
      one     = {{(PARA_ADDR_W-1){1'b0}}, 1'b1};
      f_align = addr & ~((one << size) - one);
    end
  endfunction

  // Address of the next beat (AXI A3.4.1): FIXED keeps the start address, INCR adds the transfer
  // size to the aligned address, WRAP does the same inside the wrap container of (length x size)
  // bytes.
  function automatic logic [PARA_ADDR_W-1:0] f_next(input logic [PARA_ADDR_W-1:0] addr,
                                                    input logic [2:0] size,
                                                    input logic [1:0] burst,
                                                    input logic [7:0] len);
    logic [PARA_ADDR_W-1:0] one;
    logic [PARA_ADDR_W-1:0] aligned;
    logic [PARA_ADDR_W-1:0] inc;
    logic [PARA_ADDR_W-1:0] wrap_mask;
    begin
      one       = {{(PARA_ADDR_W-1){1'b0}}, 1'b1};
      aligned   = f_align(addr, size);
      inc       = aligned + (one << size);
      wrap_mask = ((PARA_ADDR_W'(len) + one) << size) - one;
      case (burst)
        LPARA_BURST_FIXED[1:0]: f_next = addr;
        LPARA_BURST_WRAP[1:0]:  f_next = (aligned & ~wrap_mask) | (inc & wrap_mask);
        default:                f_next = inc;
      endcase
    end
  endfunction

  // Byte lanes of a beat: from the byte of the address (first beat and every FIXED beat) or from
  // the start of the aligned transfer (other beats) up to the end of the aligned transfer.
  function automatic logic [LPARA_STRB_W-1:0] f_mask(input logic [LPARA_BYTE_W-1:0] addr,
                                                     input logic [2:0] size,
                                                     input logic first);
    logic [LPARA_BYTE_W:0] off;
    logic [LPARA_BYTE_W:0] bsz;
    logic [LPARA_BYTE_W:0] aoff;
    logic [LPARA_BYTE_W:0] lo;
    logic [LPARA_BYTE_W:0] hi;
    begin
      off  = {1'b0, addr};
      bsz  = {{LPARA_BYTE_W{1'b0}}, 1'b1} << size;
      aoff = off & ~(bsz - {{LPARA_BYTE_W{1'b0}}, 1'b1});
      lo   = first ? off : aoff;
      hi   = aoff + bsz - {{LPARA_BYTE_W{1'b0}}, 1'b1};
      for (int idx = 0; idx < LPARA_STRB_W; idx++)
        f_mask[idx] = ($bits(lo)'(idx) >= lo) & ($bits(lo)'(idx) <= hi);
    end
  endfunction

  // Number of free slots that the first beat of a burst needs: the burst length, at most the table
  // size.
  function automatic logic [LPARA_CNT_W-1:0] f_need(input logic [7:0] len);
    logic [8:0] beats;
    begin
      beats  = {1'b0, len} + 9'(LPARA_ONE);
      f_need = (beats > 9'(PARA_NUM_RD)) ? LPARA_CNT_W'(PARA_NUM_RD) : LPARA_CNT_W'(beats);
    end
  endfunction

  // Fields of the AR beat from the input slice, packed as {prot2, burst, size, len, addr, id}.
  assign w_ar_id    = i_ar_data[PARA_AXI_ID_W-1:0];
  assign w_ar_addr  = i_ar_data[PARA_AXI_ID_W +: PARA_ADDR_W];
  assign w_ar_len   = i_ar_data[LPARA_LSB_LEN +: LPARA_LEN_W];
  assign w_ar_size  = i_ar_data[LPARA_LSB_SIZE +: LPARA_SIZE_FLD_W];
  assign w_ar_burst = i_ar_data[LPARA_LSB_BURST +: LPARA_BURST_FLD_W];
  assign w_ar_prot2 = i_ar_data[LPARA_LSB_PROT2];

  // Burst check on the AR beat: the INCR burst must stay in its 4 KB page, WRAP needs a length of
  // 2, 4, 8, or 16 and an aligned start address, FIXED has at most 16 beats, the size must fit the
  // bus, and the burst type 2'b11 is reserved. Any violation makes the burst illegal.
  assign w_ar_aligned  = f_align(w_ar_addr, w_ar_size);
  assign w_ar_total    = ({8'd0, ({1'b0, w_ar_len} + 9'(LPARA_ONE))}) << w_ar_size;
  assign w_ar_page_end = {5'd0, w_ar_aligned[11:0]} + w_ar_total;

  // Legality of the AR burst, evaluated on the AR beat that the slice offers.
  always_comb begin : p_com_chk
    w_illegal = (w_ar_size > LPARA_BYTE_W[2:0]);
    case (w_ar_burst)
      LPARA_BURST_FIXED[1:0]: w_illegal = w_illegal | (w_ar_len[7:4] != 4'd0);
      LPARA_BURST_INCR[1:0]:  w_illegal = w_illegal | (w_ar_page_end > 17'(LPARA_PAGE_BYTES));
      LPARA_BURST_WRAP[1:0]:  w_illegal = w_illegal | (w_ar_len[7:4] != 4'd0) | ~w_ar_len[0] |
                                          ((w_ar_len & (w_ar_len + 8'(LPARA_ONE))) != 8'd0) | (w_ar_addr != w_ar_aligned);
      default:                w_illegal = 1'b1;
    endcase
  end

  // Current beat: the AR beat itself while the engine is idle (cut-through of the first beat), the
  // stored burst state otherwise. FIXED beats always use the byte lanes of the start address.
  always_comb begin : p_com_cur
    w_cur_addr  = reg_addr;
    w_cur_size  = reg_size;
    w_cur_left  = reg_left;
    w_cur_id    = reg_id;
    w_cur_instr = reg_instr;
    w_cur_first = (reg_burst == LPARA_BURST_FIXED[1:0]);
    if (reg_fsm_rd_current_state == ENUM_ST_IDLE) begin
      w_cur_addr  = w_ar_addr;
      w_cur_size  = w_ar_size;
      w_cur_left  = w_ar_len;
      w_cur_id    = w_ar_id;
      w_cur_instr = w_ar_prot2;
      w_cur_first = 1'b1;
    end
    w_cur_last = (w_cur_left == 8'd0);
  end

  // Request, allocation, and pop of the AR beat. IDLE presents the first request of a legal burst
  // when the slot table can take the whole burst, and takes an illegal burst without a request.
  // BURST presents one request per beat. ERR allocates one error beat per cycle as the table
  // allows.
  always_comb begin : p_com_out
    w_req_valid  = 1'b0;
    w_alloc_en   = 1'b0;
    w_alloc_gen  = 1'b0;
    w_alloc_need = LPARA_CNT_W'(LPARA_ONE);
    w_ar_pop     = 1'b0;
    w_evt        = 1'b0;
    case (reg_fsm_rd_current_state)
      ENUM_ST_IDLE: begin
        w_alloc_need = f_need(w_ar_len);
        if (i_ar_valid) begin
          if (w_illegal) begin
            w_ar_pop = 1'b1;
            w_evt    = 1'b1;
          end else begin
            w_req_valid = i_alloc_ok;
            w_alloc_en  = i_alloc_ok & i_req_gnt;
            w_ar_pop    = i_alloc_ok & i_req_gnt;
          end
        end
      end
      ENUM_ST_BURST: begin
        w_req_valid = i_alloc_ok;
        w_alloc_en  = i_alloc_ok & i_req_gnt;
      end
      ENUM_ST_ERR: begin
        w_alloc_gen  = 1'b1;
        w_alloc_need = reg_first_err ? f_need(reg_left) : LPARA_CNT_W'(LPARA_ONE);
        w_alloc_en   = i_alloc_ok;
      end
      default: begin
        w_req_valid = 1'b0;
      end
    endcase
  end

  // Output mapping of the request, the allocation, and the status.
  assign o_ar_ready   = w_ar_pop;
  assign o_req_valid  = w_req_valid;
  assign o_req_addr   = f_align(w_cur_addr, w_cur_size);
  assign o_req_size   = w_cur_size[LPARA_SIZE_W-1:0];
  assign o_req_mask   = f_mask(w_cur_addr[LPARA_BYTE_W-1:0], w_cur_size, w_cur_first);
  assign o_req_instr  = w_cur_instr;
  assign o_alloc_en   = w_alloc_en;
  assign o_alloc_gen  = w_alloc_gen;
  assign o_alloc_id   = w_cur_id;
  assign o_alloc_last = w_cur_last;
  assign o_alloc_need = w_alloc_need;
  assign o_pin_valid  = (reg_fsm_rd_current_state != ENUM_ST_IDLE);
  assign o_pin_id     = reg_id;
  assign o_evt_axi_err = w_evt;

  // Part 1, sequential: the current state of the engine, reset to IDLE.
  always_ff @(posedge i_clk_main, negedge i_rst_n_main) begin : p_ff_fsm_rd
    if (!i_rst_n_main)
      reg_fsm_rd_current_state <= ENUM_ST_IDLE;
    else
      reg_fsm_rd_current_state <= w_fsm_rd_nxt_state;
  end

  // Part 2, combinational: IDLE goes to BURST after the first beat of a legal burst with more beats
  // and to ERR on an illegal burst; BURST and ERR return to IDLE after the last beat.
  always_comb begin : p_com_fsm_nxt
    w_fsm_rd_nxt_state = reg_fsm_rd_current_state;
    case (reg_fsm_rd_current_state)
      ENUM_ST_IDLE: begin
        if (i_ar_valid & w_illegal)
          w_fsm_rd_nxt_state = ENUM_ST_ERR;
        else if (w_alloc_en & ~w_cur_last)
          w_fsm_rd_nxt_state = ENUM_ST_BURST;
      end
      ENUM_ST_BURST: begin
        if (w_alloc_en & w_cur_last)
          w_fsm_rd_nxt_state = ENUM_ST_IDLE;
      end
      ENUM_ST_ERR: begin
        if (w_alloc_en & w_cur_last)
          w_fsm_rd_nxt_state = ENUM_ST_IDLE;
      end
      default: begin
        w_fsm_rd_nxt_state = ENUM_ST_IDLE;
      end
    endcase
  end

  // Burst registers next state: they load the burst when its first beat is issued (or at the take
  // of an illegal burst) and then follow the beats.
  always_comb begin : p_com_regs
    w_addr_nxt      = reg_addr;
    w_left_nxt      = reg_left;
    w_id_nxt        = reg_id;
    w_size_nxt      = reg_size;
    w_burst_nxt     = reg_burst;
    w_len_nxt       = reg_len;
    w_instr_nxt     = reg_instr;
    w_first_err_nxt = reg_first_err;
    case (reg_fsm_rd_current_state)
      ENUM_ST_IDLE: begin
        if (i_ar_valid & w_illegal) begin
          w_left_nxt      = w_ar_len;
          w_id_nxt        = w_ar_id;
          w_first_err_nxt = 1'b1;
        end else if (w_alloc_en & ~w_cur_last) begin
          w_addr_nxt  = f_next(w_ar_addr, w_ar_size, w_ar_burst, w_ar_len);
          w_left_nxt  = w_ar_len - 8'(LPARA_ONE);
          w_id_nxt    = w_ar_id;
          w_size_nxt  = w_ar_size;
          w_burst_nxt = w_ar_burst;
          w_len_nxt   = w_ar_len;
          w_instr_nxt = w_ar_prot2;
        end
      end
      ENUM_ST_BURST: begin
        if (w_alloc_en & ~w_cur_last) begin
          w_addr_nxt = f_next(reg_addr, reg_size, reg_burst, reg_len);
          w_left_nxt = reg_left - 8'(LPARA_ONE);
        end
      end
      ENUM_ST_ERR: begin
        if (w_alloc_en) begin
          w_left_nxt      = reg_left - 8'(LPARA_ONE);
          w_first_err_nxt = 1'b0;
        end
      end
      default: begin
        w_left_nxt = reg_left;
      end
    endcase
  end

  // Part 3, sequential: burst registers without reset. They are read only while the state is BURST
  // or ERR, after they were loaded, so no reset is needed.
  always_ff @(posedge i_clk_main) begin : p_ff_regs
    reg_addr      <= w_addr_nxt;
    reg_left      <= w_left_nxt;
    reg_id        <= w_id_nxt;
    reg_size      <= w_size_nxt;
    reg_burst     <= w_burst_nxt;
    reg_len       <= w_len_nxt;
    reg_instr     <= w_instr_nxt;
    reg_first_err <= w_first_err_nxt;
  end

endmodule
