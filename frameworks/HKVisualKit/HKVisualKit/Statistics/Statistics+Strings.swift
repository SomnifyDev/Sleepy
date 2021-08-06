//
//  Handling.swift
//  HKVisualKit
//
//  Created by Анас Бен Мустафа on 8/6/21.
//

import Foundation

public func getStringFormatOfTime(minutes: Int) -> String {
    return "\(minutes / 60)h \(minutes - (minutes / 60) * 60)min"
}
