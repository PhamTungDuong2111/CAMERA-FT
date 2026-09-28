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
}

// MARK: - Watermark Position
public enum WatermarkPosition: String, CaseIterable, Codable, Identifiable {
    case bottomLeft = "Góc dưới trái"
    case bottomRight = "Góc dưới phải"
    case topLeft = "Góc trên trái"
    case topRight = "Góc trên phải"
    case centerBottom = "Giữa cạnh dưới"
    
    public var id: String { rawValue }
    
    public var alignment: Alignment {
        switch self {
        case .bottomLeft: return .bottomLeading
        case .bottomRight: return .bottomTrailing
        case .topLeft: return .topLeading
        case .topRight: return .topTrailing
        case .centerBottom: return .bottom
        }
    }
}

// MARK: - Watermark Theme Color
public enum WatermarkColorTheme: String, CaseIterable, Codable, Identifiable {
    case safetyOrange = "Cam công trình"
    case blueprintBlue = "Xanh kỹ thuật"
    case emeraldGreen = "Xanh lá an toàn"
    case goldenYellow = "Vàng cảnh báo"
    case sleekDark = "Đen mờ hiện đại"
    case crispWhite = "Trắng tinh khiết"
    
    public var id: String { rawValue }
    
    public var primaryColor: Color {
        switch self {
        case .safetyOrange: return Color(red: 1.0, green: 0.45, blue: 0.0)
        case .blueprintBlue: return Color(red: 0.08, green: 0.48, blue: 0.98)
        case .emeraldGreen: return Color(red: 0.12, green: 0.78, blue: 0.42)
        case .goldenYellow: return Color(red: 1.0, green: 0.75, blue: 0.05)
        case .sleekDark: return Color(red: 0.15, green: 0.15, blue: 0.18)
        case .crispWhite: return Color.white
        }
    }
    
    public var accentUiColor: UIColor {
        switch self {
        case .safetyOrange: return UIColor(red: 1.0, green: 0.45, blue: 0.0, alpha: 1.0)
        case .blueprintBlue: return UIColor(red: 0.08, green: 0.48, blue: 0.98, alpha: 1.0)
        case .emeraldGreen: return UIColor(red: 0.12, green: 0.78, blue: 0.42, alpha: 1.0)
        case .goldenYellow: return UIColor(red: 1.0, green: 0.75, blue: 0.05, alpha: 1.0)
        case .sleekDark: return UIColor(red: 0.15, green: 0.15, blue: 0.18, alpha: 1.0)
        case .crispWhite: return UIColor.white
        }
    }
}

// MARK: - Watermark Background Style
public enum WatermarkBadgeStyle: String, CaseIterable, Codable, Identifiable {
    case glassmorphism = "Kính mờ (Glass)"
    case darkCard = "Hộp đen mờ"
    case borderedStamp = "Viền tem công tác"
    case minimalTransparent = "Chữ bóng đổ (Không nền)"
    
    public var id: String { rawValue }
}

// MARK: - Watermark Template Model
public struct WatermarkTemplate: Identifiable, Codable, Equatable {
    public var id: String
    public var name: String
    public var category: WatermarkCategory
    public var badgeStyle: WatermarkBadgeStyle
    public var colorTheme: WatermarkColorTheme
    public var position: WatermarkPosition
    
    // Toggles
    public var showTime: Bool
    public var showSeconds: Bool
    public var showLocation: Bool
    public var showCoordinates: Bool
    public var showAltitude: Bool
    public var showWeather: Bool
    public var showCompass: Bool
    public var showDeviceInfo: Bool
    public var showAntiCounterfeitQR: Bool
    
    // Custom Fields
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
        // 1. Engineering / Construction
        WatermarkTemplate(
            id: "eng_construction_pro",
            name: "Công trình tiêu chuẩn",
            category: .engineering,
            badgeStyle: .glassmorphism,
            colorTheme: .safetyOrange,
            position: .bottomLeft,
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
        
        // 2. Construction Blue Stamp
        WatermarkTemplate(
            id: "eng_blueprint_stamp",
            name: "Tem giám sát kỹ thuật",
            category: .engineering,
            badgeStyle: .borderedStamp,
            colorTheme: .blueprintBlue,
            position: .bottomLeft,
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
        
        // 5. Travel & Lifestyle Check-in
        WatermarkTemplate(
            id: "travel_lifestyle",
            name: "Check-in Du lịch",
            category: .travel,
            badgeStyle: .minimalTransparent,
            colorTheme: .crispWhite,
            position: .bottomRight,
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
        
        // 6. Minimal Clean
        WatermarkTemplate(
            id: "minimal_timestamp",
            name: "Tối giản thời gian & GPS",
            category: .minimal,
            badgeStyle: .darkCard,
            colorTheme: .crispWhite,
            position: .bottomLeft,
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
