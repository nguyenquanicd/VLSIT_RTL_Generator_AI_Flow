---
name: source-command-config-ui
description: "Choose and validate RV32IM configuration parameters and write final_config.json through Gate 2."
---

# source-command-config-ui

## User decision prompts

Follow `.agents/skills/decision_prompt_standard.md` for every user-facing question, option selection, review, approval, or overwrite decision. Before asking, review the current evidence; explain why the decision is needed; define unfamiliar terms; list valid options, their effects and trade-offs; give a concrete example; mark the best-supported option and explain why; and specify exactly how the user should answer. If the evidence does not support a safe recommendation, say what is missing instead of inventing a default. Never use a bare yes/no or A/B prompt.

Use this skill when the user asks for this phase of the repository's RTL design and verification workflow.

## Codex CLI execution notes

- Run this workflow in Codex; `/phase_name` denotes a source Claude command. Read a peer phase skill only when this workflow requires it.
- Preserve all gates. Only full autoflow may auto-approve Gate 2 and Gate 4 where the procedure permits; other approvals remain explicit.
- Adapt RV32IM and Linux/Bash assumptions to the requested IP and environment. Treat `Result/` as historical snapshots, not the active baseline.
- Report EDA results only after running the tool and inspecting its output. `sourceme.sh` is Linux/Bash-dependent; do not run it in PowerShell, and mark unavailable checks as not run.

## Token-efficient artifact reads

For an existing design, run `python scripts/prepare_skill_context.py --phase source-command-config-ui --root <design-root>` before selecting artifacts. Summarize large logs with `python scripts/summarize_eda_log.py <log-path>` and inspect cited lines in the original. These are navigation aids, not verification evidence; avoid dumping full trees or logs.

## Reusable skill improvement

At completion, assess whether observed issues justify a high-impact improvement across designs. Follow `.agents/skill_maintenance.md` and `scripts/propose_skill_update.py`; present a qualifying proposal and ask approval for the exact change. Never edit this skill or its support files without explicit user confirmation. If none qualifies, say so briefly.

## Workflow source
# Phase 2 · Configuration — /config_ui

**Mục tiêu:** Thu thập và xác nhận cấu hình parameter cho IP. Xuất `schemas/final_config.json`
sau khi người dùng ký Gate 2.

**Không làm trong phase này:** sinh RTL, SVA, testbench, hay bất kỳ artifact code nào.

---

## Quy tắc bắt buộc

1. Không tự quyết định giá trị nào khác default — mọi thay đổi phải do người dùng xác nhận.
2. Gate 2 chỉ mở khi: **(a)** toàn bộ C1–C5 pass, **(b)** người dùng gõ xác nhận tường minh.
3. Mọi ràng buộc bị vi phạm phải bị từ chối ngay, không ghi vào config.
4. Ghi `gate_2_approved: false` cho đến khi người dùng xác nhận ở Bước 5.

---

## Bước 1 — Nạp tham số

Kiểm tra theo thứ tự ưu tiên:

1. Nếu `schemas/structured_spec.json` tồn tại → đọc trường `parameters` và `requirements` từ file đó.
2. Nếu không → đọc `spec_parser.md`, trích bảng §2.2 (Parameter TOP) và §1.1 (Feature list).
3. Nếu cả hai đều không tồn tại → dừng, thông báo: _"Không tìm thấy spec. Cần có `spec_parser.md` hoặc `schemas/structured_spec.json`."_

Từ dữ liệu đọc được, xây dựng bảng nội bộ gồm:
`name | type | default | valid_range | description | features_affected | req_ids_affected`

Bảng chuẩn cho `rv32im_core` (tham chiếu `spec_parser.md §2.2`) — dùng khi không có `structured_spec.json`:

