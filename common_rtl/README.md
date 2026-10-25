# VLSIT Common RTL

## English

This directory contains reusable ASIC RTL blocks, example cell models, and design collateral. The FIFO and CRC folders contain separate design alternatives; their modules are not combined into one system.

### Directory map

| Directory | Contents |
|---|---|
| [`000_Common`](000_Common/README.md) | Shared wrappers for reset synchronization, tie-offs, and FIFO memory macros; 52 general example cells plus 8 synchronizer-cell models and 1 SRAM model in `rtl_cells`. |
| [`001_AsyncGrayFIFO`](001_AsyncGrayFIFO/AsyncGrayFIFO_Design_Specification.md) | Asynchronous FIFO for unrelated write and read clocks; Gray-pointer CDC, software-reset handshake, thresholds, and optional SRAM macro. |
| [`002_SyncFIFO`](002_SyncFIFO/SyncFIFO_Design_Specification.md) | FIFO for related synchronous clocks; optional pointer retiming and SRAM macro; supports non-power-of-two depths. |
| [`003_AsyncAXI4Bridge`](003_AsyncAXI4Bridge/AsyncAXI4Bridge_Design_Specification.md) | Asynchronous AXI4 bridge specification and integration collateral. |
| [`003_CRC`](003_CRC/rtl/filelist.f) | Five independent CRC implementations with different data rates, latency, and feature sets. See the comparison below. |
| [`004_AsyncAPBBridge`](004_AsyncAPBBridge/AsyncAPBBridge_Design_Specification.md) | Asynchronous APB bridge specification and integration collateral. |
| [`005_AHB2AXI_Bridge`](005_AHB2AXI_Bridge/README.md) | AHB-to-AXI bridge specification, protocol references, and design collateral. |
| [`006_AXI2APB_Bridge`](006_AXI2APB_Bridge/README.md) | AXI4 Subordinate to APB4 Manager bridge specification and synthesizable RTL. |

`rtl/filelist.f` in each design folder is the source list for that design. The CRC modules are alternatives: select the required CRC module as the elaboration top. FIFO filelists also depend on the shared wrappers and cell models noted in their filelist comments.

### Shared RTL and example cells

`000_Common/rtl_lib` contains the reusable functional wrappers:

| Module | Function |
|---|---|
| `m_vlsit_rst_sync` | Active-low reset synchronizer with asynchronous assertion and synchronous de-assertion. The selected synchronizer depth is configurable. |
| `m_vlsit_tie` | Width- and value-configurable tie-high/tie-low output. |
| `m_vlsit_afifo_cell_sync` | One-bit wrapper selecting a synchronizer cell for the asynchronous FIFO; the non-synthesis branch includes a simulation metastability model. |
| `m_vlsit_afifo_ram_macro` | Wrapper around the asynchronous FIFO's one-write/one-read SRAM macro. |
| `m_vlsit_sfifo_ram_macro` | Wrapper around the synchronous FIFO's one-write/one-read SRAM macro. |

`000_Common/rtl_cells` contains **61** synthesizable stand-in models: 52 general logic, sequential, clock, and tie cells; 8 synchronizer cells; and 1 SRAM model. These models support lint, simulation, and generic elaboration. ASIC implementation must map wrappers to the target library cells and memory macros; the example models are not a substitute for those views.

### FIFO architecture comparison

Both FIFO tops provide write/read requests, show-ahead read data, full/empty and threshold flags, overflow/underflow reporting, and a software-reset sequence. Their clock assumptions differ, so choose by clock relationship.

