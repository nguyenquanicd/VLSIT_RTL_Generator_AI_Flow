# Master Orchestrator — /autoflow

## User decision prompts

Follow `.agents/skills/decision_prompt_standard.md` for every user-facing question, option selection, review, approval, or overwrite decision. Before asking, review the current evidence; explain why the decision is needed; define unfamiliar terms; list valid options, their effects and trade-offs; give a concrete example; mark the best-supported option and explain why; and specify exactly how the user should answer. If the evidence does not support a safe recommendation, say what is missing instead of inventing a default. Never use a bare yes/no or A/B prompt.

**Mục tiêu:** Chạy toàn bộ RTL generation flow từ spec đến specification PDF, tự động qua các phase, dừng tại 3 gate quan trọng để human review.

**Usage:**
```
/autoflow                          → agent hỏi chọn mode
/autoflow spec/my_spec.md          → [Mode A] dùng spec có sẵn
/autoflow --describe               → [Mode B] agent tự tạo spec từ mô tả
/autoflow spec/my_spec.md --from phase3b   → resume từ phase cụ thể
```

---

## Bước 0 — Chọn Mode (nếu không có argument)

Nếu user gọi `/autoflow` không có argument, hỏi:

Trước khi hỏi, kiểm tra xem user đã cung cấp spec trong hội thoại hoặc thư mục dự án chưa.
Tóm tắt kết quả tìm thấy và giải thích lựa chọn mode sẽ quyết định nguồn đầu vào của flow.

```
Bạn muốn bắt đầu theo cách nào?

  [A] Dùng spec có sẵn — chọn khi spec đã có requirements, interface và behavior đủ rõ.
      Ví dụ: spec/axi_stream_downscaler_spec.md
  [B] Tạo spec từ mô tả — chọn khi mới có ý tưởng hoặc mô tả ngắn; assumptions sẽ được
      đánh dấu và cần review trước khi Gate 1 được ký.

Khuyến nghị: [A] nếu đã có spec phù hợp vì giảm assumptions; [B] nếu chưa có spec.
Gõ A hoặc B; với A, kèm đường dẫn file nếu chưa được cung cấp:
```

- Nếu **A** → hỏi path file, tiếp tục Phase 1
- Nếu **B** → chạy nội dung `/spec_writer` để tạo spec, sau đó tiếp tục Phase 1 với file vừa tạo

---

## Nguyên tắc bắt buộc

1. **Không bỏ qua bất kỳ phase nào** — chạy đúng thứ tự, không shortcut.
2. **Dừng bắt buộc tại Gate 1, Gate 3b, Gate 5** — không tự ký nếu chưa có "yes" từ user.
3. **Tự ký Gate 2 và Gate 4** nếu không có lỗi — không cần hỏi lại user.
4. **RTL và TB chạy song song** sau Gate 2 — không chờ nhau.
5. **Mọi lỗi phải báo rõ** — không âm thầm bỏ qua, không tiếp tục khi có lỗi nghiêm trọng.
6. **Cập nhật status sau mỗi phase** — in progress bar để user biết đang ở đâu.

---

## Bước 0 — Pre-flight

Kiểm tra trước khi bắt đầu:

```
[ ] spec_file tồn tại và có nội dung
[ ] schemas/ folder tồn tại (hoặc tạo mới)
[ ] .claude/commands/*.md đầy đủ (7 files)
[ ] sourceme.sh có thể source được
```

In ra:
```
╔══════════════════════════════════════════════╗
║         RTL GEN FLOW — AUTO MODE             ║
║  Spec: <spec_file>                           ║
║  Gates: 1 · 3b · 5 (human review)           ║
║  Auto:  2 · 3a · 4 (no prompt)              ║
╚══════════════════════════════════════════════╝
```

---

## Phase 1 — Spec Parser

Gọi nội dung của `/spec_parser` với file spec đầu vào.

Sau khi xong, in summary:
```
── GATE 1 REVIEW ──────────────────────────────
  IP Name     : <ip_name>
  REQ count   : <N> requirements
  Ambiguity   : <N> needs_human_decision
  Modules     : <N> RTL modules mapped
  SVA hints   : <N> assertions planned

  structured_spec.json → schemas/
────────────────────────────────────────────────
Explain that Gate 1 approves this structured specification as the baseline for later phases.
Summarize unresolved ambiguity and its impact. Recommend approval only if requirements that
affect behavior are resolved; otherwise recommend no and identify an example item to revise.
Giải thích Gate 1 duyệt structured spec làm baseline. Tóm tắt TBD, ambiguity và mapping
chính; yes chấp nhận baseline, no giữ gate đóng để sửa. Khuyến nghị yes chỉ khi không còn
ambiguity ảnh hưởng behavior.
Approve Gate 1? (yes / no — nêu rõ thay đổi nếu chọn no)
```

**Dừng — chờ user gõ "yes".**

Nếu "no" → dừng flow, thông báo user chỉnh spec rồi chạy lại `/autoflow`.

---

## Phase 2 — Config UI (Auto)

Gọi nội dung của `/config_ui`.

Dùng default values cho tất cả parameter trừ khi user đã cung cấp overrides trong spec hoặc comment trước khi chạy.

