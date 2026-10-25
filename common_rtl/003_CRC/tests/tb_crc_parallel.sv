`timescale 1ns/1ps

module tb_crc_parallel;
  localparam integer W = 8;
  localparam integer D = 16;

  logic i_clk_core;
  logic i_rst_n_core;
  logic i_ctrl_en;
  logic [D-1:0] i_data;
  logic [W-1:0] i_gen_poly;
  wire [W-1:0] o_crc_seq;
  wire o_crc_ready;
  integer random_seed;
  integer reported_seed;
  integer random_count;
  integer random_index;
  logic [31:0] random_data;
  logic [31:0] random_poly;

  m_crc_parallel #(.PARA_CRC_W(W), .PARA_DATA_W(D)) dut (
    .i_clk_core(i_clk_core), .i_rst_n_core(i_rst_n_core),
    .i_ctrl_en(i_ctrl_en), .i_data(i_data), .i_gen_poly(i_gen_poly),
    .o_crc_seq(o_crc_seq), .o_crc_ready(o_crc_ready)
  );

  `include "crc_tb_assertions.svh"

  always #5 i_clk_core = ~i_clk_core;

  function automatic [W-1:0] reference_step;
    input [W-1:0] state;
    input logic input_bit;
    input [W-1:0] polynomial;
    begin
      reference_step = {state[W-2:0], input_bit};
      if (state[W-1])
        reference_step = reference_step ^ polynomial;
    end
  endfunction

  function automatic [W-1:0] reference_crc;
    input [D-1:0] word;
    input [W-1:0] polynomial;
    reg [W-1:0] state;
    integer bit_index;
    integer zero_index;
    begin
      // Golden model: CRC README, Common CRC convention (MSB-first; append W zero bits).
      state = '0;
      for (bit_index = D-1; bit_index >= 0; bit_index = bit_index - 1)
        state = reference_step(state, word[bit_index], polynomial);
      for (zero_index = 0; zero_index < W; zero_index = zero_index + 1)
        state = reference_step(state, 1'b0, polynomial);
      reference_crc = state;
    end
  endfunction

  task automatic run_case;
    input [D-1:0] word;
    input [W-1:0] polynomial;
    reg [W-1:0] expected;
    begin
      expected = reference_crc(word, polynomial);
      wait (o_crc_ready === 1'b1);
      @(negedge i_clk_core);
      i_data = word;
      i_gen_poly = polynomial;
      i_ctrl_en = 1'b1;
      @(posedge i_clk_core);
      #1;
      tb_check(1, o_crc_ready === 1'b0,
               "CRC README: request acceptance must mark the module busy");

      // Alter data and polynomial during busy; this request must not replace the accepted one.
      @(negedge i_clk_core);
      i_data = ~word;
      i_gen_poly = ~polynomial;
      i_ctrl_en = 1'b1;
      @(posedge i_clk_core);
      #1;
      tb_check(2, o_crc_ready === 1'b1,
               "CRC README: one-cycle parallel result latency");
      tb_check(3, o_crc_seq === expected,
               "CRC README Common CRC convention: MSB-first augmented remainder");
      tb_check(4, o_crc_seq === expected,
               "CRC README transaction rule: busy-time request was ignored");

      @(negedge i_clk_core);
      i_ctrl_en = 1'b0;
      @(posedge i_clk_core);
      #1;
      tb_check(5, o_crc_ready === 1'b1 && o_crc_seq === expected,
               "CRC README: result remains stable until another accepted request");
    end
  endtask

  task automatic reset_during_busy;
    begin
      @(negedge i_clk_core);
      i_ctrl_en = 1'b1;
      i_data = 16'hA55A;
      i_gen_poly = 8'h07;
      @(posedge i_clk_core);
      #1;
      tb_check(1, o_crc_ready === 1'b0,
               "CRC README: accepted transaction enters busy state");
      @(negedge i_clk_core);
      i_ctrl_en = 1'b0;
      i_rst_n_core = 1'b0;
      #1;
      tb_check(0, o_crc_ready === 1'b1 && o_crc_seq === '0,
               "CRC README reset rule: asynchronous reset aborts the transaction");
      @(posedge i_clk_core);
      #1;
      @(negedge i_clk_core);
      i_rst_n_core = 1'b1;
    end
  endtask

  initial begin
    i_clk_core = 1'b0;
    i_rst_n_core = 1'b0;
    i_ctrl_en = 1'b0;
    i_data = '0;
    i_gen_poly = 8'h07;
    tb_init_assertions();
    tb_assert_names[0] = "CRC-README reset behavior";
    tb_assert_names[1] = "CRC-README request acceptance";
    tb_assert_names[2] = "CRC-README one-cycle latency";
    tb_assert_names[3] = "CRC-README CRC recurrence";
    tb_assert_names[4] = "CRC-README busy request handling";
    tb_assert_names[5] = "CRC-README result hold";
    if (!$value$plusargs("SEED=%d", reported_seed)) reported_seed = 20261025;
    random_seed = reported_seed;
    if (!$value$plusargs("N=%d", random_count)) random_count = 32;

    repeat (2) @(posedge i_clk_core);
    #1;
    tb_check(0, o_crc_ready === 1'b1 && o_crc_seq === '0,
             "CRC README reset rule: asynchronous reset state");
    @(negedge i_clk_core);
    i_rst_n_core = 1'b1;

    run_case(16'h0000, 8'h07);
    run_case(16'hFFFF, 8'h07);
    run_case(16'h8001, 8'h1D);
    run_case(16'hA55A, 8'hD5);
    run_case(16'h0102, 8'h07);

    for (random_index = 0; random_index < random_count; random_index = random_index + 1) begin
      random_data = $urandom(random_seed);
      random_poly = $urandom(random_seed);
      run_case(random_data[D-1:0], random_poly[W-1:0]);
    end

    reset_during_busy();
    tb_report_assertions();
    $display("PASS tb_crc_parallel: seed=%0d random_cases=%0d",
             reported_seed, random_count);
    $finish;
  end

  initial begin
    #1000000;
    $fatal(1, "tb_crc_parallel timeout");
  end
endmodule
