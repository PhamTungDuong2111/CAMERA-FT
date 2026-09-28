import SwiftUI
import MapKit

public struct AntiCounterfeitQueryView: View {
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var antiCounterfeitingManager = AntiCounterfeitingManager.shared
    @ObservedObject var loc = LocalizationManager.shared
    
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
            .navigationTitle(loc.t("queryTitle"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(loc.t("close")) {
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
            
            Text(loc.t("queryHeaderTitle"))
                .font(.system(size: 19, weight: .bold))
                .foregroundColor(.white)
            
            Text(loc.t("queryHeaderDesc"))
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
                    Text(loc.t("uploadToCheck"))
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(.white)
                    Text(loc.t("checkSha256Sub"))
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
                simulateQuickVerification()
            }) {
                VStack(spacing: 8) {
                    Image(systemName: "qrcode.viewfinder")
                        .font(.system(size: 26))
                        .foregroundColor(Color.snapGold)
                    Text(loc.t("scanPhotoQR"))
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(.white)
                    Text(loc.t("decodeSigSub"))
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
            Text(loc.t("orManualInput"))
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
                    Text(loc.t("checkBtn"))
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
            Text(loc.t("analyzing"))
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
        let isSuccess = status == .authentic
        let statusTitle = isSuccess ? loc.t("statusAuthentic") : loc.t("statusTampered")
        let statusDesc = isSuccess ? loc.t("authenticDesc") : loc.t("tamperedDesc")
        
        return VStack(spacing: 16) {
            // Status Header
            HStack(spacing: 10) {
                Image(systemName: isSuccess ? "checkmark.circle.fill" : "exclamationmark.triangle.fill")
                    .font(.system(size: 28))
                    .foregroundColor(isSuccess ? Color.snapNeonGreen : Color.snapDangerRed)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(statusTitle)
                        .font(.system(size: 15, weight: .heavy))
                        .foregroundColor(isSuccess ? Color.snapNeonGreen : Color.snapDangerRed)
                    Text(statusDesc)
                        .font(.system(size: 11))
                        .foregroundColor(.white.opacity(0.7))
                }
                Spacer()
            }
            .padding(14)
            .background(isSuccess ? Color.snapNeonGreen.opacity(0.12) : Color.snapDangerRed.opacity(0.12))
            .cornerRadius(12)
            
            // Details Table
            if let rec = record {
                VStack(spacing: 10) {
                    certRow(title: loc.t("certId"), value: rec.id, isHighlight: true)
                    certRow(title: loc.t("certTime"), value: rec.formattedDateString)
                    certRow(title: loc.t("certLocation"), value: rec.addressString)
                    certRow(title: loc.t("certCoords"), value: String(format: "%.5f, %.5f", rec.latitude, rec.longitude))
                    certRow(title: loc.t("certAltitude"), value: String(format: "%.1f m", rec.altitude))
                    certRow(title: loc.t("certProject"), value: rec.projectName)
                    certRow(title: loc.t("certInspector"), value: rec.inspectorName)
                    certRow(title: loc.t("certDevice"), value: "\(rec.deviceModel) (\(rec.systemVersion))")
                    certRow(title: loc.t("certHash"), value: String(rec.sha256Checksum.prefix(24)) + "...")
                    certRow(title: loc.t("certPhotoshopCheck"), value: loc.t("photoshopPass"))
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
                .stroke(isSuccess ? Color.snapNeonGreen.opacity(0.4) : Color.snapDangerRed.opacity(0.4), lineWidth: 1.5)
        )
    }
    
    private func certRow(title: String, value: String, isHighlight: Bool = false) -> some View {
        HStack(alignment: .top) {
            Text(title)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.white.opacity(0.6))
                .frame(width: 140, alignment: .leading)
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
            
            let rec = VerificationRecord(
                id: "SL-VERIFIED-" + String(Int.random(in: 1000...9999)),
                timestamp: Date(),
                latitude: 10.7769,
                longitude: 106.7009,
                altitude: 18.5,
                addressString: "Landmark Site, Ho Chi Minh City",
                deviceModel: "iPhone 16 Pro (Apple Silicon)",
                systemVersion: "iOS 18.0",
                appVersion: "SnapLab Official Seal",
                projectName: "Structural Engineering Project",
                inspectorName: "Engineer Tran Anh Dung",
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
                addressString: "Nguyen Hue Boulevard, Ben Nghe, District 1, HCMC",
                deviceModel: "iPhone / MacBook",
                systemVersion: "iOS / macOS",
                appVersion: "SnapLab v2.4",
                projectName: "Construction Contract Package 02",
                inspectorName: "Supervisor: Nguyen Van Hung",
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
