# Commercial IP Hardware Design Specification
# Section Guide | Hướng dẫn cấu trúc

## 1. Purpose and use | Mục đích và cách sử dụng

**EN:** This guide defines a reader-oriented structure for a commercial IP Hardware Design Specification (HDS). It follows the supplied `VLSIT_IP_Microarchitecture_Spec_Templat.docx`: overview, parameters, block diagram, functions, interfaces, CSRs, software programming, integration, SDC, DFT, PD, and DV. It adds security/safety/reliability and product-deliverables/release sections to cover cross-team assurance and the commercial handoff.

**VI:** Tài liệu này định nghĩa cấu trúc HDS hướng đến người sử dụng cho IP thương mại. Cấu trúc kế thừa mẫu `VLSIT_IP_Microarchitecture_Spec_Templat.docx`: tổng quan, parameter, sơ đồ khối, chức năng, interface, CSR, lập trình phần mềm, tích hợp, SDC, DFT, PD và DV. Tài liệu bổ sung mục an ninh/an toàn/độ tin cậy cùng deliverable/release để bao quát bảo đảm liên nhóm và bàn giao thương mại.

**EN:** The HDS is the normative description of externally visible behavior, configuration, interface contracts, integration requirements, and product limitations. It must let a customer, firmware engineer, DV engineer, DFT engineer, and PD engineer make their decisions without inferring behavior from RTL. Keep implementation details in controlled design collateral unless the IP owner approves their inclusion in the customer-facing HDS.

**VI:** HDS là tài liệu chuẩn tắc mô tả hành vi quan sát được, cấu hình, hợp đồng interface, yêu cầu tích hợp và giới hạn sản phẩm. Tài liệu phải giúp khách hàng, kỹ sư firmware, DV, DFT và PD đưa ra quyết định mà không phải suy luận từ RTL. Để chi tiết hiện thực trong tài liệu thiết kế có kiểm soát, trừ khi chủ sở hữu IP duyệt đưa vào HDS dành cho khách hàng.

**EN:** This file is a section guide, not a completed specification for a particular IP. Copy the structure into a new IP HDS and fill it only with approved design facts. Mark an inapplicable subsection `N/A` with a reason. Mark an unresolved item `TBD` with its impact, owner, and required decision.

**VI:** Đây là hướng dẫn cấu trúc, không phải đặc tả đã hoàn tất cho một IP cụ thể. Sao chép cấu trúc vào HDS của IP mới và chỉ điền dữ kiện thiết kế đã được duyệt. Ghi `N/A` kèm lý do cho mục không áp dụng. Ghi `TBD` kèm ảnh hưởng, người phụ trách và quyết định còn thiếu cho nội dung chưa chốt.

## 2. Intended readers | Đối tượng đọc

| Reader / Người đọc | Main questions answered / Câu hỏi chính được trả lời |
|---|---|
| Product user or customer / Người dùng sản phẩm hoặc khách hàng | What does the IP do, which features and configurations are supported, what are the limits, and what is delivered? / IP làm gì, hỗ trợ tính năng và cấu hình nào, giới hạn ra sao, và được bàn giao những gì? |
| SoC and system integration / Tích hợp SoC và hệ thống | How are interfaces, address ranges, clocks, resets, power, interrupts, DMA, pins, and dependencies connected? / Kết nối interface, địa chỉ, clock, reset, nguồn, interrupt, DMA, pin và phụ thuộc hệ thống thế nào? |
| Firmware and software / Firmware và phần mềm | How are CSRs initialized, features configured, work started, status observed, interrupts handled, and errors recovered? / Khởi tạo CSR, cấu hình tính năng, bắt đầu xử lý, đọc trạng thái, xử lý interrupt và khôi phục lỗi thế nào? |
| DV and validation / DV và validation | Which requirements are checked, with what tests/assertions/coverage, configurations, tools, and sign-off evidence? / Requirement nào được kiểm tra bằng test/assertion/coverage nào, trên cấu hình và công cụ nào, với bằng chứng sign-off gì? |
| DFT and manufacturing test / DFT và kiểm tra sản xuất | How are test modes entered, scan and memories tested, test clocks/resets controlled, and functional mode restored? / Vào chế độ test, kiểm tra scan và memory, điều khiển clock/reset test, và trở về chế độ chức năng thế nào? |
| PD, STA, and implementation / PD, STA và hiện thực vật lý | Which implementation views, timing constraints, floorplan/pin/power limits, corners, and physical sign-off criteria apply? / View hiện thực, constraint timing, giới hạn floorplan/pin/nguồn, corner và tiêu chí sign-off vật lý nào được áp dụng? |

