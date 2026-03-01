import Foundation

/// Scans the entire system for all traces of Claude Code
final class NuclearScanner {
    private let home = FileManager.default.homeDirectoryForCurrentUser.path
    private let fm = FileManager.default

    func scan() async -> ScanResult {
        let start = Date()
        var traces: [ClaudeTrace] = []

        // Scan all categories in parallel
        await withTaskGroup(of: [ClaudeTrace].self) { group in
            group.addTask { await self.scanBinaries() }
            group.addTask { await self.scanConfigFiles() }
            group.addTask { await self.scanCacheFiles() }
            group.addTask { await self.scanShellProfiles() }
            group.addTask { await self.scanHomebrew() }
            group.addTask { await self.scanNpm() }
            group.addTask { await self.scanKeychain() }
            group.addTask { await self.scanOther() }

            for await result in group {
                traces.append(contentsOf: result)
            }
        }

        // Sort by category then size
        traces.sort { ($0.category.rawValue, -$0.sizeBytes) < ($1.category.rawValue, -$1.sizeBytes) }

        return ScanResult(traces: traces, scanDuration: Date().timeIntervalSince(start))
    }

    // MARK: - Binary scanning

    private func scanBinaries() async -> [ClaudeTrace] {
        var traces: [ClaudeTrace] = []

        // ~/.local/bin/claude (symlink)
        let symlinkPath = "\(home)/.local/bin/claude"
        if fm.fileExists(atPath: symlinkPath) {
            traces.append(ClaudeTrace(
                category: .binary,
                path: symlinkPath,
                description: "Claude Code symlink",
                descriptionES: "Enlace simbólico de Claude Code",
                sizeBytes: fileSize(symlinkPath),
                canRemove: true
            ))
        }

        // ~/.local/share/claude/ (versions directory)
        let versionsDir = "\(home)/.local/share/claude"
        if fm.fileExists(atPath: versionsDir) {
            traces.append(ClaudeTrace(
                category: .binary,
                path: versionsDir,
                description: "Claude Code binaries and versions",
                descriptionES: "Binarios y versiones de Claude Code",
                sizeBytes: directorySize(versionsDir),
                canRemove: true
            ))
        }

        // /usr/local/bin/claude (legacy)
        let legacyPath = "/usr/local/bin/claude"
        if fm.fileExists(atPath: legacyPath) {
            traces.append(ClaudeTrace(
                category: .binary,
                path: legacyPath,
                description: "Legacy Claude Code binary",
                descriptionES: "Binario legacy de Claude Code",
                sizeBytes: fileSize(legacyPath),
                canRemove: true
            ))
        }

        return traces
    }

    // MARK: - Config scanning

    private func scanConfigFiles() async -> [ClaudeTrace] {
        var traces: [ClaudeTrace] = []

        // ~/.claude/ (config directory)
        let claudeDir = "\(home)/.claude"
        if fm.fileExists(atPath: claudeDir) {
            traces.append(ClaudeTrace(
                category: .config,
                path: claudeDir,
                description: "Claude Code configuration, settings, and memory",
                descriptionES: "Configuración, ajustes y memoria de Claude Code",
                sizeBytes: directorySize(claudeDir),
                canRemove: true
            ))
        }

        // CLAUDE.md files in home and common locations
        let claudeMDPaths = [
            "\(home)/CLAUDE.md",
            "\(home)/Projects/CLAUDE.md",
            "\(home)/Developer/CLAUDE.md",
            "\(home)/Desktop/CLAUDE.md",
        ]
        for path in claudeMDPaths {
            if fm.fileExists(atPath: path) {
                traces.append(ClaudeTrace(
                    category: .config,
                    path: path,
                    description: "CLAUDE.md project file",
                    descriptionES: "Archivo CLAUDE.md de proyecto",
                    sizeBytes: fileSize(path),
                    canRemove: true
                ))
            }
        }

        return traces
    }

    // MARK: - Cache scanning

    private func scanCacheFiles() async -> [ClaudeTrace] {
        var traces: [ClaudeTrace] = []

        // ~/Library/Caches/claude-code/
        let cachePaths = [
            "\(home)/Library/Caches/claude-code",
            "\(home)/Library/Caches/com.claudeinstaller",
            "\(home)/Library/Caches/com.anthropic.claude",
        ]
        for path in cachePaths {
            if fm.fileExists(atPath: path) {
                traces.append(ClaudeTrace(
                    category: .cache,
                    path: path,
                    description: "Cache directory: \(URL(fileURLWithPath: path).lastPathComponent)",
                    descriptionES: "Directorio de caché: \(URL(fileURLWithPath: path).lastPathComponent)",
                    sizeBytes: directorySize(path),
                    canRemove: true
                ))
            }
        }

        // Installer download cache
        let downloadCache = "\(home)/Library/Caches/com.claudeinstaller/downloads"
        if fm.fileExists(atPath: downloadCache) {
            traces.append(ClaudeTrace(
                category: .cache,
                path: downloadCache,
                description: "Downloaded installer binaries",
                descriptionES: "Binarios descargados por el instalador",
                sizeBytes: directorySize(downloadCache),
                canRemove: true
            ))
        }

        return traces
    }

    // MARK: - Shell profile scanning

