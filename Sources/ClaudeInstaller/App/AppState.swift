import SwiftUI

@MainActor
final class AppState: ObservableObject {
    @Published var currentPhase: InstallationPhase = .welcome
    @Published var phaseResults: [InstallationPhase: PhaseResult] = [:]
    @Published var isProcessing: Bool = false
    @Published var currentError: InstallerError? = nil
    @Published var showError: Bool = false

    // Phase 1 results
    @Published var auditResult: SystemAuditResult? = nil

    // Phase 2 state
    @Published var downloadProgress: DownloadProgress? = nil
    @Published var installedVersion: String? = nil
    @Published var latestAvailableVersion: String? = nil
    @Published var updateAvailable: Bool = false

    // Phase 4 state
    @Published var selectedAuthMode: AuthMode = .browserOAuth
    @Published var apiKey: String = ""

    // Phase 5 state
    @Published var selectedSkillLevel: SkillLevel = .beginner
    @Published var selectedTrustLevel: TrustLevel = .moderate
    @Published var projectPath: String = ""

    // Services
    let systemAuditor = SystemAuditor()
    let conflictScanner = ConflictScanner()
    let binaryDownloader = BinaryDownloader()
    let pathConfigurator = PathConfigurator()
    let keychainManager = KeychainManager()
    let apiKeyManager = APIKeyManager()
    let claudeMDGenerator = ClaudeMDGenerator()
    let projectConfigurator = ProjectConfigurator()
    let settingsConfigurator = SettingsConfigurator()
    let environmentConfigurator = EnvironmentConfigurator()
    let onboardingOrchestrator = OnboardingOrchestrator()
    let menuBarManager = MenuBarManager()

    func setError(_ error: InstallerError) {
        currentError = error
        showError = true
    }

    func clearError() {
        currentError = nil
        showError = false
    }

    func advancePhase() {
        guard let nextPhase = InstallationPhase(rawValue: currentPhase.rawValue + 1) else { return }
        withAnimation(.easeInOut(duration: 0.4)) {
            currentPhase = nextPhase
        }
    }

    func goBack() {
        guard currentPhase.rawValue > 0,
              let prevPhase = InstallationPhase(rawValue: currentPhase.rawValue - 1) else { return }
        withAnimation(.easeInOut(duration: 0.4)) {
            currentPhase = prevPhase
        }
    }

    func markPhaseResult(_ phase: InstallationPhase, result: PhaseResult) {
        phaseResults[phase] = result
    }

    /// Skip authentication — user can configure later from the terminal
    func skipKeychainSetup() {
        markPhaseResult(.keychainSetup, result: .success(
            details: Locale.isSpanish
                ? "Omitido — podrás autenticarte al abrir Claude Code"
                : "Skipped — you can authenticate when you open Claude Code"
        ))
    }

    // MARK: - Phase Execution

    func executeCurrentPhase() async {
        isProcessing = true
        clearError()

        do {
            switch currentPhase {
            case .systemAudit:
                try await executeSystemAudit()
            case .binaryDownload:
                try await executeBinaryDownload()
            case .pathResolution:
                try await executePathResolution()
            case .keychainSetup:
                try await executeKeychainSetup()
            case .projectConfig:
                try await executeProjectConfig()
            case .onboarding:
                try await executeOnboarding()
            default:
                break
            }
        } catch let error as InstallerError {
            markPhaseResult(currentPhase, result: .failure(error: error))
            setError(error)
        } catch {
            let mapped = ErrorMapper.map(error)
            markPhaseResult(currentPhase, result: .failure(error: mapped))
            setError(mapped)
        }

        isProcessing = false
    }

    private func executeSystemAudit() async throws {
        let audit = try await systemAuditor.performAudit()
        auditResult = audit

        if !audit.meetsMinimumRequirements {
            if audit.macOSVersion.majorVersion < 13 {
                throw InstallerError.macOSTooOld(
                    current: audit.macOSDisplayString,
                    required: "13.0"
                )
            }
            if audit.totalRAMGB < 4.0 {
                throw InstallerError.insufficientRAM(
                    availableGB: audit.totalRAMGB,
                    requiredGB: 4.0
                )
            }
        }

        if !audit.conflicts.isEmpty {
            let conflictMessages = audit.conflicts.map { $0.description }.joined(separator: "\n")
            markPhaseResult(.systemAudit, result: .warning(
                message: conflictMessages,
                canContinue: true
            ))
        } else {
            markPhaseResult(.systemAudit, result: .success(details: ""))
        }
    }

    private func executeBinaryDownload() async throws {
        guard let audit = auditResult else {
            throw InstallerError.unknownError("System audit not completed")
        }

        // Always fetch the latest version to compare
        let latest = try await binaryDownloader.fetchLatestVersion()
        latestAvailableVersion = latest

        if audit.isClaudeAlreadyInstalled, let currentVersion = audit.existingClaudeVersion {
            installedVersion = currentVersion

            // Compare versions to detect if update is available
            if isVersionNewer(latest, than: currentVersion) {
                updateAvailable = true
                markPhaseResult(.binaryDownload, result: .warning(
                    message: Locale.isSpanish
                        ? "Versión actual: v\(currentVersion). Nueva versión disponible: v\(latest)"
                        : "Current version: v\(currentVersion). New version available: v\(latest)",
                    canContinue: true
                ))
                // Don't auto-advance — let user decide to update or skip
                return
            } else {
                updateAvailable = false
                markPhaseResult(.binaryDownload, result: .success(
                    details: Locale.isSpanish
                        ? "Claude Code v\(currentVersion) está actualizado"
                        : "Claude Code v\(currentVersion) is up to date"
                ))
                return
            }
        }

        // Fresh install
        await downloadAndInstall(version: latest, architecture: audit.architecture)
    }

