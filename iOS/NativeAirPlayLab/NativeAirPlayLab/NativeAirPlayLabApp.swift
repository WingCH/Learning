import SwiftUI

@main
struct NativeAirPlayLabApp: App {
    init() {
        MediaPlaybackConfiguration.configureAudioSession()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
