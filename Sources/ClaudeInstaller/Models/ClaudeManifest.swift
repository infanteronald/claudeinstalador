import Foundation

struct ClaudeManifest: Codable {
    let version: String
    let platforms: [String: PlatformInfo]?

    struct PlatformInfo: Codable {
        let binaryName: String?
        let checksum: String?
        let sha256: String?
        let size: Int?

        var resolvedChecksum: String? {
            sha256 ?? checksum
        }
    }

    func platformInfo(for arch: CPUArchitecture) -> PlatformInfo? {
        platforms?[arch.downloadPlatform]
    }
}

struct DownloadProgress {
    let bytesDownloaded: Int64
    let totalBytes: Int64
    let startTime: Date

    var fraction: Double {
        guard totalBytes > 0 else { return 0 }
        return Double(bytesDownloaded) / Double(totalBytes)
    }

    var percentage: Int {
        Int(fraction * 100)
    }

    var downloadedMB: Double {
        Double(bytesDownloaded) / 1_048_576.0
    }

    var totalMB: Double {
        Double(totalBytes) / 1_048_576.0
    }

    var speedMBps: Double {
        let elapsed = Date().timeIntervalSince(startTime)
        guard elapsed > 0 else { return 0 }
        return downloadedMB / elapsed
    }

    var estimatedRemainingSeconds: Double {
        guard speedMBps > 0 else { return 0 }
        let remainingMB = totalMB - downloadedMB
        return remainingMB / speedMBps
    }
}
