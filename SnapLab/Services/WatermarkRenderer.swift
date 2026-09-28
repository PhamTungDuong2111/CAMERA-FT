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
        let fixedImage = ImageUtilities.fixOrientation(for: originalImage)
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
            let baseWidth = min(imageSize.width, imageSize.height)
            let scaleFactor = (baseWidth / 1080.0) * CGFloat(template.scale)
            
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
                lines.append(WatermarkLineItem(icon: "clock.fill", text: loc.t("timeLabel") + timeStr, isHighlight: true))
            }
            
            // Project & Task
            if !template.projectName.isEmpty {
                lines.append(WatermarkLineItem(icon: "building.2.fill", text: loc.t("projectLabel") + template.projectName, isHighlight: false))
            }
            if !template.workItem.isEmpty {
                lines.append(WatermarkLineItem(icon: "hammer.fill", text: loc.t("workItemLabel") + template.workItem, isHighlight: false))
            }
            if !template.contractorName.isEmpty {
                lines.append(WatermarkLineItem(icon: "person.2.fill", text: loc.t("contractorLabel") + template.contractorName, isHighlight: false))
            }
            if !template.inspectorName.isEmpty {
                lines.append(WatermarkLineItem(icon: "checkmark.seal.fill", text: loc.t("inspectorLabel") + template.inspectorName, isHighlight: false))
            }
            
            // Address & GPS
            if template.showLocation && !locationManager.fullAddress.isEmpty {
                lines.append(WatermarkLineItem(icon: "mappin.and.ellipse", text: loc.t("locationLabel") + locationManager.fullAddress, isHighlight: false))
            }
            if template.showCoordinates {
                let coordStr = locationManager.formattedCoordinates(latitude: locationManager.latitude, longitude: locationManager.longitude)
                lines.append(WatermarkLineItem(icon: "location.north.circle.fill", text: loc.t("coordinatesLabel") + coordStr, isHighlight: false))
            }
            if template.showAltitude {
                let altStr = String(format: "%.1f m", locationManager.altitude)
                lines.append(WatermarkLineItem(icon: "mountain.2.fill", text: loc.t("altitudeLabel") + altStr, isHighlight: false))
            }
            
            // Weather & Compass
            var envParts: [String] = []
            if template.showWeather {
                envParts.append("\(locationManager.weatherCondition) \(locationManager.temperatureCelsius)°C (Độ ẩm \(locationManager.humidityPercent)%)")
            }
            if template.showCompass {
                envParts.append(loc.t("compassLabel") + "\(locationManager.compassDirection)")
            }
            if !envParts.isEmpty {
                lines.append(WatermarkLineItem(icon: "thermometer.sun.fill", text: envParts.joined(separator: " • "), isHighlight: false))
            }
            
            // Notes
            if !template.customNotes.isEmpty {
                lines.append(WatermarkLineItem(icon: "doc.text.fill", text: loc.t("notesLabel") + template.customNotes, isHighlight: false))
            }
            
            // Anti-Counterfeiting verification code
            if template.showAntiCounterfeitQR, let record = verificationRecord {
                lines.append(WatermarkLineItem(icon: "qrcode.viewfinder", text: loc.t("verifyCodeLabel") + record.id, isHighlight: true))
            }
            
            // 3. Layout calculation
            let cardWidth = min(imageSize.width * 0.88, 620.0 * scaleFactor)
            let padding: CGFloat = 20.0 * scaleFactor
            let qrSize: CGFloat = template.showAntiCounterfeitQR ? (100.0 * scaleFactor) : 0.0
            let availableTextWidth = cardWidth - (padding * 2) - (template.showAntiCounterfeitQR ? (qrSize + 16.0 * scaleFactor) : 0)
            
            let headerFontSize: CGFloat = 18.0 * scaleFactor
            let titleFontSize: CGFloat = 22.0 * scaleFactor
            let bodyFontSize: CGFloat = 14.5 * scaleFactor
            
            let fontHeader = UIFont.systemFont(ofSize: headerFontSize, weight: .bold)
            let fontTitle = UIFont.systemFont(ofSize: titleFontSize, weight: .heavy)
            let fontBody = UIFont.systemFont(ofSize: bodyFontSize, weight: .medium)
            let fontHighlight = UIFont.systemFont(ofSize: bodyFontSize, weight: .bold)
            
            // Estimate height
            var totalHeight: CGFloat = padding * 2 + 35.0 * scaleFactor
            for item in lines {
                let bounding = (item.text as NSString).boundingRect(
                    with: CGSize(width: availableTextWidth, height: 200),
                    options: [.usesLineFragmentOrigin, .usesFontLeading],
                    attributes: [.font: item.isHighlight ? fontHighlight : fontBody],
                    context: nil
                )
                totalHeight += max(24.0 * scaleFactor, bounding.height + (6.0 * scaleFactor))
            }
            if template.showAntiCounterfeitQR {
                totalHeight = max(totalHeight, qrSize + padding * 2)
            }
            
            // Determine Position Rect
            let margin: CGFloat = 36.0 * scaleFactor
            var cardX: CGFloat = margin
            var cardY: CGFloat = imageSize.height - totalHeight - margin
            
            switch template.position {
            case .bottomLeft:
                cardX = margin
                cardY = imageSize.height - totalHeight - margin
            case .bottomRight:
                cardX = imageSize.width - cardWidth - margin
                cardY = imageSize.height - totalHeight - margin
            case .topLeft:
                cardX = margin
                cardY = margin + 40.0 * scaleFactor
            case .topRight:
                cardX = imageSize.width - cardWidth - margin
                cardY = margin + 40.0 * scaleFactor
            case .centerBottom:
                cardX = (imageSize.width - cardWidth) / 2
                cardY = imageSize.height - totalHeight - margin
            }
            
            let cardRect = CGRect(x: cardX, y: cardY, width: cardWidth, height: totalHeight)
            
            // 4. Draw Background Badge according to Style
            cgContext.saveGState()
            cgContext.setAlpha(CGFloat(template.opacity))
            
            let cornerRadius: CGFloat = 16.0 * scaleFactor
            let path = UIBezierPath(roundedRect: cardRect, cornerRadius: cornerRadius)
            
            switch template.badgeStyle {
            case .glassmorphism:
                // Dark translucent base + gradient tint
                UIColor(white: 0.05, alpha: 0.72).setFill()
                path.fill()
                
                // Border highlight
                cgContext.setStrokeColor(template.colorTheme.accentUiColor.withAlphaComponent(0.6).cgColor)
                cgContext.setLineWidth(2.0 * scaleFactor)
                path.stroke()
                
            case .darkCard:
                UIColor(red: 0.10, green: 0.11, blue: 0.13, alpha: 0.88).setFill()
                path.fill()
                cgContext.setStrokeColor(UIColor.white.withAlphaComponent(0.2).cgColor)
                cgContext.setLineWidth(1.5 * scaleFactor)
                path.stroke()
                
            case .borderedStamp:
                UIColor(white: 0.0, alpha: 0.65).setFill()
                path.fill()
                cgContext.setStrokeColor(template.colorTheme.accentUiColor.cgColor)
                cgContext.setLineWidth(3.0 * scaleFactor)
                path.stroke()
                
            case .minimalTransparent:
                // Subtle shadow back plate for readability
                UIColor(white: 0.0, alpha: 0.35).setFill()
                path.fill()
            }
            
            cgContext.restoreGState()
            
            // 5. Draw Header Accent Pill & Title
            let accentColor = template.colorTheme.accentUiColor
            let accentBarRect = CGRect(x: cardX + padding, y: cardY + padding, width: 4.0 * scaleFactor, height: 26.0 * scaleFactor)
            let accentBar = UIBezierPath(roundedRect: accentBarRect, cornerRadius: 2.0 * scaleFactor)
            accentColor.setFill()
            accentBar.fill()
            
            let titleAttrs: [NSAttributedString.Key: Any] = [
                .font: fontTitle,
                .foregroundColor: UIColor.white
            ]
            (title as NSString).draw(
                at: CGPoint(x: cardX + padding + 12.0 * scaleFactor, y: cardY + padding + 1.0 * scaleFactor),
                withAttributes: titleAttrs
            )
            
            // Category tag on the right of header
            let catText = "● " + template.category.localizedName(in: loc.currentLanguage)
            let catAttrs: [NSAttributedString.Key: Any] = [
                .font: fontHeader,
                .foregroundColor: accentColor
            ]
            let catSize = (catText as NSString).size(withAttributes: catAttrs)
            (catText as NSString).draw(
                at: CGPoint(x: cardX + cardWidth - padding - catSize.width, y: cardY + padding + 3.0 * scaleFactor),
                withAttributes: catAttrs
            )
            
            // Divider line
            let dividerY = cardY + padding + 32.0 * scaleFactor
            cgContext.setStrokeColor(UIColor.white.withAlphaComponent(0.2).cgColor)
            cgContext.setLineWidth(1.0 * scaleFactor)
            cgContext.move(to: CGPoint(x: cardX + padding, y: dividerY))
            cgContext.addLine(to: CGPoint(x: cardX + cardWidth - padding, y: dividerY))
            cgContext.strokePath()
            
            // 6. Draw Content Lines
            var currentY = dividerY + 10.0 * scaleFactor
            for item in lines {
                let paragraphStyle = NSMutableParagraphStyle()
                paragraphStyle.lineBreakMode = .byWordWrapping
                
                let textColor = item.isHighlight ? accentColor : UIColor.white.withAlphaComponent(0.92)
                let itemFont = item.isHighlight ? fontHighlight : fontBody
                
                let attrs: [NSAttributedString.Key: Any] = [
                    .font: itemFont,
                    .foregroundColor: textColor,
                    .paragraphStyle: paragraphStyle
                ]
                
                let drawRect = CGRect(
                    x: cardX + padding,
                    y: currentY,
                    width: availableTextWidth,
                    height: 100
                )
                
                let bounding = (item.text as NSString).boundingRect(
                    with: CGSize(width: availableTextWidth, height: 100),
                    options: [.usesLineFragmentOrigin, .usesFontLeading],
                    attributes: attrs,
                    context: nil
                )
                
                (item.text as NSString).draw(in: drawRect, withAttributes: attrs)
                currentY += max(20.0 * scaleFactor, bounding.height + (4.0 * scaleFactor))
            }
            
            // 7. Draw Anti-Counterfeiting QR Code
            if template.showAntiCounterfeitQR, let record = verificationRecord {
                let qrPayload = record.toQRCodePayload()
                if let qrImage = ImageUtilities.generateQRCode(from: qrPayload, size: CGSize(width: qrSize, height: qrSize)) {
                    let qrX = cardX + cardWidth - padding - qrSize
                    let qrY = cardY + totalHeight - padding - qrSize - 4.0 * scaleFactor
                    let qrRect = CGRect(x: qrX, y: qrY, width: qrSize, height: qrSize)
                    
                    // White border background for QR code
                    let qrBgPath = UIBezierPath(roundedRect: qrRect.insetBy(dx: -4.0 * scaleFactor, dy: -4.0 * scaleFactor), cornerRadius: 6.0 * scaleFactor)
                    UIColor.white.setFill()
                    qrBgPath.fill()
                    
                    qrImage.draw(in: qrRect)
                    
                    // Small caption under QR
                    let label = loc.t("scanToVerify")
                    let labelAttrs: [NSAttributedString.Key: Any] = [
                        .font: UIFont.systemFont(ofSize: 8.5 * scaleFactor, weight: .bold),
                        .foregroundColor: UIColor.white.withAlphaComponent(0.8)
                    ]
                    let labelSize = (label as NSString).size(withAttributes: labelAttrs)
                    (label as NSString).draw(
                        at: CGPoint(x: qrX + (qrSize - labelSize.width) / 2, y: qrY + qrSize + 6.0 * scaleFactor),
                        withAttributes: labelAttrs
                    )
                }
            }
        }
    }
}

private struct WatermarkLineItem {
    let icon: String
    let text: String
    let isHighlight: Bool
}
