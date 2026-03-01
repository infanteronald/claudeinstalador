import Foundation

enum InstallerError: Error, LocalizedError {
    case macOSTooOld(current: String, required: String)
    case insufficientRAM(availableGB: Double, requiredGB: Double)
    case unsupportedArchitecture(String)
    case shellNotDetected
    case conflictingInstallation(path: String, type: ConflictType)
    case downloadFailed(url: String, statusCode: Int)
    case checksumMismatch(expected: String, actual: String)
    case networkUnavailable
    case manifestParseFailed(String)
    case binaryInstallFailed(reason: String)
    case profileWriteFailed(path: String, reason: String)
    case pathVerificationFailed
    case keychainAccessDenied(String)
    case keychainStoreFailed(String)
    case apiKeyInvalid
    case apiKeyValidationFailed(String)
    case filePermissionDenied(path: String)
    case directoryCreationFailed(path: String)
    case claudeMDWriteFailed(String)
    case terminalLaunchFailed(String)
    case unknownError(String)

    var humanReadableMessage: String {
        Locale.isSpanish ? messageES : messageEN
    }

    var messageES: String {
        switch self {
        case .macOSTooOld(let current, let required):
            return "Tu Mac necesita macOS \(required) o superior. Tienes \(current). Actualiza desde Ajustes del Sistema > Actualización de Software."
        case .insufficientRAM(let available, let required):
            return "Claude Code necesita al menos \(String(format: "%.1f", required)) GB de RAM. Tu Mac tiene \(String(format: "%.1f", available)) GB disponibles. Cierra algunas aplicaciones para liberar memoria."
        case .unsupportedArchitecture(let arch):
            return "Arquitectura de procesador no soportada: \(arch). Claude Code requiere un Mac con procesador Apple Silicon (M1-M4) o Intel x64."
        case .shellNotDetected:
            return "No se pudo detectar el intérprete de comandos del sistema. Asegúrate de que Zsh o Bash están configurados."
        case .conflictingInstallation(let path, let type):
            return "Se encontró una instalación conflictiva de Claude Code (\(type.descriptionES)) en: \(path)"
        case .downloadFailed(_, let code):
            return "Error al descargar Claude Code (código \(code)). Verifica tu conexión a internet e intenta de nuevo."
        case .checksumMismatch:
            return "El archivo descargado está corrupto. Se descargará de nuevo automáticamente."
        case .networkUnavailable:
            return "No hay conexión a internet. Conéctate a una red Wi-Fi o Ethernet e intenta de nuevo."
        case .manifestParseFailed:
            return "No se pudo leer la información de la última versión de Claude Code. Intenta de nuevo en unos minutos."
        case .binaryInstallFailed(let reason):
            return "Error al instalar el binario de Claude Code: \(reason)"
        case .profileWriteFailed(let path, _):
            return "No se pudo modificar el archivo de configuración \(path). Verifica los permisos del archivo."
        case .pathVerificationFailed:
            return "La configuración del PATH no se aplicó correctamente. Puede ser necesario reiniciar la terminal."
        case .keychainAccessDenied:
            return "Acceso denegado al Llavero de macOS. Autoriza el acceso cuando se muestre el diálogo del sistema."
        case .keychainStoreFailed(let reason):
            return "No se pudo guardar la clave en el Llavero: \(reason)"
        case .apiKeyInvalid:
            return "La clave API proporcionada no es válida. Verifica que la copiaste correctamente desde console.anthropic.com"
        case .apiKeyValidationFailed:
            return "No se pudo verificar la clave API. Verifica tu conexión a internet."
        case .filePermissionDenied(let path):
            return "Permiso denegado para acceder a: \(path). El instalador intentará resolver esto automáticamente."
        case .directoryCreationFailed(let path):
            return "No se pudo crear el directorio: \(path)"
        case .claudeMDWriteFailed:
            return "No se pudo crear el archivo CLAUDE.md en el proyecto."
        case .terminalLaunchFailed:
            return "No se pudo abrir la Terminal. Puedes abrirla manualmente desde Aplicaciones > Utilidades."
        case .unknownError(let msg):
            return "Error inesperado: \(msg). Si el problema persiste, reinicia la aplicación."
        }
    }

