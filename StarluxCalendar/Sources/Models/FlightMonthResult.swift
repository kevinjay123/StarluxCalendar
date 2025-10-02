//
//  FlightMonthResult.swift
//  StarluxCalendar
//
//  Created by Kevin Chan on 2025/10/1.
//

import Foundation

struct FlightMonthResult: Codable, Equatable {
    let success: Bool
    let traceId: String
    let message: Message
    let data: DataModel
    let links: String?
    let meta: MonthMeta?
    
    enum CodingKeys: String, CodingKey {
        case success
        case traceId
        case message
        case data
        case links
        case meta
    }
}

struct DataModel: Codable, Equatable {
    let calendars: [CalendarItem]
    
    enum CodingKeys: String, CodingKey {
        case calendars
    }
}

struct CalendarItem: Codable, Equatable, Identifiable {
    var id: UUID = UUID()
    
    let departureDate: String
    let status: String
    let reason: String?
    let price: Price?
    
    enum CodingKeys: String, CodingKey {
        case departureDate
        case status
        case reason
        case price
    }
}

struct MonthMeta: Codable, Equatable {
    let currencies: [Currency]
    
    enum CodingKeys: String, CodingKey {
        case currencies
    }
}
