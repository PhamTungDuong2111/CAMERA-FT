import SwiftUI
import CoreGraphics

public enum PhotoSticker: String, CaseIterable, Identifiable, Codable {
    case passedQC = "PASSED_QC"
    case urgentDefect = "URGENT_DEFECT"
    case safetyFirst = "SAFETY_FIRST"
    case architectVerified = "ARCHITECT_VERIFIED"
    
    public var id: String { rawValue }
    
    public var titleVi: String {
        switch self {
        case .passedQC: return "Nghiệm thu ĐẠT"
        case .urgentDefect: return "Khuyết tật khẩn cấp"
        case .safetyFirst: return "An toàn là trên hết"
        case .architectVerified: return "KTS Đã phê duyệt"
        }
    }
    
    public var titleEn: String {
        switch self {
        case .passedQC: return "QC Passed"
        case .urgentDefect: return "Urgent Defect"
        case .safetyFirst: return "Safety First"
        case .architectVerified: return "Architect Verified"
        }
    }
    
    public func displayName(isVi: Bool) -> String {
        return isVi ? titleVi : titleEn
    }
    
    // Primary Badge Color
    public var badgeColor: Color {
        switch self {
        case .passedQC: return Color(red: 0.12, green: 0.45, blue: 0.95)
        case .urgentDefect: return Color(red: 0.95, green: 0.22, blue: 0.22)
        case .safetyFirst: return Color(red: 0.15, green: 0.85, blue: 0.45)
        case .architectVerified: return Color(red: 1.00, green: 0.78, blue: 0.15)
        }
    }
    
    public var uiColor: UIColor {
        switch self {
        case .passedQC: return UIColor(red: 0.12, green: 0.45, blue: 0.95, alpha: 1.0)
        case .urgentDefect: return UIColor(red: 0.95, green: 0.22, blue: 0.22, alpha: 1.0)
        case .safetyFirst: return UIColor(red: 0.15, green: 0.85, blue: 0.45, alpha: 1.0)
        case .architectVerified: return UIColor(red: 1.00, green: 0.78, blue: 0.15, alpha: 1.0)
        }
    }
    
    // MARK: - Draw on CoreGraphics Context (for Photo Rendering)
    public func draw(in context: CGContext, rect: CGRect) {
        let w = rect.width
        let h = rect.height
        let color = uiColor
        
        context.saveGState()
        
        switch self {
        case .passedQC:
            // Circular QC Seal
            context.setFillColor(color.withAlphaComponent(0.20).cgColor)
            context.fillEllipse(in: rect)
            
            context.setStrokeColor(color.cgColor)
            context.setLineWidth(3.0 * (w / 140.0))
            context.strokeEllipse(in: rect.insetBy(dx: 4, dy: 4))
            
            context.setStrokeColor(color.withAlphaComponent(0.6).cgColor)
            context.setLineWidth(1.0 * (w / 140.0))
            context.strokeEllipse(in: rect.insetBy(dx: 8, dy: 8))
            
            drawCenteredText(in: context, text: "★★★", rect: CGRect(x: rect.minX, y: rect.minY + h * 0.18, width: w, height: h * 0.18), font: .boldSystemFont(ofSize: 13 * (w / 140)), color: color)
            drawCenteredText(in: context, text: "NGHIỆM THU\nĐẠT", rect: CGRect(x: rect.minX, y: rect.minY + h * 0.36, width: w, height: h * 0.35), font: .boldSystemFont(ofSize: 13 * (w / 140)), color: .white)
            drawCenteredText(in: context, text: "QUALITY CONTROL\nPASSED", rect: CGRect(x: rect.minX, y: rect.minY + h * 0.72, width: w, height: h * 0.22), font: .systemFont(ofSize: 7.5 * (w / 140), weight: .semibold), color: color)
            
        case .urgentDefect:
            // Red Warning Octagon Seal
            let insetRect = rect.insetBy(dx: 4, dy: 4)
            let path = UIBezierPath(roundedRect: insetRect, cornerRadius: 18 * (w / 140))
            context.setFillColor(color.withAlphaComponent(0.22).cgColor)
            context.addPath(path.cgPath)
            context.fillPath()
            
            context.setStrokeColor(color.cgColor)
            context.setLineWidth(3.5 * (w / 140))
            context.addPath(path.cgPath)
            context.strokePath()
            
            drawCenteredText(in: context, text: "⚠", rect: CGRect(x: rect.minX, y: rect.minY + h * 0.14, width: w, height: h * 0.24), font: .boldSystemFont(ofSize: 22 * (w / 140)), color: color)
            drawCenteredText(in: context, text: "KHUYẾT TẬT", rect: CGRect(x: rect.minX, y: rect.minY + h * 0.40, width: w, height: h * 0.22), font: .boldSystemFont(ofSize: 13 * (w / 140)), color: .white)
            drawCenteredText(in: context, text: "CẦN XỬ LÝ GẤP\nURGENT ACTION", rect: CGRect(x: rect.minX, y: rect.minY + h * 0.65, width: w, height: h * 0.26), font: .systemFont(ofSize: 8 * (w / 140), weight: .bold), color: color)
            
        case .safetyFirst:
            // Green Shield Seal
            let insetRect = rect.insetBy(dx: 6, dy: 6)
            let path = UIBezierPath(roundedRect: insetRect, cornerRadius: 14 * (w / 140))
            context.setFillColor(color.withAlphaComponent(0.20).cgColor)
            context.addPath(path.cgPath)
            context.fillPath()
            
            context.setStrokeColor(color.cgColor)
            context.setLineWidth(3.0 * (w / 140))
            context.addPath(path.cgPath)
            context.strokePath()
            
            drawCenteredText(in: context, text: "✔", rect: CGRect(x: rect.minX, y: rect.minY + h * 0.14, width: w, height: h * 0.24), font: .boldSystemFont(ofSize: 22 * (w / 140)), color: color)
            drawCenteredText(in: context, text: "AN TOÀN", rect: CGRect(x: rect.minX, y: rect.minY + h * 0.40, width: w, height: h * 0.22), font: .boldSystemFont(ofSize: 13 * (w / 140)), color: .white)
            drawCenteredText(in: context, text: "LÀ TRÊN HẾT\nSAFETY FIRST", rect: CGRect(x: rect.minX, y: rect.minY + h * 0.65, width: w, height: h * 0.26), font: .systemFont(ofSize: 8 * (w / 140), weight: .bold), color: color)
            
        case .architectVerified:
            // Gold Seal
            let insetRect = rect.insetBy(dx: 6, dy: 6)
            let path = UIBezierPath(roundedRect: insetRect, cornerRadius: 10 * (w / 140))
            context.setFillColor(color.withAlphaComponent(0.20).cgColor)
            context.addPath(path.cgPath)
            context.fillPath()
            
            context.setStrokeColor(color.cgColor)
            context.setLineWidth(3.0 * (w / 140))
            context.addPath(path.cgPath)
            context.strokePath()
            
            drawCenteredText(in: context, text: "★ KTS ★", rect: CGRect(x: rect.minX, y: rect.minY + h * 0.16, width: w, height: h * 0.20), font: .boldSystemFont(ofSize: 12 * (w / 140)), color: color)
            drawCenteredText(in: context, text: "KIẾN TRÚC SƯ\nPHÊ DUYỆT", rect: CGRect(x: rect.minX, y: rect.minY + h * 0.38, width: w, height: h * 0.32), font: .boldSystemFont(ofSize: 11.5 * (w / 140)), color: .white)
            drawCenteredText(in: context, text: "ARCHITECT VERIFIED", rect: CGRect(x: rect.minX, y: rect.minY + h * 0.72, width: w, height: h * 0.20), font: .systemFont(ofSize: 7.5 * (w / 140), weight: .bold), color: color)
        }
        
        context.restoreGState()
    }
    
