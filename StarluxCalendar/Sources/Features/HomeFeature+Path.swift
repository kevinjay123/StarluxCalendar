//
//  HomeFeature+Path.swift
//  StarluxCalendar
//
//  Created by Kevin Chan on 2025/9/26.
//

import Foundation
import ComposableArchitecture

extension HomeFeature {
    @Reducer
    enum Path {
        case calendar(CalendarFeature)
    }
}

extension HomeFeature.Path.State: Equatable { }
