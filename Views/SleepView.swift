import SwiftUI
internal import EventKit

struct SleepView: View {
    @EnvironmentObject var calendar: CalendarManager
    @AppStorage("themeColorRaw") private var themeColorRaw = AppTheme.default.rawValue
    @State private var sleepGoal = 8.0
    @State private var wakeBufferHours = 1.5
    @State private var showingProfile = false
    @State private var showingSettings = false

    private let columns = [GridItem(.flexible()), GridItem(.flexible())]

    private var appTheme: AppTheme {
        AppTheme(rawValue: themeColorRaw) ?? .default
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    
                    // MARK: Bedtime Card
                    GlassCard {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Recommended Bedtime")
                                .font(.title2.weight(.semibold))

                            VStack(alignment: .leading, spacing: 8) {
                                Text(bedtimeString)
                                    .font(.system(size: 44, weight: .bold, design: .rounded))

                                Text("Based on your sleep goal and the next calendar event.")
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }

                    // MARK: Grid
                    LazyVGrid(columns: columns, spacing: 16) {

                        // Upcoming schedule
                        GlassCard {
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Upcoming Schedule")
                                    .font(.headline)

                                if let event = calendar.nextUpcomingEvent {
                                    Text(event.title)
                                        .font(.title3.weight(.semibold))

                                    VStack(alignment: .leading, spacing: 6) {
                                        Text("Event: \(event.startDate.formatted(date: .abbreviated, time: .shortened))")

                                        if let wake = wakeTimeString {
                                            Text("Wake-up: \(wake) (\(formattedWakeBuffer))")
                                        }
                                    }
                                    .foregroundStyle(.secondary)
                                } else {
                                    Text("No upcoming events detected. We'll aim for an 8 AM wake-up.")
                                        .foregroundStyle(.secondary)
                                }
                            }
                        }

                        // Sleep Goal
                        GlassCard {
                            VStack(alignment: .leading, spacing: 16) {
                                Text("Sleep Goal")
                                    .font(.headline)

                                Text("Hours: \(Int(sleepGoal))")
                                    .font(.title3.weight(.semibold))

                                Slider(value: $sleepGoal, in: 4...12, step: 1)
                            }
                        }

                        // Wake Buffer
                        GlassCard {
                            VStack(alignment: .leading, spacing: 16) {
                                Text("Wake-up Buffer")
                                    .font(.headline)

                                Picker("Buffer", selection: $wakeBufferHours) {
                                    ForEach(wakeBufferOptions, id: \.self) { hours in
                                        Text("\(hours, specifier: "%.1f") hours")
                                            .tag(hours)
                                    }
                                }
                                .pickerStyle(.segmented)
                                .tint(appTheme.accent)

                                Text("We'll plan wake-up times this long before your next event.")
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 24)
            }
            .navigationTitle("Sleep")
            .onAppear { calendar.fetchEvents() }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button { showingProfile = true } label: {
                        Image(systemName: "person.crop.circle")
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button { showingSettings = true } label: {
                        Image(systemName: "gear")
                    }
                }
            }
            .sheet(isPresented: $showingSettings) { SettingsView() }
            .sheet(isPresented: $showingProfile) { ProfileView() }
        }
        .tint(appTheme.accent)
    }

    // MARK: - Computed Values

    var bedtimeString: String {
        let f = DateFormatter()
        f.timeStyle = .short
        return f.string(from: calendar.recommendedBedtime(
            sleepHours: sleepGoal,
            bufferMinutes: wakeBufferHours * 60
        ))
    }

    private var wakeTimeString: String? {
        guard let wake = calendar.wakeTimeForNextEvent(bufferMinutes: wakeBufferHours * 60) else { return nil }
        let f = DateFormatter()
        f.timeStyle = .short
        return f.string(from: wake)
    }

    private var wakeBufferOptions: [Double] { [0.5, 1, 1.5, 2, 2.5] }

    private var formattedWakeBuffer: String {
        wakeBufferHours.truncatingRemainder(dividingBy: 1) == 0
        ? "\(Int(wakeBufferHours))h before"
        : "\(wakeBufferHours, default: "%.1f")h before"
    }
}


private struct GlassCard<Content: View>: View {
    @Environment(\.colorScheme) private var colorScheme
    let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        content
            .padding(20)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                .thinMaterial.opacity(colorScheme == .dark ? 0.20 : 0.45),
                in: RoundedRectangle(cornerRadius: 26, style: .continuous)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 26, style: .continuous)
                    .strokeBorder(
                        Color.white.opacity(colorScheme == .dark ? 0.22 : 0.35),
                        lineWidth: 1
                    )
            )
            .shadow(
                color: Color.black.opacity(colorScheme == .dark ? 0.35 : 0.12),
                radius: 22, x: 0, y: 12
            )
    }
}
