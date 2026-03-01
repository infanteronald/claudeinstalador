import SwiftUI

@main
struct ClaudeUninstallerApp: App {
    @StateObject private var state = UninstallerState()

    var body: some Scene {
        WindowGroup {
            UninstallerMainView()
                .environmentObject(state)
                .frame(width: 600, height: 480)
                .fixedSize()
        }
        .windowStyle(.titleBar)
        .windowResizability(.contentSize)
    }
}
