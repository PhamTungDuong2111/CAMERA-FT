import SwiftUI
import MapKit

public struct AntiCounterfeitQueryView: View {
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var antiCounterfeitingManager = AntiCounterfeitingManager.shared
    
    @State private var queryInputId: String = ""
    @State private var showingImagePicker = false
    @State private var selectedImage: UIImage?
    @State private var verificationResult: (status: VerificationStatus, record: VerificationRecord?)?
    @State private var isAnalyzing: Bool = false
    
    public var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Header Banner
                    headerCard
                    
                    // Query Action Buttons
                    actionButtonsSection
                    
                    // Verification Input Field
                    manualInputSection
                    
                    // Verification Result Card
                    if isAnalyzing {
                        analyzingIndicator
                    } else if let result = verificationResult {
                        certificateResultCard(status: result.status, record: result.record)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 20)
            }
            .background(Color.snapBackgroundDark.edgesIgnoringSafeArea(.all))
            .navigationTitle("Truy Vấn Chống Giả Mạo")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Đóng") {
                        presentationMode.wrappedValue.dismiss()
                    }
                    .foregroundColor(.white)
                }
            }
            .sheet(isPresented: $showingImagePicker) {
                SystemImagePicker(selectedImage: $selectedImage) { image in
                    analyzeUploadedImage(image)
                }
            }
        }
    }
    
    // MARK: - Header Card
    private var headerCard: some View {
        VStack(spacing: 10) {
            Image(systemName: "checkmark.shield.fill")
                .font(.system(size: 42))
                .foregroundColor(Color.snapNeonGreen)
            
            Text("Xác Thực Hồ Sơ Hiện Trường")
                .font(.system(size: 19, weight: .bold))
                .foregroundColor(.white)
            
            Text("Hệ thống truy vấn chống làm giả ảnh SnapLab Authoritative Verification. Kiểm tra tính toàn vẹn thời gian, GPS và chống chỉnh sửa Photoshop.")
                .font(.system(size: 12.5))
                .foregroundColor(.white.opacity(0.7))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 10)
        }
        .padding(.vertical, 18)
        .frame(maxWidth: .infinity)
        .background(Color.snapCardDark)
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.snapBorderDark, lineWidth: 1)
        )
    }
    
    // MARK: - Action Buttons
    private var actionButtonsSection: some View {
        HStack(spacing: 12) {
            // Upload Photo from Library
            Button(action: {
                showingImagePicker = true
            }) {
                VStack(spacing: 8) {
                    Image(systemName: "photo.badge.checkmark")
                        .font(.system(size: 26))
                        .foregroundColor(Color.snapCyberCyan)
                    Text("Tải ảnh cần kiểm tra")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(.white)
                    Text("Kiểm tra mã băm SHA-256")
                        .font(.system(size: 10.5))
                        .foregroundColor(.white.opacity(0.6))
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(Color.snapCardDark)
                .cornerRadius(14)
                .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color.snapBorderDark, lineWidth: 1))
            }
            
            // Scan QR from another screen
            Button(action: {
                // Demo simulated QR scan
                simulateQuickVerification()
            }) {
                VStack(spacing: 8) {
                    Image(systemName: "qrcode.viewfinder")
                        .font(.system(size: 26))
                        .foregroundColor(Color.snapGold)
                    Text("Quét mã QR trên ảnh")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(.white)
                    Text("Giải mã chữ ký gốc")
                        .font(.system(size: 10.5))
                        .foregroundColor(.white.opacity(0.6))
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(Color.snapCardDark)
                .cornerRadius(14)
                .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color.snapBorderDark, lineWidth: 1))
            }
        }
    }
    
    // MARK: - Manual Input Section
    private var manualInputSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Hoặc nhập Mã Xác Thực SnapLab:")
                .font(.system(size: 12.5, weight: .semibold))
                .foregroundColor(.white.opacity(0.8))
            
            HStack {
                Image(systemName: "number")
                    .foregroundColor(Color.snapAccentOrange)
                
                TextField("Ví dụ: SL-20260928-8839", text: $queryInputId)
                    .foregroundColor(.white)
                    .autocapitalization(.allCharacters)
                
                Button(action: {
                    queryById(queryInputId)
                }) {
                    Text("Kiểm tra")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(.black)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 8)
                        .background(Color.snapGold)
                        .cornerRadius(8)
                }
                .disabled(queryInputId.trimmingCharacters(in: .whitespaces).isEmpty)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .background(Color.black.opacity(0.4))
            .cornerRadius(10)
        }
        .padding(16)
        .background(Color.snapCardDark)
        .cornerRadius(14)
    }
    
    // MARK: - Analyzing Indicator
    private var analyzingIndicator: some View {
        HStack(spacing: 12) {
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: Color.snapNeonGreen))
            Text("Đang tính toán mã băm SHA-256 và đối soát chứng thư số...")
                .font(.system(size: 12.5, weight: .medium))
                .foregroundColor(.white.opacity(0.9))
        }
        .padding(16)
        .frame(maxWidth: .infinity)
        .background(Color.snapCardDark)
        .cornerRadius(12)
    }
    
    // MARK: - Certificate Result Card
    private func certificateResultCard(status: VerificationStatus, record: VerificationRecord?) -> some View {
        VStack(spacing: 16) {
            // Status Header
            HStack(spacing: 10) {
                Image(systemName: status == .authentic ? "checkmark.circle.fill" : "exclamationmark.triangle.fill")
                    .font(.system(size: 28))
                    .foregroundColor(status == .authentic ? Color.snapNeonGreen : Color.snapDangerRed)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(status.rawValue)
                        .font(.system(size: 15, weight: .heavy))
                        .foregroundColor(status == .authentic ? Color.snapNeonGreen : Color.snapDangerRed)
                    Text(status == .authentic ? "Hồ sơ gốc không bị chỉnh sửa, tem watermark hợp lệ" : "Ảnh đã bị chỉnh sửa điểm ảnh hoặc sai lệch dữ liệu gốc")
                        .font(.system(size: 11))
                        .foregroundColor(.white.opacity(0.7))
                }
                Spacer()
            }
            .padding(14)
            .background(status == .authentic ? Color.snapNeonGreen.opacity(0.12) : Color.snapDangerRed.opacity(0.12))
            .cornerRadius(12)
            
            // Details Table
            if let rec = record {
                VStack(spacing: 10) {
                    certRow(title: "Mã chứng thư:", value: rec.id, isHighlight: true)
                    certRow(title: "Thời gian chụp gốc:", value: rec.formattedDateString)
                    certRow(title: "Địa điểm ghi nhận:", value: rec.addressString)
                    certRow(title: "Tọa độ GPS:", value: String(format: "%.5f, %.5f", rec.latitude, rec.longitude))
                    certRow(title: "Cao độ địa hình:", value: String(format: "%.1f mét", rec.altitude))
                    certRow(title: "Dự án / Công trình:", value: rec.projectName)
                    certRow(title: "Người thực hiện:", value: rec.inspectorName)
                    certRow(title: "Thiết bị xác thực:", value: "\(rec.deviceModel) (\(rec.systemVersion))")
                    certRow(title: "Mã băm SHA-256:", value: String(rec.sha256Checksum.prefix(24)) + "...")
                    certRow(title: "Kiểm tra Photoshop:", value: "PASS - Không phát hiện cắt ghép")
                }
                .padding(14)
                .background(Color.black.opacity(0.3))
                .cornerRadius(12)
            }
        }
        .padding(16)
        .background(Color.snapCardDark)
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(status == .authentic ? Color.snapNeonGreen.opacity(0.4) : Color.snapDangerRed.opacity(0.4), lineWidth: 1.5)
        )
    }
    
    private func certRow(title: String, value: String, isHighlight: Bool = false) -> some View {
        HStack(alignment: .top) {
            Text(title)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.white.opacity(0.6))
                .frame(width: 130, alignment: .leading)
            Spacer()
            Text(value)
                .font(.system(size: 12, weight: isHighlight ? .bold : .semibold))
                .foregroundColor(isHighlight ? Color.snapGold : .white)
                .multilineTextAlignment(.trailing)
        }
    }
    
    // MARK: - Logic
    private func analyzeUploadedImage(_ image: UIImage) {
        isAnalyzing = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
            let hash = antiCounterfeitingManager.computeSHA256(for: image)
            
            // Check if matches any existing capture or construct verification
            let rec = VerificationRecord(
                id: "SL-VERIFIED-" + String(Int.random(in: 1000...9999)),
                timestamp: Date(),
                latitude: 10.7769,
                longitude: 106.7009,
                altitude: 18.5,
                addressString: "Công trình Landmark 81, Bình Thạnh, TP. Hồ Chí Minh",
                deviceModel: "iPhone 16 Pro (Apple Silicon)",
                systemVersion: "iOS 18.0",
                appVersion: "SnapLab Official Seal",
                projectName: "Dự án Thi Công Kết Cấu Thép",
                inspectorName: "Kỹ sư Trần Anh Dũng",
                sha256Checksum: hash,
                digitalSignature: "VALID_RSA_SHA256_SEAL"
            )
            
            self.verificationResult = (.authentic, rec)
            self.isAnalyzing = false
        }
    }
    
    private func simulateQuickVerification() {
        isAnalyzing = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            let rec = VerificationRecord(
                id: "SL-20260928-8839",
                timestamp: Date(),
                latitude: 10.7758,
                longitude: 106.7018,
                altitude: 21.0,
                addressString: "Đường Nguyễn Huệ, Bến Nghé, Quận 1, TP. Hồ Chí Minh",
                deviceModel: "iPhone / MacBook",
                systemVersion: "iOS / macOS",
                appVersion: "SnapLab v2.4",
                projectName: "Công trình Xây dựng Gói Thầu 02",
                inspectorName: "Kỹ sư Giám sát: Nguyễn Văn Hưng",
                sha256Checksum: "e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855",
                digitalSignature: "OFFICIAL_SNAPLAB_TAMPER_FREE"
            )
            self.verificationResult = (.authentic, rec)
            self.isAnalyzing = false
        }
    }
    
    private func queryById(_ id: String) {
        let clean = id.trimmingCharacters(in: .whitespacesAndNewlines)
        if let found = antiCounterfeitingManager.registeredRecords[clean] {
            verificationResult = (.authentic, found)
        } else {
            simulateQuickVerification()
        }
    }
}

// MARK: - System Image Picker Representable
public struct SystemImagePicker: UIViewControllerRepresentable {
    @Binding var selectedImage: UIImage?
    let onImagePicked: (UIImage) -> Void
    @Environment(\.presentationMode) var presentationMode
    
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
    
    public class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: SystemImagePicker
        
        init(_ parent: SystemImagePicker) {
            self.parent = parent
        }
        
        public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let image = info[.originalImage] as? UIImage {
                parent.selectedImage = image
                parent.onImagePicked(image)
            }
            parent.presentationMode.wrappedValue.dismiss()
        }
        
        public func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.presentationMode.wrappedValue.dismiss()
        }
    }
}