| Design | Clock relationship and structure | Latency | Default storage / rough area estimate | Advantages | Limits |
|---|---|---|---|---|---|
| `001_AsyncGrayFIFO/m_vlsit_afifo_top` | Independent, unrelated write/read clocks. Gray pointers cross through synchronizers; top instantiates write control, read control, and dual-clock storage. | Default pointer synchronizer is 2 stages. A new word becomes visible in the read domain after the write-pointer crossing; read storage has 1 read-clock-cycle latency and show-ahead data. Exact time varies with clock phase. | Default depth 8 × width 32 = **256 storage bits** in the RTL-array branch, plus pointer, synchronizer, reset-FSM, and flag state. **Relative estimate: medium, storage-dominated, with more control state than SyncFIFO.** SRAM macro area is library-dependent. | Supports unrelated clocks and includes a coordinated software reset. | More control and synchronizer state; default depth must be a power of two (minimum 2). Requires proper CDC constraints and library synchronizer/memory mapping for production. |
| `002_SyncFIFO/m_vlsit_sfifo_top` | Related synchronous clocks. Separate write/read control and storage; no asynchronous pointer synchronizer. `PARA_SFIFO_PTR_RETIME` optionally adds a destination-side pointer register. | Read storage latency is 1 read-clock cycle. A write into empty becomes visible after the first later read edge with `PTR_RETIME=0`, or the second with `PTR_RETIME=1`; full release follows the same 1/2-edge choice. | Default depth 8 × width 32 = **256 storage bits** in the RTL-array branch, plus pointer, optional retiming, reset-FSM, and flag state. **Relative estimate: medium, storage-dominated, with less CDC state than AsyncGrayFIFO.** SRAM macro area is library-dependent. | Lower CDC overhead; supports non-power-of-two depths; retiming trades one edge of flag latency for a shorter pointer path. | Do not use as an asynchronous FIFO. Clocks must have a known synchronous relationship. Gap-free streaming is guaranteed only for depth ≥ `4 + 2 × PTR_RETIME`. |

The 256-bit figure is the payload capacity, not total area. With the default RTL-array branch, synthesis may implement storage with registers and read-selection logic. With the macro branch, the memory compiler/library determines the macro area. The detailed specs define the legal parameter ranges, reset behavior, and flag semantics.

### CRC implementation comparison

All five modules implement an MSB-first CRC recurrence, but their interfaces and CRC profiles differ. A CRC standard match also depends on polynomial, initial value, bit order/reflection, final XOR, and exact message bits; module selection alone does not establish standard conformance. The relative area classes below compare the listed defaults only; they combine declared state and recurrence logic and are not library-mapped area.

| Module | Default configuration | Behavior and latency from accepted request | Declared state bits* | Rough area class* | Logic-size proxy | Advantages / trade-offs |
|---|---|---|---:|---|---|
| `m_crc_serial` | Fixed CRC width 4 | Consumes 1 input bit per enabled clock. Disabling `i_ctrl_en` clears the CRC state at the next edge; optional residue check samples an idle edge. | 5 | Extra small | One 4-bit serial recurrence per cycle; smallest CRC datapath. | Lowest logic footprint and continuous bit streaming; fixed width, one bit/cycle, synchronous active-low reset. |
| `m_crc_initial_value` | CRC 8, data 16 | Loads the upper 8 bits as initial CRC, then processes payload plus appended zeros serially. Result after **16 processing clocks**. | 29 | Small | One 8-bit recurrence per cycle plus counter/control. | Supports input-provided initial state with a small recurrence datapath; highest latency among the transaction variants. |
| `m_crc_parallel` | CRC 8, data 16 | Processes the full word combinationally and registers the result **1 clock after acceptance**. No reflection or init/final XOR options. | 33 | Medium | `DATA_W × CRC_W` = **128** unrolled recurrence bit-steps per result. | Short latency; larger combinational path than the serial/chunked variants. |
| `m_crc_parallel_crcw` | CRC 8, data 32, chunk 8 | Processes one chunk per clock; default `32/8 = 4` chunks, so result after **4 processing clocks**. | 51 | Medium | `CAL_W × CRC_W` = **64** recurrence bit-steps per processing cycle; trades cycles for a shorter path. | Middle point between area/timing and latency; requires `CAL_W = CRC_W` and data width divisible by chunk width. |
| `m_crc_parallel_full` | CRC 16, data 32 | One-cycle parallel result; supports input byte reflection, initial XOR, output reflection, and final XOR. Options are captured with the request. | 82 | Large | `DATA_W × CRC_W` = **512** unrolled recurrence bit-steps, plus option/reflection/XOR logic. | Most configurable CRC interface and one-cycle latency; largest default combinational datapath. |

\*Declared state bits are summed from the RTL register declarations at the stated defaults, before synthesis optimization. “Extra small/Small/Medium/Large” is a rough relative class for these default configurations, based on state and recurrence structure. The recurrence-step count indicates structural work in the RTL; it is not a mapped gate count.

All transaction CRC modules accept a request when `i_ctrl_en` and `o_crc_ready` are both high at the sampling edge. A request presented only while busy is ignored; holding `i_ctrl_en` high lets the module accept it when ready returns. `m_crc_serial` is a bit-stream interface rather than a ready/valid transaction interface. The serial reset is synchronous; the other four CRC resets assert asynchronously.

