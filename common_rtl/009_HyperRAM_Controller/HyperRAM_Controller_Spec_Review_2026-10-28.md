# Review: skill `vlsit-asic-ip-microspec` và spec `009_HyperRAM_Controller` (2026-10-28)

Tài liệu review, viết bằng tiếng Việt để thảo luận. Chưa sửa spec nào. Mọi con số datasheet lấy từ các file Markdown trong `reference/md_doc/` của thư mục này.

**Bản v2 (cùng ngày):** đã đọc đủ năm datasheet (Infineon S80KS2562 và S80KS2564, Winbond W958D8NBYA và W958D6NBKX, ISSI IS66WVH32M8DALL), thêm Phụ lục A (bảng timing và latency theo OPN) và sửa các nhận xét v1: A1 (tCSM) hạ từ "sai" xuống "quyết định cần xem lại", thêm phát hiện về lỗi chuyển đổi Winbond, về tCSHI của ISSI, về tDSV, và cập nhật giá trị mặc định đề xuất.

Mục lục: 1. Review skill. 2. Phân tích spec 009. 3. Nhận xét về spec (sai, chưa rõ, thiếu). 4. Đề xuất cho yêu cầu "nhiều loại RAM, hiệu năng cao, latency thấp, timing cấu hình bằng SW". 5. Câu hỏi cần thảo luận.

---

## 1. Review skill `vlsit-asic-ip-microspec`

### 1.1 Đã đọc / đã chạy

`SKILL.md`, `rule.md` (R-001 đến R-031), `reference/`, toàn bộ `scripts/` (biên dịch được bằng `py_compile`), `vlsit_spec_tool.py check` trên 10 spec của `common_rtl`. Chưa chạy trên Linux (chỉ có Windows); chưa chạy `vlsit_ip_search`, `vlsit_pdf_to_md` ở lượt này.

Kết quả `check` trên 10 spec: 8 PASS, `001_AsyncGrayFIFO` FAIL 43 lỗi (spec cũ), `008_APB2TLUL_Bridge` FAIL 1 lỗi. **009 PASS dù có nhiều lỗ hổng lớn** (xem 1.3).

### 1.2 Điểm tốt

- Quy trình 12 bước rõ, có cổng xác nhận của người dùng (naming rule, waveform plan, tải tài liệu, độ phủ interface).
- Rule có ID cố định, mỗi rule có Why và Check; `check` bắt được thiếu section, placeholder `<...>`, thiếu REQ trong bảng truy vết, tên cổng sai quy tắc, waveform plan thiếu hình/nguồn.
- Phần draw.io mới (R-018 đến R-020, R-027 đến R-029) có script `build` chạy được chuỗi vẽ, validate thư viện, geometry check, SVG; đã chạy thật trên 5 spec.
- Quy định về chuẩn có bản quyền (chỉ giữ Markdown, `.gitignore`) rõ.

### 1.3 Vấn đề (xếp theo mức độ)

**Cao**

| # | Vấn đề | Bằng chứng | Đề xuất |
|---|---|---|---|
| S1 | `check` không phát hiện spec chưa hoàn chỉnh. Spec 009 PASS dù: 78 chữ TBD, mục 5.3, 5.4, 10.4 rỗng, mục 6.2 **không có cổng AXI**, không có cổng CK/CS#, còn nguyên các đoạn hướng dẫn của template (ví dụ "Describe the main blocks...", "List conditions that must always hold"). | `check` 009 = PASS 0 error; `sections` báo 11 mục ở trạng thái TBD | Thêm chế độ `check --ready` (hoặc mặc định): lỗi khi còn TBD không có ID ở mục 20 (R-014 đã yêu cầu), còn câu hướng dẫn của template, mục rỗng, interface ở 6.1 không có cổng ở 6.2, bộ tín hiệu protocol thiếu so với danh mục |
| S2 | Không kiểm tra tham chiếu chéo TEST/SVA/COV. Bảng truy vết của 009 dùng `TEST-FUNC-001`, `TEST-IF-001`... nhưng mục 15 chỉ định nghĩa `TEST-001`. | grep trong spec 009 | `check`: mọi ID TEST/SVA/COV được nhắc đến phải có định nghĩa ở mục 15 và mọi REQ phải có ít nhất một test; đã làm được cho REQ nhưng chưa làm cho TEST |
| S3 | R-005 (spec bằng tiếng Anh) không được kiểm. Spec 009 có 35 dòng tiếng Việt (mục 1.1, 2.2, 4, 6.1, glossary song ngữ). | grep ký tự có dấu | `check`: cảnh báo/lỗi khi gặp ký tự tiếng Việt ngoài khối ghi chú; hoặc ghi vào rule rằng song ngữ được phép và sửa R-005 |
| S4 | Rule R-031 yêu cầu mục 11.1, 11.3, 11.4 được điền; spec 009 chỉ có 11.1 và 11.2 mà `check` vẫn PASS. | Mục lục 009 và `SKILL.md` bước 9 | `check` thêm: nếu có workbook CSR thì phải có 11.3 và 11.4 |
| S5 | `SKILL.md` bước 10 mục 3 còn nội dung cũ: "If no LaTeX compiler exists ... ask whether to use draw.io", mâu thuẫn với R-018 (draw.io là mặc định). | Dòng cuối mục 3 bước 10 | Sửa câu cho khớp R-018 |

**Trung bình**

