import SwiftUI

struct AuthenticationView: View {
    @EnvironmentObject var appState: AppState

    var body: some View {
        VStack(spacing: 20) {
            Text(Locale.isSpanish ? "Autenticación" : "Authentication")
                .font(.system(size: 24, weight: .bold))
                .padding(.top, 20)

            Text(Locale.isSpanish
                ? "Elige cómo quieres conectar tu cuenta de Anthropic"
                : "Choose how to connect your Anthropic account")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)

            if let result = appState.phaseResults[.keychainSetup], result.isSuccess {
                successView
            } else if appState.isProcessing {
                ProgressView()
                    .scaleEffect(1.2)
                    .padding(.top, 20)
                Text(Locale.isSpanish ? "Configurando autenticación..." : "Setting up authentication...")
                    .font(.body)
                    .foregroundColor(.secondary)
            } else {
                authOptionsView
            }

            Spacer()

            // Skip button — always visible unless already completed (even while processing)
            if appState.phaseResults[.keychainSetup]?.isSuccess != true {
                Button(action: {
                    appState.isProcessing = false
                    appState.skipKeychainSetup()
                }) {
                    Text(appState.isProcessing
                        ? (Locale.isSpanish
                            ? "Cancelar y omitir — autenticaré después"
                            : "Cancel and skip — I'll authenticate later")
                        : (Locale.isSpanish
                            ? "Omitir por ahora — autenticaré después"
                            : "Skip for now — I'll authenticate later"))
                        .font(.system(size: 12))
                        .foregroundColor(appState.isProcessing ? .orange : .secondary)
                }
                .buttonStyle(.plain)
                .padding(.bottom, 8)
            }
        }
    }

    var authOptionsView: some View {
        VStack(spacing: 16) {
            // Browser OAuth option
            GlassCard(isSelected: appState.selectedAuthMode == .browserOAuth) {
                Button(action: {
                    appState.selectedAuthMode = .browserOAuth
                }) {
                    HStack(spacing: 12) {
                        Image(systemName: "globe")
                            .font(.system(size: 24))
                            .foregroundColor(.accentColor)
                            .frame(width: 40)

                        VStack(alignment: .leading, spacing: 4) {
                            Text(Locale.isSpanish
                                ? "Iniciar sesión con navegador"
                                : "Sign in with browser")
                                .font(.system(size: 15, weight: .semibold))
                            Text(Locale.isSpanish
                                ? "Se abrirá tu navegador para autorizar (recomendado)"
                                : "Your browser will open to authorize (recommended)")
                                .font(.system(size: 12))
                                .foregroundColor(.secondary)
                        }

                        Spacer()

                        if appState.selectedAuthMode == .browserOAuth {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.accentColor)
                        }
                    }
                }
                .buttonStyle(.plain)
            }

            // Direct Token option
            GlassCard(isSelected: appState.selectedAuthMode == .directToken) {
                Button(action: {
                    appState.selectedAuthMode = .directToken
                }) {
                    HStack(spacing: 12) {
                        Image(systemName: "key.fill")
                            .font(.system(size: 24))
                            .foregroundColor(.orange)
                            .frame(width: 40)

                        VStack(alignment: .leading, spacing: 4) {
                            Text(Locale.isSpanish
                                ? "Ingresar clave API manualmente"
                                : "Enter API key manually")
                                .font(.system(size: 15, weight: .semibold))
                            Text(Locale.isSpanish
                                ? "Pega tu clave desde console.anthropic.com"
                                : "Paste your key from console.anthropic.com")
                                .font(.system(size: 12))
                                .foregroundColor(.secondary)
                        }

                        Spacer()

                        if appState.selectedAuthMode == .directToken {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.accentColor)
                        }
                    }
                }
                .buttonStyle(.plain)
            }

            // API Key input field (shown when direct token mode is selected)
            if appState.selectedAuthMode == .directToken {
                VStack(spacing: 8) {
                    SecureField(
                        Locale.isSpanish ? "Pega tu clave API aquí..." : "Paste your API key here...",
                        text: $appState.apiKey
                    )
                    .textFieldStyle(.roundedBorder)
                    .font(.system(size: 14, design: .monospaced))

                    Button(action: {
                        appState.apiKeyManager.openAnthropicConsole()
                    }) {
                        HStack(spacing: 4) {
                            Image(systemName: "arrow.up.right.square")
                            Text(Locale.isSpanish
                                ? "Abrir consola de Anthropic"
                                : "Open Anthropic Console")
                        }
                        .font(.system(size: 12))
                    }
                    .buttonStyle(.link)
                }
                .padding(.horizontal, 16)
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .padding(.horizontal, 40)
        .padding(.top, 10)
        .animation(.easeInOut(duration: 0.2), value: appState.selectedAuthMode)
    }

    var successView: some View {
        VStack(spacing: 16) {
            Image(systemName: "checkmark.shield.fill")
                .font(.system(size: 48))
                .foregroundColor(.green)

            Text(Locale.isSpanish
                ? "Autenticación configurada correctamente"
                : "Authentication configured successfully")
                .font(.headline)
        }
        .padding(.top, 40)
    }
}
