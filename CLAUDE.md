# CLAUDE.md - Claude Code Installer for macOS

## Project Overview
Native macOS application (Swift + SwiftUI) that automates Claude Code installation for non-technical users.

## Tech Stack
- Swift 6+ with Swift Concurrency (actors, async/await)
- SwiftUI for macOS 13.0+ (Ventura)
- Swift Package Manager (no Xcode required)
- Security.framework for Keychain/Touch ID
- CryptoKit for SHA256 checksum verification

## Build Commands
- Build: `swift build`
- Run: `swift run`
- Test: `swift test`

## Architecture
- 6-phase wizard installer: System Audit → Download → PATH → Keychain → Config → Onboarding
- AppState is the central ObservableObject state machine
- Services are in Sources/ClaudeInstaller/Services/
- Views are in Sources/ClaudeInstaller/Views/
- Bilingual: Spanish + English with Locale.isSpanish detection

## Key Conventions
- All user-facing strings must have both ES and EN versions
- Use InstallerError for all errors (with humanReadableMessage)
- Services should be Sendable-safe
- Never use sudo - handle permissions with chown or AuthorizationServices
- All shell profile modifications must be idempotent
