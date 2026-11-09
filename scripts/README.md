# Project scripts

**VI:**

- `md_to_docx_pdf.py` xuất Markdown có công thức TeX sang DOCX, PDF hoặc cả hai bằng Pandoc. PDF mặc định dùng Typst.
- `md_to_docx.py` và `md_to_pdf.py` là lệnh riêng cho từng định dạng. Cần cài Pandoc; để xuất PDF cần thêm PDF engine như Typst.
- `prepare_skill_context.py` lập chỉ mục artifact theo phase, không in nội dung file đầy đủ.
- `summarize_eda_log.py` trích các dòng chẩn đoán có số dòng và giới hạn output.
- `propose_skill_update.py` chỉ in đề xuất khi có lợi ích lớn, dùng chung cho nhiều thiết kế và có bằng chứng; script không sửa skill.
- `split_fsm_current_state.py` sao chép bộ RTL AXI2APB và tách state register của mỗi FSM thành process `always_ff` riêng.

Ví dụ:

```sh
python scripts/md_to_docx_pdf.py docs/specification.md --format all
python scripts/md_to_docx.py docs/specification.md docs/specification.docx --reference-doc docs/reference.docx
python scripts/md_to_pdf.py docs/specification.md docs/specification.pdf --pdf-engine typst
python scripts/prepare_skill_context.py --phase source-command-rtl-generator --root Result/DOWNSCALER_03_09_2026
python scripts/summarize_eda_log.py Result/DOWNSCALER_03_09_2026/src/rtl/synth_tt.log
python scripts/split_fsm_current_state.py common_rtl/006_AXI2APB_Bridge/rtl common_rtl/006_AXI2APB_Bridge/rtl_v2
```

**VI:** Các lệnh xuất không ghi đè file đã tồn tại nếu thiếu `--force`. Công thức dùng `$...$` hoặc `$$...$$`; đường dẫn hình tương đối được phân giải từ thư mục chứa file Markdown.

**EN:**

- `md_to_docx_pdf.py` exports Markdown with TeX math to DOCX, PDF, or both through Pandoc. PDF uses Typst by default.
- `md_to_docx.py` and `md_to_pdf.py` are single-format entry points. Pandoc is required; PDF also needs a PDF engine such as Typst.
- `prepare_skill_context.py` indexes artifacts for one workflow phase without printing full file contents.
- `summarize_eda_log.py` extracts line-numbered diagnostics with bounded output.
- `propose_skill_update.py` prints a proposal only for high-impact, cross-design improvements backed by evidence; it never edits a skill.
- `split_fsm_current_state.py` copies the AXI2APB RTL set and separates each FSM state register into its own `always_ff` process.

Example:

```sh
python scripts/md_to_docx_pdf.py docs/specification.md --format all
python scripts/md_to_docx.py docs/specification.md docs/specification.docx --reference-doc docs/reference.docx
python scripts/md_to_pdf.py docs/specification.md docs/specification.pdf --pdf-engine typst
python scripts/prepare_skill_context.py --phase source-command-rtl-generator --root Result/DOWNSCALER_03_09_2026
python scripts/summarize_eda_log.py Result/DOWNSCALER_03_09_2026/src/rtl/synth_tt.log
python scripts/split_fsm_current_state.py common_rtl/006_AXI2APB_Bridge/rtl common_rtl/006_AXI2APB_Bridge/rtl_v2
```

**EN:** Export commands refuse to replace existing files unless `--force` is supplied. Write math as `$...$` or `$$...$$`; relative image paths resolve from the Markdown file's directory.