## 3. Document control and writing rules | Quản lý tài liệu và quy tắc biên soạn

**EN:** Put these fields on the cover or document-control page: product and IP name, IP identifier, document identifier, revision, release status, date, owner, approvers, supported product/SoC variants, applicable RTL or collateral baseline, and information-classification level. Do not publish internal names, confidential implementation details, or support commitments without the IP owner's approval.

**VI:** Đặt các trường sau ở trang bìa hoặc trang quản lý tài liệu: tên sản phẩm và IP, mã IP, mã tài liệu, revision, trạng thái phát hành, ngày, người phụ trách, người duyệt, biến thể sản phẩm/SoC được hỗ trợ, baseline RTL hoặc collateral áp dụng và mức phân loại thông tin. Không công bố tên nội bộ, chi tiết hiện thực mật hoặc cam kết hỗ trợ khi chưa được chủ sở hữu IP duyệt.

| Rule / Quy tắc | Requirement / Yêu cầu |
|---|---|
| Normative language / Ngôn ngữ chuẩn tắc | **shall** means mandatory and verifiable; **should** means recommended; **may** means optional. Do not use these terms interchangeably. / **shall** là bắt buộc và có thể kiểm chứng; **should** là khuyến nghị; **may** là tùy chọn. Không dùng thay thế lẫn nhau. |
| Requirement IDs / Mã requirement | Give each normative requirement a stable, unique ID and at least one verification method or an approved rationale for not verifying it. / Mỗi requirement chuẩn tắc phải có ID duy nhất, ổn định và ít nhất một phương pháp verification hoặc lý do không kiểm tra đã được duyệt. |
| Evidence and status / Bằng chứng và trạng thái | Separate guaranteed behavior, target values, estimates, measured results, assumptions, and examples. State configuration, conditions, units, source, and evidence for each result. / Tách hành vi được đảm bảo, giá trị mục tiêu, ước tính, kết quả đo, giả định và ví dụ. Ghi cấu hình, điều kiện, đơn vị, nguồn và bằng chứng cho từng kết quả. |
| Standards / Tiêu chuẩn | Cite exact title, revision, applicable clauses/profile, supported subset, deviations, and compliance evidence. / Ghi tên đầy đủ, revision, điều khoản/profile áp dụng, tập con được hỗ trợ, sai khác và bằng chứng tuân thủ. |
| Traceability / Truy vết | Link every requirement to its source and to the relevant function, interface, CSR, test, constraint, or implementation evidence. / Liên kết từng requirement với nguồn và function, interface, CSR, test, constraint hoặc bằng chứng hiện thực liên quan. |

## 4. Recommended HDS structure | Cấu trúc HDS khuyến nghị

1. Overview | Tổng quan
2. Parameters | Tham số
3. Block diagram | Sơ đồ khối
4. Functions | Chức năng
5. Interfaces | Giao diện
6. Control and Status Registers | Thanh ghi điều khiển và trạng thái
7. Software programming | Lập trình phần mềm
8. Integration guideline | Hướng dẫn tích hợp
9. Synthesis design constraints and STA | Constraint synthesis và STA
10. Design for Test | DFT
11. Physical design | PD
12. Verification and validation | DV và validation
13. Security, safety, and reliability | An ninh, an toàn và độ tin cậy
14. Product deliverables and release status | Gói bàn giao và trạng thái phát hành
15. Appendices: traceability, revision history, acronyms, and references | Phụ lục: truy vết, lịch sử revision, chữ viết tắt và tài liệu tham khảo

### Front matter | Phần đầu tài liệu

