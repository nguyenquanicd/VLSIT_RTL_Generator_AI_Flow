SRST_1
| No. | Time (ns) | Event |
|---:|---:|---|
| 1 | 226.0 | Software asserts `i_rst_n_sw` = 0 (active-low request). In the same cycle (zero latency) writes are blocked: `i_wr_en` = 1 is not accepted, `o_full` = 1, and `o_full_thr` takes the value of an empty FIFO (0). |
| 2 | 236.0 | Write FSM leaves RUN: `req_wr` = 1 and `o_sw_rst_busy` = 1. Writes stay blocked. |
| 3 | 261.0 | The request is visible in the read domain (after the synchronizer): reads are blocked, `o_empty` = 1 and `o_empty_thr` = 1 in the same cycle. Reads accepted before this event were normal reads of pre-reset words. |
| 4 | 275.0 | Read FSM in RST: the read pointer is reset to 0. |
| 5 | 289.0 | `ack_rd` = 1: the read side is reset and acknowledges. |
| 6 | 306.0 | The acknowledge is visible in the write domain. |
| 7 | 316.0 | Write FSM in PTR: the write pointer is reset to 0. The FSM then waits in HOLD for `i_rst_n_sw` = 1. |
| 8 | 356.0 | Software releases `i_rst_n_sw` (back to 1). Writes stay blocked (FSM in HOLD, then REL). |
| 9 | 366.0 | Write FSM: `req_wr` = 0 (release request). |
| 10 | 387.0 | The request = 0 is visible in the read domain. |
| 11 | 401.0 | Read FSM returns to RUN: **read released first**. `ack_rd` = 0, flags live (`o_empty` = 1 because both pointers are 0). |
| 12 | 416.0 | The acknowledge = 0 is visible in the write domain. |
| 13 | 426.0 | Write FSM returns to RUN: **write released last**. Writes unblocked, `o_full` = 0, `o_full_thr` normal, `o_sw_rst_busy` = 0. |
| 14 | 476.0 | The first write after the reset is accepted (0xA5). |
| 15 | 513.0 | The new write pointer has crossed to the read domain: `o_empty` falls. |

SRST_2
| No. | Time (ns) | Event |
|---:|---:|---|
| 1 | 126.0 | The FIFO is full and the producer keeps writing: `o_overflow` pulses (normal overflow, registered one cycle after the rejected request). |
| 2 | 156.0 | `i_rst_n_sw` = 0 for **one write-clock cycle** only. Writes are blocked at once, `o_full` stays 1, and no overflow pulse follows although `i_wr_en` = 1 (the blocked access is not an error). |
| 3 | 166.0 | Write FSM takes the request at the first write edge: `req_wr` = 1, `o_sw_rst_busy` = 1. |
| 4 | 166.0 | `i_rst_n_sw` is back to 1 after one cycle. The request is already latched, so the sequence continues. |
| 5 | 191.0 | The request is visible in the read domain: reads blocked, `o_empty` = 1. |
| 6 | 219.0 | Read pointer reset, `ack_rd` = 1. |
| 7 | 246.0 | Write pointer reset (PTR). The input is already 1, so the FSM does not wait in HOLD. |
| 8 | 266.0 | Write FSM: `req_wr` = 0. |
| 9 | 303.0 | Read side released first. |
| 10 | 326.0 | Write side released last: `o_full` falls, writes unblocked. |
| 11 | 376.0 | The first write after the reset is accepted. |

SRST_3
| No. | Time (ns) | Event |
|---:|---:|---|
| 1 | 196.0 | First software reset: `i_rst_n_sw` = 0, writes blocked, handshake starts. |
| 2 | 316.0 | `i_rst_n_sw` back to 1 (after HOLD): the write FSM goes to REL and drops the request. |
| 3 | 326.0 | Write FSM in REL, waiting for the acknowledge to fall. |
| 4 | 336.0 | `i_rst_n_sw` = 0 **again while the write FSM is in REL**. Writes stay blocked (the block includes the input); `i_wr_en` = 1 is not accepted. |
| 5 | 359.0 | First sequence: the read side is released. |
| 6 | 386.0 | First sequence: the write FSM reaches RUN. The input is still 0, so no write is accepted in this cycle either (`wr_blk` includes the input). |
| 7 | 396.0 | Second sequence starts at once: `req_wr` = 1. |
| 8 | 496.0 | `i_rst_n_sw` back to 1 (in HOLD of the second sequence). |
| 9 | 541.0 | Second sequence: the read side is released again after its own reset. |
| 10 | 566.0 | Second sequence: the write side is released last. Writes are unblocked. |

