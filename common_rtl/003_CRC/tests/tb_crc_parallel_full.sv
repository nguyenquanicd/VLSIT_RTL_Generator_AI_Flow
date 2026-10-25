`timescale 1ns/1ps

module tb_crc_parallel_full;
  localparam integer W = 16;
  localparam integer D = 32;

  logic i_clk_core;
  logic i_rst_n_core;
  logic i_ctrl_en;
  logic [D-1:0] i_data;
  logic [W-1:0] i_gen_poly;
  logic [W-1:0] i_init_xor_value;
  logic i_ref_in_en;
  logic i_ref_out_en;
  logic [W-1:0] i_final_xor_value;
  wire [W-1:0] o_crc_out;
  wire o_crc_ready;
  integer random_seed;
  integer reported_seed;
  integer random_count;
  integer random_index;
  logic [31:0] random_data;
  logic [31:0] random_config;

  m_crc_parallel_full #(.PARA_CRC_W(W), .PARA_DATA_W(D)) dut (
    .i_clk_core(i_clk_core), .i_rst_n_core(i_rst_n_core),
    .i_ctrl_en(i_ctrl_en), .i_data(i_data), .i_gen_poly(i_gen_poly),
    .i_init_xor_value(i_init_xor_value), .i_ref_in_en(i_ref_in_en),
    .i_ref_out_en(i_ref_out_en), .i_final_xor_value(i_final_xor_value),
    .o_crc_out(o_crc_out), .o_crc_ready(o_crc_ready)
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

  function automatic [D-1:0] reflect_each_byte;
    input [D-1:0] word;
    reg [D-1:0] reflected;
    integer byte_index;
    integer bit_index;
    begin
      for (byte_index = 0; byte_index < D/8; byte_index = byte_index + 1)
        for (bit_index = 0; bit_index < 8; bit_index = bit_index + 1)
          reflected[byte_index*8 + bit_index] = word[byte_index*8 + (7-bit_index)];
      reflect_each_byte = reflected;
    end
  endfunction

  function automatic [W-1:0] reference_crc;
    input [D-1:0] word;
    input [W-1:0] polynomial;
    input [W-1:0] init_xor;
    input logic reflect_in;
    input logic reflect_out;
    input [W-1:0] final_xor;
    reg [D-1:0] data_stream;
    reg [W-1:0] state;
    reg [W-1:0] reflected_state;
    integer bit_index;
    integer zero_index;
    begin
      // Golden model: CRC README Full module; reflect bytes, apply initial XOR, augment, then post-process.
      data_stream = reflect_in ? reflect_each_byte(word) : word;
      data_stream = data_stream ^ {init_xor, {(D-W){1'b0}}};
      state = '0;
      for (bit_index = D-1; bit_index >= 0; bit_index = bit_index - 1)
        state = reference_step(state, data_stream[bit_index], polynomial);
      for (zero_index = 0; zero_index < W; zero_index = zero_index + 1)
        state = reference_step(state, 1'b0, polynomial);
      for (bit_index = 0; bit_index < W; bit_index = bit_index + 1)
        reflected_state[bit_index] = state[W-1-bit_index];
      reference_crc = (reflect_out ? reflected_state : state) ^ final_xor;
    end
  endfunction

  task automatic run_case;
    input [D-1:0] word;
    input [W-1:0] polynomial;
    input [W-1:0] initial_xor;
    input logic reflect_in;
    input logic reflect_out;
    input [W-1:0] final_xor;
    reg [W-1:0] expected;
    begin
      expected = reference_crc(word, polynomial, initial_xor,
                               reflect_in, reflect_out, final_xor);
      wait (o_crc_ready === 1'b1);
      @(negedge i_clk_core);
      i_data = word;
      i_gen_poly = polynomial;
      i_init_xor_value = initial_xor;
      i_ref_in_en = reflect_in;
      i_ref_out_en = reflect_out;
      i_final_xor_value = final_xor;
      i_ctrl_en = 1'b1;
      @(posedge i_clk_core);
      #1;
      tb_check(1, o_crc_ready === 1'b0,
               "CRC README: accepted transaction must deassert ready");

      // Change the entire request while busy; the accepted configuration remains authoritative.
      @(negedge i_clk_core);
      i_data = ~word;
      i_gen_poly = ~polynomial;
      i_init_xor_value = ~initial_xor;
      i_ref_in_en = ~reflect_in;
      i_ref_out_en = ~reflect_out;
      i_final_xor_value = ~final_xor;
      i_ctrl_en = 1'b1;
      @(posedge i_clk_core);
      #1;
      tb_check(2, o_crc_ready === 1'b1,
               "CRC README Full module: one-cycle result latency");
      tb_check(3, o_crc_out === expected,
               "CRC README Common CRC convention: expected CRC with captured options");
      tb_check(4, o_crc_out === expected,
               "CRC README transaction rule: busy-time changes cannot alter this result");
      @(negedge i_clk_core);
      i_ctrl_en = 1'b0;
      @(posedge i_clk_core);
      #1;
      tb_check(5, o_crc_ready === 1'b1,
               "CRC README Full module: output configuration is ready for another request");
    end
  endtask

  task automatic reset_during_busy;
    begin
      @(negedge i_clk_core);
      i_data = 32'hA55A_8001;
      i_gen_poly = 16'h1021;
      i_init_xor_value = 16'h1D0F;
      i_ref_in_en = 1'b1;
      i_ref_out_en = 1'b1;
      i_final_xor_value = 16'hFFFF;
      i_ctrl_en = 1'b1;
      @(posedge i_clk_core);
      #1;
      tb_check(1, o_crc_ready === 1'b0,
               "CRC README: accepted transaction enters busy state");
      @(negedge i_clk_core);
      i_ctrl_en = 1'b0;
      i_rst_n_core = 1'b0;
      #1;
      tb_check(0, o_crc_ready === 1'b1 && o_crc_out === '0,
               "CRC README reset rule: asynchronous reset clears transaction state and output");
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
    i_gen_poly = 16'h8005;
    i_init_xor_value = '0;
    i_ref_in_en = 1'b0;
    i_ref_out_en = 1'b0;
    i_final_xor_value = '0;
    tb_init_assertions();
    tb_assert_names[0] = "CRC-README asynchronous reset";
    tb_assert_names[1] = "CRC-README request acceptance";
    tb_assert_names[2] = "CRC-README one-cycle latency";
    tb_assert_names[3] = "CRC-README CRC and option result";
    tb_assert_names[4] = "CRC-README captured options while busy";
    tb_assert_names[5] = "CRC-README ready after result";
    if (!$value$plusargs("SEED=%d", reported_seed)) reported_seed = 20261025;
    random_seed = reported_seed;
    if (!$value$plusargs("N=%d", random_count)) random_count = 32;

    repeat (2) @(posedge i_clk_core);
    #1;
    tb_check(0, o_crc_ready === 1'b1 && o_crc_out === '0,
             "CRC README reset rule: ready and output reset values");
    @(negedge i_clk_core);
    i_rst_n_core = 1'b1;

    run_case(32'h0000_0000, 16'h8005, 16'h0000, 1'b0, 1'b0, 16'h0000);
    run_case(32'h9ABC_DEF0, 16'h8005, 16'h1D0F, 1'b0, 1'b1, 16'hFFFF);
    run_case(32'hA55A_8001, 16'h1021, 16'hB2AA, 1'b1, 1'b1, 16'h5A5A);
    run_case(32'hFFFF_0000, 16'h1021, 16'hFFFF, 1'b1, 1'b0, 16'h00FF);
    for (random_index = 0; random_index < random_count; random_index = random_index + 1) begin
      random_data = $urandom(random_seed);
      random_config = $urandom(random_seed);
      run_case(random_data, random_config[15:0], random_config[31:16],
               random_config[0], random_config[1], random_data[15:0]);
    end

    reset_during_busy();
    tb_report_assertions();
    $display("PASS tb_crc_parallel_full: seed=%0d random_cases=%0d",
             reported_seed, random_count);
    $finish;
  end

  initial begin
    #1000000;
    $fatal(1, "tb_crc_parallel_full timeout");
  end
endmodule
