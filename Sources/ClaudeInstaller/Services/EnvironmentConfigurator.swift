import Foundation

final class EnvironmentConfigurator: Sendable {

    func setEnvironmentVariables(shell: ShellType) async throws {
        let profilePath = FileSystemHelper.expandPath(shell.primaryProfilePath)

        // Read current content
        let currentContent: String
        if FileSystemHelper.exists(profilePath) {
            currentContent = (try? FileSystemHelper.readFile(profilePath)) ?? ""
        } else {
            currentContent = ""
        }

        var additions: [String] = []

        // CLAUDE_TELEMETRY=0 to prevent TTY stalls
        if !currentContent.contains("CLAUDE_TELEMETRY") {
            additions.append("export CLAUDE_TELEMETRY=0")
        }

        if additions.isEmpty { return }

        let block = "\n# Claude Code environment (added by Claude Code Installer)\n"
            + additions.joined(separator: "\n") + "\n"

        do {
            try FileSystemHelper.appendToFile(profilePath, content: block)
        } catch {
            throw InstallerError.profileWriteFailed(
                path: shell.primaryProfilePath,
                reason: error.localizedDescription
            )
        }
    }
}
