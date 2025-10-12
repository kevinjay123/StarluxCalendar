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
        case alert(PresentationAction<Alert>)
        case viewOnAppear
        case calendarRequest(FlightSearchResult?)
        case apiResponse(Result<FlightMonthResult?, NetworkError>)
        
        @CasePathable
        enum Alert {
            case incrementButtonTapped
        }
    }
    
    @Dependency(\.networkService) var networkService
    
    var body: some ReducerOf<Self> {
        Reduce(core)
            .ifLet(\.$alert, action: \.alert)
    }
    
    func core(into state: inout State, action: Action) -> Effect<Action> {
        switch action {
        case .viewOnAppear:
            state.isLoading = true
            
            let isDeptureFromTaiwan = state.fromCity.code == "TPE" || state.fromCity.code == "RMQ"
            let date = state.departureDate
            let fromCity = isDeptureFromTaiwan ? state.fromCity : state.toCity
            let toCity = isDeptureFromTaiwan ? state.toCity : state.fromCity
            let cabin = state.cabin
            
            if isDeptureFromTaiwan {
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
                    let result = try await networkService.calendar(
                        departureDate: date,
                        fromCity: fromCity.code,
                        toCity: toCity.code,
                        cabin: cabin.rawValue,
                        goFareFamilyCode: code
                    )
                    
                    await send(.apiResponse(.success(result)))
                } catch {
                    await send(.apiResponse(.failure(.loadingFailed(error.localizedDescription))))
                }
            }
        case let .apiResponse(.success(result)):
            state.isLoading = false
            let maxValue = result?.data.calendars.compactMap { $0.price?.amount }.max()
            let minValue = result?.data.calendars.compactMap { $0.price?.amount }.min()
            
            state.calendarItems = generateCalendarItem(
                maxValue: maxValue,
                minValue: minValue,
                calendarItems: result?.data.calendars ?? []
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
            return .none
        }
        
        func generateCalendarItem(maxValue: Int?, minValue: Int?, calendarItems: [CalendarItem]) -> [Item] {
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

struct Item: Equatable, Identifiable {
    var id: UUID = UUID()
    var departureDate: String = ""
    var status: String = ""
    var reason: String = ""
    var price: Price? = Price(amount: 0, currencyCode: "")
    var color: Color = .white
}
