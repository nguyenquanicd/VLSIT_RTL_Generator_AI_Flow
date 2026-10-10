# Phase 0 · Spec Writer — /spec_writer

## User decision prompts

Follow `.agents/skills/decision_prompt_standard.md` for every user-facing question, option selection, review, approval, or overwrite decision. Before asking, review the current evidence; explain why the decision is needed; define unfamiliar terms; list valid options, their effects and trade-offs; give a concrete example; mark the best-supported option and explain why; and specify exactly how the user should answer. If the evidence does not support a safe recommendation, say what is missing instead of inventing a default. Never use a bare yes/no or A/B prompt.

**Mục tiêu:** Tự động tạo file spec Markdown từ mô tả design của user, sẵn sàng để đưa vào `/spec_parser`.

**Usage:**
```
/spec_writer
```
Agent sẽ hỏi tuần tự, không hỏi tất cả cùng lúc.

---

## Nguyên tắc bắt buộc

1. **Hỏi tối đa 3 vòng** — không hỏi vòng vô tận, thiếu thông tin thì ghi `TBD` và note lại.
2. **Không tự suy diễn spec kỹ thuật** — nếu không chắc thì hỏi, không bịa số liệu.
3. **Output phải đủ để spec_parser chạy được** — ít nhất: tên IP, chức năng chính, interface, tham số chính.
4. **Lưu vào `spec/` folder** — tạo folder nếu chưa có.
5. **Format nhất quán** — dùng Markdown heading, bảng, bullet list để spec_parser dễ parse.

---

## Bước 1 — Hỏi thông tin cơ bản

Hỏi user (có thể hỏi tất cả trong 1 message):

Trước mỗi câu, nói ngắn gọn vì sao cần thông tin đó. Định nghĩa acronym/term, đưa ví dụ
answer format và gợi ý lựa chọn khi spec hoặc ngữ cảnh ủng hộ. Không tự đề xuất giá trị
kỹ thuật nếu chưa có căn cứ. Nếu ASIC đã được xác nhận, ghi đó là context thay vì hỏi ASIC/FPGA.

```
Để tạo spec, mình cần biết:

1. Tên IP/module và tên gọi dự kiến là gì? Ví dụ: axi_stream_downscaler. Dùng cho spec/module mapping.
2. IP giải quyết vấn đề gì? Ví dụ: nhận stream 64-bit và phát stream 32-bit theo thứ tự trong spec.
3. Interface nào được yêu cầu? Nêu protocol, input/output, widths, clock/reset. Ví dụ AXI4-Stream, TDATA 64-bit in/32-bit out; chỉ dùng nếu đúng design.
4. Có configurable feature/parameter nào không? Nêu mục tiêu/legal values nếu biết. Ví dụ output width 32 hoặc 64 nếu spec cho phép.
5. Target technology/process hoặc flow constraint nào đã chốt? Thông tin này ảnh hưởng synthesis/PPA. Nếu chưa chọn, trả lời TBD thay vì đoán.

Khuyến nghị: cung cấp giá trị đã có trong design brief và để TBD các quyết định chưa chốt. Trả lời theo số câu hoặc bằng văn bản tự do.
```

Nếu user cung cấp đủ → sang Bước 2.  
Nếu user mô tả ngắn gọn (ví dụ: "downscaler 4K về 1080p") → agent tự suy luận phần còn lại dựa trên domain knowledge, ghi rõ những phần đã tự điền.

---

## Bước 2 — Hỏi thêm chi tiết kỹ thuật (nếu cần)

Chỉ hỏi những gì còn thiếu sau Bước 1:

Với mỗi câu, nêu tác động, định nghĩa options và đưa ví dụ. Chỉ khuyến nghị option khi có
căn cứ từ brief hoặc standard; nếu không, nêu rõ chưa có safe default.

