import SwiftUI

/// Status chip view for gift items:
/// - Single tap: Advances to next status
/// - Long press (contextMenu): Directly pick any status
public struct StatusChipView: View {
    public let status: GiftStatus
    public var onNext: (() -> Void)? = nil
    public var onSelect: ((GiftStatus) -> Void)? = nil

    public init(status: GiftStatus, onNext: (() -> Void)? = nil, onSelect: ((GiftStatus) -> Void)? = nil) {
        self.status = status
        self.onNext = onNext
        self.onSelect = onSelect
    }

    public var body: some View {
        Button {
            onNext?()
        } label: {
            HStack(spacing: 5) {
                Image(systemName: status.systemImage)
                    .font(.caption2.weight(.bold))
                Text(status.title)
                    .font(.caption.weight(.semibold))
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(backgroundColor.opacity(0.15))
            .foregroundStyle(foregroundColor)
            .clipShape(Capsule())
            .overlay(
                Capsule()
                    .strokeBorder(foregroundColor.opacity(0.35), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Status: \(status.title). Tap to advance.")
        .contextMenu {
            ForEach(GiftStatus.allCases) { item in
                Button {
                    onSelect?(item)
                } label: {
                    Label(item.title, systemImage: item.systemImage)
                }
            }
        }
    }

    private var backgroundColor: Color {
        switch status {
        case .idea:
            return Color("WarmGold")
        case .ordered:
            return Color.orange
        case .received, .wrapped:
            return Color("PineGreen")
        }
    }

    private var foregroundColor: Color {
        switch status {
        case .idea:
            return Color("WarmGold")
        case .ordered:
            return Color.orange
        case .received, .wrapped:
            return Color("PineGreen")
        }
    }
}

public struct StatusBadgeView: View {
    public let status: GiftStatus
    public let onStatusChange: (GiftStatus) -> Void

    public init(status: GiftStatus, onStatusChange: @escaping (GiftStatus) -> Void) {
        self.status = status
        self.onStatusChange = onStatusChange
    }

    public var body: some View {
        StatusChipView(
            status: status,
            onNext: { onStatusChange(status.next()) },
            onSelect: { onStatusChange($0) }
        )
    }
}
