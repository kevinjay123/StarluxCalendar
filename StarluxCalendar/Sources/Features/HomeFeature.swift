//
//  HomeFeature.swift
//  StarluxCalendar
//
//  Created by Kevin Chan on 2025/9/24.
//

import SwiftUI
import ComposableArchitecture

@Reducer
struct HomeFeature {
    
    @ObservableState
    struct State: Equatable {
        @Presents var airportList: AirportListFeature.State?
        var airports: [AirportModel] = []
        var fromCity: AirportModel?
        var toCity: AirportModel?
        var departureType: DepartureType?
        
        @Presents var yearMonthPicker: YearMonthPickerFeature.State?
        var selectedYear: Int = Date().year()
        var selectedMonth: Int = Date().month()
        let years: [Int] = Array(2000...2030)
        let months: [Int] = Array(1...12)
        
        @Presents var cabinList: CabinFeature.State?
        var cabinTypes: [CabinType] = CabinType.allCases
        var selectedCabin: CabinType = .eco
        
        var path = StackState<Path.State>()
    }
    
    enum Action: Equatable {
        case scenePhaseBecomeActive
        case swapAirport
        case airportsResponse(Result<[AirportModel], AirportError>)
        case list(PresentationAction<AirportListFeature.Action>)
        case showList(DepartureType)
        
        case yearMonth(PresentationAction<YearMonthPickerFeature.Action>)
        case showDatePicker
        
        case showCabinType
        case selectedCabin(PresentationAction<CabinFeature.Action>)
        
        case path(StackActionOf<Path>)
        case toCalendar
    }
    
    @Dependency(\.airportService) var airportService
    
    var body: some ReducerOf<Self> {
        Reduce(core)
            .ifLet(\.$airportList, action: \.list) {
                AirportListFeature()
            }
            .ifLet(\.$yearMonthPicker, action: \.yearMonth) {
                YearMonthPickerFeature()
            }
            .ifLet(\.$cabinList, action: \.selectedCabin) {
                CabinFeature()
            }
            .forEach(\.path, action: \.path)
    }

    func core(into state: inout State, action: Action) -> Effect<Action> {
        switch action {
        case .showList(let type):
            state.departureType = type
            state.airportList = AirportListFeature.State(items: state.airports)
            return .none
        case let .list(.presented(.selectItem(item))):
            guard let departureType = state.departureType else {
                return .none
            }
            
            switch departureType {
            case .fromAirport:
                state.fromCity = item
            case .toAirport:
                state.toCity = item
            }
            
            state.airportList = nil
            return .none
        case .list(.presented(.cancel)):
            state.airportList = nil
            return .none
        case .list(.dismiss):
            state.airportList = nil
            return .none
        case .showDatePicker:
            state.yearMonthPicker = YearMonthPickerFeature.State(
                year: state.selectedYear,
                month: state.selectedMonth,
                years: state.years,
                months: state.months
            )
            return .none
        case .yearMonth(.presented(.selectYear(let year))):
            state.selectedYear = year
            return .none
        case .yearMonth(.presented(.selectMonth(let month))):
            state.selectedMonth = month
            return .none
        case .yearMonth(.presented(.confirm)):
            state.yearMonthPicker = nil
            return .none
        case .yearMonth(.dismiss):
            state.yearMonthPicker = nil
            return .none
        case .showCabinType:
            state.cabinList = CabinFeature.State(cabins: state.cabinTypes)
            return .none
        case let .selectedCabin(.presented(.selectItem(type))):
            state.selectedCabin = type
            state.cabinList = nil
            return .none
        case .selectedCabin(.dismiss):
            state.cabinList = nil
            return .none
        case .selectedCabin(.presented(.cancel)):
            state.cabinList = nil
            return .none
        case .scenePhaseBecomeActive:
            return .run { send in
                do {
                    let airports = try await airportService.loadAirports()
                    await send(.airportsResponse(.success(airports)))
                } catch {
                    await send(.airportsResponse(.failure(.loadingFailed(error.localizedDescription))))
                }
            }
        case let .airportsResponse(.success(airports)):
            state.airports = airports
            
            if let tpeCity = airports.filter({ $0.code == "TPE" }).first {
                state.fromCity = tpeCity
            }
            
            if let nrtCity = airports.filter({ $0.code == "NRT" }).first {
                state.toCity = nrtCity
            }
            
            return .none
        case .airportsResponse(.failure(.loadingFailed(_))):
            state.airports = []
            return .none
        case .swapAirport:
            (state.fromCity, state.toCity) = (state.toCity, state.fromCity)
            return .none
        case .path(_):
            return .none
        case .toCalendar:
            guard let fromCity = state.fromCity, let toCity = state.toCity else {
                return .none
            }
            let date = Date.createDate(year: state.selectedYear, month: state.selectedMonth)
            state.path.append(.calendar(.init(departureDate: date, cabin: state.selectedCabin, fromCity: fromCity, toCity: toCity)))
            return .none
        }
    }
}
