---
name: source-command-rtl-generator
description: "Generate and synthesize RV32IM RTL from an approved specification and configuration, reporting actual lint and synthesis results."
---

# source-command-rtl-generator

Use this skill when the user asks for this phase of the repository's RTL design and verification workflow.

## Codex CLI execution notes

- Run this workflow in Codex; `/phase_name` denotes a source Claude command. Read a peer phase skill only when this workflow requires it.
- Preserve all gates. Only full autoflow may auto-approve Gate 2 and Gate 4 where the procedure permits; other approvals remain explicit.
- Adapt RV32IM and Linux/Bash assumptions to the requested IP and environment. Treat `Result/` as historical snapshots, not the active baseline.
- Report EDA results only after running the tool and inspecting its output. `sourceme.sh` is Linux/Bash-dependent; do not run it in PowerShell, and mark unavailable checks as not run.

## Token-efficient artifact reads

For an existing design, run `python scripts/prepare_skill_context.py --phase source-command-rtl-generator --root <design-root>` before selecting artifacts. Summarize large logs with `python scripts/summarize_eda_log.py <log-path>` and inspect cited lines in the original. These are navigation aids, not verification evidence; avoid dumping full trees or logs.

## Reusable skill improvement

At completion, assess whether observed issues justify a high-impact improvement across designs. Follow `.agents/skill_maintenance.md` and `scripts/propose_skill_update.py`; present a qualifying proposal and ask approval for the exact change. Never edit this skill or its support files without explicit user confirmation. If none qualifies, say so briefly.

## Workflow source
# Phase 3a · RTL Generator — /rtl_generator

**Mục tiêu:** Sinh các module SystemVerilog-2012 của `m_rv32im_core`, tag REQ-ID vào từng block,
lint từng module ngay sau khi sinh, rồi chạy synthesis gate với GF180MCU.

**Không làm trong command này:** sinh SVA (dùng `/sva_generator`), sinh testbench, chạy simulation.

---

## Quy tắc bất di bất dịch

1. Sinh xong một module → lint ngay → lint pass → mới sang module tiếp theo.
2. Synth fail → phân tích lỗi, sửa RTL, chạy lại. Không báo "done" khi synth chưa pass.
3. Mọi file RTL phải có `` `default_nettype none `` ở dòng đầu và `` `default_nettype wire `` ở dòng cuối.
4. Không tự quyết định logic không có trong spec. Nếu spec mơ hồ → dừng, hỏi người dùng.
5. Gate 3 mở sau `/sva_generator`, không phải ở đây.
6. RTL design rule được chọn là yêu cầu bắt buộc. Nếu ví dụ hoặc chỉ dẫn RV32IM bên dưới mâu thuẫn với rule file, sửa ví dụ để tuân thủ rule; không coi module map cũ là ngoại lệ.

---

## Bước 1 — Pre-flight

Thực hiện theo thứ tự, dừng ngay nếu bất kỳ bước nào fail:

1. Đọc `schemas/final_config.json` → trích toàn bộ `parameters` (values đã xác nhận ở Gate 2).
   - Nếu `gate_2_approved != true` → dừng: _"Gate 2 chưa ký. Chạy `/config_ui` trước."_
2. Đọc `schemas/structured_spec.json` → trích danh sách `requirements` (REQ-IDs và text).
   - Nếu không tồn tại → dùng feature IDs (F01–F19) làm placeholder, ghi nhận warning.
3. Đọc `spec_parser.md` toàn bộ — đây là nguồn spec chính cho mọi module.
4. Chọn và đọc toàn bộ RTL design rule:
   - Nếu người dùng cung cấp rule file trong yêu cầu hiện tại, dùng file đó.
   - Nếu không, chỉ dùng `style_constraints.source_file` từ config khi `source_kind` là `user_supplied`; nếu không có bằng chứng đó (kể cả config cũ chỉ ghi `rtl_rule.md`), dùng `spec_template/VLSIT_RTL_Design_Rule.md` ở repository root (đường dẫn hiện tại: `C:\HQuan\102_MyGithub\VLSIT_RTL_Generator_AI_Model\spec_template\VLSIT_RTL_Design_Rule.md`).
   - Nếu config đã được duyệt ghi một `source_file`/`source_kind` khác với file người dùng chọn ở yêu cầu hiện tại, dừng và yêu cầu chạy lại Config UI/xác nhận; không tự đổi rule sau Gate 2.
   - Nếu file được chọn không tồn tại hoặc không đọc được, dừng và yêu cầu người dùng cung cấp rule file hợp lệ. Không dùng `rtl_rule.md` từ `Result/` làm mặc định.
