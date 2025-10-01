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
        var monthResult: FlightMonthResult?
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
            
            let date = state.departureDate
            let fromCity = state.fromCity
            let toCity = state.toCity
            let cabin = state.cabin
            
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
            
        case .calendarRequest(let result):
            state.isLoading = true
            
            let code = result?.meta?.fareProducts.filter({ $0.cabin == state.cabin.rawValue }).first?.fareFamilyCode ?? ""
            let date = state.departureDate
            let fromCity = state.fromCity
            let toCity = state.toCity
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
            state.monthResult = result
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
    }
}
