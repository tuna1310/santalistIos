import SwiftUI
import SwiftData

/// Recipient detail view showing individual budget progress and gift list
public struct PersonDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @Bindable var person: Person

    @State private var showingEditSheet = false
    @State private var showingAddGiftSheet = false
    @State private var editingGift: Gift? = nil
    @State private var showingDeletePersonAlert = false

    public init(person: Person) {
        self.person = person
    }

    public var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                budgetSummaryCard

                if !person.note.isEmpty {
                    noteCard
                }

                HStack {
                    Text("Gifts (\(person.gifts.count))")
                        .font(.headline)
                        .foregroundStyle(Color("PineGreen"))

                    Spacer()

                    Button {
                        showingAddGiftSheet = true
                    } label: {
                        Label("Add Gift", systemImage: "plus.circle.fill")
                            .font(.subheadline.bold())
                    }
                    .tint(Color("PineGreen"))
                }
                .padding(.horizontal, 16)

                if person.gifts.isEmpty {
                    EmptyStateView(
                        title: "No Gifts Yet",
                        systemImage: "gift",
                        description: "Add your first gift idea for \(person.name).",
                        actionTitle: "Add Gift for \(person.name)"
                    ) {
                        showingAddGiftSheet = true
                    }
                    .padding(.top, 24)
                } else {
                    LazyVStack(spacing: 12) {
                        ForEach(person.gifts) { gift in
                            GiftRowView(
                                gift: gift,
                                showRecipientName: false,
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
                        }
                    }
                    .padding(.horizontal, 16)
                }
            }
            .padding(.vertical, 16)
        }
        .background(Color("AppBackground").ignoresSafeArea())
        .navigationTitle(person.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Menu {
                    Button {
                        showingEditSheet = true
                    } label: {
                        Label("Edit Recipient", systemImage: "pencil")
                    }

                    Button(role: .destructive) {
                        showingDeletePersonAlert = true
                    } label: {
                        Label("Delete Recipient", systemImage: "trash")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
            }
        }
        .sheet(isPresented: $showingEditSheet) {
            AddEditPersonSheet(personToEdit: person)
        }
        .sheet(isPresented: $showingAddGiftSheet) {
            AddEditGiftSheet(preselectedPerson: person)
        }
        .sheet(item: $editingGift) { gift in
            AddEditGiftSheet(giftToEdit: gift, preselectedPerson: person)
        }
        .alert("Delete Recipient", isPresented: $showingDeletePersonAlert) {
            Button("Cancel", role: .cancel) {}
            Button("Delete All", role: .destructive) {
                deletePerson()
            }
        } message: {
            Text("Deleting \"\(person.name)\" will permanently remove all \(person.gifts.count) associated gifts. This action cannot be undone.")
        }
    }

    private var budgetSummaryCard: some View {
        VStack(spacing: 12) {
            HStack {
                Text("Personal Budget")
                    .font(.subheadline)
                    .foregroundStyle(Color("TextSecondary"))
                Spacer()
                Text(Formatters.formatVND(person.budget))
                    .font(.headline)
                    .fontWeight(.bold)
            }

            BudgetProgressBar(planned: person.plannedAmount, budget: person.budget)

            Divider()

            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Planned")
                        .font(.caption)
                        .foregroundStyle(Color("TextSecondary"))
                    Text(Formatters.formatVND(person.plannedAmount))
                        .font(.subheadline)
                        .fontWeight(.semibold)
                }

                Spacer()

                VStack(alignment: .leading, spacing: 2) {
                    Text("Spent")
                        .font(.caption)
                        .foregroundStyle(Color("TextSecondary"))
                    Text(Formatters.formatVND(person.spentAmount))
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundStyle(Color("PineGreen"))
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 2) {
                    Text("Remaining")
                        .font(.caption)
                        .foregroundStyle(Color("TextSecondary"))
                    Text(Formatters.formatVND(person.remainingBudget))
                        .font(.subheadline)
                        .fontWeight(.bold)
                        .foregroundStyle(person.isOverBudget ? Color("CranberryRed") : Color.primary)
                }
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color("AppCard"))
                .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
        )
        .padding(.horizontal, 16)
    }

    private var noteCard: some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: "note.text")
                .foregroundColor(Color("WarmGold"))
                .font(.subheadline)

            VStack(alignment: .leading, spacing: 2) {
                Text("Notes")
                    .font(.caption.bold())
                    .foregroundStyle(Color("TextSecondary"))
                Text(person.note)
                    .font(.subheadline)
                    .foregroundStyle(Color("TextPrimary"))
            }
            Spacer()
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(Color("WarmGold").opacity(0.1))
        )
        .padding(.horizontal, 16)
    }

    private func deleteGift(_ gift: Gift) {
        ReminderService.shared.cancelReminder(for: gift)
        if let idx = person.gifts.firstIndex(where: { $0.id == gift.id }) {
            person.gifts.remove(at: idx)
        }
        modelContext.delete(gift)
        try? modelContext.save()
    }

    private func deletePerson() {
        ReminderService.shared.cancelReminders(for: person.gifts)
        modelContext.delete(person)
        try? modelContext.save()
        dismiss()
    }
}
