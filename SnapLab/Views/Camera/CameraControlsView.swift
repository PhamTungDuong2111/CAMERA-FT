import SwiftUI

public enum CameraMode: String, CaseIterable {
    case photo = "ẢNH"
    case video = "VIDEO"
}

public struct CameraControlsView: View {
    @ObservedObject var cameraManager: CameraManager
    @Binding var currentMode: CameraMode
    let onCapturePhoto: () -> Void
    let onToggleVideo: () -> Void
    let onOpenGallery: () -> Void
    let onOpenTemplates: () -> Void
    let onOpenVerification: () -> Void
    let onOpenSettings: () -> Void
    
    public var body: some View {
        VStack(spacing: 12) {
            // Top Controls Bar
            topBarView
                .padding(.horizontal, 20)
                .padding(.top, 16)
            
            Spacer()
            
            // Zoom Selector Pill
            zoomPillView
                .padding(.bottom, 6)
            
            // Mode Switcher (ẢNH / VIDEO)
            modeSwitcherView
                .padding(.bottom, 8)
            
            // Bottom Action Deck (Gallery Thumb, Shutter, Flip Camera, Templates)
            bottomDeckView
                .padding(.horizontal, 24)
                .padding(.bottom, 28)
        }
    }
    
    // MARK: - Top Controls Bar
    private var topBarView: some View {
        HStack(spacing: 20) {
            // Flash Toggle
            Button(action: {
                cameraManager.toggleFlash()
            }) {
                Image(systemName: cameraManager.flashMode.iconName)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(cameraManager.flashMode == .off ? .white : Color.snapGold)
                    .frame(width: 40, height: 40)
                    .background(Color.black.opacity(0.45))
                    .clipShape(Circle())
            }
            
            // Aspect Ratio Toggle
            Button(action: {
                cycleAspectRatio()
            }) {
                Text(cameraManager.aspectRatio.rawValue)
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(.white)
                    .frame(width: 40, height: 40)
                    .background(Color.black.opacity(0.45))
                    .clipShape(Circle())
            }
            
            // Grid & Spirit Level
            Button(action: {
                cameraManager.showGrid.toggle()
                cameraManager.showSpiritLevel.toggle()
            }) {
                Image(systemName: cameraManager.showGrid ? "grid" : "circle.grid.2x2")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(cameraManager.showGrid ? Color.snapCyberCyan : .white.opacity(0.7))
                    .frame(width: 40, height: 40)
                    .background(Color.black.opacity(0.45))
                    .clipShape(Circle())
            }
            
            Spacer()
            
            // Anti-Counterfeiting Query Button
            Button(action: {
                onOpenVerification()
            }) {
                HStack(spacing: 5) {
                    Image(systemName: "checkmark.shield.fill")
                        .font(.system(size: 13))
                    Text("Đối soát")
                        .font(.system(size: 12, weight: .bold))
                }
                .foregroundColor(.white)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(Color.snapNeonGreen.opacity(0.85))
                .clipShape(Capsule())
            }
            
            // Settings Button
            Button(action: {
                onOpenSettings()
            }) {
                Image(systemName: "gearshape.fill")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(width: 40, height: 40)
                    .background(Color.black.opacity(0.45))
                    .clipShape(Circle())
            }
        }
    }
    
    // MARK: - Zoom Pill View
    private var zoomPillView: some View {
        HStack(spacing: 12) {
            zoomButton(label: "0.5x", factor: 0.5)
            zoomButton(label: "1x", factor: 1.0)
            zoomButton(label: "2x", factor: 2.0)
            zoomButton(label: "5x", factor: 5.0)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 6)
        .background(Color.black.opacity(0.45))
        .clipShape(Capsule())
    }
    
    private func zoomButton(label: String, factor: CGFloat) -> some View {
        let isSelected = abs(cameraManager.zoomFactor - factor) < 0.2
        return Button(action: {
            cameraManager.setZoom(factor: factor)
        }) {
            Text(label)
                .font(.system(size: 12, weight: isSelected ? .heavy : .medium))
                .foregroundColor(isSelected ? Color.snapGold : .white.opacity(0.8))
                .frame(width: 32, height: 24)
        }
    }
    
