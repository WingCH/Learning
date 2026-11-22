import SwiftUI

@main
struct AreaScopeApp: App {
    var body: some Scene {
        WindowGroup {
            AreaInspector()
                .preferredColorScheme(.dark)
        }
    }
}
