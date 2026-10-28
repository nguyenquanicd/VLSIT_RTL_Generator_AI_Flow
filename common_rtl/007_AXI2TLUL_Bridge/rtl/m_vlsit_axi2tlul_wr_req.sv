/*
 * Project      : VLSIT Common RTL library
 * Author       : Nguyen Quan and Claude Sonnet 5.5 (user)
 * AI Flow      : VLSIT RTL Generator AI Automation Flow
 * AI Flow Page : https://github.com/nguyenquanicd/VLSIT_RTL_Generator_AI_Model
 * Date         : 2026-10-26
 * Description  : Write request engine of the AXI2TLUL bridge. It takes one AW beat and the W beats
 *                of its burst from the input slices, checks the burst (same rules as the read
 *                engine), and splits a legal burst into one Put request per W beat with the beat
 *                address aligned to the size, the size, the strobe mask (WSTRB AND the byte lanes
 *                of the beat), the opcode (PutFullData when the mask covers the whole aligned
 *                transfer, else PutPartialData), and the data. The first request is presented in
 *                the same cycle as the AW and W beats (cut-through). W data may be waiting in its
 *                slice before the AW beat arrives. The write data of an illegal burst is dropped
 *                and one error slot is allocated after its last beat. A WLAST that does not match
 *                AWLEN raises a one-cycle event.
 */
