import SwiftUI

// MARK: - Sort Options
enum LookSortOption: String, CaseIterable, Identifiable {
    case newest = "Newest"
    case oldest = "Oldest"
    case alphabetical = "A-Z"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .newest: return "arrow.down.circle"
        case .oldest: return "arrow.up.circle"
        case .alphabetical: return "textformat.abc"
        }
    }
}

struct SavedLooksView: View {
    @EnvironmentObject var appState: AppState
    @State private var selectedLook: MakeupLook?
    @State private var searchText = ""
    @State private var selectedOccasion: Occasion?
    @State private var sortOption: LookSortOption = .newest
    @State private var showingFilters = false

    private var filteredLooks: [MakeupLook] {
        var looks = appState.savedLooks

        // Filter by search text
        if !searchText.isEmpty {
            looks = looks.filter { look in
                look.lookName.localizedCaseInsensitiveContains(searchText) ||
                look.vibe.localizedCaseInsensitiveContains(searchText)
            }
        }

        // Filter by occasion
        if let occasion = selectedOccasion {
            looks = looks.filter { $0.occasion == occasion }
        }

        // Sort
        switch sortOption {
        case .newest:
            looks = looks.sorted { $0.createdAt > $1.createdAt }
        case .oldest:
            looks = looks.sorted { $0.createdAt < $1.createdAt }
        case .alphabetical:
            looks = looks.sorted { $0.lookName < $1.lookName }
        }

        return looks
    }

    private var favoriteLooks: [MakeupLook] {
        filteredLooks.filter { appState.isLookFavorite($0) }
    }

    private var regularLooks: [MakeupLook] {
        filteredLooks.filter { !appState.isLookFavorite($0) }
    }

    var body: some View {
        Group {
            if appState.savedLooks.isEmpty {
                emptyState
            } else {
                looksList
            }
        }
        .navigationTitle("Saved Looks")
        .searchable(text: $searchText, prompt: "Search looks...")
        .sheet(item: $selectedLook) { look in
            LookResultView(look: look)
        }
    }

    // MARK: - Empty State

