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
            let preferred = Locale.preferredLanguages.first ?? "vi"
            if preferred.hasPrefix("en") {
                self.currentLanguage = .english
            } else {
                self.currentLanguage = .vietnamese
            }
        }
    }
    
    public func isVietnamese() -> Bool {
        return currentLanguage == .vietnamese
    }
    
    public func setLanguage(_ language: AppLanguage) {
        withAnimation(.easeInOut(duration: 0.25)) {
            self.currentLanguage = language
        }
    }
    
    public func toggleLanguage() {
        setLanguage(currentLanguage == .vietnamese ? .english : .vietnamese)
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
        "back": [.vietnamese: "Quay lại", .english: "Back"],
        "confirm": [.vietnamese: "Xác nhận", .english: "Confirm"],
        
        // Camera Screen
        "photo": [.vietnamese: "ẢNH", .english: "PHOTO"],
        "video": [.vietnamese: "VIDEO", .english: "VIDEO"],
        "templates": [.vietnamese: "Mẫu dấu", .english: "Templates"],
        "verify": [.vietnamese: "Đối soát", .english: "Verify"],
        "settings": [.vietnamese: "Cài đặt", .english: "Settings"],
        "gallery": [.vietnamese: "Thư viện", .english: "Gallery"],
        "flip": [.vietnamese: "Lật", .english: "Flip"],
        "simulatedCamera": [.vietnamese: "CAMERA MÔ PHỎNG HD (Giả lập)", .english: "SIMULATED HD CAMERA (Simulator)"],
        "flashOff": [.vietnamese: "Tắt", .english: "Off"],
        "flashOn": [.vietnamese: "Bật", .english: "On"],
        "flashAuto": [.vietnamese: "Tự động", .english: "Auto"],
        "flashTorch": [.vietnamese: "Đèn pin", .english: "Torch"],
        "filters": [.vietnamese: "Bộ lọc", .english: "Filters"],
        "stickers": [.vietnamese: "Nhãn dán", .english: "Stickers"],
        "noSticker": [.vietnamese: "Không dùng", .english: "None"],
        
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
        "catOffice": [.vietnamese: "Văn phòng", .english: "Office"],
        "catAttendance": [.vietnamese: "Chấm công", .english: "Attendance"],
        "catPatrol": [.vietnamese: "Tuần tra", .english: "Patrol"],
        "catTravel": [.vietnamese: "Du lịch", .english: "Travel"],
        "catMinimal": [.vietnamese: "Tối giản", .english: "Minimal"],
        "catCustom": [.vietnamese: "Tùy chỉnh", .english: "Custom"],
        
        // Template Drawer & Editor
        "templateDrawerTitle": [.vietnamese: "Thư viện mẫu dấu hiện trường", .english: "Field Watermark Templates"],
        "customize": [.vietnamese: "Tùy biến", .english: "Customize"],
        "customizeTemplate": [.vietnamese: "Tùy biến mẫu dấu", .english: "Customize Watermark"],
        "previewSection": [.vietnamese: "Xem trước trực tiếp", .english: "Live Preview"],
        "infoFieldsSection": [.vietnamese: "Thông tin hiển thị", .english: "Information Fields"],
        "titlePlaceholder": [.vietnamese: "Tiêu đề (VD: BIÊN BẢN CÔNG TRÌNH)", .english: "Title (e.g. WORK LOG)"],
        "projectPlaceholder": [.vietnamese: "Tên dự án / Công trình", .english: "Project Name"],
        "itemPlaceholder": [.vietnamese: "Hạng mục / Vị trí thi công", .english: "Work Item / Area"],
        "contractorPlaceholder": [.vietnamese: "Đơn vị tổng thầu / Thi công", .english: "Contractor / Unit"],
        "inspectorPlaceholder": [.vietnamese: "Người giám sát / Kỹ sư", .english: "Inspector / Engineer"],
        "notesPlaceholder": [.vietnamese: "Ghi chú hiện trường", .english: "Field Notes"],
        "togglesSection": [.vietnamese: "Bật / Tắt các trường dữ liệu", .english: "Display Toggles"],
        "showTimeToggle": [.vietnamese: "Hiển thị thời gian thực", .english: "Show Real-Time Clock"],
        "showSecondsToggle": [.vietnamese: "Chi tiết giây (hh:mm:ss)", .english: "Show Seconds"],
        "showLocationToggle": [.vietnamese: "Địa chỉ đường phố (Reverse Geocode)", .english: "Show Street Address"],
        "showCoordinatesToggle": [.vietnamese: "Tọa độ GPS (Vĩ độ / Kinh độ)", .english: "Show GPS Coordinates"],
        "showAltitudeToggle": [.vietnamese: "Độ cao so với mực nước biển", .english: "Show Altitude"],
        "showWeatherToggle": [.vietnamese: "Thời tiết & Nhiệt độ thực tế", .english: "Show Weather & Temp"],
        "showCompassToggle": [.vietnamese: "La bàn & Góc phương vị", .english: "Show Compass Direction"],
        "showDeviceInfoToggle": [.vietnamese: "Thông tin thiết bị & Phiên bản", .english: "Show Device Hardware"],
        "showQRToggle": [.vietnamese: "Mã QR đối soát chống làm giả", .english: "Anti-Counterfeit QR Code"],
        "styleSection": [.vietnamese: "Kiểu dáng & Tùy biến khung", .english: "Badge Style & Colors"],
        "badgeStyle": [.vietnamese: "Kiểu khung dấu", .english: "Badge Style"],
        "colorTheme": [.vietnamese: "Màu sắc chủ đạo", .english: "Color Theme"],
        "position": [.vietnamese: "Vị trí đặt khung", .english: "Badge Position"],
        "opacity": [.vietnamese: "Độ mờ đục", .english: "Opacity"],
        "scale": [.vietnamese: "Kích thước tỷ lệ", .english: "Scale Factor"],
        
        // Anti-Counterfeit Query
        "queryTitle": [.vietnamese: "Tra cứu chống làm giả", .english: "Anti-Counterfeit Query"],
        "querySubtitle": [.vietnamese: "Kiểm tra tính toàn vẹn của hồ sơ hình ảnh qua hàm băm mật mã SHA-256", .english: "Verify photo integrity via SHA-256 cryptographic proof"],
        "enterIdOrLink": [.vietnamese: "Nhập mã số hồ sơ hoặc liên kết xác thực", .english: "Enter record ID or snaplab:// link"],
        "pasteClipboard": [.vietnamese: "Dán", .english: "Paste"],
        "verifyNow": [.vietnamese: "Kiểm tra ngay", .english: "Verify Now"],
        "orPickFromAlbum": [.vietnamese: "Hoặc chọn ảnh từ Thư viện để kiểm tra", .english: "Or pick photo from Library to inspect"],
        "analyzing": [.vietnamese: "Đang phân tích chữ ký số SHA-256...", .english: "Analyzing SHA-256 digital signature..."],
        "authenticTitle": [.vietnamese: "HỒ SƠ GỐC CHÍNH CHỦ", .english: "GENUINE OFFICIAL RECORD"],
        "authenticDesc": [.vietnamese: "Hình ảnh khớp 100% với chữ ký mã hóa tại thời điểm chụp.", .english: "The image matches 100% of the cryptographic hash recorded at capture time."],
        "tamperedTitle": [.vietnamese: "CẢNH BÁO: ẢNH ĐÃ BỊ CHỈNH SỬA / LÀM GIẢ", .english: "WARNING: TAMPERED OR EDITED IMAGE"],
        "tamperedDesc": [.vietnamese: "Chữ ký mật mã không khớp! Hình ảnh có thể đã bị can thiệp qua Photoshop hoặc metadata bị sửa đổi.", .english: "Checksum mismatch! Image might have been modified via editing tools or metadata altered."],
        "untrustedTitle": [.vietnamese: "KHÔNG TÌM THẤY TRONG HỆ THỐNG", .english: "RECORD NOT FOUND"],
        "untrustedDesc": [.vietnamese: "Mã số hồ sơ không tồn tại trong sổ cái xác thực SnapLab.", .english: "The queried ID does not exist in SnapLab authoritative ledger."],
        "certificateDetails": [.vietnamese: "Chi tiết chứng thư số", .english: "Certificate Details"],
        "digitalSignature": [.vietnamese: "Chữ ký số: ", .english: "Digital Signature: "],
        "sha256Checksum": [.vietnamese: "Mã băm SHA-256: ", .english: "SHA-256 Hash: "],
        "deviceHardware": [.vietnamese: "Thiết bị chụp: ", .english: "Capture Device: "],
        "systemOS": [.vietnamese: "Hệ điều hành: ", .english: "OS Platform: "],
        
        // Gallery & Album Editor
        "galleryTitle": [.vietnamese: "Kho ảnh & Video hiện trường", .english: "Field Media Gallery"],
        "stampPhoto": [.vietnamese: "Đóng dấu ảnh", .english: "Stamp Photo"],
        "noMediaYet": [.vietnamese: "Chưa có hình ảnh nào được lưu", .english: "No media captured yet"],
        "albumEditorTitle": [.vietnamese: "Đóng dấu ảnh từ Album", .english: "Stamp Album Photo"],
        "chooseFromLibrary": [.vietnamese: "Chọn ảnh từ Album máy", .english: "Choose Photo from Library"],
        "saveAndExport": [.vietnamese: "Lưu & Xuất ảnh", .english: "Save & Export"],
        "editWatermark": [.vietnamese: "Chỉnh sửa", .english: "Edit"],
        "savedSuccessfully": [.vietnamese: "Đã lưu ảnh thành công vào Thư viện!", .english: "Saved photo to Library successfully!"],
        
        // Settings
        "settingsTitle": [.vietnamese: "Cài đặt SnapLab", .english: "SnapLab Settings"],
        "languageSection": [.vietnamese: "Ngôn ngữ giao diện", .english: "Interface Language"],
        "appLanguage": [.vietnamese: "Ngôn ngữ", .english: "Language"],
        "captureQualitySection": [.vietnamese: "Chất lượng & Định dạng", .english: "Quality & Format"],
        "exportFormat": [.vietnamese: "Định dạng lưu ảnh", .english: "Export Format"],
        "jpegQuality": [.vietnamese: "JPEG (Tương thích cao)", .english: "JPEG (High Compatibility)"],
        "heicQuality": [.vietnamese: "HEIC (Tiết kiệm dung lượng)", .english: "HEIC (Efficient)"],
        "autoSaveToAlbum": [.vietnamese: "Tự động lưu vào Album máy", .english: "Auto-save to Photos Library"],
        "shutterSound": [.vietnamese: "Âm thanh chụp ảnh", .english: "Shutter Sound Effect"],
        "watermarkDataSection": [.vietnamese: "Định dạng đơn vị hiện trường", .english: "Field Unit Preferences"],
        "gpsCoordinateFormat": [.vietnamese: "Định dạng GPS", .english: "GPS Format"],
        "coordDms": [.vietnamese: "Độ/Phút/Giây (DMS)", .english: "Degrees/Min/Sec (DMS)"],
        "coordDecimal": [.vietnamese: "Thập phân (DD.DDDD)", .english: "Decimal (DD.DDDD)"],
        "temperatureUnit": [.vietnamese: "Đơn vị nhiệt độ", .english: "Temperature Unit"],
        "tempCelsius": [.vietnamese: "Độ C (°C)", .english: "Celsius (°C)"],
        "tempFahrenheit": [.vietnamese: "Độ F (°F)", .english: "Fahrenheit (°F)"],
        "digitalLedgerSection": [.vietnamese: "Sổ cái chứng thực chống làm giả", .english: "Authoritative Audit Ledger"],
        "recordedBlocks": [.vietnamese: "Số hồ sơ đã bảo chứng: ", .english: "Protected records count: "],
        "clearLedger": [.vietnamese: "Đặt lại sổ cái chứng thực", .english: "Reset Audit Ledger"],
        "confirmClearLedger": [.vietnamese: "Bạn có chắc muốn xóa toàn bộ lịch sử chứng thực trên máy này?", .english: "Are you sure you want to reset all local verification records?"],
        "aboutSection": [.vietnamese: "Thông tin ứng dụng", .english: "About SnapLab"],
        "version": [.vietnamese: "Phiên bản: 2.4.0 (Build 6751682117)", .english: "Version: 2.4.0 (Build 6751682117)"],
        "devTeam": [.vietnamese: "Được phát triển cho giám sát thi công & nghiệm thu hiện trường", .english: "Engineered for field engineering, QC inspection & law enforcement"]
    ]
}