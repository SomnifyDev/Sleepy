//
//  Extensions.swift
//  HKStatistics
//
//  Created by Анас Бен Мустафа on 6/26/21.
//

import Foundation

extension Date {

    /// Returns the amount of minutes from another date
    func minutes(from date: Date) -> Int {
        return abs(Calendar.current.dateComponents([.minute], from: date, to: self).minute ?? 0)
    }
}
