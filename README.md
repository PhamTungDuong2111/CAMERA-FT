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

### 6. Đa Ngôn Ngữ Song Ngữ (Tiếng Việt 🇻🇳 & English 🇺🇸)
- **Chuyển đổi tức thì 1-chạm**: Nút chuyển đổi nhanh `🇻🇳 VI / 🇺🇸 EN` tích hợp ngay trên thanh công cụ camera và trong mục Cài đặt.
- **Bản địa hóa toàn diện (Comprehensive Localization)**:
  - Tất cả nhãn watermark (Thời gian, Dự án, Hạng mục, Đơn vị, Người thực hiện, Tọa độ, Cao độ, Hướng nhìn...).
  - Mẫu danh mục (Công trình/Engineering, Chấm công/Attendance, Tuần tra/Patrol, Du lịch/Travel...).
  - Chứng thư số đối soát chống giả mạo và toàn bộ thông báo hệ thống.
  - Tự động áp dụng ngôn ngữ khi nung dấu (bake) trực tiếp lên ảnh và video.

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

## 🔄 Bảng Đối Soát Tính Năng Đồng Bộ 100% (Android Kotlin ↔ iOS Swift)

| Tính Năng Nghiệp Vụ | Bản Android (`CAMERA-FT-ADR`) | Bản iOS (`SnapLab`) | Công Nghệ Native iOS |
|---|---|---|---|
| **Ngôn ngữ & Nền tảng** | 100% Kotlin + Jetpack Compose | 100% Native Swift + SwiftUI | Swift 5.0, SwiftUI, Combine |
| **Máy ảnh chụp ảnh HD** | CameraX ImageCapture | AVFoundation AVCapturePhotoOutput | `AVCaptureSession`, `AVCapturePhotoOutput` |
| **Quay Video Watermark** | CameraX VideoCapture | AVFoundation AVCaptureMovieFileOutput | `AVCaptureMovieFileOutput` |
| **Tọa độ GPS & Giải mã địa chỉ** | FusedLocationProviderClient + Geocoder | CoreLocation + CLGeocoder | `CLLocationManager`, `CLGeocoder` |
| **La bàn & Hướng nhìn** | SensorManager (Azimuth) | CoreLocation Heading (`CLHeading`) | `locationManager.startUpdatingHeading()` |
| **Bộ lọc ảnh phong cách & sáng tạo** | 10 bộ lọc (ColorMatrix + Paint) | 10 bộ lọc Core Image tương ứng | `CIFilter` (Sepia, Comic, Noir, NoirBW, etc.) |
| **Hệ thống nhãn dán nghiệp vụ** | 6 nhãn (APPROVED, PASSED, SAFETY, URGENT, HANDOVER, VIP) | 6 nhãn đồng bộ 100% | `CoreGraphics` Canvas + `StickerBadgeView` |
| **Thư viện mẫu dấu hiện trường** | 8 mẫu (Công trình, Văn phòng, Chấm công, Tuần tra, Sự cố, Du lịch, Tối giản) | 8 mẫu đồng bộ 100% | `WatermarkTemplate.presets` |
| **Mã hóa chống giả mạo SHA-256** | MessageDigest SHA-256 Ledger | Apple CryptoKit `SHA256.hash` | `CryptoKit`, `Insecure.MD5` |
| **Quét & đọc mã QR từ ảnh** | ZXing QR Decoder | CoreImage `CIDetector` QR Detector | `CIDetector(ofType: CIDetectorTypeQRCode)` |
| **Đóng dấu ảnh có sẵn từ Album** | ActivityResultContracts.GetContent | PhotosUI `SystemImagePicker` + Sheet | `PHPhotoLibrary`, `PhotosUI` |
| **Deep Link xác thực** | `snaplab://verify?...` | `snaplab://verify?...` (URL Types) | `CFBundleURLTypes`, `.onOpenURL` |
| **Song ngữ tức thì** | Tiếng Việt 🇻🇳 & English 🇺🇸 | Tiếng Việt 🇻🇳 & English 🇺🇸 | `LocalizationManager.shared` |

---

## 🚀 Hướng Dẫn Mở Bằng Xcode & Build Chạy Trên iPhone Thật (Physical Device)

### Yêu cầu chuẩn bị
- **Máy tính Mac**: Chạy macOS Monterey, Ventura, Sonoma hoặc Sequoia (Apple Silicon M1/M2/M3/M4 hoặc chip Intel).
- **Phần mềm Xcode**: Phiên bản Xcode 14, 15, 16 hoặc mới hơn (tải miễn phí từ Mac App Store).
- **iPhone thật**: Chạy iOS 16.0 trở lên kết nối với máy Mac bằng cáp sạc Lightning / USB-C (hoặc qua Wi-Fi).
- **Tài khoản Apple ID**: Bạn chỉ cần Apple ID cá nhân miễn phí (không bắt buộc tài khoản trả phí $99/năm để test trên máy thật).

