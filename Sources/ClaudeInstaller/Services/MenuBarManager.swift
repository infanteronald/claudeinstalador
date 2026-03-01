import AppKit

@MainActor
final class MenuBarManager {
    private var statusItem: NSStatusItem?

    func install() {
        guard statusItem == nil else { return }

        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)

        if let button = statusItem?.button {
            button.image = NSImage(systemSymbolName: "terminal.fill", accessibilityDescription: "Claude Code")
        }

        let menu = NSMenu()

        // Open Claude Code
        let openItem = NSMenuItem(
            title: Locale.isSpanish ? "Abrir Claude Code" : "Open Claude Code",
            action: #selector(openClaude),
            keyEquivalent: "o"
        )
        openItem.target = self
        menu.addItem(openItem)

        menu.addItem(NSMenuItem.separator())

        // Run Diagnostics
        let diagItem = NSMenuItem(
            title: Locale.isSpanish ? "Ejecutar Diagnóstico" : "Run Diagnostics",
            action: #selector(runDiagnostics),
            keyEquivalent: "d"
        )
        diagItem.target = self
        menu.addItem(diagItem)

        // Purge Cache
        let purgeItem = NSMenuItem(
            title: Locale.isSpanish ? "Purgar Caché" : "Purge Cache",
            action: #selector(purgeCache),
            keyEquivalent: ""
        )
        purgeItem.target = self
        menu.addItem(purgeItem)

        menu.addItem(NSMenuItem.separator())

        // Quit
        let quitItem = NSMenuItem(
            title: Locale.isSpanish ? "Salir" : "Quit",
            action: #selector(quit),
            keyEquivalent: "q"
        )
        quitItem.target = self
        menu.addItem(quitItem)

        statusItem?.menu = menu
    }

    func uninstall() {
        if let item = statusItem {
            NSStatusBar.system.removeStatusItem(item)
            statusItem = nil
        }
    }

    @objc private func openClaude() {
        Task {
            let script = """
            tell application "Terminal"
                activate
                do script "claude"
            end tell
            """
            _ = try? await ShellExecutor.run("osascript -e '\(script)'")
        }
    }

    @objc private func runDiagnostics() {
        Task {
            let script = """
            tell application "Terminal"
                activate
                do script "claude doctor"
            end tell
            """
            _ = try? await ShellExecutor.run("osascript -e '\(script)'")
        }
    }

    @objc private func purgeCache() {
        let alert = NSAlert()
        alert.messageText = Locale.isSpanish ? "Purgar Caché" : "Purge Cache"
        alert.informativeText = Locale.isSpanish
            ? "¿Estás seguro de que quieres borrar la caché de Claude Code? Esto no eliminará tus proyectos."
            : "Are you sure you want to clear Claude Code's cache? This won't delete your projects."
        alert.alertStyle = .warning
        alert.addButton(withTitle: Locale.isSpanish ? "Purgar" : "Purge")
        alert.addButton(withTitle: Locale.isSpanish ? "Cancelar" : "Cancel")

        if alert.runModal() == .alertFirstButtonReturn {
            try? FileSystemHelper.remove("~/.config/claude-code")
            try? FileSystemHelper.remove("~/.claude/cache")
        }
    }

    @objc private func quit() {
        NSApplication.shared.terminate(nil)
    }
}