| ID  | Tên                 | Default            | Range  | Tóm tắt                              | Feature       |
|-----|---------------------|--------------------|--------|--------------------------------------|---------------|
| P01 | `PR_BOOT_ADDR`      | `32'h8000_0000`    | align4 | PC sau reset                         | F01,F05       |
| P02 | `PR_MTVEC_RESET`    | `32'h0000_0000`    | align4 | Giá trị `mtvec` sau reset            | F11           |
| P03 | `PR_HART_ID`        | `32'h0`            | any    | Giá trị `mhartid` (read-only)        | F11           |
| P04 | `PR_M_EXT_EN`       | `1`                | 0/1    | RV32M bật/tắt                        | **F02**       |
| P05 | `PR_MULT_IMPL`      | `0`                | 0/1    | `0`=SEQ 33cy · `1`=COMB 1cy         | F17           |
| P06 | `PR_DIV_IMPL`       | `0`                | 0      | `0`=SEQ 34cy (**khoá Phase 1**)      | F17           |
| P07 | `PR_CSR_EN`         | `1`                | 0/1    | CSR file + trap bật/tắt              | F03,F11,F15   |
| P08 | `PR_IRQ_EN`         | `1`                | 0/1    | M-mode interrupts                    | F14           |
| P09 | `PR_COUNTER_EN`     | `1`                | 0/1    | `mcycle`/`minstret` 64-bit           | **F16** ⬜   |
| P10 | `PR_MTVEC_VEC_EN`   | `0`                | 0/1    | `mtvec` Vectored mode                | **F19** ⬜   |
| P11 | `PR_FWD_EN`         | `1`                | 0/1    | Full forwarding EX/MEM→EX            | F06           |
| P12 | `PR_RF_RESET_EN`    | `1`                | 0/1    | Reset regfile về 0 (sim determinism) | F09           |
| P13 | `PR_RF_IMPL`        | `0`                | 0/1    | `0`=flop array · `1`=RAM-style FPGA  | F09           |
| P14 | `PR_TRACE_EN`       | `0`                | 0/1    | Retire trace port                    | **F18** ⬜   |
| P15 | `PR_BUS_OUTSTANDING`| `1`                | 1      | Outstanding request (**khoá ở 1**)   | F10           |

---

## Bước 2 — Hiển thị bảng cấu hình

Hiển thị bảng tất cả 15 parameter với giá trị hiện tại (ban đầu = default). Chú thích rõ:
- `⬜ Tuỳ chọn` cho F16, F18, F19 — mặc định tắt (giá trị `0`)
- `[KHOÁ]` cho P06 (`PR_DIV_IMPL`) và P15 (`PR_BUS_OUTSTANDING`) — không thể thay đổi Phase 1
- Ghi chú dependency: C3 (P08→P07), C4 (P10→P07), C5 (P09→P07)

Với mỗi parameter có thể chọn, hiển thị ý nghĩa, giá trị hiện tại/default, các giá trị hợp lệ,
feature/REQ-ID bị ảnh hưởng, dependency và tác động đã được xác định đến area, timing,
throughput hoặc compatibility. Nếu spec không đủ dữ liệu để suy ra tác động, ghi rõ TBD.
Khuyến nghị giữ default khi spec không yêu cầu thay đổi; nêu lý do và trade-off cụ thể.

Sau khi hiển thị, hỏi người dùng:

> **"Bạn có thể giữ cấu hình mặc định hoặc chọn parameter cần đổi. Ví dụ: P05, P13 chọn hai parameter; none giữ nguyên tất cả. P05 điều khiển <ý nghĩa lấy từ spec>, còn P13 điều khiển <ý nghĩa lấy từ spec>. Khuyến nghị: none nếu spec không yêu cầu khác vì <lý do từ dependency/constraints>. Bạn muốn chọn ID nào?"**

---

## Bước 3 — Thu thập và validate thay đổi

Xử lý tuần tự từng parameter người dùng muốn thay đổi:

**3.1 Hiển thị context cho parameter đó:**
- Giá trị hiện tại và default
- Range hợp lệ
- Features và REQ-IDs bị ảnh hưởng
- Constraints liên quan (nếu có)

**3.2 Hỏi giá trị mới.**

Trước khi hỏi giá trị, định nghĩa parameter và từng option/value theo spec, nêu range,
default, ví dụ hợp lệ và tác động/dependency. Đánh dấu giá trị khuyến nghị cùng lý do;
không tự chọn giá trị phụ thuộc mục tiêu sản phẩm nếu spec chưa quy định.

