//
//  TimeInterval.swift
//  Sleepy
//
//  Created by Никита Казанцев on 11.07.2021.
//

import Foundation

extension DateInterval {

    func stringFromDateInterval() -> String {
        return "\(self.start.getFormattedDate(format: "dd.MM")) - \(self.end.getFormattedDate(format: "dd.MM"))"
    }

}
