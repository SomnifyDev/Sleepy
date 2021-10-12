//
//  String+Extension.swift
//  Sleepy_WatchOS Extension
//
//  Created by Анас Бен Мустафа on 10/9/21.
//

import Foundation

extension String {
    var localized: String {
        return NSLocalizedString(self, comment: "")
    }
}
