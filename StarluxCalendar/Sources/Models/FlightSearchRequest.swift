//
//  FlightSearchRequest.swift
//  StarluxCalendar
//
//  Created by Kevin Chan on 2025/10/1.
//

import Foundation

struct Itinerary: Codable {
    let departureDate: String
    let departure: String
    let arrival: String
}

struct Travelers: Codable {
    let adt: Int
    let chd: Int
    let inf: Int
}

struct FlightSearchRequest: Codable {
    let itineraries: [Itinerary]
    let travelers: Travelers
    let cabin: String
}

struct FlightMonthRequest: Codable {
    let itineraries: [Itinerary]
    let travelers: Travelers
    let cabin: String
    let goFareFamilyCode: String
}
