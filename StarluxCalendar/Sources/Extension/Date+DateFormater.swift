//
//  Date+DateFormater.swift
//  StarluxCalendar
//
//  Created by Kevin Chan on 2025/9/25.
//

import Foundation

extension Date {
    var locale: Locale {
        .defaultLocale
    }

    var calender: Calendar {
        var c = Calendar(identifier: .gregorian)
        c.locale = self.locale
        return c
    }
    
    func year() -> Int {
        self.calender.component(.year, from: self)
    }
    
    func month() -> Int {
        self.calender.component(.month, from: self)
    }
    
    func day() -> Int {
        self.calender.component(.day, from: self)
    }
    
    func getDateStringFromUTC(_ format: DateFormats = .yyyyMMddHHmmssWithSlash) -> String {
        let dateFormatter = DateFormatter.create(with: format)
        return dateFormatter.string(from: self)
    }
    
    func increaseYear(year: Int) -> Date {
        var dateComponents = DateComponents()
        dateComponents.year = year
        return self.calender.date(byAdding: dateComponents, to: self)!
    }
    
    func increaseMonth(month: Int) -> Date {
        var dateComponents = DateComponents()
        dateComponents.month = month
        return self.calender.date(byAdding: dateComponents, to: self)!
    }
    
    func increaseDate(day: Int) -> Date {
        var dateComponents = DateComponents()
        dateComponents.day = day
        return self.calender.date(byAdding: dateComponents, to: self)!
    }
    
    var startOfMonth: Date {
        let components = self.calender.dateComponents([.year, .month], from: self)

        return self.calender.date(from: components)!
    }
    
    var endOfMonth: Date {
        var components = DateComponents()
        components.month = 1
        components.second = -1
        
        return self.calender.date(byAdding: components, to: startOfMonth)!
    }
    
    var daysInMonth: Int {
        let range = self.calender.range(of: .day, in: .month, for: self)!
        return range.count
    }
    
    func getWeekday(startWith weekday: WeekDay = .sunday) -> Int {
        var c = calender
        c.firstWeekday = weekday.rawValue
        return (c.component(.weekday, from: self) - c.firstWeekday + 7) % 7 + 1
    }
    
    func getWeeksInMonth(startWith weekday: WeekDay = .sunday) -> Int {
        var c = calender
        c.firstWeekday = weekday.rawValue
        return c.range(of: .weekOfMonth, in: .month, for: self)!.count
    }
    
    func dateFrom(_ string: String, format: DateFormats = .yyyyMMdd) -> Date? {
        let df = DateFormatter()
        df.dateFormat = format.rawValue
        return df.date(from: string)
    }
    
    static func createDate(year: Int, month: Int) -> Date {
        let components = DateComponents(year: year, month: month, day: 1)
        return Calendar.current.date(from: components) ?? Date()
    }
    
    enum WeekDay: Int, CaseIterable, Identifiable {
        case sunday = 1
        case monday = 2
        case tuesday = 3
        case wednesday = 4
        case thursday = 5
        case friday = 6
        case saturday = 7
        
        var titleCatelog: String {
            switch self {
            case .sunday:
                return "Weekday_Sunday"
            case .monday:
                return "Weekday_Monday"
            case .tuesday:
                return "Weekday_Tuesday"
            case .wednesday:
                return "Weekday_Wednesday"
            case .thursday:
                return "Weekday_Thursday"
            case .friday:
                return "Weekday_Friday"
            case .saturday:
                return "Weekday_Saturday"
            }
        }
        
        var id: UUID {
            return UUID()
        }
    }
}

extension Locale {
    
    public static var defaultLocale: Locale {
        Locale(identifier: "zh_TW")
    }
    
    public static var languageAndRegion: String {
        var languageAndRegion = ""
        if let language = Locale.current.language.languageCode?.identifier {
            languageAndRegion.append(language)
            if let region = Locale.current.region?.identifier {
                languageAndRegion.append("_\(region)")
            }
        }
        return languageAndRegion
    }
}

public extension DateFormatter {
    static func create(with format: DateFormats, locale: Locale = .defaultLocale, timeZone: TimeZone? = nil) -> DateFormatter {
        var c = Calendar(identifier: .gregorian)
        c.locale = locale
        c.timeZone = timeZone ?? TimeZone.current
        
        let df = DateFormatter()
        df.dateFormat = format.rawValue
        df.calendar = c
        df.locale = locale
        df.timeZone = timeZone ?? TimeZone.current
        return df
    }
}

public enum DateFormats: String {
    /// yyyy-MM-dd'T'HH:mm:ssZ
    case iso8601                    = "yyyy-MM-dd'T'HH:mm:ssZ"
    /// yyyy-MM
    case yyyyMM                     = "yyyy-MM"
    /// yyyy-MM-dd
    case yyyyMMdd                   = "yyyy-MM-dd"
    /// yyyMM
    case yM                         = "yyyyMM"
    /// yyyyMMdd
    case yMd                        = "yyyyMMdd"
    /// yyyy/MM/dd
    case yyyyMMddWithSlash          = "yyyy/MM/dd"
    /// yyyy/MM
    case yyyyMMWithSlash            = "yyyy/MM"
    /// yyyy.MM.dd
    case yyyyMMddWithDot            = "yyyy.MM.dd"
    /// yyyyMMddHHmmss
    case yyyyMMddHHmmss             = "yyyyMMddHHmmss"
    /// yyyy/MM/dd HH:mm
    case yyyyMMddHHmmWithSlash      = "yyyy/MM/dd HH:mm"
    /// yyyy/MM/dd HH:mm:ss
    case yyyyMMddHHmmssWithSlash    = "yyyy/MM/dd HH:mm:ss"
    /// yyyy/MM/dd HH:mm:ss.SSS
    case yyyyMMddHHmmssSSSWithSlash = "yyyy/MM/dd HH:mm:ss.SSS"
    /// M
    case M                          = "M"
    /// MM
    case MM                         = "MM"
    /// yyyy
    case yyyy                       = "yyyy"
    /// d
    case d                          = "d"
    /// mm:ss
    case mmss                       = "mm:ss"
    /// HH:mm
    case hhmm                       = "HH:mm"
    /// HH:mm:ss
    case hhmmss                     = "HH:mm:ss"
    /// EEE, MMM dd
    case eeeWithCommaMMMdd                       = "EEE, MMM dd"
    
    static subscript(_ format: DateFormats) -> String {
        format.rawValue
    }
}
