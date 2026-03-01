import Foundation

struct FileSystemHelper {
    static let fileManager = FileManager.default
    static let home = fileManager.homeDirectoryForCurrentUser.path

    /// Check if a path exists
    static func exists(_ path: String) -> Bool {
        fileManager.fileExists(atPath: expandPath(path))
    }

    /// Check if a path is a directory
    static func isDirectory(_ path: String) -> Bool {
        var isDir: ObjCBool = false
        return fileManager.fileExists(atPath: expandPath(path), isDirectory: &isDir) && isDir.boolValue
    }

    /// Check if a file is a valid symlink
    static func isValidSymlink(_ path: String) -> Bool {
        let expanded = expandPath(path)
        guard let attrs = try? fileManager.attributesOfItem(atPath: expanded),
              let type = attrs[.type] as? FileAttributeType,
              type == .typeSymbolicLink else {
            return false
        }
        // Check if symlink target exists
        let resolved = (try? fileManager.destinationOfSymbolicLink(atPath: expanded)) ?? ""
        return fileManager.fileExists(atPath: resolved)
    }

    /// Check if a path is writable by the current user
    static func isWritable(_ path: String) -> Bool {
        fileManager.isWritableFile(atPath: expandPath(path))
    }

    /// Create a directory with intermediate directories
    static func createDirectory(_ path: String) throws {
        let expanded = expandPath(path)
        try fileManager.createDirectory(atPath: expanded, withIntermediateDirectories: true)
    }

    /// Read the contents of a text file
    static func readFile(_ path: String) throws -> String {
        let expanded = expandPath(path)
        return try String(contentsOfFile: expanded, encoding: .utf8)
    }

    /// Write text to a file, creating the file if it doesn't exist
    static func writeFile(_ path: String, content: String) throws {
        let expanded = expandPath(path)
        let directory = (expanded as NSString).deletingLastPathComponent
        if !fileManager.fileExists(atPath: directory) {
            try createDirectory(directory)
        }
        try content.write(toFile: expanded, atomically: true, encoding: .utf8)
    }

    /// Append text to a file
    static func appendToFile(_ path: String, content: String) throws {
        let expanded = expandPath(path)
        if fileManager.fileExists(atPath: expanded) {
            let handle = try FileHandle(forWritingTo: URL(fileURLWithPath: expanded))
            handle.seekToEndOfFile()
            if let data = content.data(using: .utf8) {
                handle.write(data)
            }
            handle.closeFile()
        } else {
            try writeFile(path, content: content)
        }
    }

    /// Set file permissions
    static func setPermissions(_ path: String, posixPermissions: Int) throws {
        let expanded = expandPath(path)
        try fileManager.setAttributes(
            [.posixPermissions: posixPermissions],
            ofItemAtPath: expanded
        )
    }

    /// Make a file executable
    static func makeExecutable(_ path: String) throws {
        try setPermissions(path, posixPermissions: 0o755)
    }

    /// Create a symbolic link
    static func createSymlink(at path: String, destination: String) throws {
        let expandedPath = expandPath(path)
        let expandedDest = expandPath(destination)
        // Remove existing symlink if present
        if fileManager.fileExists(atPath: expandedPath) {
            try fileManager.removeItem(atPath: expandedPath)
        }
        try fileManager.createSymbolicLink(
            atPath: expandedPath,
            withDestinationPath: expandedDest
        )
    }

    /// Expand ~ to home directory
    static func expandPath(_ path: String) -> String {
        (path as NSString).expandingTildeInPath
    }

    /// Get the current user's username
    static var currentUser: String {
        NSUserName()
    }

    /// Get disk space available in GB
    static func availableDiskSpaceGB() -> Double {
        guard let attrs = try? fileManager.attributesOfFileSystem(forPath: home),
              let space = attrs[.systemFreeSize] as? Int64 else {
            return 0
        }
        return Double(space) / 1_073_741_824.0
    }

    /// Delete a file or directory
    static func remove(_ path: String) throws {
        let expanded = expandPath(path)
        if fileManager.fileExists(atPath: expanded) {
            try fileManager.removeItem(atPath: expanded)
        }
    }
}
