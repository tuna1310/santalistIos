import SwiftUI
import SwiftData

/// Tab 2: Timeline view sorting gifts by deadline ascending
public struct TimelineView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var allGifts: [Gift]

    @State private var selectedFilter: TimelineFilter = .all
    @State private var showingAddGiftSheet = false
    @State private var editingGift: Gift? = nil

    public enum TimelineFilter: String, CaseIterable, Identifiable {
        case all = "All"
        case pending = "Pending"
        case overdue = "Overdue"
        case completed = "Completed"

        public var id: String { rawValue }
    }

    public init() {}

    private var sortedGifts: [Gift] {
        allGifts.sorted(by: OverdueChecker.compareForTimeline)
    }

    private var filteredGifts: [Gift] {
        let sorted = sortedGifts
        switch selectedFilter {
        case .all:
            return sorted
        case .pending:
            return sorted.filter { !$0.status.isCompleted }
        case .overdue:
            return sorted.filter { $0.isOverdue() }
        case .completed:
            return sorted.filter { $0.status.isCompleted }
        }
    }

    public var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                AppHeaderView()

                // Filter segment bar
                Picker("Filter", selection: $selectedFilter) {
                    ForEach(TimelineFilter.allCases) { filter in
                        Text(filter.rawValue).tag(filter)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(Color("AppBackground"))

                if filteredGifts.isEmpty {
                    EmptyStateView(
                        title: emptyStateTitle,
                        systemImage: "calendar.badge.clock",
                        description: emptyStateDescription,
                        actionTitle: "Add Gift"
                    ) {
                        showingAddGiftSheet = true
                    }
                    .frame(maxHeight: .infinity)
                } else {
                    List {
                        ForEach(filteredGifts) { gift in
                            GiftRowView(
                                gift: gift,
                                showRecipientName: true,
                                onStatusChange: { newStatus in
                                    gift.status = newStatus
                                    ReminderService.shared.updateReminder(for: gift)
                                    try? modelContext.save()
                                },
                                onEdit: {
                                    editingGift = gift
                                },
                                onDelete: {
                                    deleteGift(gift)
                                }
                            )
                            .listRowBackground(Color("AppCard"))
                            .listRowSeparator(.hidden)
                            .listRowInsets(EdgeInsets(top: 6, leading: 16, bottom: 6, trailing: 16))
                        }
                    }
                    .listStyle(.plain)
                }
            }
            .background(Color("AppBackground").ignoresSafeArea())
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showingAddGiftSheet = true
                    } label: {
                        Label("Add Gift", systemImage: "plus")
                    }
                    .tint(Color("PineGreen"))
                    .accessibilityLabel("Add new gift")
                }
            }
            .sheet(isPresented: $showingAddGiftSheet) {
                AddEditGiftSheet()
            }
            .sheet(item: $editingGift) { gift in
                AddEditGiftSheet(giftToEdit: gift, preselectedPerson: gift.person)
            }
        }
    }

    private var emptyStateTitle: String {
        switch selectedFilter {
        case .all:
            return "No Gifts in Timeline"
        case .pending:
            return "No Pending Gifts"
        case .overdue:
            return "Great! No Overdue Gifts"
        case .completed:
            return "No Completed Gifts Yet"
        }
    }

    private var emptyStateDescription: String {
        switch selectedFilter {
        case .all:
            return "Add gifts and set deadlines to see them scheduled here."
        case .pending:
            return "Gifts that are not yet received or wrapped will appear here."
        case .overdue:
            return "All your gifts are on schedule or already completed."
        case .completed:
            return "Gifts with Received or Wrapped status will show up here."
        }
    }

    private func deleteGift(_ gift: Gift) {
        ReminderService.shared.cancelReminder(for: gift)
        modelContext.delete(gift)
        try? modelContext.save()
    }
}

public typealias TimelineListView = TimelineView
