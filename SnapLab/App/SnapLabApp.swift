import SwiftUI

@main
struct SnapLabApp: App {
    init() {
        #if targetEnvironment(macCatalyst)
        // Configure macOS Catalyst Window title bar appearance
        UIApplication.shared.connectedScenes.compactMap { $0 as? UIWindowScene }.forEach { windowScene in
            if let titlebar = windowScene.titlebar {
                titlebar.titleVisibility = .visible
                titlebar.toolbar = nil
            }
        }
        #endif
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        #if os(macOS)
        .windowStyle(HiddenTitleBarWindowStyle())
        .defaultSize(width: 480, height: 860)
        #endif
    }
}
