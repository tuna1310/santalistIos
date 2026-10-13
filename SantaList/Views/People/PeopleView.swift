import SwiftUI
import SwiftData

/// Tab 1: Recipients list with summary cards and floating add-gift button
public struct PeopleView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Person.name) private var people: [Person]

    @State private var showingAddPersonSheet = false
    @State private var showingAddGiftSheet = false
    @State private var personToEdit: Person? = nil
    @State private var personToDelete: Person? = nil
    @State private var showingDeleteAlert = false
    @State private var searchText = ""

    public init() {}

    private var filteredPeople: [Person] {
        if searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return people
        }
        return people.filter {
            $0.name.localizedCaseInsensitiveContains(searchText) ||
            $0.note.localizedCaseInsensitiveContains(searchText)
        }
    }

    public var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                AppHeaderView()

                if people.isEmpty {
                    EmptyStateView(
                        title: "No Recipients Yet",
                        systemImage: "person.crop.circle.badge.plus",
                        description: "Add your family and friends to start tracking gift ideas.",
                        actionTitle: "Add First Recipient"
                    ) {
                        showingAddPersonSheet = true
                    }
                    .frame(maxHeight: .infinity)
                } else {
                    ScrollView {
                        LazyVStack(spacing: 16) {
                            ForEach(filteredPeople) { person in
                                NavigationLink {
                                    PersonDetailView(person: person)
                                } label: {
                                    PersonCard(
                                        person: person,
                                        onEdit: {
                                            personToEdit = person
                                        },
                                        onDelete: {
                                            personToDelete = person
                                            showingDeleteAlert = true
                                        }
                                    )
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding()
                        .padding(.bottom, 60)
                    }
                    .searchable(text: $searchText, prompt: "Search recipients...")
                }
            }
            .background(Color("AppBackground"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        showingAddPersonSheet = true
                    } label: {
                        Label("Add Person", systemImage: "person.badge.plus")
                            .foregroundStyle(Color("PineGreen"))
                    }
                    .accessibilityLabel("Add recipient")
                }

                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showingAddGiftSheet = true
                    } label: {
                        Label("Add Gift", systemImage: "gift.fill")
                            .foregroundStyle(Color("PineGreen"))
                    }
                    .accessibilityLabel("Add gift")
                }
            }
            .overlay(alignment: .bottomTrailing) {
                if !people.isEmpty {
                    Button {
                        showingAddGiftSheet = true
                    } label: {
                        HStack(spacing: 8) {
                            Image(systemName: "plus")
                                .font(.body.weight(.bold))
                            Text("Add Gift")
                                .font(.subheadline.weight(.bold))
                        }
                        .foregroundStyle(.white)
                        .padding(.horizontal, 18)
                        .padding(.vertical, 12)
                        .background(Color("PineGreen"))
                        .clipShape(Capsule())
                        .shadow(color: Color("PineGreen").opacity(0.35), radius: 8, x: 0, y: 4)
                    }
                    .padding(.trailing, 20)
                    .padding(.bottom, 16)
                    .accessibilityLabel("Floating button to add new gift")
                }
            }
            .sheet(isPresented: $showingAddPersonSheet) {
                AddEditPersonSheet()
            }
            .sheet(item: $personToEdit) { person in
                AddEditPersonSheet(personToEdit: person)
            }
            .sheet(isPresented: $showingAddGiftSheet) {
                AddEditGiftSheet()
            }
            .confirmationDialog(
                "Delete Recipient",
                isPresented: $showingDeleteAlert,
                titleVisibility: .visible,
                presenting: personToDelete
            ) { person in
                Button("Delete recipient & all gifts", role: .destructive) {
                    deletePerson(person)
                }
                Button("Cancel", role: .cancel) {}
            } message: { person in
                Text("Deleting \"\(person.name)\" will permanently remove all gifts for this person. This action cannot be undone.")
            }
        }
    }

    private func deletePerson(_ person: Person) {
        for gift in person.gifts {
            ReminderService.shared.cancelReminder(for: gift.id)
        }
        modelContext.delete(person)
        try? modelContext.save()
    }
}

/// Person summary card view
struct PersonCard: View {
    let person: Person
    let onEdit: () -> Void
    let onDelete: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(person.name)
                        .font(.headline)
                        .foregroundStyle(Color("TextPrimary"))

                    if !person.note.isEmpty {
                        Text(person.note)
                            .font(.caption)
                            .foregroundStyle(Color("TextSecondary"))
                            .lineLimit(1)
                    }
                }

                Spacer()

                Menu {
                    Button {
                        onEdit()
                    } label: {
                        Label("Edit Recipient", systemImage: "pencil")
                    }

                    Button(role: .destructive) {
                        onDelete()
                    } label: {
                        Label("Delete Recipient", systemImage: "trash")
                    }
                } label: {
                    Image(systemName: "ellipsis")
                        .font(.body)
                        .foregroundStyle(Color("TextSecondary"))
                        .padding(8)
                }
            }

            HStack {
                HStack(spacing: 6) {
                    Image(systemName: "gift")
                        .font(.caption)
                        .foregroundStyle(Color("PineGreen"))
                    Text("\(person.gifts.count) \(person.gifts.count == 1 ? "gift" : "gifts")")
                        .font(.caption)
                        .foregroundStyle(Color("TextSecondary"))
                }

                Spacer()

                HStack(spacing: 4) {
                    Text("Planned:")
                        .font(.caption2)
                        .foregroundStyle(Color("TextSecondary"))
                    Text(Formatters.formatVND(person.plannedAmount))
                        .font(.caption.weight(.bold))
                        .foregroundStyle(person.isOverBudget ? Color("CranberryRed") : Color("PineGreen"))
                    Text("/ \(Formatters.formatVND(person.budget))")
                        .font(.caption2)
                        .foregroundStyle(Color("TextSecondary"))
                }
            }

            BudgetProgressBar(
                planned: person.plannedAmount,
                budget: person.budget
            )
        }
        .padding()
        .background(Color("AppCard"))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: Color.black.opacity(0.04), radius: 6, x: 0, y: 2)
    }
}

public typealias PeopleListView = PeopleView
