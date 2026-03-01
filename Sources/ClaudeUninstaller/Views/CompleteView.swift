import SwiftUI

struct CompleteView: View {
    @EnvironmentObject var state: UninstallerState

    var body: some View {
        VStack(spacing: 20) {
            Spacer()

            if let cleanup = state.cleanupResult {
                // Detonation complete
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 56))
                    .foregroundColor(.green)

                Text(isSpanish ? "¡Limpieza Completa!" : "Cleanup Complete!")
                    .font(.system(size: 24, weight: .bold))

                // Stats
                VStack(spacing: 12) {
                    statRow(
                        icon: "trash.fill",
                        color: .green,
                        label: isSpanish
                            ? "\(cleanup.removedCount) elementos eliminados"
                            : "\(cleanup.removedCount) items removed"
                    )

                    if cleanup.freedBytes > 0 {
                        statRow(
                            icon: "internaldrive.fill",
                            color: .blue,
                            label: isSpanish
                                ? "\(formatBytes(cleanup.freedBytes)) liberados"
                                : "\(formatBytes(cleanup.freedBytes)) freed"
                        )
                    }

                    if cleanup.failedCount > 0 {
                        statRow(
                            icon: "exclamationmark.triangle.fill",
                            color: .orange,
                            label: isSpanish
                                ? "\(cleanup.failedCount) no se pudieron eliminar"
                                : "\(cleanup.failedCount) could not be removed"
                        )

                        // Show failures
                        VStack(alignment: .leading, spacing: 4) {
                            ForEach(cleanup.failures, id: \.self) { path in
                                Text(path)
                                    .font(.system(size: 10, design: .monospaced))
                                    .foregroundColor(.secondary)
                            }
                        }
                        .padding(.horizontal, 40)
                    }
                }
                .padding(.horizontal, 40)

                Text(isSpanish
                    ? "Tu Mac está limpia. Puedes reinstalar Claude Code con el instalador."
                    : "Your Mac is clean. You can reinstall Claude Code with the installer.")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
                    .padding(.top, 8)

            } else {
                // No traces found (scan came back empty)
                Image(systemName: "sparkles")
                    .font(.system(size: 56))
                    .foregroundColor(.green)

                Text(isSpanish ? "¡Todo limpio!" : "All clean!")
                    .font(.system(size: 24, weight: .bold))

                Text(isSpanish
                    ? "No se encontraron rastros de Claude Code en tu sistema."
                    : "No traces of Claude Code were found on your system.")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
            }

            Button(action: {
                NSApplication.shared.terminate(nil)
            }) {
                Text(isSpanish ? "Cerrar" : "Close")
                    .frame(minWidth: 120)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            .padding(.top, 8)

            Spacer()
        }
    }

    func statRow(icon: String, color: Color, label: String) -> some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .foregroundColor(color)
                .frame(width: 20)
            Text(label)
                .font(.system(size: 14))
            Spacer()
        }
    }

    func formatBytes(_ bytes: Int64) -> String {
        if bytes < 1024 * 1024 {
            return String(format: "%.1f KB", Double(bytes) / 1024)
        } else {
            return String(format: "%.1f MB", Double(bytes) / (1024 * 1024))
        }
    }
}
