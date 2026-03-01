import Foundation

final class BinaryDownloader: @unchecked Sendable {
    static let gcsBase = "https://storage.googleapis.com/claude-code-dist-86c565f3-f756-42ad-8dfa-d59b1c096819/claude-code-releases"

    struct RawProgress {
        let bytesDownloaded: Int64
        let totalBytes: Int64
    }

    /// Fetch the latest available version string
    func fetchLatestVersion() async throws -> String {
        let url = URL(string: "\(Self.gcsBase)/latest")!
        let (data, response) = try await URLSession.shared.data(from: url)

        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            let code = (response as? HTTPURLResponse)?.statusCode ?? 0
            throw InstallerError.downloadFailed(url: url.absoluteString, statusCode: code)
        }

        guard let version = String(data: data, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines),
              !version.isEmpty else {
            throw InstallerError.manifestParseFailed("Empty version response")
        }

        return version
    }

    /// Fetch the manifest for a specific version
    func fetchManifest(version: String) async throws -> ClaudeManifest {
        let url = URL(string: "\(Self.gcsBase)/\(version)/manifest.json")!
        let (data, response) = try await URLSession.shared.data(from: url)

        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            let code = (response as? HTTPURLResponse)?.statusCode ?? 0
            throw InstallerError.downloadFailed(url: url.absoluteString, statusCode: code)
        }

        do {
            let manifest = try JSONDecoder().decode(ClaudeManifest.self, from: data)
            return manifest
        } catch {
            throw InstallerError.manifestParseFailed(error.localizedDescription)
        }
    }

    /// Download the binary with progress reporting
    func downloadBinary(
        version: String,
        platform: CPUArchitecture,
        progress: @escaping (RawProgress) -> Void
    ) async throws -> URL {
        let urlString = "\(Self.gcsBase)/\(version)/\(platform.downloadPlatform)/claude"
        guard let url = URL(string: urlString) else {
            throw InstallerError.downloadFailed(url: urlString, statusCode: 0)
        }

        let cacheDir = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("com.claudeinstaller/downloads")
        try FileManager.default.createDirectory(at: cacheDir, withIntermediateDirectories: true)
        let destURL = cacheDir.appendingPathComponent("claude-\(version)")

        // If already downloaded and cached, return it
        if FileManager.default.fileExists(atPath: destURL.path) {
            return destURL
        }

        let (asyncBytes, response) = try await URLSession.shared.bytes(from: url)

        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            let code = (response as? HTTPURLResponse)?.statusCode ?? 0
            throw InstallerError.downloadFailed(url: urlString, statusCode: code)
        }

        let totalBytes = httpResponse.expectedContentLength
        var data = Data()
        if totalBytes > 0 {
            data.reserveCapacity(Int(totalBytes))
        }

        var bytesReceived: Int64 = 0
        for try await byte in asyncBytes {
            data.append(byte)
            bytesReceived += 1
            // Report progress every 256KB
            if bytesReceived % (1024 * 256) == 0 {
                progress(RawProgress(bytesDownloaded: bytesReceived, totalBytes: totalBytes))
            }
        }

        // Final progress report
        progress(RawProgress(bytesDownloaded: bytesReceived, totalBytes: bytesReceived))

        try data.write(to: destURL)

        // Verify checksum if manifest is available
        if let manifest = try? await fetchManifest(version: version),
           let platformInfo = manifest.platformInfo(for: platform),
           let expectedChecksum = platformInfo.resolvedChecksum {
            let valid = try ChecksumVerifier.verifySHA256(fileURL: destURL, expected: expectedChecksum)
            if !valid {
                let actual = try ChecksumVerifier.sha256(fileURL: destURL)
                try? FileManager.default.removeItem(at: destURL)
                throw InstallerError.checksumMismatch(expected: expectedChecksum, actual: actual)
            }
        }

        return destURL
    }

    /// Install the downloaded binary to the standard location
    func installBinary(downloadedURL: URL, version: String) async throws {
        let home = FileManager.default.homeDirectoryForCurrentUser.path
        let versionsDir = "\(home)/.local/share/claude/versions"
        let binDir = "\(home)/.local/bin"
        let versionPath = "\(versionsDir)/\(version)"
        let symlinkPath = "\(binDir)/claude"

        // Create directories
        try FileSystemHelper.createDirectory(versionsDir)
        try FileSystemHelper.createDirectory(binDir)

        // Copy binary to version directory
        if FileManager.default.fileExists(atPath: versionPath) {
            try FileManager.default.removeItem(atPath: versionPath)
        }
        try FileManager.default.copyItem(atPath: downloadedURL.path, toPath: versionPath)

        // Make executable
        try FileSystemHelper.makeExecutable(versionPath)

        // Create symlink
        try FileSystemHelper.createSymlink(at: symlinkPath, destination: versionPath)
    }
}
