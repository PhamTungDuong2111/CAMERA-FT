import SwiftUI
import AVFoundation

public struct CameraPreviewView: UIViewRepresentable {
    @ObservedObject var cameraManager: CameraManager
    
    public init(cameraManager: CameraManager) {
        self.cameraManager = cameraManager
    }
    
    public func makeUIView(context: Context) -> CameraPreviewUIView {
        let view = CameraPreviewUIView()
        view.videoPreviewLayer.session = cameraManager.captureSession
        view.videoPreviewLayer.videoGravity = .resizeAspectFill
        return view
    }
    
    public func updateUIView(_ uiView: CameraPreviewUIView, context: Context) {
        if uiView.videoPreviewLayer.session != cameraManager.captureSession {
            uiView.videoPreviewLayer.session = cameraManager.captureSession
        }
    }
}

public class CameraPreviewUIView: UIView {
    override public class var layerClass: AnyClass {
        return AVCaptureVideoPreviewLayer.self
    }
    
    public var videoPreviewLayer: AVCaptureVideoPreviewLayer {
        return layer as! AVCaptureVideoPreviewLayer
    }
}

// MARK: - Synthetic Camera View for Mac Simulator or Restricted Hardware
public struct SyntheticCameraPreviewView: View {
    @State private var phase: CGFloat = 0
    let showGrid: Bool
    let showLevel: Bool
    
    public var body: some View {
        GeometryReader { proxy in
            ZStack {
                // Animated realistic architectural scene background
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(red: 0.10, green: 0.28, blue: 0.52),
                        Color(red: 0.35, green: 0.55, blue: 0.75),
                        Color(red: 0.80, green: 0.72, blue: 0.58),
                        Color(red: 0.25, green: 0.26, blue: 0.28)
                    ]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                
                // Horizon and Level Line
                if showLevel {
                    VStack {
                        Spacer()
                        HStack(spacing: 8) {
                            Rectangle()
                                .fill(Color.snapGold.opacity(0.8))
                                .frame(height: 2)
                            
                            Circle()
                                .stroke(Color.snapGold, lineWidth: 2)
                                .frame(width: 14, height: 14)
                            
                            Rectangle()
                                .fill(Color.snapGold.opacity(0.8))
                                .frame(height: 2)
                        }
                        .padding(.horizontal, 40)
                        Spacer()
                    }
                }
                
                // Rule of Thirds Grid
                if showGrid {
                    GridOverlayView()
                }
                
                // Synthetic Mode Indicator
                VStack {
                    HStack {
                        Label(LocalizationManager.shared.t("simulatedCamera"), systemImage: "sparkles.tv")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 4)
                            .background(Color.black.opacity(0.55))
                            .clipShape(Capsule())
                        Spacer()
                    }
                    .padding(.top, 54)
                    .padding(.leading, 16)
                    Spacer()
                }
            }
        }
    }
}

public struct GridOverlayView: View {
    public var body: some View {
        GeometryReader { geo in
            Path { path in
                // Vertical lines
                let w = geo.size.width
                let h = geo.size.height
                path.move(to: CGPoint(x: w / 3, y: 0))
                path.addLine(to: CGPoint(x: w / 3, y: h))
                
                path.move(to: CGPoint(x: (w / 3) * 2, y: 0))
                path.addLine(to: CGPoint(x: (w / 3) * 2, y: h))
                
                // Horizontal lines
                path.move(to: CGPoint(x: 0, y: h / 3))
                path.addLine(to: CGPoint(x: w, y: h / 3))
                
                path.move(to: CGPoint(x: 0, y: (h / 3) * 2))
                path.addLine(to: CGPoint(x: w, y: (h / 3) * 2))
            }
            .stroke(Color.white.opacity(0.22), lineWidth: 1)
        }
    }
}