---

### Các Bước Thực Hiện Chi Tiết:

#### Bước 1: Mở dự án trong Xcode
1. Mở thư mục dự án `CAMERA-FT` trên máy Mac.
2. Nhấp đúp chuột vào tệp `SnapLab.xcodeproj` (hoặc mở Terminal gõ `open SnapLab.xcodeproj`).

#### Bước 2: Bật "Chế độ nhà phát triển" (Developer Mode) trên iPhone thật
> **Lưu ý quan trọng cho iOS 16, 17 và 18:**
1. Trên iPhone của bạn, vào **Cài đặt (Settings)** > **Quyền riêng tư & Bảo mật (Privacy & Security)**.
2. Cuộn xuống dưới cùng, chọn **Chế độ nhà phát triển (Developer Mode)**.
3. Bật công tắc sang **ON** và nhấn **Khởi động lại (Restart)** điện thoại khi được nhắc.
4. Sau khi khởi động lại, mở khóa iPhone và nhấn **Bật (Turn On)** > Nhập mật khẩu mở khóa màn hình.

#### Bước 3: Cấu hình tài khoản ký số (Signing & Team) trong Xcode
1. Trong Xcode, nhấp vào tên dự án **SnapLab** ở cột điều hướng bên trái (dòng màu xanh trên cùng).
2. Chọn target **SnapLab** dưới mục TARGETS.
3. Chuyển sang tab **Signing & Capabilities**.
4. Tích chọn **`Automatically manage signing`**.
5. Tại mục **Team**:
   - Nếu đã đăng nhập Apple ID: Nhấp vào menu thả xuống và chọn tên của bạn (dạng `Tên Bạn (Personal Team)`).
   - Nếu chưa đăng nhập: Nhấp vào **Add an Account...** > Nhập tài khoản Apple ID và mật khẩu của bạn.
6. Tại mục **Bundle Identifier**:
   - Nếu Xcode báo lỗi trùng bundle ID, bạn chỉ cần thêm một vài ký tự vào đuôi (ví dụ: `com.snaplab.camerafilter.mytest`).

#### Bước 4: Chọn iPhone thật làm thiết bị chạy (Run Destination)
1. Cắm cáp kết nối iPhone với máy Mac (trên iPhone chọn **Tin cậy máy tính này / Trust This Computer** nếu được hỏi).
2. Tại thanh công cụ phía trên cùng của Xcode (bên cạnh nút ▶️ Run):
   - Nhấp vào mục chọn thiết bị (thường đang hiển thị Simulator hoặc My Mac).
   - Cuộn lên phần **iOS Devices** và nhấp chọn tên chiếc **iPhone của bạn** (ví dụ: `iPhone của Tùng Dương`).

#### Bước 5: Biên dịch và chạy ứng dụng (Cmd + R)
1. Nhấn tổ hợp phím **`Cmd + R`** (hoặc nhấn nút ▶️ Run ở góc trên bên trái Xcode).
2. Xcode sẽ tự động biên dịch mã nguồn Swift 100% Native, tạo gói ứng dụng và cài đặt trực tiếp lên iPhone của bạn.

#### Bước 6: Tin cậy chứng chỉ nhà phát triển (Lần đầu tiên trên iPhone)
Khi chạy lần đầu, iPhone có thể hiển thị thông báo "Nhà phát triển không tin cậy (Untrusted Developer)":
1. Mở iPhone > Vào **Cài đặt (Settings)** > **Cài đặt chung (General)** > **Quản lý VPN & Thiết bị (VPN & Device Management)**.
2. Dưới mục **Ứng dụng của nhà phát triển (Developer App)**, nhấp vào Apple ID của bạn.
3. Nhấn **Tin cậy (Trust) "[Tên Apple ID]"** > Xác nhận **Tin cậy (Trust)**.
4. Trở về màn hình chính iPhone và nhấp mở ứng dụng **SnapLab**!
5. Cấp quyền **Camera**, **Vị trí (Location)** và **Ảnh (Photos)** để ứng dụng tự động lấy địa chỉ GPS thực tế, thời tiết, la bàn và chụp ảnh đóng dấu chuyên nghiệp.

---

### Chạy Trên Máy Giả Lập Hoặc Trực Tiếp Trên macOS (Mac Catalyst)
- Nếu chưa có sẵn iPhone hoặc cáp nối, bạn có thể:
  - Chọn máy giả lập (ví dụ `iPhone 16 Pro`) trong menu Xcode rồi nhấn `Cmd + R`.
  - Chọn **`My Mac (Mac Catalyst)`** để chạy SnapLab như một cửa sổ phần mềm Mac máy tính độc lập (hỗ trợ cả FaceTime Camera và chế độ Synthetic Camera mô phỏng).