**EN:** Include the cover, document control, approval status, revision history, intended audience, information classification, and a contents page. State the normative source of truth and the precedence among this HDS, protocol standards, configuration collateral, and integration guides.

**VI:** Gồm trang bìa, quản lý tài liệu, trạng thái duyệt, lịch sử revision, đối tượng đọc, phân loại thông tin và mục lục. Nêu nguồn chuẩn tắc và thứ tự ưu tiên giữa HDS, tiêu chuẩn giao thức, tài liệu cấu hình và hướng dẫn tích hợp.

### 1. Overview | Tổng quan

#### 1.1 IP description | Mô tả IP

**EN:** Explain the problem solved, product role, functional boundary, primary data/control flow, intended use cases, external dependencies, and excluded responsibilities. Identify the supported product and IP variants. Describe behavior visible at the IP boundary; do not substitute marketing claims for measurable behavior.

**VI:** Mô tả vấn đề cần giải quyết, vai trò trong sản phẩm, biên chức năng, luồng dữ liệu/điều khiển chính, trường hợp sử dụng, phụ thuộc bên ngoài và trách nhiệm loại trừ. Xác định biến thể sản phẩm và IP được hỗ trợ. Mô tả hành vi quan sát tại biên IP; không thay hành vi đo được bằng nội dung quảng bá.

#### 1.2 Features | Tính năng

**EN:** List one feature per entry. Give each a feature ID, observable result, applicable mode/parameter, required interface or CSR, and related requirement IDs. Mark availability by product variant or license only when that policy is confirmed.

**VI:** Mỗi dòng chỉ mô tả một tính năng. Ghi feature ID, kết quả quan sát được, mode/parameter áp dụng, interface hoặc CSR liên quan và requirement ID. Chỉ ghi phân biệt theo biến thể sản phẩm hoặc license khi chính sách đã được xác nhận.

#### 1.3 Limitations and known issues | Giới hạn và vấn đề đã biết

**EN:** List unsupported protocols, modes, combinations, rates, capacities, concurrency, environmental conditions, and known errata. State the observable effect, mitigation, system responsibility, affected release, and resolution status.

**VI:** Liệt kê giao thức, mode, tổ hợp, tốc độ, dung lượng, xử lý đồng thời, điều kiện môi trường chưa hỗ trợ và errata đã biết. Nêu ảnh hưởng quan sát được, cách giảm thiểu, trách nhiệm hệ thống, release bị ảnh hưởng và trạng thái xử lý.

#### 1.4 Standard compliance | Tuân thủ tiêu chuẩn

**EN:** Record the exact standard revision and clauses implemented. Define profiles and supported subsets, excluded options, deviations, interoperability assumptions, and evidence. Do not claim full compliance when only a subset is implemented.

**VI:** Ghi revision và điều khoản tiêu chuẩn được hiện thực. Xác định profile, tập con hỗ trợ, tùy chọn loại trừ, sai khác, giả định tương tác và bằng chứng. Không tuyên bố tuân thủ đầy đủ khi chỉ hiện thực một tập con.

### 2. Parameters | Tham số

#### 2.1 Parameter model and ownership | Mô hình và quyền sở hữu parameter

**EN:** Distinguish elaboration/generation parameters, synthesis defines supplied by the integration flow, sampled straps, and run-time CSR configuration. Name the owner and the phase at which each value becomes fixed.

**VI:** Phân biệt parameter lúc elaboration/generation, macro synthesis do flow tích hợp cung cấp, strap được lấy mẫu và cấu hình CSR lúc chạy. Ghi người sở hữu và thời điểm mỗi giá trị được cố định.

#### 2.2 User-configurable parameters, dependencies, and legal combinations | Parameter cấu hình, phụ thuộc và tổ hợp hợp lệ

**EN:** For each parameter, state ID/name, type, width, units, default, legal values, dependency, invalid combinations, and impact on ports, features, address maps, memories, interrupts, timing, area, or software. Define whether a value is public and customer-configurable.

