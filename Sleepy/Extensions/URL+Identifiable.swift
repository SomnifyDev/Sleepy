// Copyright (c) 2022 Sleepy.

import Foundation

extension URL: Identifiable {
    public var id: String {
        absoluteString
    }
}
