//
//  CabinType.swift
//  StarluxCalendar
//
//  Created by Kevin Chan on 2025/9/24.
//

enum CabinType: String, CaseIterable, Equatable, Identifiable {
    case eco = "eco"
    case ecoPremium = "ecoPremium"
    case business = "business"
    case first = "first"
    
    var id: String { rawValue }
}