    var messageEN: String {
        switch self {
        case .macOSTooOld(let current, let required):
            return "Your Mac needs macOS \(required) or later. You have \(current). Update from System Settings > Software Update."
        case .insufficientRAM(let available, let required):
            return "Claude Code needs at least \(String(format: "%.1f", required)) GB of RAM. Your Mac has \(String(format: "%.1f", available)) GB available. Close some apps to free up memory."
        case .unsupportedArchitecture(let arch):
            return "Unsupported processor architecture: \(arch). Claude Code requires Apple Silicon (M1-M4) or Intel x64."
        case .shellNotDetected:
            return "Could not detect the system shell. Make sure Zsh or Bash is configured."
        case .conflictingInstallation(let path, let type):
            return "Found a conflicting Claude Code installation (\(type.descriptionEN)) at: \(path)"
        case .downloadFailed(_, let code):
            return "Failed to download Claude Code (code \(code)). Check your internet connection and try again."
        case .checksumMismatch:
            return "The downloaded file is corrupt. It will be re-downloaded automatically."
        case .networkUnavailable:
            return "No internet connection. Connect to Wi-Fi or Ethernet and try again."
        case .manifestParseFailed:
            return "Could not read the latest Claude Code version info. Try again in a few minutes."
        case .binaryInstallFailed(let reason):
            return "Failed to install Claude Code binary: \(reason)"
        case .profileWriteFailed(let path, _):
            return "Could not modify configuration file \(path). Check the file permissions."
        case .pathVerificationFailed:
            return "PATH configuration was not applied correctly. You may need to restart the terminal."
        case .keychainAccessDenied:
            return "Access denied to macOS Keychain. Please authorize access when the system dialog appears."
        case .keychainStoreFailed(let reason):
            return "Could not save the key to Keychain: \(reason)"
        case .apiKeyInvalid:
            return "The API key provided is not valid. Make sure you copied it correctly from console.anthropic.com"
        case .apiKeyValidationFailed:
            return "Could not verify the API key. Check your internet connection."
        case .filePermissionDenied(let path):
            return "Permission denied for: \(path). The installer will try to resolve this automatically."
        case .directoryCreationFailed(let path):
            return "Could not create directory: \(path)"
        case .claudeMDWriteFailed:
            return "Could not create the CLAUDE.md file in the project."
        case .terminalLaunchFailed:
            return "Could not open Terminal. You can open it manually from Applications > Utilities."
        case .unknownError(let msg):
            return "Unexpected error: \(msg). If the issue persists, restart the application."
        }
    }

    var canRetry: Bool {
        switch self {
        case .downloadFailed, .checksumMismatch, .networkUnavailable,
             .manifestParseFailed, .apiKeyValidationFailed, .pathVerificationFailed:
            return true
        default:
            return false
        }
    }

    var errorDescription: String? { humanReadableMessage }
}

enum ConflictType: String, Codable {
    case homebrew
    case npm
    case orphanedBinary
    case corruptArtifact
    case brokenSymlink

    var descriptionES: String {
        switch self {
        case .homebrew: return "Homebrew"
        case .npm: return "NPM"
        case .orphanedBinary: return "binario huérfano"
        case .corruptArtifact: return "artefacto corrupto"
        case .brokenSymlink: return "enlace simbólico roto"
        }
    }

    var descriptionEN: String {
        switch self {
        case .homebrew: return "Homebrew"
        case .npm: return "NPM"
        case .orphanedBinary: return "orphaned binary"
        case .corruptArtifact: return "corrupt artifact"
        case .brokenSymlink: return "broken symlink"
        }
    }
}

enum PhaseResult {
    case success(details: String)
    case warning(message: String, canContinue: Bool)
    case failure(error: InstallerError)

    var isSuccess: Bool {
        if case .success = self { return true }
        return false
    }

    var canContinue: Bool {
        switch self {
        case .success: return true
        case .warning(_, let ok): return ok
        case .failure: return false
        }
    }
}
