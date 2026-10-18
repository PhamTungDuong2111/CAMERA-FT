import UIKit
import CoreGraphics
import CoreLocation

public class WatermarkRenderer {
    public static let shared = WatermarkRenderer()
    
    // MARK: - Main Render Function
    public func renderWatermark(
        on originalImage: UIImage,
        template: WatermarkTemplate,
        verificationRecord: VerificationRecord?,
        timestamp: Date = Date(),
        locationManager: LocationWeatherManager = .shared
    ) -> UIImage {
        // 1. Apply photo filter first
        let filteredImage = template.activeFilter.apply(to: originalImage)
        let fixedImage = ImageUtilities.fixOrientation(for: filteredImage)
        let imageSize = fixedImage.size
        
        let format = UIGraphicsImageRendererFormat()
        format.scale = fixedImage.scale
        format.opaque = true
        
        let renderer = UIGraphicsImageRenderer(size: imageSize, format: format)
        
        return renderer.image { context in
            let cgContext = context.cgContext
            
            // 1. Draw base photo
            fixedImage.draw(in: CGRect(origin: .zero, size: imageSize))
            
            // 2. Prepare Watermark drawing parameters
            let baseDimension = min(imageSize.width, imageSize.height)
            let scaleFactor = (baseDimension / 1080.0) * CGFloat(template.scale)
            
            let loc = LocalizationManager.shared
            
            // Calculate Watermark content items
            var lines: [WatermarkLineItem] = []
            
            // Title Header
            let title = template.titleText.isEmpty ? template.category.localizedName(in: loc.currentLanguage).uppercased() : template.titleText.uppercased()
            
            // Time string
            if template.showTime {
                let timeStr: String
                if template.showSeconds {
                    timeStr = DateFormatter.fullDateTimeFormatter.string(from: timestamp)
                } else {
                    timeStr = DateFormatter.displayDateFormatter.string(from: timestamp) + " " + DateFormatter.displayTimeFormatter.string(from: timestamp).prefix(5)
                }
                lines.append(WatermarkLineItem(text: loc.t("timeLabel") + timeStr, isHighlight: true))
            }
            
            // Project & Task
            if !template.projectName.isEmpty {
                lines.append(WatermarkLineItem(text: loc.t("projectLabel") + template.projectName, isHighlight: false))
            }
            if !template.workItem.isEmpty {
                lines.append(WatermarkLineItem(text: loc.t("workItemLabel") + template.workItem, isHighlight: false))
            }
            if !template.contractorName.isEmpty {
                lines.append(WatermarkLineItem(text: loc.t("contractorLabel") + template.contractorName, isHighlight: false))
            }
            if !template.inspectorName.isEmpty {
                lines.append(WatermarkLineItem(text: loc.t("inspectorLabel") + template.inspectorName, isHighlight: false))
            }
            
            // Address & GPS
            if template.showLocation && !locationManager.fullAddress.isEmpty {
                lines.append(WatermarkLineItem(text: loc.t("locationLabel") + locationManager.fullAddress, isHighlight: false))
            }
            if template.showCoordinates {
                lines.append(WatermarkLineItem(text: loc.t("coordinatesLabel") + locationManager.formattedCoordinates, isHighlight: false))
            }
            if template.showAltitude {
                let alt = String(format: "%.1f m", locationManager.altitude)
                lines.append(WatermarkLineItem(text: loc.t("altitudeLabel") + alt, isHighlight: false))
            }
            
            // Weather & Compass
            var envParts: [String] = []
            if template.showWeather {
                envParts.append("\(locationManager.weatherCondition) \(locationManager.temperatureCelsius)°C (Độ ẩm \(locationManager.humidityPercent)%)")
            }
            if template.showCompass {
                envParts.append(loc.t("compassLabel") + locationManager.compassDirection)
            }
            if !envParts.isEmpty {
                lines.append(WatermarkLineItem(text: envParts.joined(separator: " • "), isHighlight: false))
            }
            
            // Notes
            if !template.customNotes.isEmpty {
                lines.append(WatermarkLineItem(text: loc.t("notesLabel") + template.customNotes, isHighlight: false))
            }
            
            // Verification Code
            if template.showAntiCounterfeitQR, let rec = verificationRecord {
                lines.append(WatermarkLineItem(text: loc.t("verifyCodeLabel") + rec.id, isHighlight: true))
            }
            
            // 3. Measure Card Dimensions
            let cardWidth = min(imageSize.width * 0.88, 620.0 * scaleFactor)
            let padding = 20.0 * scaleFactor
            let qrSize: CGFloat = template.showAntiCounterfeitQR ? 105.0 * scaleFactor : 0.0
            let textWidth = cardWidth - (padding * 2) - (template.showAntiCounterfeitQR ? qrSize + 16.0 * scaleFactor : 0)
            
            let titleFont = UIFont.systemFont(ofSize: 21.0 * scaleFactor, weight: .bold)
            let catFont = UIFont.systemFont(ofSize: 14.0 * scaleFactor, weight: .bold)
            let bodyFont = UIFont.systemFont(ofSize: 13.5 * scaleFactor, weight: .medium)
            let highlightFont = UIFont.systemFont(ofSize: 13.5 * scaleFactor, weight: .bold)
            
            // Calculate total card height
            var contentHeight = padding + 34.0 * scaleFactor // title + header space
            for item in lines {
                let font = item.isHighlight ? highlightFont : bodyFont
                let itemHeight = measureTextHeight(item.text, font: font, maxWidth: textWidth)
                contentHeight += itemHeight + 6.0 * scaleFactor
            }
            contentHeight += padding
            
            if template.showAntiCounterfeitQR {
                contentHeight = max(contentHeight, qrSize + padding * 2 + 18.0 * scaleFactor)
            }
            
            // Card Positioning
            let margin = 36.0 * scaleFactor
            var cardX: CGFloat = margin
            var cardY: CGFloat = imageSize.height - contentHeight - margin
            
            switch template.position {
            case .bottomLeft:
                cardX = margin
                cardY = imageSize.height - contentHeight - margin
            case .bottomRight:
                cardX = imageSize.width - cardWidth - margin
                cardY = imageSize.height - contentHeight - margin
            case .topLeft:
                cardX = margin
                cardY = margin + 20.0 * scaleFactor
            case .topRight:
                cardX = imageSize.width - cardWidth - margin
                cardY = margin + 20.0 * scaleFactor
            case .centerBottom:
                cardX = (imageSize.width - cardWidth) / 2.0
                cardY = imageSize.height - contentHeight - margin
            }
            
            let cardRect = CGRect(x: cardX, y: cardY, width: cardWidth, height: contentHeight)
            let cornerRadius = 16.0 * scaleFactor
            
            // 4. Draw Background Card by BadgeStyle
            let cardPath = UIBezierPath(roundedRect: cardRect, cornerRadius: cornerRadius)
            let themeColor = template.colorTheme.uiColor
            
            switch template.badgeStyle {
            case .glassmorphism:
                let alpha = CGFloat(template.opacity * 0.85).clamped(to: 0.3...0.95)
                cgContext.setFillColor(UIColor(red: 0.05, green: 0.06, blue: 0.08, alpha: alpha).cgColor)
                cgContext.addPath(cardPath.cgPath)
                cgContext.fillPath()
                
                cgContext.setStrokeColor(themeColor.withAlphaComponent(0.65).cgColor)
                cgContext.setLineWidth(2.5 * scaleFactor)
                cgContext.addPath(cardPath.cgPath)
                cgContext.strokePath()
                
            case .darkCard:
                let alpha = CGFloat(template.opacity * 0.95).clamped(to: 0.4...1.0)
                cgContext.setFillColor(UIColor(red: 0.09, green: 0.10, blue: 0.13, alpha: alpha).cgColor)
                cgContext.addPath(cardPath.cgPath)
                cgContext.fillPath()
                
                cgContext.setStrokeColor(UIColor.white.withAlphaComponent(0.25).cgColor)
                cgContext.setLineWidth(1.5 * scaleFactor)
                cgContext.addPath(cardPath.cgPath)
                cgContext.strokePath()
                
            case .borderedStamp:
                let alpha = CGFloat(template.opacity * 0.90).clamped(to: 0.4...1.0)
                cgContext.setFillColor(UIColor(red: 0.04, green: 0.04, blue: 0.05, alpha: alpha).cgColor)
                cgContext.addPath(cardPath.cgPath)
                cgContext.fillPath()
                
                cgContext.setStrokeColor(themeColor.cgColor)
                cgContext.setLineWidth(3.5 * scaleFactor)
                cgContext.addPath(cardPath.cgPath)
                cgContext.strokePath()
                
            case .minimalTransparent:
                let alpha = CGFloat(template.opacity * 0.45).clamped(to: 0.15...0.75)
                cgContext.setFillColor(UIColor.black.withAlphaComponent(alpha).cgColor)
                cgContext.addPath(cardPath.cgPath)
                cgContext.fillPath()
            }
            
            // 5. Draw Header: Vertical Accent Bar + Title + Category Pill
            let barRect = CGRect(x: cardX + padding, y: cardY + padding, width: 4.0 * scaleFactor, height: 22.0 * scaleFactor)
            cgContext.setFillColor(themeColor.cgColor)
            cgContext.fill(barRect)
            
            let titleAttrs: [NSAttributedString.Key: Any] = [
                .font: titleFont,
                .foregroundColor: UIColor.white
            ]
            let titleRect = CGRect(x: cardX + padding + 12.0 * scaleFactor, y: cardY + padding, width: textWidth - 100 * scaleFactor, height: 26.0 * scaleFactor)
            (title as NSString).draw(in: titleRect, withAttributes: titleAttrs)
            
            let catText = "● " + template.category.localizedName(in: loc.currentLanguage)
            let catAttrs: [NSAttributedString.Key: Any] = [
                .font: catFont,
                .foregroundColor: themeColor
            ]
            let catSize = (catText as NSString).size(withAttributes: catAttrs)
            let catRect = CGRect(x: cardX + cardWidth - padding - catSize.width, y: cardY + padding + 2.0 * scaleFactor, width: catSize.width, height: catSize.height)
            (catText as NSString).draw(in: catRect, withAttributes: catAttrs)
            
            // Divider Line
            let dividerY = cardY + padding + 28.0 * scaleFactor
            cgContext.setStrokeColor(UIColor.white.withAlphaComponent(0.2).cgColor)
            cgContext.setLineWidth(1.0 * scaleFactor)
            cgContext.move(to: CGPoint(x: cardX + padding, y: dividerY))
            cgContext.addLine(to: CGPoint(x: cardX + cardWidth - padding, y: dividerY))
            cgContext.strokePath()
            
            // 6. Draw Content Lines
            var currentY = dividerY + 12.0 * scaleFactor
            for item in lines {
                let font = item.isHighlight ? highlightFont : bodyFont
                let color = item.isHighlight ? themeColor : UIColor.white.withAlphaComponent(0.92)
                let attrs: [NSAttributedString.Key: Any] = [
                    .font: font,
                    .foregroundColor: color
                ]
                let rect = CGRect(x: cardX + padding, y: currentY, width: textWidth, height: 120.0 * scaleFactor)
                (item.text as NSString).draw(in: rect, withAttributes: attrs)
                let height = measureTextHeight(item.text, font: font, maxWidth: textWidth)
                currentY += height + 5.0 * scaleFactor
            }
            
            // 7. Draw Anti-Counterfeiting QR Code
            if template.showAntiCounterfeitQR, let rec = verificationRecord {
                let qrX = cardX + cardWidth - padding - qrSize
                let qrY = cardY + contentHeight - padding - qrSize - 14.0 * scaleFactor
                let qrRect = CGRect(x: qrX, y: qrY, width: qrSize, height: qrSize)
                
                // White backing plate
                let plateRect = qrRect.insetBy(dx: -4.0 * scaleFactor, dy: -4.0 * scaleFactor)
                let platePath = UIBezierPath(roundedRect: plateRect, cornerRadius: 6.0 * scaleFactor)
                cgContext.setFillColor(UIColor.white.cgColor)
                cgContext.addPath(platePath.cgPath)
                cgContext.fillPath()
                
                if let qrImage = ImageUtilities.generateQRCode(from: rec.toQRCodePayload(), size: CGSize(width: qrSize, height: qrSize)) {
                    qrImage.draw(in: qrRect)
                }
                
                // Label under QR code
                let label = loc.t("scanToVerify")
                let labelAttrs: [NSAttributedString.Key: Any] = [
                    .font: UIFont.systemFont(ofSize: 8.5 * scaleFactor, weight: .bold),
                    .foregroundColor: UIColor.white.withAlphaComponent(0.85)
                ]
                let lSize = (label as NSString).size(withAttributes: labelAttrs)
                let lRect = CGRect(x: qrX + (qrSize - lSize.width) / 2.0, y: qrY + qrSize + 8.0 * scaleFactor, width: lSize.width, height: lSize.height)
                (label as NSString).draw(in: lRect, withAttributes: labelAttrs)
            }
            
            // 8. Draw Active Sticker Badge (if any)
            if let sticker = template.activeSticker {
                let stickerSize = 145.0 * scaleFactor
                let stickerMargin = 30.0 * scaleFactor
                let stickerX: CGFloat
                if template.position == .topRight || template.position == .bottomRight {
                    stickerX = stickerMargin
                } else {
                    stickerX = imageSize.width - stickerSize - stickerMargin
                }
                let stickerY: CGFloat
                if template.position == .topLeft || template.position == .topRight {
                    stickerY = imageSize.height - stickerSize - stickerMargin
                } else {
                    stickerY = stickerMargin + 20.0 * scaleFactor
                }
                let stickerRect = CGRect(x: stickerX, y: stickerY, width: stickerSize, height: stickerSize)
                sticker.draw(in: cgContext, rect: stickerRect)
            }
        }
    }
    
    private func measureTextHeight(_ text: String, font: UIFont, maxWidth: CGFloat) -> CGFloat {
        let constraintRect = CGSize(width: maxWidth, height: .greatestFiniteMagnitude)
        let boundingBox = (text as NSString).boundingRect(
            with: constraintRect,
            options: [.usesLineFragmentOrigin, .usesFontLeading],
            attributes: [.font: font],
            context: nil
        )
        return max(font.lineHeight, ceil(boundingBox.height))
    }
}

// Data Model for line item
fileprivate struct WatermarkLineItem {
    let text: String
    let isHighlight: Bool
}

fileprivate extension Comparable {
    func clamped(to limits: ClosedRange<Self>) -> Self {
        return min(max(self, limits.lowerBound), limits.upperBound)
    }
}