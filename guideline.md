# Step-by-step User Guide | Hướng dẫn từng bước

**EN:** Claude Code commands and Codex CLI skills are prompts entered in their chats, not terminal commands. Work in this repository or a copy/branch of it. The agent creates design outputs in the working design root; the saved `example/` folders are historical references.

**VI:** Command Claude Code và skill Codex CLI là prompt nhập trong hội thoại, không phải lệnh terminal. Làm việc trong repository này hoặc bản sao/branch của nó. Agent tạo output tại root của thiết kế đang làm; thư mục `example/` chỉ là ví dụ lịch sử.

## 0. Prepare the specification | Chuẩn bị đặc tả

**EN:** Create `spec/<ip_name>_spec.md` with ports, parameters, clock/reset, observable behavior, timing, error handling, and exact protocol-standard revision when applicable. You may start from [the IP template](spec_template/VLSIT_ASIC_IP_Design_Specification_Template.md). If you only have a description, use `/spec_writer` or `/autoflow --describe`, then review the draft before parsing.

**VI:** Tạo `spec/<ip_name>_spec.md` với port, parameter, clock/reset, hành vi quan sát được, timing, xử lý lỗi và phiên bản chuẩn giao thức khi áp dụng. Có thể bắt đầu từ [mẫu IP](spec_template/VLSIT_ASIC_IP_Design_Specification_Template.md). Nếu mới có mô tả, dùng `/spec_writer` hoặc `/autoflow --describe`, rồi review bản nháp trước khi parse.

**Example / Ví dụ:** For an 8-bit, 16-entry FIFO, create `spec/fifo_spec.md` and specify reset polarity, ready/valid behavior, full/empty handling, and cycle timing. This file is an example path; it is not included in the repository. / Với FIFO rộng 8 bit, sâu 16 phần tử, tạo `spec/fifo_spec.md` và nêu rõ cực tính reset, ready/valid, full/empty và timing theo chu kỳ. File này chỉ là ví dụ, không có sẵn trong repository.

## 1. Choose automatic or manual execution | Chọn chạy tự động hoặc từng bước

**EN:** For the full flow, enter `/autoflow spec/fifo_spec.md` in Claude Code. In Codex CLI, invoke `$source-command-autoflow` and provide the same path. To run one phase at a time, follow Steps 2–10 below. The [README](README.md) maps each Claude command to its Codex skill.

**VI:** Để chạy toàn flow, nhập `/autoflow spec/fifo_spec.md` trong Claude Code. Trong Codex CLI, gọi `$source-command-autoflow` và cung cấp cùng đường dẫn. Để chạy từng phase, theo Bước 2–10 dưới đây. [README](README.md) ánh xạ command Claude với skill Codex.

## 2. Parse requirements — Gate 1 | Parse yêu cầu — Gate 1

**EN:** Run `/spec_parser spec/fifo_spec.md`. Review REQ-IDs, source clauses, ambiguity, and parameter/module mappings. Approve Gate 1 only after unresolved behavior is settled. Output: `schemas/structured_spec.json`.

**VI:** Chạy `/spec_parser spec/fifo_spec.md`. Review REQ-ID, nguồn yêu cầu, điểm mơ hồ và mapping parameter/module. Chỉ duyệt Gate 1 khi hành vi chưa rõ đã được giải quyết. Output: `schemas/structured_spec.json`.

## 3. Set configuration — Gate 2 | Chốt cấu hình — Gate 2

**EN:** Run `/config_ui`. Check legal parameter values and constraints. Supply an RTL rule file if needed; otherwise the default is `spec_template/VLSIT_RTL_Design_Rule.md`. Output: `schemas/final_config.json`. A standalone run needs your approval; full autoflow may approve unchanged defaults when every constraint passes.

**VI:** Chạy `/config_ui`. Kiểm tra giá trị parameter và constraint hợp lệ. Có thể cung cấp RTL rule riêng; nếu không, dùng `spec_template/VLSIT_RTL_Design_Rule.md`. Output: `schemas/final_config.json`. Chạy riêng cần bạn duyệt; autoflow có thể tự duyệt giá trị mặc định khi mọi constraint đạt.

## 4. Approve the verification contract — Gate 3a | Duyệt verification contract — Gate 3a

**EN:** Run `/verification_contract`. Review the contract-level interface, expected behavior, exact standard revisions/clauses, and open questions. This phase reads the approved specification and configuration, not generated RTL. Outputs: `schemas/verification_contract.json` and `src/verification/contract_if.sv`. Approve Gate 3a before generating verification artifacts.

**VI:** Chạy `/verification_contract`. Review interface, expected behavior, phiên bản/điều khoản chuẩn và vấn đề còn mở. Phase này đọc đặc tả và cấu hình đã duyệt, không đọc RTL được sinh. Output: `schemas/verification_contract.json` và `src/verification/contract_if.sv`. Duyệt Gate 3a trước khi sinh artifact verification.

## 5. Generate RTL | Sinh RTL

**EN:** Run `/rtl_generator`. It uses the approved specification, configuration, and RTL rule file. Inspect `src/rtl/`, `src/rtl/filelist.f`, lint logs, and `schemas/synth_report.json` when synthesis runs. Unavailable checks must be reported as not run.

