# VLSIT — AI-Assisted RTL Design & Verification Flow

**EN:** An AI-assisted RTL design and verification workflow based on engineering requirements and human review.

**VI:** Quy trình thiết kế và kiểm chứng RTL có hỗ trợ AI, dựa trên yêu cầu kỹ thuật và review của kỹ sư.

> **Status / Trạng thái:** Engineering prototype / Mẫu thử kỹ thuật · Claude Code prompts / Prompt Claude Code · Codex CLI skills / Skill Codex CLI · SystemVerilog RTL and verification / RTL SystemVerilog và verification

## Reference | Tài liệu tham khảo

[User guide / Hướng dẫn sử dụng — automatic and step-by-step / tự động và từng bước](guideline.md)

## Overview | Tổng quan

**EN:** VLSIT organizes work from hardware specification through requirements, configuration, RTL, assertions and testbench, verification, and documentation. Claude Code slash commands and Codex CLI skills guide the agent through the corresponding phases.

**VI:** VLSIT tổ chức quy trình từ đặc tả phần cứng, requirement, cấu hình, RTL, assertion và testbench, verification đến tài liệu. Slash command của Claude Code và skill của Codex CLI hướng dẫn agent thực hiện các phase tương ứng.

**EN:** The flow tracks requirements to specification/standard clauses, reviewed SVA, test cases, DUT results, and human sign-off using a Requirement Traceability Matrix (RTM). RTL generation and verification generation are separate branches that share an approved baseline.

**VI:** Flow truy vết requirement đến điều khoản specification/standard, SVA đã review, testcase, kết quả DUT và sign-off của kỹ sư bằng Requirement Traceability Matrix (RTM). RTL generator và verification generator là hai nhánh riêng dùng chung baseline đã duyệt.

**EN:** The repository contains agent prompts, an RTL rule template, JSON Schemas, helper scripts, diagrams, and saved examples. The common flow is described first; design examples appear at the end.

**VI:** Repository chứa prompt cho agent, mẫu quy tắc RTL, JSON Schema, script hỗ trợ, sơ đồ và ví dụ đã lưu. Flow dùng chung được mô tả trước; ví dụ thiết kế nằm ở cuối README.

**EN — Language policy:** Codex skills, Claude commands, agent guidance, and schema descriptions use technical English. Documents and README files may present both English and Vietnamese.

**VI — Quy định ngôn ngữ:** Skill Codex, command Claude, hướng dẫn cho agent và mô tả schema dùng tiếng Anh kỹ thuật. Tài liệu và README có thể trình bày song ngữ Anh–Việt.

**EN — AI scope:** The project uses an LLM through Claude Code or Codex CLI. It does not contain model weights, a training or fine-tuning pipeline, a RAG system, or a standalone LLM API application. Model access and authentication are managed by the host environment.

**VI — Phạm vi AI:** Project dùng LLM thông qua Claude Code hoặc Codex CLI. Repository không chứa model weights, pipeline training/fine-tuning, hệ thống RAG hay ứng dụng LLM API độc lập. Môi trường chạy bên ngoài quản lý model và xác thực.

## Purpose | Mục đích

| EN | VI |
|---|---|
| Convert a hardware specification into identified requirements, a configuration, and an RTL design. | Chuyển đặc tả phần cứng thành requirement có định danh, cấu hình và thiết kế RTL. |
| Generate RTL from the approved specification and configuration; generate SVA and tests independently from the approved verification contract. | Sinh RTL từ đặc tả và cấu hình đã duyệt; sinh SVA và testcase độc lập từ verification contract đã duyệt. |
| Compare AI-generated artifacts with lint, synthesis, and simulation results. | Đối chiếu artifact do AI tạo với kết quả lint, synthesis và simulation. |
| Track missing evidence, verification gaps, and review status. | Theo dõi bằng chứng còn thiếu, verification gap và trạng thái review. |
| Preserve design runs for inspection and comparison. | Lưu các lần chạy thiết kế để kiểm tra và so sánh. |

**EN:** The project supports AI-assisted RTL engineering and IP prototyping. Saved reports describe their recorded runs; they do not replace reproducible regression, formal proof, static timing analysis (STA), or ASIC sign-off.

**VI:** Project hỗ trợ nghiên cứu AI-assisted RTL engineering và tạo IP prototype. Report lưu trong repository chỉ mô tả lần chạy tương ứng; chúng không thay thế regression tái lập, formal proof, static timing analysis (STA) hoặc ASIC sign-off.

## Architecture & Flow | Kiến trúc và flow

**EN:** The diagram shows the `/autoflow` sequence. Existing RTL may use the optional style converter in place of RTL generation. In a manual run, either RTL path may start after Gate 2 because neither consumes the verification contract.

**VI:** Sơ đồ thể hiện thứ tự của `/autoflow`. Với RTL có sẵn, có thể dùng bộ chuyển style thay cho bước sinh RTL. Khi chạy từng phase, cả hai nhánh RTL đều có thể bắt đầu sau Gate 2 vì không dùng verification contract.