### Area-estimate limits

This repository does not include a target standard-cell Liberty file, memory compiler area, process corner, timing constraints, or a completed technology-mapped synthesis report. Therefore this README does **not** claim µm² or a precise NAND2-equivalent count. The tables give reproducible RTL-level proxies: FIFO payload bits, declared CRC state bits, and CRC recurrence-step counts. For implementation area, synthesize with the target library and the intended macro configuration, then report mapped cell area and memory-macro area separately.

The CRC RTL in `003_CRC` passes the VLSIT rule checker and Verilator lint (five tops, zero lint errors/warnings each). It has not been simulated here; no independent approved CRC specification is present in this folder. The CRC source README remains the behavioral reference for the converted modules.

## Tiếng Việt

Thư mục này chứa các khối RTL ASIC dùng chung, mô hình cell ví dụ và tài liệu thiết kế. Các thư mục FIFO và CRC chứa nhiều phương án RTL độc lập; các module này không ghép thành một system duy nhất.

### Cấu trúc thư mục

| Thư mục | Nội dung |
|---|---|
| [`000_Common`](000_Common/README.md) | Wrapper dùng chung cho reset synchronizer, tie-off và FIFO memory macro; `rtl_cells` có 52 cell logic/sequential/clock/tie, 8 mô hình synchronizer và 1 mô hình SRAM. |
| [`001_AsyncGrayFIFO`](001_AsyncGrayFIFO/AsyncGrayFIFO_Design_Specification.md) | FIFO bất đồng bộ cho write/read clock độc lập; CDC bằng Gray pointer, software-reset handshake, threshold và tùy chọn SRAM macro. |
| [`002_SyncFIFO`](002_SyncFIFO/SyncFIFO_Design_Specification.md) | FIFO cho các clock đồng bộ có quan hệ thời gian; tùy chọn retime pointer và SRAM macro; hỗ trợ depth không phải lũy thừa của 2. |
| [`003_AsyncAXI4Bridge`](003_AsyncAXI4Bridge/AsyncAXI4Bridge_Design_Specification.md) | Đặc tả và tài liệu tích hợp bridge AXI4 bất đồng bộ. |
| [`003_CRC`](003_CRC/rtl/filelist.f) | Năm cách hiện thực CRC độc lập, khác nhau về tốc độ xử lý dữ liệu, latency và tính năng. Xem bảng so sánh bên dưới. |
| [`004_AsyncAPBBridge`](004_AsyncAPBBridge/AsyncAPBBridge_Design_Specification.md) | Đặc tả và tài liệu tích hợp bridge APB bất đồng bộ. |
| [`005_AHB2AXI_Bridge`](005_AHB2AXI_Bridge/README.md) | Đặc tả, tài liệu chuẩn giao thức và tài liệu thiết kế bridge AHB sang AXI. |
| [`006_AXI2APB_Bridge`](006_AXI2APB_Bridge/README.md) | Đặc tả và RTL tổng hợp được cho bridge AXI4 Subordinate sang APB4 Manager. |

`rtl/filelist.f` trong mỗi thư mục thiết kế là danh sách source của thiết kế đó. Các module CRC là phương án thay thế nhau: chọn module CRC cần dùng làm top khi elaborate. Filelist FIFO cũng cần các wrapper và cell model dùng chung được nêu trong comment của filelist.

### RTL dùng chung và mô hình cell

`000_Common/rtl_lib` chứa các functional wrapper dùng lại:

| Module | Chức năng |
|---|---|
| `m_vlsit_rst_sync` | Reset synchronizer active-low, assertion bất đồng bộ và de-assertion đồng bộ. Số tầng synchronizer cấu hình được. |
| `m_vlsit_tie` | Ngõ ra tie-high/tie-low với độ rộng và giá trị cấu hình được. |
| `m_vlsit_afifo_cell_sync` | Wrapper một bit để chọn synchronizer cell cho FIFO bất đồng bộ; nhánh mô phỏng có mô hình metastability. |
| `m_vlsit_afifo_ram_macro` | Wrapper cho SRAM macro một cổng ghi, một cổng đọc của asynchronous FIFO. |
| `m_vlsit_sfifo_ram_macro` | Wrapper cho SRAM macro một cổng ghi, một cổng đọc của synchronous FIFO. |

