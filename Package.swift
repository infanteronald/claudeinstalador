// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "ClaudeInstaller",
    platforms: [
        .macOS(.v13)
    ],
    targets: [
        .executableTarget(
            name: "ClaudeInstaller",
            path: "Sources/ClaudeInstaller",
            resources: [
                .process("Resources")
            ]
        ),
        .executableTarget(
            name: "ClaudeUninstaller",
            path: "Sources/ClaudeUninstaller"
        ),
        .testTarget(
            name: "ClaudeInstallerTests",
            dependencies: ["ClaudeInstaller"],
            path: "Tests/ClaudeInstallerTests"
        )
    ]
)
