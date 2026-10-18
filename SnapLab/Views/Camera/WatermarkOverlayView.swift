import SwiftUI

public struct WatermarkOverlayView: View {
    let template: WatermarkTemplate
    @ObservedObject var locationManager: LocationWeatherManager
    @ObservedObject var loc = LocalizationManager.shared
    let verificationRecord: VerificationRecord?
    let onEditTapped: () -> Void
    
    // Timer for ticking live seconds
    @State private var currentDate = Date()
    let timer = Timer.publish(every: 1.0, on: .main, in: .common).autoconnect()
    
    public var body: some View {
        ZStack {
            // 1. Watermark Card Positioned
            VStack {
                if template.position == .bottomLeft || template.position == .bottomRight || template.position == .centerBottom {
                    Spacer()
                }
                
                HStack {
                    if template.position == .bottomRight || template.position == .topRight {
                        Spacer()
                    }
                    
                    // The Watermark Card
                    watermarkBadgeView
                        .scaleEffect(CGFloat(template.scale))
                        .opacity(template.opacity)
                        .onTapGesture {
                            onEditTapped()
                        }
                    
                    if template.position == .bottomLeft || template.position == .topLeft {
                        Spacer()
                    }
                }
                
                if template.position == .topLeft || template.position == .topRight {
                    Spacer()
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 24)
            
            // 2. Active Sticker Badge (Corner Placement)
            if let sticker = template.activeSticker {
                VStack {
                    HStack {
                        if template.position == .topRight || template.position == .bottomRight {
                            StickerBadgeView(sticker: sticker, size: 105)
                                .padding(.leading, 20)
                                .padding(.top, 76)
                            Spacer()
                        } else {
                            Spacer()
                            StickerBadgeView(sticker: sticker, size: 105)
                                .padding(.trailing, 20)
                                .padding(.top, 76)
                        }
                    }
                    Spacer()
                }
            }
        }
        .onReceive(timer) { input in
            currentDate = input
        }
    }
    
    // MARK: - Watermark Badge View
    @ViewBuilder
    private var watermarkBadgeView: some View {
        HStack(alignment: .bottom, spacing: 14) {
            // Text Details Column
            VStack(alignment: .leading, spacing: 4) {
                // Header Bar: Accent Bar + Title and Category
                HStack(spacing: 6) {
                    RoundedRectangle(cornerRadius: 2)
                        .fill(template.colorTheme.primaryColor)
                        .frame(width: 4, height: 16)
                    
                    Text(template.titleText.isEmpty ? template.category.localizedName(in: loc.currentLanguage).uppercased() : template.titleText.uppercased())
                        .font(.system(size: 14, weight: .heavy))
                        .foregroundColor(.white)
                    
                    Spacer(minLength: 6)
                    
                    Text("● " + template.category.localizedName(in: loc.currentLanguage))
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(template.colorTheme.primaryColor)
                }
                
                Divider()
                    .background(Color.white.opacity(0.2))
                    .padding(.vertical, 2)
                
                // Live Time
                if template.showTime {
                    HStack(spacing: 5) {
                        Image(systemName: "clock.fill")
                            .font(.system(size: 11))
                            .foregroundColor(template.colorTheme.primaryColor)
                        let timeString = template.showSeconds ? DateFormatter.fullDateTimeFormatter.string(from: currentDate) : DateFormatter.displayDateFormatter.string(from: currentDate) + " " + String(DateFormatter.displayTimeFormatter.string(from: currentDate).prefix(5))
                        Text(loc.t("timeLabel") + timeString)
                            .font(.system(size: 11.5, weight: .bold))
                            .foregroundColor(template.colorTheme.primaryColor)
                    }
                }
                
                // Project & Work Item
                if !template.projectName.isEmpty {
                    Label(loc.t("projectLabel") + template.projectName, systemImage: "building.2.fill")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(.white)
                        .lineLimit(1)
                }
                
                if !template.workItem.isEmpty {
                    Label(loc.t("workItemLabel") + template.workItem, systemImage: "hammer.fill")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(.white)
                        .lineLimit(1)
                }
                
                if !template.contractorName.isEmpty {
                    Label(loc.t("contractorLabel") + template.contractorName, systemImage: "person.2.fill")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(.white)
                        .lineLimit(1)
                }
                
                if !template.inspectorName.isEmpty {
                    Label(loc.t("inspectorLabel") + template.inspectorName, systemImage: "checkmark.seal.fill")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(.white)
                        .lineLimit(1)
                }
                
                // Address & Coordinates
                if template.showLocation && !locationManager.fullAddress.isEmpty {
                    Label(loc.t("locationLabel") + locationManager.fullAddress, systemImage: "mappin.and.ellipse")
                        .font(.system(size: 10.5, weight: .medium))
                        .foregroundColor(.white.opacity(0.9))
                        .lineLimit(2)
                }
                
                if template.showCoordinates {
                    Label(loc.t("coordinatesLabel") + locationManager.formattedCoordinates, systemImage: "location.north.circle.fill")
                        .font(.system(size: 10.5, weight: .medium))
                        .foregroundColor(.white.opacity(0.85))
                }
                
                if template.showAltitude {
                    Label(loc.t("altitudeLabel") + String(format: "%.1f m", locationManager.altitude), systemImage: "mountain.2.fill")
                        .font(.system(size: 10.5, weight: .medium))
                        .foregroundColor(.white.opacity(0.85))
                }
                
                // Weather & Heading
                if template.showWeather || template.showCompass {
                    HStack(spacing: 8) {
                        if template.showWeather {
                            HStack(spacing: 3) {
                                Image(systemName: "sun.max.fill")
                                    .font(.system(size: 10))
                                    .foregroundColor(.yellow)
                                Text("\(locationManager.weatherCondition) \(locationManager.temperatureCelsius)°C")
                                    .font(.system(size: 10, weight: .medium))
                                    .foregroundColor(.white.opacity(0.9))
                            }
                        }
                        if template.showCompass {
                            HStack(spacing: 3) {
                                Image(systemName: "safari.fill")
                                    .font(.system(size: 10))
                                    .foregroundColor(template.colorTheme.primaryColor)
                                Text(locationManager.compassDirection)
                                    .font(.system(size: 10, weight: .medium))
                                    .foregroundColor(.white.opacity(0.9))
                            }
                        }
                    }
                }
                
                // Notes
                if !template.customNotes.isEmpty {
                    Label(loc.t("notesLabel") + template.customNotes, systemImage: "note.text")
                        .font(.system(size: 10.5, weight: .medium))
                        .foregroundColor(.white.opacity(0.9))
                        .lineLimit(2)
                }
                
                // Verification Record Code
                if template.showAntiCounterfeitQR, let rec = verificationRecord {
                    Text(loc.t("verifyCodeLabel") + rec.id)
                        .font(.system(size: 9.5, weight: .bold, design: .monospaced))
                        .foregroundColor(template.colorTheme.primaryColor)
                        .padding(.top, 2)
                }
            }
            .frame(maxWidth: 270, alignment: .leading)
            
            // Anti-Counterfeiting Dynamic QR Code Plate
            if template.showAntiCounterfeitQR, let rec = verificationRecord {
                VStack(spacing: 4) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 6)
                            .fill(Color.white)
                            .frame(width: 80, height: 80)
                        
                        if let qr = ImageUtilities.generateQRCode(from: rec.toQRCodePayload(), size: CGSize(width: 74, height: 74)) {
                            Image(uiImage: qr)
                                .interpolation(.none)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 74, height: 74)
                        }
                    }
                    
                    Text(loc.t("scanToVerify"))
                        .font(.system(size: 7, weight: .bold))
                        .foregroundColor(.white.opacity(0.8))
                        .lineLimit(1)
                }
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .background(badgeBackground)
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .overlay(badgeBorder)
        .shadow(color: Color.black.opacity(0.45), radius: 8, x: 0, y: 4)
    }
    
    // MARK: - Badge Background Styling
    @ViewBuilder
    private var badgeBackground: some View {
        switch template.badgeStyle {
        case .glassmorphism:
            Color(red: 0.06, green: 0.07, blue: 0.09)
                .opacity(0.82)
                .background(.ultraThinMaterial)
        case .darkCard:
            Color(red: 0.10, green: 0.11, blue: 0.14)
                .opacity(0.95)
        case .borderedStamp:
            Color(red: 0.05, green: 0.05, blue: 0.06)
                .opacity(0.92)
        case .minimalTransparent:
            Color.black.opacity(0.40)
        }
    }
    
    // MARK: - Badge Border Styling
    @ViewBuilder
    private var badgeBorder: some View {
        switch template.badgeStyle {
        case .glassmorphism:
            RoundedRectangle(cornerRadius: 14)
                .stroke(template.colorTheme.primaryColor.opacity(0.65), lineWidth: 1.5)
        case .darkCard:
            RoundedRectangle(cornerRadius: 14)
                .stroke(Color.white.opacity(0.25), lineWidth: 1.0)
        case .borderedStamp:
            RoundedRectangle(cornerRadius: 14)
                .stroke(template.colorTheme.primaryColor, lineWidth: 2.5)
        case .minimalTransparent:
            EmptyView()
        }
    }
}