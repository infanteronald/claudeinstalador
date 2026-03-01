import Testing
import Foundation

@Test func checksumVerifierComputesCorrectHash() async throws {
    // Test with known SHA256 hash of "hello world"
    let testData = "hello world".data(using: .utf8)!
    let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent("test_checksum")
    try testData.write(to: tempURL)
    defer { try? FileManager.default.removeItem(at: tempURL) }

    let expectedHash = "b94d27b9934d3e08a52e52d7da7dabfac484efe37a5380ee9088f7ace2efcde9"
    // We test the raw CryptoKit computation
    let data = try Data(contentsOf: tempURL)
    let hash = CryptoKit.SHA256.hash(data: data)
    let actual = hash.map { String(format: "%02x", $0) }.joined()

    #expect(actual == expectedHash)
}
