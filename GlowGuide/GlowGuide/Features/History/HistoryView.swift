import SwiftUI

struct HistoryView: View {
    @EnvironmentObject var appState: AppState
    @State private var selectedLook: MakeupLook?
    @State private var showingClearConfirmation = false

    var body: some View {
        Group {
            if appState.recentlyViewedLooks.isEmpty {
                emptyState
            } else {
                historyList
            }
        }
        .navigationTitle("History")
        .toolbar {
            if !appState.recentlyViewedLooks.isEmpty {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        HapticManager.warning()
                        showingClearConfirmation = true
                    } label: {
                        Text("Clear")
                            .foregroundColor(.pink)
                    }
                }
            }
        }
        .alert("Clear History?", isPresented: $showingClearConfirmation) {
            Button("Cancel", role: .cancel) { }
            Button("Clear", role: .destructive) {
                HapticManager.warning()
                withAnimation {
                    appState.clearHistory()
                }
            }
        } message: {
            Text("This will remove all recently viewed looks from your history.")
        }
        .sheet(item: $selectedLook) { look in
            LookResultView(look: look)
        }
    }

    // MARK: - Empty State

    private var emptyState: some View {
        VStack(spacing: 20) {
            Image(systemName: "clock.arrow.circlepath")
                .font(.system(size: 60))
                .foregroundColor(.gray.opacity(0.5))

            Text("No Recent Looks")
                .font(.title2)
                .fontWeight(.semibold)

            Text("Looks you view will appear here")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemGroupedBackground))
    }

    // MARK: - History List

    private var historyList: some View {
        List {
            // Stats Section
            Section {
                HStack(spacing: 20) {
                    StatBadge(
                        value: "\(appState.recentlyViewedLooks.count)",
                        label: "Recent",
                        icon: "clock"
                    )
                    StatBadge(
                        value: "\(Set(appState.recentlyViewedLooks.map { $0.occasion }).count)",
                        label: "Occasions",
                        icon: "calendar"
                    )
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 4)
            }

            // Today Section
            let todayLooks = looksForToday()
            if !todayLooks.isEmpty {
                Section {
                    ForEach(todayLooks) { look in
                        HistoryRow(look: look, isSaved: appState.isLookSaved(look))
                            .onTapGesture {
                                HapticManager.selectionChanged()
                                selectedLook = look
                            }
                    }
                    .onDelete { offsets in
                        deleteLooks(from: todayLooks, at: offsets)
                    }
                } header: {
                    Label("Today", systemImage: "sun.max")
                }
            }

            // Earlier Section
            let earlierLooks = looksFromEarlier()
            if !earlierLooks.isEmpty {
                Section {
                    ForEach(earlierLooks) { look in
                        HistoryRow(look: look, isSaved: appState.isLookSaved(look))
                            .onTapGesture {
                                HapticManager.selectionChanged()
                                selectedLook = look
                            }
                    }
                    .onDelete { offsets in
                        deleteLooks(from: earlierLooks, at: offsets)
                    }
                } header: {
                    Label("Earlier", systemImage: "clock")
                }
            }
        }
        .listStyle(.insetGrouped)
    }

    // MARK: - Helpers

    private func looksForToday() -> [MakeupLook] {
        let calendar = Calendar.current
        return appState.recentlyViewedLooks.filter { look in
            calendar.isDateInToday(look.createdAt)
        }
    }

    private func looksFromEarlier() -> [MakeupLook] {
        let calendar = Calendar.current
        return appState.recentlyViewedLooks.filter { look in
            !calendar.isDateInToday(look.createdAt)
        }
    }

    private func deleteLooks(from looks: [MakeupLook], at offsets: IndexSet) {
        HapticManager.warning()
        for index in offsets {
            let look = looks[index]
            appState.removeFromHistory(look)
        }
    }
}

// MARK: - History Row

struct HistoryRow: View {
    let look: MakeupLook
    let isSaved: Bool

    var body: some View {
        HStack(spacing: 16) {
            // Color preview
            HStack(spacing: 4) {
                Circle()
                    .fill(look.colorPalette.eyeshadow.color)
                    .frame(width: 20, height: 20)
                Circle()
                    .fill(look.colorPalette.lips.color)
                    .frame(width: 20, height: 20)
                Circle()
                    .fill(look.colorPalette.blush.color)
                    .frame(width: 20, height: 20)
            }
            .padding(8)
            .background(Color(.systemGray6))
            .cornerRadius(12)

            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(look.lookName)
                        .font(.headline)

                    if isSaved {
                        Image(systemName: "heart.fill")
                            .font(.caption)
                            .foregroundColor(.pink)
                    }
                }

                HStack {
                    Label(look.occasion.displayName, systemImage: look.occasion.icon)
                        .font(.caption)
                        .foregroundColor(.secondary)

                    Text("•")
                        .foregroundColor(.secondary)

                    Text(look.vibe)
                        .font(.caption)
                        .foregroundColor(.pink)
                        .lineLimit(1)
                }

                Text(timeAgoString(from: look.createdAt))
                    .font(.caption2)
                    .foregroundColor(.gray)
            }

            Spacer()

            Image(systemName: "chevron.right")
                .foregroundColor(.gray)
                .font(.caption)
        }
        .padding(.vertical, 8)
        .contentShape(Rectangle())
    }

    private func timeAgoString(from date: Date) -> String {
        let calendar = Calendar.current
        let now = Date()

        if calendar.isDateInToday(date) {
            let components = calendar.dateComponents([.hour, .minute], from: date, to: now)
            if let hours = components.hour, hours > 0 {
                return "\(hours)h ago"
            } else if let minutes = components.minute, minutes > 0 {
                return "\(minutes)m ago"
            } else {
                return "Just now"
            }
        } else if calendar.isDateInYesterday(date) {
            return "Yesterday"
        } else {
            return date.formatted(date: .abbreviated, time: .omitted)
        }
    }
}

#Preview {
    NavigationStack {
        HistoryView()
            .environmentObject(AppState())
    }
}
