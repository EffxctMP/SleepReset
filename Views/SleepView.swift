import SwiftUI

struct SleepView: View {
    @EnvironmentObject var calendar: CalendarManager
    @State private var sleepGoal = 8.0

    var body: some View {
        VStack(spacing: 30) {

            Text("Recommended Bedtime")
                .font(.title)
                .bold()

            Text(bedtimeString)
                .font(.system(size: 40))
                .bold()

            VStack {
                Text("Sleep Goal: \(Int(sleepGoal)) hours")
                Slider(value: $sleepGoal, in: 4...12, step: 1)
            }

            Spacer()
        }
        .padding()
        .navigationTitle("Sleep")
        .onAppear { calendar.fetchEvents() }
    }

    var bedtimeString: String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short

        let recommended = calendar.recommendedBedtime(sleepHours: sleepGoal)
        return formatter.string(from: recommended)
    }
}
