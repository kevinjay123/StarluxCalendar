//
//  CalendarFeature.swift
//  StarluxCalendar
//
//  Created by Kevin Chan on 2025/9/26.
//

import ComposableArchitecture
import SwiftUI

@Reducer
struct CalendarFeature {
    
    @ObservableState
    struct State: Equatable {
        var departureDate: Date
        var cabin: CabinType
        var fromCity: AirportModel
        var toCity: AirportModel
        var isLoading: Bool = false
        var calendarItems: [Item] = []
        var maxValue: Int?
        var minValue: Int?
        var weekdays: [Date.WeekDay] = []
        @Presents var alert: AlertState<Action.Alert>?
    }
    
    enum Action: Equatable {
        static func == (lhs: CalendarFeature.Action, rhs: CalendarFeature.Action) -> Bool {
            switch (lhs, rhs) {
            case let (.alert(l), .alert(r)):
                return l == r
            case (.viewOnAppear, .viewOnAppear):
                return true
            case let (.calendarRequest(l), .calendarRequest(r)):
                return l == r
            case let (.apiResponse(l), .apiResponse(r)):
                switch (l, r) {
                case (.success(let lv), .success(let rv)):
                    return lv == rv
                case (.failure(let le), .failure(let re)):
                    return String(reflecting: le) == String(reflecting: re)
                default:
                    return false
                }
            default:
                return false
            }
        }
        
        case alert(PresentationAction<Alert>)
        case viewOnAppear
        case calendarRequest(FlightSearchResult?)
        case apiResponse(Result<(FlightMonthResult?, [Holiday]?), NetworkError>)
        
        @CasePathable
        enum Alert {
            case incrementButtonTapped
        }
    }
    
    @Dependency(\.networkService) var networkService
    @Dependency(\.dismiss) var dismiss
    
    var body: some ReducerOf<Self> {
        Reduce(core)
            .ifLet(\.$alert, action: \.alert)
    }
    
    func core(into state: inout State, action: Action) -> Effect<Action> {
        switch action {
        case .viewOnAppear:
            state.isLoading = true
            
            let isDepartureFromTaiwan = state.fromCity.code == "TPE" || state.fromCity.code == "RMQ"
            let date = state.departureDate
            let fromCity = isDepartureFromTaiwan ? state.fromCity : state.toCity
            let toCity = isDepartureFromTaiwan ? state.toCity : state.fromCity
            let cabin = state.cabin
            
            if isDepartureFromTaiwan {
                return .run { send in
                    await send(.calendarRequest(nil))
                }
            } else {
                return .run { send in
                    do {
                        let result = try await networkService.search(
                            departureDate: date,
                            fromCity: fromCity.code,
                            toCity: toCity.code,
                            cabin: cabin.rawValue
                        )

                        await send(.calendarRequest(result))
                    } catch {
                        await send(.apiResponse(.failure(.loadingFailed(error.localizedDescription))))
                    }
                }
            }
            
        case .calendarRequest(let result):
            state.isLoading = true
            
            let code = result?.meta?.fareProducts.filter({ $0.cabin == state.cabin.rawValue }).first?.fareFamilyCode ?? ""
            let date = state.departureDate
            let fromCity = result == nil ? state.fromCity : state.toCity
            let toCity = result == nil ? state.toCity : state.fromCity
            let cabin = state.cabin
            
            return .run { send in
                do {
                    async let calendarResult = await networkService.calendar(
                        departureDate: date,
                        fromCity: fromCity.code,
                        toCity: toCity.code,
                        cabin: cabin.rawValue,
                        goFareFamilyCode: code
                    )
                    
                    async let holidayResult = await networkService.holiday()
                    
                    try await send(.apiResponse(.success((calendarResult, holidayResult))))
                } catch {
                    await send(.apiResponse(.failure(.loadingFailed(error.localizedDescription))))
                }
            }
        case let .apiResponse(.success((calendarResult, holidayResult))):
            state.isLoading = false
            let maxValue = calendarResult?.data.calendars.compactMap { $0.price?.amount }.max()
            let minValue = calendarResult?.data.calendars.compactMap { $0.price?.amount }.min()
            let holidays = generateCurrentHolidays(departureDate: state.departureDate, result: holidayResult)
            
            state.calendarItems = generateCalendarItem(
                maxValue: maxValue,
                minValue: minValue,
                calendarItems: calendarResult?.data.calendars ?? [],
                holidays: holidays
            )
            return .none
        case let .apiResponse(.failure(error)):
            state.isLoading = false
            if case .loadingFailed(let message) = error {
                state.alert = AlertState(title: {
                    TextState("\(message)")
                })
            }

            return .none
        case .alert:
            return .run { _ in await self.dismiss() }
        }
        
        func generateCurrentHolidays(departureDate: Date, result: [Holiday]?) -> [Int: Holiday?] {
            guard let result else { return [:] }
            
            var holidays: [Int: Holiday?] = [:]
            
            for holiday in result {
                if let date = Date().dateFrom(holiday.date ?? "", format: .yMd),
                    date.year() == departureDate.year(),
                    date.month() == departureDate.month()
                {
                    holidays[date.day()] = holiday
                }
            }
            
            return holidays
        }
        
        func generateCalendarItem(
            maxValue: Int?,
            minValue: Int?,
            calendarItems: [CalendarItem],
            holidays: [Int: Holiday?]
        ) -> [Item] {
            var allCases = Date.WeekDay.allCases
            allCases.move(fromOffsets: IndexSet(integer: 0), toOffset: allCases.count)
            state.weekdays = allCases
            
            var reportInfos = calendarItems
            var items: [Item] = []
            let weekdayBaseCount = 7
            let selectedDate = state.departureDate
            
            /// 目前這個月有幾天
            let daysInMonth = selectedDate.daysInMonth
            
            /// 這個月的第一天
            let firstDayOfMonth = selectedDate.startOfMonth
            
            /// 這個月有幾週
            let weeksInMonth = selectedDate.getWeeksInMonth(startWith: .monday)
            
            /// 這個月第一天是星期幾
            /// WeekDay 回傳數字邏輯：星期日為 1、星期一為 2，以此類推...
            let startingSpaces = firstDayOfMonth.getWeekday(startWith: .monday)

            /// 本行事曆每週第一天從星期一開始計算
            var count = Date.WeekDay.monday.rawValue
            
            /// 因為從星期一開始計算，故行事曆格數最大值需 + 1
            let maximumDaysInGrid = weeksInMonth * weekdayBaseCount + 1
            
            /// 產生行事曆
            while count <= maximumDaysInGrid {
                /// 補足當月第一天以前的空白天數
                if count <= startingSpaces {
                    items.append(Item())
                } else {
                    /// 將預設值減第一天以前的空白天數，即為所在日期
                    let calendarDay = count - startingSpaces
                    
                    if calendarDay <= daysInMonth {
                        
                        /// 行事曆預設資料
                        var item = Item(departureDate: String(calendarDay))
                        
                        /// 將 API 資料塞進行事曆
                        if let calendar = reportInfos.first {
                            let color: Color
                            if calendar.price?.amount == maxValue {
                                color = .red
                            } else if calendar.price?.amount == minValue {
                                color = .green
                            } else {
                                color = .gray
                            }
                            
                            item.status = calendar.status
                            item.price = calendar.price
                            item.color = color
                            item.isHoliday = holidays[calendarDay] != nil
                            reportInfos.removeFirst()
                        }
                        
                        items.append(item)
                    }
                }
                
                /// 依序將預設值 +1，直到跑完整個月份
                count += 1
            }
            
            return items
        }
    }
}
