import Foundation
import UIKit
import Photos
import AVFoundation
import Combine

public class PhotoLibraryManager: ObservableObject {
    public static let shared = PhotoLibraryManager()
    
    @Published public var mediaItems: [CapturedMedia] = []
    
    private let albumName = "SnapLab"
    private let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    private let indexFileKey = "SnapLab_MediaIndex.json"
    
    init() {
        loadMediaIndex()
    }
    
    // MARK: - Save Watermarked Photo
    public func saveWatermarkedPhoto(
        image: UIImage,
        template: WatermarkTemplate,
        verificationRecord: VerificationRecord?
    ) {
        let mediaId = UUID().uuidString
        let photoFileName = "\(mediaId).jpg"
        let thumbFileName = "\(mediaId)_thumb.jpg"
        
        let photoURL = documentsDirectory.appendingPathComponent(photoFileName)
        let thumbURL = documentsDirectory.appendingPathComponent(thumbFileName)
        
        // Write Full Resolution to disk
        if let data = image.jpegData(compressionQuality: 0.95) {
            try? data.write(to: photoURL)
        }
        
        // Write Thumbnail
        let thumbSize = CGSize(width: 300, height: 300)
        let renderer = UIGraphicsImageRenderer(size: thumbSize)
        let thumbImage = renderer.image { _ in
            image.draw(in: CGRect(origin: .zero, size: thumbSize))
        }
        if let thumbData = thumbImage.jpegData(compressionQuality: 0.8) {
            try? thumbData.write(to: thumbURL)
        }
        
        // Calculate file size
        let fileSize = (try? FileManager.default.attributesOfItem(atPath: photoURL.path)[.size] as? Int64) ?? 0
        
        let newItem = CapturedMedia(
            id: mediaId,
            type: .photo,
            localFileName: photoFileName,
            thumbnailFileName: thumbFileName,
            creationDate: Date(),
            templateId: template.id,
            templateName: template.name,
            verificationRecord: verificationRecord,
            durationSeconds: nil,
            fileSize: fileSize
        )
        
        DispatchQueue.main.async {
            self.mediaItems.insert(newItem, at: 0)
            self.saveMediaIndex()
        }
        
        // Also save to iOS Photos Library if authorized
        saveToSystemPhotoLibrary(image: image)
    }
    
