import SwiftUI
import CoreGraphics

public enum PhotoSticker: String, CaseIterable, Identifiable, Codable {
    case approved = "approved"
    case passed = "passed"
    case safetyFirst = "safety_first"
    case urgent = "urgent"
    case handover = "handover"
    case vipSeal = "vip_seal"
    
    // Backward compatibility aliases
    public static var passedQC: PhotoSticker { .passed }
    public static var urgentDefect: PhotoSticker { .urgent }
    public static var architectVerified: PhotoSticker { .vipSeal }
    
    public var id: String { rawValue }
    
    public var titleVi: String {
        switch self {
        case .approved: return "ĐÃ DUYỆT"
        case .passed: return "NGHIỆM THU ĐẠT"
        case .safetyFirst: return "SAFETY FIRST"
        case .urgent: return "KHẨN CẤP"
        case .handover: return "BÀN GIAO HỒ SƠ"
        case .vipSeal: return "VIP SEAL"
        }
    }
    
    public var titleEn: String {
        switch self {
        case .approved: return "APPROVED"
        case .passed: return "QC PASSED"
        case .safetyFirst: return "SAFETY FIRST"
        case .urgent: return "URGENT"
        case .handover: return "HANDOVER"
        case .vipSeal: return "VIP SEAL"
        }
    }
    
    public var subtitleVi: String {
        switch self {
        case .approved: return "ĐÃ PHÊ DUYỆT CHÍNH THỨC"
        case .passed: return "CHẤT LƯỢNG ĐẠT CHUẨN"
        case .safetyFirst: return "AN TOÀN LÀ TRÊN HẾT"
        case .urgent: return "CẦN XỬ LÝ GẤP"
        case .handover: return "HỒ SƠ BÀN GIAO"
        case .vipSeal: return "CHỨNG THỰC XUẤT SẮC"
        }
    }
    
    public var subtitleEn: String {
        switch self {
        case .approved: return "OFFICIALLY APPROVED"
        case .passed: return "QUALITY CONTROL PASSED"
        case .safetyFirst: return "PRIORITY SAFETY"
        case .urgent: return "PRIORITY DISPATCH"
        case .handover: return "OFFICIAL HANDOVER"
        case .vipSeal: return "VERIFIED EXCELLENCE"
        }
    }
    
    public func displayName(isVi: Bool) -> String {
        return isVi ? titleVi : titleEn
    }
    
    public func displaySubtitle(isVi: Bool) -> String {
        return isVi ? subtitleVi : subtitleEn
    }
    
    // Primary Badge Color
    public var badgeColor: Color {
        switch self {
        case .approved: return Color(red: 0.00, green: 0.90, blue: 0.46) // #00E676
        case .passed: return Color(red: 0.00, green: 0.40, blue: 1.00) // #0066FF
        case .safetyFirst: return Color(red: 1.00, green: 0.42, blue: 0.00) // #FF6B00
        case .urgent: return Color(red: 1.00, green: 0.09, blue: 0.27) // #FF1744
        case .handover: return Color(red: 0.49, green: 0.30, blue: 1.00) // #7C4DFF
        case .vipSeal: return Color(red: 1.00, green: 0.84, blue: 0.00) // #FFD700
        }
    }
    
    public var uiColor: UIColor {
        switch self {
        case .approved: return UIColor(red: 0.00, green: 0.90, blue: 0.46, alpha: 1.0)
        case .passed: return UIColor(red: 0.00, green: 0.40, blue: 1.00, alpha: 1.0)
        case .safetyFirst: return UIColor(red: 1.00, green: 0.42, blue: 0.00, alpha: 1.0)
        case .urgent: return UIColor(red: 1.00, green: 0.09, blue: 0.27, alpha: 1.0)
        case .handover: return UIColor(red: 0.49, green: 0.30, blue: 1.00, alpha: 1.0)
        case .vipSeal: return UIColor(red: 1.00, green: 0.84, blue: 0.00, alpha: 1.0)
        }
    }
    
