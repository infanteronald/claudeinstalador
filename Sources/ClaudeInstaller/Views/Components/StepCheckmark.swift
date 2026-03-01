import SwiftUI

struct StepCheckmark: View {
    let label: String
    let isComplete: Bool
    let isActive: Bool
    var hasWarning: Bool = false
    var hasFailed: Bool = false

    @State private var animateCheck = false

    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .stroke(borderColor, lineWidth: 2)
                    .frame(width: 24, height: 24)

                if isComplete {
                    Circle()
                        .fill(fillColor)
                        .frame(width: 24, height: 24)

                    Image(systemName: iconName)
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(.white)
                        .scaleEffect(animateCheck ? 1.0 : 0.0)
                } else if isActive {
                    ProgressView()
                        .scaleEffect(0.6)
                }
            }

            Text(label)
                .font(.system(size: 14))
                .foregroundColor(isComplete || isActive ? .primary : .secondary)

            Spacer()
        }
        .onAppear {
            if isComplete {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
                    animateCheck = true
                }
            }
        }
    }

    var iconName: String {
        if hasFailed { return "xmark" }
        if hasWarning { return "exclamationmark" }
        return "checkmark"
    }

    var borderColor: Color {
        if hasFailed { return .red }
        if hasWarning { return .orange }
        if isComplete { return .green }
        if isActive { return .accentColor }
        return .gray.opacity(0.4)
    }

    var fillColor: Color {
        if hasFailed { return .red }
        if hasWarning { return .orange }
        return .green
    }
}