**VI:** Với mỗi parameter, ghi ID/tên, kiểu, độ rộng, đơn vị, mặc định, giá trị hợp lệ, phụ thuộc, tổ hợp không hợp lệ và ảnh hưởng đến port, tính năng, map địa chỉ, memory, interrupt, timing, area hoặc phần mềm. Xác định giá trị có được công bố và cho phép khách hàng cấu hình hay không.

#### 2.3 Parameter validation requirements | Yêu cầu kiểm tra parameter

**EN:** State where invalid values are detected and whether the result is an error, warning, disabled feature, or safe default. Define observable behavior and the evidence required at generation, elaboration, lint, synthesis, DV, and STA as applicable.

**VI:** Nêu nơi phát hiện giá trị không hợp lệ và kết quả là error, warning, tắt tính năng hay dùng giá trị an toàn. Xác định hành vi quan sát được và bằng chứng cần có ở bước generation, elaboration, lint, synthesis, DV và STA nếu áp dụng.

#### 2.4 Validated configuration examples | Ví dụ cấu hình đã xác nhận

**EN:** Provide representative legal configurations with resolved values, enabled features, target context, source revision/hash, validation status, and links to evidence. Label untested legal combinations as unverified.

**VI:** Đưa các cấu hình hợp lệ tiêu biểu cùng giá trị đã chốt, tính năng bật, bối cảnh mục tiêu, revision/hash nguồn, trạng thái xác nhận và link bằng chứng. Đánh dấu tổ hợp hợp lệ nhưng chưa test là chưa được xác nhận.

### 3. Block diagram | Sơ đồ khối

#### 3.1 IP block diagram | Sơ đồ khối IP

**EN:** Show the IP boundary, major internal blocks, data and control paths, interface groups, clock/reset/power domains, and optional memory/macros. Add an SoC context diagram when it clarifies buses, interrupt routing, DMA, pins, or external dependencies. Label diagrams and explain abbreviations.

**VI:** Thể hiện biên IP, các khối chính, luồng dữ liệu/điều khiển, nhóm interface, miền clock/reset/nguồn và memory/macro nếu có. Thêm sơ đồ bối cảnh SoC nếu cần làm rõ bus, đường interrupt, DMA, pin hoặc phụ thuộc ngoài. Đặt tên sơ đồ và giải thích chữ viết tắt.

#### 3.2 Block behavior and inter-block relationships | Hành vi khối và quan hệ giữa các khối

**EN:** Describe each block's responsibility and its connections. Explain arbitration, buffering, ownership of state, backpressure, data ordering, reset release, clock-domain crossings, and concurrent operations at the architectural level.

**VI:** Mô tả trách nhiệm và kết nối của từng khối. Giải thích arbitration, buffering, quyền sở hữu state, backpressure, thứ tự dữ liệu, nhả reset, crossing clock domain và hoạt động đồng thời ở mức kiến trúc.

### 4. Functions | Chức năng

**EN:** Create one numbered subsection for each externally observable function, with a stable ID such as `FN-001`. Repeat the same content pattern for every function.

**VI:** Tạo một mục riêng có số thứ tự cho mỗi chức năng quan sát được từ bên ngoài, với ID ổn định như `FN-001`. Dùng cùng cấu trúc nội dung cho mọi function.

For each function, describe / Với mỗi function, mô tả:

1. **Purpose, use case, and scope:** trigger, preconditions, inputs, outputs, completion indication, dependencies, and excluded behavior. / **Mục đích, trường hợp sử dụng và phạm vi:** trigger, điều kiện trước, input, output, dấu hiệu hoàn tất, phụ thuộc và hành vi loại trừ.
2. **Function diagram:** relevant blocks, signals, state ownership, and paths. / **Sơ đồ chức năng:** các khối, tín hiệu, quyền sở hữu state và đường dữ liệu liên quan.
3. **Functional behavior:** operation sequence, modes, priority, ordering, buffering, state transitions, corner cases, and concurrency. / **Hành vi chức năng:** trình tự hoạt động, mode, độ ưu tiên, thứ tự, buffering, chuyển state, trường hợp biên và xử lý đồng thời.
4. **Timing and waveforms:** latency/throughput guarantees, units, clock domain, handshake timing, backpressure, reset behavior, success and error examples. / **Timing và waveform:** cam kết latency/throughput, đơn vị, clock domain, timing handshake, backpressure, hành vi reset, ví dụ thành công và lỗi.
5. **Error and recovery:** detection, status/interrupt, partial completion, retry/abort, data integrity, and recovery sequence. / **Lỗi và khôi phục:** phát hiện, status/interrupt, hoàn tất một phần, retry/abort, toàn vẹn dữ liệu và trình tự khôi phục.
6. **Verification obligations:** requirement IDs, representative scenarios, assertions or static checks, and coverage intent. / **Nghĩa vụ verification:** requirement ID, scenario tiêu biểu, assertion hoặc kiểm tra tĩnh và mục tiêu coverage.

