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
    
    private let columns = Array(repeating: GridItem(.flexible()), count: 7)
    
    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            ZStack {
                if viewStore.isLoading {
                    ProgressView() {
                        Text("Loading...")
                    }
                } else {
                    ScrollView {
                        VStack(spacing: 0) {
                            LazyVGrid(columns: columns) {
                                ForEach(viewStore.weekdays, id: \.self) { weekday in
                                    Text(LocalizedStringKey(weekday.titleCatelog))
                                        .font(.headline)
                                        .foregroundColor(.black)
                                        .frame(height: 24, alignment: .center)
                                }
                            }.padding(16)
                            
                            LazyVGrid(columns: columns, spacing: 12) {
                                ForEach(viewStore.calendarItems, id: \.id) { day in
                                    VStack(spacing: 0) {
                                        if day.status == "available" {
                                            Text(day.departureDate)
                                                .font(.headline)
                                                .foregroundColor(day.isHoliday ? .red : .black)
                                        } else {
                                            Text(day.departureDate)
                                                .font(.headline)
                                                .foregroundColor(.gray)
                                        }
                                                        
                                        if let price = day.price, day.status == "available" {
                                            Text("\(price.amount)")
                                                .font(.caption2)
                                                .foregroundColor(day.color)
                                                .lineLimit(1)
                                                .minimumScaleFactor(0.5)
                                            Text("\(price.currencyCode)")
                                                .font(.caption2)
                                                .foregroundColor(day.color)
                                                .lineLimit(1)
                                                .minimumScaleFactor(0.5)
                                        } else if !day.departureDate.isEmpty {
                                            Text("No")
                                                .font(.body)
                                                .foregroundColor(.gray)
                                                .lineLimit(1)
                                                .minimumScaleFactor(0.5)
                                                .frame(height: 12)
                                            Text("Price")
                                                .font(.body)
                                                .foregroundColor(.gray)
                                                .lineLimit(1)
                                                .minimumScaleFactor(0.5)
                                                .frame(height: 12)
                                        }
                                    }
                                    .padding(8)
                                    .cornerRadius(8)
                                }
                            }
                            .padding()
                        }
                    }
                    .padding(.top, 0)
                    .frame(maxWidth: .infinity, alignment: .top)
                }
            }
            .alert($store.scope(state: \.alert, action: \.alert))
            .navigationTitle("\(viewStore.departureDate.getDateStringFromUTC(.yyyyMMWithSlash))")
            .onAppear {
                store.send(.viewOnAppear)
            }
        }
    }
}
