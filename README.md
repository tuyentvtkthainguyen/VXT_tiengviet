# VXT Tiếng Việt cho AutoCAD

Bộ công cụ sửa lỗi font chữ tiếng Việt trong bản vẽ AutoCAD: chuyển chữ **TCVN3 (ABC)** và **VNI** sang **Unicode**, đổi font lỗi hoặc thiếu sang Arial / Times New Roman, tự sửa chính tả, và có sẵn tab Ribbon để bấm nút.

Tác giả: Vũ Xuân Tuyến (VXT) – Thái Nguyên.

Chương trình chạy hoàn toàn trên máy, không kết nối mạng, không thu thập dữ liệu người dùng.

## Cài đặt nhanh

1. Tải [`release/VXT_TiengViet_Setup.exe`](release/VXT_TiengViet_Setup.exe).
2. Lưu bản vẽ, **đóng hết AutoCAD**.
3. Chạy file Setup, bấm OK.
4. Mở AutoCAD: tab **VXT Tiếng Việt** xuất hiện trên Ribbon.

File Setup chép chương trình vào `Documents\VXT_Tools` và đăng ký vào mọi bản AutoCAD / Profile trên máy (Support File Search Path, Trusted Paths, Startup Suite). Chạy lại nhiều lần không bị trùng; dùng để cập nhật bản mới. File từ điển `VXT_CHINHTA.txt` anh đã sửa sẽ được giữ nguyên.

Windows có thể cảnh báo SmartScreen vì file chưa ký số: bấm *More info* → *Run anyway*.

## Chức năng

| Nút trên Ribbon | Lệnh | Việc làm |
| --- | --- | --- |
| Toàn bộ bản vẽ | `TCVN2UNI_TB` | Chuyển mọi chữ trong bản vẽ đang mở |
| Chọn đối tượng | `TCVN2UNI_CHON` | Chỉ chuyển các đối tượng chọn |
| Cả thư mục | `TCVN2UNI_THUMUC` | Chuyển mọi file DWG trong một thư mục, sao lưu bản gốc vào `_BanGoc_VXT`, ghi nhật ký |
| Kiểm tra chính tả | `TCVNKIEMTRA` | Rà soát, chọn sẵn chữ nghi sai (không sửa) |
| Ép chuyển | `TCVNEP` | Ép theo bảng mã TCVN3 / TCVN3 hoa / VNI |
| Cài đặt | `TCVNCAIDAT` | Font đích, nhận diện lỗi font, chính tả, kiểu đặt dấu |
| Từ điển chính tả | `TCVNTUDIEN` | Mở `VXT_CHINHTA.txt` để thêm cặp `chữ sai|chữ đúng` |
| Hướng dẫn | `TCVNHUONGDAN` | Danh sách lệnh |

- **Đối tượng xử lý:** TEXT, MTEXT (cả font chèn `\f` bên trong), ATTDEF/ATTRIB, DIMENSION (chữ ghi đè, tiền tố/hậu tố, DIMPOST trong Dimension Style), MULTILEADER, TABLE, kể cả trong Block. Layer khoá được tự mở rồi khoá lại; gõ `U` để hoàn tác.
- **Nhận diện lỗi font:** tìm chữ mã TCVN3/VNI kể cả khi kiểu chữ đã bị đổi sang font khác; chữ đã là Unicode không bị đổi lần hai.
- **Font:** kiểu chữ `.VnTime`, `.VnArial`, `VNI-…`, font thiếu trên máy, font SHX chứa tiếng Việt → Arial (hoặc Times New Roman).
- **Tự sửa chính tả sau khi chuyển:** chữ hoa lẫn chữ thường (`CầU` → `CẦU`), dấu sai vị trí (`tìên` → `tiền`), thiếu móc (`mưòi` → `mười`), dấu tổ hợp, từ điển lỗi thường gặp; kiểm tra luật ghép vần và chọn sẵn chữ còn nghi sai.

## Cấu trúc thư mục

```
autocad/   VXT_TCVN2UNI.lsp, VXT_TIENGVIET.cuix (Ribbon), VXT_TIENGVIET.mnl, VXT_CHINHTA.txt
release/   VXT_TiengViet_Setup.exe (bộ cài cho Windows)
setup/     mã nguồn bộ cài (Go, chỉ dùng thư viện chuẩn)
tools/     main.lsp (mã nguồn LISP), gen2.py / spell.py (sinh bảng mã, kiểm thử),
           build_cuix.py + cuix_template/ (tạo menu Ribbon)
build.sh   build lại toàn bộ
```

## Build lại

Cần Python 3 (Pillow) và Go 1.21+:

```sh
./build.sh
```

Kết quả: `autocad/*` và `release/VXT_TiengViet_Setup.exe`.

## Cài thủ công (không dùng Setup)

1. Chép thư mục `autocad/` vào máy, ví dụ `Documents\VXT_Tools`.
2. `OPTIONS` → Files → Support File Search Path → Add thư mục đó.
3. `APPLOAD` → Startup Suite → Contents → Add `VXT_TCVN2UNI.lsp`.
4. `CUILOAD` → Browse → `VXT_TIENGVIET.cuix` → Load.

## Gỡ cài đặt

`CUIUNLOAD` chọn VXT_TIENGVIET; `APPLOAD` → Startup Suite bỏ `VXT_TCVN2UNI.lsp`; xoá thư mục `Documents\VXT_Tools`.

## Giới hạn

- Không sửa chữ trong Xref (mở file Xref và chạy riêng).
- Chữ chứa Field bị sửa sẽ mất liên kết Field.
- Sửa chính tả chỉ theo luật và từ điển, không thay thế kiểm tra như Word; từ nước ngoài có dấu có thể bị báo nhầm.
