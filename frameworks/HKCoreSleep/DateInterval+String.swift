//
//  DateInterval+String.swift
//  DateInterval+String
//
//  Created by Никита Казанцев on 17.09.2021.
//


import Foundation

extension DateInterval {
    enum StringFormatType: String {
        case days = "dd.MM"
        case time = "HH:mm"
    }

    func stringFromDateInterval(type: StringFormatType) -> String {

        return "\(self.start.getFormattedDate(format: type.rawValue)) - \(self.end.getFormattedDate(format: type.rawValue))"
    }
}