`000_Common/rtl_cells` có **61** mô hình stand-in có thể tổng hợp: 52 cell logic, tuần tự, clock và tie; 8 synchronizer cell; 1 mô hình SRAM. Các mô hình này phục vụ lint, mô phỏng và elaborate tổng quát. Khi triển khai ASIC, phải ánh xạ wrapper sang cell và memory macro của thư viện đích; mô hình ví dụ không thay thế view của thư viện thật.

### So sánh kiến trúc FIFO

Cả hai FIFO top đều có request ghi/đọc, dữ liệu đọc show-ahead, cờ full/empty và threshold, báo overflow/underflow, cùng trình tự software reset. Điều kiện clock khác nhau nên cần chọn theo quan hệ clock.

| Design | Quan hệ clock và cấu trúc | Latency | Storage mặc định / ước lượng diện tích tương đối | Ưu điểm | Giới hạn |
|---|---|---|---|---|---|
| `001_AsyncGrayFIFO/m_vlsit_afifo_top` | Write/read clock độc lập, không đồng bộ. Gray pointer đi qua synchronizer; top ghép khối điều khiển ghi, đọc và storage hai clock. | Synchronizer pointer mặc định 2 tầng. Word mới xuất hiện ở read domain sau khi write pointer đi qua CDC; storage đọc có latency 1 read-clock-cycle và dữ liệu show-ahead. Thời gian thực tế phụ thuộc pha hai clock. | Mặc định depth 8 × width 32 = **256 bit dữ liệu** ở nhánh RTL array, cộng pointer, synchronizer, reset FSM và flag. **Ước lượng tương đối: trung bình, chủ yếu do storage, thêm nhiều điều khiển hơn SyncFIFO.** Diện tích SRAM macro phụ thuộc thư viện. | Dùng được với clock độc lập và có software-reset phối hợp hai miền. | Nhiều trạng thái điều khiển/synchronizer hơn; depth mặc định phải là lũy thừa của 2 (tối thiểu 2). Cần CDC constraint và ánh xạ synchronizer/memory macro đúng cho sản phẩm. |
| `002_SyncFIFO/m_vlsit_sfifo_top` | Các clock đồng bộ có quan hệ thời gian. Điều khiển ghi/đọc và storage tách riêng; không có asynchronous pointer synchronizer. `PARA_SFIFO_PTR_RETIME` tùy chọn thêm register ở miền nhận pointer. | Storage đọc có latency 1 read-clock-cycle. Word ghi vào FIFO rỗng xuất hiện sau cạnh đọc kế tiếp thứ nhất khi `PTR_RETIME=0`, hoặc thứ hai khi `PTR_RETIME=1`; full giảm theo cùng lựa chọn 1/2 cạnh. | Mặc định depth 8 × width 32 = **256 bit dữ liệu** ở nhánh RTL array, cộng pointer, retiming tùy chọn, reset FSM và flag. **Ước lượng tương đối: trung bình, chủ yếu do storage, ít trạng thái CDC hơn AsyncGrayFIFO.** Diện tích SRAM macro phụ thuộc thư viện. | Ít overhead CDC hơn; hỗ trợ depth không phải lũy thừa của 2; retime đổi thêm một cạnh flag lấy đường pointer ngắn hơn. | Không dùng thay asynchronous FIFO. Hai clock phải có quan hệ đồng bộ đã biết. Chỉ đảm bảo streaming không gián đoạn khi depth ≥ `4 + 2 × PTR_RETIME`. |

Con số 256 bit là dung lượng payload, không phải tổng diện tích. Ở nhánh RTL array mặc định, synthesis có thể ánh xạ storage thành register và logic chọn dữ liệu đọc. Ở nhánh macro, diện tích do memory compiler/thư viện quyết định. Spec chi tiết định nghĩa miền parameter hợp lệ, reset và ý nghĩa các flag.

### So sánh các phương án CRC

Cả năm module dùng recurrence CRC MSB-first, nhưng interface và profile CRC khác nhau. Muốn khớp một chuẩn CRC còn cần polynomial, initial value, bit order/reflection, final XOR và chính xác các bit message; chỉ chọn module không chứng minh tương thích chuẩn.

