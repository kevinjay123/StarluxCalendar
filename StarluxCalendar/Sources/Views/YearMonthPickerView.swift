//
//  YearMonthPickerView.swift
//  StarluxCalendar
//
//  Created by Kevin Chan on 2025/9/25.
//

import Foundation
import SwiftUI
import ComposableArchitecture

struct YearMonthPickerView: View {
    let store: StoreOf<YearMonthPickerFeature>
    
    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            HStack {
                Picker("Year", selection: viewStore.binding(
                    get: \.year,
                    send: YearMonthPickerFeature.Action.selectYear
                )) {
                    ForEach(viewStore.years, id: \.self) { year in
                        Text("\(year)")
                    }
                }
                .frame(width: 100)
                
                Picker("Month", selection: viewStore.binding(
                    get: \.month,
                    send: YearMonthPickerFeature.Action.selectMonth
                )) {
                    ForEach(viewStore.months, id: \.self) { month in
                        Text(String(format: "%02d", month))
                    }
                }
                .frame(width: 80)
            }
            .pickerStyle(.wheel)
            
            Button {
                viewStore.send(.confirm)
            } label: {
                Text("Confirm")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
            }
            .background(Color.blue)
            .cornerRadius(16)
            .padding(.horizontal)
        }
    }
}
