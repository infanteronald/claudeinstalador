import Foundation
import AppKit

final class APIKeyManager: @unchecked Sendable {
    private let anthropicConsoleURL = "https://console.anthropic.com/settings/keys"

    /// Open the Anthropic console for API key creation
    func openAnthropicConsole() {
        if let url = URL(string: anthropicConsoleURL) {
            NSWorkspace.shared.open(url)
        }
    }

    /// Validate an API key by making a lightweight API call
    func validateAPIKey(_ key: String) async throws -> Bool {
        let trimmedKey = key.trimmingCharacters(in: .whitespacesAndNewlines)

        // Basic format validation
        guard trimmedKey.hasPrefix("sk-ant-") || trimmedKey.hasPrefix("sk-") else {
            return false
        }

        // Test the key with a minimal API request
        guard let url = URL(string: "https://api.anthropic.com/v1/messages") else {
            throw InstallerError.apiKeyValidationFailed("Invalid API URL")
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue(trimmedKey, forHTTPHeaderField: "x-api-key")
        request.setValue("2023-06-01", forHTTPHeaderField: "anthropic-version")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        // Send a minimal request to check authentication
        let body: [String: Any] = [
            "model": "claude-haiku-4-5-20251001",
            "max_tokens": 1,
            "messages": [["role": "user", "content": "hi"]]
        ]
        request.httpBody = try JSONSerialization.data(withJSONObject: body)

        let (_, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw InstallerError.apiKeyValidationFailed("No HTTP response")
        }

        // 200 = valid, 401 = invalid key, other = network issue
        switch httpResponse.statusCode {
        case 200:
            return true
        case 401:
            return false
        case 400:
            // Bad request but key was accepted — key is valid
            return true
        default:
            throw InstallerError.apiKeyValidationFailed("HTTP \(httpResponse.statusCode)")
        }
    }

    /// Inject the API key as an environment variable in the shell profile
    func injectAPIKeyAsEnvVar(_ key: String, shell: ShellType) async throws {
        let profilePath = shell.primaryProfilePath
        let expandedPath = FileSystemHelper.expandPath(profilePath)

        // Read current content
        let currentContent: String
        if FileSystemHelper.exists(expandedPath) {
            currentContent = (try? FileSystemHelper.readFile(expandedPath)) ?? ""
        } else {
            currentContent = ""
        }

        // Check if already set (idempotent)
        if currentContent.contains("ANTHROPIC_API_KEY") {
            // Replace existing
            let lines = currentContent.components(separatedBy: "\n")
            var newLines: [String] = []
            for line in lines {
                if line.contains("ANTHROPIC_API_KEY") {
                    newLines.append("export ANTHROPIC_API_KEY=\"\(key)\"")
                } else {
                    newLines.append(line)
                }
            }
            try FileSystemHelper.writeFile(expandedPath, content: newLines.joined(separator: "\n"))
        } else {
            // Append new
            let exportLine = "\n# Claude Code API Key (added by Claude Code Installer)\nexport ANTHROPIC_API_KEY=\"\(key)\"\n"
            try FileSystemHelper.appendToFile(expandedPath, content: exportLine)
        }
    }
}
