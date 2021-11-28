// Copyright (c) 2021 Sleepy.

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
