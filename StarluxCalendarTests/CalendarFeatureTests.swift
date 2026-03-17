import Testing
import ComposableArchitecture
import SwiftUI

@testable import StarluxCalendar

struct CalendarFeatureTests {
    @Test func apiResponse_generatesStableCalendarItemIdentifiers() async throws {
        let calendarItems = [
            CalendarItem(
                departureDate: "2025-10-01",
                status: "available",
                reason: nil,
                price: Price(amount: 1000, currencyCode: "TWD")
            ),
            CalendarItem(
                departureDate: "2025-10-02",
                status: "available",
                reason: nil,
                price: Price(amount: 2000, currencyCode: "TWD")
            )
        ]

        var state = CalendarFeature.State(
            departureDate: Date.createDate(year: 2025, month: 10),
            cabin: .eco,
            fromCity: AirportModel(region: "亞洲", location: "台北", name: "桃園國際機場", code: "TPE", disabled: false),
            toCity: AirportModel(region: "亞洲", location: "東京", name: "成田國際機場", code: "NRT", disabled: false)
        )
        let feature = CalendarFeature()

        _ = feature.core(into: &state, action: .apiResponse(.success((
            FlightMonthResult(
                success: true,
                traceId: "trace-id",
                message: Message(code: "200", content: "ok", details: nil),
                data: DataModel(calendars: calendarItems),
                links: nil,
                meta: nil
            ),
            []
        ))))

        #expect(state.isLoading == false)
        #expect(state.weekdays == [.monday, .tuesday, .wednesday, .thursday, .friday, .saturday, .sunday])
        #expect(state.calendarItems.first?.id == "blank-2")
        #expect(state.calendarItems.dropFirst().first?.id == "blank-3")
        #expect(state.calendarItems.dropFirst(2).first?.id == "day-1")
        #expect(state.calendarItems.dropFirst(3).first?.id == "day-2")
        #expect(state.calendarItems.dropFirst(2).first?.color == .green)
        #expect(state.calendarItems.dropFirst(3).first?.color == .red)
        #expect(state.calendarItems.contains(where: { $0.id == "day-31" }))
    }
}
