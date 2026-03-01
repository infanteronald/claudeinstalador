import SwiftUI

struct UninstallerMainView: View {
    @EnvironmentObject var state: UninstallerState

    var body: some View {
        VStack(spacing: 0) {
            // Content
            Group {
                switch state.phase {
                case .welcome:
                    WelcomeNukeView()
                case .scanning:
                    ScanningView()
                case .results:
                    ScanResultsView()
                case .confirming:
                    ConfirmDetonationView()
                case .detonating:
                    DetonatingView()
                case .complete:
                    CompleteView()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .transition(.opacity)
            .animation(.easeInOut(duration: 0.3), value: state.phase == .welcome)
            .animation(.easeInOut(duration: 0.3), value: state.phase == .scanning)
            .animation(.easeInOut(duration: 0.3), value: state.phase == .results)
            .animation(.easeInOut(duration: 0.3), value: state.phase == .confirming)
            .animation(.easeInOut(duration: 0.3), value: state.phase == .detonating)
            .animation(.easeInOut(duration: 0.3), value: state.phase == .complete)
        }
        .background(Color(nsColor: .windowBackgroundColor))
    }
}
