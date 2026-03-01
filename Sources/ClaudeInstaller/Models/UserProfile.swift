import Foundation

enum SkillLevel: String, CaseIterable, Identifiable, Codable {
    case beginner
    case intermediate
    case advanced
    case expert

    var id: String { rawValue }

    var titleES: String {
        switch self {
        case .beginner: return "Principiante"
        case .intermediate: return "Intermedio"
        case .advanced: return "Avanzado"
        case .expert: return "Experto"
        }
    }

    var titleEN: String {
        switch self {
        case .beginner: return "Beginner"
        case .intermediate: return "Intermediate"
        case .advanced: return "Advanced"
        case .expert: return "Expert"
        }
    }

    var title: String {
        Locale.isSpanish ? titleES : titleEN
    }

    var descriptionES: String {
        switch self {
        case .beginner: return "Nunca he usado la terminal ni herramientas de programación"
        case .intermediate: return "Tengo experiencia básica con la terminal y código"
        case .advanced: return "Trabajo frecuentemente con herramientas de desarrollo"
        case .expert: return "Soy desarrollador profesional de software"
        }
    }

    var descriptionEN: String {
        switch self {
        case .beginner: return "I've never used the terminal or programming tools"
        case .intermediate: return "I have basic experience with the terminal and code"
        case .advanced: return "I frequently work with development tools"
        case .expert: return "I'm a professional software developer"
        }
    }

    var skillDescription: String {
        Locale.isSpanish ? descriptionES : descriptionEN
    }

    var iconName: String {
        switch self {
        case .beginner: return "leaf"
        case .intermediate: return "hammer"
        case .advanced: return "wrench.and.screwdriver"
        case .expert: return "terminal"
        }
    }
}

enum AuthMode: String, CaseIterable, Identifiable {
    case browserOAuth
    case directToken

    var id: String { rawValue }

    var title: String {
        switch self {
        case .browserOAuth:
            return Locale.isSpanish ? "Iniciar sesión con navegador" : "Sign in with browser"
        case .directToken:
            return Locale.isSpanish ? "Ingresar clave API manualmente" : "Enter API key manually"
        }
    }

    var description: String {
        switch self {
        case .browserOAuth:
            return Locale.isSpanish
                ? "Se abrirá tu navegador para autorizar Claude Code (recomendado)"
                : "Your browser will open to authorize Claude Code (recommended)"
        case .directToken:
            return Locale.isSpanish
                ? "Pega tu clave API de console.anthropic.com"
                : "Paste your API key from console.anthropic.com"
        }
    }
}

enum TrustLevel: String, CaseIterable, Identifiable, Codable {
    case restrictive
    case moderate
    case permissive

    var id: String { rawValue }

    var title: String {
        switch self {
        case .restrictive:
            return Locale.isSpanish ? "Restrictivo" : "Restrictive"
        case .moderate:
            return Locale.isSpanish ? "Moderado" : "Moderate"
        case .permissive:
            return Locale.isSpanish ? "Permisivo" : "Permissive"
        }
    }

    var description: String {
        switch self {
        case .restrictive:
            return Locale.isSpanish
                ? "Pedir confirmación para todo (más seguro)"
                : "Ask for confirmation for everything (most secure)"
        case .moderate:
            return Locale.isSpanish
                ? "Permitir lectura, pedir confirmación para escritura"
                : "Allow reads, ask for confirmation for writes"
        case .permissive:
            return Locale.isSpanish
                ? "Permitir la mayoría de operaciones automáticamente"
                : "Allow most operations automatically"
        }
    }
}