    private var emptyState: some View {
        VStack(spacing: 20) {
            Image(systemName: "heart.slash")
                .font(.system(size: 60))
                .foregroundColor(.gray.opacity(0.5))

            Text("No Saved Looks")
                .font(.title2)
                .fontWeight(.semibold)

            Text("Looks you save will appear here")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemGroupedBackground))
    }

    // MARK: - Looks List

    private var looksList: some View {
        List {
            // Filter and Sort Controls
            filterSection

            // Stats
            if !filteredLooks.isEmpty {
                statsSection
            }

            // Favorites Section
            if !favoriteLooks.isEmpty {
                Section {
                    ForEach(favoriteLooks) { look in
                        SavedLookRow(
                            look: look,
                            isFavorite: true,
                            onFavoriteToggle: { toggleFavorite(look) }
                        )
                        .onTapGesture {
                            HapticManager.selectionChanged()
                            selectedLook = look
                        }
                    }
                    .onDelete { offsets in
                        deleteLooks(from: favoriteLooks, at: offsets)
                    }
                } header: {
                    HStack {
                        Image(systemName: "star.fill")
                            .foregroundColor(.yellow)
                        Text("Favorites")
                    }
                }
            }

            // Regular Looks Section
            if !regularLooks.isEmpty {
                Section {
                    ForEach(regularLooks) { look in
                        SavedLookRow(
                            look: look,
                            isFavorite: false,
                            onFavoriteToggle: { toggleFavorite(look) }
                        )
                        .onTapGesture {
                            HapticManager.selectionChanged()
                            selectedLook = look
                        }
                    }
                    .onDelete { offsets in
                        deleteLooks(from: regularLooks, at: offsets)
                    }
                } header: {
                    if !favoriteLooks.isEmpty {
                        Text("All Looks")
                    }
                }
            }

            // No Results
            if filteredLooks.isEmpty && !appState.savedLooks.isEmpty {
                Section {
                    VStack(spacing: 12) {
                        Image(systemName: "magnifyingglass")
                            .font(.largeTitle)
                            .foregroundColor(.gray)
                        Text("No looks match your filters")
                            .foregroundColor(.secondary)
                        Button("Clear Filters") {
                            HapticManager.lightImpact()
                            searchText = ""
                            selectedOccasion = nil
                        }
                        .foregroundColor(.pink)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 32)
                }
            }
        }
        .listStyle(.insetGrouped)
    }

    // MARK: - Filter Section

    private var filterSection: some View {
        Section {
            // Occasion Filter Pills
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    // All filter
                    FilterChip(
                        label: "All",
                        icon: "sparkles",
                        isSelected: selectedOccasion == nil
                    ) {
                        HapticManager.selectionChanged()
                        withAnimation {
                            selectedOccasion = nil
                        }
                    }

                    // Occasion filters
                    ForEach(Occasion.allCases) { occasion in
                        FilterChip(
                            label: occasion.displayName,
                            icon: occasion.icon,
                            isSelected: selectedOccasion == occasion
                        ) {
                            HapticManager.selectionChanged()
                            withAnimation {
                                selectedOccasion = occasion
                            }
                        }
                    }
                }
                .padding(.vertical, 4)
            }

            // Sort Picker
            HStack {
                Text("Sort by")
                    .foregroundColor(.secondary)
                Spacer()
                Picker("Sort", selection: $sortOption) {
                    ForEach(LookSortOption.allCases) { option in
                        Label(option.rawValue, systemImage: option.icon)
                            .tag(option)
                    }
                }
                .pickerStyle(.menu)
                .tint(.pink)
                .onChange(of: sortOption) { _, _ in
                    HapticManager.selectionChanged()
                }
            }
        }
    }

    // MARK: - Stats Section

    private var statsSection: some View {
        Section {
            HStack(spacing: 20) {
                StatBadge(value: "\(filteredLooks.count)", label: "Looks", icon: "sparkles")
                StatBadge(value: "\(favoriteLooks.count)", label: "Favorites", icon: "star.fill")
                StatBadge(
                    value: "\(Set(filteredLooks.map { $0.occasion }).count)",
                    label: "Occasions",
                    icon: "calendar"
                )
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 4)
        }
    }

    // MARK: - Actions

    private func toggleFavorite(_ look: MakeupLook) {
        HapticManager.lightImpact()
        withAnimation {
            appState.toggleFavorite(look)
        }
    }

    private func deleteLooks(from looks: [MakeupLook], at offsets: IndexSet) {
        HapticManager.warning()
        for index in offsets {
            let look = looks[index]
            appState.removeLook(look)
        }
    }
}

// MARK: - Filter Chip

struct FilterChip: View {
    let label: String
    let icon: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.caption)
                Text(label)
                    .font(.caption)
                    .fontWeight(.medium)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(isSelected ? Color.pink : Color(.systemGray6))
            .foregroundColor(isSelected ? .white : .primary)
            .cornerRadius(20)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Stat Badge

struct StatBadge: View {
    let value: String
    let label: String
    let icon: String

    var body: some View {
        VStack(spacing: 4) {
            HStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.caption)
                    .foregroundColor(.pink)
                Text(value)
                    .font(.headline)
                    .fontWeight(.bold)
            }
            Text(label)
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Saved Look Row

struct SavedLookRow: View {
    let look: MakeupLook
    let isFavorite: Bool
    let onFavoriteToggle: () -> Void

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

                    if isFavorite {
                        Image(systemName: "star.fill")
                            .font(.caption)
                            .foregroundColor(.yellow)
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

                Text(look.createdAt.formatted(date: .abbreviated, time: .omitted))
                    .font(.caption2)
                    .foregroundColor(.gray)
            }

            Spacer()

            // Favorite button
            Button {
                onFavoriteToggle()
            } label: {
                Image(systemName: isFavorite ? "star.fill" : "star")
                    .foregroundColor(isFavorite ? .yellow : .gray)
                    .font(.title3)
            }
            .buttonStyle(.plain)

            Image(systemName: "chevron.right")
                .foregroundColor(.gray)
                .font(.caption)
        }
        .padding(.vertical, 8)
        .contentShape(Rectangle())
    }
}

#Preview {
    NavigationStack {
        SavedLooksView()
            .environmentObject(AppState())
    }
}
