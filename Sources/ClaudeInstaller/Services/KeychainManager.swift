import Foundation
import Security
import AppKit

final class KeychainManager: @unchecked Sendable {
    private let service = "com.anthropic.claude-code"

    /// Store an API key in the macOS Keychain
    func storeAPIKey(_ key: String) async throws {
        let account = NSUserName()
        guard let keyData = key.data(using: .utf8) else {
            throw InstallerError.keychainStoreFailed("Could not encode key")
        }

        // Delete existing entry if present
        let deleteQuery: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account
        ]
        SecItemDelete(deleteQuery as CFDictionary)

        // Create access control (biometry if available, otherwise password)
        var error: Unmanaged<CFError>?
        let accessControl = SecAccessControlCreateWithFlags(
            kCFAllocatorDefault,
            kSecAttrAccessibleWhenUnlockedThisDeviceOnly,
            .userPresence,
            &error
        )

        var query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecValueData as String: keyData
        ]

        if let ac = accessControl {
            query[kSecAttrAccessControl as String] = ac
        }

        let status = SecItemAdd(query as CFDictionary, nil)
        guard status == errSecSuccess else {
            throw InstallerError.keychainStoreFailed("Keychain error: \(status)")
        }
    }

    /// Retrieve the API key from Keychain
    func retrieveAPIKey() async -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: NSUserName(),
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]

        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)

        guard status == errSecSuccess,
              let data = item as? Data,
              let key = String(data: data, encoding: .utf8) else {
            return nil
        }

        return key
    }

    /// Delete stored API key
    func deleteAPIKey() async {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: NSUserName()
        ]
        SecItemDelete(query as CFDictionary)
    }

    /// Check if Claude Code already has a valid authentication.
    /// Uses a strict 5-second timeout to avoid hanging on interactive commands.
    func isAlreadyAuthenticated() async -> Bool {
        let claudePath = FileSystemHelper.expandPath("~/.local/bin/claude")
        guard FileSystemHelper.exists(claudePath) else { return false }

        // Use a 5-second timeout — `claude auth status` can hang if it
        // tries to read from stdin or launch interactive prompts.
        if let result = try? await ShellExecutor.run(
            "\(claudePath) auth status 2>&1 || echo 'NOT_AUTHENTICATED'",
            timeoutSeconds: 5
        ) {
            let output = result.output + result.errorOutput
            // Timed out or failed → assume not authenticated
            if result.exitCode == -1 { return false }
            // If it doesn't say "not authenticated" or "login", it's probably good
            if result.succeeded && !output.contains("NOT_AUTHENTICATED")
                && !output.contains("login") && !output.contains("Missing") {
                return true
            }
        }
        return false
    }

    /// Open the Anthropic login page so the user can authenticate.
    /// Does NOT run any interactive `claude` commands — those block forever.
    /// The user will complete authentication when they first run `claude` in terminal.
    func triggerOAuthLogin() async throws {
        // Open the Anthropic login page in the default browser
        if let url = URL(string: "https://claude.ai/login") {
            await MainActor.run {
                _ = NSWorkspace.shared.open(url)
            }
        }

        // NOTE: We intentionally skip `isAlreadyAuthenticated()` here.
        // Even with a timeout, it can delay the UI. The user will
        // complete auth when they run `claude` in the terminal.
    }
}
