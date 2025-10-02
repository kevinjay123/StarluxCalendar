//
//  StarluxCalendarTests.swift
//  StarluxCalendarTests
//
//  Created by Kevin Chan on 2025/8/22.
//

import Testing
import ComposableArchitecture

@testable import StarluxCalendar

struct HomeFeatureTests {
    
    @Test func showListAndSelectedItem() async throws {
        let airport = AirportModel(region: "亞洲", location: "台北", name: "桃園國際機場", code: "TPE", disabled: false)
        let airport2 = AirportModel(region: "亞洲", location: "東京", name: "成田國際機場", code: "NRT", disabled: false)

        let store = await TestStore(initialState: HomeFeature.State(
            airports: [airport, airport2]
        )) {
            HomeFeature()
        }
                
        await store.send(.showList(.fromAirport)) {
            $0.departureType = .fromAirport
            $0.airportList = AirportListFeature.State(items: [$0.airports[0], $0.airports[1]])
        }
        
        await store.send(.list(.presented(.selectItem(airport)))) { state in
            state.fromCity = airport
            state.airportList = nil
        }
    }
    
    @Test func showListAndCancel() async throws {
        let airport = AirportModel(region: "亞洲", location: "台北", name: "桃園國際機場", code: "TPE", disabled: false)
        let airport2 = AirportModel(region: "亞洲", location: "東京", name: "成田國際機場", code: "NRT", disabled: false)

        let store = await TestStore(initialState: HomeFeature.State(
            airports: [airport, airport2]
        )) {
            HomeFeature()
        }
                
        await store.send(.showList(.fromAirport)) {
            $0.departureType = .fromAirport
            $0.airportList = AirportListFeature.State(items: [$0.airports[0], $0.airports[1]])
        }
        
        await store.send(.list(.presented(.cancel))) { state in
            state.airportList = nil
        }
    }
    
    @Test func showListAndDismiss() async throws {
        let airport = AirportModel(region: "亞洲", location: "台北", name: "桃園國際機場", code: "TPE", disabled: false)
        let airport2 = AirportModel(region: "亞洲", location: "東京", name: "成田國際機場", code: "NRT", disabled: false)

        let store = await TestStore(initialState: HomeFeature.State(
            airports: [airport, airport2]
        )) {
            HomeFeature()
        }
                
        await store.send(.showList(.fromAirport)) {
            $0.departureType = .fromAirport
            $0.airportList = AirportListFeature.State(items: [$0.airports[0], $0.airports[1]])
        }
        
        await store.send(.list(.dismiss)) { state in
            state.airportList = nil
        }
    }
    
    @Test func swapAirport() async throws {
        let airport = AirportModel(region: "", location: "", name: "", code: "TPE", disabled: false)
        let airport2 = AirportModel(region: "", location: "", name: "", code: "NRT", disabled: false)
        let store = await TestStore(initialState: HomeFeature.State(
            fromCity: airport,
            toCity: airport2
        )) {
            HomeFeature()
        }
        await store.send(.swapAirport) {
            $0.fromCity = airport2
            $0.toCity = airport
        }
    }
    
    @Test func showDatePickerSelectYearMonth() async throws {
        let store = await TestStore(initialState: HomeFeature.State()) {
            HomeFeature()
        }

        await store.send(.showDatePicker) {
            $0.yearMonthPicker = YearMonthPickerFeature.State(
                year: $0.selectedYear,
                month: $0.selectedMonth,
                years: $0.years,
                months: $0.months
            )
        }
        
        await store.send(.yearMonth(.presented(.selectYear(2025))))
        await store.send(.yearMonth(.presented(.selectMonth(10))))
    }
    
    @Test func showAndSelectedCabin() async throws {
        let store = await TestStore(initialState: HomeFeature.State()) {
            HomeFeature()
        }
        
        await store.send(.showCabinType) { state in
            state.cabinList = CabinFeature.State(cabins: CabinType.allCases)
        }
        
        await store.send(.selectedCabin(.presented(.selectItem(.business)))) { state in
            state.selectedCabin = .business
            state.cabinList = nil
        }
    }
    
    @Test func showCabinAndCancel() async throws {
        let store = await TestStore(initialState: HomeFeature.State()) {
            HomeFeature()
        }
        
        await store.send(.showCabinType) { state in
            state.cabinList = CabinFeature.State(cabins: CabinType.allCases)
        }
        
        await store.send(.selectedCabin(.presented(.cancel))) { state in
            state.cabinList = nil
        }
    }
    
    @Test func showCabinAndDismiss() async throws {
        let store = await TestStore(initialState: HomeFeature.State()) {
            HomeFeature()
        }
        
        await store.send(.showCabinType) { state in
            state.cabinList = CabinFeature.State(cabins: CabinType.allCases)
        }
        
        await store.send(.selectedCabin(.dismiss)) { state in
            state.cabinList = nil
        }
    }
    
    @Test func airportsResponse_Success() async throws {
        let store = await TestStore(initialState: HomeFeature.State()) {
            HomeFeature()
        }
        
        await(store.send(.airportsResponse(.success([]))))
    }
}
