//
//  CalendarView.swift
//  StarluxCalendar
//
//  Created by Kevin Chan on 2025/9/26.
//

import ComposableArchitecture
import SwiftUI

struct CalendarView: View {
    @Bindable var store: StoreOf<CalendarFeature>
    
    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            ZStack {
                if viewStore.isLoading {
                    ProgressView() {
                        Text("Loading...")
                    }
                } else {
                    ScrollView {
                        Text("Hello")
                    }
                }
            }
            .alert($store.scope(state: \.alert, action: \.alert))
            .navigationTitle("Calendar")
            .onAppear {
                store.send(.viewOnAppear)
            }
        }
    }
}
