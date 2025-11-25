import SwiftUI

struct MainTabView: View {
    @AppStorage("isDarkMode") private var isDarkMode = false
    @AppStorage("themeColorRaw") private var themeColorRaw = AppTheme.default.rawValue
    @Environment(\.colorScheme) private var colorScheme

    private var appTheme: AppTheme {
        AppTheme(rawValue: themeColorRaw) ?? .default
    }

    var body: some View {
        ZStack {
            LinearGradient(
                colors: backgroundGradient,
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            TabView {
                SleepView()
                    .tabItem {
                        Label("Sleep", systemImage: "moon.zzz")
                    }

                CalendarView()
                    .tabItem {
                        Label("Calendar", systemImage: "calendar")
                    }

                SearchView()
                    .tabItem {
                        Label("Search", systemImage: "magnifyingglass")
                    }
            }
            .tint(appTheme.accent)
        }
        // DIE REGEL MET themeColor.color WAS TRASH → vervangen / verwijderd
        .preferredColorScheme(isDarkMode ? .dark : .light)
    }

    private var backgroundGradient: [Color] {
        let base = Color(.systemBackground)
        let elevated = Color(.secondarySystemBackground)
        let accent = appTheme.accent.opacity(colorScheme == .dark ? 0.55 : 0.4)
        return [base.opacity(0.92), elevated.opacity(0.85), accent]
    }
}
