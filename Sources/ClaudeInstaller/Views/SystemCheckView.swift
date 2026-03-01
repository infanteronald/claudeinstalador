import SwiftUI

struct SystemCheckView: View {
    @EnvironmentObject var appState: AppState

    var body: some View {
        VStack(spacing: 20) {
            Text(Locale.isSpanish ? "Verificación del Sistema" : "System Check")
                .font(.system(size: 24, weight: .bold))
                .padding(.top, 20)

            Text(Locale.isSpanish
                ? "Verificando que tu Mac cumple los requisitos..."
                : "Checking that your Mac meets the requirements...")
                .font(.body)
                .foregroundColor(.secondary)

            if let audit = appState.auditResult {
                VStack(spacing: 12) {
                    // macOS Version
                    StepCheckmark(
                        label: "macOS \(audit.macOSDisplayString)",
                        isComplete: true,
                        isActive: false,
                        hasFailed: audit.macOSVersion.majorVersion < 13
                    )

                    // RAM
                    StepCheckmark(
                        label: Locale.isSpanish
                            ? "RAM: \(String(format: "%.1f", audit.totalRAMGB)) GB"
                            : "RAM: \(String(format: "%.1f", audit.totalRAMGB)) GB",
                        isComplete: true,
                        isActive: false,
                        hasFailed: audit.totalRAMGB < 4.0
                    )

                    // Architecture
                    StepCheckmark(
                        label: Locale.isSpanish
                            ? "Procesador: \(audit.chipName)"
                            : "Processor: \(audit.chipName)",
                        isComplete: true,
                        isActive: false
                    )

                    // Shell
                    StepCheckmark(
                        label: "Shell: \(audit.shellType.displayName)",
                        isComplete: true,
                        isActive: false
                    )

                    // Existing installation
                    if let version = audit.existingClaudeVersion {
                        StepCheckmark(
                            label: Locale.isSpanish
                                ? "Claude Code v\(version) ya instalado"
                                : "Claude Code v\(version) already installed",
                            isComplete: true,
                            isActive: false,
                            hasWarning: true
                        )
                    }

                    // Conflicts
                    if !audit.conflicts.isEmpty {
                        Divider()
                        Text(Locale.isSpanish ? "Conflictos detectados:" : "Conflicts detected:")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.orange)
                            .frame(maxWidth: .infinity, alignment: .leading)

                        ForEach(audit.conflicts) { conflict in
                            StepCheckmark(
                                label: conflict.description,
                                isComplete: true,
                                isActive: false,
                                hasWarning: true
                            )
                        }
                    }
                }
                .padding(.horizontal, 40)
            } else if appState.isProcessing {
                VStack(spacing: 12) {
                    StepCheckmark(
                        label: Locale.isSpanish ? "Verificando versión de macOS..." : "Checking macOS version...",
                        isComplete: false, isActive: true
                    )
                    StepCheckmark(
                        label: Locale.isSpanish ? "Verificando memoria RAM..." : "Checking RAM...",
                        isComplete: false, isActive: false
                    )
                    StepCheckmark(
                        label: Locale.isSpanish ? "Detectando procesador..." : "Detecting processor...",
                        isComplete: false, isActive: false
                    )
                    StepCheckmark(
                        label: Locale.isSpanish ? "Buscando conflictos..." : "Scanning for conflicts...",
                        isComplete: false, isActive: false
                    )
                }
                .padding(.horizontal, 40)
            }

            Spacer()
        }
    }
}