    private func scanShellProfiles() async -> [ClaudeTrace] {
        var traces: [ClaudeTrace] = []

        let profilePaths = [
            "\(home)/.zshrc",
            "\(home)/.zshenv",
            "\(home)/.bash_profile",
            "\(home)/.bashrc",
        ]

        for path in profilePaths {
            guard fm.fileExists(atPath: path),
                  let content = try? String(contentsOfFile: path, encoding: .utf8) else { continue }

            var foundEntries: [String] = []

            // Check for PATH entries
            if content.contains(".local/bin") {
                foundEntries.append("PATH (.local/bin)")
            }

            // Check for ANTHROPIC_API_KEY
            if content.contains("ANTHROPIC_API_KEY") {
                foundEntries.append("ANTHROPIC_API_KEY")
            }

            // Check for CLAUDE_TELEMETRY
            if content.contains("CLAUDE_TELEMETRY") {
                foundEntries.append("CLAUDE_TELEMETRY")
            }

            if !foundEntries.isEmpty {
                let fileName = URL(fileURLWithPath: path).lastPathComponent
                traces.append(ClaudeTrace(
                    category: .shellProfile,
                    path: path,
                    description: "\(fileName): \(foundEntries.joined(separator: ", "))",
                    descriptionES: "\(fileName): \(foundEntries.joined(separator: ", "))",
                    sizeBytes: 0,
                    canRemove: true
                ))
            }
        }

        // /etc/paths.d/claude
        let systemPath = "/etc/paths.d/claude"
        if fm.fileExists(atPath: systemPath) {
            traces.append(ClaudeTrace(
                category: .shellProfile,
                path: systemPath,
                description: "System-level PATH configuration",
                descriptionES: "Configuración PATH a nivel de sistema",
                sizeBytes: fileSize(systemPath),
                canRemove: true
            ))
        }

        return traces
    }

    // MARK: - Homebrew scanning

    private func scanHomebrew() async -> [ClaudeTrace] {
        var traces: [ClaudeTrace] = []

        let brewPaths = [
            "/opt/homebrew/bin/claude",
            "/usr/local/Cellar/claude-code",
            "/opt/homebrew/Cellar/claude-code",
        ]

        for path in brewPaths {
            if fm.fileExists(atPath: path) {
                traces.append(ClaudeTrace(
                    category: .homebrew,
                    path: path,
                    description: "Homebrew installation: \(URL(fileURLWithPath: path).lastPathComponent)",
                    descriptionES: "Instalación Homebrew: \(URL(fileURLWithPath: path).lastPathComponent)",
                    sizeBytes: fileSize(path),
                    canRemove: true
                ))
            }
        }

        return traces
    }

    // MARK: - npm scanning

    private func scanNpm() async -> [ClaudeTrace] {
        var traces: [ClaudeTrace] = []

        let npmPaths = [
            "\(home)/.npm-global/bin/claude",
            "\(home)/.npm-global/lib/node_modules/@anthropic-ai",
            "/usr/local/lib/node_modules/@anthropic-ai",
        ]

        for path in npmPaths {
            if fm.fileExists(atPath: path) {
                traces.append(ClaudeTrace(
                    category: .npm,
                    path: path,
                    description: "npm global install: \(URL(fileURLWithPath: path).lastPathComponent)",
                    descriptionES: "Instalación npm global: \(URL(fileURLWithPath: path).lastPathComponent)",
                    sizeBytes: directorySize(path),
                    canRemove: true
                ))
            }
        }

        return traces
    }

    // MARK: - Keychain scanning

    private func scanKeychain() async -> [ClaudeTrace] {
        var traces: [ClaudeTrace] = []

        // Check for keychain entries (we can't read them, but we can check if they exist)
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: "com.anthropic.claude-code",
            kSecReturnAttributes as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]

        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)

        if status == errSecSuccess {
            traces.append(ClaudeTrace(
                category: .keychain,
                path: "Keychain: com.anthropic.claude-code",
                description: "API key stored in macOS Keychain",
                descriptionES: "Clave API almacenada en el Llavero de macOS",
                sizeBytes: 0,
                canRemove: true
            ))
        }

        return traces
    }

    // MARK: - Other traces

    private func scanOther() async -> [ClaudeTrace] {
        var traces: [ClaudeTrace] = []

        // ~/.config/claude/
        let configClaude = "\(home)/.config/claude"
        if fm.fileExists(atPath: configClaude) {
            traces.append(ClaudeTrace(
                category: .other,
                path: configClaude,
                description: "XDG config directory for Claude",
                descriptionES: "Directorio de configuración XDG para Claude",
                sizeBytes: directorySize(configClaude),
                canRemove: true
            ))
        }

        // ~/Library/Application Support/claude-code/
        let appSupport = "\(home)/Library/Application Support/claude-code"
        if fm.fileExists(atPath: appSupport) {
            traces.append(ClaudeTrace(
                category: .other,
                path: appSupport,
                description: "Application Support data",
                descriptionES: "Datos de Application Support",
                sizeBytes: directorySize(appSupport),
                canRemove: true
            ))
        }

        return traces
    }

    // MARK: - Helpers

    private func fileSize(_ path: String) -> Int64 {
        guard let attrs = try? fm.attributesOfItem(atPath: path),
              let size = attrs[.size] as? Int64 else { return 0 }
        return size
    }

    private func directorySize(_ path: String) -> Int64 {
        guard let enumerator = fm.enumerator(atPath: path) else { return 0 }
        var total: Int64 = 0
        while let file = enumerator.nextObject() as? String {
            let fullPath = "\(path)/\(file)"
            if let attrs = try? fm.attributesOfItem(atPath: fullPath),
               let size = attrs[.size] as? Int64 {
                total += size
            }
        }
        return total
    }
}
