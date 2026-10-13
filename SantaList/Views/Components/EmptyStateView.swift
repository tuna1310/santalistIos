import SwiftUI

/// Empty state view using standard iOS 17 ContentUnavailableView
public struct EmptyStateView: View {
    public let title: String
    public let systemImage: String
    public let description: String
    public var actionTitle: String? = nil
    public var action: (() -> Void)? = nil

    public init(
        title: String,
        systemImage: String,
        description: String,
        actionTitle: String? = nil,
        action: (() -> Void)? = nil
    ) {
        self.title = title
        self.systemImage = systemImage
        self.description = description
        self.actionTitle = actionTitle
        self.action = action
    }

    public var body: some View {
        ContentUnavailableView {
            Label {
                Text(title)
                    .font(.title3.bold())
            } icon: {
                Image(systemName: systemImage)
                    .font(.system(size: 48))
                    .foregroundStyle(Color("PineGreen"))
            }
        } description: {
            Text(description)
                .font(.subheadline)
                .foregroundStyle(Color("TextSecondary"))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 24)
        } actions: {
            if let actionTitle = actionTitle, let action = action {
                Button(action: action) {
                    HStack {
                        Image(systemName: "plus.circle.fill")
                        Text(actionTitle)
                    }
                    .font(.subheadline.bold())
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                }
                .buttonStyle(.borderedProminent)
                .tint(Color("PineGreen"))
                .padding(.top, 4)
            }
        }
    }
}
