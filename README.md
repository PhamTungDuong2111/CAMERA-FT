# SnapLab ‑ Camera & Filter (iOS & macOS)

Dự án ứng dụng máy ảnh chụp ảnh & quay video đóng dấu Watermark thông minh hiện trường kết hợp hệ thống truy vấn chống giả mạo bằng mã QR (Anti-Counterfeiting Verification) dựa trên ứng dụng mẫu [SnapLab ‑ Camera & Filter (App Store ID: 6751682117)](https://apps.apple.com/us/app/snaplab-camera-filter/id6751682117).

Ứng dụng được viết bằng **SwiftUI & Native Swift**, cấu hình chạy đa nền tảng cho **iOS (iPhone/iPad)** và chạy trực tiếp trên **macOS** (thông qua **Mac Catalyst** và **Designed for iPad** trên Apple Silicon M1/M2/M3/M4 & Intel).

---

## 📸 Các Tính Năng Chính

### 1. Máy ảnh Watermark Thời Gian Thực (HD Camera & Live Viewfinder)
- **Overlay thời gian thực**: Lớp dấu watermark hiển thị trực tiếp trên khung ngắm máy ảnh với đồng hồ tích tắc từng giây, tọa độ GPS cập nhật tức thời khi di chuyển.
- **Tự động điền dữ liệu thông minh**:
  - Thời gian & ngày tháng (định dạng giờ phút giây, ngày tháng năm).
  - Địa chỉ thực tế được giải mã tự động qua `CLGeocoder` (Số nhà, đường, phường/xã, quận/huyện, thành phố).
  - Tọa độ GPS chính xác (dạng DMS `10°46'37"N 106°41'55"E` hoặc số thập phân) và độ cao địa hình (Altitude).
  - Thời tiết & nhiệt độ thời gian thực (°C/°F, độ ẩm, trạng thái mây/nắng).
  - Hướng la bàn điện tử (Compass Bearing / Azimuth: Đông, Tây, Nam, Bắc theo độ).
  - Tên thiết bị ghi hình (iPhone, MacBook, Apple Silicon).
- **Bộ điều khiển máy ảnh chuyên nghiệp**:
  - Chuyển đổi camera trước / sau / FaceTime Camera trên Mac.
  - Điều chỉnh tỷ lệ khung hình: `4:3`, `16:9`, `1:1`, `Full`.
  - Thu phóng kỹ thuật số mượt mà: `0.5x`, `1.0x`, `2.0x`, `5.0x`.
  - Bật/tắt lưới tam phân (Grid lines) và đường cân bằng chân trời (Spirit Level).
  - Chế độ đèn Flash / Đèn trợ sáng (`Auto`, `On`, `Off`).
  - Chụp ảnh với hiệu ứng chớp sáng Shutter Flash & âm thanh màn trập chân thực.
  - Quay video có nhúng watermark chuyển động với đồng hồ đếm thời gian thực.
  - **Chế độ Camera Mô Phỏng HD (Synthetic Camera)**: Tự động kích hoạt khi chạy trên máy Mac chưa kết nối webcam hoặc trên Xcode Simulator, giúp kiểm tra 100% quy trình chụp ảnh và đóng dấu mà không lo lỗi phần cứng.

### 2. Thư Viện Mẫu Dấu Thông Minh (Intelligent Templates)
Cung cấp sẵn hệ thống mẫu thiết kế chuyên dụng cho từng nghiệp vụ:
- 🏗️ **Công trình & Xây dựng (Engineering)**: Tiêu chuẩn nghiệm thu cốp pha, đổ bê tông cốt thép, tên dự án, nhà thầu, tư vấn giám sát, cao độ móng dầm sàn.
- 🕒 **Chấm công & Điểm danh (Attendance)**: Check-in làm việc hiện trường, mã nhân viên, ban chỉ huy, xác thực vị trí văn phòng.
- 🛡️ **Tuần tra & An toàn (Patrol & Inspection)**: Kiểm tra PCCC, an toàn lao động, tuần tra kho bãi, áp suất bình khí, tình trạng niêm phong.
- ✈️ **Du lịch & Đời sống (Travel & Lifestyle)**: Ghi lại hành trình du lịch với phong cách tối giản thanh lịch, nhiệt độ vùng miền và kinh độ vĩ độ.
- ⚡ **Tối giản (Minimal)**: Chỉ hiển thị thời gian, GPS và tem xác thực số.
- 🎨 **Tùy biến không giới hạn (Customizer)**:
  - Thay đổi vị trí: 4 góc màn hình hoặc chính giữa cạnh dưới.
  - Thay đổi kiểu khung: Kính mờ cao cấp (`Glassmorphism`), Hộp đen hiện đại (`Dark Card`), Tem viền kỹ thuật (`Bordered Stamp`), Chữ viền bóng (`Minimal`).
  - Tông màu chủ đạo: Cam công trình (`Safety Orange`), Xanh kỹ thuật (`Blueprint Blue`), Xanh lá an toàn (`Emerald Green`), Vàng cảnh báo (`Golden Yellow`), Đen mờ (`Sleek Dark`), Trắng (`Crisp White`).
  - Thanh trượt điều chỉnh độ mờ (`Opacity`) từ 30% đến 100% và kích thước (`Scale`) từ 0.7x đến 1.3x.

### 3. Hệ Thống Truy Vấn Chống Giả Mạo Độc Quyền (Authoritative Anti-Counterfeiting Query)
- **Tính toán mã băm SHA-256**: Khi bức ảnh được chụp, hệ thống trích xuất dữ liệu điểm ảnh thô từ cảm biến và tính toán mã băm mật mã học SHA-256 kết hợp chữ ký số và tọa độ gốc.
- **Tạo mã QR xác thực**: Tự động nhúng mã QR chứa token định danh độc nhất vào góc watermark.
- **Trung tâm đối soát & kiểm tra**:
  - Cho phép quét mã QR trên ảnh hoặc tải ảnh từ máy lên để kiểm tra.
  - Thuật toán so khớp mã băm SHA-256 để phát hiện ảnh có bị chỉnh sửa bằng Photoshop hay không.
  - Cấp **Chứng thư số xác thực (Verification Certificate)** hiển thị trạng thái `ĐÃ XÁC THỰC CHÍNH CHỦ` (màu xanh lá) hoặc `CẢNH BÁO: DỮ LIỆU ĐÃ BỊ CHỈNH SỬA` (màu đỏ) kèm thông tin thời gian chụp gốc, vị trí GPS và thiết bị ghi nhận.

### 4. Đóng Dấu Cho Ảnh Có Sẵn Từ Album / Máy
- Chọn bất kỳ bức ảnh nào từ Thư viện ảnh hoặc thư mục máy tính.
- Áp dụng các mẫu watermark SnapLab, tự do tinh chỉnh nội dung và lưu lại với độ phân giải HD sắc nét.

### 5. Quản Lý Thư Viện SnapLab & Xuất Tệp
- Bộ sưu tập lưu trữ riêng cho các tác phẩm chụp từ SnapLab.
- Lọc nhanh theo Ảnh hoặc Video.
- Trình xem ảnh toàn màn hình với thanh thông tin metadata đầy đủ.
- Tích hợp Share Sheet của iOS/macOS (AirDrop, Mail, Tin nhắn, Lưu vào Tệp...).

---

## 📂 Cấu Trúc Dự Án

```
CAMERA-FT/
├── SnapLab.xcodeproj/                    # File dự án Xcode mở trên macOS
│   ├── project.pbxproj                  # Cấu hình target iOS & Mac Catalyst
│   └── xcshareddata/xcschemes/
│       └── SnapLab.xcscheme             # Scheme chạy 1-click Cmd + R
├── SnapLab/
│   ├── App/
│   │   ├── SnapLabApp.swift             # Entry point SwiftUI cho iOS & macOS
│   │   ├── ContentView.swift            # View gốc
│   │   └── Info.plist                   # Khai báo quyền Camera, GPS, Micro, Album
│   ├── Models/
│   │   ├── WatermarkTemplate.swift      # Model mẫu dấu, màu sắc, vị trí, preset
│   │   ├── VerificationRecord.swift     # Model chứng thư số & mã băm SHA-256
│   │   └── CapturedMedia.swift          # Model lưu trữ ảnh và video
│   ├── Services/
│   │   ├── CameraManager.swift          # AVFoundation camera, zoom, flash, video
│   │   ├── LocationWeatherManager.swift # CoreLocation GPS, Geocoding, la bàn, thời tiết
│   │   ├── AntiCounterfeitingManager.swift # Cryptographic hash & bộ đối soát chống giả
│   │   ├── WatermarkRenderer.swift      # Render watermark độ phân giải cao lên ảnh
│   │   └── PhotoLibraryManager.swift    # Quản lý lưu trữ album & tệp tin
│   ├── Views/
│   │   ├── Camera/
│   │   │   ├── CameraView.swift         # Màn hình camera chính
│   │   │   ├── CameraPreviewView.swift  # Lớp hiển thị luồng video & mô phỏng
│   │   │   ├── WatermarkOverlayView.swift # Lớp watermark thời gian thực
│   │   │   └── CameraControlsView.swift # Thanh công cụ, nút chụp, zoom, mode
│   │   ├── Templates/
│   │   │   ├── TemplateSelectorView.swift # Khay chọn mẫu ngang phân loại
│   │   │   └── TemplateEditorSheet.swift  # Modal tùy biến chuyên sâu mẫu dấu
│   │   ├── AntiCounterfeit/
│   │   │   └── AntiCounterfeitQueryView.swift # Màn hình truy vấn đối soát chống giả
│   │   ├── Gallery/
│   │   │   ├── GalleryView.swift        # Lưới thư viện ảnh/video
│   │   │   ├── MediaDetailView.swift    # Xem chi tiết ảnh & chia sẻ
│   │   │   └── AlbumWatermarkEditorView.swift # Đóng dấu ảnh có sẵn từ máy
│   │   └── Settings/
│   │       └── SettingsView.swift       # Cài đặt định dạng, tọa độ, bảo mật
│   ├── Utilities/
│   │   ├── Color+Extensions.swift       # Bảng màu chủ đề SnapLab
│   │   └── Image+Extensions.swift       # Tiện ích ảnh, QR code generator
│   └── Assets.xcassets/                 # Biểu tượng và màu sắc ứng dụng
└── README.md
```

---

## 🚀 Hướng Dẫn Mở & Chạy Dự Án Trên macOS

### Yêu cầu hệ thống
- Máy Mac chạy macOS Monterey, Ventura, Sonoma hoặc mới hơn (tương thích cả chip Apple Silicon M1/M2/M3/M4 và Intel).
- Đã cài đặt **Xcode** (từ Mac App Store hoặc developer.apple.com).

### Các bước khởi chạy:

1. **Sao chép thư mục dự án lên máy Mac**:
   Bạn copy toàn bộ thư mục `CAMERA-FT` sang máy Mac (hoặc giải nén nếu chuyển qua USB / AirDrop / Git).

2. **Mở dự án bằng Xcode**:
   Nhấp đúp chuột vào tệp `SnapLab.xcodeproj` hoặc mở Terminal trên macOS và chạy:
   ```bash
   cd /duong-dan-toi/CAMERA-FT
   open SnapLab.xcodeproj
   ```

3. **Chọn Thiết Bị Chạy (Run Destination)**:
   Tại thanh trên cùng của Xcode (cạnh nút Run):
   - Để chạy ứng dụng trực tiếp như một **cửa sổ Mac App**: Chọn **`My Mac (Mac Catalyst)`** hoặc **`My Mac (Designed for iPad)`**.
   - Để chạy trong giả lập điện thoại: Chọn một máy giả lập ví dụ **`iPhone 16 Pro`** hoặc **`iPad Pro`**.
   - Để cắm cáp chạy lên iPhone thật: Cắm iPhone vào máy Mac và chọn thiết bị của bạn.

4. **Bấm Chạy (Run)**:
   - Nhấn tổ hợp phím **`Cmd + R`** (hoặc nhấn nút hình tam giác ▶️ ở góc trên bên trái Xcode).
   - Dự án sẽ được biên dịch và khởi chạy ngay lập tức trên macOS!
   - Khi chạy lần đầu, hãy cấp quyền truy cập **Camera**, **Vị trí (Location)** và **Ảnh (Photos)** khi hệ thống hỏi để ứng dụng tự động điền tọa độ và chụp ảnh thực tế.