~~~mermaid
flowchart TD
    U["Existing specification or design description<br/>Đặc tả có sẵn hoặc mô tả thiết kế"] --> S["Reviewed hardware specification<br/>Đặc tả phần cứng đã review"]
    U --> W["spec_writer, if needed"]
    W --> S
    S --> P[spec_parser]
    P --> R[structured_spec.json]
    R --> G1{"Gate 1: Spec review<br/>Review đặc tả"}
    G1 --> C[config_ui]
    C --> F["final_config.json / Gate 2"]
    F --> VC["verification_contract: spec/config/standards"]
    VC --> G3A{"Gate 3a: contract review<br/>Review verification baseline"}
    G3A --> R{"New or existing RTL?<br/>Sinh mới hay RTL có sẵn?"}
    R --> RTL["rtl_generator: new RTL"]
    R --> SC["rtl_style_converter: existing RTL"]
    G3A --> A["Verification branch: SVA + testbench + test plan"]
    A --> G3B{"Gate 3b: Property review<br/>Review SVA"}
    A --> G4{"Gate 4: Test-plan review<br/>Review tests"}
    RTL --> V["DUT integration + verification run"]
    SC --> V
    G3B --> V
    G4 --> V
    V --> CC["code_coverage: measured baseline + optional target closure"]
    CC --> G5{"Gate 5: Verification review<br/>Review verification"}
    G5 --> D["spec_pdf_generator: Markdown + PDF"]
~~~

### Architecture layers | Các lớp kiến trúc

| Layer / Lớp | Components / Thành phần | EN role | Vai trò |
|---|---|---|---|
| AI phase instructions / Hướng dẫn phase | .claude/commands/*.md, .agents/skills/*/SKILL.md | Guides Claude Code and Codex through phases, input checks, and review reports. | Hướng dẫn Claude Code và Codex qua các phase, kiểm tra đầu vào và báo cáo review. |
| Flow maintenance / Bảo trì flow | .claude/skills/rtl-flow-maintainer/, shared JSON Schemas | Maintains command authoring rules and artifact formats; it does not execute a design phase. | Bảo trì quy tắc biên soạn command và định dạng artifact; không chạy phase thiết kế. |
| Data and traceability / Dữ liệu và truy vết | JSON artifacts, JSON Schema, RTM | Stores requirements, configuration, mappings, and gate status. | Lưu requirement, cấu hình, mapping và trạng thái gate. |
| Design and execution / Thiết kế và thực thi | SystemVerilog, shell/Yosys scripts, EDA tools | Implements hardware and produces tool evidence. | Hiện thực phần cứng và tạo bằng chứng từ công cụ. |

**EN:** Slash commands and Codex skills are instructions for an agent, not shell programs or standalone workflow engines. Gate enforcement and artifact updates depend on the agent following those instructions; the repository has no unified orchestrator or validator that enforces the full flow. A phase reference such as /phase_name inside a Codex skill names a Claude source command; Codex reads and performs the matching skill directly.

**VI:** Slash command và Codex skill là hướng dẫn cho agent, không phải chương trình shell hay workflow engine độc lập. Việc thực thi gate và cập nhật artifact phụ thuộc vào agent làm đúng hướng dẫn; repository chưa có orchestrator hoặc validator thống nhất để cưỡng chế toàn bộ flow. Tham chiếu phase như /phase_name trong Codex skill là tên command Claude nguồn; Codex đọc và thực hiện skill tương ứng trực tiếp.

**EN:** In `/autoflow`, Gate 3a approves the spec/config/standard-based verification contract before the RTL and verification branches. `/rtl_generator` creates new RTL from the specification and configuration. `/rtl_style_converter` instead converts user-supplied RTL without changing its module topology or behavior and reports suspected original bugs separately. The verification branch consumes the approved contract and golden sources, not either RTL version. Final verification integrates the selected RTL as the DUT. `/autoflow` runs phases sequentially in one session; the repository has no parallel scheduler.

**VI:** Trong `/autoflow`, Gate 3a duyệt verification contract dựa trên spec/config/standard trước nhánh RTL và verification. `/rtl_generator` sinh RTL mới từ đặc tả và cấu hình. `/rtl_style_converter` chuyển RTL do user cung cấp, giữ cấu trúc module và hành vi, đồng thời báo bug gốc nghi vấn riêng. Nhánh verification dùng contract và nguồn chuẩn đã duyệt, không dùng phiên bản RTL nào để tạo expected behavior. Verification cuối tích hợp RTL được chọn làm DUT. `/autoflow` chạy tuần tự trong một session; repository không có scheduler chạy song song.

## Repository structure | Cấu trúc repository

~~~text
VLSIT_RTL_Generator_AI_Model/
├── .claude/commands/         # Claude Code prompts / Prompt cho Claude Code
├── .claude/skills/           # Claude Code maintenance skill and schemas / Skill bảo trì và schema
├── .agents/skills/           # Codex CLI skills / Skill cho Codex CLI
├── agent_structure/          # Flow diagrams / Sơ đồ flow
├── common_rtl/               # Reusable RTL IP library / Thư viện RTL IP dùng lại
├── example/                  # Saved design examples / Ví dụ thiết kế đã lưu
├── scripts/                  # Helper scripts / Script hỗ trợ
├── spec_template/            # IP, CSR, and RTL-rule templates / Mẫu spec IP, CSR và rule RTL
├── guideline.md              # Step-by-step user guide / Hướng dẫn từng bước
└── sourceme.sh               # Linux EDA environment setup / Thiết lập môi trường EDA Linux
~~~

**EN:** Project folders include short bilingual READMEs. The `example/` folders contain historical artifacts, not the required output tree or evidence for a new run. The default RTL rule is `spec_template/VLSIT_RTL_Design_Rule.md` when the user supplies none.

**VI:** Các thư mục project có README song ngữ ngắn. Thư mục `example/` chứa artifact lịch sử, không phải cây output bắt buộc hay bằng chứng cho lần chạy mới. RTL rule mặc định là `spec_template/VLSIT_RTL_Design_Rule.md` khi người dùng không cung cấp file khác.

### Claude Code commands | Command Claude Code

