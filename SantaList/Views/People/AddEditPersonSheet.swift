import SwiftUI
import SwiftData

/// Add or edit recipient sheet with inline error validations
public struct AddEditPersonSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    public var personToEdit: Person? = nil

    @State private var name: String = ""
    @State private var budgetText: String = ""
    @State private var note: String = ""

    @State private var isSubmitted: Bool = false

    public init(personToEdit: Person? = nil) {
        self.personToEdit = personToEdit
    }

    private var isEditing: Bool {
        personToEdit != nil
    }

    private var trimmedName: String {
        name.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private var parsedBudget: Int? {
        let clean = budgetText.replacingOccurrences(of: ".", with: "")
            .replacingOccurrences(of: ",", with: "")
            .replacingOccurrences(of: " ", with: "")
            .replacingOccurrences(of: "₫", with: "")
        if clean.isEmpty { return 0 }
        return Int(clean)
    }

    private var nameValidationError: String? {
        if isSubmitted && trimmedName.isEmpty {
            return "Please enter recipient name"
        }
        return nil
    }

    private var budgetValidationError: String? {
        guard let budget = parsedBudget else {
            return "Budget must be a non-negative number"
        }
        if budget < 0 {
            return "Budget cannot be negative"
        }
        return nil
    }

    private var isValid: Bool {
        !trimmedName.isEmpty && parsedBudget != nil && (parsedBudget ?? 0) >= 0
    }

    public var body: some View {
        NavigationStack {
            Form {
                Section("Recipient Information") {
                    VStack(alignment: .leading, spacing: 4) {
                        TextField("Full name or nickname", text: $name)
                            .textContentType(.name)
                            .accessibilityLabel("Recipient name")

                        if let error = nameValidationError {
                            Text(error)
                                .font(.caption)
                                .foregroundStyle(Color("CranberryRed"))
                        }
                    }

                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Text("Budget (VNĐ)")
                            Spacer()
                            TextField("0", text: $budgetText)
                                .keyboardType(.numberPad)
                                .multilineTextAlignment(.trailing)
                                .accessibilityLabel("Budget")
                        }

                        if let error = budgetValidationError {
                            Text(error)
                                .font(.caption)
                                .foregroundStyle(Color("CranberryRed"))
                        }

                        if let budget = parsedBudget, budget > 0 {
                            Text("Formatted: \(Formatters.formatVND(budget))")
                                .font(.caption2)
                                .foregroundStyle(Color("PineGreen"))
                        }
                    }
                }

                Section("Notes") {
                    TextField("Preferences, sizes, notes (optional)", text: $note, axis: .vertical)
                        .lineLimit(3...6)
                        .accessibilityLabel("Notes")
                }
            }
            .navigationTitle(isEditing ? "Edit Recipient" : "Add Recipient")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button(isEditing ? "Save" : "Add") {
                        save()
                    }
                    .fontWeight(.semibold)
                    .foregroundStyle(Color("PineGreen"))
                }
            }
            .onAppear {
                if let person = personToEdit {
                    name = person.name
                    budgetText = String(person.budget)
                    note = person.note
                }
            }
        }
    }

    private func save() {
        isSubmitted = true
        guard isValid else { return }

        let finalBudget = parsedBudget ?? 0

        if let person = personToEdit {
            person.name = trimmedName
            person.budget = finalBudget
            person.note = note
        } else {
            let newPerson = Person(
                name: trimmedName,
                budget: finalBudget,
                note: note
            )
            modelContext.insert(newPerson)
        }

        try? modelContext.save()
        dismiss()
    }
}

public typealias PersonFormSheet = AddEditPersonSheet
