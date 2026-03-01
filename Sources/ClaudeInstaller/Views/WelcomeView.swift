import SwiftUI

struct WelcomeView: View {
    @EnvironmentObject var appState: AppState

    var body: some View {
        VStack(spacing: 20) {
            Spacer()

            // Logo area
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [.orange, .pink, .purple],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 100, height: 100)
                    .shadow(color: .purple.opacity(0.3), radius: 20, x: 0, y: 10)

                Image(systemName: "terminal.fill")
                    .font(.system(size: 44))
                    .foregroundColor(.white)
            }

            Text("Claude Code")
                .font(.system(size: 32, weight: .bold))

            Text(Locale.isSpanish ? "Instalador Inteligente" : "Smart Installer")
                .font(.system(size: 18, weight: .medium))
                .foregroundColor(.secondary)

            Text(welcomeDescription)
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 60)
                .fixedSize(horizontal: false, vertical: true)

            // Feature pills
            VStack(spacing: 8) {
                FeaturePill(
                    icon: "shield.checkered",
                    text: Locale.isSpanish ? "Instalación segura y automática" : "Secure automatic installation"
                )
                FeaturePill(
                    icon: "bolt.fill",
                    text: Locale.isSpanish ? "Sin conocimientos técnicos" : "No technical knowledge needed"
                )
                FeaturePill(
                    icon: "globe",
                    text: Locale.isSpanish ? "Configuración completa del entorno" : "Complete environment setup"
                )
            }
            .padding(.top, 8)

            Spacer()
        }
    }

    var welcomeDescription: String {
        Locale.isSpanish
            ? "Este instalador configurará Claude Code en tu Mac de forma completamente automática. No necesitas experiencia técnica previa."
            : "This installer will set up Claude Code on your Mac completely automatically. No prior technical experience needed."
    }
}

struct FeaturePill: View {
    let icon: String
    let text: String

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 13))
                .foregroundColor(.accentColor)
                .frame(width: 20)

            Text(text)
                .font(.system(size: 13))
                .foregroundColor(.primary)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.accentColor.opacity(0.08))
        )
    }
}