| Command | EN purpose | Chức năng |
|---|---|---|
| /autoflow | Runs the gated flow across phases. | Điều phối flow qua các phase và gate review. |
| /spec_writer | Drafts an input specification from a design description. | Soạn đặc tả đầu vào từ mô tả thiết kế. |
| /spec_parser | Extracts requirements, IDs, ambiguity, and mappings. | Trích requirement, ID, ambiguity và mapping. |
| /config_ui | Selects parameters and checks configuration constraints. | Chọn parameter và kiểm tra ràng buộc cấu hình. |
| /verification_contract | Builds and reviews an RTL-independent interface and behavioral oracle from the specification, configuration, and exact standards. | Tạo và review interface cùng oracle độc lập RTL từ specification, cấu hình và chuẩn có revision cụ thể. |
| /rtl_generator | Generates RTL and runs lint and synthesis steps. | Sinh RTL và chạy lint, synthesis. |
| /rtl_style_converter | Converts existing RTL while preserving topology and behavior; reports incompatible rules and suspected bugs bilingually. | Chuyển RTL có sẵn, giữ cấu trúc và hành vi; báo rule xung đột và bug nghi vấn bằng hai ngôn ngữ. |
| /sva_generator | Generates interface-level assertions from the approved contract and compiles against its shell. | Sinh assertion tại interface từ contract đã duyệt và compile với shell. |
| /tb_generator | Builds saved tests and a plan from the contract without reading RTL. | Tạo testcase đã lưu và test plan từ contract, không đọc RTL. |
| /verification | Integrates the DUT, runs simulation and mutation checks, and records baseline coverage when supported. | Tích hợp DUT, chạy simulation và mutation, ghi baseline coverage khi công cụ hỗ trợ. |
| /code_coverage | Shows measured baseline before an optional target; adds saved tests for reachable specification-based gaps. | Hiển thị baseline đã đo trước khi chọn ngưỡng tùy chọn; thêm testcase đã lưu cho gap có thể cover theo specification. |
| /spec_pdf_generator | Builds specification documentation from design artifacts. | Tạo tài liệu đặc tả từ artifact thiết kế. |

**EN:** config_ui is an interactive command, not a separate GUI application. The testbench flow uses plain SystemVerilog, not UVM.

**VI:** config_ui là command tương tác, không phải ứng dụng GUI riêng. Flow testbench dùng SystemVerilog thuần, không dùng UVM.

### Codex CLI skills | Skill Codex CLI

**EN:** Invoke a project skill in Codex CLI with its skill name, and provide the specification or configuration path in the request when needed. Each skill maps to one Claude command.

**VI:** Gọi project skill trong Codex CLI bằng tên skill; khi cần, cung cấp đường dẫn spec hoặc cấu hình trong yêu cầu. Mỗi skill ánh xạ với một Claude command.

| Codex skill | Claude Code command |
|---|---|
| $source-command-autoflow | /autoflow |
| $source-command-spec-writer | /spec_writer |
| $source-command-spec-parser | /spec_parser |
| $source-command-config-ui | /config_ui |
| $source-command-verification-contract | /verification_contract |
| $source-command-rtl-generator | /rtl_generator |
| $source-command-rtl-style-converter | /rtl_style_converter |
| $source-command-sva-generator | /sva_generator |
| $source-command-tb-generator | /tb_generator |
| $source-command-verification | /verification |
| $source-command-code-coverage | /code_coverage |
| $source-command-spec-pdf-generator | /spec_pdf_generator |

**EN:** The Codex phase skills read the matching Claude commands and preserve their gates. The Claude `rtl-flow-maintainer` skill maintains command and schema references; it does not run a design phase. Adapt IP mappings, constraints, and tool paths for each design.

**VI:** Skill Codex đọc command Claude tương ứng và giữ các gate. Skill Claude `rtl-flow-maintainer` dùng để bảo trì command và schema, không chạy phase thiết kế. Điều chỉnh mapping IP, constraint và đường dẫn công cụ cho từng thiết kế.

**EN:** RTL lint/synthesis and all SVA/testbench compile, regression, mutation, and code-coverage runs use one documented Makefile at the design root. Every testcase is saved under `src/tb/tests/`, included in the selected test plan and file list, and runnable through a Make target. The coverage target is optional: the flow shows a measured baseline before asking for a threshold. RTL is the coverage target, while expected behavior still comes from the approved specification and protocol standard.

**VI:** Lint/synthesis RTL và mọi lệnh compile SVA/testbench, regression, mutation, code coverage dùng một Makefile có mô tả tại root của design. Mỗi testcase được lưu trong `src/tb/tests/`, thêm vào test plan và file list, rồi chạy lại qua Make target. Ngưỡng coverage là tùy chọn; flow phải hiển thị baseline đã đo trước khi hỏi ngưỡng. RTL là đối tượng đo coverage, còn expected behavior vẫn lấy từ specification và protocol standard đã duyệt.

### Gates & traceability | Gate và truy vết

The RTM links / RTM liên kết:

~~~text
REQ-ID → Specification/standard clause → Reviewed oracle/SVA/TC → DUT execution → Human sign-off
~~~

**EN:** Autoflow requires user review at Gate 1 (requirements), Gate 3a (verification contract), Gate 3b (properties), and Gate 5 (DUT verification). Gate 2 may be auto-approved only for unchanged specification defaults with all constraints passing. Gate 4 may be auto-approved only for a complete plan without unresolved issues after contract-shell compilation. Shell compilation is not a DUT pass.

**VI:** Autoflow cần người dùng review tại Gate 1 (requirement), Gate 3a (verification contract), Gate 3b (property) và Gate 5 (DUT verification). Gate 2 chỉ có thể tự duyệt khi giữ nguyên giá trị mặc định trong spec và mọi constraint đạt. Gate 4 chỉ có thể tự duyệt khi plan đầy đủ, không còn vấn đề mở và đã compile với contract shell. Shell compile không chứng minh DUT pass.

