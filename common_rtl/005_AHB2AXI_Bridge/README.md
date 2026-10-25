# AHB-to-AXI4 Bridge / Cầu nối AHB sang AXI4

## English

This folder contains the specification and RTL for a 32-bit Full AHB5 Subordinate to AXI4 Manager bridge. The design uses one clock (`i_clk_core`) and one active-low reset (`i_rst_n_core`). The SoC synchronizes reset deassertion before it reaches the IP; the RTL has no internal reset synchronizer. Clock frequency is TBD by SoC integration.

The only supported top is `m_ahb2axi_top`. Three functional modules implement the AHB boundary, central control and AXI boundary. The controller instantiates the two interface modules and five reused synchronous FIFOs. USER sidebands are not supported.

Reads are serialized and never speculative. Eligible bufferable Normal Write-back fixed write bursts may map to AXI bursts of up to 16 beats when their address attributes remain constant. Other writes use ordered AXI single-beat transactions.

RTL rule check passed with 0 errors and 2 advisory warnings: the controller combines its required control logic with child instances, and one AHB5 HPROT pattern is reported as a numeric literal. Verilator lint passed with 0 errors and 27 warnings. These are open unused status pins on the reused FIFOs and two unused address-extension bits in the reused `002_SyncFIFO` RTL. No testbench or functional simulation has been generated for this RTL.

## Tiếng Việt

Thư mục này chứa đặc tả và RTL cho cầu nối Full AHB5 Subordinate 32 bit sang AXI4 Manager. Thiết kế dùng một clock (`i_clk_core`) và một reset active-low (`i_rst_n_core`). SoC đồng bộ việc nhả reset trước khi reset vào IP; RTL không có reset synchronizer nội bộ. Tần số clock do SoC quyết định (TBD).

Top duy nhất được hỗ trợ là `m_ahb2axi_top`. Ba module chức năng xử lý giao diện AHB, điều khiển trung tâm và giao diện AXI. Controller tạo instance của hai module giao diện và năm FIFO đồng bộ dùng lại. Không hỗ trợ USER sideband.

Read được tuần tự hóa và không phát request suy đoán. Write burst cố định Normal Write-back có thuộc tính bufferable có thể ghép thành AXI burst tối đa 16 beat nếu thuộc tính địa chỉ không đổi. Các write khác dùng AXI single-beat theo thứ tự.

Rule check RTL đạt với 0 lỗi và 2 cảnh báo tham khảo: controller vừa có logic điều khiển vừa chứa instance con theo kiến trúc đã chọn; một mẫu HPROT của AHB5 bị nhận diện là hằng số số học. Verilator lint đạt với 0 lỗi và 27 cảnh báo. Các cảnh báo này gồm chân trạng thái FIFO dùng lại được để trống và hai bit địa chỉ mở rộng không dùng trong RTL `002_SyncFIFO` dùng lại. Chưa tạo testbench hoặc chạy mô phỏng chức năng cho RTL này.

## Files / Tệp

- [`AHB2AXI_Bridge_Design_Specification.md`](AHB2AXI_Bridge_Design_Specification.md): complete bilingual specification / đặc tả song ngữ.
- [`rtl/`](rtl/): generated RTL, filelist, [rule-check report](rtl/rule_check_report.md) and [final Verilator log](rtl/lint_verilator_final.log) / RTL đã sinh, filelist, báo cáo rule-check và log Verilator cuối.
- [`figures/`](figures/): module diagram and WaveJSON/SVG waveforms / sơ đồ module và waveform WaveJSON/SVG.
- [`research/vlsit_reference_ip_log.md`](research/vlsit_reference_ip_log.md): reference-IP evaluation / đánh giá IP tham chiếu.

The licensed Arm protocol documents are kept outside this folder. Do not copy or redistribute them. / Tài liệu giao thức Arm có giấy phép được giữ ngoài thư mục này; không sao chép hoặc phân phối lại.