| Module | Cấu hình mặc định | Chức năng và latency từ lúc nhận request | Số bit state khai báo* | Ước lượng diện tích tương đối* | Proxy độ lớn logic | Ưu điểm / đánh đổi |
|---|---|---|---:|---|---|
| `m_crc_serial` | CRC width cố định 4 | Nhận 1 bit mỗi clock được enable. Khi tắt `i_ctrl_en`, CRC state bị xóa ở cạnh kế tiếp; residue checker tùy chọn lấy mẫu ở cạnh idle. | 5 | Rất nhỏ | Một recurrence serial 4 bit mỗi chu kỳ; datapath CRC nhỏ nhất. | Logic ít nhất, nhận luồng bit liên tục; width cố định, 1 bit/chu kỳ, reset active-low đồng bộ. |
| `m_crc_initial_value` | CRC 8, data 16 | Nạp 8 bit trên làm initial CRC, sau đó xử lý tuần tự payload và bit 0 nối thêm. Kết quả sau **16 processing clock**. | 29 | Nhỏ | Một recurrence 8 bit mỗi chu kỳ, thêm counter/control. | Nhận initial state từ input với datapath nhỏ; latency lớn nhất trong nhóm transaction. |
| `m_crc_parallel` | CRC 8, data 16 | Xử lý toàn bộ word bằng logic tổ hợp và đăng ký kết quả **1 clock sau khi nhận**. Không có tùy chọn reflection hoặc init/final XOR. | 33 | Trung bình | `DATA_W × CRC_W` = **128** bước recurrence bit được unroll cho một kết quả. | Latency thấp; đường tổ hợp lớn hơn phương án serial/chunked. |
| `m_crc_parallel_crcw` | CRC 8, data 32, chunk 8 | Xử lý một chunk mỗi clock; mặc định `32/8 = 4` chunk, kết quả sau **4 processing clock**. | 51 | Trung bình | `CAL_W × CRC_W` = **64** bước recurrence bit mỗi chu kỳ xử lý; đổi thêm chu kỳ lấy đường logic ngắn hơn. | Cân bằng giữa diện tích/timing và latency; cần `CAL_W = CRC_W` và data width chia hết cho chunk width. |
| `m_crc_parallel_full` | CRC 16, data 32 | Kết quả song song sau 1 chu kỳ; hỗ trợ đảo bit từng byte đầu vào, initial XOR, đảo bit đầu ra và final XOR. Các option được chốt khi nhận request. | 82 | Lớn | `DATA_W × CRC_W` = **512** bước recurrence bit unroll, cộng logic option/reflection/XOR. | Interface CRC đầy đủ nhất và latency 1 chu kỳ; datapath tổ hợp mặc định lớn nhất. |

\*Số bit state khai báo được cộng từ các register trong RTL tại cấu hình mặc định nêu trên, trước tối ưu synthesis. “Rất nhỏ/Nhỏ/Trung bình/Lớn” là phân hạng tương đối cho các cấu hình mặc định này, dựa trên state và cấu trúc recurrence. Số bước recurrence biểu thị cấu trúc logic trong RTL, không phải số cổng sau mapping.

Các CRC dạng transaction nhận request khi `i_ctrl_en` và `o_crc_ready` cùng bằng 1 tại cạnh lấy mẫu. Request chỉ xuất hiện lúc module bận sẽ bị bỏ qua; giữ `i_ctrl_en` mức 1 sẽ cho phép nhận khi ready trở lại. `m_crc_serial` là giao diện luồng bit, không phải giao diện transaction ready/valid. Reset của module serial là đồng bộ; bốn module còn lại assertion bất đồng bộ.

### Giới hạn của ước lượng diện tích

Repository không có file Liberty của standard cell đích, diện tích memory compiler, process corner, timing constraint hoặc báo cáo synthesis đã map theo công nghệ. Vì vậy README này **không đưa ra** diện tích µm² hay con số NAND2-equivalent chính xác. Bảng dùng proxy có thể kiểm chứng ở mức RTL: số bit payload FIFO, số bit state CRC khai báo và số bước recurrence CRC. Muốn biết diện tích triển khai, cần synthesis theo thư viện đích và cấu hình macro dự kiến, rồi báo cáo riêng diện tích cell đã map và diện tích memory macro.

CRC RTL trong `003_CRC` đã pass VLSIT rule checker và Verilator lint (5 top, mỗi top 0 lỗi/0 cảnh báo). Chưa chạy mô phỏng tại đây; thư mục chưa có CRC specification độc lập được duyệt. README nguồn CRC vẫn là tài liệu tham chiếu hành vi cho các module đã chuyển đổi.
