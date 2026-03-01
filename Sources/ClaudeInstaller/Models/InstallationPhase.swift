import Foundation

enum InstallationPhase: Int, CaseIterable, Comparable, Identifiable {
    case welcome = 0
    case systemAudit = 1
    case binaryDownload = 2
    case pathResolution = 3
    case keychainSetup = 4
    case projectConfig = 5
    case onboarding = 6
    case complete = 7

    var id: Int { rawValue }

    static func < (lhs: InstallationPhase, rhs: InstallationPhase) -> Bool {
        lhs.rawValue < rhs.rawValue
    }

    var titleES: String {
        switch self {
        case .welcome: return "Bienvenida"
        case .systemAudit: return "Verificación del Sistema"
        case .binaryDownload: return "Descarga"
        case .pathResolution: return "Configuración PATH"
        case .keychainSetup: return "Autenticación"
        case .projectConfig: return "Configuración"
        case .onboarding: return "Finalización"
        case .complete: return "Completado"
        }
    }

    var titleEN: String {
        switch self {
        case .welcome: return "Welcome"
        case .systemAudit: return "System Check"
        case .binaryDownload: return "Download"
        case .pathResolution: return "PATH Setup"
        case .keychainSetup: return "Authentication"
        case .projectConfig: return "Configuration"
        case .onboarding: return "Finishing"
        case .complete: return "Complete"
        }
    }

    var title: String {
        Locale.isSpanish ? titleES : titleEN
    }

    var descriptionES: String {
        switch self {
        case .welcome: return "Preparando tu instalación de Claude Code"
        case .systemAudit: return "Verificando compatibilidad del sistema"
        case .binaryDownload: return "Descargando Claude Code"
        case .pathResolution: return "Configurando variables de entorno"
        case .keychainSetup: return "Configurando autenticación segura"
        case .projectConfig: return "Preparando el entorno de desarrollo"
        case .onboarding: return "Finalizando la configuración"
        case .complete: return "¡Todo listo!"
        }
    }

    var descriptionEN: String {
        switch self {
        case .welcome: return "Preparing your Claude Code installation"
        case .systemAudit: return "Checking system compatibility"
        case .binaryDownload: return "Downloading Claude Code"
        case .pathResolution: return "Setting up environment variables"
        case .keychainSetup: return "Setting up secure authentication"
        case .projectConfig: return "Preparing the development environment"
        case .onboarding: return "Finishing setup"
        case .complete: return "All set!"
        }
    }

    var phaseDescription: String {
        Locale.isSpanish ? descriptionES : descriptionEN
    }

    var phaseNumber: Int? {
        switch self {
        case .welcome, .complete: return nil
        default: return rawValue
        }
    }

    /// Phases that show in the progress bar
    static var trackablePhases: [InstallationPhase] {
        [.systemAudit, .binaryDownload, .pathResolution, .keychainSetup, .projectConfig, .onboarding]
    }
}

extension Locale {
    static var isSpanish: Bool {
        let lang = Locale.current.language.languageCode?.identifier ?? "en"
        return lang.hasPrefix("es")
    }
}
