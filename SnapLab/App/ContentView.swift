import SwiftUI

public struct ContentView: View {
    @State private var deepLinkQueryId: String?
    @State private var showingDeepLinkVerify: Bool = false
    
    public init() {}
    
    public var body: some View {
        CameraView()
            .preferredColorScheme(.dark)
            .sheet(isPresented: $showingDeepLinkVerify) {
                AntiCounterfeitQueryView(initialQueryId: deepLinkQueryId)
            }
            .onOpenURL { url in
                if url.scheme == "snaplab" && url.host == "verify" {
                    if let components = URLComponents(url: url, resolvingAgainstBaseURL: false) {
                        let id = components.queryItems?.first(where: { $0.name == "id" })?.value ?? url.path.replacingOccurrences(of: "/", with: "")
                        deepLinkQueryId = id.isEmpty ? url.absoluteString : id
                        showingDeepLinkVerify = true
                    }
                }
            }
    }
}