SRST_4
| No. | Time (ns) | Event |
|---:|---:|---|
| 1 | 206.0 | Software reset starts: `i_rst_n_sw` = 0. |
| 2 | 216.0 | `req_wr` = 1. |
| 3 | 261.0 | The read side is reset and `ack_rd` = 1. |
| 4 | 296.0 | The write pointer is reset; the write FSM waits in HOLD. |
| 5 | 326.0 | Hardware reset of both domains asserted (`i_rst_n_wr` = 0, `i_rst_n_rd` = 0) in the middle of the sequence; the testbench also releases `i_rst_n_sw`. Both FSMs, both pointers and both synchronizers go to their reset values at once (hardware reset priority). |
| 6 | 366.0 | `i_rst_n_wr` released. The write FSM is in RUN and the FIFO is empty. |
| 7 | 401.0 | `i_rst_n_rd` released (later than the write side). The read FSM is in RUN and `o_empty` = 1. |
| 8 | 496.0 | The first write after the reset is accepted (0xA5) once both domains are out of reset (ASM-005). |
| 9 | 527.0 | `o_empty` falls after the write pointer has crossed to the read domain. |

SRST_BUSY_1
| No. | Time (ns) | Event |
|---:|---:|---|
| 1 | 226.0 | `i_rst_n_sw` falls. `wr_blk` = 1 and `o_full` = 1 at once (combinational). `o_sw_rst_busy` is still 0: it is a flip-flop and changes only at the next write-clock edge. |
| 2 | 236.0 | The first write-clock edge after the fall: the write FSM goes RUN to REQ, and `req_wr` and `o_sw_rst_busy` rise **at this same edge** (busy is one write-clock cycle behind the block). |
| 3 | 316.0 | The acknowledge was seen, the write FSM goes REQ to PTR and resets the write pointer. Busy stays 1 (state not RUN). |
| 4 | 356.0 | `i_rst_n_sw` back to 1. The write FSM is in HOLD and goes to REL at the next edge. Busy stays 1: it follows the FSM state, not the input. |
| 5 | 401.0 | The read FSM returns to RUN (read side released). Busy stays 1: it describes the write side, which is released last. |
| 6 | 426.0 | The write FSM returns to RUN. `o_sw_rst_busy` falls at this edge, together with `wr_blk` and `o_full`: writes are possible again. |

SRST_BUSY_3
| No. | Time (ns) | Event |
|---:|---:|---|
| 1 | 336.0 | `i_rst_n_sw` = 0 again while the write FSM is in REL (first sequence not finished). Busy is still 1. |
| 2 | 386.0 | The write FSM returns to RUN: `o_sw_rst_busy` falls. `wr_blk` stays 1 because the input is still 0. |
| 3 | 396.0 | One write-clock cycle later the FSM sees the input at 0 in RUN and goes to REQ: `o_sw_rst_busy` rises again. Writes were blocked during the whole gap. |

SRST_BUSY_TABLE
| Scenario | `i_rst_n_sw` falls (ns) | `wr_blk` rises (ns) | `o_sw_rst_busy` rises (ns) | `o_sw_rst_busy` falls (ns) | `wr_blk` falls (ns) | Busy high (write-clock cycles) |
|---|---:|---:|---:|---:|---:|---:|
| 1 | 226.0 | 226.0 | 236.0 | 426.0 | 426.0 | 19 |
| 2 | 156.0 | 156.0 | 166.0 | 326.0 | 326.0 | 16 |
| 3.1 | 196.0 | 196.0 | 206.0 | 386.0 | 566.0 | 18 |
| 3.2 | 336.0 | 196.0 | 396.0 | 566.0 | 566.0 | 17 |
| 4 | 206.0 | 206.0 | 216.0 | 326.0 | 326.0 | 11 |

SRST_SYNC
| Scenario | Write domain signals checked (clock `i_clk_wr`) | Changes outside a rising edge | Read domain signals checked (clock `i_clk_rd`) | Changes outside a rising edge |
|---|---|---:|---|---:|
| 1 | `i_wr_en`, `i_wr_data`, `i_rst_n_sw`, `rst_n_wr` | 0 | `i_rd_en`, `rst_n_rd` | 0 |
| 2 | `i_wr_en`, `i_wr_data`, `i_rst_n_sw`, `rst_n_wr` | 0 | `i_rd_en`, `rst_n_rd` | 0 |
| 3 | `i_wr_en`, `i_wr_data`, `i_rst_n_sw`, `rst_n_wr` | 0 | `i_rd_en`, `rst_n_rd` | 0 |
| 4 | `i_wr_en`, `i_wr_data`, `i_rst_n_sw`, `rst_n_wr` | 0 | `i_rd_en`, `rst_n_rd` | 0 |
