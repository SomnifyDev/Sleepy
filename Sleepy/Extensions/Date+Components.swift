// Copyright (c) 2022 Sleepy.

import Foundation

extension Date {
    var startOfDay: Date {
        return Calendar.current.startOfDay(for: self)
    }

    var startOfMonth: Date {
        let calendar = Calendar(identifier: .gregorian)
        let components = calendar.dateComponents([.year, .month], from: self)
        return calendar.date(from: components)!
    }

    var endOfDay: Date {
        var components = DateComponents()
        components.day = 1
        components.second = -1
        return Calendar.current.date(byAdding: components, to: self.startOfDay)!
    }

    var endOfMonth: Date {
        var components = DateComponents()
        components.month = 1
        components.second = -1
        return Calendar(identifier: .gregorian).date(byAdding: components, to: self.startOfMonth)!
    }

    var twoWeeksBefore: Date {
        var components = DateComponents()
        components.day = -14
        return Calendar.current.date(byAdding: components, to: self)!
    }

    var monthBefore: Date {
        var components = DateComponents()
        components.month = -1
        return Calendar.current.date(byAdding: components, to: self)!
    }

    func weekday() -> String? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EE"
        return dateFormatter.string(from: self)
    }

    func isMonday() -> Bool {
        let calendar = Calendar(identifier: .gregorian)
        let components = calendar.dateComponents([.weekday], from: self)
        return components.weekday == 2
    }

    func isToday() -> Bool {
        return self.startOfDay == Date().startOfDay
    }

    func nextTimeMatchingComponents(
        inDirection direction: Calendar.SearchDirection = .forward,
        using calendar: Calendar = .current,
        components: DateComponents
    ) -> Date {
        return calendar.nextDate(
            after: self,
            matching: components,
            matchingPolicy: .nextTime,
            direction: direction
        )!
    }

    func getFormattedDate(format: String) -> String {
        let dateformat = DateFormatter()
        dateformat.dateFormat = format
        return dateformat.string(from: self)
    }

    func getFormattedDate(_ format: String = "dd.MM", dateStyle: DateFormatter.Style, timeStyle: DateFormatter.Style) -> String
    {
        let dateformat = DateFormatter()
        dateformat.dateFormat = format
        dateformat.dateStyle = dateStyle
        dateformat.timeStyle = timeStyle
        dateformat.timeZone = TimeZone.current
        dateformat.locale = Locale(identifier: Locale.preferredLanguages.first!)
        return dateformat.string(from: self)
    }

    func years(from date: Date) -> Int {
        return Calendar.current.dateComponents([.year], from: date, to: self).year ?? 0
    }

    /// Returns the amount of months from another date
    func months(from date: Date) -> Int {
        return Calendar.current.dateComponents([.month], from: date, to: self).month ?? 0
    }

    /// Returns the amount of weeks from another date
    func weeks(from date: Date) -> Int {
        return Calendar.current.dateComponents([.weekOfMonth], from: date, to: self).weekOfMonth ?? 0
    }

    /// Returns the amount of days from another date
    func days(from date: Date) -> Int {
        return Calendar.current.dateComponents([.day], from: date, to: self).day ?? 0
    }

    /// Returns the amount of hours from another date
    func hours(from date: Date) -> Int {
        return Calendar.current.dateComponents([.hour], from: date, to: self).hour ?? 0
    }

    /// Returns the amount of minutes from another date
    func minutes(from date: Date) -> Int {
        return Calendar.current.dateComponents([.minute], from: date, to: self).minute ?? 0
    }

    /// Returns the amount of seconds from another date
    func seconds(from date: Date) -> Int {
        return Calendar.current.dateComponents([.second], from: date, to: self).second ?? 0
    }

    /// Returns hours and minutes from another date
    func hoursMinutes(from date: Date) -> String {
        let tmp = Calendar.current.dateComponents([.hour, .minute], from: date, to: self)
        let hours = tmp.hour ?? 0
        let minutes = tmp.minute ?? 0
        return "\(hours):\(minutes >= 10 ? String(minutes) : "0" + String(minutes))"
    }

    /// Returns the a custom time interval description from another date
    func offset(from date: Date) -> String {
        if self.years(from: date) > 0 { return "\(self.years(from: date))y" }
        if self.months(from: date) > 0 { return "\(self.months(from: date))M" }
        if self.weeks(from: date) > 0 { return "\(self.weeks(from: date))w" }
        if self.days(from: date) > 0 { return "\(self.days(from: date))d" }
        if self.hours(from: date) > 0 { return "\(self.hours(from: date))h" }
        if self.minutes(from: date) > 0 { return "\(self.minutes(from: date))m" }
        if self.seconds(from: date) > 0 { return "\(self.seconds(from: date))s" }
        return ""
    }

    func getDaysInMonth() -> Int {
        let calendar = Calendar.current

        let dateComponents = DateComponents(year: calendar.component(.year, from: self), month: calendar.component(.month, from: self))
        let date = calendar.date(from: dateComponents)!

        let range = calendar.range(of: .day, in: .month, for: date)!
        let numDays = range.count

        return numDays
    }

    func getMonthString() -> String {
        let df = DateFormatter()
        df.setLocalizedDateFormatFromTemplate("MMM")
        return df.string(from: self)
    }

    func getYearString() -> String {
        let df = DateFormatter()
        df.setLocalizedDateFormatFromTemplate("YYYY")
        return df.string(from: self)
    }

    func getMonthInt() -> Int {
        let index = Calendar.current.component(.month, from: self)
        return index
    }

    func getDayInt() -> Int {
        let df = DateFormatter()
        df.setLocalizedDateFormatFromTemplate("dd")
        return Int(df.string(from: self))!
    }

    func getHourInt() -> Int {
        let df = DateFormatter()
        df.setLocalizedDateFormatFromTemplate("HH")
        return Int(df.string(from: self))!
    }

    func getMinuteInt() -> Int {
        let df = DateFormatter()
        df.setLocalizedDateFormatFromTemplate("mm")
        return Int(df.string(from: self))!
    }

    func toString(dateFormat format: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        return dateFormatter.string(from: self)
    }

    static func minutesToDateDescription(minutes: Int) -> String {
        let hours = minutes / 60
        let minutes = minutes % 60
        let minutesStr = minutes > 9 ? String(minutes) : "0" + String(minutes)

        return "\(hours):\(minutesStr)"
    }

    static func minutesToClearString(minutes: Int) -> String {
        // TODO: localize
        let hours = minutes / 60
        let minutes = minutes % 60
        let minutesStr = minutes > 9 ? String(minutes) : "0" + String(minutes)

        return "\(hours)h \(minutesStr)min"
    }
}
