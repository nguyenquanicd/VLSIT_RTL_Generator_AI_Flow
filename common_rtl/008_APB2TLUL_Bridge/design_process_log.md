# APB4 ↔ TL-UL bridge: design process log (spec and RTL) / Nhật ký thiết kế cầu APB4 ↔ TL-UL (spec và RTL)

**EN:** This document records, step by step, the work with two skills, `vlsit-asic-ip-microspec` (specification) and `vlsit-rtl-generator` (RTL), together with the important discussions and decisions. Skill updates are left out. All dates are 2026-10-18.

**VI:** Tài liệu này ghi lại từng bước làm việc với hai skill `vlsit-asic-ip-microspec` (viết spec) và `vlsit-rtl-generator` (sinh RTL), cùng các thảo luận và quyết định quan trọng. Các phần cập nhật skill không được ghi ở đây. Mọi mốc ngày là 2026-10-18.

Final deliverables are in `Output\apb_tlul_bridge\` / Sản phẩm cuối nằm trong `Output\apb_tlul_bridge\`:

| Item / Thành phần | Path / Đường dẫn |
|---|---|
| Specification / Spec | `m_apb_tlul_bridge_Design_Specification.md` |
| Figures (block diagram, waveforms) / Hình (sơ đồ khối, waveform) | `figures\` |
| Reference IP research / Nghiên cứu IP tham khảo | `research\reference_ip_log.md` |
| RTL | `rtl\m_apb_tlul_bridge.sv`, `rtl\m_apb_if.sv`, `rtl\m_tlul_if.sv`, `rtl\filelist.f` |
| RTL check logs / Log kiểm tra RTL | `rtl\rtl_check_report.md`, `rtl\lint_verilator.log`, `rtl\lint_slang.log` |

---

## Part A. Writing the spec with `vlsit-asic-ip-microspec` / Phần A. Viết spec với `vlsit-asic-ip-microspec`

### A1. Initial request / Yêu cầu ban đầu

**EN:** Design a converter between APB4 and TL-UL (the TileLink of OpenTitan):

- APB4 is a subordinate (Completer) that receives requests from one master.
- TL-UL is a manager (host) that drives one external TL-UL subordinate.
- Low latency.
- Every output toward the buses comes directly from a flip-flop.
- A single clock domain.
- APB-facing logic and TL-UL-facing logic are clearly separated.

**VI:** Thiết kế bộ chuyển đổi giữa APB4 và TL-UL (TileLink của OpenTitan):

- APB4 là subordinate (Completer), nhận request từ một master.
- TL-UL là manager (host), lái một TL-UL subordinate bên ngoài.
- Độ trễ thấp.
- Mọi tín hiệu ngõ ra ra bus đi thẳng từ flip-flop.
- Một miền clock duy nhất.
- Logic phía APB và logic phía TL-UL tách rõ.

### A2. Preparation (skill steps 1 to 4) / Chuẩn bị (bước 1 đến 4 của skill)

**EN:**
- Read the skill `rule.md` (23 rules, R-001 to R-023), found Python 3.12 and checked the environment: `openpyxl`, `PyMuPDF` and `tectonic` (LaTeX diagrams) are available.
- The skill ships an APB4↔TL-UL example, but its Q&A is **simulated**, so the questions were asked again to you. The example was used only as a structural reference.
- The OpenTitan TL-UL document was already in `reference/md_doc`. **The APB document was missing**, and Arm blocks scripted downloads (HTTP 403). Under R-006 every protocol statement must come from a converted standard.

**VI:**
- Đọc `rule.md` của skill (23 rule, R-001 đến R-023), tìm Python 3.12 và kiểm tra môi trường: có `openpyxl`, `PyMuPDF` và `tectonic` (sơ đồ LaTeX).
- Skill có sẵn ví dụ APB4↔TL-UL, nhưng phần hỏi đáp trong ví dụ là **mô phỏng**, nên các câu hỏi được hỏi lại với bạn thật. Ví dụ chỉ dùng làm tham khảo cấu trúc.
- Tài liệu TL-UL của OpenTitan đã có trong `reference/md_doc`. **Tài liệu APB chưa có**, và Arm chặn tải bằng script (HTTP 403). Theo R-006, mọi câu về giao thức phải lấy từ tài liệu chuẩn đã chuyển Markdown.

### A3. Q&A round 1 / Vòng hỏi đáp 1

| # | Topic / Nội dung | Options offered / Phương án đưa ra | Your choice / Bạn chọn |
|---|---|---|---|
| 1 | APB4 document source / Nguồn tài liệu APB4 | A: you download the PDF; B: automatic download; C: write first, mark "unverified"; D: other / A: bạn tải PDF; B: tải tự động; C: viết trước, đánh dấu "chưa kiểm chứng"; D: khác | **B**, with the note that the web page must be accessed slowly like a human / kèm lưu ý truy cập trang web chậm như người thật |
| 2 | Latency architecture with flop outputs / Kiến trúc độ trễ với ngõ ra từ flop | A: "early launch" (capture the request at the end of SETUP); B: launch in ACCESS (exactly 1 cycle slower) / A: "phóng sớm"; B: phóng ở pha ACCESS (chậm hơn đúng 1 chu kỳ) | **A** |
| 3 | Mapping `PSTRB` and address to `a_opcode`, `a_mask`, `a_size` / Chuyển `PSTRB` và địa chỉ sang `a_opcode`, `a_mask`, `a_size` | A: only masks of the OpenTitan set, otherwise `PSLVERR`; B: pass `PSTRB` straight to `a_mask` / A: chỉ nhận mask trong tập OpenTitan, còn lại `PSLVERR`; B: chuyển thẳng | **A, but accept full strobe only**, and state it clearly in the spec / **A, nhưng chỉ nhận full strobe**, ghi rõ trong spec |
| 4 | `a_source` and `a_user` | A: constant `a_source`, fixed `a_user`, no integrity; B: generate integrity / A: `a_source` hằng, `a_user` cố định, không sinh integrity; B: sinh integrity | **A** |

**EN – Why these decisions:**
- **Early launch (#2).** APB drives `PADDR`, `PWRITE`, `PWDATA` and `PSTRB` from the SETUP phase and holds them until the transfer ends (APB spec sections 3.1, 4.1, Appendix A). So the bridge captures the request straight into the channel A flops at the end of the SETUP cycle, and `a_valid` (from a flop) is high in the first ACCESS cycle. Timeline: S (setup) → A1 (`a_valid`, accepted) → A2 (`d_valid`, captured into flops) → A3 (`PREADY` and `PRDATA` from flops): 1 SETUP cycle plus 3 ACCESS cycles (2 wait states) with a prompt device.
- **Full strobe only (#3).** Any write with `PSTRB` other than `4'b1111`, and any access with `PADDR[1:0]` not zero, returns `PSLVERR` with no TL-UL request. Consequence: no byte or half-word writes through this bridge. The limitation is stated prominently at the top of the spec.
- **Bus integrity (#4).** The "Bus Integrity Scheme" section of the TL-UL document says "To be filled in", so the bridge does not generate integrity. Consequence: an OpenTitan device that checks integrity may return `d_error` for every access. This is recorded as open item OI-001.

**VI – Lý do các quyết định:**
- **Phóng sớm (#2).** APB lái `PADDR`, `PWRITE`, `PWDATA`, `PSTRB` từ pha SETUP và giữ đến khi transfer kết thúc (tài liệu APB: mục 3.1, 4.1, Phụ lục A). Vì vậy cầu chốt thẳng request vào flop kênh A ở cuối chu kỳ SETUP, và `a_valid` (từ flop) lên 1 ngay chu kỳ ACCESS đầu. Timeline: S → A1 (`a_valid`, được nhận) → A2 (`d_valid`, chốt vào flop) → A3 (`PREADY`, `PRDATA` từ flop): 1 chu kỳ SETUP cộng 3 chu kỳ ACCESS (2 wait state) khi thiết bị phản hồi nhanh.
- **Chỉ nhận full strobe (#3).** Mọi lần ghi có `PSTRB` khác `4'b1111`, và mọi truy cập có `PADDR[1:0]` khác 0, trả `PSLVERR` mà không phát request TL-UL. Hệ quả: không có byte hay half-word write qua cầu này. Giới hạn này được ghi nổi bật ở đầu spec.
- **Bus integrity (#4).** Mục "Bus Integrity Scheme" của tài liệu TL-UL ghi "To be filled in", nên cầu không sinh integrity. Hệ quả: thiết bị OpenTitan có kiểm tra integrity có thể trả `d_error` cho mọi access. Ghi là open item OI-001.

### A4. Getting the APB document (step 4) / Lấy tài liệu APB (bước 4)

**EN:**
- Through the Arm page, the static link of **IHI 0024 Issue D** was found (Issue E is newer). Issue D was chosen because the VLSIT RTL rule document cites exactly this issue.
- Under R-009 the skill stated the file name, source, size (416,189 bytes) and licence before downloading. You agreed and the file was downloaded with curl.
- It was converted to Markdown and verified page by page (`verify`), the header records `redistribution: forbidden`, and the file is listed in `.gitignore` (R-007, R-008). Only the Markdown is kept in the repository, not the PDF.
- APB clauses used as design basis: Appendix A (signals valid from SETUP), 3.1 (signals stable until completion), 3.2 (`PSTRB` low on reads), 3.4 (`PSLVERR` valid only in the last cycle), Figure 4-1 (ACCESS goes directly to SETUP when another transfer follows).

**VI:**
- Qua trang Arm tìm được static link của **IHI 0024 Issue D** (Issue E mới hơn). Chọn Issue D vì tài liệu quy tắc RTL của VLSIT trích đúng issue này.
- Theo R-009, skill báo tên file, nguồn, kích thước (416.189 byte) và giấy phép trước khi tải. Bạn đồng ý và file được tải bằng curl.
- Chuyển sang Markdown, kiểm tra từng trang (`verify`), header ghi `redistribution: forbidden` và file nằm trong `.gitignore` (R-007, R-008). Repo chỉ giữ bản Markdown, không giữ PDF.
- Các điều khoản APB làm căn cứ thiết kế: Phụ lục A (tín hiệu hợp lệ từ SETUP), 3.1 (tín hiệu ổn định đến khi xong), 3.2 (`PSTRB` thấp khi đọc), 3.4 (`PSLVERR` chỉ hợp lệ ở chu kỳ cuối), Hình 4-1 (ACCESS chuyển thẳng sang SETUP khi còn transfer kế).

### A5. Q&A round 2 / Vòng hỏi đáp 2

| # | Topic / Nội dung | Options / Phương án | Your choice / Bạn chọn |
|---|---|---|---|
| 1 | Agree to download APB Issue D / Đồng ý tải APB Issue D | A: Issue D; B: Issue E; C: other / A: Issue D; B: Issue E; C: khác | **A** (agreed / đồng ý) |
| 2 | When the TL-UL device never answers / Khi thiết bị TL-UL không bao giờ trả lời | A: wait forever; B: optional timeout with a drain state (recommended); C: other / A: chờ vô hạn; B: timeout tùy chọn có trạng thái drain (đề xuất); C: khác | **A** |
| 3 | `PRDATA` on error / `PRDATA` khi lỗi | A: `PRDATA = 0`, `PSLVERR = 1`; B: `PRDATA = d_data` | **A** |

**EN:** Notable decision: **no timeout** (you chose A although the skill recommended B). Your reason: the SoC watchdog handles a hung device. Consequence: the APB master waits forever if the device never answers; recorded in the spec as ERR-006 and DEC-003.

**VI:** Quyết định đáng chú ý: **không có timeout** (bạn chọn A dù skill đề xuất B). Lý do của bạn: watchdog của SoC sẽ xử lý thiết bị treo. Hệ quả: master APB chờ vô hạn nếu thiết bị không trả lời; ghi trong spec là ERR-006 và DEC-003.

### A6. Reference IP research (step 5) / Nghiên cứu IP tham khảo (bước 5)

**EN:**
- 7 keywords (including Chinese) on GitHub and Gitee with `ip_search.py`.
- 3 candidates, all **excluded**: two copies of `vyges/tlul-apb-adapter` (no licence, no tapeout evidence, and the opposite direction TL-UL → APB) and `merledu/common_peripheral_ips` (not a bridge, no evidence).
- Conclusion: no IP meets the evidence filter R-010, so none is used and none was downloaded. Log: `research\reference_ip_log.md`.

**VI:**
- 7 từ khóa (kể cả tiếng Trung) trên GitHub và Gitee bằng `ip_search.py`.
- Có 3 ứng viên, đều **bị loại**: hai bản `vyges/tlul-apb-adapter` (không có licence, không có bằng chứng tapeout, và là chiều ngược TL-UL → APB) và `merledu/common_peripheral_ips` (không phải bridge, không có bằng chứng).
- Kết luận: không IP nào đạt chuẩn bằng chứng R-010, nên không dùng và không tải IP nào. Log: `research\reference_ip_log.md`.

### A7. Q&A round 3 (open points) / Vòng hỏi đáp 3 (các điểm còn mở)

| # | Topic / Nội dung | Your choice / Bạn chọn |
|---|---|---|
| 1 | Reset: asynchronous active-low, outputs 0 after reset / Reset bất đồng bộ active-low, các output về 0 sau reset | **A** |
| 2 | `d_ready`: held at 1 continuously / giữ bằng 1 liên tục | **A** |
| 3 | Abnormal response (wrong `d_source`, `d_opcode`...) / Response bất thường | **B**: the bridge checks `d_source` and `d_opcode`, a mismatch gives `PSLVERR = 1` / cầu kiểm tra `d_source` và `d_opcode`, sai thì `PSLVERR = 1` |
| 4 | Parameters: `PARA_ADDR_W`, `PARA_SRC_W`, `PARA_SRC_ID`, `PARA_A_USER`; fixed 32-bit data / Tham số; dữ liệu cố định 32 bit | **A** |

**EN – Consequences:**
- `d_ready` is a flop reset to 0 whose D input is 1. This satisfies both "outputs 0 after reset" (#1) and "`d_ready` always 1" (#2): `d_ready` becomes 1 at the first clock edge after reset release.
- Choosing 3B means the RTL must handle a wrong `d_source` or `d_opcode`. Round 4 clarified how.

**VI – Hệ quả:**
- `d_ready` là một flop reset về 0 với ngõ D bằng 1. Nhờ vậy thỏa cả "output về 0 sau reset" (#1) lẫn "`d_ready` luôn 1" (#2): `d_ready` lên 1 ở cạnh clock đầu tiên sau khi nhả reset.
- Chọn 3B nghĩa là RTL phải xử lý `d_source` hoặc `d_opcode` sai. Vòng 4 làm rõ cách xử lý.

### A8. Q&A round 4 / Vòng hỏi đáp 4

| # | Topic / Nội dung | Your choice / Bạn chọn |
|---|---|---|
| 1 | Response errors: `PSLVERR = 1`, `PRDATA = 0`; a sticky flag only for simulation, not a port / Lỗi response: `PSLVERR = 1`, `PRDATA = 0`; cờ giữ lỗi chỉ để quan sát khi mô phỏng | **A** |
| 2 | Latency target in the spec: 3 ACCESS cycles with a prompt device (hard), 2 when the response comes in the acceptance cycle / Mục tiêu latency: 3 chu kỳ ACCESS khi thiết bị phản hồi nhanh (cứng), 2 khi response cùng chu kỳ nhận | **A** |
| 3 | Verification plan: directed + constrained-random + SVA, **no** formal / Kế hoạch verification: directed + constrained-random + SVA, **không** formal | **A** |
| 4 | "Not required" sections: CDC (7.2), power intent (7.4), memory (10.5), registers (11), detailed DFT (16), security/safety (18) / Các mục không cần | **A** |

### A9. Writing the spec (steps 7 to 10) / Viết spec (bước 7 đến 10)

**EN:**
- Initialized with `spec_tool.py init` (22 sections) and filled in the VLSIT template: requirements with `REQ-<AREA>-<NNN>` IDs, verification method, traceability table, decisions `DEC-xxx` and assumptions `ASM-xxx` in section 20. Protocol statements cite the documents in `md_doc`.
- Figures: block diagram (JSON → LaTeX/TikZ with `block_diagram.py`, built with tectonic) and waveforms (WaveJSON → SVG): successful write, successful read, error from the response, local error, channel A back pressure. The figures were reviewed on rendered images and fixed in a few places (label spacing, footer length).
- `spec_tool.py check` reports PASS (0 errors). An extra script cross-checked that every referenced `REQ`, `TEST`, `SVA`, `COV` and `DEC` is defined and that the traceability table matches the requirement table.

**VI:**
- Khởi tạo bằng `spec_tool.py init` (22 mục) và điền theo mẫu VLSIT: yêu cầu có ID `REQ-<AREA>-<NNN>`, phương pháp kiểm chứng, bảng truy vết, quyết định `DEC-xxx` và giả định `ASM-xxx` ở mục 20. Các điểm giao thức trích tài liệu trong `md_doc`.
- Hình: sơ đồ khối (JSON → LaTeX/TikZ bằng `block_diagram.py`, dựng bằng tectonic) và waveform (WaveJSON → SVG): ghi thành công, đọc thành công, lỗi từ response, lỗi cục bộ, back pressure kênh A. Các hình được xem lại trên ảnh render và sửa vài chỗ (khoảng cách nhãn, độ dài chú thích).
- `spec_tool.py check` báo PASS (0 lỗi). Một script phụ kiểm tra chéo: mọi `REQ`, `TEST`, `SVA`, `COV`, `DEC` được tham chiếu đều có định nghĩa và bảng truy vết khớp bảng yêu cầu.

**EN – Main design points of the spec:**
- **Two modules:** `m_apb_if` (all APB logic) and `m_tlul_if` (all TL-UL logic), connected only by internal wires (one request bundle, one response bundle). The top is a structural wrapper.
- **APB FSM:** IDLE, BUSY, DONE. **TL-UL FSM:** IDLE, REQ, WAIT.
- **Setup is detected by level** (`PSEL = 1` and `PENABLE = 0` while the FSM is idle), not by an edge of `PSEL`.
- **Latency:** 3 ACCESS cycles when the device accepts in A1 and answers in A2; 2 cycles when it answers in the acceptance cycle; 1 cycle for a local error (`PREADY` rises in the first ACCESS cycle).
- **Minimum Setup-to-Setup interval:** 4 cycles (normal), 3 (same-cycle response), 2 (local error). This is a protocol limit: the address of the next transfer is valid only from its own Setup cycle.
- **Result:** 22 sections, 29 requirements in the first version (31 after back-to-back), test plan TEST-001 to TEST-019, SVA-001 to SVA-010, COV-001 to COV-005.

**VI – Điểm thiết kế chính của spec:**
- **Hai module:** `m_apb_if` (toàn bộ logic APB) và `m_tlul_if` (toàn bộ logic TL-UL), nối nhau chỉ bằng dây nội bộ (một bó request, một bó response). Top là wrapper cấu trúc.
- **FSM APB:** IDLE, BUSY, DONE. **FSM TL-UL:** IDLE, REQ, WAIT.
- **Phát hiện Setup bằng mức** (`PSEL = 1` và `PENABLE = 0` khi FSM rảnh), không dùng cạnh của `PSEL`.
- **Latency:** 3 chu kỳ ACCESS khi thiết bị nhận ở A1 và trả lời ở A2; 2 chu kỳ khi trả lời cùng chu kỳ nhận; 1 chu kỳ cho lỗi cục bộ (`PREADY` lên ngay chu kỳ ACCESS đầu).
- **Khoảng cách Setup đến Setup tối thiểu:** 4 chu kỳ (bình thường), 3 (response cùng chu kỳ), 2 (lỗi cục bộ). Đây là giới hạn giao thức: địa chỉ transfer kế chỉ hợp lệ từ chu kỳ Setup của nó.
- **Kết quả:** 22 mục, 29 yêu cầu ở bản đầu (31 sau khi thêm back-to-back), kế hoạch kiểm chứng TEST-001 đến TEST-019, SVA-001 đến SVA-010, COV-001 đến COV-005.

### A10. Author choices you confirmed (five answers) / Các điểm tác giả tự chọn, bạn xác nhận (năm câu trả lời)

| # | Author's choice / Điểm tự chọn | Your answer / Câu trả lời | Result in spec / Kết quả trong spec |
|---|---|---|---|
| 1 | Constant outputs (`a_param`, `a_size`, `a_mask`, `a_source`, `a_user`, `a_opcode[1:0]`, `a_address[1:0]`) are tie-offs, not flops / Output hằng là tie-off, không phải flop | "Tie-off, no flip-flop needed" / "Tie-off, không cần flip-flop" | DEC-005: the "every output from a flop" rule applies to every output that can change / quy tắc "mọi output từ FF" áp cho mọi output có thể đổi |
| 2 | Drop ports `d_param`, `d_size`, `d_sink`, `d_user` / Bỏ các port này | "May create the ports but not use them" / "Có thể tạo port nhưng không dùng" | DEC-006: all TL-UL ports kept, no logic reads them / giữ đủ port TL-UL, không logic nào đọc |
| 3 | Add `PARA_A_USER_W` | "Approved, but since it is unused make the default width the lowest" / "Duyệt, nhưng không dùng nên mặc định bit width thấp nhất" | Default 1; `PARA_D_SINK_W` and `PARA_D_USER_W` added with default 1 / mặc định 1; thêm `PARA_D_SINK_W`, `PARA_D_USER_W` mặc định 1 |
| 4 | Sticky error flag / Cờ lỗi sticky | "Right, no sticky flag in the RTL" / "Đúng, trong RTL không có cờ giữ" | DEC-009: only a counter in the verification environment / chỉ có bộ đếm ở môi trường verification |
| 5 | Payload flops without reset / Flop payload không reset | "Add reset, set value 0" / "Thêm reset và gài trị 0" | DEC-013: every flop has asynchronous reset to 0, including `reg_a_rd`, `reg_a_addr`, `reg_a_data` / mọi flop reset bất đồng bộ về 0 |

### A11. Adding back-to-back transfers / Bổ sung transfer liên tiếp (back-to-back)

**EN:** You asked for back-to-back APB transfers where `PSEL` stays high and only `PENABLE` toggles, with a clear waveform.
- **No architecture change was needed**, because Setup is detected by level when the FSM is idle. The PREADY cycle of a transfer is the cycle in which the FSM is in DONE; in the very next cycle the FSM is back in IDLE, which is exactly the Setup cycle of the next transfer.
- **Added to the spec:** FEAT-006; REQ-FUNC-008 (Setup by level, every combination of read, write and error) and REQ-PERF-004 (same minimum interval as with a gap); decision DEC-014; TEST-019; SVA-010; COV-005; descriptions in sections 5.3, 6.3, 10.3, 10.4.
- **Waveform:** Figure 6-4 (`figures\apb_back_to_back.svg`): a full-strobe write, a read, then a write with `PSTRB = 4'b0011` that gets a local error, with `PSEL` held high; the Setup cycles are 4 cycles apart.
- Figure 4-1 of the APB document confirms the direct ACCESS → SETUP transition.

**VI:** Bạn yêu cầu hỗ trợ transfer APB liên tiếp mà `PSEL` giữ nguyên, chỉ `PENABLE` đổi mức, kèm waveform rõ ràng.
- **Không phải đổi kiến trúc**, vì Setup được phát hiện bằng mức khi FSM rảnh. Chu kỳ PREADY của transfer trước là chu kỳ FSM ở DONE; chu kỳ ngay sau đó FSM đã về IDLE, đúng lúc là chu kỳ Setup của transfer kế.
- **Thêm vào spec:** FEAT-006; REQ-FUNC-008 (Setup theo mức, mọi tổ hợp đọc, ghi, lỗi) và REQ-PERF-004 (cùng khoảng cách tối thiểu như khi có khoảng trống); quyết định DEC-014; TEST-019; SVA-010; COV-005; mô tả ở mục 5.3, 6.3, 10.3, 10.4.
- **Waveform:** Figure 6-4 (`figures\apb_back_to_back.svg`): ghi full-strobe, đọc, rồi ghi `PSTRB = 4'b0011` bị lỗi cục bộ, với `PSEL` giữ cao; các Setup cách nhau 4 chu kỳ.
- Hình 4-1 của tài liệu APB xác nhận chuyển thẳng ACCESS → SETUP.

---

## Part B. Generating the RTL with `vlsit-rtl-generator` / Phần B. Sinh RTL với `vlsit-rtl-generator`

### B1. Reading the rules and scanning the spec / Đọc rule và quét spec

**EN:**
- Read the full `VLSIT_RTL_Design_Rule.md` v2 (from `VLSIT_RTL_Generator_AI_Model\spec_template`, identical to the copy in the skill).
- `vlsit_spec_gaps.py gaps` reported 2 BLOCK gaps and 5 INFO. Neither BLOCK gap changes behavior:
  - G-001: section 8 still contains the word "TBD" (reference to TBD-001, the unknown `a_user` layout).
  - G-005: synthesis libraries and corners are chosen by the integrator.
- Tool check: Verilator and slang are available in the OSS CAD Suite.

**VI:**
- Đọc đầy đủ `VLSIT_RTL_Design_Rule.md` v2 (từ `VLSIT_RTL_Generator_AI_Model\spec_template`, trùng bản trong skill).
- `vlsit_spec_gaps.py gaps` báo 2 gap BLOCK và 5 INFO. Cả hai BLOCK đều không đổi hành vi:
  - G-001: mục 8 còn chữ "TBD" (tham chiếu TBD-001, layout `a_user` chưa biết).
  - G-005: thư viện và corner synthesis do integrator chọn.
- Kiểm tra công cụ: có Verilator và slang trong OSS CAD Suite.

### B2. Questions and answers before writing RTL / Câu hỏi và trả lời trước khi viết RTL

| # | Topic / Nội dung | Answer / Trả lời |
|---|---|---|
| 1 | G-001: treat `PARA_A_USER_W` (default 1) as settled / coi `PARA_A_USER_W` là đã chốt | **A**, plus: `o_tlul_a_user = '0` (valid SystemVerilog for any `PARA_A_USER_W`) / kèm: `o_tlul_a_user = '0` (hợp lệ với mọi `PARA_A_USER_W`) |
| 2 | G-005: ignore synthesis libraries for RTL, record the lint frontend in the report / bỏ qua thư viện synthesis cho RTL, ghi frontend lint vào báo cáo | **A** |
| 3 | File header data / Dữ liệu header file | Project: `VLSI Technology - AI RTL generator`; Author: `Nguyen Quan and Claude` |
| 4 | Output folder / Thư mục output | `Output\apb_tlul_bridge\rtl` |
| Module plan / Kế hoạch module | Three `.sv` files, one module per file / Ba file `.sv`, mỗi module một file | **OK** |

| Module | Content / Nội dung |
|---|---|
| `m_apb_if` | Setup detect, legality check (`PSTRB`, `PADDR[1:0]`), APB FSM (IDLE, BUSY, DONE), flops `reg_pready`, `reg_pslverr`, `reg_prdata` / phát hiện Setup, kiểm tra hợp lệ, FSM APB, các flop hoàn tất |
| `m_tlul_if` | Channel A flops, TL-UL FSM (IDLE, REQ, WAIT), flop `reg_d_ready`, channel D check, constant tie-offs / flop kênh A, FSM TL-UL, flop `reg_d_ready`, kiểm tra kênh D, các tie-off hằng |
| `m_apb_tlul_bridge` | Purely structural top: ports, parameters, internal wires, two instances / top thuần cấu trúc: port, tham số, dây nội bộ, hai instance |

### B3. Writing the RTL and checking in a loop / Viết RTL và kiểm tra theo vòng lặp

**EN:** Leaf modules first, top last. After every write, `vlsit_rtl_check.py` was run and the findings fixed:
- **First run:** 3 CMT-05 errors (comment lines over 100 characters) and 10 NAM-08 warnings. After a few rounds of shortening comments, no errors were left.
- **NAM-08:** internal signals were renamed from `address` to `addr` (for example `reg_a_addr`). 8 NAM-08 warnings remain on TL-UL ports (`source`, `address`, `error`). They are **kept**, because the names are fixed by the protocol mnemonics (NAM-02 and PRT-01).
- **Named constants:** constants such as `a_size = 2`, `a_mask = 4'b1111` and the `d_opcode` of AccessAckData are declared as `localparam`, to avoid P10 (magic numbers).
- **`o_tlul_a_user`:** first written as `PARA_A_USER[PARA_A_USER_W-1:0]` with `PARA_A_USER = '0` by default; then (at your request) the parameter **`PARA_A_USER` was removed completely** and the output is `'0`. The spec was updated to match (section 8, 6.2, REQ-IF-005, DEC-004, DEC-007, ASM-005, TBD-001).

**VI:** Viết leaf trước, top sau. Sau mỗi lần viết chạy `vlsit_rtl_check.py` và sửa:
- **Lần đầu:** 3 lỗi CMT-05 (comment dài hơn 100 ký tự) và 10 cảnh báo NAM-08. Sau vài vòng rút gọn comment, hết lỗi.
- **NAM-08:** signal nội bộ đổi `address` thành `addr` (ví dụ `reg_a_addr`). Còn 8 cảnh báo NAM-08 trên port TL-UL (`source`, `address`, `error`). **Giữ nguyên**, vì tên do mnemonic giao thức quy định (NAM-02 và PRT-01).
- **Hằng số có tên:** `a_size = 2`, `a_mask = 4'b1111`, `d_opcode` của AccessAckData khai báo bằng `localparam` để không vướng P10 (magic number).
- **`o_tlul_a_user`:** ban đầu viết `PARA_A_USER[PARA_A_USER_W-1:0]` với `PARA_A_USER = '0` mặc định; sau đó (theo yêu cầu của bạn) **bỏ hẳn tham số `PARA_A_USER`** và gán `'0`. Spec sửa theo (mục 8, 6.2, REQ-IF-005, DEC-004, DEC-007, ASM-005, TBD-001).

### B4. Final RTL check results / Kết quả kiểm tra RTL cuối cùng

| Item / Hạng mục | Result / Kết quả |
|---|---|
| `vlsit_rtl_check.py check` | PASS, 0 errors, 8 NAM-08 warnings (justified above) / PASS, 0 lỗi, 8 cảnh báo NAM-08 (có lý do) |
| Verilator (lint) | 0 errors, 5 `UNUSEDSIGNAL` warnings: the 5 intentionally unused inputs `i_apb_pprot`, `i_tlul_d_param`, `i_tlul_d_size`, `i_tlul_d_sink`, `i_tlul_d_user` (a waiver is noted in spec section 14.3) / 0 lỗi, 5 cảnh báo cho 5 input cố ý không dùng (waiver ghi ở mục 14.3 của spec) |
| slang (lint) | 0 errors, 0 warnings / 0 lỗi, 0 cảnh báo |
| Two narrow configurations (verilator: `PARA_ADDR_W` 16 and 24, `PARA_SRC_W` 1 and 5, `PARA_A_USER_W` 32 and 7) / Hai cấu hình hẹp | Lint clean / Lint sạch |
| Throwaway iverilog bench (not delivered, per R-010) / Bench iverilog tạm (không giao kèm) | PASS for the default configuration / PASS cấu hình mặc định |

**EN – The throwaway bench checked:**
- Values after reset are 0, `d_ready` rises after reset release, constants are correct.
- Write and read take exactly 3 ACCESS cycles.
- A response in the acceptance cycle gives 2 ACCESS cycles.
- Wrong strobe or misaligned address: 1 cycle, `PSLVERR = 1`, no TL-UL request.
- Back-to-back with `PSEL` held high (write, read, error, read): correct order and cycle counts.
- With `a_ready` held low, channel A stays stable and the request is accepted exactly once.

**VI – Bench tạm đã kiểm tra:**
- Giá trị sau reset là 0, `d_ready` lên 1 sau khi nhả reset, các hằng đúng.
- Ghi và đọc đúng 3 chu kỳ ACCESS.
- Response cùng chu kỳ nhận request: 2 chu kỳ ACCESS.
- Strobe sai hoặc địa chỉ lệch: 1 chu kỳ, `PSLVERR = 1`, không có request TL-UL.
- Back-to-back với `PSEL` giữ cao (ghi, đọc, lỗi, đọc): đúng thứ tự và số chu kỳ.
- Khi `a_ready` bị giữ thấp, kênh A ổn định và request được nhận đúng một lần.

**EN:** While building the bench several mistakes of the bench itself appeared (static variable initialization in a task, a device-model delay off by one cycle, wrong back-to-back stimulus, a wrong back-pressure expectation). Each was traced cycle by cycle in the log and identified as a bench error, not an RTL error.

**VI:** Khi dựng bench có nhiều lỗi của chính bench (khởi tạo biến static trong task, độ trễ mô hình thiết bị lệch 1 chu kỳ, stimulus back-to-back sai, kỳ vọng back pressure sai). Từng lỗi được lần theo từng chu kỳ trên log và xác định là lỗi bench, không phải lỗi RTL.

### B5. Not done / Chưa làm được

**EN:**
- CDC/RDC, synthesis, equivalence, STA (section 11 of the rule file).
- The real verification environment of the spec plan (APB master model, TL-UL device model, SVA, coverage).
- The narrow configurations were only linted, not simulated.
- Abnormal `d_valid` cases beyond those in the bench were not checked.

**VI:**
- CDC/RDC, synthesis, equivalence, STA (mục 11 của rule file).
- Môi trường verification thật theo kế hoạch của spec (APB master model, TL-UL device model, SVA, coverage).
- Cấu hình hẹp mới được lint, chưa mô phỏng.
- Chưa kiểm các ca `d_valid` bất thường ngoài những ca có trong bench.

---

## Part C. Points to remember when using this IP / Phần C. Điểm cần nhớ khi dùng IP này

| # | English | Tiếng Việt |
|---|---|---|
| 1 | **Full-strobe writes only** (`PSTRB = 4'b1111`) and 4-byte aligned addresses; anything else returns `PSLVERR` with no TL-UL request. | **Chỉ ghi full-strobe** (`PSTRB = 4'b1111`) và địa chỉ căn lề 4 byte; còn lại trả `PSLVERR`, không có request TL-UL. |
| 2 | **No timeout:** a hung TL-UL device hangs the APB master; an SoC watchdog is required. | **Không có timeout:** thiết bị TL-UL treo thì master APB treo; cần watchdog SoC. |
| 3 | **No bus integrity:** `a_user` is always 0. A device that checks integrity may return `d_error` (OI-001). | **Không sinh bus integrity:** `a_user` luôn bằng 0. Thiết bị có kiểm tra integrity có thể trả `d_error` (OI-001). |
| 4 | **Reset:** every flop resets asynchronously to 0; `d_ready` is 0 in reset and becomes 1 at the first edge after release. The SoC must release reset synchronously and reset the APB master and the TL-UL device together (DEP-002). | **Reset:** mọi flop reset bất đồng bộ về 0; `d_ready` bằng 0 trong reset rồi lên 1 ở cạnh đầu tiên sau khi nhả reset. SoC phải nhả reset đồng bộ và reset APB master cùng thiết bị TL-UL (DEP-002). |
| 5 | **Remaining open items:** TBD-001 (`a_user` layout), TBD-002 (frequency, area, power targets), OI-001 (integrity), OI-003 (TileLink 1.7.1 spec not downloaded), OI-004 (clock frequency range). | **Open items còn lại:** TBD-001 (layout `a_user`), TBD-002 (mục tiêu tần số, diện tích, công suất), OI-001 (integrity), OI-003 (chưa tải đặc tả TileLink 1.7.1), OI-004 (dải tần số clock). |
| 6 | **Remaining lint messages:** 5 unused inputs need a waiver; the 8 NAM-08 warnings are port names fixed by the protocol. | **Cảnh báo lint còn lại:** 5 input không dùng cần waiver; 8 cảnh báo NAM-08 là tên port do giao thức quy định. |

---

## Part D. Update for the new skill rules (2026-10-21) / Phần D. Cập nhật theo rule mới của skill (2026-10-21)

**EN:** The skill `vlsit-asic-ip-microspec` gained two rules, so the spec was updated and re-checked with `vlsit_spec_tool.py check` (PASS).
- **Signal description table (R-025).** The port table of section 6.2 now has a "Meaning (function)" column, the clock domain, and a new **Signal type** column for all 32 ports. Only `o_apb_pready` is a pulse (1 cycle per transfer); the other control signals are levels; data signals name the qualifier that makes them valid; the constants are static; the five unused inputs are marked "ignored".
- **Waveform plan (R-024).** Nine waveforms were proposed from sections 6.3 and 10.2 and **confirmed by you on 2026-10-21 ("proposed list")**: the six existing ones (write, read, local error, TL-UL error response, channel A back pressure, back-to-back with `PSEL` held) plus three new ones: response in the acceptance cycle (2 Access cycles), reset and the first cycles after release (`d_ready` 0 then 1), and an orphan response discarded. The plan table is at the start of section 10.3 (WF-001 to WF-009) and the three new images are Figure 10-1 to 10-3 (`figures\apb_write_same_cycle`, `reset_sequence`, `tlul_orphan_response`).

**VI:** Skill `vlsit-asic-ip-microspec` có thêm hai rule, nên spec được cập nhật và kiểm lại bằng `vlsit_spec_tool.py check` (PASS).
- **Bảng mô tả tín hiệu (R-025).** Bảng port ở mục 6.2 giờ có cột "Meaning (function)", clock domain, và cột mới **Signal type** cho cả 32 port. Chỉ `o_apb_pready` là pulse (1 chu kỳ mỗi transfer); các tín hiệu điều khiển khác là level; tín hiệu data ghi rõ điều kiện hợp lệ; các hằng là static; năm input không dùng ghi "ignored".
- **Kế hoạch waveform (R-024).** Chín waveform được đề xuất từ mục 6.3 và 10.2 và **bạn đã xác nhận ngày 2026-10-21 ("danh sách đề xuất")**: sáu waveform sẵn có (ghi, đọc, lỗi cục bộ, response lỗi TL-UL, back pressure kênh A, back-to-back với `PSEL` giữ cao) cộng ba waveform mới: response cùng chu kỳ nhận (2 chu kỳ Access), reset và các chu kỳ đầu sau khi nhả (`d_ready` 0 rồi 1), và orphan response bị bỏ qua. Bảng kế hoạch nằm đầu mục 10.3 (WF-001 đến WF-009), ba hình mới là Figure 10-1 đến 10-3 (`figures\apb_write_same_cycle`, `reset_sequence`, `tlul_orphan_response`).
