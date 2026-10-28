# HyperRAM Protocol and Product Research

**Research date:** 2026-10-27  
**Status:** Preliminary; the five initial target OPNs, shared AXI4/HyperBus `CLK-CORE`, independent asynchronous APB4 `CLK-APB`, programmable tCSM limits (x8 ≤1 µs, x16 ≤4 µs), AXI4 profile, split DQ/RWDS input/output/OE pad boundary, fixed-latency burst policy, core/APB reset behavior, and high-throughout-operation power-good policy are approved. External logic blocks AXI traffic and waits for fully drained/startup-complete `o_idle` before asserting `i_rst_n_core`; core reset resets HyperRAM and invalidates DRAM contents. After core reset release, software programs valid timing fields while disabled; enable starts the programmed RESET#-low and post-release startup waits before AXI admission. `i_rst_n_apb` may assert independently while APB is idle and no APB/core CDC request or response is pending; APB reset preserves the active core and memory state. Software programs wait timings and the segmentation limit before enable; counts represent complete HyperBus CK periods generated from `CLK-CORE`. APB/core CSR crossing uses the `ASYNC_CSR` profile. Clock rates/CK ratio and phase, power-warning timing, final CSR choices, AXI ordering/lock-pin policy, and exact device mode-register values remain open. A 22-register CSR proposal is now in the project workbook for review.

## 1. Executive summary / Tóm tắt

The project targets an AXI4 subordinate controller with configurable 32-bit or 64-bit AXI data width. The AXI clock frequency remains TBD. The memory-side scope includes multi-vendor x8 HyperBus (Infineon, Winbond, ISSI) and x16 HyperBus Extended-I/O (Infineon and Winbond). The approved HyperBus baseline document is Infineon/Cypress specification 001-99253 Rev. H.

Dự án hướng tới bộ điều khiển AXI4 subordinate, cho phép cấu hình độ rộng dữ liệu AXI 32 hoặc 64 bit. Tần số clock AXI vẫn TBD. Phía bộ nhớ gồm HyperBus x8 đa hãng (Infineon, Winbond, ISSI) và HyperBus Extended-I/O x16 (Infineon, Winbond). Tài liệu HyperBus nền đã duyệt là đặc tả Infineon/Cypress 001-99253 Rev. H.

“Popular” here means current manufacturer-listed product families and production status, not market-share ranking. No reliable public market-share data was identified.  
Trong tài liệu này, “phổ biến” nghĩa là các dòng sản phẩm đang được nhà sản xuất liệt kê cùng trạng thái sản xuất, không phải xếp hạng thị phần. Chưa tìm thấy dữ liệu thị phần công khai đáng tin cậy.

## 2. Protocol baseline / Nền tảng giao thức

| Profile | Baseline and boundary | Current finding |
|---|---|---|
| HyperBus x8 | HyperBus Specification 001-99253 Rev. H (2019), approved for local conversion | Direct protocol baseline for x8 HyperBus. It describes x8 DDR CA/data signaling, RWDS latency/data-strobe/write-mask behavior, transaction timing, reset, and device-dependent timing constraints. Per-device datasheets remain authoritative for supported modes and timing values. |
| HyperBus Extended-I/O x16 | Approved Infineon S80KS2564 and Winbond W958D6NBKX datasheets | Rev. H is an x8 specification; x16 behavior is grounded in the selected vendor device documents, not inferred from x8 rules. No cross-vendor x16 standard was found in the approved source set. |

| Hồ sơ | Nền tảng và giới hạn | Kết quả hiện tại |
|---|---|---|
| HyperBus x8 | HyperBus Specification 001-99253 Rev. H (2019), đã duyệt chuyển đổi cục bộ | Nền tảng giao thức trực tiếp cho HyperBus x8. Tài liệu mô tả CA/dữ liệu DDR x8, chức năng RWDS về latency/strobe dữ liệu/write-mask, timing giao dịch, reset và các giới hạn phụ thuộc từng thiết bị. Datasheet từng linh kiện vẫn là nguồn xác định mode và trị số timing được hỗ trợ. |
| HyperBus Extended-I/O x16 | Datasheet Infineon S80KS2564 và Winbond W958D6NBKX đã duyệt | Rev. H là đặc tả x8; hành vi x16 dựa trên tài liệu thiết bị đã chọn, không suy diễn từ quy tắc x8. Bộ nguồn đã duyệt chưa có một chuẩn x16 dùng chung cho nhiều hãng. |

### Key x8 facts / Các điểm chính của x8

- A transaction sends a 48-bit command/address field over three clock cycles and six DDR edges. The CA field describes the operation, target address space, burst type, and address.
- RWDS indicates additional initial latency during CA. During reads it is the data strobe; during writes it carries byte-mask information when masking is supported.
- HyperRAM transfers 16-bit words over the 8-bit DQ bus using two data phases per clock cycle. Device timing, latency, reset, and mode support must be taken from the selected part datasheet.
- The source specification contains flattened tables in its text conversion. Any requirement derived from a complex table or figure must be checked against the source PDF page before it enters the normative specification.

