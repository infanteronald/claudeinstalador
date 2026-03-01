import Foundation

final class SystemAuditor: Sendable {

    func performAudit() async throws -> SystemAuditResult {
        let osVersion = ProcessInfo.processInfo.operatingSystemVersion
        let architecture = detectArchitecture()
        let chipName = await detectChipName()
        let totalRAMGB = Double(ProcessInfo.processInfo.physicalMemory) / 1_073_741_824.0
        let availableRAMGB = await getAvailableRAM()
        let shellType = detectShell()
        let profilePath = shellType.primaryProfilePath
        let conflicts = await ConflictScanner().scanForConflicts()
        let existingVersion = await detectExistingClaudeVersion()
        let isInstalled = existingVersion != nil

        let versionString = "\(osVersion.majorVersion).\(osVersion.minorVersion).\(osVersion.patchVersion)"

        return SystemAuditResult(
            macOSVersion: osVersion,
            macOSVersionString: versionString,
            architecture: architecture,
            chipName: chipName,
            totalRAMGB: totalRAMGB,
            availableRAMGB: availableRAMGB,
            shellType: shellType,
            shellProfilePath: profilePath,
            conflicts: conflicts,
            existingClaudeVersion: existingVersion,
            isClaudeAlreadyInstalled: isInstalled
        )
    }

    func detectArchitecture() -> CPUArchitecture {
        #if arch(arm64)
        return .arm64
        #else
        return .x64
        #endif
    }

    private func detectChipName() async -> String {
        var size: size_t = 0
        sysctlbyname("machdep.cpu.brand_string", nil, &size, nil, 0)
        var brand = [CChar](repeating: 0, count: size)
        sysctlbyname("machdep.cpu.brand_string", &brand, &size, nil, 0)
        let name = String(cString: brand)
        return name.isEmpty ? "Unknown" : name
    }

    private func getAvailableRAM() async -> Double {
        // Use vm_stat to get free memory
        if let result = try? await ShellExecutor.run("vm_stat | head -5") {
            let output = result.output
            // Parse "Pages free" line
            if let range = output.range(of: #"Pages free:\s+(\d+)"#, options: .regularExpression) {
                let match = String(output[range])
                let digits = match.filter { $0.isNumber }
                if let pages = UInt64(digits) {
                    // Each page is 16384 bytes on Apple Silicon (or 4096 on Intel)
                    let pageSize: UInt64 = 16384
                    return Double(pages * pageSize) / 1_073_741_824.0
                }
            }
        }
        // Fallback: return total RAM as estimate
        return Double(ProcessInfo.processInfo.physicalMemory) / 1_073_741_824.0
    }

    func detectShell() -> ShellType {
        let shellPath = ProcessInfo.processInfo.environment["SHELL"] ?? "/bin/zsh"
        if shellPath.contains("bash") {
            return .bash
        }
        return .zsh
    }

    private func detectExistingClaudeVersion() async -> String? {
        let claudePath = FileSystemHelper.expandPath("~/.local/bin/claude")
        guard FileSystemHelper.exists(claudePath) else { return nil }

        // Try to get version from the binary
        if let result = try? await ShellExecutor.run("\(claudePath) --version 2>/dev/null"),
           result.succeeded {
            let version = result.trimmedOutput
            // Extract version number (e.g., "2.1.44" from potential verbose output)
            if let match = version.range(of: #"\d+\.\d+\.\d+"#, options: .regularExpression) {
                return String(version[match])
            }
            return version.isEmpty ? nil : version
        }
        return nil
    }
}
