//
//  Airport.swift
//  StarluxCalendar
//
//  Created by Kevin Chan on 2025/9/24.
//

import ComposableArchitecture
import Foundation

enum AirportError: Error, Equatable {
    case loadingFailed(String)
}

protocol AirportService {
    func loadAirports() async throws -> [AirportModel]
}

struct LiveAirportService: AirportService {
    func loadAirports() async throws -> [AirportModel] {
        guard let url = Bundle.main.url(forResource: "StarluxAirport", withExtension: "json") else {
            throw NSError(domain: "FileNotFound", code: 0, userInfo: nil)
        }
        
        let data = try Data(contentsOf: url)
        return try JSONDecoder().decode([AirportModel].self, from: data)
    }
}

private enum AirportServiceKey: DependencyKey {
    static let liveValue: any AirportService = LiveAirportService()
}

extension DependencyValues {
    var airportService: any AirportService {
        get { self[AirportServiceKey.self] }
        set { self[AirportServiceKey.self] = newValue }
    }
}
