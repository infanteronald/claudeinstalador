import Foundation

struct SystemAuditResult {
    let macOSVersion: OperatingSystemVersion
    let macOSVersionString: String
    let architecture: CPUArchitecture
    let chipName: String
    let totalRAMGB: Double
    let availableRAMGB: Double
    let shellType: ShellType
    let shellProfilePath: String
    let conflicts: [ConflictingInstallation]
    let existingClaudeVersion: String?
    let isClaudeAlreadyInstalled: Bool

    var meetsMinimumRequirements: Bool {
        macOSVersion.majorVersion >= 13 && totalRAMGB >= 4.0
    }

    var macOSDisplayString: String {
        "\(macOSVersion.majorVersion).\(macOSVersion.minorVersion).\(macOSVersion.patchVersion)"
    }
}

enum CPUArchitecture: String, Codable {
    case arm64 = "darwin-arm64"
    case x64 = "darwin-x64"

    var displayName: String {
        switch self {
        case .arm64: return "Apple Silicon (ARM64)"
        case .x64: return "Intel (x64)"
        }
    }

    var downloadPlatform: String { rawValue }
}

enum ShellType: String, Codable {
    case zsh
    case bash

    var displayName: String {
        switch self {
        case .zsh: return "Zsh"
        case .bash: return "Bash"
        }
    }

    var primaryProfilePath: String {
        let home = FileManager.default.homeDirectoryForCurrentUser.path
        switch self {
        case .zsh: return "\(home)/.zshrc"
        case .bash: return "\(home)/.bash_profile"
        }
    }

    var fallbackProfilePath: String {
        let home = FileManager.default.homeDirectoryForCurrentUser.path
        switch self {
        case .zsh: return "\(home)/.zshenv"
        case .bash: return "\(home)/.bashrc"
        }
    }

    var shellBinary: String {
        switch self {
        case .zsh: return "/bin/zsh"
        case .bash: return "/bin/bash"
        }
    }
}

struct ConflictingInstallation: Identifiable {
    let id = UUID()
    let path: String
    let type: ConflictType
    let description: String
    let canAutoResolve: Bool
}
