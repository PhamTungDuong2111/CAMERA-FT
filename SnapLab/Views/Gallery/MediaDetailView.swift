import SwiftUI

public struct MediaDetailView: View {
    let item: CapturedMedia
    @ObservedObject var libraryManager: PhotoLibraryManager
    @ObservedObject var loc = LocalizationManager.shared
    @Environment(\.presentationMode) var presentationMode
    
    @State private var showingShareSheet = false
    @State private var showingDeleteAlert = false
    @State private var showingVerificationSheet = false
    
    public var body: some View {
        NavigationView {
            ZStack {
                Color.black.edgesIgnoringSafeArea(.all)
                
                VStack(spacing: 0) {
                    // Full Resolution Image Display
                    if let image = libraryManager.loadImage(for: item) {
                        Image(uiImage: image)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                    } else {
                        VStack(spacing: 12) {
                            Image(systemName: "exclamationmark.triangle")
                                .font(.system(size: 40))
                                .foregroundColor(.yellow)
                            Text("Không tải được tệp tin gốc")
                                .foregroundColor(.white)
                        }
                    }
                    
                    // Metadata Info Bar
                    bottomInfoBar
                }
            }
            .navigationBarTitle(item.templateName.isEmpty ? "SnapLab Photo" : item.templateName, displayMode: .inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(loc.t("close")) {
                        presentationMode.wrappedValue.dismiss()
                    }
                    .foregroundColor(.white)
                }
                
                ToolbarItem(placement: .primaryAction) {
                    HStack(spacing: 16) {
                        // Anti-counterfeit verification
                        if item.verificationRecord != nil {
                            Button(action: {
                                showingVerificationSheet = true
                            }) {
                                Image(systemName: "checkmark.shield.fill")
                                    .foregroundColor(Color.snapNeonGreen)
                            }
                        }
                        
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
                if let image = libraryManager.loadImage(for: item) {
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
    
    private var bottomInfoBar: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Label(DateFormatter.fullDateTimeFormatter.string(from: item.creationDate), systemImage: "clock")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(.white)
                Spacer()
                if let record = item.verificationRecord {
                    Text(loc.t("snaplabVerified") + record.id)
                        .font(.system(size: 10.5, weight: .heavy))
                        .foregroundColor(Color.snapNeonGreen)
                }
            }
            
            if let record = item.verificationRecord {
                Text(loc.t("locationLabel") + record.addressString)
                    .font(.system(size: 11))
                    .foregroundColor(.white.opacity(0.8))
                    .lineLimit(1)
                Text(loc.t("coordinatesLabel") + String(format: "%.5f", record.latitude) + ", " + String(format: "%.5f", record.longitude) + " • " + loc.t("altitudeLabel") + String(format: "%.1f", record.altitude) + "m")
                    .font(.system(size: 10.5))
                    .foregroundColor(.white.opacity(0.65))
            }
        }
        .padding(14)
        .background(Color.snapCardDark.opacity(0.95))
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