5. Tạo `src/rtl/` nếu chưa tồn tại.
6. Kiểm tra `module load oss-cad-suite` khả dụng:
   ```bash
   module load oss-cad-suite && verilator --version
   ```
   Nếu fail → dừng: _"oss-cad-suite không load được. Kiểm tra môi trường module."_

Tóm tắt pre-flight trước khi bắt đầu sinh:
```
Pre-flight OK:
  Gate 2: approved
  Parameters: 15 loaded
  REQ-IDs: N loaded (hoặc WARNING: dùng feature IDs)
  RTL rule: <selected rule file>
  Lint tool: Verilator X.XXX
  Output: src/rtl/
```

---

## Bước 2 — Sinh module theo thứ tự compile

Sinh các module chức năng theo thứ tự dưới đây. Với **mỗi module**:

### Quy trình per-module

**2a. Đọc spec section tương ứng** trong `spec_parser.md`:

| Module | Spec section |
|---|---|
| `m_rv32im_alu` | §11 |
| `m_rv32im_branch_unit` | §12 |
| `m_rv32im_imm_gen` | §8 |
| `m_rv32im_decoder` | §7 |
| `m_rv32im_lsu` | §15 |
| `m_rv32im_regfile` | §9 |
| `m_rv32im_mult` | §13.4 |
| `m_rv32im_div` | §13.5 |
| `m_rv32im_muldiv` | §13 |
| `m_rv32im_hazard_ctrl` | §18 |
| `m_rv32im_if_stage` | §5 |
| `m_rv32im_id_stage` | §6 |
| `m_rv32im_ex_stage` | §10 |
| `m_rv32im_csr_file` | §16 |
| `m_rv32im_trap_ctrl` | §17 |
| `m_rv32im_mem_stage` | §14 |
| `m_rv32im_core` | §3 + §4.1 |

Các tên `m_*`, file name và top dưới đây theo rule mặc định. Nếu user rule file quy định khác, đổi nhất quán module/instance/file/top và số module theo rule đó. Với rule mặc định, type ở §4.2 và §4.3 được khai báo module-local trong từng module sử dụng, không tạo package design RTL, và port liên module dùng packed vectors. `m_rv32im_core` là structural top: chỉ khai báo interface/interconnect và instance; chuyển mọi logic chức năng vào child module. Nếu user rule file khác, áp dụng quy định của file đó.

**2b. Sinh file SystemVerilog** vào `src/rtl/<module_name>.sv`; module name và file name phải cùng tuân thủ prefix `m_` theo rule mặc định.

Template bắt buộc cho mọi file:
```systemverilog
`default_nettype none
//==============================================================================
// Project      : <PROJECT_NAME>
// Author       : <USER_NAME> (user)
// AI Flow      : VLSIT RTL Generator AI Automation Flow
// AI Flow Page : https://github.com/nguyenquanicd/VLSIT_RTL_Generator_AI_Model
// Date         : YYYY-MM-DD
// Description  : <mô tả 1 dòng từ spec>
// Module       : <module_name>
// Parent      : <parent module>
// Spec ref    : spec_parser.md §<số>
// REQ-IDs     : REQ-xxx, REQ-yyy  (hoặc F01, F02 nếu chưa có structured_spec)
//==============================================================================
`timescale 1ns/1ps
module m_<function>
#(
  // PARA_* parameters theo RTL rule và mapping sang parameter trong spec
  // LPARA_* localparams ngay sau parameter list khi cần
) (
  // ---- Clock & Reset ----
  // ---- <nhóm port> ---- // REQ-xxx
  ...
);
  // Module-local typedefs from spec §4.2/§4.3, if used; names follow the selected RTL rule.
  // khai báo reg_* rồi w_*
  // always_comb process name: p_com_<function>
  // always_ff process name: p_ff_<function>
  // instance submodule với tên u_<module-function> theo RTL rule
  `ifndef SYNTHESIS
  // assertions (placeholder — sẽ được fill bởi /sva_generator)
  `endif
endmodule
`default_nettype wire
```

**Quy tắc tagging REQ-ID trong RTL:**
- Header comment: `// REQ-IDs: REQ-xxx, REQ-yyy`
- Cuối mỗi `always_comb` / `always_ff` block liên quan đến một requirement: `// REQ-xxx`
- Port group: `// ---- <tên nhóm> ---- // REQ-xxx` nếu port trực tiếp implement requirement đó

**Parameter substitution:** Lấy giá trị đã duyệt từ `final_config.json`. Tên parameter trong RTL phải theo rule file đã chọn; nếu tên trong spec khác quy ước RTL (ví dụ `PR_M_EXT_EN` so với `PARA_M_EXT_EN`), ghi mapping rõ ràng và dùng nhất quán trong module, instance override, filelist và báo cáo. Ví dụ nếu parameter tương ứng với `PR_M_EXT_EN = 0` thì trong `m_rv32im_decoder`, nhánh RV32M decode ra `o_illegal = 1`.

