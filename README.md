# MMU Region Checker & Môi trường Kiểm thử Ngẫu nhiên có Ràng buộc (CRV)

Dự án thiết kế phần cứng bộ kiểm tra phân vùng bộ nhớ (MMU Region Checker) bằng SystemVerilog RTL có thể cấu hình tham số, kết hợp môi trường kiểm thử hướng đối tượng sử dụng kỹ thuật Kiểm thử Ngẫu nhiên có Ràng buộc (Constrained-Random Verification - CRV).

## 📌 Tính năng chính

- **Thiết kế tham số hóa (Parameterized RTL)**: Tự do cấu hình số lượng phân vùng nhớ (`NUM_REGIONS`), tự động tính toán độ rộng bit định danh vùng (`ID_WIDTH = $clog2(NUM_REGIONS)`).
- **Mạch dò trúng phân vùng (Single-Cycle Combinatorial Hit Logic)**: Đánh giá song song các mốc địa chỉ biên trong 1 chu kỳ tổ hợp, trả về cờ `hit` và `hit_region_id` tức thì không trễ chu kỳ.
- **Phát hiện lỗi chồng lấn phần cứng (Hardware Safety Engine)**: Mạch logic tổ hợp tự động phát hiện và cảnh báo cờ lỗi `overlap_fault` nếu có bất kỳ hai phân vùng nhớ nào bị cấu hình đè/chồng lấn lên nhau.
- **Kiểm thử ngẫu nhiên hướng đối tượng (CRV Testbench)**: Áp dụng OOP SystemVerilog để phân bổ ngẫu nhiên các khối nhớ, ép chuẩn căn chỉnh địa chỉ 4-byte (word-aligned) và phát sinh chuỗi giao dịch đọc/ghi ngẫu nhiên (Stimulus Traffic).

## 📁 Cấu trúc thư mục

- `mmu_region_checker.sv`: Mã nguồn RTL phần cứng có thể tổng hợp được (Synthesizable).
- `tb_mem_system.sv`: Môi trường kiểm thử SystemVerilog gồm các class `mem_block`, `mem_system` và bộ phát test vector ngẫu nhiên.

## 🚀 Hướng dẫn chạy mô phỏng

### Chạy bằng Vivado (xsim qua dòng lệnh)

```bash
xvlog -sv mmu_region_checker.sv tb_mem_system.sv
xelab tb -s top_sim
xsim top_sim -R
```
