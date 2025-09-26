//
//  CabinView.swift
//  StarluxCalendar
//
//  Created by Kevin Chan on 2025/9/25.
//

import ComposableArchitecture
import SwiftUI

struct CabinView: View {
    let store: StoreOf<CabinFeature>

    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            List(viewStore.cabins ?? []) { cabin in
                Text(LocalizedStringKey(cabin.rawValue))
                    .contentShape(Rectangle())
                    .onTapGesture {
                        viewStore.send(.selectItem(cabin))
                    }
            }
        }
    }
}