| # | Vấn đề | Đề xuất |
|---|---|---|
| S6 | Thứ tự rule trong `rule.md` rối (R-030, R-031 chen giữa R-016 và R-025; R-024 sau R-029). ID đúng là cố định nhưng người đọc khó tìm. | Thêm bảng mục lục ở đầu `rule.md` (ID, tên, nhóm) thay vì đánh số lại |
| S7 | R-007 nói `verify` phải báo OK, nhưng với AXI (500 trang) `verify` luôn báo CHECK (53 trang lệch trên 5% số từ, chủ yếu bảng và hình). Chưa có quy định xử lý. | Bổ sung vào R-007: kết quả CHECK chấp nhận được nếu các trang lệch được người vận hành kiểm tay và ghi vào header; thêm tham số ngưỡng cho `verify` |
| S8 | Thư viện chuẩn của skill (`md_doc`) chỉ có APB, AXI, TL-UL. Spec 009 tự giữ HyperBus và datasheet ở `reference/md_doc` của IP, không qua `vlsit_INDEX.md`. R-006 nói "take from md_doc of the skill". | Cho phép md_doc theo từng IP nhưng ghi rõ trong R-006 và dùng `vlsit_protocol_docs.py index --dir` cho thư mục đó |
| S9 | Tooling draw.io: bố cục chỉ một frame, block phải có chiều rộng chia hết cho 20 (đã thêm kiểm tra), cây clock/reset đôi khi vòng quanh frame, không có nhiều cấp. `vlsit_diagram_rules.md` đã ghi ngoại lệ RHD-087 nhưng chưa được người dùng xác nhận. | Xác nhận ngoại lệ; tạo `reference/drawio/` hướng dẫn xử lý lỗi thường gặp |
| S10 | Khối không có kiểm thử tự động: các script chỉ được chạy tay. | Thêm thư mục `tests/` với ví dụ nhỏ (SyncFIFO, AXI bridge) chạy `check`, `build` và so sánh kết quả |
| S11 | `vlsit_find_python.sh` và `vlsit_drawio_to_svg.py` chưa được chạy trên Linux (môi trường hiện tại chỉ có Windows). | Chạy thử trên Linux hoặc ghi rõ "chưa kiểm chứng trên Linux" trong README |

**Thấp**

- `SKILL.md` dài (15 KB); nên chuyển các chi tiết bước 9 và bước 10 vào `reference/`.
- Thư mục skill đã cài có `__pycache__` và `vlsit_approved_packages.txt` không có trong repo skills (có thể do bản đã cài khác bản repo); nên đồng bộ.
- Câu hỏi mẫu (`vlsit_question_bank.md`) chưa có nhóm cho IP có giao diện vật lý/PHY, tham số timing theo thiết bị, và hiệu năng (throughput/latency theo kịch bản), chính là những nhóm mà spec 009 thiếu nhất (xem mục 3). Đề xuất thêm các nhóm này.

---

## 2. Phân tích spec 009

### 2.1 Spec định nghĩa gì

- IP: bộ điều khiển HyperRAM, phía SoC là AXI4 subordinate (32 hoặc 64 bit) và APB4 CSR; phía bộ nhớ là HyperBus x8 hoặc Extended-I/O x16, chọn bằng parameter `PARA_MEM_DQ_W` lúc elaboration.
- Năm OPN mục tiêu ở 200 MHz: Infineon S80KS2562GABHB020 (x8), Winbond W958D8NBYA5I (x8), ISSI IS66WVH32M8DALL-200B1LI (x8), Infineon S80KS2564GACHI040 (x16), Winbond W958D6NBKX5I (x16).
- Kiến trúc: một top cấu trúc `m_vlsit_hyperram_controller` với 6 module con: `apb4_if`, `apb4_cdc`, `csr_regfile`, `axi4_frontend`, `hyperbus_ctrl`, `hyperbus_phy`.
- Clock: `CLK-CORE` chung cho AXI4 và HyperBus; `CLK-APB` bất đồng bộ riêng. Reset: `i_rst_n_core` (reset cả HyperRAM, mất dữ liệu), `i_rst_n_apb` (chỉ APB).
- Trình tự khởi động: reset core, SW lập trình timing khi disabled, set enable, đếm RESET# thấp, nhả RESET#, đếm startup, khởi tạo mode register, nhận AXI.
- Lỗi: ngoài vùng địa chỉ = DECERR; request hợp lệ nhưng không hỗ trợ = SLVERR; cả hai không gây giao dịch HyperBus.
- CSR: workbook `ASYNC_CSR` đề xuất 22 thanh ghi (control, status, capability, 8 thanh ghi timing, latency, profile, lỗi cấu hình, interrupt, bộ đếm lỗi AXI, địa chỉ lỗi cuối).
- 21 quyết định (DEC-001..021), 5 phụ thuộc, 22 REQ, 9 waveform, 1 test, 2 property.

### 2.2 Mức hoàn thiện

Spec ở trạng thái "ý định đã duyệt, chi tiết chưa viết": phần quyết định nghiệp vụ (cấu hình, reset, lỗi, ranh giới pad) rõ; phần cần để viết RTL (cổng, kiến trúc, PHY, bộ đệm, hiệu năng, test) còn trống. Theo mục 20 và README còn mở: tần số clock và sinh CK, IO timing, ordering AXI, timing cảnh báo nguồn, giá trị mode register từng OPN, qualification.

---

## 3. Nhận xét về spec 009

Mức: **A** = sai hoặc mâu thuẫn, phải sửa; **B** = chưa rõ, cần thảo luận để chốt; **C** = thiếu, phải bổ sung trước khi viết RTL; **D** = hình thức.

### 3.1 Sai hoặc mâu thuẫn (A)

**A1. (hạ mức, xem B13) tCSM gán theo độ rộng x8/x16.** REQ-CSR-002, REQ-MEM-003 (x8 ≤ 1 µs), REQ-MEM-005 (x16 ≤ 4 µs), DEC-008 và `TIMING_CSM`. Sau khi đọc đủ năm datasheet (Phụ lục A): tCSM phụ thuộc **cấp nhiệt độ** của OPN, không phụ thuộc độ rộng bus. Infineon x8 S80KS2562GABHB020 là Automotive Grade 2 (-40..105 °C): 1 µs khi nhiệt độ > 85 °C, 4 µs khi ≤ 85 °C. Winbond x8 và x16, ISSI x8, Infineon x16 (hậu tố I) đều là Industrial (-40..85 °C): 4 µs. Vậy "x8 ≤ 1 µs" chỉ do OPN Infineon Grade 2 trong ma trận (mức xấu nhất của nhóm x8); `research/hyperram_protocol_and_product_research.md` dòng 81 đã ghi đúng điều này, spec đã gộp thành quy tắc theo độ rộng. Hệ quả: (a) an toàn nhưng làm giảm hiệu năng của Winbond và ISSI x8 (được phép 4 µs): mỗi lần tách đoạn mất tCSHI + CA + latency khoảng 95 ns ở fixed latency, tức khoảng 9% của 1 µs so với 2% của 4 µs; (b) không tổng quát cho OPN mới; (c) Infineon Grade 2 vẫn được 4 µs khi nhiệt độ ≤ 85 °C. Đây là một quyết định thiết kế cần thảo luận (câu hỏi 1), không phải lỗi giá trị.