    // MARK: - Save Recorded Video
    public func saveRecordedVideo(
        url: URL,
        template: WatermarkTemplate,
        verificationRecord: VerificationRecord?
    ) {
        let mediaId = UUID().uuidString
        let videoFileName = "\(mediaId).mp4"
        let thumbFileName = "\(mediaId)_thumb.jpg"
        
        let videoURL = documentsDirectory.appendingPathComponent(videoFileName)
        let thumbURL = documentsDirectory.appendingPathComponent(thumbFileName)
        
        // Copy temporary video file to documents directory
        try? FileManager.default.copyItem(at: url, to: videoURL)
        
        // Generate video thumbnail
        let asset = AVAsset(url: videoURL)
        let imageGenerator = AVAssetImageGenerator(asset: asset)
        imageGenerator.appliesPreferredTrackTransform = true
        let time = CMTime(seconds: 0.5, preferredTimescale: 600)
        let durationSec = CMTimeGetSeconds(asset.duration)
        
        if let cgImage = try? imageGenerator.copyCGImage(at: time, actualTime: nil) {
            let thumbImage = UIImage(cgImage: cgImage)
            if let data = thumbImage.jpegData(compressionQuality: 0.8) {
                try? data.write(to: thumbURL)
            }
        }
        
        let fileSize = (try? FileManager.default.attributesOfItem(atPath: videoURL.path)[.size] as? Int64) ?? 0
        
        let newItem = CapturedMedia(
            id: mediaId,
            type: .video,
            localFileName: videoFileName,
            thumbnailFileName: thumbFileName,
            creationDate: Date(),
            templateId: template.id,
            templateName: template.name,
            verificationRecord: verificationRecord,
            durationSeconds: durationSec.isFinite && durationSec > 0 ? durationSec : nil,
            fileSize: fileSize
        )
        
        DispatchQueue.main.async {
            self.mediaItems.insert(newItem, at: 0)
            self.saveMediaIndex()
        }
        
        // Save to system Photo Library
        PHPhotoLibrary.requestAuthorization { status in
            guard status == .authorized || status == .limited else { return }
            PHPhotoLibrary.shared().performChanges({
                let request = PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: videoURL)
                guard let placeholder = request?.placeholderForCreatedAsset else { return }
                
                let fetchOptions = PHFetchOptions()
                fetchOptions.predicate = NSPredicate(format: "title = %@", self.albumName)
                let collections = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .any, options: fetchOptions)
                if let album = collections.firstObject {
                    let albumChangeRequest = PHAssetCollectionChangeRequest(for: album)
                    albumChangeRequest?.addAssets([placeholder] as NSArray)
                } else {
                    let albumChangeRequest = PHAssetCollectionChangeRequest.creationRequestForAssetCollection(withTitle: self.albumName)
                    albumChangeRequest.addAssets([placeholder] as NSArray)
                }
            }, completionHandler: nil)
        }
    }
    
    // MARK: - Save System Photo Library
    private func saveToSystemPhotoLibrary(image: UIImage) {
        PHPhotoLibrary.requestAuthorization { status in
            guard status == .authorized || status == .limited else { return }
            
            PHPhotoLibrary.shared().performChanges({
                let request = PHAssetChangeRequest.creationRequestForAsset(from: image)
                guard let placeholder = request.placeholderForCreatedAsset else { return }
                
                let fetchOptions = PHFetchOptions()
                fetchOptions.predicate = NSPredicate(format: "title = %@", self.albumName)
                let collections = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .any, options: fetchOptions)
                
                if let album = collections.firstObject {
                    let albumChangeRequest = PHAssetCollectionChangeRequest(for: album)
                    albumChangeRequest?.addAssets([placeholder] as NSArray)
                } else {
                    let albumChangeRequest = PHAssetCollectionChangeRequest.creationRequestForAssetCollection(withTitle: self.albumName)
                    albumChangeRequest.addAssets([placeholder] as NSArray)
                }
            }, completionHandler: nil)
        }
    }
    
    // MARK: - Get Image for Item
    public func loadImage(for item: CapturedMedia) -> UIImage? {
        let fileURL = documentsDirectory.appendingPathComponent(item.localFileName)
        return UIImage(contentsOfFile: fileURL.path)
    }
    
    public func loadThumbnail(for item: CapturedMedia) -> UIImage? {
        let fileURL = documentsDirectory.appendingPathComponent(item.thumbnailFileName)
        return UIImage(contentsOfFile: fileURL.path)
    }
    
    public func getFileURL(for item: CapturedMedia) -> URL {
        return documentsDirectory.appendingPathComponent(item.localFileName)
    }
    
    // MARK: - Delete Media Item
    public func deleteItem(_ item: CapturedMedia) {
        let photoURL = documentsDirectory.appendingPathComponent(item.localFileName)
        let thumbURL = documentsDirectory.appendingPathComponent(item.thumbnailFileName)
        try? FileManager.default.removeItem(at: photoURL)
        try? FileManager.default.removeItem(at: thumbURL)
        
        DispatchQueue.main.async {
            self.mediaItems.removeAll { $0.id == item.id }
            self.saveMediaIndex()
        }
    }
    
    // MARK: - Persistence
    private func saveMediaIndex() {
        let indexURL = documentsDirectory.appendingPathComponent(indexFileKey)
        if let data = try? JSONEncoder().encode(mediaItems) {
            try? data.write(to: indexURL)
        }
    }
    
    private func loadMediaIndex() {
        let indexURL = documentsDirectory.appendingPathComponent(indexFileKey)
        if let data = try? Data(contentsOf: indexURL),
           let decoded = try? JSONDecoder().decode([CapturedMedia].self, from: data) {
            mediaItems = decoded
        }
    }
}