import SwiftUI

struct OnboardingCompleteView: View {
    @EnvironmentObject var appState: AppState
    @State private var diagnosticOutput: String = ""
    @State private var showDiagnostics: Bool = false

    var body: some View {
        VStack(spacing: 20) {
            Text(Locale.isSpanish ? "Finalización" : "Finishing Up")
                .font(.system(size: 24, weight: .bold))
                .padding(.top, 20)

            if appState.isProcessing {
                VStack(spacing: 16) {
                    ProgressView()
                        .scaleEffect(1.2)
                    Text(Locale.isSpanish
                        ? "Configurando acceso rápido..."
                        : "Setting up quick access...")
                        .font(.body)
                        .foregroundColor(.secondary)
                }
            } else if let result = appState.phaseResults[.onboarding], result.isSuccess {
                VStack(spacing: 16) {
                    Image(systemName: "party.popper.fill")
                        .font(.system(size: 48))
                        .foregroundColor(.orange)

                    Text(Locale.isSpanish
                        ? "¡Claude Code está listo!"
                        : "Claude Code is ready!")
                        .font(.system(size: 20, weight: .semibold))

                    // Summary
                    VStack(spacing: 12) {
                        summaryItem(
                            icon: "checkmark.circle.fill",
                            color: .green,
                            label: Locale.isSpanish
                                ? "Claude Code v\(appState.installedVersion ?? "?")"
                                : "Claude Code v\(appState.installedVersion ?? "?")"
                        )
                        summaryItem(
                            icon: "terminal.fill",
                            color: .accentColor,
                            label: Locale.isSpanish
                                ? "Accesible desde cualquier terminal"
                                : "Accessible from any terminal"
                        )
                        summaryItem(
                            icon: "menubar.rectangle",
                            color: .purple,
                            label: Locale.isSpanish
                                ? "Atajo en barra de menús instalado"
                                : "Menu bar shortcut installed"
                        )
                    }
                    .padding(.horizontal, 60)

                    // Quick actions
                    HStack(spacing: 12) {
                        Button(action: openTerminal) {
                            Label(
                                Locale.isSpanish ? "Abrir Terminal" : "Open Terminal",
                                systemImage: "terminal"
                            )
                        }
                        .buttonStyle(.bordered)

                        Button(action: { showDiagnostics.toggle() }) {
                            Label(
                                Locale.isSpanish ? "Diagnóstico" : "Diagnostics",
                                systemImage: "stethoscope"
                            )
                        }
                        .buttonStyle(.bordered)
                    }
                    .padding(.top, 8)

                    // Diagnostics panel
                    if showDiagnostics {
                        GlassCard {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(Locale.isSpanish ? "Resultado del Diagnóstico:" : "Diagnostic Result:")
                                    .font(.system(size: 12, weight: .semibold))

                                if diagnosticOutput.isEmpty {
                                    ProgressView()
                                        .scaleEffect(0.6)
                                } else {
                                    Text(diagnosticOutput)
                                        .font(.system(size: 11, design: .monospaced))
                                        .foregroundColor(.secondary)
                                        .textSelection(.enabled)
                                }
                            }
                        }
                        .padding(.horizontal, 40)
                        .transition(.opacity.combined(with: .move(edge: .bottom)))
                        .task {
                            let report = await DiagnosticRunner().runDiagnostics()
                            diagnosticOutput = report.output
                        }
                    }
                }
            }

            Spacer()
        }
        .animation(.easeInOut(duration: 0.2), value: showDiagnostics)
    }

    func summaryItem(icon: String, color: Color, label: String) -> some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .foregroundColor(color)
                .frame(width: 20)
            Text(label)
                .font(.system(size: 14))
            Spacer()
        }
    }

    func openTerminal() {
        Task {
            try? await appState.onboardingOrchestrator.launchTerminalWithClaude(
                at: appState.projectPath.isEmpty
                    ? FileManager.default.homeDirectoryForCurrentUser.path
                    : appState.projectPath
            )
        }
    }
}
