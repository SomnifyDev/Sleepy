//
//  TimeInterval.swift
//  Sleepy
//
//  Created by Никита Казанцев on 11.07.2021.
//

import Foundation

extension DateInterval {
    enum StringFormatType: String {
        case days = "dd.MM"
        case time = "HH:mm"
    }

    func stringFromDateInterval(type: StringFormatType) -> String {
        return "\(start.getFormattedDate(format: type.rawValue)) - \(end.getFormattedDate(format: type.rawValue))"
    }
}
