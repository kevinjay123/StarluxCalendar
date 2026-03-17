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
        HStack {
            Picker("Year", selection: Binding(
                get: { store.year },
                set: { store.send(.selectYear($0)) }
            )) {
                ForEach(store.years, id: \.self) { year in
                    Text("\(year)")
                }
            }
            .frame(width: 100)
            
            Picker("Month", selection: Binding(
                get: { store.month },
                set: { store.send(.selectMonth($0)) }
            )) {
                ForEach(store.months, id: \.self) { month in
                    Text(String(format: "%02d", month))
                }
            }
            .frame(width: 80)
        }
        .pickerStyle(.wheel)
        
        Button {
            store.send(.confirm)
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