**A2. Mode fixed-latency làm hỏng yêu cầu latency thấp.** DEC-020, REQ-MEM-006. Datasheet S80KS2562: fixed latency là mặc định sau reset, mọi truy cập có độ trễ ban đầu bằng 2 lần số chu kỳ cấu hình (200 MHz: mã latency 7, tức 14 CK = 70 ns trước byte dữ liệu đầu, cộng CA 3 CK, khoảng 85 ns). Ở chế độ variable latency, độ trễ chỉ là 1 lần (7 CK = 35 ns) khi không có refresh trùng, và RWDS báo 2 lần chỉ khi trùng. Với yêu cầu "high performance, low latency", việc khóa cứng fixed latency giảm một nửa hiệu năng cho truy cập ngắn (cache-line refill 32 hoặc 64 byte: 85 ns so với 50 ns). Đề xuất: hỗ trợ cả hai chế độ, chọn bằng CSR; mặc định variable nếu controller xử lý được RWDS (xem mục 4.3).

**A3. Trạng thái "không hỗ trợ" cho AXI WRAP hợp lệ.** REQ-MEM-006, OP-001/002: "nếu thiết bị không hỗ trợ thì SLVERR". Chuẩn AXI cho WRAP độ dài 2, 4, 8, 16 beat; với data 32 bit ra 8, 16, 32, 64 byte; HyperBus wrapped burst có độ dài 16, 32, 64, 128 byte (Hybrid thêm). Vậy WRAP 8 byte (2 beat × 4 byte) không map được. Trả SLVERR cho một request hợp lệ theo chuẩn AXI gây lỗi cho master. Controller nên **luôn** hoàn thành được mọi request AXI hợp lệ: chia thành các truy cập HyperBus phù hợp (ví dụ đọc 16 byte rồi sắp xếp lại), chỉ trả SLVERR cho trường hợp thực sự bất khả (ví dụ FIXED, vượt aperture là DECERR). Cần liệt kê rõ AXI feature nào bị loại (FIXED burst, narrow transfer, unaligned, size > bus width).

**A4. Quy tắc mục 14.1 dẫn tới mâu thuẫn tên cổng và hình thức.** Mục 14.1 ghi "Author: Nguyen Quan (user)", các spec khác trong repo dùng "Nguyen Quan and Claude Sonnet 5.5 (user)". Mục 22 (References used to shape this template) còn nguyên danh sách của template (Arm, Synopsys), không phải tài liệu của IP này; mục 2.1 còn câu hướng dẫn "Record exact title, revision...".

**A5. Reset giá trị mặc định của thanh ghi timing đều bằng 0 (workbook).** `T_RP_CK`, `T_RH_CK`, `T_RPH_CK`, `T_VCS_CK`, `T_CSHI_CK`, `T_RWR_CK`, `T_CSM_CK`, `INITIAL_LATENCY_CK`: reset 0x0; `CONFIG_ERROR_STATUS.INVALID_TIMING` mô tả "timing counts are zero ... invalid". Vậy sau reset controller không thể enable nếu SW không lập trình đầy đủ 8 thanh ghi; không có giá trị mặc định hợp lý như người dùng yêu cầu. Xem mục 4.4.

**A6. Mục 11 thiếu 11.3 và 11.4** (R-031). `CAPABILITY.AXI_DATA_WIDTH` dùng mã 00/01 trong khi `PARA_AXI_DATA_W` = 32/64: cần ghi rõ ánh xạ.

### 3.2 Chưa rõ, cần thảo luận (B)

**B1. Kiến trúc clock và PHY (quan trọng nhất).** Spec nói CK "forwarded from CLK-CORE, ratio/phase TBD". Chưa trả lời được: (a) tần số CLK-CORE so với CK; để CK = 200 MHz DDR cần clock 200 MHz và pha 90 độ hoặc clock 400 MHz; (b) CK phát từ clock nào, bằng ODDR hay cell thư viện; (c) CK# có hay không (thiết bị 1,8 V có CK#, 3 V không có); (d) cách lấy mẫu dữ liệu đọc: RWDS là strobe cạnh-căn-chỉnh với dữ liệu, thường cần dịch pha hoặc delay line + FIFO chéo miền; spec khẳng định "no AXI-to-HyperBus CDC", nhưng một PHY 200 MHz thực tế thường có FIFO bắt dữ liệu theo RWDS hoặc clock đã trễ; (e) có hỗ trợ hiệu chỉnh delay (tap) cho skew bo mạch không. Không chốt phần này thì không thể viết `hyperbus_phy`, SDC, hay xác nhận "200 MHz".

**B2. Ordering và arbitration AXI.** DEC-016: "cross-channel ordering remains open". HyperBus chỉ có một giao dịch tại một thời điểm (half-duplex); với 4 read + 4 write outstanding cần: ai thắng khi đọc và ghi cùng chờ (round-robin, ưu tiên ghi, ưu tiên đọc, cấu hình), ràng buộc RAW (đọc sau ghi cùng địa chỉ), thứ tự B và R với cùng ID, có cho đọc vượt ghi không, độ lớn bộ đệm. Mục 10.4 và 5.4 trống.

**B3. Định nghĩa "write-completion point".** OP-002: B trả sau "selected write-completion point" chưa chọn: sau khi nhận W cuối (posted write, B sớm, hiệu năng tốt, SW không biết dữ liệu đã vào RAM), hay sau khi giao dịch HyperBus kết thúc (an toàn, chậm). Ảnh hưởng trực tiếp tới hiệu năng và tính nhất quán với `o_idle`.

**B4. Số đệm AXI (MEM-001 là TBD).** "Bốn outstanding" nhưng chưa có kích thước đệm dữ liệu: bao nhiêu beat cho đường ghi (để nhận W trong khi chờ CA và latency 85 ns) và đường đọc (để chịu back-pressure R và tách đoạn). Quyết định này định hiệu năng và diện tích.

