# Reference-IP research log / Nhật ký nghiên cứu IP tham chiếu

Research date: 2026-10-25. This review followed microspec rule R-010. No RTL or vendor package was downloaded. / Ngày nghiên cứu: 2026-10-25. Đánh giá theo rule R-010 của skill microspec. Không tải RTL hoặc gói IP của nhà cung cấp.

## Search queries / Truy vấn

| Query / Truy vấn | Sources / Nguồn | Result / Kết quả |
|---|---|---|
| `AHB to AXI bridge synchronous clock FPGA IP` | Microchip product page and CoreAHBLtoAXI v2.1 handbook | An AHB-Lite subordinate to AXI manager bridge with synchronous and asynchronous clock options, buffering and FPGA implementation data. |
| `AHB5 to AXI5 single clock bridge low latency` | Arm CoreLink XHB-500 TRM | Product-level AHB5-to-AXI5 reference; its single-clock profile matches the clock-count goal, but it uses AXI5. |
| `AHB-to-AXI 激进式处理` | Google Patents, Chinese patent CN112965924A | Patent describes pre-read and pre-write methods for undefined-length INCR traffic; no silicon or FPGA validation evidence was found. |

## Candidates / 候选项

| Candidate / 候选 | Direction and evidence / 方向与证据 | License / 许可 | Decision / 决定 |
|---|---|---|---|
| Microchip CoreAHBLtoAXI v2.1 | AHB-Lite subordinate to AXI manager. The handbook documents synchronous/asynchronous clock options, 16-deep write/read buffers, supported SmartFusion2 and IGLOO2 families, an implementation table for SmartFusion2, and an included user testbench with AHB master, AXI subordinate and checker models. It reports 2,615 logic elements and 119.1 MHz for one SmartFusion2 configuration; these are FPGA results, not ASIC area or a target for this design. | The handbook says an RTL license is required; Microchip lists the core as free with a Libero license. This is a vendor-controlled license, not an open-source reuse grant. | **USED as a high-level architectural reference only.** Its AHB-Lite profile is narrower than this Full AHB5 profile. No RTL, text or waveform was copied. Sources: [product page](https://www.microchip.com/en-us/products/fpgas-and-plds/ip-core-tools/coreahbltoaxi-1), [v2.1 handbook](https://ww1.microchip.com/downloads/aemDocuments/documents/FPGA/ProductDocuments/UserGuides/ip_cores/directcores/CoreAHBLtoAXI_HB.pdf). |
| Arm CoreLink XHB-500 | AHB5 subordinate to AXI5 manager; product TRM describes a single clock domain and low-latency operation. | Arm licensed product; no redistribution or source reuse. | **EXCLUDED as a direct design reference** because it uses AXI5. Consulted only to compare single-clock architecture and the latency cost of buffering/registration. Source: [XHB-500 TRM](https://documentation-service.arm.com/static/5f242f86da9f9552000fadb0). |
| Patent CN112965924A | Chinese patent describes read-ahead/write-ahead buffering and claims a throughput improvement for continuous undefined-length INCR traffic. Its description is a proposed method, not evidence of silicon or FPGA validation; no testbench or implementation license was identified. Confidence in its claimed performance is **low**. | Patent publication; no implementation license identified. | **EXCLUDED** under R-010. It was used only to identify speculative prefetch as a performance option; the selected design rejects speculative reads. Source: [Google Patents page](https://patents.google.com/patent/CN112965924A/zh). |

## Findings used / Kết quả được dùng

- Synchronous buffering is a documented bridge implementation option. This supports considering queues between AHB acceptance and AXI responses; it does not establish the latency or area of this Full AHB5-to-AXI4 design. / Buffer đồng bộ là một lựa chọn đã được mô tả cho bridge. Điều này hỗ trợ việc dùng queue giữa thời điểm nhận AHB và response AXI, nhưng không chứng minh latency hoặc diện tích của thiết kế Full AHB5-to-AXI4 này.
- Buffering write data can decouple AHB acceptance from AXI response latency in the shared-clock design. Only eligible Normal Write-back fixed bursts are accepted early when queue capacity is available; aggregate errors are reported at the terminal beat. Device-E writes remain single-beat and wait for final-destination BRESP. / Buffer dữ liệu ghi có thể tách thời điểm nhận AHB khỏi latency response AXI trong thiết kế một clock. Chỉ nhận sớm burst Normal Write-back cố định đủ điều kiện khi queue còn chỗ; lỗi tổng hợp được báo ở beat cuối. Write Device-E dùng từng beat và chờ BRESP từ đích cuối.
- Read-ahead could raise throughput for continuous traffic but issues AXI requests before each AHB read is accepted. The user selected strict no-speculation, so reads remain serialized and each accepted AHB read generates one AXI single-beat read. / Đọc trước có thể tăng thông lượng nhưng phát AXI request trước khi nhận AHB read. Người dùng chọn không suy đoán; read được tuần tự hóa và mỗi AHB read đã nhận tạo một AXI read một beat.

## Not done / Chưa thực hiện

- No RTL was downloaded, compiled or evaluated. / Không tải, biên dịch hoặc đánh giá RTL.
- No ASIC synthesis, gate-count estimate or PPA comparison was performed. Vendor FPGA logic-element data is not an ASIC area estimate. / Không tổng hợp ASIC, ước tính cổng hoặc so sánh PPA. Số logic element FPGA không phải ước lượng diện tích ASIC.
- No qualified open-source IP matching Full AHB5, AXI4 and this shared single-clock profile was found in this research pass. / Chưa tìm thấy IP mã nguồn mở đủ điều kiện có Full AHB5, AXI4 và profile một clock dùng chung trong lượt nghiên cứu này.