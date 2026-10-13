import SwiftUI

/// Gift occasion
public enum Occasion: String, CaseIterable, Codable, Identifiable, Sendable {
    case christmas = "Christmas"
    case birthday = "Birthday"
    case anniversary = "Anniversary"
    case other = "Other"

    public var id: String { rawValue }

    public var title: String {
        rawValue
    }

    public var systemImage: String {
        switch self {
        case .christmas:
            return "sparkles"
        case .birthday:
            return "birthday.cake.fill"
        case .anniversary:
            return "heart.fill"
        case .other:
            return "tag.fill"
        }
    }

    public var accentColor: Color {
        switch self {
        case .christmas:
            return Color("CranberryRed", bundle: nil)
        case .birthday:
            return Color("WarmGold", bundle: nil)
        case .anniversary:
            return Color.pink
        case .other:
            return Color.secondary
        }
    }
}

public typealias GiftOccasion = Occasion
