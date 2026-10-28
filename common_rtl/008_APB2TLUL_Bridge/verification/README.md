# Verification of m_apb_tlul_bridge / Kiểm chứng m_apb_tlul_bridge

**EN:** `tb_apb_tlul_bridge.sv` is the self-checking testbench (requester model, TL-UL device model, scoreboard, monitors). `apb_tlul_protocol_assertions.sv` holds 36 protocol assertions on the APB4 and TL-UL ports. Run both with `make sim` and `make sim-narrow` from the parent folder; the results are written to `../sanity/`.

**VI:** `tb_apb_tlul_bridge.sv` là testbench tự kiểm (mô hình requester, mô hình thiết bị TL-UL, scoreboard, monitor). `apb_tlul_protocol_assertions.sv` chứa 36 assertion giao thức trên cổng APB4 và TL-UL. Chạy bằng `make sim` và `make sim-narrow` từ thư mục cha; kết quả ghi vào `../sanity/`.

## How the assertions work / Cách các assertion hoạt động

**EN:** Icarus Verilog has no concurrent SVA, so each assertion is a clocked check with an antecedent and a consequent, sampled at the rising edge before the design flops update (the same sampling as a concurrent assertion). The module counts **hits** (antecedent true) and **fails** per assertion. At the end the testbench prints the table and fails if an assertion failed or **never fired** (a check that never fires proves nothing). Three masks switch off the checks that a test violates on purpose (orphan response, wrong `d_opcode`/`d_source` injected, read driven with a non-zero `PSTRB`).

**VI:** Icarus Verilog không hỗ trợ SVA concurrent, nên mỗi assertion là một check theo clock có antecedent và consequent, lấy mẫu ở cạnh lên trước khi flop của design cập nhật (giống cách lấy mẫu của concurrent assertion). Module đếm **hits** (antecedent đúng) và **fails** cho từng assertion. Cuối bài test in bảng và báo FAIL nếu có assertion lỗi hoặc **không bao giờ kích hoạt** (check không kích hoạt thì không chứng minh gì). Ba mask tắt các check mà test cố ý vi phạm (response mồ côi, chèn `d_opcode`/`d_source` sai, đọc với `PSTRB` khác 0).

## The 36 assertions / 36 assertion

Sources / Nguồn: APB = Arm IHI 0024 Issue D (`../../../VLSIT_CODEX_CLAUDE_SKILLS/.claude/skills/vlsit-asic-ip-microspec/reference/md_doc` of the skill `vlsit-asic-ip-microspec`); TL-UL = OpenTitan TL-UL specification and the `tlul_assert` protocol checker (the names legalAOpcode, sizeMatchesMask... are theirs); BRIDGE = requirement of this design; CROSS = relation between the APB transfer and the TL-UL request and response.

