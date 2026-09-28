import SwiftUI
import Combine

public enum AppLanguage: String, CaseIterable, Identifiable, Codable {
    case vietnamese = "vi"
    case english = "en"
    
    public var id: String { rawValue }
    
    public var displayName: String {
        switch self {
        case .vietnamese: return "Tiếng Việt 🇻🇳"
        case .english: return "English 🇺🇸"
        }
    }
}

public class LocalizationManager: ObservableObject {
    public static let shared = LocalizationManager()
    
    private let languageKey = "snaplab_app_language"
    
    @Published public var currentLanguage: AppLanguage = .vietnamese {
        didSet {
            UserDefaults.standard.set(currentLanguage.rawValue, forKey: languageKey)
        }
    }
    
    init() {
        if let saved = UserDefaults.standard.string(forKey: languageKey),
           let lang = AppLanguage(rawValue: saved) {
            self.currentLanguage = lang
        } else {
            // Default to system language or Vietnamese
            let preferred = Locale.preferredLanguages.first ?? "vi"
            if preferred.hasPrefix("en") {
                self.currentLanguage = .english
            } else {
                self.currentLanguage = .vietnamese
            }
        }
    }
    
    public func setLanguage(_ language: AppLanguage) {
        withAnimation(.easeInOut(duration: 0.25)) {
            self.currentLanguage = language
        }
    }
    
    // MARK: - Localized String Lookup
    public func t(_ key: String) -> String {
        guard let dict = translations[key] else { return key }
        return dict[currentLanguage] ?? dict[.vietnamese] ?? key
    }
    