**3.3 Validate ngay lập tức:**

| Constraint | Điều kiện | Lỗi nếu vi phạm |
|---|---|---|
| C1 | `PR_BOOT_ADDR % 4 == 0` | "Địa chỉ boot phải align 4 byte" |
| C2 | `PR_MTVEC_RESET % 4 == 0` | "Địa chỉ mtvec reset phải align 4 byte" |
| C3 | `PR_IRQ_EN=1 → PR_CSR_EN=1` | "IRQ cần CSR. Bật PR_CSR_EN trước." |
| C4 | `PR_MTVEC_VEC_EN=1 → PR_CSR_EN=1` | "Vectored mode cần CSR. Bật PR_CSR_EN trước." |
| C5 | `PR_COUNTER_EN=1 → PR_CSR_EN=1` | "Counter cần CSR. Bật PR_CSR_EN trước." |
| — | P06 và P15 không được thay đổi | "Parameter này khoá trong Phase 1." |

**3.4 Xử lý kết quả:**
- Vi phạm → Từ chối, giải thích, đề xuất cách sửa, hỏi lại.
- Hợp lệ → Cập nhật bảng, chuyển parameter tiếp theo.

**3.5 Sau khi xử lý hết danh sách**, tóm tắt giá trị đã đổi và tác động, rồi hỏi lựa chọn:
`done` để chốt các giá trị đang hiển thị, hoặc nhập thêm parameter ID. Nêu rõ `done`
không đồng nghĩa với ký Gate 2; khuyến nghị `done` khi không còn yêu cầu cấu hình chưa xử lý.

---

## Bước 4 — Style constraints

Chọn file RTL design rule theo thứ tự:

1. Nếu người dùng đã cung cấp đường dẫn rule file cho design này, dùng file đó.
2. Nếu chưa có file do người dùng cung cấp, dùng rule mặc định trong repository: `spec_template/VLSIT_RTL_Design_Rule.md` (đường dẫn hiện tại: `C:\HQuan\102_MyGithub\VLSIT_RTL_Generator_AI_Model\spec_template\VLSIT_RTL_Design_Rule.md`). Không lấy rule từ snapshot cũ trong `Result/`.
3. Đọc file được chọn. Nếu file mặc định không tồn tại hoặc không đọc được, dừng Gate 2 và yêu cầu người dùng cung cấp rule file; không tiếp tục với bộ rule rỗng.

Ghi đường dẫn file được chọn vào `style_constraints.source_file` và ghi `source_kind` là `user_supplied` hoặc `repository_default`. Không chép toàn bộ nội dung rule vào config; `lint_rules` chỉ chứa các constraint bổ sung do người dùng xác nhận. Tóm tắt ngắn gọn nhóm rule để người dùng biết file nào sẽ chi phối RTL.

Hỏi người dùng:

> **"Bạn có muốn thêm style constraint nào ngoài file RTL rule đã chọn không?
> Gõ bằng ngôn ngữ tự nhiên (ví dụ: 'không dùng for loop trong pipeline stage',
> 'mỗi module tối đa 200 dòng') hoặc gõ `none`."**

Nếu người dùng cung cấp constraints:
1. Phân tích ý định của từng constraint.
2. Chuyển đổi sang dạng lint rule ngắn gọn (text, không phải code).
3. Hiển thị constraint gốc, bản diễn giải lint, file/rule hiện hành có liên quan, ví dụ RTL
   được phép/bị cấm và ảnh hưởng đến synthesis. Đề xuất `yes` nếu diễn giải giữ đúng ý và
   không mâu thuẫn; giải thích lý do. Hỏi `yes` để chấp nhận hoặc `edit` để sửa.
4. Nếu đúng → ghi vào danh sách. Nếu không → hỏi lại.
5. Nếu constraint bổ sung mâu thuẫn với file rule được chọn → nêu rõ mâu thuẫn và hỏi người dùng cách xử lý; không âm thầm bỏ rule bắt buộc.

---

## Bước 5 — Gate 2: Summary và xác nhận

Hiển thị bảng tổng kết theo format sau:

