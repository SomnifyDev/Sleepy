//
//  String+Localizable.swift
//  Sleepy
//
//  Created by Никита Казанцев on 27.08.2021.
//

import Foundation

public extension String {
    var localized: String {
        return NSLocalizedString(self, comment: "\(self)_comment")
    }
}
