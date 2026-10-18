import SwiftUI
import CoreLocation

// MARK: - Watermark Category
public enum WatermarkCategory: String, CaseIterable, Codable, Identifiable {
    case engineering = "Công trình"
    case attendance = "Chấm công"
    case patrol = "Tuần tra"
    case travel = "Du lịch"
    case minimal = "Tối giản"
    case custom = "Tùy chỉnh"
    
    public var id: String { rawValue }
    
    public var iconName: String {
        switch self {
        case .engineering: return "hammer.fill"
        case .attendance: return "person.badge.clock.fill"
        case .patrol: return "shield.checkerboard"
        case .travel: return "airplane.departure"
        case .minimal: return "sparkles"
        case .custom: return "slider.horizontal.3"
        }
    }
    
    public func localizedName(in language: AppLanguage) -> String {
        switch language {
        case .vietnamese: return rawValue
        case .english:
            switch self {
            case .engineering: return "Engineering"
            case .attendance: return "Attendance"
            case .patrol: return "Patrol"
            case .travel: return "Travel"
            case .minimal: return "Minimal"
            case .custom: return "Custom"
            }
        }
    }
}

// MARK: - Watermark Position
public enum WatermarkPosition: String, CaseIterable, Codable, Identifiable {
    case bottomLeft = "Góc dưới trái"
    case bottomRight = "Góc dưới phải"
    case topLeft = "Góc trên trái"
    case topRight = "Góc trên phải"
    case centerBottom = "Giữa cạnh dưới"
    
    public var id: String { rawValue }
    
    public func localizedName(in language: AppLanguage) -> String {
        switch language {
        case .vietnamese: return rawValue
        case .english:
            switch self {
            case .bottomLeft: return "Bottom Left"
            case .bottomRight: return "Bottom Right"
            case .topLeft: return "Top Left"
            case .topRight: return "Top Right"
            case .centerBottom: return "Center Bottom"
            }
        }
    }
}

// MARK: - Watermark Badge Style
public enum WatermarkBadgeStyle: String, CaseIterable, Codable, Identifiable {
    case glassmorphism = "Kính mờ (Glass)"
    case darkCard = "Thẻ tối (Dark Card)"
    case borderedStamp = "Viền tem (Stamp)"
    case minimalTransparent = "Tối giản (Minimal)"
    
    public var id: String { rawValue }
    
    public func localizedName(in language: AppLanguage) -> String {
        switch language {
        case .vietnamese: return rawValue
        case .english:
            switch self {
            case .glassmorphism: return "Glassmorphism"
            case .darkCard: return "Dark Card"
            case .borderedStamp: return "Bordered Stamp"
            case .minimalTransparent: return "Minimal Transparent"
            }
        }
    }
}

// MARK: - Watermark Color Theme
public enum WatermarkColorTheme: String, CaseIterable, Codable, Identifiable {
    case safetyOrange = "Cam công trình"
    case goldenYellow = "Vàng kim"
    case emeraldGreen = "Xanh lá ngọc"
    case blueprintBlue = "Xanh bản vẽ"
    case crimsonRed = "Đỏ cảnh báo"
    case crispWhite = "Trắng tinh khôi"
    
    public var id: String { rawValue }
    
    public var primaryColor: Color {
        switch self {
        case .safetyOrange: return Color(red: 1.0, green: 0.42, blue: 0.0)
        case .goldenYellow: return Color(red: 1.0, green: 0.78, blue: 0.12)
        case .emeraldGreen: return Color(red: 0.15, green: 0.85, blue: 0.45)
        case .blueprintBlue: return Color(red: 0.0, green: 0.65, blue: 1.0)
        case .crimsonRed: return Color(red: 0.95, green: 0.25, blue: 0.25)
        case .crispWhite: return Color.white
        }
    }
    
    public var uiColor: UIColor {
        switch self {
        case .safetyOrange: return UIColor(red: 1.0, green: 0.42, blue: 0.0, alpha: 1.0)
        case .goldenYellow: return UIColor(red: 1.0, green: 0.78, blue: 0.12, alpha: 1.0)
        case .emeraldGreen: return UIColor(red: 0.15, green: 0.85, blue: 0.45, alpha: 1.0)
        case .blueprintBlue: return UIColor(red: 0.0, green: 0.65, blue: 1.0, alpha: 1.0)
        case .crimsonRed: return UIColor(red: 0.95, green: 0.25, blue: 0.25, alpha: 1.0)
        case .crispWhite: return UIColor.white
        }
    }
    
    public func localizedName(in language: AppLanguage) -> String {
        switch language {
        case .vietnamese: return rawValue
        case .english:
            switch self {
            case .safetyOrange: return "Safety Orange"
            case .goldenYellow: return "Golden Yellow"
            case .emeraldGreen: return "Emerald Green"
            case .blueprintBlue: return "Blueprint Blue"
            case .crimsonRed: return "Crimson Red"
            case .crispWhite: return "Crisp White"
            }
        }
    }
}