**B5. `PARA_MEM_PROFILE` / `DEVICE_PROFILE`.** Workbook ghi "requires an explicit compile-time PARA_MEM_PROFILE", trong khi mục 8 chỉ có 3 parameter. Chọn profile lúc compile mâu thuẫn mục tiêu "hỗ trợ nhiều loại RAM": mỗi sản phẩm phải tổng hợp lại để đổi OPN. Cần quyết định: profile là runtime (SW chọn hoặc đọc ID) hay compile-time (xem mục 4).

**B6. Số chip-select và nhiều thiết bị.** Mục 1.2 nói "one or more HyperRAM devices" nhưng chưa có số CS#, cách ánh xạ địa chỉ tới CS#, dual-die (một số HyperRAM hai die chung CS#). Cổng `o_hb_cs_n` chưa tồn tại.

**B7. Thanh ghi thiết bị (CR0, CR1, ID).** Spec nói "issue selected-profile initialization/mode-register commands" nhưng không định nghĩa: nội dung CR0 (độ trễ ban đầu, fixed/variable, drive strength, hybrid burst, burst length), CR1 (refresh, hybrid sleep, differential clock), ID0/ID1 (đọc nhận dạng, kiểm tra dung lượng). Cần chọn: controller tự ghi CR0 theo CSR, hay SW ghi trực tiếp qua một cổng truy cập thanh ghi thiết bị (khuyến nghị: có cổng "register access" để SW đọc/ghi CR0/CR1/ID qua APB).

**B8. Tần số hoạt động và độ rộng đếm.** `T_*_CK` rộng 16 bit tính theo chu kỳ CK; nếu CK thay đổi (phần mềm đổi chia tần), mọi số đếm phải tính lại; chưa có thanh ghi tần số CK (hoặc chia). Cần xác nhận CK cố định theo thiết kế hay cấu hình được.

**B9. Ý nghĩa `o_idle` khi APB-only reset và khi refresh.** `o_idle` đòi hỏi "APB bus idle", nghĩa là phụ thuộc miền APB bất đồng bộ; không rõ đồng bộ hóa trạng thái idle APB sang CLK-CORE có chịu trách nhiệm nào (CDC-001 chỉ liệt kê request/response). Cũng chưa rõ self-refresh của RAM trong lúc đang idle lâu.

**B10. Cảnh báo nguồn.** `i_mem_pwr_good` chỉ là mức; spec ghi "SoC xử lý". Chấp nhận được, nhưng nên thống nhất với SoC thời gian cảnh báo tối thiểu để `o_idle` kịp lên (REQ-PWR-001 chưa có số).

**B11. Lỗi trong lúc truy cập HyperBus.** Spec chỉ có lỗi vùng địa chỉ và lỗi tính năng. Chưa có: timeout (RAM không phản hồi, RWDS không toggle), lỗi đọc RWDS bất thường, vi phạm tCSM do back-pressure R, power-good rơi giữa giao dịch (mô tả ở REQ-PWR-001 nhưng không có bộ xử lý lỗi).

**B12. Tính hợp lệ của "REQ-IF-002: không quá bốn outstanding".** Với ID 4 bit có thể có 16 ID khác nhau; controller giữ 4 giao dịch chứ không 16 ID: cần quy định khi master gửi giao dịch thứ 5 (không nhận AWREADY/ARREADY) và thứ tự trả lời với ID khác nhau.

**B13. Trần tCSM theo OPN và nhiệt độ.** Xem A1. Đề xuất: trần theo preset OPN (4 µs cho Industrial, 1 µs cho Grade 2 khi > 85 °C), cho phép controller đọc CR1[1:0] (Infineon: 01b = 4 µs, 10b = 1 µs; Winbond x8 và x16 chỉ có 01b; ISSI có hai mức theo -40..85 và -40..105 °C) hoặc SW cấu hình.

**B14. Cách đọc dữ liệu khác nhau giữa các hãng.** Ở 200 MHz, tDSV (RWDS hợp lệ sau CK, tối đa) của Winbond là 5 ns, của ISSI là 12 ns (Phụ lục A); ISSI có "RWDS DCARS" (RWDS lệch pha bằng clock thứ hai). Nghĩa là cách thu dữ liệu đọc (theo RWDS hay theo clock trễ, độ trễ tap) phải cấu hình được theo OPN, không thể cố định trong PHY (liên hệ B1).

**B15. Độ dài CA.** x8: 3 CK (CA0..CA2). x16 Extended-I/O: datasheet nói "hai chu kỳ clock xác định hàng và kiểu burst, chu kỳ thứ ba xác định cột 32 bit"; tổng số CK của CA khi bus 16 bit chưa chắc chắn và cần đối chiếu hình thời gian x16, vì số CK của CA và độ dài latency quyết định hiệu suất và `T_CSM_CK` hiệu dụng.

### 3.3 Thiếu (C), phải bổ sung trước khi viết RTL

1. **Mục 6.2 không có**: toàn bộ cổng AXI4 (khoảng 40 tín hiệu, với DATA_W thay đổi), `o_hb_ck`, `o_hb_ck_n`, `o_hb_cs_n`, cổng chọn thiết bị, cổng đọc/ghi thanh ghi thiết bị (nếu có). Ghi chú ở 6.1 "pin expansion remains to be detailed".
2. **Mục 5.3 (dòng dữ liệu), 5.4 (bất biến), 10.4 (arbitration, throughput), 15.1, 15.2, 15.3 (chỉ 1 test, 2 property)** trống hoặc là chữ của template.
3. **Mục 13 (PPA/PERF)**: không có mục tiêu số. Thiếu băng thông và latency mục tiêu theo kịch bản (đọc cache-line 32 byte, ghi 4 byte rải rác, chuỗi tuần tự dài).
4. **Mục 17 (timing)**: không có SDC, không có ràng buộc IO nguồn-đồng-bộ (set_input_delay theo RWDS/CK, min/max delay, tKSKEW).
5. **Mục 9, 10.1**: chưa có máy trạng thái truy cập (idle, CA, latency, data, tách đoạn tCSM), chưa có độ dài chia đoạn, không có quy tắc giải quyết khi một AXI burst vượt 128 byte hoặc vượt giới hạn mảng.
6. **Test plan (mục 15)**: chỉ TEST-001 chung chung; thiếu test cho từng REQ (reset, tCSM, tCSHI, CDC, APB-only reset...), thiếu mô hình thiết bị (4 hãng, 5 OPN) và checker HyperBus.
7. **Truy vết (mục 19)**: dùng mã TEST không có trong mục 15; REQ-PWR-001 thiếu test thực tế.
8. **Danh sách cấu hình**: ma trận 4 cấu hình AXI/DQ nhưng thiếu chiều "OPN/profile": 5 OPN × 4 cấu hình là thực tế cần xác minh; chưa có giá trị mặc định mode register cho từng OPN (DEC-020 ghi "per-part programming details remain open").
9. **Bộ đếm hiệu năng/gỡ lỗi** (số giao dịch, số lần tách đoạn, độ trễ trung bình): chưa có.

