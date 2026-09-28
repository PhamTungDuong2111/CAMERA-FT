import SwiftUI

public struct ContentView: View {
    public init() {}
    
    public var body: some View {
        CameraView()
            .preferredColorScheme(.dark)
    }
}