**EN:** Verification eligibility uses specification/standard traceability, reviewed oracle/SVA/TC evidence, DUT simulation, and mutation evidence under the current policy. RTL tag presence is not a sign-off condition. N/A is not evidence that mutation requirements passed.

**VI:** Điều kiện sign-off verification dùng truy vết specification/standard, oracle/SVA/TC đã review, DUT simulation và mutation evidence theo chính sách hiện tại. Tag RTL không phải điều kiện sign-off. N/A không chứng minh mutation đã đạt.

## Reusable RTL library and default rules | Thư viện RTL dùng lại và rule mặc định

**EN:** `common_rtl/` holds reusable ASIC RTL blocks together with their specifications (22-section VLSIT template), figures, waveforms, constraints and, where noted in each folder, testbenches and logs. It is separate from the autoflow output trees. Each design folder has its own `rtl/filelist.f`; shared wrappers and cell models are in `common_rtl/000_Common`. See [common_rtl/README.md](common_rtl/README.md) for the directory map, the FIFO and CRC comparisons, and the limits of the area estimates.

**VI:** `common_rtl/` chứa các khối RTL ASIC dùng lại cùng specification (mẫu 22 mục của VLSIT), hình vẽ, waveform, constraint và, nơi thư mục ghi rõ, testbench và log. Thư mục này tách khỏi cây output của autoflow. Mỗi thư mục thiết kế có `rtl/filelist.f` riêng; wrapper và mô hình cell dùng chung nằm ở `common_rtl/000_Common`. Xem [common_rtl/README.md](common_rtl/README.md) để biết bản đồ thư mục, so sánh FIFO và CRC, và giới hạn của các ước lượng diện tích.

| Folder / Thư mục | EN content | Nội dung |
|---|---|---|
| `000_Common` | Shared wrappers (reset synchronizer, tie-off, FIFO SRAM macros, synchronizer cells with a metastability model) and stand-in cell models | Wrapper dùng chung (reset synchronizer, tie-off, SRAM macro cho FIFO, synchronizer cell có mô hình metastability) và mô hình cell stand-in |
| `001_AsyncGrayFIFO` | FIFO for unrelated write/read clocks (Gray pointers, software reset, thresholds) | FIFO cho write/read clock độc lập (Gray pointer, software reset, threshold) |
| `002_SyncFIFO` | FIFO for related synchronous clocks, any depth, optional pointer retiming (specification, RTL, self-checking testbench) | FIFO cho clock đồng bộ có quan hệ, depth bất kỳ, tùy chọn retime pointer (specification, RTL, testbench tự kiểm) |
| `003_AsyncAXI4Bridge`, `004_AsyncAPBBridge` | Asynchronous AXI4 and APB (APB4/APB5) bridges across unrelated clocks | Bridge AXI4 và APB (APB4/APB5) bất đồng bộ giữa các clock độc lập |
| `003_CRC` | Five alternative CRC implementations | Năm phương án CRC thay thế nhau |
| `005_AHB2AXI_Bridge`, `006_AXI2APB_Bridge` | AHB-to-AXI and AXI4-to-APB4 bridges | Bridge AHB sang AXI và AXI4 sang APB4 |
| `007_AXI2TLUL_Bridge`, `008_APB2TLUL_Bridge` | AXI4-to-TL-UL and APB4-to-TL-UL bridges | Bridge AXI4 sang TL-UL và APB4 sang TL-UL |
| `009_HyperRAM_Controller` | AXI4 subordinate HyperRAM controller (specification and research in progress) | Bộ điều khiển HyperRAM với AXI4 subordinate (đang viết specification và research) |

**EN:** The status of each design differs (specification only, RTL with lint, RTL with simulation evidence); read the folder README or the specification section on open items before reuse. None of them includes timing closure, place-and-route or sign-off.

**VI:** Trạng thái từng thiết kế khác nhau (chỉ có specification, RTL kèm lint, RTL kèm bằng chứng mô phỏng); đọc README của thư mục hoặc mục open item trong specification trước khi tái sử dụng. Không thiết kế nào có timing closure, place-and-route hay sign-off.

**EN:** The default coding rules ([spec_template/VLSIT_RTL_Design_Rule.md](spec_template/VLSIT_RTL_Design_Rule.md)) define naming, file structure, and prohibited constructs P1 to P30. Recent additions include NAM-09 (library cells and macros are instantiated only in wrappers and named `u_dont_touch_<function>`), SCP-03 (the only simulation code in a design file is the branch selected by `VLSIT_SYNTHESIS`), FIL-04 to FIL-06 (branch layout, aligned port lists, ports grouped by function), TYP-06 (no redundant declarations), ENM-06 (each FSM current-state register has its own `always_ff`), COM-06 (functions are documented and limited to reuse or clear nontrivial abstractions), and PAR-04 (fixed protocol encodings use width-matched `LPARA_` localparams; `PARA_` is reserved for approved configurable choices).

