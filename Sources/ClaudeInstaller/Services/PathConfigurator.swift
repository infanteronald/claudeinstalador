import Foundation

final class PathConfigurator: Sendable {

    /// Ensure the PATH is configured to include ~/.local/bin
    func ensurePathConfigured(shell: ShellType, profilePath: String) async throws {
        let expandedPath = FileSystemHelper.expandPath(profilePath)
        let pathExport = "export PATH=\"$HOME/.local/bin:$PATH\""

        // Read current profile content
        let currentContent: String
        if FileSystemHelper.exists(expandedPath) {
            currentContent = (try? FileSystemHelper.readFile(expandedPath)) ?? ""
        } else {
            currentContent = ""
        }

        // Idempotency check: see if any form of .local/bin PATH export exists
        let patterns = [
            #"export\s+PATH\s*=.*\.local/bin"#,
            #"PATH\s*=.*\.local/bin"#,
            #"path\s*\+?=.*\.local/bin"#
        ]

        for pattern in patterns {
            if let regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive) {
                let range = NSRange(currentContent.startIndex..., in: currentContent)
                if regex.firstMatch(in: currentContent, range: range) != nil {
                    // Already configured
                    return
                }
            }
        }

        // Append PATH export with comment marker
        let exportBlock = "\n# Added by Claude Code Installer\n\(pathExport)\n"

        do {
            try FileSystemHelper.appendToFile(expandedPath, content: exportBlock)
        } catch {
            throw InstallerError.profileWriteFailed(
                path: profilePath,
                reason: error.localizedDescription
            )
        }
    }

    /// Verify that `claude` is accessible after PATH configuration
    func verifyPathWorks(shell: ShellType) async throws -> Bool {
        let result = try await ShellExecutor.run(
            shell: shell,
            command: "command -v claude"
        )
        return result.succeeded && !result.trimmedOutput.isEmpty
    }

    /// Create system-level fallback at /etc/paths.d/claude
    func createSystemFallback() async throws {
        let home = FileManager.default.homeDirectoryForCurrentUser.path
        let content = "\(home)/.local/bin"
        let fallbackPath = "/etc/paths.d/claude"

        // This requires admin privileges - use osascript for authorization
        let script = """
        do shell script "echo '\(content)' > \(fallbackPath)" with administrator privileges
        """

        let result = try await ShellExecutor.run("osascript -e '\(script)'")
        if !result.succeeded {
            throw InstallerError.profileWriteFailed(
                path: fallbackPath,
                reason: result.errorOutput
            )
        }
    }
}