    private func drawCenteredText(in context: CGContext, text: String, rect: CGRect, font: UIFont, color: UIColor) {
        let paragraph = NSMutableParagraphStyle()
        paragraph.alignment = .center
        let attrs: [NSAttributedString.Key: Any] = [
            .font: font,
            .foregroundColor: color,
            .paragraphStyle: paragraph
        ]
        (text as NSString).draw(in: rect, withAttributes: attrs)
    }
}

// MARK: - SwiftUI Preview Badge Component
public struct StickerBadgeView: View {
    public let sticker: PhotoSticker
    public var size: CGFloat = 100
    
    public init(sticker: PhotoSticker, size: CGFloat = 100) {
        self.sticker = sticker
        self.size = size
    }
    
    public var body: some View {
        ZStack {
            // Background & Border
            Circle()
                .fill(sticker.badgeColor.opacity(0.25))
            Circle()
                .stroke(sticker.badgeColor, lineWidth: 2.5)
                .padding(2)
            Circle()
                .stroke(sticker.badgeColor.opacity(0.4), lineWidth: 1)
                .padding(6)
            
            VStack(spacing: 2) {
                switch sticker {
                case .passedQC:
                    Text("★★★")
                        .font(.system(size: size * 0.10, weight: .bold))
                        .foregroundColor(sticker.badgeColor)
                    Text("NGHIỆM THU\nĐẠT")
                        .font(.system(size: size * 0.12, weight: .black))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                    Text("QUALITY CONTROL\nPASSED")
                        .font(.system(size: size * 0.07, weight: .bold))
                        .foregroundColor(sticker.badgeColor)
                        .multilineTextAlignment(.center)
                    
                case .urgentDefect:
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.system(size: size * 0.20))
                        .foregroundColor(sticker.badgeColor)
                    Text("KHUYẾT TẬT")
                        .font(.system(size: size * 0.12, weight: .black))
                        .foregroundColor(.white)
                    Text("CẦN XỬ LÝ GẤP")
                        .font(.system(size: size * 0.075, weight: .bold))
                        .foregroundColor(sticker.badgeColor)
                    
                case .safetyFirst:
                    Image(systemName: "checkmark.shield.fill")
                        .font(.system(size: size * 0.22))
                        .foregroundColor(sticker.badgeColor)
                    Text("AN TOÀN")
                        .font(.system(size: size * 0.12, weight: .black))
                        .foregroundColor(.white)
                    Text("LÀ TRÊN HẾT")
                        .font(.system(size: size * 0.075, weight: .bold))
                        .foregroundColor(sticker.badgeColor)
                    
                case .architectVerified:
                    Text("★ KTS ★")
                        .font(.system(size: size * 0.10, weight: .bold))
                        .foregroundColor(sticker.badgeColor)
                    Text("KIẾN TRÚC SƯ\nPHÊ DUYỆT")
                        .font(.system(size: size * 0.105, weight: .black))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                    Text("ARCHITECT VERIFIED")
                        .font(.system(size: size * 0.065, weight: .bold))
                        .foregroundColor(sticker.badgeColor)
                }
            }
            .padding(8)
        }
        .frame(width: size, height: size)
        .shadow(color: Color.black.opacity(0.5), radius: 6, x: 0, y: 3)
    }
}