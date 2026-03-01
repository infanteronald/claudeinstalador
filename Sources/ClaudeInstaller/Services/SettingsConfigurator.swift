import Foundation

final class SettingsConfigurator: Sendable {

    func configure(trustLevel: TrustLevel) async throws {
        let settingsDir = FileSystemHelper.expandPath("~/.claude")
        let settingsPath = "\(settingsDir)/settings.json"

        try FileSystemHelper.createDirectory(settingsDir)

        // Read existing settings if present
        var settings: [String: Any] = [:]
        if FileSystemHelper.exists(settingsPath),
           let data = try? Data(contentsOf: URL(fileURLWithPath: settingsPath)),
           let existing = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
            settings = existing
        }

        // Configure permissions based on trust level
        var permissions: [String: Any] = (settings["permissions"] as? [String: Any]) ?? [:]
        var allowList: [String] = (permissions["allow"] as? [String]) ?? []

        switch trustLevel {
        case .restrictive:
            // Minimal permissions - ask for everything
            break

        case .moderate:
            // Allow read operations
            let moderatePermissions = [
                "Bash(cat *)",
                "Bash(ls *)",
                "Bash(find *)",
                "Bash(grep *)",
                "Bash(head *)",
                "Bash(tail *)",
                "Bash(wc *)"
            ]
            for perm in moderatePermissions {
                if !allowList.contains(perm) {
                    allowList.append(perm)
                }
            }

        case .permissive:
            // Allow most operations
            let permissivePermissions = [
                "Bash(cat *)",
                "Bash(ls *)",
                "Bash(find *)",
                "Bash(grep *)",
                "Bash(head *)",
                "Bash(tail *)",
                "Bash(wc *)",
                "Bash(mkdir *)",
                "Bash(cp *)",
                "Bash(mv *)",
                "Bash(git *)",
                "Bash(npm *)",
                "Bash(node *)",
                "Bash(python *)",
                "Bash(swift *)"
            ]
            for perm in permissivePermissions {
                if !allowList.contains(perm) {
                    allowList.append(perm)
                }
            }
        }

        permissions["allow"] = allowList
        settings["permissions"] = permissions

        let jsonData = try JSONSerialization.data(
            withJSONObject: settings,
            options: [.prettyPrinted, .sortedKeys]
        )
        try jsonData.write(to: URL(fileURLWithPath: settingsPath))
    }
}
