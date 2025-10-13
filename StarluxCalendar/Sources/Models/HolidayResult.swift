//
//  HolidayResult.swift
//  StarluxCalendar
//
//  Created by Kevin Chan on 2025/10/13.
//

import Foundation

struct Holiday: Codable, Equatable {
    let date: String?
    let year: String?
    let name: String?
    let isHoliday: String?
    let holidayCategory: String?

    enum CodingKeys: String, CodingKey {
        case date
        case year
        case name
        case isHoliday = "isholiday"
        case holidayCategory = "holidaycategory"
    }
}
