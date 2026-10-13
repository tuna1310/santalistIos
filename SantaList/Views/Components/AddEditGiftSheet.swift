import SwiftUI
import SwiftData

/// Add or edit gift sheet with validation errors displayed directly below inputs
public struct AddEditGiftSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Person.name) private var people: [Person]

    public var giftToEdit: Gift? = nil
    public var preselectedPerson: Person? = nil

    @State private var title: String = ""
    @State private var priceText: String = ""
    @State private var occasion: Occasion = .christmas
    @State private var status: GiftStatus = .idea
    @State private var hasDueDate: Bool = false
    @State private var dueDate: Date = Date()
    @State private var note: String = ""
    @State private var url: String = ""
    @State private var selectedPerson: Person? = nil

    @State private var isSubmitted: Bool = false

    public init(giftToEdit: Gift? = nil, preselectedPerson: Person? = nil) {
        self.giftToEdit = giftToEdit
        self.preselectedPerson = preselectedPerson
    }

    private var isEditing: Bool {
        giftToEdit != nil
    }

    private var trimmedTitle: String {
        title.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private var parsedPrice: Int? {
        let clean = priceText.replacingOccurrences(of: ".", with: "")
            .replacingOccurrences(of: ",", with: "")
            .replacingOccurrences(of: " ", with: "")
            .replacingOccurrences(of: "₫", with: "")
        if clean.isEmpty { return 0 }
        return Int(clean)
    }

    private var titleValidationError: String? {
        if isSubmitted && trimmedTitle.isEmpty {
            return "Gift title cannot be empty"
        }
        return nil
    }

    private var priceValidationError: String? {
        guard let price = parsedPrice else {
            return "Price must be a non-negative number"
        }
        if price < 0 {
            return "Price cannot be negative"
        }
        return nil
    }

    private var personValidationError: String? {
        if isSubmitted && selectedPerson == nil {
            return "Please select a recipient"
        }
        return nil
    }

    private var isValid: Bool {
        !trimmedTitle.isEmpty && selectedPerson != nil && parsedPrice != nil && (parsedPrice ?? 0) >= 0
    }

    public var body: some View {
        NavigationStack {
            Form {
                Section("Recipient") {
                    if people.isEmpty {
                        Text("No recipients available. Please add a recipient first.")
                            .font(.callout)
                            .foregroundStyle(Color("CranberryRed"))
                    } else {
                        Picker("Select recipient", selection: $selectedPerson) {
                            Text("Select recipient").tag(Person?.none)
                            ForEach(people) { person in
                                Text(person.name).tag(Person?.some(person))
                            }
                        }
                        .accessibilityLabel("Select recipient")

                        if let error = personValidationError {
                            Text(error)
                                .font(.caption)
                                .foregroundStyle(Color("CranberryRed"))
                        }
                    }
                }

                Section("Gift Information") {
                    VStack(alignment: .leading, spacing: 4) {
                        TextField("Gift title (required)", text: $title)
                            .accessibilityLabel("Gift title")

                        if let error = titleValidationError {
                            Text(error)
                                .font(.caption)
                                .foregroundStyle(Color("CranberryRed"))
                        }
                    }

                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Text("Price (VNĐ)")
                            Spacer()
                            TextField("0", text: $priceText)
                                .keyboardType(.numberPad)
                                .multilineTextAlignment(.trailing)
                                .accessibilityLabel("Gift price")
                        }

                        if let error = priceValidationError {
                            Text(error)
                                .font(.caption)
                                .foregroundStyle(Color("CranberryRed"))
                        }

                        if let price = parsedPrice, price > 0 {
                            Text("Formatted: \(Formatters.formatVND(price))")
                                .font(.caption2)
                                .foregroundStyle(Color("PineGreen"))
                        }
                    }

                    Picker("Occasion", selection: $occasion) {
                        ForEach(Occasion.allCases) { occ in
                            Label(occ.title, systemImage: occ.systemImage).tag(occ)
                        }
                    }
                    .accessibilityLabel("Occasion")

                    Picker("Status", selection: $status) {
                        ForEach(GiftStatus.allCases) { st in
                            Label(st.title, systemImage: st.systemImage).tag(st)
                        }
                    }
                    .accessibilityLabel("Status")
                }

                Section("Deadline") {
                    Toggle("Has deadline", isOn: $hasDueDate.animation())
                        .accessibilityLabel("Has deadline toggle")

                    if hasDueDate {
                        DatePicker(
                            "Due date",
                            selection: $dueDate,
                            displayedComponents: .date
                        )
                        .datePickerStyle(.graphical)
                        .accessibilityLabel("Due date picker")

                        Button(role: .destructive) {
                            withAnimation {
                                hasDueDate = false
                            }
                        } label: {
                            Label("Remove deadline", systemImage: "xmark.circle")
                                .font(.callout)
                        }
                    }
                }

                Section("Additional Details") {
                    TextField("Purchase link (https://...)", text: $url)
                        .keyboardType(.URL)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                        .accessibilityLabel("Purchase link")

                    TextField("Notes (size, color, store...)", text: $note, axis: .vertical)
                        .lineLimit(3...6)
                        .accessibilityLabel("Gift notes")
                }
            }
            .navigationTitle(isEditing ? "Edit Gift" : "Add Gift")
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
                setupInitialValues()
            }
        }
    }

    private func setupInitialValues() {
        if let gift = giftToEdit {
            title = gift.title
            priceText = String(gift.price)
            occasion = gift.occasion
            status = gift.status
            note = gift.note
            url = gift.url ?? ""
            selectedPerson = gift.person
            if let due = gift.dueDate {
                hasDueDate = true
                dueDate = due
            } else {
                hasDueDate = false
                dueDate = Date()
            }
        } else {
            selectedPerson = preselectedPerson ?? people.first
            hasDueDate = false
            dueDate = Date()
        }
    }

    private func save() {
        isSubmitted = true
        guard isValid, let person = selectedPerson else { return }

        let finalPrice = parsedPrice ?? 0
        let finalDueDate = hasDueDate ? dueDate : nil
        let finalURL = url.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? nil : url.trimmingCharacters(in: .whitespacesAndNewlines)

        if let gift = giftToEdit {
            let previousPerson = gift.person
            if previousPerson?.id != person.id {
                previousPerson?.gifts.removeAll { $0.id == gift.id }
                gift.person = person
                person.gifts.append(gift)
            }
            gift.title = trimmedTitle
            gift.price = finalPrice
            gift.status = status
            gift.dueDate = finalDueDate
            gift.occasion = occasion
            gift.note = note
            gift.url = finalURL

            ReminderService.shared.updateReminder(for: gift)
        } else {
            let newGift = Gift(
                title: trimmedTitle,
                price: finalPrice,
                status: status,
                dueDate: finalDueDate,
                occasion: occasion,
                note: note,
                url: finalURL,
                person: person
            )
            person.gifts.append(newGift)
            modelContext.insert(newGift)

            ReminderService.shared.updateReminder(for: newGift)
        }

        try? modelContext.save()

        Task {
            await ReminderService.shared.requestAuthorization()
        }

        dismiss()
    }
}

public struct GiftFormSheet: View {
    public var gift: Gift? = nil
    public var defaultPerson: Person? = nil

    public init(gift: Gift? = nil, defaultPerson: Person? = nil) {
        self.gift = gift
        self.defaultPerson = defaultPerson
    }

    public var body: some View {
        AddEditGiftSheet(giftToEdit: gift, preselectedPerson: defaultPerson)
    }
}
