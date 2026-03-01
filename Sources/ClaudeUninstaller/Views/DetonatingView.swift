import SwiftUI

struct DetonatingView: View {
    @State private var pulse = false

    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            ZStack {
                Circle()
                    .fill(Color.red.opacity(0.1))
                    .frame(width: pulse ? 140 : 100, height: pulse ? 140 : 100)
                    .animation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true), value: pulse)

                Image(systemName: "flame.fill")
                    .font(.system(size: 48))
                    .foregroundColor(.red)
            }
            .onAppear { pulse = true }

            Text(isSpanish ? "Eliminando..." : "Removing...")
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(.red)

            Text(isSpanish
                ? "Eliminando todos los rastros de Claude Code"
                : "Removing all traces of Claude Code")
                .font(.body)
                .foregroundColor(.secondary)

            ProgressView()
                .scaleEffect(1.2)

            Spacer()
        }
    }
}
