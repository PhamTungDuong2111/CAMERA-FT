import SwiftUI
import CoreImage
import CoreImage.CIFilterBuiltins

#if canImport(UIKit)
import UIKit
#endif

public struct ImageUtilities {
    
    // MARK: - Generate QR Code UIImage
    public static func generateQRCode(from string: String, size: CGSize = CGSize(width: 140, height: 140)) -> UIImage? {
        let context = CIContext()
        let filter = CIFilter.qrCodeGenerator()
        let data = Data(string.utf8)
        filter.setValue(data, forKey: "inputMessage")
        filter.setValue("M", forKey: "inputCorrectionLevel")
        
        guard let outputImage = filter.outputImage else { return nil }
        
        // Scale up crisply without blurring
        let scaleX = size.width / outputImage.extent.size.width
        let scaleY = size.height / outputImage.extent.size.height
        let transformedImage = outputImage.transformed(by: CGAffineTransform(scaleX: scaleX, y: scaleY))
        
        if let cgImage = context.createCGImage(transformedImage, from: transformedImage.extent) {
            return UIImage(cgImage: cgImage)
        }
        return nil
    }
    
    // MARK: - Fix Orientation
    public static func fixOrientation(for image: UIImage) -> UIImage {
        if image.imageOrientation == .up {
            return image
        }
        
        UIGraphicsBeginImageContextWithOptions(image.size, false, image.scale)
        image.draw(in: CGRect(origin: .zero, size: image.size))
        let normalizedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return normalizedImage ?? image
    }
    
    // MARK: - Generate Synthetic Test Photo for Simulator / Mac without webcam
    public static func generateSyntheticScene(
        size: CGSize = CGSize(width: 1920, height: 1440),
        sceneTitle: String = "SnapLab HD Live View"
    ) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { ctx in
            let bounds = CGRect(origin: .zero, size: size)
            
            // Draw realistic architectural/construction gradient sky and ground
            let colors = [
                UIColor(red: 0.12, green: 0.35, blue: 0.65, alpha: 1.0).cgColor,
                UIColor(red: 0.45, green: 0.65, blue: 0.85, alpha: 1.0).cgColor,
                UIColor(red: 0.85, green: 0.75, blue: 0.60, alpha: 1.0).cgColor,
                UIColor(red: 0.30, green: 0.32, blue: 0.35, alpha: 1.0).cgColor
            ] as CFArray
            let colorSpace = CGColorSpaceCreateDeviceRGB()
            let locations: [CGFloat] = [0.0, 0.45, 0.70, 1.0]
            
            if let gradient = CGGradient(colorsSpace: colorSpace, colors: colors, locations: locations) {
                ctx.cgContext.drawLinearGradient(
                    gradient,
                    start: CGPoint(x: bounds.midX, y: 0),
                    end: CGPoint(x: bounds.midX, y: bounds.height),
                    options: []
                )
            }
            
            // Draw grid pattern (Engineering grid)
            ctx.cgContext.setStrokeColor(UIColor.white.withAlphaComponent(0.15).cgColor)
            ctx.cgContext.setLineWidth(2.0)
            let step: CGFloat = 120
            var x: CGFloat = 0
            while x < size.width {
                ctx.cgContext.move(to: CGPoint(x: x, y: 0))
                ctx.cgContext.addLine(to: CGPoint(x: x, y: size.height))
                x += step
            }
            var y: CGFloat = 0
            while y < size.height {
                ctx.cgContext.move(to: CGPoint(x: 0, y: y))
                ctx.cgContext.addLine(to: CGPoint(x: size.width, y: y))
                y += step
            }
            ctx.cgContext.strokePath()
            
            // Draw Horizon line and level mark
            let horizonY = size.height * 0.55
            ctx.cgContext.setStrokeColor(UIColor(red: 1.0, green: 0.78, blue: 0.12, alpha: 0.7).cgColor)
            ctx.cgContext.setLineWidth(3.0)
            ctx.cgContext.move(to: CGPoint(x: 100, y: horizonY))
            ctx.cgContext.addLine(to: CGPoint(x: size.width - 100, y: horizonY))
            ctx.cgContext.strokePath()
            
            // Draw Center Crosshair
            let centerX = size.width / 2
            let centerY = size.height / 2
            ctx.cgContext.setStrokeColor(UIColor.white.withAlphaComponent(0.6).cgColor)
            ctx.cgContext.strokeEllipse(in: CGRect(x: centerX - 80, y: centerY - 80, width: 160, height: 160))
            ctx.cgContext.move(to: CGPoint(x: centerX - 110, y: centerY))
            ctx.cgContext.addLine(to: CGPoint(x: centerX + 110, y: centerY))
            ctx.cgContext.move(to: CGPoint(x: centerX, y: centerY - 110))
            ctx.cgContext.addLine(to: CGPoint(x: centerX, y: centerY + 110))
            ctx.cgContext.strokePath()
            
            // Watermark prompt text
            let text = "SNAPLAB HIGH RESOLUTION CAMERA FEED\n\(sceneTitle)\nSimulated Viewport • 1920x1440 HD"
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.alignment = .center
            let attrs: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 32, weight: .bold),
                .foregroundColor: UIColor.white.withAlphaComponent(0.75),
                .paragraphStyle: paragraphStyle
            ]
            let textRect = CGRect(x: 100, y: centerY + 120, width: size.width - 200, height: 150)
            (text as NSString).draw(in: textRect, withAttributes: attrs)
        }
    }
}
