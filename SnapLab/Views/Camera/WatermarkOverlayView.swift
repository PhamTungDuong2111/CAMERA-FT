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
                // Header Bar: Title and Category
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
                        Text(loc.t("timeLabel") + (template.showSeconds ? DateFormatter.fullDateTimeFormatter.string(from: currentDate) : DateFormatter.displayDateFormatter.string(from: currentDate) + " " + String(DateFormatter.displayTimeFormatter.string(from: currentDate).prefix(5))))
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
                    let coord = locationManager.formattedCoordinates(latitude: locationManager.latitude, longitude: locationManager.longitude)
                    Label(loc.t("coordinatesLabel") + coord, systemImage: "location.north.circle.fill")
                        .font(.system(size: 10.5, weight: .medium))
                        .foregroundColor(.white.opacity(0.9))
                }
                
                if template.showAltitude {
                    Label(loc.t("altitudeLabel") + String(format: "%.1f m", locationManager.altitude), systemImage: "mountain.2.fill")
                        .font(.system(size: 10.5, weight: .medium))
                        .foregroundColor(.white.opacity(0.85))
                }
                
                // Weather & Compass
                if template.showWeather || template.showCompass {
                    HStack(spacing: 8) {
                        if template.showWeather {
                            Label("\(locationManager.weatherCondition) \(locationManager.temperatureCelsius)°C", systemImage: locationManager.weatherIcon)
                                .font(.system(size: 10.5, weight: .medium))
                                .foregroundColor(.white.opacity(0.9))
                        }
                        if template.showCompass {
                            Label(loc.t("compassLabel") + locationManager.compassDirection, systemImage: "safari.fill")
                                .font(.system(size: 10.5, weight: .medium))
                                .foregroundColor(.white.opacity(0.9))
                        }
                    }
                }
                
                // Custom Notes
                if !template.customNotes.isEmpty {
                    Label(loc.t("notesLabel") + template.customNotes, systemImage: "doc.text.fill")
                        .font(.system(size: 10, weight: .regular))
                        .foregroundColor(.white.opacity(0.8))
                        .lineLimit(2)
                }
                
                // Verification Code ID
                if template.showAntiCounterfeitQR, let record = verificationRecord {
                    HStack(spacing: 4) {
                        Image(systemName: "checkmark.shield.fill")
                            .font(.system(size: 10))
                            .foregroundColor(Color.snapNeonGreen)
                        Text(loc.t("snaplabVerified") + record.id)
                            .font(.system(size: 9.5, weight: .bold))
                            .foregroundColor(Color.snapNeonGreen)
                    }
                    .padding(.top, 1)
                }
            }
            .frame(maxWidth: 290, alignment: .leading)
            
            // Anti-Counterfeiting QR Code Column
            if template.showAntiCounterfeitQR {
                VStack(spacing: 3) {
                    let dummyPayload = verificationRecord?.toQRCodePayload() ?? "snaplab://verify?id=DEMO"
                    if let qrImage = ImageUtilities.generateQRCode(from: dummyPayload, size: CGSize(width: 68, height: 68)) {
                        Image(uiImage: qrImage)
                            .resizable()
                            .interpolation(.none)
                            .frame(width: 58, height: 58)
                            .padding(3)
                            .background(Color.white)
                            .cornerRadius(6)
                    }
                    
                    Text(loc.t("scanQuery"))
                        .font(.system(size: 7.5, weight: .heavy))
                        .foregroundColor(.white.opacity(0.85))
                }
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .background(
            badgeBackground(for: template.badgeStyle)
        )
        .overlay(
            badgeBorder(for: template.badgeStyle)
        )
    }
    
    // MARK: - Badge Background
    @ViewBuilder
    private func badgeBackground(for style: WatermarkBadgeStyle) -> some View {
        switch style {
        case .glassmorphism:
            RoundedRectangle(cornerRadius: 14)
                .fill(Color.black.opacity(0.68))
                .background(.ultraThinMaterial)
                .cornerRadius(14)
        case .darkCard:
            RoundedRectangle(cornerRadius: 14)
                .fill(Color(red: 0.10, green: 0.11, blue: 0.13).opacity(0.88))
        case .borderedStamp:
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.black.opacity(0.65))
        case .minimalTransparent:
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.black.opacity(0.35))
        }
    }
    
    // MARK: - Badge Border
    @ViewBuilder
    private func badgeBorder(for style: WatermarkBadgeStyle) -> some View {
        switch style {
        case .glassmorphism:
            RoundedRectangle(cornerRadius: 14)
                .stroke(template.colorTheme.primaryColor.opacity(0.55), lineWidth: 1.5)
        case .darkCard:
            RoundedRectangle(cornerRadius: 14)
                .stroke(Color.white.opacity(0.18), lineWidth: 1)
        case .borderedStamp:
            RoundedRectangle(cornerRadius: 12)
                .stroke(template.colorTheme.primaryColor, lineWidth: 2)
        case .minimalTransparent:
            EmptyView()
        }
    }
}
