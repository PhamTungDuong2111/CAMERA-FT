import SwiftUI

public struct AlbumWatermarkEditorView: View {
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var libraryManager = PhotoLibraryManager.shared
    @ObservedObject var locationManager = LocationWeatherManager.shared
    @ObservedObject var antiCounterfeitManager = AntiCounterfeitingManager.shared
    @ObservedObject var loc = LocalizationManager.shared
    
    @State private var sourceImage: UIImage?
    @State private var showingImagePicker = false
    @State private var selectedTemplate: WatermarkTemplate = WatermarkTemplate.presets[0]
    @State private var showingCustomizer = false
    @State private var isProcessing = false
    @State private var showSuccessBanner = false
    
    public var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                if let image = sourceImage {
                    // Preview Canvas with Watermark Overlay
                    ZStack {
                        Image(uiImage: image)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .background(Color.black)
                        
                        WatermarkOverlayView(
                            template: selectedTemplate,
                            locationManager: locationManager,
                            verificationRecord: VerificationRecord(id: "SL-ALBUM-8921"),
                            onEditTapped: {
                                showingCustomizer = true
                            }
                        )
                    }
                    
                    // Bottom Template Selector
                    TemplateSelectorView(
                        selectedTemplate: $selectedTemplate,
                        templates: .constant(WatermarkTemplate.presets),
                        onCustomize: { _ in
                            showingCustomizer = true
                        },
                        onDismiss: {}
                    )
                    .frame(height: 175)
                } else {
                    // Picker Prompt
                    emptyPickerPrompt
                }
            }
            .background(Color.snapBackgroundDark.edgesIgnoringSafeArea(.all))
            .navigationTitle(loc.t("albumEditorTitle"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(loc.t("close")) {
                        presentationMode.wrappedValue.dismiss()
                    }
                    .foregroundColor(.white)
                }
                
                if sourceImage != nil {
                    ToolbarItem(placement: .primaryAction) {
                        Button(action: saveWatermarkedResult) {
                            if isProcessing {
                                ProgressView()
                            } else {
                                Text(loc.t("savePhoto"))
                                    .font(.system(size: 15, weight: .bold))
                                    .foregroundColor(Color.snapAccentOrange)
                            }
                        }
                        .disabled(isProcessing)
                    }
                }
            }
            .sheet(isPresented: $showingImagePicker) {
                SystemImagePicker(selectedImage: $sourceImage) { picked in
                    self.sourceImage = picked
                }
            }
            .sheet(isPresented: $showingCustomizer) {
                TemplateEditorSheet(template: $selectedTemplate, onSave: { updated in
                    self.selectedTemplate = updated
                }, onDismiss: {
                    showingCustomizer = false
                })
            }
        }
    }
    
    private var emptyPickerPrompt: some View {
        VStack(spacing: 20) {
            Spacer()
            Image(systemName: "photo.badge.plus")
                .font(.system(size: 58))
                .foregroundColor(Color.snapAccentOrange)
            
            Text(loc.t("albumPickerPromptTitle"))
                .font(.system(size: 17, weight: .bold))
                .foregroundColor(.white)
            
            Text(loc.t("albumPickerPromptDesc"))
                .font(.system(size: 13))
                .foregroundColor(.white.opacity(0.65))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 36)
            
            Button(action: {
                showingImagePicker = true
            }) {
                HStack(spacing: 8) {
                    Image(systemName: "photo.fill")
                    Text(loc.t("openPhotoLibrary"))
                }
                .font(.system(size: 15, weight: .bold))
                .foregroundColor(.black)
                .padding(.horizontal, 24)
                .padding(.vertical, 12)
                .background(Color.snapGold)
                .cornerRadius(12)
            }
            Spacer()
        }
    }
    
    private func saveWatermarkedResult() {
        guard let original = sourceImage else { return }
        isProcessing = true
        
        DispatchQueue.global(qos: .userInitiated).async {
            // Register verification record
            let record = self.antiCounterfeitManager.createAndRegisterRecord(
                image: original,
                latitude: self.locationManager.latitude,
                longitude: self.locationManager.longitude,
                altitude: self.locationManager.altitude,
                address: self.locationManager.fullAddress,
                projectName: self.selectedTemplate.projectName,
                inspectorName: self.selectedTemplate.inspectorName
            )
            
            // Render high definition watermark
            let rendered = WatermarkRenderer.shared.renderWatermark(
                on: original,
                template: self.selectedTemplate,
                verificationRecord: record,
                timestamp: Date(),
                locationManager: self.locationManager
            )
            
            // Save to library
            self.libraryManager.saveWatermarkedPhoto(
                image: rendered,
                template: self.selectedTemplate,
                verificationRecord: record
            )
            
            DispatchQueue.main.async {
                self.isProcessing = false
                self.presentationMode.wrappedValue.dismiss()
            }
        }
    }
}
