import SwiftUI

struct ProjectConfigView: View {
    @EnvironmentObject var appState: AppState

    var body: some View {
        VStack(spacing: 20) {
            Text(Locale.isSpanish ? "Configuración del Proyecto" : "Project Configuration")
                .font(.system(size: 24, weight: .bold))
                .padding(.top, 20)

            if let result = appState.phaseResults[.projectConfig], result.isSuccess {
                configCompleteView
            } else if appState.isProcessing {
                ProgressView()
                    .scaleEffect(1.2)
                    .padding()
                Text(Locale.isSpanish ? "Configurando entorno..." : "Setting up environment...")
                    .font(.body)
                    .foregroundColor(.secondary)
            } else {
                configFormView
            }

            Spacer()
        }
    }

    var configFormView: some View {
        VStack(spacing: 20) {
            // Skill level selector
            VStack(alignment: .leading, spacing: 8) {
                Text(Locale.isSpanish
                    ? "Tu nivel de experiencia técnica:"
                    : "Your technical experience level:")
                    .font(.system(size: 14, weight: .medium))

                SkillLevelPickerView(selectedLevel: $appState.selectedSkillLevel)
            }
            .padding(.horizontal, 40)

            // Project path
            VStack(alignment: .leading, spacing: 8) {
                Text(Locale.isSpanish
                    ? "Directorio del proyecto (opcional):"
                    : "Project directory (optional):")
                    .font(.system(size: 14, weight: .medium))

                HStack {
                    TextField(
                        Locale.isSpanish ? "~/Projects" : "~/Projects",
                        text: $appState.projectPath
                    )
                    .textFieldStyle(.roundedBorder)
                    .font(.system(size: 13, design: .monospaced))

                    Button(action: selectFolder) {
                        Image(systemName: "folder")
                    }
                }

                Text(Locale.isSpanish
                    ? "Se crearán CLAUDE.md, .gitignore y .claudeignore aquí"
                    : "CLAUDE.md, .gitignore and .claudeignore will be created here")
                    .font(.system(size: 11))
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal, 40)

            // Trust level
            VStack(alignment: .leading, spacing: 8) {
                Text(Locale.isSpanish
                    ? "Nivel de permisos de Claude Code:"
                    : "Claude Code permission level:")
                    .font(.system(size: 14, weight: .medium))

                Picker("", selection: $appState.selectedTrustLevel) {
                    ForEach(TrustLevel.allCases) { level in
                        Text(level.title).tag(level)
                    }
                }
                .pickerStyle(.segmented)

                Text(appState.selectedTrustLevel.description)
                    .font(.system(size: 11))
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal, 40)
        }
    }

    var configCompleteView: some View {
        VStack(spacing: 16) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 48))
                .foregroundColor(.green)

            Text(Locale.isSpanish
                ? "Entorno configurado correctamente"
                : "Environment configured successfully")
                .font(.headline)

            VStack(alignment: .leading, spacing: 8) {
                configItem(
                    icon: "doc.text",
                    label: "CLAUDE.md",
                    detail: appState.selectedSkillLevel.title
                )
                configItem(
                    icon: "eye.slash",
                    label: ".gitignore + .claudeignore",
                    detail: Locale.isSpanish ? "Creados" : "Created"
                )
                configItem(
                    icon: "shield",
                    label: Locale.isSpanish ? "Permisos" : "Permissions",
                    detail: appState.selectedTrustLevel.title
                )
            }
            .padding(.horizontal, 60)
        }
        .padding(.top, 20)
    }

    func configItem(icon: String, label: String, detail: String) -> some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.accentColor)
                .frame(width: 20)
            Text(label)
                .font(.system(size: 13, weight: .medium))
            Spacer()
            Text(detail)
                .font(.system(size: 13))
                .foregroundColor(.secondary)
        }
    }

    func selectFolder() {
        let panel = NSOpenPanel()
        panel.canChooseDirectories = true
        panel.canChooseFiles = false
        panel.canCreateDirectories = true
        panel.allowsMultipleSelection = false
        panel.message = Locale.isSpanish
            ? "Selecciona el directorio de tu proyecto"
            : "Select your project directory"

        if panel.runModal() == .OK, let url = panel.url {
            appState.projectPath = url.path
        }
    }
}