    // MARK: - Mode Switcher View
    private var modeSwitcherView: some View {
        HStack(spacing: 28) {
            ForEach(CameraMode.allCases, id: \.self) { mode in
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        currentMode = mode
                    }
                }) {
                    Text(mode.rawValue)
                        .font(.system(size: 14, weight: currentMode == mode ? .heavy : .bold))
                        .foregroundColor(currentMode == mode ? Color.snapGold : .white.opacity(0.6))
                        .shadow(color: .black.opacity(0.8), radius: 2)
                }
            }
        }
    }
    
    // MARK: - Bottom Deck View
    private var bottomDeckView: some View {
        HStack {
            // Gallery Thumbnail
            Button(action: {
                onOpenGallery()
            }) {
                ZStack {
                    if let thumb = cameraManager.lastCapturedThumbnail {
                        Image(uiImage: thumb)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 52, height: 52)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.white, lineWidth: 2))
                    } else {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.white.opacity(0.2))
                            .frame(width: 52, height: 52)
                            .overlay(Image(systemName: "photo.on.rectangle").foregroundColor(.white))
                    }
                }
            }
            .frame(width: 60)
            
            Spacer()
            
            // Shutter Button
            shutterButton
            
            Spacer()
            
            // Right Controls: Template Selector & Flip Camera
            HStack(spacing: 16) {
                // Template Drawer
                Button(action: {
                    onOpenTemplates()
                }) {
                    VStack(spacing: 2) {
                        Image(systemName: "square.stack.3d.down.right.fill")
                            .font(.system(size: 20))
                            .foregroundColor(.white)
                        Text("Mẫu dấu")
                            .font(.system(size: 9.5, weight: .bold))
                            .foregroundColor(.white)
                    }
                    .frame(width: 50, height: 50)
                    .background(Color.snapAccentOrange.opacity(0.85))
                    .clipShape(Circle())
                }
                
                // Flip Camera
                Button(action: {
                    cameraManager.flipCamera()
                }) {
                    Image(systemName: "camera.rotate.fill")
                        .font(.system(size: 22))
                        .foregroundColor(.white)
                        .frame(width: 48, height: 48)
                        .background(Color.black.opacity(0.45))
                        .clipShape(Circle())
                }
            }
        }
    }
    
    // MARK: - Shutter Button
    @ViewBuilder
    private var shutterButton: some View {
        if currentMode == .photo {
            // Photo Shutter
            Button(action: {
                onCapturePhoto()
            }) {
                ZStack {
                    Circle()
                        .stroke(Color.white, lineWidth: 4.5)
                        .frame(width: 76, height: 76)
                    
                    Circle()
                        .fill(Color.white)
                        .frame(width: 62, height: 62)
                }
            }
        } else {
            // Video Shutter
            Button(action: {
                onToggleVideo()
            }) {
                ZStack {
                    Circle()
                        .stroke(cameraManager.isRecordingVideo ? Color.snapDangerRed : Color.white, lineWidth: 4.5)
                        .frame(width: 76, height: 76)
                    
                    if cameraManager.isRecordingVideo {
                        RoundedRectangle(cornerRadius: 6)
                            .fill(Color.snapDangerRed)
                            .frame(width: 30, height: 30)
                    } else {
                        Circle()
                            .fill(Color.snapDangerRed)
                            .frame(width: 62, height: 62)
                    }
                }
            }
        }
    }
    
    private func cycleAspectRatio() {
        switch cameraManager.aspectRatio {
        case .ratio4_3: cameraManager.aspectRatio = .ratio16_9
        case .ratio16_9: cameraManager.aspectRatio = .ratio1_1
        case .ratio1_1: cameraManager.aspectRatio = .full
        case .full: cameraManager.aspectRatio = .ratio4_3
        }
    }
}
