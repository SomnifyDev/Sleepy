// Copyright (c) 2021 Sleepy.

import Foundation

extension Date {
	/// Returns the amount of minutes from another date
	func minutes(from date: Date) -> Int {
		return abs(Calendar.current.dateComponents([.minute], from: date, to: self).minute ?? 0)
	}

	/// Returns date in some special string format
	func getFormattedDate(format: String) -> String {
		let dateformat = DateFormatter()
		dateformat.dateFormat = format
		return dateformat.string(from: self)
	}


    func getFormattedDate(_ format: String = "HH.mm", dateStyle: DateFormatter.Style, timeStyle: DateFormatter.Style) -> String {
        let dateformat = DateFormatter()
        dateformat.dateFormat = format
        dateformat.dateStyle = dateStyle
        dateformat.timeStyle = timeStyle
        dateformat.timeZone = TimeZone.current
        dateformat.locale = Locale(identifier: Locale.preferredLanguages.first!)
        return dateformat.string(from: self)
    }
}