**2c. Chạy lint ngay sau khi sinh:**
```bash
module load oss-cad-suite
verilator --lint-only --sv -Wall \
  +incdir+src/rtl \
  src/rtl/<module_name>.sv \
  2>&1
```
_(Đọc và lint các module phụ thuộc đã sinh khi cần. Không thêm package design RTL khi dùng rule mặc định.)_

- **Lint pass (0 warning/error)** → thông báo `✓ <module_name> lint OK` → tiếp tục module tiếp.
- **Lint fail** → hiển thị lỗi, phân tích nguyên nhân, sửa file, lint lại. Không sang module tiếp cho đến khi pass.

**Loại warning phải fix (không dùng `-Wno-` để suppress):**
- `UNOPTFLAT` — latch hoặc combinational loop
- `MULTIDRIVEN` — multi-driven net
- `WIDTH` — width mismatch
- `UNUSED` — signal khai báo nhưng không dùng (gợi ý xem lại spec)
- `LATCH` — latch không chủ ý

### Thứ tự module chức năng (không sinh package design RTL theo rule mặc định)

```
[1/17]  m_rv32im_alu          → src/rtl/m_rv32im_alu.sv
[2/17]  m_rv32im_branch_unit  → src/rtl/m_rv32im_branch_unit.sv
[3/17]  m_rv32im_imm_gen      → src/rtl/m_rv32im_imm_gen.sv
[4/17]  m_rv32im_decoder      → src/rtl/m_rv32im_decoder.sv
[5/17]  m_rv32im_lsu          → src/rtl/m_rv32im_lsu.sv
[6/17]  m_rv32im_regfile      → src/rtl/m_rv32im_regfile.sv
[7/17]  m_rv32im_mult         → src/rtl/m_rv32im_mult.sv
[8/17]  m_rv32im_div          → src/rtl/m_rv32im_div.sv
[9/17]  m_rv32im_muldiv       → src/rtl/m_rv32im_muldiv.sv
[10/17] m_rv32im_hazard_ctrl  → src/rtl/m_rv32im_hazard_ctrl.sv
[11/17] m_rv32im_if_stage     → src/rtl/m_rv32im_if_stage.sv
[12/17] m_rv32im_id_stage     → src/rtl/m_rv32im_id_stage.sv
[13/17] m_rv32im_ex_stage     → src/rtl/m_rv32im_ex_stage.sv
[14/17] m_rv32im_csr_file     → src/rtl/m_rv32im_csr_file.sv
[15/17] m_rv32im_trap_ctrl    → src/rtl/m_rv32im_trap_ctrl.sv
[16/17] m_rv32im_mem_stage    → src/rtl/m_rv32im_mem_stage.sv
[17/17] m_rv32im_core         → src/rtl/m_rv32im_core.sv
```

---

## Bước 3 — Sinh filelist.f

Sau khi tất cả module chức năng đã sinh và lint sạch, tạo `src/rtl/filelist.f`:

```
src/rtl/m_rv32im_alu.sv
src/rtl/m_rv32im_branch_unit.sv
src/rtl/m_rv32im_imm_gen.sv
src/rtl/m_rv32im_decoder.sv
src/rtl/m_rv32im_lsu.sv
src/rtl/m_rv32im_regfile.sv
src/rtl/m_rv32im_mult.sv
src/rtl/m_rv32im_div.sv
src/rtl/m_rv32im_muldiv.sv
src/rtl/m_rv32im_hazard_ctrl.sv
src/rtl/m_rv32im_if_stage.sv
src/rtl/m_rv32im_id_stage.sv
src/rtl/m_rv32im_ex_stage.sv
src/rtl/m_rv32im_csr_file.sv
src/rtl/m_rv32im_trap_ctrl.sv
src/rtl/m_rv32im_mem_stage.sv
src/rtl/m_rv32im_core.sv
```

Chạy lint full design một lần nữa để verify không có cross-module issue:
```bash
module load oss-cad-suite
verilator --lint-only --sv -Wall --top-module m_rv32im_core -f src/rtl/filelist.f 2>&1
```

---

## Bước 4 — Synthesis Gate (Gate 3a)

### 4a. Chuẩn bị Yosys synthesis script

