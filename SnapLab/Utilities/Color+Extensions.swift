import SwiftUI

public extension Color {
    static let snapBackgroundDark = Color(red: 0.08, green: 0.09, blue: 0.11)
    static let snapCardDark = Color(red: 0.13, green: 0.14, blue: 0.17)
    static let snapBorderDark = Color(red: 0.22, green: 0.24, blue: 0.28)
    static let snapAccentOrange = Color(red: 1.0, green: 0.42, blue: 0.0)
    static let snapNeonGreen = Color(red: 0.15, green: 0.85, blue: 0.45)
    static let snapCyberCyan = Color(red: 0.0, green: 0.78, blue: 1.0)
    static let snapGold = Color(red: 1.0, green: 0.78, blue: 0.12)
    static let snapDangerRed = Color(red: 0.95, green: 0.25, blue: 0.25)
    
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
