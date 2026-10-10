# AI flow diagrams

**VI:** Thư mục chứa sơ đồ AI flow ở định dạng draw.io, HTML và Mermaid bằng tiếng Việt/Anh. `autoflow_mermaid.html` và `autoflow_mermaid_en.html` thể hiện Gate 3a tạo và review verification contract từ specification, cấu hình và chuẩn trước khi tách thành hai nhánh độc lập: RTL và verification. Nhánh verification không đọc RTL đã sinh; bước DUT integration chỉ dùng RTL để kiểm tra tương thích interface. Flow hiện thực thi tuần tự, dù hai nhánh độc lập về dữ liệu.

`VLSI_AI_FLOW.drawio` là sơ đồ có thể chỉnh sửa. Nội dung Gate 3a và ranh giới dữ liệu giữa hai nhánh cũng được ghi chú trong sơ đồ.

**EN:** This directory contains editable draw.io diagrams and Vietnamese/English HTML and Mermaid views. `autoflow_mermaid.html` and `autoflow_mermaid_en.html` show Gate 3a creating and reviewing a verification contract from the specification, configuration, and standards before splitting into independent RTL and verification branches. The verification branch does not read generated RTL; DUT integration uses RTL only for interface compatibility checks. The current flow executes sequentially even though the branches have independent inputs.

`VLSI_AI_FLOW.drawio` is the editable diagram source. It also documents Gate 3a and the data boundary between the branches.