### 5. Interfaces | Giao diện

#### 5.1 Interface group | Nhóm interface

**EN:** Give each interface group an ID such as `IF-001`. For every signal, document name, direction, width, meaning, clock domain, reset value/behavior, active polarity, idle value, and when data/control is valid. For buses, state protocol and exact revision, role, supported subset, transaction ordering, outstanding limits, backpressure, response/error behavior, and deviations. Record timing/electrical assumptions and required tie-offs.

**VI:** Đặt ID như `IF-001` cho từng nhóm interface. Với mỗi tín hiệu, ghi tên, hướng, độ rộng, ý nghĩa, clock domain, giá trị/hành vi reset, cực tính active, giá trị idle và điều kiện hợp lệ của data/control. Với bus, ghi protocol và revision chính xác, vai trò, tập con hỗ trợ, thứ tự transaction, giới hạn outstanding, backpressure, response/error và sai khác. Ghi giả định timing/điện và tie-off bắt buộc.

### 6. Control and Status Registers | Thanh ghi điều khiển và trạng thái

**EN:** State the register interface and address window, alignment, width, endianness, access privilege, wait/error behavior, and reset conditions. Include a register summary/map and one detail table per register: offset, reset value, field range/name, access type, software meaning, hardware meaning, write/read side effects, reserved-bit behavior, and access restrictions. Describe atomicity, shadow/commit behavior, aliases, clear-on-read, W1C/W0C, hardware set/clear priority, and interrupt/status lifecycle. Link each field to features and requirements.

**VI:** Nêu interface thanh ghi, vùng địa chỉ, alignment, độ rộng, endian, quyền truy cập, wait/error và điều kiện reset. Có bảng tổng quan/map và bảng chi tiết từng register: offset, giá trị reset, range/tên field, loại truy cập, ý nghĩa với software/hardware, tác động khi đọc/ghi, hành vi bit reserved và giới hạn truy cập. Mô tả tính atomic, shadow/commit, alias, clear-on-read, W1C/W0C, ưu tiên set/clear từ hardware và vòng đời interrupt/status. Liên kết field với tính năng và requirement.

**EN:** If the IP has no software-visible registers, retain the section and state `N/A`, explain the control model, and identify the interface that replaces CSR access.

**VI:** Nếu IP không có register nhìn thấy từ software, vẫn giữ mục này, ghi `N/A`, giải thích mô hình điều khiển và nêu interface thay cho CSR.

### 7. Software programming | Lập trình phần mềm

**EN:** Describe ownership between firmware, hardware, and system services. Give ordered flows for initialization, configuration/start, normal operation, status/result collection, interrupt service, DMA, error recovery, shutdown, reset, and power transitions where applicable. Include preconditions, register accesses, expected outcomes, timeouts, and safe sequence. Provide a worked example only for a supported configuration.

**VI:** Mô tả quyền sở hữu giữa firmware, hardware và dịch vụ hệ thống. Đưa trình tự cho khởi tạo, cấu hình/bắt đầu, vận hành, đọc status/kết quả, xử lý interrupt, DMA, khôi phục lỗi, shutdown, reset và chuyển nguồn khi áp dụng. Ghi điều kiện trước, truy cập register, kết quả mong đợi, timeout và trình tự an toàn. Chỉ đưa ví dụ hoàn chỉnh cho cấu hình được hỗ trợ.

### 8. Integration guideline | Hướng dẫn tích hợp

