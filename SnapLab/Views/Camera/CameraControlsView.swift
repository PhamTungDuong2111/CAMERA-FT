import SwiftUI

public enum CameraMode: String, CaseIterable {
    case photo
    case video
}

public struct CameraControlsView: View {
    @ObservedObject var cameraManager: CameraManager
    @ObservedObject var loc = LocalizationManager.shared
    @Binding var currentMode: CameraMode
    @Binding var activeFilter: PhotoFilter
    @Binding var activeSticker: PhotoSticker?
    
    let onCapturePhoto: () -> Void
    let onToggleVideo: () -> Void
    let onOpenGallery: () -> Void
    let onOpenTemplates: () -> Void
    let onOpenVerification: () -> Void
    let onOpenSettings: () -> Void
    
    @State private var showingFilterSelector = false
    @State private var showingStickerSelector = false
    
    public var body: some View {
        VStack(spacing: 8) {
            // 1. Top Controls Bar
            topBarView
                .padding(.horizontal, 16)
                .padding(.top, 14)
            
            Spacer()
            
            // 2. Filter Selector Row (Collapsible)
            if showingFilterSelector {
                filterSelectorRow
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            }
            
            // 3. Sticker Selector Row (Collapsible)
            if showingStickerSelector {
                stickerSelectorRow
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            }
            
            // 4. Zoom Selector Pill (.5x, 1x, 2x, 5x)
            zoomPillView
                .padding(.bottom, 4)
            
            // 5. Mode Switcher (ẢNH / VIDEO)
            modeSwitcherView
                .padding(.bottom, 6)
            
            // 6. Bottom Action Deck
            bottomDeckView
                .padding(.horizontal, 16)
                .padding(.bottom, 22)
        }
    }
    
    // MARK: - Top Controls Bar
    private var topBarView: some View {
        HStack(spacing: 12) {
            // Flash Toggle
            Button(action: { cameraManager.toggleFlash() }) {
                Image(systemName: cameraManager.flashMode.iconName)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(cameraManager.flashMode == .off ? .white : Color.snapGold)
                    .frame(width: 38, height: 38)
                    .background(Color.black.opacity(0.45))
                    .clipShape(Circle())
            }
            
            // Aspect Ratio Toggle (4:3 / 16:9)
            Button(action: { cycleAspectRatio() }) {
                Text(cameraManager.aspectRatio.rawValue)
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 10)
                    .frame(height: 32)
                    .background(Color.black.opacity(0.45))
                    .clipShape(Capsule())
            }
            
            // Grid Toggle
            Button(action: { cameraManager.toggleGrid() }) {
                Image(systemName: cameraManager.showGrid ? "grid" : "grid.circle")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(cameraManager.showGrid ? Color.snapGold : .white.opacity(0.55))
                    .frame(width: 38, height: 38)
                    .background(Color.black.opacity(0.45))
                    .clipShape(Circle())
            }
            
            // Filter Drawer Toggle (Magic Wand)
            Button(action: {
                withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                    showingFilterSelector.toggle()
                    if showingFilterSelector { showingStickerSelector = false }
                }
            }) {
                Image(systemName: "wand.and.stars")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(showingFilterSelector || activeFilter != .original ? Color.snapGold : .white)
                    .frame(width: 38, height: 38)
                    .background(Color.black.opacity(0.45))
                    .clipShape(Circle())
            }
            