**VI:** Rule coding mặc định ([spec_template/VLSIT_RTL_Design_Rule.md](spec_template/VLSIT_RTL_Design_Rule.md)) quy định đặt tên, cấu trúc file và danh sách cấm P1 đến P30. Bổ sung gần đây gồm NAM-09 (cell thư viện và macro chỉ instantiate trong wrapper, tên `u_dont_touch_<function>`), SCP-03 (mã mô phỏng duy nhất trong file thiết kế là nhánh `VLSIT_SYNTHESIS`), FIL-04 đến FIL-06 (bố cục nhánh, căn cột port, nhóm port theo chức năng), TYP-06 (không khai báo dư), ENM-06 (mỗi current-state register có `always_ff` riêng), COM-06 (comment mọi function và chỉ dùng khi tái sử dụng hoặc giúp biểu diễn phép biến đổi phức tạp rõ hơn), và PAR-04 (mã protocol cố định dùng `localparam LPARA_` đúng độ rộng; `parameter PARA_` chỉ dành cho cấu hình được phép thay đổi).

**EN:** The block diagram of every specification is drawn with draw.io from the VLSIT symbol library: `vlsit_spec_diagram.py` of the skill `vlsit-asic-ip-microspec` builds the `.drawio` file from a JSON diagram spec, validates the library use, runs the geometry check, renders an SVG for the Markdown specification and inserts it into section 5.2 (rules R-018 to R-020 and R-027 to R-029 of that skill). The diagram spec and the `.drawio` source sit in the `figures/` folder of each design.

**VI:** Sơ đồ khối của mọi specification được vẽ bằng draw.io với thư viện symbol VLSIT: `vlsit_spec_diagram.py` của skill `vlsit-asic-ip-microspec` dựng file `.drawio` từ JSON mô tả sơ đồ, kiểm tra việc dùng thư viện, chạy kiểm tra hình học, xuất SVG cho specification Markdown và chèn vào mục 5.2 (rule R-018 đến R-020 và R-027 đến R-029 của skill). JSON mô tả và file nguồn `.drawio` nằm trong thư mục `figures/` của từng thiết kế.

**EN:** The skills `vlsit-asic-ip-microspec` (specification, waveforms) and `vlsit-rtl-generator` (RTL under this rule file, rule checker, lint, optional testbench) of the companion repository `VLSIT_CODEX_CLAUDE_SKILLS` were used for several designs of `common_rtl`. For a testbench the generator skill requires protocol assertions, saved simulated waveforms next to the specified ones, and, for a clock-domain crossing, runs in both the `VLSIT_SYNTHESIS` branch and the metastability-model branch.

**VI:** Skill `vlsit-asic-ip-microspec` (specification, waveform) và `vlsit-rtl-generator` (RTL theo file rule này, kiểm rule, lint, testbench tùy chọn) của repository đi kèm `VLSIT_CODEX_CLAUDE_SKILLS` đã được dùng cho nhiều thiết kế trong `common_rtl`. Với testbench, skill sinh RTL yêu cầu assertion cho giao thức, lưu waveform mô phỏng cạnh waveform trong specification và, với crossing giữa các miền clock, chạy cả nhánh `VLSIT_SYNTHESIS` lẫn nhánh có mô hình metastability.

**EN:** The register blocks (APB slave with control and status registers) are never written by hand: the git submodule `APB-CSR-Generator` (`https://github.com/nguyenquanicd/APB-CSR-Generator`, script `CSR_Generation.py`) builds them from the CSR workbook `spec_template/VLSIT_CSR_Specification_Template.xlsx`. The skill `vlsit-asic-ip-microspec` plans the registers for it and `vlsit-rtl-generator` runs it (`vlsit_csr_generate.py`, rules R-039 to R-042). Clone with `git clone --recurse-submodules`, or run `git submodule update --init` after a clone.

**VI:** Khối thanh ghi (APB slave có thanh ghi điều khiển và trạng thái) không viết tay: submodule `APB-CSR-Generator` (`https://github.com/nguyenquanicd/APB-CSR-Generator`, script `CSR_Generation.py`) sinh chúng từ workbook CSR `spec_template/VLSIT_CSR_Specification_Template.xlsx`. Skill `vlsit-asic-ip-microspec` lập kế hoạch thanh ghi cho generator và `vlsit-rtl-generator` chạy nó (`vlsit_csr_generate.py`, rule R-039 đến R-042). Clone bằng `git clone --recurse-submodules`, hoặc chạy `git submodule update --init` sau khi clone.

## Tools and environment | Công cụ và môi trường

**EN:** Use the tools required by the selected phase and available on the EDA host. A missing tool means that check was not run; generated files alone are not verification evidence.

**VI:** Dùng công cụ cần cho phase đã chọn và có trên máy EDA. Thiếu công cụ nghĩa là kiểm tra tương ứng chưa chạy; file được sinh không tự chứng minh verification pass.

| Tool/environment / Công cụ/môi trường | EN purpose | Mục đích |
|---|---|---|
| Claude Code or Codex CLI | Reads and performs command prompts or project skills. | Đọc và thực hiện command prompt hoặc project skill. |
| Linux, Bash, Environment Modules | Runtime assumed by the current scripts. | Môi trường mà các script hiện tại giả định. |
| Verilator | RTL lint. | Lint RTL. |
| Yosys; slang plugin when required by the SystemVerilog frontend | Synthesis and support for mutation workflow. | Synthesis và hỗ trợ mutation workflow. |
| Technology Liberty libraries, if mapped synthesis is requested | Provide cells and corners for the selected technology; GF180MCU is an example. | Cung cấp cell và corner cho công nghệ được chọn; GF180MCU là ví dụ. |
| Simulator with required SystemVerilog/SVA support | Compile and run the selected DUT tests and assertions; available features depend on the installed tool. | Compile và chạy testcase cùng assertion đã chọn; tính năng phụ thuộc công cụ được cài. |
| PDF converter, if PDF output is requested | Produces the optional PDF; Markdown remains available without it. | Tạo PDF tùy chọn; Markdown vẫn có khi thiếu công cụ chuyển đổi. |

