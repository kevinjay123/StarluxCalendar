//
//  APIConfig.swift
//  StarluxCalendar
//
//  Created by Kevin Chan on 2025/10/1.
//

import Foundation

enum APIConfig {
    case searchFlight(departureDate: Date, fromCity: String, toCity: String, cabin: String)
    case calendar(departureDate: Date, fromCity: String, toCity: String, cabin: String, goFareFamilyCode: String)
    case holiday
    
    private static let baseUrl = "https://ecapi.starlux-airlines.com/searchFlight/v2/flights"
    
    var url: URL {
        switch self {
        case .searchFlight:
            return URL(string: "\(APIConfig.baseUrl)/search")!
        case .calendar:
            return URL(string: "\(APIConfig.baseUrl)/calendars/monthly")!
        case .holiday:
            return URL(string: "https://opensheet.elk.sh/1yC_pjiP0orcMqRy0rpymMjDpISJhiJBcMoOmCowru84/taiwan-calendar")!
        }
    }
    
    var method: String {
        switch self {
        case .searchFlight, .calendar, .holiday:
            return "POST"
        }
    }
    
    var headers: [String: String] {
        switch self {
        case .searchFlight, .calendar:
            return ["Content-Type": "application/json",
                    "jx-lang": "zh-TW",
                    "X-Requested-With": "XMLHttpRequest"]
        case .holiday:
            return ["Content-Type": "application/json"]
        }
    }
    
    var body: Data? {
        switch self {
        case .searchFlight(let departureDate, let fromCity, let toCity, let cabin):
            var date = departureDate
            
            if departureDate.year() == Date().year() && departureDate.month() == Date().month() {
                date = Date().increaseDate(day: 1)
            }
            
            let returnDate = date.increaseDate(day: 5)
            
            let requestBody = FlightSearchRequest(
                itineraries: [
                    Itinerary(
                        departureDate: date.getDateStringFromUTC(
                            .yyyyMMdd
                        ),
                        departure: fromCity,
                        arrival: toCity
                    ),
                    Itinerary(
                        departureDate: returnDate.getDateStringFromUTC(
                            .yyyyMMdd
                        ),
                        departure: toCity,
                        arrival: fromCity
                    )
                ],
                travelers: Travelers(adt: 1, chd: 0, inf: 0),
                cabin: cabin
            )
            
            return try? JSONEncoder().encode(requestBody)
            
        case .calendar(let departureDate, let fromCity, let toCity, let cabin, let goFareFamilyCode):
            var date = departureDate
            
            if departureDate.year() == Date().year() && departureDate.month() == Date().month() {
                date = Date().increaseDate(day: 1)
            }
            
            let returnDate = date.increaseDate(day: 5)
            
            let requestBody = FlightMonthRequest(
                itineraries: [
                    Itinerary(
                        departureDate: date.getDateStringFromUTC(
                            .yyyyMMdd
                        ),
                        departure: fromCity,
                        arrival: toCity
                    ),
                    Itinerary(
                        departureDate: returnDate.getDateStringFromUTC(
                            .yyyyMMdd
                        ),
                        departure: toCity,
                        arrival: fromCity
                    )
                ],
                travelers: Travelers(adt: 1, chd: 0, inf: 0),
                cabin: cabin,
                goFareFamilyCode: goFareFamilyCode
            )
            
            return try? JSONEncoder().encode(requestBody)
        case .holiday:
            return nil
        }
    }

    var request: URLRequest {
        var req = URLRequest(url: url)
        req.httpMethod = method
        headers.forEach { req.setValue($0.value, forHTTPHeaderField: $0.key) }
        
        if let body {
            req.httpBody = body
        }
        return req
    }
}
