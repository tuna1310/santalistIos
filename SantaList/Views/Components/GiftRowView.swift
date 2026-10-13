import SwiftUI

/// Gift item row view displaying title, price, deadline badge, and status chip
public struct GiftRowView: View {
    public let gift: Gift
    public var showRecipientName: Bool = true
    public let onStatusChange: (GiftStatus) -> Void
    public var onEdit: (() -> Void)? = nil
    public var onDelete: (() -> Void)? = nil

    @Environment(\.openURL) private var openURL
    @State private var showingDeleteAlert = false

    public init(
        gift: Gift,
        showRecipientName: Bool = true,
        onStatusChange: @escaping (GiftStatus) -> Void,
        onEdit: (() -> Void)? = nil,
        onDelete: (() -> Void)? = nil
    ) {
        self.gift = gift
        self.showRecipientName = showRecipientName
        self.onStatusChange = onStatusChange
        self.onEdit = onEdit
        self.onDelete = onDelete
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            // Header row: Title and Status Chip
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(gift.title)
                        .font(.headline)
                        .foregroundColor(.primary)
                        .lineLimit(2)

                    if showRecipientName, let personName = gift.person?.name {
                        HStack(spacing: 4) {
                            Image(systemName: "person.crop.circle.fill")
                                .font(.caption2)
                            Text(personName)
                                .font(.caption)
                                .fontWeight(.medium)
                        }
                        .foregroundStyle(Color("TextSecondary"))
                    }
                }

                Spacer()

                // Interactive status chip
                StatusChipView(status: gift.status, onNext: {
                    onStatusChange(gift.status.next())
                }, onSelect: { newStatus in
                    onStatusChange(newStatus)
                })
            }

            // Middle row: Price, Occasion, and Deadline Badge
            HStack(spacing: 8) {
                Text(Formatters.formatVND(gift.price))
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .foregroundStyle(Color("PineGreen"))

                Text("•")
                    .foregroundStyle(Color("TextSecondary"))

                HStack(spacing: 4) {
                    Image(systemName: gift.occasion.systemImage)
                        .font(.caption2)
                    Text(gift.occasion.title)
                        .font(.caption)
                }
                .foregroundStyle(gift.occasion.accentColor)
                .padding(.horizontal, 6)
                .padding(.vertical, 2)
                .background(gift.occasion.accentColor.opacity(0.12))
                .clipShape(Capsule())

                Spacer()

                dueDateIndicator
            }

            // Footer row: Note and Link if available
            if !gift.note.isEmpty || gift.url != nil {
                HStack(alignment: .center, spacing: 12) {
                    if !gift.note.isEmpty {
                        Text(gift.note)
                            .font(.caption)
                            .foregroundStyle(Color("TextSecondary"))
                            .lineLimit(1)
                    }

                    Spacer()

                    if let urlString = gift.url, let validURL = URL(string: urlString) {
                        Button {
                            openURL(validURL)
                        } label: {
                            HStack(spacing: 4) {
                                Image(systemName: "link")
                                Text("View Link")
                            }
                            .font(.caption.bold())
                            .foregroundStyle(Color.blue)
                        }
                        .buttonStyle(.borderless)
                    }
                }
            }
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(Color("AppCard"))
                .shadow(color: Color.black.opacity(0.04), radius: 3, x: 0, y: 1)
        )
        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
            Button(role: .destructive) {
                showingDeleteAlert = true
            } label: {
                Label("Delete", systemImage: "trash")
            }

            if let onEdit = onEdit {
                Button {
                    onEdit()
                } label: {
                    Label("Edit", systemImage: "pencil")
                }
                .tint(Color("WarmGold"))
            }
        }
        .alert("Delete Gift", isPresented: $showingDeleteAlert) {
            Button("Cancel", role: .cancel) {}
            Button("Delete", role: .destructive) {
                onDelete?()
            }
        } message: {
            Text("Are you sure you want to delete \"\(gift.title)\"?")
        }
    }

    @ViewBuilder
    private var dueDateIndicator: some View {
        if let dueDate = gift.dueDate {
            let isOverdue = gift.isOverdue()
            HStack(spacing: 4) {
                Image(systemName: isOverdue ? "exclamationmark.circle.fill" : (gift.status.isCompleted ? "checkmark.circle.fill" : "calendar"))
                    .font(.caption2)
                Text(isOverdue ? "Overdue (\(Formatters.formatShortDate(dueDate)))" : (gift.status.isCompleted ? "Completed" : Formatters.formatRelativeDate(dueDate)))
                    .font(.caption2)
                    .fontWeight(isOverdue ? .bold : .medium)
            }
            .foregroundColor(isOverdue ? Color("CranberryRed") : (gift.status.isCompleted ? Color("PineGreen") : Color("TextSecondary")))
            .padding(.horizontal, 6)
            .padding(.vertical, 2)
            .background(
                (isOverdue ? Color("CranberryRed") : (gift.status.isCompleted ? Color("PineGreen") : Color("TextSecondary")))
                    .opacity(0.12)
            )
            .clipShape(Capsule())
            .accessibilityElement(children: .combine)
            .accessibilityLabel(isOverdue ? "Overdue: \(Formatters.formatDate(dueDate))" : "Due: \(Formatters.formatDate(dueDate))")
        } else {
            Text("No deadline")
                .font(.caption2)
                .foregroundStyle(Color("TextSecondary"))
        }
    }
}
