import SwiftUI

struct DownloadProgressView: View {
    @EnvironmentObject var appState: AppState

    var body: some View {
        VStack(spacing: 20) {
            Text(Locale.isSpanish ? "Descarga de Claude Code" : "Downloading Claude Code")
                .font(.system(size: 24, weight: .bold))
                .padding(.top, 20)

            if appState.updateAvailable {
                updateAvailableView
            } else if let result = appState.phaseResults[.binaryDownload], result.isSuccess,
               appState.auditResult?.isClaudeAlreadyInstalled == true {
                alreadyInstalledView
            } else if appState.isProcessing {
                downloadingView
            } else if let result = appState.phaseResults[.binaryDownload], result.isSuccess {
                downloadCompleteView
            } else {
                waitingView
            }

            Spacer()
        }
    }

    var updateAvailableView: some View {
        VStack(spacing: 16) {
            Image(systemName: "arrow.triangle.2.circlepath.circle.fill")
                .font(.system(size: 48))
                .foregroundColor(.orange)

            Text(Locale.isSpanish
                ? "Actualización Disponible"
                : "Update Available")
                .font(.system(size: 20, weight: .semibold))

            // Version comparison
            HStack(spacing: 16) {
                VStack(spacing: 4) {
                    Text(Locale.isSpanish ? "Instalada" : "Installed")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("v\(appState.installedVersion ?? "?")")
                        .font(.system(size: 15, weight: .medium, design: .monospaced))
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.gray.opacity(0.15))
                        )
                }

                Image(systemName: "arrow.right")
                    .foregroundColor(.orange)
                    .font(.system(size: 18, weight: .semibold))

                VStack(spacing: 4) {
                    Text(Locale.isSpanish ? "Disponible" : "Available")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("v\(appState.latestAvailableVersion ?? "?")")
                        .font(.system(size: 15, weight: .bold, design: .monospaced))
                        .foregroundColor(.orange)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.orange.opacity(0.12))
                        )
                }
            }

            // Action buttons
            HStack(spacing: 12) {
                Button(action: {
                    guard let latest = appState.latestAvailableVersion,
                          let arch = appState.auditResult?.architecture else { return }
                    Task {
                        await appState.downloadAndInstall(version: latest, architecture: arch)
                    }
                }) {
                    Label(
                        Locale.isSpanish ? "Actualizar ahora" : "Update now",
                        systemImage: "arrow.down.circle.fill"
                    )
                }
                .buttonStyle(.borderedProminent)
                .tint(.orange)

                Button(action: {
                    // Skip update — mark as success with current version
                    appState.updateAvailable = false
                    appState.markPhaseResult(.binaryDownload, result: .success(
                        details: Locale.isSpanish
                            ? "Se conserva la versión v\(appState.installedVersion ?? "?")"
                            : "Keeping version v\(appState.installedVersion ?? "?")"
                    ))
                }) {
                    Text(Locale.isSpanish ? "Omitir" : "Skip")
                }
                .buttonStyle(.bordered)
            }
            .padding(.top, 8)
        }
        .padding(.top, 20)
    }

    var alreadyInstalledView: some View {
        VStack(spacing: 16) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 48))
                .foregroundColor(.green)

            Text(Locale.isSpanish
                ? "Claude Code está actualizado"
                : "Claude Code is up to date")
                .font(.headline)

            if let version = appState.installedVersion {
                Text("v\(version)")
                    .font(.system(size: 16, weight: .medium, design: .monospaced))
                    .foregroundColor(.secondary)
            }
        }
        .padding(.top, 40)
    }

    var downloadingView: some View {
        VStack(spacing: 16) {
            if let progress = appState.downloadProgress {
                // Animated icon
                Image(systemName: "arrow.down.circle.fill")
                    .font(.system(size: 48))
                    .foregroundColor(.accentColor)

                // Progress bar
                ProgressView(value: progress.fraction)
                    .progressViewStyle(.linear)
                    .padding(.horizontal, 60)

                // Percentage
                Text("\(progress.percentage)%")
                    .font(.system(size: 36, weight: .bold, design: .rounded))
                    .foregroundColor(.accentColor)

                // Details
                HStack(spacing: 20) {
                    VStack {
                        Text(Locale.isSpanish ? "Descargado" : "Downloaded")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text(String(format: "%.1f MB", progress.downloadedMB))
                            .font(.system(size: 14, weight: .medium, design: .monospaced))
                    }

                    Divider().frame(height: 30)

                    VStack {
                        Text(Locale.isSpanish ? "Total" : "Total")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text(String(format: "%.1f MB", progress.totalMB))
                            .font(.system(size: 14, weight: .medium, design: .monospaced))
                    }

                    Divider().frame(height: 30)

                    VStack {
                        Text(Locale.isSpanish ? "Velocidad" : "Speed")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text(String(format: "%.1f MB/s", progress.speedMBps))
                            .font(.system(size: 14, weight: .medium, design: .monospaced))
                    }
                }
            } else {
                ProgressView()
                    .scaleEffect(1.2)

                Text(Locale.isSpanish
                    ? "Conectando con los servidores de Anthropic..."
                    : "Connecting to Anthropic servers...")
                    .font(.body)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.top, 20)
    }

    var downloadCompleteView: some View {
        VStack(spacing: 16) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 48))
                .foregroundColor(.green)

            Text(Locale.isSpanish
                ? "Descarga completada"
                : "Download complete")
                .font(.headline)

            if let version = appState.installedVersion {
                Text("Claude Code v\(version)")
                    .font(.system(size: 16, weight: .medium, design: .monospaced))
                    .foregroundColor(.secondary)
            }
        }
        .padding(.top, 40)
    }

    var waitingView: some View {
        VStack(spacing: 16) {
            Image(systemName: "arrow.down.circle")
                .font(.system(size: 48))
                .foregroundColor(.secondary)

            Text(Locale.isSpanish
                ? "Listo para descargar Claude Code"
                : "Ready to download Claude Code")
                .font(.body)
                .foregroundColor(.secondary)
        }
        .padding(.top, 40)
    }
}
