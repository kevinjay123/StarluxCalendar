//
//  AirportModel.swift
//  StarluxCalendar
//
//  Created by Kevin Chan on 2025/9/25.
//

import Foundation

struct AirportModel: Codable, Equatable, Identifiable {
    let region: String
    let location: String
    let name: String
    let code: String
    let disabled: Bool
    
    var id: String { code }
}

enum DepartureType: Equatable {
    case fromAirport
    case toAirport
}