- Một giao dịch gửi trường command/address 48 bit trong ba chu kỳ clock và sáu cạnh DDR. Trường CA xác định thao tác, không gian địa chỉ, kiểu burst và địa chỉ.
- RWDS báo latency ban đầu bổ sung trong CA. Khi đọc, RWDS là data strobe; khi ghi, RWDS mang thông tin byte mask nếu thiết bị hỗ trợ.
- HyperRAM truyền word 16 bit qua DQ 8 bit bằng hai pha dữ liệu mỗi chu kỳ clock. Timing, latency, reset và mode phải căn cứ datasheet của linh kiện được chọn.
- Bản chuyển đổi văn bản có một số bảng bị dàn phẳng. Yêu cầu lấy từ bảng hoặc hình phức tạp phải được đối chiếu với đúng trang PDF trước khi đưa vào đặc tả quy phạm.

### x16 boundary / Giới hạn x16

Infineon describes HyperRAM 3.0 as a 16-bit Extended-I/O version of HyperBus. The user selected Infineon and Winbond for x16 coverage. ISSI lists x16 Extended-I/O parts as samples or scheduled releases in its current catalog and is outside the current x16 qualification scope. Similar bus width does not establish identical device modes, register maps, reset behavior, or timing.

Infineon mô tả HyperRAM 3.0 là phiên bản HyperBus Extended-I/O 16 bit. Người dùng đã chọn Infineon và Winbond cho phạm vi x16. Danh mục ISSI liệt kê linh kiện Extended-I/O x16 ở trạng thái sample hoặc lịch phát hành, nên hiện không nằm trong phạm vi qualification x16. Cùng độ rộng bus không đồng nghĩa mode, register map, reset hoặc timing giống nhau.

## 3. Current manufacturer-listed families / Các dòng sản phẩm đang được hãng liệt kê

| Manufacturer | x8 family evidence | x16 family evidence | Status caveat |
|---|---|---|---|
| Infineon | HyperRAM 2.0, 64–512 Mb; representative S80KS2562 (256 Mb, x8, DDR up to 200 MHz, 400 MB/s) | HyperRAM 3.0 Extended-I/O; representative S80KS2564 (256 Mb, x16, DDR up to 200 MHz, 800 MB/s) | Manufacturer part pages list representative parts as active/preferred. Confirm the exact voltage and temperature grade selected for this project. |
| Winbond | Product selection guide lists production x8 devices from 32 Mb to 512 Mb; examples include W956/W957/W958/W959 families | Product selection guide lists production x16 devices, including 128 Mb W957 and 256 Mb W958 | Guide lists interface rates and product status; exact datasheet revision and operating conditions vary by part suffix. |
| ISSI | Official product catalog lists x8 HyperRAM from 32 Mb to 512 Mb in production; IS66WVH32M8DALL/BLL is a 256-Mb example | Official catalog lists 256/512-Mb Extended-I/O x16 items as samples or planned releases, not all production | x16 is excluded from this revision. Catalog status is not a supply guarantee. |

| Nhà sản xuất | Bằng chứng dòng x8 | Bằng chứng dòng x16 | Lưu ý trạng thái |
|---|---|---|---|
| Infineon | HyperRAM 2.0, 64–512 Mb; ví dụ S80KS2562 (256 Mb, x8, DDR đến 200 MHz, 400 MB/s) | HyperRAM 3.0 Extended-I/O; ví dụ S80KS2564 (256 Mb, x16, DDR đến 200 MHz, 800 MB/s) | Trang hãng ghi linh kiện đại diện active/preferred. Cần chốt điện áp và cấp nhiệt độ cho dự án. |
| Winbond | Hướng dẫn sản phẩm liệt kê các thiết bị x8 production từ 32 Mb đến 512 Mb; ví dụ dòng W956/W957/W958/W959 | Hướng dẫn sản phẩm liệt kê x16 production, gồm W957 128 Mb và W958 256 Mb | Tốc độ giao tiếp và trạng thái được liệt kê trong hướng dẫn; revision datasheet và điều kiện hoạt động phụ thuộc hậu tố part number. |
| ISSI | Danh mục chính thức liệt kê HyperRAM x8 32–512 Mb đang production; IS66WVH32M8DALL/BLL là ví dụ 256 Mb | Danh mục chính thức liệt kê x16 Extended-I/O 256/512 Mb ở trạng thái sample hoặc dự kiến phát hành | x16 nằm ngoài phiên bản này. Trạng thái trên danh mục không bảo đảm nguồn cung. |

## 4. Candidate parts for qualification / Linh kiện ứng viên để qualification

The user approved the five exact OPNs below as the initial 200-MHz qualification targets. This defines a test target matrix, not a completed qualification result or vendor-wide compatibility claim. A final claim must name the tested OPNs, operating conditions, and supported modes.

