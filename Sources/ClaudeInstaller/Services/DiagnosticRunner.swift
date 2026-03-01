import Foundation

final class DiagnosticRunner: Sendable {

    struct DiagnosticReport {
        let claudeVersion: String?
        let claudePath: String?
        let shellType: String
        let pathConfigured: Bool
        let keychainAccessible: Bool
        let output: String
    }

    func runDiagnostics() async -> DiagnosticReport {
        let claudePath = FileSystemHelper.expandPath("~/.local/bin/claude")
        let exists = FileSystemHelper.exists(claudePath)

        // Get version
        var version: String? = nil
        if exists {
            if let result = try? await ShellExecutor.run("\(claudePath) --version 2>/dev/null"),
               result.succeeded {
                version = result.trimmedOutput
            }
        }

        // Check shell
        let shellPath = ProcessInfo.processInfo.environment["SHELL"] ?? "unknown"

        // Check PATH
        let pathResult = try? await ShellExecutor.run("echo $PATH")
        let pathConfigured = pathResult?.output.contains(".local/bin") ?? false

        // Check keychain
        let keychainResult = try? await ShellExecutor.run(
            "security find-generic-password -s com.anthropic.claude-code 2>/dev/null"
        )
        let keychainAccessible = keychainResult?.succeeded ?? false

        // Build report
        var output = ""
        output += Locale.isSpanish ? "=== Diagnóstico de Claude Code ===\n\n" : "=== Claude Code Diagnostics ===\n\n"
        output += "Claude Binary: \(exists ? claudePath : "NOT FOUND")\n"
        output += "Version: \(version ?? "N/A")\n"
        output += "Shell: \(shellPath)\n"
        output += "PATH configured: \(pathConfigured ? "YES" : "NO")\n"
        output += "Keychain: \(keychainAccessible ? "OK" : "NOT CONFIGURED")\n"
        output += "macOS: \(ProcessInfo.processInfo.operatingSystemVersionString)\n"
        output += "RAM: \(String(format: "%.1f", Double(ProcessInfo.processInfo.physicalMemory) / 1_073_741_824.0)) GB\n"

        return DiagnosticReport(
            claudeVersion: version,
            claudePath: exists ? claudePath : nil,
            shellType: shellPath,
            pathConfigured: pathConfigured,
            keychainAccessible: keychainAccessible,
            output: output
        )
    }
}
