//
//  StarluxCalendarTests.swift
//  StarluxCalendarTests
//
//  Created by Kevin Chan on 2025/8/22.
//

import Testing
import ComposableArchitecture
import Foundation

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
        
        await store.send(.yearMonth(.presented(.selectYear(2025)))) {
            $0.selectedYear = 2025
            $0.yearMonthPicker?.year = 2025
        }
        await store.send(.yearMonth(.presented(.selectMonth(10)))) {
            $0.selectedMonth = 10
            $0.yearMonthPicker?.month = 10
        }
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
        
        await store.send(.airportsResponse(.success([]))) {
            $0.hasLoadedAirports = true
        }
    }

    @Test func scenePhaseBecomeActive_loadsOnlyOnceAfterSuccess() async throws {
        let airport = AirportModel(region: "亞洲", location: "台北", name: "桃園國際機場", code: "TPE", disabled: false)
        let airport2 = AirportModel(region: "亞洲", location: "東京", name: "成田國際機場", code: "NRT", disabled: false)
        let counter = Counter()

        let store = await TestStore(initialState: HomeFeature.State()) {
            HomeFeature()
        } withDependencies: {
            $0.airportService = MockAirportService {
                await counter.increment()
                return [airport, airport2]
            }
        }

        await store.send(.scenePhaseBecomeActive) {
            $0.isLoadingAirports = true
        }
        await store.receive(\.airportsResponse.success, [airport, airport2]) {
            $0.isLoadingAirports = false
            $0.hasLoadedAirports = true
            $0.airports = [airport, airport2]
            $0.fromCity = airport
            $0.toCity = airport2
        }

        await store.send(.scenePhaseBecomeActive)
        #expect(await counter.value == 1)
    }

    @Test func scenePhaseBecomeActive_allowsRetryAfterFailure() async throws {
        let counter = Counter()

        let store = await TestStore(initialState: HomeFeature.State()) {
            HomeFeature()
        } withDependencies: {
            $0.airportService = MockAirportService {
                await counter.increment()
                throw AirportError.loadingFailed("load failed")
            }
        }

        await store.send(.scenePhaseBecomeActive) {
            $0.isLoadingAirports = true
        }
        await store.receive(\.airportsResponse.failure, .loadingFailed("load failed")) {
            $0.isLoadingAirports = false
            $0.hasLoadedAirports = false
            $0.airports = []
        }

        await store.send(.scenePhaseBecomeActive) {
            $0.isLoadingAirports = true
        }
        await store.receive(\.airportsResponse.failure, .loadingFailed("load failed")) {
            $0.isLoadingAirports = false
            $0.hasLoadedAirports = false
            $0.airports = []
        }

        #expect(await counter.value == 2)
    }
}

private struct MockAirportService: AirportService {
    let load: @Sendable () async throws -> [AirportModel]

    init(load: @escaping @Sendable () async throws -> [AirportModel]) {
        self.load = load
    }

    func loadAirports() async throws -> [AirportModel] {
        try await load()
    }
}

private actor Counter {
    private(set) var value = 0

    func increment() {
        value += 1
    }
}