**EN:** Artifacts record Verilator 5.041, Yosys 0.58/0.58+35, VCS, and Icarus 13.0. These are observed environment versions, not a tested compatibility matrix. sourceme.sh also loads a toolchain and lists tools from OSS CAD Suite; adapt it for the target IP. SymbiYosys or cocotb in the setup does not mean the repository contains a complete formal or cocotb flow.

**VI:** Artifact ghi nhận Verilator 5.041, Yosys 0.58/0.58+35, VCS và Icarus 13.0. Đây là phiên bản đã xuất hiện trong môi trường chạy, không phải compatibility matrix đã kiểm thử. sourceme.sh còn nạp toolchain và liệt kê công cụ từ OSS CAD Suite; cần điều chỉnh theo IP đích. Việc setup có SymbiYosys hoặc cocotb không đồng nghĩa repository có flow formal hoặc cocotb hoàn chỉnh.

## Usage | Cách sử dụng

### 1. Prepare the environment | Chuẩn bị môi trường

~~~bash
git clone https://github.com/nguyenquanicd/VLSIT_RTL_Generator_AI_Flow.git VLSIT_RTL_Generator_AI_Model
cd VLSIT_RTL_Generator_AI_Model
~~~

**EN:** Review and adapt sourceme.sh before sourcing it. The script assumes /etc/profile.d/modules.sh, configured EDA/toolchain modules, and a PDK under /tools/PDK. It does not install tools and does not load VCS in the current version.

**VI:** Kiểm tra và điều chỉnh sourceme.sh trước khi source. Script giả định có /etc/profile.d/modules.sh, các module EDA/toolchain và PDK dưới /tools/PDK. Script không cài công cụ và phiên bản hiện tại không nạp VCS.

~~~bash
source sourceme.sh
~~~

**EN:** On Windows, use a Linux environment such as WSL or an EDA server, then adapt paths and tool setup. The shell scripts are not designed for direct PowerShell execution.

**VI:** Trên Windows, dùng môi trường Linux như WSL hoặc máy chủ EDA, sau đó điều chỉnh đường dẫn và cách nạp công cụ. Shell script không được thiết kế để chạy trực tiếp bằng PowerShell.

### 2. Prepare a project and specification | Chuẩn bị project và spec

1. **EN:** Work on a separate branch or copy to preserve reference snapshots.  
   **VI:** Làm việc trên branch hoặc bản sao riêng để giữ nguyên snapshot tham khảo.
2. **EN:** Put the design specification at spec/<ip_name>_spec.md. Define interfaces, parameters, reset, functionality, timing, and error behavior.  
   **VI:** Đặt đặc tả tại spec/<ip_name>_spec.md. Mô tả interface, parameter, reset, chức năng, timing và error behavior.
3. **EN:** Provide IP-specific mappings, constraints, module hierarchy, and protocol-standard revisions in the specification and phase inputs. If the reusable command or schema itself needs maintenance, use the Claude `rtl-flow-maintainer` skill.<br>
   **VI:** Cung cấp mapping, constraint, hierarchy module và phiên bản chuẩn giao thức của IP trong đặc tả và input của từng phase. Nếu cần bảo trì command hoặc schema dùng chung, dùng skill Claude `rtl-flow-maintainer`.
4. **EN:** Shared JSON Schemas are in `.claude/skills/rtl-flow-maintainer/schemas/`. Design-run outputs remain in the design's own `schemas/` directory.<br>
   **VI:** JSON Schema dùng chung nằm trong `.claude/skills/rtl-flow-maintainer/schemas/`. Output của mỗi lần chạy vẫn nằm trong thư mục `schemas/` của thiết kế.

**EN:** Some snapshots contain input artifacts with names that overlap Claude command prompts. Check each file's role and source before using it as a baseline.

**VI:** Một số snapshot có artifact đầu vào trùng tên với prompt Claude command. Xác định vai trò và nguồn gốc của file trước khi dùng làm baseline.

### 3. Run in Claude Code | Chạy trong Claude Code

**EN:** Open Claude Code at the project root and enter slash commands in the conversation, not in a shell terminal.

**VI:** Mở Claude Code tại project root và nhập slash command trong hội thoại, không nhập trong terminal shell.

~~~text
/autoflow spec/<ip_name>_spec.md
~~~

**EN:** To draft a specification from an initial description:

**VI:** Để soạn spec từ mô tả ban đầu:

~~~text
/autoflow --describe
~~~

**EN:** Or run phases individually for detailed review:

**VI:** Hoặc chạy từng phase để review chi tiết:

~~~text
/spec_parser spec/<ip_name>_spec.md
/config_ui
/verification_contract
/rtl_generator
/sva_generator
/tb_generator
/verification
/code_coverage
/spec_pdf_generator
~~~

**EN:** For existing RTL, replace `/rtl_generator` in that sequence with `/rtl_style_converter <source-rtl-directory>` and provide the top and a separate output directory. To use full autoflow with existing RTL, enter `/autoflow spec/<ip_name>_spec.md --rtl-source <source-rtl-directory>`. The converter can also run alone without a specification. Run one command at a time and satisfy its gate before the next dependent phase. The verification branch remains independent of RTL until DUT integration. `/code_coverage` is optional after baseline simulation and before Gate 5; return to `/verification` to complete Gate 5 when running it separately. See the [step-by-step guide](guideline.md) for inputs and outputs.

