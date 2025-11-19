//
//  YearMonthPickerFeature.swift
//  StarluxCalendar
//
//  Created by Kevin Chan on 2025/9/25.
//

import ComposableArchitecture
import Foundation
import SwiftUI

struct YearMonthPickerFeature: Reducer {
    struct State: Equatable {
        var year: Int
        var month: Int
        let years: [Int]
        let months: [Int]
        
        var selectedDate: Date {
            let components = DateComponents(year: year, month: month, day: 1)
            return Calendar.current.date(from: components) ?? Date()
        }
    }
    
    enum Action {
        case selectYear(Int)
        case selectMonth(Int)
        case confirm
    }
    
    func reduce(into state: inout State, action: Action) -> Effect<Action> {
        switch action {
        case let .selectYear(year):
            state.year = year
            return .none
        case let .selectMonth(month):
            state.month = month
            return .none
        case .confirm:
            return .none
        }
    }
}
