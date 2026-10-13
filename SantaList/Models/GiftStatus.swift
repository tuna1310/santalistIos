import SwiftUI

/// Gift shopping workflow status
public enum GiftStatus: String, CaseIterable, Codable, Identifiable, Sendable {
    case idea = "Idea"
    case ordered = "Ordered"
    case received = "Received"
    case wrapped = "Wrapped"

    public var id: String { rawValue }

    public var title: String {
        rawValue
    }

    /// SF Symbol for the status
    public var systemImage: String {
        switch self {
        case .idea:
            return "lightbulb.fill"
        case .ordered:
            return "cart.fill"
        case .received:
            return "shippingbox.fill"
        case .wrapped:
            return "gift.fill"
        }
    }

    /// Color representation
    public var tintColor: Color {
        switch self {
        case .idea:
            return Color("WarmGold", bundle: nil)
        case .ordered:
            return Color.orange
        case .received, .wrapped:
            return Color("PineGreen", bundle: nil)
        }
    }

    /// Whether the gift is finished (Received or Wrapped)
    public var isCompleted: Bool {
        self == .received || self == .wrapped
    }

    /// Whether the gift price counts towards spent amount (Ordered, Received, or Wrapped)
    public var isCountedAsSpent: Bool {
        self == .ordered || self == .received || self == .wrapped
    }

    /// Cyclic progression: Idea -> Ordered -> Received -> Wrapped -> Idea
    public func next() -> GiftStatus {
        switch self {
        case .idea:
            return .ordered
        case .ordered:
            return .received
        case .received:
            return .wrapped
        case .wrapped:
            return .idea
        }
    }
}
