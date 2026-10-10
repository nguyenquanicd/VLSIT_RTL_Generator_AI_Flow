---
name: source-command-spec-writer
description: "Draft a hardware RTL specification from a user-provided design description."
---

# source-command-spec-writer

Use this skill when the user asks for this phase of the repository's RTL design and verification workflow.

## Codex CLI execution notes

- Run this workflow in Codex; `/phase_name` denotes a source Claude command. Read a peer phase skill only when this workflow requires it.
- Preserve all gates. Only full autoflow may auto-approve Gate 2 and Gate 4 where the procedure permits; other approvals remain explicit.
- Adapt RV32IM and Linux/Bash assumptions to the requested IP and environment. Treat `Result/` as historical snapshots, not the active baseline.
- Report EDA results only after running the tool and inspecting its output. `sourceme.sh` is Linux/Bash-dependent; do not run it in PowerShell, and mark unavailable checks as not run.

## Token-efficient artifact reads

For existing inputs, run `python scripts/prepare_skill_context.py --phase source-command-spec-writer --root <design-root> --include <input-file>` before targeted reads. Summarize large logs with `python scripts/summarize_eda_log.py <log-path>` and inspect cited lines in the original. These are navigation aids, not verification evidence; avoid dumping full trees or logs.

## RTL rule source

For any phase work that generates or modifies synthesizable design RTL, use `style_constraints.source_file/source_kind` from approved config. If a legacy config lacks `source_kind`, treat its old path as unsupplied: use a rule file explicitly provided for this design, or repository default `spec_template/VLSIT_RTL_Design_Rule.md`. Never substitute a historical `Result/*/rtl_rule.md`. These rules apply to design RTL; SVA and testbench follow their own procedures.

## Reusable skill improvement

At completion, assess whether observed issues justify a high-impact improvement across designs. Follow `.agents/skill_maintenance.md` and `scripts/propose_skill_update.py`; present a qualifying proposal and ask approval for the exact change. Never edit this skill or its support files without explicit user confirmation. If none qualifies, say so briefly.

## Workflow source
# Phase 0 · Spec Writer — /spec_writer

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

```
Để tạo spec, mình cần biết:

1. Tên IP / module là gì? (ví dụ: downscaler, axi_bridge, uart_ctrl)
2. Chức năng chính là gì? (1-3 câu mô tả)
3. Interface: input/output chính là gì? (data width, bus type, clock?)
4. Có parameter nào cần configure không? (enable/disable feature, width, depth...)
5. Target: ASIC hay FPGA?
```

Nếu user cung cấp đủ → sang Bước 2.  
Nếu user mô tả ngắn gọn (ví dụ: "downscaler 4K về 1080p") → agent tự suy luận phần còn lại dựa trên domain knowledge, ghi rõ những phần đã tự điền.

---

## Bước 2 — Hỏi thêm chi tiết kỹ thuật (nếu cần)

Chỉ hỏi những gì còn thiếu sau Bước 1:

```
Thêm một vài câu hỏi kỹ thuật:

6. Pipeline hay combinational? Bao nhiêu stage?
7. Có reset không? Active-high hay active-low?
8. Clock domain: 1 hay nhiều?
9. Có interrupt / status register không?
10. Có CSR / register map không?
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

```
Spec đã được tạo tại: spec/<ip_name>_spec.md

Bạn muốn:
  [1] Tiếp tục → chạy /autoflow với spec này
  [2] Chỉnh sửa thêm → mở file và sửa tay, xong gõ /autoflow spec/<ip_name>_spec.md
  [3] Hỏi thêm → agent tiếp tục hỏi để bổ sung
```

---

## Xử lý lỗi

| Tình huống | Hành động |
|------------|-----------|
| User mô tả quá ngắn (< 10 từ) | Hỏi lại: "Bạn có thể mô tả thêm về input/output không?" |
| Domain không quen (RF, analog, etc.) | Ghi rõ "TBD — cần domain expert confirm" ở section đó |
| Mâu thuẫn thông tin | Hỏi lại ngay, không tự chọn |
| User cung cấp file PDF/docx | Đọc file, extract thông tin rồi tiếp tục flow |