### 3.4 Hình thức (D)

- **Lỗi chuyển đổi tài liệu Winbond.** Trong `winbond_w958d6nbkx_256mb_x16_a01-001.md` (Bảng 15 và 17) và `winbond_w958d8nbya_256mb_x8_a01-003.md`, các bảng power-up và reset (tVCS, tRP, tRH, tRPH) chỉ còn cột mô tả, **mất cột số**; spec ghi "Converted and page-verified" (REF-008). Không xác nhận được giá trị Winbond từ file này; `research/hyperram_protocol_and_product_research.md` dòng 82 nói giống Infineon và ISSI (150 µs, 200 ns, 200 ns, 400 ns) nhưng Markdown không có bằng chứng. Cần dựng lại hai bảng từ PDF (`repair_pdf_md_pages.py` có trong `research/`) trước khi dùng làm giá trị mặc định.
- **tCSHI "6 ns cho cả năm OPN" (REQ-MEM-004).** Infineon x8 và Winbond: 6 ns ở 200 MHz; ISSI: 5 ns. Giá trị 6 ns là mức bảo thủ chung nên không sai, nhưng spec ghi nguồn là "200-MHz column" của cả năm datasheet; nên ghi "6 ns (giá trị chung bảo thủ; ISSI 5 ns)".

- Song ngữ trong spec (R-005 yêu cầu tiếng Anh): xóa hoặc đổi quy ước.
- 78 chữ TBD phân tán; R-014 yêu cầu ghi mỗi TBD ở mục 20 với tác động và quyết định cần thiết (hiện chỉ có DEC-004, 012, 013, 017 kiểu này).
- Sơ đồ khối 5.2 chỉ có nhãn "CK / CS# / RESET#" trong chữ; không có connector riêng; mục 6.2 cũng thiếu các cổng này. Nên vẽ lại sau khi chốt cổng.
- Waveform WF-002: trục thời gian không có số chu kỳ, nhãn "LATENCY" chồng nhãn "CA" (đã quan sát ở bản SVG); các waveform "abstract", không thể dùng làm tài liệu thời gian.
- Mục 22 là danh sách của template; thay bằng tài liệu thực của IP.
- Tên module có `apb4_if` và `apb4_cdc` dùng "if" và "cdc" nhưng quy tắc đặt tên NAM-08 chưa liệt kê; kiểm tra bằng `check --naming default` khi các cổng đã đủ.

---

## 4. Đề xuất cho yêu cầu mới: nhiều loại RAM, hiệu năng cao, latency thấp, timing cấu hình bằng SW, mặc định hợp lý

Phần này là đề xuất để thảo luận, chưa phải quyết định. Các con số dựa trên datasheet đã đọc (Infineon S80KS2562) và cần kiểm lại với 4 datasheet còn lại.

### 4.1 Nguyên tắc: tách "controller" khỏi "thiết bị" bằng bộ tham số cấu hình runtime

Thay vì `PARA_MEM_PROFILE` compile-time và ma trận 5 OPN, controller chỉ biết một **mô hình thiết bị chung** gồm: độ rộng DQ, tập thời gian (đếm theo chu kỳ CK), kiểu độ trễ, kiểu clock (vi sai hay đơn), trần tCSM, và danh sách lệnh khởi tạo. Mỗi OPN chỉ là **một bộ giá trị** nạp vào CSR. Cách làm:

1. **Thanh ghi preset (`DEVICE_PRESET`)**: SW ghi mã preset (ví dụ 0 = custom, 1..5 = năm OPN hiện tại); phần cứng nạp ngay giá trị mặc định của preset vào các thanh ghi timing (ROM nhỏ trong CSR hoặc trong RTL), SW sau đó có thể ghi đè từng trường. Thêm OPN mới = thêm một dòng preset (và một mục trong tài liệu), không đổi kiến trúc.
2. **Độ rộng x8/x16**: vẫn là parameter (khác số chân và số làn RWDS), nhưng timing hoàn toàn từ CSR. Nếu muốn đổi x8/x16 runtime thì cần superset pin (đã bị loại, DEC-005).
3. **Đọc ID thiết bị (ID0/ID1)**: controller đọc thanh ghi ID của RAM sau khởi tạo, so với preset (ghi `STATUS.ID_MISMATCH`), giúp phát hiện nhầm OPN.

### 4.2 Nhóm thanh ghi timing và trường cần có (bổ sung/sửa workbook)

Tất cả đếm theo chu kỳ CK đầy đủ (như hiện tại), đều có trần cứng và giá trị reset hợp lý.