```
Thêm một vài câu hỏi kỹ thuật:

6. Datapath cần combinational hay pipeline? Pipeline thêm stage/register để cải thiện timing/throughput nhưng có thể tăng latency/area. Ví dụ 2 stages nếu target timing yêu cầu; không tự mặc định.
7. Reset có không, đồng bộ hay bất đồng bộ, active-high hay active-low? Ví dụ answer: active-low asynchronous; chọn theo system integration requirement.
8. Có bao nhiêu clock domain? Nhiều domain cần CDC design/verification. Ví dụ một domain 100 MHz nếu đó là system clock đã chốt.
9. Có interrupt hoặc status output/register không? Nêu event, polarity và clear behavior nếu có.
10. Có CSR/register map không? Nếu có, cung cấp address, access type, reset value và side effects; ví dụ một bảng register map hiện hành.
```

Nếu user không biết → dùng default hợp lý cho domain, ghi chú rõ.

---

## Bước 3 — Sinh spec.md

Dựa trên thông tin thu thập, sinh file `spec/<ip_name>_spec.md` với cấu trúc:

```markdown
# <IP_NAME> — Hardware IP Specification

## 1. Overview
<Mô tả chức năng chính, use case, target application>

## 2. Key Features
- Feature 1: ...
- Feature 2: ...

## 3. Parameters
| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| PR_...    | bit  | 1       | ...         |

## 4. Interface
### 4.1 Clock & Reset
| Signal | Direction | Description |
|--------|-----------|-------------|

### 4.2 Input Ports
| Signal | Direction | Width | Description |
|--------|-----------|-------|-------------|

### 4.3 Output Ports
| Signal | Direction | Width | Description |
|--------|-----------|-------|-------------|

## 5. Functional Description
### 5.1 <Subsystem 1>
<Mô tả chi tiết>

### 5.2 <Subsystem 2>
<Mô tả chi tiết>

## 6. Microarchitecture
<Pipeline diagram, state machine, datapath nếu có>

## 7. Timing & Constraints
<Clock frequency, latency, throughput>

## 8. Register Map (nếu có)
| Address | Name | Access | Reset | Description |
|---------|------|--------|-------|-------------|

## 9. Error Handling
<Exception, invalid input behavior>

## 10. Notes / TBD
<Những gì còn chưa rõ, cần confirm thêm>
```

---

## Bước 4 — Review và confirm

In ra preview 20 dòng đầu của spec, sau đó hỏi:

Nêu các TBD/assumptions và hậu quả khi tiếp tục chưa xác nhận. Định nghĩa từng option,
đưa ví dụ, và khuyến nghị tiếp tục chỉ khi spec đủ rõ để parse mà không giữ assumption
ảnh hưởng behavior.

```
Spec đã được tạo tại: spec/<ip_name>_spec.md

Bạn muốn:
  [1] Tiếp tục → dùng file hiện tại cho /autoflow; chọn khi requirements, interface và TBD đã review.
  [2] Chỉnh sửa → cập nhật file trước khi chạy flow; chọn khi có nội dung chưa chính xác.
  [3] Hỏi thêm → bổ sung field còn thiếu; chọn khi TBD ảnh hưởng behavior/interface.

Khuyến nghị: [3] nếu còn TBD ảnh hưởng behavior, [2] nếu tìm thấy lỗi cụ thể, [1] chỉ khi
spec đã đủ rõ. Ví dụ: thiếu reset polarity thì chọn [3], không tự mặc định.
```

---

## Xử lý lỗi

| Tình huống | Hành động |
|------------|-----------|
| User mô tả quá ngắn (< 10 từ) | Hỏi lại: "Bạn có thể mô tả thêm về input/output không?" |
| Domain không quen (RF, analog, etc.) | Ghi rõ "TBD — cần domain expert confirm" ở section đó |
| Mâu thuẫn thông tin | Hỏi lại ngay, không tự chọn |
| User cung cấp file PDF/docx | Đọc file, extract thông tin rồi tiếp tục flow |
