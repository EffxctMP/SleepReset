import SwiftUI

struct SettingsView: View {
    @State private var notificationsEnabled = true
    @State private var bedtimeReminders = true

    var body: some View {
        Form {
            Section(header: Text("Notifications")) {
                Toggle("Enable Notifications", isOn: $notificationsEnabled)
                Toggle("Bedtime Reminders", isOn: $bedtimeReminders)
            }

            Section(header: Text("About")) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("SleepReset")
                        .font(.headline)
                    Text("Manage your sleep goals and schedules.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .navigationTitle("Settings")
    }
}

#Preview {
    NavigationStack {
        SettingsView()
    }
}
