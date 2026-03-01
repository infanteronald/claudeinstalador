import SwiftUI

struct PathConfigView: View {
    @EnvironmentObject var appState: AppState

    var body: some View {
        VStack(spacing: 20) {
            Text(Locale.isSpanish ? "Configuración del PATH" : "PATH Configuration")
                .font(.system(size: 24, weight: .bold))
                .padding(.top, 20)

            Text(Locale.isSpanish
                ? "Configurando las variables de entorno para que puedas usar Claude Code desde cualquier terminal..."
                : "Setting up environment variables so you can use Claude Code from any terminal...")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)

            if appState.isProcessing {
                VStack(spacing: 12) {
                    ProgressView()
                        .scaleEffect(1.2)
                        .padding()

                    Text(Locale.isSpanish
                        ? "Configurando automáticamente..."
                        : "Configuring automatically...")
                        .font(.body)
                        .foregroundColor(.secondary)
                }
                .padding(.top, 20)
            } else if let result = appState.phaseResults[.pathResolution] {
                switch result {
                case .success(let details):
                    VStack(spacing: 16) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 48))
                            .foregroundColor(.green)

                        Text(details)
                            .font(.headline)

                        if let audit = appState.auditResult {
                            GlassCard {
                                VStack(alignment: .leading, spacing: 8) {
                                    HStack {
                                        Image(systemName: "doc.text")
                                            .foregroundColor(.accentColor)
                                        Text(Locale.isSpanish ? "Archivo modificado:" : "Modified file:")
                                            .font(.system(size: 13, weight: .medium))
                                    }
                                    Text(audit.shellProfilePath)
                                        .font(.system(size: 12, design: .monospaced))
                                        .foregroundColor(.secondary)
                                }
                            }
                            .padding(.horizontal, 40)
                        }
                    }
                    .padding(.top, 20)

                case .warning(let message, _):
                    VStack(spacing: 16) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .font(.system(size: 48))
                            .foregroundColor(.orange)

                        Text(message)
                            .font(.body)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.top, 20)

                case .failure(let error):
                    VStack(spacing: 16) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 48))
                            .foregroundColor(.red)

                        Text(error.humanReadableMessage)
                            .font(.body)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)
                    }
                    .padding(.top, 20)
                }
            }

            Spacer()
        }
    }
}
