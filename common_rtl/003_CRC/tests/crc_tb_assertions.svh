localparam integer TB_ASSERTION_COUNT = 6;
integer tb_assert_hits [0:TB_ASSERTION_COUNT-1];
integer tb_assert_fails [0:TB_ASSERTION_COUNT-1];
integer tb_total_checks;
integer tb_total_fails;
integer tb_report_index;
string tb_assert_names [0:TB_ASSERTION_COUNT-1];

task automatic tb_init_assertions;
  integer index;
  begin
    tb_total_checks = 0;
    tb_total_fails = 0;
    for (index = 0; index < TB_ASSERTION_COUNT; index = index + 1) begin
      tb_assert_hits[index] = 0;
      tb_assert_fails[index] = 0;
    end
  end
endtask

task automatic tb_check;
  input integer assertion_id;
  input logic condition;
  input string evidence;
  begin
    tb_total_checks = tb_total_checks + 1;
    tb_assert_hits[assertion_id] = tb_assert_hits[assertion_id] + 1;
    if (condition !== 1'b1) begin
      tb_assert_fails[assertion_id] = tb_assert_fails[assertion_id] + 1;
      tb_total_fails = tb_total_fails + 1;
      $display("ASSERT FAIL [%0s] at %0t: %0s", tb_assert_names[assertion_id], $time, evidence);
    end
  end
endtask

task automatic tb_report_assertions;
  integer index;
  begin
    $display("ASSERTION TABLE: assertion_id | hits | failures");
    for (index = 0; index < TB_ASSERTION_COUNT; index = index + 1) begin
      $display("  %0s | %0d | %0d", tb_assert_names[index],
               tb_assert_hits[index], tb_assert_fails[index]);
      if (tb_assert_hits[index] == 0) begin
        $display("ASSERT NOT EXERCISED [%0s]", tb_assert_names[index]);
        tb_total_fails = tb_total_fails + 1;
      end
    end
    $display("ASSERTIONS: checks=%0d failures=%0d", tb_total_checks, tb_total_fails);
    if (tb_total_checks < 20)
      tb_total_fails = tb_total_fails + 1;
    if (tb_total_fails != 0)
      $fatal(1, "CRC testbench failed: %0d failure(s)", tb_total_fails);
  end
endtask