**VI:** Với RTL có sẵn, thay `/rtl_generator` trong thứ tự trên bằng `/rtl_style_converter <source-rtl-directory>` và cung cấp top cùng thư mục output riêng. Để dùng toàn flow với RTL có sẵn, nhập `/autoflow spec/<ip_name>_spec.md --rtl-source <source-rtl-directory>`. Bộ chuyển style cũng có thể chạy độc lập, không cần đặc tả. Chạy từng command và hoàn thành gate trước phase phụ thuộc. Nhánh verification vẫn độc lập với RTL đến khi tích hợp DUT. `/code_coverage` là tùy chọn sau baseline simulation và trước Gate 5; quay lại `/verification` để hoàn thành Gate 5 nếu chạy coverage riêng. Xem [hướng dẫn từng bước](guideline.md) về input và output.

**EN:** Review requirements before Gate 1, the verification contract before Gate 3a, property meaning/vacuity before Gate 3b, the test plan before Gate 4, and execution logs/gaps before Gate 5. Generation commands may create or update files in the working project.

**VI:** Review requirement trước Gate 1, verification contract trước Gate 3a, ý nghĩa/vacuity của property trước Gate 3b, test plan trước Gate 4, và log thực thi/gap trước Gate 5. Lệnh generation có thể tạo hoặc cập nhật file trong project làm việc.

### 4. Run in Codex CLI | Chạy trong Codex CLI

**EN:** Open Codex CLI at the project root and call the matching skill in the conversation. For example:

**VI:** Mở Codex CLI tại project root và gọi skill tương ứng trong hội thoại. Ví dụ:

~~~text
$source-command-autoflow
Use spec/<ip_name>_spec.md
~~~

**EN:** Call an individual phase with its mapped skill. References such as /autoflow or /phase_name inside a skill refer to the source Claude prompt; they are not terminal commands.

**VI:** Gọi phase riêng bằng skill đã ánh xạ. Tham chiếu như /autoflow hoặc /phase_name bên trong skill là prompt Claude nguồn, không phải lệnh terminal.

### 5. Resume an interrupted flow | Tiếp tục flow bị gián đoạn

~~~text
/autoflow spec/<ip_name>_spec.md --from phase3b
/autoflow spec/<ip_name>_spec.md --from phase5
/autoflow spec/<ip_name>_spec.md --from phase6
~~~

**EN:** Resume uses saved artifacts. Before continuing, confirm that the specification, configuration, RTL, and reports use the same baseline. Editing an input artifact can invalidate downstream results.

**VI:** Resume sử dụng artifact đã lưu. Trước khi tiếp tục, xác nhận spec, cấu hình, RTL và report thuộc cùng một baseline. Sửa artifact đầu vào có thể làm mất hiệu lực kết quả phía sau.

## Current limitations | Hạn chế hiện tại

- **Historical examples — EN:** Saved design runs may use older commands or synthesis settings; inspect their source and logs before reuse.<br>
  **VI:** Snapshot thiết kế có thể dùng command hoặc cấu hình synthesis cũ; kiểm tra source và log trước khi tái sử dụng.
- **Schema drift — EN:** Some JSON artifacts omit fields or use formats that differ from the sample schemas; there is no unified automated validation.  
  **VI:** Một số JSON artifact thiếu trường hoặc khác định dạng schema mẫu; chưa có validation tự động thống nhất.
- **Evidence completeness — EN:** Some final logs, mutation wrappers, and working artifacts are not packaged, so snapshots alone may not reproduce every result.  
  **VI:** Một số log cuối, mutation wrapper và artifact làm việc không được đóng gói; chỉ từ snapshot có thể không tái lập được mọi kết quả.
- **Verification scope — EN:** Pass counts, property counts, and gate approval do not prove full requirement coverage. Some test cases report information or check default configuration only.  
  **VI:** Số lượng pass, property hay gate đã duyệt không chứng minh bao phủ đủ requirement. Một số test case chỉ cung cấp thông tin hoặc kiểm tra cấu hình mặc định.
- **Physical implementation — EN:** Synthesis and cell mapping do not establish timing closure. The repository has no complete STA, place-and-route, CDC/RDC, or sign-off flow.  
  **VI:** Synthesis và cell mapping không xác nhận timing closure. Repository chưa có flow STA, place-and-route, CDC/RDC hoặc sign-off hoàn chỉnh.
- **Documentation — EN:** PDFs summarize artifacts; resolve conflicts by checking source files and logs. The Matplotlib PDF script has layout limits, including clipping long table cells.  
  **VI:** PDF tổng hợp artifact; khi có mâu thuẫn, đối chiếu source và log. Script PDF dùng Matplotlib có giới hạn trình bày, gồm khả năng cắt nội dung cell bảng dài.

## Further reading | Đọc thêm

- [Manual workflow / Flow từng bước](guideline.md)
- [Automatic workflow prompt / Prompt autoflow](.claude/commands/autoflow.md)
- [Default RTL coding rules / Quy tắc RTL mặc định](spec_template/VLSIT_RTL_Design_Rule.md)
- [Reusable RTL library / Thư viện RTL dùng lại](common_rtl/README.md)
- [Spec parser authoring rules / Quy tắc biên soạn spec parser](.claude/skills/rtl-flow-maintainer/references/spec-parser-authoring-rules.md)
- [Active Claude Code commands / Claude Code command đang dùng](.claude/commands/)
- [Claude Code maintenance skill / Skill bảo trì Claude Code](.claude/skills/rtl-flow-maintainer/SKILL.md)
- [Codex CLI project skills / Skill Codex CLI](.agents/skills/)
- [JSON Schemas / JSON Schema](.claude/skills/rtl-flow-maintainer/schemas/)
- [Saved design examples / Ví dụ thiết kế](example/)
- [Architecture diagrams / Sơ đồ kiến trúc](agent_structure/)

## License | Giấy phép

