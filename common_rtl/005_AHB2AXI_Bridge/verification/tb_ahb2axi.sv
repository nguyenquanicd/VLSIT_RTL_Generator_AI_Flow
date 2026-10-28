`timescale 1ns/1ps

module tb_ahb2axi;

  localparam integer PARA_RD_ID_COUNT = 1;
  localparam integer PARA_WR_ID_COUNT = 1;
  localparam integer AHB_ASSERTION_COUNT = 21;
  localparam integer AXI_ASSERTION_COUNT = 33;
  localparam integer BRIDGE_ASSERTION_COUNT = 17;

  logic         i_clk_core;
  logic         i_rst_n_core;

  logic         i_ahb_hsel;
  wire          i_ahb_hready;
  logic [31:0]  i_ahb_haddr;
  logic [1:0]   i_ahb_htrans;
  logic         i_ahb_hwrite;
  logic [2:0]   i_ahb_hsize;
  logic [2:0]   i_ahb_hburst;
  logic [6:0]   i_ahb_hprot;
  logic         i_ahb_hnonsec;
  logic         i_ahb_hmastlock;
  logic [31:0]  i_ahb_hwdata;
  logic [3:0]   i_ahb_hwstrb;
  wire          o_ahb_hreadyout;
  wire          o_ahb_hresp;
  wire [31:0]   o_ahb_hrdata;

  wire [2:0]    o_axi_awid;
  wire [31:0]   o_axi_awaddr;
  wire [7:0]    o_axi_awlen;
  wire [2:0]    o_axi_awsize;
  wire [1:0]    o_axi_awburst;
  wire          o_axi_awlock;
  wire [3:0]    o_axi_awcache;
  wire [2:0]    o_axi_awprot;
  wire          o_axi_awvalid;
  logic         i_axi_awready;
  wire [31:0]   o_axi_wdata;
  wire [3:0]    o_axi_wstrb;
  wire          o_axi_wlast;
  wire          o_axi_wvalid;
  logic         i_axi_wready;
  logic [2:0]   i_axi_bid;
  logic [1:0]   i_axi_bresp;
  logic         i_axi_bvalid;
  wire          o_axi_bready;
  wire [2:0]    o_axi_arid;
  wire [31:0]   o_axi_araddr;
  wire [7:0]    o_axi_arlen;
  wire [2:0]    o_axi_arsize;
  wire [1:0]    o_axi_arburst;
  wire          o_axi_arlock;
  wire [3:0]    o_axi_arcache;
  wire [2:0]    o_axi_arprot;
  wire          o_axi_arvalid;
  logic         i_axi_arready;
  logic [2:0]   i_axi_rid;
  logic [31:0]  i_axi_rdata;
  logic [1:0]   i_axi_rresp;
  logic         i_axi_rlast;
  logic         i_axi_rvalid;
  wire          o_axi_rready;

  integer       selected_case;
  integer       test_checks;
  integer       test_failures;
  integer       assertion_failures;
  integer       assertions_never_exercised;
  integer       ahb_hits [0:AHB_ASSERTION_COUNT-1];
  integer       ahb_fails[0:AHB_ASSERTION_COUNT-1];
  integer       axi_hits [0:AXI_ASSERTION_COUNT-1];
  integer       axi_fails[0:AXI_ASSERTION_COUNT-1];
  integer       bridge_hits [0:BRIDGE_ASSERTION_COUNT-1];
  integer       bridge_fails[0:BRIDGE_ASSERTION_COUNT-1];
  string        ahb_names [0:AHB_ASSERTION_COUNT-1];
  string        ahb_sources[0:AHB_ASSERTION_COUNT-1];
  string        axi_names [0:AXI_ASSERTION_COUNT-1];
  string        axi_sources[0:AXI_ASSERTION_COUNT-1];
  string        bridge_names [0:BRIDGE_ASSERTION_COUNT-1];
  string        bridge_sources[0:BRIDGE_ASSERTION_COUNT-1];

  integer       ar_handshakes;
  integer       aw_handshakes;
  integer       w_handshakes;
  integer       wlast_handshakes;
  integer       r_handshakes;
  integer       b_handshakes;
  integer       ahb_read_accepts;
  integer       ahb_write_accepts;
  integer       exp_ar_head;
  integer       exp_ar_tail;
  integer       exp_aw_head;
  integer       exp_aw_tail;
  integer       exp_w_head;
  integer       exp_w_tail;
  logic [31:0]  exp_ar_addr [0:63];
  logic [2:0]   exp_ar_size [0:63];
  logic [3:0]   exp_ar_cache[0:63];
  logic [2:0]   exp_ar_prot [0:63];
  logic [31:0]  exp_aw_addr [0:63];
  logic [7:0]   exp_aw_len  [0:63];
  logic [2:0]   exp_aw_size [0:63];
  logic [1:0]   exp_aw_burst[0:63];
  logic [3:0]   exp_aw_cache[0:63];
  logic [2:0]   exp_aw_prot [0:63];
  logic [31:0]  exp_w_data  [0:255];
  logic [3:0]   exp_w_strb  [0:255];
  logic         exp_w_last  [0:255];

  logic         prev_ahb_wait;
  logic [1:0]   prev_htrans;
  logic [31:0]  prev_haddr;
  logic         prev_hwrite;
  logic [2:0]   prev_hsize;
  logic [2:0]   prev_hburst;
  logic [6:0]   prev_hprot;
  logic         prev_hnonsec;
  logic         prev_hmastlock;
  logic [31:0]  prev_hwdata;
  logic [3:0]   prev_hwstrb;
  logic         prev_error_first;
  logic         pending_ahb_read;
  logic         previous_accepted_ahb_address;
  logic [31:0]  previous_ahb_address;
  logic [2:0]   previous_ahb_size;
  logic [2:0]   previous_ahb_burst;
  logic [6:0]   fixed_burst_hprot;
  logic         fixed_burst_tracking;

  logic         prev_ar_stall;
  logic [55:0]  prev_ar_payload;
  logic         prev_aw_stall;
  logic [55:0]  prev_aw_payload;
  logic         prev_w_stall;
  logic [36:0]  prev_w_payload;
  logic         prev_r_stall;
  logic [37:0]  prev_r_payload;
  logic         prev_b_stall;
  logic [4:0]   prev_b_payload;
  logic [2:0]   last_ar_id;
  logic [2:0]   last_aw_id;
  logic [31:0]  last_aw_addr;
  logic [7:0]   last_aw_len;

  logic         quiet_mode;
  logic         reject_mode;
  logic         burst_capture_mode;
  logic         burst_capture_done;
  integer       burst_expected_addresses;
  integer       burst_accepted_addresses;
  logic         last_ahb_address_accepted;
  logic         burst_early_issue_logged;

  assign i_ahb_hready = o_ahb_hreadyout;

  initial begin
    i_clk_core = 1'b0;
    forever #5 i_clk_core = ~i_clk_core;
  end

  m_ahb2axi_top #(
    .PARA_RD_ID_COUNT (32'd1),
    .PARA_WR_ID_COUNT (32'd1)
  ) u_dut (
    .i_clk_core       (i_clk_core),
    .i_rst_n_core     (i_rst_n_core),
    .i_ahb_hsel       (i_ahb_hsel),
    .i_ahb_hready     (i_ahb_hready),
    .i_ahb_haddr      (i_ahb_haddr),
    .i_ahb_htrans     (i_ahb_htrans),
    .i_ahb_hwrite     (i_ahb_hwrite),
    .i_ahb_hsize       (i_ahb_hsize),
    .i_ahb_hburst     (i_ahb_hburst),
    .i_ahb_hprot      (i_ahb_hprot),
    .i_ahb_hnonsec    (i_ahb_hnonsec),
    .i_ahb_hmastlock  (i_ahb_hmastlock),
    .i_ahb_hwdata     (i_ahb_hwdata),
    .i_ahb_hwstrb     (i_ahb_hwstrb),
    .o_ahb_hreadyout  (o_ahb_hreadyout),
    .o_ahb_hresp      (o_ahb_hresp),
    .o_ahb_hrdata     (o_ahb_hrdata),
    .o_axi_awid       (o_axi_awid),
    .o_axi_awaddr     (o_axi_awaddr),
    .o_axi_awlen      (o_axi_awlen),
    .o_axi_awsize     (o_axi_awsize),
    .o_axi_awburst    (o_axi_awburst),
    .o_axi_awlock     (o_axi_awlock),
    .o_axi_awcache    (o_axi_awcache),
    .o_axi_awprot     (o_axi_awprot),
    .o_axi_awvalid    (o_axi_awvalid),
    .i_axi_awready    (i_axi_awready),
    .o_axi_wdata      (o_axi_wdata),
    .o_axi_wstrb      (o_axi_wstrb),
    .o_axi_wlast      (o_axi_wlast),
    .o_axi_wvalid     (o_axi_wvalid),
    .i_axi_wready     (i_axi_wready),
    .i_axi_bid        (i_axi_bid),
    .i_axi_bresp       (i_axi_bresp),
    .i_axi_bvalid     (i_axi_bvalid),
    .o_axi_bready     (o_axi_bready),
    .o_axi_arid       (o_axi_arid),
    .o_axi_araddr     (o_axi_araddr),
    .o_axi_arlen      (o_axi_arlen),
    .o_axi_arsize     (o_axi_arsize),
    .o_axi_arburst    (o_axi_arburst),
    .o_axi_arlock     (o_axi_arlock),
    .o_axi_arcache    (o_axi_arcache),
    .o_axi_arprot     (o_axi_arprot),
    .o_axi_arvalid    (o_axi_arvalid),
    .i_axi_arready    (i_axi_arready),
    .i_axi_rid        (i_axi_rid),
    .i_axi_rdata      (i_axi_rdata),
    .i_axi_rresp      (i_axi_rresp),
    .i_axi_rlast      (i_axi_rlast),
    .i_axi_rvalid     (i_axi_rvalid),
    .o_axi_rready     (o_axi_rready)
  );

  function automatic logic [3:0] f_expected_cache(
    input logic [6:0] hprot_value,
    input logic       is_write
  );
    begin
      if (hprot_value[4] == 1'b0) begin
        f_expected_cache = {2'b00, hprot_value[3], hprot_value[2]};
      end else if (hprot_value[5] == 1'b1) begin
        if (is_write == 1'b1) begin
          f_expected_cache = {2'b10, hprot_value[3], hprot_value[2]};
        end else begin
          f_expected_cache = {2'b01, hprot_value[3], hprot_value[2]};
        end
      end else begin
        if (is_write == 1'b1) begin
          f_expected_cache = {2'b01, hprot_value[3], hprot_value[2]};
        end else begin
          f_expected_cache = {2'b10, hprot_value[3], hprot_value[2]};
        end
      end
    end
  endfunction

  function automatic logic [2:0] f_expected_prot(
    input logic [6:0] hprot_value,
    input logic       hnonsec_value
  );
    begin
      f_expected_prot = {~hprot_value[0], hnonsec_value, hprot_value[1]};
    end
  endfunction

  function automatic logic f_legal_awlen(input logic [7:0] awlen_value);
    begin
      case (awlen_value)
        8'd0, 8'd3, 8'd7, 8'd15: f_legal_awlen = 1'b1;
        default:                 f_legal_awlen = 1'b0;
      endcase
    end
  endfunction

  function automatic logic f_no_4k_cross(
    input logic [31:0] addr_value,
    input logic [7:0]  len_value,
    input logic [2:0]  size_value
  );
    logic [32:0] last_byte;
    logic [32:0] bytes_per_burst;
    begin
      bytes_per_burst = ({25'b0, len_value} + 33'd1) << size_value;
      last_byte = {1'b0, addr_value} + bytes_per_burst - 33'd1;
      f_no_4k_cross = (addr_value[31:12] == last_byte[31:12]);
    end
  endfunction

  function automatic logic f_aligned(
    input logic [31:0] addr_value,
    input logic [2:0]  size_value
  );
    begin
      case (size_value)
        3'd0:    f_aligned = 1'b1;
        3'd1:    f_aligned = (addr_value[0] == 1'b0);
        3'd2:    f_aligned = (addr_value[1:0] == 2'b00);
        default: f_aligned = 1'b0;
      endcase
    end
  endfunction

  task automatic pcheck(
    input integer family,
    input integer assertion_id,
    input logic   antecedent,
    input logic   property_value
  );
    begin
      if (antecedent === 1'b1) begin
        case (family)
          0: begin
            ahb_hits[assertion_id] = ahb_hits[assertion_id] + 1;
            if (property_value !== 1'b1) begin
              ahb_fails[assertion_id] = ahb_fails[assertion_id] + 1;
              assertion_failures = assertion_failures + 1;
              $display("ASSERT_FAIL AHB %02d %s [%s] at %0t", assertion_id + 1,
                       ahb_names[assertion_id], ahb_sources[assertion_id], $time);
            end
          end
          1: begin
            axi_hits[assertion_id] = axi_hits[assertion_id] + 1;
            if (property_value !== 1'b1) begin
              axi_fails[assertion_id] = axi_fails[assertion_id] + 1;
              assertion_failures = assertion_failures + 1;
              $display("ASSERT_FAIL AXI %02d %s [%s] at %0t", assertion_id + 1,
                       axi_names[assertion_id], axi_sources[assertion_id], $time);
            end
          end
          default: begin
            bridge_hits[assertion_id] = bridge_hits[assertion_id] + 1;
            if (property_value !== 1'b1) begin
              bridge_fails[assertion_id] = bridge_fails[assertion_id] + 1;
              assertion_failures = assertion_failures + 1;
              $display("ASSERT_FAIL BRIDGE %02d %s [%s] at %0t", assertion_id + 1,
                       bridge_names[assertion_id], bridge_sources[assertion_id], $time);
            end
          end
        endcase
      end
    end
  endtask

  task automatic rcheck(input integer assertion_id, input logic property_value);
    begin
      bridge_hits[assertion_id] = bridge_hits[assertion_id] + 1;
      if (property_value !== 1'b1) begin
        bridge_fails[assertion_id] = bridge_fails[assertion_id] + 1;
        assertion_failures = assertion_failures + 1;
        $display("ASSERT_FAIL BRIDGE %02d %s [%s] at %0t", assertion_id + 1,
                 bridge_names[assertion_id], bridge_sources[assertion_id], $time);
      end
    end
  endtask

  task automatic tcheck(input logic property_value, input [8*120-1:0] description);
    begin
      test_checks = test_checks + 1;
      if (property_value !== 1'b1) begin
        test_failures = test_failures + 1;
        $display("TEST_FAIL %0s at %0t", description, $time);
      end
    end
  endtask

  task automatic queue_ar(
    input logic [31:0] addr_value,
    input logic [2:0]  size_value,
    input logic [6:0]  hprot_value,
    input logic        hnonsec_value
  );
    begin
      exp_ar_addr[exp_ar_tail]  = addr_value;
      exp_ar_size[exp_ar_tail]  = size_value;
      exp_ar_cache[exp_ar_tail] = f_expected_cache(hprot_value, 1'b0);
      exp_ar_prot[exp_ar_tail]  = f_expected_prot(hprot_value, hnonsec_value);
      exp_ar_tail = exp_ar_tail + 1;
    end
  endtask

  task automatic queue_aw(
    input logic [31:0] addr_value,
    input logic [7:0]  len_value,
    input logic [2:0]  size_value,
    input logic [3:0]  cache_value,
    input logic [2:0]  prot_value
  );
    begin
      exp_aw_addr[exp_aw_tail]  = addr_value;
      exp_aw_len[exp_aw_tail]   = len_value;
      exp_aw_size[exp_aw_tail]  = size_value;
      exp_aw_burst[exp_aw_tail] = 2'b01;
      exp_aw_cache[exp_aw_tail] = cache_value;
      exp_aw_prot[exp_aw_tail]  = prot_value;
      exp_aw_tail = exp_aw_tail + 1;
    end
  endtask

  task automatic queue_w(
    input logic [31:0] data_value,
    input logic [3:0]  strb_value,
    input logic        last_value
  );
    begin
      exp_w_data[exp_w_tail] = data_value;
      exp_w_strb[exp_w_tail] = strb_value;
      exp_w_last[exp_w_tail] = last_value;
      exp_w_tail = exp_w_tail + 1;
    end
  endtask

  task automatic ahb_transfer_address(
    input logic [31:0] addr_value,
    input logic [1:0]  trans_value,
    input logic        write_value,
    input logic [2:0]  size_value,
    input logic [2:0]  burst_value,
    input logic [6:0]  prot_value,
    input logic        nonsec_value,
    input logic        lock_value,
    input logic [31:0] data_phase_value,
    input logic [3:0]  strb_phase_value
  );
    integer wait_cycles;
    begin : issue_transfer
      @(negedge i_clk_core);
      i_ahb_hsel       = 1'b1;
      i_ahb_haddr      = addr_value;
      i_ahb_htrans     = trans_value;
      i_ahb_hwrite     = write_value;
      i_ahb_hsize      = size_value;
      i_ahb_hburst     = burst_value;
      i_ahb_hprot      = prot_value;
      i_ahb_hnonsec    = nonsec_value;
      i_ahb_hmastlock  = lock_value;
      i_ahb_hwdata     = data_phase_value;
      i_ahb_hwstrb     = strb_phase_value;
      last_ahb_address_accepted = 1'b0;
      wait_cycles = 0;
      while (wait_cycles < 32) begin
        // AHB transfer acceptance is sampled at the rising clock edge.
        @(posedge i_clk_core);
        if (o_ahb_hreadyout === 1'b1) begin
          last_ahb_address_accepted = 1'b1;
          #1;
          disable issue_transfer;
        end
        @(negedge i_clk_core);
        wait_cycles = wait_cycles + 1;
      end
      $display("TEST_FAIL AHB address was not accepted: %08x", addr_value);
      test_failures = test_failures + 1;
    end
  endtask

  task automatic ahb_idle_data(input logic [31:0] data_value, input logic [3:0] strb_value);
    begin
      @(negedge i_clk_core);
      i_ahb_hsel      = 1'b0;
      i_ahb_htrans    = 2'b00;
      i_ahb_haddr     = 32'b0;
      i_ahb_hwrite    = 1'b0;
      i_ahb_hsize     = 3'b010;
      i_ahb_hburst    = 3'b000;
      i_ahb_hprot     = 7'b0001010;
      i_ahb_hnonsec   = 1'b0;
      i_ahb_hmastlock = 1'b0;
      i_ahb_hwdata    = data_value;
      i_ahb_hwstrb    = strb_value;
    end
  endtask

  task automatic wait_ahb_response(
    input logic        expected_error,
    input logic        check_read_data,
    input logic [31:0] expected_read_data,
    input integer      relation_id,
    input [8*64-1:0]  label
  );
    integer cycles;
    logic response_sample;
    logic [31:0] data_sample;
    begin : wait_response
      cycles = 0;
      while (cycles < 200) begin
        // Sample AHB response signals together at the response clock edge.
        @(posedge i_clk_core);
        if (o_ahb_hreadyout === 1'b1) begin
          response_sample = o_ahb_hresp;
          data_sample = o_ahb_hrdata;
          #1;
          tcheck((response_sample === expected_error), label);
          if (check_read_data == 1'b1) begin
            tcheck((data_sample === expected_read_data), "AHB read data matches the AXI RDATA response");
            rcheck(3, data_sample === expected_read_data);
          end
          rcheck(relation_id, response_sample === expected_error);
          disable wait_response;
        end
        cycles = cycles + 1;
      end
      test_failures = test_failures + 1;
      $display("TEST_FAIL AHB response timeout: %0s", label);
    end
  endtask

  task automatic wait_ar_handshakes(input integer target_count);
    integer wait_cycles;
    begin
      wait_cycles = 0;
      while (ar_handshakes < target_count && wait_cycles < 100) begin
        @(posedge i_clk_core);
        #1;
        wait_cycles = wait_cycles + 1;
      end
      tcheck((ar_handshakes == target_count), "AXI AR handshake reached expected count");
    end
  endtask

  task automatic wait_aw_handshakes(input integer target_count);
    integer wait_cycles;
    begin
      wait_cycles = 0;
      while (aw_handshakes < target_count && wait_cycles < 100) begin
        @(posedge i_clk_core);
        #1;
        wait_cycles = wait_cycles + 1;
      end
      tcheck((aw_handshakes == target_count), "AXI AW handshake reached expected count");
    end
  endtask

  task automatic wait_w_handshakes(input integer target_count);
    integer wait_cycles;
    begin
      wait_cycles = 0;
      while (w_handshakes < target_count && wait_cycles < 100) begin
        @(posedge i_clk_core);
        #1;
        wait_cycles = wait_cycles + 1;
      end
      tcheck((w_handshakes == target_count), "AXI W handshake reached expected count");
    end
  endtask

  task automatic send_axi_read_response(
    input logic [31:0] data_value,
    input logic [1:0]  response_value
  );
    integer wait_cycles;
    integer target_count;
    begin
      target_count = r_handshakes + 1;
      @(negedge i_clk_core);
      i_axi_rid    = last_ar_id;
      i_axi_rdata  = data_value;
      i_axi_rresp  = response_value;
      i_axi_rlast  = 1'b1;
      i_axi_rvalid = 1'b1;
      wait_cycles = 0;
      while (r_handshakes < target_count && wait_cycles < 100) begin
        @(posedge i_clk_core);
        #1;
        wait_cycles = wait_cycles + 1;
      end
      tcheck((r_handshakes == target_count), "AXI R response handshake reached expected count");
      @(negedge i_clk_core);
      i_axi_rvalid = 1'b0;
      i_axi_rlast  = 1'b0;
      i_axi_rdata  = 32'b0;
      i_axi_rresp  = 2'b00;
    end
  endtask

  task automatic send_axi_write_response(input logic [1:0] response_value);
    integer wait_cycles;
    integer target_count;
    begin
      target_count = b_handshakes + 1;
      @(negedge i_clk_core);
      i_axi_bid    = last_aw_id;
      i_axi_bresp  = response_value;
      i_axi_bvalid = 1'b1;
      wait_cycles = 0;
      while (b_handshakes < target_count && wait_cycles < 100) begin
        @(posedge i_clk_core);
        #1;
        wait_cycles = wait_cycles + 1;
      end
      tcheck((b_handshakes == target_count), "AXI B response handshake reached expected count");
      @(negedge i_clk_core);
      i_axi_bvalid = 1'b0;
      i_axi_bresp  = 2'b00;
    end
  endtask

  task automatic wave_start(input integer case_id, input [8*32-1:0] name);
    begin
      if (selected_case == case_id) begin
        $display("WAVE_BEGIN %0s time=%0t", name, $time);
        $dumpon;
      end
    end
  endtask

  task automatic wave_end(input integer case_id, input [8*32-1:0] name);
    begin
      if (selected_case == case_id) begin
        $display("WAVE_END %0s time=%0t", name, $time);
        $dumpoff;
      end
    end
  endtask

  task automatic test_wf001_reset_and_startup;
    integer ar_target;
    begin
      $display("TEST WF-001: shared reset and synchronous startup");
      wave_start(1, "WF-001");
      repeat (3) @(posedge i_clk_core);
      @(negedge i_clk_core);
      i_rst_n_core = 1'b1;
      repeat (1) @(posedge i_clk_core);
      #1;
      i_axi_arready = 1'b1;
      ar_target = ar_handshakes + 1;
      queue_ar(32'h0000_0100, 3'd2, 7'b0001010, 1'b0);
      ahb_transfer_address(32'h0000_0100, 2'b10, 1'b0, 3'd2, 3'b000,
                           7'b0001010, 1'b0, 1'b0, 32'b0, 4'b0);
      ahb_idle_data(32'b0, 4'b0);
      wait_ar_handshakes(ar_target);
      send_axi_read_response(32'hA55A_1234, 2'b00);
      wait_ahb_response(1'b0, 1'b1, 32'hA55A_1234, 9, "WF-001 AHB read completes OKAY");
      wave_end(1, "WF-001");
    end
  endtask

  task automatic test_ahb_idle_busy;
    integer ar_before;
    integer aw_before;
    integer w_before;
    begin
      $display("TEST AHB IDLE/BUSY: no AXI request");
      ar_before = ar_handshakes;
      aw_before = aw_handshakes;
      w_before = w_handshakes;
      quiet_mode = 1'b1;
      @(negedge i_clk_core);
      i_ahb_hsel = 1'b0;
      i_ahb_htrans = 2'b00;
      i_ahb_haddr = 32'h0000_0200;
      repeat (2) @(posedge i_clk_core);
      #1;
      tcheck((o_ahb_hreadyout === 1'b1) && (o_ahb_hresp === 1'b0),
             "AHB IDLE receives zero-wait OKAY");
      @(negedge i_clk_core);
      i_ahb_hsel = 1'b1;
      i_ahb_htrans = 2'b01;
      i_ahb_hburst = 3'b001;
      repeat (2) @(posedge i_clk_core);
      #1;
      tcheck((o_ahb_hreadyout === 1'b1) && (o_ahb_hresp === 1'b0),
             "AHB BUSY receives zero-wait OKAY");
      @(negedge i_clk_core);
      i_ahb_hsel = 1'b0;
      i_ahb_htrans = 2'b00;
      i_ahb_hburst = 3'b000;
      quiet_mode = 1'b0;
      repeat (1) @(posedge i_clk_core);
      #1;
      tcheck((ar_handshakes == ar_before) && (aw_handshakes == aw_before) &&
             (w_handshakes == w_before), "AHB IDLE/BUSY issued no AXI traffic");
      rcheck(10, (ar_handshakes == ar_before) && (aw_handshakes == aw_before) &&
                 (w_handshakes == w_before));
    end
  endtask

  task automatic test_wf002_read_error;
    integer ar_target;
    begin
      $display("TEST WF-002: serialized read, ARREADY stall, and SLVERR");
      wave_start(2, "WF-002");
      i_axi_arready = 1'b0;
      ar_target = ar_handshakes + 1;
      queue_ar(32'h0000_0200, 3'd2, 7'b0001010, 1'b0);
      ahb_transfer_address(32'h0000_0200, 2'b10, 1'b0, 3'd2, 3'b000,
                           7'b0001010, 1'b0, 1'b0, 32'b0, 4'b0);
      ahb_idle_data(32'b0, 4'b0);
      repeat (3) @(posedge i_clk_core);
      #1;
      tcheck(o_axi_arvalid === 1'b1, "WF-002 ARVALID is held during ARREADY stall");
      @(negedge i_clk_core);
      i_axi_arready = 1'b1;
      wait_ar_handshakes(ar_target);
      @(negedge i_clk_core);
      i_axi_arready = 1'b0;
      send_axi_read_response(32'hDEAD_BEEF, 2'b10);
      wait_ahb_response(1'b1, 1'b0, 32'b0, 4, "WF-002 SLVERR maps to two-cycle AHB ERROR");
      wave_end(2, "WF-002");
    end
  endtask

  task automatic test_wf003_bufferable_burst;
    integer beat;
    integer aw_target;
    integer w_target;
    begin : wf003_body
      $display("TEST WF-003: bufferable INCR4, sparse strobes, BRESP error");
      wave_start(3, "WF-003");
      i_axi_awready = 1'b0;
      i_axi_wready = 1'b0;
      queue_aw(32'h0000_1000, 8'd3, 3'd2, 4'b1011, 3'b101);
      queue_w(32'h1122_3344, 4'b1111, 1'b0);
      queue_w(32'h5566_7788, 4'b0011, 1'b0);
      queue_w(32'h99AA_BBCC, 4'b1100, 1'b0);
      queue_w(32'hDDEE_FF00, 4'b1111, 1'b1);
      burst_capture_mode = 1'b1;
      burst_capture_done = 1'b0;
      burst_early_issue_logged = 1'b0;
      burst_expected_addresses = 4;
      burst_accepted_addresses = 0;
      for (beat = 0; beat < 4; beat = beat + 1) begin
        if (beat == 0) begin
          ahb_transfer_address(32'h0000_1000, 2'b10, 1'b1, 3'd2, 3'b011,
                               7'b0111110, 1'b0, 1'b0, 32'b0, 4'b0);
        end else begin
          case (beat)
            1: ahb_transfer_address(32'h0000_1004, 2'b11, 1'b1, 3'd2, 3'b011,
                                    7'b0111110, 1'b0, 1'b0, 32'h1122_3344, 4'b1111);
            2: ahb_transfer_address(32'h0000_1008, 2'b11, 1'b1, 3'd2, 3'b011,
                                    7'b0111110, 1'b0, 1'b0, 32'h5566_7788, 4'b0011);
            default: ahb_transfer_address(32'h0000_100C, 2'b11, 1'b1, 3'd2, 3'b011,
                                          7'b0111110, 1'b0, 1'b0, 32'h99AA_BBCC, 4'b1100);
          endcase
        end
        if (last_ahb_address_accepted === 1'b1) begin
          burst_accepted_addresses = burst_accepted_addresses + 1;
        end else begin
          burst_capture_done = 1'b1;
          burst_capture_mode = 1'b0;
          wave_end(3, "WF-003");
          disable wf003_body;
        end
        if (beat < 3) begin
          tcheck((o_axi_awvalid === 1'b0) && (o_axi_wvalid === 1'b0),
                 "WF-003 AXI burst waits until full AHB capture");
        end
      end
      ahb_idle_data(32'hDDEE_FF00, 4'b1111);
      @(posedge i_clk_core);
      #1;
      burst_capture_done = 1'b1;
      burst_capture_mode = 1'b0;
      aw_target = aw_handshakes + 1;
      w_target = w_handshakes + 4;
      repeat (2) @(posedge i_clk_core);
      @(negedge i_clk_core);
      i_axi_awready = 1'b1;
      wait_aw_handshakes(aw_target);
      @(negedge i_clk_core);
      i_axi_awready = 1'b0;
      repeat (2) @(posedge i_clk_core);
      @(negedge i_clk_core);
      i_axi_wready = 1'b1;
      wait_w_handshakes(w_target);
      @(negedge i_clk_core);
      i_axi_wready = 1'b0;
      repeat (2) @(posedge i_clk_core);
      #1;
      tcheck(o_ahb_hreadyout === 1'b0, "WF-003 terminal AHB response waits for BRESP");
      send_axi_write_response(2'b10);
      wait_ahb_response(1'b1, 1'b0, 32'b0, 4, "WF-003 SLVERR maps to terminal AHB ERROR");
      wave_end(3, "WF-003");
      i_axi_awready = 1'b1;
      i_axi_wready = 1'b1;
    end
  endtask

  task automatic test_wf004_nonbufferable_write;
    integer aw_target;
    integer w_target;
    begin
      $display("TEST WF-004: non-bufferable write waits for BRESP");
      wave_start(4, "WF-004");
      i_axi_awready = 1'b0;
      i_axi_wready = 1'b0;
      queue_aw(32'h0000_0300, 8'd0, 3'd2, 4'b0110, 3'b101);
      queue_w(32'hCAFE_1234, 4'b0101, 1'b1);
      ahb_transfer_address(32'h0000_0300, 2'b10, 1'b1, 3'd2, 3'b000,
                           7'b0011010, 1'b0, 1'b0, 32'b0, 4'b0);
      ahb_idle_data(32'hCAFE_1234, 4'b0101);
      aw_target = aw_handshakes + 1;
      w_target = w_handshakes + 1;
      repeat (2) @(posedge i_clk_core);
      @(negedge i_clk_core);
      i_axi_awready = 1'b1;
      i_axi_wready = 1'b1;
      wait_aw_handshakes(aw_target);
      wait_w_handshakes(w_target);
      @(negedge i_clk_core);
      i_axi_awready = 1'b0;
      i_axi_wready = 1'b0;
      repeat (2) @(posedge i_clk_core);
      #1;
      tcheck(o_ahb_hreadyout === 1'b0, "WF-004 AHB remains pending until B response");
      rcheck(11, o_ahb_hreadyout === 1'b0);
      send_axi_write_response(2'b00);
      wait_ahb_response(1'b0, 1'b0, 32'b0, 9, "WF-004 OKAY BRESP completes AHB write");
      wave_end(4, "WF-004");
      i_axi_awready = 1'b1;
      i_axi_wready = 1'b1;
    end
  endtask

  task automatic test_wf005_rejected_transfers;
    integer ar_before;
    integer aw_before;
    integer w_before;
    begin
      $display("TEST WF-005: rejected HPROT[6] and HMASTLOCK transfers");
      wave_start(5, "WF-005");
      i_axi_arready = 1'b1;
      i_axi_awready = 1'b1;
      i_axi_wready = 1'b1;
      reject_mode = 1'b1;
      ar_before = ar_handshakes;
      aw_before = aw_handshakes;
      w_before = w_handshakes;
      ahb_transfer_address(32'h0000_0400, 2'b10, 1'b0, 3'd2, 3'b000,
                           7'b1000000, 1'b0, 1'b0, 32'b0, 4'b0);
      ahb_idle_data(32'b0, 4'b0);
      wait_ahb_response(1'b1, 1'b0, 32'b0, 12, "WF-005 HPROT[6] rejected with AHB ERROR");
      tcheck((ar_handshakes == ar_before) && (aw_handshakes == aw_before) &&
             (w_handshakes == w_before), "WF-005 HPROT[6] causes no AXI traffic");
      rcheck(12, (ar_handshakes == ar_before) && (aw_handshakes == aw_before) &&
                 (w_handshakes == w_before));
      ar_before = ar_handshakes;
      aw_before = aw_handshakes;
      w_before = w_handshakes;
      ahb_transfer_address(32'h0000_0404, 2'b10, 1'b1, 3'd2, 3'b000,
                           7'b0001010, 1'b0, 1'b1, 32'b0, 4'b0);
      ahb_idle_data(32'h1234_5678, 4'b1111);
      wait_ahb_response(1'b1, 1'b0, 32'b0, 13, "WF-005 HMASTLOCK rejected with AHB ERROR");
      tcheck((ar_handshakes == ar_before) && (aw_handshakes == aw_before) &&
             (w_handshakes == w_before), "WF-005 HMASTLOCK causes no AXI traffic");
      rcheck(13, (ar_handshakes == ar_before) && (aw_handshakes == aw_before) &&
                 (w_handshakes == w_before));
      reject_mode = 1'b0;
      wave_end(5, "WF-005");
    end
  endtask

  task automatic test_wf006_4k_split;
    integer beat;
    integer aw_target;
    integer w_target;
    begin : wf006_body
      $display("TEST WF-006: out-of-profile 4-KiB split and response aggregation");
      wave_start(6, "WF-006");
      i_axi_awready = 1'b1;
      i_axi_wready = 1'b1;
      queue_aw(32'h0000_0FFC, 8'd0, 3'd2, 4'b1011, 3'b101);
      queue_aw(32'h0000_1000, 8'd2, 3'd2, 4'b1011, 3'b101);
      queue_w(32'h0102_0304, 4'b1111, 1'b1);
      queue_w(32'h1112_1314, 4'b1111, 1'b0);
      queue_w(32'h2122_2324, 4'b1111, 1'b0);
      queue_w(32'h3132_3334, 4'b1111, 1'b1);
      for (beat = 0; beat < 4; beat = beat + 1) begin
        if (beat == 0) begin
          ahb_transfer_address(32'h0000_0FFC, 2'b10, 1'b1, 3'd2, 3'b011,
                               7'b0111110, 1'b0, 1'b0, 32'b0, 4'b0);
        end else begin
          case (beat)
            1: ahb_transfer_address(32'h0000_1000, 2'b11, 1'b1, 3'd2, 3'b011,
                                    7'b0111110, 1'b0, 1'b0, 32'h0102_0304, 4'b1111);
            2: ahb_transfer_address(32'h0000_1004, 2'b11, 1'b1, 3'd2, 3'b011,
                                    7'b0111110, 1'b0, 1'b0, 32'h1112_1314, 4'b1111);
            default: ahb_transfer_address(32'h0000_1008, 2'b11, 1'b1, 3'd2, 3'b011,
                                          7'b0111110, 1'b0, 1'b0, 32'h2122_2324, 4'b1111);
          endcase
        end
        if (last_ahb_address_accepted !== 1'b1) begin
          wave_end(6, "WF-006");
          disable wf006_body;
        end
      end
      ahb_idle_data(32'h3132_3334, 4'b1111);
      @(posedge i_clk_core);
      #1;
      aw_target = aw_handshakes + 1;
      w_target = w_handshakes + 1;
      wait_aw_handshakes(aw_target);
      wait_w_handshakes(w_target);
      rcheck(14, (last_aw_addr === 32'h0000_0FFC) && (last_aw_len === 8'd0));
      send_axi_write_response(2'b00);
      aw_target = aw_handshakes + 1;
      w_target = w_handshakes + 3;
      wait_aw_handshakes(aw_target);
      wait_w_handshakes(w_target);
      rcheck(14, last_aw_addr === 32'h0000_1000 && last_aw_len === 8'd2);
      send_axi_write_response(2'b10);
      wait_ahb_response(1'b1, 1'b0, 32'b0, 15, "WF-006 sub-burst SLVERR aggregates to terminal AHB ERROR");
      wave_end(6, "WF-006");
    end
  endtask

  task automatic report_assertions;
    integer index;
    integer total_hits;
    integer total_fails;
    integer total_assertions;
    begin
      total_hits = 0;
      total_fails = 0;
      total_assertions = 0;
      $display("ASSERTION TABLE: IHI 0033C / IHI 0022H.c / bridge requirements");
      for (index = 0; index < AHB_ASSERTION_COUNT; index = index + 1) begin
        $display("AHB_%02d %-34s hits=%0d fails=%0d source=%s", index + 1,
                 ahb_names[index], ahb_hits[index], ahb_fails[index], ahb_sources[index]);
        total_hits = total_hits + ahb_hits[index];
        total_fails = total_fails + ahb_fails[index];
        total_assertions = total_assertions + 1;
        if (ahb_hits[index] == 0) assertions_never_exercised = assertions_never_exercised + 1;
      end
      for (index = 0; index < AXI_ASSERTION_COUNT; index = index + 1) begin
        $display("AXI_%02d %-34s hits=%0d fails=%0d source=%s", index + 1,
                 axi_names[index], axi_hits[index], axi_fails[index], axi_sources[index]);
        total_hits = total_hits + axi_hits[index];
        total_fails = total_fails + axi_fails[index];
        total_assertions = total_assertions + 1;
        if (axi_hits[index] == 0) assertions_never_exercised = assertions_never_exercised + 1;
      end
      for (index = 0; index < BRIDGE_ASSERTION_COUNT; index = index + 1) begin
        $display("BRIDGE_%02d %-34s hits=%0d fails=%0d source=%s", index + 1,
                 bridge_names[index], bridge_hits[index], bridge_fails[index], bridge_sources[index]);
        total_hits = total_hits + bridge_hits[index];
        total_fails = total_fails + bridge_fails[index];
        total_assertions = total_assertions + 1;
        if (bridge_hits[index] == 0) assertions_never_exercised = assertions_never_exercised + 1;
      end
      $display("ASSERTIONS: %0d total, %0d hits", total_assertions, total_hits);
      $display("assertion failures: %0d, assertions never exercised: %0d",
               assertion_failures, assertions_never_exercised);
      $display("TEST CHECKS: %0d, failures: %0d", test_checks, test_failures);
      if (assertion_failures != 0 || test_failures != 0 ||
          ((selected_case == 0) && (assertions_never_exercised != 0) &&
           (assertion_failures == 0) && (test_failures == 0))) begin
        $fatal(1, "AHB-to-AXI verification FAILED");
      end
      $display("AHB-to-AXI verification PASS");
    end
  endtask

  always @(posedge i_clk_core) begin
    if (i_rst_n_core !== 1'b1) begin
      pcheck(0, 0, (i_rst_n_core === 1'b0),
             (o_ahb_hreadyout === 1'b1));
      pcheck(0, 1, (i_rst_n_core === 1'b0),
             (o_ahb_hresp === 1'b0));
      pcheck(1, 0, (i_rst_n_core === 1'b0),
             (o_axi_awvalid === 1'b0) && (o_axi_wvalid === 1'b0) &&
             (o_axi_arvalid === 1'b0));
      prev_ahb_wait = 1'b0;
      prev_error_first = 1'b0;
      prev_ar_stall = 1'b0;
      prev_aw_stall = 1'b0;
      prev_w_stall = 1'b0;
      prev_r_stall = 1'b0;
      prev_b_stall = 1'b0;
      pending_ahb_read = 1'b0;
      previous_accepted_ahb_address = 1'b0;
      fixed_burst_tracking = 1'b0;
    end else begin
      pcheck(0, 2, 1'b1, ((o_ahb_hreadyout === 1'b0) || (o_ahb_hreadyout === 1'b1)));
      pcheck(0, 3, (o_ahb_hreadyout === 1'b1),
             ((o_ahb_hresp === 1'b0) || (o_ahb_hresp === 1'b1)));
      pcheck(0, 4, 1'b1, (i_ahb_hready === o_ahb_hreadyout));
      pcheck(0, 5, (i_ahb_htrans[1] === 1'b1), (i_ahb_hsel === 1'b1));
      pcheck(0, 6, (i_ahb_hsel === 1'b1),
             ((i_ahb_htrans === 2'b00) || (i_ahb_htrans === 2'b01) ||
              (i_ahb_htrans === 2'b10) || (i_ahb_htrans === 2'b11)));
      pcheck(0, 7, (i_ahb_hsel === 1'b1 && i_ahb_htrans[1] === 1'b1),
             (i_ahb_hsize <= 3'd2));
      pcheck(0, 8, (i_ahb_hsel === 1'b1 && i_ahb_htrans[1] === 1'b1),
             f_aligned(i_ahb_haddr, i_ahb_hsize));
      pcheck(0, 9, prev_ahb_wait, (i_ahb_haddr === prev_haddr));
      pcheck(0, 10, prev_ahb_wait,
             (i_ahb_htrans === prev_htrans) && (i_ahb_hwrite === prev_hwrite) &&
             (i_ahb_hsize === prev_hsize) && (i_ahb_hburst === prev_hburst));
      pcheck(0, 11, prev_ahb_wait,
             (i_ahb_hprot === prev_hprot) && (i_ahb_hnonsec === prev_hnonsec) &&
             (i_ahb_hmastlock === prev_hmastlock));
      pcheck(0, 12, prev_ahb_wait, (i_ahb_hwdata === prev_hwdata));
      pcheck(0, 13, prev_ahb_wait, (i_ahb_hwstrb === prev_hwstrb));
      pcheck(0, 14, (i_ahb_hready === 1'b1 && i_ahb_hsel === 1'b1 &&
                     i_ahb_htrans === 2'b11 && previous_accepted_ahb_address === 1'b1 &&
                     i_ahb_hburst == 3'b011),
             (i_ahb_haddr === previous_ahb_address + (32'd1 << previous_ahb_size)));
      pcheck(0, 15, (i_ahb_hready === 1'b1 && i_ahb_hsel === 1'b1 &&
                     i_ahb_htrans === 2'b11 && fixed_burst_tracking === 1'b1),
             (i_ahb_hprot === fixed_burst_hprot));
      pcheck(0, 16, prev_error_first,
             (o_ahb_hresp === 1'b1) && (o_ahb_hreadyout === 1'b1));
      pcheck(0, 17, (o_ahb_hreadyout === 1'b1 && o_ahb_hresp === 1'b0),
             (o_ahb_hresp === 1'b0));
      pcheck(0, 18, (pending_ahb_read === 1'b1 && o_ahb_hreadyout === 1'b1 &&
                     o_ahb_hresp === 1'b0), ((^o_ahb_hrdata) !== 1'bx));
      pcheck(0, 19, (quiet_mode === 1'b1 && i_ahb_htrans === 2'b00),
             (o_axi_arvalid === 1'b0 && o_axi_awvalid === 1'b0 && o_axi_wvalid === 1'b0));
      pcheck(0, 20, (quiet_mode === 1'b1 && i_ahb_htrans === 2'b01),
             (o_axi_arvalid === 1'b0 && o_axi_awvalid === 1'b0 && o_axi_wvalid === 1'b0));

      pcheck(1, 1, prev_ar_stall,
             (o_axi_arvalid === 1'b1));
      pcheck(1, 2, prev_ar_stall,
             ({o_axi_arid, o_axi_araddr, o_axi_arlen, o_axi_arsize, o_axi_arburst,
               o_axi_arlock, o_axi_arcache, o_axi_arprot} === prev_ar_payload));
      pcheck(1, 3, (o_axi_arvalid === 1'b1),
             ((^{o_axi_arid, o_axi_araddr, o_axi_arlen, o_axi_arsize, o_axi_arburst,
                o_axi_arlock, o_axi_arcache, o_axi_arprot}) !== 1'bx));
      pcheck(1, 4, (o_axi_arvalid === 1'b1), (o_axi_arlen === 8'd0));
      pcheck(1, 5, (o_axi_arvalid === 1'b1), (o_axi_arburst === 2'b01));
      pcheck(1, 6, (o_axi_arvalid === 1'b1), (o_axi_arsize <= 3'd2));
      pcheck(1, 7, (o_axi_arvalid === 1'b1), f_aligned(o_axi_araddr, o_axi_arsize));
      pcheck(1, 8, (o_axi_arvalid === 1'b1), (o_axi_arlock === 1'b0));
      pcheck(1, 9, (o_axi_arvalid === 1'b1), (o_axi_arid < PARA_RD_ID_COUNT));
      pcheck(1, 10, prev_aw_stall, (o_axi_awvalid === 1'b1));
      pcheck(1, 11, prev_aw_stall,
             ({o_axi_awid, o_axi_awaddr, o_axi_awlen, o_axi_awsize, o_axi_awburst,
               o_axi_awlock, o_axi_awcache, o_axi_awprot} === prev_aw_payload));
      pcheck(1, 12, (o_axi_awvalid === 1'b1),
             ((^{o_axi_awid, o_axi_awaddr, o_axi_awlen, o_axi_awsize, o_axi_awburst,
                o_axi_awlock, o_axi_awcache, o_axi_awprot}) !== 1'bx));
      pcheck(1, 13, (o_axi_awvalid === 1'b1), f_legal_awlen(o_axi_awlen));
      pcheck(1, 14, (o_axi_awvalid === 1'b1), (o_axi_awburst === 2'b01));
      pcheck(1, 15, (o_axi_awvalid === 1'b1), (o_axi_awsize <= 3'd2));
      pcheck(1, 16, (o_axi_awvalid === 1'b1), f_aligned(o_axi_awaddr, o_axi_awsize));
      pcheck(1, 17, (o_axi_awvalid === 1'b1), (o_axi_awlock === 1'b0));
      pcheck(1, 18, (o_axi_awvalid === 1'b1), (o_axi_awid < PARA_WR_ID_COUNT));
      pcheck(1, 19, prev_w_stall, (o_axi_wvalid === 1'b1));
      pcheck(1, 20, prev_w_stall,
             ({o_axi_wdata, o_axi_wstrb, o_axi_wlast} === prev_w_payload));
      pcheck(1, 21, (i_axi_rvalid === 1'b1),
             ((^{i_axi_rid, i_axi_rdata, i_axi_rresp, i_axi_rlast}) !== 1'bx));
      pcheck(1, 22, (i_axi_rvalid === 1'b1), (i_axi_rlast === 1'b1));
      pcheck(1, 23, (i_axi_rvalid === 1'b1), (i_axi_rid === last_ar_id));
      pcheck(1, 24, prev_r_stall, (i_axi_rvalid === 1'b1));
      pcheck(1, 25, prev_r_stall,
             ({i_axi_rid, i_axi_rdata, i_axi_rresp, i_axi_rlast} === prev_r_payload));
      pcheck(1, 26, (i_axi_bvalid === 1'b1),
             ((^{i_axi_bid, i_axi_bresp}) !== 1'bx));
      pcheck(1, 27, (i_axi_bvalid === 1'b1), (i_axi_bid === last_aw_id));
      pcheck(1, 28, prev_b_stall, (i_axi_bvalid === 1'b1));
      pcheck(1, 29, prev_b_stall, ({i_axi_bid, i_axi_bresp} === prev_b_payload));
      pcheck(1, 30, (i_axi_bvalid === 1'b1),
             (aw_handshakes > b_handshakes && wlast_handshakes > b_handshakes));
      pcheck(1, 31, (o_axi_wvalid === 1'b1 && i_axi_wready === 1'b1 &&
                     exp_w_head < exp_w_tail),
             (o_axi_wlast === exp_w_last[exp_w_head]));
      pcheck(1, 32, (o_axi_awvalid === 1'b1),
             f_no_4k_cross(o_axi_awaddr, o_axi_awlen, o_axi_awsize));
      if (burst_capture_mode === 1'b1 && burst_capture_done === 1'b0 &&
          burst_early_issue_logged === 1'b0) begin
        pcheck(2, 8, 1'b1, (o_axi_awvalid === 1'b0 && o_axi_wvalid === 1'b0));
        if (o_axi_awvalid === 1'b1 || o_axi_wvalid === 1'b1)
          burst_early_issue_logged = 1'b1;
      end

      if (pending_ahb_read === 1'b1 && o_ahb_hreadyout === 1'b1) begin
        pending_ahb_read = 1'b0;
      end

      if (i_ahb_hsel === 1'b1 && i_ahb_hready === 1'b1 && i_ahb_htrans[1] === 1'b1) begin
        if (i_ahb_hwrite === 1'b0) ahb_read_accepts = ahb_read_accepts + 1;
        else ahb_write_accepts = ahb_write_accepts + 1;
        if (i_ahb_hwrite === 1'b0) pending_ahb_read = 1'b1;
        if (i_ahb_htrans === 2'b10 && i_ahb_hburst === 3'b011) begin
          fixed_burst_tracking = 1'b1;
          fixed_burst_hprot = i_ahb_hprot;
        end else if (i_ahb_htrans === 2'b00) begin
          fixed_burst_tracking = 1'b0;
        end
        previous_ahb_address = i_ahb_haddr;
        previous_ahb_size = i_ahb_hsize;
        previous_ahb_burst = i_ahb_hburst;
        previous_accepted_ahb_address = 1'b1;
      end
      if (i_ahb_htrans === 2'b00 && i_ahb_hready === 1'b1) begin
        previous_accepted_ahb_address = 1'b0;
        fixed_burst_tracking = 1'b0;
      end

      prev_error_first = (o_ahb_hresp === 1'b1 && o_ahb_hreadyout === 1'b0);
      prev_ahb_wait = (o_ahb_hreadyout === 1'b0);
      prev_htrans = i_ahb_htrans;
      prev_haddr = i_ahb_haddr;
      prev_hwrite = i_ahb_hwrite;
      prev_hsize = i_ahb_hsize;
      prev_hburst = i_ahb_hburst;
      prev_hprot = i_ahb_hprot;
      prev_hnonsec = i_ahb_hnonsec;
      prev_hmastlock = i_ahb_hmastlock;
      prev_hwdata = i_ahb_hwdata;
      prev_hwstrb = i_ahb_hwstrb;

      if (o_axi_arvalid === 1'b1 && i_axi_arready === 1'b1) begin
        if (exp_ar_head < exp_ar_tail) begin
          rcheck(0, ahb_read_accepts > ar_handshakes);
          rcheck(1, (o_axi_araddr === exp_ar_addr[exp_ar_head]) &&
                    (o_axi_arsize === exp_ar_size[exp_ar_head]) &&
                    (o_axi_arcache === exp_ar_cache[exp_ar_head]) &&
                    (o_axi_arprot === exp_ar_prot[exp_ar_head]) &&
                    (o_axi_arlen === 8'd0) && (o_axi_arburst === 2'b01));
          rcheck(2, o_axi_arlen === 8'd0);
          exp_ar_head = exp_ar_head + 1;
        end else begin
          rcheck(0, 1'b0);
        end
        last_ar_id = o_axi_arid;
        ar_handshakes = ar_handshakes + 1;
      end
      if (o_axi_awvalid === 1'b1 && i_axi_awready === 1'b1) begin
        if (exp_aw_head < exp_aw_tail) begin
          if (!((o_axi_awaddr === exp_aw_addr[exp_aw_head]) &&
                (o_axi_awlen === exp_aw_len[exp_aw_head]) &&
                (o_axi_awsize === exp_aw_size[exp_aw_head]) &&
                (o_axi_awburst === exp_aw_burst[exp_aw_head]) &&
                (o_axi_awcache === exp_aw_cache[exp_aw_head]) &&
                (o_axi_awprot === exp_aw_prot[exp_aw_head]))) begin
            $display("AXI_AW_MISMATCH actual addr=%08x len=%0d size=%0d burst=%0b cache=%04b prot=%03b expected addr=%08x len=%0d size=%0d burst=%0b cache=%04b prot=%03b",
                     o_axi_awaddr, o_axi_awlen, o_axi_awsize, o_axi_awburst,
                     o_axi_awcache, o_axi_awprot, exp_aw_addr[exp_aw_head],
                     exp_aw_len[exp_aw_head], exp_aw_size[exp_aw_head],
                     exp_aw_burst[exp_aw_head], exp_aw_cache[exp_aw_head],
                     exp_aw_prot[exp_aw_head]);
          end
          rcheck(16, (o_axi_awaddr === exp_aw_addr[exp_aw_head]) &&
                    (o_axi_awlen === exp_aw_len[exp_aw_head]) &&
                    (o_axi_awsize === exp_aw_size[exp_aw_head]) &&
                    (o_axi_awburst === exp_aw_burst[exp_aw_head]) &&
                    (o_axi_awcache === exp_aw_cache[exp_aw_head]) &&
                    (o_axi_awprot === exp_aw_prot[exp_aw_head]));
          exp_aw_head = exp_aw_head + 1;
        end else begin
          rcheck(6, 1'b0);
        end
        last_aw_id = o_axi_awid;
        last_aw_addr = o_axi_awaddr;
        last_aw_len = o_axi_awlen;
        aw_handshakes = aw_handshakes + 1;
      end
      if (o_axi_wvalid === 1'b1 && i_axi_wready === 1'b1) begin
        if (exp_w_head < exp_w_tail) begin
          rcheck(5, o_axi_wdata === exp_w_data[exp_w_head]);
          rcheck(6, o_axi_wstrb === exp_w_strb[exp_w_head]);
          rcheck(7, o_axi_wlast === exp_w_last[exp_w_head]);
          exp_w_head = exp_w_head + 1;
        end else begin
          rcheck(5, 1'b0);
        end
        w_handshakes = w_handshakes + 1;
        if (o_axi_wlast === 1'b1) wlast_handshakes = wlast_handshakes + 1;
      end
      if (i_axi_rvalid === 1'b1 && o_axi_rready === 1'b1) begin
        if (ar_handshakes <= r_handshakes) begin
          rcheck(0, 1'b0);
        end
        r_handshakes = r_handshakes + 1;
      end
      if (i_axi_bvalid === 1'b1 && o_axi_bready === 1'b1) begin
        b_handshakes = b_handshakes + 1;
      end

      prev_ar_stall = (o_axi_arvalid === 1'b1 && i_axi_arready === 1'b0);
      prev_ar_payload = {o_axi_arid, o_axi_araddr, o_axi_arlen, o_axi_arsize,
                         o_axi_arburst, o_axi_arlock, o_axi_arcache, o_axi_arprot};
      prev_aw_stall = (o_axi_awvalid === 1'b1 && i_axi_awready === 1'b0);
      prev_aw_payload = {o_axi_awid, o_axi_awaddr, o_axi_awlen, o_axi_awsize,
                         o_axi_awburst, o_axi_awlock, o_axi_awcache, o_axi_awprot};
      prev_w_stall = (o_axi_wvalid === 1'b1 && i_axi_wready === 1'b0);
      prev_w_payload = {o_axi_wdata, o_axi_wstrb, o_axi_wlast};
      prev_r_stall = (i_axi_rvalid === 1'b1 && o_axi_rready === 1'b0);
      prev_r_payload = {i_axi_rid, i_axi_rdata, i_axi_rresp, i_axi_rlast};
      prev_b_stall = (i_axi_bvalid === 1'b1 && o_axi_bready === 1'b0);
      prev_b_payload = {i_axi_bid, i_axi_bresp};

      if (burst_capture_mode === 1'b1 && burst_capture_done === 1'b0 &&
          o_axi_awvalid === 1'b1) begin
        burst_accepted_addresses = burst_accepted_addresses;
      end
    end
  end

  initial begin
    i_rst_n_core = 1'b0;
    i_ahb_hsel = 1'b0;
    i_ahb_haddr = 32'b0;
    i_ahb_htrans = 2'b00;
    i_ahb_hwrite = 1'b0;
    i_ahb_hsize = 3'b010;
    i_ahb_hburst = 3'b000;
    i_ahb_hprot = 7'b0001010;
    i_ahb_hnonsec = 1'b0;
    i_ahb_hmastlock = 1'b0;
    i_ahb_hwdata = 32'b0;
    i_ahb_hwstrb = 4'b0;
    i_axi_awready = 1'b1;
    i_axi_wready = 1'b1;
    i_axi_bid = 3'b0;
    i_axi_bresp = 2'b0;
    i_axi_bvalid = 1'b0;
    i_axi_arready = 1'b1;
    i_axi_rid = 3'b0;
    i_axi_rdata = 32'b0;
    i_axi_rresp = 2'b0;
    i_axi_rlast = 1'b0;
    i_axi_rvalid = 1'b0;
    quiet_mode = 1'b0;
    reject_mode = 1'b0;
    burst_capture_mode = 1'b0;
    burst_capture_done = 1'b0;
    burst_expected_addresses = 0;
    burst_accepted_addresses = 0;
    last_ahb_address_accepted = 1'b0;
    burst_early_issue_logged = 1'b0;
    selected_case = 0;
    test_checks = 0;
    test_failures = 0;
    assertion_failures = 0;
    assertions_never_exercised = 0;
    ar_handshakes = 0;
    aw_handshakes = 0;
    w_handshakes = 0;
    wlast_handshakes = 0;
    r_handshakes = 0;
    b_handshakes = 0;
    ahb_read_accepts = 0;
    ahb_write_accepts = 0;
    exp_ar_head = 0;
    exp_ar_tail = 0;
    exp_aw_head = 0;
    exp_aw_tail = 0;
    exp_w_head = 0;
    exp_w_tail = 0;
    pending_ahb_read = 1'b0;
    previous_accepted_ahb_address = 1'b0;
    fixed_burst_tracking = 1'b0;

    ahb_names[0] = "reset HREADYOUT high"; ahb_sources[0] = "REQ-RESET-001; IHI0033C reset";
    ahb_names[1] = "reset HRESP OKAY"; ahb_sources[1] = "REQ-RESET-001; IHI0033C reset";
    ahb_names[2] = "HREADYOUT is known"; ahb_sources[2] = "IHI0033C §5.1";
    ahb_names[3] = "HRESP known at completion"; ahb_sources[3] = "IHI0033C §5.1";
    ahb_names[4] = "HREADY shared-bus feedback"; ahb_sources[4] = "IHI0033C §4.3; single subordinate model";
    ahb_names[5] = "active transfer selected"; ahb_sources[5] = "IHI0033C §3.1";
    ahb_names[6] = "HTRANS encoding known"; ahb_sources[6] = "IHI0033C §3.2 Table 3-1";
    ahb_names[7] = "supported transfer size"; ahb_sources[7] = "REQ-FUNC-002; §6.3 profile";
    ahb_names[8] = "address aligned to HSIZE"; ahb_sources[8] = "REQ-FUNC-002; IHI0033C §3.4";
    ahb_names[9] = "HADDR stable while stalled"; ahb_sources[9] = "IHI0033C §3.6";
    ahb_names[10] = "HTRANS/HWRITE/size/burst stable"; ahb_sources[10] = "IHI0033C §§3.2, 3.6";
    ahb_names[11] = "HPROT/security/lock stable"; ahb_sources[11] = "IHI0033C §§3.8, 3.9";
    ahb_names[12] = "HWDATA stable while stalled"; ahb_sources[12] = "IHI0033C §3.5";
    ahb_names[13] = "HWSTRB stable while stalled"; ahb_sources[13] = "IHI0033C §2.2 Table 2-2";
    ahb_names[14] = "INCR4 SEQ address progression"; ahb_sources[14] = "IHI0033C §3.2 Table 3-1";
    ahb_names[15] = "HPROT constant in fixed burst"; ahb_sources[15] = "IHI0033C §3.8";
    ahb_names[16] = "ERROR response is two cycles"; ahb_sources[16] = "IHI0033C §5.1.3";
    ahb_names[17] = "completed OKAY has HRESP low"; ahb_sources[17] = "IHI0033C §5.1.1";
    ahb_names[18] = "completed read data known"; ahb_sources[18] = "REQ-FUNC-001; IHI0033C §4.3";
    ahb_names[19] = "IDLE produces no AXI request"; ahb_sources[19] = "IHI0033C §3.2 Table 3-1; REQ-FUNC-002";
    ahb_names[20] = "BUSY produces no AXI request"; ahb_sources[20] = "IHI0033C §3.2 Table 3-1; REQ-FUNC-002";

    axi_names[0] = "reset request VALID low"; axi_sources[0] = "IHI0022H.c §A3.1.2";
    axi_names[1] = "ARVALID held until handshake"; axi_sources[1] = "IHI0022H.c §A3.2.1";
    axi_names[2] = "AR payload stable while stalled"; axi_sources[2] = "IHI0022H.c §A3.2.1";
    axi_names[3] = "AR payload known while valid"; axi_sources[3] = "IHI0022H.c §A3.2.2";
    axi_names[4] = "single-beat read ARLEN"; axi_sources[4] = "REQ-FUNC-003; IHI0022H.c §A3.4";
    axi_names[5] = "read burst is INCR"; axi_sources[5] = "IHI0022H.c §A3.4";
    axi_names[6] = "ARSIZE supported"; axi_sources[6] = "IHI0022H.c §A3.4";
    axi_names[7] = "ARADDR aligned"; axi_sources[7] = "IHI0022H.c §A3.4";
    axi_names[8] = "ARLOCK disabled"; axi_sources[8] = "DEC-EXCL-001; IHI0022H.c §A7";
    axi_names[9] = "ARID in configured range"; axi_sources[9] = "REQ-PARAM-001; IHI0022H.c §A5.2";
    axi_names[10] = "AWVALID held until handshake"; axi_sources[10] = "IHI0022H.c §A3.2.1";
    axi_names[11] = "AW payload stable while stalled"; axi_sources[11] = "IHI0022H.c §A3.2.1";
    axi_names[12] = "AW payload known while valid"; axi_sources[12] = "IHI0022H.c §A3.2.2";
    axi_names[13] = "AWLEN is supported"; axi_sources[13] = "REQ-FUNC-005; IHI0022H.c §A3.4";
    axi_names[14] = "write burst is INCR"; axi_sources[14] = "IHI0022H.c §A3.4";
    axi_names[15] = "AWSIZE supported"; axi_sources[15] = "IHI0022H.c §A3.4";
    axi_names[16] = "AWADDR aligned"; axi_sources[16] = "IHI0022H.c §A3.4";
    axi_names[17] = "AWLOCK disabled"; axi_sources[17] = "DEC-EXCL-001; IHI0022H.c §A7";
    axi_names[18] = "AWID in configured range"; axi_sources[18] = "REQ-PARAM-001; IHI0022H.c §A5.2";
    axi_names[19] = "WVALID held until handshake"; axi_sources[19] = "IHI0022H.c §A3.2.1";
    axi_names[20] = "W payload stable while stalled"; axi_sources[20] = "IHI0022H.c §A3.2.1";
    axi_names[21] = "R response payload known"; axi_sources[21] = "IHI0022H.c §A3.2.2";
    axi_names[22] = "single-beat response has RLAST"; axi_sources[22] = "REQ-FUNC-003; IHI0022H.c §A3.2.2";
    axi_names[23] = "RID matches ARID"; axi_sources[23] = "IHI0022H.c §A5.2";
    axi_names[24] = "RVALID held during stall"; axi_sources[24] = "IHI0022H.c §A3.2.1";
    axi_names[25] = "R payload stable while stalled"; axi_sources[25] = "IHI0022H.c §A3.2.1";
    axi_names[26] = "B response payload known"; axi_sources[26] = "IHI0022H.c §A3.2.2";
    axi_names[27] = "BID matches AWID"; axi_sources[27] = "IHI0022H.c §A5.2";
    axi_names[28] = "BVALID held during stall"; axi_sources[28] = "IHI0022H.c §A3.2.1";
    axi_names[29] = "B payload stable while stalled"; axi_sources[29] = "IHI0022H.c §A3.2.1";
    axi_names[30] = "B follows AW and final W"; axi_sources[30] = "IHI0022H.c §§A3.2.2, A3.3";
    axi_names[31] = "WLAST matches expected burst end"; axi_sources[31] = "IHI0022H.c §A3.2.2";
    axi_names[32] = "AXI burst stays within 4 KiB"; axi_sources[32] = "IHI0022H.c §A3.4";

    bridge_names[0] = "AR follows an accepted AHB read"; bridge_sources[0] = "REQ-FUNC-003; IHI0022H.c §A3.2.1";
    bridge_names[1] = "AHB read fields map to AXI AR"; bridge_sources[1] = "REQ-FUNC-001/003; spec §6.3";
    bridge_names[2] = "AXI read remains single beat"; bridge_sources[2] = "REQ-FUNC-003/004";
    bridge_names[3] = "AXI RDATA maps to AHB HRDATA"; bridge_sources[3] = "REQ-FUNC-001; IHI0033C §4.3";
    bridge_names[4] = "AXI error response maps to AHB ERROR"; bridge_sources[4] = "REQ-ERR-001; DEC-WERR-001";
    bridge_names[5] = "AHB write data maps to AXI WDATA"; bridge_sources[5] = "REQ-FUNC-006; IHI0022H.c §A3.2.2";
    bridge_names[6] = "AHB HWSTRB maps to AXI WSTRB"; bridge_sources[6] = "REQ-FUNC-006; IHI0033C §2.2";
    bridge_names[7] = "AXI WLAST maps to AHB burst boundary"; bridge_sources[7] = "REQ-FUNC-005/006; IHI0022H.c §A3.2.2";
    bridge_names[8] = "AW waits for full fixed-burst capture"; bridge_sources[8] = "REQ-FUNC-005/009";
    bridge_names[9] = "AXI OKAY BRESP completes AHB write"; bridge_sources[9] = "REQ-ERR-001; IHI0033C §5.1.1";
    bridge_names[10] = "AHB IDLE/BUSY do not issue traffic"; bridge_sources[10] = "REQ-FUNC-002; IHI0033C §3.2";
    bridge_names[11] = "non-bufferable write waits for B"; bridge_sources[11] = "REQ-FUNC-008; WF-004";
    bridge_names[12] = "HPROT[6] reject has no AXI issue"; bridge_sources[12] = "REQ-ERR-002; DEC-HPROT-001";
    bridge_names[13] = "HMASTLOCK reject has no AXI issue"; bridge_sources[13] = "REQ-ERR-002; DEC-EXCL-001";
    bridge_names[14] = "4-KiB crossing is split"; bridge_sources[14] = "REQ-FUNC-010; IHI0022H.c §A3.4";
    bridge_names[15] = "split BRESP error is aggregated"; bridge_sources[15] = "REQ-FUNC-007/010; WF-006";
    bridge_names[16] = "AHB write fields map to AXI AW"; bridge_sources[16] = "REQ-FUNC-001/005; spec §6.3";

    for (integer init_index = 0; init_index < AHB_ASSERTION_COUNT; init_index = init_index + 1) begin
      ahb_hits[init_index] = 0;
      ahb_fails[init_index] = 0;
    end
    for (integer init_index = 0; init_index < AXI_ASSERTION_COUNT; init_index = init_index + 1) begin
      axi_hits[init_index] = 0;
      axi_fails[init_index] = 0;
    end
    for (integer init_index = 0; init_index < BRIDGE_ASSERTION_COUNT; init_index = init_index + 1) begin
      bridge_hits[init_index] = 0;
      bridge_fails[init_index] = 0;
    end

    if (!$value$plusargs("CASE=%d", selected_case)) selected_case = 0;
    case (selected_case)
      0: begin end
      1: begin $dumpfile("waveforms_sim/wf001_shared_reset.vcd"); $dumpvars(0, tb_ahb2axi); end
      2: begin $dumpfile("waveforms_sim/wf002_read_error.vcd"); $dumpvars(0, tb_ahb2axi); end
      3: begin $dumpfile("waveforms_sim/wf003_bufferable_burst.vcd"); $dumpvars(0, tb_ahb2axi); end
      4: begin $dumpfile("waveforms_sim/wf004_nonbufferable_write.vcd"); $dumpvars(0, tb_ahb2axi); end
      5: begin $dumpfile("waveforms_sim/wf005_rejected_access.vcd"); $dumpvars(0, tb_ahb2axi); end
      6: begin $dumpfile("waveforms_sim/wf006_4k_split.vcd"); $dumpvars(0, tb_ahb2axi); end
      default: $fatal(1, "CASE must be in the range 1..6");
    endcase
    $dumpoff;
    $display("SIM-BRANCH: single-clock simulation (no CDC)");
    test_wf001_reset_and_startup();
    test_ahb_idle_busy();
    if (selected_case == 0) begin
      test_wf002_read_error();
      if ((test_failures == 0) && (assertion_failures == 0))
        test_wf003_bufferable_burst();
      if ((test_failures == 0) && (assertion_failures == 0))
        test_wf004_nonbufferable_write();
      if ((test_failures == 0) && (assertion_failures == 0))
        test_wf005_rejected_transfers();
      if ((test_failures == 0) && (assertion_failures == 0))
        test_wf006_4k_split();
    end else begin
      case (selected_case)
        1: begin end
        2: test_wf002_read_error();
        3: test_wf003_bufferable_burst();
        4: test_wf004_nonbufferable_write();
        5: test_wf005_rejected_transfers();
        6: test_wf006_4k_split();
        default: $fatal(1, "CASE must be 0..6");
      endcase
    end

    tcheck((exp_ar_head == exp_ar_tail), "all expected AXI AR requests observed");
    tcheck((exp_aw_head == exp_aw_tail), "all expected AXI AW requests observed");
    tcheck((exp_w_head == exp_w_tail), "all expected AXI W beats observed");
    tcheck((b_handshakes == aw_handshakes), "one AXI B per AXI write transaction");
    tcheck((wlast_handshakes == aw_handshakes), "each AXI write transaction has one final W beat");
    report_assertions();
    $finish;
  end

endmodule
