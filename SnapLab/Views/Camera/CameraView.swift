import SwiftUI
import AudioToolbox

public struct CameraView: View {
    @StateObject private var cameraManager = CameraManager.shared
    @StateObject private var locationManager = LocationWeatherManager.shared
    @StateObject private var antiCounterfeitManager = AntiCounterfeitingManager.shared
    @StateObject private var photoLibraryManager = PhotoLibraryManager.shared
    
    @State private var currentMode: CameraMode = .photo
    @State private var selectedTemplate: WatermarkTemplate = WatermarkTemplate.presets[0]
    @State private var allTemplates: [WatermarkTemplate] = WatermarkTemplate.presets
    
    // Sheets and Modals
    @State private var showingTemplateDrawer = false
    @State private var showingTemplateCustomizer = false
    @State private var showingVerificationView = false
    @State private var showingGallery = false
    @State private var showingSettings = false
    
    // Visual flash on capture
    @State private var flashOpacity: Double = 0.0
    
    public var body: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all)
            
            // 1. Live Camera Viewfinder Layer
            viewfinderLayer
                .edgesIgnoringSafeArea(.all)
            
            // 2. Real-Time Watermark Overlay Layer
            WatermarkOverlayView(
                template: selectedTemplate,
                locationManager: locationManager,
                verificationRecord: currentPreviewVerificationRecord,
                onEditTapped: {
                    showingTemplateCustomizer = true
                }
            )
            .allowsHitTesting(true)
            
            // 3. Shutter Flash Overlay
            Color.white
                .opacity(flashOpacity)
                .edgesIgnoringSafeArea(.all)
                .allowsHitTesting(false)
            
            // 4. Video Recording Timer Indicator
            if cameraManager.isRecordingVideo {
                VStack {
                    recordingHeaderView
                        .padding(.top, 56)
                    Spacer()
                }
            }
            
            // 5. Controls Overlay Deck (Top bar, Zoom, Shutter, Gallery, Flip)
            CameraControlsView(
                cameraManager: cameraManager,
                currentMode: $currentMode,
                onCapturePhoto: performPhotoCapture,
                onToggleVideo: performVideoToggle,
                onOpenGallery: { showingGallery = true },
                onOpenTemplates: { showingTemplateDrawer = true },
                onOpenVerification: { showingVerificationView = true },
                onOpenSettings: { showingSettings = true }
            )
            
            // 6. Sliding Template Drawer
            if showingTemplateDrawer {
                VStack {
                    Spacer()
                    TemplateSelectorView(
                        selectedTemplate: $selectedTemplate,
                        templates: $allTemplates,
                        onCustomize: { tmpl in
                            selectedTemplate = tmpl
                            showingTemplateCustomizer = true
                        },
                        onDismiss: {
                            withAnimation(.spring()) {
                                showingTemplateDrawer = false
                            }
                        }
                    )
                    .transition(.move(edge: .bottom))
                    .padding(.bottom, 90)
                    .padding(.horizontal, 10)
                }
            }
        }
        .onAppear {
            setupCallbacks()
        }
        // Sheets
        .sheet(isPresented: $showingTemplateCustomizer) {
            TemplateEditorSheet(template: $selectedTemplate, onSave: { updated in
                self.selectedTemplate = updated
            }, onDismiss: {
                showingTemplateCustomizer = false
            })
        }
        .sheet(isPresented: $showingVerificationView) {
            AntiCounterfeitQueryView()
        }
        .sheet(isPresented: $showingGallery) {
            GalleryView()
        }
        .sheet(isPresented: $showingSettings) {
            SettingsView()
        }
    }
    
    // MARK: - Viewfinder Layer
    @ViewBuilder
    private var viewfinderLayer: some View {
        if cameraManager.isUsingSyntheticCamera || !cameraManager.isSessionRunning {
            SyntheticCameraPreviewView(
                showGrid: cameraManager.showGrid,
                showLevel: cameraManager.showSpiritLevel
            )
        } else {
            ZStack {
                CameraPreviewView(cameraManager: cameraManager)
                if cameraManager.showGrid {
                    GridOverlayView()
                }
            }
        }
    }
    
    // MARK: - Video Recording Header
    private var recordingHeaderView: some View {
        HStack(spacing: 8) {
            Circle()
                .fill(Color.snapDangerRed)
                .frame(width: 10, height: 10)
            
            let minutes = Int(cameraManager.recordingDuration) / 60
            let seconds = Int(cameraManager.recordingDuration) % 60
            Text(String(format: "%02d:%02d", minutes, seconds))
                .font(.system(size: 14, weight: .heavy, design: .monospaced))
                .foregroundColor(.white)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 6)
        .background(Color.black.opacity(0.7))
        .clipShape(Capsule())
    }
    
    private var currentPreviewVerificationRecord: VerificationRecord {
        VerificationRecord(
            id: "SL-LIVE-" + String(Int.random(in: 1000...9999)),
            timestamp: Date(),
            latitude: locationManager.latitude,
            longitude: locationManager.longitude,
            altitude: locationManager.altitude,
            addressString: locationManager.fullAddress,
            projectName: selectedTemplate.projectName,
            inspectorName: selectedTemplate.inspectorName
        )
    }
    
    // MARK: - Capture Callbacks
    private func setupCallbacks() {
        cameraManager.onPhotoCaptured = { [self] capturedImage in
            processCapturedPhoto(capturedImage)
        }
        
        cameraManager.onVideoRecorded = { [self] videoURL in
            processCapturedVideo(videoURL)
        }
    }
    
    // MARK: - Photo Capture Logic
    private func performPhotoCapture() {
        // Trigger visual flash
        withAnimation(.easeIn(duration: 0.08)) {
            flashOpacity = 0.85
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.12) {
            withAnimation(.easeOut(duration: 0.25)) {
                flashOpacity = 0.0
            }
        }
        
        // Haptic feedback
        AudioServicesPlaySystemSound(1108) // Camera shutter sound
        
        cameraManager.capturePhoto()
    }
    
    private func processCapturedPhoto(_ rawImage: UIImage) {
        DispatchQueue.global(qos: .userInitiated).async {
            // 1. Create authoritative Anti-Counterfeiting verification record with SHA-256
            let record = antiCounterfeitManager.createAndRegisterRecord(
                image: rawImage,
                timestamp: Date(),
                latitude: locationManager.latitude,
                longitude: locationManager.longitude,
                altitude: locationManager.altitude,
                address: locationManager.fullAddress,
                projectName: selectedTemplate.projectName,
                inspectorName: selectedTemplate.inspectorName
            )
            
            // 2. Render high resolution watermark onto raw image
            let watermarkedImage = WatermarkRenderer.shared.renderWatermark(
                on: rawImage,
                template: selectedTemplate,
                verificationRecord: record,
                timestamp: record.timestamp,
                locationManager: locationManager
            )
            
            // 3. Save to local disk & photo library
            photoLibraryManager.saveWatermarkedPhoto(
                image: watermarkedImage,
                template: selectedTemplate,
                verificationRecord: record
            )
        }
    }
    
    // MARK: - Video Toggle Logic
    private func performVideoToggle() {
        cameraManager.toggleVideoRecording()
    }
    
    private func processCapturedVideo(_ url: URL) {
        // Handle video save to library
        let dummyThumb = ImageUtilities.generateSyntheticScene()
        photoLibraryManager.saveWatermarkedPhoto(
            image: dummyThumb,
            template: selectedTemplate,
            verificationRecord: currentPreviewVerificationRecord
        )
    }
}