    // MARK: - Translation Dictionary
    private let translations: [String: [AppLanguage: String]] = [
        // Navigation & Common
        "close": [.vietnamese: "Đóng", .english: "Close"],
        "cancel": [.vietnamese: "Hủy", .english: "Cancel"],
        "apply": [.vietnamese: "Áp dụng", .english: "Apply"],
        "done": [.vietnamese: "Xong", .english: "Done"],
        "save": [.vietnamese: "Lưu", .english: "Save"],
        "delete": [.vietnamese: "Xóa", .english: "Delete"],
        "share": [.vietnamese: "Chia sẻ", .english: "Share"],
        
        // Camera Screen
        "photo": [.vietnamese: "ẢNH", .english: "PHOTO"],
        "video": [.vietnamese: "VIDEO", .english: "VIDEO"],
        "templates": [.vietnamese: "Mẫu dấu", .english: "Templates"],
        "verify": [.vietnamese: "Đối soát", .english: "Verify"],
        "settings": [.vietnamese: "Cài đặt", .english: "Settings"],
        "simulatedCamera": [.vietnamese: "CAMERA MÔ PHỎNG HD (macOS/Simulator)", .english: "SIMULATED HD CAMERA (macOS/Simulator)"],
        "flashOff": [.vietnamese: "Tắt", .english: "Off"],
        "flashOn": [.vietnamese: "Bật", .english: "On"],
        "flashAuto": [.vietnamese: "Tự động", .english: "Auto"],
        
        // Watermark Live Labels
        "timeLabel": [.vietnamese: "Thời gian: ", .english: "Time: "],
        "projectLabel": [.vietnamese: "Dự án: ", .english: "Project: "],
        "workItemLabel": [.vietnamese: "Hạng mục: ", .english: "Work Item: "],
        "contractorLabel": [.vietnamese: "Đơn vị: ", .english: "Contractor: "],
        "inspectorLabel": [.vietnamese: "Người thực hiện: ", .english: "Inspector: "],
        "locationLabel": [.vietnamese: "Địa điểm: ", .english: "Location: "],
        "coordinatesLabel": [.vietnamese: "Tọa độ: ", .english: "Coordinates: "],
        "altitudeLabel": [.vietnamese: "Cao độ: ", .english: "Altitude: "],
        "compassLabel": [.vietnamese: "Hướng: ", .english: "Heading: "],
        "notesLabel": [.vietnamese: "Ghi chú: ", .english: "Notes: "],
        "verifyCodeLabel": [.vietnamese: "Mã xác thực: ", .english: "Verify Code: "],
        "scanToVerify": [.vietnamese: "QUÉT ĐỂ XÁC THỰC", .english: "SCAN TO VERIFY"],
        "scanQuery": [.vietnamese: "QUÉT ĐỐI SOÁT", .english: "SCAN QUERY"],
        "snaplabVerified": [.vietnamese: "Xác thực SnapLab: ", .english: "SnapLab Verified: "],
        
        // Categories
        "all": [.vietnamese: "Tất cả", .english: "All"],
        "catEngineering": [.vietnamese: "Công trình", .english: "Engineering"],
        "catAttendance": [.vietnamese: "Chấm công", .english: "Attendance"],
        "catPatrol": [.vietnamese: "Tuần tra", .english: "Patrol"],
        "catTravel": [.vietnamese: "Du lịch", .english: "Travel"],
        "catMinimal": [.vietnamese: "Tối giản", .english: "Minimal"],
        "catCustom": [.vietnamese: "Tùy chỉnh", .english: "Custom"],
        
        // Positions
        "posBottomLeft": [.vietnamese: "Góc dưới trái", .english: "Bottom Left"],
        "posBottomRight": [.vietnamese: "Góc dưới phải", .english: "Bottom Right"],
        "posTopLeft": [.vietnamese: "Góc trên trái", .english: "Top Left"],
        "posTopRight": [.vietnamese: "Góc trên phải", .english: "Top Right"],
        "posCenterBottom": [.vietnamese: "Giữa cạnh dưới", .english: "Center Bottom"],
        
        // Badge Styles
        "styleGlassmorphism": [.vietnamese: "Kính mờ (Glass)", .english: "Glassmorphism"],
        "styleDarkCard": [.vietnamese: "Hộp đen mờ", .english: "Dark Card"],
        "styleBorderedStamp": [.vietnamese: "Viền tem công tác", .english: "Bordered Stamp"],
        "styleMinimal": [.vietnamese: "Chữ bóng đổ (Không nền)", .english: "Minimal Transparent"],
        
        // Color Themes
        "colorSafetyOrange": [.vietnamese: "Cam công trình", .english: "Safety Orange"],
        "colorBlueprintBlue": [.vietnamese: "Xanh kỹ thuật", .english: "Blueprint Blue"],
        "colorEmeraldGreen": [.vietnamese: "Xanh lá an toàn", .english: "Emerald Green"],
        "colorGoldenYellow": [.vietnamese: "Vàng cảnh báo", .english: "Golden Yellow"],
        "colorSleekDark": [.vietnamese: "Đen mờ hiện đại", .english: "Sleek Dark"],
        "colorCrispWhite": [.vietnamese: "Trắng tinh khiết", .english: "Crisp White"],
        
        // Template Selector & Editor
        "templateDrawerTitle": [.vietnamese: "Mẫu Watermark Thông Minh", .english: "Intelligent Watermark Templates"],
        "customize": [.vietnamese: "Tùy biến", .english: "Customize"],
        "customizerTitle": [.vietnamese: "Tùy Chỉnh Mẫu Dấu", .english: "Customize Template"],
        "previewSection": [.vietnamese: "Xem trước Watermark", .english: "Watermark Preview"],
        "infoFieldsSection": [.vietnamese: "Nội dung thông tin hiện trường", .english: "Field Information Content"],
        "titlePlaceholder": [.vietnamese: "Tiêu đề dấu (vd: TIÊU CHUẨN XÂY DỰNG)", .english: "Title (e.g. CONSTRUCTION STANDARD)"],
        "projectPlaceholder": [.vietnamese: "Tên dự án / Công trình", .english: "Project / Site Name"],
        "itemPlaceholder": [.vietnamese: "Hạng mục công việc", .english: "Work Item / Task"],
        "contractorPlaceholder": [.vietnamese: "Đơn vị thi công / Nhà thầu", .english: "Contractor / Unit"],
        "inspectorPlaceholder": [.vietnamese: "Người thực hiện / Giám sát", .english: "Inspector / Operator"],
        "notesPlaceholder": [.vietnamese: "Ghi chú bổ sung", .english: "Additional Notes"],
        "autoFieldsSection": [.vietnamese: "Trường dữ liệu tự động", .english: "Automatic Metadata Fields"],
        "toggleTime": [.vietnamese: "Hiển thị ngày giờ thực", .english: "Show Real-time Date & Time"],
        "toggleSeconds": [.vietnamese: "Hiển thị đến từng giây", .english: "Show Seconds"],
        "toggleLocation": [.vietnamese: "Hiển thị địa chỉ thực tế", .english: "Show Street Address"],
        "toggleCoords": [.vietnamese: "Hiển thị tọa độ GPS chính xác", .english: "Show GPS Coordinates"],
        "toggleAltitude": [.vietnamese: "Hiển thị cao độ địa hình (Altitude)", .english: "Show Altitude"],
        "toggleWeather": [.vietnamese: "Hiển thị thời tiết & nhiệt độ", .english: "Show Weather & Temperature"],
        "toggleCompass": [.vietnamese: "Hiển thị la bàn & hướng nhìn", .english: "Show Compass Heading"],
        "toggleDeviceInfo": [.vietnamese: "Hiển thị thông tin thiết bị", .english: "Show Device Info"],
        "toggleAntiCounterfeit": [.vietnamese: "Mã QR chống giả mạo (Anti-Counterfeit)", .english: "Anti-Counterfeiting QR Code"],
        "appearanceSection": [.vietnamese: "Giao diện & Vị trí", .english: "Appearance & Position"],
        "positionPicker": [.vietnamese: "Vị trí đặt dấu", .english: "Watermark Position"],
        "badgeStylePicker": [.vietnamese: "Kiểu khung nền", .english: "Badge Frame Style"],
        "colorThemePicker": [.vietnamese: "Tông màu chủ đạo", .english: "Primary Theme Color"],
        "opacitySlider": [.vietnamese: "Độ mờ (Opacity)", .english: "Opacity"],
        "scaleSlider": [.vietnamese: "Kích thước (Scale)", .english: "Scale"],
        
        // Anti-Counterfeiting Query View
        "queryTitle": [.vietnamese: "Truy Vấn Chống Giả Mạo", .english: "Anti-Counterfeit Query"],
        "queryHeaderTitle": [.vietnamese: "Xác Thực Hồ Sơ Hiện Trường", .english: "Field Record Authentication"],
        "queryHeaderDesc": [.vietnamese: "Hệ thống truy vấn chống làm giả ảnh SnapLab Authoritative Verification. Kiểm tra tính toàn vẹn thời gian, GPS và chống chỉnh sửa Photoshop.", .english: "SnapLab Authoritative Verification query system. Validates timestamp integrity, GPS coordinates, and detects Photoshop alterations."],
        "uploadToCheck": [.vietnamese: "Tải ảnh cần kiểm tra", .english: "Upload Photo to Verify"],
        "checkSha256Sub": [.vietnamese: "Kiểm tra mã băm SHA-256", .english: "Inspect SHA-256 Checksum"],
        "scanPhotoQR": [.vietnamese: "Quét mã QR trên ảnh", .english: "Scan Photo QR Code"],
        "decodeSigSub": [.vietnamese: "Giải mã chữ ký gốc", .english: "Decode Digital Signature"],
        "orManualInput": [.vietnamese: "Hoặc nhập Mã Xác Thực SnapLab:", .english: "Or enter SnapLab Verification ID:"],
        "checkBtn": [.vietnamese: "Kiểm tra", .english: "Verify"],
        "analyzing": [.vietnamese: "Đang tính toán mã băm SHA-256 và đối soát chứng thư số...", .english: "Computing SHA-256 hash and verifying digital certificate..."],
        "statusAuthentic": [.vietnamese: "ĐÃ XÁC THỰC CHÍNH CHỦ", .english: "AUTHENTIC & VERIFIED"],
        "statusTampered": [.vietnamese: "CẢNH BÁO: DỮ LIỆU ĐÃ BỊ SỬA ĐỔI", .english: "WARNING: DATA HAS BEEN TAMPERED"],
        "statusUntrusted": [.vietnamese: "KHÔNG TÌM THẤY CHỮ KÝ GỐC", .english: "UNTRUSTED SIGNATURE"],
        "authenticDesc": [.vietnamese: "Hồ sơ gốc không bị chỉnh sửa, tem watermark hợp lệ", .english: "Original record is intact, watermark seal is valid"],
        "tamperedDesc": [.vietnamese: "Ảnh đã bị chỉnh sửa điểm ảnh hoặc sai lệch dữ liệu gốc", .english: "Image pixels have been altered or metadata mismatched"],
        "certId": [.vietnamese: "Mã chứng thư:", .english: "Certificate ID:"],
        "certTime": [.vietnamese: "Thời gian chụp gốc:", .english: "Original Capture Time:"],
        "certLocation": [.vietnamese: "Địa điểm ghi nhận:", .english: "Recorded Location:"],
        "certCoords": [.vietnamese: "Tọa độ GPS:", .english: "GPS Coordinates:"],
        "certAltitude": [.vietnamese: "Cao độ địa hình:", .english: "Terrain Altitude:"],
        "certProject": [.vietnamese: "Dự án / Công trình:", .english: "Project / Site:"],
        "certInspector": [.vietnamese: "Người thực hiện:", .english: "Operator / Inspector:"],
        "certDevice": [.vietnamese: "Thiết bị xác thực:", .english: "Authenticated Device:"],
        "certHash": [.vietnamese: "Mã băm SHA-256:", .english: "SHA-256 Hash:"],
        "certPhotoshopCheck": [.vietnamese: "Kiểm tra Photoshop:", .english: "Photoshop Inspection:"],
        "photoshopPass": [.vietnamese: "PASS - Không phát hiện cắt ghép", .english: "PASS - No tampering detected"],
        
        // Gallery
        "galleryTitle": [.vietnamese: "Thư Viện SnapLab", .english: "SnapLab Gallery"],
        "stampExistingPhoto": [.vietnamese: "Đóng dấu ảnh", .english: "Stamp Photo"],
        "emptyGalleryTitle": [.vietnamese: "Chưa có ảnh hoặc video nào", .english: "No Photos or Videos Yet"],
        "emptyGalleryDesc": [.vietnamese: "Chụp ảnh hoặc quay video gắn watermark từ camera, hoặc chọn ảnh từ thư viện để đóng dấu.", .english: "Capture photos or record videos with watermarks, or select photos from library to stamp."],
        "chooseFromAlbum": [.vietnamese: "Chọn ảnh từ Album để đóng dấu", .english: "Choose Photo from Album to Stamp"],
        "deleteAlertTitle": [.vietnamese: "Xóa tệp tin này?", .english: "Delete this item?"],
        "deleteAlertDesc": [.vietnamese: "Ảnh và hồ sơ đóng dấu sẽ bị xóa vĩnh viễn khỏi thiết bị.", .english: "The photo and watermark record will be permanently deleted."],
        "albumEditorTitle": [.vietnamese: "Đóng Dấu Ảnh Có Sẵn", .english: "Stamp Existing Photo"],
        "albumPickerPromptTitle": [.vietnamese: "Chọn một ảnh từ máy để đóng dấu", .english: "Select a photo from device to stamp"],
        "albumPickerPromptDesc": [.vietnamese: "Hệ thống sẽ giữ nguyên độ phân giải gốc của ảnh, gắn watermark thông minh thời gian, GPS và mã QR chống giả.", .english: "Preserves native image resolution while applying smart timestamp, GPS, and anti-counterfeit QR seal."],
        "openPhotoLibrary": [.vietnamese: "Mở thư viện ảnh", .english: "Open Photo Library"],
        "savePhoto": [.vietnamese: "Lưu ảnh", .english: "Save Photo"],
        
        // Settings Screen
        "settingsNavTitle": [.vietnamese: "Cài Đặt", .english: "Settings"],
        "languageSection": [.vietnamese: "Ngôn ngữ / Language", .english: "Language / Ngôn ngữ"],
        "appLanguage": [.vietnamese: "Ngôn ngữ hiển thị", .english: "Display Language"],
        "captureQualitySection": [.vietnamese: "Chất lượng ảnh & Định dạng", .english: "Image Quality & Format"],
        "exportFormat": [.vietnamese: "Định dạng xuất ảnh", .english: "Export Format"],
        "jpegQuality": [.vietnamese: "JPEG (95% Giữ nguyên chi tiết)", .english: "JPEG (95% High Quality)"],
        "heicQuality": [.vietnamese: "HEIC (Tối ưu dung lượng Apple)", .english: "HEIC (Apple Space Efficient)"],
        "autoSaveToAlbum": [.vietnamese: "Tự động lưu vào Album 'SnapLab'", .english: "Auto-save to 'SnapLab' Album"],
        "shutterSound": [.vietnamese: "Âm thanh chụp ảnh", .english: "Camera Shutter Sound"],
        "watermarkDataSection": [.vietnamese: "Định dạng dữ liệu Watermark", .english: "Watermark Data Format"],
        "gpsCoordinateFormat": [.vietnamese: "Hiển thị Tọa độ GPS", .english: "GPS Coordinates Display"],
        "coordDms": [.vietnamese: "DMS (Ví dụ: 10°46'37\"N 106°41'55\"E)", .english: "DMS (e.g. 10°46'37\"N 106°41'55\"E)"],
        "coordDecimal": [.vietnamese: "Thập phân (Ví dụ: 10.77694, 106.70093)", .english: "Decimal (e.g. 10.77694, 106.70093)"],
        "temperatureUnit": [.vietnamese: "Đơn vị Nhiệt độ", .english: "Temperature Unit"],
        "tempCelsius": [.vietnamese: "Độ C (°C)", .english: "Celsius (°C)"],
        "tempFahrenheit": [.vietnamese: "Độ F (°F)", .english: "Fahrenheit (°F)"],
        "securitySectionTitle": [.vietnamese: "Bảo mật chống làm giả (Anti-Counterfeiting)", .english: "Anti-Counterfeiting Security"],
        "securityTitle": [.vietnamese: "Chữ Ký Số SHA-256 & QR Code", .english: "Digital Signature SHA-256 & QR Code"],
        "securityDetailedDesc": [.vietnamese: "Mỗi bức ảnh được chụp từ SnapLab được gắn mã băm cryptographic SHA-256 từ cảm biến camera gốc cùng tọa độ thời gian thực. Bất kỳ sự can thiệp nào bằng Photoshop hoặc phần mềm chỉnh sửa đều bị phát hiện ngay khi quét đối soát.", .english: "Every photo captured with SnapLab is cryptographically signed with a SHA-256 hash of original sensor pixels, timestamp, and GPS. Any tampering or editing with Photoshop is detected immediately during verification query."],
        "appInfoSection": [.vietnamese: "Thông tin ứng dụng", .english: "About SnapLab"],
        "appNameTitle": [.vietnamese: "Tên ứng dụng", .english: "Application Name"],
        "appVersionTitle": [.vietnamese: "Phiên bản", .english: "Version"],
        "platformTitle": [.vietnamese: "Nền tảng hỗ trợ", .english: "Supported Platforms"],
        "platformDesc": [.vietnamese: "iOS 16+ & macOS Catalyst", .english: "iOS 16+ & macOS Catalyst"],
        "copyrightTitle": [.vietnamese: "Bản quyền", .english: "Copyright"],
        "copyrightDesc": [.vietnamese: "SnapLab Technologies", .english: "SnapLab Technologies"]
    ]
}

// Global localization shortcut
public func L(_ key: String) -> String {
    LocalizationManager.shared.t(key)
}
