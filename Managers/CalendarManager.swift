import Foundation
internal import EventKit
import Combine

@MainActor
class CalendarManager: ObservableObject {

    @Published var events: [EKEvent] = []
    @Published var authorizationStatus: EKAuthorizationStatus = .notDetermined
    @Published var isRequestingAccess = false

    private let store = EKEventStore()

    init() {
        refreshAuthorizationStatus()
    }

    // MARK: - Permissions

    func requestAccess() async {
        refreshAuthorizationStatus()

        guard authorizationStatus == .notDetermined else {
            if hasFullAccess {
                fetchEvents()
            }
            return
        }

        isRequestingAccess = true
        defer { isRequestingAccess = false }

        do {
            let granted = try await store.requestFullAccessToEvents()
            refreshAuthorizationStatus()

            if granted {
                fetchEvents()
            } else {
                authorizationStatus = .denied
            }
        } catch {
            authorizationStatus = .denied
            print("Calendar access error:", error)
        }
    }

    func refreshAuthorizationStatus() {
        authorizationStatus = EKEventStore.authorizationStatus(for: .event)
    }

    // MARK: - Events

    func fetchEvents() {
        guard hasFullAccess else { return }

        let start = Date()
        let end = Calendar.current.date(byAdding: .day, value: 30, to: start)!

        let predicate = store.predicateForEvents(withStart: start, end: end, calendars: nil)
        self.events = store.events(matching: predicate)
            .sorted { $0.startDate < $1.startDate }
    }

    func saveEvent(title: String, startDate: Date, duration: TimeInterval = 60 * 60) async throws {
        guard hasFullAccess else { return }

        let event = EKEvent(eventStore: store)
        event.title = title
        event.startDate = startDate
        event.endDate = startDate.addingTimeInterval(duration)
        event.calendar = store.defaultCalendarForNewEvents

        try store.save(event, span: .thisEvent, commit: true)
        fetchEvents()
    }

    private var workdayHours: ClosedRange<Int> { 5...14 }

    var nextUpcomingEvent: EKEvent? {
        let now = Date()
        let calendar = Calendar.current

        return events
            .filter { event in
                guard event.startDate > now else { return false }
                let hour = calendar.component(.hour, from: event.startDate)
                return workdayHours.contains(hour)
            }
            .sorted { $0.startDate < $1.startDate }
            .first
    }

    func wakeTimeForNextEvent(bufferMinutes: Double = 90) -> Date? {
        guard let event = nextUpcomingEvent else { return nil }
        return event.startDate.addingTimeInterval(-(bufferMinutes * 60))
    }

    // MARK: - Access helpers

    var hasFullAccess: Bool {
        if #available(iOS 17, *) {
            return authorizationStatus == .fullAccess
        } else {
            return authorizationStatus == .authorized
        }
    }

    var hasWriteOnlyAccess: Bool {
        if #available(iOS 17, *) {
            return authorizationStatus == .writeOnly
        } else {
            return false
        }
    }

    func recommendedBedtime(sleepHours: Double, bufferMinutes: Double = 90) -> Date {
        if let wakeTime = wakeTimeForNextEvent(bufferMinutes: bufferMinutes) {
            return wakeTime.addingTimeInterval(-(sleepHours * 3600))
        }

        // default wake-up time: 8 AM next day
        let defaultWake = Calendar.current.date(bySettingHour: 8,
                                                minute: 0,
                                                second: 0,
                                                of: Calendar.current.date(byAdding: .day, value: 1, to: Date())!)!

        return defaultWake.addingTimeInterval(-sleepHours * 3600)
    }
}
