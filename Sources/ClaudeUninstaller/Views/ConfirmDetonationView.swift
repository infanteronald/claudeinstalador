import SwiftUI

struct ConfirmDetonationView: View {
    @EnvironmentObject var state: UninstallerState
    @State private var confirmText: String = ""

    private var expectedText: String {
        isSpanish ? "ELIMINAR" : "DELETE"
    }

    var body: some View {
        VStack(spacing: 20) {
            Spacer()

            Image(systemName: "exclamationmark.octagon.fill")
                .font(.system(size: 56))
                .foregroundColor(.red)

            Text(isSpanish ? "¿Estás seguro?" : "Are you sure?")
                .font(.system(size: 24, weight: .bold))

            Text(isSpanish
                ? "Se eliminarán \(state.scanResult?.removableTraces.count ?? 0) elementos de Claude Code. Esta acción no se puede deshacer."
                : "\(state.scanResult?.removableTraces.count ?? 0) Claude Code items will be removed. This action cannot be undone.")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 50)

            // Type to confirm
            VStack(spacing: 8) {
                Text(isSpanish
                    ? "Escribe \"\(expectedText)\" para confirmar:"
                    : "Type \"\(expectedText)\" to confirm:")
                    .font(.system(size: 13))
                    .foregroundColor(.secondary)

                TextField(expectedText, text: $confirmText)
                    .textFieldStyle(.roundedBorder)
                    .font(.system(size: 16, weight: .bold, design: .monospaced))
                    .multilineTextAlignment(.center)
                    .frame(width: 200)
            }

            // Buttons
            HStack(spacing: 16) {
                Button(action: {
                    state.cancelDetonation()
                }) {
                    Text(isSpanish ? "Cancelar" : "Cancel")
                        .frame(minWidth: 100)
                }
                .buttonStyle(.bordered)
                .controlSize(.large)

                Button(action: {
                    Task { await state.detonate() }
                }) {
                    HStack(spacing: 6) {
                        Image(systemName: "trash.fill")
                        Text(isSpanish ? "ELIMINAR TODO" : "DELETE ALL")
                            .font(.system(size: 14, weight: .bold))
                    }
                    .frame(minWidth: 160)
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                .tint(.red)
                .disabled(confirmText.uppercased() != expectedText)
            }

            Spacer()
        }
    }
}
