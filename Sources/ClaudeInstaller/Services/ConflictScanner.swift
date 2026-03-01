import Foundation

final class ConflictScanner: Sendable {

    func scanForConflicts() async -> [ConflictingInstallation] {
        var conflicts: [ConflictingInstallation] = []

        // Check Homebrew installation
        let homebrewPath = "/opt/homebrew/bin/claude"
        if FileSystemHelper.exists(homebrewPath) {
            conflicts.append(ConflictingInstallation(
                path: homebrewPath,
                type: .homebrew,
                description: Locale.isSpanish
                    ? "Instalación de Claude Code vía Homebrew detectada"
                    : "Claude Code installation via Homebrew detected",
                canAutoResolve: false
            ))
        }

        // Check legacy Homebrew path (Intel)
        let legacyBrewPath = "/usr/local/bin/claude"
        if FileSystemHelper.exists(legacyBrewPath) {
            conflicts.append(ConflictingInstallation(
                path: legacyBrewPath,
                type: .homebrew,
                description: Locale.isSpanish
                    ? "Instalación legacy de Claude Code en /usr/local/bin"
                    : "Legacy Claude Code installation in /usr/local/bin",
                canAutoResolve: false
            ))
        }

        // Check NPM global installation
        let npmPaths = [
            FileSystemHelper.expandPath("~/.npm-global/bin/claude"),
            "/usr/local/lib/node_modules/@anthropic-ai/claude-code"
        ]
        for npmPath in npmPaths {
            if FileSystemHelper.exists(npmPath) {
                conflicts.append(ConflictingInstallation(
                    path: npmPath,
                    type: .npm,
                    description: Locale.isSpanish
                        ? "Instalación de Claude Code vía NPM detectada"
                        : "Claude Code installation via NPM detected",
                    canAutoResolve: false
                ))
            }
        }

        // Check if ~/.local/bin/claude is a broken symlink
        let localBinClaude = FileSystemHelper.expandPath("~/.local/bin/claude")
        if FileSystemHelper.exists(localBinClaude) {
            let attrs = try? FileManager.default.attributesOfItem(atPath: localBinClaude)
            if let type = attrs?[.type] as? FileAttributeType, type == .typeSymbolicLink {
                if !FileSystemHelper.isValidSymlink(localBinClaude) {
                    conflicts.append(ConflictingInstallation(
                        path: localBinClaude,
                        type: .brokenSymlink,
                        description: Locale.isSpanish
                            ? "Enlace simbólico roto en ~/.local/bin/claude"
                            : "Broken symlink at ~/.local/bin/claude",
                        canAutoResolve: true
                    ))
                }
            }
        }

        // Check for corrupt version binaries
        let versionsDir = FileSystemHelper.expandPath("~/.local/share/claude/versions")
        if FileSystemHelper.isDirectory(versionsDir) {
            if let contents = try? FileManager.default.contentsOfDirectory(atPath: versionsDir) {
                for item in contents {
                    let versionPath = "\(versionsDir)/\(item)"
                    // Check if the binary is actually executable
                    if !FileManager.default.isExecutableFile(atPath: versionPath) {
                        conflicts.append(ConflictingInstallation(
                            path: versionPath,
                            type: .corruptArtifact,
                            description: Locale.isSpanish
                                ? "Binario corrupto o no ejecutable: \(item)"
                                : "Corrupt or non-executable binary: \(item)",
                            canAutoResolve: true
                        ))
                    }
                }
            }
        }

        return conflicts
    }

    /// Attempt to resolve conflicts that can be auto-resolved
    func resolveConflict(_ conflict: ConflictingInstallation) async throws {
        guard conflict.canAutoResolve else { return }

        switch conflict.type {
        case .brokenSymlink:
            try FileSystemHelper.remove(conflict.path)
        case .corruptArtifact:
            try FileSystemHelper.remove(conflict.path)
        default:
            break
        }
    }
}