    // MARK: - Draw on CoreGraphics Context (for High Res Watermark Rendering)
    public func draw(in context: CGContext, rect: CGRect) {
        let size = min(rect.width, rect.height)
        let cx = rect.midX
        let cy = rect.midY
        let radius = size / 2.0
        let color = uiColor
        let isVi = LocalizationManager.shared.isVietnamese()
        
        context.saveGState()
        
        // 1. Semi-transparent center fill
        context.setFillColor(color.withAlphaComponent(0.22).cgColor)
        context.fillEllipse(in: CGRect(x: cx - radius * 0.92, y: cy - radius * 0.92, width: radius * 1.84, height: radius * 1.84))
        
        // 2. Outer Solid Ring
        context.setStrokeColor(color.cgColor)
        context.setLineWidth(size * 0.04)
        context.strokeEllipse(in: CGRect(x: cx - radius * 0.92, y: cy - radius * 0.92, width: radius * 1.84, height: radius * 1.84))
        
        // 3. Dashed Inset Circle
        let dashLengths: [CGFloat] = [size * 0.04, size * 0.03]
        context.setLineDash(phase: 0, lengths: dashLengths)
        context.setLineWidth(size * 0.018)
        context.strokeEllipse(in: CGRect(x: cx - radius * 0.82, y: cy - radius * 0.82, width: radius * 1.64, height: radius * 1.64))
        context.setLineDash(phase: 0, lengths: []) // reset dash
        
        // 4. Little decorative stars "★ ★ ★"
        drawCenteredText(
            in: context,
            text: "★ ★ ★",
            rect: CGRect(x: cx - radius * 0.75, y: cy - radius * 0.55, width: radius * 1.5, height: size * 0.16),
            font: .boldSystemFont(ofSize: size * 0.11),
            color: color
        )
        
        // 5. Main Title
        drawCenteredText(
            in: context,
            text: displayName(isVi: isVi),
            rect: CGRect(x: cx - radius * 0.78, y: cy - radius * 0.18, width: radius * 1.56, height: size * 0.22),
            font: .boldSystemFont(ofSize: size * 0.14),
            color: .white
        )
        
        // 6. Subtitle
        drawCenteredText(
            in: context,
            text: displaySubtitle(isVi: isVi),
            rect: CGRect(x: cx - radius * 0.78, y: cy + radius * 0.22, width: radius * 1.56, height: size * 0.18),
            font: .systemFont(ofSize: size * 0.075, weight: .bold),
            color: color
        )
        
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
    @ObservedObject var loc = LocalizationManager.shared
    
    public init(sticker: PhotoSticker, size: CGFloat = 100) {
        self.sticker = sticker
        self.size = size
    }
    
    public var body: some View {
        let isVi = loc.isVietnamese()
        ZStack {
            // Background fill
            Circle()
                .fill(sticker.badgeColor.opacity(0.25))
            
            // Outer Ring
            Circle()
                .stroke(sticker.badgeColor, lineWidth: size * 0.04)
                .padding(size * 0.04)
            
            // Dashed Inset Circle
            Circle()
                .stroke(
                    sticker.badgeColor.opacity(0.8),
                    style: StrokeStyle(lineWidth: size * 0.018, dash: [size * 0.04, size * 0.03])
                )
                .padding(size * 0.10)
            
            // Content
            VStack(spacing: size * 0.02) {
                Text("★ ★ ★")
                    .font(.system(size: size * 0.10, weight: .bold))
                    .foregroundColor(sticker.badgeColor)
                
                Text(sticker.displayName(isVi: isVi))
                    .font(.system(size: size * 0.12, weight: .black))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .shadow(color: Color.black.opacity(0.6), radius: 2, x: 0, y: 1)
                
                Text(sticker.displaySubtitle(isVi: isVi))
                    .font(.system(size: size * 0.07, weight: .bold))
                    .foregroundColor(sticker.badgeColor)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
            }
            .padding(.horizontal, size * 0.12)
        }
        .frame(width: size, height: size)
        .shadow(color: Color.black.opacity(0.5), radius: 6, x: 0, y: 3)
    }
}