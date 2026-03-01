import Foundation

struct ErrorMapper {
    /// Convert any error into a user-friendly InstallerError
    static func map(_ error: Error) -> InstallerError {
        if let installerError = error as? InstallerError {
            return installerError
        }

        let nsError = error as NSError

        // Network errors
        if nsError.domain == NSURLErrorDomain {
            switch nsError.code {
            case NSURLErrorNotConnectedToInternet, NSURLErrorNetworkConnectionLost:
                return .networkUnavailable
            case NSURLErrorTimedOut:
                return .downloadFailed(url: "", statusCode: 0)
            default:
                return .downloadFailed(url: nsError.localizedDescription, statusCode: nsError.code)
            }
        }

        // File system errors
        if nsError.domain == NSCocoaErrorDomain {
            switch nsError.code {
            case NSFileWriteNoPermissionError, NSFileReadNoPermissionError:
                return .filePermissionDenied(path: nsError.localizedDescription)
            case NSFileNoSuchFileError:
                return .unknownError(nsError.localizedDescription)
            default:
                break
            }
        }

        return .unknownError(error.localizedDescription)
    }
}