    /// Download and install a specific version (used for fresh install and updates)
    func downloadAndInstall(version: String, architecture: CPUArchitecture) async {
        isProcessing = true
        clearError()
        let startTime = Date()

        do {
            let fileURL = try await binaryDownloader.downloadBinary(
                version: version,
                platform: architecture
            ) { [weak self] progress in
                Task { @MainActor in
                    self?.downloadProgress = DownloadProgress(
                        bytesDownloaded: progress.bytesDownloaded,
                        totalBytes: progress.totalBytes,
                        startTime: startTime
                    )
                }
            }

            try await binaryDownloader.installBinary(downloadedURL: fileURL, version: version)
            installedVersion = version
            updateAvailable = false

            markPhaseResult(.binaryDownload, result: .success(
                details: Locale.isSpanish
                    ? "Claude Code v\(version) instalado correctamente"
                    : "Claude Code v\(version) installed successfully"
            ))
        } catch {
            let mapped = (error as? InstallerError) ?? ErrorMapper.map(error)
            markPhaseResult(.binaryDownload, result: .failure(error: mapped))
            setError(mapped)
        }

        isProcessing = false
    }

    /// Compare two semantic version strings (e.g., "2.1.44" vs "2.1.50")
    private func isVersionNewer(_ newVersion: String, than currentVersion: String) -> Bool {
        let newParts = newVersion.split(separator: ".").compactMap { Int($0) }
        let currentParts = currentVersion.split(separator: ".").compactMap { Int($0) }

        let maxLen = max(newParts.count, currentParts.count)
        for i in 0..<maxLen {
            let newPart = i < newParts.count ? newParts[i] : 0
            let currentPart = i < currentParts.count ? currentParts[i] : 0
            if newPart > currentPart { return true }
            if newPart < currentPart { return false }
        }
        return false // equal
    }

    private func executePathResolution() async throws {
        guard let audit = auditResult else {
            throw InstallerError.unknownError("System audit not completed")
        }

        try await pathConfigurator.ensurePathConfigured(
            shell: audit.shellType,
            profilePath: audit.shellProfilePath
        )

        let works = try await pathConfigurator.verifyPathWorks(shell: audit.shellType)
        if works {
            markPhaseResult(.pathResolution, result: .success(
                details: Locale.isSpanish ? "PATH configurado correctamente" : "PATH configured successfully"
            ))
        } else {
            try await pathConfigurator.createSystemFallback()
            markPhaseResult(.pathResolution, result: .warning(
                message: Locale.isSpanish
                    ? "Se usó configuración alternativa del sistema"
                    : "System-level fallback configuration used",
                canContinue: true
            ))
        }
    }

    private func executeKeychainSetup() async throws {
        switch selectedAuthMode {
        case .browserOAuth:
            // Open browser directly — do NOT run `claude auth status` or any
            // interactive commands that could hang the UI.
            try await keychainManager.triggerOAuthLogin()
            markPhaseResult(.keychainSetup, result: .success(
                details: Locale.isSpanish
                    ? "Se abrió el navegador — completarás la autenticación al abrir Claude Code"
                    : "Browser opened — you'll complete authentication when you open Claude Code"
            ))
        case .directToken:
            let trimmedKey = apiKey.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !trimmedKey.isEmpty else {
                throw InstallerError.apiKeyInvalid
            }
            let valid = try await apiKeyManager.validateAPIKey(trimmedKey)
            guard valid else {
                throw InstallerError.apiKeyInvalid
            }
            try await keychainManager.storeAPIKey(trimmedKey)
            if let audit = auditResult {
                try await apiKeyManager.injectAPIKeyAsEnvVar(
                    trimmedKey,
                    shell: audit.shellType
                )
            }
            markPhaseResult(.keychainSetup, result: .success(
                details: Locale.isSpanish ? "Clave API configurada" : "API key configured"
            ))
        }
    }

    private func executeProjectConfig() async throws {
        let path = projectPath.isEmpty
            ? FileManager.default.homeDirectoryForCurrentUser.appendingPathComponent("Projects").path
            : projectPath

        try await claudeMDGenerator.generateAndWrite(
            skillLevel: selectedSkillLevel,
            projectPath: path
        )

        try await projectConfigurator.generateGitignore(at: path)
        try await projectConfigurator.generateClaudeignore(at: path)
        try await settingsConfigurator.configure(trustLevel: selectedTrustLevel)

        if let audit = auditResult {
            try await environmentConfigurator.setEnvironmentVariables(shell: audit.shellType)
        }

        markPhaseResult(.projectConfig, result: .success(
            details: Locale.isSpanish ? "Entorno configurado" : "Environment configured"
        ))
    }

    private func executeOnboarding() async throws {
        menuBarManager.install()

        markPhaseResult(.onboarding, result: .success(
            details: Locale.isSpanish ? "¡Todo listo!" : "All set!"
        ))
    }
}
