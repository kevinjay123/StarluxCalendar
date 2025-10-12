//
//  StarluxCalendarApp.swift
//  StarluxCalendar
//
//  Created by Kevin Chan on 2025/8/22.
//

import SwiftUI
import ComposableArchitecture

@main
struct StarluxCalendarApp: App {
    var body: some Scene {
        WindowGroup {
            AppView(
                store: .init(
                    initialState: AppFeature.State(),
                    reducer: {
                        AppFeature()
                })
            ).preferredColorScheme(.light)
        }
    }
}
