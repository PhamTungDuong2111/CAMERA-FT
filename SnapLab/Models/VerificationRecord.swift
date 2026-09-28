import Foundation
import CoreLocation

// MARK: - Verification Status
public enum VerificationStatus: String, Codable {
    case authentic = "ĐÃ XÁC THỰC CHÍNH CHỦ"
    case tampered = "CẢNH BÁO: DỮ LIỆU BỊ SỬA ĐỔI"
    case untrusted = "KHÔNG TÌM THẤY CHỮ KÝ GỐC"
    
    public var isSuccess: Bool {
        return self == .authentic
    }
}

// MARK: - Verification Record
public struct VerificationRecord: Identifiable, Codable, Equatable {
    public var id: String                  // Unique verification ID (e.g. SL-20260928-8921)
    public var timestamp: Date             // Exact UTC timestamp of shot
    public var formattedDateString: String // Human readable date string
    public var latitude: Double
    public var longitude: Double
    public var altitude: Double
    public var addressString: String
    public var deviceModel: String         // e.g. "iPhone 16 Pro" or "MacBook Pro (Apple Silicon)"
    public var systemVersion: String       // e.g. "iOS 18.0" / "macOS 15.0"
    public var appVersion: String          // e.g. "SnapLab v2.4.0"
    public var projectName: String
    public var inspectorName: String
    public var sha256Checksum: String      // SHA-256 hash of original raw capture buffer
    public var digitalSignature: String    // Encrypted token for anti-counterfeit query
    
    public init(
        id: String = "SL-" + DateFormatter.snapLabIdFormatter.string(from: Date()) + "-" + String(Int.random(in: 1000...9999)),
        timestamp: Date = Date(),
        latitude: Double = 0.0,
        longitude: Double = 0.0,
        altitude: Double = 0.0,
        addressString: String = "",
        deviceModel: String = "Apple Device",
        systemVersion: String = "iOS 18.0",
        appVersion: String = "SnapLab 1.0 (iOS/macOS)",
        projectName: String = "",
        inspectorName: String = "",
        sha256Checksum: String = "",
        digitalSignature: String = ""
    ) {
        self.id = id
        self.timestamp = timestamp
        self.formattedDateString = DateFormatter.fullDateTimeFormatter.string(from: timestamp)
        self.latitude = latitude
        self.longitude = longitude
        self.altitude = altitude
        self.addressString = addressString
        self.deviceModel = deviceModel
        self.systemVersion = systemVersion
        self.appVersion = appVersion
        self.projectName = projectName
        self.inspectorName = inspectorName
        self.sha256Checksum = sha256Checksum
        self.digitalSignature = digitalSignature
    }
    
    // Encodes record into a portable query string for the QR code
    public func toQRCodePayload() -> String {
        return "snaplab://verify?id=\(id)&t=\(Int(timestamp.timeIntervalSince1970))&lat=\(String(format: "%.5f", latitude))&lon=\(String(format: "%.5f", longitude))&hash=\(sha256Checksum.prefix(12))"
    }
}

// MARK: - Date Formatter Helpers
public extension DateFormatter {
    static let snapLabIdFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "yyyyMMdd"
        return f
    }()
    
    static let fullDateTimeFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return f
    }()
    
    static let displayDateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "dd/MM/yyyy"
        return f
    }()
    
    static let displayTimeFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "HH:mm:ss"
        return f
    }()
}
