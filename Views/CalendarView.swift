import SwiftUI
import EventKit

struct CalendarView: View {
    @EnvironmentObject var calendar: CalendarManager

    var body: some View {
        List(calendar.events, id: \.eventIdentifier) { event in
            VStack(alignment: .leading) {
                Text(event.title).bold()
                Text(event.startDate.formatted(date: .abbreviated, time: .shortened))
                    .foregroundStyle(.secondary)
            }
        }
        .navigationTitle("Calendar")
    }
}