Người dùng đã duyệt năm OPN dưới đây làm mục tiêu qualification ban đầu ở 200 MHz. Đây là danh sách mục tiêu kiểm thử, chưa phải kết quả qualification hay tuyên bố tương thích toàn hãng. Tuyên bố cuối cùng phải nêu OPN, điều kiện hoạt động và mode đã kiểm thử.

| Role | Candidate | Why it is representative |
|---|---|---|
| x8 Infineon | `S80KS2562GABHB020`, 256 Mb, 1.8 V | Approved Rev. C valid-combinations table; 200 MHz, tACC 35 ns; `B` grade is automotive AEC-Q100 Grade 2, −40°C to +105°C. |
| x8 Winbond | `W958D8NBYA5I`, 256 Mb, 1.8 V | Approved A01-003; 200 MHz, −40°C to +85°C; `W958D8NBYA4I` is the 250-MHz grade. |
| x8 ISSI | `IS66WVH32M8DALL-200B1LI`, 256 Mb, 1.8 V | Source pages marked Rev. A7 (2024-11-21); lists this 200-MHz OPN and tACC 35 ns, industrial −40°C to +85°C. |
| x16 Infineon | `S80KS2564GACHI040`, 256 Mb, 1.8 V | Approved Rev. C ordering table; 200 MHz, tACC 35 ns, industrial −40°C to +85°C. |
| x16 Winbond | `W958D6NBKX5I`, 256 Mb, 1.8 V | Approved A01-001; 200 MHz, −40°C to +85°C; `W958D6NBKX4I` is the 250-MHz grade. |

### Representative-device comparison / So sánh thiết bị đại diện

| Item | x8 profiles | x16 profiles | Design implication |
|---|---|---|---|
| DQ / RWDS lanes | DQ[7:0], one RWDS | DQ[15:0], two RWDS lanes | x16 uses one mask/strobe lane per byte. RTL exposes split input/output/active-high OE ports; the SoC pad wrapper connects them to physical bidirectional pads. |
| Device data per clock | x8 DDR transfers two bytes per clock | x16 Extended-I/O transfers four bytes per clock in the Winbond W958 profile | Beat packing and AXI byte-lane mapping depend on the selected profile. |
| Maximum device clock in reviewed representatives | Infineon S80KS2562: 200 MHz; Winbond W958D8NBYA: 200- or 250-MHz ordering grades; ISSI source Rev. A7: 200 MHz | Infineon S80KS2564: 200 MHz; Winbond W958D6NBKX: 200- or 250-MHz ordering grades | The user approved a 200-MHz maximum for the five selected OPNs. Board timing margin and clock implementation still need sign-off. |
| tACC at 200 MHz in reviewed sources | Infineon S80KS2562: 35 ns; Winbond W958D8NBYA5I: 35 ns; ISSI Rev. A7: 35 ns | Infineon S80KS2564: 35 ns; Winbond W958D6NBKX5I: 35 ns | The selected OPNs share a 35-ns initial-access minimum in these tables. Latency negotiation and count must still match actual CK frequency and CR0 mode. |
| Maximum CS# low time (`tCSM`) | Infineon Grade 2: 1 µs above 85°C (4 µs at ≤85°C); Winbond and ISSI industrial parts: 4 µs | Selected Infineon and Winbond industrial parts: 4 µs | User-approved CSR-programmable cap: no more than 1 µs in x8 mode or 4 µs in x16 mode. The interval includes CA, latency, data, and clock stalls. Long AXI bursts must be segmented while preserving address order and data semantics. At a nominal 200-MHz CK these caps are 200 and 800 CK periods; timing margin/count mapping depends on the finalized CK generation. |
| Power-up and hardware-reset timing | Selected Infineon, Winbond, and ISSI devices: `tVCS` = 150 µs; `tRP` ≥ 200 ns; `tRH` ≥ 200 ns; `tRPH` ≥ 400 ns | Same limits in the selected x16 device data | Core reset or bad power-good holds RESET# LOW and blocks memory access. After core reset release, software programs timing while disabled; enable starts the programmable RESET#-low wait, releases RESET#, then starts the programmable startup wait before AXI admission. Counts must satisfy all selected-part minima and use complete HyperBus CK periods. Every core reset invalidates DRAM contents; software reloads required data. Sources: REF-006–REF-009, device power-up/reset tables. |
| CS# high time between transactions (`tCSHI`) | Infineon and Winbond x8 targets: 6 ns; ISSI x8 target: 5 ns at 200 MHz | Infineon and Winbond x16 targets: 6 ns at 200 MHz | A common minimum of 6 ns covers the five approved OPNs. At 200 MHz, one 5-ns CK period is insufficient; the PHY must meet the time value with its actual CK/CS# implementation. |
| Clock pins | Winbond x8, ISSI, and Infineon x8 options are specified per datasheet | Reviewed Infineon and Winbond x16 parts expose CK and CK# | CK/CK# mode and board timing need one explicit integration contract. AXI clock frequency does not define this memory clock. |

