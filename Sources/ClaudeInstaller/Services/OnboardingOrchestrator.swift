import Foundation
import AppKit

final class OnboardingOrchestrator: @unchecked Sendable {

    /// Open Finder at the specified project directory
    func openFinderToProject(path: String) {
        let expandedPath = FileSystemHelper.expandPath(path)
        NSWorkspace.shared.selectFile(nil, inFileViewerRootedAtPath: expandedPath)
    }

    /// Launch Terminal.app with Claude Code in the specified project directory
    func launchTerminalWithClaude(at projectPath: String) async throws {
        let expandedPath = FileSystemHelper.expandPath(projectPath)

        // Write AppleScript to a temp file to avoid shell quoting issues
        let scriptContent = """
        tell application "Terminal"
            activate
            do script "cd \\"\(expandedPath)\\" && claude"
        end tell
        """

        let tempScript = FileManager.default.temporaryDirectory
            .appendingPathComponent("claude_launch_\(ProcessInfo.processInfo.processIdentifier).scpt")
        try scriptContent.write(to: tempScript, atomically: true, encoding: .utf8)
        defer { try? FileManager.default.removeItem(at: tempScript) }

        let result = try await ShellExecutor.run(
            "osascript \"\(tempScript.path)\"",
            timeoutSeconds: 10
        )
        if !result.succeeded && result.exitCode != -1 {
            throw InstallerError.terminalLaunchFailed(result.errorOutput)
        }
    }

    /// Run `claude doctor` diagnostic and return the output
    func runDoctorDiagnostic() async throws -> String {
        let claudePath = FileSystemHelper.expandPath("~/.local/bin/claude")
        guard FileSystemHelper.exists(claudePath) else {
            return Locale.isSpanish
                ? "Claude Code no encontrado en ~/.local/bin/claude"
                : "Claude Code not found at ~/.local/bin/claude"
        }

        let result = try await ShellExecutor.run("\(claudePath) doctor 2>&1 || true")
        return result.output.isEmpty ? result.errorOutput : result.output
    }
}
