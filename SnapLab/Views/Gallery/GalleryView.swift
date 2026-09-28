import SwiftUI

public struct GalleryView: View {
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var libraryManager = PhotoLibraryManager.shared
    @ObservedObject var loc = LocalizationManager.shared
    
    @State private var selectedFilter: MediaType? = nil
    @State private var selectedMedia: CapturedMedia?
    @State private var showingAlbumEditor = false
    
    private let columns = [
        GridItem(.adaptive(minimum: 110, maximum: 160), spacing: 10)
    ]
    
    public var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Filter Tabs Bar
                filterBar
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(Color.snapCardDark)
                
                // Content Grid
                if filteredItems.isEmpty {
                    emptyStateView
                } else {
                    ScrollView {
                        LazyVGrid(columns: columns, spacing: 10) {
                            ForEach(filteredItems) { item in
                                mediaGridItem(item)
                            }
                        }
                        .padding(14)
                    }
                }
            }
            .background(Color.snapBackgroundDark.edgesIgnoringSafeArea(.all))
            .navigationTitle(loc.t("galleryTitle"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(loc.t("close")) {
                        presentationMode.wrappedValue.dismiss()
                    }
                    .foregroundColor(.white)
                }
                
                ToolbarItem(placement: .primaryAction) {
                    Button(action: {
                        showingAlbumEditor = true
                    }) {
                        HStack(spacing: 5) {
                            Image(systemName: "plus.viewfinder")
                            Text(loc.t("stampExistingPhoto"))
                        }
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(Color.snapAccentOrange)
                    }
                }
            }
            .sheet(item: $selectedMedia) { item in
                MediaDetailView(item: item, libraryManager: libraryManager)
            }
            .sheet(isPresented: $showingAlbumEditor) {
                AlbumWatermarkEditorView()
            }
        }
    }
    
    // MARK: - Filter Bar
    private var filterBar: some View {
        HStack(spacing: 12) {
            filterButton(title: "\(loc.t("all")) (\(libraryManager.mediaItems.count))", isSelected: selectedFilter == nil) {
                selectedFilter = nil
            }
            
            let photoCount = libraryManager.mediaItems.filter { $0.type == .photo }.count
            filterButton(title: "\(loc.t("photo")) (\(photoCount))", isSelected: selectedFilter == .photo) {
                selectedFilter = .photo
            }
            
            let videoCount = libraryManager.mediaItems.filter { $0.type == .video }.count
            filterButton(title: "\(loc.t("video")) (\(videoCount))", isSelected: selectedFilter == .video) {
                selectedFilter = .video
            }
            
            Spacer()
        }
    }
    
    private func filterButton(title: String, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 12.5, weight: isSelected ? .bold : .medium))
                .foregroundColor(isSelected ? .black : .white.opacity(0.8))
                .padding(.horizontal, 14)
                .padding(.vertical, 6)
                .background(isSelected ? Color.snapGold : Color.white.opacity(0.12))
                .clipShape(Capsule())
        }
    }
    
    // MARK: - Empty State
    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Spacer()
            Image(systemName: "camera.viewfinder")
                .font(.system(size: 54))
                .foregroundColor(.white.opacity(0.3))
            
            Text(loc.t("emptyGalleryTitle"))
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(.white)
            
            Text(loc.t("emptyGalleryDesc"))
                .font(.system(size: 13))
                .foregroundColor(.white.opacity(0.6))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 36)
            
            Button(action: {
                showingAlbumEditor = true
            }) {
                Text(loc.t("chooseFromAlbum"))
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
                    .background(Color.snapAccentOrange)
                    .cornerRadius(10)
            }
            Spacer()
        }
    }
    
    // MARK: - Grid Item
    private func mediaGridItem(_ item: CapturedMedia) -> some View {
        Button(action: {
            selectedMedia = item
        }) {
            ZStack(alignment: .bottomLeading) {
                if let thumb = libraryManager.loadThumbnail(for: item) {
                    Image(uiImage: thumb)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(minWidth: 0, maxWidth: .infinity, minHeight: 120, maxHeight: 150)
                        .clipped()
                        .cornerRadius(10)
                } else {
                    Rectangle()
                        .fill(Color.snapCardDark)
                        .frame(height: 120)
                        .cornerRadius(10)
                        .overlay(Image(systemName: "photo").foregroundColor(.white.opacity(0.3)))
                }
                
                // Bottom Gradient Shade with Badge & Time
                VStack(alignment: .leading, spacing: 2) {
                    if item.type == .video {
                        HStack(spacing: 4) {
                            Image(systemName: "video.fill")
                                .font(.system(size: 9))
                            Text(String(format: "%.0fs", item.durationSeconds ?? 0))
                                .font(.system(size: 9.5, weight: .bold))
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color.snapDangerRed.opacity(0.85))
                        .cornerRadius(4)
                    }
                    
                    Text(DateFormatter.displayDateFormatter.string(from: item.creationDate))
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundColor(.white)
                }
                .padding(6)
            }
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.white.opacity(0.12), lineWidth: 1)
            )
        }
    }
    
    private var filteredItems: [CapturedMedia] {
        if let filter = selectedFilter {
            return libraryManager.mediaItems.filter { $0.type == filter }
        }
        return libraryManager.mediaItems
    }
}
