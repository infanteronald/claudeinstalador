import SwiftUI

@MainActor
final class UninstallerState: ObservableObject {
    enum Phase {
        case welcome
        case scanning
        case results
        case confirming
        case detonating
        case complete
    }

    @Published var phase: Phase = .welcome
    @Published var scanResult: ScanResult? = nil
    @Published var cleanupResult: NuclearCleaner.CleanupResult? = nil
    @Published var scanProgress: String = ""

    let scanner = NuclearScanner()
    let cleaner = NuclearCleaner()

    func startScan() async {
        phase = .scanning
        scanProgress = isSpanish
            ? "Escaneando el sistema..."
            : "Scanning system..."

        let result = await scanner.scan()
        scanResult = result

        if result.isEmpty {
            phase = .complete
        } else {
            phase = .results
        }
    }

    func confirmDetonation() {
        phase = .confirming
    }

    func detonate() async {
        guard let result = scanResult else { return }
        phase = .detonating

        let cleanup = await cleaner.detonate(traces: result.removableTraces)
        cleanupResult = cleanup
        phase = .complete
    }

    func cancelDetonation() {
        phase = .results
    }
}
