import SwiftUI
import CoreImage
import CoreImage.CIFilterBuiltins

public enum PhotoFilter: String, CaseIterable, Identifiable, Codable {
    case original = "original"
    case fleetingYears = "fleetingYears"
    case elegant = "elegant"
    case warmSunlight = "warmSunlight"
    case cinematic = "cinematic"
    case noirBW = "noirBW"
    case cartoon = "cartoon"
    case anaglyph3D = "anaglyph3D"
    case comicSketch = "comicSketch"
    case posterize = "posterize"
    
    public var id: String { rawValue }
    
    public var titleVi: String {
        switch self {
        case .original: return "Gốc"
        case .fleetingYears: return "Năm tháng"
        case .elegant: return "Thanh lịch"
        case .warmSunlight: return "Nắng ấm"
        case .cinematic: return "Điện ảnh"
        case .noirBW: return "Phim B&W"
        case .cartoon: return "Hoạt hình"
        case .anaglyph3D: return "Lập thể 3D"
        case .comicSketch: return "Phác thảo"
        case .posterize: return "Áp phích"
        }
    }
    
    public var titleEn: String {
        switch self {
        case .original: return "Original"
        case .fleetingYears: return "Fleeting Years"
        case .elegant: return "Elegant"
        case .warmSunlight: return "Warm Sunlight"
        case .cinematic: return "Cinematic"
        case .noirBW: return "Noir Film"
        case .cartoon: return "Cartoon AI"
        case .anaglyph3D: return "3D Pop"
        case .comicSketch: return "Comic Sketch"
        case .posterize: return "Pop Poster"
        }
    }
    
    public func displayName(isVi: Bool) -> String {
        return isVi ? titleVi : titleEn
    }
    
    public var category: String {
        switch self {
        case .original, .fleetingYears, .elegant, .warmSunlight, .cinematic, .noirBW:
            return "Phong cách"
        default:
            return "Sáng tạo"
        }
    }
    
    // MARK: - Core Image Processing
    public func apply(to image: UIImage) -> UIImage {
        if self == .original { return image }
        guard let ciImage = CIImage(image: image) else { return image }
        let context = CIContext(options: nil)
        
        var outputCIImage: CIImage?
        
        switch self {
        case .original:
            return image
            
        case .fleetingYears:
            // Sepia tone with contrast and warm shift
            if let sepia = CIFilter(name: "CISepiaTone") {
                sepia.setValue(ciImage, forKey: kCIInputImageKey)
                sepia.setValue(0.55, forKey: kCIInputIntensityKey)
                if let sepiaOut = sepia.outputImage,
                   let controls = CIFilter(name: "CIColorControls") {
                    controls.setValue(sepiaOut, forKey: kCIInputImageKey)
                    controls.setValue(1.15, forKey: kCIInputContrastKey)
                    controls.setValue(1.10, forKey: kCIInputSaturationKey)
                    outputCIImage = controls.outputImage
                }
            }
            
        case .elegant:
            // Soft contrast, luminous highlights
            if let controls = CIFilter(name: "CIColorControls") {
                controls.setValue(ciImage, forKey: kCIInputImageKey)
                controls.setValue(1.08, forKey: kCIInputContrastKey)
                controls.setValue(1.12, forKey: kCIInputSaturationKey)
                controls.setValue(0.04, forKey: kCIInputBrightnessKey)
                outputCIImage = controls.outputImage
            }
            
        case .warmSunlight:
            // Warm golden temperature shift
            if let temp = CIFilter(name: "CITemperatureAndTint") {
                temp.setValue(ciImage, forKey: kCIInputImageKey)
                temp.setValue(CIVector(x: 6500, y: 0), forKey: "inputNeutral")
                temp.setValue(CIVector(x: 7600, y: 15), forKey: "inputTargetNeutral")
                if let tempOut = temp.outputImage,
                   let controls = CIFilter(name: "CIColorControls") {
                    controls.setValue(tempOut, forKey: kCIInputImageKey)
                    controls.setValue(1.20, forKey: kCIInputSaturationKey)
                    outputCIImage = controls.outputImage
                }
            }
            
        case .cinematic:
            // Teal shadows, orange highlights, film curve
            if let filter = CIFilter(name: "CIPhotoEffectProcess") {
                filter.setValue(ciImage, forKey: kCIInputImageKey)
                outputCIImage = filter.outputImage
            }
            
        case .noirBW:
            // High-contrast dramatic black and white
            if let noir = CIFilter(name: "CIPhotoEffectNoir") {
                noir.setValue(ciImage, forKey: kCIInputImageKey)
                if let noirOut = noir.outputImage,
                   let controls = CIFilter(name: "CIColorControls") {
                    controls.setValue(noirOut, forKey: kCIInputImageKey)
                    controls.setValue(1.35, forKey: kCIInputContrastKey)
                    outputCIImage = controls.outputImage
                }
            }
            
        case .cartoon:
            // Comic/Posterize edges
            if let comic = CIFilter(name: "CIComicEffect") {
                comic.setValue(ciImage, forKey: kCIInputImageKey)
                outputCIImage = comic.outputImage
            }
            
        case .anaglyph3D:
            // 3D chromatic shift via color matrix
            if let filter = CIFilter(name: "CIColorMatrix") {
                filter.setValue(ciImage, forKey: kCIInputImageKey)
                filter.setValue(CIVector(x: 1.25, y: 0, z: 0, w: 0), forKey: "inputRVector")
                filter.setValue(CIVector(x: 0, y: 0.95, z: 0.15, w: 0), forKey: "inputGVector")
                filter.setValue(CIVector(x: 0.15, y: 0, z: 1.30, w: 0), forKey: "inputBVector")
                outputCIImage = filter.outputImage
            }
            
        case .comicSketch:
            // Line sketch effect
            if let sketch = CIFilter(name: "CILineOverlay") {
                sketch.setValue(ciImage, forKey: kCIInputImageKey)
                sketch.setValue(0.06, forKey: "inputNRNoiseLevel")
                sketch.setValue(0.70, forKey: "inputNRSharpness")
                sketch.setValue(0.85, forKey: "inputEdgeIntensity")
                outputCIImage = sketch.outputImage
            }
            
        case .posterize:
            // Posterize color levels
            if let post = CIFilter(name: "CIColorPosterize") {
                post.setValue(ciImage, forKey: kCIInputImageKey)
                post.setValue(6.0, forKey: "inputLevels")
                outputCIImage = post.outputImage
            }
        }
        
        guard let output = outputCIImage,
              let cgImage = context.createCGImage(output, from: output.extent) else {
            return image
        }
        
        return UIImage(cgImage: cgImage, scale: image.scale, orientation: image.imageOrientation)
    }
}