Tạo `src/rtl/synth_gf180_tt.ys`:
```tcl
# Synthesis script — GF180MCU TT 25C 1.8V
set GF180_TT "/tools/PDK/GF180/globalfoundries-pdk-libs-gf180mcu_fd_sc_mcu7t5v0/liberty/gf180mcu_fd_sc_mcu7t5v0__tt_025C_1v80.lib"

read_verilog -sv -f src/rtl/filelist.f
hierarchy -check -top m_rv32im_core
proc
opt -full
memory
opt -full
techmap
opt -fast
dfflibmap -liberty $GF180_TT
abc -liberty $GF180_TT -D 5000
opt_clean -purge
stat -liberty $GF180_TT
write_json src/rtl/synth_gf180_tt.json
```

Tạo `src/rtl/synth_gf180_ss.ys` (SS corner — worst case):
```tcl
set GF180_SS "/tools/PDK/GF180/globalfoundries-pdk-libs-gf180mcu_fd_sc_mcu7t5v0/liberty/gf180mcu_fd_sc_mcu7t5v0__ss_125C_1v62.lib"

read_verilog -sv -f src/rtl/filelist.f
hierarchy -check -top m_rv32im_core
proc
opt -full
memory
opt -full
techmap
opt -fast
dfflibmap -liberty $GF180_SS
abc -liberty $GF180_SS -D 5000
opt_clean -purge
stat -liberty $GF180_SS
write_json src/rtl/synth_gf180_ss.json
```

### 4b. Chạy synthesis

```bash
module load oss-cad-suite

echo "=== Synthesis TT corner ==="
yosys -l src/rtl/synth_tt.log src/rtl/synth_gf180_tt.ys

echo "=== Synthesis SS corner ==="
yosys -l src/rtl/synth_ss.log src/rtl/synth_gf180_ss.ys
```

### 4c. Kiểm tra kết quả

Kết quả **PASS** khi:
- Không có `ERROR:` trong log
- `hierarchy -check` không báo missing module
- `stat` xuất ra số cell count > 0

Kết quả **FAIL** khi:
- Có `ERROR:` → phân tích: thường là construct không synthesizable (`initial`, `#delay`, `$display` trong RTL)
- Fix ngay trong file RTL tương ứng, lint lại module đó, chạy lại toàn bộ synth

### 4d. Ghi synth_report.json

Sau khi cả hai corner pass, trích số liệu từ log và ghi `schemas/synth_report.json`:

```json
{
  "tool": "Yosys 0.58",
  "pdk": "GF180MCU",
  "top_module": "m_rv32im_core",
  "corners": {
    "tt_025C_1v80": {
      "status": "pass",
      "cell_count": <trích từ log>,
      "area_estimate_um2": null,
      "log": "src/rtl/synth_tt.log"
    },
    "ss_125C_1v62": {
      "status": "pass",
      "cell_count": <trích từ log>,
      "area_estimate_um2": null,
      "log": "src/rtl/synth_ss.log"
    }
  },
  "req_ids_tagged": <đếm số REQ-ID comments trong src/rtl/>,
  "generated_at": "<timestamp>"
}
```

---

## Bước 5 — Báo cáo tổng kết

```
╔══ RTL GENERATOR REPORT ══════════════════════════════╗
║  Modules sinh: N/N                                  ║
║  Lint status:  ✓ N/N pass (0 warning)               ║
║  Synth TT:     ✓ pass — XXX cells                   ║
║  Synth SS:     ✓ pass — XXX cells                   ║
║  REQ-IDs tagged: N tags trong N files               ║
╠══ Files tạo ra ══════════════════════════════════════╣
║  src/rtl/m_rv32im_*.sv  (N module files)            ║
║  src/rtl/filelist.f                                 ║
║  src/rtl/synth_gf180_tt.ys                          ║
║  src/rtl/synth_gf180_ss.ys                          ║
║  schemas/synth_report.json                          ║
╠══ Bước tiếp theo ════════════════════════════════════╣
║  Chạy /sva_generator để sinh SVA và mở Gate 3       ║
╚══════════════════════════════════════════════════════╝
```

---

## Xử lý lỗi

| Tình huống | Hành động |
|---|---|
| `final_config.json` không tồn tại | Dừng, yêu cầu chạy `/config_ui` |
| Gate 2 chưa ký | Dừng, yêu cầu ký Gate 2 |
| Spec section không rõ ràng | Dừng, hỏi người dùng — không tự đoán |
| Lint warning `UNUSED` | Xem lại spec, nếu signal thực sự không dùng thì xoá, không dùng `-Wno-UNUSED` |
| Synth: missing cell từ GF180 | Kiểm tra construct có synthesizable không (`initial`, `$`-tasks, v.v.) |
| `src/rtl/<module>.sv` đã tồn tại | Hỏi "Ghi đè?" trước khi overwrite |