**EN:** The analyzed snapshot has no LICENSE file. Confirm use and distribution terms with the repository owner. External EDA tools and PDKs have separate licenses.

**VI:** Snapshot đã rà soát không có file LICENSE. Xác nhận điều kiện sử dụng và phân phối với chủ repository. Công cụ EDA và PDK bên ngoài áp dụng license riêng.

## Reference design examples | Ví dụ thiết kế tham khảo

**EN:** These snapshots show how the flow was applied to two design types. They help explain the saved artifacts and evidence limits. Their metrics describe individual runs and do not guarantee results for other designs.

**VI:** Các snapshot minh họa cách áp dụng flow cho hai loại thiết kế. Chúng giúp giải thích artifact đã lưu và giới hạn bằng chứng. Số liệu phản ánh từng lần chạy, không đảm bảo kết quả cho thiết kế khác.

| Snapshot | Saved artifacts / Artifact đã lưu | Evidence limits / Giới hạn bằng chứng |
|---|---|---|
| RISCV_23_08_2026 | EN: RV32IM processor core; 18 RTL files (17 modules and 1 package); 191 requirements; 181 property records; GF180 synthesis artifacts.<br/>VI: RV32IM processor core; 18 file RTL (17 module và 1 package); 191 requirement; 181 property record; artifact synthesis GF180. | EN: Stops at Gate 3; 0 requirements signed off. The RTM records 83 vacuous properties in the smoke test.<br/>VI: Dừng ở Gate 3; 0 requirement được sign-off. RTM ghi nhận 83 property vacuous trong smoke test. |
| RISCV_24_08_2026 | EN: RV32IM processor core; 35 assertion records; report states 24/24 test cases passed and 8/23 requirements signed off.<br/>VI: RV32IM processor core; 35 assertion record; report ghi 24/24 test case pass và 8/23 requirement sign-off. | EN: The packaged simulation log is an older failed run. The final passing log referenced by the report is absent from the snapshot.<br/>VI: Log simulation được đóng gói là lần chạy cũ bị fail. Log pass cuối mà report tham chiếu không có trong snapshot. |
| DOWNSCALER_03_09_2026 | EN: AXI4-Stream data-width downscaler; 4 RTL modules; default 64-bit to 32-bit; report states 11 test cases passed and 1 N/A, with 12/16 requirements signed off.<br/>VI: AXI4-Stream data-width downscaler; 4 module RTL; mặc định 64-bit xuống 32-bit; report ghi 11 test case pass, 1 N/A và 12/16 requirement sign-off. | EN: Timing has not been checked by STA. Width ratios outside the default configuration need their own regression.<br/>VI: Timing chưa được kiểm tra bằng STA. Tỷ lệ width ngoài cấu hình mặc định cần regression riêng. |

### RV32IM processor core | Lõi xử lý RV32IM

**EN:** The core snapshot shows an IF → ID → EX → MEM → WB pipeline with a register file, hazard/forwarding control, CSR, and trap control. EX contains the ALU, branch unit, and multiply/divide units; MEM uses an LSU. WB writes back to the register file and has no separate WB module. The I-bus and D-bus use a custom valid/ready protocol.

**VI:** Snapshot core thể hiện pipeline IF → ID → EX → MEM → WB cùng register file, hazard/forwarding control, CSR và trap control. EX gồm ALU, branch unit và multiply/divide; MEM dùng LSU. WB ghi dữ liệu về register file, không có module WB riêng. I-bus và D-bus dùng giao thức valid/ready tùy chỉnh.

**EN:** The two RISC-V folders are independent snapshots, not sequential revisions: the 23 Aug snapshot uses spec revision 0.4, while the 24 Aug snapshot uses revision 0.2. Update absolute paths in file lists and compile scripts before running elsewhere. Compiling a testbench alone is not complete verification with SVA and mutation.

**VI:** Hai thư mục RISC-V là snapshot độc lập, không phải các revision nối tiếp: snapshot 23 Aug dùng spec revision 0.4, snapshot 24 Aug dùng revision 0.2. Cập nhật đường dẫn tuyệt đối trong file list và compile script trước khi chạy ở máy khác. Chỉ compile testbench không phải verification đầy đủ có SVA và mutation.

### AXI4-Stream data-width downscaler | Bộ giảm độ rộng dữ liệu AXI4-Stream

**EN:** The downscaler snapshot uses the path S_AXIS → width_split → FIFO → m_axis_if → M_AXIS. It splits beats in LSB-first order, forwards TKEEP per slice, and forwards TLAST on the last slice. It converts AXI4-Stream data width; it does not downscale image resolution.

**VI:** Snapshot downscaler dùng luồng S_AXIS → width_split → FIFO → m_axis_if → M_AXIS. Thiết kế chia beat theo thứ tự LSB-first, truyền TKEEP theo từng slice và truyền TLAST ở slice cuối. Đây là bộ chuyển đổi độ rộng dữ liệu AXI4-Stream, không giảm độ phân giải ảnh.

**EN:** To run the default configuration with Icarus from the repository root:

**VI:** Để chạy cấu hình mặc định bằng Icarus từ repository root:

~~~bash
cd example/DOWNSCALER_03_09_2026
bash src/tb/run_icarus_sim.sh
~~~

**EN:** The script compiles and simulates into sim/, but does not run SVA. A timing test case marked N/A still increments the snapshot testbench's pass counter; inspect each test result instead of relying only on the PASS total.

**VI:** Script compile và simulate vào sim/, nhưng không chạy SVA. Test timing đánh dấu N/A vẫn làm tăng bộ đếm pass trong testbench snapshot; cần xem kết quả từng test thay vì chỉ dựa vào tổng PASS.