```
╔══ GATE 2 · CONFIG SUMMARY ═══════════════════════════╗
║  IP: rv32im_core   Spec rev: 0.2                    ║
╠══ Parameters thay đổi so với default ════════════════╣
║  (Liệt kê từng parameter đã thay đổi: tên, old→new) ║
║  (Nếu không có: "Tất cả giữ default")               ║
╠══ Constraints ════════════════════════════════════════╣
║  C1 [PASS/FAIL]  C2 [PASS/FAIL]  C3 [PASS/FAIL]    ║
║  C4 [PASS/FAIL]  C5 [PASS/FAIL]                     ║
╠══ Features enabled ═══════════════════════════════════╣
║  ✓ Mandatory: F01 F02 F03 F04 F05 F06 F07 F08       ║
║               F09 F10 F11 F12 F13 F14 F15 F17       ║
║  ✓ Optional:  (liệt kê các F đang bật)              ║
║  ✗ Disabled:  (liệt kê các F đang tắt)              ║
╠══ Style constraints ══════════════════════════════════╣
║  RTL rule: <selected file> [<source_kind>]           ║
║  Rule bổ sung đã xác nhận: [N]                      ║
╚══════════════════════════════════════════════════════╝
```

Nếu có bất kỳ constraint nào FAIL → **Không mở Gate 2**. Thông báo lỗi và quay về Bước 3.

Nếu tất cả pass, tóm tắt default/changed values, feature impact và constraint results. Giải
thích yes ký cấu hình và mở Gate 2; no giữ gate đóng để chỉnh. Khuyến nghị yes chỉ khi mọi
giá trị phù hợp spec và constraints pass. Sau đó hỏi:

> **"Gate 2 chốt cấu hình đã tóm tắt và cho phép bắt đầu sinh RTL. Khuyến nghị yes vì tất cả constraints pass và values khớp spec. yes lưu cấu hình hiện tại; no giữ gate đóng để chỉnh. Ví dụ: nếu còn parameter sai range, chọn no. Bạn chọn yes/no?"**

- `no` → Quay về Bước 3, cho phép chỉnh sửa.
- `yes` → Tiếp tục Bước 6.

---

## Bước 6 — Ghi output

1. Tạo thư mục `schemas/` nếu chưa tồn tại.
2. Ghi `schemas/final_config.json` với cấu trúc theo `schemas/final_config_schema.json`.
   - `gate_2_approved: true`
   - `approved_at`: timestamp hiện tại (dùng lệnh `date -Iseconds` nếu cần)
   - `style_constraints.source_file` và `style_constraints.source_kind` phải chứa rule file đã chọn; `lint_rules` là danh sách rule bổ sung đã xác nhận (có thể rỗng).
3. Thông báo:

> **"✓ Gate 2 đã ký. `schemas/final_config.json` đã được ghi.
> Phase 3 (RTL Generator + SVA Generator) có thể bắt đầu với `/rtl_generator`."**

---

## Xử lý lỗi

| Tình huống | Hành động |
|---|---|
| `spec_parser.md` và `structured_spec.json` đều không có | Dừng, yêu cầu file spec |
| Không có user rule file | Dùng `spec_template/VLSIT_RTL_Design_Rule.md` trong repository |
| Rule mặc định không tồn tại/đọc được | Dừng Gate 2, yêu cầu user cung cấp rule file; không ghi config thiếu rule |
| User rule file không tồn tại/đọc được | Dừng Gate 2, yêu cầu người dùng cung cấp lại file; không tự thay bằng default |
| Người dùng nhập value ngoài range | Từ chối, giải thích range hợp lệ, hỏi lại |
| Constraint vi phạm sau thay đổi hàng loạt | Liệt kê tất cả vi phạm cùng lúc trước khi yêu cầu sửa |
| `schemas/final_config.json` đã tồn tại | So sánh file hiện tại với config mới, nêu giá trị bị thay đổi và hậu quả overwrite; đưa lựa chọn review/overwrite/keep, ví dụ cho biết P05 đổi từ giá trị nào sang giá trị nào; khuyến nghị review nếu file có chỉnh sửa thủ công. |