The comparison is tied to the converted datasheet revisions and representative ordering codes above. It does not qualify all vendor products. Winbond offers 200-MHz and 250-MHz order grades under the same family document; selecting the family name alone is insufficient for timing sign-off.

Bảng so sánh dựa trên revision datasheet và mã đặt hàng đại diện đã chuyển đổi; không qualification toàn bộ sản phẩm của hãng. Winbond có grade 200 MHz và 250 MHz trong cùng tài liệu dòng sản phẩm, vì vậy chỉ chọn tên family chưa đủ để chốt timing.

## 5. Compatibility risks / Rủi ro tương thích

1. “HyperBus compatible” does not make all vendors and generations interchangeable. Compare CA interpretation, latency negotiation, RWDS behavior, burst settings, register defaults, reset/power-on sequence, maximum CS# active time, and timing margins against each selected datasheet.
2. The x16 extended-I/O profile is a separate qualification boundary. Do not infer support from x8 tests or from an x8-only Rev. H source.
3. Multi-vendor support needs a named qualification matrix. At minimum, test each named part, voltage/temperature profile, and supported speed grade; any omitted modes must be explicit.
4. Product catalogs reflect vendor listings, not guaranteed stock at every distributor. Recheck the chosen part’s status before design freeze.

1. “Tương thích HyperBus” không có nghĩa mọi hãng và thế hệ thay thế trực tiếp cho nhau. Cần so CA, thương lượng latency, RWDS, burst, giá trị thanh ghi mặc định, trình tự reset/power-on, giới hạn CS# active và timing margin theo từng datasheet.
2. Extended-I/O x16 là ranh giới qualification riêng. Không suy ra hỗ trợ từ bài kiểm tra x8 hoặc tài liệu Rev. H chỉ bao phủ x8.
3. Hỗ trợ đa hãng cần ma trận qualification có part number cụ thể. Tối thiểu kiểm tra từng linh kiện, điện áp/nhiệt độ, cấp tốc độ; ghi rõ mode không hỗ trợ.
4. Danh mục hãng thể hiện trạng thái được liệt kê, không bảo đảm tồn kho tại mọi nhà phân phối. Cần kiểm tra lại part đã chọn trước khi đóng băng thiết kế.

## 6. External implementation evidence / Bằng chứng triển khai bên ngoài

### NXP AN12239, Chinese edition / NXP AN12239, bản tiếng Trung

NXP's *Using HyperFlash and HyperRAM with the i.MX RT FlexSPI*, Rev. 4 (2022-09-29), reports system-level tests with several memory vendors. Cypress S27KS0642 and Winbond W956x8MBYA passed the stated NXP tests; ISSI IS66WVH32M8DALL passed on the listed RT1064/RT1176 boards. Cypress 7KS0641DPHI02 failed on two listed MCU variants. This is evidence that vendor and part revision alone do not guarantee operation: controller timing, board, and host configuration matter. The tests are MCU/FlexSPI integration evidence, not validation of this ASIC RTL. **Confidence: medium** for integration risk; not normative protocol authority.

NXP, *Using HyperFlash and HyperRAM with the i.MX RT FlexSPI*, Rev. 4 (2022-09-29), báo cáo thử nghiệm hệ thống với nhiều hãng bộ nhớ. Cypress S27KS0642 và Winbond W956x8MBYA đạt các bài thử NXP nêu; ISSI IS66WVH32M8DALL đạt trên các bo RT1064/RT1176 được liệt kê. Cypress 7KS0641DPHI02 lỗi trên hai biến thể MCU được nêu. Đây là bằng chứng cho thấy cùng hãng/part revision chưa bảo đảm hoạt động: timing controller, board và cấu hình host đều ảnh hưởng. Thử nghiệm này là bằng chứng tích hợp MCU/FlexSPI, không phải verification cho RTL ASIC đang thiết kế. **Độ tin cậy: trung bình** về rủi ro tích hợp; không phải nguồn quy phạm giao thức.

