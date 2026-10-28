/*
 * Project      : VLSIT Common RTL library
 * Author       : Nguyen Quan and Claude Sonnet 5.5 (user)
 * AI Flow      : VLSIT RTL Generator AI Automation Flow
 * AI Flow Page : https://github.com/nguyenquanicd/VLSIT_RTL_Generator_AI_Model
 * Date         : 2026-10-26
 * Description  : Two-entry input slice of one AXI request channel of the AXI2TLUL bridge. The ready
 *                output to the AXI side is a flip-flop. An empty slice passes a beat to the next
 *                stage in the same cycle (cut-through, no registered delay); when the next stage
 *                stalls the slice keeps up to two beats, so one beat per cycle is accepted without
 *                a bubble. The payload registers have no reset: they are read only while the entry
 *                counter shows that they hold a beat.
 */
`timescale 1ns/1ps

module m_vlsit_axi2tlul_skid #(
  // Parameter Description: width of the payload of one beat (all fields of the channel except
  // VALID and READY, packed by the parent).
  // Parameter values: 1 or more; default is 8.
  // Parameter unit: bit
  parameter logic [31:0] PARA_PAYLOAD_W = 8,
  localparam logic [31:0] LPARA_EMPTY_CNT = 0,
  localparam logic [31:0] LPARA_ONE_CNT = 1,
  localparam logic [31:0] LPARA_FULL_CNT = 2
) (
  // Clock and reset
  input  wire                       i_clk_main,
  input  wire                       i_rst_n_main,

  // Upstream side (AXI port)
  input  wire                       i_valid,
  output logic                      o_ready,
  input  wire  [PARA_PAYLOAD_W-1:0] i_data,

  // Downstream side (request engine)
  output logic                      o_valid,
  input  wire                       i_ready,
  output logic [PARA_PAYLOAD_W-1:0] o_data
);

  // Internal signal declarations
  logic                      reg_ready;
  logic [1:0]                reg_cnt;
  logic [PARA_PAYLOAD_W-1:0] reg_data_0;
  logic [PARA_PAYLOAD_W-1:0] reg_data_1;
  logic                      w_push;
  logic                      w_pop;
  logic [1:0]                w_cnt_nxt;
  logic [PARA_PAYLOAD_W-1:0] w_data_0_nxt;
  logic [PARA_PAYLOAD_W-1:0] w_data_1_nxt;

  // A beat enters when the upstream valid meets the registered ready and leaves when the next stage
  // takes the offered beat. With an empty slice the beat at the input is the beat that is offered.
  assign o_ready = reg_ready;
  assign w_push  = i_valid & reg_ready;
  assign o_valid = (reg_cnt != 2'd0) | w_push;
  assign o_data  = (reg_cnt != 2'd0) ? reg_data_0 : i_data;
  assign w_pop   = o_valid & i_ready;

  // Entry counter and payload update. A beat that is pushed and popped in the same cycle with an
  // empty slice passes through and is not stored; otherwise the beat goes to the first free entry,
  // and the second entry moves up when the first one leaves.
  always_comb begin : p_com_skid
    w_cnt_nxt    = reg_cnt + {1'b0, w_push} - {1'b0, w_pop};
    w_data_0_nxt = reg_data_0;
    w_data_1_nxt = reg_data_1;
    case (reg_cnt)
      LPARA_EMPTY_CNT[1:0]: begin
        if (w_push & ~w_pop)
          w_data_0_nxt = i_data;
      end
      LPARA_ONE_CNT[1:0]: begin
        if (w_push & w_pop)
          w_data_0_nxt = i_data;
        else if (w_push)
          w_data_1_nxt = i_data;
      end
      LPARA_FULL_CNT[1:0]: begin
        if (w_pop)
          w_data_0_nxt = reg_data_1;
      end
      default: begin
        w_cnt_nxt = 2'd0;
      end
    endcase
  end

  // Control state: the entry counter and the registered ready are reset. The ready is low in reset
  // and whenever the slice will be full in the next cycle, so the ready output is a flip-flop.
  always_ff @(posedge i_clk_main, negedge i_rst_n_main) begin : p_ff_ctrl
    if (!i_rst_n_main) begin
      reg_cnt   <= 2'd0;
      reg_ready <= 1'b0;
    end else begin
      reg_cnt   <= w_cnt_nxt;
      reg_ready <= (w_cnt_nxt != LPARA_FULL_CNT[1:0]);
    end
  end

  // Payload registers without reset: a stored word is consumed only while the counter shows it.
  always_ff @(posedge i_clk_main) begin : p_ff_data
    reg_data_0 <= w_data_0_nxt;
    reg_data_1 <= w_data_1_nxt;
  end

endmodule
