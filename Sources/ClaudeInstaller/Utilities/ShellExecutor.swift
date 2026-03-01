import Foundation

struct ShellExecutor {
    struct Result {
        let output: String
        let errorOutput: String
        let exitCode: Int32

        var succeeded: Bool { exitCode == 0 }
        var trimmedOutput: String { output.trimmingCharacters(in: .whitespacesAndNewlines) }
    }

    /// Execute a shell command and return the result
    /// - Parameters:
    ///   - command: The shell command to run
    ///   - environment: Optional environment variables
    ///   - timeoutSeconds: Optional timeout in seconds. If the process exceeds this, it is killed.
    @discardableResult
    static func run(_ command: String, environment: [String: String]? = nil, timeoutSeconds: Double? = nil) async throws -> Result {
        let process = Process()
        let outputPipe = Pipe()
        let errorPipe = Pipe()

        process.executableURL = URL(fileURLWithPath: "/bin/zsh")
        process.arguments = ["-c", command]
        process.standardOutput = outputPipe
        process.standardError = errorPipe

        if let env = environment {
            var processEnv = ProcessInfo.processInfo.environment
            for (key, value) in env {
                processEnv[key] = value
            }
            process.environment = processEnv
        }

        if let timeout = timeoutSeconds {
            return try await withThrowingTaskGroup(of: Result.self) { group in
                group.addTask {
                    try await withCheckedThrowingContinuation { continuation in
                        do {
                            try process.run()
                            process.waitUntilExit()

                            let outputData = outputPipe.fileHandleForReading.readDataToEndOfFile()
                            let errorData = errorPipe.fileHandleForReading.readDataToEndOfFile()

                            let output = String(data: outputData, encoding: .utf8) ?? ""
                            let errorOutput = String(data: errorData, encoding: .utf8) ?? ""

                            continuation.resume(returning: Result(
                                output: output,
                                errorOutput: errorOutput,
                                exitCode: process.terminationStatus
                            ))
                        } catch {
                            continuation.resume(throwing: error)
                        }
                    }
                }

                group.addTask {
                    try await Task.sleep(nanoseconds: UInt64(timeout * 1_000_000_000))
                    throw ShellTimeoutError()
                }

                do {
                    let result = try await group.next()!
                    group.cancelAll()
                    return result
                } catch is ShellTimeoutError {
                    if process.isRunning {
                        process.terminate()
                    }
                    group.cancelAll()
                    return Result(output: "", errorOutput: "Process timed out", exitCode: -1)
                }
            }
        }

        return try await withCheckedThrowingContinuation { continuation in
            do {
                try process.run()
                process.waitUntilExit()

                let outputData = outputPipe.fileHandleForReading.readDataToEndOfFile()
                let errorData = errorPipe.fileHandleForReading.readDataToEndOfFile()

                let output = String(data: outputData, encoding: .utf8) ?? ""
                let errorOutput = String(data: errorData, encoding: .utf8) ?? ""

                continuation.resume(returning: Result(
                    output: output,
                    errorOutput: errorOutput,
                    exitCode: process.terminationStatus
                ))
            } catch {
                continuation.resume(throwing: error)
            }
        }
    }

    private struct ShellTimeoutError: Error {}

    /// Execute a command with a specific shell
    @discardableResult
    static func run(shell: ShellType, command: String) async throws -> Result {
        let process = Process()
        let outputPipe = Pipe()
        let errorPipe = Pipe()

        process.executableURL = URL(fileURLWithPath: shell.shellBinary)
        process.arguments = ["-l", "-c", command]
        process.standardOutput = outputPipe
        process.standardError = errorPipe

        return try await withCheckedThrowingContinuation { continuation in
            do {
                try process.run()
                process.waitUntilExit()

                let outputData = outputPipe.fileHandleForReading.readDataToEndOfFile()
                let errorData = errorPipe.fileHandleForReading.readDataToEndOfFile()

                let output = String(data: outputData, encoding: .utf8) ?? ""
                let errorOutput = String(data: errorData, encoding: .utf8) ?? ""

                continuation.resume(returning: Result(
                    output: output,
                    errorOutput: errorOutput,
                    exitCode: process.terminationStatus
                ))
            } catch {
                continuation.resume(throwing: error)
            }
        }
    }

    /// Check if a command exists in the system
    static func commandExists(_ command: String) async -> Bool {
        let result = try? await run("command -v \(command)")
        return result?.succeeded ?? false
    }
}
