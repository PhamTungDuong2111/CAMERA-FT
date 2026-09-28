import Foundation
import AVFoundation
import UIKit
import Combine

public enum CameraPosition {
    case back
    case front
}

public enum FlashMode: String, CaseIterable {
    case off = "Tắt"
    case on = "Bật"
    case auto = "Tự động"
    
    public var iconName: String {
        switch self {
        case .off: return "bolt.slash.fill"
        case .on: return "bolt.fill"
        case .auto: return "bolt.badge.a.fill"
        }
    }
}

public enum CameraAspectRatio: String, CaseIterable {
    case ratio4_3 = "4:3"
    case ratio16_9 = "16:9"
    case ratio1_1 = "1:1"
    case full = "Full"
}

public class CameraManager: NSObject, ObservableObject {
    public static let shared = CameraManager()
    
    // AVCaptureSession
    public let captureSession = AVCaptureSession()
    private var currentDevice: AVCaptureDevice?
    private var videoInput: AVCaptureDeviceInput?
    private let photoOutput = AVCapturePhotoOutput()
    private let movieOutput = AVCaptureMovieFileOutput()
    
    // Published State
    @Published public var isSessionRunning = false
    @Published public var isRecordingVideo = false
    @Published public var recordingDuration: TimeInterval = 0
    @Published public var flashMode: FlashMode = .auto
    @Published public var currentPosition: CameraPosition = .back
    @Published public var aspectRatio: CameraAspectRatio = .ratio4_3
    @Published public var zoomFactor: CGFloat = 1.0
    @Published public var maxZoomFactor: CGFloat = 5.0
    @Published public var showGrid: Bool = true
    @Published public var showSpiritLevel: Bool = true
    @Published public var isUsingSyntheticCamera: Bool = false
    @Published public var lastCapturedThumbnail: UIImage?
    
    // Callbacks
    public var onPhotoCaptured: ((UIImage) -> Void)?
    public var onVideoRecorded: ((URL) -> Void)?
    
    private var recordingTimer: AnyCancellable?
    private let sessionQueue = DispatchQueue(label: "com.snaplab.camera.sessionQueue")
    
    override public init() {
        super.init()
        checkPermissionsAndConfigure()
    }
    