**EN:** Give SoC integrators actionable connection and configuration requirements: bus/address mapping, privilege/security, clock/reset/power/CDC, interrupt routing, DMA and memory endpoints, pins/pad/pinmux, unused-signal tie-offs, isolation/retention, arbitration/QoS, and dependencies. Include a bring-up checklist, integration hazards, performance boundaries, liveness assumptions, and required system-level validation. Distinguish IP guarantees from fabric or platform behavior.

**VI:** Đưa yêu cầu kết nối/cấu hình có thể thực hiện cho nhóm tích hợp SoC: bus/map địa chỉ, privilege/security, clock/reset/nguồn/CDC, định tuyến interrupt, DMA và memory endpoint, pin/pad/pinmux, tie-off tín hiệu không dùng, isolation/retention, arbitration/QoS và phụ thuộc. Có checklist bring-up, nguy cơ tích hợp, giới hạn hiệu năng, giả định liveness và validation hệ thống cần thiết. Phân biệt cam kết của IP với hành vi fabric/platform.

### 9. Synthesis design constraints and STA | Constraint synthesis và STA

**EN:** Define timing intent and constraints for each supported mode: primary/generated clocks, frequencies, relationships, uncertainty, input/output delays, loads, transitions, false/multicycle/max/min paths, case analysis, and exceptions. Every exception needs precise endpoints, mode, rationale, owner, approval, and CDC/RDC evidence. Record SDC revision, tool/corner, unconstrained paths, ignored constraints, and sign-off criteria. Separate guaranteed limits from implementation targets.

**VI:** Định nghĩa ý đồ timing và constraint cho từng mode được hỗ trợ: clock chính/generated, tần số, quan hệ, uncertainty, input/output delay, load, transition, false/multicycle/max/min path, case analysis và exception. Mỗi exception cần endpoint chính xác, mode, lý do, người phụ trách, phê duyệt và bằng chứng CDC/RDC. Ghi revision SDC, tool/corner, path chưa constraint, constraint bị bỏ qua và tiêu chí sign-off. Tách giới hạn được đảm bảo khỏi mục tiêu hiện thực.

### 10. Design for Test | DFT

**EN:** Define test modes, access and controls; scan domains/chains and clock/reset overrides; memory instances and MBIST/BISR ownership; test points and embedded instruments; isolation and functional bypass; ATPG assumptions/coverage; mode entry/exit; manufacturing procedure; and recovery to functional operation. Identify which requirements belong to the IP and which depend on the SoC DFT architecture.

**VI:** Định nghĩa mode, truy cập và điều khiển test; scan domain/chain và override clock/reset; memory instance và quyền sở hữu MBIST/BISR; test point và instrument nhúng; isolation và bypass chức năng; giả định/coverage ATPG; vào/ra mode; quy trình sản xuất và khôi phục vận hành. Xác định yêu cầu nào thuộc IP, yêu cầu nào phụ thuộc kiến trúc DFT của SoC.

### 11. Physical design | PD

**EN:** State the implementation boundary and delivered views (for example RTL, gate netlist, LEF, Liberty, GDS/OASIS, abstracts, and SDC) only when actually included. Define floorplan/utilization guidance, boundary pins, routing layers/obstructions, macro constraints, power domains/supplies, isolation/retention/tie cells, and package/ESD/analog restrictions. Define routing, congestion, antenna, EM/IR, DRC/LVS and waiver criteria. Report area, timing, and power only with configuration, process/voltage/temperature corner, mode, tool/flow revision, and whether results are synthesis or post-route.

**VI:** Nêu biên hiện thực và view bàn giao (ví dụ RTL, gate netlist, LEF, Liberty, GDS/OASIS, abstract, SDC) chỉ khi thực sự có trong gói phát hành. Định nghĩa hướng dẫn floorplan/utilization, pin biên, layer/obstruction route, giới hạn macro, miền/nguồn điện, isolation/retention/tie cell và giới hạn package/ESD/analog. Đặt tiêu chí route, congestion, antenna, EM/IR, DRC/LVS và waiver. Chỉ báo cáo area, timing, power kèm cấu hình, process/voltage/temperature corner, mode, revision tool/flow và trạng thái synthesis hay post-route.

