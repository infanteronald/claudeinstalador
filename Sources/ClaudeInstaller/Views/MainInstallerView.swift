import SwiftUI

struct MainInstallerView: View {
    @EnvironmentObject var appState: AppState

    var body: some View {
        VStack(spacing: 0) {
            // Progress bar (hidden on welcome and complete)
            if appState.currentPhase != .welcome && appState.currentPhase != .complete {
                PhaseProgressBar(
                    currentPhase: appState.currentPhase,
                    phaseResults: appState.phaseResults
                )
                Divider()
            }

            // Current phase view
            Group {
                switch appState.currentPhase {
                case .welcome:
                    WelcomeView()
                case .systemAudit:
                    SystemCheckView()
                case .binaryDownload:
                    DownloadProgressView()
                case .pathResolution:
                    PathConfigView()
                case .keychainSetup:
                    AuthenticationView()
                case .projectConfig:
                    ProjectConfigView()
                case .onboarding:
                    OnboardingCompleteView()
                case .complete:
                    CompletionView()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .transition(.asymmetric(
                insertion: .move(edge: .trailing).combined(with: .opacity),
                removal: .move(edge: .leading).combined(with: .opacity)
            ))
            .animation(.easeInOut(duration: 0.35), value: appState.currentPhase)

            Divider()

            // Navigation buttons
            NavigationBar()
                .padding(.horizontal, 24)
                .padding(.vertical, 12)
        }
        .background(Color(nsColor: .windowBackgroundColor))
        .alert(
            Locale.isSpanish ? "Error" : "Error",
            isPresented: $appState.showError,
            presenting: appState.currentError
        ) { error in
            if error.canRetry {
                Button(Locale.isSpanish ? "Reintentar" : "Retry") {
                    Task { await appState.executeCurrentPhase() }
                }
            }
            Button(Locale.isSpanish ? "Cerrar" : "Close", role: .cancel) {
                appState.clearError()
            }
        } message: { error in
            Text(error.humanReadableMessage)
        }
    }
}

struct NavigationBar: View {
    @EnvironmentObject var appState: AppState

    var body: some View {
        HStack {
            // Back button
            if appState.currentPhase.rawValue > 0 && appState.currentPhase != .complete {
                Button(action: { appState.goBack() }) {
                    HStack(spacing: 4) {
                        Image(systemName: "chevron.left")
                        Text(Locale.isSpanish ? "Atrás" : "Back")
                    }
                }
                .buttonStyle(.plain)
                .disabled(appState.isProcessing)
            }

            Spacer()

            // Processing indicator
            if appState.isProcessing {
                ProgressView()
                    .scaleEffect(0.7)
                    .padding(.trailing, 8)
            }

            // Continue button
            if appState.currentPhase == .welcome {
                Button(Locale.isSpanish ? "Comenzar" : "Get Started") {
                    appState.advancePhase()
                    Task { await appState.executeCurrentPhase() }
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
            } else if appState.currentPhase == .complete {
                // Buttons are in CompletionView itself
                EmptyView()
            } else if canAdvance {
                Button(Locale.isSpanish ? "Continuar" : "Continue") {
                    appState.advancePhase()
                    Task { await appState.executeCurrentPhase() }
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                .disabled(appState.isProcessing)
            }
        }
    }

    var canAdvance: Bool {
        guard let result = appState.phaseResults[appState.currentPhase] else { return false }
        return result.canContinue
    }
}

struct CompletionView: View {
    @EnvironmentObject var appState: AppState
    @State private var isLaunching = false

    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 64))
                .foregroundColor(.green)

            Text(Locale.isSpanish ? "¡Instalación Completada!" : "Installation Complete!")
                .font(.system(size: 28, weight: .bold))

            Text(completionMessage)
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)

            if let version = appState.installedVersion {
                Text("Claude Code v\(version)")
                    .font(.system(size: 14, weight: .medium, design: .monospaced))
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.accentColor.opacity(0.1))
                    )
            }

            // Primary action: Launch Claude Code
            Button(action: { launchClaude() }) {
                HStack(spacing: 10) {
                    if isLaunching {
                        ProgressView()
                            .scaleEffect(0.7)
                            .tint(.white)
                    } else {
                        Image(systemName: "terminal.fill")
                    }
                    Text(Locale.isSpanish ? "Iniciar Claude Code" : "Launch Claude Code")
                        .font(.system(size: 16, weight: .semibold))
                }
                .frame(minWidth: 220, minHeight: 20)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            .tint(.accentColor)
            .disabled(isLaunching)

            // Secondary actions
            HStack(spacing: 16) {
                Button(action: { openFinder() }) {
                    Label(
                        Locale.isSpanish ? "Abrir en Finder" : "Open in Finder",
                        systemImage: "folder"
                    )
                }
                .buttonStyle(.bordered)

                Button(action: {
                    NSApplication.shared.terminate(nil)
                }) {
                    Text(Locale.isSpanish ? "Cerrar instalador" : "Close installer")
                }
                .buttonStyle(.bordered)
            }

            Spacer()
        }
    }

    var completionMessage: String {
        Locale.isSpanish
            ? "Todo está configurado. Haz clic en el botón para abrir Claude Code en la terminal."
            : "Everything is set up. Click the button to open Claude Code in your terminal."
    }

    func launchClaude() {
        isLaunching = true
        Task {
            try? await appState.onboardingOrchestrator.launchTerminalWithClaude(
                at: appState.projectPath.isEmpty
                    ? FileManager.default.homeDirectoryForCurrentUser.path
                    : appState.projectPath
            )
            // Small delay so the user sees the launching state
            try? await Task.sleep(nanoseconds: 1_000_000_000)
            isLaunching = false
        }
    }

    func openFinder() {
        let path = appState.projectPath.isEmpty
            ? FileManager.default.homeDirectoryForCurrentUser.path
            : appState.projectPath
        NSWorkspace.shared.selectFile(nil, inFileViewerRootedAtPath: path)
    }
}
