//
//  CalendarItem.swift
//  StarluxCalendar
//
//  Created by Kevin Chan on 2025/10/13.
//

import Foundation
import SwiftUI

struct Item: Equatable, Identifiable {
    var id: UUID = UUID()
    var departureDate: String = ""
    var status: String = ""
    var reason: String = ""
    var price: Price? = Price(amount: 0, currencyCode: "")
    var color: Color = .white
    var isHoliday: Bool = false
}