// MARK: - Watermark Template Model
public struct WatermarkTemplate: Identifiable, Codable, Equatable {
    public var id: String
    public var name: String
    public var category: WatermarkCategory
    public var badgeStyle: WatermarkBadgeStyle
    public var colorTheme: WatermarkColorTheme
    public var position: WatermarkPosition
    
    // Active Photo Filter & Sticker
    public var activeFilter: PhotoFilter
    public var activeSticker: PhotoSticker?
    
    // Field Toggles
    public var showTime: Bool
    public var showSeconds: Bool
    public var showLocation: Bool
    public var showCoordinates: Bool
    public var showAltitude: Bool
    public var showWeather: Bool
    public var showCompass: Bool
    public var showDeviceInfo: Bool
    public var showAntiCounterfeitQR: Bool
    
    // Custom Text Fields
    public var titleText: String
    public var projectName: String
    public var workItem: String
    public var contractorName: String
    public var inspectorName: String
    public var customNotes: String
    
    // Adjustments
    public var opacity: Double // 0.3 - 1.0
    public var scale: Double   // 0.7 - 1.4
    
    public init(
        id: String = UUID().uuidString,
        name: String,
        category: WatermarkCategory,
        badgeStyle: WatermarkBadgeStyle = .glassmorphism,
        colorTheme: WatermarkColorTheme = .safetyOrange,
        position: WatermarkPosition = .bottomLeft,
        activeFilter: PhotoFilter = .original,
        activeSticker: PhotoSticker? = nil,
        showTime: Bool = true,
        showSeconds: Bool = true,
        showLocation: Bool = true,
        showCoordinates: Bool = true,
        showAltitude: Bool = true,
        showWeather: Bool = true,
        showCompass: Bool = true,
        showDeviceInfo: Bool = true,
        showAntiCounterfeitQR: Bool = true,
        titleText: String = "",
        projectName: String = "",
        workItem: String = "",
        contractorName: String = "",
        inspectorName: String = "",
        customNotes: String = "",
        opacity: Double = 0.92,
        scale: Double = 1.0
    ) {
        self.id = id
        self.name = name
        self.category = category
        self.badgeStyle = badgeStyle
        self.colorTheme = colorTheme
        self.position = position
        self.activeFilter = activeFilter
        self.activeSticker = activeSticker
        self.showTime = showTime
        self.showSeconds = showSeconds
        self.showLocation = showLocation
        self.showCoordinates = showCoordinates
        self.showAltitude = showAltitude
        self.showWeather = showWeather
        self.showCompass = showCompass
        self.showDeviceInfo = showDeviceInfo
        self.showAntiCounterfeitQR = showAntiCounterfeitQR
        self.titleText = titleText
        self.projectName = projectName
        self.workItem = workItem
        self.contractorName = contractorName
        self.inspectorName = inspectorName
        self.customNotes = customNotes
        self.opacity = opacity
        self.scale = scale
    }
}

