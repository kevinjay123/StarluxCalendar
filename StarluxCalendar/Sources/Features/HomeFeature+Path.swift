//
//  HomeFeature+Path.swift
//  StarluxCalendar
//
//  Created by Kevin Chan on 2025/9/26.
//

import Foundation
import ComposableArchitecture

extension HomeFeature {
    @Reducer(state: .equatable, action: .equatable)
    enum Path {
        case calendar(CalendarFeature)
    }
}
