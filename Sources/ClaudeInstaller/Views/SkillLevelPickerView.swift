import SwiftUI

struct SkillLevelPickerView: View {
    @Binding var selectedLevel: SkillLevel

    var body: some View {
        VStack(spacing: 8) {
            ForEach(SkillLevel.allCases) { level in
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        selectedLevel = level
                    }
                }) {
                    HStack(spacing: 12) {
                        Image(systemName: level.iconName)
                            .font(.system(size: 18))
                            .foregroundColor(selectedLevel == level ? .accentColor : .secondary)
                            .frame(width: 28)

                        VStack(alignment: .leading, spacing: 2) {
                            Text(level.title)
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.primary)
                            Text(level.skillDescription)
                                .font(.system(size: 11))
                                .foregroundColor(.secondary)
                        }

                        Spacer()

                        if selectedLevel == level {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.accentColor)
                                .transition(.scale.combined(with: .opacity))
                        }
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(selectedLevel == level
                                ? Color.accentColor.opacity(0.08)
                                : Color.clear)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(
                                selectedLevel == level ? Color.accentColor.opacity(0.3) : Color.clear,
                                lineWidth: 1
                            )
                    )
                }
                .buttonStyle(.plain)
            }
        }
    }
}
