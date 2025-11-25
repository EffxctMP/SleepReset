import SwiftUI
internal import EventKit
import UIKit

struct CalendarView: View {
    @EnvironmentObject var calendar: CalendarManager
    @State private var showingAddEvent = false
    @State private var eventTitle = ""
    @State private var eventDate = Date()
    @State private var errorMessage: String?
    @State private var displayedMonth = Date()
    @State private var selectedDate = Date()
    @State private var showingProfile = false
    @State private var showingSettings = false

    var body: some View {
        NavigationStack {
            Group {
                if calendar.hasFullAccess {
                    calendarList
                } else if calendar.hasWriteOnlyAccess ||
                            calendar.authorizationStatus == .denied ||
                            calendar.authorizationStatus == .restricted {
                    accessDeniedView
                } else {
                    accessRequestView
                }
            }
            .navigationTitle("Calendar")
            .toolbar {
                ToolbarItemGroup(placement: .topBarTrailing) {

                    if calendar.hasFullAccess {
                        Button {
                            eventTitle = ""
                            eventDate = Date()
                            showingAddEvent = true
                        } label: {
                            Label("Add Event", systemImage: "plus")
                        }
                    }

                    Button {
                        showingProfile = true
                    } label: {
                        Image(systemName: "person.crop.circle")
                    }

                    Button {
                        showingSettings = true
                    } label: {
                        Image(systemName: "gear")
                    }
                }
            }
            .sheet(isPresented: $showingAddEvent) {
                NavigationStack {
                    Form {
                        Section("Event Details") {
                            TextField("Title", text: $eventTitle)
                            DatePicker("Start", selection: $eventDate,
                                       displayedComponents: [.date, .hourAndMinute])
                        }

                        if let errorMessage {
                            Section {
                                Text(errorMessage)
                                    .foregroundStyle(.red)
                            }
                        }
                    }
                    .navigationTitle("New Event")
                    .toolbar {
                        ToolbarItem(placement: .cancellationAction) {
                            Button("Cancel") { showingAddEvent = false }
                        }

                        ToolbarItem(placement: .confirmationAction) {
                            Button("Save") { saveEvent() }
                                .disabled(eventTitle.trimmingCharacters(in: .whitespaces).isEmpty)
                        }
                    }
                }
            }
            .sheet(isPresented: $showingSettings) {
                SettingsView()
            }
            .sheet(isPresented: $showingProfile) {
                ProfileView()
            }
        }
    }

