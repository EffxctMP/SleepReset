import SwiftUI
import UIKit

struct MainTabView: View {
    @State private var showingSettings = false

    var body: some View {
        NavigationStack {
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
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showingSettings = true
                    } label: {
                        Label("Settings", systemImage: "gearshape")
                    }
                }
            }
            .background {
                NavigationLink(isActive: $showingSettings) {
                    SettingsView()
                } label: {
                    EmptyView()
                }
                .hidden()
            }
        }
    }
}
