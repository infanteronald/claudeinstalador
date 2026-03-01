import SwiftUI

struct ScanningView: View {
    @EnvironmentObject var state: UninstallerState
    @State private var rotation: Double = 0

    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            // Animated scanning icon
            Image(systemName: "antenna.radiowaves.left.and.right")
                .font(.system(size: 48))
                .foregroundColor(.red)
                .rotationEffect(.degrees(rotation))
                .onAppear {
                    withAnimation(.linear(duration: 2).repeatForever(autoreverses: false)) {
                        rotation = 360
                    }
                }

            Text(isSpanish ? "Escaneando..." : "Scanning...")
                .font(.system(size: 24, weight: .bold))

            Text(isSpanish
                ? "Buscando todos los rastros de Claude Code en tu sistema"
                : "Searching for all Claude Code traces on your system")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)

            ProgressView()
                .scaleEffect(1.2)

            // Scanning locations
            VStack(alignment: .leading, spacing: 6) {
                scanLocationRow("~/.local/bin/claude")
                scanLocationRow("~/.local/share/claude/")
                scanLocationRow("~/.claude/")
                scanLocationRow("~/.zshrc")
                scanLocationRow("Keychain")
                scanLocationRow("Homebrew / npm")
            }
            .font(.system(size: 12, design: .monospaced))
            .foregroundColor(.secondary)
            .padding(.horizontal, 60)

            Spacer()
        }
    }

    func scanLocationRow(_ text: String) -> some View {
        HStack(spacing: 6) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 10))
                .foregroundColor(.red.opacity(0.6))
            Text(text)
        }
    }
}
