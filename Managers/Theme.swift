import SwiftUI

enum AppTheme: String, CaseIterable, Identifiable {
    case blue
    case indigo
    case teal
    case orange
    case pink
    case purple

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .blue: "Sky"
        case .indigo: "Indigo"
        case .teal: "Teal"
        case .orange: "Sunrise"
        case .pink: "Blush"
        case .purple: "Violet"
        }
    }

    var accent: Color {
        switch self {
        case .blue: .blue
        case .indigo: .indigo
        case .teal: .teal
        case .orange: .orange
        case .pink: .pink
        case .purple: .purple
        }
    }

    static var `default`: AppTheme { .indigo }
}
