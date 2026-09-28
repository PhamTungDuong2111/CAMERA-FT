import SwiftUI

public struct TemplateEditorSheet: View {
    @Binding var template: WatermarkTemplate
    let onSave: (WatermarkTemplate) -> Void
    let onDismiss: () -> Void
    
    @State private var workingCopy: WatermarkTemplate
    @StateObject private var locationManager = LocationWeatherManager.shared
    @ObservedObject var loc = LocalizationManager.shared
    
    public init(template: Binding<WatermarkTemplate>, onSave: @escaping (WatermarkTemplate) -> Void, onDismiss: @escaping () -> Void) {
        self._template = template
        self.onSave = onSave
        self.onDismiss = onDismiss
        self._workingCopy = State(initialValue: template.wrappedValue)
    }
    
    public var body: some View {
        NavigationView {
            Form {
                // Section 1: Live Interactive Preview
                Section(header: Text(loc.t("previewSection")).font(.system(size: 13, weight: .bold))) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(red: 0.14, green: 0.18, blue: 0.24))
                            .frame(height: 240)
                        
                        WatermarkOverlayView(
                            template: workingCopy,
                            locationManager: locationManager,
                            verificationRecord: VerificationRecord(id: "SL-PREVIEW-9921"),
                            onEditTapped: {}
                        )
                        .frame(height: 240)
                    }
                    .listRowInsets(EdgeInsets())
                    .padding(.vertical, 8)
                }
                
                // Section 2: Watermark Text Fields
                Section(header: Text(loc.t("infoFieldsSection")).font(.system(size: 13, weight: .bold))) {
                    TextField(loc.t("titlePlaceholder"), text: $workingCopy.titleText)
                    TextField(loc.t("projectPlaceholder"), text: $workingCopy.projectName)
                    TextField(loc.t("itemPlaceholder"), text: $workingCopy.workItem)
                    TextField(loc.t("contractorPlaceholder"), text: $workingCopy.contractorName)
                    TextField(loc.t("inspectorPlaceholder"), text: $workingCopy.inspectorName)
                    TextField(loc.t("notesPlaceholder"), text: $workingCopy.customNotes)
                }
                
                // Section 3: Information Toggles
                Section(header: Text(loc.t("autoFieldsSection")).font(.system(size: 13, weight: .bold))) {
                    Toggle(loc.t("toggleTime"), isOn: $workingCopy.showTime)
                    if workingCopy.showTime {
                        Toggle(loc.t("toggleSeconds"), isOn: $workingCopy.showSeconds)
                    }
                    Toggle(loc.t("toggleLocation"), isOn: $workingCopy.showLocation)
                    Toggle(loc.t("toggleCoords"), isOn: $workingCopy.showCoordinates)
                    Toggle(loc.t("toggleAltitude"), isOn: $workingCopy.showAltitude)
                    Toggle(loc.t("toggleWeather"), isOn: $workingCopy.showWeather)
                    Toggle(loc.t("toggleCompass"), isOn: $workingCopy.showCompass)
                    Toggle(loc.t("toggleDeviceInfo"), isOn: $workingCopy.showDeviceInfo)
                    Toggle(loc.t("toggleAntiCounterfeit"), isOn: $workingCopy.showAntiCounterfeitQR)
                }
                
                // Section 4: Style & Visuals
                Section(header: Text(loc.t("appearanceSection")).font(.system(size: 13, weight: .bold))) {
                    Picker(loc.t("positionPicker"), selection: $workingCopy.position) {
                        ForEach(WatermarkPosition.allCases) { pos in
                            Text(pos.localizedName(in: loc.currentLanguage)).tag(pos)
                        }
                    }
                    
                    Picker(loc.t("badgeStylePicker"), selection: $workingCopy.badgeStyle) {
                        ForEach(WatermarkBadgeStyle.allCases) { style in
                            Text(style.localizedName(in: loc.currentLanguage)).tag(style)
                        }
                    }
                    
                    Picker(loc.t("colorThemePicker"), selection: $workingCopy.colorTheme) {
                        ForEach(WatermarkColorTheme.allCases) { color in
                            HStack {
                                Circle().fill(color.primaryColor).frame(width: 12, height: 12)
                                Text(color.localizedName(in: loc.currentLanguage))
                            }
                            .tag(color)
                        }
                    }
                    
                    VStack(alignment: .leading, spacing: 6) {
                        HStack {
                            Text(loc.t("opacitySlider"))
                            Spacer()
                            Text("\(Int(workingCopy.opacity * 100))%")
                                .foregroundColor(.secondary)
                        }
                        Slider(value: $workingCopy.opacity, in: 0.3...1.0, step: 0.05)
                    }
                    
                    VStack(alignment: .leading, spacing: 6) {
                        HStack {
                            Text(loc.t("scaleSlider"))
                            Spacer()
                            Text(String(format: "%.1fx", workingCopy.scale))
                                .foregroundColor(.secondary)
                        }
                        Slider(value: $workingCopy.scale, in: 0.7...1.3, step: 0.05)
                    }
                }
            }
            .navigationTitle(loc.t("customizerTitle"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(loc.t("cancel"), action: onDismiss)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(loc.t("apply")) {
                        onSave(workingCopy)
                        onDismiss()
                    }
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(Color.snapAccentOrange)
                }
            }
        }
    }
}
