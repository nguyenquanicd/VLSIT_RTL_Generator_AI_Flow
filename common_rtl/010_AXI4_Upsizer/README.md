# 010_AXI4_Upsizer

## English

Design specification of an AXI upsizer: an AXI subordinate of data width S (narrow side) that drives an AXI manager of data width M > S (wide side), with the ratio set by two parameters (power of 2, 2 to 128), AXI4 and AXI3 profile tops, one clock, a register slice on every channel. Modifiable INCR and WRAP bursts of full S width are packed into wide beats; every other transaction keeps its shape and moves its beats to the right byte lane.

Status (2026-10-28): **specification only, no RTL yet.** `vlsit_spec_tool.py check` passes (0 errors, 22 sections). Thirteen waveforms and the draw.io block diagram are delivered. The algorithm of section 10.2, including the AXI3 write data interleave (WID contexts, DEC-019), was checked on a Python cycle model, not on RTL. Open item: TBD-001 (frequency, area, power targets), left as TBD by the user's request. The combinational circuit is specified in an optimized implementation form (section 10.2, REQ-RTL-004, DEC-021). The AXI3 interleave rules were checked against the Arm AXI Protocol Specification v1.0, IHI 0022B, sections 8.4 and 8.5, converted into the `md_doc` of the specification skill (issue F was not read); see `research/axi3_write_interleave_source.md`. ASM-002, ASM-003 and DEP-004 are confirmed by the user.

| Path | Content |
|---|---|
| [AXI4_Upsizer_Design_Specification.md](AXI4_Upsizer_Design_Specification.md) | The specification (22 sections of the VLSIT template) |
| `figures/` | Block diagram (`axi_upsizer_block_diagram.drawio`, `.svg`, `.png`, diagram spec JSON) and the 13 waveforms (`upsizer_wf001_...` to `upsizer_wf013_...`, WaveJSON source and SVG) |
| `model/` | Reference cycle model of the specification (`ups_cycle_model.py`), the waveform generator (`gen_waveforms.py`) and the byte-level checks (`check_model.py`, `check_interleave.py` for the AXI3 write interleave) and the equivalence check of the optimized combinational forms (`check_equivalence.py`); not RTL |
| `constraints/m_vlsit_axi_upsizer.sdc` | Clock definition and the statement that the IP owns no exception (variable `T_CLK_AXI` set by the SoC) |
| `research/reference_ip_log.md` | Reference IP research log (ideas only, nothing copied) |
| `research/axi3_write_interleave_source.md` | Source and paraphrased rules of the AXI3 write data interleaving (Arm IHI 0022B 8.4, 8.5) |
| `research/source_docs/` | Local copy of the Arm PDF (licensed, ignored by git, never committed) |
| `qa_log.md` | Questions and answers with the user that fixed the decisions DEC-001 to DEC-022 |

Run the model check from `model/`:

```bash
python check_model.py 200 1
python check_interleave.py 200 1 2
python check_equivalence.py
```

Environment variables `UPS_S` and `UPS_M` (bits) select other widths, for example `UPS_S=8 UPS_M=1024`. The waveform files are regenerated with `python gen_waveforms.py <dir>` and rendered with `vlsit_waveform_svg.py render <file> --out <file>.svg --cell 54`.

## Tiếng Việt

Đặc tả của bộ upsizer AXI: subordinate AXI độ rộng dữ liệu S (phía hẹp) điều khiển manager AXI độ rộng M > S (phía rộng), tỷ lệ đặt bằng hai tham số (lũy thừa 2, từ 2 đến 128), hai top AXI4 và AXI3, một clock, register slice trên mọi kênh. Burst INCR và WRAP Modifiable có đúng độ rộng S được gép (pack) thành beat rộng; các giao dịch còn lại giữ nguyên hình dạng và chỉ chuyển beat sang đúng byte lane.

Trạng thái (2026-10-28): **chỉ có đặc tả, chưa có RTL.** `vlsit_spec_tool.py check` pass (0 lỗi, 22 mục). Đã có 13 waveform và sơ đồ khối draw.io. Thuật toán ở mục 10.2, gồm cả interleave write data của AXI3 (ngữ cảnh theo WID, DEC-019), đã được kiểm trên mô hình chu kỳ bằng Python, chưa kiểm trên RTL. Việc còn mở: TBD-001 (mục tiêu tần số, diện tích, công suất), để TBD theo yêu cầu của người dùng. Mạch tổ hợp được đặc tả theo dạng tối ưu (mục 10.2, REQ-RTL-004, DEC-021). Quy tắc interleave AXI3 đã đối chiếu với Arm AXI Protocol Specification v1.0, IHI 0022B, mục 8.4 và 8.5, đã chuyển vào md_doc của skill (chưa đọc issue F); xem `research/axi3_write_interleave_source.md`. ASM-002, ASM-003 và DEP-004 đã được người dùng xác nhận.

Các file như bảng tiếng Anh ở trên. Chạy kiểm tra mô hình từ thư mục `model/` bằng lệnh `python check_model.py 200 1`.
