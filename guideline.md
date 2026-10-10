# User Guide | Hướng dẫn sử dụng

**EN:** This guide covers the specification-driven RTL and independent verification flow. Claude Code commands and Codex CLI skills are agent instructions entered in their chats, not shell commands.

**VI:** Hướng dẫn này mô tả flow tạo RTL từ đặc tả và kiểm chứng độc lập. Command của Claude Code và skill của Codex CLI được nhập trong hội thoại, không phải lệnh terminal.

## 1. Prepare | Chuẩn bị

- **EN:** Write a hardware specification with ports, parameters, clock/reset, behavior, timing, error handling, and exact protocol-standard revision when applicable. Start from [the IP specification template](spec_template/VLSIT_ASIC_IP_Design_Specification_Template.md) if useful.
- **VI:** Viết đặc tả phần cứng gồm port, parameter, clock/reset, chức năng, timing, xử lý lỗi và phiên bản chuẩn giao thức khi áp dụng. Có thể bắt đầu từ [mẫu đặc tả IP](spec_template/VLSIT_ASIC_IP_Design_Specification_Template.md).
- **EN:** On a Linux EDA host, review tool and PDK paths in `sourceme.sh` before running `source sourceme.sh`. On Windows, use WSL or an EDA host; this Bash script does not run directly in PowerShell.
- **VI:** Trên máy EDA Linux, kiểm tra đường dẫn công cụ và PDK trong `sourceme.sh` trước khi chạy `source sourceme.sh`. Trên Windows, dùng WSL hoặc máy chủ EDA; script Bash này không chạy trực tiếp trong PowerShell.

## 2. Example | Ví dụ

**EN:** Suppose the design is an 8-bit, 16-entry synchronous FIFO. Save its specification as `spec/fifo_spec.md`. State reset polarity, ready/valid handshake, full and empty behavior, and cycle timing explicitly. The path and values below are illustrative; replace them with the approved design specification.

**VI:** Giả sử thiết kế là FIFO đồng bộ rộng 8 bit, sâu 16 phần tử. Lưu đặc tả tại `spec/fifo_spec.md`. Ghi rõ cực tính reset, giao tiếp ready/valid, xử lý full/empty và timing theo chu kỳ. Đường dẫn và giá trị này chỉ là ví dụ; dùng đặc tả đã duyệt của thiết kế thực tế.

In **Claude Code**, enter:

```text
/autoflow spec/fifo_spec.md
```

In **Codex CLI**, enter:

```text
$source-command-autoflow
Use spec/fifo_spec.md.
```

**EN:** If no specification exists, use `/autoflow --describe` in Claude Code or ask the Codex autoflow skill to draft one from your description. Review the draft before parsing. For individual phases, use the [command and skill mapping](README.md).

**VI:** Nếu chưa có đặc tả, dùng `/autoflow --describe` trong Claude Code hoặc yêu cầu skill autoflow của Codex soạn từ mô tả. Review bản nháp trước khi phân tích yêu cầu. Để chạy từng bước, xem [bảng command và skill](README.md).

## 3. Flow and approvals | Flow và các bước duyệt

```text
Specification → requirements (Gate 1) → configuration (Gate 2)
→ verification contract (Gate 3a)
→ RTL branch + verification branch (SVA Gate 3b; test plan Gate 4)
→ DUT integration and verification → optional code-coverage target
→ user sign-off (Gate 5) → final documentation
```

**EN:** Gate 1, 3a, 3b, and 5 require user review. Full autoflow may approve Gate 2 and Gate 4 when their checks pass. The verification contract, assertions, tests, and expected outcomes come from the approved specification and applicable standards, not generated RTL. Before DUT integration, SVA and testbench compile against a contract-derived interface shell; that compile is not a DUT pass.

**VI:** Gate 1, 3a, 3b và 5 cần người dùng duyệt. Autoflow có thể tự duyệt Gate 2 và Gate 4 khi các điều kiện đạt. Verification contract, assertion, testcase và expected result lấy từ đặc tả và chuẩn đã duyệt, không lấy từ RTL được sinh. Trước khi tích hợp DUT, SVA và testbench compile với interface shell tạo từ contract; kết quả đó không chứng minh DUT pass.

**EN:** After baseline simulation, the coverage step shows the measured metric and percentage before asking for a target. For example, if line coverage is 48%, you may choose 60%; the flow saves added specification-based tests and reruns them. A target is optional, and an unmet target is reported as unmet.

**VI:** Sau baseline simulation, bước coverage hiển thị loại metric và tỷ lệ đã đo trước khi hỏi ngưỡng. Ví dụ, nếu line coverage là 48%, bạn có thể chọn 60%; flow lưu testcase bổ sung theo đặc tả rồi chạy lại. Ngưỡng là tùy chọn; nếu chưa đạt, báo đúng trạng thái chưa đạt.

## 4. Inspect and resume | Kiểm tra và tiếp tục

**EN:** The design root contains one documented `Makefile` for lint, synthesis, compilation, tests, regression, mutation, and coverage. All test files remain in `src/tb/tests/`; approval and result records are in `schemas/`; logs are in `work/`. Use `make help` to list targets and `make -n <target>` to inspect commands. A missing tool or unrun check is not a pass.

**VI:** Root của thiết kế có một `Makefile` mô tả lint, synthesis, compile, testcase, regression, mutation và coverage. Testcase được lưu trong `src/tb/tests/`; approval và kết quả nằm trong `schemas/`; log nằm trong `work/`. Dùng `make help` để xem target và `make -n <target>` để xem lệnh. Thiếu công cụ hoặc chưa chạy kiểm tra không được tính là pass.

**EN:** To resume in Claude Code, for example, use `/autoflow spec/fifo_spec.md --from phase5`. In Codex CLI, ask the autoflow skill to resume from phase 5. The agent must check that saved artifacts match the current specification and configuration before reusing approvals or results.

**VI:** Ví dụ tiếp tục trong Claude Code: `/autoflow spec/fifo_spec.md --from phase5`. Trong Codex CLI, yêu cầu skill autoflow tiếp tục từ phase 5. Agent phải kiểm tra artifact đã lưu khớp đặc tả và cấu hình hiện tại trước khi dùng lại approval hoặc kết quả.
