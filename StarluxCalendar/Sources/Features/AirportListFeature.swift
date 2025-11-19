//
//  AirportListFeature.swift
//  StarluxCalendar
//
//  Created by Kevin Chan on 2025/9/25.
//

import Foundation
import ComposableArchitecture
import SwiftUI

@Reducer
struct AirportListFeature {
    struct State: Equatable {
        var items: [AirportModel]?
        var selectedItem: AirportModel? = nil
    }
    
    enum Action {
        case selectItem(AirportModel)
        case cancel
    }
    
    var body: some ReducerOf<Self> {
        Reduce(core)
    }
    
    func core(into state: inout State, action: Action) -> Effect<Action> {
        switch action {
        case let .selectItem(item):
            state.selectedItem = item
            return .none
        case .cancel:
            return .none
        }
    }
}
