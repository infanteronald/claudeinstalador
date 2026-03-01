import Foundation
import CryptoKit

struct ChecksumVerifier {
    /// Verify SHA256 checksum of a file against an expected hash
    static func verifySHA256(fileURL: URL, expected: String) throws -> Bool {
        let data = try Data(contentsOf: fileURL)
        let hash = SHA256.hash(data: data)
        let actual = hash.map { String(format: "%02x", $0) }.joined()
        return actual.lowercased() == expected.lowercased()
    }

    /// Compute SHA256 hash of a file
    static func sha256(fileURL: URL) throws -> String {
        let data = try Data(contentsOf: fileURL)
        let hash = SHA256.hash(data: data)
        return hash.map { String(format: "%02x", $0) }.joined()
    }

    /// Compute SHA256 hash of data
    static func sha256(data: Data) -> String {
        let hash = SHA256.hash(data: data)
        return hash.map { String(format: "%02x", $0) }.joined()
    }
}
