import SwiftUI

public struct SettingsView: View {
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var loc = LocalizationManager.shared
    
    @AppStorage("snaplab_format") private var imageFormat = "JPEG"
    @AppStorage("snaplab_coord_format") private var coordFormat = "DMS"
    @AppStorage("snaplab_temp_unit") private var tempUnit = "Celsius"
    @AppStorage("snaplab_auto_save_album") private var autoSaveAlbum = true
    @AppStorage("snaplab_sound_shutter") private var soundShutter = true
    
    public var body: some View {
        NavigationView {
            Form {
                // Section 0: Language Switcher (Tiếng Việt <-> English)
                Section(header: Text(loc.t("languageSection")).font(.system(size: 13, weight: .bold))) {
                    Picker(loc.t("appLanguage"), selection: Binding(
                        get: { loc.currentLanguage },
                        set: { loc.setLanguage($0) }
                    )) {
                        ForEach(AppLanguage.allCases) { lang in
                            Text(lang.displayName).tag(lang)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .padding(.vertical, 4)
                }
                
                // Section 1: Capture Quality
                Section(header: Text(loc.t("captureQualitySection")).font(.system(size: 13, weight: .bold))) {
                    Picker(loc.t("exportFormat"), selection: $imageFormat) {
                        Text(loc.t("jpegQuality")).tag("JPEG")
                        Text(loc.t("heicQuality")).tag("HEIC")
                    }
                    
                    Toggle(loc.t("autoSaveToAlbum"), isOn: $autoSaveAlbum)
                    Toggle(loc.t("shutterSound"), isOn: $soundShutter)
                }
                
                // Section 2: Watermark Units
                Section(header: Text(loc.t("watermarkDataSection")).font(.system(size: 13, weight: .bold))) {
                    Picker(loc.t("gpsCoordinateFormat"), selection: $coordFormat) {
                        Text(loc.t("coordDms")).tag("DMS")
                        Text(loc.t("coordDecimal")).tag("Decimal")
                    }
                    
                    Picker(loc.t("temperatureUnit"), selection: $tempUnit) {
                        Text(loc.t("tempCelsius")).tag("Celsius")
                        Text(loc.t("tempFahrenheit")).tag("Fahrenheit")
                    }
                }
                
                // Section 3: Anti-Counterfeiting Security
                Section(header: Text(loc.t("securitySectionTitle")).font(.system(size: 13, weight: .bold))) {
                    VStack(alignment: .leading, spacing: 6) {
                        HStack {
                            Image(systemName: "lock.shield.fill")
                                .foregroundColor(Color.snapNeonGreen)
                            Text(loc.t("securityTitle"))
                                .font(.system(size: 14, weight: .bold))
                        }
                        Text(loc.t("securityDetailedDesc"))
                            .font(.system(size: 12))
                            .foregroundColor(.secondary)
                    }
                    .padding(.vertical, 4)
                }
                
                // Section 4: About & Compatibility
                Section(header: Text(loc.t("appInfoSection")).font(.system(size: 13, weight: .bold))) {
                    HStack {
                        Text(loc.t("appNameTitle"))
                        Spacer()
                        Text("SnapLab ‑ Camera & Filter")
                            .foregroundColor(.secondary)
                    }
                    HStack {
                        Text(loc.t("appVersionTitle"))
                        Spacer()
                        Text("2.4.0 (Build 6751682117)")
                            .foregroundColor(.secondary)
                    }
                    HStack {
                        Text(loc.t("platformTitle"))
                        Spacer()
                        Text(loc.t("platformDesc"))
                            .foregroundColor(.secondary)
                    }
                    HStack {
                        Text(loc.t("copyrightTitle"))
                        Spacer()
                        Text(loc.t("copyrightDesc"))
                            .foregroundColor(.secondary)
                    }
                }
            }
            .navigationTitle(loc.t("settingsNavTitle"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button(loc.t("done")) {
                        presentationMode.wrappedValue.dismiss()
                    }
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(Color.snapAccentOrange)
                }
            }
        }
    }
}
