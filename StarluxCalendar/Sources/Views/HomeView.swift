//
//  HomeView.swift
//  Features
//
//  Created by Kevin Chan on 2025/9/10.
//

import SwiftUI
import ComposableArchitecture
import Foundation

struct HomeView: View {
    @Bindable var store: StoreOf<HomeFeature>
    @Environment(\.scenePhase) private var scenePhase
    
    var body: some View {
        NavigationStack(
            path: $store.scope(state: \.path, action: \.path)
        ) {
            ScrollView {
                VStack {
                    departureView
                    Spacer(minLength: 5)
                    departureDateView
                    Spacer(minLength: 24)
                    searchView
                }
                .padding(.top, 24)
                .frame(maxWidth: .infinity, alignment: .top)
                .onChange(of: scenePhase) { _, newValue in
                    switch newValue {
                    case .active:
                        store.send(.scenePhaseBecomeActive)
                    default:
                        break
                    }
                }
            }
            .navigationTitle("Airports")
            .background(Color(AppColor.background))
            .sheet(
                item: $store.scope(
                    state: \.airportList,
                    action: \.list
                )
            ) { store in
                AirportListView(store: store)
            }
            .sheet(
                item: $store.scope(
                    state: \.yearMonthPicker,
                    action: \.yearMonth
                )
            ) { store in
                YearMonthPickerView(store: store)
                    .presentationDetents([.fraction(0.3)])
            }
            .sheet(
                item: $store.scope(
                    state: \.cabinList,
                    action: \.selectedCabin
                )
            ) { store in
                CabinView(store: store)
                    .presentationDetents([.fraction(0.3)])
            }
        } destination: { store in
            switch store.case {
            case let .calendar(store):
                CalendarView(store: store)
            }
        }
    }
    
    @ViewBuilder
    private var departureView: some View {
        ZStack {
            HStack(spacing: 0) {
                // FROM 卡片
                Button(action: {
                    store.send(.showList(.fromAirport))
                }) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("From")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                        Spacer(minLength: 0.5)
                        Text(store.fromCity?.location ?? "")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                            .fixedSize(horizontal: false, vertical: true)
                        Text(store.fromCity?.code ?? "")
                            .font(.title3)
                            .foregroundColor(.gray)
                            .fontWeight(.bold)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                    .background(
                        UnevenRoundedRectangle(
                            cornerRadii: .init(topLeading: 16, bottomLeading: 16, bottomTrailing: 0, topTrailing: 0),
                            style: .continuous
                        )
                        .fill(Color.white)
                    )
                    .overlay(
                        UnevenRoundedRectangle(
                            cornerRadii: .init(topLeading: 16, bottomLeading: 16, bottomTrailing: 0, topTrailing: 0),
                            style: .continuous
                        )
                        .stroke(Color(AppColor.border), lineWidth: 1)
                    )
                }
                .buttonStyle(PlainButtonStyle())

                Spacer(minLength: 5)

                // TO 卡片
                Button(action: {
                    store.send(.showList(.toAirport))
                }) {
                    VStack(alignment: .trailing, spacing: 4) {
                        Text("To")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                        Spacer(minLength: 0.5)
                        Text(store.toCity?.location ?? "")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                            .fixedSize(horizontal: false, vertical: true)
                        Text(store.toCity?.code ?? "")
                            .font(.title3)
                            .foregroundColor(.gray)
                            .fontWeight(.bold)
                    }
                    .frame(maxWidth: .infinity, alignment: .trailing)
                    .padding()
                    .background(
                        UnevenRoundedRectangle(
                            cornerRadii: .init(topLeading: 0, bottomLeading: 0, bottomTrailing: 16, topTrailing: 16),
                            style: .continuous
                        )
                        .fill(Color.white)
                    )
                    .overlay(
                        UnevenRoundedRectangle(
                            cornerRadii: .init(topLeading: 0, bottomLeading: 0, bottomTrailing: 16, topTrailing: 16),
                            style: .continuous
                        )
                        .stroke(Color(AppColor.border), lineWidth: 1)
                    )
                }
                .buttonStyle(PlainButtonStyle())
            }
            .padding(.horizontal)

            // 換向按鈕 (浮在上面)
            Button {
                store.send(.swapAirport)
            } label: {
                ZStack {
                    Circle()
                        .fill(Color.blue)
                        .frame(width: 44, height: 44)
                        .shadow(radius: 1)
                    Image(systemName: "arrow.left.arrow.right")
                        .foregroundColor(.white)
                        .font(.title2)
                }
            }
            .buttonStyle(PlainButtonStyle())
            .offset(y: 0)
        }
    }
    
    @ViewBuilder
    private var departureDateView: some View {
        ZStack {
            HStack(spacing: 0) {
                Button {
                    store.send(.showDatePicker)
                } label: {
                    HStack {
                        Image(systemName: "calendar")
                            .foregroundColor(.blue)
                            .font(.title)
                        VStack(alignment: .leading) {
                            Text("Depart")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                            Text("\(String(store.selectedYear))/\(String(store.selectedMonth))")
                                .font(.headline)
                                .foregroundColor(.blue)
                        }
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(
                        UnevenRoundedRectangle(
                            cornerRadii: .init(topLeading: 16, bottomLeading: 16, bottomTrailing: 0, topTrailing: 0),
                            style: .continuous
                        ).fill(Color(AppColor.buttonBackground))
                    )
                }

                Button {
                    store.send(.showCabinType)
                } label: {
                    HStack {
                        VStack(alignment: .leading) {
                            Text("Cabin")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                            Text(LocalizedStringKey(store.selectedCabin.rawValue))
                                .font(.headline)
                                .foregroundColor(.black)
                        }
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(
                        UnevenRoundedRectangle(
                            cornerRadii: .init(topLeading: 0, bottomLeading: 0, bottomTrailing: 16, topTrailing: 16),
                            style: .continuous
                        ).fill(Color.white)
                    )
                }
            }
            .frame(maxWidth: .infinity)
            
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(Color(AppColor.border), lineWidth: 1)
        }
        .padding(.horizontal)
    }
    
    @ViewBuilder
    private var searchView: some View {
        Button {
            store.send(.toCalendar)
        } label: {
            Text("Search")
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