### 12. Verification and validation | DV và validation

**EN:** Define the verification boundary, sign-off configurations, assumptions, exclusions, testbench architecture and versioned dependencies (simulator, VIP, reference models). Trace each requirement to directed/random tests, assertions, static checks, functional/code coverage, pass criteria, and evidence. Cover nominal, boundary, reset, concurrency, backpressure, illegal access, error, interrupt/DMA, and low-power cases when applicable. Record regression revision, seeds, logs/waveforms, results, coverage, waivers, unresolved gaps, and approval. Verification expectations must come from this HDS and normative standards, not from generated RTL behavior.

**VI:** Định nghĩa biên verification, cấu hình sign-off, giả định, phần loại trừ, kiến trúc testbench và dependency có version (simulator, VIP, reference model). Truy vết từng requirement tới directed/random test, assertion, kiểm tra tĩnh, functional/code coverage, tiêu chí pass và bằng chứng. Cover nominal, boundary, reset, đồng thời, backpressure, truy cập sai, error, interrupt/DMA và low-power khi áp dụng. Ghi revision regression, seed, log/waveform, kết quả, coverage, waiver, gap chưa giải quyết và phê duyệt. Kỳ vọng verification phải xuất phát từ HDS và tiêu chuẩn chuẩn tắc, không suy ra từ hành vi RTL được sinh.

### 13. Security, safety, and reliability | An ninh, an toàn và độ tin cậy

**EN:** State the security boundary, protected assets, privilege/access rules, lifecycle and debug/test access, isolation, sensitive-data handling, zeroization, and security-related error behavior when applicable. Define safety goals, assumptions, diagnostic coverage, safe state, fault reaction, and required evidence only when the IP has a safety allocation. Describe reliability mechanisms such as ECC/parity, fault detection, state recovery, and data-integrity limits where used. Cite the governing security/safety standard and exact revision; do not claim certification or a safety level without approved evidence. Use `N/A` with rationale when these topics are outside the IP scope.

**VI:** Khi áp dụng, nêu biên bảo mật, tài sản cần bảo vệ, quy tắc privilege/truy cập, lifecycle và quyền debug/test, isolation, xử lý dữ liệu nhạy cảm, zeroization và hành vi lỗi liên quan bảo mật. Chỉ định nghĩa safety goal, giả định, diagnostic coverage, trạng thái an toàn, phản ứng lỗi và bằng chứng cần thiết khi IP có phân bổ yêu cầu an toàn. Mô tả cơ chế tin cậy như ECC/parity, phát hiện lỗi, phục hồi trạng thái và giới hạn toàn vẹn dữ liệu nếu có. Ghi tiêu chuẩn an ninh/an toàn và revision chính xác; không tuyên bố chứng nhận hoặc safety level khi chưa có bằng chứng được duyệt. Ghi `N/A` kèm lý do nếu nằm ngoài phạm vi IP.

### 14. Product deliverables and release status | Gói bàn giao và trạng thái phát hành

**EN:** Give a release manifest with file/view name, version or hash, configuration, intended consumer, license/classification, and validation status. List supported process nodes/platforms, tool versions or compatibility range, required collateral, known errata, release maturity, and customer-visible restrictions. Separate included deliverables from optional or separately licensed items. State support and lifecycle commitments only when formally approved.

**VI:** Lập manifest release với tên file/view, version hoặc hash, cấu hình, nhóm sử dụng, license/phân loại và trạng thái validation. Liệt kê process node/platform hỗ trợ, version hoặc khoảng tương thích tool, collateral bắt buộc, errata đã biết, mức trưởng thành release và giới hạn công bố cho khách hàng. Tách deliverable đi kèm khỏi mục tùy chọn hoặc cấp phép riêng. Chỉ nêu cam kết hỗ trợ/vòng đời khi đã được phê duyệt chính thức.

### Appendices | Phụ lục

