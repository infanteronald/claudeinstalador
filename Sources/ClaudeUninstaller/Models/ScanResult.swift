import Foundation

/// Represents a single trace of Claude Code found on the system
struct ClaudeTrace: Identifiable {
    let id = UUID()
    let category: TraceCategory
    let path: String
    let description: String
    let descriptionES: String
    let sizeBytes: Int64
    let canRemove: Bool

    var displayDescription: String {
        isSpanish ? descriptionES : description
    }

    var sizeDisplay: String {
        if sizeBytes < 1024 {
            return "\(sizeBytes) B"
        } else if sizeBytes < 1024 * 1024 {
            return String(format: "%.1f KB", Double(sizeBytes) / 1024)
        } else {
            return String(format: "%.1f MB", Double(sizeBytes) / (1024 * 1024))
        }
    }
}

enum TraceCategory: String, CaseIterable, Identifiable {
    case binary = "binary"
    case config = "config"
    case cache = "cache"
    case shellProfile = "shell"
    case keychain = "keychain"
    case homebrew = "homebrew"
    case npm = "npm"
    case other = "other"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .binary: return "terminal.fill"
        case .config: return "gearshape.fill"
        case .cache: return "archivebox.fill"
        case .shellProfile: return "doc.text.fill"
        case .keychain: return "key.fill"
        case .homebrew: return "mug.fill"
        case .npm: return "shippingbox.fill"
        case .other: return "questionmark.circle.fill"
        }
    }

    var displayName: String {
        isSpanish ? displayNameES : displayNameEN
    }

    var displayNameEN: String {
        switch self {
        case .binary: return "Binaries"
        case .config: return "Configuration"
        case .cache: return "Cache"
        case .shellProfile: return "Shell Profile"
        case .keychain: return "Keychain"
        case .homebrew: return "Homebrew"
        case .npm: return "npm"
        case .other: return "Other"
        }
    }

    var displayNameES: String {
        switch self {
        case .binary: return "Binarios"
        case .config: return "Configuración"
        case .cache: return "Caché"
        case .shellProfile: return "Perfil de Shell"
        case .keychain: return "Llavero"
        case .homebrew: return "Homebrew"
        case .npm: return "npm"
        case .other: return "Otros"
        }
    }

    var dangerColor: String {
        switch self {
        case .binary, .homebrew, .npm: return "red"
        case .config, .shellProfile: return "orange"
        case .cache, .other: return "yellow"
        case .keychain: return "red"
        }
    }
}

/// Overall scan result
struct ScanResult {
    let traces: [ClaudeTrace]
    let scanDuration: TimeInterval

    var totalSizeBytes: Int64 {
        traces.reduce(0) { $0 + $1.sizeBytes }
    }

    var totalSizeDisplay: String {
        if totalSizeBytes < 1024 * 1024 {
            return String(format: "%.1f KB", Double(totalSizeBytes) / 1024)
        } else {
            return String(format: "%.1f MB", Double(totalSizeBytes) / (1024 * 1024))
        }
    }

    var removableTraces: [ClaudeTrace] {
        traces.filter { $0.canRemove }
    }

    var tracesByCategory: [TraceCategory: [ClaudeTrace]] {
        Dictionary(grouping: traces, by: { $0.category })
    }

    var isEmpty: Bool { traces.isEmpty }
}

/// Language detection (standalone, not depending on installer module)
var isSpanish: Bool {
    let lang = Locale.current.language.languageCode?.identifier ?? "en"
    return lang.hasPrefix("es")
}