Tự ký Gate 2 nếu không có lỗi. In:
```
✓ Gate 2 auto-signed — final_config.json saved
  Parameters: <N> locked
```

---

## Phase 3a + Phase 4 — RTL Generator & Testbench (Song song)

Thông báo:
```
── PARALLEL EXECUTION ─────────────────────────
  [3a] /rtl_generator  →  src/rtl/ + lint + synth
  [ 4] /tb_generator   →  src/tb/ + testplan
  (chạy độc lập, không chờ nhau)
────────────────────────────────────────────────
```

Chạy **Phase 3a trước**, sau đó chạy **Phase 4**.

> Lưu ý: Trong session đơn, chạy tuần tự nhưng không phụ thuộc kết quả nhau — 3a xong report, 4 chạy tiếp ngay.

**Phase 3a — RTL Generator:**
- Gọi nội dung `/rtl_generator`
- Lint check bắt buộc (0 warnings)
- Synthesis nếu tool có sẵn
- In kết quả: modules, cells, area

**Phase 4 — Testbench:**
- Gọi nội dung `/tb_generator`
- Tự ký Gate 4 nếu compile check pass
- In: số TC, coverage REQ-IDs

---

## Phase 3b — SVA Generator

Gọi nội dung `/sva_generator`.

Sau khi xong, in summary và **dừng**:
```
── GATE 3b REVIEW ─────────────────────────────
  SVA properties : <N> generated
  Vacuous (smoke) : <N> chưa được kích hoạt
  Compile check  : PASS / FAIL
  Review file    : src/sva/GATE3_REVIEW.md

  ⚠ Hãy đọc GATE3_REVIEW.md trước khi approve.
────────────────────────────────────────────────
Gate 3b approves the reviewed SVA set and unlocks verification. Summarize compile status,
vacuity concerns, uncovered requirements and unresolved properties. Recommend yes only when
properties match the approved requirements and checks pass; otherwise recommend no with edits.
Approve Gate 3b? (yes to accept this property set / no to keep the gate open)
```

**Dừng — chờ user gõ "yes".**

---

## Phase 5 — Verification

Gọi nội dung `/verification`.

Bao gồm:
- Compile TB (VCS)
- Run simulation tất cả TC
- Mutation testing (nếu có Yosys)
- Sign-off eligible REQ-IDs

Sau khi xong, in summary và **dừng**:
```
── GATE 5 REVIEW ──────────────────────────────
  Simulation  : <N>/<N> PASS  |  FAIL: <N>
  SVA         : 0 violations
  Mutation    : <N> REQ-IDs tested
  Sign-off    : <N>/<N> REQ-IDs eligible

  verification_report.json → schemas/
────────────────────────────────────────────────
Gate 5 records the verification outcome; it does not convert failed or locked items into passes.
Summarize failures, timeouts, locked requirements and report revision. Recommend yes only when
mandatory checks pass; otherwise recommend no and explain the blocker.
Sign off Gate 5? (yes to record the result / no to leave the gate open)
```

**Dừng — chờ user gõ "yes".**

Nếu có TC FAIL → **không cho phép sign Gate 5**, báo lỗi và dừng.

---

## Phase 6 — Specification PDF

Gọi nội dung `/spec_pdf_generator`.

In kết quả cuối:
```
╔══════════════════════════════════════════════╗
║           FLOW COMPLETE ✓                    ║
╠══════════════════════════════════════════════╣
║  Gate 1  ✓  structured_spec.json            ║
║  Gate 2  ✓  final_config.json               ║
║  Gate 3a ✓  src/rtl/ (<N> modules)          ║
║  Gate 3b ✓  src/sva/ (<N> properties)       ║
║  Gate 4  ✓  src/tb/  (<N> TCs)              ║
║  Gate 5  ✓  verification_report.json        ║
║  Phase 6 ✓  docs/specification.pdf          ║
╠══════════════════════════════════════════════╣
║  Sim result : <N>/<N> PASS                  ║
║  Sign-off   : <N>/<N> REQ-IDs               ║
║  RTL cells  : <N>                           ║
╚══════════════════════════════════════════════╝
```

---

## Xử lý lỗi

| Tình huống | Hành động |
|------------|-----------|
| spec_file không tồn tại | Dừng ngay, thông báo rõ path |
| Gate 1 ambiguity > 0.6 | Dừng, liệt kê các REQ cần làm rõ |
| Lint FAIL | Dừng Phase 3a, không tiếp tục sang 3b/5 |
| Compile TB FAIL | Dừng Phase 4, không tiếp tục sang Phase 5 |
| TC FAIL trong sim | Dừng trước Gate 5, liệt kê TC nào fail |
| User gõ "no" ở bất kỳ gate | Dừng sạch, in hướng dẫn fix rồi chạy lại |
| Phase bị interrupt | In trạng thái cuối, hướng dẫn resume từ phase đó |

---

## Resume từ phase cụ thể

Nếu flow bị interrupt, user có thể resume:

```
/autoflow <spec_file> --from phase3b   # bắt đầu lại từ SVA
/autoflow <spec_file> --from phase5    # bắt đầu lại từ verification
/autoflow <spec_file> --from phase6    # chỉ gen PDF
```

Agent đọc schemas/ để biết gate nào đã ký, bắt đầu từ phase được chỉ định.