Source / Nguồn: [NXP AN12239 Rev. 4, Chinese PDF](https://www.nxp.com/docs/zh/nxp/application-notes/AN12239.pdf).

### AG32VH application guide / Hướng dẫn ứng dụng AG32VH

An AG32VH Chinese application article describes a Winbond W956A8 64-Mb x8 HyperRAM at 200 MHz and uses a phase-shifted capture clock and DMA for higher throughput. Its reported throughput is specific to that FPGA/MCU system and workload; it must not be used as a controller guarantee. **Confidence: low to medium** because this is a vendor ecosystem example, not a standard or independent ASIC measurement.

Bài hướng dẫn ứng dụng AG32VH mô tả Winbond W956A8 HyperRAM x8 64-Mb ở 200 MHz, dùng clock capture lệch pha và DMA để tăng thông lượng. Thông lượng công bố chỉ áp dụng cho hệ thống FPGA/MCU và workload đó; không dùng làm cam kết hiệu năng của controller này. **Độ tin cậy: thấp đến trung bình** vì đây là ví dụ hệ sinh thái của hãng, không phải tiêu chuẩn hay phép đo ASIC độc lập.

Source / Nguồn: [AG32VH application article](https://www.eefocus.com/article/1842965.html).

### Controller IP implementation references / IP controller tham khảo

| Reference | Evidence and scope | Relevance and limitation |
|---|---|---|
| [GhlHub/hyperbus_controller](https://github.com/GhlHub/hyperbus_controller) | Open-source Apache-2.0 RTL. Its project documentation reports implemented FPGA testing on Xilinx UltraScale+ at 200-MHz HyperBus with a 50-MHz AXI clock; it includes AXI4-Full and AXI4-Lite paths, a HyperBus engine, device-specific PHYs, and FIFO banks. | Strong structural reference for separating AXI frontends, transaction engine, clock crossing/storage, and FPGA PHY. It is Xilinx-primitive dependent and currently x8-only; do not copy the PHY into ASIC RTL. |
| [Mobiveil HyperRAM Controller, listed by Altera as production silicon-proven IP](https://www.altera.com/partners/offering/po-2499/hyperram-controller-silicon-proven-ip-altera-devices) | Vendor page describes Winbond x8/x16 support, AXI4 memory access, APB control, linear/wrap/hybrid bursts, operation up to 250 MHz, a SystemVerilog/UVM testbench, and a validated FPGA PHY reference design. | Commercial evidence that a multi-width controller commonly separates data access and control/configuration. The advertised scope is Winbond-specific and access is commercial; it does not qualify this ASIC or other vendors. |
| [Efinix HyperRAM Controller Core](https://www.efinixinc.com/support/ip/hyperram-controller.php) | Vendor core advertises x8/x16 width, dual-memory support, calibration, and AXI3 half-duplex or native access; Verilog and simulation testbench are included for Efinix FPGA targets. | Useful evidence for PHY calibration and width-selection needs. It uses a different host protocol and FPGA platform, so it is not an AXI4 ASIC compliance reference. |

Architecture guidance from these implementations: keep the AXI transaction adapter, HyperBus transaction sequencing, and DDR IO PHY as explicit boundaries. Add asynchronous FIFOs only if the selected clock contract requires a domain crossing. Use each reference for its documented evidence only; none establishes the behavior of the new ASIC RTL.

Gợi ý kiến trúc từ các triển khai này: tách rõ adapter AXI, điều khiển giao dịch HyperBus và PHY DDR. Chỉ thêm asynchronous FIFO nếu hợp đồng clock yêu cầu crossing miền. Mỗi nguồn chỉ chứng minh phạm vi họ công bố; không nguồn nào chứng minh RTL ASIC mới hoạt động.

## 7. Project decisions and open items / Quyết định và mục còn mở

| Item | State |
|---|---|
| HyperBus x8 standard | Approved: 001-99253 Rev. H |
| Memory width | x8 multi-vendor; x16 Extended-I/O required |
| x8 vendor scope | Approved: Infineon, Winbond, ISSI |
| AXI data width | Configurable between 32 and 64 bits |
| Clock topology | Approved: AXI4 and HyperBus control share `CLK-CORE`; APB4 uses asynchronous `CLK-APB`; memory CK ratio/phase and clock rates remain TBD. Programmable wait counts use complete HyperBus CK periods at the device pins. |
| `tCSM` policy | Approved programmable segmentation cap: maximum 1 µs for x8 and 4 µs for x16; includes CA, latency, data, and stalls; long AXI bursts are segmented |
| Reset inputs | Approved: `i_rst_n_core` resets AXI/HyperBus and memory after external logic blocks requests and waits for `o_idle`; `i_rst_n_apb` can reset the APB endpoint independently while APB is idle and no CDC request/response is pending. APB reset preserves core registers/configuration, controller operation, and memory. `o_idle` is synchronous to `CLK-CORE`. The IP drives device RESET# after power-good and each core reset; device data is invalid after core reset. |
| APB CSR | Required APB4 interface with independent APB clock/reset, asynchronous CDC, configurable timing waits, status, sticky raw interrupt status, enable, masked status, and injection into raw status. Raw status is W1C. Invalid/reserved CSR addresses complete with `PREADY=1`, `PSLVERR=1`, and no state change. Workbook sheet: `ASYNC_CSR`; a 22-register proposal covers configuration, status, diagnostics, and interrupts and remains pending designer review. |
| Default configuration | Approved: `CFG-X8-32` (`PARA_MEM_DQ_W=8`, `PARA_AXI_DATA_W=32`). |
| Initial qualification target matrix | Five exact 200-MHz OPNs approved: Infineon S80KS2562GABHB020 / S80KS2564GACHI040; Winbond W958D8NBYA5I / W958D6NBKX5I; ISSI IS66WVH32M8DALL-200B1LI. Datasheet conversions are verified; qualification tests remain open. |
| x8/x16 selection | Approved: one top module with elaboration-selected, parameter-sized DQ/RWDS ports |
| x16 vendor scope | Approved: Infineon and Winbond; ISSI x16 excluded from this revision |
| AXI address/error policy | Approved: `PARA_MEM_SIZE_BYTES` defines the aperture; out-of-range requests return DECERR; unsupported in-range requests return SLVERR; rejected writes consume W beats and issue no HyperBus transaction. |
| HyperBus mode | Approved fixed-latency operation; AXI INCR maps to linear bursts and WRAP to wrapped bursts where supported by the selected OPN. Exact mode-register values and latency counts remain in the CSR workbook/device profile. |
| HyperBus pad boundary | Approved split DQ/RWDS input, output, and active-high OE ports; an SoC pad wrapper maps these to physical bidirectional pads. No RTL `inout` ports. |
| Reset/enable | Approved: timing programmed while disabled; enable starts programmed RESET#-low and startup waits before AXI admission. The proposed CSR fields are in the workbook and remain pending designer review. |
| APB access error | Approved: invalid/reserved CSR address completes with `PREADY=1`, `PSLVERR=1`, and no state change. |
| Remaining system integration | Clock rate and CK ratio/phase, voltage and temperature qualification conditions, AXI ordering/lock-pin policy, power-warning timing, interrupt events, CSR field definitions, and waveform plan remain open. |

| Hạng mục | Trạng thái |
|---|---|
| Chuẩn HyperBus x8 | Đã duyệt: 001-99253 Rev. H |
| Độ rộng bộ nhớ | Đã duyệt x8 đa hãng và x16 Extended-I/O (Infineon, Winbond) |
| Phạm vi hãng x8 | Đã duyệt: Infineon, Winbond, ISSI |
| Độ rộng dữ liệu AXI | Cấu hình được giữa 32 và 64 bit |
| Kiến trúc clock | Đã duyệt AXI4 và điều khiển HyperBus dùng chung `CLK-CORE`; APB4 dùng `CLK-APB` bất đồng bộ riêng. Tần số, tỷ lệ và pha CK còn TBD. Bộ đếm timing dùng chu kỳ CK HyperBus hoàn chỉnh tại chân bộ nhớ. |
| Chính sách `tCSM` x8 | Đã duyệt giới hạn cố định 1 µs cho mỗi khoảng CS# low, gồm CA, latency, dữ liệu và dừng clock; request AXI dài được chia giao dịch |
| Reset đầu vào | Đã duyệt `i_rst_n_core` cho AXI/HyperBus và `i_rst_n_apb` độc lập. Reset core sau khi `o_idle` báo drain xong; reset APB khi APB idle và không có CDC request/response pending, chỉ reset endpoint APB và giữ nguyên core, cấu hình, controller, bộ nhớ. `o_idle` thuộc `CLK-CORE`. IP điều khiển RESET# sau power-good và mỗi reset core; dữ liệu DRAM phải nạp lại sau reset core. |
| AXI4 profile | Đã duyệt địa chỉ 32-bit, ID 4-bit, data 32/64-bit, INCR/WRAP, WSTRB, bốn request outstanding mỗi hướng; không USER/QOS/REGION/exclusive. |
| AXI address/error | Đã duyệt aperture `PARA_MEM_SIZE_BYTES`; request ngoài vùng trả DECERR; request trong vùng nhưng không hỗ trợ trả SLVERR; write bị từ chối vẫn nhận đủ W beat và không phát giao dịch HyperBus. |
| Mode HyperBus | Đã duyệt fixed-latency; AXI INCR ánh xạ burst linear, WRAP ánh xạ burst wrapped khi OPN hỗ trợ. Giá trị mode register và latency count chính xác còn nằm trong workbook/profile thiết bị. |
| Ranh giới pad HyperBus | Đã duyệt cổng DQ/RWDS input, output và OE active-high tách riêng; SoC pad wrapper nối tới pad vật lý hai chiều. RTL không khai báo `inout`. |
| Reset/enable | Đã duyệt: lập trình timing khi disabled; enable bắt đầu thời gian RESET#-low đã cấu hình, nhả RESET# rồi đếm startup wait trước khi nhận AXI. CSR field chi tiết còn mở. |
| Lỗi truy cập APB | Đã duyệt: địa chỉ CSR invalid/reserved hoàn tất với `PREADY=1`, `PSLVERR=1` và không đổi trạng thái. |
| CSR APB4 | Bắt buộc; APB clock/reset riêng, crossing bất đồng bộ; workbook dùng sheet `ASYNC_CSR`. Raw interrupt sticky W1C, có enable, status sau mask và injection vào raw. Địa chỉ CSR invalid/reserved hoàn tất với `PREADY=1`, `PSLVERR=1` và không đổi trạng thái. Event source và bản đồ thanh ghi đang hoàn thiện. Timing wait lập trình trước enable và đếm theo chu kỳ CK HyperBus hoàn chỉnh. |
| Cấu hình mặc định | Đã duyệt `CFG-X8-32` (`PARA_MEM_DQ_W=8`, `PARA_AXI_DATA_W=32`). |
| Ma trận qualification ban đầu | Đã duyệt năm OPN 200 MHz: Infineon S80KS2562GABHB020 / S80KS2564GACHI040; Winbond W958D8NBYA5I / W958D6NBKX5I; ISSI IS66WVH32M8DALL-200B1LI. Bản chuyển đổi đã kiểm tra; bài qualification chưa thực hiện. |
| Chọn x8/x16 | Đã duyệt: một top module, port DQ/RWDS đổi độ rộng lúc elaboration theo parameter |
| Phạm vi hãng x16 | Đã duyệt: Infineon và Winbond; ISSI x16 nằm ngoài phiên bản này |
| Tích hợp còn mở | Tần số clock/tỷ lệ pha CK, điều kiện qualification điện áp/nhiệt độ, thứ tự/lock AXI, power-warning, event và CSR field, cùng waveform plan. |

## 8. Sources / Nguồn

1. Infineon/Cypress, *HYPERBUS Specification: Low Signal Count, High Performance DDR Bus*, document 001-99253 Rev. H, 2019. Local converted reference: `../reference/md_doc/hyperbus_001-99253_rev_h.md`. [Official PDF](https://www.infineon.com/dgdl/Infineon-HYPERBUS_SPECIFICATION_LOW_SIGNAL_COUNT_HIGH_PERFORMANCE_DDR_BUS-AdditionalTechnicalInformation-v09_00-EN.pdf?fileId=8ac78c8c7d0d8da4017d0ed619b05663)
2. Infineon, [PSRAM / HYPERRAM portfolio](https://www.infineon.com/products/memories/psram-pseudostatic-dram); [S80KS2562 x8 part page](https://www.infineon.com/part/S80KS2562GABHB020); [S80KS2564 x16 part page](https://www.infineon.com/part/S80KS2564GACHI040).
3. Winbond, [2026 Product Selection Guide](https://www.winbond.com/export/sites/winbond/product-selection-guide/file/2026-Winbond-Customized-Memory-Solution.pdf?__locale=en), HyperRAM product tables, pp. 18–19; [W958 documentation listing](https://www.winbond.com/hq/support/documentation/index.html?__locale=it&category=%2F.categories%2Fresources%2Fdatasheet%2F&family=%2Fproduct%2Fmobile-dram%2Fhyperram%2Findex.html&line=%2Fproduct%2Fmobile-dram%2Findex.html&pno=W958).
4. ISSI, [HyperRAM product catalog](https://issi.com.cn/CN/product-serial-sram-and-serial-ram.shtml); [IS66WVH32M8DALL/BLL datasheet](https://www.issi.com/WW/pdf/66-67WVH32M8DALL-BLL.pdf). The approved URL returned source pages marked Rev. A7, dated 2024-11-21; the initial metadata proposal described Rev. A5.
5. All online product status and catalog claims were checked on 2026-10-27. The source material and part status may change; the final specification must record the exact revision and retrieval date for each approved datasheet.

## 9. Approved local source conversions / Chuyển đổi tài liệu đã duyệt

| Source | PDF size | SHA-256 | Conversion check |
|---|---:|---|---|
| HyperBus 001-99253 Rev. H | 1,670,145 bytes | `92582827E60B21A25658E5E1435DDDB212CD63E7D4E00D31ADF2156F3503041C` | 45 pages; verifier passed after repair of page 24 caption. |
| Infineon S80KS2562, 002-31337 Rev. C | 1,125,669 bytes | `3f8e3992fd679a51022d133fe68ef446c49c52d1aeec6d0577617dc1127dc70e` | 54 pages; 10 affected page bodies rebuilt from the PDF text layer; verifier: 0 pages over 5% difference. |
| Infineon S80KS2564, 002-31341 Rev. C | 1,076,578 bytes | `e8de950a327546c2eb79c2637e6473add3deb4b466a00795f6b0eda0422103f2` | 48 pages; 7 affected page bodies rebuilt from the PDF text layer; verifier: 0 pages over 5% difference. |
| Winbond W958D8NBYA x8, A01-003 | Not published by manufacturer | `019ab3b6d19af5d3b0df04c1bba15fa4731c712ba4d04c6f1e53e9da28595748` | 45 pages; 15 affected page bodies rebuilt; verifier: 0 pages over 5% difference. |
| Winbond W958D6NBKX x16, A01-001 | Not published by manufacturer | `1b20458786d101d8452562922131167813621d1a778e9f9f7ed2af5e95041107` | 44 pages; 14 affected page bodies rebuilt; verifier: 0 pages over 5% difference. |
| ISSI IS66WVH32M8DALL/BLL x8, source Rev. A7 (2024-11-21) | Not published by manufacturer | `5f4273cf4a537266ad108c873b28138e705727861de9b2788e4d3e9d3b7c70aa` | 51 pages; 4 affected page bodies rebuilt; verifier: 0 pages over 5% difference. User confirmed A7 after the source revision mismatch was reported. |

The original PDFs are temporary and are not stored in the project. Converted Markdown carries the source metadata and is excluded from version control because redistribution rights are not granted.  
PDF gốc chỉ được lưu tạm và không đưa vào dự án. Markdown đã chuyển đổi có metadata nguồn và bị loại khỏi version control vì chưa có quyền tái phân phối.

## 6. CSR options / Các lựa chọn CSR

The HyperBus specification and device datasheets describe device mode registers such as CR0/CR1. These are distinct from controller CSRs: the controller CSRs should expose stable software controls and diagnostics, while the selected OPN profile translates them to device-specific CA/mode-register encodings. The reference documents show that latency, burst behavior, refresh/power modes, and some settings differ by part. See REF-001 §5.2 and the selected device datasheets in REF-006–REF-009.

| Option | Software-visible behavior | Tradeoff |
|---|---|---|
| **A — Common controls with compile-time OPN profile (recommended)** | Software programs enable, required wait counts, fixed-latency count, and CS# segmentation cap. Firmware reads profile/capability, init/status, outstanding counts, config errors, AXI error counters/context, and manages interrupt raw/enable/masked/injection state. Device-specific mode-register encodings stay internal to the selected profile. | Best multi-vendor safety and firmware portability. Requires a compile-time OPN profile and review of the proposed legal timing ranges. |
| **B — Add vendor-neutral mode controls** | Add only options shared and validated across all selected parts, for example output-drive level or supported wrapped-burst choices. | More runtime flexibility, but every option needs per-OPN mapping, reset value, legal range, and verification. Unsupported combinations must return APB error without starting memory access. |
| **C — Expose raw CR0/CR1 programming** | Software supplies vendor-defined mode-register bits directly. | Not recommended for the first revision: reserved/device-specific bits can vary; partial-array refresh, hybrid-sleep, or deep-power-down controls can affect data availability or retention. Requires per-vendor register maps and a documented recovery model. |

The current workbook implements **Option A as a proposal**. It includes initialization/timing configuration; read-only profile/capability and live status; sticky configuration errors and AXI error history; plus interrupt raw, enable, masked-status, and injection registers. It deliberately does not expose raw device CR0/CR1, DPD, hybrid sleep, or partial-array-refresh fields. The proposed event list and `PARA_MEM_PROFILE` selection remain subject to designer approval.

HyperBus và datasheet linh kiện mô tả các mode register của bộ nhớ như CR0/CR1. Chúng khác CSR của controller: CSR nên cung cấp điều khiển/chẩn đoán ổn định cho phần mềm; OPN profile được chọn sẽ chuyển các giá trị đó sang mã CA/mode-register riêng của thiết bị. Tài liệu tham chiếu cho thấy latency, burst, refresh/power mode và một số cấu hình phụ thuộc từng linh kiện. Xem REF-001 §5.2 và datasheet thiết bị tại REF-006–REF-009.

| Lựa chọn | Chức năng phần mềm nhìn thấy | Đánh đổi |
|---|---|---|
| **A — Điều khiển chung với OPN profile lúc biên dịch (khuyến nghị)** | Phần mềm cấu hình enable, thời gian chờ bắt buộc, fixed-latency count và giới hạn phân đoạn CS#. Firmware đọc profile/capability, init/status, outstanding, lỗi cấu hình, bộ đếm/ngữ cảnh lỗi AXI và điều khiển raw/enable/masked/injection của interrupt. Mã mode register riêng thiết bị nằm bên trong profile. | An toàn và dễ dùng chung firmware nhất khi hỗ trợ nhiều hãng. Cần chọn OPN profile lúc biên dịch và duyệt dải timing hợp lệ. |
| **B — Thêm điều khiển mode trung lập theo hãng** | Chỉ thêm tùy chọn chung và đã xác minh trên mọi linh kiện, ví dụ mức drive hoặc lựa chọn wrapped-burst được hỗ trợ. | Linh hoạt runtime hơn nhưng mỗi tùy chọn phải có ánh xạ, reset, dải hợp lệ và kiểm thử cho từng OPN. Cấu hình không hỗ trợ phải báo lỗi APB và không khởi tạo truy cập bộ nhớ. |
| **C — Cho phần mềm ghi CR0/CR1 thô** | Phần mềm tự cung cấp bit mode-register theo hãng. | Không khuyến nghị cho bản đầu: bit reserved/riêng hãng khác nhau; partial-array refresh, hybrid-sleep hoặc deep-power-down có thể ảnh hưởng khả năng truy cập hay lưu giữ dữ liệu. Cần register map theo hãng và chính sách khôi phục. |

Workbook hiện thực hóa **đề xuất Lựa chọn A**. Workbook có cấu hình init/timing; profile/capability và trạng thái chỉ đọc; lỗi cấu hình sticky, lịch sử lỗi AXI; cùng các thanh ghi raw, enable, masked-status và injection cho interrupt. Workbook chưa lộ CR0/CR1 thô, DPD, hybrid-sleep hay partial-array-refresh. Danh sách event và `PARA_MEM_PROFILE` vẫn cần người thiết kế duyệt.

