# RTL Files / Tệp RTL

## English

Synthesizable SystemVerilog for the single supported top, `m_ahb2axi_top`. The controller uses the AHB and AXI boundary modules and five synchronous FIFO instances from `common_rtl/002_SyncFIFO`.

Compile the sources in `filelist.f` with top `m_ahb2axi_top`. The filelist includes the reused FIFO RTL. The [rule-check report](rule_check_report.md) records 0 errors and 2 advisory warnings. [Verilator lint](lint_verilator_final.log) passed with 0 errors and 27 warnings; the warnings are documented in the project README. No testbench is included and functional simulation has not been run.

## Tiếng Việt

SystemVerilog tổng hợp được cho top duy nhất `m_ahb2axi_top`. Controller dùng module giao diện AHB, AXI và năm FIFO đồng bộ từ `common_rtl/002_SyncFIFO`.

Biên dịch các file trong `filelist.f` với top `m_ahb2axi_top`. Filelist có RTL FIFO dùng lại. [Báo cáo rule-check](rule_check_report.md) ghi nhận 0 lỗi và 2 cảnh báo tham khảo. [Log Verilator](lint_verilator_final.log) đạt với 0 lỗi và 27 cảnh báo; README dự án giải thích cảnh báo. Không có testbench; chưa chạy mô phỏng chức năng.
