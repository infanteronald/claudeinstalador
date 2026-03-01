import SwiftUI

struct PhaseProgressBar: View {
    let currentPhase: InstallationPhase
    let phaseResults: [InstallationPhase: PhaseResult]

    var body: some View {
        HStack(spacing: 4) {
            ForEach(InstallationPhase.trackablePhases) { phase in
                PhaseStep(
                    phase: phase,
                    isCurrent: phase == currentPhase,
                    isCompleted: phaseResults[phase]?.isSuccess == true || phase < currentPhase,
                    hasWarning: {
                        if case .warning = phaseResults[phase] { return true }
                        return false
                    }(),
                    hasFailed: {
                        if case .failure = phaseResults[phase] { return true }
                        return false
                    }()
                )

                if phase != InstallationPhase.trackablePhases.last {
                    Rectangle()
                        .fill(phase < currentPhase ? Color.accentColor : Color.gray.opacity(0.3))
                        .frame(height: 2)
                        .animation(.easeInOut(duration: 0.3), value: currentPhase)
                }
            }
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 16)
    }
}

struct PhaseStep: View {
    let phase: InstallationPhase
    let isCurrent: Bool
    let isCompleted: Bool
    let hasWarning: Bool
    let hasFailed: Bool

    var body: some View {
        VStack(spacing: 4) {
            ZStack {
                Circle()
                    .fill(backgroundColor)
                    .frame(width: 28, height: 28)

                if isCompleted && !hasFailed {
                    Image(systemName: hasWarning ? "exclamationmark" : "checkmark")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.white)
                } else if hasFailed {
                    Image(systemName: "xmark")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.white)
                } else if let num = phase.phaseNumber {
                    Text("\(num)")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(isCurrent ? .white : .secondary)
                }
            }
            .scaleEffect(isCurrent ? 1.15 : 1.0)
            .animation(.spring(response: 0.3), value: isCurrent)

            Text(phase.title)
                .font(.system(size: 9))
                .foregroundColor(isCurrent ? .primary : .secondary)
                .lineLimit(1)
        }
        .frame(width: 72)
    }

    var backgroundColor: Color {
        if hasFailed { return .red }
        if hasWarning && isCompleted { return .orange }
        if isCompleted { return .green }
        if isCurrent { return .accentColor }
        return Color.gray.opacity(0.3)
    }
}
