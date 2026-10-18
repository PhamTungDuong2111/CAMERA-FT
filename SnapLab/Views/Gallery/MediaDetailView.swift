import SwiftUI
import AVKit

public struct MediaDetailView: View {
    let item: CapturedMedia
    @ObservedObject var libraryManager: PhotoLibraryManager
    @ObservedObject var loc = LocalizationManager.shared
    @Environment(\.presentationMode) var presentationMode
    
    @State private var showingShareSheet = false
    @State private var showingDeleteAlert = false
    @State private var showingVerificationSheet = false
    @State private var avPlayer: AVPlayer?
    
    public init(item: CapturedMedia, libraryManager: PhotoLibraryManager) {
        self.item = item
        self.libraryManager = libraryManager
    }
    
    public var body: some View {
        NavigationView {
            ZStack {
                Color.black.edgesIgnoringSafeArea(.all)
                
                VStack(spacing: 0) {
                    // Main Media Preview
                    if item.type == .video {
                        let videoURL = libraryManager.getMediaURL(for: item)
                        VideoPlayer(player: avPlayer ?? AVPlayer(url: videoURL))
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .onAppear {
                                if avPlayer == nil {
                                    avPlayer = AVPlayer(url: videoURL)
                                }
                            }
                            .onDisappear {
                                avPlayer?.pause()
                            }
                    } else if let image = libraryManager.loadImage(for: item) {
                        Image(uiImage: image)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                    } else {
                        VStack(spacing: 12) {
                            Image(systemName: "exclamationmark.triangle")
                                .font(.system(size: 40))
                                .foregroundColor(.yellow)
                            Text(loc.isVietnamese() ? "Không tải được tệp tin gốc" : "Cannot load original file")
                                .foregroundColor(.white)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    }
                    
                    // Metadata Info Card
                    metadataCard
                }
            }
            .navigationBarTitle(item.templateName.isEmpty ? "SnapLab Media" : item.templateName, displayMode: .inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(loc.t("close")) {
                        presentationMode.wrappedValue.dismiss()
                    }
                    .foregroundColor(.white)
                }
                
                ToolbarItem(placement: .primaryAction) {
                    HStack(spacing: 16) {
                        // Share
                        Button(action: {
                            showingShareSheet = true
                        }) {
                            Image(systemName: "square.and.arrow.up")
                                .foregroundColor(.white)
                        }
                        
                        // Delete
                        Button(action: {
                            showingDeleteAlert = true
                        }) {
                            Image(systemName: "trash")
                                .foregroundColor(Color.snapDangerRed)
                        }
                    }
                }
            }
            .sheet(isPresented: $showingShareSheet) {
                if item.type == .video {
                    let url = libraryManager.getMediaURL(for: item)
                    ShareSheetRepresentable(items: [url])
                } else if let image = libraryManager.loadImage(for: item) {
                    ShareSheetRepresentable(items: [image])
                }
            }
            .sheet(isPresented: $showingVerificationSheet) {
                AntiCounterfeitQueryView()
            }
            .alert(isPresented: $showingDeleteAlert) {
                Alert(
                    title: Text(loc.t("deleteAlertTitle")),
                    message: Text(loc.t("deleteAlertDesc")),
                    primaryButton: .destructive(Text(loc.t("delete"))) {
                        libraryManager.deleteItem(item)
                        presentationMode.wrappedValue.dismiss()
                    },
                    secondaryButton: .cancel(Text(loc.t("cancel")))
                )
            }
        }
    }
    
    private var metadataCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(loc.isVietnamese() ? "THÔNG TIN CHI TIẾT" : "METADATA DETAILS")
                .font(.system(size: 11, weight: .bold))
                .foregroundColor(.white.opacity(0.6))
            
            detailRow(label: loc.isVietnamese() ? "Tập tin:" : "File:", value: item.localFileName)
            detailRow(label: loc.isVietnamese() ? "Thời gian:" : "Date:", value: DateFormatter.fullDateTimeFormatter.string(from: item.creationDate))
            
            if let record = item.verificationRecord {
                if !record.addressString.isEmpty {
                    detailRow(label: loc.isVietnamese() ? "Vị trí:" : "Location:", value: record.addressString)
                }
                detailRow(label: loc.isVietnamese() ? "Mã định danh:" : "Record ID:", value: record.id, isMono: true, highlightColor: Color.snapGold)
                detailRow(label: loc.isVietnamese() ? "Thiết bị:" : "Device:", value: "\(record.deviceModel) • \(record.systemVersion)")
                detailRow(label: loc.isVietnamese() ? "Mã băm SHA-256:" : "SHA-256 Hash:", value: record.sha256Checksum, isMono: true)
            }
            
            // Button: Verify Signature
            Button(action: {
                showingVerificationSheet = true
            }) {
                HStack(spacing: 8) {
                    Image(systemName: "checkmark.shield.fill")
                        .foregroundColor(.black)
                    Text(loc.isVietnamese() ? "Đối Soát Chống Giả Mạo" : "Anti-Counterfeit Query")
                        .font(.system(size: 13.5, weight: .bold))
                        .foregroundColor(.black)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
                .background(Color.snapNeonGreen)
                .cornerRadius(10)
            }
            .padding(.top, 4)
        }
        .padding(14)
        .background(Color.snapCardDark.opacity(0.96))
        .cornerRadius(14)
        .padding(.horizontal, 12)
        .padding(.bottom, 12)
    }
    
    private func detailRow(label: String, value: String, isMono: Bool = false, highlightColor: Color = .white) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(label)
                .font(.system(size: 10.5))
                .foregroundColor(.white.opacity(0.5))
            Text(value)
                .font(isMono ? .system(size: 10.5, weight: .medium, design: .monospaced) : .system(size: 12, weight: .medium))
                .foregroundColor(highlightColor)
                .lineLimit(2)
        }
    }
}

// MARK: - UIActivityViewController Representable
public struct ShareSheetRepresentable: UIViewControllerRepresentable {
    let items: [Any]
    
    public func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(activityItems: items, applicationActivities: nil)
        return controller
    }
    
    public func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
