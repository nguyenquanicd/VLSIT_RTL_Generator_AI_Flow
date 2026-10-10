# Project scripts

**VI:**

- `md_to_pdf.py` chuyển Markdown sang PDF; cần Python 3 và Matplotlib.
- `prepare_skill_context.py` lập chỉ mục artifact theo phase, không in nội dung file đầy đủ.
- `summarize_eda_log.py` trích các dòng chẩn đoán có số dòng và giới hạn output.
- `propose_skill_update.py` chỉ in đề xuất khi có lợi ích lớn, dùng chung cho nhiều thiết kế và có bằng chứng; script không sửa skill.

Ví dụ:

```powershell
python scripts/prepare_skill_context.py --phase source-command-rtl-generator --root Result/DOWNSCALER_03_09_2026
python scripts/summarize_eda_log.py Result/DOWNSCALER_03_09_2026/src/rtl/synth_tt.log
```

**EN:**

- `md_to_pdf.py` converts Markdown to PDF; it requires Python 3 and Matplotlib.
- `prepare_skill_context.py` indexes artifacts for one workflow phase without printing full file contents.
- `summarize_eda_log.py` extracts line-numbered diagnostics with bounded output.
- `propose_skill_update.py` prints a proposal only for high-impact, cross-design improvements backed by evidence; it never edits a skill.

Example:

```powershell
python scripts/prepare_skill_context.py --phase source-command-rtl-generator --root Result/DOWNSCALER_03_09_2026
python scripts/summarize_eda_log.py Result/DOWNSCALER_03_09_2026/src/rtl/synth_tt.log
```
