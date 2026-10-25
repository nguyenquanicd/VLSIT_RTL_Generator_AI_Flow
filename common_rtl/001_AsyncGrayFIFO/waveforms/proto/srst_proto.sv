`timescale 1ns/100ps
//------------------------------------------------------------------------------
// Protocol prototype of the SOFTWARE RESET handshake of the Async Gray FIFO.
// NOT the RTL of the IP: only the pointers, the flags, two reset FSMs and the four
// crossings (request, acknowledge, write Gray pointer, read Gray pointer) are modelled.
// 3-bit pointers (depth 4), 2-stage synchronizers.
// The software reset input is i_rst_n_sw: active-low level, synchronous to the write clock.
// Every input of the interface changes at a rising edge of its clock (non-blocking assignment at the edge)
//   and every reset is asserted and released at a clock edge.
//   +SCRIPT=n   1 main scenario, 2 one-cycle pulse on a full FIFO, 3 re-assertion while in REL,
//               4 hardware reset during the sequence (writes srst_<n>.vcd)
//   +RAND=1     random per-bit extra latency (0..2 cycles) on every crossing (metastability model)
//   +SEED=n     seed ; +HW=n +HR=n half periods of the write / read clock (ns)
//   +NOFLUSH=1  remove the "synchronized pointer == 0" release condition (negative test)
//   +NCYC=n     number of random software resets
//   +MODE=m     random stimulus: 0 = next reset only after the write side is released,
//               1 = i_rst_n_sw may be asserted again at any time (also while the write FSM is in REL),
//               2 = as 1, and a quarter of the resets are aborted by a hardware reset of both domains
// Decisions modelled: DEC-025 active-low i_rst_n_sw, DEC-026 o_sw_rst_busy, DEC-027 o_full = 1
// while the write side is blocked, DEC-028 no overflow or underflow pulse for a blocked access,
// DEC-029 threshold flags show an empty FIFO while blocked, DEC-030 zero-latency blocks,
// DEC-031 hardware reset priority.
//------------------------------------------------------------------------------
module rsync #(parameter W = 1, parameter ID = 0) (
  input clk, input rst_n, input en, input [31:0] seed, input [W-1:0] d, output [W-1:0] q);
  reg [W-1:0] s1, s2, last, cur, nxt, pend;
  integer cnt [0:W-1];
  reg [31:0] rs;
  integer b, k;
  assign q = en ? cur : s2;
  function [31:0] nextrs(input [31:0] x);
    reg [31:0] y;
    begin y = x; y = y ^ (y << 13); y = y ^ (y >> 17); y = y ^ (y << 5); nextrs = y; end
  endfunction
  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      s1 <= 0; s2 <= 0; last <= 0; cur <= 0; pend <= 0; rs <= (seed ^ (32'h9e3779b9 * (ID + 1))) | 1;
      for (b = 0; b < W; b = b + 1) cnt[b] = 0;
    end else begin
      s1 <= d; s2 <= s1;
      for (b = 0; b < W; b = b + 1) begin
        if (s2[b] !== last[b]) begin                       // a change reached the last stage
          last[b] <= s2[b]; rs <= nextrs(rs);
          k = (nextrs(rs) >> 7) % 3;                        // extra latency 0, 1 or 2 cycles
          if (k == 0) begin cur[b] <= s2[b]; pend[b] <= 0; end
          else begin nxt[b] <= s2[b]; cnt[b] = k - 1; pend[b] <= 1; end   // new value replaces the pending one
        end else if (pend[b]) begin
          if (cnt[b] == 0) begin cur[b] <= nxt[b]; pend[b] <= 0; end else cnt[b] = cnt[b] - 1;
        end
      end
    end
  end
endmodule

module srst_proto;
  localparam PW = 3;
  localparam W_RUN = 0, W_REQ = 1, W_PTR = 2, W_HOLD = 3, W_REL = 4;
  localparam R_RUN = 0, R_RST = 1, R_ACK = 2;
  integer hw = 5, hr = 7, nflush = 0, rnd = 0, script = 0, ncyc = 20, seed = 1, errors = 0, mode = 0;
  initial begin
    if ($value$plusargs("HW=%d", hw)) ; if ($value$plusargs("HR=%d", hr)) ;
    if ($value$plusargs("NOFLUSH=%d", nflush)) ; if ($value$plusargs("RAND=%d", rnd)) ;
    if ($value$plusargs("SCRIPT=%d", script)) ; if ($value$plusargs("NCYC=%d", ncyc)) ;
    if ($value$plusargs("SEED=%d", seed)) ; if ($value$plusargs("MODE=%d", mode)) ;
  end
  reg clk_wr = 0, clk_rd = 0, rst_n_wr = 0, rst_n_rd = 0;
  initial begin #1; forever #(hw) clk_wr = ~clk_wr; end
  initial begin #(1 + (seed % 5)); forever #(hr) clk_rd = ~clk_rd; end

  function [PW-1:0] g2b(input [PW-1:0] g);
    integer i; reg [PW-1:0] b;
    begin b[PW-1] = g[PW-1]; for (i = PW - 2; i >= 0; i = i - 1) b[i] = b[i+1] ^ g[i]; g2b = b; end
  endfunction

  // ---------------- inputs ----------------
  reg i_rst_n_sw = 1, i_wr_en = 0, i_rd_en = 0;       // i_rst_n_sw = 0 requests the software reset
  wire sw_rst = ~i_rst_n_sw;                          // internal active-high view of the request
  reg [7:0] i_wr_data = 0;
  reg [PW-1:0] i_full_thr = 3, i_empty_thr = 1;         // static thresholds
  reg traffic_en = 1;                                   // random traffic gate (modes 0 to 2)

  // ---------------- write domain ----------------
  reg [2:0] wst;
  reg req_wr, o_overflow, o_sw_rst_busy;     // o_sw_rst_busy is a flip-flop (DEC-026)
  reg [PW-1:0] wbin, wgray;
  wire ack_s;                       // acknowledge synchronized into the write domain
  wire [PW-1:0] rgray_s;            // read Gray pointer synchronized into the write domain
  wire wr_blk = (wst != W_RUN) | sw_rst;
  wire full_n = (wgray == {~rgray_s[PW-1:PW-2], rgray_s[PW-3:0]});
  wire o_full = wr_blk | full_n;                                            // DEC-027
  wire [PW-1:0] occ_w = wbin - g2b(rgray_s);
  wire o_full_thr = wr_blk ? (i_full_thr == 0) : (occ_w >= i_full_thr);     // DEC-029
  wire wr_accept = i_wr_en & ~wr_blk & ~full_n;
  wire [PW-1:0] wbin_n = wbin + 1'b1;
  reg [7:0] mem [0:3];
  always @(posedge clk_wr or negedge rst_n_wr) begin
    if (!rst_n_wr) begin wst <= W_RUN; req_wr <= 0; wbin <= 0; wgray <= 0; o_overflow <= 0; o_sw_rst_busy <= 0; end
    else begin
      o_overflow <= i_wr_en & ~wr_blk & full_n;                             // DEC-028: a blocked access gives no pulse
      case (wst)
        W_RUN:  if (sw_rst) begin wst <= W_REQ; req_wr <= 1; o_sw_rst_busy <= 1; end
                else if (wr_accept) begin wbin <= wbin_n; wgray <= wbin_n ^ (wbin_n >> 1); mem[wbin[1:0]] <= i_wr_data; end
        W_REQ:  if (ack_s) wst <= W_PTR;
        W_PTR:  begin wbin <= 0; wgray <= 0; wst <= W_HOLD; end
        W_HOLD: if (!sw_rst) begin wst <= W_REL; req_wr <= 0; end
        W_REL:  if (!ack_s && (nflush || rgray_s == 0)) begin wst <= W_RUN; o_sw_rst_busy <= 0; end
        default: wst <= W_RUN;
      endcase
    end
  end

  // ---------------- read domain ----------------
  reg [1:0] rst_st;
  reg ack_rd, o_underflow;
  reg [PW-1:0] rbin, rgray;
  wire req_s;                       // request synchronized into the read domain
  wire [PW-1:0] wgray_s;            // write Gray pointer synchronized into the read domain
  wire rd_blk = (rst_st != R_RUN) | req_s;
  wire empty_n = (rgray == wgray_s);
  wire o_empty = rd_blk | empty_n;
  wire [PW-1:0] occ_r = g2b(wgray_s) - rbin;
  wire o_empty_thr = rd_blk ? 1'b1 : (occ_r <= i_empty_thr);                // DEC-029
  wire rd_accept = i_rd_en & ~rd_blk & ~empty_n;
  wire [PW-1:0] rbin_n = rbin + 1'b1;
  wire [7:0] o_rd_data = mem[rbin[1:0]];
  always @(posedge clk_rd or negedge rst_n_rd) begin
    if (!rst_n_rd) begin rst_st <= R_RUN; ack_rd <= 0; rbin <= 0; rgray <= 0; o_underflow <= 0; end
    else begin
      o_underflow <= i_rd_en & ~rd_blk & empty_n;                           // DEC-028
      case (rst_st)
        R_RUN: if (req_s) rst_st <= R_RST;
               else if (rd_accept) begin rbin <= rbin_n; rgray <= rbin_n ^ (rbin_n >> 1); end
        R_RST: begin rbin <= 0; rgray <= 0; ack_rd <= 1; rst_st <= R_ACK; end
        R_ACK: if (!req_s && (nflush || wgray_s == 0)) begin ack_rd <= 0; rst_st <= R_RUN; end
        default: rst_st <= R_RUN;
      endcase
    end
  end

  // ---------------- crossings ----------------
  wire [31:0] sd = seed;
  rsync #(.W(1),  .ID(1)) u_req (.clk(clk_rd), .rst_n(rst_n_rd), .en(rnd[0]), .seed(sd), .d(req_wr),  .q(req_s));
  rsync #(.W(1),  .ID(2)) u_ack (.clk(clk_wr), .rst_n(rst_n_wr), .en(rnd[0]), .seed(sd), .d(ack_rd),  .q(ack_s));
  rsync #(.W(PW), .ID(3)) u_wg  (.clk(clk_rd), .rst_n(rst_n_rd), .en(rnd[0]), .seed(sd), .d(wgray),   .q(wgray_s));
  rsync #(.W(PW), .ID(4)) u_rg  (.clk(clk_wr), .rst_n(rst_n_wr), .en(rnd[0]), .seed(sd), .d(rgray),   .q(rgray_s));

  // ---------------- checkers ----------------
  integer t_rd_unblk, t_wr_unblk, t_sw_rise, n_reset = 0;
  reg [7:0] sb [0:63]; integer sb_wr = 0, sb_rd = 0;
  always @(posedge clk_wr) if (rst_n_wr) begin
    if (wr_blk && wr_accept) begin errors = errors + 1; $display("ERR write accepted while blocked t=%0t", $time); end
    if (o_sw_rst_busy !== (wst != W_RUN)) begin errors = errors + 1; $display("ERR o_sw_rst_busy differs from the FSM state t=%0t", $time); end
    if (wr_blk && !o_full) begin errors = errors + 1; $display("ERR o_full = 0 while blocked t=%0t", $time); end
    if (wr_blk && (o_full_thr !== (i_full_thr == 0))) begin errors = errors + 1; $display("ERR o_full_thr while blocked t=%0t", $time); end
    if (wr_accept) begin sb[sb_wr % 64] = i_wr_data; sb_wr = sb_wr + 1; end
  end
  always @(posedge clk_rd) if (rst_n_rd) begin
    if (rd_blk && rd_accept) begin errors = errors + 1; $display("ERR read accepted while blocked t=%0t", $time); end
    if (rd_blk && (!o_empty || !o_empty_thr)) begin errors = errors + 1; $display("ERR empty flags while blocked t=%0t", $time); end
    if (rd_accept) begin
      if (sb_rd >= sb_wr) begin errors = errors + 1; $display("ERR read of a word that was never written t=%0t", $time); end
      else if (o_rd_data !== sb[sb_rd % 64]) begin errors = errors + 1; $display("ERR data mismatch exp=%h got=%h t=%0t", sb[sb_rd % 64], o_rd_data, $time); end
      sb_rd = sb_rd + 1;
    end
  end
  // release events are detected with the transition condition, before the clock edge that releases
  always @(posedge clk_rd) if (rst_n_rd && rst_st == R_ACK && !req_s && (nflush || wgray_s == 0)) begin
    t_rd_unblk = $time;
    if (wgray_s !== 0 || rgray !== 0) begin errors = errors + 1; $display("ERR read released with stale pointers wg_s=%b rg=%b t=%0t", wgray_s, rgray, $time); end
  end
  always @(posedge clk_wr) if (rst_n_wr && wst == W_REL && !ack_s && (nflush || rgray_s == 0)) begin
    t_wr_unblk = $time; n_reset = n_reset + 1;
    if (rgray_s !== 0 || wgray !== 0) begin errors = errors + 1; $display("ERR write released with stale pointers rg_s=%b wg=%b t=%0t", rgray_s, wgray, $time); end
    if (t_rd_unblk > t_wr_unblk || t_rd_unblk < t_sw_rise) begin errors = errors + 1; $display("ERR release order rd=%0d wr=%0d t=%0t", t_rd_unblk, t_wr_unblk, $time); end
    sb_rd = sb_wr;                                    // all pre-reset words are discarded
  end
  // after the read side is released the FIFO must report empty until a word is written
  always @(posedge clk_rd) if (rst_n_rd && rst_st == R_RUN && !req_s && rgray === 0 && wgray_s === 0 && !o_empty) begin
    errors = errors + 1; $display("ERR empty=0 with both pointers at 0 t=%0t", $time);
  end
  // the start of a sequence is the assertion of i_rst_n_sw while the write FSM is in RUN
  always @(negedge i_rst_n_sw) if (wst == W_RUN) t_sw_rise = $time;

  // ---------------- stimulus ----------------
  task wcyc(input integer n); begin repeat (n) @(posedge clk_wr); end endtask
  task rcyc(input integer n); begin repeat (n) @(posedge clk_rd); end endtask
  task hw_reset_both;                 // hardware reset of both domains, asserted and released at clock edges
    begin
      traffic_en = 0; i_wr_en <= 0; i_rd_en <= 0; i_rst_n_sw <= 1;
      fork
        begin @(posedge clk_wr); rst_n_wr <= 0; end
        begin @(posedge clk_rd); rst_n_rd <= 0; end
      join
      repeat (3 + ($urandom % 3)) @(posedge clk_wr); rst_n_wr <= 1;
      repeat (2 + ($urandom % 2)) @(posedge clk_rd); rst_n_rd <= 1;
      wcyc(3); rcyc(3);
      if (wst !== W_RUN || rst_st !== R_RUN || wbin !== 0 || rbin !== 0 || !o_empty || o_full) begin
        errors = errors + 1; $display("ERR state after the hardware reset t=%0t", $time);
      end
      sb_rd = sb_wr; traffic_en = 1;
    end
  endtask
  task final_check(input integer expect_min);
    begin
      wait (wst == W_RUN && rst_st == R_RUN); wcyc(4);
      if (n_reset < expect_min) begin errors = errors + 1; $display("ERR fewer resets than expected: %0d", n_reset); end
    end
  endtask
  integer i, dur;
  initial begin
    if (script) begin $dumpfile($sformatf("srst_%0d.vcd", script)); $dumpvars(0, srst_proto); end
    fork
      begin repeat (4) @(posedge clk_wr); rst_n_wr <= 1; end        // released at a clock edge
      begin repeat (5) @(posedge clk_rd); rst_n_rd <= 1; end
    join
    case (script)
      1: begin   // three words in the FIFO, producer and consumer keep requesting during the reset
        wcyc(2); i_wr_data <= 8'h11; i_wr_en <= 1; wcyc(1); i_wr_data <= 8'h22; wcyc(1); i_wr_data <= 8'h33; wcyc(1); i_wr_en <= 0;
        wcyc(12);
        i_wr_data <= 8'h77; i_wr_en <= 1; i_rst_n_sw <= 0; fork begin rcyc(1); i_rd_en <= 1; end join_none
        wait (wst == W_HOLD); wcyc(3); i_rst_n_sw <= 1;
        wait (wst == W_RUN); i_wr_en <= 0; rcyc(1); i_rd_en <= 0; wcyc(5);
        i_wr_data <= 8'hA5; i_wr_en <= 1; wcyc(1); i_wr_data <= 8'h3C; wcyc(1); i_wr_en <= 0;
        rcyc(10); i_rd_en <= 1; rcyc(4); i_rd_en <= 0; rcyc(4);
        final_check(1);
      end
      2: begin   // FIFO full, producer keeps writing (overflow), one-cycle pulse on i_rst_n_sw
        wcyc(2); i_wr_en <= 1; i_wr_data <= 8'h11; wcyc(1); i_wr_data <= 8'h22; wcyc(1); i_wr_data <= 8'h33; wcyc(1);
        i_wr_data <= 8'h44; wcyc(1); i_wr_data <= 8'h55; wcyc(4);
        i_wr_data <= 8'h77; i_rst_n_sw <= 0; wcyc(1); i_rst_n_sw <= 1;
        wait (wst != W_RUN); wait (wst == W_RUN); i_wr_en <= 0; wcyc(5);
        i_wr_data <= 8'hA5; i_wr_en <= 1; wcyc(1); i_wr_en <= 0;
        rcyc(10); i_rd_en <= 1; rcyc(4); i_rd_en <= 0; rcyc(4);
        final_check(1);
      end
      3: begin   // i_rst_n_sw asserted again while the write FSM is in REL
        wcyc(2); i_wr_data <= 8'h11; i_wr_en <= 1; wcyc(1); i_wr_data <= 8'h22; wcyc(1); i_wr_en <= 0; wcyc(10);
        i_rst_n_sw <= 0;
        wait (wst == W_HOLD); wcyc(2); i_rst_n_sw <= 1;
        wait (wst == W_REL); wcyc(1); i_wr_data <= 8'h77; i_wr_en <= 1; i_rst_n_sw <= 0;
        wait (wst == W_RUN); wait (wst == W_REQ);
        wait (wst == W_HOLD); wcyc(2); i_rst_n_sw <= 1;
        wait (wst == W_RUN); i_wr_en <= 0; wcyc(5);
        i_wr_data <= 8'hA5; i_wr_en <= 1; wcyc(1); i_wr_en <= 0;
        rcyc(10); i_rd_en <= 1; rcyc(3); i_rd_en <= 0; rcyc(4);
        final_check(2);
      end
      4: begin   // hardware reset of both domains in the middle of the sequence
        wcyc(2); i_wr_data <= 8'h11; i_wr_en <= 1; wcyc(1); i_wr_data <= 8'h22; wcyc(1); i_wr_data <= 8'h33; wcyc(1); i_wr_en <= 0; wcyc(10);
        i_rst_n_sw <= 0;
        wait (wst == W_HOLD); wcyc(2);
        hw_reset_both;
        wcyc(4);
        i_wr_data <= 8'hA5; i_wr_en <= 1; wcyc(1); i_wr_en <= 0;
        rcyc(10); i_rd_en <= 1; rcyc(3); i_rd_en <= 0; rcyc(4);
        final_check(0);
      end
      default: begin
        fork
          begin : wr_traffic forever begin i_wr_en <= traffic_en && (($urandom % 3) != 0); i_wr_data <= $urandom; wcyc(1); end end
          begin : rd_traffic forever begin i_rd_en <= traffic_en && (($urandom % 3) != 0); rcyc(1); end end
          begin : sw_ctrl
            for (i = 0; i < ncyc; i = i + 1) begin
              wcyc(1 + ($urandom % 40));
              i_rst_n_sw <= 0;
              if (mode == 2 && ($urandom % 4) == 0) begin
                wcyc(1 + ($urandom % 30)); hw_reset_both;
              end else begin
                dur = 1 + ($urandom % 12); wcyc(dur); i_rst_n_sw <= 1;
                if (mode == 0) begin wait (wst != W_RUN); wait (wst == W_RUN); wcyc(1); end
              end
            end
            wcyc(2); i_rst_n_sw <= 1;
            wait (wst == W_RUN && rst_st == R_RUN); wcyc(60);
            $display("RESULT seed=%0d hw=%0d hr=%0d rand=%0d mode=%0d noflush=%0d resets=%0d errors=%0d %s", seed, hw, hr, rnd, mode, nflush, n_reset,
                     errors, (errors == 0 && n_reset >= 1 && n_reset <= ncyc && wst == W_RUN && rst_st == R_RUN) ? "PASS" : "FAIL");
            $finish;
          end
        join
      end
    endcase
    if (script) begin
      $display("SCRIPT=%0d resets=%0d errors=%0d t_sw=%0d t_rd_unblk=%0d t_wr_unblk=%0d %s", script, n_reset, errors, t_sw_rise, t_rd_unblk, t_wr_unblk, (errors == 0) ? "PASS" : "FAIL");
      $finish;
    end
  end
  initial begin #3000000; $display("TIMEOUT (deadlock?) resets=%0d RESULT FAIL", n_reset); $finish; end
endmodule