**VI:** Chạy `/rtl_generator`. Phase này dùng đặc tả, cấu hình và RTL rule đã duyệt. Kiểm tra `src/rtl/`, `src/rtl/filelist.f`, log lint và `schemas/synth_report.json` nếu synthesis đã chạy. Công cụ không khả dụng phải được báo là chưa chạy.

## 6. Generate SVA — Gate 3b | Sinh SVA — Gate 3b

**EN:** Run `/sva_generator`. Review the meaning and REQ-ID trace of interface-level properties, then approve Gate 3b. SVA is compiled against the contract interface shell; this checks syntax/elaboration, not DUT behavior. Output: `src/sva/` and approval records in `schemas/rtm.json`.

**VI:** Chạy `/sva_generator`. Review ý nghĩa property ở interface và trace tới REQ-ID, rồi duyệt Gate 3b. SVA được compile với interface shell của contract; bước này kiểm tra syntax/elaboration, không chứng minh DUT pass. Output: `src/sva/` và approval trong `schemas/rtm.json`.

## 7. Generate tests — Gate 4 | Sinh testcase — Gate 4

**EN:** Run `/tb_generator`. Review the test plan and uncovered REQ-IDs. Tests come from the approved contract and golden sources, not RTL. Check saved files in `src/tb/tests/` and `schemas/selected_testplan.json`. Shell compilation precedes Gate 4; a standalone run needs your approval, while full autoflow may approve a complete, clean plan.

**VI:** Chạy `/tb_generator`. Review test plan và REQ-ID chưa được cover. Test lấy từ contract và golden sources đã duyệt, không lấy từ RTL. Kiểm tra file trong `src/tb/tests/` và `schemas/selected_testplan.json`. Shell compile diễn ra trước Gate 4; chạy riêng cần bạn duyệt, còn autoflow có thể tự duyệt plan đầy đủ và không lỗi.

**EN:** The steps above follow `/autoflow`. In a manual run, Step 5 may start as soon as Gate 2 is approved; Steps 6–7 require Gate 3a. RTL and verification generation stay independent until DUT integration.

**VI:** Thứ tự trên theo `/autoflow`. Khi chạy từng phase, Bước 5 có thể bắt đầu ngay sau Gate 2; Bước 6–7 cần Gate 3a. Việc sinh RTL và verification độc lập đến khi tích hợp DUT.

## 8. Integrate and verify | Tích hợp và kiểm chứng

**EN:** Run `/verification`. The adapter connects contract signals to the DUT; mismatched ports or behavior are failures, not reasons to change the oracle. Review actual compile, testcase, SVA, mutation, and baseline coverage evidence in `schemas/rtm.json`, `schemas/verification_report.json`, and `work/`.

**VI:** Chạy `/verification`. Adapter nối tín hiệu contract với DUT; port hoặc hành vi không khớp là lỗi, không phải lý do sửa oracle. Review bằng chứng compile, testcase, SVA, mutation và baseline coverage trong `schemas/rtm.json`, `schemas/verification_report.json` và `work/`.

## 9. Optional coverage target, then Gate 5 | Ngưỡng coverage tùy chọn, rồi Gate 5

**EN:** Before Gate 5 sign-off, use `/code_coverage` if you want a target. The agent must show a measured metric and baseline first. Example: if line coverage is 48%, you may select 60%; added tests are saved and rerun through the Makefile. A target is optional. Return to `/verification` for the Gate 5 dashboard and approve only evidence-backed results.

**VI:** Trước khi ký Gate 5, dùng `/code_coverage` nếu muốn đặt ngưỡng. Agent phải hiển thị metric và baseline đã đo trước. Ví dụ: line coverage 48%, bạn có thể chọn 60%; testcase bổ sung được lưu và chạy lại qua Makefile. Ngưỡng là tùy chọn. Quay lại `/verification` để xem dashboard Gate 5 và chỉ duyệt kết quả có bằng chứng.

## 10. Produce documentation | Tạo tài liệu

**EN:** After Gate 5 approval, run `/spec_pdf_generator`. Inspect `docs/specification.md`; `docs/specification.pdf` is created only when a PDF converter is available. Missing evidence must be marked TBD or N/A, never pass.

**VI:** Sau khi duyệt Gate 5, chạy `/spec_pdf_generator`. Kiểm tra `docs/specification.md`; chỉ tạo `docs/specification.pdf` khi có công cụ chuyển đổi. Bằng chứng thiếu phải ghi TBD hoặc N/A, không được ghi pass.

## Reproduce or resume | Chạy lại hoặc tiếp tục

**EN:** The agent creates or extends one design-root `Makefile` for lint, synthesis, compilation, tests, regression, mutation, and coverage. Use `make help` to list targets and `make -n <target>` to inspect the actual commands. Tools and PDK paths in `sourceme.sh` must be adapted to the Linux EDA host; do not run this Bash script in PowerShell. To resume, for example, enter `/autoflow spec/fifo_spec.md --from phase5`; the agent must validate saved approvals and revisions first.

**VI:** Agent tạo hoặc mở rộng một `Makefile` tại root thiết kế cho lint, synthesis, compile, testcase, regression, mutation và coverage. Dùng `make help` xem target và `make -n <target>` xem lệnh thực tế. Cần điều chỉnh đường dẫn tool/PDK trong `sourceme.sh` cho máy EDA Linux; không chạy script Bash này trong PowerShell. Ví dụ tiếp tục: `/autoflow spec/fifo_spec.md --from phase5`; agent phải kiểm tra approval và revision đã lưu trước.
