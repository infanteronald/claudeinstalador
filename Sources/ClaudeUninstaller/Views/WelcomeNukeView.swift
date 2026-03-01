import SwiftUI

struct WelcomeNukeView: View {
    @EnvironmentObject var state: UninstallerState

    var body: some View {
        VStack(spacing: 20) {
            Spacer()

            // Nuclear icon
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [.red, .orange, .yellow],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 100, height: 100)
                    .shadow(color: .red.opacity(0.3), radius: 20, x: 0, y: 10)

                Image(systemName: "trash.circle.fill")
                    .font(.system(size: 48))
                    .foregroundColor(.white)
            }

            Text("Claude Code")
                .font(.system(size: 28, weight: .bold))

            Text(isSpanish ? "Nuclear Uninstaller" : "Nuclear Uninstaller")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.red)

            Text(isSpanish
                ? "Escanea y elimina todos los rastros de Claude Code de tu Mac. Binarios, configuración, caché, Keychain, entradas de PATH — todo."
                : "Scans and removes every trace of Claude Code from your Mac. Binaries, config, cache, Keychain, PATH entries — everything.")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 50)

            // Warning
            HStack(spacing: 8) {
                Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundColor(.orange)
                Text(isSpanish
                    ? "Esta acción no se puede deshacer"
                    : "This action cannot be undone")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(.orange)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.orange.opacity(0.1))
            )

            // Scan button
            Button(action: {
                Task { await state.startScan() }
            }) {
                HStack(spacing: 8) {
                    Image(systemName: "magnifyingglass")
                    Text(isSpanish ? "Escanear Sistema" : "Scan System")
                        .font(.system(size: 16, weight: .semibold))
                }
                .frame(minWidth: 200, minHeight: 20)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            .tint(.red)
            .padding(.top, 8)

            Spacer()
        }
    }
}
