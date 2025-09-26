//
//  ListView.swift
//  Features
//
//  Created by Kevin Chan on 2025/9/23.
//

import ComposableArchitecture
import SwiftUI

struct AirportListView: View {
    let store: StoreOf<AirportListFeature>
    
    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            NavigationStack {
                List(viewStore.items ?? []) { airport in
                    HStack(alignment: .top, spacing: 12) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(airport.location)
                                .font(.headline)
                                .foregroundColor(airport.disabled ? .gray : .primary)
                                .lineLimit(1)
                                .truncationMode(.tail)
                            Text(airport.name)
                                .font(.subheadline)
                                .foregroundColor(airport.disabled ? .gray : .secondary)
                                .lineLimit(2)
                                .truncationMode(.tail)
                        }
                        Spacer()
                        Text(airport.code)
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundColor(airport.disabled ? .gray : .blue)
                    }
                    .contentShape(Rectangle())
                    .opacity(airport.disabled ? 0.5 : 1)
                    .disabled(airport.disabled)
                    .onTapGesture {
                        viewStore.send(.selectItem(airport))
                    }
                }
                .navigationTitle("Select Airport")
                .navigationBarItems(trailing: Button("Cancel") {
                    viewStore.send(.cancel)
                })
                .listStyle(.insetGrouped)
            }
        }
    }
}