            // Sticker Drawer Toggle (Star)
            Button(action: {
                withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                    showingStickerSelector.toggle()
                    if showingStickerSelector { showingFilterSelector = false }
                }
            }) {
                Image(systemName: "seal.fill")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(showingStickerSelector || activeSticker != nil ? Color.snapNeonGreen : .white)
                    .frame(width: 38, height: 38)
                    .background(Color.black.opacity(0.45))
                    .clipShape(Circle())
            }
            
            Spacer()
            
            // Language Toggle (VI / EN)
            Button(action: { loc.toggleLanguage() }) {
                HStack(spacing: 4) {
                    Text(loc.isVietnamese() ? "🇻🇳 VI" : "🇺🇸 EN")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.white)
                }
                .padding(.horizontal, 10)
                .frame(height: 32)
                .background(Color.black.opacity(0.45))
                .clipShape(Capsule())
            }
            
            // Settings Button
            Button(action: onOpenSettings) {
                Image(systemName: "gearshape.fill")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(width: 38, height: 38)
                    .background(Color.black.opacity(0.45))
                    .clipShape(Circle())
            }
        }
    }
    
    // MARK: - Filter Selector Carousel
    private var filterSelectorRow: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(PhotoFilter.allCases) { filter in
                    let isSelected = activeFilter == filter
                    Button(action: {
                        activeFilter = filter
                    }) {
                        Text(filter.displayName(isVi: loc.isVietnamese()))
                            .font(.system(size: 11, weight: isSelected ? .bold : .medium))
                            .foregroundColor(isSelected ? .black : .white)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 7)
                            .background(isSelected ? Color.snapGold : Color.black.opacity(0.65))
                            .clipShape(Capsule())
                            .overlay(
                                Capsule()
                                    .stroke(isSelected ? Color.white : Color.white.opacity(0.2), lineWidth: 1)
                            )
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 6)
        }
    }
    
    // MARK: - Sticker Selector Carousel
    private var stickerSelectorRow: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                // "None" option
                let isNone = activeSticker == nil
                Button(action: { activeSticker = nil }) {
                    Text(loc.t("noSticker"))
                        .font(.system(size: 11, weight: isNone ? .bold : .medium))
                        .foregroundColor(isNone ? .black : .white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 7)
                        .background(isNone ? Color.snapNeonGreen : Color.black.opacity(0.65))
                        .clipShape(Capsule())
                        .overlay(
                            Capsule().stroke(isNone ? Color.white : Color.white.opacity(0.2), lineWidth: 1)
                        )
                }
                
                ForEach(PhotoSticker.allCases) { sticker in
                    let isSelected = activeSticker == sticker
                    Button(action: { activeSticker = sticker }) {
                        Text(sticker.displayName(isVi: loc.isVietnamese()))
                            .font(.system(size: 11, weight: isSelected ? .bold : .medium))
                            .foregroundColor(isSelected ? .black : .white)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 7)
                            .background(isSelected ? sticker.badgeColor : Color.black.opacity(0.65))
                            .clipShape(Capsule())
                            .overlay(
                                Capsule().stroke(isSelected ? Color.white : Color.white.opacity(0.2), lineWidth: 1)
                            )
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 6)
        }
    }
    
    // MARK: - Zoom Selector Pill
    private var zoomPillView: some View {
        HStack(spacing: 4) {
            zoomButton(factor: 0.5, label: ".5")
            zoomButton(factor: 1.0, label: "1x")
            zoomButton(factor: 2.0, label: "2x")
            zoomButton(factor: 5.0, label: "5x")
        }
        .padding(3)
        .background(Color.black.opacity(0.45))
        .clipShape(Capsule())
    }
    
    private func zoomButton(factor: CGFloat, label: String) -> some View {
        let isSelected = abs(cameraManager.zoomFactor - factor) < 0.25
        return Button(action: {
            cameraManager.setZoom(factor)
        }) {
            Text(label)
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(isSelected ? .black : .white)
                .frame(width: 38, height: 30)
                .background(isSelected ? Color.snapGold : Color.clear)
                .clipShape(Circle())
        }
    }
    
    // MARK: - Camera Mode Switcher (ẢNH / VIDEO)
    private var modeSwitcherView: some View {
        HStack(spacing: 24) {
            Button(action: { currentMode = .photo }) {
                Text(loc.t("photo"))
                    .font(.system(size: 14, weight: currentMode == .photo ? .bold : .medium))
                    .foregroundColor(currentMode == .photo ? Color.snapGold : .white.opacity(0.6))
            }
            
            Button(action: { currentMode = .video }) {
                Text(loc.t("video"))
                    .font(.system(size: 14, weight: currentMode == .video ? .bold : .medium))
                    .foregroundColor(currentMode == .video ? Color.snapGold : .white.opacity(0.6))
            }
        }
    }
    
    // MARK: - Bottom Action Deck
    private var bottomDeckView: some View {
        HStack(spacing: 0) {
            // 1. Gallery Button
            bottomIconButton(
                title: loc.t("gallery"),
                systemImage: "photo.on.rectangle.angled",
                action: onOpenGallery
            )
            .frame(maxWidth: .infinity)
            
            // 2. Templates Button
            bottomIconButton(
                title: loc.t("templates"),
                systemImage: "square.3.layers.3d.down.right.fill",
                action: onOpenTemplates
            )
            .frame(maxWidth: .infinity)
            
            // 3. Shutter Capture Button
            shutterButton
                .frame(maxWidth: .infinity)
            
            // 4. Verify Query Button
            bottomIconButton(
                title: loc.t("verify"),
                systemImage: "checkmark.shield.fill",
                tint: Color.snapNeonGreen,
                action: onOpenVerification
            )
            .frame(maxWidth: .infinity)
            
            // 5. Flip Camera Button
            bottomIconButton(
                title: loc.t("flip"),
                systemImage: "camera.rotate.fill",
                action: { cameraManager.toggleCameraFacing() }
            )
            .frame(maxWidth: .infinity)
        }
    }
    
    // MARK: - Shutter Button with Mode morphing
    private var shutterButton: some View {
        Button(action: {
            if currentMode == .photo {
                onCapturePhoto()
            } else {
                onToggleVideo()
            }
        }) {
            ZStack {
                Circle()
                    .stroke(Color.white, lineWidth: 3.5)
                    .frame(width: 76, height: 76)
                
                if currentMode == .photo {
                    Circle()
                        .fill(Color.white)
                        .frame(width: 64, height: 64)
                } else {
                    // Video recording state: circle vs rounded square
                    if cameraManager.isRecordingVideo {
                        RoundedRectangle(cornerRadius: 6)
                            .fill(Color.snapDangerRed)
                            .frame(width: 28, height: 28)
                    } else {
                        Circle()
                            .fill(Color.snapDangerRed)
                            .frame(width: 58, height: 58)
                    }
                }
            }
        }
    }
    
    private func bottomIconButton(
        title: String,
        systemImage: String,
        tint: Color = .white,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            VStack(spacing: 4) {
                ZStack {
                    Circle()
                        .fill(Color.white.opacity(0.12))
                        .frame(width: 44, height: 44)
                    
                    Image(systemName: systemImage)
                        .font(.system(size: 20))
                        .foregroundColor(tint)
                }
                
                Text(title)
                    .font(.system(size: 10, weight: .medium))
                    .foregroundColor(.white.opacity(0.85))
                    .lineLimit(1)
            }
        }
    }
    
    private func cycleAspectRatio() {
        switch cameraManager.aspectRatio {
        case .ratio4_3:
            cameraManager.aspectRatio = .ratio16_9
        case .ratio16_9:
            cameraManager.aspectRatio = .ratio1_1
        case .ratio1_1:
            cameraManager.aspectRatio = .full
        case .full:
            cameraManager.aspectRatio = .ratio4_3
        }
    }
}