    public func checkPermissionsAndConfigure() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            setupCaptureSession()
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
                if granted {
                    self?.setupCaptureSession()
                } else {
                    DispatchQueue.main.async {
                        self?.isUsingSyntheticCamera = true
                    }
                }
            }
        default:
            DispatchQueue.main.async {
                self.isUsingSyntheticCamera = true
            }
        }
    }
    
    // MARK: - Capture Session Setup
    private func setupCaptureSession() {
        sessionQueue.async { [weak self] in
            guard let self = self else { return }
            
            self.captureSession.beginConfiguration()
            self.captureSession.sessionPreset = .photo
            
            // Choose camera device
            let device = self.getBestCamera(for: .back)
            guard let camera = device,
                  let input = try? AVCaptureDeviceInput(device: camera) else {
                self.captureSession.commitConfiguration()
                DispatchQueue.main.async {
                    self.isUsingSyntheticCamera = true
                }
                return
            }
            
            self.currentDevice = camera
            self.videoInput = input
            
            if self.captureSession.canAddInput(input) {
                self.captureSession.addInput(input)
            }
            
            // Photo Output
            if self.captureSession.canAddOutput(self.photoOutput) {
                self.photoOutput.maxPhotoQualityPrioritization = .quality
                self.captureSession.addOutput(self.photoOutput)
            }
            
            // Movie Output
            if self.captureSession.canAddOutput(self.movieOutput) {
                self.captureSession.addOutput(self.movieOutput)
            }
            
            self.captureSession.commitConfiguration()
            
            self.captureSession.startRunning()
            DispatchQueue.main.async {
                self.isSessionRunning = self.captureSession.isRunning
                self.isUsingSyntheticCamera = !self.captureSession.isRunning
            }
        }
    }
    
    private func getBestCamera(for position: CameraPosition) -> AVCaptureDevice? {
        let avPosition: AVCaptureDevice.Position = (position == .back) ? .back : .front
        
        let deviceTypes: [AVCaptureDevice.DeviceType] = [
            .builtInTripleCamera,
            .builtInDualWideCamera,
            .builtInDualCamera,
            .builtInWideAngleCamera
        ]
        
        let discovery = AVCaptureDevice.DiscoverySession(
            deviceTypes: deviceTypes,
            mediaType: .video,
            position: avPosition
        )
        
        return discovery.devices.first ?? AVCaptureDevice.default(for: .video)
    }
    
    // MARK: - Flip Camera
    public func flipCamera() {
        sessionQueue.async { [weak self] in
            guard let self = self else { return }
            let newPosition: CameraPosition = (self.currentPosition == .back) ? .front : .back
            
            guard let newDevice = self.getBestCamera(for: newPosition),
                  let newInput = try? AVCaptureDeviceInput(device: newDevice) else {
                return
            }
            
            self.captureSession.beginConfiguration()
            if let oldInput = self.videoInput {
                self.captureSession.removeInput(oldInput)
            }
            
            if self.captureSession.canAddInput(newInput) {
                self.captureSession.addInput(newInput)
                self.videoInput = newInput
                self.currentDevice = newDevice
            }
            self.captureSession.commitConfiguration()
            
            DispatchQueue.main.async {
                self.currentPosition = newPosition
                self.zoomFactor = 1.0
            }
        }
    }
    
    // MARK: - Zoom Control
    public func setZoom(factor: CGFloat) {
        guard let device = currentDevice else { return }
        do {
            try device.lockForConfiguration()
            let clamped = max(1.0, min(factor, min(device.activeFormat.videoMaxZoomFactor, 5.0)))
            device.videoZoomFactor = clamped
            device.unlockForConfiguration()
            DispatchQueue.main.async {
                self.zoomFactor = clamped
            }
        } catch {
            print("Zoom error: \(error)")
        }
    }
    
    // MARK: - Flash Control
    public func toggleFlash() {
        switch flashMode {
        case .off: flashMode = .on
        case .on: flashMode = .auto
        case .auto: flashMode = .off
        }
    }
    
    // MARK: - Capture Photo
    public func capturePhoto() {
        if isUsingSyntheticCamera || !captureSession.isRunning {
            // Simulator or Mac fallback: produce high resolution test frame
            let synthetic = ImageUtilities.generateSyntheticScene()
            DispatchQueue.main.async {
                self.lastCapturedThumbnail = synthetic
                self.onPhotoCaptured?(synthetic)
            }
            return
        }
        
        let settings = AVCapturePhotoSettings()
        if let device = currentDevice, device.hasFlash {
            switch flashMode {
            case .on: settings.flashMode = .on
            case .auto: settings.flashMode = .auto
            case .off: settings.flashMode = .off
            }
        }
        settings.photoQualityPrioritization = .quality
        photoOutput.capturePhoto(with: settings, delegate: self)
    }
    
    // MARK: - Video Recording
    public func toggleVideoRecording() {
        if isRecordingVideo {
            stopVideoRecording()
        } else {
            startVideoRecording()
        }
    }
    
    public func startVideoRecording() {
        guard !isRecordingVideo else { return }
        
        let outputFileName = UUID().uuidString + ".mp4"
        let outputFilePath = (NSTemporaryDirectory() as NSString).appendingPathComponent(outputFileName)
        let outputURL = URL(fileURLWithPath: outputFilePath)
        
        if isUsingSyntheticCamera || !captureSession.isRunning {
            // Synthetic video recording
            self.isRecordingVideo = true
            self.recordingDuration = 0
            self.recordingTimer = Timer.publish(every: 1.0, on: .main, in: .common)
                .autoconnect()
                .sink { [weak self] _ in
                    self?.recordingDuration += 1
                }
            return
        }
        
        movieOutput.startRecording(to: outputURL, recordingDelegate: self)
        DispatchQueue.main.async {
            self.isRecordingVideo = true
            self.recordingDuration = 0
            self.recordingTimer = Timer.publish(every: 1.0, on: .main, in: .common)
                .autoconnect()
                .sink { [weak self] _ in
                    self?.recordingDuration += 1
                }
        }
    }
    
    public func stopVideoRecording() {
        guard isRecordingVideo else { return }
        recordingTimer?.cancel()
        recordingTimer = nil
        
        if isUsingSyntheticCamera || !captureSession.isRunning {
            DispatchQueue.main.async {
                self.isRecordingVideo = false
                let dummyURL = URL(fileURLWithPath: (NSTemporaryDirectory() as NSString).appendingPathComponent("demo_video.mp4"))
                self.onVideoRecorded?(dummyURL)
            }
            return
        }
        
        movieOutput.stopRecording()
        DispatchQueue.main.async {
            self.isRecordingVideo = false
        }
    }
}

// MARK: - AVCapturePhotoCaptureDelegate
extension CameraManager: AVCapturePhotoCaptureDelegate {
    public func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        guard error == nil,
              let data = photo.fileDataRepresentation(),
              let image = UIImage(data: data) else {
            print("Capture failed: \(String(describing: error))")
            return
        }
        
        let fixed = ImageUtilities.fixOrientation(for: image)
        DispatchQueue.main.async {
            self.lastCapturedThumbnail = fixed
            self.onPhotoCaptured?(fixed)
        }
    }
}

// MARK: - AVCaptureFileOutputRecordingDelegate
extension CameraManager: AVCaptureFileOutputRecordingDelegate {
    public func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
        guard error == nil else {
            print("Video recording failed: \(String(describing: error))")
            return
        }
        DispatchQueue.main.async {
            self.onVideoRecorded?(outputFileURL)
        }
    }
}