| Appendix / Phụ lục | Required content / Nội dung |
|---|---|
| A. Requirement traceability / Truy vết requirement | Requirement ID, source clause, function/interface/CSR, verification method, evidence, status, and approved waiver. / Requirement ID, điều khoản nguồn, function/interface/CSR, phương pháp verification, bằng chứng, trạng thái và waiver đã duyệt. |
| B. Revision history and approvals / Lịch sử revision và phê duyệt | Revision, change summary, affected requirements/configurations, author, reviewers, approval date. / Revision, tóm tắt thay đổi, requirement/cấu hình ảnh hưởng, người viết, người review, ngày duyệt. |
| C. Acronyms and definitions / Chữ viết tắt và định nghĩa | Define terms used across product, software, DV, DFT, and PD sections. / Định nghĩa thuật ngữ dùng trong các mục sản phẩm, software, DV, DFT và PD. |
| D. References / Tài liệu tham khảo | Exact document title, identifier, revision/date, owner/publisher, and applicable clauses. / Tên tài liệu, mã, revision/ngày, chủ sở hữu/nhà phát hành và điều khoản áp dụng. |

## 5. Reader review checklist | Checklist review theo nhóm

| Team / Nhóm | Review before HDS release / Nội dung cần review trước phát hành HDS |
|---|---|
| Product/IP owner / Chủ sở hữu sản phẩm/IP | Product boundary, feature list, supported variants, limitations, standards claims, release manifest, information classification, and approved security/safety claims. / Biên sản phẩm, danh sách tính năng, biến thể hỗ trợ, giới hạn, tuyên bố tiêu chuẩn, manifest release, phân loại thông tin và tuyên bố an ninh/an toàn đã duyệt. |
| User, software, and integration / Người dùng, software và tích hợp | Interfaces, legal configurations, CSRs, programming sequence, clocks/resets/power, address map, interrupts/DMA, tie-offs, and bring-up. / Interface, cấu hình hợp lệ, CSR, trình tự lập trình, clock/reset/nguồn, map địa chỉ, interrupt/DMA, tie-off và bring-up. |
| DV / Nhóm DV | Requirement completeness, observable expected behavior, standard revisions, test matrix, assertions, coverage goals, pass criteria, and evidence reproducibility. / Độ đầy đủ requirement, hành vi mong đợi quan sát được, revision tiêu chuẩn, ma trận test, assertion, mục tiêu coverage, tiêu chí pass và khả năng tái lập bằng chứng. |
| DFT / Nhóm DFT | Test-mode controls, scan/memory-test scope, clock/reset override, access/security, ATPG assumptions, and manufacturing recovery. / Điều khiển test mode, phạm vi scan/kiểm tra memory, override clock/reset, truy cập/security, giả định ATPG và khôi phục sau kiểm tra sản xuất. |
| PD and STA / Nhóm PD và STA | SDC completeness, supported corners/modes, boundary budgets, physical views, pins/macros/power, exception approval, PPA conditions, and sign-off limits. / Độ đầy đủ SDC, corner/mode hỗ trợ, budget biên, view vật lý, pin/macro/nguồn, duyệt exception, điều kiện PPA và giới hạn sign-off. |

## 6. Release readiness criteria | Tiêu chí sẵn sàng phát hành

**EN:** Release the HDS only when every required section is populated or explicitly marked `N/A` with rationale; every `TBD` has an owner and disposition; normative requirements are testable and traceable; protocol and product claims have evidence; interface and configuration tables agree; DV/DFT/PD assumptions are reviewed by their owners; PPA and timing data state their conditions; and the release manifest matches the actual package. Record unresolved risks and approved waivers; do not silently convert them into guarantees.

**VI:** Chỉ phát hành HDS khi mọi mục bắt buộc đã có nội dung hoặc được ghi `N/A` kèm lý do; mỗi `TBD` có người phụ trách và hướng xử lý; requirement chuẩn tắc kiểm thử/truy vết được; tuyên bố về protocol và sản phẩm có bằng chứng; bảng interface/cấu hình thống nhất; giả định DV/DFT/PD được chủ sở hữu review; dữ liệu PPA/timing ghi điều kiện đo; manifest khớp gói bàn giao thực tế. Ghi rủi ro và waiver đã duyệt; không âm thầm biến chúng thành cam kết.
