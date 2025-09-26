//
//  FlightSearchResult.swift
//  StarluxCalendar
//
//  Created by Kevin Chan on 2025/8/22.
//

import Foundation

// MARK: - Root
struct FlightSearchResult: Codable {
    let success: Bool
    let traceId: String
    let message: Message
    let data: FlightData
    let links: String?
    let meta: Meta
}

// MARK: - Message
struct Message: Codable {
    let code: String
    let content: String
    let details: String?
}

// MARK: - FlightData
struct FlightData: Codable {
    let flightInfo: FlightInfo
    let flights: [Flight]
    let availableCabins: AvailableCabins
}

// MARK: - FlightInfo
struct FlightInfo: Codable {
    let departure: String
    let arrival: String
}

// MARK: - Flight
struct Flight: Codable {
    let flightDetails: [FlightDetail]
    let isDirect: Bool
    let flightNo: [String]
    let airOffers: [AirOffer]
    let priceInfo: [PriceInfo]
    let ranking: Int
}

// MARK: - FlightDetail
struct FlightDetail: Codable {
    let id: String
    let departure: FlightEvent
    let arrival: FlightEvent
    let marketingAirlineCode: String
    let marketingFlightNumber: String
    let operatingAirlineCode: String
    let operatingAirlineFlightNumber: String?
    let operatingAirlineName: String
    let aircraftCode: String
    let duration: Int
    let isPendingApproval: Bool
}

struct FlightEvent: Codable {
    let dateTime: String
    let airport: String
    let terminal: String
}

// MARK: - AirOffer
struct AirOffer: Codable {
    let id: String
    let cabin: String
    let flights: [OfferFlight]
    let fareFamilyCode: String
    let quota: Int
    let isSoldOut: Bool
    let price: OfferPrice
}

struct OfferFlight: Codable {
    let id: String
    let cabin: String
    let bookingClass: String
    let baggagePolicyIds: [String]
    let fareProduct: FareProduct
}

struct FareProduct: Codable {
    let mileageAccumulate: MileageAccumulate
    let mileageUpgrade: String
}

struct MileageAccumulate: Codable {
    let amount: Int
    let percentage: String
}

struct OfferPrice: Codable {
    let base: Price
    let totalTaxes: Price
    let total: Price
}

struct Price: Codable {
    let amount: Int
    let currencyCode: String
}

// MARK: - PriceInfo
struct PriceInfo: Codable {
    let cabin: String
    let from: Price
}

// MARK: - AvailableCabins
struct AvailableCabins: Codable {
    let eco: Bool
    let ecoPremium: Bool
    let business: Bool
    let first: Bool
}

// MARK: - Meta
struct Meta: Codable {
    let airports: [Airport]
    let currencies: [Currency]
    let aircraft: [Aircraft]
    let cabins: [Cabin]
    let fareProducts: [FareProductMeta]
    let bookingClasses: [BookingClass]
    let flightEmissions: [FlightEmission]
    let baggagePolicies: [BaggagePolicy]
}

// MARK: - Airport
struct Airport: Codable {
    let code: String
    let name: String
    let city: City
    let country: Country
}

struct City: Codable {
    let code: String
    let name: String
}

struct Country: Codable {
    let code: String
    let name: String
}

// MARK: - Currency
struct Currency: Codable {
    let code: String
    let decimalPlaces: Int
}

// MARK: - Aircraft
struct Aircraft: Codable {
    let code: String
    let aircraft: String
    let equipments: [String]
}

// MARK: - Cabin
struct Cabin: Codable {
    let code: String
    let name: String
}

// MARK: - FareProductMeta
struct FareProductMeta: Codable {
    let fareFamilyCode: String
    let cabin: String
    let name: String
    let flightExperiences: FlightExperiences
    let cosmile: Cosmile
    let fareRules: FareRules
}

struct FlightExperiences: Codable {
    let seatSelection: String
    let checkedBaggage: String
    let carryOnBaggage: String
    let meal: String
    let internet: String
}

struct Cosmile: Codable {
    let mileageAccumulate: String
    let upgradeAward: String
}

struct FareRules: Codable {
    let validity: String
    let reissueFee: String
    let refundFee: String
    let noShowFee: String
}

// MARK: - BookingClass
struct BookingClass: Codable {
    let code: String
    let name: String
}

// MARK: - FlightEmission
struct FlightEmission: Codable {
    let id: String
    let emissionsGramsPerPax: EmissionsGramsPerPax
}

struct EmissionsGramsPerPax: Codable {
    let first: Int
    let business: Int
    let premiumEconomy: Int
    let economy: Int
}

// MARK: - BaggagePolicy
struct BaggagePolicy: Codable {
    let id: String
    let marketingAirlineCode: String
    let type: String
    let details: BaggageDetails
}

struct BaggageDetails: Codable {
    let type: String
    let quantity: Int
    let characteristics: [BaggageCharacteristic]
}

struct BaggageCharacteristic: Codable {
    let description: String
    let policyDetails: [PolicyDetail]
}

struct PolicyDetail: Codable {
    let type: String
    let qualifier: String
    let value: String
    let unit: String
}
