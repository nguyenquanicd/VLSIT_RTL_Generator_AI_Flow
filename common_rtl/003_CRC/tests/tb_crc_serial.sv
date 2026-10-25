`timescale 1ns/1ps

module tb_crc_serial;
  localparam integer W = 4;

  logic i_clk_core;
  logic i_rst_n_core;
  logic i_ctrl_en;
  logic i_data_bit;
  logic [W-1:0] i_gen_poly;
  logic i_chk_en;
  wire [W-1:0] o_crc_seq;
  wire o_crc_err;
  logic [W-1:0] reference_state;
  integer random_seed;
  integer reported_seed;
  integer random_count;
  integer random_index;
  integer bit_index;
  logic [31:0] random_stream;
  logic [31:0] random_poly;

  m_crc_serial dut (
    .i_clk_core(i_clk_core), .i_rst_n_core(i_rst_n_core),
    .i_ctrl_en(i_ctrl_en), .i_data_bit(i_data_bit), .i_gen_poly(i_gen_poly),
    .i_chk_en(i_chk_en), .o_crc_seq(o_crc_seq), .o_crc_err(o_crc_err)
  );

  `include "crc_tb_assertions.svh"

  always #5 i_clk_core = ~i_clk_core;

  function automatic [W-1:0] reference_step;
    input [W-1:0] state;
    input logic input_bit;
    input [W-1:0] polynomial;
    begin
      // Golden model: CRC README Common CRC convention.
      reference_step = {state[W-2:0], input_bit};
      if (state[W-1])
        reference_step = reference_step ^ polynomial;
    end
  endfunction

  task automatic send_bit;
    input logic value;
    input [W-1:0] polynomial;
    begin
      reference_state = reference_step(reference_state, value, polynomial);
      @(negedge i_clk_core);
      i_data_bit = value;
      i_gen_poly = polynomial;
      i_ctrl_en = 1'b1;
      i_chk_en = 1'b0;
      @(posedge i_clk_core);
      #1;
      tb_check(1, o_crc_seq === reference_state,
               "CRC README Serial module: one MSB-first input bit updates the CRC state");
    end
  endtask

  task automatic run_frame;
    input [31:0] stream;
    input integer bit_count;
    input [W-1:0] polynomial;
    logic expected_error;
    begin
      for (bit_index = bit_count-1; bit_index >= 0; bit_index = bit_index - 1)
        send_bit(stream[bit_index], polynomial);
      tb_check(5, o_crc_seq === reference_state,
               "CRC README Serial module: polynomial remains fixed for this frame");
      expected_error = (reference_state != '0);

      // The first idle edge samples the old residue and clears the serial state.
      @(negedge i_clk_core);
      i_ctrl_en = 1'b0;
      i_chk_en = 1'b1;
      @(posedge i_clk_core);
      #1;
      tb_check(2, o_crc_seq === '0,
               "CRC README Serial module: ctrl_en low clears state at the next rising edge");
      tb_check(3, o_crc_err === expected_error,
               "CRC README Serial module: checker flags a nonzero residue on first idle edge");
      reference_state = '0;

      @(negedge i_clk_core);
      i_chk_en = 1'b0;
      @(posedge i_clk_core);
      #1;
      tb_check(4, o_crc_err === 1'b0,
               "CRC README Serial module: residue error is a one-cycle indication");
    end
  endtask

  task automatic verify_synchronous_reset;
    logic [W-1:0] state_before_reset;
    begin
      send_bit(1'b1, 4'h3);
      state_before_reset = reference_state;
      @(negedge i_clk_core);
      i_rst_n_core = 1'b0;
      i_ctrl_en = 1'b1;
      #1;
      tb_check(0, o_crc_seq === state_before_reset,
               "CRC README reset rule: serial reset is synchronous between rising edges");
      @(posedge i_clk_core);
      #1;
      tb_check(0, o_crc_seq === '0 && o_crc_err === 1'b0,
               "CRC README reset rule: serial state and error clear on rising edge");
      reference_state = '0;
      @(negedge i_clk_core);
      i_rst_n_core = 1'b1;
      i_ctrl_en = 1'b0;
    end
  endtask

  initial begin
    i_clk_core = 1'b0;
    i_rst_n_core = 1'b0;
    i_ctrl_en = 1'b0;
    i_data_bit = 1'b0;
    i_gen_poly = 4'h3;
    i_chk_en = 1'b0;
    reference_state = '0;
    tb_init_assertions();
    tb_assert_names[0] = "CRC-README synchronous reset";
    tb_assert_names[1] = "CRC-README serial recurrence";
    tb_assert_names[2] = "CRC-README idle clears state";
    tb_assert_names[3] = "CRC-README residue checker";
    tb_assert_names[4] = "CRC-README checker pulse";
    tb_assert_names[5] = "CRC-README polynomial per frame";
    if (!$value$plusargs("SEED=%d", reported_seed)) reported_seed = 20261025;
    random_seed = reported_seed;
    if (!$value$plusargs("N=%d", random_count)) random_count = 32;

    repeat (2) @(posedge i_clk_core);
    #1;
    tb_check(0, o_crc_seq === '0 && o_crc_err === 1'b0,
             "CRC README reset rule: serial outputs after synchronous reset");
    @(negedge i_clk_core);
    i_rst_n_core = 1'b1;

    // Directed frames exercise both a nonzero residue and the zero-residue case.
    run_frame(32'h0000_0FFF, 12, 4'h3);
    run_frame(32'h0000_0A60, 12, 4'h3);
    run_frame(32'hFFFF_FFFF, 32, 4'h9);
    for (random_index = 0; random_index < random_count; random_index = random_index + 1) begin
      random_stream = $urandom(random_seed);
      random_poly = $urandom(random_seed);
      run_frame(random_stream, 32, random_poly[W-1:0]);
    end

    verify_synchronous_reset();
    tb_report_assertions();
    $display("PASS tb_crc_serial: seed=%0d random_frames=%0d",
             reported_seed, random_count);
    $finish;
  end

  initial begin
    #1000000;
    $fatal(1, "tb_crc_serial timeout");
  end
endmodule