| ID | Rule / Quy tắc | Source / Nguồn |
|---|---|---|
| APB-01 | `PENABLE` only when `PSEL` | APB 4.1 |
| APB-02 | The Setup phase lasts one cycle, then `PSEL` and `PENABLE` are high / Setup một chu kỳ rồi sang Access | APB 4.1 |
| APB-03 | The Access phase holds (`PSEL`, `PENABLE`) until `PREADY` / Access giữ đến khi `PREADY` | APB 3.1, 4.1 |
| APB-04 | `PADDR`, `PWRITE`, `PSTRB` (and `PWDATA` on a write) stay unchanged from Setup to the end of the transfer / không đổi suốt transfer | APB 3.1, 4.1 |
| APB-05 | `PSTRB` is all LOW on a read / `PSTRB` bằng 0 khi đọc | APB 3.2 |
| APB-06 | `PADDR`, `PWRITE`, `PSTRB`, `PENABLE` (and `PWDATA` on a write) are not X when `PSEL` / không X khi `PSEL` | APB Appendix A |
| APB-07 | `PREADY` is known in Access; at completion `PSLVERR` is known and `PRDATA` is known on an error-free read / hợp lệ khi hoàn tất | APB Appendix A, 3.4 |
| APB-08 | `PSLVERR` only together with `PREADY` | APB 3.4 |
| APB-09 | `PREADY` only in the Access phase | BRIDGE REQ-IF-004 |
| APB-10 | `PENABLE` is LOW in the cycle after a completed transfer / `PENABLE` thấp sau khi hoàn tất | APB 4.1 |
| APB-11 | `PENABLE` is LOW in the first cycle of `PSEL` / `PENABLE` thấp ở chu kỳ đầu của `PSEL` | APB 4.1 |
| APB-12 | An Access phase ends within `MAX_WAIT` cycles (no hang) / không treo | BRIDGE |
| APB-13 | `PREADY` is high for one cycle only | BRIDGE REQ-IF-004 |
| APB-14 | `PREADY` and `PSLVERR` are LOW in reset | BRIDGE REQ-RESET-001 |
| TL-01 | legalAOpcode: Get (3'b100), PutFullData (3'b000) or PutPartialData (3'b001) | TL-UL opcode table |
| TL-02 | legalAParam: `a_param` is 0 | tlul_assert |
| TL-03 | sizeMatchesMask: 2^`a_size` equals the number of `a_mask` bits | tlul_assert, TileLink 4.6 |
| TL-04 | addrSizeAligned: `a_address` is aligned to `a_size` | tlul_assert |
| TL-05 | contigMask: `a_mask` is contiguous for Get and PutFullData | tlul_assert |
| TL-06 | aKnown: channel A fields (and `a_data` for a write) are not X when `a_valid` | tlul_assert |
| TL-07 | `a_valid`, `a_ready`, `d_valid`, `d_ready` are not X after reset | tlul_assert |
| TL-08 | Channel A is stable while `a_valid` is high and `a_ready` is low (valid and every field) / kênh A ổn định đến khi `a_ready` | TL-UL timing diagrams, tlul_assert |
| TL-09 | pendingReqPerSrc: one outstanding request / một request đang chạy | tlul_assert |
| TL-10 | respMustHaveReq: a response needs an accepted request (same cycle allowed) | tlul_assert |
| TL-11 | respOpcode: AccessAckData for Get, AccessAck otherwise | tlul_assert |
| TL-12 | `d_source` equals the `a_source` of the request | tlul_assert |
| TL-13 | respSzEqReqSz and legalDParam: `d_size` equals `a_size`, `d_param` is 0 | tlul_assert |
| TL-14 | dKnown: channel D fields are not X when `d_valid` | tlul_assert |
| TL-15 | `d_ready` is high from the first cycle after reset | BRIDGE DEC-010 |
| TL-16 | A request starts only the cycle after an APB Setup phase / request chỉ bắt đầu sau Setup | BRIDGE DEC-002 |
| TL-17 | `a_source` is the constant `PARA_SRC_ID` | BRIDGE REQ-IF-005 |
| TL-18 | 4-byte size, full mask, Get or PutFullData, `a_user` is 0 | BRIDGE REQ-FUNC-002/003, DEC-004 |
| TL-19 | In reset `a_valid` and `d_ready` are LOW | TileLink 3.2.2, REQ-RESET-001 |
| CROSS-01 | The APB completion reflects the TL-UL response: `PSLVERR` = (`d_error` or wrong opcode or wrong source), `PRDATA` = read data or 0 on an error | BRIDGE REQ-ERR-003..005, REQ-FUNC-006 |
| CROSS-02 | An illegal APB request (strobe not 4'b1111 on a write, or misaligned address) gives no TL-UL request and `PREADY` with `PSLVERR` in the next cycle | BRIDGE REQ-ERR-001/002, REQ-PERF-003 |
| CROSS-03 | A legal APB request becomes the matching TL-UL request (opcode, address, write data) in the next cycle | BRIDGE REQ-FUNC-001..003 |

## How strong is it / Mức độ hiệu quả

**EN:** The assertions were run against 15 deliberately injected RTL bugs; each bug was caught by at least one assertion (for example an accepted illegal strobe or misaligned address by CROSS-02, the read data not cleared on an error by CROSS-01, a wrong `a_mask` or `a_size` by TL-03/TL-18, a dropped `a_valid` by TL-08, `d_ready` stuck low by TL-15, a broken back-to-back transfer by APB-12, `PSLVERR` held without `PREADY` by APB-08, `PREADY` for two cycles by APB-13, a changed `a_source` by TL-12/TL-17). Two further mutations were equivalent to the original design and changed no behavior. Not covered: formal proof, functional coverage, and rules that need a second TL-UL source or multi-beat bursts (this bridge issues neither).

**VI:** Các assertion đã được chạy với 15 lỗi RTL cố ý chèn; mỗi lỗi đều bị ít nhất một assertion bắt (ví dụ nhận strobe sai hoặc địa chỉ lệch bị CROSS-02 bắt, dữ liệu đọc không bị xoá khi lỗi bị CROSS-01 bắt, `a_mask` hoặc `a_size` sai bị TL-03/TL-18 bắt, `a_valid` bị hạ sớm bị TL-08 bắt, `d_ready` kẹt thấp bị TL-15 bắt, hỏng back-to-back bị APB-12 bắt, `PSLVERR` giữ khi không có `PREADY` bị APB-08 bắt, `PREADY` hai chu kỳ bị APB-13 bắt, `a_source` đổi bị TL-12/TL-17 bắt). Hai đột biến khác tương đương thiết kế gốc nên không đổi hành vi. Chưa có: formal, functional coverage, và các luật cần nhiều source TL-UL hoặc burst nhiều beat (cầu này không phát cả hai).
