import SwiftUI

struct SleepView: View {
    @EnvironmentObject var calendar: CalendarManager
    @State private var sleepGoal = 8.0
    @State private var wakeBufferMinutes = 90.0

    private let wakeBufferOptions: [Double] = [30, 60, 90, 120]

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                recommendedBedtimeCard

                HStack(spacing: 16) {
                    sleepGoalCard
                    wakeBufferCard
                }
            }
            .padding()
        }
        .navigationTitle("Sleep")
        .onAppear { calendar.fetchEvents() }
    }

    var bedtimeString: String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short

        let recommended = calendar.recommendedBedtime(sleepHours: sleepGoal,
                                                     bufferMinutes: wakeBufferMinutes)
        return formatter.string(from: recommended)
    }

    private var upcomingScheduleDescription: String {
        guard let event = calendar.nextUpcomingEvent else {
            return "No upcoming schedule available."
        }

        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium

        let timeFormatter = DateFormatter()
        timeFormatter.timeStyle = .short

        return "\(event.title) · \(dateFormatter.string(from: event.startDate)) at \(timeFormatter.string(from: event.startDate))"
    }

    private var recommendedBedtimeCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            VStack(alignment: .leading, spacing: 8) {
                Text("Recommended Bedtime")
                    .font(.headline)
                Text(bedtimeString)
                    .font(.system(size: 40, weight: .bold))
            }

            Divider()

            VStack(alignment: .leading, spacing: 6) {
                Text("Upcoming Schedule")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                Text(upcomingScheduleDescription)
                    .font(.body)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 5)
        )
    }

    private var sleepGoalCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Sleep Goal")
                .font(.headline)

            Text("\(Int(sleepGoal)) hours")
                .font(.title2)
                .bold()

            Slider(value: $sleepGoal, in: 4...12, step: 1)
        }
        .frame(maxWidth: .infinity, minHeight: 160, alignment: .topLeading)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 5)
        )
    }

    private var wakeBufferCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Wake Up Buffer")
                .font(.headline)

            Text("\(Int(wakeBufferMinutes)) minutes before wake time")
                .font(.title3)
                .bold()

            Picker("Wake Up Buffer", selection: $wakeBufferMinutes) {
                ForEach(wakeBufferOptions, id: \.self) { option in
                    Text("\(Int(option)) minutes").tag(option)
                }
            }
            .pickerStyle(.menu)
        }
        .frame(maxWidth: .infinity, minHeight: 160, alignment: .topLeading)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 5)
        )
    }
}
