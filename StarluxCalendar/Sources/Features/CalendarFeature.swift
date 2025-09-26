//
//  CalendarFeature.swift
//  StarluxCalendar
//
//  Created by Kevin Chan on 2025/9/26.
//

import ComposableArchitecture
import SwiftUI

@Reducer
struct CalendarFeature {
    struct State: Equatable {
        
    }
    
    enum Action: Equatable {
        case readOnly
    }
    
    var body: some ReducerOf<Self> {
        Reduce(core)
    }
    
    func core(into state: inout State, action: Action) -> Effect<Action> {
        switch action {
        case .readOnly:
            return .none
        }
    }
}
