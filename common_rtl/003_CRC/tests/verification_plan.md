# CRC Verification Plan / Kế hoạch kiểm chứng CRC

## English

### Golden source

Expected behavior is taken from `crcCalculator/README.md`, not from implementation logic:

- **Common CRC convention:** implicit monic term, MSB-first bit update, polynomial feedback, and zero augmentation for parallel datapaths.
- **Serial CRC module:** one bit per enabled rising edge; idle clears state; first idle edge optionally checks the prior residue.
- **Initial-value module:** upper CRC-width bits seed the state; lower payload bits are processed before CRC-width zero bits.
- **Parallel module:** whole input word, followed by CRC-width zero bits; one-cycle result latency.
- **Chunked module:** most-significant chunk first; completion after `DATA_W/CAL_W` processing clocks.
- **Full module:** per-byte input reflection, shifted initial XOR, augmented CRC, optional full-state reflection, and final XOR; options are captured at acceptance.

The original README has no formal REQ-IDs and defines no standard bus protocol. Assertion names therefore cite the README sections directly. The request/ready interface is custom, so protocol-standard assertion counts are not applicable; the table checks the specified custom control behavior instead.

### Checks and stimulus

The transaction modules use four or five directed vectors plus `N` reproducible randomized vectors, with default `SEED=20261025`, `N=32`. The serial test uses three directed frames and `N` randomized 32-bit frames. Tests check reset, request acceptance, result latency, reference CRC, busy-time input changes, CRC option capture, serial idle clearing and residue error pulse. The helper fails on any incorrect result, any assertion group with zero hits, or fewer than 20 total checks.

`make mutation-test` changes only a copy of `m_crc_parallel.sv`, forcing its output to zero. It expects the parallel self-checking testbench to fail, and passes only when that injected defect is detected. The delivered RTL is not changed.

### Limits

These simulations use the README's stated behavior as the golden contract. They do not prove conformance to a named CRC standard, exhaust all parameters, provide formal proof, or claim silicon timing closure. Only the selected default testbench parameters are simulated.

## Tiếng Việt

### Nguồn golden

Hành vi kỳ vọng lấy từ `crcCalculator/README.md`, không lấy từ logic triển khai:

- **Common CRC convention:** hệ số monic được hiểu ngầm, xử lý bit MSB-first, hồi tiếp polynomial và tự thêm bit 0 cho datapath song song.
- **Serial CRC:** nhận một bit mỗi cạnh lên khi enable; idle xóa trạng thái; cạnh idle đầu tiên có thể kiểm tra residue trước khi xóa.
- **Initial-value:** các bit trên có độ rộng CRC khởi tạo trạng thái; payload phía dưới được xử lý trước các bit 0 bổ sung.
- **Parallel:** xử lý toàn bộ từ đầu vào rồi thêm số bit 0 bằng độ rộng CRC; kết quả sau một chu kỳ.
- **Chunked:** xử lý chunk cao trước; hoàn tất sau `DATA_W/CAL_W` chu kỳ xử lý.
- **Full:** đảo bit theo byte tùy chọn, XOR giá trị khởi tạo đã dịch, CRC có bit 0 bổ sung, đảo toàn trạng thái tùy chọn và XOR cuối; các tùy chọn được chốt khi nhận request.

README gốc không có REQ-ID hình thức và không định nghĩa giao thức bus chuẩn. Tên assertion vì vậy trỏ trực tiếp tới mục README. Giao diện request/ready là giao diện riêng, nên số assertion theo chuẩn giao thức không áp dụng; test kiểm tra hành vi điều khiển riêng đã mô tả.

### Check và stimulus

Các module giao dịch chạy bốn hoặc năm vector có hướng và `N` vector ngẫu nhiên tái lập được; mặc định `SEED=20261025`, `N=32`. Test serial dùng ba frame có hướng và `N` frame ngẫu nhiên 32-bit. Các check bao phủ reset, nhận request, độ trễ, CRC tham chiếu, thay đổi input khi bận, chốt tùy chọn CRC, xóa khi idle và xung báo residue. Helper làm mô phỏng thất bại nếu kết quả sai, nhóm assertion không có hit hoặc tổng số check dưới 20.

`make mutation-test` chỉ sửa bản sao của `m_crc_parallel.sv`, ép output về 0. Testbench parallel phải bắt được lỗi này; target chỉ thành công khi lỗi được phát hiện. RTL được giao không bị sửa.

### Giới hạn

Mô phỏng dùng hành vi trong README làm hợp đồng golden. Kết quả không chứng minh phù hợp với một chuẩn CRC cụ thể, không bao phủ mọi cấu hình parameter, không thay thế formal proof và không chứng minh timing silicon. Chỉ các cấu hình mặc định của testbench được mô phỏng.
