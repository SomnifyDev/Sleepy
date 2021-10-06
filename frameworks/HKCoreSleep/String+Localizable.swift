//
//  String+Localizable.swift
//  String+Localizable
//
//  Created by Никита Казанцев on 17.09.2021.
//

import Foundation

public extension String {
    var localized: String {
        return NSLocalizedString(self, comment: "\(self)_comment")
    }
}