`timescale 1ns/1ps

module m_vlsit_axi2tlul_wr_req #(
  // Parameter Description: width of the address.
  // Parameter values: 12 to 64; default is 32.
  // Parameter unit: bit
  parameter logic [31:0] PARA_ADDR_W = 32,
  // Parameter Description: width of the AXI ID.
  // Parameter values: 1 to 32; default is 8.
  // Parameter unit: bit
  parameter logic [31:0] PARA_AXI_ID_W = 8,
  // Parameter Description: width of the data bus; the strobe and the mask have one bit per byte.
  // Parameter values: 32, 64, 128, 256, 512, or 1024; default is 32.
  // Parameter unit: bit
  parameter logic [31:0] PARA_DATA_W = 32,
  localparam logic [31:0] LPARA_STRB_W = PARA_DATA_W / 8,
  localparam logic [31:0] LPARA_BYTE_W = $clog2(PARA_DATA_W / 8),
  localparam logic [31:0] LPARA_SIZE_W = $clog2($clog2(PARA_DATA_W / 8) + 1),
  localparam logic [31:0] LPARA_LEN_W = 8,
  localparam logic [31:0] LPARA_SIZE_FLD_W = 3,
  localparam logic [31:0] LPARA_BURST_FLD_W = 2,
  localparam logic [31:0] LPARA_LSB_LEN = PARA_AXI_ID_W + PARA_ADDR_W,
  localparam logic [31:0] LPARA_LSB_SIZE = PARA_AXI_ID_W + PARA_ADDR_W + 8,
  localparam logic [31:0] LPARA_LSB_BURST = PARA_AXI_ID_W + PARA_ADDR_W + 11,
  localparam logic [31:0] LPARA_LSB_PROT2 = PARA_AXI_ID_W + PARA_ADDR_W + 13,
  localparam logic [31:0] LPARA_AW_W = PARA_AXI_ID_W + PARA_ADDR_W + 14,
  localparam logic [31:0] LPARA_W_W = PARA_DATA_W + PARA_DATA_W / 8 + 1,
  localparam logic [31:0] LPARA_BURST_FIXED = 0,
  localparam logic [31:0] LPARA_BURST_INCR = 1,
  localparam logic [31:0] LPARA_BURST_WRAP = 2,
  localparam logic [31:0] LPARA_PAGE_BYTES = 4096,
  localparam logic [31:0] LPARA_OPC_PUT_FULL = 0,
  localparam logic [31:0] LPARA_OPC_PUT_PART = 1,
  localparam logic [31:0] LPARA_ONE = 1
) (
  // Clock and reset
  input  wire                      i_clk_main,
  input  wire                      i_rst_n_main,

  // AW input slice
  input  wire                      i_aw_valid,
  output logic                     o_aw_ready,
  input  wire  [LPARA_AW_W-1:0]    i_aw_data,

  // W input slice
  input  wire                      i_w_valid,
  output logic                     o_w_ready,
  input  wire  [LPARA_W_W-1:0]     i_w_data,

  // Write request to the arbiter
  output logic                     o_req_valid,
  input  wire                      i_req_gnt,
  output logic [2:0]               o_req_opcode,
  output logic [PARA_ADDR_W-1:0]   o_req_addr,
  output logic [LPARA_SIZE_W-1:0]  o_req_size,
  output logic [LPARA_STRB_W-1:0]  o_req_mask,
  output logic [PARA_DATA_W-1:0]   o_req_data,
  output logic                     o_req_instr,

  // Slot allocation to the write slot table
  output logic                     o_alloc_en,
  output logic                     o_alloc_gen,
  output logic [PARA_AXI_ID_W-1:0] o_alloc_id,
  output logic                     o_alloc_last,
  input  wire                      i_alloc_ok,
  output logic                     o_pin_valid,
  output logic [PARA_AXI_ID_W-1:0] o_pin_id,

  // Status
  output logic                     o_evt_axi_err
);

  // FSM states: IDLE waits for an AW beat, BURST issues the remaining beats of a legal burst, and
  // DISC drops the W beats of an illegal burst. Encoding 2'b11 is unused and recovers to IDLE.
  typedef enum logic [1:0] {
    ENUM_ST_IDLE  = 2'b00,
    ENUM_ST_BURST = 2'b01,
    ENUM_ST_DISC  = 2'b10
  } wr_state_type_def;

  // Internal signal declarations
  wr_state_type_def         reg_fsm_wr_current_state;
  wr_state_type_def         w_fsm_wr_nxt_state;
  logic [PARA_ADDR_W-1:0]   reg_addr;
  logic [7:0]               reg_left;
  logic [PARA_AXI_ID_W-1:0] reg_id;
  logic [2:0]               reg_size;
  logic [1:0]               reg_burst;
  logic [7:0]               reg_len;
  logic                     reg_instr;
  logic [PARA_ADDR_W-1:0]   w_addr_nxt;
  logic [7:0]               w_left_nxt;
  logic [PARA_AXI_ID_W-1:0] w_id_nxt;
  logic [2:0]               w_size_nxt;
  logic [1:0]               w_burst_nxt;
  logic [7:0]               w_len_nxt;
  logic                     w_instr_nxt;
  logic [PARA_AXI_ID_W-1:0] w_aw_id;
  logic [PARA_ADDR_W-1:0]   w_aw_addr;
  logic [7:0]               w_aw_len;
  logic [2:0]               w_aw_size;
  logic [1:0]               w_aw_burst;
  logic                     w_aw_prot2;
  logic [PARA_DATA_W-1:0]   w_w_data;
  logic [LPARA_STRB_W-1:0]  w_w_strb;
  logic                     w_w_last;
  logic [PARA_ADDR_W-1:0]   w_aw_aligned;
  logic [16:0]              w_aw_total;
  logic [16:0]              w_aw_page_end;
  logic                     w_illegal;
  logic [PARA_ADDR_W-1:0]   w_cur_addr;
  logic [2:0]               w_cur_size;
  logic [7:0]               w_cur_left;
  logic [PARA_AXI_ID_W-1:0] w_cur_id;
  logic                     w_cur_instr;
  logic                     w_cur_first;
  logic                     w_cur_last;
  logic [LPARA_STRB_W-1:0]  w_mask;
  logic [LPARA_STRB_W-1:0]  w_region;
  logic                     w_req_valid;
  logic                     w_alloc_en;
  logic                     w_alloc_gen;
  logic                     w_aw_pop;
  logic                     w_w_pop;
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

  // Byte lanes of the whole aligned transfer region of a beat (all bytes that a full write covers).
  function automatic logic [LPARA_STRB_W-1:0] f_region(input logic [LPARA_BYTE_W-1:0] addr,
                                                       input logic [2:0] size);
    logic [LPARA_BYTE_W:0] off;
    logic [LPARA_BYTE_W:0] bsz;
    logic [LPARA_BYTE_W:0] aoff;
    logic [LPARA_BYTE_W:0] hi;
    begin
      off  = {1'b0, addr};
      bsz  = {{LPARA_BYTE_W{1'b0}}, 1'b1} << size;
      aoff = off & ~(bsz - {{LPARA_BYTE_W{1'b0}}, 1'b1});
      hi   = aoff + bsz - {{LPARA_BYTE_W{1'b0}}, 1'b1};
      for (int idx = 0; idx < LPARA_STRB_W; idx++)
        f_region[idx] = ($bits(aoff)'(idx) >= aoff) & ($bits(aoff)'(idx) <= hi);
    end
  endfunction

  // Fields of the AW beat from the input slice, packed as {prot2, burst, size, len, addr, id}, and
  // of the W beat, packed as {last, strb, data}.
  assign w_aw_id    = i_aw_data[PARA_AXI_ID_W-1:0];
  assign w_aw_addr  = i_aw_data[PARA_AXI_ID_W +: PARA_ADDR_W];
  assign w_aw_len   = i_aw_data[LPARA_LSB_LEN +: LPARA_LEN_W];
  assign w_aw_size  = i_aw_data[LPARA_LSB_SIZE +: LPARA_SIZE_FLD_W];
  assign w_aw_burst = i_aw_data[LPARA_LSB_BURST +: LPARA_BURST_FLD_W];
  assign w_aw_prot2 = i_aw_data[LPARA_LSB_PROT2];
  assign w_w_data   = i_w_data[PARA_DATA_W-1:0];
  assign w_w_strb   = i_w_data[PARA_DATA_W +: LPARA_STRB_W];
  assign w_w_last   = i_w_data[PARA_DATA_W + LPARA_STRB_W];

  // Burst check on the AW beat: the INCR burst must stay in its 4 KB page, WRAP needs a length of
  // 2, 4, 8, or 16 and an aligned start address, FIXED has at most 16 beats, the size must fit the
  // bus, and the burst type 2'b11 is reserved. Any violation makes the burst illegal.
  assign w_aw_aligned  = f_align(w_aw_addr, w_aw_size);
  assign w_aw_total    = ({8'd0, ({1'b0, w_aw_len} + 9'(LPARA_ONE))}) << w_aw_size;
  assign w_aw_page_end = {5'd0, w_aw_aligned[11:0]} + w_aw_total;

  // Legality of the AW burst, evaluated on the AW beat that the slice offers.
  always_comb begin : p_com_chk
    w_illegal = (w_aw_size > LPARA_BYTE_W[2:0]);
    case (w_aw_burst)
      LPARA_BURST_FIXED[1:0]: w_illegal = w_illegal | (w_aw_len[7:4] != 4'd0);
      LPARA_BURST_INCR[1:0]:  w_illegal = w_illegal | (w_aw_page_end > 17'(LPARA_PAGE_BYTES));
      LPARA_BURST_WRAP[1:0]:  w_illegal = w_illegal | (w_aw_len[7:4] != 4'd0) | ~w_aw_len[0] |
                                          ((w_aw_len & (w_aw_len + 8'(LPARA_ONE))) != 8'd0) | (w_aw_addr != w_aw_aligned);
      default:                w_illegal = 1'b1;
    endcase
  end

  // Current beat: the AW beat itself while the engine is idle (cut-through of the first beat), the
  // stored burst state otherwise. FIXED beats always use the byte lanes of the start address.
  always_comb begin : p_com_cur
    w_cur_addr  = reg_addr;
    w_cur_size  = reg_size;
    w_cur_left  = reg_left;
    w_cur_id    = reg_id;
    w_cur_instr = reg_instr;
    w_cur_first = (reg_burst == LPARA_BURST_FIXED[1:0]);
    if (reg_fsm_wr_current_state == ENUM_ST_IDLE) begin
      w_cur_addr  = w_aw_addr;
      w_cur_size  = w_aw_size;
      w_cur_left  = w_aw_len;
      w_cur_id    = w_aw_id;
      w_cur_instr = w_aw_prot2;
      w_cur_first = 1'b1;
    end
    w_cur_last = (w_cur_left == 8'd0);
  end

  // Strobe mask and opcode: the mask is WSTRB limited to the byte lanes of the beat; the write is
  // full when the mask covers the whole aligned transfer region, and partial otherwise.
  assign w_mask   = w_w_strb & f_mask(w_cur_addr[LPARA_BYTE_W-1:0], w_cur_size, w_cur_first);
  assign w_region = f_region(w_cur_addr[LPARA_BYTE_W-1:0], w_cur_size);

  // Request, allocation, and pops. IDLE presents the first request of a legal burst when an AW beat
  // and a W beat are present and a slot is available, and takes an illegal burst without a request.
  // BURST presents one request per W beat. DISC drops one W beat per cycle and allocates the error
  // slot with the last one.
  always_comb begin : p_com_out
    w_req_valid = 1'b0;
    w_alloc_en  = 1'b0;
    w_alloc_gen = 1'b0;
    w_aw_pop    = 1'b0;
    w_w_pop     = 1'b0;
    w_evt       = 1'b0;
    case (reg_fsm_wr_current_state)
      ENUM_ST_IDLE: begin
        if (i_aw_valid) begin
          if (w_illegal) begin
            w_aw_pop = 1'b1;
            w_evt    = 1'b1;
          end else begin
            w_req_valid = i_w_valid & i_alloc_ok;
            w_alloc_en  = i_w_valid & i_alloc_ok & i_req_gnt;
            w_aw_pop    = i_w_valid & i_alloc_ok & i_req_gnt;
            w_w_pop     = i_w_valid & i_alloc_ok & i_req_gnt;
          end
        end
      end
      ENUM_ST_BURST: begin
        w_req_valid = i_w_valid & i_alloc_ok;
        w_alloc_en  = i_w_valid & i_alloc_ok & i_req_gnt;
        w_w_pop     = i_w_valid & i_alloc_ok & i_req_gnt;
      end
      ENUM_ST_DISC: begin
        w_alloc_gen = 1'b1;
        w_w_pop     = i_w_valid & (~w_cur_last | i_alloc_ok);
        w_alloc_en  = i_w_valid & w_cur_last & i_alloc_ok;
      end
      default: begin
        w_req_valid = 1'b0;
      end
    endcase
    if (w_w_pop & (w_w_last != w_cur_last))
      w_evt = 1'b1;
  end

  // Output mapping of the request, the allocation, the pops, and the status.
  assign o_aw_ready    = w_aw_pop;
  assign o_w_ready     = w_w_pop;
  assign o_req_valid   = w_req_valid;
  assign o_req_opcode  = (w_mask == w_region) ? LPARA_OPC_PUT_FULL[2:0] : LPARA_OPC_PUT_PART[2:0];
  assign o_req_addr    = f_align(w_cur_addr, w_cur_size);
  assign o_req_size    = w_cur_size[LPARA_SIZE_W-1:0];
  assign o_req_mask    = w_mask;
  assign o_req_data    = w_w_data;
  assign o_req_instr   = w_cur_instr;
  assign o_alloc_en    = w_alloc_en;
  assign o_alloc_gen   = w_alloc_gen;
  assign o_alloc_id    = w_cur_id;
  assign o_alloc_last  = w_cur_last;
  assign o_pin_valid   = (reg_fsm_wr_current_state == ENUM_ST_BURST);
  assign o_pin_id      = reg_id;
  assign o_evt_axi_err = w_evt;

  // Part 1, sequential: the current state of the engine, reset to IDLE.
  always_ff @(posedge i_clk_main, negedge i_rst_n_main) begin : p_ff_fsm_wr
    if (!i_rst_n_main)
      reg_fsm_wr_current_state <= ENUM_ST_IDLE;
    else
      reg_fsm_wr_current_state <= w_fsm_wr_nxt_state;
  end

  // Part 2, combinational: IDLE goes to BURST after the first beat of a legal burst with more beats
  // and to DISC on an illegal burst; BURST returns to IDLE after the last beat and DISC after the
  // allocation of the error slot.
  always_comb begin : p_com_fsm_nxt
    w_fsm_wr_nxt_state = reg_fsm_wr_current_state;
    case (reg_fsm_wr_current_state)
      ENUM_ST_IDLE: begin
        if (i_aw_valid & w_illegal)
          w_fsm_wr_nxt_state = ENUM_ST_DISC;
        else if (w_alloc_en & ~w_cur_last)
          w_fsm_wr_nxt_state = ENUM_ST_BURST;
      end
      ENUM_ST_BURST: begin
        if (w_alloc_en & w_cur_last)
          w_fsm_wr_nxt_state = ENUM_ST_IDLE;
      end
      ENUM_ST_DISC: begin
        if (w_alloc_en)
          w_fsm_wr_nxt_state = ENUM_ST_IDLE;
      end
      default: begin
        w_fsm_wr_nxt_state = ENUM_ST_IDLE;
      end
    endcase
  end

  // Burst registers next state: they load the burst when its first beat is issued (or at the take
  // of an illegal burst) and then follow the beats.
  always_comb begin : p_com_regs
    w_addr_nxt  = reg_addr;
    w_left_nxt  = reg_left;
    w_id_nxt    = reg_id;
    w_size_nxt  = reg_size;
    w_burst_nxt = reg_burst;
    w_len_nxt   = reg_len;
    w_instr_nxt = reg_instr;
    case (reg_fsm_wr_current_state)
      ENUM_ST_IDLE: begin
        if (i_aw_valid & w_illegal) begin
          w_left_nxt = w_aw_len;
          w_id_nxt   = w_aw_id;
        end else if (w_alloc_en & ~w_cur_last) begin
          w_addr_nxt  = f_next(w_aw_addr, w_aw_size, w_aw_burst, w_aw_len);
          w_left_nxt  = w_aw_len - 8'(LPARA_ONE);
          w_id_nxt    = w_aw_id;
          w_size_nxt  = w_aw_size;
          w_burst_nxt = w_aw_burst;
          w_len_nxt   = w_aw_len;
          w_instr_nxt = w_aw_prot2;
        end
      end
      ENUM_ST_BURST: begin
        if (w_alloc_en & ~w_cur_last) begin
          w_addr_nxt = f_next(reg_addr, reg_size, reg_burst, reg_len);
          w_left_nxt = reg_left - 8'(LPARA_ONE);
        end
      end
      ENUM_ST_DISC: begin
        if (w_w_pop)
          w_left_nxt = reg_left - 8'(LPARA_ONE);
      end
      default: begin
        w_left_nxt = reg_left;
      end
    endcase
  end

  // Part 3, sequential: burst registers without reset. They are read only while the state is BURST
  // or DISC, after they were loaded, so no reset is needed.
  always_ff @(posedge i_clk_main) begin : p_ff_regs
    reg_addr  <= w_addr_nxt;
    reg_left  <= w_left_nxt;
    reg_id    <= w_id_nxt;
    reg_size  <= w_size_nxt;
    reg_burst <= w_burst_nxt;
    reg_len   <= w_len_nxt;
    reg_instr <= w_instr_nxt;
  end

endmodule