    // MARK: - MAIN CALENDAR LIST
    private var calendarList: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {

                monthHeader

                if calendar.events.isEmpty {
                    ContentUnavailableView(
                        "No Upcoming Events",
                        systemImage: "calendar.badge.exclamationmark",
                        description: Text("Add a new event to sync with your iOS calendar.")
                    )
                    .frame(maxWidth: .infinity)
                } else {
                    VStack(alignment: .leading, spacing: 8) {
                        weekdayHeader
                        calendarGrid
                    }

                    if !events(on: selectedDate).isEmpty {
                        Section("Events on \(selectedDate.formatted(date: .abbreviated, time: .omitted))") {
                            ForEach(events(on: selectedDate), id: \.eventIdentifier) { event in
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(event.title)
                                        .font(.headline)
                                    Text(event.startDate.formatted(date: .omitted, time: .shortened))
                                        .foregroundStyle(.secondary)
                                }
                                .padding(.vertical, 4)
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
            }
            .padding()
        }
        .scrollBounceBehavior(.basedOnSize)
        .refreshable { calendar.fetchEvents() }
        .onAppear {
            calendar.fetchEvents()
            selectedDate = Date()
            displayedMonth = Calendar.current.date(
                from: Calendar.current.dateComponents([.year, .month], from: Date())
            ) ?? Date()
        }
    }

    // MARK: - MONTH HEADER
    private var monthHeader: some View {
        HStack {
            Button {
                displayedMonth = Calendar.current.date(byAdding: .month, value: -1, to: displayedMonth) ?? displayedMonth
            } label: {
                Image(systemName: "chevron.left")
            }

            Spacer()

            Text(monthTitle)
                .font(.headline)

            Spacer()

            Button {
                displayedMonth = Calendar.current.date(byAdding: .month, value: 1, to: displayedMonth) ?? displayedMonth
            } label: {
                Image(systemName: "chevron.right")
            }
        }
    }

    // MARK: - WEEKDAY HEADER
    private var weekdayHeader: some View {
        let symbols = Calendar.current.shortWeekdaySymbols
        let firstWeekdayIndex = Calendar.current.firstWeekday - 1
        let ordered = Array(symbols[firstWeekdayIndex...] + symbols[..<firstWeekdayIndex])

        return HStack(spacing: 0) {
            ForEach(ordered, id: \.self) { day in
                Text(day)
                    .font(.caption)
                    .frame(maxWidth: .infinity)
                    .foregroundStyle(.secondary)
            }
        }
    }

    // MARK: - GRID
    private var calendarGrid: some View {
        let columns = Array(repeating: GridItem(.flexible()), count: 7)
        let days = daysInMonth(for: displayedMonth)

        return LazyVGrid(columns: columns, spacing: 12) {
            ForEach(days, id: \.self) { day in
                Button {
                    selectedDate = day
                } label: {
                    VStack(spacing: 6) {
                        Text("\(Calendar.current.component(.day, from: day))")
                            .font(.body)
                            .padding(8)
                            .frame(maxWidth: .infinity)
                            .background(dayBackground(for: day))
                            .clipShape(Circle())

                        if !events(on: day).isEmpty {
                            Circle()
                                .frame(width: 6, height: 6)
                                .foregroundStyle(.tint)
                        }
                    }
                    .frame(height: 52)
                    .foregroundStyle(textColor(for: day))
                }
                .buttonStyle(.plain)
                .disabled(!Calendar.current.isDate(day, equalTo: displayedMonth, toGranularity: .month))
                .opacity(Calendar.current.isDate(day, equalTo: displayedMonth, toGranularity: .month) ? 1 : 0.25)
            }
        }
    }

    // MARK: - DAY STYLING
    private func dayBackground(for date: Date) -> some ShapeStyle {
        if Calendar.current.isDate(date, inSameDayAs: selectedDate) {
            return AnyShapeStyle(.tint.opacity(0.2))
        }
        if Calendar.current.isDateInToday(date) {
            return AnyShapeStyle(.secondary.opacity(0.2))
        }
        return AnyShapeStyle(.clear)
    }

    private func textColor(for date: Date) -> some ShapeStyle {
        if Calendar.current.isDate(date, inSameDayAs: selectedDate) {
            return AnyShapeStyle(.tint)
        }
        return AnyShapeStyle(.primary)
    }

    // MARK: - DATE UTILS
    private func daysInMonth(for date: Date) -> [Date] {
        let cal = Calendar.current

        guard let monthInterval = cal.dateInterval(of: .month, for: date),
              let firstWeek = cal.dateInterval(of: .weekOfMonth, for: monthInterval.start)?.start,
              let lastWeek = cal.dateInterval(of: .weekOfMonth,
                                              for: monthInterval.end.addingTimeInterval(-1))?.end
        else { return [] }

        var days: [Date] = []
        var cursor = firstWeek

        while cursor < lastWeek {
            days.append(cursor)
            cursor = cal.date(byAdding: .day, value: 1, to: cursor) ?? cursor
        }

        return days
    }

    private func events(on date: Date) -> [EKEvent] {
        calendar.events.filter {
            Calendar.current.isDate($0.startDate, inSameDayAs: date)
        }
    }

    private var monthTitle: String {
        let f = DateFormatter()
        f.dateFormat = "LLLL yyyy"
        return f.string(from: displayedMonth)
    }

    // MARK: - ACCESS VIEWS
    private var accessDeniedView: some View {
        VStack(spacing: 20) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.largeTitle)
                .foregroundStyle(.orange)

            Text("Full calendar access is required.")
                .multilineTextAlignment(.center)

            Button("Open Settings") {
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url)
                }
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
    }

    private var accessRequestView: some View {
        VStack(spacing: 16) {
            if calendar.isRequestingAccess {
                ProgressView("Requesting access…")
            } else {
                Image(systemName: "calendar.badge.plus")
                    .font(.largeTitle)
                    .foregroundStyle(.tint)

                Text("Allow SleepReset to read your calendar.")
                    .multilineTextAlignment(.center)

                Button {
                    Task { await calendar.requestAccess() }
                } label: {
                    Label("Request Access", systemImage: "person.badge.key")
                }
                .buttonStyle(.borderedProminent)
            }
        }
        .padding()
        .task { await calendar.requestAccess() }
    }

    // MARK: - SAVE EVENT
    private func saveEvent() {
        errorMessage = nil
        let trimmed = eventTitle.trimmingCharacters(in: .whitespacesAndNewlines)

        Task {
            do {
                try await calendar.saveEvent(title: trimmed, startDate: eventDate)
                showingAddEvent = false
            } catch {
                errorMessage = "Could not save event. Please try again."
            }
        }
    }
}
