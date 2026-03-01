import SwiftUI

struct ScanResultsView: View {
    @EnvironmentObject var state: UninstallerState

    var body: some View {
        VStack(spacing: 16) {
            // Header
            HStack(spacing: 12) {
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.system(size: 28))
                    .foregroundColor(.red)

                VStack(alignment: .leading, spacing: 2) {
                    Text(isSpanish
                        ? "\(state.scanResult?.traces.count ?? 0) rastros encontrados"
                        : "\(state.scanResult?.traces.count ?? 0) traces found")
                        .font(.system(size: 20, weight: .bold))

                    Text(isSpanish
                        ? "Tamaño total: \(state.scanResult?.totalSizeDisplay ?? "0")"
                        : "Total size: \(state.scanResult?.totalSizeDisplay ?? "0")")
                        .font(.system(size: 13))
                        .foregroundColor(.secondary)
                }

                Spacer()
            }
            .padding(.horizontal, 24)
            .padding(.top, 16)

            // Traces list
            ScrollView {
                VStack(spacing: 12) {
                    if let result = state.scanResult {
                        ForEach(TraceCategory.allCases) { category in
                            if let traces = result.tracesByCategory[category], !traces.isEmpty {
                                CategorySection(category: category, traces: traces)
                            }
                        }
                    }
                }
                .padding(.horizontal, 24)
            }

            Divider()

            // Action buttons
            HStack(spacing: 12) {
                Button(action: {
                    NSApplication.shared.terminate(nil)
                }) {
                    Text(isSpanish ? "Cancelar" : "Cancel")
                }
                .buttonStyle(.bordered)
                .controlSize(.large)

                Spacer()

                Button(action: {
                    state.confirmDetonation()
                }) {
                    HStack(spacing: 6) {
                        Image(systemName: "trash.fill")
                        Text(isSpanish ? "Eliminar Todo" : "Remove All")
                            .font(.system(size: 14, weight: .semibold))
                    }
                    .frame(minWidth: 160)
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                .tint(.red)
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 16)
        }
    }
}

struct CategorySection: View {
    let category: TraceCategory
    let traces: [ClaudeTrace]

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            // Category header
            HStack(spacing: 6) {
                Image(systemName: category.icon)
                    .foregroundColor(.red)
                    .frame(width: 20)
                Text(category.displayName)
                    .font(.system(size: 14, weight: .semibold))
                Spacer()
                Text("\(traces.count)")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 2)
                    .background(
                        Capsule().fill(Color.red.opacity(0.1))
                    )
            }

            // Traces
            ForEach(traces) { trace in
                TraceRow(trace: trace)
            }
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.red.opacity(0.04))
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .strokeBorder(Color.red.opacity(0.1), lineWidth: 1)
                )
        )
    }
}

struct TraceRow: View {
    let trace: ClaudeTrace

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "xmark.circle.fill")
                .font(.system(size: 12))
                .foregroundColor(.red.opacity(0.6))

            VStack(alignment: .leading, spacing: 1) {
                Text(trace.displayDescription)
                    .font(.system(size: 12))
                Text(trace.path)
                    .font(.system(size: 10, design: .monospaced))
                    .foregroundColor(.secondary)
                    .lineLimit(1)
                    .truncationMode(.middle)
            }

            Spacer()

            if trace.sizeBytes > 0 {
                Text(trace.sizeDisplay)
                    .font(.system(size: 11, design: .monospaced))
                    .foregroundColor(.secondary)
            }
        }
        .padding(.leading, 26)
    }
}