// MARK: - Built-in Preset Templates
public extension WatermarkTemplate {
    static let presets: [WatermarkTemplate] = [
        // 1. Engineering / Construction Standard
        WatermarkTemplate(
            id: "eng_construction_pro",
            name: "Công trình tiêu chuẩn",
            category: .engineering,
            badgeStyle: .glassmorphism,
            colorTheme: .safetyOrange,
            position: .bottomLeft,
            activeFilter: .original,
            activeSticker: .passedQC,
            showTime: true,
            showSeconds: true,
            showLocation: true,
            showCoordinates: true,
            showAltitude: true,
            showWeather: true,
            showCompass: true,
            showDeviceInfo: true,
            showAntiCounterfeitQR: true,
            titleText: "TIÊU CHUẨN XÂY DỰNG",
            projectName: "Dự án Khu Đô Thị Nam Sài Gòn",
            workItem: "Nghiệm thu cốp pha sàn tầng 15",
            contractorName: "Tổng thầu Xây dựng Nam Á",
            inspectorName: "Kỹ sư: Nguyễn Văn Hưng",
            customNotes: "Đạt chuẩn an toàn kỹ thuật thi công"
        ),
        
        // 2. Blueprint Stamp
        WatermarkTemplate(
            id: "eng_blueprint_stamp",
            name: "Tem giám sát kỹ thuật",
            category: .engineering,
            badgeStyle: .borderedStamp,
            colorTheme: .blueprintBlue,
            position: .bottomLeft,
            activeFilter: .cinematic,
            activeSticker: .architectVerified,
            showTime: true,
            showSeconds: true,
            showLocation: true,
            showCoordinates: true,
            showAltitude: true,
            showWeather: false,
            showCompass: true,
            showDeviceInfo: false,
            showAntiCounterfeitQR: true,
            titleText: "BIÊN BẢN HIỆN TRƯỜNG",
            projectName: "Cầu Vượt Ngã Tư Thủ Đức",
            workItem: "Đổ bê tông dầm mố M1",
            contractorName: "Công ty Cổ phần Cầu Đường 1",
            inspectorName: "Tư vấn giám sát: Phạm Hoàng",
            customNotes: "Mẫu R-28 đạt mác M350"
        ),
        
        // 3. Work Attendance / Check-in
        WatermarkTemplate(
            id: "att_standard_checkin",
            name: "Chấm công hiện trường",
            category: .attendance,
            badgeStyle: .darkCard,
            colorTheme: .emeraldGreen,
            position: .bottomLeft,
            activeFilter: .original,
            activeSticker: nil,
            showTime: true,
            showSeconds: true,
            showLocation: true,
            showCoordinates: true,
            showAltitude: false,
            showWeather: true,
            showCompass: false,
            showDeviceInfo: true,
            showAntiCounterfeitQR: true,
            titleText: "ĐIỂM DANH LÀM VIỆC",
            projectName: "Ca sáng - Ban Chỉ Huy",
            workItem: "Nhân sự: Lê Thanh Hải",
            contractorName: "Phòng QLDA & Giám sát chất lượng",
            inspectorName: "Mã NV: SNAP-8842",
            customNotes: "Check-in đúng giờ ca 08:00"
        ),
        
        // 4. Field Patrol & Safety Inspection
        WatermarkTemplate(
            id: "patrol_safety_inspect",
            name: "Tuần tra an toàn PCCC",
            category: .patrol,
            badgeStyle: .glassmorphism,
            colorTheme: .goldenYellow,
            position: .bottomLeft,
            activeFilter: .warmSunlight,
            activeSticker: .safetyFirst,
            showTime: true,
            showSeconds: true,
            showLocation: true,
            showCoordinates: true,
            showAltitude: true,
            showWeather: true,
            showCompass: true,
            showDeviceInfo: true,
            showAntiCounterfeitQR: true,
            titleText: "TUẦN TRA AN TOÀN",
            projectName: "Kho cảng Logistic Cát Lái",
            workItem: "Kiểm tra hệ thống chữa cháy tự động",
            contractorName: "Đội phản ứng nhanh PCCC",
            inspectorName: "Đội trưởng: Vũ Mạnh Thắng",
            customNotes: "Áp suất bình chữa cháy bình thường"
        ),
        
        // 5. Defect Report
        WatermarkTemplate(
            id: "eng_defect_report",
            name: "Báo cáo lỗi & Khuyết tật",
            category: .engineering,
            badgeStyle: .borderedStamp,
            colorTheme: .crimsonRed,
            position: .bottomLeft,
            activeFilter: .original,
            activeSticker: .urgentDefect,
            showTime: true,
            showSeconds: true,
            showLocation: true,
            showCoordinates: true,
            showAltitude: true,
            showWeather: true,
            showCompass: true,
            showDeviceInfo: true,
            showAntiCounterfeitQR: true,
            titleText: "BIÊN BẢN SỰ CỐ",
            projectName: "Cao ốc Thương Mại Landmark",
            workItem: "Kiểm định kết cấu vách thang máy",
            contractorName: "Ban Thanh Tra Chất Lượng",
            inspectorName: "Giám sát: Trần Đình Trọng",
            customNotes: "Phát hiện vết rạn nứt bề mặt vữa ngoài"
        ),
        
        // 6. Travel & Lifestyle
        WatermarkTemplate(
            id: "travel_lifestyle",
            name: "Check-in Du lịch",
            category: .travel,
            badgeStyle: .minimalTransparent,
            colorTheme: .crispWhite,
            position: .bottomRight,
            activeFilter: .fleetingYears,
            activeSticker: nil,
            showTime: true,
            showSeconds: false,
            showLocation: true,
            showCoordinates: true,
            showAltitude: true,
            showWeather: true,
            showCompass: false,
            showDeviceInfo: false,
            showAntiCounterfeitQR: false,
            titleText: "TRAVEL MEMORIES",
            projectName: "Khám phá Việt Nam",
            workItem: "Đà Lạt - Thành phố ngàn hoa",
            contractorName: "",
            inspectorName: "",
            customNotes: "Thời tiết se lạnh 19°C tuyệt đẹp"
        ),
        
        // 7. Minimal Clean
        WatermarkTemplate(
            id: "minimal_timestamp",
            name: "Tối giản thời gian & GPS",
            category: .minimal,
            badgeStyle: .darkCard,
            colorTheme: .crispWhite,
            position: .bottomLeft,
            activeFilter: .original,
            activeSticker: nil,
            showTime: true,
            showSeconds: true,
            showLocation: true,
            showCoordinates: true,
            showAltitude: false,
            showWeather: false,
            showCompass: false,
            showDeviceInfo: false,
            showAntiCounterfeitQR: true,
            titleText: "SNAPLAB VERIFIED",
            projectName: "",
            workItem: "",
            contractorName: "",
            inspectorName: "",
            customNotes: ""
        )
    ]
}