import SwiftUI

enum ThemeColor: String, CaseIterable, Identifiable {
    case ocean = "Ocean"
    case indigo = "Indigo"
    case forest = "Forest"
    case coral = "Coral"
    case midnight = "Midnight"

    var id: String { rawValue }

    var color: Color {
        switch self {
        case .ocean:
            return Color(red: 0.16, green: 0.58, blue: 0.95)
        case .indigo:
            return Color(red: 0.38, green: 0.31, blue: 0.84)
        case .forest:
            return Color(red: 0.16, green: 0.67, blue: 0.46)
        case .coral:
            return Color(red: 1.0, green: 0.44, blue: 0.47)
        case .midnight:
            return Color(red: 0.22, green: 0.32, blue: 0.52)
        }
    }

    static var `default`: ThemeColor { .ocean }
}
