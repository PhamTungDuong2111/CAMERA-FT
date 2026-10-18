import SwiftUI
import PhotosUI

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
    
    // Bottom tabs: 0: None, 1: Templates, 2: Filters, 3: Stickers
    @State private var activeBottomDrawer: Int = 1
    
    public var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                if let image = sourceImage {
                    // Preview Canvas with Watermark Overlay
                    ZStack {
                        Image(uiImage: selectedTemplate.activeFilter.apply(to: image))
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .background(Color.black)
                        
                        WatermarkOverlayView(
                            template: selectedTemplate,
                            locationManager: locationManager,
                            verificationRecord: VerificationRecord(
                                id: "SL-ALBUM-" + String(Int.random(in: 1000...9999)),
                                addressString: locationManager.fullAddress,
                                projectName: selectedTemplate.projectName,
                                inspectorName: selectedTemplate.inspectorName
                            ),
                            onEditTapped: {
                                showingCustomizer = true
                            }
                        )
                    }
                    
                    // Bottom Selection Drawer
                    VStack(spacing: 0) {
                        if activeBottomDrawer == 1 {
                            // Templates Carousel
                            TemplateSelectorView(
                                selectedTemplate: $selectedTemplate,
                                templates: .constant(WatermarkTemplate.presets),
                                onCustomize: { _ in
                                    showingCustomizer = true
                                },
                                onDismiss: { activeBottomDrawer = 0 }
                            )
                            .frame(height: 180)
                        } else if activeBottomDrawer == 2 {
                            // Filters Carousel
                            filterPickerRow
                                .frame(height: 75)
                                .background(Color.snapCardDark)
                        } else if activeBottomDrawer == 3 {
                            // Stickers Carousel
                            stickerPickerRow
                                .frame(height: 75)
                                .background(Color.snapCardDark)
                        }
                        
                        // Bottom Toolbar (Templates, Filters, Stickers, Edit)
                        bottomEditorToolbar
                    }
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
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            } else {
                                HStack(spacing: 4) {
                                    Image(systemName: "checkmark.circle.fill")
                                    Text(loc.t("save"))
                                }
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(Color.snapAccentOrange)
                            }
                        }
                        .disabled(isProcessing)
                    }
                }
            }
            .sheet(isPresented: $showingImagePicker) {
                SystemImagePicker(selectedImage: $sourceImage) { img in
                    self.sourceImage = img
                }
            }
            .sheet(isPresented: $showingCustomizer) {
                TemplateEditorSheet(template: $selectedTemplate, onSave: { updated in
                    self.selectedTemplate = updated
                }, onDismiss: {
                    showingCustomizer = false
                })
            }
            .alert(isPresented: $showSuccessBanner) {
                Alert(
                    title: Text(loc.t("done")),
                    message: Text(loc.t("savedSuccessfully")),
                    dismissButton: .default(Text("OK")) {
                        presentationMode.wrappedValue.dismiss()
                    }
                )
            }
        }
    }
    
    // MARK: - Bottom Editor Toolbar
    private var bottomEditorToolbar: some View {
        HStack(spacing: 0) {
            tabButton(title: loc.t("templates"), icon: "square.3.layers.3d.down.right.fill", isSelected: activeBottomDrawer == 1) {
                withAnimation { activeBottomDrawer = activeBottomDrawer == 1 ? 0 : 1 }
            }
            
            tabButton(title: loc.t("filters"), icon: "wand.and.stars", isSelected: activeBottomDrawer == 2) {
                withAnimation { activeBottomDrawer = activeBottomDrawer == 2 ? 0 : 2 }
            }
            
            tabButton(title: loc.t("stickers"), icon: "seal.fill", isSelected: activeBottomDrawer == 3) {
                withAnimation { activeBottomDrawer = activeBottomDrawer == 3 ? 0 : 3 }
            }
            
            tabButton(title: loc.t("customize"), icon: "slider.horizontal.3", isSelected: false) {
                showingCustomizer = true
            }
        }
        .padding(.vertical, 10)
        .background(Color(red: 0.10, green: 0.11, blue: 0.14))
    }
    
    private func tabButton(title: String, icon: String, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 18))
                    .foregroundColor(isSelected ? Color.snapAccentOrange : .white.opacity(0.7))
                Text(title)
                    .font(.system(size: 11, weight: isSelected ? .bold : .medium))
                    .foregroundColor(isSelected ? Color.snapAccentOrange : .white.opacity(0.7))
            }
            .frame(maxWidth: .infinity)
        }
    }
    
    // MARK: - Filters Carousel
    private var filterPickerRow: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(PhotoFilter.allCases) { filter in
                    let isSelected = selectedTemplate.activeFilter == filter
                    Button(action: {
                        selectedTemplate.activeFilter = filter
                    }) {
                        Text(filter.displayName(isVi: loc.isVietnamese()))
                            .font(.system(size: 11, weight: isSelected ? .bold : .medium))
                            .foregroundColor(isSelected ? .black : .white)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 7)
                            .background(isSelected ? Color.snapGold : Color.black.opacity(0.5))
                            .clipShape(Capsule())
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
        }
    }
    
    // MARK: - Stickers Carousel
    private var stickerPickerRow: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                let isNone = selectedTemplate.activeSticker == nil
                Button(action: { selectedTemplate.activeSticker = nil }) {
                    Text(loc.t("noSticker"))
                        .font(.system(size: 11, weight: isNone ? .bold : .medium))
                        .foregroundColor(isNone ? .black : .white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 7)
                        .background(isNone ? Color.snapNeonGreen : Color.black.opacity(0.5))
                        .clipShape(Capsule())
                }
                
                ForEach(PhotoSticker.allCases) { sticker in
                    let isSelected = selectedTemplate.activeSticker == sticker
                    Button(action: { selectedTemplate.activeSticker = sticker }) {
                        Text(sticker.displayName(isVi: loc.isVietnamese()))
                            .font(.system(size: 11, weight: isSelected ? .bold : .medium))
                            .foregroundColor(isSelected ? .black : .white)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 7)
                            .background(isSelected ? sticker.badgeColor : Color.black.opacity(0.5))
                            .clipShape(Capsule())
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
        }
    }
    
    // MARK: - Empty Prompt
    private var emptyPickerPrompt: some View {
        VStack(spacing: 20) {
            Spacer()
            
            Image(systemName: "photo.badge.plus")
                .font(.system(size: 64))
                .foregroundColor(Color.snapAccentOrange.opacity(0.8))
            
            Text(loc.t("chooseFromLibrary"))
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.white)
            
            Button(action: { showingImagePicker = true }) {
                HStack(spacing: 8) {
                    Image(systemName: "photo.on.rectangle")
                    Text(loc.t("chooseFromLibrary"))
                }
                .font(.system(size: 15, weight: .bold))
                .foregroundColor(.white)
                .padding(.horizontal, 24)
                .padding(.vertical, 14)
                .background(Color.snapAccentOrange)
                .cornerRadius(12)
                .shadow(color: Color.snapAccentOrange.opacity(0.4), radius: 8, x: 0, y: 4)
            }
            
            Spacer()
        }
        .padding(.horizontal, 32)
    }
    
    // MARK: - Save Watermarked Photo
    private func saveWatermarkedResult() {
        guard let img = sourceImage else { return }
        isProcessing = true
        
        DispatchQueue.global(qos: .userInitiated).async {
            let record = antiCounterfeitManager.createAndRegisterRecord(
                image: img,
                timestamp: Date(),
                latitude: locationManager.latitude,
                longitude: locationManager.longitude,
                altitude: locationManager.altitude,
                address: locationManager.fullAddress,
                projectName: selectedTemplate.projectName,
                inspectorName: selectedTemplate.inspectorName
            )
            
            let result = WatermarkRenderer.shared.renderWatermark(
                on: img,
                template: selectedTemplate,
                verificationRecord: record,
                timestamp: record.timestamp,
                locationManager: locationManager
            )
            
            libraryManager.saveWatermarkedPhoto(
                image: result,
                template: selectedTemplate,
                verificationRecord: record
            )
            
            DispatchQueue.main.async {
                isProcessing = false
                showSuccessBanner = true
            }
        }
    }
}

// System UIImagePicker Wrapper
public struct SystemImagePicker: UIViewControllerRepresentable {
    @Binding var selectedImage: UIImage?
    let onImagePicked: (UIImage) -> Void
    
    public func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.sourceType = .photoLibrary
        return picker
    }
    
    public func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    public func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    public class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        let parent: SystemImagePicker
        
        init(_ parent: SystemImagePicker) {
            self.parent = parent
        }
        
        public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let image = info[.originalImage] as? UIImage {
                parent.selectedImage = image
                parent.onImagePicked(image)
            }
            picker.dismiss(animated: true)
        }
        
        public func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            picker.dismiss(animated: true)
        }
    }
}