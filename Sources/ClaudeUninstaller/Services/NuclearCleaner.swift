import Foundation
import Security

/// Removes all traces of Claude Code from the system
final class NuclearCleaner {
    private let fm = FileManager.default

    struct CleanupResult {
        let removedCount: Int
        let failedCount: Int
        let failures: [String]
        let freedBytes: Int64
    }

    /// Remove all provided traces
    func detonate(traces: [ClaudeTrace]) async -> CleanupResult {
        var removed = 0
        var failed = 0
        var failures: [String] = []
        var freedBytes: Int64 = 0

        for trace in traces {
            guard trace.canRemove else { continue }

            let success: Bool
            switch trace.category {
            case .shellProfile:
                success = cleanShellProfile(trace)
            case .keychain:
                success = cleanKeychain()
            default:
                success = removeFileOrDirectory(trace.path)
            }

            if success {
                removed += 1
                freedBytes += trace.sizeBytes
            } else {
                failed += 1
                failures.append(trace.path)
            }
        }

        return CleanupResult(
            removedCount: removed,
            failedCount: failed,
            failures: failures,
            freedBytes: freedBytes
        )
    }

    // MARK: - File/Directory removal

    private func removeFileOrDirectory(_ path: String) -> Bool {
        guard fm.fileExists(atPath: path) else { return true }
        do {
            try fm.removeItem(atPath: path)
            return true
        } catch {
            return false
        }
    }

    // MARK: - Shell profile cleaning

    private func cleanShellProfile(_ trace: ClaudeTrace) -> Bool {
        let path = trace.path
        guard let content = try? String(contentsOfFile: path, encoding: .utf8) else {
            return false
        }

        var lines = content.components(separatedBy: "\n")
        let originalCount = lines.count

        // Remove lines containing Claude-related entries
        lines.removeAll { line in
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            // PATH entries for .local/bin (Claude's install location)
            if trimmed.contains(".local/bin") && trimmed.contains("export PATH") {
                return true
            }
            // ANTHROPIC_API_KEY
            if trimmed.contains("ANTHROPIC_API_KEY") {
                return true
            }
            // CLAUDE_TELEMETRY
            if trimmed.contains("CLAUDE_TELEMETRY") {
                return true
            }
            return false
        }

        // Only write if something changed
        if lines.count != originalCount {
            let newContent = lines.joined(separator: "\n")
            do {
                try newContent.write(toFile: path, atomically: true, encoding: .utf8)
                return true
            } catch {
                return false
            }
        }

        return true
    }

    // MARK: - Keychain cleaning

    private func cleanKeychain() -> Bool {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: "com.anthropic.claude-code"
        ]
        let status = SecItemDelete(query as CFDictionary)
        return status == errSecSuccess || status == errSecItemNotFound
    }
}
