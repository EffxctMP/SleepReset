import SwiftUI

@main
struct SleepResetApp: App {
    @StateObject private var calendar = CalendarManager()

    var body: some Scene {
        WindowGroup {
            MainTabView()
                .environmentObject(calendar)
                .task {
                    await calendar.requestAccess()
                }
        }
    }
}

