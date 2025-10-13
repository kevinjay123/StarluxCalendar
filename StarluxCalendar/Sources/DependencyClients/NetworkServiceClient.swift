//
//  NetworkServiceClient.swift
//  StarluxCalendar
//
//  Created by Kevin Chan on 2025/10/1.
//

import ComposableArchitecture
import Foundation

enum NetworkError: Error, Equatable {
    case loadingFailed(String)
}

protocol NetworkService {
    func search(departureDate: Date, fromCity: String, toCity: String, cabin: String) async throws -> FlightSearchResult?
    func calendar(departureDate: Date, fromCity: String, toCity: String, cabin: String, goFareFamilyCode: String) async throws -> FlightMonthResult?
    func holiday() async throws -> [Holiday]?
}

struct NetworkServiceClient: NetworkService {
    private func request<Element: Codable>(by config: APIConfig) async throws -> Element? {
        let request = config.request

        let (data, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse,
              200 ..< 300 ~= httpResponse.statusCode
        else {
            return nil
        }

        let result = try JSONDecoder().decode(Element.self, from: data)
        return result
    }
}

extension NetworkServiceClient {
    func search(
        departureDate: Date,
        fromCity: String,
        toCity: String,
        cabin: String
    ) async throws -> FlightSearchResult? {
        return try await request(
            by: APIConfig.searchFlight(
                departureDate: departureDate,
                fromCity: fromCity,
                toCity: toCity,
                cabin: cabin
            )
        )
    }
    
    func calendar(
        departureDate: Date,
        fromCity: String,
        toCity: String,
        cabin: String,
        goFareFamilyCode: String
    ) async throws -> FlightMonthResult? {
        return try await request(
            by: APIConfig.calendar(
                departureDate: departureDate,
                fromCity: fromCity,
                toCity: toCity,
                cabin: cabin,
                goFareFamilyCode: goFareFamilyCode
            )
        )
    }
    
    func holiday() async throws -> [Holiday]? {
        return try await request(by: APIConfig.holiday)
    }
}

private enum NetworkServiceKey: DependencyKey {
    static var liveValue: any NetworkService = NetworkServiceClient()
}

extension DependencyValues {
    var networkService: any NetworkService {
        get { self[NetworkServiceKey.self] }
        set { self[NetworkServiceKey.self] = newValue }
    }
}
