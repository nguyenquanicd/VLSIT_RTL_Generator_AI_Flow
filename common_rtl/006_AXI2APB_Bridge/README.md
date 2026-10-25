# AXI2APB Bridge / Cầu nối AXI4 sang APB4

## English

This folder contains a microarchitecture specification and synthesizable RTL for a 32-bit AXI4 Subordinate to APB4 Manager bridge. It uses one shared clock, one APB port and one active AXI transaction. The bridge has no internal clock/reset synchronizer; the SoC supplies an active-low reset synchronous to the shared clock. The external APB fabric supplies address decoding and a default error Completer.

The spec defines FIXED, INCR and WRAP conversion, subword lanes, ID echo, PPROT mapping, error handling, reset and verification requirements. It includes 14 user-approved waveform examples with WaveJSON sources. The `rtl/` folder contains the structural top, read sequencer, write sequencer and combined arbiter/APB controller, plus a filelist. Rule checks pass; Verilator reports zero errors and one intentional unused `i_axi_wlast` warning because malformed AXI traffic is outside the profile. A testbench has not been requested or generated.

## Tiếng Việt

Thư mục này chứa đặc tả vi kiến trúc và RTL có thể tổng hợp cho bridge AXI4 Subordinate sang APB4 Manager 32 bit. Thiết kế dùng chung một clock, một cổng APB và tối đa một giao dịch AXI đang hoạt động. Bridge không có clock/reset synchronizer nội bộ; SoC cấp reset active-low đã đồng bộ với clock chung. Fabric APB bên ngoài đảm nhiệm giải mã địa chỉ và Completer lỗi mặc định.

Đặc tả quy định chuyển đổi FIXED, INCR, WRAP, lane dữ liệu nhỏ hơn word, phản hồi ID, ánh xạ PPROT, xử lý lỗi, reset và yêu cầu verification. Tài liệu có 14 waveform đã được người dùng duyệt cùng file nguồn WaveJSON. Thư mục `rtl/` có top cấu trúc, read sequencer, write sequencer, controller gộp arbitration/APB và filelist. Chưa tạo testbench vì chưa có yêu cầu.

## Files / Tệp

- [Design specification](AXI2APB_Bridge_Design_Specification.md) / Đặc tả thiết kế
- [RTL hierarchy block diagram (SVG)](figures/vlsit_block_diagram.svg) / Sơ đồ khối hierarchy RTL (SVG)
- [Waveform index and sources](AXI2APB_Bridge_Design_Specification.md#103-cycle-level-behavior) / Danh sách waveform và file nguồn
- [RTL source set and filelist](rtl/filelist.f) / Bộ RTL và filelist
- [Reference IP research](research/vlsit_reference_ip_log.md) / Nghiên cứu IP tham chiếu
- [Decision and QA log](vlsit_qa_log.md) / Nhật ký quyết định và QA

Run the VLSIT lint script with `rtl/filelist.f` and top `m_axi2apb_bridge`. / Chạy script lint VLSIT với `rtl/filelist.f` và top `m_axi2apb_bridge`.

The Arm protocol specifications are licensed references kept outside this folder. Do not copy or redistribute them. / Tài liệu giao thức Arm có giấy phép được giữ ngoài thư mục này; không sao chép hoặc phân phối lại.
