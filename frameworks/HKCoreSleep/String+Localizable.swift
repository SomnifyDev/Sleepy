// Copyright (c) 2022 Sleepy.

import Foundation

public extension String {
    var localized: String {
        return NSLocalizedString(self, comment: "\(self)_comment")
    }
}
