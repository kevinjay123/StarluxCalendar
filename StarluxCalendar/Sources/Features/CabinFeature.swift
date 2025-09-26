//
//  CabinFeature.swift
//  StarluxCalendar
//
//  Created by Kevin Chan on 2025/9/25.
//

import ComposableArchitecture
import Foundation
import SwiftUI

@Reducer
struct CabinFeature {
    struct State: Equatable {
        var cabins: [CabinType]?
        var selectedCabin: CabinType? = nil
    }
    
    enum Action: Equatable {
        case selectItem(CabinType)
        case cancel
    }
    
    var body: some ReducerOf<Self> {
        Reduce(core)
    }
    
    func core(into state: inout State, action: Action) -> Effect<Action> {
        switch action {
        case .selectItem(let cabinType):
            state.selectedCabin = cabinType
            return .none
        case .cancel:
            return .none
        }
    }
}