| Nhóm | Trường | Ghi chú |
|---|---|---|
| Đồng hồ | `CK_DIV` (hoặc tỷ lệ CLK-CORE/CK), `CK_DIFF_EN` (CK# bật/tắt) | Cần để tính lại mọi số đếm khi đổi tần số; reset: tỷ lệ cho CK an toàn |
| Khởi động | `T_RP`, `T_RH`, `T_RPH`, `T_VCS` | Từ datasheet: tRP 200 ns, tRH 200 ns, tRPH 400 ns, tVCS 150 µs |
| Truy cập | `T_CSHI` (CS# cao tối thiểu), `T_RWR` (read-write recovery), `T_CSS`, `T_CSH` nếu cần | tCSHI = 6 ns ở 200 MHz |
| Độ trễ | `INITIAL_LATENCY` (3..7 CK theo mã thiết bị), `LATENCY_MODE` (fixed hoặc variable), `RWDS_LAT_DETECT` | 200 MHz: latency 7 |
| Đoạn CS# | `T_CSM_CK` + `CSM_AUTO` (đọc CR1[1:0] để chọn 4 µs hay 1 µs) + `CSM_FORCE` | Trần theo nhiệt độ, không theo độ rộng |
| Thu dữ liệu | `RD_CAPTURE_TAP` (bước delay/pha), `RD_CAPTURE_MODE` (theo RWDS hay theo clock trễ), `WR_DATA_PHASE` | Cần để chạy 200 MHz trên nhiều bo mạch và nhiều RAM |
| Thiết bị | `CR0_WR_VALUE`, `CR1_WR_VALUE` (SW ghi trực tiếp hoặc controller dựng từ các trường trên), `DRIVE_STRENGTH` (CR0[14:12]), `HYBRID_EN` | Cổng truy cập thanh ghi thiết bị cho SW |
| Hiệu năng | `POSTED_WRITE_EN`, `PREFETCH_EN`, `ARB_MODE` (round-robin, ưu tiên đọc, ưu tiên ghi), `MAX_BURST_BYTES` | Xem mục 4.3 |

### 4.3 Hiệu năng cao và latency thấp: các cơ chế đáng cân nhắc

1. **Variable latency mặc định** (RWDS báo trùng refresh): giảm độ trễ ban đầu từ 85 ns xuống khoảng 50 ns cho truy cập bình thường (200 MHz, latency 7). Yêu cầu: logic đọc RWDS trong pha CA để biết 1x hay 2x.
2. **Posted write**: trả B ngay khi dữ liệu W cuối vào bộ đệm ghi nếu `POSTED_WRITE_EN`; tắt để có ngữ nghĩa nghiêm ngặt (B sau khi ghi vào RAM). `o_idle` phải chờ bộ đệm rỗng.
3. **Đọc liên tục và gộp burst liền kề**: nếu request đọc kế tiếp có địa chỉ ngay sau burst hiện tại và vẫn trong tCSM, tiếp tục giao dịch HyperBus thay vì kết thúc rồi bắt đầu lại (tiết kiệm CA + latency).
4. **Prefetch/đệm đọc** (một hay hai dòng 32 hoặc 64 byte): cho cache-line refill tuần tự.
5. **Tách đoạn tCSM thông minh**: nếu T_CSM = 1 µs, tối ưu điểm tách để căn theo ranh giới 4 KB của AXI và theo wrapped group.
6. **Ưu tiên theo ID hoặc loại**: AXI4 không có QoS trong profile hiện tại; chỉ cần `ARB_MODE` tĩnh.
7. **Băng thông lý thuyết**: x8 200 MHz DDR = 400 MB/s; x16 = 800 MB/s. AXI 32 bit ở 200 MHz = 800 MB/s nên x8 là nút cổ chai. Với truy cập 32 byte ở fixed latency: 17 CK overhead + 16 CK data = 33 CK (hiệu suất 48%); variable: 10 + 16 = 26 CK (hiệu suất 61%). Đây chính là lý do cần mục tiêu hiệu năng định lượng (xem câu hỏi 6).

Mục tiêu đề xuất (để người dùng điều chỉnh): hiệu suất bus x8 ≥ 80% cho burst ≥ 128 byte tuần tự; latency đọc cache-line 32 byte ≤ 60 ns tính từ AR đến beat R đầu ở 200 MHz (variable latency); mọi con số cần đo bằng mô phỏng chu kỳ trước khi đóng spec.

### 4.4 Giá trị mặc định hợp lý (chạy được sau reset mà không cần SW lập trình)

Nguyên tắc: reset đưa về giá trị an toàn cho cả 5 OPN ở CK mặc định, nên SW chỉ cần `ENABLE = 1` cho trường hợp phổ biến; đổi sang preset cao hơn nếu cần. Đề xuất mặc định (tính cho CLK-CORE 200 MHz, CK 200 MHz, chu kỳ 5 ns; các giá trị phải được xác nhận với datasheet từng OPN, nhất là Winbond và ISSI):

| Trường | Mặc định đề xuất | Cơ sở |
|---|---|---|
| `T_RP_CK` | 80 (400 ns) | tRP 200 ns (Infineon, ISSI; Winbond cần xác nhận từ PDF), gấp đôi để có lề |
| `T_RH_CK` | 80 (400 ns) | tRH 200 ns, lề |
| `T_RPH_CK` | 160 (800 ns) | tRPH 400 ns, lề |
| `T_VCS_CK` | 40000 (200 µs) | tVCS 150 µs (Infineon, ISSI; Winbond cần xác nhận từ PDF), lề 33% |
| `T_CSHI_CK` | 2 (10 ns) | tCSHI 6 ns (Infineon, Winbond), 5 ns (ISSI): 2 CK an toàn cho cả 5 OPN |
| `T_RWR_CK` | 7 (35 ns) | tRWR = 35 ns ở 200 MHz cho cả 5 OPN (Phụ lục A); ở 166 MHz là 36 ns (6 CK), ở 133 MHz 37,5 ns (5 CK) |
| `INITIAL_LATENCY` | 7 | Mã 0010 = 7 CK ở 200 MHz cho cả 5 OPN (ISSI còn mã 0011 = 8 CK ở 200 MHz); 7 CK = 35 ns bằng đúng tACC, lề 0 ở 200 MHz, nên cho phép 8 |
| `LATENCY_MODE` | fixed (mặc định của thiết bị sau reset) nếu chưa hỗ trợ variable; variable nếu có | khớp trạng thái POR của thiết bị |
| `T_CSM_CK` | 160 (800 ns) hoặc `CSM_AUTO = 1` | 1 µs của cấp Industrial Plus trừ CA và latency còn khoảng 160 CK nên 800 ns an toàn cho mọi cấp; người dùng nhiệt độ ≤ 85 °C tăng lên 4 µs |

Lưu ý: `INVALID_TIMING` của workbook hiện coi giá trị 0 là lỗi; khi có giá trị mặc định hợp lý cần định nghĩa lại chỉ báo lỗi này theo sàn và trần của preset.

### 4.5 Việc cần sửa trong workbook và spec (nếu chấp nhận đề xuất)

1. Thêm thanh ghi: `CLOCK_CONFIG`, `DEVICE_REG_ACCESS` (địa chỉ, dữ liệu, kích hoạt đọc/ghi CR0, CR1, ID0, ID1), `RD_CAPTURE`, `PERF_CONFIG`, `TIMING_*` mới, `PRESET`.
2. Đặt giá trị reset theo mục 4.4; đổi `INVALID_TIMING` thành kiểm tra theo trần và sàn của preset.
3. Bỏ `PARA_MEM_PROFILE` compile-time; thêm `PRESET` runtime; sửa DEC-008, REQ-MEM-003, REQ-MEM-005, REQ-CSR-002 (A1).
4. Viết mục 6.2 đầy đủ, mục 5.3, 5.4, 10.1, 10.4, 13, 15, 17.

---

## 5. Câu hỏi cần thảo luận (trả lời theo số)

Mỗi câu có phương án khuyến nghị đầu tiên; bạn có thể viết ý khác.

1. **tCSM (A1)**: bỏ ràng buộc "x8 ≤ 1 µs, x16 ≤ 4 µs" và thay bằng trần theo nhiệt độ/OPN, mặc định an toàn 1 µs, cho phép 4 µs khi SW xác nhận hoặc khi controller đọc CR1[1:0]? (A: có, đọc CR1 tự động; B: có, chỉ SW chọn; C: giữ như cũ.)
2. **Latency (A2, 4.3)**: hỗ trợ cả fixed và variable latency, mặc định variable? (A: có; B: chỉ fixed; C: variable bắt buộc.)
3. **PHY và clock (B1)**: kiến trúc nào? (A: CLK-CORE 200 MHz và một clock 90 độ từ PLL của SoC để phát CK/lấy mẫu, có tap trễ cấu hình; B: một clock 400 MHz chia 2, tự tạo pha; C: PHY chỉ là giao diện thô, tạo CK bằng cell của SoC.) Cần biết thư viện công nghệ và có PLL/DLL không.
4. **Profile runtime (B5, 4.1)**: dùng preset runtime (A) hay giữ `PARA_MEM_PROFILE` compile-time (B)?
5. **Posted write và ordering (B2, B3)**: B sau khi ghi vào RAM hay B sớm (posted)? Quy tắc arbitration đọc/ghi mặc định? Có cho đọc vượt ghi không?
6. **Mục tiêu hiệu năng (C3)**: chốt các con số: băng thông tuần tự, latency cache-line, kích thước burst điển hình, tần số CLK-CORE. Không có số này thì không có tiêu chí đóng spec.
7. **AXI feature (A3)**: hỗ trợ đầy đủ WRAP/INCR mọi kích thước hợp lệ (A), thêm FIXED (B)? Narrow transfer và unaligned có hỗ trợ không?
8. **Số chip-select và thiết bị (B6)**: một CS# hay nhiều; có dual-die?
9. **Thanh ghi thiết bị (B7)**: có cổng SW đọc/ghi CR0, CR1, ID qua APB không, hay controller chỉ ghi giá trị cố định?
10. **Ngôn ngữ spec (S3)**: giữ song ngữ (sửa R-005) hay chuyển 009 sang tiếng Anh hoàn toàn?
11. **Skill (S1-S5)**: đồng ý nâng cấp `check` (TBD, TEST/SVA, 11.3/11.4, template text, tiếng Việt, interface completeness) và sửa `SKILL.md` bước 10 mục 3? Có thể làm ngay sau khi bạn chốt.

---

---

## Phụ lục A. Thông số trích từ datasheet theo OPN (200 MHz, 1,8 V)

Nguồn: các file trong `reference/md_doc/`. Giá trị là mức tối thiểu trừ khi ghi "tối đa". "chưa trích" = bảng trong file Markdown bị ghép hoặc thiếu cột; "chưa xác nhận" = file Markdown mất cột số.

| Tham số | Infineon x8 S80KS2562GABHB020 | Winbond x8 W958D8NBYA5I | ISSI x8 IS66WVH32M8DALL-200B1LI | Infineon x16 S80KS2564GACHI040 | Winbond x16 W958D6NBKX5I |
|---|---|---|---|---|---|
| Cấp nhiệt độ | Automotive Grade 2, -40..105 °C | Industrial, -40..85 °C | Industrial, -40..85 °C | Industrial (hậu tố I), -40..85 °C | Industrial, -40..85 °C |
| tCK min | 5 ns | 5 ns | 5 ns | 5 ns | 5 ns |
| tACC | 35 ns | 35 ns | 35 ns | 35 ns | 35 ns |
| tRWR | 35 ns | 35 ns | 35 ns | 35 ns | 35 ns |
| tCSHI | 6 ns | 6 ns | 5 ns | chưa trích (bảng ghép) | 6 ns |
| tCSS | 4,0 ns | 4 ns | 3 ns | chưa trích | 4 ns |
| tDSV (tối đa) | chưa trích | 5 ns | 12 ns | chưa trích | 5 ns |
| tCSM (tối đa) | 4 µs (≤ 85 °C), 1 µs (85..125 °C), đọc CR1[1:0] | 4 µs (chỉ mã 01b) | 4 µs (-40..85 °C); 1 µs (-40..105 °C) | 4 µs (85 °C), 1 µs (105 °C) | 4 µs (chỉ mã 01b) |
| Mã latency ở 200 MHz (CR0[7:4]) | 0010b = 7 CK (mặc định) | 0010b = 7 CK (mặc định; cùng mã 7 CK cho 250 MHz) | 0010b = 7 CK; 0011b = 8 CK | 0010b = 7 CK (mặc định) | chưa trích dòng |
| Latency ở tần số khác | 0000b 5 CK (133), 0001b 6 CK (166), 1110b 3 CK (85), 1111b 4 CK (104) | giống Infineon | 0000b 5, 0001b 6 (166 MHz), 1110b 3, 1111b 4 | giống Infineon | chưa trích |
| Fixed latency mặc định (CR0[3]) | 1 (fixed, 2 lần) | 1 | 1 | 1 | 1 |
| Drive strength mặc định (CR0[14:12]) | 000b = 34 Ω | 000b = 34 Ω | chưa trích | 000b = 34 Ω | chưa trích |
| tVCS | 150 µs | chưa xác nhận (mất cột số) | 150 µs | 150 µs | chưa xác nhận |
| tRP, tRH, tRPH | 200, 200, 400 ns (bảng Infineon x16; x8 cùng giá trị theo nghiên cứu) | chưa xác nhận | 200, 200, 400 ns | 200, 200, 400 ns | chưa xác nhận |
| Clock vi sai CK/CK# | có | có | có | có | có |
| Điểm riêng | hybrid burst, hybrid sleep | có OPN 250 MHz khác | RWDS DCARS (RWDS lệch pha) | RWDS[1:0], 32 bit mỗi chu kỳ | RWDS[1:0] |

Suy ra cho controller ở CK 200 MHz (chu kỳ 5 ns):

| Đại lượng | Giá trị | Ghi chú |
|---|---|---|
| tRWR tính bằng CK | 7 CK (35 ns) | cùng giá trị cho cả 5 OPN |
| tCSHI tính bằng CK | 1 CK (ISSI, 5 ns) hoặc 2 CK (6 ns) | dùng 2 CK chung |
| Độ trễ ban đầu | 7 CK; fixed = 14 CK (70 ns); variable = 7 hoặc 14 CK | 7 CK = đúng tACC 35 ns, lề 0 |
| Overhead mỗi giao dịch (x8, fixed) | CA 3 CK + 14 CK = 17 CK = 85 ns, cộng tCSHI 10 ns | khoảng 95 ns giữa hai giao dịch |
| Overhead (x8, variable, không trùng refresh) | 3 + 7 = 10 CK = 50 ns, cộng tCSHI 10 ns | khoảng 60 ns |
| Băng thông đỉnh | x8: 400 MB/s; x16: 800 MB/s | DDR 200 MHz |

Việc chưa làm được: dựng lại bảng power-up và reset của Winbond (cần PDF, không có trong repo); đọc tCSHI, tCSS, tDSV của Infineon x16 và các dòng latency và drive strength của Winbond x16 và ISSI từ bản PDF.

## 5A. Quyết định của người dùng (2026-10-28, đã ghi vào spec v0.2, workbook 34 thanh ghi, kế hoạch 16 waveform, DEC-033 và DEC-034)

| Câu | Quyết định | Hệ quả cho spec và workbook |
|---|---|---|
| 1 | Mọi tham số timing cấu hình bằng CSR, đơn vị chu kỳ CK; không đọc CR1 tự động; mặc định `T_CSM_CK` = 160 (1 µs), bộ đếm tối thiểu 10 bit (chứa 800 = 4 µs) | Bỏ `CSM_AUTO`; sửa REQ về trần tCSM (A1); sàn và trần theo preset |
| 2 | Hỗ trợ fixed và variable latency; mặc định fixed (khớp trạng thái sau reset của cả 5 OPN), variable do SW bật | Thêm `LATENCY_MODE`; sửa mặc định trong 4.3 mục 1 |
| 3 | PHY một clock 400 MHz chia 2, tự tạo pha; SoC có clock 400 MHz; thêm delay cell cho đường lấy mẫu RWDS | Spec nêu rủi ro độ phân giải 2,5 ns của lấy mẫu và đóng timing 400 MHz; `RD_CAPTURE_TAP` điều khiển delay cell |
| 4 | Preset runtime `DEV_PRESET` (custom + 5 OPN), SW ghi đè từng trường | Bỏ `PARA_MEM_PROFILE`; sửa DEC-008, REQ-MEM-003, REQ-MEM-005, REQ-CSR-002 |
| 5 | `WRITE_RESP_MODE`: mặc định B sau khi ghi xong vào RAM, posted tùy chọn; đọc vượt ghi chỉ khi không trùng địa chỉ | Thêm CSR và REQ ordering |
| 6 | Burst điển hình 32 hoặc 64 B; băng thông đỉnh x8 400 MB/s là số tính từ datasheet; hiệu suất và latency cache-line giữ TBD | Ghi TBD có ID trong mục 20 |
| 7 | Hỗ trợ đầy đủ INCR và WRAP mọi kích thước hợp lệ; không FIXED; narrow bằng WSTRB; unaligned tách CA, lỗi nếu vượt biên trang | Sửa REQ AXI |
| 8 | `NUM_CS` (mặc định 1, tối đa 2), preset và timing riêng cho mỗi CS#; dual-die coi là 2 CS# | Thêm cổng `o_cs_n` nhiều bit và CSR theo CS# |
| 9a | Cổng lệnh thô: `DEV_REG_ADDR`, `DEV_REG_WDATA`, `DEV_REG_RDATA`, `DEV_REG_CMD`, `DEV_REG_STATUS` | Rủi ro SW làm lệch CR0 và `INITIAL_LATENCY`: spec thêm cờ `CR0_LAT_MISMATCH` khi ghi CR0 làm mã latency khác CSR (cần người dùng xác nhận) |
| 9b | Lệnh thanh ghi chỉ chạy khi bus RAM rảnh; AXI chờ (backpressure) trong lúc lệnh chạy | Thêm REQ và waveform |
| 9c | Sau reset tự đọc ID, so với preset, đặt `STATUS.ID_MISMATCH`, không chặn AXI | Thêm REQ |
| 9d | Không đọc CR1 định kỳ; SW tự đặt `T_CSM_CK` | Xem câu 1 |
| 10 | Chuyển 009 hoàn toàn sang tiếng Anh | Dịch các dòng tiếng Việt |
| 11 | Nâng cấp `vlsit_spec_tool.py check` và sửa `SKILL.md` bước 10 mục 3, làm ngay | Xem bước kế |

---

## 6. Hạn chế của review này

- Đã đọc đủ năm datasheet theo phạm vi các bảng chính (Phụ lục A); còn các ô "chưa trích" và "chưa xác nhận" vì file Markdown thiếu cột hoặc bảng bị ghép; các giá trị mặc định ở 4.4 dựa trên Phụ lục A, ô thiếu cần xác nhận từ PDF.
- Không chạy lại các test của spec; không đánh giá RTL (chưa có).
- Review skill dựa trên đọc và chạy `check`, chưa chạy skill từ đầu cho một IP mới ở lượt này.
