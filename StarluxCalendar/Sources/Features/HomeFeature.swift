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
        var airports: [AirportModel] = []
        var fromCity: AirportModel?
        var toCity: AirportModel?
        
        var isShowDatePicker: Bool = false
        var selectedYear: Int = 2025
        var selectedMonth: Int = 9
        let years: [Int] = Array(2000...2030)
        let months: [Int] = Array(1...12)
        
        var departureType: DepartureType?
        var isListPresented: Bool = false
        
        var cabinTypes: [CabinType] = CabinType.allCases
        var selectedCabin: CabinType = .eco
        var isShowCabinType: Bool = false
    }
    
    enum Action: Equatable {
        case scenePhaseBecomeActive
        case swapAirport
        case airportsResponse(Result<[AirportModel], AirportError>)
        
        case showList(DepartureType)
        case dismissList
        case list(AirportListFeature.Action)
        
        case yearMonth(YearMonthPickerFeature.Action)
        case showDatePicker
        case dismissDatePicker
        
        case showCabinType
        case dismissCabinType
        case selectedCabin(CabinFeature.Action)
    }
    
    @Dependency(\.airportService) var airportService
    
    var body: some ReducerOf<Self> {
        Scope(state: \.list, action: \.list) {
            AirportListFeature()
        }
        
        Scope(state: \.yearMonthList, action: \.yearMonth) {
            YearMonthPickerFeature()
        }
        
        Reduce(core)
    }

    func core(into state: inout State, action: Action) -> Effect<Action> {
        switch action {
        case .showList(let type):
            state.departureType = type
            state.isListPresented = true
            return .none
        case .dismissList:
            state.isListPresented = false
            return .none
        case let .list(.selectItem(item)):
            guard let departureType = state.departureType else {
                return .none
            }
            
            switch departureType {
            case .fromAirport:
                state.fromCity = item
            case .toAirport:
                state.toCity = item
            }
            
            state.isListPresented = false
            return .none
        case .list(.cancel):
            state.isListPresented = false
            return .none
        case .showDatePicker:
            state.isShowDatePicker = true
            return .none
        case .dismissDatePicker:
            state.isShowDatePicker = false
            return .none
        case .yearMonth(let action):
            switch action {
            case .selectYear(let year):
                state.selectedYear = year
            case .selectMonth(let month):
                state.selectedMonth = month
            case .confirm:
                state.isShowDatePicker = false
            }
            return .none
        case .showCabinType:
            state.isShowCabinType = true
            return .none
        case .dismissCabinType:
            state.isShowCabinType = false
            return .none
        case .selectedCabin(let action):
            switch action {
            case .selectItem(let cabinType):
                state.selectedCabin = cabinType
            case .cancel:
                state.isShowCabinType = false
            }
            state.isShowCabinType = false
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
        }
    }
}

extension HomeFeature.State {
    var list: AirportListFeature.State {
        get { AirportListFeature.State(items: airports, selectedItem: nil) }
        set {}
    }
    
    var yearMonthList: YearMonthPickerFeature.State {
        get { YearMonthPickerFeature.State(year: selectedYear, month: selectedMonth, years: years, months: months) }
        set {}
    }
    
    var cabinList: CabinFeature.State {
        get { CabinFeature.State(cabins: cabinTypes, selectedCabin: nil) }
        set {}
    }
}
